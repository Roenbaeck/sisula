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
    GEN_ID number(1,0) not null,
    GEN_Gender varchar(42) not null,
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
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ONG_Ongoing (
    ONG_ID tinyint not null,
    ONG_Ongoing varchar(3) not null,
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
    RAT_ID tinyint not null,
    RAT_Rating varchar(42) not null,
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
    EV_ID int not null,
    EV_DAT_Event_Date datetime not null,
    constraint fkEV_DAT_Event_Date foreign key (
        EV_ID
    ) references public.EV_Event(EV_ID),
    constraint pkEV_DAT_Event_Date primary key (
        EV_ID
    )
) CLUSTER BY (EV_ID);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_AUD_Event_Audience (
    EV_ID int not null,
    EV_AUD_Event_Audience int not null,
    constraint fkEV_AUD_Event_Audience foreign key (
        EV_ID
    ) references public.EV_Event(EV_ID),
    constraint pkEV_AUD_Event_Audience primary key (
        EV_ID
    )
) CLUSTER BY (EV_ID);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_REV_Event_Revenue (
    EV_ID int not null,
    EV_REV_Event_Revenue number(19,4) not null,
    constraint fkEV_REV_Event_Revenue foreign key (
        EV_ID
    ) references public.EV_Event(EV_ID),
    constraint pkEV_REV_Event_Revenue primary key (
        EV_ID
    )
) CLUSTER BY (EV_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_NAM_Stage_Name (
    ST_ID int not null,
    ST_NAM_Stage_Name varchar(42) not null,
    ST_NAM_ChangedAt datetime not null,
    constraint fkST_NAM_Stage_Name foreign key (
        ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint pkST_NAM_Stage_Name primary key (
        ST_ID,
        ST_NAM_ChangedAt
    )
) CLUSTER BY (ST_ID, ST_NAM_ChangedAt);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_LOC_Stage_Location (
    ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum numeric(19,0) default hash(ST_LOC_Stage_Location),
    constraint fkST_LOC_Stage_Location foreign key (
        ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint pkST_LOC_Stage_Location primary key (
        ST_ID
    )
) CLUSTER BY (ST_ID);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_AVG_Stage_Average (
    ST_ID int not null,
    UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime not null,
    constraint fk_A_ST_AVG_Stage_Average foreign key (
        ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint fk_K_ST_AVG_Stage_Average foreign key (
        UTL_ID
    ) references public.UTL_Utilization(UTL_ID),
    constraint pkST_AVG_Stage_Average primary key (
        ST_ID,
        ST_AVG_ChangedAt
    )
) CLUSTER BY (ST_ID, ST_AVG_ChangedAt);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_MIN_Stage_Minimum (
    ST_ID int not null,
    UTL_ID tinyint not null,
    constraint fk_A_ST_MIN_Stage_Minimum foreign key (
        ST_ID
    ) references public.ST_Stage(ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum foreign key (
        UTL_ID
    ) references public.UTL_Utilization(UTL_ID),
    constraint pkST_MIN_Stage_Minimum primary key (
        ST_ID
    )
) CLUSTER BY (ST_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_NAM_Actor_Name (
    AC_ID int not null,
    AC_NAM_Actor_Name varchar(42) not null,
    AC_NAM_ChangedAt datetime not null,
    constraint fkAC_NAM_Actor_Name foreign key (
        AC_ID
    ) references public.AC_Actor(AC_ID),
    constraint pkAC_NAM_Actor_Name primary key (
        AC_ID,
        AC_NAM_ChangedAt
    )
) CLUSTER BY (AC_ID, AC_NAM_ChangedAt);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_GEN_Actor_Gender (
    AC_ID int not null,
    GEN_ID number(1,0) not null,
    constraint fk_A_AC_GEN_Actor_Gender foreign key (
        AC_ID
    ) references public.AC_Actor(AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender foreign key (
        GEN_ID
    ) references public.GEN_Gender(GEN_ID),
    constraint pkAC_GEN_Actor_Gender primary key (
        AC_ID
    )
) CLUSTER BY (AC_ID);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_PLV_Actor_ProfessionalLevel (
    AC_ID int not null,
    PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_ID
    ) references public.AC_Actor(AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel foreign key (
        PLV_ID
    ) references public.PLV_ProfessionalLevel(PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel primary key (
        AC_ID,
        AC_PLV_ChangedAt
    )
) CLUSTER BY (AC_ID, AC_PLV_ChangedAt);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_NAM_Program_Name (
    PR_ID int not null,
    PR_NAM_Program_Name varchar(42) not null,
    constraint fkPR_NAM_Program_Name foreign key (
        PR_ID
    ) references public.PR_Program(PR_ID),
    constraint pkPR_NAM_Program_Name primary key (
        PR_ID
    )
) CLUSTER BY (PR_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_LEN_Program_Length (
    PR_ID int not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length foreign key (
        PR_ID
    ) references public.PR_Program(PR_ID),
    constraint pkPR_LEN_Program_Length primary key (
        PR_ID,
        PR_LEN_ChangedAt
    )
) CLUSTER BY (PR_ID, PR_LEN_ChangedAt);
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
    ) references public.ONG_Ongoing(ONG_ID),
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
    ) references public.RAT_Rating(RAT_ID),
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
    ) references public.PAT_ParentalType(PAT_ID),
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
RETURNS TABLE (
    ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
    SELECT
        ST_ID,
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
RETURNS TABLE (
    ST_ID int,
    UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
    SELECT
        ST_ID,
        UTL_ID,
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
RETURNS TABLE (
    AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
    SELECT
        AC_ID,
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
RETURNS TABLE (
    AC_ID int,
    PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
    SELECT
        AC_ID,
        PLV_ID,
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
    PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
    SELECT
        PR_ID,
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
    ST_NAM_ChangedAt,
    ST_NAM_Stage_Name COMMENT 'Name of the stage. Historized, since a stage may be renamed over time.',
    ST_LOC_Checksum,
    ST_LOC_Stage_Location COMMENT 'Geographic location of the stage as a geography point.',
    ST_AVG_ChangedAt,
    UTL_Utilization COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    UTL_ID COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    UTL_Utilization COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.',
    UTL_ID COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.'
) COMMENT = 'A stage or venue where programs are played and events are held.'
AS
SELECT
    ST.ST_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ChangedAt,
    kAVG.UTL_Utilization AS UTL_Utilization,
    AVG.UTL_ID,
    kMIN.UTL_Utilization AS UTL_Utilization,
    MIN.UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    public.ST_NAM_Stage_Name NAM
ON
    NAM.ST_ID = ST.ST_ID
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            public.ST_NAM_Stage_Name sub
        WHERE
            sub.ST_ID = ST.ST_ID
   )
LEFT JOIN
    public.ST_LOC_Stage_Location LOC
ON
    LOC.ST_ID = ST.ST_ID
LEFT JOIN
    public.ST_AVG_Stage_Average AVG
ON
    AVG.ST_ID = ST.ST_ID
AND
    AVG.ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            public.ST_AVG_Stage_Average sub
        WHERE
            sub.ST_ID = ST.ST_ID
   )
LEFT JOIN
    public.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.UTL_ID
LEFT JOIN
    public.ST_MIN_Stage_Minimum MIN
ON
    MIN.ST_ID = ST.ST_ID
LEFT JOIN
    public.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.UTL_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pST_Stage (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    ST_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ChangedAt datetime,
    UTL_Utilization tinyint,
    UTL_ID tinyint,
    UTL_Utilization tinyint,
    UTL_ID tinyint
)
AS
$$
SELECT
    ST.ST_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ChangedAt,
    kAVG.UTL_Utilization AS UTL_Utilization,
    AVG.UTL_ID,
    kMIN.UTL_Utilization AS UTL_Utilization,
    MIN.UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    TABLE(public.rST_NAM_Stage_Name(changingTimepoint::datetime)) NAM
ON
    NAM.ST_ID = ST.ST_ID
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            TABLE(public.rST_NAM_Stage_Name(changingTimepoint::datetime)) sub
        WHERE
            sub.ST_ID = ST.ST_ID
   )
LEFT JOIN
    public.ST_LOC_Stage_Location LOC
ON
    LOC.ST_ID = ST.ST_ID
LEFT JOIN
    TABLE(public.rST_AVG_Stage_Average(changingTimepoint::datetime)) AVG
ON
    AVG.ST_ID = ST.ST_ID
AND
    AVG.ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            TABLE(public.rST_AVG_Stage_Average(changingTimepoint::datetime)) sub
        WHERE
            sub.ST_ID = ST.ST_ID
   )
LEFT JOIN
    public.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.UTL_ID
LEFT JOIN
    public.ST_MIN_Stage_Minimum MIN
ON
    MIN.ST_ID = ST.ST_ID
LEFT JOIN
    public.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.UTL_ID
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
    ST_NAM_ChangedAt datetime,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ChangedAt datetime,
    UTL_Utilization tinyint,
    UTL_ID tinyint,
    UTL_Utilization tinyint,
    UTL_ID tinyint
)
AS
$$
SELECT DISTINCT
    hNAM.ST_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    pST.ST_ID,
    pST.ST_NAM_ChangedAt,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_Checksum,
    pST.ST_LOC_Stage_Location,
    pST.ST_AVG_ChangedAt,
    pST.UTL_Utilization,
    pST.UTL_ID,
    pST.UTL_Utilization,
    pST.UTL_ID
FROM
    public.ST_NAM_Stage_Name hNAM,
    TABLE(public.pST_Stage(hNAM.ST_NAM_ChangedAt::timestamp_ntz(9))) pST
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    hNAM.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pST.ST_ID = hNAM.ST_ID
UNION
SELECT DISTINCT
    hAVG.ST_AVG_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'AVG' AS mnemonic,
    pST.ST_ID,
    pST.ST_NAM_ChangedAt,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_Checksum,
    pST.ST_LOC_Stage_Location,
    pST.ST_AVG_ChangedAt,
    pST.UTL_Utilization,
    pST.UTL_ID,
    pST.UTL_Utilization,
    pST.UTL_ID
FROM
    public.ST_AVG_Stage_Average hAVG,
    TABLE(public.pST_Stage(hAVG.ST_AVG_ChangedAt::timestamp_ntz(9))) pST
WHERE
    (selection IS NULL OR selection LIKE '%AVG%')
AND
    hAVG.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pST.ST_ID = hAVG.ST_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_Actor (
    AC_ID,
    AC_NAM_ChangedAt,
    AC_NAM_Actor_Name COMMENT 'Name of the actor, such as a stage name. Historized, since it may change over time.',
    GEN_Gender COMMENT 'Gender of the actor.',
    GEN_ID COMMENT 'Gender of the actor.',
    AC_PLV_ChangedAt,
    ,
    PLV_ProfessionalLevel COMMENT 'Professional level of the actor, which may change as the actor gains experience.',
    PLV_ID COMMENT 'Professional level of the actor, which may change as the actor gains experience.'
) COMMENT = 'An actor, a person who performs parts in programs and is cast in events.'
AS
SELECT
    AC.AC_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_Actor_Name,
    kGEN.GEN_Gender AS GEN_Gender,
    GEN.GEN_ID,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_Checksum AS ,
    kPLV.PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    PLV.PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    public.AC_NAM_Actor_Name NAM
ON
    NAM.AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            public.AC_NAM_Actor_Name sub
        WHERE
            sub.AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_ID = AC.AC_ID
LEFT JOIN
    public.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.GEN_ID
LEFT JOIN
    public.AC_PLV_Actor_ProfessionalLevel PLV
ON
    PLV.AC_ID = AC.AC_ID
AND
    PLV.AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            public.AC_PLV_Actor_ProfessionalLevel sub
        WHERE
            sub.AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.PLV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_Actor (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    AC_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_Actor_Name varchar(42),
    GEN_Gender varchar(42),
    GEN_ID number(1,0),
    AC_PLV_ChangedAt datetime,
     numeric(19,0),
    PLV_ProfessionalLevel string,
    PLV_ID tinyint
)
AS
$$
SELECT
    AC.AC_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_Actor_Name,
    kGEN.GEN_Gender AS GEN_Gender,
    GEN.GEN_ID,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_Checksum AS ,
    kPLV.PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    PLV.PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    TABLE(public.rAC_NAM_Actor_Name(changingTimepoint::datetime)) NAM
ON
    NAM.AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            TABLE(public.rAC_NAM_Actor_Name(changingTimepoint::datetime)) sub
        WHERE
            sub.AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_ID = AC.AC_ID
LEFT JOIN
    public.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.GEN_ID
LEFT JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint::datetime)) PLV
ON
    PLV.AC_ID = AC.AC_ID
AND
    PLV.AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            TABLE(public.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint::datetime)) sub
        WHERE
            sub.AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.PLV_ID
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
    AC_NAM_ChangedAt datetime,
    AC_NAM_Actor_Name varchar(42),
    GEN_Gender varchar(42),
    GEN_ID number(1,0),
    AC_PLV_ChangedAt datetime,
     numeric(19,0),
    PLV_ProfessionalLevel string,
    PLV_ID tinyint
)
AS
$$
SELECT DISTINCT
    hNAM.AC_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    pAC.AC_ID,
    pAC.AC_NAM_ChangedAt,
    pAC.AC_NAM_Actor_Name,
    pAC.GEN_Gender,
    pAC.GEN_ID,
    pAC.AC_PLV_ChangedAt,
    pAC.,
    pAC.PLV_ProfessionalLevel,
    pAC.PLV_ID
