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
    "PAT_ID" smallint not null,
    "Metadata_PAT" integer not null, 
    constraint "pkPAT_Föräldratyp_ID" primary key (
        "PAT_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_Föräldratyp_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_Föräldratyp_EQ" (
    "PAT_ID" smallint not null,
    "PAT_EQ" smallint not null,
    "PAT_Föräldratyp" varchar(42) not null,
    "Metadata_PAT" integer not null, 
    constraint "fkPAT_Föräldratyp_EQ" foreign key (
        "PAT_ID"
    ) references knots."PAT_Föräldratyp_ID"("PAT_ID"),
    constraint "pkPAT_Föräldratyp_EQ" primary key (
        "PAT_EQ",
        "PAT_ID"
    ),
    constraint "uqPAT_Föräldratyp_EQ" unique (
        "PAT_EQ",
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
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå_ID" (
    "PLV_ID" smallint not null,
    "Metadata_PLV" integer not null, 
    constraint "pkPLV_Yrkesnivå_ID" primary key (
        "PLV_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå_EQ" (
    "PLV_ID" smallint not null,
    "PLV_EQ" smallint not null,
    "PLV_Yrkesnivå" text not null,
    "PLV_Checksum" bytea generated always as (decode(md5("PLV_Yrkesnivå"::text), 'hex')) stored,
    "Metadata_PLV" integer not null, 
    constraint "fkPLV_Yrkesnivå_EQ" foreign key (
        "PLV_ID"
    ) references knots."PLV_Yrkesnivå_ID"("PLV_ID"),
    constraint "pkPLV_Yrkesnivå_EQ" primary key (
        "PLV_EQ",
        "PLV_ID"
    ),
    constraint "uqPLV_Yrkesnivå_EQ" unique (
        "PLV_EQ",
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
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ONG_Pågående_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående_ID" (
    "ONG_ID" smallint not null,
    "Metadata_ONG" integer not null, 
    constraint "pkONG_Pågående_ID" primary key (
        "ONG_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Pågående_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående_EQ" (
    "ONG_ID" smallint not null,
    "ONG_EQ" smallint not null,
    "ONG_Pågående" varchar(3) not null,
    "Metadata_ONG" integer not null, 
    constraint "fkONG_Pågående_EQ" foreign key (
        "ONG_ID"
    ) references knots."ONG_Pågående_ID"("ONG_ID"),
    constraint "pkONG_Pågående_EQ" primary key (
        "ONG_EQ",
        "ONG_ID"
    ),
    constraint "uqONG_Pågående_EQ" unique (
        "ONG_EQ",
        "ONG_Pågående"
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- RAT_Betyg_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Betyg_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg_ID" (
    "RAT_ID" smallint default nextval('knots."RAT_Betyg_ID_SEQ"') not null, 
    "Metadata_RAT" integer not null, 
    constraint "pkRAT_Betyg_ID" primary key (
        "RAT_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Betyg_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg_EQ" (
    "RAT_ID" smallint not null,
    "RAT_EQ" smallint not null,
    "RAT_Betyg" varchar(42) not null,
    "RAT_Checksum" bytea generated always as (decode(md5("RAT_Betyg"::text), 'hex')) stored,
    "Metadata_RAT" integer not null, 
    constraint "fkRAT_Betyg_EQ" foreign key (
        "RAT_ID"
    ) references knots."RAT_Betyg_ID"("RAT_ID"),
    constraint "pkRAT_Betyg_EQ" primary key (
        "RAT_EQ",
        "RAT_ID"
    ),
    constraint "uqRAT_Betyg_EQ" unique (
        "RAT_EQ",
        "RAT_Checksum" 
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp_ID" (
    "ETY_ID" smallint not null,
    "Metadata_ETY" integer not null, 
    constraint "pkETY_Händelsetyp_ID" primary key (
        "ETY_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp_EQ" (
    "ETY_ID" smallint not null,
    "ETY_EQ" smallint not null,
    "ETY_Händelsetyp" varchar(42) not null,
    "ETY_Checksum" bytea generated always as (decode(md5("ETY_Händelsetyp"::text), 'hex')) stored,
    "Metadata_ETY" integer not null, 
    constraint "fkETY_Händelsetyp_EQ" foreign key (
        "ETY_ID"
    ) references knots."ETY_Händelsetyp_ID"("ETY_ID"),
    constraint "pkETY_Händelsetyp_EQ" primary key (
        "ETY_EQ",
        "ETY_ID"
    ),
    constraint "uqETY_Händelsetyp_EQ" unique (
        "ETY_EQ",
        "ETY_Checksum" 
    )
);
