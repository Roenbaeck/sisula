-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public._Positor (
    Positor tinyint not null,
    constraint pk_Positor primary key (
        Positor
    ) RELY
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
    PAT_ID tinyint not null,
    PAT_ParentalType varchar(42) not null,
    Metadata_PAT int not null,
    constraint pkPAT_ParentalType primary key (
        PAT_ID 
    ) RELY,
    constraint uqPAT_ParentalType unique (
        PAT_ParentalType
    ) RELY
) CLUSTER BY (PAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.GEN_Gender (
    GEN_ID number(1,0) not null,
    GEN_Gender varchar(42) not null,
    Metadata_GEN int not null,
    constraint pkGEN_Gender primary key (
        GEN_ID 
    ) RELY,
    constraint uqGEN_Gender unique (
        GEN_Gender
    ) RELY
) CLUSTER BY (GEN_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PLV_ProfessionalLevel (
    PLV_ID tinyint not null,
    PLV_ProfessionalLevel string not null,
    PLV_Checksum numeric(19,0) default hash(PLV_ProfessionalLevel),
    Metadata_PLV int not null,
    constraint pkPLV_ProfessionalLevel primary key (
        PLV_ID 
    ) RELY,
    constraint uqPLV_ProfessionalLevel unique (
        PLV_Checksum 
    ) RELY
) CLUSTER BY (PLV_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.UTL_Utilization (
    UTL_ID tinyint not null,
    UTL_Utilization tinyint not null,
    Metadata_UTL int not null,
    constraint pkUTL_Utilization primary key (
        UTL_ID 
    ) RELY,
    constraint uqUTL_Utilization unique (
        UTL_Utilization
    ) RELY
) CLUSTER BY (UTL_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ONG_Ongoing (
    ONG_ID tinyint not null,
    ONG_Ongoing varchar(3) not null,
    Metadata_ONG int not null,
    constraint pkONG_Ongoing primary key (
        ONG_ID 
    ) RELY,
    constraint uqONG_Ongoing unique (
        ONG_Ongoing
    ) RELY
) CLUSTER BY (ONG_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.RAT_Rating (
    RAT_ID tinyint not null,
    RAT_Rating varchar(42) not null,
    Metadata_RAT int not null,
    constraint pkRAT_Rating primary key (
        RAT_ID 
    ) RELY,
    constraint uqRAT_Rating unique (
        RAT_Rating
    ) RELY
) CLUSTER BY (RAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ETY_EventType (
    ETY_ID tinyint not null,
    ETY_EventType varchar(42) not null,
    Metadata_ETY int not null,
    constraint pkETY_EventType primary key (
        ETY_ID 
    ) RELY,
    constraint uqETY_EventType unique (
        ETY_EventType
    ) RELY
) CLUSTER BY (ETY_ID);
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.PN_Person_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PN_Person (
    PN_ID int default public.PN_Person_ID_SEQ.nextval not null, 
    Metadata_PN int not null,
    constraint pkPN_Person primary key (
        PN_ID
    ) RELY
) CLUSTER BY (PN_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.ST_Stage_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.ST_Stage (
    ST_ID int default public.ST_Stage_ID_SEQ.nextval not null, 
    Metadata_ST int not null,
    constraint pkST_Stage primary key (
        ST_ID
    ) RELY
) CLUSTER BY (ST_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.AC_Actor_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.AC_Actor (
    AC_ID int default public.AC_Actor_ID_SEQ.nextval not null, 
    Metadata_AC int not null,
    constraint pkAC_Actor primary key (
        AC_ID
    ) RELY
) CLUSTER BY (AC_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.PR_Program_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PR_Program (
    PR_ID int default public.PR_Program_ID_SEQ.nextval not null, 
    Metadata_PR int not null,
    constraint pkPR_Program primary key (
        PR_ID
    ) RELY
) CLUSTER BY (PR_ID);
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 3 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.EV_Event_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.EV_Event (
    EV_ID int default public.EV_Event_ID_SEQ.nextval not null, 
    ST_ID_wasHeldAt int not null, 
    PR_ID_wasPlayed int not null, 
    ETY_ID_of tinyint not null,
    constraint EV_Event_fkST_wasHeldAt foreign key (
        ST_ID_wasHeldAt
    ) references public.ST_Stage(ST_ID) RELY, 
    constraint EV_Event_fkPR_wasPlayed foreign key (
        PR_ID_wasPlayed
    ) references public.PR_Program(PR_ID) RELY, 
    constraint EV_Event_fkETY_of foreign key (
        ETY_ID_of
    ) references public.ETY_EventType(ETY_ID) RELY,
    Metadata_EV int not null, 
    constraint pkEV_Event primary key (
        EV_ID
    ) RELY
) CLUSTER BY (EV_ID);
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.EV_DAT_Event_Date_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.EV_DAT_Event_Date_Posit (
    EV_DAT_ID int default public.EV_DAT_Event_Date_Posit_ID_SEQ.nextval not null, 
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
CREATE SEQUENCE IF NOT EXISTS public.EV_AUD_Event_Audience_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.EV_AUD_Event_Audience_Posit (
    EV_AUD_ID int default public.EV_AUD_Event_Audience_Posit_ID_SEQ.nextval not null, 
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
CREATE SEQUENCE IF NOT EXISTS public.EV_REV_Event_Revenue_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.EV_REV_Event_Revenue_Posit (
    EV_REV_ID int default public.EV_REV_Event_Revenue_Posit_ID_SEQ.nextval not null, 
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
CREATE SEQUENCE IF NOT EXISTS public.ST_NAM_Stage_Name_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.ST_NAM_Stage_Name_Posit (
    ST_NAM_ID int default public.ST_NAM_Stage_Name_Posit_ID_SEQ.nextval not null, 
    ST_NAM_ST_ID int not null,
    ST_NAM_Stage_Name varchar(42) not null,
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
        ST_NAM_Stage_Name
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
CREATE SEQUENCE IF NOT EXISTS public.ST_LOC_Stage_Location_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.ST_LOC_Stage_Location_Posit (
    ST_LOC_ID int default public.ST_LOC_Stage_Location_Posit_ID_SEQ.nextval not null, 
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
CREATE SEQUENCE IF NOT EXISTS public.ST_AVG_Stage_Average_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.ST_AVG_Stage_Average_Posit (
    ST_AVG_ID int default public.ST_AVG_Stage_Average_Posit_ID_SEQ.nextval not null, 
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
CREATE SEQUENCE IF NOT EXISTS public.ST_MIN_Stage_Minimum_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.ST_MIN_Stage_Minimum_Posit (
    ST_MIN_ID int default public.ST_MIN_Stage_Minimum_Posit_ID_SEQ.nextval not null, 
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
CREATE SEQUENCE IF NOT EXISTS public.AC_NAM_Actor_Name_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.AC_NAM_Actor_Name_Posit (
    AC_NAM_ID int default public.AC_NAM_Actor_Name_Posit_ID_SEQ.nextval not null, 
    AC_NAM_AC_ID int not null,
    AC_NAM_Actor_Name varchar(42) not null,
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
        AC_NAM_Actor_Name
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
CREATE SEQUENCE IF NOT EXISTS public.AC_GEN_Actor_Gender_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.AC_GEN_Actor_Gender_Posit (
    AC_GEN_ID int default public.AC_GEN_Actor_Gender_Posit_ID_SEQ.nextval not null, 
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
CREATE SEQUENCE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel_Posit (
    AC_PLV_ID int default public.AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ.nextval not null, 
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
CREATE SEQUENCE IF NOT EXISTS public.PR_NAM_Program_Name_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PR_NAM_Program_Name_Posit (
    PR_NAM_ID int default public.PR_NAM_Program_Name_Posit_ID_SEQ.nextval not null, 
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
CREATE SEQUENCE IF NOT EXISTS public.PR_LEN_Program_Length_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PR_LEN_Program_Length_Posit (
    PR_LEN_ID int default public.PR_LEN_Program_Length_Posit_ID_SEQ.nextval not null, 
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
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public.EV_DAT_Event_Date COPY GRANTS AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Positor,
    a.EV_DAT_Reliability,
    a.EV_DAT_Assertion
FROM
    public.EV_DAT_Event_Date_Posit p
JOIN
    public.EV_DAT_Event_Date_Annex a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
;
CREATE OR REPLACE VIEW public.EV_AUD_Event_Audience COPY GRANTS AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Positor,
    a.EV_AUD_Reliability,
    a.EV_AUD_Assertion
FROM
    public.EV_AUD_Event_Audience_Posit p
JOIN
    public.EV_AUD_Event_Audience_Annex a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
;
CREATE OR REPLACE VIEW public.EV_REV_Event_Revenue COPY GRANTS AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue,
    a.EV_REV_PositedAt,
    a.EV_REV_Positor,
    a.EV_REV_Reliability,
    a.EV_REV_Assertion
FROM
    public.EV_REV_Event_Revenue_Posit p
JOIN
    public.EV_REV_Event_Revenue_Annex a
ON
    a.EV_REV_ID = p.EV_REV_ID
;
CREATE OR REPLACE VIEW public.ST_NAM_Stage_Name COPY GRANTS AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Positor,
    a.ST_NAM_Reliability,
    a.ST_NAM_Assertion
FROM
    public.ST_NAM_Stage_Name_Posit p
JOIN
    public.ST_NAM_Stage_Name_Annex a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
;
CREATE OR REPLACE VIEW public.ST_LOC_Stage_Location COPY GRANTS AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Positor,
    a.ST_LOC_Reliability,
    a.ST_LOC_Assertion
FROM
    public.ST_LOC_Stage_Location_Posit p
JOIN
    public.ST_LOC_Stage_Location_Annex a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
;
CREATE OR REPLACE VIEW public.ST_AVG_Stage_Average COPY GRANTS AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Positor,
    a.ST_AVG_Reliability,
    a.ST_AVG_Assertion
FROM
    public.ST_AVG_Stage_Average_Posit p
JOIN
    public.ST_AVG_Stage_Average_Annex a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
;
CREATE OR REPLACE VIEW public.ST_MIN_Stage_Minimum COPY GRANTS AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Positor,
    a.ST_MIN_Reliability,
    a.ST_MIN_Assertion
FROM
    public.ST_MIN_Stage_Minimum_Posit p
JOIN
    public.ST_MIN_Stage_Minimum_Annex a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
;
CREATE OR REPLACE VIEW public.AC_NAM_Actor_Name COPY GRANTS AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Positor,
    a.AC_NAM_Reliability,
    a.AC_NAM_Assertion
FROM
    public.AC_NAM_Actor_Name_Posit p
JOIN
    public.AC_NAM_Actor_Name_Annex a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
;
CREATE OR REPLACE VIEW public.AC_GEN_Actor_Gender COPY GRANTS AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Positor,
    a.AC_GEN_Reliability,
    a.AC_GEN_Assertion
FROM
    public.AC_GEN_Actor_Gender_Posit p
JOIN
    public.AC_GEN_Actor_Gender_Annex a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
;
CREATE OR REPLACE VIEW public.AC_PLV_Actor_ProfessionalLevel COPY GRANTS AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Positor,
    a.AC_PLV_Reliability,
    a.AC_PLV_Assertion
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit p
JOIN
    public.AC_PLV_Actor_ProfessionalLevel_Annex a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
;
CREATE OR REPLACE VIEW public.PR_NAM_Program_Name COPY GRANTS AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Positor,
    a.PR_NAM_Reliability,
    a.PR_NAM_Assertion
FROM
    public.PR_NAM_Program_Name_Posit p
JOIN
    public.PR_NAM_Program_Name_Annex a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
;
CREATE OR REPLACE VIEW public.PR_LEN_Program_Length COPY GRANTS AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Positor,
    a.PR_LEN_Reliability,
    a.PR_LEN_Assertion
FROM
    public.PR_LEN_Program_Length_Posit p
JOIN
    public.PR_LEN_Program_Length_Annex a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the 
-- union of the two will produce all rows in a posit table.
--
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_DAT_Event_Date_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string
)
AS
$$
SELECT
    Metadata_EV_DAT,
    EV_DAT_ID,
    EV_DAT_PositedAt,
    EV_DAT_Positor,
    EV_DAT_Reliability,
    EV_DAT_Assertion
FROM
    public.EV_DAT_Event_Date_Annex
WHERE
    EV_DAT_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_DAT_Event_Date (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string,
    EV_DAT_EV_ID int,
    EV_DAT_Event_Date datetime
)
AS
$$
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Positor,
    a.EV_DAT_Reliability,
    a.EV_DAT_Assertion,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date
FROM
    public.EV_DAT_Event_Date_Posit p
JOIN
    TABLE(public.rEV_DAT_Event_Date_Annex(positingTimepoint)) a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
AND
    a.EV_DAT_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_DAT_ID
        ORDER BY a.EV_DAT_PositedAt DESC
    ) = 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_AUD_Event_Audience_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string
)
AS
$$
SELECT
    Metadata_EV_AUD,
    EV_AUD_ID,
    EV_AUD_PositedAt,
    EV_AUD_Positor,
    EV_AUD_Reliability,
    EV_AUD_Assertion
FROM
    public.EV_AUD_Event_Audience_Annex
WHERE
    EV_AUD_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_AUD_Event_Audience (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string,
    EV_AUD_EV_ID int,
    EV_AUD_Event_Audience int
)
AS
$$
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Positor,
    a.EV_AUD_Reliability,
    a.EV_AUD_Assertion,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience
FROM
    public.EV_AUD_Event_Audience_Posit p
JOIN
    TABLE(public.rEV_AUD_Event_Audience_Annex(positingTimepoint)) a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
AND
    a.EV_AUD_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_AUD_ID
        ORDER BY a.EV_AUD_PositedAt DESC
    ) = 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_REV_Event_Revenue_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string
)
AS
$$
SELECT
    Metadata_EV_REV,
    EV_REV_ID,
    EV_REV_PositedAt,
    EV_REV_Positor,
    EV_REV_Reliability,
    EV_REV_Assertion
FROM
    public.EV_REV_Event_Revenue_Annex
WHERE
    EV_REV_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_REV_Event_Revenue (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string,
    EV_REV_EV_ID int,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    a.EV_REV_PositedAt,
    a.EV_REV_Positor,
    a.EV_REV_Reliability,
    a.EV_REV_Assertion,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue
FROM
    public.EV_REV_Event_Revenue_Posit p
JOIN
    TABLE(public.rEV_REV_Event_Revenue_Annex(positingTimepoint)) a
ON
    a.EV_REV_ID = p.EV_REV_ID
AND
    a.EV_REV_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_REV_ID
        ORDER BY a.EV_REV_PositedAt DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_NAM_ID int,
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
    public.ST_NAM_Stage_Name_Posit
WHERE
    ST_NAM_ChangedAt <= changingTimepoint
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fST_NAM_Stage_Name_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_NAM_ID int,
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
    public.ST_NAM_Stage_Name_Posit
WHERE
    ST_NAM_ChangedAt > changingTimepoint
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Positor tinyint,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Assertion string
)
AS
$$
SELECT
    Metadata_ST_NAM,
    ST_NAM_ID,
    ST_NAM_PositedAt,
    ST_NAM_Positor,
    ST_NAM_Reliability,
    ST_NAM_Assertion
FROM
    public.ST_NAM_Stage_Name_Annex
WHERE
    ST_NAM_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Positor tinyint,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Assertion string,
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
    a.ST_NAM_Positor,
    a.ST_NAM_Reliability,
    a.ST_NAM_Assertion,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt
FROM
    TABLE(public.rST_NAM_Stage_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_NAM_Stage_Name_Annex(positingTimepoint)) a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
AND
    a.ST_NAM_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_NAM_ID
        ORDER BY a.ST_NAM_PositedAt DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fST_NAM_Stage_Name (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Positor tinyint,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Assertion string,
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
    a.ST_NAM_Positor,
    a.ST_NAM_Reliability,
    a.ST_NAM_Assertion,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt
FROM
    TABLE(public.fST_NAM_Stage_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_NAM_Stage_Name_Annex(positingTimepoint)) a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
AND
    a.ST_NAM_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_NAM_ID
        ORDER BY a.ST_NAM_PositedAt DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.preST_NAM_Stage_Name (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    pre.ST_NAM_Stage_Name
FROM
    TABLE(public.rST_NAM_Stage_Name(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre.ST_NAM_ST_ID = id
AND
    pre.ST_NAM_ChangedAt < changingTimepoint
AND
    pre.ST_NAM_Assertion = coalesce(assertion, pre.ST_NAM_Assertion)
ORDER BY
    pre.ST_NAM_ChangedAt DESC,
    pre.ST_NAM_PositedAt DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.folST_NAM_Stage_Name (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    fol.ST_NAM_Stage_Name
FROM
    TABLE(public.fST_NAM_Stage_Name(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol.ST_NAM_ST_ID = id
AND
    fol.ST_NAM_ChangedAt > changingTimepoint
AND
    fol.ST_NAM_Assertion = coalesce(assertion, fol.ST_NAM_Assertion)
ORDER BY
    fol.ST_NAM_ChangedAt ASC,
    fol.ST_NAM_PositedAt DESC
LIMIT 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_LOC_Stage_Location_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_LOC int,
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Positor tinyint,
    ST_LOC_Reliability decimal(5,2),
    ST_LOC_Assertion string
)
AS
$$
SELECT
    Metadata_ST_LOC,
    ST_LOC_ID,
    ST_LOC_PositedAt,
    ST_LOC_Positor,
    ST_LOC_Reliability,
    ST_LOC_Assertion
FROM
    public.ST_LOC_Stage_Location_Annex
WHERE
    ST_LOC_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_LOC_Stage_Location (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_LOC int,
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Positor tinyint,
    ST_LOC_Reliability decimal(5,2),
    ST_LOC_Assertion string,
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
    a.ST_LOC_Positor,
    a.ST_LOC_Reliability,
    a.ST_LOC_Assertion,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location
FROM
    public.ST_LOC_Stage_Location_Posit p
JOIN
    TABLE(public.rST_LOC_Stage_Location_Annex(positingTimepoint)) a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
AND
    a.ST_LOC_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_LOC_ID
        ORDER BY a.ST_LOC_PositedAt DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_AVG_ID int,
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
    public.ST_AVG_Stage_Average_Posit
WHERE
    ST_AVG_ChangedAt <= changingTimepoint
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fST_AVG_Stage_Average_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_AVG_ID int,
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
    public.ST_AVG_Stage_Average_Posit
WHERE
    ST_AVG_ChangedAt > changingTimepoint
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Positor tinyint,
    ST_AVG_Reliability decimal(5,2),
    ST_AVG_Assertion string
)
AS
$$
SELECT
    Metadata_ST_AVG,
    ST_AVG_ID,
    ST_AVG_PositedAt,
    ST_AVG_Positor,
    ST_AVG_Reliability,
    ST_AVG_Assertion
FROM
    public.ST_AVG_Stage_Average_Annex
WHERE
    ST_AVG_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Positor tinyint,
    ST_AVG_Reliability decimal(5,2),
    ST_AVG_Assertion string,
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
    a.ST_AVG_Positor,
    a.ST_AVG_Reliability,
    a.ST_AVG_Assertion,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt
FROM
    TABLE(public.rST_AVG_Stage_Average_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_AVG_Stage_Average_Annex(positingTimepoint)) a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
AND
    a.ST_AVG_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_AVG_ID
        ORDER BY a.ST_AVG_PositedAt DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fST_AVG_Stage_Average (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Positor tinyint,
    ST_AVG_Reliability decimal(5,2),
    ST_AVG_Assertion string,
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
    a.ST_AVG_Positor,
    a.ST_AVG_Reliability,
    a.ST_AVG_Assertion,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt
FROM
    TABLE(public.fST_AVG_Stage_Average_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_AVG_Stage_Average_Annex(positingTimepoint)) a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
AND
    a.ST_AVG_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_AVG_ID
        ORDER BY a.ST_AVG_PositedAt DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.preST_AVG_Stage_Average (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    pre.ST_AVG_UTL_ID
FROM
    TABLE(public.rST_AVG_Stage_Average(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre.ST_AVG_ST_ID = id
AND
    pre.ST_AVG_ChangedAt < changingTimepoint
AND
    pre.ST_AVG_Assertion = coalesce(assertion, pre.ST_AVG_Assertion)
ORDER BY
    pre.ST_AVG_ChangedAt DESC,
    pre.ST_AVG_PositedAt DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.folST_AVG_Stage_Average (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    fol.ST_AVG_UTL_ID
FROM
    TABLE(public.fST_AVG_Stage_Average(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol.ST_AVG_ST_ID = id
AND
    fol.ST_AVG_ChangedAt > changingTimepoint
AND
    fol.ST_AVG_Assertion = coalesce(assertion, fol.ST_AVG_Assertion)
ORDER BY
    fol.ST_AVG_ChangedAt ASC,
    fol.ST_AVG_PositedAt DESC
LIMIT 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_MIN_Stage_Minimum_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_MIN int,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Positor tinyint,
    ST_MIN_Reliability decimal(5,2),
    ST_MIN_Assertion string
)
AS
$$
SELECT
    Metadata_ST_MIN,
    ST_MIN_ID,
    ST_MIN_PositedAt,
    ST_MIN_Positor,
    ST_MIN_Reliability,
    ST_MIN_Assertion
FROM
    public.ST_MIN_Stage_Minimum_Annex
WHERE
    ST_MIN_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_MIN_Stage_Minimum (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_MIN int,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Positor tinyint,
    ST_MIN_Reliability decimal(5,2),
    ST_MIN_Assertion string,
    ST_MIN_ST_ID int,
    ST_MIN_UTL_ID tinyint 
)
AS
$$
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Positor,
    a.ST_MIN_Reliability,
    a.ST_MIN_Assertion,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID
FROM
    public.ST_MIN_Stage_Minimum_Posit p
JOIN
    TABLE(public.rST_MIN_Stage_Minimum_Annex(positingTimepoint)) a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
AND
    a.ST_MIN_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_MIN_ID
        ORDER BY a.ST_MIN_PositedAt DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_NAM_ID int,
    AC_NAM_AC_ID int,
    AC_NAM_Actor_Name varchar(42),
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
    public.AC_NAM_Actor_Name_Posit
WHERE
    AC_NAM_ChangedAt <= changingTimepoint
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fAC_NAM_Actor_Name_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_NAM_ID int,
    AC_NAM_AC_ID int,
    AC_NAM_Actor_Name varchar(42),
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
    public.AC_NAM_Actor_Name_Posit
WHERE
    AC_NAM_ChangedAt > changingTimepoint
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Positor tinyint,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Assertion string
)
AS
$$
SELECT
    Metadata_AC_NAM,
    AC_NAM_ID,
    AC_NAM_PositedAt,
    AC_NAM_Positor,
    AC_NAM_Reliability,
    AC_NAM_Assertion
FROM
    public.AC_NAM_Actor_Name_Annex
WHERE
    AC_NAM_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Positor tinyint,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Assertion string,
    AC_NAM_AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Positor,
    a.AC_NAM_Reliability,
    a.AC_NAM_Assertion,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt
FROM
    TABLE(public.rAC_NAM_Actor_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_NAM_Actor_Name_Annex(positingTimepoint)) a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
AND
    a.AC_NAM_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_NAM_ID
        ORDER BY a.AC_NAM_PositedAt DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fAC_NAM_Actor_Name (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Positor tinyint,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Assertion string,
    AC_NAM_AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Positor,
    a.AC_NAM_Reliability,
    a.AC_NAM_Assertion,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt
FROM
    TABLE(public.fAC_NAM_Actor_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_NAM_Actor_Name_Annex(positingTimepoint)) a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
AND
    a.AC_NAM_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_NAM_ID
        ORDER BY a.AC_NAM_PositedAt DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.preAC_NAM_Actor_Name (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    pre.AC_NAM_Actor_Name
FROM
    TABLE(public.rAC_NAM_Actor_Name(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre.AC_NAM_AC_ID = id
AND
    pre.AC_NAM_ChangedAt < changingTimepoint
AND
    pre.AC_NAM_Assertion = coalesce(assertion, pre.AC_NAM_Assertion)
ORDER BY
    pre.AC_NAM_ChangedAt DESC,
    pre.AC_NAM_PositedAt DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.folAC_NAM_Actor_Name (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    fol.AC_NAM_Actor_Name
FROM
    TABLE(public.fAC_NAM_Actor_Name(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol.AC_NAM_AC_ID = id
AND
    fol.AC_NAM_ChangedAt > changingTimepoint
AND
    fol.AC_NAM_Assertion = coalesce(assertion, fol.AC_NAM_Assertion)
ORDER BY
    fol.AC_NAM_ChangedAt ASC,
    fol.AC_NAM_PositedAt DESC
LIMIT 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_GEN_Actor_Gender_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_GEN int,
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Positor tinyint,
    AC_GEN_Reliability decimal(5,2),
    AC_GEN_Assertion string
)
AS
$$
SELECT
    Metadata_AC_GEN,
    AC_GEN_ID,
    AC_GEN_PositedAt,
    AC_GEN_Positor,
    AC_GEN_Reliability,
    AC_GEN_Assertion
FROM
    public.AC_GEN_Actor_Gender_Annex
WHERE
    AC_GEN_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_GEN_Actor_Gender (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_GEN int,
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Positor tinyint,
    AC_GEN_Reliability decimal(5,2),
    AC_GEN_Assertion string,
    AC_GEN_AC_ID int,
    AC_GEN_GEN_ID number(1,0) 
)
AS
$$
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Positor,
    a.AC_GEN_Reliability,
    a.AC_GEN_Assertion,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID
FROM
    public.AC_GEN_Actor_Gender_Posit p
JOIN
    TABLE(public.rAC_GEN_Actor_Gender_Annex(positingTimepoint)) a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
AND
    a.AC_GEN_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_GEN_ID
        ORDER BY a.AC_GEN_PositedAt DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_PLV_ID int,
    AC_PLV_AC_ID int,
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
    public.AC_PLV_Actor_ProfessionalLevel_Posit
WHERE
    AC_PLV_ChangedAt <= changingTimepoint
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fAC_PLV_Actor_ProfessionalLevel_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_PLV_ID int,
    AC_PLV_AC_ID int,
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
    public.AC_PLV_Actor_ProfessionalLevel_Posit
WHERE
    AC_PLV_ChangedAt > changingTimepoint
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Positor tinyint,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_Assertion string
)
AS
$$
SELECT
    Metadata_AC_PLV,
    AC_PLV_ID,
    AC_PLV_PositedAt,
    AC_PLV_Positor,
    AC_PLV_Reliability,
    AC_PLV_Assertion
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Annex
WHERE
    AC_PLV_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Positor tinyint,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_Assertion string,
    AC_PLV_AC_ID int,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Positor,
    a.AC_PLV_Reliability,
    a.AC_PLV_Assertion,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt
FROM
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel_Annex(positingTimepoint)) a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
AND
    a.AC_PLV_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_PLV_ID
        ORDER BY a.AC_PLV_PositedAt DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fAC_PLV_Actor_ProfessionalLevel (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Positor tinyint,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_Assertion string,
    AC_PLV_AC_ID int,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Positor,
    a.AC_PLV_Reliability,
    a.AC_PLV_Assertion,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt
FROM
    TABLE(public.fAC_PLV_Actor_ProfessionalLevel_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel_Annex(positingTimepoint)) a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
AND
    a.AC_PLV_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_PLV_ID
        ORDER BY a.AC_PLV_PositedAt DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.preAC_PLV_Actor_ProfessionalLevel (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    pre.AC_PLV_PLV_ID
FROM
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre.AC_PLV_AC_ID = id
AND
    pre.AC_PLV_ChangedAt < changingTimepoint
AND
    pre.AC_PLV_Assertion = coalesce(assertion, pre.AC_PLV_Assertion)
ORDER BY
    pre.AC_PLV_ChangedAt DESC,
    pre.AC_PLV_PositedAt DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.folAC_PLV_Actor_ProfessionalLevel (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    fol.AC_PLV_PLV_ID
FROM
    TABLE(public.fAC_PLV_Actor_ProfessionalLevel(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol.AC_PLV_AC_ID = id
AND
    fol.AC_PLV_ChangedAt > changingTimepoint
AND
    fol.AC_PLV_Assertion = coalesce(assertion, fol.AC_PLV_Assertion)
ORDER BY
    fol.AC_PLV_ChangedAt ASC,
    fol.AC_PLV_PositedAt DESC
LIMIT 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_NAM_Program_Name_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_NAM int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Positor tinyint,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_Assertion string
)
AS
$$
SELECT
    Metadata_PR_NAM,
    PR_NAM_ID,
    PR_NAM_PositedAt,
    PR_NAM_Positor,
    PR_NAM_Reliability,
    PR_NAM_Assertion
FROM
    public.PR_NAM_Program_Name_Annex
WHERE
    PR_NAM_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_NAM_Program_Name (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_NAM int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Positor tinyint,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_Assertion string,
    PR_NAM_PR_ID int,
    PR_NAM_Program_Name varchar(42)
)
AS
$$
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Positor,
    a.PR_NAM_Reliability,
    a.PR_NAM_Assertion,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name
FROM
    public.PR_NAM_Program_Name_Posit p
JOIN
    TABLE(public.rPR_NAM_Program_Name_Annex(positingTimepoint)) a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
AND
    a.PR_NAM_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_NAM_ID
        ORDER BY a.PR_NAM_PositedAt DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length_Posit (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    PR_LEN_ID int,
    PR_LEN_PR_ID int,
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
    public.PR_LEN_Program_Length_Posit
WHERE
    PR_LEN_ChangedAt <= changingTimepoint
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fPR_LEN_Program_Length_Posit (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    PR_LEN_ID int,
    PR_LEN_PR_ID int,
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
    public.PR_LEN_Program_Length_Posit
WHERE
    PR_LEN_ChangedAt > changingTimepoint
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Positor tinyint,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Assertion string
)
AS
$$
SELECT
    Metadata_PR_LEN,
    PR_LEN_ID,
    PR_LEN_PositedAt,
    PR_LEN_Positor,
    PR_LEN_Reliability,
    PR_LEN_Assertion
FROM
    public.PR_LEN_Program_Length_Annex
WHERE
    PR_LEN_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length (
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Positor tinyint,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Assertion string,
    PR_LEN_PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Positor,
    a.PR_LEN_Reliability,
    a.PR_LEN_Assertion,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt
FROM
    TABLE(public.rPR_LEN_Program_Length_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rPR_LEN_Program_Length_Annex(positingTimepoint)) a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
AND
    a.PR_LEN_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_LEN_ID
        ORDER BY a.PR_LEN_PositedAt DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fPR_LEN_Program_Length (
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Positor tinyint,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Assertion string,
    PR_LEN_PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Positor,
    a.PR_LEN_Reliability,
    a.PR_LEN_Assertion,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt
FROM
    TABLE(public.fPR_LEN_Program_Length_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rPR_LEN_Program_Length_Annex(positingTimepoint)) a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
AND
    a.PR_LEN_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_LEN_ID
        ORDER BY a.PR_LEN_PositedAt DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.prePR_LEN_Program_Length (
    id int,
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS time
AS
$$
SELECT
    pre.PR_LEN_Program_Length
FROM
    TABLE(public.rPR_LEN_Program_Length(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre.PR_LEN_PR_ID = id
AND
    pre.PR_LEN_ChangedAt < changingTimepoint
AND
    pre.PR_LEN_Assertion = coalesce(assertion, pre.PR_LEN_Assertion)
ORDER BY
    pre.PR_LEN_ChangedAt DESC,
    pre.PR_LEN_PositedAt DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.folPR_LEN_Program_Length (
    id int,
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS time
AS
$$
SELECT
    fol.PR_LEN_Program_Length
FROM
    TABLE(public.fPR_LEN_Program_Length(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol.PR_LEN_PR_ID = id
AND
    fol.PR_LEN_ChangedAt > changingTimepoint
AND
    fol.PR_LEN_Assertion = coalesce(assertion, fol.PR_LEN_Assertion)
ORDER BY
    fol.PR_LEN_ChangedAt ASC,
    fol.PR_LEN_PositedAt DESC
LIMIT 1
$$
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
CREATE SEQUENCE IF NOT EXISTS public.AC_partner_AC_with_ONG_currently_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.AC_partner_AC_with_ONG_currently_Posit (
    AC_partner_AC_with_ONG_currently_ID int default public.AC_partner_AC_with_ONG_currently_Posit_ID_SEQ.nextval not null, 
    AC_ID_partner int not null, 
    AC_ID_with int not null, 
    ONG_ID_currently tinyint not null,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime not null,
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_partner foreign key (
        AC_ID_partner
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_with foreign key (
        AC_ID_with
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_partner_AC_with_ONG_currently_Posit_fkONG_currently foreign key (
        ONG_ID_currently
    ) references public.ONG_Ongoing(ONG_ID) RELY,
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ) RELY,
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ) RELY,
    constraint pkAC_partner_AC_with_ONG_currently_Posit primary key (
        AC_partner_AC_with_ONG_currently_ID
    ) RELY,
    constraint uqAC_partner_AC_with_ONG_currently unique (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    ) RELY
) CLUSTER BY (
    AC_ID_partner,
    AC_ID_with,
    ONG_ID_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt
);
CREATE TABLE IF NOT EXISTS public.AC_partner_AC_with_ONG_currently_Annex (
    AC_partner_AC_with_ONG_currently_ID int not null,
    AC_partner_AC_with_ONG_currently_PositedAt datetime not null,
    AC_partner_AC_with_ONG_currently_Positor tinyint not null,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2) not null,
    AC_partner_AC_with_ONG_currently_Assertion string default (
        case
            when AC_partner_AC_with_ONG_currently_Reliability > 0 then '+'
            when AC_partner_AC_with_ONG_currently_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_AC_partner_AC_with_ONG_currently int not null,
    constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
        AC_partner_AC_with_ONG_currently_ID
    ) references public.AC_partner_AC_with_ONG_currently_Posit(AC_partner_AC_with_ONG_currently_ID) RELY,
    constraint pkAC_partner_AC_with_ONG_currently_Annex primary key (
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt
    ) RELY
) CLUSTER BY (AC_partner_AC_with_ONG_currently_ID, AC_partner_AC_with_ONG_currently_Positor, AC_partner_AC_with_ONG_currently_PositedAt);
CREATE SEQUENCE IF NOT EXISTS public.AC_subset_PN_of_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.AC_subset_PN_of_Posit (
    AC_subset_PN_of_ID int default public.AC_subset_PN_of_Posit_ID_SEQ.nextval not null, 
    AC_ID_subset int not null, 
    PN_ID_of int not null, 
    constraint AC_subset_PN_of_Posit_fkAC_subset foreign key (
        AC_ID_subset
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_subset_PN_of_Posit_fkPN_of foreign key (
        PN_ID_of
    ) references public.PN_Person(PN_ID) RELY, 
    constraint AC_subset_PN_of_Posit_uqAC_subset unique (
        AC_ID_subset
    ) RELY,
    constraint AC_subset_PN_of_Posit_uqPN_of unique (
        PN_ID_of
    ) RELY,
    constraint pkAC_subset_PN_of_Posit primary key (
        AC_subset_PN_of_ID
    ) RELY,
    constraint uqAC_subset_PN_of unique (
        AC_ID_subset,
        PN_ID_of
    ) RELY
) CLUSTER BY (
    AC_ID_subset,
    PN_ID_of
);
CREATE TABLE IF NOT EXISTS public.AC_subset_PN_of_Annex (
    AC_subset_PN_of_ID int not null,
    AC_subset_PN_of_PositedAt datetime not null,
    AC_subset_PN_of_Positor tinyint not null,
    AC_subset_PN_of_Reliability decimal(5,2) not null,
    AC_subset_PN_of_Assertion string default (
        case
            when AC_subset_PN_of_Reliability > 0 then '+'
            when AC_subset_PN_of_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_AC_subset_PN_of int not null,
    constraint fkAC_subset_PN_of_Annex foreign key (
        AC_subset_PN_of_ID
    ) references public.AC_subset_PN_of_Posit(AC_subset_PN_of_ID) RELY,
    constraint pkAC_subset_PN_of_Annex primary key (
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt
    ) RELY
) CLUSTER BY (AC_subset_PN_of_ID, AC_subset_PN_of_Positor, AC_subset_PN_of_PositedAt);
CREATE SEQUENCE IF NOT EXISTS public.EV_in_AC_wasCast_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.EV_in_AC_wasCast_Posit (
    EV_in_AC_wasCast_ID int default public.EV_in_AC_wasCast_Posit_ID_SEQ.nextval not null, 
    EV_ID_in int not null, 
    AC_ID_wasCast int not null, 
    constraint EV_in_AC_wasCast_Posit_fkEV_in foreign key (
        EV_ID_in
    ) references public.EV_Event(EV_ID) RELY, 
    constraint EV_in_AC_wasCast_Posit_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint pkEV_in_AC_wasCast_Posit primary key (
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
CREATE TABLE IF NOT EXISTS public.EV_in_AC_wasCast_Annex (
    EV_in_AC_wasCast_ID int not null,
    EV_in_AC_wasCast_PositedAt datetime not null,
    EV_in_AC_wasCast_Positor tinyint not null,
    EV_in_AC_wasCast_Reliability decimal(5,2) not null,
    EV_in_AC_wasCast_Assertion string default (
        case
            when EV_in_AC_wasCast_Reliability > 0 then '+'
            when EV_in_AC_wasCast_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_EV_in_AC_wasCast int not null,
    constraint fkEV_in_AC_wasCast_Annex foreign key (
        EV_in_AC_wasCast_ID
    ) references public.EV_in_AC_wasCast_Posit(EV_in_AC_wasCast_ID) RELY,
    constraint pkEV_in_AC_wasCast_Annex primary key (
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_Positor,
        EV_in_AC_wasCast_PositedAt
    ) RELY
) CLUSTER BY (EV_in_AC_wasCast_ID, EV_in_AC_wasCast_Positor, EV_in_AC_wasCast_PositedAt);
CREATE SEQUENCE IF NOT EXISTS public.AC_part_PR_in_RAT_got_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.AC_part_PR_in_RAT_got_Posit (
    AC_part_PR_in_RAT_got_ID int default public.AC_part_PR_in_RAT_got_Posit_ID_SEQ.nextval not null, 
    AC_ID_part int not null, 
    PR_ID_in int not null, 
    RAT_ID_got tinyint not null,
    AC_part_PR_in_RAT_got_ChangedAt datetime not null,
    constraint AC_part_PR_in_RAT_got_Posit_fkAC_part foreign key (
        AC_ID_part
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_part_PR_in_RAT_got_Posit_fkPR_in foreign key (
        PR_ID_in
    ) references public.PR_Program(PR_ID) RELY, 
    constraint AC_part_PR_in_RAT_got_Posit_fkRAT_got foreign key (
        RAT_ID_got
    ) references public.RAT_Rating(RAT_ID) RELY,
    constraint pkAC_part_PR_in_RAT_got_Posit primary key (
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
CREATE TABLE IF NOT EXISTS public.AC_part_PR_in_RAT_got_Annex (
    AC_part_PR_in_RAT_got_ID int not null,
    AC_part_PR_in_RAT_got_PositedAt datetime not null,
    AC_part_PR_in_RAT_got_Positor tinyint not null,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2) not null,
    AC_part_PR_in_RAT_got_Assertion string default (
        case
            when AC_part_PR_in_RAT_got_Reliability > 0 then '+'
            when AC_part_PR_in_RAT_got_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_AC_part_PR_in_RAT_got int not null,
    constraint fkAC_part_PR_in_RAT_got_Annex foreign key (
        AC_part_PR_in_RAT_got_ID
    ) references public.AC_part_PR_in_RAT_got_Posit(AC_part_PR_in_RAT_got_ID) RELY,
    constraint pkAC_part_PR_in_RAT_got_Annex primary key (
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Positor,
        AC_part_PR_in_RAT_got_PositedAt
    ) RELY
) CLUSTER BY (AC_part_PR_in_RAT_got_ID, AC_part_PR_in_RAT_got_Positor, AC_part_PR_in_RAT_got_PositedAt);
CREATE SEQUENCE IF NOT EXISTS public.ST_at_PR_isPlaying_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.ST_at_PR_isPlaying_Posit (
    ST_at_PR_isPlaying_ID int default public.ST_at_PR_isPlaying_Posit_ID_SEQ.nextval not null, 
    ST_ID_at int not null, 
    PR_ID_isPlaying int not null, 
    ST_at_PR_isPlaying_ChangedAt datetime not null,
    constraint ST_at_PR_isPlaying_Posit_fkST_at foreign key (
        ST_ID_at
    ) references public.ST_Stage(ST_ID) RELY, 
    constraint ST_at_PR_isPlaying_Posit_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references public.PR_Program(PR_ID) RELY, 
    constraint pkST_at_PR_isPlaying_Posit primary key (
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
CREATE TABLE IF NOT EXISTS public.ST_at_PR_isPlaying_Annex (
    ST_at_PR_isPlaying_ID int not null,
    ST_at_PR_isPlaying_PositedAt datetime not null,
    ST_at_PR_isPlaying_Positor tinyint not null,
    ST_at_PR_isPlaying_Reliability decimal(5,2) not null,
    ST_at_PR_isPlaying_Assertion string default (
        case
            when ST_at_PR_isPlaying_Reliability > 0 then '+'
            when ST_at_PR_isPlaying_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_ST_at_PR_isPlaying int not null,
    constraint fkST_at_PR_isPlaying_Annex foreign key (
        ST_at_PR_isPlaying_ID
    ) references public.ST_at_PR_isPlaying_Posit(ST_at_PR_isPlaying_ID) RELY,
    constraint pkST_at_PR_isPlaying_Annex primary key (
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_Positor,
        ST_at_PR_isPlaying_PositedAt
    ) RELY
) CLUSTER BY (ST_at_PR_isPlaying_ID, ST_at_PR_isPlaying_Positor, ST_at_PR_isPlaying_PositedAt);
CREATE SEQUENCE IF NOT EXISTS public.AC_parent_AC_child_PAT_having_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.AC_parent_AC_child_PAT_having_Posit (
    AC_parent_AC_child_PAT_having_ID int default public.AC_parent_AC_child_PAT_having_Posit_ID_SEQ.nextval not null, 
    AC_ID_parent int not null, 
    AC_ID_child int not null, 
    PAT_ID_having tinyint not null,
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_parent foreign key (
        AC_ID_parent
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_child foreign key (
        AC_ID_child
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_parent_AC_child_PAT_having_Posit_fkPAT_having foreign key (
        PAT_ID_having
    ) references public.PAT_ParentalType(PAT_ID) RELY,
    constraint pkAC_parent_AC_child_PAT_having_Posit primary key (
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
CREATE TABLE IF NOT EXISTS public.AC_parent_AC_child_PAT_having_Annex (
    AC_parent_AC_child_PAT_having_ID int not null,
    AC_parent_AC_child_PAT_having_PositedAt datetime not null,
    AC_parent_AC_child_PAT_having_Positor tinyint not null,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2) not null,
    AC_parent_AC_child_PAT_having_Assertion string default (
        case
            when AC_parent_AC_child_PAT_having_Reliability > 0 then '+'
            when AC_parent_AC_child_PAT_having_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_AC_parent_AC_child_PAT_having int not null,
    constraint fkAC_parent_AC_child_PAT_having_Annex foreign key (
        AC_parent_AC_child_PAT_having_ID
    ) references public.AC_parent_AC_child_PAT_having_Posit(AC_parent_AC_child_PAT_having_ID) RELY,
    constraint pkAC_parent_AC_child_PAT_having_Annex primary key (
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_Positor,
        AC_parent_AC_child_PAT_having_PositedAt
    ) RELY
) CLUSTER BY (AC_parent_AC_child_PAT_having_ID, AC_parent_AC_child_PAT_having_Positor, AC_parent_AC_child_PAT_having_PositedAt);
CREATE SEQUENCE IF NOT EXISTS public.PR_content_ST_location_EV_of_Posit_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PR_content_ST_location_EV_of_Posit (
    PR_content_ST_location_EV_of_ID int default public.PR_content_ST_location_EV_of_Posit_ID_SEQ.nextval not null, 
    PR_ID_content int not null, 
    ST_ID_location int not null, 
    EV_ID_of int not null, 
    constraint PR_content_ST_location_EV_of_Posit_fkPR_content foreign key (
        PR_ID_content
    ) references public.PR_Program(PR_ID) RELY, 
    constraint PR_content_ST_location_EV_of_Posit_fkST_location foreign key (
        ST_ID_location
    ) references public.ST_Stage(ST_ID) RELY, 
    constraint PR_content_ST_location_EV_of_Posit_fkEV_of foreign key (
        EV_ID_of
    ) references public.EV_Event(EV_ID) RELY, 
    constraint pkPR_content_ST_location_EV_of_Posit primary key (
        PR_content_ST_location_EV_of_ID
    ) RELY,
    constraint uqPR_content_ST_location_EV_of unique (
        EV_ID_of,
        PR_ID_content,
        ST_ID_location
    ) RELY
) CLUSTER BY (
    EV_ID_of
);
CREATE TABLE IF NOT EXISTS public.PR_content_ST_location_EV_of_Annex (
    PR_content_ST_location_EV_of_ID int not null,
    PR_content_ST_location_EV_of_PositedAt datetime not null,
    PR_content_ST_location_EV_of_Positor tinyint not null,
    PR_content_ST_location_EV_of_Reliability decimal(5,2) not null,
    PR_content_ST_location_EV_of_Assertion string default (
        case
            when PR_content_ST_location_EV_of_Reliability > 0 then '+'
            when PR_content_ST_location_EV_of_Reliability = 0 then '?'
            else '-'
        end
    ),
    Metadata_PR_content_ST_location_EV_of int not null,
    constraint fkPR_content_ST_location_EV_of_Annex foreign key (
        PR_content_ST_location_EV_of_ID
    ) references public.PR_content_ST_location_EV_of_Posit(PR_content_ST_location_EV_of_ID) RELY,
    constraint pkPR_content_ST_location_EV_of_Annex primary key (
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Positor,
        PR_content_ST_location_EV_of_PositedAt
    ) RELY
) CLUSTER BY (PR_content_ST_location_EV_of_ID, PR_content_ST_location_EV_of_Positor, PR_content_ST_location_EV_of_PositedAt);
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public.AC_partner_AC_with_ONG_currently COPY GRANTS AS
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
    a.AC_partner_AC_with_ONG_currently_Assertion
FROM
    public.AC_partner_AC_with_ONG_currently_Posit p
JOIN
    public.AC_partner_AC_with_ONG_currently_Annex a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
;
CREATE OR REPLACE VIEW public.AC_subset_PN_of COPY GRANTS AS
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Positor,
    a.AC_subset_PN_of_Reliability,
    a.AC_subset_PN_of_Assertion
FROM
    public.AC_subset_PN_of_Posit p
JOIN
    public.AC_subset_PN_of_Annex a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
;
CREATE OR REPLACE VIEW public.EV_in_AC_wasCast COPY GRANTS AS
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Positor,
    a.EV_in_AC_wasCast_Reliability,
    a.EV_in_AC_wasCast_Assertion
FROM
    public.EV_in_AC_wasCast_Posit p
JOIN
    public.EV_in_AC_wasCast_Annex a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
;
CREATE OR REPLACE VIEW public.AC_part_PR_in_RAT_got COPY GRANTS AS
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
    a.AC_part_PR_in_RAT_got_Assertion
FROM
    public.AC_part_PR_in_RAT_got_Posit p
JOIN
    public.AC_part_PR_in_RAT_got_Annex a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
;
CREATE OR REPLACE VIEW public.ST_at_PR_isPlaying COPY GRANTS AS
SELECT
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Positor,
    a.ST_at_PR_isPlaying_Reliability,
    a.ST_at_PR_isPlaying_Assertion
FROM
    public.ST_at_PR_isPlaying_Posit p
JOIN
    public.ST_at_PR_isPlaying_Annex a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
;
CREATE OR REPLACE VIEW public.AC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    a.Metadata_AC_parent_AC_child_PAT_having,
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Positor,
    a.AC_parent_AC_child_PAT_having_Reliability,
    a.AC_parent_AC_child_PAT_having_Assertion
FROM
    public.AC_parent_AC_child_PAT_having_Posit p
JOIN
    public.AC_parent_AC_child_PAT_having_Annex a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
;
CREATE OR REPLACE VIEW public.PR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Positor,
    a.PR_content_ST_location_EV_of_Reliability,
    a.PR_content_ST_location_EV_of_Assertion
FROM
    public.PR_content_ST_location_EV_of_Posit p
JOIN
    public.PR_content_ST_location_EV_of_Annex a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection.
--
CREATE OR REPLACE FUNCTION public.rAC_partner_AC_with_ONG_currently_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID int,
    AC_ID_partner int, 
    AC_ID_with int, 
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
    public.AC_partner_AC_with_ONG_currently_Posit
WHERE
    AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.fAC_partner_AC_with_ONG_currently_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID int,
    AC_ID_partner int, 
    AC_ID_with int, 
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
    public.AC_partner_AC_with_ONG_currently_Posit
WHERE
    AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_partner_AC_with_ONG_currently_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ID int,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string
)
AS
$$
SELECT
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ID,
    AC_partner_AC_with_ONG_currently_PositedAt,
    AC_partner_AC_with_ONG_currently_Positor,
    AC_partner_AC_with_ONG_currently_Reliability,
    AC_partner_AC_with_ONG_currently_Assertion
FROM
    public.AC_partner_AC_with_ONG_currently_Annex
WHERE
    AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_partner_AC_with_ONG_currently (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ID int,
    AC_ID_partner int, 
    AC_ID_with int, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string
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
    a.AC_partner_AC_with_ONG_currently_Positor,
    a.AC_partner_AC_with_ONG_currently_Reliability,
    a.AC_partner_AC_with_ONG_currently_Assertion
FROM
    TABLE(public.rAC_partner_AC_with_ONG_currently_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rAC_partner_AC_with_ONG_currently_Annex(positingTimepoint)) a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
AND
    a.AC_partner_AC_with_ONG_currently_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_partner_AC_with_ONG_currently_ID
        ORDER BY a.AC_partner_AC_with_ONG_currently_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fAC_partner_AC_with_ONG_currently (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ID int,
    AC_ID_partner int, 
    AC_ID_with int, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string
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
    a.AC_partner_AC_with_ONG_currently_Positor,
    a.AC_partner_AC_with_ONG_currently_Reliability,
    a.AC_partner_AC_with_ONG_currently_Assertion
FROM
    TABLE(public.fAC_partner_AC_with_ONG_currently_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rAC_partner_AC_with_ONG_currently_Annex(positingTimepoint)) a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
AND
    a.AC_partner_AC_with_ONG_currently_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_partner_AC_with_ONG_currently_ID
        ORDER BY a.AC_partner_AC_with_ONG_currently_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rAC_subset_PN_of_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_subset_PN_of_ID int,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Positor tinyint,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_subset_PN_of_Assertion string
)
AS
$$
SELECT
    Metadata_AC_subset_PN_of,
    AC_subset_PN_of_ID,
    AC_subset_PN_of_PositedAt,
    AC_subset_PN_of_Positor,
    AC_subset_PN_of_Reliability,
    AC_subset_PN_of_Assertion
FROM
    public.AC_subset_PN_of_Annex
WHERE
    AC_subset_PN_of_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_subset_PN_of (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_subset_PN_of_ID int,
    AC_ID_subset int, 
    PN_ID_of int, 
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Positor tinyint,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_subset_PN_of_Assertion string
)
AS
$$
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Positor,
    a.AC_subset_PN_of_Reliability,
    a.AC_subset_PN_of_Assertion
FROM
    public.AC_subset_PN_of_Posit p
JOIN
    TABLE(public.rAC_subset_PN_of_Annex(positingTimepoint)) a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
AND
    a.AC_subset_PN_of_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_subset_PN_of_ID
        ORDER BY a.AC_subset_PN_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fAC_subset_PN_of (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_subset_PN_of_ID int,
    AC_ID_subset int, 
    PN_ID_of int, 
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Positor tinyint,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_subset_PN_of_Assertion string
)
AS
$$
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Positor,
    a.AC_subset_PN_of_Reliability,
    a.AC_subset_PN_of_Assertion
FROM
    public.AC_subset_PN_of_Posit p
JOIN
    TABLE(public.rAC_subset_PN_of_Annex(positingTimepoint)) a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
AND
    a.AC_subset_PN_of_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_subset_PN_of_ID
        ORDER BY a.AC_subset_PN_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rEV_in_AC_wasCast_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_in_AC_wasCast_ID int,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Positor tinyint,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_in_AC_wasCast_Assertion string
)
AS
$$
SELECT
    Metadata_EV_in_AC_wasCast,
    EV_in_AC_wasCast_ID,
    EV_in_AC_wasCast_PositedAt,
    EV_in_AC_wasCast_Positor,
    EV_in_AC_wasCast_Reliability,
    EV_in_AC_wasCast_Assertion
FROM
    public.EV_in_AC_wasCast_Annex
WHERE
    EV_in_AC_wasCast_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rEV_in_AC_wasCast (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_in_AC_wasCast_ID int,
    EV_ID_in int, 
    AC_ID_wasCast int, 
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Positor tinyint,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_in_AC_wasCast_Assertion string
)
AS
$$
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Positor,
    a.EV_in_AC_wasCast_Reliability,
    a.EV_in_AC_wasCast_Assertion
FROM
    public.EV_in_AC_wasCast_Posit p
JOIN
    TABLE(public.rEV_in_AC_wasCast_Annex(positingTimepoint)) a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
AND
    a.EV_in_AC_wasCast_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_in_AC_wasCast_ID
        ORDER BY a.EV_in_AC_wasCast_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fEV_in_AC_wasCast (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_in_AC_wasCast_ID int,
    EV_ID_in int, 
    AC_ID_wasCast int, 
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Positor tinyint,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_in_AC_wasCast_Assertion string
)
AS
$$
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Positor,
    a.EV_in_AC_wasCast_Reliability,
    a.EV_in_AC_wasCast_Assertion
FROM
    public.EV_in_AC_wasCast_Posit p
JOIN
    TABLE(public.rEV_in_AC_wasCast_Annex(positingTimepoint)) a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
AND
    a.EV_in_AC_wasCast_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_in_AC_wasCast_ID
        ORDER BY a.EV_in_AC_wasCast_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rAC_part_PR_in_RAT_got_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID int,
    AC_ID_part int, 
    PR_ID_in int, 
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
    public.AC_part_PR_in_RAT_got_Posit
WHERE
    AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.fAC_part_PR_in_RAT_got_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID int,
    AC_ID_part int, 
    PR_ID_in int, 
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
    public.AC_part_PR_in_RAT_got_Posit
WHERE
    AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_part_PR_in_RAT_got_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ID int,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string
)
AS
$$
SELECT
    Metadata_AC_part_PR_in_RAT_got,
    AC_part_PR_in_RAT_got_ID,
    AC_part_PR_in_RAT_got_PositedAt,
    AC_part_PR_in_RAT_got_Positor,
    AC_part_PR_in_RAT_got_Reliability,
    AC_part_PR_in_RAT_got_Assertion
FROM
    public.AC_part_PR_in_RAT_got_Annex
WHERE
    AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_part_PR_in_RAT_got (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ID int,
    AC_ID_part int, 
    PR_ID_in int, 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string
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
    a.AC_part_PR_in_RAT_got_Positor,
    a.AC_part_PR_in_RAT_got_Reliability,
    a.AC_part_PR_in_RAT_got_Assertion
FROM
    TABLE(public.rAC_part_PR_in_RAT_got_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rAC_part_PR_in_RAT_got_Annex(positingTimepoint)) a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
AND
    a.AC_part_PR_in_RAT_got_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_part_PR_in_RAT_got_ID
        ORDER BY a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fAC_part_PR_in_RAT_got (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ID int,
    AC_ID_part int, 
    PR_ID_in int, 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string
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
    a.AC_part_PR_in_RAT_got_Positor,
    a.AC_part_PR_in_RAT_got_Reliability,
    a.AC_part_PR_in_RAT_got_Assertion
FROM
    TABLE(public.fAC_part_PR_in_RAT_got_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rAC_part_PR_in_RAT_got_Annex(positingTimepoint)) a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
AND
    a.AC_part_PR_in_RAT_got_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_part_PR_in_RAT_got_ID
        ORDER BY a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rST_at_PR_isPlaying_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID int,
    ST_ID_at int, 
    PR_ID_isPlaying int, 
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
    public.ST_at_PR_isPlaying_Posit
WHERE
    ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.fST_at_PR_isPlaying_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID int,
    ST_ID_at int, 
    PR_ID_isPlaying int, 
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
    public.ST_at_PR_isPlaying_Posit
WHERE
    ST_at_PR_isPlaying_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rST_at_PR_isPlaying_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ID int,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string
)
AS
$$
SELECT
    Metadata_ST_at_PR_isPlaying,
    ST_at_PR_isPlaying_ID,
    ST_at_PR_isPlaying_PositedAt,
    ST_at_PR_isPlaying_Positor,
    ST_at_PR_isPlaying_Reliability,
    ST_at_PR_isPlaying_Assertion
FROM
    public.ST_at_PR_isPlaying_Annex
WHERE
    ST_at_PR_isPlaying_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rST_at_PR_isPlaying (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ID int,
    ST_ID_at int, 
    PR_ID_isPlaying int, 
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string
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
    a.ST_at_PR_isPlaying_Positor,
    a.ST_at_PR_isPlaying_Reliability,
    a.ST_at_PR_isPlaying_Assertion
FROM
    TABLE(public.rST_at_PR_isPlaying_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rST_at_PR_isPlaying_Annex(positingTimepoint)) a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
AND
    a.ST_at_PR_isPlaying_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_at_PR_isPlaying_ID
        ORDER BY a.ST_at_PR_isPlaying_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fST_at_PR_isPlaying (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ID int,
    ST_ID_at int, 
    PR_ID_isPlaying int, 
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string
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
    a.ST_at_PR_isPlaying_Positor,
    a.ST_at_PR_isPlaying_Reliability,
    a.ST_at_PR_isPlaying_Assertion
FROM
    TABLE(public.fST_at_PR_isPlaying_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rST_at_PR_isPlaying_Annex(positingTimepoint)) a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
AND
    a.ST_at_PR_isPlaying_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_at_PR_isPlaying_ID
        ORDER BY a.ST_at_PR_isPlaying_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rAC_parent_AC_child_PAT_having_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_parent_AC_child_PAT_having_ID int,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Positor tinyint,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_parent_AC_child_PAT_having_Assertion string
)
AS
$$
SELECT
    Metadata_AC_parent_AC_child_PAT_having,
    AC_parent_AC_child_PAT_having_ID,
    AC_parent_AC_child_PAT_having_PositedAt,
    AC_parent_AC_child_PAT_having_Positor,
    AC_parent_AC_child_PAT_having_Reliability,
    AC_parent_AC_child_PAT_having_Assertion
FROM
    public.AC_parent_AC_child_PAT_having_Annex
WHERE
    AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_parent_AC_child_PAT_having (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_parent_AC_child_PAT_having_ID int,
    AC_ID_parent int, 
    AC_ID_child int, 
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Positor tinyint,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_parent_AC_child_PAT_having_Assertion string
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
    a.AC_parent_AC_child_PAT_having_Positor,
    a.AC_parent_AC_child_PAT_having_Reliability,
    a.AC_parent_AC_child_PAT_having_Assertion
FROM
    public.AC_parent_AC_child_PAT_having_Posit p
JOIN
    TABLE(public.rAC_parent_AC_child_PAT_having_Annex(positingTimepoint)) a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
AND
    a.AC_parent_AC_child_PAT_having_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_parent_AC_child_PAT_having_ID
        ORDER BY a.AC_parent_AC_child_PAT_having_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fAC_parent_AC_child_PAT_having (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_parent_AC_child_PAT_having_ID int,
    AC_ID_parent int, 
    AC_ID_child int, 
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Positor tinyint,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_parent_AC_child_PAT_having_Assertion string
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
    a.AC_parent_AC_child_PAT_having_Positor,
    a.AC_parent_AC_child_PAT_having_Reliability,
    a.AC_parent_AC_child_PAT_having_Assertion
FROM
    public.AC_parent_AC_child_PAT_having_Posit p
JOIN
    TABLE(public.rAC_parent_AC_child_PAT_having_Annex(positingTimepoint)) a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
AND
    a.AC_parent_AC_child_PAT_having_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_parent_AC_child_PAT_having_ID
        ORDER BY a.AC_parent_AC_child_PAT_having_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rPR_content_ST_location_EV_of_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_ID int,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Positor tinyint,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_content_ST_location_EV_of_Assertion string
)
AS
$$
SELECT
    Metadata_PR_content_ST_location_EV_of,
    PR_content_ST_location_EV_of_ID,
    PR_content_ST_location_EV_of_PositedAt,
    PR_content_ST_location_EV_of_Positor,
    PR_content_ST_location_EV_of_Reliability,
    PR_content_ST_location_EV_of_Assertion
FROM
    public.PR_content_ST_location_EV_of_Annex
WHERE
    PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rPR_content_ST_location_EV_of (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_ID int,
    PR_ID_content int, 
    ST_ID_location int, 
    EV_ID_of int, 
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Positor tinyint,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_content_ST_location_EV_of_Assertion string
)
AS
$$
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Positor,
    a.PR_content_ST_location_EV_of_Reliability,
    a.PR_content_ST_location_EV_of_Assertion
FROM
    public.PR_content_ST_location_EV_of_Posit p
JOIN
    TABLE(public.rPR_content_ST_location_EV_of_Annex(positingTimepoint)) a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
AND
    a.PR_content_ST_location_EV_of_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_content_ST_location_EV_of_ID
        ORDER BY a.PR_content_ST_location_EV_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fPR_content_ST_location_EV_of (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_ID int,
    PR_ID_content int, 
    ST_ID_location int, 
    EV_ID_of int, 
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Positor tinyint,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_content_ST_location_EV_of_Assertion string
)
AS
$$
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Positor,
    a.PR_content_ST_location_EV_of_Reliability,
    a.PR_content_ST_location_EV_of_Assertion
FROM
    public.PR_content_ST_location_EV_of_Posit p
JOIN
    TABLE(public.rPR_content_ST_location_EV_of_Annex(positingTimepoint)) a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
AND
    a.PR_content_ST_location_EV_of_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_content_ST_location_EV_of_ID
        ORDER BY a.PR_content_ST_location_EV_of_PositedAt DESC
    ) = 1
$$
;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tST_Stage (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    ST_ID int,
    Metadata_ST int,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt datetime,
    ST_NAM_Positor tinyint,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Assertion string,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC int,
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Positor tinyint,
    ST_LOC_Reliability decimal(5,2),
    ST_LOC_Assertion string,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt datetime,
    ST_AVG_Positor tinyint,
    ST_AVG_Reliability decimal(5,2),
    ST_AVG_Assertion string,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL int,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN int,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Positor tinyint,
    ST_MIN_Reliability decimal(5,2),
    ST_MIN_Assertion string,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_Metadata_UTL int,
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
    NAM.ST_NAM_Positor,
    NAM.ST_NAM_Reliability,
    NAM.ST_NAM_Assertion,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.Metadata_ST_LOC,
    LOC.ST_LOC_ID,
    LOC.ST_LOC_PositedAt,
    LOC.ST_LOC_Positor,
    LOC.ST_LOC_Reliability,
    LOC.ST_LOC_Assertion,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ST_ID,
    AVG.Metadata_ST_AVG,
    AVG.ST_AVG_ID,
    AVG.ST_AVG_ChangedAt,
    AVG.ST_AVG_PositedAt,
    AVG.ST_AVG_Positor,
    AVG.ST_AVG_Reliability,
    AVG.ST_AVG_Assertion,
    kAVG.UTL_Utilization AS ST_AVG_UTL_Utilization,
    kAVG.Metadata_UTL AS ST_AVG_Metadata_UTL,
    AVG.ST_AVG_UTL_ID,
    MIN.ST_MIN_ST_ID,
    MIN.Metadata_ST_MIN,
    MIN.ST_MIN_ID,
    MIN.ST_MIN_PositedAt,
    MIN.ST_MIN_Positor,
    MIN.ST_MIN_Reliability,
    MIN.ST_MIN_Assertion,
    kMIN.UTL_Utilization AS ST_MIN_UTL_Utilization,
    kMIN.Metadata_UTL AS ST_MIN_Metadata_UTL,
    MIN.ST_MIN_UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    TABLE(public.rST_NAM_Stage_Name(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) NAM
ON
    NAM.ST_NAM_ID = (
        SELECT
            sub.ST_NAM_ID
        FROM
            TABLE(public.rST_NAM_Stage_Name(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
        AND
            sub.ST_NAM_Assertion = coalesce(assertion, sub.ST_NAM_Assertion)
        ORDER BY
            sub.ST_NAM_ChangedAt DESC,
            sub.ST_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rST_LOC_Stage_Location(
        positor,
        positingTimepoint::datetime
    )) LOC
ON
    LOC.ST_LOC_ID = (
        SELECT
            sub.ST_LOC_ID
        FROM
            TABLE(public.rST_LOC_Stage_Location(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.ST_LOC_ST_ID = ST.ST_ID
        AND
            sub.ST_LOC_Assertion = coalesce(assertion, sub.ST_LOC_Assertion)
        ORDER BY
            sub.ST_LOC_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rST_AVG_Stage_Average(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) AVG
ON
    AVG.ST_AVG_ID = (
        SELECT
            sub.ST_AVG_ID
        FROM
            TABLE(public.rST_AVG_Stage_Average(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.ST_AVG_ST_ID = ST.ST_ID
        AND
            sub.ST_AVG_Assertion = coalesce(assertion, sub.ST_AVG_Assertion)
        ORDER BY
            sub.ST_AVG_ChangedAt DESC,
            sub.ST_AVG_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    public.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.ST_AVG_UTL_ID
LEFT JOIN
    TABLE(public.rST_MIN_Stage_Minimum(
        positor,
        positingTimepoint::datetime
    )) MIN
ON
    MIN.ST_MIN_ID = (
        SELECT
            sub.ST_MIN_ID
        FROM
            TABLE(public.rST_MIN_Stage_Minimum(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.ST_MIN_ST_ID = ST.ST_ID
        AND
            sub.ST_MIN_Assertion = coalesce(assertion, sub.ST_MIN_Assertion)
        ORDER BY
            sub.ST_MIN_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    public.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.ST_MIN_UTL_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lST_Stage COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) as Reliability,
    ST.*
FROM
    public._Positor p,
    TABLE(public.tST_Stage(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) ST
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pST_Stage (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    ST_ID int,
    Metadata_ST int,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt datetime,
    ST_NAM_Positor tinyint,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Assertion string,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC int,
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Positor tinyint,
    ST_LOC_Reliability decimal(5,2),
    ST_LOC_Assertion string,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt datetime,
    ST_AVG_Positor tinyint,
    ST_AVG_Reliability decimal(5,2),
    ST_AVG_Assertion string,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL int,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN int,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Positor tinyint,
    ST_MIN_Reliability decimal(5,2),
    ST_MIN_Assertion string,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_Metadata_UTL int,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) as Reliability,
    ST.ST_ID,
    ST.Metadata_ST,
    ST.ST_NAM_ST_ID,
    ST.Metadata_ST_NAM,
    ST.ST_NAM_ID,
    ST.ST_NAM_ChangedAt,
    ST.ST_NAM_PositedAt,
    ST.ST_NAM_Positor,
    ST.ST_NAM_Reliability,
    ST.ST_NAM_Assertion,
    ST.ST_NAM_Stage_Name,
    ST.ST_LOC_ST_ID,
    ST.Metadata_ST_LOC,
    ST.ST_LOC_ID,
    ST.ST_LOC_PositedAt,
    ST.ST_LOC_Positor,
    ST.ST_LOC_Reliability,
    ST.ST_LOC_Assertion,
    ST.ST_LOC_Checksum,
    ST.ST_LOC_Stage_Location,
    ST.ST_AVG_ST_ID,
    ST.Metadata_ST_AVG,
    ST.ST_AVG_ID,
    ST.ST_AVG_ChangedAt,
    ST.ST_AVG_PositedAt,
    ST.ST_AVG_Positor,
    ST.ST_AVG_Reliability,
    ST.ST_AVG_Assertion,
    ST.ST_AVG_UTL_Utilization,
    ST.ST_AVG_Metadata_UTL,
    ST.ST_AVG_UTL_ID,
    ST.ST_MIN_ST_ID,
    ST.Metadata_ST_MIN,
    ST.ST_MIN_ID,
    ST.ST_MIN_PositedAt,
    ST.ST_MIN_Positor,
    ST.ST_MIN_Reliability,
    ST.ST_MIN_Assertion,
    ST.ST_MIN_UTL_Utilization,
    ST.ST_MIN_Metadata_UTL,
    ST.ST_MIN_UTL_ID
FROM
    public._Positor p,
    TABLE(public.tST_Stage(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) ST
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nST_Stage COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) as Reliability,
    ST.*
FROM
    public._Positor p,
    TABLE(public.tST_Stage(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) ST
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dST_Stage (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    ST_ID int,
    Metadata_ST int,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt datetime,
    ST_NAM_Positor tinyint,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Assertion string,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC int,
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Positor tinyint,
    ST_LOC_Reliability decimal(5,2),
    ST_LOC_Assertion string,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt datetime,
    ST_AVG_Positor tinyint,
    ST_AVG_Reliability decimal(5,2),
    ST_AVG_Assertion string,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL int,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN int,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Positor tinyint,
    ST_MIN_Reliability decimal(5,2),
    ST_MIN_Assertion string,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_Metadata_UTL int,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    p.Positor,
    timepoints.inspectedTimepoint,
    ST.ST_ID,
    ST.Metadata_ST,
    ST.ST_NAM_ST_ID,
    ST.Metadata_ST_NAM,
    ST.ST_NAM_ID,
    ST.ST_NAM_ChangedAt,
    ST.ST_NAM_PositedAt,
    ST.ST_NAM_Positor,
    ST.ST_NAM_Reliability,
    ST.ST_NAM_Assertion,
    ST.ST_NAM_Stage_Name,
    ST.ST_LOC_ST_ID,
    ST.Metadata_ST_LOC,
    ST.ST_LOC_ID,
    ST.ST_LOC_PositedAt,
    ST.ST_LOC_Positor,
    ST.ST_LOC_Reliability,
    ST.ST_LOC_Assertion,
    ST.ST_LOC_Checksum,
    ST.ST_LOC_Stage_Location,
    ST.ST_AVG_ST_ID,
    ST.Metadata_ST_AVG,
    ST.ST_AVG_ID,
    ST.ST_AVG_ChangedAt,
    ST.ST_AVG_PositedAt,
    ST.ST_AVG_Positor,
    ST.ST_AVG_Reliability,
    ST.ST_AVG_Assertion,
    ST.ST_AVG_UTL_Utilization,
    ST.ST_AVG_Metadata_UTL,
    ST.ST_AVG_UTL_ID,
    ST.ST_MIN_ST_ID,
    ST.Metadata_ST_MIN,
    ST.ST_MIN_ID,
    ST.ST_MIN_PositedAt,
    ST.ST_MIN_Positor,
    ST.ST_MIN_Reliability,
    ST.ST_MIN_Assertion,
    ST.ST_MIN_UTL_Utilization,
    ST.ST_MIN_Metadata_UTL,
    ST.ST_MIN_UTL_ID
FROM
    public._Positor p
JOIN
(
    SELECT DISTINCT
        ST_NAM_Positor AS positor,
        ST_NAM_ST_ID AS ST_ID,
        ST_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public.ST_NAM_Stage_Name
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        ST_AVG_Positor AS positor,
        ST_AVG_ST_ID AS ST_ID,
        ST_AVG_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        public.ST_AVG_Stage_Average
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p.Positor,
    TABLE(public.tST_Stage(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) ST
WHERE
    ST.ST_ID = timepoints.ST_ID
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tAC_Actor (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    AC_ID int,
    Metadata_AC int,
    AC_NAM_AC_ID int,
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt datetime,
    AC_NAM_Positor tinyint,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Assertion string,
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    Metadata_AC_GEN int,
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Positor tinyint,
    AC_GEN_Reliability decimal(5,2),
    AC_GEN_Assertion string,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN int,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt datetime,
    AC_PLV_Positor tinyint,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_Assertion string,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_Metadata_PLV int,
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
    NAM.AC_NAM_Positor,
    NAM.AC_NAM_Reliability,
    NAM.AC_NAM_Assertion,
    NAM.AC_NAM_Actor_Name,
    GEN.AC_GEN_AC_ID,
    GEN.Metadata_AC_GEN,
    GEN.AC_GEN_ID,
    GEN.AC_GEN_PositedAt,
    GEN.AC_GEN_Positor,
    GEN.AC_GEN_Reliability,
    GEN.AC_GEN_Assertion,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    kGEN.Metadata_GEN AS AC_GEN_Metadata_GEN,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.Metadata_AC_PLV,
    PLV.AC_PLV_ID,
    PLV.AC_PLV_ChangedAt,
    PLV.AC_PLV_PositedAt,
    PLV.AC_PLV_Positor,
    PLV.AC_PLV_Reliability,
    PLV.AC_PLV_Assertion,
    kPLV.PLV_Checksum AS AC_PLV_PLV_Checksum,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    kPLV.Metadata_PLV AS AC_PLV_Metadata_PLV,
    PLV.AC_PLV_PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    TABLE(public.rAC_NAM_Actor_Name(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) NAM
ON
    NAM.AC_NAM_ID = (
        SELECT
            sub.AC_NAM_ID
        FROM
            TABLE(public.rAC_NAM_Actor_Name(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
        AND
            sub.AC_NAM_Assertion = coalesce(assertion, sub.AC_NAM_Assertion)
        ORDER BY
            sub.AC_NAM_ChangedAt DESC,
            sub.AC_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rAC_GEN_Actor_Gender(
        positor,
        positingTimepoint::datetime
    )) GEN
ON
    GEN.AC_GEN_ID = (
        SELECT
            sub.AC_GEN_ID
        FROM
            TABLE(public.rAC_GEN_Actor_Gender(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.AC_GEN_AC_ID = AC.AC_ID
        AND
            sub.AC_GEN_Assertion = coalesce(assertion, sub.AC_GEN_Assertion)
        ORDER BY
            sub.AC_GEN_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    public.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.AC_GEN_GEN_ID
LEFT JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) PLV
ON
    PLV.AC_PLV_ID = (
        SELECT
            sub.AC_PLV_ID
        FROM
            TABLE(public.rAC_PLV_Actor_ProfessionalLevel(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.AC_PLV_AC_ID = AC.AC_ID
        AND
            sub.AC_PLV_Assertion = coalesce(assertion, sub.AC_PLV_Assertion)
        ORDER BY
            sub.AC_PLV_ChangedAt DESC,
            sub.AC_PLV_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.AC_PLV_PLV_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_Actor COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) as Reliability,
    AC.*
FROM
    public._Positor p,
    TABLE(public.tAC_Actor(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) AC
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_Actor (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    AC_ID int,
    Metadata_AC int,
    AC_NAM_AC_ID int,
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt datetime,
    AC_NAM_Positor tinyint,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Assertion string,
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    Metadata_AC_GEN int,
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Positor tinyint,
    AC_GEN_Reliability decimal(5,2),
    AC_GEN_Assertion string,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN int,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt datetime,
    AC_PLV_Positor tinyint,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_Assertion string,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_Metadata_PLV int,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) as Reliability,
    AC.AC_ID,
    AC.Metadata_AC,
    AC.AC_NAM_AC_ID,
    AC.Metadata_AC_NAM,
    AC.AC_NAM_ID,
    AC.AC_NAM_ChangedAt,
    AC.AC_NAM_PositedAt,
    AC.AC_NAM_Positor,
    AC.AC_NAM_Reliability,
    AC.AC_NAM_Assertion,
    AC.AC_NAM_Actor_Name,
    AC.AC_GEN_AC_ID,
    AC.Metadata_AC_GEN,
    AC.AC_GEN_ID,
    AC.AC_GEN_PositedAt,
    AC.AC_GEN_Positor,
    AC.AC_GEN_Reliability,
    AC.AC_GEN_Assertion,
    AC.AC_GEN_GEN_Gender,
    AC.AC_GEN_Metadata_GEN,
    AC.AC_GEN_GEN_ID,
    AC.AC_PLV_AC_ID,
    AC.Metadata_AC_PLV,
    AC.AC_PLV_ID,
    AC.AC_PLV_ChangedAt,
    AC.AC_PLV_PositedAt,
    AC.AC_PLV_Positor,
    AC.AC_PLV_Reliability,
    AC.AC_PLV_Assertion,
    AC.AC_PLV_PLV_Checksum,
    AC.AC_PLV_PLV_ProfessionalLevel,
    AC.AC_PLV_Metadata_PLV,
    AC.AC_PLV_PLV_ID
FROM
    public._Positor p,
    TABLE(public.tAC_Actor(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) AC
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_Actor COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) as Reliability,
    AC.*
FROM
    public._Positor p,
    TABLE(public.tAC_Actor(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) AC
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_Actor (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    AC_ID int,
    Metadata_AC int,
    AC_NAM_AC_ID int,
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt datetime,
    AC_NAM_Positor tinyint,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Assertion string,
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    Metadata_AC_GEN int,
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Positor tinyint,
    AC_GEN_Reliability decimal(5,2),
    AC_GEN_Assertion string,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN int,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt datetime,
    AC_PLV_Positor tinyint,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_Assertion string,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_Metadata_PLV int,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    p.Positor,
    timepoints.inspectedTimepoint,
    AC.AC_ID,
    AC.Metadata_AC,
    AC.AC_NAM_AC_ID,
    AC.Metadata_AC_NAM,
    AC.AC_NAM_ID,
    AC.AC_NAM_ChangedAt,
    AC.AC_NAM_PositedAt,
    AC.AC_NAM_Positor,
    AC.AC_NAM_Reliability,
    AC.AC_NAM_Assertion,
    AC.AC_NAM_Actor_Name,
    AC.AC_GEN_AC_ID,
    AC.Metadata_AC_GEN,
    AC.AC_GEN_ID,
    AC.AC_GEN_PositedAt,
    AC.AC_GEN_Positor,
    AC.AC_GEN_Reliability,
    AC.AC_GEN_Assertion,
    AC.AC_GEN_GEN_Gender,
    AC.AC_GEN_Metadata_GEN,
    AC.AC_GEN_GEN_ID,
    AC.AC_PLV_AC_ID,
    AC.Metadata_AC_PLV,
    AC.AC_PLV_ID,
    AC.AC_PLV_ChangedAt,
    AC.AC_PLV_PositedAt,
    AC.AC_PLV_Positor,
    AC.AC_PLV_Reliability,
    AC.AC_PLV_Assertion,
    AC.AC_PLV_PLV_Checksum,
    AC.AC_PLV_PLV_ProfessionalLevel,
    AC.AC_PLV_Metadata_PLV,
    AC.AC_PLV_PLV_ID
FROM
    public._Positor p
JOIN
(
    SELECT DISTINCT
        AC_NAM_Positor AS positor,
        AC_NAM_AC_ID AS AC_ID,
        AC_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public.AC_NAM_Actor_Name
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        AC_PLV_Positor AS positor,
        AC_PLV_AC_ID AS AC_ID,
        AC_PLV_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        public.AC_PLV_Actor_ProfessionalLevel
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p.Positor,
    TABLE(public.tAC_Actor(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) AC
WHERE
    AC.AC_ID = timepoints.AC_ID
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tPR_Program (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    PR_ID int,
    Metadata_PR int,
    PR_NAM_PR_ID int,
    Metadata_PR_NAM int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Positor tinyint,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_Assertion string,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt datetime,
    PR_LEN_Positor tinyint,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Assertion string,
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
    NAM.PR_NAM_Positor,
    NAM.PR_NAM_Reliability,
    NAM.PR_NAM_Assertion,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_PR_ID,
    LEN.Metadata_PR_LEN,
    LEN.PR_LEN_ID,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_PositedAt,
    LEN.PR_LEN_Positor,
    LEN.PR_LEN_Reliability,
    LEN.PR_LEN_Assertion,
    LEN.PR_LEN_Program_Length
FROM
    public.PR_Program PR
LEFT JOIN
    TABLE(public.rPR_NAM_Program_Name(
        positor,
        positingTimepoint::datetime
    )) NAM
ON
    NAM.PR_NAM_ID = (
        SELECT
            sub.PR_NAM_ID
        FROM
            TABLE(public.rPR_NAM_Program_Name(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.PR_NAM_PR_ID = PR.PR_ID
        AND
            sub.PR_NAM_Assertion = coalesce(assertion, sub.PR_NAM_Assertion)
        ORDER BY
            sub.PR_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rPR_LEN_Program_Length(
        positor,
        changingTimepoint::date,
        positingTimepoint::datetime
    )) LEN
ON
    LEN.PR_LEN_ID = (
        SELECT
            sub.PR_LEN_ID
        FROM
            TABLE(public.rPR_LEN_Program_Length(
                positor,
                changingTimepoint::date,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.PR_LEN_PR_ID = PR.PR_ID
        AND
            sub.PR_LEN_Assertion = coalesce(assertion, sub.PR_LEN_Assertion)
        ORDER BY
            sub.PR_LEN_ChangedAt DESC,
            sub.PR_LEN_PositedAt DESC
        LIMIT 1
    )
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lPR_Program COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) as Reliability,
    PR.*
FROM
    public._Positor p,
    TABLE(public.tPR_Program(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) PR
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pPR_Program (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    PR_ID int,
    Metadata_PR int,
    PR_NAM_PR_ID int,
    Metadata_PR_NAM int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Positor tinyint,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_Assertion string,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt datetime,
    PR_LEN_Positor tinyint,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Assertion string,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) as Reliability,
    PR.PR_ID,
    PR.Metadata_PR,
    PR.PR_NAM_PR_ID,
    PR.Metadata_PR_NAM,
    PR.PR_NAM_ID,
    PR.PR_NAM_PositedAt,
    PR.PR_NAM_Positor,
    PR.PR_NAM_Reliability,
    PR.PR_NAM_Assertion,
    PR.PR_NAM_Program_Name,
    PR.PR_LEN_PR_ID,
    PR.Metadata_PR_LEN,
    PR.PR_LEN_ID,
    PR.PR_LEN_ChangedAt,
    PR.PR_LEN_PositedAt,
    PR.PR_LEN_Positor,
    PR.PR_LEN_Reliability,
    PR.PR_LEN_Assertion,
    PR.PR_LEN_Program_Length
FROM
    public._Positor p,
    TABLE(public.tPR_Program(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) PR
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nPR_Program COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) as Reliability,
    PR.*
FROM
    public._Positor p,
    TABLE(public.tPR_Program(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) PR
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dPR_Program (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    PR_ID int,
    Metadata_PR int,
    PR_NAM_PR_ID int,
    Metadata_PR_NAM int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Positor tinyint,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_Assertion string,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt datetime,
    PR_LEN_Positor tinyint,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Assertion string,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    p.Positor,
    timepoints.inspectedTimepoint,
    PR.PR_ID,
    PR.Metadata_PR,
    PR.PR_NAM_PR_ID,
    PR.Metadata_PR_NAM,
    PR.PR_NAM_ID,
    PR.PR_NAM_PositedAt,
    PR.PR_NAM_Positor,
    PR.PR_NAM_Reliability,
    PR.PR_NAM_Assertion,
    PR.PR_NAM_Program_Name,
    PR.PR_LEN_PR_ID,
    PR.Metadata_PR_LEN,
    PR.PR_LEN_ID,
    PR.PR_LEN_ChangedAt,
    PR.PR_LEN_PositedAt,
    PR.PR_LEN_Positor,
    PR.PR_LEN_Reliability,
    PR.PR_LEN_Assertion,
    PR.PR_LEN_Program_Length
FROM
    public._Positor p
JOIN
(
    SELECT DISTINCT
        PR_LEN_Positor AS positor,
        PR_LEN_PR_ID AS PR_ID,
        PR_LEN_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        public.PR_LEN_Program_Length
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p.Positor,
    TABLE(public.tPR_Program(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) PR
WHERE
    PR.PR_ID = timepoints.PR_ID
$$
;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tEV_Event (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    EV_ID int,
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    kETY_of.ETY_EventType AS of_ETY_EventType,
    kETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_ID,
    DAT.EV_DAT_PositedAt,
    DAT.EV_DAT_Positor,
    DAT.EV_DAT_Reliability,
    DAT.EV_DAT_Assertion,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_ID,
    AUD.EV_AUD_PositedAt,
    AUD.EV_AUD_Positor,
    AUD.EV_AUD_Reliability,
    AUD.EV_AUD_Assertion,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_ID,
    REV.EV_REV_PositedAt,
    REV.EV_REV_Positor,
    REV.EV_REV_Reliability,
    REV.EV_REV_Assertion,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType kETY_of
ON
    kETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.rEV_DAT_Event_Date(
        positor,
        positingTimepoint::datetime
    )) DAT
ON
    DAT.EV_DAT_ID = (
        SELECT
            sub.EV_DAT_ID
        FROM
            TABLE(public.rEV_DAT_Event_Date(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_DAT_EV_ID = EV.EV_ID
        AND
            sub.EV_DAT_Assertion = coalesce(assertion, sub.EV_DAT_Assertion)
        ORDER BY
            sub.EV_DAT_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rEV_AUD_Event_Audience(
        positor,
        positingTimepoint::datetime
    )) AUD
ON
    AUD.EV_AUD_ID = (
        SELECT
            sub.EV_AUD_ID
        FROM
            TABLE(public.rEV_AUD_Event_Audience(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_AUD_EV_ID = EV.EV_ID
        AND
            sub.EV_AUD_Assertion = coalesce(assertion, sub.EV_AUD_Assertion)
        ORDER BY
            sub.EV_AUD_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rEV_REV_Event_Revenue(
        positor,
        positingTimepoint::datetime
    )) REV
ON
    REV.EV_REV_ID = (
        SELECT
            sub.EV_REV_ID
        FROM
            TABLE(public.rEV_REV_Event_Revenue(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_REV_EV_ID = EV.EV_ID
        AND
            sub.EV_REV_Assertion = coalesce(assertion, sub.EV_REV_Assertion)
        ORDER BY
            sub.EV_REV_PositedAt DESC
        LIMIT 1
    )
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lEV_Event COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    EV.*
FROM
    public._Positor p,
    TABLE(public.tEV_Event(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) EV
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    EV_ID int,
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    EV.of_ETY_EventType,
    EV.of_Metadata_ETY,
    EV.ETY_ID_of,
    EV.EV_DAT_EV_ID,
    EV.Metadata_EV_DAT,
    EV.EV_DAT_ID,
    EV.EV_DAT_PositedAt,
    EV.EV_DAT_Positor,
    EV.EV_DAT_Reliability,
    EV.EV_DAT_Assertion,
    EV.EV_DAT_Event_Date,
    EV.EV_AUD_EV_ID,
    EV.Metadata_EV_AUD,
    EV.EV_AUD_ID,
    EV.EV_AUD_PositedAt,
    EV.EV_AUD_Positor,
    EV.EV_AUD_Reliability,
    EV.EV_AUD_Assertion,
    EV.EV_AUD_Event_Audience,
    EV.EV_REV_EV_ID,
    EV.Metadata_EV_REV,
    EV.EV_REV_ID,
    EV.EV_REV_PositedAt,
    EV.EV_REV_Positor,
    EV.EV_REV_Reliability,
    EV.EV_REV_Assertion,
    EV.EV_REV_Event_Revenue
FROM
    public._Positor p,
    TABLE(public.tEV_Event(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) EV
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nEV_Event COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    EV.*
FROM
    public._Positor p,
    TABLE(public.tEV_Event(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) EV
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tAC_partner_AC_with_ONG_currently (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG int,
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string
)
AS
$$
SELECT
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_ID_partner,
    t.AC_ID_with,
    kONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    kONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    t.ONG_ID_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Positor,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_partner_AC_with_ONG_currently_Assertion
FROM
    TABLE(public.rAC_partner_AC_with_ONG_currently(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.ONG_Ongoing kONG_currently
ON
    kONG_currently.ONG_ID = t.ONG_ID_currently
WHERE
    t.AC_partner_AC_with_ONG_currently_Assertion = coalesce(assertion, t.AC_partner_AC_with_ONG_currently_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG int,
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.currently_ONG_Ongoing,
    t.currently_Metadata_ONG,
    t.ONG_ID_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Positor,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_partner_AC_with_ONG_currently_Assertion
FROM
    public._Positor p,
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG int,
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.currently_ONG_Ongoing,
    t.currently_Metadata_ONG,
    t.ONG_ID_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Positor,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_partner_AC_with_ONG_currently_Assertion
FROM
    public._Positor p
JOIN (
    SELECT DISTINCT
        AC_partner_AC_with_ONG_currently_Positor AS positor,
        AC_partner_AC_with_ONG_currently_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        public.AC_partner_AC_with_ONG_currently
    WHERE
        AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor,
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tAC_subset_PN_of (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_ID_subset int,
    PN_ID_of int,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Positor tinyint,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_subset_PN_of_Assertion string
)
AS
$$
SELECT
    t.Metadata_AC_subset_PN_of,
    t.AC_ID_subset,
    t.PN_ID_of,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Positor,
    t.AC_subset_PN_of_Reliability,
    t.AC_subset_PN_of_Assertion
FROM
    TABLE(public.rAC_subset_PN_of(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t.AC_subset_PN_of_Assertion = coalesce(assertion, t.AC_subset_PN_of_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_subset_PN_of COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tAC_subset_PN_of(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_AC_subset_PN_of int,
    AC_ID_subset int,
    PN_ID_of int,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Positor tinyint,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_subset_PN_of_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_AC_subset_PN_of,
    t.AC_ID_subset,
    t.PN_ID_of,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Positor,
    t.AC_subset_PN_of_Reliability,
    t.AC_subset_PN_of_Assertion
FROM
    public._Positor p,
    TABLE(public.tAC_subset_PN_of(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_subset_PN_of COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tAC_subset_PN_of(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tEV_in_AC_wasCast (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_ID_in int,
    AC_ID_wasCast int,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Positor tinyint,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_in_AC_wasCast_Assertion string
)
AS
$$
SELECT
    t.Metadata_EV_in_AC_wasCast,
    t.EV_ID_in,
    t.AC_ID_wasCast,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Positor,
    t.EV_in_AC_wasCast_Reliability,
    t.EV_in_AC_wasCast_Assertion
FROM
    TABLE(public.rEV_in_AC_wasCast(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t.EV_in_AC_wasCast_Assertion = coalesce(assertion, t.EV_in_AC_wasCast_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lEV_in_AC_wasCast COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tEV_in_AC_wasCast(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_EV_in_AC_wasCast int,
    EV_ID_in int,
    AC_ID_wasCast int,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Positor tinyint,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_in_AC_wasCast_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_EV_in_AC_wasCast,
    t.EV_ID_in,
    t.AC_ID_wasCast,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Positor,
    t.EV_in_AC_wasCast_Reliability,
    t.EV_in_AC_wasCast_Assertion
FROM
    public._Positor p,
    TABLE(public.tEV_in_AC_wasCast(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nEV_in_AC_wasCast COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tEV_in_AC_wasCast(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tAC_part_PR_in_RAT_got (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_Metadata_RAT int,
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string
)
AS
$$
SELECT
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_ID_part,
    t.PR_ID_in,
    kRAT_got.RAT_Rating AS got_RAT_Rating,
    kRAT_got.Metadata_RAT AS got_Metadata_RAT,
    t.RAT_ID_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Positor,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_part_PR_in_RAT_got_Assertion
FROM
    TABLE(public.rAC_part_PR_in_RAT_got(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.RAT_Rating kRAT_got
ON
    kRAT_got.RAT_ID = t.RAT_ID_got
WHERE
    t.AC_part_PR_in_RAT_got_Assertion = coalesce(assertion, t.AC_part_PR_in_RAT_got_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tAC_part_PR_in_RAT_got(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_AC_part_PR_in_RAT_got int,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_Metadata_RAT int,
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_ID_part,
    t.PR_ID_in,
    t.got_RAT_Rating,
    t.got_Metadata_RAT,
    t.RAT_ID_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Positor,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_part_PR_in_RAT_got_Assertion
FROM
    public._Positor p,
    TABLE(public.tAC_part_PR_in_RAT_got(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tAC_part_PR_in_RAT_got(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_AC_part_PR_in_RAT_got int,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_Metadata_RAT int,
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_ID_part,
    t.PR_ID_in,
    t.got_RAT_Rating,
    t.got_Metadata_RAT,
    t.RAT_ID_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Positor,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_part_PR_in_RAT_got_Assertion
FROM
    public._Positor p
JOIN (
    SELECT DISTINCT
        AC_part_PR_in_RAT_got_Positor AS positor,
        AC_part_PR_in_RAT_got_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        public.AC_part_PR_in_RAT_got
    WHERE
        AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor,
    TABLE(public.tAC_part_PR_in_RAT_got(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tST_at_PR_isPlaying (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_ID_at int,
    PR_ID_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string
)
AS
$$
SELECT
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_ID_at,
    t.PR_ID_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Positor,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_at_PR_isPlaying_Assertion
FROM
    TABLE(public.rST_at_PR_isPlaying(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t.ST_at_PR_isPlaying_Assertion = coalesce(assertion, t.ST_at_PR_isPlaying_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lST_at_PR_isPlaying COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tST_at_PR_isPlaying(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_ST_at_PR_isPlaying int,
    ST_ID_at int,
    PR_ID_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_ID_at,
    t.PR_ID_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Positor,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_at_PR_isPlaying_Assertion
FROM
    public._Positor p,
    TABLE(public.tST_at_PR_isPlaying(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nST_at_PR_isPlaying COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tST_at_PR_isPlaying(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_ST_at_PR_isPlaying int,
    ST_ID_at int,
    PR_ID_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_ID_at,
    t.PR_ID_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Positor,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_at_PR_isPlaying_Assertion
FROM
    public._Positor p
JOIN (
    SELECT DISTINCT
        ST_at_PR_isPlaying_Positor AS positor,
        ST_at_PR_isPlaying_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        public.ST_at_PR_isPlaying
    WHERE
        ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor,
    TABLE(public.tST_at_PR_isPlaying(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tAC_parent_AC_child_PAT_having (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_ID_parent int,
    AC_ID_child int,
    having_PAT_ParentalType varchar(42),
    having_Metadata_PAT int,
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Positor tinyint,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_parent_AC_child_PAT_having_Assertion string
)
AS
$$
SELECT
    t.Metadata_AC_parent_AC_child_PAT_having,
    t.AC_ID_parent,
    t.AC_ID_child,
    kPAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    kPAT_having.Metadata_PAT AS having_Metadata_PAT,
    t.PAT_ID_having,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Positor,
    t.AC_parent_AC_child_PAT_having_Reliability,
    t.AC_parent_AC_child_PAT_having_Assertion
FROM
    TABLE(public.rAC_parent_AC_child_PAT_having(
        positor,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.PAT_ParentalType kPAT_having
ON
    kPAT_having.PAT_ID = t.PAT_ID_having
WHERE
    t.AC_parent_AC_child_PAT_having_Assertion = coalesce(assertion, t.AC_parent_AC_child_PAT_having_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tAC_parent_AC_child_PAT_having(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_ID_parent int,
    AC_ID_child int,
    having_PAT_ParentalType varchar(42),
    having_Metadata_PAT int,
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Positor tinyint,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_parent_AC_child_PAT_having_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_AC_parent_AC_child_PAT_having,
    t.AC_ID_parent,
    t.AC_ID_child,
    t.having_PAT_ParentalType,
    t.having_Metadata_PAT,
    t.PAT_ID_having,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Positor,
    t.AC_parent_AC_child_PAT_having_Reliability,
    t.AC_parent_AC_child_PAT_having_Assertion
FROM
    public._Positor p,
    TABLE(public.tAC_parent_AC_child_PAT_having(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tAC_parent_AC_child_PAT_having(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tPR_content_ST_location_EV_of (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Positor tinyint,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_content_ST_location_EV_of_Assertion string
)
AS
$$
SELECT
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Positor,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_content_ST_location_EV_of_Assertion
FROM
    TABLE(public.rPR_content_ST_location_EV_of(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t.PR_content_ST_location_EV_of_Assertion = coalesce(assertion, t.PR_content_ST_location_EV_of_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tPR_content_ST_location_EV_of(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_PR_content_ST_location_EV_of int,
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Positor tinyint,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_content_ST_location_EV_of_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Positor,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_content_ST_location_EV_of_Assertion
FROM
    public._Positor p,
    TABLE(public.tPR_content_ST_location_EV_of(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    public._Positor p,
    TABLE(public.tPR_content_ST_location_EV_of(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- Snowflake does not enforce primary, unique or foreign keys, and every key here is declared RELY, which tells the
-- optimizer to trust it. A violation is therefore not an error, but wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--
-- In a concurrent reliance temporal model an attribute and a tie are a posit table and an annex table, each with a view. What is not
-- checked is restatement and whether the time of a posit overlaps another: the uni-temporal checks do not carry over.
--
-- A view that returns nothing has nothing wrong. IntegrityViolations is all of them together; it reads every table.
--
--   Construct     the table
--   Violation     what is wrong
--   ViolationKey  the key of the rows, as an object of column and value
--   Occurrences   how many rows
--
-- The orphan checks join to the table that is referred to and look for the rows without a match. They use a
-- column of the referred table in the WHERE clause, so a RELY foreign key cannot make the optimizer drop the join.
--
-- PAT_ParentalType integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PAT_ParentalType (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PAT_ParentalType',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PAT_ID', PAT_ID),
    COUNT(*)
FROM
    public.PAT_ParentalType
GROUP BY
    PAT_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_ParentalType',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PAT_ParentalType', PAT_ParentalType),
    COUNT(*)
FROM
    public.PAT_ParentalType
GROUP BY
    PAT_ParentalType
HAVING
    COUNT(*) > 1;
-- GEN_Gender integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_GEN_Gender (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'GEN_Gender',
    'duplicate primary key',
    OBJECT_CONSTRUCT('GEN_ID', GEN_ID),
    COUNT(*)
FROM
    public.GEN_Gender
GROUP BY
    GEN_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Gender',
    'duplicate unique key',
    OBJECT_CONSTRUCT('GEN_Gender', GEN_Gender),
    COUNT(*)
FROM
    public.GEN_Gender
GROUP BY
    GEN_Gender
HAVING
    COUNT(*) > 1;
-- PLV_ProfessionalLevel integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PLV_ProfessionalLevel (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PLV_ProfessionalLevel',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PLV_ID', PLV_ID),
    COUNT(*)
FROM
    public.PLV_ProfessionalLevel
GROUP BY
    PLV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PLV_ProfessionalLevel',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PLV_Checksum', PLV_Checksum),
    COUNT(*)
FROM
    public.PLV_ProfessionalLevel
GROUP BY
    PLV_Checksum
HAVING
    COUNT(*) > 1;
-- UTL_Utilization integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_UTL_Utilization (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'UTL_Utilization',
    'duplicate primary key',
    OBJECT_CONSTRUCT('UTL_ID', UTL_ID),
    COUNT(*)
FROM
    public.UTL_Utilization
GROUP BY
    UTL_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'UTL_Utilization',
    'duplicate unique key',
    OBJECT_CONSTRUCT('UTL_Utilization', UTL_Utilization),
    COUNT(*)
FROM
    public.UTL_Utilization
GROUP BY
    UTL_Utilization
HAVING
    COUNT(*) > 1;
-- ONG_Ongoing integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ONG_Ongoing (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ONG_Ongoing',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ONG_ID', ONG_ID),
    COUNT(*)
FROM
    public.ONG_Ongoing
GROUP BY
    ONG_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Ongoing',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ONG_Ongoing', ONG_Ongoing),
    COUNT(*)
FROM
    public.ONG_Ongoing
GROUP BY
    ONG_Ongoing
HAVING
    COUNT(*) > 1;
-- RAT_Rating integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_RAT_Rating (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'RAT_Rating',
    'duplicate primary key',
    OBJECT_CONSTRUCT('RAT_ID', RAT_ID),
    COUNT(*)
FROM
    public.RAT_Rating
GROUP BY
    RAT_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Rating',
    'duplicate unique key',
    OBJECT_CONSTRUCT('RAT_Rating', RAT_Rating),
    COUNT(*)
FROM
    public.RAT_Rating
GROUP BY
    RAT_Rating
HAVING
    COUNT(*) > 1;
-- ETY_EventType integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ETY_EventType (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ETY_EventType',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ETY_ID', ETY_ID),
    COUNT(*)
FROM
    public.ETY_EventType
GROUP BY
    ETY_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_EventType',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ETY_EventType', ETY_EventType),
    COUNT(*)
FROM
    public.ETY_EventType
GROUP BY
    ETY_EventType
HAVING
    COUNT(*) > 1;
-- PN_Person integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PN_Person (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PN_Person',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PN_ID', PN_ID),
    COUNT(*)
FROM
    public.PN_Person
GROUP BY
    PN_ID
HAVING
    COUNT(*) > 1;
-- ST_Stage integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_Stage (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_Stage',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_ID', ST_ID),
    COUNT(*)
FROM
    public.ST_Stage
GROUP BY
    ST_ID
HAVING
    COUNT(*) > 1;
-- AC_Actor integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_Actor (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_Actor',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_ID', AC_ID),
    COUNT(*)
FROM
    public.AC_Actor
GROUP BY
    AC_ID
HAVING
    COUNT(*) > 1;
-- PR_Program integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_Program (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_Program',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_ID', PR_ID),
    COUNT(*)
FROM
    public.PR_Program
GROUP BY
    PR_ID
HAVING
    COUNT(*) > 1;
-- EV_Event integrity -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_Event (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_Event',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_ID', EV_ID),
    COUNT(*)
FROM
    public.EV_Event
GROUP BY
    EV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_Event',
    'no row in ST_Stage for ST_ID_wasHeldAt',
    OBJECT_CONSTRUCT('ST_ID_wasHeldAt', c.ST_ID_wasHeldAt),
    COUNT(*)
FROM
    public.EV_Event c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_ID_wasHeldAt
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_ID_wasHeldAt
UNION ALL
SELECT
    'EV_Event',
    'no row in PR_Program for PR_ID_wasPlayed',
    OBJECT_CONSTRUCT('PR_ID_wasPlayed', c.PR_ID_wasPlayed),
    COUNT(*)
FROM
    public.EV_Event c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_ID_wasPlayed
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_ID_wasPlayed
UNION ALL
SELECT
    'EV_Event',
    'no row in ETY_EventType for ETY_ID_of',
    OBJECT_CONSTRUCT('ETY_ID_of', c.ETY_ID_of),
    COUNT(*)
FROM
    public.EV_Event c
LEFT JOIN
    public.ETY_EventType p
ON
    p.ETY_ID = c.ETY_ID_of
WHERE
    p.ETY_ID IS NULL
GROUP BY
    c.ETY_ID_of
;
-- EV_DAT_Event_Date_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_DAT_Event_Date_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Event_Date_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_DAT_ID', EV_DAT_ID),
    COUNT(*)
FROM
    public.EV_DAT_Event_Date_Posit
GROUP BY
    EV_DAT_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_DAT_EV_ID', EV_DAT_EV_ID,
        'EV_DAT_Event_Date', EV_DAT_Event_Date
    ),
    COUNT(*)
FROM
    public.EV_DAT_Event_Date_Posit
GROUP BY
    EV_DAT_EV_ID,
    EV_DAT_Event_Date
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Posit',
    'no row in EV_Event for EV_DAT_EV_ID',
    OBJECT_CONSTRUCT('EV_DAT_EV_ID', c.EV_DAT_EV_ID),
    COUNT(*)
FROM
    public.EV_DAT_Event_Date_Posit c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_DAT_EV_ID
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_DAT_EV_ID
;
-- EV_DAT_Event_Date_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_DAT_Event_Date_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Event_Date_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_DAT_ID', EV_DAT_ID,
        'EV_DAT_Positor', EV_DAT_Positor,
        'EV_DAT_PositedAt', EV_DAT_PositedAt
    ),
    COUNT(*)
FROM
    public.EV_DAT_Event_Date_Annex
GROUP BY
    EV_DAT_ID,
    EV_DAT_Positor,
    EV_DAT_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Annex',
    'no row in EV_DAT_Event_Date_Posit for EV_DAT_ID',
    OBJECT_CONSTRUCT('EV_DAT_ID', c.EV_DAT_ID),
    COUNT(*)
FROM
    public.EV_DAT_Event_Date_Annex c
LEFT JOIN
    public.EV_DAT_Event_Date_Posit p
ON
    p.EV_DAT_ID = c.EV_DAT_ID
WHERE
    p.EV_DAT_ID IS NULL
GROUP BY
    c.EV_DAT_ID
;
-- EV_AUD_Event_Audience_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_AUD_Event_Audience_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Event_Audience_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_AUD_ID', EV_AUD_ID),
    COUNT(*)
FROM
    public.EV_AUD_Event_Audience_Posit
GROUP BY
    EV_AUD_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_AUD_EV_ID', EV_AUD_EV_ID,
        'EV_AUD_Event_Audience', EV_AUD_Event_Audience
    ),
    COUNT(*)
FROM
    public.EV_AUD_Event_Audience_Posit
GROUP BY
    EV_AUD_EV_ID,
    EV_AUD_Event_Audience
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Posit',
    'no row in EV_Event for EV_AUD_EV_ID',
    OBJECT_CONSTRUCT('EV_AUD_EV_ID', c.EV_AUD_EV_ID),
    COUNT(*)
FROM
    public.EV_AUD_Event_Audience_Posit c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_AUD_EV_ID
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_AUD_EV_ID
;
-- EV_AUD_Event_Audience_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_AUD_Event_Audience_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Event_Audience_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_AUD_ID', EV_AUD_ID,
        'EV_AUD_Positor', EV_AUD_Positor,
        'EV_AUD_PositedAt', EV_AUD_PositedAt
    ),
    COUNT(*)
FROM
    public.EV_AUD_Event_Audience_Annex
GROUP BY
    EV_AUD_ID,
    EV_AUD_Positor,
    EV_AUD_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Annex',
    'no row in EV_AUD_Event_Audience_Posit for EV_AUD_ID',
    OBJECT_CONSTRUCT('EV_AUD_ID', c.EV_AUD_ID),
    COUNT(*)
FROM
    public.EV_AUD_Event_Audience_Annex c
LEFT JOIN
    public.EV_AUD_Event_Audience_Posit p
ON
    p.EV_AUD_ID = c.EV_AUD_ID
WHERE
    p.EV_AUD_ID IS NULL
GROUP BY
    c.EV_AUD_ID
;
-- EV_REV_Event_Revenue_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_REV_Event_Revenue_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Event_Revenue_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_REV_ID', EV_REV_ID),
    COUNT(*)
FROM
    public.EV_REV_Event_Revenue_Posit
GROUP BY
    EV_REV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_REV_EV_ID', EV_REV_EV_ID,
        'EV_REV_Event_Revenue', EV_REV_Event_Revenue
    ),
    COUNT(*)
FROM
    public.EV_REV_Event_Revenue_Posit
GROUP BY
    EV_REV_EV_ID,
    EV_REV_Event_Revenue
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Posit',
    'no row in EV_Event for EV_REV_EV_ID',
    OBJECT_CONSTRUCT('EV_REV_EV_ID', c.EV_REV_EV_ID),
    COUNT(*)
FROM
    public.EV_REV_Event_Revenue_Posit c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_REV_EV_ID
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_REV_EV_ID
;
-- EV_REV_Event_Revenue_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_REV_Event_Revenue_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Event_Revenue_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_REV_ID', EV_REV_ID,
        'EV_REV_Positor', EV_REV_Positor,
        'EV_REV_PositedAt', EV_REV_PositedAt
    ),
    COUNT(*)
FROM
    public.EV_REV_Event_Revenue_Annex
GROUP BY
    EV_REV_ID,
    EV_REV_Positor,
    EV_REV_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Annex',
    'no row in EV_REV_Event_Revenue_Posit for EV_REV_ID',
    OBJECT_CONSTRUCT('EV_REV_ID', c.EV_REV_ID),
    COUNT(*)
FROM
    public.EV_REV_Event_Revenue_Annex c
LEFT JOIN
    public.EV_REV_Event_Revenue_Posit p
ON
    p.EV_REV_ID = c.EV_REV_ID
WHERE
    p.EV_REV_ID IS NULL
GROUP BY
    c.EV_REV_ID
;
-- ST_NAM_Stage_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_NAM_Stage_Name_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Stage_Name_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_NAM_ID', ST_NAM_ID),
    COUNT(*)
FROM
    public.ST_NAM_Stage_Name_Posit
GROUP BY
    ST_NAM_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_NAM_ST_ID', ST_NAM_ST_ID,
        'ST_NAM_ChangedAt', ST_NAM_ChangedAt,
        'ST_NAM_Stage_Name', ST_NAM_Stage_Name
    ),
    COUNT(*)
FROM
    public.ST_NAM_Stage_Name_Posit
GROUP BY
    ST_NAM_ST_ID,
    ST_NAM_ChangedAt,
    ST_NAM_Stage_Name
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Posit',
    'no row in ST_Stage for ST_NAM_ST_ID',
    OBJECT_CONSTRUCT('ST_NAM_ST_ID', c.ST_NAM_ST_ID),
    COUNT(*)
FROM
    public.ST_NAM_Stage_Name_Posit c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_NAM_ST_ID
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_NAM_ST_ID
;
-- ST_NAM_Stage_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_NAM_Stage_Name_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Stage_Name_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_NAM_ID', ST_NAM_ID,
        'ST_NAM_Positor', ST_NAM_Positor,
        'ST_NAM_PositedAt', ST_NAM_PositedAt
    ),
    COUNT(*)
FROM
    public.ST_NAM_Stage_Name_Annex
GROUP BY
    ST_NAM_ID,
    ST_NAM_Positor,
    ST_NAM_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Annex',
    'no row in ST_NAM_Stage_Name_Posit for ST_NAM_ID',
    OBJECT_CONSTRUCT('ST_NAM_ID', c.ST_NAM_ID),
    COUNT(*)
FROM
    public.ST_NAM_Stage_Name_Annex c
LEFT JOIN
    public.ST_NAM_Stage_Name_Posit p
ON
    p.ST_NAM_ID = c.ST_NAM_ID
WHERE
    p.ST_NAM_ID IS NULL
GROUP BY
    c.ST_NAM_ID
;
-- ST_LOC_Stage_Location_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_LOC_Stage_Location_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Stage_Location_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_LOC_ID', ST_LOC_ID),
    COUNT(*)
FROM
    public.ST_LOC_Stage_Location_Posit
GROUP BY
    ST_LOC_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_LOC_ST_ID', ST_LOC_ST_ID,
        'ST_LOC_Checksum', ST_LOC_Checksum
    ),
    COUNT(*)
FROM
    public.ST_LOC_Stage_Location_Posit
GROUP BY
    ST_LOC_ST_ID,
    ST_LOC_Checksum
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Posit',
    'no row in ST_Stage for ST_LOC_ST_ID',
    OBJECT_CONSTRUCT('ST_LOC_ST_ID', c.ST_LOC_ST_ID),
    COUNT(*)
FROM
    public.ST_LOC_Stage_Location_Posit c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_LOC_ST_ID
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_LOC_ST_ID
;
-- ST_LOC_Stage_Location_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_LOC_Stage_Location_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Stage_Location_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_LOC_ID', ST_LOC_ID,
        'ST_LOC_Positor', ST_LOC_Positor,
        'ST_LOC_PositedAt', ST_LOC_PositedAt
    ),
    COUNT(*)
FROM
    public.ST_LOC_Stage_Location_Annex
GROUP BY
    ST_LOC_ID,
    ST_LOC_Positor,
    ST_LOC_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Annex',
    'no row in ST_LOC_Stage_Location_Posit for ST_LOC_ID',
    OBJECT_CONSTRUCT('ST_LOC_ID', c.ST_LOC_ID),
    COUNT(*)
FROM
    public.ST_LOC_Stage_Location_Annex c
LEFT JOIN
    public.ST_LOC_Stage_Location_Posit p
ON
    p.ST_LOC_ID = c.ST_LOC_ID
WHERE
    p.ST_LOC_ID IS NULL
GROUP BY
    c.ST_LOC_ID
;
-- ST_AVG_Stage_Average_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_AVG_Stage_Average_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Stage_Average_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_AVG_ID', ST_AVG_ID),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average_Posit
GROUP BY
    ST_AVG_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_AVG_ST_ID', ST_AVG_ST_ID,
        'ST_AVG_ChangedAt', ST_AVG_ChangedAt,
        'ST_AVG_UTL_ID', ST_AVG_UTL_ID
    ),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average_Posit
GROUP BY
    ST_AVG_ST_ID,
    ST_AVG_ChangedAt,
    ST_AVG_UTL_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'no row in ST_Stage for ST_AVG_ST_ID',
    OBJECT_CONSTRUCT('ST_AVG_ST_ID', c.ST_AVG_ST_ID),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average_Posit c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_AVG_ST_ID
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_AVG_ST_ID
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'no row in UTL_Utilization for ST_AVG_UTL_ID',
    OBJECT_CONSTRUCT('ST_AVG_UTL_ID', c.ST_AVG_UTL_ID),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average_Posit c
LEFT JOIN
    public.UTL_Utilization p
ON
    p.UTL_ID = c.ST_AVG_UTL_ID
WHERE
    p.UTL_ID IS NULL
GROUP BY
    c.ST_AVG_UTL_ID
;
-- ST_AVG_Stage_Average_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_AVG_Stage_Average_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Stage_Average_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_AVG_ID', ST_AVG_ID,
        'ST_AVG_Positor', ST_AVG_Positor,
        'ST_AVG_PositedAt', ST_AVG_PositedAt
    ),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average_Annex
GROUP BY
    ST_AVG_ID,
    ST_AVG_Positor,
    ST_AVG_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Annex',
    'no row in ST_AVG_Stage_Average_Posit for ST_AVG_ID',
    OBJECT_CONSTRUCT('ST_AVG_ID', c.ST_AVG_ID),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average_Annex c
LEFT JOIN
    public.ST_AVG_Stage_Average_Posit p
ON
    p.ST_AVG_ID = c.ST_AVG_ID
WHERE
    p.ST_AVG_ID IS NULL
GROUP BY
    c.ST_AVG_ID
;
-- ST_MIN_Stage_Minimum_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_MIN_Stage_Minimum_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_MIN_ID', ST_MIN_ID),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum_Posit
GROUP BY
    ST_MIN_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_MIN_ST_ID', ST_MIN_ST_ID,
        'ST_MIN_UTL_ID', ST_MIN_UTL_ID
    ),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum_Posit
GROUP BY
    ST_MIN_ST_ID,
    ST_MIN_UTL_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'no row in ST_Stage for ST_MIN_ST_ID',
    OBJECT_CONSTRUCT('ST_MIN_ST_ID', c.ST_MIN_ST_ID),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum_Posit c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_MIN_ST_ID
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_MIN_ST_ID
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'no row in UTL_Utilization for ST_MIN_UTL_ID',
    OBJECT_CONSTRUCT('ST_MIN_UTL_ID', c.ST_MIN_UTL_ID),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum_Posit c
LEFT JOIN
    public.UTL_Utilization p
ON
    p.UTL_ID = c.ST_MIN_UTL_ID
WHERE
    p.UTL_ID IS NULL
GROUP BY
    c.ST_MIN_UTL_ID
;
-- ST_MIN_Stage_Minimum_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_MIN_Stage_Minimum_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Stage_Minimum_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_MIN_ID', ST_MIN_ID,
        'ST_MIN_Positor', ST_MIN_Positor,
        'ST_MIN_PositedAt', ST_MIN_PositedAt
    ),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum_Annex
GROUP BY
    ST_MIN_ID,
    ST_MIN_Positor,
    ST_MIN_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Annex',
    'no row in ST_MIN_Stage_Minimum_Posit for ST_MIN_ID',
    OBJECT_CONSTRUCT('ST_MIN_ID', c.ST_MIN_ID),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum_Annex c
LEFT JOIN
    public.ST_MIN_Stage_Minimum_Posit p
ON
    p.ST_MIN_ID = c.ST_MIN_ID
WHERE
    p.ST_MIN_ID IS NULL
GROUP BY
    c.ST_MIN_ID
;
-- AC_NAM_Actor_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_NAM_Actor_Name_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Actor_Name_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_NAM_ID', AC_NAM_ID),
    COUNT(*)
FROM
    public.AC_NAM_Actor_Name_Posit
GROUP BY
    AC_NAM_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_NAM_AC_ID', AC_NAM_AC_ID,
        'AC_NAM_ChangedAt', AC_NAM_ChangedAt,
        'AC_NAM_Actor_Name', AC_NAM_Actor_Name
    ),
    COUNT(*)
FROM
    public.AC_NAM_Actor_Name_Posit
GROUP BY
    AC_NAM_AC_ID,
    AC_NAM_ChangedAt,
    AC_NAM_Actor_Name
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Posit',
    'no row in AC_Actor for AC_NAM_AC_ID',
    OBJECT_CONSTRUCT('AC_NAM_AC_ID', c.AC_NAM_AC_ID),
    COUNT(*)
FROM
    public.AC_NAM_Actor_Name_Posit c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_NAM_AC_ID
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_NAM_AC_ID
;
-- AC_NAM_Actor_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_NAM_Actor_Name_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Actor_Name_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_NAM_ID', AC_NAM_ID,
        'AC_NAM_Positor', AC_NAM_Positor,
        'AC_NAM_PositedAt', AC_NAM_PositedAt
    ),
    COUNT(*)
FROM
    public.AC_NAM_Actor_Name_Annex
GROUP BY
    AC_NAM_ID,
    AC_NAM_Positor,
    AC_NAM_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Annex',
    'no row in AC_NAM_Actor_Name_Posit for AC_NAM_ID',
    OBJECT_CONSTRUCT('AC_NAM_ID', c.AC_NAM_ID),
    COUNT(*)
FROM
    public.AC_NAM_Actor_Name_Annex c
LEFT JOIN
    public.AC_NAM_Actor_Name_Posit p
ON
    p.AC_NAM_ID = c.AC_NAM_ID
WHERE
    p.AC_NAM_ID IS NULL
GROUP BY
    c.AC_NAM_ID
;
-- AC_GEN_Actor_Gender_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_GEN_Actor_Gender_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_GEN_ID', AC_GEN_ID),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender_Posit
GROUP BY
    AC_GEN_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_GEN_AC_ID', AC_GEN_AC_ID,
        'AC_GEN_GEN_ID', AC_GEN_GEN_ID
    ),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender_Posit
GROUP BY
    AC_GEN_AC_ID,
    AC_GEN_GEN_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'no row in AC_Actor for AC_GEN_AC_ID',
    OBJECT_CONSTRUCT('AC_GEN_AC_ID', c.AC_GEN_AC_ID),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender_Posit c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_GEN_AC_ID
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_GEN_AC_ID
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'no row in GEN_Gender for AC_GEN_GEN_ID',
    OBJECT_CONSTRUCT('AC_GEN_GEN_ID', c.AC_GEN_GEN_ID),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender_Posit c
LEFT JOIN
    public.GEN_Gender p
ON
    p.GEN_ID = c.AC_GEN_GEN_ID
WHERE
    p.GEN_ID IS NULL
GROUP BY
    c.AC_GEN_GEN_ID
;
-- AC_GEN_Actor_Gender_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_GEN_Actor_Gender_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Actor_Gender_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_GEN_ID', AC_GEN_ID,
        'AC_GEN_Positor', AC_GEN_Positor,
        'AC_GEN_PositedAt', AC_GEN_PositedAt
    ),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender_Annex
GROUP BY
    AC_GEN_ID,
    AC_GEN_Positor,
    AC_GEN_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Annex',
    'no row in AC_GEN_Actor_Gender_Posit for AC_GEN_ID',
    OBJECT_CONSTRUCT('AC_GEN_ID', c.AC_GEN_ID),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender_Annex c
LEFT JOIN
    public.AC_GEN_Actor_Gender_Posit p
ON
    p.AC_GEN_ID = c.AC_GEN_ID
WHERE
    p.AC_GEN_ID IS NULL
GROUP BY
    c.AC_GEN_ID
;
-- AC_PLV_Actor_ProfessionalLevel_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_PLV_Actor_ProfessionalLevel_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_PLV_ID', AC_PLV_ID),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit
GROUP BY
    AC_PLV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_PLV_AC_ID', AC_PLV_AC_ID,
        'AC_PLV_ChangedAt', AC_PLV_ChangedAt,
        'AC_PLV_PLV_ID', AC_PLV_PLV_ID
    ),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit
GROUP BY
    AC_PLV_AC_ID,
    AC_PLV_ChangedAt,
    AC_PLV_PLV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'no row in AC_Actor for AC_PLV_AC_ID',
    OBJECT_CONSTRUCT('AC_PLV_AC_ID', c.AC_PLV_AC_ID),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_PLV_AC_ID
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_PLV_AC_ID
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'no row in PLV_ProfessionalLevel for AC_PLV_PLV_ID',
    OBJECT_CONSTRUCT('AC_PLV_PLV_ID', c.AC_PLV_PLV_ID),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit c
LEFT JOIN
    public.PLV_ProfessionalLevel p
ON
    p.PLV_ID = c.AC_PLV_PLV_ID
WHERE
    p.PLV_ID IS NULL
GROUP BY
    c.AC_PLV_PLV_ID
;
-- AC_PLV_Actor_ProfessionalLevel_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_PLV_Actor_ProfessionalLevel_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_PLV_ID', AC_PLV_ID,
        'AC_PLV_Positor', AC_PLV_Positor,
        'AC_PLV_PositedAt', AC_PLV_PositedAt
    ),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Annex
GROUP BY
    AC_PLV_ID,
    AC_PLV_Positor,
    AC_PLV_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Annex',
    'no row in AC_PLV_Actor_ProfessionalLevel_Posit for AC_PLV_ID',
    OBJECT_CONSTRUCT('AC_PLV_ID', c.AC_PLV_ID),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Annex c
LEFT JOIN
    public.AC_PLV_Actor_ProfessionalLevel_Posit p
ON
    p.AC_PLV_ID = c.AC_PLV_ID
WHERE
    p.AC_PLV_ID IS NULL
GROUP BY
    c.AC_PLV_ID
;
-- PR_NAM_Program_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_NAM_Program_Name_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Program_Name_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_NAM_ID', PR_NAM_ID),
    COUNT(*)
FROM
    public.PR_NAM_Program_Name_Posit
GROUP BY
    PR_NAM_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_NAM_PR_ID', PR_NAM_PR_ID,
        'PR_NAM_Program_Name', PR_NAM_Program_Name
    ),
    COUNT(*)
FROM
    public.PR_NAM_Program_Name_Posit
GROUP BY
    PR_NAM_PR_ID,
    PR_NAM_Program_Name
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Posit',
    'no row in PR_Program for PR_NAM_PR_ID',
    OBJECT_CONSTRUCT('PR_NAM_PR_ID', c.PR_NAM_PR_ID),
    COUNT(*)
FROM
    public.PR_NAM_Program_Name_Posit c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_NAM_PR_ID
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_NAM_PR_ID
;
-- PR_NAM_Program_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_NAM_Program_Name_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Program_Name_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_NAM_ID', PR_NAM_ID,
        'PR_NAM_Positor', PR_NAM_Positor,
        'PR_NAM_PositedAt', PR_NAM_PositedAt
    ),
    COUNT(*)
FROM
    public.PR_NAM_Program_Name_Annex
GROUP BY
    PR_NAM_ID,
    PR_NAM_Positor,
    PR_NAM_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Annex',
    'no row in PR_NAM_Program_Name_Posit for PR_NAM_ID',
    OBJECT_CONSTRUCT('PR_NAM_ID', c.PR_NAM_ID),
    COUNT(*)
FROM
    public.PR_NAM_Program_Name_Annex c
LEFT JOIN
    public.PR_NAM_Program_Name_Posit p
ON
    p.PR_NAM_ID = c.PR_NAM_ID
WHERE
    p.PR_NAM_ID IS NULL
GROUP BY
    c.PR_NAM_ID
;
-- PR_LEN_Program_Length_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_LEN_Program_Length_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Program_Length_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_LEN_ID', PR_LEN_ID),
    COUNT(*)
FROM
    public.PR_LEN_Program_Length_Posit
GROUP BY
    PR_LEN_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_LEN_PR_ID', PR_LEN_PR_ID,
        'PR_LEN_ChangedAt', PR_LEN_ChangedAt,
        'PR_LEN_Program_Length', PR_LEN_Program_Length
    ),
    COUNT(*)
FROM
    public.PR_LEN_Program_Length_Posit
GROUP BY
    PR_LEN_PR_ID,
    PR_LEN_ChangedAt,
    PR_LEN_Program_Length
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Posit',
    'no row in PR_Program for PR_LEN_PR_ID',
    OBJECT_CONSTRUCT('PR_LEN_PR_ID', c.PR_LEN_PR_ID),
    COUNT(*)
FROM
    public.PR_LEN_Program_Length_Posit c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_LEN_PR_ID
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_LEN_PR_ID
;
-- PR_LEN_Program_Length_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_LEN_Program_Length_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Program_Length_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_LEN_ID', PR_LEN_ID,
        'PR_LEN_Positor', PR_LEN_Positor,
        'PR_LEN_PositedAt', PR_LEN_PositedAt
    ),
    COUNT(*)
FROM
    public.PR_LEN_Program_Length_Annex
GROUP BY
    PR_LEN_ID,
    PR_LEN_Positor,
    PR_LEN_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Annex',
    'no row in PR_LEN_Program_Length_Posit for PR_LEN_ID',
    OBJECT_CONSTRUCT('PR_LEN_ID', c.PR_LEN_ID),
    COUNT(*)
FROM
    public.PR_LEN_Program_Length_Annex c
LEFT JOIN
    public.PR_LEN_Program_Length_Posit p
ON
    p.PR_LEN_ID = c.PR_LEN_ID
WHERE
    p.PR_LEN_ID IS NULL
GROUP BY
    c.PR_LEN_ID
;
-- AC_partner_AC_with_ONG_currently_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_partner_AC_with_ONG_currently_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_partner_AC_with_ONG_currently_ID', AC_partner_AC_with_ONG_currently_ID),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently_Posit
GROUP BY
    AC_partner_AC_with_ONG_currently_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', AC_ID_partner,
        'AC_ID_with', AC_ID_with,
        'ONG_ID_currently', ONG_ID_currently,
        'AC_partner_AC_with_ONG_currently_ChangedAt', AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently_Posit
GROUP BY
    AC_ID_partner,
    AC_ID_with,
    ONG_ID_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_partner)',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', AC_ID_partner,
        'AC_partner_AC_with_ONG_currently_ChangedAt', AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently_Posit
GROUP BY
    AC_ID_partner,
    AC_partner_AC_with_ONG_currently_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_with)',
    OBJECT_CONSTRUCT(
        'AC_ID_with', AC_ID_with,
        'AC_partner_AC_with_ONG_currently_ChangedAt', AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently_Posit
GROUP BY
    AC_ID_with,
    AC_partner_AC_with_ONG_currently_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Actor for AC_ID_partner',
    OBJECT_CONSTRUCT('AC_ID_partner', c.AC_ID_partner),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently_Posit c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_partner
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_partner
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Actor for AC_ID_with',
    OBJECT_CONSTRUCT('AC_ID_with', c.AC_ID_with),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently_Posit c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_with
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_with
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in ONG_Ongoing for ONG_ID_currently',
    OBJECT_CONSTRUCT('ONG_ID_currently', c.ONG_ID_currently),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently_Posit c
LEFT JOIN
    public.ONG_Ongoing p
ON
    p.ONG_ID = c.ONG_ID_currently
WHERE
    p.ONG_ID IS NULL
GROUP BY
    c.ONG_ID_currently
;
-- AC_partner_AC_with_ONG_currently_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_partner_AC_with_ONG_currently_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_partner_AC_with_ONG_currently_ID', AC_partner_AC_with_ONG_currently_ID,
        'AC_partner_AC_with_ONG_currently_Positor', AC_partner_AC_with_ONG_currently_Positor,
        'AC_partner_AC_with_ONG_currently_PositedAt', AC_partner_AC_with_ONG_currently_PositedAt
    ),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently_Annex
GROUP BY
    AC_partner_AC_with_ONG_currently_ID,
    AC_partner_AC_with_ONG_currently_Positor,
    AC_partner_AC_with_ONG_currently_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'no row in AC_partner_AC_with_ONG_currently_Posit for AC_partner_AC_with_ONG_currently_ID',
    OBJECT_CONSTRUCT('AC_partner_AC_with_ONG_currently_ID', c.AC_partner_AC_with_ONG_currently_ID),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently_Annex c
LEFT JOIN
    public.AC_partner_AC_with_ONG_currently_Posit p
ON
    p.AC_partner_AC_with_ONG_currently_ID = c.AC_partner_AC_with_ONG_currently_ID
WHERE
    p.AC_partner_AC_with_ONG_currently_ID IS NULL
GROUP BY
    c.AC_partner_AC_with_ONG_currently_ID
;
-- AC_subset_PN_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_subset_PN_of_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_subset_PN_of_ID', AC_subset_PN_of_ID),
    COUNT(*)
FROM
    public.AC_subset_PN_of_Posit
GROUP BY
    AC_subset_PN_of_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', AC_ID_subset,
        'PN_ID_of', PN_ID_of
    ),
    COUNT(*)
FROM
    public.AC_subset_PN_of_Posit
GROUP BY
    AC_ID_subset,
    PN_ID_of
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (AC_subset)',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', AC_ID_subset
    ),
    COUNT(*)
FROM
    public.AC_subset_PN_of_Posit
GROUP BY
    AC_ID_subset
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (PN_of)',
    OBJECT_CONSTRUCT(
        'PN_ID_of', PN_ID_of
    ),
    COUNT(*)
FROM
    public.AC_subset_PN_of_Posit
GROUP BY
    PN_ID_of
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in AC_Actor for AC_ID_subset',
    OBJECT_CONSTRUCT('AC_ID_subset', c.AC_ID_subset),
    COUNT(*)
FROM
    public.AC_subset_PN_of_Posit c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_subset
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_subset
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in PN_Person for PN_ID_of',
    OBJECT_CONSTRUCT('PN_ID_of', c.PN_ID_of),
    COUNT(*)
FROM
    public.AC_subset_PN_of_Posit c
LEFT JOIN
    public.PN_Person p
ON
    p.PN_ID = c.PN_ID_of
WHERE
    p.PN_ID IS NULL
GROUP BY
    c.PN_ID_of
;
-- AC_subset_PN_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_subset_PN_of_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_subset_PN_of_ID', AC_subset_PN_of_ID,
        'AC_subset_PN_of_Positor', AC_subset_PN_of_Positor,
        'AC_subset_PN_of_PositedAt', AC_subset_PN_of_PositedAt
    ),
    COUNT(*)
FROM
    public.AC_subset_PN_of_Annex
GROUP BY
    AC_subset_PN_of_ID,
    AC_subset_PN_of_Positor,
    AC_subset_PN_of_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Annex',
    'no row in AC_subset_PN_of_Posit for AC_subset_PN_of_ID',
    OBJECT_CONSTRUCT('AC_subset_PN_of_ID', c.AC_subset_PN_of_ID),
    COUNT(*)
FROM
    public.AC_subset_PN_of_Annex c
LEFT JOIN
    public.AC_subset_PN_of_Posit p
ON
    p.AC_subset_PN_of_ID = c.AC_subset_PN_of_ID
WHERE
    p.AC_subset_PN_of_ID IS NULL
GROUP BY
    c.AC_subset_PN_of_ID
;
-- EV_in_AC_wasCast_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_in_AC_wasCast_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_wasCast_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_in_AC_wasCast_ID', EV_in_AC_wasCast_ID),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast_Posit
GROUP BY
    EV_in_AC_wasCast_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_ID_in', EV_ID_in,
        'AC_ID_wasCast', AC_ID_wasCast
    ),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast_Posit
GROUP BY
    EV_ID_in,
    AC_ID_wasCast
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'no row in EV_Event for EV_ID_in',
    OBJECT_CONSTRUCT('EV_ID_in', c.EV_ID_in),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast_Posit c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_ID_in
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_ID_in
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'no row in AC_Actor for AC_ID_wasCast',
    OBJECT_CONSTRUCT('AC_ID_wasCast', c.AC_ID_wasCast),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast_Posit c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_wasCast
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_wasCast
;
-- EV_in_AC_wasCast_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_in_AC_wasCast_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_wasCast_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_in_AC_wasCast_ID', EV_in_AC_wasCast_ID,
        'EV_in_AC_wasCast_Positor', EV_in_AC_wasCast_Positor,
        'EV_in_AC_wasCast_PositedAt', EV_in_AC_wasCast_PositedAt
    ),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast_Annex
GROUP BY
    EV_in_AC_wasCast_ID,
    EV_in_AC_wasCast_Positor,
    EV_in_AC_wasCast_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Annex',
    'no row in EV_in_AC_wasCast_Posit for EV_in_AC_wasCast_ID',
    OBJECT_CONSTRUCT('EV_in_AC_wasCast_ID', c.EV_in_AC_wasCast_ID),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast_Annex c
LEFT JOIN
    public.EV_in_AC_wasCast_Posit p
ON
    p.EV_in_AC_wasCast_ID = c.EV_in_AC_wasCast_ID
WHERE
    p.EV_in_AC_wasCast_ID IS NULL
GROUP BY
    c.EV_in_AC_wasCast_ID
;
-- AC_part_PR_in_RAT_got_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_part_PR_in_RAT_got_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_part_PR_in_RAT_got_ID', AC_part_PR_in_RAT_got_ID),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got_Posit
GROUP BY
    AC_part_PR_in_RAT_got_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_part', AC_ID_part,
        'PR_ID_in', PR_ID_in,
        'RAT_ID_got', RAT_ID_got,
        'AC_part_PR_in_RAT_got_ChangedAt', AC_part_PR_in_RAT_got_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got_Posit
GROUP BY
    AC_ID_part,
    PR_ID_in,
    RAT_ID_got,
    AC_part_PR_in_RAT_got_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in AC_Actor for AC_ID_part',
    OBJECT_CONSTRUCT('AC_ID_part', c.AC_ID_part),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got_Posit c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_part
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_part
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in PR_Program for PR_ID_in',
    OBJECT_CONSTRUCT('PR_ID_in', c.PR_ID_in),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got_Posit c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_ID_in
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_ID_in
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in RAT_Rating for RAT_ID_got',
    OBJECT_CONSTRUCT('RAT_ID_got', c.RAT_ID_got),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got_Posit c
LEFT JOIN
    public.RAT_Rating p
ON
    p.RAT_ID = c.RAT_ID_got
WHERE
    p.RAT_ID IS NULL
GROUP BY
    c.RAT_ID_got
;
-- AC_part_PR_in_RAT_got_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_part_PR_in_RAT_got_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_part_PR_in_RAT_got_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_part_PR_in_RAT_got_ID', AC_part_PR_in_RAT_got_ID,
        'AC_part_PR_in_RAT_got_Positor', AC_part_PR_in_RAT_got_Positor,
        'AC_part_PR_in_RAT_got_PositedAt', AC_part_PR_in_RAT_got_PositedAt
    ),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got_Annex
GROUP BY
    AC_part_PR_in_RAT_got_ID,
    AC_part_PR_in_RAT_got_Positor,
    AC_part_PR_in_RAT_got_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Annex',
    'no row in AC_part_PR_in_RAT_got_Posit for AC_part_PR_in_RAT_got_ID',
    OBJECT_CONSTRUCT('AC_part_PR_in_RAT_got_ID', c.AC_part_PR_in_RAT_got_ID),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got_Annex c
LEFT JOIN
    public.AC_part_PR_in_RAT_got_Posit p
ON
    p.AC_part_PR_in_RAT_got_ID = c.AC_part_PR_in_RAT_got_ID
WHERE
    p.AC_part_PR_in_RAT_got_ID IS NULL
GROUP BY
    c.AC_part_PR_in_RAT_got_ID
;
-- ST_at_PR_isPlaying_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_at_PR_isPlaying_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_isPlaying_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_at_PR_isPlaying_ID', ST_at_PR_isPlaying_ID),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying_Posit
GROUP BY
    ST_at_PR_isPlaying_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_ID_at', ST_ID_at,
        'PR_ID_isPlaying', PR_ID_isPlaying,
        'ST_at_PR_isPlaying_ChangedAt', ST_at_PR_isPlaying_ChangedAt
    ),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying_Posit
GROUP BY
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'no row in ST_Stage for ST_ID_at',
    OBJECT_CONSTRUCT('ST_ID_at', c.ST_ID_at),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying_Posit c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_ID_at
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_ID_at
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'no row in PR_Program for PR_ID_isPlaying',
    OBJECT_CONSTRUCT('PR_ID_isPlaying', c.PR_ID_isPlaying),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying_Posit c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_ID_isPlaying
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_ID_isPlaying
;
-- ST_at_PR_isPlaying_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_at_PR_isPlaying_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_isPlaying_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_at_PR_isPlaying_ID', ST_at_PR_isPlaying_ID,
        'ST_at_PR_isPlaying_Positor', ST_at_PR_isPlaying_Positor,
        'ST_at_PR_isPlaying_PositedAt', ST_at_PR_isPlaying_PositedAt
    ),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying_Annex
GROUP BY
    ST_at_PR_isPlaying_ID,
    ST_at_PR_isPlaying_Positor,
    ST_at_PR_isPlaying_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Annex',
    'no row in ST_at_PR_isPlaying_Posit for ST_at_PR_isPlaying_ID',
    OBJECT_CONSTRUCT('ST_at_PR_isPlaying_ID', c.ST_at_PR_isPlaying_ID),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying_Annex c
LEFT JOIN
    public.ST_at_PR_isPlaying_Posit p
ON
    p.ST_at_PR_isPlaying_ID = c.ST_at_PR_isPlaying_ID
WHERE
    p.ST_at_PR_isPlaying_ID IS NULL
GROUP BY
    c.ST_at_PR_isPlaying_ID
;
-- AC_parent_AC_child_PAT_having_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_parent_AC_child_PAT_having_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_parent_AC_child_PAT_having_ID', AC_parent_AC_child_PAT_having_ID),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having_Posit
GROUP BY
    AC_parent_AC_child_PAT_having_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_parent', AC_ID_parent,
        'AC_ID_child', AC_ID_child,
        'PAT_ID_having', PAT_ID_having
    ),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having_Posit
GROUP BY
    AC_ID_parent,
    AC_ID_child,
    PAT_ID_having
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in AC_Actor for AC_ID_parent',
    OBJECT_CONSTRUCT('AC_ID_parent', c.AC_ID_parent),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having_Posit c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_parent
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_parent
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in AC_Actor for AC_ID_child',
    OBJECT_CONSTRUCT('AC_ID_child', c.AC_ID_child),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having_Posit c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_child
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_child
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in PAT_ParentalType for PAT_ID_having',
    OBJECT_CONSTRUCT('PAT_ID_having', c.PAT_ID_having),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having_Posit c
LEFT JOIN
    public.PAT_ParentalType p
ON
    p.PAT_ID = c.PAT_ID_having
WHERE
    p.PAT_ID IS NULL
GROUP BY
    c.PAT_ID_having
;
-- AC_parent_AC_child_PAT_having_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_parent_AC_child_PAT_having_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_parent_AC_child_PAT_having_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_parent_AC_child_PAT_having_ID', AC_parent_AC_child_PAT_having_ID,
        'AC_parent_AC_child_PAT_having_Positor', AC_parent_AC_child_PAT_having_Positor,
        'AC_parent_AC_child_PAT_having_PositedAt', AC_parent_AC_child_PAT_having_PositedAt
    ),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having_Annex
GROUP BY
    AC_parent_AC_child_PAT_having_ID,
    AC_parent_AC_child_PAT_having_Positor,
    AC_parent_AC_child_PAT_having_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Annex',
    'no row in AC_parent_AC_child_PAT_having_Posit for AC_parent_AC_child_PAT_having_ID',
    OBJECT_CONSTRUCT('AC_parent_AC_child_PAT_having_ID', c.AC_parent_AC_child_PAT_having_ID),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having_Annex c
LEFT JOIN
    public.AC_parent_AC_child_PAT_having_Posit p
ON
    p.AC_parent_AC_child_PAT_having_ID = c.AC_parent_AC_child_PAT_having_ID
WHERE
    p.AC_parent_AC_child_PAT_having_ID IS NULL
GROUP BY
    c.AC_parent_AC_child_PAT_having_ID
;
-- PR_content_ST_location_EV_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_content_ST_location_EV_of_Posit (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_content_ST_location_EV_of_ID', PR_content_ST_location_EV_of_ID),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of_Posit
GROUP BY
    PR_content_ST_location_EV_of_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_ID_content', PR_ID_content,
        'ST_ID_location', ST_ID_location,
        'EV_ID_of', EV_ID_of
    ),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of_Posit
GROUP BY
    PR_ID_content,
    ST_ID_location,
    EV_ID_of
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in PR_Program for PR_ID_content',
    OBJECT_CONSTRUCT('PR_ID_content', c.PR_ID_content),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of_Posit c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_ID_content
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_ID_content
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in ST_Stage for ST_ID_location',
    OBJECT_CONSTRUCT('ST_ID_location', c.ST_ID_location),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of_Posit c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_ID_location
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_ID_location
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in EV_Event for EV_ID_of',
    OBJECT_CONSTRUCT('EV_ID_of', c.EV_ID_of),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of_Posit c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_ID_of
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_ID_of
;
-- PR_content_ST_location_EV_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_content_ST_location_EV_of_Annex (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_content_ST_location_EV_of_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_content_ST_location_EV_of_ID', PR_content_ST_location_EV_of_ID,
        'PR_content_ST_location_EV_of_Positor', PR_content_ST_location_EV_of_Positor,
        'PR_content_ST_location_EV_of_PositedAt', PR_content_ST_location_EV_of_PositedAt
    ),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of_Annex
GROUP BY
    PR_content_ST_location_EV_of_ID,
    PR_content_ST_location_EV_of_Positor,
    PR_content_ST_location_EV_of_PositedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Annex',
    'no row in PR_content_ST_location_EV_of_Posit for PR_content_ST_location_EV_of_ID',
    OBJECT_CONSTRUCT('PR_content_ST_location_EV_of_ID', c.PR_content_ST_location_EV_of_ID),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of_Annex c
LEFT JOIN
    public.PR_content_ST_location_EV_of_Posit p
ON
    p.PR_content_ST_location_EV_of_ID = c.PR_content_ST_location_EV_of_ID
WHERE
    p.PR_content_ST_location_EV_of_ID IS NULL
GROUP BY
    c.PR_content_ST_location_EV_of_ID
;
-- IntegrityViolations ------------------------------------------------------------------------------------------------
-- Every integrity check of the model, in one view.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.IntegrityViolations (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR),
    CAST(NULL AS OBJECT),
    CAST(NULL AS NUMBER)
WHERE
    FALSE
UNION ALL SELECT * FROM public.ic_PAT_ParentalType
UNION ALL SELECT * FROM public.ic_GEN_Gender
UNION ALL SELECT * FROM public.ic_PLV_ProfessionalLevel
UNION ALL SELECT * FROM public.ic_UTL_Utilization
UNION ALL SELECT * FROM public.ic_ONG_Ongoing
UNION ALL SELECT * FROM public.ic_RAT_Rating
UNION ALL SELECT * FROM public.ic_ETY_EventType
UNION ALL SELECT * FROM public.ic_PN_Person
UNION ALL SELECT * FROM public.ic_ST_Stage
UNION ALL SELECT * FROM public.ic_AC_Actor
UNION ALL SELECT * FROM public.ic_PR_Program
UNION ALL SELECT * FROM public.ic_EV_Event
UNION ALL SELECT * FROM public.ic_EV_DAT_Event_Date_Posit
UNION ALL SELECT * FROM public.ic_EV_DAT_Event_Date_Annex
UNION ALL SELECT * FROM public.ic_EV_AUD_Event_Audience_Posit
UNION ALL SELECT * FROM public.ic_EV_AUD_Event_Audience_Annex
UNION ALL SELECT * FROM public.ic_EV_REV_Event_Revenue_Posit
UNION ALL SELECT * FROM public.ic_EV_REV_Event_Revenue_Annex
UNION ALL SELECT * FROM public.ic_ST_NAM_Stage_Name_Posit
UNION ALL SELECT * FROM public.ic_ST_NAM_Stage_Name_Annex
UNION ALL SELECT * FROM public.ic_ST_LOC_Stage_Location_Posit
UNION ALL SELECT * FROM public.ic_ST_LOC_Stage_Location_Annex
UNION ALL SELECT * FROM public.ic_ST_AVG_Stage_Average_Posit
UNION ALL SELECT * FROM public.ic_ST_AVG_Stage_Average_Annex
UNION ALL SELECT * FROM public.ic_ST_MIN_Stage_Minimum_Posit
UNION ALL SELECT * FROM public.ic_ST_MIN_Stage_Minimum_Annex
UNION ALL SELECT * FROM public.ic_AC_NAM_Actor_Name_Posit
UNION ALL SELECT * FROM public.ic_AC_NAM_Actor_Name_Annex
UNION ALL SELECT * FROM public.ic_AC_GEN_Actor_Gender_Posit
UNION ALL SELECT * FROM public.ic_AC_GEN_Actor_Gender_Annex
UNION ALL SELECT * FROM public.ic_AC_PLV_Actor_ProfessionalLevel_Posit
UNION ALL SELECT * FROM public.ic_AC_PLV_Actor_ProfessionalLevel_Annex
UNION ALL SELECT * FROM public.ic_PR_NAM_Program_Name_Posit
UNION ALL SELECT * FROM public.ic_PR_NAM_Program_Name_Annex
UNION ALL SELECT * FROM public.ic_PR_LEN_Program_Length_Posit
UNION ALL SELECT * FROM public.ic_PR_LEN_Program_Length_Annex
UNION ALL SELECT * FROM public.ic_AC_partner_AC_with_ONG_currently_Posit
UNION ALL SELECT * FROM public.ic_AC_partner_AC_with_ONG_currently_Annex
UNION ALL SELECT * FROM public.ic_AC_subset_PN_of_Posit
UNION ALL SELECT * FROM public.ic_AC_subset_PN_of_Annex
UNION ALL SELECT * FROM public.ic_EV_in_AC_wasCast_Posit
UNION ALL SELECT * FROM public.ic_EV_in_AC_wasCast_Annex
UNION ALL SELECT * FROM public.ic_AC_part_PR_in_RAT_got_Posit
UNION ALL SELECT * FROM public.ic_AC_part_PR_in_RAT_got_Annex
UNION ALL SELECT * FROM public.ic_ST_at_PR_isPlaying_Posit
UNION ALL SELECT * FROM public.ic_ST_at_PR_isPlaying_Annex
UNION ALL SELECT * FROM public.ic_AC_parent_AC_child_PAT_having_Posit
UNION ALL SELECT * FROM public.ic_AC_parent_AC_child_PAT_having_Annex
UNION ALL SELECT * FROM public.ic_PR_content_ST_location_EV_of_Posit
UNION ALL SELECT * FROM public.ic_PR_content_ST_location_EV_of_Annex
;-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers. Views get their comments when they are
-- created, since Snowflake does not allow comments on view columns to be added afterwards.
--
COMMENT ON SCHEMA public IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE public.PAT_ParentalType IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON COLUMN public.PAT_ParentalType.PAT_ParentalType IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE public.GEN_Gender IS 'Gender of an actor.';
COMMENT ON COLUMN public.GEN_Gender.GEN_Gender IS 'Gender of an actor.';
COMMENT ON TABLE public.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN public.PLV_ProfessionalLevel.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE public.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN public.UTL_Utilization.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE public.ONG_Ongoing IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN public.ONG_Ongoing.ONG_Ongoing IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE public.RAT_Rating IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN public.RAT_Rating.RAT_Rating IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON TABLE public.ETY_EventType IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN public.ETY_EventType.ETY_EventType IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN public.EV_DAT_Event_Date_Posit.EV_DAT_Event_Date IS 'Date and time when the event took place.';
COMMENT ON COLUMN public.EV_AUD_Event_Audience_Posit.EV_AUD_Event_Audience IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN public.EV_REV_Event_Revenue_Posit.EV_REV_Event_Revenue IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN public.ST_NAM_Stage_Name_Posit.ST_NAM_Stage_Name IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN public.ST_LOC_Stage_Location_Posit.ST_LOC_Stage_Location IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN public.ST_AVG_Stage_Average_Posit.ST_AVG_UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN public.ST_MIN_Stage_Minimum_Posit.ST_MIN_UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN public.AC_NAM_Actor_Name_Posit.AC_NAM_Actor_Name IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN public.AC_GEN_Actor_Gender_Posit.AC_GEN_GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN public.AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN public.PR_NAM_Program_Name_Posit.PR_NAM_Program_Name IS 'Name or title of the program.';
COMMENT ON COLUMN public.PR_LEN_Program_Length_Posit.PR_LEN_Program_Length IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE public.PN_Person IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE public.ST_Stage IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE public.AC_Actor IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE public.PR_Program IS 'A program, such as a play, show or concert, that can be played on stages.';
COMMENT ON TABLE public.EV_Event IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN public.EV_Event.ST_ID_wasHeldAt IS 'The stage at which the event was held.';
COMMENT ON COLUMN public.EV_Event.PR_ID_wasPlayed IS 'The program that was played at the event.';
COMMENT ON COLUMN public.EV_Event.ETY_ID_of IS 'The type of the event.';
COMMENT ON TABLE public.AC_partner_AC_with_ONG_currently_Posit IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN public.AC_partner_AC_with_ONG_currently_Posit.AC_ID_partner IS 'One of the actors in the partnership.';
COMMENT ON COLUMN public.AC_partner_AC_with_ONG_currently_Posit.AC_ID_with IS 'The other actor in the partnership.';
COMMENT ON COLUMN public.AC_partner_AC_with_ONG_currently_Posit.ONG_ID_currently IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON TABLE public.AC_subset_PN_of_Posit IS 'Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.';
COMMENT ON COLUMN public.AC_subset_PN_of_Posit.AC_ID_subset IS 'The actor.';
COMMENT ON COLUMN public.AC_subset_PN_of_Posit.PN_ID_of IS 'The person who is the actor.';
COMMENT ON TABLE public.EV_in_AC_wasCast_Posit IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN public.EV_in_AC_wasCast_Posit.EV_ID_in IS 'The event the actor was cast in.';
COMMENT ON COLUMN public.EV_in_AC_wasCast_Posit.AC_ID_wasCast IS 'An actor cast in the event.';
COMMENT ON TABLE public.AC_part_PR_in_RAT_got_Posit IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN public.AC_part_PR_in_RAT_got_Posit.AC_ID_part IS 'The actor having a part in the program.';
COMMENT ON COLUMN public.AC_part_PR_in_RAT_got_Posit.PR_ID_in IS 'The program the actor has a part in.';
COMMENT ON COLUMN public.AC_part_PR_in_RAT_got_Posit.RAT_ID_got IS 'The rating the actor got for the part.';
COMMENT ON TABLE public.ST_at_PR_isPlaying_Posit IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN public.ST_at_PR_isPlaying_Posit.ST_ID_at IS 'The stage where the program is playing.';
COMMENT ON COLUMN public.ST_at_PR_isPlaying_Posit.PR_ID_isPlaying IS 'The program playing at the stage.';
COMMENT ON TABLE public.AC_parent_AC_child_PAT_having_Posit IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN public.AC_parent_AC_child_PAT_having_Posit.AC_ID_parent IS 'The actor who is the parent.';
COMMENT ON COLUMN public.AC_parent_AC_child_PAT_having_Posit.AC_ID_child IS 'The actor who is the child.';
COMMENT ON COLUMN public.AC_parent_AC_child_PAT_having_Posit.PAT_ID_having IS 'The type of parental relationship.';
COMMENT ON TABLE public.PR_content_ST_location_EV_of_Posit IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN public.PR_content_ST_location_EV_of_Posit.PR_ID_content IS 'The program that made up the content of the event.';
COMMENT ON COLUMN public.PR_content_ST_location_EV_of_Posit.ST_ID_location IS 'The stage where the event was located.';
COMMENT ON COLUMN public.PR_content_ST_location_EV_of_Posit.EV_ID_of IS 'The event.';
