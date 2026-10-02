-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are immutable lookup tables for values.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PAT_ParentalType (
    PAT_ID tinyint not null,
    PAT_ParentalType varchar(42) not null,
    constraint pkPAT_ParentalType primary key (
        PAT_ID
    ) RELY,
    constraint uqPAT_ParentalType unique (
        PAT_ParentalType
    ) RELY
) CLUSTER BY (PAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.GEN_Gender (
    GEN_ID number(1,0) not null,
    GEN_Gender varchar(42) not null,
    constraint pkGEN_Gender primary key (
        GEN_ID
    ) RELY,
    constraint uqGEN_Gender unique (
        GEN_Gender
    ) RELY
) CLUSTER BY (GEN_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PLV_ProfessionalLevel (
    PLV_ID tinyint not null,
    PLV_ProfessionalLevel string not null,
    PLV_Checksum numeric(19,0) default hash(PLV_ProfessionalLevel),
    constraint pkPLV_ProfessionalLevel primary key (
        PLV_ID
    ) RELY,
    constraint uqPLV_ProfessionalLevel unique (
        PLV_Checksum 
    ) RELY
) CLUSTER BY (PLV_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.UTL_Utilization (
    UTL_ID tinyint not null,
    UTL_Utilization tinyint not null,
    constraint pkUTL_Utilization primary key (
        UTL_ID
    ) RELY,
    constraint uqUTL_Utilization unique (
        UTL_Utilization
    ) RELY
) CLUSTER BY (UTL_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ONG_Ongoing (
    ONG_ID tinyint not null,
    ONG_Ongoing varchar(3) not null,
    constraint pkONG_Ongoing primary key (
        ONG_ID
    ) RELY,
    constraint uqONG_Ongoing unique (
        ONG_Ongoing
    ) RELY
) CLUSTER BY (ONG_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.RAT_Rating (
    RAT_ID tinyint not null,
    RAT_Rating varchar(42) not null,
    constraint pkRAT_Rating primary key (
        RAT_ID
    ) RELY,
    constraint uqRAT_Rating unique (
        RAT_Rating
    ) RELY
) CLUSTER BY (RAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ETY_EventType (
    ETY_ID tinyint not null,
    ETY_EventType varchar(42) not null,
    constraint pkETY_EventType primary key (
        ETY_ID
    ) RELY,
    constraint uqETY_EventType unique (
        ETY_EventType
    ) RELY
) CLUSTER BY (ETY_ID);
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors store immutable entity identities.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.PN_Person_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PN_Person (
    PN_ID int default public.PN_Person_ID_SEQ.nextval not null, 
    constraint pkPN_Person primary key (
        PN_ID
    ) RELY
) CLUSTER BY (PN_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.ST_Stage_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.ST_Stage (
    ST_ID int default public.ST_Stage_ID_SEQ.nextval not null, 
    constraint pkST_Stage primary key (
        ST_ID
    ) RELY
) CLUSTER BY (ST_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.AC_Actor_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.AC_Actor (
    AC_ID int default public.AC_Actor_ID_SEQ.nextval not null, 
    constraint pkAC_Actor primary key (
        AC_ID
    ) RELY
) CLUSTER BY (AC_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.PR_Program_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PR_Program (
    PR_ID int default public.PR_Program_ID_SEQ.nextval not null, 
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
CREATE TABLE IF NOT EXISTS public.EV_Event (
    EV_ID int IDENTITY(1,1) not null, 
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
    EV_Dummy boolean null,
    constraint pkEV_Event primary key (
        EV_ID
    ) RELY
) CLUSTER BY (EV_ID);
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
CREATE TABLE IF NOT EXISTS public.EV_DAT_Event_Date_Posit (
    EV_DAT_ID int IDENTITY(1,1) not null, 
    EV_ID int not null,
    EV_DAT_Event_Date datetime not null,
    constraint fkEV_DAT_Event_Date_Posit foreign key (
        EV_ID
    ) references public.EV_Event(EV_ID) RELY,
    constraint pkEV_DAT_Event_Date_Posit primary key (
        EV_DAT_ID
    ) RELY,
    constraint uqEV_DAT_Event_Date_Posit unique (
        EV_ID,
        EV_DAT_Event_Date
    ) RELY
) CLUSTER BY (EV_ID);
CREATE TABLE IF NOT EXISTS public.EV_DAT_Event_Date_Annex (
    EV_DAT_ID int not null,
    EV_DAT_PositedAt datetime not null,
    EV_DAT_Reliability decimal(5,2) not null,
    constraint fkEV_DAT_Event_Date_Annex foreign key (
        EV_DAT_ID
    ) references public.EV_DAT_Event_Date_Posit(EV_DAT_ID) RELY,
    constraint pkEV_DAT_Event_Date_Annex primary key (
        EV_DAT_ID,
        EV_DAT_PositedAt
    ) RELY
) CLUSTER BY (EV_DAT_ID, EV_DAT_PositedAt);
CREATE TABLE IF NOT EXISTS public.EV_AUD_Event_Audience_Posit (
    EV_AUD_ID int IDENTITY(1,1) not null, 
    EV_ID int not null,
    EV_AUD_Event_Audience int not null,
    constraint fkEV_AUD_Event_Audience_Posit foreign key (
        EV_ID
    ) references public.EV_Event(EV_ID) RELY,
    constraint pkEV_AUD_Event_Audience_Posit primary key (
        EV_AUD_ID
    ) RELY,
    constraint uqEV_AUD_Event_Audience_Posit unique (
        EV_ID,
        EV_AUD_Event_Audience
    ) RELY
) CLUSTER BY (EV_ID);
CREATE TABLE IF NOT EXISTS public.EV_AUD_Event_Audience_Annex (
    EV_AUD_ID int not null,
    EV_AUD_PositedAt datetime not null,
    EV_AUD_Reliability decimal(5,2) not null,
    constraint fkEV_AUD_Event_Audience_Annex foreign key (
        EV_AUD_ID
    ) references public.EV_AUD_Event_Audience_Posit(EV_AUD_ID) RELY,
    constraint pkEV_AUD_Event_Audience_Annex primary key (
        EV_AUD_ID,
        EV_AUD_PositedAt
    ) RELY
) CLUSTER BY (EV_AUD_ID, EV_AUD_PositedAt);
CREATE TABLE IF NOT EXISTS public.EV_REV_Event_Revenue_Posit (
    EV_REV_ID int IDENTITY(1,1) not null, 
    EV_ID int not null,
    EV_REV_Event_Revenue number(19,4) not null,
    constraint fkEV_REV_Event_Revenue_Posit foreign key (
        EV_ID
    ) references public.EV_Event(EV_ID) RELY,
    constraint pkEV_REV_Event_Revenue_Posit primary key (
        EV_REV_ID
    ) RELY,
    constraint uqEV_REV_Event_Revenue_Posit unique (
        EV_ID,
        EV_REV_Event_Revenue
    ) RELY
) CLUSTER BY (EV_ID);
CREATE TABLE IF NOT EXISTS public.EV_REV_Event_Revenue_Annex (
    EV_REV_ID int not null,
    EV_REV_PositedAt datetime not null,
    EV_REV_Reliability decimal(5,2) not null,
    constraint fkEV_REV_Event_Revenue_Annex foreign key (
        EV_REV_ID
    ) references public.EV_REV_Event_Revenue_Posit(EV_REV_ID) RELY,
    constraint pkEV_REV_Event_Revenue_Annex primary key (
        EV_REV_ID,
        EV_REV_PositedAt
    ) RELY
) CLUSTER BY (EV_REV_ID, EV_REV_PositedAt);
CREATE TABLE IF NOT EXISTS public.ST_NAM_Stage_Name_Posit (
    ST_NAM_ID int IDENTITY(1,1) not null, 
    ST_ID int not null,
    ST_NAM_Stage_Name varchar(42) not null,
    ST_NAM_ChangedAt datetime not null,
    constraint fkST_NAM_Stage_Name_Posit foreign key (
        ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint pkST_NAM_Stage_Name_Posit primary key (
        ST_NAM_ID
    ) RELY,
    constraint uqST_NAM_Stage_Name_Posit unique (
        ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    ) RELY
) CLUSTER BY (ST_ID);
CREATE TABLE IF NOT EXISTS public.ST_NAM_Stage_Name_Annex (
    ST_NAM_ID int not null,
    ST_NAM_PositedAt datetime not null,
    ST_NAM_Reliability decimal(5,2) not null,
    constraint fkST_NAM_Stage_Name_Annex foreign key (
        ST_NAM_ID
    ) references public.ST_NAM_Stage_Name_Posit(ST_NAM_ID) RELY,
    constraint pkST_NAM_Stage_Name_Annex primary key (
        ST_NAM_ID,
        ST_NAM_PositedAt
    ) RELY
) CLUSTER BY (ST_NAM_ID, ST_NAM_PositedAt);
CREATE TABLE IF NOT EXISTS public.ST_LOC_Stage_Location_Posit (
    ST_LOC_ID int IDENTITY(1,1) not null, 
    ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum numeric(19,0) default hash(ST_LOC_Stage_Location),
    constraint fkST_LOC_Stage_Location_Posit foreign key (
        ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint pkST_LOC_Stage_Location_Posit primary key (
        ST_LOC_ID
    ) RELY,
    constraint uqST_LOC_Stage_Location_Posit unique (
        ST_ID,
        ST_LOC_Checksum 
    ) RELY
) CLUSTER BY (ST_ID);
CREATE TABLE IF NOT EXISTS public.ST_LOC_Stage_Location_Annex (
    ST_LOC_ID int not null,
    ST_LOC_PositedAt datetime not null,
    ST_LOC_Reliability decimal(5,2) not null,
    constraint fkST_LOC_Stage_Location_Annex foreign key (
        ST_LOC_ID
    ) references public.ST_LOC_Stage_Location_Posit(ST_LOC_ID) RELY,
    constraint pkST_LOC_Stage_Location_Annex primary key (
        ST_LOC_ID,
        ST_LOC_PositedAt
    ) RELY
) CLUSTER BY (ST_LOC_ID, ST_LOC_PositedAt);
CREATE TABLE IF NOT EXISTS public.ST_AVG_Stage_Average_Posit (
    ST_AVG_ID int IDENTITY(1,1) not null, 
    ST_ID int not null,
    UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime not null,
    constraint fk_A_ST_AVG_Stage_Average_Posit foreign key (
        ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint fk_K_ST_AVG_Stage_Average_Posit foreign key (
        UTL_ID
    ) references public.UTL_Utilization(UTL_ID) RELY,
    constraint pkST_AVG_Stage_Average_Posit primary key (
        ST_AVG_ID
    ) RELY,
    constraint uqST_AVG_Stage_Average_Posit unique (
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    ) RELY
) CLUSTER BY (ST_ID);
CREATE TABLE IF NOT EXISTS public.ST_AVG_Stage_Average_Annex (
    ST_AVG_ID int not null,
    ST_AVG_PositedAt datetime not null,
    ST_AVG_Reliability decimal(5,2) not null,
    constraint fkST_AVG_Stage_Average_Annex foreign key (
        ST_AVG_ID
    ) references public.ST_AVG_Stage_Average_Posit(ST_AVG_ID) RELY,
    constraint pkST_AVG_Stage_Average_Annex primary key (
        ST_AVG_ID,
        ST_AVG_PositedAt
    ) RELY
) CLUSTER BY (ST_AVG_ID, ST_AVG_PositedAt);
CREATE TABLE IF NOT EXISTS public.ST_MIN_Stage_Minimum_Posit (
    ST_MIN_ID int IDENTITY(1,1) not null, 
    ST_ID int not null,
    UTL_ID tinyint not null,
    constraint fk_A_ST_MIN_Stage_Minimum_Posit foreign key (
        ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint fk_K_ST_MIN_Stage_Minimum_Posit foreign key (
        UTL_ID
    ) references public.UTL_Utilization(UTL_ID) RELY,
    constraint pkST_MIN_Stage_Minimum_Posit primary key (
        ST_MIN_ID
    ) RELY,
    constraint uqST_MIN_Stage_Minimum_Posit unique (
        ST_ID,
        UTL_ID
    ) RELY
) CLUSTER BY (ST_ID);
CREATE TABLE IF NOT EXISTS public.ST_MIN_Stage_Minimum_Annex (
    ST_MIN_ID int not null,
    ST_MIN_PositedAt datetime not null,
    ST_MIN_Reliability decimal(5,2) not null,
    constraint fkST_MIN_Stage_Minimum_Annex foreign key (
        ST_MIN_ID
    ) references public.ST_MIN_Stage_Minimum_Posit(ST_MIN_ID) RELY,
    constraint pkST_MIN_Stage_Minimum_Annex primary key (
        ST_MIN_ID,
        ST_MIN_PositedAt
    ) RELY
) CLUSTER BY (ST_MIN_ID, ST_MIN_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_NAM_Actor_Name_Posit (
    AC_NAM_ID int IDENTITY(1,1) not null, 
    AC_ID int not null,
    AC_NAM_Actor_Name varchar(42) not null,
    AC_NAM_ChangedAt datetime not null,
    constraint fkAC_NAM_Actor_Name_Posit foreign key (
        AC_ID
    ) references public.AC_Actor(AC_ID) RELY,
    constraint pkAC_NAM_Actor_Name_Posit primary key (
        AC_NAM_ID
    ) RELY,
    constraint uqAC_NAM_Actor_Name_Posit unique (
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    ) RELY
) CLUSTER BY (AC_ID);
CREATE TABLE IF NOT EXISTS public.AC_NAM_Actor_Name_Annex (
    AC_NAM_ID int not null,
    AC_NAM_PositedAt datetime not null,
    AC_NAM_Reliability decimal(5,2) not null,
    constraint fkAC_NAM_Actor_Name_Annex foreign key (
        AC_NAM_ID
    ) references public.AC_NAM_Actor_Name_Posit(AC_NAM_ID) RELY,
    constraint pkAC_NAM_Actor_Name_Annex primary key (
        AC_NAM_ID,
        AC_NAM_PositedAt
    ) RELY
) CLUSTER BY (AC_NAM_ID, AC_NAM_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_GEN_Actor_Gender_Posit (
    AC_GEN_ID int IDENTITY(1,1) not null, 
    AC_ID int not null,
    GEN_ID number(1,0) not null,
    constraint fk_A_AC_GEN_Actor_Gender_Posit foreign key (
        AC_ID
    ) references public.AC_Actor(AC_ID) RELY,
    constraint fk_K_AC_GEN_Actor_Gender_Posit foreign key (
        GEN_ID
    ) references public.GEN_Gender(GEN_ID) RELY,
    constraint pkAC_GEN_Actor_Gender_Posit primary key (
        AC_GEN_ID
    ) RELY,
    constraint uqAC_GEN_Actor_Gender_Posit unique (
        AC_ID,
        GEN_ID
    ) RELY
) CLUSTER BY (AC_ID);
CREATE TABLE IF NOT EXISTS public.AC_GEN_Actor_Gender_Annex (
    AC_GEN_ID int not null,
    AC_GEN_PositedAt datetime not null,
    AC_GEN_Reliability decimal(5,2) not null,
    constraint fkAC_GEN_Actor_Gender_Annex foreign key (
        AC_GEN_ID
    ) references public.AC_GEN_Actor_Gender_Posit(AC_GEN_ID) RELY,
    constraint pkAC_GEN_Actor_Gender_Annex primary key (
        AC_GEN_ID,
        AC_GEN_PositedAt
    ) RELY
) CLUSTER BY (AC_GEN_ID, AC_GEN_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel_Posit (
    AC_PLV_ID int IDENTITY(1,1) not null, 
    AC_ID int not null,
    PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        AC_ID
    ) references public.AC_Actor(AC_ID) RELY,
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
        PLV_ID
    ) references public.PLV_ProfessionalLevel(PLV_ID) RELY,
    constraint pkAC_PLV_Actor_ProfessionalLevel_Posit primary key (
        AC_PLV_ID
    ) RELY,
    constraint uqAC_PLV_Actor_ProfessionalLevel_Posit unique (
        AC_ID,
        AC_PLV_ChangedAt,
        PLV_ID
    ) RELY
) CLUSTER BY (AC_ID);
CREATE TABLE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel_Annex (
    AC_PLV_ID int not null,
    AC_PLV_PositedAt datetime not null,
    AC_PLV_Reliability decimal(5,2) not null,
    constraint fkAC_PLV_Actor_ProfessionalLevel_Annex foreign key (
        AC_PLV_ID
    ) references public.AC_PLV_Actor_ProfessionalLevel_Posit(AC_PLV_ID) RELY,
    constraint pkAC_PLV_Actor_ProfessionalLevel_Annex primary key (
        AC_PLV_ID,
        AC_PLV_PositedAt
    ) RELY
) CLUSTER BY (AC_PLV_ID, AC_PLV_PositedAt);
CREATE TABLE IF NOT EXISTS public.PR_NAM_Program_Name_Posit (
    PR_NAM_ID int IDENTITY(1,1) not null, 
    PR_ID int not null,
    PR_NAM_Program_Name varchar(42) not null,
    constraint fkPR_NAM_Program_Name_Posit foreign key (
        PR_ID
    ) references public.PR_Program(PR_ID) RELY,
    constraint pkPR_NAM_Program_Name_Posit primary key (
        PR_NAM_ID
    ) RELY,
    constraint uqPR_NAM_Program_Name_Posit unique (
        PR_ID,
        PR_NAM_Program_Name
    ) RELY
) CLUSTER BY (PR_ID);
CREATE TABLE IF NOT EXISTS public.PR_NAM_Program_Name_Annex (
    PR_NAM_ID int not null,
    PR_NAM_PositedAt datetime not null,
    PR_NAM_Reliability decimal(5,2) not null,
    constraint fkPR_NAM_Program_Name_Annex foreign key (
        PR_NAM_ID
    ) references public.PR_NAM_Program_Name_Posit(PR_NAM_ID) RELY,
    constraint pkPR_NAM_Program_Name_Annex primary key (
        PR_NAM_ID,
        PR_NAM_PositedAt
    ) RELY
) CLUSTER BY (PR_NAM_ID, PR_NAM_PositedAt);
CREATE TABLE IF NOT EXISTS public.PR_LEN_Program_Length_Posit (
    PR_LEN_ID int IDENTITY(1,1) not null, 
    PR_ID int not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length_Posit foreign key (
        PR_ID
    ) references public.PR_Program(PR_ID) RELY,
    constraint pkPR_LEN_Program_Length_Posit primary key (
        PR_LEN_ID
    ) RELY,
    constraint uqPR_LEN_Program_Length_Posit unique (
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    ) RELY
) CLUSTER BY (PR_ID);
CREATE TABLE IF NOT EXISTS public.PR_LEN_Program_Length_Annex (
    PR_LEN_ID int not null,
    PR_LEN_PositedAt datetime not null,
    PR_LEN_Reliability decimal(5,2) not null,
    constraint fkPR_LEN_Program_Length_Annex foreign key (
        PR_LEN_ID
    ) references public.PR_LEN_Program_Length_Posit(PR_LEN_ID) RELY,
    constraint pkPR_LEN_Program_Length_Annex primary key (
        PR_LEN_ID,
        PR_LEN_PositedAt
    ) RELY
) CLUSTER BY (PR_LEN_ID, PR_LEN_PositedAt);
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public.EV_DAT_Event_Date COPY GRANTS AS
SELECT
    p.EV_DAT_ID,
    p.EV_ID,
    p.EV_DAT_Event_Date,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Reliability
FROM
    public.EV_DAT_Event_Date_Posit p
JOIN
    public.EV_DAT_Event_Date_Annex a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
;
CREATE OR REPLACE VIEW public.EV_AUD_Event_Audience COPY GRANTS AS
SELECT
    p.EV_AUD_ID,
    p.EV_ID,
    p.EV_AUD_Event_Audience,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Reliability
FROM
    public.EV_AUD_Event_Audience_Posit p
JOIN
    public.EV_AUD_Event_Audience_Annex a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
;
CREATE OR REPLACE VIEW public.EV_REV_Event_Revenue COPY GRANTS AS
SELECT
    p.EV_REV_ID,
    p.EV_ID,
    p.EV_REV_Event_Revenue,
    a.EV_REV_PositedAt,
    a.EV_REV_Reliability
FROM
    public.EV_REV_Event_Revenue_Posit p
JOIN
    public.EV_REV_Event_Revenue_Annex a
ON
    a.EV_REV_ID = p.EV_REV_ID
;
CREATE OR REPLACE VIEW public.ST_NAM_Stage_Name COPY GRANTS AS
SELECT
    p.ST_NAM_ID,
    p.ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Reliability
FROM
    public.ST_NAM_Stage_Name_Posit p
JOIN
    public.ST_NAM_Stage_Name_Annex a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
;
CREATE OR REPLACE VIEW public.ST_LOC_Stage_Location COPY GRANTS AS
SELECT
    p.ST_LOC_ID,
    p.ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Reliability
FROM
    public.ST_LOC_Stage_Location_Posit p
JOIN
    public.ST_LOC_Stage_Location_Annex a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
;
CREATE OR REPLACE VIEW public.ST_AVG_Stage_Average COPY GRANTS AS
SELECT
    p.ST_AVG_ID,
    p.ST_ID,
    p.UTL_ID,
    p.ST_AVG_ChangedAt,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Reliability
FROM
    public.ST_AVG_Stage_Average_Posit p
JOIN
    public.ST_AVG_Stage_Average_Annex a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
;
CREATE OR REPLACE VIEW public.ST_MIN_Stage_Minimum COPY GRANTS AS
SELECT
    p.ST_MIN_ID,
    p.ST_ID,
    p.UTL_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Reliability
FROM
    public.ST_MIN_Stage_Minimum_Posit p
JOIN
    public.ST_MIN_Stage_Minimum_Annex a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
;
CREATE OR REPLACE VIEW public.AC_NAM_Actor_Name COPY GRANTS AS
SELECT
    p.AC_NAM_ID,
    p.AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Reliability
FROM
    public.AC_NAM_Actor_Name_Posit p
JOIN
    public.AC_NAM_Actor_Name_Annex a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
;
CREATE OR REPLACE VIEW public.AC_GEN_Actor_Gender COPY GRANTS AS
SELECT
    p.AC_GEN_ID,
    p.AC_ID,
    p.GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Reliability
FROM
    public.AC_GEN_Actor_Gender_Posit p
JOIN
    public.AC_GEN_Actor_Gender_Annex a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
;
CREATE OR REPLACE VIEW public.AC_PLV_Actor_ProfessionalLevel COPY GRANTS AS
SELECT
    p.AC_PLV_ID,
    p.AC_ID,
    p.PLV_ID,
    p.AC_PLV_ChangedAt,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Reliability
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit p
JOIN
    public.AC_PLV_Actor_ProfessionalLevel_Annex a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
;
CREATE OR REPLACE VIEW public.PR_NAM_Program_Name COPY GRANTS AS
SELECT
    p.PR_NAM_ID,
    p.PR_ID,
    p.PR_NAM_Program_Name,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Reliability
FROM
    public.PR_NAM_Program_Name_Posit p
JOIN
    public.PR_NAM_Program_Name_Annex a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
;
CREATE OR REPLACE VIEW public.PR_LEN_Program_Length COPY GRANTS AS
SELECT
    p.PR_LEN_ID,
    p.PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Reliability
FROM
    public.PR_LEN_Program_Length_Posit p
JOIN
    public.PR_LEN_Program_Length_Annex a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION public.rEV_DAT_Event_Date_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Reliability decimal(5,2)
)
AS
$$
SELECT
    EV_DAT_ID,
    EV_DAT_PositedAt,
    EV_DAT_Reliability
FROM
    public.EV_DAT_Event_Date_Annex
WHERE
    EV_DAT_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rEV_DAT_Event_Date (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Reliability decimal(5,2),
    EV_ID int,
    EV_DAT_Event_Date datetime
)
AS
$$
SELECT
    p.EV_DAT_ID,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Reliability,
    p.EV_ID,
    p.EV_DAT_Event_Date
FROM
    public.EV_DAT_Event_Date_Posit p
JOIN
    TABLE(public.rEV_DAT_Event_Date_Annex(positingTimepoint)) a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_DAT_ID
        ORDER BY a.EV_DAT_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rEV_AUD_Event_Audience_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Reliability decimal(5,2)
)
AS
$$
SELECT
    EV_AUD_ID,
    EV_AUD_PositedAt,
    EV_AUD_Reliability
FROM
    public.EV_AUD_Event_Audience_Annex
WHERE
    EV_AUD_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rEV_AUD_Event_Audience (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Reliability decimal(5,2),
    EV_ID int,
    EV_AUD_Event_Audience int
)
AS
$$
SELECT
    p.EV_AUD_ID,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Reliability,
    p.EV_ID,
    p.EV_AUD_Event_Audience
FROM
    public.EV_AUD_Event_Audience_Posit p
JOIN
    TABLE(public.rEV_AUD_Event_Audience_Annex(positingTimepoint)) a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_AUD_ID
        ORDER BY a.EV_AUD_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rEV_REV_Event_Revenue_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Reliability decimal(5,2)
)
AS
$$
SELECT
    EV_REV_ID,
    EV_REV_PositedAt,
    EV_REV_Reliability
FROM
    public.EV_REV_Event_Revenue_Annex
WHERE
    EV_REV_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rEV_REV_Event_Revenue (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Reliability decimal(5,2),
    EV_ID int,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    p.EV_REV_ID,
    a.EV_REV_PositedAt,
    a.EV_REV_Reliability,
    p.EV_ID,
    p.EV_REV_Event_Revenue
FROM
    public.EV_REV_Event_Revenue_Posit p
JOIN
    TABLE(public.rEV_REV_Event_Revenue_Annex(positingTimepoint)) a
ON
    a.EV_REV_ID = p.EV_REV_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_REV_ID
        ORDER BY a.EV_REV_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_NAM_ID int,
    ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    ST_NAM_ID,
    ST_ID,
    ST_NAM_Stage_Name,
    ST_NAM_ChangedAt
FROM
    public.ST_NAM_Stage_Name_Posit
WHERE
    ST_NAM_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.fST_NAM_Stage_Name_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_NAM_ID int,
    ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    ST_NAM_ID,
    ST_ID,
    ST_NAM_Stage_Name,
    ST_NAM_ChangedAt
FROM
    public.ST_NAM_Stage_Name_Posit
WHERE
    ST_NAM_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Reliability decimal(5,2)
)
AS
$$
SELECT
    ST_NAM_ID,
    ST_NAM_PositedAt,
    ST_NAM_Reliability
FROM
    public.ST_NAM_Stage_Name_Annex
WHERE
    ST_NAM_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Reliability decimal(5,2),
    ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Reliability,
    p.ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt
FROM
    TABLE(public.rST_NAM_Stage_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_NAM_Stage_Name_Annex(positingTimepoint)) a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_NAM_ID
        ORDER BY a.ST_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fST_NAM_Stage_Name (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Reliability decimal(5,2),
    ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Reliability,
    p.ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt
FROM
    TABLE(public.fST_NAM_Stage_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_NAM_Stage_Name_Annex(positingTimepoint)) a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_NAM_ID
        ORDER BY a.ST_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.preST_NAM_Stage_Name (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    pre.ST_NAM_Stage_Name
FROM
    TABLE(public.rST_NAM_Stage_Name(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.ST_ID = id
AND
    pre.ST_NAM_ChangedAt < changingTimepoint
AND
    pre.ST_NAM_Reliability = 1
ORDER BY
    pre.ST_NAM_ChangedAt DESC,
    pre.ST_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION public.folST_NAM_Stage_Name (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    fol.ST_NAM_Stage_Name
FROM
    TABLE(public.fST_NAM_Stage_Name(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.ST_ID = id
AND
    fol.ST_NAM_ChangedAt > changingTimepoint
AND
    fol.ST_NAM_Reliability = 1
ORDER BY
    fol.ST_NAM_ChangedAt ASC,
    fol.ST_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION public.rST_LOC_Stage_Location_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Reliability decimal(5,2)
)
AS
$$
SELECT
    ST_LOC_ID,
    ST_LOC_PositedAt,
    ST_LOC_Reliability
FROM
    public.ST_LOC_Stage_Location_Annex
WHERE
    ST_LOC_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rST_LOC_Stage_Location (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Reliability decimal(5,2),
    ST_ID int,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography
)
AS
$$
SELECT
    p.ST_LOC_ID,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Reliability,
    p.ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location
FROM
    public.ST_LOC_Stage_Location_Posit p
JOIN
    TABLE(public.rST_LOC_Stage_Location_Annex(positingTimepoint)) a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_LOC_ID
        ORDER BY a.ST_LOC_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_AVG_ID int,
    ST_ID int,
    UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    ST_AVG_ID,
    ST_ID,
    UTL_ID,
    ST_AVG_ChangedAt
FROM
    public.ST_AVG_Stage_Average_Posit
WHERE
    ST_AVG_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.fST_AVG_Stage_Average_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_AVG_ID int,
    ST_ID int,
    UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    ST_AVG_ID,
    ST_ID,
    UTL_ID,
    ST_AVG_ChangedAt
FROM
    public.ST_AVG_Stage_Average_Posit
WHERE
    ST_AVG_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Reliability decimal(5,2)
)
AS
$$
SELECT
    ST_AVG_ID,
    ST_AVG_PositedAt,
    ST_AVG_Reliability
FROM
    public.ST_AVG_Stage_Average_Annex
WHERE
    ST_AVG_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Reliability decimal(5,2),
    ST_ID int,
    UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Reliability,
    p.ST_ID,
    p.UTL_ID,
    p.ST_AVG_ChangedAt
FROM
    TABLE(public.rST_AVG_Stage_Average_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_AVG_Stage_Average_Annex(positingTimepoint)) a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_AVG_ID
        ORDER BY a.ST_AVG_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fST_AVG_Stage_Average (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Reliability decimal(5,2),
    ST_ID int,
    UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Reliability,
    p.ST_ID,
    p.UTL_ID,
    p.ST_AVG_ChangedAt
FROM
    TABLE(public.fST_AVG_Stage_Average_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_AVG_Stage_Average_Annex(positingTimepoint)) a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_AVG_ID
        ORDER BY a.ST_AVG_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.preST_AVG_Stage_Average (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    pre.UTL_ID
FROM
    TABLE(public.rST_AVG_Stage_Average(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.ST_ID = id
AND
    pre.ST_AVG_ChangedAt < changingTimepoint
AND
    pre.ST_AVG_Reliability = 1
ORDER BY
    pre.ST_AVG_ChangedAt DESC,
    pre.ST_AVG_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION public.folST_AVG_Stage_Average (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    fol.UTL_ID
FROM
    TABLE(public.fST_AVG_Stage_Average(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.ST_ID = id
AND
    fol.ST_AVG_ChangedAt > changingTimepoint
AND
    fol.ST_AVG_Reliability = 1
ORDER BY
    fol.ST_AVG_ChangedAt ASC,
    fol.ST_AVG_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION public.rST_MIN_Stage_Minimum_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Reliability decimal(5,2)
)
AS
$$
SELECT
    ST_MIN_ID,
    ST_MIN_PositedAt,
    ST_MIN_Reliability
FROM
    public.ST_MIN_Stage_Minimum_Annex
WHERE
    ST_MIN_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rST_MIN_Stage_Minimum (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Reliability decimal(5,2),
    ST_ID int,
    UTL_ID tinyint 
)
AS
$$
SELECT
    p.ST_MIN_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Reliability,
    p.ST_ID,
    p.UTL_ID
FROM
    public.ST_MIN_Stage_Minimum_Posit p
JOIN
    TABLE(public.rST_MIN_Stage_Minimum_Annex(positingTimepoint)) a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_MIN_ID
        ORDER BY a.ST_MIN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_NAM_ID int,
    AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    AC_NAM_ID,
    AC_ID,
    AC_NAM_Actor_Name,
    AC_NAM_ChangedAt
FROM
    public.AC_NAM_Actor_Name_Posit
WHERE
    AC_NAM_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.fAC_NAM_Actor_Name_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_NAM_ID int,
    AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    AC_NAM_ID,
    AC_ID,
    AC_NAM_Actor_Name,
    AC_NAM_ChangedAt
FROM
    public.AC_NAM_Actor_Name_Posit
WHERE
    AC_NAM_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Reliability decimal(5,2)
)
AS
$$
SELECT
    AC_NAM_ID,
    AC_NAM_PositedAt,
    AC_NAM_Reliability
FROM
    public.AC_NAM_Actor_Name_Annex
WHERE
    AC_NAM_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Reliability decimal(5,2),
    AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Reliability,
    p.AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt
FROM
    TABLE(public.rAC_NAM_Actor_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_NAM_Actor_Name_Annex(positingTimepoint)) a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_NAM_ID
        ORDER BY a.AC_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fAC_NAM_Actor_Name (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Reliability decimal(5,2),
    AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Reliability,
    p.AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt
FROM
    TABLE(public.fAC_NAM_Actor_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_NAM_Actor_Name_Annex(positingTimepoint)) a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_NAM_ID
        ORDER BY a.AC_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.preAC_NAM_Actor_Name (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    pre.AC_NAM_Actor_Name
FROM
    TABLE(public.rAC_NAM_Actor_Name(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.AC_ID = id
AND
    pre.AC_NAM_ChangedAt < changingTimepoint
AND
    pre.AC_NAM_Reliability = 1
ORDER BY
    pre.AC_NAM_ChangedAt DESC,
    pre.AC_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION public.folAC_NAM_Actor_Name (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS varchar(42)
AS
$$
SELECT
    fol.AC_NAM_Actor_Name
FROM
    TABLE(public.fAC_NAM_Actor_Name(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.AC_ID = id
AND
    fol.AC_NAM_ChangedAt > changingTimepoint
AND
    fol.AC_NAM_Reliability = 1
ORDER BY
    fol.AC_NAM_ChangedAt ASC,
    fol.AC_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION public.rAC_GEN_Actor_Gender_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Reliability decimal(5,2)
)
AS
$$
SELECT
    AC_GEN_ID,
    AC_GEN_PositedAt,
    AC_GEN_Reliability
FROM
    public.AC_GEN_Actor_Gender_Annex
WHERE
    AC_GEN_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_GEN_Actor_Gender (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Reliability decimal(5,2),
    AC_ID int,
    GEN_ID number(1,0) 
)
AS
$$
SELECT
    p.AC_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Reliability,
    p.AC_ID,
    p.GEN_ID
FROM
    public.AC_GEN_Actor_Gender_Posit p
JOIN
    TABLE(public.rAC_GEN_Actor_Gender_Annex(positingTimepoint)) a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_GEN_ID
        ORDER BY a.AC_GEN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_PLV_ID int,
    AC_ID int,
    PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    AC_PLV_ID,
    AC_ID,
    PLV_ID,
    AC_PLV_ChangedAt
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit
WHERE
    AC_PLV_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.fAC_PLV_Actor_ProfessionalLevel_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_PLV_ID int,
    AC_ID int,
    PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    AC_PLV_ID,
    AC_ID,
    PLV_ID,
    AC_PLV_ChangedAt
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit
WHERE
    AC_PLV_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Reliability decimal(5,2)
)
AS
$$
SELECT
    AC_PLV_ID,
    AC_PLV_PositedAt,
    AC_PLV_Reliability
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Annex
WHERE
    AC_PLV_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Reliability decimal(5,2),
    AC_ID int,
    PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Reliability,
    p.AC_ID,
    p.PLV_ID,
    p.AC_PLV_ChangedAt
FROM
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel_Annex(positingTimepoint)) a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_PLV_ID
        ORDER BY a.AC_PLV_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Reliability decimal(5,2),
    AC_ID int,
    PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Reliability,
    p.AC_ID,
    p.PLV_ID,
    p.AC_PLV_ChangedAt
FROM
    TABLE(public.fAC_PLV_Actor_ProfessionalLevel_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel_Annex(positingTimepoint)) a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_PLV_ID
        ORDER BY a.AC_PLV_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.preAC_PLV_Actor_ProfessionalLevel (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    pre.PLV_ID
FROM
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.AC_ID = id
AND
    pre.AC_PLV_ChangedAt < changingTimepoint
AND
    pre.AC_PLV_Reliability = 1
ORDER BY
    pre.AC_PLV_ChangedAt DESC,
    pre.AC_PLV_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION public.folAC_PLV_Actor_ProfessionalLevel (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS tinyint
AS
$$
SELECT
    fol.PLV_ID
FROM
    TABLE(public.fAC_PLV_Actor_ProfessionalLevel(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.AC_ID = id
AND
    fol.AC_PLV_ChangedAt > changingTimepoint
AND
    fol.AC_PLV_Reliability = 1
ORDER BY
    fol.AC_PLV_ChangedAt ASC,
    fol.AC_PLV_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION public.rPR_NAM_Program_Name_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Reliability decimal(5,2)
)
AS
$$
SELECT
    PR_NAM_ID,
    PR_NAM_PositedAt,
    PR_NAM_Reliability
FROM
    public.PR_NAM_Program_Name_Annex
WHERE
    PR_NAM_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rPR_NAM_Program_Name (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Reliability decimal(5,2),
    PR_ID int,
    PR_NAM_Program_Name varchar(42)
)
AS
$$
SELECT
    p.PR_NAM_ID,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Reliability,
    p.PR_ID,
    p.PR_NAM_Program_Name
FROM
    public.PR_NAM_Program_Name_Posit p
JOIN
    TABLE(public.rPR_NAM_Program_Name_Annex(positingTimepoint)) a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_NAM_ID
        ORDER BY a.PR_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length_Posit (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    PR_LEN_ID int,
    PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    PR_LEN_ID,
    PR_ID,
    PR_LEN_Program_Length,
    PR_LEN_ChangedAt
FROM
    public.PR_LEN_Program_Length_Posit
WHERE
    PR_LEN_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.fPR_LEN_Program_Length_Posit (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    PR_LEN_ID int,
    PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    PR_LEN_ID,
    PR_ID,
    PR_LEN_Program_Length,
    PR_LEN_ChangedAt
FROM
    public.PR_LEN_Program_Length_Posit
WHERE
    PR_LEN_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Reliability decimal(5,2)
)
AS
$$
SELECT
    PR_LEN_ID,
    PR_LEN_PositedAt,
    PR_LEN_Reliability
FROM
    public.PR_LEN_Program_Length_Annex
WHERE
    PR_LEN_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length (
    changingTimepoint date,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Reliability decimal(5,2),
    PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Reliability,
    p.PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt
FROM
    TABLE(public.rPR_LEN_Program_Length_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rPR_LEN_Program_Length_Annex(positingTimepoint)) a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_LEN_ID
        ORDER BY a.PR_LEN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fPR_LEN_Program_Length (
    changingTimepoint date,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Reliability decimal(5,2),
    PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Reliability,
    p.PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt
FROM
    TABLE(public.fPR_LEN_Program_Length_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rPR_LEN_Program_Length_Annex(positingTimepoint)) a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_LEN_ID
        ORDER BY a.PR_LEN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.prePR_LEN_Program_Length (
    id int,
    changingTimepoint date,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS time
AS
$$
SELECT
    pre.PR_LEN_Program_Length
FROM
    TABLE(public.rPR_LEN_Program_Length(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.PR_ID = id
AND
    pre.PR_LEN_ChangedAt < changingTimepoint
AND
    pre.PR_LEN_Reliability = 1
ORDER BY
    pre.PR_LEN_ChangedAt DESC,
    pre.PR_LEN_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION public.folPR_LEN_Program_Length (
    id int,
    changingTimepoint date,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS time
AS
$$
SELECT
    fol.PR_LEN_Program_Length
FROM
    TABLE(public.fPR_LEN_Program_Length(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.PR_ID = id
AND
    fol.PR_LEN_ChangedAt > changingTimepoint
AND
    fol.PR_LEN_Reliability = 1
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
CREATE OR REPLACE FUNCTION public.tST_Stage (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_ID int,
    ST_NAM_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt datetime,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Reliability decimal(5,2),
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt datetime,
    ST_AVG_Reliability decimal(5,2),
    UTL_Utilization tinyint,
    UTL_ID tinyint,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Reliability decimal(5,2),
    UTL_Utilization tinyint,
    UTL_ID tinyint
)
AS
$$
SELECT
    ST.ST_ID,
    NAM.ST_NAM_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_PositedAt,
    NAM.ST_NAM_Reliability,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ID,
    LOC.ST_LOC_PositedAt,
    LOC.ST_LOC_Reliability,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ID,
    AVG.ST_AVG_ChangedAt,
    AVG.ST_AVG_PositedAt,
    AVG.ST_AVG_Reliability,
    kAVG.UTL_Utilization AS UTL_Utilization,
    AVG.UTL_ID,
    MIN.ST_MIN_ID,
    MIN.ST_MIN_PositedAt,
    MIN.ST_MIN_Reliability,
    kMIN.UTL_Utilization AS UTL_Utilization,
    MIN.UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    TABLE(public.rST_NAM_Stage_Name(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) NAM
ON
    NAM.ST_NAM_ID = (
        SELECT
            sub.ST_NAM_ID
        FROM
            TABLE(public.rST_NAM_Stage_Name(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.ST_ID = ST.ST_ID
        AND
            sub.ST_NAM_Reliability = 1
        ORDER BY
            sub.ST_NAM_ChangedAt DESC,
            sub.ST_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rST_LOC_Stage_Location(
        positingTimepoint::datetime
    )) LOC
ON
    LOC.ST_LOC_ID = (
        SELECT
            sub.ST_LOC_ID
        FROM
            TABLE(public.rST_LOC_Stage_Location(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.ST_ID = ST.ST_ID
        AND
            sub.ST_LOC_Reliability = 1
        ORDER BY
            sub.ST_LOC_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rST_AVG_Stage_Average(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) AVG
ON
    AVG.ST_AVG_ID = (
        SELECT
            sub.ST_AVG_ID
        FROM
            TABLE(public.rST_AVG_Stage_Average(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.ST_ID = ST.ST_ID
        AND
            sub.ST_AVG_Reliability = 1
        ORDER BY
            sub.ST_AVG_ChangedAt DESC,
            sub.ST_AVG_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    public.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.UTL_ID
LEFT JOIN
    TABLE(public.rST_MIN_Stage_Minimum(
        positingTimepoint::datetime
    )) MIN
ON
    MIN.ST_MIN_ID = (
        SELECT
            sub.ST_MIN_ID
        FROM
            TABLE(public.rST_MIN_Stage_Minimum(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.ST_ID = ST.ST_ID
        AND
            sub.ST_MIN_Reliability = 1
        ORDER BY
            sub.ST_MIN_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    public.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.UTL_ID
$$
;
CREATE OR REPLACE VIEW public.lST_Stage COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    ST.*
FROM
    TABLE(public.tST_Stage(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) ST
;
CREATE OR REPLACE FUNCTION public.pST_Stage (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Reliability decimal(5,2),
    ST_ID int,
    ST_NAM_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt datetime,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Reliability decimal(5,2),
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt datetime,
    ST_AVG_Reliability decimal(5,2),
    UTL_Utilization tinyint,
    UTL_ID tinyint,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Reliability decimal(5,2),
    UTL_Utilization tinyint,
    UTL_ID tinyint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as Reliability,
    ST.ST_ID,
    ST.ST_NAM_ID,
    ST.ST_NAM_ChangedAt,
    ST.ST_NAM_PositedAt,
    ST.ST_NAM_Reliability,
    ST.ST_NAM_Stage_Name,
    ST.ST_LOC_ID,
    ST.ST_LOC_PositedAt,
    ST.ST_LOC_Reliability,
    ST.ST_LOC_Checksum,
    ST.ST_LOC_Stage_Location,
    ST.ST_AVG_ID,
    ST.ST_AVG_ChangedAt,
    ST.ST_AVG_PositedAt,
    ST.ST_AVG_Reliability,
    ST.UTL_Utilization,
    ST.UTL_ID,
    ST.ST_MIN_ID,
    ST.ST_MIN_PositedAt,
    ST.ST_MIN_Reliability,
    ST.UTL_Utilization,
    ST.UTL_ID
FROM
    TABLE(public.tST_Stage(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) ST
$$
;
CREATE OR REPLACE VIEW public.nST_Stage COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    ST.*
FROM
    TABLE(public.tST_Stage(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) ST
;
CREATE OR REPLACE FUNCTION public.dST_Stage (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    ST_ID int,
    ST_NAM_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt datetime,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Reliability decimal(5,2),
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt datetime,
    ST_AVG_Reliability decimal(5,2),
    UTL_Utilization tinyint,
    UTL_ID tinyint,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Reliability decimal(5,2),
    UTL_Utilization tinyint,
    UTL_ID tinyint
)
AS
$$
SELECT
    tp.inspectedTimepoint,
    ST.ST_ID,
    ST.ST_NAM_ID,
    ST.ST_NAM_ChangedAt,
    ST.ST_NAM_PositedAt,
    ST.ST_NAM_Reliability,
    ST.ST_NAM_Stage_Name,
    ST.ST_LOC_ID,
    ST.ST_LOC_PositedAt,
    ST.ST_LOC_Reliability,
    ST.ST_LOC_Checksum,
    ST.ST_LOC_Stage_Location,
    ST.ST_AVG_ID,
    ST.ST_AVG_ChangedAt,
    ST.ST_AVG_PositedAt,
    ST.ST_AVG_Reliability,
    ST.UTL_Utilization,
    ST.UTL_ID,
    ST.ST_MIN_ID,
    ST.ST_MIN_PositedAt,
    ST.ST_MIN_Reliability,
    ST.UTL_Utilization,
    ST.UTL_ID
FROM (
    SELECT DISTINCT
        ST_ID AS ST_ID,
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
        ST_ID AS ST_ID,
        ST_AVG_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        public.ST_AVG_Stage_Average
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp,
    TABLE(public.tST_Stage(
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) ST
WHERE
    ST.ST_ID = tp.ST_ID
$$
;
CREATE OR REPLACE FUNCTION public.tAC_Actor (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_ID int,
    AC_NAM_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt datetime,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Reliability decimal(5,2),
    GEN_Gender varchar(42),
    GEN_ID number(1,0),
    AC_PLV_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt datetime,
    AC_PLV_Reliability decimal(5,2),
    PLV_Checksum numeric(19,0),
    PLV_ProfessionalLevel string,
    PLV_ID tinyint
)
AS
$$
SELECT
    AC.AC_ID,
    NAM.AC_NAM_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_PositedAt,
    NAM.AC_NAM_Reliability,
    NAM.AC_NAM_Actor_Name,
    GEN.AC_GEN_ID,
    GEN.AC_GEN_PositedAt,
    GEN.AC_GEN_Reliability,
    kGEN.GEN_Gender AS GEN_Gender,
    GEN.GEN_ID,
    PLV.AC_PLV_ID,
    PLV.AC_PLV_ChangedAt,
    PLV.AC_PLV_PositedAt,
    PLV.AC_PLV_Reliability,
    kPLV.PLV_Checksum AS PLV_Checksum,
    kPLV.PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    PLV.PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    TABLE(public.rAC_NAM_Actor_Name(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) NAM
ON
    NAM.AC_NAM_ID = (
        SELECT
            sub.AC_NAM_ID
        FROM
            TABLE(public.rAC_NAM_Actor_Name(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.AC_ID = AC.AC_ID
        AND
            sub.AC_NAM_Reliability = 1
        ORDER BY
            sub.AC_NAM_ChangedAt DESC,
            sub.AC_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rAC_GEN_Actor_Gender(
        positingTimepoint::datetime
    )) GEN
ON
    GEN.AC_GEN_ID = (
        SELECT
            sub.AC_GEN_ID
        FROM
            TABLE(public.rAC_GEN_Actor_Gender(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.AC_ID = AC.AC_ID
        AND
            sub.AC_GEN_Reliability = 1
        ORDER BY
            sub.AC_GEN_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    public.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.GEN_ID
LEFT JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) PLV
ON
    PLV.AC_PLV_ID = (
        SELECT
            sub.AC_PLV_ID
        FROM
            TABLE(public.rAC_PLV_Actor_ProfessionalLevel(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.AC_ID = AC.AC_ID
        AND
            sub.AC_PLV_Reliability = 1
        ORDER BY
            sub.AC_PLV_ChangedAt DESC,
            sub.AC_PLV_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.PLV_ID
$$
;
CREATE OR REPLACE VIEW public.lAC_Actor COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    AC.*
FROM
    TABLE(public.tAC_Actor(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) AC
;
CREATE OR REPLACE FUNCTION public.pAC_Actor (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Reliability decimal(5,2),
    AC_ID int,
    AC_NAM_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt datetime,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Reliability decimal(5,2),
    GEN_Gender varchar(42),
    GEN_ID number(1,0),
    AC_PLV_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt datetime,
    AC_PLV_Reliability decimal(5,2),
    PLV_Checksum numeric(19,0),
    PLV_ProfessionalLevel string,
    PLV_ID tinyint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as Reliability,
    AC.AC_ID,
    AC.AC_NAM_ID,
    AC.AC_NAM_ChangedAt,
    AC.AC_NAM_PositedAt,
    AC.AC_NAM_Reliability,
    AC.AC_NAM_Actor_Name,
    AC.AC_GEN_ID,
    AC.AC_GEN_PositedAt,
    AC.AC_GEN_Reliability,
    AC.GEN_Gender,
    AC.GEN_ID,
    AC.AC_PLV_ID,
    AC.AC_PLV_ChangedAt,
    AC.AC_PLV_PositedAt,
    AC.AC_PLV_Reliability,
    AC.PLV_Checksum,
    AC.PLV_ProfessionalLevel,
    AC.PLV_ID
FROM
    TABLE(public.tAC_Actor(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) AC
$$
;
CREATE OR REPLACE VIEW public.nAC_Actor COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    AC.*
FROM
    TABLE(public.tAC_Actor(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) AC
;
CREATE OR REPLACE FUNCTION public.dAC_Actor (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    AC_ID int,
    AC_NAM_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt datetime,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Reliability decimal(5,2),
    GEN_Gender varchar(42),
    GEN_ID number(1,0),
    AC_PLV_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt datetime,
    AC_PLV_Reliability decimal(5,2),
    PLV_Checksum numeric(19,0),
    PLV_ProfessionalLevel string,
    PLV_ID tinyint
)
AS
$$
SELECT
    tp.inspectedTimepoint,
    AC.AC_ID,
    AC.AC_NAM_ID,
    AC.AC_NAM_ChangedAt,
    AC.AC_NAM_PositedAt,
    AC.AC_NAM_Reliability,
    AC.AC_NAM_Actor_Name,
    AC.AC_GEN_ID,
    AC.AC_GEN_PositedAt,
    AC.AC_GEN_Reliability,
    AC.GEN_Gender,
    AC.GEN_ID,
    AC.AC_PLV_ID,
    AC.AC_PLV_ChangedAt,
    AC.AC_PLV_PositedAt,
    AC.AC_PLV_Reliability,
    AC.PLV_Checksum,
    AC.PLV_ProfessionalLevel,
    AC.PLV_ID
FROM (
    SELECT DISTINCT
        AC_ID AS AC_ID,
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
        AC_ID AS AC_ID,
        AC_PLV_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        public.AC_PLV_Actor_ProfessionalLevel
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp,
    TABLE(public.tAC_Actor(
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) AC
WHERE
    AC.AC_ID = tp.AC_ID
$$
;
CREATE OR REPLACE FUNCTION public.tPR_Program (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_ID int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_Program_Name varchar(42),
    PR_LEN_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt datetime,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    PR.PR_ID,
    NAM.PR_NAM_ID,
    NAM.PR_NAM_PositedAt,
    NAM.PR_NAM_Reliability,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_ID,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_PositedAt,
    LEN.PR_LEN_Reliability,
    LEN.PR_LEN_Program_Length
FROM
    public.PR_Program PR
LEFT JOIN
    TABLE(public.rPR_NAM_Program_Name(
        positingTimepoint::datetime
    )) NAM
ON
    NAM.PR_NAM_ID = (
        SELECT
            sub.PR_NAM_ID
        FROM
            TABLE(public.rPR_NAM_Program_Name(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.PR_ID = PR.PR_ID
        AND
            sub.PR_NAM_Reliability = 1
        ORDER BY
            sub.PR_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rPR_LEN_Program_Length(
        changingTimepoint::date,
        positingTimepoint::datetime
    )) LEN
ON
    LEN.PR_LEN_ID = (
        SELECT
            sub.PR_LEN_ID
        FROM
            TABLE(public.rPR_LEN_Program_Length(
                changingTimepoint::date,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.PR_ID = PR.PR_ID
        AND
            sub.PR_LEN_Reliability = 1
        ORDER BY
            sub.PR_LEN_ChangedAt DESC,
            sub.PR_LEN_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public.lPR_Program COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    PR.*
FROM
    TABLE(public.tPR_Program(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) PR
;
CREATE OR REPLACE FUNCTION public.pPR_Program (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Reliability decimal(5,2),
    PR_ID int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_Program_Name varchar(42),
    PR_LEN_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt datetime,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as Reliability,
    PR.PR_ID,
    PR.PR_NAM_ID,
    PR.PR_NAM_PositedAt,
    PR.PR_NAM_Reliability,
    PR.PR_NAM_Program_Name,
    PR.PR_LEN_ID,
    PR.PR_LEN_ChangedAt,
    PR.PR_LEN_PositedAt,
    PR.PR_LEN_Reliability,
    PR.PR_LEN_Program_Length
FROM
    TABLE(public.tPR_Program(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) PR
$$
;
CREATE OR REPLACE VIEW public.nPR_Program COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    PR.*
FROM
    TABLE(public.tPR_Program(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) PR
;
CREATE OR REPLACE FUNCTION public.dPR_Program (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    PR_ID int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_Program_Name varchar(42),
    PR_LEN_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt datetime,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    tp.inspectedTimepoint,
    PR.PR_ID,
    PR.PR_NAM_ID,
    PR.PR_NAM_PositedAt,
    PR.PR_NAM_Reliability,
    PR.PR_NAM_Program_Name,
    PR.PR_LEN_ID,
    PR.PR_LEN_ChangedAt,
    PR.PR_LEN_PositedAt,
    PR.PR_LEN_Reliability,
    PR.PR_LEN_Program_Length
FROM (
    SELECT DISTINCT
        PR_ID AS PR_ID,
        PR_LEN_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        public.PR_LEN_Program_Length
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp,
    TABLE(public.tPR_Program(
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
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
CREATE OR REPLACE FUNCTION public.tEV_Event (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Event_Date datetime,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Event_Audience int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    kETY_of.ETY_EventType AS ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_ID,
    DAT.EV_DAT_PositedAt,
    DAT.EV_DAT_Reliability,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_ID,
    AUD.EV_AUD_PositedAt,
    AUD.EV_AUD_Reliability,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_ID,
    REV.EV_REV_PositedAt,
    REV.EV_REV_Reliability,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType kETY_of
ON
    kETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.rEV_DAT_Event_Date(
        positingTimepoint::datetime
    )) DAT
ON
    DAT.EV_DAT_ID = (
        SELECT
            sub.EV_DAT_ID
        FROM
            TABLE(public.rEV_DAT_Event_Date(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID = EV.EV_ID
        AND
            sub.EV_DAT_Reliability = 1
        ORDER BY
            sub.EV_DAT_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rEV_AUD_Event_Audience(
        positingTimepoint::datetime
    )) AUD
ON
    AUD.EV_AUD_ID = (
        SELECT
            sub.EV_AUD_ID
        FROM
            TABLE(public.rEV_AUD_Event_Audience(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID = EV.EV_ID
        AND
            sub.EV_AUD_Reliability = 1
        ORDER BY
            sub.EV_AUD_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rEV_REV_Event_Revenue(
        positingTimepoint::datetime
    )) REV
ON
    REV.EV_REV_ID = (
        SELECT
            sub.EV_REV_ID
        FROM
            TABLE(public.rEV_REV_Event_Revenue(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID = EV.EV_ID
        AND
            sub.EV_REV_Reliability = 1
        ORDER BY
            sub.EV_REV_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public.lEV_Event COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    EV.*
FROM
    TABLE(public.tEV_Event(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) EV
;
CREATE OR REPLACE FUNCTION public.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Reliability decimal(5,2),
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Event_Date datetime,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Event_Audience int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as Reliability,
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    EV.ETY_EventType,
    EV.ETY_ID_of,
    EV.EV_DAT_ID,
    EV.EV_DAT_PositedAt,
    EV.EV_DAT_Reliability,
    EV.EV_DAT_Event_Date,
    EV.EV_AUD_ID,
    EV.EV_AUD_PositedAt,
    EV.EV_AUD_Reliability,
    EV.EV_AUD_Event_Audience,
    EV.EV_REV_ID,
    EV.EV_REV_PositedAt,
    EV.EV_REV_Reliability,
    EV.EV_REV_Event_Revenue
FROM
    TABLE(public.tEV_Event(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) EV
$$
;
CREATE OR REPLACE VIEW public.nEV_Event COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    EV.*
FROM
    TABLE(public.tEV_Event(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) EV
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
CREATE TABLE IF NOT EXISTS public.AC_partner_AC_with_ONG_currently_Posit (
    AC_partner_AC_with_ONG_currently_ID int IDENTITY(1,1) not null, 
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
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2) not null,
    constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
        AC_partner_AC_with_ONG_currently_ID
    ) references public.AC_partner_AC_with_ONG_currently_Posit(AC_partner_AC_with_ONG_currently_ID) RELY,
    constraint pkAC_partner_AC_with_ONG_currently_Annex primary key (
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt
    ) RELY
) CLUSTER BY (AC_partner_AC_with_ONG_currently_ID, AC_partner_AC_with_ONG_currently_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_subset_PN_of_Posit (
    AC_subset_PN_of_ID int IDENTITY(1,1) not null, 
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
    AC_subset_PN_of_Reliability decimal(5,2) not null,
    constraint fkAC_subset_PN_of_Annex foreign key (
        AC_subset_PN_of_ID
    ) references public.AC_subset_PN_of_Posit(AC_subset_PN_of_ID) RELY,
    constraint pkAC_subset_PN_of_Annex primary key (
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt
    ) RELY
) CLUSTER BY (AC_subset_PN_of_ID, AC_subset_PN_of_PositedAt);
CREATE TABLE IF NOT EXISTS public.EV_in_AC_wasCast_Posit (
    EV_in_AC_wasCast_ID int IDENTITY(1,1) not null, 
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
    EV_in_AC_wasCast_Reliability decimal(5,2) not null,
    constraint fkEV_in_AC_wasCast_Annex foreign key (
        EV_in_AC_wasCast_ID
    ) references public.EV_in_AC_wasCast_Posit(EV_in_AC_wasCast_ID) RELY,
    constraint pkEV_in_AC_wasCast_Annex primary key (
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt
    ) RELY
) CLUSTER BY (EV_in_AC_wasCast_ID, EV_in_AC_wasCast_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_part_PR_in_RAT_got_Posit (
    AC_part_PR_in_RAT_got_ID int IDENTITY(1,1) not null, 
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
    AC_part_PR_in_RAT_got_Reliability decimal(5,2) not null,
    constraint fkAC_part_PR_in_RAT_got_Annex foreign key (
        AC_part_PR_in_RAT_got_ID
    ) references public.AC_part_PR_in_RAT_got_Posit(AC_part_PR_in_RAT_got_ID) RELY,
    constraint pkAC_part_PR_in_RAT_got_Annex primary key (
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt
    ) RELY
) CLUSTER BY (AC_part_PR_in_RAT_got_ID, AC_part_PR_in_RAT_got_PositedAt);
CREATE TABLE IF NOT EXISTS public.ST_at_PR_isPlaying_Posit (
    ST_at_PR_isPlaying_ID int IDENTITY(1,1) not null, 
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
    ST_at_PR_isPlaying_Reliability decimal(5,2) not null,
    constraint fkST_at_PR_isPlaying_Annex foreign key (
        ST_at_PR_isPlaying_ID
    ) references public.ST_at_PR_isPlaying_Posit(ST_at_PR_isPlaying_ID) RELY,
    constraint pkST_at_PR_isPlaying_Annex primary key (
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt
    ) RELY
) CLUSTER BY (ST_at_PR_isPlaying_ID, ST_at_PR_isPlaying_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_parent_AC_child_PAT_having_Posit (
    AC_parent_AC_child_PAT_having_ID int IDENTITY(1,1) not null, 
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
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2) not null,
    constraint fkAC_parent_AC_child_PAT_having_Annex foreign key (
        AC_parent_AC_child_PAT_having_ID
    ) references public.AC_parent_AC_child_PAT_having_Posit(AC_parent_AC_child_PAT_having_ID) RELY,
    constraint pkAC_parent_AC_child_PAT_having_Annex primary key (
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt
    ) RELY
) CLUSTER BY (AC_parent_AC_child_PAT_having_ID, AC_parent_AC_child_PAT_having_PositedAt);
CREATE TABLE IF NOT EXISTS public.PR_content_ST_location_EV_of_Posit (
    PR_content_ST_location_EV_of_ID int IDENTITY(1,1) not null, 
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
    PR_content_ST_location_EV_of_Reliability decimal(5,2) not null,
    constraint fkPR_content_ST_location_EV_of_Annex foreign key (
        PR_content_ST_location_EV_of_ID
    ) references public.PR_content_ST_location_EV_of_Posit(PR_content_ST_location_EV_of_ID) RELY,
    constraint pkPR_content_ST_location_EV_of_Annex primary key (
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt
    ) RELY
) CLUSTER BY (PR_content_ST_location_EV_of_ID, PR_content_ST_location_EV_of_PositedAt);
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
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
    AC_partner_AC_with_ONG_currently_ID int,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2)
)
AS
$$
SELECT
    AC_partner_AC_with_ONG_currently_ID,
    AC_partner_AC_with_ONG_currently_PositedAt,
    AC_partner_AC_with_ONG_currently_Reliability
FROM
    public.AC_partner_AC_with_ONG_currently_Annex
WHERE
    AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_partner_AC_with_ONG_currently (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID int,
    AC_ID_partner int, 
    AC_ID_with int, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Reliability
FROM
    TABLE(public.rAC_partner_AC_with_ONG_currently_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rAC_partner_AC_with_ONG_currently_Annex(positingTimepoint)) a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_partner_AC_with_ONG_currently_ID
        ORDER BY a.AC_partner_AC_with_ONG_currently_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fAC_partner_AC_with_ONG_currently (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID int,
    AC_ID_partner int, 
    AC_ID_with int, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Reliability
FROM
    TABLE(public.fAC_partner_AC_with_ONG_currently_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rAC_partner_AC_with_ONG_currently_Annex(positingTimepoint)) a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
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
    AC_subset_PN_of_ID int,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    AC_subset_PN_of_ID,
    AC_subset_PN_of_PositedAt,
    AC_subset_PN_of_Reliability
FROM
    public.AC_subset_PN_of_Annex
WHERE
    AC_subset_PN_of_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_subset_PN_of (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_subset_PN_of_ID int,
    AC_ID_subset int, 
    PN_ID_of int, 
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Reliability
FROM
    public.AC_subset_PN_of_Posit p
JOIN
    TABLE(public.rAC_subset_PN_of_Annex(positingTimepoint)) a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_subset_PN_of_ID
        ORDER BY a.AC_subset_PN_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fAC_subset_PN_of (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_subset_PN_of_ID int,
    AC_ID_subset int, 
    PN_ID_of int, 
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Reliability
FROM
    public.AC_subset_PN_of_Posit p
JOIN
    TABLE(public.rAC_subset_PN_of_Annex(positingTimepoint)) a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
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
    EV_in_AC_wasCast_ID int,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Reliability decimal(5,2)
)
AS
$$
SELECT
    EV_in_AC_wasCast_ID,
    EV_in_AC_wasCast_PositedAt,
    EV_in_AC_wasCast_Reliability
FROM
    public.EV_in_AC_wasCast_Annex
WHERE
    EV_in_AC_wasCast_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rEV_in_AC_wasCast (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_in_AC_wasCast_ID int,
    EV_ID_in int, 
    AC_ID_wasCast int, 
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Reliability
FROM
    public.EV_in_AC_wasCast_Posit p
JOIN
    TABLE(public.rEV_in_AC_wasCast_Annex(positingTimepoint)) a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_in_AC_wasCast_ID
        ORDER BY a.EV_in_AC_wasCast_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fEV_in_AC_wasCast (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_in_AC_wasCast_ID int,
    EV_ID_in int, 
    AC_ID_wasCast int, 
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Reliability
FROM
    public.EV_in_AC_wasCast_Posit p
JOIN
    TABLE(public.rEV_in_AC_wasCast_Annex(positingTimepoint)) a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
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
    AC_part_PR_in_RAT_got_ID int,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2)
)
AS
$$
SELECT
    AC_part_PR_in_RAT_got_ID,
    AC_part_PR_in_RAT_got_PositedAt,
    AC_part_PR_in_RAT_got_Reliability
FROM
    public.AC_part_PR_in_RAT_got_Annex
WHERE
    AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_part_PR_in_RAT_got (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID int,
    AC_ID_part int, 
    PR_ID_in int, 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Reliability
FROM
    TABLE(public.rAC_part_PR_in_RAT_got_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rAC_part_PR_in_RAT_got_Annex(positingTimepoint)) a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_part_PR_in_RAT_got_ID
        ORDER BY a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fAC_part_PR_in_RAT_got (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID int,
    AC_ID_part int, 
    PR_ID_in int, 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Reliability
FROM
    TABLE(public.fAC_part_PR_in_RAT_got_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rAC_part_PR_in_RAT_got_Annex(positingTimepoint)) a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
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
    ST_at_PR_isPlaying_ID int,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2)
)
AS
$$
SELECT
    ST_at_PR_isPlaying_ID,
    ST_at_PR_isPlaying_PositedAt,
    ST_at_PR_isPlaying_Reliability
FROM
    public.ST_at_PR_isPlaying_Annex
WHERE
    ST_at_PR_isPlaying_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rST_at_PR_isPlaying (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID int,
    ST_ID_at int, 
    PR_ID_isPlaying int, 
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Reliability
FROM
    TABLE(public.rST_at_PR_isPlaying_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rST_at_PR_isPlaying_Annex(positingTimepoint)) a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_at_PR_isPlaying_ID
        ORDER BY a.ST_at_PR_isPlaying_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fST_at_PR_isPlaying (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID int,
    ST_ID_at int, 
    PR_ID_isPlaying int, 
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Reliability
FROM
    TABLE(public.fST_at_PR_isPlaying_Posit(changingTimepoint)) p 
JOIN
    TABLE(public.rST_at_PR_isPlaying_Annex(positingTimepoint)) a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
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
    AC_parent_AC_child_PAT_having_ID int,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2)
)
AS
$$
SELECT
    AC_parent_AC_child_PAT_having_ID,
    AC_parent_AC_child_PAT_having_PositedAt,
    AC_parent_AC_child_PAT_having_Reliability
FROM
    public.AC_parent_AC_child_PAT_having_Annex
WHERE
    AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rAC_parent_AC_child_PAT_having (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_parent_AC_child_PAT_having_ID int,
    AC_ID_parent int, 
    AC_ID_child int, 
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Reliability
FROM
    public.AC_parent_AC_child_PAT_having_Posit p
JOIN
    TABLE(public.rAC_parent_AC_child_PAT_having_Annex(positingTimepoint)) a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_parent_AC_child_PAT_having_ID
        ORDER BY a.AC_parent_AC_child_PAT_having_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fAC_parent_AC_child_PAT_having (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_parent_AC_child_PAT_having_ID int,
    AC_ID_parent int, 
    AC_ID_child int, 
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Reliability
FROM
    public.AC_parent_AC_child_PAT_having_Posit p
JOIN
    TABLE(public.rAC_parent_AC_child_PAT_having_Annex(positingTimepoint)) a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
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
    PR_content_ST_location_EV_of_ID int,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    PR_content_ST_location_EV_of_ID,
    PR_content_ST_location_EV_of_PositedAt,
    PR_content_ST_location_EV_of_Reliability
FROM
    public.PR_content_ST_location_EV_of_Annex
WHERE
    PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION public.rPR_content_ST_location_EV_of (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID int,
    PR_ID_content int, 
    ST_ID_location int, 
    EV_ID_of int, 
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Reliability
FROM
    public.PR_content_ST_location_EV_of_Posit p
JOIN
    TABLE(public.rPR_content_ST_location_EV_of_Annex(positingTimepoint)) a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_content_ST_location_EV_of_ID
        ORDER BY a.PR_content_ST_location_EV_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION public.fPR_content_ST_location_EV_of (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID int,
    PR_ID_content int, 
    ST_ID_location int, 
    EV_ID_of int, 
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Reliability
FROM
    public.PR_content_ST_location_EV_of_Posit p
JOIN
    TABLE(public.rPR_content_ST_location_EV_of_Annex(positingTimepoint)) a
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
CREATE OR REPLACE FUNCTION public.tAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_ID_partner int,
    AC_ID_with int,
    ONG_Ongoing varchar(3),
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    t.AC_partner_AC_with_ONG_currently_ID,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_ID_partner,
    t.AC_ID_with,
    kONG_currently.ONG_Ongoing AS ONG_Ongoing,
    t.ONG_ID_currently
FROM
    TABLE(public.rAC_partner_AC_with_ONG_currently(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.ONG_Ongoing kONG_currently
ON
    kONG_currently.ONG_ID = t.ONG_ID_currently
WHERE
    t.AC_partner_AC_with_ONG_currently_Reliability = 1
AND
    t.AC_partner_AC_with_ONG_currently_ID = (
        SELECT
            sub.AC_partner_AC_with_ONG_currently_ID
        FROM
            TABLE(public.rAC_partner_AC_with_ONG_currently(
                changingTimepoint::datetime,
                positingTimepoint::datetime
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
CREATE OR REPLACE VIEW public.lAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_ID_partner int,
    AC_ID_with int,
    ONG_Ongoing varchar(3),
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    t.AC_partner_AC_with_ONG_currently_ID,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.ONG_Ongoing,
    t.ONG_ID_currently
FROM
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_ID_partner int,
    AC_ID_with int,
    ONG_Ongoing varchar(3),
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    t.AC_partner_AC_with_ONG_currently_ID,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.ONG_Ongoing,
    t.ONG_ID_currently
FROM
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
WHERE
    t.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION public.tAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_subset_PN_of_ID int,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_ID_subset int,
    PN_ID_of int
)
AS
$$
SELECT
    t.AC_subset_PN_of_ID,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Reliability,
    t.AC_ID_subset,
    t.PN_ID_of
FROM
    TABLE(public.rAC_subset_PN_of(
        positingTimepoint::datetime
    )) t
WHERE
    t.AC_subset_PN_of_Reliability = 1
AND
    t.AC_subset_PN_of_ID = (
        SELECT
            sub.AC_subset_PN_of_ID
        FROM
            TABLE(public.rAC_subset_PN_of(
                positingTimepoint::datetime
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
CREATE OR REPLACE VIEW public.lAC_subset_PN_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_subset_PN_of(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_subset_PN_of_ID int,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_ID_subset int,
    PN_ID_of int
)
AS
$$
SELECT
    t.AC_subset_PN_of_ID,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Reliability,
    t.AC_ID_subset,
    t.PN_ID_of
FROM
    TABLE(public.tAC_subset_PN_of(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nAC_subset_PN_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_subset_PN_of(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.tEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_in_AC_wasCast_ID int,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_ID_in int,
    AC_ID_wasCast int
)
AS
$$
SELECT
    t.EV_in_AC_wasCast_ID,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Reliability,
    t.EV_ID_in,
    t.AC_ID_wasCast
FROM
    TABLE(public.rEV_in_AC_wasCast(
        positingTimepoint::datetime
    )) t
WHERE
    t.EV_in_AC_wasCast_Reliability = 1
AND
    t.EV_in_AC_wasCast_ID = (
        SELECT
            sub.EV_in_AC_wasCast_ID
        FROM
            TABLE(public.rEV_in_AC_wasCast(
                positingTimepoint::datetime
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
CREATE OR REPLACE VIEW public.lEV_in_AC_wasCast COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tEV_in_AC_wasCast(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    EV_in_AC_wasCast_ID int,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_ID_in int,
    AC_ID_wasCast int
)
AS
$$
SELECT
    t.EV_in_AC_wasCast_ID,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Reliability,
    t.EV_ID_in,
    t.AC_ID_wasCast
FROM
    TABLE(public.tEV_in_AC_wasCast(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nEV_in_AC_wasCast COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tEV_in_AC_wasCast(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.tAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_ID_part int,
    PR_ID_in int,
    RAT_Rating varchar(42),
    RAT_ID_got tinyint
)
AS
$$
SELECT
    t.AC_part_PR_in_RAT_got_ID,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_ID_part,
    t.PR_ID_in,
    kRAT_got.RAT_Rating AS RAT_Rating,
    t.RAT_ID_got
FROM
    TABLE(public.rAC_part_PR_in_RAT_got(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.RAT_Rating kRAT_got
ON
    kRAT_got.RAT_ID = t.RAT_ID_got
WHERE
    t.AC_part_PR_in_RAT_got_Reliability = 1
AND
    t.AC_part_PR_in_RAT_got_ID = (
        SELECT
            sub.AC_part_PR_in_RAT_got_ID
        FROM
            TABLE(public.rAC_part_PR_in_RAT_got(
                changingTimepoint::datetime,
                positingTimepoint::datetime
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
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_part_PR_in_RAT_got(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_ID_part int,
    PR_ID_in int,
    RAT_Rating varchar(42),
    RAT_ID_got tinyint
)
AS
$$
SELECT
    t.AC_part_PR_in_RAT_got_ID,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_ID_part,
    t.PR_ID_in,
    t.RAT_Rating,
    t.RAT_ID_got
FROM
    TABLE(public.tAC_part_PR_in_RAT_got(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_part_PR_in_RAT_got(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_ID_part int,
    PR_ID_in int,
    RAT_Rating varchar(42),
    RAT_ID_got tinyint
)
AS
$$
SELECT
    t.AC_part_PR_in_RAT_got_ID,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_ID_part,
    t.PR_ID_in,
    t.RAT_Rating,
    t.RAT_ID_got
FROM
    TABLE(public.tAC_part_PR_in_RAT_got(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
WHERE
    t.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION public.tST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    t.ST_at_PR_isPlaying_ID,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_ID_at,
    t.PR_ID_isPlaying
FROM
    TABLE(public.rST_at_PR_isPlaying(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t.ST_at_PR_isPlaying_Reliability = 1
AND
    t.ST_at_PR_isPlaying_ID = (
        SELECT
            sub.ST_at_PR_isPlaying_ID
        FROM
            TABLE(public.rST_at_PR_isPlaying(
                changingTimepoint::datetime,
                positingTimepoint::datetime
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
CREATE OR REPLACE VIEW public.lST_at_PR_isPlaying COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tST_at_PR_isPlaying(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    t.ST_at_PR_isPlaying_ID,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_ID_at,
    t.PR_ID_isPlaying
FROM
    TABLE(public.tST_at_PR_isPlaying(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nST_at_PR_isPlaying COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tST_at_PR_isPlaying(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    t.ST_at_PR_isPlaying_ID,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_ID_at,
    t.PR_ID_isPlaying
FROM
    TABLE(public.tST_at_PR_isPlaying(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
WHERE
    t.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION public.tAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_parent_AC_child_PAT_having_ID int,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_ID_parent int,
    AC_ID_child int,
    PAT_ParentalType varchar(42),
    PAT_ID_having tinyint
)
AS
$$
SELECT
    t.AC_parent_AC_child_PAT_having_ID,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Reliability,
    t.AC_ID_parent,
    t.AC_ID_child,
    kPAT_having.PAT_ParentalType AS PAT_ParentalType,
    t.PAT_ID_having
FROM
    TABLE(public.rAC_parent_AC_child_PAT_having(
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.PAT_ParentalType kPAT_having
ON
    kPAT_having.PAT_ID = t.PAT_ID_having
WHERE
    t.AC_parent_AC_child_PAT_having_Reliability = 1
AND
    t.AC_parent_AC_child_PAT_having_ID = (
        SELECT
            sub.AC_parent_AC_child_PAT_having_ID
        FROM
            TABLE(public.rAC_parent_AC_child_PAT_having(
                positingTimepoint::datetime
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
CREATE OR REPLACE VIEW public.lAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_parent_AC_child_PAT_having(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_parent_AC_child_PAT_having_ID int,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_ID_parent int,
    AC_ID_child int,
    PAT_ParentalType varchar(42),
    PAT_ID_having tinyint
)
AS
$$
SELECT
    t.AC_parent_AC_child_PAT_having_ID,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Reliability,
    t.AC_ID_parent,
    t.AC_ID_child,
    t.PAT_ParentalType,
    t.PAT_ID_having
FROM
    TABLE(public.tAC_parent_AC_child_PAT_having(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_parent_AC_child_PAT_having(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.tPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID int,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
)
AS
$$
SELECT
    t.PR_content_ST_location_EV_of_ID,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of
FROM
    TABLE(public.rPR_content_ST_location_EV_of(
        positingTimepoint::datetime
    )) t
WHERE
    t.PR_content_ST_location_EV_of_Reliability = 1
AND
    t.PR_content_ST_location_EV_of_ID = (
        SELECT
            sub.PR_content_ST_location_EV_of_ID
        FROM
            TABLE(public.rPR_content_ST_location_EV_of(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID_of = t.EV_ID_of
        ORDER BY
            sub.PR_content_ST_location_EV_of_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public.lPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tPR_content_ST_location_EV_of(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID int,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
)
AS
$$
SELECT
    t.PR_content_ST_location_EV_of_ID,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of
FROM
    TABLE(public.tPR_content_ST_location_EV_of(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tPR_content_ST_location_EV_of(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
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
COMMENT ON COLUMN public.ST_AVG_Stage_Average_Posit.UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN public.ST_MIN_Stage_Minimum_Posit.UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN public.AC_NAM_Actor_Name_Posit.AC_NAM_Actor_Name IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN public.AC_GEN_Actor_Gender_Posit.GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN public.AC_PLV_Actor_ProfessionalLevel_Posit.PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
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
