-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are immutable lookup tables for values.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PAT_ParentalType" (
    "PAT_ID" tinyint not null,
    "PAT_ParentalType" varchar(42) not null,
    constraint "pkPAT_ParentalType" primary key (
        "PAT_ID"
    ),
    constraint "uqPAT_ParentalType" unique (
        "PAT_ParentalType"
    )
) ORDER BY "PAT_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."GEN_Gender" (
    "GEN_ID" tinyint not null,
    "GEN_Gender" varchar(42) not null,
    constraint "pkGEN_Gender" primary key (
        "GEN_ID"
    ),
    constraint "uqGEN_Gender" unique (
        "GEN_Gender"
    )
) ORDER BY "GEN_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PLV_ProfessionalLevel" (
    "PLV_ID" tinyint not null,
    "PLV_ProfessionalLevel" long varchar(32000000) not null,
    "PLV_Checksum" int default hash("PLV_ProfessionalLevel"),
    constraint "pkPLV_ProfessionalLevel" primary key (
        "PLV_ID"
    ),
    constraint "uqPLV_ProfessionalLevel" unique (
        "PLV_Checksum" 
    )
) ORDER BY "PLV_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."UTL_Utilization" (
    "UTL_ID" tinyint not null,
    "UTL_Utilization" tinyint not null,
    constraint "pkUTL_Utilization" primary key (
        "UTL_ID"
    ),
    constraint "uqUTL_Utilization" unique (
        "UTL_Utilization"
    )
) ORDER BY "UTL_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ONG_Ongoing" (
    "ONG_ID" tinyint not null,
    "ONG_Ongoing" varchar(3) not null,
    constraint "pkONG_Ongoing" primary key (
        "ONG_ID"
    ),
    constraint "uqONG_Ongoing" unique (
        "ONG_Ongoing"
    )
) ORDER BY "ONG_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."RAT_Rating" (
    "RAT_ID" tinyint not null,
    "RAT_Rating" varchar(42) not null,
    constraint "pkRAT_Rating" primary key (
        "RAT_ID"
    ),
    constraint "uqRAT_Rating" unique (
        "RAT_Rating"
    )
) ORDER BY "RAT_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ETY_EventType" (
    "ETY_ID" tinyint not null,
    "ETY_EventType" varchar(42) not null,
    constraint "pkETY_EventType" primary key (
        "ETY_ID"
    ),
    constraint "uqETY_EventType" unique (
        "ETY_EventType"
    )
) ORDER BY "ETY_ID" UNSEGMENTED ALL NODES;
