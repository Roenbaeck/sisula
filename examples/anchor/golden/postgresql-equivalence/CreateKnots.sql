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
CREATE SEQUENCE IF NOT EXISTS public."PAT_ParentalType_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PAT_ParentalType_ID" (
    "PAT_ID" smallint default nextval('public."PAT_ParentalType_ID_SEQ"') not null, 
    "Metadata_PAT" integer not null, 
    constraint "pkPAT_ParentalType_ID" primary key (
        "PAT_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_ParentalType_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PAT_ParentalType_EQ" (
    "PAT_ID" smallint not null,
    "PAT_EQ" smallint not null,
    "PAT_ParentalType" varchar(42) not null,
    "Metadata_PAT" integer not null, 
    constraint "fkPAT_ParentalType_EQ" foreign key (
        "PAT_ID"
    ) references public."PAT_ParentalType_ID"("PAT_ID"),
    constraint "pkPAT_ParentalType_EQ" primary key (
        "PAT_EQ",
        "PAT_ID"
    ),
    constraint "uqPAT_ParentalType_EQ" unique (
        "PAT_EQ",
        "PAT_ParentalType"
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- GEN_Gender_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."GEN_Gender_ID" (
    "GEN_ID" smallint not null,
    "Metadata_GEN" integer not null, 
    constraint "pkGEN_Gender_ID" primary key (
        "GEN_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- GEN_Gender_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."GEN_Gender_EQ" (
    "GEN_ID" smallint not null,
    "GEN_EQ" smallint not null,
    "GEN_Gender" varchar(42) not null,
    "Metadata_GEN" integer not null, 
    constraint "fkGEN_Gender_EQ" foreign key (
        "GEN_ID"
    ) references public."GEN_Gender_ID"("GEN_ID"),
    constraint "pkGEN_Gender_EQ" primary key (
        "GEN_EQ",
        "GEN_ID"
    ),
    constraint "uqGEN_Gender_EQ" unique (
        "GEN_EQ",
        "GEN_Gender"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PLV_ProfessionalLevel" (
    "PLV_ID" smallint not null,
    "PLV_ProfessionalLevel" text not null,
    "PLV_Checksum" bytea generated always as (decode(md5("PLV_ProfessionalLevel"::text), 'hex')) stored,
    "Metadata_PLV" integer not null,
    constraint "pkPLV_ProfessionalLevel" primary key (
        "PLV_ID"
    ),
    constraint "uqPLV_ProfessionalLevel" unique (
        "PLV_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."UTL_Utilization" (
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
CREATE TABLE IF NOT EXISTS public."ONG_Ongoing_ID" (
    "ONG_ID" smallint not null,
    "Metadata_ONG" integer not null, 
    constraint "pkONG_Ongoing_ID" primary key (
        "ONG_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Ongoing_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ONG_Ongoing_EQ" (
    "ONG_ID" smallint not null,
    "ONG_EQ" smallint not null,
    "ONG_Ongoing" varchar(3) not null,
    "Metadata_ONG" integer not null, 
    constraint "fkONG_Ongoing_EQ" foreign key (
        "ONG_ID"
    ) references public."ONG_Ongoing_ID"("ONG_ID"),
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
CREATE SEQUENCE IF NOT EXISTS public."RAT_Rating_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."RAT_Rating_ID" (
    "RAT_ID" smallint default nextval('public."RAT_Rating_ID_SEQ"') not null, 
    "Metadata_RAT" integer not null, 
    constraint "pkRAT_Rating_ID" primary key (
        "RAT_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Rating_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."RAT_Rating_EQ" (
    "RAT_ID" smallint not null,
    "RAT_EQ" smallint not null,
    "RAT_Rating" varchar(42) not null,
    "Metadata_RAT" integer not null, 
    constraint "fkRAT_Rating_EQ" foreign key (
        "RAT_ID"
    ) references public."RAT_Rating_ID"("RAT_ID"),
    constraint "pkRAT_Rating_EQ" primary key (
        "RAT_EQ",
        "RAT_ID"
    ),
    constraint "uqRAT_Rating_EQ" unique (
        "RAT_EQ",
        "RAT_Rating"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ETY_EventType" (
    "ETY_ID" smallint not null,
    "ETY_EventType" varchar(42) not null,
    "Metadata_ETY" integer not null,
    constraint "pkETY_EventType" primary key (
        "ETY_ID"
    ),
    constraint "uqETY_EventType" unique (
        "ETY_EventType"
    )
);
