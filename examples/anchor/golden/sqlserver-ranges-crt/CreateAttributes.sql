-- ATTRIBUTES (UNIFIED FOR ANCHORS AND NEXUSES) ---------------------------------------------------------------------
--
-- Attributes are mutable properties attached to either anchors or nexuses.
-- Flavors: static, historized, knotted static, knotted historized.
-- This unified script creates all attribute tables (posits and annexes) using the global attribute iterator.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_DAT_Event_Date_Fact', 'U') IS NULL
CREATE TABLE [attributes].[EV_DAT_Event_Date_Fact] (
    EV_DAT_ID bigint IDENTITY(1,1) not null,
    EV_DAT_EV_ID numeric(12,0) not null,
    EV_DAT_Event_Date datetime2 not null,
    constraint fkEV_DAT_Event_Date_Fact foreign key (
        EV_DAT_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_DAT_Event_Date_Fact primary key nonclustered (
        EV_DAT_ID asc
    ),
    constraint uqEV_DAT_Event_Date_Fact unique clustered (
        EV_DAT_EV_ID asc,
        EV_DAT_Event_Date asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Meta table (of EV_DAT_Event_Date_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_DAT_Event_Date_Meta', 'U') IS NULL
CREATE TABLE [attributes].[EV_DAT_Event_Date_Meta] (
    EV_DAT_ID bigint not null,
    EV_DAT_PositedAt datetime2(3) not null,
    EV_DAT_Who smallint not null,
    EV_DAT_Confidence decimal(7,3) not null,
    EV_DAT_Stance as cast(
        case
            when EV_DAT_Confidence > 0.25 then '+'
            when EV_DAT_Confidence = 0.25 then '?'
            when EV_DAT_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_DAT bigint not null,
    constraint fkEV_DAT_Event_Date_Meta foreign key (
        EV_DAT_ID
    ) references [attributes].[EV_DAT_Event_Date_Fact](EV_DAT_ID),
    constraint pkEV_DAT_Event_Date_Meta primary key clustered (
        EV_DAT_ID asc,
        EV_DAT_Who asc,
        EV_DAT_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_AUD_Event_Audience_Fact', 'U') IS NULL
CREATE TABLE [attributes].[EV_AUD_Event_Audience_Fact] (
    EV_AUD_ID bigint IDENTITY(1,1) not null,
    EV_AUD_EV_ID numeric(12,0) not null,
    EV_AUD_Event_Audience int not null,
    constraint fkEV_AUD_Event_Audience_Fact foreign key (
        EV_AUD_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_AUD_Event_Audience_Fact primary key nonclustered (
        EV_AUD_ID asc
    ),
    constraint uqEV_AUD_Event_Audience_Fact unique clustered (
        EV_AUD_EV_ID asc,
        EV_AUD_Event_Audience asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Meta table (of EV_AUD_Event_Audience_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_AUD_Event_Audience_Meta', 'U') IS NULL
CREATE TABLE [attributes].[EV_AUD_Event_Audience_Meta] (
    EV_AUD_ID bigint not null,
    EV_AUD_PositedAt datetime2(3) not null,
    EV_AUD_Who smallint not null,
    EV_AUD_Confidence decimal(7,3) not null,
    EV_AUD_Stance as cast(
        case
            when EV_AUD_Confidence > 0.25 then '+'
            when EV_AUD_Confidence = 0.25 then '?'
            when EV_AUD_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_AUD bigint not null,
    constraint fkEV_AUD_Event_Audience_Meta foreign key (
        EV_AUD_ID
    ) references [attributes].[EV_AUD_Event_Audience_Fact](EV_AUD_ID),
    constraint pkEV_AUD_Event_Audience_Meta primary key clustered (
        EV_AUD_ID asc,
        EV_AUD_Who asc,
        EV_AUD_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_REV_Event_Revenue_Fact', 'U') IS NULL
CREATE TABLE [attributes].[EV_REV_Event_Revenue_Fact] (
    EV_REV_ID bigint IDENTITY(1,1) not null,
    EV_REV_EV_ID numeric(12,0) not null,
    EV_REV_Event_Revenue decimal(19,4) not null,
    constraint fkEV_REV_Event_Revenue_Fact foreign key (
        EV_REV_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_REV_Event_Revenue_Fact primary key nonclustered (
        EV_REV_ID asc
    ),
    constraint uqEV_REV_Event_Revenue_Fact unique clustered (
        EV_REV_EV_ID asc,
        EV_REV_Event_Revenue asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Meta table (of EV_REV_Event_Revenue_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_REV_Event_Revenue_Meta', 'U') IS NULL
CREATE TABLE [attributes].[EV_REV_Event_Revenue_Meta] (
    EV_REV_ID bigint not null,
    EV_REV_PositedAt datetime2(3) not null,
    EV_REV_Who smallint not null,
    EV_REV_Confidence decimal(7,3) not null,
    EV_REV_Stance as cast(
        case
            when EV_REV_Confidence > 0.25 then '+'
            when EV_REV_Confidence = 0.25 then '?'
            when EV_REV_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_REV bigint not null,
    constraint fkEV_REV_Event_Revenue_Meta foreign key (
        EV_REV_ID
    ) references [attributes].[EV_REV_Event_Revenue_Fact](EV_REV_ID),
    constraint pkEV_REV_Event_Revenue_Meta primary key clustered (
        EV_REV_ID asc,
        EV_REV_Who asc,
        EV_REV_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Event_Status_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_STA_Event_Status_Fact', 'U') IS NULL
CREATE TABLE [attributes].[EV_STA_Event_Status_Fact] (
    EV_STA_ID bigint IDENTITY(1,1) not null,
    EV_STA_EV_ID numeric(12,0) not null,
    EV_STA_Event_Status nvarchar(20) not null,
    EV_STA_ChangedAt datetime2 not null,
    constraint fkEV_STA_Event_Status_Fact foreign key (
        EV_STA_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint pkEV_STA_Event_Status_Fact primary key nonclustered (
        EV_STA_ID asc
    ),
    constraint uqEV_STA_Event_Status_Fact unique clustered (
        EV_STA_EV_ID asc,
        EV_STA_ChangedAt desc,
        EV_STA_Event_Status asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Event_Status_Meta table (of EV_STA_Event_Status_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_STA_Event_Status_Meta', 'U') IS NULL
CREATE TABLE [attributes].[EV_STA_Event_Status_Meta] (
    EV_STA_ID bigint not null,
    EV_STA_PositedAt datetime2(3) not null,
    EV_STA_Who smallint not null,
    EV_STA_Confidence decimal(7,3) not null,
    EV_STA_Stance as cast(
        case
            when EV_STA_Confidence > 0.25 then '+'
            when EV_STA_Confidence = 0.25 then '?'
            when EV_STA_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_STA bigint not null,
    constraint fkEV_STA_Event_Status_Meta foreign key (
        EV_STA_ID
    ) references [attributes].[EV_STA_Event_Status_Fact](EV_STA_ID),
    constraint pkEV_STA_Event_Status_Meta primary key clustered (
        EV_STA_ID asc,
        EV_STA_Who asc,
        EV_STA_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_UTL_Event_Utilization_Fact', 'U') IS NULL
CREATE TABLE [attributes].[EV_UTL_Event_Utilization_Fact] (
    EV_UTL_ID bigint IDENTITY(1,1) not null,
    EV_UTL_EV_ID numeric(12,0) not null,
    EV_UTL_UTL_ID tinyint not null,
    constraint fk_A_EV_UTL_Event_Utilization_Fact foreign key (
        EV_UTL_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint fk_K_EV_UTL_Event_Utilization_Fact foreign key (
        EV_UTL_UTL_ID
    ) references [knots].[UTL_Utilization](UTL_ID),
    constraint pkEV_UTL_Event_Utilization_Fact primary key nonclustered (
        EV_UTL_ID asc
    ),
    constraint uqEV_UTL_Event_Utilization_Fact unique clustered (
        EV_UTL_EV_ID asc,
        EV_UTL_UTL_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Meta table (of EV_UTL_Event_Utilization_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_UTL_Event_Utilization_Meta', 'U') IS NULL
CREATE TABLE [attributes].[EV_UTL_Event_Utilization_Meta] (
    EV_UTL_ID bigint not null,
    EV_UTL_PositedAt datetime2(3) not null,
    EV_UTL_Who smallint not null,
    EV_UTL_Confidence decimal(7,3) not null,
    EV_UTL_Stance as cast(
        case
            when EV_UTL_Confidence > 0.25 then '+'
            when EV_UTL_Confidence = 0.25 then '?'
            when EV_UTL_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_UTL bigint not null,
    constraint fkEV_UTL_Event_Utilization_Meta foreign key (
        EV_UTL_ID
    ) references [attributes].[EV_UTL_Event_Utilization_Fact](EV_UTL_ID),
    constraint pkEV_UTL_Event_Utilization_Meta primary key clustered (
        EV_UTL_ID asc,
        EV_UTL_Who asc,
        EV_UTL_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Event_Level_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_LVL_Event_Level_Fact', 'U') IS NULL
CREATE TABLE [attributes].[EV_LVL_Event_Level_Fact] (
    EV_LVL_ID bigint IDENTITY(1,1) not null,
    EV_LVL_EV_ID numeric(12,0) not null,
    EV_LVL_PLV_ID tinyint not null,
    EV_LVL_ChangedAt date not null,
    constraint fk_A_EV_LVL_Event_Level_Fact foreign key (
        EV_LVL_EV_ID
    ) references [nexuses].[EV_Event](EV_ID),
    constraint fk_K_EV_LVL_Event_Level_Fact foreign key (
        EV_LVL_PLV_ID
    ) references [knots].[PLV_ProfessionalLevel](PLV_ID),
    constraint pkEV_LVL_Event_Level_Fact primary key nonclustered (
        EV_LVL_ID asc
    ),
    constraint uqEV_LVL_Event_Level_Fact unique clustered (
        EV_LVL_EV_ID asc,
        EV_LVL_ChangedAt desc,
        EV_LVL_PLV_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Event_Level_Meta table (of EV_LVL_Event_Level_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_LVL_Event_Level_Meta', 'U') IS NULL
CREATE TABLE [attributes].[EV_LVL_Event_Level_Meta] (
    EV_LVL_ID bigint not null,
    EV_LVL_PositedAt datetime2(3) not null,
    EV_LVL_Who smallint not null,
    EV_LVL_Confidence decimal(7,3) not null,
    EV_LVL_Stance as cast(
        case
            when EV_LVL_Confidence > 0.25 then '+'
            when EV_LVL_Confidence = 0.25 then '?'
            when EV_LVL_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_EV_LVL bigint not null,
    constraint fkEV_LVL_Event_Level_Meta foreign key (
        EV_LVL_ID
    ) references [attributes].[EV_LVL_Event_Level_Fact](EV_LVL_ID),
    constraint pkEV_LVL_Event_Level_Meta primary key clustered (
        EV_LVL_ID asc,
        EV_LVL_Who asc,
        EV_LVL_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_NAM_Stage_Name_Fact', 'U') IS NULL
CREATE TABLE [attributes].[ST_NAM_Stage_Name_Fact] (
    ST_NAM_ID bigint IDENTITY(1,1) not null,
    ST_NAM_ST_ID int not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    ST_NAM_ChangedAt datetime2 not null,
    constraint fkST_NAM_Stage_Name_Fact foreign key (
        ST_NAM_ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint pkST_NAM_Stage_Name_Fact primary key nonclustered (
        ST_NAM_ID asc
    ),
    constraint uqST_NAM_Stage_Name_Fact unique clustered (
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc,
        ST_NAM_Stage_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Meta table (of ST_NAM_Stage_Name_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_NAM_Stage_Name_Meta', 'U') IS NULL
CREATE TABLE [attributes].[ST_NAM_Stage_Name_Meta] (
    ST_NAM_ID bigint not null,
    ST_NAM_PositedAt datetime2(3) not null,
    ST_NAM_Who smallint not null,
    ST_NAM_Confidence decimal(7,3) not null,
    ST_NAM_Stance as cast(
        case
            when ST_NAM_Confidence > 0.25 then '+'
            when ST_NAM_Confidence = 0.25 then '?'
            when ST_NAM_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_ST_NAM bigint not null,
    constraint fkST_NAM_Stage_Name_Meta foreign key (
        ST_NAM_ID
    ) references [attributes].[ST_NAM_Stage_Name_Fact](ST_NAM_ID),
    constraint pkST_NAM_Stage_Name_Meta primary key clustered (
        ST_NAM_ID asc,
        ST_NAM_Who asc,
        ST_NAM_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_LOC_Stage_Location_Fact', 'U') IS NULL
CREATE TABLE [attributes].[ST_LOC_Stage_Location_Fact] (
    ST_LOC_ID bigint IDENTITY(1,1) not null,
    ST_LOC_ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum as cast(dw.MD5(cast(ST_LOC_Stage_Location as varbinary(max))) as varbinary(16)) persisted,
    constraint fkST_LOC_Stage_Location_Fact foreign key (
        ST_LOC_ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint pkST_LOC_Stage_Location_Fact primary key nonclustered (
        ST_LOC_ID asc
    ),
    constraint uqST_LOC_Stage_Location_Fact unique clustered (
        ST_LOC_ST_ID asc,
        ST_LOC_Checksum asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Meta table (of ST_LOC_Stage_Location_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_LOC_Stage_Location_Meta', 'U') IS NULL
CREATE TABLE [attributes].[ST_LOC_Stage_Location_Meta] (
    ST_LOC_ID bigint not null,
    ST_LOC_PositedAt datetime2(3) not null,
    ST_LOC_Who smallint not null,
    ST_LOC_Confidence decimal(7,3) not null,
    ST_LOC_Stance as cast(
        case
            when ST_LOC_Confidence > 0.25 then '+'
            when ST_LOC_Confidence = 0.25 then '?'
            when ST_LOC_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_ST_LOC bigint not null,
    constraint fkST_LOC_Stage_Location_Meta foreign key (
        ST_LOC_ID
    ) references [attributes].[ST_LOC_Stage_Location_Fact](ST_LOC_ID),
    constraint pkST_LOC_Stage_Location_Meta primary key clustered (
        ST_LOC_ID asc,
        ST_LOC_Who asc,
        ST_LOC_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_AVG_Stage_Average_Fact', 'U') IS NULL
CREATE TABLE [attributes].[ST_AVG_Stage_Average_Fact] (
    ST_AVG_ID bigint IDENTITY(1,1) not null,
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime2 not null,
    constraint fk_A_ST_AVG_Stage_Average_Fact foreign key (
        ST_AVG_ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint fk_K_ST_AVG_Stage_Average_Fact foreign key (
        ST_AVG_UTL_ID
    ) references [knots].[UTL_Utilization](UTL_ID),
    constraint pkST_AVG_Stage_Average_Fact primary key nonclustered (
        ST_AVG_ID asc
    ),
    constraint uqST_AVG_Stage_Average_Fact unique clustered (
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc,
        ST_AVG_UTL_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Meta table (of ST_AVG_Stage_Average_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_AVG_Stage_Average_Meta', 'U') IS NULL
CREATE TABLE [attributes].[ST_AVG_Stage_Average_Meta] (
    ST_AVG_ID bigint not null,
    ST_AVG_PositedAt datetime2(3) not null,
    ST_AVG_Who smallint not null,
    ST_AVG_Confidence decimal(7,3) not null,
    ST_AVG_Stance as cast(
        case
            when ST_AVG_Confidence > 0.25 then '+'
            when ST_AVG_Confidence = 0.25 then '?'
            when ST_AVG_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_ST_AVG bigint not null,
    constraint fkST_AVG_Stage_Average_Meta foreign key (
        ST_AVG_ID
    ) references [attributes].[ST_AVG_Stage_Average_Fact](ST_AVG_ID),
    constraint pkST_AVG_Stage_Average_Meta primary key clustered (
        ST_AVG_ID asc,
        ST_AVG_Who asc,
        ST_AVG_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_MIN_Stage_Minimum_Fact', 'U') IS NULL
CREATE TABLE [attributes].[ST_MIN_Stage_Minimum_Fact] (
    ST_MIN_ID bigint IDENTITY(1,1) not null,
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    constraint fk_A_ST_MIN_Stage_Minimum_Fact foreign key (
        ST_MIN_ST_ID
    ) references [anchors].[ST_Stage](ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum_Fact foreign key (
        ST_MIN_UTL_ID
    ) references [knots].[UTL_Utilization](UTL_ID),
    constraint pkST_MIN_Stage_Minimum_Fact primary key nonclustered (
        ST_MIN_ID asc
    ),
    constraint uqST_MIN_Stage_Minimum_Fact unique clustered (
        ST_MIN_ST_ID asc,
        ST_MIN_UTL_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Meta table (of ST_MIN_Stage_Minimum_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_MIN_Stage_Minimum_Meta', 'U') IS NULL
CREATE TABLE [attributes].[ST_MIN_Stage_Minimum_Meta] (
    ST_MIN_ID bigint not null,
    ST_MIN_PositedAt datetime2(3) not null,
    ST_MIN_Who smallint not null,
    ST_MIN_Confidence decimal(7,3) not null,
    ST_MIN_Stance as cast(
        case
            when ST_MIN_Confidence > 0.25 then '+'
            when ST_MIN_Confidence = 0.25 then '?'
            when ST_MIN_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_ST_MIN bigint not null,
    constraint fkST_MIN_Stage_Minimum_Meta foreign key (
        ST_MIN_ID
    ) references [attributes].[ST_MIN_Stage_Minimum_Fact](ST_MIN_ID),
    constraint pkST_MIN_Stage_Minimum_Meta primary key clustered (
        ST_MIN_ID asc,
        ST_MIN_Who asc,
        ST_MIN_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_NAM_Actor_Name_Fact', 'U') IS NULL
CREATE TABLE [attributes].[AC_NAM_Actor_Name_Fact] (
    AC_NAM_ID bigint IDENTITY(1,1) not null,
    AC_NAM_AC_ID smallint not null,
    AC_NAM_Actor_Name varbinary(max) not null,
    AC_NAM_ChangedAt datetime2 not null,
    constraint fkAC_NAM_Actor_Name_Fact foreign key (
        AC_NAM_AC_ID
    ) references [anchors].[AC_Actor](AC_ID),
    constraint pkAC_NAM_Actor_Name_Fact primary key nonclustered (
        AC_NAM_ID asc
    ),
    constraint uqAC_NAM_Actor_Name_Fact unique clustered (
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc,
        AC_NAM_Actor_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Meta table (of AC_NAM_Actor_Name_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_NAM_Actor_Name_Meta', 'U') IS NULL
CREATE TABLE [attributes].[AC_NAM_Actor_Name_Meta] (
    AC_NAM_ID bigint not null,
    AC_NAM_PositedAt datetime2(3) not null,
    AC_NAM_Who smallint not null,
    AC_NAM_Confidence decimal(7,3) not null,
    AC_NAM_Stance as cast(
        case
            when AC_NAM_Confidence > 0.25 then '+'
            when AC_NAM_Confidence = 0.25 then '?'
            when AC_NAM_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_AC_NAM bigint not null,
    constraint fkAC_NAM_Actor_Name_Meta foreign key (
        AC_NAM_ID
    ) references [attributes].[AC_NAM_Actor_Name_Fact](AC_NAM_ID),
    constraint pkAC_NAM_Actor_Name_Meta primary key clustered (
        AC_NAM_ID asc,
        AC_NAM_Who asc,
        AC_NAM_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_GEN_Actor_Gender_Fact', 'U') IS NULL
CREATE TABLE [attributes].[AC_GEN_Actor_Gender_Fact] (
    AC_GEN_ID bigint IDENTITY(1,1) not null,
    AC_GEN_AC_ID smallint not null,
    AC_GEN_GEN_ID tinyint not null,
    constraint fk_A_AC_GEN_Actor_Gender_Fact foreign key (
        AC_GEN_AC_ID
    ) references [anchors].[AC_Actor](AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender_Fact foreign key (
        AC_GEN_GEN_ID
    ) references [knots].[GEN_Gender](GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Fact primary key nonclustered (
        AC_GEN_ID asc
    ),
    constraint uqAC_GEN_Actor_Gender_Fact unique clustered (
        AC_GEN_AC_ID asc,
        AC_GEN_GEN_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Meta table (of AC_GEN_Actor_Gender_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_GEN_Actor_Gender_Meta', 'U') IS NULL
CREATE TABLE [attributes].[AC_GEN_Actor_Gender_Meta] (
    AC_GEN_ID bigint not null,
    AC_GEN_PositedAt datetime2(3) not null,
    AC_GEN_Who smallint not null,
    AC_GEN_Confidence decimal(7,3) not null,
    AC_GEN_Stance as cast(
        case
            when AC_GEN_Confidence > 0.25 then '+'
            when AC_GEN_Confidence = 0.25 then '?'
            when AC_GEN_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_AC_GEN bigint not null,
    constraint fkAC_GEN_Actor_Gender_Meta foreign key (
        AC_GEN_ID
    ) references [attributes].[AC_GEN_Actor_Gender_Fact](AC_GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Meta primary key clustered (
        AC_GEN_ID asc,
        AC_GEN_Who asc,
        AC_GEN_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_PLV_Actor_ProfessionalLevel_Fact', 'U') IS NULL
CREATE TABLE [attributes].[AC_PLV_Actor_ProfessionalLevel_Fact] (
    AC_PLV_ID bigint IDENTITY(1,1) not null,
    AC_PLV_AC_ID smallint not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime2 not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel_Fact foreign key (
        AC_PLV_AC_ID
    ) references [anchors].[AC_Actor](AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel_Fact foreign key (
        AC_PLV_PLV_ID
    ) references [knots].[PLV_ProfessionalLevel](PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Fact primary key nonclustered (
        AC_PLV_ID asc
    ),
    constraint uqAC_PLV_Actor_ProfessionalLevel_Fact unique clustered (
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc,
        AC_PLV_PLV_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Meta table (of AC_PLV_Actor_ProfessionalLevel_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_PLV_Actor_ProfessionalLevel_Meta', 'U') IS NULL
CREATE TABLE [attributes].[AC_PLV_Actor_ProfessionalLevel_Meta] (
    AC_PLV_ID bigint not null,
    AC_PLV_PositedAt datetime2(3) not null,
    AC_PLV_Who smallint not null,
    AC_PLV_Confidence decimal(7,3) not null,
    AC_PLV_Stance as cast(
        case
            when AC_PLV_Confidence > 0.25 then '+'
            when AC_PLV_Confidence = 0.25 then '?'
            when AC_PLV_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_AC_PLV bigint not null,
    constraint fkAC_PLV_Actor_ProfessionalLevel_Meta foreign key (
        AC_PLV_ID
    ) references [attributes].[AC_PLV_Actor_ProfessionalLevel_Fact](AC_PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Meta primary key clustered (
        AC_PLV_ID asc,
        AC_PLV_Who asc,
        AC_PLV_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Fact table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_NAM_Program_Name_Fact', 'U') IS NULL
CREATE TABLE [attributes].[PR_NAM_Program_Name_Fact] (
    PR_NAM_ID bigint IDENTITY(1,1) not null,
    PR_NAM_PR_ID bigint not null,
    PR_NAM_Program_Name nvarchar(42) not null,
    constraint fkPR_NAM_Program_Name_Fact foreign key (
        PR_NAM_PR_ID
    ) references [anchors].[PR_Program](PR_ID),
    constraint pkPR_NAM_Program_Name_Fact primary key nonclustered (
        PR_NAM_ID asc
    ),
    constraint uqPR_NAM_Program_Name_Fact unique clustered (
        PR_NAM_PR_ID asc,
        PR_NAM_Program_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Meta table (of PR_NAM_Program_Name_Fact on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_NAM_Program_Name_Meta', 'U') IS NULL
CREATE TABLE [attributes].[PR_NAM_Program_Name_Meta] (
    PR_NAM_ID bigint not null,
    PR_NAM_PositedAt datetime2(3) not null,
    PR_NAM_Who smallint not null,
    PR_NAM_Confidence decimal(7,3) not null,
    PR_NAM_Stance as cast(
        case
            when PR_NAM_Confidence > 0.25 then '+'
            when PR_NAM_Confidence = 0.25 then '?'
            when PR_NAM_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_PR_NAM bigint not null,
    constraint fkPR_NAM_Program_Name_Meta foreign key (
        PR_NAM_ID
    ) references [attributes].[PR_NAM_Program_Name_Fact](PR_NAM_ID),
    constraint pkPR_NAM_Program_Name_Meta primary key clustered (
        PR_NAM_ID asc,
        PR_NAM_Who asc,
        PR_NAM_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Fact table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_LEN_Program_Length_Fact', 'U') IS NULL
CREATE TABLE [attributes].[PR_LEN_Program_Length_Fact] (
    PR_LEN_ID bigint IDENTITY(1,1) not null,
    PR_LEN_PR_ID bigint not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length_Fact foreign key (
        PR_LEN_PR_ID
    ) references [anchors].[PR_Program](PR_ID),
    constraint pkPR_LEN_Program_Length_Fact primary key nonclustered (
        PR_LEN_ID asc
    ),
    constraint uqPR_LEN_Program_Length_Fact unique clustered (
        PR_LEN_PR_ID asc,
        PR_LEN_ChangedAt desc,
        PR_LEN_Program_Length asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Meta table (of PR_LEN_Program_Length_Fact on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_LEN_Program_Length_Meta', 'U') IS NULL
CREATE TABLE [attributes].[PR_LEN_Program_Length_Meta] (
    PR_LEN_ID bigint not null,
    PR_LEN_PositedAt datetime2(3) not null,
    PR_LEN_Who smallint not null,
    PR_LEN_Confidence decimal(7,3) not null,
    PR_LEN_Stance as cast(
        case
            when PR_LEN_Confidence > 0.25 then '+'
            when PR_LEN_Confidence = 0.25 then '?'
            when PR_LEN_Confidence < 0.25 then '-'
        end
    as char(1)) persisted,
    Metadata_PR_LEN bigint not null,
    constraint fkPR_LEN_Program_Length_Meta foreign key (
        PR_LEN_ID
    ) references [attributes].[PR_LEN_Program_Length_Fact](PR_LEN_ID),
    constraint pkPR_LEN_Program_Length_Meta primary key clustered (
        PR_LEN_ID asc,
        PR_LEN_Who asc,
        PR_LEN_PositedAt desc
    )
);
GO
