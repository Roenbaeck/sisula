-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw."_Positor" (
    "Positor" tinyint not null,
    constraint "pk_Positor" primary key (
        "Positor"
    ) RELY
);
MERGE INTO dw."_Positor" p
USING ( SELECT 0 AS _defaultPositor ) d
ON (
    d._defaultPositor = p."Positor"
)
WHEN NOT MATCHED THEN
INSERT (
    "Positor"
)
VALUES (
    d._defaultPositor
);
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_Föräldratyp table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_Föräldratyp" (
    "PAT_ID" tinyint not null,
    "PAT_Föräldratyp" varchar(42) not null,
    "Metadata_PAT" int not null,
    constraint "pkPAT_Föräldratyp" primary key (
        "PAT_ID" 
    ) RELY,
    constraint "uqPAT_Föräldratyp" unique (
        "PAT_Föräldratyp"
    ) RELY
) CLUSTER BY ("PAT_ID");
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Kön table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Kön" (
    "GEN_ID" number(1,0) not null,
    "GEN_Kön" varchar(42) not null,
    "GEN_Checksum" numeric(19,0) default hash("GEN_Kön"),
    "Metadata_GEN" int not null,
    constraint "pkGEN_Kön" primary key (
        "GEN_ID" 
    ) RELY,
    constraint "uqGEN_Kön" unique (
        "GEN_Checksum" 
    ) RELY
) CLUSTER BY ("GEN_ID");
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå" (
    "PLV_ID" tinyint not null,
    "PLV_Yrkesnivå" string not null,
    "PLV_Checksum" numeric(19,0) default hash("PLV_Yrkesnivå"),
    "Metadata_PLV" int not null,
    constraint "pkPLV_Yrkesnivå" primary key (
        "PLV_ID" 
    ) RELY,
    constraint "uqPLV_Yrkesnivå" unique (
        "PLV_Checksum" 
    ) RELY
) CLUSTER BY ("PLV_ID");
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utnyttjande table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utnyttjande" (
    "UTL_ID" tinyint not null,
    "UTL_Utnyttjande" tinyint not null,
    "Metadata_UTL" int not null,
    constraint "pkUTL_Utnyttjande" primary key (
        "UTL_ID" 
    ) RELY,
    constraint "uqUTL_Utnyttjande" unique (
        "UTL_Utnyttjande"
    ) RELY
) CLUSTER BY ("UTL_ID");
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Pågående table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående" (
    "ONG_ID" tinyint not null,
    "ONG_Pågående" varchar(3) not null,
    "Metadata_ONG" int not null,
    constraint "pkONG_Pågående" primary key (
        "ONG_ID" 
    ) RELY,
    constraint "uqONG_Pågående" unique (
        "ONG_Pågående"
    ) RELY
) CLUSTER BY ("ONG_ID");
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Betyg table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Betyg_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg" (
    "RAT_ID" tinyint default knots."RAT_Betyg_ID_SEQ".nextval not null, 
    "RAT_Betyg" varchar(42) not null,
    "RAT_Checksum" numeric(19,0) default hash("RAT_Betyg"),
    "Metadata_RAT" int not null,
    constraint "pkRAT_Betyg" primary key (
        "RAT_ID" 
    ) RELY,
    constraint "uqRAT_Betyg" unique (
        "RAT_Checksum" 
    ) RELY
) CLUSTER BY ("RAT_ID");
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp" (
    "ETY_ID" tinyint not null,
    "ETY_Händelsetyp" varchar(42) not null,
    "ETY_Checksum" numeric(19,0) default hash("ETY_Händelsetyp"),
    "Metadata_ETY" int not null,
    constraint "pkETY_Händelsetyp" primary key (
        "ETY_ID" 
    ) RELY,
    constraint "uqETY_Händelsetyp" unique (
        "ETY_Checksum" 
    ) RELY
) CLUSTER BY ("ETY_ID");
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
    "PN_ID" bigint default anchors."PN_Person_ID_SEQ".nextval not null, 
    "Metadata_PN" int not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    ) RELY
) CLUSTER BY ("PN_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Scen table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Scen" (
    "ST_ID" int not null,
    "Metadata_ST" int not null,
    constraint "pkST_Scen" primary key (
        "ST_ID"
    ) RELY
) CLUSTER BY ("ST_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Skådespelare table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Skådespelare_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Skådespelare" (
    "AC_ID" smallint default anchors."AC_Skådespelare_ID_SEQ".nextval not null, 
    "Metadata_AC" int not null,
    constraint "pkAC_Skådespelare" primary key (
        "AC_ID"
    ) RELY
) CLUSTER BY ("AC_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Föreställning table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Föreställning" (
    "PR_ID" number(10,0) not null,
    "Metadata_PR" int not null,
    constraint "pkPR_Föreställning" primary key (
        "PR_ID"
    ) RELY
) CLUSTER BY ("PR_ID");
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Händelse table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses."EV_Händelse" (
    "EV_ID" numeric(12,0) not null,
    "ST_ID_hölls" int not null, 
    "PR_ID_spelades" number(10,0) not null, 
    "ETY_ID_of" tinyint not null,
    constraint "EV_Händelse_fkST_hölls" foreign key (
        "ST_ID_hölls"
    ) references anchors."ST_Scen"("ST_ID") RELY, 
    constraint "EV_Händelse_fkPR_spelades" foreign key (
        "PR_ID_spelades"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "EV_Händelse_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references knots."ETY_Händelsetyp"("ETY_ID") RELY,
    "Metadata_EV" int not null, 
    constraint "pkEV_Händelse" primary key (
        "EV_ID"
    ) RELY
) CLUSTER BY ("EV_ID");
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
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW attributes."EV_DAT_Händelse_Datum" COPY GRANTS AS
SELECT
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Händelse_Datum",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Positor",
    a."EV_DAT_Reliability",
    a."EV_DAT_Assertion"
FROM
    attributes."EV_DAT_Händelse_Datum_Posit" p
JOIN
    attributes."EV_DAT_Händelse_Datum_Annex" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
;
CREATE OR REPLACE VIEW attributes."EV_AUD_Händelse_Publik" COPY GRANTS AS
SELECT
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Händelse_Publik",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Positor",
    a."EV_AUD_Reliability",
    a."EV_AUD_Assertion"
FROM
    attributes."EV_AUD_Händelse_Publik_Posit" p
JOIN
    attributes."EV_AUD_Händelse_Publik_Annex" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
;
CREATE OR REPLACE VIEW attributes."EV_REV_Händelse_Intäkt" COPY GRANTS AS
SELECT
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    p."EV_REV_EV_ID",
    p."EV_REV_Händelse_Intäkt",
    a."EV_REV_PositedAt",
    a."EV_REV_Positor",
    a."EV_REV_Reliability",
    a."EV_REV_Assertion"
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit" p
JOIN
    attributes."EV_REV_Händelse_Intäkt_Annex" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
;
CREATE OR REPLACE VIEW attributes."EV_STA_Händelse_Status" COPY GRANTS AS
SELECT
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    p."EV_STA_EV_ID",
    p."EV_STA_Händelse_Status",
    p."EV_STA_ChangedAt",
    a."EV_STA_PositedAt",
    a."EV_STA_Positor",
    a."EV_STA_Reliability",
    a."EV_STA_Assertion"
FROM
    attributes."EV_STA_Händelse_Status_Posit" p
JOIN
    attributes."EV_STA_Händelse_Status_Annex" a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
;
CREATE OR REPLACE VIEW attributes."EV_UTL_Händelse_Utnyttjande" COPY GRANTS AS
SELECT
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Positor",
    a."EV_UTL_Reliability",
    a."EV_UTL_Assertion"
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
JOIN
    attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
;
CREATE OR REPLACE VIEW attributes."EV_LVL_Händelse_Level" COPY GRANTS AS
SELECT
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Positor",
    a."EV_LVL_Reliability",
    a."EV_LVL_Assertion"
FROM
    attributes."EV_LVL_Händelse_Level_Posit" p
JOIN
    attributes."EV_LVL_Händelse_Level_Annex" a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
;
CREATE OR REPLACE VIEW attributes."ST_NAM_Scen_Namn" COPY GRANTS AS
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Scen_Namn",
    p."ST_NAM_ChangedAt",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Positor",
    a."ST_NAM_Reliability",
    a."ST_NAM_Assertion"
FROM
    attributes."ST_NAM_Scen_Namn_Posit" p
JOIN
    attributes."ST_NAM_Scen_Namn_Annex" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."ST_LOC_Scen_Plats" COPY GRANTS AS
SELECT
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Scen_Plats",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Positor",
    a."ST_LOC_Reliability",
    a."ST_LOC_Assertion"
FROM
    attributes."ST_LOC_Scen_Plats_Posit" p
JOIN
    attributes."ST_LOC_Scen_Plats_Annex" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
;
CREATE OR REPLACE VIEW attributes."ST_AVG_Scen_Medel" COPY GRANTS AS
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
    attributes."ST_AVG_Scen_Medel_Posit" p
JOIN
    attributes."ST_AVG_Scen_Medel_Annex" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
;
CREATE OR REPLACE VIEW attributes."ST_MIN_Scen_Minimum" COPY GRANTS AS
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
    attributes."ST_MIN_Scen_Minimum_Posit" p
JOIN
    attributes."ST_MIN_Scen_Minimum_Annex" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
;
CREATE OR REPLACE VIEW attributes."AC_NAM_Skådespelare_Namn" COPY GRANTS AS
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Skådespelare_Namn",
    p."AC_NAM_ChangedAt",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Positor",
    a."AC_NAM_Reliability",
    a."AC_NAM_Assertion"
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit" p
JOIN
    attributes."AC_NAM_Skådespelare_Namn_Annex" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."AC_GEN_Skådespelare_Kön" COPY GRANTS AS
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
    attributes."AC_GEN_Skådespelare_Kön_Posit" p
JOIN
    attributes."AC_GEN_Skådespelare_Kön_Annex" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
;
CREATE OR REPLACE VIEW attributes."AC_PLV_Skådespelare_Yrkesnivå" COPY GRANTS AS
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
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
JOIN
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
;
CREATE OR REPLACE VIEW attributes."PR_NAM_Föreställning_Namn" COPY GRANTS AS
SELECT
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Föreställning_Namn",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Positor",
    a."PR_NAM_Reliability",
    a."PR_NAM_Assertion"
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit" p
JOIN
    attributes."PR_NAM_Föreställning_Namn_Annex" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."PR_LEN_Föreställning_Längd" COPY GRANTS AS
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Föreställning_Längd",
    p."PR_LEN_ChangedAt",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Positor",
    a."PR_LEN_Reliability",
    a."PR_LEN_Assertion"
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit" p
JOIN
    attributes."PR_LEN_Föreställning_Längd_Annex" a
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
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_DAT_Händelse_Datum_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_DAT" int,
    "EV_DAT_ID" int,
    "EV_DAT_PositedAt" datetime,
    "EV_DAT_Positor" tinyint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" string
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
    attributes."EV_DAT_Händelse_Datum_Annex"
WHERE
    "EV_DAT_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_DAT_Händelse_Datum" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_DAT" int,
    "EV_DAT_ID" int,
    "EV_DAT_PositedAt" datetime,
    "EV_DAT_Positor" tinyint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" string,
    "EV_DAT_EV_ID" numeric(12,0),
    "EV_DAT_Händelse_Datum" datetime
)
AS
$$
SELECT
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Positor",
    a."EV_DAT_Reliability",
    a."EV_DAT_Assertion",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Händelse_Datum"
FROM
    attributes."EV_DAT_Händelse_Datum_Posit" p
JOIN
    TABLE(attributes."rEV_DAT_Händelse_Datum_Annex"(positingTimepoint)) a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
AND
    a."EV_DAT_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_DAT_ID"
        ORDER BY a."EV_DAT_PositedAt" DESC
    ) = 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_AUD_Händelse_Publik_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_AUD" int,
    "EV_AUD_ID" int,
    "EV_AUD_PositedAt" datetime,
    "EV_AUD_Positor" tinyint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" string
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
    attributes."EV_AUD_Händelse_Publik_Annex"
WHERE
    "EV_AUD_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_AUD_Händelse_Publik" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_AUD" int,
    "EV_AUD_ID" int,
    "EV_AUD_PositedAt" datetime,
    "EV_AUD_Positor" tinyint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" string,
    "EV_AUD_EV_ID" numeric(12,0),
    "EV_AUD_Händelse_Publik" int
)
AS
$$
SELECT
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Positor",
    a."EV_AUD_Reliability",
    a."EV_AUD_Assertion",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Händelse_Publik"
FROM
    attributes."EV_AUD_Händelse_Publik_Posit" p
JOIN
    TABLE(attributes."rEV_AUD_Händelse_Publik_Annex"(positingTimepoint)) a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
AND
    a."EV_AUD_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_AUD_ID"
        ORDER BY a."EV_AUD_PositedAt" DESC
    ) = 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_REV_Händelse_Intäkt_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_REV" int,
    "EV_REV_ID" int,
    "EV_REV_PositedAt" datetime,
    "EV_REV_Positor" tinyint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" string
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
    attributes."EV_REV_Händelse_Intäkt_Annex"
WHERE
    "EV_REV_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_REV_Händelse_Intäkt" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_REV" int,
    "EV_REV_ID" int,
    "EV_REV_PositedAt" datetime,
    "EV_REV_Positor" tinyint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" string,
    "EV_REV_EV_ID" numeric(12,0),
    "EV_REV_Händelse_Intäkt" number(19,4)
)
AS
$$
SELECT
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    a."EV_REV_PositedAt",
    a."EV_REV_Positor",
    a."EV_REV_Reliability",
    a."EV_REV_Assertion",
    p."EV_REV_EV_ID",
    p."EV_REV_Händelse_Intäkt"
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit" p
JOIN
    TABLE(attributes."rEV_REV_Händelse_Intäkt_Annex"(positingTimepoint)) a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
AND
    a."EV_REV_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_REV_ID"
        ORDER BY a."EV_REV_PositedAt" DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Händelse_Status_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "EV_STA_ID" int,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_STA_ChangedAt" datetime
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
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_STA_Händelse_Status_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "EV_STA_ID" int,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_STA_ChangedAt" datetime
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Händelse_Status_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_STA" int,
    "EV_STA_ID" int,
    "EV_STA_PositedAt" datetime,
    "EV_STA_Positor" tinyint,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Assertion" string
)
AS
$$
SELECT
    "Metadata_EV_STA",
    "EV_STA_ID",
    "EV_STA_PositedAt",
    "EV_STA_Positor",
    "EV_STA_Reliability",
    "EV_STA_Assertion"
FROM
    attributes."EV_STA_Händelse_Status_Annex"
WHERE
    "EV_STA_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Händelse_Status" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_STA" int,
    "EV_STA_ID" int,
    "EV_STA_PositedAt" datetime,
    "EV_STA_Positor" tinyint,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Assertion" string,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_STA_ChangedAt" datetime
)
AS
$$
SELECT
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Positor",
    a."EV_STA_Reliability",
    a."EV_STA_Assertion",
    p."EV_STA_EV_ID",
    p."EV_STA_Händelse_Status",
    p."EV_STA_ChangedAt"
FROM
    TABLE(attributes."rEV_STA_Händelse_Status_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rEV_STA_Händelse_Status_Annex"(positingTimepoint)) a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
AND
    a."EV_STA_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_STA_ID"
        ORDER BY a."EV_STA_PositedAt" DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_STA_Händelse_Status" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_STA" int,
    "EV_STA_ID" int,
    "EV_STA_PositedAt" datetime,
    "EV_STA_Positor" tinyint,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Assertion" string,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_STA_ChangedAt" datetime
)
AS
$$
SELECT
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Positor",
    a."EV_STA_Reliability",
    a."EV_STA_Assertion",
    p."EV_STA_EV_ID",
    p."EV_STA_Händelse_Status",
    p."EV_STA_ChangedAt"
FROM
    TABLE(attributes."fEV_STA_Händelse_Status_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rEV_STA_Händelse_Status_Annex"(positingTimepoint)) a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
AND
    a."EV_STA_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_STA_ID"
        ORDER BY a."EV_STA_PositedAt" DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preEV_STA_Händelse_Status" (
    id numeric(12,0),
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS varchar(20)
AS
$$
SELECT
    pre."EV_STA_Händelse_Status"
