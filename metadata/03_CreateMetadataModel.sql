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
IF Object_Id('metadata.MD5') IS NULL
BEGIN
    IF(@version >= 2016)
    BEGIN
        EXEC('
        CREATE FUNCTION metadata.MD5(@binaryData AS varbinary(max))
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
        CREATE FUNCTION metadata.MD5(@binaryData AS varbinary(max))
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
-- COT_ContainerType table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.COT_ContainerType', 'U') IS NULL
CREATE TABLE [metadata].[COT_ContainerType] (
    COT_ID tinyint not null,
    COT_ContainerType varchar(42) not null,
    constraint pkCOT_ContainerType primary key (
        COT_ID asc
    ),
    constraint uqCOT_ContainerType unique (
        COT_ContainerType
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- EST_ExecutionStatus table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.EST_ExecutionStatus', 'U') IS NULL
CREATE TABLE [metadata].[EST_ExecutionStatus] (
    EST_ID tinyint not null,
    EST_ExecutionStatus varchar(42) not null,
    constraint pkEST_ExecutionStatus primary key (
        EST_ID asc
    ),
    constraint uqEST_ExecutionStatus unique (
        EST_ExecutionStatus
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- CFT_ConfigurationType table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CFT_ConfigurationType', 'U') IS NULL
CREATE TABLE [metadata].[CFT_ConfigurationType] (
    CFT_ID tinyint not null,
    CFT_ConfigurationType varchar(42) not null,
    constraint pkCFT_ConfigurationType primary key (
        CFT_ID asc
    ),
    constraint uqCFT_ConfigurationType unique (
        CFT_ConfigurationType
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- WON_WorkName table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WON_WorkName', 'U') IS NULL
CREATE TABLE [metadata].[WON_WorkName] (
    WON_ID int IDENTITY(1,1) not null,
    WON_WorkName varchar(255) not null,
    constraint pkWON_WorkName primary key (
        WON_ID asc
    ),
    constraint uqWON_WorkName unique (
        WON_WorkName
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- WIU_WorkInvocationUser table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WIU_WorkInvocationUser', 'U') IS NULL
CREATE TABLE [metadata].[WIU_WorkInvocationUser] (
    WIU_ID smallint IDENTITY(1,1) not null,
    WIU_WorkInvocationUser varchar(555) not null,
    constraint pkWIU_WorkInvocationUser primary key (
        WIU_ID asc
    ),
    constraint uqWIU_WorkInvocationUser unique (
        WIU_WorkInvocationUser
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- WIR_WorkInvocationRole table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WIR_WorkInvocationRole', 'U') IS NULL
CREATE TABLE [metadata].[WIR_WorkInvocationRole] (
    WIR_ID smallint IDENTITY(1,1) not null,
    WIR_WorkInvocationRole varchar(42) not null,
    constraint pkWIR_WorkInvocationRole primary key (
        WIR_ID asc
    ),
    constraint uqWIR_WorkInvocationRole unique (
        WIR_WorkInvocationRole
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- JON_JobName table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JON_JobName', 'U') IS NULL
CREATE TABLE [metadata].[JON_JobName] (
    JON_ID int IDENTITY(1,1) not null,
    JON_JobName varchar(255) not null,
    constraint pkJON_JobName primary key (
        JON_ID asc
    ),
    constraint uqJON_JobName unique (
        JON_JobName
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- AID_AgentJobId table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.AID_AgentJobId', 'U') IS NULL
CREATE TABLE [metadata].[AID_AgentJobId] (
    AID_ID int IDENTITY(1,1) not null,
    AID_AgentJobId uniqueidentifier not null,
    constraint pkAID_AgentJobId primary key (
        AID_ID asc
    ),
    constraint uqAID_AgentJobId unique (
        AID_AgentJobId
    )
);
GO
-- ANCHORS AND ATTRIBUTES ---------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
-- Attributes are used to store values for properties of entities.
-- Attributes are mutable, their values may change over one or more types of time.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
-- Anchors may have zero or more adjoined attributes.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- JB_Job table (with 5 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_Job', 'U') IS NULL
CREATE TABLE [metadata].[JB_Job] (
    JB_ID int IDENTITY(1,1) not null,
    JB_Dummy bit null,
    constraint pkJB_Job primary key (
        JB_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- JB_STA_Job_Start table (on JB_Job)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_STA_Job_Start', 'U') IS NULL
CREATE TABLE [metadata].[JB_STA_Job_Start] (
    JB_STA_JB_ID int not null,
    JB_STA_Job_Start datetime2(7) not null,
    constraint fkJB_STA_Job_Start foreign key (
        JB_STA_JB_ID
    ) references [metadata].[JB_Job](JB_ID),
    constraint pkJB_STA_Job_Start primary key (
        JB_STA_JB_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- JB_END_Job_End table (on JB_Job)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_END_Job_End', 'U') IS NULL
CREATE TABLE [metadata].[JB_END_Job_End] (
    JB_END_JB_ID int not null,
    JB_END_Job_End datetime2(7) not null,
    constraint fkJB_END_Job_End foreign key (
        JB_END_JB_ID
    ) references [metadata].[JB_Job](JB_ID),
    constraint pkJB_END_Job_End primary key (
        JB_END_JB_ID asc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- JB_NAM_Job_Name table (on JB_Job)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_NAM_Job_Name', 'U') IS NULL
CREATE TABLE [metadata].[JB_NAM_Job_Name] (
    JB_NAM_JB_ID int not null,
    JB_NAM_JON_ID int not null,
    constraint fk_A_JB_NAM_Job_Name foreign key (
        JB_NAM_JB_ID
    ) references [metadata].[JB_Job](JB_ID),
    constraint fk_K_JB_NAM_Job_Name foreign key (
        JB_NAM_JON_ID
    ) references [metadata].[JON_JobName](JON_ID),
    constraint pkJB_NAM_Job_Name primary key (
        JB_NAM_JB_ID asc
    )
);
GO
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- JB_EST_Job_ExecutionStatus table (on JB_Job)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_EST_Job_ExecutionStatus', 'U') IS NULL
CREATE TABLE [metadata].[JB_EST_Job_ExecutionStatus] (
    JB_EST_JB_ID int not null,
    JB_EST_EST_ID tinyint not null,
    JB_EST_ChangedAt datetime2(7) not null,
    constraint fk_A_JB_EST_Job_ExecutionStatus foreign key (
        JB_EST_JB_ID
    ) references [metadata].[JB_Job](JB_ID),
    constraint fk_K_JB_EST_Job_ExecutionStatus foreign key (
        JB_EST_EST_ID
    ) references [metadata].[EST_ExecutionStatus](EST_ID),
    constraint pkJB_EST_Job_ExecutionStatus primary key (
        JB_EST_JB_ID asc,
        JB_EST_ChangedAt desc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- JB_AID_Job_AgentJobId table (on JB_Job)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_AID_Job_AgentJobId', 'U') IS NULL
CREATE TABLE [metadata].[JB_AID_Job_AgentJobId] (
    JB_AID_JB_ID int not null,
    JB_AID_AID_ID int not null,
    constraint fk_A_JB_AID_Job_AgentJobId foreign key (
        JB_AID_JB_ID
    ) references [metadata].[JB_Job](JB_ID),
    constraint fk_K_JB_AID_Job_AgentJobId foreign key (
        JB_AID_AID_ID
    ) references [metadata].[AID_AgentJobId](AID_ID),
    constraint pkJB_AID_Job_AgentJobId primary key (
        JB_AID_JB_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- CO_Container table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_Container', 'U') IS NULL
CREATE TABLE [metadata].[CO_Container] (
    CO_ID int IDENTITY(1,1) not null,
    CO_Dummy bit null,
    constraint pkCO_Container primary key (
        CO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- CO_NAM_Container_Name table (on CO_Container)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_NAM_Container_Name', 'U') IS NULL
CREATE TABLE [metadata].[CO_NAM_Container_Name] (
    CO_NAM_CO_ID int not null,
    CO_NAM_Container_Name varchar(2000) not null,
    constraint fkCO_NAM_Container_Name foreign key (
        CO_NAM_CO_ID
    ) references [metadata].[CO_Container](CO_ID),
    constraint pkCO_NAM_Container_Name primary key (
        CO_NAM_CO_ID asc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- CO_TYP_Container_Type table (on CO_Container)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_TYP_Container_Type', 'U') IS NULL
CREATE TABLE [metadata].[CO_TYP_Container_Type] (
    CO_TYP_CO_ID int not null,
    CO_TYP_COT_ID tinyint not null,
    constraint fk_A_CO_TYP_Container_Type foreign key (
        CO_TYP_CO_ID
    ) references [metadata].[CO_Container](CO_ID),
    constraint fk_K_CO_TYP_Container_Type foreign key (
        CO_TYP_COT_ID
    ) references [metadata].[COT_ContainerType](COT_ID),
    constraint pkCO_TYP_Container_Type primary key (
        CO_TYP_CO_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- CO_DSC_Container_Discovered table (on CO_Container)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_DSC_Container_Discovered', 'U') IS NULL
CREATE TABLE [metadata].[CO_DSC_Container_Discovered] (
    CO_DSC_CO_ID int not null,
    CO_DSC_Container_Discovered datetime not null,
    CO_DSC_ChangedAt datetime2(7) not null,
    constraint fkCO_DSC_Container_Discovered foreign key (
        CO_DSC_CO_ID
    ) references [metadata].[CO_Container](CO_ID),
    constraint pkCO_DSC_Container_Discovered primary key (
        CO_DSC_CO_ID asc,
        CO_DSC_ChangedAt desc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- CO_CRE_Container_Created table (on CO_Container)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_CRE_Container_Created', 'U') IS NULL
CREATE TABLE [metadata].[CO_CRE_Container_Created] (
    CO_CRE_CO_ID int not null,
    CO_CRE_Container_Created datetime not null,
    constraint fkCO_CRE_Container_Created foreign key (
        CO_CRE_CO_ID
    ) references [metadata].[CO_Container](CO_ID),
    constraint pkCO_CRE_Container_Created primary key (
        CO_CRE_CO_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- WO_Work table (with 9 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_Work', 'U') IS NULL
CREATE TABLE [metadata].[WO_Work] (
    WO_ID int IDENTITY(1,1) not null,
    WO_Dummy bit null,
    constraint pkWO_Work primary key (
        WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_STA_Work_Start table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_STA_Work_Start', 'U') IS NULL
CREATE TABLE [metadata].[WO_STA_Work_Start] (
    WO_STA_WO_ID int not null,
    WO_STA_Work_Start datetime2(7) not null,
    constraint fkWO_STA_Work_Start foreign key (
        WO_STA_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_STA_Work_Start primary key (
        WO_STA_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_END_Work_End table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_END_Work_End', 'U') IS NULL
CREATE TABLE [metadata].[WO_END_Work_End] (
    WO_END_WO_ID int not null,
    WO_END_Work_End datetime2(7) not null,
    constraint fkWO_END_Work_End foreign key (
        WO_END_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_END_Work_End primary key (
        WO_END_WO_ID asc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- WO_NAM_Work_Name table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_NAM_Work_Name', 'U') IS NULL
CREATE TABLE [metadata].[WO_NAM_Work_Name] (
    WO_NAM_WO_ID int not null,
    WO_NAM_WON_ID int not null,
    constraint fk_A_WO_NAM_Work_Name foreign key (
        WO_NAM_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint fk_K_WO_NAM_Work_Name foreign key (
        WO_NAM_WON_ID
    ) references [metadata].[WON_WorkName](WON_ID),
    constraint pkWO_NAM_Work_Name primary key (
        WO_NAM_WO_ID asc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- WO_USR_Work_InvocationUser table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_USR_Work_InvocationUser', 'U') IS NULL
CREATE TABLE [metadata].[WO_USR_Work_InvocationUser] (
    WO_USR_WO_ID int not null,
    WO_USR_WIU_ID smallint not null,
    constraint fk_A_WO_USR_Work_InvocationUser foreign key (
        WO_USR_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint fk_K_WO_USR_Work_InvocationUser foreign key (
        WO_USR_WIU_ID
    ) references [metadata].[WIU_WorkInvocationUser](WIU_ID),
    constraint pkWO_USR_Work_InvocationUser primary key (
        WO_USR_WO_ID asc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- WO_ROL_Work_InvocationRole table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_ROL_Work_InvocationRole', 'U') IS NULL
CREATE TABLE [metadata].[WO_ROL_Work_InvocationRole] (
    WO_ROL_WO_ID int not null,
    WO_ROL_WIR_ID smallint not null,
    constraint fk_A_WO_ROL_Work_InvocationRole foreign key (
        WO_ROL_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint fk_K_WO_ROL_Work_InvocationRole foreign key (
        WO_ROL_WIR_ID
    ) references [metadata].[WIR_WorkInvocationRole](WIR_ID),
    constraint pkWO_ROL_Work_InvocationRole primary key (
        WO_ROL_WO_ID asc
    )
);
GO
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- WO_EST_Work_ExecutionStatus table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_EST_Work_ExecutionStatus', 'U') IS NULL
CREATE TABLE [metadata].[WO_EST_Work_ExecutionStatus] (
    WO_EST_WO_ID int not null,
    WO_EST_EST_ID tinyint not null,
    WO_EST_ChangedAt datetime2(7) not null,
    constraint fk_A_WO_EST_Work_ExecutionStatus foreign key (
        WO_EST_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint fk_K_WO_EST_Work_ExecutionStatus foreign key (
        WO_EST_EST_ID
    ) references [metadata].[EST_ExecutionStatus](EST_ID),
    constraint pkWO_EST_Work_ExecutionStatus primary key (
        WO_EST_WO_ID asc,
        WO_EST_ChangedAt desc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_ERL_Work_ErrorLine table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_ERL_Work_ErrorLine', 'U') IS NULL
CREATE TABLE [metadata].[WO_ERL_Work_ErrorLine] (
    WO_ERL_WO_ID int not null,
    WO_ERL_Work_ErrorLine int not null,
    constraint fkWO_ERL_Work_ErrorLine foreign key (
        WO_ERL_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_ERL_Work_ErrorLine primary key (
        WO_ERL_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_ERM_Work_ErrorMessage table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_ERM_Work_ErrorMessage', 'U') IS NULL
CREATE TABLE [metadata].[WO_ERM_Work_ErrorMessage] (
    WO_ERM_WO_ID int not null,
    WO_ERM_Work_ErrorMessage varchar(555) not null,
    constraint fkWO_ERM_Work_ErrorMessage foreign key (
        WO_ERM_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_ERM_Work_ErrorMessage primary key (
        WO_ERM_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_AID_Work_AgentStepId table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_AID_Work_AgentStepId', 'U') IS NULL
CREATE TABLE [metadata].[WO_AID_Work_AgentStepId] (
    WO_AID_WO_ID int not null,
    WO_AID_Work_AgentStepId smallint not null,
    constraint fkWO_AID_Work_AgentStepId foreign key (
        WO_AID_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_AID_Work_AgentStepId primary key (
        WO_AID_WO_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- CF_Configuration table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CF_Configuration', 'U') IS NULL
CREATE TABLE [metadata].[CF_Configuration] (
    CF_ID int IDENTITY(1,1) not null,
    CF_Dummy bit null,
    constraint pkCF_Configuration primary key (
        CF_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- CF_NAM_Configuration_Name table (on CF_Configuration)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CF_NAM_Configuration_Name', 'U') IS NULL
CREATE TABLE [metadata].[CF_NAM_Configuration_Name] (
    CF_NAM_CF_ID int not null,
    CF_NAM_Configuration_Name varchar(255) not null,
    constraint fkCF_NAM_Configuration_Name foreign key (
        CF_NAM_CF_ID
    ) references [metadata].[CF_Configuration](CF_ID),
    constraint pkCF_NAM_Configuration_Name primary key (
        CF_NAM_CF_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- CF_XML_Configuration_XMLDefinition table (on CF_Configuration)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CF_XML_Configuration_XMLDefinition', 'U') IS NULL
CREATE TABLE [metadata].[CF_XML_Configuration_XMLDefinition] (
    CF_XML_CF_ID int not null,
    CF_XML_Configuration_XMLDefinition xml not null,
    CF_XML_Checksum as cast(metadata.MD5(cast(CF_XML_Configuration_XMLDefinition as varbinary(max))) as varbinary(16)) persisted,
    CF_XML_ChangedAt datetime not null,
    constraint fkCF_XML_Configuration_XMLDefinition foreign key (
        CF_XML_CF_ID
    ) references [metadata].[CF_Configuration](CF_ID),
    constraint pkCF_XML_Configuration_XMLDefinition primary key (
        CF_XML_CF_ID asc,
        CF_XML_ChangedAt desc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- CF_TYP_Configuration_Type table (on CF_Configuration)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CF_TYP_Configuration_Type', 'U') IS NULL
CREATE TABLE [metadata].[CF_TYP_Configuration_Type] (
    CF_TYP_CF_ID int not null,
    CF_TYP_CFT_ID tinyint not null,
    constraint fk_A_CF_TYP_Configuration_Type foreign key (
        CF_TYP_CF_ID
    ) references [metadata].[CF_Configuration](CF_ID),
    constraint fk_K_CF_TYP_Configuration_Type foreign key (
        CF_TYP_CFT_ID
    ) references [metadata].[CFT_ConfigurationType](CFT_ID),
    constraint pkCF_TYP_Configuration_Type primary key (
        CF_TYP_CF_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- OP_Operations table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.OP_Operations', 'U') IS NULL
CREATE TABLE [metadata].[OP_Operations] (
    OP_ID int IDENTITY(1,1) not null,
    OP_Dummy bit null,
    constraint pkOP_Operations primary key (
        OP_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- OP_INS_Operations_Inserts table (on OP_Operations)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.OP_INS_Operations_Inserts', 'U') IS NULL
CREATE TABLE [metadata].[OP_INS_Operations_Inserts] (
    OP_INS_OP_ID int not null,
    OP_INS_Operations_Inserts int not null,
    OP_INS_ChangedAt datetime2(7) not null,
    constraint fkOP_INS_Operations_Inserts foreign key (
        OP_INS_OP_ID
    ) references [metadata].[OP_Operations](OP_ID),
    constraint pkOP_INS_Operations_Inserts primary key (
        OP_INS_OP_ID asc,
        OP_INS_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- OP_UPD_Operations_Updates table (on OP_Operations)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.OP_UPD_Operations_Updates', 'U') IS NULL
CREATE TABLE [metadata].[OP_UPD_Operations_Updates] (
    OP_UPD_OP_ID int not null,
    OP_UPD_Operations_Updates int not null,
    OP_UPD_ChangedAt datetime2(7) not null,
    constraint fkOP_UPD_Operations_Updates foreign key (
        OP_UPD_OP_ID
    ) references [metadata].[OP_Operations](OP_ID),
    constraint pkOP_UPD_Operations_Updates primary key (
        OP_UPD_OP_ID asc,
        OP_UPD_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- OP_DEL_Operations_Deletes table (on OP_Operations)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.OP_DEL_Operations_Deletes', 'U') IS NULL
CREATE TABLE [metadata].[OP_DEL_Operations_Deletes] (
    OP_DEL_OP_ID int not null,
    OP_DEL_Operations_Deletes int not null,
    OP_DEL_ChangedAt datetime2(7) not null,
    constraint fkOP_DEL_Operations_Deletes foreign key (
        OP_DEL_OP_ID
    ) references [metadata].[OP_Operations](OP_ID),
    constraint pkOP_DEL_Operations_Deletes primary key (
        OP_DEL_OP_ID asc,
        OP_DEL_ChangedAt desc
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
-- Static tie table ---------------------------------------------------------------------------------------------------
-- WO_part_JB_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_part_JB_of', 'U') IS NULL
CREATE TABLE [metadata].[WO_part_JB_of] (
    WO_ID_part int not null, 
    JB_ID_of int not null, 
    constraint WO_part_JB_of_fkWO_part foreign key (
        WO_ID_part
    ) references [metadata].[WO_Work](WO_ID), 
    constraint WO_part_JB_of_fkJB_of foreign key (
        JB_ID_of
    ) references [metadata].[JB_Job](JB_ID), 
    constraint pkWO_part_JB_of primary key (
        WO_ID_part asc,
        JB_ID_of asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- JB_formed_CF_from table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_formed_CF_from', 'U') IS NULL
CREATE TABLE [metadata].[JB_formed_CF_from] (
    JB_ID_formed int not null, 
    CF_ID_from int not null, 
    constraint JB_formed_CF_from_fkJB_formed foreign key (
        JB_ID_formed
    ) references [metadata].[JB_Job](JB_ID), 
    constraint JB_formed_CF_from_fkCF_from foreign key (
        CF_ID_from
    ) references [metadata].[CF_Configuration](CF_ID), 
    constraint pkJB_formed_CF_from primary key (
        JB_ID_formed asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- WO_operates_CO_source_CO_target_OP_with table (having 4 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_operates_CO_source_CO_target_OP_with', 'U') IS NULL
CREATE TABLE [metadata].[WO_operates_CO_source_CO_target_OP_with] (
    WO_ID_operates int not null, 
    CO_ID_source int not null, 
    CO_ID_target int not null, 
    OP_ID_with int not null, 
    constraint WO_operates_CO_source_CO_target_OP_with_fkWO_operates foreign key (
        WO_ID_operates
    ) references [metadata].[WO_Work](WO_ID), 
    constraint WO_operates_CO_source_CO_target_OP_with_fkCO_source foreign key (
        CO_ID_source
    ) references [metadata].[CO_Container](CO_ID), 
    constraint WO_operates_CO_source_CO_target_OP_with_fkCO_target foreign key (
        CO_ID_target
    ) references [metadata].[CO_Container](CO_ID), 
    constraint WO_operates_CO_source_CO_target_OP_with_fkOP_with foreign key (
        OP_ID_with
    ) references [metadata].[OP_Operations](OP_ID), 
    constraint pkWO_operates_CO_source_CO_target_OP_with primary key (
        WO_ID_operates asc,
        CO_ID_source asc,
        CO_ID_target asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- WO_formed_CF_from table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_formed_CF_from', 'U') IS NULL
CREATE TABLE [metadata].[WO_formed_CF_from] (
    WO_ID_formed int not null, 
    CF_ID_from int not null, 
    constraint WO_formed_CF_from_fkWO_formed foreign key (
        WO_ID_formed
    ) references [metadata].[WO_Work](WO_ID), 
    constraint WO_formed_CF_from_fkCF_from foreign key (
        CF_ID_from
    ) references [metadata].[CF_Configuration](CF_ID), 
    constraint pkWO_formed_CF_from primary key (
        WO_ID_formed asc
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
-- rt_JB_EST_Job_ExecutionStatus (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rt_JB_EST_Job_ExecutionStatus', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[rt_JB_EST_Job_ExecutionStatus];
GO
CREATE TRIGGER [metadata].[rt_JB_EST_Job_ExecutionStatus] ON [metadata].[JB_EST_Job_ExecutionStatus]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @JB_EST_Job_ExecutionStatus TABLE (
        JB_EST_JB_ID int not null,
        JB_EST_ChangedAt datetime2(7) not null,
        JB_EST_EST_ID tinyint not null, 
        primary key(
            JB_EST_JB_ID asc, 
            JB_EST_ChangedAt desc
        )
    );
    INSERT INTO @JB_EST_Job_ExecutionStatus (
        JB_EST_JB_ID,
        JB_EST_ChangedAt,
        JB_EST_EST_ID
    )
    SELECT
        JB_EST_JB_ID,
        JB_EST_ChangedAt,
        JB_EST_EST_ID
    FROM 
        inserted;
    INSERT INTO @JB_EST_Job_ExecutionStatus (
        JB_EST_JB_ID,
        JB_EST_ChangedAt,
        JB_EST_EST_ID
    )
    SELECT
        p.JB_EST_JB_ID,
        p.JB_EST_ChangedAt,
        p.JB_EST_EST_ID
    FROM (
        SELECT DISTINCT 
            JB_EST_JB_ID 
        FROM 
            @JB_EST_Job_ExecutionStatus
    ) i 
    JOIN
        [metadata].[JB_EST_Job_ExecutionStatus] p
    ON 
        p.JB_EST_JB_ID = i.JB_EST_JB_ID
    WHERE NOT EXISTS (
        SELECT 
            x.JB_EST_JB_ID
        FROM
            @JB_EST_Job_ExecutionStatus x
        WHERE
            x.JB_EST_JB_ID = p.JB_EST_JB_ID
        AND
            x.JB_EST_ChangedAt = p.JB_EST_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @JB_EST_Job_ExecutionStatus i
        CROSS APPLY (
            SELECT TOP 1
                h.JB_EST_JB_ID,
                h.JB_EST_ChangedAt,
                h.JB_EST_EST_ID
            FROM 
                @JB_EST_Job_ExecutionStatus h
            WHERE
                h.JB_EST_JB_ID = i.JB_EST_JB_ID
            AND
                h.JB_EST_ChangedAt < i.JB_EST_ChangedAt
            ORDER BY 
                h.JB_EST_ChangedAt DESC
        ) pre
        WHERE
            i.JB_EST_EST_ID = pre.JB_EST_EST_ID
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in JB_EST_Job_ExecutionStatus for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_CO_DSC_Container_Discovered (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rt_CO_DSC_Container_Discovered', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[rt_CO_DSC_Container_Discovered];
GO
CREATE TRIGGER [metadata].[rt_CO_DSC_Container_Discovered] ON [metadata].[CO_DSC_Container_Discovered]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @CO_DSC_Container_Discovered TABLE (
        CO_DSC_CO_ID int not null,
        CO_DSC_ChangedAt datetime2(7) not null,
        CO_DSC_Container_Discovered datetime not null,
        primary key(
            CO_DSC_CO_ID asc, 
            CO_DSC_ChangedAt desc
        )
    );
    INSERT INTO @CO_DSC_Container_Discovered (
        CO_DSC_CO_ID,
        CO_DSC_ChangedAt,
        CO_DSC_Container_Discovered
    )
    SELECT
        CO_DSC_CO_ID,
        CO_DSC_ChangedAt,
        CO_DSC_Container_Discovered
    FROM 
        inserted;
    INSERT INTO @CO_DSC_Container_Discovered (
        CO_DSC_CO_ID,
        CO_DSC_ChangedAt,
        CO_DSC_Container_Discovered
    )
    SELECT
        p.CO_DSC_CO_ID,
        p.CO_DSC_ChangedAt,
        p.CO_DSC_Container_Discovered
    FROM (
        SELECT DISTINCT 
            CO_DSC_CO_ID 
        FROM 
            @CO_DSC_Container_Discovered
    ) i 
    JOIN
        [metadata].[CO_DSC_Container_Discovered] p
    ON 
        p.CO_DSC_CO_ID = i.CO_DSC_CO_ID
    WHERE NOT EXISTS (
        SELECT 
            x.CO_DSC_CO_ID
        FROM
            @CO_DSC_Container_Discovered x
        WHERE
            x.CO_DSC_CO_ID = p.CO_DSC_CO_ID
        AND
            x.CO_DSC_ChangedAt = p.CO_DSC_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @CO_DSC_Container_Discovered i
        CROSS APPLY (
            SELECT TOP 1
                h.CO_DSC_CO_ID,
                h.CO_DSC_ChangedAt,
                h.CO_DSC_Container_Discovered
            FROM 
                @CO_DSC_Container_Discovered h
            WHERE
                h.CO_DSC_CO_ID = i.CO_DSC_CO_ID
            AND
                h.CO_DSC_ChangedAt < i.CO_DSC_ChangedAt
            ORDER BY 
                h.CO_DSC_ChangedAt DESC
        ) pre
        WHERE
            i.CO_DSC_Container_Discovered = pre.CO_DSC_Container_Discovered
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in CO_DSC_Container_Discovered for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_WO_EST_Work_ExecutionStatus (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rt_WO_EST_Work_ExecutionStatus', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[rt_WO_EST_Work_ExecutionStatus];
GO
CREATE TRIGGER [metadata].[rt_WO_EST_Work_ExecutionStatus] ON [metadata].[WO_EST_Work_ExecutionStatus]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @WO_EST_Work_ExecutionStatus TABLE (
        WO_EST_WO_ID int not null,
        WO_EST_ChangedAt datetime2(7) not null,
        WO_EST_EST_ID tinyint not null, 
        primary key(
            WO_EST_WO_ID asc, 
            WO_EST_ChangedAt desc
        )
    );
    INSERT INTO @WO_EST_Work_ExecutionStatus (
        WO_EST_WO_ID,
        WO_EST_ChangedAt,
        WO_EST_EST_ID
    )
    SELECT
        WO_EST_WO_ID,
        WO_EST_ChangedAt,
        WO_EST_EST_ID
    FROM 
        inserted;
    INSERT INTO @WO_EST_Work_ExecutionStatus (
        WO_EST_WO_ID,
        WO_EST_ChangedAt,
        WO_EST_EST_ID
    )
    SELECT
        p.WO_EST_WO_ID,
        p.WO_EST_ChangedAt,
        p.WO_EST_EST_ID
    FROM (
        SELECT DISTINCT 
            WO_EST_WO_ID 
        FROM 
            @WO_EST_Work_ExecutionStatus
    ) i 
    JOIN
        [metadata].[WO_EST_Work_ExecutionStatus] p
    ON 
        p.WO_EST_WO_ID = i.WO_EST_WO_ID
    WHERE NOT EXISTS (
        SELECT 
            x.WO_EST_WO_ID
        FROM
            @WO_EST_Work_ExecutionStatus x
        WHERE
            x.WO_EST_WO_ID = p.WO_EST_WO_ID
        AND
            x.WO_EST_ChangedAt = p.WO_EST_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @WO_EST_Work_ExecutionStatus i
        CROSS APPLY (
            SELECT TOP 1
                h.WO_EST_WO_ID,
                h.WO_EST_ChangedAt,
                h.WO_EST_EST_ID
            FROM 
                @WO_EST_Work_ExecutionStatus h
            WHERE
                h.WO_EST_WO_ID = i.WO_EST_WO_ID
            AND
                h.WO_EST_ChangedAt < i.WO_EST_ChangedAt
            ORDER BY 
                h.WO_EST_ChangedAt DESC
        ) pre
        WHERE
            i.WO_EST_EST_ID = pre.WO_EST_EST_ID
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in WO_EST_Work_ExecutionStatus for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_CF_XML_Configuration_XMLDefinition (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rt_CF_XML_Configuration_XMLDefinition', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[rt_CF_XML_Configuration_XMLDefinition];
GO
CREATE TRIGGER [metadata].[rt_CF_XML_Configuration_XMLDefinition] ON [metadata].[CF_XML_Configuration_XMLDefinition]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @CF_XML_Configuration_XMLDefinition TABLE (
        CF_XML_CF_ID int not null,
        CF_XML_ChangedAt datetime not null,
        CF_XML_Configuration_XMLDefinition xml not null,
        CF_XML_Checksum varbinary(16) not null,
        primary key(
            CF_XML_CF_ID asc, 
            CF_XML_ChangedAt desc
        )
    );
    INSERT INTO @CF_XML_Configuration_XMLDefinition (
        CF_XML_CF_ID,
        CF_XML_ChangedAt,
        CF_XML_Checksum, 
        CF_XML_Configuration_XMLDefinition
    )
    SELECT
        CF_XML_CF_ID,
        CF_XML_ChangedAt,
        CF_XML_Checksum, 
        CF_XML_Configuration_XMLDefinition
    FROM 
        inserted;
    INSERT INTO @CF_XML_Configuration_XMLDefinition (
        CF_XML_CF_ID,
        CF_XML_ChangedAt,
        CF_XML_Checksum, 
        CF_XML_Configuration_XMLDefinition
    )
    SELECT
        p.CF_XML_CF_ID,
        p.CF_XML_ChangedAt,
        p.CF_XML_Checksum, 
        p.CF_XML_Configuration_XMLDefinition
    FROM (
        SELECT DISTINCT 
            CF_XML_CF_ID 
        FROM 
            @CF_XML_Configuration_XMLDefinition
    ) i 
    JOIN
        [metadata].[CF_XML_Configuration_XMLDefinition] p
    ON 
        p.CF_XML_CF_ID = i.CF_XML_CF_ID
    WHERE NOT EXISTS (
        SELECT 
            x.CF_XML_CF_ID
        FROM
            @CF_XML_Configuration_XMLDefinition x
        WHERE
            x.CF_XML_CF_ID = p.CF_XML_CF_ID
        AND
            x.CF_XML_ChangedAt = p.CF_XML_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @CF_XML_Configuration_XMLDefinition i
        CROSS APPLY (
            SELECT TOP 1
                h.CF_XML_CF_ID,
                h.CF_XML_ChangedAt,
                h.CF_XML_Checksum 
            FROM 
                @CF_XML_Configuration_XMLDefinition h
            WHERE
                h.CF_XML_CF_ID = i.CF_XML_CF_ID
            AND
                h.CF_XML_ChangedAt < i.CF_XML_ChangedAt
            ORDER BY 
                h.CF_XML_ChangedAt DESC
        ) pre
        WHERE
            i.CF_XML_Checksum = pre.CF_XML_Checksum 
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in CF_XML_Configuration_XMLDefinition for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_OP_INS_Operations_Inserts (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rt_OP_INS_Operations_Inserts', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[rt_OP_INS_Operations_Inserts];
GO
CREATE TRIGGER [metadata].[rt_OP_INS_Operations_Inserts] ON [metadata].[OP_INS_Operations_Inserts]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @OP_INS_Operations_Inserts TABLE (
        OP_INS_OP_ID int not null,
        OP_INS_ChangedAt datetime2(7) not null,
        OP_INS_Operations_Inserts int not null,
        primary key(
            OP_INS_OP_ID asc, 
            OP_INS_ChangedAt desc
        )
    );
    INSERT INTO @OP_INS_Operations_Inserts (
        OP_INS_OP_ID,
        OP_INS_ChangedAt,
        OP_INS_Operations_Inserts
    )
    SELECT
        OP_INS_OP_ID,
        OP_INS_ChangedAt,
        OP_INS_Operations_Inserts
    FROM 
        inserted;
    INSERT INTO @OP_INS_Operations_Inserts (
        OP_INS_OP_ID,
        OP_INS_ChangedAt,
        OP_INS_Operations_Inserts
    )
    SELECT
        p.OP_INS_OP_ID,
        p.OP_INS_ChangedAt,
        p.OP_INS_Operations_Inserts
    FROM (
        SELECT DISTINCT 
            OP_INS_OP_ID 
        FROM 
            @OP_INS_Operations_Inserts
    ) i 
    JOIN
        [metadata].[OP_INS_Operations_Inserts] p
    ON 
        p.OP_INS_OP_ID = i.OP_INS_OP_ID
    WHERE NOT EXISTS (
        SELECT 
            x.OP_INS_OP_ID
        FROM
            @OP_INS_Operations_Inserts x
        WHERE
            x.OP_INS_OP_ID = p.OP_INS_OP_ID
        AND
            x.OP_INS_ChangedAt = p.OP_INS_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @OP_INS_Operations_Inserts i
        CROSS APPLY (
            SELECT TOP 1
                h.OP_INS_OP_ID,
                h.OP_INS_ChangedAt,
                h.OP_INS_Operations_Inserts
            FROM 
                @OP_INS_Operations_Inserts h
            WHERE
                h.OP_INS_OP_ID = i.OP_INS_OP_ID
            AND
                h.OP_INS_ChangedAt < i.OP_INS_ChangedAt
            ORDER BY 
                h.OP_INS_ChangedAt DESC
        ) pre
        WHERE
            i.OP_INS_Operations_Inserts = pre.OP_INS_Operations_Inserts
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in OP_INS_Operations_Inserts for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_OP_UPD_Operations_Updates (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rt_OP_UPD_Operations_Updates', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[rt_OP_UPD_Operations_Updates];
GO
CREATE TRIGGER [metadata].[rt_OP_UPD_Operations_Updates] ON [metadata].[OP_UPD_Operations_Updates]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @OP_UPD_Operations_Updates TABLE (
        OP_UPD_OP_ID int not null,
        OP_UPD_ChangedAt datetime2(7) not null,
        OP_UPD_Operations_Updates int not null,
        primary key(
            OP_UPD_OP_ID asc, 
            OP_UPD_ChangedAt desc
        )
    );
    INSERT INTO @OP_UPD_Operations_Updates (
        OP_UPD_OP_ID,
        OP_UPD_ChangedAt,
        OP_UPD_Operations_Updates
    )
    SELECT
        OP_UPD_OP_ID,
        OP_UPD_ChangedAt,
        OP_UPD_Operations_Updates
    FROM 
        inserted;
    INSERT INTO @OP_UPD_Operations_Updates (
        OP_UPD_OP_ID,
        OP_UPD_ChangedAt,
        OP_UPD_Operations_Updates
    )
    SELECT
        p.OP_UPD_OP_ID,
        p.OP_UPD_ChangedAt,
        p.OP_UPD_Operations_Updates
    FROM (
        SELECT DISTINCT 
            OP_UPD_OP_ID 
        FROM 
            @OP_UPD_Operations_Updates
    ) i 
    JOIN
        [metadata].[OP_UPD_Operations_Updates] p
    ON 
        p.OP_UPD_OP_ID = i.OP_UPD_OP_ID
    WHERE NOT EXISTS (
        SELECT 
            x.OP_UPD_OP_ID
        FROM
            @OP_UPD_Operations_Updates x
        WHERE
            x.OP_UPD_OP_ID = p.OP_UPD_OP_ID
        AND
            x.OP_UPD_ChangedAt = p.OP_UPD_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @OP_UPD_Operations_Updates i
        CROSS APPLY (
            SELECT TOP 1
                h.OP_UPD_OP_ID,
                h.OP_UPD_ChangedAt,
                h.OP_UPD_Operations_Updates
            FROM 
                @OP_UPD_Operations_Updates h
            WHERE
                h.OP_UPD_OP_ID = i.OP_UPD_OP_ID
            AND
                h.OP_UPD_ChangedAt < i.OP_UPD_ChangedAt
            ORDER BY 
                h.OP_UPD_ChangedAt DESC
        ) pre
        WHERE
            i.OP_UPD_Operations_Updates = pre.OP_UPD_Operations_Updates
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in OP_UPD_Operations_Updates for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_OP_DEL_Operations_Deletes (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rt_OP_DEL_Operations_Deletes', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[rt_OP_DEL_Operations_Deletes];
GO
CREATE TRIGGER [metadata].[rt_OP_DEL_Operations_Deletes] ON [metadata].[OP_DEL_Operations_Deletes]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @OP_DEL_Operations_Deletes TABLE (
        OP_DEL_OP_ID int not null,
        OP_DEL_ChangedAt datetime2(7) not null,
        OP_DEL_Operations_Deletes int not null,
        primary key(
            OP_DEL_OP_ID asc, 
            OP_DEL_ChangedAt desc
        )
    );
    INSERT INTO @OP_DEL_Operations_Deletes (
        OP_DEL_OP_ID,
        OP_DEL_ChangedAt,
        OP_DEL_Operations_Deletes
    )
    SELECT
        OP_DEL_OP_ID,
        OP_DEL_ChangedAt,
        OP_DEL_Operations_Deletes
    FROM 
        inserted;
    INSERT INTO @OP_DEL_Operations_Deletes (
        OP_DEL_OP_ID,
        OP_DEL_ChangedAt,
        OP_DEL_Operations_Deletes
    )
    SELECT
        p.OP_DEL_OP_ID,
        p.OP_DEL_ChangedAt,
        p.OP_DEL_Operations_Deletes
    FROM (
        SELECT DISTINCT 
            OP_DEL_OP_ID 
        FROM 
            @OP_DEL_Operations_Deletes
    ) i 
    JOIN
        [metadata].[OP_DEL_Operations_Deletes] p
    ON 
        p.OP_DEL_OP_ID = i.OP_DEL_OP_ID
    WHERE NOT EXISTS (
        SELECT 
            x.OP_DEL_OP_ID
        FROM
            @OP_DEL_Operations_Deletes x
        WHERE
            x.OP_DEL_OP_ID = p.OP_DEL_OP_ID
        AND
            x.OP_DEL_ChangedAt = p.OP_DEL_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @OP_DEL_Operations_Deletes i
        CROSS APPLY (
            SELECT TOP 1
                h.OP_DEL_OP_ID,
                h.OP_DEL_ChangedAt,
                h.OP_DEL_Operations_Deletes
            FROM 
                @OP_DEL_Operations_Deletes h
            WHERE
                h.OP_DEL_OP_ID = i.OP_DEL_OP_ID
            AND
                h.OP_DEL_ChangedAt < i.OP_DEL_ChangedAt
            ORDER BY 
                h.OP_DEL_ChangedAt DESC
        ) pre
        WHERE
            i.OP_DEL_Operations_Deletes = pre.OP_DEL_Operations_Deletes
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in OP_DEL_Operations_Deletes for: ' + @message;
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
-- kJB_Job identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kJB_Job', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kJB_Job] (
        @requestedNumberOfIdentities bigint
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
            INSERT INTO [metadata].[JB_Job] (
                JB_Dummy
            )
            OUTPUT
                inserted.JB_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kCO_Container identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kCO_Container', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kCO_Container] (
        @requestedNumberOfIdentities bigint
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
            INSERT INTO [metadata].[CO_Container] (
                CO_Dummy
            )
            OUTPUT
                inserted.CO_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kWO_Work identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kWO_Work', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kWO_Work] (
        @requestedNumberOfIdentities bigint
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
            INSERT INTO [metadata].[WO_Work] (
                WO_Dummy
            )
            OUTPUT
                inserted.WO_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kCF_Configuration identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kCF_Configuration', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kCF_Configuration] (
        @requestedNumberOfIdentities bigint
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
            INSERT INTO [metadata].[CF_Configuration] (
                CF_Dummy
            )
            OUTPUT
                inserted.CF_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kOP_Operations identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kOP_Operations', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kOP_Operations] (
        @requestedNumberOfIdentities bigint
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
            INSERT INTO [metadata].[OP_Operations] (
                OP_Dummy
            )
            OUTPUT
                inserted.OP_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
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
-- rJB_EST_Job_ExecutionStatus rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rJB_EST_Job_ExecutionStatus','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rJB_EST_Job_ExecutionStatus] (
        @changingTimepoint datetime2(7)
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        JB_EST_JB_ID,
        JB_EST_EST_ID,
        JB_EST_ChangedAt
    FROM
        [metadata].[JB_EST_Job_ExecutionStatus]
    WHERE
        JB_EST_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rCO_DSC_Container_Discovered rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rCO_DSC_Container_Discovered','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rCO_DSC_Container_Discovered] (
        @changingTimepoint datetime2(7)
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        CO_DSC_CO_ID,
        CO_DSC_Container_Discovered,
        CO_DSC_ChangedAt
    FROM
        [metadata].[CO_DSC_Container_Discovered]
    WHERE
        CO_DSC_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rWO_EST_Work_ExecutionStatus rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rWO_EST_Work_ExecutionStatus','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rWO_EST_Work_ExecutionStatus] (
        @changingTimepoint datetime2(7)
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        WO_EST_WO_ID,
        WO_EST_EST_ID,
        WO_EST_ChangedAt
    FROM
        [metadata].[WO_EST_Work_ExecutionStatus]
    WHERE
        WO_EST_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rCF_XML_Configuration_XMLDefinition rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rCF_XML_Configuration_XMLDefinition','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rCF_XML_Configuration_XMLDefinition] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        CF_XML_CF_ID,
        CF_XML_Checksum,
        CF_XML_Configuration_XMLDefinition,
        CF_XML_ChangedAt
    FROM
        [metadata].[CF_XML_Configuration_XMLDefinition]
    WHERE
        CF_XML_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rOP_INS_Operations_Inserts rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rOP_INS_Operations_Inserts','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rOP_INS_Operations_Inserts] (
        @changingTimepoint datetime2(7)
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        OP_INS_OP_ID,
        OP_INS_Operations_Inserts,
        OP_INS_ChangedAt
    FROM
        [metadata].[OP_INS_Operations_Inserts]
    WHERE
        OP_INS_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rOP_UPD_Operations_Updates rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rOP_UPD_Operations_Updates','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rOP_UPD_Operations_Updates] (
        @changingTimepoint datetime2(7)
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        OP_UPD_OP_ID,
        OP_UPD_Operations_Updates,
        OP_UPD_ChangedAt
    FROM
        [metadata].[OP_UPD_Operations_Updates]
    WHERE
        OP_UPD_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rOP_DEL_Operations_Deletes rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rOP_DEL_Operations_Deletes','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rOP_DEL_Operations_Deletes] (
        @changingTimepoint datetime2(7)
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        OP_DEL_OP_ID,
        OP_DEL_Operations_Deletes,
        OP_DEL_ChangedAt
    FROM
        [metadata].[OP_DEL_Operations_Deletes]
    WHERE
        OP_DEL_ChangedAt <= @changingTimepoint;
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
IF Object_ID('metadata.dJB_Job', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dJB_Job];
IF Object_ID('metadata.nJB_Job', 'V') IS NOT NULL
DROP VIEW [metadata].[nJB_Job];
IF Object_ID('metadata.pJB_Job', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pJB_Job];
IF Object_ID('metadata.lJB_Job', 'V') IS NOT NULL
DROP VIEW [metadata].[lJB_Job];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lJB_Job viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lJB_Job] WITH SCHEMABINDING AS
SELECT
    [JB].JB_ID,
    [STA].JB_STA_JB_ID,
    [STA].JB_STA_Job_Start,
    [END].JB_END_JB_ID,
    [END].JB_END_Job_End,
    [NAM].JB_NAM_JB_ID,
    [kNAM].JON_JobName AS JB_NAM_JON_JobName,
    [NAM].JB_NAM_JON_ID,
    [EST].JB_EST_JB_ID,
    [EST].JB_EST_ChangedAt,
    [kEST].EST_ExecutionStatus AS JB_EST_EST_ExecutionStatus,
    [EST].JB_EST_EST_ID,
    [AID].JB_AID_JB_ID,
    [kAID].AID_AgentJobId AS JB_AID_AID_AgentJobId,
    [AID].JB_AID_AID_ID
FROM
    [metadata].[JB_Job] [JB]
LEFT JOIN
    [metadata].[JB_STA_Job_Start] [STA]
ON
    [STA].JB_STA_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[JB_END_Job_End] [END]
ON
    [END].JB_END_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[JB_NAM_Job_Name] [NAM]
ON
    [NAM].JB_NAM_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[JON_JobName] [kNAM]
ON
    [kNAM].JON_ID = [NAM].JB_NAM_JON_ID
LEFT JOIN
    [metadata].[JB_EST_Job_ExecutionStatus] [EST]
ON
    [EST].JB_EST_JB_ID = [JB].JB_ID
AND
    [EST].JB_EST_ChangedAt = (
        SELECT
            max(sub.JB_EST_ChangedAt)
        FROM
            [metadata].[JB_EST_Job_ExecutionStatus] sub
        WHERE
            sub.JB_EST_JB_ID = [JB].JB_ID
   )
LEFT JOIN
    [metadata].[EST_ExecutionStatus] [kEST]
ON
    [kEST].EST_ID = [EST].JB_EST_EST_ID
LEFT JOIN
    [metadata].[JB_AID_Job_AgentJobId] [AID]
ON
    [AID].JB_AID_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[AID_AgentJobId] [kAID]
ON
    [kAID].AID_ID = [AID].JB_AID_AID_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pJB_Job viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pJB_Job] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [JB].JB_ID,
    [STA].JB_STA_JB_ID,
    [STA].JB_STA_Job_Start,
    [END].JB_END_JB_ID,
    [END].JB_END_Job_End,
    [NAM].JB_NAM_JB_ID,
    [kNAM].JON_JobName AS JB_NAM_JON_JobName,
    [NAM].JB_NAM_JON_ID,
    [EST].JB_EST_JB_ID,
    [EST].JB_EST_ChangedAt,
    [kEST].EST_ExecutionStatus AS JB_EST_EST_ExecutionStatus,
    [EST].JB_EST_EST_ID,
    [AID].JB_AID_JB_ID,
    [kAID].AID_AgentJobId AS JB_AID_AID_AgentJobId,
    [AID].JB_AID_AID_ID
FROM
    [metadata].[JB_Job] [JB]
LEFT JOIN
    [metadata].[JB_STA_Job_Start] [STA]
ON
    [STA].JB_STA_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[JB_END_Job_End] [END]
ON
    [END].JB_END_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[JB_NAM_Job_Name] [NAM]
ON
    [NAM].JB_NAM_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[JON_JobName] [kNAM]
ON
    [kNAM].JON_ID = [NAM].JB_NAM_JON_ID
LEFT JOIN
    [metadata].[rJB_EST_Job_ExecutionStatus](@changingTimepoint) [EST]
ON
    [EST].JB_EST_JB_ID = [JB].JB_ID
AND
    [EST].JB_EST_ChangedAt = (
        SELECT
            max(sub.JB_EST_ChangedAt)
        FROM
            [metadata].[rJB_EST_Job_ExecutionStatus](@changingTimepoint) sub
        WHERE
            sub.JB_EST_JB_ID = [JB].JB_ID
   )
LEFT JOIN
    [metadata].[EST_ExecutionStatus] [kEST]
ON
    [kEST].EST_ID = [EST].JB_EST_EST_ID
LEFT JOIN
    [metadata].[JB_AID_Job_AgentJobId] [AID]
ON
    [AID].JB_AID_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[AID_AgentJobId] [kAID]
ON
    [kAID].AID_ID = [AID].JB_AID_AID_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nJB_Job viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nJB_Job]
AS
SELECT
    *
FROM
    [metadata].[pJB_Job](sysutcdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dJB_Job showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[dJB_Job] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pJB].*
FROM (
    SELECT DISTINCT
        JB_EST_JB_ID AS JB_ID,
        JB_EST_ChangedAt AS inspectedTimepoint,
        'EST' AS mnemonic
    FROM
        [metadata].[JB_EST_Job_ExecutionStatus]
    WHERE
        (@selection is null OR @selection like '%EST%')
    AND
        JB_EST_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [metadata].[pJB_Job](timepoints.inspectedTimepoint) [pJB]
WHERE
    [pJB].JB_ID = timepoints.JB_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dCO_Container', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dCO_Container];
IF Object_ID('metadata.nCO_Container', 'V') IS NOT NULL
DROP VIEW [metadata].[nCO_Container];
IF Object_ID('metadata.pCO_Container', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pCO_Container];
IF Object_ID('metadata.lCO_Container', 'V') IS NOT NULL
DROP VIEW [metadata].[lCO_Container];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lCO_Container viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lCO_Container] WITH SCHEMABINDING AS
SELECT
    [CO].CO_ID,
    [NAM].CO_NAM_CO_ID,
    [NAM].CO_NAM_Container_Name,
    [TYP].CO_TYP_CO_ID,
    [kTYP].COT_ContainerType AS CO_TYP_COT_ContainerType,
    [TYP].CO_TYP_COT_ID,
    [DSC].CO_DSC_CO_ID,
    [DSC].CO_DSC_ChangedAt,
    [DSC].CO_DSC_Container_Discovered,
    [CRE].CO_CRE_CO_ID,
    [CRE].CO_CRE_Container_Created
FROM
    [metadata].[CO_Container] [CO]
LEFT JOIN
    [metadata].[CO_NAM_Container_Name] [NAM]
ON
    [NAM].CO_NAM_CO_ID = [CO].CO_ID
LEFT JOIN
    [metadata].[CO_TYP_Container_Type] [TYP]
ON
    [TYP].CO_TYP_CO_ID = [CO].CO_ID
LEFT JOIN
    [metadata].[COT_ContainerType] [kTYP]
ON
    [kTYP].COT_ID = [TYP].CO_TYP_COT_ID
LEFT JOIN
    [metadata].[CO_DSC_Container_Discovered] [DSC]
ON
    [DSC].CO_DSC_CO_ID = [CO].CO_ID
AND
    [DSC].CO_DSC_ChangedAt = (
        SELECT
            max(sub.CO_DSC_ChangedAt)
        FROM
            [metadata].[CO_DSC_Container_Discovered] sub
        WHERE
            sub.CO_DSC_CO_ID = [CO].CO_ID
   )
LEFT JOIN
    [metadata].[CO_CRE_Container_Created] [CRE]
ON
    [CRE].CO_CRE_CO_ID = [CO].CO_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pCO_Container viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pCO_Container] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [CO].CO_ID,
    [NAM].CO_NAM_CO_ID,
    [NAM].CO_NAM_Container_Name,
    [TYP].CO_TYP_CO_ID,
    [kTYP].COT_ContainerType AS CO_TYP_COT_ContainerType,
    [TYP].CO_TYP_COT_ID,
    [DSC].CO_DSC_CO_ID,
    [DSC].CO_DSC_ChangedAt,
    [DSC].CO_DSC_Container_Discovered,
    [CRE].CO_CRE_CO_ID,
    [CRE].CO_CRE_Container_Created
FROM
    [metadata].[CO_Container] [CO]
LEFT JOIN
    [metadata].[CO_NAM_Container_Name] [NAM]
ON
    [NAM].CO_NAM_CO_ID = [CO].CO_ID
LEFT JOIN
    [metadata].[CO_TYP_Container_Type] [TYP]
ON
    [TYP].CO_TYP_CO_ID = [CO].CO_ID
LEFT JOIN
    [metadata].[COT_ContainerType] [kTYP]
ON
    [kTYP].COT_ID = [TYP].CO_TYP_COT_ID
LEFT JOIN
    [metadata].[rCO_DSC_Container_Discovered](@changingTimepoint) [DSC]
ON
    [DSC].CO_DSC_CO_ID = [CO].CO_ID
AND
    [DSC].CO_DSC_ChangedAt = (
        SELECT
            max(sub.CO_DSC_ChangedAt)
        FROM
            [metadata].[rCO_DSC_Container_Discovered](@changingTimepoint) sub
        WHERE
            sub.CO_DSC_CO_ID = [CO].CO_ID
   )
LEFT JOIN
    [metadata].[CO_CRE_Container_Created] [CRE]
ON
    [CRE].CO_CRE_CO_ID = [CO].CO_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nCO_Container viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nCO_Container]
AS
SELECT
    *
FROM
    [metadata].[pCO_Container](sysutcdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dCO_Container showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[dCO_Container] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pCO].*
FROM (
    SELECT DISTINCT
        CO_DSC_CO_ID AS CO_ID,
        CO_DSC_ChangedAt AS inspectedTimepoint,
        'DSC' AS mnemonic
    FROM
        [metadata].[CO_DSC_Container_Discovered]
    WHERE
        (@selection is null OR @selection like '%DSC%')
    AND
        CO_DSC_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [metadata].[pCO_Container](timepoints.inspectedTimepoint) [pCO]
WHERE
    [pCO].CO_ID = timepoints.CO_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dWO_Work', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dWO_Work];
IF Object_ID('metadata.nWO_Work', 'V') IS NOT NULL
DROP VIEW [metadata].[nWO_Work];
IF Object_ID('metadata.pWO_Work', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pWO_Work];
IF Object_ID('metadata.lWO_Work', 'V') IS NOT NULL
DROP VIEW [metadata].[lWO_Work];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lWO_Work viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lWO_Work] WITH SCHEMABINDING AS
SELECT
    [WO].WO_ID,
    [STA].WO_STA_WO_ID,
    [STA].WO_STA_Work_Start,
    [END].WO_END_WO_ID,
    [END].WO_END_Work_End,
    [NAM].WO_NAM_WO_ID,
    [kNAM].WON_WorkName AS WO_NAM_WON_WorkName,
    [NAM].WO_NAM_WON_ID,
    [USR].WO_USR_WO_ID,
    [kUSR].WIU_WorkInvocationUser AS WO_USR_WIU_WorkInvocationUser,
    [USR].WO_USR_WIU_ID,
    [ROL].WO_ROL_WO_ID,
    [kROL].WIR_WorkInvocationRole AS WO_ROL_WIR_WorkInvocationRole,
    [ROL].WO_ROL_WIR_ID,
    [EST].WO_EST_WO_ID,
    [EST].WO_EST_ChangedAt,
    [kEST].EST_ExecutionStatus AS WO_EST_EST_ExecutionStatus,
    [EST].WO_EST_EST_ID,
    [ERL].WO_ERL_WO_ID,
    [ERL].WO_ERL_Work_ErrorLine,
    [ERM].WO_ERM_WO_ID,
    [ERM].WO_ERM_Work_ErrorMessage,
    [AID].WO_AID_WO_ID,
    [AID].WO_AID_Work_AgentStepId
FROM
    [metadata].[WO_Work] [WO]
LEFT JOIN
    [metadata].[WO_STA_Work_Start] [STA]
ON
    [STA].WO_STA_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_END_Work_End] [END]
ON
    [END].WO_END_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_NAM_Work_Name] [NAM]
ON
    [NAM].WO_NAM_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WON_WorkName] [kNAM]
ON
    [kNAM].WON_ID = [NAM].WO_NAM_WON_ID
LEFT JOIN
    [metadata].[WO_USR_Work_InvocationUser] [USR]
ON
    [USR].WO_USR_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WIU_WorkInvocationUser] [kUSR]
ON
    [kUSR].WIU_ID = [USR].WO_USR_WIU_ID
LEFT JOIN
    [metadata].[WO_ROL_Work_InvocationRole] [ROL]
ON
    [ROL].WO_ROL_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WIR_WorkInvocationRole] [kROL]
ON
    [kROL].WIR_ID = [ROL].WO_ROL_WIR_ID
LEFT JOIN
    [metadata].[WO_EST_Work_ExecutionStatus] [EST]
ON
    [EST].WO_EST_WO_ID = [WO].WO_ID
AND
    [EST].WO_EST_ChangedAt = (
        SELECT
            max(sub.WO_EST_ChangedAt)
        FROM
            [metadata].[WO_EST_Work_ExecutionStatus] sub
        WHERE
            sub.WO_EST_WO_ID = [WO].WO_ID
   )
LEFT JOIN
    [metadata].[EST_ExecutionStatus] [kEST]
ON
    [kEST].EST_ID = [EST].WO_EST_EST_ID
LEFT JOIN
    [metadata].[WO_ERL_Work_ErrorLine] [ERL]
ON
    [ERL].WO_ERL_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_ERM_Work_ErrorMessage] [ERM]
ON
    [ERM].WO_ERM_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_AID_Work_AgentStepId] [AID]
ON
    [AID].WO_AID_WO_ID = [WO].WO_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pWO_Work viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pWO_Work] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [WO].WO_ID,
    [STA].WO_STA_WO_ID,
    [STA].WO_STA_Work_Start,
    [END].WO_END_WO_ID,
    [END].WO_END_Work_End,
    [NAM].WO_NAM_WO_ID,
    [kNAM].WON_WorkName AS WO_NAM_WON_WorkName,
    [NAM].WO_NAM_WON_ID,
    [USR].WO_USR_WO_ID,
    [kUSR].WIU_WorkInvocationUser AS WO_USR_WIU_WorkInvocationUser,
    [USR].WO_USR_WIU_ID,
    [ROL].WO_ROL_WO_ID,
    [kROL].WIR_WorkInvocationRole AS WO_ROL_WIR_WorkInvocationRole,
    [ROL].WO_ROL_WIR_ID,
    [EST].WO_EST_WO_ID,
    [EST].WO_EST_ChangedAt,
    [kEST].EST_ExecutionStatus AS WO_EST_EST_ExecutionStatus,
    [EST].WO_EST_EST_ID,
    [ERL].WO_ERL_WO_ID,
    [ERL].WO_ERL_Work_ErrorLine,
    [ERM].WO_ERM_WO_ID,
    [ERM].WO_ERM_Work_ErrorMessage,
    [AID].WO_AID_WO_ID,
    [AID].WO_AID_Work_AgentStepId
FROM
    [metadata].[WO_Work] [WO]
LEFT JOIN
    [metadata].[WO_STA_Work_Start] [STA]
ON
    [STA].WO_STA_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_END_Work_End] [END]
ON
    [END].WO_END_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_NAM_Work_Name] [NAM]
ON
    [NAM].WO_NAM_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WON_WorkName] [kNAM]
ON
    [kNAM].WON_ID = [NAM].WO_NAM_WON_ID
LEFT JOIN
    [metadata].[WO_USR_Work_InvocationUser] [USR]
ON
    [USR].WO_USR_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WIU_WorkInvocationUser] [kUSR]
ON
    [kUSR].WIU_ID = [USR].WO_USR_WIU_ID
LEFT JOIN
    [metadata].[WO_ROL_Work_InvocationRole] [ROL]
ON
    [ROL].WO_ROL_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WIR_WorkInvocationRole] [kROL]
ON
    [kROL].WIR_ID = [ROL].WO_ROL_WIR_ID
LEFT JOIN
    [metadata].[rWO_EST_Work_ExecutionStatus](@changingTimepoint) [EST]
ON
    [EST].WO_EST_WO_ID = [WO].WO_ID
AND
    [EST].WO_EST_ChangedAt = (
        SELECT
            max(sub.WO_EST_ChangedAt)
        FROM
            [metadata].[rWO_EST_Work_ExecutionStatus](@changingTimepoint) sub
        WHERE
            sub.WO_EST_WO_ID = [WO].WO_ID
   )
LEFT JOIN
    [metadata].[EST_ExecutionStatus] [kEST]
ON
    [kEST].EST_ID = [EST].WO_EST_EST_ID
LEFT JOIN
    [metadata].[WO_ERL_Work_ErrorLine] [ERL]
ON
    [ERL].WO_ERL_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_ERM_Work_ErrorMessage] [ERM]
ON
    [ERM].WO_ERM_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_AID_Work_AgentStepId] [AID]
ON
    [AID].WO_AID_WO_ID = [WO].WO_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nWO_Work viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nWO_Work]
AS
SELECT
    *
FROM
    [metadata].[pWO_Work](sysutcdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dWO_Work showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[dWO_Work] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pWO].*
FROM (
    SELECT DISTINCT
        WO_EST_WO_ID AS WO_ID,
        WO_EST_ChangedAt AS inspectedTimepoint,
        'EST' AS mnemonic
    FROM
        [metadata].[WO_EST_Work_ExecutionStatus]
    WHERE
        (@selection is null OR @selection like '%EST%')
    AND
        WO_EST_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [metadata].[pWO_Work](timepoints.inspectedTimepoint) [pWO]
WHERE
    [pWO].WO_ID = timepoints.WO_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dCF_Configuration', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dCF_Configuration];
IF Object_ID('metadata.nCF_Configuration', 'V') IS NOT NULL
DROP VIEW [metadata].[nCF_Configuration];
IF Object_ID('metadata.pCF_Configuration', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pCF_Configuration];
IF Object_ID('metadata.lCF_Configuration', 'V') IS NOT NULL
DROP VIEW [metadata].[lCF_Configuration];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lCF_Configuration viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lCF_Configuration] WITH SCHEMABINDING AS
SELECT
    [CF].CF_ID,
    [NAM].CF_NAM_CF_ID,
    [NAM].CF_NAM_Configuration_Name,
    [XML].CF_XML_CF_ID,
    [XML].CF_XML_ChangedAt,
    [XML].CF_XML_Checksum,
    [XML].CF_XML_Configuration_XMLDefinition,
    [TYP].CF_TYP_CF_ID,
    [kTYP].CFT_ConfigurationType AS CF_TYP_CFT_ConfigurationType,
    [TYP].CF_TYP_CFT_ID
FROM
    [metadata].[CF_Configuration] [CF]
LEFT JOIN
    [metadata].[CF_NAM_Configuration_Name] [NAM]
ON
    [NAM].CF_NAM_CF_ID = [CF].CF_ID
LEFT JOIN
    [metadata].[CF_XML_Configuration_XMLDefinition] [XML]
ON
    [XML].CF_XML_CF_ID = [CF].CF_ID
AND
    [XML].CF_XML_ChangedAt = (
        SELECT
            max(sub.CF_XML_ChangedAt)
        FROM
            [metadata].[CF_XML_Configuration_XMLDefinition] sub
        WHERE
            sub.CF_XML_CF_ID = [CF].CF_ID
   )
LEFT JOIN
    [metadata].[CF_TYP_Configuration_Type] [TYP]
ON
    [TYP].CF_TYP_CF_ID = [CF].CF_ID
LEFT JOIN
    [metadata].[CFT_ConfigurationType] [kTYP]
ON
    [kTYP].CFT_ID = [TYP].CF_TYP_CFT_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pCF_Configuration viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pCF_Configuration] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [CF].CF_ID,
    [NAM].CF_NAM_CF_ID,
    [NAM].CF_NAM_Configuration_Name,
    [XML].CF_XML_CF_ID,
    [XML].CF_XML_ChangedAt,
    [XML].CF_XML_Checksum,
    [XML].CF_XML_Configuration_XMLDefinition,
    [TYP].CF_TYP_CF_ID,
    [kTYP].CFT_ConfigurationType AS CF_TYP_CFT_ConfigurationType,
    [TYP].CF_TYP_CFT_ID
FROM
    [metadata].[CF_Configuration] [CF]
LEFT JOIN
    [metadata].[CF_NAM_Configuration_Name] [NAM]
ON
    [NAM].CF_NAM_CF_ID = [CF].CF_ID
LEFT JOIN
    [metadata].[rCF_XML_Configuration_XMLDefinition](@changingTimepoint) [XML]
ON
    [XML].CF_XML_CF_ID = [CF].CF_ID
AND
    [XML].CF_XML_ChangedAt = (
        SELECT
            max(sub.CF_XML_ChangedAt)
        FROM
            [metadata].[rCF_XML_Configuration_XMLDefinition](@changingTimepoint) sub
        WHERE
            sub.CF_XML_CF_ID = [CF].CF_ID
   )
LEFT JOIN
    [metadata].[CF_TYP_Configuration_Type] [TYP]
ON
    [TYP].CF_TYP_CF_ID = [CF].CF_ID
LEFT JOIN
    [metadata].[CFT_ConfigurationType] [kTYP]
ON
    [kTYP].CFT_ID = [TYP].CF_TYP_CFT_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nCF_Configuration viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nCF_Configuration]
AS
SELECT
    *
FROM
    [metadata].[pCF_Configuration](sysutcdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dCF_Configuration showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[dCF_Configuration] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pCF].*
FROM (
    SELECT DISTINCT
        CF_XML_CF_ID AS CF_ID,
        CF_XML_ChangedAt AS inspectedTimepoint,
        'XML' AS mnemonic
    FROM
        [metadata].[CF_XML_Configuration_XMLDefinition]
    WHERE
        (@selection is null OR @selection like '%XML%')
    AND
        CF_XML_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [metadata].[pCF_Configuration](timepoints.inspectedTimepoint) [pCF]
WHERE
    [pCF].CF_ID = timepoints.CF_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dOP_Operations', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dOP_Operations];
IF Object_ID('metadata.nOP_Operations', 'V') IS NOT NULL
DROP VIEW [metadata].[nOP_Operations];
IF Object_ID('metadata.pOP_Operations', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pOP_Operations];
IF Object_ID('metadata.lOP_Operations', 'V') IS NOT NULL
DROP VIEW [metadata].[lOP_Operations];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOP_Operations viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lOP_Operations] WITH SCHEMABINDING AS
SELECT
    [OP].OP_ID,
    [INS].OP_INS_OP_ID,
    [INS].OP_INS_ChangedAt,
    [INS].OP_INS_Operations_Inserts,
    [UPD].OP_UPD_OP_ID,
    [UPD].OP_UPD_ChangedAt,
    [UPD].OP_UPD_Operations_Updates,
    [DEL].OP_DEL_OP_ID,
    [DEL].OP_DEL_ChangedAt,
    [DEL].OP_DEL_Operations_Deletes
FROM
    [metadata].[OP_Operations] [OP]
LEFT JOIN
    [metadata].[OP_INS_Operations_Inserts] [INS]
ON
    [INS].OP_INS_OP_ID = [OP].OP_ID
AND
    [INS].OP_INS_ChangedAt = (
        SELECT
            max(sub.OP_INS_ChangedAt)
        FROM
            [metadata].[OP_INS_Operations_Inserts] sub
        WHERE
            sub.OP_INS_OP_ID = [OP].OP_ID
   )
LEFT JOIN
    [metadata].[OP_UPD_Operations_Updates] [UPD]
ON
    [UPD].OP_UPD_OP_ID = [OP].OP_ID
AND
    [UPD].OP_UPD_ChangedAt = (
        SELECT
            max(sub.OP_UPD_ChangedAt)
        FROM
            [metadata].[OP_UPD_Operations_Updates] sub
        WHERE
            sub.OP_UPD_OP_ID = [OP].OP_ID
   )
LEFT JOIN
    [metadata].[OP_DEL_Operations_Deletes] [DEL]
ON
    [DEL].OP_DEL_OP_ID = [OP].OP_ID
AND
    [DEL].OP_DEL_ChangedAt = (
        SELECT
            max(sub.OP_DEL_ChangedAt)
        FROM
            [metadata].[OP_DEL_Operations_Deletes] sub
        WHERE
            sub.OP_DEL_OP_ID = [OP].OP_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pOP_Operations viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pOP_Operations] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [OP].OP_ID,
    [INS].OP_INS_OP_ID,
    [INS].OP_INS_ChangedAt,
    [INS].OP_INS_Operations_Inserts,
    [UPD].OP_UPD_OP_ID,
    [UPD].OP_UPD_ChangedAt,
    [UPD].OP_UPD_Operations_Updates,
    [DEL].OP_DEL_OP_ID,
    [DEL].OP_DEL_ChangedAt,
    [DEL].OP_DEL_Operations_Deletes
FROM
    [metadata].[OP_Operations] [OP]
LEFT JOIN
    [metadata].[rOP_INS_Operations_Inserts](@changingTimepoint) [INS]
ON
    [INS].OP_INS_OP_ID = [OP].OP_ID
AND
    [INS].OP_INS_ChangedAt = (
        SELECT
            max(sub.OP_INS_ChangedAt)
        FROM
            [metadata].[rOP_INS_Operations_Inserts](@changingTimepoint) sub
        WHERE
            sub.OP_INS_OP_ID = [OP].OP_ID
   )
LEFT JOIN
    [metadata].[rOP_UPD_Operations_Updates](@changingTimepoint) [UPD]
ON
    [UPD].OP_UPD_OP_ID = [OP].OP_ID
AND
    [UPD].OP_UPD_ChangedAt = (
        SELECT
            max(sub.OP_UPD_ChangedAt)
        FROM
            [metadata].[rOP_UPD_Operations_Updates](@changingTimepoint) sub
        WHERE
            sub.OP_UPD_OP_ID = [OP].OP_ID
   )
LEFT JOIN
    [metadata].[rOP_DEL_Operations_Deletes](@changingTimepoint) [DEL]
ON
    [DEL].OP_DEL_OP_ID = [OP].OP_ID
AND
    [DEL].OP_DEL_ChangedAt = (
        SELECT
            max(sub.OP_DEL_ChangedAt)
        FROM
            [metadata].[rOP_DEL_Operations_Deletes](@changingTimepoint) sub
        WHERE
            sub.OP_DEL_OP_ID = [OP].OP_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOP_Operations viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nOP_Operations]
AS
SELECT
    *
FROM
    [metadata].[pOP_Operations](sysutcdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dOP_Operations showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[dOP_Operations] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pOP].*
FROM (
    SELECT DISTINCT
        OP_INS_OP_ID AS OP_ID,
        OP_INS_ChangedAt AS inspectedTimepoint,
        'INS' AS mnemonic
    FROM
        [metadata].[OP_INS_Operations_Inserts]
    WHERE
        (@selection is null OR @selection like '%INS%')
    AND
        OP_INS_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        OP_UPD_OP_ID AS OP_ID,
        OP_UPD_ChangedAt AS inspectedTimepoint,
        'UPD' AS mnemonic
    FROM
        [metadata].[OP_UPD_Operations_Updates]
    WHERE
        (@selection is null OR @selection like '%UPD%')
    AND
        OP_UPD_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        OP_DEL_OP_ID AS OP_ID,
        OP_DEL_ChangedAt AS inspectedTimepoint,
        'DEL' AS mnemonic
    FROM
        [metadata].[OP_DEL_Operations_Deletes]
    WHERE
        (@selection is null OR @selection like '%DEL%')
    AND
        OP_DEL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [metadata].[pOP_Operations](timepoints.inspectedTimepoint) [pOP]
WHERE
    [pOP].OP_ID = timepoints.OP_ID;
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
-- it_JB_STA_Job_Start instead of INSERT trigger on JB_STA_Job_Start
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_STA_Job_Start', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_STA_Job_Start];
GO
CREATE TRIGGER [metadata].[it_JB_STA_Job_Start] ON [metadata].[JB_STA_Job_Start]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[JB_STA_Job_Start] (
        JB_STA_JB_ID,
        JB_STA_Job_Start
    )
    SELECT
        JB_STA_JB_ID,
        JB_STA_Job_Start
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.JB_STA_JB_ID
        FROM
            [metadata].[JB_STA_Job_Start] x
        WHERE
            x.JB_STA_JB_ID = i.JB_STA_JB_ID
        AND
            x.JB_STA_Job_Start = i.JB_STA_Job_Start
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_JB_END_Job_End instead of INSERT trigger on JB_END_Job_End
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_END_Job_End', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_END_Job_End];
GO
CREATE TRIGGER [metadata].[it_JB_END_Job_End] ON [metadata].[JB_END_Job_End]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[JB_END_Job_End] (
        JB_END_JB_ID,
        JB_END_Job_End
    )
    SELECT
        JB_END_JB_ID,
        JB_END_Job_End
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.JB_END_JB_ID
        FROM
            [metadata].[JB_END_Job_End] x
        WHERE
            x.JB_END_JB_ID = i.JB_END_JB_ID
        AND
            x.JB_END_Job_End = i.JB_END_Job_End
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_JB_NAM_Job_Name instead of INSERT trigger on JB_NAM_Job_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_NAM_Job_Name', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_NAM_Job_Name];
GO
CREATE TRIGGER [metadata].[it_JB_NAM_Job_Name] ON [metadata].[JB_NAM_Job_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[JB_NAM_Job_Name] (
        JB_NAM_JB_ID,
        JB_NAM_JON_ID
    )
    SELECT
        JB_NAM_JB_ID,
        JB_NAM_JON_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.JB_NAM_JB_ID
        FROM
            [metadata].[JB_NAM_Job_Name] x
        WHERE
            x.JB_NAM_JB_ID = i.JB_NAM_JB_ID
        AND
            x.JB_NAM_JON_ID = i.JB_NAM_JON_ID
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_JB_EST_Job_ExecutionStatus instead of INSERT trigger on JB_EST_Job_ExecutionStatus
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_EST_Job_ExecutionStatus', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_EST_Job_ExecutionStatus];
GO
CREATE TRIGGER [metadata].[it_JB_EST_Job_ExecutionStatus] ON [metadata].[JB_EST_Job_ExecutionStatus]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @JB_EST_Job_ExecutionStatus TABLE (
        JB_EST_JB_ID int not null,
        JB_EST_ChangedAt datetime2(7) not null,
        JB_EST_EST_ID tinyint not null, 
        JB_EST_StatementType char(1) not null,
        primary key (
            JB_EST_JB_ID asc, 
            JB_EST_ChangedAt desc
        )
    );
    INSERT INTO @JB_EST_Job_ExecutionStatus
    SELECT
        i.JB_EST_JB_ID,
        i.JB_EST_ChangedAt,
        i.JB_EST_EST_ID,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.JB_EST_JB_ID
        FROM
            [metadata].[JB_EST_Job_ExecutionStatus] x
        WHERE
            x.JB_EST_JB_ID = i.JB_EST_JB_ID
        AND
            x.JB_EST_ChangedAt = i.JB_EST_ChangedAt
        AND
            x.JB_EST_EST_ID = i.JB_EST_EST_ID
    ); -- the posit must be different (exclude the identical)
    INSERT INTO @JB_EST_Job_ExecutionStatus
    SELECT
        i.JB_EST_JB_ID,
        p.JB_EST_ChangedAt,
        p.JB_EST_EST_ID,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            JB_EST_JB_ID 
        FROM 
            @JB_EST_Job_ExecutionStatus
    ) i
    JOIN
        [metadata].[JB_EST_Job_ExecutionStatus] p
    ON
        p.JB_EST_JB_ID = i.JB_EST_JB_ID;
    DECLARE @restated TABLE (
        JB_EST_JB_ID int not null,
        JB_EST_ChangedAt datetime2(7) not null
    );
    INSERT INTO @restated
    SELECT 
        x.JB_EST_JB_ID,
        x.JB_EST_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @JB_EST_Job_ExecutionStatus a
        OUTER APPLY (
            SELECT TOP 1
                h.JB_EST_EST_ID
            FROM 
                @JB_EST_Job_ExecutionStatus h
            WHERE
                h.JB_EST_JB_ID = a.JB_EST_JB_ID
            AND
                h.JB_EST_ChangedAt < a.JB_EST_ChangedAt
            ORDER BY 
                h.JB_EST_ChangedAt DESC
        ) pre
        WHERE
            a.JB_EST_EST_ID = pre.JB_EST_EST_ID
    ) x
    WHERE
        x.JB_EST_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[metadata].[JB_EST_Job_ExecutionStatus] a
	JOIN 
		@restated d
	ON 
		d.JB_EST_JB_ID = a.JB_EST_JB_ID
	AND 
		d.JB_EST_ChangedAt = a.JB_EST_ChangedAt; 
    INSERT INTO [metadata].[JB_EST_Job_ExecutionStatus] (
        JB_EST_JB_ID,
        JB_EST_ChangedAt,
        JB_EST_EST_ID
    )
    SELECT
        JB_EST_JB_ID,
        JB_EST_ChangedAt,
        JB_EST_EST_ID
    FROM
        @JB_EST_Job_ExecutionStatus
    WHERE
        JB_EST_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_JB_AID_Job_AgentJobId instead of INSERT trigger on JB_AID_Job_AgentJobId
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_AID_Job_AgentJobId', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_AID_Job_AgentJobId];
GO
CREATE TRIGGER [metadata].[it_JB_AID_Job_AgentJobId] ON [metadata].[JB_AID_Job_AgentJobId]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[JB_AID_Job_AgentJobId] (
        JB_AID_JB_ID,
        JB_AID_AID_ID
    )
    SELECT
        JB_AID_JB_ID,
        JB_AID_AID_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.JB_AID_JB_ID
        FROM
            [metadata].[JB_AID_Job_AgentJobId] x
        WHERE
            x.JB_AID_JB_ID = i.JB_AID_JB_ID
        AND
            x.JB_AID_AID_ID = i.JB_AID_AID_ID
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CO_NAM_Container_Name instead of INSERT trigger on CO_NAM_Container_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CO_NAM_Container_Name', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CO_NAM_Container_Name];
GO
CREATE TRIGGER [metadata].[it_CO_NAM_Container_Name] ON [metadata].[CO_NAM_Container_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[CO_NAM_Container_Name] (
        CO_NAM_CO_ID,
        CO_NAM_Container_Name
    )
    SELECT
        CO_NAM_CO_ID,
        CO_NAM_Container_Name
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.CO_NAM_CO_ID
        FROM
            [metadata].[CO_NAM_Container_Name] x
        WHERE
            x.CO_NAM_CO_ID = i.CO_NAM_CO_ID
        AND
            x.CO_NAM_Container_Name = i.CO_NAM_Container_Name
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CO_TYP_Container_Type instead of INSERT trigger on CO_TYP_Container_Type
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CO_TYP_Container_Type', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CO_TYP_Container_Type];
GO
CREATE TRIGGER [metadata].[it_CO_TYP_Container_Type] ON [metadata].[CO_TYP_Container_Type]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[CO_TYP_Container_Type] (
        CO_TYP_CO_ID,
        CO_TYP_COT_ID
    )
    SELECT
        CO_TYP_CO_ID,
        CO_TYP_COT_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.CO_TYP_CO_ID
        FROM
            [metadata].[CO_TYP_Container_Type] x
        WHERE
            x.CO_TYP_CO_ID = i.CO_TYP_CO_ID
        AND
            x.CO_TYP_COT_ID = i.CO_TYP_COT_ID
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CO_DSC_Container_Discovered instead of INSERT trigger on CO_DSC_Container_Discovered
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CO_DSC_Container_Discovered', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CO_DSC_Container_Discovered];
GO
CREATE TRIGGER [metadata].[it_CO_DSC_Container_Discovered] ON [metadata].[CO_DSC_Container_Discovered]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @CO_DSC_Container_Discovered TABLE (
        CO_DSC_CO_ID int not null,
        CO_DSC_ChangedAt datetime2(7) not null,
        CO_DSC_Container_Discovered datetime not null,
        CO_DSC_StatementType char(1) not null,
        primary key (
            CO_DSC_CO_ID asc, 
            CO_DSC_ChangedAt desc
        )
    );
    INSERT INTO @CO_DSC_Container_Discovered
    SELECT
        i.CO_DSC_CO_ID,
        i.CO_DSC_ChangedAt,
        i.CO_DSC_Container_Discovered,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.CO_DSC_CO_ID
        FROM
            [metadata].[CO_DSC_Container_Discovered] x
        WHERE
            x.CO_DSC_CO_ID = i.CO_DSC_CO_ID
        AND
            x.CO_DSC_ChangedAt = i.CO_DSC_ChangedAt
        AND
            x.CO_DSC_Container_Discovered = i.CO_DSC_Container_Discovered
    ); -- the posit must be different (exclude the identical)
    INSERT INTO @CO_DSC_Container_Discovered
    SELECT
        i.CO_DSC_CO_ID,
        p.CO_DSC_ChangedAt,
        p.CO_DSC_Container_Discovered,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            CO_DSC_CO_ID 
        FROM 
            @CO_DSC_Container_Discovered
    ) i
    JOIN
        [metadata].[CO_DSC_Container_Discovered] p
    ON
        p.CO_DSC_CO_ID = i.CO_DSC_CO_ID;
    DECLARE @restated TABLE (
        CO_DSC_CO_ID int not null,
        CO_DSC_ChangedAt datetime2(7) not null
    );
    INSERT INTO @restated
    SELECT 
        x.CO_DSC_CO_ID,
        x.CO_DSC_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @CO_DSC_Container_Discovered a
        OUTER APPLY (
            SELECT TOP 1
                h.CO_DSC_Container_Discovered
            FROM 
                @CO_DSC_Container_Discovered h
            WHERE
                h.CO_DSC_CO_ID = a.CO_DSC_CO_ID
            AND
                h.CO_DSC_ChangedAt < a.CO_DSC_ChangedAt
            ORDER BY 
                h.CO_DSC_ChangedAt DESC
        ) pre
        WHERE
            a.CO_DSC_Container_Discovered = pre.CO_DSC_Container_Discovered
    ) x
    WHERE
        x.CO_DSC_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[metadata].[CO_DSC_Container_Discovered] a
	JOIN 
		@restated d
	ON 
		d.CO_DSC_CO_ID = a.CO_DSC_CO_ID
	AND 
		d.CO_DSC_ChangedAt = a.CO_DSC_ChangedAt; 
    INSERT INTO [metadata].[CO_DSC_Container_Discovered] (
        CO_DSC_CO_ID,
        CO_DSC_ChangedAt,
        CO_DSC_Container_Discovered
    )
    SELECT
        CO_DSC_CO_ID,
        CO_DSC_ChangedAt,
        CO_DSC_Container_Discovered
    FROM
        @CO_DSC_Container_Discovered
    WHERE
        CO_DSC_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CO_CRE_Container_Created instead of INSERT trigger on CO_CRE_Container_Created
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CO_CRE_Container_Created', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CO_CRE_Container_Created];
GO
CREATE TRIGGER [metadata].[it_CO_CRE_Container_Created] ON [metadata].[CO_CRE_Container_Created]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[CO_CRE_Container_Created] (
        CO_CRE_CO_ID,
        CO_CRE_Container_Created
    )
    SELECT
        CO_CRE_CO_ID,
        CO_CRE_Container_Created
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.CO_CRE_CO_ID
        FROM
            [metadata].[CO_CRE_Container_Created] x
        WHERE
            x.CO_CRE_CO_ID = i.CO_CRE_CO_ID
        AND
            x.CO_CRE_Container_Created = i.CO_CRE_Container_Created
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_STA_Work_Start instead of INSERT trigger on WO_STA_Work_Start
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_STA_Work_Start', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_STA_Work_Start];
GO
CREATE TRIGGER [metadata].[it_WO_STA_Work_Start] ON [metadata].[WO_STA_Work_Start]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_STA_Work_Start] (
        WO_STA_WO_ID,
        WO_STA_Work_Start
    )
    SELECT
        WO_STA_WO_ID,
        WO_STA_Work_Start
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.WO_STA_WO_ID
        FROM
            [metadata].[WO_STA_Work_Start] x
        WHERE
            x.WO_STA_WO_ID = i.WO_STA_WO_ID
        AND
            x.WO_STA_Work_Start = i.WO_STA_Work_Start
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_END_Work_End instead of INSERT trigger on WO_END_Work_End
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_END_Work_End', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_END_Work_End];
GO
CREATE TRIGGER [metadata].[it_WO_END_Work_End] ON [metadata].[WO_END_Work_End]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_END_Work_End] (
        WO_END_WO_ID,
        WO_END_Work_End
    )
    SELECT
        WO_END_WO_ID,
        WO_END_Work_End
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.WO_END_WO_ID
        FROM
            [metadata].[WO_END_Work_End] x
        WHERE
            x.WO_END_WO_ID = i.WO_END_WO_ID
        AND
            x.WO_END_Work_End = i.WO_END_Work_End
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_NAM_Work_Name instead of INSERT trigger on WO_NAM_Work_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_NAM_Work_Name', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_NAM_Work_Name];
GO
CREATE TRIGGER [metadata].[it_WO_NAM_Work_Name] ON [metadata].[WO_NAM_Work_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_NAM_Work_Name] (
        WO_NAM_WO_ID,
        WO_NAM_WON_ID
    )
    SELECT
        WO_NAM_WO_ID,
        WO_NAM_WON_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.WO_NAM_WO_ID
        FROM
            [metadata].[WO_NAM_Work_Name] x
        WHERE
            x.WO_NAM_WO_ID = i.WO_NAM_WO_ID
        AND
            x.WO_NAM_WON_ID = i.WO_NAM_WON_ID
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_USR_Work_InvocationUser instead of INSERT trigger on WO_USR_Work_InvocationUser
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_USR_Work_InvocationUser', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_USR_Work_InvocationUser];
GO
CREATE TRIGGER [metadata].[it_WO_USR_Work_InvocationUser] ON [metadata].[WO_USR_Work_InvocationUser]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_USR_Work_InvocationUser] (
        WO_USR_WO_ID,
        WO_USR_WIU_ID
    )
    SELECT
        WO_USR_WO_ID,
        WO_USR_WIU_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.WO_USR_WO_ID
        FROM
            [metadata].[WO_USR_Work_InvocationUser] x
        WHERE
            x.WO_USR_WO_ID = i.WO_USR_WO_ID
        AND
            x.WO_USR_WIU_ID = i.WO_USR_WIU_ID
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_ROL_Work_InvocationRole instead of INSERT trigger on WO_ROL_Work_InvocationRole
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_ROL_Work_InvocationRole', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_ROL_Work_InvocationRole];
GO
CREATE TRIGGER [metadata].[it_WO_ROL_Work_InvocationRole] ON [metadata].[WO_ROL_Work_InvocationRole]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_ROL_Work_InvocationRole] (
        WO_ROL_WO_ID,
        WO_ROL_WIR_ID
    )
    SELECT
        WO_ROL_WO_ID,
        WO_ROL_WIR_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.WO_ROL_WO_ID
        FROM
            [metadata].[WO_ROL_Work_InvocationRole] x
        WHERE
            x.WO_ROL_WO_ID = i.WO_ROL_WO_ID
        AND
            x.WO_ROL_WIR_ID = i.WO_ROL_WIR_ID
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_EST_Work_ExecutionStatus instead of INSERT trigger on WO_EST_Work_ExecutionStatus
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_EST_Work_ExecutionStatus', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_EST_Work_ExecutionStatus];
GO
CREATE TRIGGER [metadata].[it_WO_EST_Work_ExecutionStatus] ON [metadata].[WO_EST_Work_ExecutionStatus]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @WO_EST_Work_ExecutionStatus TABLE (
        WO_EST_WO_ID int not null,
        WO_EST_ChangedAt datetime2(7) not null,
        WO_EST_EST_ID tinyint not null, 
        WO_EST_StatementType char(1) not null,
        primary key (
            WO_EST_WO_ID asc, 
            WO_EST_ChangedAt desc
        )
    );
    INSERT INTO @WO_EST_Work_ExecutionStatus
    SELECT
        i.WO_EST_WO_ID,
        i.WO_EST_ChangedAt,
        i.WO_EST_EST_ID,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.WO_EST_WO_ID
        FROM
            [metadata].[WO_EST_Work_ExecutionStatus] x
        WHERE
            x.WO_EST_WO_ID = i.WO_EST_WO_ID
        AND
            x.WO_EST_ChangedAt = i.WO_EST_ChangedAt
        AND
            x.WO_EST_EST_ID = i.WO_EST_EST_ID
    ); -- the posit must be different (exclude the identical)
    INSERT INTO @WO_EST_Work_ExecutionStatus
    SELECT
        i.WO_EST_WO_ID,
        p.WO_EST_ChangedAt,
        p.WO_EST_EST_ID,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            WO_EST_WO_ID 
        FROM 
            @WO_EST_Work_ExecutionStatus
    ) i
    JOIN
        [metadata].[WO_EST_Work_ExecutionStatus] p
    ON
        p.WO_EST_WO_ID = i.WO_EST_WO_ID;
    DECLARE @restated TABLE (
        WO_EST_WO_ID int not null,
        WO_EST_ChangedAt datetime2(7) not null
    );
    INSERT INTO @restated
    SELECT 
        x.WO_EST_WO_ID,
        x.WO_EST_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @WO_EST_Work_ExecutionStatus a
        OUTER APPLY (
            SELECT TOP 1
                h.WO_EST_EST_ID
            FROM 
                @WO_EST_Work_ExecutionStatus h
            WHERE
                h.WO_EST_WO_ID = a.WO_EST_WO_ID
            AND
                h.WO_EST_ChangedAt < a.WO_EST_ChangedAt
            ORDER BY 
                h.WO_EST_ChangedAt DESC
        ) pre
        WHERE
            a.WO_EST_EST_ID = pre.WO_EST_EST_ID
    ) x
    WHERE
        x.WO_EST_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[metadata].[WO_EST_Work_ExecutionStatus] a
	JOIN 
		@restated d
	ON 
		d.WO_EST_WO_ID = a.WO_EST_WO_ID
	AND 
		d.WO_EST_ChangedAt = a.WO_EST_ChangedAt; 
    INSERT INTO [metadata].[WO_EST_Work_ExecutionStatus] (
        WO_EST_WO_ID,
        WO_EST_ChangedAt,
        WO_EST_EST_ID
    )
    SELECT
        WO_EST_WO_ID,
        WO_EST_ChangedAt,
        WO_EST_EST_ID
    FROM
        @WO_EST_Work_ExecutionStatus
    WHERE
        WO_EST_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_ERL_Work_ErrorLine instead of INSERT trigger on WO_ERL_Work_ErrorLine
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_ERL_Work_ErrorLine', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_ERL_Work_ErrorLine];
GO
CREATE TRIGGER [metadata].[it_WO_ERL_Work_ErrorLine] ON [metadata].[WO_ERL_Work_ErrorLine]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_ERL_Work_ErrorLine] (
        WO_ERL_WO_ID,
        WO_ERL_Work_ErrorLine
    )
    SELECT
        WO_ERL_WO_ID,
        WO_ERL_Work_ErrorLine
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.WO_ERL_WO_ID
        FROM
            [metadata].[WO_ERL_Work_ErrorLine] x
        WHERE
            x.WO_ERL_WO_ID = i.WO_ERL_WO_ID
        AND
            x.WO_ERL_Work_ErrorLine = i.WO_ERL_Work_ErrorLine
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_ERM_Work_ErrorMessage instead of INSERT trigger on WO_ERM_Work_ErrorMessage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_ERM_Work_ErrorMessage', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_ERM_Work_ErrorMessage];
GO
CREATE TRIGGER [metadata].[it_WO_ERM_Work_ErrorMessage] ON [metadata].[WO_ERM_Work_ErrorMessage]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_ERM_Work_ErrorMessage] (
        WO_ERM_WO_ID,
        WO_ERM_Work_ErrorMessage
    )
    SELECT
        WO_ERM_WO_ID,
        WO_ERM_Work_ErrorMessage
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.WO_ERM_WO_ID
        FROM
            [metadata].[WO_ERM_Work_ErrorMessage] x
        WHERE
            x.WO_ERM_WO_ID = i.WO_ERM_WO_ID
        AND
            x.WO_ERM_Work_ErrorMessage = i.WO_ERM_Work_ErrorMessage
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_AID_Work_AgentStepId instead of INSERT trigger on WO_AID_Work_AgentStepId
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_AID_Work_AgentStepId', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_AID_Work_AgentStepId];
GO
CREATE TRIGGER [metadata].[it_WO_AID_Work_AgentStepId] ON [metadata].[WO_AID_Work_AgentStepId]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_AID_Work_AgentStepId] (
        WO_AID_WO_ID,
        WO_AID_Work_AgentStepId
    )
    SELECT
        WO_AID_WO_ID,
        WO_AID_Work_AgentStepId
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.WO_AID_WO_ID
        FROM
            [metadata].[WO_AID_Work_AgentStepId] x
        WHERE
            x.WO_AID_WO_ID = i.WO_AID_WO_ID
        AND
            x.WO_AID_Work_AgentStepId = i.WO_AID_Work_AgentStepId
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CF_NAM_Configuration_Name instead of INSERT trigger on CF_NAM_Configuration_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CF_NAM_Configuration_Name', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CF_NAM_Configuration_Name];
GO
CREATE TRIGGER [metadata].[it_CF_NAM_Configuration_Name] ON [metadata].[CF_NAM_Configuration_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[CF_NAM_Configuration_Name] (
        CF_NAM_CF_ID,
        CF_NAM_Configuration_Name
    )
    SELECT
        CF_NAM_CF_ID,
        CF_NAM_Configuration_Name
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.CF_NAM_CF_ID
        FROM
            [metadata].[CF_NAM_Configuration_Name] x
        WHERE
            x.CF_NAM_CF_ID = i.CF_NAM_CF_ID
        AND
            x.CF_NAM_Configuration_Name = i.CF_NAM_Configuration_Name
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CF_XML_Configuration_XMLDefinition instead of INSERT trigger on CF_XML_Configuration_XMLDefinition
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CF_XML_Configuration_XMLDefinition', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CF_XML_Configuration_XMLDefinition];
GO
CREATE TRIGGER [metadata].[it_CF_XML_Configuration_XMLDefinition] ON [metadata].[CF_XML_Configuration_XMLDefinition]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @CF_XML_Configuration_XMLDefinition TABLE (
        CF_XML_CF_ID int not null,
        CF_XML_ChangedAt datetime not null,
        CF_XML_Configuration_XMLDefinition xml not null,
        CF_XML_Checksum varbinary(16) not null,
        CF_XML_StatementType char(1) not null,
        primary key (
            CF_XML_CF_ID asc, 
            CF_XML_ChangedAt desc
        )
    );
    INSERT INTO @CF_XML_Configuration_XMLDefinition
    SELECT
        i.CF_XML_CF_ID,
        i.CF_XML_ChangedAt,
        i.CF_XML_Configuration_XMLDefinition,
        metadata.MD5(cast(i.CF_XML_Configuration_XMLDefinition as varbinary(max))),
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.CF_XML_CF_ID
        FROM
            [metadata].[CF_XML_Configuration_XMLDefinition] x
        WHERE
            x.CF_XML_CF_ID = i.CF_XML_CF_ID
        AND
            x.CF_XML_ChangedAt = i.CF_XML_ChangedAt
        AND
            x.CF_XML_Checksum = i.CF_XML_Checksum 
    ); -- the posit must be different (exclude the identical)
    INSERT INTO @CF_XML_Configuration_XMLDefinition
    SELECT
        i.CF_XML_CF_ID,
        p.CF_XML_ChangedAt,
        p.CF_XML_Configuration_XMLDefinition,
        p.CF_XML_Checksum,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            CF_XML_CF_ID 
        FROM 
            @CF_XML_Configuration_XMLDefinition
    ) i
    JOIN
        [metadata].[CF_XML_Configuration_XMLDefinition] p
    ON
        p.CF_XML_CF_ID = i.CF_XML_CF_ID;
    DECLARE @restated TABLE (
        CF_XML_CF_ID int not null,
        CF_XML_ChangedAt datetime not null
    );
    INSERT INTO @restated
    SELECT 
        x.CF_XML_CF_ID,
        x.CF_XML_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @CF_XML_Configuration_XMLDefinition a
        OUTER APPLY (
            SELECT TOP 1
                h.CF_XML_Checksum 
            FROM 
                @CF_XML_Configuration_XMLDefinition h
            WHERE
                h.CF_XML_CF_ID = a.CF_XML_CF_ID
            AND
                h.CF_XML_ChangedAt < a.CF_XML_ChangedAt
            ORDER BY 
                h.CF_XML_ChangedAt DESC
        ) pre
        WHERE
            a.CF_XML_Checksum = pre.CF_XML_Checksum 
    ) x
    WHERE
        x.CF_XML_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[metadata].[CF_XML_Configuration_XMLDefinition] a
	JOIN 
		@restated d
	ON 
		d.CF_XML_CF_ID = a.CF_XML_CF_ID
	AND 
		d.CF_XML_ChangedAt = a.CF_XML_ChangedAt; 
    INSERT INTO [metadata].[CF_XML_Configuration_XMLDefinition] (
        CF_XML_CF_ID,
        CF_XML_ChangedAt,
        CF_XML_Configuration_XMLDefinition
    )
    SELECT
        CF_XML_CF_ID,
        CF_XML_ChangedAt,
        CF_XML_Configuration_XMLDefinition
    FROM
        @CF_XML_Configuration_XMLDefinition
    WHERE
        CF_XML_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CF_TYP_Configuration_Type instead of INSERT trigger on CF_TYP_Configuration_Type
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CF_TYP_Configuration_Type', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CF_TYP_Configuration_Type];
GO
CREATE TRIGGER [metadata].[it_CF_TYP_Configuration_Type] ON [metadata].[CF_TYP_Configuration_Type]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[CF_TYP_Configuration_Type] (
        CF_TYP_CF_ID,
        CF_TYP_CFT_ID
    )
    SELECT
        CF_TYP_CF_ID,
        CF_TYP_CFT_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.CF_TYP_CF_ID
        FROM
            [metadata].[CF_TYP_Configuration_Type] x
        WHERE
            x.CF_TYP_CF_ID = i.CF_TYP_CF_ID
        AND
            x.CF_TYP_CFT_ID = i.CF_TYP_CFT_ID
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OP_INS_Operations_Inserts instead of INSERT trigger on OP_INS_Operations_Inserts
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_OP_INS_Operations_Inserts', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_OP_INS_Operations_Inserts];
GO
CREATE TRIGGER [metadata].[it_OP_INS_Operations_Inserts] ON [metadata].[OP_INS_Operations_Inserts]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @OP_INS_Operations_Inserts TABLE (
        OP_INS_OP_ID int not null,
        OP_INS_ChangedAt datetime2(7) not null,
        OP_INS_Operations_Inserts int not null,
        OP_INS_StatementType char(1) not null,
        primary key (
            OP_INS_OP_ID asc, 
            OP_INS_ChangedAt desc
        )
    );
    INSERT INTO @OP_INS_Operations_Inserts
    SELECT
        i.OP_INS_OP_ID,
        i.OP_INS_ChangedAt,
        i.OP_INS_Operations_Inserts,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.OP_INS_OP_ID
        FROM
            [metadata].[OP_INS_Operations_Inserts] x
        WHERE
            x.OP_INS_OP_ID = i.OP_INS_OP_ID
        AND
            x.OP_INS_ChangedAt = i.OP_INS_ChangedAt
        AND
            x.OP_INS_Operations_Inserts = i.OP_INS_Operations_Inserts
    ); -- the posit must be different (exclude the identical)
    INSERT INTO @OP_INS_Operations_Inserts
    SELECT
        i.OP_INS_OP_ID,
        p.OP_INS_ChangedAt,
        p.OP_INS_Operations_Inserts,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            OP_INS_OP_ID 
        FROM 
            @OP_INS_Operations_Inserts
    ) i
    JOIN
        [metadata].[OP_INS_Operations_Inserts] p
    ON
        p.OP_INS_OP_ID = i.OP_INS_OP_ID;
    DECLARE @restated TABLE (
        OP_INS_OP_ID int not null,
        OP_INS_ChangedAt datetime2(7) not null
    );
    INSERT INTO @restated
    SELECT 
        x.OP_INS_OP_ID,
        x.OP_INS_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @OP_INS_Operations_Inserts a
        OUTER APPLY (
            SELECT TOP 1
                h.OP_INS_Operations_Inserts
            FROM 
                @OP_INS_Operations_Inserts h
            WHERE
                h.OP_INS_OP_ID = a.OP_INS_OP_ID
            AND
                h.OP_INS_ChangedAt < a.OP_INS_ChangedAt
            ORDER BY 
                h.OP_INS_ChangedAt DESC
        ) pre
        WHERE
            a.OP_INS_Operations_Inserts = pre.OP_INS_Operations_Inserts
    ) x
    WHERE
        x.OP_INS_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[metadata].[OP_INS_Operations_Inserts] a
	JOIN 
		@restated d
	ON 
		d.OP_INS_OP_ID = a.OP_INS_OP_ID
	AND 
		d.OP_INS_ChangedAt = a.OP_INS_ChangedAt; 
    INSERT INTO [metadata].[OP_INS_Operations_Inserts] (
        OP_INS_OP_ID,
        OP_INS_ChangedAt,
        OP_INS_Operations_Inserts
    )
    SELECT
        OP_INS_OP_ID,
        OP_INS_ChangedAt,
        OP_INS_Operations_Inserts
    FROM
        @OP_INS_Operations_Inserts
    WHERE
        OP_INS_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OP_UPD_Operations_Updates instead of INSERT trigger on OP_UPD_Operations_Updates
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_OP_UPD_Operations_Updates', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_OP_UPD_Operations_Updates];
GO
CREATE TRIGGER [metadata].[it_OP_UPD_Operations_Updates] ON [metadata].[OP_UPD_Operations_Updates]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @OP_UPD_Operations_Updates TABLE (
        OP_UPD_OP_ID int not null,
        OP_UPD_ChangedAt datetime2(7) not null,
        OP_UPD_Operations_Updates int not null,
        OP_UPD_StatementType char(1) not null,
        primary key (
            OP_UPD_OP_ID asc, 
            OP_UPD_ChangedAt desc
        )
    );
    INSERT INTO @OP_UPD_Operations_Updates
    SELECT
        i.OP_UPD_OP_ID,
        i.OP_UPD_ChangedAt,
        i.OP_UPD_Operations_Updates,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.OP_UPD_OP_ID
        FROM
            [metadata].[OP_UPD_Operations_Updates] x
        WHERE
            x.OP_UPD_OP_ID = i.OP_UPD_OP_ID
        AND
            x.OP_UPD_ChangedAt = i.OP_UPD_ChangedAt
        AND
            x.OP_UPD_Operations_Updates = i.OP_UPD_Operations_Updates
    ); -- the posit must be different (exclude the identical)
    INSERT INTO @OP_UPD_Operations_Updates
    SELECT
        i.OP_UPD_OP_ID,
        p.OP_UPD_ChangedAt,
        p.OP_UPD_Operations_Updates,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            OP_UPD_OP_ID 
        FROM 
            @OP_UPD_Operations_Updates
    ) i
    JOIN
        [metadata].[OP_UPD_Operations_Updates] p
    ON
        p.OP_UPD_OP_ID = i.OP_UPD_OP_ID;
    DECLARE @restated TABLE (
        OP_UPD_OP_ID int not null,
        OP_UPD_ChangedAt datetime2(7) not null
    );
    INSERT INTO @restated
    SELECT 
        x.OP_UPD_OP_ID,
        x.OP_UPD_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @OP_UPD_Operations_Updates a
        OUTER APPLY (
            SELECT TOP 1
                h.OP_UPD_Operations_Updates
            FROM 
                @OP_UPD_Operations_Updates h
            WHERE
                h.OP_UPD_OP_ID = a.OP_UPD_OP_ID
            AND
                h.OP_UPD_ChangedAt < a.OP_UPD_ChangedAt
            ORDER BY 
                h.OP_UPD_ChangedAt DESC
        ) pre
        WHERE
            a.OP_UPD_Operations_Updates = pre.OP_UPD_Operations_Updates
    ) x
    WHERE
        x.OP_UPD_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[metadata].[OP_UPD_Operations_Updates] a
	JOIN 
		@restated d
	ON 
		d.OP_UPD_OP_ID = a.OP_UPD_OP_ID
	AND 
		d.OP_UPD_ChangedAt = a.OP_UPD_ChangedAt; 
    INSERT INTO [metadata].[OP_UPD_Operations_Updates] (
        OP_UPD_OP_ID,
        OP_UPD_ChangedAt,
        OP_UPD_Operations_Updates
    )
    SELECT
        OP_UPD_OP_ID,
        OP_UPD_ChangedAt,
        OP_UPD_Operations_Updates
    FROM
        @OP_UPD_Operations_Updates
    WHERE
        OP_UPD_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OP_DEL_Operations_Deletes instead of INSERT trigger on OP_DEL_Operations_Deletes
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_OP_DEL_Operations_Deletes', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_OP_DEL_Operations_Deletes];
GO
CREATE TRIGGER [metadata].[it_OP_DEL_Operations_Deletes] ON [metadata].[OP_DEL_Operations_Deletes]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @OP_DEL_Operations_Deletes TABLE (
        OP_DEL_OP_ID int not null,
        OP_DEL_ChangedAt datetime2(7) not null,
        OP_DEL_Operations_Deletes int not null,
        OP_DEL_StatementType char(1) not null,
        primary key (
            OP_DEL_OP_ID asc, 
            OP_DEL_ChangedAt desc
        )
    );
    INSERT INTO @OP_DEL_Operations_Deletes
    SELECT
        i.OP_DEL_OP_ID,
        i.OP_DEL_ChangedAt,
        i.OP_DEL_Operations_Deletes,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            x.OP_DEL_OP_ID
        FROM
            [metadata].[OP_DEL_Operations_Deletes] x
        WHERE
            x.OP_DEL_OP_ID = i.OP_DEL_OP_ID
        AND
            x.OP_DEL_ChangedAt = i.OP_DEL_ChangedAt
        AND
            x.OP_DEL_Operations_Deletes = i.OP_DEL_Operations_Deletes
    ); -- the posit must be different (exclude the identical)
    INSERT INTO @OP_DEL_Operations_Deletes
    SELECT
        i.OP_DEL_OP_ID,
        p.OP_DEL_ChangedAt,
        p.OP_DEL_Operations_Deletes,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            OP_DEL_OP_ID 
        FROM 
            @OP_DEL_Operations_Deletes
    ) i
    JOIN
        [metadata].[OP_DEL_Operations_Deletes] p
    ON
        p.OP_DEL_OP_ID = i.OP_DEL_OP_ID;
    DECLARE @restated TABLE (
        OP_DEL_OP_ID int not null,
        OP_DEL_ChangedAt datetime2(7) not null
    );
    INSERT INTO @restated
    SELECT 
        x.OP_DEL_OP_ID,
        x.OP_DEL_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @OP_DEL_Operations_Deletes a
        OUTER APPLY (
            SELECT TOP 1
                h.OP_DEL_Operations_Deletes
            FROM 
                @OP_DEL_Operations_Deletes h
            WHERE
                h.OP_DEL_OP_ID = a.OP_DEL_OP_ID
            AND
                h.OP_DEL_ChangedAt < a.OP_DEL_ChangedAt
            ORDER BY 
                h.OP_DEL_ChangedAt DESC
        ) pre
        WHERE
            a.OP_DEL_Operations_Deletes = pre.OP_DEL_Operations_Deletes
    ) x
    WHERE
        x.OP_DEL_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[metadata].[OP_DEL_Operations_Deletes] a
	JOIN 
		@restated d
	ON 
		d.OP_DEL_OP_ID = a.OP_DEL_OP_ID
	AND 
		d.OP_DEL_ChangedAt = a.OP_DEL_ChangedAt; 
    INSERT INTO [metadata].[OP_DEL_Operations_Deletes] (
        OP_DEL_OP_ID,
        OP_DEL_ChangedAt,
        OP_DEL_Operations_Deletes
    )
    SELECT
        OP_DEL_OP_ID,
        OP_DEL_ChangedAt,
        OP_DEL_Operations_Deletes
    FROM
        @OP_DEL_Operations_Deletes
    WHERE
        OP_DEL_StatementType = 'P';
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
-- it_lJB_Job instead of INSERT trigger on lJB_Job
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lJB_Job] ON [metadata].[lJB_Job]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @JB TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        JB_ID int not null
    );
    INSERT INTO [metadata].[JB_Job] (
        JB_Dummy
    )
    OUTPUT
        inserted.JB_ID
    INTO
        @JB
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.JB_ID is null;
    DECLARE @inserted TABLE (
        JB_ID int not null,
        JB_STA_JB_ID int null,
        JB_STA_Job_Start datetime2(7) null,
        JB_END_JB_ID int null,
        JB_END_Job_End datetime2(7) null,
        JB_NAM_JB_ID int null,
        JB_NAM_JON_JobName varchar(255) null,
        JB_NAM_JON_ID int null,
        JB_EST_JB_ID int null,
        JB_EST_ChangedAt datetime2(7) null,
        JB_EST_EST_ExecutionStatus varchar(42) null,
        JB_EST_EST_ID tinyint null,
        JB_AID_JB_ID int null,
        JB_AID_AID_AgentJobId uniqueidentifier null,
        JB_AID_AID_ID int null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.JB_ID, a.JB_ID),
        ISNULL(ISNULL(i.JB_STA_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_STA_Job_Start,
        ISNULL(ISNULL(i.JB_END_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_END_Job_End,
        ISNULL(ISNULL(i.JB_NAM_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_NAM_JON_JobName,
        i.JB_NAM_JON_ID,
        ISNULL(ISNULL(i.JB_EST_JB_ID, i.JB_ID), a.JB_ID),
        ISNULL(i.JB_EST_ChangedAt, @now),
        i.JB_EST_EST_ExecutionStatus,
        i.JB_EST_EST_ID,
        ISNULL(ISNULL(i.JB_AID_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_AID_AID_AgentJobId,
        i.JB_AID_AID_ID
    FROM (
        SELECT
            JB_ID,
            JB_STA_JB_ID,
            JB_STA_Job_Start,
            JB_END_JB_ID,
            JB_END_Job_End,
            JB_NAM_JB_ID,
            JB_NAM_JON_JobName,
            JB_NAM_JON_ID,
            JB_EST_JB_ID,
            JB_EST_ChangedAt,
            JB_EST_EST_ExecutionStatus,
            JB_EST_EST_ID,
            JB_AID_JB_ID,
            JB_AID_AID_AgentJobId,
            JB_AID_AID_ID,
            ROW_NUMBER() OVER (PARTITION BY JB_ID ORDER BY JB_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @JB a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[JB_STA_Job_Start] (
        JB_STA_JB_ID,
        JB_STA_Job_Start
    )
    SELECT DISTINCT
        i.JB_STA_JB_ID,
        i.JB_STA_Job_Start
    FROM
        @inserted i
    WHERE
        i.JB_STA_Job_Start is not null;
    INSERT INTO [metadata].[JB_END_Job_End] (
        JB_END_JB_ID,
        JB_END_Job_End
    )
    SELECT DISTINCT
        i.JB_END_JB_ID,
        i.JB_END_Job_End
    FROM
        @inserted i
    WHERE
        i.JB_END_Job_End is not null;
    INSERT INTO [metadata].[JB_NAM_Job_Name] (
        JB_NAM_JB_ID,
        JB_NAM_JON_ID
    )
    SELECT DISTINCT
        i.JB_NAM_JB_ID,
        ISNULL(i.JB_NAM_JON_ID, [kJON].JON_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[JON_JobName] [kJON]
    ON
        [kJON].JON_JobName = i.JB_NAM_JON_JobName
    WHERE
        ISNULL(i.JB_NAM_JON_ID, [kJON].JON_ID) is not null;
    INSERT INTO [metadata].[JB_EST_Job_ExecutionStatus] (
        JB_EST_JB_ID,
        JB_EST_ChangedAt,
        JB_EST_EST_ID
    )
    SELECT DISTINCT
        i.JB_EST_JB_ID,
        i.JB_EST_ChangedAt,
        ISNULL(i.JB_EST_EST_ID, [kEST].EST_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[EST_ExecutionStatus] [kEST]
    ON
        [kEST].EST_ExecutionStatus = i.JB_EST_EST_ExecutionStatus
    WHERE
        ISNULL(i.JB_EST_EST_ID, [kEST].EST_ID) is not null;
    INSERT INTO [metadata].[JB_AID_Job_AgentJobId] (
        JB_AID_JB_ID,
        JB_AID_AID_ID
    )
    SELECT DISTINCT
        i.JB_AID_JB_ID,
        ISNULL(i.JB_AID_AID_ID, [kAID].AID_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[AID_AgentJobId] [kAID]
    ON
        [kAID].AID_AgentJobId = i.JB_AID_AID_AgentJobId
    WHERE
        ISNULL(i.JB_AID_AID_ID, [kAID].AID_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lJB_Job instead of UPDATE trigger on lJB_Job
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lJB_Job] ON [metadata].[lJB_Job]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    IF(UPDATE(JB_ID))
        RAISERROR('The identity column JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_STA_JB_ID))
        RAISERROR('The foreign key column JB_STA_JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_STA_Job_Start))
    BEGIN
        INSERT INTO [metadata].[JB_STA_Job_Start] (
            JB_STA_JB_ID,
            JB_STA_Job_Start
        )
        SELECT DISTINCT
            ISNULL(i.JB_STA_JB_ID, i.JB_ID),
            i.JB_STA_Job_Start
        FROM
            inserted i
        WHERE
            i.JB_STA_Job_Start is not null;
    END
    IF(UPDATE(JB_END_JB_ID))
        RAISERROR('The foreign key column JB_END_JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_END_Job_End))
    BEGIN
        INSERT INTO [metadata].[JB_END_Job_End] (
            JB_END_JB_ID,
            JB_END_Job_End
        )
        SELECT DISTINCT
            ISNULL(i.JB_END_JB_ID, i.JB_ID),
            i.JB_END_Job_End
        FROM
            inserted i
        WHERE
            i.JB_END_Job_End is not null;
    END
    IF(UPDATE(JB_NAM_JB_ID))
        RAISERROR('The foreign key column JB_NAM_JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_NAM_JON_ID) OR UPDATE(JB_NAM_JON_JobName))
    BEGIN
        INSERT INTO [metadata].[JB_NAM_Job_Name] (
            JB_NAM_JB_ID,
            JB_NAM_JON_ID
        )
        SELECT DISTINCT
            ISNULL(i.JB_NAM_JB_ID, i.JB_ID),
            CASE WHEN UPDATE(JB_NAM_JON_ID) THEN i.JB_NAM_JON_ID ELSE [kJON].JON_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[JON_JobName] [kJON]
        ON
            [kJON].JON_JobName = i.JB_NAM_JON_JobName
        WHERE
            CASE WHEN UPDATE(JB_NAM_JON_ID) THEN i.JB_NAM_JON_ID ELSE [kJON].JON_ID END is not null;
    END
    IF(UPDATE(JB_EST_JB_ID))
        RAISERROR('The foreign key column JB_EST_JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_EST_EST_ID) OR UPDATE(JB_EST_EST_ExecutionStatus))
    BEGIN
        INSERT INTO [metadata].[JB_EST_Job_ExecutionStatus] (
            JB_EST_JB_ID,
            JB_EST_ChangedAt,
            JB_EST_EST_ID
        )
        SELECT DISTINCT
            ISNULL(i.JB_EST_JB_ID, i.JB_ID),
            cast(ISNULL(CASE
                WHEN i.JB_EST_EST_ID is null AND [kEST].EST_ID is null THEN i.JB_EST_ChangedAt
                WHEN UPDATE(JB_EST_ChangedAt) THEN i.JB_EST_ChangedAt
            END, @now) as datetime2(7)),
            CASE WHEN UPDATE(JB_EST_EST_ID) THEN i.JB_EST_EST_ID ELSE [kEST].EST_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[EST_ExecutionStatus] [kEST]
        ON
            [kEST].EST_ExecutionStatus = i.JB_EST_EST_ExecutionStatus
        WHERE
            CASE WHEN UPDATE(JB_EST_EST_ID) THEN i.JB_EST_EST_ID ELSE [kEST].EST_ID END is not null;
    END
    IF(UPDATE(JB_AID_JB_ID))
        RAISERROR('The foreign key column JB_AID_JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_AID_AID_ID) OR UPDATE(JB_AID_AID_AgentJobId))
    BEGIN
        INSERT INTO [metadata].[JB_AID_Job_AgentJobId] (
            JB_AID_JB_ID,
            JB_AID_AID_ID
        )
        SELECT DISTINCT
            ISNULL(i.JB_AID_JB_ID, i.JB_ID),
            CASE WHEN UPDATE(JB_AID_AID_ID) THEN i.JB_AID_AID_ID ELSE [kAID].AID_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[AID_AgentJobId] [kAID]
        ON
            [kAID].AID_AgentJobId = i.JB_AID_AID_AgentJobId
        WHERE
            CASE WHEN UPDATE(JB_AID_AID_ID) THEN i.JB_AID_AID_ID ELSE [kAID].AID_ID END is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lJB_Job instead of DELETE trigger on lJB_Job
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lJB_Job] ON [metadata].[lJB_Job]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [STA]
    FROM
        [metadata].[JB_STA_Job_Start] [STA]
    JOIN
        deleted d
    ON
        d.JB_STA_JB_ID = [STA].JB_STA_JB_ID;
    DELETE [END]
    FROM
        [metadata].[JB_END_Job_End] [END]
    JOIN
        deleted d
    ON
        d.JB_END_JB_ID = [END].JB_END_JB_ID;
    DELETE [NAM]
    FROM
        [metadata].[JB_NAM_Job_Name] [NAM]
    JOIN
        deleted d
    ON
        d.JB_NAM_JB_ID = [NAM].JB_NAM_JB_ID;
    DELETE [EST]
    FROM
        [metadata].[JB_EST_Job_ExecutionStatus] [EST]
    JOIN
        deleted d
    ON
        d.JB_EST_ChangedAt = [EST].JB_EST_ChangedAt
    AND
        d.JB_EST_JB_ID = [EST].JB_EST_JB_ID;
    DELETE [AID]
    FROM
        [metadata].[JB_AID_Job_AgentJobId] [AID]
    JOIN
        deleted d
    ON
        d.JB_AID_JB_ID = [AID].JB_AID_JB_ID;
    DECLARE @deleted TABLE (
        JB_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (JB_ID)
    SELECT a.JB_ID
    FROM (
        SELECT [JB].JB_ID
        FROM [metadata].[JB_Job] [JB] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 JB_STA_JB_ID
            FROM [metadata].[JB_STA_Job_Start] WITH(NOLOCK)
            WHERE JB_STA_JB_ID = [JB].JB_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 JB_END_JB_ID
            FROM [metadata].[JB_END_Job_End] WITH(NOLOCK)
            WHERE JB_END_JB_ID = [JB].JB_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 JB_NAM_JB_ID
            FROM [metadata].[JB_NAM_Job_Name] WITH(NOLOCK)
            WHERE JB_NAM_JB_ID = [JB].JB_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 JB_EST_JB_ID
            FROM [metadata].[JB_EST_Job_ExecutionStatus] WITH(NOLOCK)
            WHERE JB_EST_JB_ID = [JB].JB_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 JB_AID_JB_ID
            FROM [metadata].[JB_AID_Job_AgentJobId] WITH(NOLOCK)
            WHERE JB_AID_JB_ID = [JB].JB_ID
        )
    ) a
    JOIN deleted d
    ON d.JB_ID = a.JB_ID;
    DELETE [JB]
    FROM [metadata].[JB_Job] [JB]
    JOIN @deleted d
    ON d.JB_ID = [JB].JB_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lCO_Container instead of INSERT trigger on lCO_Container
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lCO_Container] ON [metadata].[lCO_Container]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @CO TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        CO_ID int not null
    );
    INSERT INTO [metadata].[CO_Container] (
        CO_Dummy
    )
    OUTPUT
        inserted.CO_ID
    INTO
        @CO
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.CO_ID is null;
    DECLARE @inserted TABLE (
        CO_ID int not null,
        CO_NAM_CO_ID int null,
        CO_NAM_Container_Name varchar(2000) null,
        CO_TYP_CO_ID int null,
        CO_TYP_COT_ContainerType varchar(42) null,
        CO_TYP_COT_ID tinyint null,
        CO_DSC_CO_ID int null,
        CO_DSC_ChangedAt datetime2(7) null,
        CO_DSC_Container_Discovered datetime null,
        CO_CRE_CO_ID int null,
        CO_CRE_Container_Created datetime null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.CO_ID, a.CO_ID),
        ISNULL(ISNULL(i.CO_NAM_CO_ID, i.CO_ID), a.CO_ID),
        i.CO_NAM_Container_Name,
        ISNULL(ISNULL(i.CO_TYP_CO_ID, i.CO_ID), a.CO_ID),
        i.CO_TYP_COT_ContainerType,
        i.CO_TYP_COT_ID,
        ISNULL(ISNULL(i.CO_DSC_CO_ID, i.CO_ID), a.CO_ID),
        ISNULL(i.CO_DSC_ChangedAt, @now),
        i.CO_DSC_Container_Discovered,
        ISNULL(ISNULL(i.CO_CRE_CO_ID, i.CO_ID), a.CO_ID),
        i.CO_CRE_Container_Created
    FROM (
        SELECT
            CO_ID,
            CO_NAM_CO_ID,
            CO_NAM_Container_Name,
            CO_TYP_CO_ID,
            CO_TYP_COT_ContainerType,
            CO_TYP_COT_ID,
            CO_DSC_CO_ID,
            CO_DSC_ChangedAt,
            CO_DSC_Container_Discovered,
            CO_CRE_CO_ID,
            CO_CRE_Container_Created,
            ROW_NUMBER() OVER (PARTITION BY CO_ID ORDER BY CO_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @CO a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[CO_NAM_Container_Name] (
        CO_NAM_CO_ID,
        CO_NAM_Container_Name
    )
    SELECT DISTINCT
        i.CO_NAM_CO_ID,
        i.CO_NAM_Container_Name
    FROM
        @inserted i
    WHERE
        i.CO_NAM_Container_Name is not null;
    INSERT INTO [metadata].[CO_TYP_Container_Type] (
        CO_TYP_CO_ID,
        CO_TYP_COT_ID
    )
    SELECT DISTINCT
        i.CO_TYP_CO_ID,
        ISNULL(i.CO_TYP_COT_ID, [kCOT].COT_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[COT_ContainerType] [kCOT]
    ON
        [kCOT].COT_ContainerType = i.CO_TYP_COT_ContainerType
    WHERE
        ISNULL(i.CO_TYP_COT_ID, [kCOT].COT_ID) is not null;
    INSERT INTO [metadata].[CO_DSC_Container_Discovered] (
        CO_DSC_CO_ID,
        CO_DSC_ChangedAt,
        CO_DSC_Container_Discovered
    )
    SELECT DISTINCT
        i.CO_DSC_CO_ID,
        i.CO_DSC_ChangedAt,
        i.CO_DSC_Container_Discovered
    FROM
        @inserted i
    WHERE
        i.CO_DSC_Container_Discovered is not null;
    INSERT INTO [metadata].[CO_CRE_Container_Created] (
        CO_CRE_CO_ID,
        CO_CRE_Container_Created
    )
    SELECT DISTINCT
        i.CO_CRE_CO_ID,
        i.CO_CRE_Container_Created
    FROM
        @inserted i
    WHERE
        i.CO_CRE_Container_Created is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lCO_Container instead of UPDATE trigger on lCO_Container
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lCO_Container] ON [metadata].[lCO_Container]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    IF(UPDATE(CO_ID))
        RAISERROR('The identity column CO_ID is not updatable.', 16, 1);
    IF(UPDATE(CO_NAM_CO_ID))
        RAISERROR('The foreign key column CO_NAM_CO_ID is not updatable.', 16, 1);
    IF(UPDATE(CO_NAM_Container_Name))
    BEGIN
        INSERT INTO [metadata].[CO_NAM_Container_Name] (
            CO_NAM_CO_ID,
            CO_NAM_Container_Name
        )
        SELECT DISTINCT
            ISNULL(i.CO_NAM_CO_ID, i.CO_ID),
            i.CO_NAM_Container_Name
        FROM
            inserted i
        WHERE
            i.CO_NAM_Container_Name is not null;
    END
    IF(UPDATE(CO_TYP_CO_ID))
        RAISERROR('The foreign key column CO_TYP_CO_ID is not updatable.', 16, 1);
    IF(UPDATE(CO_TYP_COT_ID) OR UPDATE(CO_TYP_COT_ContainerType))
    BEGIN
        INSERT INTO [metadata].[CO_TYP_Container_Type] (
            CO_TYP_CO_ID,
            CO_TYP_COT_ID
        )
        SELECT DISTINCT
            ISNULL(i.CO_TYP_CO_ID, i.CO_ID),
            CASE WHEN UPDATE(CO_TYP_COT_ID) THEN i.CO_TYP_COT_ID ELSE [kCOT].COT_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[COT_ContainerType] [kCOT]
        ON
            [kCOT].COT_ContainerType = i.CO_TYP_COT_ContainerType
        WHERE
            CASE WHEN UPDATE(CO_TYP_COT_ID) THEN i.CO_TYP_COT_ID ELSE [kCOT].COT_ID END is not null;
    END
    IF(UPDATE(CO_DSC_CO_ID))
        RAISERROR('The foreign key column CO_DSC_CO_ID is not updatable.', 16, 1);
    IF(UPDATE(CO_DSC_Container_Discovered))
    BEGIN
        INSERT INTO [metadata].[CO_DSC_Container_Discovered] (
            CO_DSC_CO_ID,
            CO_DSC_ChangedAt,
            CO_DSC_Container_Discovered
        )
        SELECT DISTINCT
            ISNULL(i.CO_DSC_CO_ID, i.CO_ID),
            cast(ISNULL(CASE
                WHEN i.CO_DSC_Container_Discovered is null THEN i.CO_DSC_ChangedAt
                WHEN UPDATE(CO_DSC_ChangedAt) THEN i.CO_DSC_ChangedAt
            END, @now) as datetime2(7)),
            i.CO_DSC_Container_Discovered
        FROM
            inserted i
        WHERE
            i.CO_DSC_Container_Discovered is not null;
    END
    IF(UPDATE(CO_CRE_CO_ID))
        RAISERROR('The foreign key column CO_CRE_CO_ID is not updatable.', 16, 1);
    IF(UPDATE(CO_CRE_Container_Created))
    BEGIN
        INSERT INTO [metadata].[CO_CRE_Container_Created] (
            CO_CRE_CO_ID,
            CO_CRE_Container_Created
        )
        SELECT DISTINCT
            ISNULL(i.CO_CRE_CO_ID, i.CO_ID),
            i.CO_CRE_Container_Created
        FROM
            inserted i
        WHERE
            i.CO_CRE_Container_Created is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lCO_Container instead of DELETE trigger on lCO_Container
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lCO_Container] ON [metadata].[lCO_Container]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [metadata].[CO_NAM_Container_Name] [NAM]
    JOIN
        deleted d
    ON
        d.CO_NAM_CO_ID = [NAM].CO_NAM_CO_ID;
    DELETE [TYP]
    FROM
        [metadata].[CO_TYP_Container_Type] [TYP]
    JOIN
        deleted d
    ON
        d.CO_TYP_CO_ID = [TYP].CO_TYP_CO_ID;
    DELETE [DSC]
    FROM
        [metadata].[CO_DSC_Container_Discovered] [DSC]
    JOIN
        deleted d
    ON
        d.CO_DSC_ChangedAt = [DSC].CO_DSC_ChangedAt
    AND
        d.CO_DSC_CO_ID = [DSC].CO_DSC_CO_ID;
    DELETE [CRE]
    FROM
        [metadata].[CO_CRE_Container_Created] [CRE]
    JOIN
        deleted d
    ON
        d.CO_CRE_CO_ID = [CRE].CO_CRE_CO_ID;
    DECLARE @deleted TABLE (
        CO_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (CO_ID)
    SELECT a.CO_ID
    FROM (
        SELECT [CO].CO_ID
        FROM [metadata].[CO_Container] [CO] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 CO_NAM_CO_ID
            FROM [metadata].[CO_NAM_Container_Name] WITH(NOLOCK)
            WHERE CO_NAM_CO_ID = [CO].CO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 CO_TYP_CO_ID
            FROM [metadata].[CO_TYP_Container_Type] WITH(NOLOCK)
            WHERE CO_TYP_CO_ID = [CO].CO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 CO_DSC_CO_ID
            FROM [metadata].[CO_DSC_Container_Discovered] WITH(NOLOCK)
            WHERE CO_DSC_CO_ID = [CO].CO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 CO_CRE_CO_ID
            FROM [metadata].[CO_CRE_Container_Created] WITH(NOLOCK)
            WHERE CO_CRE_CO_ID = [CO].CO_ID
        )
    ) a
    JOIN deleted d
    ON d.CO_ID = a.CO_ID;
    DELETE [CO]
    FROM [metadata].[CO_Container] [CO]
    JOIN @deleted d
    ON d.CO_ID = [CO].CO_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lWO_Work instead of INSERT trigger on lWO_Work
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lWO_Work] ON [metadata].[lWO_Work]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @WO TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        WO_ID int not null
    );
    INSERT INTO [metadata].[WO_Work] (
        WO_Dummy
    )
    OUTPUT
        inserted.WO_ID
    INTO
        @WO
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.WO_ID is null;
    DECLARE @inserted TABLE (
        WO_ID int not null,
        WO_STA_WO_ID int null,
        WO_STA_Work_Start datetime2(7) null,
        WO_END_WO_ID int null,
        WO_END_Work_End datetime2(7) null,
        WO_NAM_WO_ID int null,
        WO_NAM_WON_WorkName varchar(255) null,
        WO_NAM_WON_ID int null,
        WO_USR_WO_ID int null,
        WO_USR_WIU_WorkInvocationUser varchar(555) null,
        WO_USR_WIU_ID smallint null,
        WO_ROL_WO_ID int null,
        WO_ROL_WIR_WorkInvocationRole varchar(42) null,
        WO_ROL_WIR_ID smallint null,
        WO_EST_WO_ID int null,
        WO_EST_ChangedAt datetime2(7) null,
        WO_EST_EST_ExecutionStatus varchar(42) null,
        WO_EST_EST_ID tinyint null,
        WO_ERL_WO_ID int null,
        WO_ERL_Work_ErrorLine int null,
        WO_ERM_WO_ID int null,
        WO_ERM_Work_ErrorMessage varchar(555) null,
        WO_AID_WO_ID int null,
        WO_AID_Work_AgentStepId smallint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.WO_ID, a.WO_ID),
        ISNULL(ISNULL(i.WO_STA_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_STA_Work_Start,
        ISNULL(ISNULL(i.WO_END_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_END_Work_End,
        ISNULL(ISNULL(i.WO_NAM_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_NAM_WON_WorkName,
        i.WO_NAM_WON_ID,
        ISNULL(ISNULL(i.WO_USR_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_USR_WIU_WorkInvocationUser,
        i.WO_USR_WIU_ID,
        ISNULL(ISNULL(i.WO_ROL_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_ROL_WIR_WorkInvocationRole,
        i.WO_ROL_WIR_ID,
        ISNULL(ISNULL(i.WO_EST_WO_ID, i.WO_ID), a.WO_ID),
        ISNULL(i.WO_EST_ChangedAt, @now),
        i.WO_EST_EST_ExecutionStatus,
        i.WO_EST_EST_ID,
        ISNULL(ISNULL(i.WO_ERL_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_ERL_Work_ErrorLine,
        ISNULL(ISNULL(i.WO_ERM_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_ERM_Work_ErrorMessage,
        ISNULL(ISNULL(i.WO_AID_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_AID_Work_AgentStepId
    FROM (
        SELECT
            WO_ID,
            WO_STA_WO_ID,
            WO_STA_Work_Start,
            WO_END_WO_ID,
            WO_END_Work_End,
            WO_NAM_WO_ID,
            WO_NAM_WON_WorkName,
            WO_NAM_WON_ID,
            WO_USR_WO_ID,
            WO_USR_WIU_WorkInvocationUser,
            WO_USR_WIU_ID,
            WO_ROL_WO_ID,
            WO_ROL_WIR_WorkInvocationRole,
            WO_ROL_WIR_ID,
            WO_EST_WO_ID,
            WO_EST_ChangedAt,
            WO_EST_EST_ExecutionStatus,
            WO_EST_EST_ID,
            WO_ERL_WO_ID,
            WO_ERL_Work_ErrorLine,
            WO_ERM_WO_ID,
            WO_ERM_Work_ErrorMessage,
            WO_AID_WO_ID,
            WO_AID_Work_AgentStepId,
            ROW_NUMBER() OVER (PARTITION BY WO_ID ORDER BY WO_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @WO a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[WO_STA_Work_Start] (
        WO_STA_WO_ID,
        WO_STA_Work_Start
    )
    SELECT DISTINCT
        i.WO_STA_WO_ID,
        i.WO_STA_Work_Start
    FROM
        @inserted i
    WHERE
        i.WO_STA_Work_Start is not null;
    INSERT INTO [metadata].[WO_END_Work_End] (
        WO_END_WO_ID,
        WO_END_Work_End
    )
    SELECT DISTINCT
        i.WO_END_WO_ID,
        i.WO_END_Work_End
    FROM
        @inserted i
    WHERE
        i.WO_END_Work_End is not null;
    INSERT INTO [metadata].[WO_NAM_Work_Name] (
        WO_NAM_WO_ID,
        WO_NAM_WON_ID
    )
    SELECT DISTINCT
        i.WO_NAM_WO_ID,
        ISNULL(i.WO_NAM_WON_ID, [kWON].WON_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[WON_WorkName] [kWON]
    ON
        [kWON].WON_WorkName = i.WO_NAM_WON_WorkName
    WHERE
        ISNULL(i.WO_NAM_WON_ID, [kWON].WON_ID) is not null;
    INSERT INTO [metadata].[WO_USR_Work_InvocationUser] (
        WO_USR_WO_ID,
        WO_USR_WIU_ID
    )
    SELECT DISTINCT
        i.WO_USR_WO_ID,
        ISNULL(i.WO_USR_WIU_ID, [kWIU].WIU_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[WIU_WorkInvocationUser] [kWIU]
    ON
        [kWIU].WIU_WorkInvocationUser = i.WO_USR_WIU_WorkInvocationUser
    WHERE
        ISNULL(i.WO_USR_WIU_ID, [kWIU].WIU_ID) is not null;
    INSERT INTO [metadata].[WO_ROL_Work_InvocationRole] (
        WO_ROL_WO_ID,
        WO_ROL_WIR_ID
    )
    SELECT DISTINCT
        i.WO_ROL_WO_ID,
        ISNULL(i.WO_ROL_WIR_ID, [kWIR].WIR_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[WIR_WorkInvocationRole] [kWIR]
    ON
        [kWIR].WIR_WorkInvocationRole = i.WO_ROL_WIR_WorkInvocationRole
    WHERE
        ISNULL(i.WO_ROL_WIR_ID, [kWIR].WIR_ID) is not null;
    INSERT INTO [metadata].[WO_EST_Work_ExecutionStatus] (
        WO_EST_WO_ID,
        WO_EST_ChangedAt,
        WO_EST_EST_ID
    )
    SELECT DISTINCT
        i.WO_EST_WO_ID,
        i.WO_EST_ChangedAt,
        ISNULL(i.WO_EST_EST_ID, [kEST].EST_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[EST_ExecutionStatus] [kEST]
    ON
        [kEST].EST_ExecutionStatus = i.WO_EST_EST_ExecutionStatus
    WHERE
        ISNULL(i.WO_EST_EST_ID, [kEST].EST_ID) is not null;
    INSERT INTO [metadata].[WO_ERL_Work_ErrorLine] (
        WO_ERL_WO_ID,
        WO_ERL_Work_ErrorLine
    )
    SELECT DISTINCT
        i.WO_ERL_WO_ID,
        i.WO_ERL_Work_ErrorLine
    FROM
        @inserted i
    WHERE
        i.WO_ERL_Work_ErrorLine is not null;
    INSERT INTO [metadata].[WO_ERM_Work_ErrorMessage] (
        WO_ERM_WO_ID,
        WO_ERM_Work_ErrorMessage
    )
    SELECT DISTINCT
        i.WO_ERM_WO_ID,
        i.WO_ERM_Work_ErrorMessage
    FROM
        @inserted i
    WHERE
        i.WO_ERM_Work_ErrorMessage is not null;
    INSERT INTO [metadata].[WO_AID_Work_AgentStepId] (
        WO_AID_WO_ID,
        WO_AID_Work_AgentStepId
    )
    SELECT DISTINCT
        i.WO_AID_WO_ID,
        i.WO_AID_Work_AgentStepId
    FROM
        @inserted i
    WHERE
        i.WO_AID_Work_AgentStepId is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lWO_Work instead of UPDATE trigger on lWO_Work
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lWO_Work] ON [metadata].[lWO_Work]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    IF(UPDATE(WO_ID))
        RAISERROR('The identity column WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_STA_WO_ID))
        RAISERROR('The foreign key column WO_STA_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_STA_Work_Start))
    BEGIN
        INSERT INTO [metadata].[WO_STA_Work_Start] (
            WO_STA_WO_ID,
            WO_STA_Work_Start
        )
        SELECT DISTINCT
            ISNULL(i.WO_STA_WO_ID, i.WO_ID),
            i.WO_STA_Work_Start
        FROM
            inserted i
        WHERE
            i.WO_STA_Work_Start is not null;
    END
    IF(UPDATE(WO_END_WO_ID))
        RAISERROR('The foreign key column WO_END_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_END_Work_End))
    BEGIN
        INSERT INTO [metadata].[WO_END_Work_End] (
            WO_END_WO_ID,
            WO_END_Work_End
        )
        SELECT DISTINCT
            ISNULL(i.WO_END_WO_ID, i.WO_ID),
            i.WO_END_Work_End
        FROM
            inserted i
        WHERE
            i.WO_END_Work_End is not null;
    END
    IF(UPDATE(WO_NAM_WO_ID))
        RAISERROR('The foreign key column WO_NAM_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_NAM_WON_ID) OR UPDATE(WO_NAM_WON_WorkName))
    BEGIN
        INSERT INTO [metadata].[WO_NAM_Work_Name] (
            WO_NAM_WO_ID,
            WO_NAM_WON_ID
        )
        SELECT DISTINCT
            ISNULL(i.WO_NAM_WO_ID, i.WO_ID),
            CASE WHEN UPDATE(WO_NAM_WON_ID) THEN i.WO_NAM_WON_ID ELSE [kWON].WON_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[WON_WorkName] [kWON]
        ON
            [kWON].WON_WorkName = i.WO_NAM_WON_WorkName
        WHERE
            CASE WHEN UPDATE(WO_NAM_WON_ID) THEN i.WO_NAM_WON_ID ELSE [kWON].WON_ID END is not null;
    END
    IF(UPDATE(WO_USR_WO_ID))
        RAISERROR('The foreign key column WO_USR_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_USR_WIU_ID) OR UPDATE(WO_USR_WIU_WorkInvocationUser))
    BEGIN
        INSERT INTO [metadata].[WO_USR_Work_InvocationUser] (
            WO_USR_WO_ID,
            WO_USR_WIU_ID
        )
        SELECT DISTINCT
            ISNULL(i.WO_USR_WO_ID, i.WO_ID),
            CASE WHEN UPDATE(WO_USR_WIU_ID) THEN i.WO_USR_WIU_ID ELSE [kWIU].WIU_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[WIU_WorkInvocationUser] [kWIU]
        ON
            [kWIU].WIU_WorkInvocationUser = i.WO_USR_WIU_WorkInvocationUser
        WHERE
            CASE WHEN UPDATE(WO_USR_WIU_ID) THEN i.WO_USR_WIU_ID ELSE [kWIU].WIU_ID END is not null;
    END
    IF(UPDATE(WO_ROL_WO_ID))
        RAISERROR('The foreign key column WO_ROL_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_ROL_WIR_ID) OR UPDATE(WO_ROL_WIR_WorkInvocationRole))
    BEGIN
        INSERT INTO [metadata].[WO_ROL_Work_InvocationRole] (
            WO_ROL_WO_ID,
            WO_ROL_WIR_ID
        )
        SELECT DISTINCT
            ISNULL(i.WO_ROL_WO_ID, i.WO_ID),
            CASE WHEN UPDATE(WO_ROL_WIR_ID) THEN i.WO_ROL_WIR_ID ELSE [kWIR].WIR_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[WIR_WorkInvocationRole] [kWIR]
        ON
            [kWIR].WIR_WorkInvocationRole = i.WO_ROL_WIR_WorkInvocationRole
        WHERE
            CASE WHEN UPDATE(WO_ROL_WIR_ID) THEN i.WO_ROL_WIR_ID ELSE [kWIR].WIR_ID END is not null;
    END
    IF(UPDATE(WO_EST_WO_ID))
        RAISERROR('The foreign key column WO_EST_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_EST_EST_ID) OR UPDATE(WO_EST_EST_ExecutionStatus))
    BEGIN
        INSERT INTO [metadata].[WO_EST_Work_ExecutionStatus] (
            WO_EST_WO_ID,
            WO_EST_ChangedAt,
            WO_EST_EST_ID
        )
        SELECT DISTINCT
            ISNULL(i.WO_EST_WO_ID, i.WO_ID),
            cast(ISNULL(CASE
                WHEN i.WO_EST_EST_ID is null AND [kEST].EST_ID is null THEN i.WO_EST_ChangedAt
                WHEN UPDATE(WO_EST_ChangedAt) THEN i.WO_EST_ChangedAt
            END, @now) as datetime2(7)),
            CASE WHEN UPDATE(WO_EST_EST_ID) THEN i.WO_EST_EST_ID ELSE [kEST].EST_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[EST_ExecutionStatus] [kEST]
        ON
            [kEST].EST_ExecutionStatus = i.WO_EST_EST_ExecutionStatus
        WHERE
            CASE WHEN UPDATE(WO_EST_EST_ID) THEN i.WO_EST_EST_ID ELSE [kEST].EST_ID END is not null;
    END
    IF(UPDATE(WO_ERL_WO_ID))
        RAISERROR('The foreign key column WO_ERL_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_ERL_Work_ErrorLine))
    BEGIN
        INSERT INTO [metadata].[WO_ERL_Work_ErrorLine] (
            WO_ERL_WO_ID,
            WO_ERL_Work_ErrorLine
        )
        SELECT DISTINCT
            ISNULL(i.WO_ERL_WO_ID, i.WO_ID),
            i.WO_ERL_Work_ErrorLine
        FROM
            inserted i
        WHERE
            i.WO_ERL_Work_ErrorLine is not null;
    END
    IF(UPDATE(WO_ERM_WO_ID))
        RAISERROR('The foreign key column WO_ERM_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_ERM_Work_ErrorMessage))
    BEGIN
        INSERT INTO [metadata].[WO_ERM_Work_ErrorMessage] (
            WO_ERM_WO_ID,
            WO_ERM_Work_ErrorMessage
        )
        SELECT DISTINCT
            ISNULL(i.WO_ERM_WO_ID, i.WO_ID),
            i.WO_ERM_Work_ErrorMessage
        FROM
            inserted i
        WHERE
            i.WO_ERM_Work_ErrorMessage is not null;
    END
    IF(UPDATE(WO_AID_WO_ID))
        RAISERROR('The foreign key column WO_AID_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_AID_Work_AgentStepId))
    BEGIN
        INSERT INTO [metadata].[WO_AID_Work_AgentStepId] (
            WO_AID_WO_ID,
            WO_AID_Work_AgentStepId
        )
        SELECT DISTINCT
            ISNULL(i.WO_AID_WO_ID, i.WO_ID),
            i.WO_AID_Work_AgentStepId
        FROM
            inserted i
        WHERE
            i.WO_AID_Work_AgentStepId is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lWO_Work instead of DELETE trigger on lWO_Work
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lWO_Work] ON [metadata].[lWO_Work]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [STA]
    FROM
        [metadata].[WO_STA_Work_Start] [STA]
    JOIN
        deleted d
    ON
        d.WO_STA_WO_ID = [STA].WO_STA_WO_ID;
    DELETE [END]
    FROM
        [metadata].[WO_END_Work_End] [END]
    JOIN
        deleted d
    ON
        d.WO_END_WO_ID = [END].WO_END_WO_ID;
    DELETE [NAM]
    FROM
        [metadata].[WO_NAM_Work_Name] [NAM]
    JOIN
        deleted d
    ON
        d.WO_NAM_WO_ID = [NAM].WO_NAM_WO_ID;
    DELETE [USR]
    FROM
        [metadata].[WO_USR_Work_InvocationUser] [USR]
    JOIN
        deleted d
    ON
        d.WO_USR_WO_ID = [USR].WO_USR_WO_ID;
    DELETE [ROL]
    FROM
        [metadata].[WO_ROL_Work_InvocationRole] [ROL]
    JOIN
        deleted d
    ON
        d.WO_ROL_WO_ID = [ROL].WO_ROL_WO_ID;
    DELETE [EST]
    FROM
        [metadata].[WO_EST_Work_ExecutionStatus] [EST]
    JOIN
        deleted d
    ON
        d.WO_EST_ChangedAt = [EST].WO_EST_ChangedAt
    AND
        d.WO_EST_WO_ID = [EST].WO_EST_WO_ID;
    DELETE [ERL]
    FROM
        [metadata].[WO_ERL_Work_ErrorLine] [ERL]
    JOIN
        deleted d
    ON
        d.WO_ERL_WO_ID = [ERL].WO_ERL_WO_ID;
    DELETE [ERM]
    FROM
        [metadata].[WO_ERM_Work_ErrorMessage] [ERM]
    JOIN
        deleted d
    ON
        d.WO_ERM_WO_ID = [ERM].WO_ERM_WO_ID;
    DELETE [AID]
    FROM
        [metadata].[WO_AID_Work_AgentStepId] [AID]
    JOIN
        deleted d
    ON
        d.WO_AID_WO_ID = [AID].WO_AID_WO_ID;
    DECLARE @deleted TABLE (
        WO_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (WO_ID)
    SELECT a.WO_ID
    FROM (
        SELECT [WO].WO_ID
        FROM [metadata].[WO_Work] [WO] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 WO_STA_WO_ID
            FROM [metadata].[WO_STA_Work_Start] WITH(NOLOCK)
            WHERE WO_STA_WO_ID = [WO].WO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 WO_END_WO_ID
            FROM [metadata].[WO_END_Work_End] WITH(NOLOCK)
            WHERE WO_END_WO_ID = [WO].WO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 WO_NAM_WO_ID
            FROM [metadata].[WO_NAM_Work_Name] WITH(NOLOCK)
            WHERE WO_NAM_WO_ID = [WO].WO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 WO_USR_WO_ID
            FROM [metadata].[WO_USR_Work_InvocationUser] WITH(NOLOCK)
            WHERE WO_USR_WO_ID = [WO].WO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 WO_ROL_WO_ID
            FROM [metadata].[WO_ROL_Work_InvocationRole] WITH(NOLOCK)
            WHERE WO_ROL_WO_ID = [WO].WO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 WO_EST_WO_ID
            FROM [metadata].[WO_EST_Work_ExecutionStatus] WITH(NOLOCK)
            WHERE WO_EST_WO_ID = [WO].WO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 WO_ERL_WO_ID
            FROM [metadata].[WO_ERL_Work_ErrorLine] WITH(NOLOCK)
            WHERE WO_ERL_WO_ID = [WO].WO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 WO_ERM_WO_ID
            FROM [metadata].[WO_ERM_Work_ErrorMessage] WITH(NOLOCK)
            WHERE WO_ERM_WO_ID = [WO].WO_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 WO_AID_WO_ID
            FROM [metadata].[WO_AID_Work_AgentStepId] WITH(NOLOCK)
            WHERE WO_AID_WO_ID = [WO].WO_ID
        )
    ) a
    JOIN deleted d
    ON d.WO_ID = a.WO_ID;
    DELETE [WO]
    FROM [metadata].[WO_Work] [WO]
    JOIN @deleted d
    ON d.WO_ID = [WO].WO_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lCF_Configuration instead of INSERT trigger on lCF_Configuration
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lCF_Configuration] ON [metadata].[lCF_Configuration]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @CF TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        CF_ID int not null
    );
    INSERT INTO [metadata].[CF_Configuration] (
        CF_Dummy
    )
    OUTPUT
        inserted.CF_ID
    INTO
        @CF
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.CF_ID is null;
    DECLARE @inserted TABLE (
        CF_ID int not null,
        CF_NAM_CF_ID int null,
        CF_NAM_Configuration_Name varchar(255) null,
        CF_XML_CF_ID int null,
        CF_XML_ChangedAt datetime null,
        CF_XML_Configuration_XMLDefinition xml null,
        CF_TYP_CF_ID int null,
        CF_TYP_CFT_ConfigurationType varchar(42) null,
        CF_TYP_CFT_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.CF_ID, a.CF_ID),
        ISNULL(ISNULL(i.CF_NAM_CF_ID, i.CF_ID), a.CF_ID),
        i.CF_NAM_Configuration_Name,
        ISNULL(ISNULL(i.CF_XML_CF_ID, i.CF_ID), a.CF_ID),
        ISNULL(i.CF_XML_ChangedAt, @now),
        i.CF_XML_Configuration_XMLDefinition,
        ISNULL(ISNULL(i.CF_TYP_CF_ID, i.CF_ID), a.CF_ID),
        i.CF_TYP_CFT_ConfigurationType,
        i.CF_TYP_CFT_ID
    FROM (
        SELECT
            CF_ID,
            CF_NAM_CF_ID,
            CF_NAM_Configuration_Name,
            CF_XML_CF_ID,
            CF_XML_ChangedAt,
            CF_XML_Configuration_XMLDefinition,
            CF_TYP_CF_ID,
            CF_TYP_CFT_ConfigurationType,
            CF_TYP_CFT_ID,
            ROW_NUMBER() OVER (PARTITION BY CF_ID ORDER BY CF_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @CF a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[CF_NAM_Configuration_Name] (
        CF_NAM_CF_ID,
        CF_NAM_Configuration_Name
    )
    SELECT DISTINCT
        i.CF_NAM_CF_ID,
        i.CF_NAM_Configuration_Name
    FROM
        @inserted i
    WHERE
        i.CF_NAM_Configuration_Name is not null;
    INSERT INTO [metadata].[CF_XML_Configuration_XMLDefinition] (
        CF_XML_CF_ID,
        CF_XML_ChangedAt,
        CF_XML_Configuration_XMLDefinition
    )
    SELECT 
        i.CF_XML_CF_ID,
        i.CF_XML_ChangedAt,
        i.CF_XML_Configuration_XMLDefinition
    FROM
        @inserted i
    WHERE
        i.CF_XML_Configuration_XMLDefinition is not null;
    INSERT INTO [metadata].[CF_TYP_Configuration_Type] (
        CF_TYP_CF_ID,
        CF_TYP_CFT_ID
    )
    SELECT DISTINCT
        i.CF_TYP_CF_ID,
        ISNULL(i.CF_TYP_CFT_ID, [kCFT].CFT_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[CFT_ConfigurationType] [kCFT]
    ON
        [kCFT].CFT_ConfigurationType = i.CF_TYP_CFT_ConfigurationType
    WHERE
        ISNULL(i.CF_TYP_CFT_ID, [kCFT].CFT_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lCF_Configuration instead of UPDATE trigger on lCF_Configuration
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lCF_Configuration] ON [metadata].[lCF_Configuration]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    IF(UPDATE(CF_ID))
        RAISERROR('The identity column CF_ID is not updatable.', 16, 1);
    IF(UPDATE(CF_NAM_CF_ID))
        RAISERROR('The foreign key column CF_NAM_CF_ID is not updatable.', 16, 1);
    IF(UPDATE(CF_NAM_Configuration_Name))
    BEGIN
        INSERT INTO [metadata].[CF_NAM_Configuration_Name] (
            CF_NAM_CF_ID,
            CF_NAM_Configuration_Name
        )
        SELECT DISTINCT
            ISNULL(i.CF_NAM_CF_ID, i.CF_ID),
            i.CF_NAM_Configuration_Name
        FROM
            inserted i
        WHERE
            i.CF_NAM_Configuration_Name is not null;
    END
    IF(UPDATE(CF_XML_CF_ID))
        RAISERROR('The foreign key column CF_XML_CF_ID is not updatable.', 16, 1);
    IF(UPDATE(CF_XML_Configuration_XMLDefinition))
    BEGIN
        INSERT INTO [metadata].[CF_XML_Configuration_XMLDefinition] (
            CF_XML_CF_ID,
            CF_XML_ChangedAt,
            CF_XML_Configuration_XMLDefinition
        )
        SELECT 
            ISNULL(i.CF_XML_CF_ID, i.CF_ID),
            cast(ISNULL(CASE
                WHEN i.CF_XML_Configuration_XMLDefinition is null THEN i.CF_XML_ChangedAt
                WHEN UPDATE(CF_XML_ChangedAt) THEN i.CF_XML_ChangedAt
            END, @now) as datetime),
            i.CF_XML_Configuration_XMLDefinition
        FROM
            inserted i
        WHERE
            i.CF_XML_Configuration_XMLDefinition is not null;
    END
    IF(UPDATE(CF_TYP_CF_ID))
        RAISERROR('The foreign key column CF_TYP_CF_ID is not updatable.', 16, 1);
    IF(UPDATE(CF_TYP_CFT_ID) OR UPDATE(CF_TYP_CFT_ConfigurationType))
    BEGIN
        INSERT INTO [metadata].[CF_TYP_Configuration_Type] (
            CF_TYP_CF_ID,
            CF_TYP_CFT_ID
        )
        SELECT DISTINCT
            ISNULL(i.CF_TYP_CF_ID, i.CF_ID),
            CASE WHEN UPDATE(CF_TYP_CFT_ID) THEN i.CF_TYP_CFT_ID ELSE [kCFT].CFT_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[CFT_ConfigurationType] [kCFT]
        ON
            [kCFT].CFT_ConfigurationType = i.CF_TYP_CFT_ConfigurationType
        WHERE
            CASE WHEN UPDATE(CF_TYP_CFT_ID) THEN i.CF_TYP_CFT_ID ELSE [kCFT].CFT_ID END is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lCF_Configuration instead of DELETE trigger on lCF_Configuration
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lCF_Configuration] ON [metadata].[lCF_Configuration]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [metadata].[CF_NAM_Configuration_Name] [NAM]
    JOIN
        deleted d
    ON
        d.CF_NAM_CF_ID = [NAM].CF_NAM_CF_ID;
    DELETE [XML]
    FROM
        [metadata].[CF_XML_Configuration_XMLDefinition] [XML]
    JOIN
        deleted d
    ON
        d.CF_XML_ChangedAt = [XML].CF_XML_ChangedAt
    AND
        d.CF_XML_CF_ID = [XML].CF_XML_CF_ID;
    DELETE [TYP]
    FROM
        [metadata].[CF_TYP_Configuration_Type] [TYP]
    JOIN
        deleted d
    ON
        d.CF_TYP_CF_ID = [TYP].CF_TYP_CF_ID;
    DECLARE @deleted TABLE (
        CF_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (CF_ID)
    SELECT a.CF_ID
    FROM (
        SELECT [CF].CF_ID
        FROM [metadata].[CF_Configuration] [CF] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 CF_NAM_CF_ID
            FROM [metadata].[CF_NAM_Configuration_Name] WITH(NOLOCK)
            WHERE CF_NAM_CF_ID = [CF].CF_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 CF_XML_CF_ID
            FROM [metadata].[CF_XML_Configuration_XMLDefinition] WITH(NOLOCK)
            WHERE CF_XML_CF_ID = [CF].CF_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 CF_TYP_CF_ID
            FROM [metadata].[CF_TYP_Configuration_Type] WITH(NOLOCK)
            WHERE CF_TYP_CF_ID = [CF].CF_ID
        )
    ) a
    JOIN deleted d
    ON d.CF_ID = a.CF_ID;
    DELETE [CF]
    FROM [metadata].[CF_Configuration] [CF]
    JOIN @deleted d
    ON d.CF_ID = [CF].CF_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOP_Operations instead of INSERT trigger on lOP_Operations
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lOP_Operations] ON [metadata].[lOP_Operations]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    DECLARE @OP TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        OP_ID int not null
    );
    INSERT INTO [metadata].[OP_Operations] (
        OP_Dummy
    )
    OUTPUT
        inserted.OP_ID
    INTO
        @OP
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.OP_ID is null;
    DECLARE @inserted TABLE (
        OP_ID int not null,
        OP_INS_OP_ID int null,
        OP_INS_ChangedAt datetime2(7) null,
        OP_INS_Operations_Inserts int null,
        OP_UPD_OP_ID int null,
        OP_UPD_ChangedAt datetime2(7) null,
        OP_UPD_Operations_Updates int null,
        OP_DEL_OP_ID int null,
        OP_DEL_ChangedAt datetime2(7) null,
        OP_DEL_Operations_Deletes int null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.OP_ID, a.OP_ID),
        ISNULL(ISNULL(i.OP_INS_OP_ID, i.OP_ID), a.OP_ID),
        ISNULL(i.OP_INS_ChangedAt, @now),
        i.OP_INS_Operations_Inserts,
        ISNULL(ISNULL(i.OP_UPD_OP_ID, i.OP_ID), a.OP_ID),
        ISNULL(i.OP_UPD_ChangedAt, @now),
        i.OP_UPD_Operations_Updates,
        ISNULL(ISNULL(i.OP_DEL_OP_ID, i.OP_ID), a.OP_ID),
        ISNULL(i.OP_DEL_ChangedAt, @now),
        i.OP_DEL_Operations_Deletes
    FROM (
        SELECT
            OP_ID,
            OP_INS_OP_ID,
            OP_INS_ChangedAt,
            OP_INS_Operations_Inserts,
            OP_UPD_OP_ID,
            OP_UPD_ChangedAt,
            OP_UPD_Operations_Updates,
            OP_DEL_OP_ID,
            OP_DEL_ChangedAt,
            OP_DEL_Operations_Deletes,
            ROW_NUMBER() OVER (PARTITION BY OP_ID ORDER BY OP_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @OP a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[OP_INS_Operations_Inserts] (
        OP_INS_OP_ID,
        OP_INS_ChangedAt,
        OP_INS_Operations_Inserts
    )
    SELECT DISTINCT
        i.OP_INS_OP_ID,
        i.OP_INS_ChangedAt,
        i.OP_INS_Operations_Inserts
    FROM
        @inserted i
    WHERE
        i.OP_INS_Operations_Inserts is not null;
    INSERT INTO [metadata].[OP_UPD_Operations_Updates] (
        OP_UPD_OP_ID,
        OP_UPD_ChangedAt,
        OP_UPD_Operations_Updates
    )
    SELECT DISTINCT
        i.OP_UPD_OP_ID,
        i.OP_UPD_ChangedAt,
        i.OP_UPD_Operations_Updates
    FROM
        @inserted i
    WHERE
        i.OP_UPD_Operations_Updates is not null;
    INSERT INTO [metadata].[OP_DEL_Operations_Deletes] (
        OP_DEL_OP_ID,
        OP_DEL_ChangedAt,
        OP_DEL_Operations_Deletes
    )
    SELECT DISTINCT
        i.OP_DEL_OP_ID,
        i.OP_DEL_ChangedAt,
        i.OP_DEL_Operations_Deletes
    FROM
        @inserted i
    WHERE
        i.OP_DEL_Operations_Deletes is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOP_Operations instead of UPDATE trigger on lOP_Operations
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lOP_Operations] ON [metadata].[lOP_Operations]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    IF(UPDATE(OP_ID))
        RAISERROR('The identity column OP_ID is not updatable.', 16, 1);
    IF(UPDATE(OP_INS_OP_ID))
        RAISERROR('The foreign key column OP_INS_OP_ID is not updatable.', 16, 1);
    IF(UPDATE(OP_INS_Operations_Inserts))
    BEGIN
        INSERT INTO [metadata].[OP_INS_Operations_Inserts] (
            OP_INS_OP_ID,
            OP_INS_ChangedAt,
            OP_INS_Operations_Inserts
        )
        SELECT DISTINCT
            ISNULL(i.OP_INS_OP_ID, i.OP_ID),
            cast(ISNULL(CASE
                WHEN i.OP_INS_Operations_Inserts is null THEN i.OP_INS_ChangedAt
                WHEN UPDATE(OP_INS_ChangedAt) THEN i.OP_INS_ChangedAt
            END, @now) as datetime2(7)),
            i.OP_INS_Operations_Inserts
        FROM
            inserted i
        WHERE
            i.OP_INS_Operations_Inserts is not null;
    END
    IF(UPDATE(OP_UPD_OP_ID))
        RAISERROR('The foreign key column OP_UPD_OP_ID is not updatable.', 16, 1);
    IF(UPDATE(OP_UPD_Operations_Updates))
    BEGIN
        INSERT INTO [metadata].[OP_UPD_Operations_Updates] (
            OP_UPD_OP_ID,
            OP_UPD_ChangedAt,
            OP_UPD_Operations_Updates
        )
        SELECT DISTINCT
            ISNULL(i.OP_UPD_OP_ID, i.OP_ID),
            cast(ISNULL(CASE
                WHEN i.OP_UPD_Operations_Updates is null THEN i.OP_UPD_ChangedAt
                WHEN UPDATE(OP_UPD_ChangedAt) THEN i.OP_UPD_ChangedAt
            END, @now) as datetime2(7)),
            i.OP_UPD_Operations_Updates
        FROM
            inserted i
        WHERE
            i.OP_UPD_Operations_Updates is not null;
    END
    IF(UPDATE(OP_DEL_OP_ID))
        RAISERROR('The foreign key column OP_DEL_OP_ID is not updatable.', 16, 1);
    IF(UPDATE(OP_DEL_Operations_Deletes))
    BEGIN
        INSERT INTO [metadata].[OP_DEL_Operations_Deletes] (
            OP_DEL_OP_ID,
            OP_DEL_ChangedAt,
            OP_DEL_Operations_Deletes
        )
        SELECT DISTINCT
            ISNULL(i.OP_DEL_OP_ID, i.OP_ID),
            cast(ISNULL(CASE
                WHEN i.OP_DEL_Operations_Deletes is null THEN i.OP_DEL_ChangedAt
                WHEN UPDATE(OP_DEL_ChangedAt) THEN i.OP_DEL_ChangedAt
            END, @now) as datetime2(7)),
            i.OP_DEL_Operations_Deletes
        FROM
            inserted i
        WHERE
            i.OP_DEL_Operations_Deletes is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOP_Operations instead of DELETE trigger on lOP_Operations
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lOP_Operations] ON [metadata].[lOP_Operations]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [INS]
    FROM
        [metadata].[OP_INS_Operations_Inserts] [INS]
    JOIN
        deleted d
    ON
        d.OP_INS_ChangedAt = [INS].OP_INS_ChangedAt
    AND
        d.OP_INS_OP_ID = [INS].OP_INS_OP_ID;
    DELETE [UPD]
    FROM
        [metadata].[OP_UPD_Operations_Updates] [UPD]
    JOIN
        deleted d
    ON
        d.OP_UPD_ChangedAt = [UPD].OP_UPD_ChangedAt
    AND
        d.OP_UPD_OP_ID = [UPD].OP_UPD_OP_ID;
    DELETE [DEL]
    FROM
        [metadata].[OP_DEL_Operations_Deletes] [DEL]
    JOIN
        deleted d
    ON
        d.OP_DEL_ChangedAt = [DEL].OP_DEL_ChangedAt
    AND
        d.OP_DEL_OP_ID = [DEL].OP_DEL_OP_ID;
    DECLARE @deleted TABLE (
        OP_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (OP_ID)
    SELECT a.OP_ID
    FROM (
        SELECT [OP].OP_ID
        FROM [metadata].[OP_Operations] [OP] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 OP_INS_OP_ID
            FROM [metadata].[OP_INS_Operations_Inserts] WITH(NOLOCK)
            WHERE OP_INS_OP_ID = [OP].OP_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 OP_UPD_OP_ID
            FROM [metadata].[OP_UPD_Operations_Updates] WITH(NOLOCK)
            WHERE OP_UPD_OP_ID = [OP].OP_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 OP_DEL_OP_ID
            FROM [metadata].[OP_DEL_Operations_Deletes] WITH(NOLOCK)
            WHERE OP_DEL_OP_ID = [OP].OP_ID
        )
    ) a
    JOIN deleted d
    ON d.OP_ID = a.OP_ID;
    DELETE [OP]
    FROM [metadata].[OP_Operations] [OP]
    JOIN @deleted d
    ON d.OP_ID = [OP].OP_ID;
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
IF Object_ID('metadata.dWO_part_JB_of', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dWO_part_JB_of];
IF Object_ID('metadata.nWO_part_JB_of', 'V') IS NOT NULL
DROP VIEW [metadata].[nWO_part_JB_of];
IF Object_ID('metadata.pWO_part_JB_of', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pWO_part_JB_of];
IF Object_ID('metadata.lWO_part_JB_of', 'V') IS NOT NULL
DROP VIEW [metadata].[lWO_part_JB_of];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lWO_part_JB_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lWO_part_JB_of] WITH SCHEMABINDING AS
SELECT
    tie.WO_ID_part,
    tie.JB_ID_of
FROM
    [metadata].[WO_part_JB_of] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pWO_part_JB_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pWO_part_JB_of] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.WO_ID_part,
    tie.JB_ID_of
FROM
    [metadata].[WO_part_JB_of] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nWO_part_JB_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nWO_part_JB_of]
AS
SELECT
    *
FROM
    [metadata].[pWO_part_JB_of](sysutcdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dJB_formed_CF_from', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dJB_formed_CF_from];
IF Object_ID('metadata.nJB_formed_CF_from', 'V') IS NOT NULL
DROP VIEW [metadata].[nJB_formed_CF_from];
IF Object_ID('metadata.pJB_formed_CF_from', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pJB_formed_CF_from];
IF Object_ID('metadata.lJB_formed_CF_from', 'V') IS NOT NULL
DROP VIEW [metadata].[lJB_formed_CF_from];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lJB_formed_CF_from viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lJB_formed_CF_from] WITH SCHEMABINDING AS
SELECT
    tie.JB_ID_formed,
    tie.CF_ID_from
FROM
    [metadata].[JB_formed_CF_from] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pJB_formed_CF_from viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pJB_formed_CF_from] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.JB_ID_formed,
    tie.CF_ID_from
FROM
    [metadata].[JB_formed_CF_from] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nJB_formed_CF_from viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nJB_formed_CF_from]
AS
SELECT
    *
FROM
    [metadata].[pJB_formed_CF_from](sysutcdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dWO_operates_CO_source_CO_target_OP_with', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dWO_operates_CO_source_CO_target_OP_with];
IF Object_ID('metadata.nWO_operates_CO_source_CO_target_OP_with', 'V') IS NOT NULL
DROP VIEW [metadata].[nWO_operates_CO_source_CO_target_OP_with];
IF Object_ID('metadata.pWO_operates_CO_source_CO_target_OP_with', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pWO_operates_CO_source_CO_target_OP_with];
IF Object_ID('metadata.lWO_operates_CO_source_CO_target_OP_with', 'V') IS NOT NULL
DROP VIEW [metadata].[lWO_operates_CO_source_CO_target_OP_with];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lWO_operates_CO_source_CO_target_OP_with viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lWO_operates_CO_source_CO_target_OP_with] WITH SCHEMABINDING AS
SELECT
    tie.WO_ID_operates,
    tie.CO_ID_source,
    tie.CO_ID_target,
    tie.OP_ID_with
FROM
    [metadata].[WO_operates_CO_source_CO_target_OP_with] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pWO_operates_CO_source_CO_target_OP_with viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pWO_operates_CO_source_CO_target_OP_with] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.WO_ID_operates,
    tie.CO_ID_source,
    tie.CO_ID_target,
    tie.OP_ID_with
FROM
    [metadata].[WO_operates_CO_source_CO_target_OP_with] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nWO_operates_CO_source_CO_target_OP_with viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nWO_operates_CO_source_CO_target_OP_with]
AS
SELECT
    *
FROM
    [metadata].[pWO_operates_CO_source_CO_target_OP_with](sysutcdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dWO_formed_CF_from', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dWO_formed_CF_from];
IF Object_ID('metadata.nWO_formed_CF_from', 'V') IS NOT NULL
DROP VIEW [metadata].[nWO_formed_CF_from];
IF Object_ID('metadata.pWO_formed_CF_from', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pWO_formed_CF_from];
IF Object_ID('metadata.lWO_formed_CF_from', 'V') IS NOT NULL
DROP VIEW [metadata].[lWO_formed_CF_from];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lWO_formed_CF_from viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lWO_formed_CF_from] WITH SCHEMABINDING AS
SELECT
    tie.WO_ID_formed,
    tie.CF_ID_from
FROM
    [metadata].[WO_formed_CF_from] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pWO_formed_CF_from viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pWO_formed_CF_from] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.WO_ID_formed,
    tie.CF_ID_from
FROM
    [metadata].[WO_formed_CF_from] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nWO_formed_CF_from viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nWO_formed_CF_from]
AS
SELECT
    *
FROM
    [metadata].[pWO_formed_CF_from](sysutcdatetime());
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
-- itWO_part_JB_of instead of INSERT trigger on WO_part_JB_of
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_part_JB_of', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_part_JB_of];
GO
CREATE TRIGGER [metadata].[it_WO_part_JB_of] ON [metadata].[WO_part_JB_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [metadata].[WO_part_JB_of] (
        WO_ID_part,
        JB_ID_of
    )
    SELECT
        WO_ID_part,
        JB_ID_of
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            42
        FROM
            [metadata].[WO_part_JB_of] x
        WHERE 
            x.WO_ID_part = i.WO_ID_part
        AND
            x.JB_ID_of = i.JB_ID_of
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lWO_part_JB_of instead of INSERT trigger on lWO_part_JB_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lWO_part_JB_of] ON [metadata].[lWO_part_JB_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_part_JB_of] (
        WO_ID_part,
        JB_ID_of
    )
    SELECT
        i.WO_ID_part,
        i.JB_ID_of
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lWO_part_JB_of instead of DELETE trigger on lWO_part_JB_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lWO_part_JB_of] ON [metadata].[lWO_part_JB_of]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[WO_part_JB_of] tie
    JOIN
        deleted d
    ON
        d.WO_ID_part = tie.WO_ID_part
    AND
        d.JB_ID_of = tie.JB_ID_of;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itJB_formed_CF_from instead of INSERT trigger on JB_formed_CF_from
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_formed_CF_from', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_formed_CF_from];
GO
CREATE TRIGGER [metadata].[it_JB_formed_CF_from] ON [metadata].[JB_formed_CF_from]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [metadata].[JB_formed_CF_from] (
        JB_ID_formed,
        CF_ID_from
    )
    SELECT
        JB_ID_formed,
        CF_ID_from
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            42
        FROM
            [metadata].[JB_formed_CF_from] x
        WHERE 
            x.JB_ID_formed = i.JB_ID_formed
        AND
            x.CF_ID_from = i.CF_ID_from
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lJB_formed_CF_from instead of INSERT trigger on lJB_formed_CF_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lJB_formed_CF_from] ON [metadata].[lJB_formed_CF_from]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[JB_formed_CF_from] (
        JB_ID_formed,
        CF_ID_from
    )
    SELECT
        i.JB_ID_formed,
        i.CF_ID_from
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lJB_formed_CF_from instead of UPDATE trigger on lJB_formed_CF_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lJB_formed_CF_from] ON [metadata].[lJB_formed_CF_from]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    IF(UPDATE(JB_ID_formed))
        RAISERROR('The identity column JB_ID_formed is not updatable.', 16, 1);
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lJB_formed_CF_from instead of DELETE trigger on lJB_formed_CF_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lJB_formed_CF_from] ON [metadata].[lJB_formed_CF_from]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[JB_formed_CF_from] tie
    JOIN
        deleted d
    ON
        d.JB_ID_formed = tie.JB_ID_formed;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itWO_operates_CO_source_CO_target_OP_with instead of INSERT trigger on WO_operates_CO_source_CO_target_OP_with
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_operates_CO_source_CO_target_OP_with', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_operates_CO_source_CO_target_OP_with];
GO
CREATE TRIGGER [metadata].[it_WO_operates_CO_source_CO_target_OP_with] ON [metadata].[WO_operates_CO_source_CO_target_OP_with]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [metadata].[WO_operates_CO_source_CO_target_OP_with] (
        WO_ID_operates,
        CO_ID_source,
        CO_ID_target,
        OP_ID_with
    )
    SELECT
        WO_ID_operates,
        CO_ID_source,
        CO_ID_target,
        OP_ID_with
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            42
        FROM
            [metadata].[WO_operates_CO_source_CO_target_OP_with] x
        WHERE 
            x.WO_ID_operates = i.WO_ID_operates
        AND
            x.CO_ID_source = i.CO_ID_source
        AND
            x.CO_ID_target = i.CO_ID_target
        AND
            x.OP_ID_with = i.OP_ID_with
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lWO_operates_CO_source_CO_target_OP_with instead of INSERT trigger on lWO_operates_CO_source_CO_target_OP_with
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lWO_operates_CO_source_CO_target_OP_with] ON [metadata].[lWO_operates_CO_source_CO_target_OP_with]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_operates_CO_source_CO_target_OP_with] (
        WO_ID_operates,
        CO_ID_source,
        CO_ID_target,
        OP_ID_with
    )
    SELECT
        i.WO_ID_operates,
        i.CO_ID_source,
        i.CO_ID_target,
        i.OP_ID_with
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lWO_operates_CO_source_CO_target_OP_with instead of UPDATE trigger on lWO_operates_CO_source_CO_target_OP_with
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lWO_operates_CO_source_CO_target_OP_with] ON [metadata].[lWO_operates_CO_source_CO_target_OP_with]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    IF(UPDATE(WO_ID_operates))
        RAISERROR('The identity column WO_ID_operates is not updatable.', 16, 1);
    IF(UPDATE(CO_ID_source))
        RAISERROR('The identity column CO_ID_source is not updatable.', 16, 1);
    IF(UPDATE(CO_ID_target))
        RAISERROR('The identity column CO_ID_target is not updatable.', 16, 1);
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lWO_operates_CO_source_CO_target_OP_with instead of DELETE trigger on lWO_operates_CO_source_CO_target_OP_with
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lWO_operates_CO_source_CO_target_OP_with] ON [metadata].[lWO_operates_CO_source_CO_target_OP_with]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[WO_operates_CO_source_CO_target_OP_with] tie
    JOIN
        deleted d
    ON
        d.WO_ID_operates = tie.WO_ID_operates
    AND
        d.CO_ID_source = tie.CO_ID_source
    AND
        d.CO_ID_target = tie.CO_ID_target;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itWO_formed_CF_from instead of INSERT trigger on WO_formed_CF_from
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_formed_CF_from', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_formed_CF_from];
GO
CREATE TRIGGER [metadata].[it_WO_formed_CF_from] ON [metadata].[WO_formed_CF_from]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [metadata].[WO_formed_CF_from] (
        WO_ID_formed,
        CF_ID_from
    )
    SELECT
        WO_ID_formed,
        CF_ID_from
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT 
            42
        FROM
            [metadata].[WO_formed_CF_from] x
        WHERE 
            x.WO_ID_formed = i.WO_ID_formed
        AND
            x.CF_ID_from = i.CF_ID_from
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lWO_formed_CF_from instead of INSERT trigger on lWO_formed_CF_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lWO_formed_CF_from] ON [metadata].[lWO_formed_CF_from]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    INSERT INTO [metadata].[WO_formed_CF_from] (
        WO_ID_formed,
        CF_ID_from
    )
    SELECT
        i.WO_ID_formed,
        i.CF_ID_from
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lWO_formed_CF_from instead of UPDATE trigger on lWO_formed_CF_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lWO_formed_CF_from] ON [metadata].[lWO_formed_CF_from]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysutcdatetime();
    IF(UPDATE(WO_ID_formed))
        RAISERROR('The identity column WO_ID_formed is not updatable.', 16, 1);
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lWO_formed_CF_from instead of DELETE trigger on lWO_formed_CF_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lWO_formed_CF_from] ON [metadata].[lWO_formed_CF_from]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[WO_formed_CF_from] tie
    JOIN
        deleted d
    ON
        d.WO_ID_formed = tie.WO_ID_formed;
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
IF Object_ID('metadata._Schema', 'U') IS NULL
   CREATE TABLE [metadata].[_Schema] (
      [version] int identity(1, 1) not null,
      [activation] datetime2(7) not null,
      [schema] xml not null,
      constraint pk_Schema primary key (
         [version]
      )
   );
GO
-- Insert the XML schema (as of now)
INSERT INTO [metadata].[_Schema] (
   [activation],
   [schema]
)
SELECT
   current_timestamp,
   N'<schema format="0.99.12" date="2024-03-15" time="15:48:49"><metadata changingRange="datetime2(7)" encapsulation="metadata" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="false" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="tinyint" reliabilitySuffix="Reliability" defaultReliability="1" deleteReliability="0" assertionSuffix="Assertion" partitioning="false" entityIntegrity="true" restatability="false" idempotency="true" assertiveness="false" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2(7)" now="sysutcdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="false" decisiveness="false" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="uni" deletability="false" deletablePrefix="Deletable" deletionSuffix="Deleted" privacy="Ignore" checksum="false" triggers="true" knotAliases="false"/><knot mnemonic="COT" descriptor="ContainerType" identity="tinyint" dataRange="varchar(42)"><metadata capsule="metadata" generator="false"/><layout x="387.60" y="896.41" fixed="false"/></knot><knot mnemonic="EST" descriptor="ExecutionStatus" identity="tinyint" dataRange="varchar(42)"><metadata capsule="metadata" generator="false"/><layout x="438.52" y="150.08" fixed="false"/></knot><knot mnemonic="CFT" descriptor="ConfigurationType" identity="tinyint" dataRange="varchar(42)"><metadata capsule="metadata" generator="false"/><layout x="1005.04" y="94.19" fixed="false"/></knot><knot mnemonic="WON" descriptor="WorkName" identity="int" dataRange="varchar(255)"><metadata capsule="metadata" generator="true"/><layout x="420.96" y="498.46" fixed="false"/></knot><knot mnemonic="WIU" descriptor="WorkInvocationUser" identity="smallint" dataRange="varchar(555)"><metadata capsule="metadata" generator="true"/><layout x="385.15" y="376.34" fixed="false"/></knot><knot mnemonic="WIR" descriptor="WorkInvocationRole" identity="smallint" dataRange="varchar(42)"><metadata capsule="metadata" generator="true"/><layout x="372.45" y="456.39" fixed="false"/></knot><knot mnemonic="JON" descriptor="JobName" identity="int" dataRange="varchar(255)"><metadata capsule="metadata" generator="true"/><layout x="637.51" y="-124.90" fixed="true"/></knot><knot mnemonic="AID" descriptor="AgentJobId" identity="int" dataRange="uniqueidentifier"><metadata capsule="metadata" generator="true"/><layout x="736.51" y="-86.90" fixed="true"/></knot><anchor mnemonic="JB" descriptor="Job" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="STA" descriptor="Start" dataRange="datetime2(7)"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="501.82" y="-2.32" fixed="false"/></attribute><attribute mnemonic="END" descriptor="End" dataRange="datetime2(7)"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="537.57" y="-25.36" fixed="false"/></attribute><attribute mnemonic="NAM" descriptor="Name" knotRange="JON"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="607.51" y="-59.90" fixed="true"/></attribute><attribute mnemonic="EST" descriptor="ExecutionStatus" timeRange="datetime2(7)" knotRange="EST"><metadata privacy="Ignore" capsule="metadata" restatable="false" idempotent="true" deletable="false"/><layout x="472.56" y="44.18" fixed="false"/></attribute><attribute mnemonic="AID" descriptor="AgentJobId" knotRange="AID"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="678.51" y="-38.90" fixed="true"/></attribute><layout x="587.40" y="28.06" fixed="false"/></anchor><anchor mnemonic="CO" descriptor="Container" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(2000)"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="549.51" y="785.10" fixed="false"/></attribute><attribute mnemonic="TYP" descriptor="Type" knotRange="COT"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="420.74" y="826.77" fixed="false"/></attribute><attribute mnemonic="DSC" descriptor="Discovered" timeRange="datetime2(7)" dataRange="datetime"><metadata privacy="Ignore" capsule="metadata" restatable="false" idempotent="true" deletable="false"/><layout x="491.43" y="822.15" fixed="false"/></attribute><attribute mnemonic="CRE" descriptor="Created" dataRange="datetime"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="409.02" y="737.23" fixed="false"/></attribute><layout x="486.14" y="719.35" fixed="false"/></anchor><anchor mnemonic="WO" descriptor="Work" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="STA" descriptor="Start" dataRange="datetime2(7)"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="532.15" y="455.07" fixed="false"/></attribute><attribute mnemonic="END" descriptor="End" dataRange="datetime2(7)"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="635.32" y="448.22" fixed="false"/></attribute><attribute mnemonic="NAM" descriptor="Name" knotRange="WON"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="483.13" y="477.26" fixed="false"/></attribute><attribute mnemonic="USR" descriptor="InvocationUser" knotRange="WIU"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="450.43" y="399.49" fixed="false"/></attribute><attribute mnemonic="ROL" descriptor="InvocationRole" knotRange="WIR"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="448.49" y="437.97" fixed="false"/></attribute><attribute mnemonic="EST" descriptor="ExecutionStatus" timeRange="datetime2(7)" knotRange="EST"><metadata privacy="Ignore" capsule="metadata" restatable="false" idempotent="true" deletable="false"/><layout x="472.44" y="281.47" fixed="false"/></attribute><attribute mnemonic="ERL" descriptor="ErrorLine" dataRange="int"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="598.41" y="463.33" fixed="false"/></attribute><attribute mnemonic="ERM" descriptor="ErrorMessage" dataRange="varchar(555)"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="662.52" y="418.54" fixed="false"/></attribute><attribute mnemonic="AID" descriptor="AgentStepId" dataRange="smallint"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="648.39" y="402.32" fixed="false"/></attribute><layout x="554.62" y="403.94" fixed="false"/></anchor><anchor mnemonic="CF" descriptor="Configuration" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(255)"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="893.18" y="200.39" fixed="false"/></attribute><attribute mnemonic="XML" descriptor="XMLDefinition" timeRange="datetime" dataRange="xml"><metadata privacy="Ignore" capsule="metadata" checksum="true" restatable="false" idempotent="true" deletable="false"/><layout x="910.77" y="159.81" fixed="false"/></attribute><attribute mnemonic="TYP" descriptor="Type" knotRange="CFT"><metadata privacy="Ignore" capsule="metadata" idempotent="true" deletable="false"/><layout x="938.10" y="122.49" fixed="false"/></attribute><layout x="826.03" y="164.64" fixed="false"/></anchor><anchor mnemonic="OP" descriptor="Operations" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="INS" descriptor="Inserts" timeRange="datetime2(7)" dataRange="int"><metadata privacy="Ignore" capsule="metadata" restatable="false" idempotent="true" deletable="false"/><layout x="724.76" y="789.35" fixed="false"/></attribute><attribute mnemonic="UPD" descriptor="Updates" timeRange="datetime2(7)" dataRange="int"><metadata privacy="Ignore" capsule="metadata" restatable="false" idempotent="true" deletable="false"/><layout x="766.60" y="751.54" fixed="false"/></attribute><attribute mnemonic="DEL" descriptor="Deletes" timeRange="datetime2(7)" dataRange="int"><metadata privacy="Ignore" capsule="metadata" restatable="false" idempotent="true" deletable="false"/><layout x="789.60" y="702.18" fixed="false"/></attribute><layout x="692.65" y="695.79" fixed="false"/></anchor><tie><anchorRole role="part" type="WO" identifier="true"/><anchorRole role="of" type="JB" identifier="true"/><metadata capsule="metadata" deletable="false" idempotent="true"/><layout x="555.96" y="204.02" fixed="false"/></tie><tie><anchorRole role="formed" type="JB" identifier="true"/><anchorRole role="from" type="CF" identifier="false"/><metadata capsule="metadata" deletable="false" idempotent="true"/><layout x="735.45" y="81.40" fixed="false"/></tie><tie><anchorRole role="operates" type="WO" identifier="true"/><anchorRole role="source" type="CO" identifier="true"/><anchorRole role="target" type="CO" identifier="true"/><anchorRole role="with" type="OP" identifier="false"/><metadata capsule="metadata" deletable="false" idempotent="true"/><layout x="565.13" y="632.69" fixed="false"/></tie><tie><anchorRole role="formed" type="WO" identifier="true"/><anchorRole role="from" type="CF" identifier="false"/><metadata capsule="metadata" deletable="false" idempotent="true"/><layout x="710.86" y="289.11" fixed="false"/></tie></schema>';
GO
-- Schema expanded view -----------------------------------------------------------------------------------------------
-- A view of the schema table that expands the XML attributes into columns
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Schema_Expanded', 'V') IS NOT NULL
DROP VIEW [metadata].[_Schema_Expanded]
GO
CREATE VIEW [metadata].[_Schema_Expanded]
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
IF Object_ID('metadata._Anchor', 'V') IS NOT NULL
DROP VIEW [metadata].[_Anchor]
GO
CREATE VIEW [metadata].[_Anchor]
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
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as Nodeset(anchor);
GO
-- Knot view ----------------------------------------------------------------------------------------------------------
-- The knot view shows information about all the knots in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Knot', 'V') IS NOT NULL
DROP VIEW [metadata].[_Knot]
GO
CREATE VIEW [metadata].[_Knot]
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
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/knot') as Nodeset(knot);
GO
-- Attribute view -----------------------------------------------------------------------------------------------------
-- The attribute view shows information about all the attributes in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Attribute', 'V') IS NOT NULL
DROP VIEW [metadata].[_Attribute]
GO
CREATE VIEW [metadata].[_Attribute]
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
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as ParentNodeset(anchor)
OUTER APPLY
   ParentNodeset.anchor.nodes('attribute') as Nodeset(attribute);
GO
-- Tie view -----------------------------------------------------------------------------------------------------------
-- The tie view shows information about all the ties in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Tie', 'V') IS NOT NULL
DROP VIEW [metadata].[_Tie]
GO
CREATE VIEW [metadata].[_Tie]
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
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/tie') as Nodeset(tie);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- The key view shows information about all the keys in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Key', 'V') IS NOT NULL
DROP VIEW [metadata].[_Key]
GO
CREATE VIEW [metadata].[_Key]
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
   [metadata].[_Schema] S
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
IF Object_ID('metadata._Evolution', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[_Evolution];
GO
CREATE FUNCTION [metadata].[_Evolution] (
    @timepoint AS datetime2(7)
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
      [metadata].[_Anchor] a
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
      [metadata].[_Knot] k
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
      [metadata].[_Attribute] b
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
      [metadata].[_Tie] t
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '_Annex'), ('crt', '_Posit')
   ) s (temporalization, suffix)
), 
selectedSchema AS (
   SELECT TOP 1
      *
   FROM
      [metadata].[_Schema_Expanded]
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
IF Object_ID('metadata._GenerateDropScript', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_GenerateDropScript];
GO
CREATE PROCEDURE [metadata]._GenerateDropScript (
   @exclusionPattern varchar(42) = '%.[[][_]%', -- exclude Metadata by default
   @inclusionPattern varchar(42) = '%', -- include everything by default
   @directions varchar(42) = 'Upwards, Downwards', -- do both up and down by default
   @qualifiedName varchar(555) = null -- can specify a single object
)
AS
BEGIN
   set nocount on;
   select
      ordinal,
      unqualifiedName,
      qualifiedName
   into 
      #constructs
   from (
      select distinct
         10 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [metadata]._Attribute
      union all
      select distinct
         11 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Annex]' as qualifiedName
      from
         [metadata]._Attribute
      union all
      select distinct
         12 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Posit]' as qualifiedName
      from
         [metadata]._Attribute
      union all
      select distinct
         20 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [metadata]._Tie
      union all
      select distinct
         21 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Annex]' as qualifiedName
      from
         [metadata]._Tie
      union all
      select distinct
         22 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Posit]' as qualifiedName
      from
         [metadata]._Tie
      union all
      select distinct
         30 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [metadata]._Knot
      union all
      select distinct
         40 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [metadata]._Anchor
   ) t;
   select
      c.ordinal,
      cast(c.unqualifiedName as nvarchar(517)) as unqualifiedName,
      cast(c.qualifiedName as nvarchar(517)) as qualifiedName,
      o.[object_id],
      o.[type]
   into
      #includedConstructs
   from
      #constructs c
   join
      sys.objects o
   on
      o.[object_id] = OBJECT_ID(c.qualifiedName)
   and 
      o.[type] = 'U'
   where
      OBJECT_ID(c.qualifiedName) = OBJECT_ID(isnull(@qualifiedName, c.qualifiedName));
   create unique clustered index ix_includedConstructs on #includedConstructs([object_id]);
   select distinct
      c.[object_id],
      c.qualifiedName,
      c.unqualifiedName,
      c.[type], 
      r.referencing_id as [referenced_by_object_id],
      n.qualifiedName as referenced_qualifiedName,
      n.unqualifiedName as referenced_unqualifiedName, 
      o.[type] as referenced_type
   into 
      #referencing_entities
   from 
      #includedConstructs c
    cross apply (
        select
         refs.referencing_id
        from 
         sys.dm_sql_referencing_entities(c.qualifiedName, 'OBJECT') refs
        where
         refs.referencing_id <> OBJECT_ID(c.qualifiedName)
    ) r
   join -- select top 100 * from 
         sys.objects o
      on
         o.[object_id] = r.referencing_id
      and
         o.type not in ('S')
      join
         sys.schemas s
      on 
         s.schema_id = o.schema_id
      cross apply (
         select
            cast('[' + s.name + '].[' + o.name + ']' as nvarchar(517)),
            cast(o.name as nvarchar(517))
      ) n (qualifiedName, unqualifiedName);
   create unique clustered index pk_referencing_entities 
   on #referencing_entities ([object_id], [referenced_by_object_id]);
   declare @inserts int = 1;
   while (@inserts > 0)
   begin
      insert into #referencing_entities
      select distinct
         c.[referenced_by_object_id] as [object_id],
         c.referenced_qualifiedName as qualifiedName,
         c.referenced_unqualifiedName as unqualifiedName, 
         c.referenced_type as [type],
         r.referencing_id as [referenced_by_object_id],
         n.qualifiedName as referenced_qualifiedName, 
         n.unqualifiedName as referenced_unqualifiedName, 
         o.[type] as referenced_type
      from 
         #referencing_entities c
      outer apply (
         select
            refs.referencing_id
         from 
            sys.dm_sql_referencing_entities(c.referenced_qualifiedName, 'OBJECT') refs
         where
            refs.referencing_id <> c.referenced_by_object_id
      ) r
      left join 
         #referencing_entities x
      on 
         x.[object_id] = c.[referenced_by_object_id]
      and
         x.referenced_by_object_id = r.referencing_id
      join -- select top 100 * from 
          sys.objects o
        on
          o.[object_id] = r.referencing_id
        and
          o.type not in ('S')
        join
          sys.schemas s
        on 
          s.schema_id = o.schema_id
        cross apply (
          select
            cast('[' + s.name + '].[' + o.name + ']' as nvarchar(517)),
            cast(o.name as nvarchar(517))
        ) n (qualifiedName, unqualifiedName)
      where
         x.[object_id] is null; 
      set @inserts = @@ROWCOUNT;
   end;
   with relatedUpwards as (
      select
         c.[object_id],
         c.[type],
         c.unqualifiedName,
         c.qualifiedName,
         1 as depth
      from
         #includedConstructs c
      union all
      select
         r.referenced_by_object_id,
         r.referenced_type,
         r.referenced_unqualifiedName,
         r.referenced_qualifiedName,
         c.depth + 1 as depth
      from
         relatedUpwards c
     join 
       #referencing_entities r
     on 
        r.[object_id] = c.[object_id]
   )
   select distinct
      [object_id],
      [type],
      unqualifiedName,
      qualifiedName,
      depth
   into
      #relatedUpwards
   from
      relatedUpwards u
   where
      depth = (
         select
            MAX(depth)
         from
            relatedUpwards s
         where
            s.[object_id] = u.[object_id]
      );
   create unique clustered index ix_relatedUpwards on #relatedUpwards([object_id]);
   select distinct
      c.[object_id],
      c.qualifiedName,
      c.unqualifiedName, 
      c.[type],
      r.referenced_id as [references_object_id],
      n.qualifiedName as references_qualifiedName, 
      n.unqualifiedName as references_unqualifiedName, 
      o.[type] as references_type
   into -- drop table
      #referenced_entities
   from 
      #includedConstructs c
    cross apply (
         select 
            refs.referenced_id 
         from
            sys.dm_sql_referenced_entities(c.qualifiedName, 'OBJECT') refs
         where
            refs.referenced_minor_id = 0
         and
            refs.referenced_id <> OBJECT_ID(c.qualifiedName)
         and 
            refs.referenced_id not in (select [object_id] from #relatedUpwards)
    ) r
      join -- select top 100 * from 
          sys.objects o
        on
          o.[object_id] = r.referenced_id
        and
          o.type not in ('S')
        join
          sys.schemas s
        on 
          s.schema_id = o.schema_id
        cross apply (
          select
            cast('[' + s.name + '].[' + o.name + ']' as nvarchar(517)),
            cast(o.name as nvarchar(517))
        ) n (qualifiedName, unqualifiedName);
   create unique clustered index pk_referenced_entities 
   on #referenced_entities ([object_id], [references_object_id]);
   set @inserts = 1;
   while(@inserts > 0)
   begin
      insert into #referenced_entities
      select distinct
         c.[references_object_id] as [object_id],
         c.references_qualifiedName as qualifiedName,
         c.references_unqualifiedName as unqualifiedName,
         c.references_type as [type],
         r.referenced_id as [references_object_id],
         n.qualifiedName as references_qualifiedName, 
         n.unqualifiedName as references_unqualifiedName, 
         o.[type] as references_type
      from 
         #referenced_entities c
      cross apply (
          select 
            refs.referenced_id 
          from
            sys.dm_sql_referenced_entities(c.references_qualifiedName, 'OBJECT') refs
          where
            refs.referenced_minor_id = 0
          and
            refs.referenced_id <> c.[references_object_id]
          and 
            refs.referenced_id not in (select [object_id] from #relatedUpwards)
      ) r
      left join
         #referenced_entities x
      on 
         x.[object_id] = c.[references_object_id]
      and
         x.references_object_id = r.referenced_id
      join -- select top 100 * from 
          sys.objects o
        on
          o.[object_id] = r.referenced_id
        and
          o.type not in ('S')
        join
          sys.schemas s
        on 
          s.schema_id = o.schema_id
        cross apply (
          select
            cast('[' + s.name + '].[' + o.name + ']' as nvarchar(517)),
            cast(o.name as nvarchar(517))
        ) n (qualifiedName, unqualifiedName)
      where
         x.[object_id] is null;
      set @inserts = @@ROWCOUNT;
   end;
   with relatedDownwards as (
      select
         cast('Upwards' as varchar(42)) as [relationType],
         c.[object_id],
         c.[type],
         c.unqualifiedName, 
         c.qualifiedName,
         c.depth
      from
         #relatedUpwards c 
      union all
      select
         cast('Downwards' as varchar(42)) as [relationType],
         r.references_object_id,
         r.references_type,
         r.references_unqualifiedName, 
         r.references_qualifiedName,
         c.depth - 1 as depth
      from
         relatedDownwards c
     join
      #referenced_entities r
     on 
      r.[object_id] = c.[object_id]
   )
   select distinct
      relationType,
      [object_id],
      [type],
      unqualifiedName,
      qualifiedName,
      depth
   into -- drop table 
      #relatedDownwards
   from
      relatedDownwards d
   where
      depth = (
         select
            MIN(depth)
         from
            relatedDownwards s
         where
            s.[object_id] = d.[object_id]
      );
   create unique clustered index ix_relatedDownwards on #relatedDownwards([object_id]);
   select distinct
      [object_id],
      [type],
      [unqualifiedName],
      [qualifiedName],
      [depth]
   into
      #affectedObjects
   from
      #relatedDownwards d
   where
      [qualifiedName] not like @exclusionPattern
   and
      [qualifiedName] like @inclusionPattern
   and
      @directions like '%' + [relationType] + '%';
   create unique clustered index ix_affectedObjects on #affectedObjects([object_id]);
   select distinct
      objectType,
      unqualifiedName,
      qualifiedName,
      dropOrder
   into
      #dropList
   from (
      select
         t.objectType,
         o.unqualifiedName,
         o.qualifiedName,
         dense_rank() over (
            order by
               o.depth desc,
               case o.[type]
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
               isnull(c.ordinal, 0) asc
         ) as dropOrder
      from
         #affectedObjects o
      left join
         #includedConstructs c
      on
         c.[object_id] = o.[object_id]
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
      where
         t.objectType in (
            'CHECK',
            'VIEW',
            'FUNCTION',
            'PROCEDURE',
            'TABLE'
         )
   ) r;
   select
      case 
         when d.objectType = 'CHECK'
         then 'ALTER TABLE ' + p.parentName + ' DROP CONSTRAINT ' + d.unqualifiedName
         else 'DROP ' + d.objectType + ' ' + d.qualifiedName
      end + ';' + CHAR(13) as [text()]
   from
      #dropList d
   join
      sys.objects o
   on
      o.[object_id] = OBJECT_ID(d.qualifiedName)
   join
      sys.schemas s
   on
      s.[schema_id] = o.[schema_id]
   cross apply (
      select
         '[' + s.name + '].[' + OBJECT_NAME(o.parent_object_id) + ']'
   ) p (parentName)
   order by
      d.dropOrder asc
   for xml path('');
END
GO
-- Database Copy Script Generator -------------------------------------------------------------------------------------
-- generates a copy script, that must be run separately, copying all data between two identically modeled databases
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._GenerateCopyScript', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_GenerateCopyScript];
GO
CREATE PROCEDURE [metadata]._GenerateCopyScript (
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
		_Schema;
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
		_Schema_Expanded
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
			_Knot x
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
			_Knot x
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
			_Anchor x
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
				_Attribute x
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
				_Attribute x
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
				_Tie x
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
				_Tie x
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
IF Object_ID('metadata._DeleteWhereMetadataEquals', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_DeleteWhereMetadataEquals];
GO
CREATE PROCEDURE [metadata]._DeleteWhereMetadataEquals (
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
				_Schema;
		end;
		with constructs as (
			select
				'l' + name as name,
				2 as prio,
				'Metadata' + name as metadataColumn
			from
				_Tie
			where
				[version] = @schemaVersion
			union all
			select
				'l' + name as name,
				3 as prio,
				'Metadata' + mnemonic as metadataColumn
			from
				_Anchor
			where
				[version] = @schemaVersion
			union all
			select
				name,
				4 as prio,
				'Metadata' + mnemonic as metadataColumn
			from
				_Knot
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
if OBJECT_ID('metadata._FindWhatToRemove', 'P') is not null
drop proc [metadata].[_FindWhatToRemove];
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
create proc [metadata].[_FindWhatToRemove] (
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
		declare @version int = (select max(version) from _Schema);
		declare @ties xml = (
			select
				*
			from (
				select [schema].query('//tie[anchorRole[@type = sql:variable("@current")]]')
				from _Schema
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
					for $anchorRole in $tie/anchorRole
					return concat($anchorRole/@type, "_", $anchorRole/@role)
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
					select ''' + @next + ''', t.' + @anchor_column + '
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
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------