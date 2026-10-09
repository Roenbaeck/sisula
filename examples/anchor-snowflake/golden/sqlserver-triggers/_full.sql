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
-- Knots are unfolded when using equivalence.
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
-- EV_Event table (with 1 attributes and 1 roles)
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
-- This unified script creates all attribute tables using the global attribute iterator.
--
-- Static attribute table --------------------------------------------------------------------------------------------
-- EV_QTY_Event_Quantity table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_QTY_Event_Quantity', 'U') IS NULL
CREATE TABLE [dbo].[EV_QTY_Event_Quantity] (
    EV_QTY_EV_ID int not null,
    EV_QTY_Event_Quantity int not null,
    Metadata_EV_QTY int not null,
    constraint fkEV_QTY_Event_Quantity foreign key (
        EV_QTY_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_QTY_Event_Quantity primary key (
        EV_QTY_EV_ID asc
    )
);
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_NAM_Subject_Name', 'U') IS NULL
CREATE TABLE [dbo].[SU_NAM_Subject_Name] (
    SU_NAM_SU_ID int not null,
    SU_NAM_Subject_Name nvarchar(42) not null,
    Metadata_SU_NAM int not null,
    constraint fkSU_NAM_Subject_Name foreign key (
        SU_NAM_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_NAM_Subject_Name primary key (
        SU_NAM_SU_ID asc
    )
);
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- SU_COD_Subject_Code table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_COD_Subject_Code', 'U') IS NULL
CREATE TABLE [dbo].[SU_COD_Subject_Code] (
    SU_COD_SU_ID int not null,
    SU_COD_Subject_Code nvarchar(42) not null,
    Metadata_SU_COD int not null,
    constraint fkSU_COD_Subject_Code foreign key (
        SU_COD_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_COD_Subject_Code primary key (
        SU_COD_SU_ID asc
    )
);
GO
-- Knotted static attribute table ------------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_GRD_Subject_Grade', 'U') IS NULL
CREATE TABLE [dbo].[SU_GRD_Subject_Grade] (
    SU_GRD_SU_ID int not null,
    SU_GRD_GRD_ID tinyint not null,
    Metadata_SU_GRD int not null,
    constraint fk_A_SU_GRD_Subject_Grade foreign key (
        SU_GRD_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint fk_K_SU_GRD_Subject_Grade foreign key (
        SU_GRD_GRD_ID
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_GRD_Subject_Grade primary key (
        SU_GRD_SU_ID asc
    )
);
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- SU_NOT_Subject_Note table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_NOT_Subject_Note', 'U') IS NULL
CREATE TABLE [dbo].[SU_NOT_Subject_Note] (
    SU_NOT_SU_ID int not null,
    SU_NOT_Subject_Note nvarchar(max) not null,
    SU_NOT_Checksum as cast(dbo.MD5(cast(SU_NOT_Subject_Note as varbinary(max))) as varbinary(16)) persisted,
    Metadata_SU_NOT int not null,
    constraint fkSU_NOT_Subject_Note foreign key (
        SU_NOT_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_NOT_Subject_Note primary key (
        SU_NOT_SU_ID asc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- SU_TTL_Subject_Title table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TTL_Subject_Title', 'U') IS NULL
CREATE TABLE [dbo].[SU_TTL_Subject_Title] (
    SU_TTL_SU_ID int not null,
    SU_TTL_Subject_Title nvarchar(42) not null,
    SU_TTL_ChangedAt datetime2 not null,
    Metadata_SU_TTL int not null,
    constraint fkSU_TTL_Subject_Title foreign key (
        SU_TTL_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_TTL_Subject_Title primary key (
        SU_TTL_SU_ID asc,
        SU_TTL_ChangedAt desc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- SU_STA_Subject_State table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_STA_Subject_State', 'U') IS NULL
CREATE TABLE [dbo].[SU_STA_Subject_State] (
    SU_STA_SU_ID int not null,
    SU_STA_Subject_State nvarchar(42) not null,
    SU_STA_ChangedAt datetime2 not null,
    Metadata_SU_STA int not null,
    constraint fkSU_STA_Subject_State foreign key (
        SU_STA_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_STA_Subject_State primary key (
        SU_STA_SU_ID asc,
        SU_STA_ChangedAt desc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- SU_LBL_Subject_Label table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_LBL_Subject_Label', 'U') IS NULL
CREATE TABLE [dbo].[SU_LBL_Subject_Label] (
    SU_LBL_SU_ID int not null,
    SU_LBL_Subject_Label nvarchar(42) not null,
    SU_LBL_ChangedAt datetime2 not null,
    Metadata_SU_LBL int not null,
    constraint fkSU_LBL_Subject_Label foreign key (
        SU_LBL_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_LBL_Subject_Label primary key (
        SU_LBL_SU_ID asc,
        SU_LBL_ChangedAt desc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TAG_Subject_Tag', 'U') IS NULL
CREATE TABLE [dbo].[SU_TAG_Subject_Tag] (
    SU_TAG_SU_ID int not null,
    SU_TAG_Subject_Tag nvarchar(42) not null,
    SU_TAG_ChangedAt datetime2 not null,
    Metadata_SU_TAG int not null,
    constraint fkSU_TAG_Subject_Tag foreign key (
        SU_TAG_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_TAG_Subject_Tag primary key (
        SU_TAG_SU_ID asc,
        SU_TAG_ChangedAt desc
    )
);
GO
-- Knotted historized attribute table --------------------------------------------------------------------------------
-- SU_LVL_Subject_Level table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_LVL_Subject_Level', 'U') IS NULL
CREATE TABLE [dbo].[SU_LVL_Subject_Level] (
    SU_LVL_SU_ID int not null,
    SU_LVL_GRD_ID tinyint not null,
    SU_LVL_ChangedAt datetime2 not null,
    Metadata_SU_LVL int not null,
    constraint fk_A_SU_LVL_Subject_Level foreign key (
        SU_LVL_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint fk_K_SU_LVL_Subject_Level foreign key (
        SU_LVL_GRD_ID
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_LVL_Subject_Level primary key (
        SU_LVL_SU_ID asc,
        SU_LVL_ChangedAt desc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- SU_TXT_Subject_Text table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TXT_Subject_Text', 'U') IS NULL
CREATE TABLE [dbo].[SU_TXT_Subject_Text] (
    SU_TXT_SU_ID int not null,
    SU_TXT_Subject_Text nvarchar(max) not null,
    SU_TXT_Checksum as cast(dbo.MD5(cast(SU_TXT_Subject_Text as varbinary(max))) as varbinary(16)) persisted,
    SU_TXT_ChangedAt datetime2 not null,
    Metadata_SU_TXT int not null,
    constraint fkSU_TXT_Subject_Text foreign key (
        SU_TXT_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_TXT_Subject_Text primary key (
        SU_TXT_SU_ID asc,
        SU_TXT_ChangedAt desc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_ASR_Subject_Assessment', 'U') IS NULL
CREATE TABLE [dbo].[SU_ASR_Subject_Assessment] (
    SU_ASR_SU_ID int not null,
    SU_ASR_Subject_Assessment nvarchar(42) not null,
    SU_ASR_ChangedAt datetime2 not null,
    Metadata_SU_ASR int not null,
    constraint fkSU_ASR_Subject_Assessment foreign key (
        SU_ASR_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_ASR_Subject_Assessment primary key (
        SU_ASR_SU_ID asc,
        SU_ASR_ChangedAt desc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_ERS_Subject_Erasable', 'U') IS NULL
CREATE TABLE [dbo].[SU_ERS_Subject_Erasable] (
    SU_ERS_SU_ID int not null,
    SU_ERS_Subject_Erasable nvarchar(42) not null,
    SU_ERS_ChangedAt datetime2 not null,
    Metadata_SU_ERS int not null,
    constraint fkSU_ERS_Subject_Erasable foreign key (
        SU_ERS_SU_ID
    ) references [dbo].[SU_Subject](SU_ID),
    constraint pkSU_ERS_Subject_Erasable primary key (
        SU_ERS_SU_ID asc,
        SU_ERS_ChangedAt desc
    )
);
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- OB_NAM_Object_Name table (on OB_Object)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_NAM_Object_Name', 'U') IS NULL
CREATE TABLE [dbo].[OB_NAM_Object_Name] (
    OB_NAM_OB_ID int not null,
    OB_NAM_Object_Name nvarchar(42) not null,
    Metadata_OB_NAM int not null,
    constraint fkOB_NAM_Object_Name foreign key (
        OB_NAM_OB_ID
    ) references [dbo].[OB_Object](OB_ID),
    constraint pkOB_NAM_Object_Name primary key (
        OB_NAM_OB_ID asc
    )
);
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
-- SU_holder_OB_item_GRD_grade table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_holder_OB_item_GRD_grade', 'U') IS NULL
CREATE TABLE [dbo].[SU_holder_OB_item_GRD_grade] (
    SU_ID_holder int not null, 
    OB_ID_item int not null, 
    GRD_ID_grade tinyint not null,
    SU_holder_OB_item_GRD_grade_ChangedAt datetime2 not null,
    Metadata_SU_holder_OB_item_GRD_grade int not null,
    constraint SU_holder_OB_item_GRD_grade_fkSU_holder foreign key (
        SU_ID_holder
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_holder_OB_item_GRD_grade_fkOB_item foreign key (
        OB_ID_item
    ) references [dbo].[OB_Object](OB_ID), 
    constraint SU_holder_OB_item_GRD_grade_fkGRD_grade foreign key (
        GRD_ID_grade
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_holder_OB_item_GRD_grade primary key (
        SU_ID_holder asc,
        OB_ID_item asc,
        SU_holder_OB_item_GRD_grade_ChangedAt desc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_keeper_OB_thing_GRD_rank', 'U') IS NULL
CREATE TABLE [dbo].[SU_keeper_OB_thing_GRD_rank] (
    SU_ID_keeper int not null, 
    OB_ID_thing int not null, 
    GRD_ID_rank tinyint not null,
    SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
    Metadata_SU_keeper_OB_thing_GRD_rank int not null,
    constraint SU_keeper_OB_thing_GRD_rank_fkSU_keeper foreign key (
        SU_ID_keeper
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_keeper_OB_thing_GRD_rank_fkOB_thing foreign key (
        OB_ID_thing
    ) references [dbo].[OB_Object](OB_ID), 
    constraint SU_keeper_OB_thing_GRD_rank_fkGRD_rank foreign key (
        GRD_ID_rank
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_keeper_OB_thing_GRD_rank primary key (
        SU_ID_keeper asc,
        OB_ID_thing asc,
        SU_keeper_OB_thing_GRD_rank_ChangedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- OB_part_SU_owner table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_part_SU_owner', 'U') IS NULL
CREATE TABLE [dbo].[OB_part_SU_owner] (
    OB_ID_part int not null, 
    SU_ID_owner int not null, 
    Metadata_OB_part_SU_owner int not null,
    constraint OB_part_SU_owner_fkOB_part foreign key (
        OB_ID_part
    ) references [dbo].[OB_Object](OB_ID), 
    constraint OB_part_SU_owner_fkSU_owner foreign key (
        SU_ID_owner
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint pkOB_part_SU_owner primary key (
        OB_ID_part asc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_partner_SU_with table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_partner_SU_with', 'U') IS NULL
CREATE TABLE [dbo].[SU_partner_SU_with] (
    SU_ID_partner int not null, 
    SU_ID_with int not null, 
    SU_partner_SU_with_ChangedAt datetime2 not null,
    Metadata_SU_partner_SU_with int not null,
    constraint SU_partner_SU_with_fkSU_partner foreign key (
        SU_ID_partner
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_partner_SU_with_fkSU_with foreign key (
        SU_ID_with
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_partner_SU_with_uqSU_partner unique (
        SU_ID_partner,
        SU_partner_SU_with_ChangedAt
    ),
    constraint SU_partner_SU_with_uqSU_with unique (
        SU_ID_with,
        SU_partner_SU_with_ChangedAt
    ),
    constraint pkSU_partner_SU_with primary key (
        SU_ID_partner asc,
        SU_ID_with asc,
        SU_partner_SU_with_ChangedAt desc
    )
);
GO
-- KNOT EQUIVALENCE VIEWS ---------------------------------------------------------------------------------------------
--
-- Equivalence views combine the identity and equivalent parts of a knot into a single view, making
-- it look and behave like a regular knot. They also make it possible to retrieve data for only the
-- given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
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
-- rt_SU_STA_Subject_State (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_SU_STA_Subject_State', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_SU_STA_Subject_State];
GO
CREATE TRIGGER [dbo].[rt_SU_STA_Subject_State] ON [dbo].[SU_STA_Subject_State]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @SU_STA_Subject_State TABLE (
        SU_STA_SU_ID int not null,
        Metadata_SU_STA int not null,
        SU_STA_ChangedAt datetime2 not null,
        SU_STA_Subject_State nvarchar(42) not null,
        primary key(
            SU_STA_SU_ID asc, 
            SU_STA_ChangedAt desc
        )
    );
    INSERT INTO @SU_STA_Subject_State (
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    SELECT
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    FROM 
        inserted;
    INSERT INTO @SU_STA_Subject_State (
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    SELECT
        p.SU_STA_SU_ID,
        p.Metadata_SU_STA,
        p.SU_STA_ChangedAt,
        p.SU_STA_Subject_State
    FROM (
        SELECT DISTINCT 
            SU_STA_SU_ID 
        FROM 
            @SU_STA_Subject_State
    ) i 
    JOIN
        [dbo].[SU_STA_Subject_State] p
    ON 
        p.SU_STA_SU_ID = i.SU_STA_SU_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_STA_SU_ID
        FROM
            @SU_STA_Subject_State x
        WHERE
            x.SU_STA_SU_ID = p.SU_STA_SU_ID
        AND
            x.SU_STA_ChangedAt = p.SU_STA_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @SU_STA_Subject_State i
        CROSS APPLY (
            SELECT TOP 1
                h.SU_STA_SU_ID,
                h.SU_STA_ChangedAt,
                h.SU_STA_Subject_State
            FROM 
                @SU_STA_Subject_State h
            WHERE
                h.SU_STA_SU_ID = i.SU_STA_SU_ID
            AND
                h.SU_STA_ChangedAt < i.SU_STA_ChangedAt
            ORDER BY 
                h.SU_STA_ChangedAt DESC
        ) pre
        WHERE
            i.SU_STA_Subject_State = pre.SU_STA_Subject_State
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in SU_STA_Subject_State for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_SU_LBL_Subject_Label (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_SU_LBL_Subject_Label', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_SU_LBL_Subject_Label];
GO
CREATE TRIGGER [dbo].[rt_SU_LBL_Subject_Label] ON [dbo].[SU_LBL_Subject_Label]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @SU_LBL_Subject_Label TABLE (
        SU_LBL_SU_ID int not null,
        Metadata_SU_LBL int not null,
        SU_LBL_ChangedAt datetime2 not null,
        SU_LBL_Subject_Label nvarchar(42) not null,
        primary key(
            SU_LBL_SU_ID asc, 
            SU_LBL_ChangedAt desc
        )
    );
    INSERT INTO @SU_LBL_Subject_Label (
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    SELECT
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    FROM 
        inserted;
    INSERT INTO @SU_LBL_Subject_Label (
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    SELECT
        p.SU_LBL_SU_ID,
        p.Metadata_SU_LBL,
        p.SU_LBL_ChangedAt,
        p.SU_LBL_Subject_Label
    FROM (
        SELECT DISTINCT 
            SU_LBL_SU_ID 
        FROM 
            @SU_LBL_Subject_Label
    ) i 
    JOIN
        [dbo].[SU_LBL_Subject_Label] p
    ON 
        p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_LBL_SU_ID
        FROM
            @SU_LBL_Subject_Label x
        WHERE
            x.SU_LBL_SU_ID = p.SU_LBL_SU_ID
        AND
            x.SU_LBL_ChangedAt = p.SU_LBL_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @SU_LBL_Subject_Label i
        CROSS APPLY (
            SELECT TOP 1
                h.SU_LBL_SU_ID,
                h.SU_LBL_ChangedAt,
                h.SU_LBL_Subject_Label
            FROM 
                @SU_LBL_Subject_Label h
            WHERE
                h.SU_LBL_SU_ID = i.SU_LBL_SU_ID
            AND
                h.SU_LBL_ChangedAt < i.SU_LBL_ChangedAt
            ORDER BY 
                h.SU_LBL_ChangedAt DESC
        ) pre
        WHERE
            i.SU_LBL_Subject_Label = pre.SU_LBL_Subject_Label
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in SU_LBL_Subject_Label for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
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
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kEV_Event identity by surrogate key generation stored procedure (nexus)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kEV_Event', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kEV_Event] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT 1
                UNION ALL SELECT idNumber + 1 FROM idGenerator WHERE idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[EV_Event] (
                Metadata_EV
            )
            OUTPUT inserted.EV_ID
            SELECT @metadata FROM idGenerator OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TTL_Subject_Title','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TTL_Subject_Title] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_Subject_Title,
        SU_TTL_ChangedAt
    FROM
        [dbo].[SU_TTL_Subject_Title]
    WHERE
        SU_TTL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_STA_Subject_State rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_STA_Subject_State','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_STA_Subject_State] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_Subject_State,
        SU_STA_ChangedAt
    FROM
        [dbo].[SU_STA_Subject_State]
    WHERE
        SU_STA_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LBL_Subject_Label','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LBL_Subject_Label] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_Subject_Label,
        SU_LBL_ChangedAt
    FROM
        [dbo].[SU_LBL_Subject_Label]
    WHERE
        SU_LBL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TAG_Subject_Tag','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TAG_Subject_Tag] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_Subject_Tag,
        SU_TAG_ChangedAt
    FROM
        [dbo].[SU_TAG_Subject_Tag]
    WHERE
        SU_TAG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LVL_Subject_Level','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LVL_Subject_Level] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_GRD_ID,
        SU_LVL_ChangedAt
    FROM
        [dbo].[SU_LVL_Subject_Level]
    WHERE
        SU_LVL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TXT_Subject_Text','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TXT_Subject_Text] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_TXT,
        SU_TXT_SU_ID,
        SU_TXT_Checksum,
        SU_TXT_Subject_Text,
        SU_TXT_ChangedAt
    FROM
        [dbo].[SU_TXT_Subject_Text]
    WHERE
        SU_TXT_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ASR_Subject_Assessment','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ASR_Subject_Assessment] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_Subject_Assessment,
        SU_ASR_ChangedAt
    FROM
        [dbo].[SU_ASR_Subject_Assessment]
    WHERE
        SU_ASR_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ERS_Subject_Erasable','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ERS_Subject_Erasable] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_Subject_Erasable,
        SU_ERS_ChangedAt
    FROM
        [dbo].[SU_ERS_Subject_Erasable]
    WHERE
        SU_ERS_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
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
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
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
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_Subject viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_Subject] WITH SCHEMABINDING AS
SELECT
    [SU].SU_ID,
    [SU].Metadata_SU,
    [NAM].SU_NAM_SU_ID,
    [NAM].Metadata_SU_NAM,
    [NAM].SU_NAM_Subject_Name,
    [COD].SU_COD_SU_ID,
    [COD].Metadata_SU_COD,
    [COD].SU_COD_Subject_Code,
    [GRD].SU_GRD_SU_ID,
    [GRD].Metadata_SU_GRD,
    [kGRD].GRD_Grade AS SU_GRD_GRD_Grade,
    [kGRD].Metadata_GRD AS SU_GRD_Metadata_GRD,
    [GRD].SU_GRD_GRD_ID,
    [NOT].SU_NOT_SU_ID,
    [NOT].Metadata_SU_NOT,
    [NOT].SU_NOT_Checksum,
    [NOT].SU_NOT_Subject_Note,
    [TTL].SU_TTL_SU_ID,
    [TTL].Metadata_SU_TTL,
    [TTL].SU_TTL_ChangedAt,
    [TTL].SU_TTL_Subject_Title,
    [STA].SU_STA_SU_ID,
    [STA].Metadata_SU_STA,
    [STA].SU_STA_ChangedAt,
    [STA].SU_STA_Subject_State,
    [LBL].SU_LBL_SU_ID,
    [LBL].Metadata_SU_LBL,
    [LBL].SU_LBL_ChangedAt,
    [LBL].SU_LBL_Subject_Label,
    [TAG].SU_TAG_SU_ID,
    [TAG].Metadata_SU_TAG,
    [TAG].SU_TAG_ChangedAt,
    [TAG].SU_TAG_Subject_Tag,
    [LVL].SU_LVL_SU_ID,
    [LVL].Metadata_SU_LVL,
    [LVL].SU_LVL_ChangedAt,
    [kLVL].GRD_Grade AS SU_LVL_GRD_Grade,
    [kLVL].Metadata_GRD AS SU_LVL_Metadata_GRD,
    [LVL].SU_LVL_GRD_ID,
    [TXT].SU_TXT_SU_ID,
    [TXT].Metadata_SU_TXT,
    [TXT].SU_TXT_ChangedAt,
    [TXT].SU_TXT_Checksum,
    [TXT].SU_TXT_Subject_Text,
    [ASR].SU_ASR_SU_ID,
    [ASR].Metadata_SU_ASR,
    [ASR].SU_ASR_ChangedAt,
    [ASR].SU_ASR_Subject_Assessment,
    [ERS].SU_ERS_SU_ID,
    [ERS].Metadata_SU_ERS,
    cast(null as bit) as Deletable_SU_ERS,
    [ERS].SU_ERS_ChangedAt,
    [ERS].SU_ERS_Subject_Erasable
FROM
    [dbo].[SU_Subject] [SU]
LEFT JOIN
    [dbo].[SU_NAM_Subject_Name] [NAM]
ON
    [NAM].SU_NAM_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[SU_COD_Subject_Code] [COD]
ON
    [COD].SU_COD_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[SU_GRD_Subject_Grade] [GRD]
ON
    [GRD].SU_GRD_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[GRD_Grade] [kGRD]
ON
    [kGRD].GRD_ID = [GRD].SU_GRD_GRD_ID
LEFT JOIN
    [dbo].[SU_NOT_Subject_Note] [NOT]
ON
    [NOT].SU_NOT_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[SU_TTL_Subject_Title] [TTL]
ON
    [TTL].SU_TTL_SU_ID = [SU].SU_ID
AND
    [TTL].SU_TTL_ChangedAt = (
        SELECT
            max(sub.SU_TTL_ChangedAt)
        FROM
            [dbo].[SU_TTL_Subject_Title] sub
        WHERE
            sub.SU_TTL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_STA_Subject_State] [STA]
ON
    [STA].SU_STA_SU_ID = [SU].SU_ID
AND
    [STA].SU_STA_ChangedAt = (
        SELECT
            max(sub.SU_STA_ChangedAt)
        FROM
            [dbo].[SU_STA_Subject_State] sub
        WHERE
            sub.SU_STA_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_LBL_Subject_Label] [LBL]
ON
    [LBL].SU_LBL_SU_ID = [SU].SU_ID
AND
    [LBL].SU_LBL_ChangedAt = (
        SELECT
            max(sub.SU_LBL_ChangedAt)
        FROM
            [dbo].[SU_LBL_Subject_Label] sub
        WHERE
            sub.SU_LBL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_TAG_Subject_Tag] [TAG]
ON
    [TAG].SU_TAG_SU_ID = [SU].SU_ID
AND
    [TAG].SU_TAG_ChangedAt = (
        SELECT
            max(sub.SU_TAG_ChangedAt)
        FROM
            [dbo].[SU_TAG_Subject_Tag] sub
        WHERE
            sub.SU_TAG_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_LVL_Subject_Level] [LVL]
ON
    [LVL].SU_LVL_SU_ID = [SU].SU_ID
AND
    [LVL].SU_LVL_ChangedAt = (
        SELECT
            max(sub.SU_LVL_ChangedAt)
        FROM
            [dbo].[SU_LVL_Subject_Level] sub
        WHERE
            sub.SU_LVL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[GRD_Grade] [kLVL]
ON
    [kLVL].GRD_ID = [LVL].SU_LVL_GRD_ID
LEFT JOIN
    [dbo].[SU_TXT_Subject_Text] [TXT]
ON
    [TXT].SU_TXT_SU_ID = [SU].SU_ID
AND
    [TXT].SU_TXT_ChangedAt = (
        SELECT
            max(sub.SU_TXT_ChangedAt)
        FROM
            [dbo].[SU_TXT_Subject_Text] sub
        WHERE
            sub.SU_TXT_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_ASR_Subject_Assessment] [ASR]
ON
    [ASR].SU_ASR_SU_ID = [SU].SU_ID
AND
    [ASR].SU_ASR_ChangedAt = (
        SELECT
            max(sub.SU_ASR_ChangedAt)
        FROM
            [dbo].[SU_ASR_Subject_Assessment] sub
        WHERE
            sub.SU_ASR_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_ERS_Subject_Erasable] [ERS]
ON
    [ERS].SU_ERS_SU_ID = [SU].SU_ID
AND
    [ERS].SU_ERS_ChangedAt = (
        SELECT
            max(sub.SU_ERS_ChangedAt)
        FROM
            [dbo].[SU_ERS_Subject_Erasable] sub
        WHERE
            sub.SU_ERS_SU_ID = [SU].SU_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_Subject viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_Subject] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [SU].SU_ID,
    [SU].Metadata_SU,
    [NAM].SU_NAM_SU_ID,
    [NAM].Metadata_SU_NAM,
    [NAM].SU_NAM_Subject_Name,
    [COD].SU_COD_SU_ID,
    [COD].Metadata_SU_COD,
    [COD].SU_COD_Subject_Code,
    [GRD].SU_GRD_SU_ID,
    [GRD].Metadata_SU_GRD,
    [kGRD].GRD_Grade AS SU_GRD_GRD_Grade,
    [kGRD].Metadata_GRD AS SU_GRD_Metadata_GRD,
    [GRD].SU_GRD_GRD_ID,
    [NOT].SU_NOT_SU_ID,
    [NOT].Metadata_SU_NOT,
    [NOT].SU_NOT_Checksum,
    [NOT].SU_NOT_Subject_Note,
    [TTL].SU_TTL_SU_ID,
    [TTL].Metadata_SU_TTL,
    [TTL].SU_TTL_ChangedAt,
    [TTL].SU_TTL_Subject_Title,
    [STA].SU_STA_SU_ID,
    [STA].Metadata_SU_STA,
    [STA].SU_STA_ChangedAt,
    [STA].SU_STA_Subject_State,
    [LBL].SU_LBL_SU_ID,
    [LBL].Metadata_SU_LBL,
    [LBL].SU_LBL_ChangedAt,
    [LBL].SU_LBL_Subject_Label,
    [TAG].SU_TAG_SU_ID,
    [TAG].Metadata_SU_TAG,
    [TAG].SU_TAG_ChangedAt,
    [TAG].SU_TAG_Subject_Tag,
    [LVL].SU_LVL_SU_ID,
    [LVL].Metadata_SU_LVL,
    [LVL].SU_LVL_ChangedAt,
    [kLVL].GRD_Grade AS SU_LVL_GRD_Grade,
    [kLVL].Metadata_GRD AS SU_LVL_Metadata_GRD,
    [LVL].SU_LVL_GRD_ID,
    [TXT].SU_TXT_SU_ID,
    [TXT].Metadata_SU_TXT,
    [TXT].SU_TXT_ChangedAt,
    [TXT].SU_TXT_Checksum,
    [TXT].SU_TXT_Subject_Text,
    [ASR].SU_ASR_SU_ID,
    [ASR].Metadata_SU_ASR,
    [ASR].SU_ASR_ChangedAt,
    [ASR].SU_ASR_Subject_Assessment,
    [ERS].SU_ERS_SU_ID,
    [ERS].Metadata_SU_ERS,
    [ERS].SU_ERS_ChangedAt,
    [ERS].SU_ERS_Subject_Erasable
FROM
    [dbo].[SU_Subject] [SU]
LEFT JOIN
    [dbo].[SU_NAM_Subject_Name] [NAM]
ON
    [NAM].SU_NAM_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[SU_COD_Subject_Code] [COD]
ON
    [COD].SU_COD_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[SU_GRD_Subject_Grade] [GRD]
ON
    [GRD].SU_GRD_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[GRD_Grade] [kGRD]
ON
    [kGRD].GRD_ID = [GRD].SU_GRD_GRD_ID
LEFT JOIN
    [dbo].[SU_NOT_Subject_Note] [NOT]
ON
    [NOT].SU_NOT_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[rSU_TTL_Subject_Title](@changingTimepoint) [TTL]
ON
    [TTL].SU_TTL_SU_ID = [SU].SU_ID
AND
    [TTL].SU_TTL_ChangedAt = (
        SELECT
            max(sub.SU_TTL_ChangedAt)
        FROM
            [dbo].[rSU_TTL_Subject_Title](@changingTimepoint) sub
        WHERE
            sub.SU_TTL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_STA_Subject_State](@changingTimepoint) [STA]
ON
    [STA].SU_STA_SU_ID = [SU].SU_ID
AND
    [STA].SU_STA_ChangedAt = (
        SELECT
            max(sub.SU_STA_ChangedAt)
        FROM
            [dbo].[rSU_STA_Subject_State](@changingTimepoint) sub
        WHERE
            sub.SU_STA_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_LBL_Subject_Label](@changingTimepoint) [LBL]
ON
    [LBL].SU_LBL_SU_ID = [SU].SU_ID
AND
    [LBL].SU_LBL_ChangedAt = (
        SELECT
            max(sub.SU_LBL_ChangedAt)
        FROM
            [dbo].[rSU_LBL_Subject_Label](@changingTimepoint) sub
        WHERE
            sub.SU_LBL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_TAG_Subject_Tag](@changingTimepoint) [TAG]
ON
    [TAG].SU_TAG_SU_ID = [SU].SU_ID
AND
    [TAG].SU_TAG_ChangedAt = (
        SELECT
            max(sub.SU_TAG_ChangedAt)
        FROM
            [dbo].[rSU_TAG_Subject_Tag](@changingTimepoint) sub
        WHERE
            sub.SU_TAG_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_LVL_Subject_Level](@changingTimepoint) [LVL]
ON
    [LVL].SU_LVL_SU_ID = [SU].SU_ID
AND
    [LVL].SU_LVL_ChangedAt = (
        SELECT
            max(sub.SU_LVL_ChangedAt)
        FROM
            [dbo].[rSU_LVL_Subject_Level](@changingTimepoint) sub
        WHERE
            sub.SU_LVL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[GRD_Grade] [kLVL]
ON
    [kLVL].GRD_ID = [LVL].SU_LVL_GRD_ID
LEFT JOIN
    [dbo].[rSU_TXT_Subject_Text](@changingTimepoint) [TXT]
ON
    [TXT].SU_TXT_SU_ID = [SU].SU_ID
AND
    [TXT].SU_TXT_ChangedAt = (
        SELECT
            max(sub.SU_TXT_ChangedAt)
        FROM
            [dbo].[rSU_TXT_Subject_Text](@changingTimepoint) sub
        WHERE
            sub.SU_TXT_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_ASR_Subject_Assessment](@changingTimepoint) [ASR]
ON
    [ASR].SU_ASR_SU_ID = [SU].SU_ID
AND
    [ASR].SU_ASR_ChangedAt = (
        SELECT
            max(sub.SU_ASR_ChangedAt)
        FROM
            [dbo].[rSU_ASR_Subject_Assessment](@changingTimepoint) sub
        WHERE
            sub.SU_ASR_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_ERS_Subject_Erasable](@changingTimepoint) [ERS]
ON
    [ERS].SU_ERS_SU_ID = [SU].SU_ID
AND
    [ERS].SU_ERS_ChangedAt = (
        SELECT
            max(sub.SU_ERS_ChangedAt)
        FROM
            [dbo].[rSU_ERS_Subject_Erasable](@changingTimepoint) sub
        WHERE
            sub.SU_ERS_SU_ID = [SU].SU_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_Subject viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_Subject]
AS
SELECT
    *
FROM
    [dbo].[pSU_Subject](sysdatetime());
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
    timepoints.mnemonic,
    [pSU].*
FROM (
    SELECT DISTINCT
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
CROSS APPLY
    [dbo].[pSU_Subject](timepoints.inspectedTimepoint) [pSU]
WHERE
    [pSU].SU_ID = timepoints.SU_ID;
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
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOB_Object viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lOB_Object] WITH SCHEMABINDING AS
SELECT
    [OB].OB_ID,
    [OB].Metadata_OB,
    [NAM].OB_NAM_OB_ID,
    [NAM].Metadata_OB_NAM,
    [NAM].OB_NAM_Object_Name
FROM
    [dbo].[OB_Object] [OB]
LEFT JOIN
    [dbo].[OB_NAM_Object_Name] [NAM]
ON
    [NAM].OB_NAM_OB_ID = [OB].OB_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pOB_Object viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pOB_Object] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [OB].OB_ID,
    [OB].Metadata_OB,
    [NAM].OB_NAM_OB_ID,
    [NAM].Metadata_OB_NAM,
    [NAM].OB_NAM_Object_Name
FROM
    [dbo].[OB_Object] [OB]
LEFT JOIN
    [dbo].[OB_NAM_Object_Name] [NAM]
ON
    [NAM].OB_NAM_OB_ID = [OB].OB_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOB_Object viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nOB_Object]
AS
SELECT
    *
FROM
    [dbo].[pOB_Object](sysdatetime());
GO
-- NEXUS TEMPORAL PERSPECTIVES --------------------------------------------------------------------------------------
--
-- These views and table valued functions provide temporal perspectives over each nexus,
-- denormalizing the nexus, its adjoined attributes, and any referenced knots (both from
-- roles and from knotted attributes) from sixth to third normal form.
--
-- Four types of perspectives are provided (mirroring anchors):
-- latest (l), point-in-time (p), difference (d), and now (n).
-- Under equivalence, corresponding e-prefixed variants (el, ep, ed, en) are generated.
--
-- The nexus base row is immutable; only its historized attributes change over time. Roles
-- (anchor/nexus/knot foreign keys stored in the base nexus table) are therefore treated as
-- static within temporal selection logic. Historization logic only applies to historized
-- attributes.
--
-- @changingTimepoint the point in changing time to travel to (for point-in-time functions)
-- @intervalStart the start of the interval for finding changes (difference)
-- @intervalEnd the end of the interval for finding changes (difference)
-- @selection list of mnemonics for tracked attributes, e.g. 'ABC DEF', or null for all (difference)
-- @equivalent the equivalent for which to retrieve data (equivalence variants)
--
-- Perspective generation is skipped for nexuses without attributes (to avoid redundant
-- projections identical to the base nexus table).
--
-- Drop perspectives ------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dEV_Event];
IF Object_ID('dbo.nEV_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[nEV_Event];
IF Object_ID('dbo.pEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pEV_Event];
IF Object_ID('dbo.lEV_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[lEV_Event];
GO
-- Latest perspective -----------------------------------------------------------------------------------------------
-- lEV_Event viewed by the latest available information (may include future versions)
----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lEV_Event] WITH SCHEMABINDING AS
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].SU_ID_for,
    [QTY].EV_QTY_EV_ID,
    [QTY].Metadata_EV_QTY,
    [QTY].EV_QTY_Event_Quantity
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[EV_QTY_Event_Quantity] [QTY]
ON
    [QTY].EV_QTY_EV_ID = [EV].EV_ID;
GO
-- Point-in-time perspective -----------------------------------------------------------------------------------------
-- pEV_Event viewed as it was on the given timepoint
----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pEV_Event] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].SU_ID_for,
    [QTY].EV_QTY_EV_ID,
    [QTY].Metadata_EV_QTY,
    [QTY].EV_QTY_Event_Quantity
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[EV_QTY_Event_Quantity] [QTY]
ON
    [QTY].EV_QTY_EV_ID = [EV].EV_ID;
GO
-- Now perspective --------------------------------------------------------------------------------------------------
-- nEV_Event viewed as it currently is (cannot include future versions)
----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nEV_Event]
AS
SELECT
    *
FROM
    [dbo].[pEV_Event](sysdatetime());
GO
-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the attributes make them behave like tables.
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_QTY_EV_ID
        FROM
            inserted i
        JOIN
            [dbo].[EV_QTY_Event_Quantity] x
        ON
            x.EV_QTY_EV_ID = i.EV_QTY_EV_ID
        WHERE NOT (
            x.EV_QTY_Event_Quantity = i.EV_QTY_Event_Quantity
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
    INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
        Metadata_EV_QTY,
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity
    )
    SELECT
        Metadata_EV_QTY,
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.EV_QTY_EV_ID
        FROM
            [dbo].[EV_QTY_Event_Quantity] x
        WHERE
            x.EV_QTY_EV_ID = i.EV_QTY_EV_ID
        AND
            x.EV_QTY_Event_Quantity = i.EV_QTY_Event_Quantity
    ); 
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_NAM_SU_ID
        FROM
            inserted i
        JOIN
            [dbo].[SU_NAM_Subject_Name] x
        ON
            x.SU_NAM_SU_ID = i.SU_NAM_SU_ID
        WHERE NOT (
            x.SU_NAM_Subject_Name = i.SU_NAM_Subject_Name
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
    INSERT INTO [dbo].[SU_NAM_Subject_Name] (
        Metadata_SU_NAM,
        SU_NAM_SU_ID,
        SU_NAM_Subject_Name
    )
    SELECT
        Metadata_SU_NAM,
        SU_NAM_SU_ID,
        SU_NAM_Subject_Name
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_NAM_SU_ID
        FROM
            [dbo].[SU_NAM_Subject_Name] x
        WHERE
            x.SU_NAM_SU_ID = i.SU_NAM_SU_ID
        AND
            x.SU_NAM_Subject_Name = i.SU_NAM_Subject_Name
    ); 
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_COD_SU_ID
        FROM
            inserted i
        JOIN
            [dbo].[SU_COD_Subject_Code] x
        ON
            x.SU_COD_SU_ID = i.SU_COD_SU_ID
        WHERE NOT (
            x.SU_COD_Subject_Code = i.SU_COD_Subject_Code
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
    INSERT INTO [dbo].[SU_COD_Subject_Code] (
        Metadata_SU_COD,
        SU_COD_SU_ID,
        SU_COD_Subject_Code
    )
    SELECT
        Metadata_SU_COD,
        SU_COD_SU_ID,
        SU_COD_Subject_Code
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_COD_SU_ID
        FROM
            [dbo].[SU_COD_Subject_Code] x
        WHERE
            x.SU_COD_SU_ID = i.SU_COD_SU_ID
        AND
            x.SU_COD_Subject_Code = i.SU_COD_Subject_Code
    ); 
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_GRD_SU_ID
        FROM
            inserted i
        JOIN
            [dbo].[SU_GRD_Subject_Grade] x
        ON
            x.SU_GRD_SU_ID = i.SU_GRD_SU_ID
        WHERE NOT (
            x.SU_GRD_GRD_ID = i.SU_GRD_GRD_ID
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
    INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
        Metadata_SU_GRD,
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID
    )
    SELECT
        Metadata_SU_GRD,
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_GRD_SU_ID
        FROM
            [dbo].[SU_GRD_Subject_Grade] x
        WHERE
            x.SU_GRD_SU_ID = i.SU_GRD_SU_ID
        AND
            x.SU_GRD_GRD_ID = i.SU_GRD_GRD_ID
    ); 
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_NOT_SU_ID
        FROM
            inserted i
        JOIN
            [dbo].[SU_NOT_Subject_Note] x
        ON
            x.SU_NOT_SU_ID = i.SU_NOT_SU_ID
        WHERE NOT (
            x.SU_NOT_Checksum = dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max))) 
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
    INSERT INTO [dbo].[SU_NOT_Subject_Note] (
        Metadata_SU_NOT,
        SU_NOT_SU_ID,
        SU_NOT_Subject_Note
    )
    SELECT
        Metadata_SU_NOT,
        SU_NOT_SU_ID,
        SU_NOT_Subject_Note
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_NOT_SU_ID
        FROM
            [dbo].[SU_NOT_Subject_Note] x
        WHERE
            x.SU_NOT_SU_ID = i.SU_NOT_SU_ID
        AND
            x.SU_NOT_Checksum = dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max))) 
    ); 
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_TTL_Subject_Title TABLE (
    SU_TTL_SU_ID int not null,
        Metadata_SU_TTL int not null,
        SU_TTL_ChangedAt datetime2 not null,
        SU_TTL_Subject_Title nvarchar(42) not null,
        SU_TTL_StatementType char(1) not null,
        primary key (
            SU_TTL_SU_ID asc, 
            SU_TTL_ChangedAt desc
        )
    );
    INSERT INTO @SU_TTL_Subject_Title
    SELECT
        i.SU_TTL_SU_ID,
        i.Metadata_SU_TTL,
        i.SU_TTL_ChangedAt,
        i.SU_TTL_Subject_Title,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_TTL_SU_ID
        FROM
            [dbo].[SU_TTL_Subject_Title] x
        WHERE
            x.SU_TTL_SU_ID = i.SU_TTL_SU_ID
        AND
            x.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
        AND
            x.SU_TTL_Subject_Title = i.SU_TTL_Subject_Title
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TTL_SU_ID,
            i.SU_TTL_ChangedAt
        FROM
            @SU_TTL_Subject_Title i
        JOIN
            [dbo].[SU_TTL_Subject_Title] x
        ON
            x.SU_TTL_SU_ID = i.SU_TTL_SU_ID
        AND
            x.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TTL_Subject_Title for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_TTL_Subject_Title] (
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_ChangedAt,
        SU_TTL_Subject_Title
    )
    SELECT
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_ChangedAt,
        SU_TTL_Subject_Title
    FROM
        @SU_TTL_Subject_Title
    WHERE
        SU_TTL_StatementType = 'P';
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_STA_Subject_State TABLE (
    SU_STA_SU_ID int not null,
        Metadata_SU_STA int not null,
        SU_STA_ChangedAt datetime2 not null,
        SU_STA_Subject_State nvarchar(42) not null,
        SU_STA_StatementType char(1) not null,
        primary key (
            SU_STA_SU_ID asc, 
            SU_STA_ChangedAt desc
        )
    );
    INSERT INTO @SU_STA_Subject_State
    SELECT
        i.SU_STA_SU_ID,
        i.Metadata_SU_STA,
        i.SU_STA_ChangedAt,
        i.SU_STA_Subject_State,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_STA_SU_ID
        FROM
            [dbo].[SU_STA_Subject_State] x
        WHERE
            x.SU_STA_SU_ID = i.SU_STA_SU_ID
        AND
            x.SU_STA_ChangedAt = i.SU_STA_ChangedAt
        AND
            x.SU_STA_Subject_State = i.SU_STA_Subject_State
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_STA_SU_ID,
            i.SU_STA_ChangedAt
        FROM
            @SU_STA_Subject_State i
        JOIN
            [dbo].[SU_STA_Subject_State] x
        ON
            x.SU_STA_SU_ID = i.SU_STA_SU_ID
        AND
            x.SU_STA_ChangedAt = i.SU_STA_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_STA_Subject_State for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_STA_Subject_State] (
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    SELECT
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    FROM
        @SU_STA_Subject_State
    WHERE
        SU_STA_StatementType = 'P';
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_LBL_Subject_Label TABLE (
    SU_LBL_SU_ID int not null,
        Metadata_SU_LBL int not null,
        SU_LBL_ChangedAt datetime2 not null,
        SU_LBL_Subject_Label nvarchar(42) not null,
        SU_LBL_StatementType char(1) not null,
        primary key (
            SU_LBL_SU_ID asc, 
            SU_LBL_ChangedAt desc
        )
    );
    INSERT INTO @SU_LBL_Subject_Label
    SELECT
        i.SU_LBL_SU_ID,
        i.Metadata_SU_LBL,
        i.SU_LBL_ChangedAt,
        i.SU_LBL_Subject_Label,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_LBL_SU_ID
        FROM
            [dbo].[SU_LBL_Subject_Label] x
        WHERE
            x.SU_LBL_SU_ID = i.SU_LBL_SU_ID
        AND
            x.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
        AND
            x.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_LBL_SU_ID,
            i.SU_LBL_ChangedAt
        FROM
            @SU_LBL_Subject_Label i
        JOIN
            [dbo].[SU_LBL_Subject_Label] x
        ON
            x.SU_LBL_SU_ID = i.SU_LBL_SU_ID
        AND
            x.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
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
        p.Metadata_SU_LBL,
        p.SU_LBL_ChangedAt,
        p.SU_LBL_Subject_Label,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            SU_LBL_SU_ID 
        FROM 
            @SU_LBL_Subject_Label
    ) i
    JOIN
        [dbo].[SU_LBL_Subject_Label] p
    ON
        p.SU_LBL_SU_ID = i.SU_LBL_SU_ID;
    DECLARE @restated TABLE (
    SU_LBL_SU_ID int not null,
        SU_LBL_ChangedAt datetime2 not null
    );
    INSERT INTO @restated
    SELECT 
        x.SU_LBL_SU_ID,
        x.SU_LBL_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @SU_LBL_Subject_Label a
        OUTER APPLY (
            SELECT TOP 1
                h.SU_LBL_Subject_Label
            FROM 
                @SU_LBL_Subject_Label h
            WHERE
                h.SU_LBL_SU_ID = a.SU_LBL_SU_ID
            AND
                h.SU_LBL_ChangedAt < a.SU_LBL_ChangedAt
            ORDER BY 
                h.SU_LBL_ChangedAt DESC
        ) pre
        WHERE
            a.SU_LBL_Subject_Label = pre.SU_LBL_Subject_Label
    ) x
    WHERE
        x.SU_LBL_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[dbo].[SU_LBL_Subject_Label] a
	JOIN 
		@restated d
	ON 
		d.SU_LBL_SU_ID = a.SU_LBL_SU_ID
	AND 
		d.SU_LBL_ChangedAt = a.SU_LBL_ChangedAt; 
    INSERT INTO [dbo].[SU_LBL_Subject_Label] (
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    SELECT
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    FROM
        @SU_LBL_Subject_Label
    WHERE
        SU_LBL_StatementType = 'P';
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_TAG_Subject_Tag TABLE (
    SU_TAG_SU_ID int not null,
        Metadata_SU_TAG int not null,
        SU_TAG_ChangedAt datetime2 not null,
        SU_TAG_Subject_Tag nvarchar(42) not null,
        SU_TAG_StatementType char(1) not null,
        primary key (
            SU_TAG_SU_ID asc, 
            SU_TAG_ChangedAt desc
        )
    );
    INSERT INTO @SU_TAG_Subject_Tag
    SELECT
        i.SU_TAG_SU_ID,
        i.Metadata_SU_TAG,
        i.SU_TAG_ChangedAt,
        i.SU_TAG_Subject_Tag,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_TAG_SU_ID
        FROM
            [dbo].[SU_TAG_Subject_Tag] x
        WHERE
            x.SU_TAG_SU_ID = i.SU_TAG_SU_ID
        AND
            x.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
        AND
            x.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TAG_SU_ID,
            i.SU_TAG_ChangedAt
        FROM
            @SU_TAG_Subject_Tag i
        JOIN
            [dbo].[SU_TAG_Subject_Tag] x
        ON
            x.SU_TAG_SU_ID = i.SU_TAG_SU_ID
        AND
            x.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
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
        p.Metadata_SU_TAG,
        p.SU_TAG_ChangedAt,
        p.SU_TAG_Subject_Tag,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            SU_TAG_SU_ID 
        FROM 
            @SU_TAG_Subject_Tag
    ) i
    JOIN
        [dbo].[SU_TAG_Subject_Tag] p
    ON
        p.SU_TAG_SU_ID = i.SU_TAG_SU_ID;
    DECLARE @restated TABLE (
    SU_TAG_SU_ID int not null,
        SU_TAG_ChangedAt datetime2 not null
    );
    INSERT INTO @restated
    SELECT 
        x.SU_TAG_SU_ID,
        x.SU_TAG_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @SU_TAG_Subject_Tag a
        OUTER APPLY (
            SELECT TOP 1
                h.SU_TAG_Subject_Tag
            FROM 
                @SU_TAG_Subject_Tag h
            WHERE
                h.SU_TAG_SU_ID = a.SU_TAG_SU_ID
            AND
                h.SU_TAG_ChangedAt < a.SU_TAG_ChangedAt
            ORDER BY 
                h.SU_TAG_ChangedAt DESC
        ) pre
        WHERE
            a.SU_TAG_Subject_Tag = pre.SU_TAG_Subject_Tag
    ) x
    WHERE
        x.SU_TAG_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[dbo].[SU_TAG_Subject_Tag] a
	JOIN 
		@restated d
	ON 
		d.SU_TAG_SU_ID = a.SU_TAG_SU_ID
	AND 
		d.SU_TAG_ChangedAt = a.SU_TAG_ChangedAt; 
    INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_ChangedAt,
        SU_TAG_Subject_Tag
    )
    SELECT
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_ChangedAt,
        SU_TAG_Subject_Tag
    FROM
        @SU_TAG_Subject_Tag
    WHERE
        SU_TAG_StatementType = 'P';
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_LVL_Subject_Level TABLE (
    SU_LVL_SU_ID int not null,
        Metadata_SU_LVL int not null,
        SU_LVL_ChangedAt datetime2 not null,
        SU_LVL_GRD_ID tinyint not null, 
        SU_LVL_StatementType char(1) not null,
        primary key (
            SU_LVL_SU_ID asc, 
            SU_LVL_ChangedAt desc
        )
    );
    INSERT INTO @SU_LVL_Subject_Level
    SELECT
        i.SU_LVL_SU_ID,
        i.Metadata_SU_LVL,
        i.SU_LVL_ChangedAt,
        i.SU_LVL_GRD_ID,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_LVL_SU_ID
        FROM
            [dbo].[SU_LVL_Subject_Level] x
        WHERE
            x.SU_LVL_SU_ID = i.SU_LVL_SU_ID
        AND
            x.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
        AND
            x.SU_LVL_GRD_ID = i.SU_LVL_GRD_ID
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_LVL_SU_ID,
            i.SU_LVL_ChangedAt
        FROM
            @SU_LVL_Subject_Level i
        JOIN
            [dbo].[SU_LVL_Subject_Level] x
        ON
            x.SU_LVL_SU_ID = i.SU_LVL_SU_ID
        AND
            x.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_LVL_Subject_Level for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_LVL_Subject_Level] (
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_ChangedAt,
        SU_LVL_GRD_ID
    )
    SELECT
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_ChangedAt,
        SU_LVL_GRD_ID
    FROM
        @SU_LVL_Subject_Level
    WHERE
        SU_LVL_StatementType = 'P';
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_TXT_Subject_Text TABLE (
    SU_TXT_SU_ID int not null,
        Metadata_SU_TXT int not null,
        SU_TXT_ChangedAt datetime2 not null,
        SU_TXT_Subject_Text nvarchar(max) not null,
        SU_TXT_Checksum varbinary(16) not null,
        SU_TXT_StatementType char(1) not null,
        primary key (
            SU_TXT_SU_ID asc, 
            SU_TXT_ChangedAt desc
        )
    );
    INSERT INTO @SU_TXT_Subject_Text
    SELECT
        i.SU_TXT_SU_ID,
        i.Metadata_SU_TXT,
        i.SU_TXT_ChangedAt,
        i.SU_TXT_Subject_Text,
        dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max))),
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_TXT_SU_ID
        FROM
            [dbo].[SU_TXT_Subject_Text] x
        WHERE
            x.SU_TXT_SU_ID = i.SU_TXT_SU_ID
        AND
            x.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
        AND
            x.SU_TXT_Checksum = dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max))) 
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TXT_SU_ID,
            i.SU_TXT_ChangedAt
        FROM
            @SU_TXT_Subject_Text i
        JOIN
            [dbo].[SU_TXT_Subject_Text] x
        ON
            x.SU_TXT_SU_ID = i.SU_TXT_SU_ID
        AND
            x.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TXT_Subject_Text for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_TXT_Subject_Text] (
        Metadata_SU_TXT,
        SU_TXT_SU_ID,
        SU_TXT_ChangedAt,
        SU_TXT_Subject_Text
    )
    SELECT
        Metadata_SU_TXT,
        SU_TXT_SU_ID,
        SU_TXT_ChangedAt,
        SU_TXT_Subject_Text
    FROM
        @SU_TXT_Subject_Text
    WHERE
        SU_TXT_StatementType = 'P';
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_ASR_Subject_Assessment TABLE (
    SU_ASR_SU_ID int not null,
        Metadata_SU_ASR int not null,
        SU_ASR_ChangedAt datetime2 not null,
        SU_ASR_Subject_Assessment nvarchar(42) not null,
        SU_ASR_StatementType char(1) not null,
        primary key (
            SU_ASR_SU_ID asc, 
            SU_ASR_ChangedAt desc
        )
    );
    INSERT INTO @SU_ASR_Subject_Assessment
    SELECT
        i.SU_ASR_SU_ID,
        i.Metadata_SU_ASR,
        i.SU_ASR_ChangedAt,
        i.SU_ASR_Subject_Assessment,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_ASR_SU_ID
        FROM
            [dbo].[SU_ASR_Subject_Assessment] x
        WHERE
            x.SU_ASR_SU_ID = i.SU_ASR_SU_ID
        AND
            x.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
        AND
            x.SU_ASR_Subject_Assessment = i.SU_ASR_Subject_Assessment
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ASR_SU_ID,
            i.SU_ASR_ChangedAt
        FROM
            @SU_ASR_Subject_Assessment i
        JOIN
            [dbo].[SU_ASR_Subject_Assessment] x
        ON
            x.SU_ASR_SU_ID = i.SU_ASR_SU_ID
        AND
            x.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_ASR_Subject_Assessment for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_ChangedAt,
        SU_ASR_Subject_Assessment
    )
    SELECT
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_ChangedAt,
        SU_ASR_Subject_Assessment
    FROM
        @SU_ASR_Subject_Assessment
    WHERE
        SU_ASR_StatementType = 'P';
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_ERS_Subject_Erasable TABLE (
    SU_ERS_SU_ID int not null,
        Metadata_SU_ERS int not null,
        SU_ERS_ChangedAt datetime2 not null,
        SU_ERS_Subject_Erasable nvarchar(42) not null,
        SU_ERS_StatementType char(1) not null,
        primary key (
            SU_ERS_SU_ID asc, 
            SU_ERS_ChangedAt desc
        )
    );
    INSERT INTO @SU_ERS_Subject_Erasable
    SELECT
        i.SU_ERS_SU_ID,
        i.Metadata_SU_ERS,
        i.SU_ERS_ChangedAt,
        i.SU_ERS_Subject_Erasable,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_ERS_SU_ID
        FROM
            [dbo].[SU_ERS_Subject_Erasable] x
        WHERE
            x.SU_ERS_SU_ID = i.SU_ERS_SU_ID
        AND
            x.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
        AND
            x.SU_ERS_Subject_Erasable = i.SU_ERS_Subject_Erasable
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ERS_SU_ID,
            i.SU_ERS_ChangedAt
        FROM
            @SU_ERS_Subject_Erasable i
        JOIN
            [dbo].[SU_ERS_Subject_Erasable] x
        ON
            x.SU_ERS_SU_ID = i.SU_ERS_SU_ID
        AND
            x.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_ERS_Subject_Erasable for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_ChangedAt,
        SU_ERS_Subject_Erasable
    )
    SELECT
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_ChangedAt,
        SU_ERS_Subject_Erasable
    FROM
        @SU_ERS_Subject_Erasable
    WHERE
        SU_ERS_StatementType = 'P';
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.OB_NAM_OB_ID
        FROM
            inserted i
        JOIN
            [dbo].[OB_NAM_Object_Name] x
        ON
            x.OB_NAM_OB_ID = i.OB_NAM_OB_ID
        WHERE NOT (
            x.OB_NAM_Object_Name = i.OB_NAM_Object_Name
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
    INSERT INTO [dbo].[OB_NAM_Object_Name] (
        Metadata_OB_NAM,
        OB_NAM_OB_ID,
        OB_NAM_Object_Name
    )
    SELECT
        Metadata_OB_NAM,
        OB_NAM_OB_ID,
        OB_NAM_Object_Name
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.OB_NAM_OB_ID
        FROM
            [dbo].[OB_NAM_Object_Name] x
        WHERE
            x.OB_NAM_OB_ID = i.OB_NAM_OB_ID
        AND
            x.OB_NAM_Object_Name = i.OB_NAM_Object_Name
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
        SU_NAM_Subject_Name nvarchar(42) null,
        SU_COD_SU_ID int null,
        Metadata_SU_COD int null,
        SU_COD_Subject_Code nvarchar(42) null,
        SU_GRD_SU_ID int null,
        Metadata_SU_GRD int null,
        SU_GRD_GRD_Grade nvarchar(42) null,
        SU_GRD_Metadata_GRD int null,
        SU_GRD_GRD_ID tinyint null,
        SU_NOT_SU_ID int null,
        Metadata_SU_NOT int null,
        SU_NOT_Subject_Note nvarchar(max) null,
        SU_TTL_SU_ID int null,
        Metadata_SU_TTL int null,
        SU_TTL_ChangedAt datetime2 null,
        SU_TTL_Subject_Title nvarchar(42) null,
        SU_STA_SU_ID int null,
        Metadata_SU_STA int null,
        SU_STA_ChangedAt datetime2 null,
        SU_STA_Subject_State nvarchar(42) null,
        SU_LBL_SU_ID int null,
        Metadata_SU_LBL int null,
        SU_LBL_ChangedAt datetime2 null,
        SU_LBL_Subject_Label nvarchar(42) null,
        SU_TAG_SU_ID int null,
        Metadata_SU_TAG int null,
        SU_TAG_ChangedAt datetime2 null,
        SU_TAG_Subject_Tag nvarchar(42) null,
        SU_LVL_SU_ID int null,
        Metadata_SU_LVL int null,
        SU_LVL_ChangedAt datetime2 null,
        SU_LVL_GRD_Grade nvarchar(42) null,
        SU_LVL_Metadata_GRD int null,
        SU_LVL_GRD_ID tinyint null,
        SU_TXT_SU_ID int null,
        Metadata_SU_TXT int null,
        SU_TXT_ChangedAt datetime2 null,
        SU_TXT_Subject_Text nvarchar(max) null,
        SU_ASR_SU_ID int null,
        Metadata_SU_ASR int null,
        SU_ASR_ChangedAt datetime2 null,
        SU_ASR_Subject_Assessment nvarchar(42) null,
        SU_ERS_SU_ID int null,
        Metadata_SU_ERS int null,
        SU_ERS_ChangedAt datetime2 null,
        SU_ERS_Subject_Erasable nvarchar(42) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.SU_ID, a.SU_ID),
        i.Metadata_SU,
        ISNULL(ISNULL(i.SU_NAM_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_NAM, i.Metadata_SU),
        i.SU_NAM_Subject_Name,
        ISNULL(ISNULL(i.SU_COD_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_COD, i.Metadata_SU),
        i.SU_COD_Subject_Code,
        ISNULL(ISNULL(i.SU_GRD_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_GRD, i.Metadata_SU),
        i.SU_GRD_GRD_Grade,
        ISNULL(i.SU_GRD_Metadata_GRD, i.Metadata_SU),
        i.SU_GRD_GRD_ID,
        ISNULL(ISNULL(i.SU_NOT_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_NOT, i.Metadata_SU),
        i.SU_NOT_Subject_Note,
        ISNULL(ISNULL(i.SU_TTL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TTL, i.Metadata_SU),
        ISNULL(i.SU_TTL_ChangedAt, @now),
        i.SU_TTL_Subject_Title,
        ISNULL(ISNULL(i.SU_STA_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_STA, i.Metadata_SU),
        ISNULL(i.SU_STA_ChangedAt, @now),
        i.SU_STA_Subject_State,
        ISNULL(ISNULL(i.SU_LBL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_LBL, i.Metadata_SU),
        ISNULL(i.SU_LBL_ChangedAt, @now),
        i.SU_LBL_Subject_Label,
        ISNULL(ISNULL(i.SU_TAG_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TAG, i.Metadata_SU),
        ISNULL(i.SU_TAG_ChangedAt, @now),
        i.SU_TAG_Subject_Tag,
        ISNULL(ISNULL(i.SU_LVL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_LVL, i.Metadata_SU),
        ISNULL(i.SU_LVL_ChangedAt, @now),
        i.SU_LVL_GRD_Grade,
        ISNULL(i.SU_LVL_Metadata_GRD, i.Metadata_SU),
        i.SU_LVL_GRD_ID,
        ISNULL(ISNULL(i.SU_TXT_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TXT, i.Metadata_SU),
        ISNULL(i.SU_TXT_ChangedAt, @now),
        i.SU_TXT_Subject_Text,
        ISNULL(ISNULL(i.SU_ASR_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_ASR, i.Metadata_SU),
        ISNULL(i.SU_ASR_ChangedAt, @now),
        i.SU_ASR_Subject_Assessment,
        ISNULL(ISNULL(i.SU_ERS_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_ERS, i.Metadata_SU),
        ISNULL(i.SU_ERS_ChangedAt, @now),
        i.SU_ERS_Subject_Erasable
    FROM (
        SELECT
            SU_ID,
            Metadata_SU,
            SU_NAM_SU_ID,
            Metadata_SU_NAM,
            SU_NAM_Subject_Name,
            SU_COD_SU_ID,
            Metadata_SU_COD,
            SU_COD_Subject_Code,
            SU_GRD_SU_ID,
            Metadata_SU_GRD,
            SU_GRD_GRD_Grade,
            SU_GRD_Metadata_GRD,
            SU_GRD_GRD_ID,
            SU_NOT_SU_ID,
            Metadata_SU_NOT,
            SU_NOT_Subject_Note,
            SU_TTL_SU_ID,
            Metadata_SU_TTL,
            SU_TTL_ChangedAt,
            SU_TTL_Subject_Title,
            SU_STA_SU_ID,
            Metadata_SU_STA,
            SU_STA_ChangedAt,
            SU_STA_Subject_State,
            SU_LBL_SU_ID,
            Metadata_SU_LBL,
            SU_LBL_ChangedAt,
            SU_LBL_Subject_Label,
            SU_TAG_SU_ID,
            Metadata_SU_TAG,
            SU_TAG_ChangedAt,
            SU_TAG_Subject_Tag,
            SU_LVL_SU_ID,
            Metadata_SU_LVL,
            SU_LVL_ChangedAt,
            SU_LVL_GRD_Grade,
            SU_LVL_Metadata_GRD,
            SU_LVL_GRD_ID,
            SU_TXT_SU_ID,
            Metadata_SU_TXT,
            SU_TXT_ChangedAt,
            SU_TXT_Subject_Text,
            SU_ASR_SU_ID,
            Metadata_SU_ASR,
            SU_ASR_ChangedAt,
            SU_ASR_Subject_Assessment,
            SU_ERS_SU_ID,
            Metadata_SU_ERS,
            SU_ERS_ChangedAt,
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
        SU_NAM_Subject_Name
    )
    SELECT DISTINCT
        i.Metadata_SU_NAM,
        i.SU_NAM_SU_ID,
        i.SU_NAM_Subject_Name
    FROM
        @inserted i
    WHERE
        i.SU_NAM_Subject_Name is not null;
    INSERT INTO [dbo].[SU_COD_Subject_Code] (
        Metadata_SU_COD,
        SU_COD_SU_ID,
        SU_COD_Subject_Code
    )
    SELECT DISTINCT
        i.Metadata_SU_COD,
        i.SU_COD_SU_ID,
        i.SU_COD_Subject_Code
    FROM
        @inserted i
    WHERE
        i.SU_COD_Subject_Code is not null;
    INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
        Metadata_SU_GRD,
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID
    )
    SELECT DISTINCT
        i.Metadata_SU_GRD,
        i.SU_GRD_SU_ID,
        ISNULL(i.SU_GRD_GRD_ID, [kGRD].GRD_ID) 
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
        SU_NOT_Subject_Note
    )
    SELECT 
        i.Metadata_SU_NOT,
        i.SU_NOT_SU_ID,
        i.SU_NOT_Subject_Note
    FROM
        @inserted i
    WHERE
        i.SU_NOT_Subject_Note is not null;
    INSERT INTO [dbo].[SU_TTL_Subject_Title] (
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_ChangedAt,
        SU_TTL_Subject_Title
    )
    SELECT DISTINCT
        i.Metadata_SU_TTL,
        i.SU_TTL_SU_ID,
        i.SU_TTL_ChangedAt,
        i.SU_TTL_Subject_Title
    FROM
        @inserted i
    WHERE
        i.SU_TTL_Subject_Title is not null;
    INSERT INTO [dbo].[SU_STA_Subject_State] (
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    SELECT DISTINCT
        i.Metadata_SU_STA,
        i.SU_STA_SU_ID,
        i.SU_STA_ChangedAt,
        i.SU_STA_Subject_State
    FROM
        @inserted i
    WHERE
        i.SU_STA_Subject_State is not null;
    INSERT INTO [dbo].[SU_LBL_Subject_Label] (
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    SELECT DISTINCT
        i.Metadata_SU_LBL,
        i.SU_LBL_SU_ID,
        i.SU_LBL_ChangedAt,
        i.SU_LBL_Subject_Label
    FROM
        @inserted i
    WHERE
        i.SU_LBL_Subject_Label is not null;
    INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_ChangedAt,
        SU_TAG_Subject_Tag
    )
    SELECT DISTINCT
        i.Metadata_SU_TAG,
        i.SU_TAG_SU_ID,
        i.SU_TAG_ChangedAt,
        i.SU_TAG_Subject_Tag
    FROM
        @inserted i
    WHERE
        i.SU_TAG_Subject_Tag is not null;
    INSERT INTO [dbo].[SU_LVL_Subject_Level] (
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_ChangedAt,
        SU_LVL_GRD_ID
    )
    SELECT DISTINCT
        i.Metadata_SU_LVL,
        i.SU_LVL_SU_ID,
        i.SU_LVL_ChangedAt,
        ISNULL(i.SU_LVL_GRD_ID, [kGRD].GRD_ID) 
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
        SU_TXT_ChangedAt,
        SU_TXT_Subject_Text
    )
    SELECT 
        i.Metadata_SU_TXT,
        i.SU_TXT_SU_ID,
        i.SU_TXT_ChangedAt,
        i.SU_TXT_Subject_Text
    FROM
        @inserted i
    WHERE
        i.SU_TXT_Subject_Text is not null;
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_ChangedAt,
        SU_ASR_Subject_Assessment
    )
    SELECT DISTINCT
        i.Metadata_SU_ASR,
        i.SU_ASR_SU_ID,
        i.SU_ASR_ChangedAt,
        i.SU_ASR_Subject_Assessment
    FROM
        @inserted i
    WHERE
        i.SU_ASR_Subject_Assessment is not null;
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_ChangedAt,
        SU_ERS_Subject_Erasable
    )
    SELECT DISTINCT
        i.Metadata_SU_ERS,
        i.SU_ERS_SU_ID,
        i.SU_ERS_ChangedAt,
        i.SU_ERS_Subject_Erasable
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
    IF(UPDATE(SU_NAM_SU_ID))
        RAISERROR('The foreign key column SU_NAM_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NAM_Subject_Name))
    BEGIN
        INSERT INTO [dbo].[SU_NAM_Subject_Name] (
            Metadata_SU_NAM,
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NAM)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NAM
            END, i.Metadata_SU),
            ISNULL(i.SU_NAM_SU_ID, i.SU_ID),
            i.SU_NAM_Subject_Name
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_NAM_Subject_Name is not null
        AND ( -- a value that is left as it is states nothing
            d.SU_NAM_Subject_Name is null OR
            d.SU_NAM_Subject_Name <> i.SU_NAM_Subject_Name
        );
    END
    IF(UPDATE(SU_COD_SU_ID))
        RAISERROR('The foreign key column SU_COD_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_COD_Subject_Code))
    BEGIN
        INSERT INTO [dbo].[SU_COD_Subject_Code] (
            Metadata_SU_COD,
            SU_COD_SU_ID,
            SU_COD_Subject_Code
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_COD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_COD
            END, i.Metadata_SU),
            ISNULL(i.SU_COD_SU_ID, i.SU_ID),
            i.SU_COD_Subject_Code
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_COD_Subject_Code is not null
        AND ( -- a value that is left as it is states nothing
            d.SU_COD_Subject_Code is null OR
            d.SU_COD_Subject_Code <> i.SU_COD_Subject_Code
        );
    END
    IF(UPDATE(SU_GRD_SU_ID))
        RAISERROR('The foreign key column SU_GRD_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_GRD_GRD_ID) OR UPDATE(SU_GRD_GRD_Grade))
    BEGIN
        INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
            Metadata_SU_GRD,
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_GRD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_GRD
            END, i.Metadata_SU),
            ISNULL(i.SU_GRD_SU_ID, i.SU_ID),
            CASE WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID ELSE [kGRD].GRD_ID END
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
        WHERE
            CASE WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID ELSE [kGRD].GRD_ID END is not null
        AND ( -- a value that is left as it is states nothing
            d.SU_GRD_GRD_ID is null OR
            d.SU_GRD_GRD_ID <> CASE WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID ELSE [kGRD].GRD_ID END
        );
    END
    IF(UPDATE(SU_NOT_SU_ID))
        RAISERROR('The foreign key column SU_NOT_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NOT_Subject_Note))
    BEGIN
        INSERT INTO [dbo].[SU_NOT_Subject_Note] (
            Metadata_SU_NOT,
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note
        )
        SELECT 
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NOT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NOT
            END, i.Metadata_SU),
            ISNULL(i.SU_NOT_SU_ID, i.SU_ID),
            i.SU_NOT_Subject_Note
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_NOT_Subject_Note is not null
        AND ( -- a value that is left as it is states nothing
            d.SU_NOT_Subject_Note is null OR
            d.SU_NOT_Checksum <> dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
        );
    END
    IF(UPDATE(SU_TTL_SU_ID))
        RAISERROR('The foreign key column SU_TTL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TTL_Subject_Title))
    BEGIN
        INSERT INTO [dbo].[SU_TTL_Subject_Title] (
            Metadata_SU_TTL,
            SU_TTL_SU_ID,
            SU_TTL_ChangedAt,
            SU_TTL_Subject_Title
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TTL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TTL
            END, i.Metadata_SU),
            ISNULL(i.SU_TTL_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_TTL_Subject_Title is null THEN i.SU_TTL_ChangedAt
                WHEN UPDATE(SU_TTL_ChangedAt) THEN i.SU_TTL_ChangedAt
            END, @now) as datetime2),
            i.SU_TTL_Subject_Title
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_TTL_Subject_Title is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_TTL_ChangedAt) OR
            d.SU_TTL_Subject_Title is null OR
            d.SU_TTL_Subject_Title <> i.SU_TTL_Subject_Title
        );
    END
    IF(UPDATE(SU_STA_SU_ID))
        RAISERROR('The foreign key column SU_STA_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_STA_Subject_State))
    BEGIN
        INSERT INTO [dbo].[SU_STA_Subject_State] (
            Metadata_SU_STA,
            SU_STA_SU_ID,
            SU_STA_ChangedAt,
            SU_STA_Subject_State
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_STA)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_STA
            END, i.Metadata_SU),
            ISNULL(i.SU_STA_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_STA_Subject_State is null THEN i.SU_STA_ChangedAt
                WHEN UPDATE(SU_STA_ChangedAt) THEN i.SU_STA_ChangedAt
            END, @now) as datetime2),
            i.SU_STA_Subject_State
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_STA_Subject_State is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_STA_ChangedAt) OR
            d.SU_STA_Subject_State is null OR
            d.SU_STA_Subject_State <> i.SU_STA_Subject_State
        );
    END
    IF(UPDATE(SU_LBL_SU_ID))
        RAISERROR('The foreign key column SU_LBL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LBL_Subject_Label))
    BEGIN
        INSERT INTO [dbo].[SU_LBL_Subject_Label] (
            Metadata_SU_LBL,
            SU_LBL_SU_ID,
            SU_LBL_ChangedAt,
            SU_LBL_Subject_Label
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LBL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LBL
            END, i.Metadata_SU),
            ISNULL(i.SU_LBL_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_LBL_Subject_Label is null THEN i.SU_LBL_ChangedAt
                WHEN UPDATE(SU_LBL_ChangedAt) THEN i.SU_LBL_ChangedAt
            END, @now) as datetime2),
            i.SU_LBL_Subject_Label
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_LBL_Subject_Label is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_LBL_ChangedAt) OR
            d.SU_LBL_Subject_Label is null OR
            d.SU_LBL_Subject_Label <> i.SU_LBL_Subject_Label
        );
    END
    IF(UPDATE(SU_TAG_SU_ID))
        RAISERROR('The foreign key column SU_TAG_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TAG_Subject_Tag))
    BEGIN
        INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
            Metadata_SU_TAG,
            SU_TAG_SU_ID,
            SU_TAG_ChangedAt,
            SU_TAG_Subject_Tag
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TAG)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TAG
            END, i.Metadata_SU),
            ISNULL(i.SU_TAG_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_TAG_Subject_Tag is null THEN i.SU_TAG_ChangedAt
                WHEN UPDATE(SU_TAG_ChangedAt) THEN i.SU_TAG_ChangedAt
            END, @now) as datetime2),
            i.SU_TAG_Subject_Tag
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_TAG_Subject_Tag is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_TAG_ChangedAt) OR
            d.SU_TAG_Subject_Tag is null OR
            d.SU_TAG_Subject_Tag <> i.SU_TAG_Subject_Tag
        );
    END
    IF(UPDATE(SU_LVL_SU_ID))
        RAISERROR('The foreign key column SU_LVL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LVL_GRD_ID) OR UPDATE(SU_LVL_GRD_Grade))
    BEGIN
        INSERT INTO [dbo].[SU_LVL_Subject_Level] (
            Metadata_SU_LVL,
            SU_LVL_SU_ID,
            SU_LVL_ChangedAt,
            SU_LVL_GRD_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LVL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LVL
            END, i.Metadata_SU),
            ISNULL(i.SU_LVL_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_LVL_GRD_ID is null AND [kGRD].GRD_ID is null THEN i.SU_LVL_ChangedAt
                WHEN UPDATE(SU_LVL_ChangedAt) THEN i.SU_LVL_ChangedAt
            END, @now) as datetime2),
            CASE WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID ELSE [kGRD].GRD_ID END
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
        WHERE
            CASE WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID ELSE [kGRD].GRD_ID END is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_LVL_ChangedAt) OR
            d.SU_LVL_GRD_ID is null OR
            d.SU_LVL_GRD_ID <> CASE WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID ELSE [kGRD].GRD_ID END
        );
    END
    IF(UPDATE(SU_TXT_SU_ID))
        RAISERROR('The foreign key column SU_TXT_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TXT_Subject_Text))
    BEGIN
        INSERT INTO [dbo].[SU_TXT_Subject_Text] (
            Metadata_SU_TXT,
            SU_TXT_SU_ID,
            SU_TXT_ChangedAt,
            SU_TXT_Subject_Text
        )
        SELECT 
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TXT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TXT
            END, i.Metadata_SU),
            ISNULL(i.SU_TXT_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_TXT_Subject_Text is null THEN i.SU_TXT_ChangedAt
                WHEN UPDATE(SU_TXT_ChangedAt) THEN i.SU_TXT_ChangedAt
            END, @now) as datetime2),
            i.SU_TXT_Subject_Text
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_TXT_Subject_Text is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_TXT_ChangedAt) OR
            d.SU_TXT_Subject_Text is null OR
            d.SU_TXT_Checksum <> dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
        );
    END
    IF(UPDATE(SU_ASR_SU_ID))
        RAISERROR('The foreign key column SU_ASR_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ASR_Subject_Assessment))
    BEGIN
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
            Metadata_SU_ASR,
            SU_ASR_SU_ID,
            SU_ASR_ChangedAt,
            SU_ASR_Subject_Assessment
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ASR)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ASR
            END, i.Metadata_SU),
            ISNULL(i.SU_ASR_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_ASR_Subject_Assessment is null THEN i.SU_ASR_ChangedAt
                WHEN UPDATE(SU_ASR_ChangedAt) THEN i.SU_ASR_ChangedAt
            END, @now) as datetime2),
            i.SU_ASR_Subject_Assessment
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_ASR_Subject_Assessment is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_ASR_ChangedAt) OR
            d.SU_ASR_Subject_Assessment is null OR
            d.SU_ASR_Subject_Assessment <> i.SU_ASR_Subject_Assessment
        );
    END
    IF(UPDATE(SU_ERS_SU_ID))
        RAISERROR('The foreign key column SU_ERS_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ERS_Subject_Erasable))
    BEGIN
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
            Metadata_SU_ERS,
            SU_ERS_SU_ID,
            SU_ERS_ChangedAt,
            SU_ERS_Subject_Erasable
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ERS)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ERS
            END, i.Metadata_SU),
            ISNULL(i.SU_ERS_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_ERS_Subject_Erasable is null THEN i.SU_ERS_ChangedAt
                WHEN UPDATE(SU_ERS_ChangedAt) THEN i.SU_ERS_ChangedAt
            END, @now) as datetime2),
            i.SU_ERS_Subject_Erasable
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_ERS_Subject_Erasable is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_ERS_ChangedAt) OR
            d.SU_ERS_Subject_Erasable is null OR
            d.SU_ERS_Subject_Erasable <> i.SU_ERS_Subject_Erasable
        );
        SELECT
            cast(CASE WHEN UPDATE(SU_ERS_ChangedAt) THEN i.SU_ERS_ChangedAt ELSE @now END as datetime2) as SU_ERS_Deleted,
            i.SU_ERS_SU_ID
        INTO
            #SU_ERS
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ERS_SU_ID = i.SU_ERS_SU_ID
        AND
            d.SU_ERS_Subject_Erasable is not null
        WHERE
            i.SU_ERS_Subject_Erasable is null
        AND
            i.Deletable_SU_ERS = 1;
        IF(@@ROWCOUNT > 0)
        BEGIN
            IF OBJECT_ID('[dbo].[SU_ERS_Subject_Erasable_Deleted]') is null
            SELECT TOP 0 
                *, 
                CAST(null as datetime2) as SU_ERS_Deleted
            INTO 
                [dbo].[SU_ERS_Subject_Erasable_Deleted]
            FROM 
                [dbo].[SU_ERS_Subject_Erasable];
            DELETE [ERS]
            OUTPUT
                deleted.*,
                ISNULL(d.SU_ERS_Deleted, @now) 
            INTO
                [dbo].[SU_ERS_Subject_Erasable_Deleted]
            FROM
                [dbo].[SU_ERS_Subject_Erasable] [ERS]
            JOIN
                #SU_ERS d
            ON
                d.SU_ERS_SU_ID = [ERS].SU_ERS_SU_ID
        END
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
    DELETE [NAM]
    FROM
        [dbo].[SU_NAM_Subject_Name] [NAM]
    JOIN
        deleted d
    ON
        d.SU_NAM_SU_ID = [NAM].SU_NAM_SU_ID;
    DELETE [COD]
    FROM
        [dbo].[SU_COD_Subject_Code] [COD]
    JOIN
        deleted d
    ON
        d.SU_COD_SU_ID = [COD].SU_COD_SU_ID;
    DELETE [GRD]
    FROM
        [dbo].[SU_GRD_Subject_Grade] [GRD]
    JOIN
        deleted d
    ON
        d.SU_GRD_SU_ID = [GRD].SU_GRD_SU_ID;
    DELETE [NOT]
    FROM
        [dbo].[SU_NOT_Subject_Note] [NOT]
    JOIN
        deleted d
    ON
        d.SU_NOT_SU_ID = [NOT].SU_NOT_SU_ID;
    DELETE [TTL]
    FROM
        [dbo].[SU_TTL_Subject_Title] [TTL]
    JOIN
        deleted d
    ON
        d.SU_TTL_ChangedAt = [TTL].SU_TTL_ChangedAt
    AND
        d.SU_TTL_SU_ID = [TTL].SU_TTL_SU_ID;
    DELETE [STA]
    FROM
        [dbo].[SU_STA_Subject_State] [STA]
    JOIN
        deleted d
    ON
        d.SU_STA_ChangedAt = [STA].SU_STA_ChangedAt
    AND
        d.SU_STA_SU_ID = [STA].SU_STA_SU_ID;
    DELETE [LBL]
    FROM
        [dbo].[SU_LBL_Subject_Label] [LBL]
    JOIN
        deleted d
    ON
        d.SU_LBL_ChangedAt = [LBL].SU_LBL_ChangedAt
    AND
        d.SU_LBL_SU_ID = [LBL].SU_LBL_SU_ID;
    DELETE [TAG]
    FROM
        [dbo].[SU_TAG_Subject_Tag] [TAG]
    JOIN
        deleted d
    ON
        d.SU_TAG_ChangedAt = [TAG].SU_TAG_ChangedAt
    AND
        d.SU_TAG_SU_ID = [TAG].SU_TAG_SU_ID;
    DELETE [LVL]
    FROM
        [dbo].[SU_LVL_Subject_Level] [LVL]
    JOIN
        deleted d
    ON
        d.SU_LVL_ChangedAt = [LVL].SU_LVL_ChangedAt
    AND
        d.SU_LVL_SU_ID = [LVL].SU_LVL_SU_ID;
    DELETE [TXT]
    FROM
        [dbo].[SU_TXT_Subject_Text] [TXT]
    JOIN
        deleted d
    ON
        d.SU_TXT_ChangedAt = [TXT].SU_TXT_ChangedAt
    AND
        d.SU_TXT_SU_ID = [TXT].SU_TXT_SU_ID;
    DELETE [ASR]
    FROM
        [dbo].[SU_ASR_Subject_Assessment] [ASR]
    JOIN
        deleted d
    ON
        d.SU_ASR_ChangedAt = [ASR].SU_ASR_ChangedAt
    AND
        d.SU_ASR_SU_ID = [ASR].SU_ASR_SU_ID;
    DELETE [ERS]
    FROM
        [dbo].[SU_ERS_Subject_Erasable] [ERS]
    JOIN
        deleted d
    ON
        d.SU_ERS_ChangedAt = [ERS].SU_ERS_ChangedAt
    AND
        d.SU_ERS_SU_ID = [ERS].SU_ERS_SU_ID;
    DECLARE @deleted TABLE (
        SU_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (SU_ID)
    SELECT a.SU_ID
    FROM (
        SELECT [SU].SU_ID
        FROM [dbo].[SU_Subject] [SU] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 SU_NAM_SU_ID
            FROM [dbo].[SU_NAM_Subject_Name] WITH(NOLOCK)
            WHERE SU_NAM_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_COD_SU_ID
            FROM [dbo].[SU_COD_Subject_Code] WITH(NOLOCK)
            WHERE SU_COD_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_GRD_SU_ID
            FROM [dbo].[SU_GRD_Subject_Grade] WITH(NOLOCK)
            WHERE SU_GRD_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_NOT_SU_ID
            FROM [dbo].[SU_NOT_Subject_Note] WITH(NOLOCK)
            WHERE SU_NOT_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_TTL_SU_ID
            FROM [dbo].[SU_TTL_Subject_Title] WITH(NOLOCK)
            WHERE SU_TTL_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_STA_SU_ID
            FROM [dbo].[SU_STA_Subject_State] WITH(NOLOCK)
            WHERE SU_STA_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_LBL_SU_ID
            FROM [dbo].[SU_LBL_Subject_Label] WITH(NOLOCK)
            WHERE SU_LBL_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_TAG_SU_ID
            FROM [dbo].[SU_TAG_Subject_Tag] WITH(NOLOCK)
            WHERE SU_TAG_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_LVL_SU_ID
            FROM [dbo].[SU_LVL_Subject_Level] WITH(NOLOCK)
            WHERE SU_LVL_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_TXT_SU_ID
            FROM [dbo].[SU_TXT_Subject_Text] WITH(NOLOCK)
            WHERE SU_TXT_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_ASR_SU_ID
            FROM [dbo].[SU_ASR_Subject_Assessment] WITH(NOLOCK)
            WHERE SU_ASR_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_ERS_SU_ID
            FROM [dbo].[SU_ERS_Subject_Erasable] WITH(NOLOCK)
            WHERE SU_ERS_SU_ID = [SU].SU_ID
        )
    ) a
    JOIN deleted d
    ON d.SU_ID = a.SU_ID;
    DELETE [SU]
    FROM [dbo].[SU_Subject] [SU]
    JOIN @deleted d
    ON d.SU_ID = [SU].SU_ID;
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
        OB_NAM_Object_Name nvarchar(42) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.OB_ID, a.OB_ID),
        i.Metadata_OB,
        ISNULL(ISNULL(i.OB_NAM_OB_ID, i.OB_ID), a.OB_ID),
        ISNULL(i.Metadata_OB_NAM, i.Metadata_OB),
        i.OB_NAM_Object_Name
    FROM (
        SELECT
            OB_ID,
            Metadata_OB,
            OB_NAM_OB_ID,
            Metadata_OB_NAM,
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
        OB_NAM_Object_Name
    )
    SELECT DISTINCT
        i.Metadata_OB_NAM,
        i.OB_NAM_OB_ID,
        i.OB_NAM_Object_Name
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
    IF(UPDATE(OB_NAM_OB_ID))
        RAISERROR('The foreign key column OB_NAM_OB_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_NAM_Object_Name))
    BEGIN
        INSERT INTO [dbo].[OB_NAM_Object_Name] (
            Metadata_OB_NAM,
            OB_NAM_OB_ID,
            OB_NAM_Object_Name
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_OB) AND NOT UPDATE(Metadata_OB_NAM)
                THEN i.Metadata_OB
                ELSE i.Metadata_OB_NAM
            END, i.Metadata_OB),
            ISNULL(i.OB_NAM_OB_ID, i.OB_ID),
            i.OB_NAM_Object_Name
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.OB_ID = i.OB_ID
        WHERE
            i.OB_NAM_Object_Name is not null
        AND ( -- a value that is left as it is states nothing
            d.OB_NAM_Object_Name is null OR
            d.OB_NAM_Object_Name <> i.OB_NAM_Object_Name
        );
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
    DELETE [NAM]
    FROM
        [dbo].[OB_NAM_Object_Name] [NAM]
    JOIN
        deleted d
    ON
        d.OB_NAM_OB_ID = [NAM].OB_NAM_OB_ID;
    DECLARE @deleted TABLE (
        OB_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (OB_ID)
    SELECT a.OB_ID
    FROM (
        SELECT [OB].OB_ID
        FROM [dbo].[OB_Object] [OB] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 OB_NAM_OB_ID
            FROM [dbo].[OB_NAM_Object_Name] WITH(NOLOCK)
            WHERE OB_NAM_OB_ID = [OB].OB_ID
        )
    ) a
    JOIN deleted d
    ON d.OB_ID = a.OB_ID;
    DELETE [OB]
    FROM [dbo].[OB_Object] [OB]
    JOIN @deleted d
    ON d.OB_ID = [OB].OB_ID;
