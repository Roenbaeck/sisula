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
-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Positor', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[_Positor] (
        Positor tinyint not null,
        constraint pk_Positor primary key (
            Positor asc
        )
    );
    INSERT INTO [dbo].[_Positor] (
        Positor
    )
    VALUES (
        0 -- the default positor
    );
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
-- GRD_Grade table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.GRD_Grade', 'U') IS NULL
CREATE TABLE [dbo].[GRD_Grade] (
    GRD_ID tinyint not null,
    GRD_Grade nvarchar(42) not null,
    Metadata_GRD int not null,
    constraint pkGRD_Grade primary key (
        GRD_ID asc
    ),
    constraint uqGRD_Grade unique (
        GRD_Grade
    )
);
GO
-- ANCHORS -----------------------------------------------------------------------------------------------------------
--
-- Anchors store the identities of entities and are immutable.
-- (Attribute tables moved to CreateAttributes.js.)
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- SU_Subject table (with 12 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_Subject', 'U') IS NULL
CREATE TABLE [dbo].[SU_Subject] (
    SU_ID int IDENTITY(1,1) not null,
    Metadata_SU int not null,
    constraint pkSU_Subject primary key (
        SU_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- OB_Object table (with 1 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_Object', 'U') IS NULL
CREATE TABLE [dbo].[OB_Object] (
    OB_ID int IDENTITY(1,1) not null,
    Metadata_OB int not null,
    constraint pkOB_Object primary key (
        OB_ID asc
    )
);
GO
-- NEXUSES -----------------------------------------------------------------------------------------------------------
--
-- Nexuses (event-like constructs) store identities of composite event instances and are immutable.
-- (Attribute tables moved to CreateAttributes.js.)
--
-- Nexus table -------------------------------------------------------------------------------------------------------
-- EV_Event table (with 2 attributes and 1 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_Event', 'U') IS NULL
CREATE TABLE [dbo].[EV_Event] (
    EV_ID int IDENTITY(1,1) not null,
    SU_ID_for int not null,
    constraint EV_Event_fkSU_for foreign key (
        SU_ID_for
    ) references [dbo].[SU_Subject](SU_ID),
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
-- EV_QTY_Event_Quantity_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_QTY_Event_Quantity_Posit', 'U') IS NULL
CREATE TABLE [dbo].[EV_QTY_Event_Quantity_Posit] (
    EV_QTY_ID int IDENTITY(1,1) not null,
    EV_QTY_EV_ID int not null,
    EV_QTY_Event_Quantity int not null,
    constraint fkEV_QTY_Event_Quantity_Posit foreign key (
        EV_QTY_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_QTY_Event_Quantity_Posit primary key nonclustered (
        EV_QTY_ID asc
    ),
    constraint uqEV_QTY_Event_Quantity_Posit unique clustered (
        EV_QTY_EV_ID asc,
        EV_QTY_Event_Quantity asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_QTY_Event_Quantity_Annex table (of EV_QTY_Event_Quantity_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_QTY_Event_Quantity_Annex', 'U') IS NULL
CREATE TABLE [dbo].[EV_QTY_Event_Quantity_Annex] (
    EV_QTY_ID int not null,
    EV_QTY_PositedAt datetime2 not null,
    EV_QTY_Positor tinyint not null,
    EV_QTY_Reliability decimal(5,2) not null,
    EV_QTY_Assertion as cast(
        case
            when EV_QTY_Reliability > 0 then '+'
            when EV_QTY_Reliability = 0 then '?'
            when EV_QTY_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_QTY int not null,
    constraint fkEV_QTY_Event_Quantity_Annex foreign key (
        EV_QTY_ID
    ) references [dbo].[EV_QTY_Event_Quantity_Posit](EV_QTY_ID),
    constraint pkEV_QTY_Event_Quantity_Annex primary key clustered (
        EV_QTY_ID asc,
        EV_QTY_Positor asc,
        EV_QTY_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_PLC_Event_Place_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_PLC_Event_Place_Posit', 'U') IS NULL
CREATE TABLE [dbo].[EV_PLC_Event_Place_Posit] (
    EV_PLC_ID int IDENTITY(1,1) not null,
    EV_PLC_EV_ID int not null,
    EV_PLC_Event_Place nvarchar(42) not null,
    EV_PLC_ChangedAt datetime2 not null,
    constraint fkEV_PLC_Event_Place_Posit foreign key (
        EV_PLC_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_PLC_Event_Place_Posit primary key nonclustered (
        EV_PLC_ID asc
    ),
    constraint uqEV_PLC_Event_Place_Posit unique clustered (
        EV_PLC_EV_ID asc,
        EV_PLC_ChangedAt desc,
        EV_PLC_Event_Place asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_PLC_Event_Place_Annex table (of EV_PLC_Event_Place_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_PLC_Event_Place_Annex', 'U') IS NULL
CREATE TABLE [dbo].[EV_PLC_Event_Place_Annex] (
    EV_PLC_ID int not null,
    EV_PLC_PositedAt datetime2 not null,
    EV_PLC_Positor tinyint not null,
    EV_PLC_Reliability decimal(5,2) not null,
    EV_PLC_Assertion as cast(
        case
            when EV_PLC_Reliability > 0 then '+'
            when EV_PLC_Reliability = 0 then '?'
            when EV_PLC_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_PLC int not null,
    constraint fkEV_PLC_Event_Place_Annex foreign key (
        EV_PLC_ID
    ) references [dbo].[EV_PLC_Event_Place_Posit](EV_PLC_ID),
    constraint pkEV_PLC_Event_Place_Annex primary key clustered (
        EV_PLC_ID asc,
        EV_PLC_Positor asc,
        EV_PLC_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- SU_NAM_Subject_Name_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_NAM_Subject_Name_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_NAM_Subject_Name_Posit] (
    SU_NAM_ID int IDENTITY(1,1) not null,
    SU_NAM_SU_ID int not null,
    SU_NAM_Subject_Name nvarchar(42) not null,
    constraint fkSU_NAM_Subject_Name_Posit foreign key (
        SU_NAM_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_NAM_Subject_Name_Posit primary key nonclustered (
        SU_NAM_ID asc
    ),
    constraint uqSU_NAM_Subject_Name_Posit unique clustered (
        SU_NAM_SU_ID asc,
        SU_NAM_Subject_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name_Annex table (of SU_NAM_Subject_Name_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_NAM_Subject_Name_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_NAM_Subject_Name_Annex] (
    SU_NAM_ID int not null,
    SU_NAM_PositedAt datetime2 not null,
    SU_NAM_Positor tinyint not null,
    SU_NAM_Reliability decimal(5,2) not null,
    SU_NAM_Assertion as cast(
        case
            when SU_NAM_Reliability > 0 then '+'
            when SU_NAM_Reliability = 0 then '?'
            when SU_NAM_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_NAM int not null,
    constraint fkSU_NAM_Subject_Name_Annex foreign key (
        SU_NAM_ID
    ) references [dbo].[SU_NAM_Subject_Name_Posit](SU_NAM_ID),
    constraint pkSU_NAM_Subject_Name_Annex primary key clustered (
        SU_NAM_ID asc,
        SU_NAM_Positor asc,
        SU_NAM_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- SU_COD_Subject_Code_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_COD_Subject_Code_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_COD_Subject_Code_Posit] (
    SU_COD_ID int IDENTITY(1,1) not null,
    SU_COD_SU_ID int not null,
    SU_COD_Subject_Code nvarchar(42) not null,
    constraint fkSU_COD_Subject_Code_Posit foreign key (
        SU_COD_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_COD_Subject_Code_Posit primary key nonclustered (
        SU_COD_ID asc
    ),
    constraint uqSU_COD_Subject_Code_Posit unique clustered (
        SU_COD_SU_ID asc,
        SU_COD_Subject_Code asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_COD_Subject_Code_Annex table (of SU_COD_Subject_Code_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_COD_Subject_Code_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_COD_Subject_Code_Annex] (
    SU_COD_ID int not null,
    SU_COD_PositedAt datetime2 not null,
    SU_COD_Positor tinyint not null,
    SU_COD_Reliability decimal(5,2) not null,
    SU_COD_Assertion as cast(
        case
            when SU_COD_Reliability > 0 then '+'
            when SU_COD_Reliability = 0 then '?'
            when SU_COD_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_COD int not null,
    constraint fkSU_COD_Subject_Code_Annex foreign key (
        SU_COD_ID
    ) references [dbo].[SU_COD_Subject_Code_Posit](SU_COD_ID),
    constraint pkSU_COD_Subject_Code_Annex primary key clustered (
        SU_COD_ID asc,
        SU_COD_Positor asc,
        SU_COD_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_GRD_Subject_Grade_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_GRD_Subject_Grade_Posit] (
    SU_GRD_ID int IDENTITY(1,1) not null,
    SU_GRD_SU_ID int not null,
    SU_GRD_GRD_ID tinyint not null,
    constraint fk_A_SU_GRD_Subject_Grade_Posit foreign key (
        SU_GRD_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint fk_K_SU_GRD_Subject_Grade_Posit foreign key (
        SU_GRD_GRD_ID
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_GRD_Subject_Grade_Posit primary key nonclustered (
        SU_GRD_ID asc
    ),
    constraint uqSU_GRD_Subject_Grade_Posit unique clustered (
        SU_GRD_SU_ID asc,
        SU_GRD_GRD_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade_Annex table (of SU_GRD_Subject_Grade_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_GRD_Subject_Grade_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_GRD_Subject_Grade_Annex] (
    SU_GRD_ID int not null,
    SU_GRD_PositedAt datetime2 not null,
    SU_GRD_Positor tinyint not null,
    SU_GRD_Reliability decimal(5,2) not null,
    SU_GRD_Assertion as cast(
        case
            when SU_GRD_Reliability > 0 then '+'
            when SU_GRD_Reliability = 0 then '?'
            when SU_GRD_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_GRD int not null,
    constraint fkSU_GRD_Subject_Grade_Annex foreign key (
        SU_GRD_ID
    ) references [dbo].[SU_GRD_Subject_Grade_Posit](SU_GRD_ID),
    constraint pkSU_GRD_Subject_Grade_Annex primary key clustered (
        SU_GRD_ID asc,
        SU_GRD_Positor asc,
        SU_GRD_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- SU_NOT_Subject_Note_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_NOT_Subject_Note_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_NOT_Subject_Note_Posit] (
    SU_NOT_ID int IDENTITY(1,1) not null,
    SU_NOT_SU_ID int not null,
    SU_NOT_Subject_Note nvarchar(max) not null,
    SU_NOT_Checksum as cast(dbo.MD5(cast(SU_NOT_Subject_Note as varbinary(max))) as varbinary(16)) persisted,
    constraint fkSU_NOT_Subject_Note_Posit foreign key (
        SU_NOT_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_NOT_Subject_Note_Posit primary key nonclustered (
        SU_NOT_ID asc
    ),
    constraint uqSU_NOT_Subject_Note_Posit unique clustered (
        SU_NOT_SU_ID asc,
        SU_NOT_Checksum asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_NOT_Subject_Note_Annex table (of SU_NOT_Subject_Note_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_NOT_Subject_Note_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_NOT_Subject_Note_Annex] (
    SU_NOT_ID int not null,
    SU_NOT_PositedAt datetime2 not null,
    SU_NOT_Positor tinyint not null,
    SU_NOT_Reliability decimal(5,2) not null,
    SU_NOT_Assertion as cast(
        case
            when SU_NOT_Reliability > 0 then '+'
            when SU_NOT_Reliability = 0 then '?'
            when SU_NOT_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_NOT int not null,
    constraint fkSU_NOT_Subject_Note_Annex foreign key (
        SU_NOT_ID
    ) references [dbo].[SU_NOT_Subject_Note_Posit](SU_NOT_ID),
    constraint pkSU_NOT_Subject_Note_Annex primary key clustered (
        SU_NOT_ID asc,
        SU_NOT_Positor asc,
        SU_NOT_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_TTL_Subject_Title_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TTL_Subject_Title_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_TTL_Subject_Title_Posit] (
    SU_TTL_ID int IDENTITY(1,1) not null,
    SU_TTL_SU_ID int not null,
    SU_TTL_Subject_Title nvarchar(42) not null,
    SU_TTL_ChangedAt datetime2 not null,
    constraint fkSU_TTL_Subject_Title_Posit foreign key (
        SU_TTL_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_TTL_Subject_Title_Posit primary key nonclustered (
        SU_TTL_ID asc
    ),
    constraint uqSU_TTL_Subject_Title_Posit unique clustered (
        SU_TTL_SU_ID asc,
        SU_TTL_ChangedAt desc,
        SU_TTL_Subject_Title asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_TTL_Subject_Title_Annex table (of SU_TTL_Subject_Title_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TTL_Subject_Title_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_TTL_Subject_Title_Annex] (
    SU_TTL_ID int not null,
    SU_TTL_PositedAt datetime2 not null,
    SU_TTL_Positor tinyint not null,
    SU_TTL_Reliability decimal(5,2) not null,
    SU_TTL_Assertion as cast(
        case
            when SU_TTL_Reliability > 0 then '+'
            when SU_TTL_Reliability = 0 then '?'
            when SU_TTL_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_TTL int not null,
    constraint fkSU_TTL_Subject_Title_Annex foreign key (
        SU_TTL_ID
    ) references [dbo].[SU_TTL_Subject_Title_Posit](SU_TTL_ID),
    constraint pkSU_TTL_Subject_Title_Annex primary key clustered (
        SU_TTL_ID asc,
        SU_TTL_Positor asc,
        SU_TTL_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_STA_Subject_State_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_STA_Subject_State_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_STA_Subject_State_Posit] (
    SU_STA_ID int IDENTITY(1,1) not null,
    SU_STA_SU_ID int not null,
    SU_STA_Subject_State nvarchar(42) not null,
    SU_STA_ChangedAt datetime2 not null,
    constraint fkSU_STA_Subject_State_Posit foreign key (
        SU_STA_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_STA_Subject_State_Posit primary key nonclustered (
        SU_STA_ID asc
    ),
    constraint uqSU_STA_Subject_State_Posit unique clustered (
        SU_STA_SU_ID asc,
        SU_STA_ChangedAt desc,
        SU_STA_Subject_State asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_STA_Subject_State_Annex table (of SU_STA_Subject_State_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_STA_Subject_State_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_STA_Subject_State_Annex] (
    SU_STA_ID int not null,
    SU_STA_PositedAt datetime2 not null,
    SU_STA_Positor tinyint not null,
    SU_STA_Reliability decimal(5,2) not null,
    SU_STA_Assertion as cast(
        case
            when SU_STA_Reliability > 0 then '+'
            when SU_STA_Reliability = 0 then '?'
            when SU_STA_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_STA int not null,
    constraint fkSU_STA_Subject_State_Annex foreign key (
        SU_STA_ID
    ) references [dbo].[SU_STA_Subject_State_Posit](SU_STA_ID),
    constraint pkSU_STA_Subject_State_Annex primary key clustered (
        SU_STA_ID asc,
        SU_STA_Positor asc,
        SU_STA_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_LBL_Subject_Label_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_LBL_Subject_Label_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_LBL_Subject_Label_Posit] (
    SU_LBL_ID int IDENTITY(1,1) not null,
    SU_LBL_SU_ID int not null,
    SU_LBL_Subject_Label nvarchar(42) not null,
    SU_LBL_ChangedAt datetime2 not null,
    constraint fkSU_LBL_Subject_Label_Posit foreign key (
        SU_LBL_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_LBL_Subject_Label_Posit primary key nonclustered (
        SU_LBL_ID asc
    ),
    constraint uqSU_LBL_Subject_Label_Posit unique clustered (
        SU_LBL_SU_ID asc,
        SU_LBL_ChangedAt desc,
        SU_LBL_Subject_Label asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_LBL_Subject_Label_Annex table (of SU_LBL_Subject_Label_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_LBL_Subject_Label_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_LBL_Subject_Label_Annex] (
    SU_LBL_ID int not null,
    SU_LBL_PositedAt datetime2 not null,
    SU_LBL_Positor tinyint not null,
    SU_LBL_Reliability decimal(5,2) not null,
    SU_LBL_Assertion as cast(
        case
            when SU_LBL_Reliability > 0 then '+'
            when SU_LBL_Reliability = 0 then '?'
            when SU_LBL_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_LBL int not null,
    constraint fkSU_LBL_Subject_Label_Annex foreign key (
        SU_LBL_ID
    ) references [dbo].[SU_LBL_Subject_Label_Posit](SU_LBL_ID),
    constraint pkSU_LBL_Subject_Label_Annex primary key clustered (
        SU_LBL_ID asc,
        SU_LBL_Positor asc,
        SU_LBL_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TAG_Subject_Tag_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_TAG_Subject_Tag_Posit] (
    SU_TAG_ID int IDENTITY(1,1) not null,
    SU_TAG_SU_ID int not null,
    SU_TAG_Subject_Tag nvarchar(42) not null,
    SU_TAG_ChangedAt datetime2 not null,
    constraint fkSU_TAG_Subject_Tag_Posit foreign key (
        SU_TAG_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_TAG_Subject_Tag_Posit primary key nonclustered (
        SU_TAG_ID asc
    ),
    constraint uqSU_TAG_Subject_Tag_Posit unique clustered (
        SU_TAG_SU_ID asc,
        SU_TAG_ChangedAt desc,
        SU_TAG_Subject_Tag asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag_Annex table (of SU_TAG_Subject_Tag_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TAG_Subject_Tag_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_TAG_Subject_Tag_Annex] (
    SU_TAG_ID int not null,
    SU_TAG_PositedAt datetime2 not null,
    SU_TAG_Positor tinyint not null,
    SU_TAG_Reliability decimal(5,2) not null,
    SU_TAG_Assertion as cast(
        case
            when SU_TAG_Reliability > 0 then '+'
            when SU_TAG_Reliability = 0 then '?'
            when SU_TAG_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_TAG int not null,
    constraint fkSU_TAG_Subject_Tag_Annex foreign key (
        SU_TAG_ID
    ) references [dbo].[SU_TAG_Subject_Tag_Posit](SU_TAG_ID),
    constraint pkSU_TAG_Subject_Tag_Annex primary key clustered (
        SU_TAG_ID asc,
        SU_TAG_Positor asc,
        SU_TAG_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- SU_LVL_Subject_Level_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_LVL_Subject_Level_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_LVL_Subject_Level_Posit] (
    SU_LVL_ID int IDENTITY(1,1) not null,
    SU_LVL_SU_ID int not null,
    SU_LVL_GRD_ID tinyint not null,
    SU_LVL_ChangedAt datetime2 not null,
    constraint fk_A_SU_LVL_Subject_Level_Posit foreign key (
        SU_LVL_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint fk_K_SU_LVL_Subject_Level_Posit foreign key (
        SU_LVL_GRD_ID
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_LVL_Subject_Level_Posit primary key nonclustered (
        SU_LVL_ID asc
    ),
    constraint uqSU_LVL_Subject_Level_Posit unique clustered (
        SU_LVL_SU_ID asc,
        SU_LVL_ChangedAt desc,
        SU_LVL_GRD_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_LVL_Subject_Level_Annex table (of SU_LVL_Subject_Level_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_LVL_Subject_Level_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_LVL_Subject_Level_Annex] (
    SU_LVL_ID int not null,
    SU_LVL_PositedAt datetime2 not null,
    SU_LVL_Positor tinyint not null,
    SU_LVL_Reliability decimal(5,2) not null,
    SU_LVL_Assertion as cast(
        case
            when SU_LVL_Reliability > 0 then '+'
            when SU_LVL_Reliability = 0 then '?'
            when SU_LVL_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_LVL int not null,
    constraint fkSU_LVL_Subject_Level_Annex foreign key (
        SU_LVL_ID
    ) references [dbo].[SU_LVL_Subject_Level_Posit](SU_LVL_ID),
    constraint pkSU_LVL_Subject_Level_Annex primary key clustered (
        SU_LVL_ID asc,
        SU_LVL_Positor asc,
        SU_LVL_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_TXT_Subject_Text_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TXT_Subject_Text_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_TXT_Subject_Text_Posit] (
    SU_TXT_ID int IDENTITY(1,1) not null,
    SU_TXT_SU_ID int not null,
    SU_TXT_Subject_Text nvarchar(max) not null,
    SU_TXT_Checksum as cast(dbo.MD5(cast(SU_TXT_Subject_Text as varbinary(max))) as varbinary(16)) persisted,
    SU_TXT_ChangedAt datetime2 not null,
    constraint fkSU_TXT_Subject_Text_Posit foreign key (
        SU_TXT_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_TXT_Subject_Text_Posit primary key nonclustered (
        SU_TXT_ID asc
    ),
    constraint uqSU_TXT_Subject_Text_Posit unique clustered (
        SU_TXT_SU_ID asc,
        SU_TXT_ChangedAt desc,
        SU_TXT_Checksum asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_TXT_Subject_Text_Annex table (of SU_TXT_Subject_Text_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TXT_Subject_Text_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_TXT_Subject_Text_Annex] (
    SU_TXT_ID int not null,
    SU_TXT_PositedAt datetime2 not null,
    SU_TXT_Positor tinyint not null,
    SU_TXT_Reliability decimal(5,2) not null,
    SU_TXT_Assertion as cast(
        case
            when SU_TXT_Reliability > 0 then '+'
            when SU_TXT_Reliability = 0 then '?'
            when SU_TXT_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_TXT int not null,
    constraint fkSU_TXT_Subject_Text_Annex foreign key (
        SU_TXT_ID
    ) references [dbo].[SU_TXT_Subject_Text_Posit](SU_TXT_ID),
    constraint pkSU_TXT_Subject_Text_Annex primary key clustered (
        SU_TXT_ID asc,
        SU_TXT_Positor asc,
        SU_TXT_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_ASR_Subject_Assessment_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_ASR_Subject_Assessment_Posit] (
    SU_ASR_ID int IDENTITY(1,1) not null,
    SU_ASR_SU_ID int not null,
    SU_ASR_Subject_Assessment nvarchar(42) not null,
    SU_ASR_ChangedAt datetime2 not null,
    constraint fkSU_ASR_Subject_Assessment_Posit foreign key (
        SU_ASR_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_ASR_Subject_Assessment_Posit primary key nonclustered (
        SU_ASR_ID asc
    ),
    constraint uqSU_ASR_Subject_Assessment_Posit unique clustered (
        SU_ASR_SU_ID asc,
        SU_ASR_ChangedAt desc,
        SU_ASR_Subject_Assessment asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment_Annex table (of SU_ASR_Subject_Assessment_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_ASR_Subject_Assessment_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_ASR_Subject_Assessment_Annex] (
    SU_ASR_ID int not null,
    SU_ASR_PositedAt datetime2 not null,
    SU_ASR_Positor tinyint not null,
    SU_ASR_Reliability decimal(5,2) not null,
    SU_ASR_Assertion as cast(
        case
            when SU_ASR_Reliability > 0 then '+'
            when SU_ASR_Reliability = 0 then '?'
            when SU_ASR_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_ASR int not null,
    constraint fkSU_ASR_Subject_Assessment_Annex foreign key (
        SU_ASR_ID
    ) references [dbo].[SU_ASR_Subject_Assessment_Posit](SU_ASR_ID),
    constraint pkSU_ASR_Subject_Assessment_Annex primary key clustered (
        SU_ASR_ID asc,
        SU_ASR_Positor asc,
        SU_ASR_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_ERS_Subject_Erasable_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_ERS_Subject_Erasable_Posit] (
    SU_ERS_ID int IDENTITY(1,1) not null,
    SU_ERS_SU_ID int not null,
    SU_ERS_Subject_Erasable nvarchar(42) not null,
    SU_ERS_ChangedAt datetime2 not null,
    constraint fkSU_ERS_Subject_Erasable_Posit foreign key (
        SU_ERS_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_ERS_Subject_Erasable_Posit primary key nonclustered (
        SU_ERS_ID asc
    ),
    constraint uqSU_ERS_Subject_Erasable_Posit unique clustered (
        SU_ERS_SU_ID asc,
        SU_ERS_ChangedAt desc,
        SU_ERS_Subject_Erasable asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable_Annex table (of SU_ERS_Subject_Erasable_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_ERS_Subject_Erasable_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_ERS_Subject_Erasable_Annex] (
    SU_ERS_ID int not null,
    SU_ERS_PositedAt datetime2 not null,
    SU_ERS_Positor tinyint not null,
    SU_ERS_Reliability decimal(5,2) not null,
    SU_ERS_Assertion as cast(
        case
            when SU_ERS_Reliability > 0 then '+'
            when SU_ERS_Reliability = 0 then '?'
            when SU_ERS_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_ERS int not null,
    constraint fkSU_ERS_Subject_Erasable_Annex foreign key (
        SU_ERS_ID
    ) references [dbo].[SU_ERS_Subject_Erasable_Posit](SU_ERS_ID),
    constraint pkSU_ERS_Subject_Erasable_Annex primary key clustered (
        SU_ERS_ID asc,
        SU_ERS_Positor asc,
        SU_ERS_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- OB_NAM_Object_Name_Posit table (on OB_Object)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_NAM_Object_Name_Posit', 'U') IS NULL
CREATE TABLE [dbo].[OB_NAM_Object_Name_Posit] (
    OB_NAM_ID int IDENTITY(1,1) not null,
    OB_NAM_OB_ID int not null,
    OB_NAM_Object_Name nvarchar(42) not null,
    constraint fkOB_NAM_Object_Name_Posit foreign key (
        OB_NAM_OB_ID
    ) references [dbo].[OB_Object](OB_ID),
    constraint pkOB_NAM_Object_Name_Posit primary key nonclustered (
        OB_NAM_ID asc
    ),
    constraint uqOB_NAM_Object_Name_Posit unique clustered (
        OB_NAM_OB_ID asc,
        OB_NAM_Object_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- OB_NAM_Object_Name_Annex table (of OB_NAM_Object_Name_Posit on OB_Object)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_NAM_Object_Name_Annex', 'U') IS NULL
CREATE TABLE [dbo].[OB_NAM_Object_Name_Annex] (
    OB_NAM_ID int not null,
    OB_NAM_PositedAt datetime2 not null,
    OB_NAM_Positor tinyint not null,
    OB_NAM_Reliability decimal(5,2) not null,
    OB_NAM_Assertion as cast(
        case
            when OB_NAM_Reliability > 0 then '+'
            when OB_NAM_Reliability = 0 then '?'
            when OB_NAM_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_OB_NAM int not null,
    constraint fkOB_NAM_Object_Name_Annex foreign key (
        OB_NAM_ID
    ) references [dbo].[OB_NAM_Object_Name_Posit](OB_NAM_ID),
    constraint pkOB_NAM_Object_Name_Annex primary key clustered (
        OB_NAM_ID asc,
        OB_NAM_Positor asc,
        OB_NAM_PositedAt desc
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
-- EV_QTY_Event_Quantity assembled view of the posit and annex tables,
-- pkEV_QTY_Event_Quantity optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_QTY_Event_Quantity', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_QTY_Event_Quantity]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_QTY,
        p.EV_QTY_ID,
        p.EV_QTY_EV_ID,
        p.EV_QTY_Event_Quantity,
        a.EV_QTY_PositedAt,
        a.EV_QTY_Positor,
        a.EV_QTY_Reliability,
        a.EV_QTY_Assertion
    FROM
        [dbo].[EV_QTY_Event_Quantity_Posit] p
    JOIN
        [dbo].[EV_QTY_Event_Quantity_Annex] a
    ON
        a.EV_QTY_ID = p.EV_QTY_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_QTY_Event_Quantity]
    ON [dbo].[EV_QTY_Event_Quantity] (
        EV_QTY_ID asc,
        EV_QTY_PositedAt desc,
        EV_QTY_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_PLC_Event_Place assembled view of the posit and annex tables,
-- pkEV_PLC_Event_Place optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_PLC_Event_Place', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_PLC_Event_Place]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_PLC,
        p.EV_PLC_ID,
        p.EV_PLC_EV_ID,
        p.EV_PLC_Event_Place,
        p.EV_PLC_ChangedAt,
        a.EV_PLC_PositedAt,
        a.EV_PLC_Positor,
        a.EV_PLC_Reliability,
        a.EV_PLC_Assertion
    FROM
        [dbo].[EV_PLC_Event_Place_Posit] p
    JOIN
        [dbo].[EV_PLC_Event_Place_Annex] a
    ON
        a.EV_PLC_ID = p.EV_PLC_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_PLC_Event_Place]
    ON [dbo].[EV_PLC_Event_Place] (
        EV_PLC_ID asc,
        EV_PLC_PositedAt desc,
        EV_PLC_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name assembled view of the posit and annex tables,
-- pkSU_NAM_Subject_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_NAM_Subject_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_NAM_Subject_Name]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_NAM,
        p.SU_NAM_ID,
        p.SU_NAM_SU_ID,
        p.SU_NAM_Subject_Name,
        a.SU_NAM_PositedAt,
        a.SU_NAM_Positor,
        a.SU_NAM_Reliability,
        a.SU_NAM_Assertion
    FROM
        [dbo].[SU_NAM_Subject_Name_Posit] p
    JOIN
        [dbo].[SU_NAM_Subject_Name_Annex] a
    ON
        a.SU_NAM_ID = p.SU_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_NAM_Subject_Name]
    ON [dbo].[SU_NAM_Subject_Name] (
        SU_NAM_ID asc,
        SU_NAM_PositedAt desc,
        SU_NAM_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_COD_Subject_Code assembled view of the posit and annex tables,
-- pkSU_COD_Subject_Code optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_COD_Subject_Code', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_COD_Subject_Code]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_COD,
        p.SU_COD_ID,
        p.SU_COD_SU_ID,
        p.SU_COD_Subject_Code,
        a.SU_COD_PositedAt,
        a.SU_COD_Positor,
        a.SU_COD_Reliability,
        a.SU_COD_Assertion
    FROM
        [dbo].[SU_COD_Subject_Code_Posit] p
    JOIN
        [dbo].[SU_COD_Subject_Code_Annex] a
    ON
        a.SU_COD_ID = p.SU_COD_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_COD_Subject_Code]
    ON [dbo].[SU_COD_Subject_Code] (
        SU_COD_ID asc,
        SU_COD_PositedAt desc,
        SU_COD_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade assembled view of the posit and annex tables,
-- pkSU_GRD_Subject_Grade optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_GRD_Subject_Grade', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_GRD_Subject_Grade]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_GRD,
        p.SU_GRD_ID,
        p.SU_GRD_SU_ID,
        p.SU_GRD_GRD_ID,
        a.SU_GRD_PositedAt,
        a.SU_GRD_Positor,
        a.SU_GRD_Reliability,
        a.SU_GRD_Assertion
    FROM
        [dbo].[SU_GRD_Subject_Grade_Posit] p
    JOIN
        [dbo].[SU_GRD_Subject_Grade_Annex] a
    ON
        a.SU_GRD_ID = p.SU_GRD_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_GRD_Subject_Grade]
    ON [dbo].[SU_GRD_Subject_Grade] (
        SU_GRD_ID asc,
        SU_GRD_PositedAt desc,
        SU_GRD_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_NOT_Subject_Note assembled view of the posit and annex tables,
-- pkSU_NOT_Subject_Note optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_NOT_Subject_Note', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_NOT_Subject_Note]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_NOT,
        p.SU_NOT_ID,
        p.SU_NOT_SU_ID,
        p.SU_NOT_Checksum,
        p.SU_NOT_Subject_Note,
        a.SU_NOT_PositedAt,
        a.SU_NOT_Positor,
        a.SU_NOT_Reliability,
        a.SU_NOT_Assertion
    FROM
        [dbo].[SU_NOT_Subject_Note_Posit] p
    JOIN
        [dbo].[SU_NOT_Subject_Note_Annex] a
    ON
        a.SU_NOT_ID = p.SU_NOT_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_NOT_Subject_Note]
    ON [dbo].[SU_NOT_Subject_Note] (
        SU_NOT_ID asc,
        SU_NOT_PositedAt desc,
        SU_NOT_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_TTL_Subject_Title assembled view of the posit and annex tables,
-- pkSU_TTL_Subject_Title optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TTL_Subject_Title', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_TTL_Subject_Title]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_TTL,
        p.SU_TTL_ID,
        p.SU_TTL_SU_ID,
        p.SU_TTL_Subject_Title,
        p.SU_TTL_ChangedAt,
        a.SU_TTL_PositedAt,
        a.SU_TTL_Positor,
        a.SU_TTL_Reliability,
        a.SU_TTL_Assertion
    FROM
        [dbo].[SU_TTL_Subject_Title_Posit] p
    JOIN
        [dbo].[SU_TTL_Subject_Title_Annex] a
    ON
        a.SU_TTL_ID = p.SU_TTL_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_TTL_Subject_Title]
    ON [dbo].[SU_TTL_Subject_Title] (
        SU_TTL_ID asc,
        SU_TTL_PositedAt desc,
        SU_TTL_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_STA_Subject_State assembled view of the posit and annex tables,
-- pkSU_STA_Subject_State optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_STA_Subject_State', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_STA_Subject_State]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_STA,
        p.SU_STA_ID,
        p.SU_STA_SU_ID,
        p.SU_STA_Subject_State,
        p.SU_STA_ChangedAt,
        a.SU_STA_PositedAt,
        a.SU_STA_Positor,
        a.SU_STA_Reliability,
        a.SU_STA_Assertion
    FROM
        [dbo].[SU_STA_Subject_State_Posit] p
    JOIN
        [dbo].[SU_STA_Subject_State_Annex] a
    ON
        a.SU_STA_ID = p.SU_STA_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_STA_Subject_State]
    ON [dbo].[SU_STA_Subject_State] (
        SU_STA_ID asc,
        SU_STA_PositedAt desc,
        SU_STA_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_LBL_Subject_Label assembled view of the posit and annex tables,
-- pkSU_LBL_Subject_Label optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_LBL_Subject_Label', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_LBL_Subject_Label]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_LBL,
        p.SU_LBL_ID,
        p.SU_LBL_SU_ID,
        p.SU_LBL_Subject_Label,
        p.SU_LBL_ChangedAt,
        a.SU_LBL_PositedAt,
        a.SU_LBL_Positor,
        a.SU_LBL_Reliability,
        a.SU_LBL_Assertion
    FROM
        [dbo].[SU_LBL_Subject_Label_Posit] p
    JOIN
        [dbo].[SU_LBL_Subject_Label_Annex] a
    ON
        a.SU_LBL_ID = p.SU_LBL_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_LBL_Subject_Label]
    ON [dbo].[SU_LBL_Subject_Label] (
        SU_LBL_ID asc,
        SU_LBL_PositedAt desc,
        SU_LBL_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag assembled view of the posit and annex tables,
-- pkSU_TAG_Subject_Tag optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TAG_Subject_Tag', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_TAG_Subject_Tag]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_TAG,
        p.SU_TAG_ID,
        p.SU_TAG_SU_ID,
        p.SU_TAG_Subject_Tag,
        p.SU_TAG_ChangedAt,
        a.SU_TAG_PositedAt,
        a.SU_TAG_Positor,
        a.SU_TAG_Reliability,
        a.SU_TAG_Assertion
    FROM
        [dbo].[SU_TAG_Subject_Tag_Posit] p
    JOIN
        [dbo].[SU_TAG_Subject_Tag_Annex] a
    ON
        a.SU_TAG_ID = p.SU_TAG_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_TAG_Subject_Tag]
    ON [dbo].[SU_TAG_Subject_Tag] (
        SU_TAG_ID asc,
        SU_TAG_PositedAt desc,
        SU_TAG_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_LVL_Subject_Level assembled view of the posit and annex tables,
-- pkSU_LVL_Subject_Level optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_LVL_Subject_Level', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_LVL_Subject_Level]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_LVL,
        p.SU_LVL_ID,
        p.SU_LVL_SU_ID,
        p.SU_LVL_GRD_ID,
        p.SU_LVL_ChangedAt,
        a.SU_LVL_PositedAt,
        a.SU_LVL_Positor,
        a.SU_LVL_Reliability,
        a.SU_LVL_Assertion
    FROM
        [dbo].[SU_LVL_Subject_Level_Posit] p
    JOIN
        [dbo].[SU_LVL_Subject_Level_Annex] a
    ON
        a.SU_LVL_ID = p.SU_LVL_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_LVL_Subject_Level]
    ON [dbo].[SU_LVL_Subject_Level] (
        SU_LVL_ID asc,
        SU_LVL_PositedAt desc,
        SU_LVL_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_TXT_Subject_Text assembled view of the posit and annex tables,
-- pkSU_TXT_Subject_Text optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TXT_Subject_Text', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_TXT_Subject_Text]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_TXT,
        p.SU_TXT_ID,
        p.SU_TXT_SU_ID,
        p.SU_TXT_Checksum,
        p.SU_TXT_Subject_Text,
        p.SU_TXT_ChangedAt,
        a.SU_TXT_PositedAt,
        a.SU_TXT_Positor,
        a.SU_TXT_Reliability,
        a.SU_TXT_Assertion
    FROM
        [dbo].[SU_TXT_Subject_Text_Posit] p
    JOIN
        [dbo].[SU_TXT_Subject_Text_Annex] a
    ON
        a.SU_TXT_ID = p.SU_TXT_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_TXT_Subject_Text]
    ON [dbo].[SU_TXT_Subject_Text] (
        SU_TXT_ID asc,
        SU_TXT_PositedAt desc,
        SU_TXT_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment assembled view of the posit and annex tables,
-- pkSU_ASR_Subject_Assessment optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_ASR_Subject_Assessment', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_ASR_Subject_Assessment]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_ASR,
        p.SU_ASR_ID,
        p.SU_ASR_SU_ID,
        p.SU_ASR_Subject_Assessment,
        p.SU_ASR_ChangedAt,
        a.SU_ASR_PositedAt,
        a.SU_ASR_Positor,
        a.SU_ASR_Reliability,
        a.SU_ASR_Assertion
    FROM
        [dbo].[SU_ASR_Subject_Assessment_Posit] p
    JOIN
        [dbo].[SU_ASR_Subject_Assessment_Annex] a
    ON
        a.SU_ASR_ID = p.SU_ASR_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_ASR_Subject_Assessment]
    ON [dbo].[SU_ASR_Subject_Assessment] (
        SU_ASR_ID asc,
        SU_ASR_PositedAt desc,
        SU_ASR_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable assembled view of the posit and annex tables,
-- pkSU_ERS_Subject_Erasable optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_ERS_Subject_Erasable', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_ERS_Subject_Erasable]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_ERS,
        p.SU_ERS_ID,
        p.SU_ERS_SU_ID,
        p.SU_ERS_Subject_Erasable,
        p.SU_ERS_ChangedAt,
        a.SU_ERS_PositedAt,
        a.SU_ERS_Positor,
        a.SU_ERS_Reliability,
        a.SU_ERS_Assertion
    FROM
        [dbo].[SU_ERS_Subject_Erasable_Posit] p
    JOIN
        [dbo].[SU_ERS_Subject_Erasable_Annex] a
    ON
        a.SU_ERS_ID = p.SU_ERS_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_ERS_Subject_Erasable]
    ON [dbo].[SU_ERS_Subject_Erasable] (
        SU_ERS_ID asc,
        SU_ERS_PositedAt desc,
        SU_ERS_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- OB_NAM_Object_Name assembled view of the posit and annex tables,
-- pkOB_NAM_Object_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_NAM_Object_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[OB_NAM_Object_Name]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_OB_NAM,
        p.OB_NAM_ID,
        p.OB_NAM_OB_ID,
        p.OB_NAM_Object_Name,
        a.OB_NAM_PositedAt,
        a.OB_NAM_Positor,
        a.OB_NAM_Reliability,
        a.OB_NAM_Assertion
    FROM
        [dbo].[OB_NAM_Object_Name_Posit] p
    JOIN
        [dbo].[OB_NAM_Object_Name_Annex] a
    ON
        a.OB_NAM_ID = p.OB_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkOB_NAM_Object_Name]
    ON [dbo].[OB_NAM_Object_Name] (
        OB_NAM_ID asc,
        OB_NAM_PositedAt desc,
        OB_NAM_Positor asc
    );
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
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_QTY_Event_Quantity_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_QTY_Event_Quantity_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_QTY_Event_Quantity_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_QTY,
        EV_QTY_ID,
        EV_QTY_PositedAt,
        EV_QTY_Positor,
        EV_QTY_Reliability,
        EV_QTY_Assertion
    FROM
        [dbo].[EV_QTY_Event_Quantity_Annex]
    WHERE
        EV_QTY_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_QTY_Event_Quantity rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_QTY_Event_Quantity','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_QTY_Event_Quantity] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_QTY,
        p.EV_QTY_ID,
        a.EV_QTY_PositedAt,
        a.EV_QTY_Positor,
        a.EV_QTY_Reliability,
        a.EV_QTY_Assertion,
        p.EV_QTY_EV_ID,
        p.EV_QTY_Event_Quantity
    FROM
        [dbo].[EV_QTY_Event_Quantity_Posit] p
    JOIN
        [dbo].[rEV_QTY_Event_Quantity_Annex](@positingTimepoint) a
    ON
        a.EV_QTY_ID = p.EV_QTY_ID
    AND
        a.EV_QTY_Positor = @positor
    AND
        a.EV_QTY_PositedAt = (
            SELECT TOP 1
                sub.EV_QTY_PositedAt
            FROM
                [dbo].[rEV_QTY_Event_Quantity_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_QTY_ID = p.EV_QTY_ID
            AND
                sub.EV_QTY_Positor = @positor
            ORDER BY
                sub.EV_QTY_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rEV_PLC_Event_Place_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_PLC_Event_Place_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_PLC_Event_Place_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_PLC_ID,
        EV_PLC_EV_ID,
        EV_PLC_Event_Place,
        EV_PLC_ChangedAt
    FROM
        [dbo].[EV_PLC_Event_Place_Posit]
    WHERE
        EV_PLC_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fEV_PLC_Event_Place_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fEV_PLC_Event_Place_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fEV_PLC_Event_Place_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_PLC_ID,
        EV_PLC_EV_ID,
        EV_PLC_Event_Place,
        EV_PLC_ChangedAt
    FROM
        [dbo].[EV_PLC_Event_Place_Posit]
    WHERE
        EV_PLC_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_PLC_Event_Place_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_PLC_Event_Place_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_PLC_Event_Place_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_PLC,
        EV_PLC_ID,
        EV_PLC_PositedAt,
        EV_PLC_Positor,
        EV_PLC_Reliability,
        EV_PLC_Assertion
    FROM
        [dbo].[EV_PLC_Event_Place_Annex]
    WHERE
        EV_PLC_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_PLC_Event_Place rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_PLC_Event_Place','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_PLC_Event_Place] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_PLC,
        p.EV_PLC_ID,
        a.EV_PLC_PositedAt,
        a.EV_PLC_Positor,
        a.EV_PLC_Reliability,
        a.EV_PLC_Assertion,
        p.EV_PLC_EV_ID,
        p.EV_PLC_Event_Place,
        p.EV_PLC_ChangedAt
    FROM
        [dbo].[rEV_PLC_Event_Place_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rEV_PLC_Event_Place_Annex](@positingTimepoint) a
    ON
        a.EV_PLC_ID = p.EV_PLC_ID
    AND
        a.EV_PLC_Positor = @positor
    AND
        a.EV_PLC_PositedAt = (
            SELECT TOP 1
                sub.EV_PLC_PositedAt
            FROM
                [dbo].[rEV_PLC_Event_Place_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_PLC_ID = p.EV_PLC_ID
            AND
                sub.EV_PLC_Positor = @positor
            ORDER BY
                sub.EV_PLC_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fEV_PLC_Event_Place forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fEV_PLC_Event_Place','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fEV_PLC_Event_Place] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_PLC,
        p.EV_PLC_ID,
        a.EV_PLC_PositedAt,
        a.EV_PLC_Positor,
        a.EV_PLC_Reliability,
        a.EV_PLC_Assertion,
        p.EV_PLC_EV_ID,
        p.EV_PLC_Event_Place,
        p.EV_PLC_ChangedAt
    FROM
        [dbo].[fEV_PLC_Event_Place_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rEV_PLC_Event_Place_Annex](@positingTimepoint) a
    ON
        a.EV_PLC_ID = p.EV_PLC_ID
    AND
        a.EV_PLC_Positor = @positor
    AND
        a.EV_PLC_PositedAt = (
            SELECT TOP 1
                sub.EV_PLC_PositedAt
            FROM
                [dbo].[rEV_PLC_Event_Place_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_PLC_ID = p.EV_PLC_ID
            AND
                sub.EV_PLC_Positor = @positor
            ORDER BY
                sub.EV_PLC_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preEV_PLC_Event_Place function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preEV_PLC_Event_Place','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preEV_PLC_Event_Place] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.EV_PLC_Event_Place
        FROM
            [dbo].[rEV_PLC_Event_Place](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.EV_PLC_EV_ID = @id
        AND
            pre.EV_PLC_ChangedAt < @changingTimepoint
        AND
            pre.EV_PLC_Assertion = isnull(@assertion, pre.EV_PLC_Assertion)
        ORDER BY
            pre.EV_PLC_ChangedAt DESC,
            pre.EV_PLC_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folEV_PLC_Event_Place function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folEV_PLC_Event_Place','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folEV_PLC_Event_Place] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.EV_PLC_Event_Place
        FROM
            [dbo].[fEV_PLC_Event_Place](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.EV_PLC_EV_ID = @id
        AND
            fol.EV_PLC_ChangedAt > @changingTimepoint
        AND
            fol.EV_PLC_Assertion = isnull(@assertion, fol.EV_PLC_Assertion)
        ORDER BY
            fol.EV_PLC_ChangedAt ASC,
            fol.EV_PLC_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_NAM_Subject_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_NAM_Subject_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_NAM_Subject_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_NAM,
        SU_NAM_ID,
        SU_NAM_PositedAt,
        SU_NAM_Positor,
        SU_NAM_Reliability,
        SU_NAM_Assertion
    FROM
        [dbo].[SU_NAM_Subject_Name_Annex]
    WHERE
        SU_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_NAM_Subject_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_NAM_Subject_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_NAM_Subject_Name] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_NAM,
        p.SU_NAM_ID,
        a.SU_NAM_PositedAt,
        a.SU_NAM_Positor,
        a.SU_NAM_Reliability,
        a.SU_NAM_Assertion,
        p.SU_NAM_SU_ID,
        p.SU_NAM_Subject_Name
    FROM
        [dbo].[SU_NAM_Subject_Name_Posit] p
    JOIN
        [dbo].[rSU_NAM_Subject_Name_Annex](@positingTimepoint) a
    ON
        a.SU_NAM_ID = p.SU_NAM_ID
    AND
        a.SU_NAM_Positor = @positor
    AND
        a.SU_NAM_PositedAt = (
            SELECT TOP 1
                sub.SU_NAM_PositedAt
            FROM
                [dbo].[rSU_NAM_Subject_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_NAM_ID = p.SU_NAM_ID
            AND
                sub.SU_NAM_Positor = @positor
            ORDER BY
                sub.SU_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_COD_Subject_Code_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_COD_Subject_Code_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_COD_Subject_Code_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_COD,
        SU_COD_ID,
        SU_COD_PositedAt,
        SU_COD_Positor,
        SU_COD_Reliability,
        SU_COD_Assertion
    FROM
        [dbo].[SU_COD_Subject_Code_Annex]
    WHERE
        SU_COD_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_COD_Subject_Code rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_COD_Subject_Code','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_COD_Subject_Code] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_COD,
        p.SU_COD_ID,
        a.SU_COD_PositedAt,
        a.SU_COD_Positor,
        a.SU_COD_Reliability,
        a.SU_COD_Assertion,
        p.SU_COD_SU_ID,
        p.SU_COD_Subject_Code
    FROM
        [dbo].[SU_COD_Subject_Code_Posit] p
    JOIN
        [dbo].[rSU_COD_Subject_Code_Annex](@positingTimepoint) a
    ON
        a.SU_COD_ID = p.SU_COD_ID
    AND
        a.SU_COD_Positor = @positor
    AND
        a.SU_COD_PositedAt = (
            SELECT TOP 1
                sub.SU_COD_PositedAt
            FROM
                [dbo].[rSU_COD_Subject_Code_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_COD_ID = p.SU_COD_ID
            AND
                sub.SU_COD_Positor = @positor
            ORDER BY
                sub.SU_COD_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_GRD_Subject_Grade_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_GRD_Subject_Grade_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_GRD_Subject_Grade_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_GRD,
        SU_GRD_ID,
        SU_GRD_PositedAt,
        SU_GRD_Positor,
        SU_GRD_Reliability,
        SU_GRD_Assertion
    FROM
        [dbo].[SU_GRD_Subject_Grade_Annex]
    WHERE
        SU_GRD_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_GRD_Subject_Grade rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_GRD_Subject_Grade','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_GRD_Subject_Grade] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_GRD,
        p.SU_GRD_ID,
        a.SU_GRD_PositedAt,
        a.SU_GRD_Positor,
        a.SU_GRD_Reliability,
        a.SU_GRD_Assertion,
        p.SU_GRD_SU_ID,
        p.SU_GRD_GRD_ID
    FROM
        [dbo].[SU_GRD_Subject_Grade_Posit] p
    JOIN
        [dbo].[rSU_GRD_Subject_Grade_Annex](@positingTimepoint) a
    ON
        a.SU_GRD_ID = p.SU_GRD_ID
    AND
        a.SU_GRD_Positor = @positor
    AND
        a.SU_GRD_PositedAt = (
            SELECT TOP 1
                sub.SU_GRD_PositedAt
            FROM
                [dbo].[rSU_GRD_Subject_Grade_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_GRD_ID = p.SU_GRD_ID
            AND
                sub.SU_GRD_Positor = @positor
            ORDER BY
                sub.SU_GRD_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_NOT_Subject_Note_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_NOT_Subject_Note_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_NOT_Subject_Note_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_NOT,
        SU_NOT_ID,
        SU_NOT_PositedAt,
        SU_NOT_Positor,
        SU_NOT_Reliability,
        SU_NOT_Assertion
    FROM
        [dbo].[SU_NOT_Subject_Note_Annex]
    WHERE
        SU_NOT_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_NOT_Subject_Note rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_NOT_Subject_Note','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_NOT_Subject_Note] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_NOT,
        p.SU_NOT_ID,
        a.SU_NOT_PositedAt,
        a.SU_NOT_Positor,
        a.SU_NOT_Reliability,
        a.SU_NOT_Assertion,
        p.SU_NOT_SU_ID,
        p.SU_NOT_Checksum,
        p.SU_NOT_Subject_Note
    FROM
        [dbo].[SU_NOT_Subject_Note_Posit] p
    JOIN
        [dbo].[rSU_NOT_Subject_Note_Annex](@positingTimepoint) a
    ON
        a.SU_NOT_ID = p.SU_NOT_ID
    AND
        a.SU_NOT_Positor = @positor
    AND
        a.SU_NOT_PositedAt = (
            SELECT TOP 1
                sub.SU_NOT_PositedAt
            FROM
                [dbo].[rSU_NOT_Subject_Note_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_NOT_ID = p.SU_NOT_ID
            AND
                sub.SU_NOT_Positor = @positor
            ORDER BY
                sub.SU_NOT_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TTL_Subject_Title_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TTL_Subject_Title_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TTL_ID,
        SU_TTL_SU_ID,
        SU_TTL_Subject_Title,
        SU_TTL_ChangedAt
    FROM
        [dbo].[SU_TTL_Subject_Title_Posit]
    WHERE
        SU_TTL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_TTL_Subject_Title_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TTL_Subject_Title_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TTL_Subject_Title_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TTL_ID,
        SU_TTL_SU_ID,
        SU_TTL_Subject_Title,
        SU_TTL_ChangedAt
    FROM
        [dbo].[SU_TTL_Subject_Title_Posit]
    WHERE
        SU_TTL_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TTL_Subject_Title_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TTL_Subject_Title_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_TTL,
        SU_TTL_ID,
        SU_TTL_PositedAt,
        SU_TTL_Positor,
        SU_TTL_Reliability,
        SU_TTL_Assertion
    FROM
        [dbo].[SU_TTL_Subject_Title_Annex]
    WHERE
        SU_TTL_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TTL_Subject_Title','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TTL_Subject_Title] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TTL,
        p.SU_TTL_ID,
        a.SU_TTL_PositedAt,
        a.SU_TTL_Positor,
        a.SU_TTL_Reliability,
        a.SU_TTL_Assertion,
        p.SU_TTL_SU_ID,
        p.SU_TTL_Subject_Title,
        p.SU_TTL_ChangedAt
    FROM
        [dbo].[rSU_TTL_Subject_Title_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TTL_Subject_Title_Annex](@positingTimepoint) a
    ON
        a.SU_TTL_ID = p.SU_TTL_ID
    AND
        a.SU_TTL_Positor = @positor
    AND
        a.SU_TTL_PositedAt = (
            SELECT TOP 1
                sub.SU_TTL_PositedAt
            FROM
                [dbo].[rSU_TTL_Subject_Title_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TTL_ID = p.SU_TTL_ID
            AND
                sub.SU_TTL_Positor = @positor
            ORDER BY
                sub.SU_TTL_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_TTL_Subject_Title forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TTL_Subject_Title','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TTL_Subject_Title] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TTL,
        p.SU_TTL_ID,
        a.SU_TTL_PositedAt,
        a.SU_TTL_Positor,
        a.SU_TTL_Reliability,
        a.SU_TTL_Assertion,
        p.SU_TTL_SU_ID,
        p.SU_TTL_Subject_Title,
        p.SU_TTL_ChangedAt
    FROM
        [dbo].[fSU_TTL_Subject_Title_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TTL_Subject_Title_Annex](@positingTimepoint) a
    ON
        a.SU_TTL_ID = p.SU_TTL_ID
    AND
        a.SU_TTL_Positor = @positor
    AND
        a.SU_TTL_PositedAt = (
            SELECT TOP 1
                sub.SU_TTL_PositedAt
            FROM
                [dbo].[rSU_TTL_Subject_Title_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TTL_ID = p.SU_TTL_ID
            AND
                sub.SU_TTL_Positor = @positor
            ORDER BY
                sub.SU_TTL_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_TTL_Subject_Title function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_TTL_Subject_Title','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_TTL_Subject_Title] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_TTL_Subject_Title
        FROM
            [dbo].[rSU_TTL_Subject_Title](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_TTL_SU_ID = @id
        AND
            pre.SU_TTL_ChangedAt < @changingTimepoint
        AND
            pre.SU_TTL_Assertion = isnull(@assertion, pre.SU_TTL_Assertion)
        ORDER BY
            pre.SU_TTL_ChangedAt DESC,
            pre.SU_TTL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_TTL_Subject_Title function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_TTL_Subject_Title','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_TTL_Subject_Title] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_TTL_Subject_Title
        FROM
            [dbo].[fSU_TTL_Subject_Title](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_TTL_SU_ID = @id
        AND
            fol.SU_TTL_ChangedAt > @changingTimepoint
        AND
            fol.SU_TTL_Assertion = isnull(@assertion, fol.SU_TTL_Assertion)
        ORDER BY
            fol.SU_TTL_ChangedAt ASC,
            fol.SU_TTL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_STA_Subject_State_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_STA_Subject_State_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_STA_Subject_State_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_STA_ID,
        SU_STA_SU_ID,
        SU_STA_Subject_State,
        SU_STA_ChangedAt
    FROM
        [dbo].[SU_STA_Subject_State_Posit]
    WHERE
        SU_STA_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_STA_Subject_State_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_STA_Subject_State_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_STA_Subject_State_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_STA_ID,
        SU_STA_SU_ID,
        SU_STA_Subject_State,
        SU_STA_ChangedAt
    FROM
        [dbo].[SU_STA_Subject_State_Posit]
    WHERE
        SU_STA_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_STA_Subject_State_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_STA_Subject_State_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_STA_Subject_State_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_STA,
        SU_STA_ID,
        SU_STA_PositedAt,
        SU_STA_Positor,
        SU_STA_Reliability,
        SU_STA_Assertion
    FROM
        [dbo].[SU_STA_Subject_State_Annex]
    WHERE
        SU_STA_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_STA_Subject_State rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_STA_Subject_State','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_STA_Subject_State] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_STA,
        p.SU_STA_ID,
        a.SU_STA_PositedAt,
        a.SU_STA_Positor,
        a.SU_STA_Reliability,
        a.SU_STA_Assertion,
        p.SU_STA_SU_ID,
        p.SU_STA_Subject_State,
        p.SU_STA_ChangedAt
    FROM
        [dbo].[rSU_STA_Subject_State_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_STA_Subject_State_Annex](@positingTimepoint) a
    ON
        a.SU_STA_ID = p.SU_STA_ID
    AND
        a.SU_STA_Positor = @positor
    AND
        a.SU_STA_PositedAt = (
            SELECT TOP 1
                sub.SU_STA_PositedAt
            FROM
                [dbo].[rSU_STA_Subject_State_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_STA_ID = p.SU_STA_ID
            AND
                sub.SU_STA_Positor = @positor
            ORDER BY
                sub.SU_STA_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_STA_Subject_State forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_STA_Subject_State','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_STA_Subject_State] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_STA,
        p.SU_STA_ID,
        a.SU_STA_PositedAt,
        a.SU_STA_Positor,
        a.SU_STA_Reliability,
        a.SU_STA_Assertion,
        p.SU_STA_SU_ID,
        p.SU_STA_Subject_State,
        p.SU_STA_ChangedAt
    FROM
        [dbo].[fSU_STA_Subject_State_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_STA_Subject_State_Annex](@positingTimepoint) a
    ON
        a.SU_STA_ID = p.SU_STA_ID
    AND
        a.SU_STA_Positor = @positor
    AND
        a.SU_STA_PositedAt = (
            SELECT TOP 1
                sub.SU_STA_PositedAt
            FROM
                [dbo].[rSU_STA_Subject_State_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_STA_ID = p.SU_STA_ID
            AND
                sub.SU_STA_Positor = @positor
            ORDER BY
                sub.SU_STA_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_STA_Subject_State function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_STA_Subject_State','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_STA_Subject_State] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_STA_Subject_State
        FROM
            [dbo].[rSU_STA_Subject_State](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_STA_SU_ID = @id
        AND
            pre.SU_STA_ChangedAt < @changingTimepoint
        AND
            pre.SU_STA_Assertion = isnull(@assertion, pre.SU_STA_Assertion)
        ORDER BY
            pre.SU_STA_ChangedAt DESC,
            pre.SU_STA_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_STA_Subject_State function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_STA_Subject_State','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_STA_Subject_State] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_STA_Subject_State
        FROM
            [dbo].[fSU_STA_Subject_State](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_STA_SU_ID = @id
        AND
            fol.SU_STA_ChangedAt > @changingTimepoint
        AND
            fol.SU_STA_Assertion = isnull(@assertion, fol.SU_STA_Assertion)
        ORDER BY
            fol.SU_STA_ChangedAt ASC,
            fol.SU_STA_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LBL_Subject_Label_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LBL_Subject_Label_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_LBL_ID,
        SU_LBL_SU_ID,
        SU_LBL_Subject_Label,
        SU_LBL_ChangedAt
    FROM
        [dbo].[SU_LBL_Subject_Label_Posit]
    WHERE
        SU_LBL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_LBL_Subject_Label_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_LBL_Subject_Label_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_LBL_Subject_Label_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_LBL_ID,
        SU_LBL_SU_ID,
        SU_LBL_Subject_Label,
        SU_LBL_ChangedAt
    FROM
        [dbo].[SU_LBL_Subject_Label_Posit]
    WHERE
        SU_LBL_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LBL_Subject_Label_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LBL_Subject_Label_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_LBL,
        SU_LBL_ID,
        SU_LBL_PositedAt,
        SU_LBL_Positor,
        SU_LBL_Reliability,
        SU_LBL_Assertion
    FROM
        [dbo].[SU_LBL_Subject_Label_Annex]
    WHERE
        SU_LBL_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LBL_Subject_Label','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LBL_Subject_Label] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_LBL,
        p.SU_LBL_ID,
        a.SU_LBL_PositedAt,
        a.SU_LBL_Positor,
        a.SU_LBL_Reliability,
        a.SU_LBL_Assertion,
        p.SU_LBL_SU_ID,
        p.SU_LBL_Subject_Label,
        p.SU_LBL_ChangedAt
    FROM
        [dbo].[rSU_LBL_Subject_Label_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_LBL_Subject_Label_Annex](@positingTimepoint) a
    ON
        a.SU_LBL_ID = p.SU_LBL_ID
    AND
        a.SU_LBL_Positor = @positor
    AND
        a.SU_LBL_PositedAt = (
            SELECT TOP 1
                sub.SU_LBL_PositedAt
            FROM
                [dbo].[rSU_LBL_Subject_Label_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_LBL_ID = p.SU_LBL_ID
            AND
                sub.SU_LBL_Positor = @positor
            ORDER BY
                sub.SU_LBL_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_LBL_Subject_Label forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_LBL_Subject_Label','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_LBL_Subject_Label] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_LBL,
        p.SU_LBL_ID,
        a.SU_LBL_PositedAt,
        a.SU_LBL_Positor,
        a.SU_LBL_Reliability,
        a.SU_LBL_Assertion,
        p.SU_LBL_SU_ID,
        p.SU_LBL_Subject_Label,
        p.SU_LBL_ChangedAt
    FROM
        [dbo].[fSU_LBL_Subject_Label_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_LBL_Subject_Label_Annex](@positingTimepoint) a
    ON
        a.SU_LBL_ID = p.SU_LBL_ID
    AND
        a.SU_LBL_Positor = @positor
    AND
        a.SU_LBL_PositedAt = (
            SELECT TOP 1
                sub.SU_LBL_PositedAt
            FROM
                [dbo].[rSU_LBL_Subject_Label_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_LBL_ID = p.SU_LBL_ID
            AND
                sub.SU_LBL_Positor = @positor
            ORDER BY
                sub.SU_LBL_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_LBL_Subject_Label function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_LBL_Subject_Label','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_LBL_Subject_Label] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_LBL_Subject_Label
        FROM
            [dbo].[rSU_LBL_Subject_Label](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_LBL_SU_ID = @id
        AND
            pre.SU_LBL_ChangedAt < @changingTimepoint
        AND
            pre.SU_LBL_Assertion = isnull(@assertion, pre.SU_LBL_Assertion)
        ORDER BY
            pre.SU_LBL_ChangedAt DESC,
            pre.SU_LBL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_LBL_Subject_Label function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_LBL_Subject_Label','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_LBL_Subject_Label] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_LBL_Subject_Label
        FROM
            [dbo].[fSU_LBL_Subject_Label](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_LBL_SU_ID = @id
        AND
            fol.SU_LBL_ChangedAt > @changingTimepoint
        AND
            fol.SU_LBL_Assertion = isnull(@assertion, fol.SU_LBL_Assertion)
        ORDER BY
            fol.SU_LBL_ChangedAt ASC,
            fol.SU_LBL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TAG_Subject_Tag_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TAG_Subject_Tag_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TAG_ID,
        SU_TAG_SU_ID,
        SU_TAG_Subject_Tag,
        SU_TAG_ChangedAt
    FROM
        [dbo].[SU_TAG_Subject_Tag_Posit]
    WHERE
        SU_TAG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_TAG_Subject_Tag_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TAG_Subject_Tag_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TAG_Subject_Tag_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TAG_ID,
        SU_TAG_SU_ID,
        SU_TAG_Subject_Tag,
        SU_TAG_ChangedAt
    FROM
        [dbo].[SU_TAG_Subject_Tag_Posit]
    WHERE
        SU_TAG_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TAG_Subject_Tag_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TAG_Subject_Tag_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_TAG,
        SU_TAG_ID,
        SU_TAG_PositedAt,
        SU_TAG_Positor,
        SU_TAG_Reliability,
        SU_TAG_Assertion
    FROM
        [dbo].[SU_TAG_Subject_Tag_Annex]
    WHERE
        SU_TAG_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TAG_Subject_Tag','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TAG_Subject_Tag] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TAG,
        p.SU_TAG_ID,
        a.SU_TAG_PositedAt,
        a.SU_TAG_Positor,
        a.SU_TAG_Reliability,
        a.SU_TAG_Assertion,
        p.SU_TAG_SU_ID,
        p.SU_TAG_Subject_Tag,
        p.SU_TAG_ChangedAt
    FROM
        [dbo].[rSU_TAG_Subject_Tag_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TAG_Subject_Tag_Annex](@positingTimepoint) a
    ON
        a.SU_TAG_ID = p.SU_TAG_ID
    AND
        a.SU_TAG_Positor = @positor
    AND
        a.SU_TAG_PositedAt = (
            SELECT TOP 1
                sub.SU_TAG_PositedAt
            FROM
                [dbo].[rSU_TAG_Subject_Tag_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TAG_ID = p.SU_TAG_ID
            AND
                sub.SU_TAG_Positor = @positor
            ORDER BY
                sub.SU_TAG_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_TAG_Subject_Tag forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TAG_Subject_Tag','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TAG_Subject_Tag] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TAG,
        p.SU_TAG_ID,
        a.SU_TAG_PositedAt,
        a.SU_TAG_Positor,
        a.SU_TAG_Reliability,
        a.SU_TAG_Assertion,
        p.SU_TAG_SU_ID,
        p.SU_TAG_Subject_Tag,
        p.SU_TAG_ChangedAt
    FROM
        [dbo].[fSU_TAG_Subject_Tag_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TAG_Subject_Tag_Annex](@positingTimepoint) a
    ON
        a.SU_TAG_ID = p.SU_TAG_ID
    AND
        a.SU_TAG_Positor = @positor
    AND
        a.SU_TAG_PositedAt = (
            SELECT TOP 1
                sub.SU_TAG_PositedAt
            FROM
                [dbo].[rSU_TAG_Subject_Tag_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TAG_ID = p.SU_TAG_ID
            AND
                sub.SU_TAG_Positor = @positor
            ORDER BY
                sub.SU_TAG_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_TAG_Subject_Tag function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_TAG_Subject_Tag','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_TAG_Subject_Tag] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_TAG_Subject_Tag
        FROM
            [dbo].[rSU_TAG_Subject_Tag](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_TAG_SU_ID = @id
        AND
            pre.SU_TAG_ChangedAt < @changingTimepoint
        AND
            pre.SU_TAG_Assertion = isnull(@assertion, pre.SU_TAG_Assertion)
        ORDER BY
            pre.SU_TAG_ChangedAt DESC,
            pre.SU_TAG_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_TAG_Subject_Tag function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_TAG_Subject_Tag','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_TAG_Subject_Tag] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_TAG_Subject_Tag
        FROM
            [dbo].[fSU_TAG_Subject_Tag](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_TAG_SU_ID = @id
        AND
            fol.SU_TAG_ChangedAt > @changingTimepoint
        AND
            fol.SU_TAG_Assertion = isnull(@assertion, fol.SU_TAG_Assertion)
        ORDER BY
            fol.SU_TAG_ChangedAt ASC,
            fol.SU_TAG_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LVL_Subject_Level_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LVL_Subject_Level_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_LVL_ID,
        SU_LVL_SU_ID,
        SU_LVL_GRD_ID,
        SU_LVL_ChangedAt
    FROM
        [dbo].[SU_LVL_Subject_Level_Posit]
    WHERE
        SU_LVL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_LVL_Subject_Level_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_LVL_Subject_Level_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_LVL_Subject_Level_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_LVL_ID,
        SU_LVL_SU_ID,
        SU_LVL_GRD_ID,
        SU_LVL_ChangedAt
    FROM
        [dbo].[SU_LVL_Subject_Level_Posit]
    WHERE
        SU_LVL_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LVL_Subject_Level_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LVL_Subject_Level_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_LVL,
        SU_LVL_ID,
        SU_LVL_PositedAt,
        SU_LVL_Positor,
        SU_LVL_Reliability,
        SU_LVL_Assertion
    FROM
        [dbo].[SU_LVL_Subject_Level_Annex]
    WHERE
        SU_LVL_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LVL_Subject_Level','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LVL_Subject_Level] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_LVL,
        p.SU_LVL_ID,
        a.SU_LVL_PositedAt,
        a.SU_LVL_Positor,
        a.SU_LVL_Reliability,
        a.SU_LVL_Assertion,
        p.SU_LVL_SU_ID,
        p.SU_LVL_GRD_ID,
        p.SU_LVL_ChangedAt
    FROM
        [dbo].[rSU_LVL_Subject_Level_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_LVL_Subject_Level_Annex](@positingTimepoint) a
    ON
        a.SU_LVL_ID = p.SU_LVL_ID
    AND
        a.SU_LVL_Positor = @positor
    AND
        a.SU_LVL_PositedAt = (
            SELECT TOP 1
                sub.SU_LVL_PositedAt
            FROM
                [dbo].[rSU_LVL_Subject_Level_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_LVL_ID = p.SU_LVL_ID
            AND
                sub.SU_LVL_Positor = @positor
            ORDER BY
                sub.SU_LVL_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_LVL_Subject_Level forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_LVL_Subject_Level','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_LVL_Subject_Level] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_LVL,
        p.SU_LVL_ID,
        a.SU_LVL_PositedAt,
        a.SU_LVL_Positor,
        a.SU_LVL_Reliability,
        a.SU_LVL_Assertion,
        p.SU_LVL_SU_ID,
        p.SU_LVL_GRD_ID,
        p.SU_LVL_ChangedAt
    FROM
        [dbo].[fSU_LVL_Subject_Level_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_LVL_Subject_Level_Annex](@positingTimepoint) a
    ON
        a.SU_LVL_ID = p.SU_LVL_ID
    AND
        a.SU_LVL_Positor = @positor
    AND
        a.SU_LVL_PositedAt = (
            SELECT TOP 1
                sub.SU_LVL_PositedAt
            FROM
                [dbo].[rSU_LVL_Subject_Level_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_LVL_ID = p.SU_LVL_ID
            AND
                sub.SU_LVL_Positor = @positor
            ORDER BY
                sub.SU_LVL_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_LVL_Subject_Level function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_LVL_Subject_Level','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_LVL_Subject_Level] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_LVL_GRD_ID
        FROM
            [dbo].[rSU_LVL_Subject_Level](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_LVL_SU_ID = @id
        AND
            pre.SU_LVL_ChangedAt < @changingTimepoint
        AND
            pre.SU_LVL_Assertion = isnull(@assertion, pre.SU_LVL_Assertion)
        ORDER BY
            pre.SU_LVL_ChangedAt DESC,
            pre.SU_LVL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_LVL_Subject_Level function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_LVL_Subject_Level','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_LVL_Subject_Level] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_LVL_GRD_ID
        FROM
            [dbo].[fSU_LVL_Subject_Level](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_LVL_SU_ID = @id
        AND
            fol.SU_LVL_ChangedAt > @changingTimepoint
        AND
            fol.SU_LVL_Assertion = isnull(@assertion, fol.SU_LVL_Assertion)
        ORDER BY
            fol.SU_LVL_ChangedAt ASC,
            fol.SU_LVL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TXT_Subject_Text_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TXT_Subject_Text_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TXT_ID,
        SU_TXT_SU_ID,
        SU_TXT_Checksum,
        SU_TXT_Subject_Text,
        SU_TXT_ChangedAt
    FROM
        [dbo].[SU_TXT_Subject_Text_Posit]
    WHERE
        SU_TXT_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_TXT_Subject_Text_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TXT_Subject_Text_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TXT_Subject_Text_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TXT_ID,
        SU_TXT_SU_ID,
        SU_TXT_Checksum,
        SU_TXT_Subject_Text,
        SU_TXT_ChangedAt
    FROM
        [dbo].[SU_TXT_Subject_Text_Posit]
    WHERE
        SU_TXT_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TXT_Subject_Text_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TXT_Subject_Text_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_TXT,
        SU_TXT_ID,
        SU_TXT_PositedAt,
        SU_TXT_Positor,
        SU_TXT_Reliability,
        SU_TXT_Assertion
    FROM
        [dbo].[SU_TXT_Subject_Text_Annex]
    WHERE
        SU_TXT_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TXT_Subject_Text','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TXT_Subject_Text] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TXT,
        p.SU_TXT_ID,
        a.SU_TXT_PositedAt,
        a.SU_TXT_Positor,
        a.SU_TXT_Reliability,
        a.SU_TXT_Assertion,
        p.SU_TXT_SU_ID,
        p.SU_TXT_Checksum,
        p.SU_TXT_Subject_Text,
        p.SU_TXT_ChangedAt
    FROM
        [dbo].[rSU_TXT_Subject_Text_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TXT_Subject_Text_Annex](@positingTimepoint) a
    ON
        a.SU_TXT_ID = p.SU_TXT_ID
    AND
        a.SU_TXT_Positor = @positor
    AND
        a.SU_TXT_PositedAt = (
            SELECT TOP 1
                sub.SU_TXT_PositedAt
            FROM
                [dbo].[rSU_TXT_Subject_Text_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TXT_ID = p.SU_TXT_ID
            AND
                sub.SU_TXT_Positor = @positor
            ORDER BY
                sub.SU_TXT_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_TXT_Subject_Text forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TXT_Subject_Text','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TXT_Subject_Text] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TXT,
        p.SU_TXT_ID,
        a.SU_TXT_PositedAt,
        a.SU_TXT_Positor,
        a.SU_TXT_Reliability,
        a.SU_TXT_Assertion,
        p.SU_TXT_SU_ID,
        p.SU_TXT_Checksum,
        p.SU_TXT_Subject_Text,
        p.SU_TXT_ChangedAt
    FROM
        [dbo].[fSU_TXT_Subject_Text_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TXT_Subject_Text_Annex](@positingTimepoint) a
    ON
        a.SU_TXT_ID = p.SU_TXT_ID
    AND
        a.SU_TXT_Positor = @positor
    AND
        a.SU_TXT_PositedAt = (
            SELECT TOP 1
                sub.SU_TXT_PositedAt
            FROM
                [dbo].[rSU_TXT_Subject_Text_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TXT_ID = p.SU_TXT_ID
            AND
                sub.SU_TXT_Positor = @positor
            ORDER BY
                sub.SU_TXT_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_TXT_Subject_Text function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_TXT_Subject_Text','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_TXT_Subject_Text] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS varbinary(16)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_TXT_Checksum
        FROM
            [dbo].[rSU_TXT_Subject_Text](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_TXT_SU_ID = @id
        AND
            pre.SU_TXT_ChangedAt < @changingTimepoint
        AND
            pre.SU_TXT_Assertion = isnull(@assertion, pre.SU_TXT_Assertion)
        ORDER BY
            pre.SU_TXT_ChangedAt DESC,
            pre.SU_TXT_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_TXT_Subject_Text function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_TXT_Subject_Text','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_TXT_Subject_Text] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS varbinary(16)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_TXT_Checksum
        FROM
            [dbo].[fSU_TXT_Subject_Text](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_TXT_SU_ID = @id
        AND
            fol.SU_TXT_ChangedAt > @changingTimepoint
        AND
            fol.SU_TXT_Assertion = isnull(@assertion, fol.SU_TXT_Assertion)
        ORDER BY
            fol.SU_TXT_ChangedAt ASC,
            fol.SU_TXT_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ASR_Subject_Assessment_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ASR_Subject_Assessment_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_ASR_ID,
        SU_ASR_SU_ID,
        SU_ASR_Subject_Assessment,
        SU_ASR_ChangedAt
    FROM
        [dbo].[SU_ASR_Subject_Assessment_Posit]
    WHERE
        SU_ASR_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_ASR_Subject_Assessment_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_ASR_Subject_Assessment_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_ASR_Subject_Assessment_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_ASR_ID,
        SU_ASR_SU_ID,
        SU_ASR_Subject_Assessment,
        SU_ASR_ChangedAt
    FROM
        [dbo].[SU_ASR_Subject_Assessment_Posit]
    WHERE
        SU_ASR_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ASR_Subject_Assessment_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ASR_Subject_Assessment_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_ASR,
        SU_ASR_ID,
        SU_ASR_PositedAt,
        SU_ASR_Positor,
        SU_ASR_Reliability,
        SU_ASR_Assertion
    FROM
        [dbo].[SU_ASR_Subject_Assessment_Annex]
    WHERE
        SU_ASR_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ASR_Subject_Assessment','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ASR_Subject_Assessment] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_ASR,
        p.SU_ASR_ID,
        a.SU_ASR_PositedAt,
        a.SU_ASR_Positor,
        a.SU_ASR_Reliability,
        a.SU_ASR_Assertion,
        p.SU_ASR_SU_ID,
        p.SU_ASR_Subject_Assessment,
        p.SU_ASR_ChangedAt
    FROM
        [dbo].[rSU_ASR_Subject_Assessment_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_ASR_Subject_Assessment_Annex](@positingTimepoint) a
    ON
        a.SU_ASR_ID = p.SU_ASR_ID
    AND
        a.SU_ASR_Positor = @positor
    AND
        a.SU_ASR_PositedAt = (
            SELECT TOP 1
                sub.SU_ASR_PositedAt
            FROM
                [dbo].[rSU_ASR_Subject_Assessment_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_ASR_ID = p.SU_ASR_ID
            AND
                sub.SU_ASR_Positor = @positor
            ORDER BY
                sub.SU_ASR_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_ASR_Subject_Assessment forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_ASR_Subject_Assessment','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_ASR_Subject_Assessment] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_ASR,
        p.SU_ASR_ID,
        a.SU_ASR_PositedAt,
        a.SU_ASR_Positor,
        a.SU_ASR_Reliability,
        a.SU_ASR_Assertion,
        p.SU_ASR_SU_ID,
        p.SU_ASR_Subject_Assessment,
        p.SU_ASR_ChangedAt
    FROM
        [dbo].[fSU_ASR_Subject_Assessment_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_ASR_Subject_Assessment_Annex](@positingTimepoint) a
    ON
        a.SU_ASR_ID = p.SU_ASR_ID
    AND
        a.SU_ASR_Positor = @positor
    AND
        a.SU_ASR_PositedAt = (
            SELECT TOP 1
                sub.SU_ASR_PositedAt
            FROM
                [dbo].[rSU_ASR_Subject_Assessment_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_ASR_ID = p.SU_ASR_ID
            AND
                sub.SU_ASR_Positor = @positor
            ORDER BY
                sub.SU_ASR_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_ASR_Subject_Assessment function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_ASR_Subject_Assessment','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_ASR_Subject_Assessment] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_ASR_Subject_Assessment
        FROM
            [dbo].[rSU_ASR_Subject_Assessment](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_ASR_SU_ID = @id
        AND
            pre.SU_ASR_ChangedAt < @changingTimepoint
        AND
            pre.SU_ASR_Assertion = isnull(@assertion, pre.SU_ASR_Assertion)
        ORDER BY
            pre.SU_ASR_ChangedAt DESC,
            pre.SU_ASR_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_ASR_Subject_Assessment function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_ASR_Subject_Assessment','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_ASR_Subject_Assessment] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_ASR_Subject_Assessment
        FROM
            [dbo].[fSU_ASR_Subject_Assessment](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_ASR_SU_ID = @id
        AND
            fol.SU_ASR_ChangedAt > @changingTimepoint
        AND
            fol.SU_ASR_Assertion = isnull(@assertion, fol.SU_ASR_Assertion)
        ORDER BY
            fol.SU_ASR_ChangedAt ASC,
            fol.SU_ASR_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ERS_Subject_Erasable_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ERS_Subject_Erasable_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_ERS_ID,
        SU_ERS_SU_ID,
        SU_ERS_Subject_Erasable,
        SU_ERS_ChangedAt
    FROM
        [dbo].[SU_ERS_Subject_Erasable_Posit]
    WHERE
        SU_ERS_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_ERS_Subject_Erasable_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_ERS_Subject_Erasable_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_ERS_Subject_Erasable_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_ERS_ID,
        SU_ERS_SU_ID,
        SU_ERS_Subject_Erasable,
        SU_ERS_ChangedAt
    FROM
        [dbo].[SU_ERS_Subject_Erasable_Posit]
    WHERE
        SU_ERS_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ERS_Subject_Erasable_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ERS_Subject_Erasable_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_ERS,
        SU_ERS_ID,
        SU_ERS_PositedAt,
        SU_ERS_Positor,
        SU_ERS_Reliability,
        SU_ERS_Assertion
    FROM
        [dbo].[SU_ERS_Subject_Erasable_Annex]
    WHERE
        SU_ERS_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ERS_Subject_Erasable','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ERS_Subject_Erasable] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_ERS,
        p.SU_ERS_ID,
        a.SU_ERS_PositedAt,
        a.SU_ERS_Positor,
        a.SU_ERS_Reliability,
        a.SU_ERS_Assertion,
        p.SU_ERS_SU_ID,
        p.SU_ERS_Subject_Erasable,
        p.SU_ERS_ChangedAt
    FROM
        [dbo].[rSU_ERS_Subject_Erasable_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_ERS_Subject_Erasable_Annex](@positingTimepoint) a
    ON
        a.SU_ERS_ID = p.SU_ERS_ID
    AND
        a.SU_ERS_Positor = @positor
    AND
        a.SU_ERS_PositedAt = (
            SELECT TOP 1
                sub.SU_ERS_PositedAt
            FROM
                [dbo].[rSU_ERS_Subject_Erasable_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_ERS_ID = p.SU_ERS_ID
            AND
                sub.SU_ERS_Positor = @positor
            ORDER BY
                sub.SU_ERS_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_ERS_Subject_Erasable forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_ERS_Subject_Erasable','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_ERS_Subject_Erasable] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_ERS,
        p.SU_ERS_ID,
        a.SU_ERS_PositedAt,
        a.SU_ERS_Positor,
        a.SU_ERS_Reliability,
        a.SU_ERS_Assertion,
        p.SU_ERS_SU_ID,
        p.SU_ERS_Subject_Erasable,
        p.SU_ERS_ChangedAt
    FROM
        [dbo].[fSU_ERS_Subject_Erasable_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_ERS_Subject_Erasable_Annex](@positingTimepoint) a
    ON
        a.SU_ERS_ID = p.SU_ERS_ID
    AND
        a.SU_ERS_Positor = @positor
    AND
        a.SU_ERS_PositedAt = (
            SELECT TOP 1
                sub.SU_ERS_PositedAt
            FROM
                [dbo].[rSU_ERS_Subject_Erasable_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_ERS_ID = p.SU_ERS_ID
            AND
                sub.SU_ERS_Positor = @positor
            ORDER BY
                sub.SU_ERS_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_ERS_Subject_Erasable function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_ERS_Subject_Erasable','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_ERS_Subject_Erasable] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_ERS_Subject_Erasable
        FROM
            [dbo].[rSU_ERS_Subject_Erasable](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_ERS_SU_ID = @id
        AND
            pre.SU_ERS_ChangedAt < @changingTimepoint
        AND
            pre.SU_ERS_Assertion = isnull(@assertion, pre.SU_ERS_Assertion)
        ORDER BY
            pre.SU_ERS_ChangedAt DESC,
            pre.SU_ERS_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_ERS_Subject_Erasable function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_ERS_Subject_Erasable','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_ERS_Subject_Erasable] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_ERS_Subject_Erasable
        FROM
            [dbo].[fSU_ERS_Subject_Erasable](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_ERS_SU_ID = @id
        AND
            fol.SU_ERS_ChangedAt > @changingTimepoint
        AND
            fol.SU_ERS_Assertion = isnull(@assertion, fol.SU_ERS_Assertion)
        ORDER BY
            fol.SU_ERS_ChangedAt ASC,
            fol.SU_ERS_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rOB_NAM_Object_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rOB_NAM_Object_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rOB_NAM_Object_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_OB_NAM,
        OB_NAM_ID,
        OB_NAM_PositedAt,
        OB_NAM_Positor,
        OB_NAM_Reliability,
        OB_NAM_Assertion
    FROM
        [dbo].[OB_NAM_Object_Name_Annex]
    WHERE
        OB_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rOB_NAM_Object_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rOB_NAM_Object_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rOB_NAM_Object_Name] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_OB_NAM,
        p.OB_NAM_ID,
        a.OB_NAM_PositedAt,
        a.OB_NAM_Positor,
        a.OB_NAM_Reliability,
        a.OB_NAM_Assertion,
        p.OB_NAM_OB_ID,
        p.OB_NAM_Object_Name
    FROM
        [dbo].[OB_NAM_Object_Name_Posit] p
    JOIN
        [dbo].[rOB_NAM_Object_Name_Annex](@positingTimepoint) a
    ON
        a.OB_NAM_ID = p.OB_NAM_ID
    AND
        a.OB_NAM_Positor = @positor
    AND
        a.OB_NAM_PositedAt = (
            SELECT TOP 1
                sub.OB_NAM_PositedAt
            FROM
                [dbo].[rOB_NAM_Object_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.OB_NAM_ID = p.OB_NAM_ID
            AND
                sub.OB_NAM_Positor = @positor
            ORDER BY
                sub.OB_NAM_PositedAt DESC
        )
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
-- returns 1 for at least one equal surrounding value, 0 for different surrounding values
--
-- @posit the id of the posit that should be checked
-- @posited the time when this posit was made
-- @positor the one who made the posit
-- @assertion whether this posit is positively or negatively asserted, or unreliable
--
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfEV_PLC_Event_Place restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcEV_PLC_Event_Place restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfEV_PLC_Event_Place', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfEV_PLC_Event_Place] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = EV_PLC_EV_ID,
        @value = EV_PLC_Event_Place,
        @changed = EV_PLC_ChangedAt
    FROM
        [dbo].[EV_PLC_Event_Place_Posit]
    WHERE
        EV_PLC_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preEV_PLC_Event_Place] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folEV_PLC_Event_Place] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [dbo].[EV_PLC_Event_Place_Annex]
    ADD CONSTRAINT [rcEV_PLC_Event_Place_Annex] CHECK (
        [dbo].[rfEV_PLC_Event_Place] (
            EV_PLC_ID,
            EV_PLC_PositedAt,
            EV_PLC_Positor,
            EV_PLC_Assertion
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_TTL_Subject_Title restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_TTL_Subject_Title restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_TTL_Subject_Title', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_TTL_Subject_Title] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_TTL_SU_ID,
        @value = SU_TTL_Subject_Title,
        @changed = SU_TTL_ChangedAt
    FROM
        [dbo].[SU_TTL_Subject_Title_Posit]
    WHERE
        SU_TTL_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_TTL_Subject_Title] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_TTL_Subject_Title] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_STA_Subject_State restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_STA_Subject_State restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_STA_Subject_State', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_STA_Subject_State] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_STA_SU_ID,
        @value = SU_STA_Subject_State,
        @changed = SU_STA_ChangedAt
    FROM
        [dbo].[SU_STA_Subject_State_Posit]
    WHERE
        SU_STA_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_STA_Subject_State] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_STA_Subject_State] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [dbo].[SU_STA_Subject_State_Annex]
    ADD CONSTRAINT [rcSU_STA_Subject_State_Annex] CHECK (
        [dbo].[rfSU_STA_Subject_State] (
            SU_STA_ID,
            SU_STA_PositedAt,
            SU_STA_Positor,
            SU_STA_Assertion
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_LBL_Subject_Label restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_LBL_Subject_Label restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_LBL_Subject_Label', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_LBL_Subject_Label] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_LBL_SU_ID,
        @value = SU_LBL_Subject_Label,
        @changed = SU_LBL_ChangedAt
    FROM
        [dbo].[SU_LBL_Subject_Label_Posit]
    WHERE
        SU_LBL_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_LBL_Subject_Label] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_LBL_Subject_Label] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [dbo].[SU_LBL_Subject_Label_Annex]
    ADD CONSTRAINT [rcSU_LBL_Subject_Label_Annex] CHECK (
        [dbo].[rfSU_LBL_Subject_Label] (
            SU_LBL_ID,
            SU_LBL_PositedAt,
            SU_LBL_Positor,
            SU_LBL_Assertion
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_TAG_Subject_Tag restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_TAG_Subject_Tag restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_TAG_Subject_Tag', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_TAG_Subject_Tag] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_TAG_SU_ID,
        @value = SU_TAG_Subject_Tag,
        @changed = SU_TAG_ChangedAt
    FROM
        [dbo].[SU_TAG_Subject_Tag_Posit]
    WHERE
        SU_TAG_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_TAG_Subject_Tag] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_TAG_Subject_Tag] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_LVL_Subject_Level restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_LVL_Subject_Level restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_LVL_Subject_Level', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_LVL_Subject_Level] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value tinyint;
    DECLARE @changed datetime2;
    SELECT
        @id = SU_LVL_SU_ID,
        @value = SU_LVL_GRD_ID,
        @changed = SU_LVL_ChangedAt
    FROM
        [dbo].[SU_LVL_Subject_Level_Posit]
    WHERE
        SU_LVL_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_LVL_Subject_Level] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_LVL_Subject_Level] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_TXT_Subject_Text restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_TXT_Subject_Text restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_TXT_Subject_Text', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_TXT_Subject_Text] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value varbinary(16);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_TXT_SU_ID,
        @value = SU_TXT_Checksum,
        @changed = SU_TXT_ChangedAt
    FROM
        [dbo].[SU_TXT_Subject_Text_Posit]
    WHERE
        SU_TXT_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_TXT_Subject_Text] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_TXT_Subject_Text] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_ASR_Subject_Assessment restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_ASR_Subject_Assessment restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_ASR_Subject_Assessment', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_ASR_Subject_Assessment] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_ASR_SU_ID,
        @value = SU_ASR_Subject_Assessment,
        @changed = SU_ASR_ChangedAt
    FROM
        [dbo].[SU_ASR_Subject_Assessment_Posit]
    WHERE
        SU_ASR_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_ASR_Subject_Assessment] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_ASR_Subject_Assessment] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_ERS_Subject_Erasable restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_ERS_Subject_Erasable restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_ERS_Subject_Erasable', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_ERS_Subject_Erasable] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_ERS_SU_ID,
        @value = SU_ERS_Subject_Erasable,
        @changed = SU_ERS_ChangedAt
    FROM
        [dbo].[SU_ERS_Subject_Erasable_Posit]
    WHERE
        SU_ERS_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_ERS_Subject_Erasable] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_ERS_Subject_Erasable] (
                    @id,
                    @positor,
                    @changed,
                    @posited,
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
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
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
-- @assertion whether to show positve, negative, uncertain, or all posits (defaults to all)
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
IF Object_ID('dbo.dSU_Subject', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dSU_Subject];
IF Object_ID('dbo.nSU_Subject', 'V') IS NOT NULL
DROP VIEW [dbo].[nSU_Subject];
IF Object_ID('dbo.pSU_Subject', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pSU_Subject];
IF Object_ID('dbo.lSU_Subject', 'V') IS NOT NULL
DROP VIEW [dbo].[lSU_Subject];
IF Object_ID('dbo.tSU_Subject', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tSU_Subject];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tSU_Subject viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tSU_Subject] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [SU].SU_ID,
    [SU].Metadata_SU,
    [NAM].SU_NAM_SU_ID,
    [NAM].Metadata_SU_NAM,
    [NAM].SU_NAM_ID,
    [NAM].SU_NAM_PositedAt,
    [NAM].SU_NAM_Positor,
    [NAM].SU_NAM_Reliability,
    [NAM].SU_NAM_Assertion,
    [NAM].SU_NAM_Subject_Name,
    [COD].SU_COD_SU_ID,
    [COD].Metadata_SU_COD,
    [COD].SU_COD_ID,
    [COD].SU_COD_PositedAt,
    [COD].SU_COD_Positor,
    [COD].SU_COD_Reliability,
    [COD].SU_COD_Assertion,
    [COD].SU_COD_Subject_Code,
    [GRD].SU_GRD_SU_ID,
    [GRD].Metadata_SU_GRD,
    [GRD].SU_GRD_ID,
    [GRD].SU_GRD_PositedAt,
    [GRD].SU_GRD_Positor,
    [GRD].SU_GRD_Reliability,
    [GRD].SU_GRD_Assertion,
    [kGRD].GRD_Grade AS SU_GRD_GRD_Grade,
    [kGRD].Metadata_GRD AS SU_GRD_Metadata_GRD,
    [GRD].SU_GRD_GRD_ID,
    [NOT].SU_NOT_SU_ID,
    [NOT].Metadata_SU_NOT,
    [NOT].SU_NOT_ID,
    [NOT].SU_NOT_PositedAt,
    [NOT].SU_NOT_Positor,
    [NOT].SU_NOT_Reliability,
    [NOT].SU_NOT_Assertion,
    [NOT].SU_NOT_Checksum,
    [NOT].SU_NOT_Subject_Note,
    [TTL].SU_TTL_SU_ID,
    [TTL].Metadata_SU_TTL,
    [TTL].SU_TTL_ID,
    [TTL].SU_TTL_ChangedAt,
    [TTL].SU_TTL_PositedAt,
    [TTL].SU_TTL_Positor,
    [TTL].SU_TTL_Reliability,
    [TTL].SU_TTL_Assertion,
    [TTL].SU_TTL_Subject_Title,
    [STA].SU_STA_SU_ID,
    [STA].Metadata_SU_STA,
    [STA].SU_STA_ID,
    [STA].SU_STA_ChangedAt,
    [STA].SU_STA_PositedAt,
    [STA].SU_STA_Positor,
    [STA].SU_STA_Reliability,
    [STA].SU_STA_Assertion,
    [STA].SU_STA_Subject_State,
    [LBL].SU_LBL_SU_ID,
    [LBL].Metadata_SU_LBL,
    [LBL].SU_LBL_ID,
    [LBL].SU_LBL_ChangedAt,
    [LBL].SU_LBL_PositedAt,
    [LBL].SU_LBL_Positor,
    [LBL].SU_LBL_Reliability,
    [LBL].SU_LBL_Assertion,
    [LBL].SU_LBL_Subject_Label,
    [TAG].SU_TAG_SU_ID,
    [TAG].Metadata_SU_TAG,
    [TAG].SU_TAG_ID,
    [TAG].SU_TAG_ChangedAt,
    [TAG].SU_TAG_PositedAt,
    [TAG].SU_TAG_Positor,
    [TAG].SU_TAG_Reliability,
    [TAG].SU_TAG_Assertion,
    [TAG].SU_TAG_Subject_Tag,
    [LVL].SU_LVL_SU_ID,
    [LVL].Metadata_SU_LVL,
    [LVL].SU_LVL_ID,
    [LVL].SU_LVL_ChangedAt,
    [LVL].SU_LVL_PositedAt,
    [LVL].SU_LVL_Positor,
    [LVL].SU_LVL_Reliability,
    [LVL].SU_LVL_Assertion,
    [kLVL].GRD_Grade AS SU_LVL_GRD_Grade,
    [kLVL].Metadata_GRD AS SU_LVL_Metadata_GRD,
    [LVL].SU_LVL_GRD_ID,
    [TXT].SU_TXT_SU_ID,
    [TXT].Metadata_SU_TXT,
    [TXT].SU_TXT_ID,
    [TXT].SU_TXT_ChangedAt,
    [TXT].SU_TXT_PositedAt,
    [TXT].SU_TXT_Positor,
    [TXT].SU_TXT_Reliability,
    [TXT].SU_TXT_Assertion,
    [TXT].SU_TXT_Checksum,
    [TXT].SU_TXT_Subject_Text,
    [ASR].SU_ASR_SU_ID,
    [ASR].Metadata_SU_ASR,
    [ASR].SU_ASR_ID,
    [ASR].SU_ASR_ChangedAt,
    [ASR].SU_ASR_PositedAt,
    [ASR].SU_ASR_Positor,
    [ASR].SU_ASR_Reliability,
    [ASR].SU_ASR_Assertion,
    [ASR].SU_ASR_Subject_Assessment,
    [ERS].SU_ERS_SU_ID,
    [ERS].Metadata_SU_ERS,
    [ERS].SU_ERS_ID,
    [ERS].SU_ERS_ChangedAt,
    [ERS].SU_ERS_PositedAt,
    [ERS].SU_ERS_Positor,
    [ERS].SU_ERS_Reliability,
    [ERS].SU_ERS_Assertion,
    [ERS].SU_ERS_Subject_Erasable
FROM
    [dbo].[SU_Subject] [SU]
LEFT JOIN
    [dbo].[rSU_NAM_Subject_Name](
        @positor,
        @positingTimepoint
    ) [NAM]
ON
    [NAM].SU_NAM_ID = (
        SELECT TOP 1
            sub.SU_NAM_ID
        FROM
            [dbo].[rSU_NAM_Subject_Name](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_NAM_SU_ID = [SU].SU_ID
        AND
            sub.SU_NAM_Assertion = isnull(@assertion, sub.SU_NAM_Assertion)
        ORDER BY
            sub.SU_NAM_PositedAt DESC,
            sub.SU_NAM_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_COD_Subject_Code](
        @positor,
        @positingTimepoint
    ) [COD]
ON
    [COD].SU_COD_ID = (
        SELECT TOP 1
            sub.SU_COD_ID
        FROM
            [dbo].[rSU_COD_Subject_Code](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_COD_SU_ID = [SU].SU_ID
        AND
            sub.SU_COD_Assertion = isnull(@assertion, sub.SU_COD_Assertion)
        ORDER BY
            sub.SU_COD_PositedAt DESC,
            sub.SU_COD_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_GRD_Subject_Grade](
        @positor,
        @positingTimepoint
    ) [GRD]
ON
    [GRD].SU_GRD_ID = (
        SELECT TOP 1
            sub.SU_GRD_ID
        FROM
            [dbo].[rSU_GRD_Subject_Grade](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_GRD_SU_ID = [SU].SU_ID
        AND
            sub.SU_GRD_Assertion = isnull(@assertion, sub.SU_GRD_Assertion)
        ORDER BY
            sub.SU_GRD_PositedAt DESC,
            sub.SU_GRD_Reliability DESC
    )
LEFT JOIN
    [dbo].[GRD_Grade] [kGRD]
ON
    [kGRD].GRD_ID = [GRD].SU_GRD_GRD_ID
LEFT JOIN
    [dbo].[rSU_NOT_Subject_Note](
        @positor,
        @positingTimepoint
    ) [NOT]
ON
    [NOT].SU_NOT_ID = (
        SELECT TOP 1
            sub.SU_NOT_ID
        FROM
            [dbo].[rSU_NOT_Subject_Note](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_NOT_SU_ID = [SU].SU_ID
        AND
            sub.SU_NOT_Assertion = isnull(@assertion, sub.SU_NOT_Assertion)
        ORDER BY
            sub.SU_NOT_PositedAt DESC,
            sub.SU_NOT_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_TTL_Subject_Title](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [TTL]
ON
    [TTL].SU_TTL_ID = (
        SELECT TOP 1
            sub.SU_TTL_ID
        FROM
            [dbo].[rSU_TTL_Subject_Title](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_TTL_SU_ID = [SU].SU_ID
        AND
            sub.SU_TTL_Assertion = isnull(@assertion, sub.SU_TTL_Assertion)
        ORDER BY
            sub.SU_TTL_ChangedAt DESC,
            sub.SU_TTL_PositedAt DESC,
            sub.SU_TTL_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_STA_Subject_State](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [STA]
ON
    [STA].SU_STA_ID = (
        SELECT TOP 1
            sub.SU_STA_ID
        FROM
            [dbo].[rSU_STA_Subject_State](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_STA_SU_ID = [SU].SU_ID
        AND
            sub.SU_STA_Assertion = isnull(@assertion, sub.SU_STA_Assertion)
        ORDER BY
            sub.SU_STA_ChangedAt DESC,
            sub.SU_STA_PositedAt DESC,
            sub.SU_STA_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_LBL_Subject_Label](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [LBL]
ON
    [LBL].SU_LBL_ID = (
        SELECT TOP 1
            sub.SU_LBL_ID
        FROM
            [dbo].[rSU_LBL_Subject_Label](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_LBL_SU_ID = [SU].SU_ID
        AND
            sub.SU_LBL_Assertion = isnull(@assertion, sub.SU_LBL_Assertion)
        ORDER BY
            sub.SU_LBL_ChangedAt DESC,
            sub.SU_LBL_PositedAt DESC,
            sub.SU_LBL_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_TAG_Subject_Tag](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [TAG]
ON
    [TAG].SU_TAG_ID = (
        SELECT TOP 1
            sub.SU_TAG_ID
        FROM
            [dbo].[rSU_TAG_Subject_Tag](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_TAG_SU_ID = [SU].SU_ID
        AND
            sub.SU_TAG_Assertion = isnull(@assertion, sub.SU_TAG_Assertion)
        ORDER BY
            sub.SU_TAG_ChangedAt DESC,
            sub.SU_TAG_PositedAt DESC,
            sub.SU_TAG_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_LVL_Subject_Level](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [LVL]
ON
    [LVL].SU_LVL_ID = (
        SELECT TOP 1
            sub.SU_LVL_ID
        FROM
            [dbo].[rSU_LVL_Subject_Level](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_LVL_SU_ID = [SU].SU_ID
        AND
            sub.SU_LVL_Assertion = isnull(@assertion, sub.SU_LVL_Assertion)
        ORDER BY
            sub.SU_LVL_ChangedAt DESC,
            sub.SU_LVL_PositedAt DESC,
            sub.SU_LVL_Reliability DESC
    )
LEFT JOIN
    [dbo].[GRD_Grade] [kLVL]
ON
    [kLVL].GRD_ID = [LVL].SU_LVL_GRD_ID
LEFT JOIN
    [dbo].[rSU_TXT_Subject_Text](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [TXT]
ON
    [TXT].SU_TXT_ID = (
        SELECT TOP 1
            sub.SU_TXT_ID
        FROM
            [dbo].[rSU_TXT_Subject_Text](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_TXT_SU_ID = [SU].SU_ID
        AND
            sub.SU_TXT_Assertion = isnull(@assertion, sub.SU_TXT_Assertion)
        ORDER BY
            sub.SU_TXT_ChangedAt DESC,
            sub.SU_TXT_PositedAt DESC,
            sub.SU_TXT_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_ASR_Subject_Assessment](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [ASR]
ON
    [ASR].SU_ASR_ID = (
        SELECT TOP 1
            sub.SU_ASR_ID
        FROM
            [dbo].[rSU_ASR_Subject_Assessment](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_ASR_SU_ID = [SU].SU_ID
        AND
            sub.SU_ASR_Assertion = isnull(@assertion, sub.SU_ASR_Assertion)
        ORDER BY
            sub.SU_ASR_ChangedAt DESC,
            sub.SU_ASR_PositedAt DESC,
            sub.SU_ASR_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_ERS_Subject_Erasable](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [ERS]
ON
    [ERS].SU_ERS_ID = (
        SELECT TOP 1
            sub.SU_ERS_ID
        FROM
            [dbo].[rSU_ERS_Subject_Erasable](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_ERS_SU_ID = [SU].SU_ID
        AND
            sub.SU_ERS_Assertion = isnull(@assertion, sub.SU_ERS_Assertion)
        ORDER BY
            sub.SU_ERS_ChangedAt DESC,
            sub.SU_ERS_PositedAt DESC,
            sub.SU_ERS_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_Subject viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_Subject]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [SU].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_Subject] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
    ) [SU];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_Subject viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_Subject] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [SU].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_Subject] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [SU];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_Subject viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_Subject]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [SU].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_Subject] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
    ) [SU];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dSU_Subject showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dSU_Subject] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    [SU].*
FROM
    [dbo].[_Positor] p
JOIN (
    SELECT DISTINCT
        SU_TTL_Positor AS positor,
        SU_TTL_SU_ID AS SU_ID,
        SU_TTL_ChangedAt AS inspectedTimepoint,
        'TTL' AS mnemonic
    FROM
        [dbo].[SU_TTL_Subject_Title]
    WHERE
        (@selection is null OR @selection like '%TTL%')
    AND
        SU_TTL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_STA_Positor AS positor,
        SU_STA_SU_ID AS SU_ID,
        SU_STA_ChangedAt AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        [dbo].[SU_STA_Subject_State]
    WHERE
        (@selection is null OR @selection like '%STA%')
    AND
        SU_STA_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_LBL_Positor AS positor,
        SU_LBL_SU_ID AS SU_ID,
        SU_LBL_ChangedAt AS inspectedTimepoint,
        'LBL' AS mnemonic
    FROM
        [dbo].[SU_LBL_Subject_Label]
    WHERE
        (@selection is null OR @selection like '%LBL%')
    AND
        SU_LBL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_TAG_Positor AS positor,
        SU_TAG_SU_ID AS SU_ID,
        SU_TAG_ChangedAt AS inspectedTimepoint,
        'TAG' AS mnemonic
    FROM
        [dbo].[SU_TAG_Subject_Tag]
    WHERE
        (@selection is null OR @selection like '%TAG%')
    AND
        SU_TAG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_LVL_Positor AS positor,
        SU_LVL_SU_ID AS SU_ID,
        SU_LVL_ChangedAt AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        [dbo].[SU_LVL_Subject_Level]
    WHERE
        (@selection is null OR @selection like '%LVL%')
    AND
        SU_LVL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_TXT_Positor AS positor,
        SU_TXT_SU_ID AS SU_ID,
        SU_TXT_ChangedAt AS inspectedTimepoint,
        'TXT' AS mnemonic
    FROM
        [dbo].[SU_TXT_Subject_Text]
    WHERE
        (@selection is null OR @selection like '%TXT%')
    AND
        SU_TXT_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_ASR_Positor AS positor,
        SU_ASR_SU_ID AS SU_ID,
        SU_ASR_ChangedAt AS inspectedTimepoint,
        'ASR' AS mnemonic
    FROM
        [dbo].[SU_ASR_Subject_Assessment]
    WHERE
        (@selection is null OR @selection like '%ASR%')
    AND
        SU_ASR_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_ERS_Positor AS positor,
        SU_ERS_SU_ID AS SU_ID,
        SU_ERS_ChangedAt AS inspectedTimepoint,
        'ERS' AS mnemonic
    FROM
        [dbo].[SU_ERS_Subject_Erasable]
    WHERE
        (@selection is null OR @selection like '%ERS%')
    AND
        SU_ERS_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [dbo].[tSU_Subject] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [SU]
 WHERE
    [SU].SU_ID = timepoints.SU_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dOB_Object', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dOB_Object];
IF Object_ID('dbo.nOB_Object', 'V') IS NOT NULL
DROP VIEW [dbo].[nOB_Object];
IF Object_ID('dbo.pOB_Object', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pOB_Object];
IF Object_ID('dbo.lOB_Object', 'V') IS NOT NULL
DROP VIEW [dbo].[lOB_Object];
IF Object_ID('dbo.tOB_Object', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tOB_Object];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tOB_Object viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tOB_Object] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [OB].OB_ID,
    [OB].Metadata_OB,
    [NAM].OB_NAM_OB_ID,
    [NAM].Metadata_OB_NAM,
    [NAM].OB_NAM_ID,
    [NAM].OB_NAM_PositedAt,
    [NAM].OB_NAM_Positor,
    [NAM].OB_NAM_Reliability,
    [NAM].OB_NAM_Assertion,
    [NAM].OB_NAM_Object_Name
FROM
    [dbo].[OB_Object] [OB]
LEFT JOIN
    [dbo].[rOB_NAM_Object_Name](
        @positor,
        @positingTimepoint
    ) [NAM]
ON
    [NAM].OB_NAM_ID = (
        SELECT TOP 1
            sub.OB_NAM_ID
        FROM
            [dbo].[rOB_NAM_Object_Name](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.OB_NAM_OB_ID = [OB].OB_ID
        AND
            sub.OB_NAM_Assertion = isnull(@assertion, sub.OB_NAM_Assertion)
        ORDER BY
            sub.OB_NAM_PositedAt DESC,
            sub.OB_NAM_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOB_Object viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lOB_Object]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [OB].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_Object] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
    ) [OB];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pOB_Object viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pOB_Object] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [OB].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_Object] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [OB];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOB_Object viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nOB_Object]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [OB].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_Object] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
    ) [OB];
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
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
-- @assertion whether to show positve, negative, uncertain, or all posits (defaults to all)
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
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].SU_ID_for,
    [QTY].EV_QTY_EV_ID,
    [QTY].Metadata_EV_QTY,
    [QTY].EV_QTY_ID,
    [QTY].EV_QTY_PositedAt,
    [QTY].EV_QTY_Positor,
    [QTY].EV_QTY_Reliability,
    [QTY].EV_QTY_Assertion,
    [QTY].EV_QTY_Event_Quantity,
    [PLC].EV_PLC_EV_ID,
    [PLC].Metadata_EV_PLC,
    [PLC].EV_PLC_ID,
    [PLC].EV_PLC_ChangedAt,
    [PLC].EV_PLC_PositedAt,
    [PLC].EV_PLC_Positor,
    [PLC].EV_PLC_Reliability,
    [PLC].EV_PLC_Assertion,
    [PLC].EV_PLC_Event_Place
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[rEV_QTY_Event_Quantity](
        @positor,
        @positingTimepoint
    ) [QTY]
ON
    [QTY].EV_QTY_ID = (
        SELECT TOP 1
            sub.EV_QTY_ID
        FROM
            [dbo].[rEV_QTY_Event_Quantity](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_QTY_EV_ID = [EV].EV_ID
        AND
            sub.EV_QTY_Assertion = isnull(@assertion, sub.EV_QTY_Assertion)
        ORDER BY
            sub.EV_QTY_PositedAt DESC,
            sub.EV_QTY_Reliability DESC
    )
LEFT JOIN
    [dbo].[rEV_PLC_Event_Place](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [PLC]
ON
    [PLC].EV_PLC_ID = (
        SELECT TOP 1
            sub.EV_PLC_ID
        FROM
            [dbo].[rEV_PLC_Event_Place](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_PLC_EV_ID = [EV].EV_ID
        AND
            sub.EV_PLC_Assertion = isnull(@assertion, sub.EV_PLC_Assertion)
        ORDER BY
            sub.EV_PLC_ChangedAt DESC,
            sub.EV_PLC_PositedAt DESC,
            sub.EV_PLC_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lEV_Event viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lEV_Event]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tEV_Event] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
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
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tEV_Event] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [EV];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_Event viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nEV_Event]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tEV_Event] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
    ) [EV];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dEV_Event showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dEV_Event] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    [EV].*
FROM
    [dbo].[_Positor] p
JOIN (
    SELECT DISTINCT
        EV_PLC_Positor AS positor,
        EV_PLC_EV_ID AS EV_ID,
        EV_PLC_ChangedAt AS inspectedTimepoint,
        'PLC' AS mnemonic
    FROM
        [dbo].[EV_PLC_Event_Place]
    WHERE
        (@selection is null OR @selection like '%PLC%')
    AND
        EV_PLC_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [dbo].[tEV_Event] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [EV]
 WHERE
    [EV].EV_ID = timepoints.EV_ID;
GO
-- KEY GENERATORS -----------------------------------------------------------------------------------------------------
--
-- These stored procedures can be used to generate identities of entities.
-- Corresponding anchors must have an incrementing identity column.
--
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kSU_Subject identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kSU_Subject', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kSU_Subject] (
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
            INSERT INTO [dbo].[SU_Subject] (
                Metadata_SU
            )
            OUTPUT
                inserted.SU_ID
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
-- kOB_Object identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kOB_Object', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kOB_Object] (
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
            INSERT INTO [dbo].[OB_Object] (
                Metadata_OB
            )
            OUTPUT
                inserted.OB_ID
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
-- it_EV_QTY_Event_Quantity instead of INSERT trigger on EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_QTY_Event_Quantity', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_QTY_Event_Quantity];
GO
CREATE TRIGGER [dbo].[it_EV_QTY_Event_Quantity] ON [dbo].[EV_QTY_Event_Quantity]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_QTY_Event_Quantity TABLE (
        EV_QTY_EV_ID int not null,
        Metadata_EV_QTY int not null,
        EV_QTY_Positor tinyint not null,
        EV_QTY_PositedAt datetime2 not null,
        EV_QTY_Reliability decimal(5,2) not null,
        EV_QTY_Assertion char(1) not null,
        EV_QTY_Event_Quantity int not null,
        EV_QTY_Version bigint not null,
        EV_QTY_StatementType char(1) not null,
        primary key(
            EV_QTY_Version,
            EV_QTY_Positor,
            EV_QTY_EV_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_QTY_EV_ID,
            i.EV_QTY_Positor,
            i.EV_QTY_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_QTY_Event_Quantity_Posit] p
            JOIN
                [dbo].[EV_QTY_Event_Quantity_Annex] a
            ON
                a.EV_QTY_ID = p.EV_QTY_ID
            WHERE
                p.EV_QTY_EV_ID = i.EV_QTY_EV_ID
            AND
                p.EV_QTY_Event_Quantity = i.EV_QTY_Event_Quantity
            AND
                a.EV_QTY_Positor = i.EV_QTY_Positor
            AND
                a.EV_QTY_PositedAt = i.EV_QTY_PositedAt
            AND
                a.EV_QTY_Reliability <> i.EV_QTY_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_QTY_Event_Quantity for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_QTY_Event_Quantity
    SELECT
        i.EV_QTY_EV_ID,
        i.Metadata_EV_QTY,
        i.EV_QTY_Positor,
        i.EV_QTY_PositedAt,
        i.EV_QTY_Reliability,
        case
            when i.EV_QTY_Reliability > 0 then '+'
            when i.EV_QTY_Reliability = 0 then '?'
            when i.EV_QTY_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_QTY_Event_Quantity,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_QTY_Positor,
                i.EV_QTY_EV_ID
            ORDER BY
                i.EV_QTY_PositedAt ASC,
                i.EV_QTY_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Annex] a
        ON
            a.EV_QTY_ID = p.EV_QTY_ID
        WHERE
            p.EV_QTY_EV_ID = i.EV_QTY_EV_ID
        AND
            p.EV_QTY_Event_Quantity = i.EV_QTY_Event_Quantity
        AND
            a.EV_QTY_Positor = i.EV_QTY_Positor
        AND
            a.EV_QTY_PositedAt = i.EV_QTY_PositedAt
    );
    SELECT
        @maxVersion = max(EV_QTY_Version),
        @currentVersion = 0
    FROM
        @EV_QTY_Event_Quantity;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_QTY_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_QTY_ID
                        FROM
                            [dbo].[tEV_Event](v.EV_QTY_Positor, DEFAULT, v.EV_QTY_PositedAt, v.EV_QTY_Assertion) t
                        WHERE
                            t.EV_QTY_EV_ID = v.EV_QTY_EV_ID
                        AND
                            t.EV_QTY_Reliability = v.EV_QTY_Reliability
                        AND
                            t.EV_QTY_Event_Quantity = v.EV_QTY_Event_Quantity
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_QTY_EV_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_QTY_Event_Quantity v
        LEFT JOIN
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        ON
            p.EV_QTY_EV_ID = v.EV_QTY_EV_ID
        AND
            p.EV_QTY_Event_Quantity = v.EV_QTY_Event_Quantity
        WHERE
            v.EV_QTY_Version = @currentVersion;
        INSERT INTO [dbo].[EV_QTY_Event_Quantity_Posit] (
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity
        )
        SELECT
            v.EV_QTY_EV_ID,
            v.EV_QTY_Event_Quantity
        FROM
            @EV_QTY_Event_Quantity v
        WHERE
            v.EV_QTY_Version = @currentVersion
        AND
            v.EV_QTY_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @EV_QTY_Event_Quantity w
            WHERE
                w.EV_QTY_Version = v.EV_QTY_Version
            AND
                w.EV_QTY_Positor < v.EV_QTY_Positor
            AND
                w.EV_QTY_EV_ID = v.EV_QTY_EV_ID
            AND
                w.EV_QTY_Event_Quantity = v.EV_QTY_Event_Quantity
            AND
                w.EV_QTY_StatementType in ('N')
        );
        INSERT INTO [dbo].[EV_QTY_Event_Quantity_Annex] (
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_Positor,
            EV_QTY_PositedAt,
            EV_QTY_Reliability
        )
        SELECT
            v.Metadata_EV_QTY,
            p.EV_QTY_ID,
            v.EV_QTY_Positor,
            v.EV_QTY_PositedAt,
            v.EV_QTY_Reliability
        FROM
            @EV_QTY_Event_Quantity v
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        ON
            p.EV_QTY_EV_ID = v.EV_QTY_EV_ID
        AND
            p.EV_QTY_Event_Quantity = v.EV_QTY_Event_Quantity
        WHERE
            v.EV_QTY_Version = @currentVersion
        AND
            EV_QTY_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_PLC_Event_Place instead of INSERT trigger on EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_PLC_Event_Place', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_PLC_Event_Place];
GO
CREATE TRIGGER [dbo].[it_EV_PLC_Event_Place] ON [dbo].[EV_PLC_Event_Place]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_PLC_Event_Place TABLE (
        EV_PLC_EV_ID int not null,
        Metadata_EV_PLC int not null,
        EV_PLC_ChangedAt datetime2 not null,
        EV_PLC_Positor tinyint not null,
        EV_PLC_PositedAt datetime2 not null,
        EV_PLC_Reliability decimal(5,2) not null,
        EV_PLC_Assertion char(1) not null,
        EV_PLC_Event_Place nvarchar(42) not null,
        EV_PLC_Version bigint not null,
        EV_PLC_StatementType char(1) not null,
        primary key(
            EV_PLC_Version,
            EV_PLC_Positor,
            EV_PLC_EV_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_PLC_EV_ID,
            i.EV_PLC_ChangedAt,
            i.EV_PLC_Positor,
            i.EV_PLC_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_PLC_Event_Place_Posit] p
            JOIN
                [dbo].[EV_PLC_Event_Place_Annex] a
            ON
                a.EV_PLC_ID = p.EV_PLC_ID
            WHERE
                p.EV_PLC_EV_ID = i.EV_PLC_EV_ID
            AND
                p.EV_PLC_ChangedAt = i.EV_PLC_ChangedAt
            AND
                p.EV_PLC_Event_Place = i.EV_PLC_Event_Place
            AND
                a.EV_PLC_Positor = i.EV_PLC_Positor
            AND
                a.EV_PLC_PositedAt = i.EV_PLC_PositedAt
            AND
                a.EV_PLC_Reliability <> i.EV_PLC_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_PLC_Event_Place for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_PLC_Event_Place
    SELECT
        i.EV_PLC_EV_ID,
        i.Metadata_EV_PLC,
        i.EV_PLC_ChangedAt,
        i.EV_PLC_Positor,
        i.EV_PLC_PositedAt,
        i.EV_PLC_Reliability,
        case
            when i.EV_PLC_Reliability > 0 then '+'
            when i.EV_PLC_Reliability = 0 then '?'
            when i.EV_PLC_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_PLC_Event_Place,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_PLC_Positor,
                i.EV_PLC_EV_ID
            ORDER BY
                i.EV_PLC_ChangedAt ASC,
                i.EV_PLC_PositedAt ASC,
                i.EV_PLC_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_PLC_Event_Place_Posit] p
        JOIN
            [dbo].[EV_PLC_Event_Place_Annex] a
        ON
            a.EV_PLC_ID = p.EV_PLC_ID
        WHERE
            p.EV_PLC_EV_ID = i.EV_PLC_EV_ID
        AND
            p.EV_PLC_ChangedAt = i.EV_PLC_ChangedAt
        AND
            p.EV_PLC_Event_Place = i.EV_PLC_Event_Place
        AND
            a.EV_PLC_Positor = i.EV_PLC_Positor
        AND
            a.EV_PLC_PositedAt = i.EV_PLC_PositedAt
    );
    SELECT
        @maxVersion = max(EV_PLC_Version),
        @currentVersion = 0
    FROM
        @EV_PLC_Event_Place;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_PLC_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_PLC_ID
                        FROM
                            [dbo].[tEV_Event](v.EV_PLC_Positor, v.EV_PLC_ChangedAt, v.EV_PLC_PositedAt, v.EV_PLC_Assertion) t
                        WHERE
                            t.EV_PLC_EV_ID = v.EV_PLC_EV_ID
                        AND
                            t.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
                        AND
                            t.EV_PLC_Reliability = v.EV_PLC_Reliability
                        AND
                            t.EV_PLC_Event_Place = v.EV_PLC_Event_Place
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_PLC_EV_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.EV_PLC_Event_Place
                        WHERE
                            v.EV_PLC_Event_Place =
                                dbo.preEV_PLC_Event_Place (
                                    v.EV_PLC_EV_ID,
                                    v.EV_PLC_Positor,
                                    v.EV_PLC_ChangedAt,
                                    v.EV_PLC_PositedAt,
                                    v.EV_PLC_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.EV_PLC_Event_Place
                        WHERE
                            v.EV_PLC_Event_Place =
                                dbo.folEV_PLC_Event_Place (
                                    v.EV_PLC_EV_ID,
                                    v.EV_PLC_Positor,
                                    v.EV_PLC_ChangedAt,
                                    v.EV_PLC_PositedAt,
                                    v.EV_PLC_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_PLC_Event_Place v
        LEFT JOIN
            [dbo].[EV_PLC_Event_Place_Posit] p
        ON
            p.EV_PLC_EV_ID = v.EV_PLC_EV_ID
        AND
            p.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
        AND
            p.EV_PLC_Event_Place = v.EV_PLC_Event_Place
        WHERE
            v.EV_PLC_Version = @currentVersion;
        INSERT INTO [dbo].[EV_PLC_Event_Place_Posit] (
            EV_PLC_EV_ID,
            EV_PLC_ChangedAt,
            EV_PLC_Event_Place
        )
        SELECT
            v.EV_PLC_EV_ID,
            v.EV_PLC_ChangedAt,
            v.EV_PLC_Event_Place
        FROM
            @EV_PLC_Event_Place v
        WHERE
            v.EV_PLC_Version = @currentVersion
        AND
            v.EV_PLC_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @EV_PLC_Event_Place w
            WHERE
                w.EV_PLC_Version = v.EV_PLC_Version
            AND
                w.EV_PLC_Positor < v.EV_PLC_Positor
            AND
                w.EV_PLC_EV_ID = v.EV_PLC_EV_ID
            AND
                w.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
            AND
                w.EV_PLC_Event_Place = v.EV_PLC_Event_Place
            AND
                w.EV_PLC_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[EV_PLC_Event_Place_Annex] (
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_Positor,
            EV_PLC_PositedAt,
            EV_PLC_Reliability
        )
        SELECT
            v.Metadata_EV_PLC,
            p.EV_PLC_ID,
            v.EV_PLC_Positor,
            v.EV_PLC_PositedAt,
            v.EV_PLC_Reliability
        FROM
            @EV_PLC_Event_Place v
        JOIN
            [dbo].[EV_PLC_Event_Place_Posit] p
        ON
            p.EV_PLC_EV_ID = v.EV_PLC_EV_ID
        AND
            p.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
        AND
            p.EV_PLC_Event_Place = v.EV_PLC_Event_Place
        WHERE
            v.EV_PLC_Version = @currentVersion
        AND
            EV_PLC_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NAM_Subject_Name instead of INSERT trigger on SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_NAM_Subject_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_NAM_Subject_Name];
GO
CREATE TRIGGER [dbo].[it_SU_NAM_Subject_Name] ON [dbo].[SU_NAM_Subject_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_NAM_Subject_Name TABLE (
        SU_NAM_SU_ID int not null,
        Metadata_SU_NAM int not null,
        SU_NAM_Positor tinyint not null,
        SU_NAM_PositedAt datetime2 not null,
        SU_NAM_Reliability decimal(5,2) not null,
        SU_NAM_Assertion char(1) not null,
        SU_NAM_Subject_Name nvarchar(42) not null,
        SU_NAM_Version bigint not null,
        SU_NAM_StatementType char(1) not null,
        primary key(
            SU_NAM_Version,
            SU_NAM_Positor,
            SU_NAM_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_NAM_SU_ID,
            i.SU_NAM_Positor,
            i.SU_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_NAM_Subject_Name_Posit] p
            JOIN
                [dbo].[SU_NAM_Subject_Name_Annex] a
            ON
                a.SU_NAM_ID = p.SU_NAM_ID
            WHERE
                p.SU_NAM_SU_ID = i.SU_NAM_SU_ID
            AND
                p.SU_NAM_Subject_Name = i.SU_NAM_Subject_Name
            AND
                a.SU_NAM_Positor = i.SU_NAM_Positor
            AND
                a.SU_NAM_PositedAt = i.SU_NAM_PositedAt
            AND
                a.SU_NAM_Reliability <> i.SU_NAM_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_NAM_Subject_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_NAM_Subject_Name
    SELECT
        i.SU_NAM_SU_ID,
        i.Metadata_SU_NAM,
        i.SU_NAM_Positor,
        i.SU_NAM_PositedAt,
        i.SU_NAM_Reliability,
        case
            when i.SU_NAM_Reliability > 0 then '+'
            when i.SU_NAM_Reliability = 0 then '?'
            when i.SU_NAM_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_NAM_Subject_Name,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_NAM_Positor,
                i.SU_NAM_SU_ID
            ORDER BY
                i.SU_NAM_PositedAt ASC,
                i.SU_NAM_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_NAM_Subject_Name_Posit] p
        JOIN
            [dbo].[SU_NAM_Subject_Name_Annex] a
        ON
            a.SU_NAM_ID = p.SU_NAM_ID
        WHERE
            p.SU_NAM_SU_ID = i.SU_NAM_SU_ID
        AND
            p.SU_NAM_Subject_Name = i.SU_NAM_Subject_Name
        AND
            a.SU_NAM_Positor = i.SU_NAM_Positor
        AND
            a.SU_NAM_PositedAt = i.SU_NAM_PositedAt
    );
    SELECT
        @maxVersion = max(SU_NAM_Version),
        @currentVersion = 0
    FROM
        @SU_NAM_Subject_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_NAM_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_NAM_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_NAM_Positor, DEFAULT, v.SU_NAM_PositedAt, v.SU_NAM_Assertion) t
                        WHERE
                            t.SU_NAM_SU_ID = v.SU_NAM_SU_ID
                        AND
                            t.SU_NAM_Reliability = v.SU_NAM_Reliability
                        AND
                            t.SU_NAM_Subject_Name = v.SU_NAM_Subject_Name
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_NAM_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_NAM_Subject_Name v
        LEFT JOIN
            [dbo].[SU_NAM_Subject_Name_Posit] p
        ON
            p.SU_NAM_SU_ID = v.SU_NAM_SU_ID
        AND
            p.SU_NAM_Subject_Name = v.SU_NAM_Subject_Name
        WHERE
            v.SU_NAM_Version = @currentVersion;
        INSERT INTO [dbo].[SU_NAM_Subject_Name_Posit] (
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name
        )
        SELECT
            v.SU_NAM_SU_ID,
            v.SU_NAM_Subject_Name
        FROM
            @SU_NAM_Subject_Name v
        WHERE
            v.SU_NAM_Version = @currentVersion
        AND
            v.SU_NAM_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_NAM_Subject_Name w
            WHERE
                w.SU_NAM_Version = v.SU_NAM_Version
            AND
                w.SU_NAM_Positor < v.SU_NAM_Positor
            AND
                w.SU_NAM_SU_ID = v.SU_NAM_SU_ID
            AND
                w.SU_NAM_Subject_Name = v.SU_NAM_Subject_Name
            AND
                w.SU_NAM_StatementType in ('N')
        );
        INSERT INTO [dbo].[SU_NAM_Subject_Name_Annex] (
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_Positor,
            SU_NAM_PositedAt,
            SU_NAM_Reliability
        )
        SELECT
            v.Metadata_SU_NAM,
            p.SU_NAM_ID,
            v.SU_NAM_Positor,
            v.SU_NAM_PositedAt,
            v.SU_NAM_Reliability
        FROM
            @SU_NAM_Subject_Name v
        JOIN
            [dbo].[SU_NAM_Subject_Name_Posit] p
        ON
            p.SU_NAM_SU_ID = v.SU_NAM_SU_ID
        AND
            p.SU_NAM_Subject_Name = v.SU_NAM_Subject_Name
        WHERE
            v.SU_NAM_Version = @currentVersion
        AND
            SU_NAM_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_COD_Subject_Code instead of INSERT trigger on SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_COD_Subject_Code', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_COD_Subject_Code];
GO
CREATE TRIGGER [dbo].[it_SU_COD_Subject_Code] ON [dbo].[SU_COD_Subject_Code]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_COD_Subject_Code TABLE (
        SU_COD_SU_ID int not null,
        Metadata_SU_COD int not null,
        SU_COD_Positor tinyint not null,
        SU_COD_PositedAt datetime2 not null,
        SU_COD_Reliability decimal(5,2) not null,
        SU_COD_Assertion char(1) not null,
        SU_COD_Subject_Code nvarchar(42) not null,
        SU_COD_Version bigint not null,
        SU_COD_StatementType char(1) not null,
        primary key(
            SU_COD_Version,
            SU_COD_Positor,
            SU_COD_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_COD_SU_ID,
            i.SU_COD_Positor,
            i.SU_COD_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_COD_Subject_Code_Posit] p
            JOIN
                [dbo].[SU_COD_Subject_Code_Annex] a
            ON
                a.SU_COD_ID = p.SU_COD_ID
            WHERE
                p.SU_COD_SU_ID = i.SU_COD_SU_ID
            AND
                p.SU_COD_Subject_Code = i.SU_COD_Subject_Code
            AND
                a.SU_COD_Positor = i.SU_COD_Positor
            AND
                a.SU_COD_PositedAt = i.SU_COD_PositedAt
            AND
                a.SU_COD_Reliability <> i.SU_COD_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_COD_Subject_Code for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_COD_Subject_Code
    SELECT
        i.SU_COD_SU_ID,
        i.Metadata_SU_COD,
        i.SU_COD_Positor,
        i.SU_COD_PositedAt,
        i.SU_COD_Reliability,
        case
            when i.SU_COD_Reliability > 0 then '+'
            when i.SU_COD_Reliability = 0 then '?'
            when i.SU_COD_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_COD_Subject_Code,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_COD_Positor,
                i.SU_COD_SU_ID
            ORDER BY
                i.SU_COD_PositedAt ASC,
                i.SU_COD_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_COD_Subject_Code_Posit] p
        JOIN
            [dbo].[SU_COD_Subject_Code_Annex] a
        ON
            a.SU_COD_ID = p.SU_COD_ID
        WHERE
            p.SU_COD_SU_ID = i.SU_COD_SU_ID
        AND
            p.SU_COD_Subject_Code = i.SU_COD_Subject_Code
        AND
            a.SU_COD_Positor = i.SU_COD_Positor
        AND
            a.SU_COD_PositedAt = i.SU_COD_PositedAt
    );
    SELECT
        @maxVersion = max(SU_COD_Version),
        @currentVersion = 0
    FROM
        @SU_COD_Subject_Code;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_COD_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_COD_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_COD_Positor, DEFAULT, v.SU_COD_PositedAt, v.SU_COD_Assertion) t
                        WHERE
                            t.SU_COD_SU_ID = v.SU_COD_SU_ID
                        AND
                            t.SU_COD_Reliability = v.SU_COD_Reliability
                        AND
                            t.SU_COD_Subject_Code = v.SU_COD_Subject_Code
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_COD_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_COD_Subject_Code v
        LEFT JOIN
            [dbo].[SU_COD_Subject_Code_Posit] p
        ON
            p.SU_COD_SU_ID = v.SU_COD_SU_ID
        AND
            p.SU_COD_Subject_Code = v.SU_COD_Subject_Code
        WHERE
            v.SU_COD_Version = @currentVersion;
        INSERT INTO [dbo].[SU_COD_Subject_Code_Posit] (
            SU_COD_SU_ID,
            SU_COD_Subject_Code
        )
        SELECT
            v.SU_COD_SU_ID,
            v.SU_COD_Subject_Code
        FROM
            @SU_COD_Subject_Code v
        WHERE
            v.SU_COD_Version = @currentVersion
        AND
            v.SU_COD_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_COD_Subject_Code w
            WHERE
                w.SU_COD_Version = v.SU_COD_Version
            AND
                w.SU_COD_Positor < v.SU_COD_Positor
            AND
                w.SU_COD_SU_ID = v.SU_COD_SU_ID
            AND
                w.SU_COD_Subject_Code = v.SU_COD_Subject_Code
            AND
                w.SU_COD_StatementType in ('N')
        );
        INSERT INTO [dbo].[SU_COD_Subject_Code_Annex] (
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_Positor,
            SU_COD_PositedAt,
            SU_COD_Reliability
        )
        SELECT
            v.Metadata_SU_COD,
            p.SU_COD_ID,
            v.SU_COD_Positor,
            v.SU_COD_PositedAt,
            v.SU_COD_Reliability
        FROM
            @SU_COD_Subject_Code v
        JOIN
            [dbo].[SU_COD_Subject_Code_Posit] p
        ON
            p.SU_COD_SU_ID = v.SU_COD_SU_ID
        AND
            p.SU_COD_Subject_Code = v.SU_COD_Subject_Code
        WHERE
            v.SU_COD_Version = @currentVersion
        AND
            SU_COD_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_GRD_Subject_Grade instead of INSERT trigger on SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_GRD_Subject_Grade', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_GRD_Subject_Grade];
GO
CREATE TRIGGER [dbo].[it_SU_GRD_Subject_Grade] ON [dbo].[SU_GRD_Subject_Grade]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_GRD_Subject_Grade TABLE (
        SU_GRD_SU_ID int not null,
        Metadata_SU_GRD int not null,
        SU_GRD_Positor tinyint not null,
        SU_GRD_PositedAt datetime2 not null,
        SU_GRD_Reliability decimal(5,2) not null,
        SU_GRD_Assertion char(1) not null,
        SU_GRD_GRD_ID tinyint not null,
        SU_GRD_Version bigint not null,
        SU_GRD_StatementType char(1) not null,
        primary key(
            SU_GRD_Version,
            SU_GRD_Positor,
            SU_GRD_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_GRD_SU_ID,
            i.SU_GRD_Positor,
            i.SU_GRD_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_GRD_Subject_Grade_Posit] p
            JOIN
                [dbo].[SU_GRD_Subject_Grade_Annex] a
            ON
                a.SU_GRD_ID = p.SU_GRD_ID
            WHERE
                p.SU_GRD_SU_ID = i.SU_GRD_SU_ID
            AND
                p.SU_GRD_GRD_ID = i.SU_GRD_GRD_ID
            AND
                a.SU_GRD_Positor = i.SU_GRD_Positor
            AND
                a.SU_GRD_PositedAt = i.SU_GRD_PositedAt
            AND
                a.SU_GRD_Reliability <> i.SU_GRD_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_GRD_Subject_Grade for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_GRD_Subject_Grade
    SELECT
        i.SU_GRD_SU_ID,
        i.Metadata_SU_GRD,
        i.SU_GRD_Positor,
        i.SU_GRD_PositedAt,
        i.SU_GRD_Reliability,
        case
            when i.SU_GRD_Reliability > 0 then '+'
            when i.SU_GRD_Reliability = 0 then '?'
            when i.SU_GRD_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_GRD_GRD_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_GRD_Positor,
                i.SU_GRD_SU_ID
            ORDER BY
                i.SU_GRD_PositedAt ASC,
                i.SU_GRD_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        JOIN
            [dbo].[SU_GRD_Subject_Grade_Annex] a
        ON
            a.SU_GRD_ID = p.SU_GRD_ID
        WHERE
            p.SU_GRD_SU_ID = i.SU_GRD_SU_ID
        AND
            p.SU_GRD_GRD_ID = i.SU_GRD_GRD_ID
        AND
            a.SU_GRD_Positor = i.SU_GRD_Positor
        AND
            a.SU_GRD_PositedAt = i.SU_GRD_PositedAt
    );
    SELECT
        @maxVersion = max(SU_GRD_Version),
        @currentVersion = 0
    FROM
        @SU_GRD_Subject_Grade;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_GRD_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_GRD_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_GRD_Positor, DEFAULT, v.SU_GRD_PositedAt, v.SU_GRD_Assertion) t
                        WHERE
                            t.SU_GRD_SU_ID = v.SU_GRD_SU_ID
                        AND
                            t.SU_GRD_Reliability = v.SU_GRD_Reliability
                        AND
                            t.SU_GRD_GRD_ID = v.SU_GRD_GRD_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_GRD_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_GRD_Subject_Grade v
        LEFT JOIN
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        ON
            p.SU_GRD_SU_ID = v.SU_GRD_SU_ID
        AND
            p.SU_GRD_GRD_ID = v.SU_GRD_GRD_ID
        WHERE
            v.SU_GRD_Version = @currentVersion;
        INSERT INTO [dbo].[SU_GRD_Subject_Grade_Posit] (
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID
        )
        SELECT
            v.SU_GRD_SU_ID,
            v.SU_GRD_GRD_ID
        FROM
            @SU_GRD_Subject_Grade v
        WHERE
            v.SU_GRD_Version = @currentVersion
        AND
            v.SU_GRD_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_GRD_Subject_Grade w
            WHERE
                w.SU_GRD_Version = v.SU_GRD_Version
            AND
                w.SU_GRD_Positor < v.SU_GRD_Positor
            AND
                w.SU_GRD_SU_ID = v.SU_GRD_SU_ID
            AND
                w.SU_GRD_GRD_ID = v.SU_GRD_GRD_ID
            AND
                w.SU_GRD_StatementType in ('N')
        );
        INSERT INTO [dbo].[SU_GRD_Subject_Grade_Annex] (
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_Positor,
            SU_GRD_PositedAt,
            SU_GRD_Reliability
        )
        SELECT
            v.Metadata_SU_GRD,
            p.SU_GRD_ID,
            v.SU_GRD_Positor,
            v.SU_GRD_PositedAt,
            v.SU_GRD_Reliability
        FROM
            @SU_GRD_Subject_Grade v
        JOIN
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        ON
            p.SU_GRD_SU_ID = v.SU_GRD_SU_ID
        AND
            p.SU_GRD_GRD_ID = v.SU_GRD_GRD_ID
        WHERE
            v.SU_GRD_Version = @currentVersion
        AND
            SU_GRD_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NOT_Subject_Note instead of INSERT trigger on SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_NOT_Subject_Note', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_NOT_Subject_Note];
GO
CREATE TRIGGER [dbo].[it_SU_NOT_Subject_Note] ON [dbo].[SU_NOT_Subject_Note]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_NOT_Subject_Note TABLE (
        SU_NOT_SU_ID int not null,
        Metadata_SU_NOT int not null,
        SU_NOT_Positor tinyint not null,
        SU_NOT_PositedAt datetime2 not null,
        SU_NOT_Reliability decimal(5,2) not null,
        SU_NOT_Assertion char(1) not null,
        SU_NOT_Subject_Note nvarchar(max) not null,
        SU_NOT_Checksum varbinary(16) not null,
        SU_NOT_Version bigint not null,
        SU_NOT_StatementType char(1) not null,
        primary key(
            SU_NOT_Version,
            SU_NOT_Positor,
            SU_NOT_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_NOT_SU_ID,
            i.SU_NOT_Positor,
            i.SU_NOT_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_NOT_Subject_Note_Posit] p
            JOIN
                [dbo].[SU_NOT_Subject_Note_Annex] a
            ON
                a.SU_NOT_ID = p.SU_NOT_ID
            WHERE
                p.SU_NOT_SU_ID = i.SU_NOT_SU_ID
            AND
                p.SU_NOT_Checksum = dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
            AND
                a.SU_NOT_Positor = i.SU_NOT_Positor
            AND
                a.SU_NOT_PositedAt = i.SU_NOT_PositedAt
            AND
                a.SU_NOT_Reliability <> i.SU_NOT_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_NOT_Subject_Note for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_NOT_Subject_Note
    SELECT
        i.SU_NOT_SU_ID,
        i.Metadata_SU_NOT,
        i.SU_NOT_Positor,
        i.SU_NOT_PositedAt,
        i.SU_NOT_Reliability,
        case
            when i.SU_NOT_Reliability > 0 then '+'
            when i.SU_NOT_Reliability = 0 then '?'
            when i.SU_NOT_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_NOT_Subject_Note,
        dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max))),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_NOT_Positor,
                i.SU_NOT_SU_ID
            ORDER BY
                i.SU_NOT_PositedAt ASC,
                i.SU_NOT_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_NOT_Subject_Note_Posit] p
        JOIN
            [dbo].[SU_NOT_Subject_Note_Annex] a
        ON
            a.SU_NOT_ID = p.SU_NOT_ID
        WHERE
            p.SU_NOT_SU_ID = i.SU_NOT_SU_ID
        AND
            p.SU_NOT_Checksum = dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
        AND
            a.SU_NOT_Positor = i.SU_NOT_Positor
        AND
            a.SU_NOT_PositedAt = i.SU_NOT_PositedAt
    );
    SELECT
        @maxVersion = max(SU_NOT_Version),
        @currentVersion = 0
    FROM
        @SU_NOT_Subject_Note;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_NOT_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_NOT_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_NOT_Positor, DEFAULT, v.SU_NOT_PositedAt, v.SU_NOT_Assertion) t
                        WHERE
                            t.SU_NOT_SU_ID = v.SU_NOT_SU_ID
                        AND
                            t.SU_NOT_Reliability = v.SU_NOT_Reliability
                        AND
                            t.SU_NOT_Checksum = v.SU_NOT_Checksum
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_NOT_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_NOT_Subject_Note v
        LEFT JOIN
            [dbo].[SU_NOT_Subject_Note_Posit] p
        ON
            p.SU_NOT_SU_ID = v.SU_NOT_SU_ID
        AND
            p.SU_NOT_Checksum = v.SU_NOT_Checksum
        WHERE
            v.SU_NOT_Version = @currentVersion;
        INSERT INTO [dbo].[SU_NOT_Subject_Note_Posit] (
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note
        )
        SELECT
            v.SU_NOT_SU_ID,
            v.SU_NOT_Subject_Note
        FROM
            @SU_NOT_Subject_Note v
        WHERE
            v.SU_NOT_Version = @currentVersion
        AND
            v.SU_NOT_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_NOT_Subject_Note w
            WHERE
                w.SU_NOT_Version = v.SU_NOT_Version
            AND
                w.SU_NOT_Positor < v.SU_NOT_Positor
            AND
                w.SU_NOT_SU_ID = v.SU_NOT_SU_ID
            AND
                w.SU_NOT_Checksum = v.SU_NOT_Checksum
            AND
                w.SU_NOT_StatementType in ('N')
        );
        INSERT INTO [dbo].[SU_NOT_Subject_Note_Annex] (
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_Positor,
            SU_NOT_PositedAt,
            SU_NOT_Reliability
        )
        SELECT
            v.Metadata_SU_NOT,
            p.SU_NOT_ID,
            v.SU_NOT_Positor,
            v.SU_NOT_PositedAt,
            v.SU_NOT_Reliability
        FROM
            @SU_NOT_Subject_Note v
        JOIN
            [dbo].[SU_NOT_Subject_Note_Posit] p
        ON
            p.SU_NOT_SU_ID = v.SU_NOT_SU_ID
        AND
            p.SU_NOT_Checksum = v.SU_NOT_Checksum
        WHERE
            v.SU_NOT_Version = @currentVersion
        AND
            SU_NOT_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TTL_Subject_Title instead of INSERT trigger on SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TTL_Subject_Title', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TTL_Subject_Title];
GO
CREATE TRIGGER [dbo].[it_SU_TTL_Subject_Title] ON [dbo].[SU_TTL_Subject_Title]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_TTL_Subject_Title TABLE (
        SU_TTL_SU_ID int not null,
        Metadata_SU_TTL int not null,
        SU_TTL_ChangedAt datetime2 not null,
        SU_TTL_Positor tinyint not null,
        SU_TTL_PositedAt datetime2 not null,
        SU_TTL_Reliability decimal(5,2) not null,
        SU_TTL_Assertion char(1) not null,
        SU_TTL_Subject_Title nvarchar(42) not null,
        SU_TTL_Version bigint not null,
        SU_TTL_StatementType char(1) not null,
        primary key(
            SU_TTL_Version,
            SU_TTL_Positor,
            SU_TTL_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TTL_SU_ID,
            i.SU_TTL_ChangedAt,
            i.SU_TTL_Positor,
            i.SU_TTL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TTL_Subject_Title_Posit] p
            JOIN
                [dbo].[SU_TTL_Subject_Title_Annex] a
            ON
                a.SU_TTL_ID = p.SU_TTL_ID
            WHERE
                p.SU_TTL_SU_ID = i.SU_TTL_SU_ID
            AND
                p.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
            AND
                p.SU_TTL_Subject_Title = i.SU_TTL_Subject_Title
            AND
                a.SU_TTL_Positor = i.SU_TTL_Positor
            AND
                a.SU_TTL_PositedAt = i.SU_TTL_PositedAt
            AND
                a.SU_TTL_Reliability <> i.SU_TTL_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TTL_Subject_Title for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_TTL_Subject_Title
    SELECT
        i.SU_TTL_SU_ID,
        i.Metadata_SU_TTL,
        i.SU_TTL_ChangedAt,
        i.SU_TTL_Positor,
        i.SU_TTL_PositedAt,
        i.SU_TTL_Reliability,
        case
            when i.SU_TTL_Reliability > 0 then '+'
            when i.SU_TTL_Reliability = 0 then '?'
            when i.SU_TTL_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_TTL_Subject_Title,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_TTL_Positor,
                i.SU_TTL_SU_ID
            ORDER BY
                i.SU_TTL_ChangedAt ASC,
                i.SU_TTL_PositedAt ASC,
                i.SU_TTL_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_TTL_Subject_Title_Posit] p
        JOIN
            [dbo].[SU_TTL_Subject_Title_Annex] a
        ON
            a.SU_TTL_ID = p.SU_TTL_ID
        WHERE
            p.SU_TTL_SU_ID = i.SU_TTL_SU_ID
        AND
            p.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
        AND
            p.SU_TTL_Subject_Title = i.SU_TTL_Subject_Title
        AND
            a.SU_TTL_Positor = i.SU_TTL_Positor
        AND
            a.SU_TTL_PositedAt = i.SU_TTL_PositedAt
    );
    SELECT
        @maxVersion = max(SU_TTL_Version),
        @currentVersion = 0
    FROM
        @SU_TTL_Subject_Title;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_TTL_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_TTL_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_TTL_Positor, v.SU_TTL_ChangedAt, v.SU_TTL_PositedAt, v.SU_TTL_Assertion) t
                        WHERE
                            t.SU_TTL_SU_ID = v.SU_TTL_SU_ID
                        AND
                            t.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
                        AND
                            t.SU_TTL_Reliability = v.SU_TTL_Reliability
                        AND
                            t.SU_TTL_Subject_Title = v.SU_TTL_Subject_Title
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_TTL_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_TTL_Subject_Title
                        WHERE
                            v.SU_TTL_Subject_Title =
                                dbo.preSU_TTL_Subject_Title (
                                    v.SU_TTL_SU_ID,
                                    v.SU_TTL_Positor,
                                    v.SU_TTL_ChangedAt,
                                    v.SU_TTL_PositedAt,
                                    v.SU_TTL_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_TTL_Subject_Title
                        WHERE
                            v.SU_TTL_Subject_Title =
                                dbo.folSU_TTL_Subject_Title (
                                    v.SU_TTL_SU_ID,
                                    v.SU_TTL_Positor,
                                    v.SU_TTL_ChangedAt,
                                    v.SU_TTL_PositedAt,
                                    v.SU_TTL_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_TTL_Subject_Title v
        LEFT JOIN
            [dbo].[SU_TTL_Subject_Title_Posit] p
        ON
            p.SU_TTL_SU_ID = v.SU_TTL_SU_ID
        AND
            p.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
        AND
            p.SU_TTL_Subject_Title = v.SU_TTL_Subject_Title
        WHERE
            v.SU_TTL_Version = @currentVersion;
        INSERT INTO [dbo].[SU_TTL_Subject_Title_Posit] (
            SU_TTL_SU_ID,
            SU_TTL_ChangedAt,
            SU_TTL_Subject_Title
        )
        SELECT
            v.SU_TTL_SU_ID,
            v.SU_TTL_ChangedAt,
            v.SU_TTL_Subject_Title
        FROM
            @SU_TTL_Subject_Title v
        WHERE
            v.SU_TTL_Version = @currentVersion
        AND
            v.SU_TTL_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_TTL_Subject_Title w
            WHERE
                w.SU_TTL_Version = v.SU_TTL_Version
            AND
                w.SU_TTL_Positor < v.SU_TTL_Positor
            AND
                w.SU_TTL_SU_ID = v.SU_TTL_SU_ID
            AND
                w.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
            AND
                w.SU_TTL_Subject_Title = v.SU_TTL_Subject_Title
            AND
                w.SU_TTL_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_TTL_Subject_Title_Annex] (
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_Positor,
            SU_TTL_PositedAt,
            SU_TTL_Reliability
        )
        SELECT
            v.Metadata_SU_TTL,
            p.SU_TTL_ID,
            v.SU_TTL_Positor,
            v.SU_TTL_PositedAt,
            v.SU_TTL_Reliability
        FROM
            @SU_TTL_Subject_Title v
        JOIN
            [dbo].[SU_TTL_Subject_Title_Posit] p
        ON
            p.SU_TTL_SU_ID = v.SU_TTL_SU_ID
        AND
            p.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
        AND
            p.SU_TTL_Subject_Title = v.SU_TTL_Subject_Title
        WHERE
            v.SU_TTL_Version = @currentVersion
        AND
            SU_TTL_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_STA_Subject_State instead of INSERT trigger on SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_STA_Subject_State', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_STA_Subject_State];
GO
CREATE TRIGGER [dbo].[it_SU_STA_Subject_State] ON [dbo].[SU_STA_Subject_State]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_STA_Subject_State TABLE (
        SU_STA_SU_ID int not null,
        Metadata_SU_STA int not null,
        SU_STA_ChangedAt datetime2 not null,
        SU_STA_Positor tinyint not null,
        SU_STA_PositedAt datetime2 not null,
        SU_STA_Reliability decimal(5,2) not null,
        SU_STA_Assertion char(1) not null,
        SU_STA_Subject_State nvarchar(42) not null,
        SU_STA_Version bigint not null,
        SU_STA_StatementType char(1) not null,
        primary key(
            SU_STA_Version,
            SU_STA_Positor,
            SU_STA_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_STA_SU_ID,
            i.SU_STA_ChangedAt,
            i.SU_STA_Positor,
            i.SU_STA_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_STA_Subject_State_Posit] p
            JOIN
                [dbo].[SU_STA_Subject_State_Annex] a
            ON
                a.SU_STA_ID = p.SU_STA_ID
            WHERE
                p.SU_STA_SU_ID = i.SU_STA_SU_ID
            AND
                p.SU_STA_ChangedAt = i.SU_STA_ChangedAt
            AND
                p.SU_STA_Subject_State = i.SU_STA_Subject_State
            AND
                a.SU_STA_Positor = i.SU_STA_Positor
            AND
                a.SU_STA_PositedAt = i.SU_STA_PositedAt
            AND
                a.SU_STA_Reliability <> i.SU_STA_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_STA_Subject_State for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_STA_Subject_State
    SELECT
        i.SU_STA_SU_ID,
        i.Metadata_SU_STA,
        i.SU_STA_ChangedAt,
        i.SU_STA_Positor,
        i.SU_STA_PositedAt,
        i.SU_STA_Reliability,
        case
            when i.SU_STA_Reliability > 0 then '+'
            when i.SU_STA_Reliability = 0 then '?'
            when i.SU_STA_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_STA_Subject_State,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_STA_Positor,
                i.SU_STA_SU_ID
            ORDER BY
                i.SU_STA_ChangedAt ASC,
                i.SU_STA_PositedAt ASC,
                i.SU_STA_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_STA_Subject_State_Posit] p
        JOIN
            [dbo].[SU_STA_Subject_State_Annex] a
        ON
            a.SU_STA_ID = p.SU_STA_ID
        WHERE
            p.SU_STA_SU_ID = i.SU_STA_SU_ID
        AND
            p.SU_STA_ChangedAt = i.SU_STA_ChangedAt
        AND
            p.SU_STA_Subject_State = i.SU_STA_Subject_State
        AND
            a.SU_STA_Positor = i.SU_STA_Positor
        AND
            a.SU_STA_PositedAt = i.SU_STA_PositedAt
    );
    SELECT
        @maxVersion = max(SU_STA_Version),
        @currentVersion = 0
    FROM
        @SU_STA_Subject_State;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_STA_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_STA_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_STA_Positor, v.SU_STA_ChangedAt, v.SU_STA_PositedAt, v.SU_STA_Assertion) t
                        WHERE
                            t.SU_STA_SU_ID = v.SU_STA_SU_ID
                        AND
                            t.SU_STA_ChangedAt = v.SU_STA_ChangedAt
                        AND
                            t.SU_STA_Reliability = v.SU_STA_Reliability
                        AND
                            t.SU_STA_Subject_State = v.SU_STA_Subject_State
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_STA_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_STA_Subject_State
                        WHERE
                            v.SU_STA_Subject_State =
                                dbo.preSU_STA_Subject_State (
                                    v.SU_STA_SU_ID,
                                    v.SU_STA_Positor,
                                    v.SU_STA_ChangedAt,
                                    v.SU_STA_PositedAt,
                                    v.SU_STA_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_STA_Subject_State
                        WHERE
                            v.SU_STA_Subject_State =
                                dbo.folSU_STA_Subject_State (
                                    v.SU_STA_SU_ID,
                                    v.SU_STA_Positor,
                                    v.SU_STA_ChangedAt,
                                    v.SU_STA_PositedAt,
                                    v.SU_STA_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_STA_Subject_State v
        LEFT JOIN
            [dbo].[SU_STA_Subject_State_Posit] p
        ON
            p.SU_STA_SU_ID = v.SU_STA_SU_ID
        AND
            p.SU_STA_ChangedAt = v.SU_STA_ChangedAt
        AND
            p.SU_STA_Subject_State = v.SU_STA_Subject_State
        WHERE
            v.SU_STA_Version = @currentVersion;
        INSERT INTO [dbo].[SU_STA_Subject_State_Posit] (
            SU_STA_SU_ID,
            SU_STA_ChangedAt,
            SU_STA_Subject_State
        )
        SELECT
            v.SU_STA_SU_ID,
            v.SU_STA_ChangedAt,
            v.SU_STA_Subject_State
        FROM
            @SU_STA_Subject_State v
        WHERE
            v.SU_STA_Version = @currentVersion
        AND
            v.SU_STA_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_STA_Subject_State w
            WHERE
                w.SU_STA_Version = v.SU_STA_Version
            AND
                w.SU_STA_Positor < v.SU_STA_Positor
            AND
                w.SU_STA_SU_ID = v.SU_STA_SU_ID
            AND
                w.SU_STA_ChangedAt = v.SU_STA_ChangedAt
            AND
                w.SU_STA_Subject_State = v.SU_STA_Subject_State
            AND
                w.SU_STA_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_STA_Subject_State_Annex] (
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_Positor,
            SU_STA_PositedAt,
            SU_STA_Reliability
        )
        SELECT
            v.Metadata_SU_STA,
            p.SU_STA_ID,
            v.SU_STA_Positor,
            v.SU_STA_PositedAt,
            v.SU_STA_Reliability
        FROM
            @SU_STA_Subject_State v
        JOIN
            [dbo].[SU_STA_Subject_State_Posit] p
        ON
            p.SU_STA_SU_ID = v.SU_STA_SU_ID
        AND
            p.SU_STA_ChangedAt = v.SU_STA_ChangedAt
        AND
            p.SU_STA_Subject_State = v.SU_STA_Subject_State
        WHERE
            v.SU_STA_Version = @currentVersion
        AND
            SU_STA_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LBL_Subject_Label instead of INSERT trigger on SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_LBL_Subject_Label', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_LBL_Subject_Label];
GO
CREATE TRIGGER [dbo].[it_SU_LBL_Subject_Label] ON [dbo].[SU_LBL_Subject_Label]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_LBL_Subject_Label TABLE (
        SU_LBL_SU_ID int not null,
        Metadata_SU_LBL int not null,
        SU_LBL_ChangedAt datetime2 not null,
        SU_LBL_Positor tinyint not null,
        SU_LBL_PositedAt datetime2 not null,
        SU_LBL_Reliability decimal(5,2) not null,
        SU_LBL_Assertion char(1) not null,
        SU_LBL_Subject_Label nvarchar(42) not null,
        SU_LBL_Version bigint not null,
        SU_LBL_StatementType char(1) not null,
        primary key(
            SU_LBL_Version,
            SU_LBL_Positor,
            SU_LBL_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_LBL_SU_ID,
            i.SU_LBL_ChangedAt,
            i.SU_LBL_Positor,
            i.SU_LBL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_LBL_Subject_Label_Posit] p
            JOIN
                [dbo].[SU_LBL_Subject_Label_Annex] a
            ON
                a.SU_LBL_ID = p.SU_LBL_ID
            WHERE
                p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
            AND
                p.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
            AND
                p.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
            AND
                a.SU_LBL_Positor = i.SU_LBL_Positor
            AND
                a.SU_LBL_PositedAt = i.SU_LBL_PositedAt
            AND
                a.SU_LBL_Reliability <> i.SU_LBL_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_LBL_Subject_Label for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_LBL_Subject_Label
    SELECT
        i.SU_LBL_SU_ID,
        i.Metadata_SU_LBL,
        i.SU_LBL_ChangedAt,
        i.SU_LBL_Positor,
        i.SU_LBL_PositedAt,
        i.SU_LBL_Reliability,
        case
            when i.SU_LBL_Reliability > 0 then '+'
            when i.SU_LBL_Reliability = 0 then '?'
            when i.SU_LBL_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_LBL_Subject_Label,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_LBL_Positor,
                i.SU_LBL_SU_ID
            ORDER BY
                i.SU_LBL_ChangedAt ASC,
                i.SU_LBL_PositedAt ASC,
                i.SU_LBL_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_LBL_Subject_Label_Posit] p
        JOIN
            [dbo].[SU_LBL_Subject_Label_Annex] a
        ON
            a.SU_LBL_ID = p.SU_LBL_ID
        WHERE
            p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
        AND
            p.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
        AND
            p.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
        AND
            a.SU_LBL_Positor = i.SU_LBL_Positor
        AND
            a.SU_LBL_PositedAt = i.SU_LBL_PositedAt
    );
    SELECT
        @maxVersion = max(SU_LBL_Version),
        @currentVersion = 0
    FROM
        @SU_LBL_Subject_Label;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_LBL_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_LBL_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_LBL_Positor, v.SU_LBL_ChangedAt, v.SU_LBL_PositedAt, v.SU_LBL_Assertion) t
                        WHERE
                            t.SU_LBL_SU_ID = v.SU_LBL_SU_ID
                        AND
                            t.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
                        AND
                            t.SU_LBL_Reliability = v.SU_LBL_Reliability
                        AND
                            t.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_LBL_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_LBL_Subject_Label
                        WHERE
                            v.SU_LBL_Subject_Label =
                                dbo.preSU_LBL_Subject_Label (
                                    v.SU_LBL_SU_ID,
                                    v.SU_LBL_Positor,
                                    v.SU_LBL_ChangedAt,
                                    v.SU_LBL_PositedAt,
                                    v.SU_LBL_Assertion
                                )
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            v.SU_LBL_Subject_Label
                        WHERE
                            v.SU_LBL_Subject_Label =
                                dbo.folSU_LBL_Subject_Label (
                                    v.SU_LBL_SU_ID,
                                    v.SU_LBL_Positor,
                                    v.SU_LBL_ChangedAt,
                                    v.SU_LBL_PositedAt,
                                    v.SU_LBL_Assertion
                                )
                    )
                    THEN 'F' -- the following version restates this one, so it is retracted
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_LBL_Subject_Label v
        LEFT JOIN
            [dbo].[SU_LBL_Subject_Label_Posit] p
        ON
            p.SU_LBL_SU_ID = v.SU_LBL_SU_ID
        AND
            p.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
        AND
            p.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label
        WHERE
            v.SU_LBL_Version = @currentVersion;
        INSERT INTO [dbo].[SU_LBL_Subject_Label_Posit] (
            SU_LBL_SU_ID,
            SU_LBL_ChangedAt,
            SU_LBL_Subject_Label
        )
        SELECT
            v.SU_LBL_SU_ID,
            v.SU_LBL_ChangedAt,
            v.SU_LBL_Subject_Label
        FROM
            @SU_LBL_Subject_Label v
        WHERE
            v.SU_LBL_Version = @currentVersion
        AND
            v.SU_LBL_StatementType in ('N','F')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_LBL_Subject_Label w
            WHERE
                w.SU_LBL_Version = v.SU_LBL_Version
            AND
                w.SU_LBL_Positor < v.SU_LBL_Positor
            AND
                w.SU_LBL_SU_ID = v.SU_LBL_SU_ID
            AND
                w.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
            AND
                w.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label
            AND
                w.SU_LBL_StatementType in ('N','F')
        );
        -- retract the following versions that the new ones make restatements
        INSERT INTO [dbo].[SU_LBL_Subject_Label_Annex] (
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_Positor,
            SU_LBL_PositedAt,
            SU_LBL_Reliability
        )
        SELECT
            v.Metadata_SU_LBL,
            fol.SU_LBL_ID,
            v.SU_LBL_Positor,
            v.SU_LBL_PositedAt,
            0
        FROM
            @SU_LBL_Subject_Label v
        CROSS APPLY (
            SELECT TOP 1
                f.SU_LBL_ID,
                f.SU_LBL_Subject_Label
            FROM
                [dbo].[fSU_LBL_Subject_Label](
                    v.SU_LBL_Positor,
                    v.SU_LBL_ChangedAt,
                    v.SU_LBL_PositedAt
                ) f
            WHERE
                f.SU_LBL_SU_ID = v.SU_LBL_SU_ID
            AND
                f.SU_LBL_ChangedAt > v.SU_LBL_ChangedAt
            AND
                f.SU_LBL_Assertion = v.SU_LBL_Assertion
            ORDER BY
                f.SU_LBL_ChangedAt ASC,
                f.SU_LBL_PositedAt DESC
        ) fol
        WHERE
            v.SU_LBL_Version = @currentVersion
        AND
            v.SU_LBL_StatementType = 'F'
        AND
            fol.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label;
        INSERT INTO [dbo].[SU_LBL_Subject_Label_Annex] (
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_Positor,
            SU_LBL_PositedAt,
            SU_LBL_Reliability
        )
        SELECT
            v.Metadata_SU_LBL,
            p.SU_LBL_ID,
            v.SU_LBL_Positor,
            v.SU_LBL_PositedAt,
            v.SU_LBL_Reliability
        FROM
            @SU_LBL_Subject_Label v
        JOIN
            [dbo].[SU_LBL_Subject_Label_Posit] p
        ON
            p.SU_LBL_SU_ID = v.SU_LBL_SU_ID
        AND
            p.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
        AND
            p.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label
        WHERE
            v.SU_LBL_Version = @currentVersion
        AND
            SU_LBL_StatementType in ('S','N','D','F');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TAG_Subject_Tag instead of INSERT trigger on SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TAG_Subject_Tag', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TAG_Subject_Tag];
GO
CREATE TRIGGER [dbo].[it_SU_TAG_Subject_Tag] ON [dbo].[SU_TAG_Subject_Tag]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_TAG_Subject_Tag TABLE (
        SU_TAG_SU_ID int not null,
        Metadata_SU_TAG int not null,
        SU_TAG_ChangedAt datetime2 not null,
        SU_TAG_Positor tinyint not null,
        SU_TAG_PositedAt datetime2 not null,
        SU_TAG_Reliability decimal(5,2) not null,
        SU_TAG_Assertion char(1) not null,
        SU_TAG_Subject_Tag nvarchar(42) not null,
        SU_TAG_Version bigint not null,
        SU_TAG_StatementType char(1) not null,
        primary key(
            SU_TAG_Version,
            SU_TAG_Positor,
            SU_TAG_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TAG_SU_ID,
            i.SU_TAG_ChangedAt,
            i.SU_TAG_Positor,
            i.SU_TAG_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TAG_Subject_Tag_Posit] p
            JOIN
                [dbo].[SU_TAG_Subject_Tag_Annex] a
            ON
                a.SU_TAG_ID = p.SU_TAG_ID
            WHERE
                p.SU_TAG_SU_ID = i.SU_TAG_SU_ID
            AND
                p.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
            AND
                p.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
            AND
                a.SU_TAG_Positor = i.SU_TAG_Positor
            AND
                a.SU_TAG_PositedAt = i.SU_TAG_PositedAt
            AND
                a.SU_TAG_Reliability <> i.SU_TAG_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TAG_Subject_Tag for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_TAG_Subject_Tag
    SELECT
        i.SU_TAG_SU_ID,
        i.Metadata_SU_TAG,
        i.SU_TAG_ChangedAt,
        i.SU_TAG_Positor,
        i.SU_TAG_PositedAt,
        i.SU_TAG_Reliability,
        case
            when i.SU_TAG_Reliability > 0 then '+'
            when i.SU_TAG_Reliability = 0 then '?'
            when i.SU_TAG_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_TAG_Subject_Tag,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_TAG_Positor,
                i.SU_TAG_SU_ID
            ORDER BY
                i.SU_TAG_ChangedAt ASC,
                i.SU_TAG_PositedAt ASC,
                i.SU_TAG_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        JOIN
            [dbo].[SU_TAG_Subject_Tag_Annex] a
        ON
            a.SU_TAG_ID = p.SU_TAG_ID
        WHERE
            p.SU_TAG_SU_ID = i.SU_TAG_SU_ID
        AND
            p.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
        AND
            p.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
        AND
            a.SU_TAG_Positor = i.SU_TAG_Positor
        AND
            a.SU_TAG_PositedAt = i.SU_TAG_PositedAt
    );
    SELECT
        @maxVersion = max(SU_TAG_Version),
        @currentVersion = 0
    FROM
        @SU_TAG_Subject_Tag;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_TAG_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_TAG_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_TAG_Positor, v.SU_TAG_ChangedAt, v.SU_TAG_PositedAt, v.SU_TAG_Assertion) t
                        WHERE
                            t.SU_TAG_SU_ID = v.SU_TAG_SU_ID
                        AND
                            t.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
                        AND
                            t.SU_TAG_Reliability = v.SU_TAG_Reliability
                        AND
                            t.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_TAG_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_TAG_Subject_Tag
                        WHERE
                            v.SU_TAG_Subject_Tag =
                                dbo.preSU_TAG_Subject_Tag (
                                    v.SU_TAG_SU_ID,
                                    v.SU_TAG_Positor,
                                    v.SU_TAG_ChangedAt,
                                    v.SU_TAG_PositedAt,
                                    v.SU_TAG_Assertion
                                )
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            v.SU_TAG_Subject_Tag
                        WHERE
                            v.SU_TAG_Subject_Tag =
                                dbo.folSU_TAG_Subject_Tag (
                                    v.SU_TAG_SU_ID,
                                    v.SU_TAG_Positor,
                                    v.SU_TAG_ChangedAt,
                                    v.SU_TAG_PositedAt,
                                    v.SU_TAG_Assertion
                                )
                    )
                    THEN 'F' -- the following version restates this one, so it is retracted
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_TAG_Subject_Tag v
        LEFT JOIN
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        ON
            p.SU_TAG_SU_ID = v.SU_TAG_SU_ID
        AND
            p.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
        AND
            p.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag
        WHERE
            v.SU_TAG_Version = @currentVersion;
        INSERT INTO [dbo].[SU_TAG_Subject_Tag_Posit] (
            SU_TAG_SU_ID,
            SU_TAG_ChangedAt,
            SU_TAG_Subject_Tag
        )
        SELECT
            v.SU_TAG_SU_ID,
            v.SU_TAG_ChangedAt,
            v.SU_TAG_Subject_Tag
        FROM
            @SU_TAG_Subject_Tag v
        WHERE
            v.SU_TAG_Version = @currentVersion
        AND
            v.SU_TAG_StatementType in ('N','F')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_TAG_Subject_Tag w
            WHERE
                w.SU_TAG_Version = v.SU_TAG_Version
            AND
                w.SU_TAG_Positor < v.SU_TAG_Positor
            AND
                w.SU_TAG_SU_ID = v.SU_TAG_SU_ID
            AND
                w.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
            AND
                w.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag
            AND
                w.SU_TAG_StatementType in ('N','F')
        );
        -- retract the following versions that the new ones make restatements
        INSERT INTO [dbo].[SU_TAG_Subject_Tag_Annex] (
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_Positor,
            SU_TAG_PositedAt,
            SU_TAG_Reliability
        )
        SELECT
            v.Metadata_SU_TAG,
            fol.SU_TAG_ID,
            v.SU_TAG_Positor,
            v.SU_TAG_PositedAt,
            0
        FROM
            @SU_TAG_Subject_Tag v
        CROSS APPLY (
            SELECT TOP 1
                f.SU_TAG_ID,
                f.SU_TAG_Subject_Tag
            FROM
                [dbo].[fSU_TAG_Subject_Tag](
                    v.SU_TAG_Positor,
                    v.SU_TAG_ChangedAt,
                    v.SU_TAG_PositedAt
                ) f
            WHERE
                f.SU_TAG_SU_ID = v.SU_TAG_SU_ID
            AND
                f.SU_TAG_ChangedAt > v.SU_TAG_ChangedAt
            AND
                f.SU_TAG_Assertion = v.SU_TAG_Assertion
            ORDER BY
                f.SU_TAG_ChangedAt ASC,
                f.SU_TAG_PositedAt DESC
        ) fol
        WHERE
            v.SU_TAG_Version = @currentVersion
        AND
            v.SU_TAG_StatementType = 'F'
        AND
            fol.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag;
        INSERT INTO [dbo].[SU_TAG_Subject_Tag_Annex] (
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_Positor,
            SU_TAG_PositedAt,
            SU_TAG_Reliability
        )
        SELECT
            v.Metadata_SU_TAG,
            p.SU_TAG_ID,
            v.SU_TAG_Positor,
            v.SU_TAG_PositedAt,
            v.SU_TAG_Reliability
        FROM
            @SU_TAG_Subject_Tag v
        JOIN
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        ON
            p.SU_TAG_SU_ID = v.SU_TAG_SU_ID
        AND
            p.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
        AND
            p.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag
        WHERE
            v.SU_TAG_Version = @currentVersion
        AND
            SU_TAG_StatementType in ('S','N','D','F');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LVL_Subject_Level instead of INSERT trigger on SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_LVL_Subject_Level', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_LVL_Subject_Level];
GO
CREATE TRIGGER [dbo].[it_SU_LVL_Subject_Level] ON [dbo].[SU_LVL_Subject_Level]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_LVL_Subject_Level TABLE (
        SU_LVL_SU_ID int not null,
        Metadata_SU_LVL int not null,
        SU_LVL_ChangedAt datetime2 not null,
        SU_LVL_Positor tinyint not null,
        SU_LVL_PositedAt datetime2 not null,
        SU_LVL_Reliability decimal(5,2) not null,
        SU_LVL_Assertion char(1) not null,
        SU_LVL_GRD_ID tinyint not null,
        SU_LVL_Version bigint not null,
        SU_LVL_StatementType char(1) not null,
        primary key(
            SU_LVL_Version,
            SU_LVL_Positor,
            SU_LVL_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_LVL_SU_ID,
            i.SU_LVL_ChangedAt,
            i.SU_LVL_Positor,
            i.SU_LVL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_LVL_Subject_Level_Posit] p
            JOIN
                [dbo].[SU_LVL_Subject_Level_Annex] a
            ON
                a.SU_LVL_ID = p.SU_LVL_ID
            WHERE
                p.SU_LVL_SU_ID = i.SU_LVL_SU_ID
            AND
                p.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
            AND
                p.SU_LVL_GRD_ID = i.SU_LVL_GRD_ID
            AND
                a.SU_LVL_Positor = i.SU_LVL_Positor
            AND
                a.SU_LVL_PositedAt = i.SU_LVL_PositedAt
            AND
                a.SU_LVL_Reliability <> i.SU_LVL_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_LVL_Subject_Level for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_LVL_Subject_Level
    SELECT
        i.SU_LVL_SU_ID,
        i.Metadata_SU_LVL,
        i.SU_LVL_ChangedAt,
        i.SU_LVL_Positor,
        i.SU_LVL_PositedAt,
        i.SU_LVL_Reliability,
        case
            when i.SU_LVL_Reliability > 0 then '+'
            when i.SU_LVL_Reliability = 0 then '?'
            when i.SU_LVL_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_LVL_GRD_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_LVL_Positor,
                i.SU_LVL_SU_ID
            ORDER BY
                i.SU_LVL_ChangedAt ASC,
                i.SU_LVL_PositedAt ASC,
                i.SU_LVL_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_LVL_Subject_Level_Posit] p
        JOIN
            [dbo].[SU_LVL_Subject_Level_Annex] a
        ON
            a.SU_LVL_ID = p.SU_LVL_ID
        WHERE
            p.SU_LVL_SU_ID = i.SU_LVL_SU_ID
        AND
            p.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
        AND
            p.SU_LVL_GRD_ID = i.SU_LVL_GRD_ID
        AND
            a.SU_LVL_Positor = i.SU_LVL_Positor
        AND
            a.SU_LVL_PositedAt = i.SU_LVL_PositedAt
    );
    SELECT
        @maxVersion = max(SU_LVL_Version),
        @currentVersion = 0
    FROM
        @SU_LVL_Subject_Level;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_LVL_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_LVL_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_LVL_Positor, v.SU_LVL_ChangedAt, v.SU_LVL_PositedAt, v.SU_LVL_Assertion) t
                        WHERE
                            t.SU_LVL_SU_ID = v.SU_LVL_SU_ID
                        AND
                            t.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
                        AND
                            t.SU_LVL_Reliability = v.SU_LVL_Reliability
                        AND
                            t.SU_LVL_GRD_ID = v.SU_LVL_GRD_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_LVL_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_LVL_GRD_ID
                        WHERE
                            v.SU_LVL_GRD_ID =
                                dbo.preSU_LVL_Subject_Level (
                                    v.SU_LVL_SU_ID,
                                    v.SU_LVL_Positor,
                                    v.SU_LVL_ChangedAt,
                                    v.SU_LVL_PositedAt,
                                    v.SU_LVL_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_LVL_GRD_ID
                        WHERE
                            v.SU_LVL_GRD_ID =
                                dbo.folSU_LVL_Subject_Level (
                                    v.SU_LVL_SU_ID,
                                    v.SU_LVL_Positor,
                                    v.SU_LVL_ChangedAt,
                                    v.SU_LVL_PositedAt,
                                    v.SU_LVL_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_LVL_Subject_Level v
        LEFT JOIN
            [dbo].[SU_LVL_Subject_Level_Posit] p
        ON
            p.SU_LVL_SU_ID = v.SU_LVL_SU_ID
        AND
            p.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
        AND
            p.SU_LVL_GRD_ID = v.SU_LVL_GRD_ID
        WHERE
            v.SU_LVL_Version = @currentVersion;
        INSERT INTO [dbo].[SU_LVL_Subject_Level_Posit] (
            SU_LVL_SU_ID,
            SU_LVL_ChangedAt,
            SU_LVL_GRD_ID
        )
        SELECT
            v.SU_LVL_SU_ID,
            v.SU_LVL_ChangedAt,
            v.SU_LVL_GRD_ID
        FROM
            @SU_LVL_Subject_Level v
        WHERE
            v.SU_LVL_Version = @currentVersion
        AND
            v.SU_LVL_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_LVL_Subject_Level w
            WHERE
                w.SU_LVL_Version = v.SU_LVL_Version
            AND
                w.SU_LVL_Positor < v.SU_LVL_Positor
            AND
                w.SU_LVL_SU_ID = v.SU_LVL_SU_ID
            AND
                w.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
            AND
                w.SU_LVL_GRD_ID = v.SU_LVL_GRD_ID
            AND
                w.SU_LVL_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_LVL_Subject_Level_Annex] (
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_Positor,
            SU_LVL_PositedAt,
            SU_LVL_Reliability
        )
        SELECT
            v.Metadata_SU_LVL,
            p.SU_LVL_ID,
            v.SU_LVL_Positor,
            v.SU_LVL_PositedAt,
            v.SU_LVL_Reliability
        FROM
            @SU_LVL_Subject_Level v
        JOIN
            [dbo].[SU_LVL_Subject_Level_Posit] p
        ON
            p.SU_LVL_SU_ID = v.SU_LVL_SU_ID
        AND
            p.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
        AND
            p.SU_LVL_GRD_ID = v.SU_LVL_GRD_ID
        WHERE
            v.SU_LVL_Version = @currentVersion
        AND
            SU_LVL_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TXT_Subject_Text instead of INSERT trigger on SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TXT_Subject_Text', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TXT_Subject_Text];
GO
CREATE TRIGGER [dbo].[it_SU_TXT_Subject_Text] ON [dbo].[SU_TXT_Subject_Text]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_TXT_Subject_Text TABLE (
        SU_TXT_SU_ID int not null,
        Metadata_SU_TXT int not null,
        SU_TXT_ChangedAt datetime2 not null,
        SU_TXT_Positor tinyint not null,
        SU_TXT_PositedAt datetime2 not null,
        SU_TXT_Reliability decimal(5,2) not null,
        SU_TXT_Assertion char(1) not null,
        SU_TXT_Subject_Text nvarchar(max) not null,
        SU_TXT_Checksum varbinary(16) not null,
        SU_TXT_Version bigint not null,
        SU_TXT_StatementType char(1) not null,
        primary key(
            SU_TXT_Version,
            SU_TXT_Positor,
            SU_TXT_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TXT_SU_ID,
            i.SU_TXT_ChangedAt,
            i.SU_TXT_Positor,
            i.SU_TXT_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TXT_Subject_Text_Posit] p
            JOIN
                [dbo].[SU_TXT_Subject_Text_Annex] a
            ON
                a.SU_TXT_ID = p.SU_TXT_ID
            WHERE
                p.SU_TXT_SU_ID = i.SU_TXT_SU_ID
            AND
                p.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
            AND
                p.SU_TXT_Checksum = dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
            AND
                a.SU_TXT_Positor = i.SU_TXT_Positor
            AND
                a.SU_TXT_PositedAt = i.SU_TXT_PositedAt
            AND
                a.SU_TXT_Reliability <> i.SU_TXT_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TXT_Subject_Text for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_TXT_Subject_Text
    SELECT
        i.SU_TXT_SU_ID,
        i.Metadata_SU_TXT,
        i.SU_TXT_ChangedAt,
        i.SU_TXT_Positor,
        i.SU_TXT_PositedAt,
        i.SU_TXT_Reliability,
        case
            when i.SU_TXT_Reliability > 0 then '+'
            when i.SU_TXT_Reliability = 0 then '?'
            when i.SU_TXT_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_TXT_Subject_Text,
        dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max))),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_TXT_Positor,
                i.SU_TXT_SU_ID
            ORDER BY
                i.SU_TXT_ChangedAt ASC,
                i.SU_TXT_PositedAt ASC,
                i.SU_TXT_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_TXT_Subject_Text_Posit] p
        JOIN
            [dbo].[SU_TXT_Subject_Text_Annex] a
        ON
            a.SU_TXT_ID = p.SU_TXT_ID
        WHERE
            p.SU_TXT_SU_ID = i.SU_TXT_SU_ID
        AND
            p.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
        AND
            p.SU_TXT_Checksum = dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
        AND
            a.SU_TXT_Positor = i.SU_TXT_Positor
        AND
            a.SU_TXT_PositedAt = i.SU_TXT_PositedAt
    );
    SELECT
        @maxVersion = max(SU_TXT_Version),
        @currentVersion = 0
    FROM
        @SU_TXT_Subject_Text;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_TXT_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_TXT_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_TXT_Positor, v.SU_TXT_ChangedAt, v.SU_TXT_PositedAt, v.SU_TXT_Assertion) t
                        WHERE
                            t.SU_TXT_SU_ID = v.SU_TXT_SU_ID
                        AND
                            t.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
                        AND
                            t.SU_TXT_Reliability = v.SU_TXT_Reliability
                        AND
                            t.SU_TXT_Checksum = v.SU_TXT_Checksum
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_TXT_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_TXT_Checksum
                        WHERE
                            v.SU_TXT_Checksum =
                                dbo.preSU_TXT_Subject_Text (
                                    v.SU_TXT_SU_ID,
                                    v.SU_TXT_Positor,
                                    v.SU_TXT_ChangedAt,
                                    v.SU_TXT_PositedAt,
                                    v.SU_TXT_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_TXT_Checksum
                        WHERE
                            v.SU_TXT_Checksum =
                                dbo.folSU_TXT_Subject_Text (
                                    v.SU_TXT_SU_ID,
                                    v.SU_TXT_Positor,
                                    v.SU_TXT_ChangedAt,
                                    v.SU_TXT_PositedAt,
                                    v.SU_TXT_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_TXT_Subject_Text v
        LEFT JOIN
            [dbo].[SU_TXT_Subject_Text_Posit] p
        ON
            p.SU_TXT_SU_ID = v.SU_TXT_SU_ID
        AND
            p.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
        AND
            p.SU_TXT_Checksum = v.SU_TXT_Checksum
        WHERE
            v.SU_TXT_Version = @currentVersion;
        INSERT INTO [dbo].[SU_TXT_Subject_Text_Posit] (
            SU_TXT_SU_ID,
            SU_TXT_ChangedAt,
            SU_TXT_Subject_Text
        )
        SELECT
            v.SU_TXT_SU_ID,
            v.SU_TXT_ChangedAt,
            v.SU_TXT_Subject_Text
        FROM
            @SU_TXT_Subject_Text v
        WHERE
            v.SU_TXT_Version = @currentVersion
        AND
            v.SU_TXT_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_TXT_Subject_Text w
            WHERE
                w.SU_TXT_Version = v.SU_TXT_Version
            AND
                w.SU_TXT_Positor < v.SU_TXT_Positor
            AND
                w.SU_TXT_SU_ID = v.SU_TXT_SU_ID
            AND
                w.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
            AND
                w.SU_TXT_Checksum = v.SU_TXT_Checksum
            AND
                w.SU_TXT_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_TXT_Subject_Text_Annex] (
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_Positor,
            SU_TXT_PositedAt,
            SU_TXT_Reliability
        )
        SELECT
            v.Metadata_SU_TXT,
            p.SU_TXT_ID,
            v.SU_TXT_Positor,
            v.SU_TXT_PositedAt,
            v.SU_TXT_Reliability
        FROM
            @SU_TXT_Subject_Text v
        JOIN
            [dbo].[SU_TXT_Subject_Text_Posit] p
        ON
            p.SU_TXT_SU_ID = v.SU_TXT_SU_ID
        AND
            p.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
        AND
            p.SU_TXT_Checksum = v.SU_TXT_Checksum
        WHERE
            v.SU_TXT_Version = @currentVersion
        AND
            SU_TXT_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ASR_Subject_Assessment instead of INSERT trigger on SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_ASR_Subject_Assessment', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_ASR_Subject_Assessment];
GO
CREATE TRIGGER [dbo].[it_SU_ASR_Subject_Assessment] ON [dbo].[SU_ASR_Subject_Assessment]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_ASR_Subject_Assessment TABLE (
        SU_ASR_SU_ID int not null,
        Metadata_SU_ASR int not null,
        SU_ASR_ChangedAt datetime2 not null,
        SU_ASR_Positor tinyint not null,
        SU_ASR_PositedAt datetime2 not null,
        SU_ASR_Reliability decimal(5,2) not null,
        SU_ASR_Assertion char(1) not null,
        SU_ASR_Subject_Assessment nvarchar(42) not null,
        SU_ASR_Version bigint not null,
        SU_ASR_StatementType char(1) not null,
        primary key(
            SU_ASR_Version,
            SU_ASR_Positor,
            SU_ASR_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ASR_SU_ID,
            i.SU_ASR_ChangedAt,
            i.SU_ASR_Positor,
            i.SU_ASR_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_ASR_Subject_Assessment_Posit] p
            JOIN
                [dbo].[SU_ASR_Subject_Assessment_Annex] a
            ON
                a.SU_ASR_ID = p.SU_ASR_ID
            WHERE
                p.SU_ASR_SU_ID = i.SU_ASR_SU_ID
            AND
                p.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
            AND
                p.SU_ASR_Subject_Assessment = i.SU_ASR_Subject_Assessment
            AND
                a.SU_ASR_Positor = i.SU_ASR_Positor
            AND
                a.SU_ASR_PositedAt = i.SU_ASR_PositedAt
            AND
                a.SU_ASR_Reliability <> i.SU_ASR_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_ASR_Subject_Assessment for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_ASR_Subject_Assessment
    SELECT
        i.SU_ASR_SU_ID,
        i.Metadata_SU_ASR,
        i.SU_ASR_ChangedAt,
        i.SU_ASR_Positor,
        i.SU_ASR_PositedAt,
        i.SU_ASR_Reliability,
        case
            when i.SU_ASR_Reliability > 0 then '+'
            when i.SU_ASR_Reliability = 0 then '?'
            when i.SU_ASR_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_ASR_Subject_Assessment,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_ASR_Positor,
                i.SU_ASR_SU_ID
            ORDER BY
                i.SU_ASR_ChangedAt ASC,
                i.SU_ASR_PositedAt ASC,
                i.SU_ASR_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        JOIN
            [dbo].[SU_ASR_Subject_Assessment_Annex] a
        ON
            a.SU_ASR_ID = p.SU_ASR_ID
        WHERE
            p.SU_ASR_SU_ID = i.SU_ASR_SU_ID
        AND
            p.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
        AND
            p.SU_ASR_Subject_Assessment = i.SU_ASR_Subject_Assessment
        AND
            a.SU_ASR_Positor = i.SU_ASR_Positor
        AND
            a.SU_ASR_PositedAt = i.SU_ASR_PositedAt
    );
    SELECT
        @maxVersion = max(SU_ASR_Version),
        @currentVersion = 0
    FROM
        @SU_ASR_Subject_Assessment;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_ASR_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_ASR_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_ASR_Positor, v.SU_ASR_ChangedAt, v.SU_ASR_PositedAt, v.SU_ASR_Assertion) t
                        WHERE
                            t.SU_ASR_SU_ID = v.SU_ASR_SU_ID
                        AND
                            t.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
                        AND
                            t.SU_ASR_Reliability = v.SU_ASR_Reliability
                        AND
                            t.SU_ASR_Subject_Assessment = v.SU_ASR_Subject_Assessment
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_ASR_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_ASR_Subject_Assessment
                        WHERE
                            v.SU_ASR_Subject_Assessment =
                                dbo.preSU_ASR_Subject_Assessment (
                                    v.SU_ASR_SU_ID,
                                    v.SU_ASR_Positor,
                                    v.SU_ASR_ChangedAt,
                                    v.SU_ASR_PositedAt,
                                    v.SU_ASR_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_ASR_Subject_Assessment
                        WHERE
                            v.SU_ASR_Subject_Assessment =
                                dbo.folSU_ASR_Subject_Assessment (
                                    v.SU_ASR_SU_ID,
                                    v.SU_ASR_Positor,
                                    v.SU_ASR_ChangedAt,
                                    v.SU_ASR_PositedAt,
                                    v.SU_ASR_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_ASR_Subject_Assessment v
        LEFT JOIN
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        ON
            p.SU_ASR_SU_ID = v.SU_ASR_SU_ID
        AND
            p.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
        AND
            p.SU_ASR_Subject_Assessment = v.SU_ASR_Subject_Assessment
        WHERE
            v.SU_ASR_Version = @currentVersion;
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment_Posit] (
            SU_ASR_SU_ID,
            SU_ASR_ChangedAt,
            SU_ASR_Subject_Assessment
        )
        SELECT
            v.SU_ASR_SU_ID,
            v.SU_ASR_ChangedAt,
            v.SU_ASR_Subject_Assessment
        FROM
            @SU_ASR_Subject_Assessment v
        WHERE
            v.SU_ASR_Version = @currentVersion
        AND
            v.SU_ASR_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_ASR_Subject_Assessment w
            WHERE
                w.SU_ASR_Version = v.SU_ASR_Version
            AND
                w.SU_ASR_Positor < v.SU_ASR_Positor
            AND
                w.SU_ASR_SU_ID = v.SU_ASR_SU_ID
            AND
                w.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
            AND
                w.SU_ASR_Subject_Assessment = v.SU_ASR_Subject_Assessment
            AND
                w.SU_ASR_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment_Annex] (
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_Positor,
            SU_ASR_PositedAt,
            SU_ASR_Reliability
        )
        SELECT
            v.Metadata_SU_ASR,
            p.SU_ASR_ID,
            v.SU_ASR_Positor,
            v.SU_ASR_PositedAt,
            v.SU_ASR_Reliability
        FROM
            @SU_ASR_Subject_Assessment v
        JOIN
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        ON
            p.SU_ASR_SU_ID = v.SU_ASR_SU_ID
        AND
            p.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
        AND
            p.SU_ASR_Subject_Assessment = v.SU_ASR_Subject_Assessment
        WHERE
            v.SU_ASR_Version = @currentVersion
        AND
            SU_ASR_StatementType in ('S','N','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ERS_Subject_Erasable instead of INSERT trigger on SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_ERS_Subject_Erasable', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_ERS_Subject_Erasable];
GO
CREATE TRIGGER [dbo].[it_SU_ERS_Subject_Erasable] ON [dbo].[SU_ERS_Subject_Erasable]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_ERS_Subject_Erasable TABLE (
        SU_ERS_SU_ID int not null,
        Metadata_SU_ERS int not null,
        SU_ERS_ChangedAt datetime2 not null,
        SU_ERS_Positor tinyint not null,
        SU_ERS_PositedAt datetime2 not null,
        SU_ERS_Reliability decimal(5,2) not null,
        SU_ERS_Assertion char(1) not null,
        SU_ERS_Subject_Erasable nvarchar(42) not null,
        SU_ERS_Version bigint not null,
        SU_ERS_StatementType char(1) not null,
        primary key(
            SU_ERS_Version,
            SU_ERS_Positor,
            SU_ERS_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ERS_SU_ID,
            i.SU_ERS_ChangedAt,
            i.SU_ERS_Positor,
            i.SU_ERS_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_ERS_Subject_Erasable_Posit] p
            JOIN
                [dbo].[SU_ERS_Subject_Erasable_Annex] a
            ON
                a.SU_ERS_ID = p.SU_ERS_ID
            WHERE
                p.SU_ERS_SU_ID = i.SU_ERS_SU_ID
            AND
                p.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
            AND
                p.SU_ERS_Subject_Erasable = i.SU_ERS_Subject_Erasable
            AND
                a.SU_ERS_Positor = i.SU_ERS_Positor
            AND
                a.SU_ERS_PositedAt = i.SU_ERS_PositedAt
            AND
                a.SU_ERS_Reliability <> i.SU_ERS_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_ERS_Subject_Erasable for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_ERS_Subject_Erasable
    SELECT
        i.SU_ERS_SU_ID,
        i.Metadata_SU_ERS,
        i.SU_ERS_ChangedAt,
        i.SU_ERS_Positor,
        i.SU_ERS_PositedAt,
        i.SU_ERS_Reliability,
        case
            when i.SU_ERS_Reliability > 0 then '+'
            when i.SU_ERS_Reliability = 0 then '?'
            when i.SU_ERS_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_ERS_Subject_Erasable,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_ERS_Positor,
                i.SU_ERS_SU_ID
            ORDER BY
                i.SU_ERS_ChangedAt ASC,
                i.SU_ERS_PositedAt ASC,
                i.SU_ERS_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        JOIN
            [dbo].[SU_ERS_Subject_Erasable_Annex] a
        ON
            a.SU_ERS_ID = p.SU_ERS_ID
        WHERE
            p.SU_ERS_SU_ID = i.SU_ERS_SU_ID
        AND
            p.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
        AND
            p.SU_ERS_Subject_Erasable = i.SU_ERS_Subject_Erasable
        AND
            a.SU_ERS_Positor = i.SU_ERS_Positor
        AND
            a.SU_ERS_PositedAt = i.SU_ERS_PositedAt
    );
    SELECT
        @maxVersion = max(SU_ERS_Version),
        @currentVersion = 0
    FROM
        @SU_ERS_Subject_Erasable;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_ERS_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_ERS_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_ERS_Positor, v.SU_ERS_ChangedAt, v.SU_ERS_PositedAt, v.SU_ERS_Assertion) t
                        WHERE
                            t.SU_ERS_SU_ID = v.SU_ERS_SU_ID
                        AND
                            t.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
                        AND
                            t.SU_ERS_Reliability = v.SU_ERS_Reliability
                        AND
                            t.SU_ERS_Subject_Erasable = v.SU_ERS_Subject_Erasable
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_ERS_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_ERS_Subject_Erasable
                        WHERE
                            v.SU_ERS_Subject_Erasable =
                                dbo.preSU_ERS_Subject_Erasable (
                                    v.SU_ERS_SU_ID,
                                    v.SU_ERS_Positor,
                                    v.SU_ERS_ChangedAt,
                                    v.SU_ERS_PositedAt,
                                    v.SU_ERS_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_ERS_Subject_Erasable
                        WHERE
                            v.SU_ERS_Subject_Erasable =
                                dbo.folSU_ERS_Subject_Erasable (
                                    v.SU_ERS_SU_ID,
                                    v.SU_ERS_Positor,
                                    v.SU_ERS_ChangedAt,
                                    v.SU_ERS_PositedAt,
                                    v.SU_ERS_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_ERS_Subject_Erasable v
        LEFT JOIN
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        ON
            p.SU_ERS_SU_ID = v.SU_ERS_SU_ID
        AND
            p.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
        AND
            p.SU_ERS_Subject_Erasable = v.SU_ERS_Subject_Erasable
        WHERE
            v.SU_ERS_Version = @currentVersion;
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable_Posit] (
            SU_ERS_SU_ID,
            SU_ERS_ChangedAt,
            SU_ERS_Subject_Erasable
        )
        SELECT
            v.SU_ERS_SU_ID,
            v.SU_ERS_ChangedAt,
            v.SU_ERS_Subject_Erasable
        FROM
            @SU_ERS_Subject_Erasable v
        WHERE
            v.SU_ERS_Version = @currentVersion
        AND
            v.SU_ERS_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_ERS_Subject_Erasable w
            WHERE
                w.SU_ERS_Version = v.SU_ERS_Version
            AND
                w.SU_ERS_Positor < v.SU_ERS_Positor
            AND
                w.SU_ERS_SU_ID = v.SU_ERS_SU_ID
            AND
                w.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
            AND
                w.SU_ERS_Subject_Erasable = v.SU_ERS_Subject_Erasable
            AND
                w.SU_ERS_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable_Annex] (
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_Positor,
            SU_ERS_PositedAt,
            SU_ERS_Reliability
        )
        SELECT
            v.Metadata_SU_ERS,
            p.SU_ERS_ID,
            v.SU_ERS_Positor,
            v.SU_ERS_PositedAt,
            v.SU_ERS_Reliability
        FROM
            @SU_ERS_Subject_Erasable v
        JOIN
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        ON
            p.SU_ERS_SU_ID = v.SU_ERS_SU_ID
        AND
            p.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
        AND
            p.SU_ERS_Subject_Erasable = v.SU_ERS_Subject_Erasable
        WHERE
            v.SU_ERS_Version = @currentVersion
        AND
            SU_ERS_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_NAM_Object_Name instead of INSERT trigger on OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_OB_NAM_Object_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_OB_NAM_Object_Name];
GO
CREATE TRIGGER [dbo].[it_OB_NAM_Object_Name] ON [dbo].[OB_NAM_Object_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @OB_NAM_Object_Name TABLE (
        OB_NAM_OB_ID int not null,
        Metadata_OB_NAM int not null,
        OB_NAM_Positor tinyint not null,
        OB_NAM_PositedAt datetime2 not null,
        OB_NAM_Reliability decimal(5,2) not null,
        OB_NAM_Assertion char(1) not null,
        OB_NAM_Object_Name nvarchar(42) not null,
        OB_NAM_Version bigint not null,
        OB_NAM_StatementType char(1) not null,
        primary key(
            OB_NAM_Version,
            OB_NAM_Positor,
            OB_NAM_OB_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.OB_NAM_OB_ID,
            i.OB_NAM_Positor,
            i.OB_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[OB_NAM_Object_Name_Posit] p
            JOIN
                [dbo].[OB_NAM_Object_Name_Annex] a
            ON
                a.OB_NAM_ID = p.OB_NAM_ID
            WHERE
                p.OB_NAM_OB_ID = i.OB_NAM_OB_ID
            AND
                p.OB_NAM_Object_Name = i.OB_NAM_Object_Name
            AND
                a.OB_NAM_Positor = i.OB_NAM_Positor
            AND
                a.OB_NAM_PositedAt = i.OB_NAM_PositedAt
            AND
                a.OB_NAM_Reliability <> i.OB_NAM_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in OB_NAM_Object_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @OB_NAM_Object_Name
    SELECT
        i.OB_NAM_OB_ID,
        i.Metadata_OB_NAM,
        i.OB_NAM_Positor,
        i.OB_NAM_PositedAt,
        i.OB_NAM_Reliability,
        case
            when i.OB_NAM_Reliability > 0 then '+'
            when i.OB_NAM_Reliability = 0 then '?'
            when i.OB_NAM_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.OB_NAM_Object_Name,
        DENSE_RANK() OVER (
            PARTITION BY
                i.OB_NAM_Positor,
                i.OB_NAM_OB_ID
            ORDER BY
                i.OB_NAM_PositedAt ASC,
                i.OB_NAM_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[OB_NAM_Object_Name_Posit] p
        JOIN
            [dbo].[OB_NAM_Object_Name_Annex] a
        ON
            a.OB_NAM_ID = p.OB_NAM_ID
        WHERE
            p.OB_NAM_OB_ID = i.OB_NAM_OB_ID
        AND
            p.OB_NAM_Object_Name = i.OB_NAM_Object_Name
        AND
            a.OB_NAM_Positor = i.OB_NAM_Positor
        AND
            a.OB_NAM_PositedAt = i.OB_NAM_PositedAt
    );
    SELECT
        @maxVersion = max(OB_NAM_Version),
        @currentVersion = 0
    FROM
        @OB_NAM_Object_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.OB_NAM_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.OB_NAM_ID
                        FROM
                            [dbo].[tOB_Object](v.OB_NAM_Positor, DEFAULT, v.OB_NAM_PositedAt, v.OB_NAM_Assertion) t
                        WHERE
                            t.OB_NAM_OB_ID = v.OB_NAM_OB_ID
                        AND
                            t.OB_NAM_Reliability = v.OB_NAM_Reliability
                        AND
                            t.OB_NAM_Object_Name = v.OB_NAM_Object_Name
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.OB_NAM_OB_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @OB_NAM_Object_Name v
        LEFT JOIN
            [dbo].[OB_NAM_Object_Name_Posit] p
        ON
            p.OB_NAM_OB_ID = v.OB_NAM_OB_ID
        AND
            p.OB_NAM_Object_Name = v.OB_NAM_Object_Name
        WHERE
            v.OB_NAM_Version = @currentVersion;
        INSERT INTO [dbo].[OB_NAM_Object_Name_Posit] (
            OB_NAM_OB_ID,
            OB_NAM_Object_Name
        )
        SELECT
            v.OB_NAM_OB_ID,
            v.OB_NAM_Object_Name
        FROM
            @OB_NAM_Object_Name v
        WHERE
            v.OB_NAM_Version = @currentVersion
        AND
            v.OB_NAM_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @OB_NAM_Object_Name w
            WHERE
                w.OB_NAM_Version = v.OB_NAM_Version
            AND
                w.OB_NAM_Positor < v.OB_NAM_Positor
            AND
                w.OB_NAM_OB_ID = v.OB_NAM_OB_ID
            AND
                w.OB_NAM_Object_Name = v.OB_NAM_Object_Name
            AND
                w.OB_NAM_StatementType in ('N')
        );
        INSERT INTO [dbo].[OB_NAM_Object_Name_Annex] (
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_Positor,
            OB_NAM_PositedAt,
            OB_NAM_Reliability
        )
        SELECT
            v.Metadata_OB_NAM,
            p.OB_NAM_ID,
            v.OB_NAM_Positor,
            v.OB_NAM_PositedAt,
            v.OB_NAM_Reliability
        FROM
            @OB_NAM_Object_Name v
        JOIN
            [dbo].[OB_NAM_Object_Name_Posit] p
        ON
            p.OB_NAM_OB_ID = v.OB_NAM_OB_ID
        AND
            p.OB_NAM_Object_Name = v.OB_NAM_Object_Name
        WHERE
            v.OB_NAM_Version = @currentVersion
        AND
            OB_NAM_StatementType in ('S','N','D');
    END
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
-- it_lSU_Subject instead of INSERT trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lSU_Subject] ON [dbo].[lSU_Subject]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        SU_ID int not null
    );
    INSERT INTO [dbo].[SU_Subject] (
        Metadata_SU
    )
    OUTPUT
        inserted.SU_ID
    INTO
        @SU
    SELECT
        Metadata_SU
    FROM
        inserted
    WHERE
        inserted.SU_ID is null;
    DECLARE @inserted TABLE (
        SU_ID int not null,
        Metadata_SU int not null,
        SU_NAM_SU_ID int null,
        Metadata_SU_NAM int null,
        SU_NAM_Positor tinyint null,
        SU_NAM_PositedAt datetime2 null,
        SU_NAM_Reliability decimal(5,2) null,
        SU_NAM_Subject_Name nvarchar(42) null,
        SU_COD_SU_ID int null,
        Metadata_SU_COD int null,
        SU_COD_Positor tinyint null,
        SU_COD_PositedAt datetime2 null,
        SU_COD_Reliability decimal(5,2) null,
        SU_COD_Subject_Code nvarchar(42) null,
        SU_GRD_SU_ID int null,
        Metadata_SU_GRD int null,
        SU_GRD_Positor tinyint null,
        SU_GRD_PositedAt datetime2 null,
        SU_GRD_Reliability decimal(5,2) null,
        SU_GRD_GRD_Grade nvarchar(42) null,
        SU_GRD_Metadata_GRD int null,
        SU_GRD_GRD_ID tinyint null,
        SU_NOT_SU_ID int null,
        Metadata_SU_NOT int null,
        SU_NOT_Positor tinyint null,
        SU_NOT_PositedAt datetime2 null,
        SU_NOT_Reliability decimal(5,2) null,
        SU_NOT_Subject_Note nvarchar(max) null,
        SU_TTL_SU_ID int null,
        Metadata_SU_TTL int null,
        SU_TTL_ChangedAt datetime2 null,
        SU_TTL_Positor tinyint null,
        SU_TTL_PositedAt datetime2 null,
        SU_TTL_Reliability decimal(5,2) null,
        SU_TTL_Subject_Title nvarchar(42) null,
        SU_STA_SU_ID int null,
        Metadata_SU_STA int null,
        SU_STA_ChangedAt datetime2 null,
        SU_STA_Positor tinyint null,
        SU_STA_PositedAt datetime2 null,
        SU_STA_Reliability decimal(5,2) null,
        SU_STA_Subject_State nvarchar(42) null,
        SU_LBL_SU_ID int null,
        Metadata_SU_LBL int null,
        SU_LBL_ChangedAt datetime2 null,
        SU_LBL_Positor tinyint null,
        SU_LBL_PositedAt datetime2 null,
        SU_LBL_Reliability decimal(5,2) null,
        SU_LBL_Subject_Label nvarchar(42) null,
        SU_TAG_SU_ID int null,
        Metadata_SU_TAG int null,
        SU_TAG_ChangedAt datetime2 null,
        SU_TAG_Positor tinyint null,
        SU_TAG_PositedAt datetime2 null,
        SU_TAG_Reliability decimal(5,2) null,
        SU_TAG_Subject_Tag nvarchar(42) null,
        SU_LVL_SU_ID int null,
        Metadata_SU_LVL int null,
        SU_LVL_ChangedAt datetime2 null,
        SU_LVL_Positor tinyint null,
        SU_LVL_PositedAt datetime2 null,
        SU_LVL_Reliability decimal(5,2) null,
        SU_LVL_GRD_Grade nvarchar(42) null,
        SU_LVL_Metadata_GRD int null,
        SU_LVL_GRD_ID tinyint null,
        SU_TXT_SU_ID int null,
        Metadata_SU_TXT int null,
        SU_TXT_ChangedAt datetime2 null,
        SU_TXT_Positor tinyint null,
        SU_TXT_PositedAt datetime2 null,
        SU_TXT_Reliability decimal(5,2) null,
        SU_TXT_Subject_Text nvarchar(max) null,
        SU_ASR_SU_ID int null,
        Metadata_SU_ASR int null,
        SU_ASR_ChangedAt datetime2 null,
        SU_ASR_Positor tinyint null,
        SU_ASR_PositedAt datetime2 null,
        SU_ASR_Reliability decimal(5,2) null,
        SU_ASR_Subject_Assessment nvarchar(42) null,
        SU_ERS_SU_ID int null,
        Metadata_SU_ERS int null,
        SU_ERS_ChangedAt datetime2 null,
        SU_ERS_Positor tinyint null,
        SU_ERS_PositedAt datetime2 null,
        SU_ERS_Reliability decimal(5,2) null,
        SU_ERS_Subject_Erasable nvarchar(42) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.SU_ID, a.SU_ID),
        i.Metadata_SU,
        ISNULL(ISNULL(i.SU_NAM_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_NAM, i.Metadata_SU),
        ISNULL(ISNULL(i.SU_NAM_Positor, i.Positor), 0),
        ISNULL(i.SU_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.SU_NAM_Reliability, i.Reliability), 1),
        i.SU_NAM_Subject_Name,
        ISNULL(ISNULL(i.SU_COD_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_COD, i.Metadata_SU),
        ISNULL(ISNULL(i.SU_COD_Positor, i.Positor), 0),
        ISNULL(i.SU_COD_PositedAt, @now),
        ISNULL(ISNULL(i.SU_COD_Reliability, i.Reliability), 1),
        i.SU_COD_Subject_Code,
        ISNULL(ISNULL(i.SU_GRD_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_GRD, i.Metadata_SU),
        ISNULL(ISNULL(i.SU_GRD_Positor, i.Positor), 0),
        ISNULL(i.SU_GRD_PositedAt, @now),
        ISNULL(ISNULL(i.SU_GRD_Reliability, i.Reliability), 1),
        i.SU_GRD_GRD_Grade,
        ISNULL(i.SU_GRD_Metadata_GRD, i.Metadata_SU),
        i.SU_GRD_GRD_ID,
        ISNULL(ISNULL(i.SU_NOT_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_NOT, i.Metadata_SU),
        ISNULL(ISNULL(i.SU_NOT_Positor, i.Positor), 0),
        ISNULL(i.SU_NOT_PositedAt, @now),
        ISNULL(ISNULL(i.SU_NOT_Reliability, i.Reliability), 1),
        i.SU_NOT_Subject_Note,
        ISNULL(ISNULL(i.SU_TTL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TTL, i.Metadata_SU),
        ISNULL(i.SU_TTL_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_TTL_Positor, i.Positor), 0),
        ISNULL(i.SU_TTL_PositedAt, @now),
        ISNULL(ISNULL(i.SU_TTL_Reliability, i.Reliability), 1),
        i.SU_TTL_Subject_Title,
        ISNULL(ISNULL(i.SU_STA_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_STA, i.Metadata_SU),
        ISNULL(i.SU_STA_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_STA_Positor, i.Positor), 0),
        ISNULL(i.SU_STA_PositedAt, @now),
        ISNULL(ISNULL(i.SU_STA_Reliability, i.Reliability), 1),
        i.SU_STA_Subject_State,
        ISNULL(ISNULL(i.SU_LBL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_LBL, i.Metadata_SU),
        ISNULL(i.SU_LBL_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_LBL_Positor, i.Positor), 0),
        ISNULL(i.SU_LBL_PositedAt, @now),
        ISNULL(ISNULL(i.SU_LBL_Reliability, i.Reliability), 1),
        i.SU_LBL_Subject_Label,
        ISNULL(ISNULL(i.SU_TAG_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TAG, i.Metadata_SU),
        ISNULL(i.SU_TAG_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_TAG_Positor, i.Positor), 0),
        ISNULL(i.SU_TAG_PositedAt, @now),
        ISNULL(ISNULL(i.SU_TAG_Reliability, i.Reliability), 1),
        i.SU_TAG_Subject_Tag,
        ISNULL(ISNULL(i.SU_LVL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_LVL, i.Metadata_SU),
        ISNULL(i.SU_LVL_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_LVL_Positor, i.Positor), 0),
        ISNULL(i.SU_LVL_PositedAt, @now),
        ISNULL(ISNULL(i.SU_LVL_Reliability, i.Reliability), 1),
        i.SU_LVL_GRD_Grade,
        ISNULL(i.SU_LVL_Metadata_GRD, i.Metadata_SU),
        i.SU_LVL_GRD_ID,
        ISNULL(ISNULL(i.SU_TXT_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TXT, i.Metadata_SU),
        ISNULL(i.SU_TXT_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_TXT_Positor, i.Positor), 0),
        ISNULL(i.SU_TXT_PositedAt, @now),
        ISNULL(ISNULL(i.SU_TXT_Reliability, i.Reliability), 1),
        i.SU_TXT_Subject_Text,
        ISNULL(ISNULL(i.SU_ASR_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_ASR, i.Metadata_SU),
        ISNULL(i.SU_ASR_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_ASR_Positor, i.Positor), 0),
        ISNULL(i.SU_ASR_PositedAt, @now),
        ISNULL(ISNULL(i.SU_ASR_Reliability, i.Reliability), 1),
        i.SU_ASR_Subject_Assessment,
        ISNULL(ISNULL(i.SU_ERS_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_ERS, i.Metadata_SU),
        ISNULL(i.SU_ERS_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_ERS_Positor, i.Positor), 0),
        ISNULL(i.SU_ERS_PositedAt, @now),
        ISNULL(ISNULL(i.SU_ERS_Reliability, i.Reliability), 1),
        i.SU_ERS_Subject_Erasable
    FROM (
        SELECT
            Positor,
            Reliability,
            SU_ID,
            Metadata_SU,
            SU_NAM_SU_ID,
            Metadata_SU_NAM,
            SU_NAM_Positor,
            SU_NAM_PositedAt,
            SU_NAM_Reliability,
            SU_NAM_Subject_Name,
            SU_COD_SU_ID,
            Metadata_SU_COD,
            SU_COD_Positor,
            SU_COD_PositedAt,
            SU_COD_Reliability,
            SU_COD_Subject_Code,
            SU_GRD_SU_ID,
            Metadata_SU_GRD,
            SU_GRD_Positor,
            SU_GRD_PositedAt,
            SU_GRD_Reliability,
            SU_GRD_GRD_Grade,
            SU_GRD_Metadata_GRD,
            SU_GRD_GRD_ID,
            SU_NOT_SU_ID,
            Metadata_SU_NOT,
            SU_NOT_Positor,
            SU_NOT_PositedAt,
            SU_NOT_Reliability,
            SU_NOT_Subject_Note,
            SU_TTL_SU_ID,
            Metadata_SU_TTL,
            SU_TTL_ChangedAt,
            SU_TTL_Positor,
            SU_TTL_PositedAt,
            SU_TTL_Reliability,
            SU_TTL_Subject_Title,
            SU_STA_SU_ID,
            Metadata_SU_STA,
            SU_STA_ChangedAt,
            SU_STA_Positor,
            SU_STA_PositedAt,
            SU_STA_Reliability,
            SU_STA_Subject_State,
            SU_LBL_SU_ID,
            Metadata_SU_LBL,
            SU_LBL_ChangedAt,
            SU_LBL_Positor,
            SU_LBL_PositedAt,
            SU_LBL_Reliability,
            SU_LBL_Subject_Label,
            SU_TAG_SU_ID,
            Metadata_SU_TAG,
            SU_TAG_ChangedAt,
            SU_TAG_Positor,
            SU_TAG_PositedAt,
            SU_TAG_Reliability,
            SU_TAG_Subject_Tag,
            SU_LVL_SU_ID,
            Metadata_SU_LVL,
            SU_LVL_ChangedAt,
            SU_LVL_Positor,
            SU_LVL_PositedAt,
            SU_LVL_Reliability,
            SU_LVL_GRD_Grade,
            SU_LVL_Metadata_GRD,
            SU_LVL_GRD_ID,
            SU_TXT_SU_ID,
            Metadata_SU_TXT,
            SU_TXT_ChangedAt,
            SU_TXT_Positor,
            SU_TXT_PositedAt,
            SU_TXT_Reliability,
            SU_TXT_Subject_Text,
            SU_ASR_SU_ID,
            Metadata_SU_ASR,
            SU_ASR_ChangedAt,
            SU_ASR_Positor,
            SU_ASR_PositedAt,
            SU_ASR_Reliability,
            SU_ASR_Subject_Assessment,
            SU_ERS_SU_ID,
            Metadata_SU_ERS,
            SU_ERS_ChangedAt,
            SU_ERS_Positor,
            SU_ERS_PositedAt,
            SU_ERS_Reliability,
            SU_ERS_Subject_Erasable,
            ROW_NUMBER() OVER (PARTITION BY SU_ID ORDER BY SU_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @SU a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[SU_NAM_Subject_Name] (
        Metadata_SU_NAM,
        SU_NAM_SU_ID,
        SU_NAM_Subject_Name,
        SU_NAM_PositedAt,
        SU_NAM_Positor,
        SU_NAM_Reliability
    )
    SELECT
        i.Metadata_SU_NAM,
        i.SU_NAM_SU_ID,
        i.SU_NAM_Subject_Name,
        i.SU_NAM_PositedAt,
        i.SU_NAM_Positor,
        i.SU_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_NAM_Subject_Name is not null;
    INSERT INTO [dbo].[SU_COD_Subject_Code] (
        Metadata_SU_COD,
        SU_COD_SU_ID,
        SU_COD_Subject_Code,
        SU_COD_PositedAt,
        SU_COD_Positor,
        SU_COD_Reliability
    )
    SELECT
        i.Metadata_SU_COD,
        i.SU_COD_SU_ID,
        i.SU_COD_Subject_Code,
        i.SU_COD_PositedAt,
        i.SU_COD_Positor,
        i.SU_COD_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_COD_Subject_Code is not null;
    INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
        Metadata_SU_GRD,
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID,
        SU_GRD_PositedAt,
        SU_GRD_Positor,
        SU_GRD_Reliability
    )
    SELECT
        i.Metadata_SU_GRD,
        i.SU_GRD_SU_ID,
        ISNULL(i.SU_GRD_GRD_ID, [kGRD].GRD_ID),
        i.SU_GRD_PositedAt,
        i.SU_GRD_Positor,
        i.SU_GRD_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [kGRD]
    ON
        [kGRD].GRD_Grade = i.SU_GRD_GRD_Grade
    WHERE
        ISNULL(i.SU_GRD_GRD_ID, [kGRD].GRD_ID) is not null;
    INSERT INTO [dbo].[SU_NOT_Subject_Note] (
        Metadata_SU_NOT,
        SU_NOT_SU_ID,
        SU_NOT_Subject_Note,
        SU_NOT_PositedAt,
        SU_NOT_Positor,
        SU_NOT_Reliability
    )
    SELECT
        i.Metadata_SU_NOT,
        i.SU_NOT_SU_ID,
        i.SU_NOT_Subject_Note,
        i.SU_NOT_PositedAt,
        i.SU_NOT_Positor,
        i.SU_NOT_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_NOT_Subject_Note is not null;
    INSERT INTO [dbo].[SU_TTL_Subject_Title] (
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_Subject_Title,
        SU_TTL_ChangedAt,
        SU_TTL_PositedAt,
        SU_TTL_Positor,
        SU_TTL_Reliability
    )
    SELECT
        i.Metadata_SU_TTL,
        i.SU_TTL_SU_ID,
        i.SU_TTL_Subject_Title,
        i.SU_TTL_ChangedAt,
        i.SU_TTL_PositedAt,
        i.SU_TTL_Positor,
        i.SU_TTL_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_TTL_Subject_Title is not null;
    INSERT INTO [dbo].[SU_STA_Subject_State] (
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_Subject_State,
        SU_STA_ChangedAt,
        SU_STA_PositedAt,
        SU_STA_Positor,
        SU_STA_Reliability
    )
    SELECT
        i.Metadata_SU_STA,
        i.SU_STA_SU_ID,
        i.SU_STA_Subject_State,
        i.SU_STA_ChangedAt,
        i.SU_STA_PositedAt,
        i.SU_STA_Positor,
        i.SU_STA_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_STA_Subject_State is not null;
    INSERT INTO [dbo].[SU_LBL_Subject_Label] (
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_Subject_Label,
        SU_LBL_ChangedAt,
        SU_LBL_PositedAt,
        SU_LBL_Positor,
        SU_LBL_Reliability
    )
    SELECT
        i.Metadata_SU_LBL,
        i.SU_LBL_SU_ID,
        i.SU_LBL_Subject_Label,
        i.SU_LBL_ChangedAt,
        i.SU_LBL_PositedAt,
        i.SU_LBL_Positor,
        i.SU_LBL_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_LBL_Subject_Label is not null;
    INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_Subject_Tag,
        SU_TAG_ChangedAt,
        SU_TAG_PositedAt,
        SU_TAG_Positor,
        SU_TAG_Reliability
    )
    SELECT
        i.Metadata_SU_TAG,
        i.SU_TAG_SU_ID,
        i.SU_TAG_Subject_Tag,
        i.SU_TAG_ChangedAt,
        i.SU_TAG_PositedAt,
        i.SU_TAG_Positor,
        i.SU_TAG_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_TAG_Subject_Tag is not null;
    INSERT INTO [dbo].[SU_LVL_Subject_Level] (
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_GRD_ID,
        SU_LVL_ChangedAt,
        SU_LVL_PositedAt,
        SU_LVL_Positor,
        SU_LVL_Reliability
    )
    SELECT
        i.Metadata_SU_LVL,
        i.SU_LVL_SU_ID,
        ISNULL(i.SU_LVL_GRD_ID, [kGRD].GRD_ID),
        i.SU_LVL_ChangedAt,
        i.SU_LVL_PositedAt,
        i.SU_LVL_Positor,
        i.SU_LVL_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [kGRD]
    ON
        [kGRD].GRD_Grade = i.SU_LVL_GRD_Grade
    WHERE
        ISNULL(i.SU_LVL_GRD_ID, [kGRD].GRD_ID) is not null;
    INSERT INTO [dbo].[SU_TXT_Subject_Text] (
        Metadata_SU_TXT,
        SU_TXT_SU_ID,
        SU_TXT_Subject_Text,
        SU_TXT_ChangedAt,
        SU_TXT_PositedAt,
        SU_TXT_Positor,
        SU_TXT_Reliability
    )
    SELECT
        i.Metadata_SU_TXT,
        i.SU_TXT_SU_ID,
        i.SU_TXT_Subject_Text,
        i.SU_TXT_ChangedAt,
        i.SU_TXT_PositedAt,
        i.SU_TXT_Positor,
        i.SU_TXT_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_TXT_Subject_Text is not null;
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_Subject_Assessment,
        SU_ASR_ChangedAt,
        SU_ASR_PositedAt,
        SU_ASR_Positor,
        SU_ASR_Reliability
    )
    SELECT
        i.Metadata_SU_ASR,
        i.SU_ASR_SU_ID,
        i.SU_ASR_Subject_Assessment,
        i.SU_ASR_ChangedAt,
        i.SU_ASR_PositedAt,
        i.SU_ASR_Positor,
        i.SU_ASR_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_ASR_Subject_Assessment is not null;
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_Subject_Erasable,
        SU_ERS_ChangedAt,
        SU_ERS_PositedAt,
        SU_ERS_Positor,
        SU_ERS_Reliability
    )
    SELECT
        i.Metadata_SU_ERS,
        i.SU_ERS_SU_ID,
        i.SU_ERS_Subject_Erasable,
        i.SU_ERS_ChangedAt,
        i.SU_ERS_PositedAt,
        i.SU_ERS_Positor,
        i.SU_ERS_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_ERS_Subject_Erasable is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_Subject instead of UPDATE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lSU_Subject] ON [dbo].[lSU_Subject]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(SU_ID))
        RAISERROR('The identity column SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NAM_ID))
        RAISERROR('The identity column SU_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NAM_SU_ID))
        RAISERROR('The foreign key column SU_NAM_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NAM_Assertion))
        RAISERROR('The computed assertion column SU_NAM_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_NAM_Subject_Name) OR
        UPDATE(SU_NAM_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_NAM_Subject_Name] (
            Metadata_SU_NAM,
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name,
            SU_NAM_PositedAt,
            SU_NAM_Positor,
            SU_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NAM)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NAM
            END, i.Metadata_SU),
            ISNULL(i.SU_NAM_SU_ID, i.SU_ID),
            i.SU_NAM_Subject_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_NAM_PositedAt) THEN i.SU_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_NAM_Positor) THEN i.SU_NAM_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_NAM_Reliability) THEN i.SU_NAM_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_NAM_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_NAM_Subject_Name is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_NAM_PositedAt) OR
            UPDATE(SU_NAM_Positor) OR
            UPDATE(Positor) OR
            d.SU_NAM_Subject_Name is null OR
            d.SU_NAM_Subject_Name <> i.SU_NAM_Subject_Name OR
            d.SU_NAM_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_NAM_Reliability) THEN i.SU_NAM_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_NAM_Reliability
            END, 1)
        )
    END
    -- indecisive: another value is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_NAM_Subject_Name)
    )
    BEGIN
        INSERT INTO [dbo].[SU_NAM_Subject_Name] (
            Metadata_SU_NAM,
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name,
            SU_NAM_PositedAt,
            SU_NAM_Positor,
            SU_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NAM)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NAM
            END, i.Metadata_SU),
            p.SU_NAM_SU_ID,
            p.SU_NAM_Subject_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_NAM_PositedAt) THEN i.SU_NAM_PositedAt
            END, @now) as datetime2),
            d.SU_NAM_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_NAM_Subject_Name_Posit] p
        ON
            p.SU_NAM_ID = d.SU_NAM_ID
        WHERE
            p.SU_NAM_Subject_Name <> i.SU_NAM_Subject_Name
        AND
            d.SU_NAM_Positor = ISNULL(CASE
                WHEN UPDATE(SU_NAM_Positor) THEN i.SU_NAM_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_NAM_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_NAM_PositedAt) THEN i.SU_NAM_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_NAM_Reliability) THEN i.SU_NAM_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_NAM_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_NAM_Subject_Name)
    )
    BEGIN
        INSERT INTO [dbo].[SU_NAM_Subject_Name] (
            Metadata_SU_NAM,
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name,
            SU_NAM_PositedAt,
            SU_NAM_Positor,
            SU_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NAM)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NAM
            END, i.Metadata_SU),
            p.SU_NAM_SU_ID,
            p.SU_NAM_Subject_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_NAM_PositedAt) THEN i.SU_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_NAM_Positor) THEN i.SU_NAM_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_NAM_Subject_Name_Posit] p
        ON
            p.SU_NAM_ID = i.SU_NAM_ID
        WHERE
            i.SU_NAM_Subject_Name is null
    END
    IF(UPDATE(SU_COD_ID))
        RAISERROR('The identity column SU_COD_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_COD_SU_ID))
        RAISERROR('The foreign key column SU_COD_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_COD_Assertion))
        RAISERROR('The computed assertion column SU_COD_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_COD_Subject_Code) OR
        UPDATE(SU_COD_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_COD_Subject_Code] (
            Metadata_SU_COD,
            SU_COD_SU_ID,
            SU_COD_Subject_Code,
            SU_COD_PositedAt,
            SU_COD_Positor,
            SU_COD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_COD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_COD
            END, i.Metadata_SU),
            ISNULL(i.SU_COD_SU_ID, i.SU_ID),
            i.SU_COD_Subject_Code,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_COD_PositedAt) THEN i.SU_COD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_COD_Positor) THEN i.SU_COD_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_COD_Reliability) THEN i.SU_COD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_COD_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_COD_Subject_Code is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_COD_PositedAt) OR
            UPDATE(SU_COD_Positor) OR
            UPDATE(Positor) OR
            d.SU_COD_Subject_Code is null OR
            d.SU_COD_Subject_Code <> i.SU_COD_Subject_Code OR
            d.SU_COD_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_COD_Reliability) THEN i.SU_COD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_COD_Reliability
            END, 1)
        )
    END
    -- indecisive: another value is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_COD_Subject_Code)
    )
    BEGIN
        INSERT INTO [dbo].[SU_COD_Subject_Code] (
            Metadata_SU_COD,
            SU_COD_SU_ID,
            SU_COD_Subject_Code,
            SU_COD_PositedAt,
            SU_COD_Positor,
            SU_COD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_COD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_COD
            END, i.Metadata_SU),
            p.SU_COD_SU_ID,
            p.SU_COD_Subject_Code,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_COD_PositedAt) THEN i.SU_COD_PositedAt
            END, @now) as datetime2),
            d.SU_COD_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_COD_Subject_Code_Posit] p
        ON
            p.SU_COD_ID = d.SU_COD_ID
        WHERE
            p.SU_COD_Subject_Code <> i.SU_COD_Subject_Code
        AND
            d.SU_COD_Positor = ISNULL(CASE
                WHEN UPDATE(SU_COD_Positor) THEN i.SU_COD_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_COD_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_COD_PositedAt) THEN i.SU_COD_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_COD_Reliability) THEN i.SU_COD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_COD_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_COD_Subject_Code)
    )
    BEGIN
        INSERT INTO [dbo].[SU_COD_Subject_Code] (
            Metadata_SU_COD,
            SU_COD_SU_ID,
            SU_COD_Subject_Code,
            SU_COD_PositedAt,
            SU_COD_Positor,
            SU_COD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_COD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_COD
            END, i.Metadata_SU),
            p.SU_COD_SU_ID,
            p.SU_COD_Subject_Code,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_COD_PositedAt) THEN i.SU_COD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_COD_Positor) THEN i.SU_COD_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_COD_Subject_Code_Posit] p
        ON
            p.SU_COD_ID = i.SU_COD_ID
        WHERE
            i.SU_COD_Subject_Code is null
    END
    IF(UPDATE(SU_GRD_ID))
        RAISERROR('The identity column SU_GRD_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_GRD_SU_ID))
        RAISERROR('The foreign key column SU_GRD_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_GRD_Assertion))
        RAISERROR('The computed assertion column SU_GRD_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_GRD_GRD_ID) OR
        UPDATE(SU_GRD_GRD_Grade) OR
        UPDATE(SU_GRD_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
            Metadata_SU_GRD,
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Positor,
            SU_GRD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_GRD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_GRD
            END, i.Metadata_SU),
            ISNULL(i.SU_GRD_SU_ID, i.SU_ID),
            CASE
                WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID
                ELSE [kGRD].GRD_ID
            END,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_GRD_PositedAt) THEN i.SU_GRD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_GRD_Positor) THEN i.SU_GRD_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_GRD_Reliability) THEN i.SU_GRD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_GRD_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[GRD_Grade] [kGRD]
        ON
            [kGRD].GRD_Grade = i.SU_GRD_GRD_Grade
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            CASE
                WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID
                ELSE [kGRD].GRD_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_GRD_PositedAt) OR
            UPDATE(SU_GRD_Positor) OR
            UPDATE(Positor) OR
            d.SU_GRD_GRD_ID is null OR
            d.SU_GRD_GRD_ID <> CASE WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID ELSE [kGRD].GRD_ID END OR
            d.SU_GRD_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_GRD_Reliability) THEN i.SU_GRD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_GRD_Reliability
            END, 1)
        );
    END
    -- indecisive: another value is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_GRD_GRD_ID) OR
        UPDATE(SU_GRD_GRD_Grade)
    )
    BEGIN
        INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
            Metadata_SU_GRD,
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Positor,
            SU_GRD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_GRD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_GRD
            END, i.Metadata_SU),
            p.SU_GRD_SU_ID,
            p.SU_GRD_GRD_ID,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_GRD_PositedAt) THEN i.SU_GRD_PositedAt
            END, @now) as datetime2),
            d.SU_GRD_Positor,
            0
        FROM
            inserted i
        LEFT JOIN
            [dbo].[GRD_Grade] [kGRD]
        ON
            [kGRD].GRD_Grade = i.SU_GRD_GRD_Grade
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        ON
            p.SU_GRD_ID = d.SU_GRD_ID
        WHERE
            p.SU_GRD_GRD_ID <> CASE
                WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID
                ELSE [kGRD].GRD_ID
            END
        AND
            d.SU_GRD_Positor = ISNULL(CASE
                WHEN UPDATE(SU_GRD_Positor) THEN i.SU_GRD_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_GRD_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_GRD_PositedAt) THEN i.SU_GRD_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_GRD_Reliability) THEN i.SU_GRD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_GRD_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_GRD_GRD_ID) OR
        UPDATE(SU_GRD_GRD_Grade)
    )
    BEGIN
        INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
            Metadata_SU_GRD,
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Positor,
            SU_GRD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_GRD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_GRD
            END, i.Metadata_SU),
            p.SU_GRD_SU_ID,
            p.SU_GRD_GRD_ID,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_GRD_PositedAt) THEN i.SU_GRD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_GRD_Positor) THEN i.SU_GRD_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        ON
            p.SU_GRD_ID = i.SU_GRD_ID
        WHERE
            (UPDATE(SU_GRD_GRD_ID) AND i.SU_GRD_GRD_ID is null)
        OR
            (UPDATE(SU_GRD_GRD_Grade) AND i.SU_GRD_GRD_Grade is null);
    END
    IF(UPDATE(SU_NOT_ID))
        RAISERROR('The identity column SU_NOT_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NOT_SU_ID))
        RAISERROR('The foreign key column SU_NOT_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NOT_Assertion))
        RAISERROR('The computed assertion column SU_NOT_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_NOT_Subject_Note) OR
        UPDATE(SU_NOT_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_NOT_Subject_Note] (
            Metadata_SU_NOT,
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note,
            SU_NOT_PositedAt,
            SU_NOT_Positor,
            SU_NOT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NOT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NOT
            END, i.Metadata_SU),
            ISNULL(i.SU_NOT_SU_ID, i.SU_ID),
            i.SU_NOT_Subject_Note,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_NOT_PositedAt) THEN i.SU_NOT_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_NOT_Positor) THEN i.SU_NOT_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_NOT_Reliability) THEN i.SU_NOT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_NOT_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_NOT_Subject_Note is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_NOT_PositedAt) OR
            UPDATE(SU_NOT_Positor) OR
            UPDATE(Positor) OR
            d.SU_NOT_Subject_Note is null OR
            d.SU_NOT_Checksum <> dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max))) OR
            d.SU_NOT_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_NOT_Reliability) THEN i.SU_NOT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_NOT_Reliability
            END, 1)
        )
    END
    -- indecisive: another value is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_NOT_Subject_Note)
    )
    BEGIN
        INSERT INTO [dbo].[SU_NOT_Subject_Note] (
            Metadata_SU_NOT,
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note,
            SU_NOT_PositedAt,
            SU_NOT_Positor,
            SU_NOT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NOT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NOT
            END, i.Metadata_SU),
            p.SU_NOT_SU_ID,
            p.SU_NOT_Subject_Note,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_NOT_PositedAt) THEN i.SU_NOT_PositedAt
            END, @now) as datetime2),
            d.SU_NOT_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_NOT_Subject_Note_Posit] p
        ON
            p.SU_NOT_ID = d.SU_NOT_ID
        WHERE
            p.SU_NOT_Checksum <> dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
        AND
            d.SU_NOT_Positor = ISNULL(CASE
                WHEN UPDATE(SU_NOT_Positor) THEN i.SU_NOT_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_NOT_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_NOT_PositedAt) THEN i.SU_NOT_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_NOT_Reliability) THEN i.SU_NOT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_NOT_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_NOT_Subject_Note)
    )
    BEGIN
        INSERT INTO [dbo].[SU_NOT_Subject_Note] (
            Metadata_SU_NOT,
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note,
            SU_NOT_PositedAt,
            SU_NOT_Positor,
            SU_NOT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NOT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NOT
            END, i.Metadata_SU),
            p.SU_NOT_SU_ID,
            p.SU_NOT_Subject_Note,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_NOT_PositedAt) THEN i.SU_NOT_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_NOT_Positor) THEN i.SU_NOT_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_NOT_Subject_Note_Posit] p
        ON
            p.SU_NOT_ID = i.SU_NOT_ID
        WHERE
            i.SU_NOT_Subject_Note is null
    END
    IF(UPDATE(SU_TTL_ID))
        RAISERROR('The identity column SU_TTL_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TTL_SU_ID))
        RAISERROR('The foreign key column SU_TTL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TTL_Assertion))
        RAISERROR('The computed assertion column SU_TTL_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_TTL_Subject_Title) OR
        UPDATE(SU_TTL_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TTL_Subject_Title] (
            Metadata_SU_TTL,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt,
            SU_TTL_PositedAt,
            SU_TTL_Positor,
            SU_TTL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TTL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TTL
            END, i.Metadata_SU),
            ISNULL(i.SU_TTL_SU_ID, i.SU_ID),
            i.SU_TTL_Subject_Title,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TTL_ChangedAt) THEN i.SU_TTL_ChangedAt
                WHEN d.SU_TTL_Subject_Title = i.SU_TTL_Subject_Title
                THEN i.SU_TTL_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TTL_PositedAt) THEN i.SU_TTL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TTL_Positor) THEN i.SU_TTL_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_TTL_Reliability) THEN i.SU_TTL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TTL_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_TTL_Subject_Title is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_TTL_ChangedAt) OR
            UPDATE(SU_TTL_PositedAt) OR
            UPDATE(SU_TTL_Positor) OR
            UPDATE(Positor) OR
            d.SU_TTL_Subject_Title is null OR
            d.SU_TTL_Subject_Title <> i.SU_TTL_Subject_Title OR
            d.SU_TTL_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_TTL_Reliability) THEN i.SU_TTL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TTL_Reliability
            END, 1)
        )
    END
    -- indecisive: another value at the same changing time is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_TTL_Subject_Title)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TTL_Subject_Title] (
            Metadata_SU_TTL,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt,
            SU_TTL_PositedAt,
            SU_TTL_Positor,
            SU_TTL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TTL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TTL
            END, i.Metadata_SU),
            p.SU_TTL_SU_ID,
            p.SU_TTL_Subject_Title,
            p.SU_TTL_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TTL_PositedAt) THEN i.SU_TTL_PositedAt
            END, @now) as datetime2),
            d.SU_TTL_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_TTL_Subject_Title_Posit] p
        ON
            p.SU_TTL_ID = d.SU_TTL_ID
        WHERE
            p.SU_TTL_Subject_Title <> i.SU_TTL_Subject_Title
        AND
            UPDATE(SU_TTL_ChangedAt)
        AND
            p.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
        AND
            d.SU_TTL_Positor = ISNULL(CASE
                WHEN UPDATE(SU_TTL_Positor) THEN i.SU_TTL_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_TTL_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_TTL_PositedAt) THEN i.SU_TTL_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_TTL_Reliability) THEN i.SU_TTL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TTL_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_TTL_Subject_Title)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TTL_Subject_Title] (
            Metadata_SU_TTL,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt,
            SU_TTL_PositedAt,
            SU_TTL_Positor,
            SU_TTL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TTL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TTL
            END, i.Metadata_SU),
            p.SU_TTL_SU_ID,
            p.SU_TTL_Subject_Title,
            p.SU_TTL_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TTL_PositedAt) THEN i.SU_TTL_PositedAt
                WHEN UPDATE(SU_TTL_ChangedAt) THEN i.SU_TTL_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TTL_Positor) THEN i.SU_TTL_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_TTL_Subject_Title_Posit] p
        ON
            p.SU_TTL_ID = i.SU_TTL_ID
        WHERE
            i.SU_TTL_Subject_Title is null
    END
    IF(UPDATE(SU_STA_ID))
        RAISERROR('The identity column SU_STA_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_STA_SU_ID))
        RAISERROR('The foreign key column SU_STA_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_STA_Assertion))
        RAISERROR('The computed assertion column SU_STA_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_STA_Subject_State) OR
        UPDATE(SU_STA_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_STA_Subject_State] (
            Metadata_SU_STA,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt,
            SU_STA_PositedAt,
            SU_STA_Positor,
            SU_STA_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_STA)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_STA
            END, i.Metadata_SU),
            ISNULL(i.SU_STA_SU_ID, i.SU_ID),
            i.SU_STA_Subject_State,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_STA_ChangedAt) THEN i.SU_STA_ChangedAt
                WHEN d.SU_STA_Subject_State = i.SU_STA_Subject_State
                THEN i.SU_STA_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_STA_PositedAt) THEN i.SU_STA_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_STA_Positor) THEN i.SU_STA_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_STA_Reliability) THEN i.SU_STA_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_STA_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_STA_Subject_State is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_STA_ChangedAt) OR
            UPDATE(SU_STA_PositedAt) OR
            UPDATE(SU_STA_Positor) OR
            UPDATE(Positor) OR
            d.SU_STA_Subject_State is null OR
            d.SU_STA_Subject_State <> i.SU_STA_Subject_State OR
            d.SU_STA_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_STA_Reliability) THEN i.SU_STA_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_STA_Reliability
            END, 1)
        )
    END
    -- indecisive: another value at the same changing time is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_STA_Subject_State)
    )
    BEGIN
        INSERT INTO [dbo].[SU_STA_Subject_State] (
            Metadata_SU_STA,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt,
            SU_STA_PositedAt,
            SU_STA_Positor,
            SU_STA_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_STA)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_STA
            END, i.Metadata_SU),
            p.SU_STA_SU_ID,
            p.SU_STA_Subject_State,
            p.SU_STA_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_STA_PositedAt) THEN i.SU_STA_PositedAt
            END, @now) as datetime2),
            d.SU_STA_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_STA_Subject_State_Posit] p
        ON
            p.SU_STA_ID = d.SU_STA_ID
        WHERE
            p.SU_STA_Subject_State <> i.SU_STA_Subject_State
        AND
            UPDATE(SU_STA_ChangedAt)
        AND
            p.SU_STA_ChangedAt = i.SU_STA_ChangedAt
        AND
            d.SU_STA_Positor = ISNULL(CASE
                WHEN UPDATE(SU_STA_Positor) THEN i.SU_STA_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_STA_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_STA_PositedAt) THEN i.SU_STA_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_STA_Reliability) THEN i.SU_STA_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_STA_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_STA_Subject_State)
    )
    BEGIN
        INSERT INTO [dbo].[SU_STA_Subject_State] (
            Metadata_SU_STA,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt,
            SU_STA_PositedAt,
            SU_STA_Positor,
            SU_STA_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_STA)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_STA
            END, i.Metadata_SU),
            p.SU_STA_SU_ID,
            p.SU_STA_Subject_State,
            p.SU_STA_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_STA_PositedAt) THEN i.SU_STA_PositedAt
                WHEN UPDATE(SU_STA_ChangedAt) THEN i.SU_STA_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_STA_Positor) THEN i.SU_STA_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_STA_Subject_State_Posit] p
        ON
            p.SU_STA_ID = i.SU_STA_ID
        WHERE
            i.SU_STA_Subject_State is null
    END
    IF(UPDATE(SU_LBL_ID))
        RAISERROR('The identity column SU_LBL_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LBL_SU_ID))
        RAISERROR('The foreign key column SU_LBL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LBL_Assertion))
        RAISERROR('The computed assertion column SU_LBL_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_LBL_Subject_Label) OR
        UPDATE(SU_LBL_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_LBL_Subject_Label] (
            Metadata_SU_LBL,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt,
            SU_LBL_PositedAt,
            SU_LBL_Positor,
            SU_LBL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LBL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LBL
            END, i.Metadata_SU),
            ISNULL(i.SU_LBL_SU_ID, i.SU_ID),
            i.SU_LBL_Subject_Label,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LBL_ChangedAt) THEN i.SU_LBL_ChangedAt
                WHEN d.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
                THEN i.SU_LBL_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LBL_PositedAt) THEN i.SU_LBL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_LBL_Positor) THEN i.SU_LBL_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_LBL_Reliability) THEN i.SU_LBL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_LBL_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_LBL_Subject_Label is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_LBL_ChangedAt) OR
            UPDATE(SU_LBL_PositedAt) OR
            UPDATE(SU_LBL_Positor) OR
            UPDATE(Positor) OR
            d.SU_LBL_Subject_Label is null OR
            d.SU_LBL_Subject_Label <> i.SU_LBL_Subject_Label OR
            d.SU_LBL_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_LBL_Reliability) THEN i.SU_LBL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_LBL_Reliability
            END, 1)
        )
    END
    -- indecisive: another value at the same changing time is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_LBL_Subject_Label)
    )
    BEGIN
        INSERT INTO [dbo].[SU_LBL_Subject_Label] (
            Metadata_SU_LBL,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt,
            SU_LBL_PositedAt,
            SU_LBL_Positor,
            SU_LBL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LBL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LBL
            END, i.Metadata_SU),
            p.SU_LBL_SU_ID,
            p.SU_LBL_Subject_Label,
            p.SU_LBL_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LBL_PositedAt) THEN i.SU_LBL_PositedAt
            END, @now) as datetime2),
            d.SU_LBL_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_LBL_Subject_Label_Posit] p
        ON
            p.SU_LBL_ID = d.SU_LBL_ID
        WHERE
            p.SU_LBL_Subject_Label <> i.SU_LBL_Subject_Label
        AND
            UPDATE(SU_LBL_ChangedAt)
        AND
            p.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
        AND
            d.SU_LBL_Positor = ISNULL(CASE
                WHEN UPDATE(SU_LBL_Positor) THEN i.SU_LBL_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_LBL_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_LBL_PositedAt) THEN i.SU_LBL_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_LBL_Reliability) THEN i.SU_LBL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_LBL_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_LBL_Subject_Label)
    )
    BEGIN
        INSERT INTO [dbo].[SU_LBL_Subject_Label] (
            Metadata_SU_LBL,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt,
            SU_LBL_PositedAt,
            SU_LBL_Positor,
            SU_LBL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LBL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LBL
            END, i.Metadata_SU),
            p.SU_LBL_SU_ID,
            p.SU_LBL_Subject_Label,
            p.SU_LBL_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LBL_PositedAt) THEN i.SU_LBL_PositedAt
                WHEN UPDATE(SU_LBL_ChangedAt) THEN i.SU_LBL_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_LBL_Positor) THEN i.SU_LBL_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_LBL_Subject_Label_Posit] p
        ON
            p.SU_LBL_ID = i.SU_LBL_ID
        WHERE
            i.SU_LBL_Subject_Label is null
    END
    IF(UPDATE(SU_TAG_ID))
        RAISERROR('The identity column SU_TAG_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TAG_SU_ID))
        RAISERROR('The foreign key column SU_TAG_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TAG_Assertion))
        RAISERROR('The computed assertion column SU_TAG_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_TAG_Subject_Tag) OR
        UPDATE(SU_TAG_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
            Metadata_SU_TAG,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt,
            SU_TAG_PositedAt,
            SU_TAG_Positor,
            SU_TAG_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TAG)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TAG
            END, i.Metadata_SU),
            ISNULL(i.SU_TAG_SU_ID, i.SU_ID),
            i.SU_TAG_Subject_Tag,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TAG_ChangedAt) THEN i.SU_TAG_ChangedAt
                WHEN d.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
                THEN i.SU_TAG_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TAG_PositedAt) THEN i.SU_TAG_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TAG_Positor) THEN i.SU_TAG_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_TAG_Reliability) THEN i.SU_TAG_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TAG_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_TAG_Subject_Tag is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_TAG_ChangedAt) OR
            UPDATE(SU_TAG_PositedAt) OR
            UPDATE(SU_TAG_Positor) OR
            UPDATE(Positor) OR
            d.SU_TAG_Subject_Tag is null OR
            d.SU_TAG_Subject_Tag <> i.SU_TAG_Subject_Tag OR
            d.SU_TAG_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_TAG_Reliability) THEN i.SU_TAG_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TAG_Reliability
            END, 1)
        )
    END
    -- indecisive: another value at the same changing time is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_TAG_Subject_Tag)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
            Metadata_SU_TAG,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt,
            SU_TAG_PositedAt,
            SU_TAG_Positor,
            SU_TAG_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TAG)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TAG
            END, i.Metadata_SU),
            p.SU_TAG_SU_ID,
            p.SU_TAG_Subject_Tag,
            p.SU_TAG_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TAG_PositedAt) THEN i.SU_TAG_PositedAt
            END, @now) as datetime2),
            d.SU_TAG_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        ON
            p.SU_TAG_ID = d.SU_TAG_ID
        WHERE
            p.SU_TAG_Subject_Tag <> i.SU_TAG_Subject_Tag
        AND
            UPDATE(SU_TAG_ChangedAt)
        AND
            p.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
        AND
            d.SU_TAG_Positor = ISNULL(CASE
                WHEN UPDATE(SU_TAG_Positor) THEN i.SU_TAG_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_TAG_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_TAG_PositedAt) THEN i.SU_TAG_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_TAG_Reliability) THEN i.SU_TAG_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TAG_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_TAG_Subject_Tag)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
            Metadata_SU_TAG,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt,
            SU_TAG_PositedAt,
            SU_TAG_Positor,
            SU_TAG_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TAG)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TAG
            END, i.Metadata_SU),
            p.SU_TAG_SU_ID,
            p.SU_TAG_Subject_Tag,
            p.SU_TAG_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TAG_PositedAt) THEN i.SU_TAG_PositedAt
                WHEN UPDATE(SU_TAG_ChangedAt) THEN i.SU_TAG_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TAG_Positor) THEN i.SU_TAG_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        ON
            p.SU_TAG_ID = i.SU_TAG_ID
        WHERE
            i.SU_TAG_Subject_Tag is null
    END
    IF(UPDATE(SU_LVL_ID))
        RAISERROR('The identity column SU_LVL_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LVL_SU_ID))
        RAISERROR('The foreign key column SU_LVL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LVL_Assertion))
        RAISERROR('The computed assertion column SU_LVL_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_LVL_GRD_ID) OR
        UPDATE(SU_LVL_GRD_Grade) OR
        UPDATE(SU_LVL_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_LVL_Subject_Level] (
            Metadata_SU_LVL,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt,
            SU_LVL_PositedAt,
            SU_LVL_Positor,
            SU_LVL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LVL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LVL
            END, i.Metadata_SU),
            ISNULL(i.SU_LVL_SU_ID, i.SU_ID),
            CASE
                WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID
                ELSE [kGRD].GRD_ID
            END,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LVL_ChangedAt) THEN i.SU_LVL_ChangedAt
                WHEN d.SU_LVL_GRD_ID = CASE WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID ELSE [kGRD].GRD_ID END
                THEN i.SU_LVL_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LVL_PositedAt) THEN i.SU_LVL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_LVL_Positor) THEN i.SU_LVL_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_LVL_Reliability) THEN i.SU_LVL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_LVL_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[GRD_Grade] [kGRD]
        ON
            [kGRD].GRD_Grade = i.SU_LVL_GRD_Grade
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            CASE
                WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID
                ELSE [kGRD].GRD_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_LVL_ChangedAt) OR
            UPDATE(SU_LVL_PositedAt) OR
            UPDATE(SU_LVL_Positor) OR
            UPDATE(Positor) OR
            d.SU_LVL_GRD_ID is null OR
            d.SU_LVL_GRD_ID <> CASE WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID ELSE [kGRD].GRD_ID END OR
            d.SU_LVL_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_LVL_Reliability) THEN i.SU_LVL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_LVL_Reliability
            END, 1)
        );
    END
    -- indecisive: another value at the same changing time is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_LVL_GRD_ID) OR
        UPDATE(SU_LVL_GRD_Grade)
    )
    BEGIN
        INSERT INTO [dbo].[SU_LVL_Subject_Level] (
            Metadata_SU_LVL,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt,
            SU_LVL_PositedAt,
            SU_LVL_Positor,
            SU_LVL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LVL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LVL
            END, i.Metadata_SU),
            p.SU_LVL_SU_ID,
            p.SU_LVL_GRD_ID,
            p.SU_LVL_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LVL_PositedAt) THEN i.SU_LVL_PositedAt
            END, @now) as datetime2),
            d.SU_LVL_Positor,
            0
        FROM
            inserted i
        LEFT JOIN
            [dbo].[GRD_Grade] [kGRD]
        ON
            [kGRD].GRD_Grade = i.SU_LVL_GRD_Grade
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_LVL_Subject_Level_Posit] p
        ON
            p.SU_LVL_ID = d.SU_LVL_ID
        WHERE
            p.SU_LVL_GRD_ID <> CASE
                WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID
                ELSE [kGRD].GRD_ID
            END
        AND
            UPDATE(SU_LVL_ChangedAt)
        AND
            p.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
        AND
            d.SU_LVL_Positor = ISNULL(CASE
                WHEN UPDATE(SU_LVL_Positor) THEN i.SU_LVL_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_LVL_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_LVL_PositedAt) THEN i.SU_LVL_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_LVL_Reliability) THEN i.SU_LVL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_LVL_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_LVL_GRD_ID) OR
        UPDATE(SU_LVL_GRD_Grade)
    )
    BEGIN
        INSERT INTO [dbo].[SU_LVL_Subject_Level] (
            Metadata_SU_LVL,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt,
            SU_LVL_PositedAt,
            SU_LVL_Positor,
            SU_LVL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LVL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LVL
            END, i.Metadata_SU),
            p.SU_LVL_SU_ID,
            p.SU_LVL_GRD_ID,
            p.SU_LVL_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LVL_PositedAt) THEN i.SU_LVL_PositedAt
                WHEN UPDATE(SU_LVL_ChangedAt) THEN i.SU_LVL_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_LVL_Positor) THEN i.SU_LVL_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_LVL_Subject_Level_Posit] p
        ON
            p.SU_LVL_ID = i.SU_LVL_ID
        WHERE
            (UPDATE(SU_LVL_GRD_ID) AND i.SU_LVL_GRD_ID is null)
        OR
            (UPDATE(SU_LVL_GRD_Grade) AND i.SU_LVL_GRD_Grade is null);
    END
    IF(UPDATE(SU_TXT_ID))
        RAISERROR('The identity column SU_TXT_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TXT_SU_ID))
        RAISERROR('The foreign key column SU_TXT_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TXT_Assertion))
        RAISERROR('The computed assertion column SU_TXT_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_TXT_Subject_Text) OR
        UPDATE(SU_TXT_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TXT_Subject_Text] (
            Metadata_SU_TXT,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt,
            SU_TXT_PositedAt,
            SU_TXT_Positor,
            SU_TXT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TXT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TXT
            END, i.Metadata_SU),
            ISNULL(i.SU_TXT_SU_ID, i.SU_ID),
            i.SU_TXT_Subject_Text,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TXT_ChangedAt) THEN i.SU_TXT_ChangedAt
                WHEN d.SU_TXT_Checksum = dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
                THEN i.SU_TXT_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TXT_PositedAt) THEN i.SU_TXT_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TXT_Positor) THEN i.SU_TXT_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_TXT_Reliability) THEN i.SU_TXT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TXT_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_TXT_Subject_Text is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_TXT_ChangedAt) OR
            UPDATE(SU_TXT_PositedAt) OR
            UPDATE(SU_TXT_Positor) OR
            UPDATE(Positor) OR
            d.SU_TXT_Subject_Text is null OR
            d.SU_TXT_Checksum <> dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max))) OR
            d.SU_TXT_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_TXT_Reliability) THEN i.SU_TXT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TXT_Reliability
            END, 1)
        )
    END
    -- indecisive: another value at the same changing time is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_TXT_Subject_Text)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TXT_Subject_Text] (
            Metadata_SU_TXT,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt,
            SU_TXT_PositedAt,
            SU_TXT_Positor,
            SU_TXT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TXT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TXT
            END, i.Metadata_SU),
            p.SU_TXT_SU_ID,
            p.SU_TXT_Subject_Text,
            p.SU_TXT_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TXT_PositedAt) THEN i.SU_TXT_PositedAt
            END, @now) as datetime2),
            d.SU_TXT_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_TXT_Subject_Text_Posit] p
        ON
            p.SU_TXT_ID = d.SU_TXT_ID
        WHERE
            p.SU_TXT_Checksum <> dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
        AND
            UPDATE(SU_TXT_ChangedAt)
        AND
            p.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
        AND
            d.SU_TXT_Positor = ISNULL(CASE
                WHEN UPDATE(SU_TXT_Positor) THEN i.SU_TXT_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_TXT_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_TXT_PositedAt) THEN i.SU_TXT_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_TXT_Reliability) THEN i.SU_TXT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TXT_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_TXT_Subject_Text)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TXT_Subject_Text] (
            Metadata_SU_TXT,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt,
            SU_TXT_PositedAt,
            SU_TXT_Positor,
            SU_TXT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TXT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TXT
            END, i.Metadata_SU),
            p.SU_TXT_SU_ID,
            p.SU_TXT_Subject_Text,
            p.SU_TXT_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TXT_PositedAt) THEN i.SU_TXT_PositedAt
                WHEN UPDATE(SU_TXT_ChangedAt) THEN i.SU_TXT_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TXT_Positor) THEN i.SU_TXT_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_TXT_Subject_Text_Posit] p
        ON
            p.SU_TXT_ID = i.SU_TXT_ID
        WHERE
            i.SU_TXT_Subject_Text is null
    END
    IF(UPDATE(SU_ASR_ID))
        RAISERROR('The identity column SU_ASR_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ASR_SU_ID))
        RAISERROR('The foreign key column SU_ASR_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ASR_Assertion))
        RAISERROR('The computed assertion column SU_ASR_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_ASR_Subject_Assessment) OR
        UPDATE(SU_ASR_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
            Metadata_SU_ASR,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt,
            SU_ASR_PositedAt,
            SU_ASR_Positor,
            SU_ASR_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ASR)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ASR
            END, i.Metadata_SU),
            ISNULL(i.SU_ASR_SU_ID, i.SU_ID),
            i.SU_ASR_Subject_Assessment,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ASR_ChangedAt) THEN i.SU_ASR_ChangedAt
                WHEN d.SU_ASR_Subject_Assessment = i.SU_ASR_Subject_Assessment
                THEN i.SU_ASR_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ASR_PositedAt) THEN i.SU_ASR_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_ASR_Positor) THEN i.SU_ASR_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_ASR_Reliability) THEN i.SU_ASR_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_ASR_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_ASR_Subject_Assessment is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_ASR_ChangedAt) OR
            UPDATE(SU_ASR_PositedAt) OR
            UPDATE(SU_ASR_Positor) OR
            UPDATE(Positor) OR
            d.SU_ASR_Subject_Assessment is null OR
            d.SU_ASR_Subject_Assessment <> i.SU_ASR_Subject_Assessment OR
            d.SU_ASR_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_ASR_Reliability) THEN i.SU_ASR_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_ASR_Reliability
            END, 1)
        )
    END
    -- indecisive: another value at the same changing time is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_ASR_Subject_Assessment)
    )
    BEGIN
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
            Metadata_SU_ASR,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt,
            SU_ASR_PositedAt,
            SU_ASR_Positor,
            SU_ASR_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ASR)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ASR
            END, i.Metadata_SU),
            p.SU_ASR_SU_ID,
            p.SU_ASR_Subject_Assessment,
            p.SU_ASR_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ASR_PositedAt) THEN i.SU_ASR_PositedAt
            END, @now) as datetime2),
            d.SU_ASR_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        ON
            p.SU_ASR_ID = d.SU_ASR_ID
        WHERE
            p.SU_ASR_Subject_Assessment <> i.SU_ASR_Subject_Assessment
        AND
            UPDATE(SU_ASR_ChangedAt)
        AND
            p.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
        AND
            d.SU_ASR_Positor = ISNULL(CASE
                WHEN UPDATE(SU_ASR_Positor) THEN i.SU_ASR_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_ASR_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_ASR_PositedAt) THEN i.SU_ASR_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_ASR_Reliability) THEN i.SU_ASR_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_ASR_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_ASR_Subject_Assessment)
    )
    BEGIN
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
            Metadata_SU_ASR,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt,
            SU_ASR_PositedAt,
            SU_ASR_Positor,
            SU_ASR_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ASR)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ASR
            END, i.Metadata_SU),
            p.SU_ASR_SU_ID,
            p.SU_ASR_Subject_Assessment,
            p.SU_ASR_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ASR_PositedAt) THEN i.SU_ASR_PositedAt
                WHEN UPDATE(SU_ASR_ChangedAt) THEN i.SU_ASR_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_ASR_Positor) THEN i.SU_ASR_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        ON
            p.SU_ASR_ID = i.SU_ASR_ID
        WHERE
            i.SU_ASR_Subject_Assessment is null
    END
    IF(UPDATE(SU_ERS_ID))
        RAISERROR('The identity column SU_ERS_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ERS_SU_ID))
        RAISERROR('The foreign key column SU_ERS_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ERS_Assertion))
        RAISERROR('The computed assertion column SU_ERS_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_ERS_Subject_Erasable) OR
        UPDATE(SU_ERS_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
            Metadata_SU_ERS,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt,
            SU_ERS_PositedAt,
            SU_ERS_Positor,
            SU_ERS_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ERS)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ERS
            END, i.Metadata_SU),
            ISNULL(i.SU_ERS_SU_ID, i.SU_ID),
            i.SU_ERS_Subject_Erasable,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ERS_ChangedAt) THEN i.SU_ERS_ChangedAt
                WHEN d.SU_ERS_Subject_Erasable = i.SU_ERS_Subject_Erasable
                THEN i.SU_ERS_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ERS_PositedAt) THEN i.SU_ERS_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_ERS_Positor) THEN i.SU_ERS_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_ERS_Reliability) THEN i.SU_ERS_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_ERS_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_ERS_Subject_Erasable is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_ERS_ChangedAt) OR
            UPDATE(SU_ERS_PositedAt) OR
            UPDATE(SU_ERS_Positor) OR
            UPDATE(Positor) OR
            d.SU_ERS_Subject_Erasable is null OR
            d.SU_ERS_Subject_Erasable <> i.SU_ERS_Subject_Erasable OR
            d.SU_ERS_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_ERS_Reliability) THEN i.SU_ERS_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_ERS_Reliability
            END, 1)
        )
    END
    -- indecisive: another value at the same changing time is a correction, which also retracts the shown one
    IF (
        UPDATE(SU_ERS_Subject_Erasable)
    )
    BEGIN
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
            Metadata_SU_ERS,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt,
            SU_ERS_PositedAt,
            SU_ERS_Positor,
            SU_ERS_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ERS)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ERS
            END, i.Metadata_SU),
            p.SU_ERS_SU_ID,
            p.SU_ERS_Subject_Erasable,
            p.SU_ERS_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ERS_PositedAt) THEN i.SU_ERS_PositedAt
            END, @now) as datetime2),
            d.SU_ERS_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        ON
            p.SU_ERS_ID = d.SU_ERS_ID
        WHERE
            p.SU_ERS_Subject_Erasable <> i.SU_ERS_Subject_Erasable
        AND
            UPDATE(SU_ERS_ChangedAt)
        AND
            p.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
        AND
            d.SU_ERS_Positor = ISNULL(CASE
                WHEN UPDATE(SU_ERS_Positor) THEN i.SU_ERS_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.SU_ERS_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(SU_ERS_PositedAt) THEN i.SU_ERS_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(SU_ERS_Reliability) THEN i.SU_ERS_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_ERS_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_ERS_Subject_Erasable)
    )
    BEGIN
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
            Metadata_SU_ERS,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt,
            SU_ERS_PositedAt,
            SU_ERS_Positor,
            SU_ERS_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ERS)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ERS
            END, i.Metadata_SU),
            p.SU_ERS_SU_ID,
            p.SU_ERS_Subject_Erasable,
            p.SU_ERS_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ERS_PositedAt) THEN i.SU_ERS_PositedAt
                WHEN UPDATE(SU_ERS_ChangedAt) THEN i.SU_ERS_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_ERS_Positor) THEN i.SU_ERS_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        ON
            p.SU_ERS_ID = i.SU_ERS_ID
        WHERE
            i.SU_ERS_Subject_Erasable is null
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_Subject instead of DELETE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lSU_Subject] ON [dbo].[lSU_Subject]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_NAM_Subject_Name_Annex] (
        Metadata_SU_NAM,
        SU_NAM_ID,
        SU_NAM_Positor,
        SU_NAM_PositedAt,
        SU_NAM_Reliability
    )
    SELECT
        d.Metadata_SU_NAM,
        d.SU_NAM_ID,
        d.SU_NAM_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_NAM_ID is not null;
    INSERT INTO [dbo].[SU_COD_Subject_Code_Annex] (
        Metadata_SU_COD,
        SU_COD_ID,
        SU_COD_Positor,
        SU_COD_PositedAt,
        SU_COD_Reliability
    )
    SELECT
        d.Metadata_SU_COD,
        d.SU_COD_ID,
        d.SU_COD_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_COD_ID is not null;
    INSERT INTO [dbo].[SU_GRD_Subject_Grade_Annex] (
        Metadata_SU_GRD,
        SU_GRD_ID,
        SU_GRD_Positor,
        SU_GRD_PositedAt,
        SU_GRD_Reliability
    )
    SELECT
        d.Metadata_SU_GRD,
        d.SU_GRD_ID,
        d.SU_GRD_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_GRD_ID is not null;
    INSERT INTO [dbo].[SU_NOT_Subject_Note_Annex] (
        Metadata_SU_NOT,
        SU_NOT_ID,
        SU_NOT_Positor,
        SU_NOT_PositedAt,
        SU_NOT_Reliability
    )
    SELECT
        d.Metadata_SU_NOT,
        d.SU_NOT_ID,
        d.SU_NOT_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_NOT_ID is not null;
    INSERT INTO [dbo].[SU_TTL_Subject_Title_Annex] (
        Metadata_SU_TTL,
        SU_TTL_ID,
        SU_TTL_Positor,
        SU_TTL_PositedAt,
        SU_TTL_Reliability
    )
    SELECT
        d.Metadata_SU_TTL,
        d.SU_TTL_ID,
        d.SU_TTL_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_TTL_ID is not null;
    INSERT INTO [dbo].[SU_STA_Subject_State_Annex] (
        Metadata_SU_STA,
        SU_STA_ID,
        SU_STA_Positor,
        SU_STA_PositedAt,
        SU_STA_Reliability
    )
    SELECT
        d.Metadata_SU_STA,
        d.SU_STA_ID,
        d.SU_STA_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_STA_ID is not null;
    INSERT INTO [dbo].[SU_LBL_Subject_Label_Annex] (
        Metadata_SU_LBL,
        SU_LBL_ID,
        SU_LBL_Positor,
        SU_LBL_PositedAt,
        SU_LBL_Reliability
    )
    SELECT
        d.Metadata_SU_LBL,
        d.SU_LBL_ID,
        d.SU_LBL_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_LBL_ID is not null;
    INSERT INTO [dbo].[SU_TAG_Subject_Tag_Annex] (
        Metadata_SU_TAG,
        SU_TAG_ID,
        SU_TAG_Positor,
        SU_TAG_PositedAt,
        SU_TAG_Reliability
    )
    SELECT
        d.Metadata_SU_TAG,
        d.SU_TAG_ID,
        d.SU_TAG_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_TAG_ID is not null;
    INSERT INTO [dbo].[SU_LVL_Subject_Level_Annex] (
        Metadata_SU_LVL,
        SU_LVL_ID,
        SU_LVL_Positor,
        SU_LVL_PositedAt,
        SU_LVL_Reliability
    )
    SELECT
        d.Metadata_SU_LVL,
        d.SU_LVL_ID,
        d.SU_LVL_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_LVL_ID is not null;
    INSERT INTO [dbo].[SU_TXT_Subject_Text_Annex] (
        Metadata_SU_TXT,
        SU_TXT_ID,
        SU_TXT_Positor,
        SU_TXT_PositedAt,
        SU_TXT_Reliability
    )
    SELECT
        d.Metadata_SU_TXT,
        d.SU_TXT_ID,
        d.SU_TXT_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_TXT_ID is not null;
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment_Annex] (
        Metadata_SU_ASR,
        SU_ASR_ID,
        SU_ASR_Positor,
        SU_ASR_PositedAt,
        SU_ASR_Reliability
    )
    SELECT
        d.Metadata_SU_ASR,
        d.SU_ASR_ID,
        d.SU_ASR_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_ASR_ID is not null;
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable_Annex] (
        Metadata_SU_ERS,
        SU_ERS_ID,
        SU_ERS_Positor,
        SU_ERS_PositedAt,
        SU_ERS_Reliability
    )
    SELECT
        d.Metadata_SU_ERS,
        d.SU_ERS_ID,
        d.SU_ERS_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_ERS_ID is not null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_Object instead of INSERT trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lOB_Object] ON [dbo].[lOB_Object]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @OB TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        OB_ID int not null
    );
    INSERT INTO [dbo].[OB_Object] (
        Metadata_OB
    )
    OUTPUT
        inserted.OB_ID
    INTO
        @OB
    SELECT
        Metadata_OB
    FROM
        inserted
    WHERE
        inserted.OB_ID is null;
    DECLARE @inserted TABLE (
        OB_ID int not null,
        Metadata_OB int not null,
        OB_NAM_OB_ID int null,
        Metadata_OB_NAM int null,
        OB_NAM_Positor tinyint null,
        OB_NAM_PositedAt datetime2 null,
        OB_NAM_Reliability decimal(5,2) null,
        OB_NAM_Object_Name nvarchar(42) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.OB_ID, a.OB_ID),
        i.Metadata_OB,
        ISNULL(ISNULL(i.OB_NAM_OB_ID, i.OB_ID), a.OB_ID),
        ISNULL(i.Metadata_OB_NAM, i.Metadata_OB),
        ISNULL(ISNULL(i.OB_NAM_Positor, i.Positor), 0),
        ISNULL(i.OB_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.OB_NAM_Reliability, i.Reliability), 1),
        i.OB_NAM_Object_Name
    FROM (
        SELECT
            Positor,
            Reliability,
            OB_ID,
            Metadata_OB,
            OB_NAM_OB_ID,
            Metadata_OB_NAM,
            OB_NAM_Positor,
            OB_NAM_PositedAt,
            OB_NAM_Reliability,
            OB_NAM_Object_Name,
            ROW_NUMBER() OVER (PARTITION BY OB_ID ORDER BY OB_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @OB a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[OB_NAM_Object_Name] (
        Metadata_OB_NAM,
        OB_NAM_OB_ID,
        OB_NAM_Object_Name,
        OB_NAM_PositedAt,
        OB_NAM_Positor,
        OB_NAM_Reliability
    )
    SELECT
        i.Metadata_OB_NAM,
        i.OB_NAM_OB_ID,
        i.OB_NAM_Object_Name,
        i.OB_NAM_PositedAt,
        i.OB_NAM_Positor,
        i.OB_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.OB_NAM_Object_Name is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_Object instead of UPDATE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lOB_Object] ON [dbo].[lOB_Object]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(OB_ID))
        RAISERROR('The identity column OB_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_NAM_ID))
        RAISERROR('The identity column OB_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_NAM_OB_ID))
        RAISERROR('The foreign key column OB_NAM_OB_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_NAM_Assertion))
        RAISERROR('The computed assertion column OB_NAM_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(OB_NAM_Object_Name) OR
        UPDATE(OB_NAM_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[OB_NAM_Object_Name] (
            Metadata_OB_NAM,
            OB_NAM_OB_ID,
            OB_NAM_Object_Name,
            OB_NAM_PositedAt,
            OB_NAM_Positor,
            OB_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_OB) AND NOT UPDATE(Metadata_OB_NAM)
                THEN i.Metadata_OB
                ELSE i.Metadata_OB_NAM
            END, i.Metadata_OB),
            ISNULL(i.OB_NAM_OB_ID, i.OB_ID),
            i.OB_NAM_Object_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(OB_NAM_PositedAt) THEN i.OB_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(OB_NAM_Positor) THEN i.OB_NAM_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(OB_NAM_Reliability) THEN i.OB_NAM_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.OB_NAM_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.OB_ID = i.OB_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.OB_NAM_Object_Name is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(OB_NAM_PositedAt) OR
            UPDATE(OB_NAM_Positor) OR
            UPDATE(Positor) OR
            d.OB_NAM_Object_Name is null OR
            d.OB_NAM_Object_Name <> i.OB_NAM_Object_Name OR
            d.OB_NAM_Reliability <> ISNULL(CASE
                WHEN UPDATE(OB_NAM_Reliability) THEN i.OB_NAM_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.OB_NAM_Reliability
            END, 1)
        )
    END
    -- indecisive: another value is a correction, which also retracts the shown one
    IF (
        UPDATE(OB_NAM_Object_Name)
    )
    BEGIN
        INSERT INTO [dbo].[OB_NAM_Object_Name] (
            Metadata_OB_NAM,
            OB_NAM_OB_ID,
            OB_NAM_Object_Name,
            OB_NAM_PositedAt,
            OB_NAM_Positor,
            OB_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_OB) AND NOT UPDATE(Metadata_OB_NAM)
                THEN i.Metadata_OB
                ELSE i.Metadata_OB_NAM
            END, i.Metadata_OB),
            p.OB_NAM_OB_ID,
            p.OB_NAM_Object_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(OB_NAM_PositedAt) THEN i.OB_NAM_PositedAt
            END, @now) as datetime2),
            d.OB_NAM_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.OB_ID = i.OB_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[OB_NAM_Object_Name_Posit] p
        ON
            p.OB_NAM_ID = d.OB_NAM_ID
        WHERE
            p.OB_NAM_Object_Name <> i.OB_NAM_Object_Name
        AND
            d.OB_NAM_Positor = ISNULL(CASE
                WHEN UPDATE(OB_NAM_Positor) THEN i.OB_NAM_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.OB_NAM_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(OB_NAM_PositedAt) THEN i.OB_NAM_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(OB_NAM_Reliability) THEN i.OB_NAM_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.OB_NAM_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(OB_NAM_Object_Name)
    )
    BEGIN
        INSERT INTO [dbo].[OB_NAM_Object_Name] (
            Metadata_OB_NAM,
            OB_NAM_OB_ID,
            OB_NAM_Object_Name,
            OB_NAM_PositedAt,
            OB_NAM_Positor,
            OB_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_OB) AND NOT UPDATE(Metadata_OB_NAM)
                THEN i.Metadata_OB
                ELSE i.Metadata_OB_NAM
            END, i.Metadata_OB),
            p.OB_NAM_OB_ID,
            p.OB_NAM_Object_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(OB_NAM_PositedAt) THEN i.OB_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(OB_NAM_Positor) THEN i.OB_NAM_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[OB_NAM_Object_Name_Posit] p
        ON
            p.OB_NAM_ID = i.OB_NAM_ID
        WHERE
            i.OB_NAM_Object_Name is null
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_Object instead of DELETE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lOB_Object] ON [dbo].[lOB_Object]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[OB_NAM_Object_Name_Annex] (
        Metadata_OB_NAM,
        OB_NAM_ID,
        OB_NAM_Positor,
        OB_NAM_PositedAt,
        OB_NAM_Reliability
    )
    SELECT
        d.Metadata_OB_NAM,
        d.OB_NAM_ID,
        d.OB_NAM_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.OB_NAM_ID is not null;
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
        EV_QTY_EV_ID int null,
        Metadata_EV_QTY int null,
        EV_QTY_Positor tinyint null,
        EV_QTY_PositedAt datetime2 null,
        EV_QTY_Reliability decimal(5,2) null,
        EV_QTY_Event_Quantity int null,
        EV_PLC_EV_ID int null,
        Metadata_EV_PLC int null,
        EV_PLC_ChangedAt datetime2 null,
        EV_PLC_Positor tinyint null,
        EV_PLC_PositedAt datetime2 null,
        EV_PLC_Reliability decimal(5,2) null,
        EV_PLC_Event_Place nvarchar(42) null
    );
    -- a nexus row for each row without an identity; the merge outputs every new identity together with the values of
    -- the row it was made for, so each new row keeps its own attributes, also when several are inserted at once
    MERGE INTO [dbo].[EV_Event]
    USING inserted AS i
    ON 1 = 0
    WHEN NOT MATCHED AND i.EV_ID is null THEN INSERT (
        SU_ID_for,
        Metadata_EV 
    )
    VALUES (
        i.SU_ID_for,
        i.Metadata_EV 
    )
    OUTPUT
        inserted.EV_ID,
        i.Metadata_EV,
        ISNULL(i.EV_QTY_EV_ID, inserted.EV_ID),
        ISNULL(i.Metadata_EV_QTY, i.Metadata_EV),
        ISNULL(ISNULL(i.EV_QTY_Positor, i.Positor), 0),
        ISNULL(i.EV_QTY_PositedAt, @now),
        ISNULL(ISNULL(i.EV_QTY_Reliability, i.Reliability), 1),
        i.EV_QTY_Event_Quantity,
        ISNULL(i.EV_PLC_EV_ID, inserted.EV_ID),
        ISNULL(i.Metadata_EV_PLC, i.Metadata_EV),
        ISNULL(i.EV_PLC_ChangedAt, @now),
        ISNULL(ISNULL(i.EV_PLC_Positor, i.Positor), 0),
        ISNULL(i.EV_PLC_PositedAt, @now),
        ISNULL(ISNULL(i.EV_PLC_Reliability, i.Reliability), 1),
        i.EV_PLC_Event_Place
    INTO
        @inserted;
    -- the rows that come with the identity of a nexus row
    INSERT INTO @inserted
    SELECT
        i.EV_ID,
        i.Metadata_EV,
        ISNULL(i.EV_QTY_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_QTY, i.Metadata_EV),
        ISNULL(ISNULL(i.EV_QTY_Positor, i.Positor), 0),
        ISNULL(i.EV_QTY_PositedAt, @now),
        ISNULL(ISNULL(i.EV_QTY_Reliability, i.Reliability), 1),
        i.EV_QTY_Event_Quantity,
        ISNULL(i.EV_PLC_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_PLC, i.Metadata_EV),
        ISNULL(i.EV_PLC_ChangedAt, @now),
        ISNULL(ISNULL(i.EV_PLC_Positor, i.Positor), 0),
        ISNULL(i.EV_PLC_PositedAt, @now),
        ISNULL(ISNULL(i.EV_PLC_Reliability, i.Reliability), 1),
        i.EV_PLC_Event_Place
    FROM
        inserted i
    WHERE
        i.EV_ID is not null;
    INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
        Metadata_EV_QTY,
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity,
        EV_QTY_PositedAt,
        EV_QTY_Positor,
        EV_QTY_Reliability
    )
    SELECT
        i.Metadata_EV_QTY,
        i.EV_QTY_EV_ID,
        i.EV_QTY_Event_Quantity,
        i.EV_QTY_PositedAt,
        i.EV_QTY_Positor,
        i.EV_QTY_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_QTY_Event_Quantity is not null;
    INSERT INTO [dbo].[EV_PLC_Event_Place] (
        Metadata_EV_PLC,
        EV_PLC_EV_ID,
        EV_PLC_Event_Place,
        EV_PLC_ChangedAt,
        EV_PLC_PositedAt,
        EV_PLC_Positor,
        EV_PLC_Reliability
    )
    SELECT
        i.Metadata_EV_PLC,
        i.EV_PLC_EV_ID,
        i.EV_PLC_Event_Place,
        i.EV_PLC_ChangedAt,
        i.EV_PLC_PositedAt,
        i.EV_PLC_Positor,
        i.EV_PLC_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_PLC_Event_Place is not null;
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
    IF(UPDATE(EV_ID))
        RAISERROR('The identity column EV_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ID_for))
        RAISERROR('The role column SU_ID_for is not updatable.', 16, 1);
    IF(UPDATE(EV_QTY_ID))
        RAISERROR('The identity column EV_QTY_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_QTY_EV_ID))
        RAISERROR('The foreign key column EV_QTY_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_QTY_Assertion))
        RAISERROR('The computed assertion column EV_QTY_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(EV_QTY_Event_Quantity) OR
        UPDATE(EV_QTY_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
            Metadata_EV_QTY,
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity,
            EV_QTY_PositedAt,
            EV_QTY_Positor,
            EV_QTY_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_QTY)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_QTY
            END, i.Metadata_EV),
            ISNULL(i.EV_QTY_EV_ID, i.EV_ID),
            i.EV_QTY_Event_Quantity,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_QTY_PositedAt) THEN i.EV_QTY_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_QTY_Positor) THEN i.EV_QTY_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(EV_QTY_Reliability) THEN i.EV_QTY_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_QTY_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.EV_QTY_Event_Quantity is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(EV_QTY_PositedAt) OR
            UPDATE(EV_QTY_Positor) OR
            UPDATE(Positor) OR
            d.EV_QTY_Event_Quantity is null OR
            d.EV_QTY_Event_Quantity <> i.EV_QTY_Event_Quantity OR
            d.EV_QTY_Reliability <> ISNULL(CASE
                WHEN UPDATE(EV_QTY_Reliability) THEN i.EV_QTY_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_QTY_Reliability
            END, 1)
        )
    END
    -- indecisive: another value is a correction, which also retracts the shown one
    IF (
        UPDATE(EV_QTY_Event_Quantity)
    )
    BEGIN
        INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
            Metadata_EV_QTY,
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity,
            EV_QTY_PositedAt,
            EV_QTY_Positor,
            EV_QTY_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_QTY)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_QTY
            END, i.Metadata_EV),
            p.EV_QTY_EV_ID,
            p.EV_QTY_Event_Quantity,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_QTY_PositedAt) THEN i.EV_QTY_PositedAt
            END, @now) as datetime2),
            d.EV_QTY_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        ON
            p.EV_QTY_ID = d.EV_QTY_ID
        WHERE
            p.EV_QTY_Event_Quantity <> i.EV_QTY_Event_Quantity
        AND
            d.EV_QTY_Positor = ISNULL(CASE
                WHEN UPDATE(EV_QTY_Positor) THEN i.EV_QTY_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.EV_QTY_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(EV_QTY_PositedAt) THEN i.EV_QTY_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(EV_QTY_Reliability) THEN i.EV_QTY_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_QTY_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(EV_QTY_Event_Quantity)
    )
    BEGIN
        INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
            Metadata_EV_QTY,
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity,
            EV_QTY_PositedAt,
            EV_QTY_Positor,
            EV_QTY_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_QTY)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_QTY
            END, i.Metadata_EV),
            p.EV_QTY_EV_ID,
            p.EV_QTY_Event_Quantity,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_QTY_PositedAt) THEN i.EV_QTY_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_QTY_Positor) THEN i.EV_QTY_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        ON
            p.EV_QTY_ID = i.EV_QTY_ID
        WHERE
            i.EV_QTY_Event_Quantity is null
    END
    IF(UPDATE(EV_PLC_ID))
        RAISERROR('The identity column EV_PLC_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_PLC_EV_ID))
        RAISERROR('The foreign key column EV_PLC_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_PLC_Assertion))
        RAISERROR('The computed assertion column EV_PLC_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(EV_PLC_Event_Place) OR
        UPDATE(EV_PLC_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[EV_PLC_Event_Place] (
            Metadata_EV_PLC,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt,
            EV_PLC_PositedAt,
            EV_PLC_Positor,
            EV_PLC_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_PLC)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_PLC
            END, i.Metadata_EV),
            ISNULL(i.EV_PLC_EV_ID, i.EV_ID),
            i.EV_PLC_Event_Place,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_PLC_ChangedAt) THEN i.EV_PLC_ChangedAt
                WHEN d.EV_PLC_Event_Place = i.EV_PLC_Event_Place
                THEN i.EV_PLC_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(EV_PLC_PositedAt) THEN i.EV_PLC_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_PLC_Positor) THEN i.EV_PLC_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(EV_PLC_Reliability) THEN i.EV_PLC_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_PLC_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.EV_PLC_Event_Place is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(EV_PLC_ChangedAt) OR
            UPDATE(EV_PLC_PositedAt) OR
            UPDATE(EV_PLC_Positor) OR
            UPDATE(Positor) OR
            d.EV_PLC_Event_Place is null OR
            d.EV_PLC_Event_Place <> i.EV_PLC_Event_Place OR
            d.EV_PLC_Reliability <> ISNULL(CASE
                WHEN UPDATE(EV_PLC_Reliability) THEN i.EV_PLC_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_PLC_Reliability
            END, 1)
        )
    END
    -- indecisive: another value at the same changing time is a correction, which also retracts the shown one
    IF (
        UPDATE(EV_PLC_Event_Place)
    )
    BEGIN
        INSERT INTO [dbo].[EV_PLC_Event_Place] (
            Metadata_EV_PLC,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt,
            EV_PLC_PositedAt,
            EV_PLC_Positor,
            EV_PLC_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_PLC)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_PLC
            END, i.Metadata_EV),
            p.EV_PLC_EV_ID,
            p.EV_PLC_Event_Place,
            p.EV_PLC_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_PLC_PositedAt) THEN i.EV_PLC_PositedAt
            END, @now) as datetime2),
            d.EV_PLC_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[EV_PLC_Event_Place_Posit] p
        ON
            p.EV_PLC_ID = d.EV_PLC_ID
        WHERE
            p.EV_PLC_Event_Place <> i.EV_PLC_Event_Place
        AND
            UPDATE(EV_PLC_ChangedAt)
        AND
            p.EV_PLC_ChangedAt = i.EV_PLC_ChangedAt
        AND
            d.EV_PLC_Positor = ISNULL(CASE
                WHEN UPDATE(EV_PLC_Positor) THEN i.EV_PLC_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.EV_PLC_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(EV_PLC_PositedAt) THEN i.EV_PLC_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(EV_PLC_Reliability) THEN i.EV_PLC_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_PLC_Reliability
            END, 1) > 0;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(EV_PLC_Event_Place)
    )
    BEGIN
        INSERT INTO [dbo].[EV_PLC_Event_Place] (
            Metadata_EV_PLC,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt,
            EV_PLC_PositedAt,
            EV_PLC_Positor,
            EV_PLC_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_PLC)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_PLC
            END, i.Metadata_EV),
            p.EV_PLC_EV_ID,
            p.EV_PLC_Event_Place,
            p.EV_PLC_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_PLC_PositedAt) THEN i.EV_PLC_PositedAt
                WHEN UPDATE(EV_PLC_ChangedAt) THEN i.EV_PLC_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_PLC_Positor) THEN i.EV_PLC_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[EV_PLC_Event_Place_Posit] p
        ON
            p.EV_PLC_ID = i.EV_PLC_ID
        WHERE
            i.EV_PLC_Event_Place is null
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
    INSERT INTO [dbo].[EV_QTY_Event_Quantity_Annex] (
        Metadata_EV_QTY,
        EV_QTY_ID,
        EV_QTY_Positor,
        EV_QTY_PositedAt,
        EV_QTY_Reliability
    )
    SELECT
        d.Metadata_EV_QTY,
        d.EV_QTY_ID,
        d.EV_QTY_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_QTY_ID is not null;
    INSERT INTO [dbo].[EV_PLC_Event_Place_Annex] (
        Metadata_EV_PLC,
        EV_PLC_ID,
        EV_PLC_Positor,
        EV_PLC_PositedAt,
        EV_PLC_Reliability
    )
    SELECT
        d.Metadata_EV_PLC,
        d.EV_PLC_ID,
        d.EV_PLC_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_PLC_ID is not null;
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
-- SU_holder_OB_item_GRD_grade_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_holder_OB_item_GRD_grade_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_holder_OB_item_GRD_grade_Posit] (
    SU_holder_OB_item_GRD_grade_ID int IDENTITY(1,1) not null,
    SU_ID_holder int not null,
    OB_ID_item int not null,
    GRD_ID_grade tinyint not null,
    SU_holder_OB_item_GRD_grade_ChangedAt datetime2 not null,
    constraint SU_holder_OB_item_GRD_grade_Posit_fkSU_holder foreign key (
        SU_ID_holder
    ) references [dbo].[SU_Subject](SU_ID),
    constraint SU_holder_OB_item_GRD_grade_Posit_fkOB_item foreign key (
        OB_ID_item
    ) references [dbo].[OB_Object](OB_ID),
    constraint SU_holder_OB_item_GRD_grade_Posit_fkGRD_grade foreign key (
        GRD_ID_grade
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_holder_OB_item_GRD_grade_Posit primary key nonclustered (
        SU_holder_OB_item_GRD_grade_ID asc
    ),
    constraint uqSU_holder_OB_item_GRD_grade unique clustered (
        SU_ID_holder asc,
        OB_ID_item asc,
        SU_holder_OB_item_GRD_grade_ChangedAt desc,
        GRD_ID_grade asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- SU_holder_OB_item_GRD_grade_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_holder_OB_item_GRD_grade_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
    SU_holder_OB_item_GRD_grade_ID int not null,
    SU_holder_OB_item_GRD_grade_PositedAt datetime2 not null,
    SU_holder_OB_item_GRD_grade_Positor tinyint not null,
    SU_holder_OB_item_GRD_grade_Reliability decimal(5,2) not null,
    SU_holder_OB_item_GRD_grade_Assertion as cast(
        case
            when SU_holder_OB_item_GRD_grade_Reliability > 0 then '+'
            when SU_holder_OB_item_GRD_grade_Reliability = 0 then '?'
            when SU_holder_OB_item_GRD_grade_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_holder_OB_item_GRD_grade int not null,
    constraint fkSU_holder_OB_item_GRD_grade_Annex foreign key (
        SU_holder_OB_item_GRD_grade_ID
    ) references [dbo].[SU_holder_OB_item_GRD_grade_Posit](SU_holder_OB_item_GRD_grade_ID),
    constraint pkSU_holder_OB_item_GRD_grade_Annex primary key clustered (
        SU_holder_OB_item_GRD_grade_ID asc,
        SU_holder_OB_item_GRD_grade_Positor asc,
        SU_holder_OB_item_GRD_grade_PositedAt desc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_keeper_OB_thing_GRD_rank_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] (
    SU_keeper_OB_thing_GRD_rank_ID int IDENTITY(1,1) not null,
    SU_ID_keeper int not null,
    OB_ID_thing int not null,
    GRD_ID_rank tinyint not null,
    SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
    constraint SU_keeper_OB_thing_GRD_rank_Posit_fkSU_keeper foreign key (
        SU_ID_keeper
    ) references [dbo].[SU_Subject](SU_ID),
    constraint SU_keeper_OB_thing_GRD_rank_Posit_fkOB_thing foreign key (
        OB_ID_thing
    ) references [dbo].[OB_Object](OB_ID),
    constraint SU_keeper_OB_thing_GRD_rank_Posit_fkGRD_rank foreign key (
        GRD_ID_rank
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_keeper_OB_thing_GRD_rank_Posit primary key nonclustered (
        SU_keeper_OB_thing_GRD_rank_ID asc
    ),
    constraint uqSU_keeper_OB_thing_GRD_rank unique clustered (
        SU_ID_keeper asc,
        OB_ID_thing asc,
        SU_keeper_OB_thing_GRD_rank_ChangedAt desc,
        GRD_ID_rank asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_keeper_OB_thing_GRD_rank_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
    SU_keeper_OB_thing_GRD_rank_ID int not null,
    SU_keeper_OB_thing_GRD_rank_PositedAt datetime2 not null,
    SU_keeper_OB_thing_GRD_rank_Positor tinyint not null,
    SU_keeper_OB_thing_GRD_rank_Reliability decimal(5,2) not null,
    SU_keeper_OB_thing_GRD_rank_Assertion as cast(
        case
            when SU_keeper_OB_thing_GRD_rank_Reliability > 0 then '+'
            when SU_keeper_OB_thing_GRD_rank_Reliability = 0 then '?'
            when SU_keeper_OB_thing_GRD_rank_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_keeper_OB_thing_GRD_rank int not null,
    constraint fkSU_keeper_OB_thing_GRD_rank_Annex foreign key (
        SU_keeper_OB_thing_GRD_rank_ID
    ) references [dbo].[SU_keeper_OB_thing_GRD_rank_Posit](SU_keeper_OB_thing_GRD_rank_ID),
    constraint pkSU_keeper_OB_thing_GRD_rank_Annex primary key clustered (
        SU_keeper_OB_thing_GRD_rank_ID asc,
        SU_keeper_OB_thing_GRD_rank_Positor asc,
        SU_keeper_OB_thing_GRD_rank_PositedAt desc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- OB_part_SU_owner_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_part_SU_owner_Posit', 'U') IS NULL
CREATE TABLE [dbo].[OB_part_SU_owner_Posit] (
    OB_part_SU_owner_ID int IDENTITY(1,1) not null,
    OB_ID_part int not null,
    SU_ID_owner int not null,
    constraint OB_part_SU_owner_Posit_fkOB_part foreign key (
        OB_ID_part
    ) references [dbo].[OB_Object](OB_ID),
    constraint OB_part_SU_owner_Posit_fkSU_owner foreign key (
        SU_ID_owner
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkOB_part_SU_owner_Posit primary key nonclustered (
        OB_part_SU_owner_ID asc
    ),
    constraint uqOB_part_SU_owner unique clustered (
        OB_ID_part asc,
        SU_ID_owner asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- OB_part_SU_owner_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_part_SU_owner_Annex', 'U') IS NULL
CREATE TABLE [dbo].[OB_part_SU_owner_Annex] (
    OB_part_SU_owner_ID int not null,
    OB_part_SU_owner_PositedAt datetime2 not null,
    OB_part_SU_owner_Positor tinyint not null,
    OB_part_SU_owner_Reliability decimal(5,2) not null,
    OB_part_SU_owner_Assertion as cast(
        case
            when OB_part_SU_owner_Reliability > 0 then '+'
            when OB_part_SU_owner_Reliability = 0 then '?'
            when OB_part_SU_owner_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_OB_part_SU_owner int not null,
    constraint fkOB_part_SU_owner_Annex foreign key (
        OB_part_SU_owner_ID
    ) references [dbo].[OB_part_SU_owner_Posit](OB_part_SU_owner_ID),
    constraint pkOB_part_SU_owner_Annex primary key clustered (
        OB_part_SU_owner_ID asc,
        OB_part_SU_owner_Positor asc,
        OB_part_SU_owner_PositedAt desc
    )
);
GO
-- Historized tie table -----------------------------------------------------------------------------------------------
-- SU_partner_SU_with_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_partner_SU_with_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_partner_SU_with_Posit] (
    SU_partner_SU_with_ID int IDENTITY(1,1) not null,
    SU_ID_partner int not null,
    SU_ID_with int not null,
    SU_partner_SU_with_ChangedAt datetime2 not null,
    constraint SU_partner_SU_with_Posit_fkSU_partner foreign key (
        SU_ID_partner
    ) references [dbo].[SU_Subject](SU_ID),
    constraint SU_partner_SU_with_Posit_fkSU_with foreign key (
        SU_ID_with
    ) references [dbo].[SU_Subject](SU_ID),
    constraint SU_partner_SU_with_Posit_uqSU_partner unique (
        SU_ID_partner,
        SU_partner_SU_with_ChangedAt
    ),
    constraint SU_partner_SU_with_Posit_uqSU_with unique (
        SU_ID_with,
        SU_partner_SU_with_ChangedAt
    ),
    constraint pkSU_partner_SU_with_Posit primary key nonclustered (
        SU_partner_SU_with_ID asc
    ),
    constraint uqSU_partner_SU_with unique clustered (
        SU_partner_SU_with_ChangedAt desc,
        SU_ID_partner asc,
        SU_ID_with asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- SU_partner_SU_with_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_partner_SU_with_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_partner_SU_with_Annex] (
    SU_partner_SU_with_ID int not null,
    SU_partner_SU_with_PositedAt datetime2 not null,
    SU_partner_SU_with_Positor tinyint not null,
    SU_partner_SU_with_Reliability decimal(5,2) not null,
    SU_partner_SU_with_Assertion as cast(
        case
            when SU_partner_SU_with_Reliability > 0 then '+'
            when SU_partner_SU_with_Reliability = 0 then '?'
            when SU_partner_SU_with_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_SU_partner_SU_with int not null,
    constraint fkSU_partner_SU_with_Annex foreign key (
        SU_partner_SU_with_ID
    ) references [dbo].[SU_partner_SU_with_Posit](SU_partner_SU_with_ID),
    constraint pkSU_partner_SU_with_Annex primary key clustered (
        SU_partner_SU_with_ID asc,
        SU_partner_SU_with_Positor asc,
        SU_partner_SU_with_PositedAt desc
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
-- SU_holder_OB_item_GRD_grade assembled view of the posit and annex tables,
-- pkSU_holder_OB_item_GRD_grade optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_holder_OB_item_GRD_grade', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_holder_OB_item_GRD_grade]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_holder_OB_item_GRD_grade,
        p.SU_holder_OB_item_GRD_grade_ID,
        p.SU_ID_holder,
        p.OB_ID_item,
        p.GRD_ID_grade,
        p.SU_holder_OB_item_GRD_grade_ChangedAt,
        a.SU_holder_OB_item_GRD_grade_PositedAt,
        a.SU_holder_OB_item_GRD_grade_Positor,
        a.SU_holder_OB_item_GRD_grade_Reliability,
        a.SU_holder_OB_item_GRD_grade_Assertion
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
    JOIN
        [dbo].[SU_holder_OB_item_GRD_grade_Annex] a
    ON
        a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_holder_OB_item_GRD_grade]
    ON [dbo].[SU_holder_OB_item_GRD_grade] (
        SU_holder_OB_item_GRD_grade_ID asc,
        SU_holder_OB_item_GRD_grade_PositedAt desc,
        SU_holder_OB_item_GRD_grade_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank assembled view of the posit and annex tables,
-- pkSU_keeper_OB_thing_GRD_rank optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_keeper_OB_thing_GRD_rank', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_keeper_OB_thing_GRD_rank]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ID,
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank,
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        a.SU_keeper_OB_thing_GRD_rank_PositedAt,
        a.SU_keeper_OB_thing_GRD_rank_Positor,
        a.SU_keeper_OB_thing_GRD_rank_Reliability,
        a.SU_keeper_OB_thing_GRD_rank_Assertion
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
    ON
        a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_keeper_OB_thing_GRD_rank]
    ON [dbo].[SU_keeper_OB_thing_GRD_rank] (
        SU_keeper_OB_thing_GRD_rank_ID asc,
        SU_keeper_OB_thing_GRD_rank_PositedAt desc,
        SU_keeper_OB_thing_GRD_rank_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- OB_part_SU_owner assembled view of the posit and annex tables,
-- pkOB_part_SU_owner optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_part_SU_owner', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[OB_part_SU_owner]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_OB_part_SU_owner,
        p.OB_part_SU_owner_ID,
        p.OB_ID_part,
        p.SU_ID_owner,
        a.OB_part_SU_owner_PositedAt,
        a.OB_part_SU_owner_Positor,
        a.OB_part_SU_owner_Reliability,
        a.OB_part_SU_owner_Assertion
    FROM
        [dbo].[OB_part_SU_owner_Posit] p
    JOIN
        [dbo].[OB_part_SU_owner_Annex] a
    ON
        a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkOB_part_SU_owner]
    ON [dbo].[OB_part_SU_owner] (
        OB_part_SU_owner_ID asc,
        OB_part_SU_owner_PositedAt desc,
        OB_part_SU_owner_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- SU_partner_SU_with assembled view of the posit and annex tables,
-- pkSU_partner_SU_with optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_partner_SU_with', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_partner_SU_with]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_partner_SU_with,
        p.SU_partner_SU_with_ID,
        p.SU_ID_partner,
        p.SU_ID_with,
        p.SU_partner_SU_with_ChangedAt,
        a.SU_partner_SU_with_PositedAt,
        a.SU_partner_SU_with_Positor,
        a.SU_partner_SU_with_Reliability,
        a.SU_partner_SU_with_Assertion
    FROM
        [dbo].[SU_partner_SU_with_Posit] p
    JOIN
        [dbo].[SU_partner_SU_with_Annex] a
    ON
        a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_partner_SU_with]
    ON [dbo].[SU_partner_SU_with] (
        SU_partner_SU_with_ID asc,
        SU_partner_SU_with_PositedAt desc,
        SU_partner_SU_with_Positor asc
    );
    ');
END
GO
-- TIE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------------
--
-- Ties may be prevented from storing restatements.
-- A restatement is when the same (non-key) values occurs for two adjacent points
-- in changing time.
--
-- returns 1 for one or two equal surrounding values, 0 for different surrounding values
--
-- @posit the id of the posit that should be checked
-- @posited the time when this posit was made
-- @positor the one who made the posit
-- @assertion whether this posit is positively or negatively asserted, or unreliable
--
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_holder_OB_item_GRD_grade restatement finder
-- rcSU_holder_OB_item_GRD_grade restatement constraint (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_holder_OB_item_GRD_grade', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_holder_OB_item_GRD_grade] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @SU_holder int;
    DECLARE @OB_item int;
    DECLARE @GRD_grade tinyint;
    SELECT
        @SU_holder = p.SU_ID_holder,
        @OB_item = p.OB_ID_item,
        @GRD_grade = p.GRD_ID_grade,
        @changed = p.SU_holder_OB_item_GRD_grade_ChangedAt
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
    WHERE
        p.SU_holder_OB_item_GRD_grade_ID = @posit;
    RETURN
        CASE WHEN @assertion = ''?'' THEN 0
        ELSE (
        SELECT
            COUNT(*)
        FROM (
            SELECT * FROM (
            SELECT TOP 1
                pre.GRD_ID_grade
            FROM
                [dbo].[rSU_holder_OB_item_GRD_grade] (
                    @positor,
                    @changed,
                    @posited
                ) pre
            WHERE
                pre.SU_ID_holder = @SU_holder
            AND
                pre.OB_ID_item = @OB_item
            AND
                pre.SU_holder_OB_item_GRD_grade_ChangedAt < @changed
            AND
                pre.SU_holder_OB_item_GRD_grade_Assertion = @assertion
            ORDER BY
                pre.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                pre.SU_holder_OB_item_GRD_grade_PositedAt DESC
            ) previous
            UNION
            SELECT * FROM (
            SELECT TOP 1
                fol.GRD_ID_grade
            FROM
                [dbo].[fSU_holder_OB_item_GRD_grade] (
                    @positor,
                    @changed,
                    @posited
                ) fol
            WHERE
                fol.SU_ID_holder = @SU_holder
            AND
                fol.OB_ID_item = @OB_item
            AND
                fol.SU_holder_OB_item_GRD_grade_ChangedAt > @changed
            AND
                fol.SU_holder_OB_item_GRD_grade_Assertion = @assertion
            ORDER BY
                fol.SU_holder_OB_item_GRD_grade_ChangedAt ASC,
                fol.SU_holder_OB_item_GRD_grade_PositedAt DESC
            ) following
        ) s
        WHERE
            s.GRD_ID_grade = @GRD_grade
    )
    END;
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_keeper_OB_thing_GRD_rank restatement finder
-- rcSU_keeper_OB_thing_GRD_rank restatement constraint (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_keeper_OB_thing_GRD_rank', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_keeper_OB_thing_GRD_rank] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @SU_keeper int;
    DECLARE @OB_thing int;
    DECLARE @GRD_rank tinyint;
    SELECT
        @SU_keeper = p.SU_ID_keeper,
        @OB_thing = p.OB_ID_thing,
        @GRD_rank = p.GRD_ID_rank,
        @changed = p.SU_keeper_OB_thing_GRD_rank_ChangedAt
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
    WHERE
        p.SU_keeper_OB_thing_GRD_rank_ID = @posit;
    RETURN
        CASE WHEN @assertion = ''?'' THEN 0
        ELSE (
        SELECT
            COUNT(*)
        FROM (
            SELECT * FROM (
            SELECT TOP 1
                pre.GRD_ID_rank
            FROM
                [dbo].[rSU_keeper_OB_thing_GRD_rank] (
                    @positor,
                    @changed,
                    @posited
                ) pre
            WHERE
                pre.SU_ID_keeper = @SU_keeper
            AND
                pre.OB_ID_thing = @OB_thing
            AND
                pre.SU_keeper_OB_thing_GRD_rank_ChangedAt < @changed
            AND
                pre.SU_keeper_OB_thing_GRD_rank_Assertion = @assertion
            ORDER BY
                pre.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                pre.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
            ) previous
            UNION
            SELECT * FROM (
            SELECT TOP 1
                fol.GRD_ID_rank
            FROM
                [dbo].[fSU_keeper_OB_thing_GRD_rank] (
                    @positor,
                    @changed,
                    @posited
                ) fol
            WHERE
                fol.SU_ID_keeper = @SU_keeper
            AND
                fol.OB_ID_thing = @OB_thing
            AND
                fol.SU_keeper_OB_thing_GRD_rank_ChangedAt > @changed
            AND
                fol.SU_keeper_OB_thing_GRD_rank_Assertion = @assertion
            ORDER BY
                fol.SU_keeper_OB_thing_GRD_rank_ChangedAt ASC,
                fol.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
            ) following
        ) s
        WHERE
            s.GRD_ID_rank = @GRD_rank
    )
    END;
    END
    ');
    ALTER TABLE [dbo].[SU_keeper_OB_thing_GRD_rank_Annex]
    ADD CONSTRAINT [rcSU_keeper_OB_thing_GRD_rank] CHECK (
        [dbo].[rfSU_keeper_OB_thing_GRD_rank] (
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_Assertion
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_partner_SU_with restatement finder
-- rcSU_partner_SU_with restatement constraint (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_partner_SU_with', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_partner_SU_with] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @SU_partner int;
    DECLARE @SU_with int;
    SELECT
        @SU_partner = p.SU_ID_partner,
        @SU_with = p.SU_ID_with,
        @changed = p.SU_partner_SU_with_ChangedAt
    FROM
        [dbo].[SU_partner_SU_with_Posit] p
    WHERE
        p.SU_partner_SU_with_ID = @posit;
    RETURN
        CASE WHEN @assertion = ''?'' THEN 0
        ELSE (
        SELECT
            COUNT(*)
        FROM (
            SELECT * FROM (
            SELECT TOP 1
                pre.SU_ID_partner,
                pre.SU_ID_with
            FROM
                [dbo].[rSU_partner_SU_with] (
                    @positor,
                    @changed,
                    @posited
                ) pre
            WHERE
            (
                    pre.SU_ID_partner = @SU_partner
                OR
                    pre.SU_ID_with = @SU_with
            )
            AND
                pre.SU_partner_SU_with_ChangedAt < @changed
            AND
                pre.SU_partner_SU_with_Assertion = @assertion
            ORDER BY
                pre.SU_partner_SU_with_ChangedAt DESC,
                pre.SU_partner_SU_with_PositedAt DESC
            ) previous
            UNION
            SELECT * FROM (
            SELECT TOP 1
                fol.SU_ID_partner,
                fol.SU_ID_with
            FROM
                [dbo].[fSU_partner_SU_with] (
                    @positor,
                    @changed,
                    @posited
                ) fol
            WHERE
            (
                    fol.SU_ID_partner = @SU_partner
                OR
                    fol.SU_ID_with = @SU_with
            )
            AND
                fol.SU_partner_SU_with_ChangedAt > @changed
            AND
                fol.SU_partner_SU_with_Assertion = @assertion
            ORDER BY
                fol.SU_partner_SU_with_ChangedAt ASC,
                fol.SU_partner_SU_with_PositedAt DESC
            ) following
        ) s
        WHERE
            s.SU_ID_partner = @SU_partner
        AND
            s.SU_ID_with = @SU_with
    )
    END;
    END
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
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rSU_holder_OB_item_GRD_grade_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_holder_OB_item_GRD_grade_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_holder_OB_item_GRD_grade_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_holder_OB_item_GRD_grade_ID,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade_Posit]
    WHERE
        SU_holder_OB_item_GRD_grade_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fSU_holder_OB_item_GRD_grade_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_holder_OB_item_GRD_grade_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_holder_OB_item_GRD_grade_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_holder_OB_item_GRD_grade_ID,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade_Posit]
    WHERE
        SU_holder_OB_item_GRD_grade_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rSU_holder_OB_item_GRD_grade_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_holder_OB_item_GRD_grade_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_holder_OB_item_GRD_grade_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_Reliability,
        SU_holder_OB_item_GRD_grade_Assertion
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade_Annex]
    WHERE
        SU_holder_OB_item_GRD_grade_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rSU_holder_OB_item_GRD_grade rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_holder_OB_item_GRD_grade','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_holder_OB_item_GRD_grade] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_holder_OB_item_GRD_grade,
        p.SU_holder_OB_item_GRD_grade_ID,
        p.SU_ID_holder,
        p.OB_ID_item,
        p.GRD_ID_grade,
        p.SU_holder_OB_item_GRD_grade_ChangedAt,
        a.SU_holder_OB_item_GRD_grade_PositedAt,
        a.SU_holder_OB_item_GRD_grade_Positor,
        a.SU_holder_OB_item_GRD_grade_Reliability,
        a.SU_holder_OB_item_GRD_grade_Assertion
    FROM
        [dbo].[rSU_holder_OB_item_GRD_grade_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_holder_OB_item_GRD_grade_Annex](@positingTimepoint) a
    ON
        a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
    AND
        a.SU_holder_OB_item_GRD_grade_Positor = @positor
    AND
        a.SU_holder_OB_item_GRD_grade_PositedAt = (
            SELECT TOP 1
                sub.SU_holder_OB_item_GRD_grade_PositedAt
            FROM
                [dbo].[rSU_holder_OB_item_GRD_grade_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            AND
                sub.SU_holder_OB_item_GRD_grade_Positor = @positor
            ORDER BY
                sub.SU_holder_OB_item_GRD_grade_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fSU_holder_OB_item_GRD_grade forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_holder_OB_item_GRD_grade','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_holder_OB_item_GRD_grade] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_holder_OB_item_GRD_grade,
        p.SU_holder_OB_item_GRD_grade_ID,
        p.SU_ID_holder,
        p.OB_ID_item,
        p.GRD_ID_grade,
        p.SU_holder_OB_item_GRD_grade_ChangedAt,
        a.SU_holder_OB_item_GRD_grade_PositedAt,
        a.SU_holder_OB_item_GRD_grade_Positor,
        a.SU_holder_OB_item_GRD_grade_Reliability,
        a.SU_holder_OB_item_GRD_grade_Assertion
    FROM
        [dbo].[fSU_holder_OB_item_GRD_grade_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_holder_OB_item_GRD_grade_Annex](@positingTimepoint) a
    ON
        a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
    AND
        a.SU_holder_OB_item_GRD_grade_Positor = @positor
    AND
        a.SU_holder_OB_item_GRD_grade_PositedAt = (
            SELECT TOP 1
                sub.SU_holder_OB_item_GRD_grade_PositedAt
            FROM
                [dbo].[rSU_holder_OB_item_GRD_grade_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            AND
                sub.SU_holder_OB_item_GRD_grade_Positor = @positor
            ORDER BY
                sub.SU_holder_OB_item_GRD_grade_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rSU_keeper_OB_thing_GRD_rank_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_keeper_OB_thing_GRD_rank_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_keeper_OB_thing_GRD_rank_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit]
    WHERE
        SU_keeper_OB_thing_GRD_rank_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fSU_keeper_OB_thing_GRD_rank_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_keeper_OB_thing_GRD_rank_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_keeper_OB_thing_GRD_rank_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit]
    WHERE
        SU_keeper_OB_thing_GRD_rank_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rSU_keeper_OB_thing_GRD_rank_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_keeper_OB_thing_GRD_rank_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_keeper_OB_thing_GRD_rank_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_Reliability,
        SU_keeper_OB_thing_GRD_rank_Assertion
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank_Annex]
    WHERE
        SU_keeper_OB_thing_GRD_rank_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rSU_keeper_OB_thing_GRD_rank rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_keeper_OB_thing_GRD_rank','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_keeper_OB_thing_GRD_rank] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ID,
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank,
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        a.SU_keeper_OB_thing_GRD_rank_PositedAt,
        a.SU_keeper_OB_thing_GRD_rank_Positor,
        a.SU_keeper_OB_thing_GRD_rank_Reliability,
        a.SU_keeper_OB_thing_GRD_rank_Assertion
    FROM
        [dbo].[rSU_keeper_OB_thing_GRD_rank_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_keeper_OB_thing_GRD_rank_Annex](@positingTimepoint) a
    ON
        a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
    AND
        a.SU_keeper_OB_thing_GRD_rank_Positor = @positor
    AND
        a.SU_keeper_OB_thing_GRD_rank_PositedAt = (
            SELECT TOP 1
                sub.SU_keeper_OB_thing_GRD_rank_PositedAt
            FROM
                [dbo].[rSU_keeper_OB_thing_GRD_rank_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            AND
                sub.SU_keeper_OB_thing_GRD_rank_Positor = @positor
            ORDER BY
                sub.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fSU_keeper_OB_thing_GRD_rank forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_keeper_OB_thing_GRD_rank','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_keeper_OB_thing_GRD_rank] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ID,
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank,
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        a.SU_keeper_OB_thing_GRD_rank_PositedAt,
        a.SU_keeper_OB_thing_GRD_rank_Positor,
        a.SU_keeper_OB_thing_GRD_rank_Reliability,
        a.SU_keeper_OB_thing_GRD_rank_Assertion
    FROM
        [dbo].[fSU_keeper_OB_thing_GRD_rank_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_keeper_OB_thing_GRD_rank_Annex](@positingTimepoint) a
    ON
        a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
    AND
        a.SU_keeper_OB_thing_GRD_rank_Positor = @positor
    AND
        a.SU_keeper_OB_thing_GRD_rank_PositedAt = (
            SELECT TOP 1
                sub.SU_keeper_OB_thing_GRD_rank_PositedAt
            FROM
                [dbo].[rSU_keeper_OB_thing_GRD_rank_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            AND
                sub.SU_keeper_OB_thing_GRD_rank_Positor = @positor
            ORDER BY
                sub.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rOB_part_SU_owner_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rOB_part_SU_owner_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rOB_part_SU_owner_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_Reliability,
        OB_part_SU_owner_Assertion
    FROM
        [dbo].[OB_part_SU_owner_Annex]
    WHERE
        OB_part_SU_owner_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rOB_part_SU_owner rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rOB_part_SU_owner','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rOB_part_SU_owner] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_OB_part_SU_owner,
        p.OB_part_SU_owner_ID,
        p.OB_ID_part,
        p.SU_ID_owner,
        a.OB_part_SU_owner_PositedAt,
        a.OB_part_SU_owner_Positor,
        a.OB_part_SU_owner_Reliability,
        a.OB_part_SU_owner_Assertion
    FROM
        [dbo].[OB_part_SU_owner_Posit] p
    JOIN
        [dbo].[rOB_part_SU_owner_Annex](@positingTimepoint) a
    ON
        a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
    AND
        a.OB_part_SU_owner_Positor = @positor
    AND
        a.OB_part_SU_owner_PositedAt = (
            SELECT TOP 1
                sub.OB_part_SU_owner_PositedAt
            FROM
                [dbo].[rOB_part_SU_owner_Annex](@positingTimepoint) sub
            WHERE
                sub.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            AND
                sub.OB_part_SU_owner_Positor = @positor
            ORDER BY
                sub.OB_part_SU_owner_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fOB_part_SU_owner forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fOB_part_SU_owner','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fOB_part_SU_owner] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_OB_part_SU_owner,
        p.OB_part_SU_owner_ID,
        p.OB_ID_part,
        p.SU_ID_owner,
        a.OB_part_SU_owner_PositedAt,
        a.OB_part_SU_owner_Positor,
        a.OB_part_SU_owner_Reliability,
        a.OB_part_SU_owner_Assertion
    FROM
        [dbo].[OB_part_SU_owner_Posit] p
    JOIN
        [dbo].[rOB_part_SU_owner_Annex](@positingTimepoint) a
    ON
        a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
    AND
        a.OB_part_SU_owner_Positor = @positor
    AND
        a.OB_part_SU_owner_PositedAt = (
            SELECT TOP 1
                sub.OB_part_SU_owner_PositedAt
            FROM
                [dbo].[rOB_part_SU_owner_Annex](@positingTimepoint) sub
            WHERE
                sub.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            AND
                sub.OB_part_SU_owner_Positor = @positor
            ORDER BY
                sub.OB_part_SU_owner_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rSU_partner_SU_with_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_partner_SU_with_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_partner_SU_with_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_partner_SU_with_ID,
        SU_ID_partner,
        SU_ID_with,
        SU_partner_SU_with_ChangedAt
    FROM
        [dbo].[SU_partner_SU_with_Posit]
    WHERE
        SU_partner_SU_with_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fSU_partner_SU_with_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_partner_SU_with_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_partner_SU_with_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_partner_SU_with_ID,
        SU_ID_partner,
        SU_ID_with,
        SU_partner_SU_with_ChangedAt
    FROM
        [dbo].[SU_partner_SU_with_Posit]
    WHERE
        SU_partner_SU_with_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rSU_partner_SU_with_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_partner_SU_with_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_partner_SU_with_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_Reliability,
        SU_partner_SU_with_Assertion
    FROM
        [dbo].[SU_partner_SU_with_Annex]
    WHERE
        SU_partner_SU_with_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rSU_partner_SU_with rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_partner_SU_with','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_partner_SU_with] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_partner_SU_with,
        p.SU_partner_SU_with_ID,
        p.SU_ID_partner,
        p.SU_ID_with,
        p.SU_partner_SU_with_ChangedAt,
        a.SU_partner_SU_with_PositedAt,
        a.SU_partner_SU_with_Positor,
        a.SU_partner_SU_with_Reliability,
        a.SU_partner_SU_with_Assertion
    FROM
        [dbo].[rSU_partner_SU_with_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_partner_SU_with_Annex](@positingTimepoint) a
    ON
        a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
    AND
        a.SU_partner_SU_with_Positor = @positor
    AND
        a.SU_partner_SU_with_PositedAt = (
            SELECT TOP 1
                sub.SU_partner_SU_with_PositedAt
            FROM
                [dbo].[rSU_partner_SU_with_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            AND
                sub.SU_partner_SU_with_Positor = @positor
            ORDER BY
                sub.SU_partner_SU_with_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fSU_partner_SU_with forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_partner_SU_with','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_partner_SU_with] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_partner_SU_with,
        p.SU_partner_SU_with_ID,
        p.SU_ID_partner,
        p.SU_ID_with,
        p.SU_partner_SU_with_ChangedAt,
        a.SU_partner_SU_with_PositedAt,
        a.SU_partner_SU_with_Positor,
        a.SU_partner_SU_with_Reliability,
        a.SU_partner_SU_with_Assertion
    FROM
        [dbo].[fSU_partner_SU_with_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_partner_SU_with_Annex](@positingTimepoint) a
    ON
        a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
    AND
        a.SU_partner_SU_with_Positor = @positor
    AND
        a.SU_partner_SU_with_PositedAt = (
            SELECT TOP 1
                sub.SU_partner_SU_with_PositedAt
            FROM
                [dbo].[rSU_partner_SU_with_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            AND
                sub.SU_partner_SU_with_Positor = @positor
            ORDER BY
                sub.SU_partner_SU_with_PositedAt DESC
        )
    ');
END
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
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
-- @assertion whether to show positve, negative, uncertain, or all posits (defaults to all)
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
IF Object_ID('dbo.dSU_holder_OB_item_GRD_grade', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.nSU_holder_OB_item_GRD_grade', 'V') IS NOT NULL
DROP VIEW [dbo].[nSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.pSU_holder_OB_item_GRD_grade', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.lSU_holder_OB_item_GRD_grade', 'V') IS NOT NULL
DROP VIEW [dbo].[lSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.tSU_holder_OB_item_GRD_grade', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tSU_holder_OB_item_GRD_grade];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tSU_holder_OB_item_GRD_grade viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tSU_holder_OB_item_GRD_grade] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.SU_holder_OB_item_GRD_grade_ID,
    tie.Metadata_SU_holder_OB_item_GRD_grade,
    tie.SU_holder_OB_item_GRD_grade_Positor,
    tie.SU_holder_OB_item_GRD_grade_ChangedAt,
    tie.SU_holder_OB_item_GRD_grade_PositedAt,
    tie.SU_holder_OB_item_GRD_grade_Reliability,
    tie.SU_holder_OB_item_GRD_grade_Assertion,
    tie.SU_ID_holder,
    tie.OB_ID_item,
    [GRD_grade].GRD_Grade AS grade_GRD_Grade,
    [GRD_grade].Metadata_GRD AS grade_Metadata_GRD,
    tie.GRD_ID_grade
FROM
    [dbo].[rSU_holder_OB_item_GRD_grade](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_grade]
ON
    [GRD_grade].GRD_ID = tie.GRD_ID_grade
WHERE
    tie.SU_holder_OB_item_GRD_grade_ID = (
        SELECT TOP 1
            sub.SU_holder_OB_item_GRD_grade_ID
        FROM
            [dbo].[rSU_holder_OB_item_GRD_grade](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_ID_holder = tie.SU_ID_holder
        AND
            sub.OB_ID_item = tie.OB_ID_item
        AND
            sub.SU_holder_OB_item_GRD_grade_Assertion = isnull(@assertion, sub.SU_holder_OB_item_GRD_grade_Assertion)
        ORDER BY
            sub.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
            sub.SU_holder_OB_item_GRD_grade_PositedAt DESC,
            sub.SU_holder_OB_item_GRD_grade_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_holder_OB_item_GRD_grade viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_holder_OB_item_GRD_grade] AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_holder_OB_item_GRD_grade] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_holder_OB_item_GRD_grade viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_holder_OB_item_GRD_grade] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_holder_OB_item_GRD_grade] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_holder_OB_item_GRD_grade viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_holder_OB_item_GRD_grade]
AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_holder_OB_item_GRD_grade] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dSU_holder_OB_item_GRD_grade showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dSU_holder_OB_item_GRD_grade] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [GRD_grade].GRD_Grade AS grade_GRD_Grade,
    [GRD_grade].Metadata_GRD AS grade_Metadata_GRD,
    tie.*
FROM
    [dbo].[SU_holder_OB_item_GRD_grade] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_grade]
ON
    [GRD_grade].GRD_ID = tie.GRD_ID_grade
WHERE
    tie.SU_holder_OB_item_GRD_grade_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dSU_keeper_OB_thing_GRD_rank', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dSU_keeper_OB_thing_GRD_rank];
IF Object_ID('dbo.nSU_keeper_OB_thing_GRD_rank', 'V') IS NOT NULL
DROP VIEW [dbo].[nSU_keeper_OB_thing_GRD_rank];
IF Object_ID('dbo.pSU_keeper_OB_thing_GRD_rank', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pSU_keeper_OB_thing_GRD_rank];
IF Object_ID('dbo.lSU_keeper_OB_thing_GRD_rank', 'V') IS NOT NULL
DROP VIEW [dbo].[lSU_keeper_OB_thing_GRD_rank];
IF Object_ID('dbo.tSU_keeper_OB_thing_GRD_rank', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tSU_keeper_OB_thing_GRD_rank];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tSU_keeper_OB_thing_GRD_rank viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tSU_keeper_OB_thing_GRD_rank] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.SU_keeper_OB_thing_GRD_rank_ID,
    tie.Metadata_SU_keeper_OB_thing_GRD_rank,
    tie.SU_keeper_OB_thing_GRD_rank_Positor,
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    tie.SU_keeper_OB_thing_GRD_rank_PositedAt,
    tie.SU_keeper_OB_thing_GRD_rank_Reliability,
    tie.SU_keeper_OB_thing_GRD_rank_Assertion,
    tie.SU_ID_keeper,
    tie.OB_ID_thing,
    [GRD_rank].GRD_Grade AS rank_GRD_Grade,
    [GRD_rank].Metadata_GRD AS rank_Metadata_GRD,
    tie.GRD_ID_rank
FROM
    [dbo].[rSU_keeper_OB_thing_GRD_rank](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_rank]
ON
    [GRD_rank].GRD_ID = tie.GRD_ID_rank
WHERE
    tie.SU_keeper_OB_thing_GRD_rank_ID = (
        SELECT TOP 1
            sub.SU_keeper_OB_thing_GRD_rank_ID
        FROM
            [dbo].[rSU_keeper_OB_thing_GRD_rank](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_ID_keeper = tie.SU_ID_keeper
        AND
            sub.OB_ID_thing = tie.OB_ID_thing
        AND
            sub.SU_keeper_OB_thing_GRD_rank_Assertion = isnull(@assertion, sub.SU_keeper_OB_thing_GRD_rank_Assertion)
        ORDER BY
            sub.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
            sub.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
            sub.SU_keeper_OB_thing_GRD_rank_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_keeper_OB_thing_GRD_rank viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_keeper_OB_thing_GRD_rank] AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_keeper_OB_thing_GRD_rank] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_keeper_OB_thing_GRD_rank viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_keeper_OB_thing_GRD_rank] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_keeper_OB_thing_GRD_rank] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_keeper_OB_thing_GRD_rank viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_keeper_OB_thing_GRD_rank]
AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_keeper_OB_thing_GRD_rank] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dSU_keeper_OB_thing_GRD_rank showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dSU_keeper_OB_thing_GRD_rank] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [GRD_rank].GRD_Grade AS rank_GRD_Grade,
    [GRD_rank].Metadata_GRD AS rank_Metadata_GRD,
    tie.*
FROM
    [dbo].[SU_keeper_OB_thing_GRD_rank] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_rank]
ON
    [GRD_rank].GRD_ID = tie.GRD_ID_rank
WHERE
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dOB_part_SU_owner', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dOB_part_SU_owner];
IF Object_ID('dbo.nOB_part_SU_owner', 'V') IS NOT NULL
DROP VIEW [dbo].[nOB_part_SU_owner];
IF Object_ID('dbo.pOB_part_SU_owner', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pOB_part_SU_owner];
IF Object_ID('dbo.lOB_part_SU_owner', 'V') IS NOT NULL
DROP VIEW [dbo].[lOB_part_SU_owner];
IF Object_ID('dbo.tOB_part_SU_owner', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tOB_part_SU_owner];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tOB_part_SU_owner viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tOB_part_SU_owner] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.OB_part_SU_owner_ID,
    tie.Metadata_OB_part_SU_owner,
    tie.OB_part_SU_owner_Positor,
    tie.OB_part_SU_owner_PositedAt,
    tie.OB_part_SU_owner_Reliability,
    tie.OB_part_SU_owner_Assertion,
    tie.OB_ID_part,
    tie.SU_ID_owner
FROM
    [dbo].[rOB_part_SU_owner](
        @positor,
        @positingTimepoint
    ) tie
WHERE
    tie.OB_part_SU_owner_ID = (
        SELECT TOP 1
            sub.OB_part_SU_owner_ID
        FROM
            [dbo].[rOB_part_SU_owner](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.OB_ID_part = tie.OB_ID_part
        AND
            sub.OB_part_SU_owner_Assertion = isnull(@assertion, sub.OB_part_SU_owner_Assertion)
        ORDER BY
            sub.OB_part_SU_owner_PositedAt DESC,
            sub.OB_part_SU_owner_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOB_part_SU_owner viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lOB_part_SU_owner] AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_part_SU_owner] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pOB_part_SU_owner viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pOB_part_SU_owner] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_part_SU_owner] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOB_part_SU_owner viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nOB_part_SU_owner]
AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_part_SU_owner] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dSU_partner_SU_with', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dSU_partner_SU_with];
IF Object_ID('dbo.nSU_partner_SU_with', 'V') IS NOT NULL
DROP VIEW [dbo].[nSU_partner_SU_with];
IF Object_ID('dbo.pSU_partner_SU_with', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pSU_partner_SU_with];
IF Object_ID('dbo.lSU_partner_SU_with', 'V') IS NOT NULL
DROP VIEW [dbo].[lSU_partner_SU_with];
IF Object_ID('dbo.tSU_partner_SU_with', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tSU_partner_SU_with];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tSU_partner_SU_with viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tSU_partner_SU_with] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.SU_partner_SU_with_ID,
    tie.Metadata_SU_partner_SU_with,
    tie.SU_partner_SU_with_Positor,
    tie.SU_partner_SU_with_ChangedAt,
    tie.SU_partner_SU_with_PositedAt,
    tie.SU_partner_SU_with_Reliability,
    tie.SU_partner_SU_with_Assertion,
    tie.SU_ID_partner,
    tie.SU_ID_with
FROM
    [dbo].[rSU_partner_SU_with](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) tie
WHERE
    tie.SU_partner_SU_with_ID = (
        SELECT TOP 1
            sub.SU_partner_SU_with_ID
        FROM
            [dbo].[rSU_partner_SU_with](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
        (
                sub.SU_ID_partner = tie.SU_ID_partner
            OR
                sub.SU_ID_with = tie.SU_ID_with
        )
        AND
            sub.SU_partner_SU_with_Assertion = isnull(@assertion, sub.SU_partner_SU_with_Assertion)
        ORDER BY
            sub.SU_partner_SU_with_ChangedAt DESC,
            sub.SU_partner_SU_with_PositedAt DESC,
            sub.SU_partner_SU_with_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_partner_SU_with viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_partner_SU_with] AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_partner_SU_with] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_partner_SU_with viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_partner_SU_with] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_partner_SU_with] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_partner_SU_with viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_partner_SU_with]
AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_partner_SU_with] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dSU_partner_SU_with showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dSU_partner_SU_with] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.*
FROM
    [dbo].[SU_partner_SU_with] tie
WHERE
    tie.SU_partner_SU_with_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
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
-- itSU_holder_OB_item_GRD_grade instead of INSERT trigger on SU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_holder_OB_item_GRD_grade', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_holder_OB_item_GRD_grade];
GO
CREATE TRIGGER [dbo].[it_SU_holder_OB_item_GRD_grade] ON [dbo].[SU_holder_OB_item_GRD_grade]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_SU_holder_OB_item_GRD_grade int not null,
        SU_holder_OB_item_GRD_grade_ChangedAt datetime2 not null,
        SU_holder_OB_item_GRD_grade_Version bigint not null,
        SU_holder_OB_item_GRD_grade_StatementType char(1) not null,
        SU_holder_OB_item_GRD_grade_Positor tinyint not null,
        SU_holder_OB_item_GRD_grade_PositedAt datetime2 not null,
        SU_holder_OB_item_GRD_grade_Reliability decimal(5,2) not null,
        SU_holder_OB_item_GRD_grade_Assertion char(1) not null,
        SU_ID_holder int not null,
        OB_ID_item int not null,
        GRD_ID_grade tinyint not null,
        primary key (
            SU_holder_OB_item_GRD_grade_Version,
            SU_holder_OB_item_GRD_grade_Positor,
            SU_ID_holder,
            OB_ID_item
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_holder,
            i.OB_ID_item,
            i.GRD_ID_grade,
            ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now) AS SU_holder_OB_item_GRD_grade_ChangedAt,
            ISNULL(i.SU_holder_OB_item_GRD_grade_Positor, 0) AS SU_holder_OB_item_GRD_grade_Positor,
            ISNULL(i.SU_holder_OB_item_GRD_grade_PositedAt, @now) AS SU_holder_OB_item_GRD_grade_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
            JOIN
                [dbo].[SU_holder_OB_item_GRD_grade_Annex] a
            ON
                a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            WHERE
                p.SU_ID_holder = i.SU_ID_holder
            AND
                p.OB_ID_item = i.OB_ID_item
            AND
                p.GRD_ID_grade = i.GRD_ID_grade
            AND
                p.SU_holder_OB_item_GRD_grade_ChangedAt = ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now)
            AND
                a.SU_holder_OB_item_GRD_grade_Positor = ISNULL(i.SU_holder_OB_item_GRD_grade_Positor, 0)
            AND
                a.SU_holder_OB_item_GRD_grade_PositedAt = ISNULL(i.SU_holder_OB_item_GRD_grade_PositedAt, @now)
            AND
                a.SU_holder_OB_item_GRD_grade_Reliability <> ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_holder_OB_item_GRD_grade for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_holder_OB_item_GRD_grade, 0),
        ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_holder_OB_item_GRD_grade_Positor,
                i.SU_ID_holder,
                i.OB_ID_item
            ORDER BY
                ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now),
                i.SU_holder_OB_item_GRD_grade_PositedAt ASC,
                i.SU_holder_OB_item_GRD_grade_Reliability ASC
        ),
        'X',
        ISNULL(i.SU_holder_OB_item_GRD_grade_Positor, 0),
        ISNULL(i.SU_holder_OB_item_GRD_grade_PositedAt, @now),
        ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1),
        CAST(
            case
                when i.SU_holder_OB_item_GRD_grade_Reliability > 0 then '+'
                when i.SU_holder_OB_item_GRD_grade_Reliability = 0 then '?'
                when i.SU_holder_OB_item_GRD_grade_Reliability < 0 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.SU_ID_holder,
        i.OB_ID_item,
        i.GRD_ID_grade
    FROM
        inserted i
    WHERE
        i.SU_ID_holder is not null
    AND
        i.OB_ID_item is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
            JOIN
                [dbo].[SU_holder_OB_item_GRD_grade_Annex] a
            ON
                a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            WHERE
                p.SU_ID_holder = i.SU_ID_holder
            AND
                p.OB_ID_item = i.OB_ID_item
            AND
                p.GRD_ID_grade = i.GRD_ID_grade
            AND
                p.SU_holder_OB_item_GRD_grade_ChangedAt = ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now)
            AND
                a.SU_holder_OB_item_GRD_grade_Positor = ISNULL(i.SU_holder_OB_item_GRD_grade_Positor, 0)
            AND
                a.SU_holder_OB_item_GRD_grade_PositedAt = ISNULL(i.SU_holder_OB_item_GRD_grade_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(SU_holder_OB_item_GRD_grade_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_holder_OB_item_GRD_grade_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_holder_OB_item_GRD_grade_ID
                        FROM
                            [dbo].[tSU_holder_OB_item_GRD_grade](v.SU_holder_OB_item_GRD_grade_Positor, v.SU_holder_OB_item_GRD_grade_ChangedAt, v.SU_holder_OB_item_GRD_grade_PositedAt, v.SU_holder_OB_item_GRD_grade_Assertion) t
                        WHERE
                            t.SU_holder_OB_item_GRD_grade_Reliability = v.SU_holder_OB_item_GRD_grade_Reliability
                        AND
                            t.SU_holder_OB_item_GRD_grade_ChangedAt = v.SU_holder_OB_item_GRD_grade_ChangedAt
                        AND
                            t.SU_ID_holder = v.SU_ID_holder
                        AND
                            t.OB_ID_item = v.OB_ID_item
                        AND
                            t.GRD_ID_grade = v.GRD_ID_grade
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_holder_OB_item_GRD_grade_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                pre.GRD_ID_grade
                            FROM
                                [dbo].[rSU_holder_OB_item_GRD_grade] (
                                    v.SU_holder_OB_item_GRD_grade_Positor,
                                    v.SU_holder_OB_item_GRD_grade_ChangedAt,
                                    v.SU_holder_OB_item_GRD_grade_PositedAt
                                ) pre
                            WHERE
                                pre.SU_ID_holder = v.SU_ID_holder
                            AND
                                pre.OB_ID_item = v.OB_ID_item
                            AND
                                pre.SU_holder_OB_item_GRD_grade_ChangedAt < v.SU_holder_OB_item_GRD_grade_ChangedAt
                            AND
                                pre.SU_holder_OB_item_GRD_grade_Assertion = v.SU_holder_OB_item_GRD_grade_Assertion
                            ORDER BY
                                pre.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                                pre.SU_holder_OB_item_GRD_grade_PositedAt DESC
                        ) s
                        WHERE
                            s.GRD_ID_grade = v.GRD_ID_grade
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                fol.GRD_ID_grade
                            FROM
                                [dbo].[fSU_holder_OB_item_GRD_grade] (
                                    v.SU_holder_OB_item_GRD_grade_Positor,
                                    v.SU_holder_OB_item_GRD_grade_ChangedAt,
                                    v.SU_holder_OB_item_GRD_grade_PositedAt
                                ) fol
                            WHERE
                                fol.SU_ID_holder = v.SU_ID_holder
                            AND
                                fol.OB_ID_item = v.OB_ID_item
                            AND
                                fol.SU_holder_OB_item_GRD_grade_ChangedAt > v.SU_holder_OB_item_GRD_grade_ChangedAt
                            AND
                                fol.SU_holder_OB_item_GRD_grade_Assertion = v.SU_holder_OB_item_GRD_grade_Assertion
                            ORDER BY
                                fol.SU_holder_OB_item_GRD_grade_ChangedAt ASC,
                                fol.SU_holder_OB_item_GRD_grade_PositedAt DESC
                        ) s
                        WHERE
                            s.GRD_ID_grade = v.GRD_ID_grade
                    )
                    THEN 'R' -- restatement of the following version
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
        ON
            p.SU_ID_holder = v.SU_ID_holder
        AND
            p.OB_ID_item = v.OB_ID_item
        AND
            p.GRD_ID_grade = v.GRD_ID_grade
        AND
            p.SU_holder_OB_item_GRD_grade_ChangedAt = v.SU_holder_OB_item_GRD_grade_ChangedAt
        WHERE
            v.SU_holder_OB_item_GRD_grade_Version = @currentVersion;
        INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Posit] (
            SU_holder_OB_item_GRD_grade_ChangedAt,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            SU_holder_OB_item_GRD_grade_ChangedAt,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade
        FROM
            @inserted
        WHERE
            SU_holder_OB_item_GRD_grade_Version = @currentVersion
        AND
            SU_holder_OB_item_GRD_grade_StatementType in ('N','R');
        INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_holder_OB_item_GRD_grade_Positor,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Reliability
        )
        SELECT
            v.Metadata_SU_holder_OB_item_GRD_grade,
            p.SU_holder_OB_item_GRD_grade_ID,
            v.SU_holder_OB_item_GRD_grade_Positor,
            v.SU_holder_OB_item_GRD_grade_PositedAt,
            v.SU_holder_OB_item_GRD_grade_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
        ON
            p.SU_ID_holder = v.SU_ID_holder
        AND
            p.OB_ID_item = v.OB_ID_item
        AND
            p.GRD_ID_grade = v.GRD_ID_grade
        AND
            p.SU_holder_OB_item_GRD_grade_ChangedAt = v.SU_holder_OB_item_GRD_grade_ChangedAt
        WHERE
            v.SU_holder_OB_item_GRD_grade_Version = @currentVersion
        AND
            v.SU_holder_OB_item_GRD_grade_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_holder_OB_item_GRD_grade instead of INSERT trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lSU_holder_OB_item_GRD_grade] ON [dbo].[lSU_holder_OB_item_GRD_grade]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        i.SU_holder_OB_item_GRD_grade_ChangedAt,
        i.SU_ID_holder,
        i.OB_ID_item,
        ISNULL(i.GRD_ID_grade, [GRD_grade].GRD_ID),
        ISNULL(i.SU_holder_OB_item_GRD_grade_Positor, i.Positor),
        i.SU_holder_OB_item_GRD_grade_PositedAt,
        i.SU_holder_OB_item_GRD_grade_Reliability
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_grade]
    ON
        [GRD_grade].GRD_Grade = i.grade_GRD_Grade;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_holder_OB_item_GRD_grade instead of UPDATE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lSU_holder_OB_item_GRD_grade] ON [dbo].[lSU_holder_OB_item_GRD_grade]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(SU_holder_OB_item_GRD_grade_Assertion))
        RAISERROR('The computed assertion column SU_holder_OB_item_GRD_grade_Assertion is not updatable.', 16, 1);
    IF(UPDATE(SU_holder_OB_item_GRD_grade_ID))
        RAISERROR('The identity column SU_holder_OB_item_GRD_grade_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ID_holder))
        RAISERROR('The identity column SU_ID_holder is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_item))
        RAISERROR('The identity column OB_ID_item is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        i.SU_holder_OB_item_GRD_grade_ID,
        ISNULL(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_Positor) THEN i.SU_holder_OB_item_GRD_grade_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(SU_holder_OB_item_GRD_grade_PositedAt) THEN i.SU_holder_OB_item_GRD_grade_PositedAt
            WHEN UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt) THEN i.SU_holder_OB_item_GRD_grade_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_grade]
    ON
        [GRD_grade].GRD_Grade = i.grade_GRD_Grade
    WHERE
        i.SU_holder_OB_item_GRD_grade_ID is not null
    AND (
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        cast(CASE
            WHEN UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt) THEN i.SU_holder_OB_item_GRD_grade_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_holder_OB_item_GRD_grade_ID = i.SU_holder_OB_item_GRD_grade_ID
                AND
                    d.SU_holder_OB_item_GRD_grade_Positor = i.SU_holder_OB_item_GRD_grade_Positor
                AND
                    d.GRD_ID_grade = CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END
            ) THEN i.SU_holder_OB_item_GRD_grade_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.SU_ID_holder,
        i.OB_ID_item,
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END,
        ISNULL(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_Positor) THEN i.SU_holder_OB_item_GRD_grade_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_PositedAt) THEN i.SU_holder_OB_item_GRD_grade_PositedAt ELSE @now END as datetime2),
        ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1)
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_grade]
    ON
        [GRD_grade].GRD_Grade = i.grade_GRD_Grade
    WHERE
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt) OR
            UPDATE(SU_holder_OB_item_GRD_grade_PositedAt) OR
            UPDATE(SU_holder_OB_item_GRD_grade_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_holder_OB_item_GRD_grade_ID = i.SU_holder_OB_item_GRD_grade_ID
                AND
                    d.SU_holder_OB_item_GRD_grade_Positor = i.SU_holder_OB_item_GRD_grade_Positor
                AND
                    d.GRD_ID_grade = CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END
                AND
                    d.SU_holder_OB_item_GRD_grade_Reliability = ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1)
            )
        );
    -- indecisive: other values at the same changing time are a correction, which also retracts the shown posit
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        d.SU_holder_OB_item_GRD_grade_ID,
        d.SU_holder_OB_item_GRD_grade_Positor,
        cast(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_PositedAt) THEN i.SU_holder_OB_item_GRD_grade_PositedAt ELSE @now END as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_grade]
    ON
        [GRD_grade].GRD_Grade = i.grade_GRD_Grade
    JOIN
        deleted d
    ON
        d.SU_holder_OB_item_GRD_grade_ID = i.SU_holder_OB_item_GRD_grade_ID
    AND
        d.SU_holder_OB_item_GRD_grade_Positor = i.SU_holder_OB_item_GRD_grade_Positor
    WHERE (
        d.GRD_ID_grade <> CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END
    )
    AND
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END is not null
    AND
        UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt)
    AND
        d.SU_holder_OB_item_GRD_grade_ChangedAt = i.SU_holder_OB_item_GRD_grade_ChangedAt
    AND
        d.SU_holder_OB_item_GRD_grade_Positor = ISNULL(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_Positor) THEN i.SU_holder_OB_item_GRD_grade_Positor ELSE i.Positor END, 0)
    AND
        d.SU_holder_OB_item_GRD_grade_PositedAt < cast(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_PositedAt) THEN i.SU_holder_OB_item_GRD_grade_PositedAt ELSE @now END as datetime2)
    AND
        ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1) > 0;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_holder_OB_item_GRD_grade instead of DELETE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lSU_holder_OB_item_GRD_grade] ON [dbo].[lSU_holder_OB_item_GRD_grade]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        d.Metadata_SU_holder_OB_item_GRD_grade,
        d.SU_holder_OB_item_GRD_grade_ID,
        d.SU_holder_OB_item_GRD_grade_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on SU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_keeper_OB_thing_GRD_rank', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_keeper_OB_thing_GRD_rank];
GO
CREATE TRIGGER [dbo].[it_SU_keeper_OB_thing_GRD_rank] ON [dbo].[SU_keeper_OB_thing_GRD_rank]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_SU_keeper_OB_thing_GRD_rank int not null,
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_Version bigint not null,
        SU_keeper_OB_thing_GRD_rank_StatementType char(1) not null,
        SU_keeper_OB_thing_GRD_rank_Positor tinyint not null,
        SU_keeper_OB_thing_GRD_rank_PositedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_Reliability decimal(5,2) not null,
        SU_keeper_OB_thing_GRD_rank_Assertion char(1) not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null,
        primary key (
            SU_keeper_OB_thing_GRD_rank_Version,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_ID_keeper,
            OB_ID_thing
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_keeper,
            i.OB_ID_thing,
            i.GRD_ID_rank,
            ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now) AS SU_keeper_OB_thing_GRD_rank_ChangedAt,
            ISNULL(i.SU_keeper_OB_thing_GRD_rank_Positor, 0) AS SU_keeper_OB_thing_GRD_rank_Positor,
            ISNULL(i.SU_keeper_OB_thing_GRD_rank_PositedAt, @now) AS SU_keeper_OB_thing_GRD_rank_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
            JOIN
                [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
            ON
                a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            WHERE
                p.SU_ID_keeper = i.SU_ID_keeper
            AND
                p.OB_ID_thing = i.OB_ID_thing
            AND
                p.GRD_ID_rank = i.GRD_ID_rank
            AND
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt = ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now)
            AND
                a.SU_keeper_OB_thing_GRD_rank_Positor = ISNULL(i.SU_keeper_OB_thing_GRD_rank_Positor, 0)
            AND
                a.SU_keeper_OB_thing_GRD_rank_PositedAt = ISNULL(i.SU_keeper_OB_thing_GRD_rank_PositedAt, @now)
            AND
                a.SU_keeper_OB_thing_GRD_rank_Reliability <> ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_keeper_OB_thing_GRD_rank for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_keeper_OB_thing_GRD_rank, 0),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_keeper_OB_thing_GRD_rank_Positor,
                i.SU_ID_keeper,
                i.OB_ID_thing
            ORDER BY
                ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now),
                i.SU_keeper_OB_thing_GRD_rank_PositedAt ASC,
                i.SU_keeper_OB_thing_GRD_rank_Reliability ASC
        ),
        'X',
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Positor, 0),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_PositedAt, @now),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1),
        CAST(
            case
                when i.SU_keeper_OB_thing_GRD_rank_Reliability > 0 then '+'
                when i.SU_keeper_OB_thing_GRD_rank_Reliability = 0 then '?'
                when i.SU_keeper_OB_thing_GRD_rank_Reliability < 0 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.SU_ID_keeper,
        i.OB_ID_thing,
        i.GRD_ID_rank
    FROM
        inserted i
    WHERE
        i.SU_ID_keeper is not null
    AND
        i.OB_ID_thing is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
            JOIN
                [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
            ON
                a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            WHERE
                p.SU_ID_keeper = i.SU_ID_keeper
            AND
                p.OB_ID_thing = i.OB_ID_thing
            AND
                p.GRD_ID_rank = i.GRD_ID_rank
            AND
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt = ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now)
            AND
                a.SU_keeper_OB_thing_GRD_rank_Positor = ISNULL(i.SU_keeper_OB_thing_GRD_rank_Positor, 0)
            AND
                a.SU_keeper_OB_thing_GRD_rank_PositedAt = ISNULL(i.SU_keeper_OB_thing_GRD_rank_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(SU_keeper_OB_thing_GRD_rank_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_keeper_OB_thing_GRD_rank_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_keeper_OB_thing_GRD_rank_ID
                        FROM
                            [dbo].[tSU_keeper_OB_thing_GRD_rank](v.SU_keeper_OB_thing_GRD_rank_Positor, v.SU_keeper_OB_thing_GRD_rank_ChangedAt, v.SU_keeper_OB_thing_GRD_rank_PositedAt, v.SU_keeper_OB_thing_GRD_rank_Assertion) t
                        WHERE
                            t.SU_keeper_OB_thing_GRD_rank_Reliability = v.SU_keeper_OB_thing_GRD_rank_Reliability
                        AND
                            t.SU_keeper_OB_thing_GRD_rank_ChangedAt = v.SU_keeper_OB_thing_GRD_rank_ChangedAt
                        AND
                            t.SU_ID_keeper = v.SU_ID_keeper
                        AND
                            t.OB_ID_thing = v.OB_ID_thing
                        AND
                            t.GRD_ID_rank = v.GRD_ID_rank
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_keeper_OB_thing_GRD_rank_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                pre.GRD_ID_rank
                            FROM
                                [dbo].[rSU_keeper_OB_thing_GRD_rank] (
                                    v.SU_keeper_OB_thing_GRD_rank_Positor,
                                    v.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                                    v.SU_keeper_OB_thing_GRD_rank_PositedAt
                                ) pre
                            WHERE
                                pre.SU_ID_keeper = v.SU_ID_keeper
                            AND
                                pre.OB_ID_thing = v.OB_ID_thing
                            AND
                                pre.SU_keeper_OB_thing_GRD_rank_ChangedAt < v.SU_keeper_OB_thing_GRD_rank_ChangedAt
                            AND
                                pre.SU_keeper_OB_thing_GRD_rank_Assertion = v.SU_keeper_OB_thing_GRD_rank_Assertion
                            ORDER BY
                                pre.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                                pre.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                        ) s
                        WHERE
                            s.GRD_ID_rank = v.GRD_ID_rank
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                fol.GRD_ID_rank
                            FROM
                                [dbo].[fSU_keeper_OB_thing_GRD_rank] (
                                    v.SU_keeper_OB_thing_GRD_rank_Positor,
                                    v.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                                    v.SU_keeper_OB_thing_GRD_rank_PositedAt
                                ) fol
                            WHERE
                                fol.SU_ID_keeper = v.SU_ID_keeper
                            AND
                                fol.OB_ID_thing = v.OB_ID_thing
                            AND
                                fol.SU_keeper_OB_thing_GRD_rank_ChangedAt > v.SU_keeper_OB_thing_GRD_rank_ChangedAt
                            AND
                                fol.SU_keeper_OB_thing_GRD_rank_Assertion = v.SU_keeper_OB_thing_GRD_rank_Assertion
                            ORDER BY
                                fol.SU_keeper_OB_thing_GRD_rank_ChangedAt ASC,
                                fol.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                        ) s
                        WHERE
                            s.GRD_ID_rank = v.GRD_ID_rank
                    )
                    THEN 'F' -- the following version restates this one, so it is retracted
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
        ON
            p.SU_ID_keeper = v.SU_ID_keeper
        AND
            p.OB_ID_thing = v.OB_ID_thing
        AND
            p.GRD_ID_rank = v.GRD_ID_rank
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v.SU_keeper_OB_thing_GRD_rank_ChangedAt
        WHERE
            v.SU_keeper_OB_thing_GRD_rank_Version = @currentVersion;
        INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] (
            SU_keeper_OB_thing_GRD_rank_ChangedAt,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            SU_keeper_OB_thing_GRD_rank_ChangedAt,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank
        FROM
            @inserted
        WHERE
            SU_keeper_OB_thing_GRD_rank_Version = @currentVersion
        AND
            SU_keeper_OB_thing_GRD_rank_StatementType in ('N','F');
        -- retract the following versions that the new ones make restatements
        INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
        )
        SELECT
            v.Metadata_SU_keeper_OB_thing_GRD_rank,
            fol.SU_keeper_OB_thing_GRD_rank_ID,
            v.SU_keeper_OB_thing_GRD_rank_Positor,
            v.SU_keeper_OB_thing_GRD_rank_PositedAt,
            0
        FROM
            @inserted v
        CROSS APPLY (
            SELECT TOP 1
                f.SU_keeper_OB_thing_GRD_rank_ID,
                f.GRD_ID_rank
            FROM
                [dbo].[fSU_keeper_OB_thing_GRD_rank] (
                    v.SU_keeper_OB_thing_GRD_rank_Positor,
                    v.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                    v.SU_keeper_OB_thing_GRD_rank_PositedAt
                ) f
            WHERE
                f.SU_ID_keeper = v.SU_ID_keeper
            AND
                f.OB_ID_thing = v.OB_ID_thing
            AND
                f.SU_keeper_OB_thing_GRD_rank_ChangedAt > v.SU_keeper_OB_thing_GRD_rank_ChangedAt
            AND
                f.SU_keeper_OB_thing_GRD_rank_Assertion = v.SU_keeper_OB_thing_GRD_rank_Assertion
            ORDER BY
                f.SU_keeper_OB_thing_GRD_rank_ChangedAt ASC,
                f.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        ) fol
        WHERE
            v.SU_keeper_OB_thing_GRD_rank_Version = @currentVersion
        AND
            v.SU_keeper_OB_thing_GRD_rank_StatementType = 'F'
        AND
            fol.GRD_ID_rank = v.GRD_ID_rank;
        INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
        )
        SELECT
            v.Metadata_SU_keeper_OB_thing_GRD_rank,
            p.SU_keeper_OB_thing_GRD_rank_ID,
            v.SU_keeper_OB_thing_GRD_rank_Positor,
            v.SU_keeper_OB_thing_GRD_rank_PositedAt,
            v.SU_keeper_OB_thing_GRD_rank_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
        ON
            p.SU_ID_keeper = v.SU_ID_keeper
        AND
            p.OB_ID_thing = v.OB_ID_thing
        AND
            p.GRD_ID_rank = v.GRD_ID_rank
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v.SU_keeper_OB_thing_GRD_rank_ChangedAt
        WHERE
            v.SU_keeper_OB_thing_GRD_rank_Version = @currentVersion
        AND
            v.SU_keeper_OB_thing_GRD_rank_StatementType in ('S','N','F');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lSU_keeper_OB_thing_GRD_rank] ON [dbo].[lSU_keeper_OB_thing_GRD_rank]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        i.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        i.SU_ID_keeper,
        i.OB_ID_thing,
        ISNULL(i.GRD_ID_rank, [GRD_rank].GRD_ID),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Positor, i.Positor),
        i.SU_keeper_OB_thing_GRD_rank_PositedAt,
        i.SU_keeper_OB_thing_GRD_rank_Reliability
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_rank]
    ON
        [GRD_rank].GRD_Grade = i.rank_GRD_Grade;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_keeper_OB_thing_GRD_rank instead of UPDATE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lSU_keeper_OB_thing_GRD_rank] ON [dbo].[lSU_keeper_OB_thing_GRD_rank]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(SU_keeper_OB_thing_GRD_rank_Assertion))
        RAISERROR('The computed assertion column SU_keeper_OB_thing_GRD_rank_Assertion is not updatable.', 16, 1);
    IF(UPDATE(SU_keeper_OB_thing_GRD_rank_ID))
        RAISERROR('The identity column SU_keeper_OB_thing_GRD_rank_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ID_keeper))
        RAISERROR('The identity column SU_ID_keeper is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_thing))
        RAISERROR('The identity column OB_ID_thing is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        i.SU_keeper_OB_thing_GRD_rank_ID,
        ISNULL(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_Positor) THEN i.SU_keeper_OB_thing_GRD_rank_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_PositedAt) THEN i.SU_keeper_OB_thing_GRD_rank_PositedAt
            WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt) THEN i.SU_keeper_OB_thing_GRD_rank_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_rank]
    ON
        [GRD_rank].GRD_Grade = i.rank_GRD_Grade
    WHERE
        i.SU_keeper_OB_thing_GRD_rank_ID is not null
    AND (
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        cast(CASE
            WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt) THEN i.SU_keeper_OB_thing_GRD_rank_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_keeper_OB_thing_GRD_rank_ID = i.SU_keeper_OB_thing_GRD_rank_ID
                AND
                    d.SU_keeper_OB_thing_GRD_rank_Positor = i.SU_keeper_OB_thing_GRD_rank_Positor
                AND
                    d.GRD_ID_rank = CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END
            ) THEN i.SU_keeper_OB_thing_GRD_rank_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.SU_ID_keeper,
        i.OB_ID_thing,
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END,
        ISNULL(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_Positor) THEN i.SU_keeper_OB_thing_GRD_rank_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_PositedAt) THEN i.SU_keeper_OB_thing_GRD_rank_PositedAt ELSE @now END as datetime2),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1)
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_rank]
    ON
        [GRD_rank].GRD_Grade = i.rank_GRD_Grade
    WHERE
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt) OR
            UPDATE(SU_keeper_OB_thing_GRD_rank_PositedAt) OR
            UPDATE(SU_keeper_OB_thing_GRD_rank_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_keeper_OB_thing_GRD_rank_ID = i.SU_keeper_OB_thing_GRD_rank_ID
                AND
                    d.SU_keeper_OB_thing_GRD_rank_Positor = i.SU_keeper_OB_thing_GRD_rank_Positor
                AND
                    d.GRD_ID_rank = CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END
                AND
                    d.SU_keeper_OB_thing_GRD_rank_Reliability = ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1)
            )
        );
    -- indecisive: other values at the same changing time are a correction, which also retracts the shown posit
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        d.SU_keeper_OB_thing_GRD_rank_ID,
        d.SU_keeper_OB_thing_GRD_rank_Positor,
        cast(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_PositedAt) THEN i.SU_keeper_OB_thing_GRD_rank_PositedAt ELSE @now END as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_rank]
    ON
        [GRD_rank].GRD_Grade = i.rank_GRD_Grade
    JOIN
        deleted d
    ON
        d.SU_keeper_OB_thing_GRD_rank_ID = i.SU_keeper_OB_thing_GRD_rank_ID
    AND
        d.SU_keeper_OB_thing_GRD_rank_Positor = i.SU_keeper_OB_thing_GRD_rank_Positor
    WHERE (
        d.GRD_ID_rank <> CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END
    )
    AND
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END is not null
    AND
        UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt)
    AND
        d.SU_keeper_OB_thing_GRD_rank_ChangedAt = i.SU_keeper_OB_thing_GRD_rank_ChangedAt
    AND
        d.SU_keeper_OB_thing_GRD_rank_Positor = ISNULL(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_Positor) THEN i.SU_keeper_OB_thing_GRD_rank_Positor ELSE i.Positor END, 0)
    AND
        d.SU_keeper_OB_thing_GRD_rank_PositedAt < cast(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_PositedAt) THEN i.SU_keeper_OB_thing_GRD_rank_PositedAt ELSE @now END as datetime2)
    AND
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1) > 0;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_keeper_OB_thing_GRD_rank instead of DELETE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lSU_keeper_OB_thing_GRD_rank] ON [dbo].[lSU_keeper_OB_thing_GRD_rank]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        d.Metadata_SU_keeper_OB_thing_GRD_rank,
        d.SU_keeper_OB_thing_GRD_rank_ID,
        d.SU_keeper_OB_thing_GRD_rank_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itOB_part_SU_owner instead of INSERT trigger on OB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_OB_part_SU_owner', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_OB_part_SU_owner];
GO
CREATE TRIGGER [dbo].[it_OB_part_SU_owner] ON [dbo].[OB_part_SU_owner]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_OB_part_SU_owner int not null,
        OB_part_SU_owner_Version bigint not null,
        OB_part_SU_owner_StatementType char(1) not null,
        OB_part_SU_owner_Positor tinyint not null,
        OB_part_SU_owner_PositedAt datetime2 not null,
        OB_part_SU_owner_Reliability decimal(5,2) not null,
        OB_part_SU_owner_Assertion char(1) not null,
        OB_ID_part int not null,
        SU_ID_owner int not null,
        primary key (
            OB_part_SU_owner_Version,
            OB_part_SU_owner_Positor,
            OB_ID_part
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.OB_ID_part,
            i.SU_ID_owner,
            ISNULL(i.OB_part_SU_owner_Positor, 0) AS OB_part_SU_owner_Positor,
            ISNULL(i.OB_part_SU_owner_PositedAt, @now) AS OB_part_SU_owner_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[OB_part_SU_owner_Posit] p
            JOIN
                [dbo].[OB_part_SU_owner_Annex] a
            ON
                a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            WHERE
                p.OB_ID_part = i.OB_ID_part
            AND
                p.SU_ID_owner = i.SU_ID_owner
            AND
                a.OB_part_SU_owner_Positor = ISNULL(i.OB_part_SU_owner_Positor, 0)
            AND
                a.OB_part_SU_owner_PositedAt = ISNULL(i.OB_part_SU_owner_PositedAt, @now)
            AND
                a.OB_part_SU_owner_Reliability <> ISNULL(i.OB_part_SU_owner_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in OB_part_SU_owner for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_OB_part_SU_owner, 0),
        DENSE_RANK() OVER (
            PARTITION BY
                i.OB_part_SU_owner_Positor,
                i.OB_ID_part
            ORDER BY
                i.OB_part_SU_owner_PositedAt ASC,
                i.OB_part_SU_owner_Reliability ASC
        ),
        'X',
        ISNULL(i.OB_part_SU_owner_Positor, 0),
        ISNULL(i.OB_part_SU_owner_PositedAt, @now),
        ISNULL(i.OB_part_SU_owner_Reliability, 1),
        CAST(
            case
                when i.OB_part_SU_owner_Reliability > 0 then '+'
                when i.OB_part_SU_owner_Reliability = 0 then '?'
                when i.OB_part_SU_owner_Reliability < 0 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.OB_ID_part,
        i.SU_ID_owner
    FROM
        inserted i
    WHERE
        i.OB_ID_part is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [dbo].[OB_part_SU_owner_Posit] p
            JOIN
                [dbo].[OB_part_SU_owner_Annex] a
            ON
                a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            WHERE
                p.OB_ID_part = i.OB_ID_part
            AND
                p.SU_ID_owner = i.SU_ID_owner
            AND
                a.OB_part_SU_owner_Positor = ISNULL(i.OB_part_SU_owner_Positor, 0)
            AND
                a.OB_part_SU_owner_PositedAt = ISNULL(i.OB_part_SU_owner_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(OB_part_SU_owner_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.OB_part_SU_owner_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.OB_part_SU_owner_ID
                        FROM
                            [dbo].[tOB_part_SU_owner](v.OB_part_SU_owner_Positor, DEFAULT, v.OB_part_SU_owner_PositedAt, v.OB_part_SU_owner_Assertion) t
                        WHERE
                            t.OB_part_SU_owner_Reliability = v.OB_part_SU_owner_Reliability
                        AND
                            t.OB_ID_part = v.OB_ID_part
                        AND
                            t.SU_ID_owner = v.SU_ID_owner
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.OB_part_SU_owner_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [dbo].[OB_part_SU_owner_Posit] p
        ON
            p.OB_ID_part = v.OB_ID_part
        AND
            p.SU_ID_owner = v.SU_ID_owner
        WHERE
            v.OB_part_SU_owner_Version = @currentVersion;
        INSERT INTO [dbo].[OB_part_SU_owner_Posit] (
            OB_ID_part,
            SU_ID_owner
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            OB_ID_part,
            SU_ID_owner
        FROM
            @inserted
        WHERE
            OB_part_SU_owner_Version = @currentVersion
        AND
            OB_part_SU_owner_StatementType in ('N');
        INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_part_SU_owner_Positor,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Reliability
        )
        SELECT
            v.Metadata_OB_part_SU_owner,
            p.OB_part_SU_owner_ID,
            v.OB_part_SU_owner_Positor,
            v.OB_part_SU_owner_PositedAt,
            v.OB_part_SU_owner_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[OB_part_SU_owner_Posit] p
        ON
            p.OB_ID_part = v.OB_ID_part
        AND
            p.SU_ID_owner = v.SU_ID_owner
        WHERE
            v.OB_part_SU_owner_Version = @currentVersion
        AND
            v.OB_part_SU_owner_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_part_SU_owner instead of INSERT trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lOB_part_SU_owner] ON [dbo].[lOB_part_SU_owner]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[OB_part_SU_owner] (
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_ID_part,
        i.SU_ID_owner,
        ISNULL(i.OB_part_SU_owner_Positor, i.Positor),
        i.OB_part_SU_owner_PositedAt,
        i.OB_part_SU_owner_Reliability
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_part_SU_owner instead of UPDATE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lOB_part_SU_owner] ON [dbo].[lOB_part_SU_owner]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(OB_part_SU_owner_Assertion))
        RAISERROR('The computed assertion column OB_part_SU_owner_Assertion is not updatable.', 16, 1);
    IF(UPDATE(OB_part_SU_owner_ID))
        RAISERROR('The identity column OB_part_SU_owner_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_part))
        RAISERROR('The identity column OB_ID_part is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_part_SU_owner_ID,
        ISNULL(CASE WHEN UPDATE(OB_part_SU_owner_Positor) THEN i.OB_part_SU_owner_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(OB_part_SU_owner_PositedAt) THEN i.OB_part_SU_owner_PositedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    WHERE
        i.OB_part_SU_owner_ID is not null
    AND (
        i.SU_ID_owner is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[OB_part_SU_owner] (
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_ID_part,
        i.SU_ID_owner,
        ISNULL(CASE WHEN UPDATE(OB_part_SU_owner_Positor) THEN i.OB_part_SU_owner_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(OB_part_SU_owner_PositedAt) THEN i.OB_part_SU_owner_PositedAt ELSE @now END as datetime2),
        ISNULL(i.OB_part_SU_owner_Reliability, 1)
    FROM
        inserted i
    WHERE
        i.SU_ID_owner is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(OB_part_SU_owner_PositedAt) OR
            UPDATE(OB_part_SU_owner_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.OB_part_SU_owner_ID = i.OB_part_SU_owner_ID
                AND
                    d.OB_part_SU_owner_Positor = i.OB_part_SU_owner_Positor
                AND
                    d.SU_ID_owner = i.SU_ID_owner
                AND
                    d.OB_part_SU_owner_Reliability = ISNULL(i.OB_part_SU_owner_Reliability, 1)
            )
        );
    -- indecisive: other values are a correction, which also retracts the shown posit
    INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        d.OB_part_SU_owner_ID,
        d.OB_part_SU_owner_Positor,
        cast(CASE WHEN UPDATE(OB_part_SU_owner_PositedAt) THEN i.OB_part_SU_owner_PositedAt ELSE @now END as datetime2),
        0
    FROM
        inserted i
    JOIN
        deleted d
    ON
        d.OB_part_SU_owner_ID = i.OB_part_SU_owner_ID
    AND
        d.OB_part_SU_owner_Positor = i.OB_part_SU_owner_Positor
    WHERE (
        d.SU_ID_owner <> i.SU_ID_owner
    )
    AND
        i.SU_ID_owner is not null
    AND
        d.OB_part_SU_owner_Positor = ISNULL(CASE WHEN UPDATE(OB_part_SU_owner_Positor) THEN i.OB_part_SU_owner_Positor ELSE i.Positor END, 0)
    AND
        d.OB_part_SU_owner_PositedAt < cast(CASE WHEN UPDATE(OB_part_SU_owner_PositedAt) THEN i.OB_part_SU_owner_PositedAt ELSE @now END as datetime2)
    AND
        ISNULL(i.OB_part_SU_owner_Reliability, 1) > 0;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_part_SU_owner instead of DELETE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lOB_part_SU_owner] ON [dbo].[lOB_part_SU_owner]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        d.Metadata_OB_part_SU_owner,
        d.OB_part_SU_owner_ID,
        d.OB_part_SU_owner_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itSU_partner_SU_with instead of INSERT trigger on SU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_partner_SU_with', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_partner_SU_with];
GO
CREATE TRIGGER [dbo].[it_SU_partner_SU_with] ON [dbo].[SU_partner_SU_with]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_SU_partner_SU_with int not null,
        SU_partner_SU_with_ChangedAt datetime2 not null,
        SU_partner_SU_with_Version bigint not null,
        SU_partner_SU_with_StatementType char(1) not null,
        SU_partner_SU_with_Positor tinyint not null,
        SU_partner_SU_with_PositedAt datetime2 not null,
        SU_partner_SU_with_Reliability decimal(5,2) not null,
        SU_partner_SU_with_Assertion char(1) not null,
        SU_ID_partner int not null,
        SU_ID_with int not null,
        primary key (
            SU_partner_SU_with_Version,
            SU_partner_SU_with_Positor,
            SU_ID_partner,
            SU_ID_with
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_partner,
            i.SU_ID_with,
            ISNULL(i.SU_partner_SU_with_ChangedAt, @now) AS SU_partner_SU_with_ChangedAt,
            ISNULL(i.SU_partner_SU_with_Positor, 0) AS SU_partner_SU_with_Positor,
            ISNULL(i.SU_partner_SU_with_PositedAt, @now) AS SU_partner_SU_with_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_partner_SU_with_Posit] p
            JOIN
                [dbo].[SU_partner_SU_with_Annex] a
            ON
                a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            WHERE
                p.SU_ID_partner = i.SU_ID_partner
            AND
                p.SU_ID_with = i.SU_ID_with
            AND
                p.SU_partner_SU_with_ChangedAt = ISNULL(i.SU_partner_SU_with_ChangedAt, @now)
            AND
                a.SU_partner_SU_with_Positor = ISNULL(i.SU_partner_SU_with_Positor, 0)
            AND
                a.SU_partner_SU_with_PositedAt = ISNULL(i.SU_partner_SU_with_PositedAt, @now)
            AND
                a.SU_partner_SU_with_Reliability <> ISNULL(i.SU_partner_SU_with_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_partner_SU_with for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_partner_SU_with, 0),
        ISNULL(i.SU_partner_SU_with_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_partner_SU_with_Positor,
                i.SU_ID_partner,
                i.SU_ID_with
            ORDER BY
                ISNULL(i.SU_partner_SU_with_ChangedAt, @now),
                i.SU_partner_SU_with_PositedAt ASC,
                i.SU_partner_SU_with_Reliability ASC
        ),
        'X',
        ISNULL(i.SU_partner_SU_with_Positor, 0),
        ISNULL(i.SU_partner_SU_with_PositedAt, @now),
        ISNULL(i.SU_partner_SU_with_Reliability, 1),
        CAST(
            case
                when i.SU_partner_SU_with_Reliability > 0 then '+'
                when i.SU_partner_SU_with_Reliability = 0 then '?'
                when i.SU_partner_SU_with_Reliability < 0 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.SU_ID_partner,
        i.SU_ID_with
    FROM
        inserted i
    WHERE
        i.SU_ID_partner is not null
    AND
        i.SU_ID_with is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_partner_SU_with_Posit] p
            JOIN
                [dbo].[SU_partner_SU_with_Annex] a
            ON
                a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            WHERE
                p.SU_ID_partner = i.SU_ID_partner
            AND
                p.SU_ID_with = i.SU_ID_with
            AND
                p.SU_partner_SU_with_ChangedAt = ISNULL(i.SU_partner_SU_with_ChangedAt, @now)
            AND
                a.SU_partner_SU_with_Positor = ISNULL(i.SU_partner_SU_with_Positor, 0)
            AND
                a.SU_partner_SU_with_PositedAt = ISNULL(i.SU_partner_SU_with_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(SU_partner_SU_with_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_partner_SU_with_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_partner_SU_with_ID
                        FROM
                            [dbo].[tSU_partner_SU_with](v.SU_partner_SU_with_Positor, v.SU_partner_SU_with_ChangedAt, v.SU_partner_SU_with_PositedAt, v.SU_partner_SU_with_Assertion) t
                        WHERE
                            t.SU_partner_SU_with_Reliability = v.SU_partner_SU_with_Reliability
                        AND
                            t.SU_partner_SU_with_ChangedAt = v.SU_partner_SU_with_ChangedAt
                        AND
                            t.SU_ID_partner = v.SU_ID_partner
                        AND
                            t.SU_ID_with = v.SU_ID_with
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_partner_SU_with_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                pre.SU_ID_partner,
                                pre.SU_ID_with
                            FROM
                                [dbo].[rSU_partner_SU_with] (
                                    v.SU_partner_SU_with_Positor,
                                    v.SU_partner_SU_with_ChangedAt,
                                    v.SU_partner_SU_with_PositedAt
                                ) pre
                            WHERE
                            (
                                    pre.SU_ID_partner = v.SU_ID_partner
                                AND
                                    pre.SU_ID_with = v.SU_ID_with
                            )
                            AND
                                pre.SU_partner_SU_with_ChangedAt < v.SU_partner_SU_with_ChangedAt
                            AND
                                pre.SU_partner_SU_with_Assertion = v.SU_partner_SU_with_Assertion
                            ORDER BY
                                pre.SU_partner_SU_with_ChangedAt DESC,
                                pre.SU_partner_SU_with_PositedAt DESC
                        ) s
                        WHERE
                            s.SU_ID_partner = v.SU_ID_partner
                        AND
                            s.SU_ID_with = v.SU_ID_with
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                fol.SU_ID_partner,
                                fol.SU_ID_with
                            FROM
                                [dbo].[fSU_partner_SU_with] (
                                    v.SU_partner_SU_with_Positor,
                                    v.SU_partner_SU_with_ChangedAt,
                                    v.SU_partner_SU_with_PositedAt
                                ) fol
                            WHERE
                            (
                                    fol.SU_ID_partner = v.SU_ID_partner
                                AND
                                    fol.SU_ID_with = v.SU_ID_with
                            )
                            AND
                                fol.SU_partner_SU_with_ChangedAt > v.SU_partner_SU_with_ChangedAt
                            AND
                                fol.SU_partner_SU_with_Assertion = v.SU_partner_SU_with_Assertion
                            ORDER BY
                                fol.SU_partner_SU_with_ChangedAt ASC,
                                fol.SU_partner_SU_with_PositedAt DESC
                        ) s
                        WHERE
                            s.SU_ID_partner = v.SU_ID_partner
                        AND
                            s.SU_ID_with = v.SU_ID_with
                    )
                    THEN 'R' -- restatement of the following version
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [dbo].[SU_partner_SU_with_Posit] p
        ON
            p.SU_ID_partner = v.SU_ID_partner
        AND
            p.SU_ID_with = v.SU_ID_with
        AND
            p.SU_partner_SU_with_ChangedAt = v.SU_partner_SU_with_ChangedAt
        WHERE
            v.SU_partner_SU_with_Version = @currentVersion;
        INSERT INTO [dbo].[SU_partner_SU_with_Posit] (
            SU_partner_SU_with_ChangedAt,
            SU_ID_partner,
            SU_ID_with
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            SU_partner_SU_with_ChangedAt,
            SU_ID_partner,
            SU_ID_with
        FROM
            @inserted
        WHERE
            SU_partner_SU_with_Version = @currentVersion
        AND
            SU_partner_SU_with_StatementType in ('N','R');
        INSERT INTO [dbo].[SU_partner_SU_with_Annex] (
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_partner_SU_with_Positor,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Reliability
        )
        SELECT
            v.Metadata_SU_partner_SU_with,
            p.SU_partner_SU_with_ID,
            v.SU_partner_SU_with_Positor,
            v.SU_partner_SU_with_PositedAt,
            v.SU_partner_SU_with_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[SU_partner_SU_with_Posit] p
        ON
            p.SU_ID_partner = v.SU_ID_partner
        AND
            p.SU_ID_with = v.SU_ID_with
        AND
            p.SU_partner_SU_with_ChangedAt = v.SU_partner_SU_with_ChangedAt
        WHERE
            v.SU_partner_SU_with_Version = @currentVersion
        AND
            v.SU_partner_SU_with_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_partner_SU_with instead of INSERT trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lSU_partner_SU_with] ON [dbo].[lSU_partner_SU_with]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_partner_SU_with] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        i.SU_partner_SU_with_ChangedAt,
        i.SU_ID_partner,
        i.SU_ID_with,
        ISNULL(i.SU_partner_SU_with_Positor, i.Positor),
        i.SU_partner_SU_with_PositedAt,
        i.SU_partner_SU_with_Reliability
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_partner_SU_with instead of UPDATE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lSU_partner_SU_with] ON [dbo].[lSU_partner_SU_with]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(SU_partner_SU_with_Assertion))
        RAISERROR('The computed assertion column SU_partner_SU_with_Assertion is not updatable.', 16, 1);
    IF(UPDATE(SU_partner_SU_with_ID))
        RAISERROR('The identity column SU_partner_SU_with_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[SU_partner_SU_with_Annex] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        i.SU_partner_SU_with_ID,
        ISNULL(CASE WHEN UPDATE(SU_partner_SU_with_Positor) THEN i.SU_partner_SU_with_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(SU_partner_SU_with_PositedAt) THEN i.SU_partner_SU_with_PositedAt
            WHEN UPDATE(SU_partner_SU_with_ChangedAt) THEN i.SU_partner_SU_with_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    WHERE
        i.SU_partner_SU_with_ID is not null
    AND (
        i.SU_ID_partner is null
    OR
        i.SU_ID_with is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[SU_partner_SU_with] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        cast(CASE
            WHEN UPDATE(SU_partner_SU_with_ChangedAt) THEN i.SU_partner_SU_with_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_partner_SU_with_ID = i.SU_partner_SU_with_ID
                AND
                    d.SU_partner_SU_with_Positor = i.SU_partner_SU_with_Positor
                AND
                    d.SU_ID_partner = i.SU_ID_partner
                AND
                    d.SU_ID_with = i.SU_ID_with
            ) THEN i.SU_partner_SU_with_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.SU_ID_partner,
        i.SU_ID_with,
        ISNULL(CASE WHEN UPDATE(SU_partner_SU_with_Positor) THEN i.SU_partner_SU_with_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(SU_partner_SU_with_PositedAt) THEN i.SU_partner_SU_with_PositedAt ELSE @now END as datetime2),
        ISNULL(i.SU_partner_SU_with_Reliability, 1)
    FROM
        inserted i
    WHERE
        i.SU_ID_partner is not null
    AND
        i.SU_ID_with is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_partner_SU_with_ChangedAt) OR
            UPDATE(SU_partner_SU_with_PositedAt) OR
            UPDATE(SU_partner_SU_with_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_partner_SU_with_ID = i.SU_partner_SU_with_ID
                AND
                    d.SU_partner_SU_with_Positor = i.SU_partner_SU_with_Positor
                AND
                    d.SU_ID_partner = i.SU_ID_partner
                AND
                    d.SU_ID_with = i.SU_ID_with
                AND
                    d.SU_partner_SU_with_Reliability = ISNULL(i.SU_partner_SU_with_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_partner_SU_with instead of DELETE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lSU_partner_SU_with] ON [dbo].[lSU_partner_SU_with]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_partner_SU_with_Annex] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        d.Metadata_SU_partner_SU_with,
        d.SU_partner_SU_with_ID,
        d.SU_partner_SU_with_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssEV_PLC_Event_Place procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssEV_PLC_Event_Place', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssEV_PLC_Event_Place];
GO
CREATE PROCEDURE [dbo].[ssEV_PLC_Event_Place] (
    @EV_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), EV_PLC_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[EV_PLC_Event_Place]
        WHERE
            EV_PLC_EV_ID = ISNULL(@EV_ID, EV_PLC_EV_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        EV_PLC_Positor
    FROM
        [dbo].[EV_PLC_Event_Place]
    WHERE
        EV_PLC_EV_ID = ISNULL(@EV_ID, EV_PLC_EV_ID)
    AND
        EV_PLC_Event_Place is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.EV_PLC_Positor,
                x.EV_PLC_EV_ID,
                x.EV_PLC_PositedAt,
                b.EV_PLC_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    EV_PLC_EV_ID,
                    EV_PLC_PositedAt
                FROM
                    [dbo].[EV_PLC_Event_Place]
                WHERE
                    EV_PLC_EV_ID = ISNULL(@EV_ID, EV_PLC_EV_ID)
            ) x
            LEFT JOIN (
                SELECT
                    EV_PLC_Positor,
                    EV_PLC_EV_ID,
                    EV_PLC_PositedAt,
                    EV_PLC_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[EV_PLC_Event_Place]
                PIVOT (
                    MIN(EV_PLC_Event_Place) FOR EV_PLC_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    EV_PLC_EV_ID = ISNULL(@EV_ID, EV_PLC_EV_ID)
                AND
                    EV_PLC_Positor = ' + @positor + '
            ) b
            ON
                b.EV_PLC_EV_ID = x.EV_PLC_EV_ID
            AND
                b.EV_PLC_PositedAt = x.EV_PLC_PositedAt
            ORDER BY
                EV_PLC_EV_ID,
                EV_PLC_PositedAt,
                EV_PLC_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@EV_ID int', @EV_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_TTL_Subject_Title procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_TTL_Subject_Title', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_TTL_Subject_Title];
GO
CREATE PROCEDURE [dbo].[ssSU_TTL_Subject_Title] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_TTL_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_TTL_Subject_Title]
        WHERE
            SU_TTL_SU_ID = ISNULL(@SU_ID, SU_TTL_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_TTL_Positor
    FROM
        [dbo].[SU_TTL_Subject_Title]
    WHERE
        SU_TTL_SU_ID = ISNULL(@SU_ID, SU_TTL_SU_ID)
    AND
        SU_TTL_Subject_Title is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_TTL_Positor,
                x.SU_TTL_SU_ID,
                x.SU_TTL_PositedAt,
                b.SU_TTL_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_TTL_SU_ID,
                    SU_TTL_PositedAt
                FROM
                    [dbo].[SU_TTL_Subject_Title]
                WHERE
                    SU_TTL_SU_ID = ISNULL(@SU_ID, SU_TTL_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_TTL_Positor,
                    SU_TTL_SU_ID,
                    SU_TTL_PositedAt,
                    SU_TTL_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_TTL_Subject_Title]
                PIVOT (
                    MIN(SU_TTL_Subject_Title) FOR SU_TTL_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_TTL_SU_ID = ISNULL(@SU_ID, SU_TTL_SU_ID)
                AND
                    SU_TTL_Positor = ' + @positor + '
            ) b
            ON
                b.SU_TTL_SU_ID = x.SU_TTL_SU_ID
            AND
                b.SU_TTL_PositedAt = x.SU_TTL_PositedAt
            ORDER BY
                SU_TTL_SU_ID,
                SU_TTL_PositedAt,
                SU_TTL_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_STA_Subject_State procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_STA_Subject_State', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_STA_Subject_State];
GO
CREATE PROCEDURE [dbo].[ssSU_STA_Subject_State] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_STA_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_STA_Subject_State]
        WHERE
            SU_STA_SU_ID = ISNULL(@SU_ID, SU_STA_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_STA_Positor
    FROM
        [dbo].[SU_STA_Subject_State]
    WHERE
        SU_STA_SU_ID = ISNULL(@SU_ID, SU_STA_SU_ID)
    AND
        SU_STA_Subject_State is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_STA_Positor,
                x.SU_STA_SU_ID,
                x.SU_STA_PositedAt,
                b.SU_STA_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_STA_SU_ID,
                    SU_STA_PositedAt
                FROM
                    [dbo].[SU_STA_Subject_State]
                WHERE
                    SU_STA_SU_ID = ISNULL(@SU_ID, SU_STA_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_STA_Positor,
                    SU_STA_SU_ID,
                    SU_STA_PositedAt,
                    SU_STA_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_STA_Subject_State]
                PIVOT (
                    MIN(SU_STA_Subject_State) FOR SU_STA_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_STA_SU_ID = ISNULL(@SU_ID, SU_STA_SU_ID)
                AND
                    SU_STA_Positor = ' + @positor + '
            ) b
            ON
                b.SU_STA_SU_ID = x.SU_STA_SU_ID
            AND
                b.SU_STA_PositedAt = x.SU_STA_PositedAt
            ORDER BY
                SU_STA_SU_ID,
                SU_STA_PositedAt,
                SU_STA_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_LBL_Subject_Label procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_LBL_Subject_Label', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_LBL_Subject_Label];
GO
CREATE PROCEDURE [dbo].[ssSU_LBL_Subject_Label] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_LBL_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_LBL_Subject_Label]
        WHERE
            SU_LBL_SU_ID = ISNULL(@SU_ID, SU_LBL_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_LBL_Positor
    FROM
        [dbo].[SU_LBL_Subject_Label]
    WHERE
        SU_LBL_SU_ID = ISNULL(@SU_ID, SU_LBL_SU_ID)
    AND
        SU_LBL_Subject_Label is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_LBL_Positor,
                x.SU_LBL_SU_ID,
                x.SU_LBL_PositedAt,
                b.SU_LBL_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_LBL_SU_ID,
                    SU_LBL_PositedAt
                FROM
                    [dbo].[SU_LBL_Subject_Label]
                WHERE
                    SU_LBL_SU_ID = ISNULL(@SU_ID, SU_LBL_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_LBL_Positor,
                    SU_LBL_SU_ID,
                    SU_LBL_PositedAt,
                    SU_LBL_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_LBL_Subject_Label]
                PIVOT (
                    MIN(SU_LBL_Subject_Label) FOR SU_LBL_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_LBL_SU_ID = ISNULL(@SU_ID, SU_LBL_SU_ID)
                AND
                    SU_LBL_Positor = ' + @positor + '
            ) b
            ON
                b.SU_LBL_SU_ID = x.SU_LBL_SU_ID
            AND
                b.SU_LBL_PositedAt = x.SU_LBL_PositedAt
            ORDER BY
                SU_LBL_SU_ID,
                SU_LBL_PositedAt,
                SU_LBL_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_TAG_Subject_Tag procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_TAG_Subject_Tag', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_TAG_Subject_Tag];
GO
CREATE PROCEDURE [dbo].[ssSU_TAG_Subject_Tag] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_TAG_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_TAG_Subject_Tag]
        WHERE
            SU_TAG_SU_ID = ISNULL(@SU_ID, SU_TAG_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_TAG_Positor
    FROM
        [dbo].[SU_TAG_Subject_Tag]
    WHERE
        SU_TAG_SU_ID = ISNULL(@SU_ID, SU_TAG_SU_ID)
    AND
        SU_TAG_Subject_Tag is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_TAG_Positor,
                x.SU_TAG_SU_ID,
                x.SU_TAG_PositedAt,
                b.SU_TAG_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_TAG_SU_ID,
                    SU_TAG_PositedAt
                FROM
                    [dbo].[SU_TAG_Subject_Tag]
                WHERE
                    SU_TAG_SU_ID = ISNULL(@SU_ID, SU_TAG_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_TAG_Positor,
                    SU_TAG_SU_ID,
                    SU_TAG_PositedAt,
                    SU_TAG_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_TAG_Subject_Tag]
                PIVOT (
                    MIN(SU_TAG_Subject_Tag) FOR SU_TAG_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_TAG_SU_ID = ISNULL(@SU_ID, SU_TAG_SU_ID)
                AND
                    SU_TAG_Positor = ' + @positor + '
            ) b
            ON
                b.SU_TAG_SU_ID = x.SU_TAG_SU_ID
            AND
                b.SU_TAG_PositedAt = x.SU_TAG_PositedAt
            ORDER BY
                SU_TAG_SU_ID,
                SU_TAG_PositedAt,
                SU_TAG_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_LVL_Subject_Level procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_LVL_Subject_Level', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_LVL_Subject_Level];
GO
CREATE PROCEDURE [dbo].[ssSU_LVL_Subject_Level] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_LVL_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_LVL_Subject_Level]
        WHERE
            SU_LVL_SU_ID = ISNULL(@SU_ID, SU_LVL_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_LVL_Positor
    FROM
        [dbo].[SU_LVL_Subject_Level]
    WHERE
        SU_LVL_SU_ID = ISNULL(@SU_ID, SU_LVL_SU_ID)
    AND
        SU_LVL_GRD_ID is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_LVL_Positor,
                x.SU_LVL_SU_ID,
                x.SU_LVL_PositedAt,
                b.SU_LVL_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_LVL_SU_ID,
                    SU_LVL_PositedAt
                FROM
                    [dbo].[SU_LVL_Subject_Level]
                WHERE
                    SU_LVL_SU_ID = ISNULL(@SU_ID, SU_LVL_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_LVL_Positor,
                    SU_LVL_SU_ID,
                    SU_LVL_PositedAt,
                    SU_LVL_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_LVL_Subject_Level]
                PIVOT (
                    MIN(SU_LVL_GRD_ID) FOR SU_LVL_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_LVL_SU_ID = ISNULL(@SU_ID, SU_LVL_SU_ID)
                AND
                    SU_LVL_Positor = ' + @positor + '
            ) b
            ON
                b.SU_LVL_SU_ID = x.SU_LVL_SU_ID
            AND
                b.SU_LVL_PositedAt = x.SU_LVL_PositedAt
            ORDER BY
                SU_LVL_SU_ID,
                SU_LVL_PositedAt,
                SU_LVL_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_TXT_Subject_Text procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_TXT_Subject_Text', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_TXT_Subject_Text];
GO
CREATE PROCEDURE [dbo].[ssSU_TXT_Subject_Text] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_TXT_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_TXT_Subject_Text]
        WHERE
            SU_TXT_SU_ID = ISNULL(@SU_ID, SU_TXT_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_TXT_Positor
    FROM
        [dbo].[SU_TXT_Subject_Text]
    WHERE
        SU_TXT_SU_ID = ISNULL(@SU_ID, SU_TXT_SU_ID)
    AND
        SU_TXT_Subject_Text is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_TXT_Positor,
                x.SU_TXT_SU_ID,
                x.SU_TXT_PositedAt,
                b.SU_TXT_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_TXT_SU_ID,
                    SU_TXT_PositedAt
                FROM
                    [dbo].[SU_TXT_Subject_Text]
                WHERE
                    SU_TXT_SU_ID = ISNULL(@SU_ID, SU_TXT_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_TXT_Positor,
                    SU_TXT_SU_ID,
                    SU_TXT_PositedAt,
                    SU_TXT_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_TXT_Subject_Text]
                PIVOT (
                    MIN(SU_TXT_Subject_Text) FOR SU_TXT_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_TXT_SU_ID = ISNULL(@SU_ID, SU_TXT_SU_ID)
                AND
                    SU_TXT_Positor = ' + @positor + '
            ) b
            ON
                b.SU_TXT_SU_ID = x.SU_TXT_SU_ID
            AND
                b.SU_TXT_PositedAt = x.SU_TXT_PositedAt
            ORDER BY
                SU_TXT_SU_ID,
                SU_TXT_PositedAt,
                SU_TXT_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_ASR_Subject_Assessment procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_ASR_Subject_Assessment', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_ASR_Subject_Assessment];
GO
CREATE PROCEDURE [dbo].[ssSU_ASR_Subject_Assessment] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_ASR_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_ASR_Subject_Assessment]
        WHERE
            SU_ASR_SU_ID = ISNULL(@SU_ID, SU_ASR_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_ASR_Positor
    FROM
        [dbo].[SU_ASR_Subject_Assessment]
    WHERE
        SU_ASR_SU_ID = ISNULL(@SU_ID, SU_ASR_SU_ID)
    AND
        SU_ASR_Subject_Assessment is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_ASR_Positor,
                x.SU_ASR_SU_ID,
                x.SU_ASR_PositedAt,
                b.SU_ASR_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_ASR_SU_ID,
                    SU_ASR_PositedAt
                FROM
                    [dbo].[SU_ASR_Subject_Assessment]
                WHERE
                    SU_ASR_SU_ID = ISNULL(@SU_ID, SU_ASR_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_ASR_Positor,
                    SU_ASR_SU_ID,
                    SU_ASR_PositedAt,
                    SU_ASR_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_ASR_Subject_Assessment]
                PIVOT (
                    MIN(SU_ASR_Subject_Assessment) FOR SU_ASR_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_ASR_SU_ID = ISNULL(@SU_ID, SU_ASR_SU_ID)
                AND
                    SU_ASR_Positor = ' + @positor + '
            ) b
            ON
                b.SU_ASR_SU_ID = x.SU_ASR_SU_ID
            AND
                b.SU_ASR_PositedAt = x.SU_ASR_PositedAt
            ORDER BY
                SU_ASR_SU_ID,
                SU_ASR_PositedAt,
                SU_ASR_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_ERS_Subject_Erasable procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_ERS_Subject_Erasable', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_ERS_Subject_Erasable];
GO
CREATE PROCEDURE [dbo].[ssSU_ERS_Subject_Erasable] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_ERS_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_ERS_Subject_Erasable]
        WHERE
            SU_ERS_SU_ID = ISNULL(@SU_ID, SU_ERS_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_ERS_Positor
    FROM
        [dbo].[SU_ERS_Subject_Erasable]
    WHERE
        SU_ERS_SU_ID = ISNULL(@SU_ID, SU_ERS_SU_ID)
    AND
        SU_ERS_Subject_Erasable is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_ERS_Positor,
                x.SU_ERS_SU_ID,
                x.SU_ERS_PositedAt,
                b.SU_ERS_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_ERS_SU_ID,
                    SU_ERS_PositedAt
                FROM
                    [dbo].[SU_ERS_Subject_Erasable]
                WHERE
                    SU_ERS_SU_ID = ISNULL(@SU_ID, SU_ERS_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_ERS_Positor,
                    SU_ERS_SU_ID,
                    SU_ERS_PositedAt,
                    SU_ERS_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_ERS_Subject_Erasable]
                PIVOT (
                    MIN(SU_ERS_Subject_Erasable) FOR SU_ERS_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_ERS_SU_ID = ISNULL(@SU_ID, SU_ERS_SU_ID)
                AND
                    SU_ERS_Positor = ' + @positor + '
            ) b
            ON
                b.SU_ERS_SU_ID = x.SU_ERS_SU_ID
            AND
                b.SU_ERS_PositedAt = x.SU_ERS_PositedAt
            ORDER BY
                SU_ERS_SU_ID,
                SU_ERS_PositedAt,
                SU_ERS_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
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
   N'<schema format="0.101.4" date="2026-10-09" time="12:00:00">
<metadata changingRange="datetime2" encapsulation="dbo" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="true" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime2" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="decimal(5,2)" reliabilitySuffix="Reliability" defaultReliability="1" deleteReliability="0" assertionSuffix="Assertion" partitioning="false" entityIntegrity="true" restatability="true" idempotency="false" assertiveness="true" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="false" decisiveness="false" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="crt" deletability="false" deletablePrefix="Deletable" deletionSuffix="Deleted" privacy="Ignore" checksum="false" triggers="true" knotAliases="false" naturalKeyAttributes="false" />
<description>
A model for testing the triggers of the latest views: an attribute for each combination of the settings that the
triggers read (restatable, idempotent, assertive, deletable, checksum, knotted, static or historized), ties with and
without identifiers, and a nexus with an attribute. The scripts in sqlserver-tests/ run against its output.
</description>
<knot mnemonic="GRD" descriptor="Grade" identity="tinyint" dataRange="nvarchar(42)">
<metadata capsule="dbo" generator="false" />
<layout x="514.71" y="209.97" fixed="false" />
<description>
A grade, used by knotted attributes and by the value roles of ties.
</description>
</knot>
<anchor mnemonic="SU" descriptor="Subject" identity="int">
<metadata capsule="dbo" generator="true" />
<attribute mnemonic="NAM" descriptor="Name" identity="int" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" idempotent="false" deletable="false" />
<layout x="338.35" y="444.47" fixed="false" />
<description>
Static.
</description>
</attribute>
<attribute mnemonic="COD" descriptor="Code" identity="int" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" idempotent="true" deletable="false" />
<layout x="462.21" y="22.46" fixed="false" />
<description>
Static and idempotent.
</description>
</attribute>
<attribute mnemonic="GRD" descriptor="Grade" identity="int" knotRange="GRD">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" idempotent="false" deletable="false" />
<layout x="693.16" y="69.30" fixed="false" />
<description>
Static and knotted.
</description>
</attribute>
<attribute mnemonic="NOT" descriptor="Note" identity="int" dataRange="nvarchar(max)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" checksum="true" idempotent="false" deletable="false" />
<layout x="691.37" y="260.74" fixed="false" />
<description>
Static, with a checksum.
</description>
</attribute>
<attribute mnemonic="TTL" descriptor="Title" identity="int" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" restatable="true" idempotent="false" deletable="false" />
<layout x="586.06" y="359.40" fixed="false" />
<description>
Historized, restatable.
</description>
</attribute>
<attribute mnemonic="STA" descriptor="State" identity="int" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" restatable="false" idempotent="false" deletable="false" />
<layout x="171.44" y="145.51" fixed="false" />
<description>
Historized, not restatable: a restatement is an error.
</description>
</attribute>
<attribute mnemonic="LBL" descriptor="Label" identity="int" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" restatable="false" idempotent="true" deletable="false" />
<layout x="672.99" y="69.40" fixed="false" />
<description>
Historized, not restatable and idempotent: a restatement is skipped.
</description>
</attribute>
<attribute mnemonic="TAG" descriptor="Tag" identity="int" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" restatable="true" idempotent="true" deletable="false" />
<layout x="124.58" y="55.45" fixed="false" />
<description>
Historized, restatable and idempotent: a restatement is skipped.
</description>
</attribute>
<attribute mnemonic="LVL" descriptor="Level" identity="int" timeRange="datetime2" knotRange="GRD">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" restatable="true" idempotent="false" deletable="false" />
<layout x="595.66" y="366.57" fixed="false" />
<description>
Historized and knotted.
</description>
</attribute>
<attribute mnemonic="TXT" descriptor="Text" identity="int" timeRange="datetime2" dataRange="nvarchar(max)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" checksum="true" restatable="true" idempotent="false" deletable="false" />
<layout x="161.78" y="299.68" fixed="false" />
<description>
Historized, with a checksum.
</description>
</attribute>
<attribute mnemonic="ASR" descriptor="Assessment" identity="int" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="false" restatable="true" idempotent="false" deletable="false" />
<layout x="38.94" y="13.34" fixed="false" />
<description>
Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).
</description>
</attribute>
<attribute mnemonic="ERS" descriptor="Erasable" identity="int" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" restatable="true" idempotent="false" deletable="true" />
<layout x="702.84" y="234.70" fixed="false" />
<description>
Historized and deletable (uni-temporal).
</description>
</attribute>
<layout x="536.84" y="394.14" fixed="false" />
<description>
The subject of the tests.
</description>
</anchor>
<anchor mnemonic="OB" descriptor="Object" identity="int">
<metadata capsule="dbo" generator="true" />
<attribute mnemonic="NAM" descriptor="Name" identity="int" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" idempotent="false" deletable="false" />
<layout x="105.77" y="236.02" fixed="false" />
<description>
Static.
</description>
</attribute>
<layout x="210.81" y="66.61" fixed="false" />
<description>
Something the subject has or keeps.
</description>
</anchor>
<nexus mnemonic="EV" descriptor="Event" identity="int">
<metadata capsule="dbo" generator="true" />
<attribute mnemonic="QTY" descriptor="Quantity" identity="int" dataRange="int">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" idempotent="false" deletable="false" />
<layout x="707.79" y="332.18" fixed="false" />
<description>
Static.
</description>
</attribute>
<attribute mnemonic="PLC" descriptor="Place" identity="int" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" generator="true" assertive="true" restatable="false" idempotent="false" deletable="false" />
<layout x="460.00" y="140.00" fixed="false" />
<description>
Historized and not restatable, as an attribute of an anchor may be.
</description>
</attribute>
<role role="for" type="SU" identifier="false">
<description>
The subject the event is for.
</description>
</role>
<layout x="649.43" y="274.34" fixed="false" />
<description>
An event, with attributes of its own, a static one and a historized one.
</description>
</nexus>
<tie identity="int" timeRange="datetime2">
<role role="holder" type="SU" identifier="true">
<description>
The subject of the tests.
</description>
</role>
<role role="item" type="OB" identifier="true">
<description>
Something the subject has or keeps.
</description>
</role>
<role role="grade" type="GRD" identifier="false">
<description>
A grade, used by knotted attributes and by the value roles of ties.
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="true" restatable="true" deletable="false" idempotent="false" />
<layout x="678.49" y="33.31" fixed="false" />
<description>
Historized, with identifiers and a knotted value role, restatable.
</description>
</tie>
<tie identity="int" timeRange="datetime2">
<role role="keeper" type="SU" identifier="true">
<description>
The subject of the tests.
</description>
</role>
<role role="thing" type="OB" identifier="true">
<description>
Something the subject has or keeps.
</description>
</role>
<role role="rank" type="GRD" identifier="false">
<description>
A grade, used by knotted attributes and by the value roles of ties.
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="false" restatable="false" deletable="false" idempotent="true" />
<layout x="97.00" y="341.33" fixed="false" />
<description>
Historized, with identifiers and a knotted value role, idempotent and not assertive.
</description>
</tie>
<tie identity="int">
<role role="part" type="OB" identifier="true">
<description>
Something the subject has or keeps.
</description>
</role>
<role role="owner" type="SU" identifier="false">
<description>
The subject of the tests.
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="true" deletable="false" idempotent="false" />
<layout x="236.41" y="66.65" fixed="false" />
<description>
Static, with an identifier and a value role: each object has one owner.
</description>
</tie>
<tie identity="int" timeRange="datetime2">
<role role="partner" type="SU" identifier="false">
<description>
The subject of the tests.
</description>
</role>
<role role="with" type="SU" identifier="false">
<description>
The subject of the tests.
</description>
</role>
<metadata capsule="dbo" generator="true" assertive="true" restatable="true" deletable="false" idempotent="false" />
<layout x="85.24" y="156.10" fixed="false" />
<description>
Historized, without identifiers.
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
@level1type = N'Table', @level1name = 'GRD_Grade';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A grade, used by knotted attributes and by the value roles of ties.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'GRD_Grade';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_Subject';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_Subject';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NAM_Subject_Name_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NAM_Subject_Name_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_COD_Subject_Code_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static and idempotent.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_COD_Subject_Code_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_GRD_Subject_Grade_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static and knotted.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_GRD_Subject_Grade_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NOT_Subject_Note_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static, with a checksum.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NOT_Subject_Note_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TTL_Subject_Title_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, restatable.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TTL_Subject_Title_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_STA_Subject_State_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not restatable: a restatement is an error.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_STA_Subject_State_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LBL_Subject_Label_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not restatable and idempotent: a restatement is skipped.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LBL_Subject_Label_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TAG_Subject_Tag_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, restatable and idempotent: a restatement is skipped.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TAG_Subject_Tag_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LVL_Subject_Level_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized and knotted.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LVL_Subject_Level_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TXT_Subject_Text_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with a checksum.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TXT_Subject_Text_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ASR_Subject_Assessment_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ASR_Subject_Assessment_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ERS_Subject_Erasable_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized and deletable (uni-temporal).
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ERS_Subject_Erasable_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_Object';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_Object';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_NAM_Object_Name_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_NAM_Object_Name_Posit';
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
An event, with attributes of its own, a static one and a historized one.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_QTY_Event_Quantity_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_QTY_Event_Quantity_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_PLC_Event_Place_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized and not restatable, as an attribute of an anchor may be.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_PLC_Event_Place_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'SU_ID_for';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject the event is for.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'SU_ID_for';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with identifiers and a knotted value role, restatable.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'SU_ID_holder';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'SU_ID_holder';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'OB_ID_item';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'OB_ID_item';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'GRD_ID_grade';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A grade, used by knotted attributes and by the value roles of ties.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'GRD_ID_grade';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with identifiers and a knotted value role, idempotent and not assertive.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'SU_ID_keeper';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'SU_ID_keeper';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'OB_ID_thing';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'OB_ID_thing';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'GRD_ID_rank';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A grade, used by knotted attributes and by the value roles of ties.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'GRD_ID_rank';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static, with an identifier and a value role: each object has one owner.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit',
@level2type = N'Column', @level2name = 'OB_ID_part';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit',
@level2type = N'Column', @level2name = 'OB_ID_part';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit',
@level2type = N'Column', @level2name = 'SU_ID_owner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit',
@level2type = N'Column', @level2name = 'SU_ID_owner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, without identifiers.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit',
@level2type = N'Column', @level2name = 'SU_ID_partner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit',
@level2type = N'Column', @level2name = 'SU_ID_partner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit',
@level2type = N'Column', @level2name = 'SU_ID_with';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit',
@level2type = N'Column', @level2name = 'SU_ID_with';
GO