FROM
    TABLE(attributes."rEV_STA_Händelse_Status"(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre."EV_STA_EV_ID" = id
AND
    pre."EV_STA_ChangedAt" < changingTimepoint
AND
    pre."EV_STA_Assertion" = coalesce(assertion, pre."EV_STA_Assertion")
ORDER BY
    pre."EV_STA_ChangedAt" DESC,
    pre."EV_STA_PositedAt" DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folEV_STA_Händelse_Status" (
    id numeric(12,0),
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS varchar(20)
AS
$$
SELECT
    fol."EV_STA_Händelse_Status"
FROM
    TABLE(attributes."fEV_STA_Händelse_Status"(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol."EV_STA_EV_ID" = id
AND
    fol."EV_STA_ChangedAt" > changingTimepoint
AND
    fol."EV_STA_Assertion" = coalesce(assertion, fol."EV_STA_Assertion")
ORDER BY
    fol."EV_STA_ChangedAt" ASC,
    fol."EV_STA_PositedAt" DESC
LIMIT 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_UTL_Händelse_Utnyttjande_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_UTL" int,
    "EV_UTL_ID" int,
    "EV_UTL_PositedAt" datetime,
    "EV_UTL_Positor" tinyint,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_Assertion" string
)
AS
$$
SELECT
    "Metadata_EV_UTL",
    "EV_UTL_ID",
    "EV_UTL_PositedAt",
    "EV_UTL_Positor",
    "EV_UTL_Reliability",
    "EV_UTL_Assertion"
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Annex"
WHERE
    "EV_UTL_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_UTL_Händelse_Utnyttjande" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_UTL" int,
    "EV_UTL_ID" int,
    "EV_UTL_PositedAt" datetime,
    "EV_UTL_Positor" tinyint,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_Assertion" string,
    "EV_UTL_EV_ID" numeric(12,0),
    "EV_UTL_UTL_ID" tinyint 
)
AS
$$
SELECT
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Positor",
    a."EV_UTL_Reliability",
    a."EV_UTL_Assertion",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID"
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
JOIN
    TABLE(attributes."rEV_UTL_Händelse_Utnyttjande_Annex"(positingTimepoint)) a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
AND
    a."EV_UTL_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_UTL_ID"
        ORDER BY a."EV_UTL_PositedAt" DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Händelse_Level_Posit" (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    "EV_LVL_ID" int,
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" tinyint, 
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
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_LVL_Händelse_Level_Posit" (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    "EV_LVL_ID" int,
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" tinyint, 
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Händelse_Level_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_LVL" int,
    "EV_LVL_ID" int,
    "EV_LVL_PositedAt" datetime,
    "EV_LVL_Positor" tinyint,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_Assertion" string
)
AS
$$
SELECT
    "Metadata_EV_LVL",
    "EV_LVL_ID",
    "EV_LVL_PositedAt",
    "EV_LVL_Positor",
    "EV_LVL_Reliability",
    "EV_LVL_Assertion"
FROM
    attributes."EV_LVL_Händelse_Level_Annex"
WHERE
    "EV_LVL_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Händelse_Level" (
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_LVL" int,
    "EV_LVL_ID" int,
    "EV_LVL_PositedAt" datetime,
    "EV_LVL_Positor" tinyint,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_Assertion" string,
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" tinyint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Positor",
    a."EV_LVL_Reliability",
    a."EV_LVL_Assertion",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    TABLE(attributes."rEV_LVL_Händelse_Level_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rEV_LVL_Händelse_Level_Annex"(positingTimepoint)) a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
AND
    a."EV_LVL_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_LVL_ID"
        ORDER BY a."EV_LVL_PositedAt" DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_LVL_Händelse_Level" (
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_LVL" int,
    "EV_LVL_ID" int,
    "EV_LVL_PositedAt" datetime,
    "EV_LVL_Positor" tinyint,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_Assertion" string,
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" tinyint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Positor",
    a."EV_LVL_Reliability",
    a."EV_LVL_Assertion",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    TABLE(attributes."fEV_LVL_Händelse_Level_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rEV_LVL_Händelse_Level_Annex"(positingTimepoint)) a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
AND
    a."EV_LVL_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_LVL_ID"
        ORDER BY a."EV_LVL_PositedAt" DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preEV_LVL_Händelse_Level" (
    id numeric(12,0),
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    pre."EV_LVL_PLV_ID"
FROM
    TABLE(attributes."rEV_LVL_Händelse_Level"(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre."EV_LVL_EV_ID" = id
AND
    pre."EV_LVL_ChangedAt" < changingTimepoint
AND
    pre."EV_LVL_Assertion" = coalesce(assertion, pre."EV_LVL_Assertion")
ORDER BY
    pre."EV_LVL_ChangedAt" DESC,
    pre."EV_LVL_PositedAt" DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folEV_LVL_Händelse_Level" (
    id numeric(12,0),
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    fol."EV_LVL_PLV_ID"
FROM
    TABLE(attributes."fEV_LVL_Händelse_Level"(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol."EV_LVL_EV_ID" = id
AND
    fol."EV_LVL_ChangedAt" > changingTimepoint
AND
    fol."EV_LVL_Assertion" = coalesce(assertion, fol."EV_LVL_Assertion")
ORDER BY
    fol."EV_LVL_ChangedAt" ASC,
    fol."EV_LVL_PositedAt" DESC
LIMIT 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Scen_Namn_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_NAM_ID" int,
    "ST_NAM_ST_ID" int,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_NAM_ChangedAt" datetime
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
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_NAM_Scen_Namn_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_NAM_ID" int,
    "ST_NAM_ST_ID" int,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_NAM_ChangedAt" datetime
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Scen_Namn_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Positor" tinyint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" string
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
    attributes."ST_NAM_Scen_Namn_Annex"
WHERE
    "ST_NAM_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Scen_Namn" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Positor" tinyint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" string,
    "ST_NAM_ST_ID" int,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_NAM_ChangedAt" datetime
)
AS
$$
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Positor",
    a."ST_NAM_Reliability",
    a."ST_NAM_Assertion",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Scen_Namn",
    p."ST_NAM_ChangedAt"
FROM
    TABLE(attributes."rST_NAM_Scen_Namn_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rST_NAM_Scen_Namn_Annex"(positingTimepoint)) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
AND
    a."ST_NAM_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."ST_NAM_ID"
        ORDER BY a."ST_NAM_PositedAt" DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_NAM_Scen_Namn" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Positor" tinyint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" string,
    "ST_NAM_ST_ID" int,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_NAM_ChangedAt" datetime
)
AS
$$
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Positor",
    a."ST_NAM_Reliability",
    a."ST_NAM_Assertion",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Scen_Namn",
    p."ST_NAM_ChangedAt"
FROM
    TABLE(attributes."fST_NAM_Scen_Namn_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rST_NAM_Scen_Namn_Annex"(positingTimepoint)) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
AND
    a."ST_NAM_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."ST_NAM_ID"
        ORDER BY a."ST_NAM_PositedAt" DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preST_NAM_Scen_Namn" (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    pre."ST_NAM_Scen_Namn"
FROM
    TABLE(attributes."rST_NAM_Scen_Namn"(positor, changingTimepoint, positingTimepoint)) pre
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
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folST_NAM_Scen_Namn" (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    fol."ST_NAM_Scen_Namn"
FROM
    TABLE(attributes."fST_NAM_Scen_Namn"(positor, changingTimepoint, positingTimepoint)) fol
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_LOC_Scen_Plats_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Positor" tinyint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" string
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
    attributes."ST_LOC_Scen_Plats_Annex"
WHERE
    "ST_LOC_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_LOC_Scen_Plats" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Positor" tinyint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" string,
    "ST_LOC_ST_ID" int,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography
)
AS
$$
SELECT
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Positor",
    a."ST_LOC_Reliability",
    a."ST_LOC_Assertion",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Scen_Plats"
FROM
    attributes."ST_LOC_Scen_Plats_Posit" p
JOIN
    TABLE(attributes."rST_LOC_Scen_Plats_Annex"(positingTimepoint)) a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
AND
    a."ST_LOC_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."ST_LOC_ID"
        ORDER BY a."ST_LOC_PositedAt" DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Scen_Medel_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_AVG_ID" int,
    "ST_AVG_ST_ID" int,
    "ST_AVG_UTL_ID" tinyint, 
    "ST_AVG_ChangedAt" datetime
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
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_AVG_Scen_Medel_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_AVG_ID" int,
    "ST_AVG_ST_ID" int,
    "ST_AVG_UTL_ID" tinyint, 
    "ST_AVG_ChangedAt" datetime
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Scen_Medel_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Positor" tinyint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" string
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
    attributes."ST_AVG_Scen_Medel_Annex"
WHERE
    "ST_AVG_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Scen_Medel" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Positor" tinyint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" string,
    "ST_AVG_ST_ID" int,
    "ST_AVG_UTL_ID" tinyint, 
    "ST_AVG_ChangedAt" datetime
)
AS
$$
SELECT
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
    TABLE(attributes."rST_AVG_Scen_Medel_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rST_AVG_Scen_Medel_Annex"(positingTimepoint)) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
AND
    a."ST_AVG_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."ST_AVG_ID"
        ORDER BY a."ST_AVG_PositedAt" DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_AVG_Scen_Medel" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Positor" tinyint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" string,
    "ST_AVG_ST_ID" int,
    "ST_AVG_UTL_ID" tinyint, 
    "ST_AVG_ChangedAt" datetime
)
AS
$$
SELECT
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
    TABLE(attributes."fST_AVG_Scen_Medel_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rST_AVG_Scen_Medel_Annex"(positingTimepoint)) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
AND
    a."ST_AVG_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."ST_AVG_ID"
        ORDER BY a."ST_AVG_PositedAt" DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preST_AVG_Scen_Medel" (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    pre."ST_AVG_UTL_ID"
FROM
    TABLE(attributes."rST_AVG_Scen_Medel"(positor, changingTimepoint, positingTimepoint)) pre
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
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folST_AVG_Scen_Medel" (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    fol."ST_AVG_UTL_ID"
FROM
    TABLE(attributes."fST_AVG_Scen_Medel"(positor, changingTimepoint, positingTimepoint)) fol
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_MIN_Scen_Minimum_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Positor" tinyint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" string
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
    attributes."ST_MIN_Scen_Minimum_Annex"
WHERE
    "ST_MIN_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_MIN_Scen_Minimum" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Positor" tinyint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" string,
    "ST_MIN_ST_ID" int,
    "ST_MIN_UTL_ID" tinyint 
)
AS
$$
SELECT
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Positor",
    a."ST_MIN_Reliability",
    a."ST_MIN_Assertion",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID"
FROM
    attributes."ST_MIN_Scen_Minimum_Posit" p
JOIN
    TABLE(attributes."rST_MIN_Scen_Minimum_Annex"(positingTimepoint)) a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
AND
    a."ST_MIN_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."ST_MIN_ID"
        ORDER BY a."ST_MIN_PositedAt" DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Skådespelare_Namn_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_NAM_ID" int,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_NAM_ChangedAt" datetime
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
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_NAM_Skådespelare_Namn_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_NAM_ID" int,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_NAM_ChangedAt" datetime
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Skådespelare_Namn_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Positor" tinyint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" string
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
    attributes."AC_NAM_Skådespelare_Namn_Annex"
WHERE
    "AC_NAM_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Skådespelare_Namn" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Positor" tinyint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" string,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_NAM_ChangedAt" datetime
)
AS
$$
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Positor",
    a."AC_NAM_Reliability",
    a."AC_NAM_Assertion",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Skådespelare_Namn",
    p."AC_NAM_ChangedAt"
FROM
    TABLE(attributes."rAC_NAM_Skådespelare_Namn_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rAC_NAM_Skådespelare_Namn_Annex"(positingTimepoint)) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
AND
    a."AC_NAM_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_NAM_ID"
        ORDER BY a."AC_NAM_PositedAt" DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_NAM_Skådespelare_Namn" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Positor" tinyint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" string,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_NAM_ChangedAt" datetime
)
AS
$$
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Positor",
    a."AC_NAM_Reliability",
    a."AC_NAM_Assertion",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Skådespelare_Namn",
    p."AC_NAM_ChangedAt"
FROM
    TABLE(attributes."fAC_NAM_Skådespelare_Namn_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rAC_NAM_Skådespelare_Namn_Annex"(positingTimepoint)) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
AND
    a."AC_NAM_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_NAM_ID"
        ORDER BY a."AC_NAM_PositedAt" DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preAC_NAM_Skådespelare_Namn" (
    id smallint,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS varbinary(max)
AS
$$
SELECT
    pre."AC_NAM_Skådespelare_Namn"
FROM
    TABLE(attributes."rAC_NAM_Skådespelare_Namn"(positor, changingTimepoint, positingTimepoint)) pre
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
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folAC_NAM_Skådespelare_Namn" (
    id smallint,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS varbinary(max)
AS
$$
SELECT
    fol."AC_NAM_Skådespelare_Namn"
FROM
    TABLE(attributes."fAC_NAM_Skådespelare_Namn"(positor, changingTimepoint, positingTimepoint)) fol
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_GEN_Skådespelare_Kön_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Positor" tinyint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" string
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
    attributes."AC_GEN_Skådespelare_Kön_Annex"
WHERE
    "AC_GEN_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_GEN_Skådespelare_Kön" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Positor" tinyint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" string,
    "AC_GEN_AC_ID" smallint,
    "AC_GEN_GEN_ID" number(1,0) 
)
AS
$$
SELECT
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Positor",
    a."AC_GEN_Reliability",
    a."AC_GEN_Assertion",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID"
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit" p
JOIN
    TABLE(attributes."rAC_GEN_Skådespelare_Kön_Annex"(positingTimepoint)) a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
AND
    a."AC_GEN_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_GEN_ID"
        ORDER BY a."AC_GEN_PositedAt" DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Skådespelare_Yrkesnivå_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_PLV_ID" int,
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" tinyint, 
    "AC_PLV_ChangedAt" datetime
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
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_PLV_Skådespelare_Yrkesnivå_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_PLV_ID" int,
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" tinyint, 
    "AC_PLV_ChangedAt" datetime
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Skådespelare_Yrkesnivå_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Positor" tinyint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" string
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
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex"
WHERE
    "AC_PLV_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Skådespelare_Yrkesnivå" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Positor" tinyint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" string,
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" tinyint, 
    "AC_PLV_ChangedAt" datetime
)
AS
$$
SELECT
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
    TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå_Annex"(positingTimepoint)) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
AND
    a."AC_PLV_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_PLV_ID"
        ORDER BY a."AC_PLV_PositedAt" DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_PLV_Skådespelare_Yrkesnivå" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Positor" tinyint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" string,
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" tinyint, 
    "AC_PLV_ChangedAt" datetime
)
AS
$$
SELECT
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
    TABLE(attributes."fAC_PLV_Skådespelare_Yrkesnivå_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå_Annex"(positingTimepoint)) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
AND
    a."AC_PLV_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_PLV_ID"
        ORDER BY a."AC_PLV_PositedAt" DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preAC_PLV_Skådespelare_Yrkesnivå" (
    id smallint,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    pre."AC_PLV_PLV_ID"
FROM
    TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå"(positor, changingTimepoint, positingTimepoint)) pre
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
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folAC_PLV_Skådespelare_Yrkesnivå" (
    id smallint,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    fol."AC_PLV_PLV_ID"
FROM
    TABLE(attributes."fAC_PLV_Skådespelare_Yrkesnivå"(positor, changingTimepoint, positingTimepoint)) fol
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_NAM_Föreställning_Namn_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Positor" tinyint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" string
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
    attributes."PR_NAM_Föreställning_Namn_Annex"
WHERE
    "PR_NAM_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_NAM_Föreställning_Namn" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Positor" tinyint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" string,
    "PR_NAM_PR_ID" number(10,0),
    "PR_NAM_Föreställning_Namn" varchar(42)
)
AS
$$
SELECT
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Positor",
    a."PR_NAM_Reliability",
    a."PR_NAM_Assertion",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Föreställning_Namn"
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit" p
JOIN
    TABLE(attributes."rPR_NAM_Föreställning_Namn_Annex"(positingTimepoint)) a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
AND
    a."PR_NAM_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."PR_NAM_ID"
        ORDER BY a."PR_NAM_PositedAt" DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Föreställning_Längd_Posit" (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    "PR_LEN_ID" int,
    "PR_LEN_PR_ID" number(10,0),
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
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fPR_LEN_Föreställning_Längd_Posit" (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    "PR_LEN_ID" int,
    "PR_LEN_PR_ID" number(10,0),
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
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Föreställning_Längd_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_LEN" int,
    "PR_LEN_ID" int,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Positor" tinyint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" string
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
    attributes."PR_LEN_Föreställning_Längd_Annex"
WHERE
    "PR_LEN_PositedAt" <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Föreställning_Längd" (
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_LEN" int,
    "PR_LEN_ID" int,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Positor" tinyint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" string,
    "PR_LEN_PR_ID" number(10,0),
    "PR_LEN_Föreställning_Längd" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Positor",
    a."PR_LEN_Reliability",
    a."PR_LEN_Assertion",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Föreställning_Längd",
    p."PR_LEN_ChangedAt"
FROM
    TABLE(attributes."rPR_LEN_Föreställning_Längd_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rPR_LEN_Föreställning_Längd_Annex"(positingTimepoint)) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
AND
    a."PR_LEN_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."PR_LEN_ID"
        ORDER BY a."PR_LEN_PositedAt" DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fPR_LEN_Föreställning_Längd" (
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_LEN" int,
    "PR_LEN_ID" int,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Positor" tinyint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" string,
    "PR_LEN_PR_ID" number(10,0),
    "PR_LEN_Föreställning_Längd" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Positor",
    a."PR_LEN_Reliability",
    a."PR_LEN_Assertion",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Föreställning_Längd",
    p."PR_LEN_ChangedAt"
FROM
    TABLE(attributes."fPR_LEN_Föreställning_Längd_Posit"(changingTimepoint)) p
JOIN
    TABLE(attributes."rPR_LEN_Föreställning_Längd_Annex"(positingTimepoint)) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