END
GO
-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest nexus perspective make it behave like a table for CRUD
-- operations over the nexus and its attributes. A nexus base row is immutable apart from its metadata dummy column;
-- historization only applies to its historized attributes (the base row has no changing column). Roles (anchor/nexus
-- /knot foreign keys) are part of the immutable nexus identity row and therefore are not updatable once set.
--
-- Three INSTEAD OF triggers are created when a nexus has attributes: insert, update, delete.
-- Insert: creates base nexus rows for NULL identity inputs and inserts attribute rows (knotted or not) with defaults.
-- Update: only allows changing attribute values (including knotted values); role foreign keys and identity are not
-- updatable. Historized attributes get a new version row; non-historized ones behave idempotently.
-- Delete: deletes attribute rows and conditionally deletes the base nexus row if it becomes orphaned (no attributes).
--
-- Deletable attributes (soft delete semantics) follow the same pattern as anchors: if attribute value set to NULL and
-- deletable flag = 1, a deletion record is stored in a parallel deletion table capturing deletion time.
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
    DECLARE @EV TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        EV_ID int not null
    );
    INSERT INTO [dbo].[EV_Event] (
        SU_ID_for,
        Metadata_EV 
    )
    OUTPUT
        inserted.EV_ID
    INTO
        @EV
    SELECT
        SU_ID_for,
        Metadata_EV 
    FROM
        inserted
    WHERE
        inserted.EV_ID is null;
    DECLARE @inserted TABLE (
        EV_ID int not null,
        Metadata_EV int not null,
        EV_QTY_EV_ID int null,
        Metadata_EV_QTY int null,
        EV_QTY_Event_Quantity int null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.EV_ID, a.EV_ID),
        i.Metadata_EV,
        ISNULL(ISNULL(i.EV_QTY_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_QTY, i.Metadata_EV),
        i.EV_QTY_Event_Quantity
    FROM (
        SELECT
            EV_ID,
            Metadata_EV,
            EV_QTY_EV_ID,
            Metadata_EV_QTY,
            EV_QTY_Event_Quantity,
            ROW_NUMBER() OVER (PARTITION BY EV_ID ORDER BY EV_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @EV a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
        Metadata_EV_QTY,
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity
    )
    SELECT DISTINCT
        i.Metadata_EV_QTY,
        i.EV_QTY_EV_ID,
        i.EV_QTY_Event_Quantity
    FROM
        @inserted i
    WHERE
        i.EV_QTY_Event_Quantity is not null;
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
    IF(UPDATE(EV_QTY_EV_ID))
        RAISERROR('The foreign key column EV_QTY_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_QTY_Event_Quantity))
    BEGIN
        INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
            Metadata_EV_QTY,
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_QTY)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_QTY
            END, i.Metadata_EV),
            ISNULL(i.EV_QTY_EV_ID, i.EV_ID),
            i.EV_QTY_Event_Quantity
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_QTY_Event_Quantity is not null
        AND ( -- a value that is left as it is states nothing
            d.EV_QTY_Event_Quantity is null OR
            d.EV_QTY_Event_Quantity <> i.EV_QTY_Event_Quantity
        );
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
    DELETE [QTY]
    FROM
        [dbo].[EV_QTY_Event_Quantity] [QTY]
    JOIN
        deleted d
    ON
        d.EV_QTY_EV_ID = [QTY].EV_QTY_EV_ID;
    DECLARE @deleted TABLE (
        EV_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (EV_ID)
    SELECT a.EV_ID
    FROM (
        SELECT [EV].EV_ID
        FROM [dbo].[EV_Event] [EV] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 EV_QTY_EV_ID
            FROM [dbo].[EV_QTY_Event_Quantity] WITH(NOLOCK)
            WHERE EV_QTY_EV_ID = [EV].EV_ID
        )
    ) a
    JOIN deleted d
    ON d.EV_ID = a.EV_ID;
    DELETE [EV]
    FROM [dbo].[EV_Event] [EV]
    JOIN @deleted d
    ON d.EV_ID = [EV].EV_ID;
END
GO
-- TIE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------------
--
-- Ties may be prevented from storing restatements.
-- A restatement is when the same (non-key) values occurs for two adjacent points
-- in changing time. Note that restatement checking is not done for
-- unreliable information as this could prevent demotion.
--
-- If actual deletes are made, the remaining information will not
-- be checked for restatements.
--
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_SU_keeper_OB_thing_GRD_rank (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_SU_keeper_OB_thing_GRD_rank', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_SU_keeper_OB_thing_GRD_rank];
GO
CREATE TRIGGER [dbo].[rt_SU_keeper_OB_thing_GRD_rank] ON [dbo].[SU_keeper_OB_thing_GRD_rank]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @inserted TABLE (
        Metadata_SU_keeper_OB_thing_GRD_rank int not null,
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null,
        primary key (
            SU_ID_keeper asc,
            OB_ID_thing asc,
            SU_keeper_OB_thing_GRD_rank_ChangedAt desc
        )
    );
    INSERT INTO @inserted (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    FROM
        inserted;
    INSERT INTO @inserted (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        p.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank
    FROM (
        SELECT DISTINCT
            SU_ID_keeper,
            OB_ID_thing
        FROM 
            @inserted 
    ) i
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank] p
    ON
        p.SU_ID_keeper = i.SU_ID_keeper
    AND
        p.OB_ID_thing = i.OB_ID_thing
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            @inserted x
        WHERE 
            x.SU_keeper_OB_thing_GRD_rank_ChangedAt = p.SU_keeper_OB_thing_GRD_rank_ChangedAt
        AND
            x.SU_ID_keeper = i.SU_ID_keeper
        AND
            x.OB_ID_thing = i.OB_ID_thing
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @inserted i
        CROSS APPLY (
            SELECT TOP 1
                SU_ID_keeper,
                OB_ID_thing,
                GRD_ID_rank,
                SU_keeper_OB_thing_GRD_rank_ChangedAt
            FROM
                @inserted h
            WHERE
                h.SU_ID_keeper = i.SU_ID_keeper
            AND
                h.OB_ID_thing = i.OB_ID_thing
            AND
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt < i.SU_keeper_OB_thing_GRD_rank_ChangedAt
            ORDER BY 
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC
        ) pre 
        WHERE
            i.SU_ID_keeper = pre.SU_ID_keeper
        AND
            i.OB_ID_thing = pre.OB_ID_thing
        AND
            i.GRD_ID_rank = pre.GRD_ID_rank
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in SU_keeper_OB_thing_GRD_rank for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
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
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dSU_holder_OB_item_GRD_grade', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.nSU_holder_OB_item_GRD_grade', 'V') IS NOT NULL
DROP VIEW [dbo].[nSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.pSU_holder_OB_item_GRD_grade', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.lSU_holder_OB_item_GRD_grade', 'V') IS NOT NULL
DROP VIEW [dbo].[lSU_holder_OB_item_GRD_grade];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_holder_OB_item_GRD_grade viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_holder_OB_item_GRD_grade] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_SU_holder_OB_item_GRD_grade,
    tie.SU_holder_OB_item_GRD_grade_ChangedAt,
    tie.SU_ID_holder,
    tie.OB_ID_item,
    [GRD_grade].GRD_Grade AS grade_GRD_Grade,
    [GRD_grade].Metadata_GRD AS grade_Metadata_GRD,
    tie.GRD_ID_grade
FROM
    [dbo].[SU_holder_OB_item_GRD_grade] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_grade]
