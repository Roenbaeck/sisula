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
    Metadata_PAT int not null, 
    constraint pkPAT_ParentalType_ID primary key (
        PAT_ID
    )
) CLUSTER BY (PAT_ID);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_ParentalType_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PAT_ParentalType_EQ (
    PAT_ID tinyint not null,
    PAT_EQ tinyint not null,
    PAT_ParentalType varchar(42) not null,
    Metadata_PAT int not null, 
    constraint fkPAT_ParentalType_EQ foreign key (
        PAT_ID
    ) references public.PAT_ParentalType_ID(PAT_ID),
    constraint pkPAT_ParentalType_EQ primary key (
        PAT_EQ,
        PAT_ID
    ),
    constraint uqPAT_ParentalType_EQ unique (
        PAT_EQ,
        PAT_ParentalType
    )
) CLUSTER BY (PAT_ID);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- GEN_Gender_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.GEN_Gender_ID (
    GEN_ID number(1,0) not null,
    Metadata_GEN int not null, 
    constraint pkGEN_Gender_ID primary key (
        GEN_ID
    )
) CLUSTER BY (GEN_ID);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- GEN_Gender_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.GEN_Gender_EQ (
    GEN_ID number(1,0) not null,
    GEN_EQ tinyint not null,
    GEN_Gender varchar(42) not null,
    Metadata_GEN int not null, 
    constraint fkGEN_Gender_EQ foreign key (
        GEN_ID
    ) references public.GEN_Gender_ID(GEN_ID),
    constraint pkGEN_Gender_EQ primary key (
        GEN_EQ,
        GEN_ID
    ),
    constraint uqGEN_Gender_EQ unique (
        GEN_EQ,
        GEN_Gender
    )
) CLUSTER BY (GEN_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PLV_ProfessionalLevel (
    PLV_ID tinyint not null,
    PLV_ProfessionalLevel string not null,
    PLV_Checksum numeric(19,0) default hash(PLV_ProfessionalLevel),
    Metadata_PLV int not null,
    constraint pkPLV_ProfessionalLevel primary key (
        PLV_ID
    ),
    constraint uqPLV_ProfessionalLevel unique (
        PLV_Checksum 
    )
) CLUSTER BY (PLV_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.UTL_Utilization (
    UTL_ID tinyint not null,
    UTL_Utilization tinyint not null,
    Metadata_UTL int not null,
    constraint pkUTL_Utilization primary key (
        UTL_ID
    ),
    constraint uqUTL_Utilization unique (
        UTL_Utilization
    )
) CLUSTER BY (UTL_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ONG_Ongoing (
    ONG_ID tinyint not null,
    ONG_Ongoing varchar(3) not null,
    Metadata_ONG int not null,
    constraint pkONG_Ongoing primary key (
        ONG_ID
    ),
    constraint uqONG_Ongoing unique (
        ONG_Ongoing
    )
) CLUSTER BY (ONG_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.RAT_Rating_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.RAT_Rating (
    RAT_ID tinyint default public.RAT_Rating_ID_SEQ.nextval not null, 
    RAT_Rating varchar(42) not null,
    Metadata_RAT int not null,
    constraint pkRAT_Rating primary key (
        RAT_ID
    ),
    constraint uqRAT_Rating unique (
        RAT_Rating
    )
) CLUSTER BY (RAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ETY_EventType (
    ETY_ID tinyint not null,
    ETY_EventType varchar(42) not null,
    Metadata_ETY int not null,
    constraint pkETY_EventType primary key (
        ETY_ID
    ),
    constraint uqETY_EventType unique (
        ETY_EventType
    )
) CLUSTER BY (ETY_ID);