AND
    a."PR_LEN_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."PR_LEN_ID"
        ORDER BY a."PR_LEN_PositedAt" DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."prePR_LEN_Föreställning_Längd" (
    id number(10,0),
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS time
AS
$$
SELECT
    pre."PR_LEN_Föreställning_Längd"
FROM
    TABLE(attributes."rPR_LEN_Föreställning_Längd"(positor, changingTimepoint, positingTimepoint)) pre
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
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folPR_LEN_Föreställning_Längd" (
    id number(10,0),
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS time
AS
$$
SELECT
    fol."PR_LEN_Föreställning_Längd"
FROM
    TABLE(attributes."fPR_LEN_Föreställning_Längd"(positor, changingTimepoint, positingTimepoint)) fol
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
$$
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
CREATE SEQUENCE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Posit" (
    "AC_partner_AC_with_ONG_currently_ID" int default ties."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ".nextval not null, 
    "AC_ID_partner" smallint not null, 
    "AC_ID_with" smallint not null, 
    "ONG_ID_currently" tinyint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime not null,
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_with" foreign key (
        "AC_ID_with"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references knots."ONG_Pågående"("ONG_ID") RELY,
    constraint "AC_partner_AC_with_ONG_currently_Posit_uqAC_partner" unique (
        "AC_ID_partner",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ) RELY,
    constraint "AC_partner_AC_with_ONG_currently_Posit_uqAC_with" unique (
        "AC_ID_with",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ) RELY,
    constraint "pkAC_partner_AC_with_ONG_currently_Posit" primary key (
        "AC_partner_AC_with_ONG_currently_ID"
    ) RELY,
    constraint "uqAC_partner_AC_with_ONG_currently" unique (
        "AC_partner_AC_with_ONG_currently_ChangedAt",
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently"
    ) RELY
) CLUSTER BY (
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Annex" (
    "AC_partner_AC_with_ONG_currently_ID" int not null,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime not null,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint not null,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2) not null,
    "AC_partner_AC_with_ONG_currently_Assertion" string default (
        case
            when "AC_partner_AC_with_ONG_currently_Reliability" > 0 then '+'
            when "AC_partner_AC_with_ONG_currently_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_AC_partner_AC_with_ONG_currently" int not null,
    constraint "fkAC_partner_AC_with_ONG_currently_Annex" foreign key (
        "AC_partner_AC_with_ONG_currently_ID"
    ) references ties."AC_partner_AC_with_ONG_currently_Posit"("AC_partner_AC_with_ONG_currently_ID") RELY,
    constraint "pkAC_partner_AC_with_ONG_currently_Annex" primary key (
        "AC_partner_AC_with_ONG_currently_ID",
        "AC_partner_AC_with_ONG_currently_Positor",
        "AC_partner_AC_with_ONG_currently_PositedAt"
    ) RELY
) CLUSTER BY ("AC_partner_AC_with_ONG_currently_ID", "AC_partner_AC_with_ONG_currently_Positor", "AC_partner_AC_with_ONG_currently_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."AC_subset_PN_of_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of_Posit" (
    "AC_subset_PN_of_ID" int default ties."AC_subset_PN_of_Posit_ID_SEQ".nextval not null, 
    "AC_ID_subset" smallint not null, 
    "PN_ID_of" bigint not null, 
    constraint "AC_subset_PN_of_Posit_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_subset_PN_of_Posit_fkPN_of" foreign key (
        "PN_ID_of"
    ) references anchors."PN_Person"("PN_ID") RELY, 
    constraint "AC_subset_PN_of_Posit_uqAC_subset" unique (
        "AC_ID_subset"
    ) RELY,
    constraint "AC_subset_PN_of_Posit_uqPN_of" unique (
        "PN_ID_of"
    ) RELY,
    constraint "pkAC_subset_PN_of_Posit" primary key (
        "AC_subset_PN_of_ID"
    ) RELY,
    constraint "uqAC_subset_PN_of" unique (
        "AC_ID_subset",
        "PN_ID_of"
    ) RELY
) CLUSTER BY (
    "AC_ID_subset",
    "PN_ID_of"
);
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of_Annex" (
    "AC_subset_PN_of_ID" int not null,
    "AC_subset_PN_of_PositedAt" datetime not null,
    "AC_subset_PN_of_Positor" tinyint not null,
    "AC_subset_PN_of_Reliability" decimal(5,2) not null,
    "AC_subset_PN_of_Assertion" string default (
        case
            when "AC_subset_PN_of_Reliability" > 0 then '+'
            when "AC_subset_PN_of_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_AC_subset_PN_of" int not null,
    constraint "fkAC_subset_PN_of_Annex" foreign key (
        "AC_subset_PN_of_ID"
    ) references ties."AC_subset_PN_of_Posit"("AC_subset_PN_of_ID") RELY,
    constraint "pkAC_subset_PN_of_Annex" primary key (
        "AC_subset_PN_of_ID",
        "AC_subset_PN_of_Positor",
        "AC_subset_PN_of_PositedAt"
    ) RELY
) CLUSTER BY ("AC_subset_PN_of_ID", "AC_subset_PN_of_Positor", "AC_subset_PN_of_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."EV_in_AC_rollsattes_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_rollsattes_Posit" (
    "EV_in_AC_rollsattes_ID" int default ties."EV_in_AC_rollsattes_Posit_ID_SEQ".nextval not null, 
    "EV_ID_in" numeric(12,0) not null, 
    "AC_ID_rollsattes" smallint not null, 
    constraint "EV_in_AC_rollsattes_Posit_fkEV_in" foreign key (
        "EV_ID_in"
    ) references nexuses."EV_Händelse"("EV_ID") RELY, 
    constraint "EV_in_AC_rollsattes_Posit_fkAC_rollsattes" foreign key (
        "AC_ID_rollsattes"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "pkEV_in_AC_rollsattes_Posit" primary key (
        "EV_in_AC_rollsattes_ID"
    ) RELY,
    constraint "uqEV_in_AC_rollsattes" unique (
        "EV_ID_in",
        "AC_ID_rollsattes"
    ) RELY
) CLUSTER BY (
    "EV_ID_in",
    "AC_ID_rollsattes"
);
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_rollsattes_Annex" (
    "EV_in_AC_rollsattes_ID" int not null,
    "EV_in_AC_rollsattes_PositedAt" datetime not null,
    "EV_in_AC_rollsattes_Positor" tinyint not null,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2) not null,
    "EV_in_AC_rollsattes_Assertion" string default (
        case
            when "EV_in_AC_rollsattes_Reliability" > 0 then '+'
            when "EV_in_AC_rollsattes_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_EV_in_AC_rollsattes" int not null,
    constraint "fkEV_in_AC_rollsattes_Annex" foreign key (
        "EV_in_AC_rollsattes_ID"
    ) references ties."EV_in_AC_rollsattes_Posit"("EV_in_AC_rollsattes_ID") RELY,
    constraint "pkEV_in_AC_rollsattes_Annex" primary key (
        "EV_in_AC_rollsattes_ID",
        "EV_in_AC_rollsattes_Positor",
        "EV_in_AC_rollsattes_PositedAt"
    ) RELY
) CLUSTER BY ("EV_in_AC_rollsattes_ID", "EV_in_AC_rollsattes_Positor", "EV_in_AC_rollsattes_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick_Posit" (
    "AC_deltar_PR_in_RAT_fick_ID" int default ties."AC_deltar_PR_in_RAT_fick_Posit_ID_SEQ".nextval not null, 
    "AC_ID_deltar" smallint not null, 
    "PR_ID_in" number(10,0) not null, 
    "RAT_ID_fick" tinyint not null,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime not null,
    constraint "AC_deltar_PR_in_RAT_fick_Posit_fkAC_deltar" foreign key (
        "AC_ID_deltar"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_deltar_PR_in_RAT_fick_Posit_fkPR_in" foreign key (
        "PR_ID_in"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "AC_deltar_PR_in_RAT_fick_Posit_fkRAT_fick" foreign key (
        "RAT_ID_fick"
    ) references knots."RAT_Betyg"("RAT_ID") RELY,
    constraint "pkAC_deltar_PR_in_RAT_fick_Posit" primary key (
        "AC_deltar_PR_in_RAT_fick_ID"
    ) RELY,
    constraint "uqAC_deltar_PR_in_RAT_fick" unique (
        "AC_ID_deltar",
        "PR_ID_in",
        "AC_deltar_PR_in_RAT_fick_ChangedAt",
        "RAT_ID_fick"
    ) RELY
) CLUSTER BY (
    "AC_ID_deltar",
    "PR_ID_in",
    "AC_deltar_PR_in_RAT_fick_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick_Annex" (
    "AC_deltar_PR_in_RAT_fick_ID" int not null,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime not null,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint not null,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2) not null,
    "AC_deltar_PR_in_RAT_fick_Assertion" string default (
        case
            when "AC_deltar_PR_in_RAT_fick_Reliability" > 0 then '+'
            when "AC_deltar_PR_in_RAT_fick_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_AC_deltar_PR_in_RAT_fick" int not null,
    constraint "fkAC_deltar_PR_in_RAT_fick_Annex" foreign key (
        "AC_deltar_PR_in_RAT_fick_ID"
    ) references ties."AC_deltar_PR_in_RAT_fick_Posit"("AC_deltar_PR_in_RAT_fick_ID") RELY,
    constraint "pkAC_deltar_PR_in_RAT_fick_Annex" primary key (
        "AC_deltar_PR_in_RAT_fick_ID",
        "AC_deltar_PR_in_RAT_fick_Positor",
        "AC_deltar_PR_in_RAT_fick_PositedAt"
    ) RELY
) CLUSTER BY ("AC_deltar_PR_in_RAT_fick_ID", "AC_deltar_PR_in_RAT_fick_Positor", "AC_deltar_PR_in_RAT_fick_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."ST_at_PR_spelas_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_spelas_Posit" (
    "ST_at_PR_spelas_ID" int default ties."ST_at_PR_spelas_Posit_ID_SEQ".nextval not null, 
    "ST_ID_at" int not null, 
    "PR_ID_spelas" number(10,0) not null, 
    "ST_at_PR_spelas_ChangedAt" datetime not null,
    constraint "ST_at_PR_spelas_Posit_fkST_at" foreign key (
        "ST_ID_at"
    ) references anchors."ST_Scen"("ST_ID") RELY, 
    constraint "ST_at_PR_spelas_Posit_fkPR_spelas" foreign key (
        "PR_ID_spelas"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "pkST_at_PR_spelas_Posit" primary key (
        "ST_at_PR_spelas_ID"
    ) RELY,
    constraint "uqST_at_PR_spelas" unique (
        "ST_ID_at",
        "PR_ID_spelas",
        "ST_at_PR_spelas_ChangedAt"
    ) RELY
) CLUSTER BY (
    "ST_ID_at",
    "PR_ID_spelas",
    "ST_at_PR_spelas_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_spelas_Annex" (
    "ST_at_PR_spelas_ID" int not null,
    "ST_at_PR_spelas_PositedAt" datetime not null,
    "ST_at_PR_spelas_Positor" tinyint not null,
    "ST_at_PR_spelas_Reliability" decimal(5,2) not null,
    "ST_at_PR_spelas_Assertion" string default (
        case
            when "ST_at_PR_spelas_Reliability" > 0 then '+'
            when "ST_at_PR_spelas_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_ST_at_PR_spelas" int not null,
    constraint "fkST_at_PR_spelas_Annex" foreign key (
        "ST_at_PR_spelas_ID"
    ) references ties."ST_at_PR_spelas_Posit"("ST_at_PR_spelas_ID") RELY,
    constraint "pkST_at_PR_spelas_Annex" primary key (
        "ST_at_PR_spelas_ID",
        "ST_at_PR_spelas_Positor",
        "ST_at_PR_spelas_PositedAt"
    ) RELY
) CLUSTER BY ("ST_at_PR_spelas_ID", "ST_at_PR_spelas_Positor", "ST_at_PR_spelas_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har_Posit" (
    "AC_förälder_AC_barn_PAT_har_ID" int default ties."AC_förälder_AC_barn_PAT_har_Posit_ID_SEQ".nextval not null, 
    "AC_ID_förälder" smallint not null, 
    "AC_ID_barn" smallint not null, 
    "PAT_ID_har" tinyint not null,
    constraint "AC_förälder_AC_barn_PAT_har_Posit_fkAC_förälder" foreign key (
        "AC_ID_förälder"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_förälder_AC_barn_PAT_har_Posit_fkAC_barn" foreign key (
        "AC_ID_barn"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_förälder_AC_barn_PAT_har_Posit_fkPAT_har" foreign key (
        "PAT_ID_har"
    ) references knots."PAT_Föräldratyp"("PAT_ID") RELY,
    constraint "pkAC_förälder_AC_barn_PAT_har_Posit" primary key (
        "AC_förälder_AC_barn_PAT_har_ID"
    ) RELY,
    constraint "uqAC_förälder_AC_barn_PAT_har" unique (
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har"
    ) RELY
) CLUSTER BY (
    "AC_ID_förälder",
    "AC_ID_barn",
    "PAT_ID_har"
);
CREATE TABLE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har_Annex" (
    "AC_förälder_AC_barn_PAT_har_ID" int not null,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime not null,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint not null,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2) not null,
    "AC_förälder_AC_barn_PAT_har_Assertion" string default (
        case
            when "AC_förälder_AC_barn_PAT_har_Reliability" > 0 then '+'
            when "AC_förälder_AC_barn_PAT_har_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_AC_förälder_AC_barn_PAT_har" int not null,
    constraint "fkAC_förälder_AC_barn_PAT_har_Annex" foreign key (
        "AC_förälder_AC_barn_PAT_har_ID"
    ) references ties."AC_förälder_AC_barn_PAT_har_Posit"("AC_förälder_AC_barn_PAT_har_ID") RELY,
    constraint "pkAC_förälder_AC_barn_PAT_har_Annex" primary key (
        "AC_förälder_AC_barn_PAT_har_ID",
        "AC_förälder_AC_barn_PAT_har_Positor",
        "AC_förälder_AC_barn_PAT_har_PositedAt"
    ) RELY
) CLUSTER BY ("AC_förälder_AC_barn_PAT_har_ID", "AC_förälder_AC_barn_PAT_har_Positor", "AC_förälder_AC_barn_PAT_har_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of_Posit" (
    "PR_innehåll_ST_plats_EV_of_ID" int default ties."PR_innehåll_ST_plats_EV_of_Posit_ID_SEQ".nextval not null, 
    "PR_ID_innehåll" number(10,0) not null, 
    "ST_ID_plats" int not null, 
    "EV_ID_of" numeric(12,0) not null, 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime not null,
    constraint "PR_innehåll_ST_plats_EV_of_Posit_fkPR_innehåll" foreign key (
        "PR_ID_innehåll"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_Posit_fkST_plats" foreign key (
        "ST_ID_plats"
    ) references anchors."ST_Scen"("ST_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_Posit_fkEV_of" foreign key (
        "EV_ID_of"
    ) references nexuses."EV_Händelse"("EV_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_Posit_uqPR_innehåll" unique (
        "PR_ID_innehåll",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) RELY,
    constraint "PR_innehåll_ST_plats_EV_of_Posit_uqST_plats" unique (
        "ST_ID_plats",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) RELY,
    constraint "pkPR_innehåll_ST_plats_EV_of_Posit" primary key (
        "PR_innehåll_ST_plats_EV_of_ID"
    ) RELY,
    constraint "uqPR_innehåll_ST_plats_EV_of" unique (
        "PR_innehåll_ST_plats_EV_of_ChangedAt",
        "PR_ID_innehåll",
        "ST_ID_plats",
        "EV_ID_of"
    ) RELY
) CLUSTER BY (
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of_Annex" (
    "PR_innehåll_ST_plats_EV_of_ID" int not null,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime not null,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint not null,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2) not null,
    "PR_innehåll_ST_plats_EV_of_Assertion" string default (
        case
            when "PR_innehåll_ST_plats_EV_of_Reliability" > 0 then '+'
            when "PR_innehåll_ST_plats_EV_of_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_PR_innehåll_ST_plats_EV_of" int not null,
    constraint "fkPR_innehåll_ST_plats_EV_of_Annex" foreign key (
        "PR_innehåll_ST_plats_EV_of_ID"
    ) references ties."PR_innehåll_ST_plats_EV_of_Posit"("PR_innehåll_ST_plats_EV_of_ID") RELY,
    constraint "pkPR_innehåll_ST_plats_EV_of_Annex" primary key (
        "PR_innehåll_ST_plats_EV_of_ID",
        "PR_innehåll_ST_plats_EV_of_Positor",
        "PR_innehåll_ST_plats_EV_of_PositedAt"
    ) RELY
) CLUSTER BY ("PR_innehåll_ST_plats_EV_of_ID", "PR_innehåll_ST_plats_EV_of_Positor", "PR_innehåll_ST_plats_EV_of_PositedAt");
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW ties."AC_partner_AC_with_ONG_currently" COPY GRANTS AS
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
    ties."AC_partner_AC_with_ONG_currently_Posit" p
JOIN
    ties."AC_partner_AC_with_ONG_currently_Annex" a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
;
CREATE OR REPLACE VIEW ties."AC_subset_PN_of" COPY GRANTS AS
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
    ties."AC_subset_PN_of_Posit" p
JOIN
    ties."AC_subset_PN_of_Annex" a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
;
CREATE OR REPLACE VIEW ties."EV_in_AC_rollsattes" COPY GRANTS AS
SELECT
    a."Metadata_EV_in_AC_rollsattes",
    p."EV_in_AC_rollsattes_ID",
    p."EV_ID_in",
    p."AC_ID_rollsattes",
    a."EV_in_AC_rollsattes_PositedAt",
    a."EV_in_AC_rollsattes_Positor",
    a."EV_in_AC_rollsattes_Reliability",
    a."EV_in_AC_rollsattes_Assertion"
FROM
    ties."EV_in_AC_rollsattes_Posit" p
JOIN
    ties."EV_in_AC_rollsattes_Annex" a
ON
    a."EV_in_AC_rollsattes_ID" = p."EV_in_AC_rollsattes_ID"
;
CREATE OR REPLACE VIEW ties."AC_deltar_PR_in_RAT_fick" COPY GRANTS AS
SELECT
    a."Metadata_AC_deltar_PR_in_RAT_fick",
    p."AC_deltar_PR_in_RAT_fick_ID",
    p."AC_ID_deltar",
    p."PR_ID_in",
    p."RAT_ID_fick",
    p."AC_deltar_PR_in_RAT_fick_ChangedAt",
    a."AC_deltar_PR_in_RAT_fick_PositedAt",
    a."AC_deltar_PR_in_RAT_fick_Positor",
    a."AC_deltar_PR_in_RAT_fick_Reliability",
    a."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit" p
JOIN
    ties."AC_deltar_PR_in_RAT_fick_Annex" a
ON
    a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
;
CREATE OR REPLACE VIEW ties."ST_at_PR_spelas" COPY GRANTS AS
SELECT
    a."Metadata_ST_at_PR_spelas",
    p."ST_at_PR_spelas_ID",
    p."ST_ID_at",
    p."PR_ID_spelas",
    p."ST_at_PR_spelas_ChangedAt",
    a."ST_at_PR_spelas_PositedAt",
    a."ST_at_PR_spelas_Positor",
    a."ST_at_PR_spelas_Reliability",
    a."ST_at_PR_spelas_Assertion"
FROM
    ties."ST_at_PR_spelas_Posit" p
JOIN
    ties."ST_at_PR_spelas_Annex" a
ON
    a."ST_at_PR_spelas_ID" = p."ST_at_PR_spelas_ID"
;
CREATE OR REPLACE VIEW ties."AC_förälder_AC_barn_PAT_har" COPY GRANTS AS
SELECT
    a."Metadata_AC_förälder_AC_barn_PAT_har",
    p."AC_förälder_AC_barn_PAT_har_ID",
    p."AC_ID_förälder",
    p."AC_ID_barn",
    p."PAT_ID_har",
    a."AC_förälder_AC_barn_PAT_har_PositedAt",
    a."AC_förälder_AC_barn_PAT_har_Positor",
    a."AC_förälder_AC_barn_PAT_har_Reliability",
    a."AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
JOIN
    ties."AC_förälder_AC_barn_PAT_har_Annex" a
ON
    a."AC_förälder_AC_barn_PAT_har_ID" = p."AC_förälder_AC_barn_PAT_har_ID"
;
CREATE OR REPLACE VIEW ties."PR_innehåll_ST_plats_EV_of" COPY GRANTS AS
SELECT
    a."Metadata_PR_innehåll_ST_plats_EV_of",
    p."PR_innehåll_ST_plats_EV_of_ID",
    p."PR_ID_innehåll",
    p."ST_ID_plats",
    p."EV_ID_of",
    p."PR_innehåll_ST_plats_EV_of_ChangedAt",
    a."PR_innehåll_ST_plats_EV_of_PositedAt",
    a."PR_innehåll_ST_plats_EV_of_Positor",
    a."PR_innehåll_ST_plats_EV_of_Reliability",
    a."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit" p
JOIN
    ties."PR_innehåll_ST_plats_EV_of_Annex" a
ON
    a."PR_innehåll_ST_plats_EV_of_ID" = p."PR_innehåll_ST_plats_EV_of_ID"
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection.
--
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" int,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime
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
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_partner_AC_with_ONG_currently_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" int,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime
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
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ID" int,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" string
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
    ties."AC_partner_AC_with_ONG_currently_Annex"
WHERE
    "AC_partner_AC_with_ONG_currently_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ID" int,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" string
)
AS
$$
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
    TABLE(ties."rAC_partner_AC_with_ONG_currently_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rAC_partner_AC_with_ONG_currently_Annex"(positingTimepoint)) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
AND
    a."AC_partner_AC_with_ONG_currently_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_partner_AC_with_ONG_currently_ID"
        ORDER BY a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_partner_AC_with_ONG_currently" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ID" int,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" string
)
AS
$$
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
    TABLE(ties."fAC_partner_AC_with_ONG_currently_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rAC_partner_AC_with_ONG_currently_Annex"(positingTimepoint)) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
AND
    a."AC_partner_AC_with_ONG_currently_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_partner_AC_with_ONG_currently_ID"
        ORDER BY a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_subset_PN_of_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_subset_PN_of_ID" int,
    "AC_subset_PN_of_PositedAt" datetime,
    "AC_subset_PN_of_Positor" tinyint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" string
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
    ties."AC_subset_PN_of_Annex"
WHERE
    "AC_subset_PN_of_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_subset_PN_of" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_subset_PN_of_ID" int,
    "AC_ID_subset" smallint, 
    "PN_ID_of" bigint, 
    "AC_subset_PN_of_PositedAt" datetime,
    "AC_subset_PN_of_Positor" tinyint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" string
)
AS
$$
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
    ties."AC_subset_PN_of_Posit" p
JOIN
    TABLE(ties."rAC_subset_PN_of_Annex"(positingTimepoint)) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
AND
    a."AC_subset_PN_of_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_subset_PN_of_ID"
        ORDER BY a."AC_subset_PN_of_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_subset_PN_of" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_subset_PN_of_ID" int,
    "AC_ID_subset" smallint, 
    "PN_ID_of" bigint, 
    "AC_subset_PN_of_PositedAt" datetime,
    "AC_subset_PN_of_Positor" tinyint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" string
)
AS
$$
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
    ties."AC_subset_PN_of_Posit" p
JOIN
    TABLE(ties."rAC_subset_PN_of_Annex"(positingTimepoint)) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
AND
    a."AC_subset_PN_of_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_subset_PN_of_ID"
        ORDER BY a."AC_subset_PN_of_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rEV_in_AC_rollsattes_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_in_AC_rollsattes_ID" int,
    "EV_in_AC_rollsattes_PositedAt" datetime,
    "EV_in_AC_rollsattes_Positor" tinyint,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_in_AC_rollsattes_Assertion" string
)
AS
$$
SELECT
    "Metadata_EV_in_AC_rollsattes",
    "EV_in_AC_rollsattes_ID",
    "EV_in_AC_rollsattes_PositedAt",
    "EV_in_AC_rollsattes_Positor",
    "EV_in_AC_rollsattes_Reliability",
    "EV_in_AC_rollsattes_Assertion"
FROM
    ties."EV_in_AC_rollsattes_Annex"
WHERE
    "EV_in_AC_rollsattes_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rEV_in_AC_rollsattes" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_in_AC_rollsattes_ID" int,
    "EV_ID_in" numeric(12,0), 
    "AC_ID_rollsattes" smallint, 
    "EV_in_AC_rollsattes_PositedAt" datetime,
    "EV_in_AC_rollsattes_Positor" tinyint,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_in_AC_rollsattes_Assertion" string
)
AS
$$
SELECT
    a."Metadata_EV_in_AC_rollsattes",
    p."EV_in_AC_rollsattes_ID",
    p."EV_ID_in",
    p."AC_ID_rollsattes",
    a."EV_in_AC_rollsattes_PositedAt",
    a."EV_in_AC_rollsattes_Positor",
    a."EV_in_AC_rollsattes_Reliability",
    a."EV_in_AC_rollsattes_Assertion"
FROM
    ties."EV_in_AC_rollsattes_Posit" p
JOIN
    TABLE(ties."rEV_in_AC_rollsattes_Annex"(positingTimepoint)) a
ON
    a."EV_in_AC_rollsattes_ID" = p."EV_in_AC_rollsattes_ID"
AND
    a."EV_in_AC_rollsattes_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_in_AC_rollsattes_ID"
        ORDER BY a."EV_in_AC_rollsattes_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fEV_in_AC_rollsattes" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_in_AC_rollsattes_ID" int,
    "EV_ID_in" numeric(12,0), 
    "AC_ID_rollsattes" smallint, 
    "EV_in_AC_rollsattes_PositedAt" datetime,
    "EV_in_AC_rollsattes_Positor" tinyint,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_in_AC_rollsattes_Assertion" string
)
AS
$$
SELECT
    a."Metadata_EV_in_AC_rollsattes",
    p."EV_in_AC_rollsattes_ID",
    p."EV_ID_in",
    p."AC_ID_rollsattes",
    a."EV_in_AC_rollsattes_PositedAt",
    a."EV_in_AC_rollsattes_Positor",
    a."EV_in_AC_rollsattes_Reliability",
    a."EV_in_AC_rollsattes_Assertion"
FROM
    ties."EV_in_AC_rollsattes_Posit" p
JOIN
    TABLE(ties."rEV_in_AC_rollsattes_Annex"(positingTimepoint)) a
ON
    a."EV_in_AC_rollsattes_ID" = p."EV_in_AC_rollsattes_ID"
AND
    a."EV_in_AC_rollsattes_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_in_AC_rollsattes_ID"
        ORDER BY a."EV_in_AC_rollsattes_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_deltar_PR_in_RAT_fick_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" number(10,0), 
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime
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
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_deltar_PR_in_RAT_fick_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" number(10,0), 
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime
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
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_deltar_PR_in_RAT_fick_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    "Metadata_AC_deltar_PR_in_RAT_fick",
    "AC_deltar_PR_in_RAT_fick_ID",
    "AC_deltar_PR_in_RAT_fick_PositedAt",
    "AC_deltar_PR_in_RAT_fick_Positor",
    "AC_deltar_PR_in_RAT_fick_Reliability",
    "AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    ties."AC_deltar_PR_in_RAT_fick_Annex"
WHERE
    "AC_deltar_PR_in_RAT_fick_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_deltar_PR_in_RAT_fick" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" number(10,0), 
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    a."Metadata_AC_deltar_PR_in_RAT_fick",
    p."AC_deltar_PR_in_RAT_fick_ID",
    p."AC_ID_deltar",
    p."PR_ID_in",
    p."RAT_ID_fick",
    p."AC_deltar_PR_in_RAT_fick_ChangedAt",
    a."AC_deltar_PR_in_RAT_fick_PositedAt",
    a."AC_deltar_PR_in_RAT_fick_Positor",
    a."AC_deltar_PR_in_RAT_fick_Reliability",
    a."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    TABLE(ties."rAC_deltar_PR_in_RAT_fick_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rAC_deltar_PR_in_RAT_fick_Annex"(positingTimepoint)) a
ON
    a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
AND
    a."AC_deltar_PR_in_RAT_fick_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_deltar_PR_in_RAT_fick_ID"
        ORDER BY a."AC_deltar_PR_in_RAT_fick_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_deltar_PR_in_RAT_fick" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" number(10,0), 
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    a."Metadata_AC_deltar_PR_in_RAT_fick",
    p."AC_deltar_PR_in_RAT_fick_ID",
    p."AC_ID_deltar",
    p."PR_ID_in",
    p."RAT_ID_fick",
    p."AC_deltar_PR_in_RAT_fick_ChangedAt",
    a."AC_deltar_PR_in_RAT_fick_PositedAt",
    a."AC_deltar_PR_in_RAT_fick_Positor",
    a."AC_deltar_PR_in_RAT_fick_Reliability",
    a."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    TABLE(ties."fAC_deltar_PR_in_RAT_fick_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rAC_deltar_PR_in_RAT_fick_Annex"(positingTimepoint)) a
ON
    a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
AND
    a."AC_deltar_PR_in_RAT_fick_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_deltar_PR_in_RAT_fick_ID"
        ORDER BY a."AC_deltar_PR_in_RAT_fick_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_spelas_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_at_PR_spelas_ID" int,
    "ST_ID_at" int, 
    "PR_ID_spelas" number(10,0), 
    "ST_at_PR_spelas_ChangedAt" datetime
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
$$
;
CREATE OR REPLACE FUNCTION ties."fST_at_PR_spelas_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_at_PR_spelas_ID" int,
    "ST_ID_at" int, 
    "PR_ID_spelas" number(10,0), 
    "ST_at_PR_spelas_ChangedAt" datetime
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
$$
;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_spelas_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ID" int,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    "Metadata_ST_at_PR_spelas",
    "ST_at_PR_spelas_ID",
    "ST_at_PR_spelas_PositedAt",
    "ST_at_PR_spelas_Positor",
    "ST_at_PR_spelas_Reliability",
    "ST_at_PR_spelas_Assertion"
FROM
    ties."ST_at_PR_spelas_Annex"
WHERE
    "ST_at_PR_spelas_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_spelas" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ID" int,
    "ST_ID_at" int, 
    "PR_ID_spelas" number(10,0), 
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    a."Metadata_ST_at_PR_spelas",
    p."ST_at_PR_spelas_ID",
    p."ST_ID_at",
    p."PR_ID_spelas",
    p."ST_at_PR_spelas_ChangedAt",
    a."ST_at_PR_spelas_PositedAt",
    a."ST_at_PR_spelas_Positor",
    a."ST_at_PR_spelas_Reliability",
    a."ST_at_PR_spelas_Assertion"
FROM
    TABLE(ties."rST_at_PR_spelas_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rST_at_PR_spelas_Annex"(positingTimepoint)) a
ON
    a."ST_at_PR_spelas_ID" = p."ST_at_PR_spelas_ID"
AND
    a."ST_at_PR_spelas_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."ST_at_PR_spelas_ID"
        ORDER BY a."ST_at_PR_spelas_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fST_at_PR_spelas" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ID" int,
    "ST_ID_at" int, 
    "PR_ID_spelas" number(10,0), 
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    a."Metadata_ST_at_PR_spelas",
    p."ST_at_PR_spelas_ID",
    p."ST_ID_at",
    p."PR_ID_spelas",
    p."ST_at_PR_spelas_ChangedAt",
    a."ST_at_PR_spelas_PositedAt",
    a."ST_at_PR_spelas_Positor",
    a."ST_at_PR_spelas_Reliability",
    a."ST_at_PR_spelas_Assertion"
FROM
    TABLE(ties."fST_at_PR_spelas_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rST_at_PR_spelas_Annex"(positingTimepoint)) a
ON
    a."ST_at_PR_spelas_ID" = p."ST_at_PR_spelas_ID"
AND
    a."ST_at_PR_spelas_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."ST_at_PR_spelas_ID"
        ORDER BY a."ST_at_PR_spelas_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_förälder_AC_barn_PAT_har_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_förälder_AC_barn_PAT_har_ID" int,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_förälder_AC_barn_PAT_har_Assertion" string
)
AS
$$
SELECT
    "Metadata_AC_förälder_AC_barn_PAT_har",
    "AC_förälder_AC_barn_PAT_har_ID",
    "AC_förälder_AC_barn_PAT_har_PositedAt",
    "AC_förälder_AC_barn_PAT_har_Positor",
    "AC_förälder_AC_barn_PAT_har_Reliability",
    "AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Annex"
WHERE
    "AC_förälder_AC_barn_PAT_har_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_förälder_AC_barn_PAT_har" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_förälder_AC_barn_PAT_har_ID" int,
    "AC_ID_förälder" smallint, 
    "AC_ID_barn" smallint, 
    "PAT_ID_har" tinyint,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_förälder_AC_barn_PAT_har_Assertion" string
)
AS
$$
SELECT
    a."Metadata_AC_förälder_AC_barn_PAT_har",
    p."AC_förälder_AC_barn_PAT_har_ID",
    p."AC_ID_förälder",
    p."AC_ID_barn",
    p."PAT_ID_har",
    a."AC_förälder_AC_barn_PAT_har_PositedAt",
    a."AC_förälder_AC_barn_PAT_har_Positor",
    a."AC_förälder_AC_barn_PAT_har_Reliability",
    a."AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
