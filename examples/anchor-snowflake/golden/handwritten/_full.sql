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
CREATE TABLE IF NOT EXISTS knots.PAT_ParentalType (
    PAT_ID tinyint not null,
    PAT_ParentalType varchar(42) not null,
    Metadata_PAT int not null,
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
CREATE TABLE IF NOT EXISTS knots.GEN_Gender (
    GEN_ID number(1,0) not null,
    GEN_Gender varchar(42) not null,
    GEN_Checksum numeric(19,0) default hash(GEN_Gender),
    Metadata_GEN int not null,
    constraint pkGEN_Gender primary key (
        GEN_ID
    ),
    constraint uqGEN_Gender unique (
        GEN_Checksum 
    )
) CLUSTER BY (GEN_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.PLV_ProfessionalLevel (
    PLV_ID tinyint not null,
    PLV_ProfessionalLevel string not null,
    PLV_Checksum numeric(19,0) default hash(PLV_ProfessionalLevel),
    Metadata_PLV int not null,
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
CREATE TABLE IF NOT EXISTS knots.UTL_Utilization (
    UTL_ID tinyint not null,
    UTL_Utilization tinyint not null,
    Metadata_UTL int not null,
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
CREATE TABLE IF NOT EXISTS knots.ONG_Ongoing (
    ONG_ID tinyint not null,
    ONG_Ongoing varchar(3) not null,
    Metadata_ONG int not null,
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
CREATE SEQUENCE IF NOT EXISTS knots.RAT_Rating_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots.RAT_Rating (
    RAT_ID tinyint default knots.RAT_Rating_ID_SEQ.nextval not null, 
    RAT_Rating varchar(42) not null,
    RAT_Checksum numeric(19,0) default hash(RAT_Rating),
    Metadata_RAT int not null,
    constraint pkRAT_Rating primary key (
        RAT_ID
    ),
    constraint uqRAT_Rating unique (
        RAT_Checksum 
    )
) CLUSTER BY (RAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.ETY_EventType (
    ETY_ID tinyint not null,
    ETY_EventType varchar(42) not null,
    ETY_Checksum numeric(19,0) default hash(ETY_EventType),
    Metadata_ETY int not null,
    constraint pkETY_EventType primary key (
        ETY_ID
    ),
    constraint uqETY_EventType unique (
        ETY_Checksum 
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
CREATE SEQUENCE IF NOT EXISTS anchors.PN_Person_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors.PN_Person (
    PN_ID bigint default anchors.PN_Person_ID_SEQ.nextval not null, 
    Metadata_PN int not null,
    constraint pkPN_Person primary key (
        PN_ID
    )
) CLUSTER BY (PN_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.ST_Stage (
    ST_ID int not null,
    Metadata_ST int not null,
    constraint pkST_Stage primary key (
        ST_ID
    )
) CLUSTER BY (ST_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors.AC_Actor_ID_SEQ START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors.AC_Actor (
    AC_ID smallint default anchors.AC_Actor_ID_SEQ.nextval not null, 
    Metadata_AC int not null,
    constraint pkAC_Actor primary key (
        AC_ID
    )
) CLUSTER BY (AC_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.PR_Program (
    PR_ID number(10,0) not null,
    Metadata_PR int not null,
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
-- EV_Event table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses.EV_Event (
    EV_ID numeric(12,0) not null,
    ST_ID_wasHeldAt int not null, 
    PR_ID_wasPlayed number(10,0) not null, 
    ETY_ID_of tinyint not null,
    constraint EV_Event_fkST_wasHeldAt foreign key (
        ST_ID_wasHeldAt
    ) references anchors.ST_Stage(ST_ID), 
    constraint EV_Event_fkPR_wasPlayed foreign key (
        PR_ID_wasPlayed
    ) references anchors.PR_Program(PR_ID), 
    constraint EV_Event_fkETY_of foreign key (
        ETY_ID_of
    ) references knots.ETY_EventType_ID(ETY_ID),
    Metadata_EV int not null, 
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
CREATE TABLE IF NOT EXISTS attributes.EV_DAT_Event_Date (
    EV_DAT_EV_ID numeric(12,0) not null,
    EV_DAT_Event_Date datetime not null,
    Metadata_EV_DAT int not null,
    constraint fkEV_DAT_Event_Date foreign key (
        EV_DAT_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint pkEV_DAT_Event_Date primary key (
        EV_DAT_EV_ID
    )
) CLUSTER BY (EV_DAT_EV_ID);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_AUD_Event_Audience (
    EV_AUD_EV_ID numeric(12,0) not null,
    EV_AUD_EQ tinyint not null,
    EV_AUD_Event_Audience int not null,
    Metadata_EV_AUD int not null,
    constraint fkEV_AUD_Event_Audience foreign key (
        EV_AUD_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint pkEV_AUD_Event_Audience primary key (
        EV_AUD_EQ,
        EV_AUD_EV_ID
    )
) CLUSTER BY (EV_AUD_EV_ID);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_REV_Event_Revenue (
    EV_REV_EV_ID numeric(12,0) not null,
    EV_REV_Event_Revenue number(19,4) not null,
    Metadata_EV_REV int not null,
    constraint fkEV_REV_Event_Revenue foreign key (
        EV_REV_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint pkEV_REV_Event_Revenue primary key (
        EV_REV_EV_ID
    )
) CLUSTER BY (EV_REV_EV_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Event_Status table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_STA_Event_Status (
    EV_STA_EV_ID numeric(12,0) not null,
    EV_STA_EQ tinyint not null,
    EV_STA_Event_Status varchar(20) not null,
    EV_STA_ChangedAt datetime not null,
    Metadata_EV_STA int not null,
    constraint fkEV_STA_Event_Status foreign key (
        EV_STA_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint pkEV_STA_Event_Status primary key (
        EV_STA_EQ,
        EV_STA_EV_ID,
        EV_STA_ChangedAt
    )
) CLUSTER BY (EV_STA_EV_ID, EV_STA_ChangedAt);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_UTL_Event_Utilization (
    EV_UTL_EV_ID numeric(12,0) not null,
    EV_UTL_UTL_ID tinyint not null,
    Metadata_EV_UTL int not null,
    constraint fk_A_EV_UTL_Event_Utilization foreign key (
        EV_UTL_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint fk_K_EV_UTL_Event_Utilization foreign key (
        EV_UTL_UTL_ID
    ) references knots.UTL_Utilization(UTL_ID),
    constraint pkEV_UTL_Event_Utilization primary key (
        EV_UTL_EV_ID
    )
) CLUSTER BY (EV_UTL_EV_ID);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Event_Level table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_LVL_Event_Level (
    EV_LVL_EV_ID numeric(12,0) not null,
    EV_LVL_PLV_ID tinyint not null,
    EV_LVL_ChangedAt date not null,
    Metadata_EV_LVL int not null,
    constraint fk_A_EV_LVL_Event_Level foreign key (
        EV_LVL_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint fk_K_EV_LVL_Event_Level foreign key (
        EV_LVL_PLV_ID
    ) references knots.PLV_ProfessionalLevel_ID(PLV_ID),
    constraint pkEV_LVL_Event_Level primary key (
        EV_LVL_EV_ID,
        EV_LVL_ChangedAt
    )
) CLUSTER BY (EV_LVL_EV_ID, EV_LVL_ChangedAt);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_NAM_Stage_Name (
    ST_NAM_ST_ID int not null,
    ST_NAM_EQ tinyint not null,
    ST_NAM_Stage_Name varchar(42) not null,
    ST_NAM_ChangedAt datetime not null,
    Metadata_ST_NAM int not null,
    constraint fkST_NAM_Stage_Name foreign key (
        ST_NAM_ST_ID
    ) references anchors.ST_Stage(ST_ID),
    constraint pkST_NAM_Stage_Name primary key (
        ST_NAM_EQ,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt
    )
) CLUSTER BY (ST_NAM_ST_ID, ST_NAM_ChangedAt);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_LOC_Stage_Location (
    ST_LOC_ST_ID int not null,
    ST_LOC_EQ tinyint not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum numeric(19,0) default hash(ST_LOC_Stage_Location),
    Metadata_ST_LOC int not null,
    constraint fkST_LOC_Stage_Location foreign key (
        ST_LOC_ST_ID
    ) references anchors.ST_Stage(ST_ID),
    constraint pkST_LOC_Stage_Location primary key (
        ST_LOC_EQ,
        ST_LOC_ST_ID
    )
) CLUSTER BY (ST_LOC_ST_ID);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_AVG_Stage_Average (
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime not null,
    Metadata_ST_AVG int not null,
    constraint fk_A_ST_AVG_Stage_Average foreign key (
        ST_AVG_ST_ID
    ) references anchors.ST_Stage(ST_ID),
    constraint fk_K_ST_AVG_Stage_Average foreign key (
        ST_AVG_UTL_ID
    ) references knots.UTL_Utilization(UTL_ID),
    constraint pkST_AVG_Stage_Average primary key (
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt
    )
) CLUSTER BY (ST_AVG_ST_ID, ST_AVG_ChangedAt);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_MIN_Stage_Minimum (
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    Metadata_ST_MIN int not null,
    constraint fk_A_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_ST_ID
    ) references anchors.ST_Stage(ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_UTL_ID
    ) references knots.UTL_Utilization(UTL_ID),
    constraint pkST_MIN_Stage_Minimum primary key (
        ST_MIN_ST_ID
    )
) CLUSTER BY (ST_MIN_ST_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_NAM_Actor_Name (
    AC_NAM_AC_ID smallint not null,
    AC_NAM_Actor_Name varbinary(max) not null,
    AC_NAM_ChangedAt datetime not null,
    Metadata_AC_NAM int not null,
    constraint fkAC_NAM_Actor_Name foreign key (
        AC_NAM_AC_ID
    ) references anchors.AC_Actor(AC_ID),
    constraint pkAC_NAM_Actor_Name primary key (
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt
    )
) CLUSTER BY (AC_NAM_AC_ID, AC_NAM_ChangedAt);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_GEN_Actor_Gender (
    AC_GEN_AC_ID smallint not null,
    AC_GEN_GEN_ID number(1,0) not null,
    Metadata_AC_GEN int not null,
    constraint fk_A_AC_GEN_Actor_Gender foreign key (
        AC_GEN_AC_ID
    ) references anchors.AC_Actor(AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender foreign key (
        AC_GEN_GEN_ID
    ) references knots.GEN_Gender(GEN_ID),
    constraint pkAC_GEN_Actor_Gender primary key (
        AC_GEN_AC_ID
    )
) CLUSTER BY (AC_GEN_AC_ID);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_PLV_Actor_ProfessionalLevel (
    AC_PLV_AC_ID smallint not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime not null,
    Metadata_AC_PLV int not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_AC_ID
    ) references anchors.AC_Actor(AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_PLV_ID
    ) references knots.PLV_ProfessionalLevel_ID(PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel primary key (
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt
    )
) CLUSTER BY (AC_PLV_AC_ID, AC_PLV_ChangedAt);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.PR_NAM_Program_Name (
    PR_NAM_PR_ID number(10,0) not null,
    PR_NAM_Program_Name varchar(42) not null,
    Metadata_PR_NAM int not null,
    constraint fkPR_NAM_Program_Name foreign key (
        PR_NAM_PR_ID
    ) references anchors.PR_Program(PR_ID),
    constraint pkPR_NAM_Program_Name primary key (
        PR_NAM_PR_ID
    )
) CLUSTER BY (PR_NAM_PR_ID);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.PR_LEN_Program_Length (
    PR_LEN_PR_ID number(10,0) not null,
    PR_LEN_Program_Length time not null,
    PR_LEN_ChangedAt date not null,
    Metadata_PR_LEN int not null,
    constraint fkPR_LEN_Program_Length foreign key (
        PR_LEN_PR_ID
    ) references anchors.PR_Program(PR_ID),
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
CREATE TABLE IF NOT EXISTS ties.AC_partner_AC_with_ONG_currently (
    AC_ID_partner smallint not null, 
    AC_ID_with smallint not null, 
    ONG_ID_currently tinyint not null,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime not null,
    Metadata_AC_partner_AC_with_ONG_currently int not null,
    constraint AC_partner_AC_with_ONG_currently_fkAC_partner foreign key (
        AC_ID_partner
    ) references anchors.AC_Actor(AC_ID), 
    constraint AC_partner_AC_with_ONG_currently_fkAC_with foreign key (
        AC_ID_with
    ) references anchors.AC_Actor(AC_ID), 
    constraint AC_partner_AC_with_ONG_currently_fkONG_currently foreign key (
        ONG_ID_currently
    ) references knots.ONG_Ongoing(ONG_ID),
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
CREATE TABLE IF NOT EXISTS ties.AC_subset_PN_of (
    AC_ID_subset smallint not null, 
    PN_ID_of bigint not null, 
    Metadata_AC_subset_PN_of int not null,
    constraint AC_subset_PN_of_fkAC_subset foreign key (
        AC_ID_subset
    ) references anchors.AC_Actor(AC_ID), 
    constraint AC_subset_PN_of_fkPN_of foreign key (
        PN_ID_of
    ) references anchors.PN_Person(PN_ID), 
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
CREATE TABLE IF NOT EXISTS ties.EV_in_AC_wasCast (
    EV_ID_in numeric(12,0) not null, 
    AC_ID_wasCast smallint not null, 
    Metadata_EV_in_AC_wasCast int not null,
    constraint EV_in_AC_wasCast_fkEV_in foreign key (
        EV_ID_in
    ) references nexuses.EV_Event(EV_ID), 
    constraint EV_in_AC_wasCast_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references anchors.AC_Actor(AC_ID), 
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
CREATE TABLE IF NOT EXISTS ties.AC_part_PR_in_RAT_got (
    AC_ID_part smallint not null, 
    PR_ID_in number(10,0) not null, 
    RAT_ID_got tinyint not null,
    AC_part_PR_in_RAT_got_ChangedAt datetime not null,
    Metadata_AC_part_PR_in_RAT_got int not null,
    constraint AC_part_PR_in_RAT_got_fkAC_part foreign key (
        AC_ID_part
    ) references anchors.AC_Actor(AC_ID), 
    constraint AC_part_PR_in_RAT_got_fkPR_in foreign key (
        PR_ID_in
    ) references anchors.PR_Program(PR_ID), 
    constraint AC_part_PR_in_RAT_got_fkRAT_got foreign key (
        RAT_ID_got
    ) references knots.RAT_Rating_ID(RAT_ID),
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
CREATE TABLE IF NOT EXISTS ties.ST_at_PR_isPlaying (
    ST_ID_at int not null, 
    PR_ID_isPlaying number(10,0) not null, 
    ST_at_PR_isPlaying_ChangedAt datetime not null,
    Metadata_ST_at_PR_isPlaying int not null,
    constraint ST_at_PR_isPlaying_fkST_at foreign key (
        ST_ID_at
    ) references anchors.ST_Stage(ST_ID), 
    constraint ST_at_PR_isPlaying_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references anchors.PR_Program(PR_ID), 
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
CREATE TABLE IF NOT EXISTS ties.AC_parent_AC_child_PAT_having (
    AC_ID_parent smallint not null, 
    AC_ID_child smallint not null, 
    PAT_ID_having tinyint not null,
    Metadata_AC_parent_AC_child_PAT_having int not null,
    constraint AC_parent_AC_child_PAT_having_fkAC_parent foreign key (
        AC_ID_parent
    ) references anchors.AC_Actor(AC_ID), 
    constraint AC_parent_AC_child_PAT_having_fkAC_child foreign key (
        AC_ID_child
    ) references anchors.AC_Actor(AC_ID), 
    constraint AC_parent_AC_child_PAT_having_fkPAT_having foreign key (
        PAT_ID_having
    ) references knots.PAT_ParentalType_ID(PAT_ID),
    constraint pkAC_parent_AC_child_PAT_having primary key (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
) CLUSTER BY (
    AC_ID_parent,
    AC_ID_child
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.PR_content_ST_location_EV_of (
    PR_ID_content number(10,0) not null, 
    ST_ID_location int not null, 
    EV_ID_of numeric(12,0) not null, 
    PR_content_ST_location_EV_of_ChangedAt datetime not null,
    Metadata_PR_content_ST_location_EV_of int not null,
    constraint PR_content_ST_location_EV_of_fkPR_content foreign key (
        PR_ID_content
    ) references anchors.PR_Program(PR_ID), 
    constraint PR_content_ST_location_EV_of_fkST_location foreign key (
        ST_ID_location
    ) references anchors.ST_Stage(ST_ID), 
    constraint PR_content_ST_location_EV_of_fkEV_of foreign key (
        EV_ID_of
    ) references nexuses.EV_Event(EV_ID), 
    constraint PR_content_ST_location_EV_of_uqPR_content unique (
        PR_ID_content,
        PR_content_ST_location_EV_of_ChangedAt
    ),
    constraint PR_content_ST_location_EV_of_uqST_location unique (
        ST_ID_location,
        PR_content_ST_location_EV_of_ChangedAt
    ),
    constraint pkPR_content_ST_location_EV_of primary key (
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,
        PR_content_ST_location_EV_of_ChangedAt
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
-- rEV_STA_Event_Status rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status (
    equivalent tinyint,
    changingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_STA int,
    EV_STA_EV_ID numeric(12,0),
    EV_STA_EQ tinyint,
    EV_STA_Event_Status varchar(20),
    EV_STA_ChangedAt datetime
)
AS
$$
    SELECT
        Metadata_EV_STA,
        EV_STA_EV_ID,
        EV_STA_EQ,
        EV_STA_Event_Status,
        EV_STA_ChangedAt
    FROM
        TABLE(attributes.eEV_STA_Event_Status(equivalent)) 
    WHERE
        EV_STA_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Event_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level (
    changingTimepoint date
)
RETURNS TABLE (
    Metadata_EV_LVL int,
    EV_LVL_EV_ID numeric(12,0),
    EV_LVL_PLV_ID tinyint, 
    EV_LVL_ChangedAt date
)
AS
$$
    SELECT
        Metadata_EV_LVL,
        EV_LVL_EV_ID,
        EV_LVL_PLV_ID,
        EV_LVL_ChangedAt
    FROM
        attributes.EV_LVL_Event_Level
    WHERE
        EV_LVL_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name (
    equivalent tinyint,
    changingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ST_ID int,
    ST_NAM_EQ tinyint,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
    SELECT
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_EQ,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        TABLE(attributes.eST_NAM_Stage_Name(equivalent)) 
    WHERE
        ST_NAM_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average (
    changingTimepoint datetime
)
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
        attributes.ST_AVG_Stage_Average
    WHERE
        ST_AVG_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name (
    changingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_AC_ID smallint,
    AC_NAM_Actor_Name varbinary(max),
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
        attributes.AC_NAM_Actor_Name
    WHERE
        AC_NAM_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_AC_ID smallint,
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
        attributes.AC_PLV_Actor_ProfessionalLevel
    WHERE
        AC_PLV_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length (
    changingTimepoint date
)
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_PR_ID number(10,0),
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
        attributes.PR_LEN_Program_Length
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
CREATE OR REPLACE VIEW anchors.lST_Stage (
    ST_ID,
    Metadata_ST,
    ST_NAM_ST_ID,
    Metadata_ST_NAM,
    ST_NAM_ChangedAt,
    ST_NAM_EQ,
    ST_NAM_Stage_Name COMMENT 'Name of the stage. Historized, since a stage may be renamed over time.',
    ST_LOC_ST_ID,
    Metadata_ST_LOC,
    ST_LOC_EQ,
    ST_LOC_Checksum,
    ST_LOC_Stage_Location COMMENT 'Geographic location of the stage as a geography point.',
    ST_AVG_ST_ID,
    Metadata_ST_AVG,
    ST_AVG_ChangedAt,
    ST_AVG_UTL_Utilization COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    ST_AVG_Metadata_UTL,
    ST_AVG_UTL_ID COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    ST_MIN_ST_ID,
    Metadata_ST_MIN,
    ST_MIN_UTL_Utilization COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.',
    ST_MIN_Metadata_UTL,
    ST_MIN_UTL_ID COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.'
) COMMENT = 'A stage or venue where programs are played and events are held.'
AS
SELECT
    ST.ST_ID,
    ST.Metadata_ST,
    NAM.ST_NAM_ST_ID,
    NAM.Metadata_ST_NAM,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_EQ,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.Metadata_ST_LOC,
    LOC.ST_LOC_EQ,
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
    anchors.ST_Stage ST
LEFT JOIN
    TABLE(attributes.eST_NAM_Stage_Name(0)) NAM
ON
    NAM.ST_NAM_ST_ID = ST.ST_ID
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            TABLE(attributes.eST_NAM_Stage_Name(0)) sub 
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
   )
LEFT JOIN
    TABLE(attributes.eST_LOC_Stage_Location(0)) LOC
ON
    LOC.ST_LOC_ST_ID = ST.ST_ID
LEFT JOIN
    attributes.ST_AVG_Stage_Average AVG
ON
    AVG.ST_AVG_ST_ID = ST.ST_ID
AND
    AVG.ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            attributes.ST_AVG_Stage_Average sub
        WHERE
            sub.ST_AVG_ST_ID = ST.ST_ID
   )
LEFT JOIN
    knots.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.ST_AVG_UTL_ID
LEFT JOIN
    attributes.ST_MIN_Stage_Minimum MIN
ON
    MIN.ST_MIN_ST_ID = ST.ST_ID
LEFT JOIN
    knots.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.ST_MIN_UTL_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pST_Stage (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    ST_ID int,
    Metadata_ST int,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_EQ tinyint,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC int,
    ST_LOC_EQ tinyint,
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
    NAM.ST_NAM_EQ,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.Metadata_ST_LOC,
    LOC.ST_LOC_EQ,
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
    anchors.ST_Stage ST
LEFT JOIN
    TABLE(attributes.rST_NAM_Stage_Name(0, changingTimepoint::datetime)) NAM
ON
    NAM.ST_NAM_ST_ID = ST.ST_ID
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            TABLE(attributes.rST_NAM_Stage_Name(0, changingTimepoint::datetime)) sub
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
   )
LEFT JOIN
    TABLE(attributes.eST_LOC_Stage_Location(0)) LOC
ON
    LOC.ST_LOC_ST_ID = ST.ST_ID
LEFT JOIN
    TABLE(attributes.rST_AVG_Stage_Average(changingTimepoint::datetime)) AVG
ON
    AVG.ST_AVG_ST_ID = ST.ST_ID
AND
    AVG.ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            TABLE(attributes.rST_AVG_Stage_Average(changingTimepoint::datetime)) sub
        WHERE
            sub.ST_AVG_ST_ID = ST.ST_ID
   )
LEFT JOIN
    knots.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.ST_AVG_UTL_ID
LEFT JOIN
    attributes.ST_MIN_Stage_Minimum MIN
ON
    MIN.ST_MIN_ST_ID = ST.ST_ID
LEFT JOIN
    knots.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.ST_MIN_UTL_ID
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nST_Stage
AS
SELECT
    *
FROM
    TABLE(anchors.pST_Stage(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dST_Stage (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    ST_ID int,
    Metadata_ST int,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_EQ tinyint,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC int,
    ST_LOC_EQ tinyint,
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
    pST.ST_NAM_EQ,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_ST_ID,
    pST.Metadata_ST_LOC,
    pST.ST_LOC_EQ,
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
    TABLE(attributes.eST_NAM_Stage_Name(0)) hNAM, 
    TABLE(anchors.pST_Stage(hNAM.ST_NAM_ChangedAt::timestamp_ntz(9))) pST
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
    pST.ST_NAM_EQ,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_ST_ID,
    pST.Metadata_ST_LOC,
    pST.ST_LOC_EQ,
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
    attributes.ST_AVG_Stage_Average hAVG,
    TABLE(anchors.pST_Stage(hAVG.ST_AVG_ChangedAt::timestamp_ntz(9))) pST
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
CREATE OR REPLACE VIEW anchors.lAC_Actor (
    AC_ID,
    Metadata_AC,
    AC_NAM_AC_ID,
    Metadata_AC_NAM,
    AC_NAM_ChangedAt,
    AC_NAM_Actor_Name COMMENT 'Name of the actor, such as a stage name. Historized, since it may change over time.',
    AC_GEN_AC_ID,
    Metadata_AC_GEN,
    AC_GEN_GEN_Checksum,
    AC_GEN_GEN_Gender COMMENT 'Gender of the actor.',
    AC_GEN_Metadata_GEN,
    AC_GEN_GEN_ID COMMENT 'Gender of the actor.',
    AC_PLV_AC_ID,
    Metadata_AC_PLV,
    AC_PLV_ChangedAt,
    AC_PLV_PLV_Checksum,
    AC_PLV_PLV_EQ,
    AC_PLV_PLV_ProfessionalLevel COMMENT 'Professional level of the actor, which may change as the actor gains experience.',
    AC_PLV_Metadata_PLV,
    AC_PLV_PLV_ID COMMENT 'Professional level of the actor, which may change as the actor gains experience.'
) COMMENT = 'An actor, a person who performs parts in programs and is cast in events.'
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
    kGEN.GEN_Checksum AS AC_GEN_GEN_Checksum,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    kGEN.Metadata_GEN AS AC_GEN_Metadata_GEN,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.Metadata_AC_PLV,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_Checksum AS AC_PLV_PLV_Checksum,
    kPLV.PLV_EQ AS AC_PLV_PLV_EQ,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    kPLV.Metadata_PLV AS AC_PLV_Metadata_PLV,
    PLV.AC_PLV_PLV_ID
FROM
    anchors.AC_Actor AC
LEFT JOIN
    attributes.AC_NAM_Actor_Name NAM
ON
    NAM.AC_NAM_AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            attributes.AC_NAM_Actor_Name sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
   )
LEFT JOIN
    attributes.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_GEN_AC_ID = AC.AC_ID
LEFT JOIN
    knots.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.AC_GEN_GEN_ID
LEFT JOIN
    attributes.AC_PLV_Actor_ProfessionalLevel PLV
ON
    PLV.AC_PLV_AC_ID = AC.AC_ID
AND
    PLV.AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel sub
        WHERE
            sub.AC_PLV_AC_ID = AC.AC_ID
   )
LEFT JOIN
    TABLE(knots.ePLV_ProfessionalLevel(0)) kPLV
ON
    kPLV.PLV_ID = PLV.AC_PLV_PLV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pAC_Actor (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    AC_ID smallint,
    Metadata_AC int,
    AC_NAM_AC_ID smallint,
    Metadata_AC_NAM int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_Actor_Name varbinary(max),
    AC_GEN_AC_ID smallint,
    Metadata_AC_GEN int,
    AC_GEN_GEN_Checksum numeric(19,0),
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN int,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID smallint,
    Metadata_AC_PLV int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_EQ tinyint,
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
    kGEN.GEN_Checksum AS AC_GEN_GEN_Checksum,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    kGEN.Metadata_GEN AS AC_GEN_Metadata_GEN,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.Metadata_AC_PLV,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_Checksum AS AC_PLV_PLV_Checksum,
    kPLV.PLV_EQ AS AC_PLV_PLV_EQ,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    kPLV.Metadata_PLV AS AC_PLV_Metadata_PLV,
    PLV.AC_PLV_PLV_ID
FROM
    anchors.AC_Actor AC
LEFT JOIN
    TABLE(attributes.rAC_NAM_Actor_Name(changingTimepoint::datetime)) NAM
ON
    NAM.AC_NAM_AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            TABLE(attributes.rAC_NAM_Actor_Name(changingTimepoint::datetime)) sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
   )
LEFT JOIN
    attributes.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_GEN_AC_ID = AC.AC_ID
LEFT JOIN
    knots.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.AC_GEN_GEN_ID
LEFT JOIN
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint::datetime)) PLV
ON
    PLV.AC_PLV_AC_ID = AC.AC_ID
AND
    PLV.AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint::datetime)) sub
        WHERE
            sub.AC_PLV_AC_ID = AC.AC_ID
   )
LEFT JOIN
    TABLE(knots.ePLV_ProfessionalLevel(0)) kPLV
ON
    kPLV.PLV_ID = PLV.AC_PLV_PLV_ID
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nAC_Actor
AS
SELECT
    *
FROM
    TABLE(anchors.pAC_Actor(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dAC_Actor (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    AC_ID smallint,
    Metadata_AC int,
    AC_NAM_AC_ID smallint,
    Metadata_AC_NAM int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_Actor_Name varbinary(max),
    AC_GEN_AC_ID smallint,
    Metadata_AC_GEN int,
    AC_GEN_GEN_Checksum numeric(19,0),
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN int,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID smallint,
    Metadata_AC_PLV int,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_EQ tinyint,
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
    pAC.AC_GEN_GEN_Checksum,
    pAC.AC_GEN_GEN_Gender,
    pAC.AC_GEN_Metadata_GEN,
    pAC.AC_GEN_GEN_ID,
    pAC.AC_PLV_AC_ID,
    pAC.Metadata_AC_PLV,
    pAC.AC_PLV_ChangedAt,
    pAC.AC_PLV_PLV_Checksum,
    pAC.AC_PLV_PLV_EQ,
    pAC.AC_PLV_PLV_ProfessionalLevel,
    pAC.AC_PLV_Metadata_PLV,
    pAC.AC_PLV_PLV_ID
FROM
    attributes.AC_NAM_Actor_Name hNAM,
    TABLE(anchors.pAC_Actor(hNAM.AC_NAM_ChangedAt::timestamp_ntz(9))) pAC
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
    pAC.AC_GEN_GEN_Checksum,
    pAC.AC_GEN_GEN_Gender,
    pAC.AC_GEN_Metadata_GEN,
    pAC.AC_GEN_GEN_ID,
    pAC.AC_PLV_AC_ID,
    pAC.Metadata_AC_PLV,
    pAC.AC_PLV_ChangedAt,
    pAC.AC_PLV_PLV_Checksum,
    pAC.AC_PLV_PLV_EQ,
    pAC.AC_PLV_PLV_ProfessionalLevel,
    pAC.AC_PLV_Metadata_PLV,
    pAC.AC_PLV_PLV_ID
FROM
    attributes.AC_PLV_Actor_ProfessionalLevel hPLV,
    TABLE(anchors.pAC_Actor(hPLV.AC_PLV_ChangedAt::timestamp_ntz(9))) pAC
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
CREATE OR REPLACE VIEW anchors.lPR_Program (
    PR_ID,
    Metadata_PR,
    PR_NAM_PR_ID,
    Metadata_PR_NAM,
    PR_NAM_Program_Name COMMENT 'Name or title of the program.',
    PR_LEN_PR_ID,
    Metadata_PR_LEN,
    PR_LEN_ChangedAt,
    PR_LEN_Program_Length COMMENT 'Running time of the program. Historized, since the program may be shortened or extended over time.'
) 
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
    anchors.PR_Program PR
LEFT JOIN
    attributes.PR_NAM_Program_Name NAM
ON
    NAM.PR_NAM_PR_ID = PR.PR_ID
LEFT JOIN
    attributes.PR_LEN_Program_Length LEN
ON
    LEN.PR_LEN_PR_ID = PR.PR_ID
AND
    LEN.PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            attributes.PR_LEN_Program_Length sub
        WHERE
            sub.PR_LEN_PR_ID = PR.PR_ID
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pPR_Program (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    PR_ID number(10,0),
    Metadata_PR int,
    PR_NAM_PR_ID number(10,0),
    Metadata_PR_NAM int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID number(10,0),
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
    anchors.PR_Program PR
LEFT JOIN
    attributes.PR_NAM_Program_Name NAM
ON
    NAM.PR_NAM_PR_ID = PR.PR_ID
LEFT JOIN
    TABLE(attributes.rPR_LEN_Program_Length(changingTimepoint::date)) LEN
ON
    LEN.PR_LEN_PR_ID = PR.PR_ID
AND
    LEN.PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            TABLE(attributes.rPR_LEN_Program_Length(changingTimepoint::date)) sub
        WHERE
            sub.PR_LEN_PR_ID = PR.PR_ID
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nPR_Program
AS
SELECT
    *
FROM
    TABLE(anchors.pPR_Program(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dPR_Program (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    PR_ID number(10,0),
    Metadata_PR int,
    PR_NAM_PR_ID number(10,0),
    Metadata_PR_NAM int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID number(10,0),
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
    attributes.PR_LEN_Program_Length hLEN,
    TABLE(anchors.pPR_Program(hLEN.PR_LEN_ChangedAt::timestamp_ntz(9))) pPR
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
CREATE OR REPLACE VIEW nexuses.lEV_Event (
    EV_ID,
    Metadata_EV,
    ST_ID_wasHeldAt COMMENT 'The stage at which the event was held.',
    PR_ID_wasPlayed COMMENT 'The program that was played at the event.',
    of_ETY_Checksum,
    of_ETY_EventType,
    of_ETY_EQ,
    of_Metadata_ETY,
    ETY_ID_of,
    EV_DAT_EV_ID,
    Metadata_EV_DAT,
    EV_DAT_Event_Date COMMENT 'Date and time when the event took place.',
    EV_AUD_EV_ID,
    Metadata_EV_AUD,
    EV_AUD_EQ,
    EV_AUD_Event_Audience COMMENT 'Number of people in the audience at the event.',
    EV_REV_EV_ID,
    Metadata_EV_REV,
    EV_REV_Event_Revenue COMMENT 'Revenue from ticket sales for the event.',
    EV_STA_EV_ID,
    Metadata_EV_STA,
    EV_STA_ChangedAt,
    EV_STA_EQ,
    EV_STA_Event_Status COMMENT 'Status of the event, which may change until it has taken place.',
    EV_UTL_EV_ID,
    Metadata_EV_UTL,
    EV_UTL_UTL_Utilization,
    EV_UTL_Metadata_UTL,
    EV_UTL_UTL_ID,
    EV_LVL_EV_ID,
    Metadata_EV_LVL,
    EV_LVL_ChangedAt,
    EV_LVL_PLV_Checksum,
    EV_LVL_PLV_EQ,
    EV_LVL_PLV_ProfessionalLevel COMMENT 'Professional level required for the event, over time.',
    EV_LVL_Metadata_PLV,
    EV_LVL_PLV_ID COMMENT 'Professional level required for the event, over time.'
) COMMENT = 'An event, a single performance of a program held at a stage at a specific date and time.'
AS
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_Checksum AS of_ETY_Checksum,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    ETY_of.ETY_EQ AS of_ETY_EQ,
    ETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_EQ,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_Event_Revenue,
    STA.EV_STA_EV_ID,
    STA.Metadata_EV_STA,
    STA.EV_STA_ChangedAt,
    STA.EV_STA_EQ,
    STA.EV_STA_Event_Status,
    UTL.EV_UTL_EV_ID,
    UTL.Metadata_EV_UTL,
    kUTL.UTL_Utilization AS EV_UTL_UTL_Utilization,
    kUTL.Metadata_UTL AS EV_UTL_Metadata_UTL,
    UTL.EV_UTL_UTL_ID,
    LVL.EV_LVL_EV_ID,
    LVL.Metadata_EV_LVL,
    LVL.EV_LVL_ChangedAt,
    kLVL.PLV_Checksum AS EV_LVL_PLV_Checksum,
    kLVL.PLV_EQ AS EV_LVL_PLV_EQ,
    kLVL.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    kLVL.Metadata_PLV AS EV_LVL_Metadata_PLV,
    LVL.EV_LVL_PLV_ID
FROM
    nexuses.EV_Event EV
LEFT JOIN
    TABLE(knots.eETY_EventType(0)) ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    attributes.EV_DAT_Event_Date DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_AUD_Event_Audience(0)) AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    attributes.EV_REV_Event_Revenue REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_STA_Event_Status(0)) STA
ON
    STA.EV_STA_EV_ID = EV.EV_ID
AND
    STA.EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            TABLE(attributes.eEV_STA_Event_Status(0)) sub 
        WHERE
            sub.EV_STA_EV_ID = EV.EV_ID
   )
LEFT JOIN
    attributes.EV_UTL_Event_Utilization UTL
ON
    UTL.EV_UTL_EV_ID = EV.EV_ID
LEFT JOIN
    knots.UTL_Utilization kUTL
ON
    kUTL.UTL_ID = UTL.EV_UTL_UTL_ID
LEFT JOIN
    attributes.EV_LVL_Event_Level LVL
ON
    LVL.EV_LVL_EV_ID = EV.EV_ID
AND
    LVL.EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            attributes.EV_LVL_Event_Level sub
        WHERE
            sub.EV_LVL_EV_ID = EV.EV_ID
   )
LEFT JOIN
    TABLE(knots.ePLV_ProfessionalLevel(0)) kLVL
ON
    kLVL.PLV_ID = LVL.EV_LVL_PLV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_ETY_EQ tinyint,
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD int,
    EV_AUD_EQ tinyint,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV int,
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA int,
    EV_STA_ChangedAt datetime,
    EV_STA_EQ tinyint,
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL int,
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL int,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL int,
    EV_LVL_ChangedAt date,
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_EQ tinyint,
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV int,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_Checksum AS of_ETY_Checksum,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    ETY_of.ETY_EQ AS of_ETY_EQ,
    ETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_EQ,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_Event_Revenue,
    STA.EV_STA_EV_ID,
    STA.Metadata_EV_STA,
    STA.EV_STA_ChangedAt,
    STA.EV_STA_EQ,
    STA.EV_STA_Event_Status,
    UTL.EV_UTL_EV_ID,
    UTL.Metadata_EV_UTL,
    kUTL.UTL_Utilization AS EV_UTL_UTL_Utilization,
    kUTL.Metadata_UTL AS EV_UTL_Metadata_UTL,
    UTL.EV_UTL_UTL_ID,
    LVL.EV_LVL_EV_ID,
    LVL.Metadata_EV_LVL,
    LVL.EV_LVL_ChangedAt,
    kLVL.PLV_Checksum AS EV_LVL_PLV_Checksum,
    kLVL.PLV_EQ AS EV_LVL_PLV_EQ,
    kLVL.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    kLVL.Metadata_PLV AS EV_LVL_Metadata_PLV,
    LVL.EV_LVL_PLV_ID
FROM
    nexuses.EV_Event EV
LEFT JOIN
    TABLE(knots.eETY_EventType(0)) ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    attributes.EV_DAT_Event_Date DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_AUD_Event_Audience(0)) AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    attributes.EV_REV_Event_Revenue REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.rEV_STA_Event_Status(0, changingTimepoint::datetime)) STA
ON
    STA.EV_STA_EV_ID = EV.EV_ID
AND
    STA.EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            TABLE(attributes.rEV_STA_Event_Status(0, changingTimepoint::datetime)) sub
        WHERE
            sub.EV_STA_EV_ID = EV.EV_ID
   )
LEFT JOIN
    attributes.EV_UTL_Event_Utilization UTL
ON
    UTL.EV_UTL_EV_ID = EV.EV_ID
LEFT JOIN
    knots.UTL_Utilization kUTL
ON
    kUTL.UTL_ID = UTL.EV_UTL_UTL_ID
LEFT JOIN
    TABLE(attributes.rEV_LVL_Event_Level(changingTimepoint::date)) LVL
ON
    LVL.EV_LVL_EV_ID = EV.EV_ID
AND
    LVL.EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            TABLE(attributes.rEV_LVL_Event_Level(changingTimepoint::date)) sub
        WHERE
            sub.EV_LVL_EV_ID = EV.EV_ID
   )
LEFT JOIN
    TABLE(knots.ePLV_ProfessionalLevel(0)) kLVL
ON
    kLVL.PLV_ID = LVL.EV_LVL_PLV_ID
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.nEV_Event AS
SELECT
    *
FROM
    TABLE(nexuses.pEV_Event(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.dEV_Event (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_ETY_EQ tinyint,
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD int,
    EV_AUD_EQ tinyint,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV int,
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA int,
    EV_STA_ChangedAt datetime,
    EV_STA_EQ tinyint,
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL int,
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL int,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL int,
    EV_LVL_ChangedAt date,
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_EQ tinyint,
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV int,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT DISTINCT
    hSTA.EV_STA_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'STA' AS mnemonic,
    pEV.EV_ID,
    pEV.Metadata_EV,
    pEV.ST_ID_wasHeldAt,
    pEV.PR_ID_wasPlayed,
    pEV.of_ETY_Checksum,
    pEV.of_ETY_EventType,
    pEV.of_ETY_EQ,
    pEV.of_Metadata_ETY,
    pEV.ETY_ID_of,
    pEV.EV_DAT_EV_ID,
    pEV.Metadata_EV_DAT,
    pEV.EV_DAT_Event_Date,
    pEV.EV_AUD_EV_ID,
    pEV.Metadata_EV_AUD,
    pEV.EV_AUD_EQ,
    pEV.EV_AUD_Event_Audience,
    pEV.EV_REV_EV_ID,
    pEV.Metadata_EV_REV,
    pEV.EV_REV_Event_Revenue,
    pEV.EV_STA_EV_ID,
    pEV.Metadata_EV_STA,
    pEV.EV_STA_ChangedAt,
    pEV.EV_STA_EQ,
    pEV.EV_STA_Event_Status,
    pEV.EV_UTL_EV_ID,
    pEV.Metadata_EV_UTL,
    pEV.EV_UTL_UTL_Utilization,
    pEV.EV_UTL_Metadata_UTL,
    pEV.EV_UTL_UTL_ID,
    pEV.EV_LVL_EV_ID,
    pEV.Metadata_EV_LVL,
    pEV.EV_LVL_ChangedAt,
    pEV.EV_LVL_PLV_Checksum,
    pEV.EV_LVL_PLV_EQ,
    pEV.EV_LVL_PLV_ProfessionalLevel,
    pEV.EV_LVL_Metadata_PLV,
    pEV.EV_LVL_PLV_ID
FROM
    TABLE(attributes.eEV_STA_Event_Status(0)) hSTA, 
    TABLE(nexuses.pEV_Event(hSTA.EV_STA_ChangedAt::timestamp_ntz(9))) pEV
WHERE
    (selection IS NULL OR selection LIKE '%STA%')
AND
    hSTA.EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pEV.EV_ID = hSTA.EV_STA_EV_ID
UNION
SELECT DISTINCT
    hLVL.EV_LVL_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'LVL' AS mnemonic,
    pEV.EV_ID,
    pEV.Metadata_EV,
    pEV.ST_ID_wasHeldAt,
    pEV.PR_ID_wasPlayed,
    pEV.of_ETY_Checksum,
    pEV.of_ETY_EventType,
    pEV.of_ETY_EQ,
    pEV.of_Metadata_ETY,
    pEV.ETY_ID_of,
    pEV.EV_DAT_EV_ID,
    pEV.Metadata_EV_DAT,
    pEV.EV_DAT_Event_Date,
    pEV.EV_AUD_EV_ID,
    pEV.Metadata_EV_AUD,
    pEV.EV_AUD_EQ,
    pEV.EV_AUD_Event_Audience,
    pEV.EV_REV_EV_ID,
    pEV.Metadata_EV_REV,
    pEV.EV_REV_Event_Revenue,
    pEV.EV_STA_EV_ID,
    pEV.Metadata_EV_STA,
    pEV.EV_STA_ChangedAt,
    pEV.EV_STA_EQ,
    pEV.EV_STA_Event_Status,
    pEV.EV_UTL_EV_ID,
    pEV.Metadata_EV_UTL,
    pEV.EV_UTL_UTL_Utilization,
    pEV.EV_UTL_Metadata_UTL,
    pEV.EV_UTL_UTL_ID,
    pEV.EV_LVL_EV_ID,
    pEV.Metadata_EV_LVL,
    pEV.EV_LVL_ChangedAt,
    pEV.EV_LVL_PLV_Checksum,
    pEV.EV_LVL_PLV_EQ,
    pEV.EV_LVL_PLV_ProfessionalLevel,
    pEV.EV_LVL_Metadata_PLV,
    pEV.EV_LVL_PLV_ID
FROM
    attributes.EV_LVL_Event_Level hLVL,
    TABLE(nexuses.pEV_Event(hLVL.EV_LVL_ChangedAt::timestamp_ntz(9))) pEV
WHERE
    (selection IS NULL OR selection LIKE '%LVL%')
AND
    hLVL.EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pEV.EV_ID = hLVL.EV_LVL_EV_ID
$$
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently (
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt,
    AC_ID_partner COMMENT 'One of the actors in the partnership.',
    AC_ID_with COMMENT 'The other actor in the partnership.',
    currently_ONG_Ongoing COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).',
    currently_Metadata_ONG,
    ONG_ID_currently COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).'
) COMMENT = 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.'
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
    ties.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    knots.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            ties.AC_partner_AC_with_ONG_currently sub
        WHERE
            sub.AC_ID_partner = tie.AC_ID_partner
        OR
            sub.AC_ID_with = tie.AC_ID_with
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner smallint,
    AC_ID_with smallint,
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
    ties.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    knots.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            ties.AC_partner_AC_with_ONG_currently sub
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
CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    TABLE(ties.pAC_partner_AC_with_ONG_currently(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner smallint,
    AC_ID_with smallint,
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
    ties.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    knots.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of (
    Metadata_AC_subset_PN_of,
    AC_ID_subset,
    PN_ID_of COMMENT 'The person who is the actor.'
) 
AS
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    ties.AC_subset_PN_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_ID_subset smallint,
    PN_ID_of bigint
)
AS
$$
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    ties.AC_subset_PN_of tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of AS
SELECT
    *
FROM
    TABLE(ties.pAC_subset_PN_of(current_timestamp()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast (
    Metadata_EV_in_AC_wasCast,
    EV_ID_in COMMENT 'The event the actor was cast in.',
    AC_ID_wasCast COMMENT 'An actor cast in the event.'
) COMMENT = 'The actors that were cast in an event, meaning those who performed at that performance.'
AS
SELECT
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    ties.EV_in_AC_wasCast tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_ID_in numeric(12,0),
    AC_ID_wasCast smallint
)
AS
$$
SELECT
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    ties.EV_in_AC_wasCast tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast AS
SELECT
    *
FROM
    TABLE(ties.pEV_in_AC_wasCast(current_timestamp()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got (
    Metadata_AC_part_PR_in_RAT_got,
    AC_part_PR_in_RAT_got_ChangedAt,
    AC_ID_part COMMENT 'The actor having a part in the program.',
    PR_ID_in COMMENT 'The program the actor has a part in.',
    got_RAT_Checksum,
    got_RAT_Rating COMMENT 'The rating the actor got for the part.',
    got_RAT_EQ,
    got_Metadata_RAT,
    RAT_ID_got COMMENT 'The rating the actor got for the part.'
) COMMENT = 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.'
AS
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Checksum AS got_RAT_Checksum,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.RAT_EQ AS got_RAT_EQ,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    ties.AC_part_PR_in_RAT_got tie
LEFT JOIN
    TABLE(knots.eRAT_Rating(0)) RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            ties.AC_part_PR_in_RAT_got sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    got_RAT_Checksum numeric(19,0),
    got_RAT_Rating varchar(42),
    got_RAT_EQ tinyint,
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
    RAT_got.RAT_Checksum AS got_RAT_Checksum,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.RAT_EQ AS got_RAT_EQ,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    ties.AC_part_PR_in_RAT_got tie
LEFT JOIN
    TABLE(knots.eRAT_Rating(0)) RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            ties.AC_part_PR_in_RAT_got sub
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
CREATE OR REPLACE VIEW ties.nAC_part_PR_in_RAT_got AS
SELECT
    *
FROM
    TABLE(ties.pAC_part_PR_in_RAT_got(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    got_RAT_Checksum numeric(19,0),
    got_RAT_Rating varchar(42),
    got_RAT_EQ tinyint,
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
    RAT_got.RAT_Checksum AS got_RAT_Checksum,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.RAT_EQ AS got_RAT_EQ,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    ties.AC_part_PR_in_RAT_got tie
LEFT JOIN
    TABLE(knots.eRAT_Rating(0)) RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying (
    Metadata_ST_at_PR_isPlaying,
    ST_at_PR_isPlaying_ChangedAt,
    ST_ID_at COMMENT 'The stage where the program is playing.',
    PR_ID_isPlaying COMMENT 'The program playing at the stage.'
) COMMENT = 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.'
AS
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    ties.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            ties.ST_at_PR_isPlaying sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying number(10,0)
)
AS
$$
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    ties.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            ties.ST_at_PR_isPlaying sub
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
CREATE OR REPLACE VIEW ties.nST_at_PR_isPlaying AS
SELECT
    *
FROM
    TABLE(ties.pST_at_PR_isPlaying(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying number(10,0)
)
AS
$$
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    ties.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having (
    Metadata_AC_parent_AC_child_PAT_having,
    AC_ID_parent COMMENT 'The actor who is the parent.',
    AC_ID_child COMMENT 'The actor who is the child.',
    having_PAT_ParentalType COMMENT 'The type of parental relationship.',
    having_PAT_EQ,
    having_Metadata_PAT,
    PAT_ID_having COMMENT 'The type of parental relationship.'
) COMMENT = 'Parent-child relationships between actors, along with the type of parental relationship.'
AS
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    PAT_having.PAT_EQ AS having_PAT_EQ,
    PAT_having.Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    ties.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    TABLE(knots.ePAT_ParentalType(0)) PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_ID_parent smallint,
    AC_ID_child smallint,
    having_PAT_ParentalType varchar(42),
    having_PAT_EQ tinyint,
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
    PAT_having.PAT_EQ AS having_PAT_EQ,
    PAT_having.Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    ties.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    TABLE(knots.ePAT_ParentalType(0)) PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having AS
SELECT
    *
FROM
    TABLE(ties.pAC_parent_AC_child_PAT_having(current_timestamp()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of (
    Metadata_PR_content_ST_location_EV_of,
    PR_content_ST_location_EV_of_ChangedAt,
    PR_ID_content COMMENT 'The program that made up the content of the event.',
    ST_ID_location COMMENT 'The stage where the event was located.',
    EV_ID_of COMMENT 'The event.'
) COMMENT = 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.'
AS
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_ChangedAt,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    ties.PR_content_ST_location_EV_of tie
WHERE
    tie.PR_content_ST_location_EV_of_ChangedAt = (
        SELECT
            max(sub.PR_content_ST_location_EV_of_ChangedAt)
        FROM
            ties.PR_content_ST_location_EV_of sub
        WHERE
            sub.PR_ID_content = tie.PR_ID_content
        OR
            sub.ST_ID_location = tie.ST_ID_location
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0)
)
AS
$$
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_ChangedAt,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    ties.PR_content_ST_location_EV_of tie
WHERE
    tie.PR_content_ST_location_EV_of_ChangedAt = (
        SELECT
            max(sub.PR_content_ST_location_EV_of_ChangedAt)
        FROM
            ties.PR_content_ST_location_EV_of sub
        WHERE
        (
            sub.PR_ID_content = tie.PR_ID_content
        OR
            sub.ST_ID_location = tie.ST_ID_location
        )
        AND
            sub.PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nPR_content_ST_location_EV_of AS
SELECT
    *
FROM
    TABLE(ties.pPR_content_ST_location_EV_of(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dPR_content_ST_location_EV_of (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0)
)
AS
$$
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_ChangedAt,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    ties.PR_content_ST_location_EV_of tie
WHERE
    tie.PR_content_ST_location_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers. Views get their comments when they are
-- created, since Snowflake does not allow comments on view columns to be added afterwards.
--
COMMENT ON SCHEMA dw IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE knots.PAT_ParentalType_ID IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE knots.GEN_Gender IS 'Gender of an actor.';
COMMENT ON COLUMN knots.GEN_Gender.GEN_Gender IS 'Gender of an actor.';
COMMENT ON TABLE knots.PLV_ProfessionalLevel_ID IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE knots.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN knots.UTL_Utilization.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE knots.ONG_Ongoing IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN knots.ONG_Ongoing.ONG_Ongoing IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE knots.RAT_Rating_ID IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN attributes.EV_DAT_Event_Date.EV_DAT_Event_Date IS 'Date and time when the event took place.';
COMMENT ON COLUMN attributes.EV_AUD_Event_Audience.EV_AUD_Event_Audience IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN attributes.EV_REV_Event_Revenue.EV_REV_Event_Revenue IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN attributes.EV_STA_Event_Status.EV_STA_Event_Status IS 'Status of the event, which may change until it has taken place.';
COMMENT ON COLUMN attributes.EV_LVL_Event_Level.EV_LVL_PLV_ID IS 'Professional level required for the event, over time.';
COMMENT ON COLUMN attributes.ST_NAM_Stage_Name.ST_NAM_Stage_Name IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN attributes.ST_LOC_Stage_Location.ST_LOC_Stage_Location IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN attributes.ST_AVG_Stage_Average.ST_AVG_UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN attributes.ST_MIN_Stage_Minimum.ST_MIN_UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN attributes.AC_NAM_Actor_Name.AC_NAM_Actor_Name IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN attributes.AC_GEN_Actor_Gender.AC_GEN_GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN attributes.AC_PLV_Actor_ProfessionalLevel.AC_PLV_PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN attributes.PR_NAM_Program_Name.PR_NAM_Program_Name IS 'Name or title of the program.';
COMMENT ON COLUMN attributes.PR_LEN_Program_Length.PR_LEN_Program_Length IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE anchors.PN_Person IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE anchors.ST_Stage IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE anchors.AC_Actor IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE nexuses.EV_Event IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN nexuses.EV_Event.ST_ID_wasHeldAt IS 'The stage at which the event was held.';
COMMENT ON COLUMN nexuses.EV_Event.PR_ID_wasPlayed IS 'The program that was played at the event.';
COMMENT ON TABLE ties.AC_partner_AC_with_ONG_currently IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently.AC_ID_partner IS 'One of the actors in the partnership.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently.AC_ID_with IS 'The other actor in the partnership.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently.ONG_ID_currently IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON COLUMN ties.AC_subset_PN_of.PN_ID_of IS 'The person who is the actor.';
COMMENT ON TABLE ties.EV_in_AC_wasCast IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN ties.EV_in_AC_wasCast.EV_ID_in IS 'The event the actor was cast in.';
COMMENT ON COLUMN ties.EV_in_AC_wasCast.AC_ID_wasCast IS 'An actor cast in the event.';
COMMENT ON TABLE ties.AC_part_PR_in_RAT_got IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN ties.AC_part_PR_in_RAT_got.AC_ID_part IS 'The actor having a part in the program.';
COMMENT ON COLUMN ties.AC_part_PR_in_RAT_got.PR_ID_in IS 'The program the actor has a part in.';
COMMENT ON COLUMN ties.AC_part_PR_in_RAT_got.RAT_ID_got IS 'The rating the actor got for the part.';
COMMENT ON TABLE ties.ST_at_PR_isPlaying IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ties.ST_at_PR_isPlaying.ST_ID_at IS 'The stage where the program is playing.';
COMMENT ON COLUMN ties.ST_at_PR_isPlaying.PR_ID_isPlaying IS 'The program playing at the stage.';
COMMENT ON TABLE ties.AC_parent_AC_child_PAT_having IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN ties.AC_parent_AC_child_PAT_having.AC_ID_parent IS 'The actor who is the parent.';
COMMENT ON COLUMN ties.AC_parent_AC_child_PAT_having.AC_ID_child IS 'The actor who is the child.';
COMMENT ON COLUMN ties.AC_parent_AC_child_PAT_having.PAT_ID_having IS 'The type of parental relationship.';
COMMENT ON TABLE ties.PR_content_ST_location_EV_of IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN ties.PR_content_ST_location_EV_of.PR_ID_content IS 'The program that made up the content of the event.';
COMMENT ON COLUMN ties.PR_content_ST_location_EV_of.ST_ID_location IS 'The stage where the event was located.';
COMMENT ON COLUMN ties.PR_content_ST_location_EV_of.EV_ID_of IS 'The event.';
