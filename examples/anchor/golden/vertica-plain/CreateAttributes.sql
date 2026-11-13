-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_DAT_Event_Date" (
    "EV_ID" integer not null,
    "EV_DAT_Event_Date" timestamp not null,
    constraint "fkEV_DAT_Event_Date" foreign key (
        "EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_DAT_Event_Date" primary key (
        "EV_ID"
    )
) ORDER BY "EV_ID" SEGMENTED BY MODULARHASH("EV_ID") ALL NODES;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_AUD_Event_Audience" (
    "EV_ID" integer not null,
    "EV_AUD_Event_Audience" integer not null,
    constraint "fkEV_AUD_Event_Audience" foreign key (
        "EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_AUD_Event_Audience" primary key (
        "EV_ID"
    )
) ORDER BY "EV_ID" SEGMENTED BY MODULARHASH("EV_ID") ALL NODES;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_REV_Event_Revenue" (
    "EV_ID" integer not null,
    "EV_REV_Event_Revenue" decimal(19,4) not null,
    constraint "fkEV_REV_Event_Revenue" foreign key (
        "EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_REV_Event_Revenue" primary key (
        "EV_ID"
    )
) ORDER BY "EV_ID" SEGMENTED BY MODULARHASH("EV_ID") ALL NODES;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_NAM_Stage_Name" (
    "ST_ID" integer not null,
    "ST_NAM_Stage_Name" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    constraint "fkST_NAM_Stage_Name" foreign key (
        "ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "pkST_NAM_Stage_Name" primary key (
        "ST_ID",
        "ST_NAM_ChangedAt"
    )
) ORDER BY "ST_ID", "ST_NAM_ChangedAt" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_LOC_Stage_Location" (
    "ST_ID" integer not null,
    "ST_LOC_Stage_Location" geography not null,
    "ST_LOC_Checksum" int default hash("ST_LOC_Stage_Location"),
    constraint "fkST_LOC_Stage_Location" foreign key (
        "ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "pkST_LOC_Stage_Location" primary key (
        "ST_ID"
    )
) ORDER BY "ST_ID" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_AVG_Stage_Average" (
    "ST_ID" integer not null,
    "UTL_ID" tinyint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    constraint "fk_A_ST_AVG_Stage_Average" foreign key (
        "ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_AVG_Stage_Average" foreign key (
        "UTL_ID"
    ) references public."UTL_Utilization"("UTL_ID"),
    constraint "pkST_AVG_Stage_Average" primary key (
        "ST_ID",
        "ST_AVG_ChangedAt"
    )
) ORDER BY "ST_ID", "ST_AVG_ChangedAt" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_MIN_Stage_Minimum" (
    "ST_ID" integer not null,
    "UTL_ID" tinyint not null,
    constraint "fk_A_ST_MIN_Stage_Minimum" foreign key (
        "ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_MIN_Stage_Minimum" foreign key (
        "UTL_ID"
    ) references public."UTL_Utilization"("UTL_ID"),
    constraint "pkST_MIN_Stage_Minimum" primary key (
        "ST_ID"
    )
) ORDER BY "ST_ID" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_NAM_Actor_Name" (
    "AC_ID" integer not null,
    "AC_NAM_Actor_Name" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    constraint "fkAC_NAM_Actor_Name" foreign key (
        "AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "pkAC_NAM_Actor_Name" primary key (
        "AC_ID",
        "AC_NAM_ChangedAt"
    )
) ORDER BY "AC_ID", "AC_NAM_ChangedAt" SEGMENTED BY MODULARHASH("AC_ID") ALL NODES;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_GEN_Actor_Gender" (
    "AC_ID" integer not null,
    "GEN_ID" tinyint not null,
    constraint "fk_A_AC_GEN_Actor_Gender" foreign key (
        "AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_GEN_Actor_Gender" foreign key (
        "GEN_ID"
    ) references public."GEN_Gender"("GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender" primary key (
        "AC_ID"
    )
) ORDER BY "AC_ID" SEGMENTED BY MODULARHASH("AC_ID") ALL NODES;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel" (
    "AC_ID" integer not null,
    "PLV_ID" tinyint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    constraint "fk_A_AC_PLV_Actor_ProfessionalLevel" foreign key (
        "AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_PLV_Actor_ProfessionalLevel" foreign key (
        "PLV_ID"
    ) references public."PLV_ProfessionalLevel"("PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel" primary key (
        "AC_ID",
        "AC_PLV_ChangedAt"
    )
) ORDER BY "AC_ID", "AC_PLV_ChangedAt" SEGMENTED BY MODULARHASH("AC_ID") ALL NODES;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PR_NAM_Program_Name" (
    "PR_ID" integer not null,
    "PR_NAM_Program_Name" varchar(42) not null,
    constraint "fkPR_NAM_Program_Name" foreign key (
        "PR_ID"
    ) references public."PR_Program"("PR_ID"),
    constraint "pkPR_NAM_Program_Name" primary key (
        "PR_ID"
    )
) ORDER BY "PR_ID" SEGMENTED BY MODULARHASH("PR_ID") ALL NODES;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PR_LEN_Program_Length" (
    "PR_ID" integer not null,
    "PR_LEN_Program_Length" time not null,
    "PR_LEN_ChangedAt" date not null,
    constraint "fkPR_LEN_Program_Length" foreign key (
        "PR_ID"
    ) references public."PR_Program"("PR_ID"),
    constraint "pkPR_LEN_Program_Length" primary key (
        "PR_ID",
        "PR_LEN_ChangedAt"
    )
) ORDER BY "PR_ID", "PR_LEN_ChangedAt" SEGMENTED BY MODULARHASH("PR_ID") ALL NODES;
