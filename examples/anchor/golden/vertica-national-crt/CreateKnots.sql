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
    "Metadata_PAT" integer not null,
    constraint "pkPAT_Föräldratyp" primary key (
        "PAT_ID" 
    ),
    constraint "uqPAT_Föräldratyp" unique (
        "PAT_Föräldratyp"
    )
) ORDER BY "PAT_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Kön table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Kön" (
    "GEN_ID" tinyint not null,
    "GEN_Kön" varchar(42) not null,
    "GEN_Checksum" int default hash("GEN_Kön"),
    "Metadata_GEN" integer not null,
    constraint "pkGEN_Kön" primary key (
        "GEN_ID" 
    ),
    constraint "uqGEN_Kön" unique (
        "GEN_Checksum" 
    )
) ORDER BY "GEN_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå" (
    "PLV_ID" tinyint not null,
    "PLV_Yrkesnivå" long varchar(32000000) not null,
    "PLV_Checksum" int default hash("PLV_Yrkesnivå"),
    "Metadata_PLV" integer not null,
    constraint "pkPLV_Yrkesnivå" primary key (
        "PLV_ID" 
    ),
    constraint "uqPLV_Yrkesnivå" unique (
        "PLV_Checksum" 
    )
) ORDER BY "PLV_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utnyttjande table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utnyttjande" (
    "UTL_ID" tinyint not null,
    "UTL_Utnyttjande" tinyint not null,
    "Metadata_UTL" integer not null,
    constraint "pkUTL_Utnyttjande" primary key (
        "UTL_ID" 
    ),
    constraint "uqUTL_Utnyttjande" unique (
        "UTL_Utnyttjande"
    )
) ORDER BY "UTL_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Pågående table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående" (
    "ONG_ID" tinyint not null,
    "ONG_Pågående" varchar(3) not null,
    "Metadata_ONG" integer not null,
    constraint "pkONG_Pågående" primary key (
        "ONG_ID" 
    ),
    constraint "uqONG_Pågående" unique (
        "ONG_Pågående"
    )
) ORDER BY "ONG_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Betyg table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Betyg_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg" (
    "RAT_ID" tinyint default nextval('knots."RAT_Betyg_ID_SEQ"') not null, 
    "RAT_Betyg" varchar(42) not null,
    "RAT_Checksum" int default hash("RAT_Betyg"),
    "Metadata_RAT" integer not null,
    constraint "pkRAT_Betyg" primary key (
        "RAT_ID" 
    ),
    constraint "uqRAT_Betyg" unique (
        "RAT_Checksum" 
    )
) ORDER BY "RAT_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp" (
    "ETY_ID" tinyint not null,
    "ETY_Händelsetyp" varchar(42) not null,
    "ETY_Checksum" int default hash("ETY_Händelsetyp"),
    "Metadata_ETY" integer not null,
    constraint "pkETY_Händelsetyp" primary key (
        "ETY_ID" 
    ),
    constraint "uqETY_Händelsetyp" unique (
        "ETY_Checksum" 
    )
) ORDER BY "ETY_ID" UNSEGMENTED ALL NODES;