ON
    [GRD_grade].GRD_ID = tie.GRD_ID_grade
WHERE
    tie.SU_holder_OB_item_GRD_grade_ChangedAt = (
        SELECT
            max(sub.SU_holder_OB_item_GRD_grade_ChangedAt)
        FROM
            [dbo].[SU_holder_OB_item_GRD_grade] sub
        WHERE
            sub.SU_ID_holder = tie.SU_ID_holder
        AND
            sub.OB_ID_item = tie.OB_ID_item
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_holder_OB_item_GRD_grade viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_holder_OB_item_GRD_grade] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_SU_holder_OB_item_GRD_grade,
    tie.SU_holder_OB_item_GRD_grade_ChangedAt,
    tie.SU_ID_holder,
    tie.OB_ID_item,
    [GRD_grade].GRD_Grade AS grade_GRD_Grade,
    [GRD_grade].Metadata_GRD AS grade_Metadata_GRD,
    tie.GRD_ID_grade
FROM
    [dbo].[SU_holder_OB_item_GRD_grade] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_grade]
ON
    [GRD_grade].GRD_ID = tie.GRD_ID_grade
WHERE
    tie.SU_holder_OB_item_GRD_grade_ChangedAt = (
        SELECT
            max(sub.SU_holder_OB_item_GRD_grade_ChangedAt)
        FROM
            [dbo].[SU_holder_OB_item_GRD_grade] sub
        WHERE
            sub.SU_ID_holder = tie.SU_ID_holder
        AND
            sub.OB_ID_item = tie.OB_ID_item
        AND
            sub.SU_holder_OB_item_GRD_grade_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_holder_OB_item_GRD_grade viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_holder_OB_item_GRD_grade]
