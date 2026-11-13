-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- In Oracle a schema is a user, which a script does not create. The schemas that the model puts its tables, views,
-- functions and procedures in must exist before this script is run, and the user that runs it needs the privileges to
-- create those objects in them (CREATE ANY TABLE, CREATE ANY VIEW, ... or the same privileges on each schema).
--
-- The schemas of this model are
--
--   dw
--   knots
--   anchors
--   nexuses
--   attributes
--   ties
--
-- A model whose schema is public, or that has none, creates everything in the schema that the script is run in.
--
-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- The table is called Who_ (PostgreSQL has an underscore first, which an unquoted Oracle name cannot start with).
--
-- Positor table ------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE dw.Who_ (
            Who number(5) not null,
            constraint pk_Who primary key (
                Who
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
INSERT INTO dw.Who_ (
    Who
)
SELECT
    0
FROM
    dual
WHERE NOT EXISTS (
    SELECT
        1
    FROM
        dw.Who_ p
    WHERE
        p.Who = 0
);
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_ParentalType table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.PAT_ParentalType (
            PAT_ID number(3) not null,
            PAT_ParentalType nvarchar2(42) not null,
            Metadata_PAT number(19) not null,
            constraint pkPAT_ParentalType primary key (
                PAT_ID
            ),
            constraint uqPAT_ParentalType unique (
                PAT_ParentalType
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.GEN_Gender (
            GEN_ID number(3) not null,
            GEN_Gender nvarchar2(42) not null,
            GEN_Checksum raw(16) generated always as (standard_hash(GEN_Gender, 'MD5')) virtual,
            Metadata_GEN number(19) not null,
            constraint pkGEN_Gender primary key (
                GEN_ID
            ),
            constraint uqGEN_Gender unique (
                GEN_Checksum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.PLV_ProfessionalLevel (
            PLV_ID number(3) not null,
            PLV_ProfessionalLevel nclob not null,
            PLV_Checksum raw(16) generated always as (standard_hash(PLV_ProfessionalLevel, 'MD5')) virtual,
            Metadata_PLV number(19) not null,
            constraint pkPLV_ProfessionalLevel primary key (
                PLV_ID
            ),
            constraint uqPLV_ProfessionalLevel unique (
                PLV_Checksum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.UTL_Utilization (
            UTL_ID number(3) not null,
            UTL_Utilization number(3) not null,
            Metadata_UTL number(19) not null,
            constraint pkUTL_Utilization primary key (
                UTL_ID
            ),
            constraint uqUTL_Utilization unique (
                UTL_Utilization
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.ONG_Ongoing (
            ONG_ID number(3) not null,
            ONG_Ongoing nvarchar2(3) not null,
            Metadata_ONG number(19) not null,
            constraint pkONG_Ongoing primary key (
                ONG_ID
            ),
            constraint uqONG_Ongoing unique (
                ONG_Ongoing
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE knots.RAT_Rating_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.RAT_Rating (
            RAT_ID number(3) default knots.RAT_Rating_ID_SEQ.nextval not null, 
            RAT_Rating nvarchar2(42) not null,
            RAT_Checksum raw(16) generated always as (standard_hash(RAT_Rating, 'MD5')) virtual,
            Metadata_RAT number(19) not null,
            constraint pkRAT_Rating primary key (
                RAT_ID
            ),
            constraint uqRAT_Rating unique (
                RAT_Checksum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.ETY_EventType (
            ETY_ID number(3) not null,
            ETY_EventType nvarchar2(42) not null,
            ETY_Checksum raw(16) generated always as (standard_hash(ETY_EventType, 'MD5')) virtual,
            Metadata_ETY number(19) not null,
            constraint pkETY_EventType primary key (
                ETY_ID
            ),
            constraint uqETY_EventType unique (
                ETY_Checksum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE anchors.PN_Person_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE anchors.PN_Person (
            PN_ID number(19) default anchors.PN_Person_ID_SEQ.nextval not null, 
            Metadata_PN number(19) not null,
            constraint pkPN_Person primary key (
                PN_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE anchors.ST_Stage (
            ST_ID number(10) not null,
            Metadata_ST number(19) not null,
            constraint pkST_Stage primary key (
                ST_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE anchors.AC_Actor_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE anchors.AC_Actor (
            AC_ID number(5) default anchors.AC_Actor_ID_SEQ.nextval not null, 
            Metadata_AC number(19) not null,
            constraint pkAC_Actor primary key (
                AC_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE anchors.PR_Program (
            PR_ID number(19) not null,
            Metadata_PR number(19) not null,
            constraint pkPR_Program primary key (
                PR_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE nexuses.EV_Event (
            EV_ID number(12,0) not null,
            ST_ID_wasHeldAt number(10) not null, 
            PR_ID_wasPlayed number(19) not null, 
            ETY_ID_of number(3) not null,
            Metadata_EV number(19) not null, 
            constraint EV_Event_fkST_wasHeldAt foreign key (
                ST_ID_wasHeldAt
            ) references anchors.ST_Stage(ST_ID),
            constraint EV_Event_fkPR_wasPlayed foreign key (
                PR_ID_wasPlayed
            ) references anchors.PR_Program(PR_ID),
            constraint EV_Event_fkETY_of foreign key (
                ETY_ID_of
            ) references knots.ETY_EventType(ETY_ID),
            constraint pkEV_Event primary key (
                EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
-- An attribute has a posit table, which holds the values, and an annex table, which holds who positioned each
-- of them (positor), when (positing time), and how reliable it is (reliability, from which the assertion follows).
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_DAT_Event_Date_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_DAT_Event_Date_Fact (
            EV_DAT_ID number(19) default attributes.EV_DAT_Event_Date_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Meta table (of EV_DAT_Event_Date_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_DAT_Event_Date_Meta (
            EV_DAT_ID number(19) not null,
            EV_DAT_PositedAt timestamp(3) not null,
            EV_DAT_Who number(5) not null,
            EV_DAT_Confidence number(7,3) not null,
            EV_DAT_Stance char(1) generated always as (
                case
                    when EV_DAT_Confidence > 0.25 then '+'
                    when EV_DAT_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_DAT number(19) not null,
            constraint fkEV_DAT_Event_Date_Meta foreign key (
                EV_DAT_ID
            ) references attributes.EV_DAT_Event_Date_Fact(EV_DAT_ID),
            constraint pkEV_DAT_Event_Date_Meta primary key (
                EV_DAT_ID,
                EV_DAT_Who,
                EV_DAT_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_AUD_Event_Audience_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_AUD_Event_Audience_Fact (
            EV_AUD_ID number(19) default attributes.EV_AUD_Event_Audience_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Meta table (of EV_AUD_Event_Audience_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_AUD_Event_Audience_Meta (
            EV_AUD_ID number(19) not null,
            EV_AUD_PositedAt timestamp(3) not null,
            EV_AUD_Who number(5) not null,
            EV_AUD_Confidence number(7,3) not null,
            EV_AUD_Stance char(1) generated always as (
                case
                    when EV_AUD_Confidence > 0.25 then '+'
                    when EV_AUD_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_AUD number(19) not null,
            constraint fkEV_AUD_Event_Audience_Meta foreign key (
                EV_AUD_ID
            ) references attributes.EV_AUD_Event_Audience_Fact(EV_AUD_ID),
            constraint pkEV_AUD_Event_Audience_Meta primary key (
                EV_AUD_ID,
                EV_AUD_Who,
                EV_AUD_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_REV_Event_Revenue_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_REV_Event_Revenue_Fact (
            EV_REV_ID number(19) default attributes.EV_REV_Event_Revenue_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Meta table (of EV_REV_Event_Revenue_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_REV_Event_Revenue_Meta (
            EV_REV_ID number(19) not null,
            EV_REV_PositedAt timestamp(3) not null,
            EV_REV_Who number(5) not null,
            EV_REV_Confidence number(7,3) not null,
            EV_REV_Stance char(1) generated always as (
                case
                    when EV_REV_Confidence > 0.25 then '+'
                    when EV_REV_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_REV number(19) not null,
            constraint fkEV_REV_Event_Revenue_Meta foreign key (
                EV_REV_ID
            ) references attributes.EV_REV_Event_Revenue_Fact(EV_REV_ID),
            constraint pkEV_REV_Event_Revenue_Meta primary key (
                EV_REV_ID,
                EV_REV_Who,
                EV_REV_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Event_Status_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_STA_Event_Status_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_STA_Event_Status_Fact (
            EV_STA_ID number(19) default attributes.EV_STA_Event_Status_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Event_Status_Meta table (of EV_STA_Event_Status_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_STA_Event_Status_Meta (
            EV_STA_ID number(19) not null,
            EV_STA_PositedAt timestamp(3) not null,
            EV_STA_Who number(5) not null,
            EV_STA_Confidence number(7,3) not null,
            EV_STA_Stance char(1) generated always as (
                case
                    when EV_STA_Confidence > 0.25 then '+'
                    when EV_STA_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_STA number(19) not null,
            constraint fkEV_STA_Event_Status_Meta foreign key (
                EV_STA_ID
            ) references attributes.EV_STA_Event_Status_Fact(EV_STA_ID),
            constraint pkEV_STA_Event_Status_Meta primary key (
                EV_STA_ID,
                EV_STA_Who,
                EV_STA_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_UTL_Event_Utilization_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_UTL_Event_Utilization_Fact (
            EV_UTL_ID number(19) default attributes.EV_UTL_Event_Utilization_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Meta table (of EV_UTL_Event_Utilization_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_UTL_Event_Utilization_Meta (
            EV_UTL_ID number(19) not null,
            EV_UTL_PositedAt timestamp(3) not null,
            EV_UTL_Who number(5) not null,
            EV_UTL_Confidence number(7,3) not null,
            EV_UTL_Stance char(1) generated always as (
                case
                    when EV_UTL_Confidence > 0.25 then '+'
                    when EV_UTL_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_UTL number(19) not null,
            constraint fkEV_UTL_Event_Utilization_Meta foreign key (
                EV_UTL_ID
            ) references attributes.EV_UTL_Event_Utilization_Fact(EV_UTL_ID),
            constraint pkEV_UTL_Event_Utilization_Meta primary key (
                EV_UTL_ID,
                EV_UTL_Who,
                EV_UTL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Event_Level_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_LVL_Event_Level_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_LVL_Event_Level_Fact (
            EV_LVL_ID number(19) default attributes.EV_LVL_Event_Level_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Event_Level_Meta table (of EV_LVL_Event_Level_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_LVL_Event_Level_Meta (
            EV_LVL_ID number(19) not null,
            EV_LVL_PositedAt timestamp(3) not null,
            EV_LVL_Who number(5) not null,
            EV_LVL_Confidence number(7,3) not null,
            EV_LVL_Stance char(1) generated always as (
                case
                    when EV_LVL_Confidence > 0.25 then '+'
                    when EV_LVL_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_LVL number(19) not null,
            constraint fkEV_LVL_Event_Level_Meta foreign key (
                EV_LVL_ID
            ) references attributes.EV_LVL_Event_Level_Fact(EV_LVL_ID),
            constraint pkEV_LVL_Event_Level_Meta primary key (
                EV_LVL_ID,
                EV_LVL_Who,
                EV_LVL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.ST_NAM_Stage_Name_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_NAM_Stage_Name_Fact (
            ST_NAM_ID number(19) default attributes.ST_NAM_Stage_Name_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Meta table (of ST_NAM_Stage_Name_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_NAM_Stage_Name_Meta (
            ST_NAM_ID number(19) not null,
            ST_NAM_PositedAt timestamp(3) not null,
            ST_NAM_Who number(5) not null,
            ST_NAM_Confidence number(7,3) not null,
            ST_NAM_Stance char(1) generated always as (
                case
                    when ST_NAM_Confidence > 0.25 then '+'
                    when ST_NAM_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_NAM number(19) not null,
            constraint fkST_NAM_Stage_Name_Meta foreign key (
                ST_NAM_ID
            ) references attributes.ST_NAM_Stage_Name_Fact(ST_NAM_ID),
            constraint pkST_NAM_Stage_Name_Meta primary key (
                ST_NAM_ID,
                ST_NAM_Who,
                ST_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.ST_LOC_Stage_Location_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_LOC_Stage_Location_Fact (
            ST_LOC_ID number(19) default attributes.ST_LOC_Stage_Location_Fact_ID_SEQ.nextval not null, 
            ST_LOC_ST_ID number(10) not null,
            ST_LOC_Stage_Location varchar2(100) not null,
            ST_LOC_Checksum raw(16) generated always as (standard_hash(ST_LOC_Stage_Location, 'MD5')) virtual,
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Meta table (of ST_LOC_Stage_Location_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_LOC_Stage_Location_Meta (
            ST_LOC_ID number(19) not null,
            ST_LOC_PositedAt timestamp(3) not null,
            ST_LOC_Who number(5) not null,
            ST_LOC_Confidence number(7,3) not null,
            ST_LOC_Stance char(1) generated always as (
                case
                    when ST_LOC_Confidence > 0.25 then '+'
                    when ST_LOC_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_LOC number(19) not null,
            constraint fkST_LOC_Stage_Location_Meta foreign key (
                ST_LOC_ID
            ) references attributes.ST_LOC_Stage_Location_Fact(ST_LOC_ID),
            constraint pkST_LOC_Stage_Location_Meta primary key (
                ST_LOC_ID,
                ST_LOC_Who,
                ST_LOC_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.ST_AVG_Stage_Average_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_AVG_Stage_Average_Fact (
            ST_AVG_ID number(19) default attributes.ST_AVG_Stage_Average_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Meta table (of ST_AVG_Stage_Average_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_AVG_Stage_Average_Meta (
            ST_AVG_ID number(19) not null,
            ST_AVG_PositedAt timestamp(3) not null,
            ST_AVG_Who number(5) not null,
            ST_AVG_Confidence number(7,3) not null,
            ST_AVG_Stance char(1) generated always as (
                case
                    when ST_AVG_Confidence > 0.25 then '+'
                    when ST_AVG_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_AVG number(19) not null,
            constraint fkST_AVG_Stage_Average_Meta foreign key (
                ST_AVG_ID
            ) references attributes.ST_AVG_Stage_Average_Fact(ST_AVG_ID),
            constraint pkST_AVG_Stage_Average_Meta primary key (
                ST_AVG_ID,
                ST_AVG_Who,
                ST_AVG_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.ST_MIN_Stage_Minimum_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_MIN_Stage_Minimum_Fact (
            ST_MIN_ID number(19) default attributes.ST_MIN_Stage_Minimum_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Meta table (of ST_MIN_Stage_Minimum_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_MIN_Stage_Minimum_Meta (
            ST_MIN_ID number(19) not null,
            ST_MIN_PositedAt timestamp(3) not null,
            ST_MIN_Who number(5) not null,
            ST_MIN_Confidence number(7,3) not null,
            ST_MIN_Stance char(1) generated always as (
                case
                    when ST_MIN_Confidence > 0.25 then '+'
                    when ST_MIN_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_MIN number(19) not null,
            constraint fkST_MIN_Stage_Minimum_Meta foreign key (
                ST_MIN_ID
            ) references attributes.ST_MIN_Stage_Minimum_Fact(ST_MIN_ID),
            constraint pkST_MIN_Stage_Minimum_Meta primary key (
                ST_MIN_ID,
                ST_MIN_Who,
                ST_MIN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- AC_NAM_Actor_Name is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.AC_NAM_Actor_Name_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_NAM_Actor_Name_Fact (
            AC_NAM_ID number(19) default attributes.AC_NAM_Actor_Name_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Meta table (of AC_NAM_Actor_Name_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_NAM_Actor_Name_Meta (
            AC_NAM_ID number(19) not null,
            AC_NAM_PositedAt timestamp(3) not null,
            AC_NAM_Who number(5) not null,
            AC_NAM_Confidence number(7,3) not null,
            AC_NAM_Stance char(1) generated always as (
                case
                    when AC_NAM_Confidence > 0.25 then '+'
                    when AC_NAM_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_NAM number(19) not null,
            constraint fkAC_NAM_Actor_Name_Meta foreign key (
                AC_NAM_ID
            ) references attributes.AC_NAM_Actor_Name_Fact(AC_NAM_ID),
            constraint pkAC_NAM_Actor_Name_Meta primary key (
                AC_NAM_ID,
                AC_NAM_Who,
                AC_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.AC_GEN_Actor_Gender_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_GEN_Actor_Gender_Fact (
            AC_GEN_ID number(19) default attributes.AC_GEN_Actor_Gender_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Meta table (of AC_GEN_Actor_Gender_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_GEN_Actor_Gender_Meta (
            AC_GEN_ID number(19) not null,
            AC_GEN_PositedAt timestamp(3) not null,
            AC_GEN_Who number(5) not null,
            AC_GEN_Confidence number(7,3) not null,
            AC_GEN_Stance char(1) generated always as (
                case
                    when AC_GEN_Confidence > 0.25 then '+'
                    when AC_GEN_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_GEN number(19) not null,
            constraint fkAC_GEN_Actor_Gender_Meta foreign key (
                AC_GEN_ID
            ) references attributes.AC_GEN_Actor_Gender_Fact(AC_GEN_ID),
            constraint pkAC_GEN_Actor_Gender_Meta primary key (
                AC_GEN_ID,
                AC_GEN_Who,
                AC_GEN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.AC_PLV_Actor_ProfessionalLevel_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_PLV_Actor_ProfessionalLevel_Fact (
            AC_PLV_ID number(19) default attributes.AC_PLV_Actor_ProfessionalLevel_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Meta table (of AC_PLV_Actor_ProfessionalLevel_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
            AC_PLV_ID number(19) not null,
            AC_PLV_PositedAt timestamp(3) not null,
            AC_PLV_Who number(5) not null,
            AC_PLV_Confidence number(7,3) not null,
            AC_PLV_Stance char(1) generated always as (
                case
                    when AC_PLV_Confidence > 0.25 then '+'
                    when AC_PLV_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_PLV number(19) not null,
            constraint fkAC_PLV_Actor_ProfessionalLevel_Meta foreign key (
                AC_PLV_ID
            ) references attributes.AC_PLV_Actor_ProfessionalLevel_Fact(AC_PLV_ID),
            constraint pkAC_PLV_Actor_ProfessionalLevel_Meta primary key (
                AC_PLV_ID,
                AC_PLV_Who,
                AC_PLV_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Fact table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.PR_NAM_Program_Name_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_NAM_Program_Name_Fact (
            PR_NAM_ID number(19) default attributes.PR_NAM_Program_Name_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Meta table (of PR_NAM_Program_Name_Fact on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_NAM_Program_Name_Meta (
            PR_NAM_ID number(19) not null,
            PR_NAM_PositedAt timestamp(3) not null,
            PR_NAM_Who number(5) not null,
            PR_NAM_Confidence number(7,3) not null,
            PR_NAM_Stance char(1) generated always as (
                case
                    when PR_NAM_Confidence > 0.25 then '+'
                    when PR_NAM_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_PR_NAM number(19) not null,
            constraint fkPR_NAM_Program_Name_Meta foreign key (
                PR_NAM_ID
            ) references attributes.PR_NAM_Program_Name_Fact(PR_NAM_ID),
            constraint pkPR_NAM_Program_Name_Meta primary key (
                PR_NAM_ID,
                PR_NAM_Who,
                PR_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Fact table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.PR_LEN_Program_Length_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_LEN_Program_Length_Fact (
            PR_LEN_ID number(19) default attributes.PR_LEN_Program_Length_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Meta table (of PR_LEN_Program_Length_Fact on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_LEN_Program_Length_Meta (
            PR_LEN_ID number(19) not null,
            PR_LEN_PositedAt timestamp(3) not null,
            PR_LEN_Who number(5) not null,
            PR_LEN_Confidence number(7,3) not null,
            PR_LEN_Stance char(1) generated always as (
                case
                    when PR_LEN_Confidence > 0.25 then '+'
                    when PR_LEN_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_PR_LEN number(19) not null,
            constraint fkPR_LEN_Program_Length_Meta foreign key (
                PR_LEN_ID
            ) references attributes.PR_LEN_Program_Length_Fact(PR_LEN_ID),
            constraint pkPR_LEN_Program_Length_Meta primary key (
                PR_LEN_ID,
                PR_LEN_Who,
                PR_LEN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW attributes.EV_DAT_Event_Date AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Who,
    a.EV_DAT_Confidence,
    a.EV_DAT_Stance
FROM
    attributes.EV_DAT_Event_Date_Fact p
JOIN
    attributes.EV_DAT_Event_Date_Meta a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
;
CREATE OR REPLACE VIEW attributes.EV_AUD_Event_Audience AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Who,
    a.EV_AUD_Confidence,
    a.EV_AUD_Stance
FROM
    attributes.EV_AUD_Event_Audience_Fact p
JOIN
    attributes.EV_AUD_Event_Audience_Meta a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
;
CREATE OR REPLACE VIEW attributes.EV_REV_Event_Revenue AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue,
    a.EV_REV_PositedAt,
    a.EV_REV_Who,
    a.EV_REV_Confidence,
    a.EV_REV_Stance
FROM
    attributes.EV_REV_Event_Revenue_Fact p
JOIN
    attributes.EV_REV_Event_Revenue_Meta a
ON
    a.EV_REV_ID = p.EV_REV_ID
;
CREATE OR REPLACE VIEW attributes.EV_STA_Event_Status AS
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    p.EV_STA_EV_ID,
    p.EV_STA_Event_Status,
    p.EV_STA_ChangedAt,
    a.EV_STA_PositedAt,
    a.EV_STA_Who,
    a.EV_STA_Confidence,
    a.EV_STA_Stance
FROM
    attributes.EV_STA_Event_Status_Fact p
JOIN
    attributes.EV_STA_Event_Status_Meta a
ON
    a.EV_STA_ID = p.EV_STA_ID
;
CREATE OR REPLACE VIEW attributes.EV_UTL_Event_Utilization AS
SELECT
    a.Metadata_EV_UTL,
    p.EV_UTL_ID,
    p.EV_UTL_EV_ID,
    p.EV_UTL_UTL_ID,
    a.EV_UTL_PositedAt,
    a.EV_UTL_Who,
    a.EV_UTL_Confidence,
    a.EV_UTL_Stance
FROM
    attributes.EV_UTL_Event_Utilization_Fact p
JOIN
    attributes.EV_UTL_Event_Utilization_Meta a
ON
    a.EV_UTL_ID = p.EV_UTL_ID
;
CREATE OR REPLACE VIEW attributes.EV_LVL_Event_Level AS
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID,
    p.EV_LVL_ChangedAt,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Who,
    a.EV_LVL_Confidence,
    a.EV_LVL_Stance
FROM
    attributes.EV_LVL_Event_Level_Fact p
JOIN
    attributes.EV_LVL_Event_Level_Meta a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
;
CREATE OR REPLACE VIEW attributes.ST_NAM_Stage_Name AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Who,
    a.ST_NAM_Confidence,
    a.ST_NAM_Stance
FROM
    attributes.ST_NAM_Stage_Name_Fact p
JOIN
    attributes.ST_NAM_Stage_Name_Meta a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
;
CREATE OR REPLACE VIEW attributes.ST_LOC_Stage_Location AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Who,
    a.ST_LOC_Confidence,
    a.ST_LOC_Stance
FROM
    attributes.ST_LOC_Stage_Location_Fact p
JOIN
    attributes.ST_LOC_Stage_Location_Meta a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
;
CREATE OR REPLACE VIEW attributes.ST_AVG_Stage_Average AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Who,
    a.ST_AVG_Confidence,
    a.ST_AVG_Stance
FROM
    attributes.ST_AVG_Stage_Average_Fact p
JOIN
    attributes.ST_AVG_Stage_Average_Meta a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
;
CREATE OR REPLACE VIEW attributes.ST_MIN_Stage_Minimum AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Who,
    a.ST_MIN_Confidence,
    a.ST_MIN_Stance
FROM
    attributes.ST_MIN_Stage_Minimum_Fact p
JOIN
    attributes.ST_MIN_Stage_Minimum_Meta a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
;
CREATE OR REPLACE VIEW attributes.AC_NAM_Actor_Name AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Who,
    a.AC_NAM_Confidence,
    a.AC_NAM_Stance
FROM
    attributes.AC_NAM_Actor_Name_Fact p
JOIN
    attributes.AC_NAM_Actor_Name_Meta a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
;
CREATE OR REPLACE VIEW attributes.AC_GEN_Actor_Gender AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Who,
    a.AC_GEN_Confidence,
    a.AC_GEN_Stance
FROM
    attributes.AC_GEN_Actor_Gender_Fact p
JOIN
    attributes.AC_GEN_Actor_Gender_Meta a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
;
CREATE OR REPLACE VIEW attributes.AC_PLV_Actor_ProfessionalLevel AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Who,
    a.AC_PLV_Confidence,
    a.AC_PLV_Stance
FROM
    attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
JOIN
    attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
;
CREATE OR REPLACE VIEW attributes.PR_NAM_Program_Name AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Who,
    a.PR_NAM_Confidence,
    a.PR_NAM_Stance
FROM
    attributes.PR_NAM_Program_Name_Fact p
JOIN
    attributes.PR_NAM_Program_Name_Meta a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
;
CREATE OR REPLACE VIEW attributes.PR_LEN_Program_Length AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Who,
    a.PR_LEN_Confidence,
    a.PR_LEN_Stance
FROM
    attributes.PR_LEN_Program_Length_Fact p
JOIN
    attributes.PR_LEN_Program_Length_Meta a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These SQL table macros rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the
-- union of the two will produce all rows in a posit table.
--
-- A SQL table macro (SQL_MACRO, Oracle Database 19.7 or later) is a function that returns the text of a query, in which
-- its parameters stand for the values given. It is called in the FROM clause of a query, like a table:
-- SELECT * FROM rAC_NAM_Actor_Name(CAST(NULL AS number), TIMESTAMP '2020-01-01 00:00:00', TIMESTAMP '2020-01-01 00:00:00').
--
-- The assembled rewinder and forwarder pick, for each posit and positor, the annex row that was last posited
-- at or before the positing time (the macros do not call each other, they do what the others do in their own query).
--
-- @positor the view of which positor to adopt, or null for the views of all of them
-- @changingTimepoint the point in changing time to rewind to
-- @positingTimepoint the point in positing time to rewind to
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_DAT_Event_Date_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Who,
            EV_DAT_Confidence,
            EV_DAT_Stance
        FROM
            attributes.EV_DAT_Event_Date_Meta
        WHERE
            EV_DAT_PositedAt <= positingTimepoint
    ]';
END rEV_DAT_Event_Date_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_DAT_Event_Date (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Who,
            EV_DAT_Confidence,
            EV_DAT_Stance,
            EV_DAT_EV_ID,
            EV_DAT_Event_Date
        FROM (
            SELECT
                a.Metadata_EV_DAT,
                p.EV_DAT_ID,
                a.EV_DAT_PositedAt,
                a.EV_DAT_Who,
                a.EV_DAT_Confidence,
                a.EV_DAT_Stance,
                p.EV_DAT_EV_ID,
                p.EV_DAT_Event_Date,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_DAT_ID,
                        a.EV_DAT_Who
                    ORDER BY
                        a.EV_DAT_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_DAT_Event_Date_Fact p
            JOIN
                attributes.EV_DAT_Event_Date_Meta a
            ON
                a.EV_DAT_ID = p.EV_DAT_ID
            AND
                a.EV_DAT_Who = COALESCE(positor, a.EV_DAT_Who)
            WHERE
                a.EV_DAT_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_DAT_Event_Date;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_AUD_Event_Audience_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Who,
            EV_AUD_Confidence,
            EV_AUD_Stance
        FROM
            attributes.EV_AUD_Event_Audience_Meta
        WHERE
            EV_AUD_PositedAt <= positingTimepoint
    ]';
END rEV_AUD_Event_Audience_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_AUD_Event_Audience (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Who,
            EV_AUD_Confidence,
            EV_AUD_Stance,
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience
        FROM (
            SELECT
                a.Metadata_EV_AUD,
                p.EV_AUD_ID,
                a.EV_AUD_PositedAt,
                a.EV_AUD_Who,
                a.EV_AUD_Confidence,
                a.EV_AUD_Stance,
                p.EV_AUD_EV_ID,
                p.EV_AUD_Event_Audience,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_AUD_ID,
                        a.EV_AUD_Who
                    ORDER BY
                        a.EV_AUD_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_AUD_Event_Audience_Fact p
            JOIN
                attributes.EV_AUD_Event_Audience_Meta a
            ON
                a.EV_AUD_ID = p.EV_AUD_ID
            AND
                a.EV_AUD_Who = COALESCE(positor, a.EV_AUD_Who)
            WHERE
                a.EV_AUD_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_AUD_Event_Audience;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_REV_Event_Revenue_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Who,
            EV_REV_Confidence,
            EV_REV_Stance
        FROM
            attributes.EV_REV_Event_Revenue_Meta
        WHERE
            EV_REV_PositedAt <= positingTimepoint
    ]';
END rEV_REV_Event_Revenue_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_REV_Event_Revenue (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Who,
            EV_REV_Confidence,
            EV_REV_Stance,
            EV_REV_EV_ID,
            EV_REV_Event_Revenue
        FROM (
            SELECT
                a.Metadata_EV_REV,
                p.EV_REV_ID,
                a.EV_REV_PositedAt,
                a.EV_REV_Who,
                a.EV_REV_Confidence,
                a.EV_REV_Stance,
                p.EV_REV_EV_ID,
                p.EV_REV_Event_Revenue,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_REV_ID,
                        a.EV_REV_Who
                    ORDER BY
                        a.EV_REV_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_REV_Event_Revenue_Fact p
            JOIN
                attributes.EV_REV_Event_Revenue_Meta a
            ON
                a.EV_REV_ID = p.EV_REV_ID
            AND
                a.EV_REV_Who = COALESCE(positor, a.EV_REV_Who)
            WHERE
                a.EV_REV_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_REV_Event_Revenue;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_STA_ID,
            EV_STA_EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt
        FROM
            attributes.EV_STA_Event_Status_Fact
        WHERE
            EV_STA_ChangedAt <= changingTimepoint
    ]';
END rEV_STA_Event_Status_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_STA_Event_Status_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_STA_ID,
            EV_STA_EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt
        FROM
            attributes.EV_STA_Event_Status_Fact
        WHERE
            EV_STA_ChangedAt > changingTimepoint
    ]';
END fEV_STA_Event_Status_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Who,
            EV_STA_Confidence,
            EV_STA_Stance
        FROM
            attributes.EV_STA_Event_Status_Meta
        WHERE
            EV_STA_PositedAt <= positingTimepoint
    ]';
END rEV_STA_Event_Status_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Who,
            EV_STA_Confidence,
            EV_STA_Stance,
            EV_STA_EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_STA,
                p.EV_STA_ID,
                a.EV_STA_PositedAt,
                a.EV_STA_Who,
                a.EV_STA_Confidence,
                a.EV_STA_Stance,
                p.EV_STA_EV_ID,
                p.EV_STA_Event_Status,
                p.EV_STA_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_STA_ID,
                        a.EV_STA_Who
                    ORDER BY
                        a.EV_STA_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_STA_Event_Status_Fact p
            JOIN
                attributes.EV_STA_Event_Status_Meta a
            ON
                a.EV_STA_ID = p.EV_STA_ID
            AND
                a.EV_STA_Who = COALESCE(positor, a.EV_STA_Who)
            WHERE
                p.EV_STA_ChangedAt <= changingTimepoint
            AND
                a.EV_STA_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_STA_Event_Status;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_STA_Event_Status (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Who,
            EV_STA_Confidence,
            EV_STA_Stance,
            EV_STA_EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_STA,
                p.EV_STA_ID,
                a.EV_STA_PositedAt,
                a.EV_STA_Who,
                a.EV_STA_Confidence,
                a.EV_STA_Stance,
                p.EV_STA_EV_ID,
                p.EV_STA_Event_Status,
                p.EV_STA_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_STA_ID,
                        a.EV_STA_Who
                    ORDER BY
                        a.EV_STA_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_STA_Event_Status_Fact p
            JOIN
                attributes.EV_STA_Event_Status_Meta a
            ON
                a.EV_STA_ID = p.EV_STA_ID
            AND
                a.EV_STA_Who = COALESCE(positor, a.EV_STA_Who)
            WHERE
                p.EV_STA_ChangedAt > changingTimepoint
            AND
                a.EV_STA_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_STA_Event_Status;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_UTL_Event_Utilization_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Who,
            EV_UTL_Confidence,
            EV_UTL_Stance
        FROM
            attributes.EV_UTL_Event_Utilization_Meta
        WHERE
            EV_UTL_PositedAt <= positingTimepoint
    ]';
END rEV_UTL_Event_Utilization_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_UTL_Event_Utilization (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Who,
            EV_UTL_Confidence,
            EV_UTL_Stance,
            EV_UTL_EV_ID,
            EV_UTL_UTL_ID
        FROM (
            SELECT
                a.Metadata_EV_UTL,
                p.EV_UTL_ID,
                a.EV_UTL_PositedAt,
                a.EV_UTL_Who,
                a.EV_UTL_Confidence,
                a.EV_UTL_Stance,
                p.EV_UTL_EV_ID,
                p.EV_UTL_UTL_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_UTL_ID,
                        a.EV_UTL_Who
                    ORDER BY
                        a.EV_UTL_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_UTL_Event_Utilization_Fact p
            JOIN
                attributes.EV_UTL_Event_Utilization_Meta a
            ON
                a.EV_UTL_ID = p.EV_UTL_ID
            AND
                a.EV_UTL_Who = COALESCE(positor, a.EV_UTL_Who)
            WHERE
                a.EV_UTL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_UTL_Event_Utilization;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level_Fact (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_LVL_ID,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM
            attributes.EV_LVL_Event_Level_Fact
        WHERE
            EV_LVL_ChangedAt <= changingTimepoint
    ]';
END rEV_LVL_Event_Level_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_LVL_Event_Level_Fact (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_LVL_ID,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM
            attributes.EV_LVL_Event_Level_Fact
        WHERE
            EV_LVL_ChangedAt > changingTimepoint
    ]';
END fEV_LVL_Event_Level_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Who,
            EV_LVL_Confidence,
            EV_LVL_Stance
        FROM
            attributes.EV_LVL_Event_Level_Meta
        WHERE
            EV_LVL_PositedAt <= positingTimepoint
    ]';
END rEV_LVL_Event_Level_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Who,
            EV_LVL_Confidence,
            EV_LVL_Stance,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_LVL,
                p.EV_LVL_ID,
                a.EV_LVL_PositedAt,
                a.EV_LVL_Who,
                a.EV_LVL_Confidence,
                a.EV_LVL_Stance,
                p.EV_LVL_EV_ID,
                p.EV_LVL_PLV_ID,
                p.EV_LVL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_LVL_ID,
                        a.EV_LVL_Who
                    ORDER BY
                        a.EV_LVL_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_LVL_Event_Level_Fact p
            JOIN
                attributes.EV_LVL_Event_Level_Meta a
            ON
                a.EV_LVL_ID = p.EV_LVL_ID
            AND
                a.EV_LVL_Who = COALESCE(positor, a.EV_LVL_Who)
            WHERE
                p.EV_LVL_ChangedAt <= changingTimepoint
            AND
                a.EV_LVL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_LVL_Event_Level;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_LVL_Event_Level (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Who,
            EV_LVL_Confidence,
            EV_LVL_Stance,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_LVL,
                p.EV_LVL_ID,
                a.EV_LVL_PositedAt,
                a.EV_LVL_Who,
                a.EV_LVL_Confidence,
                a.EV_LVL_Stance,
                p.EV_LVL_EV_ID,
                p.EV_LVL_PLV_ID,
                p.EV_LVL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_LVL_ID,
                        a.EV_LVL_Who
                    ORDER BY
                        a.EV_LVL_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_LVL_Event_Level_Fact p
            JOIN
                attributes.EV_LVL_Event_Level_Meta a
            ON
                a.EV_LVL_ID = p.EV_LVL_ID
            AND
                a.EV_LVL_Who = COALESCE(positor, a.EV_LVL_Who)
            WHERE
                p.EV_LVL_ChangedAt > changingTimepoint
            AND
                a.EV_LVL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_LVL_Event_Level;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM
            attributes.ST_NAM_Stage_Name_Fact
        WHERE
            ST_NAM_ChangedAt <= changingTimepoint
    ]';
END rST_NAM_Stage_Name_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fST_NAM_Stage_Name_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM
            attributes.ST_NAM_Stage_Name_Fact
        WHERE
            ST_NAM_ChangedAt > changingTimepoint
    ]';
END fST_NAM_Stage_Name_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Who,
            ST_NAM_Confidence,
            ST_NAM_Stance
        FROM
            attributes.ST_NAM_Stage_Name_Meta
        WHERE
            ST_NAM_PositedAt <= positingTimepoint
    ]';
END rST_NAM_Stage_Name_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Who,
            ST_NAM_Confidence,
            ST_NAM_Stance,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_NAM,
                p.ST_NAM_ID,
                a.ST_NAM_PositedAt,
                a.ST_NAM_Who,
                a.ST_NAM_Confidence,
                a.ST_NAM_Stance,
                p.ST_NAM_ST_ID,
                p.ST_NAM_Stage_Name,
                p.ST_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_NAM_ID,
                        a.ST_NAM_Who
                    ORDER BY
                        a.ST_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_NAM_Stage_Name_Fact p
            JOIN
                attributes.ST_NAM_Stage_Name_Meta a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            AND
                a.ST_NAM_Who = COALESCE(positor, a.ST_NAM_Who)
            WHERE
                p.ST_NAM_ChangedAt <= changingTimepoint
            AND
                a.ST_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_NAM_Stage_Name;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fST_NAM_Stage_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Who,
            ST_NAM_Confidence,
            ST_NAM_Stance,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_NAM,
                p.ST_NAM_ID,
                a.ST_NAM_PositedAt,
                a.ST_NAM_Who,
                a.ST_NAM_Confidence,
                a.ST_NAM_Stance,
                p.ST_NAM_ST_ID,
                p.ST_NAM_Stage_Name,
                p.ST_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_NAM_ID,
                        a.ST_NAM_Who
                    ORDER BY
                        a.ST_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_NAM_Stage_Name_Fact p
            JOIN
                attributes.ST_NAM_Stage_Name_Meta a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            AND
                a.ST_NAM_Who = COALESCE(positor, a.ST_NAM_Who)
            WHERE
                p.ST_NAM_ChangedAt > changingTimepoint
            AND
                a.ST_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fST_NAM_Stage_Name;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_LOC_Stage_Location_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Who,
            ST_LOC_Confidence,
            ST_LOC_Stance
        FROM
            attributes.ST_LOC_Stage_Location_Meta
        WHERE
            ST_LOC_PositedAt <= positingTimepoint
    ]';
END rST_LOC_Stage_Location_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_LOC_Stage_Location (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Who,
            ST_LOC_Confidence,
            ST_LOC_Stance,
            ST_LOC_ST_ID,
            ST_LOC_Checksum,
            ST_LOC_Stage_Location
        FROM (
            SELECT
                a.Metadata_ST_LOC,
                p.ST_LOC_ID,
                a.ST_LOC_PositedAt,
                a.ST_LOC_Who,
                a.ST_LOC_Confidence,
                a.ST_LOC_Stance,
                p.ST_LOC_ST_ID,
                p.ST_LOC_Checksum,
                p.ST_LOC_Stage_Location,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_LOC_ID,
                        a.ST_LOC_Who
                    ORDER BY
                        a.ST_LOC_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_LOC_Stage_Location_Fact p
            JOIN
                attributes.ST_LOC_Stage_Location_Meta a
            ON
                a.ST_LOC_ID = p.ST_LOC_ID
            AND
                a.ST_LOC_Who = COALESCE(positor, a.ST_LOC_Who)
            WHERE
                a.ST_LOC_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_LOC_Stage_Location;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM
            attributes.ST_AVG_Stage_Average_Fact
        WHERE
            ST_AVG_ChangedAt <= changingTimepoint
    ]';
END rST_AVG_Stage_Average_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fST_AVG_Stage_Average_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM
            attributes.ST_AVG_Stage_Average_Fact
        WHERE
            ST_AVG_ChangedAt > changingTimepoint
    ]';
END fST_AVG_Stage_Average_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Who,
            ST_AVG_Confidence,
            ST_AVG_Stance
        FROM
            attributes.ST_AVG_Stage_Average_Meta
        WHERE
            ST_AVG_PositedAt <= positingTimepoint
    ]';
END rST_AVG_Stage_Average_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Who,
            ST_AVG_Confidence,
            ST_AVG_Stance,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_AVG,
                p.ST_AVG_ID,
                a.ST_AVG_PositedAt,
                a.ST_AVG_Who,
                a.ST_AVG_Confidence,
                a.ST_AVG_Stance,
                p.ST_AVG_ST_ID,
                p.ST_AVG_UTL_ID,
                p.ST_AVG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_AVG_ID,
                        a.ST_AVG_Who
                    ORDER BY
                        a.ST_AVG_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_AVG_Stage_Average_Fact p
            JOIN
                attributes.ST_AVG_Stage_Average_Meta a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            AND
                a.ST_AVG_Who = COALESCE(positor, a.ST_AVG_Who)
            WHERE
                p.ST_AVG_ChangedAt <= changingTimepoint
            AND
                a.ST_AVG_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_AVG_Stage_Average;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fST_AVG_Stage_Average (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Who,
            ST_AVG_Confidence,
            ST_AVG_Stance,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_AVG,
                p.ST_AVG_ID,
                a.ST_AVG_PositedAt,
                a.ST_AVG_Who,
                a.ST_AVG_Confidence,
                a.ST_AVG_Stance,
                p.ST_AVG_ST_ID,
                p.ST_AVG_UTL_ID,
                p.ST_AVG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_AVG_ID,
                        a.ST_AVG_Who
                    ORDER BY
                        a.ST_AVG_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_AVG_Stage_Average_Fact p
            JOIN
                attributes.ST_AVG_Stage_Average_Meta a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            AND
                a.ST_AVG_Who = COALESCE(positor, a.ST_AVG_Who)
            WHERE
                p.ST_AVG_ChangedAt > changingTimepoint
            AND
                a.ST_AVG_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fST_AVG_Stage_Average;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_MIN_Stage_Minimum_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Who,
            ST_MIN_Confidence,
            ST_MIN_Stance
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta
        WHERE
            ST_MIN_PositedAt <= positingTimepoint
    ]';
END rST_MIN_Stage_Minimum_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_MIN_Stage_Minimum (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Who,
            ST_MIN_Confidence,
            ST_MIN_Stance,
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        FROM (
            SELECT
                a.Metadata_ST_MIN,
                p.ST_MIN_ID,
                a.ST_MIN_PositedAt,
                a.ST_MIN_Who,
                a.ST_MIN_Confidence,
                a.ST_MIN_Stance,
                p.ST_MIN_ST_ID,
                p.ST_MIN_UTL_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_MIN_ID,
                        a.ST_MIN_Who
                    ORDER BY
                        a.ST_MIN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_MIN_Stage_Minimum_Fact p
            JOIN
                attributes.ST_MIN_Stage_Minimum_Meta a
            ON
                a.ST_MIN_ID = p.ST_MIN_ID
            AND
                a.ST_MIN_Who = COALESCE(positor, a.ST_MIN_Who)
            WHERE
                a.ST_MIN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_MIN_Stage_Minimum;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM
            attributes.AC_NAM_Actor_Name_Fact
        WHERE
            AC_NAM_ChangedAt <= changingTimepoint
    ]';
END rAC_NAM_Actor_Name_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fAC_NAM_Actor_Name_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM
            attributes.AC_NAM_Actor_Name_Fact
        WHERE
            AC_NAM_ChangedAt > changingTimepoint
    ]';
END fAC_NAM_Actor_Name_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Who,
            AC_NAM_Confidence,
            AC_NAM_Stance
        FROM
            attributes.AC_NAM_Actor_Name_Meta
        WHERE
            AC_NAM_PositedAt <= positingTimepoint
    ]';
END rAC_NAM_Actor_Name_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Who,
            AC_NAM_Confidence,
            AC_NAM_Stance,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_NAM,
                p.AC_NAM_ID,
                a.AC_NAM_PositedAt,
                a.AC_NAM_Who,
                a.AC_NAM_Confidence,
                a.AC_NAM_Stance,
                p.AC_NAM_AC_ID,
                p.AC_NAM_Actor_Name,
                p.AC_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_NAM_ID,
                        a.AC_NAM_Who
                    ORDER BY
                        a.AC_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_NAM_Actor_Name_Fact p
            JOIN
                attributes.AC_NAM_Actor_Name_Meta a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            AND
                a.AC_NAM_Who = COALESCE(positor, a.AC_NAM_Who)
            WHERE
                p.AC_NAM_ChangedAt <= changingTimepoint
            AND
                a.AC_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_NAM_Actor_Name;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fAC_NAM_Actor_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Who,
            AC_NAM_Confidence,
            AC_NAM_Stance,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_NAM,
                p.AC_NAM_ID,
                a.AC_NAM_PositedAt,
                a.AC_NAM_Who,
                a.AC_NAM_Confidence,
                a.AC_NAM_Stance,
                p.AC_NAM_AC_ID,
                p.AC_NAM_Actor_Name,
                p.AC_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_NAM_ID,
                        a.AC_NAM_Who
                    ORDER BY
                        a.AC_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_NAM_Actor_Name_Fact p
            JOIN
                attributes.AC_NAM_Actor_Name_Meta a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            AND
                a.AC_NAM_Who = COALESCE(positor, a.AC_NAM_Who)
            WHERE
                p.AC_NAM_ChangedAt > changingTimepoint
            AND
                a.AC_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_NAM_Actor_Name;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_GEN_Actor_Gender_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Who,
            AC_GEN_Confidence,
            AC_GEN_Stance
        FROM
            attributes.AC_GEN_Actor_Gender_Meta
        WHERE
            AC_GEN_PositedAt <= positingTimepoint
    ]';
END rAC_GEN_Actor_Gender_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_GEN_Actor_Gender (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Who,
            AC_GEN_Confidence,
            AC_GEN_Stance,
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        FROM (
            SELECT
                a.Metadata_AC_GEN,
                p.AC_GEN_ID,
                a.AC_GEN_PositedAt,
                a.AC_GEN_Who,
                a.AC_GEN_Confidence,
                a.AC_GEN_Stance,
                p.AC_GEN_AC_ID,
                p.AC_GEN_GEN_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_GEN_ID,
                        a.AC_GEN_Who
                    ORDER BY
                        a.AC_GEN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_GEN_Actor_Gender_Fact p
            JOIN
                attributes.AC_GEN_Actor_Gender_Meta a
            ON
                a.AC_GEN_ID = p.AC_GEN_ID
            AND
                a.AC_GEN_Who = COALESCE(positor, a.AC_GEN_Who)
            WHERE
                a.AC_GEN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_GEN_Actor_Gender;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact
        WHERE
            AC_PLV_ChangedAt <= changingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fAC_PLV_Actor_ProfessionalLevel_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact
        WHERE
            AC_PLV_ChangedAt > changingTimepoint
    ]';
END fAC_PLV_Actor_ProfessionalLevel_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Who,
            AC_PLV_Confidence,
            AC_PLV_Stance
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta
        WHERE
            AC_PLV_PositedAt <= positingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Who,
            AC_PLV_Confidence,
            AC_PLV_Stance,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_PLV,
                p.AC_PLV_ID,
                a.AC_PLV_PositedAt,
                a.AC_PLV_Who,
                a.AC_PLV_Confidence,
                a.AC_PLV_Stance,
                p.AC_PLV_AC_ID,
                p.AC_PLV_PLV_ID,
                p.AC_PLV_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_PLV_ID,
                        a.AC_PLV_Who
                    ORDER BY
                        a.AC_PLV_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
            JOIN
                attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            AND
                a.AC_PLV_Who = COALESCE(positor, a.AC_PLV_Who)
            WHERE
                p.AC_PLV_ChangedAt <= changingTimepoint
            AND
                a.AC_PLV_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_PLV_Actor_ProfessionalLevel;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fAC_PLV_Actor_ProfessionalLevel (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Who,
            AC_PLV_Confidence,
            AC_PLV_Stance,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_PLV,
                p.AC_PLV_ID,
                a.AC_PLV_PositedAt,
                a.AC_PLV_Who,
                a.AC_PLV_Confidence,
                a.AC_PLV_Stance,
                p.AC_PLV_AC_ID,
                p.AC_PLV_PLV_ID,
                p.AC_PLV_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_PLV_ID,
                        a.AC_PLV_Who
                    ORDER BY
                        a.AC_PLV_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
            JOIN
                attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            AND
                a.AC_PLV_Who = COALESCE(positor, a.AC_PLV_Who)
            WHERE
                p.AC_PLV_ChangedAt > changingTimepoint
            AND
                a.AC_PLV_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_PLV_Actor_ProfessionalLevel;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_NAM_Program_Name_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Who,
            PR_NAM_Confidence,
            PR_NAM_Stance
        FROM
            attributes.PR_NAM_Program_Name_Meta
        WHERE
            PR_NAM_PositedAt <= positingTimepoint
    ]';
END rPR_NAM_Program_Name_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_NAM_Program_Name (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Who,
            PR_NAM_Confidence,
            PR_NAM_Stance,
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        FROM (
            SELECT
                a.Metadata_PR_NAM,
                p.PR_NAM_ID,
                a.PR_NAM_PositedAt,
                a.PR_NAM_Who,
                a.PR_NAM_Confidence,
                a.PR_NAM_Stance,
                p.PR_NAM_PR_ID,
                p.PR_NAM_Program_Name,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_NAM_ID,
                        a.PR_NAM_Who
                    ORDER BY
                        a.PR_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.PR_NAM_Program_Name_Fact p
            JOIN
                attributes.PR_NAM_Program_Name_Meta a
            ON
                a.PR_NAM_ID = p.PR_NAM_ID
            AND
                a.PR_NAM_Who = COALESCE(positor, a.PR_NAM_Who)
            WHERE
                a.PR_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_NAM_Program_Name;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length_Fact (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM
            attributes.PR_LEN_Program_Length_Fact
        WHERE
            PR_LEN_ChangedAt <= changingTimepoint
    ]';
END rPR_LEN_Program_Length_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fPR_LEN_Program_Length_Fact (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM
            attributes.PR_LEN_Program_Length_Fact
        WHERE
            PR_LEN_ChangedAt > changingTimepoint
    ]';
END fPR_LEN_Program_Length_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Who,
            PR_LEN_Confidence,
            PR_LEN_Stance
        FROM
            attributes.PR_LEN_Program_Length_Meta
        WHERE
            PR_LEN_PositedAt <= positingTimepoint
    ]';
END rPR_LEN_Program_Length_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Who,
            PR_LEN_Confidence,
            PR_LEN_Stance,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM (
            SELECT
                a.Metadata_PR_LEN,
                p.PR_LEN_ID,
                a.PR_LEN_PositedAt,
                a.PR_LEN_Who,
                a.PR_LEN_Confidence,
                a.PR_LEN_Stance,
                p.PR_LEN_PR_ID,
                p.PR_LEN_Program_Length,
                p.PR_LEN_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_LEN_ID,
                        a.PR_LEN_Who
                    ORDER BY
                        a.PR_LEN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.PR_LEN_Program_Length_Fact p
            JOIN
                attributes.PR_LEN_Program_Length_Meta a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            AND
                a.PR_LEN_Who = COALESCE(positor, a.PR_LEN_Who)
            WHERE
                p.PR_LEN_ChangedAt <= changingTimepoint
            AND
                a.PR_LEN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_LEN_Program_Length;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fPR_LEN_Program_Length (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Who,
            PR_LEN_Confidence,
            PR_LEN_Stance,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM (
            SELECT
                a.Metadata_PR_LEN,
                p.PR_LEN_ID,
                a.PR_LEN_PositedAt,
                a.PR_LEN_Who,
                a.PR_LEN_Confidence,
                a.PR_LEN_Stance,
                p.PR_LEN_PR_ID,
                p.PR_LEN_Program_Length,
                p.PR_LEN_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_LEN_ID,
                        a.PR_LEN_Who
                    ORDER BY
                        a.PR_LEN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.PR_LEN_Program_Length_Fact p
            JOIN
                attributes.PR_LEN_Program_Length_Meta a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            AND
                a.PR_LEN_Who = COALESCE(positor, a.PR_LEN_Who)
            WHERE
                p.PR_LEN_ChangedAt > changingTimepoint
            AND
                a.PR_LEN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fPR_LEN_Program_Length;
/
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_Actor(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex with the latest positing time picked for each posit and positor.
--
-- The latest and now perspectives are views over the point-in-time macro. A macro cannot be given a column of another
-- table to work for each positor, so the point-in-time macro works out the views of all positors itself, as does the
-- difference macro. The time traveling macro shows one positor, given by its first argument.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tST_Stage (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Who,
            "NAM".ST_NAM_Confidence,
            "NAM".ST_NAM_Stance,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Who,
            "LOC".ST_LOC_Confidence,
            "LOC".ST_LOC_Stance,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Who,
            "AVG".ST_AVG_Confidence,
            "AVG".ST_AVG_Stance,
            "AVG".ST_AVG_UTL_Utilization,
            "AVG".ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Who,
            "MIN".ST_MIN_Confidence,
            "MIN".ST_MIN_Stance,
            "MIN".ST_MIN_UTL_Utilization,
            "MIN".ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            anchors.ST_Stage "ST"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_NAM_Who, x.ST_NAM_ST_ID
                        ORDER BY
                            x.ST_NAM_ChangedAt DESC,
                            x.ST_NAM_PositedAt DESC,
                            x.ST_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_NAM_Stance <> '?' THEN r.ST_NAM_ChangedAt END) OVER (
                            PARTITION BY r.ST_NAM_Who, r.ST_NAM_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Who,
                            an.ST_NAM_Confidence,
                            an.ST_NAM_Stance,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Stage_Name,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID, an.ST_NAM_Who
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_NAM_Stage_Name_Fact po
                        JOIN
                            attributes.ST_NAM_Stage_Name_Meta an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                        WHERE
                            po.ST_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_NAM_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_NAM_Stance = COALESCE(assertion, x.ST_NAM_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.ST_NAM_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_LOC_Who, x.ST_LOC_ST_ID
                        ORDER BY
                            x.ST_LOC_PositedAt DESC,
                            x.ST_LOC_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_LOC,
                            po.ST_LOC_ID,
                            an.ST_LOC_PositedAt,
                            an.ST_LOC_Who,
                            an.ST_LOC_Confidence,
                            an.ST_LOC_Stance,
                            po.ST_LOC_ST_ID,
                            po.ST_LOC_Checksum,
                            po.ST_LOC_Stage_Location,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_LOC_ID, an.ST_LOC_Who
                                ORDER BY an.ST_LOC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_LOC_Stage_Location_Fact po
                        JOIN
                            attributes.ST_LOC_Stage_Location_Meta an
                        ON
                            an.ST_LOC_ID = po.ST_LOC_ID
                        WHERE
                            an.ST_LOC_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_LOC_Stance = COALESCE(assertion, x.ST_LOC_Stance)
            ) y
            WHERE
                y.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        AND
            "LOC".ST_LOC_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_AVG_Metadata_UTL,
                k.UTL_Utilization AS ST_AVG_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_AVG_Who, x.ST_AVG_ST_ID
                        ORDER BY
                            x.ST_AVG_ChangedAt DESC,
                            x.ST_AVG_PositedAt DESC,
                            x.ST_AVG_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_AVG_Stance <> '?' THEN r.ST_AVG_ChangedAt END) OVER (
                            PARTITION BY r.ST_AVG_Who, r.ST_AVG_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Who,
                            an.ST_AVG_Confidence,
                            an.ST_AVG_Stance,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID, an.ST_AVG_Who
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_AVG_Stage_Average_Fact po
                        JOIN
                            attributes.ST_AVG_Stage_Average_Meta an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                        WHERE
                            po.ST_AVG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_AVG_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_AVG_Stance = COALESCE(assertion, x.ST_AVG_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.ST_AVG_ChangedAt = x.inEffect
                )
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.ST_AVG_UTL_ID
            WHERE
                y.pickRank = 1
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_MIN_Metadata_UTL,
                k.UTL_Utilization AS ST_MIN_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_MIN_Who, x.ST_MIN_ST_ID
                        ORDER BY
                            x.ST_MIN_PositedAt DESC,
                            x.ST_MIN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_MIN,
                            po.ST_MIN_ID,
                            an.ST_MIN_PositedAt,
                            an.ST_MIN_Who,
                            an.ST_MIN_Confidence,
                            an.ST_MIN_Stance,
                            po.ST_MIN_ST_ID,
                            po.ST_MIN_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_MIN_ID, an.ST_MIN_Who
                                ORDER BY an.ST_MIN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_MIN_Stage_Minimum_Fact po
                        JOIN
                            attributes.ST_MIN_Stage_Minimum_Meta an
                        ON
                            an.ST_MIN_ID = po.ST_MIN_ID
                        WHERE
                            an.ST_MIN_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_MIN_Stance = COALESCE(assertion, x.ST_MIN_Stance)
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.ST_MIN_UTL_ID
            WHERE
                y.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        AND
            "MIN".ST_MIN_Who = positorTable.Who
        WHERE
            positorTable.Who = forPositor
    ]';
END tST_Stage;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pST_Stage (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Who,
            "NAM".ST_NAM_Confidence,
            "NAM".ST_NAM_Stance,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Who,
            "LOC".ST_LOC_Confidence,
            "LOC".ST_LOC_Stance,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Who,
            "AVG".ST_AVG_Confidence,
            "AVG".ST_AVG_Stance,
            "AVG".ST_AVG_UTL_Utilization,
            "AVG".ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Who,
            "MIN".ST_MIN_Confidence,
            "MIN".ST_MIN_Stance,
            "MIN".ST_MIN_UTL_Utilization,
            "MIN".ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            anchors.ST_Stage "ST"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_NAM_Who, x.ST_NAM_ST_ID
                        ORDER BY
                            x.ST_NAM_ChangedAt DESC,
                            x.ST_NAM_PositedAt DESC,
                            x.ST_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_NAM_Stance <> '?' THEN r.ST_NAM_ChangedAt END) OVER (
                            PARTITION BY r.ST_NAM_Who, r.ST_NAM_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Who,
                            an.ST_NAM_Confidence,
                            an.ST_NAM_Stance,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Stage_Name,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID, an.ST_NAM_Who
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_NAM_Stage_Name_Fact po
                        JOIN
                            attributes.ST_NAM_Stage_Name_Meta an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                        WHERE
                            po.ST_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_NAM_Stance = '+'
                AND
                    x.ST_NAM_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_LOC_Who, x.ST_LOC_ST_ID
                        ORDER BY
                            x.ST_LOC_PositedAt DESC,
                            x.ST_LOC_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_LOC,
                            po.ST_LOC_ID,
                            an.ST_LOC_PositedAt,
                            an.ST_LOC_Who,
                            an.ST_LOC_Confidence,
                            an.ST_LOC_Stance,
                            po.ST_LOC_ST_ID,
                            po.ST_LOC_Checksum,
                            po.ST_LOC_Stage_Location,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_LOC_ID, an.ST_LOC_Who
                                ORDER BY an.ST_LOC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_LOC_Stage_Location_Fact po
                        JOIN
                            attributes.ST_LOC_Stage_Location_Meta an
                        ON
                            an.ST_LOC_ID = po.ST_LOC_ID
                        WHERE
                            an.ST_LOC_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_LOC_Stance = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        AND
            "LOC".ST_LOC_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_AVG_Metadata_UTL,
                k.UTL_Utilization AS ST_AVG_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_AVG_Who, x.ST_AVG_ST_ID
                        ORDER BY
                            x.ST_AVG_ChangedAt DESC,
                            x.ST_AVG_PositedAt DESC,
                            x.ST_AVG_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_AVG_Stance <> '?' THEN r.ST_AVG_ChangedAt END) OVER (
                            PARTITION BY r.ST_AVG_Who, r.ST_AVG_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Who,
                            an.ST_AVG_Confidence,
                            an.ST_AVG_Stance,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID, an.ST_AVG_Who
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_AVG_Stage_Average_Fact po
                        JOIN
                            attributes.ST_AVG_Stage_Average_Meta an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                        WHERE
                            po.ST_AVG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_AVG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_AVG_Stance = '+'
                AND
                    x.ST_AVG_ChangedAt = x.inEffect
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.ST_AVG_UTL_ID
            WHERE
                y.pickRank = 1
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_MIN_Metadata_UTL,
                k.UTL_Utilization AS ST_MIN_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_MIN_Who, x.ST_MIN_ST_ID
                        ORDER BY
                            x.ST_MIN_PositedAt DESC,
                            x.ST_MIN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_MIN,
                            po.ST_MIN_ID,
                            an.ST_MIN_PositedAt,
                            an.ST_MIN_Who,
                            an.ST_MIN_Confidence,
                            an.ST_MIN_Stance,
                            po.ST_MIN_ST_ID,
                            po.ST_MIN_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_MIN_ID, an.ST_MIN_Who
                                ORDER BY an.ST_MIN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_MIN_Stage_Minimum_Fact po
                        JOIN
                            attributes.ST_MIN_Stage_Minimum_Meta an
                        ON
                            an.ST_MIN_ID = po.ST_MIN_ID
                        WHERE
                            an.ST_MIN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_MIN_Stance = '+'
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.ST_MIN_UTL_ID
            WHERE
                y.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        AND
            "MIN".ST_MIN_Who = positorTable.Who
    ]';
END pST_Stage;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lST_Stage
AS
SELECT
    *
FROM
    anchors.pST_Stage(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nST_Stage
AS
SELECT
    *
FROM
    anchors.pST_Stage(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dST_Stage (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            timepoints.inspectedTimepoint,
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Who,
            "NAM".ST_NAM_Confidence,
            "NAM".ST_NAM_Stance,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Who,
            "LOC".ST_LOC_Confidence,
            "LOC".ST_LOC_Stance,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Who,
            "AVG".ST_AVG_Confidence,
            "AVG".ST_AVG_Stance,
            "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Who,
            "MIN".ST_MIN_Confidence,
            "MIN".ST_MIN_Stance,
            "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.ST_NAM_Who AS inspectedPositor,
                h.ST_NAM_ST_ID AS ST_ID,
                CAST(h.ST_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                attributes.ST_NAM_Stage_Name h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.ST_AVG_Who AS inspectedPositor,
                h.ST_AVG_ST_ID AS ST_ID,
                CAST(h.ST_AVG_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'AVG' AS mnemonic
            FROM
                attributes.ST_AVG_Stage_Average h
            WHERE
                (selection IS NULL OR selection LIKE '%AVG%')
            AND
                h.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        ON
            timepoints.inspectedPositor = positorTable.Who
        JOIN
            anchors.ST_Stage "ST"
        ON
            "ST".ST_ID = timepoints.ST_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.ST_NAM_ChangedAt) OVER (
                    PARTITION BY y.ST_NAM_Who, y.ST_NAM_ST_ID
                    ORDER BY y.ST_NAM_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.ST_NAM_Who, r.ST_NAM_ST_ID, r.ST_NAM_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_NAM_Stance = '+' THEN 0 ELSE 1 END,
                                r.ST_NAM_PositedAt DESC,
                                r.ST_NAM_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Who,
                            an.ST_NAM_Confidence,
                            an.ST_NAM_Stance,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Stage_Name,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID, an.ST_NAM_Who
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_NAM_Stage_Name_Fact po
                        JOIN
                            attributes.ST_NAM_Stage_Name_Meta an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_NAM_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_Who = timepoints.inspectedPositor
        AND
            "NAM".ST_NAM_Stance = '+'
        AND
            "NAM".ST_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_LOC_Who, r.ST_LOC_ST_ID
                        ORDER BY
                            r.ST_LOC_PositedAt DESC,
                            r.ST_LOC_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_LOC,
                        po.ST_LOC_ID,
                        an.ST_LOC_PositedAt,
                        an.ST_LOC_Who,
                        an.ST_LOC_Confidence,
                        an.ST_LOC_Stance,
                        po.ST_LOC_ST_ID,
                        po.ST_LOC_Checksum,
                        po.ST_LOC_Stage_Location,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_LOC_ID, an.ST_LOC_Who
                            ORDER BY an.ST_LOC_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.ST_LOC_Stage_Location_Fact po
                    JOIN
                        attributes.ST_LOC_Stage_Location_Meta an
                    ON
                        an.ST_LOC_ID = po.ST_LOC_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_LOC_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        AND
            "LOC".ST_LOC_Who = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.ST_AVG_ChangedAt) OVER (
                    PARTITION BY y.ST_AVG_Who, y.ST_AVG_ST_ID
                    ORDER BY y.ST_AVG_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.ST_AVG_Who, r.ST_AVG_ST_ID, r.ST_AVG_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_AVG_Stance = '+' THEN 0 ELSE 1 END,
                                r.ST_AVG_PositedAt DESC,
                                r.ST_AVG_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Who,
                            an.ST_AVG_Confidence,
                            an.ST_AVG_Stance,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID, an.ST_AVG_Who
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_AVG_Stage_Average_Fact po
                        JOIN
                            attributes.ST_AVG_Stage_Average_Meta an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_AVG_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_Who = timepoints.inspectedPositor
        AND
            "AVG".ST_AVG_Stance = '+'
        AND
            "AVG".ST_AVG_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "AVG".untilTime IS NULL
        OR
            "AVG".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_MIN_Who, r.ST_MIN_ST_ID
                        ORDER BY
                            r.ST_MIN_PositedAt DESC,
                            r.ST_MIN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_MIN,
                        po.ST_MIN_ID,
                        an.ST_MIN_PositedAt,
                        an.ST_MIN_Who,
                        an.ST_MIN_Confidence,
                        an.ST_MIN_Stance,
                        po.ST_MIN_ST_ID,
                        po.ST_MIN_UTL_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_MIN_ID, an.ST_MIN_Who
                            ORDER BY an.ST_MIN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.ST_MIN_Stage_Minimum_Fact po
                    JOIN
                        attributes.ST_MIN_Stage_Minimum_Meta an
                    ON
                        an.ST_MIN_ID = po.ST_MIN_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_MIN_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        AND
            "MIN".ST_MIN_Who = timepoints.inspectedPositor
        LEFT JOIN
            knots.UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END dST_Stage;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tAC_Actor (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Who,
            "NAM".AC_NAM_Confidence,
            "NAM".AC_NAM_Stance,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Who,
            "GEN".AC_GEN_Confidence,
            "GEN".AC_GEN_Stance,
            "GEN".AC_GEN_GEN_Checksum,
            "GEN".AC_GEN_GEN_Gender,
            "GEN".AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Who,
            "PLV".AC_PLV_Confidence,
            "PLV".AC_PLV_Stance,
            "PLV".AC_PLV_PLV_Checksum,
            "PLV".AC_PLV_PLV_ProfessionalLevel,
            "PLV".AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            anchors.AC_Actor "AC"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_NAM_Who, x.AC_NAM_AC_ID
                        ORDER BY
                            x.AC_NAM_ChangedAt DESC,
                            x.AC_NAM_PositedAt DESC,
                            x.AC_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_NAM_Stance <> '?' THEN r.AC_NAM_ChangedAt END) OVER (
                            PARTITION BY r.AC_NAM_Who, r.AC_NAM_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Who,
                            an.AC_NAM_Confidence,
                            an.AC_NAM_Stance,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Actor_Name,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID, an.AC_NAM_Who
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_NAM_Actor_Name_Fact po
                        JOIN
                            attributes.AC_NAM_Actor_Name_Meta an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                        WHERE
                            po.AC_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_NAM_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_NAM_Stance = COALESCE(assertion, x.AC_NAM_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.AC_NAM_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.GEN_Checksum AS AC_GEN_GEN_Checksum,
                k.Metadata_GEN AS AC_GEN_Metadata_GEN,
                k.GEN_Gender AS AC_GEN_GEN_Gender
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_GEN_Who, x.AC_GEN_AC_ID
                        ORDER BY
                            x.AC_GEN_PositedAt DESC,
                            x.AC_GEN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_AC_GEN,
                            po.AC_GEN_ID,
                            an.AC_GEN_PositedAt,
                            an.AC_GEN_Who,
                            an.AC_GEN_Confidence,
                            an.AC_GEN_Stance,
                            po.AC_GEN_AC_ID,
                            po.AC_GEN_GEN_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_GEN_ID, an.AC_GEN_Who
                                ORDER BY an.AC_GEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_GEN_Actor_Gender_Fact po
                        JOIN
                            attributes.AC_GEN_Actor_Gender_Meta an
                        ON
                            an.AC_GEN_ID = po.AC_GEN_ID
                        WHERE
                            an.AC_GEN_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_GEN_Stance = COALESCE(assertion, x.AC_GEN_Stance)
            ) y
            LEFT JOIN
                knots.GEN_Gender k
            ON
                k.GEN_ID = y.AC_GEN_GEN_ID
            WHERE
                y.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        AND
            "GEN".AC_GEN_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS AC_PLV_PLV_Checksum,
                k.Metadata_PLV AS AC_PLV_Metadata_PLV,
                k.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_PLV_Who, x.AC_PLV_AC_ID
                        ORDER BY
                            x.AC_PLV_ChangedAt DESC,
                            x.AC_PLV_PositedAt DESC,
                            x.AC_PLV_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_PLV_Stance <> '?' THEN r.AC_PLV_ChangedAt END) OVER (
                            PARTITION BY r.AC_PLV_Who, r.AC_PLV_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Who,
                            an.AC_PLV_Confidence,
                            an.AC_PLV_Stance,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID, an.AC_PLV_Who
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_PLV_Actor_ProfessionalLevel_Fact po
                        JOIN
                            attributes.AC_PLV_Actor_ProfessionalLevel_Meta an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                        WHERE
                            po.AC_PLV_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_PLV_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_PLV_Stance = COALESCE(assertion, x.AC_PLV_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.AC_PLV_ChangedAt = x.inEffect
                )
            ) y
            LEFT JOIN
                knots.PLV_ProfessionalLevel k
            ON
                k.PLV_ID = y.AC_PLV_PLV_ID
            WHERE
                y.pickRank = 1
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_Who = positorTable.Who
        WHERE
            positorTable.Who = forPositor
    ]';
END tAC_Actor;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pAC_Actor (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Who,
            "NAM".AC_NAM_Confidence,
            "NAM".AC_NAM_Stance,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Who,
            "GEN".AC_GEN_Confidence,
            "GEN".AC_GEN_Stance,
            "GEN".AC_GEN_GEN_Checksum,
            "GEN".AC_GEN_GEN_Gender,
            "GEN".AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Who,
            "PLV".AC_PLV_Confidence,
            "PLV".AC_PLV_Stance,
            "PLV".AC_PLV_PLV_Checksum,
            "PLV".AC_PLV_PLV_ProfessionalLevel,
            "PLV".AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            anchors.AC_Actor "AC"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_NAM_Who, x.AC_NAM_AC_ID
                        ORDER BY
                            x.AC_NAM_ChangedAt DESC,
                            x.AC_NAM_PositedAt DESC,
                            x.AC_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_NAM_Stance <> '?' THEN r.AC_NAM_ChangedAt END) OVER (
                            PARTITION BY r.AC_NAM_Who, r.AC_NAM_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Who,
                            an.AC_NAM_Confidence,
                            an.AC_NAM_Stance,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Actor_Name,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID, an.AC_NAM_Who
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_NAM_Actor_Name_Fact po
                        JOIN
                            attributes.AC_NAM_Actor_Name_Meta an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                        WHERE
                            po.AC_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_NAM_Stance = '+'
                AND
                    x.AC_NAM_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.GEN_Checksum AS AC_GEN_GEN_Checksum,
                k.Metadata_GEN AS AC_GEN_Metadata_GEN,
                k.GEN_Gender AS AC_GEN_GEN_Gender
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_GEN_Who, x.AC_GEN_AC_ID
                        ORDER BY
                            x.AC_GEN_PositedAt DESC,
                            x.AC_GEN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_AC_GEN,
                            po.AC_GEN_ID,
                            an.AC_GEN_PositedAt,
                            an.AC_GEN_Who,
                            an.AC_GEN_Confidence,
                            an.AC_GEN_Stance,
                            po.AC_GEN_AC_ID,
                            po.AC_GEN_GEN_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_GEN_ID, an.AC_GEN_Who
                                ORDER BY an.AC_GEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_GEN_Actor_Gender_Fact po
                        JOIN
                            attributes.AC_GEN_Actor_Gender_Meta an
                        ON
                            an.AC_GEN_ID = po.AC_GEN_ID
                        WHERE
                            an.AC_GEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_GEN_Stance = '+'
            ) y
            LEFT JOIN
                knots.GEN_Gender k
            ON
                k.GEN_ID = y.AC_GEN_GEN_ID
            WHERE
                y.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        AND
            "GEN".AC_GEN_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS AC_PLV_PLV_Checksum,
                k.Metadata_PLV AS AC_PLV_Metadata_PLV,
                k.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_PLV_Who, x.AC_PLV_AC_ID
                        ORDER BY
                            x.AC_PLV_ChangedAt DESC,
                            x.AC_PLV_PositedAt DESC,
                            x.AC_PLV_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_PLV_Stance <> '?' THEN r.AC_PLV_ChangedAt END) OVER (
                            PARTITION BY r.AC_PLV_Who, r.AC_PLV_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Who,
                            an.AC_PLV_Confidence,
                            an.AC_PLV_Stance,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID, an.AC_PLV_Who
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_PLV_Actor_ProfessionalLevel_Fact po
                        JOIN
                            attributes.AC_PLV_Actor_ProfessionalLevel_Meta an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                        WHERE
                            po.AC_PLV_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_PLV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_PLV_Stance = '+'
                AND
                    x.AC_PLV_ChangedAt = x.inEffect
            ) y
            LEFT JOIN
                knots.PLV_ProfessionalLevel k
            ON
                k.PLV_ID = y.AC_PLV_PLV_ID
            WHERE
                y.pickRank = 1
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_Who = positorTable.Who
    ]';
END pAC_Actor;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lAC_Actor
AS
SELECT
    *
FROM
    anchors.pAC_Actor(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nAC_Actor
AS
SELECT
    *
FROM
    anchors.pAC_Actor(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dAC_Actor (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            timepoints.inspectedTimepoint,
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Who,
            "NAM".AC_NAM_Confidence,
            "NAM".AC_NAM_Stance,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Who,
            "GEN".AC_GEN_Confidence,
            "GEN".AC_GEN_Stance,
            "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
            "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Who,
            "PLV".AC_PLV_Confidence,
            "PLV".AC_PLV_Stance,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_NAM_Who AS inspectedPositor,
                h.AC_NAM_AC_ID AS AC_ID,
                CAST(h.AC_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                attributes.AC_NAM_Actor_Name h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.AC_PLV_Who AS inspectedPositor,
                h.AC_PLV_AC_ID AS AC_ID,
                CAST(h.AC_PLV_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'PLV' AS mnemonic
            FROM
                attributes.AC_PLV_Actor_ProfessionalLevel h
            WHERE
                (selection IS NULL OR selection LIKE '%PLV%')
            AND
                h.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        ON
            timepoints.inspectedPositor = positorTable.Who
        JOIN
            anchors.AC_Actor "AC"
        ON
            "AC".AC_ID = timepoints.AC_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.AC_NAM_ChangedAt) OVER (
                    PARTITION BY y.AC_NAM_Who, y.AC_NAM_AC_ID
                    ORDER BY y.AC_NAM_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.AC_NAM_Who, r.AC_NAM_AC_ID, r.AC_NAM_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_NAM_Stance = '+' THEN 0 ELSE 1 END,
                                r.AC_NAM_PositedAt DESC,
                                r.AC_NAM_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Who,
                            an.AC_NAM_Confidence,
                            an.AC_NAM_Stance,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Actor_Name,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID, an.AC_NAM_Who
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_NAM_Actor_Name_Fact po
                        JOIN
                            attributes.AC_NAM_Actor_Name_Meta an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_NAM_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_Who = timepoints.inspectedPositor
        AND
            "NAM".AC_NAM_Stance = '+'
        AND
            "NAM".AC_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_GEN_Who, r.AC_GEN_AC_ID
                        ORDER BY
                            r.AC_GEN_PositedAt DESC,
                            r.AC_GEN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_GEN,
                        po.AC_GEN_ID,
                        an.AC_GEN_PositedAt,
                        an.AC_GEN_Who,
                        an.AC_GEN_Confidence,
                        an.AC_GEN_Stance,
                        po.AC_GEN_AC_ID,
                        po.AC_GEN_GEN_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_GEN_ID, an.AC_GEN_Who
                            ORDER BY an.AC_GEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.AC_GEN_Actor_Gender_Fact po
                    JOIN
                        attributes.AC_GEN_Actor_Gender_Meta an
                    ON
                        an.AC_GEN_ID = po.AC_GEN_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_GEN_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        AND
            "GEN".AC_GEN_Who = timepoints.inspectedPositor
        LEFT JOIN
            knots.GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.AC_PLV_ChangedAt) OVER (
                    PARTITION BY y.AC_PLV_Who, y.AC_PLV_AC_ID
                    ORDER BY y.AC_PLV_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.AC_PLV_Who, r.AC_PLV_AC_ID, r.AC_PLV_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_PLV_Stance = '+' THEN 0 ELSE 1 END,
                                r.AC_PLV_PositedAt DESC,
                                r.AC_PLV_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Who,
                            an.AC_PLV_Confidence,
                            an.AC_PLV_Stance,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID, an.AC_PLV_Who
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_PLV_Actor_ProfessionalLevel_Fact po
                        JOIN
                            attributes.AC_PLV_Actor_ProfessionalLevel_Meta an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_PLV_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_Who = timepoints.inspectedPositor
        AND
            "PLV".AC_PLV_Stance = '+'
        AND
            "PLV".AC_PLV_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "PLV".untilTime IS NULL
        OR
            "PLV".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END dAC_Actor;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tPR_Program (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Who,
            "NAM".PR_NAM_Confidence,
            "NAM".PR_NAM_Stance,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Who,
            "LEN".PR_LEN_Confidence,
            "LEN".PR_LEN_Stance,
            "LEN".PR_LEN_Program_Length
        FROM
            anchors.PR_Program "PR"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_NAM_Who, x.PR_NAM_PR_ID
                        ORDER BY
                            x.PR_NAM_PositedAt DESC,
                            x.PR_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_PR_NAM,
                            po.PR_NAM_ID,
                            an.PR_NAM_PositedAt,
                            an.PR_NAM_Who,
                            an.PR_NAM_Confidence,
                            an.PR_NAM_Stance,
                            po.PR_NAM_PR_ID,
                            po.PR_NAM_Program_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_NAM_ID, an.PR_NAM_Who
                                ORDER BY an.PR_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_NAM_Program_Name_Fact po
                        JOIN
                            attributes.PR_NAM_Program_Name_Meta an
                        ON
                            an.PR_NAM_ID = po.PR_NAM_ID
                        WHERE
                            an.PR_NAM_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_NAM_Stance = COALESCE(assertion, x.PR_NAM_Stance)
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        AND
            "NAM".PR_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_LEN_Who, x.PR_LEN_PR_ID
                        ORDER BY
                            x.PR_LEN_ChangedAt DESC,
                            x.PR_LEN_PositedAt DESC,
                            x.PR_LEN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.PR_LEN_Stance <> '?' THEN r.PR_LEN_ChangedAt END) OVER (
                            PARTITION BY r.PR_LEN_Who, r.PR_LEN_PR_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Who,
                            an.PR_LEN_Confidence,
                            an.PR_LEN_Stance,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Program_Length,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID, an.PR_LEN_Who
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_LEN_Program_Length_Fact po
                        JOIN
                            attributes.PR_LEN_Program_Length_Meta an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                        WHERE
                            po.PR_LEN_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.PR_LEN_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_LEN_Stance = COALESCE(assertion, x.PR_LEN_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.PR_LEN_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
        AND
            "LEN".PR_LEN_Who = positorTable.Who
        WHERE
            positorTable.Who = forPositor
    ]';
END tPR_Program;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pPR_Program (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Who,
            "NAM".PR_NAM_Confidence,
            "NAM".PR_NAM_Stance,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Who,
            "LEN".PR_LEN_Confidence,
            "LEN".PR_LEN_Stance,
            "LEN".PR_LEN_Program_Length
        FROM
            anchors.PR_Program "PR"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_NAM_Who, x.PR_NAM_PR_ID
                        ORDER BY
                            x.PR_NAM_PositedAt DESC,
                            x.PR_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_PR_NAM,
                            po.PR_NAM_ID,
                            an.PR_NAM_PositedAt,
                            an.PR_NAM_Who,
                            an.PR_NAM_Confidence,
                            an.PR_NAM_Stance,
                            po.PR_NAM_PR_ID,
                            po.PR_NAM_Program_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_NAM_ID, an.PR_NAM_Who
                                ORDER BY an.PR_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_NAM_Program_Name_Fact po
                        JOIN
                            attributes.PR_NAM_Program_Name_Meta an
                        ON
                            an.PR_NAM_ID = po.PR_NAM_ID
                        WHERE
                            an.PR_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_NAM_Stance = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        AND
            "NAM".PR_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_LEN_Who, x.PR_LEN_PR_ID
                        ORDER BY
                            x.PR_LEN_ChangedAt DESC,
                            x.PR_LEN_PositedAt DESC,
                            x.PR_LEN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.PR_LEN_Stance <> '?' THEN r.PR_LEN_ChangedAt END) OVER (
                            PARTITION BY r.PR_LEN_Who, r.PR_LEN_PR_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Who,
                            an.PR_LEN_Confidence,
                            an.PR_LEN_Stance,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Program_Length,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID, an.PR_LEN_Who
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_LEN_Program_Length_Fact po
                        JOIN
                            attributes.PR_LEN_Program_Length_Meta an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                        WHERE
                            po.PR_LEN_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.PR_LEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_LEN_Stance = '+'
                AND
                    x.PR_LEN_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
        AND
            "LEN".PR_LEN_Who = positorTable.Who
    ]';
END pPR_Program;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lPR_Program
AS
SELECT
    *
FROM
    anchors.pPR_Program(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nPR_Program
AS
SELECT
    *
FROM
    anchors.pPR_Program(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dPR_Program (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            timepoints.inspectedTimepoint,
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Who,
            "NAM".PR_NAM_Confidence,
            "NAM".PR_NAM_Stance,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Who,
            "LEN".PR_LEN_Confidence,
            "LEN".PR_LEN_Stance,
            "LEN".PR_LEN_Program_Length
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.PR_LEN_Who AS inspectedPositor,
                h.PR_LEN_PR_ID AS PR_ID,
                CAST(h.PR_LEN_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'LEN' AS mnemonic
            FROM
                attributes.PR_LEN_Program_Length h
            WHERE
                (selection IS NULL OR selection LIKE '%LEN%')
            AND
                h.PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        ON
            timepoints.inspectedPositor = positorTable.Who
        JOIN
            anchors.PR_Program "PR"
        ON
            "PR".PR_ID = timepoints.PR_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_NAM_Who, r.PR_NAM_PR_ID
                        ORDER BY
                            r.PR_NAM_PositedAt DESC,
                            r.PR_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_NAM,
                        po.PR_NAM_ID,
                        an.PR_NAM_PositedAt,
                        an.PR_NAM_Who,
                        an.PR_NAM_Confidence,
                        an.PR_NAM_Stance,
                        po.PR_NAM_PR_ID,
                        po.PR_NAM_Program_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_NAM_ID, an.PR_NAM_Who
                            ORDER BY an.PR_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.PR_NAM_Program_Name_Fact po
                    JOIN
                        attributes.PR_NAM_Program_Name_Meta an
                    ON
                        an.PR_NAM_ID = po.PR_NAM_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_NAM_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        AND
            "NAM".PR_NAM_Who = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.PR_LEN_ChangedAt) OVER (
                    PARTITION BY y.PR_LEN_Who, y.PR_LEN_PR_ID
                    ORDER BY y.PR_LEN_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.PR_LEN_Who, r.PR_LEN_PR_ID, r.PR_LEN_ChangedAt
                            ORDER BY
                                CASE WHEN r.PR_LEN_Stance = '+' THEN 0 ELSE 1 END,
                                r.PR_LEN_PositedAt DESC,
                                r.PR_LEN_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Who,
                            an.PR_LEN_Confidence,
                            an.PR_LEN_Stance,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Program_Length,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID, an.PR_LEN_Who
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_LEN_Program_Length_Fact po
                        JOIN
                            attributes.PR_LEN_Program_Length_Meta an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.PR_LEN_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
        AND
            "LEN".PR_LEN_Who = timepoints.inspectedPositor
        AND
            "LEN".PR_LEN_Stance = '+'
        AND
            "LEN".PR_LEN_ChangedAt <= CAST(timepoints.inspectedTimepoint AS date)
        AND (
            "LEN".untilTime IS NULL
        OR
            "LEN".untilTime > CAST(timepoints.inspectedTimepoint AS date)
        )
    ]';
END dPR_Program;
/
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pEV_Event(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex with the latest positing time picked for each posit and positor.
--
-- The latest and now perspectives are views over the point-in-time macro. A macro cannot be given a column of another
-- table to work for each positor, so the point-in-time macro works out the views of all positors itself, as does the
-- difference macro. The time traveling macro shows one positor, given by its first argument.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.tEV_Event (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "kETY_of".ETY_Checksum AS of_ETY_Checksum,
            "kETY_of".ETY_EventType AS of_ETY_EventType,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Who,
            "DAT".EV_DAT_Confidence,
            "DAT".EV_DAT_Stance,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Who,
            "AUD".EV_AUD_Confidence,
            "AUD".EV_AUD_Stance,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Who,
            "REV".EV_REV_Confidence,
            "REV".EV_REV_Stance,
            "REV".EV_REV_Event_Revenue,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ID,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_PositedAt,
            "STA".EV_STA_Who,
            "STA".EV_STA_Confidence,
            "STA".EV_STA_Stance,
            "STA".EV_STA_Event_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "UTL".EV_UTL_ID,
            "UTL".EV_UTL_PositedAt,
            "UTL".EV_UTL_Who,
            "UTL".EV_UTL_Confidence,
            "UTL".EV_UTL_Stance,
            "UTL".EV_UTL_UTL_Utilization,
            "UTL".EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ID,
            "LVL".EV_LVL_ChangedAt,
            "LVL".EV_LVL_PositedAt,
            "LVL".EV_LVL_Who,
            "LVL".EV_LVL_Confidence,
            "LVL".EV_LVL_Stance,
            "LVL".EV_LVL_PLV_Checksum,
            "LVL".EV_LVL_PLV_ProfessionalLevel,
            "LVL".EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            nexuses.EV_Event "EV"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN
            knots.ETY_EventType "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_DAT_Who, x.EV_DAT_EV_ID
                        ORDER BY
                            x.EV_DAT_PositedAt DESC,
                            x.EV_DAT_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_DAT,
                            po.EV_DAT_ID,
                            an.EV_DAT_PositedAt,
                            an.EV_DAT_Who,
                            an.EV_DAT_Confidence,
                            an.EV_DAT_Stance,
                            po.EV_DAT_EV_ID,
                            po.EV_DAT_Event_Date,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_DAT_ID, an.EV_DAT_Who
                                ORDER BY an.EV_DAT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_DAT_Event_Date_Fact po
                        JOIN
                            attributes.EV_DAT_Event_Date_Meta an
                        ON
                            an.EV_DAT_ID = po.EV_DAT_ID
                        WHERE
                            an.EV_DAT_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_DAT_Stance = COALESCE(assertion, x.EV_DAT_Stance)
            ) y
            WHERE
                y.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        AND
            "DAT".EV_DAT_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_AUD_Who, x.EV_AUD_EV_ID
                        ORDER BY
                            x.EV_AUD_PositedAt DESC,
                            x.EV_AUD_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_AUD,
                            po.EV_AUD_ID,
                            an.EV_AUD_PositedAt,
                            an.EV_AUD_Who,
                            an.EV_AUD_Confidence,
                            an.EV_AUD_Stance,
                            po.EV_AUD_EV_ID,
                            po.EV_AUD_Event_Audience,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_AUD_ID, an.EV_AUD_Who
                                ORDER BY an.EV_AUD_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_AUD_Event_Audience_Fact po
                        JOIN
                            attributes.EV_AUD_Event_Audience_Meta an
                        ON
                            an.EV_AUD_ID = po.EV_AUD_ID
                        WHERE
                            an.EV_AUD_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_AUD_Stance = COALESCE(assertion, x.EV_AUD_Stance)
            ) y
            WHERE
                y.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        AND
            "AUD".EV_AUD_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_REV_Who, x.EV_REV_EV_ID
                        ORDER BY
                            x.EV_REV_PositedAt DESC,
                            x.EV_REV_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_REV,
                            po.EV_REV_ID,
                            an.EV_REV_PositedAt,
                            an.EV_REV_Who,
                            an.EV_REV_Confidence,
                            an.EV_REV_Stance,
                            po.EV_REV_EV_ID,
                            po.EV_REV_Event_Revenue,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_REV_ID, an.EV_REV_Who
                                ORDER BY an.EV_REV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_REV_Event_Revenue_Fact po
                        JOIN
                            attributes.EV_REV_Event_Revenue_Meta an
                        ON
                            an.EV_REV_ID = po.EV_REV_ID
                        WHERE
                            an.EV_REV_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_REV_Stance = COALESCE(assertion, x.EV_REV_Stance)
            ) y
            WHERE
                y.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        AND
            "REV".EV_REV_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_STA_Who, x.EV_STA_EV_ID
                        ORDER BY
                            x.EV_STA_ChangedAt DESC,
                            x.EV_STA_PositedAt DESC,
                            x.EV_STA_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_STA_Stance <> '?' THEN r.EV_STA_ChangedAt END) OVER (
                            PARTITION BY r.EV_STA_Who, r.EV_STA_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_STA,
                            po.EV_STA_ID,
                            an.EV_STA_PositedAt,
                            an.EV_STA_Who,
                            an.EV_STA_Confidence,
                            an.EV_STA_Stance,
                            po.EV_STA_EV_ID,
                            po.EV_STA_Event_Status,
                            po.EV_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_STA_ID, an.EV_STA_Who
                                ORDER BY an.EV_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_STA_Event_Status_Fact po
                        JOIN
                            attributes.EV_STA_Event_Status_Meta an
                        ON
                            an.EV_STA_ID = po.EV_STA_ID
                        WHERE
                            po.EV_STA_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.EV_STA_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_STA_Stance = COALESCE(assertion, x.EV_STA_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.EV_STA_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS EV_UTL_Metadata_UTL,
                k.UTL_Utilization AS EV_UTL_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_UTL_Who, x.EV_UTL_EV_ID
                        ORDER BY
                            x.EV_UTL_PositedAt DESC,
                            x.EV_UTL_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_UTL,
                            po.EV_UTL_ID,
                            an.EV_UTL_PositedAt,
                            an.EV_UTL_Who,
                            an.EV_UTL_Confidence,
                            an.EV_UTL_Stance,
                            po.EV_UTL_EV_ID,
                            po.EV_UTL_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_UTL_ID, an.EV_UTL_Who
                                ORDER BY an.EV_UTL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_UTL_Event_Utilization_Fact po
                        JOIN
                            attributes.EV_UTL_Event_Utilization_Meta an
                        ON
                            an.EV_UTL_ID = po.EV_UTL_ID
                        WHERE
                            an.EV_UTL_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_UTL_Stance = COALESCE(assertion, x.EV_UTL_Stance)
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.EV_UTL_UTL_ID
            WHERE
                y.pickRank = 1
        ) "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        AND
            "UTL".EV_UTL_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS EV_LVL_PLV_Checksum,
                k.Metadata_PLV AS EV_LVL_Metadata_PLV,
                k.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_LVL_Who, x.EV_LVL_EV_ID
                        ORDER BY
                            x.EV_LVL_ChangedAt DESC,
                            x.EV_LVL_PositedAt DESC,
                            x.EV_LVL_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_LVL_Stance <> '?' THEN r.EV_LVL_ChangedAt END) OVER (
                            PARTITION BY r.EV_LVL_Who, r.EV_LVL_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_LVL,
                            po.EV_LVL_ID,
                            an.EV_LVL_PositedAt,
                            an.EV_LVL_Who,
                            an.EV_LVL_Confidence,
                            an.EV_LVL_Stance,
                            po.EV_LVL_EV_ID,
                            po.EV_LVL_PLV_ID,
                            po.EV_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_LVL_ID, an.EV_LVL_Who
                                ORDER BY an.EV_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_LVL_Event_Level_Fact po
                        JOIN
                            attributes.EV_LVL_Event_Level_Meta an
                        ON
                            an.EV_LVL_ID = po.EV_LVL_ID
                        WHERE
                            po.EV_LVL_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.EV_LVL_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_LVL_Stance = COALESCE(assertion, x.EV_LVL_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.EV_LVL_ChangedAt = x.inEffect
                )
            ) y
            LEFT JOIN
                knots.PLV_ProfessionalLevel k
            ON
                k.PLV_ID = y.EV_LVL_PLV_ID
            WHERE
                y.pickRank = 1
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_Who = positorTable.Who
        WHERE
            positorTable.Who = forPositor
    ]';
END tEV_Event;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.pEV_Event (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "kETY_of".ETY_Checksum AS of_ETY_Checksum,
            "kETY_of".ETY_EventType AS of_ETY_EventType,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Who,
            "DAT".EV_DAT_Confidence,
            "DAT".EV_DAT_Stance,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Who,
            "AUD".EV_AUD_Confidence,
            "AUD".EV_AUD_Stance,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Who,
            "REV".EV_REV_Confidence,
            "REV".EV_REV_Stance,
            "REV".EV_REV_Event_Revenue,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ID,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_PositedAt,
            "STA".EV_STA_Who,
            "STA".EV_STA_Confidence,
            "STA".EV_STA_Stance,
            "STA".EV_STA_Event_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "UTL".EV_UTL_ID,
            "UTL".EV_UTL_PositedAt,
            "UTL".EV_UTL_Who,
            "UTL".EV_UTL_Confidence,
            "UTL".EV_UTL_Stance,
            "UTL".EV_UTL_UTL_Utilization,
            "UTL".EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ID,
            "LVL".EV_LVL_ChangedAt,
            "LVL".EV_LVL_PositedAt,
            "LVL".EV_LVL_Who,
            "LVL".EV_LVL_Confidence,
            "LVL".EV_LVL_Stance,
            "LVL".EV_LVL_PLV_Checksum,
            "LVL".EV_LVL_PLV_ProfessionalLevel,
            "LVL".EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            nexuses.EV_Event "EV"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN
            knots.ETY_EventType "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_DAT_Who, x.EV_DAT_EV_ID
                        ORDER BY
                            x.EV_DAT_PositedAt DESC,
                            x.EV_DAT_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_DAT,
                            po.EV_DAT_ID,
                            an.EV_DAT_PositedAt,
                            an.EV_DAT_Who,
                            an.EV_DAT_Confidence,
                            an.EV_DAT_Stance,
                            po.EV_DAT_EV_ID,
                            po.EV_DAT_Event_Date,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_DAT_ID, an.EV_DAT_Who
                                ORDER BY an.EV_DAT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_DAT_Event_Date_Fact po
                        JOIN
                            attributes.EV_DAT_Event_Date_Meta an
                        ON
                            an.EV_DAT_ID = po.EV_DAT_ID
                        WHERE
                            an.EV_DAT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_DAT_Stance = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        AND
            "DAT".EV_DAT_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_AUD_Who, x.EV_AUD_EV_ID
                        ORDER BY
                            x.EV_AUD_PositedAt DESC,
                            x.EV_AUD_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_AUD,
                            po.EV_AUD_ID,
                            an.EV_AUD_PositedAt,
                            an.EV_AUD_Who,
                            an.EV_AUD_Confidence,
                            an.EV_AUD_Stance,
                            po.EV_AUD_EV_ID,
                            po.EV_AUD_Event_Audience,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_AUD_ID, an.EV_AUD_Who
                                ORDER BY an.EV_AUD_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_AUD_Event_Audience_Fact po
                        JOIN
                            attributes.EV_AUD_Event_Audience_Meta an
                        ON
                            an.EV_AUD_ID = po.EV_AUD_ID
                        WHERE
                            an.EV_AUD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_AUD_Stance = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        AND
            "AUD".EV_AUD_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_REV_Who, x.EV_REV_EV_ID
                        ORDER BY
                            x.EV_REV_PositedAt DESC,
                            x.EV_REV_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_REV,
                            po.EV_REV_ID,
                            an.EV_REV_PositedAt,
                            an.EV_REV_Who,
                            an.EV_REV_Confidence,
                            an.EV_REV_Stance,
                            po.EV_REV_EV_ID,
                            po.EV_REV_Event_Revenue,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_REV_ID, an.EV_REV_Who
                                ORDER BY an.EV_REV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_REV_Event_Revenue_Fact po
                        JOIN
                            attributes.EV_REV_Event_Revenue_Meta an
                        ON
                            an.EV_REV_ID = po.EV_REV_ID
                        WHERE
                            an.EV_REV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_REV_Stance = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        AND
            "REV".EV_REV_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_STA_Who, x.EV_STA_EV_ID
                        ORDER BY
                            x.EV_STA_ChangedAt DESC,
                            x.EV_STA_PositedAt DESC,
                            x.EV_STA_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_STA_Stance <> '?' THEN r.EV_STA_ChangedAt END) OVER (
                            PARTITION BY r.EV_STA_Who, r.EV_STA_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_STA,
                            po.EV_STA_ID,
                            an.EV_STA_PositedAt,
                            an.EV_STA_Who,
                            an.EV_STA_Confidence,
                            an.EV_STA_Stance,
                            po.EV_STA_EV_ID,
                            po.EV_STA_Event_Status,
                            po.EV_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_STA_ID, an.EV_STA_Who
                                ORDER BY an.EV_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_STA_Event_Status_Fact po
                        JOIN
                            attributes.EV_STA_Event_Status_Meta an
                        ON
                            an.EV_STA_ID = po.EV_STA_ID
                        WHERE
                            po.EV_STA_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.EV_STA_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_STA_Stance = '+'
                AND
                    x.EV_STA_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS EV_UTL_Metadata_UTL,
                k.UTL_Utilization AS EV_UTL_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_UTL_Who, x.EV_UTL_EV_ID
                        ORDER BY
                            x.EV_UTL_PositedAt DESC,
                            x.EV_UTL_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_UTL,
                            po.EV_UTL_ID,
                            an.EV_UTL_PositedAt,
                            an.EV_UTL_Who,
                            an.EV_UTL_Confidence,
                            an.EV_UTL_Stance,
                            po.EV_UTL_EV_ID,
                            po.EV_UTL_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_UTL_ID, an.EV_UTL_Who
                                ORDER BY an.EV_UTL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_UTL_Event_Utilization_Fact po
                        JOIN
                            attributes.EV_UTL_Event_Utilization_Meta an
                        ON
                            an.EV_UTL_ID = po.EV_UTL_ID
                        WHERE
                            an.EV_UTL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_UTL_Stance = '+'
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.EV_UTL_UTL_ID
            WHERE
                y.pickRank = 1
        ) "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        AND
            "UTL".EV_UTL_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS EV_LVL_PLV_Checksum,
                k.Metadata_PLV AS EV_LVL_Metadata_PLV,
                k.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_LVL_Who, x.EV_LVL_EV_ID
                        ORDER BY
                            x.EV_LVL_ChangedAt DESC,
                            x.EV_LVL_PositedAt DESC,
                            x.EV_LVL_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_LVL_Stance <> '?' THEN r.EV_LVL_ChangedAt END) OVER (
                            PARTITION BY r.EV_LVL_Who, r.EV_LVL_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_LVL,
                            po.EV_LVL_ID,
                            an.EV_LVL_PositedAt,
                            an.EV_LVL_Who,
                            an.EV_LVL_Confidence,
                            an.EV_LVL_Stance,
                            po.EV_LVL_EV_ID,
                            po.EV_LVL_PLV_ID,
                            po.EV_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_LVL_ID, an.EV_LVL_Who
                                ORDER BY an.EV_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_LVL_Event_Level_Fact po
                        JOIN
                            attributes.EV_LVL_Event_Level_Meta an
                        ON
                            an.EV_LVL_ID = po.EV_LVL_ID
                        WHERE
                            po.EV_LVL_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.EV_LVL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_LVL_Stance = '+'
                AND
                    x.EV_LVL_ChangedAt = x.inEffect
            ) y
            LEFT JOIN
                knots.PLV_ProfessionalLevel k
            ON
                k.PLV_ID = y.EV_LVL_PLV_ID
            WHERE
                y.pickRank = 1
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_Who = positorTable.Who
    ]';
END pEV_Event;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.lEV_Event
AS
SELECT
    *
FROM
    nexuses.pEV_Event(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.nEV_Event
AS
SELECT
    *
FROM
    nexuses.pEV_Event(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.dEV_Event (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            timepoints.inspectedTimepoint,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "kETY_of".ETY_Checksum AS of_ETY_Checksum,
            "kETY_of".ETY_EventType AS of_ETY_EventType,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Who,
            "DAT".EV_DAT_Confidence,
            "DAT".EV_DAT_Stance,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Who,
            "AUD".EV_AUD_Confidence,
            "AUD".EV_AUD_Stance,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Who,
            "REV".EV_REV_Confidence,
            "REV".EV_REV_Stance,
            "REV".EV_REV_Event_Revenue,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ID,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_PositedAt,
            "STA".EV_STA_Who,
            "STA".EV_STA_Confidence,
            "STA".EV_STA_Stance,
            "STA".EV_STA_Event_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "UTL".EV_UTL_ID,
            "UTL".EV_UTL_PositedAt,
            "UTL".EV_UTL_Who,
            "UTL".EV_UTL_Confidence,
            "UTL".EV_UTL_Stance,
            "kUTL".UTL_Utilization AS EV_UTL_UTL_Utilization,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ID,
            "LVL".EV_LVL_ChangedAt,
            "LVL".EV_LVL_PositedAt,
            "LVL".EV_LVL_Who,
            "LVL".EV_LVL_Confidence,
            "LVL".EV_LVL_Stance,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.EV_STA_Who AS inspectedPositor,
                h.EV_STA_EV_ID AS EV_ID,
                CAST(h.EV_STA_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'STA' AS mnemonic
            FROM
                attributes.EV_STA_Event_Status h
            WHERE
                (selection IS NULL OR selection LIKE '%STA%')
            AND
                h.EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.EV_LVL_Who AS inspectedPositor,
                h.EV_LVL_EV_ID AS EV_ID,
                CAST(h.EV_LVL_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'LVL' AS mnemonic
            FROM
                attributes.EV_LVL_Event_Level h
            WHERE
                (selection IS NULL OR selection LIKE '%LVL%')
            AND
                h.EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        ON
            timepoints.inspectedPositor = positorTable.Who
        JOIN
            nexuses.EV_Event "EV"
        ON
            "EV".EV_ID = timepoints.EV_ID
        LEFT JOIN
            knots.ETY_EventType "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_DAT_Who, r.EV_DAT_EV_ID
                        ORDER BY
                            r.EV_DAT_PositedAt DESC,
                            r.EV_DAT_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_DAT,
                        po.EV_DAT_ID,
                        an.EV_DAT_PositedAt,
                        an.EV_DAT_Who,
                        an.EV_DAT_Confidence,
                        an.EV_DAT_Stance,
                        po.EV_DAT_EV_ID,
                        po.EV_DAT_Event_Date,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_DAT_ID, an.EV_DAT_Who
                            ORDER BY an.EV_DAT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_DAT_Event_Date_Fact po
                    JOIN
                        attributes.EV_DAT_Event_Date_Meta an
                    ON
                        an.EV_DAT_ID = po.EV_DAT_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_DAT_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        AND
            "DAT".EV_DAT_Who = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_AUD_Who, r.EV_AUD_EV_ID
                        ORDER BY
                            r.EV_AUD_PositedAt DESC,
                            r.EV_AUD_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_AUD,
                        po.EV_AUD_ID,
                        an.EV_AUD_PositedAt,
                        an.EV_AUD_Who,
                        an.EV_AUD_Confidence,
                        an.EV_AUD_Stance,
                        po.EV_AUD_EV_ID,
                        po.EV_AUD_Event_Audience,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_AUD_ID, an.EV_AUD_Who
                            ORDER BY an.EV_AUD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_AUD_Event_Audience_Fact po
                    JOIN
                        attributes.EV_AUD_Event_Audience_Meta an
                    ON
                        an.EV_AUD_ID = po.EV_AUD_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_AUD_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        AND
            "AUD".EV_AUD_Who = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_REV_Who, r.EV_REV_EV_ID
                        ORDER BY
                            r.EV_REV_PositedAt DESC,
                            r.EV_REV_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_REV,
                        po.EV_REV_ID,
                        an.EV_REV_PositedAt,
                        an.EV_REV_Who,
                        an.EV_REV_Confidence,
                        an.EV_REV_Stance,
                        po.EV_REV_EV_ID,
                        po.EV_REV_Event_Revenue,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_REV_ID, an.EV_REV_Who
                            ORDER BY an.EV_REV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_REV_Event_Revenue_Fact po
                    JOIN
                        attributes.EV_REV_Event_Revenue_Meta an
                    ON
                        an.EV_REV_ID = po.EV_REV_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_REV_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        AND
            "REV".EV_REV_Who = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.EV_STA_ChangedAt) OVER (
                    PARTITION BY y.EV_STA_Who, y.EV_STA_EV_ID
                    ORDER BY y.EV_STA_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.EV_STA_Who, r.EV_STA_EV_ID, r.EV_STA_ChangedAt
                            ORDER BY
                                CASE WHEN r.EV_STA_Stance = '+' THEN 0 ELSE 1 END,
                                r.EV_STA_PositedAt DESC,
                                r.EV_STA_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_EV_STA,
                            po.EV_STA_ID,
                            an.EV_STA_PositedAt,
                            an.EV_STA_Who,
                            an.EV_STA_Confidence,
                            an.EV_STA_Stance,
                            po.EV_STA_EV_ID,
                            po.EV_STA_Event_Status,
                            po.EV_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_STA_ID, an.EV_STA_Who
                                ORDER BY an.EV_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_STA_Event_Status_Fact po
                        JOIN
                            attributes.EV_STA_Event_Status_Meta an
                        ON
                            an.EV_STA_ID = po.EV_STA_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.EV_STA_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_Who = timepoints.inspectedPositor
        AND
            "STA".EV_STA_Stance = '+'
        AND
            "STA".EV_STA_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "STA".untilTime IS NULL
        OR
            "STA".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_UTL_Who, r.EV_UTL_EV_ID
                        ORDER BY
                            r.EV_UTL_PositedAt DESC,
                            r.EV_UTL_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_UTL,
                        po.EV_UTL_ID,
                        an.EV_UTL_PositedAt,
                        an.EV_UTL_Who,
                        an.EV_UTL_Confidence,
                        an.EV_UTL_Stance,
                        po.EV_UTL_EV_ID,
                        po.EV_UTL_UTL_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_UTL_ID, an.EV_UTL_Who
                            ORDER BY an.EV_UTL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_UTL_Event_Utilization_Fact po
                    JOIN
                        attributes.EV_UTL_Event_Utilization_Meta an
                    ON
                        an.EV_UTL_ID = po.EV_UTL_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_UTL_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        AND
            "UTL".EV_UTL_Who = timepoints.inspectedPositor
        LEFT JOIN
            knots.UTL_Utilization "kUTL"
        ON
            "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.EV_LVL_ChangedAt) OVER (
                    PARTITION BY y.EV_LVL_Who, y.EV_LVL_EV_ID
                    ORDER BY y.EV_LVL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.EV_LVL_Who, r.EV_LVL_EV_ID, r.EV_LVL_ChangedAt
                            ORDER BY
                                CASE WHEN r.EV_LVL_Stance = '+' THEN 0 ELSE 1 END,
                                r.EV_LVL_PositedAt DESC,
                                r.EV_LVL_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_EV_LVL,
                            po.EV_LVL_ID,
                            an.EV_LVL_PositedAt,
                            an.EV_LVL_Who,
                            an.EV_LVL_Confidence,
                            an.EV_LVL_Stance,
                            po.EV_LVL_EV_ID,
                            po.EV_LVL_PLV_ID,
                            po.EV_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_LVL_ID, an.EV_LVL_Who
                                ORDER BY an.EV_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_LVL_Event_Level_Fact po
                        JOIN
                            attributes.EV_LVL_Event_Level_Meta an
                        ON
                            an.EV_LVL_ID = po.EV_LVL_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.EV_LVL_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_Who = timepoints.inspectedPositor
        AND
            "LVL".EV_LVL_Stance = '+'
        AND
            "LVL".EV_LVL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS date)
        AND (
            "LVL".untilTime IS NULL
        OR
            "LVL".untilTime > CAST(timepoints.inspectedTimepoint AS date)
        )
        LEFT JOIN
            knots.PLV_ProfessionalLevel "kLVL"
        ON
            "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
    ]';
END dEV_Event;
/
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.AC_partner_AC_with_ONG_currently_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_partner_AC_with_ONG_currently_Fact (
            AC_partner_AC_with_ONG_currently_ID number(19) default ties.AC_partner_AC_with_ONG_currently_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_partner_AC_with_ONG_currently_Meta (
            AC_partner_AC_with_ONG_currently_ID number(19) not null,
            AC_partner_AC_with_ONG_currently_PositedAt timestamp(3) not null,
            AC_partner_AC_with_ONG_currently_Who number(5) not null,
            AC_partner_AC_with_ONG_currently_Confidence number(7,3) not null,
            AC_partner_AC_with_ONG_currently_Stance char(1) generated always as (
                case
                    when AC_partner_AC_with_ONG_currently_Confidence > 0.25 then '+'
                    when AC_partner_AC_with_ONG_currently_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_partner_AC_with_ONG_currently number(19) not null,
            constraint fkAC_partner_AC_with_ONG_currently_Meta foreign key (
                AC_partner_AC_with_ONG_currently_ID
            ) references ties.AC_partner_AC_with_ONG_currently_Fact(AC_partner_AC_with_ONG_currently_ID),
            constraint pkAC_partner_AC_with_ONG_currently_Meta primary key (
                AC_partner_AC_with_ONG_currently_ID,
                AC_partner_AC_with_ONG_currently_Who,
                AC_partner_AC_with_ONG_currently_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.AC_subset_PN_of_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_subset_PN_of_Fact (
            AC_subset_PN_of_ID number(19) default ties.AC_subset_PN_of_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_subset_PN_of_Meta (
            AC_subset_PN_of_ID number(19) not null,
            AC_subset_PN_of_PositedAt timestamp(3) not null,
            AC_subset_PN_of_Who number(5) not null,
            AC_subset_PN_of_Confidence number(7,3) not null,
            AC_subset_PN_of_Stance char(1) generated always as (
                case
                    when AC_subset_PN_of_Confidence > 0.25 then '+'
                    when AC_subset_PN_of_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_subset_PN_of number(19) not null,
            constraint fkAC_subset_PN_of_Meta foreign key (
                AC_subset_PN_of_ID
            ) references ties.AC_subset_PN_of_Fact(AC_subset_PN_of_ID),
            constraint pkAC_subset_PN_of_Meta primary key (
                AC_subset_PN_of_ID,
                AC_subset_PN_of_Who,
                AC_subset_PN_of_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.EV_in_AC_wasCast_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.EV_in_AC_wasCast_Fact (
            EV_in_AC_wasCast_ID number(19) default ties.EV_in_AC_wasCast_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.EV_in_AC_wasCast_Meta (
            EV_in_AC_wasCast_ID number(19) not null,
            EV_in_AC_wasCast_PositedAt timestamp(3) not null,
            EV_in_AC_wasCast_Who number(5) not null,
            EV_in_AC_wasCast_Confidence number(7,3) not null,
            EV_in_AC_wasCast_Stance char(1) generated always as (
                case
                    when EV_in_AC_wasCast_Confidence > 0.25 then '+'
                    when EV_in_AC_wasCast_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_in_AC_wasCast number(19) not null,
            constraint fkEV_in_AC_wasCast_Meta foreign key (
                EV_in_AC_wasCast_ID
            ) references ties.EV_in_AC_wasCast_Fact(EV_in_AC_wasCast_ID),
            constraint pkEV_in_AC_wasCast_Meta primary key (
                EV_in_AC_wasCast_ID,
                EV_in_AC_wasCast_Who,
                EV_in_AC_wasCast_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.AC_part_PR_in_RAT_got_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_part_PR_in_RAT_got_Fact (
            AC_part_PR_in_RAT_got_ID number(19) default ties.AC_part_PR_in_RAT_got_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_part_PR_in_RAT_got_Meta (
            AC_part_PR_in_RAT_got_ID number(19) not null,
            AC_part_PR_in_RAT_got_PositedAt timestamp(3) not null,
            AC_part_PR_in_RAT_got_Who number(5) not null,
            AC_part_PR_in_RAT_got_Confidence number(7,3) not null,
            AC_part_PR_in_RAT_got_Stance char(1) generated always as (
                case
                    when AC_part_PR_in_RAT_got_Confidence > 0.25 then '+'
                    when AC_part_PR_in_RAT_got_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_part_PR_in_RAT_got number(19) not null,
            constraint fkAC_part_PR_in_RAT_got_Meta foreign key (
                AC_part_PR_in_RAT_got_ID
            ) references ties.AC_part_PR_in_RAT_got_Fact(AC_part_PR_in_RAT_got_ID),
            constraint pkAC_part_PR_in_RAT_got_Meta primary key (
                AC_part_PR_in_RAT_got_ID,
                AC_part_PR_in_RAT_got_Who,
                AC_part_PR_in_RAT_got_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.ST_at_PR_isPlaying_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.ST_at_PR_isPlaying_Fact (
            ST_at_PR_isPlaying_ID number(19) default ties.ST_at_PR_isPlaying_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.ST_at_PR_isPlaying_Meta (
            ST_at_PR_isPlaying_ID number(19) not null,
            ST_at_PR_isPlaying_PositedAt timestamp(3) not null,
            ST_at_PR_isPlaying_Who number(5) not null,
            ST_at_PR_isPlaying_Confidence number(7,3) not null,
            ST_at_PR_isPlaying_Stance char(1) generated always as (
                case
                    when ST_at_PR_isPlaying_Confidence > 0.25 then '+'
                    when ST_at_PR_isPlaying_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_at_PR_isPlaying number(19) not null,
            constraint fkST_at_PR_isPlaying_Meta foreign key (
                ST_at_PR_isPlaying_ID
            ) references ties.ST_at_PR_isPlaying_Fact(ST_at_PR_isPlaying_ID),
            constraint pkST_at_PR_isPlaying_Meta primary key (
                ST_at_PR_isPlaying_ID,
                ST_at_PR_isPlaying_Who,
                ST_at_PR_isPlaying_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.AC_parent_AC_child_PAT_having_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_parent_AC_child_PAT_having_Fact (
            AC_parent_AC_child_PAT_having_ID number(19) default ties.AC_parent_AC_child_PAT_having_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_parent_AC_child_PAT_having_Meta (
            AC_parent_AC_child_PAT_having_ID number(19) not null,
            AC_parent_AC_child_PAT_having_PositedAt timestamp(3) not null,
            AC_parent_AC_child_PAT_having_Who number(5) not null,
            AC_parent_AC_child_PAT_having_Confidence number(7,3) not null,
            AC_parent_AC_child_PAT_having_Stance char(1) generated always as (
                case
                    when AC_parent_AC_child_PAT_having_Confidence > 0.25 then '+'
                    when AC_parent_AC_child_PAT_having_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_parent_AC_child_PAT_having number(19) not null,
            constraint fkAC_parent_AC_child_PAT_having_Meta foreign key (
                AC_parent_AC_child_PAT_having_ID
            ) references ties.AC_parent_AC_child_PAT_having_Fact(AC_parent_AC_child_PAT_having_ID),
            constraint pkAC_parent_AC_child_PAT_having_Meta primary key (
                AC_parent_AC_child_PAT_having_ID,
                AC_parent_AC_child_PAT_having_Who,
                AC_parent_AC_child_PAT_having_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.PR_content_ST_location_EV_of_Fact_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.PR_content_ST_location_EV_of_Fact (
            PR_content_ST_location_EV_of_ID number(19) default ties.PR_content_ST_location_EV_of_Fact_ID_SEQ.nextval not null, 
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.PR_content_ST_location_EV_of_Meta (
            PR_content_ST_location_EV_of_ID number(19) not null,
            PR_content_ST_location_EV_of_PositedAt timestamp(3) not null,
            PR_content_ST_location_EV_of_Who number(5) not null,
            PR_content_ST_location_EV_of_Confidence number(7,3) not null,
            PR_content_ST_location_EV_of_Stance char(1) generated always as (
                case
                    when PR_content_ST_location_EV_of_Confidence > 0.25 then '+'
                    when PR_content_ST_location_EV_of_Confidence = 0.25 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_PR_content_ST_location_EV_of number(19) not null,
            constraint fkPR_content_ST_location_EV_of_Meta foreign key (
                PR_content_ST_location_EV_of_ID
            ) references ties.PR_content_ST_location_EV_of_Fact(PR_content_ST_location_EV_of_ID),
            constraint pkPR_content_ST_location_EV_of_Meta primary key (
                PR_content_ST_location_EV_of_ID,
                PR_content_ST_location_EV_of_Who,
                PR_content_ST_location_EV_of_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW ties.AC_partner_AC_with_ONG_currently AS
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
    a.AC_partner_AC_with_ONG_currently_Stance
FROM
    ties.AC_partner_AC_with_ONG_currently_Fact p
JOIN
    ties.AC_partner_AC_with_ONG_currently_Meta a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
;
CREATE OR REPLACE VIEW ties.AC_subset_PN_of AS
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Who,
    a.AC_subset_PN_of_Confidence,
    a.AC_subset_PN_of_Stance
FROM
    ties.AC_subset_PN_of_Fact p
JOIN
    ties.AC_subset_PN_of_Meta a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
;
CREATE OR REPLACE VIEW ties.EV_in_AC_wasCast AS
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Who,
    a.EV_in_AC_wasCast_Confidence,
    a.EV_in_AC_wasCast_Stance
FROM
    ties.EV_in_AC_wasCast_Fact p
JOIN
    ties.EV_in_AC_wasCast_Meta a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
;
CREATE OR REPLACE VIEW ties.AC_part_PR_in_RAT_got AS
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
    a.AC_part_PR_in_RAT_got_Stance
FROM
    ties.AC_part_PR_in_RAT_got_Fact p
JOIN
    ties.AC_part_PR_in_RAT_got_Meta a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
;
CREATE OR REPLACE VIEW ties.ST_at_PR_isPlaying AS
SELECT
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Who,
    a.ST_at_PR_isPlaying_Confidence,
    a.ST_at_PR_isPlaying_Stance
FROM
    ties.ST_at_PR_isPlaying_Fact p
JOIN
    ties.ST_at_PR_isPlaying_Meta a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
;
CREATE OR REPLACE VIEW ties.AC_parent_AC_child_PAT_having AS
SELECT
    a.Metadata_AC_parent_AC_child_PAT_having,
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Who,
    a.AC_parent_AC_child_PAT_having_Confidence,
    a.AC_parent_AC_child_PAT_having_Stance
FROM
    ties.AC_parent_AC_child_PAT_having_Fact p
JOIN
    ties.AC_parent_AC_child_PAT_having_Meta a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
;
CREATE OR REPLACE VIEW ties.PR_content_ST_location_EV_of AS
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
    a.PR_content_ST_location_EV_of_Stance
FROM
    ties.PR_content_ST_location_EV_of_Fact p
JOIN
    ties.PR_content_ST_location_EV_of_Meta a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection: the view of the positor given,
-- or of all of them for null. They are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): functions that return
-- the text of a query, in which the parameters stand for the values given, called in the FROM clause like a table.
-- The macros do not call each other, they do what the others do in their own query.
--
-- @positor the view of which positor to adopt, or null for the views of all of them
-- @changingTimepoint the point in changing time to rewind to
-- @positingTimepoint the point in positing time to rewind to
--
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt
        FROM
            ties.AC_partner_AC_with_ONG_currently_Fact
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Fact;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt
        FROM
            ties.AC_partner_AC_with_ONG_currently_Fact
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
    ]';
END fAC_partner_AC_with_ONG_currently_Fact;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Who,
            AC_partner_AC_with_ONG_currently_Confidence,
            AC_partner_AC_with_ONG_currently_Stance
        FROM
            ties.AC_partner_AC_with_ONG_currently_Meta
        WHERE
            AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Who,
            AC_partner_AC_with_ONG_currently_Confidence,
            AC_partner_AC_with_ONG_currently_Stance
        FROM (
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
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID,
                        a.AC_partner_AC_with_ONG_currently_Who
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_partner_AC_with_ONG_currently_Fact p
            JOIN
                ties.AC_partner_AC_with_ONG_currently_Meta a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            AND
                a.AC_partner_AC_with_ONG_currently_Who = COALESCE(positor, a.AC_partner_AC_with_ONG_currently_Who)
            WHERE
                p.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
            AND
                a.AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_partner_AC_with_ONG_currently;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Who,
            AC_partner_AC_with_ONG_currently_Confidence,
            AC_partner_AC_with_ONG_currently_Stance
        FROM (
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
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID,
                        a.AC_partner_AC_with_ONG_currently_Who
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_partner_AC_with_ONG_currently_Fact p
            JOIN
                ties.AC_partner_AC_with_ONG_currently_Meta a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            AND
                a.AC_partner_AC_with_ONG_currently_Who = COALESCE(positor, a.AC_partner_AC_with_ONG_currently_Who)
            WHERE
                p.AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
            AND
                a.AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_partner_AC_with_ONG_currently;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Who,
            AC_subset_PN_of_Confidence,
            AC_subset_PN_of_Stance
        FROM
            ties.AC_subset_PN_of_Meta
        WHERE
            AC_subset_PN_of_PositedAt <= positingTimepoint
    ]';
END rAC_subset_PN_of_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_ID_subset,
            PN_ID_of,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Who,
            AC_subset_PN_of_Confidence,
            AC_subset_PN_of_Stance
        FROM (
            SELECT
                a.Metadata_AC_subset_PN_of,
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Who,
                a.AC_subset_PN_of_Confidence,
                a.AC_subset_PN_of_Stance,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID,
                        a.AC_subset_PN_of_Who
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_subset_PN_of_Fact p
            JOIN
                ties.AC_subset_PN_of_Meta a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            AND
                a.AC_subset_PN_of_Who = COALESCE(positor, a.AC_subset_PN_of_Who)
            WHERE
                a.AC_subset_PN_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_subset_PN_of;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_subset_PN_of (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_ID_subset,
            PN_ID_of,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Who,
            AC_subset_PN_of_Confidence,
            AC_subset_PN_of_Stance
        FROM (
            SELECT
                a.Metadata_AC_subset_PN_of,
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Who,
                a.AC_subset_PN_of_Confidence,
                a.AC_subset_PN_of_Stance,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID,
                        a.AC_subset_PN_of_Who
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_subset_PN_of_Fact p
            JOIN
                ties.AC_subset_PN_of_Meta a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            AND
                a.AC_subset_PN_of_Who = COALESCE(positor, a.AC_subset_PN_of_Who)
            WHERE
                a.AC_subset_PN_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_subset_PN_of;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Who,
            EV_in_AC_wasCast_Confidence,
            EV_in_AC_wasCast_Stance
        FROM
            ties.EV_in_AC_wasCast_Meta
        WHERE
            EV_in_AC_wasCast_PositedAt <= positingTimepoint
    ]';
END rEV_in_AC_wasCast_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_ID_in,
            AC_ID_wasCast,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Who,
            EV_in_AC_wasCast_Confidence,
            EV_in_AC_wasCast_Stance
        FROM (
            SELECT
                a.Metadata_EV_in_AC_wasCast,
                p.EV_in_AC_wasCast_ID,
                p.EV_ID_in,
                p.AC_ID_wasCast,
                a.EV_in_AC_wasCast_PositedAt,
                a.EV_in_AC_wasCast_Who,
                a.EV_in_AC_wasCast_Confidence,
                a.EV_in_AC_wasCast_Stance,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_wasCast_ID,
                        a.EV_in_AC_wasCast_Who
                    ORDER BY
                        a.EV_in_AC_wasCast_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.EV_in_AC_wasCast_Fact p
            JOIN
                ties.EV_in_AC_wasCast_Meta a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            AND
                a.EV_in_AC_wasCast_Who = COALESCE(positor, a.EV_in_AC_wasCast_Who)
            WHERE
                a.EV_in_AC_wasCast_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_in_AC_wasCast;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fEV_in_AC_wasCast (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_ID_in,
            AC_ID_wasCast,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Who,
            EV_in_AC_wasCast_Confidence,
            EV_in_AC_wasCast_Stance
        FROM (
            SELECT
                a.Metadata_EV_in_AC_wasCast,
                p.EV_in_AC_wasCast_ID,
                p.EV_ID_in,
                p.AC_ID_wasCast,
                a.EV_in_AC_wasCast_PositedAt,
                a.EV_in_AC_wasCast_Who,
                a.EV_in_AC_wasCast_Confidence,
                a.EV_in_AC_wasCast_Stance,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_wasCast_ID,
                        a.EV_in_AC_wasCast_Who
                    ORDER BY
                        a.EV_in_AC_wasCast_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.EV_in_AC_wasCast_Fact p
            JOIN
                ties.EV_in_AC_wasCast_Meta a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            AND
                a.EV_in_AC_wasCast_Who = COALESCE(positor, a.EV_in_AC_wasCast_Who)
            WHERE
                a.EV_in_AC_wasCast_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_in_AC_wasCast;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_part_PR_in_RAT_got_ID,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got,
            AC_part_PR_in_RAT_got_ChangedAt
        FROM
            ties.AC_part_PR_in_RAT_got_Fact
        WHERE
            AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
    ]';
END rAC_part_PR_in_RAT_got_Fact;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_part_PR_in_RAT_got_ID,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got,
            AC_part_PR_in_RAT_got_ChangedAt
        FROM
            ties.AC_part_PR_in_RAT_got_Fact
        WHERE
            AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
    ]';
END fAC_part_PR_in_RAT_got_Fact;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Who,
            AC_part_PR_in_RAT_got_Confidence,
            AC_part_PR_in_RAT_got_Stance
        FROM
            ties.AC_part_PR_in_RAT_got_Meta
        WHERE
            AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
    ]';
END rAC_part_PR_in_RAT_got_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got,
            AC_part_PR_in_RAT_got_ChangedAt,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Who,
            AC_part_PR_in_RAT_got_Confidence,
            AC_part_PR_in_RAT_got_Stance
        FROM (
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
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_part_PR_in_RAT_got_ID,
                        a.AC_part_PR_in_RAT_got_Who
                    ORDER BY
                        a.AC_part_PR_in_RAT_got_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_part_PR_in_RAT_got_Fact p
            JOIN
                ties.AC_part_PR_in_RAT_got_Meta a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            AND
                a.AC_part_PR_in_RAT_got_Who = COALESCE(positor, a.AC_part_PR_in_RAT_got_Who)
            WHERE
                p.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
            AND
                a.AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_part_PR_in_RAT_got;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got,
            AC_part_PR_in_RAT_got_ChangedAt,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Who,
            AC_part_PR_in_RAT_got_Confidence,
            AC_part_PR_in_RAT_got_Stance
        FROM (
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
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_part_PR_in_RAT_got_ID,
                        a.AC_part_PR_in_RAT_got_Who
                    ORDER BY
                        a.AC_part_PR_in_RAT_got_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_part_PR_in_RAT_got_Fact p
            JOIN
                ties.AC_part_PR_in_RAT_got_Meta a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            AND
                a.AC_part_PR_in_RAT_got_Who = COALESCE(positor, a.AC_part_PR_in_RAT_got_Who)
            WHERE
                p.AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
            AND
                a.AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_part_PR_in_RAT_got;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_isPlaying_ID,
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt
        FROM
            ties.ST_at_PR_isPlaying_Fact
        WHERE
            ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
    ]';
END rST_at_PR_isPlaying_Fact;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_isPlaying_ID,
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt
        FROM
            ties.ST_at_PR_isPlaying_Fact
        WHERE
            ST_at_PR_isPlaying_ChangedAt > changingTimepoint
    ]';
END fST_at_PR_isPlaying_Fact;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Who,
            ST_at_PR_isPlaying_Confidence,
            ST_at_PR_isPlaying_Stance
        FROM
            ties.ST_at_PR_isPlaying_Meta
        WHERE
            ST_at_PR_isPlaying_PositedAt <= positingTimepoint
    ]';
END rST_at_PR_isPlaying_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Who,
            ST_at_PR_isPlaying_Confidence,
            ST_at_PR_isPlaying_Stance
        FROM (
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
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_isPlaying_ID,
                        a.ST_at_PR_isPlaying_Who
                    ORDER BY
                        a.ST_at_PR_isPlaying_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.ST_at_PR_isPlaying_Fact p
            JOIN
                ties.ST_at_PR_isPlaying_Meta a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            AND
                a.ST_at_PR_isPlaying_Who = COALESCE(positor, a.ST_at_PR_isPlaying_Who)
            WHERE
                p.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
            AND
                a.ST_at_PR_isPlaying_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_at_PR_isPlaying;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Who,
            ST_at_PR_isPlaying_Confidence,
            ST_at_PR_isPlaying_Stance
        FROM (
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
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_isPlaying_ID,
                        a.ST_at_PR_isPlaying_Who
                    ORDER BY
                        a.ST_at_PR_isPlaying_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.ST_at_PR_isPlaying_Fact p
            JOIN
                ties.ST_at_PR_isPlaying_Meta a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            AND
                a.ST_at_PR_isPlaying_Who = COALESCE(positor, a.ST_at_PR_isPlaying_Who)
            WHERE
                p.ST_at_PR_isPlaying_ChangedAt > changingTimepoint
            AND
                a.ST_at_PR_isPlaying_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fST_at_PR_isPlaying;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Who,
            AC_parent_AC_child_PAT_having_Confidence,
            AC_parent_AC_child_PAT_having_Stance
        FROM
            ties.AC_parent_AC_child_PAT_having_Meta
        WHERE
            AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
    ]';
END rAC_parent_AC_child_PAT_having_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Who,
            AC_parent_AC_child_PAT_having_Confidence,
            AC_parent_AC_child_PAT_having_Stance
        FROM (
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
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_parent_AC_child_PAT_having_ID,
                        a.AC_parent_AC_child_PAT_having_Who
                    ORDER BY
                        a.AC_parent_AC_child_PAT_having_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_parent_AC_child_PAT_having_Fact p
            JOIN
                ties.AC_parent_AC_child_PAT_having_Meta a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            AND
                a.AC_parent_AC_child_PAT_having_Who = COALESCE(positor, a.AC_parent_AC_child_PAT_having_Who)
            WHERE
                a.AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_parent_AC_child_PAT_having;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_parent_AC_child_PAT_having (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Who,
            AC_parent_AC_child_PAT_having_Confidence,
            AC_parent_AC_child_PAT_having_Stance
        FROM (
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
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_parent_AC_child_PAT_having_ID,
                        a.AC_parent_AC_child_PAT_having_Who
                    ORDER BY
                        a.AC_parent_AC_child_PAT_having_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_parent_AC_child_PAT_having_Fact p
            JOIN
                ties.AC_parent_AC_child_PAT_having_Meta a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            AND
                a.AC_parent_AC_child_PAT_having_Who = COALESCE(positor, a.AC_parent_AC_child_PAT_having_Who)
            WHERE
                a.AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_parent_AC_child_PAT_having;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_content_ST_location_EV_of_ID,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of,
            PR_content_ST_location_EV_of_ChangedAt
        FROM
            ties.PR_content_ST_location_EV_of_Fact
        WHERE
            PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
    ]';
END rPR_content_ST_location_EV_of_Fact;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_content_ST_location_EV_of_ID,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of,
            PR_content_ST_location_EV_of_ChangedAt
        FROM
            ties.PR_content_ST_location_EV_of_Fact
        WHERE
            PR_content_ST_location_EV_of_ChangedAt > changingTimepoint
    ]';
END fPR_content_ST_location_EV_of_Fact;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Who,
            PR_content_ST_location_EV_of_Confidence,
            PR_content_ST_location_EV_of_Stance
        FROM
            ties.PR_content_ST_location_EV_of_Meta
        WHERE
            PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
    ]';
END rPR_content_ST_location_EV_of_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of,
            PR_content_ST_location_EV_of_ChangedAt,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Who,
            PR_content_ST_location_EV_of_Confidence,
            PR_content_ST_location_EV_of_Stance
        FROM (
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
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_content_ST_location_EV_of_ID,
                        a.PR_content_ST_location_EV_of_Who
                    ORDER BY
                        a.PR_content_ST_location_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.PR_content_ST_location_EV_of_Fact p
            JOIN
                ties.PR_content_ST_location_EV_of_Meta a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            AND
                a.PR_content_ST_location_EV_of_Who = COALESCE(positor, a.PR_content_ST_location_EV_of_Who)
            WHERE
                p.PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
            AND
                a.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_content_ST_location_EV_of;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of,
            PR_content_ST_location_EV_of_ChangedAt,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Who,
            PR_content_ST_location_EV_of_Confidence,
            PR_content_ST_location_EV_of_Stance
        FROM (
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
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_content_ST_location_EV_of_ID,
                        a.PR_content_ST_location_EV_of_Who
                    ORDER BY
                        a.PR_content_ST_location_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.PR_content_ST_location_EV_of_Fact p
            JOIN
                ties.PR_content_ST_location_EV_of_Meta a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            AND
                a.PR_content_ST_location_EV_of_Who = COALESCE(positor, a.PR_content_ST_location_EV_of_Who)
            WHERE
                p.PR_content_ST_location_EV_of_ChangedAt > changingTimepoint
            AND
                a.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fPR_content_ST_location_EV_of;
/
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_part_PR_wasPlayed(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinder of a tie is not called in the macros, what it does is written out in them: the posit and annex of the
-- tie joined, the annex with the latest positing time picked for each posit and positor.
--
-- The latest and now perspectives are views over the point-in-time macro. A macro cannot be given a column of another
-- table to work for each positor, so the point-in-time macro works out the views of all positors itself, as does the
-- difference macro. The time traveling macro shows one positor, given by its first argument.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_partner_AC_with_ONG_currently (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Who,
            t.AC_partner_AC_with_ONG_currently_Confidence,
            t.AC_partner_AC_with_ONG_currently_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Who, s.AC_ID_partner
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Confidence DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Who, s.AC_ID_with
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Confidence DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_partner_AC_with_ONG_currently_Stance <> '?' THEN r.AC_partner_AC_with_ONG_currently_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_partner_AC_with_ONG_currently_Who,
                            r.AC_ID_partner,
                            r.AC_ID_with,
                            r.ONG_ID_currently
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_partner_AC_with_ONG_currently,
                        po.AC_partner_AC_with_ONG_currently_ID,
                        po.AC_ID_partner,
                        po.AC_ID_with,
                        po.ONG_ID_currently,
                        po.AC_partner_AC_with_ONG_currently_ChangedAt,
                        an.AC_partner_AC_with_ONG_currently_PositedAt,
                        an.AC_partner_AC_with_ONG_currently_Who,
                        an.AC_partner_AC_with_ONG_currently_Confidence,
                        an.AC_partner_AC_with_ONG_currently_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Who
                            ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_partner_AC_with_ONG_currently_Fact po
                    JOIN
                        ties.AC_partner_AC_with_ONG_currently_Meta an
                    ON
                        an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                    WHERE
                        po.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_partner_AC_with_ONG_currently_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_partner_AC_with_ONG_currently_Stance = COALESCE(assertion, s.AC_partner_AC_with_ONG_currently_Stance)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.AC_partner_AC_with_ONG_currently_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            knots.ONG_Ongoing "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.AC_partner_AC_with_ONG_currently_Who = forPositor
        AND
            t.latestPositAC_ID_partner = 1
        AND
            t.latestPositAC_ID_with = 1
    ]';
END tAC_partner_AC_with_ONG_currently;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Who,
            t.AC_partner_AC_with_ONG_currently_Confidence,
            t.AC_partner_AC_with_ONG_currently_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Who, s.AC_ID_partner
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Confidence DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Who, s.AC_ID_with
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Confidence DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_partner_AC_with_ONG_currently_Stance <> '?' THEN r.AC_partner_AC_with_ONG_currently_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_partner_AC_with_ONG_currently_Who,
                            r.AC_ID_partner,
                            r.AC_ID_with,
                            r.ONG_ID_currently
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_partner_AC_with_ONG_currently,
                        po.AC_partner_AC_with_ONG_currently_ID,
                        po.AC_ID_partner,
                        po.AC_ID_with,
                        po.ONG_ID_currently,
                        po.AC_partner_AC_with_ONG_currently_ChangedAt,
                        an.AC_partner_AC_with_ONG_currently_PositedAt,
                        an.AC_partner_AC_with_ONG_currently_Who,
                        an.AC_partner_AC_with_ONG_currently_Confidence,
                        an.AC_partner_AC_with_ONG_currently_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Who
                            ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_partner_AC_with_ONG_currently_Fact po
                    JOIN
                        ties.AC_partner_AC_with_ONG_currently_Meta an
                    ON
                        an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                    WHERE
                        po.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_partner_AC_with_ONG_currently_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_partner_AC_with_ONG_currently_Stance = '+'
            AND
                s.AC_partner_AC_with_ONG_currently_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.AC_partner_AC_with_ONG_currently_Who
        LEFT JOIN
            knots.ONG_Ongoing "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.latestPositAC_ID_partner = 1
        AND
            t.latestPositAC_ID_with = 1
    ]';
END pAC_partner_AC_with_ONG_currently;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    ties.pAC_partner_AC_with_ONG_currently(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    ties.pAC_partner_AC_with_ONG_currently(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            q.Who,
            q.inspectedTimepoint,
            q.Metadata_AC_partner_AC_with_ONG_currently,
            q.AC_ID_partner,
            q.AC_ID_with,
            q.currently_ONG_Ongoing,
            q.currently_Metadata_ONG,
            q.ONG_ID_currently,
            q.AC_partner_AC_with_ONG_currently_ChangedAt,
            q.AC_partner_AC_with_ONG_currently_PositedAt,
            q.AC_partner_AC_with_ONG_currently_Who,
            q.AC_partner_AC_with_ONG_currently_Confidence,
            q.AC_partner_AC_with_ONG_currently_Stance
        FROM (
        SELECT
            positorTable.Who,
            tp.inspectedTimepoint,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Who,
            t.AC_partner_AC_with_ONG_currently_Confidence,
            t.AC_partner_AC_with_ONG_currently_Stance,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.AC_ID_partner
                ORDER BY
                    t.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_Confidence DESC,
                    t.AC_partner_AC_with_ONG_currently_ID DESC
            ) AS latestPositAC_ID_partner,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.AC_ID_with
                ORDER BY
                    t.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_Confidence DESC,
                    t.AC_partner_AC_with_ONG_currently_ID DESC
            ) AS latestPositAC_ID_with
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_partner_AC_with_ONG_currently_Who AS inspectedPositor,
                CAST(h.AC_partner_AC_with_ONG_currently_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.AC_partner_AC_with_ONG_currently h
            WHERE
                h.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Who
        JOIN (
            SELECT
                y.*,
                LEAD(y.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (
                    PARTITION BY
                        y.AC_partner_AC_with_ONG_currently_Who,
                        y.AC_ID_partner,
                        y.AC_ID_with,
                        y.ONG_ID_currently
                    ORDER BY y.AC_partner_AC_with_ONG_currently_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.AC_partner_AC_with_ONG_currently_Who,
                                r.AC_ID_partner,
                                r.AC_ID_with,
                                r.ONG_ID_currently,
                                r.AC_partner_AC_with_ONG_currently_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_partner_AC_with_ONG_currently_Stance = '+' THEN 0 ELSE 1 END,
                                r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                                r.AC_partner_AC_with_ONG_currently_Confidence DESC,
                                r.AC_partner_AC_with_ONG_currently_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_partner_AC_with_ONG_currently,
                            po.AC_partner_AC_with_ONG_currently_ID,
                            po.AC_ID_partner,
                            po.AC_ID_with,
                            po.ONG_ID_currently,
                            po.AC_partner_AC_with_ONG_currently_ChangedAt,
                            an.AC_partner_AC_with_ONG_currently_PositedAt,
                            an.AC_partner_AC_with_ONG_currently_Who,
                            an.AC_partner_AC_with_ONG_currently_Confidence,
                            an.AC_partner_AC_with_ONG_currently_Stance,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Who
                                ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.AC_partner_AC_with_ONG_currently_Fact po
                        JOIN
                            ties.AC_partner_AC_with_ONG_currently_Meta an
                        ON
                            an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_partner_AC_with_ONG_currently_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.AC_partner_AC_with_ONG_currently_Who = tp.inspectedPositor
        AND
            t.AC_partner_AC_with_ONG_currently_Stance = '+'
        AND
            t.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.ONG_Ongoing "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        ) q
        WHERE
            q.latestPositAC_ID_partner = 1
        AND
            q.latestPositAC_ID_with = 1
    ]';
END dAC_partner_AC_with_ONG_currently;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_subset_PN_of (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_AC_subset_PN_of,
            t.AC_ID_subset,
            t.PN_ID_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Who,
            t.AC_subset_PN_of_Confidence,
            t.AC_subset_PN_of_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Who, s.AC_ID_subset
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Confidence DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Who, s.PN_ID_of
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Confidence DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositPN_ID_of
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_subset_PN_of,
                        po.AC_subset_PN_of_ID,
                        po.AC_ID_subset,
                        po.PN_ID_of,
                        an.AC_subset_PN_of_PositedAt,
                        an.AC_subset_PN_of_Who,
                        an.AC_subset_PN_of_Confidence,
                        an.AC_subset_PN_of_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_subset_PN_of_ID, an.AC_subset_PN_of_Who
                            ORDER BY an.AC_subset_PN_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_subset_PN_of_Fact po
                    JOIN
                        ties.AC_subset_PN_of_Meta an
                    ON
                        an.AC_subset_PN_of_ID = po.AC_subset_PN_of_ID
                    WHERE
                        an.AC_subset_PN_of_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_subset_PN_of_Stance = COALESCE(assertion, s.AC_subset_PN_of_Stance)
        ) t
        WHERE
            t.AC_subset_PN_of_Who = forPositor
        AND
            t.latestPositAC_ID_subset = 1
        AND
            t.latestPositPN_ID_of = 1
    ]';
END tAC_subset_PN_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_AC_subset_PN_of,
            t.AC_ID_subset,
            t.PN_ID_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Who,
            t.AC_subset_PN_of_Confidence,
            t.AC_subset_PN_of_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Who, s.AC_ID_subset
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Confidence DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Who, s.PN_ID_of
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Confidence DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositPN_ID_of
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_subset_PN_of,
                        po.AC_subset_PN_of_ID,
                        po.AC_ID_subset,
                        po.PN_ID_of,
                        an.AC_subset_PN_of_PositedAt,
                        an.AC_subset_PN_of_Who,
                        an.AC_subset_PN_of_Confidence,
                        an.AC_subset_PN_of_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_subset_PN_of_ID, an.AC_subset_PN_of_Who
                            ORDER BY an.AC_subset_PN_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_subset_PN_of_Fact po
                    JOIN
                        ties.AC_subset_PN_of_Meta an
                    ON
                        an.AC_subset_PN_of_ID = po.AC_subset_PN_of_ID
                    WHERE
                        an.AC_subset_PN_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_subset_PN_of_Stance = '+'
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.AC_subset_PN_of_Who
        WHERE
            t.latestPositAC_ID_subset = 1
        AND
            t.latestPositPN_ID_of = 1
    ]';
END pAC_subset_PN_of;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of
AS
SELECT
    *
FROM
    ties.pAC_subset_PN_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of
AS
SELECT
    *
FROM
    ties.pAC_subset_PN_of(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tEV_in_AC_wasCast (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_EV_in_AC_wasCast,
            t.EV_ID_in,
            t.AC_ID_wasCast,
            t.EV_in_AC_wasCast_PositedAt,
            t.EV_in_AC_wasCast_Who,
            t.EV_in_AC_wasCast_Confidence,
            t.EV_in_AC_wasCast_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.EV_in_AC_wasCast_Who,
                        s.EV_ID_in,
                        s.AC_ID_wasCast
                    ORDER BY
                        s.EV_in_AC_wasCast_PositedAt DESC,
                        s.EV_in_AC_wasCast_Confidence DESC,
                        s.EV_in_AC_wasCast_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_EV_in_AC_wasCast,
                        po.EV_in_AC_wasCast_ID,
                        po.EV_ID_in,
                        po.AC_ID_wasCast,
                        an.EV_in_AC_wasCast_PositedAt,
                        an.EV_in_AC_wasCast_Who,
                        an.EV_in_AC_wasCast_Confidence,
                        an.EV_in_AC_wasCast_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_in_AC_wasCast_ID, an.EV_in_AC_wasCast_Who
                            ORDER BY an.EV_in_AC_wasCast_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.EV_in_AC_wasCast_Fact po
                    JOIN
                        ties.EV_in_AC_wasCast_Meta an
                    ON
                        an.EV_in_AC_wasCast_ID = po.EV_in_AC_wasCast_ID
                    WHERE
                        an.EV_in_AC_wasCast_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.EV_in_AC_wasCast_Stance = COALESCE(assertion, s.EV_in_AC_wasCast_Stance)
        ) t
        WHERE
            t.EV_in_AC_wasCast_Who = forPositor
        AND
            t.latestPosit = 1
    ]';
END tEV_in_AC_wasCast;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_wasCast (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_EV_in_AC_wasCast,
            t.EV_ID_in,
            t.AC_ID_wasCast,
            t.EV_in_AC_wasCast_PositedAt,
            t.EV_in_AC_wasCast_Who,
            t.EV_in_AC_wasCast_Confidence,
            t.EV_in_AC_wasCast_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.EV_in_AC_wasCast_Who,
                        s.EV_ID_in,
                        s.AC_ID_wasCast
                    ORDER BY
                        s.EV_in_AC_wasCast_PositedAt DESC,
                        s.EV_in_AC_wasCast_Confidence DESC,
                        s.EV_in_AC_wasCast_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_EV_in_AC_wasCast,
                        po.EV_in_AC_wasCast_ID,
                        po.EV_ID_in,
                        po.AC_ID_wasCast,
                        an.EV_in_AC_wasCast_PositedAt,
                        an.EV_in_AC_wasCast_Who,
                        an.EV_in_AC_wasCast_Confidence,
                        an.EV_in_AC_wasCast_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_in_AC_wasCast_ID, an.EV_in_AC_wasCast_Who
                            ORDER BY an.EV_in_AC_wasCast_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.EV_in_AC_wasCast_Fact po
                    JOIN
                        ties.EV_in_AC_wasCast_Meta an
                    ON
                        an.EV_in_AC_wasCast_ID = po.EV_in_AC_wasCast_ID
                    WHERE
                        an.EV_in_AC_wasCast_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.EV_in_AC_wasCast_Stance = '+'
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.EV_in_AC_wasCast_Who
        WHERE
            t.latestPosit = 1
    ]';
END pEV_in_AC_wasCast;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast
AS
SELECT
    *
FROM
    ties.pEV_in_AC_wasCast(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast
AS
SELECT
    *
FROM
    ties.pEV_in_AC_wasCast(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_part_PR_in_RAT_got (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Checksum AS got_RAT_Checksum,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Who,
            t.AC_part_PR_in_RAT_got_Confidence,
            t.AC_part_PR_in_RAT_got_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_part_PR_in_RAT_got_Who,
                        s.AC_ID_part,
                        s.PR_ID_in
                    ORDER BY
                        s.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        s.AC_part_PR_in_RAT_got_PositedAt DESC,
                        s.AC_part_PR_in_RAT_got_Confidence DESC,
                        s.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_part_PR_in_RAT_got_Stance <> '?' THEN r.AC_part_PR_in_RAT_got_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_part_PR_in_RAT_got_Who,
                            r.AC_ID_part,
                            r.PR_ID_in
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_part_PR_in_RAT_got,
                        po.AC_part_PR_in_RAT_got_ID,
                        po.AC_ID_part,
                        po.PR_ID_in,
                        po.RAT_ID_got,
                        po.AC_part_PR_in_RAT_got_ChangedAt,
                        an.AC_part_PR_in_RAT_got_PositedAt,
                        an.AC_part_PR_in_RAT_got_Who,
                        an.AC_part_PR_in_RAT_got_Confidence,
                        an.AC_part_PR_in_RAT_got_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_part_PR_in_RAT_got_ID, an.AC_part_PR_in_RAT_got_Who
                            ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_part_PR_in_RAT_got_Fact po
                    JOIN
                        ties.AC_part_PR_in_RAT_got_Meta an
                    ON
                        an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
                    WHERE
                        po.AC_part_PR_in_RAT_got_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_part_PR_in_RAT_got_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_part_PR_in_RAT_got_Stance = COALESCE(assertion, s.AC_part_PR_in_RAT_got_Stance)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.AC_part_PR_in_RAT_got_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            knots.RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.AC_part_PR_in_RAT_got_Who = forPositor
        AND
            t.latestPosit = 1
    ]';
END tAC_part_PR_in_RAT_got;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Checksum AS got_RAT_Checksum,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Who,
            t.AC_part_PR_in_RAT_got_Confidence,
            t.AC_part_PR_in_RAT_got_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_part_PR_in_RAT_got_Who,
                        s.AC_ID_part,
                        s.PR_ID_in
                    ORDER BY
                        s.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        s.AC_part_PR_in_RAT_got_PositedAt DESC,
                        s.AC_part_PR_in_RAT_got_Confidence DESC,
                        s.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_part_PR_in_RAT_got_Stance <> '?' THEN r.AC_part_PR_in_RAT_got_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_part_PR_in_RAT_got_Who,
                            r.AC_ID_part,
                            r.PR_ID_in
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_part_PR_in_RAT_got,
                        po.AC_part_PR_in_RAT_got_ID,
                        po.AC_ID_part,
                        po.PR_ID_in,
                        po.RAT_ID_got,
                        po.AC_part_PR_in_RAT_got_ChangedAt,
                        an.AC_part_PR_in_RAT_got_PositedAt,
                        an.AC_part_PR_in_RAT_got_Who,
                        an.AC_part_PR_in_RAT_got_Confidence,
                        an.AC_part_PR_in_RAT_got_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_part_PR_in_RAT_got_ID, an.AC_part_PR_in_RAT_got_Who
                            ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_part_PR_in_RAT_got_Fact po
                    JOIN
                        ties.AC_part_PR_in_RAT_got_Meta an
                    ON
                        an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
                    WHERE
                        po.AC_part_PR_in_RAT_got_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_part_PR_in_RAT_got_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_part_PR_in_RAT_got_Stance = '+'
            AND
                s.AC_part_PR_in_RAT_got_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.AC_part_PR_in_RAT_got_Who
        LEFT JOIN
            knots.RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.latestPosit = 1
    ]';
END pAC_part_PR_in_RAT_got;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got
AS
SELECT
    *
FROM
    ties.pAC_part_PR_in_RAT_got(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_part_PR_in_RAT_got
AS
SELECT
    *
FROM
    ties.pAC_part_PR_in_RAT_got(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_part_PR_in_RAT_got (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            tp.inspectedTimepoint,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Checksum AS got_RAT_Checksum,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Who,
            t.AC_part_PR_in_RAT_got_Confidence,
            t.AC_part_PR_in_RAT_got_Stance
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_part_PR_in_RAT_got_Who AS inspectedPositor,
                CAST(h.AC_part_PR_in_RAT_got_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.AC_part_PR_in_RAT_got h
            WHERE
                h.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Who
        JOIN (
            SELECT
                y.*,
                LEAD(y.AC_part_PR_in_RAT_got_ChangedAt) OVER (
                    PARTITION BY
                        y.AC_part_PR_in_RAT_got_Who,
                        y.AC_ID_part,
                        y.PR_ID_in
                    ORDER BY y.AC_part_PR_in_RAT_got_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.AC_part_PR_in_RAT_got_Who,
                                r.AC_ID_part,
                                r.PR_ID_in,
                                r.AC_part_PR_in_RAT_got_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_part_PR_in_RAT_got_Stance = '+' THEN 0 ELSE 1 END,
                                r.AC_part_PR_in_RAT_got_PositedAt DESC,
                                r.AC_part_PR_in_RAT_got_Confidence DESC,
                                r.AC_part_PR_in_RAT_got_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_part_PR_in_RAT_got,
                            po.AC_part_PR_in_RAT_got_ID,
                            po.AC_ID_part,
                            po.PR_ID_in,
                            po.RAT_ID_got,
                            po.AC_part_PR_in_RAT_got_ChangedAt,
                            an.AC_part_PR_in_RAT_got_PositedAt,
                            an.AC_part_PR_in_RAT_got_Who,
                            an.AC_part_PR_in_RAT_got_Confidence,
                            an.AC_part_PR_in_RAT_got_Stance,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_part_PR_in_RAT_got_ID, an.AC_part_PR_in_RAT_got_Who
                                ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.AC_part_PR_in_RAT_got_Fact po
                        JOIN
                            ties.AC_part_PR_in_RAT_got_Meta an
                        ON
                            an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_part_PR_in_RAT_got_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.AC_part_PR_in_RAT_got_Who = tp.inspectedPositor
        AND
            t.AC_part_PR_in_RAT_got_Stance = '+'
        AND
            t.AC_part_PR_in_RAT_got_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
    ]';
END dAC_part_PR_in_RAT_got;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tST_at_PR_isPlaying (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_ID_at,
            t.PR_ID_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Who,
            t.ST_at_PR_isPlaying_Confidence,
            t.ST_at_PR_isPlaying_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.ST_at_PR_isPlaying_Who,
                        s.ST_ID_at,
                        s.PR_ID_isPlaying
                    ORDER BY
                        s.ST_at_PR_isPlaying_ChangedAt DESC,
                        s.ST_at_PR_isPlaying_PositedAt DESC,
                        s.ST_at_PR_isPlaying_Confidence DESC,
                        s.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.ST_at_PR_isPlaying_Stance <> '?' THEN r.ST_at_PR_isPlaying_ChangedAt END) OVER (
                        PARTITION BY
                            r.ST_at_PR_isPlaying_Who,
                            r.ST_ID_at,
                            r.PR_ID_isPlaying
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_ST_at_PR_isPlaying,
                        po.ST_at_PR_isPlaying_ID,
                        po.ST_ID_at,
                        po.PR_ID_isPlaying,
                        po.ST_at_PR_isPlaying_ChangedAt,
                        an.ST_at_PR_isPlaying_PositedAt,
                        an.ST_at_PR_isPlaying_Who,
                        an.ST_at_PR_isPlaying_Confidence,
                        an.ST_at_PR_isPlaying_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_at_PR_isPlaying_ID, an.ST_at_PR_isPlaying_Who
                            ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.ST_at_PR_isPlaying_Fact po
                    JOIN
                        ties.ST_at_PR_isPlaying_Meta an
                    ON
                        an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
                    WHERE
                        po.ST_at_PR_isPlaying_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_at_PR_isPlaying_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.ST_at_PR_isPlaying_Stance = COALESCE(assertion, s.ST_at_PR_isPlaying_Stance)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.ST_at_PR_isPlaying_ChangedAt = s.inEffect
            )
        ) t
        WHERE
            t.ST_at_PR_isPlaying_Who = forPositor
        AND
            t.latestPosit = 1
    ]';
END tST_at_PR_isPlaying;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_isPlaying (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_ID_at,
            t.PR_ID_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Who,
            t.ST_at_PR_isPlaying_Confidence,
            t.ST_at_PR_isPlaying_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.ST_at_PR_isPlaying_Who,
                        s.ST_ID_at,
                        s.PR_ID_isPlaying
                    ORDER BY
                        s.ST_at_PR_isPlaying_ChangedAt DESC,
                        s.ST_at_PR_isPlaying_PositedAt DESC,
                        s.ST_at_PR_isPlaying_Confidence DESC,
                        s.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.ST_at_PR_isPlaying_Stance <> '?' THEN r.ST_at_PR_isPlaying_ChangedAt END) OVER (
                        PARTITION BY
                            r.ST_at_PR_isPlaying_Who,
                            r.ST_ID_at,
                            r.PR_ID_isPlaying
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_ST_at_PR_isPlaying,
                        po.ST_at_PR_isPlaying_ID,
                        po.ST_ID_at,
                        po.PR_ID_isPlaying,
                        po.ST_at_PR_isPlaying_ChangedAt,
                        an.ST_at_PR_isPlaying_PositedAt,
                        an.ST_at_PR_isPlaying_Who,
                        an.ST_at_PR_isPlaying_Confidence,
                        an.ST_at_PR_isPlaying_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_at_PR_isPlaying_ID, an.ST_at_PR_isPlaying_Who
                            ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.ST_at_PR_isPlaying_Fact po
                    JOIN
                        ties.ST_at_PR_isPlaying_Meta an
                    ON
                        an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
                    WHERE
                        po.ST_at_PR_isPlaying_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_at_PR_isPlaying_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.ST_at_PR_isPlaying_Stance = '+'
            AND
                s.ST_at_PR_isPlaying_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.ST_at_PR_isPlaying_Who
        WHERE
            t.latestPosit = 1
    ]';
END pST_at_PR_isPlaying;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying
AS
SELECT
    *
FROM
    ties.pST_at_PR_isPlaying(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nST_at_PR_isPlaying
AS
SELECT
    *
FROM
    ties.pST_at_PR_isPlaying(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dST_at_PR_isPlaying (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            tp.inspectedTimepoint,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_ID_at,
            t.PR_ID_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Who,
            t.ST_at_PR_isPlaying_Confidence,
            t.ST_at_PR_isPlaying_Stance
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.ST_at_PR_isPlaying_Who AS inspectedPositor,
                CAST(h.ST_at_PR_isPlaying_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.ST_at_PR_isPlaying h
            WHERE
                h.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Who
        JOIN (
            SELECT
                y.*,
                LEAD(y.ST_at_PR_isPlaying_ChangedAt) OVER (
                    PARTITION BY
                        y.ST_at_PR_isPlaying_Who,
                        y.ST_ID_at,
                        y.PR_ID_isPlaying
                    ORDER BY y.ST_at_PR_isPlaying_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.ST_at_PR_isPlaying_Who,
                                r.ST_ID_at,
                                r.PR_ID_isPlaying,
                                r.ST_at_PR_isPlaying_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_at_PR_isPlaying_Stance = '+' THEN 0 ELSE 1 END,
                                r.ST_at_PR_isPlaying_PositedAt DESC,
                                r.ST_at_PR_isPlaying_Confidence DESC,
                                r.ST_at_PR_isPlaying_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_at_PR_isPlaying,
                            po.ST_at_PR_isPlaying_ID,
                            po.ST_ID_at,
                            po.PR_ID_isPlaying,
                            po.ST_at_PR_isPlaying_ChangedAt,
                            an.ST_at_PR_isPlaying_PositedAt,
                            an.ST_at_PR_isPlaying_Who,
                            an.ST_at_PR_isPlaying_Confidence,
                            an.ST_at_PR_isPlaying_Stance,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_at_PR_isPlaying_ID, an.ST_at_PR_isPlaying_Who
                                ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.ST_at_PR_isPlaying_Fact po
                        JOIN
                            ties.ST_at_PR_isPlaying_Meta an
                        ON
                            an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_at_PR_isPlaying_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.ST_at_PR_isPlaying_Who = tp.inspectedPositor
        AND
            t.ST_at_PR_isPlaying_Stance = '+'
        AND
            t.ST_at_PR_isPlaying_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
    ]';
END dST_at_PR_isPlaying;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_parent_AC_child_PAT_having (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_AC_parent_AC_child_PAT_having,
            t.AC_ID_parent,
            t.AC_ID_child,
            "kPAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "kPAT_having".Metadata_PAT AS having_Metadata_PAT,
            t.PAT_ID_having,
            t.AC_parent_AC_child_PAT_having_PositedAt,
            t.AC_parent_AC_child_PAT_having_Who,
            t.AC_parent_AC_child_PAT_having_Confidence,
            t.AC_parent_AC_child_PAT_having_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_parent_AC_child_PAT_having_Who,
                        s.AC_ID_parent,
                        s.AC_ID_child,
                        s.PAT_ID_having
                    ORDER BY
                        s.AC_parent_AC_child_PAT_having_PositedAt DESC,
                        s.AC_parent_AC_child_PAT_having_Confidence DESC,
                        s.AC_parent_AC_child_PAT_having_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_parent_AC_child_PAT_having,
                        po.AC_parent_AC_child_PAT_having_ID,
                        po.AC_ID_parent,
                        po.AC_ID_child,
                        po.PAT_ID_having,
                        an.AC_parent_AC_child_PAT_having_PositedAt,
                        an.AC_parent_AC_child_PAT_having_Who,
                        an.AC_parent_AC_child_PAT_having_Confidence,
                        an.AC_parent_AC_child_PAT_having_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_parent_AC_child_PAT_having_ID, an.AC_parent_AC_child_PAT_having_Who
                            ORDER BY an.AC_parent_AC_child_PAT_having_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_parent_AC_child_PAT_having_Fact po
                    JOIN
                        ties.AC_parent_AC_child_PAT_having_Meta an
                    ON
                        an.AC_parent_AC_child_PAT_having_ID = po.AC_parent_AC_child_PAT_having_ID
                    WHERE
                        an.AC_parent_AC_child_PAT_having_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_parent_AC_child_PAT_having_Stance = COALESCE(assertion, s.AC_parent_AC_child_PAT_having_Stance)
        ) t
        LEFT JOIN
            knots.PAT_ParentalType "kPAT_having"
        ON
            "kPAT_having".PAT_ID = t.PAT_ID_having
        WHERE
            t.AC_parent_AC_child_PAT_having_Who = forPositor
        AND
            t.latestPosit = 1
    ]';
END tAC_parent_AC_child_PAT_having;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_parent_AC_child_PAT_having (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_AC_parent_AC_child_PAT_having,
            t.AC_ID_parent,
            t.AC_ID_child,
            "kPAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "kPAT_having".Metadata_PAT AS having_Metadata_PAT,
            t.PAT_ID_having,
            t.AC_parent_AC_child_PAT_having_PositedAt,
            t.AC_parent_AC_child_PAT_having_Who,
            t.AC_parent_AC_child_PAT_having_Confidence,
            t.AC_parent_AC_child_PAT_having_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_parent_AC_child_PAT_having_Who,
                        s.AC_ID_parent,
                        s.AC_ID_child,
                        s.PAT_ID_having
                    ORDER BY
                        s.AC_parent_AC_child_PAT_having_PositedAt DESC,
                        s.AC_parent_AC_child_PAT_having_Confidence DESC,
                        s.AC_parent_AC_child_PAT_having_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_parent_AC_child_PAT_having,
                        po.AC_parent_AC_child_PAT_having_ID,
                        po.AC_ID_parent,
                        po.AC_ID_child,
                        po.PAT_ID_having,
                        an.AC_parent_AC_child_PAT_having_PositedAt,
                        an.AC_parent_AC_child_PAT_having_Who,
                        an.AC_parent_AC_child_PAT_having_Confidence,
                        an.AC_parent_AC_child_PAT_having_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_parent_AC_child_PAT_having_ID, an.AC_parent_AC_child_PAT_having_Who
                            ORDER BY an.AC_parent_AC_child_PAT_having_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_parent_AC_child_PAT_having_Fact po
                    JOIN
                        ties.AC_parent_AC_child_PAT_having_Meta an
                    ON
                        an.AC_parent_AC_child_PAT_having_ID = po.AC_parent_AC_child_PAT_having_ID
                    WHERE
                        an.AC_parent_AC_child_PAT_having_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_parent_AC_child_PAT_having_Stance = '+'
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.AC_parent_AC_child_PAT_having_Who
        LEFT JOIN
            knots.PAT_ParentalType "kPAT_having"
        ON
            "kPAT_having".PAT_ID = t.PAT_ID_having
        WHERE
            t.latestPosit = 1
    ]';
END pAC_parent_AC_child_PAT_having;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    ties.pAC_parent_AC_child_PAT_having(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    ties.pAC_parent_AC_child_PAT_having(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tPR_content_ST_location_EV_of (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of,
            t.PR_content_ST_location_EV_of_ChangedAt,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Who,
            t.PR_content_ST_location_EV_of_Confidence,
            t.PR_content_ST_location_EV_of_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_content_ST_location_EV_of_Who, s.PR_ID_content
                    ORDER BY
                        s.PR_content_ST_location_EV_of_ChangedAt DESC,
                        s.PR_content_ST_location_EV_of_PositedAt DESC,
                        s.PR_content_ST_location_EV_of_Confidence DESC,
                        s.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPositPR_ID_content,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_content_ST_location_EV_of_Who, s.ST_ID_location
                    ORDER BY
                        s.PR_content_ST_location_EV_of_ChangedAt DESC,
                        s.PR_content_ST_location_EV_of_PositedAt DESC,
                        s.PR_content_ST_location_EV_of_Confidence DESC,
                        s.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPositST_ID_location
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.PR_content_ST_location_EV_of_Stance <> '?' THEN r.PR_content_ST_location_EV_of_ChangedAt END) OVER (
                        PARTITION BY
                            r.PR_content_ST_location_EV_of_Who,
                            r.PR_ID_content,
                            r.ST_ID_location,
                            r.EV_ID_of
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_PR_content_ST_location_EV_of,
                        po.PR_content_ST_location_EV_of_ID,
                        po.PR_ID_content,
                        po.ST_ID_location,
                        po.EV_ID_of,
                        po.PR_content_ST_location_EV_of_ChangedAt,
                        an.PR_content_ST_location_EV_of_PositedAt,
                        an.PR_content_ST_location_EV_of_Who,
                        an.PR_content_ST_location_EV_of_Confidence,
                        an.PR_content_ST_location_EV_of_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_content_ST_location_EV_of_ID, an.PR_content_ST_location_EV_of_Who
                            ORDER BY an.PR_content_ST_location_EV_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.PR_content_ST_location_EV_of_Fact po
                    JOIN
                        ties.PR_content_ST_location_EV_of_Meta an
                    ON
                        an.PR_content_ST_location_EV_of_ID = po.PR_content_ST_location_EV_of_ID
                    WHERE
                        po.PR_content_ST_location_EV_of_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.PR_content_ST_location_EV_of_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.PR_content_ST_location_EV_of_Stance = COALESCE(assertion, s.PR_content_ST_location_EV_of_Stance)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.PR_content_ST_location_EV_of_ChangedAt = s.inEffect
            )
        ) t
        WHERE
            t.PR_content_ST_location_EV_of_Who = forPositor
        AND
            t.latestPositPR_ID_content = 1
        AND
            t.latestPositST_ID_location = 1
    ]';
END tPR_content_ST_location_EV_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_content_ST_location_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of,
            t.PR_content_ST_location_EV_of_ChangedAt,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Who,
            t.PR_content_ST_location_EV_of_Confidence,
            t.PR_content_ST_location_EV_of_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_content_ST_location_EV_of_Who, s.PR_ID_content
                    ORDER BY
                        s.PR_content_ST_location_EV_of_ChangedAt DESC,
                        s.PR_content_ST_location_EV_of_PositedAt DESC,
                        s.PR_content_ST_location_EV_of_Confidence DESC,
                        s.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPositPR_ID_content,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_content_ST_location_EV_of_Who, s.ST_ID_location
                    ORDER BY
                        s.PR_content_ST_location_EV_of_ChangedAt DESC,
                        s.PR_content_ST_location_EV_of_PositedAt DESC,
                        s.PR_content_ST_location_EV_of_Confidence DESC,
                        s.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPositST_ID_location
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.PR_content_ST_location_EV_of_Stance <> '?' THEN r.PR_content_ST_location_EV_of_ChangedAt END) OVER (
                        PARTITION BY
                            r.PR_content_ST_location_EV_of_Who,
                            r.PR_ID_content,
                            r.ST_ID_location,
                            r.EV_ID_of
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_PR_content_ST_location_EV_of,
                        po.PR_content_ST_location_EV_of_ID,
                        po.PR_ID_content,
                        po.ST_ID_location,
                        po.EV_ID_of,
                        po.PR_content_ST_location_EV_of_ChangedAt,
                        an.PR_content_ST_location_EV_of_PositedAt,
                        an.PR_content_ST_location_EV_of_Who,
                        an.PR_content_ST_location_EV_of_Confidence,
                        an.PR_content_ST_location_EV_of_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_content_ST_location_EV_of_ID, an.PR_content_ST_location_EV_of_Who
                            ORDER BY an.PR_content_ST_location_EV_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.PR_content_ST_location_EV_of_Fact po
                    JOIN
                        ties.PR_content_ST_location_EV_of_Meta an
                    ON
                        an.PR_content_ST_location_EV_of_ID = po.PR_content_ST_location_EV_of_ID
                    WHERE
                        po.PR_content_ST_location_EV_of_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.PR_content_ST_location_EV_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.PR_content_ST_location_EV_of_Stance = '+'
            AND
                s.PR_content_ST_location_EV_of_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.PR_content_ST_location_EV_of_Who
        WHERE
            t.latestPositPR_ID_content = 1
        AND
            t.latestPositST_ID_location = 1
    ]';
END pPR_content_ST_location_EV_of;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of
AS
SELECT
    *
FROM
    ties.pPR_content_ST_location_EV_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nPR_content_ST_location_EV_of
AS
SELECT
    *
FROM
    ties.pPR_content_ST_location_EV_of(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dPR_content_ST_location_EV_of (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            q.Who,
            q.inspectedTimepoint,
            q.Metadata_PR_content_ST_location_EV_of,
            q.PR_ID_content,
            q.ST_ID_location,
            q.EV_ID_of,
            q.PR_content_ST_location_EV_of_ChangedAt,
            q.PR_content_ST_location_EV_of_PositedAt,
            q.PR_content_ST_location_EV_of_Who,
            q.PR_content_ST_location_EV_of_Confidence,
            q.PR_content_ST_location_EV_of_Stance
        FROM (
        SELECT
            positorTable.Who,
            tp.inspectedTimepoint,
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of,
            t.PR_content_ST_location_EV_of_ChangedAt,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Who,
            t.PR_content_ST_location_EV_of_Confidence,
            t.PR_content_ST_location_EV_of_Stance,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.PR_ID_content
                ORDER BY
                    t.PR_content_ST_location_EV_of_ChangedAt DESC,
                    t.PR_content_ST_location_EV_of_PositedAt DESC,
                    t.PR_content_ST_location_EV_of_Confidence DESC,
                    t.PR_content_ST_location_EV_of_ID DESC
            ) AS latestPositPR_ID_content,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.ST_ID_location
                ORDER BY
                    t.PR_content_ST_location_EV_of_ChangedAt DESC,
                    t.PR_content_ST_location_EV_of_PositedAt DESC,
                    t.PR_content_ST_location_EV_of_Confidence DESC,
                    t.PR_content_ST_location_EV_of_ID DESC
            ) AS latestPositST_ID_location
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.PR_content_ST_location_EV_of_Who AS inspectedPositor,
                CAST(h.PR_content_ST_location_EV_of_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.PR_content_ST_location_EV_of h
            WHERE
                h.PR_content_ST_location_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Who
        JOIN (
            SELECT
                y.*,
                LEAD(y.PR_content_ST_location_EV_of_ChangedAt) OVER (
                    PARTITION BY
                        y.PR_content_ST_location_EV_of_Who,
                        y.PR_ID_content,
                        y.ST_ID_location,
                        y.EV_ID_of
                    ORDER BY y.PR_content_ST_location_EV_of_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.PR_content_ST_location_EV_of_Who,
                                r.PR_ID_content,
                                r.ST_ID_location,
                                r.EV_ID_of,
                                r.PR_content_ST_location_EV_of_ChangedAt
                            ORDER BY
                                CASE WHEN r.PR_content_ST_location_EV_of_Stance = '+' THEN 0 ELSE 1 END,
                                r.PR_content_ST_location_EV_of_PositedAt DESC,
                                r.PR_content_ST_location_EV_of_Confidence DESC,
                                r.PR_content_ST_location_EV_of_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_PR_content_ST_location_EV_of,
                            po.PR_content_ST_location_EV_of_ID,
                            po.PR_ID_content,
                            po.ST_ID_location,
                            po.EV_ID_of,
                            po.PR_content_ST_location_EV_of_ChangedAt,
                            an.PR_content_ST_location_EV_of_PositedAt,
                            an.PR_content_ST_location_EV_of_Who,
                            an.PR_content_ST_location_EV_of_Confidence,
                            an.PR_content_ST_location_EV_of_Stance,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_content_ST_location_EV_of_ID, an.PR_content_ST_location_EV_of_Who
                                ORDER BY an.PR_content_ST_location_EV_of_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.PR_content_ST_location_EV_of_Fact po
                        JOIN
                            ties.PR_content_ST_location_EV_of_Meta an
                        ON
                            an.PR_content_ST_location_EV_of_ID = po.PR_content_ST_location_EV_of_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.PR_content_ST_location_EV_of_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.PR_content_ST_location_EV_of_Who = tp.inspectedPositor
        AND
            t.PR_content_ST_location_EV_of_Stance = '+'
        AND
            t.PR_content_ST_location_EV_of_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        ) q
        WHERE
            q.latestPositPR_ID_content = 1
        AND
            q.latestPositST_ID_location = 1
    ]';
END dPR_content_ST_location_EV_of;
/
-- ATTRIBUTE INSERT PROCEDURES ----------------------------------------------------------------------------------------
--
-- The procedures here state one posit of an attribute and what a positor asserts of it, in the way that the model says,
-- like the triggers on the assembled views do in PostgreSQL: the positor is 0, the positing time is now and the
-- reliability is 1 where they are not given. They are procedures and not triggers on the assembled views (which are views
-- that Oracle would need an INSTEAD OF trigger on) or on the posit and annex tables, since Oracle does not let a row
-- trigger read the table it is on (ORA-04091), which these rules do. The INSTEAD OF triggers on the latest views of the
-- anchors, and those of the nexuses, call them, and so can a load:
--
--     BEGIN ip_AC_NAM_Actor_Name(p_owner => 1, p_value => 'Ann', p_changing => SYSTIMESTAMP, p_positor => 0, p_reliability => 1, p_metadata => 1); END;
--
-- ip_<attribute.name> (one for every attribute of an anchor or a nexus, named as the attribute is in the model, written in
-- front of its schema if it has one). Its parameters are named, and all except the owner and the value may be left out (or
-- be null), when the default of the one left out is used:
--
--     p_owner        the entity that has the attribute, a column of the posit table: the entity reference of the attribute
--     p_value        the value that is posited, as it is in the posit table: for a knotted attribute the identity of the value in the
--                    knot, for an attribute with a checksum the value (the checksum is made by the table)
--     p_changing     only for a historized attribute: from when the value is valid. Default: now (current_timestamp)
--     p_positor      the positor that asserts the posit. Default: 0
--     p_positing     when the positor asserts it. Default: now
--     p_reliability  how reliable the positor says that it is: positive asserts the posit, negative asserts that it is not so, and
--                    0.25 retracts the assertion of it. Default: 1
--     p_metadata     only when the model has metadata: the metadata of the annex row. Default: 0
--
-- A posit that is not there is created. A retraction of what the positor does not hold states nothing. An error is raised
-- (RAISE_APPLICATION_ERROR) for a contradiction (-20001: the positor asserts another reliability of the same posit at the
-- same positing time, or in the model where positors are decisive another value for the same entity and changing time, or
-- in the model where positors are indecisive, alternatives with reliabilities that sum up to more than one) and for a
-- restatement (-20002: the value is the same as that of the version before or after it, where the attribute may not be
-- restated). A call that raises an error is undone, as is the statement that made it.
--
-- Two functions help the procedures and may be used in a query as well:
--
--     eq_<attribute.name>(p_left, p_right)         1 if two values of the attribute are the same, else 0
--     he_<attribute.name>(p_id, p_positor, p_positing)   the reliability that the positor holds for the posit with the identity
--                                                  at the positing time (that of its latest annex row up to then), null if it holds nothing
--
-- Positors are decisive: a positor holds one assertion at a time for an entity (and a changing time), so an assertion that
-- is not a retraction, positive or negative, of another value retracts, at its own positing time, the posit that the
-- positor holds, which is a correction.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_DAT_Event_Date tells whether two values of EV_DAT_Event_Date are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_DAT_Event_Date (
    p_left IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date%TYPE,
    p_right IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_DAT_Event_Date;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_DAT_Event_Date is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_DAT_Event_Date (
    p_id IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_ID%TYPE,
    p_positor IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_Who%TYPE,
    p_positing IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_PositedAt%TYPE
) RETURN attributes.EV_DAT_Event_Date_Meta.EV_DAT_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_DAT_Confidence
        FROM
            attributes.EV_DAT_Event_Date_Meta a
        WHERE
            a.EV_DAT_ID = p_id
        AND
            a.EV_DAT_Who = p_positor
        AND
            a.EV_DAT_PositedAt <= p_positing
        ORDER BY
            a.EV_DAT_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_DAT_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_DAT_Event_Date;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_DAT_Event_Date states a value of EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_DAT_Event_Date (
    p_owner IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_EV_ID%TYPE,
    p_value IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date%TYPE,
    p_positor IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_DAT_Event_Date_Meta.Metadata_EV_DAT%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.EV_DAT_Event_Date_Fact.EV_DAT_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_DAT_Event_Date_Meta (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_Who,
            EV_DAT_PositedAt,
            EV_DAT_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_DAT_Event_Date_Meta x
                WHERE
                    x.EV_DAT_ID = p_id
                AND
                    x.EV_DAT_Who = v_positor
                AND
                    x.EV_DAT_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            attributes.EV_DAT_Event_Date_Fact p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_DAT_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_DAT_Event_Date_Meta a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_Who = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_DAT_Event_Date_Fact p
        JOIN
            attributes.EV_DAT_Event_Date_Meta a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 0
        AND
            a.EV_DAT_Who = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_DAT_Event_Date_Meta a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_Who = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_DAT_Event_Date(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_DAT_Event_Date_Meta (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_Who,
            EV_DAT_PositedAt,
            EV_DAT_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            attributes.EV_DAT_Event_Date_Fact p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 0
        AND
            COALESCE(attributes.he_EV_DAT_Event_Date(p.EV_DAT_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_DAT_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_DAT_Event_Date_Fact (
            EV_DAT_EV_ID,
            EV_DAT_Event_Date
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_DAT_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_DAT_Event_Date_Meta (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_Who,
        EV_DAT_PositedAt,
        EV_DAT_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_DAT_Event_Date;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_AUD_Event_Audience tells whether two values of EV_AUD_Event_Audience are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_AUD_Event_Audience (
    p_left IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience%TYPE,
    p_right IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_AUD_Event_Audience;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_AUD_Event_Audience is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_AUD_Event_Audience (
    p_id IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_ID%TYPE,
    p_positor IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_Who%TYPE,
    p_positing IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_PositedAt%TYPE
) RETURN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_AUD_Confidence
        FROM
            attributes.EV_AUD_Event_Audience_Meta a
        WHERE
            a.EV_AUD_ID = p_id
        AND
            a.EV_AUD_Who = p_positor
        AND
            a.EV_AUD_PositedAt <= p_positing
        ORDER BY
            a.EV_AUD_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_AUD_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_AUD_Event_Audience;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Event_Audience states a value of EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_AUD_Event_Audience (
    p_owner IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_EV_ID%TYPE,
    p_value IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience%TYPE,
    p_positor IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_AUD_Event_Audience_Meta.Metadata_EV_AUD%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.EV_AUD_Event_Audience_Fact.EV_AUD_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_Who,
            EV_AUD_PositedAt,
            EV_AUD_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_AUD_Event_Audience_Meta x
                WHERE
                    x.EV_AUD_ID = p_id
                AND
                    x.EV_AUD_Who = v_positor
                AND
                    x.EV_AUD_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            attributes.EV_AUD_Event_Audience_Fact p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_AUD_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_AUD_Event_Audience_Meta a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_Who = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_AUD_Event_Audience_Fact p
        JOIN
            attributes.EV_AUD_Event_Audience_Meta a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 0
        AND
            a.EV_AUD_Who = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_AUD_Event_Audience_Meta a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_Who = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_AUD_Event_Audience(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_Who,
            EV_AUD_PositedAt,
            EV_AUD_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            attributes.EV_AUD_Event_Audience_Fact p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 0
        AND
            COALESCE(attributes.he_EV_AUD_Event_Audience(p.EV_AUD_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_AUD_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_AUD_Event_Audience_Fact (
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_AUD_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_Who,
        EV_AUD_PositedAt,
        EV_AUD_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_AUD_Event_Audience;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_REV_Event_Revenue tells whether two values of EV_REV_Event_Revenue are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_REV_Event_Revenue (
    p_left IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue%TYPE,
    p_right IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_REV_Event_Revenue;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_REV_Event_Revenue is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_REV_Event_Revenue (
    p_id IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_ID%TYPE,
    p_positor IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_Who%TYPE,
    p_positing IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_PositedAt%TYPE
) RETURN attributes.EV_REV_Event_Revenue_Meta.EV_REV_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_REV_Confidence
        FROM
            attributes.EV_REV_Event_Revenue_Meta a
        WHERE
            a.EV_REV_ID = p_id
        AND
            a.EV_REV_Who = p_positor
        AND
            a.EV_REV_PositedAt <= p_positing
        ORDER BY
            a.EV_REV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_REV_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_REV_Event_Revenue;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Event_Revenue states a value of EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_REV_Event_Revenue (
    p_owner IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_EV_ID%TYPE,
    p_value IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue%TYPE,
    p_positor IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_REV_Event_Revenue_Meta.Metadata_EV_REV%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.EV_REV_Event_Revenue_Fact.EV_REV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_Who,
            EV_REV_PositedAt,
            EV_REV_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_REV_Event_Revenue_Meta x
                WHERE
                    x.EV_REV_ID = p_id
                AND
                    x.EV_REV_Who = v_positor
                AND
                    x.EV_REV_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            attributes.EV_REV_Event_Revenue_Fact p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_REV_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_REV_Event_Revenue_Meta a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_Who = v_positor
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_REV_Event_Revenue_Fact p
        JOIN
            attributes.EV_REV_Event_Revenue_Meta a
        ON
            a.EV_REV_ID = p.EV_REV_ID
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 0
        AND
            a.EV_REV_Who = v_positor
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_REV_Event_Revenue_Meta a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_Who = v_positor
        AND
            a.EV_REV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_REV_Event_Revenue(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_Who,
            EV_REV_PositedAt,
            EV_REV_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            attributes.EV_REV_Event_Revenue_Fact p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 0
        AND
            COALESCE(attributes.he_EV_REV_Event_Revenue(p.EV_REV_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_REV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_REV_Event_Revenue_Fact (
            EV_REV_EV_ID,
            EV_REV_Event_Revenue
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_REV_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_Who,
        EV_REV_PositedAt,
        EV_REV_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_REV_Event_Revenue;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_STA_Event_Status tells whether two values of EV_STA_Event_Status are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_STA_Event_Status (
    p_left IN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status%TYPE,
    p_right IN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_STA_Event_Status;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_STA_Event_Status is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_STA_Event_Status (
    p_id IN attributes.EV_STA_Event_Status_Meta.EV_STA_ID%TYPE,
    p_positor IN attributes.EV_STA_Event_Status_Meta.EV_STA_Who%TYPE,
    p_positing IN attributes.EV_STA_Event_Status_Meta.EV_STA_PositedAt%TYPE
) RETURN attributes.EV_STA_Event_Status_Meta.EV_STA_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_STA_Confidence
        FROM
            attributes.EV_STA_Event_Status_Meta a
        WHERE
            a.EV_STA_ID = p_id
        AND
            a.EV_STA_Who = p_positor
        AND
            a.EV_STA_PositedAt <= p_positing
        ORDER BY
            a.EV_STA_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_STA_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_STA_Event_Status;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_STA_Event_Status states a value of EV_STA_Event_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_STA_Event_Status (
    p_owner IN attributes.EV_STA_Event_Status_Fact.EV_STA_EV_ID%TYPE,
    p_value IN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status%TYPE,
    p_changing IN attributes.EV_STA_Event_Status_Fact.EV_STA_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.EV_STA_Event_Status_Meta.EV_STA_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_STA_Event_Status_Meta.EV_STA_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_STA_Event_Status_Meta.EV_STA_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_STA_Event_Status_Meta.Metadata_EV_STA%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing timestamp;
    v_posit attributes.EV_STA_Event_Status_Fact.EV_STA_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_STA_Event_Status_Fact.EV_STA_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_STA_Event_Status_Meta (
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_Who,
            EV_STA_PositedAt,
            EV_STA_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_STA_Event_Status_Meta x
                WHERE
                    x.EV_STA_ID = p_id
                AND
                    x.EV_STA_Who = v_positor
                AND
                    x.EV_STA_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_STA_ID
        FROM
            attributes.EV_STA_Event_Status_Fact p
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Event_Status(p.EV_STA_Event_Status, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_STA_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Event_Status_Meta a
        WHERE
            a.EV_STA_ID = v_posit
        AND
            a.EV_STA_Who = v_positor
        AND
            a.EV_STA_PositedAt = v_positing
        AND
            a.EV_STA_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Event_Status for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Event_Status_Fact p
        JOIN
            attributes.EV_STA_Event_Status_Meta a
        ON
            a.EV_STA_ID = p.EV_STA_ID
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Event_Status(p.EV_STA_Event_Status, p_value) = 0
        AND
            a.EV_STA_Who = v_positor
        AND
            a.EV_STA_PositedAt = v_positing
        AND
            a.EV_STA_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Event_Status for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Event_Status_Meta a
        WHERE
            a.EV_STA_ID = v_posit
        AND
            a.EV_STA_Who = v_positor
        AND
            a.EV_STA_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_STA_Event_Status(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_STA_Event_Status_Meta (
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_Who,
            EV_STA_PositedAt,
            EV_STA_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_STA_ID
        FROM
            attributes.EV_STA_Event_Status_Fact p
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Event_Status(p.EV_STA_Event_Status, p_value) = 0
        AND
            COALESCE(attributes.he_EV_STA_Event_Status(p.EV_STA_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_STA_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_STA_Event_Status_Fact (
            EV_STA_EV_ID,
            EV_STA_ChangedAt,
            EV_STA_Event_Status
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING EV_STA_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_STA_Event_Status_Meta (
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_Who,
        EV_STA_PositedAt,
        EV_STA_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_STA_Event_Status;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_UTL_Event_Utilization tells whether two values of EV_UTL_Event_Utilization are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_UTL_Event_Utilization (
    p_left IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_UTL_ID%TYPE,
    p_right IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_UTL_Event_Utilization;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_UTL_Event_Utilization is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_UTL_Event_Utilization (
    p_id IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_ID%TYPE,
    p_positor IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_Who%TYPE,
    p_positing IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_PositedAt%TYPE
) RETURN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_UTL_Confidence
        FROM
            attributes.EV_UTL_Event_Utilization_Meta a
        WHERE
            a.EV_UTL_ID = p_id
        AND
            a.EV_UTL_Who = p_positor
        AND
            a.EV_UTL_PositedAt <= p_positing
        ORDER BY
            a.EV_UTL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_UTL_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_UTL_Event_Utilization;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_UTL_Event_Utilization states a value of EV_UTL_Event_Utilization
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_UTL_Event_Utilization (
    p_owner IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_EV_ID%TYPE,
    p_value IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_UTL_ID%TYPE,
    p_positor IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_UTL_Event_Utilization_Meta.Metadata_EV_UTL%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_Who,
            EV_UTL_PositedAt,
            EV_UTL_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_UTL_Event_Utilization_Meta x
                WHERE
                    x.EV_UTL_ID = p_id
                AND
                    x.EV_UTL_Who = v_positor
                AND
                    x.EV_UTL_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_UTL_ID
        FROM
            attributes.EV_UTL_Event_Utilization_Fact p
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Event_Utilization(p.EV_UTL_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_UTL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Event_Utilization_Meta a
        WHERE
            a.EV_UTL_ID = v_posit
        AND
            a.EV_UTL_Who = v_positor
        AND
            a.EV_UTL_PositedAt = v_positing
        AND
            a.EV_UTL_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Event_Utilization for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Event_Utilization_Fact p
        JOIN
            attributes.EV_UTL_Event_Utilization_Meta a
        ON
            a.EV_UTL_ID = p.EV_UTL_ID
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Event_Utilization(p.EV_UTL_UTL_ID, p_value) = 0
        AND
            a.EV_UTL_Who = v_positor
        AND
            a.EV_UTL_PositedAt = v_positing
        AND
            a.EV_UTL_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Event_Utilization for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Event_Utilization_Meta a
        WHERE
            a.EV_UTL_ID = v_posit
        AND
            a.EV_UTL_Who = v_positor
        AND
            a.EV_UTL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_UTL_Event_Utilization(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_Who,
            EV_UTL_PositedAt,
            EV_UTL_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_UTL_ID
        FROM
            attributes.EV_UTL_Event_Utilization_Fact p
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Event_Utilization(p.EV_UTL_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_EV_UTL_Event_Utilization(p.EV_UTL_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_UTL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_UTL_Event_Utilization_Fact (
            EV_UTL_EV_ID,
            EV_UTL_UTL_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_UTL_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_Who,
        EV_UTL_PositedAt,
        EV_UTL_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_UTL_Event_Utilization;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_LVL_Event_Level tells whether two values of EV_LVL_Event_Level are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_LVL_Event_Level (
    p_left IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID%TYPE,
    p_right IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_LVL_Event_Level;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_LVL_Event_Level is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_LVL_Event_Level (
    p_id IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_ID%TYPE,
    p_positor IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_Who%TYPE,
    p_positing IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_PositedAt%TYPE
) RETURN attributes.EV_LVL_Event_Level_Meta.EV_LVL_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_LVL_Confidence
        FROM
            attributes.EV_LVL_Event_Level_Meta a
        WHERE
            a.EV_LVL_ID = p_id
        AND
            a.EV_LVL_Who = p_positor
        AND
            a.EV_LVL_PositedAt <= p_positing
        ORDER BY
            a.EV_LVL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_LVL_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_LVL_Event_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_LVL_Event_Level states a value of EV_LVL_Event_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_LVL_Event_Level (
    p_owner IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_EV_ID%TYPE,
    p_value IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID%TYPE,
    p_changing IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_LVL_Event_Level_Meta.Metadata_EV_LVL%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing date;
    v_posit attributes.EV_LVL_Event_Level_Fact.EV_LVL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_LVL_Event_Level_Meta (
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_Who,
            EV_LVL_PositedAt,
            EV_LVL_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_LVL_Event_Level_Meta x
                WHERE
                    x.EV_LVL_ID = p_id
                AND
                    x.EV_LVL_Who = v_positor
                AND
                    x.EV_LVL_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_LVL_ID
        FROM
            attributes.EV_LVL_Event_Level_Fact p
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Event_Level(p.EV_LVL_PLV_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_LVL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Event_Level_Meta a
        WHERE
            a.EV_LVL_ID = v_posit
        AND
            a.EV_LVL_Who = v_positor
        AND
            a.EV_LVL_PositedAt = v_positing
        AND
            a.EV_LVL_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Event_Level for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Event_Level_Fact p
        JOIN
            attributes.EV_LVL_Event_Level_Meta a
        ON
            a.EV_LVL_ID = p.EV_LVL_ID
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Event_Level(p.EV_LVL_PLV_ID, p_value) = 0
        AND
            a.EV_LVL_Who = v_positor
        AND
            a.EV_LVL_PositedAt = v_positing
        AND
            a.EV_LVL_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Event_Level for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Event_Level_Meta a
        WHERE
            a.EV_LVL_ID = v_posit
        AND
            a.EV_LVL_Who = v_positor
        AND
            a.EV_LVL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_LVL_Event_Level(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_LVL_Event_Level_Meta (
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_Who,
            EV_LVL_PositedAt,
            EV_LVL_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_LVL_ID
        FROM
            attributes.EV_LVL_Event_Level_Fact p
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Event_Level(p.EV_LVL_PLV_ID, p_value) = 0
        AND
            COALESCE(attributes.he_EV_LVL_Event_Level(p.EV_LVL_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_LVL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_LVL_Event_Level_Fact (
            EV_LVL_EV_ID,
            EV_LVL_ChangedAt,
            EV_LVL_PLV_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING EV_LVL_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_LVL_Event_Level_Meta (
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_Who,
        EV_LVL_PositedAt,
        EV_LVL_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_LVL_Event_Level;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_NAM_Stage_Name tells whether two values of ST_NAM_Stage_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_NAM_Stage_Name (
    p_left IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name%TYPE,
    p_right IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_NAM_Stage_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_NAM_Stage_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_NAM_Stage_Name (
    p_id IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_ID%TYPE,
    p_positor IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_Who%TYPE,
    p_positing IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_PositedAt%TYPE
) RETURN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_NAM_Confidence
        FROM
            attributes.ST_NAM_Stage_Name_Meta a
        WHERE
            a.ST_NAM_ID = p_id
        AND
            a.ST_NAM_Who = p_positor
        AND
            a.ST_NAM_PositedAt <= p_positing
        ORDER BY
            a.ST_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_NAM_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_NAM_Stage_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Stage_Name states a value of ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_NAM_Stage_Name (
    p_owner IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ST_ID%TYPE,
    p_value IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name%TYPE,
    p_changing IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_NAM_Stage_Name_Meta.Metadata_ST_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing timestamp;
    v_posit attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_Who,
            ST_NAM_PositedAt,
            ST_NAM_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_NAM_Stage_Name_Meta x
                WHERE
                    x.ST_NAM_ID = p_id
                AND
                    x.ST_NAM_Who = v_positor
                AND
                    x.ST_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_NAM_ID
        FROM
            attributes.ST_NAM_Stage_Name_Fact p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_NAM_Stage_Name_Meta a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_Who = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_NAM_Stage_Name_Fact p
        JOIN
            attributes.ST_NAM_Stage_Name_Meta a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 0
        AND
            a.ST_NAM_Who = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_NAM_Stage_Name_Meta a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_Who = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_NAM_Stage_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_Who,
            ST_NAM_PositedAt,
            ST_NAM_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_NAM_ID
        FROM
            attributes.ST_NAM_Stage_Name_Fact p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 0
        AND
            COALESCE(attributes.he_ST_NAM_Stage_Name(p.ST_NAM_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.ST_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_NAM_Stage_Name_Fact (
            ST_NAM_ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING ST_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_Who,
        ST_NAM_PositedAt,
        ST_NAM_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_NAM_Stage_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_LOC_Stage_Location tells whether two values of ST_LOC_Stage_Location are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_LOC_Stage_Location (
    p_left IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location%TYPE,
    p_right IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location%TYPE
) RETURN NUMBER
IS
    v_same NUMBER;
BEGIN
    SELECT CASE WHEN STANDARD_HASH(p_left, 'MD5') = STANDARD_HASH(p_right, 'MD5') THEN 1 ELSE 0 END INTO v_same FROM dual;
    RETURN v_same;
END eq_ST_LOC_Stage_Location;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_LOC_Stage_Location is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_LOC_Stage_Location (
    p_id IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_ID%TYPE,
    p_positor IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_Who%TYPE,
    p_positing IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_PositedAt%TYPE
) RETURN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_LOC_Confidence
        FROM
            attributes.ST_LOC_Stage_Location_Meta a
        WHERE
            a.ST_LOC_ID = p_id
        AND
            a.ST_LOC_Who = p_positor
        AND
            a.ST_LOC_PositedAt <= p_positing
        ORDER BY
            a.ST_LOC_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_LOC_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_LOC_Stage_Location;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Stage_Location states a value of ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_LOC_Stage_Location (
    p_owner IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_ST_ID%TYPE,
    p_value IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location%TYPE,
    p_positor IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_LOC_Stage_Location_Meta.Metadata_ST_LOC%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.ST_LOC_Stage_Location_Fact.ST_LOC_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_Who,
            ST_LOC_PositedAt,
            ST_LOC_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_LOC_Stage_Location_Meta x
                WHERE
                    x.ST_LOC_ID = p_id
                AND
                    x.ST_LOC_Who = v_positor
                AND
                    x.ST_LOC_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            attributes.ST_LOC_Stage_Location_Fact p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_LOC_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_LOC_Stage_Location_Meta a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_Who = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_LOC_Stage_Location_Fact p
        JOIN
            attributes.ST_LOC_Stage_Location_Meta a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 0
        AND
            a.ST_LOC_Who = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_LOC_Stage_Location_Meta a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_Who = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_LOC_Stage_Location(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_Who,
            ST_LOC_PositedAt,
            ST_LOC_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            attributes.ST_LOC_Stage_Location_Fact p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 0
        AND
            COALESCE(attributes.he_ST_LOC_Stage_Location(p.ST_LOC_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.ST_LOC_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_LOC_Stage_Location_Fact (
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_LOC_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_Who,
        ST_LOC_PositedAt,
        ST_LOC_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_LOC_Stage_Location;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_AVG_Stage_Average tells whether two values of ST_AVG_Stage_Average are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_AVG_Stage_Average (
    p_left IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID%TYPE,
    p_right IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_AVG_Stage_Average;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_AVG_Stage_Average is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_AVG_Stage_Average (
    p_id IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_ID%TYPE,
    p_positor IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_Who%TYPE,
    p_positing IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_PositedAt%TYPE
) RETURN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_AVG_Confidence
        FROM
            attributes.ST_AVG_Stage_Average_Meta a
        WHERE
            a.ST_AVG_ID = p_id
        AND
            a.ST_AVG_Who = p_positor
        AND
            a.ST_AVG_PositedAt <= p_positing
        ORDER BY
            a.ST_AVG_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_AVG_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_AVG_Stage_Average;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Stage_Average states a value of ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_AVG_Stage_Average (
    p_owner IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ST_ID%TYPE,
    p_value IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID%TYPE,
    p_changing IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_AVG_Stage_Average_Meta.Metadata_ST_AVG%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing timestamp;
    v_posit attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Who,
            ST_AVG_PositedAt,
            ST_AVG_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_AVG_Stage_Average_Meta x
                WHERE
                    x.ST_AVG_ID = p_id
                AND
                    x.ST_AVG_Who = v_positor
                AND
                    x.ST_AVG_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_AVG_ID
        FROM
            attributes.ST_AVG_Stage_Average_Fact p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_AVG_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_AVG_Stage_Average_Meta a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_Who = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_AVG_Stage_Average_Fact p
        JOIN
            attributes.ST_AVG_Stage_Average_Meta a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            a.ST_AVG_Who = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_AVG_Stage_Average_Meta a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_Who = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_AVG_Stage_Average(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Who,
            ST_AVG_PositedAt,
            ST_AVG_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_AVG_ID
        FROM
            attributes.ST_AVG_Stage_Average_Fact p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.ST_AVG_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Stage_Average_Fact p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_ST_AVG_Stage_Average(r.ST_AVG_UTL_ID, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.ST_AVG_ID,
            f.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Stage_Average_Fact f
        WHERE
            f.ST_AVG_ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_ST_AVG_Stage_Average(f.ST_AVG_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_ST_AVG_Stage_Average(f.ST_AVG_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_ST_AVG_Stage_Average(r.ST_AVG_UTL_ID, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.ST_AVG_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_AVG_Stage_Average_Fact (
            ST_AVG_ST_ID,
            ST_AVG_ChangedAt,
            ST_AVG_UTL_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING ST_AVG_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_Who,
        ST_AVG_PositedAt,
        ST_AVG_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_AVG_Stage_Average;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_MIN_Stage_Minimum tells whether two values of ST_MIN_Stage_Minimum are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_MIN_Stage_Minimum (
    p_left IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID%TYPE,
    p_right IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_MIN_Stage_Minimum;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_MIN_Stage_Minimum is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_MIN_Stage_Minimum (
    p_id IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_ID%TYPE,
    p_positor IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_Who%TYPE,
    p_positing IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_PositedAt%TYPE
) RETURN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_MIN_Confidence
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta a
        WHERE
            a.ST_MIN_ID = p_id
        AND
            a.ST_MIN_Who = p_positor
        AND
            a.ST_MIN_PositedAt <= p_positing
        ORDER BY
            a.ST_MIN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_MIN_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_MIN_Stage_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Stage_Minimum states a value of ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_MIN_Stage_Minimum (
    p_owner IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_ST_ID%TYPE,
    p_value IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID%TYPE,
    p_positor IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_MIN_Stage_Minimum_Meta.Metadata_ST_MIN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_Who,
            ST_MIN_PositedAt,
            ST_MIN_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_MIN_Stage_Minimum_Meta x
                WHERE
                    x.ST_MIN_ID = p_id
                AND
                    x.ST_MIN_Who = v_positor
                AND
                    x.ST_MIN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            attributes.ST_MIN_Stage_Minimum_Fact p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_MIN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_Who = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_MIN_Stage_Minimum_Fact p
        JOIN
            attributes.ST_MIN_Stage_Minimum_Meta a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            a.ST_MIN_Who = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_Who = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_MIN_Stage_Minimum(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_Who,
            ST_MIN_PositedAt,
            ST_MIN_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            attributes.ST_MIN_Stage_Minimum_Fact p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_ST_MIN_Stage_Minimum(p.ST_MIN_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.ST_MIN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_MIN_Stage_Minimum_Fact (
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_MIN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_Who,
        ST_MIN_PositedAt,
        ST_MIN_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_MIN_Stage_Minimum;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_NAM_Actor_Name tells whether two values of AC_NAM_Actor_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_AC_NAM_Actor_Name (
    p_left IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name%TYPE,
    p_right IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_NAM_Actor_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_NAM_Actor_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_AC_NAM_Actor_Name (
    p_id IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_ID%TYPE,
    p_positor IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_Who%TYPE,
    p_positing IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_PositedAt%TYPE
) RETURN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_NAM_Confidence
        FROM
            attributes.AC_NAM_Actor_Name_Meta a
        WHERE
            a.AC_NAM_ID = p_id
        AND
            a.AC_NAM_Who = p_positor
        AND
            a.AC_NAM_PositedAt <= p_positing
        ORDER BY
            a.AC_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_NAM_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_NAM_Actor_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Actor_Name states a value of AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_NAM_Actor_Name (
    p_owner IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_AC_ID%TYPE,
    p_value IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name%TYPE,
    p_changing IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_NAM_Actor_Name_Meta.Metadata_AC_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing timestamp;
    v_posit attributes.AC_NAM_Actor_Name_Fact.AC_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_Who,
            AC_NAM_PositedAt,
            AC_NAM_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_NAM_Actor_Name_Meta x
                WHERE
                    x.AC_NAM_ID = p_id
                AND
                    x.AC_NAM_Who = v_positor
                AND
                    x.AC_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_NAM_ID
        FROM
            attributes.AC_NAM_Actor_Name_Fact p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_NAM_Actor_Name_Meta a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_Who = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_NAM_Actor_Name_Fact p
        JOIN
            attributes.AC_NAM_Actor_Name_Meta a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 0
        AND
            a.AC_NAM_Who = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_NAM_Actor_Name_Meta a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_Who = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_AC_NAM_Actor_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_Who,
            AC_NAM_PositedAt,
            AC_NAM_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_NAM_ID
        FROM
            attributes.AC_NAM_Actor_Name_Fact p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 0
        AND
            COALESCE(attributes.he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.AC_NAM_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.AC_NAM_Actor_Name
        FROM
            attributes.AC_NAM_Actor_Name_Fact p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.AC_NAM_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_AC_NAM_Actor_Name(r.AC_NAM_Actor_Name, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.AC_NAM_ID,
            f.AC_NAM_Actor_Name
        FROM
            attributes.AC_NAM_Actor_Name_Fact f
        WHERE
            f.AC_NAM_AC_ID = p_owner
        AND
            f.AC_NAM_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_AC_NAM_Actor_Name(f.AC_NAM_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_AC_NAM_Actor_Name(f.AC_NAM_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.AC_NAM_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_AC_NAM_Actor_Name(r.AC_NAM_Actor_Name, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_NAM_Actor_Name_Fact (
            AC_NAM_AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING AC_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_Who,
        AC_NAM_PositedAt,
        AC_NAM_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_NAM_Actor_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_GEN_Actor_Gender tells whether two values of AC_GEN_Actor_Gender are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_AC_GEN_Actor_Gender (
    p_left IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID%TYPE,
    p_right IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_GEN_Actor_Gender;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_GEN_Actor_Gender is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_AC_GEN_Actor_Gender (
    p_id IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_ID%TYPE,
    p_positor IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_Who%TYPE,
    p_positing IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_PositedAt%TYPE
) RETURN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_GEN_Confidence
        FROM
            attributes.AC_GEN_Actor_Gender_Meta a
        WHERE
            a.AC_GEN_ID = p_id
        AND
            a.AC_GEN_Who = p_positor
        AND
            a.AC_GEN_PositedAt <= p_positing
        ORDER BY
            a.AC_GEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_GEN_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_GEN_Actor_Gender;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Actor_Gender states a value of AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_GEN_Actor_Gender (
    p_owner IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_AC_ID%TYPE,
    p_value IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID%TYPE,
    p_positor IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_GEN_Actor_Gender_Meta.Metadata_AC_GEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_Who,
            AC_GEN_PositedAt,
            AC_GEN_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_GEN_Actor_Gender_Meta x
                WHERE
                    x.AC_GEN_ID = p_id
                AND
                    x.AC_GEN_Who = v_positor
                AND
                    x.AC_GEN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            attributes.AC_GEN_Actor_Gender_Fact p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_GEN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_GEN_Actor_Gender_Meta a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_Who = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_GEN_Actor_Gender_Fact p
        JOIN
            attributes.AC_GEN_Actor_Gender_Meta a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            a.AC_GEN_Who = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_GEN_Actor_Gender_Meta a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_Who = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_AC_GEN_Actor_Gender(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_Who,
            AC_GEN_PositedAt,
            AC_GEN_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            attributes.AC_GEN_Actor_Gender_Fact p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            COALESCE(attributes.he_AC_GEN_Actor_Gender(p.AC_GEN_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.AC_GEN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_GEN_Actor_Gender_Fact (
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING AC_GEN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_Who,
        AC_GEN_PositedAt,
        AC_GEN_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_GEN_Actor_Gender;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_PLV_Actor_ProfessionalLevel tells whether two values of AC_PLV_Actor_ProfessionalLevel are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_AC_PLV_Actor_ProfessionalLevel (
    p_left IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID%TYPE,
    p_right IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_PLV_Actor_ProfessionalLevel;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_PLV_Actor_ProfessionalLevel is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_AC_PLV_Actor_ProfessionalLevel (
    p_id IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_ID%TYPE,
    p_positor IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_Who%TYPE,
    p_positing IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_PositedAt%TYPE
) RETURN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_PLV_Confidence
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        WHERE
            a.AC_PLV_ID = p_id
        AND
            a.AC_PLV_Who = p_positor
        AND
            a.AC_PLV_PositedAt <= p_positing
        ORDER BY
            a.AC_PLV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_PLV_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_PLV_Actor_ProfessionalLevel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Actor_ProfessionalLevel states a value of AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_PLV_Actor_ProfessionalLevel (
    p_owner IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_AC_ID%TYPE,
    p_value IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID%TYPE,
    p_changing IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.Metadata_AC_PLV%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing timestamp;
    v_posit attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_Who,
            AC_PLV_PositedAt,
            AC_PLV_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_PLV_Actor_ProfessionalLevel_Meta x
                WHERE
                    x.AC_PLV_ID = p_id
                AND
                    x.AC_PLV_Who = v_positor
                AND
                    x.AC_PLV_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_PLV_ID
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_PLV_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_Who = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
        JOIN
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            a.AC_PLV_Who = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_Who = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_AC_PLV_Actor_ProfessionalLevel(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_Who,
            AC_PLV_PositedAt,
            AC_PLV_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_PLV_ID
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            COALESCE(attributes.he_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.AC_PLV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Fact (
            AC_PLV_AC_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PLV_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING AC_PLV_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_Who,
        AC_PLV_PositedAt,
        AC_PLV_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_PLV_Actor_ProfessionalLevel;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_NAM_Program_Name tells whether two values of PR_NAM_Program_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_PR_NAM_Program_Name (
    p_left IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name%TYPE,
    p_right IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_PR_NAM_Program_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_NAM_Program_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_PR_NAM_Program_Name (
    p_id IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_ID%TYPE,
    p_positor IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_Who%TYPE,
    p_positing IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_PositedAt%TYPE
) RETURN attributes.PR_NAM_Program_Name_Meta.PR_NAM_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_NAM_Confidence
        FROM
            attributes.PR_NAM_Program_Name_Meta a
        WHERE
            a.PR_NAM_ID = p_id
        AND
            a.PR_NAM_Who = p_positor
        AND
            a.PR_NAM_PositedAt <= p_positing
        ORDER BY
            a.PR_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_NAM_Confidence;
    END LOOP;
    RETURN NULL;
END he_PR_NAM_Program_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Program_Name states a value of PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_NAM_Program_Name (
    p_owner IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_PR_ID%TYPE,
    p_value IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name%TYPE,
    p_positor IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.PR_NAM_Program_Name_Meta.Metadata_PR_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.PR_NAM_Program_Name_Fact.PR_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.PR_NAM_Program_Name_Meta (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_Who,
            PR_NAM_PositedAt,
            PR_NAM_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.PR_NAM_Program_Name_Meta x
                WHERE
                    x.PR_NAM_ID = p_id
                AND
                    x.PR_NAM_Who = v_positor
                AND
                    x.PR_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            attributes.PR_NAM_Program_Name_Fact p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_NAM_Program_Name_Meta a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_Who = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_NAM_Program_Name_Fact p
        JOIN
            attributes.PR_NAM_Program_Name_Meta a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 0
        AND
            a.PR_NAM_Who = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_NAM_Program_Name_Meta a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_Who = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_PR_NAM_Program_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.PR_NAM_Program_Name_Meta (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_Who,
            PR_NAM_PositedAt,
            PR_NAM_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            attributes.PR_NAM_Program_Name_Fact p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 0
        AND
            COALESCE(attributes.he_PR_NAM_Program_Name(p.PR_NAM_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.PR_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.PR_NAM_Program_Name_Fact (
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING PR_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.PR_NAM_Program_Name_Meta (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_Who,
        PR_NAM_PositedAt,
        PR_NAM_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_PR_NAM_Program_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_LEN_Program_Length tells whether two values of PR_LEN_Program_Length are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_PR_LEN_Program_Length (
    p_left IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length%TYPE,
    p_right IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_PR_LEN_Program_Length;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_LEN_Program_Length is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_PR_LEN_Program_Length (
    p_id IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_ID%TYPE,
    p_positor IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_Who%TYPE,
    p_positing IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_PositedAt%TYPE
) RETURN attributes.PR_LEN_Program_Length_Meta.PR_LEN_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_LEN_Confidence
        FROM
            attributes.PR_LEN_Program_Length_Meta a
        WHERE
            a.PR_LEN_ID = p_id
        AND
            a.PR_LEN_Who = p_positor
        AND
            a.PR_LEN_PositedAt <= p_positing
        ORDER BY
            a.PR_LEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_LEN_Confidence;
    END LOOP;
    RETURN NULL;
END he_PR_LEN_Program_Length;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Program_Length states a value of PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_LEN_Program_Length (
    p_owner IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_PR_ID%TYPE,
    p_value IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length%TYPE,
    p_changing IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.PR_LEN_Program_Length_Meta.Metadata_PR_LEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing date;
    v_posit attributes.PR_LEN_Program_Length_Fact.PR_LEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.PR_LEN_Program_Length_Meta (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Who,
            PR_LEN_PositedAt,
            PR_LEN_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.PR_LEN_Program_Length_Meta x
                WHERE
                    x.PR_LEN_ID = p_id
                AND
                    x.PR_LEN_Who = v_positor
                AND
                    x.PR_LEN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.PR_LEN_ID
        FROM
            attributes.PR_LEN_Program_Length_Fact p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_LEN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_LEN_Program_Length_Meta a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_Who = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_LEN_Program_Length_Fact p
        JOIN
            attributes.PR_LEN_Program_Length_Meta a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 0
        AND
            a.PR_LEN_Who = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_LEN_Program_Length_Meta a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_Who = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_PR_LEN_Program_Length(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.PR_LEN_Program_Length_Meta (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Who,
            PR_LEN_PositedAt,
            PR_LEN_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.PR_LEN_ID
        FROM
            attributes.PR_LEN_Program_Length_Fact p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 0
        AND
            COALESCE(attributes.he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.PR_LEN_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.PR_LEN_Program_Length
        FROM
            attributes.PR_LEN_Program_Length_Fact p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.PR_LEN_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_PR_LEN_Program_Length(r.PR_LEN_Program_Length, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.PR_LEN_ID,
            f.PR_LEN_Program_Length
        FROM
            attributes.PR_LEN_Program_Length_Fact f
        WHERE
            f.PR_LEN_PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_PR_LEN_Program_Length(f.PR_LEN_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_PR_LEN_Program_Length(f.PR_LEN_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_PR_LEN_Program_Length(r.PR_LEN_Program_Length, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.PR_LEN_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.PR_LEN_Program_Length_Fact (
            PR_LEN_PR_ID,
            PR_LEN_ChangedAt,
            PR_LEN_Program_Length
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING PR_LEN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.PR_LEN_Program_Length_Meta (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_Who,
        PR_LEN_PositedAt,
        PR_LEN_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_PR_LEN_Program_Length;
/
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the posit and annex tables of the attributes in a consistent way,
-- through the insert procedures of the attributes (ip_<attribute>, see the attribute triggers, which keep the posit and
-- annex tables). Default values are used for some columns if not provided by the corresponding SQL statements: the positor
-- is 0, the changing and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the insert procedures of the attributes see to that).
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lST_Stage
INSTEAD OF INSERT ON anchors.lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    v_id := :NEW.ST_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.ST_Stage (
            Metadata_ST
        )
        VALUES (
            :NEW.Metadata_ST
        )
        RETURNING ST_ID INTO v_id;
    END IF;
    IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
        attributes.ip_ST_NAM_Stage_Name(
            p_owner => COALESCE(:NEW.ST_NAM_ST_ID, v_id),
            p_value => :NEW.ST_NAM_Stage_Name,
            p_changing => COALESCE(:NEW.ST_NAM_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.ST_NAM_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.ST_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_NAM_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_NAM, :NEW.Metadata_ST)
        );
    END IF;
    IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
        attributes.ip_ST_LOC_Stage_Location(
            p_owner => COALESCE(:NEW.ST_LOC_ST_ID, v_id),
            p_value => :NEW.ST_LOC_Stage_Location,
            p_positor => COALESCE(:NEW.ST_LOC_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.ST_LOC_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_LOC_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_LOC, :NEW.Metadata_ST)
        );
    END IF;
    v_AVG := :NEW.ST_AVG_UTL_ID;
    IF v_AVG IS NULL AND :NEW.ST_AVG_UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.ST_AVG_UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_AVG := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_AVG IS NOT NULL THEN
        attributes.ip_ST_AVG_Stage_Average(
            p_owner => COALESCE(:NEW.ST_AVG_ST_ID, v_id),
            p_value => v_AVG,
            p_changing => COALESCE(:NEW.ST_AVG_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.ST_AVG_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.ST_AVG_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_AVG_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_AVG, :NEW.Metadata_ST)
        );
    END IF;
    v_MIN := :NEW.ST_MIN_UTL_ID;
    IF v_MIN IS NULL AND :NEW.ST_MIN_UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.ST_MIN_UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_MIN := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_MIN IS NOT NULL THEN
        attributes.ip_ST_MIN_Stage_Minimum(
            p_owner => COALESCE(:NEW.ST_MIN_ST_ID, v_id),
            p_value => v_MIN,
            p_positor => COALESCE(:NEW.ST_MIN_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.ST_MIN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_MIN_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_MIN, :NEW.Metadata_ST)
        );
    END IF;
END it_lST_Stage;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lST_Stage
INSTEAD OF UPDATE ON anchors.lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(19);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_NAM_changing timestamp;
    v_AVG number(3);
    v_AVG_changing timestamp;
    v_MIN number(3);
BEGIN
    IF (:NEW.ST_ID <> :OLD.ST_ID
        OR (:NEW.ST_ID IS NULL AND :OLD.ST_ID IS NOT NULL)
        OR (:NEW.ST_ID IS NOT NULL AND :OLD.ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Confidence <> :OLD.Confidence
        OR (:NEW.Confidence IS NULL AND :OLD.Confidence IS NOT NULL)
        OR (:NEW.Confidence IS NOT NULL AND :OLD.Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
        OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
        OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL)) THEN TRUE ELSE FALSE END;
    -- ST_NAM_Stage_Name
    IF (:NEW.ST_NAM_ID <> :OLD.ST_NAM_ID
        OR (:NEW.ST_NAM_ID IS NULL AND :OLD.ST_NAM_ID IS NOT NULL)
        OR (:NEW.ST_NAM_ID IS NOT NULL AND :OLD.ST_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.ST_NAM_ST_ID <> :OLD.ST_NAM_ST_ID
        OR (:NEW.ST_NAM_ST_ID IS NULL AND :OLD.ST_NAM_ST_ID IS NOT NULL)
        OR (:NEW.ST_NAM_ST_ID IS NOT NULL AND :OLD.ST_NAM_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_NAM_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_NAM_Stage_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_NAM_Confidence <> :OLD.ST_NAM_Confidence
        OR (:NEW.ST_NAM_Confidence IS NULL AND :OLD.ST_NAM_Confidence IS NOT NULL)
        OR (:NEW.ST_NAM_Confidence IS NOT NULL AND :OLD.ST_NAM_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_NAM_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.ST_NAM_Confidence;
    END IF;
    IF (:NEW.ST_NAM_Who <> :OLD.ST_NAM_Who
        OR (:NEW.ST_NAM_Who IS NULL AND :OLD.ST_NAM_Who IS NOT NULL)
        OR (:NEW.ST_NAM_Who IS NOT NULL AND :OLD.ST_NAM_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_NAM_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_NAM_PositedAt <> :OLD.ST_NAM_PositedAt
        OR (:NEW.ST_NAM_PositedAt IS NULL AND :OLD.ST_NAM_PositedAt IS NOT NULL)
        OR (:NEW.ST_NAM_PositedAt IS NOT NULL AND :OLD.ST_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_NAM_PositedAt;
    ELSIF v_changing_diff AND :NEW.ST_NAM_Stage_Name IS NULL THEN
        v_positing := :NEW.ST_NAM_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_NAM_Stage_Name <> :OLD.ST_NAM_Stage_Name
        OR (:NEW.ST_NAM_Stage_Name IS NULL AND :OLD.ST_NAM_Stage_Name IS NOT NULL)
        OR (:NEW.ST_NAM_Stage_Name IS NOT NULL AND :OLD.ST_NAM_Stage_Name IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_NAM <> :OLD.Metadata_ST_NAM
        OR (:NEW.Metadata_ST_NAM IS NULL AND :OLD.Metadata_ST_NAM IS NOT NULL)
        OR (:NEW.Metadata_ST_NAM IS NOT NULL AND :OLD.Metadata_ST_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_NAM
        END, :NEW.Metadata_ST);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_NAM_changing := :NEW.ST_NAM_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_NAM_changing := :NEW.ST_NAM_ChangedAt;
        ELSE
            v_NAM_changing := v_now;
        END IF;
        IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_NAM_Stage_Name IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.ST_NAM_Confidence IS NULL
            OR :OLD.ST_NAM_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.ST_NAM_Who IS NULL
            OR :OLD.ST_NAM_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_ST_NAM_Stage_Name(
                    p_owner => COALESCE(:NEW.ST_NAM_ST_ID, :NEW.ST_ID),
                    p_value => :NEW.ST_NAM_Stage_Name,
                    p_changing => v_NAM_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.ST_NAM_Stage_Name IS NULL AND :OLD.ST_NAM_Stage_Name IS NOT NULL THEN
            attributes.ip_ST_NAM_Stage_Name(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_NAM_Stage_Name,
                p_changing => :OLD.ST_NAM_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- ST_LOC_Stage_Location
    IF (:NEW.ST_LOC_ID <> :OLD.ST_LOC_ID
        OR (:NEW.ST_LOC_ID IS NULL AND :OLD.ST_LOC_ID IS NOT NULL)
        OR (:NEW.ST_LOC_ID IS NOT NULL AND :OLD.ST_LOC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_LOC_ID is not updatable.');
    END IF;
    IF (:NEW.ST_LOC_ST_ID <> :OLD.ST_LOC_ST_ID
        OR (:NEW.ST_LOC_ST_ID IS NULL AND :OLD.ST_LOC_ST_ID IS NOT NULL)
        OR (:NEW.ST_LOC_ST_ID IS NOT NULL AND :OLD.ST_LOC_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_LOC_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_LOC_Stage_Location, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_LOC_Confidence <> :OLD.ST_LOC_Confidence
        OR (:NEW.ST_LOC_Confidence IS NULL AND :OLD.ST_LOC_Confidence IS NOT NULL)
        OR (:NEW.ST_LOC_Confidence IS NOT NULL AND :OLD.ST_LOC_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_LOC_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.ST_LOC_Confidence;
    END IF;
    IF (:NEW.ST_LOC_Who <> :OLD.ST_LOC_Who
        OR (:NEW.ST_LOC_Who IS NULL AND :OLD.ST_LOC_Who IS NOT NULL)
        OR (:NEW.ST_LOC_Who IS NOT NULL AND :OLD.ST_LOC_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_LOC_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_LOC_PositedAt <> :OLD.ST_LOC_PositedAt
        OR (:NEW.ST_LOC_PositedAt IS NULL AND :OLD.ST_LOC_PositedAt IS NOT NULL)
        OR (:NEW.ST_LOC_PositedAt IS NOT NULL AND :OLD.ST_LOC_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_LOC_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_LOC_Stage_Location <> :OLD.ST_LOC_Stage_Location
        OR (:NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL)
        OR (:NEW.ST_LOC_Stage_Location IS NOT NULL AND :OLD.ST_LOC_Stage_Location IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_LOC <> :OLD.Metadata_ST_LOC
        OR (:NEW.Metadata_ST_LOC IS NULL AND :OLD.Metadata_ST_LOC IS NOT NULL)
        OR (:NEW.Metadata_ST_LOC IS NOT NULL AND :OLD.Metadata_ST_LOC IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_LOC
        END, :NEW.Metadata_ST);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_LOC_Stage_Location IS NULL
            OR v_positing_diff
            OR :OLD.ST_LOC_Confidence IS NULL
            OR :OLD.ST_LOC_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.ST_LOC_Who IS NULL
            OR :OLD.ST_LOC_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_ST_LOC_Stage_Location(
                    p_owner => COALESCE(:NEW.ST_LOC_ST_ID, :NEW.ST_ID),
                    p_value => :NEW.ST_LOC_Stage_Location,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL THEN
            attributes.ip_ST_LOC_Stage_Location(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_LOC_Stage_Location,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- ST_AVG_Stage_Average
    IF (:NEW.ST_AVG_ID <> :OLD.ST_AVG_ID
        OR (:NEW.ST_AVG_ID IS NULL AND :OLD.ST_AVG_ID IS NOT NULL)
        OR (:NEW.ST_AVG_ID IS NOT NULL AND :OLD.ST_AVG_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_AVG_ID is not updatable.');
    END IF;
    IF (:NEW.ST_AVG_ST_ID <> :OLD.ST_AVG_ST_ID
        OR (:NEW.ST_AVG_ST_ID IS NULL AND :OLD.ST_AVG_ST_ID IS NOT NULL)
        OR (:NEW.ST_AVG_ST_ID IS NOT NULL AND :OLD.ST_AVG_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_AVG_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_AVG_Stage_Average, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_AVG_Confidence <> :OLD.ST_AVG_Confidence
        OR (:NEW.ST_AVG_Confidence IS NULL AND :OLD.ST_AVG_Confidence IS NOT NULL)
        OR (:NEW.ST_AVG_Confidence IS NOT NULL AND :OLD.ST_AVG_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_AVG_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.ST_AVG_Confidence;
    END IF;
    IF (:NEW.ST_AVG_Who <> :OLD.ST_AVG_Who
        OR (:NEW.ST_AVG_Who IS NULL AND :OLD.ST_AVG_Who IS NOT NULL)
        OR (:NEW.ST_AVG_Who IS NOT NULL AND :OLD.ST_AVG_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_AVG_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_AVG_PositedAt <> :OLD.ST_AVG_PositedAt
        OR (:NEW.ST_AVG_PositedAt IS NULL AND :OLD.ST_AVG_PositedAt IS NOT NULL)
        OR (:NEW.ST_AVG_PositedAt IS NOT NULL AND :OLD.ST_AVG_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_AVG_PositedAt;
    ELSIF v_changing_diff AND :NEW.ST_AVG_UTL_ID IS NULL THEN
        v_positing := :NEW.ST_AVG_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_AVG_UTL_ID <> :OLD.ST_AVG_UTL_ID
        OR (:NEW.ST_AVG_UTL_ID IS NULL AND :OLD.ST_AVG_UTL_ID IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_ID IS NOT NULL AND :OLD.ST_AVG_UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_AVG <> :OLD.Metadata_ST_AVG
        OR (:NEW.Metadata_ST_AVG IS NULL AND :OLD.Metadata_ST_AVG IS NOT NULL)
        OR (:NEW.Metadata_ST_AVG IS NOT NULL AND :OLD.Metadata_ST_AVG IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_AVG
        END, :NEW.Metadata_ST);
    v_knot_diff := CASE WHEN (:NEW.ST_AVG_UTL_Utilization <> :OLD.ST_AVG_UTL_Utilization
        OR (:NEW.ST_AVG_UTL_Utilization IS NULL AND :OLD.ST_AVG_UTL_Utilization IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_Utilization IS NOT NULL AND :OLD.ST_AVG_UTL_Utilization IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_AVG := :NEW.ST_AVG_UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_AVG := NULL;
        IF :NEW.ST_AVG_UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.ST_AVG_UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_AVG := kv.UTL_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_AVG_changing := :NEW.ST_AVG_ChangedAt;
        ELSIF :OLD.ST_AVG_UTL_ID = v_AVG THEN
            v_AVG_changing := :NEW.ST_AVG_ChangedAt;
        ELSE
            v_AVG_changing := v_now;
        END IF;
        IF v_AVG IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_AVG_UTL_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.ST_AVG_Confidence IS NULL
            OR :OLD.ST_AVG_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.ST_AVG_Who IS NULL
            OR :OLD.ST_AVG_Who <> v_positor
            OR :OLD.ST_AVG_UTL_ID <> v_AVG
            THEN
                attributes.ip_ST_AVG_Stage_Average(
                    p_owner => COALESCE(:NEW.ST_AVG_ST_ID, :NEW.ST_ID),
                    p_value => v_AVG,
                    p_changing => v_AVG_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.ST_AVG_UTL_ID IS NOT NULL AND (
            :NEW.ST_AVG_UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.ST_AVG_UTL_Utilization IS NULL AND :OLD.ST_AVG_UTL_Utilization IS NOT NULL
            )
        ) THEN
            attributes.ip_ST_AVG_Stage_Average(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_AVG_UTL_ID,
                p_changing => :OLD.ST_AVG_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- ST_MIN_Stage_Minimum
    IF (:NEW.ST_MIN_ID <> :OLD.ST_MIN_ID
        OR (:NEW.ST_MIN_ID IS NULL AND :OLD.ST_MIN_ID IS NOT NULL)
        OR (:NEW.ST_MIN_ID IS NOT NULL AND :OLD.ST_MIN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_MIN_ID is not updatable.');
    END IF;
    IF (:NEW.ST_MIN_ST_ID <> :OLD.ST_MIN_ST_ID
        OR (:NEW.ST_MIN_ST_ID IS NULL AND :OLD.ST_MIN_ST_ID IS NOT NULL)
        OR (:NEW.ST_MIN_ST_ID IS NOT NULL AND :OLD.ST_MIN_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_MIN_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_MIN_Stage_Minimum, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_MIN_Confidence <> :OLD.ST_MIN_Confidence
        OR (:NEW.ST_MIN_Confidence IS NULL AND :OLD.ST_MIN_Confidence IS NOT NULL)
        OR (:NEW.ST_MIN_Confidence IS NOT NULL AND :OLD.ST_MIN_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_MIN_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.ST_MIN_Confidence;
    END IF;
    IF (:NEW.ST_MIN_Who <> :OLD.ST_MIN_Who
        OR (:NEW.ST_MIN_Who IS NULL AND :OLD.ST_MIN_Who IS NOT NULL)
        OR (:NEW.ST_MIN_Who IS NOT NULL AND :OLD.ST_MIN_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_MIN_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_MIN_PositedAt <> :OLD.ST_MIN_PositedAt
        OR (:NEW.ST_MIN_PositedAt IS NULL AND :OLD.ST_MIN_PositedAt IS NOT NULL)
        OR (:NEW.ST_MIN_PositedAt IS NOT NULL AND :OLD.ST_MIN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_MIN_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_MIN_UTL_ID <> :OLD.ST_MIN_UTL_ID
        OR (:NEW.ST_MIN_UTL_ID IS NULL AND :OLD.ST_MIN_UTL_ID IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_ID IS NOT NULL AND :OLD.ST_MIN_UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_MIN <> :OLD.Metadata_ST_MIN
        OR (:NEW.Metadata_ST_MIN IS NULL AND :OLD.Metadata_ST_MIN IS NOT NULL)
        OR (:NEW.Metadata_ST_MIN IS NOT NULL AND :OLD.Metadata_ST_MIN IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_MIN
        END, :NEW.Metadata_ST);
    v_knot_diff := CASE WHEN (:NEW.ST_MIN_UTL_Utilization <> :OLD.ST_MIN_UTL_Utilization
        OR (:NEW.ST_MIN_UTL_Utilization IS NULL AND :OLD.ST_MIN_UTL_Utilization IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_Utilization IS NOT NULL AND :OLD.ST_MIN_UTL_Utilization IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_MIN := :NEW.ST_MIN_UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_MIN := NULL;
        IF :NEW.ST_MIN_UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.ST_MIN_UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_MIN := kv.UTL_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_MIN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_MIN_UTL_ID IS NULL
            OR v_positing_diff
            OR :OLD.ST_MIN_Confidence IS NULL
            OR :OLD.ST_MIN_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.ST_MIN_Who IS NULL
            OR :OLD.ST_MIN_Who <> v_positor
            OR :OLD.ST_MIN_UTL_ID <> v_MIN
            THEN
                attributes.ip_ST_MIN_Stage_Minimum(
                    p_owner => COALESCE(:NEW.ST_MIN_ST_ID, :NEW.ST_ID),
                    p_value => v_MIN,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.ST_MIN_UTL_ID IS NOT NULL AND (
            :NEW.ST_MIN_UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.ST_MIN_UTL_Utilization IS NULL AND :OLD.ST_MIN_UTL_Utilization IS NOT NULL
            )
        ) THEN
            attributes.ip_ST_MIN_Stage_Minimum(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_MIN_UTL_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lST_Stage;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lST_Stage
INSTEAD OF DELETE ON anchors.lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of ST_NAM_Stage_Name is retracted
    INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_Who,
        ST_NAM_PositedAt,
        ST_NAM_Confidence
    )
    SELECT
        :OLD.Metadata_ST_NAM,
        :OLD.ST_NAM_ID,
        COALESCE(:OLD.ST_NAM_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.ST_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_NAM_Stage_Name_Meta x
            WHERE
                x.ST_NAM_ID = :OLD.ST_NAM_ID
            AND
                x.ST_NAM_Who = COALESCE(:OLD.ST_NAM_Who, :OLD.Who, 0)
            AND
                x.ST_NAM_PositedAt = v_now
        );
    -- what is shown of ST_LOC_Stage_Location is retracted
    INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_Who,
        ST_LOC_PositedAt,
        ST_LOC_Confidence
    )
    SELECT
        :OLD.Metadata_ST_LOC,
        :OLD.ST_LOC_ID,
        COALESCE(:OLD.ST_LOC_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.ST_LOC_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_LOC_Stage_Location_Meta x
            WHERE
                x.ST_LOC_ID = :OLD.ST_LOC_ID
            AND
                x.ST_LOC_Who = COALESCE(:OLD.ST_LOC_Who, :OLD.Who, 0)
            AND
                x.ST_LOC_PositedAt = v_now
        );
    -- what is shown of ST_AVG_Stage_Average is retracted
    INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_Who,
        ST_AVG_PositedAt,
        ST_AVG_Confidence
    )
    SELECT
        :OLD.Metadata_ST_AVG,
        :OLD.ST_AVG_ID,
        COALESCE(:OLD.ST_AVG_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.ST_AVG_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_AVG_Stage_Average_Meta x
            WHERE
                x.ST_AVG_ID = :OLD.ST_AVG_ID
            AND
                x.ST_AVG_Who = COALESCE(:OLD.ST_AVG_Who, :OLD.Who, 0)
            AND
                x.ST_AVG_PositedAt = v_now
        );
    -- what is shown of ST_MIN_Stage_Minimum is retracted
    INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_Who,
        ST_MIN_PositedAt,
        ST_MIN_Confidence
    )
    SELECT
        :OLD.Metadata_ST_MIN,
        :OLD.ST_MIN_ID,
        COALESCE(:OLD.ST_MIN_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.ST_MIN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_MIN_Stage_Minimum_Meta x
            WHERE
                x.ST_MIN_ID = :OLD.ST_MIN_ID
            AND
                x.ST_MIN_Who = COALESCE(:OLD.ST_MIN_Who, :OLD.Who, 0)
            AND
                x.ST_MIN_PositedAt = v_now
        );
END dt_lST_Stage;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lAC_Actor
INSTEAD OF INSERT ON anchors.lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(5);
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    v_id := :NEW.AC_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.AC_Actor (
            Metadata_AC
        )
        VALUES (
            :NEW.Metadata_AC
        )
        RETURNING AC_ID INTO v_id;
    END IF;
    IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
        attributes.ip_AC_NAM_Actor_Name(
            p_owner => COALESCE(:NEW.AC_NAM_AC_ID, v_id),
            p_value => :NEW.AC_NAM_Actor_Name,
            p_changing => COALESCE(:NEW.AC_NAM_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.AC_NAM_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.AC_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_NAM_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_AC_NAM, :NEW.Metadata_AC)
        );
    END IF;
    v_GEN := :NEW.AC_GEN_GEN_ID;
    IF v_GEN IS NULL AND :NEW.AC_GEN_GEN_Gender IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GEN_ID
            FROM
                knots.GEN_Gender k
            WHERE
                k.GEN_Checksum = STANDARD_HASH(:NEW.AC_GEN_GEN_Gender, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GEN := kv.GEN_ID;
        END LOOP;
    END IF;
    IF v_GEN IS NOT NULL THEN
        attributes.ip_AC_GEN_Actor_Gender(
            p_owner => COALESCE(:NEW.AC_GEN_AC_ID, v_id),
            p_value => v_GEN,
            p_positor => COALESCE(:NEW.AC_GEN_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.AC_GEN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_GEN_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_AC_GEN, :NEW.Metadata_AC)
        );
    END IF;
    v_PLV := :NEW.AC_PLV_PLV_ID;
    IF v_PLV IS NULL AND :NEW.AC_PLV_PLV_ProfessionalLevel IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                knots.PLV_ProfessionalLevel k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.AC_PLV_PLV_ProfessionalLevel, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PLV := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_PLV IS NOT NULL THEN
        attributes.ip_AC_PLV_Actor_ProfessionalLevel(
            p_owner => COALESCE(:NEW.AC_PLV_AC_ID, v_id),
            p_value => v_PLV,
            p_changing => COALESCE(:NEW.AC_PLV_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.AC_PLV_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.AC_PLV_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_PLV_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_AC_PLV, :NEW.Metadata_AC)
        );
    END IF;
END it_lAC_Actor;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lAC_Actor
INSTEAD OF UPDATE ON anchors.lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(19);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_NAM_changing timestamp;
    v_GEN number(3);
    v_PLV number(3);
    v_PLV_changing timestamp;
BEGIN
    IF (:NEW.AC_ID <> :OLD.AC_ID
        OR (:NEW.AC_ID IS NULL AND :OLD.AC_ID IS NOT NULL)
        OR (:NEW.AC_ID IS NOT NULL AND :OLD.AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Confidence <> :OLD.Confidence
        OR (:NEW.Confidence IS NULL AND :OLD.Confidence IS NOT NULL)
        OR (:NEW.Confidence IS NOT NULL AND :OLD.Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
        OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
        OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL)) THEN TRUE ELSE FALSE END;
    -- AC_NAM_Actor_Name
    IF (:NEW.AC_NAM_ID <> :OLD.AC_NAM_ID
        OR (:NEW.AC_NAM_ID IS NULL AND :OLD.AC_NAM_ID IS NOT NULL)
        OR (:NEW.AC_NAM_ID IS NOT NULL AND :OLD.AC_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.AC_NAM_AC_ID <> :OLD.AC_NAM_AC_ID
        OR (:NEW.AC_NAM_AC_ID IS NULL AND :OLD.AC_NAM_AC_ID IS NOT NULL)
        OR (:NEW.AC_NAM_AC_ID IS NOT NULL AND :OLD.AC_NAM_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_NAM_AC_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_NAM_Actor_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_NAM_Confidence <> :OLD.AC_NAM_Confidence
        OR (:NEW.AC_NAM_Confidence IS NULL AND :OLD.AC_NAM_Confidence IS NOT NULL)
        OR (:NEW.AC_NAM_Confidence IS NOT NULL AND :OLD.AC_NAM_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_NAM_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.AC_NAM_Confidence;
    END IF;
    IF (:NEW.AC_NAM_Who <> :OLD.AC_NAM_Who
        OR (:NEW.AC_NAM_Who IS NULL AND :OLD.AC_NAM_Who IS NOT NULL)
        OR (:NEW.AC_NAM_Who IS NOT NULL AND :OLD.AC_NAM_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_NAM_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_NAM_PositedAt <> :OLD.AC_NAM_PositedAt
        OR (:NEW.AC_NAM_PositedAt IS NULL AND :OLD.AC_NAM_PositedAt IS NOT NULL)
        OR (:NEW.AC_NAM_PositedAt IS NOT NULL AND :OLD.AC_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_NAM_PositedAt;
    ELSIF v_changing_diff AND :NEW.AC_NAM_Actor_Name IS NULL THEN
        v_positing := :NEW.AC_NAM_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.AC_NAM_Actor_Name <> :OLD.AC_NAM_Actor_Name
        OR (:NEW.AC_NAM_Actor_Name IS NULL AND :OLD.AC_NAM_Actor_Name IS NOT NULL)
        OR (:NEW.AC_NAM_Actor_Name IS NOT NULL AND :OLD.AC_NAM_Actor_Name IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_AC_NAM <> :OLD.Metadata_AC_NAM
        OR (:NEW.Metadata_AC_NAM IS NULL AND :OLD.Metadata_AC_NAM IS NOT NULL)
        OR (:NEW.Metadata_AC_NAM IS NOT NULL AND :OLD.Metadata_AC_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_AC
            ELSE :NEW.Metadata_AC_NAM
        END, :NEW.Metadata_AC);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_NAM_changing := :NEW.AC_NAM_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_NAM_changing := :NEW.AC_NAM_ChangedAt;
        ELSE
            v_NAM_changing := v_now;
        END IF;
        IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.AC_NAM_Actor_Name IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.AC_NAM_Confidence IS NULL
            OR :OLD.AC_NAM_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.AC_NAM_Who IS NULL
            OR :OLD.AC_NAM_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_AC_NAM_Actor_Name(
                    p_owner => COALESCE(:NEW.AC_NAM_AC_ID, :NEW.AC_ID),
                    p_value => :NEW.AC_NAM_Actor_Name,
                    p_changing => v_NAM_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.AC_NAM_Actor_Name IS NULL AND :OLD.AC_NAM_Actor_Name IS NOT NULL THEN
            attributes.ip_AC_NAM_Actor_Name(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_NAM_Actor_Name,
                p_changing => :OLD.AC_NAM_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- AC_GEN_Actor_Gender
    IF (:NEW.AC_GEN_ID <> :OLD.AC_GEN_ID
        OR (:NEW.AC_GEN_ID IS NULL AND :OLD.AC_GEN_ID IS NOT NULL)
        OR (:NEW.AC_GEN_ID IS NOT NULL AND :OLD.AC_GEN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_GEN_ID is not updatable.');
    END IF;
    IF (:NEW.AC_GEN_AC_ID <> :OLD.AC_GEN_AC_ID
        OR (:NEW.AC_GEN_AC_ID IS NULL AND :OLD.AC_GEN_AC_ID IS NOT NULL)
        OR (:NEW.AC_GEN_AC_ID IS NOT NULL AND :OLD.AC_GEN_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_GEN_AC_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_GEN_Actor_Gender, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_GEN_Confidence <> :OLD.AC_GEN_Confidence
        OR (:NEW.AC_GEN_Confidence IS NULL AND :OLD.AC_GEN_Confidence IS NOT NULL)
        OR (:NEW.AC_GEN_Confidence IS NOT NULL AND :OLD.AC_GEN_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_GEN_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.AC_GEN_Confidence;
    END IF;
    IF (:NEW.AC_GEN_Who <> :OLD.AC_GEN_Who
        OR (:NEW.AC_GEN_Who IS NULL AND :OLD.AC_GEN_Who IS NOT NULL)
        OR (:NEW.AC_GEN_Who IS NOT NULL AND :OLD.AC_GEN_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_GEN_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_GEN_PositedAt <> :OLD.AC_GEN_PositedAt
        OR (:NEW.AC_GEN_PositedAt IS NULL AND :OLD.AC_GEN_PositedAt IS NOT NULL)
        OR (:NEW.AC_GEN_PositedAt IS NOT NULL AND :OLD.AC_GEN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_GEN_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.AC_GEN_GEN_ID <> :OLD.AC_GEN_GEN_ID
        OR (:NEW.AC_GEN_GEN_ID IS NULL AND :OLD.AC_GEN_GEN_ID IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_ID IS NOT NULL AND :OLD.AC_GEN_GEN_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_AC_GEN <> :OLD.Metadata_AC_GEN
        OR (:NEW.Metadata_AC_GEN IS NULL AND :OLD.Metadata_AC_GEN IS NOT NULL)
        OR (:NEW.Metadata_AC_GEN IS NOT NULL AND :OLD.Metadata_AC_GEN IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_AC
            ELSE :NEW.Metadata_AC_GEN
        END, :NEW.Metadata_AC);
    v_knot_diff := CASE WHEN (:NEW.AC_GEN_GEN_Gender <> :OLD.AC_GEN_GEN_Gender
        OR (:NEW.AC_GEN_GEN_Gender IS NULL AND :OLD.AC_GEN_GEN_Gender IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_Gender IS NOT NULL AND :OLD.AC_GEN_GEN_Gender IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_GEN := :NEW.AC_GEN_GEN_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_GEN := NULL;
        IF :NEW.AC_GEN_GEN_Gender IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GEN_ID
                FROM
                    knots.GEN_Gender k
                WHERE
                    k.GEN_Checksum = STANDARD_HASH(:NEW.AC_GEN_GEN_Gender, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GEN := kv.GEN_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_GEN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.AC_GEN_GEN_ID IS NULL
            OR v_positing_diff
            OR :OLD.AC_GEN_Confidence IS NULL
            OR :OLD.AC_GEN_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.AC_GEN_Who IS NULL
            OR :OLD.AC_GEN_Who <> v_positor
            OR :OLD.AC_GEN_GEN_ID <> v_GEN
            THEN
                attributes.ip_AC_GEN_Actor_Gender(
                    p_owner => COALESCE(:NEW.AC_GEN_AC_ID, :NEW.AC_ID),
                    p_value => v_GEN,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.AC_GEN_GEN_ID IS NOT NULL AND (
            :NEW.AC_GEN_GEN_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.AC_GEN_GEN_Gender IS NULL AND :OLD.AC_GEN_GEN_Gender IS NOT NULL
            )
        ) THEN
            attributes.ip_AC_GEN_Actor_Gender(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_GEN_GEN_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- AC_PLV_Actor_ProfessionalLevel
    IF (:NEW.AC_PLV_ID <> :OLD.AC_PLV_ID
        OR (:NEW.AC_PLV_ID IS NULL AND :OLD.AC_PLV_ID IS NOT NULL)
        OR (:NEW.AC_PLV_ID IS NOT NULL AND :OLD.AC_PLV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_PLV_ID is not updatable.');
    END IF;
    IF (:NEW.AC_PLV_AC_ID <> :OLD.AC_PLV_AC_ID
        OR (:NEW.AC_PLV_AC_ID IS NULL AND :OLD.AC_PLV_AC_ID IS NOT NULL)
        OR (:NEW.AC_PLV_AC_ID IS NOT NULL AND :OLD.AC_PLV_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_PLV_AC_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_PLV_Actor_ProfessionalLevel, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_PLV_Confidence <> :OLD.AC_PLV_Confidence
        OR (:NEW.AC_PLV_Confidence IS NULL AND :OLD.AC_PLV_Confidence IS NOT NULL)
        OR (:NEW.AC_PLV_Confidence IS NOT NULL AND :OLD.AC_PLV_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_PLV_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.AC_PLV_Confidence;
    END IF;
    IF (:NEW.AC_PLV_Who <> :OLD.AC_PLV_Who
        OR (:NEW.AC_PLV_Who IS NULL AND :OLD.AC_PLV_Who IS NOT NULL)
        OR (:NEW.AC_PLV_Who IS NOT NULL AND :OLD.AC_PLV_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_PLV_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_PLV_PositedAt <> :OLD.AC_PLV_PositedAt
        OR (:NEW.AC_PLV_PositedAt IS NULL AND :OLD.AC_PLV_PositedAt IS NOT NULL)
        OR (:NEW.AC_PLV_PositedAt IS NOT NULL AND :OLD.AC_PLV_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_PLV_PositedAt;
    ELSIF v_changing_diff AND :NEW.AC_PLV_PLV_ID IS NULL THEN
        v_positing := :NEW.AC_PLV_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.AC_PLV_PLV_ID <> :OLD.AC_PLV_PLV_ID
        OR (:NEW.AC_PLV_PLV_ID IS NULL AND :OLD.AC_PLV_PLV_ID IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_ID IS NOT NULL AND :OLD.AC_PLV_PLV_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_AC_PLV <> :OLD.Metadata_AC_PLV
        OR (:NEW.Metadata_AC_PLV IS NULL AND :OLD.Metadata_AC_PLV IS NOT NULL)
        OR (:NEW.Metadata_AC_PLV IS NOT NULL AND :OLD.Metadata_AC_PLV IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_AC
            ELSE :NEW.Metadata_AC_PLV
        END, :NEW.Metadata_AC);
    v_knot_diff := CASE WHEN (:NEW.AC_PLV_PLV_ProfessionalLevel <> :OLD.AC_PLV_PLV_ProfessionalLevel
        OR (:NEW.AC_PLV_PLV_ProfessionalLevel IS NULL AND :OLD.AC_PLV_PLV_ProfessionalLevel IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_ProfessionalLevel IS NOT NULL AND :OLD.AC_PLV_PLV_ProfessionalLevel IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_PLV := :NEW.AC_PLV_PLV_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_PLV := NULL;
        IF :NEW.AC_PLV_PLV_ProfessionalLevel IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    knots.PLV_ProfessionalLevel k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.AC_PLV_PLV_ProfessionalLevel, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_PLV := kv.PLV_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_PLV_changing := :NEW.AC_PLV_ChangedAt;
        ELSIF :OLD.AC_PLV_PLV_ID = v_PLV THEN
            v_PLV_changing := :NEW.AC_PLV_ChangedAt;
        ELSE
            v_PLV_changing := v_now;
        END IF;
        IF v_PLV IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.AC_PLV_PLV_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.AC_PLV_Confidence IS NULL
            OR :OLD.AC_PLV_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.AC_PLV_Who IS NULL
            OR :OLD.AC_PLV_Who <> v_positor
            OR :OLD.AC_PLV_PLV_ID <> v_PLV
            THEN
                attributes.ip_AC_PLV_Actor_ProfessionalLevel(
                    p_owner => COALESCE(:NEW.AC_PLV_AC_ID, :NEW.AC_ID),
                    p_value => v_PLV,
                    p_changing => v_PLV_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.AC_PLV_PLV_ID IS NOT NULL AND (
            :NEW.AC_PLV_PLV_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.AC_PLV_PLV_ProfessionalLevel IS NULL AND :OLD.AC_PLV_PLV_ProfessionalLevel IS NOT NULL
            )
        ) THEN
            attributes.ip_AC_PLV_Actor_ProfessionalLevel(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_PLV_PLV_ID,
                p_changing => :OLD.AC_PLV_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lAC_Actor;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lAC_Actor
INSTEAD OF DELETE ON anchors.lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of AC_NAM_Actor_Name is retracted
    INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_Who,
        AC_NAM_PositedAt,
        AC_NAM_Confidence
    )
    SELECT
        :OLD.Metadata_AC_NAM,
        :OLD.AC_NAM_ID,
        COALESCE(:OLD.AC_NAM_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.AC_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.AC_NAM_Actor_Name_Meta x
            WHERE
                x.AC_NAM_ID = :OLD.AC_NAM_ID
            AND
                x.AC_NAM_Who = COALESCE(:OLD.AC_NAM_Who, :OLD.Who, 0)
            AND
                x.AC_NAM_PositedAt = v_now
        );
    -- what is shown of AC_GEN_Actor_Gender is retracted
    INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_Who,
        AC_GEN_PositedAt,
        AC_GEN_Confidence
    )
    SELECT
        :OLD.Metadata_AC_GEN,
        :OLD.AC_GEN_ID,
        COALESCE(:OLD.AC_GEN_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.AC_GEN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.AC_GEN_Actor_Gender_Meta x
            WHERE
                x.AC_GEN_ID = :OLD.AC_GEN_ID
            AND
                x.AC_GEN_Who = COALESCE(:OLD.AC_GEN_Who, :OLD.Who, 0)
            AND
                x.AC_GEN_PositedAt = v_now
        );
    -- what is shown of AC_PLV_Actor_ProfessionalLevel is retracted
    INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_Who,
        AC_PLV_PositedAt,
        AC_PLV_Confidence
    )
    SELECT
        :OLD.Metadata_AC_PLV,
        :OLD.AC_PLV_ID,
        COALESCE(:OLD.AC_PLV_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.AC_PLV_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.AC_PLV_Actor_ProfessionalLevel_Meta x
            WHERE
                x.AC_PLV_ID = :OLD.AC_PLV_ID
            AND
                x.AC_PLV_Who = COALESCE(:OLD.AC_PLV_Who, :OLD.Who, 0)
            AND
                x.AC_PLV_PositedAt = v_now
        );
END dt_lAC_Actor;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lPR_Program
INSTEAD OF INSERT ON anchors.lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(19);
BEGIN
    v_id := :NEW.PR_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.PR_Program (
            Metadata_PR
        )
        VALUES (
            :NEW.Metadata_PR
        )
        RETURNING PR_ID INTO v_id;
    END IF;
    IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
        attributes.ip_PR_NAM_Program_Name(
            p_owner => COALESCE(:NEW.PR_NAM_PR_ID, v_id),
            p_value => :NEW.PR_NAM_Program_Name,
            p_positor => COALESCE(:NEW.PR_NAM_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.PR_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.PR_NAM_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_PR_NAM, :NEW.Metadata_PR)
        );
    END IF;
    IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
        attributes.ip_PR_LEN_Program_Length(
            p_owner => COALESCE(:NEW.PR_LEN_PR_ID, v_id),
            p_value => :NEW.PR_LEN_Program_Length,
            p_changing => COALESCE(:NEW.PR_LEN_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.PR_LEN_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.PR_LEN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.PR_LEN_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_PR_LEN, :NEW.Metadata_PR)
        );
    END IF;
END it_lPR_Program;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lPR_Program
INSTEAD OF UPDATE ON anchors.lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(19);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_LEN_changing date;
BEGIN
    IF (:NEW.PR_ID <> :OLD.PR_ID
        OR (:NEW.PR_ID IS NULL AND :OLD.PR_ID IS NOT NULL)
        OR (:NEW.PR_ID IS NOT NULL AND :OLD.PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Confidence <> :OLD.Confidence
        OR (:NEW.Confidence IS NULL AND :OLD.Confidence IS NOT NULL)
        OR (:NEW.Confidence IS NOT NULL AND :OLD.Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_PR <> :OLD.Metadata_PR
        OR (:NEW.Metadata_PR IS NULL AND :OLD.Metadata_PR IS NOT NULL)
        OR (:NEW.Metadata_PR IS NOT NULL AND :OLD.Metadata_PR IS NULL)) THEN TRUE ELSE FALSE END;
    -- PR_NAM_Program_Name
    IF (:NEW.PR_NAM_ID <> :OLD.PR_NAM_ID
        OR (:NEW.PR_NAM_ID IS NULL AND :OLD.PR_NAM_ID IS NOT NULL)
        OR (:NEW.PR_NAM_ID IS NOT NULL AND :OLD.PR_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_PR_ID <> :OLD.PR_NAM_PR_ID
        OR (:NEW.PR_NAM_PR_ID IS NULL AND :OLD.PR_NAM_PR_ID IS NOT NULL)
        OR (:NEW.PR_NAM_PR_ID IS NOT NULL AND :OLD.PR_NAM_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_NAM_PR_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of PR_NAM_Program_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.PR_NAM_Confidence <> :OLD.PR_NAM_Confidence
        OR (:NEW.PR_NAM_Confidence IS NULL AND :OLD.PR_NAM_Confidence IS NOT NULL)
        OR (:NEW.PR_NAM_Confidence IS NOT NULL AND :OLD.PR_NAM_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.PR_NAM_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.PR_NAM_Confidence;
    END IF;
    IF (:NEW.PR_NAM_Who <> :OLD.PR_NAM_Who
        OR (:NEW.PR_NAM_Who IS NULL AND :OLD.PR_NAM_Who IS NOT NULL)
        OR (:NEW.PR_NAM_Who IS NOT NULL AND :OLD.PR_NAM_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.PR_NAM_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.PR_NAM_PositedAt <> :OLD.PR_NAM_PositedAt
        OR (:NEW.PR_NAM_PositedAt IS NULL AND :OLD.PR_NAM_PositedAt IS NOT NULL)
        OR (:NEW.PR_NAM_PositedAt IS NOT NULL AND :OLD.PR_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.PR_NAM_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.PR_NAM_Program_Name <> :OLD.PR_NAM_Program_Name
        OR (:NEW.PR_NAM_Program_Name IS NULL AND :OLD.PR_NAM_Program_Name IS NOT NULL)
        OR (:NEW.PR_NAM_Program_Name IS NOT NULL AND :OLD.PR_NAM_Program_Name IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_PR_NAM <> :OLD.Metadata_PR_NAM
        OR (:NEW.Metadata_PR_NAM IS NULL AND :OLD.Metadata_PR_NAM IS NOT NULL)
        OR (:NEW.Metadata_PR_NAM IS NOT NULL AND :OLD.Metadata_PR_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_PR
            ELSE :NEW.Metadata_PR_NAM
        END, :NEW.Metadata_PR);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.PR_NAM_Program_Name IS NULL
            OR v_positing_diff
            OR :OLD.PR_NAM_Confidence IS NULL
            OR :OLD.PR_NAM_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.PR_NAM_Who IS NULL
            OR :OLD.PR_NAM_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_PR_NAM_Program_Name(
                    p_owner => COALESCE(:NEW.PR_NAM_PR_ID, :NEW.PR_ID),
                    p_value => :NEW.PR_NAM_Program_Name,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.PR_NAM_Program_Name IS NULL AND :OLD.PR_NAM_Program_Name IS NOT NULL THEN
            attributes.ip_PR_NAM_Program_Name(
                p_owner => :OLD.PR_ID,
                p_value => :OLD.PR_NAM_Program_Name,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- PR_LEN_Program_Length
    IF (:NEW.PR_LEN_ID <> :OLD.PR_LEN_ID
        OR (:NEW.PR_LEN_ID IS NULL AND :OLD.PR_LEN_ID IS NOT NULL)
        OR (:NEW.PR_LEN_ID IS NOT NULL AND :OLD.PR_LEN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_LEN_ID is not updatable.');
    END IF;
    IF (:NEW.PR_LEN_PR_ID <> :OLD.PR_LEN_PR_ID
        OR (:NEW.PR_LEN_PR_ID IS NULL AND :OLD.PR_LEN_PR_ID IS NOT NULL)
        OR (:NEW.PR_LEN_PR_ID IS NOT NULL AND :OLD.PR_LEN_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_LEN_PR_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of PR_LEN_Program_Length, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.PR_LEN_Confidence <> :OLD.PR_LEN_Confidence
        OR (:NEW.PR_LEN_Confidence IS NULL AND :OLD.PR_LEN_Confidence IS NOT NULL)
        OR (:NEW.PR_LEN_Confidence IS NOT NULL AND :OLD.PR_LEN_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.PR_LEN_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.PR_LEN_Confidence;
    END IF;
    IF (:NEW.PR_LEN_Who <> :OLD.PR_LEN_Who
        OR (:NEW.PR_LEN_Who IS NULL AND :OLD.PR_LEN_Who IS NOT NULL)
        OR (:NEW.PR_LEN_Who IS NOT NULL AND :OLD.PR_LEN_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.PR_LEN_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.PR_LEN_PositedAt <> :OLD.PR_LEN_PositedAt
        OR (:NEW.PR_LEN_PositedAt IS NULL AND :OLD.PR_LEN_PositedAt IS NOT NULL)
        OR (:NEW.PR_LEN_PositedAt IS NOT NULL AND :OLD.PR_LEN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.PR_LEN_PositedAt;
    ELSIF v_changing_diff AND :NEW.PR_LEN_Program_Length IS NULL THEN
        v_positing := :NEW.PR_LEN_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.PR_LEN_Program_Length <> :OLD.PR_LEN_Program_Length
        OR (:NEW.PR_LEN_Program_Length IS NULL AND :OLD.PR_LEN_Program_Length IS NOT NULL)
        OR (:NEW.PR_LEN_Program_Length IS NOT NULL AND :OLD.PR_LEN_Program_Length IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_PR_LEN <> :OLD.Metadata_PR_LEN
        OR (:NEW.Metadata_PR_LEN IS NULL AND :OLD.Metadata_PR_LEN IS NOT NULL)
        OR (:NEW.Metadata_PR_LEN IS NOT NULL AND :OLD.Metadata_PR_LEN IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_PR
            ELSE :NEW.Metadata_PR_LEN
        END, :NEW.Metadata_PR);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_LEN_changing := :NEW.PR_LEN_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_LEN_changing := :NEW.PR_LEN_ChangedAt;
        ELSE
            v_LEN_changing := v_now;
        END IF;
        IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.PR_LEN_Program_Length IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.PR_LEN_Confidence IS NULL
            OR :OLD.PR_LEN_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.PR_LEN_Who IS NULL
            OR :OLD.PR_LEN_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_PR_LEN_Program_Length(
                    p_owner => COALESCE(:NEW.PR_LEN_PR_ID, :NEW.PR_ID),
                    p_value => :NEW.PR_LEN_Program_Length,
                    p_changing => v_LEN_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.PR_LEN_Program_Length IS NULL AND :OLD.PR_LEN_Program_Length IS NOT NULL THEN
            attributes.ip_PR_LEN_Program_Length(
                p_owner => :OLD.PR_ID,
                p_value => :OLD.PR_LEN_Program_Length,
                p_changing => :OLD.PR_LEN_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lPR_Program;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lPR_Program
INSTEAD OF DELETE ON anchors.lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of PR_NAM_Program_Name is retracted
    INSERT INTO attributes.PR_NAM_Program_Name_Meta (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_Who,
        PR_NAM_PositedAt,
        PR_NAM_Confidence
    )
    SELECT
        :OLD.Metadata_PR_NAM,
        :OLD.PR_NAM_ID,
        COALESCE(:OLD.PR_NAM_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.PR_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.PR_NAM_Program_Name_Meta x
            WHERE
                x.PR_NAM_ID = :OLD.PR_NAM_ID
            AND
                x.PR_NAM_Who = COALESCE(:OLD.PR_NAM_Who, :OLD.Who, 0)
            AND
                x.PR_NAM_PositedAt = v_now
        );
    -- what is shown of PR_LEN_Program_Length is retracted
    INSERT INTO attributes.PR_LEN_Program_Length_Meta (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_Who,
        PR_LEN_PositedAt,
        PR_LEN_Confidence
    )
    SELECT
        :OLD.Metadata_PR_LEN,
        :OLD.PR_LEN_ID,
        COALESCE(:OLD.PR_LEN_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.PR_LEN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.PR_LEN_Program_Length_Meta x
            WHERE
                x.PR_LEN_ID = :OLD.PR_LEN_ID
            AND
                x.PR_LEN_Who = COALESCE(:OLD.PR_LEN_Who, :OLD.Who, 0)
            AND
                x.PR_LEN_PositedAt = v_now
        );
END dt_lPR_Program;
/
-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the posit and annex tables of the attributes in a consistent way,
-- through the insert procedures of the attributes (ip_<attribute>, see the attribute triggers, which keep the posit and
-- annex tables). Default values are used for some columns if not provided by the corresponding SQL statements: the positor
-- is 0, the changing and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the insert procedures of the attributes see to that).
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_Event instead of INSERT trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.it_lEV_Event
INSTEAD OF INSERT ON nexuses.lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(12,0);
    v_UTL number(3);
    v_LVL number(3);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        INSERT INTO nexuses.EV_Event (
            ST_ID_wasHeldAt,
            PR_ID_wasPlayed,
            ETY_ID_of,
            Metadata_EV
        )
        VALUES (
            :NEW.ST_ID_wasHeldAt,
            :NEW.PR_ID_wasPlayed,
            :NEW.ETY_ID_of,
            :NEW.Metadata_EV
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_DAT_Event_Date IS NOT NULL THEN
        attributes.ip_EV_DAT_Event_Date(
            p_owner => COALESCE(:NEW.EV_DAT_EV_ID, v_id),
            p_value => :NEW.EV_DAT_Event_Date,
            p_positor => COALESCE(:NEW.EV_DAT_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_DAT_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_DAT_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_DAT, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
        attributes.ip_EV_AUD_Event_Audience(
            p_owner => COALESCE(:NEW.EV_AUD_EV_ID, v_id),
            p_value => :NEW.EV_AUD_Event_Audience,
            p_positor => COALESCE(:NEW.EV_AUD_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_AUD_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_AUD_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_AUD, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
        attributes.ip_EV_REV_Event_Revenue(
            p_owner => COALESCE(:NEW.EV_REV_EV_ID, v_id),
            p_value => :NEW.EV_REV_Event_Revenue,
            p_positor => COALESCE(:NEW.EV_REV_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_REV_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_REV_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_REV, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_STA_Event_Status IS NOT NULL THEN
        attributes.ip_EV_STA_Event_Status(
            p_owner => COALESCE(:NEW.EV_STA_EV_ID, v_id),
            p_value => :NEW.EV_STA_Event_Status,
            p_changing => COALESCE(:NEW.EV_STA_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.EV_STA_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_STA_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_STA_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_STA, :NEW.Metadata_EV)
        );
    END IF;
    v_UTL := :NEW.EV_UTL_UTL_ID;
    IF v_UTL IS NULL AND :NEW.EV_UTL_UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.EV_UTL_UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_UTL := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_UTL IS NOT NULL THEN
        attributes.ip_EV_UTL_Event_Utilization(
            p_owner => COALESCE(:NEW.EV_UTL_EV_ID, v_id),
            p_value => v_UTL,
            p_positor => COALESCE(:NEW.EV_UTL_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_UTL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_UTL_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_UTL, :NEW.Metadata_EV)
        );
    END IF;
    v_LVL := :NEW.EV_LVL_PLV_ID;
    IF v_LVL IS NULL AND :NEW.EV_LVL_PLV_ProfessionalLevel IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                knots.PLV_ProfessionalLevel k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.EV_LVL_PLV_ProfessionalLevel, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_LVL := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_LVL IS NOT NULL THEN
        attributes.ip_EV_LVL_Event_Level(
            p_owner => COALESCE(:NEW.EV_LVL_EV_ID, v_id),
            p_value => v_LVL,
            p_changing => COALESCE(:NEW.EV_LVL_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.EV_LVL_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_LVL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_LVL_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_LVL, :NEW.Metadata_EV)
        );
    END IF;
END it_lEV_Event;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.ut_lEV_Event
INSTEAD OF UPDATE ON nexuses.lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(19);
    v_nexus_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_STA_changing timestamp;
    v_UTL number(3);
    v_LVL number(3);
    v_LVL_changing date;
BEGIN
    IF (:NEW.EV_ID <> :OLD.EV_ID
        OR (:NEW.EV_ID IS NULL AND :OLD.EV_ID IS NOT NULL)
        OR (:NEW.EV_ID IS NOT NULL AND :OLD.EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_ID is not updatable.');
    END IF;
    IF (:NEW.ST_ID_wasHeldAt <> :OLD.ST_ID_wasHeldAt
        OR (:NEW.ST_ID_wasHeldAt IS NULL AND :OLD.ST_ID_wasHeldAt IS NOT NULL)
        OR (:NEW.ST_ID_wasHeldAt IS NOT NULL AND :OLD.ST_ID_wasHeldAt IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column ST_ID_wasHeldAt is not updatable.');
    END IF;
    IF (:NEW.PR_ID_wasPlayed <> :OLD.PR_ID_wasPlayed
        OR (:NEW.PR_ID_wasPlayed IS NULL AND :OLD.PR_ID_wasPlayed IS NOT NULL)
        OR (:NEW.PR_ID_wasPlayed IS NOT NULL AND :OLD.PR_ID_wasPlayed IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column PR_ID_wasPlayed is not updatable.');
    END IF;
    IF (:NEW.ETY_ID_of <> :OLD.ETY_ID_of
        OR (:NEW.ETY_ID_of IS NULL AND :OLD.ETY_ID_of IS NOT NULL)
        OR (:NEW.ETY_ID_of IS NOT NULL AND :OLD.ETY_ID_of IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column ETY_ID_of is not updatable.');
    END IF;
    IF (:NEW.of_ETY_EventType <> :OLD.of_ETY_EventType
        OR (:NEW.of_ETY_EventType IS NULL AND :OLD.of_ETY_EventType IS NOT NULL)
        OR (:NEW.of_ETY_EventType IS NOT NULL AND :OLD.of_ETY_EventType IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column of_ETY_EventType is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Confidence <> :OLD.Confidence
        OR (:NEW.Confidence IS NULL AND :OLD.Confidence IS NOT NULL)
        OR (:NEW.Confidence IS NOT NULL AND :OLD.Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    v_nexus_meta_diff := CASE WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
        OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
        OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL)) THEN TRUE ELSE FALSE END;
    -- EV_DAT_Event_Date
    IF (:NEW.EV_DAT_ID <> :OLD.EV_DAT_ID
        OR (:NEW.EV_DAT_ID IS NULL AND :OLD.EV_DAT_ID IS NOT NULL)
        OR (:NEW.EV_DAT_ID IS NOT NULL AND :OLD.EV_DAT_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_DAT_ID is not updatable.');
    END IF;
    IF (:NEW.EV_DAT_EV_ID <> :OLD.EV_DAT_EV_ID
        OR (:NEW.EV_DAT_EV_ID IS NULL AND :OLD.EV_DAT_EV_ID IS NOT NULL)
        OR (:NEW.EV_DAT_EV_ID IS NOT NULL AND :OLD.EV_DAT_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_DAT_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_DAT_Event_Date, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_DAT_Confidence <> :OLD.EV_DAT_Confidence
        OR (:NEW.EV_DAT_Confidence IS NULL AND :OLD.EV_DAT_Confidence IS NOT NULL)
        OR (:NEW.EV_DAT_Confidence IS NOT NULL AND :OLD.EV_DAT_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_DAT_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_DAT_Confidence;
    END IF;
    IF (:NEW.EV_DAT_Who <> :OLD.EV_DAT_Who
        OR (:NEW.EV_DAT_Who IS NULL AND :OLD.EV_DAT_Who IS NOT NULL)
        OR (:NEW.EV_DAT_Who IS NOT NULL AND :OLD.EV_DAT_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_DAT_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_DAT_PositedAt <> :OLD.EV_DAT_PositedAt
        OR (:NEW.EV_DAT_PositedAt IS NULL AND :OLD.EV_DAT_PositedAt IS NOT NULL)
        OR (:NEW.EV_DAT_PositedAt IS NOT NULL AND :OLD.EV_DAT_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_DAT_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_DAT_Event_Date <> :OLD.EV_DAT_Event_Date
        OR (:NEW.EV_DAT_Event_Date IS NULL AND :OLD.EV_DAT_Event_Date IS NOT NULL)
        OR (:NEW.EV_DAT_Event_Date IS NOT NULL AND :OLD.EV_DAT_Event_Date IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_DAT <> :OLD.Metadata_EV_DAT
        OR (:NEW.Metadata_EV_DAT IS NULL AND :OLD.Metadata_EV_DAT IS NOT NULL)
        OR (:NEW.Metadata_EV_DAT IS NOT NULL AND :OLD.Metadata_EV_DAT IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_DAT
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_DAT_Event_Date IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_DAT_Event_Date IS NULL
            OR v_positing_diff
            OR :OLD.EV_DAT_Confidence IS NULL
            OR :OLD.EV_DAT_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_DAT_Who IS NULL
            OR :OLD.EV_DAT_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_DAT_Event_Date(
                    p_owner => COALESCE(:NEW.EV_DAT_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_DAT_Event_Date,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_DAT_Event_Date IS NULL AND :OLD.EV_DAT_Event_Date IS NOT NULL THEN
            attributes.ip_EV_DAT_Event_Date(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_DAT_Event_Date,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_AUD_Event_Audience
    IF (:NEW.EV_AUD_ID <> :OLD.EV_AUD_ID
        OR (:NEW.EV_AUD_ID IS NULL AND :OLD.EV_AUD_ID IS NOT NULL)
        OR (:NEW.EV_AUD_ID IS NOT NULL AND :OLD.EV_AUD_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_AUD_ID is not updatable.');
    END IF;
    IF (:NEW.EV_AUD_EV_ID <> :OLD.EV_AUD_EV_ID
        OR (:NEW.EV_AUD_EV_ID IS NULL AND :OLD.EV_AUD_EV_ID IS NOT NULL)
        OR (:NEW.EV_AUD_EV_ID IS NOT NULL AND :OLD.EV_AUD_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_AUD_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_AUD_Event_Audience, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_AUD_Confidence <> :OLD.EV_AUD_Confidence
        OR (:NEW.EV_AUD_Confidence IS NULL AND :OLD.EV_AUD_Confidence IS NOT NULL)
        OR (:NEW.EV_AUD_Confidence IS NOT NULL AND :OLD.EV_AUD_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_AUD_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_AUD_Confidence;
    END IF;
    IF (:NEW.EV_AUD_Who <> :OLD.EV_AUD_Who
        OR (:NEW.EV_AUD_Who IS NULL AND :OLD.EV_AUD_Who IS NOT NULL)
        OR (:NEW.EV_AUD_Who IS NOT NULL AND :OLD.EV_AUD_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_AUD_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_AUD_PositedAt <> :OLD.EV_AUD_PositedAt
        OR (:NEW.EV_AUD_PositedAt IS NULL AND :OLD.EV_AUD_PositedAt IS NOT NULL)
        OR (:NEW.EV_AUD_PositedAt IS NOT NULL AND :OLD.EV_AUD_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_AUD_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_AUD_Event_Audience <> :OLD.EV_AUD_Event_Audience
        OR (:NEW.EV_AUD_Event_Audience IS NULL AND :OLD.EV_AUD_Event_Audience IS NOT NULL)
        OR (:NEW.EV_AUD_Event_Audience IS NOT NULL AND :OLD.EV_AUD_Event_Audience IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_AUD <> :OLD.Metadata_EV_AUD
        OR (:NEW.Metadata_EV_AUD IS NULL AND :OLD.Metadata_EV_AUD IS NOT NULL)
        OR (:NEW.Metadata_EV_AUD IS NOT NULL AND :OLD.Metadata_EV_AUD IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_AUD
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_AUD_Event_Audience IS NULL
            OR v_positing_diff
            OR :OLD.EV_AUD_Confidence IS NULL
            OR :OLD.EV_AUD_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_AUD_Who IS NULL
            OR :OLD.EV_AUD_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_AUD_Event_Audience(
                    p_owner => COALESCE(:NEW.EV_AUD_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_AUD_Event_Audience,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_AUD_Event_Audience IS NULL AND :OLD.EV_AUD_Event_Audience IS NOT NULL THEN
            attributes.ip_EV_AUD_Event_Audience(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_AUD_Event_Audience,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_REV_Event_Revenue
    IF (:NEW.EV_REV_ID <> :OLD.EV_REV_ID
        OR (:NEW.EV_REV_ID IS NULL AND :OLD.EV_REV_ID IS NOT NULL)
        OR (:NEW.EV_REV_ID IS NOT NULL AND :OLD.EV_REV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_REV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_REV_EV_ID <> :OLD.EV_REV_EV_ID
        OR (:NEW.EV_REV_EV_ID IS NULL AND :OLD.EV_REV_EV_ID IS NOT NULL)
        OR (:NEW.EV_REV_EV_ID IS NOT NULL AND :OLD.EV_REV_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_REV_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_REV_Event_Revenue, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_REV_Confidence <> :OLD.EV_REV_Confidence
        OR (:NEW.EV_REV_Confidence IS NULL AND :OLD.EV_REV_Confidence IS NOT NULL)
        OR (:NEW.EV_REV_Confidence IS NOT NULL AND :OLD.EV_REV_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_REV_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_REV_Confidence;
    END IF;
    IF (:NEW.EV_REV_Who <> :OLD.EV_REV_Who
        OR (:NEW.EV_REV_Who IS NULL AND :OLD.EV_REV_Who IS NOT NULL)
        OR (:NEW.EV_REV_Who IS NOT NULL AND :OLD.EV_REV_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_REV_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_REV_PositedAt <> :OLD.EV_REV_PositedAt
        OR (:NEW.EV_REV_PositedAt IS NULL AND :OLD.EV_REV_PositedAt IS NOT NULL)
        OR (:NEW.EV_REV_PositedAt IS NOT NULL AND :OLD.EV_REV_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_REV_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_REV_Event_Revenue <> :OLD.EV_REV_Event_Revenue
        OR (:NEW.EV_REV_Event_Revenue IS NULL AND :OLD.EV_REV_Event_Revenue IS NOT NULL)
        OR (:NEW.EV_REV_Event_Revenue IS NOT NULL AND :OLD.EV_REV_Event_Revenue IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_REV <> :OLD.Metadata_EV_REV
        OR (:NEW.Metadata_EV_REV IS NULL AND :OLD.Metadata_EV_REV IS NOT NULL)
        OR (:NEW.Metadata_EV_REV IS NOT NULL AND :OLD.Metadata_EV_REV IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_REV
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_REV_Event_Revenue IS NULL
            OR v_positing_diff
            OR :OLD.EV_REV_Confidence IS NULL
            OR :OLD.EV_REV_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_REV_Who IS NULL
            OR :OLD.EV_REV_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_REV_Event_Revenue(
                    p_owner => COALESCE(:NEW.EV_REV_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_REV_Event_Revenue,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_REV_Event_Revenue IS NULL AND :OLD.EV_REV_Event_Revenue IS NOT NULL THEN
            attributes.ip_EV_REV_Event_Revenue(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_REV_Event_Revenue,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_STA_Event_Status
    IF (:NEW.EV_STA_ID <> :OLD.EV_STA_ID
        OR (:NEW.EV_STA_ID IS NULL AND :OLD.EV_STA_ID IS NOT NULL)
        OR (:NEW.EV_STA_ID IS NOT NULL AND :OLD.EV_STA_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_STA_ID is not updatable.');
    END IF;
    IF (:NEW.EV_STA_EV_ID <> :OLD.EV_STA_EV_ID
        OR (:NEW.EV_STA_EV_ID IS NULL AND :OLD.EV_STA_EV_ID IS NOT NULL)
        OR (:NEW.EV_STA_EV_ID IS NOT NULL AND :OLD.EV_STA_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_STA_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_STA_Event_Status, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_STA_Confidence <> :OLD.EV_STA_Confidence
        OR (:NEW.EV_STA_Confidence IS NULL AND :OLD.EV_STA_Confidence IS NOT NULL)
        OR (:NEW.EV_STA_Confidence IS NOT NULL AND :OLD.EV_STA_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_STA_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_STA_Confidence;
    END IF;
    IF (:NEW.EV_STA_Who <> :OLD.EV_STA_Who
        OR (:NEW.EV_STA_Who IS NULL AND :OLD.EV_STA_Who IS NOT NULL)
        OR (:NEW.EV_STA_Who IS NOT NULL AND :OLD.EV_STA_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_STA_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_STA_PositedAt <> :OLD.EV_STA_PositedAt
        OR (:NEW.EV_STA_PositedAt IS NULL AND :OLD.EV_STA_PositedAt IS NOT NULL)
        OR (:NEW.EV_STA_PositedAt IS NOT NULL AND :OLD.EV_STA_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.EV_STA_ChangedAt <> :OLD.EV_STA_ChangedAt
        OR (:NEW.EV_STA_ChangedAt IS NULL AND :OLD.EV_STA_ChangedAt IS NOT NULL)
        OR (:NEW.EV_STA_ChangedAt IS NOT NULL AND :OLD.EV_STA_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_STA_PositedAt;
    ELSIF v_changing_diff AND :NEW.EV_STA_Event_Status IS NULL THEN
        v_positing := :NEW.EV_STA_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_STA_Event_Status <> :OLD.EV_STA_Event_Status
        OR (:NEW.EV_STA_Event_Status IS NULL AND :OLD.EV_STA_Event_Status IS NOT NULL)
        OR (:NEW.EV_STA_Event_Status IS NOT NULL AND :OLD.EV_STA_Event_Status IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_STA <> :OLD.Metadata_EV_STA
        OR (:NEW.Metadata_EV_STA IS NULL AND :OLD.Metadata_EV_STA IS NOT NULL)
        OR (:NEW.Metadata_EV_STA IS NOT NULL AND :OLD.Metadata_EV_STA IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_STA
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_STA_changing := :NEW.EV_STA_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_STA_changing := :NEW.EV_STA_ChangedAt;
        ELSE
            v_STA_changing := v_now;
        END IF;
        IF :NEW.EV_STA_Event_Status IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_STA_Event_Status IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.EV_STA_Confidence IS NULL
            OR :OLD.EV_STA_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_STA_Who IS NULL
            OR :OLD.EV_STA_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_STA_Event_Status(
                    p_owner => COALESCE(:NEW.EV_STA_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_STA_Event_Status,
                    p_changing => v_STA_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_STA_Event_Status IS NULL AND :OLD.EV_STA_Event_Status IS NOT NULL THEN
            attributes.ip_EV_STA_Event_Status(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_STA_Event_Status,
                p_changing => :OLD.EV_STA_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_UTL_Event_Utilization
    IF (:NEW.EV_UTL_ID <> :OLD.EV_UTL_ID
        OR (:NEW.EV_UTL_ID IS NULL AND :OLD.EV_UTL_ID IS NOT NULL)
        OR (:NEW.EV_UTL_ID IS NOT NULL AND :OLD.EV_UTL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_UTL_ID is not updatable.');
    END IF;
    IF (:NEW.EV_UTL_EV_ID <> :OLD.EV_UTL_EV_ID
        OR (:NEW.EV_UTL_EV_ID IS NULL AND :OLD.EV_UTL_EV_ID IS NOT NULL)
        OR (:NEW.EV_UTL_EV_ID IS NOT NULL AND :OLD.EV_UTL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_UTL_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_UTL_Event_Utilization, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_UTL_Confidence <> :OLD.EV_UTL_Confidence
        OR (:NEW.EV_UTL_Confidence IS NULL AND :OLD.EV_UTL_Confidence IS NOT NULL)
        OR (:NEW.EV_UTL_Confidence IS NOT NULL AND :OLD.EV_UTL_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_UTL_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_UTL_Confidence;
    END IF;
    IF (:NEW.EV_UTL_Who <> :OLD.EV_UTL_Who
        OR (:NEW.EV_UTL_Who IS NULL AND :OLD.EV_UTL_Who IS NOT NULL)
        OR (:NEW.EV_UTL_Who IS NOT NULL AND :OLD.EV_UTL_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_UTL_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_UTL_PositedAt <> :OLD.EV_UTL_PositedAt
        OR (:NEW.EV_UTL_PositedAt IS NULL AND :OLD.EV_UTL_PositedAt IS NOT NULL)
        OR (:NEW.EV_UTL_PositedAt IS NOT NULL AND :OLD.EV_UTL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_UTL_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_UTL_UTL_ID <> :OLD.EV_UTL_UTL_ID
        OR (:NEW.EV_UTL_UTL_ID IS NULL AND :OLD.EV_UTL_UTL_ID IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_ID IS NOT NULL AND :OLD.EV_UTL_UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_UTL <> :OLD.Metadata_EV_UTL
        OR (:NEW.Metadata_EV_UTL IS NULL AND :OLD.Metadata_EV_UTL IS NOT NULL)
        OR (:NEW.Metadata_EV_UTL IS NOT NULL AND :OLD.Metadata_EV_UTL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_UTL
        END, :NEW.Metadata_EV);
    v_knot_diff := CASE WHEN (:NEW.EV_UTL_UTL_Utilization <> :OLD.EV_UTL_UTL_Utilization
        OR (:NEW.EV_UTL_UTL_Utilization IS NULL AND :OLD.EV_UTL_UTL_Utilization IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_Utilization IS NOT NULL AND :OLD.EV_UTL_UTL_Utilization IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_UTL := :NEW.EV_UTL_UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_UTL := NULL;
        IF :NEW.EV_UTL_UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.EV_UTL_UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_UTL := kv.UTL_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_UTL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_UTL_UTL_ID IS NULL
            OR v_positing_diff
            OR :OLD.EV_UTL_Confidence IS NULL
            OR :OLD.EV_UTL_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_UTL_Who IS NULL
            OR :OLD.EV_UTL_Who <> v_positor
            OR :OLD.EV_UTL_UTL_ID <> v_UTL
            THEN
                attributes.ip_EV_UTL_Event_Utilization(
                    p_owner => COALESCE(:NEW.EV_UTL_EV_ID, :NEW.EV_ID),
                    p_value => v_UTL,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.EV_UTL_UTL_ID IS NOT NULL AND (
            :NEW.EV_UTL_UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.EV_UTL_UTL_Utilization IS NULL AND :OLD.EV_UTL_UTL_Utilization IS NOT NULL
            )
        ) THEN
            attributes.ip_EV_UTL_Event_Utilization(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_UTL_UTL_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_LVL_Event_Level
    IF (:NEW.EV_LVL_ID <> :OLD.EV_LVL_ID
        OR (:NEW.EV_LVL_ID IS NULL AND :OLD.EV_LVL_ID IS NOT NULL)
        OR (:NEW.EV_LVL_ID IS NOT NULL AND :OLD.EV_LVL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_LVL_ID is not updatable.');
    END IF;
    IF (:NEW.EV_LVL_EV_ID <> :OLD.EV_LVL_EV_ID
        OR (:NEW.EV_LVL_EV_ID IS NULL AND :OLD.EV_LVL_EV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_EV_ID IS NOT NULL AND :OLD.EV_LVL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_LVL_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_LVL_Event_Level, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_LVL_Confidence <> :OLD.EV_LVL_Confidence
        OR (:NEW.EV_LVL_Confidence IS NULL AND :OLD.EV_LVL_Confidence IS NOT NULL)
        OR (:NEW.EV_LVL_Confidence IS NOT NULL AND :OLD.EV_LVL_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_LVL_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_LVL_Confidence;
    END IF;
    IF (:NEW.EV_LVL_Who <> :OLD.EV_LVL_Who
        OR (:NEW.EV_LVL_Who IS NULL AND :OLD.EV_LVL_Who IS NOT NULL)
        OR (:NEW.EV_LVL_Who IS NOT NULL AND :OLD.EV_LVL_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_LVL_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_LVL_PositedAt <> :OLD.EV_LVL_PositedAt
        OR (:NEW.EV_LVL_PositedAt IS NULL AND :OLD.EV_LVL_PositedAt IS NOT NULL)
        OR (:NEW.EV_LVL_PositedAt IS NOT NULL AND :OLD.EV_LVL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
        OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
        OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_LVL_PositedAt;
    ELSIF v_changing_diff AND :NEW.EV_LVL_PLV_ID IS NULL THEN
        v_positing := :NEW.EV_LVL_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_LVL_PLV_ID <> :OLD.EV_LVL_PLV_ID
        OR (:NEW.EV_LVL_PLV_ID IS NULL AND :OLD.EV_LVL_PLV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_ID IS NOT NULL AND :OLD.EV_LVL_PLV_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_LVL <> :OLD.Metadata_EV_LVL
        OR (:NEW.Metadata_EV_LVL IS NULL AND :OLD.Metadata_EV_LVL IS NOT NULL)
        OR (:NEW.Metadata_EV_LVL IS NOT NULL AND :OLD.Metadata_EV_LVL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_LVL
        END, :NEW.Metadata_EV);
    v_knot_diff := CASE WHEN (:NEW.EV_LVL_PLV_ProfessionalLevel <> :OLD.EV_LVL_PLV_ProfessionalLevel
        OR (:NEW.EV_LVL_PLV_ProfessionalLevel IS NULL AND :OLD.EV_LVL_PLV_ProfessionalLevel IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_ProfessionalLevel IS NOT NULL AND :OLD.EV_LVL_PLV_ProfessionalLevel IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_LVL := :NEW.EV_LVL_PLV_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_LVL := NULL;
        IF :NEW.EV_LVL_PLV_ProfessionalLevel IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    knots.PLV_ProfessionalLevel k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.EV_LVL_PLV_ProfessionalLevel, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_LVL := kv.PLV_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_LVL_changing := :NEW.EV_LVL_ChangedAt;
        ELSIF :OLD.EV_LVL_PLV_ID = v_LVL THEN
            v_LVL_changing := :NEW.EV_LVL_ChangedAt;
        ELSE
            v_LVL_changing := v_now;
        END IF;
        IF v_LVL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_LVL_PLV_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.EV_LVL_Confidence IS NULL
            OR :OLD.EV_LVL_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_LVL_Who IS NULL
            OR :OLD.EV_LVL_Who <> v_positor
            OR :OLD.EV_LVL_PLV_ID <> v_LVL
            THEN
                attributes.ip_EV_LVL_Event_Level(
                    p_owner => COALESCE(:NEW.EV_LVL_EV_ID, :NEW.EV_ID),
                    p_value => v_LVL,
                    p_changing => v_LVL_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.EV_LVL_PLV_ID IS NOT NULL AND (
            :NEW.EV_LVL_PLV_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.EV_LVL_PLV_ProfessionalLevel IS NULL AND :OLD.EV_LVL_PLV_ProfessionalLevel IS NOT NULL
            )
        ) THEN
            attributes.ip_EV_LVL_Event_Level(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_LVL_PLV_ID,
                p_changing => :OLD.EV_LVL_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lEV_Event;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.dt_lEV_Event
INSTEAD OF DELETE ON nexuses.lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of EV_DAT_Event_Date is retracted
    INSERT INTO attributes.EV_DAT_Event_Date_Meta (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_Who,
        EV_DAT_PositedAt,
        EV_DAT_Confidence
    )
    SELECT
        :OLD.Metadata_EV_DAT,
        :OLD.EV_DAT_ID,
        COALESCE(:OLD.EV_DAT_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_DAT_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_DAT_Event_Date_Meta x
            WHERE
                x.EV_DAT_ID = :OLD.EV_DAT_ID
            AND
                x.EV_DAT_Who = COALESCE(:OLD.EV_DAT_Who, :OLD.Who, 0)
            AND
                x.EV_DAT_PositedAt = v_now
        );
    -- what is shown of EV_AUD_Event_Audience is retracted
    INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_Who,
        EV_AUD_PositedAt,
        EV_AUD_Confidence
    )
    SELECT
        :OLD.Metadata_EV_AUD,
        :OLD.EV_AUD_ID,
        COALESCE(:OLD.EV_AUD_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_AUD_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_AUD_Event_Audience_Meta x
            WHERE
                x.EV_AUD_ID = :OLD.EV_AUD_ID
            AND
                x.EV_AUD_Who = COALESCE(:OLD.EV_AUD_Who, :OLD.Who, 0)
            AND
                x.EV_AUD_PositedAt = v_now
        );
    -- what is shown of EV_REV_Event_Revenue is retracted
    INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_Who,
        EV_REV_PositedAt,
        EV_REV_Confidence
    )
    SELECT
        :OLD.Metadata_EV_REV,
        :OLD.EV_REV_ID,
        COALESCE(:OLD.EV_REV_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_REV_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_REV_Event_Revenue_Meta x
            WHERE
                x.EV_REV_ID = :OLD.EV_REV_ID
            AND
                x.EV_REV_Who = COALESCE(:OLD.EV_REV_Who, :OLD.Who, 0)
            AND
                x.EV_REV_PositedAt = v_now
        );
    -- what is shown of EV_STA_Event_Status is retracted
    INSERT INTO attributes.EV_STA_Event_Status_Meta (
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_Who,
        EV_STA_PositedAt,
        EV_STA_Confidence
    )
    SELECT
        :OLD.Metadata_EV_STA,
        :OLD.EV_STA_ID,
        COALESCE(:OLD.EV_STA_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_STA_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_STA_Event_Status_Meta x
            WHERE
                x.EV_STA_ID = :OLD.EV_STA_ID
            AND
                x.EV_STA_Who = COALESCE(:OLD.EV_STA_Who, :OLD.Who, 0)
            AND
                x.EV_STA_PositedAt = v_now
        );
    -- what is shown of EV_UTL_Event_Utilization is retracted
    INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_Who,
        EV_UTL_PositedAt,
        EV_UTL_Confidence
    )
    SELECT
        :OLD.Metadata_EV_UTL,
        :OLD.EV_UTL_ID,
        COALESCE(:OLD.EV_UTL_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_UTL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_UTL_Event_Utilization_Meta x
            WHERE
                x.EV_UTL_ID = :OLD.EV_UTL_ID
            AND
                x.EV_UTL_Who = COALESCE(:OLD.EV_UTL_Who, :OLD.Who, 0)
            AND
                x.EV_UTL_PositedAt = v_now
        );
    -- what is shown of EV_LVL_Event_Level is retracted
    INSERT INTO attributes.EV_LVL_Event_Level_Meta (
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_Who,
        EV_LVL_PositedAt,
        EV_LVL_Confidence
    )
    SELECT
        :OLD.Metadata_EV_LVL,
        :OLD.EV_LVL_ID,
        COALESCE(:OLD.EV_LVL_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_LVL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_LVL_Event_Level_Meta x
            WHERE
                x.EV_LVL_ID = :OLD.EV_LVL_ID
            AND
                x.EV_LVL_Who = COALESCE(:OLD.EV_LVL_Who, :OLD.Who, 0)
            AND
                x.EV_LVL_PositedAt = v_now
        );
END dt_lEV_Event;
/
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled and latest views make them behave like tables.
-- The assembled view has an 'instead of' trigger for insert, which keeps the posit and annex tables. The latest view has
-- three: insert, update, and delete. They propagate such operations to the assembled view in a consistent way. Default
-- values are used for some columns if not provided by the corresponding SQL statements: the positor is 0, the changing and
-- positing times are now, the reliability is 1.
--
-- The rules are the ones of the attributes (see the attribute triggers). A tie that has identifiers and other roles, which
-- are its values, is about the values of the identifiers (at a changing time):
-- a decisive positor holds one assertion at a time for them, so an assertion of other values retracts, at its own positing
-- time, the posit that the positor holds, which is a correction.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- The rules are in procedures, ip_<tie>, and not in triggers on the posit and annex tables, since Oracle does not let a
-- row trigger read the table it is on (ORA-04091), which these rules do. The triggers on the views call them, and so can
-- a load, with the roles and what else is to be stated (what is left out gets its default: the positor is 0, the changing
-- and positing times are now, the reliability is 1):
--
--     BEGIN
--         ip_<tie>(
--             p_<role> => ...,                  one for each role, the identity of the entity or knot
--             p_changing => ...,                a historized tie
--             p_positor => ..., p_positing => ..., p_reliability => ...,
--             p_metadata => ...                 when the model has metadata
--         );
--     END;
--
-- A row put straight into a posit or annex table by an INSERT is not looked at.
--
-- Oracle runs a trigger of this kind for each row, so the rows of an insert are taken in the order they have. Whether a
-- column is set in an UPDATE is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_partner_AC_with_ONG_currently is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_partner_AC_with_ONG_currently (
    p_id IN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_ID%TYPE,
    p_positor IN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_Who%TYPE,
    p_positing IN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_PositedAt%TYPE
) RETURN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_partner_AC_with_ONG_currently_Confidence
        FROM
            ties.AC_partner_AC_with_ONG_currently_Meta a
        WHERE
            a.AC_partner_AC_with_ONG_currently_ID = p_id
        AND
            a.AC_partner_AC_with_ONG_currently_Who = p_positor
        AND
            a.AC_partner_AC_with_ONG_currently_PositedAt <= p_positing
        ORDER BY
            a.AC_partner_AC_with_ONG_currently_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_partner_AC_with_ONG_currently_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_partner_AC_with_ONG_currently;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_partner_AC_with_ONG_currently tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_partner_AC_with_ONG_currently (
    p_id IN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_ID%TYPE,
    p_positor IN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_Who%TYPE,
    p_positing IN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_partner_AC_with_ONG_currently(p_id, p_positor, p_positing), 0.25) <> 0.25 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_partner_AC_with_ONG_currently;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_partner_AC_with_ONG_currently states a posit of AC_partner_AC_with_ONG_currently, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_partner_AC_with_ONG_currently (
    p_AC_partner IN ties.AC_partner_AC_with_ONG_currently_Fact.AC_ID_partner%TYPE,
    p_AC_with IN ties.AC_partner_AC_with_ONG_currently_Fact.AC_ID_with%TYPE,
    p_ONG_currently IN ties.AC_partner_AC_with_ONG_currently_Fact.ONG_ID_currently%TYPE,
    p_changing IN ties.AC_partner_AC_with_ONG_currently_Fact.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_Who%TYPE DEFAULT NULL,
    p_positing IN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_Confidence%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_partner_AC_with_ONG_currently_Meta.Metadata_AC_partner_AC_with_ONG_currently%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_Who%TYPE;
    v_positing ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_PositedAt%TYPE;
    v_reliability ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_Confidence%TYPE;
    v_held ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_Confidence%TYPE;
    v_changing ties.AC_partner_AC_with_ONG_currently_Fact.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_posit ties.AC_partner_AC_with_ONG_currently_Fact.AC_partner_AC_with_ONG_currently_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_partner_AC_with_ONG_currently_Meta.AC_partner_AC_with_ONG_currently_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_partner_AC_with_ONG_currently_Meta (
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_Who,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Meta a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = p_id
                AND
                    a.AC_partner_AC_with_ONG_currently_Who = v_positor
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0.25 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_partner_AC_with_ONG_currently_ID
        FROM
            ties.AC_partner_AC_with_ONG_currently_Fact p
        WHERE
            p.AC_ID_partner = p_AC_partner
        AND
            p.AC_ID_with = p_AC_with
        AND
            p.ONG_ID_currently = p_ONG_currently
        AND
            p.AC_partner_AC_with_ONG_currently_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_partner_AC_with_ONG_currently_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Meta a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = v_posit
                AND
                    a.AC_partner_AC_with_ONG_currently_Who = v_positor
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
                AND
                    a.AC_partner_AC_with_ONG_currently_Confidence <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_partner_AC_with_ONG_currently for: ' ||
                p_AC_partner || ', ' ||
                p_AC_with || ', ' ||
                p_ONG_currently || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Meta a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = v_posit
                AND
                    a.AC_partner_AC_with_ONG_currently_Who = v_positor
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_partner_AC_with_ONG_currently(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_partner_AC_with_ONG_currently_Meta (
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_Who,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_partner_AC_with_ONG_currently_Fact (
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt
        )
        VALUES (
            p_AC_partner,
            p_AC_with,
            p_ONG_currently,
            v_changing
        )
        RETURNING AC_partner_AC_with_ONG_currently_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_partner_AC_with_ONG_currently_Meta (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Who,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_partner_AC_with_ONG_currently instead of INSERT trigger on AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON ties.AC_partner_AC_with_ONG_currently
FOR EACH ROW
BEGIN
    ties.ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => :NEW.ONG_ID_currently,
        p_changing => :NEW.AC_partner_AC_with_ONG_currently_ChangedAt,
        p_positor => :NEW.AC_partner_AC_with_ONG_currently_Who,
        p_positing => :NEW.AC_partner_AC_with_ONG_currently_PositedAt,
        p_reliability => :NEW.AC_partner_AC_with_ONG_currently_Confidence,
        p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
    );
END it_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF v_ONG_currently IS NULL AND :NEW.currently_ONG_Ongoing IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                knots.ONG_Ongoing k
            WHERE
                k.ONG_Ongoing = :NEW.currently_ONG_Ongoing
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_ONG_currently := kv.ONG_ID;
        END LOOP;
    END IF;
    ties.ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => v_ONG_currently,
        p_changing => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Who, :NEW.Who, 0),
        p_positing => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Confidence, 1),
        p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
    );
END it_lAC_partner_AC_with_ONG_currently;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lAC_partner_AC_with_ONG_currently
INSTEAD OF UPDATE ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_positor number(5);
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF (:NEW.currently_ONG_Ongoing <> :OLD.currently_ONG_Ongoing
        OR (:NEW.currently_ONG_Ongoing IS NULL AND :OLD.currently_ONG_Ongoing IS NOT NULL)
        OR (:NEW.currently_ONG_Ongoing IS NOT NULL AND :OLD.currently_ONG_Ongoing IS NULL))
    AND (:NEW.ONG_ID_currently = :OLD.ONG_ID_currently
        OR (:NEW.ONG_ID_currently IS NULL AND :OLD.ONG_ID_currently IS NULL)) THEN
        v_ONG_currently := NULL;
        IF :NEW.currently_ONG_Ongoing IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.ONG_ID
                FROM
                    knots.ONG_Ongoing k
                WHERE
                    k.ONG_Ongoing = :NEW.currently_ONG_Ongoing
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_ONG_currently := kv.ONG_ID;
            END LOOP;
        END IF;
    END IF;
    v_positor := COALESCE(CASE
        WHEN (:NEW.AC_partner_AC_with_ONG_currently_Who <> :OLD.AC_partner_AC_with_ONG_currently_Who
            OR (:NEW.AC_partner_AC_with_ONG_currently_Who IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_Who IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_Who IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_Who IS NULL))
        THEN :NEW.AC_partner_AC_with_ONG_currently_Who
        ELSE :NEW.Who
    END, 0);
    v_positing := CASE
        WHEN (:NEW.AC_partner_AC_with_ONG_currently_PositedAt <> :OLD.AC_partner_AC_with_ONG_currently_PositedAt
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NULL))
        THEN :NEW.AC_partner_AC_with_ONG_currently_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.AC_ID_partner <> :OLD.AC_ID_partner
            OR (:NEW.AC_ID_partner IS NULL AND :OLD.AC_ID_partner IS NOT NULL)
            OR (:NEW.AC_ID_partner IS NOT NULL AND :OLD.AC_ID_partner IS NULL)) OR
        (:NEW.AC_ID_with <> :OLD.AC_ID_with
            OR (:NEW.AC_ID_with IS NULL AND :OLD.AC_ID_with IS NOT NULL)
            OR (:NEW.AC_ID_with IS NOT NULL AND :OLD.AC_ID_with IS NULL)) OR
        (v_ONG_currently <> :OLD.ONG_ID_currently
            OR (v_ONG_currently IS NULL AND :OLD.ONG_ID_currently IS NOT NULL)
            OR (v_ONG_currently IS NOT NULL AND :OLD.ONG_ID_currently IS NULL)) OR
        (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
            OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL)) OR
        (:NEW.AC_partner_AC_with_ONG_currently_PositedAt <> :OLD.AC_partner_AC_with_ONG_currently_PositedAt
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NULL)) OR
        (:NEW.AC_partner_AC_with_ONG_currently_Confidence <> :OLD.AC_partner_AC_with_ONG_currently_Confidence
            OR (:NEW.AC_partner_AC_with_ONG_currently_Confidence IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_Confidence IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_Confidence IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_Confidence IS NULL))
    THEN
        IF
            :NEW.AC_ID_partner IS NOT NULL
        AND
            :NEW.AC_ID_with IS NOT NULL
        AND
            v_ONG_currently IS NOT NULL
        THEN
            ties.ip_AC_partner_AC_with_ONG_currently(
                p_AC_partner => :NEW.AC_ID_partner,
                p_AC_with => :NEW.AC_ID_with,
                p_ONG_currently => v_ONG_currently,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
                        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL))
                    THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt
                    WHEN
                        :NEW.AC_ID_partner = :OLD.AC_ID_partner
                    AND
                        :NEW.AC_ID_with = :OLD.AC_ID_with
                    AND
                        v_ONG_currently = :OLD.ONG_ID_currently
                    THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Confidence, 1),
                p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_AC_partner_AC_with_ONG_currently(
                p_AC_partner => :OLD.AC_ID_partner,
                p_AC_with => :OLD.AC_ID_with,
                p_ONG_currently => :OLD.ONG_ID_currently,
                p_changing => :OLD.AC_partner_AC_with_ONG_currently_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
            );
        END IF;
    END IF;
END ut_lAC_partner_AC_with_ONG_currently;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_partner_AC_with_ONG_currently
INSTEAD OF DELETE ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :OLD.AC_ID_partner,
        p_AC_with => :OLD.AC_ID_with,
        p_ONG_currently => :OLD.ONG_ID_currently,
        p_changing => :OLD.AC_partner_AC_with_ONG_currently_ChangedAt,
        p_positor => COALESCE(:OLD.AC_partner_AC_with_ONG_currently_Who, :OLD.Who, 0),
        p_positing => v_now,
        p_reliability => 0.25,
        p_metadata => :OLD.Metadata_AC_partner_AC_with_ONG_currently
    );
END dt_lAC_partner_AC_with_ONG_currently;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_subset_PN_of is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_subset_PN_of (
    p_id IN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_ID%TYPE,
    p_positor IN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_Who%TYPE,
    p_positing IN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_PositedAt%TYPE
) RETURN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_subset_PN_of_Confidence
        FROM
            ties.AC_subset_PN_of_Meta a
        WHERE
            a.AC_subset_PN_of_ID = p_id
        AND
            a.AC_subset_PN_of_Who = p_positor
        AND
            a.AC_subset_PN_of_PositedAt <= p_positing
        ORDER BY
            a.AC_subset_PN_of_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_subset_PN_of_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_subset_PN_of;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_subset_PN_of tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_subset_PN_of (
    p_id IN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_ID%TYPE,
    p_positor IN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_Who%TYPE,
    p_positing IN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_subset_PN_of(p_id, p_positor, p_positing), 0.25) <> 0.25 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_subset_PN_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_subset_PN_of states a posit of AC_subset_PN_of, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_subset_PN_of (
    p_AC_subset IN ties.AC_subset_PN_of_Fact.AC_ID_subset%TYPE,
    p_PN_of IN ties.AC_subset_PN_of_Fact.PN_ID_of%TYPE,
    p_positor IN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_Who%TYPE DEFAULT NULL,
    p_positing IN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_Confidence%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_subset_PN_of_Meta.Metadata_AC_subset_PN_of%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_subset_PN_of_Meta.AC_subset_PN_of_Who%TYPE;
    v_positing ties.AC_subset_PN_of_Meta.AC_subset_PN_of_PositedAt%TYPE;
    v_reliability ties.AC_subset_PN_of_Meta.AC_subset_PN_of_Confidence%TYPE;
    v_held ties.AC_subset_PN_of_Meta.AC_subset_PN_of_Confidence%TYPE;
    v_posit ties.AC_subset_PN_of_Fact.AC_subset_PN_of_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_subset_PN_of_Meta.AC_subset_PN_of_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_subset_PN_of_Meta (
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_Who,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_subset_PN_of_Meta a
                WHERE
                    a.AC_subset_PN_of_ID = p_id
                AND
                    a.AC_subset_PN_of_Who = v_positor
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    IF v_reliability > 0.25 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_subset_PN_of_ID
        FROM
            ties.AC_subset_PN_of_Fact p
        WHERE
            p.AC_ID_subset = p_AC_subset
        AND
            p.PN_ID_of = p_PN_of
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_subset_PN_of_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_subset_PN_of_Meta a
                WHERE
                    a.AC_subset_PN_of_ID = v_posit
                AND
                    a.AC_subset_PN_of_Who = v_positor
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
                AND
                    a.AC_subset_PN_of_Confidence <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_subset_PN_of for: ' ||
                p_AC_subset || ', ' ||
                p_PN_of || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_subset_PN_of_Meta a
                WHERE
                    a.AC_subset_PN_of_ID = v_posit
                AND
                    a.AC_subset_PN_of_Who = v_positor
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_subset_PN_of(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_subset_PN_of_Meta (
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_Who,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_subset_PN_of_Fact (
            AC_ID_subset,
            PN_ID_of
        )
        VALUES (
            p_AC_subset,
            p_PN_of
        )
        RETURNING AC_subset_PN_of_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_subset_PN_of_Meta (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Who,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_subset_PN_of instead of INSERT trigger on AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_subset_PN_of
INSTEAD OF INSERT ON ties.AC_subset_PN_of
FOR EACH ROW
BEGIN
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
        p_positor => :NEW.AC_subset_PN_of_Who,
        p_positing => :NEW.AC_subset_PN_of_PositedAt,
        p_reliability => :NEW.AC_subset_PN_of_Confidence,
        p_metadata => :NEW.Metadata_AC_subset_PN_of
    );
END it_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_subset_PN_of
INSTEAD OF INSERT ON ties.lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
        p_positor => COALESCE(:NEW.AC_subset_PN_of_Who, :NEW.Who, 0),
        p_positing => COALESCE(:NEW.AC_subset_PN_of_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_subset_PN_of_Confidence, 1),
        p_metadata => :NEW.Metadata_AC_subset_PN_of
    );
END it_lAC_subset_PN_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lAC_subset_PN_of
INSTEAD OF UPDATE ON ties.lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_positor number(5);
BEGIN
    v_positor := COALESCE(CASE
        WHEN (:NEW.AC_subset_PN_of_Who <> :OLD.AC_subset_PN_of_Who
            OR (:NEW.AC_subset_PN_of_Who IS NULL AND :OLD.AC_subset_PN_of_Who IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_Who IS NOT NULL AND :OLD.AC_subset_PN_of_Who IS NULL))
        THEN :NEW.AC_subset_PN_of_Who
        ELSE :NEW.Who
    END, 0);
    v_positing := CASE
        WHEN (:NEW.AC_subset_PN_of_PositedAt <> :OLD.AC_subset_PN_of_PositedAt
            OR (:NEW.AC_subset_PN_of_PositedAt IS NULL AND :OLD.AC_subset_PN_of_PositedAt IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_PositedAt IS NOT NULL AND :OLD.AC_subset_PN_of_PositedAt IS NULL))
        THEN :NEW.AC_subset_PN_of_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.AC_ID_subset <> :OLD.AC_ID_subset
            OR (:NEW.AC_ID_subset IS NULL AND :OLD.AC_ID_subset IS NOT NULL)
            OR (:NEW.AC_ID_subset IS NOT NULL AND :OLD.AC_ID_subset IS NULL)) OR
        (:NEW.PN_ID_of <> :OLD.PN_ID_of
            OR (:NEW.PN_ID_of IS NULL AND :OLD.PN_ID_of IS NOT NULL)
            OR (:NEW.PN_ID_of IS NOT NULL AND :OLD.PN_ID_of IS NULL)) OR
        (:NEW.AC_subset_PN_of_PositedAt <> :OLD.AC_subset_PN_of_PositedAt
            OR (:NEW.AC_subset_PN_of_PositedAt IS NULL AND :OLD.AC_subset_PN_of_PositedAt IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_PositedAt IS NOT NULL AND :OLD.AC_subset_PN_of_PositedAt IS NULL)) OR
        (:NEW.AC_subset_PN_of_Confidence <> :OLD.AC_subset_PN_of_Confidence
            OR (:NEW.AC_subset_PN_of_Confidence IS NULL AND :OLD.AC_subset_PN_of_Confidence IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_Confidence IS NOT NULL AND :OLD.AC_subset_PN_of_Confidence IS NULL))
    THEN
        IF
            :NEW.AC_ID_subset IS NOT NULL
        AND
            :NEW.PN_ID_of IS NOT NULL
        THEN
            ties.ip_AC_subset_PN_of(
                p_AC_subset => :NEW.AC_ID_subset,
                p_PN_of => :NEW.PN_ID_of,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_subset_PN_of_Confidence, 1),
                p_metadata => :NEW.Metadata_AC_subset_PN_of
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_AC_subset_PN_of(
                p_AC_subset => :OLD.AC_ID_subset,
                p_PN_of => :OLD.PN_ID_of,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => :NEW.Metadata_AC_subset_PN_of
            );
        END IF;
    END IF;
END ut_lAC_subset_PN_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_subset_PN_of
INSTEAD OF DELETE ON ties.lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :OLD.AC_ID_subset,
        p_PN_of => :OLD.PN_ID_of,
        p_positor => COALESCE(:OLD.AC_subset_PN_of_Who, :OLD.Who, 0),
        p_positing => v_now,
        p_reliability => 0.25,
        p_metadata => :OLD.Metadata_AC_subset_PN_of
    );
END dt_lAC_subset_PN_of;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_in_AC_wasCast is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_EV_in_AC_wasCast (
    p_id IN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_ID%TYPE,
    p_positor IN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_Who%TYPE,
    p_positing IN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_PositedAt%TYPE
) RETURN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_in_AC_wasCast_Confidence
        FROM
            ties.EV_in_AC_wasCast_Meta a
        WHERE
            a.EV_in_AC_wasCast_ID = p_id
        AND
            a.EV_in_AC_wasCast_Who = p_positor
        AND
            a.EV_in_AC_wasCast_PositedAt <= p_positing
        ORDER BY
            a.EV_in_AC_wasCast_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_in_AC_wasCast_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_in_AC_wasCast;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_EV_in_AC_wasCast tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_EV_in_AC_wasCast (
    p_id IN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_ID%TYPE,
    p_positor IN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_Who%TYPE,
    p_positing IN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_EV_in_AC_wasCast(p_id, p_positor, p_positing), 0.25) <> 0.25 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_EV_in_AC_wasCast;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_in_AC_wasCast states a posit of EV_in_AC_wasCast, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_EV_in_AC_wasCast (
    p_EV_in IN ties.EV_in_AC_wasCast_Fact.EV_ID_in%TYPE,
    p_AC_wasCast IN ties.EV_in_AC_wasCast_Fact.AC_ID_wasCast%TYPE,
    p_positor IN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_Who%TYPE DEFAULT NULL,
    p_positing IN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_Confidence%TYPE DEFAULT NULL,
    p_metadata IN ties.EV_in_AC_wasCast_Meta.Metadata_EV_in_AC_wasCast%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_Who%TYPE;
    v_positing ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_PositedAt%TYPE;
    v_reliability ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_Confidence%TYPE;
    v_held ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_Confidence%TYPE;
    v_posit ties.EV_in_AC_wasCast_Fact.EV_in_AC_wasCast_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.EV_in_AC_wasCast_Meta.EV_in_AC_wasCast_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.EV_in_AC_wasCast_Meta (
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_Who,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.EV_in_AC_wasCast_Meta a
                WHERE
                    a.EV_in_AC_wasCast_ID = p_id
                AND
                    a.EV_in_AC_wasCast_Who = v_positor
                AND
                    a.EV_in_AC_wasCast_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    IF v_reliability > 0.25 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.EV_in_AC_wasCast_ID
        FROM
            ties.EV_in_AC_wasCast_Fact p
        WHERE
            p.EV_ID_in = p_EV_in
        AND
            p.AC_ID_wasCast = p_AC_wasCast
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_in_AC_wasCast_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.EV_in_AC_wasCast_Meta a
                WHERE
                    a.EV_in_AC_wasCast_ID = v_posit
                AND
                    a.EV_in_AC_wasCast_Who = v_positor
                AND
                    a.EV_in_AC_wasCast_PositedAt = v_positing
                AND
                    a.EV_in_AC_wasCast_Confidence <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_in_AC_wasCast for: ' ||
                p_EV_in || ', ' ||
                p_AC_wasCast || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.EV_in_AC_wasCast_Meta a
                WHERE
                    a.EV_in_AC_wasCast_ID = v_posit
                AND
                    a.EV_in_AC_wasCast_Who = v_positor
                AND
                    a.EV_in_AC_wasCast_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_EV_in_AC_wasCast(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO ties.EV_in_AC_wasCast_Meta (
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_Who,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.EV_in_AC_wasCast_Fact (
            EV_ID_in,
            AC_ID_wasCast
        )
        VALUES (
            p_EV_in,
            p_AC_wasCast
        )
        RETURNING EV_in_AC_wasCast_ID INTO v_posit;
    END IF;
    INSERT INTO ties.EV_in_AC_wasCast_Meta (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_Who,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_in_AC_wasCast;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_in_AC_wasCast instead of INSERT trigger on EV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_EV_in_AC_wasCast
INSTEAD OF INSERT ON ties.EV_in_AC_wasCast
FOR EACH ROW
BEGIN
    ties.ip_EV_in_AC_wasCast(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_wasCast => :NEW.AC_ID_wasCast,
        p_positor => :NEW.EV_in_AC_wasCast_Who,
        p_positing => :NEW.EV_in_AC_wasCast_PositedAt,
        p_reliability => :NEW.EV_in_AC_wasCast_Confidence,
        p_metadata => :NEW.Metadata_EV_in_AC_wasCast
    );
END it_EV_in_AC_wasCast;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lEV_in_AC_wasCast
INSTEAD OF INSERT ON ties.lEV_in_AC_wasCast
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_EV_in_AC_wasCast(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_wasCast => :NEW.AC_ID_wasCast,
        p_positor => COALESCE(:NEW.EV_in_AC_wasCast_Who, :NEW.Who, 0),
        p_positing => COALESCE(:NEW.EV_in_AC_wasCast_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.EV_in_AC_wasCast_Confidence, 1),
        p_metadata => :NEW.Metadata_EV_in_AC_wasCast
    );
END it_lEV_in_AC_wasCast;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lEV_in_AC_wasCast
INSTEAD OF DELETE ON ties.lEV_in_AC_wasCast
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_EV_in_AC_wasCast(
        p_EV_in => :OLD.EV_ID_in,
        p_AC_wasCast => :OLD.AC_ID_wasCast,
        p_positor => COALESCE(:OLD.EV_in_AC_wasCast_Who, :OLD.Who, 0),
        p_positing => v_now,
        p_reliability => 0.25,
        p_metadata => :OLD.Metadata_EV_in_AC_wasCast
    );
END dt_lEV_in_AC_wasCast;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_part_PR_in_RAT_got is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_part_PR_in_RAT_got (
    p_id IN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_ID%TYPE,
    p_positor IN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_Who%TYPE,
    p_positing IN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_PositedAt%TYPE
) RETURN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_part_PR_in_RAT_got_Confidence
        FROM
            ties.AC_part_PR_in_RAT_got_Meta a
        WHERE
            a.AC_part_PR_in_RAT_got_ID = p_id
        AND
            a.AC_part_PR_in_RAT_got_Who = p_positor
        AND
            a.AC_part_PR_in_RAT_got_PositedAt <= p_positing
        ORDER BY
            a.AC_part_PR_in_RAT_got_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_part_PR_in_RAT_got_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_part_PR_in_RAT_got;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_part_PR_in_RAT_got tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_part_PR_in_RAT_got (
    p_id IN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_ID%TYPE,
    p_positor IN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_Who%TYPE,
    p_positing IN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_part_PR_in_RAT_got(p_id, p_positor, p_positing), 0.25) <> 0.25 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_part_PR_in_RAT_got;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_part_PR_in_RAT_got states a posit of AC_part_PR_in_RAT_got, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_part_PR_in_RAT_got (
    p_AC_part IN ties.AC_part_PR_in_RAT_got_Fact.AC_ID_part%TYPE,
    p_PR_in IN ties.AC_part_PR_in_RAT_got_Fact.PR_ID_in%TYPE,
    p_RAT_got IN ties.AC_part_PR_in_RAT_got_Fact.RAT_ID_got%TYPE,
    p_changing IN ties.AC_part_PR_in_RAT_got_Fact.AC_part_PR_in_RAT_got_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_Who%TYPE DEFAULT NULL,
    p_positing IN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_Confidence%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_part_PR_in_RAT_got_Meta.Metadata_AC_part_PR_in_RAT_got%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_Who%TYPE;
    v_positing ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_PositedAt%TYPE;
    v_reliability ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_Confidence%TYPE;
    v_held ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_Confidence%TYPE;
    v_changing ties.AC_part_PR_in_RAT_got_Fact.AC_part_PR_in_RAT_got_ChangedAt%TYPE;
    v_posit ties.AC_part_PR_in_RAT_got_Fact.AC_part_PR_in_RAT_got_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_part_PR_in_RAT_got_Meta.AC_part_PR_in_RAT_got_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_part_PR_in_RAT_got_Meta (
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_Who,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_part_PR_in_RAT_got_Meta a
                WHERE
                    a.AC_part_PR_in_RAT_got_ID = p_id
                AND
                    a.AC_part_PR_in_RAT_got_Who = v_positor
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0.25 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_part_PR_in_RAT_got_ID
        FROM
            ties.AC_part_PR_in_RAT_got_Fact p
        WHERE
            p.AC_ID_part = p_AC_part
        AND
            p.PR_ID_in = p_PR_in
        AND
            p.RAT_ID_got = p_RAT_got
        AND
            p.AC_part_PR_in_RAT_got_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_part_PR_in_RAT_got_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_part_PR_in_RAT_got_Meta a
                WHERE
                    a.AC_part_PR_in_RAT_got_ID = v_posit
                AND
                    a.AC_part_PR_in_RAT_got_Who = v_positor
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
                AND
                    a.AC_part_PR_in_RAT_got_Confidence <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_part_PR_in_RAT_got for: ' ||
                p_AC_part || ', ' ||
                p_PR_in || ', ' ||
                p_RAT_got || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, are other values for identifiers that already have
    -- values (at that time), asserted by the positor at the positing time
    IF v_reliability <> 0.25 THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_part_PR_in_RAT_got_Fact p
                JOIN
                    ties.AC_part_PR_in_RAT_got_Meta a
                ON
                    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
                WHERE
                    p.AC_ID_part = p_AC_part
                AND
                    p.PR_ID_in = p_PR_in
                AND
                    p.AC_part_PR_in_RAT_got_ChangedAt = v_changing
                AND
                    NOT (
                        p.RAT_ID_got = p_RAT_got
                    )
                AND
                    a.AC_part_PR_in_RAT_got_Who = v_positor
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
                AND
                    a.AC_part_PR_in_RAT_got_Confidence <> 0.25
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_part_PR_in_RAT_got for: ' ||
                p_AC_part || ', ' ||
                p_PR_in || ', ' ||
                p_RAT_got || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_part_PR_in_RAT_got_Meta a
                WHERE
                    a.AC_part_PR_in_RAT_got_ID = v_posit
                AND
                    a.AC_part_PR_in_RAT_got_Who = v_positor
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_part_PR_in_RAT_got(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_part_PR_in_RAT_got_Meta (
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_Who,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same identifiers (and changing time), when that has other values: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_part_PR_in_RAT_got_ID
        FROM
            ties.AC_part_PR_in_RAT_got_Fact p
        WHERE
            p.AC_ID_part = p_AC_part
        AND
            p.PR_ID_in = p_PR_in
        AND
            p.AC_part_PR_in_RAT_got_ChangedAt = v_changing
        AND
            NOT (
                p.RAT_ID_got = p_RAT_got
            )
        AND
            ties.ie_AC_part_PR_in_RAT_got(p.AC_part_PR_in_RAT_got_ID, v_positor, v_positing) = 1
    ) LOOP
        retract(r.AC_part_PR_in_RAT_got_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_part_PR_in_RAT_got_Fact (
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got,
            AC_part_PR_in_RAT_got_ChangedAt
        )
        VALUES (
            p_AC_part,
            p_PR_in,
            p_RAT_got,
            v_changing
        )
        RETURNING AC_part_PR_in_RAT_got_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_part_PR_in_RAT_got_Meta (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Who,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_part_PR_in_RAT_got;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_part_PR_in_RAT_got instead of INSERT trigger on AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_part_PR_in_RAT_got
INSTEAD OF INSERT ON ties.AC_part_PR_in_RAT_got
FOR EACH ROW
BEGIN
    ties.ip_AC_part_PR_in_RAT_got(
        p_AC_part => :NEW.AC_ID_part,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_got => :NEW.RAT_ID_got,
        p_changing => :NEW.AC_part_PR_in_RAT_got_ChangedAt,
        p_positor => :NEW.AC_part_PR_in_RAT_got_Who,
        p_positing => :NEW.AC_part_PR_in_RAT_got_PositedAt,
        p_reliability => :NEW.AC_part_PR_in_RAT_got_Confidence,
        p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
    );
END it_AC_part_PR_in_RAT_got;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_part_PR_in_RAT_got
INSTEAD OF INSERT ON ties.lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_RAT_got number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_RAT_got := :NEW.RAT_ID_got;
    IF v_RAT_got IS NULL AND :NEW.got_RAT_Rating IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                knots.RAT_Rating k
            WHERE
                k.RAT_Checksum = STANDARD_HASH(:NEW.got_RAT_Rating, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_RAT_got := kv.RAT_ID;
        END LOOP;
    END IF;
    ties.ip_AC_part_PR_in_RAT_got(
        p_AC_part => :NEW.AC_ID_part,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_got => v_RAT_got,
        p_changing => COALESCE(:NEW.AC_part_PR_in_RAT_got_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.AC_part_PR_in_RAT_got_Who, :NEW.Who, 0),
        p_positing => COALESCE(:NEW.AC_part_PR_in_RAT_got_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_part_PR_in_RAT_got_Confidence, 1),
        p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
    );
END it_lAC_part_PR_in_RAT_got;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lAC_part_PR_in_RAT_got
INSTEAD OF UPDATE ON ties.lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_positor number(5);
    v_RAT_got number(3);
BEGIN
    IF (:NEW.AC_ID_part <> :OLD.AC_ID_part
        OR (:NEW.AC_ID_part IS NULL AND :OLD.AC_ID_part IS NOT NULL)
        OR (:NEW.AC_ID_part IS NOT NULL AND :OLD.AC_ID_part IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID_part is not updatable.');
    END IF;
    IF (:NEW.PR_ID_in <> :OLD.PR_ID_in
        OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
        OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID_in is not updatable.');
    END IF;
    -- the identity of the knot value, given as it is or looked up from the value
    v_RAT_got := :NEW.RAT_ID_got;
    IF (:NEW.got_RAT_Rating <> :OLD.got_RAT_Rating
        OR (:NEW.got_RAT_Rating IS NULL AND :OLD.got_RAT_Rating IS NOT NULL)
        OR (:NEW.got_RAT_Rating IS NOT NULL AND :OLD.got_RAT_Rating IS NULL))
    AND (:NEW.RAT_ID_got = :OLD.RAT_ID_got
        OR (:NEW.RAT_ID_got IS NULL AND :OLD.RAT_ID_got IS NULL)) THEN
        v_RAT_got := NULL;
        IF :NEW.got_RAT_Rating IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.RAT_ID
                FROM
                    knots.RAT_Rating k
                WHERE
                    k.RAT_Checksum = STANDARD_HASH(:NEW.got_RAT_Rating, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_RAT_got := kv.RAT_ID;
            END LOOP;
        END IF;
    END IF;
    v_positor := COALESCE(CASE
        WHEN (:NEW.AC_part_PR_in_RAT_got_Who <> :OLD.AC_part_PR_in_RAT_got_Who
            OR (:NEW.AC_part_PR_in_RAT_got_Who IS NULL AND :OLD.AC_part_PR_in_RAT_got_Who IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_Who IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_Who IS NULL))
        THEN :NEW.AC_part_PR_in_RAT_got_Who
        ELSE :NEW.Who
    END, 0);
    v_positing := CASE
        WHEN (:NEW.AC_part_PR_in_RAT_got_PositedAt <> :OLD.AC_part_PR_in_RAT_got_PositedAt
            OR (:NEW.AC_part_PR_in_RAT_got_PositedAt IS NULL AND :OLD.AC_part_PR_in_RAT_got_PositedAt IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_PositedAt IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_PositedAt IS NULL))
        THEN :NEW.AC_part_PR_in_RAT_got_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.AC_ID_part <> :OLD.AC_ID_part
            OR (:NEW.AC_ID_part IS NULL AND :OLD.AC_ID_part IS NOT NULL)
            OR (:NEW.AC_ID_part IS NOT NULL AND :OLD.AC_ID_part IS NULL)) OR
        (:NEW.PR_ID_in <> :OLD.PR_ID_in
            OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
            OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL)) OR
        (v_RAT_got <> :OLD.RAT_ID_got
            OR (v_RAT_got IS NULL AND :OLD.RAT_ID_got IS NOT NULL)
            OR (v_RAT_got IS NOT NULL AND :OLD.RAT_ID_got IS NULL)) OR
        (:NEW.AC_part_PR_in_RAT_got_ChangedAt <> :OLD.AC_part_PR_in_RAT_got_ChangedAt
            OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NULL)) OR
        (:NEW.AC_part_PR_in_RAT_got_PositedAt <> :OLD.AC_part_PR_in_RAT_got_PositedAt
            OR (:NEW.AC_part_PR_in_RAT_got_PositedAt IS NULL AND :OLD.AC_part_PR_in_RAT_got_PositedAt IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_PositedAt IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_PositedAt IS NULL)) OR
        (:NEW.AC_part_PR_in_RAT_got_Confidence <> :OLD.AC_part_PR_in_RAT_got_Confidence
            OR (:NEW.AC_part_PR_in_RAT_got_Confidence IS NULL AND :OLD.AC_part_PR_in_RAT_got_Confidence IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_Confidence IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_Confidence IS NULL))
    THEN
        IF
            :NEW.AC_ID_part IS NOT NULL
        AND
            :NEW.PR_ID_in IS NOT NULL
        AND
            v_RAT_got IS NOT NULL
        THEN
            ties.ip_AC_part_PR_in_RAT_got(
                p_AC_part => :NEW.AC_ID_part,
                p_PR_in => :NEW.PR_ID_in,
                p_RAT_got => v_RAT_got,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.AC_part_PR_in_RAT_got_ChangedAt <> :OLD.AC_part_PR_in_RAT_got_ChangedAt
                        OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NULL))
                    THEN :NEW.AC_part_PR_in_RAT_got_ChangedAt
                    WHEN
                        :NEW.AC_ID_part = :OLD.AC_ID_part
                    AND
                        :NEW.PR_ID_in = :OLD.PR_ID_in
                    AND
                        v_RAT_got = :OLD.RAT_ID_got
                    THEN :NEW.AC_part_PR_in_RAT_got_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_part_PR_in_RAT_got_Confidence, 1),
                p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_AC_part_PR_in_RAT_got(
                p_AC_part => :OLD.AC_ID_part,
                p_PR_in => :OLD.PR_ID_in,
                p_RAT_got => :OLD.RAT_ID_got,
                p_changing => :OLD.AC_part_PR_in_RAT_got_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
            );
        END IF;
    END IF;
END ut_lAC_part_PR_in_RAT_got;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_part_PR_in_RAT_got
INSTEAD OF DELETE ON ties.lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_part_PR_in_RAT_got(
        p_AC_part => :OLD.AC_ID_part,
        p_PR_in => :OLD.PR_ID_in,
        p_RAT_got => :OLD.RAT_ID_got,
        p_changing => :OLD.AC_part_PR_in_RAT_got_ChangedAt,
        p_positor => COALESCE(:OLD.AC_part_PR_in_RAT_got_Who, :OLD.Who, 0),
        p_positing => v_now,
        p_reliability => 0.25,
        p_metadata => :OLD.Metadata_AC_part_PR_in_RAT_got
    );
END dt_lAC_part_PR_in_RAT_got;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_at_PR_isPlaying is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_ST_at_PR_isPlaying (
    p_id IN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_ID%TYPE,
    p_positor IN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_Who%TYPE,
    p_positing IN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_PositedAt%TYPE
) RETURN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_at_PR_isPlaying_Confidence
        FROM
            ties.ST_at_PR_isPlaying_Meta a
        WHERE
            a.ST_at_PR_isPlaying_ID = p_id
        AND
            a.ST_at_PR_isPlaying_Who = p_positor
        AND
            a.ST_at_PR_isPlaying_PositedAt <= p_positing
        ORDER BY
            a.ST_at_PR_isPlaying_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_at_PR_isPlaying_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_at_PR_isPlaying;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_ST_at_PR_isPlaying tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_ST_at_PR_isPlaying (
    p_id IN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_ID%TYPE,
    p_positor IN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_Who%TYPE,
    p_positing IN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_ST_at_PR_isPlaying(p_id, p_positor, p_positing), 0.25) <> 0.25 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_ST_at_PR_isPlaying;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_at_PR_isPlaying states a posit of ST_at_PR_isPlaying, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_ST_at_PR_isPlaying (
    p_ST_at IN ties.ST_at_PR_isPlaying_Fact.ST_ID_at%TYPE,
    p_PR_isPlaying IN ties.ST_at_PR_isPlaying_Fact.PR_ID_isPlaying%TYPE,
    p_changing IN ties.ST_at_PR_isPlaying_Fact.ST_at_PR_isPlaying_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_Who%TYPE DEFAULT NULL,
    p_positing IN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_Confidence%TYPE DEFAULT NULL,
    p_metadata IN ties.ST_at_PR_isPlaying_Meta.Metadata_ST_at_PR_isPlaying%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_Who%TYPE;
    v_positing ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_PositedAt%TYPE;
    v_reliability ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_Confidence%TYPE;
    v_held ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_Confidence%TYPE;
    v_changing ties.ST_at_PR_isPlaying_Fact.ST_at_PR_isPlaying_ChangedAt%TYPE;
    v_posit ties.ST_at_PR_isPlaying_Fact.ST_at_PR_isPlaying_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.ST_at_PR_isPlaying_Meta.ST_at_PR_isPlaying_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.ST_at_PR_isPlaying_Meta (
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_Who,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.ST_at_PR_isPlaying_Meta a
                WHERE
                    a.ST_at_PR_isPlaying_ID = p_id
                AND
                    a.ST_at_PR_isPlaying_Who = v_positor
                AND
                    a.ST_at_PR_isPlaying_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0.25 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.ST_at_PR_isPlaying_ID
        FROM
            ties.ST_at_PR_isPlaying_Fact p
        WHERE
            p.ST_ID_at = p_ST_at
        AND
            p.PR_ID_isPlaying = p_PR_isPlaying
        AND
            p.ST_at_PR_isPlaying_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_at_PR_isPlaying_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.ST_at_PR_isPlaying_Meta a
                WHERE
                    a.ST_at_PR_isPlaying_ID = v_posit
                AND
                    a.ST_at_PR_isPlaying_Who = v_positor
                AND
                    a.ST_at_PR_isPlaying_PositedAt = v_positing
                AND
                    a.ST_at_PR_isPlaying_Confidence <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_at_PR_isPlaying for: ' ||
                p_ST_at || ', ' ||
                p_PR_isPlaying || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.ST_at_PR_isPlaying_Meta a
                WHERE
                    a.ST_at_PR_isPlaying_ID = v_posit
                AND
                    a.ST_at_PR_isPlaying_Who = v_positor
                AND
                    a.ST_at_PR_isPlaying_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_ST_at_PR_isPlaying(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO ties.ST_at_PR_isPlaying_Meta (
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_Who,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.ST_at_PR_isPlaying_Fact (
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt
        )
        VALUES (
            p_ST_at,
            p_PR_isPlaying,
            v_changing
        )
        RETURNING ST_at_PR_isPlaying_ID INTO v_posit;
    END IF;
    INSERT INTO ties.ST_at_PR_isPlaying_Meta (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_Who,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_at_PR_isPlaying;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_at_PR_isPlaying instead of INSERT trigger on ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_ST_at_PR_isPlaying
INSTEAD OF INSERT ON ties.ST_at_PR_isPlaying
FOR EACH ROW
BEGIN
    ties.ip_ST_at_PR_isPlaying(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_isPlaying => :NEW.PR_ID_isPlaying,
        p_changing => :NEW.ST_at_PR_isPlaying_ChangedAt,
        p_positor => :NEW.ST_at_PR_isPlaying_Who,
        p_positing => :NEW.ST_at_PR_isPlaying_PositedAt,
        p_reliability => :NEW.ST_at_PR_isPlaying_Confidence,
        p_metadata => :NEW.Metadata_ST_at_PR_isPlaying
    );
END it_ST_at_PR_isPlaying;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lST_at_PR_isPlaying
INSTEAD OF INSERT ON ties.lST_at_PR_isPlaying
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_ST_at_PR_isPlaying(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_isPlaying => :NEW.PR_ID_isPlaying,
        p_changing => COALESCE(:NEW.ST_at_PR_isPlaying_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.ST_at_PR_isPlaying_Who, :NEW.Who, 0),
        p_positing => COALESCE(:NEW.ST_at_PR_isPlaying_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.ST_at_PR_isPlaying_Confidence, 1),
        p_metadata => :NEW.Metadata_ST_at_PR_isPlaying
    );
END it_lST_at_PR_isPlaying;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lST_at_PR_isPlaying
INSTEAD OF DELETE ON ties.lST_at_PR_isPlaying
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_ST_at_PR_isPlaying(
        p_ST_at => :OLD.ST_ID_at,
        p_PR_isPlaying => :OLD.PR_ID_isPlaying,
        p_changing => :OLD.ST_at_PR_isPlaying_ChangedAt,
        p_positor => COALESCE(:OLD.ST_at_PR_isPlaying_Who, :OLD.Who, 0),
        p_positing => v_now,
        p_reliability => 0.25,
        p_metadata => :OLD.Metadata_ST_at_PR_isPlaying
    );
END dt_lST_at_PR_isPlaying;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_parent_AC_child_PAT_having is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_parent_AC_child_PAT_having (
    p_id IN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_ID%TYPE,
    p_positor IN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_Who%TYPE,
    p_positing IN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_PositedAt%TYPE
) RETURN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_parent_AC_child_PAT_having_Confidence
        FROM
            ties.AC_parent_AC_child_PAT_having_Meta a
        WHERE
            a.AC_parent_AC_child_PAT_having_ID = p_id
        AND
            a.AC_parent_AC_child_PAT_having_Who = p_positor
        AND
            a.AC_parent_AC_child_PAT_having_PositedAt <= p_positing
        ORDER BY
            a.AC_parent_AC_child_PAT_having_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_parent_AC_child_PAT_having_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_parent_AC_child_PAT_having;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_parent_AC_child_PAT_having tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_parent_AC_child_PAT_having (
    p_id IN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_ID%TYPE,
    p_positor IN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_Who%TYPE,
    p_positing IN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_parent_AC_child_PAT_having(p_id, p_positor, p_positing), 0.25) <> 0.25 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_parent_AC_child_PAT_having;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_parent_AC_child_PAT_having states a posit of AC_parent_AC_child_PAT_having, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_parent_AC_child_PAT_having (
    p_AC_parent IN ties.AC_parent_AC_child_PAT_having_Fact.AC_ID_parent%TYPE,
    p_AC_child IN ties.AC_parent_AC_child_PAT_having_Fact.AC_ID_child%TYPE,
    p_PAT_having IN ties.AC_parent_AC_child_PAT_having_Fact.PAT_ID_having%TYPE,
    p_positor IN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_Who%TYPE DEFAULT NULL,
    p_positing IN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_Confidence%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_parent_AC_child_PAT_having_Meta.Metadata_AC_parent_AC_child_PAT_having%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_Who%TYPE;
    v_positing ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_PositedAt%TYPE;
    v_reliability ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_Confidence%TYPE;
    v_held ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_Confidence%TYPE;
    v_posit ties.AC_parent_AC_child_PAT_having_Fact.AC_parent_AC_child_PAT_having_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_parent_AC_child_PAT_having_Meta.AC_parent_AC_child_PAT_having_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_parent_AC_child_PAT_having_Meta (
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_Who,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_parent_AC_child_PAT_having_Meta a
                WHERE
                    a.AC_parent_AC_child_PAT_having_ID = p_id
                AND
                    a.AC_parent_AC_child_PAT_having_Who = v_positor
                AND
                    a.AC_parent_AC_child_PAT_having_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    IF v_reliability > 0.25 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_parent_AC_child_PAT_having_ID
        FROM
            ties.AC_parent_AC_child_PAT_having_Fact p
        WHERE
            p.AC_ID_parent = p_AC_parent
        AND
            p.AC_ID_child = p_AC_child
        AND
            p.PAT_ID_having = p_PAT_having
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_parent_AC_child_PAT_having_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_parent_AC_child_PAT_having_Meta a
                WHERE
                    a.AC_parent_AC_child_PAT_having_ID = v_posit
                AND
                    a.AC_parent_AC_child_PAT_having_Who = v_positor
                AND
                    a.AC_parent_AC_child_PAT_having_PositedAt = v_positing
                AND
                    a.AC_parent_AC_child_PAT_having_Confidence <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_parent_AC_child_PAT_having for: ' ||
                p_AC_parent || ', ' ||
                p_AC_child || ', ' ||
                p_PAT_having || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_parent_AC_child_PAT_having_Meta a
                WHERE
                    a.AC_parent_AC_child_PAT_having_ID = v_posit
                AND
                    a.AC_parent_AC_child_PAT_having_Who = v_positor
                AND
                    a.AC_parent_AC_child_PAT_having_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_parent_AC_child_PAT_having(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_parent_AC_child_PAT_having_Meta (
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_Who,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_parent_AC_child_PAT_having_Fact (
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having
        )
        VALUES (
            p_AC_parent,
            p_AC_child,
            p_PAT_having
        )
        RETURNING AC_parent_AC_child_PAT_having_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_parent_AC_child_PAT_having_Meta (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_Who,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_parent_AC_child_PAT_having;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_parent_AC_child_PAT_having instead of INSERT trigger on AC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_parent_AC_child_PAT_having
INSTEAD OF INSERT ON ties.AC_parent_AC_child_PAT_having
FOR EACH ROW
BEGIN
    ties.ip_AC_parent_AC_child_PAT_having(
        p_AC_parent => :NEW.AC_ID_parent,
        p_AC_child => :NEW.AC_ID_child,
        p_PAT_having => :NEW.PAT_ID_having,
        p_positor => :NEW.AC_parent_AC_child_PAT_having_Who,
        p_positing => :NEW.AC_parent_AC_child_PAT_having_PositedAt,
        p_reliability => :NEW.AC_parent_AC_child_PAT_having_Confidence,
        p_metadata => :NEW.Metadata_AC_parent_AC_child_PAT_having
    );
END it_AC_parent_AC_child_PAT_having;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_parent_AC_child_PAT_having
INSTEAD OF INSERT ON ties.lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_PAT_having number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_PAT_having := :NEW.PAT_ID_having;
    IF v_PAT_having IS NULL AND :NEW.having_PAT_ParentalType IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PAT_ID
            FROM
                knots.PAT_ParentalType k
            WHERE
                k.PAT_ParentalType = :NEW.having_PAT_ParentalType
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PAT_having := kv.PAT_ID;
        END LOOP;
    END IF;
    ties.ip_AC_parent_AC_child_PAT_having(
        p_AC_parent => :NEW.AC_ID_parent,
        p_AC_child => :NEW.AC_ID_child,
        p_PAT_having => v_PAT_having,
        p_positor => COALESCE(:NEW.AC_parent_AC_child_PAT_having_Who, :NEW.Who, 0),
        p_positing => COALESCE(:NEW.AC_parent_AC_child_PAT_having_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_parent_AC_child_PAT_having_Confidence, 1),
        p_metadata => :NEW.Metadata_AC_parent_AC_child_PAT_having
    );
END it_lAC_parent_AC_child_PAT_having;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_parent_AC_child_PAT_having
INSTEAD OF DELETE ON ties.lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_parent_AC_child_PAT_having(
        p_AC_parent => :OLD.AC_ID_parent,
        p_AC_child => :OLD.AC_ID_child,
        p_PAT_having => :OLD.PAT_ID_having,
        p_positor => COALESCE(:OLD.AC_parent_AC_child_PAT_having_Who, :OLD.Who, 0),
        p_positing => v_now,
        p_reliability => 0.25,
        p_metadata => :OLD.Metadata_AC_parent_AC_child_PAT_having
    );
END dt_lAC_parent_AC_child_PAT_having;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_content_ST_location_EV_of is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_PR_content_ST_location_EV_of (
    p_id IN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_ID%TYPE,
    p_positor IN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_Who%TYPE,
    p_positing IN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_PositedAt%TYPE
) RETURN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_content_ST_location_EV_of_Confidence
        FROM
            ties.PR_content_ST_location_EV_of_Meta a
        WHERE
            a.PR_content_ST_location_EV_of_ID = p_id
        AND
            a.PR_content_ST_location_EV_of_Who = p_positor
        AND
            a.PR_content_ST_location_EV_of_PositedAt <= p_positing
        ORDER BY
            a.PR_content_ST_location_EV_of_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_content_ST_location_EV_of_Confidence;
    END LOOP;
    RETURN NULL;
END he_PR_content_ST_location_EV_of;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_PR_content_ST_location_EV_of tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_PR_content_ST_location_EV_of (
    p_id IN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_ID%TYPE,
    p_positor IN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_Who%TYPE,
    p_positing IN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_PR_content_ST_location_EV_of(p_id, p_positor, p_positing), 0.25) <> 0.25 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_PR_content_ST_location_EV_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_content_ST_location_EV_of states a posit of PR_content_ST_location_EV_of, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_PR_content_ST_location_EV_of (
    p_PR_content IN ties.PR_content_ST_location_EV_of_Fact.PR_ID_content%TYPE,
    p_ST_location IN ties.PR_content_ST_location_EV_of_Fact.ST_ID_location%TYPE,
    p_EV_of IN ties.PR_content_ST_location_EV_of_Fact.EV_ID_of%TYPE,
    p_changing IN ties.PR_content_ST_location_EV_of_Fact.PR_content_ST_location_EV_of_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_Who%TYPE DEFAULT NULL,
    p_positing IN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_Confidence%TYPE DEFAULT NULL,
    p_metadata IN ties.PR_content_ST_location_EV_of_Meta.Metadata_PR_content_ST_location_EV_of%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_Who%TYPE;
    v_positing ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_PositedAt%TYPE;
    v_reliability ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_Confidence%TYPE;
    v_held ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_Confidence%TYPE;
    v_changing ties.PR_content_ST_location_EV_of_Fact.PR_content_ST_location_EV_of_ChangedAt%TYPE;
    v_posit ties.PR_content_ST_location_EV_of_Fact.PR_content_ST_location_EV_of_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.PR_content_ST_location_EV_of_Meta.PR_content_ST_location_EV_of_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.PR_content_ST_location_EV_of_Meta (
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_Who,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.PR_content_ST_location_EV_of_Meta a
                WHERE
                    a.PR_content_ST_location_EV_of_ID = p_id
                AND
                    a.PR_content_ST_location_EV_of_Who = v_positor
                AND
                    a.PR_content_ST_location_EV_of_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0.25 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.PR_content_ST_location_EV_of_ID
        FROM
            ties.PR_content_ST_location_EV_of_Fact p
        WHERE
            p.PR_ID_content = p_PR_content
        AND
            p.ST_ID_location = p_ST_location
        AND
            p.EV_ID_of = p_EV_of
        AND
            p.PR_content_ST_location_EV_of_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_content_ST_location_EV_of_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.PR_content_ST_location_EV_of_Meta a
                WHERE
                    a.PR_content_ST_location_EV_of_ID = v_posit
                AND
                    a.PR_content_ST_location_EV_of_Who = v_positor
                AND
                    a.PR_content_ST_location_EV_of_PositedAt = v_positing
                AND
                    a.PR_content_ST_location_EV_of_Confidence <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_content_ST_location_EV_of for: ' ||
                p_PR_content || ', ' ||
                p_ST_location || ', ' ||
                p_EV_of || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.PR_content_ST_location_EV_of_Meta a
                WHERE
                    a.PR_content_ST_location_EV_of_ID = v_posit
                AND
                    a.PR_content_ST_location_EV_of_Who = v_positor
                AND
                    a.PR_content_ST_location_EV_of_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_PR_content_ST_location_EV_of(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO ties.PR_content_ST_location_EV_of_Meta (
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_Who,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.PR_content_ST_location_EV_of_Fact (
            PR_ID_content,
            ST_ID_location,
            EV_ID_of,
            PR_content_ST_location_EV_of_ChangedAt
        )
        VALUES (
            p_PR_content,
            p_ST_location,
            p_EV_of,
            v_changing
        )
        RETURNING PR_content_ST_location_EV_of_ID INTO v_posit;
    END IF;
    INSERT INTO ties.PR_content_ST_location_EV_of_Meta (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Who,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_PR_content_ST_location_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_content_ST_location_EV_of instead of INSERT trigger on PR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_PR_content_ST_location_EV_of
INSTEAD OF INSERT ON ties.PR_content_ST_location_EV_of
FOR EACH ROW
BEGIN
    ties.ip_PR_content_ST_location_EV_of(
        p_PR_content => :NEW.PR_ID_content,
        p_ST_location => :NEW.ST_ID_location,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => :NEW.PR_content_ST_location_EV_of_ChangedAt,
        p_positor => :NEW.PR_content_ST_location_EV_of_Who,
        p_positing => :NEW.PR_content_ST_location_EV_of_PositedAt,
        p_reliability => :NEW.PR_content_ST_location_EV_of_Confidence,
        p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
    );
END it_PR_content_ST_location_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lPR_content_ST_location_EV_of
INSTEAD OF INSERT ON ties.lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_PR_content_ST_location_EV_of(
        p_PR_content => :NEW.PR_ID_content,
        p_ST_location => :NEW.ST_ID_location,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => COALESCE(:NEW.PR_content_ST_location_EV_of_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.PR_content_ST_location_EV_of_Who, :NEW.Who, 0),
        p_positing => COALESCE(:NEW.PR_content_ST_location_EV_of_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.PR_content_ST_location_EV_of_Confidence, 1),
        p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
    );
END it_lPR_content_ST_location_EV_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_content_ST_location_EV_of instead of UPDATE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lPR_content_ST_location_EV_of
INSTEAD OF UPDATE ON ties.lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_positor number(5);
BEGIN
    v_positor := COALESCE(CASE
        WHEN (:NEW.PR_content_ST_location_EV_of_Who <> :OLD.PR_content_ST_location_EV_of_Who
            OR (:NEW.PR_content_ST_location_EV_of_Who IS NULL AND :OLD.PR_content_ST_location_EV_of_Who IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_Who IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_Who IS NULL))
        THEN :NEW.PR_content_ST_location_EV_of_Who
        ELSE :NEW.Who
    END, 0);
    v_positing := CASE
        WHEN (:NEW.PR_content_ST_location_EV_of_PositedAt <> :OLD.PR_content_ST_location_EV_of_PositedAt
            OR (:NEW.PR_content_ST_location_EV_of_PositedAt IS NULL AND :OLD.PR_content_ST_location_EV_of_PositedAt IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_PositedAt IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_PositedAt IS NULL))
        THEN :NEW.PR_content_ST_location_EV_of_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.PR_ID_content <> :OLD.PR_ID_content
            OR (:NEW.PR_ID_content IS NULL AND :OLD.PR_ID_content IS NOT NULL)
            OR (:NEW.PR_ID_content IS NOT NULL AND :OLD.PR_ID_content IS NULL)) OR
        (:NEW.ST_ID_location <> :OLD.ST_ID_location
            OR (:NEW.ST_ID_location IS NULL AND :OLD.ST_ID_location IS NOT NULL)
            OR (:NEW.ST_ID_location IS NOT NULL AND :OLD.ST_ID_location IS NULL)) OR
        (:NEW.EV_ID_of <> :OLD.EV_ID_of
            OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
            OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL)) OR
        (:NEW.PR_content_ST_location_EV_of_ChangedAt <> :OLD.PR_content_ST_location_EV_of_ChangedAt
            OR (:NEW.PR_content_ST_location_EV_of_ChangedAt IS NULL AND :OLD.PR_content_ST_location_EV_of_ChangedAt IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_ChangedAt IS NULL)) OR
        (:NEW.PR_content_ST_location_EV_of_PositedAt <> :OLD.PR_content_ST_location_EV_of_PositedAt
            OR (:NEW.PR_content_ST_location_EV_of_PositedAt IS NULL AND :OLD.PR_content_ST_location_EV_of_PositedAt IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_PositedAt IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_PositedAt IS NULL)) OR
        (:NEW.PR_content_ST_location_EV_of_Confidence <> :OLD.PR_content_ST_location_EV_of_Confidence
            OR (:NEW.PR_content_ST_location_EV_of_Confidence IS NULL AND :OLD.PR_content_ST_location_EV_of_Confidence IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_Confidence IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_Confidence IS NULL))
    THEN
        IF
            :NEW.PR_ID_content IS NOT NULL
        AND
            :NEW.ST_ID_location IS NOT NULL
        AND
            :NEW.EV_ID_of IS NOT NULL
        THEN
            ties.ip_PR_content_ST_location_EV_of(
                p_PR_content => :NEW.PR_ID_content,
                p_ST_location => :NEW.ST_ID_location,
                p_EV_of => :NEW.EV_ID_of,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.PR_content_ST_location_EV_of_ChangedAt <> :OLD.PR_content_ST_location_EV_of_ChangedAt
                        OR (:NEW.PR_content_ST_location_EV_of_ChangedAt IS NULL AND :OLD.PR_content_ST_location_EV_of_ChangedAt IS NOT NULL)
                        OR (:NEW.PR_content_ST_location_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_ChangedAt IS NULL))
                    THEN :NEW.PR_content_ST_location_EV_of_ChangedAt
                    WHEN
                        :NEW.PR_ID_content = :OLD.PR_ID_content
                    AND
                        :NEW.ST_ID_location = :OLD.ST_ID_location
                    AND
                        :NEW.EV_ID_of = :OLD.EV_ID_of
                    THEN :NEW.PR_content_ST_location_EV_of_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.PR_content_ST_location_EV_of_Confidence, 1),
                p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_PR_content_ST_location_EV_of(
                p_PR_content => :OLD.PR_ID_content,
                p_ST_location => :OLD.ST_ID_location,
                p_EV_of => :OLD.EV_ID_of,
                p_changing => :OLD.PR_content_ST_location_EV_of_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
            );
        END IF;
    END IF;
END ut_lPR_content_ST_location_EV_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lPR_content_ST_location_EV_of
INSTEAD OF DELETE ON ties.lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_PR_content_ST_location_EV_of(
        p_PR_content => :OLD.PR_ID_content,
        p_ST_location => :OLD.ST_ID_location,
        p_EV_of => :OLD.EV_ID_of,
        p_changing => :OLD.PR_content_ST_location_EV_of_ChangedAt,
        p_positor => COALESCE(:OLD.PR_content_ST_location_EV_of_Who, :OLD.Who, 0),
        p_positing => v_now,
        p_reliability => 0.25,
        p_metadata => :OLD.Metadata_PR_content_ST_location_EV_of
    );
END dt_lPR_content_ST_location_EV_of;
/
-- NATURAL KEYS -------------------------------------------------------------------------------------------------------
--
-- A natural key is a route in the model: the values that identify an anchor or a nexus, reached from it through its
-- attributes, its roles and ties (see naturalKeys() in Helpers.js for the rules a route follows). For each route of
-- each anchor and nexus there is
--
--   key_<anchor or nexus>_<route>          the key of every identity, from the latest values, with one column for
--                                          each value; a value with a checksum, such as a geography, is followed by
--                                          the checksum, a hash of the value, which is what it is matched on
--   pkey_<anchor or nexus>_<route>(time)   the key of every identity at a changing time, for a route that passes
--                                          something historized, since its key can change (a SQL table macro)
--   ic_key_<anchor or nexus>_<route>       the keys that more than one identity has, and the identities that have
--                                          more than one key; a violation is a row with the construct, what is wrong, the key as JSON
--
-- Oracle does not enforce that a key is unique (the primary keys are the identities), so a lookup through a key
-- view can find more than one identity when ic_key_ is not empty.
-- Every key is per positor, as the perspectives are.
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_ST_Stage_1st (
    Who,
    ST_ID,
    ST_LOC_Stage_Location,
    ST_LOC_Checksum
)
AS
SELECT
    "ST".Who,
    "ST".ST_ID,
    "ST".ST_LOC_Stage_Location,
    "ST".ST_LOC_Checksum
FROM
    anchors.lST_Stage "ST"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_ST_Stage_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Who' VALUE Who,
        'ST_LOC_Checksum' VALUE ST_LOC_Checksum
    ),
    COUNT(DISTINCT ST_ID)
FROM
    anchors.key_ST_Stage_1st
WHERE
    ST_LOC_Checksum IS NOT NULL
GROUP BY
    Who,
    ST_LOC_Checksum
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Stage_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Who' VALUE Who,
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    anchors.key_ST_Stage_1st
GROUP BY
    Who,
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_ST_Stage_2nd (
    Who,
    ST_ID,
    ST_NAM_Stage_Name
)
AS
SELECT
    "ST".Who,
    "ST".ST_ID,
    "ST".ST_NAM_Stage_Name
FROM
    anchors.lST_Stage "ST"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pkey_ST_Stage_2nd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "ST".Who,
            "ST".ST_ID,
            "ST".ST_NAM_Stage_Name AS ST_NAM_Stage_Name
        FROM
            anchors.pST_Stage(changingTimepoint) "ST"
    ]';
END pkey_ST_Stage_2nd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_ST_Stage_2nd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_2nd',
    'duplicate natural key',
    JSON_OBJECT(
        'Who' VALUE Who,
        'ST_NAM_Stage_Name' VALUE ST_NAM_Stage_Name
    ),
    COUNT(DISTINCT ST_ID)
FROM
    anchors.key_ST_Stage_2nd
WHERE
    ST_NAM_Stage_Name IS NOT NULL
GROUP BY
    Who,
    ST_NAM_Stage_Name
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Stage_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'Who' VALUE Who,
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    anchors.key_ST_Stage_2nd
GROUP BY
    Who,
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_AC_Actor_1st (
    Who,
    AC_ID,
    AC_NAM_Actor_Name
)
AS
SELECT
    "AC".Who,
    "AC".AC_ID,
    "AC".AC_NAM_Actor_Name
FROM
    anchors.lAC_Actor "AC"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pkey_AC_Actor_1st (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".Who,
            "AC".AC_ID,
            "AC".AC_NAM_Actor_Name AS AC_NAM_Actor_Name
        FROM
            anchors.pAC_Actor(changingTimepoint) "AC"
    ]';
END pkey_AC_Actor_1st;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_AC_Actor_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Actor_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Who' VALUE Who,
        'AC_NAM_Actor_Name' VALUE AC_NAM_Actor_Name
    ),
    COUNT(DISTINCT AC_ID)
FROM
    anchors.key_AC_Actor_1st
WHERE
    AC_NAM_Actor_Name IS NOT NULL
GROUP BY
    Who,
    AC_NAM_Actor_Name
HAVING
    COUNT(DISTINCT AC_ID) > 1
UNION ALL
SELECT
    'key_AC_Actor_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Who' VALUE Who,
        'AC_ID' VALUE AC_ID
    ),
    COUNT(*)
FROM
    anchors.key_AC_Actor_1st
GROUP BY
    Who,
    AC_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_PR_Program_1st (
    Who,
    PR_ID,
    PR_NAM_Program_Name
)
AS
SELECT
    "PR".Who,
    "PR".PR_ID,
    "PR".PR_NAM_Program_Name
FROM
    anchors.lPR_Program "PR"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_PR_Program_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PR_Program_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Who' VALUE Who,
        'PR_NAM_Program_Name' VALUE PR_NAM_Program_Name
    ),
    COUNT(DISTINCT PR_ID)
FROM
    anchors.key_PR_Program_1st
WHERE
    PR_NAM_Program_Name IS NOT NULL
GROUP BY
    Who,
    PR_NAM_Program_Name
HAVING
    COUNT(DISTINCT PR_ID) > 1
UNION ALL
SELECT
    'key_PR_Program_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Who' VALUE Who,
        'PR_ID' VALUE PR_ID
    ),
    COUNT(*)
FROM
    anchors.key_PR_Program_1st
GROUP BY
    Who,
    PR_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.key_EV_Event_1st (
    Who,
    EV_ID,
    EV_DAT_Event_Date,
    wasHeldAt_ST_LOC_Stage_Location,
    wasHeldAt_ST_LOC_Checksum,
    wasPlayed_PR_NAM_Program_Name
)
AS
SELECT
    "EV".Who,
    "EV".EV_ID,
    "EV".EV_DAT_Event_Date,
    "s2".ST_LOC_Stage_Location,
    "s2".ST_LOC_Checksum,
    "s4".PR_NAM_Program_Name
FROM
    nexuses.lEV_Event "EV"
LEFT JOIN
    anchors.lST_Stage "s2"
ON
    "s2".ST_ID = "EV".ST_ID_wasHeldAt
AND
    "s2".Who = "EV".Who
LEFT JOIN
    anchors.lPR_Program "s4"
ON
    "s4".PR_ID = "EV".PR_ID_wasPlayed
AND
    "s4".Who = "EV".Who
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.ic_key_EV_Event_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_EV_Event_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Who' VALUE Who,
        'EV_DAT_Event_Date' VALUE EV_DAT_Event_Date,
        'wasHeldAt_ST_LOC_Checksum' VALUE wasHeldAt_ST_LOC_Checksum,
        'wasPlayed_PR_NAM_Program_Name' VALUE wasPlayed_PR_NAM_Program_Name
    ),
    COUNT(DISTINCT EV_ID)
FROM
    nexuses.key_EV_Event_1st
WHERE
    EV_DAT_Event_Date IS NOT NULL
AND
    wasHeldAt_ST_LOC_Checksum IS NOT NULL
AND
    wasPlayed_PR_NAM_Program_Name IS NOT NULL
GROUP BY
    Who,
    EV_DAT_Event_Date,
    wasHeldAt_ST_LOC_Checksum,
    wasPlayed_PR_NAM_Program_Name
HAVING
    COUNT(DISTINCT EV_ID) > 1
UNION ALL
SELECT
    'key_EV_Event_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Who' VALUE Who,
        'EV_ID' VALUE EV_ID
    ),
    COUNT(*)
FROM
    nexuses.key_EV_Event_1st
GROUP BY
    Who,
    EV_ID
HAVING
    COUNT(*) > 1;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the tables and the columns holding values and references, making
-- them available to catalogs and semantic layers. A comment in Oracle is replaced by running the statement again.
-- Oracle has no comment on a schema, so the description of the model itself is not added.
--
COMMENT ON TABLE knots.PAT_ParentalType IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON COLUMN knots.PAT_ParentalType.PAT_ParentalType IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE knots.GEN_Gender IS 'Gender of an actor.';
COMMENT ON COLUMN knots.GEN_Gender.GEN_Gender IS 'Gender of an actor.';
COMMENT ON TABLE knots.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN knots.PLV_ProfessionalLevel.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE knots.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN knots.UTL_Utilization.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE knots.ONG_Ongoing IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN knots.ONG_Ongoing.ONG_Ongoing IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE knots.RAT_Rating IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN knots.RAT_Rating.RAT_Rating IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date IS 'Date and time when the event took place.';
COMMENT ON COLUMN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status IS 'Status of the event, which may change until it has taken place.';
COMMENT ON COLUMN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID IS 'Professional level required for the event, over time.';
COMMENT ON COLUMN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name IS 'Name or title of the program.';
COMMENT ON COLUMN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE anchors.PN_Person IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE anchors.ST_Stage IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE anchors.AC_Actor IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE nexuses.EV_Event IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN nexuses.EV_Event.ST_ID_wasHeldAt IS 'The stage at which the event was held.';
COMMENT ON COLUMN nexuses.EV_Event.PR_ID_wasPlayed IS 'The program that was played at the event.';
COMMENT ON TABLE ties.AC_partner_AC_with_ONG_currently_Fact IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently_Fact.AC_ID_partner IS 'One of the actors in the partnership.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently_Fact.AC_ID_with IS 'The other actor in the partnership.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently_Fact.ONG_ID_currently IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON COLUMN ties.AC_subset_PN_of_Fact.AC_ID_subset IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON COLUMN ties.AC_subset_PN_of_Fact.PN_ID_of IS 'The person who is the actor.';
COMMENT ON TABLE ties.EV_in_AC_wasCast_Fact IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN ties.EV_in_AC_wasCast_Fact.EV_ID_in IS 'The event the actor was cast in.';
COMMENT ON COLUMN ties.EV_in_AC_wasCast_Fact.AC_ID_wasCast IS 'An actor cast in the event.';
COMMENT ON TABLE ties.AC_part_PR_in_RAT_got_Fact IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN ties.AC_part_PR_in_RAT_got_Fact.AC_ID_part IS 'The actor having a part in the program.';
COMMENT ON COLUMN ties.AC_part_PR_in_RAT_got_Fact.PR_ID_in IS 'The program the actor has a part in.';
COMMENT ON COLUMN ties.AC_part_PR_in_RAT_got_Fact.RAT_ID_got IS 'The rating the actor got for the part.';
COMMENT ON TABLE ties.ST_at_PR_isPlaying_Fact IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ties.ST_at_PR_isPlaying_Fact.ST_ID_at IS 'The stage where the program is playing.';
COMMENT ON COLUMN ties.ST_at_PR_isPlaying_Fact.PR_ID_isPlaying IS 'The program playing at the stage.';
COMMENT ON TABLE ties.AC_parent_AC_child_PAT_having_Fact IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN ties.AC_parent_AC_child_PAT_having_Fact.AC_ID_parent IS 'The actor who is the parent.';
COMMENT ON COLUMN ties.AC_parent_AC_child_PAT_having_Fact.AC_ID_child IS 'The actor who is the child.';
COMMENT ON COLUMN ties.AC_parent_AC_child_PAT_having_Fact.PAT_ID_having IS 'The type of parental relationship.';
COMMENT ON TABLE ties.PR_content_ST_location_EV_of_Fact IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN ties.PR_content_ST_location_EV_of_Fact.PR_ID_content IS 'The program that made up the content of the event.';
COMMENT ON COLUMN ties.PR_content_ST_location_EV_of_Fact.ST_ID_location IS 'The stage where the event was located.';
COMMENT ON COLUMN ties.PR_content_ST_location_EV_of_Fact.EV_ID_of IS 'The event.';
