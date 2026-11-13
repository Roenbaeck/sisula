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
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Annex table (of EV_DAT_Event_Date_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_DAT_Event_Date_Annex (
            EV_DAT_ID number(10) not null,
            EV_DAT_PositedAt timestamp not null,
            EV_DAT_Positor number(5) not null,
            EV_DAT_Reliability number(5,2) not null,
            EV_DAT_Assertion char(1) generated always as (
                case
                    when EV_DAT_Reliability > 0 then '+'
                    when EV_DAT_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_DAT number(10) not null,
            constraint fkEV_DAT_Event_Date_Annex foreign key (
                EV_DAT_ID
            ) references EV_DAT_Event_Date_Posit(EV_DAT_ID),
            constraint pkEV_DAT_Event_Date_Annex primary key (
                EV_DAT_ID,
                EV_DAT_Positor,
                EV_DAT_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Annex table (of EV_AUD_Event_Audience_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_AUD_Event_Audience_Annex (
            EV_AUD_ID number(10) not null,
            EV_AUD_PositedAt timestamp not null,
            EV_AUD_Positor number(5) not null,
            EV_AUD_Reliability number(5,2) not null,
            EV_AUD_Assertion char(1) generated always as (
                case
                    when EV_AUD_Reliability > 0 then '+'
                    when EV_AUD_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_AUD number(10) not null,
            constraint fkEV_AUD_Event_Audience_Annex foreign key (
                EV_AUD_ID
            ) references EV_AUD_Event_Audience_Posit(EV_AUD_ID),
            constraint pkEV_AUD_Event_Audience_Annex primary key (
                EV_AUD_ID,
                EV_AUD_Positor,
                EV_AUD_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Annex table (of EV_REV_Event_Revenue_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_REV_Event_Revenue_Annex (
            EV_REV_ID number(10) not null,
            EV_REV_PositedAt timestamp not null,
            EV_REV_Positor number(5) not null,
            EV_REV_Reliability number(5,2) not null,
            EV_REV_Assertion char(1) generated always as (
                case
                    when EV_REV_Reliability > 0 then '+'
                    when EV_REV_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_REV number(10) not null,
            constraint fkEV_REV_Event_Revenue_Annex foreign key (
                EV_REV_ID
            ) references EV_REV_Event_Revenue_Posit(EV_REV_ID),
            constraint pkEV_REV_Event_Revenue_Annex primary key (
                EV_REV_ID,
                EV_REV_Positor,
                EV_REV_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Annex table (of ST_NAM_Stage_Name_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_NAM_Stage_Name_Annex (
            ST_NAM_ID number(10) not null,
            ST_NAM_PositedAt timestamp not null,
            ST_NAM_Positor number(5) not null,
            ST_NAM_Reliability number(5,2) not null,
            ST_NAM_Assertion char(1) generated always as (
                case
                    when ST_NAM_Reliability > 0 then '+'
                    when ST_NAM_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_NAM number(10) not null,
            constraint fkST_NAM_Stage_Name_Annex foreign key (
                ST_NAM_ID
            ) references ST_NAM_Stage_Name_Posit(ST_NAM_ID),
            constraint pkST_NAM_Stage_Name_Annex primary key (
                ST_NAM_ID,
                ST_NAM_Positor,
                ST_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Annex table (of ST_LOC_Stage_Location_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_LOC_Stage_Location_Annex (
            ST_LOC_ID number(10) not null,
            ST_LOC_PositedAt timestamp not null,
            ST_LOC_Positor number(5) not null,
            ST_LOC_Reliability number(5,2) not null,
            ST_LOC_Assertion char(1) generated always as (
                case
                    when ST_LOC_Reliability > 0 then '+'
                    when ST_LOC_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_LOC number(10) not null,
            constraint fkST_LOC_Stage_Location_Annex foreign key (
                ST_LOC_ID
            ) references ST_LOC_Stage_Location_Posit(ST_LOC_ID),
            constraint pkST_LOC_Stage_Location_Annex primary key (
                ST_LOC_ID,
                ST_LOC_Positor,
                ST_LOC_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Annex table (of ST_AVG_Stage_Average_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_AVG_Stage_Average_Annex (
            ST_AVG_ID number(10) not null,
            ST_AVG_PositedAt timestamp not null,
            ST_AVG_Positor number(5) not null,
            ST_AVG_Reliability number(5,2) not null,
            ST_AVG_Assertion char(1) generated always as (
                case
                    when ST_AVG_Reliability > 0 then '+'
                    when ST_AVG_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_AVG number(10) not null,
            constraint fkST_AVG_Stage_Average_Annex foreign key (
                ST_AVG_ID
            ) references ST_AVG_Stage_Average_Posit(ST_AVG_ID),
            constraint pkST_AVG_Stage_Average_Annex primary key (
                ST_AVG_ID,
                ST_AVG_Positor,
                ST_AVG_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Annex table (of ST_MIN_Stage_Minimum_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_MIN_Stage_Minimum_Annex (
            ST_MIN_ID number(10) not null,
            ST_MIN_PositedAt timestamp not null,
            ST_MIN_Positor number(5) not null,
            ST_MIN_Reliability number(5,2) not null,
            ST_MIN_Assertion char(1) generated always as (
                case
                    when ST_MIN_Reliability > 0 then '+'
                    when ST_MIN_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_MIN number(10) not null,
            constraint fkST_MIN_Stage_Minimum_Annex foreign key (
                ST_MIN_ID
            ) references ST_MIN_Stage_Minimum_Posit(ST_MIN_ID),
            constraint pkST_MIN_Stage_Minimum_Annex primary key (
                ST_MIN_ID,
                ST_MIN_Positor,
                ST_MIN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Annex table (of AC_NAM_Actor_Name_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_NAM_Actor_Name_Annex (
            AC_NAM_ID number(10) not null,
            AC_NAM_PositedAt timestamp not null,
            AC_NAM_Positor number(5) not null,
            AC_NAM_Reliability number(5,2) not null,
            AC_NAM_Assertion char(1) generated always as (
                case
                    when AC_NAM_Reliability > 0 then '+'
                    when AC_NAM_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_NAM number(10) not null,
            constraint fkAC_NAM_Actor_Name_Annex foreign key (
                AC_NAM_ID
            ) references AC_NAM_Actor_Name_Posit(AC_NAM_ID),
            constraint pkAC_NAM_Actor_Name_Annex primary key (
                AC_NAM_ID,
                AC_NAM_Positor,
                AC_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Annex table (of AC_GEN_Actor_Gender_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_GEN_Actor_Gender_Annex (
            AC_GEN_ID number(10) not null,
            AC_GEN_PositedAt timestamp not null,
            AC_GEN_Positor number(5) not null,
            AC_GEN_Reliability number(5,2) not null,
            AC_GEN_Assertion char(1) generated always as (
                case
                    when AC_GEN_Reliability > 0 then '+'
                    when AC_GEN_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_GEN number(10) not null,
            constraint fkAC_GEN_Actor_Gender_Annex foreign key (
                AC_GEN_ID
            ) references AC_GEN_Actor_Gender_Posit(AC_GEN_ID),
            constraint pkAC_GEN_Actor_Gender_Annex primary key (
                AC_GEN_ID,
                AC_GEN_Positor,
                AC_GEN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Annex table (of AC_PLV_Actor_ProfessionalLevel_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_PLV_Actor_ProfessionalLevel_Annex (
            AC_PLV_ID number(10) not null,
            AC_PLV_PositedAt timestamp not null,
            AC_PLV_Positor number(5) not null,
            AC_PLV_Reliability number(5,2) not null,
            AC_PLV_Assertion char(1) generated always as (
                case
                    when AC_PLV_Reliability > 0 then '+'
                    when AC_PLV_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_PLV number(10) not null,
            constraint fkAC_PLV_Actor_ProfessionalLevel_Annex foreign key (
                AC_PLV_ID
            ) references AC_PLV_Actor_ProfessionalLevel_Posit(AC_PLV_ID),
            constraint pkAC_PLV_Actor_ProfessionalLevel_Annex primary key (
                AC_PLV_ID,
                AC_PLV_Positor,
                AC_PLV_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Annex table (of PR_NAM_Program_Name_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_NAM_Program_Name_Annex (
            PR_NAM_ID number(10) not null,
            PR_NAM_PositedAt timestamp not null,
            PR_NAM_Positor number(5) not null,
            PR_NAM_Reliability number(5,2) not null,
            PR_NAM_Assertion char(1) generated always as (
                case
                    when PR_NAM_Reliability > 0 then '+'
                    when PR_NAM_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_PR_NAM number(10) not null,
            constraint fkPR_NAM_Program_Name_Annex foreign key (
                PR_NAM_ID
            ) references PR_NAM_Program_Name_Posit(PR_NAM_ID),
            constraint pkPR_NAM_Program_Name_Annex primary key (
                PR_NAM_ID,
                PR_NAM_Positor,
                PR_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Annex table (of PR_LEN_Program_Length_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_LEN_Program_Length_Annex (
            PR_LEN_ID number(10) not null,
            PR_LEN_PositedAt timestamp not null,
            PR_LEN_Positor number(5) not null,
            PR_LEN_Reliability number(5,2) not null,
            PR_LEN_Assertion char(1) generated always as (
                case
                    when PR_LEN_Reliability > 0 then '+'
                    when PR_LEN_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_PR_LEN number(10) not null,
            constraint fkPR_LEN_Program_Length_Annex foreign key (
                PR_LEN_ID
            ) references PR_LEN_Program_Length_Posit(PR_LEN_ID),
            constraint pkPR_LEN_Program_Length_Annex primary key (
                PR_LEN_ID,
                PR_LEN_Positor,
                PR_LEN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
