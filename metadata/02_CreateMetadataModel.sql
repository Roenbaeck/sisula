-- CLR ----------------------------------------------------------------------------------------------------------------
--
-- The MD5 function is used to calculate hashes on which comparisons are made for data types that do
-- not support equality checking, and for which 'checksum' has been selected. The reason for not
-- using the built in HashBytes is that it is limited to inputs up to 8000 bytes.
--
-- MD5 function -------------------------------------------------------------------------------------------------------
-- MD5 hashing function
-----------------------------------------------------------------------------------------------------------------------
IF Object_Id('metadata.MD5', 'FS') IS NULL
BEGIN
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
END
GO
sp_configure 'clr enabled', 1;
GO
reconfigure with override;
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
-- Static attribute table ---------------------------------------------------------------------------------------------
-- JB_NAM_Job_Name table (on JB_Job)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_NAM_Job_Name', 'U') IS NULL
CREATE TABLE [metadata].[JB_NAM_Job_Name] (
    JB_NAM_JB_ID int not null,
    JB_NAM_Job_Name varchar(255) not null,
    constraint fkJB_NAM_Job_Name foreign key (
        JB_NAM_JB_ID
    ) references [metadata].[JB_Job](JB_ID),
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
-- Static attribute table ---------------------------------------------------------------------------------------------
-- JB_AID_Job_AgentJobId table (on JB_Job)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_AID_Job_AgentJobId', 'U') IS NULL
CREATE TABLE [metadata].[JB_AID_Job_AgentJobId] (
    JB_AID_JB_ID int not null,
    JB_AID_Job_AgentJobId uniqueidentifier not null,
    constraint fkJB_AID_Job_AgentJobId foreign key (
        JB_AID_JB_ID
    ) references [metadata].[JB_Job](JB_ID),
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
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_NAM_Work_Name table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_NAM_Work_Name', 'U') IS NULL
CREATE TABLE [metadata].[WO_NAM_Work_Name] (
    WO_NAM_WO_ID int not null,
    WO_NAM_Work_Name varchar(255) not null,
    constraint fkWO_NAM_Work_Name foreign key (
        WO_NAM_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_NAM_Work_Name primary key (
        WO_NAM_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_USR_Work_InvocationUser table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_USR_Work_InvocationUser', 'U') IS NULL
CREATE TABLE [metadata].[WO_USR_Work_InvocationUser] (
    WO_USR_WO_ID int not null,
    WO_USR_Work_InvocationUser varchar(555) not null,
    constraint fkWO_USR_Work_InvocationUser foreign key (
        WO_USR_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_USR_Work_InvocationUser primary key (
        WO_USR_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_ROL_Work_InvocationRole table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_ROL_Work_InvocationRole', 'U') IS NULL
CREATE TABLE [metadata].[WO_ROL_Work_InvocationRole] (
    WO_ROL_WO_ID int not null,
    WO_ROL_Work_InvocationRole varchar(42) not null,
    constraint fkWO_ROL_Work_InvocationRole foreign key (
        WO_ROL_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
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
-- in changing time.
--
-- returns 1 for at least one equal surrounding value, 0 for different surrounding values
--
-- @id the identity of the anchored entity
-- @eq the equivalent (when applicable)
-- @value the value of the attribute
-- @changed the point in time from which this value shall represent a change
--
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfJB_EST_Job_ExecutionStatus restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcJB_EST_Job_ExecutionStatus restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rfJB_EST_Job_ExecutionStatus', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rfJB_EST_Job_ExecutionStatus] (
        @id int,
        @value tinyint,
        @changed datetime2(7)
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.JB_EST_EST_ID
                    FROM
                        [metadata].[JB_EST_Job_ExecutionStatus] pre
                    WHERE
                        pre.JB_EST_JB_ID = @id
                    AND
                        pre.JB_EST_ChangedAt < @changed
                    ORDER BY
                        pre.JB_EST_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.JB_EST_EST_ID
                    FROM
                        [metadata].[JB_EST_Job_ExecutionStatus] fol
                    WHERE
                        fol.JB_EST_JB_ID = @id
                    AND
                        fol.JB_EST_ChangedAt > @changed
                    ORDER BY
                        fol.JB_EST_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [metadata].[JB_EST_Job_ExecutionStatus]
    ADD CONSTRAINT [rcJB_EST_Job_ExecutionStatus] CHECK (
        [metadata].[rfJB_EST_Job_ExecutionStatus] (
            JB_EST_JB_ID,
            JB_EST_EST_ID,
            JB_EST_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfCO_DSC_Container_Discovered restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcCO_DSC_Container_Discovered restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rfCO_DSC_Container_Discovered', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rfCO_DSC_Container_Discovered] (
        @id int,
        @value datetime,
        @changed datetime2(7)
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.CO_DSC_Container_Discovered
                    FROM
                        [metadata].[CO_DSC_Container_Discovered] pre
                    WHERE
                        pre.CO_DSC_CO_ID = @id
                    AND
                        pre.CO_DSC_ChangedAt < @changed
                    ORDER BY
                        pre.CO_DSC_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.CO_DSC_Container_Discovered
                    FROM
                        [metadata].[CO_DSC_Container_Discovered] fol
                    WHERE
                        fol.CO_DSC_CO_ID = @id
                    AND
                        fol.CO_DSC_ChangedAt > @changed
                    ORDER BY
                        fol.CO_DSC_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [metadata].[CO_DSC_Container_Discovered]
    ADD CONSTRAINT [rcCO_DSC_Container_Discovered] CHECK (
        [metadata].[rfCO_DSC_Container_Discovered] (
            CO_DSC_CO_ID,
            CO_DSC_Container_Discovered,
            CO_DSC_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfWO_EST_Work_ExecutionStatus restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcWO_EST_Work_ExecutionStatus restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rfWO_EST_Work_ExecutionStatus', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rfWO_EST_Work_ExecutionStatus] (
        @id int,
        @value tinyint,
        @changed datetime2(7)
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.WO_EST_EST_ID
                    FROM
                        [metadata].[WO_EST_Work_ExecutionStatus] pre
                    WHERE
                        pre.WO_EST_WO_ID = @id
                    AND
                        pre.WO_EST_ChangedAt < @changed
                    ORDER BY
                        pre.WO_EST_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.WO_EST_EST_ID
                    FROM
                        [metadata].[WO_EST_Work_ExecutionStatus] fol
                    WHERE
                        fol.WO_EST_WO_ID = @id
                    AND
                        fol.WO_EST_ChangedAt > @changed
                    ORDER BY
                        fol.WO_EST_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [metadata].[WO_EST_Work_ExecutionStatus]
    ADD CONSTRAINT [rcWO_EST_Work_ExecutionStatus] CHECK (
        [metadata].[rfWO_EST_Work_ExecutionStatus] (
            WO_EST_WO_ID,
            WO_EST_EST_ID,
            WO_EST_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfCF_XML_Configuration_XMLDefinition restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcCF_XML_Configuration_XMLDefinition restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rfCF_XML_Configuration_XMLDefinition', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rfCF_XML_Configuration_XMLDefinition] (
        @id int,
        @value varbinary(16),
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.CF_XML_Checksum
                    FROM
                        [metadata].[CF_XML_Configuration_XMLDefinition] pre
                    WHERE
                        pre.CF_XML_CF_ID = @id
                    AND
                        pre.CF_XML_ChangedAt < @changed
                    ORDER BY
                        pre.CF_XML_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.CF_XML_Checksum
                    FROM
                        [metadata].[CF_XML_Configuration_XMLDefinition] fol
                    WHERE
                        fol.CF_XML_CF_ID = @id
                    AND
                        fol.CF_XML_ChangedAt > @changed
                    ORDER BY
                        fol.CF_XML_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [metadata].[CF_XML_Configuration_XMLDefinition]
    ADD CONSTRAINT [rcCF_XML_Configuration_XMLDefinition] CHECK (
        [metadata].[rfCF_XML_Configuration_XMLDefinition] (
            CF_XML_CF_ID,
            CF_XML_Checksum,
            CF_XML_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfOP_INS_Operations_Inserts restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcOP_INS_Operations_Inserts restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rfOP_INS_Operations_Inserts', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rfOP_INS_Operations_Inserts] (
        @id int,
        @value int,
        @changed datetime2(7)
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.OP_INS_Operations_Inserts
                    FROM
                        [metadata].[OP_INS_Operations_Inserts] pre
                    WHERE
                        pre.OP_INS_OP_ID = @id
                    AND
                        pre.OP_INS_ChangedAt < @changed
                    ORDER BY
                        pre.OP_INS_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.OP_INS_Operations_Inserts
                    FROM
                        [metadata].[OP_INS_Operations_Inserts] fol
                    WHERE
                        fol.OP_INS_OP_ID = @id
                    AND
                        fol.OP_INS_ChangedAt > @changed
                    ORDER BY
                        fol.OP_INS_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [metadata].[OP_INS_Operations_Inserts]
    ADD CONSTRAINT [rcOP_INS_Operations_Inserts] CHECK (
        [metadata].[rfOP_INS_Operations_Inserts] (
            OP_INS_OP_ID,
            OP_INS_Operations_Inserts,
            OP_INS_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfOP_UPD_Operations_Updates restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcOP_UPD_Operations_Updates restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rfOP_UPD_Operations_Updates', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rfOP_UPD_Operations_Updates] (
        @id int,
        @value int,
        @changed datetime2(7)
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.OP_UPD_Operations_Updates
                    FROM
                        [metadata].[OP_UPD_Operations_Updates] pre
                    WHERE
                        pre.OP_UPD_OP_ID = @id
                    AND
                        pre.OP_UPD_ChangedAt < @changed
                    ORDER BY
                        pre.OP_UPD_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.OP_UPD_Operations_Updates
                    FROM
                        [metadata].[OP_UPD_Operations_Updates] fol
                    WHERE
                        fol.OP_UPD_OP_ID = @id
                    AND
                        fol.OP_UPD_ChangedAt > @changed
                    ORDER BY
                        fol.OP_UPD_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [metadata].[OP_UPD_Operations_Updates]
    ADD CONSTRAINT [rcOP_UPD_Operations_Updates] CHECK (
        [metadata].[rfOP_UPD_Operations_Updates] (
            OP_UPD_OP_ID,
            OP_UPD_Operations_Updates,
            OP_UPD_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfOP_DEL_Operations_Deletes restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcOP_DEL_Operations_Deletes restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rfOP_DEL_Operations_Deletes', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rfOP_DEL_Operations_Deletes] (
        @id int,
        @value int,
        @changed datetime2(7)
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.OP_DEL_Operations_Deletes
                    FROM
                        [metadata].[OP_DEL_Operations_Deletes] pre
                    WHERE
                        pre.OP_DEL_OP_ID = @id
                    AND
                        pre.OP_DEL_ChangedAt < @changed
                    ORDER BY
                        pre.OP_DEL_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.OP_DEL_Operations_Deletes
                    FROM
                        [metadata].[OP_DEL_Operations_Deletes] fol
                    WHERE
                        fol.OP_DEL_OP_ID = @id
                    AND
                        fol.OP_DEL_ChangedAt > @changed
                    ORDER BY
                        fol.OP_DEL_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [metadata].[OP_DEL_Operations_Deletes]
    ADD CONSTRAINT [rcOP_DEL_Operations_Deletes] CHECK (
        [metadata].[rfOP_DEL_Operations_Deletes] (
            OP_DEL_OP_ID,
            OP_DEL_Operations_Deletes,
            OP_DEL_ChangedAt
        ) = 0
    );
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
    [NAM].JB_NAM_Job_Name,
    [EST].JB_EST_JB_ID,
    [EST].JB_EST_ChangedAt,
    [kEST].EST_ExecutionStatus AS JB_EST_EST_ExecutionStatus,
    [EST].JB_EST_EST_ID,
    [AID].JB_AID_JB_ID,
    [AID].JB_AID_Job_AgentJobId
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
    [AID].JB_AID_JB_ID = [JB].JB_ID;
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
    [NAM].JB_NAM_Job_Name,
    [EST].JB_EST_JB_ID,
    [EST].JB_EST_ChangedAt,
    [kEST].EST_ExecutionStatus AS JB_EST_EST_ExecutionStatus,
    [EST].JB_EST_EST_ID,
    [AID].JB_AID_JB_ID,
    [AID].JB_AID_Job_AgentJobId
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
    [AID].JB_AID_JB_ID = [JB].JB_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nJB_Job viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nJB_Job]
AS
SELECT
    *
FROM
    [metadata].[pJB_Job](sysdatetime());
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
    [metadata].[pCO_Container](sysdatetime());
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
    [NAM].WO_NAM_Work_Name,
    [USR].WO_USR_WO_ID,
    [USR].WO_USR_Work_InvocationUser,
    [ROL].WO_ROL_WO_ID,
    [ROL].WO_ROL_Work_InvocationRole,
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
    [metadata].[WO_USR_Work_InvocationUser] [USR]
ON
    [USR].WO_USR_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_ROL_Work_InvocationRole] [ROL]
ON
    [ROL].WO_ROL_WO_ID = [WO].WO_ID
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
    [NAM].WO_NAM_Work_Name,
    [USR].WO_USR_WO_ID,
    [USR].WO_USR_Work_InvocationUser,
    [ROL].WO_ROL_WO_ID,
    [ROL].WO_ROL_Work_InvocationRole,
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
    [metadata].[WO_USR_Work_InvocationUser] [USR]
ON
    [USR].WO_USR_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_ROL_Work_InvocationRole] [ROL]
ON
    [ROL].WO_ROL_WO_ID = [WO].WO_ID
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
    [metadata].[pWO_Work](sysdatetime());
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
    [metadata].[pCF_Configuration](sysdatetime());
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
    [metadata].[pOP_Operations](sysdatetime());
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @JB_STA_Job_Start TABLE (
        JB_STA_JB_ID int not null,
        JB_STA_Job_Start datetime2(7) not null,
        JB_STA_Version bigint not null,
        JB_STA_StatementType char(1) not null,
        primary key(
            JB_STA_Version,
            JB_STA_JB_ID
        )
    );
    INSERT INTO @JB_STA_Job_Start
    SELECT
        i.JB_STA_JB_ID,
        i.JB_STA_Job_Start,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(JB_STA_Version),
        @currentVersion = 0
    FROM
        @JB_STA_Job_Start;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.JB_STA_StatementType =
                CASE
                    WHEN [STA].JB_STA_JB_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @JB_STA_Job_Start v
        LEFT JOIN
            [metadata].[JB_STA_Job_Start] [STA]
        ON
            [STA].JB_STA_JB_ID = v.JB_STA_JB_ID
        AND
            [STA].JB_STA_Job_Start = v.JB_STA_Job_Start
        WHERE
            v.JB_STA_Version = @currentVersion;
        INSERT INTO [metadata].[JB_STA_Job_Start] (
            JB_STA_JB_ID,
            JB_STA_Job_Start
        )
        SELECT
            JB_STA_JB_ID,
            JB_STA_Job_Start
        FROM
            @JB_STA_Job_Start
        WHERE
            JB_STA_Version = @currentVersion
        AND
            JB_STA_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @JB_END_Job_End TABLE (
        JB_END_JB_ID int not null,
        JB_END_Job_End datetime2(7) not null,
        JB_END_Version bigint not null,
        JB_END_StatementType char(1) not null,
        primary key(
            JB_END_Version,
            JB_END_JB_ID
        )
    );
    INSERT INTO @JB_END_Job_End
    SELECT
        i.JB_END_JB_ID,
        i.JB_END_Job_End,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(JB_END_Version),
        @currentVersion = 0
    FROM
        @JB_END_Job_End;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.JB_END_StatementType =
                CASE
                    WHEN [END].JB_END_JB_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @JB_END_Job_End v
        LEFT JOIN
            [metadata].[JB_END_Job_End] [END]
        ON
            [END].JB_END_JB_ID = v.JB_END_JB_ID
        AND
            [END].JB_END_Job_End = v.JB_END_Job_End
        WHERE
            v.JB_END_Version = @currentVersion;
        INSERT INTO [metadata].[JB_END_Job_End] (
            JB_END_JB_ID,
            JB_END_Job_End
        )
        SELECT
            JB_END_JB_ID,
            JB_END_Job_End
        FROM
            @JB_END_Job_End
        WHERE
            JB_END_Version = @currentVersion
        AND
            JB_END_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @JB_NAM_Job_Name TABLE (
        JB_NAM_JB_ID int not null,
        JB_NAM_Job_Name varchar(255) not null,
        JB_NAM_Version bigint not null,
        JB_NAM_StatementType char(1) not null,
        primary key(
            JB_NAM_Version,
            JB_NAM_JB_ID
        )
    );
    INSERT INTO @JB_NAM_Job_Name
    SELECT
        i.JB_NAM_JB_ID,
        i.JB_NAM_Job_Name,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(JB_NAM_Version),
        @currentVersion = 0
    FROM
        @JB_NAM_Job_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.JB_NAM_StatementType =
                CASE
                    WHEN [NAM].JB_NAM_JB_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @JB_NAM_Job_Name v
        LEFT JOIN
            [metadata].[JB_NAM_Job_Name] [NAM]
        ON
            [NAM].JB_NAM_JB_ID = v.JB_NAM_JB_ID
        AND
            [NAM].JB_NAM_Job_Name = v.JB_NAM_Job_Name
        WHERE
            v.JB_NAM_Version = @currentVersion;
        INSERT INTO [metadata].[JB_NAM_Job_Name] (
            JB_NAM_JB_ID,
            JB_NAM_Job_Name
        )
        SELECT
            JB_NAM_JB_ID,
            JB_NAM_Job_Name
        FROM
            @JB_NAM_Job_Name
        WHERE
            JB_NAM_Version = @currentVersion
        AND
            JB_NAM_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @JB_EST_Job_ExecutionStatus TABLE (
        JB_EST_JB_ID int not null,
        JB_EST_ChangedAt datetime2(7) not null,
        JB_EST_EST_ID tinyint not null, 
        JB_EST_Version bigint not null,
        JB_EST_StatementType char(1) not null,
        primary key(
            JB_EST_Version,
            JB_EST_JB_ID
        )
    );
    INSERT INTO @JB_EST_Job_ExecutionStatus
    SELECT
        i.JB_EST_JB_ID,
        i.JB_EST_ChangedAt,
        i.JB_EST_EST_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.JB_EST_JB_ID
            ORDER BY
                i.JB_EST_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(JB_EST_Version),
        @currentVersion = 0
    FROM
        @JB_EST_Job_ExecutionStatus;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.JB_EST_StatementType =
                CASE
                    WHEN [EST].JB_EST_JB_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [metadata].[rfJB_EST_Job_ExecutionStatus](
                        v.JB_EST_JB_ID,
                        v.JB_EST_EST_ID,
                        v.JB_EST_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @JB_EST_Job_ExecutionStatus v
        LEFT JOIN
            [metadata].[JB_EST_Job_ExecutionStatus] [EST]
        ON
            [EST].JB_EST_JB_ID = v.JB_EST_JB_ID
        AND
            [EST].JB_EST_ChangedAt = v.JB_EST_ChangedAt
        AND
            [EST].JB_EST_EST_ID = v.JB_EST_EST_ID
        WHERE
            v.JB_EST_Version = @currentVersion;
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
            JB_EST_Version = @currentVersion
        AND
            JB_EST_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @JB_AID_Job_AgentJobId TABLE (
        JB_AID_JB_ID int not null,
        JB_AID_Job_AgentJobId uniqueidentifier not null,
        JB_AID_Version bigint not null,
        JB_AID_StatementType char(1) not null,
        primary key(
            JB_AID_Version,
            JB_AID_JB_ID
        )
    );
    INSERT INTO @JB_AID_Job_AgentJobId
    SELECT
        i.JB_AID_JB_ID,
        i.JB_AID_Job_AgentJobId,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(JB_AID_Version),
        @currentVersion = 0
    FROM
        @JB_AID_Job_AgentJobId;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.JB_AID_StatementType =
                CASE
                    WHEN [AID].JB_AID_JB_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @JB_AID_Job_AgentJobId v
        LEFT JOIN
            [metadata].[JB_AID_Job_AgentJobId] [AID]
        ON
            [AID].JB_AID_JB_ID = v.JB_AID_JB_ID
        AND
            [AID].JB_AID_Job_AgentJobId = v.JB_AID_Job_AgentJobId
        WHERE
            v.JB_AID_Version = @currentVersion;
        INSERT INTO [metadata].[JB_AID_Job_AgentJobId] (
            JB_AID_JB_ID,
            JB_AID_Job_AgentJobId
        )
        SELECT
            JB_AID_JB_ID,
            JB_AID_Job_AgentJobId
        FROM
            @JB_AID_Job_AgentJobId
        WHERE
            JB_AID_Version = @currentVersion
        AND
            JB_AID_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CO_NAM_Container_Name TABLE (
        CO_NAM_CO_ID int not null,
        CO_NAM_Container_Name varchar(2000) not null,
        CO_NAM_Version bigint not null,
        CO_NAM_StatementType char(1) not null,
        primary key(
            CO_NAM_Version,
            CO_NAM_CO_ID
        )
    );
    INSERT INTO @CO_NAM_Container_Name
    SELECT
        i.CO_NAM_CO_ID,
        i.CO_NAM_Container_Name,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CO_NAM_Version),
        @currentVersion = 0
    FROM
        @CO_NAM_Container_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CO_NAM_StatementType =
                CASE
                    WHEN [NAM].CO_NAM_CO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @CO_NAM_Container_Name v
        LEFT JOIN
            [metadata].[CO_NAM_Container_Name] [NAM]
        ON
            [NAM].CO_NAM_CO_ID = v.CO_NAM_CO_ID
        AND
            [NAM].CO_NAM_Container_Name = v.CO_NAM_Container_Name
        WHERE
            v.CO_NAM_Version = @currentVersion;
        INSERT INTO [metadata].[CO_NAM_Container_Name] (
            CO_NAM_CO_ID,
            CO_NAM_Container_Name
        )
        SELECT
            CO_NAM_CO_ID,
            CO_NAM_Container_Name
        FROM
            @CO_NAM_Container_Name
        WHERE
            CO_NAM_Version = @currentVersion
        AND
            CO_NAM_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CO_TYP_Container_Type TABLE (
        CO_TYP_CO_ID int not null,
        CO_TYP_COT_ID tinyint not null, 
        CO_TYP_Version bigint not null,
        CO_TYP_StatementType char(1) not null,
        primary key(
            CO_TYP_Version,
            CO_TYP_CO_ID
        )
    );
    INSERT INTO @CO_TYP_Container_Type
    SELECT
        i.CO_TYP_CO_ID,
        i.CO_TYP_COT_ID,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CO_TYP_Version),
        @currentVersion = 0
    FROM
        @CO_TYP_Container_Type;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CO_TYP_StatementType =
                CASE
                    WHEN [TYP].CO_TYP_CO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @CO_TYP_Container_Type v
        LEFT JOIN
            [metadata].[CO_TYP_Container_Type] [TYP]
        ON
            [TYP].CO_TYP_CO_ID = v.CO_TYP_CO_ID
        AND
            [TYP].CO_TYP_COT_ID = v.CO_TYP_COT_ID
        WHERE
            v.CO_TYP_Version = @currentVersion;
        INSERT INTO [metadata].[CO_TYP_Container_Type] (
            CO_TYP_CO_ID,
            CO_TYP_COT_ID
        )
        SELECT
            CO_TYP_CO_ID,
            CO_TYP_COT_ID
        FROM
            @CO_TYP_Container_Type
        WHERE
            CO_TYP_Version = @currentVersion
        AND
            CO_TYP_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CO_DSC_Container_Discovered TABLE (
        CO_DSC_CO_ID int not null,
        CO_DSC_ChangedAt datetime2(7) not null,
        CO_DSC_Container_Discovered datetime not null,
        CO_DSC_Version bigint not null,
        CO_DSC_StatementType char(1) not null,
        primary key(
            CO_DSC_Version,
            CO_DSC_CO_ID
        )
    );
    INSERT INTO @CO_DSC_Container_Discovered
    SELECT
        i.CO_DSC_CO_ID,
        i.CO_DSC_ChangedAt,
        i.CO_DSC_Container_Discovered,
        DENSE_RANK() OVER (
            PARTITION BY
                i.CO_DSC_CO_ID
            ORDER BY
                i.CO_DSC_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CO_DSC_Version),
        @currentVersion = 0
    FROM
        @CO_DSC_Container_Discovered;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CO_DSC_StatementType =
                CASE
                    WHEN [DSC].CO_DSC_CO_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [metadata].[rfCO_DSC_Container_Discovered](
                        v.CO_DSC_CO_ID,
                        v.CO_DSC_Container_Discovered,
                        v.CO_DSC_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @CO_DSC_Container_Discovered v
        LEFT JOIN
            [metadata].[CO_DSC_Container_Discovered] [DSC]
        ON
            [DSC].CO_DSC_CO_ID = v.CO_DSC_CO_ID
        AND
            [DSC].CO_DSC_ChangedAt = v.CO_DSC_ChangedAt
        AND
            [DSC].CO_DSC_Container_Discovered = v.CO_DSC_Container_Discovered
        WHERE
            v.CO_DSC_Version = @currentVersion;
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
            CO_DSC_Version = @currentVersion
        AND
            CO_DSC_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CO_CRE_Container_Created TABLE (
        CO_CRE_CO_ID int not null,
        CO_CRE_Container_Created datetime not null,
        CO_CRE_Version bigint not null,
        CO_CRE_StatementType char(1) not null,
        primary key(
            CO_CRE_Version,
            CO_CRE_CO_ID
        )
    );
    INSERT INTO @CO_CRE_Container_Created
    SELECT
        i.CO_CRE_CO_ID,
        i.CO_CRE_Container_Created,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CO_CRE_Version),
        @currentVersion = 0
    FROM
        @CO_CRE_Container_Created;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CO_CRE_StatementType =
                CASE
                    WHEN [CRE].CO_CRE_CO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @CO_CRE_Container_Created v
        LEFT JOIN
            [metadata].[CO_CRE_Container_Created] [CRE]
        ON
            [CRE].CO_CRE_CO_ID = v.CO_CRE_CO_ID
        AND
            [CRE].CO_CRE_Container_Created = v.CO_CRE_Container_Created
        WHERE
            v.CO_CRE_Version = @currentVersion;
        INSERT INTO [metadata].[CO_CRE_Container_Created] (
            CO_CRE_CO_ID,
            CO_CRE_Container_Created
        )
        SELECT
            CO_CRE_CO_ID,
            CO_CRE_Container_Created
        FROM
            @CO_CRE_Container_Created
        WHERE
            CO_CRE_Version = @currentVersion
        AND
            CO_CRE_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_STA_Work_Start TABLE (
        WO_STA_WO_ID int not null,
        WO_STA_Work_Start datetime2(7) not null,
        WO_STA_Version bigint not null,
        WO_STA_StatementType char(1) not null,
        primary key(
            WO_STA_Version,
            WO_STA_WO_ID
        )
    );
    INSERT INTO @WO_STA_Work_Start
    SELECT
        i.WO_STA_WO_ID,
        i.WO_STA_Work_Start,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_STA_Version),
        @currentVersion = 0
    FROM
        @WO_STA_Work_Start;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_STA_StatementType =
                CASE
                    WHEN [STA].WO_STA_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_STA_Work_Start v
        LEFT JOIN
            [metadata].[WO_STA_Work_Start] [STA]
        ON
            [STA].WO_STA_WO_ID = v.WO_STA_WO_ID
        AND
            [STA].WO_STA_Work_Start = v.WO_STA_Work_Start
        WHERE
            v.WO_STA_Version = @currentVersion;
        INSERT INTO [metadata].[WO_STA_Work_Start] (
            WO_STA_WO_ID,
            WO_STA_Work_Start
        )
        SELECT
            WO_STA_WO_ID,
            WO_STA_Work_Start
        FROM
            @WO_STA_Work_Start
        WHERE
            WO_STA_Version = @currentVersion
        AND
            WO_STA_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_END_Work_End TABLE (
        WO_END_WO_ID int not null,
        WO_END_Work_End datetime2(7) not null,
        WO_END_Version bigint not null,
        WO_END_StatementType char(1) not null,
        primary key(
            WO_END_Version,
            WO_END_WO_ID
        )
    );
    INSERT INTO @WO_END_Work_End
    SELECT
        i.WO_END_WO_ID,
        i.WO_END_Work_End,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_END_Version),
        @currentVersion = 0
    FROM
        @WO_END_Work_End;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_END_StatementType =
                CASE
                    WHEN [END].WO_END_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_END_Work_End v
        LEFT JOIN
            [metadata].[WO_END_Work_End] [END]
        ON
            [END].WO_END_WO_ID = v.WO_END_WO_ID
        AND
            [END].WO_END_Work_End = v.WO_END_Work_End
        WHERE
            v.WO_END_Version = @currentVersion;
        INSERT INTO [metadata].[WO_END_Work_End] (
            WO_END_WO_ID,
            WO_END_Work_End
        )
        SELECT
            WO_END_WO_ID,
            WO_END_Work_End
        FROM
            @WO_END_Work_End
        WHERE
            WO_END_Version = @currentVersion
        AND
            WO_END_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_NAM_Work_Name TABLE (
        WO_NAM_WO_ID int not null,
        WO_NAM_Work_Name varchar(255) not null,
        WO_NAM_Version bigint not null,
        WO_NAM_StatementType char(1) not null,
        primary key(
            WO_NAM_Version,
            WO_NAM_WO_ID
        )
    );
    INSERT INTO @WO_NAM_Work_Name
    SELECT
        i.WO_NAM_WO_ID,
        i.WO_NAM_Work_Name,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_NAM_Version),
        @currentVersion = 0
    FROM
        @WO_NAM_Work_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_NAM_StatementType =
                CASE
                    WHEN [NAM].WO_NAM_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_NAM_Work_Name v
        LEFT JOIN
            [metadata].[WO_NAM_Work_Name] [NAM]
        ON
            [NAM].WO_NAM_WO_ID = v.WO_NAM_WO_ID
        AND
            [NAM].WO_NAM_Work_Name = v.WO_NAM_Work_Name
        WHERE
            v.WO_NAM_Version = @currentVersion;
        INSERT INTO [metadata].[WO_NAM_Work_Name] (
            WO_NAM_WO_ID,
            WO_NAM_Work_Name
        )
        SELECT
            WO_NAM_WO_ID,
            WO_NAM_Work_Name
        FROM
            @WO_NAM_Work_Name
        WHERE
            WO_NAM_Version = @currentVersion
        AND
            WO_NAM_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_USR_Work_InvocationUser TABLE (
        WO_USR_WO_ID int not null,
        WO_USR_Work_InvocationUser varchar(555) not null,
        WO_USR_Version bigint not null,
        WO_USR_StatementType char(1) not null,
        primary key(
            WO_USR_Version,
            WO_USR_WO_ID
        )
    );
    INSERT INTO @WO_USR_Work_InvocationUser
    SELECT
        i.WO_USR_WO_ID,
        i.WO_USR_Work_InvocationUser,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_USR_Version),
        @currentVersion = 0
    FROM
        @WO_USR_Work_InvocationUser;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_USR_StatementType =
                CASE
                    WHEN [USR].WO_USR_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_USR_Work_InvocationUser v
        LEFT JOIN
            [metadata].[WO_USR_Work_InvocationUser] [USR]
        ON
            [USR].WO_USR_WO_ID = v.WO_USR_WO_ID
        AND
            [USR].WO_USR_Work_InvocationUser = v.WO_USR_Work_InvocationUser
        WHERE
            v.WO_USR_Version = @currentVersion;
        INSERT INTO [metadata].[WO_USR_Work_InvocationUser] (
            WO_USR_WO_ID,
            WO_USR_Work_InvocationUser
        )
        SELECT
            WO_USR_WO_ID,
            WO_USR_Work_InvocationUser
        FROM
            @WO_USR_Work_InvocationUser
        WHERE
            WO_USR_Version = @currentVersion
        AND
            WO_USR_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_ROL_Work_InvocationRole TABLE (
        WO_ROL_WO_ID int not null,
        WO_ROL_Work_InvocationRole varchar(42) not null,
        WO_ROL_Version bigint not null,
        WO_ROL_StatementType char(1) not null,
        primary key(
            WO_ROL_Version,
            WO_ROL_WO_ID
        )
    );
    INSERT INTO @WO_ROL_Work_InvocationRole
    SELECT
        i.WO_ROL_WO_ID,
        i.WO_ROL_Work_InvocationRole,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_ROL_Version),
        @currentVersion = 0
    FROM
        @WO_ROL_Work_InvocationRole;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_ROL_StatementType =
                CASE
                    WHEN [ROL].WO_ROL_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_ROL_Work_InvocationRole v
        LEFT JOIN
            [metadata].[WO_ROL_Work_InvocationRole] [ROL]
        ON
            [ROL].WO_ROL_WO_ID = v.WO_ROL_WO_ID
        AND
            [ROL].WO_ROL_Work_InvocationRole = v.WO_ROL_Work_InvocationRole
        WHERE
            v.WO_ROL_Version = @currentVersion;
        INSERT INTO [metadata].[WO_ROL_Work_InvocationRole] (
            WO_ROL_WO_ID,
            WO_ROL_Work_InvocationRole
        )
        SELECT
            WO_ROL_WO_ID,
            WO_ROL_Work_InvocationRole
        FROM
            @WO_ROL_Work_InvocationRole
        WHERE
            WO_ROL_Version = @currentVersion
        AND
            WO_ROL_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_EST_Work_ExecutionStatus TABLE (
        WO_EST_WO_ID int not null,
        WO_EST_ChangedAt datetime2(7) not null,
        WO_EST_EST_ID tinyint not null, 
        WO_EST_Version bigint not null,
        WO_EST_StatementType char(1) not null,
        primary key(
            WO_EST_Version,
            WO_EST_WO_ID
        )
    );
    INSERT INTO @WO_EST_Work_ExecutionStatus
    SELECT
        i.WO_EST_WO_ID,
        i.WO_EST_ChangedAt,
        i.WO_EST_EST_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.WO_EST_WO_ID
            ORDER BY
                i.WO_EST_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_EST_Version),
        @currentVersion = 0
    FROM
        @WO_EST_Work_ExecutionStatus;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_EST_StatementType =
                CASE
                    WHEN [EST].WO_EST_WO_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [metadata].[rfWO_EST_Work_ExecutionStatus](
                        v.WO_EST_WO_ID,
                        v.WO_EST_EST_ID,
                        v.WO_EST_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_EST_Work_ExecutionStatus v
        LEFT JOIN
            [metadata].[WO_EST_Work_ExecutionStatus] [EST]
        ON
            [EST].WO_EST_WO_ID = v.WO_EST_WO_ID
        AND
            [EST].WO_EST_ChangedAt = v.WO_EST_ChangedAt
        AND
            [EST].WO_EST_EST_ID = v.WO_EST_EST_ID
        WHERE
            v.WO_EST_Version = @currentVersion;
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
            WO_EST_Version = @currentVersion
        AND
            WO_EST_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_ERL_Work_ErrorLine TABLE (
        WO_ERL_WO_ID int not null,
        WO_ERL_Work_ErrorLine int not null,
        WO_ERL_Version bigint not null,
        WO_ERL_StatementType char(1) not null,
        primary key(
            WO_ERL_Version,
            WO_ERL_WO_ID
        )
    );
    INSERT INTO @WO_ERL_Work_ErrorLine
    SELECT
        i.WO_ERL_WO_ID,
        i.WO_ERL_Work_ErrorLine,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_ERL_Version),
        @currentVersion = 0
    FROM
        @WO_ERL_Work_ErrorLine;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_ERL_StatementType =
                CASE
                    WHEN [ERL].WO_ERL_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_ERL_Work_ErrorLine v
        LEFT JOIN
            [metadata].[WO_ERL_Work_ErrorLine] [ERL]
        ON
            [ERL].WO_ERL_WO_ID = v.WO_ERL_WO_ID
        AND
            [ERL].WO_ERL_Work_ErrorLine = v.WO_ERL_Work_ErrorLine
        WHERE
            v.WO_ERL_Version = @currentVersion;
        INSERT INTO [metadata].[WO_ERL_Work_ErrorLine] (
            WO_ERL_WO_ID,
            WO_ERL_Work_ErrorLine
        )
        SELECT
            WO_ERL_WO_ID,
            WO_ERL_Work_ErrorLine
        FROM
            @WO_ERL_Work_ErrorLine
        WHERE
            WO_ERL_Version = @currentVersion
        AND
            WO_ERL_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_ERM_Work_ErrorMessage TABLE (
        WO_ERM_WO_ID int not null,
        WO_ERM_Work_ErrorMessage varchar(555) not null,
        WO_ERM_Version bigint not null,
        WO_ERM_StatementType char(1) not null,
        primary key(
            WO_ERM_Version,
            WO_ERM_WO_ID
        )
    );
    INSERT INTO @WO_ERM_Work_ErrorMessage
    SELECT
        i.WO_ERM_WO_ID,
        i.WO_ERM_Work_ErrorMessage,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_ERM_Version),
        @currentVersion = 0
    FROM
        @WO_ERM_Work_ErrorMessage;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_ERM_StatementType =
                CASE
                    WHEN [ERM].WO_ERM_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_ERM_Work_ErrorMessage v
        LEFT JOIN
            [metadata].[WO_ERM_Work_ErrorMessage] [ERM]
        ON
            [ERM].WO_ERM_WO_ID = v.WO_ERM_WO_ID
        AND
            [ERM].WO_ERM_Work_ErrorMessage = v.WO_ERM_Work_ErrorMessage
        WHERE
            v.WO_ERM_Version = @currentVersion;
        INSERT INTO [metadata].[WO_ERM_Work_ErrorMessage] (
            WO_ERM_WO_ID,
            WO_ERM_Work_ErrorMessage
        )
        SELECT
            WO_ERM_WO_ID,
            WO_ERM_Work_ErrorMessage
        FROM
            @WO_ERM_Work_ErrorMessage
        WHERE
            WO_ERM_Version = @currentVersion
        AND
            WO_ERM_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_AID_Work_AgentStepId TABLE (
        WO_AID_WO_ID int not null,
        WO_AID_Work_AgentStepId smallint not null,
        WO_AID_Version bigint not null,
        WO_AID_StatementType char(1) not null,
        primary key(
            WO_AID_Version,
            WO_AID_WO_ID
        )
    );
    INSERT INTO @WO_AID_Work_AgentStepId
    SELECT
        i.WO_AID_WO_ID,
        i.WO_AID_Work_AgentStepId,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_AID_Version),
        @currentVersion = 0
    FROM
        @WO_AID_Work_AgentStepId;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_AID_StatementType =
                CASE
                    WHEN [AID].WO_AID_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_AID_Work_AgentStepId v
        LEFT JOIN
            [metadata].[WO_AID_Work_AgentStepId] [AID]
        ON
            [AID].WO_AID_WO_ID = v.WO_AID_WO_ID
        AND
            [AID].WO_AID_Work_AgentStepId = v.WO_AID_Work_AgentStepId
        WHERE
            v.WO_AID_Version = @currentVersion;
        INSERT INTO [metadata].[WO_AID_Work_AgentStepId] (
            WO_AID_WO_ID,
            WO_AID_Work_AgentStepId
        )
        SELECT
            WO_AID_WO_ID,
            WO_AID_Work_AgentStepId
        FROM
            @WO_AID_Work_AgentStepId
        WHERE
            WO_AID_Version = @currentVersion
        AND
            WO_AID_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CF_NAM_Configuration_Name TABLE (
        CF_NAM_CF_ID int not null,
        CF_NAM_Configuration_Name varchar(255) not null,
        CF_NAM_Version bigint not null,
        CF_NAM_StatementType char(1) not null,
        primary key(
            CF_NAM_Version,
            CF_NAM_CF_ID
        )
    );
    INSERT INTO @CF_NAM_Configuration_Name
    SELECT
        i.CF_NAM_CF_ID,
        i.CF_NAM_Configuration_Name,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CF_NAM_Version),
        @currentVersion = 0
    FROM
        @CF_NAM_Configuration_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CF_NAM_StatementType =
                CASE
                    WHEN [NAM].CF_NAM_CF_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @CF_NAM_Configuration_Name v
        LEFT JOIN
            [metadata].[CF_NAM_Configuration_Name] [NAM]
        ON
            [NAM].CF_NAM_CF_ID = v.CF_NAM_CF_ID
        AND
            [NAM].CF_NAM_Configuration_Name = v.CF_NAM_Configuration_Name
        WHERE
            v.CF_NAM_Version = @currentVersion;
        INSERT INTO [metadata].[CF_NAM_Configuration_Name] (
            CF_NAM_CF_ID,
            CF_NAM_Configuration_Name
        )
        SELECT
            CF_NAM_CF_ID,
            CF_NAM_Configuration_Name
        FROM
            @CF_NAM_Configuration_Name
        WHERE
            CF_NAM_Version = @currentVersion
        AND
            CF_NAM_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CF_XML_Configuration_XMLDefinition TABLE (
        CF_XML_CF_ID int not null,
        CF_XML_ChangedAt datetime not null,
        CF_XML_Configuration_XMLDefinition xml not null,
        CF_XML_Checksum varbinary(16) not null,
        CF_XML_Version bigint not null,
        CF_XML_StatementType char(1) not null,
        primary key(
            CF_XML_Version,
            CF_XML_CF_ID
        )
    );
    INSERT INTO @CF_XML_Configuration_XMLDefinition
    SELECT
        i.CF_XML_CF_ID,
        i.CF_XML_ChangedAt,
        i.CF_XML_Configuration_XMLDefinition,
        metadata.MD5(cast(i.CF_XML_Configuration_XMLDefinition as varbinary(max))),
        DENSE_RANK() OVER (
            PARTITION BY
                i.CF_XML_CF_ID
            ORDER BY
                i.CF_XML_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CF_XML_Version),
        @currentVersion = 0
    FROM
        @CF_XML_Configuration_XMLDefinition;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CF_XML_StatementType =
                CASE
                    WHEN [XML].CF_XML_CF_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [metadata].[rfCF_XML_Configuration_XMLDefinition](
                        v.CF_XML_CF_ID,
                        v.CF_XML_Checksum, 
                        v.CF_XML_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @CF_XML_Configuration_XMLDefinition v
        LEFT JOIN
            [metadata].[CF_XML_Configuration_XMLDefinition] [XML]
        ON
            [XML].CF_XML_CF_ID = v.CF_XML_CF_ID
        AND
            [XML].CF_XML_ChangedAt = v.CF_XML_ChangedAt
        AND
            [XML].CF_XML_Checksum = v.CF_XML_Checksum 
        WHERE
            v.CF_XML_Version = @currentVersion;
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
            CF_XML_Version = @currentVersion
        AND
            CF_XML_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CF_TYP_Configuration_Type TABLE (
        CF_TYP_CF_ID int not null,
        CF_TYP_CFT_ID tinyint not null, 
        CF_TYP_Version bigint not null,
        CF_TYP_StatementType char(1) not null,
        primary key(
            CF_TYP_Version,
            CF_TYP_CF_ID
        )
    );
    INSERT INTO @CF_TYP_Configuration_Type
    SELECT
        i.CF_TYP_CF_ID,
        i.CF_TYP_CFT_ID,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CF_TYP_Version),
        @currentVersion = 0
    FROM
        @CF_TYP_Configuration_Type;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CF_TYP_StatementType =
                CASE
                    WHEN [TYP].CF_TYP_CF_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @CF_TYP_Configuration_Type v
        LEFT JOIN
            [metadata].[CF_TYP_Configuration_Type] [TYP]
        ON
            [TYP].CF_TYP_CF_ID = v.CF_TYP_CF_ID
        AND
            [TYP].CF_TYP_CFT_ID = v.CF_TYP_CFT_ID
        WHERE
            v.CF_TYP_Version = @currentVersion;
        INSERT INTO [metadata].[CF_TYP_Configuration_Type] (
            CF_TYP_CF_ID,
            CF_TYP_CFT_ID
        )
        SELECT
            CF_TYP_CF_ID,
            CF_TYP_CFT_ID
        FROM
            @CF_TYP_Configuration_Type
        WHERE
            CF_TYP_Version = @currentVersion
        AND
            CF_TYP_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @OP_INS_Operations_Inserts TABLE (
        OP_INS_OP_ID int not null,
        OP_INS_ChangedAt datetime2(7) not null,
        OP_INS_Operations_Inserts int not null,
        OP_INS_Version bigint not null,
        OP_INS_StatementType char(1) not null,
        primary key(
            OP_INS_Version,
            OP_INS_OP_ID
        )
    );
    INSERT INTO @OP_INS_Operations_Inserts
    SELECT
        i.OP_INS_OP_ID,
        i.OP_INS_ChangedAt,
        i.OP_INS_Operations_Inserts,
        DENSE_RANK() OVER (
            PARTITION BY
                i.OP_INS_OP_ID
            ORDER BY
                i.OP_INS_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(OP_INS_Version),
        @currentVersion = 0
    FROM
        @OP_INS_Operations_Inserts;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.OP_INS_StatementType =
                CASE
                    WHEN [INS].OP_INS_OP_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [metadata].[rfOP_INS_Operations_Inserts](
                        v.OP_INS_OP_ID,
                        v.OP_INS_Operations_Inserts,
                        v.OP_INS_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @OP_INS_Operations_Inserts v
        LEFT JOIN
            [metadata].[OP_INS_Operations_Inserts] [INS]
        ON
            [INS].OP_INS_OP_ID = v.OP_INS_OP_ID
        AND
            [INS].OP_INS_ChangedAt = v.OP_INS_ChangedAt
        AND
            [INS].OP_INS_Operations_Inserts = v.OP_INS_Operations_Inserts
        WHERE
            v.OP_INS_Version = @currentVersion;
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
            OP_INS_Version = @currentVersion
        AND
            OP_INS_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @OP_UPD_Operations_Updates TABLE (
        OP_UPD_OP_ID int not null,
        OP_UPD_ChangedAt datetime2(7) not null,
        OP_UPD_Operations_Updates int not null,
        OP_UPD_Version bigint not null,
        OP_UPD_StatementType char(1) not null,
        primary key(
            OP_UPD_Version,
            OP_UPD_OP_ID
        )
    );
    INSERT INTO @OP_UPD_Operations_Updates
    SELECT
        i.OP_UPD_OP_ID,
        i.OP_UPD_ChangedAt,
        i.OP_UPD_Operations_Updates,
        DENSE_RANK() OVER (
            PARTITION BY
                i.OP_UPD_OP_ID
            ORDER BY
                i.OP_UPD_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(OP_UPD_Version),
        @currentVersion = 0
    FROM
        @OP_UPD_Operations_Updates;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.OP_UPD_StatementType =
                CASE
                    WHEN [UPD].OP_UPD_OP_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [metadata].[rfOP_UPD_Operations_Updates](
                        v.OP_UPD_OP_ID,
                        v.OP_UPD_Operations_Updates,
                        v.OP_UPD_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @OP_UPD_Operations_Updates v
        LEFT JOIN
            [metadata].[OP_UPD_Operations_Updates] [UPD]
        ON
            [UPD].OP_UPD_OP_ID = v.OP_UPD_OP_ID
        AND
            [UPD].OP_UPD_ChangedAt = v.OP_UPD_ChangedAt
        AND
            [UPD].OP_UPD_Operations_Updates = v.OP_UPD_Operations_Updates
        WHERE
            v.OP_UPD_Version = @currentVersion;
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
            OP_UPD_Version = @currentVersion
        AND
            OP_UPD_StatementType in ('N');
    END
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @OP_DEL_Operations_Deletes TABLE (
        OP_DEL_OP_ID int not null,
        OP_DEL_ChangedAt datetime2(7) not null,
        OP_DEL_Operations_Deletes int not null,
        OP_DEL_Version bigint not null,
        OP_DEL_StatementType char(1) not null,
        primary key(
            OP_DEL_Version,
            OP_DEL_OP_ID
        )
    );
    INSERT INTO @OP_DEL_Operations_Deletes
    SELECT
        i.OP_DEL_OP_ID,
        i.OP_DEL_ChangedAt,
        i.OP_DEL_Operations_Deletes,
        DENSE_RANK() OVER (
            PARTITION BY
                i.OP_DEL_OP_ID
            ORDER BY
                i.OP_DEL_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(OP_DEL_Version),
        @currentVersion = 0
    FROM
        @OP_DEL_Operations_Deletes;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.OP_DEL_StatementType =
                CASE
                    WHEN [DEL].OP_DEL_OP_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [metadata].[rfOP_DEL_Operations_Deletes](
                        v.OP_DEL_OP_ID,
                        v.OP_DEL_Operations_Deletes,
                        v.OP_DEL_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @OP_DEL_Operations_Deletes v
        LEFT JOIN
            [metadata].[OP_DEL_Operations_Deletes] [DEL]
        ON
            [DEL].OP_DEL_OP_ID = v.OP_DEL_OP_ID
        AND
            [DEL].OP_DEL_ChangedAt = v.OP_DEL_ChangedAt
        AND
            [DEL].OP_DEL_Operations_Deletes = v.OP_DEL_Operations_Deletes
        WHERE
            v.OP_DEL_Version = @currentVersion;
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
            OP_DEL_Version = @currentVersion
        AND
            OP_DEL_StatementType in ('N');
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
-- it_lJB_Job instead of INSERT trigger on lJB_Job
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lJB_Job] ON [metadata].[lJB_Job]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
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
        JB_NAM_Job_Name varchar(255) null,
        JB_EST_JB_ID int null,
        JB_EST_ChangedAt datetime2(7) null,
        JB_EST_EST_ExecutionStatus varchar(42) null,
        JB_EST_EST_ID tinyint null,
        JB_AID_JB_ID int null,
        JB_AID_Job_AgentJobId uniqueidentifier null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.JB_ID, a.JB_ID),
        ISNULL(ISNULL(i.JB_STA_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_STA_Job_Start,
        ISNULL(ISNULL(i.JB_END_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_END_Job_End,
        ISNULL(ISNULL(i.JB_NAM_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_NAM_Job_Name,
        ISNULL(ISNULL(i.JB_EST_JB_ID, i.JB_ID), a.JB_ID),
        ISNULL(i.JB_EST_ChangedAt, @now),
        i.JB_EST_EST_ExecutionStatus,
        i.JB_EST_EST_ID,
        ISNULL(ISNULL(i.JB_AID_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_AID_Job_AgentJobId
    FROM (
        SELECT
            JB_ID,
            JB_STA_JB_ID,
            JB_STA_Job_Start,
            JB_END_JB_ID,
            JB_END_Job_End,
            JB_NAM_JB_ID,
            JB_NAM_Job_Name,
            JB_EST_JB_ID,
            JB_EST_ChangedAt,
            JB_EST_EST_ExecutionStatus,
            JB_EST_EST_ID,
            JB_AID_JB_ID,
            JB_AID_Job_AgentJobId,
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
    SELECT
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
    SELECT
        i.JB_END_JB_ID,
        i.JB_END_Job_End
    FROM
        @inserted i
    WHERE
        i.JB_END_Job_End is not null;
    INSERT INTO [metadata].[JB_NAM_Job_Name] (
        JB_NAM_JB_ID,
        JB_NAM_Job_Name
    )
    SELECT
        i.JB_NAM_JB_ID,
        i.JB_NAM_Job_Name
    FROM
        @inserted i
    WHERE
        i.JB_NAM_Job_Name is not null;
    INSERT INTO [metadata].[JB_EST_Job_ExecutionStatus] (
        JB_EST_JB_ID,
        JB_EST_ChangedAt,
        JB_EST_EST_ID
    )
    SELECT
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
        JB_AID_Job_AgentJobId
    )
    SELECT
        i.JB_AID_JB_ID,
        i.JB_AID_Job_AgentJobId
    FROM
        @inserted i
    WHERE
        i.JB_AID_Job_AgentJobId is not null;
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
    SET @now = sysdatetime();
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
        SELECT
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
        SELECT
            ISNULL(i.JB_END_JB_ID, i.JB_ID),
            i.JB_END_Job_End
        FROM
            inserted i
        WHERE
            i.JB_END_Job_End is not null;
    END
    IF(UPDATE(JB_NAM_JB_ID))
        RAISERROR('The foreign key column JB_NAM_JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_NAM_Job_Name))
    BEGIN
        INSERT INTO [metadata].[JB_NAM_Job_Name] (
            JB_NAM_JB_ID,
            JB_NAM_Job_Name
        )
        SELECT
            ISNULL(i.JB_NAM_JB_ID, i.JB_ID),
            i.JB_NAM_Job_Name
        FROM
            inserted i
        WHERE
            i.JB_NAM_Job_Name is not null;
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
        SELECT
            ISNULL(i.JB_EST_JB_ID, i.JB_ID),
            cast(CASE
                WHEN i.JB_EST_EST_ID is null AND [kEST].EST_ID is null THEN i.JB_EST_ChangedAt
                WHEN UPDATE(JB_EST_ChangedAt) THEN i.JB_EST_ChangedAt
                ELSE @now
            END as datetime2(7)),
            CASE WHEN UPDATE(JB_EST_EST_ID) THEN i.JB_EST_EST_ID ELSE [kEST].EST_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[EST_ExecutionStatus] [kEST]
        ON
            [kEST].EST_ExecutionStatus = i.JB_EST_EST_ExecutionStatus
        WHERE
            ISNULL(i.JB_EST_EST_ID, [kEST].EST_ID) is not null;
    END
    IF(UPDATE(JB_AID_JB_ID))
        RAISERROR('The foreign key column JB_AID_JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_AID_Job_AgentJobId))
    BEGIN
        INSERT INTO [metadata].[JB_AID_Job_AgentJobId] (
            JB_AID_JB_ID,
            JB_AID_Job_AgentJobId
        )
        SELECT
            ISNULL(i.JB_AID_JB_ID, i.JB_ID),
            i.JB_AID_Job_AgentJobId
        FROM
            inserted i
        WHERE
            i.JB_AID_Job_AgentJobId is not null;
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
    DELETE [JB]
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
        [metadata].[JB_EST_Job_ExecutionStatus] [EST]
    ON
        [EST].JB_EST_JB_ID = [JB].JB_ID
    LEFT JOIN
        [metadata].[JB_AID_Job_AgentJobId] [AID]
    ON
        [AID].JB_AID_JB_ID = [JB].JB_ID
    WHERE
        [STA].JB_STA_JB_ID is null
    AND
        [END].JB_END_JB_ID is null
    AND
        [NAM].JB_NAM_JB_ID is null
    AND
        [EST].JB_EST_JB_ID is null
    AND
        [AID].JB_AID_JB_ID is null;
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
    SET @now = sysdatetime();
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
    SELECT
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
    SELECT
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
    SELECT
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
    SELECT
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
    SET @now = sysdatetime();
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
        SELECT
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
        SELECT
            ISNULL(i.CO_TYP_CO_ID, i.CO_ID),
            CASE WHEN UPDATE(CO_TYP_COT_ID) THEN i.CO_TYP_COT_ID ELSE [kCOT].COT_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[COT_ContainerType] [kCOT]
        ON
            [kCOT].COT_ContainerType = i.CO_TYP_COT_ContainerType
        WHERE
            ISNULL(i.CO_TYP_COT_ID, [kCOT].COT_ID) is not null;
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
        SELECT
            ISNULL(i.CO_DSC_CO_ID, i.CO_ID),
            cast(CASE
                WHEN i.CO_DSC_Container_Discovered is null THEN i.CO_DSC_ChangedAt
                WHEN UPDATE(CO_DSC_ChangedAt) THEN i.CO_DSC_ChangedAt
                ELSE @now
            END as datetime2(7)),
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
        SELECT
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
    DELETE [CO]
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
        [metadata].[CO_DSC_Container_Discovered] [DSC]
    ON
        [DSC].CO_DSC_CO_ID = [CO].CO_ID
    LEFT JOIN
        [metadata].[CO_CRE_Container_Created] [CRE]
    ON
        [CRE].CO_CRE_CO_ID = [CO].CO_ID
    WHERE
        [NAM].CO_NAM_CO_ID is null
    AND
        [TYP].CO_TYP_CO_ID is null
    AND
        [DSC].CO_DSC_CO_ID is null
    AND
        [CRE].CO_CRE_CO_ID is null;
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
    SET @now = sysdatetime();
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
        WO_NAM_Work_Name varchar(255) null,
        WO_USR_WO_ID int null,
        WO_USR_Work_InvocationUser varchar(555) null,
        WO_ROL_WO_ID int null,
        WO_ROL_Work_InvocationRole varchar(42) null,
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
        i.WO_NAM_Work_Name,
        ISNULL(ISNULL(i.WO_USR_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_USR_Work_InvocationUser,
        ISNULL(ISNULL(i.WO_ROL_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_ROL_Work_InvocationRole,
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
            WO_NAM_Work_Name,
            WO_USR_WO_ID,
            WO_USR_Work_InvocationUser,
            WO_ROL_WO_ID,
            WO_ROL_Work_InvocationRole,
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
    SELECT
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
    SELECT
        i.WO_END_WO_ID,
        i.WO_END_Work_End
    FROM
        @inserted i
    WHERE
        i.WO_END_Work_End is not null;
    INSERT INTO [metadata].[WO_NAM_Work_Name] (
        WO_NAM_WO_ID,
        WO_NAM_Work_Name
    )
    SELECT
        i.WO_NAM_WO_ID,
        i.WO_NAM_Work_Name
    FROM
        @inserted i
    WHERE
        i.WO_NAM_Work_Name is not null;
    INSERT INTO [metadata].[WO_USR_Work_InvocationUser] (
        WO_USR_WO_ID,
        WO_USR_Work_InvocationUser
    )
    SELECT
        i.WO_USR_WO_ID,
        i.WO_USR_Work_InvocationUser
    FROM
        @inserted i
    WHERE
        i.WO_USR_Work_InvocationUser is not null;
    INSERT INTO [metadata].[WO_ROL_Work_InvocationRole] (
        WO_ROL_WO_ID,
        WO_ROL_Work_InvocationRole
    )
    SELECT
        i.WO_ROL_WO_ID,
        i.WO_ROL_Work_InvocationRole
    FROM
        @inserted i
    WHERE
        i.WO_ROL_Work_InvocationRole is not null;
    INSERT INTO [metadata].[WO_EST_Work_ExecutionStatus] (
        WO_EST_WO_ID,
        WO_EST_ChangedAt,
        WO_EST_EST_ID
    )
    SELECT
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
    SELECT
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
    SELECT
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
    SELECT
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
    SET @now = sysdatetime();
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
        SELECT
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
        SELECT
            ISNULL(i.WO_END_WO_ID, i.WO_ID),
            i.WO_END_Work_End
        FROM
            inserted i
        WHERE
            i.WO_END_Work_End is not null;
    END
    IF(UPDATE(WO_NAM_WO_ID))
        RAISERROR('The foreign key column WO_NAM_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_NAM_Work_Name))
    BEGIN
        INSERT INTO [metadata].[WO_NAM_Work_Name] (
            WO_NAM_WO_ID,
            WO_NAM_Work_Name
        )
        SELECT
            ISNULL(i.WO_NAM_WO_ID, i.WO_ID),
            i.WO_NAM_Work_Name
        FROM
            inserted i
        WHERE
            i.WO_NAM_Work_Name is not null;
    END
    IF(UPDATE(WO_USR_WO_ID))
        RAISERROR('The foreign key column WO_USR_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_USR_Work_InvocationUser))
    BEGIN
        INSERT INTO [metadata].[WO_USR_Work_InvocationUser] (
            WO_USR_WO_ID,
            WO_USR_Work_InvocationUser
        )
        SELECT
            ISNULL(i.WO_USR_WO_ID, i.WO_ID),
            i.WO_USR_Work_InvocationUser
        FROM
            inserted i
        WHERE
            i.WO_USR_Work_InvocationUser is not null;
    END
    IF(UPDATE(WO_ROL_WO_ID))
        RAISERROR('The foreign key column WO_ROL_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_ROL_Work_InvocationRole))
    BEGIN
        INSERT INTO [metadata].[WO_ROL_Work_InvocationRole] (
            WO_ROL_WO_ID,
            WO_ROL_Work_InvocationRole
        )
        SELECT
            ISNULL(i.WO_ROL_WO_ID, i.WO_ID),
            i.WO_ROL_Work_InvocationRole
        FROM
            inserted i
        WHERE
            i.WO_ROL_Work_InvocationRole is not null;
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
        SELECT
            ISNULL(i.WO_EST_WO_ID, i.WO_ID),
            cast(CASE
                WHEN i.WO_EST_EST_ID is null AND [kEST].EST_ID is null THEN i.WO_EST_ChangedAt
                WHEN UPDATE(WO_EST_ChangedAt) THEN i.WO_EST_ChangedAt
                ELSE @now
            END as datetime2(7)),
            CASE WHEN UPDATE(WO_EST_EST_ID) THEN i.WO_EST_EST_ID ELSE [kEST].EST_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[EST_ExecutionStatus] [kEST]
        ON
            [kEST].EST_ExecutionStatus = i.WO_EST_EST_ExecutionStatus
        WHERE
            ISNULL(i.WO_EST_EST_ID, [kEST].EST_ID) is not null;
    END
    IF(UPDATE(WO_ERL_WO_ID))
        RAISERROR('The foreign key column WO_ERL_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_ERL_Work_ErrorLine))
    BEGIN
        INSERT INTO [metadata].[WO_ERL_Work_ErrorLine] (
            WO_ERL_WO_ID,
            WO_ERL_Work_ErrorLine
        )
        SELECT
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
        SELECT
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
        SELECT
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
    DELETE [WO]
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
        [metadata].[WO_USR_Work_InvocationUser] [USR]
    ON
        [USR].WO_USR_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_ROL_Work_InvocationRole] [ROL]
    ON
        [ROL].WO_ROL_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_EST_Work_ExecutionStatus] [EST]
    ON
        [EST].WO_EST_WO_ID = [WO].WO_ID
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
        [AID].WO_AID_WO_ID = [WO].WO_ID
    WHERE
        [STA].WO_STA_WO_ID is null
    AND
        [END].WO_END_WO_ID is null
    AND
        [NAM].WO_NAM_WO_ID is null
    AND
        [USR].WO_USR_WO_ID is null
    AND
        [ROL].WO_ROL_WO_ID is null
    AND
        [EST].WO_EST_WO_ID is null
    AND
        [ERL].WO_ERL_WO_ID is null
    AND
        [ERM].WO_ERM_WO_ID is null
    AND
        [AID].WO_AID_WO_ID is null;
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
    SET @now = sysdatetime();
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
    SELECT
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
    SELECT
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
    SET @now = sysdatetime();
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
        SELECT
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
            cast(CASE
                WHEN i.CF_XML_Configuration_XMLDefinition is null THEN i.CF_XML_ChangedAt
                WHEN UPDATE(CF_XML_ChangedAt) THEN i.CF_XML_ChangedAt
                ELSE @now
            END as datetime),
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
        SELECT
            ISNULL(i.CF_TYP_CF_ID, i.CF_ID),
            CASE WHEN UPDATE(CF_TYP_CFT_ID) THEN i.CF_TYP_CFT_ID ELSE [kCFT].CFT_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[CFT_ConfigurationType] [kCFT]
        ON
            [kCFT].CFT_ConfigurationType = i.CF_TYP_CFT_ConfigurationType
        WHERE
            ISNULL(i.CF_TYP_CFT_ID, [kCFT].CFT_ID) is not null;
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
    DELETE [CF]
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
    LEFT JOIN
        [metadata].[CF_TYP_Configuration_Type] [TYP]
    ON
        [TYP].CF_TYP_CF_ID = [CF].CF_ID
    WHERE
        [NAM].CF_NAM_CF_ID is null
    AND
        [XML].CF_XML_CF_ID is null
    AND
        [TYP].CF_TYP_CF_ID is null;
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
    SET @now = sysdatetime();
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
    SELECT
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
    SELECT
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
    SELECT
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
    SET @now = sysdatetime();
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
        SELECT
            ISNULL(i.OP_INS_OP_ID, i.OP_ID),
            cast(CASE
                WHEN i.OP_INS_Operations_Inserts is null THEN i.OP_INS_ChangedAt
                WHEN UPDATE(OP_INS_ChangedAt) THEN i.OP_INS_ChangedAt
                ELSE @now
            END as datetime2(7)),
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
        SELECT
            ISNULL(i.OP_UPD_OP_ID, i.OP_ID),
            cast(CASE
                WHEN i.OP_UPD_Operations_Updates is null THEN i.OP_UPD_ChangedAt
                WHEN UPDATE(OP_UPD_ChangedAt) THEN i.OP_UPD_ChangedAt
                ELSE @now
            END as datetime2(7)),
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
        SELECT
            ISNULL(i.OP_DEL_OP_ID, i.OP_ID),
            cast(CASE
                WHEN i.OP_DEL_Operations_Deletes is null THEN i.OP_DEL_ChangedAt
                WHEN UPDATE(OP_DEL_ChangedAt) THEN i.OP_DEL_ChangedAt
                ELSE @now
            END as datetime2(7)),
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
    DELETE [OP]
    FROM
        [metadata].[OP_Operations] [OP]
    LEFT JOIN
        [metadata].[OP_INS_Operations_Inserts] [INS]
    ON
        [INS].OP_INS_OP_ID = [OP].OP_ID
    LEFT JOIN
        [metadata].[OP_UPD_Operations_Updates] [UPD]
    ON
        [UPD].OP_UPD_OP_ID = [OP].OP_ID
    LEFT JOIN
        [metadata].[OP_DEL_Operations_Deletes] [DEL]
    ON
        [DEL].OP_DEL_OP_ID = [OP].OP_ID
    WHERE
        [INS].OP_INS_OP_ID is null
    AND
        [UPD].OP_UPD_OP_ID is null
    AND
        [DEL].OP_DEL_OP_ID is null;
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
    [metadata].[pWO_part_JB_of](sysdatetime());
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
    [metadata].[pJB_formed_CF_from](sysdatetime());
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
    [metadata].[pWO_operates_CO_source_CO_target_OP_with](sysdatetime());
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
    [metadata].[pWO_formed_CF_from](sysdatetime());
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
-- it_WO_part_JB_of instead of INSERT trigger on WO_part_JB_of
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_part_JB_of', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_part_JB_of];
GO
CREATE TRIGGER [metadata].[it_WO_part_JB_of] ON [metadata].[WO_part_JB_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        WO_ID_part int not null,
        JB_ID_of int not null,
        primary key (
            WO_ID_part,
            JB_ID_of
        )
    );
    INSERT INTO @inserted
    SELECT
        i.WO_ID_part,
        i.JB_ID_of
    FROM
        inserted i
    WHERE
        i.WO_ID_part is not null
    AND
        i.JB_ID_of is not null;
    INSERT INTO [metadata].[WO_part_JB_of] (
        WO_ID_part,
        JB_ID_of
    )
    SELECT
        i.WO_ID_part,
        i.JB_ID_of
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[WO_part_JB_of] tie
    ON
        tie.WO_ID_part = i.WO_ID_part
    AND
        tie.JB_ID_of = i.JB_ID_of
    WHERE
        tie.JB_ID_of is null;
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
    SET @now = sysdatetime();
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
-- it_JB_formed_CF_from instead of INSERT trigger on JB_formed_CF_from
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_formed_CF_from', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_formed_CF_from];
GO
CREATE TRIGGER [metadata].[it_JB_formed_CF_from] ON [metadata].[JB_formed_CF_from]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        JB_ID_formed int not null,
        CF_ID_from int not null,
        primary key (
            JB_ID_formed
        )
    );
    INSERT INTO @inserted
    SELECT
        i.JB_ID_formed,
        i.CF_ID_from
    FROM
        inserted i
    WHERE
        i.JB_ID_formed is not null;
    INSERT INTO [metadata].[JB_formed_CF_from] (
        JB_ID_formed,
        CF_ID_from
    )
    SELECT
        i.JB_ID_formed,
        i.CF_ID_from
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[JB_formed_CF_from] tie
    ON
        tie.JB_ID_formed = i.JB_ID_formed
    WHERE
        tie.JB_ID_formed is null;
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
    SET @now = sysdatetime();
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
    SET @now = sysdatetime();
    IF(UPDATE(JB_ID_formed))
        RAISERROR('The identity column JB_ID_formed is not updatable.', 16, 1);
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
-- it_WO_operates_CO_source_CO_target_OP_with instead of INSERT trigger on WO_operates_CO_source_CO_target_OP_with
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_operates_CO_source_CO_target_OP_with', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_operates_CO_source_CO_target_OP_with];
GO
CREATE TRIGGER [metadata].[it_WO_operates_CO_source_CO_target_OP_with] ON [metadata].[WO_operates_CO_source_CO_target_OP_with]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        WO_ID_operates int not null,
        CO_ID_source int not null,
        CO_ID_target int not null,
        OP_ID_with int not null,
        primary key (
            WO_ID_operates,
            CO_ID_source,
            CO_ID_target
        )
    );
    INSERT INTO @inserted
    SELECT
        i.WO_ID_operates,
        i.CO_ID_source,
        i.CO_ID_target,
        i.OP_ID_with
    FROM
        inserted i
    WHERE
        i.WO_ID_operates is not null
    AND
        i.CO_ID_source is not null
    AND
        i.CO_ID_target is not null;
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
        @inserted i
    LEFT JOIN
        [metadata].[WO_operates_CO_source_CO_target_OP_with] tie
    ON
        tie.WO_ID_operates = i.WO_ID_operates
    AND
        tie.CO_ID_source = i.CO_ID_source
    AND
        tie.CO_ID_target = i.CO_ID_target
    WHERE
        tie.CO_ID_target is null;
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
    SET @now = sysdatetime();
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
    SET @now = sysdatetime();
    IF(UPDATE(WO_ID_operates))
        RAISERROR('The identity column WO_ID_operates is not updatable.', 16, 1);
    IF(UPDATE(CO_ID_source))
        RAISERROR('The identity column CO_ID_source is not updatable.', 16, 1);
    IF(UPDATE(CO_ID_target))
        RAISERROR('The identity column CO_ID_target is not updatable.', 16, 1);
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
-- it_WO_formed_CF_from instead of INSERT trigger on WO_formed_CF_from
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_formed_CF_from', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_formed_CF_from];
GO
CREATE TRIGGER [metadata].[it_WO_formed_CF_from] ON [metadata].[WO_formed_CF_from]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        WO_ID_formed int not null,
        CF_ID_from int not null,
        primary key (
            WO_ID_formed
        )
    );
    INSERT INTO @inserted
    SELECT
        i.WO_ID_formed,
        i.CF_ID_from
    FROM
        inserted i
    WHERE
        i.WO_ID_formed is not null;
    INSERT INTO [metadata].[WO_formed_CF_from] (
        WO_ID_formed,
        CF_ID_from
    )
    SELECT
        i.WO_ID_formed,
        i.CF_ID_from
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[WO_formed_CF_from] tie
    ON
        tie.WO_ID_formed = i.WO_ID_formed
    WHERE
        tie.WO_ID_formed is null;
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
    SET @now = sysdatetime();
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
    SET @now = sysdatetime();
    IF(UPDATE(WO_ID_formed))
        RAISERROR('The identity column WO_ID_formed is not updatable.', 16, 1);
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
      [version] int identity(1, 1) not null primary key,
      [activation] datetime2(7) not null,
      [schema] xml not null
   );
GO
-- Insert the XML schema (as of now)
INSERT INTO [metadata].[_Schema] (
   [activation],
   [schema]
)
SELECT
   current_timestamp,
   N'<schema format="0.98" date="2014-10-07" time="13:56:03"><metadata changingRange="datetime2(7)" encapsulation="metadata" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="false" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="tinyint" reliabilitySuffix="Reliability" reliableCutoff="1" deleteReliability="0" reliableSuffix="Reliable" partitioning="false" entityIntegrity="true" restatability="false" idempotency="true" assertiveness="false" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2(7)" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="false" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="uni"/><knot mnemonic="COT" descriptor="ContainerType" identity="tinyint" dataRange="varchar(42)"><metadata capsule="metadata" generator="false"/><layout x="660.61" y="964.81" fixed="false"/></knot><knot mnemonic="EST" descriptor="ExecutionStatus" identity="tinyint" dataRange="varchar(42)"><metadata capsule="metadata" generator="false"/><layout x="506.11" y="200.89" fixed="false"/></knot><knot mnemonic="CFT" descriptor="ConfigurationType" identity="tinyint" dataRange="varchar(42)"><metadata capsule="metadata" generator="false"/><layout x="1074.66" y="42.09" fixed="false"/></knot><anchor mnemonic="JB" descriptor="Job" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="STA" descriptor="Start" dataRange="datetime2(7)"><metadata capsule="metadata"/><layout x="583.58" y="50.36" fixed="false"/></attribute><attribute mnemonic="END" descriptor="End" dataRange="datetime2(7)"><metadata capsule="metadata"/><layout x="629.12" y="0.74" fixed="false"/></attribute><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(255)"><metadata capsule="metadata"/><layout x="666.58" y="-5.61" fixed="false"/></attribute><attribute mnemonic="EST" descriptor="ExecutionStatus" timeRange="datetime2(7)" knotRange="EST"><metadata capsule="metadata" restatable="false" idempotent="true"/><layout x="496.35" y="81.94" fixed="false"/></attribute><attribute mnemonic="AID" descriptor="AgentJobId" dataRange="uniqueidentifier"><metadata capsule="metadata"/><layout x="710.50" y="0.21" fixed="false"/></attribute><layout x="668.10" y="75.12" fixed="false"/></anchor><anchor mnemonic="CO" descriptor="Container" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(2000)"><metadata capsule="metadata"/><layout x="752.71" y="800.78" fixed="false"/></attribute><attribute mnemonic="TYP" descriptor="Type" knotRange="COT"><metadata capsule="metadata"/><layout x="705.73" y="924.86" fixed="false"/></attribute><attribute mnemonic="DSC" descriptor="Discovered" timeRange="datetime2(7)" dataRange="datetime"><metadata capsule="metadata" restatable="false" idempotent="true"/><layout x="644.06" y="863.43" fixed="false"/></attribute><attribute mnemonic="CRE" descriptor="Created" dataRange="datetime"><metadata capsule="metadata"/><layout x="762.78" y="850.76" fixed="false"/></attribute><layout x="696.11" y="803.70" fixed="false"/></anchor><anchor mnemonic="WO" descriptor="Work" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="STA" descriptor="Start" dataRange="datetime2(7)"><metadata capsule="metadata"/><layout x="548.26" y="459.23" fixed="false"/></attribute><attribute mnemonic="END" descriptor="End" dataRange="datetime2(7)"><metadata capsule="metadata"/><layout x="734.29" y="457.30" fixed="false"/></attribute><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(255)"><metadata capsule="metadata"/><layout x="682.12" y="495.19" fixed="false"/></attribute><attribute mnemonic="USR" descriptor="InvocationUser" dataRange="varchar(555)"><metadata capsule="metadata"/><layout x="546.47" y="428.86" fixed="false"/></attribute><attribute mnemonic="ROL" descriptor="InvocationRole" dataRange="varchar(42)"><metadata capsule="metadata"/><layout x="582.41" y="477.14" fixed="false"/></attribute><attribute mnemonic="EST" descriptor="ExecutionStatus" timeRange="datetime2(7)" knotRange="EST"><metadata capsule="metadata" restatable="false" idempotent="true"/><layout x="546.36" y="335.79" fixed="false"/></attribute><attribute mnemonic="ERL" descriptor="ErrorLine" dataRange="int"><metadata capsule="metadata"/><layout x="636.78" y="495.80" fixed="false"/></attribute><attribute mnemonic="ERM" descriptor="ErrorMessage" dataRange="varchar(555)"><metadata capsule="metadata"/><layout x="756.10" y="429.34" fixed="false"/></attribute><attribute mnemonic="AID" descriptor="AgentStepId" dataRange="smallint"><metadata capsule="metadata"/><layout x="698.71" y="398.67" fixed="false"/></attribute><layout x="649.90" y="429.97" fixed="false"/></anchor><anchor mnemonic="CF" descriptor="Configuration" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(255)"><metadata capsule="metadata"/><layout x="956.01" y="224.55" fixed="false"/></attribute><attribute mnemonic="XML" descriptor="XMLDefinition" timeRange="datetime" dataRange="xml"><metadata capsule="metadata" checksum="true" restatable="false" idempotent="true"/><layout x="986.18" y="189.11" fixed="false"/></attribute><attribute mnemonic="TYP" descriptor="Type" knotRange="CFT"><metadata capsule="metadata"/><layout x="1014.93" y="99.34" fixed="false"/></attribute><layout x="909.39" y="168.61" fixed="false"/></anchor><anchor mnemonic="OP" descriptor="Operations" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="INS" descriptor="Inserts" timeRange="datetime2(7)" dataRange="int"><metadata capsule="metadata" restatable="false" idempotent="true"/><layout x="923.44" y="697.54" fixed="false"/></attribute><attribute mnemonic="UPD" descriptor="Updates" timeRange="datetime2(7)" dataRange="int"><metadata capsule="metadata" restatable="false" idempotent="true"/><layout x="976.39" y="650.76" fixed="false"/></attribute><attribute mnemonic="DEL" descriptor="Deletes" timeRange="datetime2(7)" dataRange="int"><metadata capsule="metadata" restatable="false" idempotent="true"/><layout x="938.91" y="583.32" fixed="false"/></attribute><layout x="870.40" y="651.21" fixed="false"/></anchor><tie><anchorRole role="part" type="WO" identifier="true"/><anchorRole role="of" type="JB" identifier="true"/><metadata capsule="metadata"/><layout x="647.76" y="256.91" fixed="false"/></tie><tie><anchorRole role="formed" type="JB" identifier="true"/><anchorRole role="from" type="CF" identifier="false"/><metadata capsule="metadata"/><layout x="805.97" y="109.80" fixed="false"/></tie><tie><anchorRole role="operates" type="WO" identifier="true"/><anchorRole role="source" type="CO" identifier="true"/><anchorRole role="target" type="CO" identifier="true"/><anchorRole role="with" type="OP" identifier="false"/><metadata capsule="metadata"/><layout x="714.10" y="646.65" fixed="false"/></tie><tie><anchorRole role="formed" type="WO" identifier="true"/><anchorRole role="from" type="CF" identifier="false"/><metadata capsule="metadata"/><layout x="806.06" y="311.23" fixed="false"/></tie></schema>';
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
	[schema].value('schema[1]/@date', 'date') as [date],
	[schema].value('schema[1]/@time', 'time(0)') as [time],
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
	[schema].value('schema[1]/metadata[1]/@reliableCutoff', 'nvarchar(max)') as [reliableCutoff],
	[schema].value('schema[1]/metadata[1]/@deleteReliability', 'nvarchar(max)') as [deleteReliability],
	[schema].value('schema[1]/metadata[1]/@reliableSuffix', 'nvarchar(max)') as [reliableSuffix],
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
   Nodeset.anchor.value('count(attribute)', 'int') as [numberOfAttributes]
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
   isnull(Nodeset.knot.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent]
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
   isnull(Nodeset.attribute.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   Nodeset.attribute.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.attribute.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   ParentNodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [anchorMnemonic],
   ParentNodeset.anchor.value('@descriptor', 'nvarchar(max)') as [anchorDescriptor],
   ParentNodeset.anchor.value('@identity', 'nvarchar(max)') as [anchorIdentity],
   Nodeset.attribute.value('@dataRange', 'nvarchar(max)') as [dataRange],
   Nodeset.attribute.value('@knotRange', 'nvarchar(max)') as [knotRange],
   Nodeset.attribute.value('@timeRange', 'nvarchar(max)') as [timeRange]
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
   Nodeset.tie.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent]
FROM
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/tie') as Nodeset(tie);
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
    @timepoint AS DATETIME2(7)
)
RETURNS TABLE
RETURN
SELECT
   V.[version],
   ISNULL(S.[name], T.[name]) AS [name],
   ISNULL(V.[activation], T.[create_date]) AS [activation],
   CASE
      WHEN S.[name] is null THEN
         CASE
            WHEN T.[create_date] > (
               SELECT
                  ISNULL(MAX([activation]), @timepoint)
               FROM
                  [metadata].[_Schema]
               WHERE
                  [activation] <= @timepoint
            ) THEN 'Future'
            ELSE 'Past'
         END
      WHEN T.[name] is null THEN 'Missing'
      ELSE 'Present'
   END AS Existence
FROM (
   SELECT
      MAX([version]) as [version],
      MAX([activation]) as [activation]
   FROM
      [metadata].[_Schema]
   WHERE
      [activation] <= @timepoint
) V
JOIN (
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Anchor] a
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Knot] k
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Attribute] b
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Tie] t
) S
ON
   S.[version] = V.[version]
FULL OUTER JOIN (
   SELECT
      [name],
      [create_date]
   FROM
      sys.tables
   WHERE
      [type] like '%U%'
   AND
      LEFT([name], 1) <> '_'
) T
ON
   S.[name] = T.[name];
GO
-- Drop Script Generator ----------------------------------------------------------------------------------------------
-- generates a drop script, that must be run separately, dropping everything in an Anchor Modeled database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._GenerateDropScript', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_GenerateDropScript];
GO
CREATE PROCEDURE [metadata]._GenerateDropScript (
   @exclusionPattern varchar(42) = '[_]%', -- exclude Metadata by default
   @inclusionPattern varchar(42) = '%' -- include everything by default
)
AS
BEGIN
   DECLARE @xml XML;
   WITH objects AS (
      SELECT
         'DROP ' + ft.[type] + ' ' + fn.[name] + '; -- ' + fn.[description] as [statement],
         row_number() OVER (
            ORDER BY
               -- restatement finders last
               CASE dc.[description]
                  WHEN 'restatement finder' THEN 1
                  ELSE 0
               END ASC,
               -- order based on type
               CASE ft.[type]
                  WHEN 'PROCEDURE' THEN 1
                  WHEN 'FUNCTION' THEN 2
                  WHEN 'VIEW' THEN 3
                  WHEN 'TABLE' THEN 4
                  ELSE 5
               END ASC,
               -- order within type
               CASE dc.[description]
                  WHEN 'key generator' THEN 1
                  WHEN 'latest perspective' THEN 2
                  WHEN 'current perspective' THEN 3
                  WHEN 'difference perspective' THEN 4
                  WHEN 'point-in-time perspective' THEN 5
                  WHEN 'time traveler' THEN 6
                  WHEN 'rewinder' THEN 7
                  WHEN 'assembled view' THEN 8
                  WHEN 'annex table' THEN 9
                  WHEN 'posit table' THEN 10
                  WHEN 'table' THEN 11
                  WHEN 'restatement finder' THEN 12
                  ELSE 13
               END,
               -- order within description
               CASE ft.[type]
                  WHEN 'TABLE' THEN
                     CASE cl.[class]
                        WHEN 'Attribute' THEN 1
                        WHEN 'Attribute Annex' THEN 2
                        WHEN 'Attribute Posit' THEN 3
                        WHEN 'Tie' THEN 4
                        WHEN 'Anchor' THEN 5
                        WHEN 'Knot' THEN 6
                        ELSE 7
                     END
                  ELSE
                     CASE cl.[class]
                        WHEN 'Anchor' THEN 1
                        WHEN 'Attribute' THEN 2
                        WHEN 'Attribute Annex' THEN 3
                        WHEN 'Attribute Posit' THEN 4
                        WHEN 'Tie' THEN 5
                        WHEN 'Knot' THEN 6
                        ELSE 7
                     END
               END,
               -- finally alphabetically
               o.[name] ASC
         ) AS [ordinal]
      FROM
         sys.objects o
      JOIN
         sys.schemas s
      ON
         s.[schema_id] = o.[schema_id]
      CROSS APPLY (
         SELECT
            CASE
               WHEN o.[name] LIKE '[_]%'
               COLLATE Latin1_General_BIN THEN 'Metadata'
               WHEN o.[name] LIKE '%[A-Z][A-Z][_][a-z]%[A-Z][A-Z][_][a-z]%'
               COLLATE Latin1_General_BIN THEN 'Tie'
               WHEN o.[name] LIKE '%[A-Z][A-Z][_][A-Z][A-Z][A-Z][_][A-Z]%[_]%'
               COLLATE Latin1_General_BIN THEN 'Attribute'
               WHEN o.[name] LIKE '%[A-Z][A-Z][A-Z][_][A-Z]%'
               COLLATE Latin1_General_BIN THEN 'Knot'
               WHEN o.[name] LIKE '%[A-Z][A-Z][_][A-Z]%'
               COLLATE Latin1_General_BIN THEN 'Anchor'
               ELSE 'Other'
            END
      ) cl ([class])
      CROSS APPLY (
         SELECT
            CASE o.[type]
               WHEN 'P' THEN 'PROCEDURE'
               WHEN 'IF' THEN 'FUNCTION'
               WHEN 'FN' THEN 'FUNCTION'
               WHEN 'V' THEN 'VIEW'
               WHEN 'U' THEN 'TABLE'
            END
      ) ft ([type])
      CROSS APPLY (
         SELECT
            CASE
               WHEN ft.[type] = 'PROCEDURE' AND cl.[class] = 'Anchor' AND o.[name] LIKE 'k%'
               COLLATE Latin1_General_BIN THEN 'key generator'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 't%'
               COLLATE Latin1_General_BIN THEN 'time traveler'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'rf%'
               COLLATE Latin1_General_BIN THEN 'restatement finder'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'r%'
               COLLATE Latin1_General_BIN THEN 'rewinder'
               WHEN ft.[type] = 'VIEW' AND o.[name] LIKE 'l%'
               COLLATE Latin1_General_BIN THEN 'latest perspective'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'p%'
               COLLATE Latin1_General_BIN THEN 'point-in-time perspective'
               WHEN ft.[type] = 'VIEW' AND o.[name] LIKE 'n%'
               COLLATE Latin1_General_BIN THEN 'current perspective'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'd%'
               COLLATE Latin1_General_BIN THEN 'difference perspective'
               WHEN ft.[type] = 'VIEW' AND cl.[class] = 'Attribute'
               COLLATE Latin1_General_BIN THEN 'assembled view'
               WHEN ft.[type] = 'TABLE' AND o.[name] LIKE '%Annex'
               COLLATE Latin1_General_BIN THEN 'annex table'
               WHEN ft.[type] = 'TABLE' AND o.[name] LIKE '%Posit'
               COLLATE Latin1_General_BIN THEN 'posit table'
               WHEN ft.[type] = 'TABLE'
               COLLATE Latin1_General_BIN THEN 'table'
               ELSE 'other'
            END
      ) dc ([description])
      CROSS APPLY (
         SELECT
            s.[name] + '.' + o.[name],
            cl.[class] + ' ' + dc.[description]
      ) fn ([name], [description])
      WHERE
         o.[type] IN ('P', 'IF', 'FN', 'V', 'U')
      AND
         o.[name] NOT LIKE ISNULL(@exclusionPattern, '')
      AND
         o.[name] LIKE ISNULL(@inclusionPattern, '%')
   )
   SELECT @xml = (
       SELECT
          [statement] + CHAR(13) as [text()]
       FROM
          objects
       ORDER BY
          [ordinal]
       FOR XML PATH('')
   );
   SELECT isnull(@xml.value('.', 'varchar(max)'), ''); 
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
	declare @R char(1) = CHAR(13);
	-- stores the built SQL code
	declare @sql varchar(max) = 'USE ' + @target + ';' + @R;
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
	select @sql;
end
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
