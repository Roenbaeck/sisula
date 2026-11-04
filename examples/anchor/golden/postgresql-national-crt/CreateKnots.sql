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
-- GEN_Kön table
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
-- PLV_Yrkesnivå table
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
-- UTL_Utnyttjande table
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
-- ONG_Pågående table
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
-- RAT_Betyg table
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
-- ETY_Händelsetyp table
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
