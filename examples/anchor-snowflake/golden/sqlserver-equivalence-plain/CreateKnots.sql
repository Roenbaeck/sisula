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
IF Object_ID('dbo.PAT_ParentalType_ID', 'U') IS NULL
CREATE TABLE [dbo].[PAT_ParentalType_ID] (
    PAT_ID tinyint IDENTITY(1,1) not null,
     bit null,
    constraint pkPAT_ParentalType_ID primary key (
        PAT_ID asc
    )
);
GO
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_ParentalType_EQ table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PAT_ParentalType_EQ', 'U') IS NULL
CREATE TABLE [dbo].[PAT_ParentalType_EQ] (
    PAT_ID tinyint not null,
    PAT_EQ tinyint not null,
    PAT_ParentalType nvarchar(42) not null,
     bit null,
    constraint fkPAT_ParentalType_EQ foreign key (
        PAT_ID
    ) references [dbo].[PAT_ParentalType_ID](PAT_ID),
    constraint pkPAT_ParentalType_EQ primary key (
        PAT_EQ asc,
        PAT_ID asc
    ),
    constraint uqPAT_ParentalType_EQ unique (
        PAT_EQ,
        PAT_ParentalType
    )
);
GO
-- Knot identity table ------------------------------------------------------------------------------------------------
-- GEN_Gender_ID table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.GEN_Gender_ID', 'U') IS NULL
CREATE TABLE [dbo].[GEN_Gender_ID] (
    GEN_ID tinyint not null,
     bit null,
    constraint pkGEN_Gender_ID primary key (
        GEN_ID asc
    )
);
GO
-- Knot value table ---------------------------------------------------------------------------------------------------
-- GEN_Gender_EQ table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.GEN_Gender_EQ', 'U') IS NULL
CREATE TABLE [dbo].[GEN_Gender_EQ] (
    GEN_ID tinyint not null,
    GEN_EQ tinyint not null,
    GEN_Gender nvarchar(42) not null,
     bit null,
    constraint fkGEN_Gender_EQ foreign key (
        GEN_ID
    ) references [dbo].[GEN_Gender_ID](GEN_ID),
    constraint pkGEN_Gender_EQ primary key (
        GEN_EQ asc,
        GEN_ID asc
    ),
    constraint uqGEN_Gender_EQ unique (
        GEN_EQ,
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
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ONG_Ongoing_ID table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ONG_Ongoing_ID', 'U') IS NULL
CREATE TABLE [dbo].[ONG_Ongoing_ID] (
    ONG_ID tinyint not null,
     bit null,
    constraint pkONG_Ongoing_ID primary key (
        ONG_ID asc
    )
);
GO
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Ongoing_EQ table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ONG_Ongoing_EQ', 'U') IS NULL
CREATE TABLE [dbo].[ONG_Ongoing_EQ] (
    ONG_ID tinyint not null,
    ONG_EQ tinyint not null,
    ONG_Ongoing nvarchar(3) not null,
     bit null,
    constraint fkONG_Ongoing_EQ foreign key (
        ONG_ID
    ) references [dbo].[ONG_Ongoing_ID](ONG_ID),
    constraint pkONG_Ongoing_EQ primary key (
        ONG_EQ asc,
        ONG_ID asc
    ),
    constraint uqONG_Ongoing_EQ unique (
        ONG_EQ,
        ONG_Ongoing
    )
);
GO
-- Knot identity table ------------------------------------------------------------------------------------------------
-- RAT_Rating_ID table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.RAT_Rating_ID', 'U') IS NULL
CREATE TABLE [dbo].[RAT_Rating_ID] (
    RAT_ID tinyint IDENTITY(1,1) not null,
     bit null,
    constraint pkRAT_Rating_ID primary key (
        RAT_ID asc
    )
);
GO
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Rating_EQ table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.RAT_Rating_EQ', 'U') IS NULL
CREATE TABLE [dbo].[RAT_Rating_EQ] (
    RAT_ID tinyint not null,
    RAT_EQ tinyint not null,
    RAT_Rating nvarchar(42) not null,
     bit null,
    constraint fkRAT_Rating_EQ foreign key (
        RAT_ID
    ) references [dbo].[RAT_Rating_ID](RAT_ID),
    constraint pkRAT_Rating_EQ primary key (
        RAT_EQ asc,
        RAT_ID asc
    ),
    constraint uqRAT_Rating_EQ unique (
        RAT_EQ,
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
