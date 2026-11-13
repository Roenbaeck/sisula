-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public._Positor (
    Positor number(3) not null,
    constraint pk_Positor primary key (
        Positor
    )
);
MERGE INTO public._Positor p
USING ( SELECT 0 AS _defaultPositor ) d
ON (
    d._defaultPositor = p.Positor
)
WHEN NOT MATCHED THEN
INSERT (
    Positor
)
VALUES (
    d._defaultPositor
);
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_ParentalType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PAT_ParentalType (
    PAT_ID number(3) not null,
    PAT_ParentalType nvarchar2(42) not null,
    Metadata_PAT number(10) not null,
    constraint pkPAT_ParentalType primary key (
        PAT_ID
    ),
    constraint uqPAT_ParentalType unique (
        PAT_ParentalType
    )
) CLUSTER BY (PAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.GEN_Gender (
    GEN_ID number(3) not null,
    GEN_Gender nvarchar2(42) not null,
    Metadata_GEN number(10) not null,
    constraint pkGEN_Gender primary key (
        GEN_ID
    ),
    constraint uqGEN_Gender unique (
        GEN_Gender
    )
) CLUSTER BY (GEN_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PLV_ProfessionalLevel (
    PLV_ID number(3) not null,
    PLV_ProfessionalLevel nclob not null,
    PLV_Checksum numeric(19,0) default hash(PLV_ProfessionalLevel),
    Metadata_PLV number(10) not null,
    constraint pkPLV_ProfessionalLevel primary key (
        PLV_ID
    ),
    constraint uqPLV_ProfessionalLevel unique (
        PLV_Checksum 
    )
) CLUSTER BY (PLV_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.UTL_Utilization (
    UTL_ID number(3) not null,
    UTL_Utilization number(3) not null,
    Metadata_UTL number(10) not null,
    constraint pkUTL_Utilization primary key (
        UTL_ID
    ),
    constraint uqUTL_Utilization unique (
        UTL_Utilization
    )
) CLUSTER BY (UTL_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ONG_Ongoing (
    ONG_ID number(3) not null,
    ONG_Ongoing nvarchar2(3) not null,
    Metadata_ONG number(10) not null,
    constraint pkONG_Ongoing primary key (
        ONG_ID
    ),
    constraint uqONG_Ongoing unique (
        ONG_Ongoing
    )
) CLUSTER BY (ONG_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.RAT_Rating (
    RAT_ID number(3) not null,
    RAT_Rating nvarchar2(42) not null,
    Metadata_RAT number(10) not null,
    constraint pkRAT_Rating primary key (
        RAT_ID
    ),
    constraint uqRAT_Rating unique (
        RAT_Rating
    )
) CLUSTER BY (RAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ETY_EventType (
    ETY_ID number(3) not null,
    ETY_EventType nvarchar2(42) not null,
    Metadata_ETY number(10) not null,
    constraint pkETY_EventType primary key (
        ETY_ID
    ),
    constraint uqETY_EventType unique (
        ETY_EventType
    )
) CLUSTER BY (ETY_ID);
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PN_Person (
    PN_ID number(10) IDENTITY(1,1) not null, 
    Metadata_PN number(10) not null, 
    constraint pkPN_Person primary key (
        PN_ID
    )
) CLUSTER BY (PN_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_Stage (
    ST_ID number(10) IDENTITY(1,1) not null, 
    Metadata_ST number(10) not null, 
    constraint pkST_Stage primary key (
        ST_ID
    )
) CLUSTER BY (ST_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_Actor (
    AC_ID number(10) IDENTITY(1,1) not null, 
    Metadata_AC number(10) not null, 
    constraint pkAC_Actor primary key (
        AC_ID
    )
) CLUSTER BY (AC_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_Program (
    PR_ID number(10) IDENTITY(1,1) not null, 
    Metadata_PR number(10) not null, 
    constraint pkPR_Program primary key (
        PR_ID
    )
) CLUSTER BY (PR_ID);
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 3 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_Event (
    EV_ID number(10) IDENTITY(1,1) not null, 
    ST_ID_wasHeldAt number(10) not null, 
    PR_ID_wasPlayed number(10) not null, 
    ETY_ID_of number(3) not null,
    constraint EV_Event_fkST_wasHeldAt foreign key (
        ST_ID_wasHeldAt
    ) references public.ST_Stage(ST_ID), 
    constraint EV_Event_fkPR_wasPlayed foreign key (
        PR_ID_wasPlayed
    ) references public.PR_Program(PR_ID), 
    constraint EV_Event_fkETY_of foreign key (
        ETY_ID_of
    ) references public.ETY_EventType(ETY_ID),
    Metadata_EV number(10) not null, 
    constraint pkEV_Event primary key (
        EV_ID
    )
) CLUSTER BY (EV_ID);
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
-- ATTRIBUTE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views. These provide a stable baseline
-- for perspectives and can later be expanded to parameterized SQL macros.
--
CREATE OR REPLACE VIEW public.rEV_DAT_Event_Date AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Positor,
    a.EV_DAT_Reliability,
    a.EV_DAT_Assertion,
    a.,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date
FROM
    public.EV_DAT_Event_Date_Posit p
JOIN
    public.EV_DAT_Event_Date_Annex a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
WHERE
    a.EV_DAT_Positor = 0
AND
    a.EV_DAT_PositedAt = (
        SELECT
            MAX(sub.EV_DAT_PositedAt)
        FROM
            public.EV_DAT_Event_Date_Annex sub
        WHERE
            sub.EV_DAT_ID = p.EV_DAT_ID
        AND
            sub.EV_DAT_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rEV_AUD_Event_Audience AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Positor,
    a.EV_AUD_Reliability,
    a.EV_AUD_Assertion,
    a.,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience
FROM
    public.EV_AUD_Event_Audience_Posit p
JOIN
    public.EV_AUD_Event_Audience_Annex a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
WHERE
    a.EV_AUD_Positor = 0
AND
    a.EV_AUD_PositedAt = (
        SELECT
            MAX(sub.EV_AUD_PositedAt)
        FROM
            public.EV_AUD_Event_Audience_Annex sub
        WHERE
            sub.EV_AUD_ID = p.EV_AUD_ID
        AND
            sub.EV_AUD_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rEV_REV_Event_Revenue AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    a.EV_REV_PositedAt,
    a.EV_REV_Positor,
    a.EV_REV_Reliability,
    a.EV_REV_Assertion,
    a.,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue
FROM
    public.EV_REV_Event_Revenue_Posit p
JOIN
    public.EV_REV_Event_Revenue_Annex a
ON
    a.EV_REV_ID = p.EV_REV_ID
WHERE
    a.EV_REV_Positor = 0
AND
    a.EV_REV_PositedAt = (
        SELECT
            MAX(sub.EV_REV_PositedAt)
        FROM
            public.EV_REV_Event_Revenue_Annex sub
        WHERE
            sub.EV_REV_ID = p.EV_REV_ID
        AND
            sub.EV_REV_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rST_NAM_Stage_Name AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Positor,
    a.ST_NAM_Reliability,
    a.ST_NAM_Assertion,
    a.,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name
    , p.ST_NAM_ChangedAt
FROM
    public.ST_NAM_Stage_Name_Posit p
JOIN
    public.ST_NAM_Stage_Name_Annex a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
WHERE
    a.ST_NAM_Positor = 0
AND
    a.ST_NAM_PositedAt = (
        SELECT
            MAX(sub.ST_NAM_PositedAt)
        FROM
            public.ST_NAM_Stage_Name_Annex sub
        WHERE
            sub.ST_NAM_ID = p.ST_NAM_ID
        AND
            sub.ST_NAM_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rST_LOC_Stage_Location AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Positor,
    a.ST_LOC_Reliability,
    a.ST_LOC_Assertion,
    a.,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location
FROM
    public.ST_LOC_Stage_Location_Posit p
JOIN
    public.ST_LOC_Stage_Location_Annex a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
WHERE
    a.ST_LOC_Positor = 0
AND
    a.ST_LOC_PositedAt = (
        SELECT
            MAX(sub.ST_LOC_PositedAt)
        FROM
            public.ST_LOC_Stage_Location_Annex sub
        WHERE
            sub.ST_LOC_ID = p.ST_LOC_ID
        AND
            sub.ST_LOC_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rST_AVG_Stage_Average AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Positor,
    a.ST_AVG_Reliability,
    a.ST_AVG_Assertion,
    a.,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID
    , p.ST_AVG_ChangedAt
FROM
    public.ST_AVG_Stage_Average_Posit p
JOIN
    public.ST_AVG_Stage_Average_Annex a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
WHERE
    a.ST_AVG_Positor = 0
AND
    a.ST_AVG_PositedAt = (
        SELECT
            MAX(sub.ST_AVG_PositedAt)
        FROM
            public.ST_AVG_Stage_Average_Annex sub
        WHERE
            sub.ST_AVG_ID = p.ST_AVG_ID
        AND
            sub.ST_AVG_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rST_MIN_Stage_Minimum AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Positor,
    a.ST_MIN_Reliability,
    a.ST_MIN_Assertion,
    a.,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID
FROM
    public.ST_MIN_Stage_Minimum_Posit p
JOIN
    public.ST_MIN_Stage_Minimum_Annex a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
WHERE
    a.ST_MIN_Positor = 0
AND
    a.ST_MIN_PositedAt = (
        SELECT
            MAX(sub.ST_MIN_PositedAt)
        FROM
            public.ST_MIN_Stage_Minimum_Annex sub
        WHERE
            sub.ST_MIN_ID = p.ST_MIN_ID
        AND
            sub.ST_MIN_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rAC_NAM_Actor_Name AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Positor,
    a.AC_NAM_Reliability,
    a.AC_NAM_Assertion,
    a.,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name
    , p.AC_NAM_ChangedAt
FROM
    public.AC_NAM_Actor_Name_Posit p
JOIN
    public.AC_NAM_Actor_Name_Annex a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
WHERE
    a.AC_NAM_Positor = 0
AND
    a.AC_NAM_PositedAt = (
        SELECT
            MAX(sub.AC_NAM_PositedAt)
        FROM
            public.AC_NAM_Actor_Name_Annex sub
        WHERE
            sub.AC_NAM_ID = p.AC_NAM_ID
        AND
            sub.AC_NAM_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rAC_GEN_Actor_Gender AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Positor,
    a.AC_GEN_Reliability,
    a.AC_GEN_Assertion,
    a.,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID
FROM
    public.AC_GEN_Actor_Gender_Posit p
JOIN
    public.AC_GEN_Actor_Gender_Annex a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
WHERE
    a.AC_GEN_Positor = 0
AND
    a.AC_GEN_PositedAt = (
        SELECT
            MAX(sub.AC_GEN_PositedAt)
        FROM
            public.AC_GEN_Actor_Gender_Annex sub
        WHERE
            sub.AC_GEN_ID = p.AC_GEN_ID
        AND
            sub.AC_GEN_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rAC_PLV_Actor_ProfessionalLevel AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Positor,
    a.AC_PLV_Reliability,
    a.AC_PLV_Assertion,
    a.,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID
    , p.AC_PLV_ChangedAt
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit p
JOIN
    public.AC_PLV_Actor_ProfessionalLevel_Annex a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
WHERE
    a.AC_PLV_Positor = 0
AND
    a.AC_PLV_PositedAt = (
        SELECT
            MAX(sub.AC_PLV_PositedAt)
        FROM
            public.AC_PLV_Actor_ProfessionalLevel_Annex sub
        WHERE
            sub.AC_PLV_ID = p.AC_PLV_ID
        AND
            sub.AC_PLV_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rPR_NAM_Program_Name AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Positor,
    a.PR_NAM_Reliability,
    a.PR_NAM_Assertion,
    a.,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name
FROM
    public.PR_NAM_Program_Name_Posit p
JOIN
    public.PR_NAM_Program_Name_Annex a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
WHERE
    a.PR_NAM_Positor = 0
AND
    a.PR_NAM_PositedAt = (
        SELECT
            MAX(sub.PR_NAM_PositedAt)
        FROM
            public.PR_NAM_Program_Name_Annex sub
        WHERE
            sub.PR_NAM_ID = p.PR_NAM_ID
        AND
            sub.PR_NAM_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rPR_LEN_Program_Length AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Positor,
    a.PR_LEN_Reliability,
    a.PR_LEN_Assertion,
    a.,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length
    , p.PR_LEN_ChangedAt
FROM
    public.PR_LEN_Program_Length_Posit p
JOIN
    public.PR_LEN_Program_Length_Annex a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
WHERE
    a.PR_LEN_Positor = 0
AND
    a.PR_LEN_PositedAt = (
        SELECT
            MAX(sub.PR_LEN_PositedAt)
        FROM
            public.PR_LEN_Program_Length_Annex sub
        WHERE
            sub.PR_LEN_ID = p.PR_LEN_ID
        AND
            sub.PR_LEN_Positor = 0
    )
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
CREATE TABLE IF NOT EXISTS public.AC_partner_AC_with_ONG_currently_Posit (
    AC_partner_AC_with_ONG_currently_ID number(10) IDENTITY(1,1) not null, 
    AC_ID_partner number(10) not null, 
    AC_ID_with number(10) not null, 
    ONG_ID_currently number(3) not null,
    AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_partner foreign key (
        AC_ID_partner
    ) references public.AC_Actor(AC_ID),
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_with foreign key (
        AC_ID_with
    ) references public.AC_Actor(AC_ID),
    constraint AC_partner_AC_with_ONG_currently_Posit_fkONG_currently foreign key (
        ONG_ID_currently
    ) references public.ONG_Ongoing(ONG_ID),
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint pkAC_partner_AC_with_ONG_currently_Posit primary key (
        AC_partner_AC_with_ONG_currently_ID
    ),
    constraint uqAC_partner_AC_with_ONG_currently unique (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
) CLUSTER BY (
    AC_partner_AC_with_ONG_currently_ChangedAt
);

CREATE TABLE IF NOT EXISTS public.AC_partner_AC_with_ONG_currently_Annex (
    AC_partner_AC_with_ONG_currently_ID number(10) not null,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp not null,
    AC_partner_AC_with_ONG_currently_Positor number(3) not null,
    AC_partner_AC_with_ONG_currently_Reliability number(5,2) not null,
    AC_partner_AC_with_ONG_currently_Assertion varchar2(4000) default (
        case
            when AC_partner_AC_with_ONG_currently_Reliability > 0 then '+'
            when AC_partner_AC_with_ONG_currently_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_partner_AC_with_ONG_currently_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_partner_AC_with_ONG_currently number(10) not null,
    constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
        AC_partner_AC_with_ONG_currently_ID
    ) references public.AC_partner_AC_with_ONG_currently_Posit(AC_partner_AC_with_ONG_currently_ID),
    constraint pkAC_partner_AC_with_ONG_currently_Annex primary key (
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt
    )
) CLUSTER BY (AC_partner_AC_with_ONG_currently_ID, AC_partner_AC_with_ONG_currently_Positor, AC_partner_AC_with_ONG_currently_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_subset_PN_of_Posit (
    AC_subset_PN_of_ID number(10) IDENTITY(1,1) not null, 
    AC_ID_subset number(10) not null, 
    PN_ID_of number(10) not null, 
    constraint AC_subset_PN_of_Posit_fkAC_subset foreign key (
        AC_ID_subset
    ) references public.AC_Actor(AC_ID),
    constraint AC_subset_PN_of_Posit_fkPN_of foreign key (
        PN_ID_of
    ) references public.PN_Person(PN_ID),
    constraint AC_subset_PN_of_Posit_uqAC_subset unique (
        AC_ID_subset
    ),
    constraint AC_subset_PN_of_Posit_uqPN_of unique (
        PN_ID_of
    ),
    constraint pkAC_subset_PN_of_Posit primary key (
        AC_subset_PN_of_ID
    ),
    constraint uqAC_subset_PN_of unique (
        AC_ID_subset,
        PN_ID_of
    )
) CLUSTER BY (
);

CREATE TABLE IF NOT EXISTS public.AC_subset_PN_of_Annex (
    AC_subset_PN_of_ID number(10) not null,
    AC_subset_PN_of_PositedAt timestamp not null,
    AC_subset_PN_of_Positor number(3) not null,
    AC_subset_PN_of_Reliability number(5,2) not null,
    AC_subset_PN_of_Assertion varchar2(4000) default (
        case
            when AC_subset_PN_of_Reliability > 0 then '+'
            when AC_subset_PN_of_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_subset_PN_of_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_subset_PN_of number(10) not null,
    constraint fkAC_subset_PN_of_Annex foreign key (
        AC_subset_PN_of_ID
    ) references public.AC_subset_PN_of_Posit(AC_subset_PN_of_ID),
    constraint pkAC_subset_PN_of_Annex primary key (
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt
    )
) CLUSTER BY (AC_subset_PN_of_ID, AC_subset_PN_of_Positor, AC_subset_PN_of_PositedAt);
CREATE TABLE IF NOT EXISTS public.EV_in_AC_wasCast_Posit (
    EV_in_AC_wasCast_ID number(10) IDENTITY(1,1) not null, 
    EV_ID_in number(10) not null, 
    AC_ID_wasCast number(10) not null, 
    constraint EV_in_AC_wasCast_Posit_fkEV_in foreign key (
        EV_ID_in
    ) references public.EV_Event(EV_ID),
    constraint EV_in_AC_wasCast_Posit_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references public.AC_Actor(AC_ID),
    constraint pkEV_in_AC_wasCast_Posit primary key (
        EV_in_AC_wasCast_ID
    ),
    constraint uqEV_in_AC_wasCast unique (
        EV_ID_in,
        AC_ID_wasCast
    )
) CLUSTER BY (
    EV_ID_in,
    AC_ID_wasCast
);

CREATE TABLE IF NOT EXISTS public.EV_in_AC_wasCast_Annex (
    EV_in_AC_wasCast_ID number(10) not null,
    EV_in_AC_wasCast_PositedAt timestamp not null,
    EV_in_AC_wasCast_Positor number(3) not null,
    EV_in_AC_wasCast_Reliability number(5,2) not null,
    EV_in_AC_wasCast_Assertion varchar2(4000) default (
        case
            when EV_in_AC_wasCast_Reliability > 0 then '+'
            when EV_in_AC_wasCast_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_in_AC_wasCast_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_in_AC_wasCast number(10) not null,
    constraint fkEV_in_AC_wasCast_Annex foreign key (
        EV_in_AC_wasCast_ID
    ) references public.EV_in_AC_wasCast_Posit(EV_in_AC_wasCast_ID),
    constraint pkEV_in_AC_wasCast_Annex primary key (
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_Positor,
        EV_in_AC_wasCast_PositedAt
    )
) CLUSTER BY (EV_in_AC_wasCast_ID, EV_in_AC_wasCast_Positor, EV_in_AC_wasCast_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_part_PR_in_RAT_got_Posit (
    AC_part_PR_in_RAT_got_ID number(10) IDENTITY(1,1) not null, 
    AC_ID_part number(10) not null, 
    PR_ID_in number(10) not null, 
    RAT_ID_got number(3) not null,
    AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
    constraint AC_part_PR_in_RAT_got_Posit_fkAC_part foreign key (
        AC_ID_part
    ) references public.AC_Actor(AC_ID),
    constraint AC_part_PR_in_RAT_got_Posit_fkPR_in foreign key (
        PR_ID_in
    ) references public.PR_Program(PR_ID),
    constraint AC_part_PR_in_RAT_got_Posit_fkRAT_got foreign key (
        RAT_ID_got
    ) references public.RAT_Rating(RAT_ID),
    constraint pkAC_part_PR_in_RAT_got_Posit primary key (
        AC_part_PR_in_RAT_got_ID
    ),
    constraint uqAC_part_PR_in_RAT_got unique (
        AC_ID_part,
        PR_ID_in,
        AC_part_PR_in_RAT_got_ChangedAt,
        RAT_ID_got
    )
) CLUSTER BY (
    AC_ID_part,
    PR_ID_in,
    AC_part_PR_in_RAT_got_ChangedAt
);

CREATE TABLE IF NOT EXISTS public.AC_part_PR_in_RAT_got_Annex (
    AC_part_PR_in_RAT_got_ID number(10) not null,
    AC_part_PR_in_RAT_got_PositedAt timestamp not null,
    AC_part_PR_in_RAT_got_Positor number(3) not null,
    AC_part_PR_in_RAT_got_Reliability number(5,2) not null,
    AC_part_PR_in_RAT_got_Assertion varchar2(4000) default (
        case
            when AC_part_PR_in_RAT_got_Reliability > 0 then '+'
            when AC_part_PR_in_RAT_got_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_part_PR_in_RAT_got_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_part_PR_in_RAT_got number(10) not null,
    constraint fkAC_part_PR_in_RAT_got_Annex foreign key (
        AC_part_PR_in_RAT_got_ID
    ) references public.AC_part_PR_in_RAT_got_Posit(AC_part_PR_in_RAT_got_ID),
    constraint pkAC_part_PR_in_RAT_got_Annex primary key (
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Positor,
        AC_part_PR_in_RAT_got_PositedAt
    )
) CLUSTER BY (AC_part_PR_in_RAT_got_ID, AC_part_PR_in_RAT_got_Positor, AC_part_PR_in_RAT_got_PositedAt);
CREATE TABLE IF NOT EXISTS public.ST_at_PR_isPlaying_Posit (
    ST_at_PR_isPlaying_ID number(10) IDENTITY(1,1) not null, 
    ST_ID_at number(10) not null, 
    PR_ID_isPlaying number(10) not null, 
    ST_at_PR_isPlaying_ChangedAt timestamp not null,
    constraint ST_at_PR_isPlaying_Posit_fkST_at foreign key (
        ST_ID_at
    ) references public.ST_Stage(ST_ID),
    constraint ST_at_PR_isPlaying_Posit_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references public.PR_Program(PR_ID),
    constraint pkST_at_PR_isPlaying_Posit primary key (
        ST_at_PR_isPlaying_ID
    ),
    constraint uqST_at_PR_isPlaying unique (
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    )
) CLUSTER BY (
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
);

CREATE TABLE IF NOT EXISTS public.ST_at_PR_isPlaying_Annex (
    ST_at_PR_isPlaying_ID number(10) not null,
    ST_at_PR_isPlaying_PositedAt timestamp not null,
    ST_at_PR_isPlaying_Positor number(3) not null,
    ST_at_PR_isPlaying_Reliability number(5,2) not null,
    ST_at_PR_isPlaying_Assertion varchar2(4000) default (
        case
            when ST_at_PR_isPlaying_Reliability > 0 then '+'
            when ST_at_PR_isPlaying_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_at_PR_isPlaying_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_at_PR_isPlaying number(10) not null,
    constraint fkST_at_PR_isPlaying_Annex foreign key (
        ST_at_PR_isPlaying_ID
    ) references public.ST_at_PR_isPlaying_Posit(ST_at_PR_isPlaying_ID),
    constraint pkST_at_PR_isPlaying_Annex primary key (
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_Positor,
        ST_at_PR_isPlaying_PositedAt
    )
) CLUSTER BY (ST_at_PR_isPlaying_ID, ST_at_PR_isPlaying_Positor, ST_at_PR_isPlaying_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_parent_AC_child_PAT_having_Posit (
    AC_parent_AC_child_PAT_having_ID number(10) IDENTITY(1,1) not null, 
    AC_ID_parent number(10) not null, 
    AC_ID_child number(10) not null, 
    PAT_ID_having number(3) not null,
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_parent foreign key (
        AC_ID_parent
    ) references public.AC_Actor(AC_ID),
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_child foreign key (
        AC_ID_child
    ) references public.AC_Actor(AC_ID),
    constraint AC_parent_AC_child_PAT_having_Posit_fkPAT_having foreign key (
        PAT_ID_having
    ) references public.PAT_ParentalType(PAT_ID),
    constraint pkAC_parent_AC_child_PAT_having_Posit primary key (
        AC_parent_AC_child_PAT_having_ID
    ),
    constraint uqAC_parent_AC_child_PAT_having unique (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
) CLUSTER BY (
    AC_ID_parent,
    AC_ID_child,
    PAT_ID_having
);

CREATE TABLE IF NOT EXISTS public.AC_parent_AC_child_PAT_having_Annex (
    AC_parent_AC_child_PAT_having_ID number(10) not null,
    AC_parent_AC_child_PAT_having_PositedAt timestamp not null,
    AC_parent_AC_child_PAT_having_Positor number(3) not null,
    AC_parent_AC_child_PAT_having_Reliability number(5,2) not null,
    AC_parent_AC_child_PAT_having_Assertion varchar2(4000) default (
        case
            when AC_parent_AC_child_PAT_having_Reliability > 0 then '+'
            when AC_parent_AC_child_PAT_having_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_parent_AC_child_PAT_having_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_parent_AC_child_PAT_having number(10) not null,
    constraint fkAC_parent_AC_child_PAT_having_Annex foreign key (
        AC_parent_AC_child_PAT_having_ID
    ) references public.AC_parent_AC_child_PAT_having_Posit(AC_parent_AC_child_PAT_having_ID),
    constraint pkAC_parent_AC_child_PAT_having_Annex primary key (
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_Positor,
        AC_parent_AC_child_PAT_having_PositedAt
    )
) CLUSTER BY (AC_parent_AC_child_PAT_having_ID, AC_parent_AC_child_PAT_having_Positor, AC_parent_AC_child_PAT_having_PositedAt);
CREATE TABLE IF NOT EXISTS public.PR_content_ST_location_EV_of_Posit (
    PR_content_ST_location_EV_of_ID number(10) IDENTITY(1,1) not null, 
    PR_ID_content number(10) not null, 
    ST_ID_location number(10) not null, 
    EV_ID_of number(10) not null, 
    constraint PR_content_ST_location_EV_of_Posit_fkPR_content foreign key (
        PR_ID_content
    ) references public.PR_Program(PR_ID),
    constraint PR_content_ST_location_EV_of_Posit_fkST_location foreign key (
        ST_ID_location
    ) references public.ST_Stage(ST_ID),
    constraint PR_content_ST_location_EV_of_Posit_fkEV_of foreign key (
        EV_ID_of
    ) references public.EV_Event(EV_ID),
    constraint pkPR_content_ST_location_EV_of_Posit primary key (
        PR_content_ST_location_EV_of_ID
    ),
    constraint uqPR_content_ST_location_EV_of unique (
        EV_ID_of,
        PR_ID_content,
        ST_ID_location
    )
) CLUSTER BY (
    EV_ID_of
);

CREATE TABLE IF NOT EXISTS public.PR_content_ST_location_EV_of_Annex (
    PR_content_ST_location_EV_of_ID number(10) not null,
    PR_content_ST_location_EV_of_PositedAt timestamp not null,
    PR_content_ST_location_EV_of_Positor number(3) not null,
    PR_content_ST_location_EV_of_Reliability number(5,2) not null,
    PR_content_ST_location_EV_of_Assertion varchar2(4000) default (
        case
            when PR_content_ST_location_EV_of_Reliability > 0 then '+'
            when PR_content_ST_location_EV_of_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when PR_content_ST_location_EV_of_Reliability <  then 0
            else 1
        end
    ),
    Metadata_PR_content_ST_location_EV_of number(10) not null,
    constraint fkPR_content_ST_location_EV_of_Annex foreign key (
        PR_content_ST_location_EV_of_ID
    ) references public.PR_content_ST_location_EV_of_Posit(PR_content_ST_location_EV_of_ID),
    constraint pkPR_content_ST_location_EV_of_Annex primary key (
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Positor,
        PR_content_ST_location_EV_of_PositedAt
    )
) CLUSTER BY (PR_content_ST_location_EV_of_ID, PR_content_ST_location_EV_of_Positor, PR_content_ST_location_EV_of_PositedAt);
-- TIE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views for ties.
--
CREATE OR REPLACE VIEW public.rAC_partner_AC_with_ONG_currently AS
SELECT
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Positor,
    a.AC_partner_AC_with_ONG_currently_Reliability,
    a.AC_partner_AC_with_ONG_currently_Assertion,
    a.
FROM
    public.AC_partner_AC_with_ONG_currently_Posit p
JOIN
    public.AC_partner_AC_with_ONG_currently_Annex a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
WHERE
    a.AC_partner_AC_with_ONG_currently_Positor = 0
AND
    a.AC_partner_AC_with_ONG_currently_PositedAt = (
        SELECT
            MAX(sub.AC_partner_AC_with_ONG_currently_PositedAt)
        FROM
            public.AC_partner_AC_with_ONG_currently_Annex sub
        WHERE
            sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
        AND
            sub.AC_partner_AC_with_ONG_currently_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rAC_subset_PN_of AS
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Positor,
    a.AC_subset_PN_of_Reliability,
    a.AC_subset_PN_of_Assertion,
    a.
FROM
    public.AC_subset_PN_of_Posit p
JOIN
    public.AC_subset_PN_of_Annex a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
WHERE
    a.AC_subset_PN_of_Positor = 0
AND
    a.AC_subset_PN_of_PositedAt = (
        SELECT
            MAX(sub.AC_subset_PN_of_PositedAt)
        FROM
            public.AC_subset_PN_of_Annex sub
        WHERE
            sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
        AND
            sub.AC_subset_PN_of_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rEV_in_AC_wasCast AS
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Positor,
    a.EV_in_AC_wasCast_Reliability,
    a.EV_in_AC_wasCast_Assertion,
    a.
FROM
    public.EV_in_AC_wasCast_Posit p
JOIN
    public.EV_in_AC_wasCast_Annex a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
WHERE
    a.EV_in_AC_wasCast_Positor = 0
AND
    a.EV_in_AC_wasCast_PositedAt = (
        SELECT
            MAX(sub.EV_in_AC_wasCast_PositedAt)
        FROM
            public.EV_in_AC_wasCast_Annex sub
        WHERE
            sub.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
        AND
            sub.EV_in_AC_wasCast_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rAC_part_PR_in_RAT_got AS
SELECT
    a.Metadata_AC_part_PR_in_RAT_got,
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Positor,
    a.AC_part_PR_in_RAT_got_Reliability,
    a.AC_part_PR_in_RAT_got_Assertion,
    a.
FROM
    public.AC_part_PR_in_RAT_got_Posit p
JOIN
    public.AC_part_PR_in_RAT_got_Annex a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
WHERE
    a.AC_part_PR_in_RAT_got_Positor = 0
AND
    a.AC_part_PR_in_RAT_got_PositedAt = (
        SELECT
            MAX(sub.AC_part_PR_in_RAT_got_PositedAt)
        FROM
            public.AC_part_PR_in_RAT_got_Annex sub
        WHERE
            sub.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
        AND
            sub.AC_part_PR_in_RAT_got_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rST_at_PR_isPlaying AS
SELECT
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Positor,
    a.ST_at_PR_isPlaying_Reliability,
    a.ST_at_PR_isPlaying_Assertion,
    a.
FROM
    public.ST_at_PR_isPlaying_Posit p
JOIN
    public.ST_at_PR_isPlaying_Annex a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
WHERE
    a.ST_at_PR_isPlaying_Positor = 0
AND
    a.ST_at_PR_isPlaying_PositedAt = (
        SELECT
            MAX(sub.ST_at_PR_isPlaying_PositedAt)
        FROM
            public.ST_at_PR_isPlaying_Annex sub
        WHERE
            sub.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
        AND
            sub.ST_at_PR_isPlaying_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rAC_parent_AC_child_PAT_having AS
SELECT
    a.Metadata_AC_parent_AC_child_PAT_having,
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Positor,
    a.AC_parent_AC_child_PAT_having_Reliability,
    a.AC_parent_AC_child_PAT_having_Assertion,
    a.
FROM
    public.AC_parent_AC_child_PAT_having_Posit p
JOIN
    public.AC_parent_AC_child_PAT_having_Annex a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
WHERE
    a.AC_parent_AC_child_PAT_having_Positor = 0
AND
    a.AC_parent_AC_child_PAT_having_PositedAt = (
        SELECT
            MAX(sub.AC_parent_AC_child_PAT_having_PositedAt)
        FROM
            public.AC_parent_AC_child_PAT_having_Annex sub
        WHERE
            sub.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
        AND
            sub.AC_parent_AC_child_PAT_having_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rPR_content_ST_location_EV_of AS
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Positor,
    a.PR_content_ST_location_EV_of_Reliability,
    a.PR_content_ST_location_EV_of_Assertion,
    a.
FROM
    public.PR_content_ST_location_EV_of_Posit p
JOIN
    public.PR_content_ST_location_EV_of_Annex a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
WHERE
    a.PR_content_ST_location_EV_of_Positor = 0
AND
    a.PR_content_ST_location_EV_of_PositedAt = (
        SELECT
            MAX(sub.PR_content_ST_location_EV_of_PositedAt)
        FROM
            public.PR_content_ST_location_EV_of_Annex sub
        WHERE
            sub.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
        AND
            sub.PR_content_ST_location_EV_of_Positor = 0
    )
;
-- ANCHOR CRT PERSPECTIVES --------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT anchors.
--
CREATE OR REPLACE VIEW public.lST_Stage AS
SELECT
    a.ST_ID,
    a.Metadata_ST,
    rNAM.ST_NAM_Stage_Name,
    rNAM.ST_NAM_ChangedAt,
    rNAM.ST_NAM_PositedAt,
    rNAM.ST_NAM_Positor,
    rNAM.ST_NAM_Reliability,
    rNAM.ST_NAM_Assertion,
    rNAM.,
    rLOC.ST_LOC_Stage_Location,
    rLOC.ST_LOC_PositedAt,
    rLOC.ST_LOC_Positor,
    rLOC.ST_LOC_Reliability,
    rLOC.ST_LOC_Assertion,
    rLOC.,
    rAVG.ST_AVG_UTL_ID,
    rAVG.ST_AVG_ChangedAt,
    rAVG.ST_AVG_PositedAt,
    rAVG.ST_AVG_Positor,
    rAVG.ST_AVG_Reliability,
    rAVG.ST_AVG_Assertion,
    rAVG.,
    rMIN.ST_MIN_UTL_ID,
    rMIN.ST_MIN_PositedAt,
    rMIN.ST_MIN_Positor,
    rMIN.ST_MIN_Reliability,
    rMIN.ST_MIN_Assertion,
    rMIN.
FROM
    public.ST_Stage a
LEFT JOIN
    public.rST_NAM_Stage_Name rNAM
ON
    rNAM.ST_NAM_ST_ID = a.ST_ID
LEFT JOIN
    public.rST_LOC_Stage_Location rLOC
ON
    rLOC.ST_LOC_ST_ID = a.ST_ID
LEFT JOIN
    public.rST_AVG_Stage_Average rAVG
ON
    rAVG.ST_AVG_ST_ID = a.ST_ID
LEFT JOIN
    public.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = rAVG.ST_AVG_UTL_ID
LEFT JOIN
    public.rST_MIN_Stage_Minimum rMIN
ON
    rMIN.ST_MIN_ST_ID = a.ST_ID
LEFT JOIN
    public.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = rMIN.ST_MIN_UTL_ID
;

CREATE OR REPLACE VIEW public.nST_Stage AS
SELECT
    *
FROM
    public.lST_Stage
;

CREATE OR REPLACE FUNCTION public.tST_Stage (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lST_Stage t
        WHERE
            (
                positor IS NULL
                OR (
                    t.ST_NAM_Positor = positor OR
                    t.ST_LOC_Positor = positor OR
                    t.ST_AVG_Positor = positor OR
                    t.ST_MIN_Positor = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.ST_NAM_Assertion = assertion OR
                    t.ST_LOC_Assertion = assertion OR
                    t.ST_AVG_Assertion = assertion OR
                    t.ST_MIN_Assertion = assertion 
                )
            )
        AND
            (
                changingTimepoint IS NULL
                OR (
                    t.ST_NAM_ChangedAt <= changingTimepoint OR
                    t.ST_AVG_ChangedAt <= changingTimepoint 
                )
            )
        AND
            (
                positingTimepoint IS NULL
                OR (
                    t.ST_NAM_PositedAt <= positingTimepoint OR
                    t.ST_LOC_PositedAt <= positingTimepoint OR
                    t.ST_AVG_PositedAt <= positingTimepoint OR
                    t.ST_MIN_PositedAt <= positingTimepoint 
                )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pST_Stage (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lST_Stage t
        WHERE
            (
                changingTimepoint IS NULL
                OR (
                    t.ST_NAM_ChangedAt <= changingTimepoint OR
                    t.ST_AVG_ChangedAt <= changingTimepoint 
            )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dST_Stage (
    intervalStart timestamp(9),
    intervalEnd timestamp(9),
    selection varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lST_Stage t
        WHERE
            (
                intervalStart IS NULL
                OR intervalEnd IS NULL
                OR (
                    t.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd OR
                    t.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd 
                )
            )
    ]';
END;
/
CREATE OR REPLACE VIEW public.lAC_Actor AS
SELECT
    a.AC_ID,
    a.Metadata_AC,
    rNAM.AC_NAM_Actor_Name,
    rNAM.AC_NAM_ChangedAt,
    rNAM.AC_NAM_PositedAt,
    rNAM.AC_NAM_Positor,
    rNAM.AC_NAM_Reliability,
    rNAM.AC_NAM_Assertion,
    rNAM.,
    rGEN.AC_GEN_GEN_ID,
    rGEN.AC_GEN_PositedAt,
    rGEN.AC_GEN_Positor,
    rGEN.AC_GEN_Reliability,
    rGEN.AC_GEN_Assertion,
    rGEN.,
    rPLV.AC_PLV_PLV_ID,
    rPLV.AC_PLV_ChangedAt,
    rPLV.AC_PLV_PositedAt,
    rPLV.AC_PLV_Positor,
    rPLV.AC_PLV_Reliability,
    rPLV.AC_PLV_Assertion,
    rPLV.
FROM
    public.AC_Actor a
LEFT JOIN
    public.rAC_NAM_Actor_Name rNAM
ON
    rNAM.AC_NAM_AC_ID = a.AC_ID
LEFT JOIN
    public.rAC_GEN_Actor_Gender rGEN
ON
    rGEN.AC_GEN_AC_ID = a.AC_ID
LEFT JOIN
    public.GEN_Gender kGEN
ON
    kGEN.GEN_ID = rGEN.AC_GEN_GEN_ID
LEFT JOIN
    public.rAC_PLV_Actor_ProfessionalLevel rPLV
ON
    rPLV.AC_PLV_AC_ID = a.AC_ID
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = rPLV.AC_PLV_PLV_ID
;

CREATE OR REPLACE VIEW public.nAC_Actor AS
SELECT
    *
FROM
    public.lAC_Actor
;

CREATE OR REPLACE FUNCTION public.tAC_Actor (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_Actor t
        WHERE
            (
                positor IS NULL
                OR (
                    t.AC_NAM_Positor = positor OR
                    t.AC_GEN_Positor = positor OR
                    t.AC_PLV_Positor = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.AC_NAM_Assertion = assertion OR
                    t.AC_GEN_Assertion = assertion OR
                    t.AC_PLV_Assertion = assertion 
                )
            )
        AND
            (
                changingTimepoint IS NULL
                OR (
                    t.AC_NAM_ChangedAt <= changingTimepoint OR
                    t.AC_PLV_ChangedAt <= changingTimepoint 
                )
            )
        AND
            (
                positingTimepoint IS NULL
                OR (
                    t.AC_NAM_PositedAt <= positingTimepoint OR
                    t.AC_GEN_PositedAt <= positingTimepoint OR
                    t.AC_PLV_PositedAt <= positingTimepoint 
                )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pAC_Actor (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_Actor t
        WHERE
            (
                changingTimepoint IS NULL
                OR (
                    t.AC_NAM_ChangedAt <= changingTimepoint OR
                    t.AC_PLV_ChangedAt <= changingTimepoint 
            )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dAC_Actor (
    intervalStart timestamp(9),
    intervalEnd timestamp(9),
    selection varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_Actor t
        WHERE
            (
                intervalStart IS NULL
                OR intervalEnd IS NULL
                OR (
                    t.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd OR
                    t.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd 
                )
            )
    ]';
END;
/
CREATE OR REPLACE VIEW public.lPR_Program AS
SELECT
    a.PR_ID,
    a.Metadata_PR,
    rNAM.PR_NAM_Program_Name,
    rNAM.PR_NAM_PositedAt,
    rNAM.PR_NAM_Positor,
    rNAM.PR_NAM_Reliability,
    rNAM.PR_NAM_Assertion,
    rNAM.,
    rLEN.PR_LEN_Program_Length,
    rLEN.PR_LEN_ChangedAt,
    rLEN.PR_LEN_PositedAt,
    rLEN.PR_LEN_Positor,
    rLEN.PR_LEN_Reliability,
    rLEN.PR_LEN_Assertion,
    rLEN.
FROM
    public.PR_Program a
LEFT JOIN
    public.rPR_NAM_Program_Name rNAM
ON
    rNAM.PR_NAM_PR_ID = a.PR_ID
LEFT JOIN
    public.rPR_LEN_Program_Length rLEN
ON
    rLEN.PR_LEN_PR_ID = a.PR_ID
;

CREATE OR REPLACE VIEW public.nPR_Program AS
SELECT
    *
FROM
    public.lPR_Program
;

CREATE OR REPLACE FUNCTION public.tPR_Program (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lPR_Program t
        WHERE
            (
                positor IS NULL
                OR (
                    t.PR_NAM_Positor = positor OR
                    t.PR_LEN_Positor = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.PR_NAM_Assertion = assertion OR
                    t.PR_LEN_Assertion = assertion 
                )
            )
        AND
            (
                changingTimepoint IS NULL
                OR (
                    t.PR_LEN_ChangedAt <= changingTimepoint 
                )
            )
        AND
            (
                positingTimepoint IS NULL
                OR (
                    t.PR_NAM_PositedAt <= positingTimepoint OR
                    t.PR_LEN_PositedAt <= positingTimepoint 
                )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pPR_Program (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lPR_Program t
        WHERE
            (
                changingTimepoint IS NULL
                OR (
                    t.PR_LEN_ChangedAt <= changingTimepoint 
            )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dPR_Program (
    intervalStart timestamp(9),
    intervalEnd timestamp(9),
    selection varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lPR_Program t
        WHERE
            (
                intervalStart IS NULL
                OR intervalEnd IS NULL
                OR (
                    t.PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd 
                )
            )
    ]';
END;
/
-- NEXUS CRT PERSPECTIVES ---------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT nexuses.
--
CREATE OR REPLACE VIEW public.lEV_Event AS
SELECT
    n.EV_ID,
    n.Metadata_EV,
    n.ST_ID_wasHeldAt,
    n.PR_ID_wasPlayed,
    n.ETY_ID_of,
    rDAT.EV_DAT_Event_Date,
    rDAT.EV_DAT_PositedAt,
    rDAT.EV_DAT_Positor,
    rDAT.EV_DAT_Reliability,
    rDAT.EV_DAT_Assertion,
    rDAT.,
    rAUD.EV_AUD_Event_Audience,
    rAUD.EV_AUD_PositedAt,
    rAUD.EV_AUD_Positor,
    rAUD.EV_AUD_Reliability,
    rAUD.EV_AUD_Assertion,
    rAUD.,
    rREV.EV_REV_Event_Revenue,
    rREV.EV_REV_PositedAt,
    rREV.EV_REV_Positor,
    rREV.EV_REV_Reliability,
    rREV.EV_REV_Assertion,
    rREV.
FROM
    public.EV_Event n
LEFT JOIN
    public.rEV_DAT_Event_Date rDAT
ON
    rDAT.EV_DAT_EV_ID = n.EV_ID
LEFT JOIN
    public.rEV_AUD_Event_Audience rAUD
ON
    rAUD.EV_AUD_EV_ID = n.EV_ID
LEFT JOIN
    public.rEV_REV_Event_Revenue rREV
ON
    rREV.EV_REV_EV_ID = n.EV_ID
;

CREATE OR REPLACE VIEW public.nEV_Event AS
SELECT
    *
FROM
    public.lEV_Event
;

CREATE OR REPLACE FUNCTION public.tEV_Event (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lEV_Event t
        WHERE
            (
                positor IS NULL
                OR (
                    t.EV_DAT_Positor = positor OR
                    t.EV_AUD_Positor = positor OR
                    t.EV_REV_Positor = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.EV_DAT_Assertion = assertion OR
                    t.EV_AUD_Assertion = assertion OR
                    t.EV_REV_Assertion = assertion 
                )
            )
        AND
            (
                changingTimepoint IS NULL
                OR 1 = 1
            )
        AND
            (
                positingTimepoint IS NULL
                OR (
                    t.EV_DAT_PositedAt <= positingTimepoint OR
                    t.EV_AUD_PositedAt <= positingTimepoint OR
                    t.EV_REV_PositedAt <= positingTimepoint 
                )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pEV_Event (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lEV_Event t
        WHERE
            (
                changingTimepoint IS NULL
                OR 1 = 1
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dEV_Event (
    intervalStart timestamp(9),
    intervalEnd timestamp(9),
    selection varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lEV_Event t
        WHERE
            (
                intervalStart IS NULL
                OR intervalEnd IS NULL
                OR 1 = 1
            )
    ]';
END;
/
-- TIE CRT PERSPECTIVES -----------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT ties.
--
CREATE OR REPLACE VIEW public.lAC_partner_AC_with_ONG_currently AS
SELECT
    r.AC_partner_AC_with_ONG_currently_ID,
    r.Metadata_AC_partner_AC_with_ONG_currently,
    r.AC_ID_partner,
    r.AC_ID_with,
    kONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    r.ONG_ID_currently
    r.AC_partner_AC_with_ONG_currently_ChangedAt,
    r.AC_partner_AC_with_ONG_currently_PositedAt,
    r.AC_partner_AC_with_ONG_currently_Positor,
    r.AC_partner_AC_with_ONG_currently_Reliability,
    r.AC_partner_AC_with_ONG_currently_Assertion,
    r.
FROM
    public.rAC_partner_AC_with_ONG_currently r
LEFT JOIN
    public.ONG_Ongoing kONG_currently
ON
    kONG_currently.ONG_ID = r.ONG_ID_currently
;

CREATE OR REPLACE VIEW public.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    public.lAC_partner_AC_with_ONG_currently
;

CREATE OR REPLACE FUNCTION public.tAC_partner_AC_with_ONG_currently (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_partner_AC_with_ONG_currently t
        WHERE
            (positor IS NULL OR t.AC_partner_AC_with_ONG_currently_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_partner_AC_with_ONG_currently_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_partner_AC_with_ONG_currently t
        WHERE
            (changingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_partner_AC_with_ONG_currently t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW public.lAC_subset_PN_of AS
SELECT
    r.AC_subset_PN_of_ID,
    r.Metadata_AC_subset_PN_of,
    r.AC_ID_subset,
    r.PN_ID_of
    r.AC_subset_PN_of_PositedAt,
    r.AC_subset_PN_of_Positor,
    r.AC_subset_PN_of_Reliability,
    r.AC_subset_PN_of_Assertion,
    r.
FROM
    public.rAC_subset_PN_of r
;

CREATE OR REPLACE VIEW public.nAC_subset_PN_of AS
SELECT
    *
FROM
    public.lAC_subset_PN_of
;

CREATE OR REPLACE FUNCTION public.tAC_subset_PN_of (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_subset_PN_of t
        WHERE
            (positor IS NULL OR t.AC_subset_PN_of_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_subset_PN_of_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.AC_subset_PN_of_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pAC_subset_PN_of (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_subset_PN_of t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dAC_subset_PN_of (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_subset_PN_of t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW public.lEV_in_AC_wasCast AS
SELECT
    r.EV_in_AC_wasCast_ID,
    r.Metadata_EV_in_AC_wasCast,
    r.EV_ID_in,
    r.AC_ID_wasCast
    r.EV_in_AC_wasCast_PositedAt,
    r.EV_in_AC_wasCast_Positor,
    r.EV_in_AC_wasCast_Reliability,
    r.EV_in_AC_wasCast_Assertion,
    r.
FROM
    public.rEV_in_AC_wasCast r
;

CREATE OR REPLACE VIEW public.nEV_in_AC_wasCast AS
SELECT
    *
FROM
    public.lEV_in_AC_wasCast
;

CREATE OR REPLACE FUNCTION public.tEV_in_AC_wasCast (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lEV_in_AC_wasCast t
        WHERE
            (positor IS NULL OR t.EV_in_AC_wasCast_Positor = positor)
        AND
            (assertion IS NULL OR t.EV_in_AC_wasCast_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.EV_in_AC_wasCast_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pEV_in_AC_wasCast (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lEV_in_AC_wasCast t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dEV_in_AC_wasCast (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lEV_in_AC_wasCast t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got AS
SELECT
    r.AC_part_PR_in_RAT_got_ID,
    r.Metadata_AC_part_PR_in_RAT_got,
    r.AC_ID_part,
    r.PR_ID_in,
    kRAT_got.RAT_Rating AS got_RAT_Rating,
    r.RAT_ID_got
    r.AC_part_PR_in_RAT_got_ChangedAt,
    r.AC_part_PR_in_RAT_got_PositedAt,
    r.AC_part_PR_in_RAT_got_Positor,
    r.AC_part_PR_in_RAT_got_Reliability,
    r.AC_part_PR_in_RAT_got_Assertion,
    r.
FROM
    public.rAC_part_PR_in_RAT_got r
LEFT JOIN
    public.RAT_Rating kRAT_got
ON
    kRAT_got.RAT_ID = r.RAT_ID_got
;

CREATE OR REPLACE VIEW public.nAC_part_PR_in_RAT_got AS
SELECT
    *
FROM
    public.lAC_part_PR_in_RAT_got
;

CREATE OR REPLACE FUNCTION public.tAC_part_PR_in_RAT_got (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_part_PR_in_RAT_got t
        WHERE
            (positor IS NULL OR t.AC_part_PR_in_RAT_got_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_part_PR_in_RAT_got_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_part_PR_in_RAT_got t
        WHERE
            (changingTimepoint IS NULL OR t.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dAC_part_PR_in_RAT_got (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_part_PR_in_RAT_got t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW public.lST_at_PR_isPlaying AS
SELECT
    r.ST_at_PR_isPlaying_ID,
    r.Metadata_ST_at_PR_isPlaying,
    r.ST_ID_at,
    r.PR_ID_isPlaying
    r.ST_at_PR_isPlaying_ChangedAt,
    r.ST_at_PR_isPlaying_PositedAt,
    r.ST_at_PR_isPlaying_Positor,
    r.ST_at_PR_isPlaying_Reliability,
    r.ST_at_PR_isPlaying_Assertion,
    r.
FROM
    public.rST_at_PR_isPlaying r
;

CREATE OR REPLACE VIEW public.nST_at_PR_isPlaying AS
SELECT
    *
FROM
    public.lST_at_PR_isPlaying
;

CREATE OR REPLACE FUNCTION public.tST_at_PR_isPlaying (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lST_at_PR_isPlaying t
        WHERE
            (positor IS NULL OR t.ST_at_PR_isPlaying_Positor = positor)
        AND
            (assertion IS NULL OR t.ST_at_PR_isPlaying_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.ST_at_PR_isPlaying_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pST_at_PR_isPlaying (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lST_at_PR_isPlaying t
        WHERE
            (changingTimepoint IS NULL OR t.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dST_at_PR_isPlaying (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lST_at_PR_isPlaying t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW public.lAC_parent_AC_child_PAT_having AS
SELECT
    r.AC_parent_AC_child_PAT_having_ID,
    r.Metadata_AC_parent_AC_child_PAT_having,
    r.AC_ID_parent,
    r.AC_ID_child,
    kPAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    r.PAT_ID_having
    r.AC_parent_AC_child_PAT_having_PositedAt,
    r.AC_parent_AC_child_PAT_having_Positor,
    r.AC_parent_AC_child_PAT_having_Reliability,
    r.AC_parent_AC_child_PAT_having_Assertion,
    r.
FROM
    public.rAC_parent_AC_child_PAT_having r
LEFT JOIN
    public.PAT_ParentalType kPAT_having
ON
    kPAT_having.PAT_ID = r.PAT_ID_having
;

CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having AS
SELECT
    *
FROM
    public.lAC_parent_AC_child_PAT_having
;

CREATE OR REPLACE FUNCTION public.tAC_parent_AC_child_PAT_having (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_parent_AC_child_PAT_having t
        WHERE
            (positor IS NULL OR t.AC_parent_AC_child_PAT_having_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_parent_AC_child_PAT_having_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_parent_AC_child_PAT_having t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dAC_parent_AC_child_PAT_having (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lAC_parent_AC_child_PAT_having t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW public.lPR_content_ST_location_EV_of AS
SELECT
    r.PR_content_ST_location_EV_of_ID,
    r.Metadata_PR_content_ST_location_EV_of,
    r.PR_ID_content,
    r.ST_ID_location,
    r.EV_ID_of
    r.PR_content_ST_location_EV_of_PositedAt,
    r.PR_content_ST_location_EV_of_Positor,
    r.PR_content_ST_location_EV_of_Reliability,
    r.PR_content_ST_location_EV_of_Assertion,
    r.
FROM
    public.rPR_content_ST_location_EV_of r
;

CREATE OR REPLACE VIEW public.nPR_content_ST_location_EV_of AS
SELECT
    *
FROM
    public.lPR_content_ST_location_EV_of
;

CREATE OR REPLACE FUNCTION public.tPR_content_ST_location_EV_of (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lPR_content_ST_location_EV_of t
        WHERE
            (positor IS NULL OR t.PR_content_ST_location_EV_of_Positor = positor)
        AND
            (assertion IS NULL OR t.PR_content_ST_location_EV_of_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lPR_content_ST_location_EV_of t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dPR_content_ST_location_EV_of (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lPR_content_ST_location_EV_of t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
