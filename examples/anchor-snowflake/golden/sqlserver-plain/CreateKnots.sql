-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_ParentalType table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PAT_ParentalType', 'U') IS NULL
CREATE TABLE [dbo].[PAT_ParentalType] (
    PAT_ID tinyint not null,
    PAT_ParentalType nvarchar(42) not null,
    constraint pkPAT_ParentalType primary key (
        PAT_ID asc
    ),
    constraint uqPAT_ParentalType unique (
        PAT_ParentalType
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.GEN_Gender', 'U') IS NULL
CREATE TABLE [dbo].[GEN_Gender] (
    GEN_ID tinyint not null,
    GEN_Gender nvarchar(42) not null,
    constraint pkGEN_Gender primary key (
        GEN_ID asc
    ),
    constraint uqGEN_Gender unique (
        GEN_Gender
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PLV_ProfessionalLevel', 'U') IS NULL
CREATE TABLE [dbo].[PLV_ProfessionalLevel] (
    PLV_ID tinyint not null,
    PLV_ProfessionalLevel nvarchar(max) not null,
    PLV_Checksum as cast(dbo.MD5(cast(PLV_ProfessionalLevel as varbinary(max))) as varbinary(16)) persisted,
    constraint pkPLV_ProfessionalLevel primary key (
        PLV_ID asc
    ),
    constraint uqPLV_ProfessionalLevel unique (
        PLV_Checksum 
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.UTL_Utilization', 'U') IS NULL
CREATE TABLE [dbo].[UTL_Utilization] (
    UTL_ID tinyint not null,
    UTL_Utilization tinyint not null,
    constraint pkUTL_Utilization primary key (
        UTL_ID asc
    ),
    constraint uqUTL_Utilization unique (
        UTL_Utilization
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ONG_Ongoing', 'U') IS NULL
CREATE TABLE [dbo].[ONG_Ongoing] (
    ONG_ID tinyint not null,
    ONG_Ongoing nvarchar(3) not null,
    constraint pkONG_Ongoing primary key (
        ONG_ID asc
    ),
    constraint uqONG_Ongoing unique (
        ONG_Ongoing
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.RAT_Rating', 'U') IS NULL
CREATE TABLE [dbo].[RAT_Rating] (
    RAT_ID tinyint not null,
    RAT_Rating nvarchar(42) not null,
    constraint pkRAT_Rating primary key (
        RAT_ID asc
    ),
    constraint uqRAT_Rating unique (
        RAT_Rating
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ETY_EventType', 'U') IS NULL
CREATE TABLE [dbo].[ETY_EventType] (
    ETY_ID tinyint not null,
    ETY_EventType nvarchar(42) not null,
    constraint pkETY_EventType primary key (
        ETY_ID asc
    ),
    constraint uqETY_EventType unique (
        ETY_EventType
    )
);
GO