AS
SELECT
    *
FROM
    [dbo].[pSU_holder_OB_item_GRD_grade](sysdatetime());
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
    tie.Metadata_SU_holder_OB_item_GRD_grade,
    tie.SU_holder_OB_item_GRD_grade_ChangedAt,
    tie.SU_ID_holder,
    tie.OB_ID_item,
    [GRD_grade].GRD_Grade AS grade_GRD_Grade,
    [GRD_grade].Metadata_GRD AS grade_Metadata_GRD,
    tie.GRD_ID_grade
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
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_keeper_OB_thing_GRD_rank viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_keeper_OB_thing_GRD_rank] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_SU_keeper_OB_thing_GRD_rank,
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    tie.SU_ID_keeper,
    tie.OB_ID_thing,
    [GRD_rank].GRD_Grade AS rank_GRD_Grade,
    [GRD_rank].Metadata_GRD AS rank_Metadata_GRD,
    tie.GRD_ID_rank
FROM
    [dbo].[SU_keeper_OB_thing_GRD_rank] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_rank]
ON
    [GRD_rank].GRD_ID = tie.GRD_ID_rank
WHERE
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt = (
        SELECT
            max(sub.SU_keeper_OB_thing_GRD_rank_ChangedAt)
        FROM
            [dbo].[SU_keeper_OB_thing_GRD_rank] sub
        WHERE
            sub.SU_ID_keeper = tie.SU_ID_keeper
        AND
            sub.OB_ID_thing = tie.OB_ID_thing
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_keeper_OB_thing_GRD_rank viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_keeper_OB_thing_GRD_rank] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_SU_keeper_OB_thing_GRD_rank,
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    tie.SU_ID_keeper,
    tie.OB_ID_thing,
    [GRD_rank].GRD_Grade AS rank_GRD_Grade,
    [GRD_rank].Metadata_GRD AS rank_Metadata_GRD,
    tie.GRD_ID_rank
