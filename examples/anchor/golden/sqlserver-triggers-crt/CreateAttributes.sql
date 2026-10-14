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
