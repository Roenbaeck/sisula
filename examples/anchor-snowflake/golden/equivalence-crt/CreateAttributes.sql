-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_DAT_Event_Date_Posit (
    EV_DAT_ID int IDENTITY(1,1) not null, 
    EV_DAT_EV_ID int not null,
    EV_DAT_Event_Date datetime not null,
    constraint fkEV_DAT_Event_Date_Posit foreign key (
        EV_DAT_EV_ID
    ) references public.EV_Event(EV_ID) RELY,
    constraint pkEV_DAT_Event_Date_Posit primary key (
        EV_DAT_ID
    ) RELY,
    constraint uqEV_DAT_Event_Date_Posit unique (
        EV_DAT_EV_ID,
        EV_DAT_Event_Date
    ) RELY
) CLUSTER BY (EV_DAT_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Annex table (of EV_DAT_Event_Date_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_DAT_Event_Date_Annex (
    EV_DAT_ID int not null,
    EV_DAT_PositedAt datetime not null,
    EV_DAT_Positor tinyint not null,
    EV_DAT_Reliability decimal(5,2) not null,
    EV_DAT_Assertion string default (
        case
            when EV_DAT_Reliability > 0 then '+'
            when EV_DAT_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_EV_DAT int not null,
    constraint fkEV_DAT_Event_Date_Annex foreign key (
        EV_DAT_ID
    ) references public.EV_DAT_Event_Date_Posit(EV_DAT_ID) RELY,
    constraint pkEV_DAT_Event_Date_Annex primary key (
        EV_DAT_ID,
        EV_DAT_Positor,
        EV_DAT_PositedAt
    ) RELY
) CLUSTER BY (EV_DAT_ID, EV_DAT_Positor, EV_DAT_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_AUD_Event_Audience_Posit (
    EV_AUD_ID int IDENTITY(1,1) not null, 
    EV_AUD_EV_ID int not null,
    EV_AUD_Event_Audience int not null,
    constraint fkEV_AUD_Event_Audience_Posit foreign key (
        EV_AUD_EV_ID
    ) references public.EV_Event(EV_ID) RELY,
    constraint pkEV_AUD_Event_Audience_Posit primary key (
        EV_AUD_ID
    ) RELY,
    constraint uqEV_AUD_Event_Audience_Posit unique (
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    ) RELY
) CLUSTER BY (EV_AUD_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Annex table (of EV_AUD_Event_Audience_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_AUD_Event_Audience_Annex (
    EV_AUD_ID int not null,
    EV_AUD_PositedAt datetime not null,
    EV_AUD_Positor tinyint not null,
    EV_AUD_Reliability decimal(5,2) not null,
    EV_AUD_Assertion string default (
        case
            when EV_AUD_Reliability > 0 then '+'
            when EV_AUD_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_EV_AUD int not null,
    constraint fkEV_AUD_Event_Audience_Annex foreign key (
        EV_AUD_ID
    ) references public.EV_AUD_Event_Audience_Posit(EV_AUD_ID) RELY,
    constraint pkEV_AUD_Event_Audience_Annex primary key (
        EV_AUD_ID,
        EV_AUD_Positor,
        EV_AUD_PositedAt
    ) RELY
) CLUSTER BY (EV_AUD_ID, EV_AUD_Positor, EV_AUD_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_REV_Event_Revenue_Posit (
    EV_REV_ID int IDENTITY(1,1) not null, 
    EV_REV_EV_ID int not null,
    EV_REV_Event_Revenue number(19,4) not null,
    constraint fkEV_REV_Event_Revenue_Posit foreign key (
        EV_REV_EV_ID
    ) references public.EV_Event(EV_ID) RELY,
    constraint pkEV_REV_Event_Revenue_Posit primary key (
        EV_REV_ID
    ) RELY,
    constraint uqEV_REV_Event_Revenue_Posit unique (
        EV_REV_EV_ID,
        EV_REV_Event_Revenue
    ) RELY
) CLUSTER BY (EV_REV_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Annex table (of EV_REV_Event_Revenue_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_REV_Event_Revenue_Annex (
    EV_REV_ID int not null,
    EV_REV_PositedAt datetime not null,
    EV_REV_Positor tinyint not null,
    EV_REV_Reliability decimal(5,2) not null,
    EV_REV_Assertion string default (
        case
            when EV_REV_Reliability > 0 then '+'
            when EV_REV_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_EV_REV int not null,
    constraint fkEV_REV_Event_Revenue_Annex foreign key (
        EV_REV_ID
    ) references public.EV_REV_Event_Revenue_Posit(EV_REV_ID) RELY,
    constraint pkEV_REV_Event_Revenue_Annex primary key (
        EV_REV_ID,
        EV_REV_Positor,
        EV_REV_PositedAt
    ) RELY
) CLUSTER BY (EV_REV_ID, EV_REV_Positor, EV_REV_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_NAM_Stage_Name_Posit (
    ST_NAM_ID int IDENTITY(1,1) not null, 
    ST_NAM_ST_ID int not null,
    ST_NAM_Stage_Name varchar(42) not null,
    ST_NAM_Checksum numeric(19,0) default hash(ST_NAM_Stage_Name),
    ST_NAM_ChangedAt datetime not null,
    constraint fkST_NAM_Stage_Name_Posit foreign key (
        ST_NAM_ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint pkST_NAM_Stage_Name_Posit primary key (
        ST_NAM_ID
    ) RELY,
    constraint uqST_NAM_Stage_Name_Posit unique (
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Checksum 
    ) RELY
) CLUSTER BY (ST_NAM_ST_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Annex table (of ST_NAM_Stage_Name_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_NAM_Stage_Name_Annex (
    ST_NAM_ID int not null,
    ST_NAM_PositedAt datetime not null,
    ST_NAM_Positor tinyint not null,
    ST_NAM_Reliability decimal(5,2) not null,
    ST_NAM_Assertion string default (
        case
            when ST_NAM_Reliability > 0 then '+'
            when ST_NAM_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_ST_NAM int not null,
    constraint fkST_NAM_Stage_Name_Annex foreign key (
        ST_NAM_ID
    ) references public.ST_NAM_Stage_Name_Posit(ST_NAM_ID) RELY,
    constraint pkST_NAM_Stage_Name_Annex primary key (
        ST_NAM_ID,
        ST_NAM_Positor,
        ST_NAM_PositedAt
    ) RELY
) CLUSTER BY (ST_NAM_ID, ST_NAM_Positor, ST_NAM_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_LOC_Stage_Location_Posit (
    ST_LOC_ID int IDENTITY(1,1) not null, 
    ST_LOC_ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum numeric(19,0) default hash(ST_LOC_Stage_Location),
    constraint fkST_LOC_Stage_Location_Posit foreign key (
        ST_LOC_ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint pkST_LOC_Stage_Location_Posit primary key (
        ST_LOC_ID
    ) RELY,
    constraint uqST_LOC_Stage_Location_Posit unique (
        ST_LOC_ST_ID,
        ST_LOC_Checksum 
    ) RELY
) CLUSTER BY (ST_LOC_ST_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Annex table (of ST_LOC_Stage_Location_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_LOC_Stage_Location_Annex (
    ST_LOC_ID int not null,
    ST_LOC_PositedAt datetime not null,
    ST_LOC_Positor tinyint not null,
    ST_LOC_Reliability decimal(5,2) not null,
    ST_LOC_Assertion string default (
        case
            when ST_LOC_Reliability > 0 then '+'
            when ST_LOC_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_ST_LOC int not null,
    constraint fkST_LOC_Stage_Location_Annex foreign key (
        ST_LOC_ID
    ) references public.ST_LOC_Stage_Location_Posit(ST_LOC_ID) RELY,
    constraint pkST_LOC_Stage_Location_Annex primary key (
        ST_LOC_ID,
        ST_LOC_Positor,
        ST_LOC_PositedAt
    ) RELY
) CLUSTER BY (ST_LOC_ID, ST_LOC_Positor, ST_LOC_PositedAt);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_AVG_Stage_Average_Posit (
    ST_AVG_ID int IDENTITY(1,1) not null, 
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime not null,
    constraint fk_A_ST_AVG_Stage_Average_Posit foreign key (
        ST_AVG_ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint fk_K_ST_AVG_Stage_Average_Posit foreign key (
        ST_AVG_UTL_ID
    ) references public.UTL_Utilization(UTL_ID) RELY,
    constraint pkST_AVG_Stage_Average_Posit primary key (
        ST_AVG_ID
    ) RELY,
    constraint uqST_AVG_Stage_Average_Posit unique (
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    ) RELY
) CLUSTER BY (ST_AVG_ST_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Annex table (of ST_AVG_Stage_Average_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_AVG_Stage_Average_Annex (
    ST_AVG_ID int not null,
    ST_AVG_PositedAt datetime not null,
    ST_AVG_Positor tinyint not null,
    ST_AVG_Reliability decimal(5,2) not null,
    ST_AVG_Assertion string default (
        case
            when ST_AVG_Reliability > 0 then '+'
            when ST_AVG_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_ST_AVG int not null,
    constraint fkST_AVG_Stage_Average_Annex foreign key (
        ST_AVG_ID
    ) references public.ST_AVG_Stage_Average_Posit(ST_AVG_ID) RELY,
    constraint pkST_AVG_Stage_Average_Annex primary key (
        ST_AVG_ID,
        ST_AVG_Positor,
        ST_AVG_PositedAt
    ) RELY
) CLUSTER BY (ST_AVG_ID, ST_AVG_Positor, ST_AVG_PositedAt);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_MIN_Stage_Minimum_Posit (
    ST_MIN_ID int IDENTITY(1,1) not null, 
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    constraint fk_A_ST_MIN_Stage_Minimum_Posit foreign key (
        ST_MIN_ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint fk_K_ST_MIN_Stage_Minimum_Posit foreign key (
        ST_MIN_UTL_ID
    ) references public.UTL_Utilization(UTL_ID) RELY,
    constraint pkST_MIN_Stage_Minimum_Posit primary key (
        ST_MIN_ID
    ) RELY,
    constraint uqST_MIN_Stage_Minimum_Posit unique (
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    ) RELY
) CLUSTER BY (ST_MIN_ST_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Annex table (of ST_MIN_Stage_Minimum_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_MIN_Stage_Minimum_Annex (
    ST_MIN_ID int not null,
    ST_MIN_PositedAt datetime not null,
    ST_MIN_Positor tinyint not null,
    ST_MIN_Reliability decimal(5,2) not null,
    ST_MIN_Assertion string default (
        case
            when ST_MIN_Reliability > 0 then '+'
            when ST_MIN_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_ST_MIN int not null,
    constraint fkST_MIN_Stage_Minimum_Annex foreign key (
        ST_MIN_ID
    ) references public.ST_MIN_Stage_Minimum_Posit(ST_MIN_ID) RELY,
    constraint pkST_MIN_Stage_Minimum_Annex primary key (
        ST_MIN_ID,
        ST_MIN_Positor,
        ST_MIN_PositedAt
    ) RELY
) CLUSTER BY (ST_MIN_ID, ST_MIN_Positor, ST_MIN_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_NAM_Actor_Name_Posit (
    AC_NAM_ID int IDENTITY(1,1) not null, 
    AC_NAM_AC_ID int not null,
    AC_NAM_Actor_Name varchar(42) not null,
    AC_NAM_Checksum numeric(19,0) default hash(AC_NAM_Actor_Name),
    AC_NAM_ChangedAt datetime not null,
    constraint fkAC_NAM_Actor_Name_Posit foreign key (
        AC_NAM_AC_ID
    ) references public.AC_Actor(AC_ID) RELY,
    constraint pkAC_NAM_Actor_Name_Posit primary key (
        AC_NAM_ID
    ) RELY,
    constraint uqAC_NAM_Actor_Name_Posit unique (
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Checksum 
    ) RELY
) CLUSTER BY (AC_NAM_AC_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Annex table (of AC_NAM_Actor_Name_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_NAM_Actor_Name_Annex (
    AC_NAM_ID int not null,
    AC_NAM_PositedAt datetime not null,
    AC_NAM_Positor tinyint not null,
    AC_NAM_Reliability decimal(5,2) not null,
    AC_NAM_Assertion string default (
        case
            when AC_NAM_Reliability > 0 then '+'
            when AC_NAM_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_AC_NAM int not null,
    constraint fkAC_NAM_Actor_Name_Annex foreign key (
        AC_NAM_ID
    ) references public.AC_NAM_Actor_Name_Posit(AC_NAM_ID) RELY,
    constraint pkAC_NAM_Actor_Name_Annex primary key (
        AC_NAM_ID,
        AC_NAM_Positor,
        AC_NAM_PositedAt
    ) RELY
) CLUSTER BY (AC_NAM_ID, AC_NAM_Positor, AC_NAM_PositedAt);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_GEN_Actor_Gender_Posit (
    AC_GEN_ID int IDENTITY(1,1) not null, 
    AC_GEN_AC_ID int not null,
    AC_GEN_GEN_ID number(1,0) not null,
    constraint fk_A_AC_GEN_Actor_Gender_Posit foreign key (
        AC_GEN_AC_ID
    ) references public.AC_Actor(AC_ID) RELY,
    constraint fk_K_AC_GEN_Actor_Gender_Posit foreign key (
        AC_GEN_GEN_ID
    ) references public.GEN_Gender(GEN_ID) RELY,
    constraint pkAC_GEN_Actor_Gender_Posit primary key (
        AC_GEN_ID
    ) RELY,
    constraint uqAC_GEN_Actor_Gender_Posit unique (
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    ) RELY
) CLUSTER BY (AC_GEN_AC_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Annex table (of AC_GEN_Actor_Gender_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_GEN_Actor_Gender_Annex (
    AC_GEN_ID int not null,
    AC_GEN_PositedAt datetime not null,
    AC_GEN_Positor tinyint not null,
    AC_GEN_Reliability decimal(5,2) not null,
    AC_GEN_Assertion string default (
        case
            when AC_GEN_Reliability > 0 then '+'
            when AC_GEN_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_AC_GEN int not null,
    constraint fkAC_GEN_Actor_Gender_Annex foreign key (
        AC_GEN_ID
    ) references public.AC_GEN_Actor_Gender_Posit(AC_GEN_ID) RELY,
    constraint pkAC_GEN_Actor_Gender_Annex primary key (
        AC_GEN_ID,
        AC_GEN_Positor,
        AC_GEN_PositedAt
    ) RELY
) CLUSTER BY (AC_GEN_ID, AC_GEN_Positor, AC_GEN_PositedAt);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel_Posit (
    AC_PLV_ID int IDENTITY(1,1) not null, 
    AC_PLV_AC_ID int not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        AC_PLV_AC_ID
    ) references public.AC_Actor(AC_ID) RELY,
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        AC_PLV_PLV_ID
    ) references public.PLV_ProfessionalLevel(PLV_ID) RELY,
    constraint pkAC_PLV_Actor_ProfessionalLevel_Posit primary key (
        AC_PLV_ID
    ) RELY,
    constraint uqAC_PLV_Actor_ProfessionalLevel_Posit unique (
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    ) RELY
) CLUSTER BY (AC_PLV_AC_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Annex table (of AC_PLV_Actor_ProfessionalLevel_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel_Annex (
    AC_PLV_ID int not null,
    AC_PLV_PositedAt datetime not null,
    AC_PLV_Positor tinyint not null,
    AC_PLV_Reliability decimal(5,2) not null,
    AC_PLV_Assertion string default (
        case
            when AC_PLV_Reliability > 0 then '+'
            when AC_PLV_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_AC_PLV int not null,
    constraint fkAC_PLV_Actor_ProfessionalLevel_Annex foreign key (
        AC_PLV_ID
    ) references public.AC_PLV_Actor_ProfessionalLevel_Posit(AC_PLV_ID) RELY,
    constraint pkAC_PLV_Actor_ProfessionalLevel_Annex primary key (
        AC_PLV_ID,
        AC_PLV_Positor,
        AC_PLV_PositedAt
    ) RELY
) CLUSTER BY (AC_PLV_ID, AC_PLV_Positor, AC_PLV_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_NAM_Program_Name_Posit (
    PR_NAM_ID int IDENTITY(1,1) not null, 
    PR_NAM_PR_ID int not null,
    PR_NAM_Program_Name varchar(42) not null,
    constraint fkPR_NAM_Program_Name_Posit foreign key (
        PR_NAM_PR_ID
    ) references public.PR_Program(PR_ID) RELY,
    constraint pkPR_NAM_Program_Name_Posit primary key (
        PR_NAM_ID
    ) RELY,
    constraint uqPR_NAM_Program_Name_Posit unique (
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    ) RELY
) CLUSTER BY (PR_NAM_PR_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Annex table (of PR_NAM_Program_Name_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_NAM_Program_Name_Annex (
    PR_NAM_ID int not null,
    PR_NAM_PositedAt datetime not null,
    PR_NAM_Positor tinyint not null,
    PR_NAM_Reliability decimal(5,2) not null,
    PR_NAM_Assertion string default (
        case
            when PR_NAM_Reliability > 0 then '+'
            when PR_NAM_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_PR_NAM int not null,
    constraint fkPR_NAM_Program_Name_Annex foreign key (
        PR_NAM_ID
    ) references public.PR_NAM_Program_Name_Posit(PR_NAM_ID) RELY,
    constraint pkPR_NAM_Program_Name_Annex primary key (
        PR_NAM_ID,
        PR_NAM_Positor,
        PR_NAM_PositedAt
    ) RELY
) CLUSTER BY (PR_NAM_ID, PR_NAM_Positor, PR_NAM_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_LEN_Program_Length_Posit (
    PR_LEN_ID int IDENTITY(1,1) not null, 
    PR_LEN_PR_ID int not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length_Posit foreign key (
        PR_LEN_PR_ID
    ) references public.PR_Program(PR_ID) RELY,
    constraint pkPR_LEN_Program_Length_Posit primary key (
        PR_LEN_ID
    ) RELY,
    constraint uqPR_LEN_Program_Length_Posit unique (
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    ) RELY
) CLUSTER BY (PR_LEN_PR_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Annex table (of PR_LEN_Program_Length_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_LEN_Program_Length_Annex (
    PR_LEN_ID int not null,
    PR_LEN_PositedAt datetime not null,
    PR_LEN_Positor tinyint not null,
    PR_LEN_Reliability decimal(5,2) not null,
    PR_LEN_Assertion string default (
        case
            when PR_LEN_Reliability > 0 then '+'
            when PR_LEN_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_PR_LEN int not null,
    constraint fkPR_LEN_Program_Length_Annex foreign key (
        PR_LEN_ID
    ) references public.PR_LEN_Program_Length_Posit(PR_LEN_ID) RELY,
    constraint pkPR_LEN_Program_Length_Annex primary key (
        PR_LEN_ID,
        PR_LEN_Positor,
        PR_LEN_PositedAt
    ) RELY
) CLUSTER BY (PR_LEN_ID, PR_LEN_Positor, PR_LEN_PositedAt);
