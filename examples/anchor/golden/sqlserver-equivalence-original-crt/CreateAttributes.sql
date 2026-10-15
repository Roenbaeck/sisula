-- ATTRIBUTES (UNIFIED FOR ANCHORS AND NEXUSES) ---------------------------------------------------------------------
--
-- Attributes are mutable properties attached to either anchors or nexuses.
-- Flavors: static, historized, knotted static, knotted historized.
-- This unified script creates all attribute tables (posits and annexes) using the global attribute iterator.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_DAT_Event_Date_Posit', 'U') IS NULL
CREATE TABLE [attributes].[EV_DAT_Event_Date_Posit] (
    EV_DAT_ID int IDENTITY(1,1) not null,
    EV_ID numeric(12,0) not null,
    EV_DAT_Event_Date datetime2 not null,
    constraint fkEV_DAT_Event_Date_Posit foreign key (
        EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_DAT_Event_Date_Posit primary key nonclustered (
        EV_DAT_ID asc
    ),
    constraint uqEV_DAT_Event_Date_Posit unique clustered (
        EV_ID asc,
        EV_DAT_Event_Date asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Annex table (of EV_DAT_Event_Date_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_DAT_Event_Date_Annex', 'U') IS NULL
CREATE TABLE [attributes].[EV_DAT_Event_Date_Annex] (
    EV_DAT_ID int not null,
    EV_DAT_PositedAt datetime2 not null,
    EV_DAT_Positor tinyint not null,
    EV_DAT_Reliability decimal(5,2) not null,
    EV_DAT_Assertion as cast(
        case
            when EV_DAT_Reliability > 0 then '+'
            when EV_DAT_Reliability = 0 then '?'
            when EV_DAT_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_DAT int not null,
    constraint fkEV_DAT_Event_Date_Annex foreign key (
        EV_DAT_ID
    ) references [attributes].[EV_DAT_Event_Date_Posit](EV_DAT_ID),
    constraint pkEV_DAT_Event_Date_Annex primary key clustered (
        EV_DAT_ID asc,
        EV_DAT_Positor asc,
        EV_DAT_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_AUD_Event_Audience_Posit', 'U') IS NULL
CREATE TABLE [attributes].[EV_AUD_Event_Audience_Posit] (
    EV_AUD_ID int IDENTITY(1,1) not null,
    EV_ID numeric(12,0) not null,
    EV_AUD_Event_Audience int not null,
    constraint fkEV_AUD_Event_Audience_Posit foreign key (
        EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_AUD_Event_Audience_Posit primary key nonclustered (
        EV_AUD_ID asc
    ),
    constraint uqEV_AUD_Event_Audience_Posit unique clustered (
        EV_ID asc,
        EV_AUD_Event_Audience asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Annex table (of EV_AUD_Event_Audience_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_AUD_Event_Audience_Annex', 'U') IS NULL
CREATE TABLE [attributes].[EV_AUD_Event_Audience_Annex] (
    EV_AUD_ID int not null,
    EV_AUD_PositedAt datetime2 not null,
    EV_AUD_Positor tinyint not null,
    EV_AUD_Reliability decimal(5,2) not null,
    EV_AUD_Assertion as cast(
        case
            when EV_AUD_Reliability > 0 then '+'
            when EV_AUD_Reliability = 0 then '?'
            when EV_AUD_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_AUD int not null,
    constraint fkEV_AUD_Event_Audience_Annex foreign key (
        EV_AUD_ID
    ) references [attributes].[EV_AUD_Event_Audience_Posit](EV_AUD_ID),
    constraint pkEV_AUD_Event_Audience_Annex primary key clustered (
        EV_AUD_ID asc,
        EV_AUD_Positor asc,
        EV_AUD_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_REV_Event_Revenue_Posit', 'U') IS NULL
CREATE TABLE [attributes].[EV_REV_Event_Revenue_Posit] (
    EV_REV_ID int IDENTITY(1,1) not null,
    EV_ID numeric(12,0) not null,
    EV_REV_Event_Revenue decimal(19,4) not null,
    constraint fkEV_REV_Event_Revenue_Posit foreign key (
        EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_REV_Event_Revenue_Posit primary key nonclustered (
        EV_REV_ID asc
    ),
    constraint uqEV_REV_Event_Revenue_Posit unique clustered (
        EV_ID asc,
        EV_REV_Event_Revenue asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Annex table (of EV_REV_Event_Revenue_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_REV_Event_Revenue_Annex', 'U') IS NULL
CREATE TABLE [attributes].[EV_REV_Event_Revenue_Annex] (
    EV_REV_ID int not null,
    EV_REV_PositedAt datetime2 not null,
    EV_REV_Positor tinyint not null,
    EV_REV_Reliability decimal(5,2) not null,
    EV_REV_Assertion as cast(
        case
            when EV_REV_Reliability > 0 then '+'
            when EV_REV_Reliability = 0 then '?'
            when EV_REV_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_REV int not null,
    constraint fkEV_REV_Event_Revenue_Annex foreign key (
        EV_REV_ID
    ) references [attributes].[EV_REV_Event_Revenue_Posit](EV_REV_ID),
    constraint pkEV_REV_Event_Revenue_Annex primary key clustered (
        EV_REV_ID asc,
        EV_REV_Positor asc,
        EV_REV_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Event_Status_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_STA_Event_Status_Posit', 'U') IS NULL
CREATE TABLE [attributes].[EV_STA_Event_Status_Posit] (
    EV_STA_ID int IDENTITY(1,1) not null,
    EV_ID numeric(12,0) not null,
    EV_STA_Event_Status nvarchar(20) not null,
    EV_STA_ChangedAt datetime2 not null,
    constraint fkEV_STA_Event_Status_Posit foreign key (
        EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_STA_Event_Status_Posit primary key nonclustered (
        EV_STA_ID asc
    ),
    constraint uqEV_STA_Event_Status_Posit unique clustered (
        EV_ID asc,
        EV_STA_ChangedAt desc,
        EV_STA_Event_Status asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Event_Status_Annex table (of EV_STA_Event_Status_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_STA_Event_Status_Annex', 'U') IS NULL
CREATE TABLE [attributes].[EV_STA_Event_Status_Annex] (
    EV_STA_ID int not null,
    EV_STA_PositedAt datetime2 not null,
    EV_STA_Positor tinyint not null,
    EV_STA_Reliability decimal(5,2) not null,
    EV_STA_Assertion as cast(
        case
            when EV_STA_Reliability > 0 then '+'
            when EV_STA_Reliability = 0 then '?'
            when EV_STA_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_STA int not null,
    constraint fkEV_STA_Event_Status_Annex foreign key (
        EV_STA_ID
    ) references [attributes].[EV_STA_Event_Status_Posit](EV_STA_ID),
    constraint pkEV_STA_Event_Status_Annex primary key clustered (
        EV_STA_ID asc,
        EV_STA_Positor asc,
        EV_STA_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_UTL_Event_Utilization_Posit', 'U') IS NULL
CREATE TABLE [attributes].[EV_UTL_Event_Utilization_Posit] (
    EV_UTL_ID int IDENTITY(1,1) not null,
    EV_ID numeric(12,0) not null,
    UTL_ID tinyint not null,
    constraint fk_A_EV_UTL_Event_Utilization_Posit foreign key (
        EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint fk_K_EV_UTL_Event_Utilization_Posit foreign key (
        UTL_ID
    ) references [knots].[UTL_Utilization](UTL_ID),
    constraint pkEV_UTL_Event_Utilization_Posit primary key nonclustered (
        EV_UTL_ID asc
    ),
    constraint uqEV_UTL_Event_Utilization_Posit unique clustered (
        EV_ID asc,
        UTL_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Annex table (of EV_UTL_Event_Utilization_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_UTL_Event_Utilization_Annex', 'U') IS NULL
CREATE TABLE [attributes].[EV_UTL_Event_Utilization_Annex] (
    EV_UTL_ID int not null,
    EV_UTL_PositedAt datetime2 not null,
    EV_UTL_Positor tinyint not null,
    EV_UTL_Reliability decimal(5,2) not null,
    EV_UTL_Assertion as cast(
        case
            when EV_UTL_Reliability > 0 then '+'
            when EV_UTL_Reliability = 0 then '?'
            when EV_UTL_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_UTL int not null,
    constraint fkEV_UTL_Event_Utilization_Annex foreign key (
        EV_UTL_ID
    ) references [attributes].[EV_UTL_Event_Utilization_Posit](EV_UTL_ID),
    constraint pkEV_UTL_Event_Utilization_Annex primary key clustered (
        EV_UTL_ID asc,
        EV_UTL_Positor asc,
        EV_UTL_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Event_Level_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_LVL_Event_Level_Posit', 'U') IS NULL
CREATE TABLE [attributes].[EV_LVL_Event_Level_Posit] (
    EV_LVL_ID int IDENTITY(1,1) not null,
    EV_ID numeric(12,0) not null,
    PLV_ID tinyint not null,
    EV_LVL_ChangedAt date not null,
    constraint fk_A_EV_LVL_Event_Level_Posit foreign key (
        EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint fk_K_EV_LVL_Event_Level_Posit foreign key (
        PLV_ID
    ) references [knots].[PLV_ProfessionalLevel](PLV_ID),
    constraint pkEV_LVL_Event_Level_Posit primary key nonclustered (
        EV_LVL_ID asc
    ),
    constraint uqEV_LVL_Event_Level_Posit unique clustered (
        EV_ID asc,
        EV_LVL_ChangedAt desc,
        PLV_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Event_Level_Annex table (of EV_LVL_Event_Level_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_LVL_Event_Level_Annex', 'U') IS NULL
CREATE TABLE [attributes].[EV_LVL_Event_Level_Annex] (
    EV_LVL_ID int not null,
    EV_LVL_PositedAt datetime2 not null,
    EV_LVL_Positor tinyint not null,
    EV_LVL_Reliability decimal(5,2) not null,
    EV_LVL_Assertion as cast(
        case
            when EV_LVL_Reliability > 0 then '+'
            when EV_LVL_Reliability = 0 then '?'
            when EV_LVL_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_LVL int not null,
    constraint fkEV_LVL_Event_Level_Annex foreign key (
        EV_LVL_ID
    ) references [attributes].[EV_LVL_Event_Level_Posit](EV_LVL_ID),
    constraint pkEV_LVL_Event_Level_Annex primary key clustered (
        EV_LVL_ID asc,
        EV_LVL_Positor asc,
        EV_LVL_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_NAM_Stage_Name_Posit', 'U') IS NULL
CREATE TABLE [attributes].[ST_NAM_Stage_Name_Posit] (
    ST_NAM_ID int IDENTITY(1,1) not null,
    ST_ID int not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    ST_NAM_ChangedAt datetime2 not null,
    constraint fkST_NAM_Stage_Name_Posit foreign key (
        ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint pkST_NAM_Stage_Name_Posit primary key nonclustered (
        ST_NAM_ID asc
    ),
    constraint uqST_NAM_Stage_Name_Posit unique clustered (
        ST_ID asc,
        ST_NAM_ChangedAt desc,
        ST_NAM_Stage_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Annex table (of ST_NAM_Stage_Name_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_NAM_Stage_Name_Annex', 'U') IS NULL
CREATE TABLE [attributes].[ST_NAM_Stage_Name_Annex] (
    ST_NAM_ID int not null,
    ST_NAM_PositedAt datetime2 not null,
    ST_NAM_Positor tinyint not null,
    ST_NAM_Reliability decimal(5,2) not null,
    ST_NAM_Assertion as cast(
        case
            when ST_NAM_Reliability > 0 then '+'
            when ST_NAM_Reliability = 0 then '?'
            when ST_NAM_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_ST_NAM int not null,
    constraint fkST_NAM_Stage_Name_Annex foreign key (
        ST_NAM_ID
    ) references [attributes].[ST_NAM_Stage_Name_Posit](ST_NAM_ID),
    constraint pkST_NAM_Stage_Name_Annex primary key clustered (
        ST_NAM_ID asc,
        ST_NAM_Positor asc,
        ST_NAM_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_LOC_Stage_Location_Posit', 'U') IS NULL
CREATE TABLE [attributes].[ST_LOC_Stage_Location_Posit] (
    ST_LOC_ID int IDENTITY(1,1) not null,
    ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum as cast(dw.MD5(cast(ST_LOC_Stage_Location as varbinary(max))) as varbinary(16)) persisted,
    constraint fkST_LOC_Stage_Location_Posit foreign key (
        ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint pkST_LOC_Stage_Location_Posit primary key nonclustered (
        ST_LOC_ID asc
    ),
    constraint uqST_LOC_Stage_Location_Posit unique clustered (
        ST_ID asc,
        ST_LOC_Checksum asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Annex table (of ST_LOC_Stage_Location_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_LOC_Stage_Location_Annex', 'U') IS NULL
CREATE TABLE [attributes].[ST_LOC_Stage_Location_Annex] (
    ST_LOC_ID int not null,
    ST_LOC_PositedAt datetime2 not null,
    ST_LOC_Positor tinyint not null,
    ST_LOC_Reliability decimal(5,2) not null,
    ST_LOC_Assertion as cast(
        case
            when ST_LOC_Reliability > 0 then '+'
            when ST_LOC_Reliability = 0 then '?'
            when ST_LOC_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_ST_LOC int not null,
    constraint fkST_LOC_Stage_Location_Annex foreign key (
        ST_LOC_ID
    ) references [attributes].[ST_LOC_Stage_Location_Posit](ST_LOC_ID),
    constraint pkST_LOC_Stage_Location_Annex primary key clustered (
        ST_LOC_ID asc,
        ST_LOC_Positor asc,
        ST_LOC_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_AVG_Stage_Average_Posit', 'U') IS NULL
CREATE TABLE [attributes].[ST_AVG_Stage_Average_Posit] (
    ST_AVG_ID int IDENTITY(1,1) not null,
    ST_ID int not null,
    UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime2 not null,
    constraint fk_A_ST_AVG_Stage_Average_Posit foreign key (
        ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint fk_K_ST_AVG_Stage_Average_Posit foreign key (
        UTL_ID
    ) references [knots].[UTL_Utilization](UTL_ID),
    constraint pkST_AVG_Stage_Average_Posit primary key nonclustered (
        ST_AVG_ID asc
    ),
    constraint uqST_AVG_Stage_Average_Posit unique clustered (
        ST_ID asc,
        ST_AVG_ChangedAt desc,
        UTL_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Annex table (of ST_AVG_Stage_Average_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_AVG_Stage_Average_Annex', 'U') IS NULL
CREATE TABLE [attributes].[ST_AVG_Stage_Average_Annex] (
    ST_AVG_ID int not null,
    ST_AVG_PositedAt datetime2 not null,
    ST_AVG_Positor tinyint not null,
    ST_AVG_Reliability decimal(5,2) not null,
    ST_AVG_Assertion as cast(
        case
            when ST_AVG_Reliability > 0 then '+'
            when ST_AVG_Reliability = 0 then '?'
            when ST_AVG_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_ST_AVG int not null,
    constraint fkST_AVG_Stage_Average_Annex foreign key (
        ST_AVG_ID
    ) references [attributes].[ST_AVG_Stage_Average_Posit](ST_AVG_ID),
    constraint pkST_AVG_Stage_Average_Annex primary key clustered (
        ST_AVG_ID asc,
        ST_AVG_Positor asc,
        ST_AVG_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_MIN_Stage_Minimum_Posit', 'U') IS NULL
CREATE TABLE [attributes].[ST_MIN_Stage_Minimum_Posit] (
    ST_MIN_ID int IDENTITY(1,1) not null,
    ST_ID int not null,
    UTL_ID tinyint not null,
    constraint fk_A_ST_MIN_Stage_Minimum_Posit foreign key (
        ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum_Posit foreign key (
        UTL_ID
    ) references [knots].[UTL_Utilization](UTL_ID),
    constraint pkST_MIN_Stage_Minimum_Posit primary key nonclustered (
        ST_MIN_ID asc
    ),
    constraint uqST_MIN_Stage_Minimum_Posit unique clustered (
        ST_ID asc,
        UTL_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Annex table (of ST_MIN_Stage_Minimum_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_MIN_Stage_Minimum_Annex', 'U') IS NULL
CREATE TABLE [attributes].[ST_MIN_Stage_Minimum_Annex] (
    ST_MIN_ID int not null,
    ST_MIN_PositedAt datetime2 not null,
    ST_MIN_Positor tinyint not null,
    ST_MIN_Reliability decimal(5,2) not null,
    ST_MIN_Assertion as cast(
        case
            when ST_MIN_Reliability > 0 then '+'
            when ST_MIN_Reliability = 0 then '?'
            when ST_MIN_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_ST_MIN int not null,
    constraint fkST_MIN_Stage_Minimum_Annex foreign key (
        ST_MIN_ID
    ) references [attributes].[ST_MIN_Stage_Minimum_Posit](ST_MIN_ID),
    constraint pkST_MIN_Stage_Minimum_Annex primary key clustered (
        ST_MIN_ID asc,
        ST_MIN_Positor asc,
        ST_MIN_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_NAM_Actor_Name_Posit', 'U') IS NULL
CREATE TABLE [attributes].[AC_NAM_Actor_Name_Posit] (
    AC_NAM_ID int IDENTITY(1,1) not null,
    AC_ID smallint not null,
    AC_NAM_Actor_Name varbinary(max) not null,
    AC_NAM_ChangedAt datetime2 not null,
    constraint fkAC_NAM_Actor_Name_Posit foreign key (
        AC_ID
    ) references [anchors].[AC_Actor](AC_ID),
    constraint pkAC_NAM_Actor_Name_Posit primary key nonclustered (
        AC_NAM_ID asc
    ),
    constraint uqAC_NAM_Actor_Name_Posit unique clustered (
        AC_ID asc,
        AC_NAM_ChangedAt desc,
        AC_NAM_Actor_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Annex table (of AC_NAM_Actor_Name_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_NAM_Actor_Name_Annex', 'U') IS NULL
CREATE TABLE [attributes].[AC_NAM_Actor_Name_Annex] (
    AC_NAM_ID int not null,
    AC_NAM_PositedAt datetime2 not null,
    AC_NAM_Positor tinyint not null,
    AC_NAM_Reliability decimal(5,2) not null,
    AC_NAM_Assertion as cast(
        case
            when AC_NAM_Reliability > 0 then '+'
            when AC_NAM_Reliability = 0 then '?'
            when AC_NAM_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_AC_NAM int not null,
    constraint fkAC_NAM_Actor_Name_Annex foreign key (
        AC_NAM_ID
    ) references [attributes].[AC_NAM_Actor_Name_Posit](AC_NAM_ID),
    constraint pkAC_NAM_Actor_Name_Annex primary key clustered (
        AC_NAM_ID asc,
        AC_NAM_Positor asc,
        AC_NAM_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_GEN_Actor_Gender_Posit', 'U') IS NULL
CREATE TABLE [attributes].[AC_GEN_Actor_Gender_Posit] (
    AC_GEN_ID int IDENTITY(1,1) not null,
    AC_ID smallint not null,
    GEN_ID tinyint not null,
    constraint fk_A_AC_GEN_Actor_Gender_Posit foreign key (
        AC_ID
    ) references [anchors].[AC_Actor](AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender_Posit foreign key (
        GEN_ID
    ) references [knots].[GEN_Gender](GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Posit primary key nonclustered (
        AC_GEN_ID asc
    ),
    constraint uqAC_GEN_Actor_Gender_Posit unique clustered (
        AC_ID asc,
        GEN_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Annex table (of AC_GEN_Actor_Gender_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_GEN_Actor_Gender_Annex', 'U') IS NULL
CREATE TABLE [attributes].[AC_GEN_Actor_Gender_Annex] (
    AC_GEN_ID int not null,
    AC_GEN_PositedAt datetime2 not null,
    AC_GEN_Positor tinyint not null,
    AC_GEN_Reliability decimal(5,2) not null,
    AC_GEN_Assertion as cast(
        case
            when AC_GEN_Reliability > 0 then '+'
            when AC_GEN_Reliability = 0 then '?'
            when AC_GEN_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_AC_GEN int not null,
    constraint fkAC_GEN_Actor_Gender_Annex foreign key (
        AC_GEN_ID
    ) references [attributes].[AC_GEN_Actor_Gender_Posit](AC_GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Annex primary key clustered (
        AC_GEN_ID asc,
        AC_GEN_Positor asc,
        AC_GEN_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_PLV_Actor_ProfessionalLevel_Posit', 'U') IS NULL
CREATE TABLE [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit] (
    AC_PLV_ID int IDENTITY(1,1) not null,
    AC_ID smallint not null,
    PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime2 not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        AC_ID
    ) references [anchors].[AC_Actor](AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        PLV_ID
    ) references [knots].[PLV_ProfessionalLevel](PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Posit primary key nonclustered (
        AC_PLV_ID asc
    ),
    constraint uqAC_PLV_Actor_ProfessionalLevel_Posit unique clustered (
        AC_ID asc,
        AC_PLV_ChangedAt desc,
        PLV_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Annex table (of AC_PLV_Actor_ProfessionalLevel_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_PLV_Actor_ProfessionalLevel_Annex', 'U') IS NULL
CREATE TABLE [attributes].[AC_PLV_Actor_ProfessionalLevel_Annex] (
    AC_PLV_ID int not null,
    AC_PLV_PositedAt datetime2 not null,
    AC_PLV_Positor tinyint not null,
    AC_PLV_Reliability decimal(5,2) not null,
    AC_PLV_Assertion as cast(
        case
            when AC_PLV_Reliability > 0 then '+'
            when AC_PLV_Reliability = 0 then '?'
            when AC_PLV_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_AC_PLV int not null,
    constraint fkAC_PLV_Actor_ProfessionalLevel_Annex foreign key (
        AC_PLV_ID
    ) references [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit](AC_PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Annex primary key clustered (
        AC_PLV_ID asc,
        AC_PLV_Positor asc,
        AC_PLV_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_NAM_Program_Name_Posit', 'U') IS NULL
CREATE TABLE [attributes].[PR_NAM_Program_Name_Posit] (
    PR_NAM_ID int IDENTITY(1,1) not null,
    PR_ID bigint not null,
    PR_NAM_Program_Name nvarchar(42) not null,
    constraint fkPR_NAM_Program_Name_Posit foreign key (
        PR_ID
    ) references [anchors].[PR_Program](PR_ID),
    constraint pkPR_NAM_Program_Name_Posit primary key nonclustered (
        PR_NAM_ID asc
    ),
    constraint uqPR_NAM_Program_Name_Posit unique clustered (
        PR_ID asc,
        PR_NAM_Program_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Annex table (of PR_NAM_Program_Name_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_NAM_Program_Name_Annex', 'U') IS NULL
CREATE TABLE [attributes].[PR_NAM_Program_Name_Annex] (
    PR_NAM_ID int not null,
    PR_NAM_PositedAt datetime2 not null,
    PR_NAM_Positor tinyint not null,
    PR_NAM_Reliability decimal(5,2) not null,
    PR_NAM_Assertion as cast(
        case
            when PR_NAM_Reliability > 0 then '+'
            when PR_NAM_Reliability = 0 then '?'
            when PR_NAM_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_PR_NAM int not null,
    constraint fkPR_NAM_Program_Name_Annex foreign key (
        PR_NAM_ID
    ) references [attributes].[PR_NAM_Program_Name_Posit](PR_NAM_ID),
    constraint pkPR_NAM_Program_Name_Annex primary key clustered (
        PR_NAM_ID asc,
        PR_NAM_Positor asc,
        PR_NAM_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_LEN_Program_Length_Posit', 'U') IS NULL
CREATE TABLE [attributes].[PR_LEN_Program_Length_Posit] (
    PR_LEN_ID int IDENTITY(1,1) not null,
    PR_ID bigint not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length_Posit foreign key (
        PR_ID
    ) references [anchors].[PR_Program](PR_ID),
    constraint pkPR_LEN_Program_Length_Posit primary key nonclustered (
        PR_LEN_ID asc
    ),
    constraint uqPR_LEN_Program_Length_Posit unique clustered (
        PR_ID asc,
        PR_LEN_ChangedAt desc,
        PR_LEN_Program_Length asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Annex table (of PR_LEN_Program_Length_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_LEN_Program_Length_Annex', 'U') IS NULL
CREATE TABLE [attributes].[PR_LEN_Program_Length_Annex] (
    PR_LEN_ID int not null,
    PR_LEN_PositedAt datetime2 not null,
    PR_LEN_Positor tinyint not null,
    PR_LEN_Reliability decimal(5,2) not null,
    PR_LEN_Assertion as cast(
        case
            when PR_LEN_Reliability > 0 then '+'
            when PR_LEN_Reliability = 0 then '?'
            when PR_LEN_Reliability < 0 then '-'
        end
    as char(1)) persisted,
    Metadata_PR_LEN int not null,
    constraint fkPR_LEN_Program_Length_Annex foreign key (
        PR_LEN_ID
    ) references [attributes].[PR_LEN_Program_Length_Posit](PR_LEN_ID),
    constraint pkPR_LEN_Program_Length_Annex primary key clustered (
        PR_LEN_ID asc,
        PR_LEN_Positor asc,
        PR_LEN_PositedAt desc
    )
);
GO
