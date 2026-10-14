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
