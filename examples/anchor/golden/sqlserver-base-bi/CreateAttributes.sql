-- ATTRIBUTES (UNIFIED FOR ANCHORS AND NEXUSES) ---------------------------------------------------------------------
--
-- Attributes are mutable properties attached to either anchors or nexuses.
-- Flavors: static, historized, knotted static, knotted historized.
-- This unified script creates all attribute tables (posits and annexes) using the global attribute iterator.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_DAT_Event_Date_Posit', 'U') IS NULL
CREATE TABLE [dbo].[EV_DAT_Event_Date_Posit] (
    EV_DAT_ID int IDENTITY(1,1) not null,
    EV_DAT_EV_ID int not null,
    EV_DAT_Event_Date datetime2 not null,
    constraint fkEV_DAT_Event_Date_Posit foreign key (
        EV_DAT_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_DAT_Event_Date_Posit primary key nonclustered (
        EV_DAT_ID asc
    ),
    constraint uqEV_DAT_Event_Date_Posit unique clustered (
        EV_DAT_EV_ID asc,
        EV_DAT_Event_Date asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Annex table (of EV_DAT_Event_Date_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_DAT_Event_Date_Annex', 'U') IS NULL
CREATE TABLE [dbo].[EV_DAT_Event_Date_Annex] (
    EV_DAT_ID int not null,
    EV_DAT_PositedAt datetime2 not null,
    EV_DAT_Reliability bit not null,
    Metadata_EV_DAT int not null,
    constraint fkEV_DAT_Event_Date_Annex foreign key (
        EV_DAT_ID
    ) references [dbo].[EV_DAT_Event_Date_Posit](EV_DAT_ID),
    constraint pkEV_DAT_Event_Date_Annex primary key clustered (
        EV_DAT_ID asc,
        EV_DAT_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_AUD_Event_Audience_Posit', 'U') IS NULL
CREATE TABLE [dbo].[EV_AUD_Event_Audience_Posit] (
    EV_AUD_ID int IDENTITY(1,1) not null,
    EV_AUD_EV_ID int not null,
    EV_AUD_Event_Audience int not null,
    constraint fkEV_AUD_Event_Audience_Posit foreign key (
        EV_AUD_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_AUD_Event_Audience_Posit primary key nonclustered (
        EV_AUD_ID asc
    ),
    constraint uqEV_AUD_Event_Audience_Posit unique clustered (
        EV_AUD_EV_ID asc,
        EV_AUD_Event_Audience asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Annex table (of EV_AUD_Event_Audience_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_AUD_Event_Audience_Annex', 'U') IS NULL
CREATE TABLE [dbo].[EV_AUD_Event_Audience_Annex] (
    EV_AUD_ID int not null,
    EV_AUD_PositedAt datetime2 not null,
    EV_AUD_Reliability bit not null,
    Metadata_EV_AUD int not null,
    constraint fkEV_AUD_Event_Audience_Annex foreign key (
        EV_AUD_ID
    ) references [dbo].[EV_AUD_Event_Audience_Posit](EV_AUD_ID),
    constraint pkEV_AUD_Event_Audience_Annex primary key clustered (
        EV_AUD_ID asc,
        EV_AUD_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_REV_Event_Revenue_Posit', 'U') IS NULL
CREATE TABLE [dbo].[EV_REV_Event_Revenue_Posit] (
    EV_REV_ID int IDENTITY(1,1) not null,
    EV_REV_EV_ID int not null,
    EV_REV_Event_Revenue decimal(19,4) not null,
    constraint fkEV_REV_Event_Revenue_Posit foreign key (
        EV_REV_EV_ID
    ) references [dbo].[EV_Event](EV_ID),
    constraint pkEV_REV_Event_Revenue_Posit primary key nonclustered (
        EV_REV_ID asc
    ),
    constraint uqEV_REV_Event_Revenue_Posit unique clustered (
        EV_REV_EV_ID asc,
        EV_REV_Event_Revenue asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Annex table (of EV_REV_Event_Revenue_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_REV_Event_Revenue_Annex', 'U') IS NULL
CREATE TABLE [dbo].[EV_REV_Event_Revenue_Annex] (
    EV_REV_ID int not null,
    EV_REV_PositedAt datetime2 not null,
    EV_REV_Reliability bit not null,
    Metadata_EV_REV int not null,
    constraint fkEV_REV_Event_Revenue_Annex foreign key (
        EV_REV_ID
    ) references [dbo].[EV_REV_Event_Revenue_Posit](EV_REV_ID),
    constraint pkEV_REV_Event_Revenue_Annex primary key clustered (
        EV_REV_ID asc,
        EV_REV_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_NAM_Stage_Name_Posit', 'U') IS NULL
CREATE TABLE [dbo].[ST_NAM_Stage_Name_Posit] (
    ST_NAM_ID int IDENTITY(1,1) not null,
    ST_NAM_ST_ID int not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    ST_NAM_ChangedAt datetime2 not null,
    constraint fkST_NAM_Stage_Name_Posit foreign key (
        ST_NAM_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint pkST_NAM_Stage_Name_Posit primary key nonclustered (
        ST_NAM_ID asc
    ),
    constraint uqST_NAM_Stage_Name_Posit unique clustered (
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc,
        ST_NAM_Stage_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Annex table (of ST_NAM_Stage_Name_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_NAM_Stage_Name_Annex', 'U') IS NULL
CREATE TABLE [dbo].[ST_NAM_Stage_Name_Annex] (
    ST_NAM_ID int not null,
    ST_NAM_PositedAt datetime2 not null,
    ST_NAM_Reliability bit not null,
    Metadata_ST_NAM int not null,
    constraint fkST_NAM_Stage_Name_Annex foreign key (
        ST_NAM_ID
    ) references [dbo].[ST_NAM_Stage_Name_Posit](ST_NAM_ID),
    constraint pkST_NAM_Stage_Name_Annex primary key clustered (
        ST_NAM_ID asc,
        ST_NAM_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_LOC_Stage_Location_Posit', 'U') IS NULL
CREATE TABLE [dbo].[ST_LOC_Stage_Location_Posit] (
    ST_LOC_ID int IDENTITY(1,1) not null,
    ST_LOC_ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum as cast(dbo.MD5(cast(ST_LOC_Stage_Location as varbinary(max))) as varbinary(16)) persisted,
    constraint fkST_LOC_Stage_Location_Posit foreign key (
        ST_LOC_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint pkST_LOC_Stage_Location_Posit primary key nonclustered (
        ST_LOC_ID asc
    ),
    constraint uqST_LOC_Stage_Location_Posit unique clustered (
        ST_LOC_ST_ID asc,
        ST_LOC_Checksum asc 
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Annex table (of ST_LOC_Stage_Location_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_LOC_Stage_Location_Annex', 'U') IS NULL
CREATE TABLE [dbo].[ST_LOC_Stage_Location_Annex] (
    ST_LOC_ID int not null,
    ST_LOC_PositedAt datetime2 not null,
    ST_LOC_Reliability bit not null,
    Metadata_ST_LOC int not null,
    constraint fkST_LOC_Stage_Location_Annex foreign key (
        ST_LOC_ID
    ) references [dbo].[ST_LOC_Stage_Location_Posit](ST_LOC_ID),
    constraint pkST_LOC_Stage_Location_Annex primary key clustered (
        ST_LOC_ID asc,
        ST_LOC_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_AVG_Stage_Average_Posit', 'U') IS NULL
CREATE TABLE [dbo].[ST_AVG_Stage_Average_Posit] (
    ST_AVG_ID int IDENTITY(1,1) not null,
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime2 not null,
    constraint fk_A_ST_AVG_Stage_Average_Posit foreign key (
        ST_AVG_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint fk_K_ST_AVG_Stage_Average_Posit foreign key (
        ST_AVG_UTL_ID
    ) references [dbo].[UTL_Utilization](UTL_ID),
    constraint pkST_AVG_Stage_Average_Posit primary key nonclustered (
        ST_AVG_ID asc
    ),
    constraint uqST_AVG_Stage_Average_Posit unique clustered (
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc,
        ST_AVG_UTL_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Annex table (of ST_AVG_Stage_Average_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_AVG_Stage_Average_Annex', 'U') IS NULL
CREATE TABLE [dbo].[ST_AVG_Stage_Average_Annex] (
    ST_AVG_ID int not null,
    ST_AVG_PositedAt datetime2 not null,
    ST_AVG_Reliability bit not null,
    Metadata_ST_AVG int not null,
    constraint fkST_AVG_Stage_Average_Annex foreign key (
        ST_AVG_ID
    ) references [dbo].[ST_AVG_Stage_Average_Posit](ST_AVG_ID),
    constraint pkST_AVG_Stage_Average_Annex primary key clustered (
        ST_AVG_ID asc,
        ST_AVG_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_MIN_Stage_Minimum_Posit', 'U') IS NULL
CREATE TABLE [dbo].[ST_MIN_Stage_Minimum_Posit] (
    ST_MIN_ID int IDENTITY(1,1) not null,
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    constraint fk_A_ST_MIN_Stage_Minimum_Posit foreign key (
        ST_MIN_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum_Posit foreign key (
        ST_MIN_UTL_ID
    ) references [dbo].[UTL_Utilization](UTL_ID),
    constraint pkST_MIN_Stage_Minimum_Posit primary key nonclustered (
        ST_MIN_ID asc
    ),
    constraint uqST_MIN_Stage_Minimum_Posit unique clustered (
        ST_MIN_ST_ID asc,
        ST_MIN_UTL_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Annex table (of ST_MIN_Stage_Minimum_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_MIN_Stage_Minimum_Annex', 'U') IS NULL
CREATE TABLE [dbo].[ST_MIN_Stage_Minimum_Annex] (
    ST_MIN_ID int not null,
    ST_MIN_PositedAt datetime2 not null,
    ST_MIN_Reliability bit not null,
    Metadata_ST_MIN int not null,
    constraint fkST_MIN_Stage_Minimum_Annex foreign key (
        ST_MIN_ID
    ) references [dbo].[ST_MIN_Stage_Minimum_Posit](ST_MIN_ID),
    constraint pkST_MIN_Stage_Minimum_Annex primary key clustered (
        ST_MIN_ID asc,
        ST_MIN_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_NAM_Actor_Name_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_NAM_Actor_Name_Posit] (
    AC_NAM_ID int IDENTITY(1,1) not null,
    AC_NAM_AC_ID int not null,
    AC_NAM_Actor_Name nvarchar(42) not null,
    AC_NAM_ChangedAt datetime2 not null,
    constraint fkAC_NAM_Actor_Name_Posit foreign key (
        AC_NAM_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint pkAC_NAM_Actor_Name_Posit primary key nonclustered (
        AC_NAM_ID asc
    ),
    constraint uqAC_NAM_Actor_Name_Posit unique clustered (
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc,
        AC_NAM_Actor_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Annex table (of AC_NAM_Actor_Name_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_NAM_Actor_Name_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_NAM_Actor_Name_Annex] (
    AC_NAM_ID int not null,
    AC_NAM_PositedAt datetime2 not null,
    AC_NAM_Reliability bit not null,
    Metadata_AC_NAM int not null,
    constraint fkAC_NAM_Actor_Name_Annex foreign key (
        AC_NAM_ID
    ) references [dbo].[AC_NAM_Actor_Name_Posit](AC_NAM_ID),
    constraint pkAC_NAM_Actor_Name_Annex primary key clustered (
        AC_NAM_ID asc,
        AC_NAM_PositedAt desc
    )
);
GO
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_GEN_Actor_Gender_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_GEN_Actor_Gender_Posit] (
    AC_GEN_ID int IDENTITY(1,1) not null,
    AC_GEN_AC_ID int not null,
    AC_GEN_GEN_ID tinyint not null,
    constraint fk_A_AC_GEN_Actor_Gender_Posit foreign key (
        AC_GEN_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender_Posit foreign key (
        AC_GEN_GEN_ID
    ) references [dbo].[GEN_Gender](GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Posit primary key nonclustered (
        AC_GEN_ID asc
    ),
    constraint uqAC_GEN_Actor_Gender_Posit unique clustered (
        AC_GEN_AC_ID asc,
        AC_GEN_GEN_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Annex table (of AC_GEN_Actor_Gender_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_GEN_Actor_Gender_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_GEN_Actor_Gender_Annex] (
    AC_GEN_ID int not null,
    AC_GEN_PositedAt datetime2 not null,
    AC_GEN_Reliability bit not null,
    Metadata_AC_GEN int not null,
    constraint fkAC_GEN_Actor_Gender_Annex foreign key (
        AC_GEN_ID
    ) references [dbo].[AC_GEN_Actor_Gender_Posit](AC_GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Annex primary key clustered (
        AC_GEN_ID asc,
        AC_GEN_PositedAt desc
    )
);
GO
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_PLV_Actor_ProfessionalLevel_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] (
    AC_PLV_ID int IDENTITY(1,1) not null,
    AC_PLV_AC_ID int not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime2 not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        AC_PLV_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        AC_PLV_PLV_ID
    ) references [dbo].[PLV_ProfessionalLevel](PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Posit primary key nonclustered (
        AC_PLV_ID asc
    ),
    constraint uqAC_PLV_Actor_ProfessionalLevel_Posit unique clustered (
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc,
        AC_PLV_PLV_ID asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Annex table (of AC_PLV_Actor_ProfessionalLevel_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_PLV_Actor_ProfessionalLevel_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] (
    AC_PLV_ID int not null,
    AC_PLV_PositedAt datetime2 not null,
    AC_PLV_Reliability bit not null,
    Metadata_AC_PLV int not null,
    constraint fkAC_PLV_Actor_ProfessionalLevel_Annex foreign key (
        AC_PLV_ID
    ) references [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit](AC_PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Annex primary key clustered (
        AC_PLV_ID asc,
        AC_PLV_PositedAt desc
    )
);
GO
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_NAM_Program_Name_Posit', 'U') IS NULL
CREATE TABLE [dbo].[PR_NAM_Program_Name_Posit] (
    PR_NAM_ID int IDENTITY(1,1) not null,
    PR_NAM_PR_ID int not null,
    PR_NAM_Program_Name nvarchar(42) not null,
    constraint fkPR_NAM_Program_Name_Posit foreign key (
        PR_NAM_PR_ID
    ) references [dbo].[PR_Program](PR_ID),
    constraint pkPR_NAM_Program_Name_Posit primary key nonclustered (
        PR_NAM_ID asc
    ),
    constraint uqPR_NAM_Program_Name_Posit unique clustered (
        PR_NAM_PR_ID asc,
        PR_NAM_Program_Name asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Annex table (of PR_NAM_Program_Name_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_NAM_Program_Name_Annex', 'U') IS NULL
CREATE TABLE [dbo].[PR_NAM_Program_Name_Annex] (
    PR_NAM_ID int not null,
    PR_NAM_PositedAt datetime2 not null,
    PR_NAM_Reliability bit not null,
    Metadata_PR_NAM int not null,
    constraint fkPR_NAM_Program_Name_Annex foreign key (
        PR_NAM_ID
    ) references [dbo].[PR_NAM_Program_Name_Posit](PR_NAM_ID),
    constraint pkPR_NAM_Program_Name_Annex primary key clustered (
        PR_NAM_ID asc,
        PR_NAM_PositedAt desc
    )
);
GO
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_LEN_Program_Length_Posit', 'U') IS NULL
CREATE TABLE [dbo].[PR_LEN_Program_Length_Posit] (
    PR_LEN_ID int IDENTITY(1,1) not null,
    PR_LEN_PR_ID int not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length_Posit foreign key (
        PR_LEN_PR_ID
    ) references [dbo].[PR_Program](PR_ID),
    constraint pkPR_LEN_Program_Length_Posit primary key nonclustered (
        PR_LEN_ID asc
    ),
    constraint uqPR_LEN_Program_Length_Posit unique clustered (
        PR_LEN_PR_ID asc,
        PR_LEN_ChangedAt desc,
        PR_LEN_Program_Length asc
    )
);
GO
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Annex table (of PR_LEN_Program_Length_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_LEN_Program_Length_Annex', 'U') IS NULL
CREATE TABLE [dbo].[PR_LEN_Program_Length_Annex] (
    PR_LEN_ID int not null,
    PR_LEN_PositedAt datetime2 not null,
    PR_LEN_Reliability bit not null,
    Metadata_PR_LEN int not null,
    constraint fkPR_LEN_Program_Length_Annex foreign key (
        PR_LEN_ID
    ) references [dbo].[PR_LEN_Program_Length_Posit](PR_LEN_ID),
    constraint pkPR_LEN_Program_Length_Annex primary key clustered (
        PR_LEN_ID asc,
        PR_LEN_PositedAt desc
    )
);
GO
