-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
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
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_DAT_Event_Date (
    EV_DAT_EV_ID int not null,
    EV_DAT_Event_Date datetime not null,
    Metadata_EV_DAT int not null,
    constraint fkEV_DAT_Event_Date foreign key (
        EV_DAT_EV_ID
    ) references public.EV_Event(EV_ID) RELY,
    constraint pkEV_DAT_Event_Date primary key (
        EV_DAT_EV_ID
    ) RELY
) CLUSTER BY (EV_DAT_EV_ID);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_AUD_Event_Audience (
    EV_AUD_EV_ID int not null,
    EV_AUD_Event_Audience int not null,
    Metadata_EV_AUD int not null,
    constraint fkEV_AUD_Event_Audience foreign key (
        EV_AUD_EV_ID
    ) references public.EV_Event(EV_ID) RELY,
    constraint pkEV_AUD_Event_Audience primary key (
        EV_AUD_EV_ID
    ) RELY
) CLUSTER BY (EV_AUD_EV_ID);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_REV_Event_Revenue (
    EV_REV_EV_ID int not null,
    EV_REV_Event_Revenue number(19,4) not null,
    Metadata_EV_REV int not null,
    constraint fkEV_REV_Event_Revenue foreign key (
        EV_REV_EV_ID
    ) references public.EV_Event(EV_ID) RELY,
    constraint pkEV_REV_Event_Revenue primary key (
        EV_REV_EV_ID
    ) RELY
) CLUSTER BY (EV_REV_EV_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_NAM_Stage_Name (
    ST_NAM_ST_ID int not null,
    ST_NAM_Stage_Name varchar(42) not null,
    ST_NAM_ChangedAt datetime not null,
    Metadata_ST_NAM int not null,
    constraint fkST_NAM_Stage_Name foreign key (
        ST_NAM_ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint pkST_NAM_Stage_Name primary key (
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt
    ) RELY
) CLUSTER BY (ST_NAM_ST_ID);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_LOC_Stage_Location (
    ST_LOC_ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum numeric(19,0) default hash(ST_LOC_Stage_Location),
    Metadata_ST_LOC int not null,
    constraint fkST_LOC_Stage_Location foreign key (
        ST_LOC_ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint pkST_LOC_Stage_Location primary key (
        ST_LOC_ST_ID
    ) RELY
) CLUSTER BY (ST_LOC_ST_ID);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_AVG_Stage_Average (
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime not null,
    Metadata_ST_AVG int not null,
    constraint fk_A_ST_AVG_Stage_Average foreign key (
        ST_AVG_ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint fk_K_ST_AVG_Stage_Average foreign key (
        ST_AVG_UTL_ID
    ) references public.UTL_Utilization(UTL_ID) RELY,
    constraint pkST_AVG_Stage_Average primary key (
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt
    ) RELY
) CLUSTER BY (ST_AVG_ST_ID);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_MIN_Stage_Minimum (
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    Metadata_ST_MIN int not null,
    constraint fk_A_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_ST_ID
    ) references public.ST_Stage(ST_ID) RELY,
    constraint fk_K_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_UTL_ID
    ) references public.UTL_Utilization(UTL_ID) RELY,
    constraint pkST_MIN_Stage_Minimum primary key (
        ST_MIN_ST_ID
    ) RELY
) CLUSTER BY (ST_MIN_ST_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_NAM_Actor_Name (
    AC_NAM_AC_ID int not null,
    AC_NAM_Actor_Name varchar(42) not null,
    AC_NAM_ChangedAt datetime not null,
    Metadata_AC_NAM int not null,
    constraint fkAC_NAM_Actor_Name foreign key (
        AC_NAM_AC_ID
    ) references public.AC_Actor(AC_ID) RELY,
    constraint pkAC_NAM_Actor_Name primary key (
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt
    ) RELY
) CLUSTER BY (AC_NAM_AC_ID);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_GEN_Actor_Gender (
    AC_GEN_AC_ID int not null,
    AC_GEN_GEN_ID number(1,0) not null,
    Metadata_AC_GEN int not null,
    constraint fk_A_AC_GEN_Actor_Gender foreign key (
        AC_GEN_AC_ID
    ) references public.AC_Actor(AC_ID) RELY,
    constraint fk_K_AC_GEN_Actor_Gender foreign key (
        AC_GEN_GEN_ID
    ) references public.GEN_Gender(GEN_ID) RELY,
    constraint pkAC_GEN_Actor_Gender primary key (
        AC_GEN_AC_ID
    ) RELY
) CLUSTER BY (AC_GEN_AC_ID);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel (
    AC_PLV_AC_ID int not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime not null,
    Metadata_AC_PLV int not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_AC_ID
    ) references public.AC_Actor(AC_ID) RELY,
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_PLV_ID
    ) references public.PLV_ProfessionalLevel(PLV_ID) RELY,
    constraint pkAC_PLV_Actor_ProfessionalLevel primary key (
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt
    ) RELY
) CLUSTER BY (AC_PLV_AC_ID);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_NAM_Program_Name (
    PR_NAM_PR_ID int not null,
    PR_NAM_Program_Name varchar(42) not null,
    Metadata_PR_NAM int not null,
    constraint fkPR_NAM_Program_Name foreign key (
        PR_NAM_PR_ID
    ) references public.PR_Program(PR_ID) RELY,
    constraint pkPR_NAM_Program_Name primary key (
        PR_NAM_PR_ID
    ) RELY
) CLUSTER BY (PR_NAM_PR_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_LEN_Program_Length (
    PR_LEN_PR_ID int not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    Metadata_PR_LEN int not null,
    constraint fkPR_LEN_Program_Length foreign key (
        PR_LEN_PR_ID
    ) references public.PR_Program(PR_ID) RELY,
    constraint pkPR_LEN_Program_Length primary key (
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt
    ) RELY
) CLUSTER BY (PR_LEN_PR_ID);
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_partner_AC_with_ONG_currently (
    AC_ID_partner int not null, 
    AC_ID_with int not null, 
    ONG_ID_currently tinyint not null,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime not null,
    Metadata_AC_partner_AC_with_ONG_currently int not null,
    constraint AC_partner_AC_with_ONG_currently_fkAC_partner foreign key (
        AC_ID_partner
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_partner_AC_with_ONG_currently_fkAC_with foreign key (
        AC_ID_with
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_partner_AC_with_ONG_currently_fkONG_currently foreign key (
        ONG_ID_currently
    ) references public.ONG_Ongoing(ONG_ID) RELY,
    constraint AC_partner_AC_with_ONG_currently_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ) RELY,
    constraint AC_partner_AC_with_ONG_currently_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ) RELY,
    constraint pkAC_partner_AC_with_ONG_currently primary key (
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ) RELY
) CLUSTER BY (
    AC_ID_partner,
    AC_ID_with
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_subset_PN_of (
    AC_ID_subset int not null, 
    PN_ID_of int not null, 
    Metadata_AC_subset_PN_of int not null,
    constraint AC_subset_PN_of_fkAC_subset foreign key (
        AC_ID_subset
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_subset_PN_of_fkPN_of foreign key (
        PN_ID_of
    ) references public.PN_Person(PN_ID) RELY, 
    constraint AC_subset_PN_of_uqAC_subset unique (
        AC_ID_subset
    ) RELY,
    constraint AC_subset_PN_of_uqPN_of unique (
        PN_ID_of
    ) RELY,
    constraint pkAC_subset_PN_of primary key (
        AC_ID_subset,
        PN_ID_of
    ) RELY
) CLUSTER BY (
    AC_ID_subset,
    PN_ID_of
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_in_AC_wasCast (
    EV_ID_in int not null, 
    AC_ID_wasCast int not null, 
    Metadata_EV_in_AC_wasCast int not null,
    constraint EV_in_AC_wasCast_fkEV_in foreign key (
        EV_ID_in
    ) references public.EV_Event(EV_ID) RELY, 
    constraint EV_in_AC_wasCast_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint pkEV_in_AC_wasCast primary key (
        EV_ID_in,
        AC_ID_wasCast
    ) RELY
) CLUSTER BY (
    AC_ID_wasCast
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_part_PR_in_RAT_got (
    AC_ID_part int not null, 
    PR_ID_in int not null, 
    RAT_ID_got tinyint not null,
    AC_part_PR_in_RAT_got_ChangedAt datetime not null,
    Metadata_AC_part_PR_in_RAT_got int not null,
    constraint AC_part_PR_in_RAT_got_fkAC_part foreign key (
        AC_ID_part
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_part_PR_in_RAT_got_fkPR_in foreign key (
        PR_ID_in
    ) references public.PR_Program(PR_ID) RELY, 
    constraint AC_part_PR_in_RAT_got_fkRAT_got foreign key (
        RAT_ID_got
    ) references public.RAT_Rating(RAT_ID) RELY,
    constraint pkAC_part_PR_in_RAT_got primary key (
        AC_ID_part,
        PR_ID_in,
        AC_part_PR_in_RAT_got_ChangedAt
    ) RELY
) CLUSTER BY (
    AC_ID_part,
    PR_ID_in
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_at_PR_isPlaying (
    ST_ID_at int not null, 
    PR_ID_isPlaying int not null, 
    ST_at_PR_isPlaying_ChangedAt datetime not null,
    Metadata_ST_at_PR_isPlaying int not null,
    constraint ST_at_PR_isPlaying_fkST_at foreign key (
        ST_ID_at
    ) references public.ST_Stage(ST_ID) RELY, 
    constraint ST_at_PR_isPlaying_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references public.PR_Program(PR_ID) RELY, 
    constraint pkST_at_PR_isPlaying primary key (
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    ) RELY
) CLUSTER BY (
    ST_ID_at,
    PR_ID_isPlaying
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_parent_AC_child_PAT_having (
    AC_ID_parent int not null, 
    AC_ID_child int not null, 
    PAT_ID_having tinyint not null,
    Metadata_AC_parent_AC_child_PAT_having int not null,
    constraint AC_parent_AC_child_PAT_having_fkAC_parent foreign key (
        AC_ID_parent
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_parent_AC_child_PAT_having_fkAC_child foreign key (
        AC_ID_child
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_parent_AC_child_PAT_having_fkPAT_having foreign key (
        PAT_ID_having
    ) references public.PAT_ParentalType(PAT_ID) RELY,
    constraint pkAC_parent_AC_child_PAT_having primary key (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    ) RELY
) CLUSTER BY (
    AC_ID_parent,
    AC_ID_child
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_content_ST_location_EV_of (
    PR_ID_content int not null, 
    ST_ID_location int not null, 
    EV_ID_of int not null, 
    Metadata_PR_content_ST_location_EV_of int not null,
    constraint PR_content_ST_location_EV_of_fkPR_content foreign key (
        PR_ID_content
    ) references public.PR_Program(PR_ID) RELY, 
    constraint PR_content_ST_location_EV_of_fkST_location foreign key (
        ST_ID_location
    ) references public.ST_Stage(ST_ID) RELY, 
    constraint PR_content_ST_location_EV_of_fkEV_of foreign key (
        EV_ID_of
    ) references public.EV_Event(EV_ID) RELY, 
    constraint pkPR_content_ST_location_EV_of primary key (
        EV_ID_of
    ) RELY
) CLUSTER BY (
    PR_ID_content,
    ST_ID_location
);
-- KNOT EQUIVALENCE VIEWS ---------------------------------------------------------------------------------------------
--
-- Equivalence views combine the identity and equivalent parts of a knot into a single view, making
-- it look and behave like a regular knot. They also make it possible to retrieve data for only the
-- given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
    SELECT
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        public.ST_NAM_Stage_Name
    WHERE
        ST_NAM_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_AVG int,
    ST_AVG_ST_ID int,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
    SELECT
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt
    FROM
        public.ST_AVG_Stage_Average
    WHERE
        ST_AVG_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
    SELECT
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        public.AC_NAM_Actor_Name
    WHERE
        AC_NAM_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_AC_ID int,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
    SELECT
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt
    FROM
        public.AC_PLV_Actor_ProfessionalLevel
    WHERE
        AC_PLV_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
    SELECT
        Metadata_PR_LEN,
        PR_LEN_PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt
    FROM
        public.PR_LEN_Program_Length
    WHERE
        PR_LEN_ChangedAt <= changingTimepoint
$$
;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native anchor perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and their equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lST_Stage (
    ST_ID,
    Metadata_ST,
    ST_NAM_ST_ID,
    Metadata_ST_NAM,
    ST_NAM_ChangedAt,
    ST_NAM_Stage_Name,
    ST_LOC_ST_ID,
    Metadata_ST_LOC,
    ST_LOC_Checksum,
    ST_LOC_Stage_Location,
    ST_AVG_ST_ID,
    Metadata_ST_AVG,
    ST_AVG_ChangedAt,
    ST_AVG_UTL_Utilization,
    ST_AVG_Metadata_UTL,
    ST_AVG_UTL_ID,
    ST_MIN_ST_ID,
    Metadata_ST_MIN,
    ST_MIN_UTL_Utilization,
    ST_MIN_Metadata_UTL,
    ST_MIN_UTL_ID
) COPY GRANTS 
AS
SELECT
    ST.ST_ID,
    ST.Metadata_ST,
    NAM.ST_NAM_ST_ID,
    NAM.Metadata_ST_NAM,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.Metadata_ST_LOC,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ST_ID,
    AVG.Metadata_ST_AVG,
    AVG.ST_AVG_ChangedAt,
    kAVG.UTL_Utilization AS ST_AVG_UTL_Utilization,
    kAVG.Metadata_UTL AS ST_AVG_Metadata_UTL,
    AVG.ST_AVG_UTL_ID,
    MIN.ST_MIN_ST_ID,
    MIN.Metadata_ST_MIN,
    kMIN.UTL_Utilization AS ST_MIN_UTL_Utilization,
    kMIN.Metadata_UTL AS ST_MIN_Metadata_UTL,
    MIN.ST_MIN_UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    public.ST_NAM_Stage_Name NAM
ON
    NAM.ST_NAM_ST_ID = ST.ST_ID
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            public.ST_NAM_Stage_Name sub
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
   )
LEFT JOIN
    public.ST_LOC_Stage_Location LOC
ON
    LOC.ST_LOC_ST_ID = ST.ST_ID
LEFT JOIN
    public.ST_AVG_Stage_Average AVG
ON
    AVG.ST_AVG_ST_ID = ST.ST_ID
AND
    AVG.ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            public.ST_AVG_Stage_Average sub
        WHERE
            sub.ST_AVG_ST_ID = ST.ST_ID
   )
LEFT JOIN
    public.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.ST_AVG_UTL_ID
LEFT JOIN
    public.ST_MIN_Stage_Minimum MIN
ON
    MIN.ST_MIN_ST_ID = ST.ST_ID
LEFT JOIN
    public.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.ST_MIN_UTL_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pST_Stage (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    ST_ID int,
    Metadata_ST int,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC int,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL int,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN int,
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
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.Metadata_ST_LOC,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ST_ID,
    AVG.Metadata_ST_AVG,
    AVG.ST_AVG_ChangedAt,
    kAVG.UTL_Utilization AS ST_AVG_UTL_Utilization,
    kAVG.Metadata_UTL AS ST_AVG_Metadata_UTL,
    AVG.ST_AVG_UTL_ID,
    MIN.ST_MIN_ST_ID,
    MIN.Metadata_ST_MIN,
    kMIN.UTL_Utilization AS ST_MIN_UTL_Utilization,
    kMIN.Metadata_UTL AS ST_MIN_Metadata_UTL,
    MIN.ST_MIN_UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    TABLE(public.rST_NAM_Stage_Name(changingTimepoint::datetime)) NAM
ON
    NAM.ST_NAM_ST_ID = ST.ST_ID
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            TABLE(public.rST_NAM_Stage_Name(changingTimepoint::datetime)) sub
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
   )
LEFT JOIN
    public.ST_LOC_Stage_Location LOC
ON
    LOC.ST_LOC_ST_ID = ST.ST_ID
LEFT JOIN
    TABLE(public.rST_AVG_Stage_Average(changingTimepoint::datetime)) AVG
ON
    AVG.ST_AVG_ST_ID = ST.ST_ID
AND
    AVG.ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            TABLE(public.rST_AVG_Stage_Average(changingTimepoint::datetime)) sub
        WHERE
            sub.ST_AVG_ST_ID = ST.ST_ID
   )
LEFT JOIN
    public.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.ST_AVG_UTL_ID
LEFT JOIN
    public.ST_MIN_Stage_Minimum MIN
ON
    MIN.ST_MIN_ST_ID = ST.ST_ID
LEFT JOIN
    public.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.ST_MIN_UTL_ID
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nST_Stage COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(public.pST_Stage(sysdate()::timestamp_ntz(9)))
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
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    ST_ID int,
    Metadata_ST int,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC int,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL int,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN int,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_Metadata_UTL int,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT DISTINCT
    hNAM.ST_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    pST.ST_ID,
    pST.Metadata_ST,
    pST.ST_NAM_ST_ID,
    pST.Metadata_ST_NAM,
    pST.ST_NAM_ChangedAt,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_ST_ID,
    pST.Metadata_ST_LOC,
    pST.ST_LOC_Checksum,
    pST.ST_LOC_Stage_Location,
    pST.ST_AVG_ST_ID,
    pST.Metadata_ST_AVG,
    pST.ST_AVG_ChangedAt,
    pST.ST_AVG_UTL_Utilization,
    pST.ST_AVG_Metadata_UTL,
    pST.ST_AVG_UTL_ID,
    pST.ST_MIN_ST_ID,
    pST.Metadata_ST_MIN,
    pST.ST_MIN_UTL_Utilization,
    pST.ST_MIN_Metadata_UTL,
    pST.ST_MIN_UTL_ID
FROM
    public.ST_NAM_Stage_Name hNAM,
    TABLE(public.pST_Stage(hNAM.ST_NAM_ChangedAt::timestamp_ntz(9))) pST
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    hNAM.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pST.ST_ID = hNAM.ST_NAM_ST_ID
UNION
SELECT DISTINCT
    hAVG.ST_AVG_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'AVG' AS mnemonic,
    pST.ST_ID,
    pST.Metadata_ST,
    pST.ST_NAM_ST_ID,
    pST.Metadata_ST_NAM,
    pST.ST_NAM_ChangedAt,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_ST_ID,
    pST.Metadata_ST_LOC,
    pST.ST_LOC_Checksum,
    pST.ST_LOC_Stage_Location,
    pST.ST_AVG_ST_ID,
    pST.Metadata_ST_AVG,
    pST.ST_AVG_ChangedAt,
    pST.ST_AVG_UTL_Utilization,
    pST.ST_AVG_Metadata_UTL,
    pST.ST_AVG_UTL_ID,
    pST.ST_MIN_ST_ID,
    pST.Metadata_ST_MIN,
    pST.ST_MIN_UTL_Utilization,
    pST.ST_MIN_Metadata_UTL,
    pST.ST_MIN_UTL_ID
FROM
    public.ST_AVG_Stage_Average hAVG,
    TABLE(public.pST_Stage(hAVG.ST_AVG_ChangedAt::timestamp_ntz(9))) pST
WHERE
    (selection IS NULL OR selection LIKE '%AVG%')
AND
    hAVG.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pST.ST_ID = hAVG.ST_AVG_ST_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_Actor (
    AC_ID,
    Metadata_AC,
    AC_NAM_AC_ID,
    Metadata_AC_NAM,
    AC_NAM_ChangedAt,
    AC_NAM_Actor_Name,
    AC_GEN_AC_ID,
    Metadata_AC_GEN,
    AC_GEN_GEN_Gender,
    AC_GEN_Metadata_GEN,
    AC_GEN_GEN_ID,
    AC_PLV_AC_ID,
    Metadata_AC_PLV,
    AC_PLV_ChangedAt,
    AC_PLV_PLV_Checksum,
    AC_PLV_PLV_ProfessionalLevel,
    AC_PLV_Metadata_PLV,
    AC_PLV_PLV_ID
) COPY GRANTS 
AS
SELECT
    AC.AC_ID,
    AC.Metadata_AC,
    NAM.AC_NAM_AC_ID,
    NAM.Metadata_AC_NAM,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_Actor_Name,
    GEN.AC_GEN_AC_ID,
    GEN.Metadata_AC_GEN,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    kGEN.Metadata_GEN AS AC_GEN_Metadata_GEN,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.Metadata_AC_PLV,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_Checksum AS AC_PLV_PLV_Checksum,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    kPLV.Metadata_PLV AS AC_PLV_Metadata_PLV,
    PLV.AC_PLV_PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    public.AC_NAM_Actor_Name NAM
ON
    NAM.AC_NAM_AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            public.AC_NAM_Actor_Name sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_GEN_AC_ID = AC.AC_ID
LEFT JOIN
    public.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.AC_GEN_GEN_ID
LEFT JOIN
    public.AC_PLV_Actor_ProfessionalLevel PLV
ON
    PLV.AC_PLV_AC_ID = AC.AC_ID
AND
    PLV.AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            public.AC_PLV_Actor_ProfessionalLevel sub
        WHERE
            sub.AC_PLV_AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.AC_PLV_PLV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_Actor (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_ID int,
    Metadata_AC int,
    AC_NAM_AC_ID int,
    Metadata_AC_NAM int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    Metadata_AC_GEN int,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN int,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    Metadata_AC_PLV int,
    AC_PLV_ChangedAt datetime,
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
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_Actor_Name,
    GEN.AC_GEN_AC_ID,
    GEN.Metadata_AC_GEN,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    kGEN.Metadata_GEN AS AC_GEN_Metadata_GEN,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.Metadata_AC_PLV,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_Checksum AS AC_PLV_PLV_Checksum,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    kPLV.Metadata_PLV AS AC_PLV_Metadata_PLV,
    PLV.AC_PLV_PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    TABLE(public.rAC_NAM_Actor_Name(changingTimepoint::datetime)) NAM
ON
    NAM.AC_NAM_AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            TABLE(public.rAC_NAM_Actor_Name(changingTimepoint::datetime)) sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_GEN_AC_ID = AC.AC_ID
LEFT JOIN
    public.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.AC_GEN_GEN_ID
LEFT JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint::datetime)) PLV
ON
    PLV.AC_PLV_AC_ID = AC.AC_ID
AND
    PLV.AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            TABLE(public.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint::datetime)) sub
        WHERE
            sub.AC_PLV_AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.AC_PLV_PLV_ID
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_Actor COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(public.pAC_Actor(sysdate()::timestamp_ntz(9)))
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
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    AC_ID int,
    Metadata_AC int,
    AC_NAM_AC_ID int,
    Metadata_AC_NAM int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    Metadata_AC_GEN int,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN int,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    Metadata_AC_PLV int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_Metadata_PLV int,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT DISTINCT
    hNAM.AC_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    pAC.AC_ID,
    pAC.Metadata_AC,
    pAC.AC_NAM_AC_ID,
    pAC.Metadata_AC_NAM,
    pAC.AC_NAM_ChangedAt,
    pAC.AC_NAM_Actor_Name,
    pAC.AC_GEN_AC_ID,
    pAC.Metadata_AC_GEN,
    pAC.AC_GEN_GEN_Gender,
    pAC.AC_GEN_Metadata_GEN,
    pAC.AC_GEN_GEN_ID,
    pAC.AC_PLV_AC_ID,
    pAC.Metadata_AC_PLV,
    pAC.AC_PLV_ChangedAt,
    pAC.AC_PLV_PLV_Checksum,
    pAC.AC_PLV_PLV_ProfessionalLevel,
    pAC.AC_PLV_Metadata_PLV,
    pAC.AC_PLV_PLV_ID
FROM
    public.AC_NAM_Actor_Name hNAM,
    TABLE(public.pAC_Actor(hNAM.AC_NAM_ChangedAt::timestamp_ntz(9))) pAC
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    hNAM.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pAC.AC_ID = hNAM.AC_NAM_AC_ID
UNION
SELECT DISTINCT
    hPLV.AC_PLV_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'PLV' AS mnemonic,
    pAC.AC_ID,
    pAC.Metadata_AC,
    pAC.AC_NAM_AC_ID,
    pAC.Metadata_AC_NAM,
    pAC.AC_NAM_ChangedAt,
    pAC.AC_NAM_Actor_Name,
    pAC.AC_GEN_AC_ID,
    pAC.Metadata_AC_GEN,
    pAC.AC_GEN_GEN_Gender,
    pAC.AC_GEN_Metadata_GEN,
    pAC.AC_GEN_GEN_ID,
    pAC.AC_PLV_AC_ID,
    pAC.Metadata_AC_PLV,
    pAC.AC_PLV_ChangedAt,
    pAC.AC_PLV_PLV_Checksum,
    pAC.AC_PLV_PLV_ProfessionalLevel,
    pAC.AC_PLV_Metadata_PLV,
    pAC.AC_PLV_PLV_ID
FROM
    public.AC_PLV_Actor_ProfessionalLevel hPLV,
    TABLE(public.pAC_Actor(hPLV.AC_PLV_ChangedAt::timestamp_ntz(9))) pAC
WHERE
    (selection IS NULL OR selection LIKE '%PLV%')
AND
    hPLV.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pAC.AC_ID = hPLV.AC_PLV_AC_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lPR_Program (
    PR_ID,
    Metadata_PR,
    PR_NAM_PR_ID,
    Metadata_PR_NAM,
    PR_NAM_Program_Name,
    PR_LEN_PR_ID,
    Metadata_PR_LEN,
    PR_LEN_ChangedAt,
    PR_LEN_Program_Length
) COPY GRANTS 
AS
SELECT
    PR.PR_ID,
    PR.Metadata_PR,
    NAM.PR_NAM_PR_ID,
    NAM.Metadata_PR_NAM,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_PR_ID,
    LEN.Metadata_PR_LEN,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_Program_Length
FROM
    public.PR_Program PR
LEFT JOIN
    public.PR_NAM_Program_Name NAM
ON
    NAM.PR_NAM_PR_ID = PR.PR_ID
LEFT JOIN
    public.PR_LEN_Program_Length LEN
ON
    LEN.PR_LEN_PR_ID = PR.PR_ID
AND
    LEN.PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            public.PR_LEN_Program_Length sub
        WHERE
            sub.PR_LEN_PR_ID = PR.PR_ID
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pPR_Program (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    PR_ID int,
    Metadata_PR int,
    PR_NAM_PR_ID int,
    Metadata_PR_NAM int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    Metadata_PR_LEN int,
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    PR.PR_ID,
    PR.Metadata_PR,
    NAM.PR_NAM_PR_ID,
    NAM.Metadata_PR_NAM,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_PR_ID,
    LEN.Metadata_PR_LEN,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_Program_Length
FROM
    public.PR_Program PR
LEFT JOIN
    public.PR_NAM_Program_Name NAM
ON
    NAM.PR_NAM_PR_ID = PR.PR_ID
LEFT JOIN
    TABLE(public.rPR_LEN_Program_Length(changingTimepoint::date)) LEN
ON
    LEN.PR_LEN_PR_ID = PR.PR_ID
AND
    LEN.PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            TABLE(public.rPR_LEN_Program_Length(changingTimepoint::date)) sub
        WHERE
            sub.PR_LEN_PR_ID = PR.PR_ID
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nPR_Program COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(public.pPR_Program(sysdate()::timestamp_ntz(9)))
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
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    PR_ID int,
    Metadata_PR int,
    PR_NAM_PR_ID int,
    Metadata_PR_NAM int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    Metadata_PR_LEN int,
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT DISTINCT
    hLEN.PR_LEN_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'LEN' AS mnemonic,
    pPR.PR_ID,
    pPR.Metadata_PR,
    pPR.PR_NAM_PR_ID,
    pPR.Metadata_PR_NAM,
    pPR.PR_NAM_Program_Name,
    pPR.PR_LEN_PR_ID,
    pPR.Metadata_PR_LEN,
    pPR.PR_LEN_ChangedAt,
    pPR.PR_LEN_Program_Length
FROM
    public.PR_LEN_Program_Length hLEN,
    TABLE(public.pPR_Program(hLEN.PR_LEN_ChangedAt::timestamp_ntz(9))) pPR
WHERE
    (selection IS NULL OR selection LIKE '%LEN%')
AND
    hLEN.PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pPR.PR_ID = hLEN.PR_LEN_PR_ID
$$
;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native nexus perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lEV_Event (
    EV_ID,
    Metadata_EV,
    ST_ID_wasHeldAt,
    PR_ID_wasPlayed,
    of_ETY_EventType,
    of_Metadata_ETY,
    ETY_ID_of,
    EV_DAT_EV_ID,
    Metadata_EV_DAT,
    EV_DAT_Event_Date,
    EV_AUD_EV_ID,
    Metadata_EV_AUD,
    EV_AUD_Event_Audience,
    EV_REV_EV_ID,
    Metadata_EV_REV,
    EV_REV_Event_Revenue
) COPY GRANTS 
AS
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    ETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    public.EV_DAT_Event_Date DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_REV_Event_Revenue REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_Event (
    changingTimepoint timestamp_ntz(9)
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
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    Metadata_EV_AUD int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    Metadata_EV_REV int,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    ETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    public.EV_DAT_Event_Date DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_REV_Event_Revenue REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nEV_Event COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pEV_Event(sysdate()::timestamp_ntz(9)))
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_partner_AC_with_ONG_currently (
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt,
    AC_ID_partner,
    AC_ID_with,
    currently_ONG_Ongoing,
    currently_Metadata_ONG,
    ONG_ID_currently
) COPY GRANTS 
AS
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    public.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            public.AC_partner_AC_with_ONG_currently sub
        WHERE
            sub.AC_ID_partner = tie.AC_ID_partner
        OR
            sub.AC_ID_with = tie.AC_ID_with
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG int,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    public.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            public.AC_partner_AC_with_ONG_currently sub
        WHERE
        (
            sub.AC_ID_partner = tie.AC_ID_partner
        OR
            sub.AC_ID_with = tie.AC_ID_with
        )
        AND
            sub.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pAC_partner_AC_with_ONG_currently(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG int,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    public.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_subset_PN_of (
    Metadata_AC_subset_PN_of,
    AC_ID_subset,
    PN_ID_of
) COPY GRANTS 
AS
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    public.AC_subset_PN_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_ID_subset int,
    PN_ID_of int
)
AS
$$
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    public.AC_subset_PN_of tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_subset_PN_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pAC_subset_PN_of(sysdate()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lEV_in_AC_wasCast (
    Metadata_EV_in_AC_wasCast,
    EV_ID_in,
    AC_ID_wasCast
) COPY GRANTS 
AS
SELECT
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    public.EV_in_AC_wasCast tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_ID_in int,
    AC_ID_wasCast int
)
AS
$$
SELECT
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    public.EV_in_AC_wasCast tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nEV_in_AC_wasCast COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pEV_in_AC_wasCast(sysdate()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got (
    Metadata_AC_part_PR_in_RAT_got,
    AC_part_PR_in_RAT_got_ChangedAt,
    AC_ID_part,
    PR_ID_in,
    got_RAT_Rating,
    got_Metadata_RAT,
    RAT_ID_got
) COPY GRANTS 
AS
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    public.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            public.AC_part_PR_in_RAT_got sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_Metadata_RAT int,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    public.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            public.AC_part_PR_in_RAT_got sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
        AND
            sub.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pAC_part_PR_in_RAT_got(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_Metadata_RAT int,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    public.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lST_at_PR_isPlaying (
    Metadata_ST_at_PR_isPlaying,
    ST_at_PR_isPlaying_ChangedAt,
    ST_ID_at,
    PR_ID_isPlaying
) COPY GRANTS 
AS
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    public.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            public.ST_at_PR_isPlaying sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    public.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            public.ST_at_PR_isPlaying sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
        AND
            sub.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nST_at_PR_isPlaying COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pST_at_PR_isPlaying(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    public.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_parent_AC_child_PAT_having (
    Metadata_AC_parent_AC_child_PAT_having,
    AC_ID_parent,
    AC_ID_child,
    having_PAT_ParentalType,
    having_Metadata_PAT,
    PAT_ID_having
) COPY GRANTS 
AS
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    PAT_having.Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    public.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    public.PAT_ParentalType PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_ID_parent int,
    AC_ID_child int,
    having_PAT_ParentalType varchar(42),
    having_Metadata_PAT int,
    PAT_ID_having tinyint
)
AS
$$
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    PAT_having.Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    public.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    public.PAT_ParentalType PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pAC_parent_AC_child_PAT_having(sysdate()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lPR_content_ST_location_EV_of (
    Metadata_PR_content_ST_location_EV_of,
    PR_ID_content,
    ST_ID_location,
    EV_ID_of
) COPY GRANTS 
AS
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    public.PR_content_ST_location_EV_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
)
AS
$$
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    public.PR_content_ST_location_EV_of tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pPR_content_ST_location_EV_of(sysdate()::timestamp_ntz(9)))
;
-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- Snowflake does not enforce primary, unique or foreign keys, and every key here is declared RELY, which tells the
-- optimizer to trust it. A violation is therefore not an error, but wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--   restatement                                   in an attribute or a tie that may not store them, a value
--                                                 that is the same as the one before it in changing time
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
-- EV_DAT_Event_Date integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_DAT_Event_Date (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Event_Date',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_DAT_EV_ID', EV_DAT_EV_ID
    ),
    COUNT(*)
FROM
    public.EV_DAT_Event_Date
GROUP BY
    EV_DAT_EV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date',
    'no row in EV_Event for EV_DAT_EV_ID',
    OBJECT_CONSTRUCT('EV_DAT_EV_ID', c.EV_DAT_EV_ID),
    COUNT(*)
FROM
    public.EV_DAT_Event_Date c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_DAT_EV_ID
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_DAT_EV_ID
;
-- EV_AUD_Event_Audience integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_AUD_Event_Audience (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Event_Audience',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_AUD_EV_ID', EV_AUD_EV_ID
    ),
    COUNT(*)
FROM
    public.EV_AUD_Event_Audience
GROUP BY
    EV_AUD_EV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience',
    'no row in EV_Event for EV_AUD_EV_ID',
    OBJECT_CONSTRUCT('EV_AUD_EV_ID', c.EV_AUD_EV_ID),
    COUNT(*)
FROM
    public.EV_AUD_Event_Audience c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_AUD_EV_ID
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_AUD_EV_ID
;
-- EV_REV_Event_Revenue integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_REV_Event_Revenue (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Event_Revenue',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_REV_EV_ID', EV_REV_EV_ID
    ),
    COUNT(*)
FROM
    public.EV_REV_Event_Revenue
GROUP BY
    EV_REV_EV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue',
    'no row in EV_Event for EV_REV_EV_ID',
    OBJECT_CONSTRUCT('EV_REV_EV_ID', c.EV_REV_EV_ID),
    COUNT(*)
FROM
    public.EV_REV_Event_Revenue c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_REV_EV_ID
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_REV_EV_ID
;
-- ST_NAM_Stage_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_NAM_Stage_Name (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Stage_Name',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_NAM_ST_ID', ST_NAM_ST_ID,
        'ST_NAM_ChangedAt', ST_NAM_ChangedAt
    ),
    COUNT(*)
FROM
    public.ST_NAM_Stage_Name
GROUP BY
    ST_NAM_ST_ID,
    ST_NAM_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name',
    'no row in ST_Stage for ST_NAM_ST_ID',
    OBJECT_CONSTRUCT('ST_NAM_ST_ID', c.ST_NAM_ST_ID),
    COUNT(*)
FROM
    public.ST_NAM_Stage_Name c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_NAM_ST_ID
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_NAM_ST_ID
;
-- ST_LOC_Stage_Location integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_LOC_Stage_Location (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Stage_Location',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_LOC_ST_ID', ST_LOC_ST_ID
    ),
    COUNT(*)
FROM
    public.ST_LOC_Stage_Location
GROUP BY
    ST_LOC_ST_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location',
    'no row in ST_Stage for ST_LOC_ST_ID',
    OBJECT_CONSTRUCT('ST_LOC_ST_ID', c.ST_LOC_ST_ID),
    COUNT(*)
FROM
    public.ST_LOC_Stage_Location c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_LOC_ST_ID
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_LOC_ST_ID
;
-- ST_AVG_Stage_Average integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_AVG_Stage_Average (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Stage_Average',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_AVG_ST_ID', ST_AVG_ST_ID,
        'ST_AVG_ChangedAt', ST_AVG_ChangedAt
    ),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average
GROUP BY
    ST_AVG_ST_ID,
    ST_AVG_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'no row in ST_Stage for ST_AVG_ST_ID',
    OBJECT_CONSTRUCT('ST_AVG_ST_ID', c.ST_AVG_ST_ID),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average c
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
    'ST_AVG_Stage_Average',
    'no row in UTL_Utilization for ST_AVG_UTL_ID',
    OBJECT_CONSTRUCT('ST_AVG_UTL_ID', c.ST_AVG_UTL_ID),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average c
LEFT JOIN
    public.UTL_Utilization p
ON
    p.UTL_ID = c.ST_AVG_UTL_ID
WHERE
    p.UTL_ID IS NULL
GROUP BY
    c.ST_AVG_UTL_ID
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'restatement',
    OBJECT_CONSTRUCT(
        'ST_AVG_ST_ID', ST_AVG_ST_ID,
        'ST_AVG_ChangedAt', ST_AVG_ChangedAt
    ),
    1
FROM (
    SELECT
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID AS compared,
        LAG(ST_AVG_UTL_ID) OVER (
            PARTITION BY
                ST_AVG_ST_ID
            ORDER BY
                ST_AVG_ChangedAt
        ) AS previous
    FROM
        public.ST_AVG_Stage_Average
)
WHERE
    compared = previous
;
-- ST_MIN_Stage_Minimum integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_MIN_Stage_Minimum (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Stage_Minimum',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_MIN_ST_ID', ST_MIN_ST_ID
    ),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum
GROUP BY
    ST_MIN_ST_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum',
    'no row in ST_Stage for ST_MIN_ST_ID',
    OBJECT_CONSTRUCT('ST_MIN_ST_ID', c.ST_MIN_ST_ID),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum c
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
    'ST_MIN_Stage_Minimum',
    'no row in UTL_Utilization for ST_MIN_UTL_ID',
    OBJECT_CONSTRUCT('ST_MIN_UTL_ID', c.ST_MIN_UTL_ID),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum c
LEFT JOIN
    public.UTL_Utilization p
ON
    p.UTL_ID = c.ST_MIN_UTL_ID
WHERE
    p.UTL_ID IS NULL
GROUP BY
    c.ST_MIN_UTL_ID
;
-- AC_NAM_Actor_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_NAM_Actor_Name (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Actor_Name',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_NAM_AC_ID', AC_NAM_AC_ID,
        'AC_NAM_ChangedAt', AC_NAM_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_NAM_Actor_Name
GROUP BY
    AC_NAM_AC_ID,
    AC_NAM_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name',
    'no row in AC_Actor for AC_NAM_AC_ID',
    OBJECT_CONSTRUCT('AC_NAM_AC_ID', c.AC_NAM_AC_ID),
    COUNT(*)
FROM
    public.AC_NAM_Actor_Name c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_NAM_AC_ID
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_NAM_AC_ID
UNION ALL
SELECT
    'AC_NAM_Actor_Name',
    'restatement',
    OBJECT_CONSTRUCT(
        'AC_NAM_AC_ID', AC_NAM_AC_ID,
        'AC_NAM_ChangedAt', AC_NAM_ChangedAt
    ),
    1
FROM (
    SELECT
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name AS compared,
        LAG(AC_NAM_Actor_Name) OVER (
            PARTITION BY
                AC_NAM_AC_ID
            ORDER BY
                AC_NAM_ChangedAt
        ) AS previous
    FROM
        public.AC_NAM_Actor_Name
)
WHERE
    compared = previous
;
-- AC_GEN_Actor_Gender integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_GEN_Actor_Gender (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Actor_Gender',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_GEN_AC_ID', AC_GEN_AC_ID
    ),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender
GROUP BY
    AC_GEN_AC_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender',
    'no row in AC_Actor for AC_GEN_AC_ID',
    OBJECT_CONSTRUCT('AC_GEN_AC_ID', c.AC_GEN_AC_ID),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender c
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
    'AC_GEN_Actor_Gender',
    'no row in GEN_Gender for AC_GEN_GEN_ID',
    OBJECT_CONSTRUCT('AC_GEN_GEN_ID', c.AC_GEN_GEN_ID),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender c
LEFT JOIN
    public.GEN_Gender p
ON
    p.GEN_ID = c.AC_GEN_GEN_ID
WHERE
    p.GEN_ID IS NULL
GROUP BY
    c.AC_GEN_GEN_ID
;
-- AC_PLV_Actor_ProfessionalLevel integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_PLV_Actor_ProfessionalLevel (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_PLV_AC_ID', AC_PLV_AC_ID,
        'AC_PLV_ChangedAt', AC_PLV_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel
GROUP BY
    AC_PLV_AC_ID,
    AC_PLV_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'no row in AC_Actor for AC_PLV_AC_ID',
    OBJECT_CONSTRUCT('AC_PLV_AC_ID', c.AC_PLV_AC_ID),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel c
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
    'AC_PLV_Actor_ProfessionalLevel',
    'no row in PLV_ProfessionalLevel for AC_PLV_PLV_ID',
    OBJECT_CONSTRUCT('AC_PLV_PLV_ID', c.AC_PLV_PLV_ID),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel c
LEFT JOIN
    public.PLV_ProfessionalLevel p
ON
    p.PLV_ID = c.AC_PLV_PLV_ID
WHERE
    p.PLV_ID IS NULL
GROUP BY
    c.AC_PLV_PLV_ID
;
-- PR_NAM_Program_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_NAM_Program_Name (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Program_Name',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_NAM_PR_ID', PR_NAM_PR_ID
    ),
    COUNT(*)
FROM
    public.PR_NAM_Program_Name
GROUP BY
    PR_NAM_PR_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name',
    'no row in PR_Program for PR_NAM_PR_ID',
    OBJECT_CONSTRUCT('PR_NAM_PR_ID', c.PR_NAM_PR_ID),
    COUNT(*)
FROM
    public.PR_NAM_Program_Name c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_NAM_PR_ID
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_NAM_PR_ID
;
-- PR_LEN_Program_Length integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_LEN_Program_Length (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Program_Length',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_LEN_PR_ID', PR_LEN_PR_ID,
        'PR_LEN_ChangedAt', PR_LEN_ChangedAt
    ),
    COUNT(*)
FROM
    public.PR_LEN_Program_Length
GROUP BY
    PR_LEN_PR_ID,
    PR_LEN_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length',
    'no row in PR_Program for PR_LEN_PR_ID',
    OBJECT_CONSTRUCT('PR_LEN_PR_ID', c.PR_LEN_PR_ID),
    COUNT(*)
FROM
    public.PR_LEN_Program_Length c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_LEN_PR_ID
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_LEN_PR_ID
;
-- AC_partner_AC_with_ONG_currently integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_partner_AC_with_ONG_currently (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', AC_ID_partner,
        'AC_ID_with', AC_ID_with,
        'ONG_ID_currently', ONG_ID_currently,
        'AC_partner_AC_with_ONG_currently_ChangedAt', AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently
GROUP BY
    AC_ID_partner,
    AC_ID_with,
    ONG_ID_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate unique key (AC_partner)',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', AC_ID_partner,
        'AC_partner_AC_with_ONG_currently_ChangedAt', AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently
GROUP BY
    AC_ID_partner,
    AC_partner_AC_with_ONG_currently_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate unique key (AC_with)',
    OBJECT_CONSTRUCT(
        'AC_ID_with', AC_ID_with,
        'AC_partner_AC_with_ONG_currently_ChangedAt', AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently
GROUP BY
    AC_ID_with,
    AC_partner_AC_with_ONG_currently_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Actor for AC_ID_partner',
    OBJECT_CONSTRUCT('AC_ID_partner', c.AC_ID_partner),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently c
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
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Actor for AC_ID_with',
    OBJECT_CONSTRUCT('AC_ID_with', c.AC_ID_with),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently c
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
    'AC_partner_AC_with_ONG_currently',
    'no row in ONG_Ongoing for ONG_ID_currently',
    OBJECT_CONSTRUCT('ONG_ID_currently', c.ONG_ID_currently),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently c
LEFT JOIN
    public.ONG_Ongoing p
ON
    p.ONG_ID = c.ONG_ID_currently
WHERE
    p.ONG_ID IS NULL
GROUP BY
    c.ONG_ID_currently
;
-- AC_subset_PN_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_subset_PN_of (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', AC_ID_subset,
        'PN_ID_of', PN_ID_of
    ),
    COUNT(*)
FROM
    public.AC_subset_PN_of
GROUP BY
    AC_ID_subset,
    PN_ID_of
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'duplicate unique key (AC_subset)',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', AC_ID_subset
    ),
    COUNT(*)
FROM
    public.AC_subset_PN_of
GROUP BY
    AC_ID_subset
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'duplicate unique key (PN_of)',
    OBJECT_CONSTRUCT(
        'PN_ID_of', PN_ID_of
    ),
    COUNT(*)
FROM
    public.AC_subset_PN_of
GROUP BY
    PN_ID_of
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'no row in AC_Actor for AC_ID_subset',
    OBJECT_CONSTRUCT('AC_ID_subset', c.AC_ID_subset),
    COUNT(*)
FROM
    public.AC_subset_PN_of c
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
    'AC_subset_PN_of',
    'no row in PN_Person for PN_ID_of',
    OBJECT_CONSTRUCT('PN_ID_of', c.PN_ID_of),
    COUNT(*)
FROM
    public.AC_subset_PN_of c
LEFT JOIN
    public.PN_Person p
ON
    p.PN_ID = c.PN_ID_of
WHERE
    p.PN_ID IS NULL
GROUP BY
    c.PN_ID_of
;
-- EV_in_AC_wasCast integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_in_AC_wasCast (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_wasCast',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_ID_in', EV_ID_in,
        'AC_ID_wasCast', AC_ID_wasCast
    ),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast
GROUP BY
    EV_ID_in,
    AC_ID_wasCast
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast',
    'no row in EV_Event for EV_ID_in',
    OBJECT_CONSTRUCT('EV_ID_in', c.EV_ID_in),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast c
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
    'EV_in_AC_wasCast',
    'no row in AC_Actor for AC_ID_wasCast',
    OBJECT_CONSTRUCT('AC_ID_wasCast', c.AC_ID_wasCast),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_wasCast
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_wasCast
;
-- AC_part_PR_in_RAT_got integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_part_PR_in_RAT_got (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_part_PR_in_RAT_got',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_part', AC_ID_part,
        'PR_ID_in', PR_ID_in,
        'AC_part_PR_in_RAT_got_ChangedAt', AC_part_PR_in_RAT_got_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got
GROUP BY
    AC_ID_part,
    PR_ID_in,
    AC_part_PR_in_RAT_got_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got',
    'no row in AC_Actor for AC_ID_part',
    OBJECT_CONSTRUCT('AC_ID_part', c.AC_ID_part),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got c
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
    'AC_part_PR_in_RAT_got',
    'no row in PR_Program for PR_ID_in',
    OBJECT_CONSTRUCT('PR_ID_in', c.PR_ID_in),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got c
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
    'AC_part_PR_in_RAT_got',
    'no row in RAT_Rating for RAT_ID_got',
    OBJECT_CONSTRUCT('RAT_ID_got', c.RAT_ID_got),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got c
LEFT JOIN
    public.RAT_Rating p
ON
    p.RAT_ID = c.RAT_ID_got
WHERE
    p.RAT_ID IS NULL
GROUP BY
    c.RAT_ID_got
;
-- ST_at_PR_isPlaying integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_at_PR_isPlaying (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_isPlaying',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_ID_at', ST_ID_at,
        'PR_ID_isPlaying', PR_ID_isPlaying,
        'ST_at_PR_isPlaying_ChangedAt', ST_at_PR_isPlaying_ChangedAt
    ),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying
GROUP BY
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying',
    'no row in ST_Stage for ST_ID_at',
    OBJECT_CONSTRUCT('ST_ID_at', c.ST_ID_at),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying c
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
    'ST_at_PR_isPlaying',
    'no row in PR_Program for PR_ID_isPlaying',
    OBJECT_CONSTRUCT('PR_ID_isPlaying', c.PR_ID_isPlaying),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_ID_isPlaying
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_ID_isPlaying
;
-- AC_parent_AC_child_PAT_having integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_parent_AC_child_PAT_having (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_parent_AC_child_PAT_having',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_parent', AC_ID_parent,
        'AC_ID_child', AC_ID_child,
        'PAT_ID_having', PAT_ID_having
    ),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having
GROUP BY
    AC_ID_parent,
    AC_ID_child,
    PAT_ID_having
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having',
    'no row in AC_Actor for AC_ID_parent',
    OBJECT_CONSTRUCT('AC_ID_parent', c.AC_ID_parent),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having c
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
    'AC_parent_AC_child_PAT_having',
    'no row in AC_Actor for AC_ID_child',
    OBJECT_CONSTRUCT('AC_ID_child', c.AC_ID_child),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having c
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
    'AC_parent_AC_child_PAT_having',
    'no row in PAT_ParentalType for PAT_ID_having',
    OBJECT_CONSTRUCT('PAT_ID_having', c.PAT_ID_having),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having c
LEFT JOIN
    public.PAT_ParentalType p
ON
    p.PAT_ID = c.PAT_ID_having
WHERE
    p.PAT_ID IS NULL
GROUP BY
    c.PAT_ID_having
;
-- PR_content_ST_location_EV_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_content_ST_location_EV_of (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_content_ST_location_EV_of',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_ID_of', EV_ID_of
    ),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of
GROUP BY
    EV_ID_of
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'no row in PR_Program for PR_ID_content',
    OBJECT_CONSTRUCT('PR_ID_content', c.PR_ID_content),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of c
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
    'PR_content_ST_location_EV_of',
    'no row in ST_Stage for ST_ID_location',
    OBJECT_CONSTRUCT('ST_ID_location', c.ST_ID_location),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of c
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
    'PR_content_ST_location_EV_of',
    'no row in EV_Event for EV_ID_of',
    OBJECT_CONSTRUCT('EV_ID_of', c.EV_ID_of),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_ID_of
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_ID_of
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
UNION ALL SELECT * FROM public.ic_EV_DAT_Event_Date
UNION ALL SELECT * FROM public.ic_EV_AUD_Event_Audience
UNION ALL SELECT * FROM public.ic_EV_REV_Event_Revenue
UNION ALL SELECT * FROM public.ic_ST_NAM_Stage_Name
UNION ALL SELECT * FROM public.ic_ST_LOC_Stage_Location
UNION ALL SELECT * FROM public.ic_ST_AVG_Stage_Average
UNION ALL SELECT * FROM public.ic_ST_MIN_Stage_Minimum
UNION ALL SELECT * FROM public.ic_AC_NAM_Actor_Name
UNION ALL SELECT * FROM public.ic_AC_GEN_Actor_Gender
UNION ALL SELECT * FROM public.ic_AC_PLV_Actor_ProfessionalLevel
UNION ALL SELECT * FROM public.ic_PR_NAM_Program_Name
UNION ALL SELECT * FROM public.ic_PR_LEN_Program_Length
UNION ALL SELECT * FROM public.ic_AC_partner_AC_with_ONG_currently
UNION ALL SELECT * FROM public.ic_AC_subset_PN_of
UNION ALL SELECT * FROM public.ic_EV_in_AC_wasCast
UNION ALL SELECT * FROM public.ic_AC_part_PR_in_RAT_got
UNION ALL SELECT * FROM public.ic_ST_at_PR_isPlaying
UNION ALL SELECT * FROM public.ic_AC_parent_AC_child_PAT_having
UNION ALL SELECT * FROM public.ic_PR_content_ST_location_EV_of
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers. Views get their comments when they are
-- created, since Snowflake does not allow comments on view columns to be added afterwards.
--