FROM
    [dbo].[SU_keeper_OB_thing_GRD_rank] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_rank]
ON
    [GRD_rank].GRD_ID = tie.GRD_ID_rank
WHERE
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt = (
        SELECT
            max(sub.SU_keeper_OB_thing_GRD_rank_ChangedAt)
        FROM
            [dbo].[SU_keeper_OB_thing_GRD_rank] sub
        WHERE
            sub.SU_ID_keeper = tie.SU_ID_keeper
        AND
            sub.OB_ID_thing = tie.OB_ID_thing
        AND
            sub.SU_keeper_OB_thing_GRD_rank_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_keeper_OB_thing_GRD_rank viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_keeper_OB_thing_GRD_rank]
AS
SELECT
    *
FROM
    [dbo].[pSU_keeper_OB_thing_GRD_rank](sysdatetime());
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
    tie.Metadata_SU_keeper_OB_thing_GRD_rank,
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    tie.SU_ID_keeper,
    tie.OB_ID_thing,
    [GRD_rank].GRD_Grade AS rank_GRD_Grade,
    [GRD_rank].Metadata_GRD AS rank_Metadata_GRD,
    tie.GRD_ID_rank
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
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOB_part_SU_owner viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lOB_part_SU_owner] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_OB_part_SU_owner,
    tie.OB_ID_part,
    tie.SU_ID_owner
