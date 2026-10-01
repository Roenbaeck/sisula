-- EQUIVALENTS METADATA -----------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available equivalents. Since at least one equivalent
-- must be available the table is set up with a default equivalent with identity 0.
--
-- Equivalent table ---------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public._EQ (
    EQ tinyint not null,
    constraint pk_EQ primary key (
        EQ 
    )
);
MERGE INTO public._EQ e
USING ( SELECT 0 AS _defaultEquivalent ) d
ON (
    d._defaultEquivalent = e.EQ
)
WHEN NOT MATCHED THEN
INSERT (
    EQ
)
VALUES (
    d._defaultEquivalent
);
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
--
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PAT_ParentalType_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.PAT_ParentalType_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PAT_ParentalType_ID (
    PAT_ID tinyint default public.PAT_ParentalType_ID_SEQ.nextval not null, 
     bit null,
    constraint pkPAT_ParentalType_ID primary key (
        PAT_ID
    )
) CLUSTER BY (PAT_ID);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_ParentalType_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PAT_ParentalType_EQ (
    PAT_ID tinyint not null,
    PAT_EQ tinyint not null,
    PAT_ParentalType varchar(42) not null,
     bit null,
    constraint fkPAT_ParentalType_EQ foreign key (
        PAT_ID
    ) references public.PAT_ParentalType_ID(PAT_ID),
    constraint pkPAT_ParentalType_EQ primary key (
        PAT_EQ,
        PAT_ID
    ),
    constraint uqPAT_ParentalType_EQ unique (
        PAT_EQ,
        PAT_ParentalType
    )
) CLUSTER BY (PAT_ID);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- GEN_Gender_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.GEN_Gender_ID (
    GEN_ID number(1,0) not null,
     bit null,
    constraint pkGEN_Gender_ID primary key (
        GEN_ID
    )
) CLUSTER BY (GEN_ID);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- GEN_Gender_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.GEN_Gender_EQ (
    GEN_ID number(1,0) not null,
    GEN_EQ tinyint not null,
    GEN_Gender varchar(42) not null,
     bit null,
    constraint fkGEN_Gender_EQ foreign key (
        GEN_ID
    ) references public.GEN_Gender_ID(GEN_ID),
    constraint pkGEN_Gender_EQ primary key (
        GEN_EQ,
        GEN_ID
    ),
    constraint uqGEN_Gender_EQ unique (
        GEN_EQ,
        GEN_Gender
    )
) CLUSTER BY (GEN_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PLV_ProfessionalLevel (
    PLV_ID tinyint not null,
    PLV_ProfessionalLevel string not null,
    PLV_Checksum numeric(19,0) default hash(PLV_ProfessionalLevel),
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
    UTL_ID tinyint not null,
    UTL_Utilization tinyint not null,
    constraint pkUTL_Utilization primary key (
        UTL_ID
    ),
    constraint uqUTL_Utilization unique (
        UTL_Utilization
    )
) CLUSTER BY (UTL_ID);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ONG_Ongoing_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ONG_Ongoing_ID (
    ONG_ID tinyint not null,
     bit null,
    constraint pkONG_Ongoing_ID primary key (
        ONG_ID
    )
) CLUSTER BY (ONG_ID);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Ongoing_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ONG_Ongoing_EQ (
    ONG_ID tinyint not null,
    ONG_EQ tinyint not null,
    ONG_Ongoing varchar(3) not null,
     bit null,
    constraint fkONG_Ongoing_EQ foreign key (
        ONG_ID
    ) references public.ONG_Ongoing_ID(ONG_ID),
    constraint pkONG_Ongoing_EQ primary key (
        ONG_EQ,
        ONG_ID
    ),
    constraint uqONG_Ongoing_EQ unique (
        ONG_EQ,
        ONG_Ongoing
    )
) CLUSTER BY (ONG_ID);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- RAT_Rating_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.RAT_Rating_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.RAT_Rating_ID (
    RAT_ID tinyint default public.RAT_Rating_ID_SEQ.nextval not null, 
     bit null,
    constraint pkRAT_Rating_ID primary key (
        RAT_ID
    )
) CLUSTER BY (RAT_ID);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Rating_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.RAT_Rating_EQ (
    RAT_ID tinyint not null,
    RAT_EQ tinyint not null,
    RAT_Rating varchar(42) not null,
     bit null,
    constraint fkRAT_Rating_EQ foreign key (
        RAT_ID
    ) references public.RAT_Rating_ID(RAT_ID),
    constraint pkRAT_Rating_EQ primary key (
        RAT_EQ,
        RAT_ID
    ),
    constraint uqRAT_Rating_EQ unique (
        RAT_EQ,
        RAT_Rating
    )
) CLUSTER BY (RAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ETY_EventType (
    ETY_ID tinyint not null,
    ETY_EventType varchar(42) not null,
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
CREATE SEQUENCE IF NOT EXISTS public.PN_Person_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PN_Person (
    PN_ID int default public.PN_Person_ID_SEQ.nextval not null, 
    constraint pkPN_Person primary key (
        PN_ID
    )
) CLUSTER BY (PN_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.ST_Stage_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.ST_Stage (
    ST_ID int default public.ST_Stage_ID_SEQ.nextval not null, 
    constraint pkST_Stage primary key (
        ST_ID
    )
) CLUSTER BY (ST_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.AC_Actor_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.AC_Actor (
    AC_ID int default public.AC_Actor_ID_SEQ.nextval not null, 
    constraint pkAC_Actor primary key (
        AC_ID
    )
) CLUSTER BY (AC_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public.PR_Program_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public.PR_Program (
    PR_ID int default public.PR_Program_ID_SEQ.nextval not null, 
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
    EV_ID int IDENTITY(1,1) not null, 
    ST_ID_wasHeldAt int not null, 
    PR_ID_wasPlayed int not null, 
    ETY_ID_of tinyint not null,
    constraint EV_Event_fkST_wasHeldAt foreign key (
        ST_ID_wasHeldAt
    ) references public.ST_Stage(ST_ID), 
    constraint EV_Event_fkPR_wasPlayed foreign key (
        PR_ID_wasPlayed
    ) references public.PR_Program(PR_ID), 
    constraint EV_Event_fkETY_of foreign key (
        ETY_ID_of
    ) references public.ETY_EventType(ETY_ID),
    EV_Dummy bit null,
    constraint pkEV_Event primary key (
        EV_ID
    )
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
    EV_DAT_EQ tinyint not null,
    EV_DAT_Event_Date datetime not null,
    constraint fkEV_DAT_Event_Date foreign key (
        EV_DAT_EV_ID
    ) references public.EV_Event(EV_ID),
    constraint pkEV_DAT_Event_Date primary key (
        EV_DAT_EQ,
        EV_DAT_EV_ID
    )
) CLUSTER BY (EV_DAT_EV_ID);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_AUD_Event_Audience (
    EV_AUD_EV_ID int not null,
    EV_AUD_Event_Audience int not null,
    constraint fkEV_AUD_Event_Audience foreign key (
        EV_AUD_EV_ID
    ) references public.EV_Event(EV_ID),
    constraint pkEV_AUD_Event_Audience primary key (
        EV_AUD_EV_ID
    )
) CLUSTER BY (EV_AUD_EV_ID);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_REV_Event_Revenue (
    EV_REV_EV_ID int not null,
    EV_REV_EQ tinyint not null,
    EV_REV_Event_Revenue number(19,4) not null,
    constraint fkEV_REV_Event_Revenue foreign key (
        EV_REV_EV_ID
    ) references public.EV_Event(EV_ID),
    constraint pkEV_REV_Event_Revenue primary key (
        EV_REV_EQ,
        EV_REV_EV_ID
    )
) CLUSTER BY (EV_REV_EV_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_NAM_Stage_Name (
    ST_NAM_ST_ID int not null,
    ST_NAM_EQ tinyint not null,
    ST_NAM_Stage_Name varchar(42) not null,
    ST_NAM_Checksum numeric(19,0) default hash(ST_NAM_Stage_Name),
    ST_NAM_ChangedAt datetime not null,
    constraint fkST_NAM_Stage_Name foreign key (
        ST_NAM_ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint pkST_NAM_Stage_Name primary key (
        ST_NAM_EQ,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt
    )
) CLUSTER BY (ST_NAM_ST_ID, ST_NAM_ChangedAt);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_LOC_Stage_Location (
    ST_LOC_ST_ID int not null,
    ST_LOC_EQ tinyint not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum numeric(19,0) default hash(ST_LOC_Stage_Location),
    constraint fkST_LOC_Stage_Location foreign key (
        ST_LOC_ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint pkST_LOC_Stage_Location primary key (
        ST_LOC_EQ,
        ST_LOC_ST_ID
    )
) CLUSTER BY (ST_LOC_ST_ID);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_AVG_Stage_Average (
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime not null,
    constraint fk_A_ST_AVG_Stage_Average foreign key (
        ST_AVG_ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint fk_K_ST_AVG_Stage_Average foreign key (
        ST_AVG_UTL_ID
    ) references public.UTL_Utilization(UTL_ID),
    constraint pkST_AVG_Stage_Average primary key (
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt
    )
) CLUSTER BY (ST_AVG_ST_ID, ST_AVG_ChangedAt);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_MIN_Stage_Minimum (
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    constraint fk_A_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_UTL_ID
    ) references public.UTL_Utilization(UTL_ID),
    constraint pkST_MIN_Stage_Minimum primary key (
        ST_MIN_ST_ID
    )
) CLUSTER BY (ST_MIN_ST_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_NAM_Actor_Name (
    AC_NAM_AC_ID int not null,
    AC_NAM_EQ tinyint not null,
    AC_NAM_Actor_Name varchar(42) not null,
    AC_NAM_Checksum numeric(19,0) default hash(AC_NAM_Actor_Name),
    AC_NAM_ChangedAt datetime not null,
    constraint fkAC_NAM_Actor_Name foreign key (
        AC_NAM_AC_ID
    ) references public.AC_Actor(AC_ID),
    constraint pkAC_NAM_Actor_Name primary key (
        AC_NAM_EQ,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt
    )
) CLUSTER BY (AC_NAM_AC_ID, AC_NAM_ChangedAt);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_GEN_Actor_Gender (
    AC_GEN_AC_ID int not null,
    AC_GEN_GEN_ID number(1,0) not null,
    constraint fk_A_AC_GEN_Actor_Gender foreign key (
        AC_GEN_AC_ID
    ) references public.AC_Actor(AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender foreign key (
        AC_GEN_GEN_ID
    ) references public.GEN_Gender_ID(GEN_ID),
    constraint pkAC_GEN_Actor_Gender primary key (
        AC_GEN_AC_ID
    )
) CLUSTER BY (AC_GEN_AC_ID);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel (
    AC_PLV_AC_ID int not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_AC_ID
    ) references public.AC_Actor(AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_PLV_ID
    ) references public.PLV_ProfessionalLevel(PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel primary key (
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt
    )
) CLUSTER BY (AC_PLV_AC_ID, AC_PLV_ChangedAt);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_NAM_Program_Name (
    PR_NAM_PR_ID int not null,
    PR_NAM_Program_Name varchar(42) not null,
    constraint fkPR_NAM_Program_Name foreign key (
        PR_NAM_PR_ID
    ) references public.PR_Program(PR_ID),
    constraint pkPR_NAM_Program_Name primary key (
        PR_NAM_PR_ID
    )
) CLUSTER BY (PR_NAM_PR_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_LEN_Program_Length (
    PR_LEN_PR_ID int not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length foreign key (
        PR_LEN_PR_ID
    ) references public.PR_Program(PR_ID),
    constraint pkPR_LEN_Program_Length primary key (
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt
    )
) CLUSTER BY (PR_LEN_PR_ID, PR_LEN_ChangedAt);
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
    constraint AC_partner_AC_with_ONG_currently_fkAC_partner foreign key (
        AC_ID_partner
    ) references public.AC_Actor(AC_ID), 
    constraint AC_partner_AC_with_ONG_currently_fkAC_with foreign key (
        AC_ID_with
    ) references public.AC_Actor(AC_ID), 
    constraint AC_partner_AC_with_ONG_currently_fkONG_currently foreign key (
        ONG_ID_currently
    ) references public.ONG_Ongoing_ID(ONG_ID),
    constraint AC_partner_AC_with_ONG_currently_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint AC_partner_AC_with_ONG_currently_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint pkAC_partner_AC_with_ONG_currently primary key (
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt
    )
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
    constraint AC_subset_PN_of_fkAC_subset foreign key (
        AC_ID_subset
    ) references public.AC_Actor(AC_ID), 
    constraint AC_subset_PN_of_fkPN_of foreign key (
        PN_ID_of
    ) references public.PN_Person(PN_ID), 
    constraint AC_subset_PN_of_uqAC_subset unique (
        AC_ID_subset
    ),
    constraint AC_subset_PN_of_uqPN_of unique (
        PN_ID_of
    ),
    constraint pkAC_subset_PN_of primary key (
        AC_ID_subset,
        PN_ID_of
    )
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
    constraint EV_in_AC_wasCast_fkEV_in foreign key (
        EV_ID_in
    ) references public.EV_Event(EV_ID), 
    constraint EV_in_AC_wasCast_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references public.AC_Actor(AC_ID), 
    constraint pkEV_in_AC_wasCast primary key (
        EV_ID_in,
        AC_ID_wasCast
    )
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
    constraint AC_part_PR_in_RAT_got_fkAC_part foreign key (
        AC_ID_part
    ) references public.AC_Actor(AC_ID), 
    constraint AC_part_PR_in_RAT_got_fkPR_in foreign key (
        PR_ID_in
    ) references public.PR_Program(PR_ID), 
    constraint AC_part_PR_in_RAT_got_fkRAT_got foreign key (
        RAT_ID_got
    ) references public.RAT_Rating_ID(RAT_ID),
    constraint pkAC_part_PR_in_RAT_got primary key (
        AC_ID_part,
        PR_ID_in,
        AC_part_PR_in_RAT_got_ChangedAt
    )
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
    constraint ST_at_PR_isPlaying_fkST_at foreign key (
        ST_ID_at
    ) references public.ST_Stage(ST_ID), 
    constraint ST_at_PR_isPlaying_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references public.PR_Program(PR_ID), 
    constraint pkST_at_PR_isPlaying primary key (
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    )
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
    constraint AC_parent_AC_child_PAT_having_fkAC_parent foreign key (
        AC_ID_parent
    ) references public.AC_Actor(AC_ID), 
    constraint AC_parent_AC_child_PAT_having_fkAC_child foreign key (
        AC_ID_child
    ) references public.AC_Actor(AC_ID), 
    constraint AC_parent_AC_child_PAT_having_fkPAT_having foreign key (
        PAT_ID_having
    ) references public.PAT_ParentalType_ID(PAT_ID),
    constraint pkAC_parent_AC_child_PAT_having primary key (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
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
    constraint PR_content_ST_location_EV_of_fkPR_content foreign key (
        PR_ID_content
    ) references public.PR_Program(PR_ID), 
    constraint PR_content_ST_location_EV_of_fkST_location foreign key (
        ST_ID_location
    ) references public.ST_Stage(ST_ID), 
    constraint PR_content_ST_location_EV_of_fkEV_of foreign key (
        EV_ID_of
    ) references public.EV_Event(EV_ID), 
    constraint pkPR_content_ST_location_EV_of primary key (
        EV_ID_of
    )
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
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- PAT_ParentalType view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.PAT_ParentalType (
    PAT_ID,
    PAT_EQ,
    PAT_ParentalType COMMENT 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.'
) COMMENT = 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.'
AS
SELECT
    i.PAT_ID,
    v.PAT_EQ,
    v.PAT_ParentalType
FROM
    public.PAT_ParentalType_ID i
JOIN
    public.PAT_ParentalType_EQ v
ON
    v.PAT_ID = i.PAT_ID
;
CREATE OR REPLACE FUNCTION public.ePAT_ParentalType (
    equivalent tinyint
)
RETURNS TABLE (
    PAT_ID tinyint,
    PAT_EQ tinyint,
    PAT_ParentalType varchar(42)
)
AS
$$
    SELECT
        PAT_ID,
        PAT_EQ,
        PAT_ParentalType
    FROM
        public.PAT_ParentalType
    WHERE
        PAT_EQ = equivalent
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- GEN_Gender view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.GEN_Gender (
    GEN_ID,
    GEN_EQ,
    GEN_Gender COMMENT 'Gender of an actor.'
) COMMENT = 'Gender of an actor.'
AS
SELECT
    i.GEN_ID,
    v.GEN_EQ,
    v.GEN_Gender
FROM
    public.GEN_Gender_ID i
JOIN
    public.GEN_Gender_EQ v
ON
    v.GEN_ID = i.GEN_ID
;
CREATE OR REPLACE FUNCTION public.eGEN_Gender (
    equivalent tinyint
)
RETURNS TABLE (
    GEN_ID number(1,0),
    GEN_EQ tinyint,
    GEN_Gender varchar(42)
)
AS
$$
    SELECT
        GEN_ID,
        GEN_EQ,
        GEN_Gender
    FROM
        public.GEN_Gender
    WHERE
        GEN_EQ = equivalent
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ONG_Ongoing view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ONG_Ongoing (
    ONG_ID,
    ONG_EQ,
    ONG_Ongoing COMMENT 'Yes or No flag indicating whether a relationship is still ongoing or has ended.'
) COMMENT = 'Yes or No flag indicating whether a relationship is still ongoing or has ended.'
AS
SELECT
    i.ONG_ID,
    v.ONG_EQ,
    v.ONG_Ongoing
FROM
    public.ONG_Ongoing_ID i
JOIN
    public.ONG_Ongoing_EQ v
ON
    v.ONG_ID = i.ONG_ID
;
CREATE OR REPLACE FUNCTION public.eONG_Ongoing (
    equivalent tinyint
)
RETURNS TABLE (
    ONG_ID tinyint,
    ONG_EQ tinyint,
    ONG_Ongoing varchar(3)
)
AS
$$
    SELECT
        ONG_ID,
        ONG_EQ,
        ONG_Ongoing
    FROM
        public.ONG_Ongoing
    WHERE
        ONG_EQ = equivalent
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- RAT_Rating view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.RAT_Rating (
    RAT_ID,
    RAT_EQ,
    RAT_Rating COMMENT 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.'
) COMMENT = 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.'
AS
SELECT
    i.RAT_ID,
    v.RAT_EQ,
    v.RAT_Rating
FROM
    public.RAT_Rating_ID i
JOIN
    public.RAT_Rating_EQ v
ON
    v.RAT_ID = i.RAT_ID
;
CREATE OR REPLACE FUNCTION public.eRAT_Rating (
    equivalent tinyint
)
RETURNS TABLE (
    RAT_ID tinyint,
    RAT_EQ tinyint,
    RAT_Rating varchar(42)
)
AS
$$
    SELECT
        RAT_ID,
        RAT_EQ,
        RAT_Rating
    FROM
        public.RAT_Rating
    WHERE
        RAT_EQ = equivalent
$$
;
-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_DAT_Event_Date parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.eEV_DAT_Event_Date (
    equivalent tinyint
)
RETURNS TABLE (
    EV_DAT_EV_ID int,
    EV_DAT_EQ tinyint,
    EV_DAT_Event_Date datetime
)
AS
$$
    SELECT
        EV_DAT_EV_ID,
        EV_DAT_EQ,
        EV_DAT_Event_Date
    FROM
        public.EV_DAT_Event_Date
    WHERE
        EV_DAT_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.eEV_REV_Event_Revenue (
    equivalent tinyint
)
RETURNS TABLE (
    EV_REV_EV_ID int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
    SELECT
        EV_REV_EV_ID,
        EV_REV_EQ,
        EV_REV_Event_Revenue
    FROM
        public.EV_REV_Event_Revenue
    WHERE
        EV_REV_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.eST_NAM_Stage_Name (
    equivalent tinyint
)
RETURNS TABLE (
    ST_NAM_ST_ID int,
    ST_NAM_EQ tinyint,
    ST_NAM_Checksum numeric(19,0),
    ST_NAM_ChangedAt datetime,
    ST_NAM_Stage_Name varchar(42)
)
AS
$$
    SELECT
        ST_NAM_ST_ID,
        ST_NAM_EQ,
        ST_NAM_Checksum,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    FROM
        public.ST_NAM_Stage_Name
    WHERE
        ST_NAM_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.eST_LOC_Stage_Location (
    equivalent tinyint
)
RETURNS TABLE (
    ST_LOC_ST_ID int,
    ST_LOC_EQ tinyint,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography
)
AS
$$
    SELECT
        ST_LOC_ST_ID,
        ST_LOC_EQ,
        ST_LOC_Checksum,
        ST_LOC_Stage_Location
    FROM
        public.ST_LOC_Stage_Location
    WHERE
        ST_LOC_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.eAC_NAM_Actor_Name (
    equivalent tinyint
)
RETURNS TABLE (
    AC_NAM_AC_ID int,
    AC_NAM_EQ tinyint,
    AC_NAM_Checksum numeric(19,0),
    AC_NAM_ChangedAt datetime,
    AC_NAM_Actor_Name varchar(42)
)
AS
$$
    SELECT
        AC_NAM_AC_ID,
        AC_NAM_EQ,
        AC_NAM_Checksum,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    FROM
        public.AC_NAM_Actor_Name
    WHERE
        AC_NAM_EQ = equivalent
$$
;
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
    equivalent tinyint,
    changingTimepoint datetime
)
RETURNS TABLE (
    ST_NAM_ST_ID int,
    ST_NAM_EQ tinyint,
    ST_NAM_Checksum numeric(19,0),
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
    SELECT
        ST_NAM_ST_ID,
        ST_NAM_EQ,
        ST_NAM_Checksum,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        TABLE(public.eST_NAM_Stage_Name(equivalent)) 
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
RETURNS TABLE (
    ST_AVG_ST_ID int,
    ST_AVG_EQ tinyint,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
    SELECT
        ST_AVG_ST_ID,
        ST_AVG_EQ,
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
    equivalent tinyint,
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_NAM_AC_ID int,
    AC_NAM_EQ tinyint,
    AC_NAM_Checksum numeric(19,0),
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
    SELECT
        AC_NAM_AC_ID,
        AC_NAM_EQ,
        AC_NAM_Checksum,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        TABLE(public.eAC_NAM_Actor_Name(equivalent)) 
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
RETURNS TABLE (
    AC_PLV_AC_ID int,
    AC_PLV_EQ tinyint,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
    SELECT
        AC_PLV_AC_ID,
        AC_PLV_EQ,
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
RETURNS TABLE (
    PR_LEN_PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
    SELECT
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
    ST_NAM_ST_ID,
    ST_NAM_ChangedAt,
    ST_NAM_EQ,
    ST_NAM_Checksum,
    ST_NAM_Stage_Name COMMENT 'Name of the stage. Historized, since a stage may be renamed over time.',
    ST_LOC_ST_ID,
    ST_LOC_EQ,
    ST_LOC_Checksum,
    ST_LOC_Stage_Location COMMENT 'Geographic location of the stage as a geography point.',
    ST_AVG_ST_ID,
    ST_AVG_ChangedAt,
    ST_AVG_EQ,
    ST_AVG_UTL_Utilization COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    ST_AVG_UTL_ID COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    ST_MIN_ST_ID,
    ST_MIN_EQ,
    ST_MIN_UTL_Utilization COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.',
    ST_MIN_UTL_ID COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.'
) COMMENT = 'A stage or venue where programs are played and events are held.'
AS
SELECT
    ST.ST_ID,
    NAM.ST_NAM_ST_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_EQ,
    NAM.ST_NAM_Checksum,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.ST_LOC_EQ,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ST_ID,
    AVG.ST_AVG_ChangedAt,
    AVG.ST_AVG_EQ,
    kAVG.UTL_Utilization AS ST_AVG_UTL_Utilization,
    AVG.ST_AVG_UTL_ID,
    MIN.ST_MIN_ST_ID,
    MIN.ST_MIN_EQ,
    kMIN.UTL_Utilization AS ST_MIN_UTL_Utilization,
    MIN.ST_MIN_UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    TABLE(public.eST_NAM_Stage_Name(0)) NAM
ON
    NAM.ST_NAM_ST_ID = ST.ST_ID
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            TABLE(public.eST_NAM_Stage_Name(0)) sub 
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
   )
LEFT JOIN
    TABLE(public.eST_LOC_Stage_Location(0)) LOC
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
RETURNS TABLE (
    ST_ID int,
    ST_NAM_ST_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_EQ tinyint,
    ST_NAM_Checksum numeric(19,0),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    ST_LOC_EQ tinyint,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_EQ tinyint,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    ST_MIN_EQ tinyint,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    ST.ST_ID,
    NAM.ST_NAM_ST_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_EQ,
    NAM.ST_NAM_Checksum,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.ST_LOC_EQ,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ST_ID,
    AVG.ST_AVG_ChangedAt,
    AVG.ST_AVG_EQ,
    kAVG.UTL_Utilization AS ST_AVG_UTL_Utilization,
    AVG.ST_AVG_UTL_ID,
    MIN.ST_MIN_ST_ID,
    MIN.ST_MIN_EQ,
    kMIN.UTL_Utilization AS ST_MIN_UTL_Utilization,
    MIN.ST_MIN_UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    TABLE(public.rST_NAM_Stage_Name(0, changingTimepoint::datetime)) NAM
ON
    NAM.ST_NAM_ST_ID = ST.ST_ID
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            TABLE(public.rST_NAM_Stage_Name(0, changingTimepoint::datetime)) sub
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
   )
LEFT JOIN
    TABLE(public.eST_LOC_Stage_Location(0)) LOC
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
CREATE OR REPLACE VIEW public.nST_Stage
AS
SELECT
    *
FROM
    TABLE(public.pST_Stage(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dST_Stage (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    ST_ID int,
    ST_NAM_ST_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_EQ tinyint,
    ST_NAM_Checksum numeric(19,0),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    ST_LOC_EQ tinyint,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_EQ tinyint,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    ST_MIN_EQ tinyint,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT DISTINCT
    hNAM.ST_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    pST.ST_ID,
    pST.ST_NAM_ST_ID,
    pST.ST_NAM_ChangedAt,
    pST.ST_NAM_EQ,
    pST.ST_NAM_Checksum,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_ST_ID,
    pST.ST_LOC_EQ,
    pST.ST_LOC_Checksum,
    pST.ST_LOC_Stage_Location,
    pST.ST_AVG_ST_ID,
    pST.ST_AVG_ChangedAt,
    pST.ST_AVG_EQ,
    pST.ST_AVG_UTL_Utilization,
    pST.ST_AVG_UTL_ID,
    pST.ST_MIN_ST_ID,
    pST.ST_MIN_EQ,
    pST.ST_MIN_UTL_Utilization,
    pST.ST_MIN_UTL_ID
FROM
    TABLE(public.eST_NAM_Stage_Name(0)) hNAM, 
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
    pST.ST_NAM_ST_ID,
    pST.ST_NAM_ChangedAt,
    pST.ST_NAM_EQ,
    pST.ST_NAM_Checksum,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_ST_ID,
    pST.ST_LOC_EQ,
    pST.ST_LOC_Checksum,
    pST.ST_LOC_Stage_Location,
    pST.ST_AVG_ST_ID,
    pST.ST_AVG_ChangedAt,
    pST.ST_AVG_EQ,
    pST.ST_AVG_UTL_Utilization,
    pST.ST_AVG_UTL_ID,
    pST.ST_MIN_ST_ID,
    pST.ST_MIN_EQ,
    pST.ST_MIN_UTL_Utilization,
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
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elST_Stage (
    equivalent tinyint
)
RETURNS TABLE (
    ST_ID int,
    ST_NAM_ST_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_EQ tinyint,
    ST_NAM_Checksum numeric(19,0),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    ST_LOC_EQ tinyint,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_EQ tinyint,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    ST_MIN_EQ tinyint,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epST_Stage(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epST_Stage (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    ST_ID int,
    ST_NAM_ST_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_EQ tinyint,
    ST_NAM_Checksum numeric(19,0),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    ST_LOC_EQ tinyint,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_EQ tinyint,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    ST_MIN_EQ tinyint,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    ST.ST_ID,
    NAM.ST_NAM_ST_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_EQ,
    NAM.ST_NAM_Checksum,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.ST_LOC_EQ,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ST_ID,
    AVG.ST_AVG_ChangedAt,
    AVG.ST_AVG_EQ,
    kAVG.UTL_Utilization AS ST_AVG_UTL_Utilization,
    AVG.ST_AVG_UTL_ID,
    MIN.ST_MIN_ST_ID,
    MIN.ST_MIN_EQ,
    kMIN.UTL_Utilization AS ST_MIN_UTL_Utilization,
    MIN.ST_MIN_UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    TABLE(public.rST_NAM_Stage_Name(equivalent, changingTimepoint::datetime)) NAM
ON
    NAM.ST_NAM_ST_ID = ST.ST_ID
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            TABLE(public.rST_NAM_Stage_Name(equivalent, changingTimepoint::datetime)) sub
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
   )
LEFT JOIN
    TABLE(public.eST_LOC_Stage_Location(equivalent)) LOC
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
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enST_Stage (
    equivalent tinyint
)
RETURNS TABLE (
    ST_ID int,
    ST_NAM_ST_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_EQ tinyint,
    ST_NAM_Checksum numeric(19,0),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    ST_LOC_EQ tinyint,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_EQ tinyint,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    ST_MIN_EQ tinyint,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epST_Stage(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edST_Stage (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    ST_ID int,
    ST_NAM_ST_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_EQ tinyint,
    ST_NAM_Checksum numeric(19,0),
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    ST_LOC_EQ tinyint,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    ST_AVG_ChangedAt datetime,
    ST_AVG_EQ tinyint,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    ST_MIN_EQ tinyint,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT DISTINCT
    hNAM.ST_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    pST.ST_ID,
    pST.ST_NAM_ST_ID,
    pST.ST_NAM_ChangedAt,
    pST.ST_NAM_EQ,
    pST.ST_NAM_Checksum,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_ST_ID,
    pST.ST_LOC_EQ,
    pST.ST_LOC_Checksum,
    pST.ST_LOC_Stage_Location,
    pST.ST_AVG_ST_ID,
    pST.ST_AVG_ChangedAt,
    pST.ST_AVG_EQ,
    pST.ST_AVG_UTL_Utilization,
    pST.ST_AVG_UTL_ID,
    pST.ST_MIN_ST_ID,
    pST.ST_MIN_EQ,
    pST.ST_MIN_UTL_Utilization,
    pST.ST_MIN_UTL_ID
FROM
    TABLE(public.eST_NAM_Stage_Name(equivalent)) hNAM, 
    TABLE(public.epST_Stage(equivalent, hNAM.ST_NAM_ChangedAt::timestamp_ntz(9))) pST
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
    pST.ST_NAM_ST_ID,
    pST.ST_NAM_ChangedAt,
    pST.ST_NAM_EQ,
    pST.ST_NAM_Checksum,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_ST_ID,
    pST.ST_LOC_EQ,
    pST.ST_LOC_Checksum,
    pST.ST_LOC_Stage_Location,
    pST.ST_AVG_ST_ID,
    pST.ST_AVG_ChangedAt,
    pST.ST_AVG_EQ,
    pST.ST_AVG_UTL_Utilization,
    pST.ST_AVG_UTL_ID,
    pST.ST_MIN_ST_ID,
    pST.ST_MIN_EQ,
    pST.ST_MIN_UTL_Utilization,
    pST.ST_MIN_UTL_ID
FROM
    public.ST_AVG_Stage_Average hAVG,
    TABLE(public.epST_Stage(equivalent, hAVG.ST_AVG_ChangedAt::timestamp_ntz(9))) pST
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
    AC_NAM_AC_ID,
    AC_NAM_ChangedAt,
    AC_NAM_EQ,
    AC_NAM_Checksum,
    AC_NAM_Actor_Name COMMENT 'Name of the actor, such as a stage name. Historized, since it may change over time.',
    AC_GEN_AC_ID,
    AC_GEN_EQ,
    AC_GEN_GEN_EQ,
    AC_GEN_GEN_Gender COMMENT 'Gender of the actor.',
    AC_GEN_GEN_ID COMMENT 'Gender of the actor.',
    AC_PLV_AC_ID,
    AC_PLV_ChangedAt,
    AC_PLV_EQ,
    AC_PLV_PLV_Checksum,
    AC_PLV_PLV_ProfessionalLevel COMMENT 'Professional level of the actor, which may change as the actor gains experience.',
    AC_PLV_PLV_ID COMMENT 'Professional level of the actor, which may change as the actor gains experience.'
) COMMENT = 'An actor, a person who performs parts in programs and is cast in events.'
AS
SELECT
    AC.AC_ID,
    NAM.AC_NAM_AC_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_EQ,
    NAM.AC_NAM_Checksum,
    NAM.AC_NAM_Actor_Name,
    GEN.AC_GEN_AC_ID,
    GEN.AC_GEN_EQ,
    kGEN.GEN_EQ AS AC_GEN_GEN_EQ,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.AC_PLV_ChangedAt,
    PLV.AC_PLV_EQ,
    kPLV.PLV_Checksum AS AC_PLV_PLV_Checksum,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    PLV.AC_PLV_PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    TABLE(public.eAC_NAM_Actor_Name(0)) NAM
ON
    NAM.AC_NAM_AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            TABLE(public.eAC_NAM_Actor_Name(0)) sub 
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_GEN_AC_ID = AC.AC_ID
LEFT JOIN
    TABLE(public.eGEN_Gender(0)) kGEN
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
RETURNS TABLE (
    AC_ID int,
    AC_NAM_AC_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_EQ tinyint,
    AC_NAM_Checksum numeric(19,0),
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    AC_GEN_EQ tinyint,
    AC_GEN_GEN_EQ tinyint,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_EQ tinyint,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    AC.AC_ID,
    NAM.AC_NAM_AC_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_EQ,
    NAM.AC_NAM_Checksum,
    NAM.AC_NAM_Actor_Name,
    GEN.AC_GEN_AC_ID,
    GEN.AC_GEN_EQ,
    kGEN.GEN_EQ AS AC_GEN_GEN_EQ,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.AC_PLV_ChangedAt,
    PLV.AC_PLV_EQ,
    kPLV.PLV_Checksum AS AC_PLV_PLV_Checksum,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    PLV.AC_PLV_PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    TABLE(public.rAC_NAM_Actor_Name(0, changingTimepoint::datetime)) NAM
ON
    NAM.AC_NAM_AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            TABLE(public.rAC_NAM_Actor_Name(0, changingTimepoint::datetime)) sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_GEN_AC_ID = AC.AC_ID
LEFT JOIN
    TABLE(public.eGEN_Gender(0)) kGEN
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
CREATE OR REPLACE VIEW public.nAC_Actor
AS
SELECT
    *
FROM
    TABLE(public.pAC_Actor(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_Actor (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    AC_ID int,
    AC_NAM_AC_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_EQ tinyint,
    AC_NAM_Checksum numeric(19,0),
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    AC_GEN_EQ tinyint,
    AC_GEN_GEN_EQ tinyint,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_EQ tinyint,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT DISTINCT
    hNAM.AC_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    pAC.AC_ID,
    pAC.AC_NAM_AC_ID,
    pAC.AC_NAM_ChangedAt,
    pAC.AC_NAM_EQ,
    pAC.AC_NAM_Checksum,
    pAC.AC_NAM_Actor_Name,
    pAC.AC_GEN_AC_ID,
    pAC.AC_GEN_EQ,
    pAC.AC_GEN_GEN_EQ,
    pAC.AC_GEN_GEN_Gender,
    pAC.AC_GEN_GEN_ID,
    pAC.AC_PLV_AC_ID,
    pAC.AC_PLV_ChangedAt,
    pAC.AC_PLV_EQ,
    pAC.AC_PLV_PLV_Checksum,
    pAC.AC_PLV_PLV_ProfessionalLevel,
    pAC.AC_PLV_PLV_ID
FROM
    TABLE(public.eAC_NAM_Actor_Name(0)) hNAM, 
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
    pAC.AC_NAM_AC_ID,
    pAC.AC_NAM_ChangedAt,
    pAC.AC_NAM_EQ,
    pAC.AC_NAM_Checksum,
    pAC.AC_NAM_Actor_Name,
    pAC.AC_GEN_AC_ID,
    pAC.AC_GEN_EQ,
    pAC.AC_GEN_GEN_EQ,
    pAC.AC_GEN_GEN_Gender,
    pAC.AC_GEN_GEN_ID,
    pAC.AC_PLV_AC_ID,
    pAC.AC_PLV_ChangedAt,
    pAC.AC_PLV_EQ,
    pAC.AC_PLV_PLV_Checksum,
    pAC.AC_PLV_PLV_ProfessionalLevel,
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
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elAC_Actor (
    equivalent tinyint
)
RETURNS TABLE (
    AC_ID int,
    AC_NAM_AC_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_EQ tinyint,
    AC_NAM_Checksum numeric(19,0),
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    AC_GEN_EQ tinyint,
    AC_GEN_GEN_EQ tinyint,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_EQ tinyint,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epAC_Actor(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epAC_Actor (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    AC_ID int,
    AC_NAM_AC_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_EQ tinyint,
    AC_NAM_Checksum numeric(19,0),
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    AC_GEN_EQ tinyint,
    AC_GEN_GEN_EQ tinyint,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_EQ tinyint,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    AC.AC_ID,
    NAM.AC_NAM_AC_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_EQ,
    NAM.AC_NAM_Checksum,
    NAM.AC_NAM_Actor_Name,
    GEN.AC_GEN_AC_ID,
    GEN.AC_GEN_EQ,
    kGEN.GEN_EQ AS AC_GEN_GEN_EQ,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.AC_PLV_ChangedAt,
    PLV.AC_PLV_EQ,
    kPLV.PLV_Checksum AS AC_PLV_PLV_Checksum,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    PLV.AC_PLV_PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    TABLE(public.rAC_NAM_Actor_Name(equivalent, changingTimepoint::datetime)) NAM
ON
    NAM.AC_NAM_AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            TABLE(public.rAC_NAM_Actor_Name(equivalent, changingTimepoint::datetime)) sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_GEN_AC_ID = AC.AC_ID
LEFT JOIN
    TABLE(public.eGEN_Gender(equivalent)) kGEN
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
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enAC_Actor (
    equivalent tinyint
)
RETURNS TABLE (
    AC_ID int,
    AC_NAM_AC_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_EQ tinyint,
    AC_NAM_Checksum numeric(19,0),
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    AC_GEN_EQ tinyint,
    AC_GEN_GEN_EQ tinyint,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_EQ tinyint,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epAC_Actor(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edAC_Actor (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    AC_ID int,
    AC_NAM_AC_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_EQ tinyint,
    AC_NAM_Checksum numeric(19,0),
    AC_NAM_Actor_Name varchar(42),
    AC_GEN_AC_ID int,
    AC_GEN_EQ tinyint,
    AC_GEN_GEN_EQ tinyint,
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_EQ tinyint,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT DISTINCT
    hNAM.AC_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    pAC.AC_ID,
    pAC.AC_NAM_AC_ID,
    pAC.AC_NAM_ChangedAt,
    pAC.AC_NAM_EQ,
    pAC.AC_NAM_Checksum,
    pAC.AC_NAM_Actor_Name,
    pAC.AC_GEN_AC_ID,
    pAC.AC_GEN_EQ,
    pAC.AC_GEN_GEN_EQ,
    pAC.AC_GEN_GEN_Gender,
    pAC.AC_GEN_GEN_ID,
    pAC.AC_PLV_AC_ID,
    pAC.AC_PLV_ChangedAt,
    pAC.AC_PLV_EQ,
    pAC.AC_PLV_PLV_Checksum,
    pAC.AC_PLV_PLV_ProfessionalLevel,
    pAC.AC_PLV_PLV_ID
FROM
    TABLE(public.eAC_NAM_Actor_Name(equivalent)) hNAM, 
    TABLE(public.epAC_Actor(equivalent, hNAM.AC_NAM_ChangedAt::timestamp_ntz(9))) pAC
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
    pAC.AC_NAM_AC_ID,
    pAC.AC_NAM_ChangedAt,
    pAC.AC_NAM_EQ,
    pAC.AC_NAM_Checksum,
    pAC.AC_NAM_Actor_Name,
    pAC.AC_GEN_AC_ID,
    pAC.AC_GEN_EQ,
    pAC.AC_GEN_GEN_EQ,
    pAC.AC_GEN_GEN_Gender,
    pAC.AC_GEN_GEN_ID,
    pAC.AC_PLV_AC_ID,
    pAC.AC_PLV_ChangedAt,
    pAC.AC_PLV_EQ,
    pAC.AC_PLV_PLV_Checksum,
    pAC.AC_PLV_PLV_ProfessionalLevel,
    pAC.AC_PLV_PLV_ID
FROM
    public.AC_PLV_Actor_ProfessionalLevel hPLV,
    TABLE(public.epAC_Actor(equivalent, hPLV.AC_PLV_ChangedAt::timestamp_ntz(9))) pAC
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
    PR_NAM_PR_ID,
    PR_NAM_Program_Name COMMENT 'Name or title of the program.',
    PR_LEN_PR_ID,
    PR_LEN_ChangedAt,
    PR_LEN_Program_Length COMMENT 'Running time of the program. Historized, since the program may be shortened or extended over time.'
) COMMENT = 'A program, such as a play, show or concert, that can be played on stages.'
AS
SELECT
    PR.PR_ID,
    NAM.PR_NAM_PR_ID,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_PR_ID,
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
RETURNS TABLE (
    PR_ID int,
    PR_NAM_PR_ID int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    PR.PR_ID,
    NAM.PR_NAM_PR_ID,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_PR_ID,
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
CREATE OR REPLACE VIEW public.nPR_Program
AS
SELECT
    *
FROM
    TABLE(public.pPR_Program(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dPR_Program (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    PR_ID int,
    PR_NAM_PR_ID int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT DISTINCT
    hLEN.PR_LEN_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'LEN' AS mnemonic,
    pPR.PR_ID,
    pPR.PR_NAM_PR_ID,
    pPR.PR_NAM_Program_Name,
    pPR.PR_LEN_PR_ID,
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
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elPR_Program (
    equivalent tinyint
)
RETURNS TABLE (
    PR_ID int,
    PR_NAM_PR_ID int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epPR_Program(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epPR_Program (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    PR_ID int,
    PR_NAM_PR_ID int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    PR.PR_ID,
    NAM.PR_NAM_PR_ID,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_PR_ID,
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
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enPR_Program (
    equivalent tinyint
)
RETURNS TABLE (
    PR_ID int,
    PR_NAM_PR_ID int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epPR_Program(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edPR_Program (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    PR_ID int,
    PR_NAM_PR_ID int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID int,
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT DISTINCT
    hLEN.PR_LEN_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'LEN' AS mnemonic,
    pPR.PR_ID,
    pPR.PR_NAM_PR_ID,
    pPR.PR_NAM_Program_Name,
    pPR.PR_LEN_PR_ID,
    pPR.PR_LEN_ChangedAt,
    pPR.PR_LEN_Program_Length
FROM
    public.PR_LEN_Program_Length hLEN,
    TABLE(public.epPR_Program(equivalent, hLEN.PR_LEN_ChangedAt::timestamp_ntz(9))) pPR
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
    ST_ID_wasHeldAt COMMENT 'The stage at which the event was held.',
    PR_ID_wasPlayed COMMENT 'The program that was played at the event.',
    of_ETY_EventType COMMENT 'The type of the event.',
    ETY_ID_of COMMENT 'The type of the event.',
    EV_DAT_EV_ID,
    EV_DAT_EQ,
    EV_DAT_Event_Date COMMENT 'Date and time when the event took place.',
    EV_AUD_EV_ID,
    EV_AUD_Event_Audience COMMENT 'Number of people in the audience at the event.',
    EV_REV_EV_ID,
    EV_REV_EQ,
    EV_REV_Event_Revenue COMMENT 'Revenue from ticket sales for the event.'
) COMMENT = 'An event, a single performance of a program held at a stage at a specific date and time.'
AS
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.EV_DAT_EQ,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.eEV_DAT_Event_Date(0)) DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(public.eEV_REV_Event_Revenue(0)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    EV_DAT_EQ tinyint,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.EV_DAT_EQ,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.eEV_DAT_Event_Date(0)) DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(public.eEV_REV_Event_Revenue(0)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nEV_Event AS
SELECT
    *
FROM
    TABLE(public.pEV_Event(current_timestamp()::timestamp_ntz(9)))
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elEV_Event (
    equivalent tinyint
)
RETURNS TABLE (
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    EV_DAT_EQ tinyint,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.EV_DAT_EQ,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.eEV_DAT_Event_Date(equivalent)) DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(public.eEV_REV_Event_Revenue(equivalent)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epEV_Event (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    EV_DAT_EQ tinyint,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.EV_DAT_EQ,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.eEV_DAT_Event_Date(equivalent)) DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(public.eEV_REV_Event_Revenue(equivalent)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enEV_Event (
    equivalent tinyint
)
RETURNS TABLE (
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    EV_DAT_EQ tinyint,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epEV_Event(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_partner_AC_with_ONG_currently (
    AC_partner_AC_with_ONG_currently_ChangedAt,
    AC_ID_partner COMMENT 'One of the actors in the partnership.',
    AC_ID_with COMMENT 'The other actor in the partnership.',
    currently_ONG_Ongoing COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).',
    currently_ONG_EQ,
    ONG_ID_currently COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).'
) COMMENT = 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.'
AS
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    TABLE(public.eONG_Ongoing(0)) ONG_currently
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
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_ONG_EQ tinyint,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    TABLE(public.eONG_Ongoing(0)) ONG_currently
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
CREATE OR REPLACE VIEW public.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    TABLE(public.pAC_partner_AC_with_ONG_currently(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_ONG_EQ tinyint,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    TABLE(public.eONG_Ongoing(0)) ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elAC_partner_AC_with_ONG_currently (
    equivalent tinyint
)
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_ONG_EQ tinyint,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epAC_partner_AC_with_ONG_currently(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epAC_partner_AC_with_ONG_currently (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_ONG_EQ tinyint,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    TABLE(public.eONG_Ongoing(equivalent)) ONG_currently
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
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enAC_partner_AC_with_ONG_currently (
    equivalent tinyint
)
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_ONG_EQ tinyint,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epAC_partner_AC_with_ONG_currently(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edAC_partner_AC_with_ONG_currently (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_ONG_EQ tinyint,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    TABLE(public.eONG_Ongoing(equivalent)) ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_subset_PN_of (
    AC_ID_subset COMMENT 'The actor.',
    PN_ID_of COMMENT 'The person who is the actor.'
) COMMENT = 'Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.'
AS
SELECT
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
RETURNS TABLE (
    AC_ID_subset int,
    PN_ID_of int
)
AS
$$
SELECT
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    public.AC_subset_PN_of tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_subset_PN_of AS
SELECT
    *
FROM
    TABLE(public.pAC_subset_PN_of(current_timestamp()::timestamp_ntz(9)))
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elAC_subset_PN_of (
    equivalent tinyint
)
RETURNS TABLE (
    AC_ID_subset int,
    PN_ID_of int
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epAC_subset_PN_of(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epAC_subset_PN_of (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    AC_ID_subset int,
    PN_ID_of int
)
AS
$$
SELECT
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    public.AC_subset_PN_of tie
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enAC_subset_PN_of (
    equivalent tinyint
)
RETURNS TABLE (
    AC_ID_subset int,
    PN_ID_of int
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epAC_subset_PN_of(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lEV_in_AC_wasCast (
    EV_ID_in COMMENT 'The event the actor was cast in.',
    AC_ID_wasCast COMMENT 'An actor cast in the event.'
) COMMENT = 'The actors that were cast in an event, meaning those who performed at that performance.'
AS
SELECT
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
RETURNS TABLE (
    EV_ID_in int,
    AC_ID_wasCast int
)
AS
$$
SELECT
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    public.EV_in_AC_wasCast tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nEV_in_AC_wasCast AS
SELECT
    *
FROM
    TABLE(public.pEV_in_AC_wasCast(current_timestamp()::timestamp_ntz(9)))
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elEV_in_AC_wasCast (
    equivalent tinyint
)
RETURNS TABLE (
    EV_ID_in int,
    AC_ID_wasCast int
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epEV_in_AC_wasCast(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epEV_in_AC_wasCast (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    EV_ID_in int,
    AC_ID_wasCast int
)
AS
$$
SELECT
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    public.EV_in_AC_wasCast tie
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enEV_in_AC_wasCast (
    equivalent tinyint
)
RETURNS TABLE (
    EV_ID_in int,
    AC_ID_wasCast int
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epEV_in_AC_wasCast(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got (
    AC_part_PR_in_RAT_got_ChangedAt,
    AC_ID_part COMMENT 'The actor having a part in the program.',
    PR_ID_in COMMENT 'The program the actor has a part in.',
    got_RAT_Rating COMMENT 'The rating the actor got for the part.',
    got_RAT_EQ,
    RAT_ID_got COMMENT 'The rating the actor got for the part.'
) COMMENT = 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.'
AS
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    TABLE(public.eRAT_Rating(0)) RAT_got
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
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_RAT_EQ tinyint,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    TABLE(public.eRAT_Rating(0)) RAT_got
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
CREATE OR REPLACE VIEW public.nAC_part_PR_in_RAT_got AS
SELECT
    *
FROM
    TABLE(public.pAC_part_PR_in_RAT_got(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_RAT_EQ tinyint,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    TABLE(public.eRAT_Rating(0)) RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elAC_part_PR_in_RAT_got (
    equivalent tinyint
)
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_RAT_EQ tinyint,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epAC_part_PR_in_RAT_got(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epAC_part_PR_in_RAT_got (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_RAT_EQ tinyint,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    TABLE(public.eRAT_Rating(equivalent)) RAT_got
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
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enAC_part_PR_in_RAT_got (
    equivalent tinyint
)
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_RAT_EQ tinyint,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epAC_part_PR_in_RAT_got(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edAC_part_PR_in_RAT_got (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_RAT_EQ tinyint,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    TABLE(public.eRAT_Rating(equivalent)) RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lST_at_PR_isPlaying (
    ST_at_PR_isPlaying_ChangedAt,
    ST_ID_at COMMENT 'The stage where the program is playing.',
    PR_ID_isPlaying COMMENT 'The program playing at the stage.'
) COMMENT = 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.'
AS
SELECT
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
RETURNS TABLE (
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
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
CREATE OR REPLACE VIEW public.nST_at_PR_isPlaying AS
SELECT
    *
FROM
    TABLE(public.pST_at_PR_isPlaying(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    public.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elST_at_PR_isPlaying (
    equivalent tinyint
)
RETURNS TABLE (
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epST_at_PR_isPlaying(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epST_at_PR_isPlaying (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
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
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enST_at_PR_isPlaying (
    equivalent tinyint
)
RETURNS TABLE (
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epST_at_PR_isPlaying(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edST_at_PR_isPlaying (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
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
    AC_ID_parent COMMENT 'The actor who is the parent.',
    AC_ID_child COMMENT 'The actor who is the child.',
    having_PAT_ParentalType COMMENT 'The type of parental relationship.',
    having_PAT_EQ,
    PAT_ID_having COMMENT 'The type of parental relationship.'
) COMMENT = 'Parent-child relationships between actors, along with the type of parental relationship.'
AS
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    PAT_having.PAT_EQ AS having_PAT_EQ,
    tie.PAT_ID_having
FROM
    public.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    TABLE(public.ePAT_ParentalType(0)) PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    AC_ID_parent int,
    AC_ID_child int,
    having_PAT_ParentalType varchar(42),
    having_PAT_EQ tinyint,
    PAT_ID_having tinyint
)
AS
$$
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    PAT_having.PAT_EQ AS having_PAT_EQ,
    tie.PAT_ID_having
FROM
    public.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    TABLE(public.ePAT_ParentalType(0)) PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having AS
SELECT
    *
FROM
    TABLE(public.pAC_parent_AC_child_PAT_having(current_timestamp()::timestamp_ntz(9)))
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elAC_parent_AC_child_PAT_having (
    equivalent tinyint
)
RETURNS TABLE (
    AC_ID_parent int,
    AC_ID_child int,
    having_PAT_ParentalType varchar(42),
    having_PAT_EQ tinyint,
    PAT_ID_having tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epAC_parent_AC_child_PAT_having(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epAC_parent_AC_child_PAT_having (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    AC_ID_parent int,
    AC_ID_child int,
    having_PAT_ParentalType varchar(42),
    having_PAT_EQ tinyint,
    PAT_ID_having tinyint
)
AS
$$
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    PAT_having.PAT_EQ AS having_PAT_EQ,
    tie.PAT_ID_having
FROM
    public.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    TABLE(public.ePAT_ParentalType(equivalent)) PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enAC_parent_AC_child_PAT_having (
    equivalent tinyint
)
RETURNS TABLE (
    AC_ID_parent int,
    AC_ID_child int,
    having_PAT_ParentalType varchar(42),
    having_PAT_EQ tinyint,
    PAT_ID_having tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epAC_parent_AC_child_PAT_having(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lPR_content_ST_location_EV_of (
    PR_ID_content COMMENT 'The program that made up the content of the event.',
    ST_ID_location COMMENT 'The stage where the event was located.',
    EV_ID_of COMMENT 'The event.'
) COMMENT = 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.'
AS
SELECT
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
RETURNS TABLE (
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
)
AS
$$
SELECT
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    public.PR_content_ST_location_EV_of tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nPR_content_ST_location_EV_of AS
SELECT
    *
FROM
    TABLE(public.pPR_content_ST_location_EV_of(current_timestamp()::timestamp_ntz(9)))
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elPR_content_ST_location_EV_of (
    equivalent tinyint
)
RETURNS TABLE (
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epPR_content_ST_location_EV_of(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epPR_content_ST_location_EV_of (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
)
AS
$$
SELECT
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    public.PR_content_ST_location_EV_of tie
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enPR_content_ST_location_EV_of (
    equivalent tinyint
)
RETURNS TABLE (
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epPR_content_ST_location_EV_of(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers. Views get their comments when they are
-- created, since Snowflake does not allow comments on view columns to be added afterwards.
--
COMMENT ON SCHEMA public IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE public.PAT_ParentalType_ID IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE public.GEN_Gender_ID IS 'Gender of an actor.';
COMMENT ON TABLE public.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN public.PLV_ProfessionalLevel.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE public.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN public.UTL_Utilization.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE public.ONG_Ongoing_ID IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE public.RAT_Rating_ID IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON TABLE public.ETY_EventType IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN public.ETY_EventType.ETY_EventType IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN public.EV_DAT_Event_Date.EV_DAT_Event_Date IS 'Date and time when the event took place.';
COMMENT ON COLUMN public.EV_AUD_Event_Audience.EV_AUD_Event_Audience IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN public.EV_REV_Event_Revenue.EV_REV_Event_Revenue IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN public.ST_NAM_Stage_Name.ST_NAM_Stage_Name IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN public.ST_LOC_Stage_Location.ST_LOC_Stage_Location IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN public.ST_AVG_Stage_Average.ST_AVG_UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN public.ST_MIN_Stage_Minimum.ST_MIN_UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN public.AC_NAM_Actor_Name.AC_NAM_Actor_Name IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN public.AC_GEN_Actor_Gender.AC_GEN_GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN public.AC_PLV_Actor_ProfessionalLevel.AC_PLV_PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN public.PR_NAM_Program_Name.PR_NAM_Program_Name IS 'Name or title of the program.';
COMMENT ON COLUMN public.PR_LEN_Program_Length.PR_LEN_Program_Length IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE public.PN_Person IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE public.ST_Stage IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE public.AC_Actor IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE public.PR_Program IS 'A program, such as a play, show or concert, that can be played on stages.';
COMMENT ON TABLE public.EV_Event IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN public.EV_Event.ST_ID_wasHeldAt IS 'The stage at which the event was held.';
COMMENT ON COLUMN public.EV_Event.PR_ID_wasPlayed IS 'The program that was played at the event.';
COMMENT ON COLUMN public.EV_Event.ETY_ID_of IS 'The type of the event.';
COMMENT ON TABLE public.AC_partner_AC_with_ONG_currently IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN public.AC_partner_AC_with_ONG_currently.AC_ID_partner IS 'One of the actors in the partnership.';
COMMENT ON COLUMN public.AC_partner_AC_with_ONG_currently.AC_ID_with IS 'The other actor in the partnership.';
COMMENT ON COLUMN public.AC_partner_AC_with_ONG_currently.ONG_ID_currently IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON TABLE public.AC_subset_PN_of IS 'Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.';
COMMENT ON COLUMN public.AC_subset_PN_of.AC_ID_subset IS 'The actor.';
COMMENT ON COLUMN public.AC_subset_PN_of.PN_ID_of IS 'The person who is the actor.';
COMMENT ON TABLE public.EV_in_AC_wasCast IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN public.EV_in_AC_wasCast.EV_ID_in IS 'The event the actor was cast in.';
COMMENT ON COLUMN public.EV_in_AC_wasCast.AC_ID_wasCast IS 'An actor cast in the event.';
COMMENT ON TABLE public.AC_part_PR_in_RAT_got IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN public.AC_part_PR_in_RAT_got.AC_ID_part IS 'The actor having a part in the program.';
COMMENT ON COLUMN public.AC_part_PR_in_RAT_got.PR_ID_in IS 'The program the actor has a part in.';
COMMENT ON COLUMN public.AC_part_PR_in_RAT_got.RAT_ID_got IS 'The rating the actor got for the part.';
COMMENT ON TABLE public.ST_at_PR_isPlaying IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN public.ST_at_PR_isPlaying.ST_ID_at IS 'The stage where the program is playing.';
COMMENT ON COLUMN public.ST_at_PR_isPlaying.PR_ID_isPlaying IS 'The program playing at the stage.';
COMMENT ON TABLE public.AC_parent_AC_child_PAT_having IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN public.AC_parent_AC_child_PAT_having.AC_ID_parent IS 'The actor who is the parent.';
COMMENT ON COLUMN public.AC_parent_AC_child_PAT_having.AC_ID_child IS 'The actor who is the child.';
COMMENT ON COLUMN public.AC_parent_AC_child_PAT_having.PAT_ID_having IS 'The type of parental relationship.';
COMMENT ON TABLE public.PR_content_ST_location_EV_of IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN public.PR_content_ST_location_EV_of.PR_ID_content IS 'The program that made up the content of the event.';
COMMENT ON COLUMN public.PR_content_ST_location_EV_of.ST_ID_location IS 'The stage where the event was located.';
COMMENT ON COLUMN public.PR_content_ST_location_EV_of.EV_ID_of IS 'The event.';
