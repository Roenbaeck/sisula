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
    "PAT_ID" tinyint not null,
    "Metadata_PAT" int not null, 
    constraint "pkPAT_ParentalType_ID" primary key (
        "PAT_ID"
    ) RELY
) CLUSTER BY ("PAT_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_ParentalType_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_ParentalType_EQ" (
    "PAT_ID" tinyint not null,
    "PAT_EQ" tinyint not null,
    "PAT_ParentalType" varchar(42) not null,
    "Metadata_PAT" int not null, 
    constraint "fkPAT_ParentalType_EQ" foreign key (
        "PAT_ID"
    ) references knots."PAT_ParentalType_ID"("PAT_ID") RELY,
    constraint "pkPAT_ParentalType_EQ" primary key (
        "PAT_EQ",
        "PAT_ID"
    ) RELY,
    constraint "uqPAT_ParentalType_EQ" unique (
        "PAT_EQ",
        "PAT_ParentalType"
    ) RELY
) CLUSTER BY ("PAT_ID");
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Gender" (
    "GEN_ID" number(1,0) not null,
    "GEN_Gender" varchar(42) not null,
    "GEN_Checksum" numeric(19,0) default hash("GEN_Gender"),
    "Metadata_GEN" int not null,
    constraint "pkGEN_Gender" primary key (
        "GEN_ID"
    ) RELY,
    constraint "uqGEN_Gender" unique (
        "GEN_Checksum" 
    ) RELY
) CLUSTER BY ("GEN_ID");
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_ProfessionalLevel_ID" (
    "PLV_ID" tinyint not null,
    "Metadata_PLV" int not null, 
    constraint "pkPLV_ProfessionalLevel_ID" primary key (
        "PLV_ID"
    ) RELY
) CLUSTER BY ("PLV_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_ProfessionalLevel_EQ" (
    "PLV_ID" tinyint not null,
    "PLV_EQ" tinyint not null,
    "PLV_ProfessionalLevel" string not null,
    "PLV_Checksum" numeric(19,0) default hash("PLV_ProfessionalLevel"),
    "Metadata_PLV" int not null, 
    constraint "fkPLV_ProfessionalLevel_EQ" foreign key (
        "PLV_ID"
    ) references knots."PLV_ProfessionalLevel_ID"("PLV_ID") RELY,
    constraint "pkPLV_ProfessionalLevel_EQ" primary key (
        "PLV_EQ",
        "PLV_ID"
    ) RELY,
    constraint "uqPLV_ProfessionalLevel_EQ" unique (
        "PLV_EQ",
        "PLV_Checksum" 
    ) RELY
) CLUSTER BY ("PLV_ID");
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utilization" (
    "UTL_ID" tinyint not null,
    "UTL_Utilization" tinyint not null,
    "Metadata_UTL" int not null,
    constraint "pkUTL_Utilization" primary key (
        "UTL_ID"
    ) RELY,
    constraint "uqUTL_Utilization" unique (
        "UTL_Utilization"
    ) RELY
) CLUSTER BY ("UTL_ID");
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ONG_Ongoing_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Ongoing_ID" (
    "ONG_ID" tinyint not null,
    "Metadata_ONG" int not null, 
    constraint "pkONG_Ongoing_ID" primary key (
        "ONG_ID"
    ) RELY
) CLUSTER BY ("ONG_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Ongoing_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Ongoing_EQ" (
    "ONG_ID" tinyint not null,
    "ONG_EQ" tinyint not null,
    "ONG_Ongoing" varchar(3) not null,
    "Metadata_ONG" int not null, 
    constraint "fkONG_Ongoing_EQ" foreign key (
        "ONG_ID"
    ) references knots."ONG_Ongoing_ID"("ONG_ID") RELY,
    constraint "pkONG_Ongoing_EQ" primary key (
        "ONG_EQ",
        "ONG_ID"
    ) RELY,
    constraint "uqONG_Ongoing_EQ" unique (
        "ONG_EQ",
        "ONG_Ongoing"
    ) RELY
) CLUSTER BY ("ONG_ID");
-- Knot identity table ------------------------------------------------------------------------------------------------
-- RAT_Rating_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Rating_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Rating_ID" (
    "RAT_ID" tinyint default knots."RAT_Rating_ID_SEQ".nextval not null, 
    "Metadata_RAT" int not null, 
    constraint "pkRAT_Rating_ID" primary key (
        "RAT_ID"
    ) RELY
) CLUSTER BY ("RAT_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Rating_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."RAT_Rating_EQ" (
    "RAT_ID" tinyint not null,
    "RAT_EQ" tinyint not null,
    "RAT_Rating" varchar(42) not null,
    "RAT_Checksum" numeric(19,0) default hash("RAT_Rating"),
    "Metadata_RAT" int not null, 
    constraint "fkRAT_Rating_EQ" foreign key (
        "RAT_ID"
    ) references knots."RAT_Rating_ID"("RAT_ID") RELY,
    constraint "pkRAT_Rating_EQ" primary key (
        "RAT_EQ",
        "RAT_ID"
    ) RELY,
    constraint "uqRAT_Rating_EQ" unique (
        "RAT_EQ",
        "RAT_Checksum" 
    ) RELY
) CLUSTER BY ("RAT_ID");
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ETY_EventType_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_EventType_ID" (
    "ETY_ID" tinyint not null,
    "Metadata_ETY" int not null, 
    constraint "pkETY_EventType_ID" primary key (
        "ETY_ID"
    ) RELY
) CLUSTER BY ("ETY_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ETY_EventType_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_EventType_EQ" (
    "ETY_ID" tinyint not null,
    "ETY_EQ" tinyint not null,
    "ETY_EventType" varchar(42) not null,
    "ETY_Checksum" numeric(19,0) default hash("ETY_EventType"),
    "Metadata_ETY" int not null, 
    constraint "fkETY_EventType_EQ" foreign key (
        "ETY_ID"
    ) references knots."ETY_EventType_ID"("ETY_ID") RELY,
    constraint "pkETY_EventType_EQ" primary key (
        "ETY_EQ",
        "ETY_ID"
    ) RELY,
    constraint "uqETY_EventType_EQ" unique (
        "ETY_EQ",
        "ETY_Checksum" 
    ) RELY
) CLUSTER BY ("ETY_ID");
