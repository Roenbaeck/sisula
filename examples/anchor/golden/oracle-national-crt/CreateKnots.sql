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
CREATE TABLE IF NOT EXISTS knots.PAT_Föräldratyp (
    PAT_ID number(3) not null,
    PAT_Föräldratyp nvarchar2(42) not null,
    Metadata_PAT number(10) not null,
    constraint pkPAT_Föräldratyp primary key (
        PAT_ID
    ),
    constraint uqPAT_Föräldratyp unique (
        PAT_Föräldratyp
    )
) CLUSTER BY (PAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Kön table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.GEN_Kön (
    GEN_ID number(3) not null,
    GEN_Kön nvarchar2(42) not null,
    GEN_Checksum numeric(19,0) default hash(GEN_Kön),
    Metadata_GEN number(10) not null,
    constraint pkGEN_Kön primary key (
        GEN_ID
    ),
    constraint uqGEN_Kön unique (
        GEN_Checksum 
    )
) CLUSTER BY (GEN_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.PLV_Yrkesnivå (
    PLV_ID number(3) not null,
    PLV_Yrkesnivå nclob not null,
    PLV_Checksum numeric(19,0) default hash(PLV_Yrkesnivå),
    Metadata_PLV number(10) not null,
    constraint pkPLV_Yrkesnivå primary key (
        PLV_ID
    ),
    constraint uqPLV_Yrkesnivå unique (
        PLV_Checksum 
    )
) CLUSTER BY (PLV_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utnyttjande table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.UTL_Utnyttjande (
    UTL_ID number(3) not null,
    UTL_Utnyttjande number(3) not null,
    Metadata_UTL number(10) not null,
    constraint pkUTL_Utnyttjande primary key (
        UTL_ID
    ),
    constraint uqUTL_Utnyttjande unique (
        UTL_Utnyttjande
    )
) CLUSTER BY (UTL_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Pågående table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.ONG_Pågående (
    ONG_ID number(3) not null,
    ONG_Pågående nvarchar2(3) not null,
    Metadata_ONG number(10) not null,
    constraint pkONG_Pågående primary key (
        ONG_ID
    ),
    constraint uqONG_Pågående unique (
        ONG_Pågående
    )
) CLUSTER BY (ONG_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Betyg table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.RAT_Betyg (
    RAT_ID number(3) IDENTITY(1,1) not null, 
    RAT_Betyg nvarchar2(42) not null,
    RAT_Checksum numeric(19,0) default hash(RAT_Betyg),
    Metadata_RAT number(10) not null,
    constraint pkRAT_Betyg primary key (
        RAT_ID
    ),
    constraint uqRAT_Betyg unique (
        RAT_Checksum 
    )
) CLUSTER BY (RAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.ETY_Händelsetyp (
    ETY_ID number(3) not null,
    ETY_Händelsetyp nvarchar2(42) not null,
    ETY_Checksum numeric(19,0) default hash(ETY_Händelsetyp),
    Metadata_ETY number(10) not null,
    constraint pkETY_Händelsetyp primary key (
        ETY_ID
    ),
    constraint uqETY_Händelsetyp unique (
        ETY_Checksum 
    )
) CLUSTER BY (ETY_ID);
