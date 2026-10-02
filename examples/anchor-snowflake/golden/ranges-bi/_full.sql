-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are immutable lookup tables for values.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.PAT_ParentalType (
    PAT_ID tinyint not null,
    PAT_ParentalType varchar(42) not null,
    Metadata_PAT bigint not null,
    constraint pkPAT_ParentalType primary key (
        PAT_ID
    ) RELY,
    constraint uqPAT_ParentalType unique (
        PAT_ParentalType
    ) RELY
) CLUSTER BY (PAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.GEN_Gender (
    GEN_ID number(1,0) not null,
    GEN_Gender varchar(42) not null,
    GEN_Checksum numeric(19,0) default hash(GEN_Gender),
    Metadata_GEN bigint not null,
    constraint pkGEN_Gender primary key (
        GEN_ID
    ) RELY,
    constraint uqGEN_Gender unique (
        GEN_Checksum 
    ) RELY
) CLUSTER BY (GEN_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.PLV_ProfessionalLevel (
    PLV_ID tinyint not null,
    PLV_ProfessionalLevel string not null,
    PLV_Checksum numeric(19,0) default hash(PLV_ProfessionalLevel),
    Metadata_PLV bigint not null,
    constraint pkPLV_ProfessionalLevel primary key (
        PLV_ID
    ) RELY,
    constraint uqPLV_ProfessionalLevel unique (
        PLV_Checksum 
    ) RELY
) CLUSTER BY (PLV_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.UTL_Utilization (
    UTL_ID tinyint not null,
    UTL_Utilization tinyint not null,
    Metadata_UTL bigint not null,
    constraint pkUTL_Utilization primary key (
        UTL_ID
    ) RELY,
    constraint uqUTL_Utilization unique (
        UTL_Utilization
    ) RELY
) CLUSTER BY (UTL_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.ONG_Ongoing (
    ONG_ID tinyint not null,
    ONG_Ongoing varchar(3) not null,
    Metadata_ONG bigint not null,
    constraint pkONG_Ongoing primary key (
        ONG_ID
    ) RELY,
    constraint uqONG_Ongoing unique (
        ONG_Ongoing
    ) RELY
) CLUSTER BY (ONG_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots.RAT_Rating_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots.RAT_Rating (
    RAT_ID tinyint default knots.RAT_Rating_ID_SEQ.nextval not null, 
    RAT_Rating varchar(42) not null,
    RAT_Checksum numeric(19,0) default hash(RAT_Rating),
    Metadata_RAT bigint not null,
    constraint pkRAT_Rating primary key (
        RAT_ID
    ) RELY,
    constraint uqRAT_Rating unique (
        RAT_Checksum 
    ) RELY
) CLUSTER BY (RAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.ETY_EventType (
    ETY_ID tinyint not null,
    ETY_EventType varchar(42) not null,
    ETY_Checksum numeric(19,0) default hash(ETY_EventType),
    Metadata_ETY bigint not null,
    constraint pkETY_EventType primary key (
        ETY_ID
    ) RELY,
    constraint uqETY_EventType unique (
        ETY_Checksum 
    ) RELY
) CLUSTER BY (ETY_ID);
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors store immutable entity identities.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors.PN_Person_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors.PN_Person (
    PN_ID bigint default anchors.PN_Person_ID_SEQ.nextval not null, 
    Metadata_PN bigint not null,
    constraint pkPN_Person primary key (
        PN_ID
    ) RELY
) CLUSTER BY (PN_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.ST_Stage (
    ST_ID int not null,
    Metadata_ST bigint not null,
    constraint pkST_Stage primary key (
        ST_ID
    ) RELY
) CLUSTER BY (ST_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors.AC_Actor_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors.AC_Actor (
    AC_ID smallint default anchors.AC_Actor_ID_SEQ.nextval not null, 
    Metadata_AC bigint not null,
    constraint pkAC_Actor primary key (
        AC_ID
    ) RELY
) CLUSTER BY (AC_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.PR_Program (
    PR_ID number(10,0) not null,
    Metadata_PR bigint not null,
    constraint pkPR_Program primary key (
        PR_ID
    ) RELY
) CLUSTER BY (PR_ID);
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses store immutable identities for event-like entities.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses.EV_Event (
    EV_ID numeric(12,0) not null,
    ST_ID_wasHeldAt int not null, 
    PR_ID_wasPlayed number(10,0) not null, 
    ETY_ID_of tinyint not null,
    constraint EV_Event_fkST_wasHeldAt foreign key (
        ST_ID_wasHeldAt
    ) references anchors.ST_Stage(ST_ID) RELY, 
    constraint EV_Event_fkPR_wasPlayed foreign key (
        PR_ID_wasPlayed
    ) references anchors.PR_Program(PR_ID) RELY, 
    constraint EV_Event_fkETY_of foreign key (
        ETY_ID_of
    ) references knots.ETY_EventType(ETY_ID) RELY,
    Metadata_EV bigint not null, 
    constraint pkEV_Event primary key (
        EV_ID
    ) RELY
) CLUSTER BY (EV_ID);
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
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW attributes.EV_DAT_Event_Date COPY GRANTS AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Confidence
FROM
    attributes.EV_DAT_Event_Date_Fact p
JOIN
    attributes.EV_DAT_Event_Date_Meta a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
;
CREATE OR REPLACE VIEW attributes.EV_AUD_Event_Audience COPY GRANTS AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Confidence
FROM
    attributes.EV_AUD_Event_Audience_Fact p
JOIN
    attributes.EV_AUD_Event_Audience_Meta a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
;
CREATE OR REPLACE VIEW attributes.EV_REV_Event_Revenue COPY GRANTS AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue,
    a.EV_REV_PositedAt,
    a.EV_REV_Confidence
FROM
    attributes.EV_REV_Event_Revenue_Fact p
JOIN
    attributes.EV_REV_Event_Revenue_Meta a
ON
    a.EV_REV_ID = p.EV_REV_ID
;
CREATE OR REPLACE VIEW attributes.EV_STA_Event_Status COPY GRANTS AS
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    p.EV_STA_EV_ID,
    p.EV_STA_Event_Status,
    p.EV_STA_ChangedAt,
    a.EV_STA_PositedAt,
    a.EV_STA_Confidence
FROM
    attributes.EV_STA_Event_Status_Fact p
JOIN
    attributes.EV_STA_Event_Status_Meta a
ON
    a.EV_STA_ID = p.EV_STA_ID
;
CREATE OR REPLACE VIEW attributes.EV_UTL_Event_Utilization COPY GRANTS AS
SELECT
    a.Metadata_EV_UTL,
    p.EV_UTL_ID,
    p.EV_UTL_EV_ID,
    p.EV_UTL_UTL_ID,
    a.EV_UTL_PositedAt,
    a.EV_UTL_Confidence
FROM
    attributes.EV_UTL_Event_Utilization_Fact p
JOIN
    attributes.EV_UTL_Event_Utilization_Meta a
ON
    a.EV_UTL_ID = p.EV_UTL_ID
;
CREATE OR REPLACE VIEW attributes.EV_LVL_Event_Level COPY GRANTS AS
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID,
    p.EV_LVL_ChangedAt,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Confidence
FROM
    attributes.EV_LVL_Event_Level_Fact p
JOIN
    attributes.EV_LVL_Event_Level_Meta a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
;
CREATE OR REPLACE VIEW attributes.ST_NAM_Stage_Name COPY GRANTS AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Confidence
FROM
    attributes.ST_NAM_Stage_Name_Fact p
JOIN
    attributes.ST_NAM_Stage_Name_Meta a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
;
CREATE OR REPLACE VIEW attributes.ST_LOC_Stage_Location COPY GRANTS AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Confidence
FROM
    attributes.ST_LOC_Stage_Location_Fact p
JOIN
    attributes.ST_LOC_Stage_Location_Meta a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
;
CREATE OR REPLACE VIEW attributes.ST_AVG_Stage_Average COPY GRANTS AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Confidence
FROM
    attributes.ST_AVG_Stage_Average_Fact p
JOIN
    attributes.ST_AVG_Stage_Average_Meta a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
;
CREATE OR REPLACE VIEW attributes.ST_MIN_Stage_Minimum COPY GRANTS AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Confidence
FROM
    attributes.ST_MIN_Stage_Minimum_Fact p
JOIN
    attributes.ST_MIN_Stage_Minimum_Meta a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
;
CREATE OR REPLACE VIEW attributes.AC_NAM_Actor_Name COPY GRANTS AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Confidence
FROM
    attributes.AC_NAM_Actor_Name_Fact p
JOIN
    attributes.AC_NAM_Actor_Name_Meta a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
;
CREATE OR REPLACE VIEW attributes.AC_GEN_Actor_Gender COPY GRANTS AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Confidence
FROM
    attributes.AC_GEN_Actor_Gender_Fact p
JOIN
    attributes.AC_GEN_Actor_Gender_Meta a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
;
CREATE OR REPLACE VIEW attributes.AC_PLV_Actor_ProfessionalLevel COPY GRANTS AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Confidence
FROM
    attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
JOIN
    attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
;
CREATE OR REPLACE VIEW attributes.PR_NAM_Program_Name COPY GRANTS AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Confidence
FROM
    attributes.PR_NAM_Program_Name_Fact p
JOIN
    attributes.PR_NAM_Program_Name_Meta a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
;
CREATE OR REPLACE VIEW attributes.PR_LEN_Program_Length COPY GRANTS AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Confidence
FROM
    attributes.PR_LEN_Program_Length_Fact p
JOIN
    attributes.PR_LEN_Program_Length_Meta a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION attributes.rEV_DAT_Event_Date_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_DAT bigint,
    EV_DAT_ID bigint,
    EV_DAT_PositedAt timestamp_ntz(3),
    EV_DAT_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_EV_DAT,
    EV_DAT_ID,
    EV_DAT_PositedAt,
    EV_DAT_Confidence
FROM
    attributes.EV_DAT_Event_Date_Meta
WHERE
    EV_DAT_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_DAT_Event_Date (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_DAT bigint,
    EV_DAT_ID bigint,
    EV_DAT_PositedAt timestamp_ntz(3),
    EV_DAT_Confidence decimal(7,3),
    EV_DAT_EV_ID numeric(12,0),
    EV_DAT_Event_Date datetime
)
AS
$$
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Confidence,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date
FROM
    attributes.EV_DAT_Event_Date_Fact p
JOIN
    TABLE(attributes.rEV_DAT_Event_Date_Meta(positingTimepoint)) a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_DAT_ID
        ORDER BY a.EV_DAT_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_AUD_Event_Audience_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_AUD bigint,
    EV_AUD_ID bigint,
    EV_AUD_PositedAt timestamp_ntz(3),
    EV_AUD_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_EV_AUD,
    EV_AUD_ID,
    EV_AUD_PositedAt,
    EV_AUD_Confidence
FROM
    attributes.EV_AUD_Event_Audience_Meta
WHERE
    EV_AUD_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_AUD_Event_Audience (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_AUD bigint,
    EV_AUD_ID bigint,
    EV_AUD_PositedAt timestamp_ntz(3),
    EV_AUD_Confidence decimal(7,3),
    EV_AUD_EV_ID numeric(12,0),
    EV_AUD_Event_Audience int
)
AS
$$
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Confidence,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience
FROM
    attributes.EV_AUD_Event_Audience_Fact p
JOIN
    TABLE(attributes.rEV_AUD_Event_Audience_Meta(positingTimepoint)) a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_AUD_ID
        ORDER BY a.EV_AUD_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_REV_Event_Revenue_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_REV bigint,
    EV_REV_ID bigint,
    EV_REV_PositedAt timestamp_ntz(3),
    EV_REV_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_EV_REV,
    EV_REV_ID,
    EV_REV_PositedAt,
    EV_REV_Confidence
FROM
    attributes.EV_REV_Event_Revenue_Meta
WHERE
    EV_REV_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_REV_Event_Revenue (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_REV bigint,
    EV_REV_ID bigint,
    EV_REV_PositedAt timestamp_ntz(3),
    EV_REV_Confidence decimal(7,3),
    EV_REV_EV_ID numeric(12,0),
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    a.EV_REV_PositedAt,
    a.EV_REV_Confidence,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue
FROM
    attributes.EV_REV_Event_Revenue_Fact p
JOIN
    TABLE(attributes.rEV_REV_Event_Revenue_Meta(positingTimepoint)) a
ON
    a.EV_REV_ID = p.EV_REV_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_REV_ID
        ORDER BY a.EV_REV_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_STA_ID bigint,
    EV_STA_EV_ID numeric(12,0),
    EV_STA_Event_Status varchar(20),
    EV_STA_ChangedAt datetime
)
AS
$$
SELECT
    EV_STA_ID,
    EV_STA_EV_ID,
    EV_STA_Event_Status,
    EV_STA_ChangedAt
FROM
    attributes.EV_STA_Event_Status_Fact
WHERE
    EV_STA_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fEV_STA_Event_Status_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_STA_ID bigint,
    EV_STA_EV_ID numeric(12,0),
    EV_STA_Event_Status varchar(20),
    EV_STA_ChangedAt datetime
)
AS
$$
SELECT
    EV_STA_ID,
    EV_STA_EV_ID,
    EV_STA_Event_Status,
    EV_STA_ChangedAt
FROM
    attributes.EV_STA_Event_Status_Fact
WHERE
    EV_STA_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_STA bigint,
    EV_STA_ID bigint,
    EV_STA_PositedAt timestamp_ntz(3),
    EV_STA_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_EV_STA,
    EV_STA_ID,
    EV_STA_PositedAt,
    EV_STA_Confidence
FROM
    attributes.EV_STA_Event_Status_Meta
WHERE
    EV_STA_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_STA bigint,
    EV_STA_ID bigint,
    EV_STA_PositedAt timestamp_ntz(3),
    EV_STA_Confidence decimal(7,3),
    EV_STA_EV_ID numeric(12,0),
    EV_STA_Event_Status varchar(20),
    EV_STA_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    a.EV_STA_PositedAt,
    a.EV_STA_Confidence,
    p.EV_STA_EV_ID,
    p.EV_STA_Event_Status,
    p.EV_STA_ChangedAt
FROM
    TABLE(attributes.rEV_STA_Event_Status_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rEV_STA_Event_Status_Meta(positingTimepoint)) a
ON
    a.EV_STA_ID = p.EV_STA_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_STA_ID
        ORDER BY a.EV_STA_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fEV_STA_Event_Status (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_STA bigint,
    EV_STA_ID bigint,
    EV_STA_PositedAt timestamp_ntz(3),
    EV_STA_Confidence decimal(7,3),
    EV_STA_EV_ID numeric(12,0),
    EV_STA_Event_Status varchar(20),
    EV_STA_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    a.EV_STA_PositedAt,
    a.EV_STA_Confidence,
    p.EV_STA_EV_ID,
    p.EV_STA_Event_Status,
    p.EV_STA_ChangedAt
FROM
    TABLE(attributes.fEV_STA_Event_Status_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rEV_STA_Event_Status_Meta(positingTimepoint)) a
ON
    a.EV_STA_ID = p.EV_STA_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_STA_ID
        ORDER BY a.EV_STA_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preEV_STA_Event_Status (
    id numeric(12,0),
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS varchar(20)
AS
$$
SELECT
    pre.EV_STA_Event_Status
FROM
    TABLE(attributes.rEV_STA_Event_Status(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.EV_STA_EV_ID = id
AND
    pre.EV_STA_ChangedAt < changingTimepoint
AND
    pre.EV_STA_Confidence = 1
ORDER BY
    pre.EV_STA_ChangedAt DESC,
    pre.EV_STA_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folEV_STA_Event_Status (
    id numeric(12,0),
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS varchar(20)
AS
$$
SELECT
    fol.EV_STA_Event_Status
FROM
    TABLE(attributes.fEV_STA_Event_Status(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.EV_STA_EV_ID = id
AND
    fol.EV_STA_ChangedAt > changingTimepoint
AND
    fol.EV_STA_Confidence = 1
ORDER BY
    fol.EV_STA_ChangedAt ASC,
    fol.EV_STA_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_UTL_Event_Utilization_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_UTL bigint,
    EV_UTL_ID bigint,
    EV_UTL_PositedAt timestamp_ntz(3),
    EV_UTL_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_EV_UTL,
    EV_UTL_ID,
    EV_UTL_PositedAt,
    EV_UTL_Confidence
FROM
    attributes.EV_UTL_Event_Utilization_Meta
WHERE
    EV_UTL_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_UTL_Event_Utilization (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_UTL bigint,
    EV_UTL_ID bigint,
    EV_UTL_PositedAt timestamp_ntz(3),
    EV_UTL_Confidence decimal(7,3),
    EV_UTL_EV_ID numeric(12,0),
    EV_UTL_UTL_ID tinyint 
)
AS
$$
SELECT
    a.Metadata_EV_UTL,
    p.EV_UTL_ID,
    a.EV_UTL_PositedAt,
    a.EV_UTL_Confidence,
    p.EV_UTL_EV_ID,
    p.EV_UTL_UTL_ID
FROM
    attributes.EV_UTL_Event_Utilization_Fact p
JOIN
    TABLE(attributes.rEV_UTL_Event_Utilization_Meta(positingTimepoint)) a
ON
    a.EV_UTL_ID = p.EV_UTL_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_UTL_ID
        ORDER BY a.EV_UTL_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level_Fact (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    EV_LVL_ID bigint,
    EV_LVL_EV_ID numeric(12,0),
    EV_LVL_PLV_ID tinyint, 
    EV_LVL_ChangedAt date
)
AS
$$
SELECT
    EV_LVL_ID,
    EV_LVL_EV_ID,
    EV_LVL_PLV_ID,
    EV_LVL_ChangedAt
FROM
    attributes.EV_LVL_Event_Level_Fact
WHERE
    EV_LVL_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fEV_LVL_Event_Level_Fact (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    EV_LVL_ID bigint,
    EV_LVL_EV_ID numeric(12,0),
    EV_LVL_PLV_ID tinyint, 
    EV_LVL_ChangedAt date
)
AS
$$
SELECT
    EV_LVL_ID,
    EV_LVL_EV_ID,
    EV_LVL_PLV_ID,
    EV_LVL_ChangedAt
FROM
    attributes.EV_LVL_Event_Level_Fact
WHERE
    EV_LVL_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_LVL bigint,
    EV_LVL_ID bigint,
    EV_LVL_PositedAt timestamp_ntz(3),
    EV_LVL_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_EV_LVL,
    EV_LVL_ID,
    EV_LVL_PositedAt,
    EV_LVL_Confidence
FROM
    attributes.EV_LVL_Event_Level_Meta
WHERE
    EV_LVL_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level (
    changingTimepoint date,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_LVL bigint,
    EV_LVL_ID bigint,
    EV_LVL_PositedAt timestamp_ntz(3),
    EV_LVL_Confidence decimal(7,3),
    EV_LVL_EV_ID numeric(12,0),
    EV_LVL_PLV_ID tinyint, 
    EV_LVL_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Confidence,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID,
    p.EV_LVL_ChangedAt
FROM
    TABLE(attributes.rEV_LVL_Event_Level_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rEV_LVL_Event_Level_Meta(positingTimepoint)) a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_LVL_ID
        ORDER BY a.EV_LVL_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fEV_LVL_Event_Level (
    changingTimepoint date,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_LVL bigint,
    EV_LVL_ID bigint,
    EV_LVL_PositedAt timestamp_ntz(3),
    EV_LVL_Confidence decimal(7,3),
    EV_LVL_EV_ID numeric(12,0),
    EV_LVL_PLV_ID tinyint, 
    EV_LVL_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Confidence,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID,
    p.EV_LVL_ChangedAt
FROM
    TABLE(attributes.fEV_LVL_Event_Level_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rEV_LVL_Event_Level_Meta(positingTimepoint)) a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_LVL_ID
        ORDER BY a.EV_LVL_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preEV_LVL_Event_Level (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    pre.EV_LVL_PLV_ID
FROM
    TABLE(attributes.rEV_LVL_Event_Level(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.EV_LVL_EV_ID = id
AND
    pre.EV_LVL_ChangedAt < changingTimepoint
AND
    pre.EV_LVL_Confidence = 1
ORDER BY
    pre.EV_LVL_ChangedAt DESC,
    pre.EV_LVL_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folEV_LVL_Event_Level (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    fol.EV_LVL_PLV_ID
FROM
    TABLE(attributes.fEV_LVL_Event_Level(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.EV_LVL_EV_ID = id
AND
    fol.EV_LVL_ChangedAt > changingTimepoint
AND
    fol.EV_LVL_Confidence = 1
ORDER BY
    fol.EV_LVL_ChangedAt ASC,
    fol.EV_LVL_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_NAM_ID bigint,
    ST_NAM_ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    ST_NAM_ID,
    ST_NAM_ST_ID,
    ST_NAM_Stage_Name,
    ST_NAM_ChangedAt
FROM
    attributes.ST_NAM_Stage_Name_Fact
WHERE
    ST_NAM_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fST_NAM_Stage_Name_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_NAM_ID bigint,
    ST_NAM_ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    ST_NAM_ID,
    ST_NAM_ST_ID,
    ST_NAM_Stage_Name,
    ST_NAM_ChangedAt
FROM
    attributes.ST_NAM_Stage_Name_Fact
WHERE
    ST_NAM_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_NAM bigint,
    ST_NAM_ID bigint,
    ST_NAM_PositedAt timestamp_ntz(3),
    ST_NAM_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_ST_NAM,
    ST_NAM_ID,
    ST_NAM_PositedAt,
    ST_NAM_Confidence
FROM
    attributes.ST_NAM_Stage_Name_Meta
WHERE
    ST_NAM_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_NAM bigint,
    ST_NAM_ID bigint,
    ST_NAM_PositedAt timestamp_ntz(3),
    ST_NAM_Confidence decimal(7,3),
    ST_NAM_ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Confidence,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt
FROM
    TABLE(attributes.rST_NAM_Stage_Name_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rST_NAM_Stage_Name_Meta(positingTimepoint)) a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_NAM_ID
        ORDER BY a.ST_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fST_NAM_Stage_Name (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_NAM bigint,
    ST_NAM_ID bigint,
    ST_NAM_PositedAt timestamp_ntz(3),
    ST_NAM_Confidence decimal(7,3),
    ST_NAM_ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Confidence,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt
FROM
    TABLE(attributes.fST_NAM_Stage_Name_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rST_NAM_Stage_Name_Meta(positingTimepoint)) a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_NAM_ID
        ORDER BY a.ST_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preST_NAM_Stage_Name (
    id int,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    pre.ST_NAM_Stage_Name
FROM
    TABLE(attributes.rST_NAM_Stage_Name(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.ST_NAM_ST_ID = id
AND
    pre.ST_NAM_ChangedAt < changingTimepoint
AND
    pre.ST_NAM_Confidence = 1
ORDER BY
    pre.ST_NAM_ChangedAt DESC,
    pre.ST_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folST_NAM_Stage_Name (
    id int,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    fol.ST_NAM_Stage_Name
FROM
    TABLE(attributes.fST_NAM_Stage_Name(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.ST_NAM_ST_ID = id
AND
    fol.ST_NAM_ChangedAt > changingTimepoint
AND
    fol.ST_NAM_Confidence = 1
ORDER BY
    fol.ST_NAM_ChangedAt ASC,
    fol.ST_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_LOC_Stage_Location_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_LOC bigint,
    ST_LOC_ID bigint,
    ST_LOC_PositedAt timestamp_ntz(3),
    ST_LOC_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_ST_LOC,
    ST_LOC_ID,
    ST_LOC_PositedAt,
    ST_LOC_Confidence
FROM
    attributes.ST_LOC_Stage_Location_Meta
WHERE
    ST_LOC_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_LOC_Stage_Location (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_LOC bigint,
    ST_LOC_ID bigint,
    ST_LOC_PositedAt timestamp_ntz(3),
    ST_LOC_Confidence decimal(7,3),
    ST_LOC_ST_ID int,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography
)
AS
$$
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Confidence,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location
FROM
    attributes.ST_LOC_Stage_Location_Fact p
JOIN
    TABLE(attributes.rST_LOC_Stage_Location_Meta(positingTimepoint)) a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_LOC_ID
        ORDER BY a.ST_LOC_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_AVG_ID bigint,
    ST_AVG_ST_ID int,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    ST_AVG_ID,
    ST_AVG_ST_ID,
    ST_AVG_UTL_ID,
    ST_AVG_ChangedAt
FROM
    attributes.ST_AVG_Stage_Average_Fact
WHERE
    ST_AVG_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fST_AVG_Stage_Average_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_AVG_ID bigint,
    ST_AVG_ST_ID int,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    ST_AVG_ID,
    ST_AVG_ST_ID,
    ST_AVG_UTL_ID,
    ST_AVG_ChangedAt
FROM
    attributes.ST_AVG_Stage_Average_Fact
WHERE
    ST_AVG_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_AVG bigint,
    ST_AVG_ID bigint,
    ST_AVG_PositedAt timestamp_ntz(3),
    ST_AVG_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_ST_AVG,
    ST_AVG_ID,
    ST_AVG_PositedAt,
    ST_AVG_Confidence
FROM
    attributes.ST_AVG_Stage_Average_Meta
WHERE
    ST_AVG_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_AVG bigint,
    ST_AVG_ID bigint,
    ST_AVG_PositedAt timestamp_ntz(3),
    ST_AVG_Confidence decimal(7,3),
    ST_AVG_ST_ID int,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Confidence,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt
FROM
    TABLE(attributes.rST_AVG_Stage_Average_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rST_AVG_Stage_Average_Meta(positingTimepoint)) a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_AVG_ID
        ORDER BY a.ST_AVG_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fST_AVG_Stage_Average (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_AVG bigint,
    ST_AVG_ID bigint,
    ST_AVG_PositedAt timestamp_ntz(3),
    ST_AVG_Confidence decimal(7,3),
    ST_AVG_ST_ID int,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Confidence,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt
FROM
    TABLE(attributes.fST_AVG_Stage_Average_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rST_AVG_Stage_Average_Meta(positingTimepoint)) a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_AVG_ID
        ORDER BY a.ST_AVG_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preST_AVG_Stage_Average (
    id int,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    pre.ST_AVG_UTL_ID
FROM
    TABLE(attributes.rST_AVG_Stage_Average(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.ST_AVG_ST_ID = id
AND
    pre.ST_AVG_ChangedAt < changingTimepoint
AND
    pre.ST_AVG_Confidence = 1
ORDER BY
    pre.ST_AVG_ChangedAt DESC,
    pre.ST_AVG_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folST_AVG_Stage_Average (
    id int,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    fol.ST_AVG_UTL_ID
FROM
    TABLE(attributes.fST_AVG_Stage_Average(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.ST_AVG_ST_ID = id
AND
    fol.ST_AVG_ChangedAt > changingTimepoint
AND
    fol.ST_AVG_Confidence = 1
ORDER BY
    fol.ST_AVG_ChangedAt ASC,
    fol.ST_AVG_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_MIN_Stage_Minimum_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_MIN bigint,
    ST_MIN_ID bigint,
    ST_MIN_PositedAt timestamp_ntz(3),
    ST_MIN_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_ST_MIN,
    ST_MIN_ID,
    ST_MIN_PositedAt,
    ST_MIN_Confidence
FROM
    attributes.ST_MIN_Stage_Minimum_Meta
WHERE
    ST_MIN_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_MIN_Stage_Minimum (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_MIN bigint,
    ST_MIN_ID bigint,
    ST_MIN_PositedAt timestamp_ntz(3),
    ST_MIN_Confidence decimal(7,3),
    ST_MIN_ST_ID int,
    ST_MIN_UTL_ID tinyint 
)
AS
$$
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Confidence,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID
FROM
    attributes.ST_MIN_Stage_Minimum_Fact p
JOIN
    TABLE(attributes.rST_MIN_Stage_Minimum_Meta(positingTimepoint)) a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_MIN_ID
        ORDER BY a.ST_MIN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_NAM_ID bigint,
    AC_NAM_AC_ID smallint,
    AC_NAM_Actor_Name varbinary(max),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    AC_NAM_ID,
    AC_NAM_AC_ID,
    AC_NAM_Actor_Name,
    AC_NAM_ChangedAt
FROM
    attributes.AC_NAM_Actor_Name_Fact
WHERE
    AC_NAM_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fAC_NAM_Actor_Name_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_NAM_ID bigint,
    AC_NAM_AC_ID smallint,
    AC_NAM_Actor_Name varbinary(max),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    AC_NAM_ID,
    AC_NAM_AC_ID,
    AC_NAM_Actor_Name,
    AC_NAM_ChangedAt
FROM
    attributes.AC_NAM_Actor_Name_Fact
WHERE
    AC_NAM_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_NAM bigint,
    AC_NAM_ID bigint,
    AC_NAM_PositedAt timestamp_ntz(3),
    AC_NAM_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_AC_NAM,
    AC_NAM_ID,
    AC_NAM_PositedAt,
    AC_NAM_Confidence
FROM
    attributes.AC_NAM_Actor_Name_Meta
WHERE
    AC_NAM_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_NAM bigint,
    AC_NAM_ID bigint,
    AC_NAM_PositedAt timestamp_ntz(3),
    AC_NAM_Confidence decimal(7,3),
    AC_NAM_AC_ID smallint,
    AC_NAM_Actor_Name varbinary(max),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Confidence,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt
FROM
    TABLE(attributes.rAC_NAM_Actor_Name_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rAC_NAM_Actor_Name_Meta(positingTimepoint)) a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_NAM_ID
        ORDER BY a.AC_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fAC_NAM_Actor_Name (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_NAM bigint,
    AC_NAM_ID bigint,
    AC_NAM_PositedAt timestamp_ntz(3),
    AC_NAM_Confidence decimal(7,3),
    AC_NAM_AC_ID smallint,
    AC_NAM_Actor_Name varbinary(max),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Confidence,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt
FROM
    TABLE(attributes.fAC_NAM_Actor_Name_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rAC_NAM_Actor_Name_Meta(positingTimepoint)) a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_NAM_ID
        ORDER BY a.AC_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preAC_NAM_Actor_Name (
    id smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS varbinary(max)
AS
$$
SELECT
    pre.AC_NAM_Actor_Name
FROM
    TABLE(attributes.rAC_NAM_Actor_Name(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.AC_NAM_AC_ID = id
AND
    pre.AC_NAM_ChangedAt < changingTimepoint
AND
    pre.AC_NAM_Confidence = 1
ORDER BY
    pre.AC_NAM_ChangedAt DESC,
    pre.AC_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folAC_NAM_Actor_Name (
    id smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS varbinary(max)
AS
$$
SELECT
    fol.AC_NAM_Actor_Name
FROM
    TABLE(attributes.fAC_NAM_Actor_Name(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.AC_NAM_AC_ID = id
AND
    fol.AC_NAM_ChangedAt > changingTimepoint
AND
    fol.AC_NAM_Confidence = 1
ORDER BY
    fol.AC_NAM_ChangedAt ASC,
    fol.AC_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_GEN_Actor_Gender_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_GEN bigint,
    AC_GEN_ID bigint,
    AC_GEN_PositedAt timestamp_ntz(3),
    AC_GEN_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_AC_GEN,
    AC_GEN_ID,
    AC_GEN_PositedAt,
    AC_GEN_Confidence
FROM
    attributes.AC_GEN_Actor_Gender_Meta
WHERE
    AC_GEN_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_GEN_Actor_Gender (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_GEN bigint,
    AC_GEN_ID bigint,
    AC_GEN_PositedAt timestamp_ntz(3),
    AC_GEN_Confidence decimal(7,3),
    AC_GEN_AC_ID smallint,
    AC_GEN_GEN_ID number(1,0) 
)
AS
$$
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Confidence,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID
FROM
    attributes.AC_GEN_Actor_Gender_Fact p
JOIN
    TABLE(attributes.rAC_GEN_Actor_Gender_Meta(positingTimepoint)) a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_GEN_ID
        ORDER BY a.AC_GEN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_PLV_ID bigint,
    AC_PLV_AC_ID smallint,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    AC_PLV_ID,
    AC_PLV_AC_ID,
    AC_PLV_PLV_ID,
    AC_PLV_ChangedAt
FROM
    attributes.AC_PLV_Actor_ProfessionalLevel_Fact
WHERE
    AC_PLV_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fAC_PLV_Actor_ProfessionalLevel_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_PLV_ID bigint,
    AC_PLV_AC_ID smallint,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    AC_PLV_ID,
    AC_PLV_AC_ID,
    AC_PLV_PLV_ID,
    AC_PLV_ChangedAt
FROM
    attributes.AC_PLV_Actor_ProfessionalLevel_Fact
WHERE
    AC_PLV_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_PLV bigint,
    AC_PLV_ID bigint,
    AC_PLV_PositedAt timestamp_ntz(3),
    AC_PLV_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_AC_PLV,
    AC_PLV_ID,
    AC_PLV_PositedAt,
    AC_PLV_Confidence
FROM
    attributes.AC_PLV_Actor_ProfessionalLevel_Meta
WHERE
    AC_PLV_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_PLV bigint,
    AC_PLV_ID bigint,
    AC_PLV_PositedAt timestamp_ntz(3),
    AC_PLV_Confidence decimal(7,3),
    AC_PLV_AC_ID smallint,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Confidence,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt
FROM
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel_Meta(positingTimepoint)) a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_PLV_ID
        ORDER BY a.AC_PLV_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_PLV bigint,
    AC_PLV_ID bigint,
    AC_PLV_PositedAt timestamp_ntz(3),
    AC_PLV_Confidence decimal(7,3),
    AC_PLV_AC_ID smallint,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Confidence,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt
FROM
    TABLE(attributes.fAC_PLV_Actor_ProfessionalLevel_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel_Meta(positingTimepoint)) a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_PLV_ID
        ORDER BY a.AC_PLV_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preAC_PLV_Actor_ProfessionalLevel (
    id smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    pre.AC_PLV_PLV_ID
FROM
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.AC_PLV_AC_ID = id
AND
    pre.AC_PLV_ChangedAt < changingTimepoint
AND
    pre.AC_PLV_Confidence = 1
ORDER BY
    pre.AC_PLV_ChangedAt DESC,
    pre.AC_PLV_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folAC_PLV_Actor_ProfessionalLevel (
    id smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    fol.AC_PLV_PLV_ID
FROM
    TABLE(attributes.fAC_PLV_Actor_ProfessionalLevel(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.AC_PLV_AC_ID = id
AND
    fol.AC_PLV_ChangedAt > changingTimepoint
AND
    fol.AC_PLV_Confidence = 1
ORDER BY
    fol.AC_PLV_ChangedAt ASC,
    fol.AC_PLV_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rPR_NAM_Program_Name_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_NAM bigint,
    PR_NAM_ID bigint,
    PR_NAM_PositedAt timestamp_ntz(3),
    PR_NAM_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_PR_NAM,
    PR_NAM_ID,
    PR_NAM_PositedAt,
    PR_NAM_Confidence
FROM
    attributes.PR_NAM_Program_Name_Meta
WHERE
    PR_NAM_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rPR_NAM_Program_Name (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_NAM bigint,
    PR_NAM_ID bigint,
    PR_NAM_PositedAt timestamp_ntz(3),
    PR_NAM_Confidence decimal(7,3),
    PR_NAM_PR_ID number(10,0),
    PR_NAM_Program_Name varchar(42)
)
AS
$$
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Confidence,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name
FROM
    attributes.PR_NAM_Program_Name_Fact p
JOIN
    TABLE(attributes.rPR_NAM_Program_Name_Meta(positingTimepoint)) a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_NAM_ID
        ORDER BY a.PR_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length_Fact (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    PR_LEN_ID bigint,
    PR_LEN_PR_ID number(10,0),
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    PR_LEN_ID,
    PR_LEN_PR_ID,
    PR_LEN_Program_Length,
    PR_LEN_ChangedAt
FROM
    attributes.PR_LEN_Program_Length_Fact
WHERE
    PR_LEN_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fPR_LEN_Program_Length_Fact (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    PR_LEN_ID bigint,
    PR_LEN_PR_ID number(10,0),
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    PR_LEN_ID,
    PR_LEN_PR_ID,
    PR_LEN_Program_Length,
    PR_LEN_ChangedAt
FROM
    attributes.PR_LEN_Program_Length_Fact
WHERE
    PR_LEN_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_LEN bigint,
    PR_LEN_ID bigint,
    PR_LEN_PositedAt timestamp_ntz(3),
    PR_LEN_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_PR_LEN,
    PR_LEN_ID,
    PR_LEN_PositedAt,
    PR_LEN_Confidence
FROM
    attributes.PR_LEN_Program_Length_Meta
WHERE
    PR_LEN_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length (
    changingTimepoint date,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_LEN bigint,
    PR_LEN_ID bigint,
    PR_LEN_PositedAt timestamp_ntz(3),
    PR_LEN_Confidence decimal(7,3),
    PR_LEN_PR_ID number(10,0),
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Confidence,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt
FROM
    TABLE(attributes.rPR_LEN_Program_Length_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rPR_LEN_Program_Length_Meta(positingTimepoint)) a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_LEN_ID
        ORDER BY a.PR_LEN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fPR_LEN_Program_Length (
    changingTimepoint date,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_LEN bigint,
    PR_LEN_ID bigint,
    PR_LEN_PositedAt timestamp_ntz(3),
    PR_LEN_Confidence decimal(7,3),
    PR_LEN_PR_ID number(10,0),
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Confidence,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt
FROM
    TABLE(attributes.fPR_LEN_Program_Length_Fact(changingTimepoint)) p
JOIN
    TABLE(attributes.rPR_LEN_Program_Length_Meta(positingTimepoint)) a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_LEN_ID
        ORDER BY a.PR_LEN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.prePR_LEN_Program_Length (
    id number(10,0),
    changingTimepoint date,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS time
AS
$$
SELECT
    pre.PR_LEN_Program_Length
FROM
    TABLE(attributes.rPR_LEN_Program_Length(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.PR_LEN_PR_ID = id
AND
    pre.PR_LEN_ChangedAt < changingTimepoint
AND
    pre.PR_LEN_Confidence = 1
ORDER BY
    pre.PR_LEN_ChangedAt DESC,
    pre.PR_LEN_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folPR_LEN_Program_Length (
    id number(10,0),
    changingTimepoint date,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS time
AS
$$
SELECT
    fol.PR_LEN_Program_Length
FROM
    TABLE(attributes.fPR_LEN_Program_Length(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.PR_LEN_PR_ID = id
AND
    fol.PR_LEN_ChangedAt > changingTimepoint
AND
    fol.PR_LEN_Confidence = 1
ORDER BY
    fol.PR_LEN_ChangedAt ASC,
    fol.PR_LEN_PositedAt DESC
LIMIT 1
$$
;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION anchors.tST_Stage (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    ST_ID int,
    Metadata_ST bigint,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM bigint,
    ST_NAM_ID bigint,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt timestamp_ntz(3),
    ST_NAM_Confidence decimal(7,3),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC bigint,
    ST_LOC_ID bigint,
    ST_LOC_PositedAt timestamp_ntz(3),
    ST_LOC_Confidence decimal(7,3),
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG bigint,
    ST_AVG_ID bigint,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt timestamp_ntz(3),
    ST_AVG_Confidence decimal(7,3),
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL bigint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN bigint,
    ST_MIN_ID bigint,
    ST_MIN_PositedAt timestamp_ntz(3),
    ST_MIN_Confidence decimal(7,3),
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_Metadata_UTL bigint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    ST.ST_ID,
    ST.Metadata_ST,
    NAM.ST_NAM_ST_ID,
    NAM.Metadata_ST_NAM,
    NAM.ST_NAM_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_PositedAt,
    NAM.ST_NAM_Confidence,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.Metadata_ST_LOC,
    LOC.ST_LOC_ID,
    LOC.ST_LOC_PositedAt,
    LOC.ST_LOC_Confidence,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ST_ID,
    AVG.Metadata_ST_AVG,
    AVG.ST_AVG_ID,
    AVG.ST_AVG_ChangedAt,
    AVG.ST_AVG_PositedAt,
    AVG.ST_AVG_Confidence,
    kAVG.UTL_Utilization AS ST_AVG_UTL_Utilization,
    kAVG.Metadata_UTL AS ST_AVG_Metadata_UTL,
    AVG.ST_AVG_UTL_ID,
    MIN.ST_MIN_ST_ID,
    MIN.Metadata_ST_MIN,
    MIN.ST_MIN_ID,
    MIN.ST_MIN_PositedAt,
    MIN.ST_MIN_Confidence,
    kMIN.UTL_Utilization AS ST_MIN_UTL_Utilization,
    kMIN.Metadata_UTL AS ST_MIN_Metadata_UTL,
    MIN.ST_MIN_UTL_ID
FROM
    anchors.ST_Stage ST
LEFT JOIN
    TABLE(attributes.rST_NAM_Stage_Name(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) NAM
ON
    NAM.ST_NAM_ID = (
        SELECT
            sub.ST_NAM_ID
        FROM
            TABLE(attributes.rST_NAM_Stage_Name(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
        AND
            sub.ST_NAM_Confidence = 1
        ORDER BY
            sub.ST_NAM_ChangedAt DESC,
            sub.ST_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rST_LOC_Stage_Location(
        positingTimepoint::timestamp_ntz(3)
    )) LOC
ON
    LOC.ST_LOC_ID = (
        SELECT
            sub.ST_LOC_ID
        FROM
            TABLE(attributes.rST_LOC_Stage_Location(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.ST_LOC_ST_ID = ST.ST_ID
        AND
            sub.ST_LOC_Confidence = 1
        ORDER BY
            sub.ST_LOC_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rST_AVG_Stage_Average(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) AVG
ON
    AVG.ST_AVG_ID = (
        SELECT
            sub.ST_AVG_ID
        FROM
            TABLE(attributes.rST_AVG_Stage_Average(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.ST_AVG_ST_ID = ST.ST_ID
        AND
            sub.ST_AVG_Confidence = 1
        ORDER BY
            sub.ST_AVG_ChangedAt DESC,
            sub.ST_AVG_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.ST_AVG_UTL_ID
LEFT JOIN
    TABLE(attributes.rST_MIN_Stage_Minimum(
        positingTimepoint::timestamp_ntz(3)
    )) MIN
ON
    MIN.ST_MIN_ID = (
        SELECT
            sub.ST_MIN_ID
        FROM
            TABLE(attributes.rST_MIN_Stage_Minimum(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.ST_MIN_ST_ID = ST.ST_ID
        AND
            sub.ST_MIN_Confidence = 1
        ORDER BY
            sub.ST_MIN_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.ST_MIN_UTL_ID
$$
;
CREATE OR REPLACE VIEW anchors.lST_Stage COPY GRANTS AS
SELECT
    cast(null as decimal(7,3)) as Confidence,
    ST.*
FROM
    TABLE(anchors.tST_Stage(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) ST
;
CREATE OR REPLACE FUNCTION anchors.pST_Stage (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Confidence decimal(7,3),
    ST_ID int,
    Metadata_ST bigint,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM bigint,
    ST_NAM_ID bigint,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt timestamp_ntz(3),
    ST_NAM_Confidence decimal(7,3),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC bigint,
    ST_LOC_ID bigint,
    ST_LOC_PositedAt timestamp_ntz(3),
    ST_LOC_Confidence decimal(7,3),
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG bigint,
    ST_AVG_ID bigint,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt timestamp_ntz(3),
    ST_AVG_Confidence decimal(7,3),
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL bigint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN bigint,
    ST_MIN_ID bigint,
    ST_MIN_PositedAt timestamp_ntz(3),
    ST_MIN_Confidence decimal(7,3),
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_Metadata_UTL bigint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    cast(null as decimal(7,3)) as Confidence,
    ST.ST_ID,
    ST.Metadata_ST,
    ST.ST_NAM_ST_ID,
    ST.Metadata_ST_NAM,
    ST.ST_NAM_ID,
    ST.ST_NAM_ChangedAt,
    ST.ST_NAM_PositedAt,
    ST.ST_NAM_Confidence,
    ST.ST_NAM_Stage_Name,
    ST.ST_LOC_ST_ID,
    ST.Metadata_ST_LOC,
    ST.ST_LOC_ID,
    ST.ST_LOC_PositedAt,
    ST.ST_LOC_Confidence,
    ST.ST_LOC_Checksum,
    ST.ST_LOC_Stage_Location,
    ST.ST_AVG_ST_ID,
    ST.Metadata_ST_AVG,
    ST.ST_AVG_ID,
    ST.ST_AVG_ChangedAt,
    ST.ST_AVG_PositedAt,
    ST.ST_AVG_Confidence,
    ST.ST_AVG_UTL_Utilization,
    ST.ST_AVG_Metadata_UTL,
    ST.ST_AVG_UTL_ID,
    ST.ST_MIN_ST_ID,
    ST.Metadata_ST_MIN,
    ST.ST_MIN_ID,
    ST.ST_MIN_PositedAt,
    ST.ST_MIN_Confidence,
    ST.ST_MIN_UTL_Utilization,
    ST.ST_MIN_Metadata_UTL,
    ST.ST_MIN_UTL_ID
FROM
    TABLE(anchors.tST_Stage(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) ST
$$
;
CREATE OR REPLACE VIEW anchors.nST_Stage COPY GRANTS AS
SELECT
    cast(null as decimal(7,3)) as Confidence,
    ST.*
FROM
    TABLE(anchors.tST_Stage(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) ST
;
CREATE OR REPLACE FUNCTION anchors.dST_Stage (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    ST_ID int,
    Metadata_ST bigint,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM bigint,
    ST_NAM_ID bigint,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt timestamp_ntz(3),
    ST_NAM_Confidence decimal(7,3),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC bigint,
    ST_LOC_ID bigint,
    ST_LOC_PositedAt timestamp_ntz(3),
    ST_LOC_Confidence decimal(7,3),
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG bigint,
    ST_AVG_ID bigint,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt timestamp_ntz(3),
    ST_AVG_Confidence decimal(7,3),
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL bigint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN bigint,
    ST_MIN_ID bigint,
    ST_MIN_PositedAt timestamp_ntz(3),
    ST_MIN_Confidence decimal(7,3),
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_Metadata_UTL bigint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    tp.inspectedTimepoint,
    ST.ST_ID,
    ST.Metadata_ST,
    ST.ST_NAM_ST_ID,
    ST.Metadata_ST_NAM,
    ST.ST_NAM_ID,
    ST.ST_NAM_ChangedAt,
    ST.ST_NAM_PositedAt,
    ST.ST_NAM_Confidence,
    ST.ST_NAM_Stage_Name,
    ST.ST_LOC_ST_ID,
    ST.Metadata_ST_LOC,
    ST.ST_LOC_ID,
    ST.ST_LOC_PositedAt,
    ST.ST_LOC_Confidence,
    ST.ST_LOC_Checksum,
    ST.ST_LOC_Stage_Location,
    ST.ST_AVG_ST_ID,
    ST.Metadata_ST_AVG,
    ST.ST_AVG_ID,
    ST.ST_AVG_ChangedAt,
    ST.ST_AVG_PositedAt,
    ST.ST_AVG_Confidence,
    ST.ST_AVG_UTL_Utilization,
    ST.ST_AVG_Metadata_UTL,
    ST.ST_AVG_UTL_ID,
    ST.ST_MIN_ST_ID,
    ST.Metadata_ST_MIN,
    ST.ST_MIN_ID,
    ST.ST_MIN_PositedAt,
    ST.ST_MIN_Confidence,
    ST.ST_MIN_UTL_Utilization,
    ST.ST_MIN_Metadata_UTL,
    ST.ST_MIN_UTL_ID
FROM (
    SELECT DISTINCT
        ST_NAM_ST_ID AS ST_ID,
        ST_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.ST_NAM_Stage_Name
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        ST_AVG_ST_ID AS ST_ID,
        ST_AVG_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes.ST_AVG_Stage_Average
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
CROSS JOIN LATERAL
    TABLE(anchors.tST_Stage(
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) ST
WHERE
    ST.ST_ID = tp.ST_ID
$$
;
CREATE OR REPLACE FUNCTION anchors.tAC_Actor (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    AC_ID smallint,
    Metadata_AC bigint,
    AC_NAM_AC_ID smallint,
    Metadata_AC_NAM bigint,
    AC_NAM_ID bigint,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt timestamp_ntz(3),
    AC_NAM_Confidence decimal(7,3),
    AC_NAM_Actor_Name varbinary(max),
    AC_GEN_AC_ID smallint,
    Metadata_AC_GEN bigint,
    AC_GEN_ID bigint,
    AC_GEN_PositedAt timestamp_ntz(3),
    AC_GEN_Confidence decimal(7,3),
    AC_GEN_GEN_Checksum numeric(19,0),
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN bigint,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID smallint,
    Metadata_AC_PLV bigint,
    AC_PLV_ID bigint,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt timestamp_ntz(3),
    AC_PLV_Confidence decimal(7,3),
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_Metadata_PLV bigint,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    AC.AC_ID,
    AC.Metadata_AC,
    NAM.AC_NAM_AC_ID,
    NAM.Metadata_AC_NAM,
    NAM.AC_NAM_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_PositedAt,
    NAM.AC_NAM_Confidence,
    NAM.AC_NAM_Actor_Name,
    GEN.AC_GEN_AC_ID,
    GEN.Metadata_AC_GEN,
    GEN.AC_GEN_ID,
    GEN.AC_GEN_PositedAt,
    GEN.AC_GEN_Confidence,
    kGEN.GEN_Checksum AS AC_GEN_GEN_Checksum,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    kGEN.Metadata_GEN AS AC_GEN_Metadata_GEN,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.Metadata_AC_PLV,
    PLV.AC_PLV_ID,
    PLV.AC_PLV_ChangedAt,
    PLV.AC_PLV_PositedAt,
    PLV.AC_PLV_Confidence,
    kPLV.PLV_Checksum AS AC_PLV_PLV_Checksum,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    kPLV.Metadata_PLV AS AC_PLV_Metadata_PLV,
    PLV.AC_PLV_PLV_ID
FROM
    anchors.AC_Actor AC
LEFT JOIN
    TABLE(attributes.rAC_NAM_Actor_Name(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) NAM
ON
    NAM.AC_NAM_ID = (
        SELECT
            sub.AC_NAM_ID
        FROM
            TABLE(attributes.rAC_NAM_Actor_Name(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
        AND
            sub.AC_NAM_Confidence = 1
        ORDER BY
            sub.AC_NAM_ChangedAt DESC,
            sub.AC_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rAC_GEN_Actor_Gender(
        positingTimepoint::timestamp_ntz(3)
    )) GEN
ON
    GEN.AC_GEN_ID = (
        SELECT
            sub.AC_GEN_ID
        FROM
            TABLE(attributes.rAC_GEN_Actor_Gender(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.AC_GEN_AC_ID = AC.AC_ID
        AND
            sub.AC_GEN_Confidence = 1
        ORDER BY
            sub.AC_GEN_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.AC_GEN_GEN_ID
LEFT JOIN
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) PLV
ON
    PLV.AC_PLV_ID = (
        SELECT
            sub.AC_PLV_ID
        FROM
            TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.AC_PLV_AC_ID = AC.AC_ID
        AND
            sub.AC_PLV_Confidence = 1
        ORDER BY
            sub.AC_PLV_ChangedAt DESC,
            sub.AC_PLV_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.AC_PLV_PLV_ID
$$
;
CREATE OR REPLACE VIEW anchors.lAC_Actor COPY GRANTS AS
SELECT
    cast(null as decimal(7,3)) as Confidence,
    AC.*
FROM
    TABLE(anchors.tAC_Actor(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) AC
;
CREATE OR REPLACE FUNCTION anchors.pAC_Actor (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Confidence decimal(7,3),
    AC_ID smallint,
    Metadata_AC bigint,
    AC_NAM_AC_ID smallint,
    Metadata_AC_NAM bigint,
    AC_NAM_ID bigint,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt timestamp_ntz(3),
    AC_NAM_Confidence decimal(7,3),
    AC_NAM_Actor_Name varbinary(max),
    AC_GEN_AC_ID smallint,
    Metadata_AC_GEN bigint,
    AC_GEN_ID bigint,
    AC_GEN_PositedAt timestamp_ntz(3),
    AC_GEN_Confidence decimal(7,3),
    AC_GEN_GEN_Checksum numeric(19,0),
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN bigint,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID smallint,
    Metadata_AC_PLV bigint,
    AC_PLV_ID bigint,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt timestamp_ntz(3),
    AC_PLV_Confidence decimal(7,3),
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_Metadata_PLV bigint,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    cast(null as decimal(7,3)) as Confidence,
    AC.AC_ID,
    AC.Metadata_AC,
    AC.AC_NAM_AC_ID,
    AC.Metadata_AC_NAM,
    AC.AC_NAM_ID,
    AC.AC_NAM_ChangedAt,
    AC.AC_NAM_PositedAt,
    AC.AC_NAM_Confidence,
    AC.AC_NAM_Actor_Name,
    AC.AC_GEN_AC_ID,
    AC.Metadata_AC_GEN,
    AC.AC_GEN_ID,
    AC.AC_GEN_PositedAt,
    AC.AC_GEN_Confidence,
    AC.AC_GEN_GEN_Checksum,
    AC.AC_GEN_GEN_Gender,
    AC.AC_GEN_Metadata_GEN,
    AC.AC_GEN_GEN_ID,
    AC.AC_PLV_AC_ID,
    AC.Metadata_AC_PLV,
    AC.AC_PLV_ID,
    AC.AC_PLV_ChangedAt,
    AC.AC_PLV_PositedAt,
    AC.AC_PLV_Confidence,
    AC.AC_PLV_PLV_Checksum,
    AC.AC_PLV_PLV_ProfessionalLevel,
    AC.AC_PLV_Metadata_PLV,
    AC.AC_PLV_PLV_ID
FROM
    TABLE(anchors.tAC_Actor(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) AC
$$
;
CREATE OR REPLACE VIEW anchors.nAC_Actor COPY GRANTS AS
SELECT
    cast(null as decimal(7,3)) as Confidence,
    AC.*
FROM
    TABLE(anchors.tAC_Actor(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) AC
;
CREATE OR REPLACE FUNCTION anchors.dAC_Actor (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    AC_ID smallint,
    Metadata_AC bigint,
    AC_NAM_AC_ID smallint,
    Metadata_AC_NAM bigint,
    AC_NAM_ID bigint,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt timestamp_ntz(3),
    AC_NAM_Confidence decimal(7,3),
    AC_NAM_Actor_Name varbinary(max),
    AC_GEN_AC_ID smallint,
    Metadata_AC_GEN bigint,
    AC_GEN_ID bigint,
    AC_GEN_PositedAt timestamp_ntz(3),
    AC_GEN_Confidence decimal(7,3),
    AC_GEN_GEN_Checksum numeric(19,0),
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN bigint,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID smallint,
    Metadata_AC_PLV bigint,
    AC_PLV_ID bigint,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt timestamp_ntz(3),
    AC_PLV_Confidence decimal(7,3),
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_Metadata_PLV bigint,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    tp.inspectedTimepoint,
    AC.AC_ID,
    AC.Metadata_AC,
    AC.AC_NAM_AC_ID,
    AC.Metadata_AC_NAM,
    AC.AC_NAM_ID,
    AC.AC_NAM_ChangedAt,
    AC.AC_NAM_PositedAt,
    AC.AC_NAM_Confidence,
    AC.AC_NAM_Actor_Name,
    AC.AC_GEN_AC_ID,
    AC.Metadata_AC_GEN,
    AC.AC_GEN_ID,
    AC.AC_GEN_PositedAt,
    AC.AC_GEN_Confidence,
    AC.AC_GEN_GEN_Checksum,
    AC.AC_GEN_GEN_Gender,
    AC.AC_GEN_Metadata_GEN,
    AC.AC_GEN_GEN_ID,
    AC.AC_PLV_AC_ID,
    AC.Metadata_AC_PLV,
    AC.AC_PLV_ID,
    AC.AC_PLV_ChangedAt,
    AC.AC_PLV_PositedAt,
    AC.AC_PLV_Confidence,
    AC.AC_PLV_PLV_Checksum,
    AC.AC_PLV_PLV_ProfessionalLevel,
    AC.AC_PLV_Metadata_PLV,
    AC.AC_PLV_PLV_ID
FROM (
    SELECT DISTINCT
        AC_NAM_AC_ID AS AC_ID,
        AC_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.AC_NAM_Actor_Name
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        AC_PLV_AC_ID AS AC_ID,
        AC_PLV_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes.AC_PLV_Actor_ProfessionalLevel
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
CROSS JOIN LATERAL
    TABLE(anchors.tAC_Actor(
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) AC
WHERE
    AC.AC_ID = tp.AC_ID
$$
;
CREATE OR REPLACE FUNCTION anchors.tPR_Program (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    PR_ID number(10,0),
    Metadata_PR bigint,
    PR_NAM_PR_ID number(10,0),
    Metadata_PR_NAM bigint,
    PR_NAM_ID bigint,
    PR_NAM_PositedAt timestamp_ntz(3),
    PR_NAM_Confidence decimal(7,3),
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID number(10,0),
    Metadata_PR_LEN bigint,
    PR_LEN_ID bigint,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt timestamp_ntz(3),
    PR_LEN_Confidence decimal(7,3),
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    PR.PR_ID,
    PR.Metadata_PR,
    NAM.PR_NAM_PR_ID,
    NAM.Metadata_PR_NAM,
    NAM.PR_NAM_ID,
    NAM.PR_NAM_PositedAt,
    NAM.PR_NAM_Confidence,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_PR_ID,
    LEN.Metadata_PR_LEN,
    LEN.PR_LEN_ID,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_PositedAt,
    LEN.PR_LEN_Confidence,
    LEN.PR_LEN_Program_Length
FROM
    anchors.PR_Program PR
LEFT JOIN
    TABLE(attributes.rPR_NAM_Program_Name(
        positingTimepoint::timestamp_ntz(3)
    )) NAM
ON
    NAM.PR_NAM_ID = (
        SELECT
            sub.PR_NAM_ID
        FROM
            TABLE(attributes.rPR_NAM_Program_Name(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.PR_NAM_PR_ID = PR.PR_ID
        AND
            sub.PR_NAM_Confidence = 1
        ORDER BY
            sub.PR_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rPR_LEN_Program_Length(
        changingTimepoint::date,
        positingTimepoint::timestamp_ntz(3)
    )) LEN
ON
    LEN.PR_LEN_ID = (
        SELECT
            sub.PR_LEN_ID
        FROM
            TABLE(attributes.rPR_LEN_Program_Length(
                changingTimepoint::date,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.PR_LEN_PR_ID = PR.PR_ID
        AND
            sub.PR_LEN_Confidence = 1
        ORDER BY
            sub.PR_LEN_ChangedAt DESC,
            sub.PR_LEN_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW anchors.lPR_Program COPY GRANTS AS
SELECT
    cast(null as decimal(7,3)) as Confidence,
    PR.*
FROM
    TABLE(anchors.tPR_Program(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) PR
;
CREATE OR REPLACE FUNCTION anchors.pPR_Program (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Confidence decimal(7,3),
    PR_ID number(10,0),
    Metadata_PR bigint,
    PR_NAM_PR_ID number(10,0),
    Metadata_PR_NAM bigint,
    PR_NAM_ID bigint,
    PR_NAM_PositedAt timestamp_ntz(3),
    PR_NAM_Confidence decimal(7,3),
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID number(10,0),
    Metadata_PR_LEN bigint,
    PR_LEN_ID bigint,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt timestamp_ntz(3),
    PR_LEN_Confidence decimal(7,3),
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    cast(null as decimal(7,3)) as Confidence,
    PR.PR_ID,
    PR.Metadata_PR,
    PR.PR_NAM_PR_ID,
    PR.Metadata_PR_NAM,
    PR.PR_NAM_ID,
    PR.PR_NAM_PositedAt,
    PR.PR_NAM_Confidence,
    PR.PR_NAM_Program_Name,
    PR.PR_LEN_PR_ID,
    PR.Metadata_PR_LEN,
    PR.PR_LEN_ID,
    PR.PR_LEN_ChangedAt,
    PR.PR_LEN_PositedAt,
    PR.PR_LEN_Confidence,
    PR.PR_LEN_Program_Length
FROM
    TABLE(anchors.tPR_Program(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) PR
$$
;
CREATE OR REPLACE VIEW anchors.nPR_Program COPY GRANTS AS
SELECT
    cast(null as decimal(7,3)) as Confidence,
    PR.*
FROM
    TABLE(anchors.tPR_Program(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) PR
;
CREATE OR REPLACE FUNCTION anchors.dPR_Program (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    PR_ID number(10,0),
    Metadata_PR bigint,
    PR_NAM_PR_ID number(10,0),
    Metadata_PR_NAM bigint,
    PR_NAM_ID bigint,
    PR_NAM_PositedAt timestamp_ntz(3),
    PR_NAM_Confidence decimal(7,3),
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID number(10,0),
    Metadata_PR_LEN bigint,
    PR_LEN_ID bigint,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt timestamp_ntz(3),
    PR_LEN_Confidence decimal(7,3),
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    tp.inspectedTimepoint,
    PR.PR_ID,
    PR.Metadata_PR,
    PR.PR_NAM_PR_ID,
    PR.Metadata_PR_NAM,
    PR.PR_NAM_ID,
    PR.PR_NAM_PositedAt,
    PR.PR_NAM_Confidence,
    PR.PR_NAM_Program_Name,
    PR.PR_LEN_PR_ID,
    PR.Metadata_PR_LEN,
    PR.PR_LEN_ID,
    PR.PR_LEN_ChangedAt,
    PR.PR_LEN_PositedAt,
    PR.PR_LEN_Confidence,
    PR.PR_LEN_Program_Length
FROM (
    SELECT DISTINCT
        PR_LEN_PR_ID AS PR_ID,
        PR_LEN_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes.PR_LEN_Program_Length
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
CROSS JOIN LATERAL
    TABLE(anchors.tPR_Program(
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) PR
WHERE
    PR.PR_ID = tp.PR_ID
$$
;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION nexuses.tEV_Event (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    EV_ID numeric(12,0),
    Metadata_EV bigint,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_Metadata_ETY bigint,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT bigint,
    EV_DAT_ID bigint,
    EV_DAT_PositedAt timestamp_ntz(3),
    EV_DAT_Confidence decimal(7,3),
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD bigint,
    EV_AUD_ID bigint,
    EV_AUD_PositedAt timestamp_ntz(3),
    EV_AUD_Confidence decimal(7,3),
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV bigint,
    EV_REV_ID bigint,
    EV_REV_PositedAt timestamp_ntz(3),
    EV_REV_Confidence decimal(7,3),
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA bigint,
    EV_STA_ID bigint,
    EV_STA_ChangedAt datetime,
    EV_STA_PositedAt timestamp_ntz(3),
    EV_STA_Confidence decimal(7,3),
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL bigint,
    EV_UTL_ID bigint,
    EV_UTL_PositedAt timestamp_ntz(3),
    EV_UTL_Confidence decimal(7,3),
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL bigint,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL bigint,
    EV_LVL_ID bigint,
    EV_LVL_ChangedAt date,
    EV_LVL_PositedAt timestamp_ntz(3),
    EV_LVL_Confidence decimal(7,3),
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV bigint,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    kETY_of.ETY_Checksum AS of_ETY_Checksum,
    kETY_of.ETY_EventType AS of_ETY_EventType,
    kETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_ID,
    DAT.EV_DAT_PositedAt,
    DAT.EV_DAT_Confidence,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_ID,
    AUD.EV_AUD_PositedAt,
    AUD.EV_AUD_Confidence,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_ID,
    REV.EV_REV_PositedAt,
    REV.EV_REV_Confidence,
    REV.EV_REV_Event_Revenue,
    STA.EV_STA_EV_ID,
    STA.Metadata_EV_STA,
    STA.EV_STA_ID,
    STA.EV_STA_ChangedAt,
    STA.EV_STA_PositedAt,
    STA.EV_STA_Confidence,
    STA.EV_STA_Event_Status,
    UTL.EV_UTL_EV_ID,
    UTL.Metadata_EV_UTL,
    UTL.EV_UTL_ID,
    UTL.EV_UTL_PositedAt,
    UTL.EV_UTL_Confidence,
    kUTL.UTL_Utilization AS EV_UTL_UTL_Utilization,
    kUTL.Metadata_UTL AS EV_UTL_Metadata_UTL,
    UTL.EV_UTL_UTL_ID,
    LVL.EV_LVL_EV_ID,
    LVL.Metadata_EV_LVL,
    LVL.EV_LVL_ID,
    LVL.EV_LVL_ChangedAt,
    LVL.EV_LVL_PositedAt,
    LVL.EV_LVL_Confidence,
    kLVL.PLV_Checksum AS EV_LVL_PLV_Checksum,
    kLVL.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    kLVL.Metadata_PLV AS EV_LVL_Metadata_PLV,
    LVL.EV_LVL_PLV_ID
FROM
    nexuses.EV_Event EV
LEFT JOIN
    knots.ETY_EventType kETY_of
ON
    kETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(attributes.rEV_DAT_Event_Date(
        positingTimepoint::timestamp_ntz(3)
    )) DAT
ON
    DAT.EV_DAT_ID = (
        SELECT
            sub.EV_DAT_ID
        FROM
            TABLE(attributes.rEV_DAT_Event_Date(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.EV_DAT_EV_ID = EV.EV_ID
        AND
            sub.EV_DAT_Confidence = 1
        ORDER BY
            sub.EV_DAT_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rEV_AUD_Event_Audience(
        positingTimepoint::timestamp_ntz(3)
    )) AUD
ON
    AUD.EV_AUD_ID = (
        SELECT
            sub.EV_AUD_ID
        FROM
            TABLE(attributes.rEV_AUD_Event_Audience(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.EV_AUD_EV_ID = EV.EV_ID
        AND
            sub.EV_AUD_Confidence = 1
        ORDER BY
            sub.EV_AUD_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rEV_REV_Event_Revenue(
        positingTimepoint::timestamp_ntz(3)
    )) REV
ON
    REV.EV_REV_ID = (
        SELECT
            sub.EV_REV_ID
        FROM
            TABLE(attributes.rEV_REV_Event_Revenue(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.EV_REV_EV_ID = EV.EV_ID
        AND
            sub.EV_REV_Confidence = 1
        ORDER BY
            sub.EV_REV_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rEV_STA_Event_Status(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) STA
ON
    STA.EV_STA_ID = (
        SELECT
            sub.EV_STA_ID
        FROM
            TABLE(attributes.rEV_STA_Event_Status(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.EV_STA_EV_ID = EV.EV_ID
        AND
            sub.EV_STA_Confidence = 1
        ORDER BY
            sub.EV_STA_ChangedAt DESC,
            sub.EV_STA_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rEV_UTL_Event_Utilization(
        positingTimepoint::timestamp_ntz(3)
    )) UTL
ON
    UTL.EV_UTL_ID = (
        SELECT
            sub.EV_UTL_ID
        FROM
            TABLE(attributes.rEV_UTL_Event_Utilization(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.EV_UTL_EV_ID = EV.EV_ID
        AND
            sub.EV_UTL_Confidence = 1
        ORDER BY
            sub.EV_UTL_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.UTL_Utilization kUTL
ON
    kUTL.UTL_ID = UTL.EV_UTL_UTL_ID
LEFT JOIN
    TABLE(attributes.rEV_LVL_Event_Level(
        changingTimepoint::date,
        positingTimepoint::timestamp_ntz(3)
    )) LVL
ON
    LVL.EV_LVL_ID = (
        SELECT
            sub.EV_LVL_ID
        FROM
            TABLE(attributes.rEV_LVL_Event_Level(
                changingTimepoint::date,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.EV_LVL_EV_ID = EV.EV_ID
        AND
            sub.EV_LVL_Confidence = 1
        ORDER BY
            sub.EV_LVL_ChangedAt DESC,
            sub.EV_LVL_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.PLV_ProfessionalLevel kLVL
ON
    kLVL.PLV_ID = LVL.EV_LVL_PLV_ID
$$
;
CREATE OR REPLACE VIEW nexuses.lEV_Event COPY GRANTS AS
SELECT
    cast(null as decimal(7,3)) as Confidence,
    EV.*
FROM
    TABLE(nexuses.tEV_Event(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) EV
;
CREATE OR REPLACE FUNCTION nexuses.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Confidence decimal(7,3),
    EV_ID numeric(12,0),
    Metadata_EV bigint,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_Metadata_ETY bigint,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT bigint,
    EV_DAT_ID bigint,
    EV_DAT_PositedAt timestamp_ntz(3),
    EV_DAT_Confidence decimal(7,3),
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD bigint,
    EV_AUD_ID bigint,
    EV_AUD_PositedAt timestamp_ntz(3),
    EV_AUD_Confidence decimal(7,3),
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV bigint,
    EV_REV_ID bigint,
    EV_REV_PositedAt timestamp_ntz(3),
    EV_REV_Confidence decimal(7,3),
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA bigint,
    EV_STA_ID bigint,
    EV_STA_ChangedAt datetime,
    EV_STA_PositedAt timestamp_ntz(3),
    EV_STA_Confidence decimal(7,3),
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL bigint,
    EV_UTL_ID bigint,
    EV_UTL_PositedAt timestamp_ntz(3),
    EV_UTL_Confidence decimal(7,3),
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL bigint,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL bigint,
    EV_LVL_ID bigint,
    EV_LVL_ChangedAt date,
    EV_LVL_PositedAt timestamp_ntz(3),
    EV_LVL_Confidence decimal(7,3),
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV bigint,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT
    cast(null as decimal(7,3)) as Confidence,
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    EV.of_ETY_Checksum,
    EV.of_ETY_EventType,
    EV.of_Metadata_ETY,
    EV.ETY_ID_of,
    EV.EV_DAT_EV_ID,
    EV.Metadata_EV_DAT,
    EV.EV_DAT_ID,
    EV.EV_DAT_PositedAt,
    EV.EV_DAT_Confidence,
    EV.EV_DAT_Event_Date,
    EV.EV_AUD_EV_ID,
    EV.Metadata_EV_AUD,
    EV.EV_AUD_ID,
    EV.EV_AUD_PositedAt,
    EV.EV_AUD_Confidence,
    EV.EV_AUD_Event_Audience,
    EV.EV_REV_EV_ID,
    EV.Metadata_EV_REV,
    EV.EV_REV_ID,
    EV.EV_REV_PositedAt,
    EV.EV_REV_Confidence,
    EV.EV_REV_Event_Revenue,
    EV.EV_STA_EV_ID,
    EV.Metadata_EV_STA,
    EV.EV_STA_ID,
    EV.EV_STA_ChangedAt,
    EV.EV_STA_PositedAt,
    EV.EV_STA_Confidence,
    EV.EV_STA_Event_Status,
    EV.EV_UTL_EV_ID,
    EV.Metadata_EV_UTL,
    EV.EV_UTL_ID,
    EV.EV_UTL_PositedAt,
    EV.EV_UTL_Confidence,
    EV.EV_UTL_UTL_Utilization,
    EV.EV_UTL_Metadata_UTL,
    EV.EV_UTL_UTL_ID,
    EV.EV_LVL_EV_ID,
    EV.Metadata_EV_LVL,
    EV.EV_LVL_ID,
    EV.EV_LVL_ChangedAt,
    EV.EV_LVL_PositedAt,
    EV.EV_LVL_Confidence,
    EV.EV_LVL_PLV_Checksum,
    EV.EV_LVL_PLV_ProfessionalLevel,
    EV.EV_LVL_Metadata_PLV,
    EV.EV_LVL_PLV_ID
FROM
    TABLE(nexuses.tEV_Event(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) EV
$$
;
CREATE OR REPLACE VIEW nexuses.nEV_Event COPY GRANTS AS
SELECT
    cast(null as decimal(7,3)) as Confidence,
    EV.*
FROM
    TABLE(nexuses.tEV_Event(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) EV
;
CREATE OR REPLACE FUNCTION nexuses.dEV_Event (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    EV_ID numeric(12,0),
    Metadata_EV bigint,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_Metadata_ETY bigint,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT bigint,
    EV_DAT_ID bigint,
    EV_DAT_PositedAt timestamp_ntz(3),
    EV_DAT_Confidence decimal(7,3),
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD bigint,
    EV_AUD_ID bigint,
    EV_AUD_PositedAt timestamp_ntz(3),
    EV_AUD_Confidence decimal(7,3),
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV bigint,
    EV_REV_ID bigint,
    EV_REV_PositedAt timestamp_ntz(3),
    EV_REV_Confidence decimal(7,3),
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA bigint,
    EV_STA_ID bigint,
    EV_STA_ChangedAt datetime,
    EV_STA_PositedAt timestamp_ntz(3),
    EV_STA_Confidence decimal(7,3),
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL bigint,
    EV_UTL_ID bigint,
    EV_UTL_PositedAt timestamp_ntz(3),
    EV_UTL_Confidence decimal(7,3),
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL bigint,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL bigint,
    EV_LVL_ID bigint,
    EV_LVL_ChangedAt date,
    EV_LVL_PositedAt timestamp_ntz(3),
    EV_LVL_Confidence decimal(7,3),
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV bigint,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT
    tp.inspectedTimepoint,
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    EV.of_ETY_Checksum,
    EV.of_ETY_EventType,
    EV.of_Metadata_ETY,
    EV.ETY_ID_of,
    EV.EV_DAT_EV_ID,
    EV.Metadata_EV_DAT,
    EV.EV_DAT_ID,
    EV.EV_DAT_PositedAt,
    EV.EV_DAT_Confidence,
    EV.EV_DAT_Event_Date,
    EV.EV_AUD_EV_ID,
    EV.Metadata_EV_AUD,
    EV.EV_AUD_ID,
    EV.EV_AUD_PositedAt,
    EV.EV_AUD_Confidence,
    EV.EV_AUD_Event_Audience,
    EV.EV_REV_EV_ID,
    EV.Metadata_EV_REV,
    EV.EV_REV_ID,
    EV.EV_REV_PositedAt,
    EV.EV_REV_Confidence,
    EV.EV_REV_Event_Revenue,
    EV.EV_STA_EV_ID,
    EV.Metadata_EV_STA,
    EV.EV_STA_ID,
    EV.EV_STA_ChangedAt,
    EV.EV_STA_PositedAt,
    EV.EV_STA_Confidence,
    EV.EV_STA_Event_Status,
    EV.EV_UTL_EV_ID,
    EV.Metadata_EV_UTL,
    EV.EV_UTL_ID,
    EV.EV_UTL_PositedAt,
    EV.EV_UTL_Confidence,
    EV.EV_UTL_UTL_Utilization,
    EV.EV_UTL_Metadata_UTL,
    EV.EV_UTL_UTL_ID,
    EV.EV_LVL_EV_ID,
    EV.Metadata_EV_LVL,
    EV.EV_LVL_ID,
    EV.EV_LVL_ChangedAt,
    EV.EV_LVL_PositedAt,
    EV.EV_LVL_Confidence,
    EV.EV_LVL_PLV_Checksum,
    EV.EV_LVL_PLV_ProfessionalLevel,
    EV.EV_LVL_Metadata_PLV,
    EV.EV_LVL_PLV_ID
FROM (
    SELECT DISTINCT
        EV_STA_EV_ID AS EV_ID,
        EV_STA_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes.EV_STA_Event_Status
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        EV_LVL_EV_ID AS EV_ID,
        EV_LVL_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes.EV_LVL_Event_Level
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
CROSS JOIN LATERAL
    TABLE(nexuses.tEV_Event(
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) EV
WHERE
    EV.EV_ID = tp.EV_ID
$$
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
CREATE TABLE IF NOT EXISTS ties.AC_partner_AC_with_ONG_currently_Fact (
    AC_partner_AC_with_ONG_currently_ID bigint IDENTITY(1,1) not null, 
    AC_ID_partner smallint not null, 
    AC_ID_with smallint not null, 
    ONG_ID_currently tinyint not null,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime not null,
    constraint AC_partner_AC_with_ONG_currently_Fact_fkAC_partner foreign key (
        AC_ID_partner
    ) references anchors.AC_Actor(AC_ID) RELY, 
    constraint AC_partner_AC_with_ONG_currently_Fact_fkAC_with foreign key (
        AC_ID_with
    ) references anchors.AC_Actor(AC_ID) RELY, 
    constraint AC_partner_AC_with_ONG_currently_Fact_fkONG_currently foreign key (
        ONG_ID_currently
    ) references knots.ONG_Ongoing(ONG_ID) RELY,
    constraint AC_partner_AC_with_ONG_currently_Fact_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ) RELY,
    constraint AC_partner_AC_with_ONG_currently_Fact_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ) RELY,
    constraint pkAC_partner_AC_with_ONG_currently_Fact primary key (
        AC_partner_AC_with_ONG_currently_ID
    ) RELY,
    constraint uqAC_partner_AC_with_ONG_currently unique (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    ) RELY
) CLUSTER BY (
    AC_partner_AC_with_ONG_currently_ChangedAt
);
CREATE TABLE IF NOT EXISTS ties.AC_partner_AC_with_ONG_currently_Meta (
    AC_partner_AC_with_ONG_currently_ID bigint not null,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3) not null,
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3) not null,
    Metadata_AC_partner_AC_with_ONG_currently bigint not null,
    constraint fkAC_partner_AC_with_ONG_currently_Meta foreign key (
        AC_partner_AC_with_ONG_currently_ID
    ) references ties.AC_partner_AC_with_ONG_currently_Fact(AC_partner_AC_with_ONG_currently_ID) RELY,
    constraint pkAC_partner_AC_with_ONG_currently_Meta primary key (
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt
    ) RELY
) CLUSTER BY (AC_partner_AC_with_ONG_currently_ID, AC_partner_AC_with_ONG_currently_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_subset_PN_of_Fact (
    AC_subset_PN_of_ID bigint IDENTITY(1,1) not null, 
    AC_ID_subset smallint not null, 
    PN_ID_of bigint not null, 
    constraint AC_subset_PN_of_Fact_fkAC_subset foreign key (
        AC_ID_subset
    ) references anchors.AC_Actor(AC_ID) RELY, 
    constraint AC_subset_PN_of_Fact_fkPN_of foreign key (
        PN_ID_of
    ) references anchors.PN_Person(PN_ID) RELY, 
    constraint AC_subset_PN_of_Fact_uqAC_subset unique (
        AC_ID_subset
    ) RELY,
    constraint AC_subset_PN_of_Fact_uqPN_of unique (
        PN_ID_of
    ) RELY,
    constraint pkAC_subset_PN_of_Fact primary key (
        AC_subset_PN_of_ID
    ) RELY,
    constraint uqAC_subset_PN_of unique (
        AC_ID_subset,
        PN_ID_of
    ) RELY
) CLUSTER BY (
);
CREATE TABLE IF NOT EXISTS ties.AC_subset_PN_of_Meta (
    AC_subset_PN_of_ID bigint not null,
    AC_subset_PN_of_PositedAt timestamp_ntz(3) not null,
    AC_subset_PN_of_Confidence decimal(7,3) not null,
    Metadata_AC_subset_PN_of bigint not null,
    constraint fkAC_subset_PN_of_Meta foreign key (
        AC_subset_PN_of_ID
    ) references ties.AC_subset_PN_of_Fact(AC_subset_PN_of_ID) RELY,
    constraint pkAC_subset_PN_of_Meta primary key (
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt
    ) RELY
) CLUSTER BY (AC_subset_PN_of_ID, AC_subset_PN_of_PositedAt);
CREATE TABLE IF NOT EXISTS ties.EV_in_AC_wasCast_Fact (
    EV_in_AC_wasCast_ID bigint IDENTITY(1,1) not null, 
    EV_ID_in numeric(12,0) not null, 
    AC_ID_wasCast smallint not null, 
    constraint EV_in_AC_wasCast_Fact_fkEV_in foreign key (
        EV_ID_in
    ) references nexuses.EV_Event(EV_ID) RELY, 
    constraint EV_in_AC_wasCast_Fact_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references anchors.AC_Actor(AC_ID) RELY, 
    constraint pkEV_in_AC_wasCast_Fact primary key (
        EV_in_AC_wasCast_ID
    ) RELY,
    constraint uqEV_in_AC_wasCast unique (
        EV_ID_in,
        AC_ID_wasCast
    ) RELY
) CLUSTER BY (
    EV_ID_in,
    AC_ID_wasCast
);
CREATE TABLE IF NOT EXISTS ties.EV_in_AC_wasCast_Meta (
    EV_in_AC_wasCast_ID bigint not null,
    EV_in_AC_wasCast_PositedAt timestamp_ntz(3) not null,
    EV_in_AC_wasCast_Confidence decimal(7,3) not null,
    Metadata_EV_in_AC_wasCast bigint not null,
    constraint fkEV_in_AC_wasCast_Meta foreign key (
        EV_in_AC_wasCast_ID
    ) references ties.EV_in_AC_wasCast_Fact(EV_in_AC_wasCast_ID) RELY,
    constraint pkEV_in_AC_wasCast_Meta primary key (
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt
    ) RELY
) CLUSTER BY (EV_in_AC_wasCast_ID, EV_in_AC_wasCast_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_part_PR_in_RAT_got_Fact (
    AC_part_PR_in_RAT_got_ID bigint IDENTITY(1,1) not null, 
    AC_ID_part smallint not null, 
    PR_ID_in number(10,0) not null, 
    RAT_ID_got tinyint not null,
    AC_part_PR_in_RAT_got_ChangedAt datetime not null,
    constraint AC_part_PR_in_RAT_got_Fact_fkAC_part foreign key (
        AC_ID_part
    ) references anchors.AC_Actor(AC_ID) RELY, 
    constraint AC_part_PR_in_RAT_got_Fact_fkPR_in foreign key (
        PR_ID_in
    ) references anchors.PR_Program(PR_ID) RELY, 
    constraint AC_part_PR_in_RAT_got_Fact_fkRAT_got foreign key (
        RAT_ID_got
    ) references knots.RAT_Rating(RAT_ID) RELY,
    constraint pkAC_part_PR_in_RAT_got_Fact primary key (
        AC_part_PR_in_RAT_got_ID
    ) RELY,
    constraint uqAC_part_PR_in_RAT_got unique (
        AC_ID_part,
        PR_ID_in,
        AC_part_PR_in_RAT_got_ChangedAt,
        RAT_ID_got
    ) RELY
) CLUSTER BY (
    AC_ID_part,
    PR_ID_in,
    AC_part_PR_in_RAT_got_ChangedAt
);
CREATE TABLE IF NOT EXISTS ties.AC_part_PR_in_RAT_got_Meta (
    AC_part_PR_in_RAT_got_ID bigint not null,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3) not null,
    AC_part_PR_in_RAT_got_Confidence decimal(7,3) not null,
    Metadata_AC_part_PR_in_RAT_got bigint not null,
    constraint fkAC_part_PR_in_RAT_got_Meta foreign key (
        AC_part_PR_in_RAT_got_ID
    ) references ties.AC_part_PR_in_RAT_got_Fact(AC_part_PR_in_RAT_got_ID) RELY,
    constraint pkAC_part_PR_in_RAT_got_Meta primary key (
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt
    ) RELY
) CLUSTER BY (AC_part_PR_in_RAT_got_ID, AC_part_PR_in_RAT_got_PositedAt);
CREATE TABLE IF NOT EXISTS ties.ST_at_PR_isPlaying_Fact (
    ST_at_PR_isPlaying_ID bigint IDENTITY(1,1) not null, 
    ST_ID_at int not null, 
    PR_ID_isPlaying number(10,0) not null, 
    ST_at_PR_isPlaying_ChangedAt datetime not null,
    constraint ST_at_PR_isPlaying_Fact_fkST_at foreign key (
        ST_ID_at
    ) references anchors.ST_Stage(ST_ID) RELY, 
    constraint ST_at_PR_isPlaying_Fact_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references anchors.PR_Program(PR_ID) RELY, 
    constraint pkST_at_PR_isPlaying_Fact primary key (
        ST_at_PR_isPlaying_ID
    ) RELY,
    constraint uqST_at_PR_isPlaying unique (
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    ) RELY
) CLUSTER BY (
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
);
CREATE TABLE IF NOT EXISTS ties.ST_at_PR_isPlaying_Meta (
    ST_at_PR_isPlaying_ID bigint not null,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3) not null,
    ST_at_PR_isPlaying_Confidence decimal(7,3) not null,
    Metadata_ST_at_PR_isPlaying bigint not null,
    constraint fkST_at_PR_isPlaying_Meta foreign key (
        ST_at_PR_isPlaying_ID
    ) references ties.ST_at_PR_isPlaying_Fact(ST_at_PR_isPlaying_ID) RELY,
    constraint pkST_at_PR_isPlaying_Meta primary key (
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt
    ) RELY
) CLUSTER BY (ST_at_PR_isPlaying_ID, ST_at_PR_isPlaying_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_parent_AC_child_PAT_having_Fact (
    AC_parent_AC_child_PAT_having_ID bigint IDENTITY(1,1) not null, 
    AC_ID_parent smallint not null, 
    AC_ID_child smallint not null, 
    PAT_ID_having tinyint not null,
    constraint AC_parent_AC_child_PAT_having_Fact_fkAC_parent foreign key (
        AC_ID_parent
    ) references anchors.AC_Actor(AC_ID) RELY, 
    constraint AC_parent_AC_child_PAT_having_Fact_fkAC_child foreign key (
        AC_ID_child
    ) references anchors.AC_Actor(AC_ID) RELY, 
    constraint AC_parent_AC_child_PAT_having_Fact_fkPAT_having foreign key (
        PAT_ID_having
    ) references knots.PAT_ParentalType(PAT_ID) RELY,
    constraint pkAC_parent_AC_child_PAT_having_Fact primary key (
        AC_parent_AC_child_PAT_having_ID
    ) RELY,
    constraint uqAC_parent_AC_child_PAT_having unique (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    ) RELY
) CLUSTER BY (
    AC_ID_parent,
    AC_ID_child,
    PAT_ID_having
);
CREATE TABLE IF NOT EXISTS ties.AC_parent_AC_child_PAT_having_Meta (
    AC_parent_AC_child_PAT_having_ID bigint not null,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3) not null,
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3) not null,
    Metadata_AC_parent_AC_child_PAT_having bigint not null,
    constraint fkAC_parent_AC_child_PAT_having_Meta foreign key (
        AC_parent_AC_child_PAT_having_ID
    ) references ties.AC_parent_AC_child_PAT_having_Fact(AC_parent_AC_child_PAT_having_ID) RELY,
    constraint pkAC_parent_AC_child_PAT_having_Meta primary key (
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt
    ) RELY
) CLUSTER BY (AC_parent_AC_child_PAT_having_ID, AC_parent_AC_child_PAT_having_PositedAt);
CREATE TABLE IF NOT EXISTS ties.PR_content_ST_location_EV_of_Fact (
    PR_content_ST_location_EV_of_ID bigint IDENTITY(1,1) not null, 
    PR_ID_content number(10,0) not null, 
    ST_ID_location int not null, 
    EV_ID_of numeric(12,0) not null, 
    PR_content_ST_location_EV_of_ChangedAt datetime not null,
    constraint PR_content_ST_location_EV_of_Fact_fkPR_content foreign key (
        PR_ID_content
    ) references anchors.PR_Program(PR_ID) RELY, 
    constraint PR_content_ST_location_EV_of_Fact_fkST_location foreign key (
        ST_ID_location
    ) references anchors.ST_Stage(ST_ID) RELY, 
    constraint PR_content_ST_location_EV_of_Fact_fkEV_of foreign key (
        EV_ID_of
    ) references nexuses.EV_Event(EV_ID) RELY, 
    constraint PR_content_ST_location_EV_of_Fact_uqPR_content unique (
        PR_ID_content,
        PR_content_ST_location_EV_of_ChangedAt
    ) RELY,
    constraint PR_content_ST_location_EV_of_Fact_uqST_location unique (
        ST_ID_location,
        PR_content_ST_location_EV_of_ChangedAt
    ) RELY,
    constraint pkPR_content_ST_location_EV_of_Fact primary key (
        PR_content_ST_location_EV_of_ID
    ) RELY,
    constraint uqPR_content_ST_location_EV_of unique (
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    ) RELY
) CLUSTER BY (
    PR_content_ST_location_EV_of_ChangedAt
);
CREATE TABLE IF NOT EXISTS ties.PR_content_ST_location_EV_of_Meta (
    PR_content_ST_location_EV_of_ID bigint not null,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3) not null,
    PR_content_ST_location_EV_of_Confidence decimal(7,3) not null,
    Metadata_PR_content_ST_location_EV_of bigint not null,
    constraint fkPR_content_ST_location_EV_of_Meta foreign key (
        PR_content_ST_location_EV_of_ID
    ) references ties.PR_content_ST_location_EV_of_Fact(PR_content_ST_location_EV_of_ID) RELY,
    constraint pkPR_content_ST_location_EV_of_Meta primary key (
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt
    ) RELY
) CLUSTER BY (PR_content_ST_location_EV_of_ID, PR_content_ST_location_EV_of_PositedAt);
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID bigint,
    AC_ID_partner smallint, 
    AC_ID_with smallint, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime
)
AS
$$
SELECT
    AC_partner_AC_with_ONG_currently_ID,
    AC_ID_partner,
    AC_ID_with,
    ONG_ID_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt
FROM
    ties.AC_partner_AC_with_ONG_currently_Fact
WHERE
    AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID bigint,
    AC_ID_partner smallint, 
    AC_ID_with smallint, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime
)
AS
$$
SELECT
    AC_partner_AC_with_ONG_currently_ID,
    AC_ID_partner,
    AC_ID_with,
    ONG_ID_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt
FROM
    ties.AC_partner_AC_with_ONG_currently_Fact
WHERE
    AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_partner_AC_with_ONG_currently_ID bigint,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3),
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ID,
    AC_partner_AC_with_ONG_currently_PositedAt,
    AC_partner_AC_with_ONG_currently_Confidence
FROM
    ties.AC_partner_AC_with_ONG_currently_Meta
WHERE
    AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_partner_AC_with_ONG_currently_ID bigint,
    AC_ID_partner smallint, 
    AC_ID_with smallint, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3),
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Confidence
FROM
    TABLE(ties.rAC_partner_AC_with_ONG_currently_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_partner_AC_with_ONG_currently_Meta(positingTimepoint)) a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_partner_AC_with_ONG_currently_ID
        ORDER BY a.AC_partner_AC_with_ONG_currently_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_partner_AC_with_ONG_currently_ID bigint,
    AC_ID_partner smallint, 
    AC_ID_with smallint, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3),
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Confidence
FROM
    TABLE(ties.fAC_partner_AC_with_ONG_currently_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_partner_AC_with_ONG_currently_Meta(positingTimepoint)) a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_partner_AC_with_ONG_currently_ID
        ORDER BY a.AC_partner_AC_with_ONG_currently_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of bigint,
    AC_subset_PN_of_ID bigint,
    AC_subset_PN_of_PositedAt timestamp_ntz(3),
    AC_subset_PN_of_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_AC_subset_PN_of,
    AC_subset_PN_of_ID,
    AC_subset_PN_of_PositedAt,
    AC_subset_PN_of_Confidence
FROM
    ties.AC_subset_PN_of_Meta
WHERE
    AC_subset_PN_of_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of bigint,
    AC_subset_PN_of_ID bigint,
    AC_ID_subset smallint, 
    PN_ID_of bigint, 
    AC_subset_PN_of_PositedAt timestamp_ntz(3),
    AC_subset_PN_of_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Confidence
FROM
    ties.AC_subset_PN_of_Fact p
JOIN
    TABLE(ties.rAC_subset_PN_of_Meta(positingTimepoint)) a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_subset_PN_of_ID
        ORDER BY a.AC_subset_PN_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_subset_PN_of (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of bigint,
    AC_subset_PN_of_ID bigint,
    AC_ID_subset smallint, 
    PN_ID_of bigint, 
    AC_subset_PN_of_PositedAt timestamp_ntz(3),
    AC_subset_PN_of_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Confidence
FROM
    ties.AC_subset_PN_of_Fact p
JOIN
    TABLE(ties.rAC_subset_PN_of_Meta(positingTimepoint)) a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_subset_PN_of_ID
        ORDER BY a.AC_subset_PN_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast bigint,
    EV_in_AC_wasCast_ID bigint,
    EV_in_AC_wasCast_PositedAt timestamp_ntz(3),
    EV_in_AC_wasCast_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_EV_in_AC_wasCast,
    EV_in_AC_wasCast_ID,
    EV_in_AC_wasCast_PositedAt,
    EV_in_AC_wasCast_Confidence
FROM
    ties.EV_in_AC_wasCast_Meta
WHERE
    EV_in_AC_wasCast_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast bigint,
    EV_in_AC_wasCast_ID bigint,
    EV_ID_in numeric(12,0), 
    AC_ID_wasCast smallint, 
    EV_in_AC_wasCast_PositedAt timestamp_ntz(3),
    EV_in_AC_wasCast_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Confidence
FROM
    ties.EV_in_AC_wasCast_Fact p
JOIN
    TABLE(ties.rEV_in_AC_wasCast_Meta(positingTimepoint)) a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_in_AC_wasCast_ID
        ORDER BY a.EV_in_AC_wasCast_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fEV_in_AC_wasCast (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast bigint,
    EV_in_AC_wasCast_ID bigint,
    EV_ID_in numeric(12,0), 
    AC_ID_wasCast smallint, 
    EV_in_AC_wasCast_PositedAt timestamp_ntz(3),
    EV_in_AC_wasCast_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Confidence
FROM
    ties.EV_in_AC_wasCast_Fact p
JOIN
    TABLE(ties.rEV_in_AC_wasCast_Meta(positingTimepoint)) a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_in_AC_wasCast_ID
        ORDER BY a.EV_in_AC_wasCast_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID bigint,
    AC_ID_part smallint, 
    PR_ID_in number(10,0), 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime
)
AS
$$
SELECT
    AC_part_PR_in_RAT_got_ID,
    AC_ID_part,
    PR_ID_in,
    RAT_ID_got,
    AC_part_PR_in_RAT_got_ChangedAt
FROM
    ties.AC_part_PR_in_RAT_got_Fact
WHERE
    AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID bigint,
    AC_ID_part smallint, 
    PR_ID_in number(10,0), 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime
)
AS
$$
SELECT
    AC_part_PR_in_RAT_got_ID,
    AC_ID_part,
    PR_ID_in,
    RAT_ID_got,
    AC_part_PR_in_RAT_got_ChangedAt
FROM
    ties.AC_part_PR_in_RAT_got_Fact
WHERE
    AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_part_PR_in_RAT_got_ID bigint,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3),
    AC_part_PR_in_RAT_got_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_AC_part_PR_in_RAT_got,
    AC_part_PR_in_RAT_got_ID,
    AC_part_PR_in_RAT_got_PositedAt,
    AC_part_PR_in_RAT_got_Confidence
FROM
    ties.AC_part_PR_in_RAT_got_Meta
WHERE
    AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_part_PR_in_RAT_got_ID bigint,
    AC_ID_part smallint, 
    PR_ID_in number(10,0), 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3),
    AC_part_PR_in_RAT_got_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_AC_part_PR_in_RAT_got,
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Confidence
FROM
    TABLE(ties.rAC_part_PR_in_RAT_got_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_part_PR_in_RAT_got_Meta(positingTimepoint)) a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_part_PR_in_RAT_got_ID
        ORDER BY a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_part_PR_in_RAT_got_ID bigint,
    AC_ID_part smallint, 
    PR_ID_in number(10,0), 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3),
    AC_part_PR_in_RAT_got_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_AC_part_PR_in_RAT_got,
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Confidence
FROM
    TABLE(ties.fAC_part_PR_in_RAT_got_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_part_PR_in_RAT_got_Meta(positingTimepoint)) a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_part_PR_in_RAT_got_ID
        ORDER BY a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID bigint,
    ST_ID_at int, 
    PR_ID_isPlaying number(10,0), 
    ST_at_PR_isPlaying_ChangedAt datetime
)
AS
$$
SELECT
    ST_at_PR_isPlaying_ID,
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
FROM
    ties.ST_at_PR_isPlaying_Fact
WHERE
    ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID bigint,
    ST_ID_at int, 
    PR_ID_isPlaying number(10,0), 
    ST_at_PR_isPlaying_ChangedAt datetime
)
AS
$$
SELECT
    ST_at_PR_isPlaying_ID,
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
FROM
    ties.ST_at_PR_isPlaying_Fact
WHERE
    ST_at_PR_isPlaying_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying bigint,
    ST_at_PR_isPlaying_ID bigint,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3),
    ST_at_PR_isPlaying_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_ST_at_PR_isPlaying,
    ST_at_PR_isPlaying_ID,
    ST_at_PR_isPlaying_PositedAt,
    ST_at_PR_isPlaying_Confidence
FROM
    ties.ST_at_PR_isPlaying_Meta
WHERE
    ST_at_PR_isPlaying_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying bigint,
    ST_at_PR_isPlaying_ID bigint,
    ST_ID_at int, 
    PR_ID_isPlaying number(10,0), 
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3),
    ST_at_PR_isPlaying_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Confidence
FROM
    TABLE(ties.rST_at_PR_isPlaying_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rST_at_PR_isPlaying_Meta(positingTimepoint)) a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_at_PR_isPlaying_ID
        ORDER BY a.ST_at_PR_isPlaying_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying bigint,
    ST_at_PR_isPlaying_ID bigint,
    ST_ID_at int, 
    PR_ID_isPlaying number(10,0), 
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3),
    ST_at_PR_isPlaying_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Confidence
FROM
    TABLE(ties.fST_at_PR_isPlaying_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rST_at_PR_isPlaying_Meta(positingTimepoint)) a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_at_PR_isPlaying_ID
        ORDER BY a.ST_at_PR_isPlaying_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having bigint,
    AC_parent_AC_child_PAT_having_ID bigint,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3),
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_AC_parent_AC_child_PAT_having,
    AC_parent_AC_child_PAT_having_ID,
    AC_parent_AC_child_PAT_having_PositedAt,
    AC_parent_AC_child_PAT_having_Confidence
FROM
    ties.AC_parent_AC_child_PAT_having_Meta
WHERE
    AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having bigint,
    AC_parent_AC_child_PAT_having_ID bigint,
    AC_ID_parent smallint, 
    AC_ID_child smallint, 
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3),
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_AC_parent_AC_child_PAT_having,
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Confidence
FROM
    ties.AC_parent_AC_child_PAT_having_Fact p
JOIN
    TABLE(ties.rAC_parent_AC_child_PAT_having_Meta(positingTimepoint)) a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_parent_AC_child_PAT_having_ID
        ORDER BY a.AC_parent_AC_child_PAT_having_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_parent_AC_child_PAT_having (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having bigint,
    AC_parent_AC_child_PAT_having_ID bigint,
    AC_ID_parent smallint, 
    AC_ID_child smallint, 
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3),
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_AC_parent_AC_child_PAT_having,
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Confidence
FROM
    ties.AC_parent_AC_child_PAT_having_Fact p
JOIN
    TABLE(ties.rAC_parent_AC_child_PAT_having_Meta(positingTimepoint)) a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_parent_AC_child_PAT_having_ID
        ORDER BY a.AC_parent_AC_child_PAT_having_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID bigint,
    PR_ID_content number(10,0), 
    ST_ID_location int, 
    EV_ID_of numeric(12,0), 
    PR_content_ST_location_EV_of_ChangedAt datetime
)
AS
$$
SELECT
    PR_content_ST_location_EV_of_ID,
    PR_ID_content,
    ST_ID_location,
    EV_ID_of,
    PR_content_ST_location_EV_of_ChangedAt
FROM
    ties.PR_content_ST_location_EV_of_Fact
WHERE
    PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of_Fact (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID bigint,
    PR_ID_content number(10,0), 
    ST_ID_location int, 
    EV_ID_of numeric(12,0), 
    PR_content_ST_location_EV_of_ChangedAt datetime
)
AS
$$
SELECT
    PR_content_ST_location_EV_of_ID,
    PR_ID_content,
    ST_ID_location,
    EV_ID_of,
    PR_content_ST_location_EV_of_ChangedAt
FROM
    ties.PR_content_ST_location_EV_of_Fact
WHERE
    PR_content_ST_location_EV_of_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Meta (
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_content_ST_location_EV_of_ID bigint,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3),
    PR_content_ST_location_EV_of_Confidence decimal(7,3)
)
AS
$$
SELECT
    Metadata_PR_content_ST_location_EV_of,
    PR_content_ST_location_EV_of_ID,
    PR_content_ST_location_EV_of_PositedAt,
    PR_content_ST_location_EV_of_Confidence
FROM
    ties.PR_content_ST_location_EV_of_Meta
WHERE
    PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_content_ST_location_EV_of_ID bigint,
    PR_ID_content number(10,0), 
    ST_ID_location int, 
    EV_ID_of numeric(12,0), 
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3),
    PR_content_ST_location_EV_of_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    p.PR_content_ST_location_EV_of_ChangedAt,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Confidence
FROM
    TABLE(ties.rPR_content_ST_location_EV_of_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rPR_content_ST_location_EV_of_Meta(positingTimepoint)) a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_content_ST_location_EV_of_ID
        ORDER BY a.PR_content_ST_location_EV_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of (
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_content_ST_location_EV_of_ID bigint,
    PR_ID_content number(10,0), 
    ST_ID_location int, 
    EV_ID_of numeric(12,0), 
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3),
    PR_content_ST_location_EV_of_Confidence decimal(7,3)
)
AS
$$
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    p.PR_content_ST_location_EV_of_ChangedAt,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Confidence
FROM
    TABLE(ties.fPR_content_ST_location_EV_of_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rPR_content_ST_location_EV_of_Meta(positingTimepoint)) a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_content_ST_location_EV_of_ID
        ORDER BY a.PR_content_ST_location_EV_of_PositedAt DESC
    ) = 1
$$
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION ties.tAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID bigint,
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3),
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3),
    AC_ID_partner smallint,
    AC_ID_with smallint,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG bigint,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    t.AC_partner_AC_with_ONG_currently_ID,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Confidence,
    t.AC_ID_partner,
    t.AC_ID_with,
    kONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    kONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    t.ONG_ID_currently
FROM
    TABLE(ties.rAC_partner_AC_with_ONG_currently(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
LEFT JOIN
    knots.ONG_Ongoing kONG_currently
ON
    kONG_currently.ONG_ID = t.ONG_ID_currently
WHERE
    t.AC_partner_AC_with_ONG_currently_Confidence = 1
AND
    t.AC_partner_AC_with_ONG_currently_ID = (
        SELECT
            sub.AC_partner_AC_with_ONG_currently_ID
        FROM
            TABLE(ties.rAC_partner_AC_with_ONG_currently(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            (
                sub.AC_ID_partner = t.AC_ID_partner
            OR
                sub.AC_ID_with = t.AC_ID_with
            )
        ORDER BY
            sub.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
            sub.AC_partner_AC_with_ONG_currently_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID bigint,
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3),
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3),
    AC_ID_partner smallint,
    AC_ID_with smallint,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG bigint,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    t.AC_partner_AC_with_ONG_currently_ID,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Confidence,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.currently_ONG_Ongoing,
    t.currently_Metadata_ONG,
    t.ONG_ID_currently
FROM
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID bigint,
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3),
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3),
    AC_ID_partner smallint,
    AC_ID_with smallint,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG bigint,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    t.AC_partner_AC_with_ONG_currently_ID,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Confidence,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.currently_ONG_Ongoing,
    t.currently_Metadata_ONG,
    t.ONG_ID_currently
FROM
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
WHERE
    t.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION ties.tAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    AC_subset_PN_of_ID bigint,
    Metadata_AC_subset_PN_of bigint,
    AC_subset_PN_of_PositedAt timestamp_ntz(3),
    AC_subset_PN_of_Confidence decimal(7,3),
    AC_ID_subset smallint,
    PN_ID_of bigint
)
AS
$$
SELECT
    t.AC_subset_PN_of_ID,
    t.Metadata_AC_subset_PN_of,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Confidence,
    t.AC_ID_subset,
    t.PN_ID_of
FROM
    TABLE(ties.rAC_subset_PN_of(
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t.AC_subset_PN_of_Confidence = 1
AND
    t.AC_subset_PN_of_ID = (
        SELECT
            sub.AC_subset_PN_of_ID
        FROM
            TABLE(ties.rAC_subset_PN_of(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            (
                sub.AC_ID_subset = t.AC_ID_subset
            OR
                sub.PN_ID_of = t.PN_ID_of
            )
        ORDER BY
            sub.AC_subset_PN_of_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tAC_subset_PN_of(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_subset_PN_of_ID bigint,
    Metadata_AC_subset_PN_of bigint,
    AC_subset_PN_of_PositedAt timestamp_ntz(3),
    AC_subset_PN_of_Confidence decimal(7,3),
    AC_ID_subset smallint,
    PN_ID_of bigint
)
AS
$$
SELECT
    t.AC_subset_PN_of_ID,
    t.Metadata_AC_subset_PN_of,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Confidence,
    t.AC_ID_subset,
    t.PN_ID_of
FROM
    TABLE(ties.tAC_subset_PN_of(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tAC_subset_PN_of(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.tEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    EV_in_AC_wasCast_ID bigint,
    Metadata_EV_in_AC_wasCast bigint,
    EV_in_AC_wasCast_PositedAt timestamp_ntz(3),
    EV_in_AC_wasCast_Confidence decimal(7,3),
    EV_ID_in numeric(12,0),
    AC_ID_wasCast smallint
)
AS
$$
SELECT
    t.EV_in_AC_wasCast_ID,
    t.Metadata_EV_in_AC_wasCast,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Confidence,
    t.EV_ID_in,
    t.AC_ID_wasCast
FROM
    TABLE(ties.rEV_in_AC_wasCast(
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t.EV_in_AC_wasCast_Confidence = 1
AND
    t.EV_in_AC_wasCast_ID = (
        SELECT
            sub.EV_in_AC_wasCast_ID
        FROM
            TABLE(ties.rEV_in_AC_wasCast(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.EV_ID_in = t.EV_ID_in
        AND
            sub.AC_ID_wasCast = t.AC_ID_wasCast
        ORDER BY
            sub.EV_in_AC_wasCast_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tEV_in_AC_wasCast(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    EV_in_AC_wasCast_ID bigint,
    Metadata_EV_in_AC_wasCast bigint,
    EV_in_AC_wasCast_PositedAt timestamp_ntz(3),
    EV_in_AC_wasCast_Confidence decimal(7,3),
    EV_ID_in numeric(12,0),
    AC_ID_wasCast smallint
)
AS
$$
SELECT
    t.EV_in_AC_wasCast_ID,
    t.Metadata_EV_in_AC_wasCast,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Confidence,
    t.EV_ID_in,
    t.AC_ID_wasCast
FROM
    TABLE(ties.tEV_in_AC_wasCast(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tEV_in_AC_wasCast(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.tAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID bigint,
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3),
    AC_part_PR_in_RAT_got_Confidence decimal(7,3),
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    got_RAT_Rating varchar(42),
    got_Metadata_RAT bigint,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    t.AC_part_PR_in_RAT_got_ID,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Confidence,
    t.AC_ID_part,
    t.PR_ID_in,
    kRAT_got.RAT_Rating AS got_RAT_Rating,
    kRAT_got.Metadata_RAT AS got_Metadata_RAT,
    t.RAT_ID_got
FROM
    TABLE(ties.rAC_part_PR_in_RAT_got(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
LEFT JOIN
    knots.RAT_Rating kRAT_got
ON
    kRAT_got.RAT_ID = t.RAT_ID_got
WHERE
    t.AC_part_PR_in_RAT_got_Confidence = 1
AND
    t.AC_part_PR_in_RAT_got_ID = (
        SELECT
            sub.AC_part_PR_in_RAT_got_ID
        FROM
            TABLE(ties.rAC_part_PR_in_RAT_got(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.AC_ID_part = t.AC_ID_part
        AND
            sub.PR_ID_in = t.PR_ID_in
        ORDER BY
            sub.AC_part_PR_in_RAT_got_ChangedAt DESC,
            sub.AC_part_PR_in_RAT_got_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tAC_part_PR_in_RAT_got(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID bigint,
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3),
    AC_part_PR_in_RAT_got_Confidence decimal(7,3),
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    got_RAT_Rating varchar(42),
    got_Metadata_RAT bigint,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    t.AC_part_PR_in_RAT_got_ID,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Confidence,
    t.AC_ID_part,
    t.PR_ID_in,
    t.got_RAT_Rating,
    t.got_Metadata_RAT,
    t.RAT_ID_got
FROM
    TABLE(ties.tAC_part_PR_in_RAT_got(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties.nAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tAC_part_PR_in_RAT_got(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID bigint,
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3),
    AC_part_PR_in_RAT_got_Confidence decimal(7,3),
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    got_RAT_Rating varchar(42),
    got_Metadata_RAT bigint,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    t.AC_part_PR_in_RAT_got_ID,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Confidence,
    t.AC_ID_part,
    t.PR_ID_in,
    t.got_RAT_Rating,
    t.got_Metadata_RAT,
    t.RAT_ID_got
FROM
    TABLE(ties.tAC_part_PR_in_RAT_got(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
WHERE
    t.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION ties.tST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID bigint,
    Metadata_ST_at_PR_isPlaying bigint,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3),
    ST_at_PR_isPlaying_Confidence decimal(7,3),
    ST_ID_at int,
    PR_ID_isPlaying number(10,0)
)
AS
$$
SELECT
    t.ST_at_PR_isPlaying_ID,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Confidence,
    t.ST_ID_at,
    t.PR_ID_isPlaying
FROM
    TABLE(ties.rST_at_PR_isPlaying(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t.ST_at_PR_isPlaying_Confidence = 1
AND
    t.ST_at_PR_isPlaying_ID = (
        SELECT
            sub.ST_at_PR_isPlaying_ID
        FROM
            TABLE(ties.rST_at_PR_isPlaying(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.ST_ID_at = t.ST_ID_at
        AND
            sub.PR_ID_isPlaying = t.PR_ID_isPlaying
        ORDER BY
            sub.ST_at_PR_isPlaying_ChangedAt DESC,
            sub.ST_at_PR_isPlaying_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tST_at_PR_isPlaying(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID bigint,
    Metadata_ST_at_PR_isPlaying bigint,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3),
    ST_at_PR_isPlaying_Confidence decimal(7,3),
    ST_ID_at int,
    PR_ID_isPlaying number(10,0)
)
AS
$$
SELECT
    t.ST_at_PR_isPlaying_ID,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Confidence,
    t.ST_ID_at,
    t.PR_ID_isPlaying
FROM
    TABLE(ties.tST_at_PR_isPlaying(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties.nST_at_PR_isPlaying COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tST_at_PR_isPlaying(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID bigint,
    Metadata_ST_at_PR_isPlaying bigint,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3),
    ST_at_PR_isPlaying_Confidence decimal(7,3),
    ST_ID_at int,
    PR_ID_isPlaying number(10,0)
)
AS
$$
SELECT
    t.ST_at_PR_isPlaying_ID,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Confidence,
    t.ST_ID_at,
    t.PR_ID_isPlaying
FROM
    TABLE(ties.tST_at_PR_isPlaying(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
WHERE
    t.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION ties.tAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    AC_parent_AC_child_PAT_having_ID bigint,
    Metadata_AC_parent_AC_child_PAT_having bigint,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3),
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3),
    AC_ID_parent smallint,
    AC_ID_child smallint,
    having_PAT_ParentalType varchar(42),
    having_Metadata_PAT bigint,
    PAT_ID_having tinyint
)
AS
$$
SELECT
    t.AC_parent_AC_child_PAT_having_ID,
    t.Metadata_AC_parent_AC_child_PAT_having,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Confidence,
    t.AC_ID_parent,
    t.AC_ID_child,
    kPAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    kPAT_having.Metadata_PAT AS having_Metadata_PAT,
    t.PAT_ID_having
FROM
    TABLE(ties.rAC_parent_AC_child_PAT_having(
        positingTimepoint::timestamp_ntz(3)
    )) t
LEFT JOIN
    knots.PAT_ParentalType kPAT_having
ON
    kPAT_having.PAT_ID = t.PAT_ID_having
WHERE
    t.AC_parent_AC_child_PAT_having_Confidence = 1
AND
    t.AC_parent_AC_child_PAT_having_ID = (
        SELECT
            sub.AC_parent_AC_child_PAT_having_ID
        FROM
            TABLE(ties.rAC_parent_AC_child_PAT_having(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.AC_ID_parent = t.AC_ID_parent
        AND
            sub.AC_ID_child = t.AC_ID_child
        AND
            sub.PAT_ID_having = t.PAT_ID_having
        ORDER BY
            sub.AC_parent_AC_child_PAT_having_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tAC_parent_AC_child_PAT_having(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_parent_AC_child_PAT_having_ID bigint,
    Metadata_AC_parent_AC_child_PAT_having bigint,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3),
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3),
    AC_ID_parent smallint,
    AC_ID_child smallint,
    having_PAT_ParentalType varchar(42),
    having_Metadata_PAT bigint,
    PAT_ID_having tinyint
)
AS
$$
SELECT
    t.AC_parent_AC_child_PAT_having_ID,
    t.Metadata_AC_parent_AC_child_PAT_having,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Confidence,
    t.AC_ID_parent,
    t.AC_ID_child,
    t.having_PAT_ParentalType,
    t.having_Metadata_PAT,
    t.PAT_ID_having
FROM
    TABLE(ties.tAC_parent_AC_child_PAT_having(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tAC_parent_AC_child_PAT_having(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.tPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID bigint,
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3),
    PR_content_ST_location_EV_of_Confidence decimal(7,3),
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0)
)
AS
$$
SELECT
    t.PR_content_ST_location_EV_of_ID,
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_content_ST_location_EV_of_ChangedAt,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Confidence,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of
FROM
    TABLE(ties.rPR_content_ST_location_EV_of(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t.PR_content_ST_location_EV_of_Confidence = 1
AND
    t.PR_content_ST_location_EV_of_ID = (
        SELECT
            sub.PR_content_ST_location_EV_of_ID
        FROM
            TABLE(ties.rPR_content_ST_location_EV_of(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            (
                sub.PR_ID_content = t.PR_ID_content
            OR
                sub.ST_ID_location = t.ST_ID_location
            )
        ORDER BY
            sub.PR_content_ST_location_EV_of_ChangedAt DESC,
            sub.PR_content_ST_location_EV_of_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tPR_content_ST_location_EV_of(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID bigint,
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3),
    PR_content_ST_location_EV_of_Confidence decimal(7,3),
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0)
)
AS
$$
SELECT
    t.PR_content_ST_location_EV_of_ID,
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_content_ST_location_EV_of_ChangedAt,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Confidence,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of
FROM
    TABLE(ties.tPR_content_ST_location_EV_of(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties.nPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties.tPR_content_ST_location_EV_of(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties.dPR_content_ST_location_EV_of (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID bigint,
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3),
    PR_content_ST_location_EV_of_Confidence decimal(7,3),
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0)
)
AS
$$
SELECT
    t.PR_content_ST_location_EV_of_ID,
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_content_ST_location_EV_of_ChangedAt,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Confidence,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of
FROM
    TABLE(ties.tPR_content_ST_location_EV_of(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
WHERE
    t.PR_content_ST_location_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers. Views get their comments when they are
-- created, since Snowflake does not allow comments on view columns to be added afterwards.
--
COMMENT ON SCHEMA dw IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE knots.PAT_ParentalType IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON COLUMN knots.PAT_ParentalType.PAT_ParentalType IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE knots.GEN_Gender IS 'Gender of an actor.';
COMMENT ON COLUMN knots.GEN_Gender.GEN_Gender IS 'Gender of an actor.';
COMMENT ON TABLE knots.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN knots.PLV_ProfessionalLevel.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE knots.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN knots.UTL_Utilization.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE knots.ONG_Ongoing IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN knots.ONG_Ongoing.ONG_Ongoing IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE knots.RAT_Rating IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN knots.RAT_Rating.RAT_Rating IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date IS 'Date and time when the event took place.';
COMMENT ON COLUMN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status IS 'Status of the event, which may change until it has taken place.';
COMMENT ON COLUMN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID IS 'Professional level required for the event, over time.';
COMMENT ON COLUMN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name IS 'Name or title of the program.';
COMMENT ON COLUMN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE anchors.PN_Person IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE anchors.ST_Stage IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE anchors.AC_Actor IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE nexuses.EV_Event IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN nexuses.EV_Event.ST_ID_wasHeldAt IS 'The stage at which the event was held.';
COMMENT ON COLUMN nexuses.EV_Event.PR_ID_wasPlayed IS 'The program that was played at the event.';
COMMENT ON TABLE ties.AC_partner_AC_with_ONG_currently_Fact IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently_Fact.AC_ID_partner IS 'One of the actors in the partnership.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently_Fact.AC_ID_with IS 'The other actor in the partnership.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently_Fact.ONG_ID_currently IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON COLUMN ties.AC_subset_PN_of_Fact.AC_ID_subset IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON COLUMN ties.AC_subset_PN_of_Fact.PN_ID_of IS 'The person who is the actor.';
COMMENT ON TABLE ties.EV_in_AC_wasCast_Fact IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN ties.EV_in_AC_wasCast_Fact.EV_ID_in IS 'The event the actor was cast in.';
COMMENT ON COLUMN ties.EV_in_AC_wasCast_Fact.AC_ID_wasCast IS 'An actor cast in the event.';
COMMENT ON TABLE ties.AC_part_PR_in_RAT_got_Fact IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN ties.AC_part_PR_in_RAT_got_Fact.AC_ID_part IS 'The actor having a part in the program.';
COMMENT ON COLUMN ties.AC_part_PR_in_RAT_got_Fact.PR_ID_in IS 'The program the actor has a part in.';
COMMENT ON COLUMN ties.AC_part_PR_in_RAT_got_Fact.RAT_ID_got IS 'The rating the actor got for the part.';
COMMENT ON TABLE ties.ST_at_PR_isPlaying_Fact IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ties.ST_at_PR_isPlaying_Fact.ST_ID_at IS 'The stage where the program is playing.';
COMMENT ON COLUMN ties.ST_at_PR_isPlaying_Fact.PR_ID_isPlaying IS 'The program playing at the stage.';
COMMENT ON TABLE ties.AC_parent_AC_child_PAT_having_Fact IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN ties.AC_parent_AC_child_PAT_having_Fact.AC_ID_parent IS 'The actor who is the parent.';
COMMENT ON COLUMN ties.AC_parent_AC_child_PAT_having_Fact.AC_ID_child IS 'The actor who is the child.';
COMMENT ON COLUMN ties.AC_parent_AC_child_PAT_having_Fact.PAT_ID_having IS 'The type of parental relationship.';
COMMENT ON TABLE ties.PR_content_ST_location_EV_of_Fact IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN ties.PR_content_ST_location_EV_of_Fact.PR_ID_content IS 'The program that made up the content of the event.';
COMMENT ON COLUMN ties.PR_content_ST_location_EV_of_Fact.ST_ID_location IS 'The stage where the event was located.';
COMMENT ON COLUMN ties.PR_content_ST_location_EV_of_Fact.EV_ID_of IS 'The event.';
