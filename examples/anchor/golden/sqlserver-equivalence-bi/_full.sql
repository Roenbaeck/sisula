-- CLR ----------------------------------------------------------------------------------------------------------------
--
-- The MD5 function is used to calculate hashes on which comparisons are made for data types that do
-- not support equality checking, and for which 'checksum' has been selected. The reason for not
-- using the built in HashBytes is that it is limited to inputs up to 8000 bytes.
--
-- MD5 function -------------------------------------------------------------------------------------------------------
-- MD5 hashing function
-----------------------------------------------------------------------------------------------------------------------
DECLARE @version smallint =
    CASE
        WHEN patindex('% 2[0-2][0-9][0-9] %', @@VERSION) > 0
        THEN substring(@@VERSION, patindex('% 2[0-2][0-9][0-9] %', @@VERSION) + 1, 4)
        ELSE 0
    END
IF Object_Id('dbo.MD5') IS NULL
BEGIN
    IF(@version >= 2016)
    BEGIN
        EXEC('
        CREATE FUNCTION dbo.MD5(@binaryData AS varbinary(max))
        RETURNS varbinary(16)
        WITH SCHEMABINDING AS
        BEGIN
            RETURN HASHBYTES(''MD5'', @binaryData)
        END
        ');
    END
    ELSE
    BEGIN
        -- since some version of 2017 assemblies must be explicitly whitelisted
        IF(@version >= 2017 AND OBJECT_ID('sys.sp_add_trusted_assembly') IS NOT NULL)
            IF NOT EXISTS(SELECT [hash] FROM sys.trusted_assemblies WHERE [hash] = 0x57C34E8101BA13D5E5132DCEDCBBFAE8E9DCBA2F679A47766F50E5E723970186593B3C8B55F93378A91D226D7BAC82DD95D4074D841F5DFB92AA53228334E636)
                EXEC sys.sp_add_trusted_assembly @hash = 0x57C34E8101BA13D5E5132DCEDCBBFAE8E9DCBA2F679A47766F50E5E723970186593B3C8B55F93378A91D226D7BAC82DD95D4074D841F5DFB92AA53228334E636, @description = N'Anchor';
        CREATE ASSEMBLY Anchor
        AUTHORIZATION dbo
        -- you can use the DLL instead if you substitute for your path:
        -- FROM 'path_to_Anchor.dll'
        -- or you can use the binary representation of the compiled code:
        FROM 0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000800000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000504500004C010300E7B633540000000000000000E00002210B010800000600000006000000000000CE2500000020000000400000000040000020000000020000040000000000000004000000000000000080000000020000000000000300408500001000001000000000100000100000000000001000000000000000000000007C2500004F00000000400000A002000000000000000000000000000000000000006000000C00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000080000000000000000000000082000004800000000000000000000002E74657874000000D4050000002000000006000000020000000000000000000000000000200000602E72737263000000A0020000004000000004000000080000000000000000000000000000400000402E72656C6F6300000C0000000060000000020000000C00000000000000000000000000004000004200000000000000000000000000000000B025000000000000480000000200050080200000FC040000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000096026F0400000A2D16280500000A026F0600000A6F0700000A730800000A2A14280900000A2A1E02280A00000A2A000042534A4201000100000000000C00000076322E302E35303732370000000005006C00000048010000237E0000B40100009001000023537472696E6773000000004403000008000000235553004C0300001000000023475549440000005C030000A001000023426C6F620000000000000002000001471500000900000000FA01330016000001000000090000000200000002000000010000000A00000003000000010000000200000000000A0001000000000006002F0028000A00570042000A00610042000600A30083000600C30083000A000301E800060040012301060055014B010600670123010000000001000000000001000100010010001500000005000100010050200000000096006A000A000100762000000000861872001100020000000100780021007200150029007200110031007200110019001801550139004401590119005C015E01490075016301110072006A0111008101700109007200110020001B001A002E000B0077012E0013008001048000000000000000000000000000000000E100000002000000000000000000000001001F000000000002000000000000000000000001003600000000000000003C4D6F64756C653E00416E63686F722E646C6C005574696C6974696573006D73636F726C69620053797374656D004F626A6563740053797374656D2E446174610053797374656D2E446174612E53716C54797065730053716C42696E6172790053716C427974657300486173684D4435002E63746F720062696E617279446174610053797374656D2E52756E74696D652E436F6D70696C6572536572766963657300436F6D70696C6174696F6E52656C61786174696F6E734174747269627574650052756E74696D65436F6D7061746962696C69747941747472696275746500416E63686F72004D6963726F736F66742E53716C5365727665722E5365727665720053716C46756E6374696F6E417474726962757465006765745F49734E756C6C0053797374656D2E53656375726974792E43727970746F677261706879004D4435004372656174650053797374656D2E494F0053747265616D006765745F53747265616D0048617368416C676F726974686D00436F6D7075746548617368006F705F496D706C69636974000000000003200000000000C7641B1E7755B04A8FCCCA2F22950BF30008B77A5C561934E0890600011109120D0320000104200101088139010003005455794D6963726F736F66742E53716C5365727665722E5365727665722E446174614163636573734B696E642C2053797374656D2E446174612C2056657273696F6E3D322E302E302E302C2043756C747572653D6E65757472616C2C205075626C69634B6579546F6B656E3D623737613563353631393334653038390A446174614163636573730000000054020F497344657465726D696E69737469630154557F4D6963726F736F66742E53716C5365727665722E5365727665722E53797374656D446174614163636573734B696E642C2053797374656D2E446174612C2056657273696F6E3D322E302E302E302C2043756C747572653D6E65757472616C2C205075626C69634B6579546F6B656E3D623737613563353631393334653038391053797374656D446174614163636573730000000003200002040000121D04200012210620011D051221052001011D0506000111091D050801000800000000001E01000100540216577261704E6F6E457863657074696F6E5468726F77730100A42500000000000000000000BE250000002000000000000000000000000000000000000000000000B0250000000000000000000000005F436F72446C6C4D61696E006D73636F7265652E646C6C0000000000FF2500204000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000001800008000000000000000000000000000000100010000003000008000000000000000000000000000000100000000004800000058400000440200000000000000000000440234000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100000000000000000000000000000000003F000000000000000400000002000000000000000000000000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000000B004A4010000010053007400720069006E006700460069006C00650049006E0066006F0000008001000001003000300030003000300034006200300000002C0002000100460069006C0065004400650073006300720069007000740069006F006E000000000020000000300008000100460069006C006500560065007200730069006F006E000000000030002E0030002E0030002E003000000038000B00010049006E007400650072006E0061006C004E0061006D006500000041006E00630068006F0072002E0064006C006C00000000002800020001004C006500670061006C0043006F00700079007200690067006800740000002000000040000B0001004F0072006900670069006E0061006C00460069006C0065006E0061006D006500000041006E00630068006F0072002E0064006C006C0000000000340008000100500072006F006400750063007400560065007200730069006F006E00000030002E0030002E0030002E003000000038000800010041007300730065006D0062006C0079002000560065007200730069006F006E00000030002E0030002E0030002E00300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000C000000D03500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
        WITH PERMISSION_SET = SAFE;
        EXEC('
        CREATE FUNCTION dbo.MD5(@binaryData AS varbinary(max))
        RETURNS varbinary(16) AS EXTERNAL NAME Anchor.Utilities.HashMD5
        ');
        EXEC sys.sp_configure 'clr enabled', 1;
        reconfigure with override;
    END
END
GO
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
IF Object_ID('dbo.PAT_ParentalType', 'U') IS NULL
CREATE TABLE [dbo].[PAT_ParentalType] (
    PAT_ID tinyint IDENTITY(1,1) not null,
    PAT_ParentalType nvarchar(42) not null,
    Metadata_PAT int not null,
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
    Metadata_GEN int not null,
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
    Metadata_PLV int not null,
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
    Metadata_UTL int not null,
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
    Metadata_ONG int not null,
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
    RAT_ID tinyint IDENTITY(1,1) not null,
    RAT_Rating nvarchar(42) not null,
    Metadata_RAT int not null,
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
    Metadata_ETY int not null,
    constraint pkETY_EventType primary key (
        ETY_ID asc
    ),
    constraint uqETY_EventType unique (
        ETY_EventType
    )
);
GO
-- ANCHORS -----------------------------------------------------------------------------------------------------------
--
-- Anchors store the identities of entities and are immutable.
-- (Attribute tables moved to CreateAttributes.js.)
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PN_Person', 'U') IS NULL
CREATE TABLE [dbo].[PN_Person] (
    PN_ID int IDENTITY(1,1) not null,
    Metadata_PN int not null,
    constraint pkPN_Person primary key (
        PN_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage', 'U') IS NULL
CREATE TABLE [dbo].[ST_Stage] (
    ST_ID int IDENTITY(1,1) not null,
    Metadata_ST int not null,
    constraint pkST_Stage primary key (
        ST_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_Actor', 'U') IS NULL
CREATE TABLE [dbo].[AC_Actor] (
    AC_ID int IDENTITY(1,1) not null,
    Metadata_AC int not null,
    constraint pkAC_Actor primary key (
        AC_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_Program', 'U') IS NULL
CREATE TABLE [dbo].[PR_Program] (
    PR_ID int IDENTITY(1,1) not null,
    Metadata_PR int not null,
    constraint pkPR_Program primary key (
        PR_ID asc
    )
);
GO
-- NEXUSES -----------------------------------------------------------------------------------------------------------
--
-- Nexuses (event-like constructs) store identities of composite event instances and are immutable.
-- (Attribute tables moved to CreateAttributes.js.)
--
-- Nexus table -------------------------------------------------------------------------------------------------------
-- EV_Event table (with 3 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_Event', 'U') IS NULL
CREATE TABLE [dbo].[EV_Event] (
    EV_ID int IDENTITY(1,1) not null,
    ST_ID_wasHeldAt int not null,
    PR_ID_wasPlayed int not null,
    ETY_ID_of tinyint not null,
    constraint EV_Event_fkST_wasHeldAt foreign key (
        ST_ID_wasHeldAt
    ) references [dbo].[ST_Stage](ST_ID),
    constraint EV_Event_fkPR_wasPlayed foreign key (
        PR_ID_wasPlayed
    ) references [dbo].[PR_Program](PR_ID),
    constraint EV_Event_fkETY_of foreign key (
        ETY_ID_of
    ) references [dbo].[ETY_EventType](ETY_ID),
    Metadata_EV int not null,
    constraint pkEV_Event primary key (
        EV_ID asc
    )
);
GO
-- ATTRIBUTES (UNIFIED FOR ANCHORS AND NEXUSES) ---------------------------------------------------------------------
--
-- Attributes are mutable properties attached to either anchors or nexuses.
-- Flavors: static, historized, knotted static, knotted historized.
-- This unified script creates all attribute tables (posits and annexes) using the global attribute iterator.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_DAT_Event_Date_Posit', 'U') IS NULL
CREATE TABLE [dbo].[EV_DAT_Event_Date_Posit] (
    EV_DAT_ID int IDENTITY(1,1) not null,
    EV_DAT_EV_ID int not null,
    EV_DAT_Event_Date datetime2 not null,
    constraint fkEV_DAT_Event_Date_Posit foreign key (
        EV_DAT_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_DAT_Event_Date_Posit primary key nonclustered (
        EV_DAT_ID asc
    ),
    constraint uqEV_DAT_Event_Date_Posit unique clustered (
        EV_DAT_EV_ID asc,
        EV_DAT_Event_Date asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Annex table (of EV_DAT_Event_Date_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_DAT_Event_Date_Annex', 'U') IS NULL
CREATE TABLE [dbo].[EV_DAT_Event_Date_Annex] (
    EV_DAT_ID int not null,
    EV_DAT_PositedAt datetime2 not null,
    EV_DAT_Reliability bit not null,
    Metadata_EV_DAT int not null,
    constraint fkEV_DAT_Event_Date_Annex foreign key (
        EV_DAT_ID
    ) references [dbo].[EV_DAT_Event_Date_Posit](EV_DAT_ID),
    constraint pkEV_DAT_Event_Date_Annex primary key clustered (
        EV_DAT_ID asc,
        EV_DAT_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_AUD_Event_Audience_Posit', 'U') IS NULL
CREATE TABLE [dbo].[EV_AUD_Event_Audience_Posit] (
    EV_AUD_ID int IDENTITY(1,1) not null,
    EV_AUD_EV_ID int not null,
    EV_AUD_Event_Audience int not null,
    constraint fkEV_AUD_Event_Audience_Posit foreign key (
        EV_AUD_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_AUD_Event_Audience_Posit primary key nonclustered (
        EV_AUD_ID asc
    ),
    constraint uqEV_AUD_Event_Audience_Posit unique clustered (
        EV_AUD_EV_ID asc,
        EV_AUD_Event_Audience asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Annex table (of EV_AUD_Event_Audience_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_AUD_Event_Audience_Annex', 'U') IS NULL
CREATE TABLE [dbo].[EV_AUD_Event_Audience_Annex] (
    EV_AUD_ID int not null,
    EV_AUD_PositedAt datetime2 not null,
    EV_AUD_Reliability bit not null,
    Metadata_EV_AUD int not null,
    constraint fkEV_AUD_Event_Audience_Annex foreign key (
        EV_AUD_ID
    ) references [dbo].[EV_AUD_Event_Audience_Posit](EV_AUD_ID),
    constraint pkEV_AUD_Event_Audience_Annex primary key clustered (
        EV_AUD_ID asc,
        EV_AUD_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_REV_Event_Revenue_Posit', 'U') IS NULL
CREATE TABLE [dbo].[EV_REV_Event_Revenue_Posit] (
    EV_REV_ID int IDENTITY(1,1) not null,
    EV_REV_EV_ID int not null,
    EV_REV_Event_Revenue decimal(19,4) not null,
    constraint fkEV_REV_Event_Revenue_Posit foreign key (
        EV_REV_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_REV_Event_Revenue_Posit primary key nonclustered (
        EV_REV_ID asc
    ),
    constraint uqEV_REV_Event_Revenue_Posit unique clustered (
        EV_REV_EV_ID asc,
        EV_REV_Event_Revenue asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Annex table (of EV_REV_Event_Revenue_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_REV_Event_Revenue_Annex', 'U') IS NULL
CREATE TABLE [dbo].[EV_REV_Event_Revenue_Annex] (
    EV_REV_ID int not null,
    EV_REV_PositedAt datetime2 not null,
    EV_REV_Reliability bit not null,
    Metadata_EV_REV int not null,
    constraint fkEV_REV_Event_Revenue_Annex foreign key (
        EV_REV_ID
    ) references [dbo].[EV_REV_Event_Revenue_Posit](EV_REV_ID),
    constraint pkEV_REV_Event_Revenue_Annex primary key clustered (
        EV_REV_ID asc,
        EV_REV_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_NAM_Stage_Name_Posit', 'U') IS NULL
CREATE TABLE [dbo].[ST_NAM_Stage_Name_Posit] (
    ST_NAM_ID int IDENTITY(1,1) not null,
    ST_NAM_ST_ID int not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    ST_NAM_Checksum as cast(dbo.MD5(cast(ST_NAM_Stage_Name as varbinary(max))) as varbinary(16)) persisted,
    ST_NAM_ChangedAt datetime2 not null,
    constraint fkST_NAM_Stage_Name_Posit foreign key (
        ST_NAM_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint pkST_NAM_Stage_Name_Posit primary key nonclustered (
        ST_NAM_ID asc
    ),
    constraint uqST_NAM_Stage_Name_Posit unique clustered (
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc,
        ST_NAM_Checksum asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Annex table (of ST_NAM_Stage_Name_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_NAM_Stage_Name_Annex', 'U') IS NULL
CREATE TABLE [dbo].[ST_NAM_Stage_Name_Annex] (
    ST_NAM_ID int not null,
    ST_NAM_PositedAt datetime2 not null,
    ST_NAM_Reliability bit not null,
    Metadata_ST_NAM int not null,
    constraint fkST_NAM_Stage_Name_Annex foreign key (
        ST_NAM_ID
    ) references [dbo].[ST_NAM_Stage_Name_Posit](ST_NAM_ID),
    constraint pkST_NAM_Stage_Name_Annex primary key clustered (
        ST_NAM_ID asc,
        ST_NAM_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_LOC_Stage_Location_Posit', 'U') IS NULL
CREATE TABLE [dbo].[ST_LOC_Stage_Location_Posit] (
    ST_LOC_ID int IDENTITY(1,1) not null,
    ST_LOC_ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum as cast(dbo.MD5(cast(ST_LOC_Stage_Location as varbinary(max))) as varbinary(16)) persisted,
    constraint fkST_LOC_Stage_Location_Posit foreign key (
        ST_LOC_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint pkST_LOC_Stage_Location_Posit primary key nonclustered (
        ST_LOC_ID asc
    ),
    constraint uqST_LOC_Stage_Location_Posit unique clustered (
        ST_LOC_ST_ID asc,
        ST_LOC_Checksum asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Annex table (of ST_LOC_Stage_Location_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_LOC_Stage_Location_Annex', 'U') IS NULL
CREATE TABLE [dbo].[ST_LOC_Stage_Location_Annex] (
    ST_LOC_ID int not null,
    ST_LOC_PositedAt datetime2 not null,
    ST_LOC_Reliability bit not null,
    Metadata_ST_LOC int not null,
    constraint fkST_LOC_Stage_Location_Annex foreign key (
        ST_LOC_ID
    ) references [dbo].[ST_LOC_Stage_Location_Posit](ST_LOC_ID),
    constraint pkST_LOC_Stage_Location_Annex primary key clustered (
        ST_LOC_ID asc,
        ST_LOC_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_AVG_Stage_Average_Posit', 'U') IS NULL
CREATE TABLE [dbo].[ST_AVG_Stage_Average_Posit] (
    ST_AVG_ID int IDENTITY(1,1) not null,
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime2 not null,
    constraint fk_A_ST_AVG_Stage_Average_Posit foreign key (
        ST_AVG_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint fk_K_ST_AVG_Stage_Average_Posit foreign key (
        ST_AVG_UTL_ID
    ) references [dbo].[UTL_Utilization](UTL_ID),
    constraint pkST_AVG_Stage_Average_Posit primary key nonclustered (
        ST_AVG_ID asc
    ),
    constraint uqST_AVG_Stage_Average_Posit unique clustered (
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc,
        ST_AVG_UTL_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Annex table (of ST_AVG_Stage_Average_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_AVG_Stage_Average_Annex', 'U') IS NULL
CREATE TABLE [dbo].[ST_AVG_Stage_Average_Annex] (
    ST_AVG_ID int not null,
    ST_AVG_PositedAt datetime2 not null,
    ST_AVG_Reliability bit not null,
    Metadata_ST_AVG int not null,
    constraint fkST_AVG_Stage_Average_Annex foreign key (
        ST_AVG_ID
    ) references [dbo].[ST_AVG_Stage_Average_Posit](ST_AVG_ID),
    constraint pkST_AVG_Stage_Average_Annex primary key clustered (
        ST_AVG_ID asc,
        ST_AVG_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_MIN_Stage_Minimum_Posit', 'U') IS NULL
CREATE TABLE [dbo].[ST_MIN_Stage_Minimum_Posit] (
    ST_MIN_ID int IDENTITY(1,1) not null,
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    constraint fk_A_ST_MIN_Stage_Minimum_Posit foreign key (
        ST_MIN_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum_Posit foreign key (
        ST_MIN_UTL_ID
    ) references [dbo].[UTL_Utilization](UTL_ID),
    constraint pkST_MIN_Stage_Minimum_Posit primary key nonclustered (
        ST_MIN_ID asc
    ),
    constraint uqST_MIN_Stage_Minimum_Posit unique clustered (
        ST_MIN_ST_ID asc,
        ST_MIN_UTL_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Annex table (of ST_MIN_Stage_Minimum_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_MIN_Stage_Minimum_Annex', 'U') IS NULL
CREATE TABLE [dbo].[ST_MIN_Stage_Minimum_Annex] (
    ST_MIN_ID int not null,
    ST_MIN_PositedAt datetime2 not null,
    ST_MIN_Reliability bit not null,
    Metadata_ST_MIN int not null,
    constraint fkST_MIN_Stage_Minimum_Annex foreign key (
        ST_MIN_ID
    ) references [dbo].[ST_MIN_Stage_Minimum_Posit](ST_MIN_ID),
    constraint pkST_MIN_Stage_Minimum_Annex primary key clustered (
        ST_MIN_ID asc,
        ST_MIN_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_NAM_Actor_Name_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_NAM_Actor_Name_Posit] (
    AC_NAM_ID int IDENTITY(1,1) not null,
    AC_NAM_AC_ID int not null,
    AC_NAM_Actor_Name nvarchar(42) not null,
    AC_NAM_Checksum as cast(dbo.MD5(cast(AC_NAM_Actor_Name as varbinary(max))) as varbinary(16)) persisted,
    AC_NAM_ChangedAt datetime2 not null,
    constraint fkAC_NAM_Actor_Name_Posit foreign key (
        AC_NAM_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint pkAC_NAM_Actor_Name_Posit primary key nonclustered (
        AC_NAM_ID asc
    ),
    constraint uqAC_NAM_Actor_Name_Posit unique clustered (
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc,
        AC_NAM_Checksum asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Annex table (of AC_NAM_Actor_Name_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_NAM_Actor_Name_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_NAM_Actor_Name_Annex] (
    AC_NAM_ID int not null,
    AC_NAM_PositedAt datetime2 not null,
    AC_NAM_Reliability bit not null,
    Metadata_AC_NAM int not null,
    constraint fkAC_NAM_Actor_Name_Annex foreign key (
        AC_NAM_ID
    ) references [dbo].[AC_NAM_Actor_Name_Posit](AC_NAM_ID),
    constraint pkAC_NAM_Actor_Name_Annex primary key clustered (
        AC_NAM_ID asc,
        AC_NAM_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_GEN_Actor_Gender_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_GEN_Actor_Gender_Posit] (
    AC_GEN_ID int IDENTITY(1,1) not null,
    AC_GEN_AC_ID int not null,
    AC_GEN_GEN_ID tinyint not null,
    constraint fk_A_AC_GEN_Actor_Gender_Posit foreign key (
        AC_GEN_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender_Posit foreign key (
        AC_GEN_GEN_ID
    ) references [dbo].[GEN_Gender](GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Posit primary key nonclustered (
        AC_GEN_ID asc
    ),
    constraint uqAC_GEN_Actor_Gender_Posit unique clustered (
        AC_GEN_AC_ID asc,
        AC_GEN_GEN_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Annex table (of AC_GEN_Actor_Gender_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_GEN_Actor_Gender_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_GEN_Actor_Gender_Annex] (
    AC_GEN_ID int not null,
    AC_GEN_PositedAt datetime2 not null,
    AC_GEN_Reliability bit not null,
    Metadata_AC_GEN int not null,
    constraint fkAC_GEN_Actor_Gender_Annex foreign key (
        AC_GEN_ID
    ) references [dbo].[AC_GEN_Actor_Gender_Posit](AC_GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Annex primary key clustered (
        AC_GEN_ID asc,
        AC_GEN_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_PLV_Actor_ProfessionalLevel_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] (
    AC_PLV_ID int IDENTITY(1,1) not null,
    AC_PLV_AC_ID int not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime2 not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        AC_PLV_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        AC_PLV_PLV_ID
    ) references [dbo].[PLV_ProfessionalLevel](PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Posit primary key nonclustered (
        AC_PLV_ID asc
    ),
    constraint uqAC_PLV_Actor_ProfessionalLevel_Posit unique clustered (
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc,
        AC_PLV_PLV_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Annex table (of AC_PLV_Actor_ProfessionalLevel_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_PLV_Actor_ProfessionalLevel_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] (
    AC_PLV_ID int not null,
    AC_PLV_PositedAt datetime2 not null,
    AC_PLV_Reliability bit not null,
    Metadata_AC_PLV int not null,
    constraint fkAC_PLV_Actor_ProfessionalLevel_Annex foreign key (
        AC_PLV_ID
    ) references [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit](AC_PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Annex primary key clustered (
        AC_PLV_ID asc,
        AC_PLV_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_NAM_Program_Name_Posit', 'U') IS NULL
CREATE TABLE [dbo].[PR_NAM_Program_Name_Posit] (
    PR_NAM_ID int IDENTITY(1,1) not null,
    PR_NAM_PR_ID int not null,
    PR_NAM_Program_Name nvarchar(42) not null,
    constraint fkPR_NAM_Program_Name_Posit foreign key (
        PR_NAM_PR_ID
    ) references [dbo].[PR_Program](PR_ID),
    constraint pkPR_NAM_Program_Name_Posit primary key nonclustered (
        PR_NAM_ID asc
    ),
    constraint uqPR_NAM_Program_Name_Posit unique clustered (
        PR_NAM_PR_ID asc,
        PR_NAM_Program_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Annex table (of PR_NAM_Program_Name_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_NAM_Program_Name_Annex', 'U') IS NULL
CREATE TABLE [dbo].[PR_NAM_Program_Name_Annex] (
    PR_NAM_ID int not null,
    PR_NAM_PositedAt datetime2 not null,
    PR_NAM_Reliability bit not null,
    Metadata_PR_NAM int not null,
    constraint fkPR_NAM_Program_Name_Annex foreign key (
        PR_NAM_ID
    ) references [dbo].[PR_NAM_Program_Name_Posit](PR_NAM_ID),
    constraint pkPR_NAM_Program_Name_Annex primary key clustered (
        PR_NAM_ID asc,
        PR_NAM_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_LEN_Program_Length_Posit', 'U') IS NULL
CREATE TABLE [dbo].[PR_LEN_Program_Length_Posit] (
    PR_LEN_ID int IDENTITY(1,1) not null,
    PR_LEN_PR_ID int not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length_Posit foreign key (
        PR_LEN_PR_ID
    ) references [dbo].[PR_Program](PR_ID),
    constraint pkPR_LEN_Program_Length_Posit primary key nonclustered (
        PR_LEN_ID asc
    ),
    constraint uqPR_LEN_Program_Length_Posit unique clustered (
        PR_LEN_PR_ID asc,
        PR_LEN_ChangedAt desc,
        PR_LEN_Program_Length asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Annex table (of PR_LEN_Program_Length_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_LEN_Program_Length_Annex', 'U') IS NULL
CREATE TABLE [dbo].[PR_LEN_Program_Length_Annex] (
    PR_LEN_ID int not null,
    PR_LEN_PositedAt datetime2 not null,
    PR_LEN_Reliability bit not null,
    Metadata_PR_LEN int not null,
    constraint fkPR_LEN_Program_Length_Annex foreign key (
        PR_LEN_ID
    ) references [dbo].[PR_LEN_Program_Length_Posit](PR_LEN_ID),
    constraint pkPR_LEN_Program_Length_Annex primary key clustered (
        PR_LEN_ID asc,
        PR_LEN_PositedAt desc
    )
);
GO
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines the posit and annex table of the attribute.
-- It can be used to maintain entity integrity through a primary key, which cannot be
-- defined elsewhere.
--
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date assembled view of the posit and annex tables,
-- pkEV_DAT_Event_Date optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_DAT_Event_Date', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_DAT_Event_Date]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_DAT,
        p.EV_DAT_ID,
        p.EV_DAT_EV_ID,
        p.EV_DAT_Event_Date,
        a.EV_DAT_PositedAt,
        a.EV_DAT_Reliability
    FROM
        [dbo].[EV_DAT_Event_Date_Posit] p
    JOIN
        [dbo].[EV_DAT_Event_Date_Annex] a
    ON
        a.EV_DAT_ID = p.EV_DAT_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_DAT_Event_Date]
    ON [dbo].[EV_DAT_Event_Date] (
        EV_DAT_EV_ID asc,
        EV_DAT_PositedAt desc,
        EV_DAT_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.EV_DAT_Event_Date', 'V')
    AND
        x.name = 'pkEV_DAT_Event_Date'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'EV_DAT_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_DAT_Event_Date]
    ON [dbo].[EV_DAT_Event_Date] (
        EV_DAT_EV_ID asc,
        EV_DAT_PositedAt desc,
        EV_DAT_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience assembled view of the posit and annex tables,
-- pkEV_AUD_Event_Audience optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_AUD_Event_Audience', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_AUD_Event_Audience]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_AUD,
        p.EV_AUD_ID,
        p.EV_AUD_EV_ID,
        p.EV_AUD_Event_Audience,
        a.EV_AUD_PositedAt,
        a.EV_AUD_Reliability
    FROM
        [dbo].[EV_AUD_Event_Audience_Posit] p
    JOIN
        [dbo].[EV_AUD_Event_Audience_Annex] a
    ON
        a.EV_AUD_ID = p.EV_AUD_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_AUD_Event_Audience]
    ON [dbo].[EV_AUD_Event_Audience] (
        EV_AUD_EV_ID asc,
        EV_AUD_PositedAt desc,
        EV_AUD_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.EV_AUD_Event_Audience', 'V')
    AND
        x.name = 'pkEV_AUD_Event_Audience'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'EV_AUD_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_AUD_Event_Audience]
    ON [dbo].[EV_AUD_Event_Audience] (
        EV_AUD_EV_ID asc,
        EV_AUD_PositedAt desc,
        EV_AUD_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue assembled view of the posit and annex tables,
-- pkEV_REV_Event_Revenue optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_REV_Event_Revenue', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_REV_Event_Revenue]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_REV,
        p.EV_REV_ID,
        p.EV_REV_EV_ID,
        p.EV_REV_Event_Revenue,
        a.EV_REV_PositedAt,
        a.EV_REV_Reliability
    FROM
        [dbo].[EV_REV_Event_Revenue_Posit] p
    JOIN
        [dbo].[EV_REV_Event_Revenue_Annex] a
    ON
        a.EV_REV_ID = p.EV_REV_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_REV_Event_Revenue]
    ON [dbo].[EV_REV_Event_Revenue] (
        EV_REV_EV_ID asc,
        EV_REV_PositedAt desc,
        EV_REV_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.EV_REV_Event_Revenue', 'V')
    AND
        x.name = 'pkEV_REV_Event_Revenue'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'EV_REV_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_REV_Event_Revenue]
    ON [dbo].[EV_REV_Event_Revenue] (
        EV_REV_EV_ID asc,
        EV_REV_PositedAt desc,
        EV_REV_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name assembled view of the posit and annex tables,
-- pkST_NAM_Stage_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_NAM_Stage_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[ST_NAM_Stage_Name]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_ST_NAM,
        p.ST_NAM_ID,
        p.ST_NAM_ST_ID,
        p.ST_NAM_Checksum,
        p.ST_NAM_Stage_Name,
        p.ST_NAM_ChangedAt,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Reliability
    FROM
        [dbo].[ST_NAM_Stage_Name_Posit] p
    JOIN
        [dbo].[ST_NAM_Stage_Name_Annex] a
    ON
        a.ST_NAM_ID = p.ST_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_NAM_Stage_Name]
    ON [dbo].[ST_NAM_Stage_Name] (
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc,
        ST_NAM_PositedAt desc,
        ST_NAM_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.ST_NAM_Stage_Name', 'V')
    AND
        x.name = 'pkST_NAM_Stage_Name'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'ST_NAM_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_NAM_Stage_Name]
    ON [dbo].[ST_NAM_Stage_Name] (
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc,
        ST_NAM_PositedAt desc,
        ST_NAM_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location assembled view of the posit and annex tables,
-- pkST_LOC_Stage_Location optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_LOC_Stage_Location', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[ST_LOC_Stage_Location]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_ST_LOC,
        p.ST_LOC_ID,
        p.ST_LOC_ST_ID,
        p.ST_LOC_Checksum,
        p.ST_LOC_Stage_Location,
        a.ST_LOC_PositedAt,
        a.ST_LOC_Reliability
    FROM
        [dbo].[ST_LOC_Stage_Location_Posit] p
    JOIN
        [dbo].[ST_LOC_Stage_Location_Annex] a
    ON
        a.ST_LOC_ID = p.ST_LOC_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_LOC_Stage_Location]
    ON [dbo].[ST_LOC_Stage_Location] (
        ST_LOC_ST_ID asc,
        ST_LOC_PositedAt desc,
        ST_LOC_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.ST_LOC_Stage_Location', 'V')
    AND
        x.name = 'pkST_LOC_Stage_Location'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'ST_LOC_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_LOC_Stage_Location]
    ON [dbo].[ST_LOC_Stage_Location] (
        ST_LOC_ST_ID asc,
        ST_LOC_PositedAt desc,
        ST_LOC_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average assembled view of the posit and annex tables,
-- pkST_AVG_Stage_Average optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_AVG_Stage_Average', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[ST_AVG_Stage_Average]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_ST_AVG,
        p.ST_AVG_ID,
        p.ST_AVG_ST_ID,
        p.ST_AVG_UTL_ID,
        p.ST_AVG_ChangedAt,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Reliability
    FROM
        [dbo].[ST_AVG_Stage_Average_Posit] p
    JOIN
        [dbo].[ST_AVG_Stage_Average_Annex] a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_AVG_Stage_Average]
    ON [dbo].[ST_AVG_Stage_Average] (
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc,
        ST_AVG_PositedAt desc,
        ST_AVG_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.ST_AVG_Stage_Average', 'V')
    AND
        x.name = 'pkST_AVG_Stage_Average'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'ST_AVG_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_AVG_Stage_Average]
    ON [dbo].[ST_AVG_Stage_Average] (
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc,
        ST_AVG_PositedAt desc,
        ST_AVG_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum assembled view of the posit and annex tables,
-- pkST_MIN_Stage_Minimum optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_MIN_Stage_Minimum', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[ST_MIN_Stage_Minimum]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_ST_MIN,
        p.ST_MIN_ID,
        p.ST_MIN_ST_ID,
        p.ST_MIN_UTL_ID,
        a.ST_MIN_PositedAt,
        a.ST_MIN_Reliability
    FROM
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    JOIN
        [dbo].[ST_MIN_Stage_Minimum_Annex] a
    ON
        a.ST_MIN_ID = p.ST_MIN_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_MIN_Stage_Minimum]
    ON [dbo].[ST_MIN_Stage_Minimum] (
        ST_MIN_ST_ID asc,
        ST_MIN_PositedAt desc,
        ST_MIN_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.ST_MIN_Stage_Minimum', 'V')
    AND
        x.name = 'pkST_MIN_Stage_Minimum'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'ST_MIN_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_MIN_Stage_Minimum]
    ON [dbo].[ST_MIN_Stage_Minimum] (
        ST_MIN_ST_ID asc,
        ST_MIN_PositedAt desc,
        ST_MIN_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name assembled view of the posit and annex tables,
-- pkAC_NAM_Actor_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_NAM_Actor_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[AC_NAM_Actor_Name]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_NAM,
        p.AC_NAM_ID,
        p.AC_NAM_AC_ID,
        p.AC_NAM_Checksum,
        p.AC_NAM_Actor_Name,
        p.AC_NAM_ChangedAt,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Reliability
    FROM
        [dbo].[AC_NAM_Actor_Name_Posit] p
    JOIN
        [dbo].[AC_NAM_Actor_Name_Annex] a
    ON
        a.AC_NAM_ID = p.AC_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_NAM_Actor_Name]
    ON [dbo].[AC_NAM_Actor_Name] (
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc,
        AC_NAM_PositedAt desc,
        AC_NAM_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.AC_NAM_Actor_Name', 'V')
    AND
        x.name = 'pkAC_NAM_Actor_Name'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'AC_NAM_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_NAM_Actor_Name]
    ON [dbo].[AC_NAM_Actor_Name] (
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc,
        AC_NAM_PositedAt desc,
        AC_NAM_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender assembled view of the posit and annex tables,
-- pkAC_GEN_Actor_Gender optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_GEN_Actor_Gender', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[AC_GEN_Actor_Gender]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_GEN,
        p.AC_GEN_ID,
        p.AC_GEN_AC_ID,
        p.AC_GEN_GEN_ID,
        a.AC_GEN_PositedAt,
        a.AC_GEN_Reliability
    FROM
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    JOIN
        [dbo].[AC_GEN_Actor_Gender_Annex] a
    ON
        a.AC_GEN_ID = p.AC_GEN_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_GEN_Actor_Gender]
    ON [dbo].[AC_GEN_Actor_Gender] (
        AC_GEN_AC_ID asc,
        AC_GEN_PositedAt desc,
        AC_GEN_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.AC_GEN_Actor_Gender', 'V')
    AND
        x.name = 'pkAC_GEN_Actor_Gender'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'AC_GEN_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_GEN_Actor_Gender]
    ON [dbo].[AC_GEN_Actor_Gender] (
        AC_GEN_AC_ID asc,
        AC_GEN_PositedAt desc,
        AC_GEN_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel assembled view of the posit and annex tables,
-- pkAC_PLV_Actor_ProfessionalLevel optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_PLV_Actor_ProfessionalLevel', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[AC_PLV_Actor_ProfessionalLevel]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_PLV,
        p.AC_PLV_ID,
        p.AC_PLV_AC_ID,
        p.AC_PLV_PLV_ID,
        p.AC_PLV_ChangedAt,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Reliability
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    JOIN
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
    ON
        a.AC_PLV_ID = p.AC_PLV_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_PLV_Actor_ProfessionalLevel]
    ON [dbo].[AC_PLV_Actor_ProfessionalLevel] (
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc,
        AC_PLV_PositedAt desc,
        AC_PLV_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.AC_PLV_Actor_ProfessionalLevel', 'V')
    AND
        x.name = 'pkAC_PLV_Actor_ProfessionalLevel'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'AC_PLV_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_PLV_Actor_ProfessionalLevel]
    ON [dbo].[AC_PLV_Actor_ProfessionalLevel] (
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc,
        AC_PLV_PositedAt desc,
        AC_PLV_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name assembled view of the posit and annex tables,
-- pkPR_NAM_Program_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_NAM_Program_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[PR_NAM_Program_Name]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_PR_NAM,
        p.PR_NAM_ID,
        p.PR_NAM_PR_ID,
        p.PR_NAM_Program_Name,
        a.PR_NAM_PositedAt,
        a.PR_NAM_Reliability
    FROM
        [dbo].[PR_NAM_Program_Name_Posit] p
    JOIN
        [dbo].[PR_NAM_Program_Name_Annex] a
    ON
        a.PR_NAM_ID = p.PR_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_NAM_Program_Name]
    ON [dbo].[PR_NAM_Program_Name] (
        PR_NAM_PR_ID asc,
        PR_NAM_PositedAt desc,
        PR_NAM_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.PR_NAM_Program_Name', 'V')
    AND
        x.name = 'pkPR_NAM_Program_Name'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'PR_NAM_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_NAM_Program_Name]
    ON [dbo].[PR_NAM_Program_Name] (
        PR_NAM_PR_ID asc,
        PR_NAM_PositedAt desc,
        PR_NAM_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length assembled view of the posit and annex tables,
-- pkPR_LEN_Program_Length optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_LEN_Program_Length', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[PR_LEN_Program_Length]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_PR_LEN,
        p.PR_LEN_ID,
        p.PR_LEN_PR_ID,
        p.PR_LEN_Program_Length,
        p.PR_LEN_ChangedAt,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Reliability
    FROM
        [dbo].[PR_LEN_Program_Length_Posit] p
    JOIN
        [dbo].[PR_LEN_Program_Length_Annex] a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_LEN_Program_Length]
    ON [dbo].[PR_LEN_Program_Length] (
        PR_LEN_PR_ID asc,
        PR_LEN_ChangedAt desc,
        PR_LEN_PositedAt desc,
        PR_LEN_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.PR_LEN_Program_Length', 'V')
    AND
        x.name = 'pkPR_LEN_Program_Length'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'PR_LEN_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_LEN_Program_Length]
    ON [dbo].[PR_LEN_Program_Length] (
        PR_LEN_PR_ID asc,
        PR_LEN_ChangedAt desc,
        PR_LEN_PositedAt desc,
        PR_LEN_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the
-- union of the two will produce all rows in a posit table.
--
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_DAT_Event_Date_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_DAT_Event_Date_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_DAT_Event_Date_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    FROM
        [dbo].[EV_DAT_Event_Date_Annex]
    WHERE
        EV_DAT_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_DAT_Event_Date rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_DAT_Event_Date','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_DAT_Event_Date] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_DAT,
        p.EV_DAT_ID,
        a.EV_DAT_PositedAt,
        a.EV_DAT_Reliability,
        p.EV_DAT_EV_ID,
        p.EV_DAT_Event_Date
    FROM
        [dbo].[EV_DAT_Event_Date_Posit] p
    JOIN
        [dbo].[rEV_DAT_Event_Date_Annex](@positingTimepoint) a
    ON
        a.EV_DAT_ID = p.EV_DAT_ID
    AND
        a.EV_DAT_PositedAt = (
            SELECT TOP 1
                sub.EV_DAT_PositedAt
            FROM
                [dbo].[rEV_DAT_Event_Date_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_DAT_ID = p.EV_DAT_ID
            ORDER BY
                sub.EV_DAT_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_AUD_Event_Audience_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_AUD_Event_Audience_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_AUD_Event_Audience_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    FROM
        [dbo].[EV_AUD_Event_Audience_Annex]
    WHERE
        EV_AUD_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_AUD_Event_Audience rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_AUD_Event_Audience','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_AUD_Event_Audience] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_AUD,
        p.EV_AUD_ID,
        a.EV_AUD_PositedAt,
        a.EV_AUD_Reliability,
        p.EV_AUD_EV_ID,
        p.EV_AUD_Event_Audience
    FROM
        [dbo].[EV_AUD_Event_Audience_Posit] p
    JOIN
        [dbo].[rEV_AUD_Event_Audience_Annex](@positingTimepoint) a
    ON
        a.EV_AUD_ID = p.EV_AUD_ID
    AND
        a.EV_AUD_PositedAt = (
            SELECT TOP 1
                sub.EV_AUD_PositedAt
            FROM
                [dbo].[rEV_AUD_Event_Audience_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_AUD_ID = p.EV_AUD_ID
            ORDER BY
                sub.EV_AUD_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_REV_Event_Revenue_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_REV_Event_Revenue_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_REV_Event_Revenue_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    FROM
        [dbo].[EV_REV_Event_Revenue_Annex]
    WHERE
        EV_REV_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_REV_Event_Revenue rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_REV_Event_Revenue','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_REV_Event_Revenue] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_REV,
        p.EV_REV_ID,
        a.EV_REV_PositedAt,
        a.EV_REV_Reliability,
        p.EV_REV_EV_ID,
        p.EV_REV_Event_Revenue
    FROM
        [dbo].[EV_REV_Event_Revenue_Posit] p
    JOIN
        [dbo].[rEV_REV_Event_Revenue_Annex](@positingTimepoint) a
    ON
        a.EV_REV_ID = p.EV_REV_ID
    AND
        a.EV_REV_PositedAt = (
            SELECT TOP 1
                sub.EV_REV_PositedAt
            FROM
                [dbo].[rEV_REV_Event_Revenue_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_REV_ID = p.EV_REV_ID
            ORDER BY
                sub.EV_REV_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_NAM_Stage_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_NAM_Stage_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_NAM_ID,
        ST_NAM_ST_ID,
        ST_NAM_Checksum,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        [dbo].[ST_NAM_Stage_Name_Posit]
    WHERE
        ST_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fST_NAM_Stage_Name_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_NAM_Stage_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_NAM_Stage_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_NAM_ID,
        ST_NAM_ST_ID,
        ST_NAM_Checksum,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        [dbo].[ST_NAM_Stage_Name_Posit]
    WHERE
        ST_NAM_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_NAM_Stage_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_NAM_Stage_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    FROM
        [dbo].[ST_NAM_Stage_Name_Annex]
    WHERE
        ST_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_NAM_Stage_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_NAM_Stage_Name] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_NAM,
        p.ST_NAM_ID,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Reliability,
        p.ST_NAM_ST_ID,
        p.ST_NAM_Checksum,
        p.ST_NAM_Stage_Name,
        p.ST_NAM_ChangedAt
    FROM
        [dbo].[rST_NAM_Stage_Name_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rST_NAM_Stage_Name_Annex](@positingTimepoint) a
    ON
        a.ST_NAM_ID = p.ST_NAM_ID
    AND
        a.ST_NAM_PositedAt = (
            SELECT TOP 1
                sub.ST_NAM_PositedAt
            FROM
                [dbo].[rST_NAM_Stage_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_NAM_ID = p.ST_NAM_ID
            ORDER BY
                sub.ST_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fST_NAM_Stage_Name forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_NAM_Stage_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_NAM_Stage_Name] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_NAM,
        p.ST_NAM_ID,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Reliability,
        p.ST_NAM_ST_ID,
        p.ST_NAM_Checksum,
        p.ST_NAM_Stage_Name,
        p.ST_NAM_ChangedAt
    FROM
        [dbo].[fST_NAM_Stage_Name_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rST_NAM_Stage_Name_Annex](@positingTimepoint) a
    ON
        a.ST_NAM_ID = p.ST_NAM_ID
    AND
        a.ST_NAM_PositedAt = (
            SELECT TOP 1
                sub.ST_NAM_PositedAt
            FROM
                [dbo].[rST_NAM_Stage_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_NAM_ID = p.ST_NAM_ID
            ORDER BY
                sub.ST_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preST_NAM_Stage_Name function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preST_NAM_Stage_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preST_NAM_Stage_Name] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS varbinary(16)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.ST_NAM_Checksum
        FROM
            [dbo].[rST_NAM_Stage_Name](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.ST_NAM_ST_ID = @id
        AND
            pre.ST_NAM_ChangedAt < @changingTimepoint
        AND
            pre.ST_NAM_Reliability = 1
        ORDER BY
            pre.ST_NAM_ChangedAt DESC,
            pre.ST_NAM_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folST_NAM_Stage_Name function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folST_NAM_Stage_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folST_NAM_Stage_Name] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS varbinary(16)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.ST_NAM_Checksum
        FROM
            [dbo].[fST_NAM_Stage_Name](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.ST_NAM_ST_ID = @id
        AND
            fol.ST_NAM_ChangedAt > @changingTimepoint
        AND
            fol.ST_NAM_Reliability = 1
        ORDER BY
            fol.ST_NAM_ChangedAt ASC,
            fol.ST_NAM_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rST_LOC_Stage_Location_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_LOC_Stage_Location_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_LOC_Stage_Location_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    FROM
        [dbo].[ST_LOC_Stage_Location_Annex]
    WHERE
        ST_LOC_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_LOC_Stage_Location rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_LOC_Stage_Location','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_LOC_Stage_Location] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_LOC,
        p.ST_LOC_ID,
        a.ST_LOC_PositedAt,
        a.ST_LOC_Reliability,
        p.ST_LOC_ST_ID,
        p.ST_LOC_Checksum,
        p.ST_LOC_Stage_Location
    FROM
        [dbo].[ST_LOC_Stage_Location_Posit] p
    JOIN
        [dbo].[rST_LOC_Stage_Location_Annex](@positingTimepoint) a
    ON
        a.ST_LOC_ID = p.ST_LOC_ID
    AND
        a.ST_LOC_PositedAt = (
            SELECT TOP 1
                sub.ST_LOC_PositedAt
            FROM
                [dbo].[rST_LOC_Stage_Location_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_LOC_ID = p.ST_LOC_ID
            ORDER BY
                sub.ST_LOC_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_AVG_Stage_Average_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_AVG_Stage_Average_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_AVG_ID,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt
    FROM
        [dbo].[ST_AVG_Stage_Average_Posit]
    WHERE
        ST_AVG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fST_AVG_Stage_Average_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_AVG_Stage_Average_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_AVG_Stage_Average_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_AVG_ID,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt
    FROM
        [dbo].[ST_AVG_Stage_Average_Posit]
    WHERE
        ST_AVG_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_AVG_Stage_Average_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_AVG_Stage_Average_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    FROM
        [dbo].[ST_AVG_Stage_Average_Annex]
    WHERE
        ST_AVG_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_AVG_Stage_Average','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_AVG_Stage_Average] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_AVG,
        p.ST_AVG_ID,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Reliability,
        p.ST_AVG_ST_ID,
        p.ST_AVG_UTL_ID,
        p.ST_AVG_ChangedAt
    FROM
        [dbo].[rST_AVG_Stage_Average_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rST_AVG_Stage_Average_Annex](@positingTimepoint) a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = (
            SELECT TOP 1
                sub.ST_AVG_PositedAt
            FROM
                [dbo].[rST_AVG_Stage_Average_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_AVG_ID = p.ST_AVG_ID
            ORDER BY
                sub.ST_AVG_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fST_AVG_Stage_Average forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_AVG_Stage_Average','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_AVG_Stage_Average] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_AVG,
        p.ST_AVG_ID,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Reliability,
        p.ST_AVG_ST_ID,
        p.ST_AVG_UTL_ID,
        p.ST_AVG_ChangedAt
    FROM
        [dbo].[fST_AVG_Stage_Average_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rST_AVG_Stage_Average_Annex](@positingTimepoint) a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = (
            SELECT TOP 1
                sub.ST_AVG_PositedAt
            FROM
                [dbo].[rST_AVG_Stage_Average_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_AVG_ID = p.ST_AVG_ID
            ORDER BY
                sub.ST_AVG_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preST_AVG_Stage_Average function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preST_AVG_Stage_Average','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preST_AVG_Stage_Average] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.ST_AVG_UTL_ID
        FROM
            [dbo].[rST_AVG_Stage_Average](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.ST_AVG_ST_ID = @id
        AND
            pre.ST_AVG_ChangedAt < @changingTimepoint
        AND
            pre.ST_AVG_Reliability = 1
        ORDER BY
            pre.ST_AVG_ChangedAt DESC,
            pre.ST_AVG_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folST_AVG_Stage_Average function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folST_AVG_Stage_Average','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folST_AVG_Stage_Average] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.ST_AVG_UTL_ID
        FROM
            [dbo].[fST_AVG_Stage_Average](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.ST_AVG_ST_ID = @id
        AND
            fol.ST_AVG_ChangedAt > @changingTimepoint
        AND
            fol.ST_AVG_Reliability = 1
        ORDER BY
            fol.ST_AVG_ChangedAt ASC,
            fol.ST_AVG_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rST_MIN_Stage_Minimum_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_MIN_Stage_Minimum_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_MIN_Stage_Minimum_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    FROM
        [dbo].[ST_MIN_Stage_Minimum_Annex]
    WHERE
        ST_MIN_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_MIN_Stage_Minimum rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_MIN_Stage_Minimum','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_MIN_Stage_Minimum] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_MIN,
        p.ST_MIN_ID,
        a.ST_MIN_PositedAt,
        a.ST_MIN_Reliability,
        p.ST_MIN_ST_ID,
        p.ST_MIN_UTL_ID
    FROM
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    JOIN
        [dbo].[rST_MIN_Stage_Minimum_Annex](@positingTimepoint) a
    ON
        a.ST_MIN_ID = p.ST_MIN_ID
    AND
        a.ST_MIN_PositedAt = (
            SELECT TOP 1
                sub.ST_MIN_PositedAt
            FROM
                [dbo].[rST_MIN_Stage_Minimum_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_MIN_ID = p.ST_MIN_ID
            ORDER BY
                sub.ST_MIN_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_NAM_Actor_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_NAM_Actor_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_NAM_ID,
        AC_NAM_AC_ID,
        AC_NAM_Checksum,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        [dbo].[AC_NAM_Actor_Name_Posit]
    WHERE
        AC_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fAC_NAM_Actor_Name_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_NAM_Actor_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_NAM_Actor_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_NAM_ID,
        AC_NAM_AC_ID,
        AC_NAM_Checksum,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        [dbo].[AC_NAM_Actor_Name_Posit]
    WHERE
        AC_NAM_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_NAM_Actor_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_NAM_Actor_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    FROM
        [dbo].[AC_NAM_Actor_Name_Annex]
    WHERE
        AC_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_NAM_Actor_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_NAM_Actor_Name] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_NAM,
        p.AC_NAM_ID,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Reliability,
        p.AC_NAM_AC_ID,
        p.AC_NAM_Checksum,
        p.AC_NAM_Actor_Name,
        p.AC_NAM_ChangedAt
    FROM
        [dbo].[rAC_NAM_Actor_Name_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) a
    ON
        a.AC_NAM_ID = p.AC_NAM_ID
    AND
        a.AC_NAM_PositedAt = (
            SELECT TOP 1
                sub.AC_NAM_PositedAt
            FROM
                [dbo].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_NAM_ID = p.AC_NAM_ID
            ORDER BY
                sub.AC_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fAC_NAM_Actor_Name forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_NAM_Actor_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_NAM_Actor_Name] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_NAM,
        p.AC_NAM_ID,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Reliability,
        p.AC_NAM_AC_ID,
        p.AC_NAM_Checksum,
        p.AC_NAM_Actor_Name,
        p.AC_NAM_ChangedAt
    FROM
        [dbo].[fAC_NAM_Actor_Name_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) a
    ON
        a.AC_NAM_ID = p.AC_NAM_ID
    AND
        a.AC_NAM_PositedAt = (
            SELECT TOP 1
                sub.AC_NAM_PositedAt
            FROM
                [dbo].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_NAM_ID = p.AC_NAM_ID
            ORDER BY
                sub.AC_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preAC_NAM_Actor_Name function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preAC_NAM_Actor_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preAC_NAM_Actor_Name] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS varbinary(16)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.AC_NAM_Checksum
        FROM
            [dbo].[rAC_NAM_Actor_Name](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.AC_NAM_AC_ID = @id
        AND
            pre.AC_NAM_ChangedAt < @changingTimepoint
        AND
            pre.AC_NAM_Reliability = 1
        ORDER BY
            pre.AC_NAM_ChangedAt DESC,
            pre.AC_NAM_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folAC_NAM_Actor_Name function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folAC_NAM_Actor_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folAC_NAM_Actor_Name] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS varbinary(16)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.AC_NAM_Checksum
        FROM
            [dbo].[fAC_NAM_Actor_Name](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.AC_NAM_AC_ID = @id
        AND
            fol.AC_NAM_ChangedAt > @changingTimepoint
        AND
            fol.AC_NAM_Reliability = 1
        ORDER BY
            fol.AC_NAM_ChangedAt ASC,
            fol.AC_NAM_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rAC_GEN_Actor_Gender_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_GEN_Actor_Gender_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_GEN_Actor_Gender_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    FROM
        [dbo].[AC_GEN_Actor_Gender_Annex]
    WHERE
        AC_GEN_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rAC_GEN_Actor_Gender rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_GEN_Actor_Gender','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_GEN_Actor_Gender] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_GEN,
        p.AC_GEN_ID,
        a.AC_GEN_PositedAt,
        a.AC_GEN_Reliability,
        p.AC_GEN_AC_ID,
        p.AC_GEN_GEN_ID
    FROM
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    JOIN
        [dbo].[rAC_GEN_Actor_Gender_Annex](@positingTimepoint) a
    ON
        a.AC_GEN_ID = p.AC_GEN_ID
    AND
        a.AC_GEN_PositedAt = (
            SELECT TOP 1
                sub.AC_GEN_PositedAt
            FROM
                [dbo].[rAC_GEN_Actor_Gender_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_GEN_ID = p.AC_GEN_ID
            ORDER BY
                sub.AC_GEN_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_PLV_Actor_ProfessionalLevel_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_PLV_Actor_ProfessionalLevel_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_PLV_ID,
        AC_PLV_AC_ID,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit]
    WHERE
        AC_PLV_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fAC_PLV_Actor_ProfessionalLevel_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_PLV_Actor_ProfessionalLevel_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_PLV_Actor_ProfessionalLevel_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_PLV_ID,
        AC_PLV_AC_ID,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit]
    WHERE
        AC_PLV_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_PLV_Actor_ProfessionalLevel_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_PLV_Actor_ProfessionalLevel_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex]
    WHERE
        AC_PLV_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_PLV_Actor_ProfessionalLevel','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_PLV_Actor_ProfessionalLevel] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_PLV,
        p.AC_PLV_ID,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Reliability,
        p.AC_PLV_AC_ID,
        p.AC_PLV_PLV_ID,
        p.AC_PLV_ChangedAt
    FROM
        [dbo].[rAC_PLV_Actor_ProfessionalLevel_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) a
    ON
        a.AC_PLV_ID = p.AC_PLV_ID
    AND
        a.AC_PLV_PositedAt = (
            SELECT TOP 1
                sub.AC_PLV_PositedAt
            FROM
                [dbo].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_PLV_ID = p.AC_PLV_ID
            ORDER BY
                sub.AC_PLV_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fAC_PLV_Actor_ProfessionalLevel forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_PLV_Actor_ProfessionalLevel','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_PLV_Actor_ProfessionalLevel] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_PLV,
        p.AC_PLV_ID,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Reliability,
        p.AC_PLV_AC_ID,
        p.AC_PLV_PLV_ID,
        p.AC_PLV_ChangedAt
    FROM
        [dbo].[fAC_PLV_Actor_ProfessionalLevel_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) a
    ON
        a.AC_PLV_ID = p.AC_PLV_ID
    AND
        a.AC_PLV_PositedAt = (
            SELECT TOP 1
                sub.AC_PLV_PositedAt
            FROM
                [dbo].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_PLV_ID = p.AC_PLV_ID
            ORDER BY
                sub.AC_PLV_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preAC_PLV_Actor_ProfessionalLevel function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preAC_PLV_Actor_ProfessionalLevel','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preAC_PLV_Actor_ProfessionalLevel] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.AC_PLV_PLV_ID
        FROM
            [dbo].[rAC_PLV_Actor_ProfessionalLevel](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.AC_PLV_AC_ID = @id
        AND
            pre.AC_PLV_ChangedAt < @changingTimepoint
        AND
            pre.AC_PLV_Reliability = 1
        ORDER BY
            pre.AC_PLV_ChangedAt DESC,
            pre.AC_PLV_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folAC_PLV_Actor_ProfessionalLevel function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folAC_PLV_Actor_ProfessionalLevel','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folAC_PLV_Actor_ProfessionalLevel] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.AC_PLV_PLV_ID
        FROM
            [dbo].[fAC_PLV_Actor_ProfessionalLevel](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.AC_PLV_AC_ID = @id
        AND
            fol.AC_PLV_ChangedAt > @changingTimepoint
        AND
            fol.AC_PLV_Reliability = 1
        ORDER BY
            fol.AC_PLV_ChangedAt ASC,
            fol.AC_PLV_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rPR_NAM_Program_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_NAM_Program_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_NAM_Program_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    FROM
        [dbo].[PR_NAM_Program_Name_Annex]
    WHERE
        PR_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rPR_NAM_Program_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_NAM_Program_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_NAM_Program_Name] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_NAM,
        p.PR_NAM_ID,
        a.PR_NAM_PositedAt,
        a.PR_NAM_Reliability,
        p.PR_NAM_PR_ID,
        p.PR_NAM_Program_Name
    FROM
        [dbo].[PR_NAM_Program_Name_Posit] p
    JOIN
        [dbo].[rPR_NAM_Program_Name_Annex](@positingTimepoint) a
    ON
        a.PR_NAM_ID = p.PR_NAM_ID
    AND
        a.PR_NAM_PositedAt = (
            SELECT TOP 1
                sub.PR_NAM_PositedAt
            FROM
                [dbo].[rPR_NAM_Program_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_NAM_ID = p.PR_NAM_ID
            ORDER BY
                sub.PR_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_LEN_Program_Length_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_LEN_Program_Length_Posit] (
        @changingTimepoint date = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_LEN_ID,
        PR_LEN_PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt
    FROM
        [dbo].[PR_LEN_Program_Length_Posit]
    WHERE
        PR_LEN_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fPR_LEN_Program_Length_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fPR_LEN_Program_Length_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fPR_LEN_Program_Length_Posit] (
        @changingTimepoint date = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_LEN_ID,
        PR_LEN_PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt
    FROM
        [dbo].[PR_LEN_Program_Length_Posit]
    WHERE
        PR_LEN_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_LEN_Program_Length_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_LEN_Program_Length_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    FROM
        [dbo].[PR_LEN_Program_Length_Annex]
    WHERE
        PR_LEN_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_LEN_Program_Length','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_LEN_Program_Length] (
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_LEN,
        p.PR_LEN_ID,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Reliability,
        p.PR_LEN_PR_ID,
        p.PR_LEN_Program_Length,
        p.PR_LEN_ChangedAt
    FROM
        [dbo].[rPR_LEN_Program_Length_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rPR_LEN_Program_Length_Annex](@positingTimepoint) a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = (
            SELECT TOP 1
                sub.PR_LEN_PositedAt
            FROM
                [dbo].[rPR_LEN_Program_Length_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_LEN_ID = p.PR_LEN_ID
            ORDER BY
                sub.PR_LEN_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fPR_LEN_Program_Length forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fPR_LEN_Program_Length','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fPR_LEN_Program_Length] (
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_LEN,
        p.PR_LEN_ID,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Reliability,
        p.PR_LEN_PR_ID,
        p.PR_LEN_Program_Length,
        p.PR_LEN_ChangedAt
    FROM
        [dbo].[fPR_LEN_Program_Length_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rPR_LEN_Program_Length_Annex](@positingTimepoint) a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = (
            SELECT TOP 1
                sub.PR_LEN_PositedAt
            FROM
                [dbo].[rPR_LEN_Program_Length_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_LEN_ID = p.PR_LEN_ID
            ORDER BY
                sub.PR_LEN_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- prePR_LEN_Program_Length function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.prePR_LEN_Program_Length','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[prePR_LEN_Program_Length] (
        @id int,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS time
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.PR_LEN_Program_Length
        FROM
            [dbo].[rPR_LEN_Program_Length](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.PR_LEN_PR_ID = @id
        AND
            pre.PR_LEN_ChangedAt < @changingTimepoint
        AND
            pre.PR_LEN_Reliability = 1
        ORDER BY
            pre.PR_LEN_ChangedAt DESC,
            pre.PR_LEN_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folPR_LEN_Program_Length function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folPR_LEN_Program_Length','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folPR_LEN_Program_Length] (
        @id int,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS time
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.PR_LEN_Program_Length
        FROM
            [dbo].[fPR_LEN_Program_Length](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.PR_LEN_PR_ID = @id
        AND
            fol.PR_LEN_ChangedAt > @changingTimepoint
        AND
            fol.PR_LEN_Reliability = 1
        ORDER BY
            fol.PR_LEN_ChangedAt ASC,
            fol.PR_LEN_PositedAt DESC
    );
    END
    ');
END
GO
-- ATTRIBUTE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------
--
-- Attributes may be prevented from storing restatements.
-- A restatement is when the same value occurs for two adjacent points
-- in changing time. Note that restatement checking is not done for
-- unreliable information as this could prevent demotion.
--
-- If actual deletes are made, the remaining information will not
-- be checked for restatements.
--
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_ST_AVG_Stage_Average (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_ST_AVG_Stage_Average', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_ST_AVG_Stage_Average];
GO
CREATE TRIGGER [dbo].[rt_ST_AVG_Stage_Average] ON [dbo].[ST_AVG_Stage_Average_Annex]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_AVG_ID int not null,
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null,
        primary key (
            ST_AVG_ST_ID asc,
            ST_AVG_ChangedAt desc,
            ST_AVG_PositedAt desc,
            ST_AVG_Reliability desc
        ),
        unique (
            ST_AVG_ID,
            ST_AVG_PositedAt
        )
    );
    INSERT INTO @ST_AVG_Stage_Average (
        ST_AVG_ID,
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID
    )
    SELECT
        i.ST_AVG_ID,
        p.ST_AVG_ST_ID,
        i.Metadata_ST_AVG,
        p.ST_AVG_ChangedAt,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Reliability,
        p.ST_AVG_UTL_ID
    FROM
        inserted i
    JOIN
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ID = i.ST_AVG_ID; -- the posit has already been created
    INSERT INTO @ST_AVG_Stage_Average (
        ST_AVG_ID,
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID
    )
    SELECT
        p.ST_AVG_ID,
        p.ST_AVG_ST_ID,
        p.Metadata_ST_AVG,
        p.ST_AVG_ChangedAt,
        p.ST_AVG_PositedAt,
        p.ST_AVG_Reliability,
        p.ST_AVG_UTL_ID
    FROM
        (SELECT DISTINCT ST_AVG_ST_ID FROM @ST_AVG_Stage_Average) i
    JOIN
        [dbo].[ST_AVG_Stage_Average] p
    ON
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
    LEFT JOIN
        @ST_AVG_Stage_Average x
    ON
        x.ST_AVG_ID = p.ST_AVG_ID
    AND
        x.ST_AVG_PositedAt = p.ST_AVG_PositedAt
    WHERE
        x.ST_AVG_ID is null;
    -- no need to check retracted information
    DELETE a
    FROM
        @ST_AVG_Stage_Average a
    OUTER APPLY (
        SELECT TOP 1
            x.ST_AVG_Reliability
        FROM
            @ST_AVG_Stage_Average x
        WHERE
            x.ST_AVG_ID = a.ST_AVG_ID
        AND
            x.ST_AVG_PositedAt < a.ST_AVG_PositedAt
        ORDER BY
            x.ST_AVG_PositedAt DESC
    ) pre
    OUTER APPLY (
        SELECT TOP 1
            x.ST_AVG_Reliability
        FROM
            @ST_AVG_Stage_Average x
        WHERE
            x.ST_AVG_ID = a.ST_AVG_ID
        AND
            x.ST_AVG_PositedAt > a.ST_AVG_PositedAt
        ORDER BY
            x.ST_AVG_PositedAt ASC
    ) fol
    WHERE
        (a.ST_AVG_Reliability = 1 AND fol.ST_AVG_Reliability = 0)
    OR
        (a.ST_AVG_Reliability = 0 AND pre.ST_AVG_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @ST_AVG_Stage_Average a
        CROSS APPLY (
            SELECT TOP 1
                h.ST_AVG_ST_ID,
                h.ST_AVG_ChangedAt,
                h.ST_AVG_UTL_ID
            FROM
                @ST_AVG_Stage_Average h
            WHERE
                h.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            AND
                h.ST_AVG_ChangedAt < a.ST_AVG_ChangedAt
            ORDER BY
                h.ST_AVG_ChangedAt DESC,
                h.ST_AVG_PositedAt DESC,
                h.ST_AVG_Reliability DESC
        ) pre
        WHERE
            a.ST_AVG_UTL_ID = pre.ST_AVG_UTL_ID
        AND
            a.ST_AVG_Reliability = 1
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in ST_AVG_Stage_Average for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_AC_NAM_Actor_Name (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [dbo].[rt_AC_NAM_Actor_Name] ON [dbo].[AC_NAM_Actor_Name_Annex]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_NAM_ID int not null,
        AC_NAM_AC_ID int not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_Checksum varbinary(16) not null,
        primary key (
            AC_NAM_AC_ID asc,
            AC_NAM_ChangedAt desc,
            AC_NAM_PositedAt desc,
            AC_NAM_Reliability desc
        ),
        unique (
            AC_NAM_ID,
            AC_NAM_PositedAt
        )
    );
    INSERT INTO @AC_NAM_Actor_Name (
        AC_NAM_ID,
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Checksum,
        AC_NAM_Actor_Name
    )
    SELECT
        i.AC_NAM_ID,
        p.AC_NAM_AC_ID,
        i.Metadata_AC_NAM,
        p.AC_NAM_ChangedAt,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Reliability,
        p.AC_NAM_Checksum,
        p.AC_NAM_Actor_Name
    FROM
        inserted i
    JOIN
        [dbo].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_NAM_ID = i.AC_NAM_ID; -- the posit has already been created
    INSERT INTO @AC_NAM_Actor_Name (
        AC_NAM_ID,
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Checksum,
        AC_NAM_Actor_Name
    )
    SELECT
        p.AC_NAM_ID,
        p.AC_NAM_AC_ID,
        p.Metadata_AC_NAM,
        p.AC_NAM_ChangedAt,
        p.AC_NAM_PositedAt,
        p.AC_NAM_Reliability,
        p.AC_NAM_Checksum,
        p.AC_NAM_Actor_Name
    FROM
        (SELECT DISTINCT AC_NAM_AC_ID FROM @AC_NAM_Actor_Name) i
    JOIN
        [dbo].[AC_NAM_Actor_Name] p
    ON
        p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
    LEFT JOIN
        @AC_NAM_Actor_Name x
    ON
        x.AC_NAM_ID = p.AC_NAM_ID
    AND
        x.AC_NAM_PositedAt = p.AC_NAM_PositedAt
    WHERE
        x.AC_NAM_ID is null;
    -- no need to check retracted information
    DELETE a
    FROM
        @AC_NAM_Actor_Name a
    OUTER APPLY (
        SELECT TOP 1
            x.AC_NAM_Reliability
        FROM
            @AC_NAM_Actor_Name x
        WHERE
            x.AC_NAM_ID = a.AC_NAM_ID
        AND
            x.AC_NAM_PositedAt < a.AC_NAM_PositedAt
        ORDER BY
            x.AC_NAM_PositedAt DESC
    ) pre
    OUTER APPLY (
        SELECT TOP 1
            x.AC_NAM_Reliability
        FROM
            @AC_NAM_Actor_Name x
        WHERE
            x.AC_NAM_ID = a.AC_NAM_ID
        AND
            x.AC_NAM_PositedAt > a.AC_NAM_PositedAt
        ORDER BY
            x.AC_NAM_PositedAt ASC
    ) fol
    WHERE
        (a.AC_NAM_Reliability = 1 AND fol.AC_NAM_Reliability = 0)
    OR
        (a.AC_NAM_Reliability = 0 AND pre.AC_NAM_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @AC_NAM_Actor_Name a
        CROSS APPLY (
            SELECT TOP 1
                h.AC_NAM_AC_ID,
                h.AC_NAM_ChangedAt,
                h.AC_NAM_Checksum
            FROM
                @AC_NAM_Actor_Name h
            WHERE
                h.AC_NAM_AC_ID = a.AC_NAM_AC_ID
            AND
                h.AC_NAM_ChangedAt < a.AC_NAM_ChangedAt
            ORDER BY
                h.AC_NAM_ChangedAt DESC,
                h.AC_NAM_PositedAt DESC,
                h.AC_NAM_Reliability DESC
        ) pre
        WHERE
            a.AC_NAM_Checksum = pre.AC_NAM_Checksum
        AND
            a.AC_NAM_Reliability = 1
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in AC_NAM_Actor_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- ANCHOR TEMPORAL BUSINESS PERSPECTIVES ------------------------------------------------------------------------------
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Person];
IF Object_ID('dbo.Current_Person', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Person];
IF Object_ID('dbo.Point_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Person];
IF Object_ID('dbo.Latest_Person', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Person];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Stage];
IF Object_ID('dbo.Current_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Stage];
IF Object_ID('dbo.Point_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Stage];
IF Object_ID('dbo.Latest_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Stage];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Actor];
IF Object_ID('dbo.Current_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Actor];
IF Object_ID('dbo.Point_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Actor];
IF Object_ID('dbo.Latest_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Actor];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Program];
IF Object_ID('dbo.Current_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Program];
IF Object_ID('dbo.Point_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Program];
IF Object_ID('dbo.Latest_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Program];
GO
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are five types of perspectives: time traveling, latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The time traveling perspective shows information as it was or will be based on a number
-- of input parameters.
--
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
--
-- The latest perspective shows the latest available (changing & positing) information for each anchor.
-- The now perspective shows the information as it is right now, with latest positing time.
-- The point-in-time perspective lets you travel through the information to the given timepoint,
-- with latest positing time and the given point in changing time.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes, with latest positing time.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPN_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPN_Person];
IF Object_ID('dbo.nPN_Person', 'V') IS NOT NULL
DROP VIEW [dbo].[nPN_Person];
IF Object_ID('dbo.pPN_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPN_Person];
IF Object_ID('dbo.lPN_Person', 'V') IS NOT NULL
DROP VIEW [dbo].[lPN_Person];
IF Object_ID('dbo.tPN_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tPN_Person];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_Stage];
IF Object_ID('dbo.nST_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_Stage];
IF Object_ID('dbo.pST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_Stage];
IF Object_ID('dbo.lST_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_Stage];
IF Object_ID('dbo.tST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tST_Stage];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tST_Stage viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tST_Stage] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [NAM].ST_NAM_ST_ID,
    [NAM].Metadata_ST_NAM,
    [NAM].ST_NAM_ID,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_PositedAt,
    [NAM].ST_NAM_Reliability,
    [NAM].ST_NAM_Checksum,
    [NAM].ST_NAM_Stage_Name,
    [LOC].ST_LOC_ST_ID,
    [LOC].Metadata_ST_LOC,
    [LOC].ST_LOC_ID,
    [LOC].ST_LOC_PositedAt,
    [LOC].ST_LOC_Reliability,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].ST_AVG_ST_ID,
    [AVG].Metadata_ST_AVG,
    [AVG].ST_AVG_ID,
    [AVG].ST_AVG_ChangedAt,
    [AVG].ST_AVG_PositedAt,
    [AVG].ST_AVG_Reliability,
    [AVG].UTL_Utilization AS ST_AVG_UTL_Utilization,
    [AVG].Metadata_UTL AS ST_AVG_Metadata_UTL,
    [AVG].ST_AVG_UTL_ID,
    [MIN].ST_MIN_ST_ID,
    [MIN].Metadata_ST_MIN,
    [MIN].ST_MIN_ID,
    [MIN].ST_MIN_PositedAt,
    [MIN].ST_MIN_Reliability,
    [MIN].UTL_Utilization AS ST_MIN_UTL_Utilization,
    [MIN].Metadata_UTL AS ST_MIN_Metadata_UTL,
    [MIN].ST_MIN_UTL_ID
FROM
    [dbo].[ST_Stage] [ST]
OUTER APPLY (
    SELECT TOP 1
        [rNAM].ST_NAM_ST_ID,
        [rNAM].Metadata_ST_NAM,
        [rNAM].ST_NAM_ID,
        [rNAM].ST_NAM_ChangedAt,
        [rNAM].ST_NAM_PositedAt,
        [rNAM].ST_NAM_Reliability,
        [rNAM].ST_NAM_Checksum,
        [rNAM].ST_NAM_Stage_Name
    FROM
        [dbo].[rST_NAM_Stage_Name](
            @changingTimepoint,
            @positingTimepoint
        ) [rNAM]
    WHERE
        [rNAM].ST_NAM_ST_ID = [ST].ST_ID
    AND
        [rNAM].ST_NAM_Reliability = 1
    ORDER BY
        [rNAM].ST_NAM_ChangedAt DESC,
        [rNAM].ST_NAM_PositedAt DESC
) [NAM]
OUTER APPLY (
    SELECT TOP 1
        [rLOC].ST_LOC_ST_ID,
        [rLOC].Metadata_ST_LOC,
        [rLOC].ST_LOC_ID,
        [rLOC].ST_LOC_PositedAt,
        [rLOC].ST_LOC_Reliability,
        [rLOC].ST_LOC_Checksum,
        [rLOC].ST_LOC_Stage_Location
    FROM
        [dbo].[rST_LOC_Stage_Location](
            @positingTimepoint
        ) [rLOC]
    WHERE
        [rLOC].ST_LOC_ST_ID = [ST].ST_ID
    AND
        [rLOC].ST_LOC_Reliability = 1
    ORDER BY
        [rLOC].ST_LOC_PositedAt DESC
) [LOC]
OUTER APPLY (
    SELECT TOP 1
        [rAVG].ST_AVG_ST_ID,
        [rAVG].Metadata_ST_AVG,
        [rAVG].ST_AVG_ID,
        [rAVG].ST_AVG_ChangedAt,
        [rAVG].ST_AVG_PositedAt,
        [rAVG].ST_AVG_Reliability,
        [kAVG].UTL_Utilization,
        [kAVG].Metadata_UTL,
        [rAVG].ST_AVG_UTL_ID
    FROM
        [dbo].[rST_AVG_Stage_Average](
            @changingTimepoint,
            @positingTimepoint
        ) [rAVG]
    JOIN
        [dbo].[UTL_Utilization] [kAVG]
    ON
        [kAVG].UTL_ID = [rAVG].ST_AVG_UTL_ID
    WHERE
        [rAVG].ST_AVG_ST_ID = [ST].ST_ID
    AND
        [rAVG].ST_AVG_Reliability = 1
    ORDER BY
        [rAVG].ST_AVG_ChangedAt DESC,
        [rAVG].ST_AVG_PositedAt DESC
) [AVG]
OUTER APPLY (
    SELECT TOP 1
        [rMIN].ST_MIN_ST_ID,
        [rMIN].Metadata_ST_MIN,
        [rMIN].ST_MIN_ID,
        [rMIN].ST_MIN_PositedAt,
        [rMIN].ST_MIN_Reliability,
        [kMIN].UTL_Utilization,
        [kMIN].Metadata_UTL,
        [rMIN].ST_MIN_UTL_ID
    FROM
        [dbo].[rST_MIN_Stage_Minimum](
            @positingTimepoint
        ) [rMIN]
    JOIN
        [dbo].[UTL_Utilization] [kMIN]
    ON
        [kMIN].UTL_ID = [rMIN].ST_MIN_UTL_ID
    WHERE
        [rMIN].ST_MIN_ST_ID = [ST].ST_ID
    AND
        [rMIN].ST_MIN_Reliability = 1
    ORDER BY
        [rMIN].ST_MIN_PositedAt DESC
) [MIN];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_Stage viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_Stage]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [dbo].[tST_Stage] (
        DEFAULT,
        DEFAULT
    ) [ST];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_Stage] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [dbo].[tST_Stage] (
        @changingTimepoint,
        DEFAULT
    ) [ST];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_Stage]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [dbo].[tST_Stage] (
        sysdatetime(),
        DEFAULT
    ) [ST];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dST_Stage showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dST_Stage] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    [ST].*
FROM (
    SELECT DISTINCT
        ST_NAM_ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [dbo].[ST_NAM_Stage_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        ST_AVG_ST_ID AS ST_ID,
        ST_AVG_ChangedAt AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        [dbo].[ST_AVG_Stage_Average]
    WHERE
        (@selection is null OR @selection like '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[tST_Stage] (
        timepoints.inspectedTimepoint,
        DEFAULT
    ) [ST]
 WHERE
    [ST].ST_ID = timepoints.ST_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_Actor];
IF Object_ID('dbo.nAC_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_Actor];
IF Object_ID('dbo.pAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_Actor];
IF Object_ID('dbo.lAC_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_Actor];
IF Object_ID('dbo.tAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tAC_Actor];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_Actor viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tAC_Actor] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [AC].AC_ID,
    [AC].Metadata_AC,
    [NAM].AC_NAM_AC_ID,
    [NAM].Metadata_AC_NAM,
    [NAM].AC_NAM_ID,
    [NAM].AC_NAM_ChangedAt,
    [NAM].AC_NAM_PositedAt,
    [NAM].AC_NAM_Reliability,
    [NAM].AC_NAM_Checksum,
    [NAM].AC_NAM_Actor_Name,
    [GEN].AC_GEN_AC_ID,
    [GEN].Metadata_AC_GEN,
    [GEN].AC_GEN_ID,
    [GEN].AC_GEN_PositedAt,
    [GEN].AC_GEN_Reliability,
    [GEN].GEN_Gender AS AC_GEN_GEN_Gender,
    [GEN].Metadata_GEN AS AC_GEN_Metadata_GEN,
    [GEN].AC_GEN_GEN_ID,
    [PLV].AC_PLV_AC_ID,
    [PLV].Metadata_AC_PLV,
    [PLV].AC_PLV_ID,
    [PLV].AC_PLV_ChangedAt,
    [PLV].AC_PLV_PositedAt,
    [PLV].AC_PLV_Reliability,
    [PLV].PLV_Checksum AS AC_PLV_PLV_Checksum,
    [PLV].PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    [PLV].Metadata_PLV AS AC_PLV_Metadata_PLV,
    [PLV].AC_PLV_PLV_ID
FROM
    [dbo].[AC_Actor] [AC]
OUTER APPLY (
    SELECT TOP 1
        [rNAM].AC_NAM_AC_ID,
        [rNAM].Metadata_AC_NAM,
        [rNAM].AC_NAM_ID,
        [rNAM].AC_NAM_ChangedAt,
        [rNAM].AC_NAM_PositedAt,
        [rNAM].AC_NAM_Reliability,
        [rNAM].AC_NAM_Checksum,
        [rNAM].AC_NAM_Actor_Name
    FROM
        [dbo].[rAC_NAM_Actor_Name](
            @changingTimepoint,
            @positingTimepoint
        ) [rNAM]
    WHERE
        [rNAM].AC_NAM_AC_ID = [AC].AC_ID
    AND
        [rNAM].AC_NAM_Reliability = 1
    ORDER BY
        [rNAM].AC_NAM_ChangedAt DESC,
        [rNAM].AC_NAM_PositedAt DESC
) [NAM]
OUTER APPLY (
    SELECT TOP 1
        [rGEN].AC_GEN_AC_ID,
        [rGEN].Metadata_AC_GEN,
        [rGEN].AC_GEN_ID,
        [rGEN].AC_GEN_PositedAt,
        [rGEN].AC_GEN_Reliability,
        [kGEN].GEN_Gender,
        [kGEN].Metadata_GEN,
        [rGEN].AC_GEN_GEN_ID
    FROM
        [dbo].[rAC_GEN_Actor_Gender](
            @positingTimepoint
        ) [rGEN]
    JOIN
        [dbo].[GEN_Gender] [kGEN]
    ON
        [kGEN].GEN_ID = [rGEN].AC_GEN_GEN_ID
    WHERE
        [rGEN].AC_GEN_AC_ID = [AC].AC_ID
    AND
        [rGEN].AC_GEN_Reliability = 1
    ORDER BY
        [rGEN].AC_GEN_PositedAt DESC
) [GEN]
OUTER APPLY (
    SELECT TOP 1
        [rPLV].AC_PLV_AC_ID,
        [rPLV].Metadata_AC_PLV,
        [rPLV].AC_PLV_ID,
        [rPLV].AC_PLV_ChangedAt,
        [rPLV].AC_PLV_PositedAt,
        [rPLV].AC_PLV_Reliability,
        [kPLV].PLV_Checksum,
        [kPLV].PLV_ProfessionalLevel,
        [kPLV].Metadata_PLV,
        [rPLV].AC_PLV_PLV_ID
    FROM
        [dbo].[rAC_PLV_Actor_ProfessionalLevel](
            @changingTimepoint,
            @positingTimepoint
        ) [rPLV]
    JOIN
        [dbo].[PLV_ProfessionalLevel] [kPLV]
    ON
        [kPLV].PLV_ID = [rPLV].AC_PLV_PLV_ID
    WHERE
        [rPLV].AC_PLV_AC_ID = [AC].AC_ID
    AND
        [rPLV].AC_PLV_Reliability = 1
    ORDER BY
        [rPLV].AC_PLV_ChangedAt DESC,
        [rPLV].AC_PLV_PositedAt DESC
) [PLV];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_Actor viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_Actor]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [dbo].[tAC_Actor] (
        DEFAULT,
        DEFAULT
    ) [AC];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_Actor] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [dbo].[tAC_Actor] (
        @changingTimepoint,
        DEFAULT
    ) [AC];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_Actor]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [dbo].[tAC_Actor] (
        sysdatetime(),
        DEFAULT
    ) [AC];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_Actor showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dAC_Actor] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    [AC].*
FROM (
    SELECT DISTINCT
        AC_NAM_AC_ID AS AC_ID,
        AC_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [dbo].[AC_NAM_Actor_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        AC_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        AC_PLV_AC_ID AS AC_ID,
        AC_PLV_ChangedAt AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        (@selection is null OR @selection like '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[tAC_Actor] (
        timepoints.inspectedTimepoint,
        DEFAULT
    ) [AC]
 WHERE
    [AC].AC_ID = timepoints.AC_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPR_Program];
IF Object_ID('dbo.nPR_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[nPR_Program];
IF Object_ID('dbo.pPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPR_Program];
IF Object_ID('dbo.lPR_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[lPR_Program];
IF Object_ID('dbo.tPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tPR_Program];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tPR_Program viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tPR_Program] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [PR].Metadata_PR,
    [NAM].PR_NAM_PR_ID,
    [NAM].Metadata_PR_NAM,
    [NAM].PR_NAM_ID,
    [NAM].PR_NAM_PositedAt,
    [NAM].PR_NAM_Reliability,
    [NAM].PR_NAM_Program_Name,
    [LEN].PR_LEN_PR_ID,
    [LEN].Metadata_PR_LEN,
    [LEN].PR_LEN_ID,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_PositedAt,
    [LEN].PR_LEN_Reliability,
    [LEN].PR_LEN_Program_Length
FROM
    [dbo].[PR_Program] [PR]
OUTER APPLY (
    SELECT TOP 1
        [rNAM].PR_NAM_PR_ID,
        [rNAM].Metadata_PR_NAM,
        [rNAM].PR_NAM_ID,
        [rNAM].PR_NAM_PositedAt,
        [rNAM].PR_NAM_Reliability,
        [rNAM].PR_NAM_Program_Name
    FROM
        [dbo].[rPR_NAM_Program_Name](
            @positingTimepoint
        ) [rNAM]
    WHERE
        [rNAM].PR_NAM_PR_ID = [PR].PR_ID
    AND
        [rNAM].PR_NAM_Reliability = 1
    ORDER BY
        [rNAM].PR_NAM_PositedAt DESC
) [NAM]
OUTER APPLY (
    SELECT TOP 1
        [rLEN].PR_LEN_PR_ID,
        [rLEN].Metadata_PR_LEN,
        [rLEN].PR_LEN_ID,
        [rLEN].PR_LEN_ChangedAt,
        [rLEN].PR_LEN_PositedAt,
        [rLEN].PR_LEN_Reliability,
        [rLEN].PR_LEN_Program_Length
    FROM
        [dbo].[rPR_LEN_Program_Length](
            @changingTimepoint,
            @positingTimepoint
        ) [rLEN]
    WHERE
        [rLEN].PR_LEN_PR_ID = [PR].PR_ID
    AND
        [rLEN].PR_LEN_Reliability = 1
    ORDER BY
        [rLEN].PR_LEN_ChangedAt DESC,
        [rLEN].PR_LEN_PositedAt DESC
) [LEN];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_Program viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPR_Program]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [dbo].[tPR_Program] (
        DEFAULT,
        DEFAULT
    ) [PR];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPR_Program] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [dbo].[tPR_Program] (
        @changingTimepoint,
        DEFAULT
    ) [PR];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPR_Program]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [dbo].[tPR_Program] (
        sysdatetime(),
        DEFAULT
    ) [PR];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dPR_Program showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dPR_Program] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    [PR].*
FROM (
    SELECT DISTINCT
        PR_LEN_PR_ID AS PR_ID,
        PR_LEN_ChangedAt AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        [dbo].[PR_LEN_Program_Length]
    WHERE
        (@selection is null OR @selection like '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[tPR_Program] (
        timepoints.inspectedTimepoint,
        DEFAULT
    ) [PR]
 WHERE
    [PR].PR_ID = timepoints.PR_ID;
GO
-- ANCHOR TEMPORAL BUSINESS PERSPECTIVES ------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are four types of perspectives: latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The latest perspective shows the latest available information for each anchor.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-EQ perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Stage viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Stage] AS
SELECT
    [ST].ST_ID as [Stage_Id],
    [ST].ST_NAM_Stage_Name as [Name],
    [ST].ST_LOC_Stage_Location as [Location],
    [ST].ST_AVG_UTL_Utilization as [Average_Utilization],
    [ST].ST_MIN_UTL_Utilization as [Minimum_Utilization]
FROM
    [dbo].[lST_Stage] [ST];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Stage] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [ST].ST_ID as [Stage_Id],
    [ST].ST_NAM_Stage_Name as [Name],
    [ST].ST_LOC_Stage_Location as [Location],
    [ST].ST_AVG_UTL_Utilization as [Average_Utilization],
    [ST].ST_MIN_UTL_Utilization as [Minimum_Utilization]
FROM
    [dbo].[pST_Stage](@changingTimepoint) [ST]
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Stage]
AS
SELECT
    *
FROM
    [dbo].[Point_Stage](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Stage showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Difference_Stage] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pST].*
FROM (
    SELECT DISTINCT
        ST_NAM_ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS [Time_of_Change],
        'Name' AS [Subject_of_Change]
    FROM
        [dbo].[ST_NAM_Stage_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        ST_AVG_ST_ID AS ST_ID,
        ST_AVG_ChangedAt AS [Time_of_Change],
        'Average' AS [Subject_of_Change]
    FROM
        [dbo].[ST_AVG_Stage_Average]
    WHERE
        (@selection is null OR @selection like '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[Point_Stage](timepoints.[Time_of_Change]) [pST]
WHERE
    [pST].Stage_Id = timepoints.ST_ID;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Actor viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Actor] AS
SELECT
    [AC].AC_ID as [Actor_Id],
    [AC].AC_NAM_Actor_Name as [Name],
    [AC].AC_GEN_GEN_Gender as [Gender_Gender],
    [AC].AC_PLV_PLV_ProfessionalLevel as [ProfessionalLevel_ProfessionalLevel]
FROM
    [dbo].[lAC_Actor] [AC];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Actor] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [AC].AC_ID as [Actor_Id],
    [AC].AC_NAM_Actor_Name as [Name],
    [AC].AC_GEN_GEN_Gender as [Gender_Gender],
    [AC].AC_PLV_PLV_ProfessionalLevel as [ProfessionalLevel_ProfessionalLevel]
FROM
    [dbo].[pAC_Actor](@changingTimepoint) [AC]
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Actor]
AS
SELECT
    *
FROM
    [dbo].[Point_Actor](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Actor showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Difference_Actor] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pAC].*
FROM (
    SELECT DISTINCT
        AC_NAM_AC_ID AS AC_ID,
        AC_NAM_ChangedAt AS [Time_of_Change],
        'Name' AS [Subject_of_Change]
    FROM
        [dbo].[AC_NAM_Actor_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        AC_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        AC_PLV_AC_ID AS AC_ID,
        AC_PLV_ChangedAt AS [Time_of_Change],
        'ProfessionalLevel' AS [Subject_of_Change]
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        (@selection is null OR @selection like '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[Point_Actor](timepoints.[Time_of_Change]) [pAC]
WHERE
    [pAC].Actor_Id = timepoints.AC_ID;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Program viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Program] AS
SELECT
    [PR].PR_ID as [Program_Id],
    [PR].PR_NAM_Program_Name as [Name],
    [PR].PR_LEN_Program_Length as [Length]
FROM
    [dbo].[lPR_Program] [PR];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Program] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [PR].PR_ID as [Program_Id],
    [PR].PR_NAM_Program_Name as [Name],
    [PR].PR_LEN_Program_Length as [Length]
FROM
    [dbo].[pPR_Program](@changingTimepoint) [PR]
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Program]
AS
SELECT
    *
FROM
    [dbo].[Point_Program](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Program showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Difference_Program] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pPR].*
FROM (
    SELECT DISTINCT
        PR_LEN_PR_ID AS PR_ID,
        PR_LEN_ChangedAt AS [Time_of_Change],
        'Length' AS [Subject_of_Change]
    FROM
        [dbo].[PR_LEN_Program_Length]
    WHERE
        (@selection is null OR @selection like '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[Point_Program](timepoints.[Time_of_Change]) [pPR]
WHERE
    [pPR].Program_Id = timepoints.PR_ID;
GO
-- NEXUS TEMPORAL BUSINESS PERSPECTIVES -----------------------------------------------------------------------------
--
-- Drop perspectives -------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Event];
IF Object_ID('dbo.Current_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Event];
IF Object_ID('dbo.Point_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Event];
IF Object_ID('dbo.Latest_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Event];
GO
-- NEXUS TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each nexus. There are five types of perspectives: time traveling, latest,
-- point-in-time, difference, and now. They also denormalize the nexus, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The time traveling perspective shows information as it was or will be based on a number
-- of input parameters.
--
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
--
-- The latest perspective shows the latest available (changing & positing) information for each nexus.
-- The now perspective shows the information as it is right now, with latest positing time.
-- The point-in-time perspective lets you travel through the information to the given timepoint,
-- with latest positing time and the given point in changing time.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes, with latest positing time.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dEV_Event];
IF Object_ID('dbo.nEV_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[nEV_Event];
IF Object_ID('dbo.pEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pEV_Event];
IF Object_ID('dbo.lEV_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[lEV_Event];
IF Object_ID('dbo.tEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tEV_Event];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tEV_Event viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tEV_Event] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].ST_ID_wasHeldAt,
    [EV].PR_ID_wasPlayed,
    [ETY_of].ETY_EventType AS of_ETY_EventType,
    [ETY_of].Metadata_ETY AS of_Metadata_ETY,
    [EV].ETY_ID_of,
    [DAT].EV_DAT_EV_ID,
    [DAT].Metadata_EV_DAT,
    [DAT].EV_DAT_ID,
    [DAT].EV_DAT_PositedAt,
    [DAT].EV_DAT_Reliability,
    [DAT].EV_DAT_Event_Date,
    [AUD].EV_AUD_EV_ID,
    [AUD].Metadata_EV_AUD,
    [AUD].EV_AUD_ID,
    [AUD].EV_AUD_PositedAt,
    [AUD].EV_AUD_Reliability,
    [AUD].EV_AUD_Event_Audience,
    [REV].EV_REV_EV_ID,
    [REV].Metadata_EV_REV,
    [REV].EV_REV_ID,
    [REV].EV_REV_PositedAt,
    [REV].EV_REV_Reliability,
    [REV].EV_REV_Event_Revenue
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[ETY_EventType] [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
OUTER APPLY (
    SELECT TOP 1
        [rDAT].EV_DAT_EV_ID,
        [rDAT].Metadata_EV_DAT,
        [rDAT].EV_DAT_ID,
        [rDAT].EV_DAT_PositedAt,
        [rDAT].EV_DAT_Reliability,
        [rDAT].EV_DAT_Event_Date
    FROM
        [dbo].[rEV_DAT_Event_Date](
            @positingTimepoint
        ) [rDAT]
    WHERE
        [rDAT].EV_DAT_EV_ID = [EV].EV_ID
    AND
        [rDAT].EV_DAT_Reliability = 1
    ORDER BY
        [rDAT].EV_DAT_PositedAt DESC
) [DAT]
OUTER APPLY (
    SELECT TOP 1
        [rAUD].EV_AUD_EV_ID,
        [rAUD].Metadata_EV_AUD,
        [rAUD].EV_AUD_ID,
        [rAUD].EV_AUD_PositedAt,
        [rAUD].EV_AUD_Reliability,
        [rAUD].EV_AUD_Event_Audience
    FROM
        [dbo].[rEV_AUD_Event_Audience](
            @positingTimepoint
        ) [rAUD]
    WHERE
        [rAUD].EV_AUD_EV_ID = [EV].EV_ID
    AND
        [rAUD].EV_AUD_Reliability = 1
    ORDER BY
        [rAUD].EV_AUD_PositedAt DESC
) [AUD]
OUTER APPLY (
    SELECT TOP 1
        [rREV].EV_REV_EV_ID,
        [rREV].Metadata_EV_REV,
        [rREV].EV_REV_ID,
        [rREV].EV_REV_PositedAt,
        [rREV].EV_REV_Reliability,
        [rREV].EV_REV_Event_Revenue
    FROM
        [dbo].[rEV_REV_Event_Revenue](
            @positingTimepoint
        ) [rREV]
    WHERE
        [rREV].EV_REV_EV_ID = [EV].EV_ID
    AND
        [rREV].EV_REV_Reliability = 1
    ORDER BY
        [rREV].EV_REV_PositedAt DESC
) [REV];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lEV_Event viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lEV_Event]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[tEV_Event] (
        DEFAULT,
        DEFAULT
    ) [EV];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pEV_Event viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pEV_Event] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[tEV_Event] (
        @changingTimepoint,
        DEFAULT
    ) [EV];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_Event viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nEV_Event]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[tEV_Event] (
        sysdatetime(),
        DEFAULT
    ) [EV];
GO
-- NEXUS TEMPORAL BUSINESS PERSPECTIVES -----------------------------------------------------------------------------
--
-- These views and functions provide business friendly temporal perspectives over each nexus
-- paralleling the anchor and tie business perspectives. A nexus base row is immutable; only
-- its historized attributes vary over time. Roles (anchor/nexus/knot foreign keys) project
-- as business columns without historization logic.
--
-- Four base perspectives: Latest_, Point_, Difference_, Current_ (l / p / d / n)
-- Under equivalence: EQ_Latest_, EQ_Point_, EQ_Difference_, EQ_Current_ (el / ep / ed / en)
--
-- @changingTimepoint point in changing time for point-in-time functions
-- @intervalStart interval start (difference)
-- @intervalEnd interval end (difference)
-- @selection list of attribute mnemonics to filter differences (null = all)
-- @equivalent equivalence key (equivalence variants)
--
-- Generation is skipped for nexuses without attributes to avoid trivial duplication of the base table.
-- Knot value columns respect schema.KNOT_ALIASES for presentable naming; both alias and knot value
-- are exposed analogous to anchor business perspectives when aliases are disabled.
--
-- Latest perspective ------------------------------------------------------------------------------------------------
-- Latest_Event viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Event] AS
SELECT
    [EV].EV_ID as [Event_Id],
    [EV].ST_ID_wasHeldAt as [Stage_wasHeldAt_Id],
    [EV].PR_ID_wasPlayed as [Program_wasPlayed_Id],
    [EV].of_ETY_EventType AS [of_EventType],
    [EV].EV_DAT_Event_Date as [Date],
    [EV].EV_AUD_Event_Audience as [Audience],
    [EV].EV_REV_Event_Revenue as [Revenue]
FROM
    [dbo].[lEV_Event] [EV];
GO
-- Point-in-time perspective -----------------------------------------------------------------------------------------
-- Point_Event viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Event] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [EV].EV_ID as [Event_Id],
    [EV].ST_ID_wasHeldAt as [Stage_wasHeldAt_Id],
    [EV].PR_ID_wasPlayed as [Program_wasPlayed_Id],
    [EV].of_ETY_EventType AS [of_EventType],
    [EV].EV_DAT_Event_Date as [Date],
    [EV].EV_AUD_Event_Audience as [Audience],
    [EV].EV_REV_Event_Revenue as [Revenue]
FROM
    [dbo].[pEV_Event](@changingTimepoint) [EV]
GO
-- Now perspective ---------------------------------------------------------------------------------------------------
-- Current_Event viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Event]
AS
SELECT
    *
FROM
    [dbo].[Point_Event](sysdatetime());
GO
-- KEY GENERATORS -----------------------------------------------------------------------------------------------------
--
-- These stored procedures can be used to generate identities of entities.
-- Corresponding anchors must have an incrementing identity column.
--
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kPN_Person identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kPN_Person', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kPN_Person] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[PN_Person] (
                Metadata_PN
            )
            OUTPUT
                inserted.PN_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kST_Stage identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kST_Stage', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kST_Stage] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[ST_Stage] (
                Metadata_ST
            )
            OUTPUT
                inserted.ST_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kAC_Actor identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kAC_Actor', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kAC_Actor] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[AC_Actor] (
                Metadata_AC
            )
            OUTPUT
                inserted.AC_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kPR_Program identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kPR_Program', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kPR_Program] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[PR_Program] (
                Metadata_PR
            )
            OUTPUT
                inserted.PR_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled views make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_DAT_Event_Date instead of INSERT trigger on EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_DAT_Event_Date', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_DAT_Event_Date];
GO
CREATE TRIGGER [dbo].[it_EV_DAT_Event_Date] ON [dbo].[EV_DAT_Event_Date]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_DAT_Event_Date TABLE (
        EV_DAT_EV_ID int not null,
        Metadata_EV_DAT int not null,
        EV_DAT_PositedAt datetime2 not null,
        EV_DAT_Reliability decimal(5,2) not null,
        EV_DAT_Event_Date datetime2 not null,
        EV_DAT_StatementType char(1) not null,
        primary key (
            EV_DAT_EV_ID asc,
            EV_DAT_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_DAT_EV_ID,
            i.EV_DAT_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_DAT_Event_Date_Posit] p
            JOIN
                [dbo].[EV_DAT_Event_Date_Annex] a
            ON
                a.EV_DAT_ID = p.EV_DAT_ID
            WHERE
                p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
            AND
                p.EV_DAT_Event_Date = i.EV_DAT_Event_Date
            AND
                a.EV_DAT_PositedAt = i.EV_DAT_PositedAt
            AND
                a.EV_DAT_Reliability <> i.EV_DAT_Reliability
        )
        OR (
            i.EV_DAT_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[EV_DAT_Event_Date_Posit] p
                JOIN
                    [dbo].[EV_DAT_Event_Date_Annex] a
                ON
                    a.EV_DAT_ID = p.EV_DAT_ID
                WHERE
                    p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
                AND
                    p.EV_DAT_Event_Date <> i.EV_DAT_Event_Date
                AND
                    a.EV_DAT_PositedAt = i.EV_DAT_PositedAt
                AND
                    a.EV_DAT_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.EV_DAT_EV_ID = i.EV_DAT_EV_ID
                AND
                    j.EV_DAT_Event_Date <> i.EV_DAT_Event_Date
                AND
                    j.EV_DAT_PositedAt = i.EV_DAT_PositedAt
                AND
                    j.EV_DAT_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_DAT_Event_Date for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_DAT_Event_Date
    SELECT
        i.EV_DAT_EV_ID,
        i.Metadata_EV_DAT,
        i.EV_DAT_PositedAt,
        i.EV_DAT_Reliability,
        i.EV_DAT_Event_Date,
        CASE
            WHEN p.EV_DAT_ID is null
            THEN 'P' -- new posit
            WHEN a.EV_DAT_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[EV_DAT_Event_Date_Posit] p
    ON
        p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
    AND
        p.EV_DAT_Event_Date = i.EV_DAT_Event_Date
    LEFT JOIN
        [dbo].[EV_DAT_Event_Date_Annex] a
    ON
        a.EV_DAT_ID = p.EV_DAT_ID
    AND
        a.EV_DAT_PositedAt = i.EV_DAT_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_DAT_ID is null OR a.EV_DAT_ID is null);
    INSERT INTO @EV_DAT_Event_Date (
        EV_DAT_EV_ID,
        Metadata_EV_DAT,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date,
        EV_DAT_StatementType
    )
    SELECT
        x.EV_DAT_EV_ID,
        x.Metadata_EV_DAT,
        x.EV_DAT_PositedAt,
        x.EV_DAT_Reliability,
        x.EV_DAT_Event_Date,
        'X' -- existing data
    FROM (
        SELECT
            i.EV_DAT_EV_ID,
            a.Metadata_EV_DAT,
            a.EV_DAT_PositedAt,
            a.EV_DAT_Reliability,
            p.EV_DAT_Event_Date,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.EV_DAT_EV_ID,
                    a.EV_DAT_PositedAt
                ORDER BY
                    a.EV_DAT_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT EV_DAT_EV_ID FROM @EV_DAT_Event_Date) i
        JOIN
            [dbo].[EV_DAT_Event_Date_Posit] p
        ON
            p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
        JOIN
            [dbo].[EV_DAT_Event_Date_Annex] a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @EV_DAT_Event_Date n
        WHERE
            n.EV_DAT_EV_ID = x.EV_DAT_EV_ID
        AND
            n.EV_DAT_PositedAt = x.EV_DAT_PositedAt
    );
    DECLARE @retracted TABLE (
        EV_DAT_EV_ID int not null,
        Metadata_EV_DAT int not null,
        EV_DAT_PositedAt datetime2 not null,
        EV_DAT_Reliability decimal(5,2) not null,
        EV_DAT_Event_Date datetime2 not null,
        EV_DAT_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_DAT_EV_ID,
        Metadata_EV_DAT,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date,
        EV_DAT_StatementType
    )
    SELECT
        EV_DAT_EV_ID,
        Metadata_EV_DAT,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date,
        EV_DAT_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.EV_DAT_Reliability as previous_EV_DAT_Reliability,
            fol.EV_DAT_Reliability as following_EV_DAT_Reliability
        FROM
            @EV_DAT_Event_Date a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_DAT_Reliability
            FROM
                @EV_DAT_Event_Date p
            WHERE
                p.EV_DAT_EV_ID = a.EV_DAT_EV_ID
            AND
                p.EV_DAT_PositedAt < a.EV_DAT_PositedAt
            ORDER BY
                p.EV_DAT_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_DAT_Reliability
            FROM
                @EV_DAT_Event_Date p
            WHERE
                p.EV_DAT_EV_ID = a.EV_DAT_EV_ID
            AND
                p.EV_DAT_PositedAt > a.EV_DAT_PositedAt
            ORDER BY
                p.EV_DAT_PositedAt ASC
        ) fol
        WHERE
            (a.EV_DAT_Reliability = 0 AND isnull(pre.EV_DAT_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.EV_DAT_Reliability = 1 AND fol.EV_DAT_Reliability = 0)
    ) i
    WHERE
        i.EV_DAT_StatementType <> 'X'
    AND (
            (i.EV_DAT_Reliability = 0 AND i.previous_EV_DAT_Reliability = 1)
        OR
            (i.EV_DAT_Reliability = 1 AND i.following_EV_DAT_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @EV_DAT_Event_Date SELECT * FROM @retracted;
    INSERT INTO [dbo].[EV_DAT_Event_Date_Posit] (
        EV_DAT_EV_ID,
        EV_DAT_Event_Date
    )
    SELECT
        v.EV_DAT_EV_ID,
        v.EV_DAT_Event_Date
    FROM
        @EV_DAT_Event_Date v
    WHERE
        v.EV_DAT_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @EV_DAT_Event_Date w
        WHERE
            w.EV_DAT_StatementType = 'P'
        AND
            w.EV_DAT_EV_ID = v.EV_DAT_EV_ID
        AND
            w.EV_DAT_Event_Date = v.EV_DAT_Event_Date
        AND
            w.EV_DAT_PositedAt < v.EV_DAT_PositedAt
    );
    INSERT INTO [dbo].[EV_DAT_Event_Date_Annex] (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        v.Metadata_EV_DAT,
        p.EV_DAT_ID,
        v.EV_DAT_PositedAt,
        v.EV_DAT_Reliability
    FROM
        @EV_DAT_Event_Date v
    JOIN
        [dbo].[EV_DAT_Event_Date_Posit] p
    ON
        p.EV_DAT_EV_ID = v.EV_DAT_EV_ID
    AND
        p.EV_DAT_Event_Date = v.EV_DAT_Event_Date
    WHERE
        EV_DAT_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[EV_DAT_Event_Date_Annex] (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        v.Metadata_EV_DAT,
        e.EV_DAT_ID,
        v.EV_DAT_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_EV_DAT,
            n.EV_DAT_EV_ID,
            n.EV_DAT_PositedAt,
            n.EV_DAT_Event_Date
        FROM
            @EV_DAT_Event_Date n
        WHERE
            n.EV_DAT_StatementType in ('P', 'A')
        AND
            n.EV_DAT_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.EV_DAT_ID,
            p.EV_DAT_Event_Date
        FROM
            [dbo].[EV_DAT_Event_Date_Posit] p
        JOIN
            [dbo].[EV_DAT_Event_Date_Annex] a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
        AND
            a.EV_DAT_PositedAt = (
                SELECT
                    max(s.EV_DAT_PositedAt)
                FROM
                    [dbo].[EV_DAT_Event_Date_Annex] s
                WHERE
                    s.EV_DAT_ID = p.EV_DAT_ID
                AND
                    s.EV_DAT_PositedAt < v.EV_DAT_PositedAt
            )
        WHERE
            p.EV_DAT_EV_ID = v.EV_DAT_EV_ID
        AND
            a.EV_DAT_Reliability = 1
        ORDER BY
            a.EV_DAT_PositedAt DESC
    ) e
    WHERE
        e.EV_DAT_Event_Date <> v.EV_DAT_Event_Date
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_DAT_Event_Date_Annex] x
        WHERE
            x.EV_DAT_ID = e.EV_DAT_ID
        AND
            x.EV_DAT_PositedAt = v.EV_DAT_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience instead of INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_AUD_Event_Audience', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_AUD_Event_Audience];
GO
CREATE TRIGGER [dbo].[it_EV_AUD_Event_Audience] ON [dbo].[EV_AUD_Event_Audience]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_AUD_Event_Audience TABLE (
        EV_AUD_EV_ID int not null,
        Metadata_EV_AUD int not null,
        EV_AUD_PositedAt datetime2 not null,
        EV_AUD_Reliability decimal(5,2) not null,
        EV_AUD_Event_Audience int not null,
        EV_AUD_StatementType char(1) not null,
        primary key (
            EV_AUD_EV_ID asc,
            EV_AUD_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_AUD_EV_ID,
            i.EV_AUD_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_AUD_Event_Audience_Posit] p
            JOIN
                [dbo].[EV_AUD_Event_Audience_Annex] a
            ON
                a.EV_AUD_ID = p.EV_AUD_ID
            WHERE
                p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
            AND
                p.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
            AND
                a.EV_AUD_PositedAt = i.EV_AUD_PositedAt
            AND
                a.EV_AUD_Reliability <> i.EV_AUD_Reliability
        )
        OR (
            i.EV_AUD_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[EV_AUD_Event_Audience_Posit] p
                JOIN
                    [dbo].[EV_AUD_Event_Audience_Annex] a
                ON
                    a.EV_AUD_ID = p.EV_AUD_ID
                WHERE
                    p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
                AND
                    p.EV_AUD_Event_Audience <> i.EV_AUD_Event_Audience
                AND
                    a.EV_AUD_PositedAt = i.EV_AUD_PositedAt
                AND
                    a.EV_AUD_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.EV_AUD_EV_ID = i.EV_AUD_EV_ID
                AND
                    j.EV_AUD_Event_Audience <> i.EV_AUD_Event_Audience
                AND
                    j.EV_AUD_PositedAt = i.EV_AUD_PositedAt
                AND
                    j.EV_AUD_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_AUD_Event_Audience for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_AUD_Event_Audience
    SELECT
        i.EV_AUD_EV_ID,
        i.Metadata_EV_AUD,
        i.EV_AUD_PositedAt,
        i.EV_AUD_Reliability,
        i.EV_AUD_Event_Audience,
        CASE
            WHEN p.EV_AUD_ID is null
            THEN 'P' -- new posit
            WHEN a.EV_AUD_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[EV_AUD_Event_Audience_Posit] p
    ON
        p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
    AND
        p.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
    LEFT JOIN
        [dbo].[EV_AUD_Event_Audience_Annex] a
    ON
        a.EV_AUD_ID = p.EV_AUD_ID
    AND
        a.EV_AUD_PositedAt = i.EV_AUD_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_AUD_ID is null OR a.EV_AUD_ID is null);
    INSERT INTO @EV_AUD_Event_Audience (
        EV_AUD_EV_ID,
        Metadata_EV_AUD,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience,
        EV_AUD_StatementType
    )
    SELECT
        x.EV_AUD_EV_ID,
        x.Metadata_EV_AUD,
        x.EV_AUD_PositedAt,
        x.EV_AUD_Reliability,
        x.EV_AUD_Event_Audience,
        'X' -- existing data
    FROM (
        SELECT
            i.EV_AUD_EV_ID,
            a.Metadata_EV_AUD,
            a.EV_AUD_PositedAt,
            a.EV_AUD_Reliability,
            p.EV_AUD_Event_Audience,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.EV_AUD_EV_ID,
                    a.EV_AUD_PositedAt
                ORDER BY
                    a.EV_AUD_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT EV_AUD_EV_ID FROM @EV_AUD_Event_Audience) i
        JOIN
            [dbo].[EV_AUD_Event_Audience_Posit] p
        ON
            p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
        JOIN
            [dbo].[EV_AUD_Event_Audience_Annex] a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @EV_AUD_Event_Audience n
        WHERE
            n.EV_AUD_EV_ID = x.EV_AUD_EV_ID
        AND
            n.EV_AUD_PositedAt = x.EV_AUD_PositedAt
    );
    DECLARE @retracted TABLE (
        EV_AUD_EV_ID int not null,
        Metadata_EV_AUD int not null,
        EV_AUD_PositedAt datetime2 not null,
        EV_AUD_Reliability decimal(5,2) not null,
        EV_AUD_Event_Audience int not null,
        EV_AUD_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_AUD_EV_ID,
        Metadata_EV_AUD,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience,
        EV_AUD_StatementType
    )
    SELECT
        EV_AUD_EV_ID,
        Metadata_EV_AUD,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience,
        EV_AUD_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.EV_AUD_Reliability as previous_EV_AUD_Reliability,
            fol.EV_AUD_Reliability as following_EV_AUD_Reliability
        FROM
            @EV_AUD_Event_Audience a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_AUD_Reliability
            FROM
                @EV_AUD_Event_Audience p
            WHERE
                p.EV_AUD_EV_ID = a.EV_AUD_EV_ID
            AND
                p.EV_AUD_PositedAt < a.EV_AUD_PositedAt
            ORDER BY
                p.EV_AUD_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_AUD_Reliability
            FROM
                @EV_AUD_Event_Audience p
            WHERE
                p.EV_AUD_EV_ID = a.EV_AUD_EV_ID
            AND
                p.EV_AUD_PositedAt > a.EV_AUD_PositedAt
            ORDER BY
                p.EV_AUD_PositedAt ASC
        ) fol
        WHERE
            (a.EV_AUD_Reliability = 0 AND isnull(pre.EV_AUD_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.EV_AUD_Reliability = 1 AND fol.EV_AUD_Reliability = 0)
    ) i
    WHERE
        i.EV_AUD_StatementType <> 'X'
    AND (
            (i.EV_AUD_Reliability = 0 AND i.previous_EV_AUD_Reliability = 1)
        OR
            (i.EV_AUD_Reliability = 1 AND i.following_EV_AUD_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @EV_AUD_Event_Audience SELECT * FROM @retracted;
    INSERT INTO [dbo].[EV_AUD_Event_Audience_Posit] (
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    )
    SELECT
        v.EV_AUD_EV_ID,
        v.EV_AUD_Event_Audience
    FROM
        @EV_AUD_Event_Audience v
    WHERE
        v.EV_AUD_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @EV_AUD_Event_Audience w
        WHERE
            w.EV_AUD_StatementType = 'P'
        AND
            w.EV_AUD_EV_ID = v.EV_AUD_EV_ID
        AND
            w.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
        AND
            w.EV_AUD_PositedAt < v.EV_AUD_PositedAt
    );
    INSERT INTO [dbo].[EV_AUD_Event_Audience_Annex] (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        v.Metadata_EV_AUD,
        p.EV_AUD_ID,
        v.EV_AUD_PositedAt,
        v.EV_AUD_Reliability
    FROM
        @EV_AUD_Event_Audience v
    JOIN
        [dbo].[EV_AUD_Event_Audience_Posit] p
    ON
        p.EV_AUD_EV_ID = v.EV_AUD_EV_ID
    AND
        p.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
    WHERE
        EV_AUD_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[EV_AUD_Event_Audience_Annex] (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        v.Metadata_EV_AUD,
        e.EV_AUD_ID,
        v.EV_AUD_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_EV_AUD,
            n.EV_AUD_EV_ID,
            n.EV_AUD_PositedAt,
            n.EV_AUD_Event_Audience
        FROM
            @EV_AUD_Event_Audience n
        WHERE
            n.EV_AUD_StatementType in ('P', 'A')
        AND
            n.EV_AUD_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.EV_AUD_ID,
            p.EV_AUD_Event_Audience
        FROM
            [dbo].[EV_AUD_Event_Audience_Posit] p
        JOIN
            [dbo].[EV_AUD_Event_Audience_Annex] a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
        AND
            a.EV_AUD_PositedAt = (
                SELECT
                    max(s.EV_AUD_PositedAt)
                FROM
                    [dbo].[EV_AUD_Event_Audience_Annex] s
                WHERE
                    s.EV_AUD_ID = p.EV_AUD_ID
                AND
                    s.EV_AUD_PositedAt < v.EV_AUD_PositedAt
            )
        WHERE
            p.EV_AUD_EV_ID = v.EV_AUD_EV_ID
        AND
            a.EV_AUD_Reliability = 1
        ORDER BY
            a.EV_AUD_PositedAt DESC
    ) e
    WHERE
        e.EV_AUD_Event_Audience <> v.EV_AUD_Event_Audience
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_AUD_Event_Audience_Annex] x
        WHERE
            x.EV_AUD_ID = e.EV_AUD_ID
        AND
            x.EV_AUD_PositedAt = v.EV_AUD_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue instead of INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_REV_Event_Revenue', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_REV_Event_Revenue];
GO
CREATE TRIGGER [dbo].[it_EV_REV_Event_Revenue] ON [dbo].[EV_REV_Event_Revenue]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_REV_Event_Revenue TABLE (
        EV_REV_EV_ID int not null,
        Metadata_EV_REV int not null,
        EV_REV_PositedAt datetime2 not null,
        EV_REV_Reliability decimal(5,2) not null,
        EV_REV_Event_Revenue decimal(19,4) not null,
        EV_REV_StatementType char(1) not null,
        primary key (
            EV_REV_EV_ID asc,
            EV_REV_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_REV_EV_ID,
            i.EV_REV_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_REV_Event_Revenue_Posit] p
            JOIN
                [dbo].[EV_REV_Event_Revenue_Annex] a
            ON
                a.EV_REV_ID = p.EV_REV_ID
            WHERE
                p.EV_REV_EV_ID = i.EV_REV_EV_ID
            AND
                p.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
            AND
                a.EV_REV_PositedAt = i.EV_REV_PositedAt
            AND
                a.EV_REV_Reliability <> i.EV_REV_Reliability
        )
        OR (
            i.EV_REV_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[EV_REV_Event_Revenue_Posit] p
                JOIN
                    [dbo].[EV_REV_Event_Revenue_Annex] a
                ON
                    a.EV_REV_ID = p.EV_REV_ID
                WHERE
                    p.EV_REV_EV_ID = i.EV_REV_EV_ID
                AND
                    p.EV_REV_Event_Revenue <> i.EV_REV_Event_Revenue
                AND
                    a.EV_REV_PositedAt = i.EV_REV_PositedAt
                AND
                    a.EV_REV_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.EV_REV_EV_ID = i.EV_REV_EV_ID
                AND
                    j.EV_REV_Event_Revenue <> i.EV_REV_Event_Revenue
                AND
                    j.EV_REV_PositedAt = i.EV_REV_PositedAt
                AND
                    j.EV_REV_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_REV_Event_Revenue for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_REV_Event_Revenue
    SELECT
        i.EV_REV_EV_ID,
        i.Metadata_EV_REV,
        i.EV_REV_PositedAt,
        i.EV_REV_Reliability,
        i.EV_REV_Event_Revenue,
        CASE
            WHEN p.EV_REV_ID is null
            THEN 'P' -- new posit
            WHEN a.EV_REV_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[EV_REV_Event_Revenue_Posit] p
    ON
        p.EV_REV_EV_ID = i.EV_REV_EV_ID
    AND
        p.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
    LEFT JOIN
        [dbo].[EV_REV_Event_Revenue_Annex] a
    ON
        a.EV_REV_ID = p.EV_REV_ID
    AND
        a.EV_REV_PositedAt = i.EV_REV_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_REV_ID is null OR a.EV_REV_ID is null);
    INSERT INTO @EV_REV_Event_Revenue (
        EV_REV_EV_ID,
        Metadata_EV_REV,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue,
        EV_REV_StatementType
    )
    SELECT
        x.EV_REV_EV_ID,
        x.Metadata_EV_REV,
        x.EV_REV_PositedAt,
        x.EV_REV_Reliability,
        x.EV_REV_Event_Revenue,
        'X' -- existing data
    FROM (
        SELECT
            i.EV_REV_EV_ID,
            a.Metadata_EV_REV,
            a.EV_REV_PositedAt,
            a.EV_REV_Reliability,
            p.EV_REV_Event_Revenue,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.EV_REV_EV_ID,
                    a.EV_REV_PositedAt
                ORDER BY
                    a.EV_REV_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT EV_REV_EV_ID FROM @EV_REV_Event_Revenue) i
        JOIN
            [dbo].[EV_REV_Event_Revenue_Posit] p
        ON
            p.EV_REV_EV_ID = i.EV_REV_EV_ID
        JOIN
            [dbo].[EV_REV_Event_Revenue_Annex] a
        ON
            a.EV_REV_ID = p.EV_REV_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @EV_REV_Event_Revenue n
        WHERE
            n.EV_REV_EV_ID = x.EV_REV_EV_ID
        AND
            n.EV_REV_PositedAt = x.EV_REV_PositedAt
    );
    DECLARE @retracted TABLE (
        EV_REV_EV_ID int not null,
        Metadata_EV_REV int not null,
        EV_REV_PositedAt datetime2 not null,
        EV_REV_Reliability decimal(5,2) not null,
        EV_REV_Event_Revenue decimal(19,4) not null,
        EV_REV_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_REV_EV_ID,
        Metadata_EV_REV,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue,
        EV_REV_StatementType
    )
    SELECT
        EV_REV_EV_ID,
        Metadata_EV_REV,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue,
        EV_REV_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.EV_REV_Reliability as previous_EV_REV_Reliability,
            fol.EV_REV_Reliability as following_EV_REV_Reliability
        FROM
            @EV_REV_Event_Revenue a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_REV_Reliability
            FROM
                @EV_REV_Event_Revenue p
            WHERE
                p.EV_REV_EV_ID = a.EV_REV_EV_ID
            AND
                p.EV_REV_PositedAt < a.EV_REV_PositedAt
            ORDER BY
                p.EV_REV_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_REV_Reliability
            FROM
                @EV_REV_Event_Revenue p
            WHERE
                p.EV_REV_EV_ID = a.EV_REV_EV_ID
            AND
                p.EV_REV_PositedAt > a.EV_REV_PositedAt
            ORDER BY
                p.EV_REV_PositedAt ASC
        ) fol
        WHERE
            (a.EV_REV_Reliability = 0 AND isnull(pre.EV_REV_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.EV_REV_Reliability = 1 AND fol.EV_REV_Reliability = 0)
    ) i
    WHERE
        i.EV_REV_StatementType <> 'X'
    AND (
            (i.EV_REV_Reliability = 0 AND i.previous_EV_REV_Reliability = 1)
        OR
            (i.EV_REV_Reliability = 1 AND i.following_EV_REV_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @EV_REV_Event_Revenue SELECT * FROM @retracted;
    INSERT INTO [dbo].[EV_REV_Event_Revenue_Posit] (
        EV_REV_EV_ID,
        EV_REV_Event_Revenue
    )
    SELECT
        v.EV_REV_EV_ID,
        v.EV_REV_Event_Revenue
    FROM
        @EV_REV_Event_Revenue v
    WHERE
        v.EV_REV_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @EV_REV_Event_Revenue w
        WHERE
            w.EV_REV_StatementType = 'P'
        AND
            w.EV_REV_EV_ID = v.EV_REV_EV_ID
        AND
            w.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
        AND
            w.EV_REV_PositedAt < v.EV_REV_PositedAt
    );
    INSERT INTO [dbo].[EV_REV_Event_Revenue_Annex] (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        v.Metadata_EV_REV,
        p.EV_REV_ID,
        v.EV_REV_PositedAt,
        v.EV_REV_Reliability
    FROM
        @EV_REV_Event_Revenue v
    JOIN
        [dbo].[EV_REV_Event_Revenue_Posit] p
    ON
        p.EV_REV_EV_ID = v.EV_REV_EV_ID
    AND
        p.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
    WHERE
        EV_REV_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[EV_REV_Event_Revenue_Annex] (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        v.Metadata_EV_REV,
        e.EV_REV_ID,
        v.EV_REV_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_EV_REV,
            n.EV_REV_EV_ID,
            n.EV_REV_PositedAt,
            n.EV_REV_Event_Revenue
        FROM
            @EV_REV_Event_Revenue n
        WHERE
            n.EV_REV_StatementType in ('P', 'A')
        AND
            n.EV_REV_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.EV_REV_ID,
            p.EV_REV_Event_Revenue
        FROM
            [dbo].[EV_REV_Event_Revenue_Posit] p
        JOIN
            [dbo].[EV_REV_Event_Revenue_Annex] a
        ON
            a.EV_REV_ID = p.EV_REV_ID
        AND
            a.EV_REV_PositedAt = (
                SELECT
                    max(s.EV_REV_PositedAt)
                FROM
                    [dbo].[EV_REV_Event_Revenue_Annex] s
                WHERE
                    s.EV_REV_ID = p.EV_REV_ID
                AND
                    s.EV_REV_PositedAt < v.EV_REV_PositedAt
            )
        WHERE
            p.EV_REV_EV_ID = v.EV_REV_EV_ID
        AND
            a.EV_REV_Reliability = 1
        ORDER BY
            a.EV_REV_PositedAt DESC
    ) e
    WHERE
        e.EV_REV_Event_Revenue <> v.EV_REV_Event_Revenue
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_REV_Event_Revenue_Annex] x
        WHERE
            x.EV_REV_ID = e.EV_REV_ID
        AND
            x.EV_REV_PositedAt = v.EV_REV_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_NAM_Stage_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_NAM_Stage_Name];
GO
CREATE TRIGGER [dbo].[it_ST_NAM_Stage_Name] ON [dbo].[ST_NAM_Stage_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_NAM_Stage_Name TABLE (
        ST_NAM_ST_ID int not null,
        Metadata_ST_NAM int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_PositedAt datetime2 not null,
        ST_NAM_Reliability decimal(5,2) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_Checksum varbinary(16) not null,
        ST_NAM_StatementType char(1) not null,
        primary key (
            ST_NAM_ST_ID asc,
            ST_NAM_ChangedAt desc,
            ST_NAM_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_NAM_ST_ID,
            i.ST_NAM_ChangedAt,
            i.ST_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[ST_NAM_Stage_Name_Posit] p
            JOIN
                [dbo].[ST_NAM_Stage_Name_Annex] a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            WHERE
                p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
            AND
                p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
            AND
                p.ST_NAM_Checksum = dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max)))
            AND
                a.ST_NAM_PositedAt = i.ST_NAM_PositedAt
            AND
                a.ST_NAM_Reliability <> i.ST_NAM_Reliability
        )
        OR (
            i.ST_NAM_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[ST_NAM_Stage_Name_Posit] p
                JOIN
                    [dbo].[ST_NAM_Stage_Name_Annex] a
                ON
                    a.ST_NAM_ID = p.ST_NAM_ID
                WHERE
                    p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
                AND
                    p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
                AND
                    p.ST_NAM_Checksum <> dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max)))
                AND
                    a.ST_NAM_PositedAt = i.ST_NAM_PositedAt
                AND
                    a.ST_NAM_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.ST_NAM_ST_ID = i.ST_NAM_ST_ID
                AND
                    j.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
                AND
                    dbo.MD5(cast(j.ST_NAM_Stage_Name as varbinary(max))) <> dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max)))
                AND
                    j.ST_NAM_PositedAt = i.ST_NAM_PositedAt
                AND
                    j.ST_NAM_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_NAM_Stage_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @ST_NAM_Stage_Name
    SELECT
        i.ST_NAM_ST_ID,
        i.Metadata_ST_NAM,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_PositedAt,
        i.ST_NAM_Reliability,
        i.ST_NAM_Stage_Name,
        dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max))),
        CASE
            WHEN p.ST_NAM_ID is null
            THEN 'P' -- new posit
            WHEN a.ST_NAM_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ST_NAM_Stage_Name_Posit] p
    ON
        p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
    AND
        p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
    AND
        p.ST_NAM_Checksum = dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max)))
    LEFT JOIN
        [dbo].[ST_NAM_Stage_Name_Annex] a
    ON
        a.ST_NAM_ID = p.ST_NAM_ID
    AND
        a.ST_NAM_PositedAt = i.ST_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_NAM_ID is null OR a.ST_NAM_ID is null);
    INSERT INTO @ST_NAM_Stage_Name (
        ST_NAM_ST_ID,
        Metadata_ST_NAM,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name,
        ST_NAM_Checksum,
        ST_NAM_StatementType
    )
    SELECT
        x.ST_NAM_ST_ID,
        x.Metadata_ST_NAM,
        x.ST_NAM_ChangedAt,
        x.ST_NAM_PositedAt,
        x.ST_NAM_Reliability,
        x.ST_NAM_Stage_Name,
        x.ST_NAM_Checksum,
        'X' -- existing data
    FROM (
        SELECT
            i.ST_NAM_ST_ID,
            a.Metadata_ST_NAM,
            p.ST_NAM_ChangedAt,
            a.ST_NAM_PositedAt,
            a.ST_NAM_Reliability,
            p.ST_NAM_Stage_Name,
            p.ST_NAM_Checksum,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.ST_NAM_ST_ID,
                    p.ST_NAM_ChangedAt,
                    a.ST_NAM_PositedAt
                ORDER BY
                    a.ST_NAM_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT ST_NAM_ST_ID FROM @ST_NAM_Stage_Name) i
        JOIN
            [dbo].[ST_NAM_Stage_Name_Posit] p
        ON
            p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
        JOIN
            [dbo].[ST_NAM_Stage_Name_Annex] a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @ST_NAM_Stage_Name n
        WHERE
            n.ST_NAM_ST_ID = x.ST_NAM_ST_ID
        AND
            n.ST_NAM_ChangedAt = x.ST_NAM_ChangedAt
        AND
            n.ST_NAM_PositedAt = x.ST_NAM_PositedAt
    );
    DECLARE @retracted TABLE (
        ST_NAM_ST_ID int not null,
        Metadata_ST_NAM int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_PositedAt datetime2 not null,
        ST_NAM_Reliability decimal(5,2) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_Checksum varbinary(16) not null,
        ST_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_NAM_ST_ID,
        Metadata_ST_NAM,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name,
        ST_NAM_Checksum,
        ST_NAM_StatementType
    )
    SELECT
        ST_NAM_ST_ID,
        Metadata_ST_NAM,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name,
        ST_NAM_Checksum,
        ST_NAM_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.ST_NAM_Reliability as previous_ST_NAM_Reliability,
            fol.ST_NAM_Reliability as following_ST_NAM_Reliability
        FROM
            @ST_NAM_Stage_Name a
        OUTER APPLY (
            SELECT TOP 1
                p.ST_NAM_Reliability
            FROM
                @ST_NAM_Stage_Name p
            WHERE
                p.ST_NAM_ST_ID = a.ST_NAM_ST_ID
            AND
                p.ST_NAM_ChangedAt = a.ST_NAM_ChangedAt
            AND
                p.ST_NAM_PositedAt < a.ST_NAM_PositedAt
            ORDER BY
                p.ST_NAM_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.ST_NAM_Reliability
            FROM
                @ST_NAM_Stage_Name p
            WHERE
                p.ST_NAM_ST_ID = a.ST_NAM_ST_ID
            AND
                p.ST_NAM_ChangedAt = a.ST_NAM_ChangedAt
            AND
                p.ST_NAM_PositedAt > a.ST_NAM_PositedAt
            ORDER BY
                p.ST_NAM_PositedAt ASC
        ) fol
        WHERE
            (a.ST_NAM_Reliability = 0 AND isnull(pre.ST_NAM_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.ST_NAM_Reliability = 1 AND fol.ST_NAM_Reliability = 0)
    ) i
    WHERE
        i.ST_NAM_StatementType <> 'X'
    AND (
            (i.ST_NAM_Reliability = 0 AND i.previous_ST_NAM_Reliability = 1)
        OR
            (i.ST_NAM_Reliability = 1 AND i.following_ST_NAM_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @ST_NAM_Stage_Name SELECT * FROM @retracted;
    INSERT INTO [dbo].[ST_NAM_Stage_Name_Posit] (
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    SELECT
        v.ST_NAM_ST_ID,
        v.ST_NAM_ChangedAt,
        v.ST_NAM_Stage_Name
    FROM
        @ST_NAM_Stage_Name v
    WHERE
        v.ST_NAM_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @ST_NAM_Stage_Name w
        WHERE
            w.ST_NAM_StatementType = 'P'
        AND
            w.ST_NAM_ST_ID = v.ST_NAM_ST_ID
        AND
            w.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
        AND
            w.ST_NAM_Checksum = v.ST_NAM_Checksum
        AND
            w.ST_NAM_PositedAt < v.ST_NAM_PositedAt
    );
    INSERT INTO [dbo].[ST_NAM_Stage_Name_Annex] (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        v.Metadata_ST_NAM,
        p.ST_NAM_ID,
        v.ST_NAM_PositedAt,
        v.ST_NAM_Reliability
    FROM
        @ST_NAM_Stage_Name v
    JOIN
        [dbo].[ST_NAM_Stage_Name_Posit] p
    ON
        p.ST_NAM_ST_ID = v.ST_NAM_ST_ID
    AND
        p.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
    AND
        p.ST_NAM_Checksum = v.ST_NAM_Checksum
    WHERE
        ST_NAM_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[ST_NAM_Stage_Name_Annex] (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        v.Metadata_ST_NAM,
        e.ST_NAM_ID,
        v.ST_NAM_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_ST_NAM,
            n.ST_NAM_ST_ID,
            n.ST_NAM_ChangedAt,
            n.ST_NAM_PositedAt,
            n.ST_NAM_Checksum
        FROM
            @ST_NAM_Stage_Name n
        WHERE
            n.ST_NAM_StatementType in ('P', 'A')
        AND
            n.ST_NAM_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.ST_NAM_ID,
            p.ST_NAM_Checksum
        FROM
            [dbo].[ST_NAM_Stage_Name_Posit] p
        JOIN
            [dbo].[ST_NAM_Stage_Name_Annex] a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
        AND
            a.ST_NAM_PositedAt = (
                SELECT
                    max(s.ST_NAM_PositedAt)
                FROM
                    [dbo].[ST_NAM_Stage_Name_Annex] s
                WHERE
                    s.ST_NAM_ID = p.ST_NAM_ID
                AND
                    s.ST_NAM_PositedAt < v.ST_NAM_PositedAt
            )
        WHERE
            p.ST_NAM_ST_ID = v.ST_NAM_ST_ID
        AND
            p.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
        AND
            a.ST_NAM_Reliability = 1
        ORDER BY
            a.ST_NAM_PositedAt DESC
    ) e
    WHERE
        e.ST_NAM_Checksum <> v.ST_NAM_Checksum
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_NAM_Stage_Name_Annex] x
        WHERE
            x.ST_NAM_ID = e.ST_NAM_ID
        AND
            x.ST_NAM_PositedAt = v.ST_NAM_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Stage_Location instead of INSERT trigger on ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_LOC_Stage_Location', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_LOC_Stage_Location];
GO
CREATE TRIGGER [dbo].[it_ST_LOC_Stage_Location] ON [dbo].[ST_LOC_Stage_Location]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_LOC_Stage_Location TABLE (
        ST_LOC_ST_ID int not null,
        Metadata_ST_LOC int not null,
        ST_LOC_PositedAt datetime2 not null,
        ST_LOC_Reliability decimal(5,2) not null,
        ST_LOC_Stage_Location geography not null,
        ST_LOC_Checksum varbinary(16) not null,
        ST_LOC_StatementType char(1) not null,
        primary key (
            ST_LOC_ST_ID asc,
            ST_LOC_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_LOC_ST_ID,
            i.ST_LOC_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[ST_LOC_Stage_Location_Posit] p
            JOIN
                [dbo].[ST_LOC_Stage_Location_Annex] a
            ON
                a.ST_LOC_ID = p.ST_LOC_ID
            WHERE
                p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
            AND
                p.ST_LOC_Checksum = dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max)))
            AND
                a.ST_LOC_PositedAt = i.ST_LOC_PositedAt
            AND
                a.ST_LOC_Reliability <> i.ST_LOC_Reliability
        )
        OR (
            i.ST_LOC_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[ST_LOC_Stage_Location_Posit] p
                JOIN
                    [dbo].[ST_LOC_Stage_Location_Annex] a
                ON
                    a.ST_LOC_ID = p.ST_LOC_ID
                WHERE
                    p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
                AND
                    p.ST_LOC_Checksum <> dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max)))
                AND
                    a.ST_LOC_PositedAt = i.ST_LOC_PositedAt
                AND
                    a.ST_LOC_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.ST_LOC_ST_ID = i.ST_LOC_ST_ID
                AND
                    dbo.MD5(cast(j.ST_LOC_Stage_Location as varbinary(max))) <> dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max)))
                AND
                    j.ST_LOC_PositedAt = i.ST_LOC_PositedAt
                AND
                    j.ST_LOC_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_LOC_Stage_Location for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @ST_LOC_Stage_Location
    SELECT
        i.ST_LOC_ST_ID,
        i.Metadata_ST_LOC,
        i.ST_LOC_PositedAt,
        i.ST_LOC_Reliability,
        i.ST_LOC_Stage_Location,
        dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))),
        CASE
            WHEN p.ST_LOC_ID is null
            THEN 'P' -- new posit
            WHEN a.ST_LOC_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ST_LOC_Stage_Location_Posit] p
    ON
        p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
    AND
        p.ST_LOC_Checksum = dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max)))
    LEFT JOIN
        [dbo].[ST_LOC_Stage_Location_Annex] a
    ON
        a.ST_LOC_ID = p.ST_LOC_ID
    AND
        a.ST_LOC_PositedAt = i.ST_LOC_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_LOC_ID is null OR a.ST_LOC_ID is null);
    INSERT INTO @ST_LOC_Stage_Location (
        ST_LOC_ST_ID,
        Metadata_ST_LOC,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum,
        ST_LOC_StatementType
    )
    SELECT
        x.ST_LOC_ST_ID,
        x.Metadata_ST_LOC,
        x.ST_LOC_PositedAt,
        x.ST_LOC_Reliability,
        x.ST_LOC_Stage_Location,
        x.ST_LOC_Checksum,
        'X' -- existing data
    FROM (
        SELECT
            i.ST_LOC_ST_ID,
            a.Metadata_ST_LOC,
            a.ST_LOC_PositedAt,
            a.ST_LOC_Reliability,
            p.ST_LOC_Stage_Location,
            p.ST_LOC_Checksum,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.ST_LOC_ST_ID,
                    a.ST_LOC_PositedAt
                ORDER BY
                    a.ST_LOC_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT ST_LOC_ST_ID FROM @ST_LOC_Stage_Location) i
        JOIN
            [dbo].[ST_LOC_Stage_Location_Posit] p
        ON
            p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
        JOIN
            [dbo].[ST_LOC_Stage_Location_Annex] a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @ST_LOC_Stage_Location n
        WHERE
            n.ST_LOC_ST_ID = x.ST_LOC_ST_ID
        AND
            n.ST_LOC_PositedAt = x.ST_LOC_PositedAt
    );
    DECLARE @retracted TABLE (
        ST_LOC_ST_ID int not null,
        Metadata_ST_LOC int not null,
        ST_LOC_PositedAt datetime2 not null,
        ST_LOC_Reliability decimal(5,2) not null,
        ST_LOC_Stage_Location geography not null,
        ST_LOC_Checksum varbinary(16) not null,
        ST_LOC_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_LOC_ST_ID,
        Metadata_ST_LOC,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum,
        ST_LOC_StatementType
    )
    SELECT
        ST_LOC_ST_ID,
        Metadata_ST_LOC,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum,
        ST_LOC_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.ST_LOC_Reliability as previous_ST_LOC_Reliability,
            fol.ST_LOC_Reliability as following_ST_LOC_Reliability
        FROM
            @ST_LOC_Stage_Location a
        OUTER APPLY (
            SELECT TOP 1
                p.ST_LOC_Reliability
            FROM
                @ST_LOC_Stage_Location p
            WHERE
                p.ST_LOC_ST_ID = a.ST_LOC_ST_ID
            AND
                p.ST_LOC_PositedAt < a.ST_LOC_PositedAt
            ORDER BY
                p.ST_LOC_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.ST_LOC_Reliability
            FROM
                @ST_LOC_Stage_Location p
            WHERE
                p.ST_LOC_ST_ID = a.ST_LOC_ST_ID
            AND
                p.ST_LOC_PositedAt > a.ST_LOC_PositedAt
            ORDER BY
                p.ST_LOC_PositedAt ASC
        ) fol
        WHERE
            (a.ST_LOC_Reliability = 0 AND isnull(pre.ST_LOC_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.ST_LOC_Reliability = 1 AND fol.ST_LOC_Reliability = 0)
    ) i
    WHERE
        i.ST_LOC_StatementType <> 'X'
    AND (
            (i.ST_LOC_Reliability = 0 AND i.previous_ST_LOC_Reliability = 1)
        OR
            (i.ST_LOC_Reliability = 1 AND i.following_ST_LOC_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @ST_LOC_Stage_Location SELECT * FROM @retracted;
    INSERT INTO [dbo].[ST_LOC_Stage_Location_Posit] (
        ST_LOC_ST_ID,
        ST_LOC_Stage_Location
    )
    SELECT
        v.ST_LOC_ST_ID,
        v.ST_LOC_Stage_Location
    FROM
        @ST_LOC_Stage_Location v
    WHERE
        v.ST_LOC_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @ST_LOC_Stage_Location w
        WHERE
            w.ST_LOC_StatementType = 'P'
        AND
            w.ST_LOC_ST_ID = v.ST_LOC_ST_ID
        AND
            w.ST_LOC_Checksum = v.ST_LOC_Checksum
        AND
            w.ST_LOC_PositedAt < v.ST_LOC_PositedAt
    );
    INSERT INTO [dbo].[ST_LOC_Stage_Location_Annex] (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        v.Metadata_ST_LOC,
        p.ST_LOC_ID,
        v.ST_LOC_PositedAt,
        v.ST_LOC_Reliability
    FROM
        @ST_LOC_Stage_Location v
    JOIN
        [dbo].[ST_LOC_Stage_Location_Posit] p
    ON
        p.ST_LOC_ST_ID = v.ST_LOC_ST_ID
    AND
        p.ST_LOC_Checksum = v.ST_LOC_Checksum
    WHERE
        ST_LOC_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[ST_LOC_Stage_Location_Annex] (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        v.Metadata_ST_LOC,
        e.ST_LOC_ID,
        v.ST_LOC_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_ST_LOC,
            n.ST_LOC_ST_ID,
            n.ST_LOC_PositedAt,
            n.ST_LOC_Checksum
        FROM
            @ST_LOC_Stage_Location n
        WHERE
            n.ST_LOC_StatementType in ('P', 'A')
        AND
            n.ST_LOC_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.ST_LOC_ID,
            p.ST_LOC_Checksum
        FROM
            [dbo].[ST_LOC_Stage_Location_Posit] p
        JOIN
            [dbo].[ST_LOC_Stage_Location_Annex] a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
        AND
            a.ST_LOC_PositedAt = (
                SELECT
                    max(s.ST_LOC_PositedAt)
                FROM
                    [dbo].[ST_LOC_Stage_Location_Annex] s
                WHERE
                    s.ST_LOC_ID = p.ST_LOC_ID
                AND
                    s.ST_LOC_PositedAt < v.ST_LOC_PositedAt
            )
        WHERE
            p.ST_LOC_ST_ID = v.ST_LOC_ST_ID
        AND
            a.ST_LOC_Reliability = 1
        ORDER BY
            a.ST_LOC_PositedAt DESC
    ) e
    WHERE
        e.ST_LOC_Checksum <> v.ST_LOC_Checksum
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_LOC_Stage_Location_Annex] x
        WHERE
            x.ST_LOC_ID = e.ST_LOC_ID
        AND
            x.ST_LOC_PositedAt = v.ST_LOC_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average instead of INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_AVG_Stage_Average', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_AVG_Stage_Average];
GO
CREATE TRIGGER [dbo].[it_ST_AVG_Stage_Average] ON [dbo].[ST_AVG_Stage_Average]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null,
        ST_AVG_StatementType char(1) not null,
        primary key (
            ST_AVG_ST_ID asc,
            ST_AVG_ChangedAt desc,
            ST_AVG_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_AVG_ST_ID,
            i.ST_AVG_ChangedAt,
            i.ST_AVG_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[ST_AVG_Stage_Average_Posit] p
            JOIN
                [dbo].[ST_AVG_Stage_Average_Annex] a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            WHERE
                p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
            AND
                p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
            AND
                p.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
            AND
                a.ST_AVG_PositedAt = i.ST_AVG_PositedAt
            AND
                a.ST_AVG_Reliability <> i.ST_AVG_Reliability
        )
        OR (
            i.ST_AVG_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[ST_AVG_Stage_Average_Posit] p
                JOIN
                    [dbo].[ST_AVG_Stage_Average_Annex] a
                ON
                    a.ST_AVG_ID = p.ST_AVG_ID
                WHERE
                    p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
                AND
                    p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
                AND
                    p.ST_AVG_UTL_ID <> i.ST_AVG_UTL_ID
                AND
                    a.ST_AVG_PositedAt = i.ST_AVG_PositedAt
                AND
                    a.ST_AVG_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.ST_AVG_ST_ID = i.ST_AVG_ST_ID
                AND
                    j.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
                AND
                    j.ST_AVG_UTL_ID <> i.ST_AVG_UTL_ID
                AND
                    j.ST_AVG_PositedAt = i.ST_AVG_PositedAt
                AND
                    j.ST_AVG_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_AVG_Stage_Average for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        i.ST_AVG_ST_ID,
        i.Metadata_ST_AVG,
        i.ST_AVG_ChangedAt,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Reliability,
        i.ST_AVG_UTL_ID,
        CASE
            WHEN p.ST_AVG_ID is null
            THEN 'P' -- new posit
            WHEN a.ST_AVG_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
    AND
        p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
    AND
        p.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
    LEFT JOIN
        [dbo].[ST_AVG_Stage_Average_Annex] a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = i.ST_AVG_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_AVG_ID is null OR a.ST_AVG_ID is null);
    INSERT INTO @ST_AVG_Stage_Average (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID,
        ST_AVG_StatementType
    )
    SELECT
        x.ST_AVG_ST_ID,
        x.Metadata_ST_AVG,
        x.ST_AVG_ChangedAt,
        x.ST_AVG_PositedAt,
        x.ST_AVG_Reliability,
        x.ST_AVG_UTL_ID,
        'X' -- existing data
    FROM (
        SELECT
            i.ST_AVG_ST_ID,
            a.Metadata_ST_AVG,
            p.ST_AVG_ChangedAt,
            a.ST_AVG_PositedAt,
            a.ST_AVG_Reliability,
            p.ST_AVG_UTL_ID,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.ST_AVG_ST_ID,
                    p.ST_AVG_ChangedAt,
                    a.ST_AVG_PositedAt
                ORDER BY
                    a.ST_AVG_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT ST_AVG_ST_ID FROM @ST_AVG_Stage_Average) i
        JOIN
            [dbo].[ST_AVG_Stage_Average_Posit] p
        ON
            p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
        JOIN
            [dbo].[ST_AVG_Stage_Average_Annex] a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @ST_AVG_Stage_Average n
        WHERE
            n.ST_AVG_ST_ID = x.ST_AVG_ST_ID
        AND
            n.ST_AVG_ChangedAt = x.ST_AVG_ChangedAt
        AND
            n.ST_AVG_PositedAt = x.ST_AVG_PositedAt
    );
    DECLARE @retracted TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null,
        ST_AVG_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID,
        ST_AVG_StatementType
    )
    SELECT
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID,
        ST_AVG_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.ST_AVG_Reliability as previous_ST_AVG_Reliability,
            fol.ST_AVG_Reliability as following_ST_AVG_Reliability
        FROM
            @ST_AVG_Stage_Average a
        OUTER APPLY (
            SELECT TOP 1
                p.ST_AVG_Reliability
            FROM
                @ST_AVG_Stage_Average p
            WHERE
                p.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            AND
                p.ST_AVG_ChangedAt = a.ST_AVG_ChangedAt
            AND
                p.ST_AVG_PositedAt < a.ST_AVG_PositedAt
            ORDER BY
                p.ST_AVG_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.ST_AVG_Reliability
            FROM
                @ST_AVG_Stage_Average p
            WHERE
                p.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            AND
                p.ST_AVG_ChangedAt = a.ST_AVG_ChangedAt
            AND
                p.ST_AVG_PositedAt > a.ST_AVG_PositedAt
            ORDER BY
                p.ST_AVG_PositedAt ASC
        ) fol
        WHERE
            (a.ST_AVG_Reliability = 0 AND isnull(pre.ST_AVG_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.ST_AVG_Reliability = 1 AND fol.ST_AVG_Reliability = 0)
    ) i
    WHERE
        i.ST_AVG_StatementType <> 'X'
    AND (
            (i.ST_AVG_Reliability = 0 AND i.previous_ST_AVG_Reliability = 1)
        OR
            (i.ST_AVG_Reliability = 1 AND i.following_ST_AVG_Reliability = 0)
        );
    -- the new values that only restate the previous version, which are skipped, though what they correct is retracted
    DECLARE @skipped TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_UTL_ID tinyint not null
    );
    IF EXISTS (
        SELECT TOP 1
            ST_AVG_StatementType
        FROM
            @ST_AVG_Stage_Average
        WHERE
            ST_AVG_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @restated TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null,
        ST_AVG_StatementType char(1) not null
    );
    INSERT INTO @skipped (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_UTL_ID
    )
    SELECT
        a.ST_AVG_ST_ID,
        a.Metadata_ST_AVG,
        a.ST_AVG_ChangedAt,
        a.ST_AVG_PositedAt,
        a.ST_AVG_UTL_ID
    FROM
        @ST_AVG_Stage_Average a
    CROSS APPLY (
        SELECT TOP 1
            h.ST_AVG_UTL_ID
        FROM
            @ST_AVG_Stage_Average h
        WHERE
            h.ST_AVG_ST_ID = a.ST_AVG_ST_ID
        AND
            h.ST_AVG_ChangedAt < a.ST_AVG_ChangedAt
        ORDER BY
            h.ST_AVG_ChangedAt DESC,
            h.ST_AVG_PositedAt DESC
    ) pre
    WHERE
        a.ST_AVG_StatementType in ('P', 'A')
    AND
        a.ST_AVG_Reliability = 1
    AND
        a.ST_AVG_UTL_ID = pre.ST_AVG_UTL_ID;
    INSERT INTO @restated (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID,
        ST_AVG_StatementType
    )
    SELECT
        x.ST_AVG_ST_ID,
        x.Metadata_ST_AVG,
        x.ST_AVG_ChangedAt,
        CASE
            WHEN x.previous_ST_AVG_PositedAt < x.ST_AVG_PositedAt THEN x.ST_AVG_PositedAt
            ELSE x.previous_ST_AVG_PositedAt
        END,
        0, -- quench the existing restatements
        x.ST_AVG_UTL_ID,
        CASE
            WHEN x.previous_ST_AVG_PositedAt < x.ST_AVG_PositedAt THEN 'D' -- physical delete
            ELSE 'A' -- logical delete
        END
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.ST_AVG_PositedAt as previous_ST_AVG_PositedAt
        FROM
            @ST_AVG_Stage_Average a
        OUTER APPLY (
            SELECT TOP 1
                *
            FROM
                @ST_AVG_Stage_Average h
            WHERE
                h.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            AND
                h.ST_AVG_ChangedAt < a.ST_AVG_ChangedAt
            ORDER BY
                h.ST_AVG_ChangedAt DESC,
                h.ST_AVG_PositedAt DESC
        ) pre
        WHERE
            a.ST_AVG_UTL_ID = pre.ST_AVG_UTL_ID
    ) x
    WHERE
        x.ST_AVG_StatementType = 'X'; -- quench
    -- add the quenches
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        *
    FROM (
        DELETE @restated
        OUTPUT deleted.*
        WHERE ST_AVG_StatementType = 'A'
    ) d;
    -- perform any remaining physical deletes
    DELETE a
    FROM
        @restated i
    JOIN
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
    AND
        p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
    AND
        p.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
    JOIN
        [dbo].[ST_AVG_Stage_Average_Annex] a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = i.ST_AVG_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @ST_AVG_Stage_Average SELECT * FROM @retracted;
    INSERT INTO [dbo].[ST_AVG_Stage_Average_Posit] (
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    SELECT
        v.ST_AVG_ST_ID,
        v.ST_AVG_ChangedAt,
        v.ST_AVG_UTL_ID
    FROM
        @ST_AVG_Stage_Average v
    WHERE
        v.ST_AVG_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @ST_AVG_Stage_Average w
        WHERE
            w.ST_AVG_StatementType = 'P'
        AND
            w.ST_AVG_ST_ID = v.ST_AVG_ST_ID
        AND
            w.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
        AND
            w.ST_AVG_UTL_ID = v.ST_AVG_UTL_ID
        AND
            w.ST_AVG_PositedAt < v.ST_AVG_PositedAt
    );
    INSERT INTO [dbo].[ST_AVG_Stage_Average_Annex] (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        v.Metadata_ST_AVG,
        p.ST_AVG_ID,
        v.ST_AVG_PositedAt,
        v.ST_AVG_Reliability
    FROM
        @ST_AVG_Stage_Average v
    JOIN
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ST_ID = v.ST_AVG_ST_ID
    AND
        p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
    AND
        p.ST_AVG_UTL_ID = v.ST_AVG_UTL_ID
    WHERE
        ST_AVG_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[ST_AVG_Stage_Average_Annex] (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        v.Metadata_ST_AVG,
        e.ST_AVG_ID,
        v.ST_AVG_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_ST_AVG,
            n.ST_AVG_ST_ID,
            n.ST_AVG_ChangedAt,
            n.ST_AVG_PositedAt,
            n.ST_AVG_UTL_ID
        FROM
            @ST_AVG_Stage_Average n
        WHERE
            n.ST_AVG_StatementType in ('P', 'A')
        AND
            n.ST_AVG_Reliability = 1
        UNION ALL
        SELECT
            k.Metadata_ST_AVG,
            k.ST_AVG_ST_ID,
            k.ST_AVG_ChangedAt,
            k.ST_AVG_PositedAt,
            k.ST_AVG_UTL_ID
        FROM
            @skipped k
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.ST_AVG_ID,
            p.ST_AVG_UTL_ID
        FROM
            [dbo].[ST_AVG_Stage_Average_Posit] p
        JOIN
            [dbo].[ST_AVG_Stage_Average_Annex] a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
        AND
            a.ST_AVG_PositedAt = (
                SELECT
                    max(s.ST_AVG_PositedAt)
                FROM
                    [dbo].[ST_AVG_Stage_Average_Annex] s
                WHERE
                    s.ST_AVG_ID = p.ST_AVG_ID
                AND
                    s.ST_AVG_PositedAt < v.ST_AVG_PositedAt
            )
        WHERE
            p.ST_AVG_ST_ID = v.ST_AVG_ST_ID
        AND
            p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
        AND
            a.ST_AVG_Reliability = 1
        ORDER BY
            a.ST_AVG_PositedAt DESC
    ) e
    WHERE
        e.ST_AVG_UTL_ID <> v.ST_AVG_UTL_ID
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_AVG_Stage_Average_Annex] x
        WHERE
            x.ST_AVG_ID = e.ST_AVG_ID
        AND
            x.ST_AVG_PositedAt = v.ST_AVG_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum instead of INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_MIN_Stage_Minimum', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_MIN_Stage_Minimum];
GO
CREATE TRIGGER [dbo].[it_ST_MIN_Stage_Minimum] ON [dbo].[ST_MIN_Stage_Minimum]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_MIN_Stage_Minimum TABLE (
        ST_MIN_ST_ID int not null,
        Metadata_ST_MIN int not null,
        ST_MIN_PositedAt datetime2 not null,
        ST_MIN_Reliability decimal(5,2) not null,
        ST_MIN_UTL_ID tinyint not null,
        ST_MIN_StatementType char(1) not null,
        primary key (
            ST_MIN_ST_ID asc,
            ST_MIN_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_MIN_ST_ID,
            i.ST_MIN_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[ST_MIN_Stage_Minimum_Posit] p
            JOIN
                [dbo].[ST_MIN_Stage_Minimum_Annex] a
            ON
                a.ST_MIN_ID = p.ST_MIN_ID
            WHERE
                p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
            AND
                p.ST_MIN_UTL_ID = i.ST_MIN_UTL_ID
            AND
                a.ST_MIN_PositedAt = i.ST_MIN_PositedAt
            AND
                a.ST_MIN_Reliability <> i.ST_MIN_Reliability
        )
        OR (
            i.ST_MIN_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[ST_MIN_Stage_Minimum_Posit] p
                JOIN
                    [dbo].[ST_MIN_Stage_Minimum_Annex] a
                ON
                    a.ST_MIN_ID = p.ST_MIN_ID
                WHERE
                    p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
                AND
                    p.ST_MIN_UTL_ID <> i.ST_MIN_UTL_ID
                AND
                    a.ST_MIN_PositedAt = i.ST_MIN_PositedAt
                AND
                    a.ST_MIN_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.ST_MIN_ST_ID = i.ST_MIN_ST_ID
                AND
                    j.ST_MIN_UTL_ID <> i.ST_MIN_UTL_ID
                AND
                    j.ST_MIN_PositedAt = i.ST_MIN_PositedAt
                AND
                    j.ST_MIN_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_MIN_Stage_Minimum for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @ST_MIN_Stage_Minimum
    SELECT
        i.ST_MIN_ST_ID,
        i.Metadata_ST_MIN,
        i.ST_MIN_PositedAt,
        i.ST_MIN_Reliability,
        i.ST_MIN_UTL_ID,
        CASE
            WHEN p.ST_MIN_ID is null
            THEN 'P' -- new posit
            WHEN a.ST_MIN_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    ON
        p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
    AND
        p.ST_MIN_UTL_ID = i.ST_MIN_UTL_ID
    LEFT JOIN
        [dbo].[ST_MIN_Stage_Minimum_Annex] a
    ON
        a.ST_MIN_ID = p.ST_MIN_ID
    AND
        a.ST_MIN_PositedAt = i.ST_MIN_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_MIN_ID is null OR a.ST_MIN_ID is null);
    INSERT INTO @ST_MIN_Stage_Minimum (
        ST_MIN_ST_ID,
        Metadata_ST_MIN,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        ST_MIN_UTL_ID,
        ST_MIN_StatementType
    )
    SELECT
        x.ST_MIN_ST_ID,
        x.Metadata_ST_MIN,
        x.ST_MIN_PositedAt,
        x.ST_MIN_Reliability,
        x.ST_MIN_UTL_ID,
        'X' -- existing data
    FROM (
        SELECT
            i.ST_MIN_ST_ID,
            a.Metadata_ST_MIN,
            a.ST_MIN_PositedAt,
            a.ST_MIN_Reliability,
            p.ST_MIN_UTL_ID,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.ST_MIN_ST_ID,
                    a.ST_MIN_PositedAt
                ORDER BY
                    a.ST_MIN_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT ST_MIN_ST_ID FROM @ST_MIN_Stage_Minimum) i
        JOIN
            [dbo].[ST_MIN_Stage_Minimum_Posit] p
        ON
            p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
        JOIN
            [dbo].[ST_MIN_Stage_Minimum_Annex] a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @ST_MIN_Stage_Minimum n
        WHERE
            n.ST_MIN_ST_ID = x.ST_MIN_ST_ID
        AND
            n.ST_MIN_PositedAt = x.ST_MIN_PositedAt
    );
    DECLARE @retracted TABLE (
        ST_MIN_ST_ID int not null,
        Metadata_ST_MIN int not null,
        ST_MIN_PositedAt datetime2 not null,
        ST_MIN_Reliability decimal(5,2) not null,
        ST_MIN_UTL_ID tinyint not null,
        ST_MIN_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_MIN_ST_ID,
        Metadata_ST_MIN,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        ST_MIN_UTL_ID,
        ST_MIN_StatementType
    )
    SELECT
        ST_MIN_ST_ID,
        Metadata_ST_MIN,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        ST_MIN_UTL_ID,
        ST_MIN_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.ST_MIN_Reliability as previous_ST_MIN_Reliability,
            fol.ST_MIN_Reliability as following_ST_MIN_Reliability
        FROM
            @ST_MIN_Stage_Minimum a
        OUTER APPLY (
            SELECT TOP 1
                p.ST_MIN_Reliability
            FROM
                @ST_MIN_Stage_Minimum p
            WHERE
                p.ST_MIN_ST_ID = a.ST_MIN_ST_ID
            AND
                p.ST_MIN_PositedAt < a.ST_MIN_PositedAt
            ORDER BY
                p.ST_MIN_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.ST_MIN_Reliability
            FROM
                @ST_MIN_Stage_Minimum p
            WHERE
                p.ST_MIN_ST_ID = a.ST_MIN_ST_ID
            AND
                p.ST_MIN_PositedAt > a.ST_MIN_PositedAt
            ORDER BY
                p.ST_MIN_PositedAt ASC
        ) fol
        WHERE
            (a.ST_MIN_Reliability = 0 AND isnull(pre.ST_MIN_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.ST_MIN_Reliability = 1 AND fol.ST_MIN_Reliability = 0)
    ) i
    WHERE
        i.ST_MIN_StatementType <> 'X'
    AND (
            (i.ST_MIN_Reliability = 0 AND i.previous_ST_MIN_Reliability = 1)
        OR
            (i.ST_MIN_Reliability = 1 AND i.following_ST_MIN_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @ST_MIN_Stage_Minimum SELECT * FROM @retracted;
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Posit] (
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
    SELECT
        v.ST_MIN_ST_ID,
        v.ST_MIN_UTL_ID
    FROM
        @ST_MIN_Stage_Minimum v
    WHERE
        v.ST_MIN_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @ST_MIN_Stage_Minimum w
        WHERE
            w.ST_MIN_StatementType = 'P'
        AND
            w.ST_MIN_ST_ID = v.ST_MIN_ST_ID
        AND
            w.ST_MIN_UTL_ID = v.ST_MIN_UTL_ID
        AND
            w.ST_MIN_PositedAt < v.ST_MIN_PositedAt
    );
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Annex] (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        v.Metadata_ST_MIN,
        p.ST_MIN_ID,
        v.ST_MIN_PositedAt,
        v.ST_MIN_Reliability
    FROM
        @ST_MIN_Stage_Minimum v
    JOIN
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    ON
        p.ST_MIN_ST_ID = v.ST_MIN_ST_ID
    AND
        p.ST_MIN_UTL_ID = v.ST_MIN_UTL_ID
    WHERE
        ST_MIN_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Annex] (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        v.Metadata_ST_MIN,
        e.ST_MIN_ID,
        v.ST_MIN_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_ST_MIN,
            n.ST_MIN_ST_ID,
            n.ST_MIN_PositedAt,
            n.ST_MIN_UTL_ID
        FROM
            @ST_MIN_Stage_Minimum n
        WHERE
            n.ST_MIN_StatementType in ('P', 'A')
        AND
            n.ST_MIN_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.ST_MIN_ID,
            p.ST_MIN_UTL_ID
        FROM
            [dbo].[ST_MIN_Stage_Minimum_Posit] p
        JOIN
            [dbo].[ST_MIN_Stage_Minimum_Annex] a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
        AND
            a.ST_MIN_PositedAt = (
                SELECT
                    max(s.ST_MIN_PositedAt)
                FROM
                    [dbo].[ST_MIN_Stage_Minimum_Annex] s
                WHERE
                    s.ST_MIN_ID = p.ST_MIN_ID
                AND
                    s.ST_MIN_PositedAt < v.ST_MIN_PositedAt
            )
        WHERE
            p.ST_MIN_ST_ID = v.ST_MIN_ST_ID
        AND
            a.ST_MIN_Reliability = 1
        ORDER BY
            a.ST_MIN_PositedAt DESC
    ) e
    WHERE
        e.ST_MIN_UTL_ID <> v.ST_MIN_UTL_ID
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_MIN_Stage_Minimum_Annex] x
        WHERE
            x.ST_MIN_ID = e.ST_MIN_ID
        AND
            x.ST_MIN_PositedAt = v.ST_MIN_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name instead of INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [dbo].[it_AC_NAM_Actor_Name] ON [dbo].[AC_NAM_Actor_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_NAM_AC_ID int not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_Checksum varbinary(16) not null,
        AC_NAM_StatementType char(1) not null,
        primary key (
            AC_NAM_AC_ID asc,
            AC_NAM_ChangedAt desc,
            AC_NAM_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_NAM_AC_ID,
            i.AC_NAM_ChangedAt,
            i.AC_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[AC_NAM_Actor_Name_Posit] p
            JOIN
                [dbo].[AC_NAM_Actor_Name_Annex] a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            WHERE
                p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
            AND
                p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
            AND
                p.AC_NAM_Checksum = dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max)))
            AND
                a.AC_NAM_PositedAt = i.AC_NAM_PositedAt
            AND
                a.AC_NAM_Reliability <> i.AC_NAM_Reliability
        )
        OR (
            i.AC_NAM_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[AC_NAM_Actor_Name_Posit] p
                JOIN
                    [dbo].[AC_NAM_Actor_Name_Annex] a
                ON
                    a.AC_NAM_ID = p.AC_NAM_ID
                WHERE
                    p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
                AND
                    p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
                AND
                    p.AC_NAM_Checksum <> dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max)))
                AND
                    a.AC_NAM_PositedAt = i.AC_NAM_PositedAt
                AND
                    a.AC_NAM_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.AC_NAM_AC_ID = i.AC_NAM_AC_ID
                AND
                    j.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
                AND
                    dbo.MD5(cast(j.AC_NAM_Actor_Name as varbinary(max))) <> dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max)))
                AND
                    j.AC_NAM_PositedAt = i.AC_NAM_PositedAt
                AND
                    j.AC_NAM_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_NAM_Actor_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @AC_NAM_Actor_Name
    SELECT
        i.AC_NAM_AC_ID,
        i.Metadata_AC_NAM,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Reliability,
        i.AC_NAM_Actor_Name,
        dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max))),
        CASE
            WHEN p.AC_NAM_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_NAM_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
    AND
        p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
    AND
        p.AC_NAM_Checksum = dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max)))
    LEFT JOIN
        [dbo].[AC_NAM_Actor_Name_Annex] a
    ON
        a.AC_NAM_ID = p.AC_NAM_ID
    AND
        a.AC_NAM_PositedAt = i.AC_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_NAM_ID is null OR a.AC_NAM_ID is null);
    INSERT INTO @AC_NAM_Actor_Name (
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name,
        AC_NAM_Checksum,
        AC_NAM_StatementType
    )
    SELECT
        x.AC_NAM_AC_ID,
        x.Metadata_AC_NAM,
        x.AC_NAM_ChangedAt,
        x.AC_NAM_PositedAt,
        x.AC_NAM_Reliability,
        x.AC_NAM_Actor_Name,
        x.AC_NAM_Checksum,
        'X' -- existing data
    FROM (
        SELECT
            i.AC_NAM_AC_ID,
            a.Metadata_AC_NAM,
            p.AC_NAM_ChangedAt,
            a.AC_NAM_PositedAt,
            a.AC_NAM_Reliability,
            p.AC_NAM_Actor_Name,
            p.AC_NAM_Checksum,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.AC_NAM_AC_ID,
                    p.AC_NAM_ChangedAt,
                    a.AC_NAM_PositedAt
                ORDER BY
                    a.AC_NAM_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT AC_NAM_AC_ID FROM @AC_NAM_Actor_Name) i
        JOIN
            [dbo].[AC_NAM_Actor_Name_Posit] p
        ON
            p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
        JOIN
            [dbo].[AC_NAM_Actor_Name_Annex] a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @AC_NAM_Actor_Name n
        WHERE
            n.AC_NAM_AC_ID = x.AC_NAM_AC_ID
        AND
            n.AC_NAM_ChangedAt = x.AC_NAM_ChangedAt
        AND
            n.AC_NAM_PositedAt = x.AC_NAM_PositedAt
    );
    DECLARE @retracted TABLE (
        AC_NAM_AC_ID int not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_Checksum varbinary(16) not null,
        AC_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name,
        AC_NAM_Checksum,
        AC_NAM_StatementType
    )
    SELECT
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name,
        AC_NAM_Checksum,
        AC_NAM_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_NAM_Reliability as previous_AC_NAM_Reliability,
            fol.AC_NAM_Reliability as following_AC_NAM_Reliability
        FROM
            @AC_NAM_Actor_Name a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_NAM_Reliability
            FROM
                @AC_NAM_Actor_Name p
            WHERE
                p.AC_NAM_AC_ID = a.AC_NAM_AC_ID
            AND
                p.AC_NAM_ChangedAt = a.AC_NAM_ChangedAt
            AND
                p.AC_NAM_PositedAt < a.AC_NAM_PositedAt
            ORDER BY
                p.AC_NAM_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_NAM_Reliability
            FROM
                @AC_NAM_Actor_Name p
            WHERE
                p.AC_NAM_AC_ID = a.AC_NAM_AC_ID
            AND
                p.AC_NAM_ChangedAt = a.AC_NAM_ChangedAt
            AND
                p.AC_NAM_PositedAt > a.AC_NAM_PositedAt
            ORDER BY
                p.AC_NAM_PositedAt ASC
        ) fol
        WHERE
            (a.AC_NAM_Reliability = 0 AND isnull(pre.AC_NAM_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_NAM_Reliability = 1 AND fol.AC_NAM_Reliability = 0)
    ) i
    WHERE
        i.AC_NAM_StatementType <> 'X'
    AND (
            (i.AC_NAM_Reliability = 0 AND i.previous_AC_NAM_Reliability = 1)
        OR
            (i.AC_NAM_Reliability = 1 AND i.following_AC_NAM_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @AC_NAM_Actor_Name SELECT * FROM @retracted;
    INSERT INTO [dbo].[AC_NAM_Actor_Name_Posit] (
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT
        v.AC_NAM_AC_ID,
        v.AC_NAM_ChangedAt,
        v.AC_NAM_Actor_Name
    FROM
        @AC_NAM_Actor_Name v
    WHERE
        v.AC_NAM_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @AC_NAM_Actor_Name w
        WHERE
            w.AC_NAM_StatementType = 'P'
        AND
            w.AC_NAM_AC_ID = v.AC_NAM_AC_ID
        AND
            w.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
        AND
            w.AC_NAM_Checksum = v.AC_NAM_Checksum
        AND
            w.AC_NAM_PositedAt < v.AC_NAM_PositedAt
    );
    INSERT INTO [dbo].[AC_NAM_Actor_Name_Annex] (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        v.Metadata_AC_NAM,
        p.AC_NAM_ID,
        v.AC_NAM_PositedAt,
        v.AC_NAM_Reliability
    FROM
        @AC_NAM_Actor_Name v
    JOIN
        [dbo].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_NAM_AC_ID = v.AC_NAM_AC_ID
    AND
        p.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
    AND
        p.AC_NAM_Checksum = v.AC_NAM_Checksum
    WHERE
        AC_NAM_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[AC_NAM_Actor_Name_Annex] (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        v.Metadata_AC_NAM,
        e.AC_NAM_ID,
        v.AC_NAM_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_AC_NAM,
            n.AC_NAM_AC_ID,
            n.AC_NAM_ChangedAt,
            n.AC_NAM_PositedAt,
            n.AC_NAM_Checksum
        FROM
            @AC_NAM_Actor_Name n
        WHERE
            n.AC_NAM_StatementType in ('P', 'A')
        AND
            n.AC_NAM_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.AC_NAM_ID,
            p.AC_NAM_Checksum
        FROM
            [dbo].[AC_NAM_Actor_Name_Posit] p
        JOIN
            [dbo].[AC_NAM_Actor_Name_Annex] a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
        AND
            a.AC_NAM_PositedAt = (
                SELECT
                    max(s.AC_NAM_PositedAt)
                FROM
                    [dbo].[AC_NAM_Actor_Name_Annex] s
                WHERE
                    s.AC_NAM_ID = p.AC_NAM_ID
                AND
                    s.AC_NAM_PositedAt < v.AC_NAM_PositedAt
            )
        WHERE
            p.AC_NAM_AC_ID = v.AC_NAM_AC_ID
        AND
            p.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
        AND
            a.AC_NAM_Reliability = 1
        ORDER BY
            a.AC_NAM_PositedAt DESC
    ) e
    WHERE
        e.AC_NAM_Checksum <> v.AC_NAM_Checksum
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_NAM_Actor_Name_Annex] x
        WHERE
            x.AC_NAM_ID = e.AC_NAM_ID
        AND
            x.AC_NAM_PositedAt = v.AC_NAM_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Actor_Gender instead of INSERT trigger on AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_GEN_Actor_Gender', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_GEN_Actor_Gender];
GO
CREATE TRIGGER [dbo].[it_AC_GEN_Actor_Gender] ON [dbo].[AC_GEN_Actor_Gender]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AC_GEN_Actor_Gender TABLE (
        AC_GEN_AC_ID int not null,
        Metadata_AC_GEN int not null,
        AC_GEN_PositedAt datetime2 not null,
        AC_GEN_Reliability decimal(5,2) not null,
        AC_GEN_GEN_ID tinyint not null,
        AC_GEN_StatementType char(1) not null,
        primary key (
            AC_GEN_AC_ID asc,
            AC_GEN_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_GEN_AC_ID,
            i.AC_GEN_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[AC_GEN_Actor_Gender_Posit] p
            JOIN
                [dbo].[AC_GEN_Actor_Gender_Annex] a
            ON
                a.AC_GEN_ID = p.AC_GEN_ID
            WHERE
                p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
            AND
                p.AC_GEN_GEN_ID = i.AC_GEN_GEN_ID
            AND
                a.AC_GEN_PositedAt = i.AC_GEN_PositedAt
            AND
                a.AC_GEN_Reliability <> i.AC_GEN_Reliability
        )
        OR (
            i.AC_GEN_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[AC_GEN_Actor_Gender_Posit] p
                JOIN
                    [dbo].[AC_GEN_Actor_Gender_Annex] a
                ON
                    a.AC_GEN_ID = p.AC_GEN_ID
                WHERE
                    p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
                AND
                    p.AC_GEN_GEN_ID <> i.AC_GEN_GEN_ID
                AND
                    a.AC_GEN_PositedAt = i.AC_GEN_PositedAt
                AND
                    a.AC_GEN_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.AC_GEN_AC_ID = i.AC_GEN_AC_ID
                AND
                    j.AC_GEN_GEN_ID <> i.AC_GEN_GEN_ID
                AND
                    j.AC_GEN_PositedAt = i.AC_GEN_PositedAt
                AND
                    j.AC_GEN_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_GEN_Actor_Gender for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @AC_GEN_Actor_Gender
    SELECT
        i.AC_GEN_AC_ID,
        i.Metadata_AC_GEN,
        i.AC_GEN_PositedAt,
        i.AC_GEN_Reliability,
        i.AC_GEN_GEN_ID,
        CASE
            WHEN p.AC_GEN_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_GEN_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    ON
        p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
    AND
        p.AC_GEN_GEN_ID = i.AC_GEN_GEN_ID
    LEFT JOIN
        [dbo].[AC_GEN_Actor_Gender_Annex] a
    ON
        a.AC_GEN_ID = p.AC_GEN_ID
    AND
        a.AC_GEN_PositedAt = i.AC_GEN_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_GEN_ID is null OR a.AC_GEN_ID is null);
    INSERT INTO @AC_GEN_Actor_Gender (
        AC_GEN_AC_ID,
        Metadata_AC_GEN,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        AC_GEN_GEN_ID,
        AC_GEN_StatementType
    )
    SELECT
        x.AC_GEN_AC_ID,
        x.Metadata_AC_GEN,
        x.AC_GEN_PositedAt,
        x.AC_GEN_Reliability,
        x.AC_GEN_GEN_ID,
        'X' -- existing data
    FROM (
        SELECT
            i.AC_GEN_AC_ID,
            a.Metadata_AC_GEN,
            a.AC_GEN_PositedAt,
            a.AC_GEN_Reliability,
            p.AC_GEN_GEN_ID,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.AC_GEN_AC_ID,
                    a.AC_GEN_PositedAt
                ORDER BY
                    a.AC_GEN_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT AC_GEN_AC_ID FROM @AC_GEN_Actor_Gender) i
        JOIN
            [dbo].[AC_GEN_Actor_Gender_Posit] p
        ON
            p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
        JOIN
            [dbo].[AC_GEN_Actor_Gender_Annex] a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @AC_GEN_Actor_Gender n
        WHERE
            n.AC_GEN_AC_ID = x.AC_GEN_AC_ID
        AND
            n.AC_GEN_PositedAt = x.AC_GEN_PositedAt
    );
    DECLARE @retracted TABLE (
        AC_GEN_AC_ID int not null,
        Metadata_AC_GEN int not null,
        AC_GEN_PositedAt datetime2 not null,
        AC_GEN_Reliability decimal(5,2) not null,
        AC_GEN_GEN_ID tinyint not null,
        AC_GEN_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        AC_GEN_AC_ID,
        Metadata_AC_GEN,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        AC_GEN_GEN_ID,
        AC_GEN_StatementType
    )
    SELECT
        AC_GEN_AC_ID,
        Metadata_AC_GEN,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        AC_GEN_GEN_ID,
        AC_GEN_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_GEN_Reliability as previous_AC_GEN_Reliability,
            fol.AC_GEN_Reliability as following_AC_GEN_Reliability
        FROM
            @AC_GEN_Actor_Gender a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_GEN_Reliability
            FROM
                @AC_GEN_Actor_Gender p
            WHERE
                p.AC_GEN_AC_ID = a.AC_GEN_AC_ID
            AND
                p.AC_GEN_PositedAt < a.AC_GEN_PositedAt
            ORDER BY
                p.AC_GEN_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_GEN_Reliability
            FROM
                @AC_GEN_Actor_Gender p
            WHERE
                p.AC_GEN_AC_ID = a.AC_GEN_AC_ID
            AND
                p.AC_GEN_PositedAt > a.AC_GEN_PositedAt
            ORDER BY
                p.AC_GEN_PositedAt ASC
        ) fol
        WHERE
            (a.AC_GEN_Reliability = 0 AND isnull(pre.AC_GEN_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_GEN_Reliability = 1 AND fol.AC_GEN_Reliability = 0)
    ) i
    WHERE
        i.AC_GEN_StatementType <> 'X'
    AND (
            (i.AC_GEN_Reliability = 0 AND i.previous_AC_GEN_Reliability = 1)
        OR
            (i.AC_GEN_Reliability = 1 AND i.following_AC_GEN_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @AC_GEN_Actor_Gender SELECT * FROM @retracted;
    INSERT INTO [dbo].[AC_GEN_Actor_Gender_Posit] (
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
    SELECT
        v.AC_GEN_AC_ID,
        v.AC_GEN_GEN_ID
    FROM
        @AC_GEN_Actor_Gender v
    WHERE
        v.AC_GEN_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @AC_GEN_Actor_Gender w
        WHERE
            w.AC_GEN_StatementType = 'P'
        AND
            w.AC_GEN_AC_ID = v.AC_GEN_AC_ID
        AND
            w.AC_GEN_GEN_ID = v.AC_GEN_GEN_ID
        AND
            w.AC_GEN_PositedAt < v.AC_GEN_PositedAt
    );
    INSERT INTO [dbo].[AC_GEN_Actor_Gender_Annex] (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        v.Metadata_AC_GEN,
        p.AC_GEN_ID,
        v.AC_GEN_PositedAt,
        v.AC_GEN_Reliability
    FROM
        @AC_GEN_Actor_Gender v
    JOIN
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    ON
        p.AC_GEN_AC_ID = v.AC_GEN_AC_ID
    AND
        p.AC_GEN_GEN_ID = v.AC_GEN_GEN_ID
    WHERE
        AC_GEN_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[AC_GEN_Actor_Gender_Annex] (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        v.Metadata_AC_GEN,
        e.AC_GEN_ID,
        v.AC_GEN_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_AC_GEN,
            n.AC_GEN_AC_ID,
            n.AC_GEN_PositedAt,
            n.AC_GEN_GEN_ID
        FROM
            @AC_GEN_Actor_Gender n
        WHERE
            n.AC_GEN_StatementType in ('P', 'A')
        AND
            n.AC_GEN_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.AC_GEN_ID,
            p.AC_GEN_GEN_ID
        FROM
            [dbo].[AC_GEN_Actor_Gender_Posit] p
        JOIN
            [dbo].[AC_GEN_Actor_Gender_Annex] a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
        AND
            a.AC_GEN_PositedAt = (
                SELECT
                    max(s.AC_GEN_PositedAt)
                FROM
                    [dbo].[AC_GEN_Actor_Gender_Annex] s
                WHERE
                    s.AC_GEN_ID = p.AC_GEN_ID
                AND
                    s.AC_GEN_PositedAt < v.AC_GEN_PositedAt
            )
        WHERE
            p.AC_GEN_AC_ID = v.AC_GEN_AC_ID
        AND
            a.AC_GEN_Reliability = 1
        ORDER BY
            a.AC_GEN_PositedAt DESC
    ) e
    WHERE
        e.AC_GEN_GEN_ID <> v.AC_GEN_GEN_ID
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_GEN_Actor_Gender_Annex] x
        WHERE
            x.AC_GEN_ID = e.AC_GEN_ID
        AND
            x.AC_GEN_PositedAt = v.AC_GEN_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel instead of INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_PLV_Actor_ProfessionalLevel', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_PLV_Actor_ProfessionalLevel];
GO
CREATE TRIGGER [dbo].[it_AC_PLV_Actor_ProfessionalLevel] ON [dbo].[AC_PLV_Actor_ProfessionalLevel]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AC_PLV_Actor_ProfessionalLevel TABLE (
        AC_PLV_AC_ID int not null,
        Metadata_AC_PLV int not null,
        AC_PLV_ChangedAt datetime2 not null,
        AC_PLV_PositedAt datetime2 not null,
        AC_PLV_Reliability decimal(5,2) not null,
        AC_PLV_PLV_ID tinyint not null,
        AC_PLV_StatementType char(1) not null,
        primary key (
            AC_PLV_AC_ID asc,
            AC_PLV_ChangedAt desc,
            AC_PLV_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_PLV_AC_ID,
            i.AC_PLV_ChangedAt,
            i.AC_PLV_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
            JOIN
                [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            WHERE
                p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
            AND
                p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
            AND
                p.AC_PLV_PLV_ID = i.AC_PLV_PLV_ID
            AND
                a.AC_PLV_PositedAt = i.AC_PLV_PositedAt
            AND
                a.AC_PLV_Reliability <> i.AC_PLV_Reliability
        )
        OR (
            i.AC_PLV_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
                JOIN
                    [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
                ON
                    a.AC_PLV_ID = p.AC_PLV_ID
                WHERE
                    p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
                AND
                    p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
                AND
                    p.AC_PLV_PLV_ID <> i.AC_PLV_PLV_ID
                AND
                    a.AC_PLV_PositedAt = i.AC_PLV_PositedAt
                AND
                    a.AC_PLV_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.AC_PLV_AC_ID = i.AC_PLV_AC_ID
                AND
                    j.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
                AND
                    j.AC_PLV_PLV_ID <> i.AC_PLV_PLV_ID
                AND
                    j.AC_PLV_PositedAt = i.AC_PLV_PositedAt
                AND
                    j.AC_PLV_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel
    SELECT
        i.AC_PLV_AC_ID,
        i.Metadata_AC_PLV,
        i.AC_PLV_ChangedAt,
        i.AC_PLV_PositedAt,
        i.AC_PLV_Reliability,
        i.AC_PLV_PLV_ID,
        CASE
            WHEN p.AC_PLV_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_PLV_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
    AND
        p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
    AND
        p.AC_PLV_PLV_ID = i.AC_PLV_PLV_ID
    LEFT JOIN
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
    ON
        a.AC_PLV_ID = p.AC_PLV_ID
    AND
        a.AC_PLV_PositedAt = i.AC_PLV_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_PLV_ID is null OR a.AC_PLV_ID is null);
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel (
        AC_PLV_AC_ID,
        Metadata_AC_PLV,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        AC_PLV_PLV_ID,
        AC_PLV_StatementType
    )
    SELECT
        x.AC_PLV_AC_ID,
        x.Metadata_AC_PLV,
        x.AC_PLV_ChangedAt,
        x.AC_PLV_PositedAt,
        x.AC_PLV_Reliability,
        x.AC_PLV_PLV_ID,
        'X' -- existing data
    FROM (
        SELECT
            i.AC_PLV_AC_ID,
            a.Metadata_AC_PLV,
            p.AC_PLV_ChangedAt,
            a.AC_PLV_PositedAt,
            a.AC_PLV_Reliability,
            p.AC_PLV_PLV_ID,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.AC_PLV_AC_ID,
                    p.AC_PLV_ChangedAt,
                    a.AC_PLV_PositedAt
                ORDER BY
                    a.AC_PLV_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT AC_PLV_AC_ID FROM @AC_PLV_Actor_ProfessionalLevel) i
        JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
        ON
            p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
        JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @AC_PLV_Actor_ProfessionalLevel n
        WHERE
            n.AC_PLV_AC_ID = x.AC_PLV_AC_ID
        AND
            n.AC_PLV_ChangedAt = x.AC_PLV_ChangedAt
        AND
            n.AC_PLV_PositedAt = x.AC_PLV_PositedAt
    );
    DECLARE @retracted TABLE (
        AC_PLV_AC_ID int not null,
        Metadata_AC_PLV int not null,
        AC_PLV_ChangedAt datetime2 not null,
        AC_PLV_PositedAt datetime2 not null,
        AC_PLV_Reliability decimal(5,2) not null,
        AC_PLV_PLV_ID tinyint not null,
        AC_PLV_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        AC_PLV_AC_ID,
        Metadata_AC_PLV,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        AC_PLV_PLV_ID,
        AC_PLV_StatementType
    )
    SELECT
        AC_PLV_AC_ID,
        Metadata_AC_PLV,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        AC_PLV_PLV_ID,
        AC_PLV_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_PLV_Reliability as previous_AC_PLV_Reliability,
            fol.AC_PLV_Reliability as following_AC_PLV_Reliability
        FROM
            @AC_PLV_Actor_ProfessionalLevel a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_PLV_Reliability
            FROM
                @AC_PLV_Actor_ProfessionalLevel p
            WHERE
                p.AC_PLV_AC_ID = a.AC_PLV_AC_ID
            AND
                p.AC_PLV_ChangedAt = a.AC_PLV_ChangedAt
            AND
                p.AC_PLV_PositedAt < a.AC_PLV_PositedAt
            ORDER BY
                p.AC_PLV_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_PLV_Reliability
            FROM
                @AC_PLV_Actor_ProfessionalLevel p
            WHERE
                p.AC_PLV_AC_ID = a.AC_PLV_AC_ID
            AND
                p.AC_PLV_ChangedAt = a.AC_PLV_ChangedAt
            AND
                p.AC_PLV_PositedAt > a.AC_PLV_PositedAt
            ORDER BY
                p.AC_PLV_PositedAt ASC
        ) fol
        WHERE
            (a.AC_PLV_Reliability = 0 AND isnull(pre.AC_PLV_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_PLV_Reliability = 1 AND fol.AC_PLV_Reliability = 0)
    ) i
    WHERE
        i.AC_PLV_StatementType <> 'X'
    AND (
            (i.AC_PLV_Reliability = 0 AND i.previous_AC_PLV_Reliability = 1)
        OR
            (i.AC_PLV_Reliability = 1 AND i.following_AC_PLV_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel SELECT * FROM @retracted;
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] (
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
    SELECT
        v.AC_PLV_AC_ID,
        v.AC_PLV_ChangedAt,
        v.AC_PLV_PLV_ID
    FROM
        @AC_PLV_Actor_ProfessionalLevel v
    WHERE
        v.AC_PLV_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @AC_PLV_Actor_ProfessionalLevel w
        WHERE
            w.AC_PLV_StatementType = 'P'
        AND
            w.AC_PLV_AC_ID = v.AC_PLV_AC_ID
        AND
            w.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
        AND
            w.AC_PLV_PLV_ID = v.AC_PLV_PLV_ID
        AND
            w.AC_PLV_PositedAt < v.AC_PLV_PositedAt
    );
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        v.Metadata_AC_PLV,
        p.AC_PLV_ID,
        v.AC_PLV_PositedAt,
        v.AC_PLV_Reliability
    FROM
        @AC_PLV_Actor_ProfessionalLevel v
    JOIN
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        p.AC_PLV_AC_ID = v.AC_PLV_AC_ID
    AND
        p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
    AND
        p.AC_PLV_PLV_ID = v.AC_PLV_PLV_ID
    WHERE
        AC_PLV_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        v.Metadata_AC_PLV,
        e.AC_PLV_ID,
        v.AC_PLV_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_AC_PLV,
            n.AC_PLV_AC_ID,
            n.AC_PLV_ChangedAt,
            n.AC_PLV_PositedAt,
            n.AC_PLV_PLV_ID
        FROM
            @AC_PLV_Actor_ProfessionalLevel n
        WHERE
            n.AC_PLV_StatementType in ('P', 'A')
        AND
            n.AC_PLV_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.AC_PLV_ID,
            p.AC_PLV_PLV_ID
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
        JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
        AND
            a.AC_PLV_PositedAt = (
                SELECT
                    max(s.AC_PLV_PositedAt)
                FROM
                    [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] s
                WHERE
                    s.AC_PLV_ID = p.AC_PLV_ID
                AND
                    s.AC_PLV_PositedAt < v.AC_PLV_PositedAt
            )
        WHERE
            p.AC_PLV_AC_ID = v.AC_PLV_AC_ID
        AND
            p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
        AND
            a.AC_PLV_Reliability = 1
        ORDER BY
            a.AC_PLV_PositedAt DESC
    ) e
    WHERE
        e.AC_PLV_PLV_ID <> v.AC_PLV_PLV_ID
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] x
        WHERE
            x.AC_PLV_ID = e.AC_PLV_ID
        AND
            x.AC_PLV_PositedAt = v.AC_PLV_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Program_Name instead of INSERT trigger on PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_PR_NAM_Program_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PR_NAM_Program_Name];
GO
CREATE TRIGGER [dbo].[it_PR_NAM_Program_Name] ON [dbo].[PR_NAM_Program_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PR_NAM_Program_Name TABLE (
        PR_NAM_PR_ID int not null,
        Metadata_PR_NAM int not null,
        PR_NAM_PositedAt datetime2 not null,
        PR_NAM_Reliability decimal(5,2) not null,
        PR_NAM_Program_Name nvarchar(42) not null,
        PR_NAM_StatementType char(1) not null,
        primary key (
            PR_NAM_PR_ID asc,
            PR_NAM_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_NAM_PR_ID,
            i.PR_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[PR_NAM_Program_Name_Posit] p
            JOIN
                [dbo].[PR_NAM_Program_Name_Annex] a
            ON
                a.PR_NAM_ID = p.PR_NAM_ID
            WHERE
                p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
            AND
                p.PR_NAM_Program_Name = i.PR_NAM_Program_Name
            AND
                a.PR_NAM_PositedAt = i.PR_NAM_PositedAt
            AND
                a.PR_NAM_Reliability <> i.PR_NAM_Reliability
        )
        OR (
            i.PR_NAM_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[PR_NAM_Program_Name_Posit] p
                JOIN
                    [dbo].[PR_NAM_Program_Name_Annex] a
                ON
                    a.PR_NAM_ID = p.PR_NAM_ID
                WHERE
                    p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
                AND
                    p.PR_NAM_Program_Name <> i.PR_NAM_Program_Name
                AND
                    a.PR_NAM_PositedAt = i.PR_NAM_PositedAt
                AND
                    a.PR_NAM_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.PR_NAM_PR_ID = i.PR_NAM_PR_ID
                AND
                    j.PR_NAM_Program_Name <> i.PR_NAM_Program_Name
                AND
                    j.PR_NAM_PositedAt = i.PR_NAM_PositedAt
                AND
                    j.PR_NAM_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in PR_NAM_Program_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @PR_NAM_Program_Name
    SELECT
        i.PR_NAM_PR_ID,
        i.Metadata_PR_NAM,
        i.PR_NAM_PositedAt,
        i.PR_NAM_Reliability,
        i.PR_NAM_Program_Name,
        CASE
            WHEN p.PR_NAM_ID is null
            THEN 'P' -- new posit
            WHEN a.PR_NAM_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[PR_NAM_Program_Name_Posit] p
    ON
        p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
    AND
        p.PR_NAM_Program_Name = i.PR_NAM_Program_Name
    LEFT JOIN
        [dbo].[PR_NAM_Program_Name_Annex] a
    ON
        a.PR_NAM_ID = p.PR_NAM_ID
    AND
        a.PR_NAM_PositedAt = i.PR_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.PR_NAM_ID is null OR a.PR_NAM_ID is null);
    INSERT INTO @PR_NAM_Program_Name (
        PR_NAM_PR_ID,
        Metadata_PR_NAM,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name,
        PR_NAM_StatementType
    )
    SELECT
        x.PR_NAM_PR_ID,
        x.Metadata_PR_NAM,
        x.PR_NAM_PositedAt,
        x.PR_NAM_Reliability,
        x.PR_NAM_Program_Name,
        'X' -- existing data
    FROM (
        SELECT
            i.PR_NAM_PR_ID,
            a.Metadata_PR_NAM,
            a.PR_NAM_PositedAt,
            a.PR_NAM_Reliability,
            p.PR_NAM_Program_Name,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.PR_NAM_PR_ID,
                    a.PR_NAM_PositedAt
                ORDER BY
                    a.PR_NAM_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT PR_NAM_PR_ID FROM @PR_NAM_Program_Name) i
        JOIN
            [dbo].[PR_NAM_Program_Name_Posit] p
        ON
            p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
        JOIN
            [dbo].[PR_NAM_Program_Name_Annex] a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @PR_NAM_Program_Name n
        WHERE
            n.PR_NAM_PR_ID = x.PR_NAM_PR_ID
        AND
            n.PR_NAM_PositedAt = x.PR_NAM_PositedAt
    );
    DECLARE @retracted TABLE (
        PR_NAM_PR_ID int not null,
        Metadata_PR_NAM int not null,
        PR_NAM_PositedAt datetime2 not null,
        PR_NAM_Reliability decimal(5,2) not null,
        PR_NAM_Program_Name nvarchar(42) not null,
        PR_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        PR_NAM_PR_ID,
        Metadata_PR_NAM,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name,
        PR_NAM_StatementType
    )
    SELECT
        PR_NAM_PR_ID,
        Metadata_PR_NAM,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name,
        PR_NAM_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.PR_NAM_Reliability as previous_PR_NAM_Reliability,
            fol.PR_NAM_Reliability as following_PR_NAM_Reliability
        FROM
            @PR_NAM_Program_Name a
        OUTER APPLY (
            SELECT TOP 1
                p.PR_NAM_Reliability
            FROM
                @PR_NAM_Program_Name p
            WHERE
                p.PR_NAM_PR_ID = a.PR_NAM_PR_ID
            AND
                p.PR_NAM_PositedAt < a.PR_NAM_PositedAt
            ORDER BY
                p.PR_NAM_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.PR_NAM_Reliability
            FROM
                @PR_NAM_Program_Name p
            WHERE
                p.PR_NAM_PR_ID = a.PR_NAM_PR_ID
            AND
                p.PR_NAM_PositedAt > a.PR_NAM_PositedAt
            ORDER BY
                p.PR_NAM_PositedAt ASC
        ) fol
        WHERE
            (a.PR_NAM_Reliability = 0 AND isnull(pre.PR_NAM_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.PR_NAM_Reliability = 1 AND fol.PR_NAM_Reliability = 0)
    ) i
    WHERE
        i.PR_NAM_StatementType <> 'X'
    AND (
            (i.PR_NAM_Reliability = 0 AND i.previous_PR_NAM_Reliability = 1)
        OR
            (i.PR_NAM_Reliability = 1 AND i.following_PR_NAM_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @PR_NAM_Program_Name SELECT * FROM @retracted;
    INSERT INTO [dbo].[PR_NAM_Program_Name_Posit] (
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    )
    SELECT
        v.PR_NAM_PR_ID,
        v.PR_NAM_Program_Name
    FROM
        @PR_NAM_Program_Name v
    WHERE
        v.PR_NAM_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @PR_NAM_Program_Name w
        WHERE
            w.PR_NAM_StatementType = 'P'
        AND
            w.PR_NAM_PR_ID = v.PR_NAM_PR_ID
        AND
            w.PR_NAM_Program_Name = v.PR_NAM_Program_Name
        AND
            w.PR_NAM_PositedAt < v.PR_NAM_PositedAt
    );
    INSERT INTO [dbo].[PR_NAM_Program_Name_Annex] (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        v.Metadata_PR_NAM,
        p.PR_NAM_ID,
        v.PR_NAM_PositedAt,
        v.PR_NAM_Reliability
    FROM
        @PR_NAM_Program_Name v
    JOIN
        [dbo].[PR_NAM_Program_Name_Posit] p
    ON
        p.PR_NAM_PR_ID = v.PR_NAM_PR_ID
    AND
        p.PR_NAM_Program_Name = v.PR_NAM_Program_Name
    WHERE
        PR_NAM_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[PR_NAM_Program_Name_Annex] (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        v.Metadata_PR_NAM,
        e.PR_NAM_ID,
        v.PR_NAM_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_PR_NAM,
            n.PR_NAM_PR_ID,
            n.PR_NAM_PositedAt,
            n.PR_NAM_Program_Name
        FROM
            @PR_NAM_Program_Name n
        WHERE
            n.PR_NAM_StatementType in ('P', 'A')
        AND
            n.PR_NAM_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.PR_NAM_ID,
            p.PR_NAM_Program_Name
        FROM
            [dbo].[PR_NAM_Program_Name_Posit] p
        JOIN
            [dbo].[PR_NAM_Program_Name_Annex] a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
        AND
            a.PR_NAM_PositedAt = (
                SELECT
                    max(s.PR_NAM_PositedAt)
                FROM
                    [dbo].[PR_NAM_Program_Name_Annex] s
                WHERE
                    s.PR_NAM_ID = p.PR_NAM_ID
                AND
                    s.PR_NAM_PositedAt < v.PR_NAM_PositedAt
            )
        WHERE
            p.PR_NAM_PR_ID = v.PR_NAM_PR_ID
        AND
            a.PR_NAM_Reliability = 1
        ORDER BY
            a.PR_NAM_PositedAt DESC
    ) e
    WHERE
        e.PR_NAM_Program_Name <> v.PR_NAM_Program_Name
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[PR_NAM_Program_Name_Annex] x
        WHERE
            x.PR_NAM_ID = e.PR_NAM_ID
        AND
            x.PR_NAM_PositedAt = v.PR_NAM_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Program_Length instead of INSERT trigger on PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_PR_LEN_Program_Length', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PR_LEN_Program_Length];
GO
CREATE TRIGGER [dbo].[it_PR_LEN_Program_Length] ON [dbo].[PR_LEN_Program_Length]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PR_LEN_Program_Length TABLE (
        PR_LEN_PR_ID int not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null,
        primary key (
            PR_LEN_PR_ID asc,
            PR_LEN_ChangedAt desc,
            PR_LEN_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_LEN_PR_ID,
            i.PR_LEN_ChangedAt,
            i.PR_LEN_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[PR_LEN_Program_Length_Posit] p
            JOIN
                [dbo].[PR_LEN_Program_Length_Annex] a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            WHERE
                p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
            AND
                p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
            AND
                p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
            AND
                a.PR_LEN_PositedAt = i.PR_LEN_PositedAt
            AND
                a.PR_LEN_Reliability <> i.PR_LEN_Reliability
        )
        OR (
            i.PR_LEN_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[PR_LEN_Program_Length_Posit] p
                JOIN
                    [dbo].[PR_LEN_Program_Length_Annex] a
                ON
                    a.PR_LEN_ID = p.PR_LEN_ID
                WHERE
                    p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
                AND
                    p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
                AND
                    p.PR_LEN_Program_Length <> i.PR_LEN_Program_Length
                AND
                    a.PR_LEN_PositedAt = i.PR_LEN_PositedAt
                AND
                    a.PR_LEN_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.PR_LEN_PR_ID = i.PR_LEN_PR_ID
                AND
                    j.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
                AND
                    j.PR_LEN_Program_Length <> i.PR_LEN_Program_Length
                AND
                    j.PR_LEN_PositedAt = i.PR_LEN_PositedAt
                AND
                    j.PR_LEN_Reliability = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in PR_LEN_Program_Length for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @PR_LEN_Program_Length
    SELECT
        i.PR_LEN_PR_ID,
        i.Metadata_PR_LEN,
        i.PR_LEN_ChangedAt,
        i.PR_LEN_PositedAt,
        i.PR_LEN_Reliability,
        i.PR_LEN_Program_Length,
        CASE
            WHEN p.PR_LEN_ID is null
            THEN 'P' -- new posit
            WHEN a.PR_LEN_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
    AND
        p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
    AND
        p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
    LEFT JOIN
        [dbo].[PR_LEN_Program_Length_Annex] a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = i.PR_LEN_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.PR_LEN_ID is null OR a.PR_LEN_ID is null);
    INSERT INTO @PR_LEN_Program_Length (
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType
    )
    SELECT
        x.PR_LEN_PR_ID,
        x.Metadata_PR_LEN,
        x.PR_LEN_ChangedAt,
        x.PR_LEN_PositedAt,
        x.PR_LEN_Reliability,
        x.PR_LEN_Program_Length,
        'X' -- existing data
    FROM (
        SELECT
            i.PR_LEN_PR_ID,
            a.Metadata_PR_LEN,
            p.PR_LEN_ChangedAt,
            a.PR_LEN_PositedAt,
            a.PR_LEN_Reliability,
            p.PR_LEN_Program_Length,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.PR_LEN_PR_ID,
                    p.PR_LEN_ChangedAt,
                    a.PR_LEN_PositedAt
                ORDER BY
                    a.PR_LEN_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT PR_LEN_PR_ID FROM @PR_LEN_Program_Length) i
        JOIN
            [dbo].[PR_LEN_Program_Length_Posit] p
        ON
            p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
        JOIN
            [dbo].[PR_LEN_Program_Length_Annex] a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @PR_LEN_Program_Length n
        WHERE
            n.PR_LEN_PR_ID = x.PR_LEN_PR_ID
        AND
            n.PR_LEN_ChangedAt = x.PR_LEN_ChangedAt
        AND
            n.PR_LEN_PositedAt = x.PR_LEN_PositedAt
    );
    DECLARE @retracted TABLE (
        PR_LEN_PR_ID int not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType
    )
    SELECT
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.PR_LEN_Reliability as previous_PR_LEN_Reliability,
            fol.PR_LEN_Reliability as following_PR_LEN_Reliability
        FROM
            @PR_LEN_Program_Length a
        OUTER APPLY (
            SELECT TOP 1
                p.PR_LEN_Reliability
            FROM
                @PR_LEN_Program_Length p
            WHERE
                p.PR_LEN_PR_ID = a.PR_LEN_PR_ID
            AND
                p.PR_LEN_ChangedAt = a.PR_LEN_ChangedAt
            AND
                p.PR_LEN_PositedAt < a.PR_LEN_PositedAt
            ORDER BY
                p.PR_LEN_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.PR_LEN_Reliability
            FROM
                @PR_LEN_Program_Length p
            WHERE
                p.PR_LEN_PR_ID = a.PR_LEN_PR_ID
            AND
                p.PR_LEN_ChangedAt = a.PR_LEN_ChangedAt
            AND
                p.PR_LEN_PositedAt > a.PR_LEN_PositedAt
            ORDER BY
                p.PR_LEN_PositedAt ASC
        ) fol
        WHERE
            (a.PR_LEN_Reliability = 0 AND isnull(pre.PR_LEN_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.PR_LEN_Reliability = 1 AND fol.PR_LEN_Reliability = 0)
    ) i
    WHERE
        i.PR_LEN_StatementType <> 'X'
    AND (
            (i.PR_LEN_Reliability = 0 AND i.previous_PR_LEN_Reliability = 1)
        OR
            (i.PR_LEN_Reliability = 1 AND i.following_PR_LEN_Reliability = 0)
        );
    -- the new values that only restate the previous version, which are skipped, though what they correct is retracted
    DECLARE @skipped TABLE (
        PR_LEN_PR_ID int not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Program_Length time not null
    );
    IF EXISTS (
        SELECT TOP 1
            PR_LEN_StatementType
        FROM
            @PR_LEN_Program_Length
        WHERE
            PR_LEN_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @restated TABLE (
        PR_LEN_PR_ID int not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null
    );
    INSERT INTO @skipped (
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Program_Length
    )
    SELECT
        a.PR_LEN_PR_ID,
        a.Metadata_PR_LEN,
        a.PR_LEN_ChangedAt,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Program_Length
    FROM
        @PR_LEN_Program_Length a
    CROSS APPLY (
        SELECT TOP 1
            h.PR_LEN_Program_Length
        FROM
            @PR_LEN_Program_Length h
        WHERE
            h.PR_LEN_PR_ID = a.PR_LEN_PR_ID
        AND
            h.PR_LEN_ChangedAt < a.PR_LEN_ChangedAt
        ORDER BY
            h.PR_LEN_ChangedAt DESC,
            h.PR_LEN_PositedAt DESC
    ) pre
    WHERE
        a.PR_LEN_StatementType in ('P', 'A')
    AND
        a.PR_LEN_Reliability = 1
    AND
        a.PR_LEN_Program_Length = pre.PR_LEN_Program_Length;
    INSERT INTO @restated (
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType
    )
    SELECT
        x.PR_LEN_PR_ID,
        x.Metadata_PR_LEN,
        x.PR_LEN_ChangedAt,
        CASE
            WHEN x.previous_PR_LEN_PositedAt < x.PR_LEN_PositedAt THEN x.PR_LEN_PositedAt
            ELSE x.previous_PR_LEN_PositedAt
        END,
        0, -- quench the existing restatements
        x.PR_LEN_Program_Length,
        CASE
            WHEN x.previous_PR_LEN_PositedAt < x.PR_LEN_PositedAt THEN 'D' -- physical delete
            ELSE 'A' -- logical delete
        END
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.PR_LEN_PositedAt as previous_PR_LEN_PositedAt
        FROM
            @PR_LEN_Program_Length a
        OUTER APPLY (
            SELECT TOP 1
                *
            FROM
                @PR_LEN_Program_Length h
            WHERE
                h.PR_LEN_PR_ID = a.PR_LEN_PR_ID
            AND
                h.PR_LEN_ChangedAt < a.PR_LEN_ChangedAt
            ORDER BY
                h.PR_LEN_ChangedAt DESC,
                h.PR_LEN_PositedAt DESC
        ) pre
        WHERE
            a.PR_LEN_Program_Length = pre.PR_LEN_Program_Length
    ) x
    WHERE
        x.PR_LEN_StatementType = 'X'; -- quench
    -- add the quenches
    INSERT INTO @PR_LEN_Program_Length
    SELECT
        *
    FROM (
        DELETE @restated
        OUTPUT deleted.*
        WHERE PR_LEN_StatementType = 'A'
    ) d;
    -- perform any remaining physical deletes
    DELETE a
    FROM
        @restated i
    JOIN
        [dbo].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
    AND
        p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
    AND
        p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
    JOIN
        [dbo].[PR_LEN_Program_Length_Annex] a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = i.PR_LEN_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @PR_LEN_Program_Length SELECT * FROM @retracted;
    INSERT INTO [dbo].[PR_LEN_Program_Length_Posit] (
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    SELECT
        v.PR_LEN_PR_ID,
        v.PR_LEN_ChangedAt,
        v.PR_LEN_Program_Length
    FROM
        @PR_LEN_Program_Length v
    WHERE
        v.PR_LEN_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @PR_LEN_Program_Length w
        WHERE
            w.PR_LEN_StatementType = 'P'
        AND
            w.PR_LEN_PR_ID = v.PR_LEN_PR_ID
        AND
            w.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
        AND
            w.PR_LEN_Program_Length = v.PR_LEN_Program_Length
        AND
            w.PR_LEN_PositedAt < v.PR_LEN_PositedAt
    );
    INSERT INTO [dbo].[PR_LEN_Program_Length_Annex] (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        v.Metadata_PR_LEN,
        p.PR_LEN_ID,
        v.PR_LEN_PositedAt,
        v.PR_LEN_Reliability
    FROM
        @PR_LEN_Program_Length v
    JOIN
        [dbo].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_LEN_PR_ID = v.PR_LEN_PR_ID
    AND
        p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
    AND
        p.PR_LEN_Program_Length = v.PR_LEN_Program_Length
    WHERE
        PR_LEN_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[PR_LEN_Program_Length_Annex] (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        v.Metadata_PR_LEN,
        e.PR_LEN_ID,
        v.PR_LEN_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_PR_LEN,
            n.PR_LEN_PR_ID,
            n.PR_LEN_ChangedAt,
            n.PR_LEN_PositedAt,
            n.PR_LEN_Program_Length
        FROM
            @PR_LEN_Program_Length n
        WHERE
            n.PR_LEN_StatementType in ('P', 'A')
        AND
            n.PR_LEN_Reliability = 1
        UNION ALL
        SELECT
            k.Metadata_PR_LEN,
            k.PR_LEN_PR_ID,
            k.PR_LEN_ChangedAt,
            k.PR_LEN_PositedAt,
            k.PR_LEN_Program_Length
        FROM
            @skipped k
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.PR_LEN_ID,
            p.PR_LEN_Program_Length
        FROM
            [dbo].[PR_LEN_Program_Length_Posit] p
        JOIN
            [dbo].[PR_LEN_Program_Length_Annex] a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
        AND
            a.PR_LEN_PositedAt = (
                SELECT
                    max(s.PR_LEN_PositedAt)
                FROM
                    [dbo].[PR_LEN_Program_Length_Annex] s
                WHERE
                    s.PR_LEN_ID = p.PR_LEN_ID
                AND
                    s.PR_LEN_PositedAt < v.PR_LEN_PositedAt
            )
        WHERE
            p.PR_LEN_PR_ID = v.PR_LEN_PR_ID
        AND
            p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
        AND
            a.PR_LEN_Reliability = 1
        ORDER BY
            a.PR_LEN_PositedAt DESC
    ) e
    WHERE
        e.PR_LEN_Program_Length <> v.PR_LEN_Program_Length
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[PR_LEN_Program_Length_Annex] x
        WHERE
            x.PR_LEN_ID = e.PR_LEN_ID
        AND
            x.PR_LEN_PositedAt = v.PR_LEN_PositedAt
    );
END
GO
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lST_Stage] ON [dbo].[lST_Stage]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @ST TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        ST_ID int not null
    );
    INSERT INTO [dbo].[ST_Stage] (
        Metadata_ST
    )
    OUTPUT
        inserted.ST_ID
    INTO
        @ST
    SELECT
        Metadata_ST
    FROM
        inserted
    WHERE
        inserted.ST_ID is null;
    DECLARE @inserted TABLE (
        ST_ID int not null,
        Metadata_ST int not null,
        ST_NAM_ST_ID int null,
        Metadata_ST_NAM int null,
        ST_NAM_ChangedAt datetime2 null,
        ST_NAM_PositedAt datetime2 null,
        ST_NAM_Reliability decimal(5,2) null,
        ST_NAM_Stage_Name nvarchar(42) null,
        ST_LOC_ST_ID int null,
        Metadata_ST_LOC int null,
        ST_LOC_PositedAt datetime2 null,
        ST_LOC_Reliability decimal(5,2) null,
        ST_LOC_Stage_Location geography null,
        ST_AVG_ST_ID int null,
        Metadata_ST_AVG int null,
        ST_AVG_ChangedAt datetime2 null,
        ST_AVG_PositedAt datetime2 null,
        ST_AVG_Reliability decimal(5,2) null,
        ST_AVG_UTL_Utilization tinyint null,
        ST_AVG_Metadata_UTL int null,
        ST_AVG_UTL_ID tinyint null,
        ST_MIN_ST_ID int null,
        Metadata_ST_MIN int null,
        ST_MIN_PositedAt datetime2 null,
        ST_MIN_Reliability decimal(5,2) null,
        ST_MIN_UTL_Utilization tinyint null,
        ST_MIN_Metadata_UTL int null,
        ST_MIN_UTL_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.ST_ID, a.ST_ID),
        i.Metadata_ST,
        ISNULL(ISNULL(i.ST_NAM_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_NAM, i.Metadata_ST),
        ISNULL(i.ST_NAM_ChangedAt, @now),
        ISNULL(i.ST_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.ST_NAM_Reliability, i.Reliability), 1),
        i.ST_NAM_Stage_Name,
        ISNULL(ISNULL(i.ST_LOC_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_LOC, i.Metadata_ST),
        ISNULL(i.ST_LOC_PositedAt, @now),
        ISNULL(ISNULL(i.ST_LOC_Reliability, i.Reliability), 1),
        i.ST_LOC_Stage_Location,
        ISNULL(ISNULL(i.ST_AVG_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_AVG, i.Metadata_ST),
        ISNULL(i.ST_AVG_ChangedAt, @now),
        ISNULL(i.ST_AVG_PositedAt, @now),
        ISNULL(ISNULL(i.ST_AVG_Reliability, i.Reliability), 1),
        i.ST_AVG_UTL_Utilization,
        ISNULL(i.ST_AVG_Metadata_UTL, i.Metadata_ST),
        i.ST_AVG_UTL_ID,
        ISNULL(ISNULL(i.ST_MIN_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_MIN, i.Metadata_ST),
        ISNULL(i.ST_MIN_PositedAt, @now),
        ISNULL(ISNULL(i.ST_MIN_Reliability, i.Reliability), 1),
        i.ST_MIN_UTL_Utilization,
        ISNULL(i.ST_MIN_Metadata_UTL, i.Metadata_ST),
        i.ST_MIN_UTL_ID
    FROM (
        SELECT
            Reliability,
            ST_ID,
            Metadata_ST,
            ST_NAM_ST_ID,
            Metadata_ST_NAM,
            ST_NAM_ChangedAt,
            ST_NAM_PositedAt,
            ST_NAM_Reliability,
            ST_NAM_Stage_Name,
            ST_LOC_ST_ID,
            Metadata_ST_LOC,
            ST_LOC_PositedAt,
            ST_LOC_Reliability,
            ST_LOC_Stage_Location,
            ST_AVG_ST_ID,
            Metadata_ST_AVG,
            ST_AVG_ChangedAt,
            ST_AVG_PositedAt,
            ST_AVG_Reliability,
            ST_AVG_UTL_Utilization,
            ST_AVG_Metadata_UTL,
            ST_AVG_UTL_ID,
            ST_MIN_ST_ID,
            Metadata_ST_MIN,
            ST_MIN_PositedAt,
            ST_MIN_Reliability,
            ST_MIN_UTL_Utilization,
            ST_MIN_Metadata_UTL,
            ST_MIN_UTL_ID,
            ROW_NUMBER() OVER (PARTITION BY ST_ID ORDER BY ST_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @ST a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[ST_NAM_Stage_Name] (
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        i.Metadata_ST_NAM,
        i.ST_NAM_ST_ID,
        i.ST_NAM_Stage_Name,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_PositedAt,
        i.ST_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.ST_NAM_Stage_Name is not null;
    INSERT INTO [dbo].[ST_LOC_Stage_Location] (
        Metadata_ST_LOC,
        ST_LOC_ST_ID,
        ST_LOC_Stage_Location,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        i.Metadata_ST_LOC,
        i.ST_LOC_ST_ID,
        i.ST_LOC_Stage_Location,
        i.ST_LOC_PositedAt,
        i.ST_LOC_Reliability
    FROM
        @inserted i
    WHERE
        i.ST_LOC_Stage_Location is not null;
    INSERT INTO [dbo].[ST_AVG_Stage_Average] (
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        i.Metadata_ST_AVG,
        i.ST_AVG_ST_ID,
        ISNULL(i.ST_AVG_UTL_ID, [kUTL].UTL_ID),
        i.ST_AVG_ChangedAt,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_Utilization = i.ST_AVG_UTL_Utilization
    WHERE
        ISNULL(i.ST_AVG_UTL_ID, [kUTL].UTL_ID) is not null;
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum] (
        Metadata_ST_MIN,
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        i.Metadata_ST_MIN,
        i.ST_MIN_ST_ID,
        ISNULL(i.ST_MIN_UTL_ID, [kUTL].UTL_ID),
        i.ST_MIN_PositedAt,
        i.ST_MIN_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_Utilization = i.ST_MIN_UTL_Utilization
    WHERE
        ISNULL(i.ST_MIN_UTL_ID, [kUTL].UTL_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lST_Stage] ON [dbo].[lST_Stage]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_Metadata_ST bit = CASE WHEN UPDATE(Metadata_ST) THEN 1 ELSE 0 END;
    DECLARE @updated_Reliability bit = CASE WHEN UPDATE(Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_ID))
        RAISERROR('The identity column ST_ID is not updatable.', 16, 1);
    DECLARE @updated_ST_NAM_Stage_Name bit = CASE WHEN UPDATE(ST_NAM_Stage_Name) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_NAM bit = CASE WHEN UPDATE(Metadata_ST_NAM) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_NAM_ChangedAt bit = CASE WHEN UPDATE(ST_NAM_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_NAM_PositedAt bit = CASE WHEN UPDATE(ST_NAM_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_NAM_Reliability bit = CASE WHEN UPDATE(ST_NAM_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_NAM_ID))
        RAISERROR('The identity column ST_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_NAM_ST_ID))
        RAISERROR('The foreign key column ST_NAM_ST_ID is not updatable.', 16, 1);
    IF (
        @updated_ST_NAM_Stage_Name = 1 OR
        @updated_ST_NAM_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[ST_NAM_Stage_Name] (
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_NAM = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_NAM
            END, i.Metadata_ST),
            ISNULL(i.ST_NAM_ST_ID, i.ST_ID),
            i.ST_NAM_Stage_Name,
            cast(ISNULL(CASE
                WHEN @updated_ST_NAM_ChangedAt = 1 THEN i.ST_NAM_ChangedAt
                WHEN d.ST_NAM_Checksum = dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max)))
                THEN i.ST_NAM_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN @updated_ST_NAM_PositedAt = 1 THEN i.ST_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_NAM_Reliability = 1 THEN i.ST_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_NAM_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        WHERE
            i.ST_NAM_Stage_Name is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_ST_NAM_ChangedAt = 1 OR
            @updated_ST_NAM_PositedAt = 1 OR
            d.ST_NAM_Stage_Name is null OR
            d.ST_NAM_Checksum <> dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max))) OR
            d.ST_NAM_Reliability <> ISNULL(CASE
                WHEN @updated_ST_NAM_Reliability = 1 THEN i.ST_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_NAM_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_ST_NAM_Stage_Name = 1
    )
    BEGIN
        INSERT INTO [dbo].[ST_NAM_Stage_Name] (
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_NAM = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_NAM
            END, i.Metadata_ST),
            p.ST_NAM_ST_ID,
            p.ST_NAM_Stage_Name,
            p.ST_NAM_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_ST_NAM_PositedAt = 1 THEN i.ST_NAM_PositedAt
                WHEN @updated_ST_NAM_ChangedAt = 1 THEN i.ST_NAM_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[ST_NAM_Stage_Name_Posit] p
        ON
            p.ST_NAM_ID = i.ST_NAM_ID
        WHERE
            i.ST_NAM_Stage_Name is null
    END
    DECLARE @updated_ST_LOC_Stage_Location bit = CASE WHEN UPDATE(ST_LOC_Stage_Location) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_LOC bit = CASE WHEN UPDATE(Metadata_ST_LOC) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_LOC_PositedAt bit = CASE WHEN UPDATE(ST_LOC_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_LOC_Reliability bit = CASE WHEN UPDATE(ST_LOC_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_LOC_ID))
        RAISERROR('The identity column ST_LOC_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_LOC_ST_ID))
        RAISERROR('The foreign key column ST_LOC_ST_ID is not updatable.', 16, 1);
    IF (
        @updated_ST_LOC_Stage_Location = 1 OR
        @updated_ST_LOC_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[ST_LOC_Stage_Location] (
            Metadata_ST_LOC,
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_LOC = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_LOC
            END, i.Metadata_ST),
            ISNULL(i.ST_LOC_ST_ID, i.ST_ID),
            i.ST_LOC_Stage_Location,
            cast(ISNULL(CASE
                WHEN @updated_ST_LOC_PositedAt = 1 THEN i.ST_LOC_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_LOC_Reliability = 1 THEN i.ST_LOC_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_LOC_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        WHERE
            i.ST_LOC_Stage_Location is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_ST_LOC_PositedAt = 1 OR
            d.ST_LOC_Stage_Location is null OR
            d.ST_LOC_Checksum <> dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))) OR
            d.ST_LOC_Reliability <> ISNULL(CASE
                WHEN @updated_ST_LOC_Reliability = 1 THEN i.ST_LOC_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_LOC_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_ST_LOC_Stage_Location = 1
    )
    BEGIN
        INSERT INTO [dbo].[ST_LOC_Stage_Location] (
            Metadata_ST_LOC,
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_LOC = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_LOC
            END, i.Metadata_ST),
            p.ST_LOC_ST_ID,
            p.ST_LOC_Stage_Location,
            cast(ISNULL(CASE
                WHEN @updated_ST_LOC_PositedAt = 1 THEN i.ST_LOC_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[ST_LOC_Stage_Location_Posit] p
        ON
            p.ST_LOC_ID = i.ST_LOC_ID
        WHERE
            i.ST_LOC_Stage_Location is null
    END
    DECLARE @updated_ST_AVG_UTL_ID bit = CASE WHEN UPDATE(ST_AVG_UTL_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_UTL_Utilization bit = CASE WHEN UPDATE(ST_AVG_UTL_Utilization) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_AVG bit = CASE WHEN UPDATE(Metadata_ST_AVG) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_ChangedAt bit = CASE WHEN UPDATE(ST_AVG_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_PositedAt bit = CASE WHEN UPDATE(ST_AVG_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_Reliability bit = CASE WHEN UPDATE(ST_AVG_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_AVG_ID))
        RAISERROR('The identity column ST_AVG_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_AVG_ST_ID))
        RAISERROR('The foreign key column ST_AVG_ST_ID is not updatable.', 16, 1);
    IF (
        @updated_ST_AVG_UTL_ID = 1 OR
        @updated_ST_AVG_UTL_Utilization = 1 OR
        @updated_ST_AVG_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[ST_AVG_Stage_Average] (
            Metadata_ST_AVG,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_AVG = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_AVG
            END, i.Metadata_ST),
            ISNULL(i.ST_AVG_ST_ID, i.ST_ID),
            CASE
                WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID
                ELSE [kUTL].UTL_ID
            END,
            cast(ISNULL(CASE
                WHEN @updated_ST_AVG_ChangedAt = 1 THEN i.ST_AVG_ChangedAt
                WHEN d.ST_AVG_UTL_ID = CASE WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID ELSE [kUTL].UTL_ID END
                THEN i.ST_AVG_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN @updated_ST_AVG_PositedAt = 1 THEN i.ST_AVG_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_AVG_Reliability = 1 THEN i.ST_AVG_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_AVG_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.ST_AVG_UTL_Utilization
        LEFT JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        WHERE
            CASE
                WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID
                ELSE [kUTL].UTL_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_ST_AVG_ChangedAt = 1 OR
            @updated_ST_AVG_PositedAt = 1 OR
            d.ST_AVG_UTL_ID is null OR
            d.ST_AVG_UTL_ID <> CASE WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID ELSE [kUTL].UTL_ID END OR
            d.ST_AVG_Reliability <> ISNULL(CASE
                WHEN @updated_ST_AVG_Reliability = 1 THEN i.ST_AVG_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_AVG_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_ST_AVG_UTL_ID = 1 OR
        @updated_ST_AVG_UTL_Utilization = 1
    )
    BEGIN
        INSERT INTO [dbo].[ST_AVG_Stage_Average] (
            Metadata_ST_AVG,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_AVG = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_AVG
            END, i.Metadata_ST),
            p.ST_AVG_ST_ID,
            p.ST_AVG_UTL_ID,
            p.ST_AVG_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_ST_AVG_PositedAt = 1 THEN i.ST_AVG_PositedAt
                WHEN @updated_ST_AVG_ChangedAt = 1 THEN i.ST_AVG_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[ST_AVG_Stage_Average_Posit] p
        ON
            p.ST_AVG_ID = i.ST_AVG_ID
        WHERE
            (@updated_ST_AVG_UTL_ID = 1 AND i.ST_AVG_UTL_ID is null)
        OR
            (@updated_ST_AVG_UTL_Utilization = 1 AND i.ST_AVG_UTL_Utilization is null);
    END
    DECLARE @updated_ST_MIN_UTL_ID bit = CASE WHEN UPDATE(ST_MIN_UTL_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_MIN_UTL_Utilization bit = CASE WHEN UPDATE(ST_MIN_UTL_Utilization) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_MIN bit = CASE WHEN UPDATE(Metadata_ST_MIN) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_MIN_PositedAt bit = CASE WHEN UPDATE(ST_MIN_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_MIN_Reliability bit = CASE WHEN UPDATE(ST_MIN_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_MIN_ID))
        RAISERROR('The identity column ST_MIN_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_MIN_ST_ID))
        RAISERROR('The foreign key column ST_MIN_ST_ID is not updatable.', 16, 1);
    IF (
        @updated_ST_MIN_UTL_ID = 1 OR
        @updated_ST_MIN_UTL_Utilization = 1 OR
        @updated_ST_MIN_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[ST_MIN_Stage_Minimum] (
            Metadata_ST_MIN,
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_MIN = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_MIN
            END, i.Metadata_ST),
            ISNULL(i.ST_MIN_ST_ID, i.ST_ID),
            CASE
                WHEN @updated_ST_MIN_UTL_ID = 1 THEN i.ST_MIN_UTL_ID
                ELSE [kUTL].UTL_ID
            END,
            cast(ISNULL(CASE
                WHEN @updated_ST_MIN_PositedAt = 1 THEN i.ST_MIN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_MIN_Reliability = 1 THEN i.ST_MIN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_MIN_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.ST_MIN_UTL_Utilization
        LEFT JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        WHERE
            CASE
                WHEN @updated_ST_MIN_UTL_ID = 1 THEN i.ST_MIN_UTL_ID
                ELSE [kUTL].UTL_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_ST_MIN_PositedAt = 1 OR
            d.ST_MIN_UTL_ID is null OR
            d.ST_MIN_UTL_ID <> CASE WHEN @updated_ST_MIN_UTL_ID = 1 THEN i.ST_MIN_UTL_ID ELSE [kUTL].UTL_ID END OR
            d.ST_MIN_Reliability <> ISNULL(CASE
                WHEN @updated_ST_MIN_Reliability = 1 THEN i.ST_MIN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_MIN_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_ST_MIN_UTL_ID = 1 OR
        @updated_ST_MIN_UTL_Utilization = 1
    )
    BEGIN
        INSERT INTO [dbo].[ST_MIN_Stage_Minimum] (
            Metadata_ST_MIN,
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_MIN = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_MIN
            END, i.Metadata_ST),
            p.ST_MIN_ST_ID,
            p.ST_MIN_UTL_ID,
            cast(ISNULL(CASE
                WHEN @updated_ST_MIN_PositedAt = 1 THEN i.ST_MIN_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[ST_MIN_Stage_Minimum_Posit] p
        ON
            p.ST_MIN_ID = i.ST_MIN_ID
        WHERE
            (@updated_ST_MIN_UTL_ID = 1 AND i.ST_MIN_UTL_ID is null)
        OR
            (@updated_ST_MIN_UTL_Utilization = 1 AND i.ST_MIN_UTL_Utilization is null);
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lST_Stage] ON [dbo].[lST_Stage]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[ST_NAM_Stage_Name_Annex] (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        d.Metadata_ST_NAM,
        d.ST_NAM_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.ST_NAM_ID is not null;
    INSERT INTO [dbo].[ST_LOC_Stage_Location_Annex] (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        d.Metadata_ST_LOC,
        d.ST_LOC_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.ST_LOC_ID is not null;
    INSERT INTO [dbo].[ST_AVG_Stage_Average_Annex] (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        d.Metadata_ST_AVG,
        d.ST_AVG_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.ST_AVG_ID is not null;
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Annex] (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        d.Metadata_ST_MIN,
        d.ST_MIN_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.ST_MIN_ID is not null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_Actor] ON [dbo].[lAC_Actor]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @AC TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        AC_ID int not null
    );
    INSERT INTO [dbo].[AC_Actor] (
        Metadata_AC
    )
    OUTPUT
        inserted.AC_ID
    INTO
        @AC
    SELECT
        Metadata_AC
    FROM
        inserted
    WHERE
        inserted.AC_ID is null;
    DECLARE @inserted TABLE (
        AC_ID int not null,
        Metadata_AC int not null,
        AC_NAM_AC_ID int null,
        Metadata_AC_NAM int null,
        AC_NAM_ChangedAt datetime2 null,
        AC_NAM_PositedAt datetime2 null,
        AC_NAM_Reliability decimal(5,2) null,
        AC_NAM_Actor_Name nvarchar(42) null,
        AC_GEN_AC_ID int null,
        Metadata_AC_GEN int null,
        AC_GEN_PositedAt datetime2 null,
        AC_GEN_Reliability decimal(5,2) null,
        AC_GEN_GEN_Gender nvarchar(42) null,
        AC_GEN_Metadata_GEN int null,
        AC_GEN_GEN_ID tinyint null,
        AC_PLV_AC_ID int null,
        Metadata_AC_PLV int null,
        AC_PLV_ChangedAt datetime2 null,
        AC_PLV_PositedAt datetime2 null,
        AC_PLV_Reliability decimal(5,2) null,
        AC_PLV_PLV_ProfessionalLevel nvarchar(max) null,
        AC_PLV_PLV_Checksum varbinary(16) null,
        AC_PLV_Metadata_PLV int null,
        AC_PLV_PLV_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.AC_ID, a.AC_ID),
        i.Metadata_AC,
        ISNULL(ISNULL(i.AC_NAM_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_NAM, i.Metadata_AC),
        ISNULL(i.AC_NAM_ChangedAt, @now),
        ISNULL(i.AC_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.AC_NAM_Reliability, i.Reliability), 1),
        i.AC_NAM_Actor_Name,
        ISNULL(ISNULL(i.AC_GEN_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_GEN, i.Metadata_AC),
        ISNULL(i.AC_GEN_PositedAt, @now),
        ISNULL(ISNULL(i.AC_GEN_Reliability, i.Reliability), 1),
        i.AC_GEN_GEN_Gender,
        ISNULL(i.AC_GEN_Metadata_GEN, i.Metadata_AC),
        i.AC_GEN_GEN_ID,
        ISNULL(ISNULL(i.AC_PLV_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_PLV, i.Metadata_AC),
        ISNULL(i.AC_PLV_ChangedAt, @now),
        ISNULL(i.AC_PLV_PositedAt, @now),
        ISNULL(ISNULL(i.AC_PLV_Reliability, i.Reliability), 1),
        i.AC_PLV_PLV_ProfessionalLevel,
        ISNULL(i.AC_PLV_PLV_Checksum, dbo.MD5(cast(i.AC_PLV_PLV_ProfessionalLevel as varbinary(max)))),
        ISNULL(i.AC_PLV_Metadata_PLV, i.Metadata_AC),
        i.AC_PLV_PLV_ID
    FROM (
        SELECT
            Reliability,
            AC_ID,
            Metadata_AC,
            AC_NAM_AC_ID,
            Metadata_AC_NAM,
            AC_NAM_ChangedAt,
            AC_NAM_PositedAt,
            AC_NAM_Reliability,
            AC_NAM_Actor_Name,
            AC_GEN_AC_ID,
            Metadata_AC_GEN,
            AC_GEN_PositedAt,
            AC_GEN_Reliability,
            AC_GEN_GEN_Gender,
            AC_GEN_Metadata_GEN,
            AC_GEN_GEN_ID,
            AC_PLV_AC_ID,
            Metadata_AC_PLV,
            AC_PLV_ChangedAt,
            AC_PLV_PositedAt,
            AC_PLV_Reliability,
            AC_PLV_PLV_ProfessionalLevel,
            AC_PLV_PLV_Checksum,
            AC_PLV_Metadata_PLV,
            AC_PLV_PLV_ID,
            ROW_NUMBER() OVER (PARTITION BY AC_ID ORDER BY AC_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @AC a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[AC_NAM_Actor_Name] (
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        i.Metadata_AC_NAM,
        i.AC_NAM_AC_ID,
        i.AC_NAM_Actor_Name,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.AC_NAM_Actor_Name is not null;
    INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
        Metadata_AC_GEN,
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        i.Metadata_AC_GEN,
        i.AC_GEN_AC_ID,
        ISNULL(i.AC_GEN_GEN_ID, [kGEN].GEN_ID),
        i.AC_GEN_PositedAt,
        i.AC_GEN_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[GEN_Gender] [kGEN]
    ON
        [kGEN].GEN_Gender = i.AC_GEN_GEN_Gender
    WHERE
        ISNULL(i.AC_GEN_GEN_ID, [kGEN].GEN_ID) is not null;
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        i.Metadata_AC_PLV,
        i.AC_PLV_AC_ID,
        ISNULL(i.AC_PLV_PLV_ID, [kPLV].PLV_ID),
        i.AC_PLV_ChangedAt,
        i.AC_PLV_PositedAt,
        i.AC_PLV_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[PLV_ProfessionalLevel] [kPLV]
    ON
        [kPLV].PLV_Checksum = i.AC_PLV_PLV_Checksum
    WHERE
        ISNULL(i.AC_PLV_PLV_ID, [kPLV].PLV_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_Actor] ON [dbo].[lAC_Actor]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_Metadata_AC bit = CASE WHEN UPDATE(Metadata_AC) THEN 1 ELSE 0 END;
    DECLARE @updated_Reliability bit = CASE WHEN UPDATE(Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_ID))
        RAISERROR('The identity column AC_ID is not updatable.', 16, 1);
    DECLARE @updated_AC_NAM_Actor_Name bit = CASE WHEN UPDATE(AC_NAM_Actor_Name) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_AC_NAM bit = CASE WHEN UPDATE(Metadata_AC_NAM) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_NAM_ChangedAt bit = CASE WHEN UPDATE(AC_NAM_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_NAM_PositedAt bit = CASE WHEN UPDATE(AC_NAM_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_NAM_Reliability bit = CASE WHEN UPDATE(AC_NAM_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_NAM_ID))
        RAISERROR('The identity column AC_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_NAM_AC_ID))
        RAISERROR('The foreign key column AC_NAM_AC_ID is not updatable.', 16, 1);
    IF (
        @updated_AC_NAM_Actor_Name = 1 OR
        @updated_AC_NAM_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[AC_NAM_Actor_Name] (
            Metadata_AC_NAM,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_NAM = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_NAM
            END, i.Metadata_AC),
            ISNULL(i.AC_NAM_AC_ID, i.AC_ID),
            i.AC_NAM_Actor_Name,
            cast(ISNULL(CASE
                WHEN @updated_AC_NAM_ChangedAt = 1 THEN i.AC_NAM_ChangedAt
                WHEN d.AC_NAM_Checksum = dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max)))
                THEN i.AC_NAM_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN @updated_AC_NAM_PositedAt = 1 THEN i.AC_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_AC_NAM_Reliability = 1 THEN i.AC_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_NAM_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.AC_ID = i.AC_ID
        WHERE
            i.AC_NAM_Actor_Name is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_AC_NAM_ChangedAt = 1 OR
            @updated_AC_NAM_PositedAt = 1 OR
            d.AC_NAM_Actor_Name is null OR
            d.AC_NAM_Checksum <> dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max))) OR
            d.AC_NAM_Reliability <> ISNULL(CASE
                WHEN @updated_AC_NAM_Reliability = 1 THEN i.AC_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_NAM_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_AC_NAM_Actor_Name = 1
    )
    BEGIN
        INSERT INTO [dbo].[AC_NAM_Actor_Name] (
            Metadata_AC_NAM,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_NAM = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_NAM
            END, i.Metadata_AC),
            p.AC_NAM_AC_ID,
            p.AC_NAM_Actor_Name,
            p.AC_NAM_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_AC_NAM_PositedAt = 1 THEN i.AC_NAM_PositedAt
                WHEN @updated_AC_NAM_ChangedAt = 1 THEN i.AC_NAM_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[AC_NAM_Actor_Name_Posit] p
        ON
            p.AC_NAM_ID = i.AC_NAM_ID
        WHERE
            i.AC_NAM_Actor_Name is null
    END
    DECLARE @updated_AC_GEN_GEN_ID bit = CASE WHEN UPDATE(AC_GEN_GEN_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_GEN_GEN_Gender bit = CASE WHEN UPDATE(AC_GEN_GEN_Gender) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_AC_GEN bit = CASE WHEN UPDATE(Metadata_AC_GEN) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_GEN_PositedAt bit = CASE WHEN UPDATE(AC_GEN_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_GEN_Reliability bit = CASE WHEN UPDATE(AC_GEN_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_GEN_ID))
        RAISERROR('The identity column AC_GEN_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_GEN_AC_ID))
        RAISERROR('The foreign key column AC_GEN_AC_ID is not updatable.', 16, 1);
    IF (
        @updated_AC_GEN_GEN_ID = 1 OR
        @updated_AC_GEN_GEN_Gender = 1 OR
        @updated_AC_GEN_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
            Metadata_AC_GEN,
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_GEN = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_GEN
            END, i.Metadata_AC),
            ISNULL(i.AC_GEN_AC_ID, i.AC_ID),
            CASE
                WHEN @updated_AC_GEN_GEN_ID = 1 THEN i.AC_GEN_GEN_ID
                ELSE [kGEN].GEN_ID
            END,
            cast(ISNULL(CASE
                WHEN @updated_AC_GEN_PositedAt = 1 THEN i.AC_GEN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_AC_GEN_Reliability = 1 THEN i.AC_GEN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_GEN_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[GEN_Gender] [kGEN]
        ON
            [kGEN].GEN_Gender = i.AC_GEN_GEN_Gender
        LEFT JOIN
            deleted d
        ON
            d.AC_ID = i.AC_ID
        WHERE
            CASE
                WHEN @updated_AC_GEN_GEN_ID = 1 THEN i.AC_GEN_GEN_ID
                ELSE [kGEN].GEN_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_AC_GEN_PositedAt = 1 OR
            d.AC_GEN_GEN_ID is null OR
            d.AC_GEN_GEN_ID <> CASE WHEN @updated_AC_GEN_GEN_ID = 1 THEN i.AC_GEN_GEN_ID ELSE [kGEN].GEN_ID END OR
            d.AC_GEN_Reliability <> ISNULL(CASE
                WHEN @updated_AC_GEN_Reliability = 1 THEN i.AC_GEN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_GEN_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_AC_GEN_GEN_ID = 1 OR
        @updated_AC_GEN_GEN_Gender = 1
    )
    BEGIN
        INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
            Metadata_AC_GEN,
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_GEN = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_GEN
            END, i.Metadata_AC),
            p.AC_GEN_AC_ID,
            p.AC_GEN_GEN_ID,
            cast(ISNULL(CASE
                WHEN @updated_AC_GEN_PositedAt = 1 THEN i.AC_GEN_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[AC_GEN_Actor_Gender_Posit] p
        ON
            p.AC_GEN_ID = i.AC_GEN_ID
        WHERE
            (@updated_AC_GEN_GEN_ID = 1 AND i.AC_GEN_GEN_ID is null)
        OR
            (@updated_AC_GEN_GEN_Gender = 1 AND i.AC_GEN_GEN_Gender is null);
    END
    DECLARE @updated_AC_PLV_PLV_ID bit = CASE WHEN UPDATE(AC_PLV_PLV_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_PLV_ProfessionalLevel bit = CASE WHEN UPDATE(AC_PLV_PLV_ProfessionalLevel) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_AC_PLV bit = CASE WHEN UPDATE(Metadata_AC_PLV) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_ChangedAt bit = CASE WHEN UPDATE(AC_PLV_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_PositedAt bit = CASE WHEN UPDATE(AC_PLV_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_Reliability bit = CASE WHEN UPDATE(AC_PLV_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_PLV_ID))
        RAISERROR('The identity column AC_PLV_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_PLV_AC_ID))
        RAISERROR('The foreign key column AC_PLV_AC_ID is not updatable.', 16, 1);
    IF (
        @updated_AC_PLV_PLV_ID = 1 OR
        @updated_AC_PLV_PLV_ProfessionalLevel = 1 OR
        @updated_AC_PLV_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
            Metadata_AC_PLV,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_PLV = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_PLV
            END, i.Metadata_AC),
            ISNULL(i.AC_PLV_AC_ID, i.AC_ID),
            CASE
                WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID
                ELSE [kPLV].PLV_ID
            END,
            cast(ISNULL(CASE
                WHEN @updated_AC_PLV_ChangedAt = 1 THEN i.AC_PLV_ChangedAt
                WHEN d.AC_PLV_PLV_ID = CASE WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID ELSE [kPLV].PLV_ID END
                THEN i.AC_PLV_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN @updated_AC_PLV_PositedAt = 1 THEN i.AC_PLV_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_AC_PLV_Reliability = 1 THEN i.AC_PLV_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_PLV_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[PLV_ProfessionalLevel] [kPLV]
        ON
            [kPLV].PLV_Checksum = dbo.MD5(cast(i.AC_PLV_PLV_ProfessionalLevel as varbinary(max)))
        LEFT JOIN
            deleted d
        ON
            d.AC_ID = i.AC_ID
        WHERE
            CASE
                WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID
                ELSE [kPLV].PLV_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_AC_PLV_ChangedAt = 1 OR
            @updated_AC_PLV_PositedAt = 1 OR
            d.AC_PLV_PLV_ID is null OR
            d.AC_PLV_PLV_ID <> CASE WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID ELSE [kPLV].PLV_ID END OR
            d.AC_PLV_Reliability <> ISNULL(CASE
                WHEN @updated_AC_PLV_Reliability = 1 THEN i.AC_PLV_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_PLV_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_AC_PLV_PLV_ID = 1 OR
        @updated_AC_PLV_PLV_ProfessionalLevel = 1
    )
    BEGIN
        INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
            Metadata_AC_PLV,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_PLV = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_PLV
            END, i.Metadata_AC),
            p.AC_PLV_AC_ID,
            p.AC_PLV_PLV_ID,
            p.AC_PLV_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_AC_PLV_PositedAt = 1 THEN i.AC_PLV_PositedAt
                WHEN @updated_AC_PLV_ChangedAt = 1 THEN i.AC_PLV_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
        ON
            p.AC_PLV_ID = i.AC_PLV_ID
        WHERE
            (@updated_AC_PLV_PLV_ID = 1 AND i.AC_PLV_PLV_ID is null)
        OR
            (@updated_AC_PLV_PLV_ProfessionalLevel = 1 AND i.AC_PLV_PLV_ProfessionalLevel is null);
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_Actor] ON [dbo].[lAC_Actor]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_NAM_Actor_Name_Annex] (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        d.Metadata_AC_NAM,
        d.AC_NAM_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.AC_NAM_ID is not null;
    INSERT INTO [dbo].[AC_GEN_Actor_Gender_Annex] (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        d.Metadata_AC_GEN,
        d.AC_GEN_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.AC_GEN_ID is not null;
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        d.Metadata_AC_PLV,
        d.AC_PLV_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.AC_PLV_ID is not null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPR_Program] ON [dbo].[lPR_Program]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @PR TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        PR_ID int not null
    );
    INSERT INTO [dbo].[PR_Program] (
        Metadata_PR
    )
    OUTPUT
        inserted.PR_ID
    INTO
        @PR
    SELECT
        Metadata_PR
    FROM
        inserted
    WHERE
        inserted.PR_ID is null;
    DECLARE @inserted TABLE (
        PR_ID int not null,
        Metadata_PR int not null,
        PR_NAM_PR_ID int null,
        Metadata_PR_NAM int null,
        PR_NAM_PositedAt datetime2 null,
        PR_NAM_Reliability decimal(5,2) null,
        PR_NAM_Program_Name nvarchar(42) null,
        PR_LEN_PR_ID int null,
        Metadata_PR_LEN int null,
        PR_LEN_ChangedAt date null,
        PR_LEN_PositedAt datetime2 null,
        PR_LEN_Reliability decimal(5,2) null,
        PR_LEN_Program_Length time null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.PR_ID, a.PR_ID),
        i.Metadata_PR,
        ISNULL(ISNULL(i.PR_NAM_PR_ID, i.PR_ID), a.PR_ID),
        ISNULL(i.Metadata_PR_NAM, i.Metadata_PR),
        ISNULL(i.PR_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.PR_NAM_Reliability, i.Reliability), 1),
        i.PR_NAM_Program_Name,
        ISNULL(ISNULL(i.PR_LEN_PR_ID, i.PR_ID), a.PR_ID),
        ISNULL(i.Metadata_PR_LEN, i.Metadata_PR),
        ISNULL(i.PR_LEN_ChangedAt, @now),
        ISNULL(i.PR_LEN_PositedAt, @now),
        ISNULL(ISNULL(i.PR_LEN_Reliability, i.Reliability), 1),
        i.PR_LEN_Program_Length
    FROM (
        SELECT
            Reliability,
            PR_ID,
            Metadata_PR,
            PR_NAM_PR_ID,
            Metadata_PR_NAM,
            PR_NAM_PositedAt,
            PR_NAM_Reliability,
            PR_NAM_Program_Name,
            PR_LEN_PR_ID,
            Metadata_PR_LEN,
            PR_LEN_ChangedAt,
            PR_LEN_PositedAt,
            PR_LEN_Reliability,
            PR_LEN_Program_Length,
            ROW_NUMBER() OVER (PARTITION BY PR_ID ORDER BY PR_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @PR a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[PR_NAM_Program_Name] (
        Metadata_PR_NAM,
        PR_NAM_PR_ID,
        PR_NAM_Program_Name,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        i.Metadata_PR_NAM,
        i.PR_NAM_PR_ID,
        i.PR_NAM_Program_Name,
        i.PR_NAM_PositedAt,
        i.PR_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.PR_NAM_Program_Name is not null;
    INSERT INTO [dbo].[PR_LEN_Program_Length] (
        Metadata_PR_LEN,
        PR_LEN_PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        i.Metadata_PR_LEN,
        i.PR_LEN_PR_ID,
        i.PR_LEN_Program_Length,
        i.PR_LEN_ChangedAt,
        i.PR_LEN_PositedAt,
        i.PR_LEN_Reliability
    FROM
        @inserted i
    WHERE
        i.PR_LEN_Program_Length is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lPR_Program] ON [dbo].[lPR_Program]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_Metadata_PR bit = CASE WHEN UPDATE(Metadata_PR) THEN 1 ELSE 0 END;
    DECLARE @updated_Reliability bit = CASE WHEN UPDATE(Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_ID))
        RAISERROR('The identity column PR_ID is not updatable.', 16, 1);
    DECLARE @updated_PR_NAM_Program_Name bit = CASE WHEN UPDATE(PR_NAM_Program_Name) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_PR_NAM bit = CASE WHEN UPDATE(Metadata_PR_NAM) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_NAM_PositedAt bit = CASE WHEN UPDATE(PR_NAM_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_NAM_Reliability bit = CASE WHEN UPDATE(PR_NAM_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_NAM_ID))
        RAISERROR('The identity column PR_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_NAM_PR_ID))
        RAISERROR('The foreign key column PR_NAM_PR_ID is not updatable.', 16, 1);
    IF (
        @updated_PR_NAM_Program_Name = 1 OR
        @updated_PR_NAM_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[PR_NAM_Program_Name] (
            Metadata_PR_NAM,
            PR_NAM_PR_ID,
            PR_NAM_Program_Name,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_PR = 1 AND @updated_Metadata_PR_NAM = 0
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_NAM
            END, i.Metadata_PR),
            ISNULL(i.PR_NAM_PR_ID, i.PR_ID),
            i.PR_NAM_Program_Name,
            cast(ISNULL(CASE
                WHEN @updated_PR_NAM_PositedAt = 1 THEN i.PR_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_PR_NAM_Reliability = 1 THEN i.PR_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.PR_NAM_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.PR_ID = i.PR_ID
        WHERE
            i.PR_NAM_Program_Name is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_PR_NAM_PositedAt = 1 OR
            d.PR_NAM_Program_Name is null OR
            d.PR_NAM_Program_Name <> i.PR_NAM_Program_Name OR
            d.PR_NAM_Reliability <> ISNULL(CASE
                WHEN @updated_PR_NAM_Reliability = 1 THEN i.PR_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.PR_NAM_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_PR_NAM_Program_Name = 1
    )
    BEGIN
        INSERT INTO [dbo].[PR_NAM_Program_Name] (
            Metadata_PR_NAM,
            PR_NAM_PR_ID,
            PR_NAM_Program_Name,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_PR = 1 AND @updated_Metadata_PR_NAM = 0
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_NAM
            END, i.Metadata_PR),
            p.PR_NAM_PR_ID,
            p.PR_NAM_Program_Name,
            cast(ISNULL(CASE
                WHEN @updated_PR_NAM_PositedAt = 1 THEN i.PR_NAM_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[PR_NAM_Program_Name_Posit] p
        ON
            p.PR_NAM_ID = i.PR_NAM_ID
        WHERE
            i.PR_NAM_Program_Name is null
    END
    DECLARE @updated_PR_LEN_Program_Length bit = CASE WHEN UPDATE(PR_LEN_Program_Length) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_PR_LEN bit = CASE WHEN UPDATE(Metadata_PR_LEN) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_LEN_ChangedAt bit = CASE WHEN UPDATE(PR_LEN_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_LEN_PositedAt bit = CASE WHEN UPDATE(PR_LEN_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_LEN_Reliability bit = CASE WHEN UPDATE(PR_LEN_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_LEN_ID))
        RAISERROR('The identity column PR_LEN_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_LEN_PR_ID))
        RAISERROR('The foreign key column PR_LEN_PR_ID is not updatable.', 16, 1);
    IF (
        @updated_PR_LEN_Program_Length = 1 OR
        @updated_PR_LEN_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[PR_LEN_Program_Length] (
            Metadata_PR_LEN,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_PR = 1 AND @updated_Metadata_PR_LEN = 0
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_LEN
            END, i.Metadata_PR),
            ISNULL(i.PR_LEN_PR_ID, i.PR_ID),
            i.PR_LEN_Program_Length,
            cast(ISNULL(CASE
                WHEN @updated_PR_LEN_ChangedAt = 1 THEN i.PR_LEN_ChangedAt
                WHEN d.PR_LEN_Program_Length = i.PR_LEN_Program_Length
                THEN i.PR_LEN_ChangedAt -- the shown version is asserted again
            END, @now) as date),
            cast(ISNULL(CASE
                WHEN @updated_PR_LEN_PositedAt = 1 THEN i.PR_LEN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_PR_LEN_Reliability = 1 THEN i.PR_LEN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.PR_LEN_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.PR_ID = i.PR_ID
        WHERE
            i.PR_LEN_Program_Length is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_PR_LEN_ChangedAt = 1 OR
            @updated_PR_LEN_PositedAt = 1 OR
            d.PR_LEN_Program_Length is null OR
            d.PR_LEN_Program_Length <> i.PR_LEN_Program_Length OR
            d.PR_LEN_Reliability <> ISNULL(CASE
                WHEN @updated_PR_LEN_Reliability = 1 THEN i.PR_LEN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.PR_LEN_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_PR_LEN_Program_Length = 1
    )
    BEGIN
        INSERT INTO [dbo].[PR_LEN_Program_Length] (
            Metadata_PR_LEN,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_PR = 1 AND @updated_Metadata_PR_LEN = 0
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_LEN
            END, i.Metadata_PR),
            p.PR_LEN_PR_ID,
            p.PR_LEN_Program_Length,
            p.PR_LEN_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_PR_LEN_PositedAt = 1 THEN i.PR_LEN_PositedAt
                WHEN @updated_PR_LEN_ChangedAt = 1 THEN i.PR_LEN_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[PR_LEN_Program_Length_Posit] p
        ON
            p.PR_LEN_ID = i.PR_LEN_ID
        WHERE
            i.PR_LEN_Program_Length is null
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPR_Program] ON [dbo].[lPR_Program]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PR_NAM_Program_Name_Annex] (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        d.Metadata_PR_NAM,
        d.PR_NAM_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.PR_NAM_ID is not null;
    INSERT INTO [dbo].[PR_LEN_Program_Length_Annex] (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        d.Metadata_PR_LEN,
        d.PR_LEN_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.PR_LEN_ID is not null;
END
GO
-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- The roles of a nexus are part of its identity, so they are not updatable.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_Event instead of INSERT trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lEV_Event] ON [dbo].[lEV_Event]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        EV_ID int not null,
        Metadata_EV int not null,
        EV_DAT_EV_ID int null,
        Metadata_EV_DAT int null,
        EV_DAT_PositedAt datetime2 null,
        EV_DAT_Reliability decimal(5,2) null,
        EV_DAT_Event_Date datetime2 null,
        EV_AUD_EV_ID int null,
        Metadata_EV_AUD int null,
        EV_AUD_PositedAt datetime2 null,
        EV_AUD_Reliability decimal(5,2) null,
        EV_AUD_Event_Audience int null,
        EV_REV_EV_ID int null,
        Metadata_EV_REV int null,
        EV_REV_PositedAt datetime2 null,
        EV_REV_Reliability decimal(5,2) null,
        EV_REV_Event_Revenue decimal(19,4) null
    );
    -- a nexus row for each row without an identity; the merge outputs every new identity together with the values of
    -- the row it was made for, so each new row keeps its own attributes, also when several are inserted at once
    MERGE INTO [dbo].[EV_Event]
    USING inserted AS i
    ON 1 = 0
    WHEN NOT MATCHED AND i.EV_ID is null THEN INSERT (
        ST_ID_wasHeldAt,
        PR_ID_wasPlayed,
        ETY_ID_of,
        Metadata_EV 
    )
    VALUES (
        i.ST_ID_wasHeldAt,
        i.PR_ID_wasPlayed,
        i.ETY_ID_of,
        i.Metadata_EV 
    )
    OUTPUT
        inserted.EV_ID,
        i.Metadata_EV,
        ISNULL(i.EV_DAT_EV_ID, inserted.EV_ID),
        ISNULL(i.Metadata_EV_DAT, i.Metadata_EV),
        ISNULL(i.EV_DAT_PositedAt, @now),
        ISNULL(ISNULL(i.EV_DAT_Reliability, i.Reliability), 1),
        i.EV_DAT_Event_Date,
        ISNULL(i.EV_AUD_EV_ID, inserted.EV_ID),
        ISNULL(i.Metadata_EV_AUD, i.Metadata_EV),
        ISNULL(i.EV_AUD_PositedAt, @now),
        ISNULL(ISNULL(i.EV_AUD_Reliability, i.Reliability), 1),
        i.EV_AUD_Event_Audience,
        ISNULL(i.EV_REV_EV_ID, inserted.EV_ID),
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        ISNULL(i.EV_REV_PositedAt, @now),
        ISNULL(ISNULL(i.EV_REV_Reliability, i.Reliability), 1),
        i.EV_REV_Event_Revenue
    INTO
        @inserted;
    -- the rows that come with the identity of a nexus row
    INSERT INTO @inserted
    SELECT
        i.EV_ID,
        i.Metadata_EV,
        ISNULL(i.EV_DAT_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_DAT, i.Metadata_EV),
        ISNULL(i.EV_DAT_PositedAt, @now),
        ISNULL(ISNULL(i.EV_DAT_Reliability, i.Reliability), 1),
        i.EV_DAT_Event_Date,
        ISNULL(i.EV_AUD_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_AUD, i.Metadata_EV),
        ISNULL(i.EV_AUD_PositedAt, @now),
        ISNULL(ISNULL(i.EV_AUD_Reliability, i.Reliability), 1),
        i.EV_AUD_Event_Audience,
        ISNULL(i.EV_REV_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        ISNULL(i.EV_REV_PositedAt, @now),
        ISNULL(ISNULL(i.EV_REV_Reliability, i.Reliability), 1),
        i.EV_REV_Event_Revenue
    FROM
        inserted i
    WHERE
        i.EV_ID is not null;
    INSERT INTO [dbo].[EV_DAT_Event_Date] (
        Metadata_EV_DAT,
        EV_DAT_EV_ID,
        EV_DAT_Event_Date,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        i.Metadata_EV_DAT,
        i.EV_DAT_EV_ID,
        i.EV_DAT_Event_Date,
        i.EV_DAT_PositedAt,
        i.EV_DAT_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_DAT_Event_Date is not null;
    INSERT INTO [dbo].[EV_AUD_Event_Audience] (
        Metadata_EV_AUD,
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        i.Metadata_EV_AUD,
        i.EV_AUD_EV_ID,
        i.EV_AUD_Event_Audience,
        i.EV_AUD_PositedAt,
        i.EV_AUD_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_AUD_Event_Audience is not null;
    INSERT INTO [dbo].[EV_REV_Event_Revenue] (
        Metadata_EV_REV,
        EV_REV_EV_ID,
        EV_REV_Event_Revenue,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        i.Metadata_EV_REV,
        i.EV_REV_EV_ID,
        i.EV_REV_Event_Revenue,
        i.EV_REV_PositedAt,
        i.EV_REV_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_REV_Event_Revenue is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lEV_Event] ON [dbo].[lEV_Event]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_Metadata_EV bit = CASE WHEN UPDATE(Metadata_EV) THEN 1 ELSE 0 END;
    DECLARE @updated_Reliability bit = CASE WHEN UPDATE(Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_ID))
        RAISERROR('The identity column EV_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_ID_wasHeldAt))
        RAISERROR('The role column ST_ID_wasHeldAt is not updatable.', 16, 1);
    IF(UPDATE(PR_ID_wasPlayed))
        RAISERROR('The role column PR_ID_wasPlayed is not updatable.', 16, 1);
    IF(UPDATE(ETY_ID_of))
        RAISERROR('The role column ETY_ID_of is not updatable.', 16, 1);
    IF(UPDATE(of_ETY_EventType))
        RAISERROR('The role column of_ETY_EventType is not updatable.', 16, 1);
    DECLARE @updated_EV_DAT_Event_Date bit = CASE WHEN UPDATE(EV_DAT_Event_Date) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_EV_DAT bit = CASE WHEN UPDATE(Metadata_EV_DAT) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_DAT_PositedAt bit = CASE WHEN UPDATE(EV_DAT_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_DAT_Reliability bit = CASE WHEN UPDATE(EV_DAT_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_DAT_ID))
        RAISERROR('The identity column EV_DAT_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_DAT_EV_ID))
        RAISERROR('The foreign key column EV_DAT_EV_ID is not updatable.', 16, 1);
    IF (
        @updated_EV_DAT_Event_Date = 1 OR
        @updated_EV_DAT_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[EV_DAT_Event_Date] (
            Metadata_EV_DAT,
            EV_DAT_EV_ID,
            EV_DAT_Event_Date,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_DAT = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_DAT
            END, i.Metadata_EV),
            ISNULL(i.EV_DAT_EV_ID, i.EV_ID),
            i.EV_DAT_Event_Date,
            cast(ISNULL(CASE
                WHEN @updated_EV_DAT_PositedAt = 1 THEN i.EV_DAT_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_DAT_Reliability = 1 THEN i.EV_DAT_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_DAT_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_DAT_Event_Date is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_EV_DAT_PositedAt = 1 OR
            d.EV_DAT_Event_Date is null OR
            d.EV_DAT_Event_Date <> i.EV_DAT_Event_Date OR
            d.EV_DAT_Reliability <> ISNULL(CASE
                WHEN @updated_EV_DAT_Reliability = 1 THEN i.EV_DAT_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_DAT_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_EV_DAT_Event_Date = 1
    )
    BEGIN
        INSERT INTO [dbo].[EV_DAT_Event_Date] (
            Metadata_EV_DAT,
            EV_DAT_EV_ID,
            EV_DAT_Event_Date,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_DAT = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_DAT
            END, i.Metadata_EV),
            p.EV_DAT_EV_ID,
            p.EV_DAT_Event_Date,
            cast(ISNULL(CASE
                WHEN @updated_EV_DAT_PositedAt = 1 THEN i.EV_DAT_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[EV_DAT_Event_Date_Posit] p
        ON
            p.EV_DAT_ID = i.EV_DAT_ID
        WHERE
            i.EV_DAT_Event_Date is null
    END
    DECLARE @updated_EV_AUD_Event_Audience bit = CASE WHEN UPDATE(EV_AUD_Event_Audience) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_EV_AUD bit = CASE WHEN UPDATE(Metadata_EV_AUD) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_AUD_PositedAt bit = CASE WHEN UPDATE(EV_AUD_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_AUD_Reliability bit = CASE WHEN UPDATE(EV_AUD_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_AUD_ID))
        RAISERROR('The identity column EV_AUD_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_AUD_EV_ID))
        RAISERROR('The foreign key column EV_AUD_EV_ID is not updatable.', 16, 1);
    IF (
        @updated_EV_AUD_Event_Audience = 1 OR
        @updated_EV_AUD_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[EV_AUD_Event_Audience] (
            Metadata_EV_AUD,
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_AUD = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_AUD
            END, i.Metadata_EV),
            ISNULL(i.EV_AUD_EV_ID, i.EV_ID),
            i.EV_AUD_Event_Audience,
            cast(ISNULL(CASE
                WHEN @updated_EV_AUD_PositedAt = 1 THEN i.EV_AUD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_AUD_Reliability = 1 THEN i.EV_AUD_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_AUD_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_AUD_Event_Audience is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_EV_AUD_PositedAt = 1 OR
            d.EV_AUD_Event_Audience is null OR
            d.EV_AUD_Event_Audience <> i.EV_AUD_Event_Audience OR
            d.EV_AUD_Reliability <> ISNULL(CASE
                WHEN @updated_EV_AUD_Reliability = 1 THEN i.EV_AUD_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_AUD_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_EV_AUD_Event_Audience = 1
    )
    BEGIN
        INSERT INTO [dbo].[EV_AUD_Event_Audience] (
            Metadata_EV_AUD,
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_AUD = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_AUD
            END, i.Metadata_EV),
            p.EV_AUD_EV_ID,
            p.EV_AUD_Event_Audience,
            cast(ISNULL(CASE
                WHEN @updated_EV_AUD_PositedAt = 1 THEN i.EV_AUD_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[EV_AUD_Event_Audience_Posit] p
        ON
            p.EV_AUD_ID = i.EV_AUD_ID
        WHERE
            i.EV_AUD_Event_Audience is null
    END
    DECLARE @updated_EV_REV_Event_Revenue bit = CASE WHEN UPDATE(EV_REV_Event_Revenue) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_EV_REV bit = CASE WHEN UPDATE(Metadata_EV_REV) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_REV_PositedAt bit = CASE WHEN UPDATE(EV_REV_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_REV_Reliability bit = CASE WHEN UPDATE(EV_REV_Reliability) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_REV_ID))
        RAISERROR('The identity column EV_REV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_REV_EV_ID))
        RAISERROR('The foreign key column EV_REV_EV_ID is not updatable.', 16, 1);
    IF (
        @updated_EV_REV_Event_Revenue = 1 OR
        @updated_EV_REV_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [dbo].[EV_REV_Event_Revenue] (
            Metadata_EV_REV,
            EV_REV_EV_ID,
            EV_REV_Event_Revenue,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_REV = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_REV
            END, i.Metadata_EV),
            ISNULL(i.EV_REV_EV_ID, i.EV_ID),
            i.EV_REV_Event_Revenue,
            cast(ISNULL(CASE
                WHEN @updated_EV_REV_PositedAt = 1 THEN i.EV_REV_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_REV_Reliability = 1 THEN i.EV_REV_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_REV_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_REV_Event_Revenue is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_EV_REV_PositedAt = 1 OR
            d.EV_REV_Event_Revenue is null OR
            d.EV_REV_Event_Revenue <> i.EV_REV_Event_Revenue OR
            d.EV_REV_Reliability <> ISNULL(CASE
                WHEN @updated_EV_REV_Reliability = 1 THEN i.EV_REV_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_REV_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_EV_REV_Event_Revenue = 1
    )
    BEGIN
        INSERT INTO [dbo].[EV_REV_Event_Revenue] (
            Metadata_EV_REV,
            EV_REV_EV_ID,
            EV_REV_Event_Revenue,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_REV = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_REV
            END, i.Metadata_EV),
            p.EV_REV_EV_ID,
            p.EV_REV_Event_Revenue,
            cast(ISNULL(CASE
                WHEN @updated_EV_REV_PositedAt = 1 THEN i.EV_REV_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[EV_REV_Event_Revenue_Posit] p
        ON
            p.EV_REV_ID = i.EV_REV_ID
        WHERE
            i.EV_REV_Event_Revenue is null
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lEV_Event] ON [dbo].[lEV_Event]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[EV_DAT_Event_Date_Annex] (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        d.Metadata_EV_DAT,
        d.EV_DAT_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_DAT_ID is not null;
    INSERT INTO [dbo].[EV_AUD_Event_Audience_Annex] (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        d.Metadata_EV_AUD,
        d.EV_AUD_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_AUD_ID is not null;
    INSERT INTO [dbo].[EV_REV_Event_Revenue_Annex] (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        d.Metadata_EV_REV,
        d.EV_REV_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_REV_ID is not null;
END
GO
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_partner_AC_with_ONG_currently_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_partner_AC_with_ONG_currently_Posit] (
    AC_partner_AC_with_ONG_currently_ID int IDENTITY(1,1) not null,
    AC_ID_partner int not null,
    AC_ID_with int not null,
    ONG_ID_currently tinyint not null,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime2 not null,
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_partner foreign key (
        AC_ID_partner
    ) references [dbo].[AC_Actor](AC_ID),
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_with foreign key (
        AC_ID_with
    ) references [dbo].[AC_Actor](AC_ID),
    constraint AC_partner_AC_with_ONG_currently_Posit_fkONG_currently foreign key (
        ONG_ID_currently
    ) references [dbo].[ONG_Ongoing](ONG_ID),
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint pkAC_partner_AC_with_ONG_currently_Posit primary key nonclustered (
        AC_partner_AC_with_ONG_currently_ID asc
    ),
    constraint uqAC_partner_AC_with_ONG_currently unique clustered (
        AC_partner_AC_with_ONG_currently_ChangedAt desc,
        AC_ID_partner asc,
        AC_ID_with asc,
        ONG_ID_currently asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_partner_AC_with_ONG_currently_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_partner_AC_with_ONG_currently_Annex] (
    AC_partner_AC_with_ONG_currently_ID int not null,
    AC_partner_AC_with_ONG_currently_PositedAt datetime2 not null,
    AC_partner_AC_with_ONG_currently_Reliability bit not null,
    Metadata_AC_partner_AC_with_ONG_currently int not null,
    constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
        AC_partner_AC_with_ONG_currently_ID
    ) references [dbo].[AC_partner_AC_with_ONG_currently_Posit](AC_partner_AC_with_ONG_currently_ID),
    constraint pkAC_partner_AC_with_ONG_currently_Annex primary key clustered (
        AC_partner_AC_with_ONG_currently_ID asc,
        AC_partner_AC_with_ONG_currently_PositedAt desc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_subset_PN_of_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_subset_PN_of_Posit] (
    AC_subset_PN_of_ID int IDENTITY(1,1) not null,
    AC_ID_subset int not null,
    PN_ID_of int not null,
    constraint AC_subset_PN_of_Posit_fkAC_subset foreign key (
        AC_ID_subset
    ) references [dbo].[AC_Actor](AC_ID),
    constraint AC_subset_PN_of_Posit_fkPN_of foreign key (
        PN_ID_of
    ) references [dbo].[PN_Person](PN_ID),
    constraint AC_subset_PN_of_Posit_uqAC_subset unique (
        AC_ID_subset
    ),
    constraint AC_subset_PN_of_Posit_uqPN_of unique (
        PN_ID_of
    ),
    constraint pkAC_subset_PN_of_Posit primary key nonclustered (
        AC_subset_PN_of_ID asc
    ),
    constraint uqAC_subset_PN_of unique clustered (
        AC_ID_subset asc,
        PN_ID_of asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_subset_PN_of_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_subset_PN_of_Annex] (
    AC_subset_PN_of_ID int not null,
    AC_subset_PN_of_PositedAt datetime2 not null,
    AC_subset_PN_of_Reliability bit not null,
    Metadata_AC_subset_PN_of int not null,
    constraint fkAC_subset_PN_of_Annex foreign key (
        AC_subset_PN_of_ID
    ) references [dbo].[AC_subset_PN_of_Posit](AC_subset_PN_of_ID),
    constraint pkAC_subset_PN_of_Annex primary key clustered (
        AC_subset_PN_of_ID asc,
        AC_subset_PN_of_PositedAt desc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_in_AC_wasCast_Posit', 'U') IS NULL
CREATE TABLE [dbo].[EV_in_AC_wasCast_Posit] (
    EV_in_AC_wasCast_ID int IDENTITY(1,1) not null,
    EV_ID_in int not null,
    AC_ID_wasCast int not null,
    constraint EV_in_AC_wasCast_Posit_fkEV_in foreign key (
        EV_ID_in
    ) references [dbo].[EV_Event](EV_ID),
    constraint EV_in_AC_wasCast_Posit_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references [dbo].[AC_Actor](AC_ID),
    constraint pkEV_in_AC_wasCast_Posit primary key nonclustered (
        EV_in_AC_wasCast_ID asc
    ),
    constraint uqEV_in_AC_wasCast unique clustered (
        EV_ID_in asc,
        AC_ID_wasCast asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_in_AC_wasCast_Annex', 'U') IS NULL
CREATE TABLE [dbo].[EV_in_AC_wasCast_Annex] (
    EV_in_AC_wasCast_ID int not null,
    EV_in_AC_wasCast_PositedAt datetime2 not null,
    EV_in_AC_wasCast_Reliability bit not null,
    Metadata_EV_in_AC_wasCast int not null,
    constraint fkEV_in_AC_wasCast_Annex foreign key (
        EV_in_AC_wasCast_ID
    ) references [dbo].[EV_in_AC_wasCast_Posit](EV_in_AC_wasCast_ID),
    constraint pkEV_in_AC_wasCast_Annex primary key clustered (
        EV_in_AC_wasCast_ID asc,
        EV_in_AC_wasCast_PositedAt desc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_part_PR_in_RAT_got_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_part_PR_in_RAT_got_Posit] (
    AC_part_PR_in_RAT_got_ID int IDENTITY(1,1) not null,
    AC_ID_part int not null,
    PR_ID_in int not null,
    RAT_ID_got tinyint not null,
    AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
    constraint AC_part_PR_in_RAT_got_Posit_fkAC_part foreign key (
        AC_ID_part
    ) references [dbo].[AC_Actor](AC_ID),
    constraint AC_part_PR_in_RAT_got_Posit_fkPR_in foreign key (
        PR_ID_in
    ) references [dbo].[PR_Program](PR_ID),
    constraint AC_part_PR_in_RAT_got_Posit_fkRAT_got foreign key (
        RAT_ID_got
    ) references [dbo].[RAT_Rating](RAT_ID),
    constraint pkAC_part_PR_in_RAT_got_Posit primary key nonclustered (
        AC_part_PR_in_RAT_got_ID asc
    ),
    constraint uqAC_part_PR_in_RAT_got unique clustered (
        AC_ID_part asc,
        PR_ID_in asc,
        AC_part_PR_in_RAT_got_ChangedAt desc,
        RAT_ID_got asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_part_PR_in_RAT_got_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_part_PR_in_RAT_got_Annex] (
    AC_part_PR_in_RAT_got_ID int not null,
    AC_part_PR_in_RAT_got_PositedAt datetime2 not null,
    AC_part_PR_in_RAT_got_Reliability bit not null,
    Metadata_AC_part_PR_in_RAT_got int not null,
    constraint fkAC_part_PR_in_RAT_got_Annex foreign key (
        AC_part_PR_in_RAT_got_ID
    ) references [dbo].[AC_part_PR_in_RAT_got_Posit](AC_part_PR_in_RAT_got_ID),
    constraint pkAC_part_PR_in_RAT_got_Annex primary key clustered (
        AC_part_PR_in_RAT_got_ID asc,
        AC_part_PR_in_RAT_got_PositedAt desc
    )
);
GO
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_at_PR_isPlaying_Posit', 'U') IS NULL
CREATE TABLE [dbo].[ST_at_PR_isPlaying_Posit] (
    ST_at_PR_isPlaying_ID int IDENTITY(1,1) not null,
    ST_ID_at int not null,
    PR_ID_isPlaying int not null,
    ST_at_PR_isPlaying_ChangedAt datetime2 not null,
    constraint ST_at_PR_isPlaying_Posit_fkST_at foreign key (
        ST_ID_at
    ) references [dbo].[ST_Stage](ST_ID),
    constraint ST_at_PR_isPlaying_Posit_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references [dbo].[PR_Program](PR_ID),
    constraint pkST_at_PR_isPlaying_Posit primary key nonclustered (
        ST_at_PR_isPlaying_ID asc
    ),
    constraint uqST_at_PR_isPlaying unique clustered (
        ST_ID_at asc,
        PR_ID_isPlaying asc,
        ST_at_PR_isPlaying_ChangedAt desc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_at_PR_isPlaying_Annex', 'U') IS NULL
CREATE TABLE [dbo].[ST_at_PR_isPlaying_Annex] (
    ST_at_PR_isPlaying_ID int not null,
    ST_at_PR_isPlaying_PositedAt datetime2 not null,
    ST_at_PR_isPlaying_Reliability bit not null,
    Metadata_ST_at_PR_isPlaying int not null,
    constraint fkST_at_PR_isPlaying_Annex foreign key (
        ST_at_PR_isPlaying_ID
    ) references [dbo].[ST_at_PR_isPlaying_Posit](ST_at_PR_isPlaying_ID),
    constraint pkST_at_PR_isPlaying_Annex primary key clustered (
        ST_at_PR_isPlaying_ID asc,
        ST_at_PR_isPlaying_PositedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_parent_AC_child_PAT_having_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_parent_AC_child_PAT_having_Posit] (
    AC_parent_AC_child_PAT_having_ID int IDENTITY(1,1) not null,
    AC_ID_parent int not null,
    AC_ID_child int not null,
    PAT_ID_having tinyint not null,
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_parent foreign key (
        AC_ID_parent
    ) references [dbo].[AC_Actor](AC_ID),
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_child foreign key (
        AC_ID_child
    ) references [dbo].[AC_Actor](AC_ID),
    constraint AC_parent_AC_child_PAT_having_Posit_fkPAT_having foreign key (
        PAT_ID_having
    ) references [dbo].[PAT_ParentalType](PAT_ID),
    constraint pkAC_parent_AC_child_PAT_having_Posit primary key nonclustered (
        AC_parent_AC_child_PAT_having_ID asc
    ),
    constraint uqAC_parent_AC_child_PAT_having unique clustered (
        AC_ID_parent asc,
        AC_ID_child asc,
        PAT_ID_having asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_parent_AC_child_PAT_having_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_parent_AC_child_PAT_having_Annex] (
    AC_parent_AC_child_PAT_having_ID int not null,
    AC_parent_AC_child_PAT_having_PositedAt datetime2 not null,
    AC_parent_AC_child_PAT_having_Reliability bit not null,
    Metadata_AC_parent_AC_child_PAT_having int not null,
    constraint fkAC_parent_AC_child_PAT_having_Annex foreign key (
        AC_parent_AC_child_PAT_having_ID
    ) references [dbo].[AC_parent_AC_child_PAT_having_Posit](AC_parent_AC_child_PAT_having_ID),
    constraint pkAC_parent_AC_child_PAT_having_Annex primary key clustered (
        AC_parent_AC_child_PAT_having_ID asc,
        AC_parent_AC_child_PAT_having_PositedAt desc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_content_ST_location_EV_of_Posit', 'U') IS NULL
CREATE TABLE [dbo].[PR_content_ST_location_EV_of_Posit] (
    PR_content_ST_location_EV_of_ID int IDENTITY(1,1) not null,
    PR_ID_content int not null,
    ST_ID_location int not null,
    EV_ID_of int not null,
    constraint PR_content_ST_location_EV_of_Posit_fkPR_content foreign key (
        PR_ID_content
    ) references [dbo].[PR_Program](PR_ID),
    constraint PR_content_ST_location_EV_of_Posit_fkST_location foreign key (
        ST_ID_location
    ) references [dbo].[ST_Stage](ST_ID),
    constraint PR_content_ST_location_EV_of_Posit_fkEV_of foreign key (
        EV_ID_of
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkPR_content_ST_location_EV_of_Posit primary key nonclustered (
        PR_content_ST_location_EV_of_ID asc
    ),
    constraint uqPR_content_ST_location_EV_of unique clustered (
        EV_ID_of asc,
        PR_ID_content asc,
        ST_ID_location asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_content_ST_location_EV_of_Annex', 'U') IS NULL
CREATE TABLE [dbo].[PR_content_ST_location_EV_of_Annex] (
    PR_content_ST_location_EV_of_ID int not null,
    PR_content_ST_location_EV_of_PositedAt datetime2 not null,
    PR_content_ST_location_EV_of_Reliability bit not null,
    Metadata_PR_content_ST_location_EV_of int not null,
    constraint fkPR_content_ST_location_EV_of_Annex foreign key (
        PR_content_ST_location_EV_of_ID
    ) references [dbo].[PR_content_ST_location_EV_of_Posit](PR_content_ST_location_EV_of_ID),
    constraint pkPR_content_ST_location_EV_of_Annex primary key clustered (
        PR_content_ST_location_EV_of_ID asc,
        PR_content_ST_location_EV_of_PositedAt desc
    )
);
GO
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines the posit and annex table of the tie.
-- It can be used to maintain entity integrity through a primary key, which cannot be
-- defined elsewhere.
--
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently assembled view of the posit and annex tables,
-- pkAC_partner_AC_with_ONG_currently optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_partner_AC_with_ONG_currently', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[AC_partner_AC_with_ONG_currently]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_partner_AC_with_ONG_currently,
        p.AC_partner_AC_with_ONG_currently_ID,
        p.AC_ID_partner,
        p.AC_ID_with,
        p.ONG_ID_currently,
        p.AC_partner_AC_with_ONG_currently_ChangedAt,
        a.AC_partner_AC_with_ONG_currently_PositedAt,
        a.AC_partner_AC_with_ONG_currently_Reliability
    FROM
        [dbo].[AC_partner_AC_with_ONG_currently_Posit] p
    JOIN
        [dbo].[AC_partner_AC_with_ONG_currently_Annex] a
    ON
        a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_partner_AC_with_ONG_currently]
    ON [dbo].[AC_partner_AC_with_ONG_currently] (
        AC_ID_partner asc,
        AC_ID_with asc,
        ONG_ID_currently asc,
        AC_partner_AC_with_ONG_currently_ChangedAt desc,
        AC_partner_AC_with_ONG_currently_PositedAt desc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- AC_subset_PN_of assembled view of the posit and annex tables,
-- pkAC_subset_PN_of optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_subset_PN_of', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[AC_subset_PN_of]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_subset_PN_of,
        p.AC_subset_PN_of_ID,
        p.AC_ID_subset,
        p.PN_ID_of,
        a.AC_subset_PN_of_PositedAt,
        a.AC_subset_PN_of_Reliability
    FROM
        [dbo].[AC_subset_PN_of_Posit] p
    JOIN
        [dbo].[AC_subset_PN_of_Annex] a
    ON
        a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_subset_PN_of]
    ON [dbo].[AC_subset_PN_of] (
        AC_ID_subset asc,
        PN_ID_of asc,
        AC_subset_PN_of_PositedAt desc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast assembled view of the posit and annex tables,
-- pkEV_in_AC_wasCast optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_in_AC_wasCast', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_in_AC_wasCast]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_in_AC_wasCast,
        p.EV_in_AC_wasCast_ID,
        p.EV_ID_in,
        p.AC_ID_wasCast,
        a.EV_in_AC_wasCast_PositedAt,
        a.EV_in_AC_wasCast_Reliability
    FROM
        [dbo].[EV_in_AC_wasCast_Posit] p
    JOIN
        [dbo].[EV_in_AC_wasCast_Annex] a
    ON
        a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_in_AC_wasCast]
    ON [dbo].[EV_in_AC_wasCast] (
        EV_ID_in asc,
        AC_ID_wasCast asc,
        EV_in_AC_wasCast_PositedAt desc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got assembled view of the posit and annex tables,
-- pkAC_part_PR_in_RAT_got optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_part_PR_in_RAT_got', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[AC_part_PR_in_RAT_got]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_part_PR_in_RAT_got,
        p.AC_part_PR_in_RAT_got_ID,
        p.AC_ID_part,
        p.PR_ID_in,
        p.RAT_ID_got,
        p.AC_part_PR_in_RAT_got_ChangedAt,
        a.AC_part_PR_in_RAT_got_PositedAt,
        a.AC_part_PR_in_RAT_got_Reliability
    FROM
        [dbo].[AC_part_PR_in_RAT_got_Posit] p
    JOIN
        [dbo].[AC_part_PR_in_RAT_got_Annex] a
    ON
        a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_part_PR_in_RAT_got]
    ON [dbo].[AC_part_PR_in_RAT_got] (
        AC_ID_part asc,
        PR_ID_in asc,
        AC_part_PR_in_RAT_got_ChangedAt desc,
        AC_part_PR_in_RAT_got_PositedAt desc,
        AC_part_PR_in_RAT_got_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.AC_part_PR_in_RAT_got', 'V')
    AND
        x.name = 'pkAC_part_PR_in_RAT_got'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'AC_part_PR_in_RAT_got_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_part_PR_in_RAT_got]
    ON [dbo].[AC_part_PR_in_RAT_got] (
        AC_ID_part asc,
        PR_ID_in asc,
        AC_part_PR_in_RAT_got_ChangedAt desc,
        AC_part_PR_in_RAT_got_PositedAt desc,
        AC_part_PR_in_RAT_got_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying assembled view of the posit and annex tables,
-- pkST_at_PR_isPlaying optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_at_PR_isPlaying', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[ST_at_PR_isPlaying]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_ST_at_PR_isPlaying,
        p.ST_at_PR_isPlaying_ID,
        p.ST_ID_at,
        p.PR_ID_isPlaying,
        p.ST_at_PR_isPlaying_ChangedAt,
        a.ST_at_PR_isPlaying_PositedAt,
        a.ST_at_PR_isPlaying_Reliability
    FROM
        [dbo].[ST_at_PR_isPlaying_Posit] p
    JOIN
        [dbo].[ST_at_PR_isPlaying_Annex] a
    ON
        a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_at_PR_isPlaying]
    ON [dbo].[ST_at_PR_isPlaying] (
        ST_ID_at asc,
        PR_ID_isPlaying asc,
        ST_at_PR_isPlaying_ChangedAt desc,
        ST_at_PR_isPlaying_PositedAt desc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having assembled view of the posit and annex tables,
-- pkAC_parent_AC_child_PAT_having optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_parent_AC_child_PAT_having', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[AC_parent_AC_child_PAT_having]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_parent_AC_child_PAT_having,
        p.AC_parent_AC_child_PAT_having_ID,
        p.AC_ID_parent,
        p.AC_ID_child,
        p.PAT_ID_having,
        a.AC_parent_AC_child_PAT_having_PositedAt,
        a.AC_parent_AC_child_PAT_having_Reliability
    FROM
        [dbo].[AC_parent_AC_child_PAT_having_Posit] p
    JOIN
        [dbo].[AC_parent_AC_child_PAT_having_Annex] a
    ON
        a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_parent_AC_child_PAT_having]
    ON [dbo].[AC_parent_AC_child_PAT_having] (
        AC_ID_parent asc,
        AC_ID_child asc,
        PAT_ID_having asc,
        AC_parent_AC_child_PAT_having_PositedAt desc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of assembled view of the posit and annex tables,
-- pkPR_content_ST_location_EV_of optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_content_ST_location_EV_of', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[PR_content_ST_location_EV_of]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ID,
        p.PR_ID_content,
        p.ST_ID_location,
        p.EV_ID_of,
        a.PR_content_ST_location_EV_of_PositedAt,
        a.PR_content_ST_location_EV_of_Reliability
    FROM
        [dbo].[PR_content_ST_location_EV_of_Posit] p
    JOIN
        [dbo].[PR_content_ST_location_EV_of_Annex] a
    ON
        a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_content_ST_location_EV_of]
    ON [dbo].[PR_content_ST_location_EV_of] (
        EV_ID_of asc,
        PR_content_ST_location_EV_of_PositedAt desc,
        PR_content_ST_location_EV_of_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('dbo.PR_content_ST_location_EV_of', 'V')
    AND
        x.name = 'pkPR_content_ST_location_EV_of'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'PR_content_ST_location_EV_of_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_content_ST_location_EV_of]
    ON [dbo].[PR_content_ST_location_EV_of] (
        EV_ID_of asc,
        PR_content_ST_location_EV_of_PositedAt desc,
        PR_content_ST_location_EV_of_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- These table valued functions rewind a tie posit table to the given
-- point in changing time, or a tie annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that
-- their union corresponds to all rows in the posit table.
--
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rAC_partner_AC_with_ONG_currently_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_partner_AC_with_ONG_currently_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_partner_AC_with_ONG_currently_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_partner_AC_with_ONG_currently_ID,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt
    FROM
        [dbo].[AC_partner_AC_with_ONG_currently_Posit]
    WHERE
        AC_partner_AC_with_ONG_currently_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fAC_partner_AC_with_ONG_currently_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_partner_AC_with_ONG_currently_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_partner_AC_with_ONG_currently_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_partner_AC_with_ONG_currently_ID,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt
    FROM
        [dbo].[AC_partner_AC_with_ONG_currently_Posit]
    WHERE
        AC_partner_AC_with_ONG_currently_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_partner_AC_with_ONG_currently_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_partner_AC_with_ONG_currently_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_partner_AC_with_ONG_currently_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    FROM
        [dbo].[AC_partner_AC_with_ONG_currently_Annex]
    WHERE
        AC_partner_AC_with_ONG_currently_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_partner_AC_with_ONG_currently rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_partner_AC_with_ONG_currently','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_partner_AC_with_ONG_currently] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_partner_AC_with_ONG_currently,
        p.AC_partner_AC_with_ONG_currently_ID,
        p.AC_ID_partner,
        p.AC_ID_with,
        p.ONG_ID_currently,
        p.AC_partner_AC_with_ONG_currently_ChangedAt,
        a.AC_partner_AC_with_ONG_currently_PositedAt,
        a.AC_partner_AC_with_ONG_currently_Reliability
    FROM
        [dbo].[rAC_partner_AC_with_ONG_currently_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_partner_AC_with_ONG_currently_Annex](@positingTimepoint) a
    ON
        a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
    AND
        a.AC_partner_AC_with_ONG_currently_PositedAt = (
            SELECT TOP 1
                sub.AC_partner_AC_with_ONG_currently_PositedAt
            FROM
                [dbo].[rAC_partner_AC_with_ONG_currently_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            ORDER BY
                sub.AC_partner_AC_with_ONG_currently_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_partner_AC_with_ONG_currently forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_partner_AC_with_ONG_currently','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_partner_AC_with_ONG_currently] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_partner_AC_with_ONG_currently,
        p.AC_partner_AC_with_ONG_currently_ID,
        p.AC_ID_partner,
        p.AC_ID_with,
        p.ONG_ID_currently,
        p.AC_partner_AC_with_ONG_currently_ChangedAt,
        a.AC_partner_AC_with_ONG_currently_PositedAt,
        a.AC_partner_AC_with_ONG_currently_Reliability
    FROM
        [dbo].[fAC_partner_AC_with_ONG_currently_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_partner_AC_with_ONG_currently_Annex](@positingTimepoint) a
    ON
        a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
    AND
        a.AC_partner_AC_with_ONG_currently_PositedAt = (
            SELECT TOP 1
                sub.AC_partner_AC_with_ONG_currently_PositedAt
            FROM
                [dbo].[rAC_partner_AC_with_ONG_currently_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            ORDER BY
                sub.AC_partner_AC_with_ONG_currently_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_subset_PN_of_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_subset_PN_of_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_subset_PN_of_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    FROM
        [dbo].[AC_subset_PN_of_Annex]
    WHERE
        AC_subset_PN_of_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_subset_PN_of rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_subset_PN_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_subset_PN_of] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_subset_PN_of,
        p.AC_subset_PN_of_ID,
        p.AC_ID_subset,
        p.PN_ID_of,
        a.AC_subset_PN_of_PositedAt,
        a.AC_subset_PN_of_Reliability
    FROM
        [dbo].[AC_subset_PN_of_Posit] p
    JOIN
        [dbo].[rAC_subset_PN_of_Annex](@positingTimepoint) a
    ON
        a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
    AND
        a.AC_subset_PN_of_PositedAt = (
            SELECT TOP 1
                sub.AC_subset_PN_of_PositedAt
            FROM
                [dbo].[rAC_subset_PN_of_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            ORDER BY
                sub.AC_subset_PN_of_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_subset_PN_of forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_subset_PN_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_subset_PN_of] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_subset_PN_of,
        p.AC_subset_PN_of_ID,
        p.AC_ID_subset,
        p.PN_ID_of,
        a.AC_subset_PN_of_PositedAt,
        a.AC_subset_PN_of_Reliability
    FROM
        [dbo].[AC_subset_PN_of_Posit] p
    JOIN
        [dbo].[rAC_subset_PN_of_Annex](@positingTimepoint) a
    ON
        a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
    AND
        a.AC_subset_PN_of_PositedAt = (
            SELECT TOP 1
                sub.AC_subset_PN_of_PositedAt
            FROM
                [dbo].[rAC_subset_PN_of_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            ORDER BY
                sub.AC_subset_PN_of_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rEV_in_AC_wasCast_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_in_AC_wasCast_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_in_AC_wasCast_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    FROM
        [dbo].[EV_in_AC_wasCast_Annex]
    WHERE
        EV_in_AC_wasCast_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rEV_in_AC_wasCast rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_in_AC_wasCast','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_in_AC_wasCast] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_in_AC_wasCast,
        p.EV_in_AC_wasCast_ID,
        p.EV_ID_in,
        p.AC_ID_wasCast,
        a.EV_in_AC_wasCast_PositedAt,
        a.EV_in_AC_wasCast_Reliability
    FROM
        [dbo].[EV_in_AC_wasCast_Posit] p
    JOIN
        [dbo].[rEV_in_AC_wasCast_Annex](@positingTimepoint) a
    ON
        a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
    AND
        a.EV_in_AC_wasCast_PositedAt = (
            SELECT TOP 1
                sub.EV_in_AC_wasCast_PositedAt
            FROM
                [dbo].[rEV_in_AC_wasCast_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            ORDER BY
                sub.EV_in_AC_wasCast_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fEV_in_AC_wasCast forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fEV_in_AC_wasCast','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fEV_in_AC_wasCast] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_in_AC_wasCast,
        p.EV_in_AC_wasCast_ID,
        p.EV_ID_in,
        p.AC_ID_wasCast,
        a.EV_in_AC_wasCast_PositedAt,
        a.EV_in_AC_wasCast_Reliability
    FROM
        [dbo].[EV_in_AC_wasCast_Posit] p
    JOIN
        [dbo].[rEV_in_AC_wasCast_Annex](@positingTimepoint) a
    ON
        a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
    AND
        a.EV_in_AC_wasCast_PositedAt = (
            SELECT TOP 1
                sub.EV_in_AC_wasCast_PositedAt
            FROM
                [dbo].[rEV_in_AC_wasCast_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            ORDER BY
                sub.EV_in_AC_wasCast_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rAC_part_PR_in_RAT_got_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_part_PR_in_RAT_got_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_part_PR_in_RAT_got_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_part_PR_in_RAT_got_ID,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_ChangedAt
    FROM
        [dbo].[AC_part_PR_in_RAT_got_Posit]
    WHERE
        AC_part_PR_in_RAT_got_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fAC_part_PR_in_RAT_got_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_part_PR_in_RAT_got_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_part_PR_in_RAT_got_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_part_PR_in_RAT_got_ID,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_ChangedAt
    FROM
        [dbo].[AC_part_PR_in_RAT_got_Posit]
    WHERE
        AC_part_PR_in_RAT_got_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_part_PR_in_RAT_got_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_part_PR_in_RAT_got_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_part_PR_in_RAT_got_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    FROM
        [dbo].[AC_part_PR_in_RAT_got_Annex]
    WHERE
        AC_part_PR_in_RAT_got_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_part_PR_in_RAT_got rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_part_PR_in_RAT_got','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_part_PR_in_RAT_got] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_part_PR_in_RAT_got,
        p.AC_part_PR_in_RAT_got_ID,
        p.AC_ID_part,
        p.PR_ID_in,
        p.RAT_ID_got,
        p.AC_part_PR_in_RAT_got_ChangedAt,
        a.AC_part_PR_in_RAT_got_PositedAt,
        a.AC_part_PR_in_RAT_got_Reliability
    FROM
        [dbo].[rAC_part_PR_in_RAT_got_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_part_PR_in_RAT_got_Annex](@positingTimepoint) a
    ON
        a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    AND
        a.AC_part_PR_in_RAT_got_PositedAt = (
            SELECT TOP 1
                sub.AC_part_PR_in_RAT_got_PositedAt
            FROM
                [dbo].[rAC_part_PR_in_RAT_got_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            ORDER BY
                sub.AC_part_PR_in_RAT_got_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_part_PR_in_RAT_got forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_part_PR_in_RAT_got','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_part_PR_in_RAT_got] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_part_PR_in_RAT_got,
        p.AC_part_PR_in_RAT_got_ID,
        p.AC_ID_part,
        p.PR_ID_in,
        p.RAT_ID_got,
        p.AC_part_PR_in_RAT_got_ChangedAt,
        a.AC_part_PR_in_RAT_got_PositedAt,
        a.AC_part_PR_in_RAT_got_Reliability
    FROM
        [dbo].[fAC_part_PR_in_RAT_got_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_part_PR_in_RAT_got_Annex](@positingTimepoint) a
    ON
        a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    AND
        a.AC_part_PR_in_RAT_got_PositedAt = (
            SELECT TOP 1
                sub.AC_part_PR_in_RAT_got_PositedAt
            FROM
                [dbo].[rAC_part_PR_in_RAT_got_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            ORDER BY
                sub.AC_part_PR_in_RAT_got_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rST_at_PR_isPlaying_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_at_PR_isPlaying_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_at_PR_isPlaying_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_at_PR_isPlaying_ID,
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    FROM
        [dbo].[ST_at_PR_isPlaying_Posit]
    WHERE
        ST_at_PR_isPlaying_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fST_at_PR_isPlaying_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_at_PR_isPlaying_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_at_PR_isPlaying_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_at_PR_isPlaying_ID,
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    FROM
        [dbo].[ST_at_PR_isPlaying_Posit]
    WHERE
        ST_at_PR_isPlaying_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rST_at_PR_isPlaying_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_at_PR_isPlaying_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_at_PR_isPlaying_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    FROM
        [dbo].[ST_at_PR_isPlaying_Annex]
    WHERE
        ST_at_PR_isPlaying_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rST_at_PR_isPlaying rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_at_PR_isPlaying','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_at_PR_isPlaying] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_at_PR_isPlaying,
        p.ST_at_PR_isPlaying_ID,
        p.ST_ID_at,
        p.PR_ID_isPlaying,
        p.ST_at_PR_isPlaying_ChangedAt,
        a.ST_at_PR_isPlaying_PositedAt,
        a.ST_at_PR_isPlaying_Reliability
    FROM
        [dbo].[rST_at_PR_isPlaying_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rST_at_PR_isPlaying_Annex](@positingTimepoint) a
    ON
        a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
    AND
        a.ST_at_PR_isPlaying_PositedAt = (
            SELECT TOP 1
                sub.ST_at_PR_isPlaying_PositedAt
            FROM
                [dbo].[rST_at_PR_isPlaying_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            ORDER BY
                sub.ST_at_PR_isPlaying_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fST_at_PR_isPlaying forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_at_PR_isPlaying','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_at_PR_isPlaying] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_at_PR_isPlaying,
        p.ST_at_PR_isPlaying_ID,
        p.ST_ID_at,
        p.PR_ID_isPlaying,
        p.ST_at_PR_isPlaying_ChangedAt,
        a.ST_at_PR_isPlaying_PositedAt,
        a.ST_at_PR_isPlaying_Reliability
    FROM
        [dbo].[fST_at_PR_isPlaying_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rST_at_PR_isPlaying_Annex](@positingTimepoint) a
    ON
        a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
    AND
        a.ST_at_PR_isPlaying_PositedAt = (
            SELECT TOP 1
                sub.ST_at_PR_isPlaying_PositedAt
            FROM
                [dbo].[rST_at_PR_isPlaying_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            ORDER BY
                sub.ST_at_PR_isPlaying_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_parent_AC_child_PAT_having_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_parent_AC_child_PAT_having_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_parent_AC_child_PAT_having_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    FROM
        [dbo].[AC_parent_AC_child_PAT_having_Annex]
    WHERE
        AC_parent_AC_child_PAT_having_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_parent_AC_child_PAT_having rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_parent_AC_child_PAT_having','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_parent_AC_child_PAT_having] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_parent_AC_child_PAT_having,
        p.AC_parent_AC_child_PAT_having_ID,
        p.AC_ID_parent,
        p.AC_ID_child,
        p.PAT_ID_having,
        a.AC_parent_AC_child_PAT_having_PositedAt,
        a.AC_parent_AC_child_PAT_having_Reliability
    FROM
        [dbo].[AC_parent_AC_child_PAT_having_Posit] p
    JOIN
        [dbo].[rAC_parent_AC_child_PAT_having_Annex](@positingTimepoint) a
    ON
        a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
    AND
        a.AC_parent_AC_child_PAT_having_PositedAt = (
            SELECT TOP 1
                sub.AC_parent_AC_child_PAT_having_PositedAt
            FROM
                [dbo].[rAC_parent_AC_child_PAT_having_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            ORDER BY
                sub.AC_parent_AC_child_PAT_having_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_parent_AC_child_PAT_having forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_parent_AC_child_PAT_having','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_parent_AC_child_PAT_having] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_parent_AC_child_PAT_having,
        p.AC_parent_AC_child_PAT_having_ID,
        p.AC_ID_parent,
        p.AC_ID_child,
        p.PAT_ID_having,
        a.AC_parent_AC_child_PAT_having_PositedAt,
        a.AC_parent_AC_child_PAT_having_Reliability
    FROM
        [dbo].[AC_parent_AC_child_PAT_having_Posit] p
    JOIN
        [dbo].[rAC_parent_AC_child_PAT_having_Annex](@positingTimepoint) a
    ON
        a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
    AND
        a.AC_parent_AC_child_PAT_having_PositedAt = (
            SELECT TOP 1
                sub.AC_parent_AC_child_PAT_having_PositedAt
            FROM
                [dbo].[rAC_parent_AC_child_PAT_having_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            ORDER BY
                sub.AC_parent_AC_child_PAT_having_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rPR_content_ST_location_EV_of_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_content_ST_location_EV_of_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_content_ST_location_EV_of_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    FROM
        [dbo].[PR_content_ST_location_EV_of_Annex]
    WHERE
        PR_content_ST_location_EV_of_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rPR_content_ST_location_EV_of rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_content_ST_location_EV_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_content_ST_location_EV_of] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ID,
        p.PR_ID_content,
        p.ST_ID_location,
        p.EV_ID_of,
        a.PR_content_ST_location_EV_of_PositedAt,
        a.PR_content_ST_location_EV_of_Reliability
    FROM
        [dbo].[PR_content_ST_location_EV_of_Posit] p
    JOIN
        [dbo].[rPR_content_ST_location_EV_of_Annex](@positingTimepoint) a
    ON
        a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    AND
        a.PR_content_ST_location_EV_of_PositedAt = (
            SELECT TOP 1
                sub.PR_content_ST_location_EV_of_PositedAt
            FROM
                [dbo].[rPR_content_ST_location_EV_of_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            ORDER BY
                sub.PR_content_ST_location_EV_of_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fPR_content_ST_location_EV_of forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fPR_content_ST_location_EV_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fPR_content_ST_location_EV_of] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ID,
        p.PR_ID_content,
        p.ST_ID_location,
        p.EV_ID_of,
        a.PR_content_ST_location_EV_of_PositedAt,
        a.PR_content_ST_location_EV_of_Reliability
    FROM
        [dbo].[PR_content_ST_location_EV_of_Posit] p
    JOIN
        [dbo].[rPR_content_ST_location_EV_of_Annex](@positingTimepoint) a
    ON
        a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    AND
        a.PR_content_ST_location_EV_of_PositedAt = (
            SELECT TOP 1
                sub.PR_content_ST_location_EV_of_PositedAt
            FROM
                [dbo].[rPR_content_ST_location_EV_of_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            ORDER BY
                sub.PR_content_ST_location_EV_of_PositedAt DESC
        )
    ');
END
GO
-- TIE TEMPORAL BUSINESS PERSPECTIVES ---------------------------------------------------------------------------------
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Actor_partner_Actor_with_currently_Ongoing', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('dbo.Current_Actor_partner_Actor_with_currently_Ongoing', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('dbo.Point_Actor_partner_Actor_with_currently_Ongoing', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('dbo.Latest_Actor_partner_Actor_with_currently_Ongoing', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Actor_partner_Actor_with_currently_Ongoing];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Actor_subset_Person_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Actor_subset_Person_of];
IF Object_ID('dbo.Current_Actor_subset_Person_of', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Actor_subset_Person_of];
IF Object_ID('dbo.Point_Actor_subset_Person_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Actor_subset_Person_of];
IF Object_ID('dbo.Latest_Actor_subset_Person_of', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Actor_subset_Person_of];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_in_Unknown_Actor_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_in_Unknown_Actor_wasCast];
IF Object_ID('dbo.Current_in_Unknown_Actor_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_in_Unknown_Actor_wasCast];
IF Object_ID('dbo.Point_in_Unknown_Actor_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_in_Unknown_Actor_wasCast];
IF Object_ID('dbo.Latest_in_Unknown_Actor_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_in_Unknown_Actor_wasCast];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Actor_part_Program_in_got_Rating', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Actor_part_Program_in_got_Rating];
IF Object_ID('dbo.Current_Actor_part_Program_in_got_Rating', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Actor_part_Program_in_got_Rating];
IF Object_ID('dbo.Point_Actor_part_Program_in_got_Rating', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Actor_part_Program_in_got_Rating];
IF Object_ID('dbo.Latest_Actor_part_Program_in_got_Rating', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Actor_part_Program_in_got_Rating];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Stage_at_Program_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Stage_at_Program_isPlaying];
IF Object_ID('dbo.Current_Stage_at_Program_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Stage_at_Program_isPlaying];
IF Object_ID('dbo.Point_Stage_at_Program_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Stage_at_Program_isPlaying];
IF Object_ID('dbo.Latest_Stage_at_Program_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Stage_at_Program_isPlaying];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Actor_parent_Actor_child_having_ParentalType', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('dbo.Current_Actor_parent_Actor_child_having_ParentalType', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('dbo.Point_Actor_parent_Actor_child_having_ParentalType', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('dbo.Latest_Actor_parent_Actor_child_having_ParentalType', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Actor_parent_Actor_child_having_ParentalType];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Program_content_Stage_location_of_Unknown', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Program_content_Stage_location_of_Unknown];
IF Object_ID('dbo.Current_Program_content_Stage_location_of_Unknown', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Program_content_Stage_location_of_Unknown];
IF Object_ID('dbo.Point_Program_content_Stage_location_of_Unknown', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Program_content_Stage_location_of_Unknown];
IF Object_ID('dbo.Latest_Program_content_Stage_location_of_Unknown', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Program_content_Stage_location_of_Unknown];
GO
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
--
-- The time traveling perspective shows information as it was or will be based on a number
-- of input parameters.
--
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
--
-- The latest perspective shows the latest available information for each tie.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.nAC_partner_AC_with_ONG_currently', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.pAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.lAC_partner_AC_with_ONG_currently', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.tAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tAC_partner_AC_with_ONG_currently];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_partner_AC_with_ONG_currently viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tAC_partner_AC_with_ONG_currently] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_partner_AC_with_ONG_currently_ID,
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_partner_AC_with_ONG_currently_PositedAt,
    tie.AC_partner_AC_with_ONG_currently_Reliability,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    [dbo].[rAC_partner_AC_with_ONG_currently](
        @changingTimepoint,
        @positingTimepoint
    ) tie
JOIN
    [dbo].[ONG_Ongoing] [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ID = (
        SELECT TOP 1
            sub.AC_partner_AC_with_ONG_currently_ID
        FROM
            [dbo].[rAC_partner_AC_with_ONG_currently](
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_partner_AC_with_ONG_currently_Reliability = 1
        AND
        (
                sub.AC_ID_partner = tie.AC_ID_partner
            OR
                sub.AC_ID_with = tie.AC_ID_with
        )
        ORDER BY
            sub.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
            sub.AC_partner_AC_with_ONG_currently_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_partner_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_partner_AC_with_ONG_currently] AS
SELECT
    *
FROM
    [dbo].[tAC_partner_AC_with_ONG_currently] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_partner_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_partner_AC_with_ONG_currently] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tAC_partner_AC_with_ONG_currently] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_partner_AC_with_ONG_currently viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_partner_AC_with_ONG_currently]
AS
SELECT
    *
FROM
    [dbo].[tAC_partner_AC_with_ONG_currently] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_partner_AC_with_ONG_currently showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dAC_partner_AC_with_ONG_currently] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].Metadata_ONG AS currently_Metadata_ONG,
    tie.*
FROM
    [dbo].[AC_partner_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[ONG_Ongoing] [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_subset_PN_of];
IF Object_ID('dbo.nAC_subset_PN_of', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_subset_PN_of];
IF Object_ID('dbo.pAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_subset_PN_of];
IF Object_ID('dbo.lAC_subset_PN_of', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_subset_PN_of];
IF Object_ID('dbo.tAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tAC_subset_PN_of];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_subset_PN_of viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tAC_subset_PN_of] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_subset_PN_of_ID,
    tie.Metadata_AC_subset_PN_of,
    tie.AC_subset_PN_of_PositedAt,
    tie.AC_subset_PN_of_Reliability,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    [dbo].[rAC_subset_PN_of](
        @positingTimepoint
    ) tie
WHERE
    tie.AC_subset_PN_of_ID = (
        SELECT TOP 1
            sub.AC_subset_PN_of_ID
        FROM
            [dbo].[rAC_subset_PN_of](
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_subset_PN_of_Reliability = 1
        AND
        (
                sub.AC_ID_subset = tie.AC_ID_subset
            OR
                sub.PN_ID_of = tie.PN_ID_of
        )
        ORDER BY
            sub.AC_subset_PN_of_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_subset_PN_of] AS
SELECT
    *
FROM
    [dbo].[tAC_subset_PN_of] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_subset_PN_of] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tAC_subset_PN_of] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_subset_PN_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_subset_PN_of]
AS
SELECT
    *
FROM
    [dbo].[tAC_subset_PN_of] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dEV_in_AC_wasCast];
IF Object_ID('dbo.nEV_in_AC_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[nEV_in_AC_wasCast];
IF Object_ID('dbo.pEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pEV_in_AC_wasCast];
IF Object_ID('dbo.lEV_in_AC_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[lEV_in_AC_wasCast];
IF Object_ID('dbo.tEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tEV_in_AC_wasCast];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tEV_in_AC_wasCast viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tEV_in_AC_wasCast] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.EV_in_AC_wasCast_ID,
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_in_AC_wasCast_PositedAt,
    tie.EV_in_AC_wasCast_Reliability,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    [dbo].[rEV_in_AC_wasCast](
        @positingTimepoint
    ) tie
WHERE
    tie.EV_in_AC_wasCast_ID = (
        SELECT TOP 1
            sub.EV_in_AC_wasCast_ID
        FROM
            [dbo].[rEV_in_AC_wasCast](
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_in_AC_wasCast_Reliability = 1
        AND
            sub.EV_ID_in = tie.EV_ID_in
        AND
            sub.AC_ID_wasCast = tie.AC_ID_wasCast
        ORDER BY
            sub.EV_in_AC_wasCast_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lEV_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lEV_in_AC_wasCast] AS
SELECT
    *
FROM
    [dbo].[tEV_in_AC_wasCast] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pEV_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pEV_in_AC_wasCast] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tEV_in_AC_wasCast] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_in_AC_wasCast viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nEV_in_AC_wasCast]
AS
SELECT
    *
FROM
    [dbo].[tEV_in_AC_wasCast] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_part_PR_in_RAT_got];
IF Object_ID('dbo.nAC_part_PR_in_RAT_got', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_part_PR_in_RAT_got];
IF Object_ID('dbo.pAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_part_PR_in_RAT_got];
IF Object_ID('dbo.lAC_part_PR_in_RAT_got', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_part_PR_in_RAT_got];
IF Object_ID('dbo.tAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tAC_part_PR_in_RAT_got];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_part_PR_in_RAT_got viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tAC_part_PR_in_RAT_got] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_part_PR_in_RAT_got_ID,
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_part_PR_in_RAT_got_PositedAt,
    tie.AC_part_PR_in_RAT_got_Reliability,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    [dbo].[rAC_part_PR_in_RAT_got](
        @changingTimepoint,
        @positingTimepoint
    ) tie
JOIN
    [dbo].[RAT_Rating] [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ID = (
        SELECT TOP 1
            sub.AC_part_PR_in_RAT_got_ID
        FROM
            [dbo].[rAC_part_PR_in_RAT_got](
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_part_PR_in_RAT_got_Reliability = 1
        AND
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
        ORDER BY
            sub.AC_part_PR_in_RAT_got_ChangedAt DESC,
            sub.AC_part_PR_in_RAT_got_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_part_PR_in_RAT_got] AS
SELECT
    *
FROM
    [dbo].[tAC_part_PR_in_RAT_got] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_part_PR_in_RAT_got] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tAC_part_PR_in_RAT_got] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_part_PR_in_RAT_got viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_part_PR_in_RAT_got]
AS
SELECT
    *
FROM
    [dbo].[tAC_part_PR_in_RAT_got] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_part_PR_in_RAT_got showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dAC_part_PR_in_RAT_got] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].Metadata_RAT AS got_Metadata_RAT,
    tie.*
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[RAT_Rating] [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_at_PR_isPlaying];
IF Object_ID('dbo.nST_at_PR_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_at_PR_isPlaying];
IF Object_ID('dbo.pST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_at_PR_isPlaying];
IF Object_ID('dbo.lST_at_PR_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_at_PR_isPlaying];
IF Object_ID('dbo.tST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tST_at_PR_isPlaying];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tST_at_PR_isPlaying viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tST_at_PR_isPlaying] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.ST_at_PR_isPlaying_ID,
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_at_PR_isPlaying_PositedAt,
    tie.ST_at_PR_isPlaying_Reliability,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[rST_at_PR_isPlaying](
        @changingTimepoint,
        @positingTimepoint
    ) tie
WHERE
    tie.ST_at_PR_isPlaying_ID = (
        SELECT TOP 1
            sub.ST_at_PR_isPlaying_ID
        FROM
            [dbo].[rST_at_PR_isPlaying](
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.ST_at_PR_isPlaying_Reliability = 1
        AND
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
        ORDER BY
            sub.ST_at_PR_isPlaying_ChangedAt DESC,
            sub.ST_at_PR_isPlaying_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_at_PR_isPlaying] AS
SELECT
    *
FROM
    [dbo].[tST_at_PR_isPlaying] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_at_PR_isPlaying] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tST_at_PR_isPlaying] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_at_PR_isPlaying viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_at_PR_isPlaying]
AS
SELECT
    *
FROM
    [dbo].[tST_at_PR_isPlaying] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dST_at_PR_isPlaying showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dST_at_PR_isPlaying] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.*
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.nAC_parent_AC_child_PAT_having', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.pAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.lAC_parent_AC_child_PAT_having', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.tAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tAC_parent_AC_child_PAT_having];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_parent_AC_child_PAT_having viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tAC_parent_AC_child_PAT_having] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_parent_AC_child_PAT_having_ID,
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_parent_AC_child_PAT_having_PositedAt,
    tie.AC_parent_AC_child_PAT_having_Reliability,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    [PAT_having].PAT_ParentalType AS having_PAT_ParentalType,
    [PAT_having].Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    [dbo].[rAC_parent_AC_child_PAT_having](
        @positingTimepoint
    ) tie
JOIN
    [dbo].[PAT_ParentalType] [PAT_having]
ON
    [PAT_having].PAT_ID = tie.PAT_ID_having
WHERE
    tie.AC_parent_AC_child_PAT_having_ID = (
        SELECT TOP 1
            sub.AC_parent_AC_child_PAT_having_ID
        FROM
            [dbo].[rAC_parent_AC_child_PAT_having](
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_parent_AC_child_PAT_having_Reliability = 1
        AND
            sub.AC_ID_parent = tie.AC_ID_parent
        AND
            sub.AC_ID_child = tie.AC_ID_child
        AND
            sub.PAT_ID_having = tie.PAT_ID_having
        ORDER BY
            sub.AC_parent_AC_child_PAT_having_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_parent_AC_child_PAT_having] AS
SELECT
    *
FROM
    [dbo].[tAC_parent_AC_child_PAT_having] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_parent_AC_child_PAT_having] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tAC_parent_AC_child_PAT_having] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_parent_AC_child_PAT_having viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_parent_AC_child_PAT_having]
AS
SELECT
    *
FROM
    [dbo].[tAC_parent_AC_child_PAT_having] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPR_content_ST_location_EV_of];
IF Object_ID('dbo.nPR_content_ST_location_EV_of', 'V') IS NOT NULL
DROP VIEW [dbo].[nPR_content_ST_location_EV_of];
IF Object_ID('dbo.pPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPR_content_ST_location_EV_of];
IF Object_ID('dbo.lPR_content_ST_location_EV_of', 'V') IS NOT NULL
DROP VIEW [dbo].[lPR_content_ST_location_EV_of];
IF Object_ID('dbo.tPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tPR_content_ST_location_EV_of];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tPR_content_ST_location_EV_of viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tPR_content_ST_location_EV_of] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.PR_content_ST_location_EV_of_ID,
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_PositedAt,
    tie.PR_content_ST_location_EV_of_Reliability,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    [dbo].[rPR_content_ST_location_EV_of](
        @positingTimepoint
    ) tie
WHERE
    tie.PR_content_ST_location_EV_of_ID = (
        SELECT TOP 1
            sub.PR_content_ST_location_EV_of_ID
        FROM
            [dbo].[rPR_content_ST_location_EV_of](
                @positingTimepoint
            ) sub
        WHERE
            sub.PR_content_ST_location_EV_of_Reliability = 1
        AND
            sub.EV_ID_of = tie.EV_ID_of
        ORDER BY
            sub.PR_content_ST_location_EV_of_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_content_ST_location_EV_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPR_content_ST_location_EV_of] AS
SELECT
    *
FROM
    [dbo].[tPR_content_ST_location_EV_of] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_content_ST_location_EV_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPR_content_ST_location_EV_of] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tPR_content_ST_location_EV_of] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_content_ST_location_EV_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPR_content_ST_location_EV_of]
AS
SELECT
    *
FROM
    [dbo].[tPR_content_ST_location_EV_of] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- TIE TEMPORAL BUSINESS PERSPECTIVES ---------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
--
-- The latest perspective shows the latest available information for each tie.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Actor_partner_Actor_with_currently_Ongoing viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Actor_partner_Actor_with_currently_Ongoing] AS
SELECT
    tie.AC_ID_partner as [Actor_partner_Id],
    tie.AC_ID_with as [Actor_with_Id],
    tie.currently_ONG_Ongoing AS [currently_Ongoing]
FROM
    [dbo].[lAC_partner_AC_with_ONG_currently] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Actor_partner_Actor_with_currently_Ongoing viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Actor_partner_Actor_with_currently_Ongoing] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_ID_partner as [Actor_partner_Id],
    tie.AC_ID_with as [Actor_with_Id],
    tie.currently_ONG_Ongoing AS [currently_Ongoing]
FROM
    [dbo].[pAC_partner_AC_with_ONG_currently](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Actor_partner_Actor_with_currently_Ongoing viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Actor_partner_Actor_with_currently_Ongoing]
AS
SELECT
    *
FROM
    [dbo].[Point_Actor_partner_Actor_with_currently_Ongoing](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Actor_partner_Actor_with_currently_Ongoing showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Difference_Actor_partner_Actor_with_currently_Ongoing] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt as [Time_of_Change],
    tie.AC_ID_partner as [Actor_partner_Id],
    tie.AC_ID_with as [Actor_with_Id],
    tie.currently_ONG_Ongoing AS [currently_Ongoing]
FROM
    [dbo].[dAC_partner_AC_with_ONG_currently](@intervalStart, @intervalEnd) tie;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Actor_subset_Person_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Actor_subset_Person_of] AS
SELECT
    tie.AC_ID_subset as [Actor_subset_Id],
    tie.PN_ID_of as [Person_of_Id]
FROM
    [dbo].[lAC_subset_PN_of] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Actor_subset_Person_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Actor_subset_Person_of] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_ID_subset as [Actor_subset_Id],
    tie.PN_ID_of as [Person_of_Id]
FROM
    [dbo].[pAC_subset_PN_of](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Actor_subset_Person_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Actor_subset_Person_of]
AS
SELECT
    *
FROM
    [dbo].[Point_Actor_subset_Person_of](sysdatetime());
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_in_Unknown_Actor_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_in_Unknown_Actor_wasCast] AS
SELECT
    tie.EV_ID_in as [in_Unknown_Id],
    tie.AC_ID_wasCast as [Actor_wasCast_Id]
FROM
    [dbo].[lEV_in_AC_wasCast] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_in_Unknown_Actor_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_in_Unknown_Actor_wasCast] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.EV_ID_in as [in_Unknown_Id],
    tie.AC_ID_wasCast as [Actor_wasCast_Id]
FROM
    [dbo].[pEV_in_AC_wasCast](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_in_Unknown_Actor_wasCast viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_in_Unknown_Actor_wasCast]
AS
SELECT
    *
FROM
    [dbo].[Point_in_Unknown_Actor_wasCast](sysdatetime());
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Actor_part_Program_in_got_Rating viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Actor_part_Program_in_got_Rating] AS
SELECT
    tie.AC_ID_part as [Actor_part_Id],
    tie.PR_ID_in as [Program_in_Id],
    tie.got_RAT_Rating AS [got_Rating]
FROM
    [dbo].[lAC_part_PR_in_RAT_got] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Actor_part_Program_in_got_Rating viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Actor_part_Program_in_got_Rating] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_ID_part as [Actor_part_Id],
    tie.PR_ID_in as [Program_in_Id],
    tie.got_RAT_Rating AS [got_Rating]
FROM
    [dbo].[pAC_part_PR_in_RAT_got](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Actor_part_Program_in_got_Rating viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Actor_part_Program_in_got_Rating]
AS
SELECT
    *
FROM
    [dbo].[Point_Actor_part_Program_in_got_Rating](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Actor_part_Program_in_got_Rating showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Difference_Actor_part_Program_in_got_Rating] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt as [Time_of_Change],
    tie.AC_ID_part as [Actor_part_Id],
    tie.PR_ID_in as [Program_in_Id],
    tie.got_RAT_Rating AS [got_Rating]
FROM
    [dbo].[dAC_part_PR_in_RAT_got](@intervalStart, @intervalEnd) tie;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Stage_at_Program_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Stage_at_Program_isPlaying] AS
SELECT
    tie.ST_ID_at as [Stage_at_Id],
    tie.PR_ID_isPlaying as [Program_isPlaying_Id]
FROM
    [dbo].[lST_at_PR_isPlaying] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Stage_at_Program_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Stage_at_Program_isPlaying] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.ST_ID_at as [Stage_at_Id],
    tie.PR_ID_isPlaying as [Program_isPlaying_Id]
FROM
    [dbo].[pST_at_PR_isPlaying](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Stage_at_Program_isPlaying viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Stage_at_Program_isPlaying]
AS
SELECT
    *
FROM
    [dbo].[Point_Stage_at_Program_isPlaying](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Stage_at_Program_isPlaying showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Difference_Stage_at_Program_isPlaying] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt as [Time_of_Change],
    tie.ST_ID_at as [Stage_at_Id],
    tie.PR_ID_isPlaying as [Program_isPlaying_Id]
FROM
    [dbo].[dST_at_PR_isPlaying](@intervalStart, @intervalEnd) tie;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Actor_parent_Actor_child_having_ParentalType viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Actor_parent_Actor_child_having_ParentalType] AS
SELECT
    tie.AC_ID_parent as [Actor_parent_Id],
    tie.AC_ID_child as [Actor_child_Id],
    tie.having_PAT_ParentalType AS [having_ParentalType]
FROM
    [dbo].[lAC_parent_AC_child_PAT_having] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Actor_parent_Actor_child_having_ParentalType viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Actor_parent_Actor_child_having_ParentalType] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_ID_parent as [Actor_parent_Id],
    tie.AC_ID_child as [Actor_child_Id],
    tie.having_PAT_ParentalType AS [having_ParentalType]
FROM
    [dbo].[pAC_parent_AC_child_PAT_having](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Actor_parent_Actor_child_having_ParentalType viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Actor_parent_Actor_child_having_ParentalType]
AS
SELECT
    *
FROM
    [dbo].[Point_Actor_parent_Actor_child_having_ParentalType](sysdatetime());
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Program_content_Stage_location_of_Unknown viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Program_content_Stage_location_of_Unknown] AS
SELECT
    tie.PR_ID_content as [Program_content_Id],
    tie.ST_ID_location as [Stage_location_Id],
    tie.EV_ID_of as [of_Unknown_Id]
FROM
    [dbo].[lPR_content_ST_location_EV_of] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Program_content_Stage_location_of_Unknown viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Program_content_Stage_location_of_Unknown] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.PR_ID_content as [Program_content_Id],
    tie.ST_ID_location as [Stage_location_Id],
    tie.EV_ID_of as [of_Unknown_Id]
FROM
    [dbo].[pPR_content_ST_location_EV_of](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Program_content_Stage_location_of_Unknown viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Program_content_Stage_location_of_Unknown]
AS
SELECT
    *
FROM
    [dbo].[Point_Program_content_Stage_location_of_Unknown](sysdatetime());
GO
-- NATURAL KEYS -------------------------------------------------------------------------------------------------------
--
-- A natural key is a route in the model: the values that identify an anchor or a nexus, reached from it through its
-- attributes, its roles and ties (see naturalKeys() in Helpers.js for the rules a route follows). For each route of
-- each anchor and nexus there is
--
--   key_<anchor or nexus>_<route>          the key of every identity, from the latest values, with one column for
--                                          each value; a value with a checksum, such as a geography, is followed by
--                                          its checksum, which is what it is matched on
--   pkey_<anchor or nexus>_<route>(time)   the key of every identity at a changing time, for a route that passes
--                                          something historized, since its key can change
--   ic_key_<anchor or nexus>_<route>       the keys that more than one identity has, and the identities that have
--                                          more than one key; a view that returns nothing has nothing wrong
--   <anchor or nexus>_<route>              a table with the key of every identity that has all of its values, and a
--   refresh_<anchor or nexus>_<route>      procedure that fills it from the key view; its unique constraint makes the
--                                          procedure fail when two identities have the same key, and it can be indexed
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_ST_Stage_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_ST_Stage_1st];
GO
CREATE VIEW [dbo].[key_ST_Stage_1st] AS
SELECT
    [ST].ST_ID,
    [ST].ST_LOC_Stage_Location AS ST_LOC_Stage_Location,
    [ST].ST_LOC_Checksum AS ST_LOC_Checksum
FROM
    [dbo].[lST_Stage] [ST]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_ST_Stage_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_ST_Stage_1st];
GO
CREATE VIEW [dbo].[ic_key_ST_Stage_1st] AS
SELECT
    'key_ST_Stage_1st' AS Construct,
    'duplicate natural key' AS Violation,
    CONCAT(
        'ST_LOC_Checksum=', CONVERT(varchar(max), d.ST_LOC_Checksum, 1)
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        ST_LOC_Checksum,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_1st]
    WHERE
        ST_LOC_Checksum is not null
    GROUP BY
        ST_LOC_Checksum
    HAVING
        COUNT(DISTINCT ST_ID) > 1
) d
UNION ALL
SELECT
    'key_ST_Stage_1st',
    'more than one natural key',
    CONCAT(
        'ST_ID=', d.ST_ID
    ),
    d.Occurrences
FROM (
    SELECT
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_1st]
    GROUP BY
        ST_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage, filled by refresh_ST_Stage_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[ST_Stage_1st];
GO
CREATE TABLE [dbo].[ST_Stage_1st] (
    ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum varbinary(16) not null,
    constraint pkST_Stage_1st primary key (
        ST_ID
    ),
    constraint uqST_Stage_1st unique (
        ST_LOC_Checksum
    )
);
GO
IF Object_ID('dbo.refresh_ST_Stage_1st', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_ST_Stage_1st];
GO
CREATE PROCEDURE [dbo].[refresh_ST_Stage_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[ST_Stage_1st];
    INSERT INTO [dbo].[ST_Stage_1st] (
        ST_ID,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum
    )
    SELECT
        ST_ID,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum
    FROM
        [dbo].[key_ST_Stage_1st]
    WHERE
        ST_LOC_Checksum is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_ST_Stage_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[key_ST_Stage_2nd];
GO
CREATE VIEW [dbo].[key_ST_Stage_2nd] AS
SELECT
    [ST].ST_ID,
    [ST].ST_NAM_Stage_Name AS ST_NAM_Stage_Name,
    [ST].ST_NAM_Checksum AS ST_NAM_Checksum
FROM
    [dbo].[lST_Stage] [ST]
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.pkey_ST_Stage_2nd', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pkey_ST_Stage_2nd];
GO
CREATE FUNCTION [dbo].[pkey_ST_Stage_2nd] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [ST].ST_ID,
    [ST].ST_NAM_Stage_Name AS ST_NAM_Stage_Name,
    [ST].ST_NAM_Checksum AS ST_NAM_Checksum
FROM
    [dbo].[pST_Stage](@changingTimepoint) [ST]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_ST_Stage_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_ST_Stage_2nd];
GO
CREATE VIEW [dbo].[ic_key_ST_Stage_2nd] AS
SELECT
    'key_ST_Stage_2nd' AS Construct,
    'duplicate natural key' AS Violation,
    CONCAT(
        'ST_NAM_Checksum=', CONVERT(varchar(max), d.ST_NAM_Checksum, 1)
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        ST_NAM_Checksum,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_2nd]
    WHERE
        ST_NAM_Checksum is not null
    GROUP BY
        ST_NAM_Checksum
    HAVING
        COUNT(DISTINCT ST_ID) > 1
) d
UNION ALL
SELECT
    'key_ST_Stage_2nd',
    'more than one natural key',
    CONCAT(
        'ST_ID=', d.ST_ID
    ),
    d.Occurrences
FROM (
    SELECT
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_2nd]
    GROUP BY
        ST_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage, filled by refresh_ST_Stage_2nd
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage_2nd', 'U') IS NOT NULL
DROP TABLE [dbo].[ST_Stage_2nd];
GO
CREATE TABLE [dbo].[ST_Stage_2nd] (
    ST_ID int not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    ST_NAM_Checksum varbinary(16) not null,
    constraint pkST_Stage_2nd primary key (
        ST_ID
    ),
    constraint uqST_Stage_2nd unique (
        ST_NAM_Checksum
    )
);
GO
IF Object_ID('dbo.refresh_ST_Stage_2nd', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_ST_Stage_2nd];
GO
CREATE PROCEDURE [dbo].[refresh_ST_Stage_2nd] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[ST_Stage_2nd];
    INSERT INTO [dbo].[ST_Stage_2nd] (
        ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_Checksum
    )
    SELECT
        ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_Checksum
    FROM
        [dbo].[key_ST_Stage_2nd]
    WHERE
        ST_NAM_Checksum is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_AC_Actor_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_AC_Actor_1st];
GO
CREATE VIEW [dbo].[key_AC_Actor_1st] AS
SELECT
    [AC].AC_ID,
    [AC].AC_NAM_Actor_Name AS AC_NAM_Actor_Name,
    [AC].AC_NAM_Checksum AS AC_NAM_Checksum
FROM
    [dbo].[lAC_Actor] [AC]
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.pkey_AC_Actor_1st', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pkey_AC_Actor_1st];
GO
CREATE FUNCTION [dbo].[pkey_AC_Actor_1st] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [AC].AC_ID,
    [AC].AC_NAM_Actor_Name AS AC_NAM_Actor_Name,
    [AC].AC_NAM_Checksum AS AC_NAM_Checksum
FROM
    [dbo].[pAC_Actor](@changingTimepoint) [AC]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_AC_Actor_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_AC_Actor_1st];
GO
CREATE VIEW [dbo].[ic_key_AC_Actor_1st] AS
SELECT
    'key_AC_Actor_1st' AS Construct,
    'duplicate natural key' AS Violation,
    CONCAT(
        'AC_NAM_Checksum=', CONVERT(varchar(max), d.AC_NAM_Checksum, 1)
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        AC_NAM_Checksum,
        COUNT(DISTINCT AC_ID) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_1st]
    WHERE
        AC_NAM_Checksum is not null
    GROUP BY
        AC_NAM_Checksum
    HAVING
        COUNT(DISTINCT AC_ID) > 1
) d
UNION ALL
SELECT
    'key_AC_Actor_1st',
    'more than one natural key',
    CONCAT(
        'AC_ID=', d.AC_ID
    ),
    d.Occurrences
FROM (
    SELECT
        AC_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_1st]
    GROUP BY
        AC_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor, filled by refresh_AC_Actor_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_Actor_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[AC_Actor_1st];
GO
CREATE TABLE [dbo].[AC_Actor_1st] (
    AC_ID int not null,
    AC_NAM_Actor_Name nvarchar(42) not null,
    AC_NAM_Checksum varbinary(16) not null,
    constraint pkAC_Actor_1st primary key (
        AC_ID
    ),
    constraint uqAC_Actor_1st unique (
        AC_NAM_Checksum
    )
);
GO
IF Object_ID('dbo.refresh_AC_Actor_1st', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_AC_Actor_1st];
GO
CREATE PROCEDURE [dbo].[refresh_AC_Actor_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[AC_Actor_1st];
    INSERT INTO [dbo].[AC_Actor_1st] (
        AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_Checksum
    )
    SELECT
        AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_Checksum
    FROM
        [dbo].[key_AC_Actor_1st]
    WHERE
        AC_NAM_Checksum is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_PR_Program_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_PR_Program_1st];
GO
CREATE VIEW [dbo].[key_PR_Program_1st] AS
SELECT
    [PR].PR_ID,
    [PR].PR_NAM_Program_Name AS PR_NAM_Program_Name
FROM
    [dbo].[lPR_Program] [PR]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_PR_Program_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_PR_Program_1st];
GO
CREATE VIEW [dbo].[ic_key_PR_Program_1st] AS
SELECT
    'key_PR_Program_1st' AS Construct,
    'duplicate natural key' AS Violation,
    CONCAT(
        'PR_NAM_Program_Name=', d.PR_NAM_Program_Name
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        PR_NAM_Program_Name,
        COUNT(DISTINCT PR_ID) AS Occurrences
    FROM
        [dbo].[key_PR_Program_1st]
    WHERE
        PR_NAM_Program_Name is not null
    GROUP BY
        PR_NAM_Program_Name
    HAVING
        COUNT(DISTINCT PR_ID) > 1
) d
UNION ALL
SELECT
    'key_PR_Program_1st',
    'more than one natural key',
    CONCAT(
        'PR_ID=', d.PR_ID
    ),
    d.Occurrences
FROM (
    SELECT
        PR_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_PR_Program_1st]
    GROUP BY
        PR_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program, filled by refresh_PR_Program_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_Program_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[PR_Program_1st];
GO
CREATE TABLE [dbo].[PR_Program_1st] (
    PR_ID int not null,
    PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkPR_Program_1st primary key (
        PR_ID
    ),
    constraint uqPR_Program_1st unique (
        PR_NAM_Program_Name
    )
);
GO
IF Object_ID('dbo.refresh_PR_Program_1st', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_PR_Program_1st];
GO
CREATE PROCEDURE [dbo].[refresh_PR_Program_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[PR_Program_1st];
    INSERT INTO [dbo].[PR_Program_1st] (
        PR_ID,
        PR_NAM_Program_Name
    )
    SELECT
        PR_ID,
        PR_NAM_Program_Name
    FROM
        [dbo].[key_PR_Program_1st]
    WHERE
        PR_NAM_Program_Name is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_EV_Event_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_EV_Event_1st];
GO
CREATE VIEW [dbo].[key_EV_Event_1st] AS
SELECT
    [EV].EV_ID,
    [EV].EV_DAT_Event_Date AS EV_DAT_Event_Date,
    [s2].ST_LOC_Stage_Location AS wasHeldAt_ST_LOC_Stage_Location,
    [s2].ST_LOC_Checksum AS wasHeldAt_ST_LOC_Checksum,
    [s4].PR_NAM_Program_Name AS wasPlayed_PR_NAM_Program_Name
FROM
    [dbo].[lEV_Event] [EV]
LEFT JOIN
    [dbo].[lST_Stage] [s2]
ON
    [s2].ST_ID = [EV].ST_ID_wasHeldAt
LEFT JOIN
    [dbo].[lPR_Program] [s4]
ON
    [s4].PR_ID = [EV].PR_ID_wasPlayed
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_EV_Event_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_EV_Event_1st];
GO
CREATE VIEW [dbo].[ic_key_EV_Event_1st] AS
SELECT
    'key_EV_Event_1st' AS Construct,
    'duplicate natural key' AS Violation,
    CONCAT(
        'EV_DAT_Event_Date=', d.EV_DAT_Event_Date, ', ',
        'wasHeldAt_ST_LOC_Checksum=', CONVERT(varchar(max), d.wasHeldAt_ST_LOC_Checksum, 1), ', ',
        'wasPlayed_PR_NAM_Program_Name=', d.wasPlayed_PR_NAM_Program_Name
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name,
        COUNT(DISTINCT EV_ID) AS Occurrences
    FROM
        [dbo].[key_EV_Event_1st]
    WHERE
        EV_DAT_Event_Date is not null
    AND
        wasHeldAt_ST_LOC_Checksum is not null
    AND
        wasPlayed_PR_NAM_Program_Name is not null
    GROUP BY
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    HAVING
        COUNT(DISTINCT EV_ID) > 1
) d
UNION ALL
SELECT
    'key_EV_Event_1st',
    'more than one natural key',
    CONCAT(
        'EV_ID=', d.EV_ID
    ),
    d.Occurrences
FROM (
    SELECT
        EV_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_EV_Event_1st]
    GROUP BY
        EV_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event, filled by refresh_EV_Event_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_Event_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[EV_Event_1st];
GO
CREATE TABLE [dbo].[EV_Event_1st] (
    EV_ID int not null,
    EV_DAT_Event_Date datetime2 not null,
    wasHeldAt_ST_LOC_Stage_Location geography not null,
    wasHeldAt_ST_LOC_Checksum varbinary(16) not null,
    wasPlayed_PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkEV_Event_1st primary key (
        EV_ID
    ),
    constraint uqEV_Event_1st unique (
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    )
);
GO
IF Object_ID('dbo.refresh_EV_Event_1st', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_EV_Event_1st];
GO
CREATE PROCEDURE [dbo].[refresh_EV_Event_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[EV_Event_1st];
    INSERT INTO [dbo].[EV_Event_1st] (
        EV_ID,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Stage_Location,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    )
    SELECT
        EV_ID,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Stage_Location,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    FROM
        [dbo].[key_EV_Event_1st]
    WHERE
        EV_DAT_Event_Date is not null
    AND
        wasHeldAt_ST_LOC_Checksum is not null
    AND
        wasPlayed_PR_NAM_Program_Name is not null
    ;
    COMMIT;
END
GO
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled and latest views make them behave like tables.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_partner_AC_with_ONG_currently instead of INSERT trigger on AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_partner_AC_with_ONG_currently', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_partner_AC_with_ONG_currently];
GO
CREATE TRIGGER [dbo].[it_AC_partner_AC_with_ONG_currently] ON [dbo].[AC_partner_AC_with_ONG_currently]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_AC_partner_AC_with_ONG_currently int not null,
        AC_partner_AC_with_ONG_currently_StatementType char(1) not null,
        AC_partner_AC_with_ONG_currently_ChangedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_PositedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_Reliability decimal(5,2) not null,
        AC_ID_partner int not null,
        AC_ID_with int not null,
        ONG_ID_currently tinyint not null,
        primary key (
            AC_ID_partner asc,
            AC_ID_with asc,
            ONG_ID_currently asc,
            AC_partner_AC_with_ONG_currently_ChangedAt desc,
            AC_partner_AC_with_ONG_currently_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_partner,
            i.AC_ID_with,
            i.ONG_ID_currently,
            ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now) AS AC_partner_AC_with_ONG_currently_ChangedAt,
            ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now) AS AC_partner_AC_with_ONG_currently_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[AC_partner_AC_with_ONG_currently_Posit] p
            JOIN
                [dbo].[AC_partner_AC_with_ONG_currently_Annex] a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            WHERE
                p.AC_ID_partner = i.AC_ID_partner
            AND
                p.AC_ID_with = i.AC_ID_with
            AND
                p.ONG_ID_currently = i.ONG_ID_currently
            AND
                p.AC_partner_AC_with_ONG_currently_ChangedAt = ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now)
            AND
                a.AC_partner_AC_with_ONG_currently_PositedAt = ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now)
            AND
                a.AC_partner_AC_with_ONG_currently_Reliability <> ISNULL(i.AC_partner_AC_with_ONG_currently_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_partner_AC_with_ONG_currently for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_partner_AC_with_ONG_currently, 0),
        CASE
            WHEN p.AC_partner_AC_with_ONG_currently_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_partner_AC_with_ONG_currently_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now),
        ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now),
        ISNULL(i.AC_partner_AC_with_ONG_currently_Reliability, 1),
        i.AC_ID_partner,
        i.AC_ID_with,
        i.ONG_ID_currently
    FROM
        inserted i
    LEFT JOIN
        [dbo].[AC_partner_AC_with_ONG_currently_Posit] p
    ON
        p.AC_ID_partner = i.AC_ID_partner
    AND
        p.AC_ID_with = i.AC_ID_with
    AND
        p.ONG_ID_currently = i.ONG_ID_currently
    AND
        p.AC_partner_AC_with_ONG_currently_ChangedAt = i.AC_partner_AC_with_ONG_currently_ChangedAt
    LEFT JOIN
        [dbo].[AC_partner_AC_with_ONG_currently_Annex] a
    ON
        a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
    AND
        a.AC_partner_AC_with_ONG_currently_PositedAt = i.AC_partner_AC_with_ONG_currently_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_partner_AC_with_ONG_currently_ID is null OR a.AC_partner_AC_with_ONG_currently_ID is null)
    AND
        i.AC_ID_partner is not null
    AND
        i.AC_ID_with is not null
    AND
        i.ONG_ID_currently is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_AC_partner_AC_with_ONG_currently,
        'X', -- existing data
        x.AC_partner_AC_with_ONG_currently_ChangedAt,
        x.AC_partner_AC_with_ONG_currently_PositedAt,
        x.AC_partner_AC_with_ONG_currently_Reliability,
        x.AC_ID_partner,
        x.AC_ID_with,
        x.ONG_ID_currently
    FROM (
        SELECT
            a.Metadata_AC_partner_AC_with_ONG_currently,
            p.AC_partner_AC_with_ONG_currently_ChangedAt,
            a.AC_partner_AC_with_ONG_currently_PositedAt,
            a.AC_partner_AC_with_ONG_currently_Reliability,
            p.AC_ID_partner,
            p.AC_ID_with,
            p.ONG_ID_currently,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.AC_ID_partner,
                    p.AC_ID_with,
                    p.ONG_ID_currently,
                    p.AC_partner_AC_with_ONG_currently_ChangedAt,
                    a.AC_partner_AC_with_ONG_currently_PositedAt
                ORDER BY
                    a.AC_partner_AC_with_ONG_currently_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                AC_ID_partner,
                AC_ID_with,
                ONG_ID_currently
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[AC_partner_AC_with_ONG_currently_Posit] p
        ON
            p.AC_ID_partner = i.AC_ID_partner
        AND
            p.AC_ID_with = i.AC_ID_with
        AND
            p.ONG_ID_currently = i.ONG_ID_currently
        JOIN
            [dbo].[AC_partner_AC_with_ONG_currently_Annex] a
        ON
            a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.AC_ID_partner = x.AC_ID_partner
        AND
            n.AC_ID_with = x.AC_ID_with
        AND
            n.ONG_ID_currently = x.ONG_ID_currently
        AND
            n.AC_partner_AC_with_ONG_currently_ChangedAt = x.AC_partner_AC_with_ONG_currently_ChangedAt
        AND
            n.AC_partner_AC_with_ONG_currently_PositedAt = x.AC_partner_AC_with_ONG_currently_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_AC_partner_AC_with_ONG_currently int not null,
        AC_partner_AC_with_ONG_currently_StatementType char(1) not null,
        AC_partner_AC_with_ONG_currently_ChangedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_PositedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_Reliability decimal(5,2) not null,
        AC_ID_partner int not null,
        AC_ID_with int not null,
        ONG_ID_currently tinyint not null
    );
    INSERT INTO @retracted (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_StatementType,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    SELECT
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_StatementType,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_partner_AC_with_ONG_currently_Reliability as previous_AC_partner_AC_with_ONG_currently_Reliability,
            fol.AC_partner_AC_with_ONG_currently_Reliability as following_AC_partner_AC_with_ONG_currently_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_partner_AC_with_ONG_currently_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_partner = a.AC_ID_partner
            AND
                p.AC_ID_with = a.AC_ID_with
            AND
                p.ONG_ID_currently = a.ONG_ID_currently
            AND
                p.AC_partner_AC_with_ONG_currently_ChangedAt = a.AC_partner_AC_with_ONG_currently_ChangedAt
            AND
                p.AC_partner_AC_with_ONG_currently_PositedAt < a.AC_partner_AC_with_ONG_currently_PositedAt
            ORDER BY
                p.AC_partner_AC_with_ONG_currently_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_partner_AC_with_ONG_currently_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_partner = a.AC_ID_partner
            AND
                p.AC_ID_with = a.AC_ID_with
            AND
                p.ONG_ID_currently = a.ONG_ID_currently
            AND
                p.AC_partner_AC_with_ONG_currently_ChangedAt = a.AC_partner_AC_with_ONG_currently_ChangedAt
            AND
                p.AC_partner_AC_with_ONG_currently_PositedAt > a.AC_partner_AC_with_ONG_currently_PositedAt
            ORDER BY
                p.AC_partner_AC_with_ONG_currently_PositedAt ASC
        ) fol
        WHERE
            (a.AC_partner_AC_with_ONG_currently_Reliability = 0 AND isnull(pre.AC_partner_AC_with_ONG_currently_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_partner_AC_with_ONG_currently_Reliability = 1 AND fol.AC_partner_AC_with_ONG_currently_Reliability = 0)
    ) i
    WHERE
        i.AC_partner_AC_with_ONG_currently_StatementType <> 'X'
    AND (
            (i.AC_partner_AC_with_ONG_currently_Reliability = 0 AND i.previous_AC_partner_AC_with_ONG_currently_Reliability = 1)
        OR
            (i.AC_partner_AC_with_ONG_currently_Reliability = 1 AND i.following_AC_partner_AC_with_ONG_currently_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently_Posit] (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    FROM
        @inserted
    WHERE
        AC_partner_AC_with_ONG_currently_StatementType = 'P';
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently_Annex] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        v.Metadata_AC_partner_AC_with_ONG_currently,
        p.AC_partner_AC_with_ONG_currently_ID,
        v.AC_partner_AC_with_ONG_currently_PositedAt,
        v.AC_partner_AC_with_ONG_currently_Reliability
    FROM
        @inserted v
    JOIN
        [dbo].[AC_partner_AC_with_ONG_currently_Posit] p
    ON
        p.AC_ID_partner = v.AC_ID_partner
    AND
        p.AC_ID_with = v.AC_ID_with
    AND
        p.ONG_ID_currently = v.ONG_ID_currently
    AND
        p.AC_partner_AC_with_ONG_currently_ChangedAt = v.AC_partner_AC_with_ONG_currently_ChangedAt
    WHERE
        v.AC_partner_AC_with_ONG_currently_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_partner_AC_with_ONG_currently] ON [dbo].[lAC_partner_AC_with_ONG_currently]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        i.AC_partner_AC_with_ONG_currently_ChangedAt,
        i.AC_ID_partner,
        i.AC_ID_with,
        ISNULL(i.ONG_ID_currently, [ONG_currently].ONG_ID),
        i.AC_partner_AC_with_ONG_currently_PositedAt,
        i.AC_partner_AC_with_ONG_currently_Reliability
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_partner_AC_with_ONG_currently] ON [dbo].[lAC_partner_AC_with_ONG_currently]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_AC_partner_AC_with_ONG_currently_PositedAt bit = CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_partner_AC_with_ONG_currently_ChangedAt bit = CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_currently_ONG_Ongoing bit = CASE WHEN UPDATE(currently_ONG_Ongoing) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_partner_AC_with_ONG_currently_ID))
        RAISERROR('The identity column AC_partner_AC_with_ONG_currently_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently_Annex] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        i.AC_partner_AC_with_ONG_currently_ID,
        cast(ISNULL(CASE
            WHEN @updated_AC_partner_AC_with_ONG_currently_PositedAt = 1 THEN i.AC_partner_AC_with_ONG_currently_PositedAt
            WHEN @updated_AC_partner_AC_with_ONG_currently_ChangedAt = 1 THEN i.AC_partner_AC_with_ONG_currently_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing
    WHERE
        i.AC_partner_AC_with_ONG_currently_ID is not null
    AND (
        i.AC_ID_partner is null
    OR
        i.AC_ID_with is null
    OR
        CASE WHEN @updated_currently_ONG_Ongoing = 1 THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        cast(CASE
            WHEN @updated_AC_partner_AC_with_ONG_currently_ChangedAt = 1 THEN i.AC_partner_AC_with_ONG_currently_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_partner_AC_with_ONG_currently_ID = i.AC_partner_AC_with_ONG_currently_ID
                AND
                    d.AC_ID_partner = i.AC_ID_partner
                AND
                    d.AC_ID_with = i.AC_ID_with
                AND
                    d.ONG_ID_currently = CASE WHEN @updated_currently_ONG_Ongoing = 1 THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END
            ) THEN i.AC_partner_AC_with_ONG_currently_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.AC_ID_partner,
        i.AC_ID_with,
        CASE WHEN @updated_currently_ONG_Ongoing = 1 THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END,
        cast(CASE WHEN @updated_AC_partner_AC_with_ONG_currently_PositedAt = 1 THEN i.AC_partner_AC_with_ONG_currently_PositedAt ELSE @now END as datetime2),
        ISNULL(i.AC_partner_AC_with_ONG_currently_Reliability, 1)
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing
    WHERE
        i.AC_ID_partner is not null
    AND
        i.AC_ID_with is not null
    AND
        CASE WHEN @updated_currently_ONG_Ongoing = 1 THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            @updated_AC_partner_AC_with_ONG_currently_ChangedAt = 1 OR
            @updated_AC_partner_AC_with_ONG_currently_PositedAt = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_partner_AC_with_ONG_currently_ID = i.AC_partner_AC_with_ONG_currently_ID
                AND
                    d.AC_ID_partner = i.AC_ID_partner
                AND
                    d.AC_ID_with = i.AC_ID_with
                AND
                    d.ONG_ID_currently = CASE WHEN @updated_currently_ONG_Ongoing = 1 THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END
                AND
                    d.AC_partner_AC_with_ONG_currently_Reliability = ISNULL(i.AC_partner_AC_with_ONG_currently_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_partner_AC_with_ONG_currently] ON [dbo].[lAC_partner_AC_with_ONG_currently]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently_Annex] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        d.Metadata_AC_partner_AC_with_ONG_currently,
        d.AC_partner_AC_with_ONG_currently_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_subset_PN_of instead of INSERT trigger on AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_subset_PN_of', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_subset_PN_of];
GO
CREATE TRIGGER [dbo].[it_AC_subset_PN_of] ON [dbo].[AC_subset_PN_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_AC_subset_PN_of int not null,
        AC_subset_PN_of_StatementType char(1) not null,
        AC_subset_PN_of_PositedAt datetime2 not null,
        AC_subset_PN_of_Reliability decimal(5,2) not null,
        AC_ID_subset int not null,
        PN_ID_of int not null,
        primary key (
            AC_ID_subset asc,
            PN_ID_of asc,
            AC_subset_PN_of_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_subset,
            i.PN_ID_of,
            ISNULL(i.AC_subset_PN_of_PositedAt, @now) AS AC_subset_PN_of_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[AC_subset_PN_of_Posit] p
            JOIN
                [dbo].[AC_subset_PN_of_Annex] a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            WHERE
                p.AC_ID_subset = i.AC_ID_subset
            AND
                p.PN_ID_of = i.PN_ID_of
            AND
                a.AC_subset_PN_of_PositedAt = ISNULL(i.AC_subset_PN_of_PositedAt, @now)
            AND
                a.AC_subset_PN_of_Reliability <> ISNULL(i.AC_subset_PN_of_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_subset_PN_of for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_subset_PN_of, 0),
        CASE
            WHEN p.AC_subset_PN_of_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_subset_PN_of_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.AC_subset_PN_of_PositedAt, @now),
        ISNULL(i.AC_subset_PN_of_Reliability, 1),
        i.AC_ID_subset,
        i.PN_ID_of
    FROM
        inserted i
    LEFT JOIN
        [dbo].[AC_subset_PN_of_Posit] p
    ON
        p.AC_ID_subset = i.AC_ID_subset
    AND
        p.PN_ID_of = i.PN_ID_of
    LEFT JOIN
        [dbo].[AC_subset_PN_of_Annex] a
    ON
        a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
    AND
        a.AC_subset_PN_of_PositedAt = i.AC_subset_PN_of_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_subset_PN_of_ID is null OR a.AC_subset_PN_of_ID is null)
    AND
        i.AC_ID_subset is not null
    AND
        i.PN_ID_of is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_AC_subset_PN_of,
        'X', -- existing data
        x.AC_subset_PN_of_PositedAt,
        x.AC_subset_PN_of_Reliability,
        x.AC_ID_subset,
        x.PN_ID_of
    FROM (
        SELECT
            a.Metadata_AC_subset_PN_of,
            a.AC_subset_PN_of_PositedAt,
            a.AC_subset_PN_of_Reliability,
            p.AC_ID_subset,
            p.PN_ID_of,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.AC_ID_subset,
                    p.PN_ID_of,
                    a.AC_subset_PN_of_PositedAt
                ORDER BY
                    a.AC_subset_PN_of_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                AC_ID_subset,
                PN_ID_of
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[AC_subset_PN_of_Posit] p
        ON
            p.AC_ID_subset = i.AC_ID_subset
        AND
            p.PN_ID_of = i.PN_ID_of
        JOIN
            [dbo].[AC_subset_PN_of_Annex] a
        ON
            a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.AC_ID_subset = x.AC_ID_subset
        AND
            n.PN_ID_of = x.PN_ID_of
        AND
            n.AC_subset_PN_of_PositedAt = x.AC_subset_PN_of_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_AC_subset_PN_of int not null,
        AC_subset_PN_of_StatementType char(1) not null,
        AC_subset_PN_of_PositedAt datetime2 not null,
        AC_subset_PN_of_Reliability decimal(5,2) not null,
        AC_ID_subset int not null,
        PN_ID_of int not null
    );
    INSERT INTO @retracted (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_StatementType,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability,
        AC_ID_subset,
        PN_ID_of
    )
    SELECT
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_StatementType,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability,
        AC_ID_subset,
        PN_ID_of
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_subset_PN_of_Reliability as previous_AC_subset_PN_of_Reliability,
            fol.AC_subset_PN_of_Reliability as following_AC_subset_PN_of_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_subset_PN_of_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_subset = a.AC_ID_subset
            AND
                p.PN_ID_of = a.PN_ID_of
            AND
                p.AC_subset_PN_of_PositedAt < a.AC_subset_PN_of_PositedAt
            ORDER BY
                p.AC_subset_PN_of_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_subset_PN_of_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_subset = a.AC_ID_subset
            AND
                p.PN_ID_of = a.PN_ID_of
            AND
                p.AC_subset_PN_of_PositedAt > a.AC_subset_PN_of_PositedAt
            ORDER BY
                p.AC_subset_PN_of_PositedAt ASC
        ) fol
        WHERE
            (a.AC_subset_PN_of_Reliability = 0 AND isnull(pre.AC_subset_PN_of_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_subset_PN_of_Reliability = 1 AND fol.AC_subset_PN_of_Reliability = 0)
    ) i
    WHERE
        i.AC_subset_PN_of_StatementType <> 'X'
    AND (
            (i.AC_subset_PN_of_Reliability = 0 AND i.previous_AC_subset_PN_of_Reliability = 1)
        OR
            (i.AC_subset_PN_of_Reliability = 1 AND i.following_AC_subset_PN_of_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[AC_subset_PN_of_Posit] (
        AC_ID_subset,
        PN_ID_of
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        AC_ID_subset,
        PN_ID_of
    FROM
        @inserted
    WHERE
        AC_subset_PN_of_StatementType = 'P';
    INSERT INTO [dbo].[AC_subset_PN_of_Annex] (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        v.Metadata_AC_subset_PN_of,
        p.AC_subset_PN_of_ID,
        v.AC_subset_PN_of_PositedAt,
        v.AC_subset_PN_of_Reliability
    FROM
        @inserted v
    JOIN
        [dbo].[AC_subset_PN_of_Posit] p
    ON
        p.AC_ID_subset = v.AC_ID_subset
    AND
        p.PN_ID_of = v.PN_ID_of
    WHERE
        v.AC_subset_PN_of_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_subset_PN_of] ON [dbo].[lAC_subset_PN_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_subset_PN_of] (
        Metadata_AC_subset_PN_of,
        AC_ID_subset,
        PN_ID_of,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_ID_subset,
        i.PN_ID_of,
        i.AC_subset_PN_of_PositedAt,
        i.AC_subset_PN_of_Reliability
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_subset_PN_of] ON [dbo].[lAC_subset_PN_of]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_AC_subset_PN_of_PositedAt bit = CASE WHEN UPDATE(AC_subset_PN_of_PositedAt) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_subset_PN_of_ID))
        RAISERROR('The identity column AC_subset_PN_of_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[AC_subset_PN_of_Annex] (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_subset_PN_of_ID,
        cast(ISNULL(CASE
            WHEN @updated_AC_subset_PN_of_PositedAt = 1 THEN i.AC_subset_PN_of_PositedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    WHERE
        i.AC_subset_PN_of_ID is not null
    AND (
        i.AC_ID_subset is null
    OR
        i.PN_ID_of is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[AC_subset_PN_of] (
        Metadata_AC_subset_PN_of,
        AC_ID_subset,
        PN_ID_of,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_ID_subset,
        i.PN_ID_of,
        cast(CASE WHEN @updated_AC_subset_PN_of_PositedAt = 1 THEN i.AC_subset_PN_of_PositedAt ELSE @now END as datetime2),
        ISNULL(i.AC_subset_PN_of_Reliability, 1)
    FROM
        inserted i
    WHERE
        i.AC_ID_subset is not null
    AND
        i.PN_ID_of is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            @updated_AC_subset_PN_of_PositedAt = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_subset_PN_of_ID = i.AC_subset_PN_of_ID
                AND
                    d.AC_ID_subset = i.AC_ID_subset
                AND
                    d.PN_ID_of = i.PN_ID_of
                AND
                    d.AC_subset_PN_of_Reliability = ISNULL(i.AC_subset_PN_of_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_subset_PN_of] ON [dbo].[lAC_subset_PN_of]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_subset_PN_of_Annex] (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        d.Metadata_AC_subset_PN_of,
        d.AC_subset_PN_of_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itEV_in_AC_wasCast instead of INSERT trigger on EV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_in_AC_wasCast', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_in_AC_wasCast];
GO
CREATE TRIGGER [dbo].[it_EV_in_AC_wasCast] ON [dbo].[EV_in_AC_wasCast]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_EV_in_AC_wasCast int not null,
        EV_in_AC_wasCast_StatementType char(1) not null,
        EV_in_AC_wasCast_PositedAt datetime2 not null,
        EV_in_AC_wasCast_Reliability decimal(5,2) not null,
        EV_ID_in int not null,
        AC_ID_wasCast int not null,
        primary key (
            EV_ID_in asc,
            AC_ID_wasCast asc,
            EV_in_AC_wasCast_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_ID_in,
            i.AC_ID_wasCast,
            ISNULL(i.EV_in_AC_wasCast_PositedAt, @now) AS EV_in_AC_wasCast_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_in_AC_wasCast_Posit] p
            JOIN
                [dbo].[EV_in_AC_wasCast_Annex] a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            WHERE
                p.EV_ID_in = i.EV_ID_in
            AND
                p.AC_ID_wasCast = i.AC_ID_wasCast
            AND
                a.EV_in_AC_wasCast_PositedAt = ISNULL(i.EV_in_AC_wasCast_PositedAt, @now)
            AND
                a.EV_in_AC_wasCast_Reliability <> ISNULL(i.EV_in_AC_wasCast_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_in_AC_wasCast for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_EV_in_AC_wasCast, 0),
        CASE
            WHEN p.EV_in_AC_wasCast_ID is null
            THEN 'P' -- new posit
            WHEN a.EV_in_AC_wasCast_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.EV_in_AC_wasCast_PositedAt, @now),
        ISNULL(i.EV_in_AC_wasCast_Reliability, 1),
        i.EV_ID_in,
        i.AC_ID_wasCast
    FROM
        inserted i
    LEFT JOIN
        [dbo].[EV_in_AC_wasCast_Posit] p
    ON
        p.EV_ID_in = i.EV_ID_in
    AND
        p.AC_ID_wasCast = i.AC_ID_wasCast
    LEFT JOIN
        [dbo].[EV_in_AC_wasCast_Annex] a
    ON
        a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
    AND
        a.EV_in_AC_wasCast_PositedAt = i.EV_in_AC_wasCast_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_in_AC_wasCast_ID is null OR a.EV_in_AC_wasCast_ID is null)
    AND
        i.EV_ID_in is not null
    AND
        i.AC_ID_wasCast is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_EV_in_AC_wasCast,
        'X', -- existing data
        x.EV_in_AC_wasCast_PositedAt,
        x.EV_in_AC_wasCast_Reliability,
        x.EV_ID_in,
        x.AC_ID_wasCast
    FROM (
        SELECT
            a.Metadata_EV_in_AC_wasCast,
            a.EV_in_AC_wasCast_PositedAt,
            a.EV_in_AC_wasCast_Reliability,
            p.EV_ID_in,
            p.AC_ID_wasCast,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.EV_ID_in,
                    p.AC_ID_wasCast,
                    a.EV_in_AC_wasCast_PositedAt
                ORDER BY
                    a.EV_in_AC_wasCast_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                EV_ID_in,
                AC_ID_wasCast
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[EV_in_AC_wasCast_Posit] p
        ON
            p.EV_ID_in = i.EV_ID_in
        AND
            p.AC_ID_wasCast = i.AC_ID_wasCast
        JOIN
            [dbo].[EV_in_AC_wasCast_Annex] a
        ON
            a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.EV_ID_in = x.EV_ID_in
        AND
            n.AC_ID_wasCast = x.AC_ID_wasCast
        AND
            n.EV_in_AC_wasCast_PositedAt = x.EV_in_AC_wasCast_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_EV_in_AC_wasCast int not null,
        EV_in_AC_wasCast_StatementType char(1) not null,
        EV_in_AC_wasCast_PositedAt datetime2 not null,
        EV_in_AC_wasCast_Reliability decimal(5,2) not null,
        EV_ID_in int not null,
        AC_ID_wasCast int not null
    );
    INSERT INTO @retracted (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_StatementType,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability,
        EV_ID_in,
        AC_ID_wasCast
    )
    SELECT
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_StatementType,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability,
        EV_ID_in,
        AC_ID_wasCast
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.EV_in_AC_wasCast_Reliability as previous_EV_in_AC_wasCast_Reliability,
            fol.EV_in_AC_wasCast_Reliability as following_EV_in_AC_wasCast_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_in_AC_wasCast_Reliability
            FROM
                @inserted p
            WHERE
                p.EV_ID_in = a.EV_ID_in
            AND
                p.AC_ID_wasCast = a.AC_ID_wasCast
            AND
                p.EV_in_AC_wasCast_PositedAt < a.EV_in_AC_wasCast_PositedAt
            ORDER BY
                p.EV_in_AC_wasCast_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_in_AC_wasCast_Reliability
            FROM
                @inserted p
            WHERE
                p.EV_ID_in = a.EV_ID_in
            AND
                p.AC_ID_wasCast = a.AC_ID_wasCast
            AND
                p.EV_in_AC_wasCast_PositedAt > a.EV_in_AC_wasCast_PositedAt
            ORDER BY
                p.EV_in_AC_wasCast_PositedAt ASC
        ) fol
        WHERE
            (a.EV_in_AC_wasCast_Reliability = 0 AND isnull(pre.EV_in_AC_wasCast_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.EV_in_AC_wasCast_Reliability = 1 AND fol.EV_in_AC_wasCast_Reliability = 0)
    ) i
    WHERE
        i.EV_in_AC_wasCast_StatementType <> 'X'
    AND (
            (i.EV_in_AC_wasCast_Reliability = 0 AND i.previous_EV_in_AC_wasCast_Reliability = 1)
        OR
            (i.EV_in_AC_wasCast_Reliability = 1 AND i.following_EV_in_AC_wasCast_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[EV_in_AC_wasCast_Posit] (
        EV_ID_in,
        AC_ID_wasCast
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        EV_ID_in,
        AC_ID_wasCast
    FROM
        @inserted
    WHERE
        EV_in_AC_wasCast_StatementType = 'P';
    INSERT INTO [dbo].[EV_in_AC_wasCast_Annex] (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    SELECT
        v.Metadata_EV_in_AC_wasCast,
        p.EV_in_AC_wasCast_ID,
        v.EV_in_AC_wasCast_PositedAt,
        v.EV_in_AC_wasCast_Reliability
    FROM
        @inserted v
    JOIN
        [dbo].[EV_in_AC_wasCast_Posit] p
    ON
        p.EV_ID_in = v.EV_ID_in
    AND
        p.AC_ID_wasCast = v.AC_ID_wasCast
    WHERE
        v.EV_in_AC_wasCast_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lEV_in_AC_wasCast] ON [dbo].[lEV_in_AC_wasCast]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[EV_in_AC_wasCast] (
        Metadata_EV_in_AC_wasCast,
        EV_ID_in,
        AC_ID_wasCast,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    SELECT
        i.Metadata_EV_in_AC_wasCast,
        i.EV_ID_in,
        i.AC_ID_wasCast,
        i.EV_in_AC_wasCast_PositedAt,
        i.EV_in_AC_wasCast_Reliability
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lEV_in_AC_wasCast] ON [dbo].[lEV_in_AC_wasCast]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[EV_in_AC_wasCast_Annex] (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    SELECT
        d.Metadata_EV_in_AC_wasCast,
        d.EV_in_AC_wasCast_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_part_PR_in_RAT_got instead of INSERT trigger on AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_part_PR_in_RAT_got', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_part_PR_in_RAT_got];
GO
CREATE TRIGGER [dbo].[it_AC_part_PR_in_RAT_got] ON [dbo].[AC_part_PR_in_RAT_got]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_AC_part_PR_in_RAT_got int not null,
        AC_part_PR_in_RAT_got_StatementType char(1) not null,
        AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
        AC_part_PR_in_RAT_got_PositedAt datetime2 not null,
        AC_part_PR_in_RAT_got_Reliability decimal(5,2) not null,
        AC_ID_part int not null,
        PR_ID_in int not null,
        RAT_ID_got tinyint not null,
        primary key (
            AC_ID_part asc,
            PR_ID_in asc,
            AC_part_PR_in_RAT_got_ChangedAt desc,
            AC_part_PR_in_RAT_got_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_part,
            i.PR_ID_in,
            i.RAT_ID_got,
            ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now) AS AC_part_PR_in_RAT_got_ChangedAt,
            ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now) AS AC_part_PR_in_RAT_got_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[AC_part_PR_in_RAT_got_Posit] p
            JOIN
                [dbo].[AC_part_PR_in_RAT_got_Annex] a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            WHERE
                p.AC_ID_part = i.AC_ID_part
            AND
                p.PR_ID_in = i.PR_ID_in
            AND
                p.RAT_ID_got = i.RAT_ID_got
            AND
                p.AC_part_PR_in_RAT_got_ChangedAt = ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now)
            AND
                a.AC_part_PR_in_RAT_got_PositedAt = ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now)
            AND
                a.AC_part_PR_in_RAT_got_Reliability <> ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1)
        )
        -- and so, since one posit at a time is asserted for the identifiers, is an assertion of other values at that time
        OR (
            ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1) = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[AC_part_PR_in_RAT_got_Posit] p
                JOIN
                    [dbo].[AC_part_PR_in_RAT_got_Annex] a
                ON
                    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
                WHERE
                    p.AC_ID_part = i.AC_ID_part
                AND
                    p.PR_ID_in = i.PR_ID_in
                AND
                    p.AC_part_PR_in_RAT_got_ChangedAt = ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now)
                AND
                    (
                        p.RAT_ID_got <> i.RAT_ID_got
                    )
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now)
                AND
                    a.AC_part_PR_in_RAT_got_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.AC_ID_part = i.AC_ID_part
                AND
                    j.PR_ID_in = i.PR_ID_in
                AND
                    ISNULL(j.AC_part_PR_in_RAT_got_ChangedAt, @now) = ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now)
                AND
                    (
                        j.RAT_ID_got <> i.RAT_ID_got
                    )
                AND
                    ISNULL(j.AC_part_PR_in_RAT_got_PositedAt, @now) = ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now)
                AND
                    ISNULL(j.AC_part_PR_in_RAT_got_Reliability, 1) = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_part_PR_in_RAT_got for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_part_PR_in_RAT_got, 0),
        CASE
            WHEN p.AC_part_PR_in_RAT_got_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_part_PR_in_RAT_got_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now),
        ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now),
        ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1),
        i.AC_ID_part,
        i.PR_ID_in,
        i.RAT_ID_got
    FROM
        inserted i
    LEFT JOIN
        [dbo].[AC_part_PR_in_RAT_got_Posit] p
    ON
        p.AC_ID_part = i.AC_ID_part
    AND
        p.PR_ID_in = i.PR_ID_in
    AND
        p.RAT_ID_got = i.RAT_ID_got
    AND
        p.AC_part_PR_in_RAT_got_ChangedAt = i.AC_part_PR_in_RAT_got_ChangedAt
    LEFT JOIN
        [dbo].[AC_part_PR_in_RAT_got_Annex] a
    ON
        a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    AND
        a.AC_part_PR_in_RAT_got_PositedAt = i.AC_part_PR_in_RAT_got_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_part_PR_in_RAT_got_ID is null OR a.AC_part_PR_in_RAT_got_ID is null)
    AND
        i.AC_ID_part is not null
    AND
        i.PR_ID_in is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_AC_part_PR_in_RAT_got,
        'X', -- existing data
        x.AC_part_PR_in_RAT_got_ChangedAt,
        x.AC_part_PR_in_RAT_got_PositedAt,
        x.AC_part_PR_in_RAT_got_Reliability,
        x.AC_ID_part,
        x.PR_ID_in,
        x.RAT_ID_got
    FROM (
        SELECT
            a.Metadata_AC_part_PR_in_RAT_got,
            p.AC_part_PR_in_RAT_got_ChangedAt,
            a.AC_part_PR_in_RAT_got_PositedAt,
            a.AC_part_PR_in_RAT_got_Reliability,
            p.AC_ID_part,
            p.PR_ID_in,
            p.RAT_ID_got,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.AC_ID_part,
                    p.PR_ID_in,
                    p.AC_part_PR_in_RAT_got_ChangedAt,
                    a.AC_part_PR_in_RAT_got_PositedAt
                ORDER BY
                    a.AC_part_PR_in_RAT_got_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                AC_ID_part,
                PR_ID_in
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[AC_part_PR_in_RAT_got_Posit] p
        ON
            p.AC_ID_part = i.AC_ID_part
        AND
            p.PR_ID_in = i.PR_ID_in
        JOIN
            [dbo].[AC_part_PR_in_RAT_got_Annex] a
        ON
            a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.AC_ID_part = x.AC_ID_part
        AND
            n.PR_ID_in = x.PR_ID_in
        AND
            n.AC_part_PR_in_RAT_got_ChangedAt = x.AC_part_PR_in_RAT_got_ChangedAt
        AND
            n.AC_part_PR_in_RAT_got_PositedAt = x.AC_part_PR_in_RAT_got_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_AC_part_PR_in_RAT_got int not null,
        AC_part_PR_in_RAT_got_StatementType char(1) not null,
        AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
        AC_part_PR_in_RAT_got_PositedAt datetime2 not null,
        AC_part_PR_in_RAT_got_Reliability decimal(5,2) not null,
        AC_ID_part int not null,
        PR_ID_in int not null,
        RAT_ID_got tinyint not null
    );
    INSERT INTO @retracted (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_StatementType,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    SELECT
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_StatementType,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_part_PR_in_RAT_got_Reliability as previous_AC_part_PR_in_RAT_got_Reliability,
            fol.AC_part_PR_in_RAT_got_Reliability as following_AC_part_PR_in_RAT_got_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_part_PR_in_RAT_got_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_part = a.AC_ID_part
            AND
                p.PR_ID_in = a.PR_ID_in
            AND
                p.AC_part_PR_in_RAT_got_ChangedAt = a.AC_part_PR_in_RAT_got_ChangedAt
            AND
                p.AC_part_PR_in_RAT_got_PositedAt < a.AC_part_PR_in_RAT_got_PositedAt
            ORDER BY
                p.AC_part_PR_in_RAT_got_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_part_PR_in_RAT_got_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_part = a.AC_ID_part
            AND
                p.PR_ID_in = a.PR_ID_in
            AND
                p.AC_part_PR_in_RAT_got_ChangedAt = a.AC_part_PR_in_RAT_got_ChangedAt
            AND
                p.AC_part_PR_in_RAT_got_PositedAt > a.AC_part_PR_in_RAT_got_PositedAt
            ORDER BY
                p.AC_part_PR_in_RAT_got_PositedAt ASC
        ) fol
        WHERE
            (a.AC_part_PR_in_RAT_got_Reliability = 0 AND isnull(pre.AC_part_PR_in_RAT_got_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_part_PR_in_RAT_got_Reliability = 1 AND fol.AC_part_PR_in_RAT_got_Reliability = 0)
    ) i
    WHERE
        i.AC_part_PR_in_RAT_got_StatementType <> 'X'
    AND (
            (i.AC_part_PR_in_RAT_got_Reliability = 0 AND i.previous_AC_part_PR_in_RAT_got_Reliability = 1)
        OR
            (i.AC_part_PR_in_RAT_got_Reliability = 1 AND i.following_AC_part_PR_in_RAT_got_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got_Posit] (
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    FROM
        @inserted
    WHERE
        AC_part_PR_in_RAT_got_StatementType = 'P';
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got_Annex] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        v.Metadata_AC_part_PR_in_RAT_got,
        p.AC_part_PR_in_RAT_got_ID,
        v.AC_part_PR_in_RAT_got_PositedAt,
        v.AC_part_PR_in_RAT_got_Reliability
    FROM
        @inserted v
    JOIN
        [dbo].[AC_part_PR_in_RAT_got_Posit] p
    ON
        p.AC_ID_part = v.AC_ID_part
    AND
        p.PR_ID_in = v.PR_ID_in
    AND
        p.RAT_ID_got = v.RAT_ID_got
    AND
        p.AC_part_PR_in_RAT_got_ChangedAt = v.AC_part_PR_in_RAT_got_ChangedAt
    WHERE
        v.AC_part_PR_in_RAT_got_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect for the identifiers at the same changing time when
    -- that has other values (a correction), so that one posit at a time is asserted; also when the assertion is a
    -- restatement that an idempotent tie skips
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got_Annex] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        v.Metadata_AC_part_PR_in_RAT_got,
        e.AC_part_PR_in_RAT_got_ID,
        v.AC_part_PR_in_RAT_got_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_AC_part_PR_in_RAT_got,
            n.AC_part_PR_in_RAT_got_ChangedAt,
            n.AC_part_PR_in_RAT_got_PositedAt,
            n.AC_ID_part,
            n.PR_ID_in,
            n.RAT_ID_got
        FROM
            @inserted n
        WHERE
            n.AC_part_PR_in_RAT_got_StatementType in ('P', 'A')
        AND
            n.AC_part_PR_in_RAT_got_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.AC_part_PR_in_RAT_got_ID,
            p.RAT_ID_got
        FROM
            [dbo].[AC_part_PR_in_RAT_got_Posit] p
        JOIN
            [dbo].[AC_part_PR_in_RAT_got_Annex] a
        ON
            a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
        AND
            a.AC_part_PR_in_RAT_got_PositedAt = (
                SELECT
                    max(s.AC_part_PR_in_RAT_got_PositedAt)
                FROM
                    [dbo].[AC_part_PR_in_RAT_got_Annex] s
                WHERE
                    s.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
                AND
                    s.AC_part_PR_in_RAT_got_PositedAt < v.AC_part_PR_in_RAT_got_PositedAt
            )
        WHERE
            p.AC_ID_part = v.AC_ID_part
        AND
            p.PR_ID_in = v.PR_ID_in
        AND
            p.AC_part_PR_in_RAT_got_ChangedAt = v.AC_part_PR_in_RAT_got_ChangedAt
        AND
            a.AC_part_PR_in_RAT_got_Reliability = 1
        ORDER BY
            a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) e
    WHERE (
        e.RAT_ID_got <> v.RAT_ID_got
    )
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_part_PR_in_RAT_got_Annex] x
        WHERE
            x.AC_part_PR_in_RAT_got_ID = e.AC_part_PR_in_RAT_got_ID
        AND
            x.AC_part_PR_in_RAT_got_PositedAt = v.AC_part_PR_in_RAT_got_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_part_PR_in_RAT_got] ON [dbo].[lAC_part_PR_in_RAT_got]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        i.AC_part_PR_in_RAT_got_ChangedAt,
        i.AC_ID_part,
        i.PR_ID_in,
        ISNULL(i.RAT_ID_got, [RAT_got].RAT_ID),
        i.AC_part_PR_in_RAT_got_PositedAt,
        i.AC_part_PR_in_RAT_got_Reliability
    FROM
        inserted i
    LEFT JOIN
        [dbo].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_part_PR_in_RAT_got] ON [dbo].[lAC_part_PR_in_RAT_got]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_AC_part_PR_in_RAT_got_PositedAt bit = CASE WHEN UPDATE(AC_part_PR_in_RAT_got_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_part_PR_in_RAT_got_ChangedAt bit = CASE WHEN UPDATE(AC_part_PR_in_RAT_got_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_got_RAT_Rating bit = CASE WHEN UPDATE(got_RAT_Rating) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_part_PR_in_RAT_got_ID))
        RAISERROR('The identity column AC_part_PR_in_RAT_got_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_ID_part))
        RAISERROR('The identity column AC_ID_part is not updatable.', 16, 1);
    IF(UPDATE(PR_ID_in))
        RAISERROR('The identity column PR_ID_in is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got_Annex] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        i.AC_part_PR_in_RAT_got_ID,
        cast(ISNULL(CASE
            WHEN @updated_AC_part_PR_in_RAT_got_PositedAt = 1 THEN i.AC_part_PR_in_RAT_got_PositedAt
            WHEN @updated_AC_part_PR_in_RAT_got_ChangedAt = 1 THEN i.AC_part_PR_in_RAT_got_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating
    WHERE
        i.AC_part_PR_in_RAT_got_ID is not null
    AND (
        CASE WHEN @updated_got_RAT_Rating = 1 THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        cast(CASE
            WHEN @updated_AC_part_PR_in_RAT_got_ChangedAt = 1 THEN i.AC_part_PR_in_RAT_got_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_part_PR_in_RAT_got_ID = i.AC_part_PR_in_RAT_got_ID
                AND
                    d.RAT_ID_got = CASE WHEN @updated_got_RAT_Rating = 1 THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END
            ) THEN i.AC_part_PR_in_RAT_got_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.AC_ID_part,
        i.PR_ID_in,
        CASE WHEN @updated_got_RAT_Rating = 1 THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END,
        cast(CASE WHEN @updated_AC_part_PR_in_RAT_got_PositedAt = 1 THEN i.AC_part_PR_in_RAT_got_PositedAt ELSE @now END as datetime2),
        ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1)
    FROM
        inserted i
    LEFT JOIN
        [dbo].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating
    WHERE
        CASE WHEN @updated_got_RAT_Rating = 1 THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            @updated_AC_part_PR_in_RAT_got_ChangedAt = 1 OR
            @updated_AC_part_PR_in_RAT_got_PositedAt = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_part_PR_in_RAT_got_ID = i.AC_part_PR_in_RAT_got_ID
                AND
                    d.RAT_ID_got = CASE WHEN @updated_got_RAT_Rating = 1 THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END
                AND
                    d.AC_part_PR_in_RAT_got_Reliability = ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_part_PR_in_RAT_got] ON [dbo].[lAC_part_PR_in_RAT_got]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got_Annex] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        d.Metadata_AC_part_PR_in_RAT_got,
        d.AC_part_PR_in_RAT_got_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itST_at_PR_isPlaying instead of INSERT trigger on ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_at_PR_isPlaying', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_at_PR_isPlaying];
GO
CREATE TRIGGER [dbo].[it_ST_at_PR_isPlaying] ON [dbo].[ST_at_PR_isPlaying]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_ST_at_PR_isPlaying int not null,
        ST_at_PR_isPlaying_StatementType char(1) not null,
        ST_at_PR_isPlaying_ChangedAt datetime2 not null,
        ST_at_PR_isPlaying_PositedAt datetime2 not null,
        ST_at_PR_isPlaying_Reliability decimal(5,2) not null,
        ST_ID_at int not null,
        PR_ID_isPlaying int not null,
        primary key (
            ST_ID_at asc,
            PR_ID_isPlaying asc,
            ST_at_PR_isPlaying_ChangedAt desc,
            ST_at_PR_isPlaying_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_ID_at,
            i.PR_ID_isPlaying,
            ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now) AS ST_at_PR_isPlaying_ChangedAt,
            ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now) AS ST_at_PR_isPlaying_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[ST_at_PR_isPlaying_Posit] p
            JOIN
                [dbo].[ST_at_PR_isPlaying_Annex] a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            WHERE
                p.ST_ID_at = i.ST_ID_at
            AND
                p.PR_ID_isPlaying = i.PR_ID_isPlaying
            AND
                p.ST_at_PR_isPlaying_ChangedAt = ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now)
            AND
                a.ST_at_PR_isPlaying_PositedAt = ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now)
            AND
                a.ST_at_PR_isPlaying_Reliability <> ISNULL(i.ST_at_PR_isPlaying_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_at_PR_isPlaying for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_ST_at_PR_isPlaying, 0),
        CASE
            WHEN p.ST_at_PR_isPlaying_ID is null
            THEN 'P' -- new posit
            WHEN a.ST_at_PR_isPlaying_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now),
        ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now),
        ISNULL(i.ST_at_PR_isPlaying_Reliability, 1),
        i.ST_ID_at,
        i.PR_ID_isPlaying
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ST_at_PR_isPlaying_Posit] p
    ON
        p.ST_ID_at = i.ST_ID_at
    AND
        p.PR_ID_isPlaying = i.PR_ID_isPlaying
    AND
        p.ST_at_PR_isPlaying_ChangedAt = i.ST_at_PR_isPlaying_ChangedAt
    LEFT JOIN
        [dbo].[ST_at_PR_isPlaying_Annex] a
    ON
        a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
    AND
        a.ST_at_PR_isPlaying_PositedAt = i.ST_at_PR_isPlaying_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_at_PR_isPlaying_ID is null OR a.ST_at_PR_isPlaying_ID is null)
    AND
        i.ST_ID_at is not null
    AND
        i.PR_ID_isPlaying is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_ST_at_PR_isPlaying,
        'X', -- existing data
        x.ST_at_PR_isPlaying_ChangedAt,
        x.ST_at_PR_isPlaying_PositedAt,
        x.ST_at_PR_isPlaying_Reliability,
        x.ST_ID_at,
        x.PR_ID_isPlaying
    FROM (
        SELECT
            a.Metadata_ST_at_PR_isPlaying,
            p.ST_at_PR_isPlaying_ChangedAt,
            a.ST_at_PR_isPlaying_PositedAt,
            a.ST_at_PR_isPlaying_Reliability,
            p.ST_ID_at,
            p.PR_ID_isPlaying,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.ST_ID_at,
                    p.PR_ID_isPlaying,
                    p.ST_at_PR_isPlaying_ChangedAt,
                    a.ST_at_PR_isPlaying_PositedAt
                ORDER BY
                    a.ST_at_PR_isPlaying_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                ST_ID_at,
                PR_ID_isPlaying
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[ST_at_PR_isPlaying_Posit] p
        ON
            p.ST_ID_at = i.ST_ID_at
        AND
            p.PR_ID_isPlaying = i.PR_ID_isPlaying
        JOIN
            [dbo].[ST_at_PR_isPlaying_Annex] a
        ON
            a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.ST_ID_at = x.ST_ID_at
        AND
            n.PR_ID_isPlaying = x.PR_ID_isPlaying
        AND
            n.ST_at_PR_isPlaying_ChangedAt = x.ST_at_PR_isPlaying_ChangedAt
        AND
            n.ST_at_PR_isPlaying_PositedAt = x.ST_at_PR_isPlaying_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_ST_at_PR_isPlaying int not null,
        ST_at_PR_isPlaying_StatementType char(1) not null,
        ST_at_PR_isPlaying_ChangedAt datetime2 not null,
        ST_at_PR_isPlaying_PositedAt datetime2 not null,
        ST_at_PR_isPlaying_Reliability decimal(5,2) not null,
        ST_ID_at int not null,
        PR_ID_isPlaying int not null
    );
    INSERT INTO @retracted (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_StatementType,
        ST_at_PR_isPlaying_ChangedAt,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability,
        ST_ID_at,
        PR_ID_isPlaying
    )
    SELECT
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_StatementType,
        ST_at_PR_isPlaying_ChangedAt,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability,
        ST_ID_at,
        PR_ID_isPlaying
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.ST_at_PR_isPlaying_Reliability as previous_ST_at_PR_isPlaying_Reliability,
            fol.ST_at_PR_isPlaying_Reliability as following_ST_at_PR_isPlaying_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.ST_at_PR_isPlaying_Reliability
            FROM
                @inserted p
            WHERE
                p.ST_ID_at = a.ST_ID_at
            AND
                p.PR_ID_isPlaying = a.PR_ID_isPlaying
            AND
                p.ST_at_PR_isPlaying_ChangedAt = a.ST_at_PR_isPlaying_ChangedAt
            AND
                p.ST_at_PR_isPlaying_PositedAt < a.ST_at_PR_isPlaying_PositedAt
            ORDER BY
                p.ST_at_PR_isPlaying_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.ST_at_PR_isPlaying_Reliability
            FROM
                @inserted p
            WHERE
                p.ST_ID_at = a.ST_ID_at
            AND
                p.PR_ID_isPlaying = a.PR_ID_isPlaying
            AND
                p.ST_at_PR_isPlaying_ChangedAt = a.ST_at_PR_isPlaying_ChangedAt
            AND
                p.ST_at_PR_isPlaying_PositedAt > a.ST_at_PR_isPlaying_PositedAt
            ORDER BY
                p.ST_at_PR_isPlaying_PositedAt ASC
        ) fol
        WHERE
            (a.ST_at_PR_isPlaying_Reliability = 0 AND isnull(pre.ST_at_PR_isPlaying_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.ST_at_PR_isPlaying_Reliability = 1 AND fol.ST_at_PR_isPlaying_Reliability = 0)
    ) i
    WHERE
        i.ST_at_PR_isPlaying_StatementType <> 'X'
    AND (
            (i.ST_at_PR_isPlaying_Reliability = 0 AND i.previous_ST_at_PR_isPlaying_Reliability = 1)
        OR
            (i.ST_at_PR_isPlaying_Reliability = 1 AND i.following_ST_at_PR_isPlaying_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[ST_at_PR_isPlaying_Posit] (
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    FROM
        @inserted
    WHERE
        ST_at_PR_isPlaying_StatementType = 'P';
    INSERT INTO [dbo].[ST_at_PR_isPlaying_Annex] (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    SELECT
        v.Metadata_ST_at_PR_isPlaying,
        p.ST_at_PR_isPlaying_ID,
        v.ST_at_PR_isPlaying_PositedAt,
        v.ST_at_PR_isPlaying_Reliability
    FROM
        @inserted v
    JOIN
        [dbo].[ST_at_PR_isPlaying_Posit] p
    ON
        p.ST_ID_at = v.ST_ID_at
    AND
        p.PR_ID_isPlaying = v.PR_ID_isPlaying
    AND
        p.ST_at_PR_isPlaying_ChangedAt = v.ST_at_PR_isPlaying_ChangedAt
    WHERE
        v.ST_at_PR_isPlaying_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lST_at_PR_isPlaying] ON [dbo].[lST_at_PR_isPlaying]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[ST_at_PR_isPlaying] (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    SELECT
        i.Metadata_ST_at_PR_isPlaying,
        i.ST_at_PR_isPlaying_ChangedAt,
        i.ST_ID_at,
        i.PR_ID_isPlaying,
        i.ST_at_PR_isPlaying_PositedAt,
        i.ST_at_PR_isPlaying_Reliability
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lST_at_PR_isPlaying] ON [dbo].[lST_at_PR_isPlaying]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[ST_at_PR_isPlaying_Annex] (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    SELECT
        d.Metadata_ST_at_PR_isPlaying,
        d.ST_at_PR_isPlaying_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_parent_AC_child_PAT_having instead of INSERT trigger on AC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_parent_AC_child_PAT_having', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_parent_AC_child_PAT_having];
GO
CREATE TRIGGER [dbo].[it_AC_parent_AC_child_PAT_having] ON [dbo].[AC_parent_AC_child_PAT_having]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_AC_parent_AC_child_PAT_having int not null,
        AC_parent_AC_child_PAT_having_StatementType char(1) not null,
        AC_parent_AC_child_PAT_having_PositedAt datetime2 not null,
        AC_parent_AC_child_PAT_having_Reliability decimal(5,2) not null,
        AC_ID_parent int not null,
        AC_ID_child int not null,
        PAT_ID_having tinyint not null,
        primary key (
            AC_ID_parent asc,
            AC_ID_child asc,
            PAT_ID_having asc,
            AC_parent_AC_child_PAT_having_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_parent,
            i.AC_ID_child,
            i.PAT_ID_having,
            ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now) AS AC_parent_AC_child_PAT_having_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[AC_parent_AC_child_PAT_having_Posit] p
            JOIN
                [dbo].[AC_parent_AC_child_PAT_having_Annex] a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            WHERE
                p.AC_ID_parent = i.AC_ID_parent
            AND
                p.AC_ID_child = i.AC_ID_child
            AND
                p.PAT_ID_having = i.PAT_ID_having
            AND
                a.AC_parent_AC_child_PAT_having_PositedAt = ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now)
            AND
                a.AC_parent_AC_child_PAT_having_Reliability <> ISNULL(i.AC_parent_AC_child_PAT_having_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_parent_AC_child_PAT_having for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_parent_AC_child_PAT_having, 0),
        CASE
            WHEN p.AC_parent_AC_child_PAT_having_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_parent_AC_child_PAT_having_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now),
        ISNULL(i.AC_parent_AC_child_PAT_having_Reliability, 1),
        i.AC_ID_parent,
        i.AC_ID_child,
        i.PAT_ID_having
    FROM
        inserted i
    LEFT JOIN
        [dbo].[AC_parent_AC_child_PAT_having_Posit] p
    ON
        p.AC_ID_parent = i.AC_ID_parent
    AND
        p.AC_ID_child = i.AC_ID_child
    AND
        p.PAT_ID_having = i.PAT_ID_having
    LEFT JOIN
        [dbo].[AC_parent_AC_child_PAT_having_Annex] a
    ON
        a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
    AND
        a.AC_parent_AC_child_PAT_having_PositedAt = i.AC_parent_AC_child_PAT_having_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_parent_AC_child_PAT_having_ID is null OR a.AC_parent_AC_child_PAT_having_ID is null)
    AND
        i.AC_ID_parent is not null
    AND
        i.AC_ID_child is not null
    AND
        i.PAT_ID_having is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_AC_parent_AC_child_PAT_having,
        'X', -- existing data
        x.AC_parent_AC_child_PAT_having_PositedAt,
        x.AC_parent_AC_child_PAT_having_Reliability,
        x.AC_ID_parent,
        x.AC_ID_child,
        x.PAT_ID_having
    FROM (
        SELECT
            a.Metadata_AC_parent_AC_child_PAT_having,
            a.AC_parent_AC_child_PAT_having_PositedAt,
            a.AC_parent_AC_child_PAT_having_Reliability,
            p.AC_ID_parent,
            p.AC_ID_child,
            p.PAT_ID_having,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.AC_ID_parent,
                    p.AC_ID_child,
                    p.PAT_ID_having,
                    a.AC_parent_AC_child_PAT_having_PositedAt
                ORDER BY
                    a.AC_parent_AC_child_PAT_having_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                AC_ID_parent,
                AC_ID_child,
                PAT_ID_having
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[AC_parent_AC_child_PAT_having_Posit] p
        ON
            p.AC_ID_parent = i.AC_ID_parent
        AND
            p.AC_ID_child = i.AC_ID_child
        AND
            p.PAT_ID_having = i.PAT_ID_having
        JOIN
            [dbo].[AC_parent_AC_child_PAT_having_Annex] a
        ON
            a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.AC_ID_parent = x.AC_ID_parent
        AND
            n.AC_ID_child = x.AC_ID_child
        AND
            n.PAT_ID_having = x.PAT_ID_having
        AND
            n.AC_parent_AC_child_PAT_having_PositedAt = x.AC_parent_AC_child_PAT_having_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_AC_parent_AC_child_PAT_having int not null,
        AC_parent_AC_child_PAT_having_StatementType char(1) not null,
        AC_parent_AC_child_PAT_having_PositedAt datetime2 not null,
        AC_parent_AC_child_PAT_having_Reliability decimal(5,2) not null,
        AC_ID_parent int not null,
        AC_ID_child int not null,
        PAT_ID_having tinyint not null
    );
    INSERT INTO @retracted (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_StatementType,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability,
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
    SELECT
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_StatementType,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability,
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_parent_AC_child_PAT_having_Reliability as previous_AC_parent_AC_child_PAT_having_Reliability,
            fol.AC_parent_AC_child_PAT_having_Reliability as following_AC_parent_AC_child_PAT_having_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_parent_AC_child_PAT_having_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_parent = a.AC_ID_parent
            AND
                p.AC_ID_child = a.AC_ID_child
            AND
                p.PAT_ID_having = a.PAT_ID_having
            AND
                p.AC_parent_AC_child_PAT_having_PositedAt < a.AC_parent_AC_child_PAT_having_PositedAt
            ORDER BY
                p.AC_parent_AC_child_PAT_having_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_parent_AC_child_PAT_having_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_parent = a.AC_ID_parent
            AND
                p.AC_ID_child = a.AC_ID_child
            AND
                p.PAT_ID_having = a.PAT_ID_having
            AND
                p.AC_parent_AC_child_PAT_having_PositedAt > a.AC_parent_AC_child_PAT_having_PositedAt
            ORDER BY
                p.AC_parent_AC_child_PAT_having_PositedAt ASC
        ) fol
        WHERE
            (a.AC_parent_AC_child_PAT_having_Reliability = 0 AND isnull(pre.AC_parent_AC_child_PAT_having_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_parent_AC_child_PAT_having_Reliability = 1 AND fol.AC_parent_AC_child_PAT_having_Reliability = 0)
    ) i
    WHERE
        i.AC_parent_AC_child_PAT_having_StatementType <> 'X'
    AND (
            (i.AC_parent_AC_child_PAT_having_Reliability = 0 AND i.previous_AC_parent_AC_child_PAT_having_Reliability = 1)
        OR
            (i.AC_parent_AC_child_PAT_having_Reliability = 1 AND i.following_AC_parent_AC_child_PAT_having_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[AC_parent_AC_child_PAT_having_Posit] (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    FROM
        @inserted
    WHERE
        AC_parent_AC_child_PAT_having_StatementType = 'P';
    INSERT INTO [dbo].[AC_parent_AC_child_PAT_having_Annex] (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    SELECT
        v.Metadata_AC_parent_AC_child_PAT_having,
        p.AC_parent_AC_child_PAT_having_ID,
        v.AC_parent_AC_child_PAT_having_PositedAt,
        v.AC_parent_AC_child_PAT_having_Reliability
    FROM
        @inserted v
    JOIN
        [dbo].[AC_parent_AC_child_PAT_having_Posit] p
    ON
        p.AC_ID_parent = v.AC_ID_parent
    AND
        p.AC_ID_child = v.AC_ID_child
    AND
        p.PAT_ID_having = v.PAT_ID_having
    WHERE
        v.AC_parent_AC_child_PAT_having_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_parent_AC_child_PAT_having] ON [dbo].[lAC_parent_AC_child_PAT_having]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_parent_AC_child_PAT_having] (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    SELECT
        i.Metadata_AC_parent_AC_child_PAT_having,
        i.AC_ID_parent,
        i.AC_ID_child,
        ISNULL(i.PAT_ID_having, [PAT_having].PAT_ID),
        i.AC_parent_AC_child_PAT_having_PositedAt,
        i.AC_parent_AC_child_PAT_having_Reliability
    FROM
        inserted i
    LEFT JOIN
        [dbo].[PAT_ParentalType] [PAT_having]
    ON
        [PAT_having].PAT_ParentalType = i.having_PAT_ParentalType;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_parent_AC_child_PAT_having] ON [dbo].[lAC_parent_AC_child_PAT_having]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_parent_AC_child_PAT_having_Annex] (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    SELECT
        d.Metadata_AC_parent_AC_child_PAT_having,
        d.AC_parent_AC_child_PAT_having_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itPR_content_ST_location_EV_of instead of INSERT trigger on PR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_PR_content_ST_location_EV_of', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PR_content_ST_location_EV_of];
GO
CREATE TRIGGER [dbo].[it_PR_content_ST_location_EV_of] ON [dbo].[PR_content_ST_location_EV_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_PR_content_ST_location_EV_of int not null,
        PR_content_ST_location_EV_of_StatementType char(1) not null,
        PR_content_ST_location_EV_of_PositedAt datetime2 not null,
        PR_content_ST_location_EV_of_Reliability decimal(5,2) not null,
        PR_ID_content int not null,
        ST_ID_location int not null,
        EV_ID_of int not null,
        primary key (
            EV_ID_of asc,
            PR_content_ST_location_EV_of_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_ID_content,
            i.ST_ID_location,
            i.EV_ID_of,
            ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now) AS PR_content_ST_location_EV_of_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[PR_content_ST_location_EV_of_Posit] p
            JOIN
                [dbo].[PR_content_ST_location_EV_of_Annex] a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            WHERE
                p.PR_ID_content = i.PR_ID_content
            AND
                p.ST_ID_location = i.ST_ID_location
            AND
                p.EV_ID_of = i.EV_ID_of
            AND
                a.PR_content_ST_location_EV_of_PositedAt = ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now)
            AND
                a.PR_content_ST_location_EV_of_Reliability <> ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1)
        )
        -- and so, since one posit at a time is asserted for the identifiers, is an assertion of other values at that time
        OR (
            ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1) = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[PR_content_ST_location_EV_of_Posit] p
                JOIN
                    [dbo].[PR_content_ST_location_EV_of_Annex] a
                ON
                    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
                WHERE
                    p.EV_ID_of = i.EV_ID_of
                AND
                    (
                        p.PR_ID_content <> i.PR_ID_content
                    OR
                        p.ST_ID_location <> i.ST_ID_location
                    )
                AND
                    a.PR_content_ST_location_EV_of_PositedAt = ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now)
                AND
                    a.PR_content_ST_location_EV_of_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.EV_ID_of = i.EV_ID_of
                AND
                    (
                        j.PR_ID_content <> i.PR_ID_content
                    OR
                        j.ST_ID_location <> i.ST_ID_location
                    )
                AND
                    ISNULL(j.PR_content_ST_location_EV_of_PositedAt, @now) = ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now)
                AND
                    ISNULL(j.PR_content_ST_location_EV_of_Reliability, 1) = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in PR_content_ST_location_EV_of for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_PR_content_ST_location_EV_of, 0),
        CASE
            WHEN p.PR_content_ST_location_EV_of_ID is null
            THEN 'P' -- new posit
            WHEN a.PR_content_ST_location_EV_of_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now),
        ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1),
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of
    FROM
        inserted i
    LEFT JOIN
        [dbo].[PR_content_ST_location_EV_of_Posit] p
    ON
        p.PR_ID_content = i.PR_ID_content
    AND
        p.ST_ID_location = i.ST_ID_location
    AND
        p.EV_ID_of = i.EV_ID_of
    LEFT JOIN
        [dbo].[PR_content_ST_location_EV_of_Annex] a
    ON
        a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    AND
        a.PR_content_ST_location_EV_of_PositedAt = i.PR_content_ST_location_EV_of_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.PR_content_ST_location_EV_of_ID is null OR a.PR_content_ST_location_EV_of_ID is null)
    AND
        i.EV_ID_of is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_PR_content_ST_location_EV_of,
        'X', -- existing data
        x.PR_content_ST_location_EV_of_PositedAt,
        x.PR_content_ST_location_EV_of_Reliability,
        x.PR_ID_content,
        x.ST_ID_location,
        x.EV_ID_of
    FROM (
        SELECT
            a.Metadata_PR_content_ST_location_EV_of,
            a.PR_content_ST_location_EV_of_PositedAt,
            a.PR_content_ST_location_EV_of_Reliability,
            p.PR_ID_content,
            p.ST_ID_location,
            p.EV_ID_of,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.EV_ID_of,
                    a.PR_content_ST_location_EV_of_PositedAt
                ORDER BY
                    a.PR_content_ST_location_EV_of_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                EV_ID_of
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[PR_content_ST_location_EV_of_Posit] p
        ON
            p.EV_ID_of = i.EV_ID_of
        JOIN
            [dbo].[PR_content_ST_location_EV_of_Annex] a
        ON
            a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.EV_ID_of = x.EV_ID_of
        AND
            n.PR_content_ST_location_EV_of_PositedAt = x.PR_content_ST_location_EV_of_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_PR_content_ST_location_EV_of int not null,
        PR_content_ST_location_EV_of_StatementType char(1) not null,
        PR_content_ST_location_EV_of_PositedAt datetime2 not null,
        PR_content_ST_location_EV_of_Reliability decimal(5,2) not null,
        PR_ID_content int not null,
        ST_ID_location int not null,
        EV_ID_of int not null
    );
    INSERT INTO @retracted (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_StatementType,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    SELECT
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_StatementType,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.PR_content_ST_location_EV_of_Reliability as previous_PR_content_ST_location_EV_of_Reliability,
            fol.PR_content_ST_location_EV_of_Reliability as following_PR_content_ST_location_EV_of_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.PR_content_ST_location_EV_of_Reliability
            FROM
                @inserted p
            WHERE
                p.EV_ID_of = a.EV_ID_of
            AND
                p.PR_content_ST_location_EV_of_PositedAt < a.PR_content_ST_location_EV_of_PositedAt
            ORDER BY
                p.PR_content_ST_location_EV_of_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.PR_content_ST_location_EV_of_Reliability
            FROM
                @inserted p
            WHERE
                p.EV_ID_of = a.EV_ID_of
            AND
                p.PR_content_ST_location_EV_of_PositedAt > a.PR_content_ST_location_EV_of_PositedAt
            ORDER BY
                p.PR_content_ST_location_EV_of_PositedAt ASC
        ) fol
        WHERE
            (a.PR_content_ST_location_EV_of_Reliability = 0 AND isnull(pre.PR_content_ST_location_EV_of_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.PR_content_ST_location_EV_of_Reliability = 1 AND fol.PR_content_ST_location_EV_of_Reliability = 0)
    ) i
    WHERE
        i.PR_content_ST_location_EV_of_StatementType <> 'X'
    AND (
            (i.PR_content_ST_location_EV_of_Reliability = 0 AND i.previous_PR_content_ST_location_EV_of_Reliability = 1)
        OR
            (i.PR_content_ST_location_EV_of_Reliability = 1 AND i.following_PR_content_ST_location_EV_of_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[PR_content_ST_location_EV_of_Posit] (
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    FROM
        @inserted
    WHERE
        PR_content_ST_location_EV_of_StatementType = 'P';
    INSERT INTO [dbo].[PR_content_ST_location_EV_of_Annex] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        v.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ID,
        v.PR_content_ST_location_EV_of_PositedAt,
        v.PR_content_ST_location_EV_of_Reliability
    FROM
        @inserted v
    JOIN
        [dbo].[PR_content_ST_location_EV_of_Posit] p
    ON
        p.PR_ID_content = v.PR_ID_content
    AND
        p.ST_ID_location = v.ST_ID_location
    AND
        p.EV_ID_of = v.EV_ID_of
    WHERE
        v.PR_content_ST_location_EV_of_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect for the identifiers when
    -- that has other values (a correction), so that one posit at a time is asserted; also when the assertion is a
    -- restatement that an idempotent tie skips
    INSERT INTO [dbo].[PR_content_ST_location_EV_of_Annex] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        v.Metadata_PR_content_ST_location_EV_of,
        e.PR_content_ST_location_EV_of_ID,
        v.PR_content_ST_location_EV_of_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_PR_content_ST_location_EV_of,
            n.PR_content_ST_location_EV_of_PositedAt,
            n.PR_ID_content,
            n.ST_ID_location,
            n.EV_ID_of
        FROM
            @inserted n
        WHERE
            n.PR_content_ST_location_EV_of_StatementType in ('P', 'A')
        AND
            n.PR_content_ST_location_EV_of_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.PR_content_ST_location_EV_of_ID,
            p.PR_ID_content,
            p.ST_ID_location
        FROM
            [dbo].[PR_content_ST_location_EV_of_Posit] p
        JOIN
            [dbo].[PR_content_ST_location_EV_of_Annex] a
        ON
            a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
        AND
            a.PR_content_ST_location_EV_of_PositedAt = (
                SELECT
                    max(s.PR_content_ST_location_EV_of_PositedAt)
                FROM
                    [dbo].[PR_content_ST_location_EV_of_Annex] s
                WHERE
                    s.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
                AND
                    s.PR_content_ST_location_EV_of_PositedAt < v.PR_content_ST_location_EV_of_PositedAt
            )
        WHERE
            p.EV_ID_of = v.EV_ID_of
        AND
            a.PR_content_ST_location_EV_of_Reliability = 1
        ORDER BY
            a.PR_content_ST_location_EV_of_PositedAt DESC
    ) e
    WHERE (
        e.PR_ID_content <> v.PR_ID_content
    OR
        e.ST_ID_location <> v.ST_ID_location
    )
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[PR_content_ST_location_EV_of_Annex] x
        WHERE
            x.PR_content_ST_location_EV_of_ID = e.PR_content_ST_location_EV_of_ID
        AND
            x.PR_content_ST_location_EV_of_PositedAt = v.PR_content_ST_location_EV_of_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPR_content_ST_location_EV_of] ON [dbo].[lPR_content_ST_location_EV_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PR_content_ST_location_EV_of] (
        Metadata_PR_content_ST_location_EV_of,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of,
        i.PR_content_ST_location_EV_of_PositedAt,
        i.PR_content_ST_location_EV_of_Reliability
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_content_ST_location_EV_of instead of UPDATE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lPR_content_ST_location_EV_of] ON [dbo].[lPR_content_ST_location_EV_of]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_PR_content_ST_location_EV_of_PositedAt bit = CASE WHEN UPDATE(PR_content_ST_location_EV_of_PositedAt) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_content_ST_location_EV_of_ID))
        RAISERROR('The identity column PR_content_ST_location_EV_of_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID_of))
        RAISERROR('The identity column EV_ID_of is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[PR_content_ST_location_EV_of_Annex] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        i.PR_content_ST_location_EV_of_ID,
        cast(ISNULL(CASE
            WHEN @updated_PR_content_ST_location_EV_of_PositedAt = 1 THEN i.PR_content_ST_location_EV_of_PositedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    WHERE
        i.PR_content_ST_location_EV_of_ID is not null
    AND (
        i.PR_ID_content is null
    OR
        i.ST_ID_location is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[PR_content_ST_location_EV_of] (
        Metadata_PR_content_ST_location_EV_of,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of,
        cast(CASE WHEN @updated_PR_content_ST_location_EV_of_PositedAt = 1 THEN i.PR_content_ST_location_EV_of_PositedAt ELSE @now END as datetime2),
        ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1)
    FROM
        inserted i
    WHERE
        i.PR_ID_content is not null
    AND
        i.ST_ID_location is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            @updated_PR_content_ST_location_EV_of_PositedAt = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.PR_content_ST_location_EV_of_ID = i.PR_content_ST_location_EV_of_ID
                AND
                    d.PR_ID_content = i.PR_ID_content
                AND
                    d.ST_ID_location = i.ST_ID_location
                AND
                    d.PR_content_ST_location_EV_of_Reliability = ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPR_content_ST_location_EV_of] ON [dbo].[lPR_content_ST_location_EV_of]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PR_content_ST_location_EV_of_Annex] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        d.Metadata_PR_content_ST_location_EV_of,
        d.PR_content_ST_location_EV_of_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- SCHEMA EVOLUTION ---------------------------------------------------------------------------------------------------
--
-- The following tables, views, and functions are used to track schema changes
-- over time, as well as providing every XML that has been 'executed' against
-- the database.
--
-- Schema table -------------------------------------------------------------------------------------------------------
-- The schema table holds every xml that has been executed against the database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Schema', 'U') IS NULL
   CREATE TABLE [dbo].[_Schema] (
      [version] int identity(1, 1) not null,
      [activation] datetime2 not null,
      [schema] xml not null,
      constraint pk_Schema primary key (
         [version]
      )
   );
GO
-- Insert the XML schema (as of now)
INSERT INTO [dbo].[_Schema] (
   [activation],
   [schema]
)
SELECT
   current_timestamp,
   N'<schema format="0.101.3" date="2026-09-25" time="12:50:25">
<metadata changingRange="datetime2" encapsulation="dbo" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="true" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime2" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="decimal(5,2)" reliabilitySuffix="Reliability" defaultReliability="1" deleteReliability="0" assertionSuffix="Assertion" partitioning="false" entityIntegrity="true" restatability="true" idempotency="false" assertiveness="true" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="true" decisiveness="true" equivalence="true" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="bi" deletability="false" deletablePrefix="Deletable" deletionSuffix="Deleted" privacy="Ignore" checksum="false" triggers="true" knotAliases="false" naturalKeyAttributes="true" />
<description>
Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.
</description>
<knot mnemonic="PAT" descriptor="ParentalType" identity="tinyint" dataRange="nvarchar(42)">
<metadata capsule="dbo" generator="true" equivalent="true" />
<layout x="1168.03" y="97.52" fixed="false" />
<description>
Kind of parent-child relationship between two actors, such as biological or adoptive parent.
</description>
</knot>
<knot mnemonic="GEN" descriptor="Gender" identity="tinyint" dataRange="nvarchar(42)">
<metadata capsule="dbo" generator="false" equivalent="true" />
<layout x="1360.09" y="-59.78" fixed="false" />
<description>
Gender of an actor.
</description>
</knot>
<knot mnemonic="PLV" descriptor="ProfessionalLevel" identity="tinyint" dataRange="nvarchar(max)">
<metadata capsule="dbo" generator="false" checksum="true" equivalent="false" />
<layout x="1257.93" y="-12.47" fixed="false" />
<description>
Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.
</description>
</knot>
<knot mnemonic="UTL" descriptor="Utilization" identity="tinyint" dataRange="tinyint">
<metadata capsule="dbo" generator="false" equivalent="false" />
<layout x="973.86" y="899.86" fixed="false" />
<description>
Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.
</description>
</knot>
<knot mnemonic="ONG" descriptor="Ongoing" identity="tinyint" dataRange="nvarchar(3)">
<metadata capsule="dbo" generator="false" equivalent="true" />
<layout x="1575.55" y="191.32" fixed="false" />
<description>
Yes or No flag indicating whether a relationship is still ongoing or has ended.
</description>
</knot>
<knot mnemonic="RAT" descriptor="Rating" identity="tinyint" dataRange="nvarchar(42)">
<metadata capsule="dbo" generator="true" equivalent="true" />
<layout x="1310.90" y="402.62" fixed="false" />
<description>
Rating of how well an actor performs a part in a program, such as good, mediocre or bad.
</description>
</knot>
<knot mnemonic="ETY" descriptor="EventType" identity="tinyint" dataRange="nvarchar(42)">
<metadata capsule="dbo" generator="false" equivalent="false" />
<layout x="1314.96" y="557.45" fixed="false" />
<description>
Type of event, such as premiere, regular performance, rehearsal or gala.
</description>
</knot>
<anchor mnemonic="PN" descriptor="Person" identity="int">
<metadata capsule="dbo" generator="true" />
<layout x="1497.65" y="16.48" fixed="false" />
<description>
A person. Persons who perform are also registered as actors.
</description>
</anchor>
<anchor mnemonic="ST" descriptor="Stage" identity="int">
<metadata capsule="dbo" generator="true" />
<attribute mnemonic="NAM" descriptor="Name" identity="int" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" equivalent="true" generator="true" assertive="true" checksum="true" restatable="true" idempotent="false" deletable="false" />
<key stop="1" route="2nd" of="ST" branch="1" />
<layout x="1064.26" y="809.51" fixed="false" />
<description>
Name of the stage. Historized, since a stage may be renamed over time.
</description>
</attribute>
<attribute mnemonic="LOC" descriptor="Location" identity="int" dataRange="geography">
<metadata privacy="Ignore" capsule="dbo" equivalent="true" generator="true" assertive="true" checksum="true" idempotent="false" deletable="false" />
<key stop="1" route="1st" of="ST" branch="1" />
<key stop="3" route="1st" of="EV" branch="2" />
<layout x="1105.00" y="789.37" fixed="false" />
<description>
Geographic location of the stage as a geography point.
</description>
</attribute>
<attribute mnemonic="AVG" descriptor="Average" identity="int" timeRange="datetime2" knotRange="UTL">
<metadata privacy="Ignore" capsule="dbo" equivalent="false" generator="true" assertive="true" restatable="false" idempotent="true" deletable="false" />
<layout x="1014.22" y="830.84" fixed="false" />
<description>
Average utilization of the stage capacity, recalculated over time.
</description>
</attribute>
<attribute mnemonic="MIN" descriptor="Minimum" identity="int" knotRange="UTL">
<metadata privacy="Ignore" capsule="dbo" equivalent="false" generator="true" assertive="true" idempotent="false" deletable="true" />
<layout x="987.08" y="804.53" fixed="false" />
<description>
Minimum utilization of the stage capacity required for a performance to take place.
</description>
</attribute>
<identifier route="1st" identity="int">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" />
<layout x="1139.77" y="750.29" fixed="false" />
</identifier>
<identifier route="2nd" identity="int">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" />
<layout x="974.71" y="698.13" fixed="false" />
</identifier>
<layout x="1071.79" y="692.58" fixed="false" />
<description>
A stage or venue where programs are played and events are held.
</description>
</anchor>
<anchor mnemonic="AC" descriptor="Actor" identity="int">
<metadata capsule="dbo" generator="true" />
<attribute mnemonic="NAM" descriptor="Name" identity="int" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" equivalent="true" generator="true" assertive="true" checksum="true" restatable="false" idempotent="false" deletable="false" />
<key stop="1" route="1st" of="AC" branch="1" />
<layout x="1393.90" y="233.62" fixed="false" />
<description>
Name of the actor, such as a stage name. Historized, since it may change over time.
</description>
</attribute>
<attribute mnemonic="GEN" descriptor="Gender" identity="int" knotRange="GEN">
<metadata privacy="Ignore" capsule="dbo" equivalent="false" generator="true" assertive="true" idempotent="false" deletable="false" />
<layout x="1361.11" y="14.63" fixed="false" />
<description>
Gender of the actor.
</description>
</attribute>
<attribute mnemonic="PLV" descriptor="ProfessionalLevel" identity="int" timeRange="datetime2" knotRange="PLV">
<metadata privacy="Ignore" capsule="dbo" equivalent="false" generator="true" assertive="true" restatable="true" idempotent="false" deletable="false" />
<layout x="1297.57" y="31.67" fixed="false" />
<description>
Professional level of the actor, which may change as the actor gains experience.
</description>
</attribute>
<identifier route="1st" identity="int">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" />
<layout x="1318.04" y="201.65" fixed="false" />
</identifier>
<layout x="1350.10" y="167.06" fixed="false" />
<description>
An actor, a person who performs parts in programs and is cast in events.
</description>
</anchor>
<anchor mnemonic="PR" descriptor="Program" identity="int">
<metadata capsule="dbo" generator="true" />
<attribute mnemonic="NAM" descriptor="Name" identity="int" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" equivalent="false" generator="true" assertive="true" idempotent="false" deletable="false" />
<key stop="1" route="1st" of="PR" branch="1" />
<key stop="5" route="1st" of="EV" branch="3" />
<layout x="1041.15" y="438.50" fixed="false" />
<description>
Name or title of the program.
</description>
</attribute>
<attribute mnemonic="LEN" descriptor="Length" identity="int" timeRange="date" dataRange="time">
<metadata privacy="Ignore" capsule="dbo" equivalent="false" generator="true" assertive="true" restatable="true" idempotent="true" deletable="false" />
<layout x="1087.45" y="405.27" fixed="false" />
<description>
Running time of the program. Historized, since the program may be shortened or extended over time.
</description>
</attribute>
<identifier route="1st" identity="int">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" />
<layout x="1204.70" y="448.61" fixed="false" />
</identifier>
<layout x="1143.26" y="449.41" fixed="false" />
<description>
A program, such as a play, show or concert, that can be played on stages.
</description>
</anchor>
<nexus mnemonic="EV" descriptor="Event" identity="int">
<metadata capsule="dbo" generator="true" />
<attribute mnemonic="DAT" descriptor="Date" identity="int" dataRange="datetime2" chronicle="1">
<metadata privacy="Ignore" capsule="dbo" equivalent="true" generator="true" assertive="true" idempotent="false" deletable="false" />
<key stop="1" route="1st" of="EV" branch="1" />
<layout x="1282.10" y="598.26" fixed="false" />
<description>
Date and time when the event took place.
</description>
</attribute>
<attribute mnemonic="AUD" descriptor="Audience" identity="int" dataRange="int">
<metadata privacy="Ignore" capsule="dbo" equivalent="false" generator="true" assertive="true" idempotent="false" deletable="false" />
<layout x="1238.34" y="623.47" fixed="false" />
<description>
Number of people in the audience at the event.
</description>
</attribute>
<attribute mnemonic="REV" descriptor="Revenue" identity="int" dataRange="decimal(19,4)">
<metadata privacy="Ignore" capsule="dbo" equivalent="true" generator="true" assertive="true" idempotent="false" deletable="false" />
<layout x="1299.10" y="497.14" fixed="false" />
<description>
Revenue from ticket sales for the event.
</description>
</attribute>
<role role="wasHeldAt" type="ST" identifier="false">
<key stop="2" route="1st" of="EV" branch="2" />
<description>
The stage at which the event was held.
</description>
</role>
<role role="wasPlayed" type="PR" identifier="false">
<key stop="4" route="1st" of="EV" branch="3" />
<description>
The program that was played at the event.
</description>
</role>
<role role="of" type="ETY" identifier="false">
<description>
The type of the event.
</description>
</role>
<identifier route="1st" identity="int">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" />
<layout x="1256.71" y="494.49" fixed="false" />
</identifier>
<layout x="1214.10" y="539.35" fixed="false" />
<description>
An event, a single performance of a program held at a stage at a specific date and time.
</description>
</nexus>
<tie identity="int" timeRange="datetime2">
<role role="partner" type="AC" identifier="false">
<description>
One of the actors in the partnership.
</description>
</role>
<role role="with" type="AC" identifier="false">
<description>
The other actor in the partnership.
</description>
</role>
<role role="currently" type="ONG" identifier="false">
<description>
Whether the partnership is still ongoing (Yes) or has ended (No).
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="true" restatable="true" deletable="false" idempotent="false" />
<layout x="1483.31" y="185.10" fixed="false" />
<description>
Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.
</description>
</tie>
<tie identity="int">
<role role="subset" type="AC" identifier="false">
<description>
The actor.
</description>
</role>
<role role="of" type="PN" identifier="false">
<description>
The person who is the actor.
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="true" deletable="false" idempotent="false" />
<layout x="1445.29" y="77.24" fixed="false" />
<description>
Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.
</description>
</tie>
<tie identity="int">
<role role="in" type="EV" identifier="true">
<description>
The event the actor was cast in.
</description>
</role>
<role role="wasCast" type="AC" identifier="true">
<description>
An actor cast in the event.
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="true" deletable="false" idempotent="false" />
<layout x="1283.03" y="356.36" fixed="false" />
<description>
The actors that were cast in an event, meaning those who performed at that performance.
</description>
</tie>
<tie identity="int" timeRange="datetime2">
<role role="part" type="AC" identifier="true">
<description>
The actor having a part in the program.
</description>
</role>
<role role="in" type="PR" identifier="true">
<description>
The program the actor has a part in.
</description>
</role>
<role role="got" type="RAT" identifier="false">
<description>
The rating the actor got for the part.
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="true" restatable="true" deletable="false" idempotent="false" />
<layout x="1253.84" y="330.26" fixed="false" />
<description>
Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.
</description>
</tie>
<tie identity="int" timeRange="datetime2">
<role role="at" type="ST" identifier="true">
<description>
The stage where the program is playing.
</description>
</role>
<role role="isPlaying" type="PR" identifier="true">
<description>
The program playing at the stage.
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="true" restatable="true" deletable="false" idempotent="false" />
<layout x="1042.83" y="541.87" fixed="false" />
<description>
Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.
</description>
</tie>
<tie identity="int">
<role role="parent" type="AC" identifier="true">
<description>
The actor who is the parent.
</description>
</role>
<role role="child" type="AC" identifier="true">
<description>
The actor who is the child.
</description>
</role>
<role role="having" type="PAT" identifier="true">
<description>
The type of parental relationship.
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="true" deletable="false" idempotent="false" />
<layout x="1246.77" y="123.21" fixed="false" />
<description>
Parent-child relationships between actors, along with the type of parental relationship.
</description>
</tie>
<tie identity="int">
<role role="content" type="PR" identifier="false">
<description>
The program that made up the content of the event.
</description>
</role>
<role role="location" type="ST" identifier="false">
<description>
The stage where the event was located.
</description>
</role>
<role role="of" type="EV" identifier="true">
<description>
The event.
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="true" deletable="false" idempotent="false" />
<layout x="1105.57" y="552.13" fixed="false" />
<description>
The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.
</description>
</tie>
</schema>';
GO
-- Schema expanded view -----------------------------------------------------------------------------------------------
-- A view of the schema table that expands the XML attributes into columns
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Schema_Expanded', 'V') IS NOT NULL
DROP VIEW [dbo].[_Schema_Expanded]
GO
CREATE VIEW [dbo].[_Schema_Expanded]
AS
SELECT
	[version],
	[activation],
	[schema],
	[schema].value('schema[1]/@format', 'nvarchar(max)') as [format],
	[schema].value('schema[1]/@date', 'datetime') + [schema].value('schema[1]/@time', 'datetime') as [date],
	[schema].value('schema[1]/metadata[1]/@temporalization', 'nvarchar(max)') as [temporalization],
	[schema].value('schema[1]/metadata[1]/@databaseTarget', 'nvarchar(max)') as [databaseTarget],
	[schema].value('schema[1]/metadata[1]/@changingRange', 'nvarchar(max)') as [changingRange],
	[schema].value('schema[1]/metadata[1]/@encapsulation', 'nvarchar(max)') as [encapsulation],
	[schema].value('schema[1]/metadata[1]/@identity', 'nvarchar(max)') as [identity],
	[schema].value('schema[1]/metadata[1]/@metadataPrefix', 'nvarchar(max)') as [metadataPrefix],
	[schema].value('schema[1]/metadata[1]/@metadataType', 'nvarchar(max)') as [metadataType],
	[schema].value('schema[1]/metadata[1]/@metadataUsage', 'nvarchar(max)') as [metadataUsage],
	[schema].value('schema[1]/metadata[1]/@changingSuffix', 'nvarchar(max)') as [changingSuffix],
	[schema].value('schema[1]/metadata[1]/@identitySuffix', 'nvarchar(max)') as [identitySuffix],
	[schema].value('schema[1]/metadata[1]/@positIdentity', 'nvarchar(max)') as [positIdentity],
	[schema].value('schema[1]/metadata[1]/@positGenerator', 'nvarchar(max)') as [positGenerator],
	[schema].value('schema[1]/metadata[1]/@positingRange', 'nvarchar(max)') as [positingRange],
	[schema].value('schema[1]/metadata[1]/@positingSuffix', 'nvarchar(max)') as [positingSuffix],
	[schema].value('schema[1]/metadata[1]/@positorRange', 'nvarchar(max)') as [positorRange],
	[schema].value('schema[1]/metadata[1]/@positorSuffix', 'nvarchar(max)') as [positorSuffix],
	[schema].value('schema[1]/metadata[1]/@reliabilityRange', 'nvarchar(max)') as [reliabilityRange],
	[schema].value('schema[1]/metadata[1]/@reliabilitySuffix', 'nvarchar(max)') as [reliabilitySuffix],
	[schema].value('schema[1]/metadata[1]/@deleteReliability', 'nvarchar(max)') as [deleteReliability],
	[schema].value('schema[1]/metadata[1]/@assertionSuffix', 'nvarchar(max)') as [assertionSuffix],
	[schema].value('schema[1]/metadata[1]/@partitioning', 'nvarchar(max)') as [partitioning],
	[schema].value('schema[1]/metadata[1]/@entityIntegrity', 'nvarchar(max)') as [entityIntegrity],
	[schema].value('schema[1]/metadata[1]/@restatability', 'nvarchar(max)') as [restatability],
	[schema].value('schema[1]/metadata[1]/@idempotency', 'nvarchar(max)') as [idempotency],
	[schema].value('schema[1]/metadata[1]/@assertiveness', 'nvarchar(max)') as [assertiveness],
	[schema].value('schema[1]/metadata[1]/@naming', 'nvarchar(max)') as [naming],
	[schema].value('schema[1]/metadata[1]/@positSuffix', 'nvarchar(max)') as [positSuffix],
	[schema].value('schema[1]/metadata[1]/@annexSuffix', 'nvarchar(max)') as [annexSuffix],
	[schema].value('schema[1]/metadata[1]/@chronon', 'nvarchar(max)') as [chronon],
	[schema].value('schema[1]/metadata[1]/@now', 'nvarchar(max)') as [now],
	[schema].value('schema[1]/metadata[1]/@dummySuffix', 'nvarchar(max)') as [dummySuffix],
	[schema].value('schema[1]/metadata[1]/@statementTypeSuffix', 'nvarchar(max)') as [statementTypeSuffix],
	[schema].value('schema[1]/metadata[1]/@checksumSuffix', 'nvarchar(max)') as [checksumSuffix],
	[schema].value('schema[1]/metadata[1]/@businessViews', 'nvarchar(max)') as [businessViews],
	[schema].value('schema[1]/metadata[1]/@equivalence', 'nvarchar(max)') as [equivalence],
	[schema].value('schema[1]/metadata[1]/@equivalentSuffix', 'nvarchar(max)') as [equivalentSuffix],
	[schema].value('schema[1]/metadata[1]/@equivalentRange', 'nvarchar(max)') as [equivalentRange]
FROM
	_Schema;
GO
-- Anchor view --------------------------------------------------------------------------------------------------------
-- The anchor view shows information about all the anchors in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Anchor', 'V') IS NOT NULL
DROP VIEW [dbo].[_Anchor]
GO
CREATE VIEW [dbo].[_Anchor]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.anchor.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.anchor.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.anchor.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.anchor.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.anchor.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.anchor.value('count(attribute)', 'int') as [numberOfAttributes],
   Nodeset.anchor.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as Nodeset(anchor);
GO
-- Nexus view ---------------------------------------------------------------------------------------------------------
-- The nexus view shows information about all the nexuses in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Nexus', 'V') IS NOT NULL
DROP VIEW [dbo].[_Nexus]
GO
CREATE VIEW [dbo].[_Nexus]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.nexus.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.nexus.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.nexus.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.nexus.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.nexus.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.nexus.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.nexus.value('count(attribute)', 'int') as [numberOfAttributes],
   Nodeset.nexus.value('count(role)', 'int') as [numberOfRoles],
   Nodeset.nexus.query('
      for $role in role
      return string($role/@role)
   ').value('.', 'nvarchar(max)') as [roles],
   Nodeset.nexus.query('
      for $role in role
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [types],
   Nodeset.nexus.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/nexus') as Nodeset(nexus);
GO
-- Knot view ----------------------------------------------------------------------------------------------------------
-- The knot view shows information about all the knots in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Knot', 'V') IS NOT NULL
DROP VIEW [dbo].[_Knot]
GO
CREATE VIEW [dbo].[_Knot]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.knot.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.knot.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.knot.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.knot.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.knot.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.knot.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.knot.value('@dataRange', 'nvarchar(max)') as [dataRange],
   isnull(Nodeset.knot.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   isnull(Nodeset.knot.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent],
   Nodeset.knot.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/knot') as Nodeset(knot);
GO
-- Attribute view -----------------------------------------------------------------------------------------------------
-- The attribute view shows information about all the attributes in a schema, those of anchors and those of nexuses,
-- where the anchor columns show the nexus and parent says which of the two it is
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Attribute', 'V') IS NOT NULL
DROP VIEW [dbo].[_Attribute]
GO
CREATE VIEW [dbo].[_Attribute]
AS
SELECT
   S.version,
   S.activation,
   ParentNodeset.anchor.value('concat(@mnemonic, "_")', 'nvarchar(max)') +
   Nodeset.attribute.value('concat(@mnemonic, "_")', 'nvarchar(max)') +
   ParentNodeset.anchor.value('concat(@descriptor, "_")', 'nvarchar(max)') +
   Nodeset.attribute.value('@descriptor', 'nvarchar(max)') as [name],
   Nodeset.attribute.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.attribute.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.attribute.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.attribute.value('@identity', 'nvarchar(max)') as [identity],
   isnull(Nodeset.attribute.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent],
   Nodeset.attribute.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.attribute.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   Nodeset.attribute.value('metadata[1]/@privacy', 'nvarchar(max)') as [privacy],
   isnull(Nodeset.attribute.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   Nodeset.attribute.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.attribute.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   ParentNodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [anchorMnemonic],
   ParentNodeset.anchor.value('@descriptor', 'nvarchar(max)') as [anchorDescriptor],
   ParentNodeset.anchor.value('@identity', 'nvarchar(max)') as [anchorIdentity],
   Nodeset.attribute.value('@dataRange', 'nvarchar(max)') as [dataRange],
   Nodeset.attribute.value('@knotRange', 'nvarchar(max)') as [knotRange],
   Nodeset.attribute.value('@timeRange', 'nvarchar(max)') as [timeRange],
   Nodeset.attribute.value('metadata[1]/@deletable', 'nvarchar(max)') as [deletable],
   Nodeset.attribute.value('metadata[1]/@encryptionGroup', 'nvarchar(max)') as [encryptionGroup],
   Nodeset.attribute.value('description[1]/.', 'nvarchar(max)') as [description],
   ParentNodeset.anchor.value('local-name(.)', 'nvarchar(max)') as [parent]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/*[local-name() = "anchor" or local-name() = "nexus"]') as ParentNodeset(anchor)
OUTER APPLY
   ParentNodeset.anchor.nodes('attribute') as Nodeset(attribute);
GO
-- Tie view -----------------------------------------------------------------------------------------------------------
-- The tie view shows information about all the ties in a schema. The roles of a tie are role elements, whose type is
-- an anchor, a nexus or a knot, or in schemas from before nexuses anchorRole and knotRole elements.
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Tie', 'V') IS NOT NULL
DROP VIEW [dbo].[_Tie]
GO
CREATE VIEW [dbo].[_Tie]
AS
SELECT
   S.version,
   S.activation,
   REPLACE(Nodeset.tie.query('
      for $role in *[local-name() = "role" or local-name() = "anchorRole" or local-name() = "knotRole"]
      return concat($role/@type, "_", $role/@role)
   ').value('.', 'nvarchar(max)'), ' ', '_') as [name],
   Nodeset.tie.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.tie.value('count(*[local-name() = "role" or local-name() = "anchorRole" or local-name() = "knotRole"])', 'int') as [numberOfRoles],
   Nodeset.tie.query('
      for $role in *[local-name() = "role" or local-name() = "anchorRole" or local-name() = "knotRole"]
      return string($role/@role)
   ').value('.', 'nvarchar(max)') as [roles],
   Nodeset.tie.value('count(anchorRole) + count(role[@type = /schema/anchor/@mnemonic])', 'int') as [numberOfAnchors],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or (local-name() = "role" and @type = /schema/anchor/@mnemonic)]
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [anchors],
   Nodeset.tie.value('count(knotRole) + count(role[@type = /schema/knot/@mnemonic])', 'int') as [numberOfKnots],
   Nodeset.tie.query('
      for $role in *[local-name() = "knotRole" or (local-name() = "role" and @type = /schema/knot/@mnemonic)]
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [knots],
   Nodeset.tie.value('count(*[local-name() = "role" or local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"])', 'int') as [numberOfIdentifiers],
   Nodeset.tie.query('
      for $role in *[local-name() = "role" or local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"]
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [identifiers],
   Nodeset.tie.value('@timeRange', 'nvarchar(max)') as [timeRange],
   Nodeset.tie.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.tie.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   Nodeset.tie.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.tie.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   Nodeset.tie.value('description[1]/.', 'nvarchar(max)') as [description],
   Nodeset.tie.value('count(role[@type = /schema/nexus/@mnemonic])', 'int') as [numberOfNexuses],
   Nodeset.tie.query('
      for $role in role[@type = /schema/nexus/@mnemonic]
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [nexuses]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/tie') as Nodeset(tie);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- The key view shows information about all the keys in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Key', 'V') IS NOT NULL
DROP VIEW [dbo].[_Key]
GO
CREATE VIEW [dbo].[_Key]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.keys.value('@of', 'nvarchar(max)') as [of],
   Nodeset.keys.value('@route', 'nvarchar(max)') as [route],
   Nodeset.keys.value('@stop', 'nvarchar(max)') as [stop],
   case
      when [parent] in ('tie', 'nexus')
      then Nodeset.keys.value('../@role', 'nvarchar(max)')
   end as [role],
   case [parent]
      when 'knot'
      then Nodeset.keys.value('concat(../@mnemonic, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('../@descriptor', 'nvarchar(max)')
      when 'attribute'
      then Nodeset.keys.value('concat(../../@mnemonic, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('concat(../@mnemonic, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('concat(../../@descriptor, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('../@descriptor', 'nvarchar(max)')
      when 'tie'
      then REPLACE(Nodeset.keys.query('
            for $role in ../../*[local-name() = "role" or local-name() = "anchorRole" or local-name() = "knotRole"]
            return concat($role/@type, "_", $role/@role)
          ').value('.', 'nvarchar(max)'), ' ', '_')
      when 'nexus'
      then Nodeset.keys.value('concat(../../@mnemonic, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('../../@descriptor', 'nvarchar(max)')
   end as [in],
   [parent]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema//key') as Nodeset(keys)
CROSS APPLY (
   VALUES (
      case
         when Nodeset.keys.value('local-name(..)', 'nvarchar(max)') in ('anchorRole', 'knotRole')
         then 'tie'
         when Nodeset.keys.value('local-name(..)', 'nvarchar(max)') = 'role' -- of a tie or of a nexus
         then Nodeset.keys.value('local-name(../..)', 'nvarchar(max)')
         else Nodeset.keys.value('local-name(..)', 'nvarchar(max)')
      end
   )
) p ([parent]);
GO
-- Evolution function -------------------------------------------------------------------------------------------------
-- The evolution function shows what the schema looked like at the given
-- point in time with additional information about missing or added
-- modeling components since that time.
--
-- @timepoint The point in time to which you would like to travel.
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Evolution', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[_Evolution];
GO
CREATE FUNCTION [dbo].[_Evolution] (
    @timepoint AS datetime2
)
RETURNS TABLE AS
RETURN
WITH constructs AS (
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [dbo].[_Anchor] a
   CROSS APPLY (
      VALUES ('uni', ''), ('bi', ''), ('crt', '')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [dbo].[_Nexus] n
   CROSS APPLY (
      VALUES ('uni', ''), ('bi', ''), ('crt', '')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [dbo].[_Knot] k
   CROSS APPLY (
      VALUES ('uni', ''), ('bi', ''), ('crt', '')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [dbo].[_Attribute] b
   CROSS APPLY (
      VALUES ('uni', ''), ('bi', '_Annex'), ('bi', '_Posit'), ('crt', '_Annex'), ('crt', '_Posit')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [dbo].[_Tie] t
   CROSS APPLY (
      VALUES ('uni', ''), ('bi', '_Annex'), ('bi', '_Posit'), ('crt', '_Annex'), ('crt', '_Posit')
   ) s (temporalization, suffix)
),
selectedSchema AS (
   SELECT TOP 1
      *
   FROM
      [dbo].[_Schema_Expanded]
   WHERE
      [activation] <= @timepoint
   ORDER BY
      [activation] DESC
),
presentConstructs AS (
   SELECT
      C.*
   FROM
      selectedSchema S
   JOIN
      constructs C
   ON
      S.[version] = C.[version]
   AND
      S.temporalization = C.temporalization
),
allConstructs AS (
   SELECT
      C.*
   FROM
      selectedSchema S
   JOIN
      constructs C
   ON
      S.temporalization = C.temporalization
)
SELECT
   COALESCE(P.[version], X.[version]) as [version],
   COALESCE(P.[qualifiedName], T.[qualifiedName]) AS [name],
   COALESCE(P.[activation], X.[activation], T.[create_date]) AS [activation],
   CASE
      WHEN P.[activation] = S.[activation] THEN 'Present'
      WHEN X.[activation] > S.[activation] THEN 'Future'
      WHEN X.[activation] < S.[activation] THEN 'Past'
      ELSE 'Missing'
   END AS Existence
FROM
   presentConstructs P
FULL OUTER JOIN (
   SELECT
      s.[name] + '.' + t.[name] AS [qualifiedName],
      t.[create_date]
   FROM
      sys.tables t
   JOIN
      sys.schemas s
   ON
      s.schema_id = t.schema_id
   WHERE
      t.[type] = 'U'
   AND
      LEFT(t.[name], 1) <> '_'
) T
ON
   T.[qualifiedName] = P.[qualifiedName]
LEFT JOIN
   allConstructs X
ON
   X.[qualifiedName] = T.[qualifiedName]
AND
   X.[activation] = (
      SELECT
         MIN(sub.[activation])
      FROM
         constructs sub
      WHERE
         sub.[qualifiedName] = T.[qualifiedName]
      AND
         sub.[activation] >= T.[create_date]
   )
CROSS APPLY (
   SELECT
      *
   FROM
      selectedSchema
) S;
GO
-- Drop Script Generator ----------------------------------------------------------------------------------------------
-- generates a drop script, that must be run separately, dropping everything in an Anchor Modeled database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._GenerateDropScript', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[_GenerateDropScript];
GO
CREATE PROCEDURE [dbo].[_GenerateDropScript] (
   @exclusionPattern varchar(42) = '%.[[][_]%', -- exclude Metadata by default
   @inclusionPattern varchar(42) = '%', -- include everything by default
   @directions varchar(42) = 'Upwards, Downwards', -- do both up and down by default
   @qualifiedName varchar(555) = null -- can specify a single object
)
AS
BEGIN
	set nocount on;
	create table #entities (
		[object_id] int not null unique,
		[schema] varchar(42) not null,
		[entity] varchar(555) not null,
		[type] varchar(10) not null,
		qualifiedName varchar(597) not null,
		primary key (
			[schema],
			[entity]
		)
	);
	insert into #entities (
		[object_id],
		[schema],
		[entity],
		[type],
		qualifiedName
	)
	select
		o.[object_id],
		s.[name],
		o.[name],
		o.[type],
		n.qualifiedName
	from sys.objects o
	join sys.schemas s
	on s.schema_id = o.schema_id
	cross apply (
		values (
			'[' + s.[name] + '].[' + o.[name] + ']'
		)
	) n (qualifiedName)
	where o.[type] not in ('S', 'IT');
	create table #exclusions (
		[object_id] int not null unique,
		[schema] varchar(42) not null,
		[entity] varchar(555) not null,
		qualifiedName varchar(597) not null,
		primary key (
			[schema],
			[entity]
		)
	);
	insert into #exclusions (
		[object_id],
		[schema],
		[entity],
		qualifiedName
	)
	select
		[object_id],
		[schema],
		[entity],
		qualifiedName
	from #entities
	where qualifiedName like @exclusionPattern;
	-- select * from #exclusions;
	create table #inclusions (
		[object_id] int not null unique,
		[schema] varchar(42) not null,
		[entity] varchar(555) not null,
		qualifiedName varchar(597) not null,
		primary key (
			[schema],
			[entity]
		)
	);
	insert into #inclusions (
		[object_id],
		[schema],
		[entity],
		qualifiedName
	)
	select
		[object_id],
		[schema],
		[entity],
		qualifiedName
	from #entities e
	where coalesce(@qualifiedName, qualifiedName) in (qualifiedName, [schema] + '.' + [entity])
	and not exists (
		select top 1 [entity] from #exclusions where [schema] = e.[schema] and [entity] = e.[entity]
	);
	-- select * from #inclusions;
	create table #downward (
		referenced_id int not null unique,
		referenced_schema_name varchar(42) not null,
		referenced_entity_name varchar(555) not null,
		[level] smallint not null,
		[direction] char(1) not null,
		primary key (
			referenced_schema_name,
			referenced_entity_name
		)
	);
	with downward as (
		select
			r.referenced_schema_name,
			r.referenced_entity_name,
			-2 as [level],
			'D' as direction,
			r.referenced_id
		from #inclusions
		cross apply sys.dm_sql_referenced_entities(qualifiedName, 'OBJECT') r
		where r.referenced_minor_id = 0 and r.is_incomplete = 0 and r.referenced_id is not null and r.referenced_schema_name is not null
		union all
		select
			r.referenced_schema_name,
			r.referenced_entity_name,
			d.[level] - 2,
			d.direction,
			r.referenced_id
		from downward d
		cross apply sys.dm_sql_referenced_entities(d.referenced_schema_name + '.' + d.referenced_entity_name, 'OBJECT') r
		where r.referenced_minor_id = 0 and r.is_incomplete = 0 and r.referenced_id is not null and r.referenced_schema_name is not null
	)
	insert into #downward (
		referenced_id,
		referenced_schema_name,
		referenced_entity_name,
		[level],
		[direction]
	)
	select
		referenced_id,
		referenced_schema_name,
		referenced_entity_name,
		max([level]) as [level],
		min([direction]) as [direction]
	from (
		select referenced_id, referenced_schema_name, referenced_entity_name, [level], [direction] from downward
		union all
		select [object_id], [schema], [entity], 0, 'D' from #inclusions
	) d
	where not exists (
		select top 1 [entity] from #exclusions where [schema] = referenced_schema_name and [entity] = referenced_entity_name
	)
	group by
		referenced_id,
		referenced_schema_name,
		referenced_entity_name;
	-- select * from #downward order by level desc;
	create table #entities_at_level (
		[schema] varchar(42) not null,
		[entity] varchar(555) not null,
		qualifiedName varchar(597) not null,
		[level] int null,
		primary key (
			[schema],
			[entity]
		)
	);
	insert into #entities_at_level (
		[schema],
		[entity],
		qualifiedName,
		[level]
	)
	select
		e.[schema],
		e.[entity],
		e.qualifiedName,
		d.[level]
	from #entities e
	left join #downward d
	on d.referenced_schema_name = e.[schema]
	and d.referenced_entity_name = e.[entity]
	where not exists (
		select top 1 [entity] from #exclusions where [schema] = e.[schema] and [entity] = e.[entity]
	);
	create table #upward (
		referenced_id int not null unique,
		referenced_schema_name varchar(42) not null,
		referenced_entity_name varchar(555) not null,
		[level] smallint not null,
		[direction] char(1) not null,
		primary key (
			referenced_schema_name,
			referenced_entity_name
		)
	);
	with upward as (
		select
			referenced_schema_name,
			referenced_entity_name,
			[level],
			direction,
			referenced_id
		from #downward
		union all
		select
			cast(r.referencing_schema_name as varchar(42)),
			cast(r.referencing_entity_name as varchar(555)),
			cast(u.[level] + 2 as smallint), -- series becomes 0, 2, 4, 6, ...
			cast('U' as char(1)),
			r.referencing_id
		from upward u
		cross apply sys.dm_sql_referencing_entities(u.referenced_schema_name + '.' + u.referenced_entity_name, 'OBJECT') r
		join #entities_at_level e
		on e.[schema] = r.referencing_schema_name and e.[entity] = r.referencing_entity_name
		and (e.[level] is null or u.[level] + 2 > e.[level])
		where r.referencing_id <> OBJECT_ID(u.referenced_schema_name + '.' + u.referenced_entity_name)
	)
	insert into #upward (
		referenced_id,
		referenced_schema_name,
		referenced_entity_name,
		[level],
		[direction]
	)
	select
		referenced_id,
		referenced_schema_name,
		referenced_entity_name,
		max([level]) as [level],
		min([direction]) as [direction]
	from upward
	where referenced_schema_name + '.' + referenced_entity_name like @inclusionPattern
	group by
		referenced_id,
		referenced_schema_name,
		referenced_entity_name;
	with adjustment as (
		select
			u.referenced_id,
			fk.referenced_object_id,
			1 as adjustment
		from #upward u
		join sys.foreign_keys fk
		on fk.parent_object_id = u.referenced_id
		union all
		select
			a.referenced_object_id,
			fk.referenced_object_id,
			a.adjustment + 2 -- series becomes 1, 3, 5, 7, ... so ends up between already defined order
		from adjustment a
		join sys.foreign_keys fk
		on fk.parent_object_id = a.referenced_object_id
	)
	update u
		set u.[level] = u.[level] + a.adjustment
	from #upward u
	join adjustment a
	on a.referenced_id = u.referenced_id;
	select
		case
			when t.objectType = 'CHECK'
			then 'ALTER TABLE ' + n.parentName + ' DROP CONSTRAINT ' + u.referenced_entity_name
			else 'DROP ' + t.objectType + ' ' + n.qualifiedName
		end + ';' + CHAR(13) as [text()]
	from #upward u
	join sys.objects o
	on o.object_id = u.referenced_id
	cross apply (
		values (
			'[' + u.referenced_schema_name + '].[' + u.referenced_entity_name + ']',
			'[' + u.referenced_schema_name + '].[' + OBJECT_NAME(o.parent_object_id) + ']'
		)
	) n (qualifiedName, parentName)
	cross apply (
		select
		case o.[type]
			when 'C' then 'CHECK'
			when 'TR' then 'TRIGGER'
			when 'V' then 'VIEW'
			when 'IF' then 'FUNCTION'
			when 'FN' then 'FUNCTION'
			when 'P' then 'PROCEDURE'
			when 'PK' then 'CONSTRAINT'
			when 'UQ' then 'CONSTRAINT'
			when 'F' then 'CONSTRAINT'
			when 'U' then 'TABLE'
		end
		) t (objectType)
	where @directions like '%' + u.direction + '%'
	and t.objectType in (
			'CHECK',
			'VIEW',
			'FUNCTION',
			'PROCEDURE',
			'TABLE'
		)
	order by
		[referenced_schema_name],
		[level] desc,
		[direction] asc,
		case [type]
			when 'C' then 0 -- CHECK CONSTRAINT
			when 'TR' then 1 -- SQL_TRIGGER
			when 'P' then 2 -- SQL_STORED_PROCEDURE
			when 'V' then 3 -- VIEW
			when 'IF' then 4 -- SQL_INLINE_TABLE_VALUED_FUNCTION
			when 'FN' then 5 -- SQL_SCALAR_FUNCTION
			when 'PK' then 6 -- PRIMARY_KEY_CONSTRAINT
			when 'UQ' then 7 -- UNIQUE_CONSTRAINT
			when 'F' then 8 -- FOREIGN_KEY_CONSTRAINT
			when 'U' then 9 -- USER_TABLE
		end asc,
		[referenced_entity_name]
	for xml path('');
END
GO
-- Database Copy Script Generator -------------------------------------------------------------------------------------
-- generates a copy script, that must be run separately, copying all data between two identically modeled databases
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._GenerateCopyScript', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[_GenerateCopyScript];
GO
CREATE PROCEDURE [dbo]._GenerateCopyScript (
	@source varchar(123),
	@target varchar(123)
)
as
begin
	declare @R char(1);
    set @R = CHAR(13);
	-- stores the built SQL code
	declare @sql varchar(max);
    set @sql = 'USE ' + @target + ';' + @R;
	declare @xml xml;
	-- find which version of the schema that is in effect
	declare @version int;
	select
		@version = max([version])
	from
		[dbo]._Schema;
	-- declare and set other variables we need
	declare @equivalentSuffix varchar(42);
	declare @identitySuffix varchar(42);
	declare @annexSuffix varchar(42);
	declare @positSuffix varchar(42);
	declare @temporalization varchar(42);
	select
		@equivalentSuffix = equivalentSuffix,
		@identitySuffix = identitySuffix,
		@annexSuffix = annexSuffix,
		@positSuffix = positSuffix,
		@temporalization = temporalization
	from
		[dbo]._Schema_Expanded
	where
		[version] = @version;
	-- build non-equivalent knot copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R
			end
		from
			[dbo]._Knot x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		and
			isnull(equivalent, 'false') = 'false'
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build equivalent knot copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @identitySuffix + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @identitySuffix + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @identitySuffix + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @identitySuffix + ' OFF;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @equivalentSuffix + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @equivalentSuffix + ';' + @R
		from
			[dbo]._Knot x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		and
			isnull(equivalent, 'false') = 'true'
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build anchor copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R
			end
		from
			[dbo]._Anchor x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build nexus copy, after the anchors and knots that its roles reference
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R
			end
		from
			[dbo]._Nexus x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build attribute copy, of anchors and nexuses
	if (@temporalization in ('bi', 'crt'))
	begin
		set @xml = (
			select
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' ON;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @positSuffix + '(' + [positColumns] + ')' + @R +
				'SELECT ' + [positColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @positSuffix + ';' + @R,
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' OFF;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @annexSuffix + '(' + [annexColumns] + ')' + @R +
				'SELECT ' + [annexColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @annexSuffix + ';' + @R
			from
				[dbo]._Attribute x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @positSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) pc ([positColumns])
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @annexSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) ac ([annexColumns])
			where
				[version] = @version
			for xml path('')
		);
	end
	else -- uni
	begin
		set @xml = (
			select
				'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
				'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R
			from
				[dbo]._Attribute x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) c ([columns])
			where
				[version] = @version
			for xml path('')
		);
	end
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build tie copy
	if (@temporalization in ('bi', 'crt'))
	begin
		set @xml = (
			select
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' ON;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @positSuffix + '(' + [positColumns] + ')' + @R +
				'SELECT ' + [positColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @positSuffix + ';' + @R,
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' OFF;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @annexSuffix + '(' + [annexColumns] + ')' + @R +
				'SELECT ' + [annexColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @annexSuffix + ';' + @R
			from
				[dbo]._Tie x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @positSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) pc ([positColumns])
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @annexSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) ac ([annexColumns])
			where
				[version] = @version
			for xml path('')
		);
	end
	else -- uni
	begin
		set @xml = (
			select
				'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
				'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R
			from
				[dbo]._Tie x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) c ([columns])
			where
				[version] = @version
			for xml path('')
		);
	end
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	select @sql for xml path('');
end
go
-- Delete Everything with a Certain Metadata Id -----------------------------------------------------------------------
-- deletes all rows from all tables that have the specified metadata id
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._DeleteWhereMetadataEquals', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[_DeleteWhereMetadataEquals];
GO
CREATE PROCEDURE [dbo]._DeleteWhereMetadataEquals (
	@metadataID int,
	@schemaVersion int = null,
	@includeKnots bit = 0
)
as
begin
	declare @sql varchar(max);
	set @sql = 'print ''Null is not a valid value for @metadataId''';
	if(@metadataId is not null)
	begin
		if(@schemaVersion is null)
		begin
			select
				@schemaVersion = max(Version)
			from
				[dbo]._Schema;
		end;
		with constructs as (
			select
				'l' + name as name,
				2 as prio,
				'Metadata' + name as metadataColumn
			from
				[dbo]._Tie
			where
				[version] = @schemaVersion
			union all
			select
				'l' + name as name,
				3 as prio, -- after the ties that may reference a nexus, before what its roles reference
				'Metadata' + mnemonic as metadataColumn
			from
				[dbo]._Nexus
			where
				[version] = @schemaVersion
			union all
			select
				'l' + name as name,
				4 as prio,
				'Metadata' + mnemonic as metadataColumn
			from
				[dbo]._Anchor
			where
				[version] = @schemaVersion
			union all
			select
				name,
				5 as prio,
				'Metadata' + mnemonic as metadataColumn
			from
				[dbo]._Knot
			where
				[version] = @schemaVersion
			and
				@includeKnots = 1
		)
		select
			@sql = (
				select
					'DELETE FROM ' + name + ' WHERE ' + metadataColumn + ' = ' + cast(@metadataId as varchar(max)) + '; '
				from
					constructs
        order by
					prio, name
				for xml
					path('')
			);
	end
	exec(@sql);
end
go
if OBJECT_ID('dbo._FindWhatToRemove', 'P') is not null
drop proc [dbo].[_FindWhatToRemove];
go
-- _FindWhatToRemove finds what else to remove given
-- some input data containing data about to be removed.
--
--	Note that the table #removed must be created and
--	have at least one row before calling this SP. This
--	table will be populated with additional rows during
--	the walking of the ties.
--
--	Parameters:
--
--	@current	The mnemonic of the anchor in which to
--	start the tie walking.
--	@forbid	Comma separated list of anchor mnemonics
--	that never should be walked over.
--	(optional)
--	@visited	Keeps track of which anchors have been
--	visited. Should never be passed to the
--	procedure.
--
--	----------------------------------------------------
--	-- EXAMPLE USAGE
--	----------------------------------------------------
--	if object_id('tempdb..#visited') is not null
--	drop table #visited;
--
--	create table #visited (
--	Visited varchar(max),
--	CurrentRole varchar(42),
--	CurrentMnemonic char(2),
--	Occurrences int,
--	Tie varchar(555),
--	AnchorRole varchar(42),
--	AnchorMnemonic char(2),
--	VisitingOrder int
--	);
--
--	if object_id('tempdb..#removed') is not null
--	drop table #removed;
--	create table #removed (
--	AnchorMnemonic char(2),
--	AnchorID int,
--	primary key (
--	AnchorMnemonic,
--	AnchorID
--	)
--	);
--
--	insert into #removed
--	values ('CO', 3);
--
--	insert into #visited
--	EXEC _FindWhatToRemove 'CO', 'AA';
--
--	select * from #visited;
--	select * from #removed;
create proc [dbo].[_FindWhatToRemove] (
	@current char(2),
	@forbid varchar(max) = null,
	@visited varchar(max) = null
)
as
begin
	-- dummy creation to make intellisense work
	if object_id('tempdb..#removed') is null
	create table #removed (
		AnchorMnemonic char(2),
		AnchorID int,
		primary key (
			AnchorMnemonic,
			AnchorID
		)
	);
	set @visited = isnull(@visited, '');
	if @visited not like '%-' + @current + '%'
	begin
		set @visited = @visited + '-' + @current;
		declare @version int = (select max(version) from [dbo]._Schema);
		declare @ties xml = (
			select
				*
			from (
				select [schema].query('//tie[*[local-name() = "role" or local-name() = "anchorRole"][@type = sql:variable("@current")]]')
				from [dbo]._Schema
				where version = @version
			) t (ties)
		);
		select
			@visited as Visited,
			Tie.value('(../*[local-name() = "role" or local-name() = "anchorRole"][@type = sql:variable("@current")]/@role)[1]', 'varchar(42)') as CurrentRole,
			@current as CurrentMnemonic,
			cast(null as int) as Occurrences,
			replace(Tie.query('
				for $tie in ..
				return <name> {
					for $role in $tie/*[local-name() = "role" or local-name() = "anchorRole" or local-name() = "knotRole"]
					return concat($role/@type, "_", $role/@role)
				} </name>
			').value('name[1]', 'varchar(555)'), ' ', '_') as Tie,
			Tie.value('@role', 'varchar(42)') as AnchorRole,
			Tie.value('@type', 'char(2)') as AnchorMnemonic,
			row_number() over (order by (select 1)) as VisitingOrder
		into #walk
		from @ties.nodes('tie/*[local-name() = "role" or local-name() = "anchorRole"][@type != sql:variable("@current")]') AS t (Tie)
		-- the walk goes over anchors, not over the knots or nexuses that the roles of a tie may also have
		delete #walk where AnchorMnemonic not in (
			select mnemonic from [dbo]._Anchor where [version] = @version
		);
		delete #walk where @forbid + ',' like '%' + AnchorMnemonic + ',%';
		declare @update varchar(max) = (
			select '
				update #walk
				set Occurrences = (
					select count(*)
					from ' + Tie + ' t
					join #removed x
					on x.AnchorMnemonic = ''' + CurrentMnemonic + '''
					and x.AnchorId = t.' + CurrentMnemonic + '_ID_' + CurrentRole + '
				)
				where Tie = ''' + Tie + '''
			' as [text()]
			from #walk
			for xml path(''), type
		).value('.', 'varchar(max)');
		exec(@update);
		select
			substring(Visited, 2, len(Visited)-1) as Visited,
			CurrentRole,
			CurrentMnemonic,
			Occurrences,
			Tie,
			AnchorRole,
			AnchorMnemonic,
			VisitingOrder
		from #walk;
		declare @i int = 0;
		declare @max int = (select max(VisitingOrder) from #walk);
		declare @next char(2);
		declare @occurrences int = 0;
		declare @insert varchar(max);
		declare @tie varchar(555);
		declare @anchor_column varchar(555);
		declare @current_column varchar(555);
		while @i < @max
		begin
			set @i = @i + 1;
			select
				@occurrences = Occurrences,
				@tie = Tie,
				@next = AnchorMnemonic,
				@anchor_column = AnchorMnemonic + '_ID_' + AnchorRole,
				@current_column = CurrentMnemonic + '_ID_' + CurrentRole
			from #walk
			where VisitingOrder = @i;
			if @occurrences > 0
			begin
				set @insert = '
					insert into #removed (AnchorMnemonic, AnchorID)
					select distinct ''' + @next + ''', t.' + @anchor_column + '
					from ' + @tie + ' t
					join #removed x
					on x.AnchorMnemonic = ''' + @current + '''
					and x.AnchorId = t.' + @current_column + '
					left join #removed seen
					on seen.AnchorMnemonic = ''' + @next + '''
					and seen.AnchorId = t.' + @anchor_column + '
					where seen.AnchorId is null;
				';
				exec(@insert);
				exec _FindWhatToRemove @next, @forbid, @visited;
			end
		end
	end
end
go
if OBJECT_ID('dbo._GenerateDeleteScript') is not null
drop proc [dbo]._GenerateDeleteScript;
go
-- _GenerateDeleteScript creates delete statements
-- that can be used to empty a database or parts of
-- a database.
--
--	Parameters:
--
--	@anchorList	An optional parameter specified as a
-- list of anchors to be deleted. If not
-- specified, delete statements will be
-- generated for all anchors.
--
-- EXAMPLE:
-- _GenerateDeleteScript @anchorList = 'AC PE'
--
create proc [dbo]._GenerateDeleteScript (
	@anchorList varchar(max) = null
)
as
begin
	declare @batchSize int = 100000;
	declare @currentVersion int = (
		select max([version]) from _Schema
	);
	select a.[capsule] + '.' + a.[name] as qualifiedName, a.[mnemonic], a.[generator]
	into #anchor
	from [dbo]._Anchor a
	where a.[version] = @currentVersion
	and (@anchorList is null or @anchorList like '%' + a.[mnemonic] + '%');
	select b.[capsule] + '.' + b.[name] as qualifiedName, b.[generator], b.[knotRange]
	into #attribute
	from [dbo]._Attribute b
	join #anchor a
	on a.[mnemonic] = b.[anchorMnemonic]
	where b.[version] = @currentVersion;
	select distinct t.[capsule] + '.' + t.[name] as qualifiedName, t.[generator], t.[knots]
	into #tie
	from [dbo]._Tie t
	join #anchor a
	on t.[anchors] like '%' + a.[mnemonic] + '%'
	where t.[version] = @currentVersion;
	select distinct k.[capsule] + '.' + k.[name] as qualifiedName, k.[generator]
	into #knot
	from [dbo]._Knot k
	outer apply (
		select qualifiedName
		from #tie t
		where t.[knots] like '%' + k.[mnemonic] + '%'
	) kt
	left join #attribute a
	on a.[knotRange] = k.[mnemonic]
	where k.[version] = @currentVersion
	and (kt.qualifiedName is not null or a.qualifiedName is not null)
	and not exists (
		select top 1 t.[knots]
		from [dbo]._Tie t
		where t.[version] = @currentVersion
		and t.[knots] like '%' + k.[mnemonic] + '%'
		and t.[capsule] + '.' + t.[name] not in (
			select qualifiedName from #tie
		)
	)
	and not exists (
		select top 1 a.[mnemonic]
		from [dbo]._Attribute a
		where a.[version] = @currentVersion
		and a.[knotRange] = k.[mnemonic]
		and a.[capsule] + '.' + a.[name] not in (
			select qualifiedName from #attribute
		)
	);
	select
		case
			when ROW_NUMBER() over (order by ordering, qualifiedName) = 1
			then 'DECLARE @deletedRows INT; ' + CHAR(13)
			else ''
		end +
		'SET @deletedRows = 1; ' + CHAR(13) +
		'WHILE @deletedRows != 0 ' + CHAR(13) +
		'BEGIN' + CHAR(13) +
		CHAR(9) + 'DELETE TOP (' + cast(@batchSize as varchar(10)) + ') ' + qualifiedName + '; ' + CHAR(13) +
		CHAR(9) + 'SET @deletedRows = @@ROWCOUNT; ' + CHAR(13) +
		'END' + CHAR(13) +
		case
			when [generator] = 'true'
			then 'DBCC CHECKIDENT (''' + qualifiedName + ''', RESEED, 0); ' + CHAR(13)
			else ''
		end as [text()]
	from (
		select 1 as ordering, qualifiedName, [generator] from #attribute
		union all
		select 2 as ordering, qualifiedName, [generator] from #tie
		union all
		select 3 as ordering, qualifiedName, [generator] from #anchor
		union all
		select 4 as ordering, qualifiedName, [generator] from #knot
	) x
	order by ordering, qualifiedName asc
	for xml path('');
end
go
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PAT_ParentalType';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Kind of parent-child relationship between two actors, such as biological or adoptive parent.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PAT_ParentalType';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'GEN_Gender';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Gender of an actor.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'GEN_Gender';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PLV_ProfessionalLevel';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PLV_ProfessionalLevel';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'UTL_Utilization';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'UTL_Utilization';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ONG_Ongoing';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Yes or No flag indicating whether a relationship is still ongoing or has ended.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ONG_Ongoing';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'RAT_Rating';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Rating of how well an actor performs a part in a program, such as good, mediocre or bad.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'RAT_Rating';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ETY_EventType';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Type of event, such as premiere, regular performance, rehearsal or gala.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ETY_EventType';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PN_Person';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A person. Persons who perform are also registered as actors.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PN_Person';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_Stage';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A stage or venue where programs are played and events are held.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_Stage';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_NAM_Stage_Name_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Name of the stage. Historized, since a stage may be renamed over time.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_NAM_Stage_Name_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_LOC_Stage_Location_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Geographic location of the stage as a geography point.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_LOC_Stage_Location_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_AVG_Stage_Average_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Average utilization of the stage capacity, recalculated over time.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_AVG_Stage_Average_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_MIN_Stage_Minimum_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Minimum utilization of the stage capacity required for a performance to take place.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_MIN_Stage_Minimum_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_Actor';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
An actor, a person who performs parts in programs and is cast in events.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_Actor';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_NAM_Actor_Name_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Name of the actor, such as a stage name. Historized, since it may change over time.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_NAM_Actor_Name_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_GEN_Actor_Gender_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Gender of the actor.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_GEN_Actor_Gender_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_PLV_Actor_ProfessionalLevel_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Professional level of the actor, which may change as the actor gains experience.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_PLV_Actor_ProfessionalLevel_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_Program';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A program, such as a play, show or concert, that can be played on stages.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_Program';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_NAM_Program_Name_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Name or title of the program.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_NAM_Program_Name_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_LEN_Program_Length_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Running time of the program. Historized, since the program may be shortened or extended over time.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_LEN_Program_Length_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
An event, a single performance of a program held at a stage at a specific date and time.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_DAT_Event_Date_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Date and time when the event took place.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_DAT_Event_Date_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_AUD_Event_Audience_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Number of people in the audience at the event.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_AUD_Event_Audience_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_REV_Event_Revenue_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Revenue from ticket sales for the event.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_REV_Event_Revenue_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'ST_ID_wasHeldAt';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The stage at which the event was held.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'ST_ID_wasHeldAt';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'PR_ID_wasPlayed';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The program that was played at the event.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'PR_ID_wasPlayed';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'ETY_ID_of';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The type of the event.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'ETY_ID_of';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'AC_ID_partner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
One of the actors in the partnership.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'AC_ID_partner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'AC_ID_with';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The other actor in the partnership.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'AC_ID_with';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'ONG_ID_currently';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Whether the partnership is still ongoing (Yes) or has ended (No).
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'ONG_ID_currently';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_subset_PN_of_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_subset_PN_of_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_subset_PN_of_Posit',
@level2type = N'Column', @level2name = 'AC_ID_subset';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The actor.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_subset_PN_of_Posit',
@level2type = N'Column', @level2name = 'AC_ID_subset';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_subset_PN_of_Posit',
@level2type = N'Column', @level2name = 'PN_ID_of';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The person who is the actor.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_subset_PN_of_Posit',
@level2type = N'Column', @level2name = 'PN_ID_of';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The actors that were cast in an event, meaning those who performed at that performance.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit',
@level2type = N'Column', @level2name = 'EV_ID_in';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The event the actor was cast in.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit',
@level2type = N'Column', @level2name = 'EV_ID_in';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit',
@level2type = N'Column', @level2name = 'AC_ID_wasCast';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
An actor cast in the event.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit',
@level2type = N'Column', @level2name = 'AC_ID_wasCast';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'AC_ID_part';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The actor having a part in the program.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'AC_ID_part';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'PR_ID_in';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The program the actor has a part in.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'PR_ID_in';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'RAT_ID_got';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The rating the actor got for the part.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'RAT_ID_got';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit',
@level2type = N'Column', @level2name = 'ST_ID_at';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The stage where the program is playing.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit',
@level2type = N'Column', @level2name = 'ST_ID_at';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit',
@level2type = N'Column', @level2name = 'PR_ID_isPlaying';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The program playing at the stage.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit',
@level2type = N'Column', @level2name = 'PR_ID_isPlaying';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Parent-child relationships between actors, along with the type of parental relationship.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'AC_ID_parent';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The actor who is the parent.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'AC_ID_parent';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'AC_ID_child';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The actor who is the child.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'AC_ID_child';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'PAT_ID_having';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The type of parental relationship.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'PAT_ID_having';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'PR_ID_content';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The program that made up the content of the event.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'PR_ID_content';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'ST_ID_location';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The stage where the event was located.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'ST_ID_location';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'EV_ID_of';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The event.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'EV_ID_of';
GO
