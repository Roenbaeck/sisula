-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_DAT_Event_Date_Posit (
    EV_DAT_ID number(10) IDENTITY(1,1) not null, 
    EV_DAT_EV_ID number(10) not null,
    EV_DAT_Event_Date timestamp not null,
    constraint fkEV_DAT_Event_Date_Posit foreign key (
        EV_DAT_EV_ID
    ) references public.EV_Event(EV_ID),
    constraint pkEV_DAT_Event_Date_Posit primary key (
        EV_DAT_ID
    ),
    constraint uqEV_DAT_Event_Date_Posit unique (
        EV_DAT_EV_ID,
        EV_DAT_Event_Date
    )
) CLUSTER BY (EV_DAT_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Annex table (of EV_DAT_Event_Date_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_DAT_Event_Date_Annex (
    EV_DAT_ID number(10) not null,
    EV_DAT_PositedAt timestamp not null,
    EV_DAT_Positor number(3) not null,
    EV_DAT_Reliability number(5,2) not null,
    EV_DAT_Assertion varchar2(4000) default (
        case
            when EV_DAT_Reliability > 0 then '+'
            when EV_DAT_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_DAT_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_DAT number(10) not null,
    constraint fkEV_DAT_Event_Date_Annex foreign key (
        EV_DAT_ID
    ) references public.EV_DAT_Event_Date_Posit(EV_DAT_ID),
    constraint pkEV_DAT_Event_Date_Annex primary key (
        EV_DAT_ID,
        EV_DAT_Positor,
        EV_DAT_PositedAt
    )
) CLUSTER BY (EV_DAT_ID, EV_DAT_Positor, EV_DAT_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_AUD_Event_Audience_Posit (
    EV_AUD_ID number(10) IDENTITY(1,1) not null, 
    EV_AUD_EV_ID number(10) not null,
    EV_AUD_Event_Audience number(10) not null,
    constraint fkEV_AUD_Event_Audience_Posit foreign key (
        EV_AUD_EV_ID
    ) references public.EV_Event(EV_ID),
    constraint pkEV_AUD_Event_Audience_Posit primary key (
        EV_AUD_ID
    ),
    constraint uqEV_AUD_Event_Audience_Posit unique (
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    )
) CLUSTER BY (EV_AUD_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Annex table (of EV_AUD_Event_Audience_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_AUD_Event_Audience_Annex (
    EV_AUD_ID number(10) not null,
    EV_AUD_PositedAt timestamp not null,
    EV_AUD_Positor number(3) not null,
    EV_AUD_Reliability number(5,2) not null,
    EV_AUD_Assertion varchar2(4000) default (
        case
            when EV_AUD_Reliability > 0 then '+'
            when EV_AUD_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_AUD_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_AUD number(10) not null,
    constraint fkEV_AUD_Event_Audience_Annex foreign key (
        EV_AUD_ID
    ) references public.EV_AUD_Event_Audience_Posit(EV_AUD_ID),
    constraint pkEV_AUD_Event_Audience_Annex primary key (
        EV_AUD_ID,
        EV_AUD_Positor,
        EV_AUD_PositedAt
    )
) CLUSTER BY (EV_AUD_ID, EV_AUD_Positor, EV_AUD_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_REV_Event_Revenue_Posit (
    EV_REV_ID number(10) IDENTITY(1,1) not null, 
    EV_REV_EV_ID number(10) not null,
    EV_REV_Event_Revenue number(19,4) not null,
    constraint fkEV_REV_Event_Revenue_Posit foreign key (
        EV_REV_EV_ID
    ) references public.EV_Event(EV_ID),
    constraint pkEV_REV_Event_Revenue_Posit primary key (
        EV_REV_ID
    ),
    constraint uqEV_REV_Event_Revenue_Posit unique (
        EV_REV_EV_ID,
        EV_REV_Event_Revenue
    )
) CLUSTER BY (EV_REV_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Annex table (of EV_REV_Event_Revenue_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_REV_Event_Revenue_Annex (
    EV_REV_ID number(10) not null,
    EV_REV_PositedAt timestamp not null,
    EV_REV_Positor number(3) not null,
    EV_REV_Reliability number(5,2) not null,
    EV_REV_Assertion varchar2(4000) default (
        case
            when EV_REV_Reliability > 0 then '+'
            when EV_REV_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_REV_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_REV number(10) not null,
    constraint fkEV_REV_Event_Revenue_Annex foreign key (
        EV_REV_ID
    ) references public.EV_REV_Event_Revenue_Posit(EV_REV_ID),
    constraint pkEV_REV_Event_Revenue_Annex primary key (
        EV_REV_ID,
        EV_REV_Positor,
        EV_REV_PositedAt
    )
) CLUSTER BY (EV_REV_ID, EV_REV_Positor, EV_REV_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_NAM_Stage_Name_Posit (
    ST_NAM_ID number(10) IDENTITY(1,1) not null, 
    ST_NAM_ST_ID number(10) not null,
    ST_NAM_Stage_Name nvarchar2(42) not null,
    ST_NAM_ChangedAt timestamp not null,
    constraint fkST_NAM_Stage_Name_Posit foreign key (
        ST_NAM_ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint pkST_NAM_Stage_Name_Posit primary key (
        ST_NAM_ID
    ),
    constraint uqST_NAM_Stage_Name_Posit unique (
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
) CLUSTER BY (ST_NAM_ST_ID, ST_NAM_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Annex table (of ST_NAM_Stage_Name_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_NAM_Stage_Name_Annex (
    ST_NAM_ID number(10) not null,
    ST_NAM_PositedAt timestamp not null,
    ST_NAM_Positor number(3) not null,
    ST_NAM_Reliability number(5,2) not null,
    ST_NAM_Assertion varchar2(4000) default (
        case
            when ST_NAM_Reliability > 0 then '+'
            when ST_NAM_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_NAM_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_NAM number(10) not null,
    constraint fkST_NAM_Stage_Name_Annex foreign key (
        ST_NAM_ID
    ) references public.ST_NAM_Stage_Name_Posit(ST_NAM_ID),
    constraint pkST_NAM_Stage_Name_Annex primary key (
        ST_NAM_ID,
        ST_NAM_Positor,
        ST_NAM_PositedAt
    )
) CLUSTER BY (ST_NAM_ID, ST_NAM_Positor, ST_NAM_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_LOC_Stage_Location_Posit (
    ST_LOC_ID number(10) IDENTITY(1,1) not null, 
    ST_LOC_ST_ID number(10) not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum numeric(19,0) default hash(ST_LOC_Stage_Location),
    constraint fkST_LOC_Stage_Location_Posit foreign key (
        ST_LOC_ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint pkST_LOC_Stage_Location_Posit primary key (
        ST_LOC_ID
    ),
    constraint uqST_LOC_Stage_Location_Posit unique (
        ST_LOC_ST_ID,
        ST_LOC_Checksum 
    )
) CLUSTER BY (ST_LOC_ST_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Annex table (of ST_LOC_Stage_Location_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_LOC_Stage_Location_Annex (
    ST_LOC_ID number(10) not null,
    ST_LOC_PositedAt timestamp not null,
    ST_LOC_Positor number(3) not null,
    ST_LOC_Reliability number(5,2) not null,
    ST_LOC_Assertion varchar2(4000) default (
        case
            when ST_LOC_Reliability > 0 then '+'
            when ST_LOC_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_LOC_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_LOC number(10) not null,
    constraint fkST_LOC_Stage_Location_Annex foreign key (
        ST_LOC_ID
    ) references public.ST_LOC_Stage_Location_Posit(ST_LOC_ID),
    constraint pkST_LOC_Stage_Location_Annex primary key (
        ST_LOC_ID,
        ST_LOC_Positor,
        ST_LOC_PositedAt
    )
) CLUSTER BY (ST_LOC_ID, ST_LOC_Positor, ST_LOC_PositedAt);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_AVG_Stage_Average_Posit (
    ST_AVG_ID number(10) IDENTITY(1,1) not null, 
    ST_AVG_ST_ID number(10) not null,
    ST_AVG_UTL_ID number(3) not null,
    ST_AVG_ChangedAt timestamp not null,
    constraint fk_A_ST_AVG_Stage_Average_Posit foreign key (
        ST_AVG_ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint fk_K_ST_AVG_Stage_Average_Posit foreign key (
        ST_AVG_UTL_ID
    ) references public.UTL_Utilization(UTL_ID),
    constraint pkST_AVG_Stage_Average_Posit primary key (
        ST_AVG_ID
    ),
    constraint uqST_AVG_Stage_Average_Posit unique (
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
) CLUSTER BY (ST_AVG_ST_ID, ST_AVG_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Annex table (of ST_AVG_Stage_Average_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_AVG_Stage_Average_Annex (
    ST_AVG_ID number(10) not null,
    ST_AVG_PositedAt timestamp not null,
    ST_AVG_Positor number(3) not null,
    ST_AVG_Reliability number(5,2) not null,
    ST_AVG_Assertion varchar2(4000) default (
        case
            when ST_AVG_Reliability > 0 then '+'
            when ST_AVG_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_AVG_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_AVG number(10) not null,
    constraint fkST_AVG_Stage_Average_Annex foreign key (
        ST_AVG_ID
    ) references public.ST_AVG_Stage_Average_Posit(ST_AVG_ID),
    constraint pkST_AVG_Stage_Average_Annex primary key (
        ST_AVG_ID,
        ST_AVG_Positor,
        ST_AVG_PositedAt
    )
) CLUSTER BY (ST_AVG_ID, ST_AVG_Positor, ST_AVG_PositedAt);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_MIN_Stage_Minimum_Posit (
    ST_MIN_ID number(10) IDENTITY(1,1) not null, 
    ST_MIN_ST_ID number(10) not null,
    ST_MIN_UTL_ID number(3) not null,
    constraint fk_A_ST_MIN_Stage_Minimum_Posit foreign key (
        ST_MIN_ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum_Posit foreign key (
        ST_MIN_UTL_ID
    ) references public.UTL_Utilization(UTL_ID),
    constraint pkST_MIN_Stage_Minimum_Posit primary key (
        ST_MIN_ID
    ),
    constraint uqST_MIN_Stage_Minimum_Posit unique (
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
) CLUSTER BY (ST_MIN_ST_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Annex table (of ST_MIN_Stage_Minimum_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_MIN_Stage_Minimum_Annex (
    ST_MIN_ID number(10) not null,
    ST_MIN_PositedAt timestamp not null,
    ST_MIN_Positor number(3) not null,
    ST_MIN_Reliability number(5,2) not null,
    ST_MIN_Assertion varchar2(4000) default (
        case
            when ST_MIN_Reliability > 0 then '+'
            when ST_MIN_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_MIN_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_MIN number(10) not null,
    constraint fkST_MIN_Stage_Minimum_Annex foreign key (
        ST_MIN_ID
    ) references public.ST_MIN_Stage_Minimum_Posit(ST_MIN_ID),
    constraint pkST_MIN_Stage_Minimum_Annex primary key (
        ST_MIN_ID,
        ST_MIN_Positor,
        ST_MIN_PositedAt
    )
) CLUSTER BY (ST_MIN_ID, ST_MIN_Positor, ST_MIN_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_NAM_Actor_Name_Posit (
    AC_NAM_ID number(10) IDENTITY(1,1) not null, 
    AC_NAM_AC_ID number(10) not null,
    AC_NAM_Actor_Name nvarchar2(42) not null,
    AC_NAM_ChangedAt timestamp not null,
    constraint fkAC_NAM_Actor_Name_Posit foreign key (
        AC_NAM_AC_ID
    ) references public.AC_Actor(AC_ID),
    constraint pkAC_NAM_Actor_Name_Posit primary key (
        AC_NAM_ID
    ),
    constraint uqAC_NAM_Actor_Name_Posit unique (
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
) CLUSTER BY (AC_NAM_AC_ID, AC_NAM_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Annex table (of AC_NAM_Actor_Name_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_NAM_Actor_Name_Annex (
    AC_NAM_ID number(10) not null,
    AC_NAM_PositedAt timestamp not null,
    AC_NAM_Positor number(3) not null,
    AC_NAM_Reliability number(5,2) not null,
    AC_NAM_Assertion varchar2(4000) default (
        case
            when AC_NAM_Reliability > 0 then '+'
            when AC_NAM_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_NAM_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_NAM number(10) not null,
    constraint fkAC_NAM_Actor_Name_Annex foreign key (
        AC_NAM_ID
    ) references public.AC_NAM_Actor_Name_Posit(AC_NAM_ID),
    constraint pkAC_NAM_Actor_Name_Annex primary key (
        AC_NAM_ID,
        AC_NAM_Positor,
        AC_NAM_PositedAt
    )
) CLUSTER BY (AC_NAM_ID, AC_NAM_Positor, AC_NAM_PositedAt);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_GEN_Actor_Gender_Posit (
    AC_GEN_ID number(10) IDENTITY(1,1) not null, 
    AC_GEN_AC_ID number(10) not null,
    AC_GEN_GEN_ID number(3) not null,
    constraint fk_A_AC_GEN_Actor_Gender_Posit foreign key (
        AC_GEN_AC_ID
    ) references public.AC_Actor(AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender_Posit foreign key (
        AC_GEN_GEN_ID
    ) references public.GEN_Gender(GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Posit primary key (
        AC_GEN_ID
    ),
    constraint uqAC_GEN_Actor_Gender_Posit unique (
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
) CLUSTER BY (AC_GEN_AC_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Annex table (of AC_GEN_Actor_Gender_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_GEN_Actor_Gender_Annex (
    AC_GEN_ID number(10) not null,
    AC_GEN_PositedAt timestamp not null,
    AC_GEN_Positor number(3) not null,
    AC_GEN_Reliability number(5,2) not null,
    AC_GEN_Assertion varchar2(4000) default (
        case
            when AC_GEN_Reliability > 0 then '+'
            when AC_GEN_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_GEN_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_GEN number(10) not null,
    constraint fkAC_GEN_Actor_Gender_Annex foreign key (
        AC_GEN_ID
    ) references public.AC_GEN_Actor_Gender_Posit(AC_GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Annex primary key (
        AC_GEN_ID,
        AC_GEN_Positor,
        AC_GEN_PositedAt
    )
) CLUSTER BY (AC_GEN_ID, AC_GEN_Positor, AC_GEN_PositedAt);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel_Posit (
    AC_PLV_ID number(10) IDENTITY(1,1) not null, 
    AC_PLV_AC_ID number(10) not null,
    AC_PLV_PLV_ID number(3) not null,
    AC_PLV_ChangedAt timestamp not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        AC_PLV_AC_ID
    ) references public.AC_Actor(AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        AC_PLV_PLV_ID
    ) references public.PLV_ProfessionalLevel(PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Posit primary key (
        AC_PLV_ID
    ),
    constraint uqAC_PLV_Actor_ProfessionalLevel_Posit unique (
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
) CLUSTER BY (AC_PLV_AC_ID, AC_PLV_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Annex table (of AC_PLV_Actor_ProfessionalLevel_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel_Annex (
    AC_PLV_ID number(10) not null,
    AC_PLV_PositedAt timestamp not null,
    AC_PLV_Positor number(3) not null,
    AC_PLV_Reliability number(5,2) not null,
    AC_PLV_Assertion varchar2(4000) default (
        case
            when AC_PLV_Reliability > 0 then '+'
            when AC_PLV_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_PLV_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_PLV number(10) not null,
    constraint fkAC_PLV_Actor_ProfessionalLevel_Annex foreign key (
        AC_PLV_ID
    ) references public.AC_PLV_Actor_ProfessionalLevel_Posit(AC_PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Annex primary key (
        AC_PLV_ID,
        AC_PLV_Positor,
        AC_PLV_PositedAt
    )
) CLUSTER BY (AC_PLV_ID, AC_PLV_Positor, AC_PLV_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_NAM_Program_Name_Posit (
    PR_NAM_ID number(10) IDENTITY(1,1) not null, 
    PR_NAM_PR_ID number(10) not null,
    PR_NAM_Program_Name nvarchar2(42) not null,
    constraint fkPR_NAM_Program_Name_Posit foreign key (
        PR_NAM_PR_ID
    ) references public.PR_Program(PR_ID),
    constraint pkPR_NAM_Program_Name_Posit primary key (
        PR_NAM_ID
    ),
    constraint uqPR_NAM_Program_Name_Posit unique (
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    )
) CLUSTER BY (PR_NAM_PR_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Annex table (of PR_NAM_Program_Name_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_NAM_Program_Name_Annex (
    PR_NAM_ID number(10) not null,
    PR_NAM_PositedAt timestamp not null,
    PR_NAM_Positor number(3) not null,
    PR_NAM_Reliability number(5,2) not null,
    PR_NAM_Assertion varchar2(4000) default (
        case
            when PR_NAM_Reliability > 0 then '+'
            when PR_NAM_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when PR_NAM_Reliability <  then 0
            else 1
        end
    ),
    Metadata_PR_NAM number(10) not null,
    constraint fkPR_NAM_Program_Name_Annex foreign key (
        PR_NAM_ID
    ) references public.PR_NAM_Program_Name_Posit(PR_NAM_ID),
    constraint pkPR_NAM_Program_Name_Annex primary key (
        PR_NAM_ID,
        PR_NAM_Positor,
        PR_NAM_PositedAt
    )
) CLUSTER BY (PR_NAM_ID, PR_NAM_Positor, PR_NAM_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_LEN_Program_Length_Posit (
    PR_LEN_ID number(10) IDENTITY(1,1) not null, 
    PR_LEN_PR_ID number(10) not null,
    PR_LEN_Program_Length timestamp not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length_Posit foreign key (
        PR_LEN_PR_ID
    ) references public.PR_Program(PR_ID),
    constraint pkPR_LEN_Program_Length_Posit primary key (
        PR_LEN_ID
    ),
    constraint uqPR_LEN_Program_Length_Posit unique (
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
) CLUSTER BY (PR_LEN_PR_ID, PR_LEN_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Annex table (of PR_LEN_Program_Length_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_LEN_Program_Length_Annex (
    PR_LEN_ID number(10) not null,
    PR_LEN_PositedAt timestamp not null,
    PR_LEN_Positor number(3) not null,
    PR_LEN_Reliability number(5,2) not null,
    PR_LEN_Assertion varchar2(4000) default (
        case
            when PR_LEN_Reliability > 0 then '+'
            when PR_LEN_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when PR_LEN_Reliability <  then 0
            else 1
        end
    ),
    Metadata_PR_LEN number(10) not null,
    constraint fkPR_LEN_Program_Length_Annex foreign key (
        PR_LEN_ID
    ) references public.PR_LEN_Program_Length_Posit(PR_LEN_ID),
    constraint pkPR_LEN_Program_Length_Annex primary key (
        PR_LEN_ID,
        PR_LEN_Positor,
        PR_LEN_PositedAt
    )
) CLUSTER BY (PR_LEN_ID, PR_LEN_Positor, PR_LEN_PositedAt);
