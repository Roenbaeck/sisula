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
IF Object_ID('knots.PAT_ParentalType_ID', 'U') IS NULL
CREATE TABLE [knots].[PAT_ParentalType_ID] (
    PAT_ID tinyint not null,
    Metadata_PAT int not null, 
    constraint pkPAT_ParentalType_ID primary key (
        PAT_ID asc
    )
);
GO
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_ParentalType_EQ table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.PAT_ParentalType_EQ', 'U') IS NULL
CREATE TABLE [knots].[PAT_ParentalType_EQ] (
    PAT_ID tinyint not null,
    PAT_EQ tinyint not null,
    PAT_ParentalType nvarchar(42) not null,
    Metadata_PAT int not null, 
    constraint fkPAT_ParentalType_EQ foreign key (
        PAT_ID
    ) references [knots].[PAT_ParentalType_ID](PAT_ID),
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
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.GEN_Gender', 'U') IS NULL
CREATE TABLE [knots].[GEN_Gender] (
    GEN_ID tinyint not null,
    GEN_Gender nvarchar(42) not null,
    GEN_Checksum as cast(dw.MD5(cast(GEN_Gender as varbinary(max))) as varbinary(16)) persisted,
    Metadata_GEN int not null,
    constraint pkGEN_Gender primary key (
        GEN_ID asc
    ),
    constraint uqGEN_Gender unique (
        GEN_Checksum 
    )
);
GO
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel_ID table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.PLV_ProfessionalLevel_ID', 'U') IS NULL
CREATE TABLE [knots].[PLV_ProfessionalLevel_ID] (
    PLV_ID tinyint not null,
    Metadata_PLV int not null, 
    constraint pkPLV_ProfessionalLevel_ID primary key (
        PLV_ID asc
    )
);
GO
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel_EQ table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.PLV_ProfessionalLevel_EQ', 'U') IS NULL
CREATE TABLE [knots].[PLV_ProfessionalLevel_EQ] (
    PLV_ID tinyint not null,
    PLV_EQ tinyint not null,
    PLV_ProfessionalLevel nvarchar(max) not null,
    PLV_Checksum as cast(dw.MD5(cast(PLV_ProfessionalLevel as varbinary(max))) as varbinary(16)) persisted,
    Metadata_PLV int not null, 
    constraint fkPLV_ProfessionalLevel_EQ foreign key (
        PLV_ID
    ) references [knots].[PLV_ProfessionalLevel_ID](PLV_ID),
    constraint pkPLV_ProfessionalLevel_EQ primary key (
        PLV_EQ asc,
        PLV_ID asc
    ),
    constraint uqPLV_ProfessionalLevel_EQ unique (
        PLV_EQ,
        PLV_Checksum 
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.UTL_Utilization', 'U') IS NULL
CREATE TABLE [knots].[UTL_Utilization] (
    UTL_ID tinyint not null,
    UTL_Utilization tinyint not null,
    Metadata_UTL int not null,
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
IF Object_ID('knots.ONG_Ongoing_ID', 'U') IS NULL
CREATE TABLE [knots].[ONG_Ongoing_ID] (
    ONG_ID tinyint not null,
    Metadata_ONG int not null, 
    constraint pkONG_Ongoing_ID primary key (
        ONG_ID asc
    )
);
GO
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Ongoing_EQ table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.ONG_Ongoing_EQ', 'U') IS NULL
CREATE TABLE [knots].[ONG_Ongoing_EQ] (
    ONG_ID tinyint not null,
    ONG_EQ tinyint not null,
    ONG_Ongoing nvarchar(3) not null,
    Metadata_ONG int not null, 
    constraint fkONG_Ongoing_EQ foreign key (
        ONG_ID
    ) references [knots].[ONG_Ongoing_ID](ONG_ID),
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
IF Object_ID('knots.RAT_Rating_ID', 'U') IS NULL
CREATE TABLE [knots].[RAT_Rating_ID] (
    RAT_ID tinyint IDENTITY(1,1) not null,
    Metadata_RAT int not null, 
    constraint pkRAT_Rating_ID primary key (
        RAT_ID asc
    )
);
GO
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Rating_EQ table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.RAT_Rating_EQ', 'U') IS NULL
CREATE TABLE [knots].[RAT_Rating_EQ] (
    RAT_ID tinyint not null,
    RAT_EQ tinyint not null,
    RAT_Rating nvarchar(42) not null,
    RAT_Checksum as cast(dw.MD5(cast(RAT_Rating as varbinary(max))) as varbinary(16)) persisted,
    Metadata_RAT int not null, 
    constraint fkRAT_Rating_EQ foreign key (
        RAT_ID
    ) references [knots].[RAT_Rating_ID](RAT_ID),
    constraint pkRAT_Rating_EQ primary key (
        RAT_EQ asc,
        RAT_ID asc
    ),
    constraint uqRAT_Rating_EQ unique (
        RAT_EQ,
        RAT_Checksum 
    )
);
GO
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ETY_EventType_ID table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.ETY_EventType_ID', 'U') IS NULL
CREATE TABLE [knots].[ETY_EventType_ID] (
    ETY_ID tinyint not null,
    Metadata_ETY int not null, 
    constraint pkETY_EventType_ID primary key (
        ETY_ID asc
    )
);
GO
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ETY_EventType_EQ table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.ETY_EventType_EQ', 'U') IS NULL
CREATE TABLE [knots].[ETY_EventType_EQ] (
    ETY_ID tinyint not null,
    ETY_EQ tinyint not null,
    ETY_EventType nvarchar(42) not null,
    ETY_Checksum as cast(dw.MD5(cast(ETY_EventType as varbinary(max))) as varbinary(16)) persisted,
    Metadata_ETY int not null, 
    constraint fkETY_EventType_EQ foreign key (
        ETY_ID
    ) references [knots].[ETY_EventType_ID](ETY_ID),
    constraint pkETY_EventType_EQ primary key (
        ETY_EQ asc,
        ETY_ID asc
    ),
    constraint uqETY_EventType_EQ unique (
        ETY_EQ,
        ETY_Checksum 
    )
);
GO
