-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- In Oracle a schema is a user, which a script does not create. The schemas that the model puts its tables, views,
-- functions and procedures in must exist before this script is run, and the user that runs it needs the privileges to
-- create those objects in them (CREATE ANY TABLE, CREATE ANY VIEW, ... or the same privileges on each schema).
--
-- This model has no schema of its own.
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
        CREATE TABLE PAT_ParentalType (
            PAT_ID number(3) not null,
            PAT_ParentalType nvarchar2(42) not null,
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
        CREATE TABLE GEN_Gender (
            GEN_ID number(3) not null,
            GEN_Gender nvarchar2(42) not null,
            constraint pkGEN_Gender primary key (
                GEN_ID
            ),
            constraint uqGEN_Gender unique (
                GEN_Gender
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
        CREATE TABLE PLV_ProfessionalLevel (
            PLV_ID number(3) not null,
            PLV_ProfessionalLevel nclob not null,
            PLV_Checksum raw(16) generated always as (standard_hash(PLV_ProfessionalLevel, 'MD5')) virtual,
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
        CREATE TABLE UTL_Utilization (
            UTL_ID number(3) not null,
            UTL_Utilization number(3) not null,
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
        CREATE TABLE ONG_Ongoing (
            ONG_ID number(3) not null,
            ONG_Ongoing nvarchar2(3) not null,
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
    EXECUTE IMMEDIATE q'[
        CREATE TABLE RAT_Rating (
            RAT_ID number(3) not null,
            RAT_Rating nvarchar2(42) not null,
            constraint pkRAT_Rating primary key (
                RAT_ID
            ),
            constraint uqRAT_Rating unique (
                RAT_Rating
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
        CREATE TABLE ETY_EventType (
            ETY_ID number(3) not null,
            ETY_EventType nvarchar2(42) not null,
            constraint pkETY_EventType primary key (
                ETY_ID
            ),
            constraint uqETY_EventType unique (
                ETY_EventType
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
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE PN_Person_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PN_Person (
            PN_ID number(10) default PN_Person_ID_SEQ.nextval not null, 
            PN_Dummy number(1) null,
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
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ST_Stage_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_Stage (
            ST_ID number(10) default ST_Stage_ID_SEQ.nextval not null, 
            ST_Dummy number(1) null,
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
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_Actor_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_Actor (
            AC_ID number(10) default AC_Actor_ID_SEQ.nextval not null, 
            AC_Dummy number(1) null,
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
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE PR_Program_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_Program (
            PR_ID number(10) default PR_Program_ID_SEQ.nextval not null, 
            PR_Dummy number(1) null,
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
-- EV_Event table (with 3 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE EV_Event_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_Event (
            EV_ID number(10) default EV_Event_ID_SEQ.nextval not null, 
            ST_ID_wasHeldAt number(10) not null, 
            PR_ID_wasPlayed number(10) not null, 
            ETY_ID_of number(3) not null,
            EV_Dummy number(1) null,
            constraint EV_Event_fkST_wasHeldAt foreign key (
                ST_ID_wasHeldAt
            ) references ST_Stage(ST_ID),
            constraint EV_Event_fkPR_wasPlayed foreign key (
                PR_ID_wasPlayed
            ) references PR_Program(PR_ID),
            constraint EV_Event_fkETY_of foreign key (
                ETY_ID_of
            ) references ETY_EventType(ETY_ID),
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
        CREATE TABLE EV_DAT_Event_Date (
            EV_ID number(10) not null,
            EV_DAT_Event_Date timestamp not null,
            constraint fkEV_DAT_Event_Date foreign key (
                EV_ID
            ) references EV_Event(EV_ID),
            constraint pkEV_DAT_Event_Date primary key (
                EV_ID
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
        CREATE TABLE EV_AUD_Event_Audience (
            EV_ID number(10) not null,
            EV_AUD_Event_Audience number(10) not null,
            constraint fkEV_AUD_Event_Audience foreign key (
                EV_ID
            ) references EV_Event(EV_ID),
            constraint pkEV_AUD_Event_Audience primary key (
                EV_ID
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
        CREATE TABLE EV_REV_Event_Revenue (
            EV_ID number(10) not null,
            EV_REV_Event_Revenue number(19,4) not null,
            constraint fkEV_REV_Event_Revenue foreign key (
                EV_ID
            ) references EV_Event(EV_ID),
            constraint pkEV_REV_Event_Revenue primary key (
                EV_ID
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
        CREATE TABLE ST_NAM_Stage_Name (
            ST_ID number(10) not null,
            ST_NAM_Stage_Name nvarchar2(42) not null,
            ST_NAM_ChangedAt timestamp not null,
            constraint fkST_NAM_Stage_Name foreign key (
                ST_ID
            ) references ST_Stage(ST_ID),
            constraint pkST_NAM_Stage_Name primary key (
                ST_ID,
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
        CREATE TABLE ST_LOC_Stage_Location (
            ST_ID number(10) not null,
            ST_LOC_Stage_Location varchar2(100) not null,
            ST_LOC_Checksum raw(16) generated always as (standard_hash(ST_LOC_Stage_Location, 'MD5')) virtual,
            constraint fkST_LOC_Stage_Location foreign key (
                ST_ID
            ) references ST_Stage(ST_ID),
            constraint pkST_LOC_Stage_Location primary key (
                ST_ID
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
        CREATE TABLE ST_AVG_Stage_Average (
            ST_ID number(10) not null,
            UTL_ID number(3) not null,
            ST_AVG_ChangedAt timestamp not null,
            constraint fk_A_ST_AVG_Stage_Average foreign key (
                ST_ID
            ) references ST_Stage(ST_ID),
            constraint fk_K_ST_AVG_Stage_Average foreign key (
                UTL_ID
            ) references UTL_Utilization(UTL_ID),
            constraint pkST_AVG_Stage_Average primary key (
                ST_ID,
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
        CREATE TABLE ST_MIN_Stage_Minimum (
            ST_ID number(10) not null,
            UTL_ID number(3) not null,
            constraint fk_A_ST_MIN_Stage_Minimum foreign key (
                ST_ID
            ) references ST_Stage(ST_ID),
            constraint fk_K_ST_MIN_Stage_Minimum foreign key (
                UTL_ID
            ) references UTL_Utilization(UTL_ID),
            constraint pkST_MIN_Stage_Minimum primary key (
                ST_ID
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
        CREATE TABLE ST_MIN_Stage_Minimum_Deleted (
            ST_ID number(10) not null,
            UTL_ID number(3) not null,
            ST_MIN_Deleted timestamp(9) not null
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_NAM_Actor_Name (
            AC_ID number(10) not null,
            AC_NAM_Actor_Name nvarchar2(42) not null,
            AC_NAM_ChangedAt timestamp not null,
            constraint fkAC_NAM_Actor_Name foreign key (
                AC_ID
            ) references AC_Actor(AC_ID),
            constraint pkAC_NAM_Actor_Name primary key (
                AC_ID,
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
        CREATE TABLE AC_GEN_Actor_Gender (
            AC_ID number(10) not null,
            GEN_ID number(3) not null,
            constraint fk_A_AC_GEN_Actor_Gender foreign key (
                AC_ID
            ) references AC_Actor(AC_ID),
            constraint fk_K_AC_GEN_Actor_Gender foreign key (
                GEN_ID
            ) references GEN_Gender(GEN_ID),
            constraint pkAC_GEN_Actor_Gender primary key (
                AC_ID
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
        CREATE TABLE AC_PLV_Actor_ProfessionalLevel (
            AC_ID number(10) not null,
            PLV_ID number(3) not null,
            AC_PLV_ChangedAt timestamp not null,
            constraint fk_A_AC_PLV_Actor_ProfessionalLevel foreign key (
                AC_ID
            ) references AC_Actor(AC_ID),
            constraint fk_K_AC_PLV_Actor_ProfessionalLevel foreign key (
                PLV_ID
            ) references PLV_ProfessionalLevel(PLV_ID),
            constraint pkAC_PLV_Actor_ProfessionalLevel primary key (
                AC_ID,
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
        CREATE TABLE PR_NAM_Program_Name (
            PR_ID number(10) not null,
            PR_NAM_Program_Name nvarchar2(42) not null,
            constraint fkPR_NAM_Program_Name foreign key (
                PR_ID
            ) references PR_Program(PR_ID),
            constraint pkPR_NAM_Program_Name primary key (
                PR_ID
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
        CREATE TABLE PR_LEN_Program_Length (
            PR_ID number(10) not null,
            PR_LEN_Program_Length timestamp not null,
            PR_LEN_ChangedAt date not null,
            constraint fkPR_LEN_Program_Length foreign key (
                PR_ID
            ) references PR_Program(PR_ID),
            constraint pkPR_LEN_Program_Length primary key (
                PR_ID,
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
        CREATE TABLE AC_partner_AC_with_ONG_currently (
            AC_ID_partner number(10) not null, 
            AC_ID_with number(10) not null, 
            ONG_ID_currently number(3) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            constraint AC_partner_AC_with_ONG_currently_fkAC_partner foreign key (
                AC_ID_partner
            ) references AC_Actor(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_fkAC_with foreign key (
                AC_ID_with
            ) references AC_Actor(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_fkONG_currently foreign key (
                ONG_ID_currently
            ) references ONG_Ongoing(ONG_ID),
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
        CREATE TABLE AC_subset_PN_of (
            AC_ID_subset number(10) not null, 
            PN_ID_of number(10) not null, 
            constraint AC_subset_PN_of_fkAC_subset foreign key (
                AC_ID_subset
            ) references AC_Actor(AC_ID),
            constraint AC_subset_PN_of_fkPN_of foreign key (
                PN_ID_of
            ) references PN_Person(PN_ID),
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
        CREATE TABLE EV_in_AC_wasCast (
            EV_ID_in number(10) not null, 
            AC_ID_wasCast number(10) not null, 
            constraint EV_in_AC_wasCast_fkEV_in foreign key (
                EV_ID_in
            ) references EV_Event(EV_ID),
            constraint EV_in_AC_wasCast_fkAC_wasCast foreign key (
                AC_ID_wasCast
            ) references AC_Actor(AC_ID),
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
        CREATE TABLE AC_part_PR_in_RAT_got (
            AC_ID_part number(10) not null, 
            PR_ID_in number(10) not null, 
            RAT_ID_got number(3) not null,
            AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
            constraint AC_part_PR_in_RAT_got_fkAC_part foreign key (
                AC_ID_part
            ) references AC_Actor(AC_ID),
            constraint AC_part_PR_in_RAT_got_fkPR_in foreign key (
                PR_ID_in
            ) references PR_Program(PR_ID),
            constraint AC_part_PR_in_RAT_got_fkRAT_got foreign key (
                RAT_ID_got
            ) references RAT_Rating(RAT_ID),
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
        CREATE TABLE ST_at_PR_isPlaying (
            ST_ID_at number(10) not null, 
            PR_ID_isPlaying number(10) not null, 
            ST_at_PR_isPlaying_ChangedAt timestamp not null,
            constraint ST_at_PR_isPlaying_fkST_at foreign key (
                ST_ID_at
            ) references ST_Stage(ST_ID),
            constraint ST_at_PR_isPlaying_fkPR_isPlaying foreign key (
                PR_ID_isPlaying
            ) references PR_Program(PR_ID),
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
        CREATE TABLE AC_parent_AC_child_PAT_having (
            AC_ID_parent number(10) not null, 
            AC_ID_child number(10) not null, 
            PAT_ID_having number(3) not null,
            constraint AC_parent_AC_child_PAT_having_fkAC_parent foreign key (
                AC_ID_parent
            ) references AC_Actor(AC_ID),
            constraint AC_parent_AC_child_PAT_having_fkAC_child foreign key (
                AC_ID_child
            ) references AC_Actor(AC_ID),
            constraint AC_parent_AC_child_PAT_having_fkPAT_having foreign key (
                PAT_ID_having
            ) references PAT_ParentalType(PAT_ID),
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
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_content_ST_location_EV_of (
            PR_ID_content number(10) not null, 
            ST_ID_location number(10) not null, 
            EV_ID_of number(10) not null, 
            constraint PR_content_ST_location_EV_of_fkPR_content foreign key (
                PR_ID_content
            ) references PR_Program(PR_ID),
            constraint PR_content_ST_location_EV_of_fkST_location foreign key (
                ST_ID_location
            ) references ST_Stage(ST_ID),
            constraint PR_content_ST_location_EV_of_fkEV_of foreign key (
                EV_ID_of
            ) references EV_Event(EV_ID),
            constraint pkPR_content_ST_location_EV_of primary key (
                EV_ID_of
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
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_NAM_Stage_Name (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM
            ST_NAM_Stage_Name
        WHERE
            ST_NAM_ChangedAt <= changingTimepoint
    ]';
END rST_NAM_Stage_Name;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_AVG_Stage_Average (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_ID,
            UTL_ID,
            ST_AVG_ChangedAt
        FROM
            ST_AVG_Stage_Average
        WHERE
            ST_AVG_ChangedAt <= changingTimepoint
    ]';
END rST_AVG_Stage_Average;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_NAM_Actor_Name (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM
            AC_NAM_Actor_Name
        WHERE
            AC_NAM_ChangedAt <= changingTimepoint
    ]';
END rAC_NAM_Actor_Name;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_ID,
            PLV_ID,
            AC_PLV_ChangedAt
        FROM
            AC_PLV_Actor_ProfessionalLevel
        WHERE
            AC_PLV_ChangedAt <= changingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_LEN_Program_Length (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM
            PR_LEN_Program_Length
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
CREATE OR REPLACE VIEW lST_Stage (
    ST_ID,
    ST_NAM_ChangedAt,
    ST_NAM_Stage_Name,
    ST_LOC_Checksum,
    ST_LOC_Stage_Location,
    ST_AVG_ChangedAt,
    UTL_Utilization,
    UTL_ID,
    Deletable_ST_MIN,
    UTL_Utilization,
    UTL_ID
)
AS
SELECT
    "ST".ST_ID,
    "NAM".ST_NAM_ChangedAt,
    "NAM".ST_NAM_Stage_Name,
    "LOC".ST_LOC_Checksum,
    "LOC".ST_LOC_Stage_Location,
    "AVG".ST_AVG_ChangedAt,
    "kAVG".UTL_Utilization AS UTL_Utilization,
    "AVG".UTL_ID,
    CAST(NULL AS number(1)),
    "kMIN".UTL_Utilization AS UTL_Utilization,
    "MIN".UTL_ID
FROM
    ST_Stage "ST"
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            ST_NAM_Stage_Name a
        WHERE
            a.ST_NAM_ChangedAt = (
                SELECT
                    MAX(sub.ST_NAM_ChangedAt)
                FROM
                    ST_NAM_Stage_Name sub
                WHERE
                    sub.ST_ID = a.ST_ID
            )
    ) "NAM"
ON
    "NAM".ST_ID = "ST".ST_ID
LEFT JOIN
    ST_LOC_Stage_Location "LOC"
ON
    "LOC".ST_ID = "ST".ST_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            ST_AVG_Stage_Average a
        WHERE
            a.ST_AVG_ChangedAt = (
                SELECT
                    MAX(sub.ST_AVG_ChangedAt)
                FROM
                    ST_AVG_Stage_Average sub
                WHERE
                    sub.ST_ID = a.ST_ID
            )
    ) "AVG"
ON
    "AVG".ST_ID = "ST".ST_ID
LEFT JOIN
    UTL_Utilization "kAVG"
ON
    "kAVG".UTL_ID = "AVG".UTL_ID
LEFT JOIN
    ST_MIN_Stage_Minimum "MIN"
ON
    "MIN".ST_ID = "ST".ST_ID
LEFT JOIN
    UTL_Utilization "kMIN"
ON
    "kMIN".UTL_ID = "MIN".UTL_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pST_Stage (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "ST".ST_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ChangedAt,
            "kAVG".UTL_Utilization AS UTL_Utilization,
            "AVG".UTL_ID,
            "kMIN".UTL_Utilization AS UTL_Utilization,
            "MIN".UTL_ID
        FROM
            ST_Stage "ST"
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    ST_NAM_Stage_Name a
                WHERE
                    a.ST_NAM_ChangedAt = (
                        SELECT
                            MAX(sub.ST_NAM_ChangedAt)
                        FROM
                            ST_NAM_Stage_Name sub
                        WHERE
                            sub.ST_ID = a.ST_ID
                        AND
                            sub.ST_NAM_ChangedAt <= changingTimepoint
                    )
            ) "NAM"
        ON
            "NAM".ST_ID = "ST".ST_ID
        LEFT JOIN
            ST_LOC_Stage_Location "LOC"
        ON
            "LOC".ST_ID = "ST".ST_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    ST_AVG_Stage_Average a
                WHERE
                    a.ST_AVG_ChangedAt = (
                        SELECT
                            MAX(sub.ST_AVG_ChangedAt)
                        FROM
                            ST_AVG_Stage_Average sub
                        WHERE
                            sub.ST_ID = a.ST_ID
                        AND
                            sub.ST_AVG_ChangedAt <= changingTimepoint
                    )
            ) "AVG"
        ON
            "AVG".ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".UTL_ID
        LEFT JOIN
            ST_MIN_Stage_Minimum "MIN"
        ON
            "MIN".ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".UTL_ID
    ]';
END pST_Stage;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nST_Stage
AS
SELECT
    *
FROM
    pST_Stage(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dST_Stage (
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
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ChangedAt,
            "kAVG".UTL_Utilization AS UTL_Utilization,
            "AVG".UTL_ID,
            "kMIN".UTL_Utilization AS UTL_Utilization,
            "MIN".UTL_ID
        FROM (
            SELECT DISTINCT
                h.ST_ID AS ST_ID,
                CAST(h.ST_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                ST_NAM_Stage_Name h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.ST_ID AS ST_ID,
                CAST(h.ST_AVG_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'AVG' AS mnemonic
            FROM
                ST_AVG_Stage_Average h
            WHERE
                (selection IS NULL OR selection LIKE '%AVG%')
            AND
                h.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            ST_Stage "ST"
        ON
            "ST".ST_ID = timepoints.ST_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.ST_NAM_ChangedAt) OVER (
                    PARTITION BY h.ST_ID
                    ORDER BY h.ST_NAM_ChangedAt
                ) AS untilTime
            FROM
                ST_NAM_Stage_Name h
        ) "NAM"
        ON
            "NAM".ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            ST_LOC_Stage_Location "LOC"
        ON
            "LOC".ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.ST_AVG_ChangedAt) OVER (
                    PARTITION BY h.ST_ID
                    ORDER BY h.ST_AVG_ChangedAt
                ) AS untilTime
            FROM
                ST_AVG_Stage_Average h
        ) "AVG"
        ON
            "AVG".ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "AVG".untilTime IS NULL
        OR
            "AVG".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".UTL_ID
        LEFT JOIN
            ST_MIN_Stage_Minimum "MIN"
        ON
            "MIN".ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".UTL_ID
    ]';
END dST_Stage;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_Actor (
    AC_ID,
    AC_NAM_ChangedAt,
    AC_NAM_Actor_Name,
    GEN_Gender,
    GEN_ID,
    AC_PLV_ChangedAt,
    PLV_Checksum,
    PLV_ProfessionalLevel,
    PLV_ID
)
AS
SELECT
    "AC".AC_ID,
    "NAM".AC_NAM_ChangedAt,
    "NAM".AC_NAM_Actor_Name,
    "kGEN".GEN_Gender AS GEN_Gender,
    "GEN".GEN_ID,
    "PLV".AC_PLV_ChangedAt,
    "kPLV".PLV_Checksum AS PLV_Checksum,
    "kPLV".PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    "PLV".PLV_ID
FROM
    AC_Actor "AC"
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            AC_NAM_Actor_Name a
        WHERE
            a.AC_NAM_ChangedAt = (
                SELECT
                    MAX(sub.AC_NAM_ChangedAt)
                FROM
                    AC_NAM_Actor_Name sub
                WHERE
                    sub.AC_ID = a.AC_ID
            )
    ) "NAM"
ON
    "NAM".AC_ID = "AC".AC_ID
LEFT JOIN
    AC_GEN_Actor_Gender "GEN"
ON
    "GEN".AC_ID = "AC".AC_ID
LEFT JOIN
    GEN_Gender "kGEN"
ON
    "kGEN".GEN_ID = "GEN".GEN_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            AC_PLV_Actor_ProfessionalLevel a
        WHERE
            a.AC_PLV_ChangedAt = (
                SELECT
                    MAX(sub.AC_PLV_ChangedAt)
                FROM
                    AC_PLV_Actor_ProfessionalLevel sub
                WHERE
                    sub.AC_ID = a.AC_ID
            )
    ) "PLV"
ON
    "PLV".AC_ID = "AC".AC_ID
LEFT JOIN
    PLV_ProfessionalLevel "kPLV"
ON
    "kPLV".PLV_ID = "PLV".PLV_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_Actor (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".AC_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_Actor_Name,
            "kGEN".GEN_Gender AS GEN_Gender,
            "GEN".GEN_ID,
            "PLV".AC_PLV_ChangedAt,
            "kPLV".PLV_Checksum AS PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
            "PLV".PLV_ID
        FROM
            AC_Actor "AC"
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    AC_NAM_Actor_Name a
                WHERE
                    a.AC_NAM_ChangedAt = (
                        SELECT
                            MAX(sub.AC_NAM_ChangedAt)
                        FROM
                            AC_NAM_Actor_Name sub
                        WHERE
                            sub.AC_ID = a.AC_ID
                        AND
                            sub.AC_NAM_ChangedAt <= changingTimepoint
                    )
            ) "NAM"
        ON
            "NAM".AC_ID = "AC".AC_ID
        LEFT JOIN
            AC_GEN_Actor_Gender "GEN"
        ON
            "GEN".AC_ID = "AC".AC_ID
        LEFT JOIN
            GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".GEN_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    AC_PLV_Actor_ProfessionalLevel a
                WHERE
                    a.AC_PLV_ChangedAt = (
                        SELECT
                            MAX(sub.AC_PLV_ChangedAt)
                        FROM
                            AC_PLV_Actor_ProfessionalLevel sub
                        WHERE
                            sub.AC_ID = a.AC_ID
                        AND
                            sub.AC_PLV_ChangedAt <= changingTimepoint
                    )
            ) "PLV"
        ON
            "PLV".AC_ID = "AC".AC_ID
        LEFT JOIN
            PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".PLV_ID
    ]';
END pAC_Actor;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_Actor
AS
SELECT
    *
FROM
    pAC_Actor(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dAC_Actor (
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
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_Actor_Name,
            "kGEN".GEN_Gender AS GEN_Gender,
            "GEN".GEN_ID,
            "PLV".AC_PLV_ChangedAt,
            "kPLV".PLV_Checksum AS PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
            "PLV".PLV_ID
        FROM (
            SELECT DISTINCT
                h.AC_ID AS AC_ID,
                CAST(h.AC_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                AC_NAM_Actor_Name h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.AC_ID AS AC_ID,
                CAST(h.AC_PLV_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'PLV' AS mnemonic
            FROM
                AC_PLV_Actor_ProfessionalLevel h
            WHERE
                (selection IS NULL OR selection LIKE '%PLV%')
            AND
                h.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            AC_Actor "AC"
        ON
            "AC".AC_ID = timepoints.AC_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.AC_NAM_ChangedAt) OVER (
                    PARTITION BY h.AC_ID
                    ORDER BY h.AC_NAM_ChangedAt
                ) AS untilTime
            FROM
                AC_NAM_Actor_Name h
        ) "NAM"
        ON
            "NAM".AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            AC_GEN_Actor_Gender "GEN"
        ON
            "GEN".AC_ID = "AC".AC_ID
        LEFT JOIN
            GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".GEN_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.AC_PLV_ChangedAt) OVER (
                    PARTITION BY h.AC_ID
                    ORDER BY h.AC_PLV_ChangedAt
                ) AS untilTime
            FROM
                AC_PLV_Actor_ProfessionalLevel h
        ) "PLV"
        ON
            "PLV".AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "PLV".untilTime IS NULL
        OR
            "PLV".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".PLV_ID
    ]';
END dAC_Actor;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lPR_Program (
    PR_ID,
    PR_NAM_Program_Name,
    PR_LEN_ChangedAt,
    PR_LEN_Program_Length
)
AS
SELECT
    "PR".PR_ID,
    "NAM".PR_NAM_Program_Name,
    "LEN".PR_LEN_ChangedAt,
    "LEN".PR_LEN_Program_Length
FROM
    PR_Program "PR"
LEFT JOIN
    PR_NAM_Program_Name "NAM"
ON
    "NAM".PR_ID = "PR".PR_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            PR_LEN_Program_Length a
        WHERE
            a.PR_LEN_ChangedAt = (
                SELECT
                    MAX(sub.PR_LEN_ChangedAt)
                FROM
                    PR_LEN_Program_Length sub
                WHERE
                    sub.PR_ID = a.PR_ID
            )
    ) "LEN"
ON
    "LEN".PR_ID = "PR".PR_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pPR_Program (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "PR".PR_ID,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_Program_Length
        FROM
            PR_Program "PR"
        LEFT JOIN
            PR_NAM_Program_Name "NAM"
        ON
            "NAM".PR_ID = "PR".PR_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    PR_LEN_Program_Length a
                WHERE
                    a.PR_LEN_ChangedAt = (
                        SELECT
                            MAX(sub.PR_LEN_ChangedAt)
                        FROM
                            PR_LEN_Program_Length sub
                        WHERE
                            sub.PR_ID = a.PR_ID
                        AND
                            sub.PR_LEN_ChangedAt <= changingTimepoint
                    )
            ) "LEN"
        ON
            "LEN".PR_ID = "PR".PR_ID
    ]';
END pPR_Program;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nPR_Program
AS
SELECT
    *
FROM
    pPR_Program(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dPR_Program (
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
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_Program_Length
        FROM (
            SELECT DISTINCT
                h.PR_ID AS PR_ID,
                CAST(h.PR_LEN_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'LEN' AS mnemonic
            FROM
                PR_LEN_Program_Length h
            WHERE
                (selection IS NULL OR selection LIKE '%LEN%')
            AND
                h.PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            PR_Program "PR"
        ON
            "PR".PR_ID = timepoints.PR_ID
        LEFT JOIN
            PR_NAM_Program_Name "NAM"
        ON
            "NAM".PR_ID = "PR".PR_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.PR_LEN_ChangedAt) OVER (
                    PARTITION BY h.PR_ID
                    ORDER BY h.PR_LEN_ChangedAt
                ) AS untilTime
            FROM
                PR_LEN_Program_Length h
        ) "LEN"
        ON
            "LEN".PR_ID = "PR".PR_ID
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
CREATE OR REPLACE VIEW lEV_Event (
    EV_ID,
    ST_ID_wasHeldAt,
    PR_ID_wasPlayed,
    ETY_EventType,
    ETY_ID_of,
    EV_DAT_Event_Date,
    EV_AUD_Event_Audience,
    EV_REV_Event_Revenue
)
AS
SELECT
    "EV".EV_ID,
    "EV".ST_ID_wasHeldAt,
    "EV".PR_ID_wasPlayed,
    "ETY_of".ETY_EventType AS ETY_EventType,
    "EV".ETY_ID_of,
    "DAT".EV_DAT_Event_Date,
    "AUD".EV_AUD_Event_Audience,
    "REV".EV_REV_Event_Revenue
FROM
    EV_Event "EV"
LEFT JOIN
    ETY_EventType "ETY_of"
ON
    "ETY_of".ETY_ID = "EV".ETY_ID_of
LEFT JOIN
    EV_DAT_Event_Date "DAT"
ON
    "DAT".EV_ID = "EV".EV_ID
LEFT JOIN
    EV_AUD_Event_Audience "AUD"
ON
    "AUD".EV_ID = "EV".EV_ID
LEFT JOIN
    EV_REV_Event_Revenue "REV"
ON
    "REV".EV_ID = "EV".EV_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pEV_Event (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "EV".EV_ID,
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "ETY_of".ETY_EventType AS ETY_EventType,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_Event_Revenue
        FROM
            EV_Event "EV"
        LEFT JOIN
            ETY_EventType "ETY_of"
        ON
            "ETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN
            EV_DAT_Event_Date "DAT"
        ON
            "DAT".EV_ID = "EV".EV_ID
        LEFT JOIN
            EV_AUD_Event_Audience "AUD"
        ON
            "AUD".EV_ID = "EV".EV_ID
        LEFT JOIN
            EV_REV_Event_Revenue "REV"
        ON
            "REV".EV_ID = "EV".EV_ID
    ]';
END pEV_Event;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nEV_Event
AS
SELECT
    *
FROM
    pEV_Event(CAST(current_timestamp AS timestamp(9)))
;
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
CREATE OR REPLACE VIEW lAC_partner_AC_with_ONG_currently (
    AC_partner_AC_with_ONG_currently_ChangedAt,
    AC_ID_partner,
    AC_ID_with,
    ONG_Ongoing,
    ONG_ID_currently
)
AS
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    "ONG_currently".ONG_Ongoing AS ONG_Ongoing,
    tie.ONG_ID_currently
FROM
    (
        SELECT
            t.*,
            MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_partner) AS latestAC_ID_partner,
            MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_with) AS latestAC_ID_with
        FROM
            AC_partner_AC_with_ONG_currently t
    ) tie
LEFT JOIN
    ONG_Ongoing "ONG_currently"
ON
    "ONG_currently".ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_partner
AND
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_with
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.AC_partner_AC_with_ONG_currently_ChangedAt,
            tie.AC_ID_partner,
            tie.AC_ID_with,
            "ONG_currently".ONG_Ongoing AS ONG_Ongoing,
            tie.ONG_ID_currently
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_partner) AS latestAC_ID_partner,
                    MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_with) AS latestAC_ID_with
                FROM
                    AC_partner_AC_with_ONG_currently t
                WHERE
                    t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            ONG_Ongoing "ONG_currently"
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
CREATE OR REPLACE VIEW nAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    pAC_partner_AC_with_ONG_currently(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dAC_partner_AC_with_ONG_currently (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.AC_partner_AC_with_ONG_currently_ChangedAt,
            tie.AC_ID_partner,
            tie.AC_ID_with,
            "ONG_currently".ONG_Ongoing AS ONG_Ongoing,
            tie.ONG_ID_currently
        FROM
            AC_partner_AC_with_ONG_currently tie
        LEFT JOIN
            ONG_Ongoing "ONG_currently"
        ON
            "ONG_currently".ONG_ID = tie.ONG_ID_currently
        WHERE
            tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_partner_AC_with_ONG_currently;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_subset_PN_of (
    AC_ID_subset,
    PN_ID_of
)
AS
SELECT
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    AC_subset_PN_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_subset_PN_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.AC_ID_subset,
            tie.PN_ID_of
        FROM
            AC_subset_PN_of tie
    ]';
END pAC_subset_PN_of;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_subset_PN_of
AS
SELECT
    *
FROM
    pAC_subset_PN_of(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lEV_in_AC_wasCast (
    EV_ID_in,
    AC_ID_wasCast
)
AS
SELECT
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    EV_in_AC_wasCast tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pEV_in_AC_wasCast (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.EV_ID_in,
            tie.AC_ID_wasCast
        FROM
            EV_in_AC_wasCast tie
    ]';
END pEV_in_AC_wasCast;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nEV_in_AC_wasCast
AS
SELECT
    *
FROM
    pEV_in_AC_wasCast(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_part_PR_in_RAT_got (
    AC_part_PR_in_RAT_got_ChangedAt,
    AC_ID_part,
    PR_ID_in,
    RAT_Rating,
    RAT_ID_got
)
AS
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    "RAT_got".RAT_Rating AS RAT_Rating,
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
            AC_part_PR_in_RAT_got t
    ) tie
LEFT JOIN
    RAT_Rating "RAT_got"
ON
    "RAT_got".RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.AC_part_PR_in_RAT_got_ChangedAt,
            tie.AC_ID_part,
            tie.PR_ID_in,
            "RAT_got".RAT_Rating AS RAT_Rating,
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
                    AC_part_PR_in_RAT_got t
                WHERE
                    t.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            RAT_Rating "RAT_got"
        ON
            "RAT_got".RAT_ID = tie.RAT_ID_got
        WHERE
            tie.AC_part_PR_in_RAT_got_ChangedAt = tie.latestTime
    ]';
END pAC_part_PR_in_RAT_got;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_part_PR_in_RAT_got
AS
SELECT
    *
FROM
    pAC_part_PR_in_RAT_got(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dAC_part_PR_in_RAT_got (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.AC_part_PR_in_RAT_got_ChangedAt,
            tie.AC_ID_part,
            tie.PR_ID_in,
            "RAT_got".RAT_Rating AS RAT_Rating,
            tie.RAT_ID_got
        FROM
            AC_part_PR_in_RAT_got tie
        LEFT JOIN
            RAT_Rating "RAT_got"
        ON
            "RAT_got".RAT_ID = tie.RAT_ID_got
        WHERE
            tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_part_PR_in_RAT_got;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lST_at_PR_isPlaying (
    ST_at_PR_isPlaying_ChangedAt,
    ST_ID_at,
    PR_ID_isPlaying
)
AS
SELECT
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
            ST_at_PR_isPlaying t
    ) tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pST_at_PR_isPlaying (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
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
                    ST_at_PR_isPlaying t
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
CREATE OR REPLACE VIEW nST_at_PR_isPlaying
AS
SELECT
    *
FROM
    pST_at_PR_isPlaying(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dST_at_PR_isPlaying (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.ST_at_PR_isPlaying_ChangedAt,
            tie.ST_ID_at,
            tie.PR_ID_isPlaying
        FROM
            ST_at_PR_isPlaying tie
        WHERE
            tie.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dST_at_PR_isPlaying;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_parent_AC_child_PAT_having (
    AC_ID_parent,
    AC_ID_child,
    PAT_ParentalType,
    PAT_ID_having
)
AS
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    "PAT_having".PAT_ParentalType AS PAT_ParentalType,
    tie.PAT_ID_having
FROM
    AC_parent_AC_child_PAT_having tie
LEFT JOIN
    PAT_ParentalType "PAT_having"
ON
    "PAT_having".PAT_ID = tie.PAT_ID_having
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_parent_AC_child_PAT_having (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.AC_ID_parent,
            tie.AC_ID_child,
            "PAT_having".PAT_ParentalType AS PAT_ParentalType,
            tie.PAT_ID_having
        FROM
            AC_parent_AC_child_PAT_having tie
        LEFT JOIN
            PAT_ParentalType "PAT_having"
        ON
            "PAT_having".PAT_ID = tie.PAT_ID_having
    ]';
END pAC_parent_AC_child_PAT_having;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    pAC_parent_AC_child_PAT_having(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lPR_content_ST_location_EV_of (
    PR_ID_content,
    ST_ID_location,
    EV_ID_of
)
AS
SELECT
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    PR_content_ST_location_EV_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pPR_content_ST_location_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.PR_ID_content,
            tie.ST_ID_location,
            tie.EV_ID_of
        FROM
            PR_content_ST_location_EV_of tie
    ]';
END pPR_content_ST_location_EV_of;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nPR_content_ST_location_EV_of
AS
SELECT
    *
FROM
    pPR_content_ST_location_EV_of(CAST(current_timestamp AS timestamp(9)))
;
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
CREATE OR REPLACE PROCEDURE ip_EV_DAT_Event_Date (
    p_owner IN EV_DAT_Event_Date.EV_ID%TYPE,
    p_value IN EV_DAT_Event_Date.EV_DAT_Event_Date%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN EV_DAT_Event_Date.EV_DAT_Event_Date%TYPE,
        b IN EV_DAT_Event_Date.EV_DAT_Event_Date%TYPE
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
            EV_DAT_Event_Date x
        WHERE
            x.EV_ID = p_owner
    ) LOOP
        IF same(r.EV_DAT_Event_Date, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner);
    END LOOP;
    INSERT INTO EV_DAT_Event_Date (
        EV_ID,
        EV_DAT_Event_Date
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_EV_DAT_Event_Date;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Event_Audience states a value of EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_AUD_Event_Audience (
    p_owner IN EV_AUD_Event_Audience.EV_ID%TYPE,
    p_value IN EV_AUD_Event_Audience.EV_AUD_Event_Audience%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN EV_AUD_Event_Audience.EV_AUD_Event_Audience%TYPE,
        b IN EV_AUD_Event_Audience.EV_AUD_Event_Audience%TYPE
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
            EV_AUD_Event_Audience x
        WHERE
            x.EV_ID = p_owner
    ) LOOP
        IF same(r.EV_AUD_Event_Audience, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner);
    END LOOP;
    INSERT INTO EV_AUD_Event_Audience (
        EV_ID,
        EV_AUD_Event_Audience
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_EV_AUD_Event_Audience;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Event_Revenue states a value of EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_REV_Event_Revenue (
    p_owner IN EV_REV_Event_Revenue.EV_ID%TYPE,
    p_value IN EV_REV_Event_Revenue.EV_REV_Event_Revenue%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN EV_REV_Event_Revenue.EV_REV_Event_Revenue%TYPE,
        b IN EV_REV_Event_Revenue.EV_REV_Event_Revenue%TYPE
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
            EV_REV_Event_Revenue x
        WHERE
            x.EV_ID = p_owner
    ) LOOP
        IF same(r.EV_REV_Event_Revenue, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner);
    END LOOP;
    INSERT INTO EV_REV_Event_Revenue (
        EV_ID,
        EV_REV_Event_Revenue
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_EV_REV_Event_Revenue;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Stage_Name states a value of ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_NAM_Stage_Name (
    p_owner IN ST_NAM_Stage_Name.ST_ID%TYPE,
    p_changing IN ST_NAM_Stage_Name.ST_NAM_ChangedAt%TYPE,
    p_value IN ST_NAM_Stage_Name.ST_NAM_Stage_Name%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN ST_NAM_Stage_Name.ST_NAM_Stage_Name%TYPE,
        b IN ST_NAM_Stage_Name.ST_NAM_Stage_Name%TYPE
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
            ST_NAM_Stage_Name x
        WHERE
            x.ST_ID = p_owner
        AND
            x.ST_NAM_ChangedAt = p_changing
    ) LOOP
        IF same(r.ST_NAM_Stage_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO ST_NAM_Stage_Name (
        ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    VALUES (
        p_owner,
        p_changing,
        p_value
    );
END ip_ST_NAM_Stage_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Stage_Location states a value of ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_LOC_Stage_Location (
    p_owner IN ST_LOC_Stage_Location.ST_ID%TYPE,
    p_value IN ST_LOC_Stage_Location.ST_LOC_Stage_Location%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN ST_LOC_Stage_Location.ST_LOC_Stage_Location%TYPE,
        b IN ST_LOC_Stage_Location.ST_LOC_Stage_Location%TYPE
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
            ST_LOC_Stage_Location x
        WHERE
            x.ST_ID = p_owner
    ) LOOP
        IF same(r.ST_LOC_Stage_Location, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner);
    END LOOP;
    INSERT INTO ST_LOC_Stage_Location (
        ST_ID,
        ST_LOC_Stage_Location
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_ST_LOC_Stage_Location;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Stage_Average states a value of ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_AVG_Stage_Average (
    p_owner IN ST_AVG_Stage_Average.ST_ID%TYPE,
    p_changing IN ST_AVG_Stage_Average.ST_AVG_ChangedAt%TYPE,
    p_value IN ST_AVG_Stage_Average.UTL_ID%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN ST_AVG_Stage_Average.UTL_ID%TYPE,
        b IN ST_AVG_Stage_Average.UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.UTL_ID
        FROM
            ST_AVG_Stage_Average x
        WHERE
            x.ST_ID = p_owner
        AND
            x.ST_AVG_ChangedAt = p_changing
    ) LOOP
        IF same(r.UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.UTL_ID
        FROM
            ST_AVG_Stage_Average p
        WHERE
            p.ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < p_changing
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.UTL_ID, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.ST_AVG_ChangedAt,
            f.UTL_ID
        FROM
            ST_AVG_Stage_Average f
        WHERE
            f.ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > p_changing
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.UTL_ID, p_value) THEN
            DELETE FROM
                ST_AVG_Stage_Average
            WHERE
                ST_ID = p_owner
            AND
                ST_AVG_ChangedAt = r.ST_AVG_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO ST_AVG_Stage_Average (
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    )
    VALUES (
        p_owner,
        p_changing,
        p_value
    );
END ip_ST_AVG_Stage_Average;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Stage_Minimum states a value of ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_MIN_Stage_Minimum (
    p_owner IN ST_MIN_Stage_Minimum.ST_ID%TYPE,
    p_value IN ST_MIN_Stage_Minimum.UTL_ID%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN ST_MIN_Stage_Minimum.UTL_ID%TYPE,
        b IN ST_MIN_Stage_Minimum.UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.UTL_ID
        FROM
            ST_MIN_Stage_Minimum x
        WHERE
            x.ST_ID = p_owner
    ) LOOP
        IF same(r.UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner);
    END LOOP;
    INSERT INTO ST_MIN_Stage_Minimum (
        ST_ID,
        UTL_ID
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_ST_MIN_Stage_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Actor_Name states a value of AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_NAM_Actor_Name (
    p_owner IN AC_NAM_Actor_Name.AC_ID%TYPE,
    p_changing IN AC_NAM_Actor_Name.AC_NAM_ChangedAt%TYPE,
    p_value IN AC_NAM_Actor_Name.AC_NAM_Actor_Name%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN AC_NAM_Actor_Name.AC_NAM_Actor_Name%TYPE,
        b IN AC_NAM_Actor_Name.AC_NAM_Actor_Name%TYPE
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
            AC_NAM_Actor_Name x
        WHERE
            x.AC_ID = p_owner
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
            AC_NAM_Actor_Name p
        WHERE
            p.AC_ID = p_owner
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
            AC_NAM_Actor_Name f
        WHERE
            f.AC_ID = p_owner
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
    INSERT INTO AC_NAM_Actor_Name (
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    VALUES (
        p_owner,
        p_changing,
        p_value
    );
END ip_AC_NAM_Actor_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Actor_Gender states a value of AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_GEN_Actor_Gender (
    p_owner IN AC_GEN_Actor_Gender.AC_ID%TYPE,
    p_value IN AC_GEN_Actor_Gender.GEN_ID%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN AC_GEN_Actor_Gender.GEN_ID%TYPE,
        b IN AC_GEN_Actor_Gender.GEN_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.GEN_ID
        FROM
            AC_GEN_Actor_Gender x
        WHERE
            x.AC_ID = p_owner
    ) LOOP
        IF same(r.GEN_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner);
    END LOOP;
    INSERT INTO AC_GEN_Actor_Gender (
        AC_ID,
        GEN_ID
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_AC_GEN_Actor_Gender;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Actor_ProfessionalLevel states a value of AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_PLV_Actor_ProfessionalLevel (
    p_owner IN AC_PLV_Actor_ProfessionalLevel.AC_ID%TYPE,
    p_changing IN AC_PLV_Actor_ProfessionalLevel.AC_PLV_ChangedAt%TYPE,
    p_value IN AC_PLV_Actor_ProfessionalLevel.PLV_ID%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN AC_PLV_Actor_ProfessionalLevel.PLV_ID%TYPE,
        b IN AC_PLV_Actor_ProfessionalLevel.PLV_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.PLV_ID
        FROM
            AC_PLV_Actor_ProfessionalLevel x
        WHERE
            x.AC_ID = p_owner
        AND
            x.AC_PLV_ChangedAt = p_changing
    ) LOOP
        IF same(r.PLV_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO AC_PLV_Actor_ProfessionalLevel (
        AC_ID,
        AC_PLV_ChangedAt,
        PLV_ID
    )
    VALUES (
        p_owner,
        p_changing,
        p_value
    );
END ip_AC_PLV_Actor_ProfessionalLevel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Program_Name states a value of PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_PR_NAM_Program_Name (
    p_owner IN PR_NAM_Program_Name.PR_ID%TYPE,
    p_value IN PR_NAM_Program_Name.PR_NAM_Program_Name%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN PR_NAM_Program_Name.PR_NAM_Program_Name%TYPE,
        b IN PR_NAM_Program_Name.PR_NAM_Program_Name%TYPE
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
            PR_NAM_Program_Name x
        WHERE
            x.PR_ID = p_owner
    ) LOOP
        IF same(r.PR_NAM_Program_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner);
    END LOOP;
    INSERT INTO PR_NAM_Program_Name (
        PR_ID,
        PR_NAM_Program_Name
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_PR_NAM_Program_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Program_Length states a value of PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_PR_LEN_Program_Length (
    p_owner IN PR_LEN_Program_Length.PR_ID%TYPE,
    p_changing IN PR_LEN_Program_Length.PR_LEN_ChangedAt%TYPE,
    p_value IN PR_LEN_Program_Length.PR_LEN_Program_Length%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN PR_LEN_Program_Length.PR_LEN_Program_Length%TYPE,
        b IN PR_LEN_Program_Length.PR_LEN_Program_Length%TYPE
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
            PR_LEN_Program_Length x
        WHERE
            x.PR_ID = p_owner
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
            PR_LEN_Program_Length p
        WHERE
            p.PR_ID = p_owner
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
            PR_LEN_Program_Length f
        WHERE
            f.PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > p_changing
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.PR_LEN_Program_Length, p_value) THEN
            DELETE FROM
                PR_LEN_Program_Length
            WHERE
                PR_ID = p_owner
            AND
                PR_LEN_ChangedAt = r.PR_LEN_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO PR_LEN_Program_Length (
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    VALUES (
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
CREATE OR REPLACE TRIGGER it_lST_Stage
INSTEAD OF INSERT ON lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    v_id := :NEW.ST_ID;
    IF v_id IS NULL THEN
        INSERT INTO ST_Stage (
            ST_Dummy
        )
        VALUES (
            NULL
        )
        RETURNING ST_ID INTO v_id;
    END IF;
    IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
        ip_ST_NAM_Stage_Name(
            p_owner => COALESCE(:NEW.ST_ID, v_id),
            p_changing => COALESCE(:NEW.ST_NAM_ChangedAt, v_now),
            p_value => :NEW.ST_NAM_Stage_Name
        );
    END IF;
    IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
        ip_ST_LOC_Stage_Location(
            p_owner => COALESCE(:NEW.ST_ID, v_id),
            p_value => :NEW.ST_LOC_Stage_Location
        );
    END IF;
    v_AVG := :NEW.UTL_ID;
    IF v_AVG IS NULL AND :NEW.UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_AVG := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_AVG IS NOT NULL THEN
        ip_ST_AVG_Stage_Average(
            p_owner => COALESCE(:NEW.ST_ID, v_id),
            p_changing => COALESCE(:NEW.ST_AVG_ChangedAt, v_now),
            p_value => v_AVG
        );
    END IF;
    v_MIN := :NEW.UTL_ID;
    IF v_MIN IS NULL AND :NEW.UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_MIN := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_MIN IS NOT NULL THEN
        ip_ST_MIN_Stage_Minimum(
            p_owner => COALESCE(:NEW.ST_ID, v_id),
            p_value => v_MIN
        );
    END IF;
END it_lST_Stage;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lST_Stage
INSTEAD OF UPDATE ON lST_Stage
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
    IF (:NEW.ST_NAM_Stage_Name <> :OLD.ST_NAM_Stage_Name
        OR (:NEW.ST_NAM_Stage_Name IS NULL AND :OLD.ST_NAM_Stage_Name IS NOT NULL)
        OR (:NEW.ST_NAM_Stage_Name IS NOT NULL AND :OLD.ST_NAM_Stage_Name IS NULL))
    OR (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
            ip_ST_NAM_Stage_Name(
                p_owner => COALESCE(:NEW.ST_ID, :NEW.ST_ID),
                p_changing => CASE
                    WHEN (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
                        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
                        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL))
                    THEN :NEW.ST_NAM_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.ST_NAM_Stage_Name
            );
        END IF;
    END IF;
    IF (:NEW.ST_LOC_Stage_Location <> :OLD.ST_LOC_Stage_Location
        OR (:NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL)
        OR (:NEW.ST_LOC_Stage_Location IS NOT NULL AND :OLD.ST_LOC_Stage_Location IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
            ip_ST_LOC_Stage_Location(
                p_owner => COALESCE(:NEW.ST_ID, :NEW.ST_ID),
                p_value => :NEW.ST_LOC_Stage_Location
            );
        END IF;
    END IF;
    IF (:NEW.UTL_ID <> :OLD.UTL_ID
        OR (:NEW.UTL_ID IS NULL AND :OLD.UTL_ID IS NOT NULL)
        OR (:NEW.UTL_ID IS NOT NULL AND :OLD.UTL_ID IS NULL))
    OR (:NEW.UTL_Utilization <> :OLD.UTL_Utilization
        OR (:NEW.UTL_Utilization IS NULL AND :OLD.UTL_Utilization IS NOT NULL)
        OR (:NEW.UTL_Utilization IS NOT NULL AND :OLD.UTL_Utilization IS NULL))
    OR (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_AVG := :NEW.UTL_ID;
        IF (v_AVG = :OLD.UTL_ID OR (v_AVG IS NULL AND :OLD.UTL_ID IS NULL))
        AND :NEW.UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.UTL_Utilization
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
            :OLD.UTL_ID IS NULL OR
            :OLD.UTL_ID <> v_AVG
        ) THEN
            ip_ST_AVG_Stage_Average(
                p_owner => COALESCE(:NEW.ST_ID, :NEW.ST_ID),
                p_changing => CASE
                    WHEN (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
                        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
                        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL))
                    THEN :NEW.ST_AVG_ChangedAt
                    ELSE v_now
                END,
                p_value => v_AVG
            );
        END IF;
    END IF;
    IF (:NEW.UTL_ID <> :OLD.UTL_ID
        OR (:NEW.UTL_ID IS NULL AND :OLD.UTL_ID IS NOT NULL)
        OR (:NEW.UTL_ID IS NOT NULL AND :OLD.UTL_ID IS NULL))
    OR (:NEW.UTL_Utilization <> :OLD.UTL_Utilization
        OR (:NEW.UTL_Utilization IS NULL AND :OLD.UTL_Utilization IS NOT NULL)
        OR (:NEW.UTL_Utilization IS NOT NULL AND :OLD.UTL_Utilization IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_MIN := :NEW.UTL_ID;
        IF (v_MIN = :OLD.UTL_ID OR (v_MIN IS NULL AND :OLD.UTL_ID IS NULL))
        AND :NEW.UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_MIN := kv.UTL_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_MIN IS NOT NULL AND (
            :OLD.UTL_ID IS NULL OR
            :OLD.UTL_ID <> v_MIN
        ) THEN
            ip_ST_MIN_Stage_Minimum(
                p_owner => COALESCE(:NEW.ST_ID, :NEW.ST_ID),
                p_value => v_MIN
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_ST_MIN = 1
    AND :OLD.UTL_ID IS NOT NULL
    AND (:NEW.UTL_ID IS NULL OR :NEW.UTL_Utilization IS NULL)
    THEN
        INSERT INTO ST_MIN_Stage_Minimum_Deleted (
            ST_ID,
            UTL_ID,
            ST_MIN_Deleted
        )
        SELECT
            x.ST_ID,
            x.UTL_ID,
            v_now
        FROM
            ST_MIN_Stage_Minimum x
        WHERE
            x.ST_ID = :OLD.ST_ID;
        DELETE FROM
            ST_MIN_Stage_Minimum
        WHERE
            ST_ID = :OLD.ST_ID;
    END IF;
END ut_lST_Stage;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lST_Stage
INSTEAD OF DELETE ON lST_Stage
FOR EACH ROW
BEGIN
    DELETE FROM
        ST_NAM_Stage_Name x
    WHERE
        x.ST_ID = :OLD.ST_ID
    AND
        x.ST_NAM_ChangedAt = :OLD.ST_NAM_ChangedAt
    ;
    DELETE FROM
        ST_LOC_Stage_Location x
    WHERE
        x.ST_ID = :OLD.ST_ID
    ;
    DELETE FROM
        ST_AVG_Stage_Average x
    WHERE
        x.ST_ID = :OLD.ST_ID
    AND
        x.ST_AVG_ChangedAt = :OLD.ST_AVG_ChangedAt
    ;
    DELETE FROM
        ST_MIN_Stage_Minimum x
    WHERE
        x.ST_ID = :OLD.ST_ID
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        ST_Stage a
    WHERE
        a.ST_ID = :OLD.ST_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            ST_NAM_Stage_Name x
        WHERE
            x.ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            ST_LOC_Stage_Location x
        WHERE
            x.ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            ST_AVG_Stage_Average x
        WHERE
            x.ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            ST_MIN_Stage_Minimum x
        WHERE
            x.ST_ID = a.ST_ID
    )
    ;
END dt_lST_Stage;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_Actor
INSTEAD OF INSERT ON lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    v_id := :NEW.AC_ID;
    IF v_id IS NULL THEN
        INSERT INTO AC_Actor (
            AC_Dummy
        )
        VALUES (
            NULL
        )
        RETURNING AC_ID INTO v_id;
    END IF;
    IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
        ip_AC_NAM_Actor_Name(
            p_owner => COALESCE(:NEW.AC_ID, v_id),
            p_changing => COALESCE(:NEW.AC_NAM_ChangedAt, v_now),
            p_value => :NEW.AC_NAM_Actor_Name
        );
    END IF;
    v_GEN := :NEW.GEN_ID;
    IF v_GEN IS NULL AND :NEW.GEN_Gender IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GEN_ID
            FROM
                GEN_Gender k
            WHERE
                k.GEN_Gender = :NEW.GEN_Gender
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GEN := kv.GEN_ID;
        END LOOP;
    END IF;
    IF v_GEN IS NOT NULL THEN
        ip_AC_GEN_Actor_Gender(
            p_owner => COALESCE(:NEW.AC_ID, v_id),
            p_value => v_GEN
        );
    END IF;
    v_PLV := :NEW.PLV_ID;
    IF v_PLV IS NULL AND :NEW.PLV_ProfessionalLevel IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                PLV_ProfessionalLevel k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.PLV_ProfessionalLevel, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PLV := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_PLV IS NOT NULL THEN
        ip_AC_PLV_Actor_ProfessionalLevel(
            p_owner => COALESCE(:NEW.AC_ID, v_id),
            p_changing => COALESCE(:NEW.AC_PLV_ChangedAt, v_now),
            p_value => v_PLV
        );
    END IF;
END it_lAC_Actor;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lAC_Actor
INSTEAD OF UPDATE ON lAC_Actor
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
    IF (:NEW.AC_NAM_Actor_Name <> :OLD.AC_NAM_Actor_Name
        OR (:NEW.AC_NAM_Actor_Name IS NULL AND :OLD.AC_NAM_Actor_Name IS NOT NULL)
        OR (:NEW.AC_NAM_Actor_Name IS NOT NULL AND :OLD.AC_NAM_Actor_Name IS NULL))
    OR (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
            ip_AC_NAM_Actor_Name(
                p_owner => COALESCE(:NEW.AC_ID, :NEW.AC_ID),
                p_changing => CASE
                    WHEN (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
                        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL))
                    THEN :NEW.AC_NAM_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.AC_NAM_Actor_Name
            );
        END IF;
    END IF;
    IF (:NEW.GEN_ID <> :OLD.GEN_ID
        OR (:NEW.GEN_ID IS NULL AND :OLD.GEN_ID IS NOT NULL)
        OR (:NEW.GEN_ID IS NOT NULL AND :OLD.GEN_ID IS NULL))
    OR (:NEW.GEN_Gender <> :OLD.GEN_Gender
        OR (:NEW.GEN_Gender IS NULL AND :OLD.GEN_Gender IS NOT NULL)
        OR (:NEW.GEN_Gender IS NOT NULL AND :OLD.GEN_Gender IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_GEN := :NEW.GEN_ID;
        IF (v_GEN = :OLD.GEN_ID OR (v_GEN IS NULL AND :OLD.GEN_ID IS NULL))
        AND :NEW.GEN_Gender IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GEN_ID
                FROM
                    GEN_Gender k
                WHERE
                    k.GEN_Gender = :NEW.GEN_Gender
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GEN := kv.GEN_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_GEN IS NOT NULL AND (
            :OLD.GEN_ID IS NULL OR
            :OLD.GEN_ID <> v_GEN
        ) THEN
            ip_AC_GEN_Actor_Gender(
                p_owner => COALESCE(:NEW.AC_ID, :NEW.AC_ID),
                p_value => v_GEN
            );
        END IF;
    END IF;
    IF (:NEW.PLV_ID <> :OLD.PLV_ID
        OR (:NEW.PLV_ID IS NULL AND :OLD.PLV_ID IS NOT NULL)
        OR (:NEW.PLV_ID IS NOT NULL AND :OLD.PLV_ID IS NULL))
    OR (:NEW.PLV_ProfessionalLevel <> :OLD.PLV_ProfessionalLevel
        OR (:NEW.PLV_ProfessionalLevel IS NULL AND :OLD.PLV_ProfessionalLevel IS NOT NULL)
        OR (:NEW.PLV_ProfessionalLevel IS NOT NULL AND :OLD.PLV_ProfessionalLevel IS NULL))
    OR (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_PLV := :NEW.PLV_ID;
        IF (v_PLV = :OLD.PLV_ID OR (v_PLV IS NULL AND :OLD.PLV_ID IS NULL))
        AND :NEW.PLV_ProfessionalLevel IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    PLV_ProfessionalLevel k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.PLV_ProfessionalLevel, 'MD5')
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
            :OLD.PLV_ID IS NULL OR
            :OLD.PLV_ID <> v_PLV
        ) THEN
            ip_AC_PLV_Actor_ProfessionalLevel(
                p_owner => COALESCE(:NEW.AC_ID, :NEW.AC_ID),
                p_changing => CASE
                    WHEN (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
                        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL))
                    THEN :NEW.AC_PLV_ChangedAt
                    ELSE v_now
                END,
                p_value => v_PLV
            );
        END IF;
    END IF;
END ut_lAC_Actor;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_Actor
INSTEAD OF DELETE ON lAC_Actor
FOR EACH ROW
BEGIN
    DELETE FROM
        AC_NAM_Actor_Name x
    WHERE
        x.AC_ID = :OLD.AC_ID
    AND
        x.AC_NAM_ChangedAt = :OLD.AC_NAM_ChangedAt
    ;
    DELETE FROM
        AC_GEN_Actor_Gender x
    WHERE
        x.AC_ID = :OLD.AC_ID
    ;
    DELETE FROM
        AC_PLV_Actor_ProfessionalLevel x
    WHERE
        x.AC_ID = :OLD.AC_ID
    AND
        x.AC_PLV_ChangedAt = :OLD.AC_PLV_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        AC_Actor a
    WHERE
        a.AC_ID = :OLD.AC_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            AC_NAM_Actor_Name x
        WHERE
            x.AC_ID = a.AC_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            AC_GEN_Actor_Gender x
        WHERE
            x.AC_ID = a.AC_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            AC_PLV_Actor_ProfessionalLevel x
        WHERE
            x.AC_ID = a.AC_ID
    )
    ;
END dt_lAC_Actor;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lPR_Program
INSTEAD OF INSERT ON lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
BEGIN
    v_id := :NEW.PR_ID;
    IF v_id IS NULL THEN
        INSERT INTO PR_Program (
            PR_Dummy
        )
        VALUES (
            NULL
        )
        RETURNING PR_ID INTO v_id;
    END IF;
    IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
        ip_PR_NAM_Program_Name(
            p_owner => COALESCE(:NEW.PR_ID, v_id),
            p_value => :NEW.PR_NAM_Program_Name
        );
    END IF;
    IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
        ip_PR_LEN_Program_Length(
            p_owner => COALESCE(:NEW.PR_ID, v_id),
            p_changing => COALESCE(:NEW.PR_LEN_ChangedAt, v_now),
            p_value => :NEW.PR_LEN_Program_Length
        );
    END IF;
END it_lPR_Program;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lPR_Program
INSTEAD OF UPDATE ON lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    IF (:NEW.PR_ID <> :OLD.PR_ID
        OR (:NEW.PR_ID IS NULL AND :OLD.PR_ID IS NOT NULL)
        OR (:NEW.PR_ID IS NOT NULL AND :OLD.PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_Program_Name <> :OLD.PR_NAM_Program_Name
        OR (:NEW.PR_NAM_Program_Name IS NULL AND :OLD.PR_NAM_Program_Name IS NOT NULL)
        OR (:NEW.PR_NAM_Program_Name IS NOT NULL AND :OLD.PR_NAM_Program_Name IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
            ip_PR_NAM_Program_Name(
                p_owner => COALESCE(:NEW.PR_ID, :NEW.PR_ID),
                p_value => :NEW.PR_NAM_Program_Name
            );
        END IF;
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
            ip_PR_LEN_Program_Length(
                p_owner => COALESCE(:NEW.PR_ID, :NEW.PR_ID),
                p_changing => CASE
                    WHEN (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
                        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
                        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL))
                    THEN :NEW.PR_LEN_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.PR_LEN_Program_Length
            );
        END IF;
    END IF;
END ut_lPR_Program;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lPR_Program
INSTEAD OF DELETE ON lPR_Program
FOR EACH ROW
BEGIN
    DELETE FROM
        PR_NAM_Program_Name x
    WHERE
        x.PR_ID = :OLD.PR_ID
    ;
    DELETE FROM
        PR_LEN_Program_Length x
    WHERE
        x.PR_ID = :OLD.PR_ID
    AND
        x.PR_LEN_ChangedAt = :OLD.PR_LEN_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        PR_Program a
    WHERE
        a.PR_ID = :OLD.PR_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            PR_NAM_Program_Name x
        WHERE
            x.PR_ID = a.PR_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            PR_LEN_Program_Length x
        WHERE
            x.PR_ID = a.PR_ID
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
CREATE OR REPLACE TRIGGER it_lEV_Event
INSTEAD OF INSERT ON lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_ETY_of number(3);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        -- the identity of the knot value of the role, given as it is or looked up from the value
        v_ETY_of := :NEW.ETY_ID_of;
        IF v_ETY_of IS NULL AND :NEW.ETY_EventType IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.ETY_ID
                FROM
                    ETY_EventType k
                WHERE
                    k.ETY_EventType = :NEW.ETY_EventType
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_ETY_of := kv.ETY_ID;
            END LOOP;
        END IF;
        INSERT INTO EV_Event (
            ST_ID_wasHeldAt,
            PR_ID_wasPlayed,
            ETY_ID_of,
            EV_Dummy
        )
        VALUES (
            :NEW.ST_ID_wasHeldAt,
            :NEW.PR_ID_wasPlayed,
            v_ETY_of,
            NULL
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_DAT_Event_Date IS NOT NULL THEN
        ip_EV_DAT_Event_Date(
            p_owner => COALESCE(:NEW.EV_ID, v_id),
            p_value => :NEW.EV_DAT_Event_Date
        );
    END IF;
    IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
        ip_EV_AUD_Event_Audience(
            p_owner => COALESCE(:NEW.EV_ID, v_id),
            p_value => :NEW.EV_AUD_Event_Audience
        );
    END IF;
    IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
        ip_EV_REV_Event_Revenue(
            p_owner => COALESCE(:NEW.EV_ID, v_id),
            p_value => :NEW.EV_REV_Event_Revenue
        );
    END IF;
END it_lEV_Event;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lEV_Event
INSTEAD OF UPDATE ON lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
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
    IF (:NEW.ETY_EventType <> :OLD.ETY_EventType
        OR (:NEW.ETY_EventType IS NULL AND :OLD.ETY_EventType IS NOT NULL)
        OR (:NEW.ETY_EventType IS NOT NULL AND :OLD.ETY_EventType IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column ETY_EventType is not updatable.');
    END IF;
    IF (:NEW.EV_DAT_Event_Date <> :OLD.EV_DAT_Event_Date
        OR (:NEW.EV_DAT_Event_Date IS NULL AND :OLD.EV_DAT_Event_Date IS NOT NULL)
        OR (:NEW.EV_DAT_Event_Date IS NOT NULL AND :OLD.EV_DAT_Event_Date IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_DAT_Event_Date IS NOT NULL THEN
            ip_EV_DAT_Event_Date(
                p_owner => COALESCE(:NEW.EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_DAT_Event_Date
            );
        END IF;
    END IF;
    IF (:NEW.EV_AUD_Event_Audience <> :OLD.EV_AUD_Event_Audience
        OR (:NEW.EV_AUD_Event_Audience IS NULL AND :OLD.EV_AUD_Event_Audience IS NOT NULL)
        OR (:NEW.EV_AUD_Event_Audience IS NOT NULL AND :OLD.EV_AUD_Event_Audience IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
            ip_EV_AUD_Event_Audience(
                p_owner => COALESCE(:NEW.EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_AUD_Event_Audience
            );
        END IF;
    END IF;
    IF (:NEW.EV_REV_Event_Revenue <> :OLD.EV_REV_Event_Revenue
        OR (:NEW.EV_REV_Event_Revenue IS NULL AND :OLD.EV_REV_Event_Revenue IS NOT NULL)
        OR (:NEW.EV_REV_Event_Revenue IS NOT NULL AND :OLD.EV_REV_Event_Revenue IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
            ip_EV_REV_Event_Revenue(
                p_owner => COALESCE(:NEW.EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_REV_Event_Revenue
            );
        END IF;
    END IF;
END ut_lEV_Event;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lEV_Event
INSTEAD OF DELETE ON lEV_Event
FOR EACH ROW
BEGIN
    DELETE FROM
        EV_DAT_Event_Date x
    WHERE
        x.EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        EV_AUD_Event_Audience x
    WHERE
        x.EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        EV_REV_Event_Revenue x
    WHERE
        x.EV_ID = :OLD.EV_ID
    ;
    -- a nexus that has no attribute rows left is removed
    DELETE FROM
        EV_Event a
    WHERE
        a.EV_ID = :OLD.EV_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            EV_DAT_Event_Date x
        WHERE
            x.EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            EV_AUD_Event_Audience x
        WHERE
            x.EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            EV_REV_Event_Revenue x
        WHERE
            x.EV_ID = a.EV_ID
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
CREATE OR REPLACE PROCEDURE ip_AC_partner_AC_with_ONG_currently (
    p_AC_partner IN AC_partner_AC_with_ONG_currently.AC_ID_partner%TYPE,
    p_AC_with IN AC_partner_AC_with_ONG_currently.AC_ID_with%TYPE,
    p_ONG_currently IN AC_partner_AC_with_ONG_currently.ONG_ID_currently%TYPE,
    p_changing IN AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
BEGIN
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            AC_partner_AC_with_ONG_currently x
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
    INSERT INTO AC_partner_AC_with_ONG_currently (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    VALUES (
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
CREATE OR REPLACE TRIGGER it_lAC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF v_ONG_currently IS NULL AND :NEW.ONG_Ongoing IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                ONG_Ongoing k
            WHERE
                k.ONG_Ongoing = :NEW.ONG_Ongoing
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_ONG_currently := kv.ONG_ID;
        END LOOP;
    END IF;
    ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => v_ONG_currently,
        p_changing => :NEW.AC_partner_AC_with_ONG_currently_ChangedAt
    );
END it_lAC_partner_AC_with_ONG_currently;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lAC_partner_AC_with_ONG_currently
INSTEAD OF UPDATE ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changed NUMBER(1);
    v_changing AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_ONG_currently number(3);
BEGIN
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF (:NEW.ONG_Ongoing <> :OLD.ONG_Ongoing
        OR (:NEW.ONG_Ongoing IS NULL AND :OLD.ONG_Ongoing IS NOT NULL)
        OR (:NEW.ONG_Ongoing IS NOT NULL AND :OLD.ONG_Ongoing IS NULL)) THEN
        v_ONG_currently := NULL;
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                ONG_Ongoing k
            WHERE
                k.ONG_Ongoing = :NEW.ONG_Ongoing
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
        ip_AC_partner_AC_with_ONG_currently(
            p_AC_partner => :NEW.AC_ID_partner,
            p_AC_with => :NEW.AC_ID_with,
            p_ONG_currently => v_ONG_currently,
            p_changing => v_changing
        );
    END IF;
END ut_lAC_partner_AC_with_ONG_currently;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_partner_AC_with_ONG_currently
INSTEAD OF DELETE ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
BEGIN
    DELETE FROM
        AC_partner_AC_with_ONG_currently x
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
CREATE OR REPLACE PROCEDURE ip_AC_subset_PN_of (
    p_AC_subset IN AC_subset_PN_of.AC_ID_subset%TYPE,
    p_PN_of IN AC_subset_PN_of.PN_ID_of%TYPE
)
IS
BEGIN
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            AC_subset_PN_of x
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
    INSERT INTO AC_subset_PN_of (
        AC_ID_subset,
        PN_ID_of
    )
    VALUES (
        p_AC_subset,
        p_PN_of
    );
END ip_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_subset_PN_of
INSTEAD OF INSERT ON lAC_subset_PN_of
FOR EACH ROW
BEGIN
    ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of
    );
END it_lAC_subset_PN_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lAC_subset_PN_of
INSTEAD OF UPDATE ON lAC_subset_PN_of
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
        ip_AC_subset_PN_of(
            p_AC_subset => :NEW.AC_ID_subset,
            p_PN_of => :NEW.PN_ID_of
        );
    END IF;
END ut_lAC_subset_PN_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_subset_PN_of
INSTEAD OF DELETE ON lAC_subset_PN_of
FOR EACH ROW
BEGIN
    DELETE FROM
        AC_subset_PN_of x
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
CREATE OR REPLACE PROCEDURE ip_EV_in_AC_wasCast (
    p_EV_in IN EV_in_AC_wasCast.EV_ID_in%TYPE,
    p_AC_wasCast IN EV_in_AC_wasCast.AC_ID_wasCast%TYPE
)
IS
BEGIN
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            EV_in_AC_wasCast x
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
    INSERT INTO EV_in_AC_wasCast (
        EV_ID_in,
        AC_ID_wasCast
    )
    VALUES (
        p_EV_in,
        p_AC_wasCast
    );
END ip_EV_in_AC_wasCast;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lEV_in_AC_wasCast
INSTEAD OF INSERT ON lEV_in_AC_wasCast
FOR EACH ROW
BEGIN
    ip_EV_in_AC_wasCast(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_wasCast => :NEW.AC_ID_wasCast
    );
END it_lEV_in_AC_wasCast;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lEV_in_AC_wasCast
INSTEAD OF DELETE ON lEV_in_AC_wasCast
FOR EACH ROW
BEGIN
    DELETE FROM
        EV_in_AC_wasCast x
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
CREATE OR REPLACE PROCEDURE ip_AC_part_PR_in_RAT_got (
    p_AC_part IN AC_part_PR_in_RAT_got.AC_ID_part%TYPE,
    p_PR_in IN AC_part_PR_in_RAT_got.PR_ID_in%TYPE,
    p_RAT_got IN AC_part_PR_in_RAT_got.RAT_ID_got%TYPE,
    p_changing IN AC_part_PR_in_RAT_got.AC_part_PR_in_RAT_got_ChangedAt%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing AC_part_PR_in_RAT_got.AC_part_PR_in_RAT_got_ChangedAt%TYPE;
BEGIN
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            AC_part_PR_in_RAT_got x
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
            AC_part_PR_in_RAT_got x
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
    INSERT INTO AC_part_PR_in_RAT_got (
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    VALUES (
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
CREATE OR REPLACE TRIGGER it_lAC_part_PR_in_RAT_got
INSTEAD OF INSERT ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_RAT_got number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_RAT_got := :NEW.RAT_ID_got;
    IF v_RAT_got IS NULL AND :NEW.RAT_Rating IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                RAT_Rating k
            WHERE
                k.RAT_Rating = :NEW.RAT_Rating
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_RAT_got := kv.RAT_ID;
        END LOOP;
    END IF;
    ip_AC_part_PR_in_RAT_got(
        p_AC_part => :NEW.AC_ID_part,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_got => v_RAT_got,
        p_changing => :NEW.AC_part_PR_in_RAT_got_ChangedAt
    );
END it_lAC_part_PR_in_RAT_got;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lAC_part_PR_in_RAT_got
INSTEAD OF UPDATE ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changed NUMBER(1);
    v_changing AC_part_PR_in_RAT_got.AC_part_PR_in_RAT_got_ChangedAt%TYPE;
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
    IF (:NEW.RAT_Rating <> :OLD.RAT_Rating
        OR (:NEW.RAT_Rating IS NULL AND :OLD.RAT_Rating IS NOT NULL)
        OR (:NEW.RAT_Rating IS NOT NULL AND :OLD.RAT_Rating IS NULL)) THEN
        v_RAT_got := NULL;
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                RAT_Rating k
            WHERE
                k.RAT_Rating = :NEW.RAT_Rating
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
        ip_AC_part_PR_in_RAT_got(
            p_AC_part => :NEW.AC_ID_part,
            p_PR_in => :NEW.PR_ID_in,
            p_RAT_got => v_RAT_got,
            p_changing => v_changing
        );
    END IF;
END ut_lAC_part_PR_in_RAT_got;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_part_PR_in_RAT_got
INSTEAD OF DELETE ON lAC_part_PR_in_RAT_got
FOR EACH ROW
BEGIN
    DELETE FROM
        AC_part_PR_in_RAT_got x
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
CREATE OR REPLACE PROCEDURE ip_ST_at_PR_isPlaying (
    p_ST_at IN ST_at_PR_isPlaying.ST_ID_at%TYPE,
    p_PR_isPlaying IN ST_at_PR_isPlaying.PR_ID_isPlaying%TYPE,
    p_changing IN ST_at_PR_isPlaying.ST_at_PR_isPlaying_ChangedAt%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ST_at_PR_isPlaying.ST_at_PR_isPlaying_ChangedAt%TYPE;
BEGIN
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ST_at_PR_isPlaying x
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
    INSERT INTO ST_at_PR_isPlaying (
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    )
    VALUES (
        v_changing,
        p_ST_at,
        p_PR_isPlaying
    );
END ip_ST_at_PR_isPlaying;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lST_at_PR_isPlaying
INSTEAD OF INSERT ON lST_at_PR_isPlaying
FOR EACH ROW
BEGIN
    ip_ST_at_PR_isPlaying(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_isPlaying => :NEW.PR_ID_isPlaying,
        p_changing => :NEW.ST_at_PR_isPlaying_ChangedAt
    );
END it_lST_at_PR_isPlaying;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lST_at_PR_isPlaying
INSTEAD OF DELETE ON lST_at_PR_isPlaying
FOR EACH ROW
BEGIN
    DELETE FROM
        ST_at_PR_isPlaying x
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
CREATE OR REPLACE PROCEDURE ip_AC_parent_AC_child_PAT_having (
    p_AC_parent IN AC_parent_AC_child_PAT_having.AC_ID_parent%TYPE,
    p_AC_child IN AC_parent_AC_child_PAT_having.AC_ID_child%TYPE,
    p_PAT_having IN AC_parent_AC_child_PAT_having.PAT_ID_having%TYPE
)
IS
BEGIN
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            AC_parent_AC_child_PAT_having x
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
    INSERT INTO AC_parent_AC_child_PAT_having (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
    VALUES (
        p_AC_parent,
        p_AC_child,
        p_PAT_having
    );
END ip_AC_parent_AC_child_PAT_having;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_parent_AC_child_PAT_having
INSTEAD OF INSERT ON lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    v_PAT_having number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_PAT_having := :NEW.PAT_ID_having;
    IF v_PAT_having IS NULL AND :NEW.PAT_ParentalType IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PAT_ID
            FROM
                PAT_ParentalType k
            WHERE
                k.PAT_ParentalType = :NEW.PAT_ParentalType
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PAT_having := kv.PAT_ID;
        END LOOP;
    END IF;
    ip_AC_parent_AC_child_PAT_having(
        p_AC_parent => :NEW.AC_ID_parent,
        p_AC_child => :NEW.AC_ID_child,
        p_PAT_having => v_PAT_having
    );
END it_lAC_parent_AC_child_PAT_having;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_parent_AC_child_PAT_having
INSTEAD OF DELETE ON lAC_parent_AC_child_PAT_having
FOR EACH ROW
BEGIN
    DELETE FROM
        AC_parent_AC_child_PAT_having x
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
CREATE OR REPLACE PROCEDURE ip_PR_content_ST_location_EV_of (
    p_PR_content IN PR_content_ST_location_EV_of.PR_ID_content%TYPE,
    p_ST_location IN PR_content_ST_location_EV_of.ST_ID_location%TYPE,
    p_EV_of IN PR_content_ST_location_EV_of.EV_ID_of%TYPE
)
IS
BEGIN
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            PR_content_ST_location_EV_of x
        WHERE
            x.PR_ID_content = p_PR_content
        AND
            x.ST_ID_location = p_ST_location
        AND
            x.EV_ID_of = p_EV_of
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            PR_content_ST_location_EV_of x
        WHERE
            x.EV_ID_of = p_EV_of
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_content_ST_location_EV_of for: '
            || p_EV_of
        );
    END LOOP;
    INSERT INTO PR_content_ST_location_EV_of (
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    VALUES (
        p_PR_content,
        p_ST_location,
        p_EV_of
    );
END ip_PR_content_ST_location_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lPR_content_ST_location_EV_of
INSTEAD OF INSERT ON lPR_content_ST_location_EV_of
FOR EACH ROW
BEGIN
    ip_PR_content_ST_location_EV_of(
        p_PR_content => :NEW.PR_ID_content,
        p_ST_location => :NEW.ST_ID_location,
        p_EV_of => :NEW.EV_ID_of
    );
END it_lPR_content_ST_location_EV_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_content_ST_location_EV_of instead of UPDATE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lPR_content_ST_location_EV_of
INSTEAD OF UPDATE ON lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    IF (:NEW.EV_ID_of <> :OLD.EV_ID_of
        OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
        OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_ID_of is not updatable.');
    END IF;
    -- values that are left as they are state nothing
    IF
        :NEW.PR_ID_content IS NOT NULL
    AND
        :NEW.ST_ID_location IS NOT NULL
    AND
        (
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
        ip_PR_content_ST_location_EV_of(
            p_PR_content => :NEW.PR_ID_content,
            p_ST_location => :NEW.ST_ID_location,
            p_EV_of => :NEW.EV_ID_of
        );
    END IF;
END ut_lPR_content_ST_location_EV_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lPR_content_ST_location_EV_of
INSTEAD OF DELETE ON lPR_content_ST_location_EV_of
FOR EACH ROW
BEGIN
    DELETE FROM
        PR_content_ST_location_EV_of x
    WHERE
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
CREATE OR REPLACE VIEW key_ST_Stage_1st (
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
    lST_Stage "ST"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_ST_Stage_1st (
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
    key_ST_Stage_1st
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
    key_ST_Stage_1st
GROUP BY
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_ST_Stage_2nd (
    ST_ID,
    ST_NAM_Stage_Name
)
AS
SELECT
    "ST".ST_ID,
    "ST".ST_NAM_Stage_Name
FROM
    lST_Stage "ST"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_ST_Stage_2nd (
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
            pST_Stage(changingTimepoint) "ST"
    ]';
END pkey_ST_Stage_2nd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_ST_Stage_2nd (
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
    key_ST_Stage_2nd
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
    key_ST_Stage_2nd
GROUP BY
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_AC_Actor_1st (
    AC_ID,
    AC_NAM_Actor_Name
)
AS
SELECT
    "AC".AC_ID,
    "AC".AC_NAM_Actor_Name
FROM
    lAC_Actor "AC"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_AC_Actor_1st (
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
            pAC_Actor(changingTimepoint) "AC"
    ]';
END pkey_AC_Actor_1st;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_AC_Actor_1st (
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
    key_AC_Actor_1st
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
    key_AC_Actor_1st
GROUP BY
    AC_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_PR_Program_1st (
    PR_ID,
    PR_NAM_Program_Name
)
AS
SELECT
    "PR".PR_ID,
    "PR".PR_NAM_Program_Name
FROM
    lPR_Program "PR"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_PR_Program_1st (
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
    key_PR_Program_1st
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
    key_PR_Program_1st
GROUP BY
    PR_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_EV_Event_1st (
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
    lEV_Event "EV"
LEFT JOIN
    lST_Stage "s2"
ON
    "s2".ST_ID = "EV".ST_ID_wasHeldAt
LEFT JOIN
    lPR_Program "s4"
ON
    "s4".PR_ID = "EV".PR_ID_wasPlayed
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_EV_Event_1st (
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
    key_EV_Event_1st
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
    key_EV_Event_1st
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
COMMENT ON TABLE PAT_ParentalType IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON COLUMN PAT_ParentalType.PAT_ParentalType IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE GEN_Gender IS 'Gender of an actor.';
COMMENT ON COLUMN GEN_Gender.GEN_Gender IS 'Gender of an actor.';
COMMENT ON TABLE PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN PLV_ProfessionalLevel.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN UTL_Utilization.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE ONG_Ongoing IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN ONG_Ongoing.ONG_Ongoing IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE RAT_Rating IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN RAT_Rating.RAT_Rating IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON TABLE ETY_EventType IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN ETY_EventType.ETY_EventType IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN EV_DAT_Event_Date.EV_DAT_Event_Date IS 'Date and time when the event took place.';
COMMENT ON COLUMN EV_AUD_Event_Audience.EV_AUD_Event_Audience IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN EV_REV_Event_Revenue.EV_REV_Event_Revenue IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN ST_NAM_Stage_Name.ST_NAM_Stage_Name IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN ST_LOC_Stage_Location.ST_LOC_Stage_Location IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN ST_AVG_Stage_Average.UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN ST_MIN_Stage_Minimum.UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN AC_NAM_Actor_Name.AC_NAM_Actor_Name IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN AC_GEN_Actor_Gender.GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN AC_PLV_Actor_ProfessionalLevel.PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN PR_NAM_Program_Name.PR_NAM_Program_Name IS 'Name or title of the program.';
COMMENT ON COLUMN PR_LEN_Program_Length.PR_LEN_Program_Length IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE PN_Person IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE ST_Stage IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE AC_Actor IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE PR_Program IS 'A program, such as a play, show or concert, that can be played on stages.';
COMMENT ON TABLE EV_Event IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN EV_Event.ST_ID_wasHeldAt IS 'The stage at which the event was held.';
COMMENT ON COLUMN EV_Event.PR_ID_wasPlayed IS 'The program that was played at the event.';
COMMENT ON COLUMN EV_Event.ETY_ID_of IS 'The type of the event.';
COMMENT ON TABLE AC_partner_AC_with_ONG_currently IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN AC_partner_AC_with_ONG_currently.AC_ID_partner IS 'One of the actors in the partnership.';
COMMENT ON COLUMN AC_partner_AC_with_ONG_currently.AC_ID_with IS 'The other actor in the partnership.';
COMMENT ON COLUMN AC_partner_AC_with_ONG_currently.ONG_ID_currently IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON TABLE AC_subset_PN_of IS 'Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.';
COMMENT ON COLUMN AC_subset_PN_of.AC_ID_subset IS 'The actor.';
COMMENT ON COLUMN AC_subset_PN_of.PN_ID_of IS 'The person who is the actor.';
COMMENT ON TABLE EV_in_AC_wasCast IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN EV_in_AC_wasCast.EV_ID_in IS 'The event the actor was cast in.';
COMMENT ON COLUMN EV_in_AC_wasCast.AC_ID_wasCast IS 'An actor cast in the event.';
COMMENT ON TABLE AC_part_PR_in_RAT_got IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN AC_part_PR_in_RAT_got.AC_ID_part IS 'The actor having a part in the program.';
COMMENT ON COLUMN AC_part_PR_in_RAT_got.PR_ID_in IS 'The program the actor has a part in.';
COMMENT ON COLUMN AC_part_PR_in_RAT_got.RAT_ID_got IS 'The rating the actor got for the part.';
COMMENT ON TABLE ST_at_PR_isPlaying IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ST_at_PR_isPlaying.ST_ID_at IS 'The stage where the program is playing.';
COMMENT ON COLUMN ST_at_PR_isPlaying.PR_ID_isPlaying IS 'The program playing at the stage.';
COMMENT ON TABLE AC_parent_AC_child_PAT_having IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN AC_parent_AC_child_PAT_having.AC_ID_parent IS 'The actor who is the parent.';
COMMENT ON COLUMN AC_parent_AC_child_PAT_having.AC_ID_child IS 'The actor who is the child.';
COMMENT ON COLUMN AC_parent_AC_child_PAT_having.PAT_ID_having IS 'The type of parental relationship.';
COMMENT ON TABLE PR_content_ST_location_EV_of IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN PR_content_ST_location_EV_of.PR_ID_content IS 'The program that made up the content of the event.';
COMMENT ON COLUMN PR_content_ST_location_EV_of.ST_ID_location IS 'The stage where the event was located.';
COMMENT ON COLUMN PR_content_ST_location_EV_of.EV_ID_of IS 'The event.';