FROM
    public.AC_NAM_Actor_Name hNAM,
    TABLE(public.pAC_Actor(hNAM.AC_NAM_ChangedAt::timestamp_ntz(9))) pAC
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    hNAM.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pAC.AC_ID = hNAM.AC_ID
UNION
SELECT DISTINCT
    hPLV.AC_PLV_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'PLV' AS mnemonic,
    pAC.AC_ID,
    pAC.AC_NAM_ChangedAt,
    pAC.AC_NAM_Actor_Name,
    pAC.GEN_Gender,
    pAC.GEN_ID,
    pAC.AC_PLV_ChangedAt,
    pAC.,
    pAC.PLV_ProfessionalLevel,
    pAC.PLV_ID
FROM
    public.AC_PLV_Actor_ProfessionalLevel hPLV,
    TABLE(public.pAC_Actor(hPLV.AC_PLV_ChangedAt::timestamp_ntz(9))) pAC
WHERE
    (selection IS NULL OR selection LIKE '%PLV%')
AND
    hPLV.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pAC.AC_ID = hPLV.AC_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lPR_Program (
    PR_ID,
    PR_NAM_Program_Name COMMENT 'Name or title of the program.',
    PR_LEN_ChangedAt,
    PR_LEN_Program_Length COMMENT 'Running time of the program. Historized, since the program may be shortened or extended over time.'
) COMMENT = 'A program, such as a play, show or concert, that can be played on stages.'
AS
SELECT
    PR.PR_ID,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_Program_Length
