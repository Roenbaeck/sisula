-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
--
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PAT_Föräldratyp_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_Föräldratyp_ID" (
    "PAT_ID" tinyint not null,
    "Metadata_PAT" int not null, 
    constraint "pkPAT_Föräldratyp_ID" primary key (
        "PAT_ID"
    ) RELY
) CLUSTER BY ("PAT_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_Föräldratyp_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_Föräldratyp_EQ" (
    "PAT_ID" tinyint not null,
    "PAT_EQ" tinyint not null,
    "PAT_Föräldratyp" varchar(42) not null,
    "Metadata_PAT" int not null, 
    constraint "fkPAT_Föräldratyp_EQ" foreign key (
        "PAT_ID"
    ) references knots."PAT_Föräldratyp_ID"("PAT_ID") RELY,
    constraint "pkPAT_Föräldratyp_EQ" primary key (
        "PAT_EQ",
        "PAT_ID"
    ) RELY,
    constraint "uqPAT_Föräldratyp_EQ" unique (
        "PAT_EQ",
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
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå_ID" (
    "PLV_ID" tinyint not null,
    "Metadata_PLV" int not null, 
    constraint "pkPLV_Yrkesnivå_ID" primary key (
        "PLV_ID"
    ) RELY
) CLUSTER BY ("PLV_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå_EQ" (
    "PLV_ID" tinyint not null,
    "PLV_EQ" tinyint not null,
    "PLV_Yrkesnivå" string not null,
    "PLV_Checksum" numeric(19,0) default hash("PLV_Yrkesnivå"),
    "Metadata_PLV" int not null, 
    constraint "fkPLV_Yrkesnivå_EQ" foreign key (
        "PLV_ID"
    ) references knots."PLV_Yrkesnivå_ID"("PLV_ID") RELY,
    constraint "pkPLV_Yrkesnivå_EQ" primary key (
        "PLV_EQ",
        "PLV_ID"
    ) RELY,
    constraint "uqPLV_Yrkesnivå_EQ" unique (
        "PLV_EQ",
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
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ONG_Pågående_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående_ID" (
    "ONG_ID" tinyint not null,
    "Metadata_ONG" int not null, 
    constraint "pkONG_Pågående_ID" primary key (
        "ONG_ID"
    ) RELY
) CLUSTER BY ("ONG_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Pågående_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående_EQ" (
    "ONG_ID" tinyint not null,
    "ONG_EQ" tinyint not null,
    "ONG_Pågående" varchar(3) not null,
    "Metadata_ONG" int not null, 
    constraint "fkONG_Pågående_EQ" foreign key (
        "ONG_ID"
    ) references knots."ONG_Pågående_ID"("ONG_ID") RELY,
    constraint "pkONG_Pågående_EQ" primary key (
        "ONG_EQ",
        "ONG_ID"
    ) RELY,
    constraint "uqONG_Pågående_EQ" unique (
        "ONG_EQ",
        "ONG_Pågående"
    ) RELY
) CLUSTER BY ("ONG_ID");
-- Knot identity table ------------------------------------------------------------------------------------------------
-- RAT_Betyg_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Betyg_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg_ID" (
    "RAT_ID" tinyint default knots."RAT_Betyg_ID_SEQ".nextval not null, 
    "Metadata_RAT" int not null, 
    constraint "pkRAT_Betyg_ID" primary key (
        "RAT_ID"
    ) RELY
) CLUSTER BY ("RAT_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Betyg_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg_EQ" (
    "RAT_ID" tinyint not null,
    "RAT_EQ" tinyint not null,
    "RAT_Betyg" varchar(42) not null,
    "RAT_Checksum" numeric(19,0) default hash("RAT_Betyg"),
    "Metadata_RAT" int not null, 
    constraint "fkRAT_Betyg_EQ" foreign key (
        "RAT_ID"
    ) references knots."RAT_Betyg_ID"("RAT_ID") RELY,
    constraint "pkRAT_Betyg_EQ" primary key (
        "RAT_EQ",
        "RAT_ID"
    ) RELY,
    constraint "uqRAT_Betyg_EQ" unique (
        "RAT_EQ",
        "RAT_Checksum" 
    ) RELY
) CLUSTER BY ("RAT_ID");
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp_ID" (
    "ETY_ID" tinyint not null,
    "Metadata_ETY" int not null, 
    constraint "pkETY_Händelsetyp_ID" primary key (
        "ETY_ID"
    ) RELY
) CLUSTER BY ("ETY_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp_EQ" (
    "ETY_ID" tinyint not null,
    "ETY_EQ" tinyint not null,
    "ETY_Händelsetyp" varchar(42) not null,
    "ETY_Checksum" numeric(19,0) default hash("ETY_Händelsetyp"),
    "Metadata_ETY" int not null, 
    constraint "fkETY_Händelsetyp_EQ" foreign key (
        "ETY_ID"
    ) references knots."ETY_Händelsetyp_ID"("ETY_ID") RELY,
    constraint "pkETY_Händelsetyp_EQ" primary key (
        "ETY_EQ",
        "ETY_ID"
    ) RELY,
    constraint "uqETY_Händelsetyp_EQ" unique (
        "ETY_EQ",
        "ETY_Checksum" 
    ) RELY
) CLUSTER BY ("ETY_ID");
