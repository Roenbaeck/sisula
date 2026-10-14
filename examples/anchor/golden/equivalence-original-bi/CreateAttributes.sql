-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS attributes."EV_DAT_Event_Date_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Event_Date_Posit" (
    "EV_DAT_ID" int default attributes."EV_DAT_Event_Date_Posit_ID_SEQ".nextval not null, 
    "EV_ID" numeric(12,0) not null,
    "EV_DAT_Event_Date" datetime not null,
    constraint "fkEV_DAT_Event_Date_Posit" foreign key (
        "EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "pkEV_DAT_Event_Date_Posit" primary key (
        "EV_DAT_ID"
    ) RELY,
    constraint "uqEV_DAT_Event_Date_Posit" unique (
        "EV_ID",
        "EV_DAT_Event_Date"
    ) RELY
) CLUSTER BY ("EV_ID");
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Event_Date_Annex" (
    "EV_DAT_ID" int not null,
    "EV_DAT_PositedAt" datetime not null,
    "EV_DAT_Reliability" decimal(5,2) not null,
    "Metadata_EV_DAT" int not null,
    constraint "fkEV_DAT_Event_Date_Annex" foreign key (
        "EV_DAT_ID"
    ) references attributes."EV_DAT_Event_Date_Posit"("EV_DAT_ID") RELY,
    constraint "pkEV_DAT_Event_Date_Annex" primary key (
        "EV_DAT_ID",
        "EV_DAT_PositedAt"
    ) RELY
) CLUSTER BY ("EV_DAT_ID", "EV_DAT_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."EV_AUD_Event_Audience_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Event_Audience_Posit" (
    "EV_AUD_ID" int default attributes."EV_AUD_Event_Audience_Posit_ID_SEQ".nextval not null, 
    "EV_ID" numeric(12,0) not null,
    "EV_AUD_Event_Audience" int not null,
    constraint "fkEV_AUD_Event_Audience_Posit" foreign key (
        "EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "pkEV_AUD_Event_Audience_Posit" primary key (
        "EV_AUD_ID"
    ) RELY,
    constraint "uqEV_AUD_Event_Audience_Posit" unique (
        "EV_ID",
        "EV_AUD_Event_Audience"
    ) RELY
) CLUSTER BY ("EV_ID");
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Event_Audience_Annex" (
    "EV_AUD_ID" int not null,
    "EV_AUD_PositedAt" datetime not null,
    "EV_AUD_Reliability" decimal(5,2) not null,
    "Metadata_EV_AUD" int not null,
    constraint "fkEV_AUD_Event_Audience_Annex" foreign key (
        "EV_AUD_ID"
    ) references attributes."EV_AUD_Event_Audience_Posit"("EV_AUD_ID") RELY,
    constraint "pkEV_AUD_Event_Audience_Annex" primary key (
        "EV_AUD_ID",
        "EV_AUD_PositedAt"
    ) RELY
) CLUSTER BY ("EV_AUD_ID", "EV_AUD_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."EV_REV_Event_Revenue_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Event_Revenue_Posit" (
    "EV_REV_ID" int default attributes."EV_REV_Event_Revenue_Posit_ID_SEQ".nextval not null, 
    "EV_ID" numeric(12,0) not null,
    "EV_REV_Event_Revenue" number(19,4) not null,
    constraint "fkEV_REV_Event_Revenue_Posit" foreign key (
        "EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "pkEV_REV_Event_Revenue_Posit" primary key (
        "EV_REV_ID"
    ) RELY,
    constraint "uqEV_REV_Event_Revenue_Posit" unique (
        "EV_ID",
        "EV_REV_Event_Revenue"
    ) RELY
) CLUSTER BY ("EV_ID");
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Event_Revenue_Annex" (
    "EV_REV_ID" int not null,
    "EV_REV_PositedAt" datetime not null,
    "EV_REV_Reliability" decimal(5,2) not null,
    "Metadata_EV_REV" int not null,
    constraint "fkEV_REV_Event_Revenue_Annex" foreign key (
        "EV_REV_ID"
    ) references attributes."EV_REV_Event_Revenue_Posit"("EV_REV_ID") RELY,
    constraint "pkEV_REV_Event_Revenue_Annex" primary key (
        "EV_REV_ID",
        "EV_REV_PositedAt"
    ) RELY
) CLUSTER BY ("EV_REV_ID", "EV_REV_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."EV_STA_Event_Status_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Event_Status_Posit" (
    "EV_STA_ID" int default attributes."EV_STA_Event_Status_Posit_ID_SEQ".nextval not null, 
    "EV_ID" numeric(12,0) not null,
    "EV_STA_Event_Status" varchar(20) not null,
    "EV_STA_ChangedAt" datetime not null,
    constraint "fkEV_STA_Event_Status_Posit" foreign key (
        "EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "pkEV_STA_Event_Status_Posit" primary key (
        "EV_STA_ID"
    ) RELY,
    constraint "uqEV_STA_Event_Status_Posit" unique (
        "EV_ID",
        "EV_STA_ChangedAt",
        "EV_STA_Event_Status"
    ) RELY
) CLUSTER BY ("EV_ID");
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Event_Status_Annex" (
    "EV_STA_ID" int not null,
    "EV_STA_PositedAt" datetime not null,
    "EV_STA_Reliability" decimal(5,2) not null,
    "Metadata_EV_STA" int not null,
    constraint "fkEV_STA_Event_Status_Annex" foreign key (
        "EV_STA_ID"
    ) references attributes."EV_STA_Event_Status_Posit"("EV_STA_ID") RELY,
    constraint "pkEV_STA_Event_Status_Annex" primary key (
        "EV_STA_ID",
        "EV_STA_PositedAt"
    ) RELY
) CLUSTER BY ("EV_STA_ID", "EV_STA_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."EV_UTL_Event_Utilization_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Event_Utilization_Posit" (
    "EV_UTL_ID" int default attributes."EV_UTL_Event_Utilization_Posit_ID_SEQ".nextval not null, 
    "EV_ID" numeric(12,0) not null,
    "UTL_ID" tinyint not null,
    constraint "fk_A_EV_UTL_Event_Utilization_Posit" foreign key (
        "EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "fk_K_EV_UTL_Event_Utilization_Posit" foreign key (
        "UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID") RELY,
    constraint "pkEV_UTL_Event_Utilization_Posit" primary key (
        "EV_UTL_ID"
    ) RELY,
    constraint "uqEV_UTL_Event_Utilization_Posit" unique (
        "EV_ID",
        "UTL_ID"
    ) RELY
) CLUSTER BY ("EV_ID");
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Event_Utilization_Annex" (
    "EV_UTL_ID" int not null,
    "EV_UTL_PositedAt" datetime not null,
    "EV_UTL_Reliability" decimal(5,2) not null,
    "Metadata_EV_UTL" int not null,
    constraint "fkEV_UTL_Event_Utilization_Annex" foreign key (
        "EV_UTL_ID"
    ) references attributes."EV_UTL_Event_Utilization_Posit"("EV_UTL_ID") RELY,
    constraint "pkEV_UTL_Event_Utilization_Annex" primary key (
        "EV_UTL_ID",
        "EV_UTL_PositedAt"
    ) RELY
) CLUSTER BY ("EV_UTL_ID", "EV_UTL_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."EV_LVL_Event_Level_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Event_Level_Posit" (
    "EV_LVL_ID" int default attributes."EV_LVL_Event_Level_Posit_ID_SEQ".nextval not null, 
    "EV_ID" numeric(12,0) not null,
    "PLV_ID" tinyint not null,
    "EV_LVL_ChangedAt" date not null,
    constraint "fk_A_EV_LVL_Event_Level_Posit" foreign key (
        "EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "fk_K_EV_LVL_Event_Level_Posit" foreign key (
        "PLV_ID"
    ) references knots."PLV_ProfessionalLevel"("PLV_ID") RELY,
    constraint "pkEV_LVL_Event_Level_Posit" primary key (
        "EV_LVL_ID"
    ) RELY,
    constraint "uqEV_LVL_Event_Level_Posit" unique (
        "EV_ID",
        "EV_LVL_ChangedAt",
        "PLV_ID"
    ) RELY
) CLUSTER BY ("EV_ID");
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Event_Level_Annex" (
    "EV_LVL_ID" int not null,
    "EV_LVL_PositedAt" datetime not null,
    "EV_LVL_Reliability" decimal(5,2) not null,
    "Metadata_EV_LVL" int not null,
    constraint "fkEV_LVL_Event_Level_Annex" foreign key (
        "EV_LVL_ID"
    ) references attributes."EV_LVL_Event_Level_Posit"("EV_LVL_ID") RELY,
    constraint "pkEV_LVL_Event_Level_Annex" primary key (
        "EV_LVL_ID",
        "EV_LVL_PositedAt"
    ) RELY
) CLUSTER BY ("EV_LVL_ID", "EV_LVL_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."ST_NAM_Stage_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Stage_Name_Posit" (
    "ST_NAM_ID" int default attributes."ST_NAM_Stage_Name_Posit_ID_SEQ".nextval not null, 
    "ST_ID" int not null,
    "ST_NAM_Stage_Name" varchar(42) not null,
    "ST_NAM_ChangedAt" datetime not null,
    constraint "fkST_NAM_Stage_Name_Posit" foreign key (
        "ST_ID"
    ) references anchors."ST_Stage"("ST_ID") RELY,
    constraint "pkST_NAM_Stage_Name_Posit" primary key (
        "ST_NAM_ID"
    ) RELY,
    constraint "uqST_NAM_Stage_Name_Posit" unique (
        "ST_ID",
        "ST_NAM_ChangedAt",
        "ST_NAM_Stage_Name"
    ) RELY
) CLUSTER BY ("ST_ID");
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Stage_Name_Annex" (
    "ST_NAM_ID" int not null,
    "ST_NAM_PositedAt" datetime not null,
    "ST_NAM_Reliability" decimal(5,2) not null,
    "Metadata_ST_NAM" int not null,
    constraint "fkST_NAM_Stage_Name_Annex" foreign key (
        "ST_NAM_ID"
    ) references attributes."ST_NAM_Stage_Name_Posit"("ST_NAM_ID") RELY,
    constraint "pkST_NAM_Stage_Name_Annex" primary key (
        "ST_NAM_ID",
        "ST_NAM_PositedAt"
    ) RELY
) CLUSTER BY ("ST_NAM_ID", "ST_NAM_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."ST_LOC_Stage_Location_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Stage_Location_Posit" (
    "ST_LOC_ID" int default attributes."ST_LOC_Stage_Location_Posit_ID_SEQ".nextval not null, 
    "ST_ID" int not null,
    "ST_LOC_Stage_Location" geography not null,
    "ST_LOC_Checksum" numeric(19,0) default hash("ST_LOC_Stage_Location"),
    constraint "fkST_LOC_Stage_Location_Posit" foreign key (
        "ST_ID"
    ) references anchors."ST_Stage"("ST_ID") RELY,
    constraint "pkST_LOC_Stage_Location_Posit" primary key (
        "ST_LOC_ID"
    ) RELY,
    constraint "uqST_LOC_Stage_Location_Posit" unique (
        "ST_ID",
        "ST_LOC_Checksum" 
    ) RELY
) CLUSTER BY ("ST_ID");
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Stage_Location_Annex" (
    "ST_LOC_ID" int not null,
    "ST_LOC_PositedAt" datetime not null,
    "ST_LOC_Reliability" decimal(5,2) not null,
    "Metadata_ST_LOC" int not null,
    constraint "fkST_LOC_Stage_Location_Annex" foreign key (
        "ST_LOC_ID"
    ) references attributes."ST_LOC_Stage_Location_Posit"("ST_LOC_ID") RELY,
    constraint "pkST_LOC_Stage_Location_Annex" primary key (
        "ST_LOC_ID",
        "ST_LOC_PositedAt"
    ) RELY
) CLUSTER BY ("ST_LOC_ID", "ST_LOC_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."ST_AVG_Stage_Average_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Stage_Average_Posit" (
    "ST_AVG_ID" int default attributes."ST_AVG_Stage_Average_Posit_ID_SEQ".nextval not null, 
    "ST_ID" int not null,
    "UTL_ID" tinyint not null,
    "ST_AVG_ChangedAt" datetime not null,
    constraint "fk_A_ST_AVG_Stage_Average_Posit" foreign key (
        "ST_ID"
    ) references anchors."ST_Stage"("ST_ID") RELY,
    constraint "fk_K_ST_AVG_Stage_Average_Posit" foreign key (
        "UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID") RELY,
    constraint "pkST_AVG_Stage_Average_Posit" primary key (
        "ST_AVG_ID"
    ) RELY,
    constraint "uqST_AVG_Stage_Average_Posit" unique (
        "ST_ID",
        "ST_AVG_ChangedAt",
        "UTL_ID"
    ) RELY
) CLUSTER BY ("ST_ID");
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Stage_Average_Annex" (
    "ST_AVG_ID" int not null,
    "ST_AVG_PositedAt" datetime not null,
    "ST_AVG_Reliability" decimal(5,2) not null,
    "Metadata_ST_AVG" int not null,
    constraint "fkST_AVG_Stage_Average_Annex" foreign key (
        "ST_AVG_ID"
    ) references attributes."ST_AVG_Stage_Average_Posit"("ST_AVG_ID") RELY,
    constraint "pkST_AVG_Stage_Average_Annex" primary key (
        "ST_AVG_ID",
        "ST_AVG_PositedAt"
    ) RELY
) CLUSTER BY ("ST_AVG_ID", "ST_AVG_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum_Posit" (
    "ST_MIN_ID" int default attributes."ST_MIN_Stage_Minimum_Posit_ID_SEQ".nextval not null, 
    "ST_ID" int not null,
    "UTL_ID" tinyint not null,
    constraint "fk_A_ST_MIN_Stage_Minimum_Posit" foreign key (
        "ST_ID"
    ) references anchors."ST_Stage"("ST_ID") RELY,
    constraint "fk_K_ST_MIN_Stage_Minimum_Posit" foreign key (
        "UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID") RELY,
    constraint "pkST_MIN_Stage_Minimum_Posit" primary key (
        "ST_MIN_ID"
    ) RELY,
    constraint "uqST_MIN_Stage_Minimum_Posit" unique (
        "ST_ID",
        "UTL_ID"
    ) RELY
) CLUSTER BY ("ST_ID");
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum_Annex" (
    "ST_MIN_ID" int not null,
    "ST_MIN_PositedAt" datetime not null,
    "ST_MIN_Reliability" decimal(5,2) not null,
    "Metadata_ST_MIN" int not null,
    constraint "fkST_MIN_Stage_Minimum_Annex" foreign key (
        "ST_MIN_ID"
    ) references attributes."ST_MIN_Stage_Minimum_Posit"("ST_MIN_ID") RELY,
    constraint "pkST_MIN_Stage_Minimum_Annex" primary key (
        "ST_MIN_ID",
        "ST_MIN_PositedAt"
    ) RELY
) CLUSTER BY ("ST_MIN_ID", "ST_MIN_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."AC_NAM_Actor_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Actor_Name_Posit" (
    "AC_NAM_ID" int default attributes."AC_NAM_Actor_Name_Posit_ID_SEQ".nextval not null, 
    "AC_ID" smallint not null,
    "AC_NAM_Actor_Name" varbinary(max) not null,
    "AC_NAM_ChangedAt" datetime not null,
    constraint "fkAC_NAM_Actor_Name_Posit" foreign key (
        "AC_ID"
    ) references anchors."AC_Actor"("AC_ID") RELY,
    constraint "pkAC_NAM_Actor_Name_Posit" primary key (
        "AC_NAM_ID"
    ) RELY,
    constraint "uqAC_NAM_Actor_Name_Posit" unique (
        "AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Actor_Name"
    ) RELY
) CLUSTER BY ("AC_ID");
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Actor_Name_Annex" (
    "AC_NAM_ID" int not null,
    "AC_NAM_PositedAt" datetime not null,
    "AC_NAM_Reliability" decimal(5,2) not null,
    "Metadata_AC_NAM" int not null,
    constraint "fkAC_NAM_Actor_Name_Annex" foreign key (
        "AC_NAM_ID"
    ) references attributes."AC_NAM_Actor_Name_Posit"("AC_NAM_ID") RELY,
    constraint "pkAC_NAM_Actor_Name_Annex" primary key (
        "AC_NAM_ID",
        "AC_NAM_PositedAt"
    ) RELY
) CLUSTER BY ("AC_NAM_ID", "AC_NAM_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."AC_GEN_Actor_Gender_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Actor_Gender_Posit" (
    "AC_GEN_ID" int default attributes."AC_GEN_Actor_Gender_Posit_ID_SEQ".nextval not null, 
    "AC_ID" smallint not null,
    "GEN_ID" number(1,0) not null,
    constraint "fk_A_AC_GEN_Actor_Gender_Posit" foreign key (
        "AC_ID"
    ) references anchors."AC_Actor"("AC_ID") RELY,
    constraint "fk_K_AC_GEN_Actor_Gender_Posit" foreign key (
        "GEN_ID"
    ) references knots."GEN_Gender"("GEN_ID") RELY,
    constraint "pkAC_GEN_Actor_Gender_Posit" primary key (
        "AC_GEN_ID"
    ) RELY,
    constraint "uqAC_GEN_Actor_Gender_Posit" unique (
        "AC_ID",
        "GEN_ID"
    ) RELY
) CLUSTER BY ("AC_ID");
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Actor_Gender_Annex" (
    "AC_GEN_ID" int not null,
    "AC_GEN_PositedAt" datetime not null,
    "AC_GEN_Reliability" decimal(5,2) not null,
    "Metadata_AC_GEN" int not null,
    constraint "fkAC_GEN_Actor_Gender_Annex" foreign key (
        "AC_GEN_ID"
    ) references attributes."AC_GEN_Actor_Gender_Posit"("AC_GEN_ID") RELY,
    constraint "pkAC_GEN_Actor_Gender_Annex" primary key (
        "AC_GEN_ID",
        "AC_GEN_PositedAt"
    ) RELY
) CLUSTER BY ("AC_GEN_ID", "AC_GEN_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel_Posit" (
    "AC_PLV_ID" int default attributes."AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ".nextval not null, 
    "AC_ID" smallint not null,
    "PLV_ID" tinyint not null,
    "AC_PLV_ChangedAt" datetime not null,
    constraint "fk_A_AC_PLV_Actor_ProfessionalLevel_Posit" foreign key (
        "AC_ID"
    ) references anchors."AC_Actor"("AC_ID") RELY,
    constraint "fk_K_AC_PLV_Actor_ProfessionalLevel_Posit" foreign key (
        "PLV_ID"
    ) references knots."PLV_ProfessionalLevel"("PLV_ID") RELY,
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Posit" primary key (
        "AC_PLV_ID"
    ) RELY,
    constraint "uqAC_PLV_Actor_ProfessionalLevel_Posit" unique (
        "AC_ID",
        "AC_PLV_ChangedAt",
        "PLV_ID"
    ) RELY
) CLUSTER BY ("AC_ID");
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel_Annex" (
    "AC_PLV_ID" int not null,
    "AC_PLV_PositedAt" datetime not null,
    "AC_PLV_Reliability" decimal(5,2) not null,
    "Metadata_AC_PLV" int not null,
    constraint "fkAC_PLV_Actor_ProfessionalLevel_Annex" foreign key (
        "AC_PLV_ID"
    ) references attributes."AC_PLV_Actor_ProfessionalLevel_Posit"("AC_PLV_ID") RELY,
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Annex" primary key (
        "AC_PLV_ID",
        "AC_PLV_PositedAt"
    ) RELY
) CLUSTER BY ("AC_PLV_ID", "AC_PLV_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."PR_NAM_Program_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Program_Name_Posit" (
    "PR_NAM_ID" int default attributes."PR_NAM_Program_Name_Posit_ID_SEQ".nextval not null, 
    "PR_ID" number(10,0) not null,
    "PR_NAM_Program_Name" varchar(42) not null,
    constraint "fkPR_NAM_Program_Name_Posit" foreign key (
        "PR_ID"
    ) references anchors."PR_Program"("PR_ID") RELY,
    constraint "pkPR_NAM_Program_Name_Posit" primary key (
        "PR_NAM_ID"
    ) RELY,
    constraint "uqPR_NAM_Program_Name_Posit" unique (
        "PR_ID",
        "PR_NAM_Program_Name"
    ) RELY
) CLUSTER BY ("PR_ID");
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Program_Name_Annex" (
    "PR_NAM_ID" int not null,
    "PR_NAM_PositedAt" datetime not null,
    "PR_NAM_Reliability" decimal(5,2) not null,
    "Metadata_PR_NAM" int not null,
    constraint "fkPR_NAM_Program_Name_Annex" foreign key (
        "PR_NAM_ID"
    ) references attributes."PR_NAM_Program_Name_Posit"("PR_NAM_ID") RELY,
    constraint "pkPR_NAM_Program_Name_Annex" primary key (
        "PR_NAM_ID",
        "PR_NAM_PositedAt"
    ) RELY
) CLUSTER BY ("PR_NAM_ID", "PR_NAM_PositedAt");
CREATE SEQUENCE IF NOT EXISTS attributes."PR_LEN_Program_Length_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Program_Length_Posit" (
    "PR_LEN_ID" int default attributes."PR_LEN_Program_Length_Posit_ID_SEQ".nextval not null, 
    "PR_ID" number(10,0) not null,
    "PR_LEN_Program_Length" time not null,
    "PR_LEN_ChangedAt" date not null,
    constraint "fkPR_LEN_Program_Length_Posit" foreign key (
        "PR_ID"
    ) references anchors."PR_Program"("PR_ID") RELY,
    constraint "pkPR_LEN_Program_Length_Posit" primary key (
        "PR_LEN_ID"
    ) RELY,
    constraint "uqPR_LEN_Program_Length_Posit" unique (
        "PR_ID",
        "PR_LEN_ChangedAt",
        "PR_LEN_Program_Length"
    ) RELY
) CLUSTER BY ("PR_ID");
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Program_Length_Annex" (
    "PR_LEN_ID" int not null,
    "PR_LEN_PositedAt" datetime not null,
    "PR_LEN_Reliability" decimal(5,2) not null,
    "Metadata_PR_LEN" int not null,
    constraint "fkPR_LEN_Program_Length_Annex" foreign key (
        "PR_LEN_ID"
    ) references attributes."PR_LEN_Program_Length_Posit"("PR_LEN_ID") RELY,
    constraint "pkPR_LEN_Program_Length_Annex" primary key (
        "PR_LEN_ID",
        "PR_LEN_PositedAt"
    ) RELY
) CLUSTER BY ("PR_LEN_ID", "PR_LEN_PositedAt");
