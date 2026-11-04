-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS public."EV_DAT_Event_Date_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_DAT_Event_Date_Posit" (
    "EV_DAT_ID" integer default nextval('public."EV_DAT_Event_Date_Posit_ID_SEQ"') not null, 
    "EV_DAT_EV_ID" integer not null,
    "EV_DAT_Event_Date" timestamp not null,
    constraint "fkEV_DAT_Event_Date_Posit" foreign key (
        "EV_DAT_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_DAT_Event_Date_Posit" primary key (
        "EV_DAT_ID"
    ),
    constraint "uqEV_DAT_Event_Date_Posit" unique (
        "EV_DAT_EV_ID",
        "EV_DAT_Event_Date"
    )
);
CREATE TABLE IF NOT EXISTS public."EV_DAT_Event_Date_Annex" (
    "EV_DAT_ID" integer not null,
    "EV_DAT_PositedAt" timestamp not null,
    "EV_DAT_Reliability" decimal(5,2) not null,
    "Metadata_EV_DAT" integer not null,
    constraint "fkEV_DAT_Event_Date_Annex" foreign key (
        "EV_DAT_ID"
    ) references public."EV_DAT_Event_Date_Posit"("EV_DAT_ID"),
    constraint "pkEV_DAT_Event_Date_Annex" primary key (
        "EV_DAT_ID",
        "EV_DAT_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."EV_AUD_Event_Audience_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_AUD_Event_Audience_Posit" (
    "EV_AUD_ID" integer default nextval('public."EV_AUD_Event_Audience_Posit_ID_SEQ"') not null, 
    "EV_AUD_EV_ID" integer not null,
    "EV_AUD_Event_Audience" integer not null,
    constraint "fkEV_AUD_Event_Audience_Posit" foreign key (
        "EV_AUD_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_AUD_Event_Audience_Posit" primary key (
        "EV_AUD_ID"
    ),
    constraint "uqEV_AUD_Event_Audience_Posit" unique (
        "EV_AUD_EV_ID",
        "EV_AUD_Event_Audience"
    )
);
CREATE TABLE IF NOT EXISTS public."EV_AUD_Event_Audience_Annex" (
    "EV_AUD_ID" integer not null,
    "EV_AUD_PositedAt" timestamp not null,
    "EV_AUD_Reliability" decimal(5,2) not null,
    "Metadata_EV_AUD" integer not null,
    constraint "fkEV_AUD_Event_Audience_Annex" foreign key (
        "EV_AUD_ID"
    ) references public."EV_AUD_Event_Audience_Posit"("EV_AUD_ID"),
    constraint "pkEV_AUD_Event_Audience_Annex" primary key (
        "EV_AUD_ID",
        "EV_AUD_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."EV_REV_Event_Revenue_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_REV_Event_Revenue_Posit" (
    "EV_REV_ID" integer default nextval('public."EV_REV_Event_Revenue_Posit_ID_SEQ"') not null, 
    "EV_REV_EV_ID" integer not null,
    "EV_REV_Event_Revenue" decimal(19,4) not null,
    constraint "fkEV_REV_Event_Revenue_Posit" foreign key (
        "EV_REV_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_REV_Event_Revenue_Posit" primary key (
        "EV_REV_ID"
    ),
    constraint "uqEV_REV_Event_Revenue_Posit" unique (
        "EV_REV_EV_ID",
        "EV_REV_Event_Revenue"
    )
);
CREATE TABLE IF NOT EXISTS public."EV_REV_Event_Revenue_Annex" (
    "EV_REV_ID" integer not null,
    "EV_REV_PositedAt" timestamp not null,
    "EV_REV_Reliability" decimal(5,2) not null,
    "Metadata_EV_REV" integer not null,
    constraint "fkEV_REV_Event_Revenue_Annex" foreign key (
        "EV_REV_ID"
    ) references public."EV_REV_Event_Revenue_Posit"("EV_REV_ID"),
    constraint "pkEV_REV_Event_Revenue_Annex" primary key (
        "EV_REV_ID",
        "EV_REV_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."ST_NAM_Stage_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_NAM_Stage_Name_Posit" (
    "ST_NAM_ID" integer default nextval('public."ST_NAM_Stage_Name_Posit_ID_SEQ"') not null, 
    "ST_NAM_ST_ID" integer not null,
    "ST_NAM_Stage_Name" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    constraint "fkST_NAM_Stage_Name_Posit" foreign key (
        "ST_NAM_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "pkST_NAM_Stage_Name_Posit" primary key (
        "ST_NAM_ID"
    ),
    constraint "uqST_NAM_Stage_Name_Posit" unique (
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt",
        "ST_NAM_Stage_Name"
    )
);
CREATE TABLE IF NOT EXISTS public."ST_NAM_Stage_Name_Annex" (
    "ST_NAM_ID" integer not null,
    "ST_NAM_PositedAt" timestamp not null,
    "ST_NAM_Reliability" decimal(5,2) not null,
    "Metadata_ST_NAM" integer not null,
    constraint "fkST_NAM_Stage_Name_Annex" foreign key (
        "ST_NAM_ID"
    ) references public."ST_NAM_Stage_Name_Posit"("ST_NAM_ID"),
    constraint "pkST_NAM_Stage_Name_Annex" primary key (
        "ST_NAM_ID",
        "ST_NAM_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."ST_LOC_Stage_Location_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_LOC_Stage_Location_Posit" (
    "ST_LOC_ID" integer default nextval('public."ST_LOC_Stage_Location_Posit_ID_SEQ"') not null, 
    "ST_LOC_ST_ID" integer not null,
    "ST_LOC_Stage_Location" geography not null,
    "ST_LOC_Checksum" bytea generated always as (decode(md5("ST_LOC_Stage_Location"::text), 'hex')) stored,
    constraint "fkST_LOC_Stage_Location_Posit" foreign key (
        "ST_LOC_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "pkST_LOC_Stage_Location_Posit" primary key (
        "ST_LOC_ID"
    ),
    constraint "uqST_LOC_Stage_Location_Posit" unique (
        "ST_LOC_ST_ID",
        "ST_LOC_Checksum" 
    )
);
CREATE TABLE IF NOT EXISTS public."ST_LOC_Stage_Location_Annex" (
    "ST_LOC_ID" integer not null,
    "ST_LOC_PositedAt" timestamp not null,
    "ST_LOC_Reliability" decimal(5,2) not null,
    "Metadata_ST_LOC" integer not null,
    constraint "fkST_LOC_Stage_Location_Annex" foreign key (
        "ST_LOC_ID"
    ) references public."ST_LOC_Stage_Location_Posit"("ST_LOC_ID"),
    constraint "pkST_LOC_Stage_Location_Annex" primary key (
        "ST_LOC_ID",
        "ST_LOC_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."ST_AVG_Stage_Average_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_AVG_Stage_Average_Posit" (
    "ST_AVG_ID" integer default nextval('public."ST_AVG_Stage_Average_Posit_ID_SEQ"') not null, 
    "ST_AVG_ST_ID" integer not null,
    "ST_AVG_UTL_ID" smallint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    constraint "fk_A_ST_AVG_Stage_Average_Posit" foreign key (
        "ST_AVG_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_AVG_Stage_Average_Posit" foreign key (
        "ST_AVG_UTL_ID"
    ) references public."UTL_Utilization"("UTL_ID"),
    constraint "pkST_AVG_Stage_Average_Posit" primary key (
        "ST_AVG_ID"
    ),
    constraint "uqST_AVG_Stage_Average_Posit" unique (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt",
        "ST_AVG_UTL_ID"
    )
);
CREATE TABLE IF NOT EXISTS public."ST_AVG_Stage_Average_Annex" (
    "ST_AVG_ID" integer not null,
    "ST_AVG_PositedAt" timestamp not null,
    "ST_AVG_Reliability" decimal(5,2) not null,
    "Metadata_ST_AVG" integer not null,
    constraint "fkST_AVG_Stage_Average_Annex" foreign key (
        "ST_AVG_ID"
    ) references public."ST_AVG_Stage_Average_Posit"("ST_AVG_ID"),
    constraint "pkST_AVG_Stage_Average_Annex" primary key (
        "ST_AVG_ID",
        "ST_AVG_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."ST_MIN_Stage_Minimum_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_MIN_Stage_Minimum_Posit" (
    "ST_MIN_ID" integer default nextval('public."ST_MIN_Stage_Minimum_Posit_ID_SEQ"') not null, 
    "ST_MIN_ST_ID" integer not null,
    "ST_MIN_UTL_ID" smallint not null,
    constraint "fk_A_ST_MIN_Stage_Minimum_Posit" foreign key (
        "ST_MIN_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_MIN_Stage_Minimum_Posit" foreign key (
        "ST_MIN_UTL_ID"
    ) references public."UTL_Utilization"("UTL_ID"),
    constraint "pkST_MIN_Stage_Minimum_Posit" primary key (
        "ST_MIN_ID"
    ),
    constraint "uqST_MIN_Stage_Minimum_Posit" unique (
        "ST_MIN_ST_ID",
        "ST_MIN_UTL_ID"
    )
);
CREATE TABLE IF NOT EXISTS public."ST_MIN_Stage_Minimum_Annex" (
    "ST_MIN_ID" integer not null,
    "ST_MIN_PositedAt" timestamp not null,
    "ST_MIN_Reliability" decimal(5,2) not null,
    "Metadata_ST_MIN" integer not null,
    constraint "fkST_MIN_Stage_Minimum_Annex" foreign key (
        "ST_MIN_ID"
    ) references public."ST_MIN_Stage_Minimum_Posit"("ST_MIN_ID"),
    constraint "pkST_MIN_Stage_Minimum_Annex" primary key (
        "ST_MIN_ID",
        "ST_MIN_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."AC_NAM_Actor_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_NAM_Actor_Name_Posit" (
    "AC_NAM_ID" integer default nextval('public."AC_NAM_Actor_Name_Posit_ID_SEQ"') not null, 
    "AC_NAM_AC_ID" integer not null,
    "AC_NAM_Actor_Name" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    constraint "fkAC_NAM_Actor_Name_Posit" foreign key (
        "AC_NAM_AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "pkAC_NAM_Actor_Name_Posit" primary key (
        "AC_NAM_ID"
    ),
    constraint "uqAC_NAM_Actor_Name_Posit" unique (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Actor_Name"
    )
);
CREATE TABLE IF NOT EXISTS public."AC_NAM_Actor_Name_Annex" (
    "AC_NAM_ID" integer not null,
    "AC_NAM_PositedAt" timestamp not null,
    "AC_NAM_Reliability" decimal(5,2) not null,
    "Metadata_AC_NAM" integer not null,
    constraint "fkAC_NAM_Actor_Name_Annex" foreign key (
        "AC_NAM_ID"
    ) references public."AC_NAM_Actor_Name_Posit"("AC_NAM_ID"),
    constraint "pkAC_NAM_Actor_Name_Annex" primary key (
        "AC_NAM_ID",
        "AC_NAM_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."AC_GEN_Actor_Gender_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_GEN_Actor_Gender_Posit" (
    "AC_GEN_ID" integer default nextval('public."AC_GEN_Actor_Gender_Posit_ID_SEQ"') not null, 
    "AC_GEN_AC_ID" integer not null,
    "AC_GEN_GEN_ID" smallint not null,
    constraint "fk_A_AC_GEN_Actor_Gender_Posit" foreign key (
        "AC_GEN_AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_GEN_Actor_Gender_Posit" foreign key (
        "AC_GEN_GEN_ID"
    ) references public."GEN_Gender"("GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender_Posit" primary key (
        "AC_GEN_ID"
    ),
    constraint "uqAC_GEN_Actor_Gender_Posit" unique (
        "AC_GEN_AC_ID",
        "AC_GEN_GEN_ID"
    )
);
CREATE TABLE IF NOT EXISTS public."AC_GEN_Actor_Gender_Annex" (
    "AC_GEN_ID" integer not null,
    "AC_GEN_PositedAt" timestamp not null,
    "AC_GEN_Reliability" decimal(5,2) not null,
    "Metadata_AC_GEN" integer not null,
    constraint "fkAC_GEN_Actor_Gender_Annex" foreign key (
        "AC_GEN_ID"
    ) references public."AC_GEN_Actor_Gender_Posit"("AC_GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender_Annex" primary key (
        "AC_GEN_ID",
        "AC_GEN_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel_Posit" (
    "AC_PLV_ID" integer default nextval('public."AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ"') not null, 
    "AC_PLV_AC_ID" integer not null,
    "AC_PLV_PLV_ID" smallint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    constraint "fk_A_AC_PLV_Actor_ProfessionalLevel_Posit" foreign key (
        "AC_PLV_AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_PLV_Actor_ProfessionalLevel_Posit" foreign key (
        "AC_PLV_PLV_ID"
    ) references public."PLV_ProfessionalLevel"("PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Posit" primary key (
        "AC_PLV_ID"
    ),
    constraint "uqAC_PLV_Actor_ProfessionalLevel_Posit" unique (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt",
        "AC_PLV_PLV_ID"
    )
);
CREATE TABLE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel_Annex" (
    "AC_PLV_ID" integer not null,
    "AC_PLV_PositedAt" timestamp not null,
    "AC_PLV_Reliability" decimal(5,2) not null,
    "Metadata_AC_PLV" integer not null,
    constraint "fkAC_PLV_Actor_ProfessionalLevel_Annex" foreign key (
        "AC_PLV_ID"
    ) references public."AC_PLV_Actor_ProfessionalLevel_Posit"("AC_PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Annex" primary key (
        "AC_PLV_ID",
        "AC_PLV_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."PR_NAM_Program_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PR_NAM_Program_Name_Posit" (
    "PR_NAM_ID" integer default nextval('public."PR_NAM_Program_Name_Posit_ID_SEQ"') not null, 
    "PR_NAM_PR_ID" integer not null,
    "PR_NAM_Program_Name" varchar(42) not null,
    constraint "fkPR_NAM_Program_Name_Posit" foreign key (
        "PR_NAM_PR_ID"
    ) references public."PR_Program"("PR_ID"),
    constraint "pkPR_NAM_Program_Name_Posit" primary key (
        "PR_NAM_ID"
    ),
    constraint "uqPR_NAM_Program_Name_Posit" unique (
        "PR_NAM_PR_ID",
        "PR_NAM_Program_Name"
    )
);
CREATE TABLE IF NOT EXISTS public."PR_NAM_Program_Name_Annex" (
    "PR_NAM_ID" integer not null,
    "PR_NAM_PositedAt" timestamp not null,
    "PR_NAM_Reliability" decimal(5,2) not null,
    "Metadata_PR_NAM" integer not null,
    constraint "fkPR_NAM_Program_Name_Annex" foreign key (
        "PR_NAM_ID"
    ) references public."PR_NAM_Program_Name_Posit"("PR_NAM_ID"),
    constraint "pkPR_NAM_Program_Name_Annex" primary key (
        "PR_NAM_ID",
        "PR_NAM_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."PR_LEN_Program_Length_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PR_LEN_Program_Length_Posit" (
    "PR_LEN_ID" integer default nextval('public."PR_LEN_Program_Length_Posit_ID_SEQ"') not null, 
    "PR_LEN_PR_ID" integer not null,
    "PR_LEN_Program_Length" time not null,
    "PR_LEN_ChangedAt" date not null,
    constraint "fkPR_LEN_Program_Length_Posit" foreign key (
        "PR_LEN_PR_ID"
    ) references public."PR_Program"("PR_ID"),
    constraint "pkPR_LEN_Program_Length_Posit" primary key (
        "PR_LEN_ID"
    ),
    constraint "uqPR_LEN_Program_Length_Posit" unique (
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt",
        "PR_LEN_Program_Length"
    )
);
CREATE TABLE IF NOT EXISTS public."PR_LEN_Program_Length_Annex" (
    "PR_LEN_ID" integer not null,
    "PR_LEN_PositedAt" timestamp not null,
    "PR_LEN_Reliability" decimal(5,2) not null,
    "Metadata_PR_LEN" integer not null,
    constraint "fkPR_LEN_Program_Length_Annex" foreign key (
        "PR_LEN_ID"
    ) references public."PR_LEN_Program_Length_Posit"("PR_LEN_ID"),
    constraint "pkPR_LEN_Program_Length_Annex" primary key (
        "PR_LEN_ID",
        "PR_LEN_PositedAt"
    )
);
