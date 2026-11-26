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
-- Knots are immutable lookup tables for values.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PAT_ParentalType (
            PAT_ID number(5) not null,
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
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE GEN_Gender (
            GEN_ID number(5) not null,
            GEN_Gender nvarchar2(42) not null,
            Metadata_GEN number(10) not null,
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
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PLV_ProfessionalLevel (
            PLV_ID number(5) not null,
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
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE UTL_Utilization (
            UTL_ID number(5) not null,
            UTL_Utilization number(5) not null,
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
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ONG_Ongoing (
            ONG_ID number(5) not null,
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
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE RAT_Rating (
            RAT_ID number(5) not null,
            RAT_Rating nvarchar2(42) not null,
            Metadata_RAT number(10) not null,
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
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ETY_EventType (
            ETY_ID number(5) not null,
            ETY_EventType nvarchar2(42) not null,
            Metadata_ETY number(10) not null,
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
-- Anchors store immutable entity identities.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
-- Anchor table -------------------------------------------------------------------------------------------------------
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
-- Nexuses store immutable identities for event-like entities.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
-- Nexus table --------------------------------------------------------------------------------------------------------
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
            ETY_ID_of number(5) not null,
            Metadata_EV number(10) not null, 
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
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE EV_DAT_Event_Date_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_DAT_Event_Date_Posit (
            EV_DAT_ID number(10) default EV_DAT_Event_Date_Posit_ID_SEQ.nextval not null, 
            EV_DAT_EV_ID number(10) not null,
            EV_DAT_Event_Date timestamp not null,
            constraint fkEV_DAT_Event_Date_Posit foreign key (
                EV_DAT_EV_ID
            ) references EV_Event(EV_ID),
            constraint pkEV_DAT_Event_Date_Posit primary key (
                EV_DAT_ID
            ),
            constraint uqEV_DAT_Event_Date_Posit unique (
                EV_DAT_EV_ID,
                EV_DAT_Event_Date
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_DAT_Event_Date_Annex (
            EV_DAT_ID number(10) not null,
            EV_DAT_PositedAt timestamp not null,
            EV_DAT_Reliability number(5,2) not null,
            Metadata_EV_DAT number(10) not null,
            constraint fkEV_DAT_Event_Date_Annex foreign key (
                EV_DAT_ID
            ) references EV_DAT_Event_Date_Posit(EV_DAT_ID),
            constraint pkEV_DAT_Event_Date_Annex primary key (
                EV_DAT_ID,
                EV_DAT_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE EV_AUD_Event_Audience_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_AUD_Event_Audience_Posit (
            EV_AUD_ID number(10) default EV_AUD_Event_Audience_Posit_ID_SEQ.nextval not null, 
            EV_AUD_EV_ID number(10) not null,
            EV_AUD_Event_Audience number(10) not null,
            constraint fkEV_AUD_Event_Audience_Posit foreign key (
                EV_AUD_EV_ID
            ) references EV_Event(EV_ID),
            constraint pkEV_AUD_Event_Audience_Posit primary key (
                EV_AUD_ID
            ),
            constraint uqEV_AUD_Event_Audience_Posit unique (
                EV_AUD_EV_ID,
                EV_AUD_Event_Audience
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_AUD_Event_Audience_Annex (
            EV_AUD_ID number(10) not null,
            EV_AUD_PositedAt timestamp not null,
            EV_AUD_Reliability number(5,2) not null,
            Metadata_EV_AUD number(10) not null,
            constraint fkEV_AUD_Event_Audience_Annex foreign key (
                EV_AUD_ID
            ) references EV_AUD_Event_Audience_Posit(EV_AUD_ID),
            constraint pkEV_AUD_Event_Audience_Annex primary key (
                EV_AUD_ID,
                EV_AUD_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE EV_REV_Event_Revenue_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_REV_Event_Revenue_Posit (
            EV_REV_ID number(10) default EV_REV_Event_Revenue_Posit_ID_SEQ.nextval not null, 
            EV_REV_EV_ID number(10) not null,
            EV_REV_Event_Revenue number(19,4) not null,
            constraint fkEV_REV_Event_Revenue_Posit foreign key (
                EV_REV_EV_ID
            ) references EV_Event(EV_ID),
            constraint pkEV_REV_Event_Revenue_Posit primary key (
                EV_REV_ID
            ),
            constraint uqEV_REV_Event_Revenue_Posit unique (
                EV_REV_EV_ID,
                EV_REV_Event_Revenue
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_REV_Event_Revenue_Annex (
            EV_REV_ID number(10) not null,
            EV_REV_PositedAt timestamp not null,
            EV_REV_Reliability number(5,2) not null,
            Metadata_EV_REV number(10) not null,
            constraint fkEV_REV_Event_Revenue_Annex foreign key (
                EV_REV_ID
            ) references EV_REV_Event_Revenue_Posit(EV_REV_ID),
            constraint pkEV_REV_Event_Revenue_Annex primary key (
                EV_REV_ID,
                EV_REV_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ST_NAM_Stage_Name_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_NAM_Stage_Name_Posit (
            ST_NAM_ID number(10) default ST_NAM_Stage_Name_Posit_ID_SEQ.nextval not null, 
            ST_NAM_ST_ID number(10) not null,
            ST_NAM_Stage_Name nvarchar2(42) not null,
            ST_NAM_ChangedAt timestamp not null,
            constraint fkST_NAM_Stage_Name_Posit foreign key (
                ST_NAM_ST_ID
            ) references ST_Stage(ST_ID),
            constraint pkST_NAM_Stage_Name_Posit primary key (
                ST_NAM_ID
            ),
            constraint uqST_NAM_Stage_Name_Posit unique (
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_NAM_Stage_Name_Annex (
            ST_NAM_ID number(10) not null,
            ST_NAM_PositedAt timestamp not null,
            ST_NAM_Reliability number(5,2) not null,
            Metadata_ST_NAM number(10) not null,
            constraint fkST_NAM_Stage_Name_Annex foreign key (
                ST_NAM_ID
            ) references ST_NAM_Stage_Name_Posit(ST_NAM_ID),
            constraint pkST_NAM_Stage_Name_Annex primary key (
                ST_NAM_ID,
                ST_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ST_LOC_Stage_Location_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_LOC_Stage_Location_Posit (
            ST_LOC_ID number(10) default ST_LOC_Stage_Location_Posit_ID_SEQ.nextval not null, 
            ST_LOC_ST_ID number(10) not null,
            ST_LOC_Stage_Location nclob not null,
            constraint fkST_LOC_Stage_Location_Posit foreign key (
                ST_LOC_ST_ID
            ) references ST_Stage(ST_ID),
            constraint pkST_LOC_Stage_Location_Posit primary key (
                ST_LOC_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_LOC_Stage_Location_Annex (
            ST_LOC_ID number(10) not null,
            ST_LOC_PositedAt timestamp not null,
            ST_LOC_Reliability number(5,2) not null,
            Metadata_ST_LOC number(10) not null,
            constraint fkST_LOC_Stage_Location_Annex foreign key (
                ST_LOC_ID
            ) references ST_LOC_Stage_Location_Posit(ST_LOC_ID),
            constraint pkST_LOC_Stage_Location_Annex primary key (
                ST_LOC_ID,
                ST_LOC_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ST_AVG_Stage_Average_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_AVG_Stage_Average_Posit (
            ST_AVG_ID number(10) default ST_AVG_Stage_Average_Posit_ID_SEQ.nextval not null, 
            ST_AVG_ST_ID number(10) not null,
            ST_AVG_UTL_ID number(5) not null,
            ST_AVG_ChangedAt timestamp not null,
            constraint fk_A_ST_AVG_Stage_Average_Posit foreign key (
                ST_AVG_ST_ID
            ) references ST_Stage(ST_ID),
            constraint fk_K_ST_AVG_Stage_Average_Posit foreign key (
                ST_AVG_UTL_ID
            ) references UTL_Utilization(UTL_ID),
            constraint pkST_AVG_Stage_Average_Posit primary key (
                ST_AVG_ID
            ),
            constraint uqST_AVG_Stage_Average_Posit unique (
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_AVG_Stage_Average_Annex (
            ST_AVG_ID number(10) not null,
            ST_AVG_PositedAt timestamp not null,
            ST_AVG_Reliability number(5,2) not null,
            Metadata_ST_AVG number(10) not null,
            constraint fkST_AVG_Stage_Average_Annex foreign key (
                ST_AVG_ID
            ) references ST_AVG_Stage_Average_Posit(ST_AVG_ID),
            constraint pkST_AVG_Stage_Average_Annex primary key (
                ST_AVG_ID,
                ST_AVG_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ST_MIN_Stage_Minimum_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_MIN_Stage_Minimum_Posit (
            ST_MIN_ID number(10) default ST_MIN_Stage_Minimum_Posit_ID_SEQ.nextval not null, 
            ST_MIN_ST_ID number(10) not null,
            ST_MIN_UTL_ID number(5) not null,
            constraint fk_A_ST_MIN_Stage_Minimum_Posit foreign key (
                ST_MIN_ST_ID
            ) references ST_Stage(ST_ID),
            constraint fk_K_ST_MIN_Stage_Minimum_Posit foreign key (
                ST_MIN_UTL_ID
            ) references UTL_Utilization(UTL_ID),
            constraint pkST_MIN_Stage_Minimum_Posit primary key (
                ST_MIN_ID
            ),
            constraint uqST_MIN_Stage_Minimum_Posit unique (
                ST_MIN_ST_ID,
                ST_MIN_UTL_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_MIN_Stage_Minimum_Annex (
            ST_MIN_ID number(10) not null,
            ST_MIN_PositedAt timestamp not null,
            ST_MIN_Reliability number(5,2) not null,
            Metadata_ST_MIN number(10) not null,
            constraint fkST_MIN_Stage_Minimum_Annex foreign key (
                ST_MIN_ID
            ) references ST_MIN_Stage_Minimum_Posit(ST_MIN_ID),
            constraint pkST_MIN_Stage_Minimum_Annex primary key (
                ST_MIN_ID,
                ST_MIN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_NAM_Actor_Name_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_NAM_Actor_Name_Posit (
            AC_NAM_ID number(10) default AC_NAM_Actor_Name_Posit_ID_SEQ.nextval not null, 
            AC_NAM_AC_ID number(10) not null,
            AC_NAM_Actor_Name nvarchar2(42) not null,
            AC_NAM_ChangedAt timestamp not null,
            constraint fkAC_NAM_Actor_Name_Posit foreign key (
                AC_NAM_AC_ID
            ) references AC_Actor(AC_ID),
            constraint pkAC_NAM_Actor_Name_Posit primary key (
                AC_NAM_ID
            ),
            constraint uqAC_NAM_Actor_Name_Posit unique (
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_NAM_Actor_Name_Annex (
            AC_NAM_ID number(10) not null,
            AC_NAM_PositedAt timestamp not null,
            AC_NAM_Reliability number(5,2) not null,
            Metadata_AC_NAM number(10) not null,
            constraint fkAC_NAM_Actor_Name_Annex foreign key (
                AC_NAM_ID
            ) references AC_NAM_Actor_Name_Posit(AC_NAM_ID),
            constraint pkAC_NAM_Actor_Name_Annex primary key (
                AC_NAM_ID,
                AC_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_GEN_Actor_Gender_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_GEN_Actor_Gender_Posit (
            AC_GEN_ID number(10) default AC_GEN_Actor_Gender_Posit_ID_SEQ.nextval not null, 
            AC_GEN_AC_ID number(10) not null,
            AC_GEN_GEN_ID number(5) not null,
            constraint fk_A_AC_GEN_Actor_Gender_Posit foreign key (
                AC_GEN_AC_ID
            ) references AC_Actor(AC_ID),
            constraint fk_K_AC_GEN_Actor_Gender_Posit foreign key (
                AC_GEN_GEN_ID
            ) references GEN_Gender(GEN_ID),
            constraint pkAC_GEN_Actor_Gender_Posit primary key (
                AC_GEN_ID
            ),
            constraint uqAC_GEN_Actor_Gender_Posit unique (
                AC_GEN_AC_ID,
                AC_GEN_GEN_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_GEN_Actor_Gender_Annex (
            AC_GEN_ID number(10) not null,
            AC_GEN_PositedAt timestamp not null,
            AC_GEN_Reliability number(5,2) not null,
            Metadata_AC_GEN number(10) not null,
            constraint fkAC_GEN_Actor_Gender_Annex foreign key (
                AC_GEN_ID
            ) references AC_GEN_Actor_Gender_Posit(AC_GEN_ID),
            constraint pkAC_GEN_Actor_Gender_Annex primary key (
                AC_GEN_ID,
                AC_GEN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_PLV_Actor_ProfessionalLevel_Posit (
            AC_PLV_ID number(10) default AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ.nextval not null, 
            AC_PLV_AC_ID number(10) not null,
            AC_PLV_PLV_ID number(5) not null,
            AC_PLV_ChangedAt timestamp not null,
            constraint fk_A_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
                AC_PLV_AC_ID
            ) references AC_Actor(AC_ID),
            constraint fk_K_AC_PLV_Actor_ProfessionalLevel_Posit foreign key (
                AC_PLV_PLV_ID
            ) references PLV_ProfessionalLevel(PLV_ID),
            constraint pkAC_PLV_Actor_ProfessionalLevel_Posit primary key (
                AC_PLV_ID
            ),
            constraint uqAC_PLV_Actor_ProfessionalLevel_Posit unique (
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_PLV_Actor_ProfessionalLevel_Annex (
            AC_PLV_ID number(10) not null,
            AC_PLV_PositedAt timestamp not null,
            AC_PLV_Reliability number(5,2) not null,
            Metadata_AC_PLV number(10) not null,
            constraint fkAC_PLV_Actor_ProfessionalLevel_Annex foreign key (
                AC_PLV_ID
            ) references AC_PLV_Actor_ProfessionalLevel_Posit(AC_PLV_ID),
            constraint pkAC_PLV_Actor_ProfessionalLevel_Annex primary key (
                AC_PLV_ID,
                AC_PLV_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE PR_NAM_Program_Name_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_NAM_Program_Name_Posit (
            PR_NAM_ID number(10) default PR_NAM_Program_Name_Posit_ID_SEQ.nextval not null, 
            PR_NAM_PR_ID number(10) not null,
            PR_NAM_Program_Name nvarchar2(42) not null,
            constraint fkPR_NAM_Program_Name_Posit foreign key (
                PR_NAM_PR_ID
            ) references PR_Program(PR_ID),
            constraint pkPR_NAM_Program_Name_Posit primary key (
                PR_NAM_ID
            ),
            constraint uqPR_NAM_Program_Name_Posit unique (
                PR_NAM_PR_ID,
                PR_NAM_Program_Name
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_NAM_Program_Name_Annex (
            PR_NAM_ID number(10) not null,
            PR_NAM_PositedAt timestamp not null,
            PR_NAM_Reliability number(5,2) not null,
            Metadata_PR_NAM number(10) not null,
            constraint fkPR_NAM_Program_Name_Annex foreign key (
                PR_NAM_ID
            ) references PR_NAM_Program_Name_Posit(PR_NAM_ID),
            constraint pkPR_NAM_Program_Name_Annex primary key (
                PR_NAM_ID,
                PR_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE PR_LEN_Program_Length_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_LEN_Program_Length_Posit (
            PR_LEN_ID number(10) default PR_LEN_Program_Length_Posit_ID_SEQ.nextval not null, 
            PR_LEN_PR_ID number(10) not null,
            PR_LEN_Program_Length timestamp not null,
            PR_LEN_ChangedAt date not null,
            constraint fkPR_LEN_Program_Length_Posit foreign key (
                PR_LEN_PR_ID
            ) references PR_Program(PR_ID),
            constraint pkPR_LEN_Program_Length_Posit primary key (
                PR_LEN_ID
            ),
            constraint uqPR_LEN_Program_Length_Posit unique (
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_LEN_Program_Length_Annex (
            PR_LEN_ID number(10) not null,
            PR_LEN_PositedAt timestamp not null,
            PR_LEN_Reliability number(5,2) not null,
            Metadata_PR_LEN number(10) not null,
            constraint fkPR_LEN_Program_Length_Annex foreign key (
                PR_LEN_ID
            ) references PR_LEN_Program_Length_Posit(PR_LEN_ID),
            constraint pkPR_LEN_Program_Length_Annex primary key (
                PR_LEN_ID,
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
CREATE OR REPLACE VIEW EV_DAT_Event_Date AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Reliability
FROM
    EV_DAT_Event_Date_Posit p
JOIN
    EV_DAT_Event_Date_Annex a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
;
CREATE OR REPLACE VIEW EV_AUD_Event_Audience AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Reliability
FROM
    EV_AUD_Event_Audience_Posit p
JOIN
    EV_AUD_Event_Audience_Annex a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
;
CREATE OR REPLACE VIEW EV_REV_Event_Revenue AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue,
    a.EV_REV_PositedAt,
    a.EV_REV_Reliability
FROM
    EV_REV_Event_Revenue_Posit p
JOIN
    EV_REV_Event_Revenue_Annex a
ON
    a.EV_REV_ID = p.EV_REV_ID
;
CREATE OR REPLACE VIEW ST_NAM_Stage_Name AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Reliability
FROM
    ST_NAM_Stage_Name_Posit p
JOIN
    ST_NAM_Stage_Name_Annex a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
;
CREATE OR REPLACE VIEW ST_LOC_Stage_Location AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Stage_Location,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Reliability
FROM
    ST_LOC_Stage_Location_Posit p
JOIN
    ST_LOC_Stage_Location_Annex a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
;
CREATE OR REPLACE VIEW ST_AVG_Stage_Average AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Reliability
FROM
    ST_AVG_Stage_Average_Posit p
JOIN
    ST_AVG_Stage_Average_Annex a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
;
CREATE OR REPLACE VIEW ST_MIN_Stage_Minimum AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Reliability
FROM
    ST_MIN_Stage_Minimum_Posit p
JOIN
    ST_MIN_Stage_Minimum_Annex a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
;
CREATE OR REPLACE VIEW AC_NAM_Actor_Name AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Reliability
FROM
    AC_NAM_Actor_Name_Posit p
JOIN
    AC_NAM_Actor_Name_Annex a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
;
CREATE OR REPLACE VIEW AC_GEN_Actor_Gender AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Reliability
FROM
    AC_GEN_Actor_Gender_Posit p
JOIN
    AC_GEN_Actor_Gender_Annex a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
;
CREATE OR REPLACE VIEW AC_PLV_Actor_ProfessionalLevel AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Reliability
FROM
    AC_PLV_Actor_ProfessionalLevel_Posit p
JOIN
    AC_PLV_Actor_ProfessionalLevel_Annex a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
;
CREATE OR REPLACE VIEW PR_NAM_Program_Name AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Reliability
FROM
    PR_NAM_Program_Name_Posit p
JOIN
    PR_NAM_Program_Name_Annex a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
;
CREATE OR REPLACE VIEW PR_LEN_Program_Length AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Reliability
FROM
    PR_LEN_Program_Length_Posit p
JOIN
    PR_LEN_Program_Length_Annex a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
-- These SQL table macros rewind an attribute posit table to the given point in changing time, or an attribute annex
-- table to the given point in positing time. A rewinder does not pick a temporal perspective and instead shows all rows
-- that have been in effect before that point in time. The forwarder is the opposite of the rewinder, such that the union
-- of the two will produce all rows in a posit table.
--
-- A SQL table macro (SQL_MACRO, Oracle Database 19.7 or later) is a function that returns the text of a query, in which
-- its parameters stand for the values given. It is called in the FROM clause of a query, like a table:
-- SELECT * FROM rAC_NAM_Actor_Name(TIMESTAMP '2020-01-01 00:00:00', TIMESTAMP '2020-01-01 00:00:00').
--
-- The assembled rewinder and forwarder pick, for each posit, the annex row that was last posited at or before the
-- positing time (the macros do not call each other, they do what the others do in their own query). A bi posit has no
-- positor, so the annex rows of a posit compete with each other alone.
--
-- The functions pre<attribute> and fol<attribute> (historized attributes) are scalar functions, not macros. They return
-- the value (or the checksum, if the attribute has one) that is in effect just before and just after a point in
-- changing time, as seen from a point in positing time, among the posits that are reliable (reliability 1). They do the
-- query of the assembled rewinder and forwarder in their own text.
--
-- @changingTimepoint the point in changing time to rewind to
-- @positingTimepoint the point in positing time to rewind to
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_DAT_Event_Date_Annex (
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
            EV_DAT_Reliability
        FROM
            EV_DAT_Event_Date_Annex
        WHERE
            EV_DAT_PositedAt <= positingTimepoint
    ]';
END rEV_DAT_Event_Date_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_DAT_Event_Date (
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
            EV_DAT_Reliability,
            EV_DAT_EV_ID,
            EV_DAT_Event_Date
        FROM (
            SELECT
                a.Metadata_EV_DAT,
                p.EV_DAT_ID,
                a.EV_DAT_PositedAt,
                a.EV_DAT_Reliability,
                p.EV_DAT_EV_ID,
                p.EV_DAT_Event_Date,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_DAT_ID
                    ORDER BY
                        a.EV_DAT_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_DAT_Event_Date_Posit p
            JOIN
                EV_DAT_Event_Date_Annex a
            ON
                a.EV_DAT_ID = p.EV_DAT_ID
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
CREATE OR REPLACE FUNCTION rEV_AUD_Event_Audience_Annex (
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
            EV_AUD_Reliability
        FROM
            EV_AUD_Event_Audience_Annex
        WHERE
            EV_AUD_PositedAt <= positingTimepoint
    ]';
END rEV_AUD_Event_Audience_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_AUD_Event_Audience (
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
            EV_AUD_Reliability,
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience
        FROM (
            SELECT
                a.Metadata_EV_AUD,
                p.EV_AUD_ID,
                a.EV_AUD_PositedAt,
                a.EV_AUD_Reliability,
                p.EV_AUD_EV_ID,
                p.EV_AUD_Event_Audience,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_AUD_ID
                    ORDER BY
                        a.EV_AUD_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_AUD_Event_Audience_Posit p
            JOIN
                EV_AUD_Event_Audience_Annex a
            ON
                a.EV_AUD_ID = p.EV_AUD_ID
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
CREATE OR REPLACE FUNCTION rEV_REV_Event_Revenue_Annex (
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
            EV_REV_Reliability
        FROM
            EV_REV_Event_Revenue_Annex
        WHERE
            EV_REV_PositedAt <= positingTimepoint
    ]';
END rEV_REV_Event_Revenue_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_REV_Event_Revenue (
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
            EV_REV_Reliability,
            EV_REV_EV_ID,
            EV_REV_Event_Revenue
        FROM (
            SELECT
                a.Metadata_EV_REV,
                p.EV_REV_ID,
                a.EV_REV_PositedAt,
                a.EV_REV_Reliability,
                p.EV_REV_EV_ID,
                p.EV_REV_Event_Revenue,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_REV_ID
                    ORDER BY
                        a.EV_REV_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_REV_Event_Revenue_Posit p
            JOIN
                EV_REV_Event_Revenue_Annex a
            ON
                a.EV_REV_ID = p.EV_REV_ID
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
CREATE OR REPLACE FUNCTION rST_NAM_Stage_Name_Posit (
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
            ST_NAM_Stage_Name_Posit
        WHERE
            ST_NAM_ChangedAt <= changingTimepoint
    ]';
END rST_NAM_Stage_Name_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fST_NAM_Stage_Name_Posit (
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
            ST_NAM_Stage_Name_Posit
        WHERE
            ST_NAM_ChangedAt > changingTimepoint
    ]';
END fST_NAM_Stage_Name_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_NAM_Stage_Name_Annex (
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
            ST_NAM_Reliability
        FROM
            ST_NAM_Stage_Name_Annex
        WHERE
            ST_NAM_PositedAt <= positingTimepoint
    ]';
END rST_NAM_Stage_Name_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_NAM_Stage_Name (
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
            ST_NAM_Reliability,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_NAM,
                p.ST_NAM_ID,
                a.ST_NAM_PositedAt,
                a.ST_NAM_Reliability,
                p.ST_NAM_ST_ID,
                p.ST_NAM_Stage_Name,
                p.ST_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_NAM_ID
                    ORDER BY
                        a.ST_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_NAM_Stage_Name_Posit p
            JOIN
                ST_NAM_Stage_Name_Annex a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
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
CREATE OR REPLACE FUNCTION fST_NAM_Stage_Name (
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
            ST_NAM_Reliability,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_NAM,
                p.ST_NAM_ID,
                a.ST_NAM_PositedAt,
                a.ST_NAM_Reliability,
                p.ST_NAM_ST_ID,
                p.ST_NAM_Stage_Name,
                p.ST_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_NAM_ID
                    ORDER BY
                        a.ST_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_NAM_Stage_Name_Posit p
            JOIN
                ST_NAM_Stage_Name_Annex a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
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
CREATE OR REPLACE FUNCTION rST_LOC_Stage_Location_Annex (
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
            ST_LOC_Reliability
        FROM
            ST_LOC_Stage_Location_Annex
        WHERE
            ST_LOC_PositedAt <= positingTimepoint
    ]';
END rST_LOC_Stage_Location_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_LOC_Stage_Location (
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
            ST_LOC_Reliability,
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location
        FROM (
            SELECT
                a.Metadata_ST_LOC,
                p.ST_LOC_ID,
                a.ST_LOC_PositedAt,
                a.ST_LOC_Reliability,
                p.ST_LOC_ST_ID,
                p.ST_LOC_Stage_Location,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_LOC_ID
                    ORDER BY
                        a.ST_LOC_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_LOC_Stage_Location_Posit p
            JOIN
                ST_LOC_Stage_Location_Annex a
            ON
                a.ST_LOC_ID = p.ST_LOC_ID
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
CREATE OR REPLACE FUNCTION rST_AVG_Stage_Average_Posit (
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
            ST_AVG_Stage_Average_Posit
        WHERE
            ST_AVG_ChangedAt <= changingTimepoint
    ]';
END rST_AVG_Stage_Average_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fST_AVG_Stage_Average_Posit (
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
            ST_AVG_Stage_Average_Posit
        WHERE
            ST_AVG_ChangedAt > changingTimepoint
    ]';
END fST_AVG_Stage_Average_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_AVG_Stage_Average_Annex (
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
            ST_AVG_Reliability
        FROM
            ST_AVG_Stage_Average_Annex
        WHERE
            ST_AVG_PositedAt <= positingTimepoint
    ]';
END rST_AVG_Stage_Average_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_AVG_Stage_Average (
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
            ST_AVG_Reliability,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_AVG,
                p.ST_AVG_ID,
                a.ST_AVG_PositedAt,
                a.ST_AVG_Reliability,
                p.ST_AVG_ST_ID,
                p.ST_AVG_UTL_ID,
                p.ST_AVG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_AVG_ID
                    ORDER BY
                        a.ST_AVG_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_AVG_Stage_Average_Posit p
            JOIN
                ST_AVG_Stage_Average_Annex a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
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
CREATE OR REPLACE FUNCTION fST_AVG_Stage_Average (
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
            ST_AVG_Reliability,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_AVG,
                p.ST_AVG_ID,
                a.ST_AVG_PositedAt,
                a.ST_AVG_Reliability,
                p.ST_AVG_ST_ID,
                p.ST_AVG_UTL_ID,
                p.ST_AVG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_AVG_ID
                    ORDER BY
                        a.ST_AVG_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_AVG_Stage_Average_Posit p
            JOIN
                ST_AVG_Stage_Average_Annex a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
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
CREATE OR REPLACE FUNCTION rST_MIN_Stage_Minimum_Annex (
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
            ST_MIN_Reliability
        FROM
            ST_MIN_Stage_Minimum_Annex
        WHERE
            ST_MIN_PositedAt <= positingTimepoint
    ]';
END rST_MIN_Stage_Minimum_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_MIN_Stage_Minimum (
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
            ST_MIN_Reliability,
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        FROM (
            SELECT
                a.Metadata_ST_MIN,
                p.ST_MIN_ID,
                a.ST_MIN_PositedAt,
                a.ST_MIN_Reliability,
                p.ST_MIN_ST_ID,
                p.ST_MIN_UTL_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_MIN_ID
                    ORDER BY
                        a.ST_MIN_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_MIN_Stage_Minimum_Posit p
            JOIN
                ST_MIN_Stage_Minimum_Annex a
            ON
                a.ST_MIN_ID = p.ST_MIN_ID
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
CREATE OR REPLACE FUNCTION rAC_NAM_Actor_Name_Posit (
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
            AC_NAM_Actor_Name_Posit
        WHERE
            AC_NAM_ChangedAt <= changingTimepoint
    ]';
END rAC_NAM_Actor_Name_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fAC_NAM_Actor_Name_Posit (
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
            AC_NAM_Actor_Name_Posit
        WHERE
            AC_NAM_ChangedAt > changingTimepoint
    ]';
END fAC_NAM_Actor_Name_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_NAM_Actor_Name_Annex (
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
            AC_NAM_Reliability
        FROM
            AC_NAM_Actor_Name_Annex
        WHERE
            AC_NAM_PositedAt <= positingTimepoint
    ]';
END rAC_NAM_Actor_Name_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_NAM_Actor_Name (
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
            AC_NAM_Reliability,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_NAM,
                p.AC_NAM_ID,
                a.AC_NAM_PositedAt,
                a.AC_NAM_Reliability,
                p.AC_NAM_AC_ID,
                p.AC_NAM_Actor_Name,
                p.AC_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_NAM_ID
                    ORDER BY
                        a.AC_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_NAM_Actor_Name_Posit p
            JOIN
                AC_NAM_Actor_Name_Annex a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
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
CREATE OR REPLACE FUNCTION fAC_NAM_Actor_Name (
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
            AC_NAM_Reliability,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_NAM,
                p.AC_NAM_ID,
                a.AC_NAM_PositedAt,
                a.AC_NAM_Reliability,
                p.AC_NAM_AC_ID,
                p.AC_NAM_Actor_Name,
                p.AC_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_NAM_ID
                    ORDER BY
                        a.AC_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_NAM_Actor_Name_Posit p
            JOIN
                AC_NAM_Actor_Name_Annex a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
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
CREATE OR REPLACE FUNCTION rAC_GEN_Actor_Gender_Annex (
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
            AC_GEN_Reliability
        FROM
            AC_GEN_Actor_Gender_Annex
        WHERE
            AC_GEN_PositedAt <= positingTimepoint
    ]';
END rAC_GEN_Actor_Gender_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_GEN_Actor_Gender (
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
            AC_GEN_Reliability,
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        FROM (
            SELECT
                a.Metadata_AC_GEN,
                p.AC_GEN_ID,
                a.AC_GEN_PositedAt,
                a.AC_GEN_Reliability,
                p.AC_GEN_AC_ID,
                p.AC_GEN_GEN_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_GEN_ID
                    ORDER BY
                        a.AC_GEN_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_GEN_Actor_Gender_Posit p
            JOIN
                AC_GEN_Actor_Gender_Annex a
            ON
                a.AC_GEN_ID = p.AC_GEN_ID
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
CREATE OR REPLACE FUNCTION rAC_PLV_Actor_ProfessionalLevel_Posit (
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
            AC_PLV_Actor_ProfessionalLevel_Posit
        WHERE
            AC_PLV_ChangedAt <= changingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fAC_PLV_Actor_ProfessionalLevel_Posit (
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
            AC_PLV_Actor_ProfessionalLevel_Posit
        WHERE
            AC_PLV_ChangedAt > changingTimepoint
    ]';
END fAC_PLV_Actor_ProfessionalLevel_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_PLV_Actor_ProfessionalLevel_Annex (
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
            AC_PLV_Reliability
        FROM
            AC_PLV_Actor_ProfessionalLevel_Annex
        WHERE
            AC_PLV_PositedAt <= positingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_PLV_Actor_ProfessionalLevel (
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
            AC_PLV_Reliability,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_PLV,
                p.AC_PLV_ID,
                a.AC_PLV_PositedAt,
                a.AC_PLV_Reliability,
                p.AC_PLV_AC_ID,
                p.AC_PLV_PLV_ID,
                p.AC_PLV_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_PLV_ID
                    ORDER BY
                        a.AC_PLV_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_PLV_Actor_ProfessionalLevel_Posit p
            JOIN
                AC_PLV_Actor_ProfessionalLevel_Annex a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
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
CREATE OR REPLACE FUNCTION fAC_PLV_Actor_ProfessionalLevel (
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
            AC_PLV_Reliability,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_PLV,
                p.AC_PLV_ID,
                a.AC_PLV_PositedAt,
                a.AC_PLV_Reliability,
                p.AC_PLV_AC_ID,
                p.AC_PLV_PLV_ID,
                p.AC_PLV_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_PLV_ID
                    ORDER BY
                        a.AC_PLV_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_PLV_Actor_ProfessionalLevel_Posit p
            JOIN
                AC_PLV_Actor_ProfessionalLevel_Annex a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
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
CREATE OR REPLACE FUNCTION rPR_NAM_Program_Name_Annex (
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
            PR_NAM_Reliability
        FROM
            PR_NAM_Program_Name_Annex
        WHERE
            PR_NAM_PositedAt <= positingTimepoint
    ]';
END rPR_NAM_Program_Name_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_NAM_Program_Name (
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
            PR_NAM_Reliability,
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        FROM (
            SELECT
                a.Metadata_PR_NAM,
                p.PR_NAM_ID,
                a.PR_NAM_PositedAt,
                a.PR_NAM_Reliability,
                p.PR_NAM_PR_ID,
                p.PR_NAM_Program_Name,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_NAM_ID
                    ORDER BY
                        a.PR_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                PR_NAM_Program_Name_Posit p
            JOIN
                PR_NAM_Program_Name_Annex a
            ON
                a.PR_NAM_ID = p.PR_NAM_ID
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
CREATE OR REPLACE FUNCTION rPR_LEN_Program_Length_Posit (
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
            PR_LEN_Program_Length_Posit
        WHERE
            PR_LEN_ChangedAt <= changingTimepoint
    ]';
END rPR_LEN_Program_Length_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fPR_LEN_Program_Length_Posit (
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
            PR_LEN_Program_Length_Posit
        WHERE
            PR_LEN_ChangedAt > changingTimepoint
    ]';
END fPR_LEN_Program_Length_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_LEN_Program_Length_Annex (
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
            PR_LEN_Reliability
        FROM
            PR_LEN_Program_Length_Annex
        WHERE
            PR_LEN_PositedAt <= positingTimepoint
    ]';
END rPR_LEN_Program_Length_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_LEN_Program_Length (
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
            PR_LEN_Reliability,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM (
            SELECT
                a.Metadata_PR_LEN,
                p.PR_LEN_ID,
                a.PR_LEN_PositedAt,
                a.PR_LEN_Reliability,
                p.PR_LEN_PR_ID,
                p.PR_LEN_Program_Length,
                p.PR_LEN_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_LEN_ID
                    ORDER BY
                        a.PR_LEN_PositedAt DESC
                ) AS rowNumber
            FROM
                PR_LEN_Program_Length_Posit p
            JOIN
                PR_LEN_Program_Length_Annex a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
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
CREATE OR REPLACE FUNCTION fPR_LEN_Program_Length (
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
            PR_LEN_Reliability,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM (
            SELECT
                a.Metadata_PR_LEN,
                p.PR_LEN_ID,
                a.PR_LEN_PositedAt,
                a.PR_LEN_Reliability,
                p.PR_LEN_PR_ID,
                p.PR_LEN_Program_Length,
                p.PR_LEN_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_LEN_ID
                    ORDER BY
                        a.PR_LEN_PositedAt DESC
                ) AS rowNumber
            FROM
                PR_LEN_Program_Length_Posit p
            JOIN
                PR_LEN_Program_Length_Annex a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
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
-- BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM tAC_Actor(TIMESTAMP '9999-12-31 00:00:00', TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex with the latest positing time up to the positing timepoint picked for each posit.
-- A posit is shown when that annex says that it is asserted (a reliability of 1), and for each anchor the latest asserted
-- posit at the latest changing time is the one that is shown.
--
-- The latest and now perspectives are views over the point-in-time macro, which is the time traveling perspective with the
-- positing time set to End of Time, and as the macros are not nested the point-in-time macro works out the posits itself.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest asserted posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tST_Stage (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            "NAM".ST_NAM_Reliability,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Reliability,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Reliability,
            "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Reliability,
            "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            ST_Stage "ST"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_NAM_ST_ID
                        ORDER BY
                            r.ST_NAM_ChangedAt DESC,
                            r.ST_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_NAM,
                        po.ST_NAM_ID,
                        an.ST_NAM_PositedAt,
                        an.ST_NAM_Reliability,
                        po.ST_NAM_ST_ID,
                        po.ST_NAM_Stage_Name,
                        po.ST_NAM_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_NAM_ID
                            ORDER BY an.ST_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_NAM_Stage_Name_Posit po
                    JOIN
                        ST_NAM_Stage_Name_Annex an
                    ON
                        an.ST_NAM_ID = po.ST_NAM_ID
                    WHERE
                        po.ST_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_LOC_ST_ID
                        ORDER BY
                            r.ST_LOC_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_LOC,
                        po.ST_LOC_ID,
                        an.ST_LOC_PositedAt,
                        an.ST_LOC_Reliability,
                        po.ST_LOC_ST_ID,
                        po.ST_LOC_Stage_Location,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_LOC_ID
                            ORDER BY an.ST_LOC_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_LOC_Stage_Location_Posit po
                    JOIN
                        ST_LOC_Stage_Location_Annex an
                    ON
                        an.ST_LOC_ID = po.ST_LOC_ID
                    WHERE
                        an.ST_LOC_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_LOC_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_AVG_ST_ID
                        ORDER BY
                            r.ST_AVG_ChangedAt DESC,
                            r.ST_AVG_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_AVG,
                        po.ST_AVG_ID,
                        an.ST_AVG_PositedAt,
                        an.ST_AVG_Reliability,
                        po.ST_AVG_ST_ID,
                        po.ST_AVG_UTL_ID,
                        po.ST_AVG_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_AVG_ID
                            ORDER BY an.ST_AVG_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_AVG_Stage_Average_Posit po
                    JOIN
                        ST_AVG_Stage_Average_Annex an
                    ON
                        an.ST_AVG_ID = po.ST_AVG_ID
                    WHERE
                        po.ST_AVG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_AVG_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_AVG_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_MIN_ST_ID
                        ORDER BY
                            r.ST_MIN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_MIN,
                        po.ST_MIN_ID,
                        an.ST_MIN_PositedAt,
                        an.ST_MIN_Reliability,
                        po.ST_MIN_ST_ID,
                        po.ST_MIN_UTL_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_MIN_ID
                            ORDER BY an.ST_MIN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_MIN_Stage_Minimum_Posit po
                    JOIN
                        ST_MIN_Stage_Minimum_Annex an
                    ON
                        an.ST_MIN_ID = po.ST_MIN_ID
                    WHERE
                        an.ST_MIN_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_MIN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END tST_Stage;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What is known now (positing time End of Time) about the changing time, with a reliability that is null since a
-- perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pST_Stage (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Reliability,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Reliability,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Reliability,
            "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Reliability,
            "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            ST_Stage "ST"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_NAM_ST_ID
                        ORDER BY
                            r.ST_NAM_ChangedAt DESC,
                            r.ST_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_NAM,
                        po.ST_NAM_ID,
                        an.ST_NAM_PositedAt,
                        an.ST_NAM_Reliability,
                        po.ST_NAM_ST_ID,
                        po.ST_NAM_Stage_Name,
                        po.ST_NAM_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_NAM_ID
                            ORDER BY an.ST_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_NAM_Stage_Name_Posit po
                    JOIN
                        ST_NAM_Stage_Name_Annex an
                    ON
                        an.ST_NAM_ID = po.ST_NAM_ID
                    WHERE
                        po.ST_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_LOC_ST_ID
                        ORDER BY
                            r.ST_LOC_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_LOC,
                        po.ST_LOC_ID,
                        an.ST_LOC_PositedAt,
                        an.ST_LOC_Reliability,
                        po.ST_LOC_ST_ID,
                        po.ST_LOC_Stage_Location,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_LOC_ID
                            ORDER BY an.ST_LOC_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_LOC_Stage_Location_Posit po
                    JOIN
                        ST_LOC_Stage_Location_Annex an
                    ON
                        an.ST_LOC_ID = po.ST_LOC_ID
                    WHERE
                        an.ST_LOC_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_LOC_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_AVG_ST_ID
                        ORDER BY
                            r.ST_AVG_ChangedAt DESC,
                            r.ST_AVG_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_AVG,
                        po.ST_AVG_ID,
                        an.ST_AVG_PositedAt,
                        an.ST_AVG_Reliability,
                        po.ST_AVG_ST_ID,
                        po.ST_AVG_UTL_ID,
                        po.ST_AVG_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_AVG_ID
                            ORDER BY an.ST_AVG_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_AVG_Stage_Average_Posit po
                    JOIN
                        ST_AVG_Stage_Average_Annex an
                    ON
                        an.ST_AVG_ID = po.ST_AVG_ID
                    WHERE
                        po.ST_AVG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_AVG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_AVG_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_MIN_ST_ID
                        ORDER BY
                            r.ST_MIN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_MIN,
                        po.ST_MIN_ID,
                        an.ST_MIN_PositedAt,
                        an.ST_MIN_Reliability,
                        po.ST_MIN_ST_ID,
                        po.ST_MIN_UTL_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_MIN_ID
                            ORDER BY an.ST_MIN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_MIN_Stage_Minimum_Posit po
                    JOIN
                        ST_MIN_Stage_Minimum_Annex an
                    ON
                        an.ST_MIN_ID = po.ST_MIN_ID
                    WHERE
                        an.ST_MIN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_MIN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END pST_Stage;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-- What is known now, at End of Time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lST_Stage
AS
SELECT
    *
FROM
    pST_Stage(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nST_Stage
AS
SELECT
    *
FROM
    pST_Stage(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The attributes whose
-- mnemonics the selection holds are the ones that are looked at (all of them if it is null).
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
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Reliability,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Reliability,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Reliability,
            "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Reliability,
            "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM (
            SELECT DISTINCT
                h.ST_NAM_ST_ID AS ST_ID,
                CAST(h.ST_NAM_ChangedAt AS timestamp) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                ST_NAM_Stage_Name h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.ST_AVG_ST_ID AS ST_ID,
                CAST(h.ST_AVG_ChangedAt AS timestamp) AS inspectedTimepoint,
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
                x.*,
                LEAD(x.ST_NAM_ChangedAt) OVER (
                    PARTITION BY x.ST_NAM_ST_ID
                    ORDER BY x.ST_NAM_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.ST_NAM_ST_ID, r.ST_NAM_ChangedAt
                            ORDER BY r.ST_NAM_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Reliability,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Stage_Name,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ST_NAM_Stage_Name_Posit po
                        JOIN
                            ST_NAM_Stage_Name_Annex an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                        WHERE
                            po.ST_NAM_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.ST_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_NAM_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_LOC_ST_ID
                        ORDER BY r.ST_LOC_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_ST_LOC,
                            po.ST_LOC_ID,
                            an.ST_LOC_PositedAt,
                            an.ST_LOC_Reliability,
                            po.ST_LOC_ST_ID,
                            po.ST_LOC_Stage_Location,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_LOC_ID
                                ORDER BY an.ST_LOC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ST_LOC_Stage_Location_Posit po
                        JOIN
                            ST_LOC_Stage_Location_Annex an
                        ON
                            an.ST_LOC_ID = po.ST_LOC_ID
                        WHERE
                            an.ST_LOC_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_LOC_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.ST_AVG_ChangedAt) OVER (
                    PARTITION BY x.ST_AVG_ST_ID
                    ORDER BY x.ST_AVG_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.ST_AVG_ST_ID, r.ST_AVG_ChangedAt
                            ORDER BY r.ST_AVG_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Reliability,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ST_AVG_Stage_Average_Posit po
                        JOIN
                            ST_AVG_Stage_Average_Annex an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                        WHERE
                            po.ST_AVG_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.ST_AVG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_AVG_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
            UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_MIN_ST_ID
                        ORDER BY r.ST_MIN_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_ST_MIN,
                            po.ST_MIN_ID,
                            an.ST_MIN_PositedAt,
                            an.ST_MIN_Reliability,
                            po.ST_MIN_ST_ID,
                            po.ST_MIN_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_MIN_ID
                                ORDER BY an.ST_MIN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ST_MIN_Stage_Minimum_Posit po
                        JOIN
                            ST_MIN_Stage_Minimum_Annex an
                        ON
                            an.ST_MIN_ID = po.ST_MIN_ID
                        WHERE
                            an.ST_MIN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_MIN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END dST_Stage;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest asserted posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tAC_Actor (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            "NAM".AC_NAM_Reliability,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Reliability,
            "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Reliability,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            AC_Actor "AC"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_NAM_AC_ID
                        ORDER BY
                            r.AC_NAM_ChangedAt DESC,
                            r.AC_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_NAM,
                        po.AC_NAM_ID,
                        an.AC_NAM_PositedAt,
                        an.AC_NAM_Reliability,
                        po.AC_NAM_AC_ID,
                        po.AC_NAM_Actor_Name,
                        po.AC_NAM_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_NAM_ID
                            ORDER BY an.AC_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_NAM_Actor_Name_Posit po
                    JOIN
                        AC_NAM_Actor_Name_Annex an
                    ON
                        an.AC_NAM_ID = po.AC_NAM_ID
                    WHERE
                        po.AC_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_GEN_AC_ID
                        ORDER BY
                            r.AC_GEN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_GEN,
                        po.AC_GEN_ID,
                        an.AC_GEN_PositedAt,
                        an.AC_GEN_Reliability,
                        po.AC_GEN_AC_ID,
                        po.AC_GEN_GEN_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_GEN_ID
                            ORDER BY an.AC_GEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_GEN_Actor_Gender_Posit po
                    JOIN
                        AC_GEN_Actor_Gender_Annex an
                    ON
                        an.AC_GEN_ID = po.AC_GEN_ID
                    WHERE
                        an.AC_GEN_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_GEN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_PLV_AC_ID
                        ORDER BY
                            r.AC_PLV_ChangedAt DESC,
                            r.AC_PLV_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_PLV,
                        po.AC_PLV_ID,
                        an.AC_PLV_PositedAt,
                        an.AC_PLV_Reliability,
                        po.AC_PLV_AC_ID,
                        po.AC_PLV_PLV_ID,
                        po.AC_PLV_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_PLV_ID
                            ORDER BY an.AC_PLV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_PLV_Actor_ProfessionalLevel_Posit po
                    JOIN
                        AC_PLV_Actor_ProfessionalLevel_Annex an
                    ON
                        an.AC_PLV_ID = po.AC_PLV_ID
                    WHERE
                        po.AC_PLV_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_PLV_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_PLV_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        LEFT JOIN
            PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END tAC_Actor;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What is known now (positing time End of Time) about the changing time, with a reliability that is null since a
-- perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_Actor (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Reliability,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Reliability,
            "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Reliability,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            AC_Actor "AC"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_NAM_AC_ID
                        ORDER BY
                            r.AC_NAM_ChangedAt DESC,
                            r.AC_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_NAM,
                        po.AC_NAM_ID,
                        an.AC_NAM_PositedAt,
                        an.AC_NAM_Reliability,
                        po.AC_NAM_AC_ID,
                        po.AC_NAM_Actor_Name,
                        po.AC_NAM_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_NAM_ID
                            ORDER BY an.AC_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_NAM_Actor_Name_Posit po
                    JOIN
                        AC_NAM_Actor_Name_Annex an
                    ON
                        an.AC_NAM_ID = po.AC_NAM_ID
                    WHERE
                        po.AC_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_GEN_AC_ID
                        ORDER BY
                            r.AC_GEN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_GEN,
                        po.AC_GEN_ID,
                        an.AC_GEN_PositedAt,
                        an.AC_GEN_Reliability,
                        po.AC_GEN_AC_ID,
                        po.AC_GEN_GEN_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_GEN_ID
                            ORDER BY an.AC_GEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_GEN_Actor_Gender_Posit po
                    JOIN
                        AC_GEN_Actor_Gender_Annex an
                    ON
                        an.AC_GEN_ID = po.AC_GEN_ID
                    WHERE
                        an.AC_GEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_GEN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_PLV_AC_ID
                        ORDER BY
                            r.AC_PLV_ChangedAt DESC,
                            r.AC_PLV_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_PLV,
                        po.AC_PLV_ID,
                        an.AC_PLV_PositedAt,
                        an.AC_PLV_Reliability,
                        po.AC_PLV_AC_ID,
                        po.AC_PLV_PLV_ID,
                        po.AC_PLV_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_PLV_ID
                            ORDER BY an.AC_PLV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_PLV_Actor_ProfessionalLevel_Posit po
                    JOIN
                        AC_PLV_Actor_ProfessionalLevel_Annex an
                    ON
                        an.AC_PLV_ID = po.AC_PLV_ID
                    WHERE
                        po.AC_PLV_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_PLV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_PLV_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        LEFT JOIN
            PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END pAC_Actor;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-- What is known now, at End of Time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_Actor
AS
SELECT
    *
FROM
    pAC_Actor(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_Actor
AS
SELECT
    *
FROM
    pAC_Actor(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The attributes whose
-- mnemonics the selection holds are the ones that are looked at (all of them if it is null).
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
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Reliability,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Reliability,
            "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Reliability,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM (
            SELECT DISTINCT
                h.AC_NAM_AC_ID AS AC_ID,
                CAST(h.AC_NAM_ChangedAt AS timestamp) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                AC_NAM_Actor_Name h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.AC_PLV_AC_ID AS AC_ID,
                CAST(h.AC_PLV_ChangedAt AS timestamp) AS inspectedTimepoint,
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
                x.*,
                LEAD(x.AC_NAM_ChangedAt) OVER (
                    PARTITION BY x.AC_NAM_AC_ID
                    ORDER BY x.AC_NAM_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.AC_NAM_AC_ID, r.AC_NAM_ChangedAt
                            ORDER BY r.AC_NAM_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Reliability,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Actor_Name,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            AC_NAM_Actor_Name_Posit po
                        JOIN
                            AC_NAM_Actor_Name_Annex an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                        WHERE
                            po.AC_NAM_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.AC_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_NAM_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_GEN_AC_ID
                        ORDER BY r.AC_GEN_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_AC_GEN,
                            po.AC_GEN_ID,
                            an.AC_GEN_PositedAt,
                            an.AC_GEN_Reliability,
                            po.AC_GEN_AC_ID,
                            po.AC_GEN_GEN_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_GEN_ID
                                ORDER BY an.AC_GEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            AC_GEN_Actor_Gender_Posit po
                        JOIN
                            AC_GEN_Actor_Gender_Annex an
                        ON
                            an.AC_GEN_ID = po.AC_GEN_ID
                        WHERE
                            an.AC_GEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_GEN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.AC_PLV_ChangedAt) OVER (
                    PARTITION BY x.AC_PLV_AC_ID
                    ORDER BY x.AC_PLV_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.AC_PLV_AC_ID, r.AC_PLV_ChangedAt
                            ORDER BY r.AC_PLV_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Reliability,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            AC_PLV_Actor_ProfessionalLevel_Posit po
                        JOIN
                            AC_PLV_Actor_ProfessionalLevel_Annex an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                        WHERE
                            po.AC_PLV_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.AC_PLV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_PLV_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
            PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END dAC_Actor;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest asserted posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tPR_Program (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            "NAM".PR_NAM_Reliability,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Reliability,
            "LEN".PR_LEN_Program_Length
        FROM
            PR_Program "PR"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_NAM_PR_ID
                        ORDER BY
                            r.PR_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_NAM,
                        po.PR_NAM_ID,
                        an.PR_NAM_PositedAt,
                        an.PR_NAM_Reliability,
                        po.PR_NAM_PR_ID,
                        po.PR_NAM_Program_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_NAM_ID
                            ORDER BY an.PR_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        PR_NAM_Program_Name_Posit po
                    JOIN
                        PR_NAM_Program_Name_Annex an
                    ON
                        an.PR_NAM_ID = po.PR_NAM_ID
                    WHERE
                        an.PR_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_LEN_PR_ID
                        ORDER BY
                            r.PR_LEN_ChangedAt DESC,
                            r.PR_LEN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_LEN,
                        po.PR_LEN_ID,
                        an.PR_LEN_PositedAt,
                        an.PR_LEN_Reliability,
                        po.PR_LEN_PR_ID,
                        po.PR_LEN_Program_Length,
                        po.PR_LEN_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_LEN_ID
                            ORDER BY an.PR_LEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        PR_LEN_Program_Length_Posit po
                    JOIN
                        PR_LEN_Program_Length_Annex an
                    ON
                        an.PR_LEN_ID = po.PR_LEN_ID
                    WHERE
                        po.PR_LEN_ChangedAt <= CAST(changingTimepoint AS date)
                    AND
                        an.PR_LEN_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_LEN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
    ]';
END tPR_Program;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What is known now (positing time End of Time) about the changing time, with a reliability that is null since a
-- perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pPR_Program (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Reliability,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Reliability,
            "LEN".PR_LEN_Program_Length
        FROM
            PR_Program "PR"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_NAM_PR_ID
                        ORDER BY
                            r.PR_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_NAM,
                        po.PR_NAM_ID,
                        an.PR_NAM_PositedAt,
                        an.PR_NAM_Reliability,
                        po.PR_NAM_PR_ID,
                        po.PR_NAM_Program_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_NAM_ID
                            ORDER BY an.PR_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        PR_NAM_Program_Name_Posit po
                    JOIN
                        PR_NAM_Program_Name_Annex an
                    ON
                        an.PR_NAM_ID = po.PR_NAM_ID
                    WHERE
                        an.PR_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_LEN_PR_ID
                        ORDER BY
                            r.PR_LEN_ChangedAt DESC,
                            r.PR_LEN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_LEN,
                        po.PR_LEN_ID,
                        an.PR_LEN_PositedAt,
                        an.PR_LEN_Reliability,
                        po.PR_LEN_PR_ID,
                        po.PR_LEN_Program_Length,
                        po.PR_LEN_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_LEN_ID
                            ORDER BY an.PR_LEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        PR_LEN_Program_Length_Posit po
                    JOIN
                        PR_LEN_Program_Length_Annex an
                    ON
                        an.PR_LEN_ID = po.PR_LEN_ID
                    WHERE
                        po.PR_LEN_ChangedAt <= CAST(changingTimepoint AS date)
                    AND
                        an.PR_LEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_LEN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
    ]';
END pPR_Program;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-- What is known now, at End of Time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lPR_Program
AS
SELECT
    *
FROM
    pPR_Program(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nPR_Program
AS
SELECT
    *
FROM
    pPR_Program(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The attributes whose
-- mnemonics the selection holds are the ones that are looked at (all of them if it is null).
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
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Reliability,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Reliability,
            "LEN".PR_LEN_Program_Length
        FROM (
            SELECT DISTINCT
                h.PR_LEN_PR_ID AS PR_ID,
                CAST(h.PR_LEN_ChangedAt AS timestamp) AS inspectedTimepoint,
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
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_NAM_PR_ID
                        ORDER BY r.PR_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_PR_NAM,
                            po.PR_NAM_ID,
                            an.PR_NAM_PositedAt,
                            an.PR_NAM_Reliability,
                            po.PR_NAM_PR_ID,
                            po.PR_NAM_Program_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_NAM_ID
                                ORDER BY an.PR_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            PR_NAM_Program_Name_Posit po
                        JOIN
                            PR_NAM_Program_Name_Annex an
                        ON
                            an.PR_NAM_ID = po.PR_NAM_ID
                        WHERE
                            an.PR_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.PR_LEN_ChangedAt) OVER (
                    PARTITION BY x.PR_LEN_PR_ID
                    ORDER BY x.PR_LEN_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.PR_LEN_PR_ID, r.PR_LEN_ChangedAt
                            ORDER BY r.PR_LEN_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Reliability,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Program_Length,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            PR_LEN_Program_Length_Posit po
                        JOIN
                            PR_LEN_Program_Length_Annex an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                        WHERE
                            po.PR_LEN_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS date)
                        AND
                            an.PR_LEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.PR_LEN_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
-- BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pEV_Event(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex row with the latest positing time picked for each posit, the posits that are not
-- reliable left out, and the latest of the posits that are left picked for each nexus.
--
-- The latest and now perspectives are views over the point-in-time macro.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tEV_Event (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            "kETY_of".ETY_EventType AS of_ETY_EventType,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Reliability,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Reliability,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Reliability,
            "REV".EV_REV_Event_Revenue
        FROM
            EV_Event "EV"
        LEFT JOIN
            ETY_EventType "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_DAT_EV_ID
                        ORDER BY
                            r.EV_DAT_PositedAt DESC,
                            r.EV_DAT_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_DAT,
                        po.EV_DAT_ID,
                        an.EV_DAT_PositedAt,
                        an.EV_DAT_Reliability,
                        po.EV_DAT_EV_ID,
                        po.EV_DAT_Event_Date,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_DAT_ID
                            ORDER BY an.EV_DAT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_DAT_Event_Date_Posit po
                    JOIN
                        EV_DAT_Event_Date_Annex an
                    ON
                        an.EV_DAT_ID = po.EV_DAT_ID
                    WHERE
                        an.EV_DAT_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_DAT_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_AUD_EV_ID
                        ORDER BY
                            r.EV_AUD_PositedAt DESC,
                            r.EV_AUD_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_AUD,
                        po.EV_AUD_ID,
                        an.EV_AUD_PositedAt,
                        an.EV_AUD_Reliability,
                        po.EV_AUD_EV_ID,
                        po.EV_AUD_Event_Audience,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_AUD_ID
                            ORDER BY an.EV_AUD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_AUD_Event_Audience_Posit po
                    JOIN
                        EV_AUD_Event_Audience_Annex an
                    ON
                        an.EV_AUD_ID = po.EV_AUD_ID
                    WHERE
                        an.EV_AUD_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_AUD_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_REV_EV_ID
                        ORDER BY
                            r.EV_REV_PositedAt DESC,
                            r.EV_REV_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_REV,
                        po.EV_REV_ID,
                        an.EV_REV_PositedAt,
                        an.EV_REV_Reliability,
                        po.EV_REV_EV_ID,
                        po.EV_REV_Event_Revenue,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_REV_ID
                            ORDER BY an.EV_REV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_REV_Event_Revenue_Posit po
                    JOIN
                        EV_REV_Event_Revenue_Annex an
                    ON
                        an.EV_REV_ID = po.EV_REV_ID
                    WHERE
                        an.EV_REV_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_REV_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
    ]';
END tEV_Event;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time,
-- with a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pEV_Event (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "kETY_of".ETY_EventType AS of_ETY_EventType,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Reliability,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Reliability,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Reliability,
            "REV".EV_REV_Event_Revenue
        FROM
            EV_Event "EV"
        LEFT JOIN
            ETY_EventType "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_DAT_EV_ID
                        ORDER BY
                            r.EV_DAT_PositedAt DESC,
                            r.EV_DAT_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_DAT,
                        po.EV_DAT_ID,
                        an.EV_DAT_PositedAt,
                        an.EV_DAT_Reliability,
                        po.EV_DAT_EV_ID,
                        po.EV_DAT_Event_Date,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_DAT_ID
                            ORDER BY an.EV_DAT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_DAT_Event_Date_Posit po
                    JOIN
                        EV_DAT_Event_Date_Annex an
                    ON
                        an.EV_DAT_ID = po.EV_DAT_ID
                    WHERE
                        an.EV_DAT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_DAT_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_AUD_EV_ID
                        ORDER BY
                            r.EV_AUD_PositedAt DESC,
                            r.EV_AUD_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_AUD,
                        po.EV_AUD_ID,
                        an.EV_AUD_PositedAt,
                        an.EV_AUD_Reliability,
                        po.EV_AUD_EV_ID,
                        po.EV_AUD_Event_Audience,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_AUD_ID
                            ORDER BY an.EV_AUD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_AUD_Event_Audience_Posit po
                    JOIN
                        EV_AUD_Event_Audience_Annex an
                    ON
                        an.EV_AUD_ID = po.EV_AUD_ID
                    WHERE
                        an.EV_AUD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_AUD_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_REV_EV_ID
                        ORDER BY
                            r.EV_REV_PositedAt DESC,
                            r.EV_REV_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_REV,
                        po.EV_REV_ID,
                        an.EV_REV_PositedAt,
                        an.EV_REV_Reliability,
                        po.EV_REV_EV_ID,
                        po.EV_REV_Event_Revenue,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_REV_ID
                            ORDER BY an.EV_REV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_REV_Event_Revenue_Posit po
                    JOIN
                        EV_REV_Event_Revenue_Annex an
                    ON
                        an.EV_REV_ID = po.EV_REV_ID
                    WHERE
                        an.EV_REV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_REV_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
    ]';
END pEV_Event;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lEV_Event
AS
SELECT
    *
FROM
    pEV_Event(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nEV_Event
AS
SELECT
    *
FROM
    pEV_Event(CAST(current_timestamp AS timestamp))
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_partner_AC_with_ONG_currently_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_partner_AC_with_ONG_currently_Posit (
            AC_partner_AC_with_ONG_currently_ID number(10) default AC_partner_AC_with_ONG_currently_Posit_ID_SEQ.nextval not null, 
            AC_ID_partner number(10) not null, 
            AC_ID_with number(10) not null, 
            ONG_ID_currently number(5) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_partner foreign key (
                AC_ID_partner
            ) references AC_Actor(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_with foreign key (
                AC_ID_with
            ) references AC_Actor(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_Posit_fkONG_currently foreign key (
                ONG_ID_currently
            ) references ONG_Ongoing(ONG_ID),
            constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_partner unique (
                AC_ID_partner,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_with unique (
                AC_ID_with,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint pkAC_partner_AC_with_ONG_currently_Posit primary key (
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
        CREATE TABLE AC_partner_AC_with_ONG_currently_Annex (
            AC_partner_AC_with_ONG_currently_ID number(10) not null,
            AC_partner_AC_with_ONG_currently_PositedAt timestamp not null,
            AC_partner_AC_with_ONG_currently_Reliability number(5,2) not null,
            Metadata_AC_partner_AC_with_ONG_currently number(10) not null,
            constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
                AC_partner_AC_with_ONG_currently_ID
            ) references AC_partner_AC_with_ONG_currently_Posit(AC_partner_AC_with_ONG_currently_ID),
            constraint pkAC_partner_AC_with_ONG_currently_Annex primary key (
                AC_partner_AC_with_ONG_currently_ID,
                AC_partner_AC_with_ONG_currently_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_subset_PN_of_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_subset_PN_of_Posit (
            AC_subset_PN_of_ID number(10) default AC_subset_PN_of_Posit_ID_SEQ.nextval not null, 
            AC_ID_subset number(10) not null, 
            PN_ID_of number(10) not null, 
            constraint AC_subset_PN_of_Posit_fkAC_subset foreign key (
                AC_ID_subset
            ) references AC_Actor(AC_ID),
            constraint AC_subset_PN_of_Posit_fkPN_of foreign key (
                PN_ID_of
            ) references PN_Person(PN_ID),
            constraint AC_subset_PN_of_Posit_uqAC_subset unique (
                AC_ID_subset
            ),
            constraint AC_subset_PN_of_Posit_uqPN_of unique (
                PN_ID_of
            ),
            constraint pkAC_subset_PN_of_Posit primary key (
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
        CREATE TABLE AC_subset_PN_of_Annex (
            AC_subset_PN_of_ID number(10) not null,
            AC_subset_PN_of_PositedAt timestamp not null,
            AC_subset_PN_of_Reliability number(5,2) not null,
            Metadata_AC_subset_PN_of number(10) not null,
            constraint fkAC_subset_PN_of_Annex foreign key (
                AC_subset_PN_of_ID
            ) references AC_subset_PN_of_Posit(AC_subset_PN_of_ID),
            constraint pkAC_subset_PN_of_Annex primary key (
                AC_subset_PN_of_ID,
                AC_subset_PN_of_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE EV_in_AC_wasCast_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_in_AC_wasCast_Posit (
            EV_in_AC_wasCast_ID number(10) default EV_in_AC_wasCast_Posit_ID_SEQ.nextval not null, 
            EV_ID_in number(10) not null, 
            AC_ID_wasCast number(10) not null, 
            constraint EV_in_AC_wasCast_Posit_fkEV_in foreign key (
                EV_ID_in
            ) references EV_Event(EV_ID),
            constraint EV_in_AC_wasCast_Posit_fkAC_wasCast foreign key (
                AC_ID_wasCast
            ) references AC_Actor(AC_ID),
            constraint pkEV_in_AC_wasCast_Posit primary key (
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
        CREATE TABLE EV_in_AC_wasCast_Annex (
            EV_in_AC_wasCast_ID number(10) not null,
            EV_in_AC_wasCast_PositedAt timestamp not null,
            EV_in_AC_wasCast_Reliability number(5,2) not null,
            Metadata_EV_in_AC_wasCast number(10) not null,
            constraint fkEV_in_AC_wasCast_Annex foreign key (
                EV_in_AC_wasCast_ID
            ) references EV_in_AC_wasCast_Posit(EV_in_AC_wasCast_ID),
            constraint pkEV_in_AC_wasCast_Annex primary key (
                EV_in_AC_wasCast_ID,
                EV_in_AC_wasCast_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_part_PR_in_RAT_got_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_part_PR_in_RAT_got_Posit (
            AC_part_PR_in_RAT_got_ID number(10) default AC_part_PR_in_RAT_got_Posit_ID_SEQ.nextval not null, 
            AC_ID_part number(10) not null, 
            PR_ID_in number(10) not null, 
            RAT_ID_got number(5) not null,
            AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
            constraint AC_part_PR_in_RAT_got_Posit_fkAC_part foreign key (
                AC_ID_part
            ) references AC_Actor(AC_ID),
            constraint AC_part_PR_in_RAT_got_Posit_fkPR_in foreign key (
                PR_ID_in
            ) references PR_Program(PR_ID),
            constraint AC_part_PR_in_RAT_got_Posit_fkRAT_got foreign key (
                RAT_ID_got
            ) references RAT_Rating(RAT_ID),
            constraint pkAC_part_PR_in_RAT_got_Posit primary key (
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
        CREATE TABLE AC_part_PR_in_RAT_got_Annex (
            AC_part_PR_in_RAT_got_ID number(10) not null,
            AC_part_PR_in_RAT_got_PositedAt timestamp not null,
            AC_part_PR_in_RAT_got_Reliability number(5,2) not null,
            Metadata_AC_part_PR_in_RAT_got number(10) not null,
            constraint fkAC_part_PR_in_RAT_got_Annex foreign key (
                AC_part_PR_in_RAT_got_ID
            ) references AC_part_PR_in_RAT_got_Posit(AC_part_PR_in_RAT_got_ID),
            constraint pkAC_part_PR_in_RAT_got_Annex primary key (
                AC_part_PR_in_RAT_got_ID,
                AC_part_PR_in_RAT_got_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ST_at_PR_isPlaying_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_at_PR_isPlaying_Posit (
            ST_at_PR_isPlaying_ID number(10) default ST_at_PR_isPlaying_Posit_ID_SEQ.nextval not null, 
            ST_ID_at number(10) not null, 
            PR_ID_isPlaying number(10) not null, 
            ST_at_PR_isPlaying_ChangedAt timestamp not null,
            constraint ST_at_PR_isPlaying_Posit_fkST_at foreign key (
                ST_ID_at
            ) references ST_Stage(ST_ID),
            constraint ST_at_PR_isPlaying_Posit_fkPR_isPlaying foreign key (
                PR_ID_isPlaying
            ) references PR_Program(PR_ID),
            constraint pkST_at_PR_isPlaying_Posit primary key (
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
        CREATE TABLE ST_at_PR_isPlaying_Annex (
            ST_at_PR_isPlaying_ID number(10) not null,
            ST_at_PR_isPlaying_PositedAt timestamp not null,
            ST_at_PR_isPlaying_Reliability number(5,2) not null,
            Metadata_ST_at_PR_isPlaying number(10) not null,
            constraint fkST_at_PR_isPlaying_Annex foreign key (
                ST_at_PR_isPlaying_ID
            ) references ST_at_PR_isPlaying_Posit(ST_at_PR_isPlaying_ID),
            constraint pkST_at_PR_isPlaying_Annex primary key (
                ST_at_PR_isPlaying_ID,
                ST_at_PR_isPlaying_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_parent_AC_child_PAT_having_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_parent_AC_child_PAT_having_Posit (
            AC_parent_AC_child_PAT_having_ID number(10) default AC_parent_AC_child_PAT_having_Posit_ID_SEQ.nextval not null, 
            AC_ID_parent number(10) not null, 
            AC_ID_child number(10) not null, 
            PAT_ID_having number(5) not null,
            constraint AC_parent_AC_child_PAT_having_Posit_fkAC_parent foreign key (
                AC_ID_parent
            ) references AC_Actor(AC_ID),
            constraint AC_parent_AC_child_PAT_having_Posit_fkAC_child foreign key (
                AC_ID_child
            ) references AC_Actor(AC_ID),
            constraint AC_parent_AC_child_PAT_having_Posit_fkPAT_having foreign key (
                PAT_ID_having
            ) references PAT_ParentalType(PAT_ID),
            constraint pkAC_parent_AC_child_PAT_having_Posit primary key (
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
        CREATE TABLE AC_parent_AC_child_PAT_having_Annex (
            AC_parent_AC_child_PAT_having_ID number(10) not null,
            AC_parent_AC_child_PAT_having_PositedAt timestamp not null,
            AC_parent_AC_child_PAT_having_Reliability number(5,2) not null,
            Metadata_AC_parent_AC_child_PAT_having number(10) not null,
            constraint fkAC_parent_AC_child_PAT_having_Annex foreign key (
                AC_parent_AC_child_PAT_having_ID
            ) references AC_parent_AC_child_PAT_having_Posit(AC_parent_AC_child_PAT_having_ID),
            constraint pkAC_parent_AC_child_PAT_having_Annex primary key (
                AC_parent_AC_child_PAT_having_ID,
                AC_parent_AC_child_PAT_having_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE PR_content_ST_location_EV_of_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_content_ST_location_EV_of_Posit (
            PR_content_ST_location_EV_of_ID number(10) default PR_content_ST_location_EV_of_Posit_ID_SEQ.nextval not null, 
            PR_ID_content number(10) not null, 
            ST_ID_location number(10) not null, 
            EV_ID_of number(10) not null, 
            constraint PR_content_ST_location_EV_of_Posit_fkPR_content foreign key (
                PR_ID_content
            ) references PR_Program(PR_ID),
            constraint PR_content_ST_location_EV_of_Posit_fkST_location foreign key (
                ST_ID_location
            ) references ST_Stage(ST_ID),
            constraint PR_content_ST_location_EV_of_Posit_fkEV_of foreign key (
                EV_ID_of
            ) references EV_Event(EV_ID),
            constraint pkPR_content_ST_location_EV_of_Posit primary key (
                PR_content_ST_location_EV_of_ID
            ),
            constraint uqPR_content_ST_location_EV_of unique (
                EV_ID_of,
                PR_ID_content,
                ST_ID_location
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_content_ST_location_EV_of_Annex (
            PR_content_ST_location_EV_of_ID number(10) not null,
            PR_content_ST_location_EV_of_PositedAt timestamp not null,
            PR_content_ST_location_EV_of_Reliability number(5,2) not null,
            Metadata_PR_content_ST_location_EV_of number(10) not null,
            constraint fkPR_content_ST_location_EV_of_Annex foreign key (
                PR_content_ST_location_EV_of_ID
            ) references PR_content_ST_location_EV_of_Posit(PR_content_ST_location_EV_of_ID),
            constraint pkPR_content_ST_location_EV_of_Annex primary key (
                PR_content_ST_location_EV_of_ID,
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
-- in uni-temporal modeling.
--
CREATE OR REPLACE VIEW AC_partner_AC_with_ONG_currently AS
SELECT
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Reliability
FROM
    AC_partner_AC_with_ONG_currently_Posit p
JOIN
    AC_partner_AC_with_ONG_currently_Annex a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
;
CREATE OR REPLACE VIEW AC_subset_PN_of AS
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Reliability
FROM
    AC_subset_PN_of_Posit p
JOIN
    AC_subset_PN_of_Annex a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
;
CREATE OR REPLACE VIEW EV_in_AC_wasCast AS
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Reliability
FROM
    EV_in_AC_wasCast_Posit p
JOIN
    EV_in_AC_wasCast_Annex a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
;
CREATE OR REPLACE VIEW AC_part_PR_in_RAT_got AS
SELECT
    a.Metadata_AC_part_PR_in_RAT_got,
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Reliability
FROM
    AC_part_PR_in_RAT_got_Posit p
JOIN
    AC_part_PR_in_RAT_got_Annex a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
;
CREATE OR REPLACE VIEW ST_at_PR_isPlaying AS
SELECT
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Reliability
FROM
    ST_at_PR_isPlaying_Posit p
JOIN
    ST_at_PR_isPlaying_Annex a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
;
CREATE OR REPLACE VIEW AC_parent_AC_child_PAT_having AS
SELECT
    a.Metadata_AC_parent_AC_child_PAT_having,
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Reliability
FROM
    AC_parent_AC_child_PAT_having_Posit p
JOIN
    AC_parent_AC_child_PAT_having_Annex a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
;
CREATE OR REPLACE VIEW PR_content_ST_location_EV_of AS
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Reliability
FROM
    PR_content_ST_location_EV_of_Posit p
JOIN
    PR_content_ST_location_EV_of_Annex a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time. They are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later):
-- functions that return the text of a query, in which the parameters stand for the values given, called in the FROM
-- clause like a table. The macros do not call each other, they do what the others do in their own query.
--
-- The assembled rewinder and forwarder pick, for each posit, the annex row that was last posited at or before the
-- positing time. A bi posit has no positor, so the annex rows of a posit compete with each other alone.
--
-- @changingTimepoint the point in changing time to rewind to
-- @positingTimepoint the point in positing time to rewind to
--
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_partner_AC_with_ONG_currently_Posit (
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
            AC_partner_AC_with_ONG_currently_Posit
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fAC_partner_AC_with_ONG_currently_Posit (
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
            AC_partner_AC_with_ONG_currently_Posit
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
    ]';
END fAC_partner_AC_with_ONG_currently_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_partner_AC_with_ONG_currently_Annex (
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
            AC_partner_AC_with_ONG_currently_Reliability
        FROM
            AC_partner_AC_with_ONG_currently_Annex
        WHERE
            AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_partner_AC_with_ONG_currently (
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
            AC_partner_AC_with_ONG_currently_Reliability
        FROM (
            SELECT
                a.Metadata_AC_partner_AC_with_ONG_currently,
                p.AC_partner_AC_with_ONG_currently_ID,
                p.AC_ID_partner,
                p.AC_ID_with,
                p.ONG_ID_currently,
                p.AC_partner_AC_with_ONG_currently_ChangedAt,
                a.AC_partner_AC_with_ONG_currently_PositedAt,
                a.AC_partner_AC_with_ONG_currently_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_partner_AC_with_ONG_currently_Posit p
            JOIN
                AC_partner_AC_with_ONG_currently_Annex a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
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
CREATE OR REPLACE FUNCTION fAC_partner_AC_with_ONG_currently (
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
            AC_partner_AC_with_ONG_currently_Reliability
        FROM (
            SELECT
                a.Metadata_AC_partner_AC_with_ONG_currently,
                p.AC_partner_AC_with_ONG_currently_ID,
                p.AC_ID_partner,
                p.AC_ID_with,
                p.ONG_ID_currently,
                p.AC_partner_AC_with_ONG_currently_ChangedAt,
                a.AC_partner_AC_with_ONG_currently_PositedAt,
                a.AC_partner_AC_with_ONG_currently_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_partner_AC_with_ONG_currently_Posit p
            JOIN
                AC_partner_AC_with_ONG_currently_Annex a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
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
CREATE OR REPLACE FUNCTION rAC_subset_PN_of_Annex (
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
            AC_subset_PN_of_Reliability
        FROM
            AC_subset_PN_of_Annex
        WHERE
            AC_subset_PN_of_PositedAt <= positingTimepoint
    ]';
END rAC_subset_PN_of_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_subset_PN_of (
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
            AC_subset_PN_of_Reliability
        FROM (
            SELECT
                a.Metadata_AC_subset_PN_of,
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_subset_PN_of_Posit p
            JOIN
                AC_subset_PN_of_Annex a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
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
CREATE OR REPLACE FUNCTION fAC_subset_PN_of (
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
            AC_subset_PN_of_Reliability
        FROM (
            SELECT
                a.Metadata_AC_subset_PN_of,
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_subset_PN_of_Posit p
            JOIN
                AC_subset_PN_of_Annex a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
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
CREATE OR REPLACE FUNCTION rEV_in_AC_wasCast_Annex (
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
            EV_in_AC_wasCast_Reliability
        FROM
            EV_in_AC_wasCast_Annex
        WHERE
            EV_in_AC_wasCast_PositedAt <= positingTimepoint
    ]';
END rEV_in_AC_wasCast_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_in_AC_wasCast (
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
            EV_in_AC_wasCast_Reliability
        FROM (
            SELECT
                a.Metadata_EV_in_AC_wasCast,
                p.EV_in_AC_wasCast_ID,
                p.EV_ID_in,
                p.AC_ID_wasCast,
                a.EV_in_AC_wasCast_PositedAt,
                a.EV_in_AC_wasCast_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_wasCast_ID
                    ORDER BY
                        a.EV_in_AC_wasCast_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_in_AC_wasCast_Posit p
            JOIN
                EV_in_AC_wasCast_Annex a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
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
CREATE OR REPLACE FUNCTION fEV_in_AC_wasCast (
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
            EV_in_AC_wasCast_Reliability
        FROM (
            SELECT
                a.Metadata_EV_in_AC_wasCast,
                p.EV_in_AC_wasCast_ID,
                p.EV_ID_in,
                p.AC_ID_wasCast,
                a.EV_in_AC_wasCast_PositedAt,
                a.EV_in_AC_wasCast_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_wasCast_ID
                    ORDER BY
                        a.EV_in_AC_wasCast_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_in_AC_wasCast_Posit p
            JOIN
                EV_in_AC_wasCast_Annex a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
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
CREATE OR REPLACE FUNCTION rAC_part_PR_in_RAT_got_Posit (
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
            AC_part_PR_in_RAT_got_Posit
        WHERE
            AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
    ]';
END rAC_part_PR_in_RAT_got_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fAC_part_PR_in_RAT_got_Posit (
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
            AC_part_PR_in_RAT_got_Posit
        WHERE
            AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
    ]';
END fAC_part_PR_in_RAT_got_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_part_PR_in_RAT_got_Annex (
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
            AC_part_PR_in_RAT_got_Reliability
        FROM
            AC_part_PR_in_RAT_got_Annex
        WHERE
            AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
    ]';
END rAC_part_PR_in_RAT_got_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_part_PR_in_RAT_got (
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
            AC_part_PR_in_RAT_got_Reliability
        FROM (
            SELECT
                a.Metadata_AC_part_PR_in_RAT_got,
                p.AC_part_PR_in_RAT_got_ID,
                p.AC_ID_part,
                p.PR_ID_in,
                p.RAT_ID_got,
                p.AC_part_PR_in_RAT_got_ChangedAt,
                a.AC_part_PR_in_RAT_got_PositedAt,
                a.AC_part_PR_in_RAT_got_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_part_PR_in_RAT_got_ID
                    ORDER BY
                        a.AC_part_PR_in_RAT_got_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_part_PR_in_RAT_got_Posit p
            JOIN
                AC_part_PR_in_RAT_got_Annex a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
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
CREATE OR REPLACE FUNCTION fAC_part_PR_in_RAT_got (
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
            AC_part_PR_in_RAT_got_Reliability
        FROM (
            SELECT
                a.Metadata_AC_part_PR_in_RAT_got,
                p.AC_part_PR_in_RAT_got_ID,
                p.AC_ID_part,
                p.PR_ID_in,
                p.RAT_ID_got,
                p.AC_part_PR_in_RAT_got_ChangedAt,
                a.AC_part_PR_in_RAT_got_PositedAt,
                a.AC_part_PR_in_RAT_got_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_part_PR_in_RAT_got_ID
                    ORDER BY
                        a.AC_part_PR_in_RAT_got_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_part_PR_in_RAT_got_Posit p
            JOIN
                AC_part_PR_in_RAT_got_Annex a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
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
CREATE OR REPLACE FUNCTION rST_at_PR_isPlaying_Posit (
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
            ST_at_PR_isPlaying_Posit
        WHERE
            ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
    ]';
END rST_at_PR_isPlaying_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fST_at_PR_isPlaying_Posit (
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
            ST_at_PR_isPlaying_Posit
        WHERE
            ST_at_PR_isPlaying_ChangedAt > changingTimepoint
    ]';
END fST_at_PR_isPlaying_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_at_PR_isPlaying_Annex (
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
            ST_at_PR_isPlaying_Reliability
        FROM
            ST_at_PR_isPlaying_Annex
        WHERE
            ST_at_PR_isPlaying_PositedAt <= positingTimepoint
    ]';
END rST_at_PR_isPlaying_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_at_PR_isPlaying (
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
            ST_at_PR_isPlaying_Reliability
        FROM (
            SELECT
                a.Metadata_ST_at_PR_isPlaying,
                p.ST_at_PR_isPlaying_ID,
                p.ST_ID_at,
                p.PR_ID_isPlaying,
                p.ST_at_PR_isPlaying_ChangedAt,
                a.ST_at_PR_isPlaying_PositedAt,
                a.ST_at_PR_isPlaying_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_isPlaying_ID
                    ORDER BY
                        a.ST_at_PR_isPlaying_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_at_PR_isPlaying_Posit p
            JOIN
                ST_at_PR_isPlaying_Annex a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
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
CREATE OR REPLACE FUNCTION fST_at_PR_isPlaying (
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
            ST_at_PR_isPlaying_Reliability
        FROM (
            SELECT
                a.Metadata_ST_at_PR_isPlaying,
                p.ST_at_PR_isPlaying_ID,
                p.ST_ID_at,
                p.PR_ID_isPlaying,
                p.ST_at_PR_isPlaying_ChangedAt,
                a.ST_at_PR_isPlaying_PositedAt,
                a.ST_at_PR_isPlaying_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_isPlaying_ID
                    ORDER BY
                        a.ST_at_PR_isPlaying_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_at_PR_isPlaying_Posit p
            JOIN
                ST_at_PR_isPlaying_Annex a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
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
CREATE OR REPLACE FUNCTION rAC_parent_AC_child_PAT_having_Annex (
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
            AC_parent_AC_child_PAT_having_Reliability
        FROM
            AC_parent_AC_child_PAT_having_Annex
        WHERE
            AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
    ]';
END rAC_parent_AC_child_PAT_having_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_parent_AC_child_PAT_having (
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
            AC_parent_AC_child_PAT_having_Reliability
        FROM (
            SELECT
                a.Metadata_AC_parent_AC_child_PAT_having,
                p.AC_parent_AC_child_PAT_having_ID,
                p.AC_ID_parent,
                p.AC_ID_child,
                p.PAT_ID_having,
                a.AC_parent_AC_child_PAT_having_PositedAt,
                a.AC_parent_AC_child_PAT_having_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_parent_AC_child_PAT_having_ID
                    ORDER BY
                        a.AC_parent_AC_child_PAT_having_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_parent_AC_child_PAT_having_Posit p
            JOIN
                AC_parent_AC_child_PAT_having_Annex a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
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
CREATE OR REPLACE FUNCTION fAC_parent_AC_child_PAT_having (
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
            AC_parent_AC_child_PAT_having_Reliability
        FROM (
            SELECT
                a.Metadata_AC_parent_AC_child_PAT_having,
                p.AC_parent_AC_child_PAT_having_ID,
                p.AC_ID_parent,
                p.AC_ID_child,
                p.PAT_ID_having,
                a.AC_parent_AC_child_PAT_having_PositedAt,
                a.AC_parent_AC_child_PAT_having_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_parent_AC_child_PAT_having_ID
                    ORDER BY
                        a.AC_parent_AC_child_PAT_having_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_parent_AC_child_PAT_having_Posit p
            JOIN
                AC_parent_AC_child_PAT_having_Annex a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            WHERE
                a.AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_parent_AC_child_PAT_having;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_content_ST_location_EV_of_Annex (
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
            PR_content_ST_location_EV_of_Reliability
        FROM
            PR_content_ST_location_EV_of_Annex
        WHERE
            PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
    ]';
END rPR_content_ST_location_EV_of_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_content_ST_location_EV_of (
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
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Reliability
        FROM (
            SELECT
                a.Metadata_PR_content_ST_location_EV_of,
                p.PR_content_ST_location_EV_of_ID,
                p.PR_ID_content,
                p.ST_ID_location,
                p.EV_ID_of,
                a.PR_content_ST_location_EV_of_PositedAt,
                a.PR_content_ST_location_EV_of_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_content_ST_location_EV_of_ID
                    ORDER BY
                        a.PR_content_ST_location_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                PR_content_ST_location_EV_of_Posit p
            JOIN
                PR_content_ST_location_EV_of_Annex a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            WHERE
                a.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_content_ST_location_EV_of;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fPR_content_ST_location_EV_of (
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
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Reliability
        FROM (
            SELECT
                a.Metadata_PR_content_ST_location_EV_of,
                p.PR_content_ST_location_EV_of_ID,
                p.PR_ID_content,
                p.ST_ID_location,
                p.EV_ID_of,
                a.PR_content_ST_location_EV_of_PositedAt,
                a.PR_content_ST_location_EV_of_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_content_ST_location_EV_of_ID
                    ORDER BY
                        a.PR_content_ST_location_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                PR_content_ST_location_EV_of_Posit p
            JOIN
                PR_content_ST_location_EV_of_Annex a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            WHERE
                a.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fPR_content_ST_location_EV_of;
/
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_part_PR_in_RAT_got(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinder of a tie is not called in the macros, what it does is written out in them: the posit and annex of the tie
-- joined, the annex row with the latest positing time picked for each posit, the posits that are not reliable left out.
--
-- The latest and now perspectives are views over the point-in-time macro.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_partner_AC_with_ONG_currently_ID,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_partner
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_with
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    an.Metadata_AC_partner_AC_with_ONG_currently,
                    po.AC_partner_AC_with_ONG_currently_ID,
                    po.AC_ID_partner,
                    po.AC_ID_with,
                    po.ONG_ID_currently,
                    po.AC_partner_AC_with_ONG_currently_ChangedAt,
                    an.AC_partner_AC_with_ONG_currently_PositedAt,
                    an.AC_partner_AC_with_ONG_currently_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_partner_AC_with_ONG_currently_ID
                        ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_partner_AC_with_ONG_currently_Posit po
                JOIN
                    AC_partner_AC_with_ONG_currently_Annex an
                ON
                    an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                WHERE
                    po.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.AC_partner_AC_with_ONG_currently_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_partner_AC_with_ONG_currently_Reliability = 1
        ) t
        LEFT JOIN
            ONG_Ongoing "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.latestPositAC_ID_partner = 1
        AND
            t.latestPositAC_ID_with = 1
    ]';
END tAC_partner_AC_with_ONG_currently;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_partner_AC_with_ONG_currently_ID,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_partner
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_with
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    an.Metadata_AC_partner_AC_with_ONG_currently,
                    po.AC_partner_AC_with_ONG_currently_ID,
                    po.AC_ID_partner,
                    po.AC_ID_with,
                    po.ONG_ID_currently,
                    po.AC_partner_AC_with_ONG_currently_ChangedAt,
                    an.AC_partner_AC_with_ONG_currently_PositedAt,
                    an.AC_partner_AC_with_ONG_currently_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_partner_AC_with_ONG_currently_ID
                        ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_partner_AC_with_ONG_currently_Posit po
                JOIN
                    AC_partner_AC_with_ONG_currently_Annex an
                ON
                    an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                WHERE
                    po.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.AC_partner_AC_with_ONG_currently_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_partner_AC_with_ONG_currently_Reliability = 1
        ) t
        LEFT JOIN
            ONG_Ongoing "kONG_currently"
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
CREATE OR REPLACE VIEW lAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    pAC_partner_AC_with_ONG_currently(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    pAC_partner_AC_with_ONG_currently(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
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
            t.AC_partner_AC_with_ONG_currently_ID,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_partner
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_with
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    an.Metadata_AC_partner_AC_with_ONG_currently,
                    po.AC_partner_AC_with_ONG_currently_ID,
                    po.AC_ID_partner,
                    po.AC_ID_with,
                    po.ONG_ID_currently,
                    po.AC_partner_AC_with_ONG_currently_ChangedAt,
                    an.AC_partner_AC_with_ONG_currently_PositedAt,
                    an.AC_partner_AC_with_ONG_currently_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_partner_AC_with_ONG_currently_ID
                        ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_partner_AC_with_ONG_currently_Posit po
                JOIN
                    AC_partner_AC_with_ONG_currently_Annex an
                ON
                    an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_partner_AC_with_ONG_currently_Reliability = 1
        ) t
        LEFT JOIN
            ONG_Ongoing "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.latestPositAC_ID_partner = 1
        AND
            t.latestPositAC_ID_with = 1
        AND
            t.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_partner_AC_with_ONG_currently;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tAC_subset_PN_of (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_subset_PN_of_ID,
            t.Metadata_AC_subset_PN_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Reliability,
            t.AC_ID_subset,
            t.PN_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_subset
                    ORDER BY
                        r.AC_subset_PN_of_PositedAt DESC,
                        r.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY r.PN_ID_of
                    ORDER BY
                        r.AC_subset_PN_of_PositedAt DESC,
                        r.AC_subset_PN_of_ID DESC
                ) AS latestPositPN_ID_of
            FROM (
                SELECT
                    an.Metadata_AC_subset_PN_of,
                    po.AC_subset_PN_of_ID,
                    po.AC_ID_subset,
                    po.PN_ID_of,
                    an.AC_subset_PN_of_PositedAt,
                    an.AC_subset_PN_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_subset_PN_of_ID
                        ORDER BY an.AC_subset_PN_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_subset_PN_of_Posit po
                JOIN
                    AC_subset_PN_of_Annex an
                ON
                    an.AC_subset_PN_of_ID = po.AC_subset_PN_of_ID
                WHERE
                    an.AC_subset_PN_of_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_subset_PN_of_Reliability = 1
        ) t
        WHERE
            t.latestPositAC_ID_subset = 1
        AND
            t.latestPositPN_ID_of = 1
    ]';
END tAC_subset_PN_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_subset_PN_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_subset_PN_of_ID,
            t.Metadata_AC_subset_PN_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Reliability,
            t.AC_ID_subset,
            t.PN_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_subset
                    ORDER BY
                        r.AC_subset_PN_of_PositedAt DESC,
                        r.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY r.PN_ID_of
                    ORDER BY
                        r.AC_subset_PN_of_PositedAt DESC,
                        r.AC_subset_PN_of_ID DESC
                ) AS latestPositPN_ID_of
            FROM (
                SELECT
                    an.Metadata_AC_subset_PN_of,
                    po.AC_subset_PN_of_ID,
                    po.AC_ID_subset,
                    po.PN_ID_of,
                    an.AC_subset_PN_of_PositedAt,
                    an.AC_subset_PN_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_subset_PN_of_ID
                        ORDER BY an.AC_subset_PN_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_subset_PN_of_Posit po
                JOIN
                    AC_subset_PN_of_Annex an
                ON
                    an.AC_subset_PN_of_ID = po.AC_subset_PN_of_ID
                WHERE
                    an.AC_subset_PN_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_subset_PN_of_Reliability = 1
        ) t
        WHERE
            t.latestPositAC_ID_subset = 1
        AND
            t.latestPositPN_ID_of = 1
    ]';
END pAC_subset_PN_of;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_subset_PN_of
AS
SELECT
    *
FROM
    pAC_subset_PN_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_subset_PN_of
AS
SELECT
    *
FROM
    pAC_subset_PN_of(CAST(current_timestamp AS timestamp))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tEV_in_AC_wasCast (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.EV_in_AC_wasCast_ID,
            t.Metadata_EV_in_AC_wasCast,
            t.EV_in_AC_wasCast_PositedAt,
            t.EV_in_AC_wasCast_Reliability,
            t.EV_ID_in,
            t.AC_ID_wasCast
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.EV_ID_in,
                        r.AC_ID_wasCast
                    ORDER BY
                        r.EV_in_AC_wasCast_PositedAt DESC,
                        r.EV_in_AC_wasCast_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_EV_in_AC_wasCast,
                    po.EV_in_AC_wasCast_ID,
                    po.EV_ID_in,
                    po.AC_ID_wasCast,
                    an.EV_in_AC_wasCast_PositedAt,
                    an.EV_in_AC_wasCast_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.EV_in_AC_wasCast_ID
                        ORDER BY an.EV_in_AC_wasCast_PositedAt DESC
                    ) AS rewindRank
                FROM
                    EV_in_AC_wasCast_Posit po
                JOIN
                    EV_in_AC_wasCast_Annex an
                ON
                    an.EV_in_AC_wasCast_ID = po.EV_in_AC_wasCast_ID
                WHERE
                    an.EV_in_AC_wasCast_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.EV_in_AC_wasCast_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END tEV_in_AC_wasCast;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pEV_in_AC_wasCast (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.EV_in_AC_wasCast_ID,
            t.Metadata_EV_in_AC_wasCast,
            t.EV_in_AC_wasCast_PositedAt,
            t.EV_in_AC_wasCast_Reliability,
            t.EV_ID_in,
            t.AC_ID_wasCast
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.EV_ID_in,
                        r.AC_ID_wasCast
                    ORDER BY
                        r.EV_in_AC_wasCast_PositedAt DESC,
                        r.EV_in_AC_wasCast_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_EV_in_AC_wasCast,
                    po.EV_in_AC_wasCast_ID,
                    po.EV_ID_in,
                    po.AC_ID_wasCast,
                    an.EV_in_AC_wasCast_PositedAt,
                    an.EV_in_AC_wasCast_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.EV_in_AC_wasCast_ID
                        ORDER BY an.EV_in_AC_wasCast_PositedAt DESC
                    ) AS rewindRank
                FROM
                    EV_in_AC_wasCast_Posit po
                JOIN
                    EV_in_AC_wasCast_Annex an
                ON
                    an.EV_in_AC_wasCast_ID = po.EV_in_AC_wasCast_ID
                WHERE
                    an.EV_in_AC_wasCast_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.EV_in_AC_wasCast_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END pEV_in_AC_wasCast;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lEV_in_AC_wasCast
AS
SELECT
    *
FROM
    pEV_in_AC_wasCast(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nEV_in_AC_wasCast
AS
SELECT
    *
FROM
    pEV_in_AC_wasCast(CAST(current_timestamp AS timestamp))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_part_PR_in_RAT_got_ID,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Reliability,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_part,
                        r.PR_ID_in
                    ORDER BY
                        r.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        r.AC_part_PR_in_RAT_got_PositedAt DESC,
                        r.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_part_PR_in_RAT_got,
                    po.AC_part_PR_in_RAT_got_ID,
                    po.AC_ID_part,
                    po.PR_ID_in,
                    po.RAT_ID_got,
                    po.AC_part_PR_in_RAT_got_ChangedAt,
                    an.AC_part_PR_in_RAT_got_PositedAt,
                    an.AC_part_PR_in_RAT_got_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_part_PR_in_RAT_got_ID
                        ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_part_PR_in_RAT_got_Posit po
                JOIN
                    AC_part_PR_in_RAT_got_Annex an
                ON
                    an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
                WHERE
                    po.AC_part_PR_in_RAT_got_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.AC_part_PR_in_RAT_got_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_part_PR_in_RAT_got_Reliability = 1
        ) t
        LEFT JOIN
            RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.latestPosit = 1
    ]';
END tAC_part_PR_in_RAT_got;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_part_PR_in_RAT_got_ID,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Reliability,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_part,
                        r.PR_ID_in
                    ORDER BY
                        r.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        r.AC_part_PR_in_RAT_got_PositedAt DESC,
                        r.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_part_PR_in_RAT_got,
                    po.AC_part_PR_in_RAT_got_ID,
                    po.AC_ID_part,
                    po.PR_ID_in,
                    po.RAT_ID_got,
                    po.AC_part_PR_in_RAT_got_ChangedAt,
                    an.AC_part_PR_in_RAT_got_PositedAt,
                    an.AC_part_PR_in_RAT_got_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_part_PR_in_RAT_got_ID
                        ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_part_PR_in_RAT_got_Posit po
                JOIN
                    AC_part_PR_in_RAT_got_Annex an
                ON
                    an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
                WHERE
                    po.AC_part_PR_in_RAT_got_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.AC_part_PR_in_RAT_got_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_part_PR_in_RAT_got_Reliability = 1
        ) t
        LEFT JOIN
            RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.latestPosit = 1
    ]';
END pAC_part_PR_in_RAT_got;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_part_PR_in_RAT_got
AS
SELECT
    *
FROM
    pAC_part_PR_in_RAT_got(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_part_PR_in_RAT_got
AS
SELECT
    *
FROM
    pAC_part_PR_in_RAT_got(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
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
            t.AC_part_PR_in_RAT_got_ID,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Reliability,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_part,
                        r.PR_ID_in
                    ORDER BY
                        r.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        r.AC_part_PR_in_RAT_got_PositedAt DESC,
                        r.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_part_PR_in_RAT_got,
                    po.AC_part_PR_in_RAT_got_ID,
                    po.AC_ID_part,
                    po.PR_ID_in,
                    po.RAT_ID_got,
                    po.AC_part_PR_in_RAT_got_ChangedAt,
                    an.AC_part_PR_in_RAT_got_PositedAt,
                    an.AC_part_PR_in_RAT_got_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_part_PR_in_RAT_got_ID
                        ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_part_PR_in_RAT_got_Posit po
                JOIN
                    AC_part_PR_in_RAT_got_Annex an
                ON
                    an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_part_PR_in_RAT_got_Reliability = 1
        ) t
        LEFT JOIN
            RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.latestPosit = 1
        AND
            t.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_part_PR_in_RAT_got;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tST_at_PR_isPlaying (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.ST_at_PR_isPlaying_ID,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Reliability,
            t.ST_ID_at,
            t.PR_ID_isPlaying
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.ST_ID_at,
                        r.PR_ID_isPlaying
                    ORDER BY
                        r.ST_at_PR_isPlaying_ChangedAt DESC,
                        r.ST_at_PR_isPlaying_PositedAt DESC,
                        r.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_ST_at_PR_isPlaying,
                    po.ST_at_PR_isPlaying_ID,
                    po.ST_ID_at,
                    po.PR_ID_isPlaying,
                    po.ST_at_PR_isPlaying_ChangedAt,
                    an.ST_at_PR_isPlaying_PositedAt,
                    an.ST_at_PR_isPlaying_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.ST_at_PR_isPlaying_ID
                        ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ST_at_PR_isPlaying_Posit po
                JOIN
                    ST_at_PR_isPlaying_Annex an
                ON
                    an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
                WHERE
                    po.ST_at_PR_isPlaying_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.ST_at_PR_isPlaying_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.ST_at_PR_isPlaying_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END tST_at_PR_isPlaying;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pST_at_PR_isPlaying (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.ST_at_PR_isPlaying_ID,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Reliability,
            t.ST_ID_at,
            t.PR_ID_isPlaying
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.ST_ID_at,
                        r.PR_ID_isPlaying
                    ORDER BY
                        r.ST_at_PR_isPlaying_ChangedAt DESC,
                        r.ST_at_PR_isPlaying_PositedAt DESC,
                        r.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_ST_at_PR_isPlaying,
                    po.ST_at_PR_isPlaying_ID,
                    po.ST_ID_at,
                    po.PR_ID_isPlaying,
                    po.ST_at_PR_isPlaying_ChangedAt,
                    an.ST_at_PR_isPlaying_PositedAt,
                    an.ST_at_PR_isPlaying_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.ST_at_PR_isPlaying_ID
                        ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ST_at_PR_isPlaying_Posit po
                JOIN
                    ST_at_PR_isPlaying_Annex an
                ON
                    an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
                WHERE
                    po.ST_at_PR_isPlaying_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.ST_at_PR_isPlaying_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.ST_at_PR_isPlaying_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END pST_at_PR_isPlaying;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lST_at_PR_isPlaying
AS
SELECT
    *
FROM
    pST_at_PR_isPlaying(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nST_at_PR_isPlaying
AS
SELECT
    *
FROM
    pST_at_PR_isPlaying(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
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
            t.ST_at_PR_isPlaying_ID,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Reliability,
            t.ST_ID_at,
            t.PR_ID_isPlaying
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.ST_ID_at,
                        r.PR_ID_isPlaying
                    ORDER BY
                        r.ST_at_PR_isPlaying_ChangedAt DESC,
                        r.ST_at_PR_isPlaying_PositedAt DESC,
                        r.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_ST_at_PR_isPlaying,
                    po.ST_at_PR_isPlaying_ID,
                    po.ST_ID_at,
                    po.PR_ID_isPlaying,
                    po.ST_at_PR_isPlaying_ChangedAt,
                    an.ST_at_PR_isPlaying_PositedAt,
                    an.ST_at_PR_isPlaying_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.ST_at_PR_isPlaying_ID
                        ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ST_at_PR_isPlaying_Posit po
                JOIN
                    ST_at_PR_isPlaying_Annex an
                ON
                    an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.ST_at_PR_isPlaying_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
        AND
            t.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dST_at_PR_isPlaying;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tAC_parent_AC_child_PAT_having (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_parent_AC_child_PAT_having_ID,
            t.Metadata_AC_parent_AC_child_PAT_having,
            t.AC_parent_AC_child_PAT_having_PositedAt,
            t.AC_parent_AC_child_PAT_having_Reliability,
            t.AC_ID_parent,
            t.AC_ID_child,
            "kPAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "kPAT_having".Metadata_PAT AS having_Metadata_PAT,
            t.PAT_ID_having
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_parent,
                        r.AC_ID_child,
                        r.PAT_ID_having
                    ORDER BY
                        r.AC_parent_AC_child_PAT_having_PositedAt DESC,
                        r.AC_parent_AC_child_PAT_having_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_parent_AC_child_PAT_having,
                    po.AC_parent_AC_child_PAT_having_ID,
                    po.AC_ID_parent,
                    po.AC_ID_child,
                    po.PAT_ID_having,
                    an.AC_parent_AC_child_PAT_having_PositedAt,
                    an.AC_parent_AC_child_PAT_having_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_parent_AC_child_PAT_having_ID
                        ORDER BY an.AC_parent_AC_child_PAT_having_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_parent_AC_child_PAT_having_Posit po
                JOIN
                    AC_parent_AC_child_PAT_having_Annex an
                ON
                    an.AC_parent_AC_child_PAT_having_ID = po.AC_parent_AC_child_PAT_having_ID
                WHERE
                    an.AC_parent_AC_child_PAT_having_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_parent_AC_child_PAT_having_Reliability = 1
        ) t
        LEFT JOIN
            PAT_ParentalType "kPAT_having"
        ON
            "kPAT_having".PAT_ID = t.PAT_ID_having
        WHERE
            t.latestPosit = 1
    ]';
END tAC_parent_AC_child_PAT_having;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_parent_AC_child_PAT_having (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_parent_AC_child_PAT_having_ID,
            t.Metadata_AC_parent_AC_child_PAT_having,
            t.AC_parent_AC_child_PAT_having_PositedAt,
            t.AC_parent_AC_child_PAT_having_Reliability,
            t.AC_ID_parent,
            t.AC_ID_child,
            "kPAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "kPAT_having".Metadata_PAT AS having_Metadata_PAT,
            t.PAT_ID_having
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_parent,
                        r.AC_ID_child,
                        r.PAT_ID_having
                    ORDER BY
                        r.AC_parent_AC_child_PAT_having_PositedAt DESC,
                        r.AC_parent_AC_child_PAT_having_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_parent_AC_child_PAT_having,
                    po.AC_parent_AC_child_PAT_having_ID,
                    po.AC_ID_parent,
                    po.AC_ID_child,
                    po.PAT_ID_having,
                    an.AC_parent_AC_child_PAT_having_PositedAt,
                    an.AC_parent_AC_child_PAT_having_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_parent_AC_child_PAT_having_ID
                        ORDER BY an.AC_parent_AC_child_PAT_having_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_parent_AC_child_PAT_having_Posit po
                JOIN
                    AC_parent_AC_child_PAT_having_Annex an
                ON
                    an.AC_parent_AC_child_PAT_having_ID = po.AC_parent_AC_child_PAT_having_ID
                WHERE
                    an.AC_parent_AC_child_PAT_having_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_parent_AC_child_PAT_having_Reliability = 1
        ) t
        LEFT JOIN
            PAT_ParentalType "kPAT_having"
        ON
            "kPAT_having".PAT_ID = t.PAT_ID_having
        WHERE
            t.latestPosit = 1
    ]';
END pAC_parent_AC_child_PAT_having;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    pAC_parent_AC_child_PAT_having(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    pAC_parent_AC_child_PAT_having(CAST(current_timestamp AS timestamp))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tPR_content_ST_location_EV_of (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.PR_content_ST_location_EV_of_ID,
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Reliability,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.EV_ID_of
                    ORDER BY
                        r.PR_content_ST_location_EV_of_PositedAt DESC,
                        r.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_PR_content_ST_location_EV_of,
                    po.PR_content_ST_location_EV_of_ID,
                    po.PR_ID_content,
                    po.ST_ID_location,
                    po.EV_ID_of,
                    an.PR_content_ST_location_EV_of_PositedAt,
                    an.PR_content_ST_location_EV_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.PR_content_ST_location_EV_of_ID
                        ORDER BY an.PR_content_ST_location_EV_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    PR_content_ST_location_EV_of_Posit po
                JOIN
                    PR_content_ST_location_EV_of_Annex an
                ON
                    an.PR_content_ST_location_EV_of_ID = po.PR_content_ST_location_EV_of_ID
                WHERE
                    an.PR_content_ST_location_EV_of_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.PR_content_ST_location_EV_of_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END tPR_content_ST_location_EV_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pPR_content_ST_location_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.PR_content_ST_location_EV_of_ID,
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Reliability,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.EV_ID_of
                    ORDER BY
                        r.PR_content_ST_location_EV_of_PositedAt DESC,
                        r.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_PR_content_ST_location_EV_of,
                    po.PR_content_ST_location_EV_of_ID,
                    po.PR_ID_content,
                    po.ST_ID_location,
                    po.EV_ID_of,
                    an.PR_content_ST_location_EV_of_PositedAt,
                    an.PR_content_ST_location_EV_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.PR_content_ST_location_EV_of_ID
                        ORDER BY an.PR_content_ST_location_EV_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    PR_content_ST_location_EV_of_Posit po
                JOIN
                    PR_content_ST_location_EV_of_Annex an
                ON
                    an.PR_content_ST_location_EV_of_ID = po.PR_content_ST_location_EV_of_ID
                WHERE
                    an.PR_content_ST_location_EV_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.PR_content_ST_location_EV_of_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END pPR_content_ST_location_EV_of;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lPR_content_ST_location_EV_of
AS
SELECT
    *
FROM
    pPR_content_ST_location_EV_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nPR_content_ST_location_EV_of
AS
SELECT
    *
FROM
    pPR_content_ST_location_EV_of(CAST(current_timestamp AS timestamp))
;
-- ATTRIBUTE TRIGGERS -------------------------------------------------------------------------------------------------
--
-- The following procedures state one posit of an attribute and its assertion, in the way that the model says, and the
-- triggers on the assembled views make the views behave like tables, by calling them. There is one 'instead of' trigger
-- for: insert. The procedures are procedures and not triggers on the posit and annex tables, since Oracle does not let a
-- row trigger read the table it is on (ORA-04091), which these rules do. The INSTEAD OF triggers on the latest views of the
-- anchors, and those of the nexuses, call them too, and so can a load:
--
--     BEGIN ip_AC_NAM_Actor_Name(p_owner => 1, p_value => 'Ann', p_changing => SYSTIMESTAMP, p_reliability => 1, p_metadata => 1); END;
--
-- ip_<attribute.name> (one for every attribute of an anchor or a nexus, named as the attribute is in the model, written in
-- front of its schema if it has one). Its parameters are named, and all except the owner and the value may be left out (or
-- be null), when the default of the one left out is used:
--
--     p_owner        the entity that has the attribute, a column of the posit table: the entity reference of the attribute
--     p_value        the value that is posited, as it is in the posit table: for a knotted attribute the identity of the value in the
--                    knot, for an attribute with a checksum the value (the checksum is made by the table)
--     p_changing     only for a historized attribute: from when the value is valid. Default: now (current_timestamp)
--     p_positing     when the posit is asserted. Default: now
--     p_reliability  how reliable the assertion is: 1 asserts the posit and 0 retracts it. Default: 1
--     p_metadata     only when the model has metadata: the metadata of the annex row. Default: 0
--
-- The rules are the ones in Anchor's docs/ANCHOR.md, "Loading through the latest views". Bitemporal modeling is decisive:
-- one posit at a time is asserted for an entity (and a changing time). An assertion of another value therefore retracts, at
-- its own positing time, the posit that is in effect, which is a correction; a posit is in effect at a positing time when its
-- latest annex row up to then asserts it. The positing time is now (the clock, which moves between two statements) unless it is
-- given. A posit that is not there is created. A retraction of what is not asserted states nothing. An error is raised
-- (RAISE_APPLICATION_ERROR) for a contradiction (-20001: another reliability of the same posit at the same positing time, or
-- another value for the same entity and changing time at that positing time) and for a restatement (-20002: the value is the
-- same as that of the version before or after it, where the attribute may not be restated). A call that raises an error is
-- undone, as is the statement that made it.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates, although what they correct is retracted.
--
-- Two functions help the procedures and may be used in a query as well:
--
--     eq_<attribute.name>(p_left, p_right)      1 if two values of the attribute are the same, else 0
--     he_<attribute.name>(p_id, p_positing)     the reliability of the posit with the identity at the positing time (that of its
--                                               latest annex row up to then), null if it has none
--
-- Oracle runs a trigger of this kind for each row.
--
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_DAT_Event_Date tells whether two values of EV_DAT_Event_Date are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_EV_DAT_Event_Date (
    p_left IN EV_DAT_Event_Date_Posit.EV_DAT_Event_Date%TYPE,
    p_right IN EV_DAT_Event_Date_Posit.EV_DAT_Event_Date%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_DAT_Event_Date;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_DAT_Event_Date is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_EV_DAT_Event_Date (
    p_id IN EV_DAT_Event_Date_Annex.EV_DAT_ID%TYPE,
    p_positing IN EV_DAT_Event_Date_Annex.EV_DAT_PositedAt%TYPE
) RETURN EV_DAT_Event_Date_Annex.EV_DAT_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_DAT_Reliability
        FROM
            EV_DAT_Event_Date_Annex a
        WHERE
            a.EV_DAT_ID = p_id
        AND
            a.EV_DAT_PositedAt <= p_positing
        ORDER BY
            a.EV_DAT_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_DAT_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_DAT_Event_Date;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_DAT_Event_Date states a value of EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_DAT_Event_Date (
    p_owner IN EV_DAT_Event_Date_Posit.EV_DAT_EV_ID%TYPE,
    p_value IN EV_DAT_Event_Date_Posit.EV_DAT_Event_Date%TYPE,
    p_positing IN EV_DAT_Event_Date_Annex.EV_DAT_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_DAT_Event_Date_Annex.EV_DAT_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_DAT_Event_Date_Annex.Metadata_EV_DAT%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit EV_DAT_Event_Date_Posit.EV_DAT_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN EV_DAT_Event_Date_Posit.EV_DAT_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_DAT_Event_Date_Annex (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    EV_DAT_Event_Date_Annex x
                WHERE
                    x.EV_DAT_ID = p_id
                AND
                    x.EV_DAT_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            EV_DAT_Event_Date_Posit p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_DAT_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_DAT_Event_Date_Annex a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_DAT_Event_Date_Posit p
        JOIN
            EV_DAT_Event_Date_Annex a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 0
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_DAT_Event_Date_Annex a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_EV_DAT_Event_Date(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO EV_DAT_Event_Date_Annex (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            EV_DAT_Event_Date_Posit p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 0
        AND
            COALESCE(he_EV_DAT_Event_Date(p.EV_DAT_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_DAT_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_DAT_Event_Date_Posit (
            EV_DAT_EV_ID,
            EV_DAT_Event_Date
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_DAT_ID INTO v_posit;
    END IF;
    INSERT INTO EV_DAT_Event_Date_Annex (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_DAT_Event_Date;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_DAT_Event_Date instead of INSERT trigger on EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_EV_DAT_Event_Date
INSTEAD OF INSERT ON EV_DAT_Event_Date
FOR EACH ROW
BEGIN
    ip_EV_DAT_Event_Date(
        p_owner => :NEW.EV_DAT_EV_ID,
        p_value => :NEW.EV_DAT_Event_Date,
        p_positing => :NEW.EV_DAT_PositedAt,
        p_reliability => :NEW.EV_DAT_Reliability,
        p_metadata => :NEW.Metadata_EV_DAT
    );
END it_EV_DAT_Event_Date;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_AUD_Event_Audience tells whether two values of EV_AUD_Event_Audience are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_EV_AUD_Event_Audience (
    p_left IN EV_AUD_Event_Audience_Posit.EV_AUD_Event_Audience%TYPE,
    p_right IN EV_AUD_Event_Audience_Posit.EV_AUD_Event_Audience%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_AUD_Event_Audience;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_AUD_Event_Audience is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_EV_AUD_Event_Audience (
    p_id IN EV_AUD_Event_Audience_Annex.EV_AUD_ID%TYPE,
    p_positing IN EV_AUD_Event_Audience_Annex.EV_AUD_PositedAt%TYPE
) RETURN EV_AUD_Event_Audience_Annex.EV_AUD_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_AUD_Reliability
        FROM
            EV_AUD_Event_Audience_Annex a
        WHERE
            a.EV_AUD_ID = p_id
        AND
            a.EV_AUD_PositedAt <= p_positing
        ORDER BY
            a.EV_AUD_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_AUD_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_AUD_Event_Audience;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Event_Audience states a value of EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_AUD_Event_Audience (
    p_owner IN EV_AUD_Event_Audience_Posit.EV_AUD_EV_ID%TYPE,
    p_value IN EV_AUD_Event_Audience_Posit.EV_AUD_Event_Audience%TYPE,
    p_positing IN EV_AUD_Event_Audience_Annex.EV_AUD_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_AUD_Event_Audience_Annex.EV_AUD_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_AUD_Event_Audience_Annex.Metadata_EV_AUD%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit EV_AUD_Event_Audience_Posit.EV_AUD_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN EV_AUD_Event_Audience_Posit.EV_AUD_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_AUD_Event_Audience_Annex (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    EV_AUD_Event_Audience_Annex x
                WHERE
                    x.EV_AUD_ID = p_id
                AND
                    x.EV_AUD_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            EV_AUD_Event_Audience_Posit p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_AUD_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_AUD_Event_Audience_Annex a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_AUD_Event_Audience_Posit p
        JOIN
            EV_AUD_Event_Audience_Annex a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 0
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_AUD_Event_Audience_Annex a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_EV_AUD_Event_Audience(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO EV_AUD_Event_Audience_Annex (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            EV_AUD_Event_Audience_Posit p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 0
        AND
            COALESCE(he_EV_AUD_Event_Audience(p.EV_AUD_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_AUD_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_AUD_Event_Audience_Posit (
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_AUD_ID INTO v_posit;
    END IF;
    INSERT INTO EV_AUD_Event_Audience_Annex (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_AUD_Event_Audience;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience instead of INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_EV_AUD_Event_Audience
INSTEAD OF INSERT ON EV_AUD_Event_Audience
FOR EACH ROW
BEGIN
    ip_EV_AUD_Event_Audience(
        p_owner => :NEW.EV_AUD_EV_ID,
        p_value => :NEW.EV_AUD_Event_Audience,
        p_positing => :NEW.EV_AUD_PositedAt,
        p_reliability => :NEW.EV_AUD_Reliability,
        p_metadata => :NEW.Metadata_EV_AUD
    );
END it_EV_AUD_Event_Audience;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_REV_Event_Revenue tells whether two values of EV_REV_Event_Revenue are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_EV_REV_Event_Revenue (
    p_left IN EV_REV_Event_Revenue_Posit.EV_REV_Event_Revenue%TYPE,
    p_right IN EV_REV_Event_Revenue_Posit.EV_REV_Event_Revenue%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_REV_Event_Revenue;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_REV_Event_Revenue is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_EV_REV_Event_Revenue (
    p_id IN EV_REV_Event_Revenue_Annex.EV_REV_ID%TYPE,
    p_positing IN EV_REV_Event_Revenue_Annex.EV_REV_PositedAt%TYPE
) RETURN EV_REV_Event_Revenue_Annex.EV_REV_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_REV_Reliability
        FROM
            EV_REV_Event_Revenue_Annex a
        WHERE
            a.EV_REV_ID = p_id
        AND
            a.EV_REV_PositedAt <= p_positing
        ORDER BY
            a.EV_REV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_REV_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_REV_Event_Revenue;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Event_Revenue states a value of EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_REV_Event_Revenue (
    p_owner IN EV_REV_Event_Revenue_Posit.EV_REV_EV_ID%TYPE,
    p_value IN EV_REV_Event_Revenue_Posit.EV_REV_Event_Revenue%TYPE,
    p_positing IN EV_REV_Event_Revenue_Annex.EV_REV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_REV_Event_Revenue_Annex.EV_REV_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_REV_Event_Revenue_Annex.Metadata_EV_REV%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit EV_REV_Event_Revenue_Posit.EV_REV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN EV_REV_Event_Revenue_Posit.EV_REV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_REV_Event_Revenue_Annex (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    EV_REV_Event_Revenue_Annex x
                WHERE
                    x.EV_REV_ID = p_id
                AND
                    x.EV_REV_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            EV_REV_Event_Revenue_Posit p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_REV_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_REV_Event_Revenue_Annex a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_REV_Event_Revenue_Posit p
        JOIN
            EV_REV_Event_Revenue_Annex a
        ON
            a.EV_REV_ID = p.EV_REV_ID
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 0
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_REV_Event_Revenue_Annex a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_EV_REV_Event_Revenue(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO EV_REV_Event_Revenue_Annex (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            EV_REV_Event_Revenue_Posit p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 0
        AND
            COALESCE(he_EV_REV_Event_Revenue(p.EV_REV_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_REV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_REV_Event_Revenue_Posit (
            EV_REV_EV_ID,
            EV_REV_Event_Revenue
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_REV_ID INTO v_posit;
    END IF;
    INSERT INTO EV_REV_Event_Revenue_Annex (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_REV_Event_Revenue;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue instead of INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_EV_REV_Event_Revenue
INSTEAD OF INSERT ON EV_REV_Event_Revenue
FOR EACH ROW
BEGIN
    ip_EV_REV_Event_Revenue(
        p_owner => :NEW.EV_REV_EV_ID,
        p_value => :NEW.EV_REV_Event_Revenue,
        p_positing => :NEW.EV_REV_PositedAt,
        p_reliability => :NEW.EV_REV_Reliability,
        p_metadata => :NEW.Metadata_EV_REV
    );
END it_EV_REV_Event_Revenue;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_NAM_Stage_Name tells whether two values of ST_NAM_Stage_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_ST_NAM_Stage_Name (
    p_left IN ST_NAM_Stage_Name_Posit.ST_NAM_Stage_Name%TYPE,
    p_right IN ST_NAM_Stage_Name_Posit.ST_NAM_Stage_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_NAM_Stage_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_NAM_Stage_Name is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_ST_NAM_Stage_Name (
    p_id IN ST_NAM_Stage_Name_Annex.ST_NAM_ID%TYPE,
    p_positing IN ST_NAM_Stage_Name_Annex.ST_NAM_PositedAt%TYPE
) RETURN ST_NAM_Stage_Name_Annex.ST_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_NAM_Reliability
        FROM
            ST_NAM_Stage_Name_Annex a
        WHERE
            a.ST_NAM_ID = p_id
        AND
            a.ST_NAM_PositedAt <= p_positing
        ORDER BY
            a.ST_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_NAM_Stage_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Stage_Name states a value of ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_NAM_Stage_Name (
    p_owner IN ST_NAM_Stage_Name_Posit.ST_NAM_ST_ID%TYPE,
    p_value IN ST_NAM_Stage_Name_Posit.ST_NAM_Stage_Name%TYPE,
    p_changing IN ST_NAM_Stage_Name_Posit.ST_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN ST_NAM_Stage_Name_Annex.ST_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ST_NAM_Stage_Name_Annex.ST_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ST_NAM_Stage_Name_Annex.Metadata_ST_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit ST_NAM_Stage_Name_Posit.ST_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN ST_NAM_Stage_Name_Posit.ST_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ST_NAM_Stage_Name_Annex (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ST_NAM_Stage_Name_Annex x
                WHERE
                    x.ST_NAM_ID = p_id
                AND
                    x.ST_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
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
            ST_NAM_Stage_Name_Posit p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_NAM_Stage_Name_Annex a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_NAM_Stage_Name_Posit p
        JOIN
            ST_NAM_Stage_Name_Annex a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 0
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_NAM_Stage_Name_Annex a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_ST_NAM_Stage_Name(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO ST_NAM_Stage_Name_Annex (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.ST_NAM_ID
        FROM
            ST_NAM_Stage_Name_Posit p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 0
        AND
            COALESCE(he_ST_NAM_Stage_Name(p.ST_NAM_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.ST_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ST_NAM_Stage_Name_Posit (
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
    INSERT INTO ST_NAM_Stage_Name_Annex (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_ST_NAM_Stage_Name;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_ST_NAM_Stage_Name
INSTEAD OF INSERT ON ST_NAM_Stage_Name
FOR EACH ROW
BEGIN
    ip_ST_NAM_Stage_Name(
        p_owner => :NEW.ST_NAM_ST_ID,
        p_value => :NEW.ST_NAM_Stage_Name,
        p_changing => :NEW.ST_NAM_ChangedAt,
        p_positing => :NEW.ST_NAM_PositedAt,
        p_reliability => :NEW.ST_NAM_Reliability,
        p_metadata => :NEW.Metadata_ST_NAM
    );
END it_ST_NAM_Stage_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_LOC_Stage_Location tells whether two values of ST_LOC_Stage_Location are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_ST_LOC_Stage_Location (
    p_left IN ST_LOC_Stage_Location_Posit.ST_LOC_Stage_Location%TYPE,
    p_right IN ST_LOC_Stage_Location_Posit.ST_LOC_Stage_Location%TYPE
) RETURN NUMBER
IS
BEGIN
    IF p_left IS NULL OR p_right IS NULL THEN
        RETURN 0;
    END IF;
    RETURN CASE WHEN DBMS_LOB.COMPARE(p_left, p_right) = 0 THEN 1 ELSE 0 END;
END eq_ST_LOC_Stage_Location;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_LOC_Stage_Location is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_ST_LOC_Stage_Location (
    p_id IN ST_LOC_Stage_Location_Annex.ST_LOC_ID%TYPE,
    p_positing IN ST_LOC_Stage_Location_Annex.ST_LOC_PositedAt%TYPE
) RETURN ST_LOC_Stage_Location_Annex.ST_LOC_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_LOC_Reliability
        FROM
            ST_LOC_Stage_Location_Annex a
        WHERE
            a.ST_LOC_ID = p_id
        AND
            a.ST_LOC_PositedAt <= p_positing
        ORDER BY
            a.ST_LOC_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_LOC_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_LOC_Stage_Location;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Stage_Location states a value of ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_LOC_Stage_Location (
    p_owner IN ST_LOC_Stage_Location_Posit.ST_LOC_ST_ID%TYPE,
    p_value IN ST_LOC_Stage_Location_Posit.ST_LOC_Stage_Location%TYPE,
    p_positing IN ST_LOC_Stage_Location_Annex.ST_LOC_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ST_LOC_Stage_Location_Annex.ST_LOC_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ST_LOC_Stage_Location_Annex.Metadata_ST_LOC%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit ST_LOC_Stage_Location_Posit.ST_LOC_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN ST_LOC_Stage_Location_Posit.ST_LOC_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ST_LOC_Stage_Location_Annex (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ST_LOC_Stage_Location_Annex x
                WHERE
                    x.ST_LOC_ID = p_id
                AND
                    x.ST_LOC_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            ST_LOC_Stage_Location_Posit p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_LOC_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_LOC_Stage_Location_Annex a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_LOC_Stage_Location_Posit p
        JOIN
            ST_LOC_Stage_Location_Annex a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 0
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_LOC_Stage_Location_Annex a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_ST_LOC_Stage_Location(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO ST_LOC_Stage_Location_Annex (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            ST_LOC_Stage_Location_Posit p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 0
        AND
            COALESCE(he_ST_LOC_Stage_Location(p.ST_LOC_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.ST_LOC_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ST_LOC_Stage_Location_Posit (
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_LOC_ID INTO v_posit;
    END IF;
    INSERT INTO ST_LOC_Stage_Location_Annex (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_ST_LOC_Stage_Location;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Stage_Location instead of INSERT trigger on ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_ST_LOC_Stage_Location
INSTEAD OF INSERT ON ST_LOC_Stage_Location
FOR EACH ROW
BEGIN
    ip_ST_LOC_Stage_Location(
        p_owner => :NEW.ST_LOC_ST_ID,
        p_value => :NEW.ST_LOC_Stage_Location,
        p_positing => :NEW.ST_LOC_PositedAt,
        p_reliability => :NEW.ST_LOC_Reliability,
        p_metadata => :NEW.Metadata_ST_LOC
    );
END it_ST_LOC_Stage_Location;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_AVG_Stage_Average tells whether two values of ST_AVG_Stage_Average are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_ST_AVG_Stage_Average (
    p_left IN ST_AVG_Stage_Average_Posit.ST_AVG_UTL_ID%TYPE,
    p_right IN ST_AVG_Stage_Average_Posit.ST_AVG_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_AVG_Stage_Average;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_AVG_Stage_Average is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_ST_AVG_Stage_Average (
    p_id IN ST_AVG_Stage_Average_Annex.ST_AVG_ID%TYPE,
    p_positing IN ST_AVG_Stage_Average_Annex.ST_AVG_PositedAt%TYPE
) RETURN ST_AVG_Stage_Average_Annex.ST_AVG_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_AVG_Reliability
        FROM
            ST_AVG_Stage_Average_Annex a
        WHERE
            a.ST_AVG_ID = p_id
        AND
            a.ST_AVG_PositedAt <= p_positing
        ORDER BY
            a.ST_AVG_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_AVG_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_AVG_Stage_Average;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Stage_Average states a value of ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_AVG_Stage_Average (
    p_owner IN ST_AVG_Stage_Average_Posit.ST_AVG_ST_ID%TYPE,
    p_value IN ST_AVG_Stage_Average_Posit.ST_AVG_UTL_ID%TYPE,
    p_changing IN ST_AVG_Stage_Average_Posit.ST_AVG_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN ST_AVG_Stage_Average_Annex.ST_AVG_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ST_AVG_Stage_Average_Annex.ST_AVG_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ST_AVG_Stage_Average_Annex.Metadata_ST_AVG%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit ST_AVG_Stage_Average_Posit.ST_AVG_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN ST_AVG_Stage_Average_Posit.ST_AVG_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ST_AVG_Stage_Average_Annex (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ST_AVG_Stage_Average_Annex x
                WHERE
                    x.ST_AVG_ID = p_id
                AND
                    x.ST_AVG_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
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
            ST_AVG_Stage_Average_Posit p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_AVG_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_AVG_Stage_Average_Annex a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_AVG_Stage_Average_Posit p
        JOIN
            ST_AVG_Stage_Average_Annex a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_AVG_Stage_Average_Annex a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_ST_AVG_Stage_Average(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO ST_AVG_Stage_Average_Annex (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.ST_AVG_ID
        FROM
            ST_AVG_Stage_Average_Posit p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            COALESCE(he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.ST_AVG_ID);
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.ST_AVG_UTL_ID
        FROM
            ST_AVG_Stage_Average_Posit p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < v_changing
        AND
            COALESCE(he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positing), 0) = 1
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_ST_AVG_Stage_Average(r.ST_AVG_UTL_ID, p_value) = 1 THEN
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
            ST_AVG_Stage_Average_Posit f
        WHERE
            f.ST_AVG_ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > v_changing
        AND
            COALESCE(he_ST_AVG_Stage_Average(f.ST_AVG_ID, v_positing), 0) = 1
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_ST_AVG_Stage_Average(r.ST_AVG_UTL_ID, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.ST_AVG_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ST_AVG_Stage_Average_Posit (
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
    INSERT INTO ST_AVG_Stage_Average_Annex (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_ST_AVG_Stage_Average;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average instead of INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_ST_AVG_Stage_Average
INSTEAD OF INSERT ON ST_AVG_Stage_Average
FOR EACH ROW
BEGIN
    ip_ST_AVG_Stage_Average(
        p_owner => :NEW.ST_AVG_ST_ID,
        p_value => :NEW.ST_AVG_UTL_ID,
        p_changing => :NEW.ST_AVG_ChangedAt,
        p_positing => :NEW.ST_AVG_PositedAt,
        p_reliability => :NEW.ST_AVG_Reliability,
        p_metadata => :NEW.Metadata_ST_AVG
    );
END it_ST_AVG_Stage_Average;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_MIN_Stage_Minimum tells whether two values of ST_MIN_Stage_Minimum are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_ST_MIN_Stage_Minimum (
    p_left IN ST_MIN_Stage_Minimum_Posit.ST_MIN_UTL_ID%TYPE,
    p_right IN ST_MIN_Stage_Minimum_Posit.ST_MIN_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_MIN_Stage_Minimum;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_MIN_Stage_Minimum is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_ST_MIN_Stage_Minimum (
    p_id IN ST_MIN_Stage_Minimum_Annex.ST_MIN_ID%TYPE,
    p_positing IN ST_MIN_Stage_Minimum_Annex.ST_MIN_PositedAt%TYPE
) RETURN ST_MIN_Stage_Minimum_Annex.ST_MIN_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_MIN_Reliability
        FROM
            ST_MIN_Stage_Minimum_Annex a
        WHERE
            a.ST_MIN_ID = p_id
        AND
            a.ST_MIN_PositedAt <= p_positing
        ORDER BY
            a.ST_MIN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_MIN_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_MIN_Stage_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Stage_Minimum states a value of ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_MIN_Stage_Minimum (
    p_owner IN ST_MIN_Stage_Minimum_Posit.ST_MIN_ST_ID%TYPE,
    p_value IN ST_MIN_Stage_Minimum_Posit.ST_MIN_UTL_ID%TYPE,
    p_positing IN ST_MIN_Stage_Minimum_Annex.ST_MIN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ST_MIN_Stage_Minimum_Annex.ST_MIN_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ST_MIN_Stage_Minimum_Annex.Metadata_ST_MIN%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit ST_MIN_Stage_Minimum_Posit.ST_MIN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN ST_MIN_Stage_Minimum_Posit.ST_MIN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ST_MIN_Stage_Minimum_Annex (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ST_MIN_Stage_Minimum_Annex x
                WHERE
                    x.ST_MIN_ID = p_id
                AND
                    x.ST_MIN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            ST_MIN_Stage_Minimum_Posit p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_MIN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_MIN_Stage_Minimum_Annex a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_MIN_Stage_Minimum_Posit p
        JOIN
            ST_MIN_Stage_Minimum_Annex a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_MIN_Stage_Minimum_Annex a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_ST_MIN_Stage_Minimum(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO ST_MIN_Stage_Minimum_Annex (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            ST_MIN_Stage_Minimum_Posit p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            COALESCE(he_ST_MIN_Stage_Minimum(p.ST_MIN_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.ST_MIN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ST_MIN_Stage_Minimum_Posit (
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_MIN_ID INTO v_posit;
    END IF;
    INSERT INTO ST_MIN_Stage_Minimum_Annex (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_ST_MIN_Stage_Minimum;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum instead of INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_ST_MIN_Stage_Minimum
INSTEAD OF INSERT ON ST_MIN_Stage_Minimum
FOR EACH ROW
BEGIN
    ip_ST_MIN_Stage_Minimum(
        p_owner => :NEW.ST_MIN_ST_ID,
        p_value => :NEW.ST_MIN_UTL_ID,
        p_positing => :NEW.ST_MIN_PositedAt,
        p_reliability => :NEW.ST_MIN_Reliability,
        p_metadata => :NEW.Metadata_ST_MIN
    );
END it_ST_MIN_Stage_Minimum;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_NAM_Actor_Name tells whether two values of AC_NAM_Actor_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_AC_NAM_Actor_Name (
    p_left IN AC_NAM_Actor_Name_Posit.AC_NAM_Actor_Name%TYPE,
    p_right IN AC_NAM_Actor_Name_Posit.AC_NAM_Actor_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_NAM_Actor_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_NAM_Actor_Name is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_AC_NAM_Actor_Name (
    p_id IN AC_NAM_Actor_Name_Annex.AC_NAM_ID%TYPE,
    p_positing IN AC_NAM_Actor_Name_Annex.AC_NAM_PositedAt%TYPE
) RETURN AC_NAM_Actor_Name_Annex.AC_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_NAM_Reliability
        FROM
            AC_NAM_Actor_Name_Annex a
        WHERE
            a.AC_NAM_ID = p_id
        AND
            a.AC_NAM_PositedAt <= p_positing
        ORDER BY
            a.AC_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_NAM_Actor_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Actor_Name states a value of AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_NAM_Actor_Name (
    p_owner IN AC_NAM_Actor_Name_Posit.AC_NAM_AC_ID%TYPE,
    p_value IN AC_NAM_Actor_Name_Posit.AC_NAM_Actor_Name%TYPE,
    p_changing IN AC_NAM_Actor_Name_Posit.AC_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN AC_NAM_Actor_Name_Annex.AC_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN AC_NAM_Actor_Name_Annex.AC_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN AC_NAM_Actor_Name_Annex.Metadata_AC_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit AC_NAM_Actor_Name_Posit.AC_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN AC_NAM_Actor_Name_Posit.AC_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO AC_NAM_Actor_Name_Annex (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    AC_NAM_Actor_Name_Annex x
                WHERE
                    x.AC_NAM_ID = p_id
                AND
                    x.AC_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
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
            AC_NAM_Actor_Name_Posit p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_NAM_Actor_Name_Annex a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_NAM_Actor_Name_Posit p
        JOIN
            AC_NAM_Actor_Name_Annex a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 0
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_NAM_Actor_Name_Annex a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_AC_NAM_Actor_Name(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO AC_NAM_Actor_Name_Annex (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.AC_NAM_ID
        FROM
            AC_NAM_Actor_Name_Posit p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 0
        AND
            COALESCE(he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.AC_NAM_ID);
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.AC_NAM_Actor_Name
        FROM
            AC_NAM_Actor_Name_Posit p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt < v_changing
        AND
            COALESCE(he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positing), 0) = 1
        ORDER BY
            p.AC_NAM_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_AC_NAM_Actor_Name(r.AC_NAM_Actor_Name, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || v_changing || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.AC_NAM_ID,
            f.AC_NAM_Actor_Name
        FROM
            AC_NAM_Actor_Name_Posit f
        WHERE
            f.AC_NAM_AC_ID = p_owner
        AND
            f.AC_NAM_ChangedAt > v_changing
        AND
            COALESCE(he_AC_NAM_Actor_Name(f.AC_NAM_ID, v_positing), 0) = 1
        ORDER BY
            f.AC_NAM_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_AC_NAM_Actor_Name(r.AC_NAM_Actor_Name, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || v_changing || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO AC_NAM_Actor_Name_Posit (
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
    INSERT INTO AC_NAM_Actor_Name_Annex (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_AC_NAM_Actor_Name;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name instead of INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_AC_NAM_Actor_Name
INSTEAD OF INSERT ON AC_NAM_Actor_Name
FOR EACH ROW
BEGIN
    ip_AC_NAM_Actor_Name(
        p_owner => :NEW.AC_NAM_AC_ID,
        p_value => :NEW.AC_NAM_Actor_Name,
        p_changing => :NEW.AC_NAM_ChangedAt,
        p_positing => :NEW.AC_NAM_PositedAt,
        p_reliability => :NEW.AC_NAM_Reliability,
        p_metadata => :NEW.Metadata_AC_NAM
    );
END it_AC_NAM_Actor_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_GEN_Actor_Gender tells whether two values of AC_GEN_Actor_Gender are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_AC_GEN_Actor_Gender (
    p_left IN AC_GEN_Actor_Gender_Posit.AC_GEN_GEN_ID%TYPE,
    p_right IN AC_GEN_Actor_Gender_Posit.AC_GEN_GEN_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_GEN_Actor_Gender;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_GEN_Actor_Gender is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_AC_GEN_Actor_Gender (
    p_id IN AC_GEN_Actor_Gender_Annex.AC_GEN_ID%TYPE,
    p_positing IN AC_GEN_Actor_Gender_Annex.AC_GEN_PositedAt%TYPE
) RETURN AC_GEN_Actor_Gender_Annex.AC_GEN_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_GEN_Reliability
        FROM
            AC_GEN_Actor_Gender_Annex a
        WHERE
            a.AC_GEN_ID = p_id
        AND
            a.AC_GEN_PositedAt <= p_positing
        ORDER BY
            a.AC_GEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_GEN_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_GEN_Actor_Gender;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Actor_Gender states a value of AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_GEN_Actor_Gender (
    p_owner IN AC_GEN_Actor_Gender_Posit.AC_GEN_AC_ID%TYPE,
    p_value IN AC_GEN_Actor_Gender_Posit.AC_GEN_GEN_ID%TYPE,
    p_positing IN AC_GEN_Actor_Gender_Annex.AC_GEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN AC_GEN_Actor_Gender_Annex.AC_GEN_Reliability%TYPE DEFAULT NULL,
    p_metadata IN AC_GEN_Actor_Gender_Annex.Metadata_AC_GEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit AC_GEN_Actor_Gender_Posit.AC_GEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN AC_GEN_Actor_Gender_Posit.AC_GEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO AC_GEN_Actor_Gender_Annex (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    AC_GEN_Actor_Gender_Annex x
                WHERE
                    x.AC_GEN_ID = p_id
                AND
                    x.AC_GEN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            AC_GEN_Actor_Gender_Posit p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_GEN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_GEN_Actor_Gender_Annex a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_GEN_Actor_Gender_Posit p
        JOIN
            AC_GEN_Actor_Gender_Annex a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_GEN_Actor_Gender_Annex a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_AC_GEN_Actor_Gender(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO AC_GEN_Actor_Gender_Annex (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            AC_GEN_Actor_Gender_Posit p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            COALESCE(he_AC_GEN_Actor_Gender(p.AC_GEN_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.AC_GEN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO AC_GEN_Actor_Gender_Posit (
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING AC_GEN_ID INTO v_posit;
    END IF;
    INSERT INTO AC_GEN_Actor_Gender_Annex (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_AC_GEN_Actor_Gender;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Actor_Gender instead of INSERT trigger on AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_AC_GEN_Actor_Gender
INSTEAD OF INSERT ON AC_GEN_Actor_Gender
FOR EACH ROW
BEGIN
    ip_AC_GEN_Actor_Gender(
        p_owner => :NEW.AC_GEN_AC_ID,
        p_value => :NEW.AC_GEN_GEN_ID,
        p_positing => :NEW.AC_GEN_PositedAt,
        p_reliability => :NEW.AC_GEN_Reliability,
        p_metadata => :NEW.Metadata_AC_GEN
    );
END it_AC_GEN_Actor_Gender;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_PLV_Actor_ProfessionalLevel tells whether two values of AC_PLV_Actor_ProfessionalLevel are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_AC_PLV_Actor_ProfessionalLevel (
    p_left IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_PLV_ID%TYPE,
    p_right IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_PLV_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_PLV_Actor_ProfessionalLevel;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_PLV_Actor_ProfessionalLevel is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_AC_PLV_Actor_ProfessionalLevel (
    p_id IN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_ID%TYPE,
    p_positing IN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_PositedAt%TYPE
) RETURN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_PLV_Reliability
        FROM
            AC_PLV_Actor_ProfessionalLevel_Annex a
        WHERE
            a.AC_PLV_ID = p_id
        AND
            a.AC_PLV_PositedAt <= p_positing
        ORDER BY
            a.AC_PLV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_PLV_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_PLV_Actor_ProfessionalLevel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Actor_ProfessionalLevel states a value of AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_PLV_Actor_ProfessionalLevel (
    p_owner IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_AC_ID%TYPE,
    p_value IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_PLV_ID%TYPE,
    p_changing IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_Reliability%TYPE DEFAULT NULL,
    p_metadata IN AC_PLV_Actor_ProfessionalLevel_Annex.Metadata_AC_PLV%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO AC_PLV_Actor_ProfessionalLevel_Annex (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    AC_PLV_Actor_ProfessionalLevel_Annex x
                WHERE
                    x.AC_PLV_ID = p_id
                AND
                    x.AC_PLV_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
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
            AC_PLV_Actor_ProfessionalLevel_Posit p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_PLV_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_PLV_Actor_ProfessionalLevel_Annex a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_PLV_Actor_ProfessionalLevel_Posit p
        JOIN
            AC_PLV_Actor_ProfessionalLevel_Annex a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_PLV_Actor_ProfessionalLevel_Annex a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_AC_PLV_Actor_ProfessionalLevel(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO AC_PLV_Actor_ProfessionalLevel_Annex (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.AC_PLV_ID
        FROM
            AC_PLV_Actor_ProfessionalLevel_Posit p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            COALESCE(he_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.AC_PLV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO AC_PLV_Actor_ProfessionalLevel_Posit (
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
    INSERT INTO AC_PLV_Actor_ProfessionalLevel_Annex (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_AC_PLV_Actor_ProfessionalLevel;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel instead of INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_AC_PLV_Actor_ProfessionalLevel
INSTEAD OF INSERT ON AC_PLV_Actor_ProfessionalLevel
FOR EACH ROW
BEGIN
    ip_AC_PLV_Actor_ProfessionalLevel(
        p_owner => :NEW.AC_PLV_AC_ID,
        p_value => :NEW.AC_PLV_PLV_ID,
        p_changing => :NEW.AC_PLV_ChangedAt,
        p_positing => :NEW.AC_PLV_PositedAt,
        p_reliability => :NEW.AC_PLV_Reliability,
        p_metadata => :NEW.Metadata_AC_PLV
    );
END it_AC_PLV_Actor_ProfessionalLevel;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_NAM_Program_Name tells whether two values of PR_NAM_Program_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_PR_NAM_Program_Name (
    p_left IN PR_NAM_Program_Name_Posit.PR_NAM_Program_Name%TYPE,
    p_right IN PR_NAM_Program_Name_Posit.PR_NAM_Program_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_PR_NAM_Program_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_NAM_Program_Name is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_PR_NAM_Program_Name (
    p_id IN PR_NAM_Program_Name_Annex.PR_NAM_ID%TYPE,
    p_positing IN PR_NAM_Program_Name_Annex.PR_NAM_PositedAt%TYPE
) RETURN PR_NAM_Program_Name_Annex.PR_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_NAM_Reliability
        FROM
            PR_NAM_Program_Name_Annex a
        WHERE
            a.PR_NAM_ID = p_id
        AND
            a.PR_NAM_PositedAt <= p_positing
        ORDER BY
            a.PR_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_PR_NAM_Program_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Program_Name states a value of PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_PR_NAM_Program_Name (
    p_owner IN PR_NAM_Program_Name_Posit.PR_NAM_PR_ID%TYPE,
    p_value IN PR_NAM_Program_Name_Posit.PR_NAM_Program_Name%TYPE,
    p_positing IN PR_NAM_Program_Name_Annex.PR_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN PR_NAM_Program_Name_Annex.PR_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN PR_NAM_Program_Name_Annex.Metadata_PR_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit PR_NAM_Program_Name_Posit.PR_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN PR_NAM_Program_Name_Posit.PR_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO PR_NAM_Program_Name_Annex (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    PR_NAM_Program_Name_Annex x
                WHERE
                    x.PR_NAM_ID = p_id
                AND
                    x.PR_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            PR_NAM_Program_Name_Posit p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_NAM_Program_Name_Annex a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_NAM_Program_Name_Posit p
        JOIN
            PR_NAM_Program_Name_Annex a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 0
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_NAM_Program_Name_Annex a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_PR_NAM_Program_Name(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO PR_NAM_Program_Name_Annex (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            PR_NAM_Program_Name_Posit p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 0
        AND
            COALESCE(he_PR_NAM_Program_Name(p.PR_NAM_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.PR_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO PR_NAM_Program_Name_Posit (
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING PR_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO PR_NAM_Program_Name_Annex (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_PR_NAM_Program_Name;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Program_Name instead of INSERT trigger on PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_PR_NAM_Program_Name
INSTEAD OF INSERT ON PR_NAM_Program_Name
FOR EACH ROW
BEGIN
    ip_PR_NAM_Program_Name(
        p_owner => :NEW.PR_NAM_PR_ID,
        p_value => :NEW.PR_NAM_Program_Name,
        p_positing => :NEW.PR_NAM_PositedAt,
        p_reliability => :NEW.PR_NAM_Reliability,
        p_metadata => :NEW.Metadata_PR_NAM
    );
END it_PR_NAM_Program_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_LEN_Program_Length tells whether two values of PR_LEN_Program_Length are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_PR_LEN_Program_Length (
    p_left IN PR_LEN_Program_Length_Posit.PR_LEN_Program_Length%TYPE,
    p_right IN PR_LEN_Program_Length_Posit.PR_LEN_Program_Length%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_PR_LEN_Program_Length;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_LEN_Program_Length is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_PR_LEN_Program_Length (
    p_id IN PR_LEN_Program_Length_Annex.PR_LEN_ID%TYPE,
    p_positing IN PR_LEN_Program_Length_Annex.PR_LEN_PositedAt%TYPE
) RETURN PR_LEN_Program_Length_Annex.PR_LEN_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_LEN_Reliability
        FROM
            PR_LEN_Program_Length_Annex a
        WHERE
            a.PR_LEN_ID = p_id
        AND
            a.PR_LEN_PositedAt <= p_positing
        ORDER BY
            a.PR_LEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_LEN_Reliability;
    END LOOP;
    RETURN NULL;
END he_PR_LEN_Program_Length;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Program_Length states a value of PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_PR_LEN_Program_Length (
    p_owner IN PR_LEN_Program_Length_Posit.PR_LEN_PR_ID%TYPE,
    p_value IN PR_LEN_Program_Length_Posit.PR_LEN_Program_Length%TYPE,
    p_changing IN PR_LEN_Program_Length_Posit.PR_LEN_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN PR_LEN_Program_Length_Annex.PR_LEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN PR_LEN_Program_Length_Annex.PR_LEN_Reliability%TYPE DEFAULT NULL,
    p_metadata IN PR_LEN_Program_Length_Annex.Metadata_PR_LEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing date;
    v_posit PR_LEN_Program_Length_Posit.PR_LEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN PR_LEN_Program_Length_Posit.PR_LEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO PR_LEN_Program_Length_Annex (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    PR_LEN_Program_Length_Annex x
                WHERE
                    x.PR_LEN_ID = p_id
                AND
                    x.PR_LEN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
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
            PR_LEN_Program_Length_Posit p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_LEN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_LEN_Program_Length_Annex a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_LEN_Program_Length_Posit p
        JOIN
            PR_LEN_Program_Length_Annex a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 0
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_LEN_Program_Length_Annex a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(he_PR_LEN_Program_Length(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO PR_LEN_Program_Length_Annex (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.PR_LEN_ID
        FROM
            PR_LEN_Program_Length_Posit p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 0
        AND
            COALESCE(he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.PR_LEN_ID);
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.PR_LEN_Program_Length
        FROM
            PR_LEN_Program_Length_Posit p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt < v_changing
        AND
            COALESCE(he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positing), 0) = 1
        ORDER BY
            p.PR_LEN_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_PR_LEN_Program_Length(r.PR_LEN_Program_Length, p_value) = 1 THEN
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
            PR_LEN_Program_Length_Posit f
        WHERE
            f.PR_LEN_PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > v_changing
        AND
            COALESCE(he_PR_LEN_Program_Length(f.PR_LEN_ID, v_positing), 0) = 1
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_PR_LEN_Program_Length(r.PR_LEN_Program_Length, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.PR_LEN_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO PR_LEN_Program_Length_Posit (
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
    INSERT INTO PR_LEN_Program_Length_Annex (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_PR_LEN_Program_Length;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Program_Length instead of INSERT trigger on PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_PR_LEN_Program_Length
INSTEAD OF INSERT ON PR_LEN_Program_Length
FOR EACH ROW
BEGIN
    ip_PR_LEN_Program_Length(
        p_owner => :NEW.PR_LEN_PR_ID,
        p_value => :NEW.PR_LEN_Program_Length,
        p_changing => :NEW.PR_LEN_ChangedAt,
        p_positing => :NEW.PR_LEN_PositedAt,
        p_reliability => :NEW.PR_LEN_Reliability,
        p_metadata => :NEW.Metadata_PR_LEN
    );
END it_PR_LEN_Program_Length;
/
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the posit and annex tables of the attributes in a consistent way,
-- through the insert procedures of the attributes (ip_<attribute>, see the attribute triggers, which keep the posit and
-- annex tables). Default values are used for some columns if not provided by the corresponding SQL statements: the changing
-- and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the insert procedures of the attributes see to that).
--
-- Bitemporal modeling is decisive: one posit at a time is asserted for an entity (and a changing time), so an assertion of
-- another value corrects, at its own positing time, the posit that is in effect (the insert procedures see to that too).
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
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_id number(10);
    v_AVG number(5);
    v_MIN number(5);
BEGIN
    v_id := :NEW.ST_ID;
    IF v_id IS NULL THEN
        INSERT INTO ST_Stage (
            Metadata_ST
        )
        VALUES (
            :NEW.Metadata_ST
        )
        RETURNING ST_ID INTO v_id;
    END IF;
    IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
        ip_ST_NAM_Stage_Name(
            p_owner => COALESCE(:NEW.ST_NAM_ST_ID, v_id),
            p_value => :NEW.ST_NAM_Stage_Name,
            p_changing => COALESCE(:NEW.ST_NAM_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.ST_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_NAM_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_NAM, :NEW.Metadata_ST)
        );
    END IF;
    IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
        ip_ST_LOC_Stage_Location(
            p_owner => COALESCE(:NEW.ST_LOC_ST_ID, v_id),
            p_value => :NEW.ST_LOC_Stage_Location,
            p_positing => COALESCE(:NEW.ST_LOC_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_LOC_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_LOC, :NEW.Metadata_ST)
        );
    END IF;
    v_AVG := :NEW.ST_AVG_UTL_ID;
    IF v_AVG IS NULL AND :NEW.ST_AVG_UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.ST_AVG_UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_AVG := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_AVG IS NOT NULL THEN
        ip_ST_AVG_Stage_Average(
            p_owner => COALESCE(:NEW.ST_AVG_ST_ID, v_id),
            p_value => v_AVG,
            p_changing => COALESCE(:NEW.ST_AVG_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.ST_AVG_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_AVG_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_AVG, :NEW.Metadata_ST)
        );
    END IF;
    v_MIN := :NEW.ST_MIN_UTL_ID;
    IF v_MIN IS NULL AND :NEW.ST_MIN_UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.ST_MIN_UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_MIN := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_MIN IS NOT NULL THEN
        ip_ST_MIN_Stage_Minimum(
            p_owner => COALESCE(:NEW.ST_MIN_ST_ID, v_id),
            p_value => v_MIN,
            p_positing => COALESCE(:NEW.ST_MIN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_MIN_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_MIN, :NEW.Metadata_ST)
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
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_NAM_changing timestamp;
    v_AVG number(5);
    v_AVG_changing timestamp;
    v_MIN number(5);
BEGIN
    IF (:NEW.ST_ID <> :OLD.ST_ID
        OR (:NEW.ST_ID IS NULL AND :OLD.ST_ID IS NOT NULL)
        OR (:NEW.ST_ID IS NOT NULL AND :OLD.ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
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
    v_reliability_diff := CASE WHEN (:NEW.ST_NAM_Reliability <> :OLD.ST_NAM_Reliability
        OR (:NEW.ST_NAM_Reliability IS NULL AND :OLD.ST_NAM_Reliability IS NOT NULL)
        OR (:NEW.ST_NAM_Reliability IS NOT NULL AND :OLD.ST_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_NAM_Reliability;
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
            OR :OLD.ST_NAM_Reliability IS NULL
            OR :OLD.ST_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_ST_NAM_Stage_Name(
                    p_owner => COALESCE(:NEW.ST_NAM_ST_ID, :NEW.ST_ID),
                    p_value => :NEW.ST_NAM_Stage_Name,
                    p_changing => v_NAM_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.ST_NAM_Stage_Name IS NULL AND :OLD.ST_NAM_Stage_Name IS NOT NULL THEN
            ip_ST_NAM_Stage_Name(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_NAM_Stage_Name,
                p_changing => :OLD.ST_NAM_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
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
    v_reliability_diff := CASE WHEN (:NEW.ST_LOC_Reliability <> :OLD.ST_LOC_Reliability
        OR (:NEW.ST_LOC_Reliability IS NULL AND :OLD.ST_LOC_Reliability IS NOT NULL)
        OR (:NEW.ST_LOC_Reliability IS NOT NULL AND :OLD.ST_LOC_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_LOC_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_LOC_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_LOC_PositedAt <> :OLD.ST_LOC_PositedAt
        OR (:NEW.ST_LOC_PositedAt IS NULL AND :OLD.ST_LOC_PositedAt IS NOT NULL)
        OR (:NEW.ST_LOC_PositedAt IS NOT NULL AND :OLD.ST_LOC_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_LOC_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN ((:NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL)
        OR (:NEW.ST_LOC_Stage_Location IS NOT NULL AND :OLD.ST_LOC_Stage_Location IS NULL)
        OR (:NEW.ST_LOC_Stage_Location IS NOT NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL
            AND DBMS_LOB.COMPARE(:NEW.ST_LOC_Stage_Location, :OLD.ST_LOC_Stage_Location) <> 0)) THEN TRUE ELSE FALSE END;
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
            OR :OLD.ST_LOC_Reliability IS NULL
            OR :OLD.ST_LOC_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_ST_LOC_Stage_Location(
                    p_owner => COALESCE(:NEW.ST_LOC_ST_ID, :NEW.ST_ID),
                    p_value => :NEW.ST_LOC_Stage_Location,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL THEN
            ip_ST_LOC_Stage_Location(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_LOC_Stage_Location,
                p_positing => v_positing,
                p_reliability => 0,
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
    v_reliability_diff := CASE WHEN (:NEW.ST_AVG_Reliability <> :OLD.ST_AVG_Reliability
        OR (:NEW.ST_AVG_Reliability IS NULL AND :OLD.ST_AVG_Reliability IS NOT NULL)
        OR (:NEW.ST_AVG_Reliability IS NOT NULL AND :OLD.ST_AVG_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_AVG_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_AVG_Reliability;
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
                    UTL_Utilization k
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
            OR :OLD.ST_AVG_Reliability IS NULL
            OR :OLD.ST_AVG_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.ST_AVG_UTL_ID <> v_AVG
            THEN
                ip_ST_AVG_Stage_Average(
                    p_owner => COALESCE(:NEW.ST_AVG_ST_ID, :NEW.ST_ID),
                    p_value => v_AVG,
                    p_changing => v_AVG_changing,
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
            ip_ST_AVG_Stage_Average(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_AVG_UTL_ID,
                p_changing => :OLD.ST_AVG_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
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
    v_reliability_diff := CASE WHEN (:NEW.ST_MIN_Reliability <> :OLD.ST_MIN_Reliability
        OR (:NEW.ST_MIN_Reliability IS NULL AND :OLD.ST_MIN_Reliability IS NOT NULL)
        OR (:NEW.ST_MIN_Reliability IS NOT NULL AND :OLD.ST_MIN_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_MIN_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_MIN_Reliability;
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
                    UTL_Utilization k
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
            OR :OLD.ST_MIN_Reliability IS NULL
            OR :OLD.ST_MIN_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.ST_MIN_UTL_ID <> v_MIN
            THEN
                ip_ST_MIN_Stage_Minimum(
                    p_owner => COALESCE(:NEW.ST_MIN_ST_ID, :NEW.ST_ID),
                    p_value => v_MIN,
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
            ip_ST_MIN_Stage_Minimum(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_MIN_UTL_ID,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lST_Stage;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lST_Stage
INSTEAD OF DELETE ON lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown of ST_NAM_Stage_Name is retracted
    INSERT INTO ST_NAM_Stage_Name_Annex (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        :OLD.Metadata_ST_NAM,
        :OLD.ST_NAM_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                ST_NAM_Stage_Name_Annex x
            WHERE
                x.ST_NAM_ID = :OLD.ST_NAM_ID
            AND
                x.ST_NAM_PositedAt = v_now
        );
    -- what is shown of ST_LOC_Stage_Location is retracted
    INSERT INTO ST_LOC_Stage_Location_Annex (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        :OLD.Metadata_ST_LOC,
        :OLD.ST_LOC_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_LOC_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                ST_LOC_Stage_Location_Annex x
            WHERE
                x.ST_LOC_ID = :OLD.ST_LOC_ID
            AND
                x.ST_LOC_PositedAt = v_now
        );
    -- what is shown of ST_AVG_Stage_Average is retracted
    INSERT INTO ST_AVG_Stage_Average_Annex (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        :OLD.Metadata_ST_AVG,
        :OLD.ST_AVG_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_AVG_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                ST_AVG_Stage_Average_Annex x
            WHERE
                x.ST_AVG_ID = :OLD.ST_AVG_ID
            AND
                x.ST_AVG_PositedAt = v_now
        );
    -- what is shown of ST_MIN_Stage_Minimum is retracted
    INSERT INTO ST_MIN_Stage_Minimum_Annex (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        :OLD.Metadata_ST_MIN,
        :OLD.ST_MIN_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_MIN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                ST_MIN_Stage_Minimum_Annex x
            WHERE
                x.ST_MIN_ID = :OLD.ST_MIN_ID
            AND
                x.ST_MIN_PositedAt = v_now
        );
END dt_lST_Stage;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_Actor
INSTEAD OF INSERT ON lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_id number(10);
    v_GEN number(5);
    v_PLV number(5);
BEGIN
    v_id := :NEW.AC_ID;
    IF v_id IS NULL THEN
        INSERT INTO AC_Actor (
            Metadata_AC
        )
        VALUES (
            :NEW.Metadata_AC
        )
        RETURNING AC_ID INTO v_id;
    END IF;
    IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
        ip_AC_NAM_Actor_Name(
            p_owner => COALESCE(:NEW.AC_NAM_AC_ID, v_id),
            p_value => :NEW.AC_NAM_Actor_Name,
            p_changing => COALESCE(:NEW.AC_NAM_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.AC_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_NAM_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_AC_NAM, :NEW.Metadata_AC)
        );
    END IF;
    v_GEN := :NEW.AC_GEN_GEN_ID;
    IF v_GEN IS NULL AND :NEW.AC_GEN_GEN_Gender IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GEN_ID
            FROM
                GEN_Gender k
            WHERE
                k.GEN_Gender = :NEW.AC_GEN_GEN_Gender
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GEN := kv.GEN_ID;
        END LOOP;
    END IF;
    IF v_GEN IS NOT NULL THEN
        ip_AC_GEN_Actor_Gender(
            p_owner => COALESCE(:NEW.AC_GEN_AC_ID, v_id),
            p_value => v_GEN,
            p_positing => COALESCE(:NEW.AC_GEN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_GEN_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_AC_GEN, :NEW.Metadata_AC)
        );
    END IF;
    v_PLV := :NEW.AC_PLV_PLV_ID;
    IF v_PLV IS NULL AND :NEW.AC_PLV_PLV_ProfessionalLevel IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                PLV_ProfessionalLevel k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.AC_PLV_PLV_ProfessionalLevel, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PLV := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_PLV IS NOT NULL THEN
        ip_AC_PLV_Actor_ProfessionalLevel(
            p_owner => COALESCE(:NEW.AC_PLV_AC_ID, v_id),
            p_value => v_PLV,
            p_changing => COALESCE(:NEW.AC_PLV_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.AC_PLV_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_PLV_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_AC_PLV, :NEW.Metadata_AC)
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
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_NAM_changing timestamp;
    v_GEN number(5);
    v_PLV number(5);
    v_PLV_changing timestamp;
BEGIN
    IF (:NEW.AC_ID <> :OLD.AC_ID
        OR (:NEW.AC_ID IS NULL AND :OLD.AC_ID IS NOT NULL)
        OR (:NEW.AC_ID IS NOT NULL AND :OLD.AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
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
    v_reliability_diff := CASE WHEN (:NEW.AC_NAM_Reliability <> :OLD.AC_NAM_Reliability
        OR (:NEW.AC_NAM_Reliability IS NULL AND :OLD.AC_NAM_Reliability IS NOT NULL)
        OR (:NEW.AC_NAM_Reliability IS NOT NULL AND :OLD.AC_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.AC_NAM_Reliability;
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
            OR :OLD.AC_NAM_Reliability IS NULL
            OR :OLD.AC_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_AC_NAM_Actor_Name(
                    p_owner => COALESCE(:NEW.AC_NAM_AC_ID, :NEW.AC_ID),
                    p_value => :NEW.AC_NAM_Actor_Name,
                    p_changing => v_NAM_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.AC_NAM_Actor_Name IS NULL AND :OLD.AC_NAM_Actor_Name IS NOT NULL THEN
            ip_AC_NAM_Actor_Name(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_NAM_Actor_Name,
                p_changing => :OLD.AC_NAM_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
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
    v_reliability_diff := CASE WHEN (:NEW.AC_GEN_Reliability <> :OLD.AC_GEN_Reliability
        OR (:NEW.AC_GEN_Reliability IS NULL AND :OLD.AC_GEN_Reliability IS NOT NULL)
        OR (:NEW.AC_GEN_Reliability IS NOT NULL AND :OLD.AC_GEN_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_GEN_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.AC_GEN_Reliability;
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
                    GEN_Gender k
                WHERE
                    k.GEN_Gender = :NEW.AC_GEN_GEN_Gender
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
            OR :OLD.AC_GEN_Reliability IS NULL
            OR :OLD.AC_GEN_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.AC_GEN_GEN_ID <> v_GEN
            THEN
                ip_AC_GEN_Actor_Gender(
                    p_owner => COALESCE(:NEW.AC_GEN_AC_ID, :NEW.AC_ID),
                    p_value => v_GEN,
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
            ip_AC_GEN_Actor_Gender(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_GEN_GEN_ID,
                p_positing => v_positing,
                p_reliability => 0,
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
    v_reliability_diff := CASE WHEN (:NEW.AC_PLV_Reliability <> :OLD.AC_PLV_Reliability
        OR (:NEW.AC_PLV_Reliability IS NULL AND :OLD.AC_PLV_Reliability IS NOT NULL)
        OR (:NEW.AC_PLV_Reliability IS NOT NULL AND :OLD.AC_PLV_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_PLV_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.AC_PLV_Reliability;
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
                    PLV_ProfessionalLevel k
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
            OR :OLD.AC_PLV_Reliability IS NULL
            OR :OLD.AC_PLV_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.AC_PLV_PLV_ID <> v_PLV
            THEN
                ip_AC_PLV_Actor_ProfessionalLevel(
                    p_owner => COALESCE(:NEW.AC_PLV_AC_ID, :NEW.AC_ID),
                    p_value => v_PLV,
                    p_changing => v_PLV_changing,
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
            ip_AC_PLV_Actor_ProfessionalLevel(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_PLV_PLV_ID,
                p_changing => :OLD.AC_PLV_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
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
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown of AC_NAM_Actor_Name is retracted
    INSERT INTO AC_NAM_Actor_Name_Annex (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        :OLD.Metadata_AC_NAM,
        :OLD.AC_NAM_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                AC_NAM_Actor_Name_Annex x
            WHERE
                x.AC_NAM_ID = :OLD.AC_NAM_ID
            AND
                x.AC_NAM_PositedAt = v_now
        );
    -- what is shown of AC_GEN_Actor_Gender is retracted
    INSERT INTO AC_GEN_Actor_Gender_Annex (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        :OLD.Metadata_AC_GEN,
        :OLD.AC_GEN_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_GEN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                AC_GEN_Actor_Gender_Annex x
            WHERE
                x.AC_GEN_ID = :OLD.AC_GEN_ID
            AND
                x.AC_GEN_PositedAt = v_now
        );
    -- what is shown of AC_PLV_Actor_ProfessionalLevel is retracted
    INSERT INTO AC_PLV_Actor_ProfessionalLevel_Annex (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        :OLD.Metadata_AC_PLV,
        :OLD.AC_PLV_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_PLV_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                AC_PLV_Actor_ProfessionalLevel_Annex x
            WHERE
                x.AC_PLV_ID = :OLD.AC_PLV_ID
            AND
                x.AC_PLV_PositedAt = v_now
        );
END dt_lAC_Actor;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lPR_Program
INSTEAD OF INSERT ON lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_id number(10);
BEGIN
    v_id := :NEW.PR_ID;
    IF v_id IS NULL THEN
        INSERT INTO PR_Program (
            Metadata_PR
        )
        VALUES (
            :NEW.Metadata_PR
        )
        RETURNING PR_ID INTO v_id;
    END IF;
    IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
        ip_PR_NAM_Program_Name(
            p_owner => COALESCE(:NEW.PR_NAM_PR_ID, v_id),
            p_value => :NEW.PR_NAM_Program_Name,
            p_positing => COALESCE(:NEW.PR_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.PR_NAM_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_PR_NAM, :NEW.Metadata_PR)
        );
    END IF;
    IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
        ip_PR_LEN_Program_Length(
            p_owner => COALESCE(:NEW.PR_LEN_PR_ID, v_id),
            p_value => :NEW.PR_LEN_Program_Length,
            p_changing => COALESCE(:NEW.PR_LEN_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.PR_LEN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.PR_LEN_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_PR_LEN, :NEW.Metadata_PR)
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
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
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
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
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
    v_reliability_diff := CASE WHEN (:NEW.PR_NAM_Reliability <> :OLD.PR_NAM_Reliability
        OR (:NEW.PR_NAM_Reliability IS NULL AND :OLD.PR_NAM_Reliability IS NOT NULL)
        OR (:NEW.PR_NAM_Reliability IS NOT NULL AND :OLD.PR_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.PR_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.PR_NAM_Reliability;
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
            OR :OLD.PR_NAM_Reliability IS NULL
            OR :OLD.PR_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_PR_NAM_Program_Name(
                    p_owner => COALESCE(:NEW.PR_NAM_PR_ID, :NEW.PR_ID),
                    p_value => :NEW.PR_NAM_Program_Name,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.PR_NAM_Program_Name IS NULL AND :OLD.PR_NAM_Program_Name IS NOT NULL THEN
            ip_PR_NAM_Program_Name(
                p_owner => :OLD.PR_ID,
                p_value => :OLD.PR_NAM_Program_Name,
                p_positing => v_positing,
                p_reliability => 0,
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
    v_reliability_diff := CASE WHEN (:NEW.PR_LEN_Reliability <> :OLD.PR_LEN_Reliability
        OR (:NEW.PR_LEN_Reliability IS NULL AND :OLD.PR_LEN_Reliability IS NOT NULL)
        OR (:NEW.PR_LEN_Reliability IS NOT NULL AND :OLD.PR_LEN_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.PR_LEN_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.PR_LEN_Reliability;
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
            OR :OLD.PR_LEN_Reliability IS NULL
            OR :OLD.PR_LEN_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_PR_LEN_Program_Length(
                    p_owner => COALESCE(:NEW.PR_LEN_PR_ID, :NEW.PR_ID),
                    p_value => :NEW.PR_LEN_Program_Length,
                    p_changing => v_LEN_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.PR_LEN_Program_Length IS NULL AND :OLD.PR_LEN_Program_Length IS NOT NULL THEN
            ip_PR_LEN_Program_Length(
                p_owner => :OLD.PR_ID,
                p_value => :OLD.PR_LEN_Program_Length,
                p_changing => :OLD.PR_LEN_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
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
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown of PR_NAM_Program_Name is retracted
    INSERT INTO PR_NAM_Program_Name_Annex (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        :OLD.Metadata_PR_NAM,
        :OLD.PR_NAM_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.PR_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                PR_NAM_Program_Name_Annex x
            WHERE
                x.PR_NAM_ID = :OLD.PR_NAM_ID
            AND
                x.PR_NAM_PositedAt = v_now
        );
    -- what is shown of PR_LEN_Program_Length is retracted
    INSERT INTO PR_LEN_Program_Length_Annex (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        :OLD.Metadata_PR_LEN,
        :OLD.PR_LEN_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.PR_LEN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                PR_LEN_Program_Length_Annex x
            WHERE
                x.PR_LEN_ID = :OLD.PR_LEN_ID
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
-- annex tables). Default values are used for some columns if not provided by the corresponding SQL statements: the
-- changing and positing times are now, the reliability is 1.
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
CREATE OR REPLACE TRIGGER it_lEV_Event
INSTEAD OF INSERT ON lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_id number(10);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        INSERT INTO EV_Event (
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
        ip_EV_DAT_Event_Date(
            p_owner => COALESCE(:NEW.EV_DAT_EV_ID, v_id),
            p_value => :NEW.EV_DAT_Event_Date,
            p_positing => COALESCE(:NEW.EV_DAT_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_DAT_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_DAT, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
        ip_EV_AUD_Event_Audience(
            p_owner => COALESCE(:NEW.EV_AUD_EV_ID, v_id),
            p_value => :NEW.EV_AUD_Event_Audience,
            p_positing => COALESCE(:NEW.EV_AUD_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_AUD_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_AUD, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
        ip_EV_REV_Event_Revenue(
            p_owner => COALESCE(:NEW.EV_REV_EV_ID, v_id),
            p_value => :NEW.EV_REV_Event_Revenue,
            p_positing => COALESCE(:NEW.EV_REV_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_REV_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_REV, :NEW.Metadata_EV)
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
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_nexus_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
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
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
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
    v_reliability_diff := CASE WHEN (:NEW.EV_DAT_Reliability <> :OLD.EV_DAT_Reliability
        OR (:NEW.EV_DAT_Reliability IS NULL AND :OLD.EV_DAT_Reliability IS NOT NULL)
        OR (:NEW.EV_DAT_Reliability IS NOT NULL AND :OLD.EV_DAT_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_DAT_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_DAT_Reliability;
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
            OR :OLD.EV_DAT_Reliability IS NULL
            OR :OLD.EV_DAT_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_EV_DAT_Event_Date(
                    p_owner => COALESCE(:NEW.EV_DAT_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_DAT_Event_Date,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null: the shown posit is retracted at the positing time
        IF :NEW.EV_DAT_Event_Date IS NULL AND :OLD.EV_DAT_Event_Date IS NOT NULL THEN
            FOR p IN (
                SELECT
                    x.EV_DAT_EV_ID,
                    x.EV_DAT_Event_Date
                FROM
                    EV_DAT_Event_Date_Posit x
                WHERE
                    x.EV_DAT_ID = :OLD.EV_DAT_ID
            ) LOOP
                ip_EV_DAT_Event_Date(
                    p_owner => p.EV_DAT_EV_ID,
                    p_value => p.EV_DAT_Event_Date,
                    p_positing => v_positing,
                    p_reliability => 0,
                    p_metadata => v_metadata
                );
            END LOOP;
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
    v_reliability_diff := CASE WHEN (:NEW.EV_AUD_Reliability <> :OLD.EV_AUD_Reliability
        OR (:NEW.EV_AUD_Reliability IS NULL AND :OLD.EV_AUD_Reliability IS NOT NULL)
        OR (:NEW.EV_AUD_Reliability IS NOT NULL AND :OLD.EV_AUD_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_AUD_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_AUD_Reliability;
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
            OR :OLD.EV_AUD_Reliability IS NULL
            OR :OLD.EV_AUD_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_EV_AUD_Event_Audience(
                    p_owner => COALESCE(:NEW.EV_AUD_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_AUD_Event_Audience,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null: the shown posit is retracted at the positing time
        IF :NEW.EV_AUD_Event_Audience IS NULL AND :OLD.EV_AUD_Event_Audience IS NOT NULL THEN
            FOR p IN (
                SELECT
                    x.EV_AUD_EV_ID,
                    x.EV_AUD_Event_Audience
                FROM
                    EV_AUD_Event_Audience_Posit x
                WHERE
                    x.EV_AUD_ID = :OLD.EV_AUD_ID
            ) LOOP
                ip_EV_AUD_Event_Audience(
                    p_owner => p.EV_AUD_EV_ID,
                    p_value => p.EV_AUD_Event_Audience,
                    p_positing => v_positing,
                    p_reliability => 0,
                    p_metadata => v_metadata
                );
            END LOOP;
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
    v_reliability_diff := CASE WHEN (:NEW.EV_REV_Reliability <> :OLD.EV_REV_Reliability
        OR (:NEW.EV_REV_Reliability IS NULL AND :OLD.EV_REV_Reliability IS NOT NULL)
        OR (:NEW.EV_REV_Reliability IS NOT NULL AND :OLD.EV_REV_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_REV_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_REV_Reliability;
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
            OR :OLD.EV_REV_Reliability IS NULL
            OR :OLD.EV_REV_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_EV_REV_Event_Revenue(
                    p_owner => COALESCE(:NEW.EV_REV_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_REV_Event_Revenue,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null: the shown posit is retracted at the positing time
        IF :NEW.EV_REV_Event_Revenue IS NULL AND :OLD.EV_REV_Event_Revenue IS NOT NULL THEN
            FOR p IN (
                SELECT
                    x.EV_REV_EV_ID,
                    x.EV_REV_Event_Revenue
                FROM
                    EV_REV_Event_Revenue_Posit x
                WHERE
                    x.EV_REV_ID = :OLD.EV_REV_ID
            ) LOOP
                ip_EV_REV_Event_Revenue(
                    p_owner => p.EV_REV_EV_ID,
                    p_value => p.EV_REV_Event_Revenue,
                    p_positing => v_positing,
                    p_reliability => 0,
                    p_metadata => v_metadata
                );
            END LOOP;
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
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown of EV_DAT_Event_Date is retracted
    INSERT INTO EV_DAT_Event_Date_Annex (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        :OLD.Metadata_EV_DAT,
        :OLD.EV_DAT_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_DAT_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_DAT_Event_Date_Annex x
            WHERE
                x.EV_DAT_ID = :OLD.EV_DAT_ID
            AND
                x.EV_DAT_PositedAt = v_now
        );
    -- what is shown of EV_AUD_Event_Audience is retracted
    INSERT INTO EV_AUD_Event_Audience_Annex (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        :OLD.Metadata_EV_AUD,
        :OLD.EV_AUD_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_AUD_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_AUD_Event_Audience_Annex x
            WHERE
                x.EV_AUD_ID = :OLD.EV_AUD_ID
            AND
                x.EV_AUD_PositedAt = v_now
        );
    -- what is shown of EV_REV_Event_Revenue is retracted
    INSERT INTO EV_REV_Event_Revenue_Annex (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        :OLD.Metadata_EV_REV,
        :OLD.EV_REV_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_REV_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_REV_Event_Revenue_Annex x
            WHERE
                x.EV_REV_ID = :OLD.EV_REV_ID
            AND
                x.EV_REV_PositedAt = v_now
        );
END dt_lEV_Event;
/
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled and latest views make them behave like tables.
-- The assembled view has an 'instead of' trigger for insert, which keeps the posit and annex tables. The latest view has
-- three: insert, update, and delete. They propagate such operations to the assembled view in a consistent way. Default
-- values are used for some columns if not provided by the corresponding SQL statements: the changing and positing times
-- are now, the reliability is 1.
--
-- The rules are the ones of the attributes (see the attribute triggers). A tie that has identifiers and other roles, which
-- are its values, is decisive about the values of the identifiers (at a changing time): an assertion of other values retracts,
-- at its own positing time, the posit that is in effect, which is a correction.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- The rules are in procedures, ip_<tie>, and not in triggers on the posit and annex tables, since Oracle does not let a
-- row trigger read the table it is on (ORA-04091), which these rules do. The triggers on the views call them, and so can
-- a load, with the roles and what else is to be stated (what is left out gets its default: the changing and positing times
-- are now, the reliability is 1):
--
--     BEGIN
--         ip_<tie>(
--             p_<role> => ...,                  one for each role, the identity of the entity or knot
--             p_changing => ...,                a historized tie
--             p_positing => ..., p_reliability => ...,
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
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_partner_AC_with_ONG_currently tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_AC_partner_AC_with_ONG_currently (
    p_id IN AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_ID%TYPE,
    p_positing IN AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_partner_AC_with_ONG_currently_Reliability
        FROM
            AC_partner_AC_with_ONG_currently_Annex a
        WHERE
            a.AC_partner_AC_with_ONG_currently_ID = p_id
        AND
            a.AC_partner_AC_with_ONG_currently_PositedAt <= p_positing
        ORDER BY
            a.AC_partner_AC_with_ONG_currently_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.AC_partner_AC_with_ONG_currently_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_AC_partner_AC_with_ONG_currently;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_partner_AC_with_ONG_currently states a posit of AC_partner_AC_with_ONG_currently, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_partner_AC_with_ONG_currently (
    p_AC_partner IN AC_partner_AC_with_ONG_currently_Posit.AC_ID_partner%TYPE,
    p_AC_with IN AC_partner_AC_with_ONG_currently_Posit.AC_ID_with%TYPE,
    p_ONG_currently IN AC_partner_AC_with_ONG_currently_Posit.ONG_ID_currently%TYPE,
    p_changing IN AC_partner_AC_with_ONG_currently_Posit.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Reliability%TYPE DEFAULT NULL,
    p_metadata IN AC_partner_AC_with_ONG_currently_Annex.Metadata_AC_partner_AC_with_ONG_currently%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE;
    v_reliability AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Reliability%TYPE;
    v_changing AC_partner_AC_with_ONG_currently_Posit.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_posit AC_partner_AC_with_ONG_currently_Posit.AC_partner_AC_with_ONG_currently_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO AC_partner_AC_with_ONG_currently_Annex (
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    AC_partner_AC_with_ONG_currently_Annex a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = p_id
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_partner_AC_with_ONG_currently_ID
        FROM
            AC_partner_AC_with_ONG_currently_Posit p
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    AC_partner_AC_with_ONG_currently_Annex a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = v_posit
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
                AND
                    a.AC_partner_AC_with_ONG_currently_Reliability <> v_reliability
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
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    AC_partner_AC_with_ONG_currently_Annex a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = v_posit
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
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF ie_AC_partner_AC_with_ONG_currently(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO AC_partner_AC_with_ONG_currently_Annex (
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO AC_partner_AC_with_ONG_currently_Posit (
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
    INSERT INTO AC_partner_AC_with_ONG_currently_Annex (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_partner_AC_with_ONG_currently instead of INSERT trigger on AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_AC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON AC_partner_AC_with_ONG_currently
FOR EACH ROW
BEGIN
    ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => :NEW.ONG_ID_currently,
        p_changing => :NEW.AC_partner_AC_with_ONG_currently_ChangedAt,
        p_positing => :NEW.AC_partner_AC_with_ONG_currently_PositedAt,
        p_reliability => :NEW.AC_partner_AC_with_ONG_currently_Reliability,
        p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
    );
END it_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_ONG_currently number(5);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF v_ONG_currently IS NULL AND :NEW.currently_ONG_Ongoing IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                ONG_Ongoing k
            WHERE
                k.ONG_Ongoing = :NEW.currently_ONG_Ongoing
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_ONG_currently := kv.ONG_ID;
        END LOOP;
    END IF;
    ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => v_ONG_currently,
        p_changing => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_ChangedAt, v_now),
        p_positing => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Reliability, 1),
        p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
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
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_ONG_currently number(5);
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
                    ONG_Ongoing k
                WHERE
                    k.ONG_Ongoing = :NEW.currently_ONG_Ongoing
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_ONG_currently := kv.ONG_ID;
            END LOOP;
        END IF;
    END IF;
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
        (:NEW.AC_partner_AC_with_ONG_currently_Reliability <> :OLD.AC_partner_AC_with_ONG_currently_Reliability
            OR (:NEW.AC_partner_AC_with_ONG_currently_Reliability IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_Reliability IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_Reliability IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_Reliability IS NULL))
    THEN
        IF
            :NEW.AC_ID_partner IS NOT NULL
        AND
            :NEW.AC_ID_with IS NOT NULL
        AND
            v_ONG_currently IS NOT NULL
        THEN
            ip_AC_partner_AC_with_ONG_currently(
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
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Reliability, 1),
                p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_AC_partner_AC_with_ONG_currently(
                p_AC_partner => :OLD.AC_ID_partner,
                p_AC_with => :OLD.AC_ID_with,
                p_ONG_currently => :OLD.ONG_ID_currently,
                p_changing => :OLD.AC_partner_AC_with_ONG_currently_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
            );
        END IF;
    END IF;
END ut_lAC_partner_AC_with_ONG_currently;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_partner_AC_with_ONG_currently
INSTEAD OF DELETE ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO AC_partner_AC_with_ONG_currently_Annex (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        :OLD.Metadata_AC_partner_AC_with_ONG_currently,
        :OLD.AC_partner_AC_with_ONG_currently_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_partner_AC_with_ONG_currently_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                AC_partner_AC_with_ONG_currently_Annex x
            WHERE
                x.AC_partner_AC_with_ONG_currently_ID = :OLD.AC_partner_AC_with_ONG_currently_ID
            AND
                x.AC_partner_AC_with_ONG_currently_PositedAt = v_now
        );
END dt_lAC_partner_AC_with_ONG_currently;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_subset_PN_of tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_AC_subset_PN_of (
    p_id IN AC_subset_PN_of_Annex.AC_subset_PN_of_ID%TYPE,
    p_positing IN AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_subset_PN_of_Reliability
        FROM
            AC_subset_PN_of_Annex a
        WHERE
            a.AC_subset_PN_of_ID = p_id
        AND
            a.AC_subset_PN_of_PositedAt <= p_positing
        ORDER BY
            a.AC_subset_PN_of_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.AC_subset_PN_of_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_AC_subset_PN_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_subset_PN_of states a posit of AC_subset_PN_of, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_subset_PN_of (
    p_AC_subset IN AC_subset_PN_of_Posit.AC_ID_subset%TYPE,
    p_PN_of IN AC_subset_PN_of_Posit.PN_ID_of%TYPE,
    p_positing IN AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN AC_subset_PN_of_Annex.AC_subset_PN_of_Reliability%TYPE DEFAULT NULL,
    p_metadata IN AC_subset_PN_of_Annex.Metadata_AC_subset_PN_of%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE;
    v_reliability AC_subset_PN_of_Annex.AC_subset_PN_of_Reliability%TYPE;
    v_posit AC_subset_PN_of_Posit.AC_subset_PN_of_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN AC_subset_PN_of_Annex.AC_subset_PN_of_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO AC_subset_PN_of_Annex (
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    AC_subset_PN_of_Annex a
                WHERE
                    a.AC_subset_PN_of_ID = p_id
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_subset_PN_of_ID
        FROM
            AC_subset_PN_of_Posit p
        WHERE
            p.AC_ID_subset = p_AC_subset
        AND
            p.PN_ID_of = p_PN_of
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_subset_PN_of_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    AC_subset_PN_of_Annex a
                WHERE
                    a.AC_subset_PN_of_ID = v_posit
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
                AND
                    a.AC_subset_PN_of_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_subset_PN_of for: ' ||
                p_AC_subset || ', ' ||
                p_PN_of || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    AC_subset_PN_of_Annex a
                WHERE
                    a.AC_subset_PN_of_ID = v_posit
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
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF ie_AC_subset_PN_of(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO AC_subset_PN_of_Annex (
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO AC_subset_PN_of_Posit (
            AC_ID_subset,
            PN_ID_of
        )
        VALUES (
            p_AC_subset,
            p_PN_of
        )
        RETURNING AC_subset_PN_of_ID INTO v_posit;
    END IF;
    INSERT INTO AC_subset_PN_of_Annex (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_subset_PN_of instead of INSERT trigger on AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_AC_subset_PN_of
INSTEAD OF INSERT ON AC_subset_PN_of
FOR EACH ROW
BEGIN
    ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
        p_positing => :NEW.AC_subset_PN_of_PositedAt,
        p_reliability => :NEW.AC_subset_PN_of_Reliability,
        p_metadata => :NEW.Metadata_AC_subset_PN_of
    );
END it_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_subset_PN_of
INSTEAD OF INSERT ON lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
        p_positing => COALESCE(:NEW.AC_subset_PN_of_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_subset_PN_of_Reliability, 1),
        p_metadata => :NEW.Metadata_AC_subset_PN_of
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
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
BEGIN
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
        (:NEW.AC_subset_PN_of_Reliability <> :OLD.AC_subset_PN_of_Reliability
            OR (:NEW.AC_subset_PN_of_Reliability IS NULL AND :OLD.AC_subset_PN_of_Reliability IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_Reliability IS NOT NULL AND :OLD.AC_subset_PN_of_Reliability IS NULL))
    THEN
        IF
            :NEW.AC_ID_subset IS NOT NULL
        AND
            :NEW.PN_ID_of IS NOT NULL
        THEN
            ip_AC_subset_PN_of(
                p_AC_subset => :NEW.AC_ID_subset,
                p_PN_of => :NEW.PN_ID_of,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_subset_PN_of_Reliability, 1),
                p_metadata => :NEW.Metadata_AC_subset_PN_of
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_AC_subset_PN_of(
                p_AC_subset => :OLD.AC_ID_subset,
                p_PN_of => :OLD.PN_ID_of,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_AC_subset_PN_of
            );
        END IF;
    END IF;
END ut_lAC_subset_PN_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_subset_PN_of
INSTEAD OF DELETE ON lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO AC_subset_PN_of_Annex (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        :OLD.Metadata_AC_subset_PN_of,
        :OLD.AC_subset_PN_of_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_subset_PN_of_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                AC_subset_PN_of_Annex x
            WHERE
                x.AC_subset_PN_of_ID = :OLD.AC_subset_PN_of_ID
            AND
                x.AC_subset_PN_of_PositedAt = v_now
        );
END dt_lAC_subset_PN_of;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_EV_in_AC_wasCast tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_EV_in_AC_wasCast (
    p_id IN EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_ID%TYPE,
    p_positing IN EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_in_AC_wasCast_Reliability
        FROM
            EV_in_AC_wasCast_Annex a
        WHERE
            a.EV_in_AC_wasCast_ID = p_id
        AND
            a.EV_in_AC_wasCast_PositedAt <= p_positing
        ORDER BY
            a.EV_in_AC_wasCast_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.EV_in_AC_wasCast_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_EV_in_AC_wasCast;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_in_AC_wasCast states a posit of EV_in_AC_wasCast, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_in_AC_wasCast (
    p_EV_in IN EV_in_AC_wasCast_Posit.EV_ID_in%TYPE,
    p_AC_wasCast IN EV_in_AC_wasCast_Posit.AC_ID_wasCast%TYPE,
    p_positing IN EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_in_AC_wasCast_Annex.Metadata_EV_in_AC_wasCast%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_PositedAt%TYPE;
    v_reliability EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_Reliability%TYPE;
    v_posit EV_in_AC_wasCast_Posit.EV_in_AC_wasCast_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_in_AC_wasCast_Annex (
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    EV_in_AC_wasCast_Annex a
                WHERE
                    a.EV_in_AC_wasCast_ID = p_id
                AND
                    a.EV_in_AC_wasCast_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.EV_in_AC_wasCast_ID
        FROM
            EV_in_AC_wasCast_Posit p
        WHERE
            p.EV_ID_in = p_EV_in
        AND
            p.AC_ID_wasCast = p_AC_wasCast
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_in_AC_wasCast_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    EV_in_AC_wasCast_Annex a
                WHERE
                    a.EV_in_AC_wasCast_ID = v_posit
                AND
                    a.EV_in_AC_wasCast_PositedAt = v_positing
                AND
                    a.EV_in_AC_wasCast_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_in_AC_wasCast for: ' ||
                p_EV_in || ', ' ||
                p_AC_wasCast || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    EV_in_AC_wasCast_Annex a
                WHERE
                    a.EV_in_AC_wasCast_ID = v_posit
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
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF ie_EV_in_AC_wasCast(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO EV_in_AC_wasCast_Annex (
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_in_AC_wasCast_Posit (
            EV_ID_in,
            AC_ID_wasCast
        )
        VALUES (
            p_EV_in,
            p_AC_wasCast
        )
        RETURNING EV_in_AC_wasCast_ID INTO v_posit;
    END IF;
    INSERT INTO EV_in_AC_wasCast_Annex (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_in_AC_wasCast;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_in_AC_wasCast instead of INSERT trigger on EV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_EV_in_AC_wasCast
INSTEAD OF INSERT ON EV_in_AC_wasCast
FOR EACH ROW
BEGIN
    ip_EV_in_AC_wasCast(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_wasCast => :NEW.AC_ID_wasCast,
        p_positing => :NEW.EV_in_AC_wasCast_PositedAt,
        p_reliability => :NEW.EV_in_AC_wasCast_Reliability,
        p_metadata => :NEW.Metadata_EV_in_AC_wasCast
    );
END it_EV_in_AC_wasCast;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lEV_in_AC_wasCast
INSTEAD OF INSERT ON lEV_in_AC_wasCast
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    ip_EV_in_AC_wasCast(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_wasCast => :NEW.AC_ID_wasCast,
        p_positing => COALESCE(:NEW.EV_in_AC_wasCast_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.EV_in_AC_wasCast_Reliability, 1),
        p_metadata => :NEW.Metadata_EV_in_AC_wasCast
    );
END it_lEV_in_AC_wasCast;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lEV_in_AC_wasCast
INSTEAD OF DELETE ON lEV_in_AC_wasCast
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO EV_in_AC_wasCast_Annex (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    SELECT
        :OLD.Metadata_EV_in_AC_wasCast,
        :OLD.EV_in_AC_wasCast_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_in_AC_wasCast_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_in_AC_wasCast_Annex x
            WHERE
                x.EV_in_AC_wasCast_ID = :OLD.EV_in_AC_wasCast_ID
            AND
                x.EV_in_AC_wasCast_PositedAt = v_now
        );
END dt_lEV_in_AC_wasCast;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_part_PR_in_RAT_got tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_AC_part_PR_in_RAT_got (
    p_id IN AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_ID%TYPE,
    p_positing IN AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_part_PR_in_RAT_got_Reliability
        FROM
            AC_part_PR_in_RAT_got_Annex a
        WHERE
            a.AC_part_PR_in_RAT_got_ID = p_id
        AND
            a.AC_part_PR_in_RAT_got_PositedAt <= p_positing
        ORDER BY
            a.AC_part_PR_in_RAT_got_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.AC_part_PR_in_RAT_got_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_AC_part_PR_in_RAT_got;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_part_PR_in_RAT_got states a posit of AC_part_PR_in_RAT_got, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_part_PR_in_RAT_got (
    p_AC_part IN AC_part_PR_in_RAT_got_Posit.AC_ID_part%TYPE,
    p_PR_in IN AC_part_PR_in_RAT_got_Posit.PR_ID_in%TYPE,
    p_RAT_got IN AC_part_PR_in_RAT_got_Posit.RAT_ID_got%TYPE,
    p_changing IN AC_part_PR_in_RAT_got_Posit.AC_part_PR_in_RAT_got_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_Reliability%TYPE DEFAULT NULL,
    p_metadata IN AC_part_PR_in_RAT_got_Annex.Metadata_AC_part_PR_in_RAT_got%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_PositedAt%TYPE;
    v_reliability AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_Reliability%TYPE;
    v_changing AC_part_PR_in_RAT_got_Posit.AC_part_PR_in_RAT_got_ChangedAt%TYPE;
    v_posit AC_part_PR_in_RAT_got_Posit.AC_part_PR_in_RAT_got_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO AC_part_PR_in_RAT_got_Annex (
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    AC_part_PR_in_RAT_got_Annex a
                WHERE
                    a.AC_part_PR_in_RAT_got_ID = p_id
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_part_PR_in_RAT_got_ID
        FROM
            AC_part_PR_in_RAT_got_Posit p
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    AC_part_PR_in_RAT_got_Annex a
                WHERE
                    a.AC_part_PR_in_RAT_got_ID = v_posit
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
                AND
                    a.AC_part_PR_in_RAT_got_Reliability <> v_reliability
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
                v_positing);
        END IF;
    END IF;
    -- other values for identifiers that already have values at that time, asserted at the positing time, are a contradiction
    IF v_reliability = 1 THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    AC_part_PR_in_RAT_got_Posit p
                JOIN
                    AC_part_PR_in_RAT_got_Annex a
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
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
                AND
                    a.AC_part_PR_in_RAT_got_Reliability = 1
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
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    AC_part_PR_in_RAT_got_Annex a
                WHERE
                    a.AC_part_PR_in_RAT_got_ID = v_posit
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
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF ie_AC_part_PR_in_RAT_got(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO AC_part_PR_in_RAT_got_Annex (
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same identifiers (and changing time), when that has
    -- other values: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.AC_part_PR_in_RAT_got_ID
        FROM
            AC_part_PR_in_RAT_got_Posit p
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
            ie_AC_part_PR_in_RAT_got(p.AC_part_PR_in_RAT_got_ID, v_positing) = 1
    ) LOOP
        retract(r.AC_part_PR_in_RAT_got_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO AC_part_PR_in_RAT_got_Posit (
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
    INSERT INTO AC_part_PR_in_RAT_got_Annex (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_AC_part_PR_in_RAT_got;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_part_PR_in_RAT_got instead of INSERT trigger on AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_AC_part_PR_in_RAT_got
INSTEAD OF INSERT ON AC_part_PR_in_RAT_got
FOR EACH ROW
BEGIN
    ip_AC_part_PR_in_RAT_got(
        p_AC_part => :NEW.AC_ID_part,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_got => :NEW.RAT_ID_got,
        p_changing => :NEW.AC_part_PR_in_RAT_got_ChangedAt,
        p_positing => :NEW.AC_part_PR_in_RAT_got_PositedAt,
        p_reliability => :NEW.AC_part_PR_in_RAT_got_Reliability,
        p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
    );
END it_AC_part_PR_in_RAT_got;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_part_PR_in_RAT_got
INSTEAD OF INSERT ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_RAT_got number(5);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_RAT_got := :NEW.RAT_ID_got;
    IF v_RAT_got IS NULL AND :NEW.got_RAT_Rating IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                RAT_Rating k
            WHERE
                k.RAT_Rating = :NEW.got_RAT_Rating
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_RAT_got := kv.RAT_ID;
        END LOOP;
    END IF;
    ip_AC_part_PR_in_RAT_got(
        p_AC_part => :NEW.AC_ID_part,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_got => v_RAT_got,
        p_changing => COALESCE(:NEW.AC_part_PR_in_RAT_got_ChangedAt, v_now),
        p_positing => COALESCE(:NEW.AC_part_PR_in_RAT_got_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_part_PR_in_RAT_got_Reliability, 1),
        p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
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
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_RAT_got number(5);
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
                    RAT_Rating k
                WHERE
                    k.RAT_Rating = :NEW.got_RAT_Rating
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_RAT_got := kv.RAT_ID;
            END LOOP;
        END IF;
    END IF;
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
        (:NEW.AC_part_PR_in_RAT_got_Reliability <> :OLD.AC_part_PR_in_RAT_got_Reliability
            OR (:NEW.AC_part_PR_in_RAT_got_Reliability IS NULL AND :OLD.AC_part_PR_in_RAT_got_Reliability IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_Reliability IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_Reliability IS NULL))
    THEN
        IF
            :NEW.AC_ID_part IS NOT NULL
        AND
            :NEW.PR_ID_in IS NOT NULL
        AND
            v_RAT_got IS NOT NULL
        THEN
            ip_AC_part_PR_in_RAT_got(
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
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_part_PR_in_RAT_got_Reliability, 1),
                p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_AC_part_PR_in_RAT_got(
                p_AC_part => :OLD.AC_ID_part,
                p_PR_in => :OLD.PR_ID_in,
                p_RAT_got => :OLD.RAT_ID_got,
                p_changing => :OLD.AC_part_PR_in_RAT_got_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
            );
        END IF;
    END IF;
END ut_lAC_part_PR_in_RAT_got;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_part_PR_in_RAT_got
INSTEAD OF DELETE ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO AC_part_PR_in_RAT_got_Annex (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        :OLD.Metadata_AC_part_PR_in_RAT_got,
        :OLD.AC_part_PR_in_RAT_got_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_part_PR_in_RAT_got_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                AC_part_PR_in_RAT_got_Annex x
            WHERE
                x.AC_part_PR_in_RAT_got_ID = :OLD.AC_part_PR_in_RAT_got_ID
            AND
                x.AC_part_PR_in_RAT_got_PositedAt = v_now
        );
END dt_lAC_part_PR_in_RAT_got;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_ST_at_PR_isPlaying tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_ST_at_PR_isPlaying (
    p_id IN ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_ID%TYPE,
    p_positing IN ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_at_PR_isPlaying_Reliability
        FROM
            ST_at_PR_isPlaying_Annex a
        WHERE
            a.ST_at_PR_isPlaying_ID = p_id
        AND
            a.ST_at_PR_isPlaying_PositedAt <= p_positing
        ORDER BY
            a.ST_at_PR_isPlaying_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.ST_at_PR_isPlaying_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_ST_at_PR_isPlaying;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_at_PR_isPlaying states a posit of ST_at_PR_isPlaying, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_at_PR_isPlaying (
    p_ST_at IN ST_at_PR_isPlaying_Posit.ST_ID_at%TYPE,
    p_PR_isPlaying IN ST_at_PR_isPlaying_Posit.PR_ID_isPlaying%TYPE,
    p_changing IN ST_at_PR_isPlaying_Posit.ST_at_PR_isPlaying_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ST_at_PR_isPlaying_Annex.Metadata_ST_at_PR_isPlaying%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_PositedAt%TYPE;
    v_reliability ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_Reliability%TYPE;
    v_changing ST_at_PR_isPlaying_Posit.ST_at_PR_isPlaying_ChangedAt%TYPE;
    v_posit ST_at_PR_isPlaying_Posit.ST_at_PR_isPlaying_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ST_at_PR_isPlaying_Annex (
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ST_at_PR_isPlaying_Annex a
                WHERE
                    a.ST_at_PR_isPlaying_ID = p_id
                AND
                    a.ST_at_PR_isPlaying_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.ST_at_PR_isPlaying_ID
        FROM
            ST_at_PR_isPlaying_Posit p
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ST_at_PR_isPlaying_Annex a
                WHERE
                    a.ST_at_PR_isPlaying_ID = v_posit
                AND
                    a.ST_at_PR_isPlaying_PositedAt = v_positing
                AND
                    a.ST_at_PR_isPlaying_Reliability <> v_reliability
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
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ST_at_PR_isPlaying_Annex a
                WHERE
                    a.ST_at_PR_isPlaying_ID = v_posit
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
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF ie_ST_at_PR_isPlaying(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ST_at_PR_isPlaying_Annex (
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ST_at_PR_isPlaying_Posit (
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
    INSERT INTO ST_at_PR_isPlaying_Annex (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_ST_at_PR_isPlaying;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_at_PR_isPlaying instead of INSERT trigger on ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_ST_at_PR_isPlaying
INSTEAD OF INSERT ON ST_at_PR_isPlaying
FOR EACH ROW
BEGIN
    ip_ST_at_PR_isPlaying(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_isPlaying => :NEW.PR_ID_isPlaying,
        p_changing => :NEW.ST_at_PR_isPlaying_ChangedAt,
        p_positing => :NEW.ST_at_PR_isPlaying_PositedAt,
        p_reliability => :NEW.ST_at_PR_isPlaying_Reliability,
        p_metadata => :NEW.Metadata_ST_at_PR_isPlaying
    );
END it_ST_at_PR_isPlaying;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lST_at_PR_isPlaying
INSTEAD OF INSERT ON lST_at_PR_isPlaying
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    ip_ST_at_PR_isPlaying(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_isPlaying => :NEW.PR_ID_isPlaying,
        p_changing => COALESCE(:NEW.ST_at_PR_isPlaying_ChangedAt, v_now),
        p_positing => COALESCE(:NEW.ST_at_PR_isPlaying_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.ST_at_PR_isPlaying_Reliability, 1),
        p_metadata => :NEW.Metadata_ST_at_PR_isPlaying
    );
END it_lST_at_PR_isPlaying;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lST_at_PR_isPlaying
INSTEAD OF DELETE ON lST_at_PR_isPlaying
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO ST_at_PR_isPlaying_Annex (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    SELECT
        :OLD.Metadata_ST_at_PR_isPlaying,
        :OLD.ST_at_PR_isPlaying_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_at_PR_isPlaying_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                ST_at_PR_isPlaying_Annex x
            WHERE
                x.ST_at_PR_isPlaying_ID = :OLD.ST_at_PR_isPlaying_ID
            AND
                x.ST_at_PR_isPlaying_PositedAt = v_now
        );
END dt_lST_at_PR_isPlaying;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_parent_AC_child_PAT_having tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_AC_parent_AC_child_PAT_having (
    p_id IN AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_ID%TYPE,
    p_positing IN AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_parent_AC_child_PAT_having_Reliability
        FROM
            AC_parent_AC_child_PAT_having_Annex a
        WHERE
            a.AC_parent_AC_child_PAT_having_ID = p_id
        AND
            a.AC_parent_AC_child_PAT_having_PositedAt <= p_positing
        ORDER BY
            a.AC_parent_AC_child_PAT_having_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.AC_parent_AC_child_PAT_having_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_AC_parent_AC_child_PAT_having;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_parent_AC_child_PAT_having states a posit of AC_parent_AC_child_PAT_having, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_parent_AC_child_PAT_having (
    p_AC_parent IN AC_parent_AC_child_PAT_having_Posit.AC_ID_parent%TYPE,
    p_AC_child IN AC_parent_AC_child_PAT_having_Posit.AC_ID_child%TYPE,
    p_PAT_having IN AC_parent_AC_child_PAT_having_Posit.PAT_ID_having%TYPE,
    p_positing IN AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_Reliability%TYPE DEFAULT NULL,
    p_metadata IN AC_parent_AC_child_PAT_having_Annex.Metadata_AC_parent_AC_child_PAT_having%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_PositedAt%TYPE;
    v_reliability AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_Reliability%TYPE;
    v_posit AC_parent_AC_child_PAT_having_Posit.AC_parent_AC_child_PAT_having_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO AC_parent_AC_child_PAT_having_Annex (
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    AC_parent_AC_child_PAT_having_Annex a
                WHERE
                    a.AC_parent_AC_child_PAT_having_ID = p_id
                AND
                    a.AC_parent_AC_child_PAT_having_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_parent_AC_child_PAT_having_ID
        FROM
            AC_parent_AC_child_PAT_having_Posit p
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    AC_parent_AC_child_PAT_having_Annex a
                WHERE
                    a.AC_parent_AC_child_PAT_having_ID = v_posit
                AND
                    a.AC_parent_AC_child_PAT_having_PositedAt = v_positing
                AND
                    a.AC_parent_AC_child_PAT_having_Reliability <> v_reliability
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
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    AC_parent_AC_child_PAT_having_Annex a
                WHERE
                    a.AC_parent_AC_child_PAT_having_ID = v_posit
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
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF ie_AC_parent_AC_child_PAT_having(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO AC_parent_AC_child_PAT_having_Annex (
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO AC_parent_AC_child_PAT_having_Posit (
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
    INSERT INTO AC_parent_AC_child_PAT_having_Annex (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_AC_parent_AC_child_PAT_having;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_parent_AC_child_PAT_having instead of INSERT trigger on AC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_AC_parent_AC_child_PAT_having
INSTEAD OF INSERT ON AC_parent_AC_child_PAT_having
FOR EACH ROW
BEGIN
    ip_AC_parent_AC_child_PAT_having(
        p_AC_parent => :NEW.AC_ID_parent,
        p_AC_child => :NEW.AC_ID_child,
        p_PAT_having => :NEW.PAT_ID_having,
        p_positing => :NEW.AC_parent_AC_child_PAT_having_PositedAt,
        p_reliability => :NEW.AC_parent_AC_child_PAT_having_Reliability,
        p_metadata => :NEW.Metadata_AC_parent_AC_child_PAT_having
    );
END it_AC_parent_AC_child_PAT_having;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_parent_AC_child_PAT_having
INSTEAD OF INSERT ON lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_PAT_having number(5);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_PAT_having := :NEW.PAT_ID_having;
    IF v_PAT_having IS NULL AND :NEW.having_PAT_ParentalType IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PAT_ID
            FROM
                PAT_ParentalType k
            WHERE
                k.PAT_ParentalType = :NEW.having_PAT_ParentalType
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PAT_having := kv.PAT_ID;
        END LOOP;
    END IF;
    ip_AC_parent_AC_child_PAT_having(
        p_AC_parent => :NEW.AC_ID_parent,
        p_AC_child => :NEW.AC_ID_child,
        p_PAT_having => v_PAT_having,
        p_positing => COALESCE(:NEW.AC_parent_AC_child_PAT_having_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_parent_AC_child_PAT_having_Reliability, 1),
        p_metadata => :NEW.Metadata_AC_parent_AC_child_PAT_having
    );
END it_lAC_parent_AC_child_PAT_having;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_parent_AC_child_PAT_having
INSTEAD OF DELETE ON lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO AC_parent_AC_child_PAT_having_Annex (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    SELECT
        :OLD.Metadata_AC_parent_AC_child_PAT_having,
        :OLD.AC_parent_AC_child_PAT_having_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_parent_AC_child_PAT_having_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                AC_parent_AC_child_PAT_having_Annex x
            WHERE
                x.AC_parent_AC_child_PAT_having_ID = :OLD.AC_parent_AC_child_PAT_having_ID
            AND
                x.AC_parent_AC_child_PAT_having_PositedAt = v_now
        );
END dt_lAC_parent_AC_child_PAT_having;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_PR_content_ST_location_EV_of tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_PR_content_ST_location_EV_of (
    p_id IN PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_ID%TYPE,
    p_positing IN PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_content_ST_location_EV_of_Reliability
        FROM
            PR_content_ST_location_EV_of_Annex a
        WHERE
            a.PR_content_ST_location_EV_of_ID = p_id
        AND
            a.PR_content_ST_location_EV_of_PositedAt <= p_positing
        ORDER BY
            a.PR_content_ST_location_EV_of_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.PR_content_ST_location_EV_of_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_PR_content_ST_location_EV_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_content_ST_location_EV_of states a posit of PR_content_ST_location_EV_of, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_PR_content_ST_location_EV_of (
    p_PR_content IN PR_content_ST_location_EV_of_Posit.PR_ID_content%TYPE,
    p_ST_location IN PR_content_ST_location_EV_of_Posit.ST_ID_location%TYPE,
    p_EV_of IN PR_content_ST_location_EV_of_Posit.EV_ID_of%TYPE,
    p_positing IN PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_Reliability%TYPE DEFAULT NULL,
    p_metadata IN PR_content_ST_location_EV_of_Annex.Metadata_PR_content_ST_location_EV_of%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_PositedAt%TYPE;
    v_reliability PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_Reliability%TYPE;
    v_posit PR_content_ST_location_EV_of_Posit.PR_content_ST_location_EV_of_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO PR_content_ST_location_EV_of_Annex (
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    PR_content_ST_location_EV_of_Annex a
                WHERE
                    a.PR_content_ST_location_EV_of_ID = p_id
                AND
                    a.PR_content_ST_location_EV_of_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.PR_content_ST_location_EV_of_ID
        FROM
            PR_content_ST_location_EV_of_Posit p
        WHERE
            p.PR_ID_content = p_PR_content
        AND
            p.ST_ID_location = p_ST_location
        AND
            p.EV_ID_of = p_EV_of
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_content_ST_location_EV_of_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    PR_content_ST_location_EV_of_Annex a
                WHERE
                    a.PR_content_ST_location_EV_of_ID = v_posit
                AND
                    a.PR_content_ST_location_EV_of_PositedAt = v_positing
                AND
                    a.PR_content_ST_location_EV_of_Reliability <> v_reliability
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
                v_positing);
        END IF;
    END IF;
    -- other values for identifiers that already have values at that time, asserted at the positing time, are a contradiction
    IF v_reliability = 1 THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    PR_content_ST_location_EV_of_Posit p
                JOIN
                    PR_content_ST_location_EV_of_Annex a
                ON
                    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
                WHERE
                    p.EV_ID_of = p_EV_of
                AND
                    NOT (
                        p.PR_ID_content = p_PR_content
                        AND
                        p.ST_ID_location = p_ST_location
                    )
                AND
                    a.PR_content_ST_location_EV_of_PositedAt = v_positing
                AND
                    a.PR_content_ST_location_EV_of_Reliability = 1
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
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    PR_content_ST_location_EV_of_Annex a
                WHERE
                    a.PR_content_ST_location_EV_of_ID = v_posit
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
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF ie_PR_content_ST_location_EV_of(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO PR_content_ST_location_EV_of_Annex (
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same identifiers (and changing time), when that has
    -- other values: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.PR_content_ST_location_EV_of_ID
        FROM
            PR_content_ST_location_EV_of_Posit p
        WHERE
            p.EV_ID_of = p_EV_of
        AND
            NOT (
                p.PR_ID_content = p_PR_content
                AND
                p.ST_ID_location = p_ST_location
            )
        AND
            ie_PR_content_ST_location_EV_of(p.PR_content_ST_location_EV_of_ID, v_positing) = 1
    ) LOOP
        retract(r.PR_content_ST_location_EV_of_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO PR_content_ST_location_EV_of_Posit (
            PR_ID_content,
            ST_ID_location,
            EV_ID_of
        )
        VALUES (
            p_PR_content,
            p_ST_location,
            p_EV_of
        )
        RETURNING PR_content_ST_location_EV_of_ID INTO v_posit;
    END IF;
    INSERT INTO PR_content_ST_location_EV_of_Annex (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_PR_content_ST_location_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_content_ST_location_EV_of instead of INSERT trigger on PR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_PR_content_ST_location_EV_of
INSTEAD OF INSERT ON PR_content_ST_location_EV_of
FOR EACH ROW
BEGIN
    ip_PR_content_ST_location_EV_of(
        p_PR_content => :NEW.PR_ID_content,
        p_ST_location => :NEW.ST_ID_location,
        p_EV_of => :NEW.EV_ID_of,
        p_positing => :NEW.PR_content_ST_location_EV_of_PositedAt,
        p_reliability => :NEW.PR_content_ST_location_EV_of_Reliability,
        p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
    );
END it_PR_content_ST_location_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lPR_content_ST_location_EV_of
INSTEAD OF INSERT ON lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    ip_PR_content_ST_location_EV_of(
        p_PR_content => :NEW.PR_ID_content,
        p_ST_location => :NEW.ST_ID_location,
        p_EV_of => :NEW.EV_ID_of,
        p_positing => COALESCE(:NEW.PR_content_ST_location_EV_of_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.PR_content_ST_location_EV_of_Reliability, 1),
        p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
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
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
BEGIN
    IF (:NEW.EV_ID_of <> :OLD.EV_ID_of
        OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
        OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_ID_of is not updatable.');
    END IF;
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
        (:NEW.PR_content_ST_location_EV_of_PositedAt <> :OLD.PR_content_ST_location_EV_of_PositedAt
            OR (:NEW.PR_content_ST_location_EV_of_PositedAt IS NULL AND :OLD.PR_content_ST_location_EV_of_PositedAt IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_PositedAt IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_PositedAt IS NULL)) OR
        (:NEW.PR_content_ST_location_EV_of_Reliability <> :OLD.PR_content_ST_location_EV_of_Reliability
            OR (:NEW.PR_content_ST_location_EV_of_Reliability IS NULL AND :OLD.PR_content_ST_location_EV_of_Reliability IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_Reliability IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_Reliability IS NULL))
    THEN
        IF
            :NEW.PR_ID_content IS NOT NULL
        AND
            :NEW.ST_ID_location IS NOT NULL
        AND
            :NEW.EV_ID_of IS NOT NULL
        THEN
            ip_PR_content_ST_location_EV_of(
                p_PR_content => :NEW.PR_ID_content,
                p_ST_location => :NEW.ST_ID_location,
                p_EV_of => :NEW.EV_ID_of,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.PR_content_ST_location_EV_of_Reliability, 1),
                p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_PR_content_ST_location_EV_of(
                p_PR_content => :OLD.PR_ID_content,
                p_ST_location => :OLD.ST_ID_location,
                p_EV_of => :OLD.EV_ID_of,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
            );
        END IF;
    END IF;
END ut_lPR_content_ST_location_EV_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lPR_content_ST_location_EV_of
INSTEAD OF DELETE ON lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO PR_content_ST_location_EV_of_Annex (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        :OLD.Metadata_PR_content_ST_location_EV_of,
        :OLD.PR_content_ST_location_EV_of_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.PR_content_ST_location_EV_of_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                PR_content_ST_location_EV_of_Annex x
            WHERE
                x.PR_content_ST_location_EV_of_ID = :OLD.PR_content_ST_location_EV_of_ID
            AND
                x.PR_content_ST_location_EV_of_PositedAt = v_now
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
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_PN_Person_1st (
    PN_ID,
    subset_AC_NAM_Actor_Name
)
AS
SELECT
    "PN".PN_ID,
    "s2".AC_NAM_Actor_Name
FROM
    PN_Person "PN"
LEFT JOIN
    lAC_subset_PN_of "s1"
ON
    "s1".PN_ID_of = "PN".PN_ID
LEFT JOIN
    lAC_Actor "s2"
ON
    "s2".AC_ID = "s1".AC_ID_subset
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of PN_Person at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_PN_Person_1st (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "PN".PN_ID,
            "s2".AC_NAM_Actor_Name AS subset_AC_NAM_Actor_Name
        FROM
            PN_Person "PN"
        LEFT JOIN
            pAC_subset_PN_of(changingTimepoint) "s1"
        ON
            "s1".PN_ID_of = "PN".PN_ID
        LEFT JOIN
            pAC_Actor(changingTimepoint) "s2"
        ON
            "s2".AC_ID = "s1".AC_ID_subset
    ]';
END pkey_PN_Person_1st;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_PN_Person_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PN_Person_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'subset_AC_NAM_Actor_Name' VALUE subset_AC_NAM_Actor_Name
    ),
    COUNT(DISTINCT PN_ID)
FROM
    key_PN_Person_1st
WHERE
    subset_AC_NAM_Actor_Name IS NOT NULL
GROUP BY
    subset_AC_NAM_Actor_Name
HAVING
    COUNT(DISTINCT PN_ID) > 1
UNION ALL
SELECT
    'key_PN_Person_1st',
    'more than one natural key',
    JSON_OBJECT(
        'PN_ID' VALUE PN_ID
    ),
    COUNT(*)
FROM
    key_PN_Person_1st
GROUP BY
    PN_ID
HAVING
    COUNT(*) > 1;
-- The 1st key of ST_Stage is not generated: ST_LOC_Stage_Location is a nclob, which cannot be compared, and it has no checksum
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
-- 3rd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_ST_Stage_3rd (
    ST_ID,
    ST_MIN_UTL_Utilization,
    ST_NAM_Stage_Name
)
AS
SELECT
    "ST".ST_ID,
    "ST".ST_MIN_UTL_Utilization,
    "ST".ST_NAM_Stage_Name
FROM
    lST_Stage "ST"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_ST_Stage_3rd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "ST".ST_ID,
            "ST".ST_MIN_UTL_Utilization AS ST_MIN_UTL_Utilization,
            "ST".ST_NAM_Stage_Name AS ST_NAM_Stage_Name
        FROM
            pST_Stage(changingTimepoint) "ST"
    ]';
END pkey_ST_Stage_3rd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_ST_Stage_3rd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_3rd',
    'duplicate natural key',
    JSON_OBJECT(
        'ST_MIN_UTL_Utilization' VALUE ST_MIN_UTL_Utilization,
        'ST_NAM_Stage_Name' VALUE ST_NAM_Stage_Name
    ),
    COUNT(DISTINCT ST_ID)
FROM
    key_ST_Stage_3rd
WHERE
    ST_MIN_UTL_Utilization IS NOT NULL
AND
    ST_NAM_Stage_Name IS NOT NULL
GROUP BY
    ST_MIN_UTL_Utilization,
    ST_NAM_Stage_Name
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Stage_3rd',
    'more than one natural key',
    JSON_OBJECT(
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    key_ST_Stage_3rd
GROUP BY
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage
-- Note: ST_Stage can be wasHeldAt in more than one EV_Event, so an identity can have more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_ST_Stage_4th (
    ST_ID,
    wasHeldAt_EV_DAT_Event_Date
)
AS
SELECT
    "ST".ST_ID,
    "s1".EV_DAT_Event_Date
FROM
    lST_Stage "ST"
LEFT JOIN
    lEV_Event "s1"
ON
    "s1".ST_ID_wasHeldAt = "ST".ST_ID
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_ST_Stage_4th (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_4th',
    'duplicate natural key',
    JSON_OBJECT(
        'wasHeldAt_EV_DAT_Event_Date' VALUE wasHeldAt_EV_DAT_Event_Date
    ),
    COUNT(DISTINCT ST_ID)
FROM
    key_ST_Stage_4th
WHERE
    wasHeldAt_EV_DAT_Event_Date IS NOT NULL
GROUP BY
    wasHeldAt_EV_DAT_Event_Date
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Stage_4th',
    'more than one natural key',
    JSON_OBJECT(
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    key_ST_Stage_4th
GROUP BY
    ST_ID
HAVING
    COUNT(*) > 1;
-- The 5th key of ST_Stage is not generated: more than one element is stop 1
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
-- 2nd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_AC_Actor_2nd (
    AC_ID,
    with_AC_NAM_Actor_Name
)
AS
SELECT
    "AC".AC_ID,
    "s2".AC_NAM_Actor_Name
FROM
    lAC_Actor "AC"
LEFT JOIN
    lAC_partner_AC_with_ONG_currently "s1"
ON
    "s1".AC_ID_partner = "AC".AC_ID
LEFT JOIN
    lAC_Actor "s2"
ON
    "s2".AC_ID = "s1".AC_ID_with
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_AC_Actor_2nd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".AC_ID,
            "s2".AC_NAM_Actor_Name AS with_AC_NAM_Actor_Name
        FROM
            pAC_Actor(changingTimepoint) "AC"
        LEFT JOIN
            pAC_partner_AC_with_ONG_currently(changingTimepoint) "s1"
        ON
            "s1".AC_ID_partner = "AC".AC_ID
        LEFT JOIN
            pAC_Actor(changingTimepoint) "s2"
        ON
            "s2".AC_ID = "s1".AC_ID_with
    ]';
END pkey_AC_Actor_2nd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_AC_Actor_2nd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Actor_2nd',
    'duplicate natural key',
    JSON_OBJECT(
        'with_AC_NAM_Actor_Name' VALUE with_AC_NAM_Actor_Name
    ),
    COUNT(DISTINCT AC_ID)
FROM
    key_AC_Actor_2nd
WHERE
    with_AC_NAM_Actor_Name IS NOT NULL
GROUP BY
    with_AC_NAM_Actor_Name
HAVING
    COUNT(DISTINCT AC_ID) > 1
UNION ALL
SELECT
    'key_AC_Actor_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'AC_ID' VALUE AC_ID
    ),
    COUNT(*)
FROM
    key_AC_Actor_2nd
GROUP BY
    AC_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor
-- Note: AC_parent_AC_child_PAT_having has identifiers other than parent, so it can lead to more than one child and an identity to more than one key
-- Note: AC_part_PR_in_RAT_got has identifiers other than part, so it can lead to more than one in and an identity to more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_AC_Actor_3rd (
    AC_ID,
    child_in_PR_NAM_Program_Name
)
AS
SELECT
    "AC".AC_ID,
    "s4".PR_NAM_Program_Name
FROM
    lAC_Actor "AC"
LEFT JOIN
    lAC_parent_AC_child_PAT_having "s1"
ON
    "s1".AC_ID_parent = "AC".AC_ID
LEFT JOIN
    lAC_part_PR_in_RAT_got "s3"
ON
    "s3".AC_ID_part = "s1".AC_ID_child
LEFT JOIN
    lPR_Program "s4"
ON
    "s4".PR_ID = "s3".PR_ID_in
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_AC_Actor_3rd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".AC_ID,
            "s4".PR_NAM_Program_Name AS child_in_PR_NAM_Program_Name
        FROM
            pAC_Actor(changingTimepoint) "AC"
        LEFT JOIN
            pAC_parent_AC_child_PAT_having(changingTimepoint) "s1"
        ON
            "s1".AC_ID_parent = "AC".AC_ID
        LEFT JOIN
            pAC_part_PR_in_RAT_got(changingTimepoint) "s3"
        ON
            "s3".AC_ID_part = "s1".AC_ID_child
        LEFT JOIN
            pPR_Program(changingTimepoint) "s4"
        ON
            "s4".PR_ID = "s3".PR_ID_in
    ]';
END pkey_AC_Actor_3rd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_AC_Actor_3rd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Actor_3rd',
    'duplicate natural key',
    JSON_OBJECT(
        'child_in_PR_NAM_Program_Name' VALUE child_in_PR_NAM_Program_Name
    ),
    COUNT(DISTINCT AC_ID)
FROM
    key_AC_Actor_3rd
WHERE
    child_in_PR_NAM_Program_Name IS NOT NULL
GROUP BY
    child_in_PR_NAM_Program_Name
HAVING
    COUNT(DISTINCT AC_ID) > 1
UNION ALL
SELECT
    'key_AC_Actor_3rd',
    'more than one natural key',
    JSON_OBJECT(
        'AC_ID' VALUE AC_ID
    ),
    COUNT(*)
FROM
    key_AC_Actor_3rd
GROUP BY
    AC_ID
HAVING
    COUNT(*) > 1;
-- The 4th key of AC_Actor is not generated: stop 1: ST_NAM_Stage_Name is not an attribute of AC_Actor
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
-- 2nd key of PR_Program
-- Note: AC_part_PR_in_RAT_got has identifiers other than in, so it can lead to more than one got and an identity to more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_PR_Program_2nd (
    PR_ID,
    got_RAT_Rating
)
AS
SELECT
    "PR".PR_ID,
    "s1".got_RAT_Rating
FROM
    lPR_Program "PR"
LEFT JOIN
    lAC_part_PR_in_RAT_got "s1"
ON
    "s1".PR_ID_in = "PR".PR_ID
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_PR_Program_2nd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "PR".PR_ID,
            "s1".got_RAT_Rating AS got_RAT_Rating
        FROM
            pPR_Program(changingTimepoint) "PR"
        LEFT JOIN
            pAC_part_PR_in_RAT_got(changingTimepoint) "s1"
        ON
            "s1".PR_ID_in = "PR".PR_ID
    ]';
END pkey_PR_Program_2nd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_PR_Program_2nd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PR_Program_2nd',
    'duplicate natural key',
    JSON_OBJECT(
        'got_RAT_Rating' VALUE got_RAT_Rating
    ),
    COUNT(DISTINCT PR_ID)
FROM
    key_PR_Program_2nd
WHERE
    got_RAT_Rating IS NOT NULL
GROUP BY
    got_RAT_Rating
HAVING
    COUNT(DISTINCT PR_ID) > 1
UNION ALL
SELECT
    'key_PR_Program_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'PR_ID' VALUE PR_ID
    ),
    COUNT(*)
FROM
    key_PR_Program_2nd
GROUP BY
    PR_ID
HAVING
    COUNT(*) > 1;
-- The 3rd key of PR_Program is not generated: branch 1 does not end in a value, an attribute or a knot
-- The 1st key of EV_Event is not generated: wasHeldAt_ST_LOC_Stage_Location is a nclob, which cannot be compared, and it has no checksum
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_EV_Event_2nd (
    EV_ID,
    of_ETY_EventType,
    EV_DAT_Event_Date
)
AS
SELECT
    "EV".EV_ID,
    "EV".of_ETY_EventType,
    "EV".EV_DAT_Event_Date
FROM
    lEV_Event "EV"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_EV_Event_2nd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_EV_Event_2nd',
    'duplicate natural key',
    JSON_OBJECT(
        'of_ETY_EventType' VALUE of_ETY_EventType,
        'EV_DAT_Event_Date' VALUE EV_DAT_Event_Date
    ),
    COUNT(DISTINCT EV_ID)
FROM
    key_EV_Event_2nd
WHERE
    of_ETY_EventType IS NOT NULL
AND
    EV_DAT_Event_Date IS NOT NULL
GROUP BY
    of_ETY_EventType,
    EV_DAT_Event_Date
HAVING
    COUNT(DISTINCT EV_ID) > 1
UNION ALL
SELECT
    'key_EV_Event_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'EV_ID' VALUE EV_ID
    ),
    COUNT(*)
FROM
    key_EV_Event_2nd
GROUP BY
    EV_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_EV_Event_3rd (
    EV_ID,
    content_PR_NAM_Program_Name
)
AS
SELECT
    "EV".EV_ID,
    "s2".PR_NAM_Program_Name
FROM
    lEV_Event "EV"
LEFT JOIN
    lPR_content_ST_location_EV_of "s1"
ON
    "s1".EV_ID_of = "EV".EV_ID
LEFT JOIN
    lPR_Program "s2"
ON
    "s2".PR_ID = "s1".PR_ID_content
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_EV_Event_3rd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_EV_Event_3rd',
    'duplicate natural key',
    JSON_OBJECT(
        'content_PR_NAM_Program_Name' VALUE content_PR_NAM_Program_Name
    ),
    COUNT(DISTINCT EV_ID)
FROM
    key_EV_Event_3rd
WHERE
    content_PR_NAM_Program_Name IS NOT NULL
GROUP BY
    content_PR_NAM_Program_Name
HAVING
    COUNT(DISTINCT EV_ID) > 1
UNION ALL
SELECT
    'key_EV_Event_3rd',
    'more than one natural key',
    JSON_OBJECT(
        'EV_ID' VALUE EV_ID
    ),
    COUNT(*)
FROM
    key_EV_Event_3rd
GROUP BY
    EV_ID
HAVING
    COUNT(*) > 1;
-- The 4th key of EV_Event is not generated: stop 1: a tie takes two stops in a row in one branch, the role it is entered by and the role it is left by
-- The 5th key of EV_Event is not generated: stop 1 is on the knot ETY_EventType, which a route reaches through a knotted attribute or a knot role instead
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
COMMENT ON COLUMN EV_DAT_Event_Date_Posit.EV_DAT_Event_Date IS 'Date and time when the event took place.';
COMMENT ON COLUMN EV_AUD_Event_Audience_Posit.EV_AUD_Event_Audience IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN EV_REV_Event_Revenue_Posit.EV_REV_Event_Revenue IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN ST_NAM_Stage_Name_Posit.ST_NAM_Stage_Name IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN ST_LOC_Stage_Location_Posit.ST_LOC_Stage_Location IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN ST_AVG_Stage_Average_Posit.ST_AVG_UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN ST_MIN_Stage_Minimum_Posit.ST_MIN_UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN AC_NAM_Actor_Name_Posit.AC_NAM_Actor_Name IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN AC_GEN_Actor_Gender_Posit.AC_GEN_GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN PR_NAM_Program_Name_Posit.PR_NAM_Program_Name IS 'Name or title of the program.';
COMMENT ON COLUMN PR_LEN_Program_Length_Posit.PR_LEN_Program_Length IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE PN_Person IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE ST_Stage IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE AC_Actor IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE PR_Program IS 'A program, such as a play, show or concert, that can be played on stages.';
COMMENT ON TABLE EV_Event IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN EV_Event.ST_ID_wasHeldAt IS 'The stage at which the event was held.';
COMMENT ON COLUMN EV_Event.PR_ID_wasPlayed IS 'The program that was played at the event.';
COMMENT ON COLUMN EV_Event.ETY_ID_of IS 'The type of the event.';
COMMENT ON TABLE AC_partner_AC_with_ONG_currently_Posit IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN AC_partner_AC_with_ONG_currently_Posit.AC_ID_partner IS 'One of the actors in the partnership.';
COMMENT ON COLUMN AC_partner_AC_with_ONG_currently_Posit.AC_ID_with IS 'The other actor in the partnership.';
COMMENT ON COLUMN AC_partner_AC_with_ONG_currently_Posit.ONG_ID_currently IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON TABLE AC_subset_PN_of_Posit IS 'Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.';
COMMENT ON COLUMN AC_subset_PN_of_Posit.AC_ID_subset IS 'The actor.';
COMMENT ON COLUMN AC_subset_PN_of_Posit.PN_ID_of IS 'The person who is the actor.';
COMMENT ON TABLE EV_in_AC_wasCast_Posit IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN EV_in_AC_wasCast_Posit.EV_ID_in IS 'The event the actor was cast in.';
COMMENT ON COLUMN EV_in_AC_wasCast_Posit.AC_ID_wasCast IS 'An actor cast in the event.';
COMMENT ON TABLE AC_part_PR_in_RAT_got_Posit IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN AC_part_PR_in_RAT_got_Posit.AC_ID_part IS 'The actor having a part in the program.';
COMMENT ON COLUMN AC_part_PR_in_RAT_got_Posit.PR_ID_in IS 'The program the actor has a part in.';
COMMENT ON COLUMN AC_part_PR_in_RAT_got_Posit.RAT_ID_got IS 'The rating the actor got for the part.';
COMMENT ON TABLE ST_at_PR_isPlaying_Posit IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ST_at_PR_isPlaying_Posit.ST_ID_at IS 'The stage where the program is playing.';
COMMENT ON COLUMN ST_at_PR_isPlaying_Posit.PR_ID_isPlaying IS 'The program playing at the stage.';
COMMENT ON TABLE AC_parent_AC_child_PAT_having_Posit IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN AC_parent_AC_child_PAT_having_Posit.AC_ID_parent IS 'The actor who is the parent.';
COMMENT ON COLUMN AC_parent_AC_child_PAT_having_Posit.AC_ID_child IS 'The actor who is the child.';
COMMENT ON COLUMN AC_parent_AC_child_PAT_having_Posit.PAT_ID_having IS 'The type of parental relationship.';
COMMENT ON TABLE PR_content_ST_location_EV_of_Posit IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN PR_content_ST_location_EV_of_Posit.PR_ID_content IS 'The program that made up the content of the event.';
COMMENT ON COLUMN PR_content_ST_location_EV_of_Posit.ST_ID_location IS 'The stage where the event was located.';
COMMENT ON COLUMN PR_content_ST_location_EV_of_Posit.EV_ID_of IS 'The event.';
