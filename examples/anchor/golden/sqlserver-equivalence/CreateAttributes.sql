-- ATTRIBUTES (UNIFIED FOR ANCHORS AND NEXUSES) ---------------------------------------------------------------------
--
-- Attributes are mutable properties attached to either anchors or nexuses.
-- Flavors: static, historized, knotted static, knotted historized.
-- This unified script creates all attribute tables using the global attribute iterator.
--
-- Static attribute table --------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_DAT_Event_Date', 'U') IS NULL
CREATE TABLE [dbo].[EV_DAT_Event_Date] (
    EV_DAT_EV_ID int not null,
    EV_DAT_EQ tinyint not null,
    EV_DAT_Event_Date datetime2 not null,
    Metadata_EV_DAT int not null,
    constraint fkEV_DAT_Event_Date foreign key (
        EV_DAT_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_DAT_Event_Date primary key (
        EV_DAT_EQ asc,
        EV_DAT_EV_ID asc
    )
); 
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_AUD_Event_Audience', 'U') IS NULL
CREATE TABLE [dbo].[EV_AUD_Event_Audience] (
    EV_AUD_EV_ID int not null,
    EV_AUD_Event_Audience int not null,
    Metadata_EV_AUD int not null,
    constraint fkEV_AUD_Event_Audience foreign key (
        EV_AUD_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_AUD_Event_Audience primary key (
        EV_AUD_EV_ID asc
    )
);
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_REV_Event_Revenue', 'U') IS NULL
CREATE TABLE [dbo].[EV_REV_Event_Revenue] (
    EV_REV_EV_ID int not null,
    EV_REV_EQ tinyint not null,
    EV_REV_Event_Revenue decimal(19,4) not null,
    Metadata_EV_REV int not null,
    constraint fkEV_REV_Event_Revenue foreign key (
        EV_REV_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_REV_Event_Revenue primary key (
        EV_REV_EQ asc,
        EV_REV_EV_ID asc
    )
); 
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_NAM_Stage_Name', 'U') IS NULL
CREATE TABLE [dbo].[ST_NAM_Stage_Name] (
    ST_NAM_ST_ID int not null,
    ST_NAM_EQ tinyint not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    ST_NAM_Checksum as cast(dbo.MD5(cast(ST_NAM_Stage_Name as varbinary(max))) as varbinary(16)) persisted,
    ST_NAM_ChangedAt datetime2 not null,
    Metadata_ST_NAM int not null,
    constraint fkST_NAM_Stage_Name foreign key (
        ST_NAM_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint pkST_NAM_Stage_Name primary key (
        ST_NAM_EQ asc,
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc
    )
); 
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_LOC_Stage_Location', 'U') IS NULL
CREATE TABLE [dbo].[ST_LOC_Stage_Location] (
    ST_LOC_ST_ID int not null,
    ST_LOC_EQ tinyint not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum as cast(dbo.MD5(cast(ST_LOC_Stage_Location as varbinary(max))) as varbinary(16)) persisted,
    Metadata_ST_LOC int not null,
    constraint fkST_LOC_Stage_Location foreign key (
        ST_LOC_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint pkST_LOC_Stage_Location primary key (
        ST_LOC_EQ asc,
        ST_LOC_ST_ID asc
    )
); 
GO
-- Knotted historized attribute table --------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_AVG_Stage_Average', 'U') IS NULL
CREATE TABLE [dbo].[ST_AVG_Stage_Average] (
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime2 not null,
    Metadata_ST_AVG int not null,
    constraint fk_A_ST_AVG_Stage_Average foreign key (
        ST_AVG_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint fk_K_ST_AVG_Stage_Average foreign key (
        ST_AVG_UTL_ID
    ) references [dbo].[UTL_Utilization](UTL_ID),
    constraint pkST_AVG_Stage_Average primary key (
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc
    )
);
GO
-- Knotted static attribute table ------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_MIN_Stage_Minimum', 'U') IS NULL
CREATE TABLE [dbo].[ST_MIN_Stage_Minimum] (
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    Metadata_ST_MIN int not null,
    constraint fk_A_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_UTL_ID
    ) references [dbo].[UTL_Utilization](UTL_ID),
    constraint pkST_MIN_Stage_Minimum primary key (
        ST_MIN_ST_ID asc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_NAM_Actor_Name', 'U') IS NULL
CREATE TABLE [dbo].[AC_NAM_Actor_Name] (
    AC_NAM_AC_ID int not null,
    AC_NAM_EQ tinyint not null,
    AC_NAM_Actor_Name nvarchar(42) not null,
    AC_NAM_Checksum as cast(dbo.MD5(cast(AC_NAM_Actor_Name as varbinary(max))) as varbinary(16)) persisted,
    AC_NAM_ChangedAt datetime2 not null,
    Metadata_AC_NAM int not null,
    constraint fkAC_NAM_Actor_Name foreign key (
        AC_NAM_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint pkAC_NAM_Actor_Name primary key (
        AC_NAM_EQ asc,
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc
    )
); 
GO
-- Knotted static attribute table ------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_GEN_Actor_Gender', 'U') IS NULL
CREATE TABLE [dbo].[AC_GEN_Actor_Gender] (
    AC_GEN_AC_ID int not null,
    AC_GEN_GEN_ID tinyint not null,
    Metadata_AC_GEN int not null,
    constraint fk_A_AC_GEN_Actor_Gender foreign key (
        AC_GEN_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender foreign key (
        AC_GEN_GEN_ID
    ) references [dbo].[GEN_Gender_ID](GEN_ID),
    constraint pkAC_GEN_Actor_Gender primary key (
        AC_GEN_AC_ID asc
    )
);
GO
-- Knotted historized attribute table --------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_PLV_Actor_ProfessionalLevel', 'U') IS NULL
CREATE TABLE [dbo].[AC_PLV_Actor_ProfessionalLevel] (
    AC_PLV_AC_ID int not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime2 not null,
    Metadata_AC_PLV int not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_PLV_ID
    ) references [dbo].[PLV_ProfessionalLevel](PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel primary key (
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc
    )
);
GO
-- Static attribute table --------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_NAM_Program_Name', 'U') IS NULL
CREATE TABLE [dbo].[PR_NAM_Program_Name] (
    PR_NAM_PR_ID int not null,
    PR_NAM_Program_Name nvarchar(42) not null,
    Metadata_PR_NAM int not null,
    constraint fkPR_NAM_Program_Name foreign key (
        PR_NAM_PR_ID
    ) references [dbo].[PR_Program](PR_ID),
    constraint pkPR_NAM_Program_Name primary key (
        PR_NAM_PR_ID asc
    )
);
GO
-- Historized attribute table ----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_LEN_Program_Length', 'U') IS NULL
CREATE TABLE [dbo].[PR_LEN_Program_Length] (
    PR_LEN_PR_ID int not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    Metadata_PR_LEN int not null,
    constraint fkPR_LEN_Program_Length foreign key (
        PR_LEN_PR_ID
    ) references [dbo].[PR_Program](PR_ID),
    constraint pkPR_LEN_Program_Length primary key (
        PR_LEN_PR_ID asc,
        PR_LEN_ChangedAt desc
    )
);
GO
