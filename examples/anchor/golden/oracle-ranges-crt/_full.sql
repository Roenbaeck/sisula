-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw._Who (
    Who number(5) not null,
    constraint pk_Who primary key (
        Who
    )
);
MERGE INTO dw._Who p
USING ( SELECT 0 AS _defaultPositor ) d
ON (
    d._defaultPositor = p.Who
)
WHEN NOT MATCHED THEN
INSERT (
    Who
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
CREATE TABLE IF NOT EXISTS knots.PAT_ParentalType (
    PAT_ID number(3) not null,
    PAT_ParentalType nvarchar2(42) not null,
    Metadata_PAT number(19) not null,
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
    GEN_ID number(3) not null,
    GEN_Gender nvarchar2(42) not null,
    GEN_Checksum numeric(19,0) default hash(GEN_Gender),
    Metadata_GEN number(19) not null,
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
    PLV_ID number(3) not null,
    PLV_ProfessionalLevel nclob not null,
    PLV_Checksum numeric(19,0) default hash(PLV_ProfessionalLevel),
    Metadata_PLV number(19) not null,
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
    UTL_ID number(3) not null,
    UTL_Utilization number(3) not null,
    Metadata_UTL number(19) not null,
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
    ONG_ID number(3) not null,
    ONG_Ongoing nvarchar2(3) not null,
    Metadata_ONG number(19) not null,
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
CREATE TABLE IF NOT EXISTS knots.RAT_Rating (
    RAT_ID number(3) IDENTITY(1,1) not null, 
    RAT_Rating nvarchar2(42) not null,
    RAT_Checksum numeric(19,0) default hash(RAT_Rating),
    Metadata_RAT number(19) not null,
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
    ETY_ID number(3) not null,
    ETY_EventType nvarchar2(42) not null,
    ETY_Checksum numeric(19,0) default hash(ETY_EventType),
    Metadata_ETY number(19) not null,
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
CREATE TABLE IF NOT EXISTS anchors.PN_Person (
    PN_ID number(19) IDENTITY(1,1) not null, 
    Metadata_PN number(19) not null, 
    constraint pkPN_Person primary key (
        PN_ID
    )
) CLUSTER BY (PN_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.ST_Stage (
    ST_ID number(10) not null,
    Metadata_ST number(19) not null, 
    constraint pkST_Stage primary key (
        ST_ID
    )
) CLUSTER BY (ST_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.AC_Actor (
    AC_ID number(5) IDENTITY(1,1) not null, 
    Metadata_AC number(19) not null, 
    constraint pkAC_Actor primary key (
        AC_ID
    )
) CLUSTER BY (AC_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.PR_Program (
    PR_ID number(19) not null,
    Metadata_PR number(19) not null, 
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
    EV_ID number(12,0) not null,
    ST_ID_wasHeldAt number(10) not null, 
    PR_ID_wasPlayed number(19) not null, 
    ETY_ID_of number(3) not null,
    constraint EV_Event_fkST_wasHeldAt foreign key (
        ST_ID_wasHeldAt
    ) references anchors.ST_Stage(ST_ID), 
    constraint EV_Event_fkPR_wasPlayed foreign key (
        PR_ID_wasPlayed
    ) references anchors.PR_Program(PR_ID), 
    constraint EV_Event_fkETY_of foreign key (
        ETY_ID_of
    ) references knots.ETY_EventType(ETY_ID),
    Metadata_EV number(19) not null, 
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
-- EV_DAT_Event_Date_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_DAT_Event_Date_Fact (
    EV_DAT_ID number(19) IDENTITY(1,1) not null, 
    EV_DAT_EV_ID number(12,0) not null,
    EV_DAT_Event_Date timestamp not null,
    constraint fkEV_DAT_Event_Date_Fact foreign key (
        EV_DAT_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint pkEV_DAT_Event_Date_Fact primary key (
        EV_DAT_ID
    ),
    constraint uqEV_DAT_Event_Date_Fact unique (
        EV_DAT_EV_ID,
        EV_DAT_Event_Date
    )
) CLUSTER BY (EV_DAT_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Meta table (of EV_DAT_Event_Date_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_DAT_Event_Date_Meta (
    EV_DAT_ID number(19) not null,
    EV_DAT_PositedAt timestamp(3) not null,
    EV_DAT_Who number(5) not null,
    EV_DAT_Confidence number(7,3) not null,
    EV_DAT_Stance varchar2(4000) default (
        case
            when EV_DAT_Confidence > 0.25 then '+'
            when EV_DAT_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_DAT_Confidence <  then 0
            else 1
        end
    ),
    Metadata_EV_DAT number(19) not null,
    constraint fkEV_DAT_Event_Date_Meta foreign key (
        EV_DAT_ID
    ) references attributes.EV_DAT_Event_Date_Fact(EV_DAT_ID),
    constraint pkEV_DAT_Event_Date_Meta primary key (
        EV_DAT_ID,
        EV_DAT_Who,
        EV_DAT_PositedAt
    )
) CLUSTER BY (EV_DAT_ID, EV_DAT_Who, EV_DAT_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_AUD_Event_Audience_Fact (
    EV_AUD_ID number(19) IDENTITY(1,1) not null, 
    EV_AUD_EV_ID number(12,0) not null,
    EV_AUD_Event_Audience number(10) not null,
    constraint fkEV_AUD_Event_Audience_Fact foreign key (
        EV_AUD_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint pkEV_AUD_Event_Audience_Fact primary key (
        EV_AUD_ID
    ),
    constraint uqEV_AUD_Event_Audience_Fact unique (
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    )
) CLUSTER BY (EV_AUD_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Meta table (of EV_AUD_Event_Audience_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_AUD_Event_Audience_Meta (
    EV_AUD_ID number(19) not null,
    EV_AUD_PositedAt timestamp(3) not null,
    EV_AUD_Who number(5) not null,
    EV_AUD_Confidence number(7,3) not null,
    EV_AUD_Stance varchar2(4000) default (
        case
            when EV_AUD_Confidence > 0.25 then '+'
            when EV_AUD_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_AUD_Confidence <  then 0
            else 1
        end
    ),
    Metadata_EV_AUD number(19) not null,
    constraint fkEV_AUD_Event_Audience_Meta foreign key (
        EV_AUD_ID
    ) references attributes.EV_AUD_Event_Audience_Fact(EV_AUD_ID),
    constraint pkEV_AUD_Event_Audience_Meta primary key (
        EV_AUD_ID,
        EV_AUD_Who,
        EV_AUD_PositedAt
    )
) CLUSTER BY (EV_AUD_ID, EV_AUD_Who, EV_AUD_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_REV_Event_Revenue_Fact (
    EV_REV_ID number(19) IDENTITY(1,1) not null, 
    EV_REV_EV_ID number(12,0) not null,
    EV_REV_Event_Revenue number(19,4) not null,
    constraint fkEV_REV_Event_Revenue_Fact foreign key (
        EV_REV_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint pkEV_REV_Event_Revenue_Fact primary key (
        EV_REV_ID
    ),
    constraint uqEV_REV_Event_Revenue_Fact unique (
        EV_REV_EV_ID,
        EV_REV_Event_Revenue
    )
) CLUSTER BY (EV_REV_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Meta table (of EV_REV_Event_Revenue_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_REV_Event_Revenue_Meta (
    EV_REV_ID number(19) not null,
    EV_REV_PositedAt timestamp(3) not null,
    EV_REV_Who number(5) not null,
    EV_REV_Confidence number(7,3) not null,
    EV_REV_Stance varchar2(4000) default (
        case
            when EV_REV_Confidence > 0.25 then '+'
            when EV_REV_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_REV_Confidence <  then 0
            else 1
        end
    ),
    Metadata_EV_REV number(19) not null,
    constraint fkEV_REV_Event_Revenue_Meta foreign key (
        EV_REV_ID
    ) references attributes.EV_REV_Event_Revenue_Fact(EV_REV_ID),
    constraint pkEV_REV_Event_Revenue_Meta primary key (
        EV_REV_ID,
        EV_REV_Who,
        EV_REV_PositedAt
    )
) CLUSTER BY (EV_REV_ID, EV_REV_Who, EV_REV_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Event_Status_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_STA_Event_Status_Fact (
    EV_STA_ID number(19) IDENTITY(1,1) not null, 
    EV_STA_EV_ID number(12,0) not null,
    EV_STA_Event_Status nvarchar2(20) not null,
    EV_STA_ChangedAt timestamp not null,
    constraint fkEV_STA_Event_Status_Fact foreign key (
        EV_STA_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint pkEV_STA_Event_Status_Fact primary key (
        EV_STA_ID
    ),
    constraint uqEV_STA_Event_Status_Fact unique (
        EV_STA_EV_ID,
        EV_STA_ChangedAt,
        EV_STA_Event_Status
    )
) CLUSTER BY (EV_STA_EV_ID, EV_STA_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Event_Status_Meta table (of EV_STA_Event_Status_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_STA_Event_Status_Meta (
    EV_STA_ID number(19) not null,
    EV_STA_PositedAt timestamp(3) not null,
    EV_STA_Who number(5) not null,
    EV_STA_Confidence number(7,3) not null,
    EV_STA_Stance varchar2(4000) default (
        case
            when EV_STA_Confidence > 0.25 then '+'
            when EV_STA_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_STA_Confidence <  then 0
            else 1
        end
    ),
    Metadata_EV_STA number(19) not null,
    constraint fkEV_STA_Event_Status_Meta foreign key (
        EV_STA_ID
    ) references attributes.EV_STA_Event_Status_Fact(EV_STA_ID),
    constraint pkEV_STA_Event_Status_Meta primary key (
        EV_STA_ID,
        EV_STA_Who,
        EV_STA_PositedAt
    )
) CLUSTER BY (EV_STA_ID, EV_STA_Who, EV_STA_PositedAt);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_UTL_Event_Utilization_Fact (
    EV_UTL_ID number(19) IDENTITY(1,1) not null, 
    EV_UTL_EV_ID number(12,0) not null,
    EV_UTL_UTL_ID number(3) not null,
    constraint fk_A_EV_UTL_Event_Utilization_Fact foreign key (
        EV_UTL_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint fk_K_EV_UTL_Event_Utilization_Fact foreign key (
        EV_UTL_UTL_ID
    ) references knots.UTL_Utilization(UTL_ID),
    constraint pkEV_UTL_Event_Utilization_Fact primary key (
        EV_UTL_ID
    ),
    constraint uqEV_UTL_Event_Utilization_Fact unique (
        EV_UTL_EV_ID,
        EV_UTL_UTL_ID
    )
) CLUSTER BY (EV_UTL_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Meta table (of EV_UTL_Event_Utilization_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_UTL_Event_Utilization_Meta (
    EV_UTL_ID number(19) not null,
    EV_UTL_PositedAt timestamp(3) not null,
    EV_UTL_Who number(5) not null,
    EV_UTL_Confidence number(7,3) not null,
    EV_UTL_Stance varchar2(4000) default (
        case
            when EV_UTL_Confidence > 0.25 then '+'
            when EV_UTL_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_UTL_Confidence <  then 0
            else 1
        end
    ),
    Metadata_EV_UTL number(19) not null,
    constraint fkEV_UTL_Event_Utilization_Meta foreign key (
        EV_UTL_ID
    ) references attributes.EV_UTL_Event_Utilization_Fact(EV_UTL_ID),
    constraint pkEV_UTL_Event_Utilization_Meta primary key (
        EV_UTL_ID,
        EV_UTL_Who,
        EV_UTL_PositedAt
    )
) CLUSTER BY (EV_UTL_ID, EV_UTL_Who, EV_UTL_PositedAt);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Event_Level_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_LVL_Event_Level_Fact (
    EV_LVL_ID number(19) IDENTITY(1,1) not null, 
    EV_LVL_EV_ID number(12,0) not null,
    EV_LVL_PLV_ID number(3) not null,
    EV_LVL_ChangedAt date not null,
    constraint fk_A_EV_LVL_Event_Level_Fact foreign key (
        EV_LVL_EV_ID
    ) references nexuses.EV_Event(EV_ID),
    constraint fk_K_EV_LVL_Event_Level_Fact foreign key (
        EV_LVL_PLV_ID
    ) references knots.PLV_ProfessionalLevel(PLV_ID),
    constraint pkEV_LVL_Event_Level_Fact primary key (
        EV_LVL_ID
    ),
    constraint uqEV_LVL_Event_Level_Fact unique (
        EV_LVL_EV_ID,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    )
) CLUSTER BY (EV_LVL_EV_ID, EV_LVL_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Event_Level_Meta table (of EV_LVL_Event_Level_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_LVL_Event_Level_Meta (
    EV_LVL_ID number(19) not null,
    EV_LVL_PositedAt timestamp(3) not null,
    EV_LVL_Who number(5) not null,
    EV_LVL_Confidence number(7,3) not null,
    EV_LVL_Stance varchar2(4000) default (
        case
            when EV_LVL_Confidence > 0.25 then '+'
            when EV_LVL_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_LVL_Confidence <  then 0
            else 1
        end
    ),
    Metadata_EV_LVL number(19) not null,
    constraint fkEV_LVL_Event_Level_Meta foreign key (
        EV_LVL_ID
    ) references attributes.EV_LVL_Event_Level_Fact(EV_LVL_ID),
    constraint pkEV_LVL_Event_Level_Meta primary key (
        EV_LVL_ID,
        EV_LVL_Who,
        EV_LVL_PositedAt
    )
) CLUSTER BY (EV_LVL_ID, EV_LVL_Who, EV_LVL_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_NAM_Stage_Name_Fact (
    ST_NAM_ID number(19) IDENTITY(1,1) not null, 
    ST_NAM_ST_ID number(10) not null,
    ST_NAM_Stage_Name nvarchar2(42) not null,
    ST_NAM_ChangedAt timestamp not null,
    constraint fkST_NAM_Stage_Name_Fact foreign key (
        ST_NAM_ST_ID
    ) references anchors.ST_Stage(ST_ID),
    constraint pkST_NAM_Stage_Name_Fact primary key (
        ST_NAM_ID
    ),
    constraint uqST_NAM_Stage_Name_Fact unique (
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
) CLUSTER BY (ST_NAM_ST_ID, ST_NAM_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Meta table (of ST_NAM_Stage_Name_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_NAM_Stage_Name_Meta (
    ST_NAM_ID number(19) not null,
    ST_NAM_PositedAt timestamp(3) not null,
    ST_NAM_Who number(5) not null,
    ST_NAM_Confidence number(7,3) not null,
    ST_NAM_Stance varchar2(4000) default (
        case
            when ST_NAM_Confidence > 0.25 then '+'
            when ST_NAM_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_NAM_Confidence <  then 0
            else 1
        end
    ),
    Metadata_ST_NAM number(19) not null,
    constraint fkST_NAM_Stage_Name_Meta foreign key (
        ST_NAM_ID
    ) references attributes.ST_NAM_Stage_Name_Fact(ST_NAM_ID),
    constraint pkST_NAM_Stage_Name_Meta primary key (
        ST_NAM_ID,
        ST_NAM_Who,
        ST_NAM_PositedAt
    )
) CLUSTER BY (ST_NAM_ID, ST_NAM_Who, ST_NAM_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_LOC_Stage_Location_Fact (
    ST_LOC_ID number(19) IDENTITY(1,1) not null, 
    ST_LOC_ST_ID number(10) not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum numeric(19,0) default hash(ST_LOC_Stage_Location),
    constraint fkST_LOC_Stage_Location_Fact foreign key (
        ST_LOC_ST_ID
    ) references anchors.ST_Stage(ST_ID),
    constraint pkST_LOC_Stage_Location_Fact primary key (
        ST_LOC_ID
    ),
    constraint uqST_LOC_Stage_Location_Fact unique (
        ST_LOC_ST_ID,
        ST_LOC_Checksum 
    )
) CLUSTER BY (ST_LOC_ST_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Meta table (of ST_LOC_Stage_Location_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_LOC_Stage_Location_Meta (
    ST_LOC_ID number(19) not null,
    ST_LOC_PositedAt timestamp(3) not null,
    ST_LOC_Who number(5) not null,
    ST_LOC_Confidence number(7,3) not null,
    ST_LOC_Stance varchar2(4000) default (
        case
            when ST_LOC_Confidence > 0.25 then '+'
            when ST_LOC_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_LOC_Confidence <  then 0
            else 1
        end
    ),
    Metadata_ST_LOC number(19) not null,
    constraint fkST_LOC_Stage_Location_Meta foreign key (
        ST_LOC_ID
    ) references attributes.ST_LOC_Stage_Location_Fact(ST_LOC_ID),
    constraint pkST_LOC_Stage_Location_Meta primary key (
        ST_LOC_ID,
        ST_LOC_Who,
        ST_LOC_PositedAt
    )
) CLUSTER BY (ST_LOC_ID, ST_LOC_Who, ST_LOC_PositedAt);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_AVG_Stage_Average_Fact (
    ST_AVG_ID number(19) IDENTITY(1,1) not null, 
    ST_AVG_ST_ID number(10) not null,
    ST_AVG_UTL_ID number(3) not null,
    ST_AVG_ChangedAt timestamp not null,
    constraint fk_A_ST_AVG_Stage_Average_Fact foreign key (
        ST_AVG_ST_ID
    ) references anchors.ST_Stage(ST_ID),
    constraint fk_K_ST_AVG_Stage_Average_Fact foreign key (
        ST_AVG_UTL_ID
    ) references knots.UTL_Utilization(UTL_ID),
    constraint pkST_AVG_Stage_Average_Fact primary key (
        ST_AVG_ID
    ),
    constraint uqST_AVG_Stage_Average_Fact unique (
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
) CLUSTER BY (ST_AVG_ST_ID, ST_AVG_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Meta table (of ST_AVG_Stage_Average_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_AVG_Stage_Average_Meta (
    ST_AVG_ID number(19) not null,
    ST_AVG_PositedAt timestamp(3) not null,
    ST_AVG_Who number(5) not null,
    ST_AVG_Confidence number(7,3) not null,
    ST_AVG_Stance varchar2(4000) default (
        case
            when ST_AVG_Confidence > 0.25 then '+'
            when ST_AVG_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_AVG_Confidence <  then 0
            else 1
        end
    ),
    Metadata_ST_AVG number(19) not null,
    constraint fkST_AVG_Stage_Average_Meta foreign key (
        ST_AVG_ID
    ) references attributes.ST_AVG_Stage_Average_Fact(ST_AVG_ID),
    constraint pkST_AVG_Stage_Average_Meta primary key (
        ST_AVG_ID,
        ST_AVG_Who,
        ST_AVG_PositedAt
    )
) CLUSTER BY (ST_AVG_ID, ST_AVG_Who, ST_AVG_PositedAt);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_MIN_Stage_Minimum_Fact (
    ST_MIN_ID number(19) IDENTITY(1,1) not null, 
    ST_MIN_ST_ID number(10) not null,
    ST_MIN_UTL_ID number(3) not null,
    constraint fk_A_ST_MIN_Stage_Minimum_Fact foreign key (
        ST_MIN_ST_ID
    ) references anchors.ST_Stage(ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum_Fact foreign key (
        ST_MIN_UTL_ID
    ) references knots.UTL_Utilization(UTL_ID),
    constraint pkST_MIN_Stage_Minimum_Fact primary key (
        ST_MIN_ID
    ),
    constraint uqST_MIN_Stage_Minimum_Fact unique (
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
) CLUSTER BY (ST_MIN_ST_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Meta table (of ST_MIN_Stage_Minimum_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_MIN_Stage_Minimum_Meta (
    ST_MIN_ID number(19) not null,
    ST_MIN_PositedAt timestamp(3) not null,
    ST_MIN_Who number(5) not null,
    ST_MIN_Confidence number(7,3) not null,
    ST_MIN_Stance varchar2(4000) default (
        case
            when ST_MIN_Confidence > 0.25 then '+'
            when ST_MIN_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_MIN_Confidence <  then 0
            else 1
        end
    ),
    Metadata_ST_MIN number(19) not null,
    constraint fkST_MIN_Stage_Minimum_Meta foreign key (
        ST_MIN_ID
    ) references attributes.ST_MIN_Stage_Minimum_Fact(ST_MIN_ID),
    constraint pkST_MIN_Stage_Minimum_Meta primary key (
        ST_MIN_ID,
        ST_MIN_Who,
        ST_MIN_PositedAt
    )
) CLUSTER BY (ST_MIN_ID, ST_MIN_Who, ST_MIN_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_NAM_Actor_Name_Fact (
    AC_NAM_ID number(19) IDENTITY(1,1) not null, 
    AC_NAM_AC_ID number(5) not null,
    AC_NAM_Actor_Name nvarchar2(42) not null,
    AC_NAM_ChangedAt timestamp not null,
    constraint fkAC_NAM_Actor_Name_Fact foreign key (
        AC_NAM_AC_ID
    ) references anchors.AC_Actor(AC_ID),
    constraint pkAC_NAM_Actor_Name_Fact primary key (
        AC_NAM_ID
    ),
    constraint uqAC_NAM_Actor_Name_Fact unique (
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
) CLUSTER BY (AC_NAM_AC_ID, AC_NAM_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Meta table (of AC_NAM_Actor_Name_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_NAM_Actor_Name_Meta (
    AC_NAM_ID number(19) not null,
    AC_NAM_PositedAt timestamp(3) not null,
    AC_NAM_Who number(5) not null,
    AC_NAM_Confidence number(7,3) not null,
    AC_NAM_Stance varchar2(4000) default (
        case
            when AC_NAM_Confidence > 0.25 then '+'
            when AC_NAM_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_NAM_Confidence <  then 0
            else 1
        end
    ),
    Metadata_AC_NAM number(19) not null,
    constraint fkAC_NAM_Actor_Name_Meta foreign key (
        AC_NAM_ID
    ) references attributes.AC_NAM_Actor_Name_Fact(AC_NAM_ID),
    constraint pkAC_NAM_Actor_Name_Meta primary key (
        AC_NAM_ID,
        AC_NAM_Who,
        AC_NAM_PositedAt
    )
) CLUSTER BY (AC_NAM_ID, AC_NAM_Who, AC_NAM_PositedAt);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_GEN_Actor_Gender_Fact (
    AC_GEN_ID number(19) IDENTITY(1,1) not null, 
    AC_GEN_AC_ID number(5) not null,
    AC_GEN_GEN_ID number(3) not null,
    constraint fk_A_AC_GEN_Actor_Gender_Fact foreign key (
        AC_GEN_AC_ID
    ) references anchors.AC_Actor(AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender_Fact foreign key (
        AC_GEN_GEN_ID
    ) references knots.GEN_Gender(GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Fact primary key (
        AC_GEN_ID
    ),
    constraint uqAC_GEN_Actor_Gender_Fact unique (
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
) CLUSTER BY (AC_GEN_AC_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Meta table (of AC_GEN_Actor_Gender_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_GEN_Actor_Gender_Meta (
    AC_GEN_ID number(19) not null,
    AC_GEN_PositedAt timestamp(3) not null,
    AC_GEN_Who number(5) not null,
    AC_GEN_Confidence number(7,3) not null,
    AC_GEN_Stance varchar2(4000) default (
        case
            when AC_GEN_Confidence > 0.25 then '+'
            when AC_GEN_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_GEN_Confidence <  then 0
            else 1
        end
    ),
    Metadata_AC_GEN number(19) not null,
    constraint fkAC_GEN_Actor_Gender_Meta foreign key (
        AC_GEN_ID
    ) references attributes.AC_GEN_Actor_Gender_Fact(AC_GEN_ID),
    constraint pkAC_GEN_Actor_Gender_Meta primary key (
        AC_GEN_ID,
        AC_GEN_Who,
        AC_GEN_PositedAt
    )
) CLUSTER BY (AC_GEN_ID, AC_GEN_Who, AC_GEN_PositedAt);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_PLV_Actor_ProfessionalLevel_Fact (
    AC_PLV_ID number(19) IDENTITY(1,1) not null, 
    AC_PLV_AC_ID number(5) not null,
    AC_PLV_PLV_ID number(3) not null,
    AC_PLV_ChangedAt timestamp not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel_Fact foreign key (
        AC_PLV_AC_ID
    ) references anchors.AC_Actor(AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel_Fact foreign key (
        AC_PLV_PLV_ID
    ) references knots.PLV_ProfessionalLevel(PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Fact primary key (
        AC_PLV_ID
    ),
    constraint uqAC_PLV_Actor_ProfessionalLevel_Fact unique (
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
) CLUSTER BY (AC_PLV_AC_ID, AC_PLV_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Meta table (of AC_PLV_Actor_ProfessionalLevel_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
    AC_PLV_ID number(19) not null,
    AC_PLV_PositedAt timestamp(3) not null,
    AC_PLV_Who number(5) not null,
    AC_PLV_Confidence number(7,3) not null,
    AC_PLV_Stance varchar2(4000) default (
        case
            when AC_PLV_Confidence > 0.25 then '+'
            when AC_PLV_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_PLV_Confidence <  then 0
            else 1
        end
    ),
    Metadata_AC_PLV number(19) not null,
    constraint fkAC_PLV_Actor_ProfessionalLevel_Meta foreign key (
        AC_PLV_ID
    ) references attributes.AC_PLV_Actor_ProfessionalLevel_Fact(AC_PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel_Meta primary key (
        AC_PLV_ID,
        AC_PLV_Who,
        AC_PLV_PositedAt
    )
) CLUSTER BY (AC_PLV_ID, AC_PLV_Who, AC_PLV_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Fact table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.PR_NAM_Program_Name_Fact (
    PR_NAM_ID number(19) IDENTITY(1,1) not null, 
    PR_NAM_PR_ID number(19) not null,
    PR_NAM_Program_Name nvarchar2(42) not null,
    constraint fkPR_NAM_Program_Name_Fact foreign key (
        PR_NAM_PR_ID
    ) references anchors.PR_Program(PR_ID),
    constraint pkPR_NAM_Program_Name_Fact primary key (
        PR_NAM_ID
    ),
    constraint uqPR_NAM_Program_Name_Fact unique (
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    )
) CLUSTER BY (PR_NAM_PR_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Meta table (of PR_NAM_Program_Name_Fact on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.PR_NAM_Program_Name_Meta (
    PR_NAM_ID number(19) not null,
    PR_NAM_PositedAt timestamp(3) not null,
    PR_NAM_Who number(5) not null,
    PR_NAM_Confidence number(7,3) not null,
    PR_NAM_Stance varchar2(4000) default (
        case
            when PR_NAM_Confidence > 0.25 then '+'
            when PR_NAM_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when PR_NAM_Confidence <  then 0
            else 1
        end
    ),
    Metadata_PR_NAM number(19) not null,
    constraint fkPR_NAM_Program_Name_Meta foreign key (
        PR_NAM_ID
    ) references attributes.PR_NAM_Program_Name_Fact(PR_NAM_ID),
    constraint pkPR_NAM_Program_Name_Meta primary key (
        PR_NAM_ID,
        PR_NAM_Who,
        PR_NAM_PositedAt
    )
) CLUSTER BY (PR_NAM_ID, PR_NAM_Who, PR_NAM_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Fact table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.PR_LEN_Program_Length_Fact (
    PR_LEN_ID number(19) IDENTITY(1,1) not null, 
    PR_LEN_PR_ID number(19) not null,
    PR_LEN_Program_Length timestamp not null,
    PR_LEN_ChangedAt date not null,
    constraint fkPR_LEN_Program_Length_Fact foreign key (
        PR_LEN_PR_ID
    ) references anchors.PR_Program(PR_ID),
    constraint pkPR_LEN_Program_Length_Fact primary key (
        PR_LEN_ID
    ),
    constraint uqPR_LEN_Program_Length_Fact unique (
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
) CLUSTER BY (PR_LEN_PR_ID, PR_LEN_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Meta table (of PR_LEN_Program_Length_Fact on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.PR_LEN_Program_Length_Meta (
    PR_LEN_ID number(19) not null,
    PR_LEN_PositedAt timestamp(3) not null,
    PR_LEN_Who number(5) not null,
    PR_LEN_Confidence number(7,3) not null,
    PR_LEN_Stance varchar2(4000) default (
        case
            when PR_LEN_Confidence > 0.25 then '+'
            when PR_LEN_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when PR_LEN_Confidence <  then 0
            else 1
        end
    ),
    Metadata_PR_LEN number(19) not null,
    constraint fkPR_LEN_Program_Length_Meta foreign key (
        PR_LEN_ID
    ) references attributes.PR_LEN_Program_Length_Fact(PR_LEN_ID),
    constraint pkPR_LEN_Program_Length_Meta primary key (
        PR_LEN_ID,
        PR_LEN_Who,
        PR_LEN_PositedAt
    )
) CLUSTER BY (PR_LEN_ID, PR_LEN_Who, PR_LEN_PositedAt);
-- ATTRIBUTE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views. These provide a stable baseline
-- for perspectives and can later be expanded to parameterized SQL macros.
--
CREATE OR REPLACE VIEW attributes.rEV_DAT_Event_Date AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Who,
    a.EV_DAT_Confidence,
    a.EV_DAT_Stance,
    a.,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date
FROM
    attributes.EV_DAT_Event_Date_Fact p
JOIN
    attributes.EV_DAT_Event_Date_Meta a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
WHERE
    a.EV_DAT_Who = 0
AND
    a.EV_DAT_PositedAt = (
        SELECT
            MAX(sub.EV_DAT_PositedAt)
        FROM
            attributes.EV_DAT_Event_Date_Meta sub
        WHERE
            sub.EV_DAT_ID = p.EV_DAT_ID
        AND
            sub.EV_DAT_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_AUD_Event_Audience AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Who,
    a.EV_AUD_Confidence,
    a.EV_AUD_Stance,
    a.,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience
FROM
    attributes.EV_AUD_Event_Audience_Fact p
JOIN
    attributes.EV_AUD_Event_Audience_Meta a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
WHERE
    a.EV_AUD_Who = 0
AND
    a.EV_AUD_PositedAt = (
        SELECT
            MAX(sub.EV_AUD_PositedAt)
        FROM
            attributes.EV_AUD_Event_Audience_Meta sub
        WHERE
            sub.EV_AUD_ID = p.EV_AUD_ID
        AND
            sub.EV_AUD_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_REV_Event_Revenue AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    a.EV_REV_PositedAt,
    a.EV_REV_Who,
    a.EV_REV_Confidence,
    a.EV_REV_Stance,
    a.,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue
FROM
    attributes.EV_REV_Event_Revenue_Fact p
JOIN
    attributes.EV_REV_Event_Revenue_Meta a
ON
    a.EV_REV_ID = p.EV_REV_ID
WHERE
    a.EV_REV_Who = 0
AND
    a.EV_REV_PositedAt = (
        SELECT
            MAX(sub.EV_REV_PositedAt)
        FROM
            attributes.EV_REV_Event_Revenue_Meta sub
        WHERE
            sub.EV_REV_ID = p.EV_REV_ID
        AND
            sub.EV_REV_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_STA_Event_Status AS
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    a.EV_STA_PositedAt,
    a.EV_STA_Who,
    a.EV_STA_Confidence,
    a.EV_STA_Stance,
    a.,
    p.EV_STA_EV_ID,
    p.EV_STA_Event_Status
    , p.EV_STA_ChangedAt
FROM
    attributes.EV_STA_Event_Status_Fact p
JOIN
    attributes.EV_STA_Event_Status_Meta a
ON
    a.EV_STA_ID = p.EV_STA_ID
WHERE
    a.EV_STA_Who = 0
AND
    a.EV_STA_PositedAt = (
        SELECT
            MAX(sub.EV_STA_PositedAt)
        FROM
            attributes.EV_STA_Event_Status_Meta sub
        WHERE
            sub.EV_STA_ID = p.EV_STA_ID
        AND
            sub.EV_STA_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_UTL_Event_Utilization AS
SELECT
    a.Metadata_EV_UTL,
    p.EV_UTL_ID,
    a.EV_UTL_PositedAt,
    a.EV_UTL_Who,
    a.EV_UTL_Confidence,
    a.EV_UTL_Stance,
    a.,
    p.EV_UTL_EV_ID,
    p.EV_UTL_UTL_ID
FROM
    attributes.EV_UTL_Event_Utilization_Fact p
JOIN
    attributes.EV_UTL_Event_Utilization_Meta a
ON
    a.EV_UTL_ID = p.EV_UTL_ID
WHERE
    a.EV_UTL_Who = 0
AND
    a.EV_UTL_PositedAt = (
        SELECT
            MAX(sub.EV_UTL_PositedAt)
        FROM
            attributes.EV_UTL_Event_Utilization_Meta sub
        WHERE
            sub.EV_UTL_ID = p.EV_UTL_ID
        AND
            sub.EV_UTL_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_LVL_Event_Level AS
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Who,
    a.EV_LVL_Confidence,
    a.EV_LVL_Stance,
    a.,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID
    , p.EV_LVL_ChangedAt
FROM
    attributes.EV_LVL_Event_Level_Fact p
JOIN
    attributes.EV_LVL_Event_Level_Meta a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
WHERE
    a.EV_LVL_Who = 0
AND
    a.EV_LVL_PositedAt = (
        SELECT
            MAX(sub.EV_LVL_PositedAt)
        FROM
            attributes.EV_LVL_Event_Level_Meta sub
        WHERE
            sub.EV_LVL_ID = p.EV_LVL_ID
        AND
            sub.EV_LVL_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_NAM_Stage_Name AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Who,
    a.ST_NAM_Confidence,
    a.ST_NAM_Stance,
    a.,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name
    , p.ST_NAM_ChangedAt
FROM
    attributes.ST_NAM_Stage_Name_Fact p
JOIN
    attributes.ST_NAM_Stage_Name_Meta a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
WHERE
    a.ST_NAM_Who = 0
AND
    a.ST_NAM_PositedAt = (
        SELECT
            MAX(sub.ST_NAM_PositedAt)
        FROM
            attributes.ST_NAM_Stage_Name_Meta sub
        WHERE
            sub.ST_NAM_ID = p.ST_NAM_ID
        AND
            sub.ST_NAM_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_LOC_Stage_Location AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Who,
    a.ST_LOC_Confidence,
    a.ST_LOC_Stance,
    a.,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location
FROM
    attributes.ST_LOC_Stage_Location_Fact p
JOIN
    attributes.ST_LOC_Stage_Location_Meta a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
WHERE
    a.ST_LOC_Who = 0
AND
    a.ST_LOC_PositedAt = (
        SELECT
            MAX(sub.ST_LOC_PositedAt)
        FROM
            attributes.ST_LOC_Stage_Location_Meta sub
        WHERE
            sub.ST_LOC_ID = p.ST_LOC_ID
        AND
            sub.ST_LOC_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_AVG_Stage_Average AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Who,
    a.ST_AVG_Confidence,
    a.ST_AVG_Stance,
    a.,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID
    , p.ST_AVG_ChangedAt
FROM
    attributes.ST_AVG_Stage_Average_Fact p
JOIN
    attributes.ST_AVG_Stage_Average_Meta a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
WHERE
    a.ST_AVG_Who = 0
AND
    a.ST_AVG_PositedAt = (
        SELECT
            MAX(sub.ST_AVG_PositedAt)
        FROM
            attributes.ST_AVG_Stage_Average_Meta sub
        WHERE
            sub.ST_AVG_ID = p.ST_AVG_ID
        AND
            sub.ST_AVG_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_MIN_Stage_Minimum AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Who,
    a.ST_MIN_Confidence,
    a.ST_MIN_Stance,
    a.,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID
FROM
    attributes.ST_MIN_Stage_Minimum_Fact p
JOIN
    attributes.ST_MIN_Stage_Minimum_Meta a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
WHERE
    a.ST_MIN_Who = 0
AND
    a.ST_MIN_PositedAt = (
        SELECT
            MAX(sub.ST_MIN_PositedAt)
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta sub
        WHERE
            sub.ST_MIN_ID = p.ST_MIN_ID
        AND
            sub.ST_MIN_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_NAM_Actor_Name AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Who,
    a.AC_NAM_Confidence,
    a.AC_NAM_Stance,
    a.,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name
    , p.AC_NAM_ChangedAt
FROM
    attributes.AC_NAM_Actor_Name_Fact p
JOIN
    attributes.AC_NAM_Actor_Name_Meta a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
WHERE
    a.AC_NAM_Who = 0
AND
    a.AC_NAM_PositedAt = (
        SELECT
            MAX(sub.AC_NAM_PositedAt)
        FROM
            attributes.AC_NAM_Actor_Name_Meta sub
        WHERE
            sub.AC_NAM_ID = p.AC_NAM_ID
        AND
            sub.AC_NAM_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_GEN_Actor_Gender AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Who,
    a.AC_GEN_Confidence,
    a.AC_GEN_Stance,
    a.,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID
FROM
    attributes.AC_GEN_Actor_Gender_Fact p
JOIN
    attributes.AC_GEN_Actor_Gender_Meta a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
WHERE
    a.AC_GEN_Who = 0
AND
    a.AC_GEN_PositedAt = (
        SELECT
            MAX(sub.AC_GEN_PositedAt)
        FROM
            attributes.AC_GEN_Actor_Gender_Meta sub
        WHERE
            sub.AC_GEN_ID = p.AC_GEN_ID
        AND
            sub.AC_GEN_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_PLV_Actor_ProfessionalLevel AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Who,
    a.AC_PLV_Confidence,
    a.AC_PLV_Stance,
    a.,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID
    , p.AC_PLV_ChangedAt
FROM
    attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
JOIN
    attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
WHERE
    a.AC_PLV_Who = 0
AND
    a.AC_PLV_PositedAt = (
        SELECT
            MAX(sub.AC_PLV_PositedAt)
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta sub
        WHERE
            sub.AC_PLV_ID = p.AC_PLV_ID
        AND
            sub.AC_PLV_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rPR_NAM_Program_Name AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Who,
    a.PR_NAM_Confidence,
    a.PR_NAM_Stance,
    a.,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name
FROM
    attributes.PR_NAM_Program_Name_Fact p
JOIN
    attributes.PR_NAM_Program_Name_Meta a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
WHERE
    a.PR_NAM_Who = 0
AND
    a.PR_NAM_PositedAt = (
        SELECT
            MAX(sub.PR_NAM_PositedAt)
        FROM
            attributes.PR_NAM_Program_Name_Meta sub
        WHERE
            sub.PR_NAM_ID = p.PR_NAM_ID
        AND
            sub.PR_NAM_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rPR_LEN_Program_Length AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Who,
    a.PR_LEN_Confidence,
    a.PR_LEN_Stance,
    a.,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length
    , p.PR_LEN_ChangedAt
FROM
    attributes.PR_LEN_Program_Length_Fact p
JOIN
    attributes.PR_LEN_Program_Length_Meta a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
WHERE
    a.PR_LEN_Who = 0
AND
    a.PR_LEN_PositedAt = (
        SELECT
            MAX(sub.PR_LEN_PositedAt)
        FROM
            attributes.PR_LEN_Program_Length_Meta sub
        WHERE
            sub.PR_LEN_ID = p.PR_LEN_ID
        AND
            sub.PR_LEN_Who = 0
    )
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
CREATE TABLE IF NOT EXISTS ties.AC_partner_AC_with_ONG_currently_Fact (
    AC_partner_AC_with_ONG_currently_ID number(19) IDENTITY(1,1) not null, 
    AC_ID_partner number(5) not null, 
    AC_ID_with number(5) not null, 
    ONG_ID_currently number(3) not null,
    AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
    constraint AC_partner_AC_with_ONG_currently_Fact_fkAC_partner foreign key (
        AC_ID_partner
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_partner_AC_with_ONG_currently_Fact_fkAC_with foreign key (
        AC_ID_with
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_partner_AC_with_ONG_currently_Fact_fkONG_currently foreign key (
        ONG_ID_currently
    ) references knots.ONG_Ongoing(ONG_ID),
    constraint AC_partner_AC_with_ONG_currently_Fact_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint AC_partner_AC_with_ONG_currently_Fact_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint pkAC_partner_AC_with_ONG_currently_Fact primary key (
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

CREATE TABLE IF NOT EXISTS ties.AC_partner_AC_with_ONG_currently_Meta (
    AC_partner_AC_with_ONG_currently_ID number(19) not null,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp(3) not null,
    AC_partner_AC_with_ONG_currently_Who number(5) not null,
    AC_partner_AC_with_ONG_currently_Confidence number(7,3) not null,
    AC_partner_AC_with_ONG_currently_Stance varchar2(4000) default (
        case
            when AC_partner_AC_with_ONG_currently_Confidence > 0.25 then '+'
            when AC_partner_AC_with_ONG_currently_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_partner_AC_with_ONG_currently_Confidence <  then 0
            else 1
        end
    ),
    Metadata_AC_partner_AC_with_ONG_currently number(19) not null,
    constraint fkAC_partner_AC_with_ONG_currently_Meta foreign key (
        AC_partner_AC_with_ONG_currently_ID
    ) references ties.AC_partner_AC_with_ONG_currently_Fact(AC_partner_AC_with_ONG_currently_ID),
    constraint pkAC_partner_AC_with_ONG_currently_Meta primary key (
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Who,
        AC_partner_AC_with_ONG_currently_PositedAt
    )
) CLUSTER BY (AC_partner_AC_with_ONG_currently_ID, AC_partner_AC_with_ONG_currently_Who, AC_partner_AC_with_ONG_currently_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_subset_PN_of_Fact (
    AC_subset_PN_of_ID number(19) IDENTITY(1,1) not null, 
    AC_ID_subset number(5) not null, 
    PN_ID_of number(19) not null, 
    constraint AC_subset_PN_of_Fact_fkAC_subset foreign key (
        AC_ID_subset
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_subset_PN_of_Fact_fkPN_of foreign key (
        PN_ID_of
    ) references anchors.PN_Person(PN_ID),
    constraint AC_subset_PN_of_Fact_uqAC_subset unique (
        AC_ID_subset
    ),
    constraint AC_subset_PN_of_Fact_uqPN_of unique (
        PN_ID_of
    ),
    constraint pkAC_subset_PN_of_Fact primary key (
        AC_subset_PN_of_ID
    ),
    constraint uqAC_subset_PN_of unique (
        AC_ID_subset,
        PN_ID_of
    )
) CLUSTER BY (
);

CREATE TABLE IF NOT EXISTS ties.AC_subset_PN_of_Meta (
    AC_subset_PN_of_ID number(19) not null,
    AC_subset_PN_of_PositedAt timestamp(3) not null,
    AC_subset_PN_of_Who number(5) not null,
    AC_subset_PN_of_Confidence number(7,3) not null,
    AC_subset_PN_of_Stance varchar2(4000) default (
        case
            when AC_subset_PN_of_Confidence > 0.25 then '+'
            when AC_subset_PN_of_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_subset_PN_of_Confidence <  then 0
            else 1
        end
    ),
    Metadata_AC_subset_PN_of number(19) not null,
    constraint fkAC_subset_PN_of_Meta foreign key (
        AC_subset_PN_of_ID
    ) references ties.AC_subset_PN_of_Fact(AC_subset_PN_of_ID),
    constraint pkAC_subset_PN_of_Meta primary key (
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Who,
        AC_subset_PN_of_PositedAt
    )
) CLUSTER BY (AC_subset_PN_of_ID, AC_subset_PN_of_Who, AC_subset_PN_of_PositedAt);
CREATE TABLE IF NOT EXISTS ties.EV_in_AC_wasCast_Fact (
    EV_in_AC_wasCast_ID number(19) IDENTITY(1,1) not null, 
    EV_ID_in number(12,0) not null, 
    AC_ID_wasCast number(5) not null, 
    constraint EV_in_AC_wasCast_Fact_fkEV_in foreign key (
        EV_ID_in
    ) references nexuses.EV_Event(EV_ID),
    constraint EV_in_AC_wasCast_Fact_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references anchors.AC_Actor(AC_ID),
    constraint pkEV_in_AC_wasCast_Fact primary key (
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

CREATE TABLE IF NOT EXISTS ties.EV_in_AC_wasCast_Meta (
    EV_in_AC_wasCast_ID number(19) not null,
    EV_in_AC_wasCast_PositedAt timestamp(3) not null,
    EV_in_AC_wasCast_Who number(5) not null,
    EV_in_AC_wasCast_Confidence number(7,3) not null,
    EV_in_AC_wasCast_Stance varchar2(4000) default (
        case
            when EV_in_AC_wasCast_Confidence > 0.25 then '+'
            when EV_in_AC_wasCast_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_in_AC_wasCast_Confidence <  then 0
            else 1
        end
    ),
    Metadata_EV_in_AC_wasCast number(19) not null,
    constraint fkEV_in_AC_wasCast_Meta foreign key (
        EV_in_AC_wasCast_ID
    ) references ties.EV_in_AC_wasCast_Fact(EV_in_AC_wasCast_ID),
    constraint pkEV_in_AC_wasCast_Meta primary key (
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_Who,
        EV_in_AC_wasCast_PositedAt
    )
) CLUSTER BY (EV_in_AC_wasCast_ID, EV_in_AC_wasCast_Who, EV_in_AC_wasCast_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_part_PR_in_RAT_got_Fact (
    AC_part_PR_in_RAT_got_ID number(19) IDENTITY(1,1) not null, 
    AC_ID_part number(5) not null, 
    PR_ID_in number(19) not null, 
    RAT_ID_got number(3) not null,
    AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
    constraint AC_part_PR_in_RAT_got_Fact_fkAC_part foreign key (
        AC_ID_part
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_part_PR_in_RAT_got_Fact_fkPR_in foreign key (
        PR_ID_in
    ) references anchors.PR_Program(PR_ID),
    constraint AC_part_PR_in_RAT_got_Fact_fkRAT_got foreign key (
        RAT_ID_got
    ) references knots.RAT_Rating(RAT_ID),
    constraint pkAC_part_PR_in_RAT_got_Fact primary key (
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

CREATE TABLE IF NOT EXISTS ties.AC_part_PR_in_RAT_got_Meta (
    AC_part_PR_in_RAT_got_ID number(19) not null,
    AC_part_PR_in_RAT_got_PositedAt timestamp(3) not null,
    AC_part_PR_in_RAT_got_Who number(5) not null,
    AC_part_PR_in_RAT_got_Confidence number(7,3) not null,
    AC_part_PR_in_RAT_got_Stance varchar2(4000) default (
        case
            when AC_part_PR_in_RAT_got_Confidence > 0.25 then '+'
            when AC_part_PR_in_RAT_got_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_part_PR_in_RAT_got_Confidence <  then 0
            else 1
        end
    ),
    Metadata_AC_part_PR_in_RAT_got number(19) not null,
    constraint fkAC_part_PR_in_RAT_got_Meta foreign key (
        AC_part_PR_in_RAT_got_ID
    ) references ties.AC_part_PR_in_RAT_got_Fact(AC_part_PR_in_RAT_got_ID),
    constraint pkAC_part_PR_in_RAT_got_Meta primary key (
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Who,
        AC_part_PR_in_RAT_got_PositedAt
    )
) CLUSTER BY (AC_part_PR_in_RAT_got_ID, AC_part_PR_in_RAT_got_Who, AC_part_PR_in_RAT_got_PositedAt);
CREATE TABLE IF NOT EXISTS ties.ST_at_PR_isPlaying_Fact (
    ST_at_PR_isPlaying_ID number(19) IDENTITY(1,1) not null, 
    ST_ID_at number(10) not null, 
    PR_ID_isPlaying number(19) not null, 
    ST_at_PR_isPlaying_ChangedAt timestamp not null,
    constraint ST_at_PR_isPlaying_Fact_fkST_at foreign key (
        ST_ID_at
    ) references anchors.ST_Stage(ST_ID),
    constraint ST_at_PR_isPlaying_Fact_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references anchors.PR_Program(PR_ID),
    constraint pkST_at_PR_isPlaying_Fact primary key (
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

CREATE TABLE IF NOT EXISTS ties.ST_at_PR_isPlaying_Meta (
    ST_at_PR_isPlaying_ID number(19) not null,
    ST_at_PR_isPlaying_PositedAt timestamp(3) not null,
    ST_at_PR_isPlaying_Who number(5) not null,
    ST_at_PR_isPlaying_Confidence number(7,3) not null,
    ST_at_PR_isPlaying_Stance varchar2(4000) default (
        case
            when ST_at_PR_isPlaying_Confidence > 0.25 then '+'
            when ST_at_PR_isPlaying_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_at_PR_isPlaying_Confidence <  then 0
            else 1
        end
    ),
    Metadata_ST_at_PR_isPlaying number(19) not null,
    constraint fkST_at_PR_isPlaying_Meta foreign key (
        ST_at_PR_isPlaying_ID
    ) references ties.ST_at_PR_isPlaying_Fact(ST_at_PR_isPlaying_ID),
    constraint pkST_at_PR_isPlaying_Meta primary key (
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_Who,
        ST_at_PR_isPlaying_PositedAt
    )
) CLUSTER BY (ST_at_PR_isPlaying_ID, ST_at_PR_isPlaying_Who, ST_at_PR_isPlaying_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_parent_AC_child_PAT_having_Fact (
    AC_parent_AC_child_PAT_having_ID number(19) IDENTITY(1,1) not null, 
    AC_ID_parent number(5) not null, 
    AC_ID_child number(5) not null, 
    PAT_ID_having number(3) not null,
    constraint AC_parent_AC_child_PAT_having_Fact_fkAC_parent foreign key (
        AC_ID_parent
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_parent_AC_child_PAT_having_Fact_fkAC_child foreign key (
        AC_ID_child
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_parent_AC_child_PAT_having_Fact_fkPAT_having foreign key (
        PAT_ID_having
    ) references knots.PAT_ParentalType(PAT_ID),
    constraint pkAC_parent_AC_child_PAT_having_Fact primary key (
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

CREATE TABLE IF NOT EXISTS ties.AC_parent_AC_child_PAT_having_Meta (
    AC_parent_AC_child_PAT_having_ID number(19) not null,
    AC_parent_AC_child_PAT_having_PositedAt timestamp(3) not null,
    AC_parent_AC_child_PAT_having_Who number(5) not null,
    AC_parent_AC_child_PAT_having_Confidence number(7,3) not null,
    AC_parent_AC_child_PAT_having_Stance varchar2(4000) default (
        case
            when AC_parent_AC_child_PAT_having_Confidence > 0.25 then '+'
            when AC_parent_AC_child_PAT_having_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_parent_AC_child_PAT_having_Confidence <  then 0
            else 1
        end
    ),
    Metadata_AC_parent_AC_child_PAT_having number(19) not null,
    constraint fkAC_parent_AC_child_PAT_having_Meta foreign key (
        AC_parent_AC_child_PAT_having_ID
    ) references ties.AC_parent_AC_child_PAT_having_Fact(AC_parent_AC_child_PAT_having_ID),
    constraint pkAC_parent_AC_child_PAT_having_Meta primary key (
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_Who,
        AC_parent_AC_child_PAT_having_PositedAt
    )
) CLUSTER BY (AC_parent_AC_child_PAT_having_ID, AC_parent_AC_child_PAT_having_Who, AC_parent_AC_child_PAT_having_PositedAt);
CREATE TABLE IF NOT EXISTS ties.PR_content_ST_location_EV_of_Fact (
    PR_content_ST_location_EV_of_ID number(19) IDENTITY(1,1) not null, 
    PR_ID_content number(19) not null, 
    ST_ID_location number(10) not null, 
    EV_ID_of number(12,0) not null, 
    PR_content_ST_location_EV_of_ChangedAt timestamp not null,
    constraint PR_content_ST_location_EV_of_Fact_fkPR_content foreign key (
        PR_ID_content
    ) references anchors.PR_Program(PR_ID),
    constraint PR_content_ST_location_EV_of_Fact_fkST_location foreign key (
        ST_ID_location
    ) references anchors.ST_Stage(ST_ID),
    constraint PR_content_ST_location_EV_of_Fact_fkEV_of foreign key (
        EV_ID_of
    ) references nexuses.EV_Event(EV_ID),
    constraint PR_content_ST_location_EV_of_Fact_uqPR_content unique (
        PR_ID_content,
        PR_content_ST_location_EV_of_ChangedAt
    ),
    constraint PR_content_ST_location_EV_of_Fact_uqST_location unique (
        ST_ID_location,
        PR_content_ST_location_EV_of_ChangedAt
    ),
    constraint pkPR_content_ST_location_EV_of_Fact primary key (
        PR_content_ST_location_EV_of_ID
    ),
    constraint uqPR_content_ST_location_EV_of unique (
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
) CLUSTER BY (
    PR_content_ST_location_EV_of_ChangedAt
);

CREATE TABLE IF NOT EXISTS ties.PR_content_ST_location_EV_of_Meta (
    PR_content_ST_location_EV_of_ID number(19) not null,
    PR_content_ST_location_EV_of_PositedAt timestamp(3) not null,
    PR_content_ST_location_EV_of_Who number(5) not null,
    PR_content_ST_location_EV_of_Confidence number(7,3) not null,
    PR_content_ST_location_EV_of_Stance varchar2(4000) default (
        case
            when PR_content_ST_location_EV_of_Confidence > 0.25 then '+'
            when PR_content_ST_location_EV_of_Confidence = 0.25 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when PR_content_ST_location_EV_of_Confidence <  then 0
            else 1
        end
    ),
    Metadata_PR_content_ST_location_EV_of number(19) not null,
    constraint fkPR_content_ST_location_EV_of_Meta foreign key (
        PR_content_ST_location_EV_of_ID
    ) references ties.PR_content_ST_location_EV_of_Fact(PR_content_ST_location_EV_of_ID),
    constraint pkPR_content_ST_location_EV_of_Meta primary key (
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Who,
        PR_content_ST_location_EV_of_PositedAt
    )
) CLUSTER BY (PR_content_ST_location_EV_of_ID, PR_content_ST_location_EV_of_Who, PR_content_ST_location_EV_of_PositedAt);
-- TIE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views for ties.
--
CREATE OR REPLACE VIEW ties.rAC_partner_AC_with_ONG_currently AS
SELECT
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Who,
    a.AC_partner_AC_with_ONG_currently_Confidence,
    a.AC_partner_AC_with_ONG_currently_Stance,
    a.
FROM
    ties.AC_partner_AC_with_ONG_currently_Fact p
JOIN
    ties.AC_partner_AC_with_ONG_currently_Meta a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
WHERE
    a.AC_partner_AC_with_ONG_currently_Who = 0
AND
    a.AC_partner_AC_with_ONG_currently_PositedAt = (
        SELECT
            MAX(sub.AC_partner_AC_with_ONG_currently_PositedAt)
        FROM
            ties.AC_partner_AC_with_ONG_currently_Meta sub
        WHERE
            sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
        AND
            sub.AC_partner_AC_with_ONG_currently_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_subset_PN_of AS
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Who,
    a.AC_subset_PN_of_Confidence,
    a.AC_subset_PN_of_Stance,
    a.
FROM
    ties.AC_subset_PN_of_Fact p
JOIN
    ties.AC_subset_PN_of_Meta a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
WHERE
    a.AC_subset_PN_of_Who = 0
AND
    a.AC_subset_PN_of_PositedAt = (
        SELECT
            MAX(sub.AC_subset_PN_of_PositedAt)
        FROM
            ties.AC_subset_PN_of_Meta sub
        WHERE
            sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
        AND
            sub.AC_subset_PN_of_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rEV_in_AC_wasCast AS
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Who,
    a.EV_in_AC_wasCast_Confidence,
    a.EV_in_AC_wasCast_Stance,
    a.
FROM
    ties.EV_in_AC_wasCast_Fact p
JOIN
    ties.EV_in_AC_wasCast_Meta a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
WHERE
    a.EV_in_AC_wasCast_Who = 0
AND
    a.EV_in_AC_wasCast_PositedAt = (
        SELECT
            MAX(sub.EV_in_AC_wasCast_PositedAt)
        FROM
            ties.EV_in_AC_wasCast_Meta sub
        WHERE
            sub.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
        AND
            sub.EV_in_AC_wasCast_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_part_PR_in_RAT_got AS
SELECT
    a.Metadata_AC_part_PR_in_RAT_got,
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Who,
    a.AC_part_PR_in_RAT_got_Confidence,
    a.AC_part_PR_in_RAT_got_Stance,
    a.
FROM
    ties.AC_part_PR_in_RAT_got_Fact p
JOIN
    ties.AC_part_PR_in_RAT_got_Meta a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
WHERE
    a.AC_part_PR_in_RAT_got_Who = 0
AND
    a.AC_part_PR_in_RAT_got_PositedAt = (
        SELECT
            MAX(sub.AC_part_PR_in_RAT_got_PositedAt)
        FROM
            ties.AC_part_PR_in_RAT_got_Meta sub
        WHERE
            sub.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
        AND
            sub.AC_part_PR_in_RAT_got_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rST_at_PR_isPlaying AS
SELECT
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Who,
    a.ST_at_PR_isPlaying_Confidence,
    a.ST_at_PR_isPlaying_Stance,
    a.
FROM
    ties.ST_at_PR_isPlaying_Fact p
JOIN
    ties.ST_at_PR_isPlaying_Meta a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
WHERE
    a.ST_at_PR_isPlaying_Who = 0
AND
    a.ST_at_PR_isPlaying_PositedAt = (
        SELECT
            MAX(sub.ST_at_PR_isPlaying_PositedAt)
        FROM
            ties.ST_at_PR_isPlaying_Meta sub
        WHERE
            sub.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
        AND
            sub.ST_at_PR_isPlaying_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_parent_AC_child_PAT_having AS
SELECT
    a.Metadata_AC_parent_AC_child_PAT_having,
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Who,
    a.AC_parent_AC_child_PAT_having_Confidence,
    a.AC_parent_AC_child_PAT_having_Stance,
    a.
FROM
    ties.AC_parent_AC_child_PAT_having_Fact p
JOIN
    ties.AC_parent_AC_child_PAT_having_Meta a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
WHERE
    a.AC_parent_AC_child_PAT_having_Who = 0
AND
    a.AC_parent_AC_child_PAT_having_PositedAt = (
        SELECT
            MAX(sub.AC_parent_AC_child_PAT_having_PositedAt)
        FROM
            ties.AC_parent_AC_child_PAT_having_Meta sub
        WHERE
            sub.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
        AND
            sub.AC_parent_AC_child_PAT_having_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rPR_content_ST_location_EV_of AS
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    p.PR_content_ST_location_EV_of_ChangedAt,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Who,
    a.PR_content_ST_location_EV_of_Confidence,
    a.PR_content_ST_location_EV_of_Stance,
    a.
FROM
    ties.PR_content_ST_location_EV_of_Fact p
JOIN
    ties.PR_content_ST_location_EV_of_Meta a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
WHERE
    a.PR_content_ST_location_EV_of_Who = 0
AND
    a.PR_content_ST_location_EV_of_PositedAt = (
        SELECT
            MAX(sub.PR_content_ST_location_EV_of_PositedAt)
        FROM
            ties.PR_content_ST_location_EV_of_Meta sub
        WHERE
            sub.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
        AND
            sub.PR_content_ST_location_EV_of_Who = 0
    )
;
-- ANCHOR CRT PERSPECTIVES --------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT anchors.
--
CREATE OR REPLACE VIEW anchors.lST_Stage AS
SELECT
    a.ST_ID,
    a.Metadata_ST,
    rNAM.ST_NAM_Stage_Name,
    rNAM.ST_NAM_ChangedAt,
    rNAM.ST_NAM_PositedAt,
    rNAM.ST_NAM_Who,
    rNAM.ST_NAM_Confidence,
    rNAM.ST_NAM_Stance,
    rNAM.,
    rLOC.ST_LOC_Stage_Location,
    rLOC.ST_LOC_PositedAt,
    rLOC.ST_LOC_Who,
    rLOC.ST_LOC_Confidence,
    rLOC.ST_LOC_Stance,
    rLOC.,
    rAVG.ST_AVG_UTL_ID,
    rAVG.ST_AVG_ChangedAt,
    rAVG.ST_AVG_PositedAt,
    rAVG.ST_AVG_Who,
    rAVG.ST_AVG_Confidence,
    rAVG.ST_AVG_Stance,
    rAVG.,
    rMIN.ST_MIN_UTL_ID,
    rMIN.ST_MIN_PositedAt,
    rMIN.ST_MIN_Who,
    rMIN.ST_MIN_Confidence,
    rMIN.ST_MIN_Stance,
    rMIN.
FROM
    anchors.ST_Stage a
LEFT JOIN
    attributes.rST_NAM_Stage_Name rNAM
ON
    rNAM.ST_NAM_ST_ID = a.ST_ID
LEFT JOIN
    attributes.rST_LOC_Stage_Location rLOC
ON
    rLOC.ST_LOC_ST_ID = a.ST_ID
LEFT JOIN
    attributes.rST_AVG_Stage_Average rAVG
ON
    rAVG.ST_AVG_ST_ID = a.ST_ID
LEFT JOIN
    knots.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = rAVG.ST_AVG_UTL_ID
LEFT JOIN
    attributes.rST_MIN_Stage_Minimum rMIN
ON
    rMIN.ST_MIN_ST_ID = a.ST_ID
LEFT JOIN
    knots.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = rMIN.ST_MIN_UTL_ID
;

CREATE OR REPLACE VIEW anchors.nST_Stage AS
SELECT
    *
FROM
    anchors.lST_Stage
;

CREATE OR REPLACE FUNCTION anchors.tST_Stage (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lST_Stage t
        WHERE
            (
                positor IS NULL
                OR (
                    t.ST_NAM_Who = positor OR
                    t.ST_LOC_Who = positor OR
                    t.ST_AVG_Who = positor OR
                    t.ST_MIN_Who = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.ST_NAM_Stance = assertion OR
                    t.ST_LOC_Stance = assertion OR
                    t.ST_AVG_Stance = assertion OR
                    t.ST_MIN_Stance = assertion 
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

CREATE OR REPLACE FUNCTION anchors.pST_Stage (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lST_Stage t
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

CREATE OR REPLACE FUNCTION anchors.dST_Stage (
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
            anchors.lST_Stage t
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
CREATE OR REPLACE VIEW anchors.lAC_Actor AS
SELECT
    a.AC_ID,
    a.Metadata_AC,
    rNAM.AC_NAM_Actor_Name,
    rNAM.AC_NAM_ChangedAt,
    rNAM.AC_NAM_PositedAt,
    rNAM.AC_NAM_Who,
    rNAM.AC_NAM_Confidence,
    rNAM.AC_NAM_Stance,
    rNAM.,
    rGEN.AC_GEN_GEN_ID,
    rGEN.AC_GEN_PositedAt,
    rGEN.AC_GEN_Who,
    rGEN.AC_GEN_Confidence,
    rGEN.AC_GEN_Stance,
    rGEN.,
    rPLV.AC_PLV_PLV_ID,
    rPLV.AC_PLV_ChangedAt,
    rPLV.AC_PLV_PositedAt,
    rPLV.AC_PLV_Who,
    rPLV.AC_PLV_Confidence,
    rPLV.AC_PLV_Stance,
    rPLV.
FROM
    anchors.AC_Actor a
LEFT JOIN
    attributes.rAC_NAM_Actor_Name rNAM
ON
    rNAM.AC_NAM_AC_ID = a.AC_ID
LEFT JOIN
    attributes.rAC_GEN_Actor_Gender rGEN
ON
    rGEN.AC_GEN_AC_ID = a.AC_ID
LEFT JOIN
    knots.GEN_Gender kGEN
ON
    kGEN.GEN_ID = rGEN.AC_GEN_GEN_ID
LEFT JOIN
    attributes.rAC_PLV_Actor_ProfessionalLevel rPLV
ON
    rPLV.AC_PLV_AC_ID = a.AC_ID
LEFT JOIN
    knots.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = rPLV.AC_PLV_PLV_ID
;

CREATE OR REPLACE VIEW anchors.nAC_Actor AS
SELECT
    *
FROM
    anchors.lAC_Actor
;

CREATE OR REPLACE FUNCTION anchors.tAC_Actor (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lAC_Actor t
        WHERE
            (
                positor IS NULL
                OR (
                    t.AC_NAM_Who = positor OR
                    t.AC_GEN_Who = positor OR
                    t.AC_PLV_Who = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.AC_NAM_Stance = assertion OR
                    t.AC_GEN_Stance = assertion OR
                    t.AC_PLV_Stance = assertion 
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

CREATE OR REPLACE FUNCTION anchors.pAC_Actor (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lAC_Actor t
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

CREATE OR REPLACE FUNCTION anchors.dAC_Actor (
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
            anchors.lAC_Actor t
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
CREATE OR REPLACE VIEW anchors.lPR_Program AS
SELECT
    a.PR_ID,
    a.Metadata_PR,
    rNAM.PR_NAM_Program_Name,
    rNAM.PR_NAM_PositedAt,
    rNAM.PR_NAM_Who,
    rNAM.PR_NAM_Confidence,
    rNAM.PR_NAM_Stance,
    rNAM.,
    rLEN.PR_LEN_Program_Length,
    rLEN.PR_LEN_ChangedAt,
    rLEN.PR_LEN_PositedAt,
    rLEN.PR_LEN_Who,
    rLEN.PR_LEN_Confidence,
    rLEN.PR_LEN_Stance,
    rLEN.
FROM
    anchors.PR_Program a
LEFT JOIN
    attributes.rPR_NAM_Program_Name rNAM
ON
    rNAM.PR_NAM_PR_ID = a.PR_ID
LEFT JOIN
    attributes.rPR_LEN_Program_Length rLEN
ON
    rLEN.PR_LEN_PR_ID = a.PR_ID
;

CREATE OR REPLACE VIEW anchors.nPR_Program AS
SELECT
    *
FROM
    anchors.lPR_Program
;

CREATE OR REPLACE FUNCTION anchors.tPR_Program (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lPR_Program t
        WHERE
            (
                positor IS NULL
                OR (
                    t.PR_NAM_Who = positor OR
                    t.PR_LEN_Who = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.PR_NAM_Stance = assertion OR
                    t.PR_LEN_Stance = assertion 
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

CREATE OR REPLACE FUNCTION anchors.pPR_Program (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lPR_Program t
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

CREATE OR REPLACE FUNCTION anchors.dPR_Program (
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
            anchors.lPR_Program t
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
CREATE OR REPLACE VIEW nexuses.lEV_Event AS
SELECT
    n.EV_ID,
    n.Metadata_EV,
    n.ST_ID_wasHeldAt,
    n.PR_ID_wasPlayed,
    n.ETY_ID_of,
    rDAT.EV_DAT_Event_Date,
    rDAT.EV_DAT_PositedAt,
    rDAT.EV_DAT_Who,
    rDAT.EV_DAT_Confidence,
    rDAT.EV_DAT_Stance,
    rDAT.,
    rAUD.EV_AUD_Event_Audience,
    rAUD.EV_AUD_PositedAt,
    rAUD.EV_AUD_Who,
    rAUD.EV_AUD_Confidence,
    rAUD.EV_AUD_Stance,
    rAUD.,
    rREV.EV_REV_Event_Revenue,
    rREV.EV_REV_PositedAt,
    rREV.EV_REV_Who,
    rREV.EV_REV_Confidence,
    rREV.EV_REV_Stance,
    rREV.,
    rSTA.EV_STA_Event_Status,
    rSTA.EV_STA_ChangedAt,
    rSTA.EV_STA_PositedAt,
    rSTA.EV_STA_Who,
    rSTA.EV_STA_Confidence,
    rSTA.EV_STA_Stance,
    rSTA.,
    rUTL.EV_UTL_UTL_ID,
    rUTL.EV_UTL_PositedAt,
    rUTL.EV_UTL_Who,
    rUTL.EV_UTL_Confidence,
    rUTL.EV_UTL_Stance,
    rUTL.,
    rLVL.EV_LVL_PLV_ID,
    rLVL.EV_LVL_ChangedAt,
    rLVL.EV_LVL_PositedAt,
    rLVL.EV_LVL_Who,
    rLVL.EV_LVL_Confidence,
    rLVL.EV_LVL_Stance,
    rLVL.
FROM
    nexuses.EV_Event n
LEFT JOIN
    attributes.rEV_DAT_Event_Date rDAT
ON
    rDAT.EV_DAT_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_AUD_Event_Audience rAUD
ON
    rAUD.EV_AUD_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_REV_Event_Revenue rREV
ON
    rREV.EV_REV_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_STA_Event_Status rSTA
ON
    rSTA.EV_STA_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_UTL_Event_Utilization rUTL
ON
    rUTL.EV_UTL_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_LVL_Event_Level rLVL
ON
    rLVL.EV_LVL_EV_ID = n.EV_ID
;

CREATE OR REPLACE VIEW nexuses.nEV_Event AS
SELECT
    *
FROM
    nexuses.lEV_Event
;

CREATE OR REPLACE FUNCTION nexuses.tEV_Event (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            nexuses.lEV_Event t
        WHERE
            (
                positor IS NULL
                OR (
                    t.EV_DAT_Who = positor OR
                    t.EV_AUD_Who = positor OR
                    t.EV_REV_Who = positor OR
                    t.EV_STA_Who = positor OR
                    t.EV_UTL_Who = positor OR
                    t.EV_LVL_Who = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.EV_DAT_Stance = assertion OR
                    t.EV_AUD_Stance = assertion OR
                    t.EV_REV_Stance = assertion OR
                    t.EV_STA_Stance = assertion OR
                    t.EV_UTL_Stance = assertion OR
                    t.EV_LVL_Stance = assertion 
                )
            )
        AND
            (
                changingTimepoint IS NULL
                OR (
                    t.EV_STA_ChangedAt <= changingTimepoint OR
                    t.EV_LVL_ChangedAt <= changingTimepoint 
                )
            )
        AND
            (
                positingTimepoint IS NULL
                OR (
                    t.EV_DAT_PositedAt <= positingTimepoint OR
                    t.EV_AUD_PositedAt <= positingTimepoint OR
                    t.EV_REV_PositedAt <= positingTimepoint OR
                    t.EV_STA_PositedAt <= positingTimepoint OR
                    t.EV_UTL_PositedAt <= positingTimepoint OR
                    t.EV_LVL_PositedAt <= positingTimepoint 
                )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION nexuses.pEV_Event (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            nexuses.lEV_Event t
        WHERE
            (
                changingTimepoint IS NULL
                OR (
                    t.EV_STA_ChangedAt <= changingTimepoint OR
                    t.EV_LVL_ChangedAt <= changingTimepoint 
            )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION nexuses.dEV_Event (
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
            nexuses.lEV_Event t
        WHERE
            (
                intervalStart IS NULL
                OR intervalEnd IS NULL
                OR (
                    t.EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd OR
                    t.EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd 
                )
            )
    ]';
END;
/
-- TIE CRT PERSPECTIVES -----------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT ties.
--
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently AS
SELECT
    r.AC_partner_AC_with_ONG_currently_ID,
    r.Metadata_AC_partner_AC_with_ONG_currently,
    r.AC_ID_partner,
    r.AC_ID_with,
    kONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    r.ONG_ID_currently
    r.AC_partner_AC_with_ONG_currently_ChangedAt,
    r.AC_partner_AC_with_ONG_currently_PositedAt,
    r.AC_partner_AC_with_ONG_currently_Who,
    r.AC_partner_AC_with_ONG_currently_Confidence,
    r.AC_partner_AC_with_ONG_currently_Stance,
    r.
FROM
    ties.rAC_partner_AC_with_ONG_currently r
LEFT JOIN
    knots.ONG_Ongoing kONG_currently
ON
    kONG_currently.ONG_ID = r.ONG_ID_currently
;

CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    ties.lAC_partner_AC_with_ONG_currently
;

CREATE OR REPLACE FUNCTION ties.tAC_partner_AC_with_ONG_currently (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_partner_AC_with_ONG_currently t
        WHERE
            (positor IS NULL OR t.AC_partner_AC_with_ONG_currently_Who = positor)
        AND
            (assertion IS NULL OR t.AC_partner_AC_with_ONG_currently_Stance = assertion)
        AND
            (changingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_partner_AC_with_ONG_currently t
        WHERE
            (changingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
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
            ties.lAC_partner_AC_with_ONG_currently t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of AS
SELECT
    r.AC_subset_PN_of_ID,
    r.Metadata_AC_subset_PN_of,
    r.AC_ID_subset,
    r.PN_ID_of
    r.AC_subset_PN_of_PositedAt,
    r.AC_subset_PN_of_Who,
    r.AC_subset_PN_of_Confidence,
    r.AC_subset_PN_of_Stance,
    r.
FROM
    ties.rAC_subset_PN_of r
;

CREATE OR REPLACE VIEW ties.nAC_subset_PN_of AS
SELECT
    *
FROM
    ties.lAC_subset_PN_of
;

CREATE OR REPLACE FUNCTION ties.tAC_subset_PN_of (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_subset_PN_of t
        WHERE
            (positor IS NULL OR t.AC_subset_PN_of_Who = positor)
        AND
            (assertion IS NULL OR t.AC_subset_PN_of_Stance = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.AC_subset_PN_of_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_subset_PN_of t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_subset_PN_of (
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
            ties.lAC_subset_PN_of t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast AS
SELECT
    r.EV_in_AC_wasCast_ID,
    r.Metadata_EV_in_AC_wasCast,
    r.EV_ID_in,
    r.AC_ID_wasCast
    r.EV_in_AC_wasCast_PositedAt,
    r.EV_in_AC_wasCast_Who,
    r.EV_in_AC_wasCast_Confidence,
    r.EV_in_AC_wasCast_Stance,
    r.
FROM
    ties.rEV_in_AC_wasCast r
;

CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast AS
SELECT
    *
FROM
    ties.lEV_in_AC_wasCast
;

CREATE OR REPLACE FUNCTION ties.tEV_in_AC_wasCast (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lEV_in_AC_wasCast t
        WHERE
            (positor IS NULL OR t.EV_in_AC_wasCast_Who = positor)
        AND
            (assertion IS NULL OR t.EV_in_AC_wasCast_Stance = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.EV_in_AC_wasCast_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pEV_in_AC_wasCast (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lEV_in_AC_wasCast t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dEV_in_AC_wasCast (
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
            ties.lEV_in_AC_wasCast t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got AS
SELECT
    r.AC_part_PR_in_RAT_got_ID,
    r.Metadata_AC_part_PR_in_RAT_got,
    r.AC_ID_part,
    r.PR_ID_in,
    kRAT_got.RAT_Rating AS got_RAT_Rating,
    r.RAT_ID_got
    r.AC_part_PR_in_RAT_got_ChangedAt,
    r.AC_part_PR_in_RAT_got_PositedAt,
    r.AC_part_PR_in_RAT_got_Who,
    r.AC_part_PR_in_RAT_got_Confidence,
    r.AC_part_PR_in_RAT_got_Stance,
    r.
FROM
    ties.rAC_part_PR_in_RAT_got r
LEFT JOIN
    knots.RAT_Rating kRAT_got
ON
    kRAT_got.RAT_ID = r.RAT_ID_got
;

CREATE OR REPLACE VIEW ties.nAC_part_PR_in_RAT_got AS
SELECT
    *
FROM
    ties.lAC_part_PR_in_RAT_got
;

CREATE OR REPLACE FUNCTION ties.tAC_part_PR_in_RAT_got (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_part_PR_in_RAT_got t
        WHERE
            (positor IS NULL OR t.AC_part_PR_in_RAT_got_Who = positor)
        AND
            (assertion IS NULL OR t.AC_part_PR_in_RAT_got_Stance = assertion)
        AND
            (changingTimepoint IS NULL OR t.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_part_PR_in_RAT_got t
        WHERE
            (changingTimepoint IS NULL OR t.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_part_PR_in_RAT_got (
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
            ties.lAC_part_PR_in_RAT_got t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying AS
SELECT
    r.ST_at_PR_isPlaying_ID,
    r.Metadata_ST_at_PR_isPlaying,
    r.ST_ID_at,
    r.PR_ID_isPlaying
    r.ST_at_PR_isPlaying_ChangedAt,
    r.ST_at_PR_isPlaying_PositedAt,
    r.ST_at_PR_isPlaying_Who,
    r.ST_at_PR_isPlaying_Confidence,
    r.ST_at_PR_isPlaying_Stance,
    r.
FROM
    ties.rST_at_PR_isPlaying r
;

CREATE OR REPLACE VIEW ties.nST_at_PR_isPlaying AS
SELECT
    *
FROM
    ties.lST_at_PR_isPlaying
;

CREATE OR REPLACE FUNCTION ties.tST_at_PR_isPlaying (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lST_at_PR_isPlaying t
        WHERE
            (positor IS NULL OR t.ST_at_PR_isPlaying_Who = positor)
        AND
            (assertion IS NULL OR t.ST_at_PR_isPlaying_Stance = assertion)
        AND
            (changingTimepoint IS NULL OR t.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.ST_at_PR_isPlaying_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pST_at_PR_isPlaying (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lST_at_PR_isPlaying t
        WHERE
            (changingTimepoint IS NULL OR t.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dST_at_PR_isPlaying (
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
            ties.lST_at_PR_isPlaying t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having AS
SELECT
    r.AC_parent_AC_child_PAT_having_ID,
    r.Metadata_AC_parent_AC_child_PAT_having,
    r.AC_ID_parent,
    r.AC_ID_child,
    kPAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    r.PAT_ID_having
    r.AC_parent_AC_child_PAT_having_PositedAt,
    r.AC_parent_AC_child_PAT_having_Who,
    r.AC_parent_AC_child_PAT_having_Confidence,
    r.AC_parent_AC_child_PAT_having_Stance,
    r.
FROM
    ties.rAC_parent_AC_child_PAT_having r
LEFT JOIN
    knots.PAT_ParentalType kPAT_having
ON
    kPAT_having.PAT_ID = r.PAT_ID_having
;

CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having AS
SELECT
    *
FROM
    ties.lAC_parent_AC_child_PAT_having
;

CREATE OR REPLACE FUNCTION ties.tAC_parent_AC_child_PAT_having (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_parent_AC_child_PAT_having t
        WHERE
            (positor IS NULL OR t.AC_parent_AC_child_PAT_having_Who = positor)
        AND
            (assertion IS NULL OR t.AC_parent_AC_child_PAT_having_Stance = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_parent_AC_child_PAT_having t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_parent_AC_child_PAT_having (
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
            ties.lAC_parent_AC_child_PAT_having t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of AS
SELECT
    r.PR_content_ST_location_EV_of_ID,
    r.Metadata_PR_content_ST_location_EV_of,
    r.PR_ID_content,
    r.ST_ID_location,
    r.EV_ID_of
    r.PR_content_ST_location_EV_of_ChangedAt,
    r.PR_content_ST_location_EV_of_PositedAt,
    r.PR_content_ST_location_EV_of_Who,
    r.PR_content_ST_location_EV_of_Confidence,
    r.PR_content_ST_location_EV_of_Stance,
    r.
FROM
    ties.rPR_content_ST_location_EV_of r
;

CREATE OR REPLACE VIEW ties.nPR_content_ST_location_EV_of AS
SELECT
    *
FROM
    ties.lPR_content_ST_location_EV_of
;

CREATE OR REPLACE FUNCTION ties.tPR_content_ST_location_EV_of (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lPR_content_ST_location_EV_of t
        WHERE
            (positor IS NULL OR t.PR_content_ST_location_EV_of_Who = positor)
        AND
            (assertion IS NULL OR t.PR_content_ST_location_EV_of_Stance = assertion)
        AND
            (changingTimepoint IS NULL OR t.PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lPR_content_ST_location_EV_of t
        WHERE
            (changingTimepoint IS NULL OR t.PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dPR_content_ST_location_EV_of (
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
            ties.lPR_content_ST_location_EV_of t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.PR_content_ST_location_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
