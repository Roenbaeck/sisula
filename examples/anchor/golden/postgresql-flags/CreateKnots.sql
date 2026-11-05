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
-- PAT_ParentalType_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_ParentalType_ID" (
    "PAT_ID" smallint not null,
    "Metadata_PAT" integer not null, 
    constraint "pkPAT_ParentalType_ID" primary key (
        "PAT_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_ParentalType_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_ParentalType_EQ" (
    "PAT_ID" smallint not null,
    "PAT_EQ" smallint not null,
    "PAT_ParentalType" varchar(42) not null,
    "Metadata_PAT" integer not null, 
    constraint "fkPAT_ParentalType_EQ" foreign key (
        "PAT_ID"
    ) references knots."PAT_ParentalType_ID"("PAT_ID"),
    constraint "pkPAT_ParentalType_EQ" primary key (
        "PAT_EQ",
        "PAT_ID"
    ),
    constraint "uqPAT_ParentalType_EQ" unique (
        "PAT_EQ",
        "PAT_ParentalType"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Gender" (
    "GEN_ID" smallint not null,
    "GEN_Gender" varchar(42) not null,
    "GEN_Checksum" bytea generated always as (decode(md5("GEN_Gender"::text), 'hex')) stored,
    "Metadata_GEN" integer not null,
    constraint "pkGEN_Gender" primary key (
        "GEN_ID"
    ),
    constraint "uqGEN_Gender" unique (
        "GEN_Checksum" 
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_ProfessionalLevel_ID" (
    "PLV_ID" smallint not null,
    "Metadata_PLV" integer not null, 
    constraint "pkPLV_ProfessionalLevel_ID" primary key (
        "PLV_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_ProfessionalLevel_EQ" (
    "PLV_ID" smallint not null,
    "PLV_EQ" smallint not null,
    "PLV_ProfessionalLevel" text not null,
    "PLV_Checksum" bytea generated always as (decode(md5("PLV_ProfessionalLevel"::text), 'hex')) stored,
    "Metadata_PLV" integer not null, 
    constraint "fkPLV_ProfessionalLevel_EQ" foreign key (
        "PLV_ID"
    ) references knots."PLV_ProfessionalLevel_ID"("PLV_ID"),
    constraint "pkPLV_ProfessionalLevel_EQ" primary key (
        "PLV_EQ",
        "PLV_ID"
    ),
    constraint "uqPLV_ProfessionalLevel_EQ" unique (
        "PLV_EQ",
        "PLV_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utilization" (
    "UTL_ID" smallint not null,
    "UTL_Utilization" smallint not null,
    "Metadata_UTL" integer not null,
    constraint "pkUTL_Utilization" primary key (
        "UTL_ID"
    ),
    constraint "uqUTL_Utilization" unique (
        "UTL_Utilization"
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ONG_Ongoing_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Ongoing_ID" (
    "ONG_ID" smallint not null,
    "Metadata_ONG" integer not null, 
    constraint "pkONG_Ongoing_ID" primary key (
        "ONG_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Ongoing_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Ongoing_EQ" (
    "ONG_ID" smallint not null,
    "ONG_EQ" smallint not null,
    "ONG_Ongoing" varchar(3) not null,
    "Metadata_ONG" integer not null, 
    constraint "fkONG_Ongoing_EQ" foreign key (
        "ONG_ID"
    ) references knots."ONG_Ongoing_ID"("ONG_ID"),
    constraint "pkONG_Ongoing_EQ" primary key (
        "ONG_EQ",
        "ONG_ID"
    ),
    constraint "uqONG_Ongoing_EQ" unique (
        "ONG_EQ",
        "ONG_Ongoing"
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- RAT_Rating_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Rating_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Rating_ID" (
    "RAT_ID" smallint default nextval('knots."RAT_Rating_ID_SEQ"') not null, 
    "Metadata_RAT" integer not null, 
    constraint "pkRAT_Rating_ID" primary key (
        "RAT_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Rating_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."RAT_Rating_EQ" (
    "RAT_ID" smallint not null,
    "RAT_EQ" smallint not null,
    "RAT_Rating" varchar(42) not null,
    "RAT_Checksum" bytea generated always as (decode(md5("RAT_Rating"::text), 'hex')) stored,
    "Metadata_RAT" integer not null, 
    constraint "fkRAT_Rating_EQ" foreign key (
        "RAT_ID"
    ) references knots."RAT_Rating_ID"("RAT_ID"),
    constraint "pkRAT_Rating_EQ" primary key (
        "RAT_EQ",
        "RAT_ID"
    ),
    constraint "uqRAT_Rating_EQ" unique (
        "RAT_EQ",
        "RAT_Checksum" 
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ETY_EventType_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_EventType_ID" (
    "ETY_ID" smallint not null,
    "Metadata_ETY" integer not null, 
    constraint "pkETY_EventType_ID" primary key (
        "ETY_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ETY_EventType_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_EventType_EQ" (
    "ETY_ID" smallint not null,
    "ETY_EQ" smallint not null,
    "ETY_EventType" varchar(42) not null,
    "ETY_Checksum" bytea generated always as (decode(md5("ETY_EventType"::text), 'hex')) stored,
    "Metadata_ETY" integer not null, 
    constraint "fkETY_EventType_EQ" foreign key (
        "ETY_ID"
    ) references knots."ETY_EventType_ID"("ETY_ID"),
    constraint "pkETY_EventType_EQ" primary key (
        "ETY_EQ",
        "ETY_ID"
    ),
    constraint "uqETY_EventType_EQ" unique (
        "ETY_EQ",
        "ETY_Checksum" 
    )
);
