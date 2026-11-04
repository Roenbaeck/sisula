-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are immutable lookup tables for values.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_ParentalType" (
    "PAT_ID" smallint not null,
    "PAT_ParentalType" varchar(42) not null,
    "Metadata_PAT" bigint not null,
    constraint "pkPAT_ParentalType" primary key (
        "PAT_ID"
    ),
    constraint "uqPAT_ParentalType" unique (
        "PAT_ParentalType"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Gender" (
    "GEN_ID" smallint not null,
    "GEN_Gender" varchar(42) not null,
    "GEN_Checksum" bytea generated always as (decode(md5("GEN_Gender"::text), 'hex')) stored,
    "Metadata_GEN" bigint not null,
    constraint "pkGEN_Gender" primary key (
        "GEN_ID"
    ),
    constraint "uqGEN_Gender" unique (
        "GEN_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_ProfessionalLevel" (
    "PLV_ID" smallint not null,
    "PLV_ProfessionalLevel" text not null,
    "PLV_Checksum" bytea generated always as (decode(md5("PLV_ProfessionalLevel"::text), 'hex')) stored,
    "Metadata_PLV" bigint not null,
    constraint "pkPLV_ProfessionalLevel" primary key (
        "PLV_ID"
    ),
    constraint "uqPLV_ProfessionalLevel" unique (
        "PLV_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utilization" (
    "UTL_ID" smallint not null,
    "UTL_Utilization" smallint not null,
    "Metadata_UTL" bigint not null,
    constraint "pkUTL_Utilization" primary key (
        "UTL_ID"
    ),
    constraint "uqUTL_Utilization" unique (
        "UTL_Utilization"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Ongoing" (
    "ONG_ID" smallint not null,
    "ONG_Ongoing" varchar(3) not null,
    "Metadata_ONG" bigint not null,
    constraint "pkONG_Ongoing" primary key (
        "ONG_ID"
    ),
    constraint "uqONG_Ongoing" unique (
        "ONG_Ongoing"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Rating_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Rating" (
    "RAT_ID" smallint default nextval('knots."RAT_Rating_ID_SEQ"') not null, 
    "RAT_Rating" varchar(42) not null,
    "RAT_Checksum" bytea generated always as (decode(md5("RAT_Rating"::text), 'hex')) stored,
    "Metadata_RAT" bigint not null,
    constraint "pkRAT_Rating" primary key (
        "RAT_ID"
    ),
    constraint "uqRAT_Rating" unique (
        "RAT_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_EventType" (
    "ETY_ID" smallint not null,
    "ETY_EventType" varchar(42) not null,
    "ETY_Checksum" bytea generated always as (decode(md5("ETY_EventType"::text), 'hex')) stored,
    "Metadata_ETY" bigint not null,
    constraint "pkETY_EventType" primary key (
        "ETY_ID"
    ),
    constraint "uqETY_EventType" unique (
        "ETY_Checksum" 
    )
);