FROM
    [dbo].[OB_part_SU_owner] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pOB_part_SU_owner viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pOB_part_SU_owner] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_OB_part_SU_owner,
    tie.OB_ID_part,
    tie.SU_ID_owner
FROM
    [dbo].[OB_part_SU_owner] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOB_part_SU_owner viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nOB_part_SU_owner]
AS
SELECT
    *
FROM
    [dbo].[pOB_part_SU_owner](sysdatetime());
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
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_partner_SU_with viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_partner_SU_with] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_SU_partner_SU_with,
    tie.SU_partner_SU_with_ChangedAt,
    tie.SU_ID_partner,
    tie.SU_ID_with
FROM
    [dbo].[SU_partner_SU_with] tie
WHERE
    tie.SU_partner_SU_with_ChangedAt = (
        SELECT
            max(sub.SU_partner_SU_with_ChangedAt)
        FROM
            [dbo].[SU_partner_SU_with] sub
        WHERE
            sub.SU_ID_partner = tie.SU_ID_partner
        OR
            sub.SU_ID_with = tie.SU_ID_with
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_partner_SU_with viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_partner_SU_with] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_SU_partner_SU_with,
    tie.SU_partner_SU_with_ChangedAt,
    tie.SU_ID_partner,
    tie.SU_ID_with
