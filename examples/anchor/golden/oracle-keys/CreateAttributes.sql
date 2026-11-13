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
            EV_DAT_EV_ID number(10) not null,
            EV_DAT_Event_Date timestamp not null,
            Metadata_EV_DAT number(10) not null,
            constraint fkEV_DAT_Event_Date foreign key (
                EV_DAT_EV_ID
            ) references EV_Event(EV_ID),
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
        CREATE TABLE EV_AUD_Event_Audience (
            EV_AUD_EV_ID number(10) not null,
            EV_AUD_Event_Audience number(10) not null,
            Metadata_EV_AUD number(10) not null,
            constraint fkEV_AUD_Event_Audience foreign key (
                EV_AUD_EV_ID
            ) references EV_Event(EV_ID),
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
        CREATE TABLE EV_REV_Event_Revenue (
            EV_REV_EV_ID number(10) not null,
            EV_REV_Event_Revenue number(19,4) not null,
            Metadata_EV_REV number(10) not null,
            constraint fkEV_REV_Event_Revenue foreign key (
                EV_REV_EV_ID
            ) references EV_Event(EV_ID),
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
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_NAM_Stage_Name (
            ST_NAM_ST_ID number(10) not null,
            ST_NAM_Stage_Name nvarchar2(42) not null,
            ST_NAM_ChangedAt timestamp not null,
            Metadata_ST_NAM number(10) not null,
            constraint fkST_NAM_Stage_Name foreign key (
                ST_NAM_ST_ID
            ) references ST_Stage(ST_ID),
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
        CREATE TABLE ST_LOC_Stage_Location (
            ST_LOC_ST_ID number(10) not null,
            ST_LOC_Stage_Location nclob not null,
            Metadata_ST_LOC number(10) not null,
            constraint fkST_LOC_Stage_Location foreign key (
                ST_LOC_ST_ID
            ) references ST_Stage(ST_ID),
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
        CREATE TABLE ST_AVG_Stage_Average (
            ST_AVG_ST_ID number(10) not null,
            ST_AVG_UTL_ID number(5) not null,
            ST_AVG_ChangedAt timestamp not null,
            Metadata_ST_AVG number(10) not null,
            constraint fk_A_ST_AVG_Stage_Average foreign key (
                ST_AVG_ST_ID
            ) references ST_Stage(ST_ID),
            constraint fk_K_ST_AVG_Stage_Average foreign key (
                ST_AVG_UTL_ID
            ) references UTL_Utilization(UTL_ID),
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
        CREATE TABLE ST_MIN_Stage_Minimum (
            ST_MIN_ST_ID number(10) not null,
            ST_MIN_UTL_ID number(5) not null,
            Metadata_ST_MIN number(10) not null,
            constraint fk_A_ST_MIN_Stage_Minimum foreign key (
                ST_MIN_ST_ID
            ) references ST_Stage(ST_ID),
            constraint fk_K_ST_MIN_Stage_Minimum foreign key (
                ST_MIN_UTL_ID
            ) references UTL_Utilization(UTL_ID),
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
        CREATE TABLE ST_MIN_Stage_Minimum_Deleted (
            ST_MIN_ST_ID number(10) not null,
            ST_MIN_UTL_ID number(5) not null,
            Metadata_ST_MIN number(10) not null,
            ST_MIN_Deleted timestamp not null
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
            AC_NAM_AC_ID number(10) not null,
            AC_NAM_Actor_Name nvarchar2(42) not null,
            AC_NAM_ChangedAt timestamp not null,
            Metadata_AC_NAM number(10) not null,
            constraint fkAC_NAM_Actor_Name foreign key (
                AC_NAM_AC_ID
            ) references AC_Actor(AC_ID),
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
        CREATE TABLE AC_GEN_Actor_Gender (
            AC_GEN_AC_ID number(10) not null,
            AC_GEN_GEN_ID number(5) not null,
            Metadata_AC_GEN number(10) not null,
            constraint fk_A_AC_GEN_Actor_Gender foreign key (
                AC_GEN_AC_ID
            ) references AC_Actor(AC_ID),
            constraint fk_K_AC_GEN_Actor_Gender foreign key (
                AC_GEN_GEN_ID
            ) references GEN_Gender(GEN_ID),
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
        CREATE TABLE AC_PLV_Actor_ProfessionalLevel (
            AC_PLV_AC_ID number(10) not null,
            AC_PLV_PLV_ID number(5) not null,
            AC_PLV_ChangedAt timestamp not null,
            Metadata_AC_PLV number(10) not null,
            constraint fk_A_AC_PLV_Actor_ProfessionalLevel foreign key (
                AC_PLV_AC_ID
            ) references AC_Actor(AC_ID),
            constraint fk_K_AC_PLV_Actor_ProfessionalLevel foreign key (
                AC_PLV_PLV_ID
            ) references PLV_ProfessionalLevel(PLV_ID),
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
        CREATE TABLE PR_NAM_Program_Name (
            PR_NAM_PR_ID number(10) not null,
            PR_NAM_Program_Name nvarchar2(42) not null,
            Metadata_PR_NAM number(10) not null,
            constraint fkPR_NAM_Program_Name foreign key (
                PR_NAM_PR_ID
            ) references PR_Program(PR_ID),
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
        CREATE TABLE PR_LEN_Program_Length (
            PR_LEN_PR_ID number(10) not null,
            PR_LEN_Program_Length timestamp not null,
            PR_LEN_ChangedAt date not null,
            Metadata_PR_LEN number(10) not null,
            constraint fkPR_LEN_Program_Length foreign key (
                PR_LEN_PR_ID
            ) references PR_Program(PR_ID),
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
