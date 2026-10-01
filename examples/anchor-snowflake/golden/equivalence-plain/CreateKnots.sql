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
CREATE SEQUENCE IF NOT EXISTS public.PAT_ParentalType_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PAT_ParentalType_ID (
    PAT_ID tinyint default public.PAT_ParentalType_ID_SEQ.nextval not null, 
     bit null,
    constraint pkPAT_ParentalType_ID primary key (
        PAT_ID
    ) RELY
) CLUSTER BY (PAT_ID);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_ParentalType_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PAT_ParentalType_EQ (
    PAT_ID tinyint not null,
    PAT_EQ tinyint not null,
    PAT_ParentalType varchar(42) not null,
     bit null,
    constraint fkPAT_ParentalType_EQ foreign key (
        PAT_ID
    ) references public.PAT_ParentalType_ID(PAT_ID) RELY,
    constraint pkPAT_ParentalType_EQ primary key (
        PAT_EQ,
        PAT_ID
    ) RELY,
    constraint uqPAT_ParentalType_EQ unique (
        PAT_EQ,
        PAT_ParentalType
    ) RELY
) CLUSTER BY (PAT_ID);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- GEN_Gender_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.GEN_Gender_ID (
    GEN_ID number(1,0) not null,
     bit null,
    constraint pkGEN_Gender_ID primary key (
        GEN_ID
    ) RELY
) CLUSTER BY (GEN_ID);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- GEN_Gender_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.GEN_Gender_EQ (
    GEN_ID number(1,0) not null,
    GEN_EQ tinyint not null,
    GEN_Gender varchar(42) not null,
     bit null,
    constraint fkGEN_Gender_EQ foreign key (
        GEN_ID
    ) references public.GEN_Gender_ID(GEN_ID) RELY,
    constraint pkGEN_Gender_EQ primary key (
        GEN_EQ,
        GEN_ID
    ) RELY,
    constraint uqGEN_Gender_EQ unique (
        GEN_EQ,
        GEN_Gender
    ) RELY
) CLUSTER BY (GEN_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PLV_ProfessionalLevel (
    PLV_ID tinyint not null,
    PLV_ProfessionalLevel string not null,
    PLV_Checksum numeric(19,0) default hash(PLV_ProfessionalLevel),
    constraint pkPLV_ProfessionalLevel primary key (
        PLV_ID
    ) RELY,
    constraint uqPLV_ProfessionalLevel unique (
        PLV_Checksum 
    ) RELY
) CLUSTER BY (PLV_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.UTL_Utilization (
    UTL_ID tinyint not null,
    UTL_Utilization tinyint not null,
    constraint pkUTL_Utilization primary key (
        UTL_ID
    ) RELY,
    constraint uqUTL_Utilization unique (
        UTL_Utilization
    ) RELY
) CLUSTER BY (UTL_ID);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ONG_Ongoing_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ONG_Ongoing_ID (
    ONG_ID tinyint not null,
     bit null,
    constraint pkONG_Ongoing_ID primary key (
        ONG_ID
    ) RELY
) CLUSTER BY (ONG_ID);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Ongoing_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ONG_Ongoing_EQ (
    ONG_ID tinyint not null,
    ONG_EQ tinyint not null,
    ONG_Ongoing varchar(3) not null,
     bit null,
    constraint fkONG_Ongoing_EQ foreign key (
        ONG_ID
    ) references public.ONG_Ongoing_ID(ONG_ID) RELY,
    constraint pkONG_Ongoing_EQ primary key (
        ONG_EQ,
        ONG_ID
    ) RELY,
    constraint uqONG_Ongoing_EQ unique (
        ONG_EQ,
        ONG_Ongoing
    ) RELY
) CLUSTER BY (ONG_ID);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- RAT_Rating_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.RAT_Rating_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.RAT_Rating_ID (
    RAT_ID tinyint default public.RAT_Rating_ID_SEQ.nextval not null, 
     bit null,
    constraint pkRAT_Rating_ID primary key (
        RAT_ID
    ) RELY
) CLUSTER BY (RAT_ID);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Rating_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.RAT_Rating_EQ (
    RAT_ID tinyint not null,
    RAT_EQ tinyint not null,
    RAT_Rating varchar(42) not null,
     bit null,
    constraint fkRAT_Rating_EQ foreign key (
        RAT_ID
    ) references public.RAT_Rating_ID(RAT_ID) RELY,
    constraint pkRAT_Rating_EQ primary key (
        RAT_EQ,
        RAT_ID
    ) RELY,
    constraint uqRAT_Rating_EQ unique (
        RAT_EQ,
        RAT_Rating
    ) RELY
) CLUSTER BY (RAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ETY_EventType (
    ETY_ID tinyint not null,
    ETY_EventType varchar(42) not null,
    constraint pkETY_EventType primary key (
        ETY_ID
    ) RELY,
    constraint uqETY_EventType unique (
        ETY_EventType
    ) RELY
) CLUSTER BY (ETY_ID);