FROM
    [dbo].[SU_partner_SU_with] tie
WHERE
    tie.SU_partner_SU_with_ChangedAt = (
        SELECT
            max(sub.SU_partner_SU_with_ChangedAt)
        FROM
            [dbo].[SU_partner_SU_with] sub
        WHERE
        (
                sub.SU_ID_partner = tie.SU_ID_partner
            OR
                sub.SU_ID_with = tie.SU_ID_with
        )
        AND
            sub.SU_partner_SU_with_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_partner_SU_with viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_partner_SU_with]
AS
SELECT
    *
FROM
    [dbo].[pSU_partner_SU_with](sysdatetime());
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
    tie.Metadata_SU_partner_SU_with,
    tie.SU_partner_SU_with_ChangedAt,
    tie.SU_ID_partner,
    tie.SU_ID_with
FROM
    [dbo].[SU_partner_SU_with] tie
WHERE
    tie.SU_partner_SU_with_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
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
    DECLARE @inserted TABLE (
        Metadata_SU_holder_OB_item_GRD_grade int not null,
        SU_holder_OB_item_GRD_grade_StatementType char(1) not null,
        SU_holder_OB_item_GRD_grade_ChangedAt datetime2 not null,
        SU_ID_holder int not null,
        OB_ID_item int not null,
        GRD_ID_grade tinyint not null,
        primary key (
            SU_ID_holder asc,
            OB_ID_item asc,
            SU_holder_OB_item_GRD_grade_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_holder_OB_item_GRD_grade, 0),
        'P', -- new posit
        ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now),
        i.SU_ID_holder,
        i.OB_ID_item,
        i.GRD_ID_grade
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_holder_OB_item_GRD_grade] x
        WHERE 
            x.SU_ID_holder = i.SU_ID_holder
        AND
            x.OB_ID_item = i.OB_ID_item
        AND
            x.GRD_ID_grade = i.GRD_ID_grade
        AND
            x.SU_holder_OB_item_GRD_grade_ChangedAt = i.SU_holder_OB_item_GRD_grade_ChangedAt
    );
    -- other values for identifiers that already have values at that time are a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_holder,
            i.OB_ID_item,
            i.SU_holder_OB_item_GRD_grade_ChangedAt
        FROM
            @inserted i
        JOIN
            [dbo].[SU_holder_OB_item_GRD_grade] x
        ON
            x.SU_ID_holder = i.SU_ID_holder
        AND
            x.OB_ID_item = i.OB_ID_item
        AND
            x.SU_holder_OB_item_GRD_grade_ChangedAt = i.SU_holder_OB_item_GRD_grade_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_holder_OB_item_GRD_grade for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade] (
        Metadata_SU_holder_OB_item_GRD_grade, 
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    )
    SELECT
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    FROM
        @inserted
    WHERE
        SU_holder_OB_item_GRD_grade_StatementType = 'P';
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
        GRD_ID_grade
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        i.SU_holder_OB_item_GRD_grade_ChangedAt,
        i.SU_ID_holder,
        i.OB_ID_item,
        ISNULL(i.GRD_ID_grade, [GRD_grade].GRD_ID) 
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
    IF(UPDATE(SU_ID_holder))
        RAISERROR('The identity column SU_ID_holder is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_item))
        RAISERROR('The identity column OB_ID_item is not updatable.', 16, 1);
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        cast(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt) THEN i.SU_holder_OB_item_GRD_grade_ChangedAt ELSE @now END as datetime2),
        i.SU_ID_holder,
        i.OB_ID_item,
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_grade]
    ON
        [GRD_grade].GRD_Grade = i.grade_GRD_Grade
    WHERE
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END is not null 
    AND
        ( -- values that are left as they are state nothing
            UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_ID_holder = i.SU_ID_holder
                AND
                    d.OB_ID_item = i.OB_ID_item
                AND
                    d.GRD_ID_grade = CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END 
            )
        );
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
    DELETE tie
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade] tie
    JOIN
        deleted d
    ON
        d.SU_holder_OB_item_GRD_grade_ChangedAt = tie.SU_holder_OB_item_GRD_grade_ChangedAt
    AND
        d.SU_ID_holder = tie.SU_ID_holder
    AND
        d.OB_ID_item = tie.OB_ID_item;
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
    DECLARE @inserted TABLE (
        Metadata_SU_keeper_OB_thing_GRD_rank int not null,
        SU_keeper_OB_thing_GRD_rank_StatementType char(1) not null,
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null,
        primary key (
            SU_ID_keeper asc,
            OB_ID_thing asc,
            SU_keeper_OB_thing_GRD_rank_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_keeper_OB_thing_GRD_rank, 0),
        'P', -- new posit
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now),
        i.SU_ID_keeper,
        i.OB_ID_thing,
        i.GRD_ID_rank
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_keeper_OB_thing_GRD_rank] x
        WHERE 
            x.SU_ID_keeper = i.SU_ID_keeper
        AND
            x.OB_ID_thing = i.OB_ID_thing
        AND
            x.GRD_ID_rank = i.GRD_ID_rank
        AND
            x.SU_keeper_OB_thing_GRD_rank_ChangedAt = i.SU_keeper_OB_thing_GRD_rank_ChangedAt
    );
    -- other values for identifiers that already have values at that time are a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_keeper,
            i.OB_ID_thing,
            i.SU_keeper_OB_thing_GRD_rank_ChangedAt
        FROM
            @inserted i
        JOIN
            [dbo].[SU_keeper_OB_thing_GRD_rank] x
        ON
            x.SU_ID_keeper = i.SU_ID_keeper
        AND
            x.OB_ID_thing = i.OB_ID_thing
        AND
            x.SU_keeper_OB_thing_GRD_rank_ChangedAt = i.SU_keeper_OB_thing_GRD_rank_ChangedAt
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
        p.Metadata_SU_keeper_OB_thing_GRD_rank, 
        'X', -- existing data
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt, 
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank
    FROM (
        SELECT DISTINCT
            SU_ID_keeper,
            OB_ID_thing
        FROM 
            @inserted 
    ) i
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank] p
    ON
        p.SU_ID_keeper = i.SU_ID_keeper
    AND
        p.OB_ID_thing = i.OB_ID_thing
    DECLARE @restated TABLE (
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null
    );
    INSERT INTO @restated
    SELECT 
        x.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        x.SU_ID_keeper,
        x.OB_ID_thing,
        x.GRD_ID_rank
    FROM (
        DELETE t
        OUTPUT 
            deleted.*
        FROM 
            @inserted t
        OUTER APPLY (
            SELECT TOP 1
                SU_ID_keeper,
                OB_ID_thing,
                GRD_ID_rank
            FROM
                @inserted h
            WHERE
                h.SU_ID_keeper = t.SU_ID_keeper
            AND
                h.OB_ID_thing = t.OB_ID_thing
            AND
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt < t.SU_keeper_OB_thing_GRD_rank_ChangedAt
            ORDER BY 
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC
        ) pre
        WHERE 
            t.SU_ID_keeper = pre.SU_ID_keeper
        AND
            t.OB_ID_thing = pre.OB_ID_thing
        AND
            t.GRD_ID_rank = pre.GRD_ID_rank
    ) x
    WHERE
        x.SU_keeper_OB_thing_GRD_rank_StatementType = 'X';
    -- delete the quenches (should be rare)
    DELETE t
    FROM 
        [dbo].[SU_keeper_OB_thing_GRD_rank] t
    JOIN 
        @restated d
    ON 
        d.SU_keeper_OB_thing_GRD_rank_ChangedAt = t.SU_keeper_OB_thing_GRD_rank_ChangedAt
    AND
        d.SU_ID_keeper = t.SU_ID_keeper
    AND
        d.OB_ID_thing = t.OB_ID_thing
    AND
        d.GRD_ID_rank = t.GRD_ID_rank
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank] (
        Metadata_SU_keeper_OB_thing_GRD_rank, 
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    FROM
        @inserted
    WHERE
        SU_keeper_OB_thing_GRD_rank_StatementType = 'P';
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
        GRD_ID_rank
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        i.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        i.SU_ID_keeper,
        i.OB_ID_thing,
        ISNULL(i.GRD_ID_rank, [GRD_rank].GRD_ID) 
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
    IF(UPDATE(SU_ID_keeper))
        RAISERROR('The identity column SU_ID_keeper is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_thing))
        RAISERROR('The identity column OB_ID_thing is not updatable.', 16, 1);
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        cast(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt) THEN i.SU_keeper_OB_thing_GRD_rank_ChangedAt ELSE @now END as datetime2),
        i.SU_ID_keeper,
        i.OB_ID_thing,
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_rank]
    ON
        [GRD_rank].GRD_Grade = i.rank_GRD_Grade
    WHERE
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END is not null 
    AND
        ( -- values that are left as they are state nothing
            UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_ID_keeper = i.SU_ID_keeper
                AND
                    d.OB_ID_thing = i.OB_ID_thing
                AND
                    d.GRD_ID_rank = CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END 
            )
        );
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
    DELETE tie
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank] tie
    JOIN
        deleted d
    ON
        d.SU_keeper_OB_thing_GRD_rank_ChangedAt = tie.SU_keeper_OB_thing_GRD_rank_ChangedAt
    AND
        d.SU_ID_keeper = tie.SU_ID_keeper
    AND
        d.OB_ID_thing = tie.OB_ID_thing;
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
    -- other values for identifiers that already have values are a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.OB_ID_part
        FROM
            inserted i
        JOIN
            [dbo].[OB_part_SU_owner] x
        ON
            x.OB_ID_part = i.OB_ID_part
        WHERE NOT (
            x.SU_ID_owner = i.SU_ID_owner
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
    INSERT INTO [dbo].[OB_part_SU_owner] (
        Metadata_OB_part_SU_owner, 
        OB_ID_part,
        SU_ID_owner
    )
    SELECT
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[OB_part_SU_owner] x
        WHERE 
            x.OB_ID_part = i.OB_ID_part
        AND
            x.SU_ID_owner = i.SU_ID_owner
    );
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
        SU_ID_owner
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_ID_part,
        i.SU_ID_owner
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
    IF(UPDATE(OB_ID_part))
        RAISERROR('The identity column OB_ID_part is not updatable.', 16, 1);
    INSERT INTO [dbo].[OB_part_SU_owner] (
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_ID_part,
        i.SU_ID_owner
    FROM
        inserted i
    WHERE
        i.SU_ID_owner is not null
    AND
        ( -- values that are left as they are state nothing
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.OB_ID_part = i.OB_ID_part
                AND
                    d.SU_ID_owner = i.SU_ID_owner
            )
        );
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
    DELETE tie
    FROM
        [dbo].[OB_part_SU_owner] tie
    JOIN
        deleted d
    ON
        d.OB_ID_part = tie.OB_ID_part;
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
    DECLARE @inserted TABLE (
        Metadata_SU_partner_SU_with int not null,
        SU_partner_SU_with_StatementType char(1) not null,
        SU_partner_SU_with_ChangedAt datetime2 not null,
        SU_ID_partner int not null,
        SU_ID_with int not null,
        primary key (
            SU_ID_partner asc,
            SU_ID_with asc,
            SU_partner_SU_with_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_partner_SU_with, 0),
        'P', -- new posit
        ISNULL(i.SU_partner_SU_with_ChangedAt, @now),
        i.SU_ID_partner,
        i.SU_ID_with
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_partner_SU_with] x
        WHERE 
            x.SU_ID_partner = i.SU_ID_partner
        AND
            x.SU_ID_with = i.SU_ID_with
        AND
            x.SU_partner_SU_with_ChangedAt = i.SU_partner_SU_with_ChangedAt
    );
    INSERT INTO [dbo].[SU_partner_SU_with] (
        Metadata_SU_partner_SU_with, 
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with
    )
    SELECT
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with
    FROM
        @inserted
    WHERE
        SU_partner_SU_with_StatementType = 'P';
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
        SU_ID_with
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        i.SU_partner_SU_with_ChangedAt,
        i.SU_ID_partner,
        i.SU_ID_with
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
    INSERT INTO [dbo].[SU_partner_SU_with] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        cast(CASE WHEN UPDATE(SU_partner_SU_with_ChangedAt) THEN i.SU_partner_SU_with_ChangedAt ELSE @now END as datetime2),
        i.SU_ID_partner,
        i.SU_ID_with
    FROM
        inserted i
    WHERE
        i.SU_ID_partner is not null
    AND
        i.SU_ID_with is not null
    AND
        ( -- values that are left as they are state nothing
            UPDATE(SU_partner_SU_with_ChangedAt) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_ID_partner = i.SU_ID_partner
                AND
                    d.SU_ID_with = i.SU_ID_with
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
    DELETE tie
    FROM
        [dbo].[SU_partner_SU_with] tie
    JOIN
        deleted d
    ON
        d.SU_partner_SU_with_ChangedAt = tie.SU_partner_SU_with_ChangedAt
    AND
       (
            d.SU_ID_partner = tie.SU_ID_partner
        AND
            d.SU_ID_with = tie.SU_ID_with
       );
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
   N'<schema format="0.101.3" date="2026-10-09" time="12:00:00">
<metadata changingRange="datetime2" encapsulation="dbo" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="true" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime2" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="decimal(5,2)" reliabilitySuffix="Reliability" defaultReliability="1" deleteReliability="0" assertionSuffix="Assertion" partitioning="false" entityIntegrity="true" restatability="true" idempotency="false" assertiveness="true" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="false" decisiveness="true" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="uni" deletability="false" deletablePrefix="Deletable" deletionSuffix="Deleted" privacy="Ignore" checksum="false" triggers="true" knotAliases="false" naturalKeyAttributes="false" />
<description>
A model for testing the triggers of the latest views: an attribute for each combination of the settings that the
triggers read (restatable, idempotent, assertive, deletable, checksum, knotted, static or historized), ties with and
without identifiers, and a nexus with an attribute. The scripts in sqlserver-tests/ run against its output.
</description>
<knot mnemonic="GRD" descriptor="Grade" identity="tinyint" dataRange="nvarchar(42)">
<metadata capsule="dbo" generator="false" />
<layout x="58.53" y="368.61" fixed="false" />
<description>
A grade, used by knotted attributes and by the value roles of ties.
</description>
</knot>
<anchor mnemonic="SU" descriptor="Subject" identity="int">
<metadata capsule="dbo" generator="true" />
<attribute mnemonic="NAM" descriptor="Name" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" idempotent="false" deletable="false" />
<layout x="72.74" y="235.30" fixed="false" />
<description>
Static.
</description>
</attribute>
<attribute mnemonic="COD" descriptor="Code" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" idempotent="true" deletable="false" />
<layout x="19.64" y="36.89" fixed="false" />
<description>
Static and idempotent.
</description>
</attribute>
<attribute mnemonic="GRD" descriptor="Grade" knotRange="GRD">
<metadata privacy="Ignore" capsule="dbo" idempotent="false" deletable="false" />
<layout x="58.15" y="151.52" fixed="false" />
<description>
Static and knotted.
</description>
</attribute>
<attribute mnemonic="NOT" descriptor="Note" dataRange="nvarchar(max)">
<metadata privacy="Ignore" capsule="dbo" checksum="true" idempotent="false" deletable="false" />
<layout x="566.15" y="428.65" fixed="false" />
<description>
Static, with a checksum.
</description>
</attribute>
<attribute mnemonic="TTL" descriptor="Title" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" restatable="true" idempotent="false" deletable="false" />
<layout x="252.30" y="87.59" fixed="false" />
<description>
Historized, restatable.
</description>
</attribute>
<attribute mnemonic="STA" descriptor="State" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" restatable="false" idempotent="false" deletable="false" />
<layout x="40.33" y="25.12" fixed="false" />
<description>
Historized, not restatable: a restatement is an error.
</description>
</attribute>
<attribute mnemonic="LBL" descriptor="Label" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" restatable="false" idempotent="true" deletable="false" />
<layout x="424.94" y="293.65" fixed="false" />
<description>
Historized, not restatable and idempotent: a restatement is skipped.
</description>
</attribute>
<attribute mnemonic="TAG" descriptor="Tag" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" restatable="true" idempotent="true" deletable="false" />
<layout x="75.31" y="70.48" fixed="false" />
<description>
Historized, restatable and idempotent: a restatement is skipped.
</description>
</attribute>
<attribute mnemonic="LVL" descriptor="Level" timeRange="datetime2" knotRange="GRD">
<metadata privacy="Ignore" capsule="dbo" restatable="true" idempotent="false" deletable="false" />
<layout x="431.81" y="61.06" fixed="false" />
<description>
Historized and knotted.
</description>
</attribute>
<attribute mnemonic="TXT" descriptor="Text" timeRange="datetime2" dataRange="nvarchar(max)">
<metadata privacy="Ignore" capsule="dbo" checksum="true" restatable="true" idempotent="false" deletable="false" />
<layout x="1.43" y="217.46" fixed="false" />
<description>
Historized, with a checksum.
</description>
</attribute>
<attribute mnemonic="ASR" descriptor="Assessment" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" restatable="true" idempotent="false" deletable="false" />
<layout x="618.86" y="182.18" fixed="false" />
<description>
Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).
</description>
</attribute>
<attribute mnemonic="ERS" descriptor="Erasable" timeRange="datetime2" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" restatable="true" idempotent="false" deletable="true" />
<layout x="289.13" y="107.76" fixed="false" />
<description>
Historized and deletable (uni-temporal).
</description>
</attribute>
<layout x="110.95" y="239.57" fixed="false" />
<description>
The subject of the tests.
</description>
</anchor>
<anchor mnemonic="OB" descriptor="Object" identity="int">
<metadata capsule="dbo" generator="true" />
<attribute mnemonic="NAM" descriptor="Name" dataRange="nvarchar(42)">
<metadata privacy="Ignore" capsule="dbo" idempotent="false" deletable="false" />
<layout x="656.91" y="128.11" fixed="false" />
<description>
Static.
</description>
</attribute>
<layout x="21.26" y="41.99" fixed="false" />
<description>
Something the subject has or keeps.
</description>
</anchor>
<nexus mnemonic="EV" descriptor="Event" identity="int">
<metadata capsule="dbo" generator="true" />
<attribute mnemonic="QTY" descriptor="Quantity" dataRange="int">
<metadata privacy="Ignore" capsule="dbo" idempotent="false" deletable="false" />
<layout x="298.39" y="426.06" fixed="false" />
<description>
Static, as the attributes of a nexus are.
</description>
</attribute>
<role role="for" type="SU" identifier="false">
<description>
The subject the event is for.
</description>
</role>
<layout x="218.57" y="16.32" fixed="false" />
<description>
An event, with an attribute of its own.
</description>
</nexus>
<tie timeRange="datetime2">
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
<metadata capsule="dbo" restatable="true" deletable="false" idempotent="false" />
<layout x="518.13" y="357.47" fixed="false" />
<description>
Historized, with identifiers and a knotted value role, restatable.
</description>
</tie>
<tie timeRange="datetime2">
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
<metadata capsule="dbo" restatable="false" deletable="false" idempotent="true" />
<layout x="173.57" y="373.07" fixed="false" />
<description>
Historized, with identifiers and a knotted value role, idempotent and not assertive.
</description>
</tie>
<tie>
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
<metadata capsule="dbo" deletable="false" idempotent="false" />
<layout x="265.74" y="245.55" fixed="false" />
<description>
Static, with an identifier and a value role: each object has one owner.
</description>
</tie>
<tie timeRange="datetime2">
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
<metadata capsule="dbo" restatable="true" deletable="false" idempotent="false" />
<layout x="582.03" y="181.97" fixed="false" />
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
-- The attribute view shows information about all the attributes in a schema
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
   Nodeset.attribute.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as ParentNodeset(anchor)
