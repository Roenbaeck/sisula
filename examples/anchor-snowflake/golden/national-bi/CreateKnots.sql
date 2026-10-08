-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are immutable lookup tables for values.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
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