FROM
    public.PR_Program PR
LEFT JOIN
    public.PR_NAM_Program_Name NAM
ON
    NAM.PR_ID = PR.PR_ID
LEFT JOIN
    public.PR_LEN_Program_Length LEN
ON
    LEN.PR_ID = PR.PR_ID
AND
    LEN.PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            public.PR_LEN_Program_Length sub
        WHERE
            sub.PR_ID = PR.PR_ID
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pPR_Program (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    PR_ID int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    PR.PR_ID,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_Program_Length
FROM
    public.PR_Program PR
LEFT JOIN
    public.PR_NAM_Program_Name NAM
ON
    NAM.PR_ID = PR.PR_ID
LEFT JOIN
    TABLE(public.rPR_LEN_Program_Length(changingTimepoint::date)) LEN
ON
    LEN.PR_ID = PR.PR_ID
AND
    LEN.PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            TABLE(public.rPR_LEN_Program_Length(changingTimepoint::date)) sub
        WHERE
            sub.PR_ID = PR.PR_ID
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
    PR_NAM_Program_Name varchar(42),
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT DISTINCT
    hLEN.PR_LEN_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'LEN' AS mnemonic,
    pPR.PR_ID,
    pPR.PR_NAM_Program_Name,
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
    pPR.PR_ID = hLEN.PR_ID
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
    ETY_EventType COMMENT 'The type of the event.',
    ETY_ID_of COMMENT 'The type of the event.',
    EV_DAT_Event_Date COMMENT 'Date and time when the event took place.',
    EV_AUD_Event_Audience COMMENT 'Number of people in the audience at the event.',
    EV_REV_Event_Revenue COMMENT 'Revenue from ticket sales for the event.'
) COMMENT = 'An event, a single performance of a program held at a stage at a specific date and time.'
AS
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_Event_Audience,
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
    DAT.EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_REV_Event_Revenue REV