OUTER APPLY
   ParentNodeset.anchor.nodes('attribute') as Nodeset(attribute);
GO
-- Tie view -----------------------------------------------------------------------------------------------------------
-- The tie view shows information about all the ties in a schema
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
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"]
      return concat($role/@type, "_", $role/@role)
   ').value('.', 'nvarchar(max)'), ' ', '_') as [name],
   Nodeset.tie.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.tie.value('count(anchorRole) + count(knotRole)', 'int') as [numberOfRoles],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"]
      return string($role/@role)
   ').value('.', 'nvarchar(max)') as [roles],
   Nodeset.tie.value('count(anchorRole)', 'int') as [numberOfAnchors],
   Nodeset.tie.query('
      for $role in anchorRole
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [anchors],
   Nodeset.tie.value('count(knotRole)', 'int') as [numberOfKnots],
   Nodeset.tie.query('
      for $role in knotRole
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [knots],
   Nodeset.tie.value('count(*[local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"])', 'int') as [numberOfIdentifiers],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"]
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [identifiers],
   Nodeset.tie.value('@timeRange', 'nvarchar(max)') as [timeRange],
   Nodeset.tie.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.tie.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   Nodeset.tie.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.tie.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   Nodeset.tie.value('description[1]/.', 'nvarchar(max)') as [description]
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
   case [parent]
      when 'tie'
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
            for $role in ../../*[local-name() = "anchorRole" or local-name() = "knotRole"]
            return concat($role/@type, "_", $role/@role)
          ').value('.', 'nvarchar(max)'), ' ', '_')
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
      VALUES ('uni', ''), ('crt', '')
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
      VALUES ('uni', ''), ('crt', '')
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
      VALUES ('uni', ''), ('crt', '_Annex'), ('crt', '_Posit')
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
      VALUES ('uni', ''), ('crt', '_Annex'), ('crt', '_Posit')
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
	-- build attribute copy
	if (@temporalization = 'crt')
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
	if (@temporalization = 'crt')
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
				3 as prio,
				'Metadata' + mnemonic as metadataColumn
			from
				[dbo]._Anchor
			where
				[version] = @schemaVersion
			union all
			select
				name,
				4 as prio,
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
				select [schema].query('//tie[anchorRole[@type = sql:variable("@current")]]')
				from [dbo]._Schema
				where version = @version
			) t (ties)
		);
		select 
			@visited as Visited,
			Tie.value('../anchorRole[@type = sql:variable("@current")][1]/@role', 'varchar(42)') as CurrentRole,
			@current as CurrentMnemonic,
			cast(null as int) as Occurrences,
			replace(Tie.query('
				for $tie in ..
				return <name> {
					for $role in ($tie/anchorRole, $tie/knotRole)
					return concat($role/@type, "_", $role/@role)
				} </name>
			').value('name[1]', 'varchar(555)'), ' ', '_') as Tie,
			Tie.value('@role', 'varchar(42)') as AnchorRole,
			Tie.value('@type', 'char(2)') as AnchorMnemonic, 
			row_number() over (order by (select 1)) as VisitingOrder
		into #walk
		from @ties.nodes('tie/anchorRole[@type != sql:variable("@current")]') AS t (Tie)
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
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with identifiers and a knotted value role, restatable.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'SU_ID_holder';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'SU_ID_holder';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'OB_ID_item';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'OB_ID_item';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'GRD_ID_grade';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A grade, used by knotted attributes and by the value roles of ties.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'GRD_ID_grade';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with identifiers and a knotted value role, idempotent and not assertive.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'SU_ID_keeper';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'SU_ID_keeper';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'OB_ID_thing';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'OB_ID_thing';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'GRD_ID_rank';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A grade, used by knotted attributes and by the value roles of ties.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'GRD_ID_rank';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static, with an identifier and a value role: each object has one owner.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner',
@level2type = N'Column', @level2name = 'OB_ID_part';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner',
@level2type = N'Column', @level2name = 'OB_ID_part';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner',
@level2type = N'Column', @level2name = 'SU_ID_owner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner',
@level2type = N'Column', @level2name = 'SU_ID_owner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, without identifiers.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with',
@level2type = N'Column', @level2name = 'SU_ID_partner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with',
@level2type = N'Column', @level2name = 'SU_ID_partner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with',
@level2type = N'Column', @level2name = 'SU_ID_with';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with',
@level2type = N'Column', @level2name = 'SU_ID_with';
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
An event, with an attribute of its own.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_QTY_Event_Quantity';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static, as the attributes of a nexus are.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_QTY_Event_Quantity';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NAM_Subject_Name';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NAM_Subject_Name';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_COD_Subject_Code';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static and idempotent.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_COD_Subject_Code';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_GRD_Subject_Grade';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static and knotted.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_GRD_Subject_Grade';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NOT_Subject_Note';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static, with a checksum.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NOT_Subject_Note';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TTL_Subject_Title';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, restatable.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TTL_Subject_Title';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_STA_Subject_State';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not restatable: a restatement is an error.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_STA_Subject_State';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LBL_Subject_Label';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not restatable and idempotent: a restatement is skipped.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LBL_Subject_Label';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TAG_Subject_Tag';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, restatable and idempotent: a restatement is skipped.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TAG_Subject_Tag';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LVL_Subject_Level';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized and knotted.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LVL_Subject_Level';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TXT_Subject_Text';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with a checksum.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TXT_Subject_Text';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ASR_Subject_Assessment';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ASR_Subject_Assessment';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ERS_Subject_Erasable';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized and deletable (uni-temporal).
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ERS_Subject_Erasable';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_NAM_Object_Name';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_NAM_Object_Name';
GO