JOIN
    TABLE(ties."rAC_förälder_AC_barn_PAT_har_Annex"(positingTimepoint)) a
ON
    a."AC_förälder_AC_barn_PAT_har_ID" = p."AC_förälder_AC_barn_PAT_har_ID"
AND
    a."AC_förälder_AC_barn_PAT_har_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_förälder_AC_barn_PAT_har_ID"
        ORDER BY a."AC_förälder_AC_barn_PAT_har_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_förälder_AC_barn_PAT_har" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_förälder_AC_barn_PAT_har_ID" int,
    "AC_ID_förälder" smallint, 
    "AC_ID_barn" smallint, 
    "PAT_ID_har" tinyint,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_förälder_AC_barn_PAT_har_Assertion" string
)
AS
$$
SELECT
    a."Metadata_AC_förälder_AC_barn_PAT_har",
    p."AC_förälder_AC_barn_PAT_har_ID",
    p."AC_ID_förälder",
    p."AC_ID_barn",
    p."PAT_ID_har",
    a."AC_förälder_AC_barn_PAT_har_PositedAt",
    a."AC_förälder_AC_barn_PAT_har_Positor",
    a."AC_förälder_AC_barn_PAT_har_Reliability",
    a."AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
JOIN
    TABLE(ties."rAC_förälder_AC_barn_PAT_har_Annex"(positingTimepoint)) a
ON
    a."AC_förälder_AC_barn_PAT_har_ID" = p."AC_förälder_AC_barn_PAT_har_ID"
AND
    a."AC_förälder_AC_barn_PAT_har_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_förälder_AC_barn_PAT_har_ID"
        ORDER BY a."AC_förälder_AC_barn_PAT_har_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rPR_innehåll_ST_plats_EV_of_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "PR_ID_innehåll" number(10,0), 
    "ST_ID_plats" int, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime
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
$$
;
CREATE OR REPLACE FUNCTION ties."fPR_innehåll_ST_plats_EV_of_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "PR_ID_innehåll" number(10,0), 
    "ST_ID_plats" int, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime
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
$$
;
CREATE OR REPLACE FUNCTION ties."rPR_innehåll_ST_plats_EV_of_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    "Metadata_PR_innehåll_ST_plats_EV_of",
    "PR_innehåll_ST_plats_EV_of_ID",
    "PR_innehåll_ST_plats_EV_of_PositedAt",
    "PR_innehåll_ST_plats_EV_of_Positor",
    "PR_innehåll_ST_plats_EV_of_Reliability",
    "PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    ties."PR_innehåll_ST_plats_EV_of_Annex"
WHERE
    "PR_innehåll_ST_plats_EV_of_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rPR_innehåll_ST_plats_EV_of" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "PR_ID_innehåll" number(10,0), 
    "ST_ID_plats" int, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    a."Metadata_PR_innehåll_ST_plats_EV_of",
    p."PR_innehåll_ST_plats_EV_of_ID",
    p."PR_ID_innehåll",
    p."ST_ID_plats",
    p."EV_ID_of",
    p."PR_innehåll_ST_plats_EV_of_ChangedAt",
    a."PR_innehåll_ST_plats_EV_of_PositedAt",
    a."PR_innehåll_ST_plats_EV_of_Positor",
    a."PR_innehåll_ST_plats_EV_of_Reliability",
    a."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    TABLE(ties."rPR_innehåll_ST_plats_EV_of_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rPR_innehåll_ST_plats_EV_of_Annex"(positingTimepoint)) a
ON
    a."PR_innehåll_ST_plats_EV_of_ID" = p."PR_innehåll_ST_plats_EV_of_ID"
AND
    a."PR_innehåll_ST_plats_EV_of_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."PR_innehåll_ST_plats_EV_of_ID"
        ORDER BY a."PR_innehåll_ST_plats_EV_of_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fPR_innehåll_ST_plats_EV_of" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "PR_ID_innehåll" number(10,0), 
    "ST_ID_plats" int, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    a."Metadata_PR_innehåll_ST_plats_EV_of",
    p."PR_innehåll_ST_plats_EV_of_ID",
    p."PR_ID_innehåll",
    p."ST_ID_plats",
    p."EV_ID_of",
    p."PR_innehåll_ST_plats_EV_of_ChangedAt",
    a."PR_innehåll_ST_plats_EV_of_PositedAt",
    a."PR_innehåll_ST_plats_EV_of_Positor",
    a."PR_innehåll_ST_plats_EV_of_Reliability",
    a."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    TABLE(ties."fPR_innehåll_ST_plats_EV_of_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rPR_innehåll_ST_plats_EV_of_Annex"(positingTimepoint)) a
ON
    a."PR_innehåll_ST_plats_EV_of_ID" = p."PR_innehåll_ST_plats_EV_of_ID"
AND
    a."PR_innehåll_ST_plats_EV_of_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."PR_innehåll_ST_plats_EV_of_ID"
        ORDER BY a."PR_innehåll_ST_plats_EV_of_PositedAt" DESC
    ) = 1
$$
;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."tST_Scen" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Positor" tinyint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" string,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Positor" tinyint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" string,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Positor" tinyint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" string,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Positor" tinyint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" string,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
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
    "NAM"."ST_NAM_Scen_Namn",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Positor",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Assertion",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Scen_Plats",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Positor",
    "AVG"."ST_AVG_Reliability",
    "AVG"."ST_AVG_Assertion",
    "kAVG"."UTL_Utnyttjande" AS "ST_AVG_UTL_Utnyttjande",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Positor",
    "MIN"."ST_MIN_Reliability",
    "MIN"."ST_MIN_Assertion",
    "kMIN"."UTL_Utnyttjande" AS "ST_MIN_UTL_Utnyttjande",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Scen" "ST"
