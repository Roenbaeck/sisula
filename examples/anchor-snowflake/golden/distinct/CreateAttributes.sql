-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Event_Date" (
    "EV_DAT_EV_ID" numeric(12,0) not null,
    "EV_DAT_Event_Date" datetime not null,
    "Metadata_EV_DAT" int not null,
    constraint "fkEV_DAT_Event_Date" foreign key (
        "EV_DAT_EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "pkEV_DAT_Event_Date" primary key (
        "EV_DAT_EV_ID"
    ) RELY
) CLUSTER BY ("EV_DAT_EV_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Event_Audience" (
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_Event_Audience" int not null,
    "Metadata_EV_AUD" int not null,
    constraint "fkEV_AUD_Event_Audience" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "pkEV_AUD_Event_Audience" primary key (
        "EV_AUD_EV_ID"
    ) RELY
) CLUSTER BY ("EV_AUD_EV_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Event_Revenue" (
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_Event_Revenue" number(19,4) not null,
    "Metadata_EV_REV" int not null,
    constraint "fkEV_REV_Event_Revenue" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "pkEV_REV_Event_Revenue" primary key (
        "EV_REV_EV_ID"
    ) RELY
) CLUSTER BY ("EV_REV_EV_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Event_Status table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Event_Status" (
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_Event_Status" varchar(20) not null,
    "EV_STA_ChangedAt" datetime not null,
    "Metadata_EV_STA" int not null,
    constraint "fkEV_STA_Event_Status" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "pkEV_STA_Event_Status" primary key (
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt"
    ) RELY
) CLUSTER BY ("EV_STA_EV_ID");
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Event_Utilization" (
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" tinyint not null,
    "Metadata_EV_UTL" int not null,
    constraint "fk_A_EV_UTL_Event_Utilization" foreign key (
        "EV_UTL_EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "fk_K_EV_UTL_Event_Utilization" foreign key (
        "EV_UTL_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID") RELY,
    constraint "pkEV_UTL_Event_Utilization" primary key (
        "EV_UTL_EV_ID"
    ) RELY
) CLUSTER BY ("EV_UTL_EV_ID");
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Event_Level table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Event_Level" (
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" tinyint not null,
    "EV_LVL_ChangedAt" date not null,
    "Metadata_EV_LVL" int not null,
    constraint "fk_A_EV_LVL_Event_Level" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Event"("EV_ID") RELY,
    constraint "fk_K_EV_LVL_Event_Level" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_ProfessionalLevel"("PLV_ID") RELY,
    constraint "pkEV_LVL_Event_Level" primary key (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt"
    ) RELY
) CLUSTER BY ("EV_LVL_EV_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Stage_Name" (
    "ST_NAM_ST_ID" int not null,
    "ST_NAM_Stage_Name" varchar(42) not null,
    "ST_NAM_ChangedAt" datetime not null,
    "Metadata_ST_NAM" int not null,
    constraint "fkST_NAM_Stage_Name" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Stage"("ST_ID") RELY,
    constraint "pkST_NAM_Stage_Name" primary key (
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt"
    ) RELY
) CLUSTER BY ("ST_NAM_ST_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Stage_Location" (
    "ST_LOC_ST_ID" int not null,
    "ST_LOC_Stage_Location" geography not null,
    "ST_LOC_Checksum" numeric(19,0) default hash("ST_LOC_Stage_Location"),
    "Metadata_ST_LOC" int not null,
    constraint "fkST_LOC_Stage_Location" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Stage"("ST_ID") RELY,
    constraint "pkST_LOC_Stage_Location" primary key (
        "ST_LOC_ST_ID"
    ) RELY
) CLUSTER BY ("ST_LOC_ST_ID");
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Stage_Average" (
    "ST_AVG_ST_ID" int not null,
    "ST_AVG_UTL_ID" tinyint not null,
    "ST_AVG_ChangedAt" datetime not null,
    "Metadata_ST_AVG" int not null,
    constraint "fk_A_ST_AVG_Stage_Average" foreign key (
        "ST_AVG_ST_ID"
    ) references anchors."ST_Stage"("ST_ID") RELY,
    constraint "fk_K_ST_AVG_Stage_Average" foreign key (
        "ST_AVG_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID") RELY,
    constraint "pkST_AVG_Stage_Average" primary key (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt"
    ) RELY
) CLUSTER BY ("ST_AVG_ST_ID");
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum" (
    "ST_MIN_ST_ID" int not null,
    "ST_MIN_UTL_ID" tinyint not null,
    "Metadata_ST_MIN" int not null,
    constraint "fk_A_ST_MIN_Stage_Minimum" foreign key (
        "ST_MIN_ST_ID"
    ) references anchors."ST_Stage"("ST_ID") RELY,
    constraint "fk_K_ST_MIN_Stage_Minimum" foreign key (
        "ST_MIN_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID") RELY,
    constraint "pkST_MIN_Stage_Minimum" primary key (
        "ST_MIN_ST_ID"
    ) RELY
) CLUSTER BY ("ST_MIN_ST_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Actor_Name" (
    "AC_NAM_AC_ID" smallint not null,
    "AC_NAM_Actor_Name" varbinary(max) not null,
    "AC_NAM_ChangedAt" datetime not null,
    "Metadata_AC_NAM" int not null,
    constraint "fkAC_NAM_Actor_Name" foreign key (
        "AC_NAM_AC_ID"
    ) references anchors."AC_Actor"("AC_ID") RELY,
    constraint "pkAC_NAM_Actor_Name" primary key (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt"
    ) RELY
) CLUSTER BY ("AC_NAM_AC_ID");
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Actor_Gender" (
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" number(1,0) not null,
    "Metadata_AC_GEN" int not null,
    constraint "fk_A_AC_GEN_Actor_Gender" foreign key (
        "AC_GEN_AC_ID"
    ) references anchors."AC_Actor"("AC_ID") RELY,
    constraint "fk_K_AC_GEN_Actor_Gender" foreign key (
        "AC_GEN_GEN_ID"
    ) references knots."GEN_Gender"("GEN_ID") RELY,
    constraint "pkAC_GEN_Actor_Gender" primary key (
        "AC_GEN_AC_ID"
    ) RELY
) CLUSTER BY ("AC_GEN_AC_ID");
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel" (
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" tinyint not null,
    "AC_PLV_ChangedAt" datetime not null,
    "Metadata_AC_PLV" int not null,
    constraint "fk_A_AC_PLV_Actor_ProfessionalLevel" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Actor"("AC_ID") RELY,
    constraint "fk_K_AC_PLV_Actor_ProfessionalLevel" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_ProfessionalLevel"("PLV_ID") RELY,
    constraint "pkAC_PLV_Actor_ProfessionalLevel" primary key (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt"
    ) RELY
) CLUSTER BY ("AC_PLV_AC_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Program_Name" (
    "PR_NAM_PR_ID" number(10,0) not null,
    "PR_NAM_Program_Name" varchar(42) not null,
    "Metadata_PR_NAM" int not null,
    constraint "fkPR_NAM_Program_Name" foreign key (
        "PR_NAM_PR_ID"
    ) references anchors."PR_Program"("PR_ID") RELY,
    constraint "pkPR_NAM_Program_Name" primary key (
        "PR_NAM_PR_ID"
    ) RELY
) CLUSTER BY ("PR_NAM_PR_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Program_Length" (
    "PR_LEN_PR_ID" number(10,0) not null,
    "PR_LEN_Program_Length" time not null,
    "PR_LEN_ChangedAt" date not null,
    "Metadata_PR_LEN" int not null,
    constraint "fkPR_LEN_Program_Length" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Program"("PR_ID") RELY,
    constraint "pkPR_LEN_Program_Length" primary key (
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt"
    ) RELY
) CLUSTER BY ("PR_LEN_PR_ID");
