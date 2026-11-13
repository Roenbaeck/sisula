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
