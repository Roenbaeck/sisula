-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
CREATE TABLE IF NOT EXISTS attributes.EV_DAT_Event_Date_Fact (
    EV_DAT_ID bigint IDENTITY(1,1) not null, 
    EV_DAT_EV_ID numeric(12,0) not null,
    EV_DAT_Event_Date datetime not null,
    constraint fkEV_DAT_Event_Date_Fact foreign key (
        EV_DAT_EV_ID
    ) references nexuses.EV_Event(EV_ID) RELY,
    constraint pkEV_DAT_Event_Date_Fact primary key (
        EV_DAT_ID
    ) RELY,
    constraint uqEV_DAT_Event_Date_Fact unique (
        EV_DAT_EV_ID,
        EV_DAT_Event_Date
    ) RELY
) CLUSTER BY (EV_DAT_EV_ID);
CREATE TABLE IF NOT EXISTS attributes.EV_DAT_Event_Date_Meta (
    EV_DAT_ID bigint not null,
    EV_DAT_PositedAt timestamp_ntz(3) not null,
    EV_DAT_Confidence decimal(7,3) not null,
    Metadata_EV_DAT bigint not null,
    constraint fkEV_DAT_Event_Date_Meta foreign key (
        EV_DAT_ID
    ) references attributes.EV_DAT_Event_Date_Fact(EV_DAT_ID) RELY,
    constraint pkEV_DAT_Event_Date_Meta primary key (
        EV_DAT_ID,
        EV_DAT_PositedAt
    ) RELY
) CLUSTER BY (EV_DAT_ID, EV_DAT_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.EV_AUD_Event_Audience_Fact (
    EV_AUD_ID bigint IDENTITY(1,1) not null, 
    EV_AUD_EV_ID numeric(12,0) not null,
    EV_AUD_Event_Audience int not null,
    constraint fkEV_AUD_Event_Audience_Fact foreign key (
        EV_AUD_EV_ID
    ) references nexuses.EV_Event(EV_ID) RELY,
    constraint pkEV_AUD_Event_Audience_Fact primary key (
        EV_AUD_ID
    ) RELY,
    constraint uqEV_AUD_Event_Audience_Fact unique (
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    ) RELY
) CLUSTER BY (EV_AUD_EV_ID);
CREATE TABLE IF NOT EXISTS attributes.EV_AUD_Event_Audience_Meta (
    EV_AUD_ID bigint not null,
    EV_AUD_PositedAt timestamp_ntz(3) not null,
    EV_AUD_Confidence decimal(7,3) not null,
    Metadata_EV_AUD bigint not null,
    constraint fkEV_AUD_Event_Audience_Meta foreign key (
        EV_AUD_ID
    ) references attributes.EV_AUD_Event_Audience_Fact(EV_AUD_ID) RELY,
    constraint pkEV_AUD_Event_Audience_Meta primary key (
        EV_AUD_ID,
        EV_AUD_PositedAt
    ) RELY
) CLUSTER BY (EV_AUD_ID, EV_AUD_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.EV_REV_Event_Revenue_Fact (
    EV_REV_ID bigint IDENTITY(1,1) not null, 
    EV_REV_EV_ID numeric(12,0) not null,
    EV_REV_Event_Revenue number(19,4) not null,
    constraint fkEV_REV_Event_Revenue_Fact foreign key (
        EV_REV_EV_ID
    ) references nexuses.EV_Event(EV_ID) RELY,
    constraint pkEV_REV_Event_Revenue_Fact primary key (
        EV_REV_ID
    ) RELY,
    constraint uqEV_REV_Event_Revenue_Fact unique (
        EV_REV_EV_ID,
        EV_REV_Event_Revenue
    ) RELY
) CLUSTER BY (EV_REV_EV_ID);
CREATE TABLE IF NOT EXISTS attributes.EV_REV_Event_Revenue_Meta (
    EV_REV_ID bigint not null,
    EV_REV_PositedAt timestamp_ntz(3) not null,
    EV_REV_Confidence decimal(7,3) not null,
    Metadata_EV_REV bigint not null,
    constraint fkEV_REV_Event_Revenue_Meta foreign key (
        EV_REV_ID
    ) references attributes.EV_REV_Event_Revenue_Fact(EV_REV_ID) RELY,
    constraint pkEV_REV_Event_Revenue_Meta primary key (
        EV_REV_ID,
        EV_REV_PositedAt
    ) RELY
) CLUSTER BY (EV_REV_ID, EV_REV_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.EV_STA_Event_Status_Fact (
    EV_STA_ID bigint IDENTITY(1,1) not null, 
    EV_STA_EV_ID numeric(12,0) not null,
    EV_STA_Event_Status varchar(20) not null,
    EV_STA_ChangedAt datetime not null,
    constraint fkEV_STA_Event_Status_Fact foreign key (
        EV_STA_EV_ID
    ) references nexuses.EV_Event(EV_ID) RELY,
    constraint pkEV_STA_Event_Status_Fact primary key (
        EV_STA_ID
    ) RELY,
    constraint uqEV_STA_Event_Status_Fact unique (
        EV_STA_EV_ID,
        EV_STA_ChangedAt,
        EV_STA_Event_Status
    ) RELY
) CLUSTER BY (EV_STA_EV_ID);
CREATE TABLE IF NOT EXISTS attributes.EV_STA_Event_Status_Meta (
    EV_STA_ID bigint not null,
    EV_STA_PositedAt timestamp_ntz(3) not null,
    EV_STA_Confidence decimal(7,3) not null,
    Metadata_EV_STA bigint not null,
    constraint fkEV_STA_Event_Status_Meta foreign key (
        EV_STA_ID
    ) references attributes.EV_STA_Event_Status_Fact(EV_STA_ID) RELY,
    constraint pkEV_STA_Event_Status_Meta primary key (
        EV_STA_ID,
        EV_STA_PositedAt
    ) RELY
) CLUSTER BY (EV_STA_ID, EV_STA_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.EV_UTL_Event_Utilization_Fact (
    EV_UTL_ID bigint IDENTITY(1,1) not null, 
    EV_UTL_EV_ID numeric(12,0) not null,
    EV_UTL_UTL_ID tinyint not null,
    constraint fk_A_EV_UTL_Event_Utilization_Fact foreign key (
        EV_UTL_EV_ID
    ) references nexuses.EV_Event(EV_ID) RELY,
    constraint fk_K_EV_UTL_Event_Utilization_Fact foreign key (
        EV_UTL_UTL_ID
    ) references knots.UTL_Utilization(UTL_ID) RELY,
    constraint pkEV_UTL_Event_Utilization_Fact primary key (
        EV_UTL_ID
    ) RELY,
    constraint uqEV_UTL_Event_Utilization_Fact unique (
        EV_UTL_EV_ID,
        EV_UTL_UTL_ID
    ) RELY
) CLUSTER BY (EV_UTL_EV_ID);
CREATE TABLE IF NOT EXISTS attributes.EV_UTL_Event_Utilization_Meta (
    EV_UTL_ID bigint not null,
    EV_UTL_PositedAt timestamp_ntz(3) not null,
    EV_UTL_Confidence decimal(7,3) not null,
    Metadata_EV_UTL bigint not null,
    constraint fkEV_UTL_Event_Utilization_Meta foreign key (
        EV_UTL_ID
    ) references attributes.EV_UTL_Event_Utilization_Fact(EV_UTL_ID) RELY,
    constraint pkEV_UTL_Event_Utilization_Meta primary key (
        EV_UTL_ID,
        EV_UTL_PositedAt
    ) RELY
) CLUSTER BY (EV_UTL_ID, EV_UTL_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.EV_LVL_Event_Level_Fact (
    EV_LVL_ID bigint IDENTITY(1,1) not null, 
    EV_LVL_EV_ID numeric(12,0) not null,
    EV_LVL_PLV_ID tinyint not null,
    EV_LVL_ChangedAt date not null,
    constraint fk_A_EV_LVL_Event_Level_Fact foreign key (
        EV_LVL_EV_ID
    ) references nexuses.EV_Event(EV_ID) RELY,
    constraint fk_K_EV_LVL_Event_Level_Fact foreign key (
        EV_LVL_PLV_ID
    ) references knots.PLV_ProfessionalLevel(PLV_ID) RELY,
    constraint pkEV_LVL_Event_Level_Fact primary key (
        EV_LVL_ID
    ) RELY,
    constraint uqEV_LVL_Event_Level_Fact unique (
        EV_LVL_EV_ID,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    ) RELY
) CLUSTER BY (EV_LVL_EV_ID);
CREATE TABLE IF NOT EXISTS attributes.EV_LVL_Event_Level_Meta (
    EV_LVL_ID bigint not null,
    EV_LVL_PositedAt timestamp_ntz(3) not null,
    EV_LVL_Confidence decimal(7,3) not null,
    Metadata_EV_LVL bigint not null,
    constraint fkEV_LVL_Event_Level_Meta foreign key (
        EV_LVL_ID
    ) references attributes.EV_LVL_Event_Level_Fact(EV_LVL_ID) RELY,
    constraint pkEV_LVL_Event_Level_Meta primary key (
        EV_LVL_ID,
        EV_LVL_PositedAt
    ) RELY
) CLUSTER BY (EV_LVL_ID, EV_LVL_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.ST_NAM_Stage_Name_Fact (
    ST_NAM_ID bigint IDENTITY(1,1) not null, 
    ST_NAM_ST_ID int not null,
    ST_NAM_Stage_Name varchar(42) not null,
    ST_NAM_ChangedAt datetime not null,
    constraint fkST_NAM_Stage_Name_Fact foreign key (
        ST_NAM_ST_ID
    ) references anchors.ST_Stage(ST_ID) RELY,
    constraint pkST_NAM_Stage_Name_Fact primary key (
        ST_NAM_ID
    ) RELY,
    constraint uqST_NAM_Stage_Name_Fact unique (
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    ) RELY
) CLUSTER BY (ST_NAM_ST_ID);
CREATE TABLE IF NOT EXISTS attributes.ST_NAM_Stage_Name_Meta (
    ST_NAM_ID bigint not null,
    ST_NAM_PositedAt timestamp_ntz(3) not null,
    ST_NAM_Confidence decimal(7,3) not null,
    Metadata_ST_NAM bigint not null,
    constraint fkST_NAM_Stage_Name_Meta foreign key (
        ST_NAM_ID
    ) references attributes.ST_NAM_Stage_Name_Fact(ST_NAM_ID) RELY,
    constraint pkST_NAM_Stage_Name_Meta primary key (
        ST_NAM_ID,
        ST_NAM_PositedAt
    ) RELY
) CLUSTER BY (ST_NAM_ID, ST_NAM_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.ST_LOC_Stage_Location_Fact (
    ST_LOC_ID bigint IDENTITY(1,1) not null, 
    ST_LOC_ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum numeric(19,0) default hash(ST_LOC_Stage_Location),
    constraint fkST_LOC_Stage_Location_Fact foreign key (
        ST_LOC_ST_ID
    ) references anchors.ST_Stage(ST_ID) RELY,
    constraint pkST_LOC_Stage_Location_Fact primary key (
        ST_LOC_ID
    ) RELY,
    constraint uqST_LOC_Stage_Location_Fact unique (
        ST_LOC_ST_ID,
        ST_LOC_Checksum 
    ) RELY
) CLUSTER BY (ST_LOC_ST_ID);
CREATE TABLE IF NOT EXISTS attributes.ST_LOC_Stage_Location_Meta (
    ST_LOC_ID bigint not null,
    ST_LOC_PositedAt timestamp_ntz(3) not null,
    ST_LOC_Confidence decimal(7,3) not null,
    Metadata_ST_LOC bigint not null,
    constraint fkST_LOC_Stage_Location_Meta foreign key (
        ST_LOC_ID
    ) references attributes.ST_LOC_Stage_Location_Fact(ST_LOC_ID) RELY,
    constraint pkST_LOC_Stage_Location_Meta primary key (
        ST_LOC_ID,
        ST_LOC_PositedAt
    ) RELY
) CLUSTER BY (ST_LOC_ID, ST_LOC_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.ST_AVG_Stage_Average_Fact (
    ST_AVG_ID bigint IDENTITY(1,1) not null, 
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime not null,
    constraint fk_A_ST_AVG_Stage_Average_Fact foreign key (
        ST_AVG_ST_ID
    ) references anchors.ST_Stage(ST_ID) RELY,
    constraint fk_K_ST_AVG_Stage_Average_Fact foreign key (
        ST_AVG_UTL_ID
    ) references knots.UTL_Utilization(UTL_ID) RELY,
    constraint pkST_AVG_Stage_Average_Fact primary key (
        ST_AVG_ID
    ) RELY,
    constraint uqST_AVG_Stage_Average_Fact unique (
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    ) RELY
) CLUSTER BY (ST_AVG_ST_ID);
CREATE TABLE IF NOT EXISTS attributes.ST_AVG_Stage_Average_Meta (
    ST_AVG_ID bigint not null,
    ST_AVG_PositedAt timestamp_ntz(3) not null,
    ST_AVG_Confidence decimal(7,3) not null,
    Metadata_ST_AVG bigint not null,
    constraint fkST_AVG_Stage_Average_Meta foreign key (
        ST_AVG_ID
    ) references attributes.ST_AVG_Stage_Average_Fact(ST_AVG_ID) RELY,
    constraint pkST_AVG_Stage_Average_Meta primary key (
        ST_AVG_ID,
        ST_AVG_PositedAt
    ) RELY
) CLUSTER BY (ST_AVG_ID, ST_AVG_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.ST_MIN_Stage_Minimum_Fact (
    ST_MIN_ID bigint IDENTITY(1,1) not null, 
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    constraint fk_A_ST_MIN_Stage_Minimum_Fact foreign key (
        ST_MIN_ST_ID
    ) references anchors.ST_Stage(ST_ID) RELY,
    constraint fk_K_ST_MIN_Stage_Minimum_Fact foreign key (
        ST_MIN_UTL_ID
    ) references knots.UTL_Utilization(UTL_ID) RELY,
    constraint pkST_MIN_Stage_Minimum_Fact primary key (
        ST_MIN_ID
    ) RELY,
    constraint uqST_MIN_Stage_Minimum_Fact unique (
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    ) RELY
) CLUSTER BY (ST_MIN_ST_ID);
CREATE TABLE IF NOT EXISTS attributes.ST_MIN_Stage_Minimum_Meta (
    ST_MIN_ID bigint not null,
    ST_MIN_PositedAt timestamp_ntz(3) not null,
    ST_MIN_Confidence decimal(7,3) not null,
    Metadata_ST_MIN bigint not null,
    constraint fkST_MIN_Stage_Minimum_Meta foreign key (
        ST_MIN_ID
    ) references attributes.ST_MIN_Stage_Minimum_Fact(ST_MIN_ID) RELY,
    constraint pkST_MIN_Stage_Minimum_Meta primary key (
        ST_MIN_ID,
        ST_MIN_PositedAt
    ) RELY
) CLUSTER BY (ST_MIN_ID, ST_MIN_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.AC_NAM_Actor_Name_Fact (
    AC_NAM_ID bigint IDENTITY(1,1) not null, 
    AC_NAM_AC_ID smallint not null,
    AC_NAM_Actor_Name varbinary(max) not null,
    AC_NAM_ChangedAt datetime not null,
    constraint fkAC_NAM_Actor_Name_Fact foreign key (
        AC_NAM_AC_ID
    ) references anchors.AC_Actor(AC_ID) RELY,
    constraint pkAC_NAM_Actor_Name_Fact primary key (
        AC_NAM_ID
    ) RELY,
    constraint uqAC_NAM_Actor_Name_Fact unique (
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    ) RELY
) CLUSTER BY (AC_NAM_AC_ID);
CREATE TABLE IF NOT EXISTS attributes.AC_NAM_Actor_Name_Meta (
    AC_NAM_ID bigint not null,
    AC_NAM_PositedAt timestamp_ntz(3) not null,
    AC_NAM_Confidence decimal(7,3) not null,
    Metadata_AC_NAM bigint not null,
    constraint fkAC_NAM_Actor_Name_Meta foreign key (
        AC_NAM_ID
    ) references attributes.AC_NAM_Actor_Name_Fact(AC_NAM_ID) RELY,
    constraint pkAC_NAM_Actor_Name_Meta primary key (
        AC_NAM_ID,
        AC_NAM_PositedAt
    ) RELY
) CLUSTER BY (AC_NAM_ID, AC_NAM_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.AC_GEN_Actor_Gender_Fact (
    AC_GEN_ID bigint IDENTITY(1,1) not null, 
    AC_GEN_AC_ID smallint not null,
    AC_GEN_GEN_ID number(1,0) not null,
    constraint fk_A_AC_GEN_Actor_Gender_Fact foreign key (
        AC_GEN_AC_ID
    ) references anchors.AC_Actor(AC_ID) RELY,
    constraint fk_K_AC_GEN_Actor_Gender_Fact foreign key (
        AC_GEN_GEN_ID
    ) references knots.GEN_Gender(GEN_ID) RELY,
    constraint pkAC_GEN_Actor_Gender_Fact primary key (
        AC_GEN_ID
    ) RELY,
    constraint uqAC_GEN_Actor_Gender_Fact unique (
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    ) RELY
) CLUSTER BY (AC_GEN_AC_ID);
CREATE TABLE IF NOT EXISTS attributes.AC_GEN_Actor_Gender_Meta (
    AC_GEN_ID bigint not null,
    AC_GEN_PositedAt timestamp_ntz(3) not null,
    AC_GEN_Confidence decimal(7,3) not null,
    Metadata_AC_GEN bigint not null,
    constraint fkAC_GEN_Actor_Gender_Meta foreign key (
        AC_GEN_ID
    ) references attributes.AC_GEN_Actor_Gender_Fact(AC_GEN_ID) RELY,
    constraint pkAC_GEN_Actor_Gender_Meta primary key (
        AC_GEN_ID,
        AC_GEN_PositedAt
    ) RELY
) CLUSTER BY (AC_GEN_ID, AC_GEN_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.AC_PLV_Actor_ProfessionalLevel_Fact (
    AC_PLV_ID bigint IDENTITY(1,1) not null, 
    AC_PLV_AC_ID smallint not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel_Fact foreign key (
        AC_PLV_AC_ID
    ) references anchors.AC_Actor(AC_ID) RELY,
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel_Fact foreign key (
        AC_PLV_PLV_ID
    ) references knots.PLV_ProfessionalLevel(PLV_ID) RELY,
    constraint pkAC_PLV_Actor_ProfessionalLevel_Fact primary key (
        AC_PLV_ID
    ) RELY,
    constraint uqAC_PLV_Actor_ProfessionalLevel_Fact unique (
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    ) RELY
) CLUSTER BY (AC_PLV_AC_ID);
CREATE TABLE IF NOT EXISTS attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
    AC_PLV_ID bigint not null,
    AC_PLV_PositedAt timestamp_ntz(3) not null,
    AC_PLV_Confidence decimal(7,3) not null,
    Metadata_AC_PLV bigint not null,
    constraint fkAC_PLV_Actor_ProfessionalLevel_Meta foreign key (
        AC_PLV_ID
    ) references attributes.AC_PLV_Actor_ProfessionalLevel_Fact(AC_PLV_ID) RELY,
    constraint pkAC_PLV_Actor_ProfessionalLevel_Meta primary key (
        AC_PLV_ID,
        AC_PLV_PositedAt
    ) RELY
) CLUSTER BY (AC_PLV_ID, AC_PLV_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.PR_NAM_Program_Name_Fact (
    PR_NAM_ID bigint IDENTITY(1,1) not null, 
    PR_NAM_PR_ID number(10,0) not null,
    PR_NAM_Program_Name varchar(42) not null,
    constraint fkPR_NAM_Program_Name_Fact foreign key (
        PR_NAM_PR_ID
    ) references anchors.PR_Program(PR_ID) RELY,
    constraint pkPR_NAM_Program_Name_Fact primary key (
        PR_NAM_ID
    ) RELY,
    constraint uqPR_NAM_Program_Name_Fact unique (
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    ) RELY
) CLUSTER BY (PR_NAM_PR_ID);
CREATE TABLE IF NOT EXISTS attributes.PR_NAM_Program_Name_Meta (
    PR_NAM_ID bigint not null,
    PR_NAM_PositedAt timestamp_ntz(3) not null,
    PR_NAM_Confidence decimal(7,3) not null,
    Metadata_PR_NAM bigint not null,
    constraint fkPR_NAM_Program_Name_Meta foreign key (
        PR_NAM_ID
    ) references attributes.PR_NAM_Program_Name_Fact(PR_NAM_ID) RELY,
    constraint pkPR_NAM_Program_Name_Meta primary key (
        PR_NAM_ID,
        PR_NAM_PositedAt
    ) RELY
) CLUSTER BY (PR_NAM_ID, PR_NAM_PositedAt);
CREATE TABLE IF NOT EXISTS attributes.PR_LEN_Program_Length_Fact (
    PR_LEN_ID bigint IDENTITY(1,1) not null, 
    PR_LEN_PR_ID number(10,0) not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length_Fact foreign key (
        PR_LEN_PR_ID
    ) references anchors.PR_Program(PR_ID) RELY,
    constraint pkPR_LEN_Program_Length_Fact primary key (
        PR_LEN_ID
    ) RELY,
    constraint uqPR_LEN_Program_Length_Fact unique (
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    ) RELY
) CLUSTER BY (PR_LEN_PR_ID);
CREATE TABLE IF NOT EXISTS attributes.PR_LEN_Program_Length_Meta (
    PR_LEN_ID bigint not null,
    PR_LEN_PositedAt timestamp_ntz(3) not null,
    PR_LEN_Confidence decimal(7,3) not null,
    Metadata_PR_LEN bigint not null,
    constraint fkPR_LEN_Program_Length_Meta foreign key (
        PR_LEN_ID
    ) references attributes.PR_LEN_Program_Length_Fact(PR_LEN_ID) RELY,
    constraint pkPR_LEN_Program_Length_Meta primary key (
        PR_LEN_ID,
        PR_LEN_PositedAt
    ) RELY
) CLUSTER BY (PR_LEN_ID, PR_LEN_PositedAt);