ON
    REV.EV_ID = EV.EV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_Event_Date datetime,
    EV_AUD_Event_Audience int,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_Event_Audience,
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
    DAT.EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_REV_Event_Revenue REV
ON
    REV.EV_ID = EV.EV_ID
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
    ONG_Ongoing COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).',
    ONG_ID_currently COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).'
) COMMENT = 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.'
AS
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS ONG_Ongoing,
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
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    ONG_Ongoing varchar(3),
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS ONG_Ongoing,
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
    ONG_Ongoing varchar(3),
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS ONG_Ongoing,
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
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got (
    AC_part_PR_in_RAT_got_ChangedAt,
    AC_ID_part COMMENT 'The actor having a part in the program.',
    PR_ID_in COMMENT 'The program the actor has a part in.',
    RAT_Rating COMMENT 'The rating the actor got for the part.',
    RAT_ID_got COMMENT 'The rating the actor got for the part.'
) COMMENT = 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.'
AS
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS RAT_Rating,
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
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    RAT_Rating varchar(42),
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS RAT_Rating,
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
    RAT_Rating varchar(42),
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS RAT_Rating,
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
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_parent_AC_child_PAT_having (
    AC_ID_parent COMMENT 'The actor who is the parent.',
    AC_ID_child COMMENT 'The actor who is the child.',
    PAT_ParentalType COMMENT 'The type of parental relationship.',
    PAT_ID_having COMMENT 'The type of parental relationship.'
) COMMENT = 'Parent-child relationships between actors, along with the type of parental relationship.'
AS
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS PAT_ParentalType,
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
RETURNS TABLE (
    AC_ID_parent int,
    AC_ID_child int,
    PAT_ParentalType varchar(42),
    PAT_ID_having tinyint
)
AS
$$
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS PAT_ParentalType,
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
CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having AS
SELECT
    *
FROM
    TABLE(public.pAC_parent_AC_child_PAT_having(current_timestamp()::timestamp_ntz(9)))
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
COMMENT ON COLUMN public.EV_DAT_Event_Date.EV_DAT_Event_Date IS 'Date and time when the event took place.';
COMMENT ON COLUMN public.EV_AUD_Event_Audience.EV_AUD_Event_Audience IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN public.EV_REV_Event_Revenue.EV_REV_Event_Revenue IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN public.ST_NAM_Stage_Name.ST_NAM_Stage_Name IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN public.ST_LOC_Stage_Location.ST_LOC_Stage_Location IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN public.ST_AVG_Stage_Average.UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN public.ST_MIN_Stage_Minimum.UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN public.AC_NAM_Actor_Name.AC_NAM_Actor_Name IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN public.AC_GEN_Actor_Gender.GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN public.AC_PLV_Actor_ProfessionalLevel.PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
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
