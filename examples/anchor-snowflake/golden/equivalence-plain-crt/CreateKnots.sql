-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_ParentalType table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.PAT_ParentalType_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PAT_ParentalType (
    PAT_ID tinyint default public.PAT_ParentalType_ID_SEQ.nextval not null, 
    PAT_ParentalType varchar(42) not null,
    constraint pkPAT_ParentalType primary key (
        PAT_ID 
    ) RELY,
    constraint uqPAT_ParentalType unique (
        PAT_ParentalType
    ) RELY
) CLUSTER BY (PAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.GEN_Gender (
    GEN_ID number(1,0) not null,
    GEN_Gender varchar(42) not null,
    constraint pkGEN_Gender primary key (
        GEN_ID 
    ) RELY,
    constraint uqGEN_Gender unique (
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
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ONG_Ongoing (
    ONG_ID tinyint not null,
    ONG_Ongoing varchar(3) not null,
    constraint pkONG_Ongoing primary key (
        ONG_ID 
    ) RELY,
    constraint uqONG_Ongoing unique (
        ONG_Ongoing
    ) RELY
) CLUSTER BY (ONG_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.RAT_Rating_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.RAT_Rating (
    RAT_ID tinyint default public.RAT_Rating_ID_SEQ.nextval not null, 
    RAT_Rating varchar(42) not null,
    constraint pkRAT_Rating primary key (
        RAT_ID 
    ) RELY,
    constraint uqRAT_Rating unique (
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