LEFT JOIN
    TABLE(attributes."rST_NAM_Scen_Namn"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "NAM"
ON
    "NAM"."ST_NAM_ID" = (
        SELECT
            sub."ST_NAM_ID"
        FROM
            TABLE(attributes."rST_NAM_Scen_Namn"(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_NAM_Assertion" = coalesce(assertion, sub."ST_NAM_Assertion")
        ORDER BY
            sub."ST_NAM_ChangedAt" DESC,
            sub."ST_NAM_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rST_LOC_Scen_Plats"(
        positor,
        positingTimepoint::datetime
    )) "LOC"
ON
    "LOC"."ST_LOC_ID" = (
        SELECT
            sub."ST_LOC_ID"
        FROM
            TABLE(attributes."rST_LOC_Scen_Plats"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_LOC_ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_LOC_Assertion" = coalesce(assertion, sub."ST_LOC_Assertion")
        ORDER BY
            sub."ST_LOC_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rST_AVG_Scen_Medel"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "AVG"
ON
    "AVG"."ST_AVG_ID" = (
        SELECT
            sub."ST_AVG_ID"
        FROM
            TABLE(attributes."rST_AVG_Scen_Medel"(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_AVG_Assertion" = coalesce(assertion, sub."ST_AVG_Assertion")
        ORDER BY
            sub."ST_AVG_ChangedAt" DESC,
            sub."ST_AVG_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    knots."UTL_Utnyttjande" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    TABLE(attributes."rST_MIN_Scen_Minimum"(
        positor,
        positingTimepoint::datetime
    )) "MIN"
ON
    "MIN"."ST_MIN_ID" = (
        SELECT
            sub."ST_MIN_ID"
        FROM
            TABLE(attributes."rST_MIN_Scen_Minimum"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_MIN_ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_MIN_Assertion" = coalesce(assertion, sub."ST_MIN_Assertion")
        ORDER BY
            sub."ST_MIN_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    knots."UTL_Utnyttjande" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lST_Scen" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tST_Scen"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "ST"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pST_Scen" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Positor" tinyint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" string,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Positor" tinyint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" string,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Positor" tinyint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" string,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Positor" tinyint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" string,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
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
    "ST"."ST_NAM_Scen_Namn",
    "ST"."ST_LOC_ST_ID",
    "ST"."Metadata_ST_LOC",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Positor",
    "ST"."ST_LOC_Reliability",
    "ST"."ST_LOC_Assertion",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Scen_Plats",
    "ST"."ST_AVG_ST_ID",
    "ST"."Metadata_ST_AVG",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Positor",
    "ST"."ST_AVG_Reliability",
    "ST"."ST_AVG_Assertion",
    "ST"."ST_AVG_UTL_Utnyttjande",
    "ST"."ST_AVG_Metadata_UTL",
    "ST"."ST_AVG_UTL_ID",
    "ST"."ST_MIN_ST_ID",
    "ST"."Metadata_ST_MIN",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Positor",
    "ST"."ST_MIN_Reliability",
    "ST"."ST_MIN_Assertion",
    "ST"."ST_MIN_UTL_Utnyttjande",
    "ST"."ST_MIN_Metadata_UTL",
    "ST"."ST_MIN_UTL_ID"
FROM
    dw."_Positor" p,
    TABLE(anchors."tST_Scen"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "ST"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nST_Scen" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tST_Scen"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "ST"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dST_Scen" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Positor" tinyint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" string,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Positor" tinyint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" string,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Positor" tinyint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" string,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Positor" tinyint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" string,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
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
    "ST"."ST_NAM_Scen_Namn",
    "ST"."ST_LOC_ST_ID",
    "ST"."Metadata_ST_LOC",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Positor",
    "ST"."ST_LOC_Reliability",
    "ST"."ST_LOC_Assertion",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Scen_Plats",
    "ST"."ST_AVG_ST_ID",
    "ST"."Metadata_ST_AVG",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Positor",
    "ST"."ST_AVG_Reliability",
    "ST"."ST_AVG_Assertion",
    "ST"."ST_AVG_UTL_Utnyttjande",
    "ST"."ST_AVG_Metadata_UTL",
    "ST"."ST_AVG_UTL_ID",
    "ST"."ST_MIN_ST_ID",
    "ST"."Metadata_ST_MIN",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Positor",
    "ST"."ST_MIN_Reliability",
    "ST"."ST_MIN_Assertion",
    "ST"."ST_MIN_UTL_Utnyttjande",
    "ST"."ST_MIN_Metadata_UTL",
    "ST"."ST_MIN_UTL_ID"
FROM
    dw."_Positor" p
JOIN
(
    SELECT DISTINCT
        "ST_NAM_Positor" AS positor,
        "ST_NAM_ST_ID" AS "ST_ID",
        "ST_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."ST_NAM_Scen_Namn"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "ST_AVG_Positor" AS positor,
        "ST_AVG_ST_ID" AS "ST_ID",
        "ST_AVG_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes."ST_AVG_Scen_Medel"
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        "ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor",
    TABLE(anchors."tST_Scen"(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "ST"
WHERE
    "ST"."ST_ID" = timepoints."ST_ID"
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."tAC_Skådespelare" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Positor" tinyint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" string,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Positor" tinyint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" string,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Positor" tinyint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" string,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
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
    "NAM"."AC_NAM_Skådespelare_Namn",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Positor",
    "GEN"."AC_GEN_Reliability",
    "GEN"."AC_GEN_Assertion",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Kön" AS "AC_GEN_GEN_Kön",
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
    "kPLV"."PLV_Yrkesnivå" AS "AC_PLV_PLV_Yrkesnivå",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Skådespelare" "AC"
LEFT JOIN
    TABLE(attributes."rAC_NAM_Skådespelare_Namn"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "NAM"
ON
    "NAM"."AC_NAM_ID" = (
        SELECT
            sub."AC_NAM_ID"
        FROM
            TABLE(attributes."rAC_NAM_Skådespelare_Namn"(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
        AND
            sub."AC_NAM_Assertion" = coalesce(assertion, sub."AC_NAM_Assertion")
        ORDER BY
            sub."AC_NAM_ChangedAt" DESC,
            sub."AC_NAM_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rAC_GEN_Skådespelare_Kön"(
        positor,
        positingTimepoint::datetime
    )) "GEN"
ON
    "GEN"."AC_GEN_ID" = (
        SELECT
            sub."AC_GEN_ID"
        FROM
            TABLE(attributes."rAC_GEN_Skådespelare_Kön"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_GEN_AC_ID" = "AC"."AC_ID"
        AND
            sub."AC_GEN_Assertion" = coalesce(assertion, sub."AC_GEN_Assertion")
        ORDER BY
            sub."AC_GEN_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "PLV"
ON
    "PLV"."AC_PLV_ID" = (
        SELECT
            sub."AC_PLV_ID"
        FROM
            TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå"(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
        AND
            sub."AC_PLV_Assertion" = coalesce(assertion, sub."AC_PLV_Assertion")
        ORDER BY
            sub."AC_PLV_ChangedAt" DESC,
            sub."AC_PLV_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    knots."PLV_Yrkesnivå" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lAC_Skådespelare" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tAC_Skådespelare"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "AC"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pAC_Skådespelare" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Positor" tinyint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" string,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Positor" tinyint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" string,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Positor" tinyint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" string,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
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
    "AC"."AC_NAM_Skådespelare_Namn",
    "AC"."AC_GEN_AC_ID",
    "AC"."Metadata_AC_GEN",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Positor",
    "AC"."AC_GEN_Reliability",
    "AC"."AC_GEN_Assertion",
    "AC"."AC_GEN_GEN_Checksum",
    "AC"."AC_GEN_GEN_Kön",
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
    "AC"."AC_PLV_PLV_Yrkesnivå",
    "AC"."AC_PLV_Metadata_PLV",
    "AC"."AC_PLV_PLV_ID"
FROM
    dw."_Positor" p,
    TABLE(anchors."tAC_Skådespelare"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "AC"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nAC_Skådespelare" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tAC_Skådespelare"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "AC"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dAC_Skådespelare" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Positor" tinyint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" string,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Positor" tinyint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" string,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Positor" tinyint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" string,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
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
    "AC"."AC_NAM_Skådespelare_Namn",
    "AC"."AC_GEN_AC_ID",
    "AC"."Metadata_AC_GEN",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Positor",
    "AC"."AC_GEN_Reliability",
    "AC"."AC_GEN_Assertion",
    "AC"."AC_GEN_GEN_Checksum",
    "AC"."AC_GEN_GEN_Kön",
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
    "AC"."AC_PLV_PLV_Yrkesnivå",
    "AC"."AC_PLV_Metadata_PLV",
    "AC"."AC_PLV_PLV_ID"
FROM
    dw."_Positor" p
JOIN
(
    SELECT DISTINCT
        "AC_NAM_Positor" AS positor,
        "AC_NAM_AC_ID" AS "AC_ID",
        "AC_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Skådespelare_Namn"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "AC_PLV_Positor" AS positor,
        "AC_PLV_AC_ID" AS "AC_ID",
        "AC_PLV_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå"
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        "AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor",
    TABLE(anchors."tAC_Skådespelare"(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "AC"
WHERE
    "AC"."AC_ID" = timepoints."AC_ID"
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."tPR_Föreställning" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Positor" tinyint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" string,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Positor" tinyint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" string,
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
    "NAM"."PR_NAM_Positor",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Assertion",
    "NAM"."PR_NAM_Föreställning_Namn",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Positor",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Assertion",
    "LEN"."PR_LEN_Föreställning_Längd"
FROM
    anchors."PR_Föreställning" "PR"
LEFT JOIN
    TABLE(attributes."rPR_NAM_Föreställning_Namn"(
        positor,
        positingTimepoint::datetime
    )) "NAM"
ON
    "NAM"."PR_NAM_ID" = (
        SELECT
            sub."PR_NAM_ID"
        FROM
            TABLE(attributes."rPR_NAM_Föreställning_Namn"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."PR_NAM_PR_ID" = "PR"."PR_ID"
        AND
            sub."PR_NAM_Assertion" = coalesce(assertion, sub."PR_NAM_Assertion")
        ORDER BY
            sub."PR_NAM_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rPR_LEN_Föreställning_Längd"(
        positor,
        changingTimepoint::date,
        positingTimepoint::datetime
    )) "LEN"
ON
    "LEN"."PR_LEN_ID" = (
        SELECT
            sub."PR_LEN_ID"
        FROM
            TABLE(attributes."rPR_LEN_Föreställning_Längd"(
                positor,
                changingTimepoint::date,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
        AND
            sub."PR_LEN_Assertion" = coalesce(assertion, sub."PR_LEN_Assertion")
        ORDER BY
            sub."PR_LEN_ChangedAt" DESC,
            sub."PR_LEN_PositedAt" DESC
        LIMIT 1
    )
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lPR_Föreställning" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tPR_Föreställning"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "PR"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pPR_Föreställning" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Positor" tinyint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" string,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Positor" tinyint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" string,
    "PR_LEN_Föreställning_Längd" time
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
    "PR"."PR_NAM_Föreställning_Namn",
    "PR"."PR_LEN_PR_ID",
    "PR"."Metadata_PR_LEN",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Positor",
    "PR"."PR_LEN_Reliability",
    "PR"."PR_LEN_Assertion",
    "PR"."PR_LEN_Föreställning_Längd"
FROM
    dw."_Positor" p,
    TABLE(anchors."tPR_Föreställning"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "PR"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nPR_Föreställning" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tPR_Föreställning"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "PR"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dPR_Föreställning" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Positor" tinyint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" string,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Positor" tinyint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" string,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "PR"."PR_NAM_PR_ID",
    "PR"."Metadata_PR_NAM",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Positor",
    "PR"."PR_NAM_Reliability",
    "PR"."PR_NAM_Assertion",
    "PR"."PR_NAM_Föreställning_Namn",
    "PR"."PR_LEN_PR_ID",
    "PR"."Metadata_PR_LEN",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Positor",
    "PR"."PR_LEN_Reliability",
    "PR"."PR_LEN_Assertion",
    "PR"."PR_LEN_Föreställning_Längd"
FROM
    dw."_Positor" p
JOIN
(
    SELECT DISTINCT
        "PR_LEN_Positor" AS positor,
        "PR_LEN_PR_ID" AS "PR_ID",
        "PR_LEN_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes."PR_LEN_Föreställning_Längd"
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        "PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor",
    TABLE(anchors."tPR_Föreställning"(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "PR"
WHERE
    "PR"."PR_ID" = timepoints."PR_ID"
$$
;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."tEV_Händelse" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_hölls" int,
    "PR_ID_spelades" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_Händelsetyp" varchar(42),
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_ID" int,
    "EV_DAT_PositedAt" datetime,
    "EV_DAT_Positor" tinyint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" string,
    "EV_DAT_Händelse_Datum" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_ID" int,
    "EV_AUD_PositedAt" datetime,
    "EV_AUD_Positor" tinyint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" string,
    "EV_AUD_Händelse_Publik" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_ID" int,
    "EV_REV_PositedAt" datetime,
    "EV_REV_Positor" tinyint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" string,
    "EV_REV_Händelse_Intäkt" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ID" int,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_PositedAt" datetime,
    "EV_STA_Positor" tinyint,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Assertion" string,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_ID" int,
    "EV_UTL_PositedAt" datetime,
    "EV_UTL_Positor" tinyint,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_Assertion" string,
    "EV_UTL_UTL_Utnyttjande" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ID" int,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" datetime,
    "EV_LVL_Positor" tinyint,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_Assertion" string,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_Yrkesnivå" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
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
    "DAT"."EV_DAT_Positor",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Assertion",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Positor",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Assertion",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Positor",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Assertion",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Positor",
    "STA"."EV_STA_Reliability",
    "STA"."EV_STA_Assertion",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Positor",
    "UTL"."EV_UTL_Reliability",
    "UTL"."EV_UTL_Assertion",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Positor",
    "LVL"."EV_LVL_Reliability",
    "LVL"."EV_LVL_Assertion",
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
LEFT JOIN
    TABLE(attributes."rEV_DAT_Händelse_Datum"(
        positor,
        positingTimepoint::datetime
    )) "DAT"
ON
    "DAT"."EV_DAT_ID" = (
        SELECT
            sub."EV_DAT_ID"
        FROM
            TABLE(attributes."rEV_DAT_Händelse_Datum"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."EV_DAT_EV_ID" = "EV"."EV_ID"
        AND
            sub."EV_DAT_Assertion" = coalesce(assertion, sub."EV_DAT_Assertion")
        ORDER BY
            sub."EV_DAT_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rEV_AUD_Händelse_Publik"(
        positor,
        positingTimepoint::datetime
    )) "AUD"
ON
    "AUD"."EV_AUD_ID" = (
        SELECT
            sub."EV_AUD_ID"
        FROM
            TABLE(attributes."rEV_AUD_Händelse_Publik"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."EV_AUD_EV_ID" = "EV"."EV_ID"
        AND
            sub."EV_AUD_Assertion" = coalesce(assertion, sub."EV_AUD_Assertion")
        ORDER BY
            sub."EV_AUD_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rEV_REV_Händelse_Intäkt"(
        positor,
        positingTimepoint::datetime
    )) "REV"
ON
    "REV"."EV_REV_ID" = (
        SELECT
            sub."EV_REV_ID"
        FROM
            TABLE(attributes."rEV_REV_Händelse_Intäkt"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."EV_REV_EV_ID" = "EV"."EV_ID"
        AND
            sub."EV_REV_Assertion" = coalesce(assertion, sub."EV_REV_Assertion")
        ORDER BY
            sub."EV_REV_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rEV_STA_Händelse_Status"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "STA"
ON
    "STA"."EV_STA_ID" = (
        SELECT
            sub."EV_STA_ID"
        FROM
            TABLE(attributes."rEV_STA_Händelse_Status"(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
        AND
            sub."EV_STA_Assertion" = coalesce(assertion, sub."EV_STA_Assertion")
        ORDER BY
            sub."EV_STA_ChangedAt" DESC,
            sub."EV_STA_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rEV_UTL_Händelse_Utnyttjande"(
        positor,
        positingTimepoint::datetime
    )) "UTL"
ON
    "UTL"."EV_UTL_ID" = (
        SELECT
            sub."EV_UTL_ID"
        FROM
            TABLE(attributes."rEV_UTL_Händelse_Utnyttjande"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."EV_UTL_EV_ID" = "EV"."EV_ID"
        AND
            sub."EV_UTL_Assertion" = coalesce(assertion, sub."EV_UTL_Assertion")
        ORDER BY
            sub."EV_UTL_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    TABLE(attributes."rEV_LVL_Händelse_Level"(
        positor,
        changingTimepoint::date,
        positingTimepoint::datetime
    )) "LVL"
ON
    "LVL"."EV_LVL_ID" = (
        SELECT
            sub."EV_LVL_ID"
        FROM
            TABLE(attributes."rEV_LVL_Händelse_Level"(
                positor,
                changingTimepoint::date,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
        AND
            sub."EV_LVL_Assertion" = coalesce(assertion, sub."EV_LVL_Assertion")
        ORDER BY
            sub."EV_LVL_ChangedAt" DESC,
            sub."EV_LVL_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    knots."PLV_Yrkesnivå" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."lEV_Händelse" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV".*
FROM
    dw."_Positor" p,
    TABLE(nexuses."tEV_Händelse"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "EV"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."pEV_Händelse" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_hölls" int,
    "PR_ID_spelades" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_Händelsetyp" varchar(42),
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_ID" int,
    "EV_DAT_PositedAt" datetime,
    "EV_DAT_Positor" tinyint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" string,
    "EV_DAT_Händelse_Datum" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_ID" int,
    "EV_AUD_PositedAt" datetime,
    "EV_AUD_Positor" tinyint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" string,
    "EV_AUD_Händelse_Publik" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_ID" int,
    "EV_REV_PositedAt" datetime,
    "EV_REV_Positor" tinyint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" string,
    "EV_REV_Händelse_Intäkt" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ID" int,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_PositedAt" datetime,
    "EV_STA_Positor" tinyint,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Assertion" string,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_ID" int,
    "EV_UTL_PositedAt" datetime,
    "EV_UTL_Positor" tinyint,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_Assertion" string,
    "EV_UTL_UTL_Utnyttjande" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ID" int,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" datetime,
    "EV_LVL_Positor" tinyint,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_Assertion" string,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_Yrkesnivå" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
    "EV"."EV_DAT_Positor",
    "EV"."EV_DAT_Reliability",
    "EV"."EV_DAT_Assertion",
    "EV"."EV_DAT_Händelse_Datum",
    "EV"."EV_AUD_EV_ID",
    "EV"."Metadata_EV_AUD",
    "EV"."EV_AUD_ID",
    "EV"."EV_AUD_PositedAt",
    "EV"."EV_AUD_Positor",
    "EV"."EV_AUD_Reliability",
    "EV"."EV_AUD_Assertion",
    "EV"."EV_AUD_Händelse_Publik",
    "EV"."EV_REV_EV_ID",
    "EV"."Metadata_EV_REV",
    "EV"."EV_REV_ID",
    "EV"."EV_REV_PositedAt",
    "EV"."EV_REV_Positor",
    "EV"."EV_REV_Reliability",
    "EV"."EV_REV_Assertion",
    "EV"."EV_REV_Händelse_Intäkt",
    "EV"."EV_STA_EV_ID",
    "EV"."Metadata_EV_STA",
    "EV"."EV_STA_ID",
    "EV"."EV_STA_ChangedAt",
    "EV"."EV_STA_PositedAt",
    "EV"."EV_STA_Positor",
    "EV"."EV_STA_Reliability",
    "EV"."EV_STA_Assertion",
    "EV"."EV_STA_Händelse_Status",
    "EV"."EV_UTL_EV_ID",
    "EV"."Metadata_EV_UTL",
    "EV"."EV_UTL_ID",
    "EV"."EV_UTL_PositedAt",
    "EV"."EV_UTL_Positor",
    "EV"."EV_UTL_Reliability",
    "EV"."EV_UTL_Assertion",
    "EV"."EV_UTL_UTL_Utnyttjande",
    "EV"."EV_UTL_Metadata_UTL",
    "EV"."EV_UTL_UTL_ID",
    "EV"."EV_LVL_EV_ID",
    "EV"."Metadata_EV_LVL",
    "EV"."EV_LVL_ID",
    "EV"."EV_LVL_ChangedAt",
    "EV"."EV_LVL_PositedAt",
    "EV"."EV_LVL_Positor",
    "EV"."EV_LVL_Reliability",
    "EV"."EV_LVL_Assertion",
    "EV"."EV_LVL_PLV_Checksum",
    "EV"."EV_LVL_PLV_Yrkesnivå",
    "EV"."EV_LVL_Metadata_PLV",
    "EV"."EV_LVL_PLV_ID"
FROM
    dw."_Positor" p,
    TABLE(nexuses."tEV_Händelse"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "EV"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."nEV_Händelse" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV".*
FROM
    dw."_Positor" p,
    TABLE(nexuses."tEV_Händelse"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "EV"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."dEV_Händelse" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_hölls" int,
    "PR_ID_spelades" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_Händelsetyp" varchar(42),
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_ID" int,
    "EV_DAT_PositedAt" datetime,
    "EV_DAT_Positor" tinyint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" string,
    "EV_DAT_Händelse_Datum" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_ID" int,
    "EV_AUD_PositedAt" datetime,
    "EV_AUD_Positor" tinyint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" string,
    "EV_AUD_Händelse_Publik" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_ID" int,
    "EV_REV_PositedAt" datetime,
    "EV_REV_Positor" tinyint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" string,
    "EV_REV_Händelse_Intäkt" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ID" int,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_PositedAt" datetime,
    "EV_STA_Positor" tinyint,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Assertion" string,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_ID" int,
    "EV_UTL_PositedAt" datetime,
    "EV_UTL_Positor" tinyint,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_Assertion" string,
    "EV_UTL_UTL_Utnyttjande" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ID" int,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" datetime,
    "EV_LVL_Positor" tinyint,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_Assertion" string,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_Yrkesnivå" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT
    p."Positor",
    tp.inspectedTimepoint,
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
    "EV"."EV_DAT_Positor",
    "EV"."EV_DAT_Reliability",
    "EV"."EV_DAT_Assertion",
    "EV"."EV_DAT_Händelse_Datum",
    "EV"."EV_AUD_EV_ID",
    "EV"."Metadata_EV_AUD",
    "EV"."EV_AUD_ID",
    "EV"."EV_AUD_PositedAt",
    "EV"."EV_AUD_Positor",
    "EV"."EV_AUD_Reliability",
    "EV"."EV_AUD_Assertion",
    "EV"."EV_AUD_Händelse_Publik",
    "EV"."EV_REV_EV_ID",
    "EV"."Metadata_EV_REV",
    "EV"."EV_REV_ID",
    "EV"."EV_REV_PositedAt",
    "EV"."EV_REV_Positor",
    "EV"."EV_REV_Reliability",
    "EV"."EV_REV_Assertion",
    "EV"."EV_REV_Händelse_Intäkt",
    "EV"."EV_STA_EV_ID",
    "EV"."Metadata_EV_STA",
    "EV"."EV_STA_ID",
    "EV"."EV_STA_ChangedAt",
    "EV"."EV_STA_PositedAt",
    "EV"."EV_STA_Positor",
    "EV"."EV_STA_Reliability",
    "EV"."EV_STA_Assertion",
    "EV"."EV_STA_Händelse_Status",
    "EV"."EV_UTL_EV_ID",
    "EV"."Metadata_EV_UTL",
    "EV"."EV_UTL_ID",
    "EV"."EV_UTL_PositedAt",
    "EV"."EV_UTL_Positor",
    "EV"."EV_UTL_Reliability",
    "EV"."EV_UTL_Assertion",
    "EV"."EV_UTL_UTL_Utnyttjande",
    "EV"."EV_UTL_Metadata_UTL",
    "EV"."EV_UTL_UTL_ID",
    "EV"."EV_LVL_EV_ID",
    "EV"."Metadata_EV_LVL",
    "EV"."EV_LVL_ID",
    "EV"."EV_LVL_ChangedAt",
    "EV"."EV_LVL_PositedAt",
    "EV"."EV_LVL_Positor",
    "EV"."EV_LVL_Reliability",
    "EV"."EV_LVL_Assertion",
    "EV"."EV_LVL_PLV_Checksum",
    "EV"."EV_LVL_PLV_Yrkesnivå",
    "EV"."EV_LVL_Metadata_PLV",
    "EV"."EV_LVL_PLV_ID"
FROM
    dw."_Positor" p
JOIN (
    SELECT DISTINCT
        "EV_STA_Positor" AS positor,
        "EV_STA_EV_ID" AS "EV_ID",
        "EV_STA_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."EV_STA_Händelse_Status"
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        "EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "EV_LVL_Positor" AS positor,
        "EV_LVL_EV_ID" AS "EV_ID",
        "EV_LVL_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes."EV_LVL_Händelse_Level"
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        "EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor",
    TABLE(nexuses."tEV_Händelse"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "EV"
WHERE
    "EV"."EV_ID" = tp."EV_ID"
$$
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tAC_partner_AC_with_ONG_currently" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" string
)
AS
$$
SELECT
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    TABLE(ties."rAC_partner_AC_with_ONG_currently"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots."ONG_Pågående" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."AC_partner_AC_with_ONG_currently_Assertion" = coalesce(assertion, t."AC_partner_AC_with_ONG_currently_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Pågående",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Pågående",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    dw."_Positor" p
JOIN (
    SELECT DISTINCT
        "AC_partner_AC_with_ONG_currently_Positor" AS positor,
        "AC_partner_AC_with_ONG_currently_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties."AC_partner_AC_with_ONG_currently"
    WHERE
        "AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor",
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tAC_subset_PN_of" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint,
    "AC_subset_PN_of_PositedAt" datetime,
    "AC_subset_PN_of_Positor" tinyint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" string
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
FROM
    TABLE(ties."rAC_subset_PN_of"(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t."AC_subset_PN_of_Assertion" = coalesce(assertion, t."AC_subset_PN_of_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_subset_PN_of"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_subset_PN_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint,
    "AC_subset_PN_of_PositedAt" datetime,
    "AC_subset_PN_of_Positor" tinyint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" string
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
    dw."_Positor" p,
    TABLE(ties."tAC_subset_PN_of"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_subset_PN_of"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tEV_in_AC_rollsattes" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint,
    "EV_in_AC_rollsattes_PositedAt" datetime,
    "EV_in_AC_rollsattes_Positor" tinyint,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_in_AC_rollsattes_Assertion" string
)
AS
$$
SELECT
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_ID_in",
    t."AC_ID_rollsattes",
    t."EV_in_AC_rollsattes_PositedAt",
    t."EV_in_AC_rollsattes_Positor",
    t."EV_in_AC_rollsattes_Reliability",
    t."EV_in_AC_rollsattes_Assertion"
FROM
    TABLE(ties."rEV_in_AC_rollsattes"(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t."EV_in_AC_rollsattes_Assertion" = coalesce(assertion, t."EV_in_AC_rollsattes_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tEV_in_AC_rollsattes"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_rollsattes" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint,
    "EV_in_AC_rollsattes_PositedAt" datetime,
    "EV_in_AC_rollsattes_Positor" tinyint,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_in_AC_rollsattes_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_ID_in",
    t."AC_ID_rollsattes",
    t."EV_in_AC_rollsattes_PositedAt",
    t."EV_in_AC_rollsattes_Positor",
    t."EV_in_AC_rollsattes_Reliability",
    t."EV_in_AC_rollsattes_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tEV_in_AC_rollsattes"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tEV_in_AC_rollsattes"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tAC_deltar_PR_in_RAT_fick" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_ID_deltar",
    t."PR_ID_in",
    "kRAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "kRAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "kRAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    t."RAT_ID_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Positor",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    TABLE(ties."rAC_deltar_PR_in_RAT_fick"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots."RAT_Betyg" "kRAT_fick"
ON
    "kRAT_fick"."RAT_ID" = t."RAT_ID_fick"
WHERE
    t."AC_deltar_PR_in_RAT_fick_Assertion" = coalesce(assertion, t."AC_deltar_PR_in_RAT_fick_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_ID_deltar",
    t."PR_ID_in",
    t."fick_RAT_Checksum",
    t."fick_RAT_Betyg",
    t."fick_Metadata_RAT",
    t."RAT_ID_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Positor",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_deltar_PR_in_RAT_fick" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_ID_deltar",
    t."PR_ID_in",
    t."fick_RAT_Checksum",
    t."fick_RAT_Betyg",
    t."fick_Metadata_RAT",
    t."RAT_ID_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Positor",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    dw."_Positor" p
JOIN (
    SELECT DISTINCT
        "AC_deltar_PR_in_RAT_fick_Positor" AS positor,
        "AC_deltar_PR_in_RAT_fick_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties."AC_deltar_PR_in_RAT_fick"
    WHERE
        "AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor",
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tST_at_PR_spelas" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0),
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    t."Metadata_ST_at_PR_spelas",
    t."ST_ID_at",
    t."PR_ID_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Positor",
    t."ST_at_PR_spelas_Reliability",
    t."ST_at_PR_spelas_Assertion"
FROM
    TABLE(ties."rST_at_PR_spelas"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t."ST_at_PR_spelas_Assertion" = coalesce(assertion, t."ST_at_PR_spelas_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tST_at_PR_spelas"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pST_at_PR_spelas" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_ST_at_PR_spelas" int,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0),
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_ST_at_PR_spelas",
    t."ST_ID_at",
    t."PR_ID_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Positor",
    t."ST_at_PR_spelas_Reliability",
    t."ST_at_PR_spelas_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tST_at_PR_spelas"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tST_at_PR_spelas"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dST_at_PR_spelas" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "Metadata_ST_at_PR_spelas" int,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0),
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_ST_at_PR_spelas",
    t."ST_ID_at",
    t."PR_ID_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Positor",
    t."ST_at_PR_spelas_Reliability",
    t."ST_at_PR_spelas_Assertion"
FROM
    dw."_Positor" p
JOIN (
    SELECT DISTINCT
        "ST_at_PR_spelas_Positor" AS positor,
        "ST_at_PR_spelas_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties."ST_at_PR_spelas"
    WHERE
        "ST_at_PR_spelas_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor",
    TABLE(ties."tST_at_PR_spelas"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tAC_förälder_AC_barn_PAT_har" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_förälder_AC_barn_PAT_har_Assertion" string
)
AS
$$
SELECT
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    "kPAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "kPAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    t."PAT_ID_har",
    t."AC_förälder_AC_barn_PAT_har_PositedAt",
    t."AC_förälder_AC_barn_PAT_har_Positor",
    t."AC_förälder_AC_barn_PAT_har_Reliability",
    t."AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    TABLE(ties."rAC_förälder_AC_barn_PAT_har"(
        positor,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
WHERE
    t."AC_förälder_AC_barn_PAT_har_Assertion" = coalesce(assertion, t."AC_förälder_AC_barn_PAT_har_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_förälder_AC_barn_PAT_har"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_förälder_AC_barn_PAT_har_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    t."har_PAT_Föräldratyp",
    t."har_Metadata_PAT",
    t."PAT_ID_har",
    t."AC_förälder_AC_barn_PAT_har_PositedAt",
    t."AC_förälder_AC_barn_PAT_har_Positor",
    t."AC_förälder_AC_barn_PAT_har_Reliability",
    t."AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_förälder_AC_barn_PAT_har"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_förälder_AC_barn_PAT_har"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tPR_innehåll_ST_plats_EV_of" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0),
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Positor",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    TABLE(ties."rPR_innehåll_ST_plats_EV_of"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t."PR_innehåll_ST_plats_EV_of_Assertion" = coalesce(assertion, t."PR_innehåll_ST_plats_EV_of_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0),
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Positor",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dPR_innehåll_ST_plats_EV_of" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0),
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Positor",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    dw."_Positor" p
JOIN (
    SELECT DISTINCT
        "PR_innehåll_ST_plats_EV_of_Positor" AS positor,
        "PR_innehåll_ST_plats_EV_of_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties."PR_innehåll_ST_plats_EV_of"
    WHERE
        "PR_innehåll_ST_plats_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor",
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- Snowflake does not enforce primary, unique or foreign keys, and every key here is declared RELY, which tells the
-- optimizer to trust it. A violation is therefore not an error, but wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--
-- In a concurrent reliance temporal model an attribute and a tie are a posit table and an annex table, each with a view. What is not
-- checked is restatement and whether the time of a posit overlaps another: the uni-temporal checks do not carry over.
--
-- A view that returns nothing has nothing wrong. IntegrityViolations is all of them together; it reads every table.
--
--   Construct     the table
--   Violation     what is wrong
--   ViolationKey  the key of the rows, as an object of column and value
--   Occurrences   how many rows
--
-- The orphan checks join to the table that is referred to and look for the rows without a match. They use a
-- column of the referred table in the WHERE clause, so a RELY foreign key cannot make the optimizer drop the join.
--
-- PAT_Föräldratyp integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_PAT_Föräldratyp" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PAT_Föräldratyp',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PAT_ID', "PAT_ID"),
    COUNT(*)
FROM
    knots."PAT_Föräldratyp"
GROUP BY
    "PAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_Föräldratyp',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PAT_Föräldratyp', "PAT_Föräldratyp"),
    COUNT(*)
FROM
    knots."PAT_Föräldratyp"
GROUP BY
    "PAT_Föräldratyp"
HAVING
    COUNT(*) > 1;
-- GEN_Kön integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_GEN_Kön" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'GEN_Kön',
    'duplicate primary key',
    OBJECT_CONSTRUCT('GEN_ID', "GEN_ID"),
    COUNT(*)
FROM
    knots."GEN_Kön"
GROUP BY
    "GEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Kön',
    'duplicate unique key',
    OBJECT_CONSTRUCT('GEN_Checksum', "GEN_Checksum"),
    COUNT(*)
FROM
    knots."GEN_Kön"
GROUP BY
    "GEN_Checksum"
HAVING
    COUNT(*) > 1;
-- PLV_Yrkesnivå integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_PLV_Yrkesnivå" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PLV_Yrkesnivå',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PLV_ID', "PLV_ID"),
    COUNT(*)
FROM
    knots."PLV_Yrkesnivå"
GROUP BY
    "PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PLV_Yrkesnivå',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PLV_Checksum', "PLV_Checksum"),
    COUNT(*)
FROM
    knots."PLV_Yrkesnivå"
GROUP BY
    "PLV_Checksum"
HAVING
    COUNT(*) > 1;
-- UTL_Utnyttjande integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_UTL_Utnyttjande" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'UTL_Utnyttjande',
    'duplicate primary key',
    OBJECT_CONSTRUCT('UTL_ID', "UTL_ID"),
    COUNT(*)
FROM
    knots."UTL_Utnyttjande"
GROUP BY
    "UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'UTL_Utnyttjande',
    'duplicate unique key',
    OBJECT_CONSTRUCT('UTL_Utnyttjande', "UTL_Utnyttjande"),
    COUNT(*)
FROM
    knots."UTL_Utnyttjande"
GROUP BY
    "UTL_Utnyttjande"
HAVING
    COUNT(*) > 1;
-- ONG_Pågående integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_ONG_Pågående" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ONG_Pågående',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ONG_ID', "ONG_ID"),
    COUNT(*)
FROM
    knots."ONG_Pågående"
GROUP BY
    "ONG_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Pågående',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ONG_Pågående', "ONG_Pågående"),
    COUNT(*)
FROM
    knots."ONG_Pågående"
GROUP BY
    "ONG_Pågående"
HAVING
    COUNT(*) > 1;
-- RAT_Betyg integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_RAT_Betyg" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'RAT_Betyg',
    'duplicate primary key',
    OBJECT_CONSTRUCT('RAT_ID', "RAT_ID"),
    COUNT(*)
FROM
    knots."RAT_Betyg"
GROUP BY
    "RAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Betyg',
    'duplicate unique key',
    OBJECT_CONSTRUCT('RAT_Checksum', "RAT_Checksum"),
    COUNT(*)
FROM
    knots."RAT_Betyg"
GROUP BY
    "RAT_Checksum"
HAVING
    COUNT(*) > 1;
-- ETY_Händelsetyp integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_ETY_Händelsetyp" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ETY_Händelsetyp',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ETY_ID', "ETY_ID"),
    COUNT(*)
FROM
    knots."ETY_Händelsetyp"
GROUP BY
    "ETY_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_Händelsetyp',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ETY_Checksum', "ETY_Checksum"),
    COUNT(*)
FROM
    knots."ETY_Händelsetyp"
GROUP BY
    "ETY_Checksum"
HAVING
    COUNT(*) > 1;
-- PN_Person integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_PN_Person" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PN_Person',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PN_ID', "PN_ID"),
    COUNT(*)
FROM
    anchors."PN_Person"
GROUP BY
    "PN_ID"
HAVING
    COUNT(*) > 1;
-- ST_Scen integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_ST_Scen" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_Scen',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_ID', "ST_ID"),
    COUNT(*)
FROM
    anchors."ST_Scen"
GROUP BY
    "ST_ID"
HAVING
    COUNT(*) > 1;
-- AC_Skådespelare integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_AC_Skådespelare" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_Skådespelare',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_ID', "AC_ID"),
    COUNT(*)
FROM
    anchors."AC_Skådespelare"
GROUP BY
    "AC_ID"
HAVING
    COUNT(*) > 1;
-- PR_Föreställning integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_PR_Föreställning" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_Föreställning',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_ID', "PR_ID"),
    COUNT(*)
FROM
    anchors."PR_Föreställning"
GROUP BY
    "PR_ID"
HAVING
    COUNT(*) > 1;
-- EV_Händelse integrity -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."ic_EV_Händelse" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_Händelse',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_ID', "EV_ID"),
    COUNT(*)
FROM
    nexuses."EV_Händelse"
GROUP BY
    "EV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_Händelse',
    'no row in ST_Scen for ST_ID_hölls',
    OBJECT_CONSTRUCT('ST_ID_hölls', c."ST_ID_hölls"),
    COUNT(*)
FROM
    nexuses."EV_Händelse" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_ID_hölls"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_hölls"
UNION ALL
SELECT
    'EV_Händelse',
    'no row in PR_Föreställning for PR_ID_spelades',
    OBJECT_CONSTRUCT('PR_ID_spelades', c."PR_ID_spelades"),
    COUNT(*)
FROM
    nexuses."EV_Händelse" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_spelades"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_spelades"
UNION ALL
SELECT
    'EV_Händelse',
    'no row in ETY_Händelsetyp for ETY_ID_of',
    OBJECT_CONSTRUCT('ETY_ID_of', c."ETY_ID_of"),
    COUNT(*)
FROM
    nexuses."EV_Händelse" c
LEFT JOIN
    knots."ETY_Händelsetyp" p
ON
    p."ETY_ID" = c."ETY_ID_of"
WHERE
    p."ETY_ID" IS NULL
GROUP BY
    c."ETY_ID_of"
;
-- EV_DAT_Händelse_Datum_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_DAT_Händelse_Datum_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Händelse_Datum_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_DAT_ID', "EV_DAT_ID"),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum_Posit"
GROUP BY
    "EV_DAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Händelse_Datum_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_DAT_EV_ID', "EV_DAT_EV_ID",
        'EV_DAT_Händelse_Datum', "EV_DAT_Händelse_Datum"
    ),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum_Posit"
GROUP BY
    "EV_DAT_EV_ID",
    "EV_DAT_Händelse_Datum"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Händelse_Datum_Posit',
    'no row in EV_Händelse for EV_DAT_EV_ID',
    OBJECT_CONSTRUCT('EV_DAT_EV_ID', c."EV_DAT_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_DAT_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_DAT_EV_ID"
;
-- EV_DAT_Händelse_Datum_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_DAT_Händelse_Datum_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Händelse_Datum_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_DAT_ID', "EV_DAT_ID",
        'EV_DAT_Positor', "EV_DAT_Positor",
        'EV_DAT_PositedAt', "EV_DAT_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum_Annex"
GROUP BY
    "EV_DAT_ID",
    "EV_DAT_Positor",
    "EV_DAT_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Händelse_Datum_Annex',
    'no row in EV_DAT_Händelse_Datum_Posit for EV_DAT_ID',
    OBJECT_CONSTRUCT('EV_DAT_ID', c."EV_DAT_ID"),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum_Annex" c
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum_Posit" p
ON
    p."EV_DAT_ID" = c."EV_DAT_ID"
WHERE
    p."EV_DAT_ID" IS NULL
GROUP BY
    c."EV_DAT_ID"
;
-- EV_AUD_Händelse_Publik_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_AUD_Händelse_Publik_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Händelse_Publik_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_AUD_ID', "EV_AUD_ID"),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik_Posit"
GROUP BY
    "EV_AUD_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Händelse_Publik_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_AUD_EV_ID', "EV_AUD_EV_ID",
        'EV_AUD_Händelse_Publik', "EV_AUD_Händelse_Publik"
    ),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik_Posit"
GROUP BY
    "EV_AUD_EV_ID",
    "EV_AUD_Händelse_Publik"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Händelse_Publik_Posit',
    'no row in EV_Händelse for EV_AUD_EV_ID',
    OBJECT_CONSTRUCT('EV_AUD_EV_ID', c."EV_AUD_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_AUD_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_AUD_EV_ID"
;
-- EV_AUD_Händelse_Publik_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_AUD_Händelse_Publik_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Händelse_Publik_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_AUD_ID', "EV_AUD_ID",
        'EV_AUD_Positor', "EV_AUD_Positor",
        'EV_AUD_PositedAt', "EV_AUD_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik_Annex"
GROUP BY
    "EV_AUD_ID",
    "EV_AUD_Positor",
    "EV_AUD_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Händelse_Publik_Annex',
    'no row in EV_AUD_Händelse_Publik_Posit for EV_AUD_ID',
    OBJECT_CONSTRUCT('EV_AUD_ID', c."EV_AUD_ID"),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik_Annex" c
LEFT JOIN
    attributes."EV_AUD_Händelse_Publik_Posit" p
ON
    p."EV_AUD_ID" = c."EV_AUD_ID"
WHERE
    p."EV_AUD_ID" IS NULL
GROUP BY
    c."EV_AUD_ID"
;
-- EV_REV_Händelse_Intäkt_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_REV_Händelse_Intäkt_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Händelse_Intäkt_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_REV_ID', "EV_REV_ID"),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit"
GROUP BY
    "EV_REV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Händelse_Intäkt_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_REV_EV_ID', "EV_REV_EV_ID",
        'EV_REV_Händelse_Intäkt', "EV_REV_Händelse_Intäkt"
    ),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit"
GROUP BY
    "EV_REV_EV_ID",
    "EV_REV_Händelse_Intäkt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Händelse_Intäkt_Posit',
    'no row in EV_Händelse for EV_REV_EV_ID',
    OBJECT_CONSTRUCT('EV_REV_EV_ID', c."EV_REV_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_REV_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_REV_EV_ID"
;
-- EV_REV_Händelse_Intäkt_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_REV_Händelse_Intäkt_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Händelse_Intäkt_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_REV_ID', "EV_REV_ID",
        'EV_REV_Positor', "EV_REV_Positor",
        'EV_REV_PositedAt', "EV_REV_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt_Annex"
GROUP BY
    "EV_REV_ID",
    "EV_REV_Positor",
    "EV_REV_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Händelse_Intäkt_Annex',
    'no row in EV_REV_Händelse_Intäkt_Posit for EV_REV_ID',
    OBJECT_CONSTRUCT('EV_REV_ID', c."EV_REV_ID"),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt_Annex" c
LEFT JOIN
    attributes."EV_REV_Händelse_Intäkt_Posit" p
ON
    p."EV_REV_ID" = c."EV_REV_ID"
WHERE
    p."EV_REV_ID" IS NULL
GROUP BY
    c."EV_REV_ID"
;
-- EV_STA_Händelse_Status_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_STA_Händelse_Status_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_STA_Händelse_Status_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_STA_ID', "EV_STA_ID"),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status_Posit"
GROUP BY
    "EV_STA_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Händelse_Status_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_STA_EV_ID', "EV_STA_EV_ID",
        'EV_STA_ChangedAt', "EV_STA_ChangedAt",
        'EV_STA_Händelse_Status', "EV_STA_Händelse_Status"
    ),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status_Posit"
GROUP BY
    "EV_STA_EV_ID",
    "EV_STA_ChangedAt",
    "EV_STA_Händelse_Status"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Händelse_Status_Posit',
    'no row in EV_Händelse for EV_STA_EV_ID',
    OBJECT_CONSTRUCT('EV_STA_EV_ID', c."EV_STA_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_STA_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_STA_EV_ID"
;
-- EV_STA_Händelse_Status_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_STA_Händelse_Status_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_STA_Händelse_Status_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_STA_ID', "EV_STA_ID",
        'EV_STA_Positor', "EV_STA_Positor",
        'EV_STA_PositedAt', "EV_STA_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status_Annex"
GROUP BY
    "EV_STA_ID",
    "EV_STA_Positor",
    "EV_STA_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Händelse_Status_Annex',
    'no row in EV_STA_Händelse_Status_Posit for EV_STA_ID',
    OBJECT_CONSTRUCT('EV_STA_ID', c."EV_STA_ID"),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status_Annex" c
LEFT JOIN
    attributes."EV_STA_Händelse_Status_Posit" p
ON
    p."EV_STA_ID" = c."EV_STA_ID"
WHERE
    p."EV_STA_ID" IS NULL
GROUP BY
    c."EV_STA_ID"
;
-- EV_UTL_Händelse_Utnyttjande_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_UTL_Händelse_Utnyttjande_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_UTL_Händelse_Utnyttjande_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_UTL_ID', "EV_UTL_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit"
GROUP BY
    "EV_UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_UTL_EV_ID', "EV_UTL_EV_ID",
        'EV_UTL_UTL_ID', "EV_UTL_UTL_ID"
    ),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit"
GROUP BY
    "EV_UTL_EV_ID",
    "EV_UTL_UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande_Posit',
    'no row in EV_Händelse for EV_UTL_EV_ID',
    OBJECT_CONSTRUCT('EV_UTL_EV_ID', c."EV_UTL_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_UTL_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_UTL_EV_ID"
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande_Posit',
    'no row in UTL_Utnyttjande for EV_UTL_UTL_ID',
    OBJECT_CONSTRUCT('EV_UTL_UTL_ID', c."EV_UTL_UTL_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" c
LEFT JOIN
    knots."UTL_Utnyttjande" p
ON
    p."UTL_ID" = c."EV_UTL_UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."EV_UTL_UTL_ID"
;
-- EV_UTL_Händelse_Utnyttjande_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_UTL_Händelse_Utnyttjande_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_UTL_Händelse_Utnyttjande_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_UTL_ID', "EV_UTL_ID",
        'EV_UTL_Positor', "EV_UTL_Positor",
        'EV_UTL_PositedAt', "EV_UTL_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Annex"
GROUP BY
    "EV_UTL_ID",
    "EV_UTL_Positor",
    "EV_UTL_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande_Annex',
    'no row in EV_UTL_Händelse_Utnyttjande_Posit for EV_UTL_ID',
    OBJECT_CONSTRUCT('EV_UTL_ID', c."EV_UTL_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Annex" c
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
ON
    p."EV_UTL_ID" = c."EV_UTL_ID"
WHERE
    p."EV_UTL_ID" IS NULL
GROUP BY
    c."EV_UTL_ID"
;
-- EV_LVL_Händelse_Level_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_LVL_Händelse_Level_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_LVL_Händelse_Level_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_LVL_ID', "EV_LVL_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Posit"
GROUP BY
    "EV_LVL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Händelse_Level_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_LVL_EV_ID', "EV_LVL_EV_ID",
        'EV_LVL_ChangedAt', "EV_LVL_ChangedAt",
        'EV_LVL_PLV_ID', "EV_LVL_PLV_ID"
    ),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Posit"
GROUP BY
    "EV_LVL_EV_ID",
    "EV_LVL_ChangedAt",
    "EV_LVL_PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Händelse_Level_Posit',
    'no row in EV_Händelse for EV_LVL_EV_ID',
    OBJECT_CONSTRUCT('EV_LVL_EV_ID', c."EV_LVL_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_LVL_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_LVL_EV_ID"
UNION ALL
SELECT
    'EV_LVL_Händelse_Level_Posit',
    'no row in PLV_Yrkesnivå for EV_LVL_PLV_ID',
    OBJECT_CONSTRUCT('EV_LVL_PLV_ID', c."EV_LVL_PLV_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Posit" c
LEFT JOIN
    knots."PLV_Yrkesnivå" p
ON
    p."PLV_ID" = c."EV_LVL_PLV_ID"
WHERE
    p."PLV_ID" IS NULL
GROUP BY
    c."EV_LVL_PLV_ID"
;
-- EV_LVL_Händelse_Level_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_LVL_Händelse_Level_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_LVL_Händelse_Level_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_LVL_ID', "EV_LVL_ID",
        'EV_LVL_Positor', "EV_LVL_Positor",
        'EV_LVL_PositedAt', "EV_LVL_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Annex"
GROUP BY
    "EV_LVL_ID",
    "EV_LVL_Positor",
    "EV_LVL_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Händelse_Level_Annex',
    'no row in EV_LVL_Händelse_Level_Posit for EV_LVL_ID',
    OBJECT_CONSTRUCT('EV_LVL_ID', c."EV_LVL_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Annex" c
LEFT JOIN
    attributes."EV_LVL_Händelse_Level_Posit" p
ON
    p."EV_LVL_ID" = c."EV_LVL_ID"
WHERE
    p."EV_LVL_ID" IS NULL
GROUP BY
    c."EV_LVL_ID"
;
-- ST_NAM_Scen_Namn_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_NAM_Scen_Namn_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Scen_Namn_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_NAM_ID', "ST_NAM_ID"),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn_Posit"
GROUP BY
    "ST_NAM_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Scen_Namn_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_NAM_ST_ID', "ST_NAM_ST_ID",
        'ST_NAM_ChangedAt', "ST_NAM_ChangedAt",
        'ST_NAM_Scen_Namn', "ST_NAM_Scen_Namn"
    ),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn_Posit"
GROUP BY
    "ST_NAM_ST_ID",
    "ST_NAM_ChangedAt",
    "ST_NAM_Scen_Namn"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Scen_Namn_Posit',
    'no row in ST_Scen for ST_NAM_ST_ID',
    OBJECT_CONSTRUCT('ST_NAM_ST_ID', c."ST_NAM_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_NAM_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_NAM_ST_ID"
;
-- ST_NAM_Scen_Namn_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_NAM_Scen_Namn_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Scen_Namn_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_NAM_ID', "ST_NAM_ID",
        'ST_NAM_Positor', "ST_NAM_Positor",
        'ST_NAM_PositedAt', "ST_NAM_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn_Annex"
GROUP BY
    "ST_NAM_ID",
    "ST_NAM_Positor",
    "ST_NAM_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Scen_Namn_Annex',
    'no row in ST_NAM_Scen_Namn_Posit for ST_NAM_ID',
    OBJECT_CONSTRUCT('ST_NAM_ID', c."ST_NAM_ID"),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn_Annex" c
LEFT JOIN
    attributes."ST_NAM_Scen_Namn_Posit" p
ON
    p."ST_NAM_ID" = c."ST_NAM_ID"
WHERE
    p."ST_NAM_ID" IS NULL
GROUP BY
    c."ST_NAM_ID"
;
-- ST_LOC_Scen_Plats_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_LOC_Scen_Plats_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Scen_Plats_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_LOC_ID', "ST_LOC_ID"),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats_Posit"
GROUP BY
    "ST_LOC_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Scen_Plats_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_LOC_ST_ID', "ST_LOC_ST_ID",
        'ST_LOC_Checksum', "ST_LOC_Checksum"
    ),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats_Posit"
GROUP BY
    "ST_LOC_ST_ID",
    "ST_LOC_Checksum"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Scen_Plats_Posit',
    'no row in ST_Scen for ST_LOC_ST_ID',
    OBJECT_CONSTRUCT('ST_LOC_ST_ID', c."ST_LOC_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_LOC_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_LOC_ST_ID"
;
-- ST_LOC_Scen_Plats_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_LOC_Scen_Plats_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Scen_Plats_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_LOC_ID', "ST_LOC_ID",
        'ST_LOC_Positor', "ST_LOC_Positor",
        'ST_LOC_PositedAt', "ST_LOC_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats_Annex"
GROUP BY
    "ST_LOC_ID",
    "ST_LOC_Positor",
    "ST_LOC_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Scen_Plats_Annex',
    'no row in ST_LOC_Scen_Plats_Posit for ST_LOC_ID',
    OBJECT_CONSTRUCT('ST_LOC_ID', c."ST_LOC_ID"),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats_Annex" c
LEFT JOIN
    attributes."ST_LOC_Scen_Plats_Posit" p
ON
    p."ST_LOC_ID" = c."ST_LOC_ID"
WHERE
    p."ST_LOC_ID" IS NULL
GROUP BY
    c."ST_LOC_ID"
;
-- ST_AVG_Scen_Medel_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_AVG_Scen_Medel_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Scen_Medel_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_AVG_ID', "ST_AVG_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Posit"
GROUP BY
    "ST_AVG_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Scen_Medel_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_AVG_ST_ID', "ST_AVG_ST_ID",
        'ST_AVG_ChangedAt', "ST_AVG_ChangedAt",
        'ST_AVG_UTL_ID', "ST_AVG_UTL_ID"
    ),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Posit"
GROUP BY
    "ST_AVG_ST_ID",
    "ST_AVG_ChangedAt",
    "ST_AVG_UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Scen_Medel_Posit',
    'no row in ST_Scen for ST_AVG_ST_ID',
    OBJECT_CONSTRUCT('ST_AVG_ST_ID', c."ST_AVG_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_AVG_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_AVG_ST_ID"
UNION ALL
SELECT
    'ST_AVG_Scen_Medel_Posit',
    'no row in UTL_Utnyttjande for ST_AVG_UTL_ID',
    OBJECT_CONSTRUCT('ST_AVG_UTL_ID', c."ST_AVG_UTL_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Posit" c
LEFT JOIN
    knots."UTL_Utnyttjande" p
ON
    p."UTL_ID" = c."ST_AVG_UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."ST_AVG_UTL_ID"
;
-- ST_AVG_Scen_Medel_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_AVG_Scen_Medel_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Scen_Medel_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_AVG_ID', "ST_AVG_ID",
        'ST_AVG_Positor', "ST_AVG_Positor",
        'ST_AVG_PositedAt', "ST_AVG_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Annex"
GROUP BY
    "ST_AVG_ID",
    "ST_AVG_Positor",
    "ST_AVG_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Scen_Medel_Annex',
    'no row in ST_AVG_Scen_Medel_Posit for ST_AVG_ID',
    OBJECT_CONSTRUCT('ST_AVG_ID', c."ST_AVG_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Annex" c
LEFT JOIN
    attributes."ST_AVG_Scen_Medel_Posit" p
ON
    p."ST_AVG_ID" = c."ST_AVG_ID"
WHERE
    p."ST_AVG_ID" IS NULL
GROUP BY
    c."ST_AVG_ID"
;
-- ST_MIN_Scen_Minimum_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_MIN_Scen_Minimum_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Scen_Minimum_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_MIN_ID', "ST_MIN_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Posit"
GROUP BY
    "ST_MIN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_MIN_ST_ID', "ST_MIN_ST_ID",
        'ST_MIN_UTL_ID', "ST_MIN_UTL_ID"
    ),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Posit"
GROUP BY
    "ST_MIN_ST_ID",
    "ST_MIN_UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum_Posit',
    'no row in ST_Scen for ST_MIN_ST_ID',
    OBJECT_CONSTRUCT('ST_MIN_ST_ID', c."ST_MIN_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_MIN_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_MIN_ST_ID"
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum_Posit',
    'no row in UTL_Utnyttjande for ST_MIN_UTL_ID',
    OBJECT_CONSTRUCT('ST_MIN_UTL_ID', c."ST_MIN_UTL_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Posit" c
LEFT JOIN
    knots."UTL_Utnyttjande" p
ON
    p."UTL_ID" = c."ST_MIN_UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."ST_MIN_UTL_ID"
;
-- ST_MIN_Scen_Minimum_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_MIN_Scen_Minimum_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Scen_Minimum_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_MIN_ID', "ST_MIN_ID",
        'ST_MIN_Positor', "ST_MIN_Positor",
        'ST_MIN_PositedAt', "ST_MIN_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Annex"
GROUP BY
    "ST_MIN_ID",
    "ST_MIN_Positor",
    "ST_MIN_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum_Annex',
    'no row in ST_MIN_Scen_Minimum_Posit for ST_MIN_ID',
    OBJECT_CONSTRUCT('ST_MIN_ID', c."ST_MIN_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Annex" c
LEFT JOIN
    attributes."ST_MIN_Scen_Minimum_Posit" p
ON
    p."ST_MIN_ID" = c."ST_MIN_ID"
WHERE
    p."ST_MIN_ID" IS NULL
GROUP BY
    c."ST_MIN_ID"
;
-- AC_NAM_Skådespelare_Namn_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_NAM_Skådespelare_Namn_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Skådespelare_Namn_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_NAM_ID', "AC_NAM_ID"),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit"
GROUP BY
    "AC_NAM_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Skådespelare_Namn_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_NAM_AC_ID', "AC_NAM_AC_ID",
        'AC_NAM_ChangedAt', "AC_NAM_ChangedAt",
        'AC_NAM_Skådespelare_Namn', "AC_NAM_Skådespelare_Namn"
    ),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit"
GROUP BY
    "AC_NAM_AC_ID",
    "AC_NAM_ChangedAt",
    "AC_NAM_Skådespelare_Namn"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Skådespelare_Namn_Posit',
    'no row in AC_Skådespelare for AC_NAM_AC_ID',
    OBJECT_CONSTRUCT('AC_NAM_AC_ID', c."AC_NAM_AC_ID"),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_NAM_AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_NAM_AC_ID"
;
-- AC_NAM_Skådespelare_Namn_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_NAM_Skådespelare_Namn_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Skådespelare_Namn_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_NAM_ID', "AC_NAM_ID",
        'AC_NAM_Positor', "AC_NAM_Positor",
        'AC_NAM_PositedAt', "AC_NAM_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn_Annex"
GROUP BY
    "AC_NAM_ID",
    "AC_NAM_Positor",
    "AC_NAM_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Skådespelare_Namn_Annex',
    'no row in AC_NAM_Skådespelare_Namn_Posit for AC_NAM_ID',
    OBJECT_CONSTRUCT('AC_NAM_ID', c."AC_NAM_ID"),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn_Annex" c
LEFT JOIN
    attributes."AC_NAM_Skådespelare_Namn_Posit" p
ON
    p."AC_NAM_ID" = c."AC_NAM_ID"
WHERE
    p."AC_NAM_ID" IS NULL
GROUP BY
    c."AC_NAM_ID"
;
-- AC_GEN_Skådespelare_Kön_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_GEN_Skådespelare_Kön_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Skådespelare_Kön_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_GEN_ID', "AC_GEN_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit"
GROUP BY
    "AC_GEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_GEN_AC_ID', "AC_GEN_AC_ID",
        'AC_GEN_GEN_ID', "AC_GEN_GEN_ID"
    ),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit"
GROUP BY
    "AC_GEN_AC_ID",
    "AC_GEN_GEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön_Posit',
    'no row in AC_Skådespelare for AC_GEN_AC_ID',
    OBJECT_CONSTRUCT('AC_GEN_AC_ID', c."AC_GEN_AC_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_GEN_AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_GEN_AC_ID"
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön_Posit',
    'no row in GEN_Kön for AC_GEN_GEN_ID',
    OBJECT_CONSTRUCT('AC_GEN_GEN_ID', c."AC_GEN_GEN_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit" c
LEFT JOIN
    knots."GEN_Kön" p
ON
    p."GEN_ID" = c."AC_GEN_GEN_ID"
WHERE
    p."GEN_ID" IS NULL
GROUP BY
    c."AC_GEN_GEN_ID"
;
-- AC_GEN_Skådespelare_Kön_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_GEN_Skådespelare_Kön_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Skådespelare_Kön_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_GEN_ID', "AC_GEN_ID",
        'AC_GEN_Positor', "AC_GEN_Positor",
        'AC_GEN_PositedAt', "AC_GEN_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Annex"
GROUP BY
    "AC_GEN_ID",
    "AC_GEN_Positor",
    "AC_GEN_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön_Annex',
    'no row in AC_GEN_Skådespelare_Kön_Posit for AC_GEN_ID',
    OBJECT_CONSTRUCT('AC_GEN_ID', c."AC_GEN_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Annex" c
LEFT JOIN
    attributes."AC_GEN_Skådespelare_Kön_Posit" p
ON
    p."AC_GEN_ID" = c."AC_GEN_ID"
WHERE
    p."AC_GEN_ID" IS NULL
GROUP BY
    c."AC_GEN_ID"
;
-- AC_PLV_Skådespelare_Yrkesnivå_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_PLV_Skådespelare_Yrkesnivå_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_PLV_ID', "AC_PLV_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit"
GROUP BY
    "AC_PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_PLV_AC_ID', "AC_PLV_AC_ID",
        'AC_PLV_ChangedAt', "AC_PLV_ChangedAt",
        'AC_PLV_PLV_ID', "AC_PLV_PLV_ID"
    ),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit"
GROUP BY
    "AC_PLV_AC_ID",
    "AC_PLV_ChangedAt",
    "AC_PLV_PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Posit',
    'no row in AC_Skådespelare for AC_PLV_AC_ID',
    OBJECT_CONSTRUCT('AC_PLV_AC_ID', c."AC_PLV_AC_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_PLV_AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_PLV_AC_ID"
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Posit',
    'no row in PLV_Yrkesnivå for AC_PLV_PLV_ID',
    OBJECT_CONSTRUCT('AC_PLV_PLV_ID', c."AC_PLV_PLV_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" c
LEFT JOIN
    knots."PLV_Yrkesnivå" p
ON
    p."PLV_ID" = c."AC_PLV_PLV_ID"
WHERE
    p."PLV_ID" IS NULL
GROUP BY
    c."AC_PLV_PLV_ID"
;
-- AC_PLV_Skådespelare_Yrkesnivå_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_PLV_Skådespelare_Yrkesnivå_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_PLV_ID', "AC_PLV_ID",
        'AC_PLV_Positor', "AC_PLV_Positor",
        'AC_PLV_PositedAt', "AC_PLV_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex"
GROUP BY
    "AC_PLV_ID",
    "AC_PLV_Positor",
    "AC_PLV_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Annex',
    'no row in AC_PLV_Skådespelare_Yrkesnivå_Posit for AC_PLV_ID',
    OBJECT_CONSTRUCT('AC_PLV_ID', c."AC_PLV_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" c
LEFT JOIN
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
ON
    p."AC_PLV_ID" = c."AC_PLV_ID"
WHERE
    p."AC_PLV_ID" IS NULL
GROUP BY
    c."AC_PLV_ID"
;
-- PR_NAM_Föreställning_Namn_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_NAM_Föreställning_Namn_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Föreställning_Namn_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_NAM_ID', "PR_NAM_ID"),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit"
GROUP BY
    "PR_NAM_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Föreställning_Namn_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_NAM_PR_ID', "PR_NAM_PR_ID",
        'PR_NAM_Föreställning_Namn', "PR_NAM_Föreställning_Namn"
    ),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit"
GROUP BY
    "PR_NAM_PR_ID",
    "PR_NAM_Föreställning_Namn"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Föreställning_Namn_Posit',
    'no row in PR_Föreställning for PR_NAM_PR_ID',
    OBJECT_CONSTRUCT('PR_NAM_PR_ID', c."PR_NAM_PR_ID"),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_NAM_PR_ID"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_NAM_PR_ID"
;
-- PR_NAM_Föreställning_Namn_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_NAM_Föreställning_Namn_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Föreställning_Namn_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_NAM_ID', "PR_NAM_ID",
        'PR_NAM_Positor', "PR_NAM_Positor",
        'PR_NAM_PositedAt', "PR_NAM_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn_Annex"
GROUP BY
    "PR_NAM_ID",
    "PR_NAM_Positor",
    "PR_NAM_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Föreställning_Namn_Annex',
    'no row in PR_NAM_Föreställning_Namn_Posit for PR_NAM_ID',
    OBJECT_CONSTRUCT('PR_NAM_ID', c."PR_NAM_ID"),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn_Annex" c
LEFT JOIN
    attributes."PR_NAM_Föreställning_Namn_Posit" p
ON
    p."PR_NAM_ID" = c."PR_NAM_ID"
WHERE
    p."PR_NAM_ID" IS NULL
GROUP BY
    c."PR_NAM_ID"
;
-- PR_LEN_Föreställning_Längd_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_LEN_Föreställning_Längd_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Föreställning_Längd_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_LEN_ID', "PR_LEN_ID"),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit"
GROUP BY
    "PR_LEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Föreställning_Längd_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_LEN_PR_ID', "PR_LEN_PR_ID",
        'PR_LEN_ChangedAt', "PR_LEN_ChangedAt",
        'PR_LEN_Föreställning_Längd', "PR_LEN_Föreställning_Längd"
    ),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit"
GROUP BY
    "PR_LEN_PR_ID",
    "PR_LEN_ChangedAt",
    "PR_LEN_Föreställning_Längd"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Föreställning_Längd_Posit',
    'no row in PR_Föreställning for PR_LEN_PR_ID',
    OBJECT_CONSTRUCT('PR_LEN_PR_ID', c."PR_LEN_PR_ID"),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_LEN_PR_ID"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_LEN_PR_ID"
;
-- PR_LEN_Föreställning_Längd_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_LEN_Föreställning_Längd_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Föreställning_Längd_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_LEN_ID', "PR_LEN_ID",
        'PR_LEN_Positor', "PR_LEN_Positor",
        'PR_LEN_PositedAt', "PR_LEN_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd_Annex"
GROUP BY
    "PR_LEN_ID",
    "PR_LEN_Positor",
    "PR_LEN_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Föreställning_Längd_Annex',
    'no row in PR_LEN_Föreställning_Längd_Posit for PR_LEN_ID',
    OBJECT_CONSTRUCT('PR_LEN_ID', c."PR_LEN_ID"),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd_Annex" c
LEFT JOIN
    attributes."PR_LEN_Föreställning_Längd_Posit" p
ON
    p."PR_LEN_ID" = c."PR_LEN_ID"
WHERE
    p."PR_LEN_ID" IS NULL
GROUP BY
    c."PR_LEN_ID"
;
-- AC_partner_AC_with_ONG_currently_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_partner_AC_with_ONG_currently_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_partner_AC_with_ONG_currently_ID', "AC_partner_AC_with_ONG_currently_ID"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_partner_AC_with_ONG_currently_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', "AC_ID_partner",
        'AC_ID_with', "AC_ID_with",
        'ONG_ID_currently', "ONG_ID_currently",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_partner)',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', "AC_ID_partner",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_ID_partner",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_with)',
    OBJECT_CONSTRUCT(
        'AC_ID_with', "AC_ID_with",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_ID_with",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Skådespelare for AC_ID_partner',
    OBJECT_CONSTRUCT('AC_ID_partner', c."AC_ID_partner"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_partner"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_partner"
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Skådespelare for AC_ID_with',
    OBJECT_CONSTRUCT('AC_ID_with', c."AC_ID_with"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_with"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_with"
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in ONG_Pågående for ONG_ID_currently',
    OBJECT_CONSTRUCT('ONG_ID_currently', c."ONG_ID_currently"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" c
LEFT JOIN
    knots."ONG_Pågående" p
ON
    p."ONG_ID" = c."ONG_ID_currently"
WHERE
    p."ONG_ID" IS NULL
GROUP BY
    c."ONG_ID_currently"
;
-- AC_partner_AC_with_ONG_currently_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_partner_AC_with_ONG_currently_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_partner_AC_with_ONG_currently_ID', "AC_partner_AC_with_ONG_currently_ID",
        'AC_partner_AC_with_ONG_currently_Positor', "AC_partner_AC_with_ONG_currently_Positor",
        'AC_partner_AC_with_ONG_currently_PositedAt', "AC_partner_AC_with_ONG_currently_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Annex"
GROUP BY
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_partner_AC_with_ONG_currently_Positor",
    "AC_partner_AC_with_ONG_currently_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'no row in AC_partner_AC_with_ONG_currently_Posit for AC_partner_AC_with_ONG_currently_ID',
    OBJECT_CONSTRUCT('AC_partner_AC_with_ONG_currently_ID', c."AC_partner_AC_with_ONG_currently_ID"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Annex" c
LEFT JOIN
    ties."AC_partner_AC_with_ONG_currently_Posit" p
ON
    p."AC_partner_AC_with_ONG_currently_ID" = c."AC_partner_AC_with_ONG_currently_ID"
WHERE
    p."AC_partner_AC_with_ONG_currently_ID" IS NULL
GROUP BY
    c."AC_partner_AC_with_ONG_currently_ID"
;
-- AC_subset_PN_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_subset_PN_of_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_subset_PN_of_ID', "AC_subset_PN_of_ID"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "AC_subset_PN_of_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', "AC_ID_subset",
        'PN_ID_of', "PN_ID_of"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "AC_ID_subset",
    "PN_ID_of"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (AC_subset)',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', "AC_ID_subset"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "AC_ID_subset"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (PN_of)',
    OBJECT_CONSTRUCT(
        'PN_ID_of', "PN_ID_of"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "PN_ID_of"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in AC_Skådespelare for AC_ID_subset',
    OBJECT_CONSTRUCT('AC_ID_subset', c."AC_ID_subset"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_subset"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_subset"
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in PN_Person for PN_ID_of',
    OBJECT_CONSTRUCT('PN_ID_of', c."PN_ID_of"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit" c
LEFT JOIN
    anchors."PN_Person" p
ON
    p."PN_ID" = c."PN_ID_of"
WHERE
    p."PN_ID" IS NULL
GROUP BY
    c."PN_ID_of"
;
-- AC_subset_PN_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_subset_PN_of_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_subset_PN_of_ID', "AC_subset_PN_of_ID",
        'AC_subset_PN_of_Positor', "AC_subset_PN_of_Positor",
        'AC_subset_PN_of_PositedAt', "AC_subset_PN_of_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Annex"
GROUP BY
    "AC_subset_PN_of_ID",
    "AC_subset_PN_of_Positor",
    "AC_subset_PN_of_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Annex',
    'no row in AC_subset_PN_of_Posit for AC_subset_PN_of_ID',
    OBJECT_CONSTRUCT('AC_subset_PN_of_ID', c."AC_subset_PN_of_ID"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Annex" c
LEFT JOIN
    ties."AC_subset_PN_of_Posit" p
ON
    p."AC_subset_PN_of_ID" = c."AC_subset_PN_of_ID"
WHERE
    p."AC_subset_PN_of_ID" IS NULL
GROUP BY
    c."AC_subset_PN_of_ID"
;
-- EV_in_AC_rollsattes_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_EV_in_AC_rollsattes_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_rollsattes_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_in_AC_rollsattes_ID', "EV_in_AC_rollsattes_ID"),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Posit"
GROUP BY
    "EV_in_AC_rollsattes_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_rollsattes_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_ID_in', "EV_ID_in",
        'AC_ID_rollsattes', "AC_ID_rollsattes"
    ),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Posit"
GROUP BY
    "EV_ID_in",
    "AC_ID_rollsattes"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_rollsattes_Posit',
    'no row in EV_Händelse for EV_ID_in',
    OBJECT_CONSTRUCT('EV_ID_in', c."EV_ID_in"),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_ID_in"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID_in"
UNION ALL
SELECT
    'EV_in_AC_rollsattes_Posit',
    'no row in AC_Skådespelare for AC_ID_rollsattes',
    OBJECT_CONSTRUCT('AC_ID_rollsattes', c."AC_ID_rollsattes"),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_rollsattes"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_rollsattes"
;
-- EV_in_AC_rollsattes_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_EV_in_AC_rollsattes_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_rollsattes_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_in_AC_rollsattes_ID', "EV_in_AC_rollsattes_ID",
        'EV_in_AC_rollsattes_Positor', "EV_in_AC_rollsattes_Positor",
        'EV_in_AC_rollsattes_PositedAt', "EV_in_AC_rollsattes_PositedAt"
    ),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Annex"
GROUP BY
    "EV_in_AC_rollsattes_ID",
    "EV_in_AC_rollsattes_Positor",
    "EV_in_AC_rollsattes_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_rollsattes_Annex',
    'no row in EV_in_AC_rollsattes_Posit for EV_in_AC_rollsattes_ID',
    OBJECT_CONSTRUCT('EV_in_AC_rollsattes_ID', c."EV_in_AC_rollsattes_ID"),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Annex" c
LEFT JOIN
    ties."EV_in_AC_rollsattes_Posit" p
ON
    p."EV_in_AC_rollsattes_ID" = c."EV_in_AC_rollsattes_ID"
WHERE
    p."EV_in_AC_rollsattes_ID" IS NULL
GROUP BY
    c."EV_in_AC_rollsattes_ID"
;
-- AC_deltar_PR_in_RAT_fick_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_deltar_PR_in_RAT_fick_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_deltar_PR_in_RAT_fick_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_deltar_PR_in_RAT_fick_ID', "AC_deltar_PR_in_RAT_fick_ID"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit"
GROUP BY
    "AC_deltar_PR_in_RAT_fick_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_deltar', "AC_ID_deltar",
        'PR_ID_in', "PR_ID_in",
        'RAT_ID_fick', "RAT_ID_fick",
        'AC_deltar_PR_in_RAT_fick_ChangedAt', "AC_deltar_PR_in_RAT_fick_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit"
GROUP BY
    "AC_ID_deltar",
    "PR_ID_in",
    "RAT_ID_fick",
    "AC_deltar_PR_in_RAT_fick_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick_Posit',
    'no row in AC_Skådespelare for AC_ID_deltar',
    OBJECT_CONSTRUCT('AC_ID_deltar', c."AC_ID_deltar"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_deltar"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_deltar"
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick_Posit',
    'no row in PR_Föreställning for PR_ID_in',
    OBJECT_CONSTRUCT('PR_ID_in', c."PR_ID_in"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_in"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_in"
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick_Posit',
    'no row in RAT_Betyg for RAT_ID_fick',
    OBJECT_CONSTRUCT('RAT_ID_fick', c."RAT_ID_fick"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit" c
LEFT JOIN
    knots."RAT_Betyg" p
ON
    p."RAT_ID" = c."RAT_ID_fick"
WHERE
    p."RAT_ID" IS NULL
GROUP BY
    c."RAT_ID_fick"
;
-- AC_deltar_PR_in_RAT_fick_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_deltar_PR_in_RAT_fick_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_deltar_PR_in_RAT_fick_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_deltar_PR_in_RAT_fick_ID', "AC_deltar_PR_in_RAT_fick_ID",
        'AC_deltar_PR_in_RAT_fick_Positor', "AC_deltar_PR_in_RAT_fick_Positor",
        'AC_deltar_PR_in_RAT_fick_PositedAt', "AC_deltar_PR_in_RAT_fick_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Annex"
GROUP BY
    "AC_deltar_PR_in_RAT_fick_ID",
    "AC_deltar_PR_in_RAT_fick_Positor",
    "AC_deltar_PR_in_RAT_fick_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick_Annex',
    'no row in AC_deltar_PR_in_RAT_fick_Posit for AC_deltar_PR_in_RAT_fick_ID',
    OBJECT_CONSTRUCT('AC_deltar_PR_in_RAT_fick_ID', c."AC_deltar_PR_in_RAT_fick_ID"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Annex" c
LEFT JOIN
    ties."AC_deltar_PR_in_RAT_fick_Posit" p
ON
    p."AC_deltar_PR_in_RAT_fick_ID" = c."AC_deltar_PR_in_RAT_fick_ID"
WHERE
    p."AC_deltar_PR_in_RAT_fick_ID" IS NULL
GROUP BY
    c."AC_deltar_PR_in_RAT_fick_ID"
;
-- ST_at_PR_spelas_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_ST_at_PR_spelas_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_spelas_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_at_PR_spelas_ID', "ST_at_PR_spelas_ID"),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Posit"
GROUP BY
    "ST_at_PR_spelas_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_spelas_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_ID_at', "ST_ID_at",
        'PR_ID_spelas', "PR_ID_spelas",
        'ST_at_PR_spelas_ChangedAt', "ST_at_PR_spelas_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Posit"
GROUP BY
    "ST_ID_at",
    "PR_ID_spelas",
    "ST_at_PR_spelas_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_spelas_Posit',
    'no row in ST_Scen for ST_ID_at',
    OBJECT_CONSTRUCT('ST_ID_at', c."ST_ID_at"),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_ID_at"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_at"
UNION ALL
SELECT
    'ST_at_PR_spelas_Posit',
    'no row in PR_Föreställning for PR_ID_spelas',
    OBJECT_CONSTRUCT('PR_ID_spelas', c."PR_ID_spelas"),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Posit" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_spelas"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_spelas"
;
-- ST_at_PR_spelas_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_ST_at_PR_spelas_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_spelas_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_at_PR_spelas_ID', "ST_at_PR_spelas_ID",
        'ST_at_PR_spelas_Positor', "ST_at_PR_spelas_Positor",
        'ST_at_PR_spelas_PositedAt', "ST_at_PR_spelas_PositedAt"
    ),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Annex"
GROUP BY
    "ST_at_PR_spelas_ID",
    "ST_at_PR_spelas_Positor",
    "ST_at_PR_spelas_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_spelas_Annex',
    'no row in ST_at_PR_spelas_Posit for ST_at_PR_spelas_ID',
    OBJECT_CONSTRUCT('ST_at_PR_spelas_ID', c."ST_at_PR_spelas_ID"),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Annex" c
LEFT JOIN
    ties."ST_at_PR_spelas_Posit" p
ON
    p."ST_at_PR_spelas_ID" = c."ST_at_PR_spelas_ID"
WHERE
    p."ST_at_PR_spelas_ID" IS NULL
GROUP BY
    c."ST_at_PR_spelas_ID"
;
-- AC_förälder_AC_barn_PAT_har_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_förälder_AC_barn_PAT_har_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_förälder_AC_barn_PAT_har_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_förälder_AC_barn_PAT_har_ID', "AC_förälder_AC_barn_PAT_har_ID"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit"
GROUP BY
    "AC_förälder_AC_barn_PAT_har_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_förälder', "AC_ID_förälder",
        'AC_ID_barn', "AC_ID_barn",
        'PAT_ID_har', "PAT_ID_har"
    ),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit"
GROUP BY
    "AC_ID_förälder",
    "AC_ID_barn",
    "PAT_ID_har"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har_Posit',
    'no row in AC_Skådespelare for AC_ID_förälder',
    OBJECT_CONSTRUCT('AC_ID_förälder', c."AC_ID_förälder"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_förälder"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_förälder"
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har_Posit',
    'no row in AC_Skådespelare for AC_ID_barn',
    OBJECT_CONSTRUCT('AC_ID_barn', c."AC_ID_barn"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_barn"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_barn"
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har_Posit',
    'no row in PAT_Föräldratyp for PAT_ID_har',
    OBJECT_CONSTRUCT('PAT_ID_har', c."PAT_ID_har"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" c
LEFT JOIN
    knots."PAT_Föräldratyp" p
ON
    p."PAT_ID" = c."PAT_ID_har"
WHERE
    p."PAT_ID" IS NULL
GROUP BY
    c."PAT_ID_har"
;
-- AC_förälder_AC_barn_PAT_har_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_förälder_AC_barn_PAT_har_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_förälder_AC_barn_PAT_har_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_förälder_AC_barn_PAT_har_ID', "AC_förälder_AC_barn_PAT_har_ID",
        'AC_förälder_AC_barn_PAT_har_Positor', "AC_förälder_AC_barn_PAT_har_Positor",
        'AC_förälder_AC_barn_PAT_har_PositedAt', "AC_förälder_AC_barn_PAT_har_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Annex"
GROUP BY
    "AC_förälder_AC_barn_PAT_har_ID",
    "AC_förälder_AC_barn_PAT_har_Positor",
    "AC_förälder_AC_barn_PAT_har_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har_Annex',
    'no row in AC_förälder_AC_barn_PAT_har_Posit for AC_förälder_AC_barn_PAT_har_ID',
    OBJECT_CONSTRUCT('AC_förälder_AC_barn_PAT_har_ID', c."AC_förälder_AC_barn_PAT_har_ID"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Annex" c
LEFT JOIN
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
ON
    p."AC_förälder_AC_barn_PAT_har_ID" = c."AC_förälder_AC_barn_PAT_har_ID"
WHERE
    p."AC_förälder_AC_barn_PAT_har_ID" IS NULL
GROUP BY
    c."AC_förälder_AC_barn_PAT_har_ID"
;
-- PR_innehåll_ST_plats_EV_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_PR_innehåll_ST_plats_EV_of_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_innehåll_ST_plats_EV_of_ID', "PR_innehåll_ST_plats_EV_of_ID"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
GROUP BY
    "PR_innehåll_ST_plats_EV_of_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_ID_innehåll', "PR_ID_innehåll",
        'ST_ID_plats', "ST_ID_plats",
        'EV_ID_of', "EV_ID_of",
        'PR_innehåll_ST_plats_EV_of_ChangedAt', "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
GROUP BY
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'duplicate unique key (PR_innehåll)',
    OBJECT_CONSTRUCT(
        'PR_ID_innehåll', "PR_ID_innehåll",
        'PR_innehåll_ST_plats_EV_of_ChangedAt', "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
GROUP BY
    "PR_ID_innehåll",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'duplicate unique key (ST_plats)',
    OBJECT_CONSTRUCT(
        'ST_ID_plats', "ST_ID_plats",
        'PR_innehåll_ST_plats_EV_of_ChangedAt', "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
GROUP BY
    "ST_ID_plats",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'no row in PR_Föreställning for PR_ID_innehåll',
    OBJECT_CONSTRUCT('PR_ID_innehåll', c."PR_ID_innehåll"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_innehåll"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_innehåll"
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'no row in ST_Scen for ST_ID_plats',
    OBJECT_CONSTRUCT('ST_ID_plats', c."ST_ID_plats"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_ID_plats"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_plats"
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'no row in EV_Händelse for EV_ID_of',
    OBJECT_CONSTRUCT('EV_ID_of', c."EV_ID_of"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_ID_of"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID_of"
;
-- PR_innehåll_ST_plats_EV_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_PR_innehåll_ST_plats_EV_of_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_innehåll_ST_plats_EV_of_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_innehåll_ST_plats_EV_of_ID', "PR_innehåll_ST_plats_EV_of_ID",
        'PR_innehåll_ST_plats_EV_of_Positor', "PR_innehåll_ST_plats_EV_of_Positor",
        'PR_innehåll_ST_plats_EV_of_PositedAt', "PR_innehåll_ST_plats_EV_of_PositedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Annex"
GROUP BY
    "PR_innehåll_ST_plats_EV_of_ID",
    "PR_innehåll_ST_plats_EV_of_Positor",
    "PR_innehåll_ST_plats_EV_of_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Annex',
    'no row in PR_innehåll_ST_plats_EV_of_Posit for PR_innehåll_ST_plats_EV_of_ID',
    OBJECT_CONSTRUCT('PR_innehåll_ST_plats_EV_of_ID', c."PR_innehåll_ST_plats_EV_of_ID"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Annex" c
LEFT JOIN
    ties."PR_innehåll_ST_plats_EV_of_Posit" p
ON
    p."PR_innehåll_ST_plats_EV_of_ID" = c."PR_innehåll_ST_plats_EV_of_ID"
WHERE
    p."PR_innehåll_ST_plats_EV_of_ID" IS NULL
GROUP BY
    c."PR_innehåll_ST_plats_EV_of_ID"
;
-- IntegrityViolations ------------------------------------------------------------------------------------------------
-- Every integrity check of the model, in one view.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW dw.IntegrityViolations (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR),
    CAST(NULL AS OBJECT),
    CAST(NULL AS NUMBER)
WHERE
    FALSE
UNION ALL SELECT * FROM knots."ic_PAT_Föräldratyp"
UNION ALL SELECT * FROM knots."ic_GEN_Kön"
UNION ALL SELECT * FROM knots."ic_PLV_Yrkesnivå"
UNION ALL SELECT * FROM knots."ic_UTL_Utnyttjande"
UNION ALL SELECT * FROM knots."ic_ONG_Pågående"
UNION ALL SELECT * FROM knots."ic_RAT_Betyg"
UNION ALL SELECT * FROM knots."ic_ETY_Händelsetyp"
UNION ALL SELECT * FROM anchors."ic_PN_Person"
UNION ALL SELECT * FROM anchors."ic_ST_Scen"
UNION ALL SELECT * FROM anchors."ic_AC_Skådespelare"
UNION ALL SELECT * FROM anchors."ic_PR_Föreställning"
UNION ALL SELECT * FROM nexuses."ic_EV_Händelse"
UNION ALL SELECT * FROM attributes."ic_EV_DAT_Händelse_Datum_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_DAT_Händelse_Datum_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_AUD_Händelse_Publik_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_AUD_Händelse_Publik_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_REV_Händelse_Intäkt_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_REV_Händelse_Intäkt_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_STA_Händelse_Status_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_STA_Händelse_Status_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_UTL_Händelse_Utnyttjande_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_UTL_Händelse_Utnyttjande_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_LVL_Händelse_Level_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_LVL_Händelse_Level_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_NAM_Scen_Namn_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_NAM_Scen_Namn_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_LOC_Scen_Plats_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_LOC_Scen_Plats_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_AVG_Scen_Medel_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_AVG_Scen_Medel_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_MIN_Scen_Minimum_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_MIN_Scen_Minimum_Annex"
UNION ALL SELECT * FROM attributes."ic_AC_NAM_Skådespelare_Namn_Posit"
UNION ALL SELECT * FROM attributes."ic_AC_NAM_Skådespelare_Namn_Annex"
UNION ALL SELECT * FROM attributes."ic_AC_GEN_Skådespelare_Kön_Posit"
UNION ALL SELECT * FROM attributes."ic_AC_GEN_Skådespelare_Kön_Annex"
UNION ALL SELECT * FROM attributes."ic_AC_PLV_Skådespelare_Yrkesnivå_Posit"
UNION ALL SELECT * FROM attributes."ic_AC_PLV_Skådespelare_Yrkesnivå_Annex"
UNION ALL SELECT * FROM attributes."ic_PR_NAM_Föreställning_Namn_Posit"
UNION ALL SELECT * FROM attributes."ic_PR_NAM_Föreställning_Namn_Annex"
UNION ALL SELECT * FROM attributes."ic_PR_LEN_Föreställning_Längd_Posit"
UNION ALL SELECT * FROM attributes."ic_PR_LEN_Föreställning_Längd_Annex"
UNION ALL SELECT * FROM ties."ic_AC_partner_AC_with_ONG_currently_Posit"
UNION ALL SELECT * FROM ties."ic_AC_partner_AC_with_ONG_currently_Annex"
UNION ALL SELECT * FROM ties."ic_AC_subset_PN_of_Posit"
UNION ALL SELECT * FROM ties."ic_AC_subset_PN_of_Annex"
UNION ALL SELECT * FROM ties."ic_EV_in_AC_rollsattes_Posit"
UNION ALL SELECT * FROM ties."ic_EV_in_AC_rollsattes_Annex"
UNION ALL SELECT * FROM ties."ic_AC_deltar_PR_in_RAT_fick_Posit"
UNION ALL SELECT * FROM ties."ic_AC_deltar_PR_in_RAT_fick_Annex"
UNION ALL SELECT * FROM ties."ic_ST_at_PR_spelas_Posit"
UNION ALL SELECT * FROM ties."ic_ST_at_PR_spelas_Annex"
UNION ALL SELECT * FROM ties."ic_AC_förälder_AC_barn_PAT_har_Posit"
UNION ALL SELECT * FROM ties."ic_AC_förälder_AC_barn_PAT_har_Annex"
UNION ALL SELECT * FROM ties."ic_PR_innehåll_ST_plats_EV_of_Posit"
UNION ALL SELECT * FROM ties."ic_PR_innehåll_ST_plats_EV_of_Annex"
;-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers. Views get their comments when they are
-- created, since Snowflake does not allow comments on view columns to be added afterwards.
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
