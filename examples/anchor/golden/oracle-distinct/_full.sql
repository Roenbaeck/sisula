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
            Metadata_PAT number(10) not null,
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
            Metadata_GEN number(10) not null,
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
            Metadata_PLV number(10) not null,
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
            Metadata_UTL number(10) not null,
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
            Metadata_ONG number(10) not null,
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
            Metadata_RAT number(10) not null,
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
            Metadata_ETY number(10) not null,
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
            Metadata_PN number(10) not null, 
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
            Metadata_ST number(10) not null, 
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
            Metadata_AC number(10) not null, 
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
            Metadata_PR number(10) not null, 
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
            Metadata_EV number(10) not null, 
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
--
-- An attribute that may be deleted (deletability) also has a deletion table, which holds what was deleted and when.
-- Oracle cannot make a table in a trigger without ending the transaction, so these are made here, not when needed.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_DAT_Event_Date (
            EV_DAT_EV_ID number(12,0) not null,
            EV_DAT_Event_Date timestamp not null,
            Metadata_EV_DAT number(10) not null,
            constraint fkEV_DAT_Event_Date foreign key (
                EV_DAT_EV_ID
            ) references nexuses.EV_Event(EV_ID),
            constraint pkEV_DAT_Event_Date primary key (
                EV_DAT_EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_AUD_Event_Audience (
            EV_AUD_EV_ID number(12,0) not null,
            EV_AUD_Event_Audience number(10) not null,
            Metadata_EV_AUD number(10) not null,
            constraint fkEV_AUD_Event_Audience foreign key (
                EV_AUD_EV_ID
            ) references nexuses.EV_Event(EV_ID),
            constraint pkEV_AUD_Event_Audience primary key (
                EV_AUD_EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_REV_Event_Revenue (
            EV_REV_EV_ID number(12,0) not null,
            EV_REV_Event_Revenue number(19,4) not null,
            Metadata_EV_REV number(10) not null,
            constraint fkEV_REV_Event_Revenue foreign key (
                EV_REV_EV_ID
            ) references nexuses.EV_Event(EV_ID),
            constraint pkEV_REV_Event_Revenue primary key (
                EV_REV_EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Event_Status table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_STA_Event_Status (
            EV_STA_EV_ID number(12,0) not null,
            EV_STA_Event_Status nvarchar2(20) not null,
            EV_STA_ChangedAt timestamp not null,
            Metadata_EV_STA number(10) not null,
            constraint fkEV_STA_Event_Status foreign key (
                EV_STA_EV_ID
            ) references nexuses.EV_Event(EV_ID),
            constraint pkEV_STA_Event_Status primary key (
                EV_STA_EV_ID,
                EV_STA_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_UTL_Event_Utilization (
            EV_UTL_EV_ID number(12,0) not null,
            EV_UTL_UTL_ID number(3) not null,
            Metadata_EV_UTL number(10) not null,
            constraint fk_A_EV_UTL_Event_Utilization foreign key (
                EV_UTL_EV_ID
            ) references nexuses.EV_Event(EV_ID),
            constraint fk_K_EV_UTL_Event_Utilization foreign key (
                EV_UTL_UTL_ID
            ) references knots.UTL_Utilization(UTL_ID),
            constraint pkEV_UTL_Event_Utilization primary key (
                EV_UTL_EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Event_Level table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_LVL_Event_Level (
            EV_LVL_EV_ID number(12,0) not null,
            EV_LVL_PLV_ID number(3) not null,
            EV_LVL_ChangedAt date not null,
            Metadata_EV_LVL number(10) not null,
            constraint fk_A_EV_LVL_Event_Level foreign key (
                EV_LVL_EV_ID
            ) references nexuses.EV_Event(EV_ID),
            constraint fk_K_EV_LVL_Event_Level foreign key (
                EV_LVL_PLV_ID
            ) references knots.PLV_ProfessionalLevel(PLV_ID),
            constraint pkEV_LVL_Event_Level primary key (
                EV_LVL_EV_ID,
                EV_LVL_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_NAM_Stage_Name (
            ST_NAM_ST_ID number(10) not null,
            ST_NAM_Stage_Name nvarchar2(42) not null,
            ST_NAM_ChangedAt timestamp not null,
            Metadata_ST_NAM number(10) not null,
            constraint fkST_NAM_Stage_Name foreign key (
                ST_NAM_ST_ID
            ) references anchors.ST_Stage(ST_ID),
            constraint pkST_NAM_Stage_Name primary key (
                ST_NAM_ST_ID,
                ST_NAM_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_LOC_Stage_Location (
            ST_LOC_ST_ID number(10) not null,
            ST_LOC_Stage_Location varchar2(100) not null,
            ST_LOC_Checksum raw(16) generated always as (standard_hash(ST_LOC_Stage_Location, 'MD5')) virtual,
            Metadata_ST_LOC number(10) not null,
            constraint fkST_LOC_Stage_Location foreign key (
                ST_LOC_ST_ID
            ) references anchors.ST_Stage(ST_ID),
            constraint pkST_LOC_Stage_Location primary key (
                ST_LOC_ST_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_AVG_Stage_Average (
            ST_AVG_ST_ID number(10) not null,
            ST_AVG_UTL_ID number(3) not null,
            ST_AVG_ChangedAt timestamp not null,
            Metadata_ST_AVG number(10) not null,
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_MIN_Stage_Minimum (
            ST_MIN_ST_ID number(10) not null,
            ST_MIN_UTL_ID number(3) not null,
            Metadata_ST_MIN number(10) not null,
            constraint fk_A_ST_MIN_Stage_Minimum foreign key (
                ST_MIN_ST_ID
            ) references anchors.ST_Stage(ST_ID),
            constraint fk_K_ST_MIN_Stage_Minimum foreign key (
                ST_MIN_UTL_ID
            ) references knots.UTL_Utilization(UTL_ID),
            constraint pkST_MIN_Stage_Minimum primary key (
                ST_MIN_ST_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Deletion table -----------------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Deleted table (what was deleted from ST_MIN_Stage_Minimum, and when)
-- It has the columns of the attribute table, without keys and without the checksum, and the time of the deletion.
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_MIN_Stage_Minimum_Deleted (
            ST_MIN_ST_ID number(10) not null,
            ST_MIN_UTL_ID number(3) not null,
            Metadata_ST_MIN number(10) not null,
            ST_MIN_Deleted timestamp(9) not null
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- AC_NAM_Actor_Name is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_NAM_Actor_Name (
            AC_NAM_AC_ID number(5) not null,
            AC_NAM_Actor_Name nvarchar2(42) not null,
            AC_NAM_ChangedAt timestamp not null,
            Metadata_AC_NAM number(10) not null,
            constraint fkAC_NAM_Actor_Name foreign key (
                AC_NAM_AC_ID
            ) references anchors.AC_Actor(AC_ID),
            constraint pkAC_NAM_Actor_Name primary key (
                AC_NAM_AC_ID,
                AC_NAM_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_GEN_Actor_Gender (
            AC_GEN_AC_ID number(5) not null,
            AC_GEN_GEN_ID number(3) not null,
            Metadata_AC_GEN number(10) not null,
            constraint fk_A_AC_GEN_Actor_Gender foreign key (
                AC_GEN_AC_ID
            ) references anchors.AC_Actor(AC_ID),
            constraint fk_K_AC_GEN_Actor_Gender foreign key (
                AC_GEN_GEN_ID
            ) references knots.GEN_Gender(GEN_ID),
            constraint pkAC_GEN_Actor_Gender primary key (
                AC_GEN_AC_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_PLV_Actor_ProfessionalLevel (
            AC_PLV_AC_ID number(5) not null,
            AC_PLV_PLV_ID number(3) not null,
            AC_PLV_ChangedAt timestamp not null,
            Metadata_AC_PLV number(10) not null,
            constraint fk_A_AC_PLV_Actor_ProfessionalLevel foreign key (
                AC_PLV_AC_ID
            ) references anchors.AC_Actor(AC_ID),
            constraint fk_K_AC_PLV_Actor_ProfessionalLevel foreign key (
                AC_PLV_PLV_ID
            ) references knots.PLV_ProfessionalLevel(PLV_ID),
            constraint pkAC_PLV_Actor_ProfessionalLevel primary key (
                AC_PLV_AC_ID,
                AC_PLV_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_NAM_Program_Name (
            PR_NAM_PR_ID number(19) not null,
            PR_NAM_Program_Name nvarchar2(42) not null,
            Metadata_PR_NAM number(10) not null,
            constraint fkPR_NAM_Program_Name foreign key (
                PR_NAM_PR_ID
            ) references anchors.PR_Program(PR_ID),
            constraint pkPR_NAM_Program_Name primary key (
                PR_NAM_PR_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_LEN_Program_Length (
            PR_LEN_PR_ID number(19) not null,
            PR_LEN_Program_Length timestamp not null,
            PR_LEN_ChangedAt date not null,
            Metadata_PR_LEN number(10) not null,
            constraint fkPR_LEN_Program_Length foreign key (
                PR_LEN_PR_ID
            ) references anchors.PR_Program(PR_ID),
            constraint pkPR_LEN_Program_Length primary key (
                PR_LEN_PR_ID,
                PR_LEN_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- A tie that may be deleted (deletability) also has a deletion table, which holds what was deleted and when.
-- Oracle cannot make a table in a trigger without ending the transaction, so these are made here, not when needed.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_partner_AC_with_ONG_currently (
            AC_ID_partner number(5) not null, 
            AC_ID_with number(5) not null, 
            ONG_ID_currently number(3) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            Metadata_AC_partner_AC_with_ONG_currently number(10) not null,
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_subset_PN_of (
            AC_ID_subset number(5) not null, 
            PN_ID_of number(19) not null, 
            Metadata_AC_subset_PN_of number(10) not null,
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.EV_in_AC_wasCast (
            EV_ID_in number(12,0) not null, 
            AC_ID_wasCast number(5) not null, 
            Metadata_EV_in_AC_wasCast number(10) not null,
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_part_PR_in_RAT_got (
            AC_ID_part number(5) not null, 
            PR_ID_in number(19) not null, 
            RAT_ID_got number(3) not null,
            AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
            Metadata_AC_part_PR_in_RAT_got number(10) not null,
            constraint AC_part_PR_in_RAT_got_fkAC_part foreign key (
                AC_ID_part
            ) references anchors.AC_Actor(AC_ID),
            constraint AC_part_PR_in_RAT_got_fkPR_in foreign key (
                PR_ID_in
            ) references anchors.PR_Program(PR_ID),
            constraint AC_part_PR_in_RAT_got_fkRAT_got foreign key (
                RAT_ID_got
            ) references knots.RAT_Rating(RAT_ID),
            constraint pkAC_part_PR_in_RAT_got primary key (
                AC_ID_part,
                PR_ID_in,
                AC_part_PR_in_RAT_got_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.ST_at_PR_isPlaying (
            ST_ID_at number(10) not null, 
            PR_ID_isPlaying number(19) not null, 
            ST_at_PR_isPlaying_ChangedAt timestamp not null,
            Metadata_ST_at_PR_isPlaying number(10) not null,
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_parent_AC_child_PAT_having (
            AC_ID_parent number(5) not null, 
            AC_ID_child number(5) not null, 
            PAT_ID_having number(3) not null,
            Metadata_AC_parent_AC_child_PAT_having number(10) not null,
            constraint AC_parent_AC_child_PAT_having_fkAC_parent foreign key (
                AC_ID_parent
            ) references anchors.AC_Actor(AC_ID),
            constraint AC_parent_AC_child_PAT_having_fkAC_child foreign key (
                AC_ID_child
            ) references anchors.AC_Actor(AC_ID),
            constraint AC_parent_AC_child_PAT_having_fkPAT_having foreign key (
                PAT_ID_having
            ) references knots.PAT_ParentalType(PAT_ID),
            constraint pkAC_parent_AC_child_PAT_having primary key (
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
-- Historized tie table -----------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.PR_content_ST_location_EV_of (
            PR_ID_content number(19) not null, 
            ST_ID_location number(10) not null, 
            EV_ID_of number(12,0) not null, 
            PR_content_ST_location_EV_of_ChangedAt timestamp not null,
            Metadata_PR_content_ST_location_EV_of number(10) not null,
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
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These SQL table macros rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- A SQL table macro (SQL_MACRO, Oracle Database 19.7 or later) is a function that returns the text of a query, in which
-- its parameters stand for the values given. It is called in the FROM clause of a query, like a table:
-- SELECT * FROM rAC_NAM_Actor_Name(TIMESTAMP '2020-01-01 00:00:00').
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_STA_Event_Status rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt
        FROM
            attributes.EV_STA_Event_Status
        WHERE
            EV_STA_ChangedAt <= changingTimepoint
    ]';
END rEV_STA_Event_Status;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Event_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM
            attributes.EV_LVL_Event_Level
        WHERE
            EV_LVL_ChangedAt <= changingTimepoint
    ]';
END rEV_LVL_Event_Level;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM
            attributes.ST_NAM_Stage_Name
        WHERE
            ST_NAM_ChangedAt <= changingTimepoint
    ]';
END rST_NAM_Stage_Name;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM
            attributes.ST_AVG_Stage_Average
        WHERE
            ST_AVG_ChangedAt <= changingTimepoint
    ]';
END rST_AVG_Stage_Average;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM
            attributes.AC_NAM_Actor_Name
        WHERE
            AC_NAM_ChangedAt <= changingTimepoint
    ]';
END rAC_NAM_Actor_Name;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel
        WHERE
            AC_PLV_ChangedAt <= changingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM
            attributes.PR_LEN_Program_Length
        WHERE
            PR_LEN_ChangedAt <= changingTimepoint
    ]';
END rPR_LEN_Program_Length;
/
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- anchor perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pAC_Actor(TIMESTAMP '2020-01-01 00:00:00').
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lST_Stage (
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
    Deletable_ST_MIN,
    ST_MIN_UTL_Utilization,
    ST_MIN_Metadata_UTL,
    ST_MIN_UTL_ID
)
AS
SELECT
    "ST".ST_ID,
    "ST".Metadata_ST,
    "NAM".ST_NAM_ST_ID,
    "NAM".Metadata_ST_NAM,
    "NAM".ST_NAM_ChangedAt,
    "NAM".ST_NAM_Stage_Name,
    "LOC".ST_LOC_ST_ID,
    "LOC".Metadata_ST_LOC,
    "LOC".ST_LOC_Checksum,
    "LOC".ST_LOC_Stage_Location,
    "AVG".ST_AVG_ST_ID,
    "AVG".Metadata_ST_AVG,
    "AVG".ST_AVG_ChangedAt,
    "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
    "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
    "AVG".ST_AVG_UTL_ID,
    "MIN".ST_MIN_ST_ID,
    "MIN".Metadata_ST_MIN,
    CAST(NULL AS number(1)),
    "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
    "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
    "MIN".ST_MIN_UTL_ID
FROM
    anchors.ST_Stage "ST"
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.ST_NAM_Stage_Name a
        WHERE
            a.ST_NAM_ChangedAt = (
                SELECT
                    MAX(sub.ST_NAM_ChangedAt)
                FROM
                    attributes.ST_NAM_Stage_Name sub
                WHERE
                    sub.ST_NAM_ST_ID = a.ST_NAM_ST_ID
            )
    ) "NAM"
ON
    "NAM".ST_NAM_ST_ID = "ST".ST_ID
LEFT JOIN
    attributes.ST_LOC_Stage_Location "LOC"
ON
    "LOC".ST_LOC_ST_ID = "ST".ST_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.ST_AVG_Stage_Average a
        WHERE
            a.ST_AVG_ChangedAt = (
                SELECT
                    MAX(sub.ST_AVG_ChangedAt)
                FROM
                    attributes.ST_AVG_Stage_Average sub
                WHERE
                    sub.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            )
    ) "AVG"
ON
    "AVG".ST_AVG_ST_ID = "ST".ST_ID
LEFT JOIN
    knots.UTL_Utilization "kAVG"
ON
    "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
LEFT JOIN
    attributes.ST_MIN_Stage_Minimum "MIN"
ON
    "MIN".ST_MIN_ST_ID = "ST".ST_ID
LEFT JOIN
    knots.UTL_Utilization "kMIN"
ON
    "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pST_Stage (
    changingTimepoint IN timestamp
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
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ChangedAt,
            "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            anchors.ST_Stage "ST"
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.ST_NAM_Stage_Name a
                WHERE
                    a.ST_NAM_ChangedAt = (
                        SELECT
                            MAX(sub.ST_NAM_ChangedAt)
                        FROM
                            attributes.ST_NAM_Stage_Name sub
                        WHERE
                            sub.ST_NAM_ST_ID = a.ST_NAM_ST_ID
                        AND
                            sub.ST_NAM_ChangedAt <= changingTimepoint
                    )
            ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        LEFT JOIN
            attributes.ST_LOC_Stage_Location "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.ST_AVG_Stage_Average a
                WHERE
                    a.ST_AVG_ChangedAt = (
                        SELECT
                            MAX(sub.ST_AVG_ChangedAt)
                        FROM
                            attributes.ST_AVG_Stage_Average sub
                        WHERE
                            sub.ST_AVG_ST_ID = a.ST_AVG_ST_ID
                        AND
                            sub.ST_AVG_ChangedAt <= changingTimepoint
                    )
            ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        LEFT JOIN
            knots.UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN
            attributes.ST_MIN_Stage_Minimum "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            knots.UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END pST_Stage;
/
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
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
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
            timepoints.inspectedTimepoint,
            timepoints.mnemonic,
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ChangedAt,
            "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM (
            SELECT DISTINCT
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
        JOIN
            anchors.ST_Stage "ST"
        ON
            "ST".ST_ID = timepoints.ST_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.ST_NAM_ChangedAt) OVER (
                    PARTITION BY h.ST_NAM_ST_ID
                    ORDER BY h.ST_NAM_ChangedAt
                ) AS untilTime
            FROM
                attributes.ST_NAM_Stage_Name h
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            attributes.ST_LOC_Stage_Location "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.ST_AVG_ChangedAt) OVER (
                    PARTITION BY h.ST_AVG_ST_ID
                    ORDER BY h.ST_AVG_ChangedAt
                ) AS untilTime
            FROM
                attributes.ST_AVG_Stage_Average h
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
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
        LEFT JOIN
            attributes.ST_MIN_Stage_Minimum "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            knots.UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END dST_Stage;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lAC_Actor (
    AC_ID,
    Metadata_AC,
    AC_NAM_AC_ID,
    Metadata_AC_NAM,
    AC_NAM_ChangedAt,
    AC_NAM_Actor_Name,
    AC_GEN_AC_ID,
    Metadata_AC_GEN,
    AC_GEN_GEN_Checksum,
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
)
AS
SELECT
    "AC".AC_ID,
    "AC".Metadata_AC,
    "NAM".AC_NAM_AC_ID,
    "NAM".Metadata_AC_NAM,
    "NAM".AC_NAM_ChangedAt,
    "NAM".AC_NAM_Actor_Name,
    "GEN".AC_GEN_AC_ID,
    "GEN".Metadata_AC_GEN,
    "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
    "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
    "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
    "GEN".AC_GEN_GEN_ID,
    "PLV".AC_PLV_AC_ID,
    "PLV".Metadata_AC_PLV,
    "PLV".AC_PLV_ChangedAt,
    "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
    "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
    "PLV".AC_PLV_PLV_ID
FROM
    anchors.AC_Actor "AC"
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.AC_NAM_Actor_Name a
        WHERE
            a.AC_NAM_ChangedAt = (
                SELECT
                    MAX(sub.AC_NAM_ChangedAt)
                FROM
                    attributes.AC_NAM_Actor_Name sub
                WHERE
                    sub.AC_NAM_AC_ID = a.AC_NAM_AC_ID
            )
    ) "NAM"
ON
    "NAM".AC_NAM_AC_ID = "AC".AC_ID
LEFT JOIN
    attributes.AC_GEN_Actor_Gender "GEN"
ON
    "GEN".AC_GEN_AC_ID = "AC".AC_ID
LEFT JOIN
    knots.GEN_Gender "kGEN"
ON
    "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel a
        WHERE
            a.AC_PLV_ChangedAt = (
                SELECT
                    MAX(sub.AC_PLV_ChangedAt)
                FROM
                    attributes.AC_PLV_Actor_ProfessionalLevel sub
                WHERE
                    sub.AC_PLV_AC_ID = a.AC_PLV_AC_ID
            )
    ) "PLV"
ON
    "PLV".AC_PLV_AC_ID = "AC".AC_ID
LEFT JOIN
    knots.PLV_ProfessionalLevel "kPLV"
ON
    "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pAC_Actor (
    changingTimepoint IN timestamp
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
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
            "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ChangedAt,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            anchors.AC_Actor "AC"
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.AC_NAM_Actor_Name a
                WHERE
                    a.AC_NAM_ChangedAt = (
                        SELECT
                            MAX(sub.AC_NAM_ChangedAt)
                        FROM
                            attributes.AC_NAM_Actor_Name sub
                        WHERE
                            sub.AC_NAM_AC_ID = a.AC_NAM_AC_ID
                        AND
                            sub.AC_NAM_ChangedAt <= changingTimepoint
                    )
            ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        LEFT JOIN
            attributes.AC_GEN_Actor_Gender "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            knots.GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.AC_PLV_Actor_ProfessionalLevel a
                WHERE
                    a.AC_PLV_ChangedAt = (
                        SELECT
                            MAX(sub.AC_PLV_ChangedAt)
                        FROM
                            attributes.AC_PLV_Actor_ProfessionalLevel sub
                        WHERE
                            sub.AC_PLV_AC_ID = a.AC_PLV_AC_ID
                        AND
                            sub.AC_PLV_ChangedAt <= changingTimepoint
                    )
            ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        LEFT JOIN
            knots.PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END pAC_Actor;
/
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
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
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
            timepoints.inspectedTimepoint,
            timepoints.mnemonic,
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
            "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ChangedAt,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM (
            SELECT DISTINCT
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
        JOIN
            anchors.AC_Actor "AC"
        ON
            "AC".AC_ID = timepoints.AC_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.AC_NAM_ChangedAt) OVER (
                    PARTITION BY h.AC_NAM_AC_ID
                    ORDER BY h.AC_NAM_ChangedAt
                ) AS untilTime
            FROM
                attributes.AC_NAM_Actor_Name h
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            attributes.AC_GEN_Actor_Gender "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            knots.GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.AC_PLV_ChangedAt) OVER (
                    PARTITION BY h.AC_PLV_AC_ID
                    ORDER BY h.AC_PLV_ChangedAt
                ) AS untilTime
            FROM
                attributes.AC_PLV_Actor_ProfessionalLevel h
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
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
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lPR_Program (
    PR_ID,
    Metadata_PR,
    PR_NAM_PR_ID,
    Metadata_PR_NAM,
    PR_NAM_Program_Name,
    PR_LEN_PR_ID,
    Metadata_PR_LEN,
    PR_LEN_ChangedAt,
    PR_LEN_Program_Length
)
AS
SELECT
    "PR".PR_ID,
    "PR".Metadata_PR,
    "NAM".PR_NAM_PR_ID,
    "NAM".Metadata_PR_NAM,
    "NAM".PR_NAM_Program_Name,
    "LEN".PR_LEN_PR_ID,
    "LEN".Metadata_PR_LEN,
    "LEN".PR_LEN_ChangedAt,
    "LEN".PR_LEN_Program_Length
FROM
    anchors.PR_Program "PR"
LEFT JOIN
    attributes.PR_NAM_Program_Name "NAM"
ON
    "NAM".PR_NAM_PR_ID = "PR".PR_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.PR_LEN_Program_Length a
        WHERE
            a.PR_LEN_ChangedAt = (
                SELECT
                    MAX(sub.PR_LEN_ChangedAt)
                FROM
                    attributes.PR_LEN_Program_Length sub
                WHERE
                    sub.PR_LEN_PR_ID = a.PR_LEN_PR_ID
            )
    ) "LEN"
ON
    "LEN".PR_LEN_PR_ID = "PR".PR_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pPR_Program (
    changingTimepoint IN timestamp
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
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_Program_Length
        FROM
            anchors.PR_Program "PR"
        LEFT JOIN
            attributes.PR_NAM_Program_Name "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.PR_LEN_Program_Length a
                WHERE
                    a.PR_LEN_ChangedAt = (
                        SELECT
                            MAX(sub.PR_LEN_ChangedAt)
                        FROM
                            attributes.PR_LEN_Program_Length sub
                        WHERE
                            sub.PR_LEN_PR_ID = a.PR_LEN_PR_ID
                        AND
                            sub.PR_LEN_ChangedAt <= changingTimepoint
                    )
            ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
    ]';
END pPR_Program;
/
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
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
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
            timepoints.inspectedTimepoint,
            timepoints.mnemonic,
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_Program_Length
        FROM (
            SELECT DISTINCT
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
        JOIN
            anchors.PR_Program "PR"
        ON
            "PR".PR_ID = timepoints.PR_ID
        LEFT JOIN
            attributes.PR_NAM_Program_Name "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.PR_LEN_ChangedAt) OVER (
                    PARTITION BY h.PR_LEN_PR_ID
                    ORDER BY h.PR_LEN_ChangedAt
                ) AS untilTime
            FROM
                attributes.PR_LEN_Program_Length h
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
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
-- nexus perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pEV_Event(TIMESTAMP '2020-01-01 00:00:00').
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.lEV_Event (
    EV_ID,
    Metadata_EV,
    ST_ID_wasHeldAt,
    PR_ID_wasPlayed,
    of_ETY_Checksum,
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
    EV_REV_Event_Revenue,
    EV_STA_EV_ID,
    Metadata_EV_STA,
    EV_STA_ChangedAt,
    EV_STA_Event_Status,
    EV_UTL_EV_ID,
    Metadata_EV_UTL,
    EV_UTL_UTL_Utilization,
    EV_UTL_Metadata_UTL,
    EV_UTL_UTL_ID,
    EV_LVL_EV_ID,
    Metadata_EV_LVL,
    EV_LVL_ChangedAt,
    EV_LVL_PLV_Checksum,
    EV_LVL_PLV_ProfessionalLevel,
    EV_LVL_Metadata_PLV,
    EV_LVL_PLV_ID
)
AS
SELECT
    "EV".EV_ID,
    "EV".Metadata_EV,
    "EV".ST_ID_wasHeldAt,
    "EV".PR_ID_wasPlayed,
    "ETY_of".ETY_Checksum AS of_ETY_Checksum,
    "ETY_of".ETY_EventType AS of_ETY_EventType,
    "ETY_of".Metadata_ETY AS of_Metadata_ETY,
    "EV".ETY_ID_of,
    "DAT".EV_DAT_EV_ID,
    "DAT".Metadata_EV_DAT,
    "DAT".EV_DAT_Event_Date,
    "AUD".EV_AUD_EV_ID,
    "AUD".Metadata_EV_AUD,
    "AUD".EV_AUD_Event_Audience,
    "REV".EV_REV_EV_ID,
    "REV".Metadata_EV_REV,
    "REV".EV_REV_Event_Revenue,
    "STA".EV_STA_EV_ID,
    "STA".Metadata_EV_STA,
    "STA".EV_STA_ChangedAt,
    "STA".EV_STA_Event_Status,
    "UTL".EV_UTL_EV_ID,
    "UTL".Metadata_EV_UTL,
    "kUTL".UTL_Utilization AS EV_UTL_UTL_Utilization,
    "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
    "UTL".EV_UTL_UTL_ID,
    "LVL".EV_LVL_EV_ID,
    "LVL".Metadata_EV_LVL,
    "LVL".EV_LVL_ChangedAt,
    "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
    "kLVL".PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
    "LVL".EV_LVL_PLV_ID
FROM
    nexuses.EV_Event "EV"
LEFT JOIN
    knots.ETY_EventType "ETY_of"
ON
    "ETY_of".ETY_ID = "EV".ETY_ID_of
LEFT JOIN
    attributes.EV_DAT_Event_Date "DAT"
ON
    "DAT".EV_DAT_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_AUD_Event_Audience "AUD"
ON
    "AUD".EV_AUD_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_REV_Event_Revenue "REV"
ON
    "REV".EV_REV_EV_ID = "EV".EV_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.EV_STA_Event_Status a
        WHERE
            a.EV_STA_ChangedAt = (
                SELECT
                    MAX(sub.EV_STA_ChangedAt)
                FROM
                    attributes.EV_STA_Event_Status sub
                WHERE
                    sub.EV_STA_EV_ID = a.EV_STA_EV_ID
            )
    ) "STA"
ON
    "STA".EV_STA_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_UTL_Event_Utilization "UTL"
ON
    "UTL".EV_UTL_EV_ID = "EV".EV_ID
LEFT JOIN
    knots.UTL_Utilization "kUTL"
ON
    "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.EV_LVL_Event_Level a
        WHERE
            a.EV_LVL_ChangedAt = (
                SELECT
                    MAX(sub.EV_LVL_ChangedAt)
                FROM
                    attributes.EV_LVL_Event_Level sub
                WHERE
                    sub.EV_LVL_EV_ID = a.EV_LVL_EV_ID
            )
    ) "LVL"
ON
    "LVL".EV_LVL_EV_ID = "EV".EV_ID
LEFT JOIN
    knots.PLV_ProfessionalLevel "kLVL"
ON
    "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.pEV_Event (
    changingTimepoint IN timestamp
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
            "ETY_of".ETY_Checksum AS of_ETY_Checksum,
            "ETY_of".ETY_EventType AS of_ETY_EventType,
            "ETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_Event_Revenue,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_Event_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "kUTL".UTL_Utilization AS EV_UTL_UTL_Utilization,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ChangedAt,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            nexuses.EV_Event "EV"
        LEFT JOIN
            knots.ETY_EventType "ETY_of"
        ON
            "ETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN
            attributes.EV_DAT_Event_Date "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_AUD_Event_Audience "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_REV_Event_Revenue "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.EV_STA_Event_Status a
                WHERE
                    a.EV_STA_ChangedAt = (
                        SELECT
                            MAX(sub.EV_STA_ChangedAt)
                        FROM
                            attributes.EV_STA_Event_Status sub
                        WHERE
                            sub.EV_STA_EV_ID = a.EV_STA_EV_ID
                        AND
                            sub.EV_STA_ChangedAt <= changingTimepoint
                    )
            ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_UTL_Event_Utilization "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.UTL_Utilization "kUTL"
        ON
            "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.EV_LVL_Event_Level a
                WHERE
                    a.EV_LVL_ChangedAt = (
                        SELECT
                            MAX(sub.EV_LVL_ChangedAt)
                        FROM
                            attributes.EV_LVL_Event_Level sub
                        WHERE
                            sub.EV_LVL_EV_ID = a.EV_LVL_EV_ID
                        AND
                            sub.EV_LVL_ChangedAt <= changingTimepoint
                    )
            ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.PLV_ProfessionalLevel "kLVL"
        ON
            "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
    ]';
END pEV_Event;
/
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
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
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
            timepoints.inspectedTimepoint,
            timepoints.mnemonic,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "ETY_of".ETY_Checksum AS of_ETY_Checksum,
            "ETY_of".ETY_EventType AS of_ETY_EventType,
            "ETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_Event_Revenue,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_Event_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "kUTL".UTL_Utilization AS EV_UTL_UTL_Utilization,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ChangedAt,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM (
            SELECT DISTINCT
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
        JOIN
            nexuses.EV_Event "EV"
        ON
            "EV".EV_ID = timepoints.EV_ID
        LEFT JOIN
            knots.ETY_EventType "ETY_of"
        ON
            "ETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN
            attributes.EV_DAT_Event_Date "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_AUD_Event_Audience "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_REV_Event_Revenue "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.EV_STA_ChangedAt) OVER (
                    PARTITION BY h.EV_STA_EV_ID
                    ORDER BY h.EV_STA_ChangedAt
                ) AS untilTime
            FROM
                attributes.EV_STA_Event_Status h
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "STA".untilTime IS NULL
        OR
            "STA".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            attributes.EV_UTL_Event_Utilization "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.UTL_Utilization "kUTL"
        ON
            "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.EV_LVL_ChangedAt) OVER (
                    PARTITION BY h.EV_LVL_EV_ID
                    ORDER BY h.EV_LVL_ChangedAt
                ) AS untilTime
            FROM
                attributes.EV_LVL_Event_Level h
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
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
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- tie perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pAC_part_EV_in(TIMESTAMP '2020-01-01 00:00:00').
--
-- A historized tie shows, for each identifier (for each anchor, in a tie without identifiers), the rows that have the latest
-- changing time: that is worked out with an analytic MAX in an inline view, whose column holds the latest time.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently (
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt,
    AC_ID_partner,
    AC_ID_with,
    currently_ONG_Ongoing,
    currently_Metadata_ONG,
    ONG_ID_currently
)
AS
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    "ONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
    "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    (
        SELECT
            t.*,
            MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_partner) AS latestAC_ID_partner,
            MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_with) AS latestAC_ID_with
        FROM
            ties.AC_partner_AC_with_ONG_currently t
    ) tie
LEFT JOIN
    knots.ONG_Ongoing "ONG_currently"
ON
    "ONG_currently".ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_partner
AND
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_with
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_partner_AC_with_ONG_currently,
            tie.AC_partner_AC_with_ONG_currently_ChangedAt,
            tie.AC_ID_partner,
            tie.AC_ID_with,
            "ONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            tie.ONG_ID_currently
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_partner) AS latestAC_ID_partner,
                    MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_with) AS latestAC_ID_with
                FROM
                    ties.AC_partner_AC_with_ONG_currently t
                WHERE
                    t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            knots.ONG_Ongoing "ONG_currently"
        ON
            "ONG_currently".ONG_ID = tie.ONG_ID_currently
        WHERE
            tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_partner
        AND
            tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_with
    ]';
END pAC_partner_AC_with_ONG_currently;
/
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
            tie.Metadata_AC_partner_AC_with_ONG_currently,
            tie.AC_partner_AC_with_ONG_currently_ChangedAt,
            tie.AC_ID_partner,
            tie.AC_ID_with,
            "ONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            tie.ONG_ID_currently
        FROM
            ties.AC_partner_AC_with_ONG_currently tie
        LEFT JOIN
            knots.ONG_Ongoing "ONG_currently"
        ON
            "ONG_currently".ONG_ID = tie.ONG_ID_currently
        WHERE
            tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_partner_AC_with_ONG_currently;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of (
    Metadata_AC_subset_PN_of,
    AC_ID_subset,
    PN_ID_of
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
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_subset_PN_of,
            tie.AC_ID_subset,
            tie.PN_ID_of
        FROM
            ties.AC_subset_PN_of tie
    ]';
END pAC_subset_PN_of;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of
AS
SELECT
    *
FROM
    ties.pAC_subset_PN_of(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast (
    Metadata_EV_in_AC_wasCast,
    EV_ID_in,
    AC_ID_wasCast
)
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
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_EV_in_AC_wasCast,
            tie.EV_ID_in,
            tie.AC_ID_wasCast
        FROM
            ties.EV_in_AC_wasCast tie
    ]';
END pEV_in_AC_wasCast;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast
AS
SELECT
    *
FROM
    ties.pEV_in_AC_wasCast(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got (
    Metadata_AC_part_PR_in_RAT_got,
    AC_part_PR_in_RAT_got_ChangedAt,
    AC_ID_part,
    PR_ID_in,
    got_RAT_Checksum,
    got_RAT_Rating,
    got_Metadata_RAT,
    RAT_ID_got
)
AS
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    "RAT_got".RAT_Checksum AS got_RAT_Checksum,
    "RAT_got".RAT_Rating AS got_RAT_Rating,
    "RAT_got".Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    (
        SELECT
            t.*,
            MAX(t.AC_part_PR_in_RAT_got_ChangedAt) OVER (
                PARTITION BY
                    t.AC_ID_part,
                    t.PR_ID_in
            ) AS latestTime
        FROM
            ties.AC_part_PR_in_RAT_got t
    ) tie
LEFT JOIN
    knots.RAT_Rating "RAT_got"
ON
    "RAT_got".RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_part_PR_in_RAT_got,
            tie.AC_part_PR_in_RAT_got_ChangedAt,
            tie.AC_ID_part,
            tie.PR_ID_in,
            "RAT_got".RAT_Checksum AS got_RAT_Checksum,
            "RAT_got".RAT_Rating AS got_RAT_Rating,
            "RAT_got".Metadata_RAT AS got_Metadata_RAT,
            tie.RAT_ID_got
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.AC_part_PR_in_RAT_got_ChangedAt) OVER (
                        PARTITION BY
                            t.AC_ID_part,
                            t.PR_ID_in
                    ) AS latestTime
                FROM
                    ties.AC_part_PR_in_RAT_got t
                WHERE
                    t.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            knots.RAT_Rating "RAT_got"
        ON
            "RAT_got".RAT_ID = tie.RAT_ID_got
        WHERE
            tie.AC_part_PR_in_RAT_got_ChangedAt = tie.latestTime
    ]';
END pAC_part_PR_in_RAT_got;
/
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
            tie.Metadata_AC_part_PR_in_RAT_got,
            tie.AC_part_PR_in_RAT_got_ChangedAt,
            tie.AC_ID_part,
            tie.PR_ID_in,
            "RAT_got".RAT_Checksum AS got_RAT_Checksum,
            "RAT_got".RAT_Rating AS got_RAT_Rating,
            "RAT_got".Metadata_RAT AS got_Metadata_RAT,
            tie.RAT_ID_got
        FROM
            ties.AC_part_PR_in_RAT_got tie
        LEFT JOIN
            knots.RAT_Rating "RAT_got"
        ON
            "RAT_got".RAT_ID = tie.RAT_ID_got
        WHERE
            tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_part_PR_in_RAT_got;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying (
    Metadata_ST_at_PR_isPlaying,
    ST_at_PR_isPlaying_ChangedAt,
    ST_ID_at,
    PR_ID_isPlaying
)
AS
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    (
        SELECT
            t.*,
            MAX(t.ST_at_PR_isPlaying_ChangedAt) OVER (
                PARTITION BY
                    t.ST_ID_at,
                    t.PR_ID_isPlaying
            ) AS latestTime
        FROM
            ties.ST_at_PR_isPlaying t
    ) tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_isPlaying (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_ST_at_PR_isPlaying,
            tie.ST_at_PR_isPlaying_ChangedAt,
            tie.ST_ID_at,
            tie.PR_ID_isPlaying
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.ST_at_PR_isPlaying_ChangedAt) OVER (
                        PARTITION BY
                            t.ST_ID_at,
                            t.PR_ID_isPlaying
                    ) AS latestTime
                FROM
                    ties.ST_at_PR_isPlaying t
                WHERE
                    t.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
            ) tie
        WHERE
            tie.ST_at_PR_isPlaying_ChangedAt = tie.latestTime
    ]';
END pST_at_PR_isPlaying;
/
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
            tie.Metadata_ST_at_PR_isPlaying,
            tie.ST_at_PR_isPlaying_ChangedAt,
            tie.ST_ID_at,
            tie.PR_ID_isPlaying
        FROM
            ties.ST_at_PR_isPlaying tie
        WHERE
            tie.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dST_at_PR_isPlaying;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having (
    Metadata_AC_parent_AC_child_PAT_having,
    AC_ID_parent,
    AC_ID_child,
    having_PAT_ParentalType,
    having_Metadata_PAT,
    PAT_ID_having
)
AS
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    "PAT_having".PAT_ParentalType AS having_PAT_ParentalType,
    "PAT_having".Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    ties.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    knots.PAT_ParentalType "PAT_having"
ON
    "PAT_having".PAT_ID = tie.PAT_ID_having
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_parent_AC_child_PAT_having (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_parent_AC_child_PAT_having,
            tie.AC_ID_parent,
            tie.AC_ID_child,
            "PAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "PAT_having".Metadata_PAT AS having_Metadata_PAT,
            tie.PAT_ID_having
        FROM
            ties.AC_parent_AC_child_PAT_having tie
        LEFT JOIN
            knots.PAT_ParentalType "PAT_having"
        ON
            "PAT_having".PAT_ID = tie.PAT_ID_having
    ]';
END pAC_parent_AC_child_PAT_having;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    ties.pAC_parent_AC_child_PAT_having(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of (
    Metadata_PR_content_ST_location_EV_of,
    PR_content_ST_location_EV_of_ChangedAt,
    PR_ID_content,
    ST_ID_location,
    EV_ID_of
)
AS
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_ChangedAt,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    (
        SELECT
            t.*,
            MAX(t.PR_content_ST_location_EV_of_ChangedAt) OVER (PARTITION BY t.PR_ID_content) AS latestPR_ID_content,
            MAX(t.PR_content_ST_location_EV_of_ChangedAt) OVER (PARTITION BY t.ST_ID_location) AS latestST_ID_location
        FROM
            ties.PR_content_ST_location_EV_of t
    ) tie
WHERE
    tie.PR_content_ST_location_EV_of_ChangedAt = tie.latestPR_ID_content
AND
    tie.PR_content_ST_location_EV_of_ChangedAt = tie.latestST_ID_location
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_content_ST_location_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_PR_content_ST_location_EV_of,
            tie.PR_content_ST_location_EV_of_ChangedAt,
            tie.PR_ID_content,
            tie.ST_ID_location,
            tie.EV_ID_of
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.PR_content_ST_location_EV_of_ChangedAt) OVER (PARTITION BY t.PR_ID_content) AS latestPR_ID_content,
                    MAX(t.PR_content_ST_location_EV_of_ChangedAt) OVER (PARTITION BY t.ST_ID_location) AS latestST_ID_location
                FROM
                    ties.PR_content_ST_location_EV_of t
                WHERE
                    t.PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
            ) tie
        WHERE
            tie.PR_content_ST_location_EV_of_ChangedAt = tie.latestPR_ID_content
        AND
            tie.PR_content_ST_location_EV_of_ChangedAt = tie.latestST_ID_location
    ]';
END pPR_content_ST_location_EV_of;
/
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
            tie.Metadata_PR_content_ST_location_EV_of,
            tie.PR_content_ST_location_EV_of_ChangedAt,
            tie.PR_ID_content,
            tie.ST_ID_location,
            tie.EV_ID_of
        FROM
            ties.PR_content_ST_location_EV_of tie
        WHERE
            tie.PR_content_ST_location_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dPR_content_ST_location_EV_of;
/
-- ATTRIBUTE INSERT PROCEDURES ----------------------------------------------------------------------------------------
--
-- The procedures here state one value of an attribute, in the way that the model says: a row that is already there is
-- not stored again, another value at a time that has a value is a contradiction, and a value that is the same as the
-- one before it (a restatement) is skipped by an idempotent attribute and refused by one that may not be restated.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- These are procedures and not triggers on the attribute tables, since Oracle does not let a row trigger read the table
-- it is on (ORA-04091), which these rules do. The triggers on the latest views call them, and so can a load:
--
--     BEGIN ip_AC_NAM_Actor_Name(p_owner => 1, p_changing => SYSTIMESTAMP, p_value => 'Ann', p_metadata => 1); END;
--
-- A row put straight into an attribute table by an INSERT is not looked at.
--
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_DAT_Event_Date states a value of EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_DAT_Event_Date (
    p_owner IN attributes.EV_DAT_Event_Date.EV_DAT_EV_ID%TYPE,
    p_value IN attributes.EV_DAT_Event_Date.EV_DAT_Event_Date%TYPE,
    p_metadata IN attributes.EV_DAT_Event_Date.Metadata_EV_DAT%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_DAT_Event_Date.EV_DAT_Event_Date%TYPE,
        b IN attributes.EV_DAT_Event_Date.EV_DAT_Event_Date%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_DAT_Event_Date
        FROM
            attributes.EV_DAT_Event_Date x
        WHERE
            x.EV_DAT_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_DAT_Event_Date, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_DAT_Event_Date (
        Metadata_EV_DAT,
        EV_DAT_EV_ID,
        EV_DAT_Event_Date
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_DAT_Event_Date;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Event_Audience states a value of EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_AUD_Event_Audience (
    p_owner IN attributes.EV_AUD_Event_Audience.EV_AUD_EV_ID%TYPE,
    p_value IN attributes.EV_AUD_Event_Audience.EV_AUD_Event_Audience%TYPE,
    p_metadata IN attributes.EV_AUD_Event_Audience.Metadata_EV_AUD%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_AUD_Event_Audience.EV_AUD_Event_Audience%TYPE,
        b IN attributes.EV_AUD_Event_Audience.EV_AUD_Event_Audience%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_AUD_Event_Audience
        FROM
            attributes.EV_AUD_Event_Audience x
        WHERE
            x.EV_AUD_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_AUD_Event_Audience, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_AUD_Event_Audience (
        Metadata_EV_AUD,
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_AUD_Event_Audience;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Event_Revenue states a value of EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_REV_Event_Revenue (
    p_owner IN attributes.EV_REV_Event_Revenue.EV_REV_EV_ID%TYPE,
    p_value IN attributes.EV_REV_Event_Revenue.EV_REV_Event_Revenue%TYPE,
    p_metadata IN attributes.EV_REV_Event_Revenue.Metadata_EV_REV%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_REV_Event_Revenue.EV_REV_Event_Revenue%TYPE,
        b IN attributes.EV_REV_Event_Revenue.EV_REV_Event_Revenue%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_REV_Event_Revenue
        FROM
            attributes.EV_REV_Event_Revenue x
        WHERE
            x.EV_REV_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_REV_Event_Revenue, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_REV_Event_Revenue (
        Metadata_EV_REV,
        EV_REV_EV_ID,
        EV_REV_Event_Revenue
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_REV_Event_Revenue;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_STA_Event_Status states a value of EV_STA_Event_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_STA_Event_Status (
    p_owner IN attributes.EV_STA_Event_Status.EV_STA_EV_ID%TYPE,
    p_changing IN attributes.EV_STA_Event_Status.EV_STA_ChangedAt%TYPE,
    p_value IN attributes.EV_STA_Event_Status.EV_STA_Event_Status%TYPE,
    p_metadata IN attributes.EV_STA_Event_Status.Metadata_EV_STA%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_STA_Event_Status.EV_STA_Event_Status%TYPE,
        b IN attributes.EV_STA_Event_Status.EV_STA_Event_Status%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.EV_STA_Event_Status
        FROM
            attributes.EV_STA_Event_Status x
        WHERE
            x.EV_STA_EV_ID = p_owner
        AND
            x.EV_STA_ChangedAt = p_changing
    ) LOOP
        IF same(r.EV_STA_Event_Status, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Event_Status for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.EV_STA_Event_Status (
        Metadata_EV_STA,
        EV_STA_EV_ID,
        EV_STA_ChangedAt,
        EV_STA_Event_Status
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_EV_STA_Event_Status;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_UTL_Event_Utilization states a value of EV_UTL_Event_Utilization
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_UTL_Event_Utilization (
    p_owner IN attributes.EV_UTL_Event_Utilization.EV_UTL_EV_ID%TYPE,
    p_value IN attributes.EV_UTL_Event_Utilization.EV_UTL_UTL_ID%TYPE,
    p_metadata IN attributes.EV_UTL_Event_Utilization.Metadata_EV_UTL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_UTL_Event_Utilization.EV_UTL_UTL_ID%TYPE,
        b IN attributes.EV_UTL_Event_Utilization.EV_UTL_UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_UTL_UTL_ID
        FROM
            attributes.EV_UTL_Event_Utilization x
        WHERE
            x.EV_UTL_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_UTL_UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Event_Utilization for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_UTL_Event_Utilization (
        Metadata_EV_UTL,
        EV_UTL_EV_ID,
        EV_UTL_UTL_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_UTL_Event_Utilization;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_LVL_Event_Level states a value of EV_LVL_Event_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_LVL_Event_Level (
    p_owner IN attributes.EV_LVL_Event_Level.EV_LVL_EV_ID%TYPE,
    p_changing IN attributes.EV_LVL_Event_Level.EV_LVL_ChangedAt%TYPE,
    p_value IN attributes.EV_LVL_Event_Level.EV_LVL_PLV_ID%TYPE,
    p_metadata IN attributes.EV_LVL_Event_Level.Metadata_EV_LVL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_LVL_Event_Level.EV_LVL_PLV_ID%TYPE,
        b IN attributes.EV_LVL_Event_Level.EV_LVL_PLV_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.EV_LVL_PLV_ID
        FROM
            attributes.EV_LVL_Event_Level x
        WHERE
            x.EV_LVL_EV_ID = p_owner
        AND
            x.EV_LVL_ChangedAt = p_changing
    ) LOOP
        IF same(r.EV_LVL_PLV_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Event_Level for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.EV_LVL_Event_Level (
        Metadata_EV_LVL,
        EV_LVL_EV_ID,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_EV_LVL_Event_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Stage_Name states a value of ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_NAM_Stage_Name (
    p_owner IN attributes.ST_NAM_Stage_Name.ST_NAM_ST_ID%TYPE,
    p_changing IN attributes.ST_NAM_Stage_Name.ST_NAM_ChangedAt%TYPE,
    p_value IN attributes.ST_NAM_Stage_Name.ST_NAM_Stage_Name%TYPE,
    p_metadata IN attributes.ST_NAM_Stage_Name.Metadata_ST_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_NAM_Stage_Name.ST_NAM_Stage_Name%TYPE,
        b IN attributes.ST_NAM_Stage_Name.ST_NAM_Stage_Name%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.ST_NAM_Stage_Name
        FROM
            attributes.ST_NAM_Stage_Name x
        WHERE
            x.ST_NAM_ST_ID = p_owner
        AND
            x.ST_NAM_ChangedAt = p_changing
    ) LOOP
        IF same(r.ST_NAM_Stage_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.ST_NAM_Stage_Name (
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_ST_NAM_Stage_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Stage_Location states a value of ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_LOC_Stage_Location (
    p_owner IN attributes.ST_LOC_Stage_Location.ST_LOC_ST_ID%TYPE,
    p_value IN attributes.ST_LOC_Stage_Location.ST_LOC_Stage_Location%TYPE,
    p_metadata IN attributes.ST_LOC_Stage_Location.Metadata_ST_LOC%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_LOC_Stage_Location.ST_LOC_Stage_Location%TYPE,
        b IN attributes.ST_LOC_Stage_Location.ST_LOC_Stage_Location%TYPE
    ) RETURN BOOLEAN
    IS
        v_same NUMBER;
    BEGIN
        SELECT CASE WHEN STANDARD_HASH(a, 'MD5') = STANDARD_HASH(b, 'MD5') THEN 1 ELSE 0 END INTO v_same FROM dual;
        RETURN v_same = 1;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.ST_LOC_Stage_Location
        FROM
            attributes.ST_LOC_Stage_Location x
        WHERE
            x.ST_LOC_ST_ID = p_owner
    ) LOOP
        IF same(r.ST_LOC_Stage_Location, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.ST_LOC_Stage_Location (
        Metadata_ST_LOC,
        ST_LOC_ST_ID,
        ST_LOC_Stage_Location
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_ST_LOC_Stage_Location;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Stage_Average states a value of ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_AVG_Stage_Average (
    p_owner IN attributes.ST_AVG_Stage_Average.ST_AVG_ST_ID%TYPE,
    p_changing IN attributes.ST_AVG_Stage_Average.ST_AVG_ChangedAt%TYPE,
    p_value IN attributes.ST_AVG_Stage_Average.ST_AVG_UTL_ID%TYPE,
    p_metadata IN attributes.ST_AVG_Stage_Average.Metadata_ST_AVG%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_AVG_Stage_Average.ST_AVG_UTL_ID%TYPE,
        b IN attributes.ST_AVG_Stage_Average.ST_AVG_UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Stage_Average x
        WHERE
            x.ST_AVG_ST_ID = p_owner
        AND
            x.ST_AVG_ChangedAt = p_changing
    ) LOOP
        IF same(r.ST_AVG_UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Stage_Average p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < p_changing
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.ST_AVG_UTL_ID, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.ST_AVG_ChangedAt,
            f.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Stage_Average f
        WHERE
            f.ST_AVG_ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > p_changing
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.ST_AVG_UTL_ID, p_value) THEN
            DELETE FROM
                attributes.ST_AVG_Stage_Average
            WHERE
                ST_AVG_ST_ID = p_owner
            AND
                ST_AVG_ChangedAt = r.ST_AVG_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO attributes.ST_AVG_Stage_Average (
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_ST_AVG_Stage_Average;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Stage_Minimum states a value of ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_MIN_Stage_Minimum (
    p_owner IN attributes.ST_MIN_Stage_Minimum.ST_MIN_ST_ID%TYPE,
    p_value IN attributes.ST_MIN_Stage_Minimum.ST_MIN_UTL_ID%TYPE,
    p_metadata IN attributes.ST_MIN_Stage_Minimum.Metadata_ST_MIN%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_MIN_Stage_Minimum.ST_MIN_UTL_ID%TYPE,
        b IN attributes.ST_MIN_Stage_Minimum.ST_MIN_UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.ST_MIN_UTL_ID
        FROM
            attributes.ST_MIN_Stage_Minimum x
        WHERE
            x.ST_MIN_ST_ID = p_owner
    ) LOOP
        IF same(r.ST_MIN_UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.ST_MIN_Stage_Minimum (
        Metadata_ST_MIN,
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_ST_MIN_Stage_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Actor_Name states a value of AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_NAM_Actor_Name (
    p_owner IN attributes.AC_NAM_Actor_Name.AC_NAM_AC_ID%TYPE,
    p_changing IN attributes.AC_NAM_Actor_Name.AC_NAM_ChangedAt%TYPE,
    p_value IN attributes.AC_NAM_Actor_Name.AC_NAM_Actor_Name%TYPE,
    p_metadata IN attributes.AC_NAM_Actor_Name.Metadata_AC_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.AC_NAM_Actor_Name.AC_NAM_Actor_Name%TYPE,
        b IN attributes.AC_NAM_Actor_Name.AC_NAM_Actor_Name%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.AC_NAM_Actor_Name
        FROM
            attributes.AC_NAM_Actor_Name x
        WHERE
            x.AC_NAM_AC_ID = p_owner
        AND
            x.AC_NAM_ChangedAt = p_changing
    ) LOOP
        IF same(r.AC_NAM_Actor_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    FOR r IN (
        SELECT
            p.AC_NAM_Actor_Name
        FROM
            attributes.AC_NAM_Actor_Name p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt < p_changing
        ORDER BY
            p.AC_NAM_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.AC_NAM_Actor_Name, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.AC_NAM_Actor_Name
        FROM
            attributes.AC_NAM_Actor_Name f
        WHERE
            f.AC_NAM_AC_ID = p_owner
        AND
            f.AC_NAM_ChangedAt > p_changing
        ORDER BY
            f.AC_NAM_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.AC_NAM_Actor_Name, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    INSERT INTO attributes.AC_NAM_Actor_Name (
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_AC_NAM_Actor_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Actor_Gender states a value of AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_GEN_Actor_Gender (
    p_owner IN attributes.AC_GEN_Actor_Gender.AC_GEN_AC_ID%TYPE,
    p_value IN attributes.AC_GEN_Actor_Gender.AC_GEN_GEN_ID%TYPE,
    p_metadata IN attributes.AC_GEN_Actor_Gender.Metadata_AC_GEN%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.AC_GEN_Actor_Gender.AC_GEN_GEN_ID%TYPE,
        b IN attributes.AC_GEN_Actor_Gender.AC_GEN_GEN_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.AC_GEN_GEN_ID
        FROM
            attributes.AC_GEN_Actor_Gender x
        WHERE
            x.AC_GEN_AC_ID = p_owner
    ) LOOP
        IF same(r.AC_GEN_GEN_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.AC_GEN_Actor_Gender (
        Metadata_AC_GEN,
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_AC_GEN_Actor_Gender;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Actor_ProfessionalLevel states a value of AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_PLV_Actor_ProfessionalLevel (
    p_owner IN attributes.AC_PLV_Actor_ProfessionalLevel.AC_PLV_AC_ID%TYPE,
    p_changing IN attributes.AC_PLV_Actor_ProfessionalLevel.AC_PLV_ChangedAt%TYPE,
    p_value IN attributes.AC_PLV_Actor_ProfessionalLevel.AC_PLV_PLV_ID%TYPE,
    p_metadata IN attributes.AC_PLV_Actor_ProfessionalLevel.Metadata_AC_PLV%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.AC_PLV_Actor_ProfessionalLevel.AC_PLV_PLV_ID%TYPE,
        b IN attributes.AC_PLV_Actor_ProfessionalLevel.AC_PLV_PLV_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.AC_PLV_PLV_ID
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel x
        WHERE
            x.AC_PLV_AC_ID = p_owner
        AND
            x.AC_PLV_ChangedAt = p_changing
    ) LOOP
        IF same(r.AC_PLV_PLV_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel (
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_AC_PLV_Actor_ProfessionalLevel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Program_Name states a value of PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_NAM_Program_Name (
    p_owner IN attributes.PR_NAM_Program_Name.PR_NAM_PR_ID%TYPE,
    p_value IN attributes.PR_NAM_Program_Name.PR_NAM_Program_Name%TYPE,
    p_metadata IN attributes.PR_NAM_Program_Name.Metadata_PR_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.PR_NAM_Program_Name.PR_NAM_Program_Name%TYPE,
        b IN attributes.PR_NAM_Program_Name.PR_NAM_Program_Name%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.PR_NAM_Program_Name
        FROM
            attributes.PR_NAM_Program_Name x
        WHERE
            x.PR_NAM_PR_ID = p_owner
    ) LOOP
        IF same(r.PR_NAM_Program_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.PR_NAM_Program_Name (
        Metadata_PR_NAM,
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_PR_NAM_Program_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Program_Length states a value of PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_LEN_Program_Length (
    p_owner IN attributes.PR_LEN_Program_Length.PR_LEN_PR_ID%TYPE,
    p_changing IN attributes.PR_LEN_Program_Length.PR_LEN_ChangedAt%TYPE,
    p_value IN attributes.PR_LEN_Program_Length.PR_LEN_Program_Length%TYPE,
    p_metadata IN attributes.PR_LEN_Program_Length.Metadata_PR_LEN%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.PR_LEN_Program_Length.PR_LEN_Program_Length%TYPE,
        b IN attributes.PR_LEN_Program_Length.PR_LEN_Program_Length%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.PR_LEN_Program_Length
        FROM
            attributes.PR_LEN_Program_Length x
        WHERE
            x.PR_LEN_PR_ID = p_owner
        AND
            x.PR_LEN_ChangedAt = p_changing
    ) LOOP
        IF same(r.PR_LEN_Program_Length, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.PR_LEN_Program_Length
        FROM
            attributes.PR_LEN_Program_Length p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt < p_changing
        ORDER BY
            p.PR_LEN_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.PR_LEN_Program_Length, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.PR_LEN_ChangedAt,
            f.PR_LEN_Program_Length
        FROM
            attributes.PR_LEN_Program_Length f
        WHERE
            f.PR_LEN_PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > p_changing
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.PR_LEN_Program_Length, p_value) THEN
            DELETE FROM
                attributes.PR_LEN_Program_Length
            WHERE
                PR_LEN_PR_ID = p_owner
            AND
                PR_LEN_ChangedAt = r.PR_LEN_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO attributes.PR_LEN_Program_Length (
        Metadata_PR_LEN,
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_PR_LEN_Program_Length;
/
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates (the insert procedures of the
-- attributes, ip_<attribute>, see to that).
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
            p_changing => COALESCE(:NEW.ST_NAM_ChangedAt, v_now),
            p_value => :NEW.ST_NAM_Stage_Name,
            p_metadata => COALESCE(:NEW.Metadata_ST_NAM, :NEW.Metadata_ST)
        );
    END IF;
    IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
        attributes.ip_ST_LOC_Stage_Location(
            p_owner => COALESCE(:NEW.ST_LOC_ST_ID, v_id),
            p_value => :NEW.ST_LOC_Stage_Location,
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
            p_changing => COALESCE(:NEW.ST_AVG_ChangedAt, v_now),
            p_value => v_AVG,
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
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    IF (:NEW.ST_ID <> :OLD.ST_ID
        OR (:NEW.ST_ID IS NULL AND :OLD.ST_ID IS NOT NULL)
        OR (:NEW.ST_ID IS NOT NULL AND :OLD.ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_NAM_ST_ID <> :OLD.ST_NAM_ST_ID
        OR (:NEW.ST_NAM_ST_ID IS NULL AND :OLD.ST_NAM_ST_ID IS NOT NULL)
        OR (:NEW.ST_NAM_ST_ID IS NOT NULL AND :OLD.ST_NAM_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_NAM_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_NAM_Stage_Name <> :OLD.ST_NAM_Stage_Name
        OR (:NEW.ST_NAM_Stage_Name IS NULL AND :OLD.ST_NAM_Stage_Name IS NOT NULL)
        OR (:NEW.ST_NAM_Stage_Name IS NOT NULL AND :OLD.ST_NAM_Stage_Name IS NULL))
    OR (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
            attributes.ip_ST_NAM_Stage_Name(
                p_owner => COALESCE(:NEW.ST_NAM_ST_ID, :NEW.ST_ID),
                p_changing => CASE
                    WHEN (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
                        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
                        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL))
                    THEN :NEW.ST_NAM_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.ST_NAM_Stage_Name,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_NAM = :OLD.Metadata_ST_NAM
                            OR (:NEW.Metadata_ST_NAM IS NULL AND :OLD.Metadata_ST_NAM IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_NAM
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    IF (:NEW.ST_LOC_ST_ID <> :OLD.ST_LOC_ST_ID
        OR (:NEW.ST_LOC_ST_ID IS NULL AND :OLD.ST_LOC_ST_ID IS NOT NULL)
        OR (:NEW.ST_LOC_ST_ID IS NOT NULL AND :OLD.ST_LOC_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_LOC_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_LOC_Stage_Location <> :OLD.ST_LOC_Stage_Location
        OR (:NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL)
        OR (:NEW.ST_LOC_Stage_Location IS NOT NULL AND :OLD.ST_LOC_Stage_Location IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
            attributes.ip_ST_LOC_Stage_Location(
                p_owner => COALESCE(:NEW.ST_LOC_ST_ID, :NEW.ST_ID),
                p_value => :NEW.ST_LOC_Stage_Location,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_LOC = :OLD.Metadata_ST_LOC
                            OR (:NEW.Metadata_ST_LOC IS NULL AND :OLD.Metadata_ST_LOC IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_LOC
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    IF (:NEW.ST_AVG_ST_ID <> :OLD.ST_AVG_ST_ID
        OR (:NEW.ST_AVG_ST_ID IS NULL AND :OLD.ST_AVG_ST_ID IS NOT NULL)
        OR (:NEW.ST_AVG_ST_ID IS NOT NULL AND :OLD.ST_AVG_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_AVG_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_AVG_UTL_ID <> :OLD.ST_AVG_UTL_ID
        OR (:NEW.ST_AVG_UTL_ID IS NULL AND :OLD.ST_AVG_UTL_ID IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_ID IS NOT NULL AND :OLD.ST_AVG_UTL_ID IS NULL))
    OR (:NEW.ST_AVG_UTL_Utilization <> :OLD.ST_AVG_UTL_Utilization
        OR (:NEW.ST_AVG_UTL_Utilization IS NULL AND :OLD.ST_AVG_UTL_Utilization IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_Utilization IS NOT NULL AND :OLD.ST_AVG_UTL_Utilization IS NULL))
    OR (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_AVG := :NEW.ST_AVG_UTL_ID;
        IF (v_AVG = :OLD.ST_AVG_UTL_ID OR (v_AVG IS NULL AND :OLD.ST_AVG_UTL_ID IS NULL))
        AND :NEW.ST_AVG_UTL_Utilization IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF v_AVG IS NOT NULL AND (
            (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
                OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
                OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL)) OR
            :OLD.ST_AVG_UTL_ID IS NULL OR
            :OLD.ST_AVG_UTL_ID <> v_AVG
        ) THEN
            attributes.ip_ST_AVG_Stage_Average(
                p_owner => COALESCE(:NEW.ST_AVG_ST_ID, :NEW.ST_ID),
                p_changing => CASE
                    WHEN (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
                        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
                        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL))
                    THEN :NEW.ST_AVG_ChangedAt
                    ELSE v_now
                END,
                p_value => v_AVG,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_AVG = :OLD.Metadata_ST_AVG
                            OR (:NEW.Metadata_ST_AVG IS NULL AND :OLD.Metadata_ST_AVG IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_AVG
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    IF (:NEW.ST_MIN_ST_ID <> :OLD.ST_MIN_ST_ID
        OR (:NEW.ST_MIN_ST_ID IS NULL AND :OLD.ST_MIN_ST_ID IS NOT NULL)
        OR (:NEW.ST_MIN_ST_ID IS NOT NULL AND :OLD.ST_MIN_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_MIN_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_MIN_UTL_ID <> :OLD.ST_MIN_UTL_ID
        OR (:NEW.ST_MIN_UTL_ID IS NULL AND :OLD.ST_MIN_UTL_ID IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_ID IS NOT NULL AND :OLD.ST_MIN_UTL_ID IS NULL))
    OR (:NEW.ST_MIN_UTL_Utilization <> :OLD.ST_MIN_UTL_Utilization
        OR (:NEW.ST_MIN_UTL_Utilization IS NULL AND :OLD.ST_MIN_UTL_Utilization IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_Utilization IS NOT NULL AND :OLD.ST_MIN_UTL_Utilization IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_MIN := :NEW.ST_MIN_UTL_ID;
        IF (v_MIN = :OLD.ST_MIN_UTL_ID OR (v_MIN IS NULL AND :OLD.ST_MIN_UTL_ID IS NULL))
        AND :NEW.ST_MIN_UTL_Utilization IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF v_MIN IS NOT NULL AND (
            :OLD.ST_MIN_UTL_ID IS NULL OR
            :OLD.ST_MIN_UTL_ID <> v_MIN
        ) THEN
            attributes.ip_ST_MIN_Stage_Minimum(
                p_owner => COALESCE(:NEW.ST_MIN_ST_ID, :NEW.ST_ID),
                p_value => v_MIN,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_MIN = :OLD.Metadata_ST_MIN
                            OR (:NEW.Metadata_ST_MIN IS NULL AND :OLD.Metadata_ST_MIN IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_MIN
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_ST_MIN = 1
    AND :OLD.ST_MIN_UTL_ID IS NOT NULL
    AND (:NEW.ST_MIN_UTL_ID IS NULL OR :NEW.ST_MIN_UTL_Utilization IS NULL)
    THEN
        INSERT INTO attributes.ST_MIN_Stage_Minimum_Deleted (
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID,
            Metadata_ST_MIN,
            ST_MIN_Deleted
        )
        SELECT
            x.ST_MIN_ST_ID,
            x.ST_MIN_UTL_ID,
            x.Metadata_ST_MIN,
            v_now
        FROM
            attributes.ST_MIN_Stage_Minimum x
        WHERE
            x.ST_MIN_ST_ID = :OLD.ST_ID;
        DELETE FROM
            attributes.ST_MIN_Stage_Minimum
        WHERE
            ST_MIN_ST_ID = :OLD.ST_ID;
    END IF;
END ut_lST_Stage;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lST_Stage
INSTEAD OF DELETE ON anchors.lST_Stage
FOR EACH ROW
BEGIN
    DELETE FROM
        attributes.ST_NAM_Stage_Name x
    WHERE
        x.ST_NAM_ST_ID = :OLD.ST_ID
    AND
        x.ST_NAM_ChangedAt = :OLD.ST_NAM_ChangedAt
    ;
    DELETE FROM
        attributes.ST_LOC_Stage_Location x
    WHERE
        x.ST_LOC_ST_ID = :OLD.ST_ID
    ;
    DELETE FROM
        attributes.ST_AVG_Stage_Average x
    WHERE
        x.ST_AVG_ST_ID = :OLD.ST_ID
    AND
        x.ST_AVG_ChangedAt = :OLD.ST_AVG_ChangedAt
    ;
    DELETE FROM
        attributes.ST_MIN_Stage_Minimum x
    WHERE
        x.ST_MIN_ST_ID = :OLD.ST_ID
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors.ST_Stage a
    WHERE
        a.ST_ID = :OLD.ST_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_NAM_Stage_Name x
        WHERE
            x.ST_NAM_ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_LOC_Stage_Location x
        WHERE
            x.ST_LOC_ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_AVG_Stage_Average x
        WHERE
            x.ST_AVG_ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_MIN_Stage_Minimum x
        WHERE
            x.ST_MIN_ST_ID = a.ST_ID
    )
    ;
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
            p_changing => COALESCE(:NEW.AC_NAM_ChangedAt, v_now),
            p_value => :NEW.AC_NAM_Actor_Name,
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
            p_changing => COALESCE(:NEW.AC_PLV_ChangedAt, v_now),
            p_value => v_PLV,
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
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    IF (:NEW.AC_ID <> :OLD.AC_ID
        OR (:NEW.AC_ID IS NULL AND :OLD.AC_ID IS NOT NULL)
        OR (:NEW.AC_ID IS NOT NULL AND :OLD.AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_NAM_AC_ID <> :OLD.AC_NAM_AC_ID
        OR (:NEW.AC_NAM_AC_ID IS NULL AND :OLD.AC_NAM_AC_ID IS NOT NULL)
        OR (:NEW.AC_NAM_AC_ID IS NOT NULL AND :OLD.AC_NAM_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_NAM_AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_NAM_Actor_Name <> :OLD.AC_NAM_Actor_Name
        OR (:NEW.AC_NAM_Actor_Name IS NULL AND :OLD.AC_NAM_Actor_Name IS NOT NULL)
        OR (:NEW.AC_NAM_Actor_Name IS NOT NULL AND :OLD.AC_NAM_Actor_Name IS NULL))
    OR (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
            attributes.ip_AC_NAM_Actor_Name(
                p_owner => COALESCE(:NEW.AC_NAM_AC_ID, :NEW.AC_ID),
                p_changing => CASE
                    WHEN (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
                        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL))
                    THEN :NEW.AC_NAM_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.AC_NAM_Actor_Name,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
                            OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
                            OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL))
                        AND (:NEW.Metadata_AC_NAM = :OLD.Metadata_AC_NAM
                            OR (:NEW.Metadata_AC_NAM IS NULL AND :OLD.Metadata_AC_NAM IS NULL))
                        THEN :NEW.Metadata_AC
                        ELSE :NEW.Metadata_AC_NAM
                    END, :NEW.Metadata_AC)
            );
        END IF;
    END IF;
    IF (:NEW.AC_GEN_AC_ID <> :OLD.AC_GEN_AC_ID
        OR (:NEW.AC_GEN_AC_ID IS NULL AND :OLD.AC_GEN_AC_ID IS NOT NULL)
        OR (:NEW.AC_GEN_AC_ID IS NOT NULL AND :OLD.AC_GEN_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_GEN_AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_GEN_GEN_ID <> :OLD.AC_GEN_GEN_ID
        OR (:NEW.AC_GEN_GEN_ID IS NULL AND :OLD.AC_GEN_GEN_ID IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_ID IS NOT NULL AND :OLD.AC_GEN_GEN_ID IS NULL))
    OR (:NEW.AC_GEN_GEN_Gender <> :OLD.AC_GEN_GEN_Gender
        OR (:NEW.AC_GEN_GEN_Gender IS NULL AND :OLD.AC_GEN_GEN_Gender IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_Gender IS NOT NULL AND :OLD.AC_GEN_GEN_Gender IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_GEN := :NEW.AC_GEN_GEN_ID;
        IF (v_GEN = :OLD.AC_GEN_GEN_ID OR (v_GEN IS NULL AND :OLD.AC_GEN_GEN_ID IS NULL))
        AND :NEW.AC_GEN_GEN_Gender IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF v_GEN IS NOT NULL AND (
            :OLD.AC_GEN_GEN_ID IS NULL OR
            :OLD.AC_GEN_GEN_ID <> v_GEN
        ) THEN
            attributes.ip_AC_GEN_Actor_Gender(
                p_owner => COALESCE(:NEW.AC_GEN_AC_ID, :NEW.AC_ID),
                p_value => v_GEN,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
                            OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
                            OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL))
                        AND (:NEW.Metadata_AC_GEN = :OLD.Metadata_AC_GEN
                            OR (:NEW.Metadata_AC_GEN IS NULL AND :OLD.Metadata_AC_GEN IS NULL))
                        THEN :NEW.Metadata_AC
                        ELSE :NEW.Metadata_AC_GEN
                    END, :NEW.Metadata_AC)
            );
        END IF;
    END IF;
    IF (:NEW.AC_PLV_AC_ID <> :OLD.AC_PLV_AC_ID
        OR (:NEW.AC_PLV_AC_ID IS NULL AND :OLD.AC_PLV_AC_ID IS NOT NULL)
        OR (:NEW.AC_PLV_AC_ID IS NOT NULL AND :OLD.AC_PLV_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_PLV_AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_PLV_PLV_ID <> :OLD.AC_PLV_PLV_ID
        OR (:NEW.AC_PLV_PLV_ID IS NULL AND :OLD.AC_PLV_PLV_ID IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_ID IS NOT NULL AND :OLD.AC_PLV_PLV_ID IS NULL))
    OR (:NEW.AC_PLV_PLV_ProfessionalLevel <> :OLD.AC_PLV_PLV_ProfessionalLevel
        OR (:NEW.AC_PLV_PLV_ProfessionalLevel IS NULL AND :OLD.AC_PLV_PLV_ProfessionalLevel IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_ProfessionalLevel IS NOT NULL AND :OLD.AC_PLV_PLV_ProfessionalLevel IS NULL))
    OR (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_PLV := :NEW.AC_PLV_PLV_ID;
        IF (v_PLV = :OLD.AC_PLV_PLV_ID OR (v_PLV IS NULL AND :OLD.AC_PLV_PLV_ID IS NULL))
        AND :NEW.AC_PLV_PLV_ProfessionalLevel IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF v_PLV IS NOT NULL AND (
            (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
                OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
                OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL)) OR
            :OLD.AC_PLV_PLV_ID IS NULL OR
            :OLD.AC_PLV_PLV_ID <> v_PLV
        ) THEN
            attributes.ip_AC_PLV_Actor_ProfessionalLevel(
                p_owner => COALESCE(:NEW.AC_PLV_AC_ID, :NEW.AC_ID),
                p_changing => CASE
                    WHEN (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
                        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL))
                    THEN :NEW.AC_PLV_ChangedAt
                    ELSE v_now
                END,
                p_value => v_PLV,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
                            OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
                            OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL))
                        AND (:NEW.Metadata_AC_PLV = :OLD.Metadata_AC_PLV
                            OR (:NEW.Metadata_AC_PLV IS NULL AND :OLD.Metadata_AC_PLV IS NULL))
                        THEN :NEW.Metadata_AC
                        ELSE :NEW.Metadata_AC_PLV
                    END, :NEW.Metadata_AC)
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
BEGIN
    DELETE FROM
        attributes.AC_NAM_Actor_Name x
    WHERE
        x.AC_NAM_AC_ID = :OLD.AC_ID
    AND
        x.AC_NAM_ChangedAt = :OLD.AC_NAM_ChangedAt
    ;
    DELETE FROM
        attributes.AC_GEN_Actor_Gender x
    WHERE
        x.AC_GEN_AC_ID = :OLD.AC_ID
    ;
    DELETE FROM
        attributes.AC_PLV_Actor_ProfessionalLevel x
    WHERE
        x.AC_PLV_AC_ID = :OLD.AC_ID
    AND
        x.AC_PLV_ChangedAt = :OLD.AC_PLV_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors.AC_Actor a
    WHERE
        a.AC_ID = :OLD.AC_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.AC_NAM_Actor_Name x
        WHERE
            x.AC_NAM_AC_ID = a.AC_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.AC_GEN_Actor_Gender x
        WHERE
            x.AC_GEN_AC_ID = a.AC_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel x
        WHERE
            x.AC_PLV_AC_ID = a.AC_ID
    )
    ;
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
            p_metadata => COALESCE(:NEW.Metadata_PR_NAM, :NEW.Metadata_PR)
        );
    END IF;
    IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
        attributes.ip_PR_LEN_Program_Length(
            p_owner => COALESCE(:NEW.PR_LEN_PR_ID, v_id),
            p_changing => COALESCE(:NEW.PR_LEN_ChangedAt, v_now),
            p_value => :NEW.PR_LEN_Program_Length,
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
BEGIN
    IF (:NEW.PR_ID <> :OLD.PR_ID
        OR (:NEW.PR_ID IS NULL AND :OLD.PR_ID IS NOT NULL)
        OR (:NEW.PR_ID IS NOT NULL AND :OLD.PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_PR_ID <> :OLD.PR_NAM_PR_ID
        OR (:NEW.PR_NAM_PR_ID IS NULL AND :OLD.PR_NAM_PR_ID IS NOT NULL)
        OR (:NEW.PR_NAM_PR_ID IS NOT NULL AND :OLD.PR_NAM_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_NAM_PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_Program_Name <> :OLD.PR_NAM_Program_Name
        OR (:NEW.PR_NAM_Program_Name IS NULL AND :OLD.PR_NAM_Program_Name IS NOT NULL)
        OR (:NEW.PR_NAM_Program_Name IS NOT NULL AND :OLD.PR_NAM_Program_Name IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
            attributes.ip_PR_NAM_Program_Name(
                p_owner => COALESCE(:NEW.PR_NAM_PR_ID, :NEW.PR_ID),
                p_value => :NEW.PR_NAM_Program_Name,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_PR <> :OLD.Metadata_PR
                            OR (:NEW.Metadata_PR IS NULL AND :OLD.Metadata_PR IS NOT NULL)
                            OR (:NEW.Metadata_PR IS NOT NULL AND :OLD.Metadata_PR IS NULL))
                        AND (:NEW.Metadata_PR_NAM = :OLD.Metadata_PR_NAM
                            OR (:NEW.Metadata_PR_NAM IS NULL AND :OLD.Metadata_PR_NAM IS NULL))
                        THEN :NEW.Metadata_PR
                        ELSE :NEW.Metadata_PR_NAM
                    END, :NEW.Metadata_PR)
            );
        END IF;
    END IF;
    IF (:NEW.PR_LEN_PR_ID <> :OLD.PR_LEN_PR_ID
        OR (:NEW.PR_LEN_PR_ID IS NULL AND :OLD.PR_LEN_PR_ID IS NOT NULL)
        OR (:NEW.PR_LEN_PR_ID IS NOT NULL AND :OLD.PR_LEN_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_LEN_PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_LEN_Program_Length <> :OLD.PR_LEN_Program_Length
        OR (:NEW.PR_LEN_Program_Length IS NULL AND :OLD.PR_LEN_Program_Length IS NOT NULL)
        OR (:NEW.PR_LEN_Program_Length IS NOT NULL AND :OLD.PR_LEN_Program_Length IS NULL))
    OR (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
            attributes.ip_PR_LEN_Program_Length(
                p_owner => COALESCE(:NEW.PR_LEN_PR_ID, :NEW.PR_ID),
                p_changing => CASE
                    WHEN (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
                        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
                        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL))
                    THEN :NEW.PR_LEN_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.PR_LEN_Program_Length,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_PR <> :OLD.Metadata_PR
                            OR (:NEW.Metadata_PR IS NULL AND :OLD.Metadata_PR IS NOT NULL)
                            OR (:NEW.Metadata_PR IS NOT NULL AND :OLD.Metadata_PR IS NULL))
                        AND (:NEW.Metadata_PR_LEN = :OLD.Metadata_PR_LEN
                            OR (:NEW.Metadata_PR_LEN IS NULL AND :OLD.Metadata_PR_LEN IS NULL))
                        THEN :NEW.Metadata_PR
                        ELSE :NEW.Metadata_PR_LEN
                    END, :NEW.Metadata_PR)
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
BEGIN
    DELETE FROM
        attributes.PR_NAM_Program_Name x
    WHERE
        x.PR_NAM_PR_ID = :OLD.PR_ID
    ;
    DELETE FROM
        attributes.PR_LEN_Program_Length x
    WHERE
        x.PR_LEN_PR_ID = :OLD.PR_ID
    AND
        x.PR_LEN_ChangedAt = :OLD.PR_LEN_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors.PR_Program a
    WHERE
        a.PR_ID = :OLD.PR_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.PR_NAM_Program_Name x
        WHERE
            x.PR_NAM_PR_ID = a.PR_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.PR_LEN_Program_Length x
        WHERE
            x.PR_LEN_PR_ID = a.PR_ID
    )
    ;
END dt_lPR_Program;
/
-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates (the insert procedures of the
-- attributes, ip_<attribute>, see to that).
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
    v_ETY_of number(3);
    v_UTL number(3);
    v_LVL number(3);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        -- the identity of the knot value of the role, given as it is or looked up from the value
        v_ETY_of := :NEW.ETY_ID_of;
        IF v_ETY_of IS NULL AND :NEW.of_ETY_EventType IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.ETY_ID
                FROM
                    knots.ETY_EventType k
                WHERE
                    k.ETY_Checksum = STANDARD_HASH(:NEW.of_ETY_EventType, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_ETY_of := kv.ETY_ID;
            END LOOP;
        END IF;
        INSERT INTO nexuses.EV_Event (
            ST_ID_wasHeldAt,
            PR_ID_wasPlayed,
            ETY_ID_of,
            Metadata_EV
        )
        VALUES (
            :NEW.ST_ID_wasHeldAt,
            :NEW.PR_ID_wasPlayed,
            v_ETY_of,
            :NEW.Metadata_EV
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_DAT_Event_Date IS NOT NULL THEN
        attributes.ip_EV_DAT_Event_Date(
            p_owner => COALESCE(:NEW.EV_DAT_EV_ID, v_id),
            p_value => :NEW.EV_DAT_Event_Date,
            p_metadata => COALESCE(:NEW.Metadata_EV_DAT, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
        attributes.ip_EV_AUD_Event_Audience(
            p_owner => COALESCE(:NEW.EV_AUD_EV_ID, v_id),
            p_value => :NEW.EV_AUD_Event_Audience,
            p_metadata => COALESCE(:NEW.Metadata_EV_AUD, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
        attributes.ip_EV_REV_Event_Revenue(
            p_owner => COALESCE(:NEW.EV_REV_EV_ID, v_id),
            p_value => :NEW.EV_REV_Event_Revenue,
            p_metadata => COALESCE(:NEW.Metadata_EV_REV, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_STA_Event_Status IS NOT NULL THEN
        attributes.ip_EV_STA_Event_Status(
            p_owner => COALESCE(:NEW.EV_STA_EV_ID, v_id),
            p_changing => COALESCE(:NEW.EV_STA_ChangedAt, v_now),
            p_value => :NEW.EV_STA_Event_Status,
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
            p_changing => COALESCE(:NEW.EV_LVL_ChangedAt, v_now),
            p_value => v_LVL,
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
    v_UTL number(3);
    v_LVL number(3);
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
    IF (:NEW.EV_DAT_EV_ID <> :OLD.EV_DAT_EV_ID
        OR (:NEW.EV_DAT_EV_ID IS NULL AND :OLD.EV_DAT_EV_ID IS NOT NULL)
        OR (:NEW.EV_DAT_EV_ID IS NOT NULL AND :OLD.EV_DAT_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_DAT_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_DAT_Event_Date <> :OLD.EV_DAT_Event_Date
        OR (:NEW.EV_DAT_Event_Date IS NULL AND :OLD.EV_DAT_Event_Date IS NOT NULL)
        OR (:NEW.EV_DAT_Event_Date IS NOT NULL AND :OLD.EV_DAT_Event_Date IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_DAT_Event_Date IS NOT NULL THEN
            attributes.ip_EV_DAT_Event_Date(
                p_owner => COALESCE(:NEW.EV_DAT_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_DAT_Event_Date,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_DAT = :OLD.Metadata_EV_DAT
                            OR (:NEW.Metadata_EV_DAT IS NULL AND :OLD.Metadata_EV_DAT IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_DAT
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_AUD_EV_ID <> :OLD.EV_AUD_EV_ID
        OR (:NEW.EV_AUD_EV_ID IS NULL AND :OLD.EV_AUD_EV_ID IS NOT NULL)
        OR (:NEW.EV_AUD_EV_ID IS NOT NULL AND :OLD.EV_AUD_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_AUD_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_AUD_Event_Audience <> :OLD.EV_AUD_Event_Audience
        OR (:NEW.EV_AUD_Event_Audience IS NULL AND :OLD.EV_AUD_Event_Audience IS NOT NULL)
        OR (:NEW.EV_AUD_Event_Audience IS NOT NULL AND :OLD.EV_AUD_Event_Audience IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
            attributes.ip_EV_AUD_Event_Audience(
                p_owner => COALESCE(:NEW.EV_AUD_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_AUD_Event_Audience,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_AUD = :OLD.Metadata_EV_AUD
                            OR (:NEW.Metadata_EV_AUD IS NULL AND :OLD.Metadata_EV_AUD IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_AUD
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_REV_EV_ID <> :OLD.EV_REV_EV_ID
        OR (:NEW.EV_REV_EV_ID IS NULL AND :OLD.EV_REV_EV_ID IS NOT NULL)
        OR (:NEW.EV_REV_EV_ID IS NOT NULL AND :OLD.EV_REV_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_REV_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_REV_Event_Revenue <> :OLD.EV_REV_Event_Revenue
        OR (:NEW.EV_REV_Event_Revenue IS NULL AND :OLD.EV_REV_Event_Revenue IS NOT NULL)
        OR (:NEW.EV_REV_Event_Revenue IS NOT NULL AND :OLD.EV_REV_Event_Revenue IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
            attributes.ip_EV_REV_Event_Revenue(
                p_owner => COALESCE(:NEW.EV_REV_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_REV_Event_Revenue,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_REV = :OLD.Metadata_EV_REV
                            OR (:NEW.Metadata_EV_REV IS NULL AND :OLD.Metadata_EV_REV IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_REV
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_STA_EV_ID <> :OLD.EV_STA_EV_ID
        OR (:NEW.EV_STA_EV_ID IS NULL AND :OLD.EV_STA_EV_ID IS NOT NULL)
        OR (:NEW.EV_STA_EV_ID IS NOT NULL AND :OLD.EV_STA_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_STA_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_STA_Event_Status <> :OLD.EV_STA_Event_Status
        OR (:NEW.EV_STA_Event_Status IS NULL AND :OLD.EV_STA_Event_Status IS NOT NULL)
        OR (:NEW.EV_STA_Event_Status IS NOT NULL AND :OLD.EV_STA_Event_Status IS NULL))
    OR (:NEW.EV_STA_ChangedAt <> :OLD.EV_STA_ChangedAt
        OR (:NEW.EV_STA_ChangedAt IS NULL AND :OLD.EV_STA_ChangedAt IS NOT NULL)
        OR (:NEW.EV_STA_ChangedAt IS NOT NULL AND :OLD.EV_STA_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_STA_Event_Status IS NOT NULL THEN
            attributes.ip_EV_STA_Event_Status(
                p_owner => COALESCE(:NEW.EV_STA_EV_ID, :NEW.EV_ID),
                p_changing => CASE
                    WHEN (:NEW.EV_STA_ChangedAt <> :OLD.EV_STA_ChangedAt
                        OR (:NEW.EV_STA_ChangedAt IS NULL AND :OLD.EV_STA_ChangedAt IS NOT NULL)
                        OR (:NEW.EV_STA_ChangedAt IS NOT NULL AND :OLD.EV_STA_ChangedAt IS NULL))
                    THEN :NEW.EV_STA_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.EV_STA_Event_Status,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_STA = :OLD.Metadata_EV_STA
                            OR (:NEW.Metadata_EV_STA IS NULL AND :OLD.Metadata_EV_STA IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_STA
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_UTL_EV_ID <> :OLD.EV_UTL_EV_ID
        OR (:NEW.EV_UTL_EV_ID IS NULL AND :OLD.EV_UTL_EV_ID IS NOT NULL)
        OR (:NEW.EV_UTL_EV_ID IS NOT NULL AND :OLD.EV_UTL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_UTL_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_UTL_UTL_ID <> :OLD.EV_UTL_UTL_ID
        OR (:NEW.EV_UTL_UTL_ID IS NULL AND :OLD.EV_UTL_UTL_ID IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_ID IS NOT NULL AND :OLD.EV_UTL_UTL_ID IS NULL))
    OR (:NEW.EV_UTL_UTL_Utilization <> :OLD.EV_UTL_UTL_Utilization
        OR (:NEW.EV_UTL_UTL_Utilization IS NULL AND :OLD.EV_UTL_UTL_Utilization IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_Utilization IS NOT NULL AND :OLD.EV_UTL_UTL_Utilization IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_UTL := :NEW.EV_UTL_UTL_ID;
        IF (v_UTL = :OLD.EV_UTL_UTL_ID OR (v_UTL IS NULL AND :OLD.EV_UTL_UTL_ID IS NULL))
        AND :NEW.EV_UTL_UTL_Utilization IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF v_UTL IS NOT NULL AND (
            :OLD.EV_UTL_UTL_ID IS NULL OR
            :OLD.EV_UTL_UTL_ID <> v_UTL
        ) THEN
            attributes.ip_EV_UTL_Event_Utilization(
                p_owner => COALESCE(:NEW.EV_UTL_EV_ID, :NEW.EV_ID),
                p_value => v_UTL,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_UTL = :OLD.Metadata_EV_UTL
                            OR (:NEW.Metadata_EV_UTL IS NULL AND :OLD.Metadata_EV_UTL IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_UTL
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_LVL_EV_ID <> :OLD.EV_LVL_EV_ID
        OR (:NEW.EV_LVL_EV_ID IS NULL AND :OLD.EV_LVL_EV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_EV_ID IS NOT NULL AND :OLD.EV_LVL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_LVL_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_LVL_PLV_ID <> :OLD.EV_LVL_PLV_ID
        OR (:NEW.EV_LVL_PLV_ID IS NULL AND :OLD.EV_LVL_PLV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_ID IS NOT NULL AND :OLD.EV_LVL_PLV_ID IS NULL))
    OR (:NEW.EV_LVL_PLV_ProfessionalLevel <> :OLD.EV_LVL_PLV_ProfessionalLevel
        OR (:NEW.EV_LVL_PLV_ProfessionalLevel IS NULL AND :OLD.EV_LVL_PLV_ProfessionalLevel IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_ProfessionalLevel IS NOT NULL AND :OLD.EV_LVL_PLV_ProfessionalLevel IS NULL))
    OR (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
        OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
        OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_LVL := :NEW.EV_LVL_PLV_ID;
        IF (v_LVL = :OLD.EV_LVL_PLV_ID OR (v_LVL IS NULL AND :OLD.EV_LVL_PLV_ID IS NULL))
        AND :NEW.EV_LVL_PLV_ProfessionalLevel IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF v_LVL IS NOT NULL AND (
            (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
                OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
                OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL)) OR
            :OLD.EV_LVL_PLV_ID IS NULL OR
            :OLD.EV_LVL_PLV_ID <> v_LVL
        ) THEN
            attributes.ip_EV_LVL_Event_Level(
                p_owner => COALESCE(:NEW.EV_LVL_EV_ID, :NEW.EV_ID),
                p_changing => CASE
                    WHEN (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
                        OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
                        OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL))
                    THEN :NEW.EV_LVL_ChangedAt
                    ELSE v_now
                END,
                p_value => v_LVL,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_LVL = :OLD.Metadata_EV_LVL
                            OR (:NEW.Metadata_EV_LVL IS NULL AND :OLD.Metadata_EV_LVL IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_LVL
                    END, :NEW.Metadata_EV)
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
BEGIN
    DELETE FROM
        attributes.EV_DAT_Event_Date x
    WHERE
        x.EV_DAT_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_AUD_Event_Audience x
    WHERE
        x.EV_AUD_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_REV_Event_Revenue x
    WHERE
        x.EV_REV_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_STA_Event_Status x
    WHERE
        x.EV_STA_EV_ID = :OLD.EV_ID
    AND
        x.EV_STA_ChangedAt = :OLD.EV_STA_ChangedAt
    ;
    DELETE FROM
        attributes.EV_UTL_Event_Utilization x
    WHERE
        x.EV_UTL_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_LVL_Event_Level x
    WHERE
        x.EV_LVL_EV_ID = :OLD.EV_ID
    AND
        x.EV_LVL_ChangedAt = :OLD.EV_LVL_ChangedAt
    ;
    -- a nexus that has no attribute rows left is removed
    DELETE FROM
        nexuses.EV_Event a
    WHERE
        a.EV_ID = :OLD.EV_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_DAT_Event_Date x
        WHERE
            x.EV_DAT_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_AUD_Event_Audience x
        WHERE
            x.EV_AUD_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_REV_Event_Revenue x
        WHERE
            x.EV_REV_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_STA_Event_Status x
        WHERE
            x.EV_STA_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_UTL_Event_Utilization x
        WHERE
            x.EV_UTL_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_LVL_Event_Level x
        WHERE
            x.EV_LVL_EV_ID = a.EV_ID
    )
    ;
END dt_lEV_Event;
/
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- A tie and its latest view behave like a table that is loaded with plain statements. The rules for a row of a tie (it is
-- stored only when it is not there already, a contradiction is refused and, for an idempotent tie, what only states again
-- what the row before it says is left out) are in an insert procedure for each tie, ip_<tie>. The latest view has
-- three 'instead of' triggers: insert, update, and delete. They propagate such operations to the tie table in a consistent
-- way, the insert and update triggers by calling the insert procedure. Default values are used for some columns if not
-- provided by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- The rules are in procedures and not in a trigger on the tie table, since Oracle does not let a row trigger read the table
-- it is on (ORA-04091), which these rules do. A load can call the procedure itself:
--
--     BEGIN ip_AC_parent_AC_child(p_AC_parent => 1, p_AC_child => 2); END;
--
-- A row put straight into a tie table by an INSERT is not looked at.
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_partner_AC_with_ONG_currently states a row of AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_partner_AC_with_ONG_currently (
    p_AC_partner IN ties.AC_partner_AC_with_ONG_currently.AC_ID_partner%TYPE,
    p_AC_with IN ties.AC_partner_AC_with_ONG_currently.AC_ID_with%TYPE,
    p_ONG_currently IN ties.AC_partner_AC_with_ONG_currently.ONG_ID_currently%TYPE,
    p_changing IN ties.AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE,
    p_metadata IN ties.AC_partner_AC_with_ONG_currently.Metadata_AC_partner_AC_with_ONG_currently%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_metadata ties.AC_partner_AC_with_ONG_currently.Metadata_AC_partner_AC_with_ONG_currently%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_partner_AC_with_ONG_currently x
        WHERE
            x.AC_ID_partner = p_AC_partner
        AND
            x.AC_ID_with = p_AC_with
        AND
            x.ONG_ID_currently = p_ONG_currently
        AND
            x.AC_partner_AC_with_ONG_currently_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.AC_partner_AC_with_ONG_currently (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    VALUES (
        v_metadata,
        v_changing,
        p_AC_partner,
        p_AC_with,
        p_ONG_currently
    );
END ip_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
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
        p_changing => :NEW.AC_partner_AC_with_ONG_currently_ChangedAt,
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
    v_changed NUMBER(1);
    v_changing ties.AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_ONG_currently number(3);
BEGIN
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF (:NEW.currently_ONG_Ongoing <> :OLD.currently_ONG_Ongoing
        OR (:NEW.currently_ONG_Ongoing IS NULL AND :OLD.currently_ONG_Ongoing IS NOT NULL)
        OR (:NEW.currently_ONG_Ongoing IS NOT NULL AND :OLD.currently_ONG_Ongoing IS NULL)) THEN
        v_ONG_currently := NULL;
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
    -- values that are left as they are state nothing
    IF
        :NEW.AC_ID_partner IS NOT NULL
    AND
        :NEW.AC_ID_with IS NOT NULL
    AND
        v_ONG_currently IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.AC_ID_partner <> :OLD.AC_ID_partner
                OR (:NEW.AC_ID_partner IS NULL AND :OLD.AC_ID_partner IS NOT NULL)
                OR (:NEW.AC_ID_partner IS NOT NULL AND :OLD.AC_ID_partner IS NULL))
        OR
            (:NEW.AC_ID_with <> :OLD.AC_ID_with
                OR (:NEW.AC_ID_with IS NULL AND :OLD.AC_ID_with IS NOT NULL)
                OR (:NEW.AC_ID_with IS NOT NULL AND :OLD.AC_ID_with IS NULL))
        OR
            (v_ONG_currently <> :OLD.ONG_ID_currently
                OR (v_ONG_currently IS NULL AND :OLD.ONG_ID_currently IS NOT NULL)
                OR (v_ONG_currently IS NOT NULL AND :OLD.ONG_ID_currently IS NULL))
        )
    THEN
        ties.ip_AC_partner_AC_with_ONG_currently(
            p_AC_partner => :NEW.AC_ID_partner,
            p_AC_with => :NEW.AC_ID_with,
            p_ONG_currently => v_ONG_currently,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
        );
    END IF;
END ut_lAC_partner_AC_with_ONG_currently;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_partner_AC_with_ONG_currently
INSTEAD OF DELETE ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_partner_AC_with_ONG_currently x
    WHERE
        x.AC_partner_AC_with_ONG_currently_ChangedAt = :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
    AND
        x.AC_ID_partner = :OLD.AC_ID_partner
    AND
        x.AC_ID_with = :OLD.AC_ID_with
    AND
        x.ONG_ID_currently = :OLD.ONG_ID_currently
    ;
END dt_lAC_partner_AC_with_ONG_currently;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_subset_PN_of states a row of AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_subset_PN_of (
    p_AC_subset IN ties.AC_subset_PN_of.AC_ID_subset%TYPE,
    p_PN_of IN ties.AC_subset_PN_of.PN_ID_of%TYPE,
    p_metadata IN ties.AC_subset_PN_of.Metadata_AC_subset_PN_of%TYPE
)
IS
    v_metadata ties.AC_subset_PN_of.Metadata_AC_subset_PN_of%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_subset_PN_of x
        WHERE
            x.AC_ID_subset = p_AC_subset
        AND
            x.PN_ID_of = p_PN_of
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.AC_subset_PN_of (
        Metadata_AC_subset_PN_of,
        AC_ID_subset,
        PN_ID_of
    )
    VALUES (
        v_metadata,
        p_AC_subset,
        p_PN_of
    );
END ip_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_subset_PN_of
INSTEAD OF INSERT ON ties.lAC_subset_PN_of
FOR EACH ROW
BEGIN
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
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
BEGIN
    -- values that are left as they are state nothing
    IF
        :NEW.AC_ID_subset IS NOT NULL
    AND
        :NEW.PN_ID_of IS NOT NULL
    AND
        (
            (:NEW.AC_ID_subset <> :OLD.AC_ID_subset
                OR (:NEW.AC_ID_subset IS NULL AND :OLD.AC_ID_subset IS NOT NULL)
                OR (:NEW.AC_ID_subset IS NOT NULL AND :OLD.AC_ID_subset IS NULL))
        OR
            (:NEW.PN_ID_of <> :OLD.PN_ID_of
                OR (:NEW.PN_ID_of IS NULL AND :OLD.PN_ID_of IS NOT NULL)
                OR (:NEW.PN_ID_of IS NOT NULL AND :OLD.PN_ID_of IS NULL))
        )
    THEN
        ties.ip_AC_subset_PN_of(
            p_AC_subset => :NEW.AC_ID_subset,
            p_PN_of => :NEW.PN_ID_of,
            p_metadata => :NEW.Metadata_AC_subset_PN_of
        );
    END IF;
END ut_lAC_subset_PN_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_subset_PN_of
INSTEAD OF DELETE ON ties.lAC_subset_PN_of
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_subset_PN_of x
    WHERE
        x.AC_ID_subset = :OLD.AC_ID_subset
    AND
        x.PN_ID_of = :OLD.PN_ID_of
    ;
END dt_lAC_subset_PN_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_in_AC_wasCast states a row of EV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_EV_in_AC_wasCast (
    p_EV_in IN ties.EV_in_AC_wasCast.EV_ID_in%TYPE,
    p_AC_wasCast IN ties.EV_in_AC_wasCast.AC_ID_wasCast%TYPE,
    p_metadata IN ties.EV_in_AC_wasCast.Metadata_EV_in_AC_wasCast%TYPE
)
IS
    v_metadata ties.EV_in_AC_wasCast.Metadata_EV_in_AC_wasCast%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.EV_in_AC_wasCast x
        WHERE
            x.EV_ID_in = p_EV_in
        AND
            x.AC_ID_wasCast = p_AC_wasCast
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.EV_in_AC_wasCast (
        Metadata_EV_in_AC_wasCast,
        EV_ID_in,
        AC_ID_wasCast
    )
    VALUES (
        v_metadata,
        p_EV_in,
        p_AC_wasCast
    );
END ip_EV_in_AC_wasCast;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lEV_in_AC_wasCast
INSTEAD OF INSERT ON ties.lEV_in_AC_wasCast
FOR EACH ROW
BEGIN
    ties.ip_EV_in_AC_wasCast(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_wasCast => :NEW.AC_ID_wasCast,
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
BEGIN
    DELETE FROM
        ties.EV_in_AC_wasCast x
    WHERE
        x.EV_ID_in = :OLD.EV_ID_in
    AND
        x.AC_ID_wasCast = :OLD.AC_ID_wasCast
    ;
END dt_lEV_in_AC_wasCast;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_part_PR_in_RAT_got states a row of AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_part_PR_in_RAT_got (
    p_AC_part IN ties.AC_part_PR_in_RAT_got.AC_ID_part%TYPE,
    p_PR_in IN ties.AC_part_PR_in_RAT_got.PR_ID_in%TYPE,
    p_RAT_got IN ties.AC_part_PR_in_RAT_got.RAT_ID_got%TYPE,
    p_changing IN ties.AC_part_PR_in_RAT_got.AC_part_PR_in_RAT_got_ChangedAt%TYPE,
    p_metadata IN ties.AC_part_PR_in_RAT_got.Metadata_AC_part_PR_in_RAT_got%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.AC_part_PR_in_RAT_got.AC_part_PR_in_RAT_got_ChangedAt%TYPE;
    v_metadata ties.AC_part_PR_in_RAT_got.Metadata_AC_part_PR_in_RAT_got%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_part_PR_in_RAT_got x
        WHERE
            x.AC_ID_part = p_AC_part
        AND
            x.PR_ID_in = p_PR_in
        AND
            x.RAT_ID_got = p_RAT_got
        AND
            x.AC_part_PR_in_RAT_got_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_part_PR_in_RAT_got x
        WHERE
            x.AC_ID_part = p_AC_part
        AND
            x.PR_ID_in = p_PR_in
        AND
            x.AC_part_PR_in_RAT_got_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_part_PR_in_RAT_got for: '
            || p_AC_part
            || ', '
            || p_PR_in
            || ', '
            || v_changing
        );
    END LOOP;
    INSERT INTO ties.AC_part_PR_in_RAT_got (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    VALUES (
        v_metadata,
        v_changing,
        p_AC_part,
        p_PR_in,
        p_RAT_got
    );
END ip_AC_part_PR_in_RAT_got;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_part_PR_in_RAT_got
INSTEAD OF INSERT ON ties.lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_RAT_got number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
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
        p_changing => :NEW.AC_part_PR_in_RAT_got_ChangedAt,
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
    v_changed NUMBER(1);
    v_changing ties.AC_part_PR_in_RAT_got.AC_part_PR_in_RAT_got_ChangedAt%TYPE;
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
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.AC_part_PR_in_RAT_got_ChangedAt <> :OLD.AC_part_PR_in_RAT_got_ChangedAt
        OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL)
        OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.AC_part_PR_in_RAT_got_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_RAT_got := :NEW.RAT_ID_got;
    IF (:NEW.got_RAT_Rating <> :OLD.got_RAT_Rating
        OR (:NEW.got_RAT_Rating IS NULL AND :OLD.got_RAT_Rating IS NOT NULL)
        OR (:NEW.got_RAT_Rating IS NOT NULL AND :OLD.got_RAT_Rating IS NULL)) THEN
        v_RAT_got := NULL;
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
    -- values that are left as they are state nothing
    IF
        v_RAT_got IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.AC_ID_part <> :OLD.AC_ID_part
                OR (:NEW.AC_ID_part IS NULL AND :OLD.AC_ID_part IS NOT NULL)
                OR (:NEW.AC_ID_part IS NOT NULL AND :OLD.AC_ID_part IS NULL))
        OR
            (:NEW.PR_ID_in <> :OLD.PR_ID_in
                OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
                OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL))
        OR
            (v_RAT_got <> :OLD.RAT_ID_got
                OR (v_RAT_got IS NULL AND :OLD.RAT_ID_got IS NOT NULL)
                OR (v_RAT_got IS NOT NULL AND :OLD.RAT_ID_got IS NULL))
        )
    THEN
        ties.ip_AC_part_PR_in_RAT_got(
            p_AC_part => :NEW.AC_ID_part,
            p_PR_in => :NEW.PR_ID_in,
            p_RAT_got => v_RAT_got,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
        );
    END IF;
END ut_lAC_part_PR_in_RAT_got;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_part_PR_in_RAT_got
INSTEAD OF DELETE ON ties.lAC_part_PR_in_RAT_got
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_part_PR_in_RAT_got x
    WHERE
        x.AC_part_PR_in_RAT_got_ChangedAt = :OLD.AC_part_PR_in_RAT_got_ChangedAt
    AND
        x.AC_ID_part = :OLD.AC_ID_part
    AND
        x.PR_ID_in = :OLD.PR_ID_in
    ;
END dt_lAC_part_PR_in_RAT_got;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_at_PR_isPlaying states a row of ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_ST_at_PR_isPlaying (
    p_ST_at IN ties.ST_at_PR_isPlaying.ST_ID_at%TYPE,
    p_PR_isPlaying IN ties.ST_at_PR_isPlaying.PR_ID_isPlaying%TYPE,
    p_changing IN ties.ST_at_PR_isPlaying.ST_at_PR_isPlaying_ChangedAt%TYPE,
    p_metadata IN ties.ST_at_PR_isPlaying.Metadata_ST_at_PR_isPlaying%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.ST_at_PR_isPlaying.ST_at_PR_isPlaying_ChangedAt%TYPE;
    v_metadata ties.ST_at_PR_isPlaying.Metadata_ST_at_PR_isPlaying%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.ST_at_PR_isPlaying x
        WHERE
            x.ST_ID_at = p_ST_at
        AND
            x.PR_ID_isPlaying = p_PR_isPlaying
        AND
            x.ST_at_PR_isPlaying_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.ST_at_PR_isPlaying (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    )
    VALUES (
        v_metadata,
        v_changing,
        p_ST_at,
        p_PR_isPlaying
    );
END ip_ST_at_PR_isPlaying;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lST_at_PR_isPlaying
INSTEAD OF INSERT ON ties.lST_at_PR_isPlaying
FOR EACH ROW
BEGIN
    ties.ip_ST_at_PR_isPlaying(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_isPlaying => :NEW.PR_ID_isPlaying,
        p_changing => :NEW.ST_at_PR_isPlaying_ChangedAt,
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
BEGIN
    DELETE FROM
        ties.ST_at_PR_isPlaying x
    WHERE
        x.ST_at_PR_isPlaying_ChangedAt = :OLD.ST_at_PR_isPlaying_ChangedAt
    AND
        x.ST_ID_at = :OLD.ST_ID_at
    AND
        x.PR_ID_isPlaying = :OLD.PR_ID_isPlaying
    ;
END dt_lST_at_PR_isPlaying;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_parent_AC_child_PAT_having states a row of AC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_parent_AC_child_PAT_having (
    p_AC_parent IN ties.AC_parent_AC_child_PAT_having.AC_ID_parent%TYPE,
    p_AC_child IN ties.AC_parent_AC_child_PAT_having.AC_ID_child%TYPE,
    p_PAT_having IN ties.AC_parent_AC_child_PAT_having.PAT_ID_having%TYPE,
    p_metadata IN ties.AC_parent_AC_child_PAT_having.Metadata_AC_parent_AC_child_PAT_having%TYPE
)
IS
    v_metadata ties.AC_parent_AC_child_PAT_having.Metadata_AC_parent_AC_child_PAT_having%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_parent_AC_child_PAT_having x
        WHERE
            x.AC_ID_parent = p_AC_parent
        AND
            x.AC_ID_child = p_AC_child
        AND
            x.PAT_ID_having = p_PAT_having
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.AC_parent_AC_child_PAT_having (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
    VALUES (
        v_metadata,
        p_AC_parent,
        p_AC_child,
        p_PAT_having
    );
END ip_AC_parent_AC_child_PAT_having;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_parent_AC_child_PAT_having
INSTEAD OF INSERT ON ties.lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    v_PAT_having number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
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
BEGIN
    DELETE FROM
        ties.AC_parent_AC_child_PAT_having x
    WHERE
        x.AC_ID_parent = :OLD.AC_ID_parent
    AND
        x.AC_ID_child = :OLD.AC_ID_child
    AND
        x.PAT_ID_having = :OLD.PAT_ID_having
    ;
END dt_lAC_parent_AC_child_PAT_having;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_content_ST_location_EV_of states a row of PR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_PR_content_ST_location_EV_of (
    p_PR_content IN ties.PR_content_ST_location_EV_of.PR_ID_content%TYPE,
    p_ST_location IN ties.PR_content_ST_location_EV_of.ST_ID_location%TYPE,
    p_EV_of IN ties.PR_content_ST_location_EV_of.EV_ID_of%TYPE,
    p_changing IN ties.PR_content_ST_location_EV_of.PR_content_ST_location_EV_of_ChangedAt%TYPE,
    p_metadata IN ties.PR_content_ST_location_EV_of.Metadata_PR_content_ST_location_EV_of%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.PR_content_ST_location_EV_of.PR_content_ST_location_EV_of_ChangedAt%TYPE;
    v_metadata ties.PR_content_ST_location_EV_of.Metadata_PR_content_ST_location_EV_of%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.PR_content_ST_location_EV_of x
        WHERE
            x.PR_ID_content = p_PR_content
        AND
            x.ST_ID_location = p_ST_location
        AND
            x.EV_ID_of = p_EV_of
        AND
            x.PR_content_ST_location_EV_of_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.PR_content_ST_location_EV_of (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    VALUES (
        v_metadata,
        v_changing,
        p_PR_content,
        p_ST_location,
        p_EV_of
    );
END ip_PR_content_ST_location_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lPR_content_ST_location_EV_of
INSTEAD OF INSERT ON ties.lPR_content_ST_location_EV_of
FOR EACH ROW
BEGIN
    ties.ip_PR_content_ST_location_EV_of(
        p_PR_content => :NEW.PR_ID_content,
        p_ST_location => :NEW.ST_ID_location,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => :NEW.PR_content_ST_location_EV_of_ChangedAt,
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
    v_changed NUMBER(1);
    v_changing ties.PR_content_ST_location_EV_of.PR_content_ST_location_EV_of_ChangedAt%TYPE;
BEGIN
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.PR_content_ST_location_EV_of_ChangedAt <> :OLD.PR_content_ST_location_EV_of_ChangedAt
        OR (:NEW.PR_content_ST_location_EV_of_ChangedAt IS NULL AND :OLD.PR_content_ST_location_EV_of_ChangedAt IS NOT NULL)
        OR (:NEW.PR_content_ST_location_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.PR_content_ST_location_EV_of_ChangedAt ELSE v_now END;
    -- values that are left as they are state nothing
    IF
        :NEW.PR_ID_content IS NOT NULL
    AND
        :NEW.ST_ID_location IS NOT NULL
    AND
        :NEW.EV_ID_of IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.PR_ID_content <> :OLD.PR_ID_content
                OR (:NEW.PR_ID_content IS NULL AND :OLD.PR_ID_content IS NOT NULL)
                OR (:NEW.PR_ID_content IS NOT NULL AND :OLD.PR_ID_content IS NULL))
        OR
            (:NEW.ST_ID_location <> :OLD.ST_ID_location
                OR (:NEW.ST_ID_location IS NULL AND :OLD.ST_ID_location IS NOT NULL)
                OR (:NEW.ST_ID_location IS NOT NULL AND :OLD.ST_ID_location IS NULL))
        OR
            (:NEW.EV_ID_of <> :OLD.EV_ID_of
                OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
                OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL))
        )
    THEN
        ties.ip_PR_content_ST_location_EV_of(
            p_PR_content => :NEW.PR_ID_content,
            p_ST_location => :NEW.ST_ID_location,
            p_EV_of => :NEW.EV_ID_of,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
        );
    END IF;
END ut_lPR_content_ST_location_EV_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lPR_content_ST_location_EV_of
INSTEAD OF DELETE ON ties.lPR_content_ST_location_EV_of
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.PR_content_ST_location_EV_of x
    WHERE
        x.PR_content_ST_location_EV_of_ChangedAt = :OLD.PR_content_ST_location_EV_of_ChangedAt
    AND
        x.PR_ID_content = :OLD.PR_ID_content
    AND
        x.ST_ID_location = :OLD.ST_ID_location
    AND
        x.EV_ID_of = :OLD.EV_ID_of
    ;
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
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_ST_Stage_1st (
    ST_ID,
    ST_LOC_Stage_Location,
    ST_LOC_Checksum
)
AS
SELECT
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
        'ST_LOC_Checksum' VALUE ST_LOC_Checksum
    ),
    COUNT(DISTINCT ST_ID)
FROM
    anchors.key_ST_Stage_1st
WHERE
    ST_LOC_Checksum IS NOT NULL
GROUP BY
    ST_LOC_Checksum
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Stage_1st',
    'more than one natural key',
    JSON_OBJECT(
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    anchors.key_ST_Stage_1st
GROUP BY
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_ST_Stage_2nd (
    ST_ID,
    ST_NAM_Stage_Name
)
AS
SELECT
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
        'ST_NAM_Stage_Name' VALUE ST_NAM_Stage_Name
    ),
    COUNT(DISTINCT ST_ID)
FROM
    anchors.key_ST_Stage_2nd
WHERE
    ST_NAM_Stage_Name IS NOT NULL
GROUP BY
    ST_NAM_Stage_Name
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Stage_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    anchors.key_ST_Stage_2nd
GROUP BY
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_AC_Actor_1st (
    AC_ID,
    AC_NAM_Actor_Name
)
AS
SELECT
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
        'AC_NAM_Actor_Name' VALUE AC_NAM_Actor_Name
    ),
    COUNT(DISTINCT AC_ID)
FROM
    anchors.key_AC_Actor_1st
WHERE
    AC_NAM_Actor_Name IS NOT NULL
GROUP BY
    AC_NAM_Actor_Name
HAVING
    COUNT(DISTINCT AC_ID) > 1
UNION ALL
SELECT
    'key_AC_Actor_1st',
    'more than one natural key',
    JSON_OBJECT(
        'AC_ID' VALUE AC_ID
    ),
    COUNT(*)
FROM
    anchors.key_AC_Actor_1st
GROUP BY
    AC_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_PR_Program_1st (
    PR_ID,
    PR_NAM_Program_Name
)
AS
SELECT
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
        'PR_NAM_Program_Name' VALUE PR_NAM_Program_Name
    ),
    COUNT(DISTINCT PR_ID)
FROM
    anchors.key_PR_Program_1st
WHERE
    PR_NAM_Program_Name IS NOT NULL
GROUP BY
    PR_NAM_Program_Name
HAVING
    COUNT(DISTINCT PR_ID) > 1
UNION ALL
SELECT
    'key_PR_Program_1st',
    'more than one natural key',
    JSON_OBJECT(
        'PR_ID' VALUE PR_ID
    ),
    COUNT(*)
FROM
    anchors.key_PR_Program_1st
GROUP BY
    PR_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.key_EV_Event_1st (
    EV_ID,
    EV_DAT_Event_Date,
    wasHeldAt_ST_LOC_Stage_Location,
    wasHeldAt_ST_LOC_Checksum,
    wasPlayed_PR_NAM_Program_Name
)
AS
SELECT
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
LEFT JOIN
    anchors.lPR_Program "s4"
ON
    "s4".PR_ID = "EV".PR_ID_wasPlayed
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
        'EV_ID' VALUE EV_ID
    ),
    COUNT(*)
FROM
    nexuses.key_EV_Event_1st
GROUP BY
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
COMMENT ON COLUMN ties.AC_subset_PN_of.AC_ID_subset IS 'An actor, a person who performs parts in programs and is cast in events.';
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
