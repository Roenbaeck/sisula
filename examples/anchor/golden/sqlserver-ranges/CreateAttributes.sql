-- ATTRIBUTES (UNIFIED FOR ANCHORS AND NEXUSES) ---------------------------------------------------------------------
--
-- Attributes are mutable properties attached to either anchors or nexuses.
-- Flavors: static, historized, knotted static, knotted historized.
-- This unified script creates all attribute tables using the global attribute iterator.
--
-- Static attribute table --------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_DAT_Event_Date', 'U') IS NULL
CREATE TABLE [attributes].[EV_DAT_Event_Date] (
    EV_DAT_EV_ID numeric(12,0) not null,
    EV_DAT_Event_Date datetime2 not null,
    Metadata_EV_DAT bigint not null,
    constraint fkEV_DAT_Event_Date foreign key (
        EV_DAT_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_DAT_Event_Date primary key (
        EV_DAT_EV_ID asc
    )
);
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_AUD_Event_Audience', 'U') IS NULL
CREATE TABLE [attributes].[EV_AUD_Event_Audience] (
    EV_AUD_EV_ID numeric(12,0) not null,
    EV_AUD_Event_Audience int not null,
    Metadata_EV_AUD bigint not null,
    constraint fkEV_AUD_Event_Audience foreign key (
        EV_AUD_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_AUD_Event_Audience primary key (
        EV_AUD_EV_ID asc
    )
);
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_REV_Event_Revenue', 'U') IS NULL
CREATE TABLE [attributes].[EV_REV_Event_Revenue] (
    EV_REV_EV_ID numeric(12,0) not null,
    EV_REV_Event_Revenue decimal(19,4) not null,
    Metadata_EV_REV bigint not null,
    constraint fkEV_REV_Event_Revenue foreign key (
        EV_REV_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_REV_Event_Revenue primary key (
        EV_REV_EV_ID asc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- EV_STA_Event_Status table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_STA_Event_Status', 'U') IS NULL
CREATE TABLE [attributes].[EV_STA_Event_Status] (
    EV_STA_EV_ID numeric(12,0) not null,
    EV_STA_Event_Status nvarchar(20) not null,
    EV_STA_ChangedAt datetime2 not null,
    Metadata_EV_STA bigint not null,
    constraint fkEV_STA_Event_Status foreign key (
        EV_STA_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_STA_Event_Status primary key (
        EV_STA_EV_ID asc,
        EV_STA_ChangedAt desc
    )
);
GO
-- Knotted static attribute table ------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_UTL_Event_Utilization', 'U') IS NULL
CREATE TABLE [attributes].[EV_UTL_Event_Utilization] (
    EV_UTL_EV_ID numeric(12,0) not null,
    EV_UTL_UTL_ID tinyint not null,
    Metadata_EV_UTL bigint not null,
    constraint fk_A_EV_UTL_Event_Utilization foreign key (
        EV_UTL_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint fk_K_EV_UTL_Event_Utilization foreign key (
        EV_UTL_UTL_ID
    ) references [knots].[UTL_Utilization](UTL_ID),
    constraint pkEV_UTL_Event_Utilization primary key (
        EV_UTL_EV_ID asc
    )
);
GO
-- Knotted historized attribute table --------------------------------------------------------------------------------
-- EV_LVL_Event_Level table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_LVL_Event_Level', 'U') IS NULL
CREATE TABLE [attributes].[EV_LVL_Event_Level] (
    EV_LVL_EV_ID numeric(12,0) not null,
    EV_LVL_PLV_ID tinyint not null,
    EV_LVL_ChangedAt date not null,
    Metadata_EV_LVL bigint not null,
    constraint fk_A_EV_LVL_Event_Level foreign key (
        EV_LVL_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint fk_K_EV_LVL_Event_Level foreign key (
        EV_LVL_PLV_ID
    ) references [knots].[PLV_ProfessionalLevel](PLV_ID),
    constraint pkEV_LVL_Event_Level primary key (
        EV_LVL_EV_ID asc,
        EV_LVL_ChangedAt desc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_NAM_Stage_Name', 'U') IS NULL
CREATE TABLE [attributes].[ST_NAM_Stage_Name] (
    ST_NAM_ST_ID int not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    ST_NAM_ChangedAt datetime2 not null,
    Metadata_ST_NAM bigint not null,
    constraint fkST_NAM_Stage_Name foreign key (
        ST_NAM_ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint pkST_NAM_Stage_Name primary key (
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc
    )
);
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_LOC_Stage_Location', 'U') IS NULL
CREATE TABLE [attributes].[ST_LOC_Stage_Location] (
    ST_LOC_ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum as cast(dw.MD5(cast(ST_LOC_Stage_Location as varbinary(max))) as varbinary(16)) persisted,
    Metadata_ST_LOC bigint not null,
    constraint fkST_LOC_Stage_Location foreign key (
        ST_LOC_ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint pkST_LOC_Stage_Location primary key (
        ST_LOC_ST_ID asc
    )
);
GO
-- Knotted historized attribute table --------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_AVG_Stage_Average', 'U') IS NULL
CREATE TABLE [attributes].[ST_AVG_Stage_Average] (
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime2 not null,
    Metadata_ST_AVG bigint not null,
    constraint fk_A_ST_AVG_Stage_Average foreign key (
        ST_AVG_ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint fk_K_ST_AVG_Stage_Average foreign key (
        ST_AVG_UTL_ID
    ) references [knots].[UTL_Utilization](UTL_ID),
    constraint pkST_AVG_Stage_Average primary key (
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc
    )
);
GO
-- Knotted static attribute table ------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_MIN_Stage_Minimum', 'U') IS NULL
CREATE TABLE [attributes].[ST_MIN_Stage_Minimum] (
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    Metadata_ST_MIN bigint not null,
    constraint fk_A_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_UTL_ID
    ) references [knots].[UTL_Utilization](UTL_ID),
    constraint pkST_MIN_Stage_Minimum primary key (
        ST_MIN_ST_ID asc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_NAM_Actor_Name', 'U') IS NULL
CREATE TABLE [attributes].[AC_NAM_Actor_Name] (
    AC_NAM_AC_ID smallint not null,
    AC_NAM_Actor_Name varbinary(max) not null,
    AC_NAM_ChangedAt datetime2 not null,
    Metadata_AC_NAM bigint not null,
    constraint fkAC_NAM_Actor_Name foreign key (
        AC_NAM_AC_ID
    ) references [anchors].[AC_Actor](AC_ID),
    constraint pkAC_NAM_Actor_Name primary key (
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc
    )
);
GO
-- Knotted static attribute table ------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_GEN_Actor_Gender', 'U') IS NULL
CREATE TABLE [attributes].[AC_GEN_Actor_Gender] (
    AC_GEN_AC_ID smallint not null,
    AC_GEN_GEN_ID tinyint not null,
    Metadata_AC_GEN bigint not null,
    constraint fk_A_AC_GEN_Actor_Gender foreign key (
        AC_GEN_AC_ID
    ) references [anchors].[AC_Actor](AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender foreign key (
        AC_GEN_GEN_ID
    ) references [knots].[GEN_Gender](GEN_ID),
    constraint pkAC_GEN_Actor_Gender primary key (
        AC_GEN_AC_ID asc
    )
);
GO
-- Knotted historized attribute table --------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_PLV_Actor_ProfessionalLevel', 'U') IS NULL
CREATE TABLE [attributes].[AC_PLV_Actor_ProfessionalLevel] (
    AC_PLV_AC_ID smallint not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime2 not null,
    Metadata_AC_PLV bigint not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_AC_ID
    ) references [anchors].[AC_Actor](AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_PLV_ID
    ) references [knots].[PLV_ProfessionalLevel](PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel primary key (
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc
    )
);
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_NAM_Program_Name', 'U') IS NULL
CREATE TABLE [attributes].[PR_NAM_Program_Name] (
    PR_NAM_PR_ID bigint not null,
    PR_NAM_Program_Name nvarchar(42) not null,
    Metadata_PR_NAM bigint not null,
    constraint fkPR_NAM_Program_Name foreign key (
        PR_NAM_PR_ID
    ) references [anchors].[PR_Program](PR_ID),
    constraint pkPR_NAM_Program_Name primary key (
        PR_NAM_PR_ID asc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_LEN_Program_Length', 'U') IS NULL
CREATE TABLE [attributes].[PR_LEN_Program_Length] (
    PR_LEN_PR_ID bigint not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    Metadata_PR_LEN bigint not null,
    constraint fkPR_LEN_Program_Length foreign key (
        PR_LEN_PR_ID
    ) references [anchors].[PR_Program](PR_ID),
    constraint pkPR_LEN_Program_Length primary key (
        PR_LEN_PR_ID asc,
        PR_LEN_ChangedAt desc
    )
);
GO
