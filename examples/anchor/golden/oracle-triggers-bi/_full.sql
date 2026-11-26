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
        CREATE TABLE GRD_Grade (
            GRD_ID number(5) not null,
            GRD_Grade nvarchar2(42) not null,
            Metadata_GRD number(10) not null,
            constraint pkGRD_Grade primary key (
                GRD_ID
            ),
            constraint uqGRD_Grade unique (
                GRD_Grade
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
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_Subject_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_Subject (
            SU_ID number(10) default SU_Subject_ID_SEQ.nextval not null, 
            Metadata_SU number(10) not null,
            constraint pkSU_Subject primary key (
                SU_ID
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
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE OB_Object_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE OB_Object (
            OB_ID number(10) default OB_Object_ID_SEQ.nextval not null, 
            Metadata_OB number(10) not null,
            constraint pkOB_Object primary key (
                OB_ID
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
            SU_ID_for number(10) not null, 
            Metadata_EV number(10) not null, 
            constraint EV_Event_fkSU_for foreign key (
                SU_ID_for
            ) references SU_Subject(SU_ID),
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
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE EV_QTY_Event_Quantity_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_QTY_Event_Quantity_Posit (
            EV_QTY_ID number(10) default EV_QTY_Event_Quantity_Posit_ID_SEQ.nextval not null, 
            EV_QTY_EV_ID number(10) not null,
            EV_QTY_Event_Quantity number(10) not null,
            constraint fkEV_QTY_Event_Quantity_Posit foreign key (
                EV_QTY_EV_ID
            ) references EV_Event(EV_ID),
            constraint pkEV_QTY_Event_Quantity_Posit primary key (
                EV_QTY_ID
            ),
            constraint uqEV_QTY_Event_Quantity_Posit unique (
                EV_QTY_EV_ID,
                EV_QTY_Event_Quantity
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_QTY_Event_Quantity_Annex (
            EV_QTY_ID number(10) not null,
            EV_QTY_PositedAt timestamp not null,
            EV_QTY_Reliability number(5,2) not null,
            Metadata_EV_QTY number(10) not null,
            constraint fkEV_QTY_Event_Quantity_Annex foreign key (
                EV_QTY_ID
            ) references EV_QTY_Event_Quantity_Posit(EV_QTY_ID),
            constraint pkEV_QTY_Event_Quantity_Annex primary key (
                EV_QTY_ID,
                EV_QTY_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE EV_PLC_Event_Place_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_PLC_Event_Place_Posit (
            EV_PLC_ID number(10) default EV_PLC_Event_Place_Posit_ID_SEQ.nextval not null, 
            EV_PLC_EV_ID number(10) not null,
            EV_PLC_Event_Place nvarchar2(42) not null,
            EV_PLC_ChangedAt timestamp not null,
            constraint fkEV_PLC_Event_Place_Posit foreign key (
                EV_PLC_EV_ID
            ) references EV_Event(EV_ID),
            constraint pkEV_PLC_Event_Place_Posit primary key (
                EV_PLC_ID
            ),
            constraint uqEV_PLC_Event_Place_Posit unique (
                EV_PLC_EV_ID,
                EV_PLC_ChangedAt,
                EV_PLC_Event_Place
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_PLC_Event_Place_Annex (
            EV_PLC_ID number(10) not null,
            EV_PLC_PositedAt timestamp not null,
            EV_PLC_Reliability number(5,2) not null,
            Metadata_EV_PLC number(10) not null,
            constraint fkEV_PLC_Event_Place_Annex foreign key (
                EV_PLC_ID
            ) references EV_PLC_Event_Place_Posit(EV_PLC_ID),
            constraint pkEV_PLC_Event_Place_Annex primary key (
                EV_PLC_ID,
                EV_PLC_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_NAM_Subject_Name_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_NAM_Subject_Name_Posit (
            SU_NAM_ID number(10) default SU_NAM_Subject_Name_Posit_ID_SEQ.nextval not null, 
            SU_NAM_SU_ID number(10) not null,
            SU_NAM_Subject_Name nvarchar2(42) not null,
            constraint fkSU_NAM_Subject_Name_Posit foreign key (
                SU_NAM_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_NAM_Subject_Name_Posit primary key (
                SU_NAM_ID
            ),
            constraint uqSU_NAM_Subject_Name_Posit unique (
                SU_NAM_SU_ID,
                SU_NAM_Subject_Name
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_NAM_Subject_Name_Annex (
            SU_NAM_ID number(10) not null,
            SU_NAM_PositedAt timestamp not null,
            SU_NAM_Reliability number(5,2) not null,
            Metadata_SU_NAM number(10) not null,
            constraint fkSU_NAM_Subject_Name_Annex foreign key (
                SU_NAM_ID
            ) references SU_NAM_Subject_Name_Posit(SU_NAM_ID),
            constraint pkSU_NAM_Subject_Name_Annex primary key (
                SU_NAM_ID,
                SU_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_COD_Subject_Code_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_COD_Subject_Code_Posit (
            SU_COD_ID number(10) default SU_COD_Subject_Code_Posit_ID_SEQ.nextval not null, 
            SU_COD_SU_ID number(10) not null,
            SU_COD_Subject_Code nvarchar2(42) not null,
            constraint fkSU_COD_Subject_Code_Posit foreign key (
                SU_COD_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_COD_Subject_Code_Posit primary key (
                SU_COD_ID
            ),
            constraint uqSU_COD_Subject_Code_Posit unique (
                SU_COD_SU_ID,
                SU_COD_Subject_Code
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_COD_Subject_Code_Annex (
            SU_COD_ID number(10) not null,
            SU_COD_PositedAt timestamp not null,
            SU_COD_Reliability number(5,2) not null,
            Metadata_SU_COD number(10) not null,
            constraint fkSU_COD_Subject_Code_Annex foreign key (
                SU_COD_ID
            ) references SU_COD_Subject_Code_Posit(SU_COD_ID),
            constraint pkSU_COD_Subject_Code_Annex primary key (
                SU_COD_ID,
                SU_COD_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_GRD_Subject_Grade_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_GRD_Subject_Grade_Posit (
            SU_GRD_ID number(10) default SU_GRD_Subject_Grade_Posit_ID_SEQ.nextval not null, 
            SU_GRD_SU_ID number(10) not null,
            SU_GRD_GRD_ID number(5) not null,
            constraint fk_A_SU_GRD_Subject_Grade_Posit foreign key (
                SU_GRD_SU_ID
            ) references SU_Subject(SU_ID),
            constraint fk_K_SU_GRD_Subject_Grade_Posit foreign key (
                SU_GRD_GRD_ID
            ) references GRD_Grade(GRD_ID),
            constraint pkSU_GRD_Subject_Grade_Posit primary key (
                SU_GRD_ID
            ),
            constraint uqSU_GRD_Subject_Grade_Posit unique (
                SU_GRD_SU_ID,
                SU_GRD_GRD_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_GRD_Subject_Grade_Annex (
            SU_GRD_ID number(10) not null,
            SU_GRD_PositedAt timestamp not null,
            SU_GRD_Reliability number(5,2) not null,
            Metadata_SU_GRD number(10) not null,
            constraint fkSU_GRD_Subject_Grade_Annex foreign key (
                SU_GRD_ID
            ) references SU_GRD_Subject_Grade_Posit(SU_GRD_ID),
            constraint pkSU_GRD_Subject_Grade_Annex primary key (
                SU_GRD_ID,
                SU_GRD_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_NOT_Subject_Note_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_NOT_Subject_Note_Posit (
            SU_NOT_ID number(10) default SU_NOT_Subject_Note_Posit_ID_SEQ.nextval not null, 
            SU_NOT_SU_ID number(10) not null,
            SU_NOT_Subject_Note nclob not null,
            constraint fkSU_NOT_Subject_Note_Posit foreign key (
                SU_NOT_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_NOT_Subject_Note_Posit primary key (
                SU_NOT_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_NOT_Subject_Note_Annex (
            SU_NOT_ID number(10) not null,
            SU_NOT_PositedAt timestamp not null,
            SU_NOT_Reliability number(5,2) not null,
            Metadata_SU_NOT number(10) not null,
            constraint fkSU_NOT_Subject_Note_Annex foreign key (
                SU_NOT_ID
            ) references SU_NOT_Subject_Note_Posit(SU_NOT_ID),
            constraint pkSU_NOT_Subject_Note_Annex primary key (
                SU_NOT_ID,
                SU_NOT_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_TTL_Subject_Title_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TTL_Subject_Title_Posit (
            SU_TTL_ID number(10) default SU_TTL_Subject_Title_Posit_ID_SEQ.nextval not null, 
            SU_TTL_SU_ID number(10) not null,
            SU_TTL_Subject_Title nvarchar2(42) not null,
            SU_TTL_ChangedAt timestamp not null,
            constraint fkSU_TTL_Subject_Title_Posit foreign key (
                SU_TTL_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_TTL_Subject_Title_Posit primary key (
                SU_TTL_ID
            ),
            constraint uqSU_TTL_Subject_Title_Posit unique (
                SU_TTL_SU_ID,
                SU_TTL_ChangedAt,
                SU_TTL_Subject_Title
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TTL_Subject_Title_Annex (
            SU_TTL_ID number(10) not null,
            SU_TTL_PositedAt timestamp not null,
            SU_TTL_Reliability number(5,2) not null,
            Metadata_SU_TTL number(10) not null,
            constraint fkSU_TTL_Subject_Title_Annex foreign key (
                SU_TTL_ID
            ) references SU_TTL_Subject_Title_Posit(SU_TTL_ID),
            constraint pkSU_TTL_Subject_Title_Annex primary key (
                SU_TTL_ID,
                SU_TTL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_STA_Subject_State_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_STA_Subject_State_Posit (
            SU_STA_ID number(10) default SU_STA_Subject_State_Posit_ID_SEQ.nextval not null, 
            SU_STA_SU_ID number(10) not null,
            SU_STA_Subject_State nvarchar2(42) not null,
            SU_STA_ChangedAt timestamp not null,
            constraint fkSU_STA_Subject_State_Posit foreign key (
                SU_STA_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_STA_Subject_State_Posit primary key (
                SU_STA_ID
            ),
            constraint uqSU_STA_Subject_State_Posit unique (
                SU_STA_SU_ID,
                SU_STA_ChangedAt,
                SU_STA_Subject_State
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_STA_Subject_State_Annex (
            SU_STA_ID number(10) not null,
            SU_STA_PositedAt timestamp not null,
            SU_STA_Reliability number(5,2) not null,
            Metadata_SU_STA number(10) not null,
            constraint fkSU_STA_Subject_State_Annex foreign key (
                SU_STA_ID
            ) references SU_STA_Subject_State_Posit(SU_STA_ID),
            constraint pkSU_STA_Subject_State_Annex primary key (
                SU_STA_ID,
                SU_STA_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_LBL_Subject_Label_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_LBL_Subject_Label_Posit (
            SU_LBL_ID number(10) default SU_LBL_Subject_Label_Posit_ID_SEQ.nextval not null, 
            SU_LBL_SU_ID number(10) not null,
            SU_LBL_Subject_Label nvarchar2(42) not null,
            SU_LBL_ChangedAt timestamp not null,
            constraint fkSU_LBL_Subject_Label_Posit foreign key (
                SU_LBL_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_LBL_Subject_Label_Posit primary key (
                SU_LBL_ID
            ),
            constraint uqSU_LBL_Subject_Label_Posit unique (
                SU_LBL_SU_ID,
                SU_LBL_ChangedAt,
                SU_LBL_Subject_Label
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_LBL_Subject_Label_Annex (
            SU_LBL_ID number(10) not null,
            SU_LBL_PositedAt timestamp not null,
            SU_LBL_Reliability number(5,2) not null,
            Metadata_SU_LBL number(10) not null,
            constraint fkSU_LBL_Subject_Label_Annex foreign key (
                SU_LBL_ID
            ) references SU_LBL_Subject_Label_Posit(SU_LBL_ID),
            constraint pkSU_LBL_Subject_Label_Annex primary key (
                SU_LBL_ID,
                SU_LBL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_TAG_Subject_Tag_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TAG_Subject_Tag_Posit (
            SU_TAG_ID number(10) default SU_TAG_Subject_Tag_Posit_ID_SEQ.nextval not null, 
            SU_TAG_SU_ID number(10) not null,
            SU_TAG_Subject_Tag nvarchar2(42) not null,
            SU_TAG_ChangedAt timestamp not null,
            constraint fkSU_TAG_Subject_Tag_Posit foreign key (
                SU_TAG_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_TAG_Subject_Tag_Posit primary key (
                SU_TAG_ID
            ),
            constraint uqSU_TAG_Subject_Tag_Posit unique (
                SU_TAG_SU_ID,
                SU_TAG_ChangedAt,
                SU_TAG_Subject_Tag
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TAG_Subject_Tag_Annex (
            SU_TAG_ID number(10) not null,
            SU_TAG_PositedAt timestamp not null,
            SU_TAG_Reliability number(5,2) not null,
            Metadata_SU_TAG number(10) not null,
            constraint fkSU_TAG_Subject_Tag_Annex foreign key (
                SU_TAG_ID
            ) references SU_TAG_Subject_Tag_Posit(SU_TAG_ID),
            constraint pkSU_TAG_Subject_Tag_Annex primary key (
                SU_TAG_ID,
                SU_TAG_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_LVL_Subject_Level_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_LVL_Subject_Level_Posit (
            SU_LVL_ID number(10) default SU_LVL_Subject_Level_Posit_ID_SEQ.nextval not null, 
            SU_LVL_SU_ID number(10) not null,
            SU_LVL_GRD_ID number(5) not null,
            SU_LVL_ChangedAt timestamp not null,
            constraint fk_A_SU_LVL_Subject_Level_Posit foreign key (
                SU_LVL_SU_ID
            ) references SU_Subject(SU_ID),
            constraint fk_K_SU_LVL_Subject_Level_Posit foreign key (
                SU_LVL_GRD_ID
            ) references GRD_Grade(GRD_ID),
            constraint pkSU_LVL_Subject_Level_Posit primary key (
                SU_LVL_ID
            ),
            constraint uqSU_LVL_Subject_Level_Posit unique (
                SU_LVL_SU_ID,
                SU_LVL_ChangedAt,
                SU_LVL_GRD_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_LVL_Subject_Level_Annex (
            SU_LVL_ID number(10) not null,
            SU_LVL_PositedAt timestamp not null,
            SU_LVL_Reliability number(5,2) not null,
            Metadata_SU_LVL number(10) not null,
            constraint fkSU_LVL_Subject_Level_Annex foreign key (
                SU_LVL_ID
            ) references SU_LVL_Subject_Level_Posit(SU_LVL_ID),
            constraint pkSU_LVL_Subject_Level_Annex primary key (
                SU_LVL_ID,
                SU_LVL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_TXT_Subject_Text_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TXT_Subject_Text_Posit (
            SU_TXT_ID number(10) default SU_TXT_Subject_Text_Posit_ID_SEQ.nextval not null, 
            SU_TXT_SU_ID number(10) not null,
            SU_TXT_Subject_Text nclob not null,
            SU_TXT_ChangedAt timestamp not null,
            constraint fkSU_TXT_Subject_Text_Posit foreign key (
                SU_TXT_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_TXT_Subject_Text_Posit primary key (
                SU_TXT_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TXT_Subject_Text_Annex (
            SU_TXT_ID number(10) not null,
            SU_TXT_PositedAt timestamp not null,
            SU_TXT_Reliability number(5,2) not null,
            Metadata_SU_TXT number(10) not null,
            constraint fkSU_TXT_Subject_Text_Annex foreign key (
                SU_TXT_ID
            ) references SU_TXT_Subject_Text_Posit(SU_TXT_ID),
            constraint pkSU_TXT_Subject_Text_Annex primary key (
                SU_TXT_ID,
                SU_TXT_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_ASR_Subject_Assessment_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_ASR_Subject_Assessment_Posit (
            SU_ASR_ID number(10) default SU_ASR_Subject_Assessment_Posit_ID_SEQ.nextval not null, 
            SU_ASR_SU_ID number(10) not null,
            SU_ASR_Subject_Assessment nvarchar2(42) not null,
            SU_ASR_ChangedAt timestamp not null,
            constraint fkSU_ASR_Subject_Assessment_Posit foreign key (
                SU_ASR_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_ASR_Subject_Assessment_Posit primary key (
                SU_ASR_ID
            ),
            constraint uqSU_ASR_Subject_Assessment_Posit unique (
                SU_ASR_SU_ID,
                SU_ASR_ChangedAt,
                SU_ASR_Subject_Assessment
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_ASR_Subject_Assessment_Annex (
            SU_ASR_ID number(10) not null,
            SU_ASR_PositedAt timestamp not null,
            SU_ASR_Reliability number(5,2) not null,
            Metadata_SU_ASR number(10) not null,
            constraint fkSU_ASR_Subject_Assessment_Annex foreign key (
                SU_ASR_ID
            ) references SU_ASR_Subject_Assessment_Posit(SU_ASR_ID),
            constraint pkSU_ASR_Subject_Assessment_Annex primary key (
                SU_ASR_ID,
                SU_ASR_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_ERS_Subject_Erasable_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_ERS_Subject_Erasable_Posit (
            SU_ERS_ID number(10) default SU_ERS_Subject_Erasable_Posit_ID_SEQ.nextval not null, 
            SU_ERS_SU_ID number(10) not null,
            SU_ERS_Subject_Erasable nvarchar2(42) not null,
            SU_ERS_ChangedAt timestamp not null,
            constraint fkSU_ERS_Subject_Erasable_Posit foreign key (
                SU_ERS_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_ERS_Subject_Erasable_Posit primary key (
                SU_ERS_ID
            ),
            constraint uqSU_ERS_Subject_Erasable_Posit unique (
                SU_ERS_SU_ID,
                SU_ERS_ChangedAt,
                SU_ERS_Subject_Erasable
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_ERS_Subject_Erasable_Annex (
            SU_ERS_ID number(10) not null,
            SU_ERS_PositedAt timestamp not null,
            SU_ERS_Reliability number(5,2) not null,
            Metadata_SU_ERS number(10) not null,
            constraint fkSU_ERS_Subject_Erasable_Annex foreign key (
                SU_ERS_ID
            ) references SU_ERS_Subject_Erasable_Posit(SU_ERS_ID),
            constraint pkSU_ERS_Subject_Erasable_Annex primary key (
                SU_ERS_ID,
                SU_ERS_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE OB_NAM_Object_Name_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE OB_NAM_Object_Name_Posit (
            OB_NAM_ID number(10) default OB_NAM_Object_Name_Posit_ID_SEQ.nextval not null, 
            OB_NAM_OB_ID number(10) not null,
            OB_NAM_Object_Name nvarchar2(42) not null,
            constraint fkOB_NAM_Object_Name_Posit foreign key (
                OB_NAM_OB_ID
            ) references OB_Object(OB_ID),
            constraint pkOB_NAM_Object_Name_Posit primary key (
                OB_NAM_ID
            ),
            constraint uqOB_NAM_Object_Name_Posit unique (
                OB_NAM_OB_ID,
                OB_NAM_Object_Name
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE OB_NAM_Object_Name_Annex (
            OB_NAM_ID number(10) not null,
            OB_NAM_PositedAt timestamp not null,
            OB_NAM_Reliability number(5,2) not null,
            Metadata_OB_NAM number(10) not null,
            constraint fkOB_NAM_Object_Name_Annex foreign key (
                OB_NAM_ID
            ) references OB_NAM_Object_Name_Posit(OB_NAM_ID),
            constraint pkOB_NAM_Object_Name_Annex primary key (
                OB_NAM_ID,
                OB_NAM_PositedAt
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
CREATE OR REPLACE VIEW EV_QTY_Event_Quantity AS
SELECT
    a.Metadata_EV_QTY,
    p.EV_QTY_ID,
    p.EV_QTY_EV_ID,
    p.EV_QTY_Event_Quantity,
    a.EV_QTY_PositedAt,
    a.EV_QTY_Reliability
FROM
    EV_QTY_Event_Quantity_Posit p
JOIN
    EV_QTY_Event_Quantity_Annex a
ON
    a.EV_QTY_ID = p.EV_QTY_ID
;
CREATE OR REPLACE VIEW EV_PLC_Event_Place AS
SELECT
    a.Metadata_EV_PLC,
    p.EV_PLC_ID,
    p.EV_PLC_EV_ID,
    p.EV_PLC_Event_Place,
    p.EV_PLC_ChangedAt,
    a.EV_PLC_PositedAt,
    a.EV_PLC_Reliability
FROM
    EV_PLC_Event_Place_Posit p
JOIN
    EV_PLC_Event_Place_Annex a
ON
    a.EV_PLC_ID = p.EV_PLC_ID
;
CREATE OR REPLACE VIEW SU_NAM_Subject_Name AS
SELECT
    a.Metadata_SU_NAM,
    p.SU_NAM_ID,
    p.SU_NAM_SU_ID,
    p.SU_NAM_Subject_Name,
    a.SU_NAM_PositedAt,
    a.SU_NAM_Reliability
FROM
    SU_NAM_Subject_Name_Posit p
JOIN
    SU_NAM_Subject_Name_Annex a
ON
    a.SU_NAM_ID = p.SU_NAM_ID
;
CREATE OR REPLACE VIEW SU_COD_Subject_Code AS
SELECT
    a.Metadata_SU_COD,
    p.SU_COD_ID,
    p.SU_COD_SU_ID,
    p.SU_COD_Subject_Code,
    a.SU_COD_PositedAt,
    a.SU_COD_Reliability
FROM
    SU_COD_Subject_Code_Posit p
JOIN
    SU_COD_Subject_Code_Annex a
ON
    a.SU_COD_ID = p.SU_COD_ID
;
CREATE OR REPLACE VIEW SU_GRD_Subject_Grade AS
SELECT
    a.Metadata_SU_GRD,
    p.SU_GRD_ID,
    p.SU_GRD_SU_ID,
    p.SU_GRD_GRD_ID,
    a.SU_GRD_PositedAt,
    a.SU_GRD_Reliability
FROM
    SU_GRD_Subject_Grade_Posit p
JOIN
    SU_GRD_Subject_Grade_Annex a
ON
    a.SU_GRD_ID = p.SU_GRD_ID
;
CREATE OR REPLACE VIEW SU_NOT_Subject_Note AS
SELECT
    a.Metadata_SU_NOT,
    p.SU_NOT_ID,
    p.SU_NOT_SU_ID,
    p.SU_NOT_Subject_Note,
    a.SU_NOT_PositedAt,
    a.SU_NOT_Reliability
FROM
    SU_NOT_Subject_Note_Posit p
JOIN
    SU_NOT_Subject_Note_Annex a
ON
    a.SU_NOT_ID = p.SU_NOT_ID
;
CREATE OR REPLACE VIEW SU_TTL_Subject_Title AS
SELECT
    a.Metadata_SU_TTL,
    p.SU_TTL_ID,
    p.SU_TTL_SU_ID,
    p.SU_TTL_Subject_Title,
    p.SU_TTL_ChangedAt,
    a.SU_TTL_PositedAt,
    a.SU_TTL_Reliability
FROM
    SU_TTL_Subject_Title_Posit p
JOIN
    SU_TTL_Subject_Title_Annex a
ON
    a.SU_TTL_ID = p.SU_TTL_ID
;
CREATE OR REPLACE VIEW SU_STA_Subject_State AS
SELECT
    a.Metadata_SU_STA,
    p.SU_STA_ID,
    p.SU_STA_SU_ID,
    p.SU_STA_Subject_State,
    p.SU_STA_ChangedAt,
    a.SU_STA_PositedAt,
    a.SU_STA_Reliability
FROM
    SU_STA_Subject_State_Posit p
JOIN
    SU_STA_Subject_State_Annex a
ON
    a.SU_STA_ID = p.SU_STA_ID
;
CREATE OR REPLACE VIEW SU_LBL_Subject_Label AS
SELECT
    a.Metadata_SU_LBL,
    p.SU_LBL_ID,
    p.SU_LBL_SU_ID,
    p.SU_LBL_Subject_Label,
    p.SU_LBL_ChangedAt,
    a.SU_LBL_PositedAt,
    a.SU_LBL_Reliability
FROM
    SU_LBL_Subject_Label_Posit p
JOIN
    SU_LBL_Subject_Label_Annex a
ON
    a.SU_LBL_ID = p.SU_LBL_ID
;
CREATE OR REPLACE VIEW SU_TAG_Subject_Tag AS
SELECT
    a.Metadata_SU_TAG,
    p.SU_TAG_ID,
    p.SU_TAG_SU_ID,
    p.SU_TAG_Subject_Tag,
    p.SU_TAG_ChangedAt,
    a.SU_TAG_PositedAt,
    a.SU_TAG_Reliability
FROM
    SU_TAG_Subject_Tag_Posit p
JOIN
    SU_TAG_Subject_Tag_Annex a
ON
    a.SU_TAG_ID = p.SU_TAG_ID
;
CREATE OR REPLACE VIEW SU_LVL_Subject_Level AS
SELECT
    a.Metadata_SU_LVL,
    p.SU_LVL_ID,
    p.SU_LVL_SU_ID,
    p.SU_LVL_GRD_ID,
    p.SU_LVL_ChangedAt,
    a.SU_LVL_PositedAt,
    a.SU_LVL_Reliability
FROM
    SU_LVL_Subject_Level_Posit p
JOIN
    SU_LVL_Subject_Level_Annex a
ON
    a.SU_LVL_ID = p.SU_LVL_ID
;
CREATE OR REPLACE VIEW SU_TXT_Subject_Text AS
SELECT
    a.Metadata_SU_TXT,
    p.SU_TXT_ID,
    p.SU_TXT_SU_ID,
    p.SU_TXT_Subject_Text,
    p.SU_TXT_ChangedAt,
    a.SU_TXT_PositedAt,
    a.SU_TXT_Reliability
FROM
    SU_TXT_Subject_Text_Posit p
JOIN
    SU_TXT_Subject_Text_Annex a
ON
    a.SU_TXT_ID = p.SU_TXT_ID
;
CREATE OR REPLACE VIEW SU_ASR_Subject_Assessment AS
SELECT
    a.Metadata_SU_ASR,
    p.SU_ASR_ID,
    p.SU_ASR_SU_ID,
    p.SU_ASR_Subject_Assessment,
    p.SU_ASR_ChangedAt,
    a.SU_ASR_PositedAt,
    a.SU_ASR_Reliability
FROM
    SU_ASR_Subject_Assessment_Posit p
JOIN
    SU_ASR_Subject_Assessment_Annex a
ON
    a.SU_ASR_ID = p.SU_ASR_ID
;
CREATE OR REPLACE VIEW SU_ERS_Subject_Erasable AS
SELECT
    a.Metadata_SU_ERS,
    p.SU_ERS_ID,
    p.SU_ERS_SU_ID,
    p.SU_ERS_Subject_Erasable,
    p.SU_ERS_ChangedAt,
    a.SU_ERS_PositedAt,
    a.SU_ERS_Reliability
FROM
    SU_ERS_Subject_Erasable_Posit p
JOIN
    SU_ERS_Subject_Erasable_Annex a
ON
    a.SU_ERS_ID = p.SU_ERS_ID
;
CREATE OR REPLACE VIEW OB_NAM_Object_Name AS
SELECT
    a.Metadata_OB_NAM,
    p.OB_NAM_ID,
    p.OB_NAM_OB_ID,
    p.OB_NAM_Object_Name,
    a.OB_NAM_PositedAt,
    a.OB_NAM_Reliability
FROM
    OB_NAM_Object_Name_Posit p
JOIN
    OB_NAM_Object_Name_Annex a
ON
    a.OB_NAM_ID = p.OB_NAM_ID
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
CREATE OR REPLACE FUNCTION rEV_QTY_Event_Quantity_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_PositedAt,
            EV_QTY_Reliability
        FROM
            EV_QTY_Event_Quantity_Annex
        WHERE
            EV_QTY_PositedAt <= positingTimepoint
    ]';
END rEV_QTY_Event_Quantity_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_QTY_Event_Quantity (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_PositedAt,
            EV_QTY_Reliability,
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity
        FROM (
            SELECT
                a.Metadata_EV_QTY,
                p.EV_QTY_ID,
                a.EV_QTY_PositedAt,
                a.EV_QTY_Reliability,
                p.EV_QTY_EV_ID,
                p.EV_QTY_Event_Quantity,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_QTY_ID
                    ORDER BY
                        a.EV_QTY_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_QTY_Event_Quantity_Posit p
            JOIN
                EV_QTY_Event_Quantity_Annex a
            ON
                a.EV_QTY_ID = p.EV_QTY_ID
            WHERE
                a.EV_QTY_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_QTY_Event_Quantity;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_PLC_Event_Place_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_PLC_ID,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt
        FROM
            EV_PLC_Event_Place_Posit
        WHERE
            EV_PLC_ChangedAt <= changingTimepoint
    ]';
END rEV_PLC_Event_Place_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fEV_PLC_Event_Place_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_PLC_ID,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt
        FROM
            EV_PLC_Event_Place_Posit
        WHERE
            EV_PLC_ChangedAt > changingTimepoint
    ]';
END fEV_PLC_Event_Place_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_PLC_Event_Place_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_PositedAt,
            EV_PLC_Reliability
        FROM
            EV_PLC_Event_Place_Annex
        WHERE
            EV_PLC_PositedAt <= positingTimepoint
    ]';
END rEV_PLC_Event_Place_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_PLC_Event_Place (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_PositedAt,
            EV_PLC_Reliability,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_PLC,
                p.EV_PLC_ID,
                a.EV_PLC_PositedAt,
                a.EV_PLC_Reliability,
                p.EV_PLC_EV_ID,
                p.EV_PLC_Event_Place,
                p.EV_PLC_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_PLC_ID
                    ORDER BY
                        a.EV_PLC_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_PLC_Event_Place_Posit p
            JOIN
                EV_PLC_Event_Place_Annex a
            ON
                a.EV_PLC_ID = p.EV_PLC_ID
            WHERE
                p.EV_PLC_ChangedAt <= changingTimepoint
            AND
                a.EV_PLC_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_PLC_Event_Place;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fEV_PLC_Event_Place (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_PositedAt,
            EV_PLC_Reliability,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_PLC,
                p.EV_PLC_ID,
                a.EV_PLC_PositedAt,
                a.EV_PLC_Reliability,
                p.EV_PLC_EV_ID,
                p.EV_PLC_Event_Place,
                p.EV_PLC_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_PLC_ID
                    ORDER BY
                        a.EV_PLC_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_PLC_Event_Place_Posit p
            JOIN
                EV_PLC_Event_Place_Annex a
            ON
                a.EV_PLC_ID = p.EV_PLC_ID
            WHERE
                p.EV_PLC_ChangedAt > changingTimepoint
            AND
                a.EV_PLC_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_PLC_Event_Place;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_NAM_Subject_Name_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_PositedAt,
            SU_NAM_Reliability
        FROM
            SU_NAM_Subject_Name_Annex
        WHERE
            SU_NAM_PositedAt <= positingTimepoint
    ]';
END rSU_NAM_Subject_Name_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_NAM_Subject_Name (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_PositedAt,
            SU_NAM_Reliability,
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name
        FROM (
            SELECT
                a.Metadata_SU_NAM,
                p.SU_NAM_ID,
                a.SU_NAM_PositedAt,
                a.SU_NAM_Reliability,
                p.SU_NAM_SU_ID,
                p.SU_NAM_Subject_Name,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_NAM_ID
                    ORDER BY
                        a.SU_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_NAM_Subject_Name_Posit p
            JOIN
                SU_NAM_Subject_Name_Annex a
            ON
                a.SU_NAM_ID = p.SU_NAM_ID
            WHERE
                a.SU_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_NAM_Subject_Name;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_COD_Subject_Code_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_PositedAt,
            SU_COD_Reliability
        FROM
            SU_COD_Subject_Code_Annex
        WHERE
            SU_COD_PositedAt <= positingTimepoint
    ]';
END rSU_COD_Subject_Code_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_COD_Subject_Code (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_PositedAt,
            SU_COD_Reliability,
            SU_COD_SU_ID,
            SU_COD_Subject_Code
        FROM (
            SELECT
                a.Metadata_SU_COD,
                p.SU_COD_ID,
                a.SU_COD_PositedAt,
                a.SU_COD_Reliability,
                p.SU_COD_SU_ID,
                p.SU_COD_Subject_Code,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_COD_ID
                    ORDER BY
                        a.SU_COD_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_COD_Subject_Code_Posit p
            JOIN
                SU_COD_Subject_Code_Annex a
            ON
                a.SU_COD_ID = p.SU_COD_ID
            WHERE
                a.SU_COD_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_COD_Subject_Code;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_GRD_Subject_Grade_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Reliability
        FROM
            SU_GRD_Subject_Grade_Annex
        WHERE
            SU_GRD_PositedAt <= positingTimepoint
    ]';
END rSU_GRD_Subject_Grade_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_GRD_Subject_Grade (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Reliability,
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID
        FROM (
            SELECT
                a.Metadata_SU_GRD,
                p.SU_GRD_ID,
                a.SU_GRD_PositedAt,
                a.SU_GRD_Reliability,
                p.SU_GRD_SU_ID,
                p.SU_GRD_GRD_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_GRD_ID
                    ORDER BY
                        a.SU_GRD_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_GRD_Subject_Grade_Posit p
            JOIN
                SU_GRD_Subject_Grade_Annex a
            ON
                a.SU_GRD_ID = p.SU_GRD_ID
            WHERE
                a.SU_GRD_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_GRD_Subject_Grade;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_NOT_Subject_Note_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_PositedAt,
            SU_NOT_Reliability
        FROM
            SU_NOT_Subject_Note_Annex
        WHERE
            SU_NOT_PositedAt <= positingTimepoint
    ]';
END rSU_NOT_Subject_Note_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_NOT_Subject_Note (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_PositedAt,
            SU_NOT_Reliability,
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note
        FROM (
            SELECT
                a.Metadata_SU_NOT,
                p.SU_NOT_ID,
                a.SU_NOT_PositedAt,
                a.SU_NOT_Reliability,
                p.SU_NOT_SU_ID,
                p.SU_NOT_Subject_Note,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_NOT_ID
                    ORDER BY
                        a.SU_NOT_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_NOT_Subject_Note_Posit p
            JOIN
                SU_NOT_Subject_Note_Annex a
            ON
                a.SU_NOT_ID = p.SU_NOT_ID
            WHERE
                a.SU_NOT_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_NOT_Subject_Note;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TTL_Subject_Title_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TTL_ID,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt
        FROM
            SU_TTL_Subject_Title_Posit
        WHERE
            SU_TTL_ChangedAt <= changingTimepoint
    ]';
END rSU_TTL_Subject_Title_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TTL_Subject_Title_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TTL_ID,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt
        FROM
            SU_TTL_Subject_Title_Posit
        WHERE
            SU_TTL_ChangedAt > changingTimepoint
    ]';
END fSU_TTL_Subject_Title_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TTL_Subject_Title_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_PositedAt,
            SU_TTL_Reliability
        FROM
            SU_TTL_Subject_Title_Annex
        WHERE
            SU_TTL_PositedAt <= positingTimepoint
    ]';
END rSU_TTL_Subject_Title_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TTL_Subject_Title (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_PositedAt,
            SU_TTL_Reliability,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TTL,
                p.SU_TTL_ID,
                a.SU_TTL_PositedAt,
                a.SU_TTL_Reliability,
                p.SU_TTL_SU_ID,
                p.SU_TTL_Subject_Title,
                p.SU_TTL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TTL_ID
                    ORDER BY
                        a.SU_TTL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TTL_Subject_Title_Posit p
            JOIN
                SU_TTL_Subject_Title_Annex a
            ON
                a.SU_TTL_ID = p.SU_TTL_ID
            WHERE
                p.SU_TTL_ChangedAt <= changingTimepoint
            AND
                a.SU_TTL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_TTL_Subject_Title;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TTL_Subject_Title (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_PositedAt,
            SU_TTL_Reliability,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TTL,
                p.SU_TTL_ID,
                a.SU_TTL_PositedAt,
                a.SU_TTL_Reliability,
                p.SU_TTL_SU_ID,
                p.SU_TTL_Subject_Title,
                p.SU_TTL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TTL_ID
                    ORDER BY
                        a.SU_TTL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TTL_Subject_Title_Posit p
            JOIN
                SU_TTL_Subject_Title_Annex a
            ON
                a.SU_TTL_ID = p.SU_TTL_ID
            WHERE
                p.SU_TTL_ChangedAt > changingTimepoint
            AND
                a.SU_TTL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_TTL_Subject_Title;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_STA_Subject_State_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_STA_ID,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt
        FROM
            SU_STA_Subject_State_Posit
        WHERE
            SU_STA_ChangedAt <= changingTimepoint
    ]';
END rSU_STA_Subject_State_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_STA_Subject_State_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_STA_ID,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt
        FROM
            SU_STA_Subject_State_Posit
        WHERE
            SU_STA_ChangedAt > changingTimepoint
    ]';
END fSU_STA_Subject_State_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_STA_Subject_State_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_PositedAt,
            SU_STA_Reliability
        FROM
            SU_STA_Subject_State_Annex
        WHERE
            SU_STA_PositedAt <= positingTimepoint
    ]';
END rSU_STA_Subject_State_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_STA_Subject_State (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_PositedAt,
            SU_STA_Reliability,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_STA,
                p.SU_STA_ID,
                a.SU_STA_PositedAt,
                a.SU_STA_Reliability,
                p.SU_STA_SU_ID,
                p.SU_STA_Subject_State,
                p.SU_STA_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_STA_ID
                    ORDER BY
                        a.SU_STA_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_STA_Subject_State_Posit p
            JOIN
                SU_STA_Subject_State_Annex a
            ON
                a.SU_STA_ID = p.SU_STA_ID
            WHERE
                p.SU_STA_ChangedAt <= changingTimepoint
            AND
                a.SU_STA_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_STA_Subject_State;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_STA_Subject_State (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_PositedAt,
            SU_STA_Reliability,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_STA,
                p.SU_STA_ID,
                a.SU_STA_PositedAt,
                a.SU_STA_Reliability,
                p.SU_STA_SU_ID,
                p.SU_STA_Subject_State,
                p.SU_STA_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_STA_ID
                    ORDER BY
                        a.SU_STA_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_STA_Subject_State_Posit p
            JOIN
                SU_STA_Subject_State_Annex a
            ON
                a.SU_STA_ID = p.SU_STA_ID
            WHERE
                p.SU_STA_ChangedAt > changingTimepoint
            AND
                a.SU_STA_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_STA_Subject_State;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LBL_Subject_Label_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_LBL_ID,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt
        FROM
            SU_LBL_Subject_Label_Posit
        WHERE
            SU_LBL_ChangedAt <= changingTimepoint
    ]';
END rSU_LBL_Subject_Label_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_LBL_Subject_Label_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_LBL_ID,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt
        FROM
            SU_LBL_Subject_Label_Posit
        WHERE
            SU_LBL_ChangedAt > changingTimepoint
    ]';
END fSU_LBL_Subject_Label_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LBL_Subject_Label_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_PositedAt,
            SU_LBL_Reliability
        FROM
            SU_LBL_Subject_Label_Annex
        WHERE
            SU_LBL_PositedAt <= positingTimepoint
    ]';
END rSU_LBL_Subject_Label_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LBL_Subject_Label (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_PositedAt,
            SU_LBL_Reliability,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_LBL,
                p.SU_LBL_ID,
                a.SU_LBL_PositedAt,
                a.SU_LBL_Reliability,
                p.SU_LBL_SU_ID,
                p.SU_LBL_Subject_Label,
                p.SU_LBL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_LBL_ID
                    ORDER BY
                        a.SU_LBL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_LBL_Subject_Label_Posit p
            JOIN
                SU_LBL_Subject_Label_Annex a
            ON
                a.SU_LBL_ID = p.SU_LBL_ID
            WHERE
                p.SU_LBL_ChangedAt <= changingTimepoint
            AND
                a.SU_LBL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_LBL_Subject_Label;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_LBL_Subject_Label (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_PositedAt,
            SU_LBL_Reliability,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_LBL,
                p.SU_LBL_ID,
                a.SU_LBL_PositedAt,
                a.SU_LBL_Reliability,
                p.SU_LBL_SU_ID,
                p.SU_LBL_Subject_Label,
                p.SU_LBL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_LBL_ID
                    ORDER BY
                        a.SU_LBL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_LBL_Subject_Label_Posit p
            JOIN
                SU_LBL_Subject_Label_Annex a
            ON
                a.SU_LBL_ID = p.SU_LBL_ID
            WHERE
                p.SU_LBL_ChangedAt > changingTimepoint
            AND
                a.SU_LBL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_LBL_Subject_Label;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TAG_Subject_Tag_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TAG_ID,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt
        FROM
            SU_TAG_Subject_Tag_Posit
        WHERE
            SU_TAG_ChangedAt <= changingTimepoint
    ]';
END rSU_TAG_Subject_Tag_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TAG_Subject_Tag_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TAG_ID,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt
        FROM
            SU_TAG_Subject_Tag_Posit
        WHERE
            SU_TAG_ChangedAt > changingTimepoint
    ]';
END fSU_TAG_Subject_Tag_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TAG_Subject_Tag_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_PositedAt,
            SU_TAG_Reliability
        FROM
            SU_TAG_Subject_Tag_Annex
        WHERE
            SU_TAG_PositedAt <= positingTimepoint
    ]';
END rSU_TAG_Subject_Tag_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TAG_Subject_Tag (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_PositedAt,
            SU_TAG_Reliability,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TAG,
                p.SU_TAG_ID,
                a.SU_TAG_PositedAt,
                a.SU_TAG_Reliability,
                p.SU_TAG_SU_ID,
                p.SU_TAG_Subject_Tag,
                p.SU_TAG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TAG_ID
                    ORDER BY
                        a.SU_TAG_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TAG_Subject_Tag_Posit p
            JOIN
                SU_TAG_Subject_Tag_Annex a
            ON
                a.SU_TAG_ID = p.SU_TAG_ID
            WHERE
                p.SU_TAG_ChangedAt <= changingTimepoint
            AND
                a.SU_TAG_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_TAG_Subject_Tag;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TAG_Subject_Tag (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_PositedAt,
            SU_TAG_Reliability,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TAG,
                p.SU_TAG_ID,
                a.SU_TAG_PositedAt,
                a.SU_TAG_Reliability,
                p.SU_TAG_SU_ID,
                p.SU_TAG_Subject_Tag,
                p.SU_TAG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TAG_ID
                    ORDER BY
                        a.SU_TAG_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TAG_Subject_Tag_Posit p
            JOIN
                SU_TAG_Subject_Tag_Annex a
            ON
                a.SU_TAG_ID = p.SU_TAG_ID
            WHERE
                p.SU_TAG_ChangedAt > changingTimepoint
            AND
                a.SU_TAG_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_TAG_Subject_Tag;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LVL_Subject_Level_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_LVL_ID,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt
        FROM
            SU_LVL_Subject_Level_Posit
        WHERE
            SU_LVL_ChangedAt <= changingTimepoint
    ]';
END rSU_LVL_Subject_Level_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_LVL_Subject_Level_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_LVL_ID,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt
        FROM
            SU_LVL_Subject_Level_Posit
        WHERE
            SU_LVL_ChangedAt > changingTimepoint
    ]';
END fSU_LVL_Subject_Level_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LVL_Subject_Level_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_PositedAt,
            SU_LVL_Reliability
        FROM
            SU_LVL_Subject_Level_Annex
        WHERE
            SU_LVL_PositedAt <= positingTimepoint
    ]';
END rSU_LVL_Subject_Level_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LVL_Subject_Level (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_PositedAt,
            SU_LVL_Reliability,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_LVL,
                p.SU_LVL_ID,
                a.SU_LVL_PositedAt,
                a.SU_LVL_Reliability,
                p.SU_LVL_SU_ID,
                p.SU_LVL_GRD_ID,
                p.SU_LVL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_LVL_ID
                    ORDER BY
                        a.SU_LVL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_LVL_Subject_Level_Posit p
            JOIN
                SU_LVL_Subject_Level_Annex a
            ON
                a.SU_LVL_ID = p.SU_LVL_ID
            WHERE
                p.SU_LVL_ChangedAt <= changingTimepoint
            AND
                a.SU_LVL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_LVL_Subject_Level;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_LVL_Subject_Level (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_PositedAt,
            SU_LVL_Reliability,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_LVL,
                p.SU_LVL_ID,
                a.SU_LVL_PositedAt,
                a.SU_LVL_Reliability,
                p.SU_LVL_SU_ID,
                p.SU_LVL_GRD_ID,
                p.SU_LVL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_LVL_ID
                    ORDER BY
                        a.SU_LVL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_LVL_Subject_Level_Posit p
            JOIN
                SU_LVL_Subject_Level_Annex a
            ON
                a.SU_LVL_ID = p.SU_LVL_ID
            WHERE
                p.SU_LVL_ChangedAt > changingTimepoint
            AND
                a.SU_LVL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_LVL_Subject_Level;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TXT_Subject_Text_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TXT_ID,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt
        FROM
            SU_TXT_Subject_Text_Posit
        WHERE
            SU_TXT_ChangedAt <= changingTimepoint
    ]';
END rSU_TXT_Subject_Text_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TXT_Subject_Text_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TXT_ID,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt
        FROM
            SU_TXT_Subject_Text_Posit
        WHERE
            SU_TXT_ChangedAt > changingTimepoint
    ]';
END fSU_TXT_Subject_Text_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TXT_Subject_Text_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_PositedAt,
            SU_TXT_Reliability
        FROM
            SU_TXT_Subject_Text_Annex
        WHERE
            SU_TXT_PositedAt <= positingTimepoint
    ]';
END rSU_TXT_Subject_Text_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TXT_Subject_Text (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_PositedAt,
            SU_TXT_Reliability,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TXT,
                p.SU_TXT_ID,
                a.SU_TXT_PositedAt,
                a.SU_TXT_Reliability,
                p.SU_TXT_SU_ID,
                p.SU_TXT_Subject_Text,
                p.SU_TXT_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TXT_ID
                    ORDER BY
                        a.SU_TXT_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TXT_Subject_Text_Posit p
            JOIN
                SU_TXT_Subject_Text_Annex a
            ON
                a.SU_TXT_ID = p.SU_TXT_ID
            WHERE
                p.SU_TXT_ChangedAt <= changingTimepoint
            AND
                a.SU_TXT_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_TXT_Subject_Text;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TXT_Subject_Text (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_PositedAt,
            SU_TXT_Reliability,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TXT,
                p.SU_TXT_ID,
                a.SU_TXT_PositedAt,
                a.SU_TXT_Reliability,
                p.SU_TXT_SU_ID,
                p.SU_TXT_Subject_Text,
                p.SU_TXT_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TXT_ID
                    ORDER BY
                        a.SU_TXT_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TXT_Subject_Text_Posit p
            JOIN
                SU_TXT_Subject_Text_Annex a
            ON
                a.SU_TXT_ID = p.SU_TXT_ID
            WHERE
                p.SU_TXT_ChangedAt > changingTimepoint
            AND
                a.SU_TXT_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_TXT_Subject_Text;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ASR_Subject_Assessment_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_ASR_ID,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt
        FROM
            SU_ASR_Subject_Assessment_Posit
        WHERE
            SU_ASR_ChangedAt <= changingTimepoint
    ]';
END rSU_ASR_Subject_Assessment_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_ASR_Subject_Assessment_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_ASR_ID,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt
        FROM
            SU_ASR_Subject_Assessment_Posit
        WHERE
            SU_ASR_ChangedAt > changingTimepoint
    ]';
END fSU_ASR_Subject_Assessment_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ASR_Subject_Assessment_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_PositedAt,
            SU_ASR_Reliability
        FROM
            SU_ASR_Subject_Assessment_Annex
        WHERE
            SU_ASR_PositedAt <= positingTimepoint
    ]';
END rSU_ASR_Subject_Assessment_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ASR_Subject_Assessment (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_PositedAt,
            SU_ASR_Reliability,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_ASR,
                p.SU_ASR_ID,
                a.SU_ASR_PositedAt,
                a.SU_ASR_Reliability,
                p.SU_ASR_SU_ID,
                p.SU_ASR_Subject_Assessment,
                p.SU_ASR_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_ASR_ID
                    ORDER BY
                        a.SU_ASR_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_ASR_Subject_Assessment_Posit p
            JOIN
                SU_ASR_Subject_Assessment_Annex a
            ON
                a.SU_ASR_ID = p.SU_ASR_ID
            WHERE
                p.SU_ASR_ChangedAt <= changingTimepoint
            AND
                a.SU_ASR_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_ASR_Subject_Assessment;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_ASR_Subject_Assessment (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_PositedAt,
            SU_ASR_Reliability,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_ASR,
                p.SU_ASR_ID,
                a.SU_ASR_PositedAt,
                a.SU_ASR_Reliability,
                p.SU_ASR_SU_ID,
                p.SU_ASR_Subject_Assessment,
                p.SU_ASR_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_ASR_ID
                    ORDER BY
                        a.SU_ASR_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_ASR_Subject_Assessment_Posit p
            JOIN
                SU_ASR_Subject_Assessment_Annex a
            ON
                a.SU_ASR_ID = p.SU_ASR_ID
            WHERE
                p.SU_ASR_ChangedAt > changingTimepoint
            AND
                a.SU_ASR_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_ASR_Subject_Assessment;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ERS_Subject_Erasable_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_ERS_ID,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt
        FROM
            SU_ERS_Subject_Erasable_Posit
        WHERE
            SU_ERS_ChangedAt <= changingTimepoint
    ]';
END rSU_ERS_Subject_Erasable_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_ERS_Subject_Erasable_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_ERS_ID,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt
        FROM
            SU_ERS_Subject_Erasable_Posit
        WHERE
            SU_ERS_ChangedAt > changingTimepoint
    ]';
END fSU_ERS_Subject_Erasable_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ERS_Subject_Erasable_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_PositedAt,
            SU_ERS_Reliability
        FROM
            SU_ERS_Subject_Erasable_Annex
        WHERE
            SU_ERS_PositedAt <= positingTimepoint
    ]';
END rSU_ERS_Subject_Erasable_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ERS_Subject_Erasable (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_PositedAt,
            SU_ERS_Reliability,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_ERS,
                p.SU_ERS_ID,
                a.SU_ERS_PositedAt,
                a.SU_ERS_Reliability,
                p.SU_ERS_SU_ID,
                p.SU_ERS_Subject_Erasable,
                p.SU_ERS_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_ERS_ID
                    ORDER BY
                        a.SU_ERS_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_ERS_Subject_Erasable_Posit p
            JOIN
                SU_ERS_Subject_Erasable_Annex a
            ON
                a.SU_ERS_ID = p.SU_ERS_ID
            WHERE
                p.SU_ERS_ChangedAt <= changingTimepoint
            AND
                a.SU_ERS_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_ERS_Subject_Erasable;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_ERS_Subject_Erasable (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_PositedAt,
            SU_ERS_Reliability,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_ERS,
                p.SU_ERS_ID,
                a.SU_ERS_PositedAt,
                a.SU_ERS_Reliability,
                p.SU_ERS_SU_ID,
                p.SU_ERS_Subject_Erasable,
                p.SU_ERS_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_ERS_ID
                    ORDER BY
                        a.SU_ERS_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_ERS_Subject_Erasable_Posit p
            JOIN
                SU_ERS_Subject_Erasable_Annex a
            ON
                a.SU_ERS_ID = p.SU_ERS_ID
            WHERE
                p.SU_ERS_ChangedAt > changingTimepoint
            AND
                a.SU_ERS_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_ERS_Subject_Erasable;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rOB_NAM_Object_Name_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_PositedAt,
            OB_NAM_Reliability
        FROM
            OB_NAM_Object_Name_Annex
        WHERE
            OB_NAM_PositedAt <= positingTimepoint
    ]';
END rOB_NAM_Object_Name_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rOB_NAM_Object_Name (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_PositedAt,
            OB_NAM_Reliability,
            OB_NAM_OB_ID,
            OB_NAM_Object_Name
        FROM (
            SELECT
                a.Metadata_OB_NAM,
                p.OB_NAM_ID,
                a.OB_NAM_PositedAt,
                a.OB_NAM_Reliability,
                p.OB_NAM_OB_ID,
                p.OB_NAM_Object_Name,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.OB_NAM_ID
                    ORDER BY
                        a.OB_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                OB_NAM_Object_Name_Posit p
            JOIN
                OB_NAM_Object_Name_Annex a
            ON
                a.OB_NAM_ID = p.OB_NAM_ID
            WHERE
                a.OB_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rOB_NAM_Object_Name;
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
CREATE OR REPLACE FUNCTION tSU_Subject (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "SU".SU_ID,
            "SU".Metadata_SU,
            "NAM".SU_NAM_SU_ID,
            "NAM".Metadata_SU_NAM,
            "NAM".SU_NAM_ID,
            "NAM".SU_NAM_PositedAt,
            "NAM".SU_NAM_Reliability,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_ID,
            "COD".SU_COD_PositedAt,
            "COD".SU_COD_Reliability,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "GRD".SU_GRD_ID,
            "GRD".SU_GRD_PositedAt,
            "GRD".SU_GRD_Reliability,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_ID,
            "NOT".SU_NOT_PositedAt,
            "NOT".SU_NOT_Reliability,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ID,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_PositedAt,
            "TTL".SU_TTL_Reliability,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ID,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_PositedAt,
            "STA".SU_STA_Reliability,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ID,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_PositedAt,
            "LBL".SU_LBL_Reliability,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ID,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_PositedAt,
            "TAG".SU_TAG_Reliability,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ID,
            "LVL".SU_LVL_ChangedAt,
            "LVL".SU_LVL_PositedAt,
            "LVL".SU_LVL_Reliability,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ID,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_PositedAt,
            "TXT".SU_TXT_Reliability,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ID,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_PositedAt,
            "ASR".SU_ASR_Reliability,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ID,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_PositedAt,
            "ERS".SU_ERS_Reliability,
            "ERS".SU_ERS_Subject_Erasable
        FROM
            SU_Subject "SU"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NAM_SU_ID
                        ORDER BY
                            r.SU_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_NAM,
                        po.SU_NAM_ID,
                        an.SU_NAM_PositedAt,
                        an.SU_NAM_Reliability,
                        po.SU_NAM_SU_ID,
                        po.SU_NAM_Subject_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_NAM_ID
                            ORDER BY an.SU_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_NAM_Subject_Name_Posit po
                    JOIN
                        SU_NAM_Subject_Name_Annex an
                    ON
                        an.SU_NAM_ID = po.SU_NAM_ID
                    WHERE
                        an.SU_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_COD_SU_ID
                        ORDER BY
                            r.SU_COD_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_COD,
                        po.SU_COD_ID,
                        an.SU_COD_PositedAt,
                        an.SU_COD_Reliability,
                        po.SU_COD_SU_ID,
                        po.SU_COD_Subject_Code,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_COD_ID
                            ORDER BY an.SU_COD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_COD_Subject_Code_Posit po
                    JOIN
                        SU_COD_Subject_Code_Annex an
                    ON
                        an.SU_COD_ID = po.SU_COD_ID
                    WHERE
                        an.SU_COD_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_COD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_GRD_SU_ID
                        ORDER BY
                            r.SU_GRD_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_GRD,
                        po.SU_GRD_ID,
                        an.SU_GRD_PositedAt,
                        an.SU_GRD_Reliability,
                        po.SU_GRD_SU_ID,
                        po.SU_GRD_GRD_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_GRD_ID
                            ORDER BY an.SU_GRD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_GRD_Subject_Grade_Posit po
                    JOIN
                        SU_GRD_Subject_Grade_Annex an
                    ON
                        an.SU_GRD_ID = po.SU_GRD_ID
                    WHERE
                        an.SU_GRD_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_GRD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kGRD"
        ON
            "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NOT_SU_ID
                        ORDER BY
                            r.SU_NOT_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_NOT,
                        po.SU_NOT_ID,
                        an.SU_NOT_PositedAt,
                        an.SU_NOT_Reliability,
                        po.SU_NOT_SU_ID,
                        po.SU_NOT_Subject_Note,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_NOT_ID
                            ORDER BY an.SU_NOT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_NOT_Subject_Note_Posit po
                    JOIN
                        SU_NOT_Subject_Note_Annex an
                    ON
                        an.SU_NOT_ID = po.SU_NOT_ID
                    WHERE
                        an.SU_NOT_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NOT_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TTL_SU_ID
                        ORDER BY
                            r.SU_TTL_ChangedAt DESC,
                            r.SU_TTL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TTL,
                        po.SU_TTL_ID,
                        an.SU_TTL_PositedAt,
                        an.SU_TTL_Reliability,
                        po.SU_TTL_SU_ID,
                        po.SU_TTL_Subject_Title,
                        po.SU_TTL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TTL_ID
                            ORDER BY an.SU_TTL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TTL_Subject_Title_Posit po
                    JOIN
                        SU_TTL_Subject_Title_Annex an
                    ON
                        an.SU_TTL_ID = po.SU_TTL_ID
                    WHERE
                        po.SU_TTL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TTL_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TTL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_STA_SU_ID
                        ORDER BY
                            r.SU_STA_ChangedAt DESC,
                            r.SU_STA_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_STA,
                        po.SU_STA_ID,
                        an.SU_STA_PositedAt,
                        an.SU_STA_Reliability,
                        po.SU_STA_SU_ID,
                        po.SU_STA_Subject_State,
                        po.SU_STA_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_STA_ID
                            ORDER BY an.SU_STA_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_STA_Subject_State_Posit po
                    JOIN
                        SU_STA_Subject_State_Annex an
                    ON
                        an.SU_STA_ID = po.SU_STA_ID
                    WHERE
                        po.SU_STA_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_STA_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_STA_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_LBL_SU_ID
                        ORDER BY
                            r.SU_LBL_ChangedAt DESC,
                            r.SU_LBL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_LBL,
                        po.SU_LBL_ID,
                        an.SU_LBL_PositedAt,
                        an.SU_LBL_Reliability,
                        po.SU_LBL_SU_ID,
                        po.SU_LBL_Subject_Label,
                        po.SU_LBL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_LBL_ID
                            ORDER BY an.SU_LBL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_LBL_Subject_Label_Posit po
                    JOIN
                        SU_LBL_Subject_Label_Annex an
                    ON
                        an.SU_LBL_ID = po.SU_LBL_ID
                    WHERE
                        po.SU_LBL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_LBL_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_LBL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TAG_SU_ID
                        ORDER BY
                            r.SU_TAG_ChangedAt DESC,
                            r.SU_TAG_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TAG,
                        po.SU_TAG_ID,
                        an.SU_TAG_PositedAt,
                        an.SU_TAG_Reliability,
                        po.SU_TAG_SU_ID,
                        po.SU_TAG_Subject_Tag,
                        po.SU_TAG_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TAG_ID
                            ORDER BY an.SU_TAG_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TAG_Subject_Tag_Posit po
                    JOIN
                        SU_TAG_Subject_Tag_Annex an
                    ON
                        an.SU_TAG_ID = po.SU_TAG_ID
                    WHERE
                        po.SU_TAG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TAG_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TAG_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_LVL_SU_ID
                        ORDER BY
                            r.SU_LVL_ChangedAt DESC,
                            r.SU_LVL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_LVL,
                        po.SU_LVL_ID,
                        an.SU_LVL_PositedAt,
                        an.SU_LVL_Reliability,
                        po.SU_LVL_SU_ID,
                        po.SU_LVL_GRD_ID,
                        po.SU_LVL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_LVL_ID
                            ORDER BY an.SU_LVL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_LVL_Subject_Level_Posit po
                    JOIN
                        SU_LVL_Subject_Level_Annex an
                    ON
                        an.SU_LVL_ID = po.SU_LVL_ID
                    WHERE
                        po.SU_LVL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_LVL_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_LVL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kLVL"
        ON
            "kLVL".GRD_ID = "LVL".SU_LVL_GRD_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TXT_SU_ID
                        ORDER BY
                            r.SU_TXT_ChangedAt DESC,
                            r.SU_TXT_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TXT,
                        po.SU_TXT_ID,
                        an.SU_TXT_PositedAt,
                        an.SU_TXT_Reliability,
                        po.SU_TXT_SU_ID,
                        po.SU_TXT_Subject_Text,
                        po.SU_TXT_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TXT_ID
                            ORDER BY an.SU_TXT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TXT_Subject_Text_Posit po
                    JOIN
                        SU_TXT_Subject_Text_Annex an
                    ON
                        an.SU_TXT_ID = po.SU_TXT_ID
                    WHERE
                        po.SU_TXT_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TXT_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TXT_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_ASR_SU_ID
                        ORDER BY
                            r.SU_ASR_ChangedAt DESC,
                            r.SU_ASR_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_ASR,
                        po.SU_ASR_ID,
                        an.SU_ASR_PositedAt,
                        an.SU_ASR_Reliability,
                        po.SU_ASR_SU_ID,
                        po.SU_ASR_Subject_Assessment,
                        po.SU_ASR_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_ASR_ID
                            ORDER BY an.SU_ASR_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_ASR_Subject_Assessment_Posit po
                    JOIN
                        SU_ASR_Subject_Assessment_Annex an
                    ON
                        an.SU_ASR_ID = po.SU_ASR_ID
                    WHERE
                        po.SU_ASR_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_ASR_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_ASR_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_ERS_SU_ID
                        ORDER BY
                            r.SU_ERS_ChangedAt DESC,
                            r.SU_ERS_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_ERS,
                        po.SU_ERS_ID,
                        an.SU_ERS_PositedAt,
                        an.SU_ERS_Reliability,
                        po.SU_ERS_SU_ID,
                        po.SU_ERS_Subject_Erasable,
                        po.SU_ERS_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_ERS_ID
                            ORDER BY an.SU_ERS_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_ERS_Subject_Erasable_Posit po
                    JOIN
                        SU_ERS_Subject_Erasable_Annex an
                    ON
                        an.SU_ERS_ID = po.SU_ERS_ID
                    WHERE
                        po.SU_ERS_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_ERS_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_ERS_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
    ]';
END tSU_Subject;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What is known now (positing time End of Time) about the changing time, with a reliability that is null since a
-- perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_Subject (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "SU".SU_ID,
            "SU".Metadata_SU,
            "NAM".SU_NAM_SU_ID,
            "NAM".Metadata_SU_NAM,
            "NAM".SU_NAM_ID,
            "NAM".SU_NAM_PositedAt,
            "NAM".SU_NAM_Reliability,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_ID,
            "COD".SU_COD_PositedAt,
            "COD".SU_COD_Reliability,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "GRD".SU_GRD_ID,
            "GRD".SU_GRD_PositedAt,
            "GRD".SU_GRD_Reliability,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_ID,
            "NOT".SU_NOT_PositedAt,
            "NOT".SU_NOT_Reliability,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ID,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_PositedAt,
            "TTL".SU_TTL_Reliability,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ID,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_PositedAt,
            "STA".SU_STA_Reliability,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ID,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_PositedAt,
            "LBL".SU_LBL_Reliability,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ID,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_PositedAt,
            "TAG".SU_TAG_Reliability,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ID,
            "LVL".SU_LVL_ChangedAt,
            "LVL".SU_LVL_PositedAt,
            "LVL".SU_LVL_Reliability,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ID,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_PositedAt,
            "TXT".SU_TXT_Reliability,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ID,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_PositedAt,
            "ASR".SU_ASR_Reliability,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ID,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_PositedAt,
            "ERS".SU_ERS_Reliability,
            "ERS".SU_ERS_Subject_Erasable
        FROM
            SU_Subject "SU"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NAM_SU_ID
                        ORDER BY
                            r.SU_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_NAM,
                        po.SU_NAM_ID,
                        an.SU_NAM_PositedAt,
                        an.SU_NAM_Reliability,
                        po.SU_NAM_SU_ID,
                        po.SU_NAM_Subject_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_NAM_ID
                            ORDER BY an.SU_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_NAM_Subject_Name_Posit po
                    JOIN
                        SU_NAM_Subject_Name_Annex an
                    ON
                        an.SU_NAM_ID = po.SU_NAM_ID
                    WHERE
                        an.SU_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_COD_SU_ID
                        ORDER BY
                            r.SU_COD_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_COD,
                        po.SU_COD_ID,
                        an.SU_COD_PositedAt,
                        an.SU_COD_Reliability,
                        po.SU_COD_SU_ID,
                        po.SU_COD_Subject_Code,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_COD_ID
                            ORDER BY an.SU_COD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_COD_Subject_Code_Posit po
                    JOIN
                        SU_COD_Subject_Code_Annex an
                    ON
                        an.SU_COD_ID = po.SU_COD_ID
                    WHERE
                        an.SU_COD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_COD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_GRD_SU_ID
                        ORDER BY
                            r.SU_GRD_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_GRD,
                        po.SU_GRD_ID,
                        an.SU_GRD_PositedAt,
                        an.SU_GRD_Reliability,
                        po.SU_GRD_SU_ID,
                        po.SU_GRD_GRD_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_GRD_ID
                            ORDER BY an.SU_GRD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_GRD_Subject_Grade_Posit po
                    JOIN
                        SU_GRD_Subject_Grade_Annex an
                    ON
                        an.SU_GRD_ID = po.SU_GRD_ID
                    WHERE
                        an.SU_GRD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_GRD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kGRD"
        ON
            "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NOT_SU_ID
                        ORDER BY
                            r.SU_NOT_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_NOT,
                        po.SU_NOT_ID,
                        an.SU_NOT_PositedAt,
                        an.SU_NOT_Reliability,
                        po.SU_NOT_SU_ID,
                        po.SU_NOT_Subject_Note,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_NOT_ID
                            ORDER BY an.SU_NOT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_NOT_Subject_Note_Posit po
                    JOIN
                        SU_NOT_Subject_Note_Annex an
                    ON
                        an.SU_NOT_ID = po.SU_NOT_ID
                    WHERE
                        an.SU_NOT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NOT_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TTL_SU_ID
                        ORDER BY
                            r.SU_TTL_ChangedAt DESC,
                            r.SU_TTL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TTL,
                        po.SU_TTL_ID,
                        an.SU_TTL_PositedAt,
                        an.SU_TTL_Reliability,
                        po.SU_TTL_SU_ID,
                        po.SU_TTL_Subject_Title,
                        po.SU_TTL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TTL_ID
                            ORDER BY an.SU_TTL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TTL_Subject_Title_Posit po
                    JOIN
                        SU_TTL_Subject_Title_Annex an
                    ON
                        an.SU_TTL_ID = po.SU_TTL_ID
                    WHERE
                        po.SU_TTL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TTL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TTL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_STA_SU_ID
                        ORDER BY
                            r.SU_STA_ChangedAt DESC,
                            r.SU_STA_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_STA,
                        po.SU_STA_ID,
                        an.SU_STA_PositedAt,
                        an.SU_STA_Reliability,
                        po.SU_STA_SU_ID,
                        po.SU_STA_Subject_State,
                        po.SU_STA_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_STA_ID
                            ORDER BY an.SU_STA_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_STA_Subject_State_Posit po
                    JOIN
                        SU_STA_Subject_State_Annex an
                    ON
                        an.SU_STA_ID = po.SU_STA_ID
                    WHERE
                        po.SU_STA_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_STA_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_STA_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_LBL_SU_ID
                        ORDER BY
                            r.SU_LBL_ChangedAt DESC,
                            r.SU_LBL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_LBL,
                        po.SU_LBL_ID,
                        an.SU_LBL_PositedAt,
                        an.SU_LBL_Reliability,
                        po.SU_LBL_SU_ID,
                        po.SU_LBL_Subject_Label,
                        po.SU_LBL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_LBL_ID
                            ORDER BY an.SU_LBL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_LBL_Subject_Label_Posit po
                    JOIN
                        SU_LBL_Subject_Label_Annex an
                    ON
                        an.SU_LBL_ID = po.SU_LBL_ID
                    WHERE
                        po.SU_LBL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_LBL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_LBL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TAG_SU_ID
                        ORDER BY
                            r.SU_TAG_ChangedAt DESC,
                            r.SU_TAG_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TAG,
                        po.SU_TAG_ID,
                        an.SU_TAG_PositedAt,
                        an.SU_TAG_Reliability,
                        po.SU_TAG_SU_ID,
                        po.SU_TAG_Subject_Tag,
                        po.SU_TAG_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TAG_ID
                            ORDER BY an.SU_TAG_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TAG_Subject_Tag_Posit po
                    JOIN
                        SU_TAG_Subject_Tag_Annex an
                    ON
                        an.SU_TAG_ID = po.SU_TAG_ID
                    WHERE
                        po.SU_TAG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TAG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TAG_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_LVL_SU_ID
                        ORDER BY
                            r.SU_LVL_ChangedAt DESC,
                            r.SU_LVL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_LVL,
                        po.SU_LVL_ID,
                        an.SU_LVL_PositedAt,
                        an.SU_LVL_Reliability,
                        po.SU_LVL_SU_ID,
                        po.SU_LVL_GRD_ID,
                        po.SU_LVL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_LVL_ID
                            ORDER BY an.SU_LVL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_LVL_Subject_Level_Posit po
                    JOIN
                        SU_LVL_Subject_Level_Annex an
                    ON
                        an.SU_LVL_ID = po.SU_LVL_ID
                    WHERE
                        po.SU_LVL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_LVL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_LVL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kLVL"
        ON
            "kLVL".GRD_ID = "LVL".SU_LVL_GRD_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TXT_SU_ID
                        ORDER BY
                            r.SU_TXT_ChangedAt DESC,
                            r.SU_TXT_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TXT,
                        po.SU_TXT_ID,
                        an.SU_TXT_PositedAt,
                        an.SU_TXT_Reliability,
                        po.SU_TXT_SU_ID,
                        po.SU_TXT_Subject_Text,
                        po.SU_TXT_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TXT_ID
                            ORDER BY an.SU_TXT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TXT_Subject_Text_Posit po
                    JOIN
                        SU_TXT_Subject_Text_Annex an
                    ON
                        an.SU_TXT_ID = po.SU_TXT_ID
                    WHERE
                        po.SU_TXT_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TXT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TXT_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_ASR_SU_ID
                        ORDER BY
                            r.SU_ASR_ChangedAt DESC,
                            r.SU_ASR_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_ASR,
                        po.SU_ASR_ID,
                        an.SU_ASR_PositedAt,
                        an.SU_ASR_Reliability,
                        po.SU_ASR_SU_ID,
                        po.SU_ASR_Subject_Assessment,
                        po.SU_ASR_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_ASR_ID
                            ORDER BY an.SU_ASR_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_ASR_Subject_Assessment_Posit po
                    JOIN
                        SU_ASR_Subject_Assessment_Annex an
                    ON
                        an.SU_ASR_ID = po.SU_ASR_ID
                    WHERE
                        po.SU_ASR_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_ASR_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_ASR_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_ERS_SU_ID
                        ORDER BY
                            r.SU_ERS_ChangedAt DESC,
                            r.SU_ERS_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_ERS,
                        po.SU_ERS_ID,
                        an.SU_ERS_PositedAt,
                        an.SU_ERS_Reliability,
                        po.SU_ERS_SU_ID,
                        po.SU_ERS_Subject_Erasable,
                        po.SU_ERS_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_ERS_ID
                            ORDER BY an.SU_ERS_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_ERS_Subject_Erasable_Posit po
                    JOIN
                        SU_ERS_Subject_Erasable_Annex an
                    ON
                        an.SU_ERS_ID = po.SU_ERS_ID
                    WHERE
                        po.SU_ERS_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_ERS_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_ERS_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
    ]';
END pSU_Subject;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-- What is known now, at End of Time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_Subject
AS
SELECT
    *
FROM
    pSU_Subject(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nSU_Subject
AS
SELECT
    *
FROM
    pSU_Subject(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The attributes whose
-- mnemonics the selection holds are the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dSU_Subject (
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
            "SU".SU_ID,
            "SU".Metadata_SU,
            "NAM".SU_NAM_SU_ID,
            "NAM".Metadata_SU_NAM,
            "NAM".SU_NAM_ID,
            "NAM".SU_NAM_PositedAt,
            "NAM".SU_NAM_Reliability,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_ID,
            "COD".SU_COD_PositedAt,
            "COD".SU_COD_Reliability,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "GRD".SU_GRD_ID,
            "GRD".SU_GRD_PositedAt,
            "GRD".SU_GRD_Reliability,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_ID,
            "NOT".SU_NOT_PositedAt,
            "NOT".SU_NOT_Reliability,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ID,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_PositedAt,
            "TTL".SU_TTL_Reliability,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ID,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_PositedAt,
            "STA".SU_STA_Reliability,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ID,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_PositedAt,
            "LBL".SU_LBL_Reliability,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ID,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_PositedAt,
            "TAG".SU_TAG_Reliability,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ID,
            "LVL".SU_LVL_ChangedAt,
            "LVL".SU_LVL_PositedAt,
            "LVL".SU_LVL_Reliability,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ID,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_PositedAt,
            "TXT".SU_TXT_Reliability,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ID,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_PositedAt,
            "ASR".SU_ASR_Reliability,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ID,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_PositedAt,
            "ERS".SU_ERS_Reliability,
            "ERS".SU_ERS_Subject_Erasable
        FROM (
            SELECT DISTINCT
                h.SU_TTL_SU_ID AS SU_ID,
                CAST(h.SU_TTL_ChangedAt AS timestamp) AS inspectedTimepoint,
                'TTL' AS mnemonic
            FROM
                SU_TTL_Subject_Title h
            WHERE
                (selection IS NULL OR selection LIKE '%TTL%')
            AND
                h.SU_TTL_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_STA_SU_ID AS SU_ID,
                CAST(h.SU_STA_ChangedAt AS timestamp) AS inspectedTimepoint,
                'STA' AS mnemonic
            FROM
                SU_STA_Subject_State h
            WHERE
                (selection IS NULL OR selection LIKE '%STA%')
            AND
                h.SU_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_LBL_SU_ID AS SU_ID,
                CAST(h.SU_LBL_ChangedAt AS timestamp) AS inspectedTimepoint,
                'LBL' AS mnemonic
            FROM
                SU_LBL_Subject_Label h
            WHERE
                (selection IS NULL OR selection LIKE '%LBL%')
            AND
                h.SU_LBL_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_TAG_SU_ID AS SU_ID,
                CAST(h.SU_TAG_ChangedAt AS timestamp) AS inspectedTimepoint,
                'TAG' AS mnemonic
            FROM
                SU_TAG_Subject_Tag h
            WHERE
                (selection IS NULL OR selection LIKE '%TAG%')
            AND
                h.SU_TAG_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_LVL_SU_ID AS SU_ID,
                CAST(h.SU_LVL_ChangedAt AS timestamp) AS inspectedTimepoint,
                'LVL' AS mnemonic
            FROM
                SU_LVL_Subject_Level h
            WHERE
                (selection IS NULL OR selection LIKE '%LVL%')
            AND
                h.SU_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_TXT_SU_ID AS SU_ID,
                CAST(h.SU_TXT_ChangedAt AS timestamp) AS inspectedTimepoint,
                'TXT' AS mnemonic
            FROM
                SU_TXT_Subject_Text h
            WHERE
                (selection IS NULL OR selection LIKE '%TXT%')
            AND
                h.SU_TXT_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_ASR_SU_ID AS SU_ID,
                CAST(h.SU_ASR_ChangedAt AS timestamp) AS inspectedTimepoint,
                'ASR' AS mnemonic
            FROM
                SU_ASR_Subject_Assessment h
            WHERE
                (selection IS NULL OR selection LIKE '%ASR%')
            AND
                h.SU_ASR_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_ERS_SU_ID AS SU_ID,
                CAST(h.SU_ERS_ChangedAt AS timestamp) AS inspectedTimepoint,
                'ERS' AS mnemonic
            FROM
                SU_ERS_Subject_Erasable h
            WHERE
                (selection IS NULL OR selection LIKE '%ERS%')
            AND
                h.SU_ERS_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            SU_Subject "SU"
        ON
            "SU".SU_ID = timepoints.SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NAM_SU_ID
                        ORDER BY r.SU_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_SU_NAM,
                            po.SU_NAM_ID,
                            an.SU_NAM_PositedAt,
                            an.SU_NAM_Reliability,
                            po.SU_NAM_SU_ID,
                            po.SU_NAM_Subject_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_NAM_ID
                                ORDER BY an.SU_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_NAM_Subject_Name_Posit po
                        JOIN
                            SU_NAM_Subject_Name_Annex an
                        ON
                            an.SU_NAM_ID = po.SU_NAM_ID
                        WHERE
                            an.SU_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_COD_SU_ID
                        ORDER BY r.SU_COD_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_SU_COD,
                            po.SU_COD_ID,
                            an.SU_COD_PositedAt,
                            an.SU_COD_Reliability,
                            po.SU_COD_SU_ID,
                            po.SU_COD_Subject_Code,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_COD_ID
                                ORDER BY an.SU_COD_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_COD_Subject_Code_Posit po
                        JOIN
                            SU_COD_Subject_Code_Annex an
                        ON
                            an.SU_COD_ID = po.SU_COD_ID
                        WHERE
                            an.SU_COD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_COD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_GRD_SU_ID
                        ORDER BY r.SU_GRD_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_SU_GRD,
                            po.SU_GRD_ID,
                            an.SU_GRD_PositedAt,
                            an.SU_GRD_Reliability,
                            po.SU_GRD_SU_ID,
                            po.SU_GRD_GRD_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_GRD_ID
                                ORDER BY an.SU_GRD_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_GRD_Subject_Grade_Posit po
                        JOIN
                            SU_GRD_Subject_Grade_Annex an
                        ON
                            an.SU_GRD_ID = po.SU_GRD_ID
                        WHERE
                            an.SU_GRD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_GRD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kGRD"
        ON
            "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NOT_SU_ID
                        ORDER BY r.SU_NOT_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_SU_NOT,
                            po.SU_NOT_ID,
                            an.SU_NOT_PositedAt,
                            an.SU_NOT_Reliability,
                            po.SU_NOT_SU_ID,
                            po.SU_NOT_Subject_Note,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_NOT_ID
                                ORDER BY an.SU_NOT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_NOT_Subject_Note_Posit po
                        JOIN
                            SU_NOT_Subject_Note_Annex an
                        ON
                            an.SU_NOT_ID = po.SU_NOT_ID
                        WHERE
                            an.SU_NOT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NOT_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.SU_TTL_ChangedAt) OVER (
                    PARTITION BY x.SU_TTL_SU_ID
                    ORDER BY x.SU_TTL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_TTL_SU_ID, r.SU_TTL_ChangedAt
                            ORDER BY r.SU_TTL_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_TTL,
                            po.SU_TTL_ID,
                            an.SU_TTL_PositedAt,
                            an.SU_TTL_Reliability,
                            po.SU_TTL_SU_ID,
                            po.SU_TTL_Subject_Title,
                            po.SU_TTL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TTL_ID
                                ORDER BY an.SU_TTL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_TTL_Subject_Title_Posit po
                        JOIN
                            SU_TTL_Subject_Title_Annex an
                        ON
                            an.SU_TTL_ID = po.SU_TTL_ID
                        WHERE
                            po.SU_TTL_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_TTL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_TTL_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        AND
            "TTL".SU_TTL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "TTL".untilTime IS NULL
        OR
            "TTL".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.SU_STA_ChangedAt) OVER (
                    PARTITION BY x.SU_STA_SU_ID
                    ORDER BY x.SU_STA_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_STA_SU_ID, r.SU_STA_ChangedAt
                            ORDER BY r.SU_STA_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_STA,
                            po.SU_STA_ID,
                            an.SU_STA_PositedAt,
                            an.SU_STA_Reliability,
                            po.SU_STA_SU_ID,
                            po.SU_STA_Subject_State,
                            po.SU_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_STA_ID
                                ORDER BY an.SU_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_STA_Subject_State_Posit po
                        JOIN
                            SU_STA_Subject_State_Annex an
                        ON
                            an.SU_STA_ID = po.SU_STA_ID
                        WHERE
                            po.SU_STA_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_STA_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_STA_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        AND
            "STA".SU_STA_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "STA".untilTime IS NULL
        OR
            "STA".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.SU_LBL_ChangedAt) OVER (
                    PARTITION BY x.SU_LBL_SU_ID
                    ORDER BY x.SU_LBL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_LBL_SU_ID, r.SU_LBL_ChangedAt
                            ORDER BY r.SU_LBL_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_LBL,
                            po.SU_LBL_ID,
                            an.SU_LBL_PositedAt,
                            an.SU_LBL_Reliability,
                            po.SU_LBL_SU_ID,
                            po.SU_LBL_Subject_Label,
                            po.SU_LBL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_LBL_ID
                                ORDER BY an.SU_LBL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_LBL_Subject_Label_Posit po
                        JOIN
                            SU_LBL_Subject_Label_Annex an
                        ON
                            an.SU_LBL_ID = po.SU_LBL_ID
                        WHERE
                            po.SU_LBL_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_LBL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_LBL_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        AND
            "LBL".SU_LBL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "LBL".untilTime IS NULL
        OR
            "LBL".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.SU_TAG_ChangedAt) OVER (
                    PARTITION BY x.SU_TAG_SU_ID
                    ORDER BY x.SU_TAG_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_TAG_SU_ID, r.SU_TAG_ChangedAt
                            ORDER BY r.SU_TAG_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_TAG,
                            po.SU_TAG_ID,
                            an.SU_TAG_PositedAt,
                            an.SU_TAG_Reliability,
                            po.SU_TAG_SU_ID,
                            po.SU_TAG_Subject_Tag,
                            po.SU_TAG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TAG_ID
                                ORDER BY an.SU_TAG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_TAG_Subject_Tag_Posit po
                        JOIN
                            SU_TAG_Subject_Tag_Annex an
                        ON
                            an.SU_TAG_ID = po.SU_TAG_ID
                        WHERE
                            po.SU_TAG_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_TAG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_TAG_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        AND
            "TAG".SU_TAG_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "TAG".untilTime IS NULL
        OR
            "TAG".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.SU_LVL_ChangedAt) OVER (
                    PARTITION BY x.SU_LVL_SU_ID
                    ORDER BY x.SU_LVL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_LVL_SU_ID, r.SU_LVL_ChangedAt
                            ORDER BY r.SU_LVL_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_LVL,
                            po.SU_LVL_ID,
                            an.SU_LVL_PositedAt,
                            an.SU_LVL_Reliability,
                            po.SU_LVL_SU_ID,
                            po.SU_LVL_GRD_ID,
                            po.SU_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_LVL_ID
                                ORDER BY an.SU_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_LVL_Subject_Level_Posit po
                        JOIN
                            SU_LVL_Subject_Level_Annex an
                        ON
                            an.SU_LVL_ID = po.SU_LVL_ID
                        WHERE
                            po.SU_LVL_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_LVL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_LVL_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        AND
            "LVL".SU_LVL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "LVL".untilTime IS NULL
        OR
            "LVL".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            GRD_Grade "kLVL"
        ON
            "kLVL".GRD_ID = "LVL".SU_LVL_GRD_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.SU_TXT_ChangedAt) OVER (
                    PARTITION BY x.SU_TXT_SU_ID
                    ORDER BY x.SU_TXT_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_TXT_SU_ID, r.SU_TXT_ChangedAt
                            ORDER BY r.SU_TXT_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_TXT,
                            po.SU_TXT_ID,
                            an.SU_TXT_PositedAt,
                            an.SU_TXT_Reliability,
                            po.SU_TXT_SU_ID,
                            po.SU_TXT_Subject_Text,
                            po.SU_TXT_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TXT_ID
                                ORDER BY an.SU_TXT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_TXT_Subject_Text_Posit po
                        JOIN
                            SU_TXT_Subject_Text_Annex an
                        ON
                            an.SU_TXT_ID = po.SU_TXT_ID
                        WHERE
                            po.SU_TXT_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_TXT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_TXT_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        AND
            "TXT".SU_TXT_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "TXT".untilTime IS NULL
        OR
            "TXT".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.SU_ASR_ChangedAt) OVER (
                    PARTITION BY x.SU_ASR_SU_ID
                    ORDER BY x.SU_ASR_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_ASR_SU_ID, r.SU_ASR_ChangedAt
                            ORDER BY r.SU_ASR_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_ASR,
                            po.SU_ASR_ID,
                            an.SU_ASR_PositedAt,
                            an.SU_ASR_Reliability,
                            po.SU_ASR_SU_ID,
                            po.SU_ASR_Subject_Assessment,
                            po.SU_ASR_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_ASR_ID
                                ORDER BY an.SU_ASR_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_ASR_Subject_Assessment_Posit po
                        JOIN
                            SU_ASR_Subject_Assessment_Annex an
                        ON
                            an.SU_ASR_ID = po.SU_ASR_ID
                        WHERE
                            po.SU_ASR_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_ASR_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_ASR_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        AND
            "ASR".SU_ASR_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "ASR".untilTime IS NULL
        OR
            "ASR".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.SU_ERS_ChangedAt) OVER (
                    PARTITION BY x.SU_ERS_SU_ID
                    ORDER BY x.SU_ERS_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_ERS_SU_ID, r.SU_ERS_ChangedAt
                            ORDER BY r.SU_ERS_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_ERS,
                            po.SU_ERS_ID,
                            an.SU_ERS_PositedAt,
                            an.SU_ERS_Reliability,
                            po.SU_ERS_SU_ID,
                            po.SU_ERS_Subject_Erasable,
                            po.SU_ERS_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_ERS_ID
                                ORDER BY an.SU_ERS_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_ERS_Subject_Erasable_Posit po
                        JOIN
                            SU_ERS_Subject_Erasable_Annex an
                        ON
                            an.SU_ERS_ID = po.SU_ERS_ID
                        WHERE
                            po.SU_ERS_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_ERS_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_ERS_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
        AND
            "ERS".SU_ERS_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "ERS".untilTime IS NULL
        OR
            "ERS".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
    ]';
END dSU_Subject;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest asserted posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tOB_Object (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "OB".OB_ID,
            "OB".Metadata_OB,
            "NAM".OB_NAM_OB_ID,
            "NAM".Metadata_OB_NAM,
            "NAM".OB_NAM_ID,
            "NAM".OB_NAM_PositedAt,
            "NAM".OB_NAM_Reliability,
            "NAM".OB_NAM_Object_Name
        FROM
            OB_Object "OB"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.OB_NAM_OB_ID
                        ORDER BY
                            r.OB_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_OB_NAM,
                        po.OB_NAM_ID,
                        an.OB_NAM_PositedAt,
                        an.OB_NAM_Reliability,
                        po.OB_NAM_OB_ID,
                        po.OB_NAM_Object_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.OB_NAM_ID
                            ORDER BY an.OB_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        OB_NAM_Object_Name_Posit po
                    JOIN
                        OB_NAM_Object_Name_Annex an
                    ON
                        an.OB_NAM_ID = po.OB_NAM_ID
                    WHERE
                        an.OB_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.OB_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".OB_NAM_OB_ID = "OB".OB_ID
    ]';
END tOB_Object;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What is known now (positing time End of Time) about the changing time, with a reliability that is null since a
-- perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pOB_Object (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "OB".OB_ID,
            "OB".Metadata_OB,
            "NAM".OB_NAM_OB_ID,
            "NAM".Metadata_OB_NAM,
            "NAM".OB_NAM_ID,
            "NAM".OB_NAM_PositedAt,
            "NAM".OB_NAM_Reliability,
            "NAM".OB_NAM_Object_Name
        FROM
            OB_Object "OB"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.OB_NAM_OB_ID
                        ORDER BY
                            r.OB_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_OB_NAM,
                        po.OB_NAM_ID,
                        an.OB_NAM_PositedAt,
                        an.OB_NAM_Reliability,
                        po.OB_NAM_OB_ID,
                        po.OB_NAM_Object_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.OB_NAM_ID
                            ORDER BY an.OB_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        OB_NAM_Object_Name_Posit po
                    JOIN
                        OB_NAM_Object_Name_Annex an
                    ON
                        an.OB_NAM_ID = po.OB_NAM_ID
                    WHERE
                        an.OB_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.OB_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".OB_NAM_OB_ID = "OB".OB_ID
    ]';
END pOB_Object;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-- What is known now, at End of Time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lOB_Object
AS
SELECT
    *
FROM
    pOB_Object(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nOB_Object
AS
SELECT
    *
FROM
    pOB_Object(CAST(current_timestamp AS timestamp))
;
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
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_ID,
            "QTY".EV_QTY_PositedAt,
            "QTY".EV_QTY_Reliability,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ID,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_PositedAt,
            "PLC".EV_PLC_Reliability,
            "PLC".EV_PLC_Event_Place
        FROM
            EV_Event "EV"
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_QTY_EV_ID
                        ORDER BY
                            r.EV_QTY_PositedAt DESC,
                            r.EV_QTY_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_QTY,
                        po.EV_QTY_ID,
                        an.EV_QTY_PositedAt,
                        an.EV_QTY_Reliability,
                        po.EV_QTY_EV_ID,
                        po.EV_QTY_Event_Quantity,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_QTY_ID
                            ORDER BY an.EV_QTY_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_QTY_Event_Quantity_Posit po
                    JOIN
                        EV_QTY_Event_Quantity_Annex an
                    ON
                        an.EV_QTY_ID = po.EV_QTY_ID
                    WHERE
                        an.EV_QTY_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_QTY_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_PLC_EV_ID
                        ORDER BY
                            r.EV_PLC_ChangedAt DESC,
                            r.EV_PLC_PositedAt DESC,
                            r.EV_PLC_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_PLC,
                        po.EV_PLC_ID,
                        an.EV_PLC_PositedAt,
                        an.EV_PLC_Reliability,
                        po.EV_PLC_EV_ID,
                        po.EV_PLC_Event_Place,
                        po.EV_PLC_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_PLC_ID
                            ORDER BY an.EV_PLC_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_PLC_Event_Place_Posit po
                    JOIN
                        EV_PLC_Event_Place_Annex an
                    ON
                        an.EV_PLC_ID = po.EV_PLC_ID
                    WHERE
                        po.EV_PLC_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.EV_PLC_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_PLC_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
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
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_ID,
            "QTY".EV_QTY_PositedAt,
            "QTY".EV_QTY_Reliability,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ID,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_PositedAt,
            "PLC".EV_PLC_Reliability,
            "PLC".EV_PLC_Event_Place
        FROM
            EV_Event "EV"
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_QTY_EV_ID
                        ORDER BY
                            r.EV_QTY_PositedAt DESC,
                            r.EV_QTY_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_QTY,
                        po.EV_QTY_ID,
                        an.EV_QTY_PositedAt,
                        an.EV_QTY_Reliability,
                        po.EV_QTY_EV_ID,
                        po.EV_QTY_Event_Quantity,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_QTY_ID
                            ORDER BY an.EV_QTY_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_QTY_Event_Quantity_Posit po
                    JOIN
                        EV_QTY_Event_Quantity_Annex an
                    ON
                        an.EV_QTY_ID = po.EV_QTY_ID
                    WHERE
                        an.EV_QTY_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_QTY_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_PLC_EV_ID
                        ORDER BY
                            r.EV_PLC_ChangedAt DESC,
                            r.EV_PLC_PositedAt DESC,
                            r.EV_PLC_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_PLC,
                        po.EV_PLC_ID,
                        an.EV_PLC_PositedAt,
                        an.EV_PLC_Reliability,
                        po.EV_PLC_EV_ID,
                        po.EV_PLC_Event_Place,
                        po.EV_PLC_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_PLC_ID
                            ORDER BY an.EV_PLC_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_PLC_Event_Place_Posit po
                    JOIN
                        EV_PLC_Event_Place_Annex an
                    ON
                        an.EV_PLC_ID = po.EV_PLC_ID
                    WHERE
                        po.EV_PLC_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.EV_PLC_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_PLC_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
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
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- reliable posit is joined with the changing time until which it holds, when the next one does. The attributes whose
-- mnemonics the selection holds are the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dEV_Event (
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
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_ID,
            "QTY".EV_QTY_PositedAt,
            "QTY".EV_QTY_Reliability,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ID,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_PositedAt,
            "PLC".EV_PLC_Reliability,
            "PLC".EV_PLC_Event_Place
        FROM (
            SELECT DISTINCT
                h.EV_PLC_EV_ID AS EV_ID,
                CAST(h.EV_PLC_ChangedAt AS timestamp) AS inspectedTimepoint,
                'PLC' AS mnemonic
            FROM
                EV_PLC_Event_Place h
            WHERE
                (selection IS NULL OR selection LIKE '%PLC%')
            AND
                h.EV_PLC_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            EV_Event "EV"
        ON
            "EV".EV_ID = timepoints.EV_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_QTY_EV_ID
                        ORDER BY
                            r.EV_QTY_PositedAt DESC,
                            r.EV_QTY_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_QTY,
                        po.EV_QTY_ID,
                        an.EV_QTY_PositedAt,
                        an.EV_QTY_Reliability,
                        po.EV_QTY_EV_ID,
                        po.EV_QTY_Event_Quantity,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_QTY_ID
                            ORDER BY an.EV_QTY_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_QTY_Event_Quantity_Posit po
                    JOIN
                        EV_QTY_Event_Quantity_Annex an
                    ON
                        an.EV_QTY_ID = po.EV_QTY_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_QTY_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.EV_PLC_ChangedAt) OVER (
                    PARTITION BY y.EV_PLC_EV_ID
                    ORDER BY y.EV_PLC_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.EV_PLC_EV_ID, r.EV_PLC_ChangedAt
                            ORDER BY
                                r.EV_PLC_PositedAt DESC,
                                r.EV_PLC_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_EV_PLC,
                            po.EV_PLC_ID,
                            an.EV_PLC_PositedAt,
                            an.EV_PLC_Reliability,
                            po.EV_PLC_EV_ID,
                            po.EV_PLC_Event_Place,
                            po.EV_PLC_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_PLC_ID
                                ORDER BY an.EV_PLC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            EV_PLC_Event_Place_Posit po
                        JOIN
                            EV_PLC_Event_Place_Annex an
                        ON
                            an.EV_PLC_ID = po.EV_PLC_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.EV_PLC_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
        AND
            "PLC".EV_PLC_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "PLC".untilTime IS NULL
        OR
            "PLC".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
    ]';
END dEV_Event;
/
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_holder_OB_item_GRD_grade_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_holder_OB_item_GRD_grade_Posit (
            SU_holder_OB_item_GRD_grade_ID number(10) default SU_holder_OB_item_GRD_grade_Posit_ID_SEQ.nextval not null, 
            SU_ID_holder number(10) not null, 
            OB_ID_item number(10) not null, 
            GRD_ID_grade number(5) not null,
            SU_holder_OB_item_GRD_grade_ChangedAt timestamp not null,
            constraint SU_holder_OB_item_GRD_grade_Posit_fkSU_holder foreign key (
                SU_ID_holder
            ) references SU_Subject(SU_ID),
            constraint SU_holder_OB_item_GRD_grade_Posit_fkOB_item foreign key (
                OB_ID_item
            ) references OB_Object(OB_ID),
            constraint SU_holder_OB_item_GRD_grade_Posit_fkGRD_grade foreign key (
                GRD_ID_grade
            ) references GRD_Grade(GRD_ID),
            constraint pkSU_holder_OB_item_GRD_grade_Posit primary key (
                SU_holder_OB_item_GRD_grade_ID
            ),
            constraint uqSU_holder_OB_item_GRD_grade unique (
                SU_ID_holder,
                OB_ID_item,
                SU_holder_OB_item_GRD_grade_ChangedAt,
                GRD_ID_grade
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_holder_OB_item_GRD_grade_Annex (
            SU_holder_OB_item_GRD_grade_ID number(10) not null,
            SU_holder_OB_item_GRD_grade_PositedAt timestamp not null,
            SU_holder_OB_item_GRD_grade_Reliability number(5,2) not null,
            Metadata_SU_holder_OB_item_GRD_grade number(10) not null,
            constraint fkSU_holder_OB_item_GRD_grade_Annex foreign key (
                SU_holder_OB_item_GRD_grade_ID
            ) references SU_holder_OB_item_GRD_grade_Posit(SU_holder_OB_item_GRD_grade_ID),
            constraint pkSU_holder_OB_item_GRD_grade_Annex primary key (
                SU_holder_OB_item_GRD_grade_ID,
                SU_holder_OB_item_GRD_grade_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_keeper_OB_thing_GRD_rank_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_keeper_OB_thing_GRD_rank_Posit (
            SU_keeper_OB_thing_GRD_rank_ID number(10) default SU_keeper_OB_thing_GRD_rank_Posit_ID_SEQ.nextval not null, 
            SU_ID_keeper number(10) not null, 
            OB_ID_thing number(10) not null, 
            GRD_ID_rank number(5) not null,
            SU_keeper_OB_thing_GRD_rank_ChangedAt timestamp not null,
            constraint SU_keeper_OB_thing_GRD_rank_Posit_fkSU_keeper foreign key (
                SU_ID_keeper
            ) references SU_Subject(SU_ID),
            constraint SU_keeper_OB_thing_GRD_rank_Posit_fkOB_thing foreign key (
                OB_ID_thing
            ) references OB_Object(OB_ID),
            constraint SU_keeper_OB_thing_GRD_rank_Posit_fkGRD_rank foreign key (
                GRD_ID_rank
            ) references GRD_Grade(GRD_ID),
            constraint pkSU_keeper_OB_thing_GRD_rank_Posit primary key (
                SU_keeper_OB_thing_GRD_rank_ID
            ),
            constraint uqSU_keeper_OB_thing_GRD_rank unique (
                SU_ID_keeper,
                OB_ID_thing,
                SU_keeper_OB_thing_GRD_rank_ChangedAt,
                GRD_ID_rank
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_keeper_OB_thing_GRD_rank_Annex (
            SU_keeper_OB_thing_GRD_rank_ID number(10) not null,
            SU_keeper_OB_thing_GRD_rank_PositedAt timestamp not null,
            SU_keeper_OB_thing_GRD_rank_Reliability number(5,2) not null,
            Metadata_SU_keeper_OB_thing_GRD_rank number(10) not null,
            constraint fkSU_keeper_OB_thing_GRD_rank_Annex foreign key (
                SU_keeper_OB_thing_GRD_rank_ID
            ) references SU_keeper_OB_thing_GRD_rank_Posit(SU_keeper_OB_thing_GRD_rank_ID),
            constraint pkSU_keeper_OB_thing_GRD_rank_Annex primary key (
                SU_keeper_OB_thing_GRD_rank_ID,
                SU_keeper_OB_thing_GRD_rank_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE OB_part_SU_owner_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE OB_part_SU_owner_Posit (
            OB_part_SU_owner_ID number(10) default OB_part_SU_owner_Posit_ID_SEQ.nextval not null, 
            OB_ID_part number(10) not null, 
            SU_ID_owner number(10) not null, 
            constraint OB_part_SU_owner_Posit_fkOB_part foreign key (
                OB_ID_part
            ) references OB_Object(OB_ID),
            constraint OB_part_SU_owner_Posit_fkSU_owner foreign key (
                SU_ID_owner
            ) references SU_Subject(SU_ID),
            constraint pkOB_part_SU_owner_Posit primary key (
                OB_part_SU_owner_ID
            ),
            constraint uqOB_part_SU_owner unique (
                OB_ID_part,
                SU_ID_owner
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE OB_part_SU_owner_Annex (
            OB_part_SU_owner_ID number(10) not null,
            OB_part_SU_owner_PositedAt timestamp not null,
            OB_part_SU_owner_Reliability number(5,2) not null,
            Metadata_OB_part_SU_owner number(10) not null,
            constraint fkOB_part_SU_owner_Annex foreign key (
                OB_part_SU_owner_ID
            ) references OB_part_SU_owner_Posit(OB_part_SU_owner_ID),
            constraint pkOB_part_SU_owner_Annex primary key (
                OB_part_SU_owner_ID,
                OB_part_SU_owner_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE SU_partner_SU_with_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_partner_SU_with_Posit (
            SU_partner_SU_with_ID number(10) default SU_partner_SU_with_Posit_ID_SEQ.nextval not null, 
            SU_ID_partner number(10) not null, 
            SU_ID_with number(10) not null, 
            SU_partner_SU_with_ChangedAt timestamp not null,
            constraint SU_partner_SU_with_Posit_fkSU_partner foreign key (
                SU_ID_partner
            ) references SU_Subject(SU_ID),
            constraint SU_partner_SU_with_Posit_fkSU_with foreign key (
                SU_ID_with
            ) references SU_Subject(SU_ID),
            constraint SU_partner_SU_with_Posit_uqSU_partner unique (
                SU_ID_partner,
                SU_partner_SU_with_ChangedAt
            ),
            constraint SU_partner_SU_with_Posit_uqSU_with unique (
                SU_ID_with,
                SU_partner_SU_with_ChangedAt
            ),
            constraint pkSU_partner_SU_with_Posit primary key (
                SU_partner_SU_with_ID
            ),
            constraint uqSU_partner_SU_with unique (
                SU_partner_SU_with_ChangedAt,
                SU_ID_partner,
                SU_ID_with
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_partner_SU_with_Annex (
            SU_partner_SU_with_ID number(10) not null,
            SU_partner_SU_with_PositedAt timestamp not null,
            SU_partner_SU_with_Reliability number(5,2) not null,
            Metadata_SU_partner_SU_with number(10) not null,
            constraint fkSU_partner_SU_with_Annex foreign key (
                SU_partner_SU_with_ID
            ) references SU_partner_SU_with_Posit(SU_partner_SU_with_ID),
            constraint pkSU_partner_SU_with_Annex primary key (
                SU_partner_SU_with_ID,
                SU_partner_SU_with_PositedAt
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
CREATE OR REPLACE VIEW SU_holder_OB_item_GRD_grade AS
SELECT
    a.Metadata_SU_holder_OB_item_GRD_grade,
    p.SU_holder_OB_item_GRD_grade_ID,
    p.SU_ID_holder,
    p.OB_ID_item,
    p.GRD_ID_grade,
    p.SU_holder_OB_item_GRD_grade_ChangedAt,
    a.SU_holder_OB_item_GRD_grade_PositedAt,
    a.SU_holder_OB_item_GRD_grade_Reliability
FROM
    SU_holder_OB_item_GRD_grade_Posit p
JOIN
    SU_holder_OB_item_GRD_grade_Annex a
ON
    a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
;
CREATE OR REPLACE VIEW SU_keeper_OB_thing_GRD_rank AS
SELECT
    a.Metadata_SU_keeper_OB_thing_GRD_rank,
    p.SU_keeper_OB_thing_GRD_rank_ID,
    p.SU_ID_keeper,
    p.OB_ID_thing,
    p.GRD_ID_rank,
    p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    a.SU_keeper_OB_thing_GRD_rank_PositedAt,
    a.SU_keeper_OB_thing_GRD_rank_Reliability
FROM
    SU_keeper_OB_thing_GRD_rank_Posit p
JOIN
    SU_keeper_OB_thing_GRD_rank_Annex a
ON
    a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
;
CREATE OR REPLACE VIEW OB_part_SU_owner AS
SELECT
    a.Metadata_OB_part_SU_owner,
    p.OB_part_SU_owner_ID,
    p.OB_ID_part,
    p.SU_ID_owner,
    a.OB_part_SU_owner_PositedAt,
    a.OB_part_SU_owner_Reliability
FROM
    OB_part_SU_owner_Posit p
JOIN
    OB_part_SU_owner_Annex a
ON
    a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
;
CREATE OR REPLACE VIEW SU_partner_SU_with AS
SELECT
    a.Metadata_SU_partner_SU_with,
    p.SU_partner_SU_with_ID,
    p.SU_ID_partner,
    p.SU_ID_with,
    p.SU_partner_SU_with_ChangedAt,
    a.SU_partner_SU_with_PositedAt,
    a.SU_partner_SU_with_Reliability
FROM
    SU_partner_SU_with_Posit p
JOIN
    SU_partner_SU_with_Annex a
ON
    a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
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
CREATE OR REPLACE FUNCTION rSU_holder_OB_item_GRD_grade_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_holder_OB_item_GRD_grade_ID,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt
        FROM
            SU_holder_OB_item_GRD_grade_Posit
        WHERE
            SU_holder_OB_item_GRD_grade_ChangedAt <= changingTimepoint
    ]';
END rSU_holder_OB_item_GRD_grade_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_holder_OB_item_GRD_grade_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_holder_OB_item_GRD_grade_ID,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt
        FROM
            SU_holder_OB_item_GRD_grade_Posit
        WHERE
            SU_holder_OB_item_GRD_grade_ChangedAt > changingTimepoint
    ]';
END fSU_holder_OB_item_GRD_grade_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_holder_OB_item_GRD_grade_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Reliability
        FROM
            SU_holder_OB_item_GRD_grade_Annex
        WHERE
            SU_holder_OB_item_GRD_grade_PositedAt <= positingTimepoint
    ]';
END rSU_holder_OB_item_GRD_grade_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_holder_OB_item_GRD_grade (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Reliability
        FROM (
            SELECT
                a.Metadata_SU_holder_OB_item_GRD_grade,
                p.SU_holder_OB_item_GRD_grade_ID,
                p.SU_ID_holder,
                p.OB_ID_item,
                p.GRD_ID_grade,
                p.SU_holder_OB_item_GRD_grade_ChangedAt,
                a.SU_holder_OB_item_GRD_grade_PositedAt,
                a.SU_holder_OB_item_GRD_grade_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_holder_OB_item_GRD_grade_ID
                    ORDER BY
                        a.SU_holder_OB_item_GRD_grade_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_holder_OB_item_GRD_grade_Posit p
            JOIN
                SU_holder_OB_item_GRD_grade_Annex a
            ON
                a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            WHERE
                p.SU_holder_OB_item_GRD_grade_ChangedAt <= changingTimepoint
            AND
                a.SU_holder_OB_item_GRD_grade_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_holder_OB_item_GRD_grade;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_holder_OB_item_GRD_grade (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Reliability
        FROM (
            SELECT
                a.Metadata_SU_holder_OB_item_GRD_grade,
                p.SU_holder_OB_item_GRD_grade_ID,
                p.SU_ID_holder,
                p.OB_ID_item,
                p.GRD_ID_grade,
                p.SU_holder_OB_item_GRD_grade_ChangedAt,
                a.SU_holder_OB_item_GRD_grade_PositedAt,
                a.SU_holder_OB_item_GRD_grade_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_holder_OB_item_GRD_grade_ID
                    ORDER BY
                        a.SU_holder_OB_item_GRD_grade_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_holder_OB_item_GRD_grade_Posit p
            JOIN
                SU_holder_OB_item_GRD_grade_Annex a
            ON
                a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            WHERE
                p.SU_holder_OB_item_GRD_grade_ChangedAt > changingTimepoint
            AND
                a.SU_holder_OB_item_GRD_grade_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_holder_OB_item_GRD_grade;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_keeper_OB_thing_GRD_rank_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank,
            SU_keeper_OB_thing_GRD_rank_ChangedAt
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit
        WHERE
            SU_keeper_OB_thing_GRD_rank_ChangedAt <= changingTimepoint
    ]';
END rSU_keeper_OB_thing_GRD_rank_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_keeper_OB_thing_GRD_rank_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank,
            SU_keeper_OB_thing_GRD_rank_ChangedAt
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit
        WHERE
            SU_keeper_OB_thing_GRD_rank_ChangedAt > changingTimepoint
    ]';
END fSU_keeper_OB_thing_GRD_rank_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_keeper_OB_thing_GRD_rank_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
        FROM
            SU_keeper_OB_thing_GRD_rank_Annex
        WHERE
            SU_keeper_OB_thing_GRD_rank_PositedAt <= positingTimepoint
    ]';
END rSU_keeper_OB_thing_GRD_rank_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_keeper_OB_thing_GRD_rank (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank,
            SU_keeper_OB_thing_GRD_rank_ChangedAt,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
        FROM (
            SELECT
                a.Metadata_SU_keeper_OB_thing_GRD_rank,
                p.SU_keeper_OB_thing_GRD_rank_ID,
                p.SU_ID_keeper,
                p.OB_ID_thing,
                p.GRD_ID_rank,
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                a.SU_keeper_OB_thing_GRD_rank_PositedAt,
                a.SU_keeper_OB_thing_GRD_rank_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_keeper_OB_thing_GRD_rank_ID
                    ORDER BY
                        a.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_keeper_OB_thing_GRD_rank_Posit p
            JOIN
                SU_keeper_OB_thing_GRD_rank_Annex a
            ON
                a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            WHERE
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt <= changingTimepoint
            AND
                a.SU_keeper_OB_thing_GRD_rank_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_keeper_OB_thing_GRD_rank;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_keeper_OB_thing_GRD_rank (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank,
            SU_keeper_OB_thing_GRD_rank_ChangedAt,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
        FROM (
            SELECT
                a.Metadata_SU_keeper_OB_thing_GRD_rank,
                p.SU_keeper_OB_thing_GRD_rank_ID,
                p.SU_ID_keeper,
                p.OB_ID_thing,
                p.GRD_ID_rank,
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                a.SU_keeper_OB_thing_GRD_rank_PositedAt,
                a.SU_keeper_OB_thing_GRD_rank_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_keeper_OB_thing_GRD_rank_ID
                    ORDER BY
                        a.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_keeper_OB_thing_GRD_rank_Posit p
            JOIN
                SU_keeper_OB_thing_GRD_rank_Annex a
            ON
                a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            WHERE
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt > changingTimepoint
            AND
                a.SU_keeper_OB_thing_GRD_rank_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_keeper_OB_thing_GRD_rank;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rOB_part_SU_owner_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Reliability
        FROM
            OB_part_SU_owner_Annex
        WHERE
            OB_part_SU_owner_PositedAt <= positingTimepoint
    ]';
END rOB_part_SU_owner_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rOB_part_SU_owner (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_ID_part,
            SU_ID_owner,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Reliability
        FROM (
            SELECT
                a.Metadata_OB_part_SU_owner,
                p.OB_part_SU_owner_ID,
                p.OB_ID_part,
                p.SU_ID_owner,
                a.OB_part_SU_owner_PositedAt,
                a.OB_part_SU_owner_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.OB_part_SU_owner_ID
                    ORDER BY
                        a.OB_part_SU_owner_PositedAt DESC
                ) AS rowNumber
            FROM
                OB_part_SU_owner_Posit p
            JOIN
                OB_part_SU_owner_Annex a
            ON
                a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            WHERE
                a.OB_part_SU_owner_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rOB_part_SU_owner;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fOB_part_SU_owner (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_ID_part,
            SU_ID_owner,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Reliability
        FROM (
            SELECT
                a.Metadata_OB_part_SU_owner,
                p.OB_part_SU_owner_ID,
                p.OB_ID_part,
                p.SU_ID_owner,
                a.OB_part_SU_owner_PositedAt,
                a.OB_part_SU_owner_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.OB_part_SU_owner_ID
                    ORDER BY
                        a.OB_part_SU_owner_PositedAt DESC
                ) AS rowNumber
            FROM
                OB_part_SU_owner_Posit p
            JOIN
                OB_part_SU_owner_Annex a
            ON
                a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            WHERE
                a.OB_part_SU_owner_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fOB_part_SU_owner;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_partner_SU_with_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_partner_SU_with_ID,
            SU_ID_partner,
            SU_ID_with,
            SU_partner_SU_with_ChangedAt
        FROM
            SU_partner_SU_with_Posit
        WHERE
            SU_partner_SU_with_ChangedAt <= changingTimepoint
    ]';
END rSU_partner_SU_with_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_partner_SU_with_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_partner_SU_with_ID,
            SU_ID_partner,
            SU_ID_with,
            SU_partner_SU_with_ChangedAt
        FROM
            SU_partner_SU_with_Posit
        WHERE
            SU_partner_SU_with_ChangedAt > changingTimepoint
    ]';
END fSU_partner_SU_with_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_partner_SU_with_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Reliability
        FROM
            SU_partner_SU_with_Annex
        WHERE
            SU_partner_SU_with_PositedAt <= positingTimepoint
    ]';
END rSU_partner_SU_with_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_partner_SU_with (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_ID_partner,
            SU_ID_with,
            SU_partner_SU_with_ChangedAt,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Reliability
        FROM (
            SELECT
                a.Metadata_SU_partner_SU_with,
                p.SU_partner_SU_with_ID,
                p.SU_ID_partner,
                p.SU_ID_with,
                p.SU_partner_SU_with_ChangedAt,
                a.SU_partner_SU_with_PositedAt,
                a.SU_partner_SU_with_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_partner_SU_with_ID
                    ORDER BY
                        a.SU_partner_SU_with_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_partner_SU_with_Posit p
            JOIN
                SU_partner_SU_with_Annex a
            ON
                a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            WHERE
                p.SU_partner_SU_with_ChangedAt <= changingTimepoint
            AND
                a.SU_partner_SU_with_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_partner_SU_with;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_partner_SU_with (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_ID_partner,
            SU_ID_with,
            SU_partner_SU_with_ChangedAt,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Reliability
        FROM (
            SELECT
                a.Metadata_SU_partner_SU_with,
                p.SU_partner_SU_with_ID,
                p.SU_ID_partner,
                p.SU_ID_with,
                p.SU_partner_SU_with_ChangedAt,
                a.SU_partner_SU_with_PositedAt,
                a.SU_partner_SU_with_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_partner_SU_with_ID
                    ORDER BY
                        a.SU_partner_SU_with_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_partner_SU_with_Posit p
            JOIN
                SU_partner_SU_with_Annex a
            ON
                a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            WHERE
                p.SU_partner_SU_with_ChangedAt > changingTimepoint
            AND
                a.SU_partner_SU_with_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_partner_SU_with;
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
CREATE OR REPLACE FUNCTION tSU_holder_OB_item_GRD_grade (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_holder_OB_item_GRD_grade_ID,
            t.Metadata_SU_holder_OB_item_GRD_grade,
            t.SU_holder_OB_item_GRD_grade_ChangedAt,
            t.SU_holder_OB_item_GRD_grade_PositedAt,
            t.SU_holder_OB_item_GRD_grade_Reliability,
            t.SU_ID_holder,
            t.OB_ID_item,
            "kGRD_grade".GRD_Grade AS grade_GRD_Grade,
            "kGRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            t.GRD_ID_grade
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_holder,
                        r.OB_ID_item
                    ORDER BY
                        r.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_PositedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_holder_OB_item_GRD_grade,
                    po.SU_holder_OB_item_GRD_grade_ID,
                    po.SU_ID_holder,
                    po.OB_ID_item,
                    po.GRD_ID_grade,
                    po.SU_holder_OB_item_GRD_grade_ChangedAt,
                    an.SU_holder_OB_item_GRD_grade_PositedAt,
                    an.SU_holder_OB_item_GRD_grade_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_holder_OB_item_GRD_grade_ID
                        ORDER BY an.SU_holder_OB_item_GRD_grade_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_holder_OB_item_GRD_grade_Posit po
                JOIN
                    SU_holder_OB_item_GRD_grade_Annex an
                ON
                    an.SU_holder_OB_item_GRD_grade_ID = po.SU_holder_OB_item_GRD_grade_ID
                WHERE
                    po.SU_holder_OB_item_GRD_grade_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_holder_OB_item_GRD_grade_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_holder_OB_item_GRD_grade_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_grade"
        ON
            "kGRD_grade".GRD_ID = t.GRD_ID_grade
        WHERE
            t.latestPosit = 1
    ]';
END tSU_holder_OB_item_GRD_grade;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_holder_OB_item_GRD_grade (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_holder_OB_item_GRD_grade_ID,
            t.Metadata_SU_holder_OB_item_GRD_grade,
            t.SU_holder_OB_item_GRD_grade_ChangedAt,
            t.SU_holder_OB_item_GRD_grade_PositedAt,
            t.SU_holder_OB_item_GRD_grade_Reliability,
            t.SU_ID_holder,
            t.OB_ID_item,
            "kGRD_grade".GRD_Grade AS grade_GRD_Grade,
            "kGRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            t.GRD_ID_grade
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_holder,
                        r.OB_ID_item
                    ORDER BY
                        r.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_PositedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_holder_OB_item_GRD_grade,
                    po.SU_holder_OB_item_GRD_grade_ID,
                    po.SU_ID_holder,
                    po.OB_ID_item,
                    po.GRD_ID_grade,
                    po.SU_holder_OB_item_GRD_grade_ChangedAt,
                    an.SU_holder_OB_item_GRD_grade_PositedAt,
                    an.SU_holder_OB_item_GRD_grade_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_holder_OB_item_GRD_grade_ID
                        ORDER BY an.SU_holder_OB_item_GRD_grade_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_holder_OB_item_GRD_grade_Posit po
                JOIN
                    SU_holder_OB_item_GRD_grade_Annex an
                ON
                    an.SU_holder_OB_item_GRD_grade_ID = po.SU_holder_OB_item_GRD_grade_ID
                WHERE
                    po.SU_holder_OB_item_GRD_grade_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_holder_OB_item_GRD_grade_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_holder_OB_item_GRD_grade_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_grade"
        ON
            "kGRD_grade".GRD_ID = t.GRD_ID_grade
        WHERE
            t.latestPosit = 1
    ]';
END pSU_holder_OB_item_GRD_grade;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_holder_OB_item_GRD_grade
AS
SELECT
    *
FROM
    pSU_holder_OB_item_GRD_grade(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nSU_holder_OB_item_GRD_grade
AS
SELECT
    *
FROM
    pSU_holder_OB_item_GRD_grade(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dSU_holder_OB_item_GRD_grade (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_holder_OB_item_GRD_grade_ID,
            t.Metadata_SU_holder_OB_item_GRD_grade,
            t.SU_holder_OB_item_GRD_grade_ChangedAt,
            t.SU_holder_OB_item_GRD_grade_PositedAt,
            t.SU_holder_OB_item_GRD_grade_Reliability,
            t.SU_ID_holder,
            t.OB_ID_item,
            "kGRD_grade".GRD_Grade AS grade_GRD_Grade,
            "kGRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            t.GRD_ID_grade
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_holder,
                        r.OB_ID_item
                    ORDER BY
                        r.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_PositedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_holder_OB_item_GRD_grade,
                    po.SU_holder_OB_item_GRD_grade_ID,
                    po.SU_ID_holder,
                    po.OB_ID_item,
                    po.GRD_ID_grade,
                    po.SU_holder_OB_item_GRD_grade_ChangedAt,
                    an.SU_holder_OB_item_GRD_grade_PositedAt,
                    an.SU_holder_OB_item_GRD_grade_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_holder_OB_item_GRD_grade_ID
                        ORDER BY an.SU_holder_OB_item_GRD_grade_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_holder_OB_item_GRD_grade_Posit po
                JOIN
                    SU_holder_OB_item_GRD_grade_Annex an
                ON
                    an.SU_holder_OB_item_GRD_grade_ID = po.SU_holder_OB_item_GRD_grade_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_holder_OB_item_GRD_grade_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_grade"
        ON
            "kGRD_grade".GRD_ID = t.GRD_ID_grade
        WHERE
            t.latestPosit = 1
        AND
            t.SU_holder_OB_item_GRD_grade_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_holder_OB_item_GRD_grade;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tSU_keeper_OB_thing_GRD_rank (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_keeper_OB_thing_GRD_rank_ID,
            t.Metadata_SU_keeper_OB_thing_GRD_rank,
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            t.SU_keeper_OB_thing_GRD_rank_PositedAt,
            t.SU_keeper_OB_thing_GRD_rank_Reliability,
            t.SU_ID_keeper,
            t.OB_ID_thing,
            "kGRD_rank".GRD_Grade AS rank_GRD_Grade,
            "kGRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            t.GRD_ID_rank
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_keeper,
                        r.OB_ID_thing
                    ORDER BY
                        r.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_keeper_OB_thing_GRD_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ID,
                    po.SU_ID_keeper,
                    po.OB_ID_thing,
                    po.GRD_ID_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                    an.SU_keeper_OB_thing_GRD_rank_PositedAt,
                    an.SU_keeper_OB_thing_GRD_rank_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_keeper_OB_thing_GRD_rank_ID
                        ORDER BY an.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_keeper_OB_thing_GRD_rank_Posit po
                JOIN
                    SU_keeper_OB_thing_GRD_rank_Annex an
                ON
                    an.SU_keeper_OB_thing_GRD_rank_ID = po.SU_keeper_OB_thing_GRD_rank_ID
                WHERE
                    po.SU_keeper_OB_thing_GRD_rank_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_keeper_OB_thing_GRD_rank_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_keeper_OB_thing_GRD_rank_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_rank"
        ON
            "kGRD_rank".GRD_ID = t.GRD_ID_rank
        WHERE
            t.latestPosit = 1
    ]';
END tSU_keeper_OB_thing_GRD_rank;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_keeper_OB_thing_GRD_rank (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_keeper_OB_thing_GRD_rank_ID,
            t.Metadata_SU_keeper_OB_thing_GRD_rank,
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            t.SU_keeper_OB_thing_GRD_rank_PositedAt,
            t.SU_keeper_OB_thing_GRD_rank_Reliability,
            t.SU_ID_keeper,
            t.OB_ID_thing,
            "kGRD_rank".GRD_Grade AS rank_GRD_Grade,
            "kGRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            t.GRD_ID_rank
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_keeper,
                        r.OB_ID_thing
                    ORDER BY
                        r.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_keeper_OB_thing_GRD_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ID,
                    po.SU_ID_keeper,
                    po.OB_ID_thing,
                    po.GRD_ID_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                    an.SU_keeper_OB_thing_GRD_rank_PositedAt,
                    an.SU_keeper_OB_thing_GRD_rank_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_keeper_OB_thing_GRD_rank_ID
                        ORDER BY an.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_keeper_OB_thing_GRD_rank_Posit po
                JOIN
                    SU_keeper_OB_thing_GRD_rank_Annex an
                ON
                    an.SU_keeper_OB_thing_GRD_rank_ID = po.SU_keeper_OB_thing_GRD_rank_ID
                WHERE
                    po.SU_keeper_OB_thing_GRD_rank_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_keeper_OB_thing_GRD_rank_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_keeper_OB_thing_GRD_rank_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_rank"
        ON
            "kGRD_rank".GRD_ID = t.GRD_ID_rank
        WHERE
            t.latestPosit = 1
    ]';
END pSU_keeper_OB_thing_GRD_rank;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_keeper_OB_thing_GRD_rank
AS
SELECT
    *
FROM
    pSU_keeper_OB_thing_GRD_rank(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nSU_keeper_OB_thing_GRD_rank
AS
SELECT
    *
FROM
    pSU_keeper_OB_thing_GRD_rank(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dSU_keeper_OB_thing_GRD_rank (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_keeper_OB_thing_GRD_rank_ID,
            t.Metadata_SU_keeper_OB_thing_GRD_rank,
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            t.SU_keeper_OB_thing_GRD_rank_PositedAt,
            t.SU_keeper_OB_thing_GRD_rank_Reliability,
            t.SU_ID_keeper,
            t.OB_ID_thing,
            "kGRD_rank".GRD_Grade AS rank_GRD_Grade,
            "kGRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            t.GRD_ID_rank
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_keeper,
                        r.OB_ID_thing
                    ORDER BY
                        r.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_keeper_OB_thing_GRD_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ID,
                    po.SU_ID_keeper,
                    po.OB_ID_thing,
                    po.GRD_ID_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                    an.SU_keeper_OB_thing_GRD_rank_PositedAt,
                    an.SU_keeper_OB_thing_GRD_rank_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_keeper_OB_thing_GRD_rank_ID
                        ORDER BY an.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_keeper_OB_thing_GRD_rank_Posit po
                JOIN
                    SU_keeper_OB_thing_GRD_rank_Annex an
                ON
                    an.SU_keeper_OB_thing_GRD_rank_ID = po.SU_keeper_OB_thing_GRD_rank_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_keeper_OB_thing_GRD_rank_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_rank"
        ON
            "kGRD_rank".GRD_ID = t.GRD_ID_rank
        WHERE
            t.latestPosit = 1
        AND
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_keeper_OB_thing_GRD_rank;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tOB_part_SU_owner (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.OB_part_SU_owner_ID,
            t.Metadata_OB_part_SU_owner,
            t.OB_part_SU_owner_PositedAt,
            t.OB_part_SU_owner_Reliability,
            t.OB_ID_part,
            t.SU_ID_owner
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.OB_ID_part
                    ORDER BY
                        r.OB_part_SU_owner_PositedAt DESC,
                        r.OB_part_SU_owner_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_OB_part_SU_owner,
                    po.OB_part_SU_owner_ID,
                    po.OB_ID_part,
                    po.SU_ID_owner,
                    an.OB_part_SU_owner_PositedAt,
                    an.OB_part_SU_owner_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.OB_part_SU_owner_ID
                        ORDER BY an.OB_part_SU_owner_PositedAt DESC
                    ) AS rewindRank
                FROM
                    OB_part_SU_owner_Posit po
                JOIN
                    OB_part_SU_owner_Annex an
                ON
                    an.OB_part_SU_owner_ID = po.OB_part_SU_owner_ID
                WHERE
                    an.OB_part_SU_owner_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.OB_part_SU_owner_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END tOB_part_SU_owner;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pOB_part_SU_owner (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.OB_part_SU_owner_ID,
            t.Metadata_OB_part_SU_owner,
            t.OB_part_SU_owner_PositedAt,
            t.OB_part_SU_owner_Reliability,
            t.OB_ID_part,
            t.SU_ID_owner
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.OB_ID_part
                    ORDER BY
                        r.OB_part_SU_owner_PositedAt DESC,
                        r.OB_part_SU_owner_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_OB_part_SU_owner,
                    po.OB_part_SU_owner_ID,
                    po.OB_ID_part,
                    po.SU_ID_owner,
                    an.OB_part_SU_owner_PositedAt,
                    an.OB_part_SU_owner_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.OB_part_SU_owner_ID
                        ORDER BY an.OB_part_SU_owner_PositedAt DESC
                    ) AS rewindRank
                FROM
                    OB_part_SU_owner_Posit po
                JOIN
                    OB_part_SU_owner_Annex an
                ON
                    an.OB_part_SU_owner_ID = po.OB_part_SU_owner_ID
                WHERE
                    an.OB_part_SU_owner_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.OB_part_SU_owner_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END pOB_part_SU_owner;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lOB_part_SU_owner
AS
SELECT
    *
FROM
    pOB_part_SU_owner(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nOB_part_SU_owner
AS
SELECT
    *
FROM
    pOB_part_SU_owner(CAST(current_timestamp AS timestamp))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tSU_partner_SU_with (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_partner_SU_with_ID,
            t.Metadata_SU_partner_SU_with,
            t.SU_partner_SU_with_ChangedAt,
            t.SU_partner_SU_with_PositedAt,
            t.SU_partner_SU_with_Reliability,
            t.SU_ID_partner,
            t.SU_ID_with
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_partner
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_with
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_with
            FROM (
                SELECT
                    an.Metadata_SU_partner_SU_with,
                    po.SU_partner_SU_with_ID,
                    po.SU_ID_partner,
                    po.SU_ID_with,
                    po.SU_partner_SU_with_ChangedAt,
                    an.SU_partner_SU_with_PositedAt,
                    an.SU_partner_SU_with_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_partner_SU_with_ID
                        ORDER BY an.SU_partner_SU_with_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_partner_SU_with_Posit po
                JOIN
                    SU_partner_SU_with_Annex an
                ON
                    an.SU_partner_SU_with_ID = po.SU_partner_SU_with_ID
                WHERE
                    po.SU_partner_SU_with_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_partner_SU_with_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_partner_SU_with_Reliability = 1
        ) t
        WHERE
            t.latestPositSU_ID_partner = 1
        AND
            t.latestPositSU_ID_with = 1
    ]';
END tSU_partner_SU_with;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_partner_SU_with (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_partner_SU_with_ID,
            t.Metadata_SU_partner_SU_with,
            t.SU_partner_SU_with_ChangedAt,
            t.SU_partner_SU_with_PositedAt,
            t.SU_partner_SU_with_Reliability,
            t.SU_ID_partner,
            t.SU_ID_with
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_partner
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_with
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_with
            FROM (
                SELECT
                    an.Metadata_SU_partner_SU_with,
                    po.SU_partner_SU_with_ID,
                    po.SU_ID_partner,
                    po.SU_ID_with,
                    po.SU_partner_SU_with_ChangedAt,
                    an.SU_partner_SU_with_PositedAt,
                    an.SU_partner_SU_with_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_partner_SU_with_ID
                        ORDER BY an.SU_partner_SU_with_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_partner_SU_with_Posit po
                JOIN
                    SU_partner_SU_with_Annex an
                ON
                    an.SU_partner_SU_with_ID = po.SU_partner_SU_with_ID
                WHERE
                    po.SU_partner_SU_with_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_partner_SU_with_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_partner_SU_with_Reliability = 1
        ) t
        WHERE
            t.latestPositSU_ID_partner = 1
        AND
            t.latestPositSU_ID_with = 1
    ]';
END pSU_partner_SU_with;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_partner_SU_with
AS
SELECT
    *
FROM
    pSU_partner_SU_with(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nSU_partner_SU_with
AS
SELECT
    *
FROM
    pSU_partner_SU_with(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dSU_partner_SU_with (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_partner_SU_with_ID,
            t.Metadata_SU_partner_SU_with,
            t.SU_partner_SU_with_ChangedAt,
            t.SU_partner_SU_with_PositedAt,
            t.SU_partner_SU_with_Reliability,
            t.SU_ID_partner,
            t.SU_ID_with
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_partner
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_with
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_with
            FROM (
                SELECT
                    an.Metadata_SU_partner_SU_with,
                    po.SU_partner_SU_with_ID,
                    po.SU_ID_partner,
                    po.SU_ID_with,
                    po.SU_partner_SU_with_ChangedAt,
                    an.SU_partner_SU_with_PositedAt,
                    an.SU_partner_SU_with_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_partner_SU_with_ID
                        ORDER BY an.SU_partner_SU_with_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_partner_SU_with_Posit po
                JOIN
                    SU_partner_SU_with_Annex an
                ON
                    an.SU_partner_SU_with_ID = po.SU_partner_SU_with_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_partner_SU_with_Reliability = 1
        ) t
        WHERE
            t.latestPositSU_ID_partner = 1
        AND
            t.latestPositSU_ID_with = 1
        AND
            t.SU_partner_SU_with_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_partner_SU_with;
/
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
-- eq_EV_QTY_Event_Quantity tells whether two values of EV_QTY_Event_Quantity are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_EV_QTY_Event_Quantity (
    p_left IN EV_QTY_Event_Quantity_Posit.EV_QTY_Event_Quantity%TYPE,
    p_right IN EV_QTY_Event_Quantity_Posit.EV_QTY_Event_Quantity%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_QTY_Event_Quantity;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_QTY_Event_Quantity is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_EV_QTY_Event_Quantity (
    p_id IN EV_QTY_Event_Quantity_Annex.EV_QTY_ID%TYPE,
    p_positing IN EV_QTY_Event_Quantity_Annex.EV_QTY_PositedAt%TYPE
) RETURN EV_QTY_Event_Quantity_Annex.EV_QTY_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_QTY_Reliability
        FROM
            EV_QTY_Event_Quantity_Annex a
        WHERE
            a.EV_QTY_ID = p_id
        AND
            a.EV_QTY_PositedAt <= p_positing
        ORDER BY
            a.EV_QTY_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_QTY_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_QTY_Event_Quantity;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_QTY_Event_Quantity states a value of EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_QTY_Event_Quantity (
    p_owner IN EV_QTY_Event_Quantity_Posit.EV_QTY_EV_ID%TYPE,
    p_value IN EV_QTY_Event_Quantity_Posit.EV_QTY_Event_Quantity%TYPE,
    p_positing IN EV_QTY_Event_Quantity_Annex.EV_QTY_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_QTY_Event_Quantity_Annex.EV_QTY_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_QTY_Event_Quantity_Annex.Metadata_EV_QTY%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit EV_QTY_Event_Quantity_Posit.EV_QTY_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN EV_QTY_Event_Quantity_Posit.EV_QTY_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_QTY_Event_Quantity_Annex (
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_PositedAt,
            EV_QTY_Reliability
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
                    EV_QTY_Event_Quantity_Annex x
                WHERE
                    x.EV_QTY_ID = p_id
                AND
                    x.EV_QTY_PositedAt = v_positing
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
            p.EV_QTY_ID
        FROM
            EV_QTY_Event_Quantity_Posit p
        WHERE
            p.EV_QTY_EV_ID = p_owner
        AND
            eq_EV_QTY_Event_Quantity(p.EV_QTY_Event_Quantity, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_QTY_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_QTY_Event_Quantity_Annex a
        WHERE
            a.EV_QTY_ID = v_posit
        AND
            a.EV_QTY_PositedAt = v_positing
        AND
            a.EV_QTY_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_QTY_Event_Quantity for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_QTY_Event_Quantity_Posit p
        JOIN
            EV_QTY_Event_Quantity_Annex a
        ON
            a.EV_QTY_ID = p.EV_QTY_ID
        WHERE
            p.EV_QTY_EV_ID = p_owner
        AND
            eq_EV_QTY_Event_Quantity(p.EV_QTY_Event_Quantity, p_value) = 0
        AND
            a.EV_QTY_PositedAt = v_positing
        AND
            a.EV_QTY_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_QTY_Event_Quantity for: ' || p_owner || ', ' ||
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
            EV_QTY_Event_Quantity_Annex a
        WHERE
            a.EV_QTY_ID = v_posit
        AND
            a.EV_QTY_PositedAt = v_positing;
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
        IF COALESCE(he_EV_QTY_Event_Quantity(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO EV_QTY_Event_Quantity_Annex (
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_PositedAt,
            EV_QTY_Reliability
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
            p.EV_QTY_ID
        FROM
            EV_QTY_Event_Quantity_Posit p
        WHERE
            p.EV_QTY_EV_ID = p_owner
        AND
            eq_EV_QTY_Event_Quantity(p.EV_QTY_Event_Quantity, p_value) = 0
        AND
            COALESCE(he_EV_QTY_Event_Quantity(p.EV_QTY_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_QTY_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_QTY_Event_Quantity_Posit (
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_QTY_ID INTO v_posit;
    END IF;
    INSERT INTO EV_QTY_Event_Quantity_Annex (
        Metadata_EV_QTY,
        EV_QTY_ID,
        EV_QTY_PositedAt,
        EV_QTY_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_QTY_Event_Quantity;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_QTY_Event_Quantity instead of INSERT trigger on EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_EV_QTY_Event_Quantity
INSTEAD OF INSERT ON EV_QTY_Event_Quantity
FOR EACH ROW
BEGIN
    ip_EV_QTY_Event_Quantity(
        p_owner => :NEW.EV_QTY_EV_ID,
        p_value => :NEW.EV_QTY_Event_Quantity,
        p_positing => :NEW.EV_QTY_PositedAt,
        p_reliability => :NEW.EV_QTY_Reliability,
        p_metadata => :NEW.Metadata_EV_QTY
    );
END it_EV_QTY_Event_Quantity;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_PLC_Event_Place tells whether two values of EV_PLC_Event_Place are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_EV_PLC_Event_Place (
    p_left IN EV_PLC_Event_Place_Posit.EV_PLC_Event_Place%TYPE,
    p_right IN EV_PLC_Event_Place_Posit.EV_PLC_Event_Place%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_PLC_Event_Place;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_PLC_Event_Place is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_EV_PLC_Event_Place (
    p_id IN EV_PLC_Event_Place_Annex.EV_PLC_ID%TYPE,
    p_positing IN EV_PLC_Event_Place_Annex.EV_PLC_PositedAt%TYPE
) RETURN EV_PLC_Event_Place_Annex.EV_PLC_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_PLC_Reliability
        FROM
            EV_PLC_Event_Place_Annex a
        WHERE
            a.EV_PLC_ID = p_id
        AND
            a.EV_PLC_PositedAt <= p_positing
        ORDER BY
            a.EV_PLC_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_PLC_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_PLC_Event_Place;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_PLC_Event_Place states a value of EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_PLC_Event_Place (
    p_owner IN EV_PLC_Event_Place_Posit.EV_PLC_EV_ID%TYPE,
    p_value IN EV_PLC_Event_Place_Posit.EV_PLC_Event_Place%TYPE,
    p_changing IN EV_PLC_Event_Place_Posit.EV_PLC_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN EV_PLC_Event_Place_Annex.EV_PLC_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_PLC_Event_Place_Annex.EV_PLC_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_PLC_Event_Place_Annex.Metadata_EV_PLC%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit EV_PLC_Event_Place_Posit.EV_PLC_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN EV_PLC_Event_Place_Posit.EV_PLC_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_PLC_Event_Place_Annex (
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_PositedAt,
            EV_PLC_Reliability
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
                    EV_PLC_Event_Place_Annex x
                WHERE
                    x.EV_PLC_ID = p_id
                AND
                    x.EV_PLC_PositedAt = v_positing
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
            p.EV_PLC_ID
        FROM
            EV_PLC_Event_Place_Posit p
        WHERE
            p.EV_PLC_EV_ID = p_owner
        AND
            p.EV_PLC_ChangedAt = v_changing
        AND
            eq_EV_PLC_Event_Place(p.EV_PLC_Event_Place, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_PLC_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_PLC_Event_Place_Annex a
        WHERE
            a.EV_PLC_ID = v_posit
        AND
            a.EV_PLC_PositedAt = v_positing
        AND
            a.EV_PLC_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_PLC_Event_Place for: ' || p_owner || ', ' ||
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
            EV_PLC_Event_Place_Posit p
        JOIN
            EV_PLC_Event_Place_Annex a
        ON
            a.EV_PLC_ID = p.EV_PLC_ID
        WHERE
            p.EV_PLC_EV_ID = p_owner
        AND
            p.EV_PLC_ChangedAt = v_changing
        AND
            eq_EV_PLC_Event_Place(p.EV_PLC_Event_Place, p_value) = 0
        AND
            a.EV_PLC_PositedAt = v_positing
        AND
            a.EV_PLC_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_PLC_Event_Place for: ' || p_owner || ', ' ||
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
            EV_PLC_Event_Place_Annex a
        WHERE
            a.EV_PLC_ID = v_posit
        AND
            a.EV_PLC_PositedAt = v_positing;
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
        IF COALESCE(he_EV_PLC_Event_Place(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO EV_PLC_Event_Place_Annex (
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_PositedAt,
            EV_PLC_Reliability
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
            p.EV_PLC_ID
        FROM
            EV_PLC_Event_Place_Posit p
        WHERE
            p.EV_PLC_EV_ID = p_owner
        AND
            p.EV_PLC_ChangedAt = v_changing
        AND
            eq_EV_PLC_Event_Place(p.EV_PLC_Event_Place, p_value) = 0
        AND
            COALESCE(he_EV_PLC_Event_Place(p.EV_PLC_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_PLC_ID);
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.EV_PLC_Event_Place
        FROM
            EV_PLC_Event_Place_Posit p
        WHERE
            p.EV_PLC_EV_ID = p_owner
        AND
            p.EV_PLC_ChangedAt < v_changing
        AND
            COALESCE(he_EV_PLC_Event_Place(p.EV_PLC_ID, v_positing), 0) = 1
        ORDER BY
            p.EV_PLC_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_EV_PLC_Event_Place(r.EV_PLC_Event_Place, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in EV_PLC_Event_Place for: ' || p_owner || ', ' || v_changing || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.EV_PLC_ID,
            f.EV_PLC_Event_Place
        FROM
            EV_PLC_Event_Place_Posit f
        WHERE
            f.EV_PLC_EV_ID = p_owner
        AND
            f.EV_PLC_ChangedAt > v_changing
        AND
            COALESCE(he_EV_PLC_Event_Place(f.EV_PLC_ID, v_positing), 0) = 1
        ORDER BY
            f.EV_PLC_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_EV_PLC_Event_Place(r.EV_PLC_Event_Place, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in EV_PLC_Event_Place for: ' || p_owner || ', ' || v_changing || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_PLC_Event_Place_Posit (
            EV_PLC_EV_ID,
            EV_PLC_ChangedAt,
            EV_PLC_Event_Place
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING EV_PLC_ID INTO v_posit;
    END IF;
    INSERT INTO EV_PLC_Event_Place_Annex (
        Metadata_EV_PLC,
        EV_PLC_ID,
        EV_PLC_PositedAt,
        EV_PLC_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_PLC_Event_Place;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_PLC_Event_Place instead of INSERT trigger on EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_EV_PLC_Event_Place
INSTEAD OF INSERT ON EV_PLC_Event_Place
FOR EACH ROW
BEGIN
    ip_EV_PLC_Event_Place(
        p_owner => :NEW.EV_PLC_EV_ID,
        p_value => :NEW.EV_PLC_Event_Place,
        p_changing => :NEW.EV_PLC_ChangedAt,
        p_positing => :NEW.EV_PLC_PositedAt,
        p_reliability => :NEW.EV_PLC_Reliability,
        p_metadata => :NEW.Metadata_EV_PLC
    );
END it_EV_PLC_Event_Place;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_NAM_Subject_Name tells whether two values of SU_NAM_Subject_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_NAM_Subject_Name (
    p_left IN SU_NAM_Subject_Name_Posit.SU_NAM_Subject_Name%TYPE,
    p_right IN SU_NAM_Subject_Name_Posit.SU_NAM_Subject_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_NAM_Subject_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_NAM_Subject_Name is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_NAM_Subject_Name (
    p_id IN SU_NAM_Subject_Name_Annex.SU_NAM_ID%TYPE,
    p_positing IN SU_NAM_Subject_Name_Annex.SU_NAM_PositedAt%TYPE
) RETURN SU_NAM_Subject_Name_Annex.SU_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_NAM_Reliability
        FROM
            SU_NAM_Subject_Name_Annex a
        WHERE
            a.SU_NAM_ID = p_id
        AND
            a.SU_NAM_PositedAt <= p_positing
        ORDER BY
            a.SU_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_NAM_Subject_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_NAM_Subject_Name states a value of SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_NAM_Subject_Name (
    p_owner IN SU_NAM_Subject_Name_Posit.SU_NAM_SU_ID%TYPE,
    p_value IN SU_NAM_Subject_Name_Posit.SU_NAM_Subject_Name%TYPE,
    p_positing IN SU_NAM_Subject_Name_Annex.SU_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_NAM_Subject_Name_Annex.SU_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_NAM_Subject_Name_Annex.Metadata_SU_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit SU_NAM_Subject_Name_Posit.SU_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_NAM_Subject_Name_Posit.SU_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_NAM_Subject_Name_Annex (
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_PositedAt,
            SU_NAM_Reliability
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
                    SU_NAM_Subject_Name_Annex x
                WHERE
                    x.SU_NAM_ID = p_id
                AND
                    x.SU_NAM_PositedAt = v_positing
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
            p.SU_NAM_ID
        FROM
            SU_NAM_Subject_Name_Posit p
        WHERE
            p.SU_NAM_SU_ID = p_owner
        AND
            eq_SU_NAM_Subject_Name(p.SU_NAM_Subject_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_NAM_Subject_Name_Annex a
        WHERE
            a.SU_NAM_ID = v_posit
        AND
            a.SU_NAM_PositedAt = v_positing
        AND
            a.SU_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NAM_Subject_Name for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_NAM_Subject_Name_Posit p
        JOIN
            SU_NAM_Subject_Name_Annex a
        ON
            a.SU_NAM_ID = p.SU_NAM_ID
        WHERE
            p.SU_NAM_SU_ID = p_owner
        AND
            eq_SU_NAM_Subject_Name(p.SU_NAM_Subject_Name, p_value) = 0
        AND
            a.SU_NAM_PositedAt = v_positing
        AND
            a.SU_NAM_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NAM_Subject_Name for: ' || p_owner || ', ' ||
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
            SU_NAM_Subject_Name_Annex a
        WHERE
            a.SU_NAM_ID = v_posit
        AND
            a.SU_NAM_PositedAt = v_positing;
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
        IF COALESCE(he_SU_NAM_Subject_Name(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_NAM_Subject_Name_Annex (
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_PositedAt,
            SU_NAM_Reliability
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
            p.SU_NAM_ID
        FROM
            SU_NAM_Subject_Name_Posit p
        WHERE
            p.SU_NAM_SU_ID = p_owner
        AND
            eq_SU_NAM_Subject_Name(p.SU_NAM_Subject_Name, p_value) = 0
        AND
            COALESCE(he_SU_NAM_Subject_Name(p.SU_NAM_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_NAM_Subject_Name_Posit (
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING SU_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO SU_NAM_Subject_Name_Annex (
        Metadata_SU_NAM,
        SU_NAM_ID,
        SU_NAM_PositedAt,
        SU_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_NAM_Subject_Name;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NAM_Subject_Name instead of INSERT trigger on SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_NAM_Subject_Name
INSTEAD OF INSERT ON SU_NAM_Subject_Name
FOR EACH ROW
BEGIN
    ip_SU_NAM_Subject_Name(
        p_owner => :NEW.SU_NAM_SU_ID,
        p_value => :NEW.SU_NAM_Subject_Name,
        p_positing => :NEW.SU_NAM_PositedAt,
        p_reliability => :NEW.SU_NAM_Reliability,
        p_metadata => :NEW.Metadata_SU_NAM
    );
END it_SU_NAM_Subject_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_COD_Subject_Code tells whether two values of SU_COD_Subject_Code are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_COD_Subject_Code (
    p_left IN SU_COD_Subject_Code_Posit.SU_COD_Subject_Code%TYPE,
    p_right IN SU_COD_Subject_Code_Posit.SU_COD_Subject_Code%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_COD_Subject_Code;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_COD_Subject_Code is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_COD_Subject_Code (
    p_id IN SU_COD_Subject_Code_Annex.SU_COD_ID%TYPE,
    p_positing IN SU_COD_Subject_Code_Annex.SU_COD_PositedAt%TYPE
) RETURN SU_COD_Subject_Code_Annex.SU_COD_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_COD_Reliability
        FROM
            SU_COD_Subject_Code_Annex a
        WHERE
            a.SU_COD_ID = p_id
        AND
            a.SU_COD_PositedAt <= p_positing
        ORDER BY
            a.SU_COD_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_COD_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_COD_Subject_Code;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_COD_Subject_Code states a value of SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_COD_Subject_Code (
    p_owner IN SU_COD_Subject_Code_Posit.SU_COD_SU_ID%TYPE,
    p_value IN SU_COD_Subject_Code_Posit.SU_COD_Subject_Code%TYPE,
    p_positing IN SU_COD_Subject_Code_Annex.SU_COD_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_COD_Subject_Code_Annex.SU_COD_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_COD_Subject_Code_Annex.Metadata_SU_COD%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit SU_COD_Subject_Code_Posit.SU_COD_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_COD_Subject_Code_Posit.SU_COD_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_COD_Subject_Code_Annex (
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_PositedAt,
            SU_COD_Reliability
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
                    SU_COD_Subject_Code_Annex x
                WHERE
                    x.SU_COD_ID = p_id
                AND
                    x.SU_COD_PositedAt = v_positing
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
            p.SU_COD_ID
        FROM
            SU_COD_Subject_Code_Posit p
        WHERE
            p.SU_COD_SU_ID = p_owner
        AND
            eq_SU_COD_Subject_Code(p.SU_COD_Subject_Code, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_COD_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_COD_Subject_Code_Annex a
        WHERE
            a.SU_COD_ID = v_posit
        AND
            a.SU_COD_PositedAt = v_positing
        AND
            a.SU_COD_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_COD_Subject_Code for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_COD_Subject_Code_Posit p
        JOIN
            SU_COD_Subject_Code_Annex a
        ON
            a.SU_COD_ID = p.SU_COD_ID
        WHERE
            p.SU_COD_SU_ID = p_owner
        AND
            eq_SU_COD_Subject_Code(p.SU_COD_Subject_Code, p_value) = 0
        AND
            a.SU_COD_PositedAt = v_positing
        AND
            a.SU_COD_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_COD_Subject_Code for: ' || p_owner || ', ' ||
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
            SU_COD_Subject_Code_Annex a
        WHERE
            a.SU_COD_ID = v_posit
        AND
            a.SU_COD_PositedAt = v_positing;
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
        IF COALESCE(he_SU_COD_Subject_Code(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_COD_Subject_Code_Annex (
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_PositedAt,
            SU_COD_Reliability
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
            p.SU_COD_ID
        FROM
            SU_COD_Subject_Code_Posit p
        WHERE
            p.SU_COD_SU_ID = p_owner
        AND
            eq_SU_COD_Subject_Code(p.SU_COD_Subject_Code, p_value) = 0
        AND
            COALESCE(he_SU_COD_Subject_Code(p.SU_COD_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_COD_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_COD_Subject_Code_Posit (
            SU_COD_SU_ID,
            SU_COD_Subject_Code
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING SU_COD_ID INTO v_posit;
    END IF;
    INSERT INTO SU_COD_Subject_Code_Annex (
        Metadata_SU_COD,
        SU_COD_ID,
        SU_COD_PositedAt,
        SU_COD_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_COD_Subject_Code;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_COD_Subject_Code instead of INSERT trigger on SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_COD_Subject_Code
INSTEAD OF INSERT ON SU_COD_Subject_Code
FOR EACH ROW
BEGIN
    ip_SU_COD_Subject_Code(
        p_owner => :NEW.SU_COD_SU_ID,
        p_value => :NEW.SU_COD_Subject_Code,
        p_positing => :NEW.SU_COD_PositedAt,
        p_reliability => :NEW.SU_COD_Reliability,
        p_metadata => :NEW.Metadata_SU_COD
    );
END it_SU_COD_Subject_Code;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_GRD_Subject_Grade tells whether two values of SU_GRD_Subject_Grade are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_GRD_Subject_Grade (
    p_left IN SU_GRD_Subject_Grade_Posit.SU_GRD_GRD_ID%TYPE,
    p_right IN SU_GRD_Subject_Grade_Posit.SU_GRD_GRD_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_GRD_Subject_Grade;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_GRD_Subject_Grade is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_GRD_Subject_Grade (
    p_id IN SU_GRD_Subject_Grade_Annex.SU_GRD_ID%TYPE,
    p_positing IN SU_GRD_Subject_Grade_Annex.SU_GRD_PositedAt%TYPE
) RETURN SU_GRD_Subject_Grade_Annex.SU_GRD_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_GRD_Reliability
        FROM
            SU_GRD_Subject_Grade_Annex a
        WHERE
            a.SU_GRD_ID = p_id
        AND
            a.SU_GRD_PositedAt <= p_positing
        ORDER BY
            a.SU_GRD_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_GRD_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_GRD_Subject_Grade;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_GRD_Subject_Grade states a value of SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_GRD_Subject_Grade (
    p_owner IN SU_GRD_Subject_Grade_Posit.SU_GRD_SU_ID%TYPE,
    p_value IN SU_GRD_Subject_Grade_Posit.SU_GRD_GRD_ID%TYPE,
    p_positing IN SU_GRD_Subject_Grade_Annex.SU_GRD_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_GRD_Subject_Grade_Annex.SU_GRD_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_GRD_Subject_Grade_Annex.Metadata_SU_GRD%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit SU_GRD_Subject_Grade_Posit.SU_GRD_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_GRD_Subject_Grade_Posit.SU_GRD_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_GRD_Subject_Grade_Annex (
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Reliability
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
                    SU_GRD_Subject_Grade_Annex x
                WHERE
                    x.SU_GRD_ID = p_id
                AND
                    x.SU_GRD_PositedAt = v_positing
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
            p.SU_GRD_ID
        FROM
            SU_GRD_Subject_Grade_Posit p
        WHERE
            p.SU_GRD_SU_ID = p_owner
        AND
            eq_SU_GRD_Subject_Grade(p.SU_GRD_GRD_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_GRD_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_GRD_Subject_Grade_Annex a
        WHERE
            a.SU_GRD_ID = v_posit
        AND
            a.SU_GRD_PositedAt = v_positing
        AND
            a.SU_GRD_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_GRD_Subject_Grade for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_GRD_Subject_Grade_Posit p
        JOIN
            SU_GRD_Subject_Grade_Annex a
        ON
            a.SU_GRD_ID = p.SU_GRD_ID
        WHERE
            p.SU_GRD_SU_ID = p_owner
        AND
            eq_SU_GRD_Subject_Grade(p.SU_GRD_GRD_ID, p_value) = 0
        AND
            a.SU_GRD_PositedAt = v_positing
        AND
            a.SU_GRD_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_GRD_Subject_Grade for: ' || p_owner || ', ' ||
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
            SU_GRD_Subject_Grade_Annex a
        WHERE
            a.SU_GRD_ID = v_posit
        AND
            a.SU_GRD_PositedAt = v_positing;
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
        IF COALESCE(he_SU_GRD_Subject_Grade(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_GRD_Subject_Grade_Annex (
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Reliability
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
            p.SU_GRD_ID
        FROM
            SU_GRD_Subject_Grade_Posit p
        WHERE
            p.SU_GRD_SU_ID = p_owner
        AND
            eq_SU_GRD_Subject_Grade(p.SU_GRD_GRD_ID, p_value) = 0
        AND
            COALESCE(he_SU_GRD_Subject_Grade(p.SU_GRD_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_GRD_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_GRD_Subject_Grade_Posit (
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING SU_GRD_ID INTO v_posit;
    END IF;
    INSERT INTO SU_GRD_Subject_Grade_Annex (
        Metadata_SU_GRD,
        SU_GRD_ID,
        SU_GRD_PositedAt,
        SU_GRD_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_GRD_Subject_Grade;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_GRD_Subject_Grade instead of INSERT trigger on SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_GRD_Subject_Grade
INSTEAD OF INSERT ON SU_GRD_Subject_Grade
FOR EACH ROW
BEGIN
    ip_SU_GRD_Subject_Grade(
        p_owner => :NEW.SU_GRD_SU_ID,
        p_value => :NEW.SU_GRD_GRD_ID,
        p_positing => :NEW.SU_GRD_PositedAt,
        p_reliability => :NEW.SU_GRD_Reliability,
        p_metadata => :NEW.Metadata_SU_GRD
    );
END it_SU_GRD_Subject_Grade;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_NOT_Subject_Note tells whether two values of SU_NOT_Subject_Note are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_NOT_Subject_Note (
    p_left IN SU_NOT_Subject_Note_Posit.SU_NOT_Subject_Note%TYPE,
    p_right IN SU_NOT_Subject_Note_Posit.SU_NOT_Subject_Note%TYPE
) RETURN NUMBER
IS
BEGIN
    IF p_left IS NULL OR p_right IS NULL THEN
        RETURN 0;
    END IF;
    RETURN CASE WHEN DBMS_LOB.COMPARE(p_left, p_right) = 0 THEN 1 ELSE 0 END;
END eq_SU_NOT_Subject_Note;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_NOT_Subject_Note is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_NOT_Subject_Note (
    p_id IN SU_NOT_Subject_Note_Annex.SU_NOT_ID%TYPE,
    p_positing IN SU_NOT_Subject_Note_Annex.SU_NOT_PositedAt%TYPE
) RETURN SU_NOT_Subject_Note_Annex.SU_NOT_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_NOT_Reliability
        FROM
            SU_NOT_Subject_Note_Annex a
        WHERE
            a.SU_NOT_ID = p_id
        AND
            a.SU_NOT_PositedAt <= p_positing
        ORDER BY
            a.SU_NOT_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_NOT_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_NOT_Subject_Note;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_NOT_Subject_Note states a value of SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_NOT_Subject_Note (
    p_owner IN SU_NOT_Subject_Note_Posit.SU_NOT_SU_ID%TYPE,
    p_value IN SU_NOT_Subject_Note_Posit.SU_NOT_Subject_Note%TYPE,
    p_positing IN SU_NOT_Subject_Note_Annex.SU_NOT_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_NOT_Subject_Note_Annex.SU_NOT_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_NOT_Subject_Note_Annex.Metadata_SU_NOT%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit SU_NOT_Subject_Note_Posit.SU_NOT_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_NOT_Subject_Note_Posit.SU_NOT_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_NOT_Subject_Note_Annex (
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_PositedAt,
            SU_NOT_Reliability
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
                    SU_NOT_Subject_Note_Annex x
                WHERE
                    x.SU_NOT_ID = p_id
                AND
                    x.SU_NOT_PositedAt = v_positing
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
            p.SU_NOT_ID
        FROM
            SU_NOT_Subject_Note_Posit p
        WHERE
            p.SU_NOT_SU_ID = p_owner
        AND
            eq_SU_NOT_Subject_Note(p.SU_NOT_Subject_Note, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_NOT_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_NOT_Subject_Note_Annex a
        WHERE
            a.SU_NOT_ID = v_posit
        AND
            a.SU_NOT_PositedAt = v_positing
        AND
            a.SU_NOT_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NOT_Subject_Note for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_NOT_Subject_Note_Posit p
        JOIN
            SU_NOT_Subject_Note_Annex a
        ON
            a.SU_NOT_ID = p.SU_NOT_ID
        WHERE
            p.SU_NOT_SU_ID = p_owner
        AND
            eq_SU_NOT_Subject_Note(p.SU_NOT_Subject_Note, p_value) = 0
        AND
            a.SU_NOT_PositedAt = v_positing
        AND
            a.SU_NOT_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NOT_Subject_Note for: ' || p_owner || ', ' ||
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
            SU_NOT_Subject_Note_Annex a
        WHERE
            a.SU_NOT_ID = v_posit
        AND
            a.SU_NOT_PositedAt = v_positing;
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
        IF COALESCE(he_SU_NOT_Subject_Note(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_NOT_Subject_Note_Annex (
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_PositedAt,
            SU_NOT_Reliability
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
            p.SU_NOT_ID
        FROM
            SU_NOT_Subject_Note_Posit p
        WHERE
            p.SU_NOT_SU_ID = p_owner
        AND
            eq_SU_NOT_Subject_Note(p.SU_NOT_Subject_Note, p_value) = 0
        AND
            COALESCE(he_SU_NOT_Subject_Note(p.SU_NOT_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_NOT_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_NOT_Subject_Note_Posit (
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING SU_NOT_ID INTO v_posit;
    END IF;
    INSERT INTO SU_NOT_Subject_Note_Annex (
        Metadata_SU_NOT,
        SU_NOT_ID,
        SU_NOT_PositedAt,
        SU_NOT_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_NOT_Subject_Note;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NOT_Subject_Note instead of INSERT trigger on SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_NOT_Subject_Note
INSTEAD OF INSERT ON SU_NOT_Subject_Note
FOR EACH ROW
BEGIN
    ip_SU_NOT_Subject_Note(
        p_owner => :NEW.SU_NOT_SU_ID,
        p_value => :NEW.SU_NOT_Subject_Note,
        p_positing => :NEW.SU_NOT_PositedAt,
        p_reliability => :NEW.SU_NOT_Reliability,
        p_metadata => :NEW.Metadata_SU_NOT
    );
END it_SU_NOT_Subject_Note;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TTL_Subject_Title tells whether two values of SU_TTL_Subject_Title are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_TTL_Subject_Title (
    p_left IN SU_TTL_Subject_Title_Posit.SU_TTL_Subject_Title%TYPE,
    p_right IN SU_TTL_Subject_Title_Posit.SU_TTL_Subject_Title%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_TTL_Subject_Title;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_TTL_Subject_Title is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_TTL_Subject_Title (
    p_id IN SU_TTL_Subject_Title_Annex.SU_TTL_ID%TYPE,
    p_positing IN SU_TTL_Subject_Title_Annex.SU_TTL_PositedAt%TYPE
) RETURN SU_TTL_Subject_Title_Annex.SU_TTL_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_TTL_Reliability
        FROM
            SU_TTL_Subject_Title_Annex a
        WHERE
            a.SU_TTL_ID = p_id
        AND
            a.SU_TTL_PositedAt <= p_positing
        ORDER BY
            a.SU_TTL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_TTL_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_TTL_Subject_Title;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TTL_Subject_Title states a value of SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TTL_Subject_Title (
    p_owner IN SU_TTL_Subject_Title_Posit.SU_TTL_SU_ID%TYPE,
    p_value IN SU_TTL_Subject_Title_Posit.SU_TTL_Subject_Title%TYPE,
    p_changing IN SU_TTL_Subject_Title_Posit.SU_TTL_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_TTL_Subject_Title_Annex.SU_TTL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_TTL_Subject_Title_Annex.SU_TTL_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_TTL_Subject_Title_Annex.Metadata_SU_TTL%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit SU_TTL_Subject_Title_Posit.SU_TTL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_TTL_Subject_Title_Posit.SU_TTL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_TTL_Subject_Title_Annex (
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_PositedAt,
            SU_TTL_Reliability
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
                    SU_TTL_Subject_Title_Annex x
                WHERE
                    x.SU_TTL_ID = p_id
                AND
                    x.SU_TTL_PositedAt = v_positing
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
            p.SU_TTL_ID
        FROM
            SU_TTL_Subject_Title_Posit p
        WHERE
            p.SU_TTL_SU_ID = p_owner
        AND
            p.SU_TTL_ChangedAt = v_changing
        AND
            eq_SU_TTL_Subject_Title(p.SU_TTL_Subject_Title, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_TTL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_TTL_Subject_Title_Annex a
        WHERE
            a.SU_TTL_ID = v_posit
        AND
            a.SU_TTL_PositedAt = v_positing
        AND
            a.SU_TTL_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TTL_Subject_Title for: ' || p_owner || ', ' ||
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
            SU_TTL_Subject_Title_Posit p
        JOIN
            SU_TTL_Subject_Title_Annex a
        ON
            a.SU_TTL_ID = p.SU_TTL_ID
        WHERE
            p.SU_TTL_SU_ID = p_owner
        AND
            p.SU_TTL_ChangedAt = v_changing
        AND
            eq_SU_TTL_Subject_Title(p.SU_TTL_Subject_Title, p_value) = 0
        AND
            a.SU_TTL_PositedAt = v_positing
        AND
            a.SU_TTL_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TTL_Subject_Title for: ' || p_owner || ', ' ||
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
            SU_TTL_Subject_Title_Annex a
        WHERE
            a.SU_TTL_ID = v_posit
        AND
            a.SU_TTL_PositedAt = v_positing;
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
        IF COALESCE(he_SU_TTL_Subject_Title(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_TTL_Subject_Title_Annex (
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_PositedAt,
            SU_TTL_Reliability
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
            p.SU_TTL_ID
        FROM
            SU_TTL_Subject_Title_Posit p
        WHERE
            p.SU_TTL_SU_ID = p_owner
        AND
            p.SU_TTL_ChangedAt = v_changing
        AND
            eq_SU_TTL_Subject_Title(p.SU_TTL_Subject_Title, p_value) = 0
        AND
            COALESCE(he_SU_TTL_Subject_Title(p.SU_TTL_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_TTL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_TTL_Subject_Title_Posit (
            SU_TTL_SU_ID,
            SU_TTL_ChangedAt,
            SU_TTL_Subject_Title
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_TTL_ID INTO v_posit;
    END IF;
    INSERT INTO SU_TTL_Subject_Title_Annex (
        Metadata_SU_TTL,
        SU_TTL_ID,
        SU_TTL_PositedAt,
        SU_TTL_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_TTL_Subject_Title;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TTL_Subject_Title instead of INSERT trigger on SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_TTL_Subject_Title
INSTEAD OF INSERT ON SU_TTL_Subject_Title
FOR EACH ROW
BEGIN
    ip_SU_TTL_Subject_Title(
        p_owner => :NEW.SU_TTL_SU_ID,
        p_value => :NEW.SU_TTL_Subject_Title,
        p_changing => :NEW.SU_TTL_ChangedAt,
        p_positing => :NEW.SU_TTL_PositedAt,
        p_reliability => :NEW.SU_TTL_Reliability,
        p_metadata => :NEW.Metadata_SU_TTL
    );
END it_SU_TTL_Subject_Title;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_STA_Subject_State tells whether two values of SU_STA_Subject_State are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_STA_Subject_State (
    p_left IN SU_STA_Subject_State_Posit.SU_STA_Subject_State%TYPE,
    p_right IN SU_STA_Subject_State_Posit.SU_STA_Subject_State%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_STA_Subject_State;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_STA_Subject_State is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_STA_Subject_State (
    p_id IN SU_STA_Subject_State_Annex.SU_STA_ID%TYPE,
    p_positing IN SU_STA_Subject_State_Annex.SU_STA_PositedAt%TYPE
) RETURN SU_STA_Subject_State_Annex.SU_STA_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_STA_Reliability
        FROM
            SU_STA_Subject_State_Annex a
        WHERE
            a.SU_STA_ID = p_id
        AND
            a.SU_STA_PositedAt <= p_positing
        ORDER BY
            a.SU_STA_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_STA_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_STA_Subject_State;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_STA_Subject_State states a value of SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_STA_Subject_State (
    p_owner IN SU_STA_Subject_State_Posit.SU_STA_SU_ID%TYPE,
    p_value IN SU_STA_Subject_State_Posit.SU_STA_Subject_State%TYPE,
    p_changing IN SU_STA_Subject_State_Posit.SU_STA_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_STA_Subject_State_Annex.SU_STA_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_STA_Subject_State_Annex.SU_STA_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_STA_Subject_State_Annex.Metadata_SU_STA%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit SU_STA_Subject_State_Posit.SU_STA_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_STA_Subject_State_Posit.SU_STA_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_STA_Subject_State_Annex (
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_PositedAt,
            SU_STA_Reliability
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
                    SU_STA_Subject_State_Annex x
                WHERE
                    x.SU_STA_ID = p_id
                AND
                    x.SU_STA_PositedAt = v_positing
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
            p.SU_STA_ID
        FROM
            SU_STA_Subject_State_Posit p
        WHERE
            p.SU_STA_SU_ID = p_owner
        AND
            p.SU_STA_ChangedAt = v_changing
        AND
            eq_SU_STA_Subject_State(p.SU_STA_Subject_State, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_STA_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_STA_Subject_State_Annex a
        WHERE
            a.SU_STA_ID = v_posit
        AND
            a.SU_STA_PositedAt = v_positing
        AND
            a.SU_STA_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_STA_Subject_State for: ' || p_owner || ', ' ||
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
            SU_STA_Subject_State_Posit p
        JOIN
            SU_STA_Subject_State_Annex a
        ON
            a.SU_STA_ID = p.SU_STA_ID
        WHERE
            p.SU_STA_SU_ID = p_owner
        AND
            p.SU_STA_ChangedAt = v_changing
        AND
            eq_SU_STA_Subject_State(p.SU_STA_Subject_State, p_value) = 0
        AND
            a.SU_STA_PositedAt = v_positing
        AND
            a.SU_STA_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_STA_Subject_State for: ' || p_owner || ', ' ||
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
            SU_STA_Subject_State_Annex a
        WHERE
            a.SU_STA_ID = v_posit
        AND
            a.SU_STA_PositedAt = v_positing;
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
        IF COALESCE(he_SU_STA_Subject_State(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_STA_Subject_State_Annex (
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_PositedAt,
            SU_STA_Reliability
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
            p.SU_STA_ID
        FROM
            SU_STA_Subject_State_Posit p
        WHERE
            p.SU_STA_SU_ID = p_owner
        AND
            p.SU_STA_ChangedAt = v_changing
        AND
            eq_SU_STA_Subject_State(p.SU_STA_Subject_State, p_value) = 0
        AND
            COALESCE(he_SU_STA_Subject_State(p.SU_STA_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_STA_ID);
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.SU_STA_Subject_State
        FROM
            SU_STA_Subject_State_Posit p
        WHERE
            p.SU_STA_SU_ID = p_owner
        AND
            p.SU_STA_ChangedAt < v_changing
        AND
            COALESCE(he_SU_STA_Subject_State(p.SU_STA_ID, v_positing), 0) = 1
        ORDER BY
            p.SU_STA_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_STA_Subject_State(r.SU_STA_Subject_State, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in SU_STA_Subject_State for: ' || p_owner || ', ' || v_changing || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.SU_STA_ID,
            f.SU_STA_Subject_State
        FROM
            SU_STA_Subject_State_Posit f
        WHERE
            f.SU_STA_SU_ID = p_owner
        AND
            f.SU_STA_ChangedAt > v_changing
        AND
            COALESCE(he_SU_STA_Subject_State(f.SU_STA_ID, v_positing), 0) = 1
        ORDER BY
            f.SU_STA_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_STA_Subject_State(r.SU_STA_Subject_State, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in SU_STA_Subject_State for: ' || p_owner || ', ' || v_changing || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_STA_Subject_State_Posit (
            SU_STA_SU_ID,
            SU_STA_ChangedAt,
            SU_STA_Subject_State
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_STA_ID INTO v_posit;
    END IF;
    INSERT INTO SU_STA_Subject_State_Annex (
        Metadata_SU_STA,
        SU_STA_ID,
        SU_STA_PositedAt,
        SU_STA_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_STA_Subject_State;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_STA_Subject_State instead of INSERT trigger on SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_STA_Subject_State
INSTEAD OF INSERT ON SU_STA_Subject_State
FOR EACH ROW
BEGIN
    ip_SU_STA_Subject_State(
        p_owner => :NEW.SU_STA_SU_ID,
        p_value => :NEW.SU_STA_Subject_State,
        p_changing => :NEW.SU_STA_ChangedAt,
        p_positing => :NEW.SU_STA_PositedAt,
        p_reliability => :NEW.SU_STA_Reliability,
        p_metadata => :NEW.Metadata_SU_STA
    );
END it_SU_STA_Subject_State;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_LBL_Subject_Label tells whether two values of SU_LBL_Subject_Label are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_LBL_Subject_Label (
    p_left IN SU_LBL_Subject_Label_Posit.SU_LBL_Subject_Label%TYPE,
    p_right IN SU_LBL_Subject_Label_Posit.SU_LBL_Subject_Label%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_LBL_Subject_Label;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_LBL_Subject_Label is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_LBL_Subject_Label (
    p_id IN SU_LBL_Subject_Label_Annex.SU_LBL_ID%TYPE,
    p_positing IN SU_LBL_Subject_Label_Annex.SU_LBL_PositedAt%TYPE
) RETURN SU_LBL_Subject_Label_Annex.SU_LBL_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_LBL_Reliability
        FROM
            SU_LBL_Subject_Label_Annex a
        WHERE
            a.SU_LBL_ID = p_id
        AND
            a.SU_LBL_PositedAt <= p_positing
        ORDER BY
            a.SU_LBL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_LBL_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_LBL_Subject_Label;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_LBL_Subject_Label states a value of SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_LBL_Subject_Label (
    p_owner IN SU_LBL_Subject_Label_Posit.SU_LBL_SU_ID%TYPE,
    p_value IN SU_LBL_Subject_Label_Posit.SU_LBL_Subject_Label%TYPE,
    p_changing IN SU_LBL_Subject_Label_Posit.SU_LBL_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_LBL_Subject_Label_Annex.SU_LBL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_LBL_Subject_Label_Annex.SU_LBL_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_LBL_Subject_Label_Annex.Metadata_SU_LBL%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit SU_LBL_Subject_Label_Posit.SU_LBL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_LBL_Subject_Label_Posit.SU_LBL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_LBL_Subject_Label_Annex (
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_PositedAt,
            SU_LBL_Reliability
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
                    SU_LBL_Subject_Label_Annex x
                WHERE
                    x.SU_LBL_ID = p_id
                AND
                    x.SU_LBL_PositedAt = v_positing
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
            p.SU_LBL_ID
        FROM
            SU_LBL_Subject_Label_Posit p
        WHERE
            p.SU_LBL_SU_ID = p_owner
        AND
            p.SU_LBL_ChangedAt = v_changing
        AND
            eq_SU_LBL_Subject_Label(p.SU_LBL_Subject_Label, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_LBL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_LBL_Subject_Label_Annex a
        WHERE
            a.SU_LBL_ID = v_posit
        AND
            a.SU_LBL_PositedAt = v_positing
        AND
            a.SU_LBL_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LBL_Subject_Label for: ' || p_owner || ', ' ||
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
            SU_LBL_Subject_Label_Posit p
        JOIN
            SU_LBL_Subject_Label_Annex a
        ON
            a.SU_LBL_ID = p.SU_LBL_ID
        WHERE
            p.SU_LBL_SU_ID = p_owner
        AND
            p.SU_LBL_ChangedAt = v_changing
        AND
            eq_SU_LBL_Subject_Label(p.SU_LBL_Subject_Label, p_value) = 0
        AND
            a.SU_LBL_PositedAt = v_positing
        AND
            a.SU_LBL_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LBL_Subject_Label for: ' || p_owner || ', ' ||
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
            SU_LBL_Subject_Label_Annex a
        WHERE
            a.SU_LBL_ID = v_posit
        AND
            a.SU_LBL_PositedAt = v_positing;
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
        IF COALESCE(he_SU_LBL_Subject_Label(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_LBL_Subject_Label_Annex (
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_PositedAt,
            SU_LBL_Reliability
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
            p.SU_LBL_ID
        FROM
            SU_LBL_Subject_Label_Posit p
        WHERE
            p.SU_LBL_SU_ID = p_owner
        AND
            p.SU_LBL_ChangedAt = v_changing
        AND
            eq_SU_LBL_Subject_Label(p.SU_LBL_Subject_Label, p_value) = 0
        AND
            COALESCE(he_SU_LBL_Subject_Label(p.SU_LBL_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_LBL_ID);
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.SU_LBL_Subject_Label
        FROM
            SU_LBL_Subject_Label_Posit p
        WHERE
            p.SU_LBL_SU_ID = p_owner
        AND
            p.SU_LBL_ChangedAt < v_changing
        AND
            COALESCE(he_SU_LBL_Subject_Label(p.SU_LBL_ID, v_positing), 0) = 1
        ORDER BY
            p.SU_LBL_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_LBL_Subject_Label(r.SU_LBL_Subject_Label, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.SU_LBL_ID,
            f.SU_LBL_Subject_Label
        FROM
            SU_LBL_Subject_Label_Posit f
        WHERE
            f.SU_LBL_SU_ID = p_owner
        AND
            f.SU_LBL_ChangedAt > v_changing
        AND
            COALESCE(he_SU_LBL_Subject_Label(f.SU_LBL_ID, v_positing), 0) = 1
        ORDER BY
            f.SU_LBL_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_LBL_Subject_Label(r.SU_LBL_Subject_Label, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.SU_LBL_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_LBL_Subject_Label_Posit (
            SU_LBL_SU_ID,
            SU_LBL_ChangedAt,
            SU_LBL_Subject_Label
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_LBL_ID INTO v_posit;
    END IF;
    INSERT INTO SU_LBL_Subject_Label_Annex (
        Metadata_SU_LBL,
        SU_LBL_ID,
        SU_LBL_PositedAt,
        SU_LBL_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_LBL_Subject_Label;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LBL_Subject_Label instead of INSERT trigger on SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_LBL_Subject_Label
INSTEAD OF INSERT ON SU_LBL_Subject_Label
FOR EACH ROW
BEGIN
    ip_SU_LBL_Subject_Label(
        p_owner => :NEW.SU_LBL_SU_ID,
        p_value => :NEW.SU_LBL_Subject_Label,
        p_changing => :NEW.SU_LBL_ChangedAt,
        p_positing => :NEW.SU_LBL_PositedAt,
        p_reliability => :NEW.SU_LBL_Reliability,
        p_metadata => :NEW.Metadata_SU_LBL
    );
END it_SU_LBL_Subject_Label;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TAG_Subject_Tag tells whether two values of SU_TAG_Subject_Tag are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_TAG_Subject_Tag (
    p_left IN SU_TAG_Subject_Tag_Posit.SU_TAG_Subject_Tag%TYPE,
    p_right IN SU_TAG_Subject_Tag_Posit.SU_TAG_Subject_Tag%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_TAG_Subject_Tag;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_TAG_Subject_Tag is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_TAG_Subject_Tag (
    p_id IN SU_TAG_Subject_Tag_Annex.SU_TAG_ID%TYPE,
    p_positing IN SU_TAG_Subject_Tag_Annex.SU_TAG_PositedAt%TYPE
) RETURN SU_TAG_Subject_Tag_Annex.SU_TAG_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_TAG_Reliability
        FROM
            SU_TAG_Subject_Tag_Annex a
        WHERE
            a.SU_TAG_ID = p_id
        AND
            a.SU_TAG_PositedAt <= p_positing
        ORDER BY
            a.SU_TAG_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_TAG_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_TAG_Subject_Tag;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TAG_Subject_Tag states a value of SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TAG_Subject_Tag (
    p_owner IN SU_TAG_Subject_Tag_Posit.SU_TAG_SU_ID%TYPE,
    p_value IN SU_TAG_Subject_Tag_Posit.SU_TAG_Subject_Tag%TYPE,
    p_changing IN SU_TAG_Subject_Tag_Posit.SU_TAG_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_TAG_Subject_Tag_Annex.SU_TAG_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_TAG_Subject_Tag_Annex.SU_TAG_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_TAG_Subject_Tag_Annex.Metadata_SU_TAG%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit SU_TAG_Subject_Tag_Posit.SU_TAG_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_TAG_Subject_Tag_Posit.SU_TAG_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_TAG_Subject_Tag_Annex (
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_PositedAt,
            SU_TAG_Reliability
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
                    SU_TAG_Subject_Tag_Annex x
                WHERE
                    x.SU_TAG_ID = p_id
                AND
                    x.SU_TAG_PositedAt = v_positing
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
            p.SU_TAG_ID
        FROM
            SU_TAG_Subject_Tag_Posit p
        WHERE
            p.SU_TAG_SU_ID = p_owner
        AND
            p.SU_TAG_ChangedAt = v_changing
        AND
            eq_SU_TAG_Subject_Tag(p.SU_TAG_Subject_Tag, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_TAG_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_TAG_Subject_Tag_Annex a
        WHERE
            a.SU_TAG_ID = v_posit
        AND
            a.SU_TAG_PositedAt = v_positing
        AND
            a.SU_TAG_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TAG_Subject_Tag for: ' || p_owner || ', ' ||
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
            SU_TAG_Subject_Tag_Posit p
        JOIN
            SU_TAG_Subject_Tag_Annex a
        ON
            a.SU_TAG_ID = p.SU_TAG_ID
        WHERE
            p.SU_TAG_SU_ID = p_owner
        AND
            p.SU_TAG_ChangedAt = v_changing
        AND
            eq_SU_TAG_Subject_Tag(p.SU_TAG_Subject_Tag, p_value) = 0
        AND
            a.SU_TAG_PositedAt = v_positing
        AND
            a.SU_TAG_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TAG_Subject_Tag for: ' || p_owner || ', ' ||
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
            SU_TAG_Subject_Tag_Annex a
        WHERE
            a.SU_TAG_ID = v_posit
        AND
            a.SU_TAG_PositedAt = v_positing;
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
        IF COALESCE(he_SU_TAG_Subject_Tag(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_TAG_Subject_Tag_Annex (
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_PositedAt,
            SU_TAG_Reliability
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
            p.SU_TAG_ID
        FROM
            SU_TAG_Subject_Tag_Posit p
        WHERE
            p.SU_TAG_SU_ID = p_owner
        AND
            p.SU_TAG_ChangedAt = v_changing
        AND
            eq_SU_TAG_Subject_Tag(p.SU_TAG_Subject_Tag, p_value) = 0
        AND
            COALESCE(he_SU_TAG_Subject_Tag(p.SU_TAG_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_TAG_ID);
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.SU_TAG_Subject_Tag
        FROM
            SU_TAG_Subject_Tag_Posit p
        WHERE
            p.SU_TAG_SU_ID = p_owner
        AND
            p.SU_TAG_ChangedAt < v_changing
        AND
            COALESCE(he_SU_TAG_Subject_Tag(p.SU_TAG_ID, v_positing), 0) = 1
        ORDER BY
            p.SU_TAG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_TAG_Subject_Tag(r.SU_TAG_Subject_Tag, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.SU_TAG_ID,
            f.SU_TAG_Subject_Tag
        FROM
            SU_TAG_Subject_Tag_Posit f
        WHERE
            f.SU_TAG_SU_ID = p_owner
        AND
            f.SU_TAG_ChangedAt > v_changing
        AND
            COALESCE(he_SU_TAG_Subject_Tag(f.SU_TAG_ID, v_positing), 0) = 1
        ORDER BY
            f.SU_TAG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_TAG_Subject_Tag(r.SU_TAG_Subject_Tag, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.SU_TAG_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_TAG_Subject_Tag_Posit (
            SU_TAG_SU_ID,
            SU_TAG_ChangedAt,
            SU_TAG_Subject_Tag
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_TAG_ID INTO v_posit;
    END IF;
    INSERT INTO SU_TAG_Subject_Tag_Annex (
        Metadata_SU_TAG,
        SU_TAG_ID,
        SU_TAG_PositedAt,
        SU_TAG_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_TAG_Subject_Tag;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TAG_Subject_Tag instead of INSERT trigger on SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_TAG_Subject_Tag
INSTEAD OF INSERT ON SU_TAG_Subject_Tag
FOR EACH ROW
BEGIN
    ip_SU_TAG_Subject_Tag(
        p_owner => :NEW.SU_TAG_SU_ID,
        p_value => :NEW.SU_TAG_Subject_Tag,
        p_changing => :NEW.SU_TAG_ChangedAt,
        p_positing => :NEW.SU_TAG_PositedAt,
        p_reliability => :NEW.SU_TAG_Reliability,
        p_metadata => :NEW.Metadata_SU_TAG
    );
END it_SU_TAG_Subject_Tag;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_LVL_Subject_Level tells whether two values of SU_LVL_Subject_Level are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_LVL_Subject_Level (
    p_left IN SU_LVL_Subject_Level_Posit.SU_LVL_GRD_ID%TYPE,
    p_right IN SU_LVL_Subject_Level_Posit.SU_LVL_GRD_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_LVL_Subject_Level;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_LVL_Subject_Level is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_LVL_Subject_Level (
    p_id IN SU_LVL_Subject_Level_Annex.SU_LVL_ID%TYPE,
    p_positing IN SU_LVL_Subject_Level_Annex.SU_LVL_PositedAt%TYPE
) RETURN SU_LVL_Subject_Level_Annex.SU_LVL_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_LVL_Reliability
        FROM
            SU_LVL_Subject_Level_Annex a
        WHERE
            a.SU_LVL_ID = p_id
        AND
            a.SU_LVL_PositedAt <= p_positing
        ORDER BY
            a.SU_LVL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_LVL_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_LVL_Subject_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_LVL_Subject_Level states a value of SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_LVL_Subject_Level (
    p_owner IN SU_LVL_Subject_Level_Posit.SU_LVL_SU_ID%TYPE,
    p_value IN SU_LVL_Subject_Level_Posit.SU_LVL_GRD_ID%TYPE,
    p_changing IN SU_LVL_Subject_Level_Posit.SU_LVL_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_LVL_Subject_Level_Annex.SU_LVL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_LVL_Subject_Level_Annex.SU_LVL_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_LVL_Subject_Level_Annex.Metadata_SU_LVL%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit SU_LVL_Subject_Level_Posit.SU_LVL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_LVL_Subject_Level_Posit.SU_LVL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_LVL_Subject_Level_Annex (
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_PositedAt,
            SU_LVL_Reliability
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
                    SU_LVL_Subject_Level_Annex x
                WHERE
                    x.SU_LVL_ID = p_id
                AND
                    x.SU_LVL_PositedAt = v_positing
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
            p.SU_LVL_ID
        FROM
            SU_LVL_Subject_Level_Posit p
        WHERE
            p.SU_LVL_SU_ID = p_owner
        AND
            p.SU_LVL_ChangedAt = v_changing
        AND
            eq_SU_LVL_Subject_Level(p.SU_LVL_GRD_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_LVL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_LVL_Subject_Level_Annex a
        WHERE
            a.SU_LVL_ID = v_posit
        AND
            a.SU_LVL_PositedAt = v_positing
        AND
            a.SU_LVL_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LVL_Subject_Level for: ' || p_owner || ', ' ||
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
            SU_LVL_Subject_Level_Posit p
        JOIN
            SU_LVL_Subject_Level_Annex a
        ON
            a.SU_LVL_ID = p.SU_LVL_ID
        WHERE
            p.SU_LVL_SU_ID = p_owner
        AND
            p.SU_LVL_ChangedAt = v_changing
        AND
            eq_SU_LVL_Subject_Level(p.SU_LVL_GRD_ID, p_value) = 0
        AND
            a.SU_LVL_PositedAt = v_positing
        AND
            a.SU_LVL_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LVL_Subject_Level for: ' || p_owner || ', ' ||
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
            SU_LVL_Subject_Level_Annex a
        WHERE
            a.SU_LVL_ID = v_posit
        AND
            a.SU_LVL_PositedAt = v_positing;
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
        IF COALESCE(he_SU_LVL_Subject_Level(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_LVL_Subject_Level_Annex (
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_PositedAt,
            SU_LVL_Reliability
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
            p.SU_LVL_ID
        FROM
            SU_LVL_Subject_Level_Posit p
        WHERE
            p.SU_LVL_SU_ID = p_owner
        AND
            p.SU_LVL_ChangedAt = v_changing
        AND
            eq_SU_LVL_Subject_Level(p.SU_LVL_GRD_ID, p_value) = 0
        AND
            COALESCE(he_SU_LVL_Subject_Level(p.SU_LVL_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_LVL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_LVL_Subject_Level_Posit (
            SU_LVL_SU_ID,
            SU_LVL_ChangedAt,
            SU_LVL_GRD_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_LVL_ID INTO v_posit;
    END IF;
    INSERT INTO SU_LVL_Subject_Level_Annex (
        Metadata_SU_LVL,
        SU_LVL_ID,
        SU_LVL_PositedAt,
        SU_LVL_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_LVL_Subject_Level;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LVL_Subject_Level instead of INSERT trigger on SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_LVL_Subject_Level
INSTEAD OF INSERT ON SU_LVL_Subject_Level
FOR EACH ROW
BEGIN
    ip_SU_LVL_Subject_Level(
        p_owner => :NEW.SU_LVL_SU_ID,
        p_value => :NEW.SU_LVL_GRD_ID,
        p_changing => :NEW.SU_LVL_ChangedAt,
        p_positing => :NEW.SU_LVL_PositedAt,
        p_reliability => :NEW.SU_LVL_Reliability,
        p_metadata => :NEW.Metadata_SU_LVL
    );
END it_SU_LVL_Subject_Level;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TXT_Subject_Text tells whether two values of SU_TXT_Subject_Text are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_TXT_Subject_Text (
    p_left IN SU_TXT_Subject_Text_Posit.SU_TXT_Subject_Text%TYPE,
    p_right IN SU_TXT_Subject_Text_Posit.SU_TXT_Subject_Text%TYPE
) RETURN NUMBER
IS
BEGIN
    IF p_left IS NULL OR p_right IS NULL THEN
        RETURN 0;
    END IF;
    RETURN CASE WHEN DBMS_LOB.COMPARE(p_left, p_right) = 0 THEN 1 ELSE 0 END;
END eq_SU_TXT_Subject_Text;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_TXT_Subject_Text is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_TXT_Subject_Text (
    p_id IN SU_TXT_Subject_Text_Annex.SU_TXT_ID%TYPE,
    p_positing IN SU_TXT_Subject_Text_Annex.SU_TXT_PositedAt%TYPE
) RETURN SU_TXT_Subject_Text_Annex.SU_TXT_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_TXT_Reliability
        FROM
            SU_TXT_Subject_Text_Annex a
        WHERE
            a.SU_TXT_ID = p_id
        AND
            a.SU_TXT_PositedAt <= p_positing
        ORDER BY
            a.SU_TXT_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_TXT_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_TXT_Subject_Text;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TXT_Subject_Text states a value of SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TXT_Subject_Text (
    p_owner IN SU_TXT_Subject_Text_Posit.SU_TXT_SU_ID%TYPE,
    p_value IN SU_TXT_Subject_Text_Posit.SU_TXT_Subject_Text%TYPE,
    p_changing IN SU_TXT_Subject_Text_Posit.SU_TXT_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_TXT_Subject_Text_Annex.SU_TXT_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_TXT_Subject_Text_Annex.SU_TXT_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_TXT_Subject_Text_Annex.Metadata_SU_TXT%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit SU_TXT_Subject_Text_Posit.SU_TXT_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_TXT_Subject_Text_Posit.SU_TXT_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_TXT_Subject_Text_Annex (
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_PositedAt,
            SU_TXT_Reliability
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
                    SU_TXT_Subject_Text_Annex x
                WHERE
                    x.SU_TXT_ID = p_id
                AND
                    x.SU_TXT_PositedAt = v_positing
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
            p.SU_TXT_ID
        FROM
            SU_TXT_Subject_Text_Posit p
        WHERE
            p.SU_TXT_SU_ID = p_owner
        AND
            p.SU_TXT_ChangedAt = v_changing
        AND
            eq_SU_TXT_Subject_Text(p.SU_TXT_Subject_Text, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_TXT_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_TXT_Subject_Text_Annex a
        WHERE
            a.SU_TXT_ID = v_posit
        AND
            a.SU_TXT_PositedAt = v_positing
        AND
            a.SU_TXT_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TXT_Subject_Text for: ' || p_owner || ', ' ||
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
            SU_TXT_Subject_Text_Posit p
        JOIN
            SU_TXT_Subject_Text_Annex a
        ON
            a.SU_TXT_ID = p.SU_TXT_ID
        WHERE
            p.SU_TXT_SU_ID = p_owner
        AND
            p.SU_TXT_ChangedAt = v_changing
        AND
            eq_SU_TXT_Subject_Text(p.SU_TXT_Subject_Text, p_value) = 0
        AND
            a.SU_TXT_PositedAt = v_positing
        AND
            a.SU_TXT_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TXT_Subject_Text for: ' || p_owner || ', ' ||
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
            SU_TXT_Subject_Text_Annex a
        WHERE
            a.SU_TXT_ID = v_posit
        AND
            a.SU_TXT_PositedAt = v_positing;
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
        IF COALESCE(he_SU_TXT_Subject_Text(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_TXT_Subject_Text_Annex (
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_PositedAt,
            SU_TXT_Reliability
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
            p.SU_TXT_ID
        FROM
            SU_TXT_Subject_Text_Posit p
        WHERE
            p.SU_TXT_SU_ID = p_owner
        AND
            p.SU_TXT_ChangedAt = v_changing
        AND
            eq_SU_TXT_Subject_Text(p.SU_TXT_Subject_Text, p_value) = 0
        AND
            COALESCE(he_SU_TXT_Subject_Text(p.SU_TXT_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_TXT_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_TXT_Subject_Text_Posit (
            SU_TXT_SU_ID,
            SU_TXT_ChangedAt,
            SU_TXT_Subject_Text
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_TXT_ID INTO v_posit;
    END IF;
    INSERT INTO SU_TXT_Subject_Text_Annex (
        Metadata_SU_TXT,
        SU_TXT_ID,
        SU_TXT_PositedAt,
        SU_TXT_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_TXT_Subject_Text;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TXT_Subject_Text instead of INSERT trigger on SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_TXT_Subject_Text
INSTEAD OF INSERT ON SU_TXT_Subject_Text
FOR EACH ROW
BEGIN
    ip_SU_TXT_Subject_Text(
        p_owner => :NEW.SU_TXT_SU_ID,
        p_value => :NEW.SU_TXT_Subject_Text,
        p_changing => :NEW.SU_TXT_ChangedAt,
        p_positing => :NEW.SU_TXT_PositedAt,
        p_reliability => :NEW.SU_TXT_Reliability,
        p_metadata => :NEW.Metadata_SU_TXT
    );
END it_SU_TXT_Subject_Text;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_ASR_Subject_Assessment tells whether two values of SU_ASR_Subject_Assessment are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_ASR_Subject_Assessment (
    p_left IN SU_ASR_Subject_Assessment_Posit.SU_ASR_Subject_Assessment%TYPE,
    p_right IN SU_ASR_Subject_Assessment_Posit.SU_ASR_Subject_Assessment%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_ASR_Subject_Assessment;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_ASR_Subject_Assessment is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_ASR_Subject_Assessment (
    p_id IN SU_ASR_Subject_Assessment_Annex.SU_ASR_ID%TYPE,
    p_positing IN SU_ASR_Subject_Assessment_Annex.SU_ASR_PositedAt%TYPE
) RETURN SU_ASR_Subject_Assessment_Annex.SU_ASR_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_ASR_Reliability
        FROM
            SU_ASR_Subject_Assessment_Annex a
        WHERE
            a.SU_ASR_ID = p_id
        AND
            a.SU_ASR_PositedAt <= p_positing
        ORDER BY
            a.SU_ASR_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_ASR_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_ASR_Subject_Assessment;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_ASR_Subject_Assessment states a value of SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_ASR_Subject_Assessment (
    p_owner IN SU_ASR_Subject_Assessment_Posit.SU_ASR_SU_ID%TYPE,
    p_value IN SU_ASR_Subject_Assessment_Posit.SU_ASR_Subject_Assessment%TYPE,
    p_changing IN SU_ASR_Subject_Assessment_Posit.SU_ASR_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_ASR_Subject_Assessment_Annex.SU_ASR_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_ASR_Subject_Assessment_Annex.SU_ASR_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_ASR_Subject_Assessment_Annex.Metadata_SU_ASR%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit SU_ASR_Subject_Assessment_Posit.SU_ASR_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_ASR_Subject_Assessment_Posit.SU_ASR_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_ASR_Subject_Assessment_Annex (
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_PositedAt,
            SU_ASR_Reliability
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
                    SU_ASR_Subject_Assessment_Annex x
                WHERE
                    x.SU_ASR_ID = p_id
                AND
                    x.SU_ASR_PositedAt = v_positing
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
            p.SU_ASR_ID
        FROM
            SU_ASR_Subject_Assessment_Posit p
        WHERE
            p.SU_ASR_SU_ID = p_owner
        AND
            p.SU_ASR_ChangedAt = v_changing
        AND
            eq_SU_ASR_Subject_Assessment(p.SU_ASR_Subject_Assessment, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_ASR_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_ASR_Subject_Assessment_Annex a
        WHERE
            a.SU_ASR_ID = v_posit
        AND
            a.SU_ASR_PositedAt = v_positing
        AND
            a.SU_ASR_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ASR_Subject_Assessment for: ' || p_owner || ', ' ||
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
            SU_ASR_Subject_Assessment_Posit p
        JOIN
            SU_ASR_Subject_Assessment_Annex a
        ON
            a.SU_ASR_ID = p.SU_ASR_ID
        WHERE
            p.SU_ASR_SU_ID = p_owner
        AND
            p.SU_ASR_ChangedAt = v_changing
        AND
            eq_SU_ASR_Subject_Assessment(p.SU_ASR_Subject_Assessment, p_value) = 0
        AND
            a.SU_ASR_PositedAt = v_positing
        AND
            a.SU_ASR_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ASR_Subject_Assessment for: ' || p_owner || ', ' ||
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
            SU_ASR_Subject_Assessment_Annex a
        WHERE
            a.SU_ASR_ID = v_posit
        AND
            a.SU_ASR_PositedAt = v_positing;
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
        IF COALESCE(he_SU_ASR_Subject_Assessment(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_ASR_Subject_Assessment_Annex (
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_PositedAt,
            SU_ASR_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    IF v_posit IS NOT NULL THEN
        IF COALESCE(he_SU_ASR_Subject_Assessment(v_posit, v_positing), 0) = 1 THEN
            RETURN;
        END IF;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.SU_ASR_ID
        FROM
            SU_ASR_Subject_Assessment_Posit p
        WHERE
            p.SU_ASR_SU_ID = p_owner
        AND
            p.SU_ASR_ChangedAt = v_changing
        AND
            eq_SU_ASR_Subject_Assessment(p.SU_ASR_Subject_Assessment, p_value) = 0
        AND
            COALESCE(he_SU_ASR_Subject_Assessment(p.SU_ASR_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_ASR_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_ASR_Subject_Assessment_Posit (
            SU_ASR_SU_ID,
            SU_ASR_ChangedAt,
            SU_ASR_Subject_Assessment
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_ASR_ID INTO v_posit;
    END IF;
    INSERT INTO SU_ASR_Subject_Assessment_Annex (
        Metadata_SU_ASR,
        SU_ASR_ID,
        SU_ASR_PositedAt,
        SU_ASR_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_ASR_Subject_Assessment;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ASR_Subject_Assessment instead of INSERT trigger on SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_ASR_Subject_Assessment
INSTEAD OF INSERT ON SU_ASR_Subject_Assessment
FOR EACH ROW
BEGIN
    ip_SU_ASR_Subject_Assessment(
        p_owner => :NEW.SU_ASR_SU_ID,
        p_value => :NEW.SU_ASR_Subject_Assessment,
        p_changing => :NEW.SU_ASR_ChangedAt,
        p_positing => :NEW.SU_ASR_PositedAt,
        p_reliability => :NEW.SU_ASR_Reliability,
        p_metadata => :NEW.Metadata_SU_ASR
    );
END it_SU_ASR_Subject_Assessment;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_ERS_Subject_Erasable tells whether two values of SU_ERS_Subject_Erasable are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_ERS_Subject_Erasable (
    p_left IN SU_ERS_Subject_Erasable_Posit.SU_ERS_Subject_Erasable%TYPE,
    p_right IN SU_ERS_Subject_Erasable_Posit.SU_ERS_Subject_Erasable%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_ERS_Subject_Erasable;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_ERS_Subject_Erasable is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_ERS_Subject_Erasable (
    p_id IN SU_ERS_Subject_Erasable_Annex.SU_ERS_ID%TYPE,
    p_positing IN SU_ERS_Subject_Erasable_Annex.SU_ERS_PositedAt%TYPE
) RETURN SU_ERS_Subject_Erasable_Annex.SU_ERS_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_ERS_Reliability
        FROM
            SU_ERS_Subject_Erasable_Annex a
        WHERE
            a.SU_ERS_ID = p_id
        AND
            a.SU_ERS_PositedAt <= p_positing
        ORDER BY
            a.SU_ERS_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_ERS_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_ERS_Subject_Erasable;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_ERS_Subject_Erasable states a value of SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_ERS_Subject_Erasable (
    p_owner IN SU_ERS_Subject_Erasable_Posit.SU_ERS_SU_ID%TYPE,
    p_value IN SU_ERS_Subject_Erasable_Posit.SU_ERS_Subject_Erasable%TYPE,
    p_changing IN SU_ERS_Subject_Erasable_Posit.SU_ERS_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_ERS_Subject_Erasable_Annex.SU_ERS_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_ERS_Subject_Erasable_Annex.SU_ERS_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_ERS_Subject_Erasable_Annex.Metadata_SU_ERS%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_changing timestamp;
    v_posit SU_ERS_Subject_Erasable_Posit.SU_ERS_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_ERS_Subject_Erasable_Posit.SU_ERS_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_ERS_Subject_Erasable_Annex (
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_PositedAt,
            SU_ERS_Reliability
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
                    SU_ERS_Subject_Erasable_Annex x
                WHERE
                    x.SU_ERS_ID = p_id
                AND
                    x.SU_ERS_PositedAt = v_positing
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
            p.SU_ERS_ID
        FROM
            SU_ERS_Subject_Erasable_Posit p
        WHERE
            p.SU_ERS_SU_ID = p_owner
        AND
            p.SU_ERS_ChangedAt = v_changing
        AND
            eq_SU_ERS_Subject_Erasable(p.SU_ERS_Subject_Erasable, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_ERS_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_ERS_Subject_Erasable_Annex a
        WHERE
            a.SU_ERS_ID = v_posit
        AND
            a.SU_ERS_PositedAt = v_positing
        AND
            a.SU_ERS_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ERS_Subject_Erasable for: ' || p_owner || ', ' ||
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
            SU_ERS_Subject_Erasable_Posit p
        JOIN
            SU_ERS_Subject_Erasable_Annex a
        ON
            a.SU_ERS_ID = p.SU_ERS_ID
        WHERE
            p.SU_ERS_SU_ID = p_owner
        AND
            p.SU_ERS_ChangedAt = v_changing
        AND
            eq_SU_ERS_Subject_Erasable(p.SU_ERS_Subject_Erasable, p_value) = 0
        AND
            a.SU_ERS_PositedAt = v_positing
        AND
            a.SU_ERS_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ERS_Subject_Erasable for: ' || p_owner || ', ' ||
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
            SU_ERS_Subject_Erasable_Annex a
        WHERE
            a.SU_ERS_ID = v_posit
        AND
            a.SU_ERS_PositedAt = v_positing;
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
        IF COALESCE(he_SU_ERS_Subject_Erasable(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO SU_ERS_Subject_Erasable_Annex (
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_PositedAt,
            SU_ERS_Reliability
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
            p.SU_ERS_ID
        FROM
            SU_ERS_Subject_Erasable_Posit p
        WHERE
            p.SU_ERS_SU_ID = p_owner
        AND
            p.SU_ERS_ChangedAt = v_changing
        AND
            eq_SU_ERS_Subject_Erasable(p.SU_ERS_Subject_Erasable, p_value) = 0
        AND
            COALESCE(he_SU_ERS_Subject_Erasable(p.SU_ERS_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.SU_ERS_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_ERS_Subject_Erasable_Posit (
            SU_ERS_SU_ID,
            SU_ERS_ChangedAt,
            SU_ERS_Subject_Erasable
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_ERS_ID INTO v_posit;
    END IF;
    INSERT INTO SU_ERS_Subject_Erasable_Annex (
        Metadata_SU_ERS,
        SU_ERS_ID,
        SU_ERS_PositedAt,
        SU_ERS_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_ERS_Subject_Erasable;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ERS_Subject_Erasable instead of INSERT trigger on SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_ERS_Subject_Erasable
INSTEAD OF INSERT ON SU_ERS_Subject_Erasable
FOR EACH ROW
BEGIN
    ip_SU_ERS_Subject_Erasable(
        p_owner => :NEW.SU_ERS_SU_ID,
        p_value => :NEW.SU_ERS_Subject_Erasable,
        p_changing => :NEW.SU_ERS_ChangedAt,
        p_positing => :NEW.SU_ERS_PositedAt,
        p_reliability => :NEW.SU_ERS_Reliability,
        p_metadata => :NEW.Metadata_SU_ERS
    );
END it_SU_ERS_Subject_Erasable;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_OB_NAM_Object_Name tells whether two values of OB_NAM_Object_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_OB_NAM_Object_Name (
    p_left IN OB_NAM_Object_Name_Posit.OB_NAM_Object_Name%TYPE,
    p_right IN OB_NAM_Object_Name_Posit.OB_NAM_Object_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_OB_NAM_Object_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_OB_NAM_Object_Name is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_OB_NAM_Object_Name (
    p_id IN OB_NAM_Object_Name_Annex.OB_NAM_ID%TYPE,
    p_positing IN OB_NAM_Object_Name_Annex.OB_NAM_PositedAt%TYPE
) RETURN OB_NAM_Object_Name_Annex.OB_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.OB_NAM_Reliability
        FROM
            OB_NAM_Object_Name_Annex a
        WHERE
            a.OB_NAM_ID = p_id
        AND
            a.OB_NAM_PositedAt <= p_positing
        ORDER BY
            a.OB_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.OB_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_OB_NAM_Object_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_OB_NAM_Object_Name states a value of OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_OB_NAM_Object_Name (
    p_owner IN OB_NAM_Object_Name_Posit.OB_NAM_OB_ID%TYPE,
    p_value IN OB_NAM_Object_Name_Posit.OB_NAM_Object_Name%TYPE,
    p_positing IN OB_NAM_Object_Name_Annex.OB_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN OB_NAM_Object_Name_Annex.OB_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN OB_NAM_Object_Name_Annex.Metadata_OB_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_reliability number(5,2);
    v_posit OB_NAM_Object_Name_Posit.OB_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN OB_NAM_Object_Name_Posit.OB_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO OB_NAM_Object_Name_Annex (
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_PositedAt,
            OB_NAM_Reliability
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
                    OB_NAM_Object_Name_Annex x
                WHERE
                    x.OB_NAM_ID = p_id
                AND
                    x.OB_NAM_PositedAt = v_positing
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
            p.OB_NAM_ID
        FROM
            OB_NAM_Object_Name_Posit p
        WHERE
            p.OB_NAM_OB_ID = p_owner
        AND
            eq_OB_NAM_Object_Name(p.OB_NAM_Object_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.OB_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            OB_NAM_Object_Name_Annex a
        WHERE
            a.OB_NAM_ID = v_posit
        AND
            a.OB_NAM_PositedAt = v_positing
        AND
            a.OB_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_NAM_Object_Name for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            OB_NAM_Object_Name_Posit p
        JOIN
            OB_NAM_Object_Name_Annex a
        ON
            a.OB_NAM_ID = p.OB_NAM_ID
        WHERE
            p.OB_NAM_OB_ID = p_owner
        AND
            eq_OB_NAM_Object_Name(p.OB_NAM_Object_Name, p_value) = 0
        AND
            a.OB_NAM_PositedAt = v_positing
        AND
            a.OB_NAM_Reliability = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_NAM_Object_Name for: ' || p_owner || ', ' ||
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
            OB_NAM_Object_Name_Annex a
        WHERE
            a.OB_NAM_ID = v_posit
        AND
            a.OB_NAM_PositedAt = v_positing;
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
        IF COALESCE(he_OB_NAM_Object_Name(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO OB_NAM_Object_Name_Annex (
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_PositedAt,
            OB_NAM_Reliability
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
            p.OB_NAM_ID
        FROM
            OB_NAM_Object_Name_Posit p
        WHERE
            p.OB_NAM_OB_ID = p_owner
        AND
            eq_OB_NAM_Object_Name(p.OB_NAM_Object_Name, p_value) = 0
        AND
            COALESCE(he_OB_NAM_Object_Name(p.OB_NAM_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.OB_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO OB_NAM_Object_Name_Posit (
            OB_NAM_OB_ID,
            OB_NAM_Object_Name
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING OB_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO OB_NAM_Object_Name_Annex (
        Metadata_OB_NAM,
        OB_NAM_ID,
        OB_NAM_PositedAt,
        OB_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_OB_NAM_Object_Name;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_NAM_Object_Name instead of INSERT trigger on OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_OB_NAM_Object_Name
INSTEAD OF INSERT ON OB_NAM_Object_Name
FOR EACH ROW
BEGIN
    ip_OB_NAM_Object_Name(
        p_owner => :NEW.OB_NAM_OB_ID,
        p_value => :NEW.OB_NAM_Object_Name,
        p_positing => :NEW.OB_NAM_PositedAt,
        p_reliability => :NEW.OB_NAM_Reliability,
        p_metadata => :NEW.Metadata_OB_NAM
    );
END it_OB_NAM_Object_Name;
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
-- it_lSU_Subject instead of INSERT trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_Subject
INSTEAD OF INSERT ON lSU_Subject
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_id number(10);
    v_GRD number(5);
    v_LVL number(5);
BEGIN
    v_id := :NEW.SU_ID;
    IF v_id IS NULL THEN
        INSERT INTO SU_Subject (
            Metadata_SU
        )
        VALUES (
            :NEW.Metadata_SU
        )
        RETURNING SU_ID INTO v_id;
    END IF;
    IF :NEW.SU_NAM_Subject_Name IS NOT NULL THEN
        ip_SU_NAM_Subject_Name(
            p_owner => COALESCE(:NEW.SU_NAM_SU_ID, v_id),
            p_value => :NEW.SU_NAM_Subject_Name,
            p_positing => COALESCE(:NEW.SU_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_NAM_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_NAM, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_COD_Subject_Code IS NOT NULL THEN
        ip_SU_COD_Subject_Code(
            p_owner => COALESCE(:NEW.SU_COD_SU_ID, v_id),
            p_value => :NEW.SU_COD_Subject_Code,
            p_positing => COALESCE(:NEW.SU_COD_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_COD_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_COD, :NEW.Metadata_SU)
        );
    END IF;
    v_GRD := :NEW.SU_GRD_GRD_ID;
    IF v_GRD IS NULL AND :NEW.SU_GRD_GRD_Grade IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GRD_ID
            FROM
                GRD_Grade k
            WHERE
                k.GRD_Grade = :NEW.SU_GRD_GRD_Grade
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GRD := kv.GRD_ID;
        END LOOP;
    END IF;
    IF v_GRD IS NOT NULL THEN
        ip_SU_GRD_Subject_Grade(
            p_owner => COALESCE(:NEW.SU_GRD_SU_ID, v_id),
            p_value => v_GRD,
            p_positing => COALESCE(:NEW.SU_GRD_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_GRD_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_GRD, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_NOT_Subject_Note IS NOT NULL THEN
        ip_SU_NOT_Subject_Note(
            p_owner => COALESCE(:NEW.SU_NOT_SU_ID, v_id),
            p_value => :NEW.SU_NOT_Subject_Note,
            p_positing => COALESCE(:NEW.SU_NOT_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_NOT_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_NOT, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TTL_Subject_Title IS NOT NULL THEN
        ip_SU_TTL_Subject_Title(
            p_owner => COALESCE(:NEW.SU_TTL_SU_ID, v_id),
            p_value => :NEW.SU_TTL_Subject_Title,
            p_changing => COALESCE(:NEW.SU_TTL_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.SU_TTL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_TTL_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_TTL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_STA_Subject_State IS NOT NULL THEN
        ip_SU_STA_Subject_State(
            p_owner => COALESCE(:NEW.SU_STA_SU_ID, v_id),
            p_value => :NEW.SU_STA_Subject_State,
            p_changing => COALESCE(:NEW.SU_STA_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.SU_STA_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_STA_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_STA, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_LBL_Subject_Label IS NOT NULL THEN
        ip_SU_LBL_Subject_Label(
            p_owner => COALESCE(:NEW.SU_LBL_SU_ID, v_id),
            p_value => :NEW.SU_LBL_Subject_Label,
            p_changing => COALESCE(:NEW.SU_LBL_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.SU_LBL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_LBL_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_LBL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TAG_Subject_Tag IS NOT NULL THEN
        ip_SU_TAG_Subject_Tag(
            p_owner => COALESCE(:NEW.SU_TAG_SU_ID, v_id),
            p_value => :NEW.SU_TAG_Subject_Tag,
            p_changing => COALESCE(:NEW.SU_TAG_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.SU_TAG_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_TAG_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_TAG, :NEW.Metadata_SU)
        );
    END IF;
    v_LVL := :NEW.SU_LVL_GRD_ID;
    IF v_LVL IS NULL AND :NEW.SU_LVL_GRD_Grade IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GRD_ID
            FROM
                GRD_Grade k
            WHERE
                k.GRD_Grade = :NEW.SU_LVL_GRD_Grade
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_LVL := kv.GRD_ID;
        END LOOP;
    END IF;
    IF v_LVL IS NOT NULL THEN
        ip_SU_LVL_Subject_Level(
            p_owner => COALESCE(:NEW.SU_LVL_SU_ID, v_id),
            p_value => v_LVL,
            p_changing => COALESCE(:NEW.SU_LVL_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.SU_LVL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_LVL_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_LVL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TXT_Subject_Text IS NOT NULL THEN
        ip_SU_TXT_Subject_Text(
            p_owner => COALESCE(:NEW.SU_TXT_SU_ID, v_id),
            p_value => :NEW.SU_TXT_Subject_Text,
            p_changing => COALESCE(:NEW.SU_TXT_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.SU_TXT_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_TXT_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_TXT, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_ASR_Subject_Assessment IS NOT NULL THEN
        ip_SU_ASR_Subject_Assessment(
            p_owner => COALESCE(:NEW.SU_ASR_SU_ID, v_id),
            p_value => :NEW.SU_ASR_Subject_Assessment,
            p_changing => COALESCE(:NEW.SU_ASR_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.SU_ASR_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_ASR_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_ASR, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_ERS_Subject_Erasable IS NOT NULL THEN
        ip_SU_ERS_Subject_Erasable(
            p_owner => COALESCE(:NEW.SU_ERS_SU_ID, v_id),
            p_value => :NEW.SU_ERS_Subject_Erasable,
            p_changing => COALESCE(:NEW.SU_ERS_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.SU_ERS_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_ERS_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_ERS, :NEW.Metadata_SU)
        );
    END IF;
END it_lSU_Subject;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_Subject instead of UPDATE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lSU_Subject
INSTEAD OF UPDATE ON lSU_Subject
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
    v_GRD number(5);
    v_TTL_changing timestamp;
    v_STA_changing timestamp;
    v_LBL_changing timestamp;
    v_TAG_changing timestamp;
    v_LVL number(5);
    v_LVL_changing timestamp;
    v_TXT_changing timestamp;
    v_ASR_changing timestamp;
    v_ERS_changing timestamp;
BEGIN
    IF (:NEW.SU_ID <> :OLD.SU_ID
        OR (:NEW.SU_ID IS NULL AND :OLD.SU_ID IS NOT NULL)
        OR (:NEW.SU_ID IS NOT NULL AND :OLD.SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
        OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
        OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL)) THEN TRUE ELSE FALSE END;
    -- SU_NAM_Subject_Name
    IF (:NEW.SU_NAM_ID <> :OLD.SU_NAM_ID
        OR (:NEW.SU_NAM_ID IS NULL AND :OLD.SU_NAM_ID IS NOT NULL)
        OR (:NEW.SU_NAM_ID IS NOT NULL AND :OLD.SU_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.SU_NAM_SU_ID <> :OLD.SU_NAM_SU_ID
        OR (:NEW.SU_NAM_SU_ID IS NULL AND :OLD.SU_NAM_SU_ID IS NOT NULL)
        OR (:NEW.SU_NAM_SU_ID IS NOT NULL AND :OLD.SU_NAM_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_NAM_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_NAM_Subject_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_NAM_Reliability <> :OLD.SU_NAM_Reliability
        OR (:NEW.SU_NAM_Reliability IS NULL AND :OLD.SU_NAM_Reliability IS NOT NULL)
        OR (:NEW.SU_NAM_Reliability IS NOT NULL AND :OLD.SU_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_NAM_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_NAM_PositedAt <> :OLD.SU_NAM_PositedAt
        OR (:NEW.SU_NAM_PositedAt IS NULL AND :OLD.SU_NAM_PositedAt IS NOT NULL)
        OR (:NEW.SU_NAM_PositedAt IS NOT NULL AND :OLD.SU_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_NAM_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_NAM_Subject_Name <> :OLD.SU_NAM_Subject_Name
        OR (:NEW.SU_NAM_Subject_Name IS NULL AND :OLD.SU_NAM_Subject_Name IS NOT NULL)
        OR (:NEW.SU_NAM_Subject_Name IS NOT NULL AND :OLD.SU_NAM_Subject_Name IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_NAM <> :OLD.Metadata_SU_NAM
        OR (:NEW.Metadata_SU_NAM IS NULL AND :OLD.Metadata_SU_NAM IS NOT NULL)
        OR (:NEW.Metadata_SU_NAM IS NOT NULL AND :OLD.Metadata_SU_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_NAM
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.SU_NAM_Subject_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_NAM_Subject_Name IS NULL
            OR v_positing_diff
            OR :OLD.SU_NAM_Reliability IS NULL
            OR :OLD.SU_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_SU_NAM_Subject_Name(
                    p_owner => COALESCE(:NEW.SU_NAM_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_NAM_Subject_Name,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_NAM_Subject_Name IS NULL AND :OLD.SU_NAM_Subject_Name IS NOT NULL THEN
            ip_SU_NAM_Subject_Name(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_NAM_Subject_Name,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_COD_Subject_Code
    IF (:NEW.SU_COD_ID <> :OLD.SU_COD_ID
        OR (:NEW.SU_COD_ID IS NULL AND :OLD.SU_COD_ID IS NOT NULL)
        OR (:NEW.SU_COD_ID IS NOT NULL AND :OLD.SU_COD_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_COD_ID is not updatable.');
    END IF;
    IF (:NEW.SU_COD_SU_ID <> :OLD.SU_COD_SU_ID
        OR (:NEW.SU_COD_SU_ID IS NULL AND :OLD.SU_COD_SU_ID IS NOT NULL)
        OR (:NEW.SU_COD_SU_ID IS NOT NULL AND :OLD.SU_COD_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_COD_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_COD_Subject_Code, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_COD_Reliability <> :OLD.SU_COD_Reliability
        OR (:NEW.SU_COD_Reliability IS NULL AND :OLD.SU_COD_Reliability IS NOT NULL)
        OR (:NEW.SU_COD_Reliability IS NOT NULL AND :OLD.SU_COD_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_COD_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_COD_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_COD_PositedAt <> :OLD.SU_COD_PositedAt
        OR (:NEW.SU_COD_PositedAt IS NULL AND :OLD.SU_COD_PositedAt IS NOT NULL)
        OR (:NEW.SU_COD_PositedAt IS NOT NULL AND :OLD.SU_COD_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_COD_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_COD_Subject_Code <> :OLD.SU_COD_Subject_Code
        OR (:NEW.SU_COD_Subject_Code IS NULL AND :OLD.SU_COD_Subject_Code IS NOT NULL)
        OR (:NEW.SU_COD_Subject_Code IS NOT NULL AND :OLD.SU_COD_Subject_Code IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_COD <> :OLD.Metadata_SU_COD
        OR (:NEW.Metadata_SU_COD IS NULL AND :OLD.Metadata_SU_COD IS NOT NULL)
        OR (:NEW.Metadata_SU_COD IS NOT NULL AND :OLD.Metadata_SU_COD IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_COD
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.SU_COD_Subject_Code IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_COD_Subject_Code IS NULL
            OR v_positing_diff
            OR :OLD.SU_COD_Reliability IS NULL
            OR :OLD.SU_COD_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_SU_COD_Subject_Code(
                    p_owner => COALESCE(:NEW.SU_COD_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_COD_Subject_Code,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_COD_Subject_Code IS NULL AND :OLD.SU_COD_Subject_Code IS NOT NULL THEN
            ip_SU_COD_Subject_Code(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_COD_Subject_Code,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_GRD_Subject_Grade
    IF (:NEW.SU_GRD_ID <> :OLD.SU_GRD_ID
        OR (:NEW.SU_GRD_ID IS NULL AND :OLD.SU_GRD_ID IS NOT NULL)
        OR (:NEW.SU_GRD_ID IS NOT NULL AND :OLD.SU_GRD_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_GRD_ID is not updatable.');
    END IF;
    IF (:NEW.SU_GRD_SU_ID <> :OLD.SU_GRD_SU_ID
        OR (:NEW.SU_GRD_SU_ID IS NULL AND :OLD.SU_GRD_SU_ID IS NOT NULL)
        OR (:NEW.SU_GRD_SU_ID IS NOT NULL AND :OLD.SU_GRD_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_GRD_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_GRD_Subject_Grade, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_GRD_Reliability <> :OLD.SU_GRD_Reliability
        OR (:NEW.SU_GRD_Reliability IS NULL AND :OLD.SU_GRD_Reliability IS NOT NULL)
        OR (:NEW.SU_GRD_Reliability IS NOT NULL AND :OLD.SU_GRD_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_GRD_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_GRD_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_GRD_PositedAt <> :OLD.SU_GRD_PositedAt
        OR (:NEW.SU_GRD_PositedAt IS NULL AND :OLD.SU_GRD_PositedAt IS NOT NULL)
        OR (:NEW.SU_GRD_PositedAt IS NOT NULL AND :OLD.SU_GRD_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_GRD_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_GRD_GRD_ID <> :OLD.SU_GRD_GRD_ID
        OR (:NEW.SU_GRD_GRD_ID IS NULL AND :OLD.SU_GRD_GRD_ID IS NOT NULL)
        OR (:NEW.SU_GRD_GRD_ID IS NOT NULL AND :OLD.SU_GRD_GRD_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_GRD <> :OLD.Metadata_SU_GRD
        OR (:NEW.Metadata_SU_GRD IS NULL AND :OLD.Metadata_SU_GRD IS NOT NULL)
        OR (:NEW.Metadata_SU_GRD IS NOT NULL AND :OLD.Metadata_SU_GRD IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_GRD
        END, :NEW.Metadata_SU);
    v_knot_diff := CASE WHEN (:NEW.SU_GRD_GRD_Grade <> :OLD.SU_GRD_GRD_Grade
        OR (:NEW.SU_GRD_GRD_Grade IS NULL AND :OLD.SU_GRD_GRD_Grade IS NOT NULL)
        OR (:NEW.SU_GRD_GRD_Grade IS NOT NULL AND :OLD.SU_GRD_GRD_Grade IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_GRD := :NEW.SU_GRD_GRD_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_GRD := NULL;
        IF :NEW.SU_GRD_GRD_Grade IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GRD_ID
                FROM
                    GRD_Grade k
                WHERE
                    k.GRD_Grade = :NEW.SU_GRD_GRD_Grade
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GRD := kv.GRD_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_GRD IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_GRD_GRD_ID IS NULL
            OR v_positing_diff
            OR :OLD.SU_GRD_Reliability IS NULL
            OR :OLD.SU_GRD_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_GRD_GRD_ID <> v_GRD
            THEN
                ip_SU_GRD_Subject_Grade(
                    p_owner => COALESCE(:NEW.SU_GRD_SU_ID, :NEW.SU_ID),
                    p_value => v_GRD,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.SU_GRD_GRD_ID IS NOT NULL AND (
            :NEW.SU_GRD_GRD_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.SU_GRD_GRD_Grade IS NULL AND :OLD.SU_GRD_GRD_Grade IS NOT NULL
            )
        ) THEN
            ip_SU_GRD_Subject_Grade(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_GRD_GRD_ID,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_NOT_Subject_Note
    IF (:NEW.SU_NOT_ID <> :OLD.SU_NOT_ID
        OR (:NEW.SU_NOT_ID IS NULL AND :OLD.SU_NOT_ID IS NOT NULL)
        OR (:NEW.SU_NOT_ID IS NOT NULL AND :OLD.SU_NOT_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_NOT_ID is not updatable.');
    END IF;
    IF (:NEW.SU_NOT_SU_ID <> :OLD.SU_NOT_SU_ID
        OR (:NEW.SU_NOT_SU_ID IS NULL AND :OLD.SU_NOT_SU_ID IS NOT NULL)
        OR (:NEW.SU_NOT_SU_ID IS NOT NULL AND :OLD.SU_NOT_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_NOT_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_NOT_Subject_Note, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_NOT_Reliability <> :OLD.SU_NOT_Reliability
        OR (:NEW.SU_NOT_Reliability IS NULL AND :OLD.SU_NOT_Reliability IS NOT NULL)
        OR (:NEW.SU_NOT_Reliability IS NOT NULL AND :OLD.SU_NOT_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_NOT_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_NOT_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_NOT_PositedAt <> :OLD.SU_NOT_PositedAt
        OR (:NEW.SU_NOT_PositedAt IS NULL AND :OLD.SU_NOT_PositedAt IS NOT NULL)
        OR (:NEW.SU_NOT_PositedAt IS NOT NULL AND :OLD.SU_NOT_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_NOT_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN ((:NEW.SU_NOT_Subject_Note IS NULL AND :OLD.SU_NOT_Subject_Note IS NOT NULL)
        OR (:NEW.SU_NOT_Subject_Note IS NOT NULL AND :OLD.SU_NOT_Subject_Note IS NULL)
        OR (:NEW.SU_NOT_Subject_Note IS NOT NULL AND :OLD.SU_NOT_Subject_Note IS NOT NULL
            AND DBMS_LOB.COMPARE(:NEW.SU_NOT_Subject_Note, :OLD.SU_NOT_Subject_Note) <> 0)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_NOT <> :OLD.Metadata_SU_NOT
        OR (:NEW.Metadata_SU_NOT IS NULL AND :OLD.Metadata_SU_NOT IS NOT NULL)
        OR (:NEW.Metadata_SU_NOT IS NOT NULL AND :OLD.Metadata_SU_NOT IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_NOT
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.SU_NOT_Subject_Note IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_NOT_Subject_Note IS NULL
            OR v_positing_diff
            OR :OLD.SU_NOT_Reliability IS NULL
            OR :OLD.SU_NOT_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_SU_NOT_Subject_Note(
                    p_owner => COALESCE(:NEW.SU_NOT_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_NOT_Subject_Note,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_NOT_Subject_Note IS NULL AND :OLD.SU_NOT_Subject_Note IS NOT NULL THEN
            ip_SU_NOT_Subject_Note(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_NOT_Subject_Note,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_TTL_Subject_Title
    IF (:NEW.SU_TTL_ID <> :OLD.SU_TTL_ID
        OR (:NEW.SU_TTL_ID IS NULL AND :OLD.SU_TTL_ID IS NOT NULL)
        OR (:NEW.SU_TTL_ID IS NOT NULL AND :OLD.SU_TTL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_TTL_ID is not updatable.');
    END IF;
    IF (:NEW.SU_TTL_SU_ID <> :OLD.SU_TTL_SU_ID
        OR (:NEW.SU_TTL_SU_ID IS NULL AND :OLD.SU_TTL_SU_ID IS NOT NULL)
        OR (:NEW.SU_TTL_SU_ID IS NOT NULL AND :OLD.SU_TTL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TTL_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_TTL_Subject_Title, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_TTL_Reliability <> :OLD.SU_TTL_Reliability
        OR (:NEW.SU_TTL_Reliability IS NULL AND :OLD.SU_TTL_Reliability IS NOT NULL)
        OR (:NEW.SU_TTL_Reliability IS NOT NULL AND :OLD.SU_TTL_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_TTL_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_TTL_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_TTL_PositedAt <> :OLD.SU_TTL_PositedAt
        OR (:NEW.SU_TTL_PositedAt IS NULL AND :OLD.SU_TTL_PositedAt IS NOT NULL)
        OR (:NEW.SU_TTL_PositedAt IS NOT NULL AND :OLD.SU_TTL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_TTL_ChangedAt <> :OLD.SU_TTL_ChangedAt
        OR (:NEW.SU_TTL_ChangedAt IS NULL AND :OLD.SU_TTL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TTL_ChangedAt IS NOT NULL AND :OLD.SU_TTL_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_TTL_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_TTL_Subject_Title IS NULL THEN
        v_positing := :NEW.SU_TTL_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_TTL_Subject_Title <> :OLD.SU_TTL_Subject_Title
        OR (:NEW.SU_TTL_Subject_Title IS NULL AND :OLD.SU_TTL_Subject_Title IS NOT NULL)
        OR (:NEW.SU_TTL_Subject_Title IS NOT NULL AND :OLD.SU_TTL_Subject_Title IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_TTL <> :OLD.Metadata_SU_TTL
        OR (:NEW.Metadata_SU_TTL IS NULL AND :OLD.Metadata_SU_TTL IS NOT NULL)
        OR (:NEW.Metadata_SU_TTL IS NOT NULL AND :OLD.Metadata_SU_TTL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_TTL
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_TTL_changing := :NEW.SU_TTL_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_TTL_changing := :NEW.SU_TTL_ChangedAt;
        ELSE
            v_TTL_changing := v_now;
        END IF;
        IF :NEW.SU_TTL_Subject_Title IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_TTL_Subject_Title IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_TTL_Reliability IS NULL
            OR :OLD.SU_TTL_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_SU_TTL_Subject_Title(
                    p_owner => COALESCE(:NEW.SU_TTL_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_TTL_Subject_Title,
                    p_changing => v_TTL_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_TTL_Subject_Title IS NULL AND :OLD.SU_TTL_Subject_Title IS NOT NULL THEN
            ip_SU_TTL_Subject_Title(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_TTL_Subject_Title,
                p_changing => :OLD.SU_TTL_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_STA_Subject_State
    IF (:NEW.SU_STA_ID <> :OLD.SU_STA_ID
        OR (:NEW.SU_STA_ID IS NULL AND :OLD.SU_STA_ID IS NOT NULL)
        OR (:NEW.SU_STA_ID IS NOT NULL AND :OLD.SU_STA_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_STA_ID is not updatable.');
    END IF;
    IF (:NEW.SU_STA_SU_ID <> :OLD.SU_STA_SU_ID
        OR (:NEW.SU_STA_SU_ID IS NULL AND :OLD.SU_STA_SU_ID IS NOT NULL)
        OR (:NEW.SU_STA_SU_ID IS NOT NULL AND :OLD.SU_STA_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_STA_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_STA_Subject_State, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_STA_Reliability <> :OLD.SU_STA_Reliability
        OR (:NEW.SU_STA_Reliability IS NULL AND :OLD.SU_STA_Reliability IS NOT NULL)
        OR (:NEW.SU_STA_Reliability IS NOT NULL AND :OLD.SU_STA_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_STA_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_STA_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_STA_PositedAt <> :OLD.SU_STA_PositedAt
        OR (:NEW.SU_STA_PositedAt IS NULL AND :OLD.SU_STA_PositedAt IS NOT NULL)
        OR (:NEW.SU_STA_PositedAt IS NOT NULL AND :OLD.SU_STA_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_STA_ChangedAt <> :OLD.SU_STA_ChangedAt
        OR (:NEW.SU_STA_ChangedAt IS NULL AND :OLD.SU_STA_ChangedAt IS NOT NULL)
        OR (:NEW.SU_STA_ChangedAt IS NOT NULL AND :OLD.SU_STA_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_STA_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_STA_Subject_State IS NULL THEN
        v_positing := :NEW.SU_STA_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_STA_Subject_State <> :OLD.SU_STA_Subject_State
        OR (:NEW.SU_STA_Subject_State IS NULL AND :OLD.SU_STA_Subject_State IS NOT NULL)
        OR (:NEW.SU_STA_Subject_State IS NOT NULL AND :OLD.SU_STA_Subject_State IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_STA <> :OLD.Metadata_SU_STA
        OR (:NEW.Metadata_SU_STA IS NULL AND :OLD.Metadata_SU_STA IS NOT NULL)
        OR (:NEW.Metadata_SU_STA IS NOT NULL AND :OLD.Metadata_SU_STA IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_STA
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_STA_changing := :NEW.SU_STA_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_STA_changing := :NEW.SU_STA_ChangedAt;
        ELSE
            v_STA_changing := v_now;
        END IF;
        IF :NEW.SU_STA_Subject_State IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_STA_Subject_State IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_STA_Reliability IS NULL
            OR :OLD.SU_STA_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_SU_STA_Subject_State(
                    p_owner => COALESCE(:NEW.SU_STA_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_STA_Subject_State,
                    p_changing => v_STA_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_STA_Subject_State IS NULL AND :OLD.SU_STA_Subject_State IS NOT NULL THEN
            ip_SU_STA_Subject_State(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_STA_Subject_State,
                p_changing => :OLD.SU_STA_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_LBL_Subject_Label
    IF (:NEW.SU_LBL_ID <> :OLD.SU_LBL_ID
        OR (:NEW.SU_LBL_ID IS NULL AND :OLD.SU_LBL_ID IS NOT NULL)
        OR (:NEW.SU_LBL_ID IS NOT NULL AND :OLD.SU_LBL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_LBL_ID is not updatable.');
    END IF;
    IF (:NEW.SU_LBL_SU_ID <> :OLD.SU_LBL_SU_ID
        OR (:NEW.SU_LBL_SU_ID IS NULL AND :OLD.SU_LBL_SU_ID IS NOT NULL)
        OR (:NEW.SU_LBL_SU_ID IS NOT NULL AND :OLD.SU_LBL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_LBL_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_LBL_Subject_Label, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_LBL_Reliability <> :OLD.SU_LBL_Reliability
        OR (:NEW.SU_LBL_Reliability IS NULL AND :OLD.SU_LBL_Reliability IS NOT NULL)
        OR (:NEW.SU_LBL_Reliability IS NOT NULL AND :OLD.SU_LBL_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_LBL_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_LBL_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_LBL_PositedAt <> :OLD.SU_LBL_PositedAt
        OR (:NEW.SU_LBL_PositedAt IS NULL AND :OLD.SU_LBL_PositedAt IS NOT NULL)
        OR (:NEW.SU_LBL_PositedAt IS NOT NULL AND :OLD.SU_LBL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_LBL_ChangedAt <> :OLD.SU_LBL_ChangedAt
        OR (:NEW.SU_LBL_ChangedAt IS NULL AND :OLD.SU_LBL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_LBL_ChangedAt IS NOT NULL AND :OLD.SU_LBL_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_LBL_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_LBL_Subject_Label IS NULL THEN
        v_positing := :NEW.SU_LBL_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_LBL_Subject_Label <> :OLD.SU_LBL_Subject_Label
        OR (:NEW.SU_LBL_Subject_Label IS NULL AND :OLD.SU_LBL_Subject_Label IS NOT NULL)
        OR (:NEW.SU_LBL_Subject_Label IS NOT NULL AND :OLD.SU_LBL_Subject_Label IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_LBL <> :OLD.Metadata_SU_LBL
        OR (:NEW.Metadata_SU_LBL IS NULL AND :OLD.Metadata_SU_LBL IS NOT NULL)
        OR (:NEW.Metadata_SU_LBL IS NOT NULL AND :OLD.Metadata_SU_LBL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_LBL
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_LBL_changing := :NEW.SU_LBL_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_LBL_changing := :NEW.SU_LBL_ChangedAt;
        ELSE
            v_LBL_changing := v_now;
        END IF;
        IF :NEW.SU_LBL_Subject_Label IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_LBL_Subject_Label IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_LBL_Reliability IS NULL
            OR :OLD.SU_LBL_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_SU_LBL_Subject_Label(
                    p_owner => COALESCE(:NEW.SU_LBL_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_LBL_Subject_Label,
                    p_changing => v_LBL_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_LBL_Subject_Label IS NULL AND :OLD.SU_LBL_Subject_Label IS NOT NULL THEN
            ip_SU_LBL_Subject_Label(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_LBL_Subject_Label,
                p_changing => :OLD.SU_LBL_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_TAG_Subject_Tag
    IF (:NEW.SU_TAG_ID <> :OLD.SU_TAG_ID
        OR (:NEW.SU_TAG_ID IS NULL AND :OLD.SU_TAG_ID IS NOT NULL)
        OR (:NEW.SU_TAG_ID IS NOT NULL AND :OLD.SU_TAG_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_TAG_ID is not updatable.');
    END IF;
    IF (:NEW.SU_TAG_SU_ID <> :OLD.SU_TAG_SU_ID
        OR (:NEW.SU_TAG_SU_ID IS NULL AND :OLD.SU_TAG_SU_ID IS NOT NULL)
        OR (:NEW.SU_TAG_SU_ID IS NOT NULL AND :OLD.SU_TAG_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TAG_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_TAG_Subject_Tag, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_TAG_Reliability <> :OLD.SU_TAG_Reliability
        OR (:NEW.SU_TAG_Reliability IS NULL AND :OLD.SU_TAG_Reliability IS NOT NULL)
        OR (:NEW.SU_TAG_Reliability IS NOT NULL AND :OLD.SU_TAG_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_TAG_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_TAG_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_TAG_PositedAt <> :OLD.SU_TAG_PositedAt
        OR (:NEW.SU_TAG_PositedAt IS NULL AND :OLD.SU_TAG_PositedAt IS NOT NULL)
        OR (:NEW.SU_TAG_PositedAt IS NOT NULL AND :OLD.SU_TAG_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_TAG_ChangedAt <> :OLD.SU_TAG_ChangedAt
        OR (:NEW.SU_TAG_ChangedAt IS NULL AND :OLD.SU_TAG_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TAG_ChangedAt IS NOT NULL AND :OLD.SU_TAG_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_TAG_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_TAG_Subject_Tag IS NULL THEN
        v_positing := :NEW.SU_TAG_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_TAG_Subject_Tag <> :OLD.SU_TAG_Subject_Tag
        OR (:NEW.SU_TAG_Subject_Tag IS NULL AND :OLD.SU_TAG_Subject_Tag IS NOT NULL)
        OR (:NEW.SU_TAG_Subject_Tag IS NOT NULL AND :OLD.SU_TAG_Subject_Tag IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_TAG <> :OLD.Metadata_SU_TAG
        OR (:NEW.Metadata_SU_TAG IS NULL AND :OLD.Metadata_SU_TAG IS NOT NULL)
        OR (:NEW.Metadata_SU_TAG IS NOT NULL AND :OLD.Metadata_SU_TAG IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_TAG
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_TAG_changing := :NEW.SU_TAG_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_TAG_changing := :NEW.SU_TAG_ChangedAt;
        ELSE
            v_TAG_changing := v_now;
        END IF;
        IF :NEW.SU_TAG_Subject_Tag IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_TAG_Subject_Tag IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_TAG_Reliability IS NULL
            OR :OLD.SU_TAG_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_SU_TAG_Subject_Tag(
                    p_owner => COALESCE(:NEW.SU_TAG_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_TAG_Subject_Tag,
                    p_changing => v_TAG_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_TAG_Subject_Tag IS NULL AND :OLD.SU_TAG_Subject_Tag IS NOT NULL THEN
            ip_SU_TAG_Subject_Tag(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_TAG_Subject_Tag,
                p_changing => :OLD.SU_TAG_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_LVL_Subject_Level
    IF (:NEW.SU_LVL_ID <> :OLD.SU_LVL_ID
        OR (:NEW.SU_LVL_ID IS NULL AND :OLD.SU_LVL_ID IS NOT NULL)
        OR (:NEW.SU_LVL_ID IS NOT NULL AND :OLD.SU_LVL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_LVL_ID is not updatable.');
    END IF;
    IF (:NEW.SU_LVL_SU_ID <> :OLD.SU_LVL_SU_ID
        OR (:NEW.SU_LVL_SU_ID IS NULL AND :OLD.SU_LVL_SU_ID IS NOT NULL)
        OR (:NEW.SU_LVL_SU_ID IS NOT NULL AND :OLD.SU_LVL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_LVL_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_LVL_Subject_Level, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_LVL_Reliability <> :OLD.SU_LVL_Reliability
        OR (:NEW.SU_LVL_Reliability IS NULL AND :OLD.SU_LVL_Reliability IS NOT NULL)
        OR (:NEW.SU_LVL_Reliability IS NOT NULL AND :OLD.SU_LVL_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_LVL_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_LVL_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_LVL_PositedAt <> :OLD.SU_LVL_PositedAt
        OR (:NEW.SU_LVL_PositedAt IS NULL AND :OLD.SU_LVL_PositedAt IS NOT NULL)
        OR (:NEW.SU_LVL_PositedAt IS NOT NULL AND :OLD.SU_LVL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_LVL_ChangedAt <> :OLD.SU_LVL_ChangedAt
        OR (:NEW.SU_LVL_ChangedAt IS NULL AND :OLD.SU_LVL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_LVL_ChangedAt IS NOT NULL AND :OLD.SU_LVL_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_LVL_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_LVL_GRD_ID IS NULL THEN
        v_positing := :NEW.SU_LVL_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_LVL_GRD_ID <> :OLD.SU_LVL_GRD_ID
        OR (:NEW.SU_LVL_GRD_ID IS NULL AND :OLD.SU_LVL_GRD_ID IS NOT NULL)
        OR (:NEW.SU_LVL_GRD_ID IS NOT NULL AND :OLD.SU_LVL_GRD_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_LVL <> :OLD.Metadata_SU_LVL
        OR (:NEW.Metadata_SU_LVL IS NULL AND :OLD.Metadata_SU_LVL IS NOT NULL)
        OR (:NEW.Metadata_SU_LVL IS NOT NULL AND :OLD.Metadata_SU_LVL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_LVL
        END, :NEW.Metadata_SU);
    v_knot_diff := CASE WHEN (:NEW.SU_LVL_GRD_Grade <> :OLD.SU_LVL_GRD_Grade
        OR (:NEW.SU_LVL_GRD_Grade IS NULL AND :OLD.SU_LVL_GRD_Grade IS NOT NULL)
        OR (:NEW.SU_LVL_GRD_Grade IS NOT NULL AND :OLD.SU_LVL_GRD_Grade IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_LVL := :NEW.SU_LVL_GRD_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_LVL := NULL;
        IF :NEW.SU_LVL_GRD_Grade IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GRD_ID
                FROM
                    GRD_Grade k
                WHERE
                    k.GRD_Grade = :NEW.SU_LVL_GRD_Grade
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_LVL := kv.GRD_ID;
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
            v_LVL_changing := :NEW.SU_LVL_ChangedAt;
        ELSIF :OLD.SU_LVL_GRD_ID = v_LVL THEN
            v_LVL_changing := :NEW.SU_LVL_ChangedAt;
        ELSE
            v_LVL_changing := v_now;
        END IF;
        IF v_LVL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_LVL_GRD_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_LVL_Reliability IS NULL
            OR :OLD.SU_LVL_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_LVL_GRD_ID <> v_LVL
            THEN
                ip_SU_LVL_Subject_Level(
                    p_owner => COALESCE(:NEW.SU_LVL_SU_ID, :NEW.SU_ID),
                    p_value => v_LVL,
                    p_changing => v_LVL_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.SU_LVL_GRD_ID IS NOT NULL AND (
            :NEW.SU_LVL_GRD_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.SU_LVL_GRD_Grade IS NULL AND :OLD.SU_LVL_GRD_Grade IS NOT NULL
            )
        ) THEN
            ip_SU_LVL_Subject_Level(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_LVL_GRD_ID,
                p_changing => :OLD.SU_LVL_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_TXT_Subject_Text
    IF (:NEW.SU_TXT_ID <> :OLD.SU_TXT_ID
        OR (:NEW.SU_TXT_ID IS NULL AND :OLD.SU_TXT_ID IS NOT NULL)
        OR (:NEW.SU_TXT_ID IS NOT NULL AND :OLD.SU_TXT_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_TXT_ID is not updatable.');
    END IF;
    IF (:NEW.SU_TXT_SU_ID <> :OLD.SU_TXT_SU_ID
        OR (:NEW.SU_TXT_SU_ID IS NULL AND :OLD.SU_TXT_SU_ID IS NOT NULL)
        OR (:NEW.SU_TXT_SU_ID IS NOT NULL AND :OLD.SU_TXT_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TXT_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_TXT_Subject_Text, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_TXT_Reliability <> :OLD.SU_TXT_Reliability
        OR (:NEW.SU_TXT_Reliability IS NULL AND :OLD.SU_TXT_Reliability IS NOT NULL)
        OR (:NEW.SU_TXT_Reliability IS NOT NULL AND :OLD.SU_TXT_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_TXT_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_TXT_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_TXT_PositedAt <> :OLD.SU_TXT_PositedAt
        OR (:NEW.SU_TXT_PositedAt IS NULL AND :OLD.SU_TXT_PositedAt IS NOT NULL)
        OR (:NEW.SU_TXT_PositedAt IS NOT NULL AND :OLD.SU_TXT_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_TXT_ChangedAt <> :OLD.SU_TXT_ChangedAt
        OR (:NEW.SU_TXT_ChangedAt IS NULL AND :OLD.SU_TXT_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TXT_ChangedAt IS NOT NULL AND :OLD.SU_TXT_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_TXT_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_TXT_Subject_Text IS NULL THEN
        v_positing := :NEW.SU_TXT_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN ((:NEW.SU_TXT_Subject_Text IS NULL AND :OLD.SU_TXT_Subject_Text IS NOT NULL)
        OR (:NEW.SU_TXT_Subject_Text IS NOT NULL AND :OLD.SU_TXT_Subject_Text IS NULL)
        OR (:NEW.SU_TXT_Subject_Text IS NOT NULL AND :OLD.SU_TXT_Subject_Text IS NOT NULL
            AND DBMS_LOB.COMPARE(:NEW.SU_TXT_Subject_Text, :OLD.SU_TXT_Subject_Text) <> 0)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_TXT <> :OLD.Metadata_SU_TXT
        OR (:NEW.Metadata_SU_TXT IS NULL AND :OLD.Metadata_SU_TXT IS NOT NULL)
        OR (:NEW.Metadata_SU_TXT IS NOT NULL AND :OLD.Metadata_SU_TXT IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_TXT
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_TXT_changing := :NEW.SU_TXT_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_TXT_changing := :NEW.SU_TXT_ChangedAt;
        ELSE
            v_TXT_changing := v_now;
        END IF;
        IF :NEW.SU_TXT_Subject_Text IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_TXT_Subject_Text IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_TXT_Reliability IS NULL
            OR :OLD.SU_TXT_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_SU_TXT_Subject_Text(
                    p_owner => COALESCE(:NEW.SU_TXT_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_TXT_Subject_Text,
                    p_changing => v_TXT_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_TXT_Subject_Text IS NULL AND :OLD.SU_TXT_Subject_Text IS NOT NULL THEN
            ip_SU_TXT_Subject_Text(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_TXT_Subject_Text,
                p_changing => :OLD.SU_TXT_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_ASR_Subject_Assessment
    IF (:NEW.SU_ASR_ID <> :OLD.SU_ASR_ID
        OR (:NEW.SU_ASR_ID IS NULL AND :OLD.SU_ASR_ID IS NOT NULL)
        OR (:NEW.SU_ASR_ID IS NOT NULL AND :OLD.SU_ASR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ASR_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ASR_SU_ID <> :OLD.SU_ASR_SU_ID
        OR (:NEW.SU_ASR_SU_ID IS NULL AND :OLD.SU_ASR_SU_ID IS NOT NULL)
        OR (:NEW.SU_ASR_SU_ID IS NOT NULL AND :OLD.SU_ASR_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_ASR_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_ASR_Subject_Assessment, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_ASR_Reliability <> :OLD.SU_ASR_Reliability
        OR (:NEW.SU_ASR_Reliability IS NULL AND :OLD.SU_ASR_Reliability IS NOT NULL)
        OR (:NEW.SU_ASR_Reliability IS NOT NULL AND :OLD.SU_ASR_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_ASR_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_ASR_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_ASR_PositedAt <> :OLD.SU_ASR_PositedAt
        OR (:NEW.SU_ASR_PositedAt IS NULL AND :OLD.SU_ASR_PositedAt IS NOT NULL)
        OR (:NEW.SU_ASR_PositedAt IS NOT NULL AND :OLD.SU_ASR_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_ASR_ChangedAt <> :OLD.SU_ASR_ChangedAt
        OR (:NEW.SU_ASR_ChangedAt IS NULL AND :OLD.SU_ASR_ChangedAt IS NOT NULL)
        OR (:NEW.SU_ASR_ChangedAt IS NOT NULL AND :OLD.SU_ASR_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_ASR_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_ASR_Subject_Assessment IS NULL THEN
        v_positing := :NEW.SU_ASR_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_ASR_Subject_Assessment <> :OLD.SU_ASR_Subject_Assessment
        OR (:NEW.SU_ASR_Subject_Assessment IS NULL AND :OLD.SU_ASR_Subject_Assessment IS NOT NULL)
        OR (:NEW.SU_ASR_Subject_Assessment IS NOT NULL AND :OLD.SU_ASR_Subject_Assessment IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_ASR <> :OLD.Metadata_SU_ASR
        OR (:NEW.Metadata_SU_ASR IS NULL AND :OLD.Metadata_SU_ASR IS NOT NULL)
        OR (:NEW.Metadata_SU_ASR IS NOT NULL AND :OLD.Metadata_SU_ASR IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_ASR
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_ASR_changing := :NEW.SU_ASR_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_ASR_changing := :NEW.SU_ASR_ChangedAt;
        ELSE
            v_ASR_changing := v_now;
        END IF;
        IF :NEW.SU_ASR_Subject_Assessment IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_ASR_Subject_Assessment IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_ASR_Reliability IS NULL
            OR :OLD.SU_ASR_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_SU_ASR_Subject_Assessment(
                    p_owner => COALESCE(:NEW.SU_ASR_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_ASR_Subject_Assessment,
                    p_changing => v_ASR_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_ASR_Subject_Assessment IS NULL AND :OLD.SU_ASR_Subject_Assessment IS NOT NULL THEN
            ip_SU_ASR_Subject_Assessment(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_ASR_Subject_Assessment,
                p_changing => :OLD.SU_ASR_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_ERS_Subject_Erasable
    IF (:NEW.SU_ERS_ID <> :OLD.SU_ERS_ID
        OR (:NEW.SU_ERS_ID IS NULL AND :OLD.SU_ERS_ID IS NOT NULL)
        OR (:NEW.SU_ERS_ID IS NOT NULL AND :OLD.SU_ERS_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ERS_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ERS_SU_ID <> :OLD.SU_ERS_SU_ID
        OR (:NEW.SU_ERS_SU_ID IS NULL AND :OLD.SU_ERS_SU_ID IS NOT NULL)
        OR (:NEW.SU_ERS_SU_ID IS NOT NULL AND :OLD.SU_ERS_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_ERS_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_ERS_Subject_Erasable, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_ERS_Reliability <> :OLD.SU_ERS_Reliability
        OR (:NEW.SU_ERS_Reliability IS NULL AND :OLD.SU_ERS_Reliability IS NOT NULL)
        OR (:NEW.SU_ERS_Reliability IS NOT NULL AND :OLD.SU_ERS_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_ERS_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_ERS_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_ERS_PositedAt <> :OLD.SU_ERS_PositedAt
        OR (:NEW.SU_ERS_PositedAt IS NULL AND :OLD.SU_ERS_PositedAt IS NOT NULL)
        OR (:NEW.SU_ERS_PositedAt IS NOT NULL AND :OLD.SU_ERS_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_ERS_ChangedAt <> :OLD.SU_ERS_ChangedAt
        OR (:NEW.SU_ERS_ChangedAt IS NULL AND :OLD.SU_ERS_ChangedAt IS NOT NULL)
        OR (:NEW.SU_ERS_ChangedAt IS NOT NULL AND :OLD.SU_ERS_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_ERS_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_ERS_Subject_Erasable IS NULL THEN
        v_positing := :NEW.SU_ERS_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_ERS_Subject_Erasable <> :OLD.SU_ERS_Subject_Erasable
        OR (:NEW.SU_ERS_Subject_Erasable IS NULL AND :OLD.SU_ERS_Subject_Erasable IS NOT NULL)
        OR (:NEW.SU_ERS_Subject_Erasable IS NOT NULL AND :OLD.SU_ERS_Subject_Erasable IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_ERS <> :OLD.Metadata_SU_ERS
        OR (:NEW.Metadata_SU_ERS IS NULL AND :OLD.Metadata_SU_ERS IS NOT NULL)
        OR (:NEW.Metadata_SU_ERS IS NOT NULL AND :OLD.Metadata_SU_ERS IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_ERS
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_ERS_changing := :NEW.SU_ERS_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_ERS_changing := :NEW.SU_ERS_ChangedAt;
        ELSE
            v_ERS_changing := v_now;
        END IF;
        IF :NEW.SU_ERS_Subject_Erasable IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_ERS_Subject_Erasable IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_ERS_Reliability IS NULL
            OR :OLD.SU_ERS_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_SU_ERS_Subject_Erasable(
                    p_owner => COALESCE(:NEW.SU_ERS_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_ERS_Subject_Erasable,
                    p_changing => v_ERS_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_ERS_Subject_Erasable IS NULL AND :OLD.SU_ERS_Subject_Erasable IS NOT NULL THEN
            ip_SU_ERS_Subject_Erasable(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_ERS_Subject_Erasable,
                p_changing => :OLD.SU_ERS_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lSU_Subject;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_Subject instead of DELETE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_Subject
INSTEAD OF DELETE ON lSU_Subject
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown of SU_NAM_Subject_Name is retracted
    INSERT INTO SU_NAM_Subject_Name_Annex (
        Metadata_SU_NAM,
        SU_NAM_ID,
        SU_NAM_PositedAt,
        SU_NAM_Reliability
    )
    SELECT
        :OLD.Metadata_SU_NAM,
        :OLD.SU_NAM_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_NAM_Subject_Name_Annex x
            WHERE
                x.SU_NAM_ID = :OLD.SU_NAM_ID
            AND
                x.SU_NAM_PositedAt = v_now
        );
    -- what is shown of SU_COD_Subject_Code is retracted
    INSERT INTO SU_COD_Subject_Code_Annex (
        Metadata_SU_COD,
        SU_COD_ID,
        SU_COD_PositedAt,
        SU_COD_Reliability
    )
    SELECT
        :OLD.Metadata_SU_COD,
        :OLD.SU_COD_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_COD_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_COD_Subject_Code_Annex x
            WHERE
                x.SU_COD_ID = :OLD.SU_COD_ID
            AND
                x.SU_COD_PositedAt = v_now
        );
    -- what is shown of SU_GRD_Subject_Grade is retracted
    INSERT INTO SU_GRD_Subject_Grade_Annex (
        Metadata_SU_GRD,
        SU_GRD_ID,
        SU_GRD_PositedAt,
        SU_GRD_Reliability
    )
    SELECT
        :OLD.Metadata_SU_GRD,
        :OLD.SU_GRD_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_GRD_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_GRD_Subject_Grade_Annex x
            WHERE
                x.SU_GRD_ID = :OLD.SU_GRD_ID
            AND
                x.SU_GRD_PositedAt = v_now
        );
    -- what is shown of SU_NOT_Subject_Note is retracted
    INSERT INTO SU_NOT_Subject_Note_Annex (
        Metadata_SU_NOT,
        SU_NOT_ID,
        SU_NOT_PositedAt,
        SU_NOT_Reliability
    )
    SELECT
        :OLD.Metadata_SU_NOT,
        :OLD.SU_NOT_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_NOT_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_NOT_Subject_Note_Annex x
            WHERE
                x.SU_NOT_ID = :OLD.SU_NOT_ID
            AND
                x.SU_NOT_PositedAt = v_now
        );
    -- what is shown of SU_TTL_Subject_Title is retracted
    INSERT INTO SU_TTL_Subject_Title_Annex (
        Metadata_SU_TTL,
        SU_TTL_ID,
        SU_TTL_PositedAt,
        SU_TTL_Reliability
    )
    SELECT
        :OLD.Metadata_SU_TTL,
        :OLD.SU_TTL_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_TTL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_TTL_Subject_Title_Annex x
            WHERE
                x.SU_TTL_ID = :OLD.SU_TTL_ID
            AND
                x.SU_TTL_PositedAt = v_now
        );
    -- what is shown of SU_STA_Subject_State is retracted
    INSERT INTO SU_STA_Subject_State_Annex (
        Metadata_SU_STA,
        SU_STA_ID,
        SU_STA_PositedAt,
        SU_STA_Reliability
    )
    SELECT
        :OLD.Metadata_SU_STA,
        :OLD.SU_STA_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_STA_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_STA_Subject_State_Annex x
            WHERE
                x.SU_STA_ID = :OLD.SU_STA_ID
            AND
                x.SU_STA_PositedAt = v_now
        );
    -- what is shown of SU_LBL_Subject_Label is retracted
    INSERT INTO SU_LBL_Subject_Label_Annex (
        Metadata_SU_LBL,
        SU_LBL_ID,
        SU_LBL_PositedAt,
        SU_LBL_Reliability
    )
    SELECT
        :OLD.Metadata_SU_LBL,
        :OLD.SU_LBL_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_LBL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_LBL_Subject_Label_Annex x
            WHERE
                x.SU_LBL_ID = :OLD.SU_LBL_ID
            AND
                x.SU_LBL_PositedAt = v_now
        );
    -- what is shown of SU_TAG_Subject_Tag is retracted
    INSERT INTO SU_TAG_Subject_Tag_Annex (
        Metadata_SU_TAG,
        SU_TAG_ID,
        SU_TAG_PositedAt,
        SU_TAG_Reliability
    )
    SELECT
        :OLD.Metadata_SU_TAG,
        :OLD.SU_TAG_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_TAG_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_TAG_Subject_Tag_Annex x
            WHERE
                x.SU_TAG_ID = :OLD.SU_TAG_ID
            AND
                x.SU_TAG_PositedAt = v_now
        );
    -- what is shown of SU_LVL_Subject_Level is retracted
    INSERT INTO SU_LVL_Subject_Level_Annex (
        Metadata_SU_LVL,
        SU_LVL_ID,
        SU_LVL_PositedAt,
        SU_LVL_Reliability
    )
    SELECT
        :OLD.Metadata_SU_LVL,
        :OLD.SU_LVL_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_LVL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_LVL_Subject_Level_Annex x
            WHERE
                x.SU_LVL_ID = :OLD.SU_LVL_ID
            AND
                x.SU_LVL_PositedAt = v_now
        );
    -- what is shown of SU_TXT_Subject_Text is retracted
    INSERT INTO SU_TXT_Subject_Text_Annex (
        Metadata_SU_TXT,
        SU_TXT_ID,
        SU_TXT_PositedAt,
        SU_TXT_Reliability
    )
    SELECT
        :OLD.Metadata_SU_TXT,
        :OLD.SU_TXT_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_TXT_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_TXT_Subject_Text_Annex x
            WHERE
                x.SU_TXT_ID = :OLD.SU_TXT_ID
            AND
                x.SU_TXT_PositedAt = v_now
        );
    -- what is shown of SU_ASR_Subject_Assessment is retracted
    INSERT INTO SU_ASR_Subject_Assessment_Annex (
        Metadata_SU_ASR,
        SU_ASR_ID,
        SU_ASR_PositedAt,
        SU_ASR_Reliability
    )
    SELECT
        :OLD.Metadata_SU_ASR,
        :OLD.SU_ASR_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_ASR_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_ASR_Subject_Assessment_Annex x
            WHERE
                x.SU_ASR_ID = :OLD.SU_ASR_ID
            AND
                x.SU_ASR_PositedAt = v_now
        );
    -- what is shown of SU_ERS_Subject_Erasable is retracted
    INSERT INTO SU_ERS_Subject_Erasable_Annex (
        Metadata_SU_ERS,
        SU_ERS_ID,
        SU_ERS_PositedAt,
        SU_ERS_Reliability
    )
    SELECT
        :OLD.Metadata_SU_ERS,
        :OLD.SU_ERS_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_ERS_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_ERS_Subject_Erasable_Annex x
            WHERE
                x.SU_ERS_ID = :OLD.SU_ERS_ID
            AND
                x.SU_ERS_PositedAt = v_now
        );
END dt_lSU_Subject;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_Object instead of INSERT trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lOB_Object
INSTEAD OF INSERT ON lOB_Object
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_id number(10);
BEGIN
    v_id := :NEW.OB_ID;
    IF v_id IS NULL THEN
        INSERT INTO OB_Object (
            Metadata_OB
        )
        VALUES (
            :NEW.Metadata_OB
        )
        RETURNING OB_ID INTO v_id;
    END IF;
    IF :NEW.OB_NAM_Object_Name IS NOT NULL THEN
        ip_OB_NAM_Object_Name(
            p_owner => COALESCE(:NEW.OB_NAM_OB_ID, v_id),
            p_value => :NEW.OB_NAM_Object_Name,
            p_positing => COALESCE(:NEW.OB_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.OB_NAM_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_OB_NAM, :NEW.Metadata_OB)
        );
    END IF;
END it_lOB_Object;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_Object instead of UPDATE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lOB_Object
INSTEAD OF UPDATE ON lOB_Object
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
BEGIN
    IF (:NEW.OB_ID <> :OLD.OB_ID
        OR (:NEW.OB_ID IS NULL AND :OLD.OB_ID IS NOT NULL)
        OR (:NEW.OB_ID IS NOT NULL AND :OLD.OB_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_OB <> :OLD.Metadata_OB
        OR (:NEW.Metadata_OB IS NULL AND :OLD.Metadata_OB IS NOT NULL)
        OR (:NEW.Metadata_OB IS NOT NULL AND :OLD.Metadata_OB IS NULL)) THEN TRUE ELSE FALSE END;
    -- OB_NAM_Object_Name
    IF (:NEW.OB_NAM_ID <> :OLD.OB_NAM_ID
        OR (:NEW.OB_NAM_ID IS NULL AND :OLD.OB_NAM_ID IS NOT NULL)
        OR (:NEW.OB_NAM_ID IS NOT NULL AND :OLD.OB_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.OB_NAM_OB_ID <> :OLD.OB_NAM_OB_ID
        OR (:NEW.OB_NAM_OB_ID IS NULL AND :OLD.OB_NAM_OB_ID IS NOT NULL)
        OR (:NEW.OB_NAM_OB_ID IS NOT NULL AND :OLD.OB_NAM_OB_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column OB_NAM_OB_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of OB_NAM_Object_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.OB_NAM_Reliability <> :OLD.OB_NAM_Reliability
        OR (:NEW.OB_NAM_Reliability IS NULL AND :OLD.OB_NAM_Reliability IS NOT NULL)
        OR (:NEW.OB_NAM_Reliability IS NOT NULL AND :OLD.OB_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.OB_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.OB_NAM_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.OB_NAM_PositedAt <> :OLD.OB_NAM_PositedAt
        OR (:NEW.OB_NAM_PositedAt IS NULL AND :OLD.OB_NAM_PositedAt IS NOT NULL)
        OR (:NEW.OB_NAM_PositedAt IS NOT NULL AND :OLD.OB_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.OB_NAM_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.OB_NAM_Object_Name <> :OLD.OB_NAM_Object_Name
        OR (:NEW.OB_NAM_Object_Name IS NULL AND :OLD.OB_NAM_Object_Name IS NOT NULL)
        OR (:NEW.OB_NAM_Object_Name IS NOT NULL AND :OLD.OB_NAM_Object_Name IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_OB_NAM <> :OLD.Metadata_OB_NAM
        OR (:NEW.Metadata_OB_NAM IS NULL AND :OLD.Metadata_OB_NAM IS NOT NULL)
        OR (:NEW.Metadata_OB_NAM IS NOT NULL AND :OLD.Metadata_OB_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_OB
            ELSE :NEW.Metadata_OB_NAM
        END, :NEW.Metadata_OB);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.OB_NAM_Object_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.OB_NAM_Object_Name IS NULL
            OR v_positing_diff
            OR :OLD.OB_NAM_Reliability IS NULL
            OR :OLD.OB_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_OB_NAM_Object_Name(
                    p_owner => COALESCE(:NEW.OB_NAM_OB_ID, :NEW.OB_ID),
                    p_value => :NEW.OB_NAM_Object_Name,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.OB_NAM_Object_Name IS NULL AND :OLD.OB_NAM_Object_Name IS NOT NULL THEN
            ip_OB_NAM_Object_Name(
                p_owner => :OLD.OB_ID,
                p_value => :OLD.OB_NAM_Object_Name,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lOB_Object;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_Object instead of DELETE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lOB_Object
INSTEAD OF DELETE ON lOB_Object
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown of OB_NAM_Object_Name is retracted
    INSERT INTO OB_NAM_Object_Name_Annex (
        Metadata_OB_NAM,
        OB_NAM_ID,
        OB_NAM_PositedAt,
        OB_NAM_Reliability
    )
    SELECT
        :OLD.Metadata_OB_NAM,
        :OLD.OB_NAM_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.OB_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                OB_NAM_Object_Name_Annex x
            WHERE
                x.OB_NAM_ID = :OLD.OB_NAM_ID
            AND
                x.OB_NAM_PositedAt = v_now
        );
END dt_lOB_Object;
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
            SU_ID_for,
            Metadata_EV
        )
        VALUES (
            :NEW.SU_ID_for,
            :NEW.Metadata_EV
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_QTY_Event_Quantity IS NOT NULL THEN
        ip_EV_QTY_Event_Quantity(
            p_owner => COALESCE(:NEW.EV_QTY_EV_ID, v_id),
            p_value => :NEW.EV_QTY_Event_Quantity,
            p_positing => COALESCE(:NEW.EV_QTY_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_QTY_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_QTY, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_PLC_Event_Place IS NOT NULL THEN
        ip_EV_PLC_Event_Place(
            p_owner => COALESCE(:NEW.EV_PLC_EV_ID, v_id),
            p_value => :NEW.EV_PLC_Event_Place,
            p_changing => COALESCE(:NEW.EV_PLC_ChangedAt, v_now),
            p_positing => COALESCE(:NEW.EV_PLC_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_PLC_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_PLC, :NEW.Metadata_EV)
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
    v_PLC_changing timestamp;
BEGIN
    IF (:NEW.EV_ID <> :OLD.EV_ID
        OR (:NEW.EV_ID IS NULL AND :OLD.EV_ID IS NOT NULL)
        OR (:NEW.EV_ID IS NOT NULL AND :OLD.EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ID_for <> :OLD.SU_ID_for
        OR (:NEW.SU_ID_for IS NULL AND :OLD.SU_ID_for IS NOT NULL)
        OR (:NEW.SU_ID_for IS NOT NULL AND :OLD.SU_ID_for IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column SU_ID_for is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    v_nexus_meta_diff := CASE WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
        OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
        OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL)) THEN TRUE ELSE FALSE END;
    -- EV_QTY_Event_Quantity
    IF (:NEW.EV_QTY_ID <> :OLD.EV_QTY_ID
        OR (:NEW.EV_QTY_ID IS NULL AND :OLD.EV_QTY_ID IS NOT NULL)
        OR (:NEW.EV_QTY_ID IS NOT NULL AND :OLD.EV_QTY_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_QTY_ID is not updatable.');
    END IF;
    IF (:NEW.EV_QTY_EV_ID <> :OLD.EV_QTY_EV_ID
        OR (:NEW.EV_QTY_EV_ID IS NULL AND :OLD.EV_QTY_EV_ID IS NOT NULL)
        OR (:NEW.EV_QTY_EV_ID IS NOT NULL AND :OLD.EV_QTY_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_QTY_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_QTY_Event_Quantity, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_QTY_Reliability <> :OLD.EV_QTY_Reliability
        OR (:NEW.EV_QTY_Reliability IS NULL AND :OLD.EV_QTY_Reliability IS NOT NULL)
        OR (:NEW.EV_QTY_Reliability IS NOT NULL AND :OLD.EV_QTY_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_QTY_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_QTY_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_QTY_PositedAt <> :OLD.EV_QTY_PositedAt
        OR (:NEW.EV_QTY_PositedAt IS NULL AND :OLD.EV_QTY_PositedAt IS NOT NULL)
        OR (:NEW.EV_QTY_PositedAt IS NOT NULL AND :OLD.EV_QTY_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_QTY_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_QTY_Event_Quantity <> :OLD.EV_QTY_Event_Quantity
        OR (:NEW.EV_QTY_Event_Quantity IS NULL AND :OLD.EV_QTY_Event_Quantity IS NOT NULL)
        OR (:NEW.EV_QTY_Event_Quantity IS NOT NULL AND :OLD.EV_QTY_Event_Quantity IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_QTY <> :OLD.Metadata_EV_QTY
        OR (:NEW.Metadata_EV_QTY IS NULL AND :OLD.Metadata_EV_QTY IS NOT NULL)
        OR (:NEW.Metadata_EV_QTY IS NOT NULL AND :OLD.Metadata_EV_QTY IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_QTY
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_QTY_Event_Quantity IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_QTY_Event_Quantity IS NULL
            OR v_positing_diff
            OR :OLD.EV_QTY_Reliability IS NULL
            OR :OLD.EV_QTY_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_EV_QTY_Event_Quantity(
                    p_owner => COALESCE(:NEW.EV_QTY_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_QTY_Event_Quantity,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null: the shown posit is retracted at the positing time
        IF :NEW.EV_QTY_Event_Quantity IS NULL AND :OLD.EV_QTY_Event_Quantity IS NOT NULL THEN
            FOR p IN (
                SELECT
                    x.EV_QTY_EV_ID,
                    x.EV_QTY_Event_Quantity
                FROM
                    EV_QTY_Event_Quantity_Posit x
                WHERE
                    x.EV_QTY_ID = :OLD.EV_QTY_ID
            ) LOOP
                ip_EV_QTY_Event_Quantity(
                    p_owner => p.EV_QTY_EV_ID,
                    p_value => p.EV_QTY_Event_Quantity,
                    p_positing => v_positing,
                    p_reliability => 0,
                    p_metadata => v_metadata
                );
            END LOOP;
        END IF;
    END IF;
    -- EV_PLC_Event_Place
    IF (:NEW.EV_PLC_ID <> :OLD.EV_PLC_ID
        OR (:NEW.EV_PLC_ID IS NULL AND :OLD.EV_PLC_ID IS NOT NULL)
        OR (:NEW.EV_PLC_ID IS NOT NULL AND :OLD.EV_PLC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_PLC_ID is not updatable.');
    END IF;
    IF (:NEW.EV_PLC_EV_ID <> :OLD.EV_PLC_EV_ID
        OR (:NEW.EV_PLC_EV_ID IS NULL AND :OLD.EV_PLC_EV_ID IS NOT NULL)
        OR (:NEW.EV_PLC_EV_ID IS NOT NULL AND :OLD.EV_PLC_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_PLC_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_PLC_Event_Place, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_PLC_Reliability <> :OLD.EV_PLC_Reliability
        OR (:NEW.EV_PLC_Reliability IS NULL AND :OLD.EV_PLC_Reliability IS NOT NULL)
        OR (:NEW.EV_PLC_Reliability IS NOT NULL AND :OLD.EV_PLC_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_PLC_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_PLC_Reliability;
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_PLC_PositedAt <> :OLD.EV_PLC_PositedAt
        OR (:NEW.EV_PLC_PositedAt IS NULL AND :OLD.EV_PLC_PositedAt IS NOT NULL)
        OR (:NEW.EV_PLC_PositedAt IS NOT NULL AND :OLD.EV_PLC_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.EV_PLC_ChangedAt <> :OLD.EV_PLC_ChangedAt
        OR (:NEW.EV_PLC_ChangedAt IS NULL AND :OLD.EV_PLC_ChangedAt IS NOT NULL)
        OR (:NEW.EV_PLC_ChangedAt IS NOT NULL AND :OLD.EV_PLC_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_PLC_PositedAt;
    ELSIF v_changing_diff AND :NEW.EV_PLC_Event_Place IS NULL THEN
        v_positing := :NEW.EV_PLC_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_PLC_Event_Place <> :OLD.EV_PLC_Event_Place
        OR (:NEW.EV_PLC_Event_Place IS NULL AND :OLD.EV_PLC_Event_Place IS NOT NULL)
        OR (:NEW.EV_PLC_Event_Place IS NOT NULL AND :OLD.EV_PLC_Event_Place IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_PLC <> :OLD.Metadata_EV_PLC
        OR (:NEW.Metadata_EV_PLC IS NULL AND :OLD.Metadata_EV_PLC IS NOT NULL)
        OR (:NEW.Metadata_EV_PLC IS NOT NULL AND :OLD.Metadata_EV_PLC IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_PLC
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_PLC_changing := :NEW.EV_PLC_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_PLC_changing := :NEW.EV_PLC_ChangedAt;
        ELSE
            v_PLC_changing := v_now;
        END IF;
        IF :NEW.EV_PLC_Event_Place IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_PLC_Event_Place IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.EV_PLC_Reliability IS NULL
            OR :OLD.EV_PLC_Reliability <> COALESCE(v_reliability, 1)
            OR v_value_diff
            THEN
                ip_EV_PLC_Event_Place(
                    p_owner => COALESCE(:NEW.EV_PLC_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_PLC_Event_Place,
                    p_changing => v_PLC_changing,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null: the shown posit is retracted at the positing time
        IF :NEW.EV_PLC_Event_Place IS NULL AND :OLD.EV_PLC_Event_Place IS NOT NULL THEN
            FOR p IN (
                SELECT
                    x.EV_PLC_EV_ID,
                    x.EV_PLC_Event_Place
                    , x.EV_PLC_ChangedAt
                FROM
                    EV_PLC_Event_Place_Posit x
                WHERE
                    x.EV_PLC_ID = :OLD.EV_PLC_ID
            ) LOOP
                ip_EV_PLC_Event_Place(
                    p_owner => p.EV_PLC_EV_ID,
                    p_value => p.EV_PLC_Event_Place,
                    p_changing => p.EV_PLC_ChangedAt,
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
    -- what is shown of EV_QTY_Event_Quantity is retracted
    INSERT INTO EV_QTY_Event_Quantity_Annex (
        Metadata_EV_QTY,
        EV_QTY_ID,
        EV_QTY_PositedAt,
        EV_QTY_Reliability
    )
    SELECT
        :OLD.Metadata_EV_QTY,
        :OLD.EV_QTY_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_QTY_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_QTY_Event_Quantity_Annex x
            WHERE
                x.EV_QTY_ID = :OLD.EV_QTY_ID
            AND
                x.EV_QTY_PositedAt = v_now
        );
    -- what is shown of EV_PLC_Event_Place is retracted
    INSERT INTO EV_PLC_Event_Place_Annex (
        Metadata_EV_PLC,
        EV_PLC_ID,
        EV_PLC_PositedAt,
        EV_PLC_Reliability
    )
    SELECT
        :OLD.Metadata_EV_PLC,
        :OLD.EV_PLC_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_PLC_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_PLC_Event_Place_Annex x
            WHERE
                x.EV_PLC_ID = :OLD.EV_PLC_ID
            AND
                x.EV_PLC_PositedAt = v_now
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
-- ie_SU_holder_OB_item_GRD_grade tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_SU_holder_OB_item_GRD_grade (
    p_id IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_ID%TYPE,
    p_positing IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_holder_OB_item_GRD_grade_Reliability
        FROM
            SU_holder_OB_item_GRD_grade_Annex a
        WHERE
            a.SU_holder_OB_item_GRD_grade_ID = p_id
        AND
            a.SU_holder_OB_item_GRD_grade_PositedAt <= p_positing
        ORDER BY
            a.SU_holder_OB_item_GRD_grade_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.SU_holder_OB_item_GRD_grade_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_SU_holder_OB_item_GRD_grade;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_holder_OB_item_GRD_grade states a posit of SU_holder_OB_item_GRD_grade, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_holder_OB_item_GRD_grade (
    p_SU_holder IN SU_holder_OB_item_GRD_grade_Posit.SU_ID_holder%TYPE,
    p_OB_item IN SU_holder_OB_item_GRD_grade_Posit.OB_ID_item%TYPE,
    p_GRD_grade IN SU_holder_OB_item_GRD_grade_Posit.GRD_ID_grade%TYPE,
    p_changing IN SU_holder_OB_item_GRD_grade_Posit.SU_holder_OB_item_GRD_grade_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_holder_OB_item_GRD_grade_Annex.Metadata_SU_holder_OB_item_GRD_grade%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_PositedAt%TYPE;
    v_reliability SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_Reliability%TYPE;
    v_changing SU_holder_OB_item_GRD_grade_Posit.SU_holder_OB_item_GRD_grade_ChangedAt%TYPE;
    v_posit SU_holder_OB_item_GRD_grade_Posit.SU_holder_OB_item_GRD_grade_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_holder_OB_item_GRD_grade_Annex (
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Reliability
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
                    SU_holder_OB_item_GRD_grade_Annex a
                WHERE
                    a.SU_holder_OB_item_GRD_grade_ID = p_id
                AND
                    a.SU_holder_OB_item_GRD_grade_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.SU_holder_OB_item_GRD_grade_ID
        FROM
            SU_holder_OB_item_GRD_grade_Posit p
        WHERE
            p.SU_ID_holder = p_SU_holder
        AND
            p.OB_ID_item = p_OB_item
        AND
            p.GRD_ID_grade = p_GRD_grade
        AND
            p.SU_holder_OB_item_GRD_grade_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_holder_OB_item_GRD_grade_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_holder_OB_item_GRD_grade_Annex a
                WHERE
                    a.SU_holder_OB_item_GRD_grade_ID = v_posit
                AND
                    a.SU_holder_OB_item_GRD_grade_PositedAt = v_positing
                AND
                    a.SU_holder_OB_item_GRD_grade_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_holder_OB_item_GRD_grade for: ' ||
                p_SU_holder || ', ' ||
                p_OB_item || ', ' ||
                p_GRD_grade || ', ' ||
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
                    SU_holder_OB_item_GRD_grade_Posit p
                JOIN
                    SU_holder_OB_item_GRD_grade_Annex a
                ON
                    a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
                WHERE
                    p.SU_ID_holder = p_SU_holder
                AND
                    p.OB_ID_item = p_OB_item
                AND
                    p.SU_holder_OB_item_GRD_grade_ChangedAt = v_changing
                AND
                    NOT (
                        p.GRD_ID_grade = p_GRD_grade
                    )
                AND
                    a.SU_holder_OB_item_GRD_grade_PositedAt = v_positing
                AND
                    a.SU_holder_OB_item_GRD_grade_Reliability = 1
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_holder_OB_item_GRD_grade for: ' ||
                p_SU_holder || ', ' ||
                p_OB_item || ', ' ||
                p_GRD_grade || ', ' ||
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
                    SU_holder_OB_item_GRD_grade_Annex a
                WHERE
                    a.SU_holder_OB_item_GRD_grade_ID = v_posit
                AND
                    a.SU_holder_OB_item_GRD_grade_PositedAt = v_positing
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
        IF ie_SU_holder_OB_item_GRD_grade(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_holder_OB_item_GRD_grade_Annex (
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Reliability
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
            p.SU_holder_OB_item_GRD_grade_ID
        FROM
            SU_holder_OB_item_GRD_grade_Posit p
        WHERE
            p.SU_ID_holder = p_SU_holder
        AND
            p.OB_ID_item = p_OB_item
        AND
            p.SU_holder_OB_item_GRD_grade_ChangedAt = v_changing
        AND
            NOT (
                p.GRD_ID_grade = p_GRD_grade
            )
        AND
            ie_SU_holder_OB_item_GRD_grade(p.SU_holder_OB_item_GRD_grade_ID, v_positing) = 1
    ) LOOP
        retract(r.SU_holder_OB_item_GRD_grade_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_holder_OB_item_GRD_grade_Posit (
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt
        )
        VALUES (
            p_SU_holder,
            p_OB_item,
            p_GRD_grade,
            v_changing
        )
        RETURNING SU_holder_OB_item_GRD_grade_ID INTO v_posit;
    END IF;
    INSERT INTO SU_holder_OB_item_GRD_grade_Annex (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_holder_OB_item_GRD_grade;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_holder_OB_item_GRD_grade instead of INSERT trigger on SU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_holder_OB_item_GRD_grade
INSTEAD OF INSERT ON SU_holder_OB_item_GRD_grade
FOR EACH ROW
BEGIN
    ip_SU_holder_OB_item_GRD_grade(
        p_SU_holder => :NEW.SU_ID_holder,
        p_OB_item => :NEW.OB_ID_item,
        p_GRD_grade => :NEW.GRD_ID_grade,
        p_changing => :NEW.SU_holder_OB_item_GRD_grade_ChangedAt,
        p_positing => :NEW.SU_holder_OB_item_GRD_grade_PositedAt,
        p_reliability => :NEW.SU_holder_OB_item_GRD_grade_Reliability,
        p_metadata => :NEW.Metadata_SU_holder_OB_item_GRD_grade
    );
END it_SU_holder_OB_item_GRD_grade;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_holder_OB_item_GRD_grade instead of INSERT trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_holder_OB_item_GRD_grade
INSTEAD OF INSERT ON lSU_holder_OB_item_GRD_grade
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_GRD_grade number(5);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_GRD_grade := :NEW.GRD_ID_grade;
    IF v_GRD_grade IS NULL AND :NEW.grade_GRD_Grade IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GRD_ID
            FROM
                GRD_Grade k
            WHERE
                k.GRD_Grade = :NEW.grade_GRD_Grade
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GRD_grade := kv.GRD_ID;
        END LOOP;
    END IF;
    ip_SU_holder_OB_item_GRD_grade(
        p_SU_holder => :NEW.SU_ID_holder,
        p_OB_item => :NEW.OB_ID_item,
        p_GRD_grade => v_GRD_grade,
        p_changing => COALESCE(:NEW.SU_holder_OB_item_GRD_grade_ChangedAt, v_now),
        p_positing => COALESCE(:NEW.SU_holder_OB_item_GRD_grade_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.SU_holder_OB_item_GRD_grade_Reliability, 1),
        p_metadata => :NEW.Metadata_SU_holder_OB_item_GRD_grade
    );
END it_lSU_holder_OB_item_GRD_grade;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_holder_OB_item_GRD_grade instead of UPDATE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lSU_holder_OB_item_GRD_grade
INSTEAD OF UPDATE ON lSU_holder_OB_item_GRD_grade
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_GRD_grade number(5);
BEGIN
    IF (:NEW.SU_ID_holder <> :OLD.SU_ID_holder
        OR (:NEW.SU_ID_holder IS NULL AND :OLD.SU_ID_holder IS NOT NULL)
        OR (:NEW.SU_ID_holder IS NOT NULL AND :OLD.SU_ID_holder IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ID_holder is not updatable.');
    END IF;
    IF (:NEW.OB_ID_item <> :OLD.OB_ID_item
        OR (:NEW.OB_ID_item IS NULL AND :OLD.OB_ID_item IS NOT NULL)
        OR (:NEW.OB_ID_item IS NOT NULL AND :OLD.OB_ID_item IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID_item is not updatable.');
    END IF;
    -- the identity of the knot value, given as it is or looked up from the value
    v_GRD_grade := :NEW.GRD_ID_grade;
    IF (:NEW.grade_GRD_Grade <> :OLD.grade_GRD_Grade
        OR (:NEW.grade_GRD_Grade IS NULL AND :OLD.grade_GRD_Grade IS NOT NULL)
        OR (:NEW.grade_GRD_Grade IS NOT NULL AND :OLD.grade_GRD_Grade IS NULL))
    AND (:NEW.GRD_ID_grade = :OLD.GRD_ID_grade
        OR (:NEW.GRD_ID_grade IS NULL AND :OLD.GRD_ID_grade IS NULL)) THEN
        v_GRD_grade := NULL;
        IF :NEW.grade_GRD_Grade IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GRD_ID
                FROM
                    GRD_Grade k
                WHERE
                    k.GRD_Grade = :NEW.grade_GRD_Grade
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GRD_grade := kv.GRD_ID;
            END LOOP;
        END IF;
    END IF;
    v_positing := CASE
        WHEN (:NEW.SU_holder_OB_item_GRD_grade_PositedAt <> :OLD.SU_holder_OB_item_GRD_grade_PositedAt
            OR (:NEW.SU_holder_OB_item_GRD_grade_PositedAt IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_PositedAt IS NOT NULL)
            OR (:NEW.SU_holder_OB_item_GRD_grade_PositedAt IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_PositedAt IS NULL))
        THEN :NEW.SU_holder_OB_item_GRD_grade_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.SU_ID_holder <> :OLD.SU_ID_holder
            OR (:NEW.SU_ID_holder IS NULL AND :OLD.SU_ID_holder IS NOT NULL)
            OR (:NEW.SU_ID_holder IS NOT NULL AND :OLD.SU_ID_holder IS NULL)) OR
        (:NEW.OB_ID_item <> :OLD.OB_ID_item
            OR (:NEW.OB_ID_item IS NULL AND :OLD.OB_ID_item IS NOT NULL)
            OR (:NEW.OB_ID_item IS NOT NULL AND :OLD.OB_ID_item IS NULL)) OR
        (v_GRD_grade <> :OLD.GRD_ID_grade
            OR (v_GRD_grade IS NULL AND :OLD.GRD_ID_grade IS NOT NULL)
            OR (v_GRD_grade IS NOT NULL AND :OLD.GRD_ID_grade IS NULL)) OR
        (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt <> :OLD.SU_holder_OB_item_GRD_grade_ChangedAt
            OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL)
            OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL)) OR
        (:NEW.SU_holder_OB_item_GRD_grade_PositedAt <> :OLD.SU_holder_OB_item_GRD_grade_PositedAt
            OR (:NEW.SU_holder_OB_item_GRD_grade_PositedAt IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_PositedAt IS NOT NULL)
            OR (:NEW.SU_holder_OB_item_GRD_grade_PositedAt IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_PositedAt IS NULL)) OR
        (:NEW.SU_holder_OB_item_GRD_grade_Reliability <> :OLD.SU_holder_OB_item_GRD_grade_Reliability
            OR (:NEW.SU_holder_OB_item_GRD_grade_Reliability IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_Reliability IS NOT NULL)
            OR (:NEW.SU_holder_OB_item_GRD_grade_Reliability IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_Reliability IS NULL))
    THEN
        IF
            :NEW.SU_ID_holder IS NOT NULL
        AND
            :NEW.OB_ID_item IS NOT NULL
        AND
            v_GRD_grade IS NOT NULL
        THEN
            ip_SU_holder_OB_item_GRD_grade(
                p_SU_holder => :NEW.SU_ID_holder,
                p_OB_item => :NEW.OB_ID_item,
                p_GRD_grade => v_GRD_grade,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt <> :OLD.SU_holder_OB_item_GRD_grade_ChangedAt
                        OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL))
                    THEN :NEW.SU_holder_OB_item_GRD_grade_ChangedAt
                    WHEN
                        :NEW.SU_ID_holder = :OLD.SU_ID_holder
                    AND
                        :NEW.OB_ID_item = :OLD.OB_ID_item
                    AND
                        v_GRD_grade = :OLD.GRD_ID_grade
                    THEN :NEW.SU_holder_OB_item_GRD_grade_ChangedAt
                    ELSE v_now
                END,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.SU_holder_OB_item_GRD_grade_Reliability, 1),
                p_metadata => :NEW.Metadata_SU_holder_OB_item_GRD_grade
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_SU_holder_OB_item_GRD_grade(
                p_SU_holder => :OLD.SU_ID_holder,
                p_OB_item => :OLD.OB_ID_item,
                p_GRD_grade => :OLD.GRD_ID_grade,
                p_changing => :OLD.SU_holder_OB_item_GRD_grade_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_SU_holder_OB_item_GRD_grade
            );
        END IF;
    END IF;
END ut_lSU_holder_OB_item_GRD_grade;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_holder_OB_item_GRD_grade instead of DELETE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_holder_OB_item_GRD_grade
INSTEAD OF DELETE ON lSU_holder_OB_item_GRD_grade
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO SU_holder_OB_item_GRD_grade_Annex (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        :OLD.Metadata_SU_holder_OB_item_GRD_grade,
        :OLD.SU_holder_OB_item_GRD_grade_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_holder_OB_item_GRD_grade_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_holder_OB_item_GRD_grade_Annex x
            WHERE
                x.SU_holder_OB_item_GRD_grade_ID = :OLD.SU_holder_OB_item_GRD_grade_ID
            AND
                x.SU_holder_OB_item_GRD_grade_PositedAt = v_now
        );
END dt_lSU_holder_OB_item_GRD_grade;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_keeper_OB_thing_GRD_rank tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_SU_keeper_OB_thing_GRD_rank (
    p_id IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_ID%TYPE,
    p_positing IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_keeper_OB_thing_GRD_rank_Reliability
        FROM
            SU_keeper_OB_thing_GRD_rank_Annex a
        WHERE
            a.SU_keeper_OB_thing_GRD_rank_ID = p_id
        AND
            a.SU_keeper_OB_thing_GRD_rank_PositedAt <= p_positing
        ORDER BY
            a.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.SU_keeper_OB_thing_GRD_rank_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_SU_keeper_OB_thing_GRD_rank;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_keeper_OB_thing_GRD_rank states a posit of SU_keeper_OB_thing_GRD_rank, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_keeper_OB_thing_GRD_rank (
    p_SU_keeper IN SU_keeper_OB_thing_GRD_rank_Posit.SU_ID_keeper%TYPE,
    p_OB_thing IN SU_keeper_OB_thing_GRD_rank_Posit.OB_ID_thing%TYPE,
    p_GRD_rank IN SU_keeper_OB_thing_GRD_rank_Posit.GRD_ID_rank%TYPE,
    p_changing IN SU_keeper_OB_thing_GRD_rank_Posit.SU_keeper_OB_thing_GRD_rank_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_keeper_OB_thing_GRD_rank_Annex.Metadata_SU_keeper_OB_thing_GRD_rank%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_PositedAt%TYPE;
    v_reliability SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_Reliability%TYPE;
    v_changing SU_keeper_OB_thing_GRD_rank_Posit.SU_keeper_OB_thing_GRD_rank_ChangedAt%TYPE;
    v_posit SU_keeper_OB_thing_GRD_rank_Posit.SU_keeper_OB_thing_GRD_rank_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_keeper_OB_thing_GRD_rank_Annex (
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
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
                    SU_keeper_OB_thing_GRD_rank_Annex a
                WHERE
                    a.SU_keeper_OB_thing_GRD_rank_ID = p_id
                AND
                    a.SU_keeper_OB_thing_GRD_rank_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.SU_keeper_OB_thing_GRD_rank_ID
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit p
        WHERE
            p.SU_ID_keeper = p_SU_keeper
        AND
            p.OB_ID_thing = p_OB_thing
        AND
            p.GRD_ID_rank = p_GRD_rank
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_keeper_OB_thing_GRD_rank_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_keeper_OB_thing_GRD_rank_Annex a
                WHERE
                    a.SU_keeper_OB_thing_GRD_rank_ID = v_posit
                AND
                    a.SU_keeper_OB_thing_GRD_rank_PositedAt = v_positing
                AND
                    a.SU_keeper_OB_thing_GRD_rank_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_keeper_OB_thing_GRD_rank for: ' ||
                p_SU_keeper || ', ' ||
                p_OB_thing || ', ' ||
                p_GRD_rank || ', ' ||
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
                    SU_keeper_OB_thing_GRD_rank_Posit p
                JOIN
                    SU_keeper_OB_thing_GRD_rank_Annex a
                ON
                    a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
                WHERE
                    p.SU_ID_keeper = p_SU_keeper
                AND
                    p.OB_ID_thing = p_OB_thing
                AND
                    p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v_changing
                AND
                    NOT (
                        p.GRD_ID_rank = p_GRD_rank
                    )
                AND
                    a.SU_keeper_OB_thing_GRD_rank_PositedAt = v_positing
                AND
                    a.SU_keeper_OB_thing_GRD_rank_Reliability = 1
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_keeper_OB_thing_GRD_rank for: ' ||
                p_SU_keeper || ', ' ||
                p_OB_thing || ', ' ||
                p_GRD_rank || ', ' ||
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
                    SU_keeper_OB_thing_GRD_rank_Annex a
                WHERE
                    a.SU_keeper_OB_thing_GRD_rank_ID = v_posit
                AND
                    a.SU_keeper_OB_thing_GRD_rank_PositedAt = v_positing
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
        IF ie_SU_keeper_OB_thing_GRD_rank(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_keeper_OB_thing_GRD_rank_Annex (
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion that is asserted already is skipped unless the tie is assertive
    IF v_posit IS NOT NULL THEN
        IF ie_SU_keeper_OB_thing_GRD_rank(v_posit, v_positing) = 1 THEN
            RETURN;
        END IF;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same identifiers (and changing time), when that has
    -- other values: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.SU_keeper_OB_thing_GRD_rank_ID
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit p
        WHERE
            p.SU_ID_keeper = p_SU_keeper
        AND
            p.OB_ID_thing = p_OB_thing
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v_changing
        AND
            NOT (
                p.GRD_ID_rank = p_GRD_rank
            )
        AND
            ie_SU_keeper_OB_thing_GRD_rank(p.SU_keeper_OB_thing_GRD_rank_ID, v_positing) = 1
    ) LOOP
        retract(r.SU_keeper_OB_thing_GRD_rank_ID);
    END LOOP;
    -- the same values as the version before it, which is asserted at the positing time, is a restatement
    -- (an idempotent tie does not store it, and retracts the version after it that the new values make a restatement of)
    FOR r IN (
        SELECT
            p.SU_ID_keeper,
            p.OB_ID_thing,
            p.GRD_ID_rank
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit p
        WHERE
            p.SU_ID_keeper = p_SU_keeper
        AND
            p.OB_ID_thing = p_OB_thing
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt < v_changing
        AND
            ie_SU_keeper_OB_thing_GRD_rank(p.SU_keeper_OB_thing_GRD_rank_ID, v_positing) = 1
        ORDER BY
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF
            r.SU_ID_keeper = p_SU_keeper
        AND
            r.OB_ID_thing = p_OB_thing
        AND
            r.GRD_ID_rank = p_GRD_rank
        THEN
            RETURN;
        END IF;
    END LOOP;
    -- the same values as the version after it make that version a restatement
    FOR r IN (
        SELECT
            f.SU_keeper_OB_thing_GRD_rank_ID,
            f.SU_ID_keeper,
            f.OB_ID_thing,
            f.GRD_ID_rank
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit f
        WHERE
            f.SU_ID_keeper = p_SU_keeper
        AND
            f.OB_ID_thing = p_OB_thing
        AND
            f.SU_keeper_OB_thing_GRD_rank_ChangedAt > v_changing
        AND
            ie_SU_keeper_OB_thing_GRD_rank(f.SU_keeper_OB_thing_GRD_rank_ID, v_positing) = 1
        ORDER BY
            f.SU_keeper_OB_thing_GRD_rank_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF
            r.SU_ID_keeper = p_SU_keeper
        AND
            r.OB_ID_thing = p_OB_thing
        AND
            r.GRD_ID_rank = p_GRD_rank
        THEN
            -- (an idempotent tie retracts it)
            retract(r.SU_keeper_OB_thing_GRD_rank_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_keeper_OB_thing_GRD_rank_Posit (
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank,
            SU_keeper_OB_thing_GRD_rank_ChangedAt
        )
        VALUES (
            p_SU_keeper,
            p_OB_thing,
            p_GRD_rank,
            v_changing
        )
        RETURNING SU_keeper_OB_thing_GRD_rank_ID INTO v_posit;
    END IF;
    INSERT INTO SU_keeper_OB_thing_GRD_rank_Annex (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_keeper_OB_thing_GRD_rank;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_keeper_OB_thing_GRD_rank instead of INSERT trigger on SU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_keeper_OB_thing_GRD_rank
INSTEAD OF INSERT ON SU_keeper_OB_thing_GRD_rank
FOR EACH ROW
BEGIN
    ip_SU_keeper_OB_thing_GRD_rank(
        p_SU_keeper => :NEW.SU_ID_keeper,
        p_OB_thing => :NEW.OB_ID_thing,
        p_GRD_rank => :NEW.GRD_ID_rank,
        p_changing => :NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        p_positing => :NEW.SU_keeper_OB_thing_GRD_rank_PositedAt,
        p_reliability => :NEW.SU_keeper_OB_thing_GRD_rank_Reliability,
        p_metadata => :NEW.Metadata_SU_keeper_OB_thing_GRD_rank
    );
END it_SU_keeper_OB_thing_GRD_rank;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_keeper_OB_thing_GRD_rank
INSTEAD OF INSERT ON lSU_keeper_OB_thing_GRD_rank
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_GRD_rank number(5);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_GRD_rank := :NEW.GRD_ID_rank;
    IF v_GRD_rank IS NULL AND :NEW.rank_GRD_Grade IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GRD_ID
            FROM
                GRD_Grade k
            WHERE
                k.GRD_Grade = :NEW.rank_GRD_Grade
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GRD_rank := kv.GRD_ID;
        END LOOP;
    END IF;
    ip_SU_keeper_OB_thing_GRD_rank(
        p_SU_keeper => :NEW.SU_ID_keeper,
        p_OB_thing => :NEW.OB_ID_thing,
        p_GRD_rank => v_GRD_rank,
        p_changing => COALESCE(:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt, v_now),
        p_positing => COALESCE(:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.SU_keeper_OB_thing_GRD_rank_Reliability, 1),
        p_metadata => :NEW.Metadata_SU_keeper_OB_thing_GRD_rank
    );
END it_lSU_keeper_OB_thing_GRD_rank;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_keeper_OB_thing_GRD_rank instead of UPDATE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lSU_keeper_OB_thing_GRD_rank
INSTEAD OF UPDATE ON lSU_keeper_OB_thing_GRD_rank
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_GRD_rank number(5);
BEGIN
    IF (:NEW.SU_ID_keeper <> :OLD.SU_ID_keeper
        OR (:NEW.SU_ID_keeper IS NULL AND :OLD.SU_ID_keeper IS NOT NULL)
        OR (:NEW.SU_ID_keeper IS NOT NULL AND :OLD.SU_ID_keeper IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ID_keeper is not updatable.');
    END IF;
    IF (:NEW.OB_ID_thing <> :OLD.OB_ID_thing
        OR (:NEW.OB_ID_thing IS NULL AND :OLD.OB_ID_thing IS NOT NULL)
        OR (:NEW.OB_ID_thing IS NOT NULL AND :OLD.OB_ID_thing IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID_thing is not updatable.');
    END IF;
    -- the identity of the knot value, given as it is or looked up from the value
    v_GRD_rank := :NEW.GRD_ID_rank;
    IF (:NEW.rank_GRD_Grade <> :OLD.rank_GRD_Grade
        OR (:NEW.rank_GRD_Grade IS NULL AND :OLD.rank_GRD_Grade IS NOT NULL)
        OR (:NEW.rank_GRD_Grade IS NOT NULL AND :OLD.rank_GRD_Grade IS NULL))
    AND (:NEW.GRD_ID_rank = :OLD.GRD_ID_rank
        OR (:NEW.GRD_ID_rank IS NULL AND :OLD.GRD_ID_rank IS NULL)) THEN
        v_GRD_rank := NULL;
        IF :NEW.rank_GRD_Grade IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GRD_ID
                FROM
                    GRD_Grade k
                WHERE
                    k.GRD_Grade = :NEW.rank_GRD_Grade
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GRD_rank := kv.GRD_ID;
            END LOOP;
        END IF;
    END IF;
    v_positing := CASE
        WHEN (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt <> :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt IS NOT NULL)
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt IS NULL))
        THEN :NEW.SU_keeper_OB_thing_GRD_rank_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.SU_ID_keeper <> :OLD.SU_ID_keeper
            OR (:NEW.SU_ID_keeper IS NULL AND :OLD.SU_ID_keeper IS NOT NULL)
            OR (:NEW.SU_ID_keeper IS NOT NULL AND :OLD.SU_ID_keeper IS NULL)) OR
        (:NEW.OB_ID_thing <> :OLD.OB_ID_thing
            OR (:NEW.OB_ID_thing IS NULL AND :OLD.OB_ID_thing IS NOT NULL)
            OR (:NEW.OB_ID_thing IS NOT NULL AND :OLD.OB_ID_thing IS NULL)) OR
        (v_GRD_rank <> :OLD.GRD_ID_rank
            OR (v_GRD_rank IS NULL AND :OLD.GRD_ID_rank IS NOT NULL)
            OR (v_GRD_rank IS NOT NULL AND :OLD.GRD_ID_rank IS NULL)) OR
        (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt <> :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL)
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL)) OR
        (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt <> :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt IS NOT NULL)
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt IS NULL)) OR
        (:NEW.SU_keeper_OB_thing_GRD_rank_Reliability <> :OLD.SU_keeper_OB_thing_GRD_rank_Reliability
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_Reliability IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_Reliability IS NOT NULL)
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_Reliability IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_Reliability IS NULL))
    THEN
        IF
            :NEW.SU_ID_keeper IS NOT NULL
        AND
            :NEW.OB_ID_thing IS NOT NULL
        AND
            v_GRD_rank IS NOT NULL
        THEN
            ip_SU_keeper_OB_thing_GRD_rank(
                p_SU_keeper => :NEW.SU_ID_keeper,
                p_OB_thing => :NEW.OB_ID_thing,
                p_GRD_rank => v_GRD_rank,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt <> :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt
                        OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL))
                    THEN :NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt
                    WHEN
                        :NEW.SU_ID_keeper = :OLD.SU_ID_keeper
                    AND
                        :NEW.OB_ID_thing = :OLD.OB_ID_thing
                    AND
                        v_GRD_rank = :OLD.GRD_ID_rank
                    THEN :NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt
                    ELSE v_now
                END,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.SU_keeper_OB_thing_GRD_rank_Reliability, 1),
                p_metadata => :NEW.Metadata_SU_keeper_OB_thing_GRD_rank
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_SU_keeper_OB_thing_GRD_rank(
                p_SU_keeper => :OLD.SU_ID_keeper,
                p_OB_thing => :OLD.OB_ID_thing,
                p_GRD_rank => :OLD.GRD_ID_rank,
                p_changing => :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_SU_keeper_OB_thing_GRD_rank
            );
        END IF;
    END IF;
END ut_lSU_keeper_OB_thing_GRD_rank;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_keeper_OB_thing_GRD_rank instead of DELETE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_keeper_OB_thing_GRD_rank
INSTEAD OF DELETE ON lSU_keeper_OB_thing_GRD_rank
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO SU_keeper_OB_thing_GRD_rank_Annex (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        :OLD.Metadata_SU_keeper_OB_thing_GRD_rank,
        :OLD.SU_keeper_OB_thing_GRD_rank_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_keeper_OB_thing_GRD_rank_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_keeper_OB_thing_GRD_rank_Annex x
            WHERE
                x.SU_keeper_OB_thing_GRD_rank_ID = :OLD.SU_keeper_OB_thing_GRD_rank_ID
            AND
                x.SU_keeper_OB_thing_GRD_rank_PositedAt = v_now
        );
END dt_lSU_keeper_OB_thing_GRD_rank;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_OB_part_SU_owner tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_OB_part_SU_owner (
    p_id IN OB_part_SU_owner_Annex.OB_part_SU_owner_ID%TYPE,
    p_positing IN OB_part_SU_owner_Annex.OB_part_SU_owner_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.OB_part_SU_owner_Reliability
        FROM
            OB_part_SU_owner_Annex a
        WHERE
            a.OB_part_SU_owner_ID = p_id
        AND
            a.OB_part_SU_owner_PositedAt <= p_positing
        ORDER BY
            a.OB_part_SU_owner_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.OB_part_SU_owner_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_OB_part_SU_owner;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_OB_part_SU_owner states a posit of OB_part_SU_owner, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_OB_part_SU_owner (
    p_OB_part IN OB_part_SU_owner_Posit.OB_ID_part%TYPE,
    p_SU_owner IN OB_part_SU_owner_Posit.SU_ID_owner%TYPE,
    p_positing IN OB_part_SU_owner_Annex.OB_part_SU_owner_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN OB_part_SU_owner_Annex.OB_part_SU_owner_Reliability%TYPE DEFAULT NULL,
    p_metadata IN OB_part_SU_owner_Annex.Metadata_OB_part_SU_owner%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing OB_part_SU_owner_Annex.OB_part_SU_owner_PositedAt%TYPE;
    v_reliability OB_part_SU_owner_Annex.OB_part_SU_owner_Reliability%TYPE;
    v_posit OB_part_SU_owner_Posit.OB_part_SU_owner_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN OB_part_SU_owner_Annex.OB_part_SU_owner_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO OB_part_SU_owner_Annex (
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Reliability
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
                    OB_part_SU_owner_Annex a
                WHERE
                    a.OB_part_SU_owner_ID = p_id
                AND
                    a.OB_part_SU_owner_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.OB_part_SU_owner_ID
        FROM
            OB_part_SU_owner_Posit p
        WHERE
            p.OB_ID_part = p_OB_part
        AND
            p.SU_ID_owner = p_SU_owner
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.OB_part_SU_owner_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    OB_part_SU_owner_Annex a
                WHERE
                    a.OB_part_SU_owner_ID = v_posit
                AND
                    a.OB_part_SU_owner_PositedAt = v_positing
                AND
                    a.OB_part_SU_owner_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_part_SU_owner for: ' ||
                p_OB_part || ', ' ||
                p_SU_owner || ', ' ||
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
                    OB_part_SU_owner_Posit p
                JOIN
                    OB_part_SU_owner_Annex a
                ON
                    a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
                WHERE
                    p.OB_ID_part = p_OB_part
                AND
                    NOT (
                        p.SU_ID_owner = p_SU_owner
                    )
                AND
                    a.OB_part_SU_owner_PositedAt = v_positing
                AND
                    a.OB_part_SU_owner_Reliability = 1
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_part_SU_owner for: ' ||
                p_OB_part || ', ' ||
                p_SU_owner || ', ' ||
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
                    OB_part_SU_owner_Annex a
                WHERE
                    a.OB_part_SU_owner_ID = v_posit
                AND
                    a.OB_part_SU_owner_PositedAt = v_positing
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
        IF ie_OB_part_SU_owner(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO OB_part_SU_owner_Annex (
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Reliability
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
            p.OB_part_SU_owner_ID
        FROM
            OB_part_SU_owner_Posit p
        WHERE
            p.OB_ID_part = p_OB_part
        AND
            NOT (
                p.SU_ID_owner = p_SU_owner
            )
        AND
            ie_OB_part_SU_owner(p.OB_part_SU_owner_ID, v_positing) = 1
    ) LOOP
        retract(r.OB_part_SU_owner_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO OB_part_SU_owner_Posit (
            OB_ID_part,
            SU_ID_owner
        )
        VALUES (
            p_OB_part,
            p_SU_owner
        )
        RETURNING OB_part_SU_owner_ID INTO v_posit;
    END IF;
    INSERT INTO OB_part_SU_owner_Annex (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_OB_part_SU_owner;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_part_SU_owner instead of INSERT trigger on OB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_OB_part_SU_owner
INSTEAD OF INSERT ON OB_part_SU_owner
FOR EACH ROW
BEGIN
    ip_OB_part_SU_owner(
        p_OB_part => :NEW.OB_ID_part,
        p_SU_owner => :NEW.SU_ID_owner,
        p_positing => :NEW.OB_part_SU_owner_PositedAt,
        p_reliability => :NEW.OB_part_SU_owner_Reliability,
        p_metadata => :NEW.Metadata_OB_part_SU_owner
    );
END it_OB_part_SU_owner;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_part_SU_owner instead of INSERT trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lOB_part_SU_owner
INSTEAD OF INSERT ON lOB_part_SU_owner
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    ip_OB_part_SU_owner(
        p_OB_part => :NEW.OB_ID_part,
        p_SU_owner => :NEW.SU_ID_owner,
        p_positing => COALESCE(:NEW.OB_part_SU_owner_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.OB_part_SU_owner_Reliability, 1),
        p_metadata => :NEW.Metadata_OB_part_SU_owner
    );
END it_lOB_part_SU_owner;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_part_SU_owner instead of UPDATE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lOB_part_SU_owner
INSTEAD OF UPDATE ON lOB_part_SU_owner
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
BEGIN
    IF (:NEW.OB_ID_part <> :OLD.OB_ID_part
        OR (:NEW.OB_ID_part IS NULL AND :OLD.OB_ID_part IS NOT NULL)
        OR (:NEW.OB_ID_part IS NOT NULL AND :OLD.OB_ID_part IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID_part is not updatable.');
    END IF;
    v_positing := CASE
        WHEN (:NEW.OB_part_SU_owner_PositedAt <> :OLD.OB_part_SU_owner_PositedAt
            OR (:NEW.OB_part_SU_owner_PositedAt IS NULL AND :OLD.OB_part_SU_owner_PositedAt IS NOT NULL)
            OR (:NEW.OB_part_SU_owner_PositedAt IS NOT NULL AND :OLD.OB_part_SU_owner_PositedAt IS NULL))
        THEN :NEW.OB_part_SU_owner_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.OB_ID_part <> :OLD.OB_ID_part
            OR (:NEW.OB_ID_part IS NULL AND :OLD.OB_ID_part IS NOT NULL)
            OR (:NEW.OB_ID_part IS NOT NULL AND :OLD.OB_ID_part IS NULL)) OR
        (:NEW.SU_ID_owner <> :OLD.SU_ID_owner
            OR (:NEW.SU_ID_owner IS NULL AND :OLD.SU_ID_owner IS NOT NULL)
            OR (:NEW.SU_ID_owner IS NOT NULL AND :OLD.SU_ID_owner IS NULL)) OR
        (:NEW.OB_part_SU_owner_PositedAt <> :OLD.OB_part_SU_owner_PositedAt
            OR (:NEW.OB_part_SU_owner_PositedAt IS NULL AND :OLD.OB_part_SU_owner_PositedAt IS NOT NULL)
            OR (:NEW.OB_part_SU_owner_PositedAt IS NOT NULL AND :OLD.OB_part_SU_owner_PositedAt IS NULL)) OR
        (:NEW.OB_part_SU_owner_Reliability <> :OLD.OB_part_SU_owner_Reliability
            OR (:NEW.OB_part_SU_owner_Reliability IS NULL AND :OLD.OB_part_SU_owner_Reliability IS NOT NULL)
            OR (:NEW.OB_part_SU_owner_Reliability IS NOT NULL AND :OLD.OB_part_SU_owner_Reliability IS NULL))
    THEN
        IF
            :NEW.OB_ID_part IS NOT NULL
        AND
            :NEW.SU_ID_owner IS NOT NULL
        THEN
            ip_OB_part_SU_owner(
                p_OB_part => :NEW.OB_ID_part,
                p_SU_owner => :NEW.SU_ID_owner,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.OB_part_SU_owner_Reliability, 1),
                p_metadata => :NEW.Metadata_OB_part_SU_owner
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_OB_part_SU_owner(
                p_OB_part => :OLD.OB_ID_part,
                p_SU_owner => :OLD.SU_ID_owner,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_OB_part_SU_owner
            );
        END IF;
    END IF;
END ut_lOB_part_SU_owner;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_part_SU_owner instead of DELETE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lOB_part_SU_owner
INSTEAD OF DELETE ON lOB_part_SU_owner
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO OB_part_SU_owner_Annex (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        :OLD.Metadata_OB_part_SU_owner,
        :OLD.OB_part_SU_owner_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.OB_part_SU_owner_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                OB_part_SU_owner_Annex x
            WHERE
                x.OB_part_SU_owner_ID = :OLD.OB_part_SU_owner_ID
            AND
                x.OB_part_SU_owner_PositedAt = v_now
        );
END dt_lOB_part_SU_owner;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_partner_SU_with tells (1 or 0) whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_SU_partner_SU_with (
    p_id IN SU_partner_SU_with_Annex.SU_partner_SU_with_ID%TYPE,
    p_positing IN SU_partner_SU_with_Annex.SU_partner_SU_with_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_partner_SU_with_Reliability
        FROM
            SU_partner_SU_with_Annex a
        WHERE
            a.SU_partner_SU_with_ID = p_id
        AND
            a.SU_partner_SU_with_PositedAt <= p_positing
        ORDER BY
            a.SU_partner_SU_with_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF r.SU_partner_SU_with_Reliability = 1 THEN
            RETURN 1;
        END IF;
    END LOOP;
    RETURN 0;
END ie_SU_partner_SU_with;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_partner_SU_with states a posit of SU_partner_SU_with, and its assertion or retraction
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_partner_SU_with (
    p_SU_partner IN SU_partner_SU_with_Posit.SU_ID_partner%TYPE,
    p_SU_with IN SU_partner_SU_with_Posit.SU_ID_with%TYPE,
    p_changing IN SU_partner_SU_with_Posit.SU_partner_SU_with_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN SU_partner_SU_with_Annex.SU_partner_SU_with_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_partner_SU_with_Annex.SU_partner_SU_with_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_partner_SU_with_Annex.Metadata_SU_partner_SU_with%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing SU_partner_SU_with_Annex.SU_partner_SU_with_PositedAt%TYPE;
    v_reliability SU_partner_SU_with_Annex.SU_partner_SU_with_Reliability%TYPE;
    v_changing SU_partner_SU_with_Posit.SU_partner_SU_with_ChangedAt%TYPE;
    v_posit SU_partner_SU_with_Posit.SU_partner_SU_with_ID%TYPE;
    v_exists NUMBER;
    -- retracts a posit at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN SU_partner_SU_with_Annex.SU_partner_SU_with_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_partner_SU_with_Annex (
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Reliability
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
                    SU_partner_SU_with_Annex a
                WHERE
                    a.SU_partner_SU_with_ID = p_id
                AND
                    a.SU_partner_SU_with_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.SU_partner_SU_with_ID
        FROM
            SU_partner_SU_with_Posit p
        WHERE
            p.SU_ID_partner = p_SU_partner
        AND
            p.SU_ID_with = p_SU_with
        AND
            p.SU_partner_SU_with_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_partner_SU_with_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_partner_SU_with_Annex a
                WHERE
                    a.SU_partner_SU_with_ID = v_posit
                AND
                    a.SU_partner_SU_with_PositedAt = v_positing
                AND
                    a.SU_partner_SU_with_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_partner_SU_with for: ' ||
                p_SU_partner || ', ' ||
                p_SU_with || ', ' ||
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
                    SU_partner_SU_with_Annex a
                WHERE
                    a.SU_partner_SU_with_ID = v_posit
                AND
                    a.SU_partner_SU_with_PositedAt = v_positing
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
        IF ie_SU_partner_SU_with(v_posit, v_positing) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_partner_SU_with_Annex (
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Reliability
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
        INSERT INTO SU_partner_SU_with_Posit (
            SU_ID_partner,
            SU_ID_with,
            SU_partner_SU_with_ChangedAt
        )
        VALUES (
            p_SU_partner,
            p_SU_with,
            v_changing
        )
        RETURNING SU_partner_SU_with_ID INTO v_posit;
    END IF;
    INSERT INTO SU_partner_SU_with_Annex (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_SU_partner_SU_with;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_partner_SU_with instead of INSERT trigger on SU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_partner_SU_with
INSTEAD OF INSERT ON SU_partner_SU_with
FOR EACH ROW
BEGIN
    ip_SU_partner_SU_with(
        p_SU_partner => :NEW.SU_ID_partner,
        p_SU_with => :NEW.SU_ID_with,
        p_changing => :NEW.SU_partner_SU_with_ChangedAt,
        p_positing => :NEW.SU_partner_SU_with_PositedAt,
        p_reliability => :NEW.SU_partner_SU_with_Reliability,
        p_metadata => :NEW.Metadata_SU_partner_SU_with
    );
END it_SU_partner_SU_with;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_partner_SU_with instead of INSERT trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_partner_SU_with
INSTEAD OF INSERT ON lSU_partner_SU_with
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    ip_SU_partner_SU_with(
        p_SU_partner => :NEW.SU_ID_partner,
        p_SU_with => :NEW.SU_ID_with,
        p_changing => COALESCE(:NEW.SU_partner_SU_with_ChangedAt, v_now),
        p_positing => COALESCE(:NEW.SU_partner_SU_with_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.SU_partner_SU_with_Reliability, 1),
        p_metadata => :NEW.Metadata_SU_partner_SU_with
    );
END it_lSU_partner_SU_with;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_partner_SU_with instead of UPDATE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lSU_partner_SU_with
INSTEAD OF UPDATE ON lSU_partner_SU_with
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
BEGIN
    v_positing := CASE
        WHEN (:NEW.SU_partner_SU_with_PositedAt <> :OLD.SU_partner_SU_with_PositedAt
            OR (:NEW.SU_partner_SU_with_PositedAt IS NULL AND :OLD.SU_partner_SU_with_PositedAt IS NOT NULL)
            OR (:NEW.SU_partner_SU_with_PositedAt IS NOT NULL AND :OLD.SU_partner_SU_with_PositedAt IS NULL))
        THEN :NEW.SU_partner_SU_with_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.SU_ID_partner <> :OLD.SU_ID_partner
            OR (:NEW.SU_ID_partner IS NULL AND :OLD.SU_ID_partner IS NOT NULL)
            OR (:NEW.SU_ID_partner IS NOT NULL AND :OLD.SU_ID_partner IS NULL)) OR
        (:NEW.SU_ID_with <> :OLD.SU_ID_with
            OR (:NEW.SU_ID_with IS NULL AND :OLD.SU_ID_with IS NOT NULL)
            OR (:NEW.SU_ID_with IS NOT NULL AND :OLD.SU_ID_with IS NULL)) OR
        (:NEW.SU_partner_SU_with_ChangedAt <> :OLD.SU_partner_SU_with_ChangedAt
            OR (:NEW.SU_partner_SU_with_ChangedAt IS NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NOT NULL)
            OR (:NEW.SU_partner_SU_with_ChangedAt IS NOT NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NULL)) OR
        (:NEW.SU_partner_SU_with_PositedAt <> :OLD.SU_partner_SU_with_PositedAt
            OR (:NEW.SU_partner_SU_with_PositedAt IS NULL AND :OLD.SU_partner_SU_with_PositedAt IS NOT NULL)
            OR (:NEW.SU_partner_SU_with_PositedAt IS NOT NULL AND :OLD.SU_partner_SU_with_PositedAt IS NULL)) OR
        (:NEW.SU_partner_SU_with_Reliability <> :OLD.SU_partner_SU_with_Reliability
            OR (:NEW.SU_partner_SU_with_Reliability IS NULL AND :OLD.SU_partner_SU_with_Reliability IS NOT NULL)
            OR (:NEW.SU_partner_SU_with_Reliability IS NOT NULL AND :OLD.SU_partner_SU_with_Reliability IS NULL))
    THEN
        IF
            :NEW.SU_ID_partner IS NOT NULL
        AND
            :NEW.SU_ID_with IS NOT NULL
        THEN
            ip_SU_partner_SU_with(
                p_SU_partner => :NEW.SU_ID_partner,
                p_SU_with => :NEW.SU_ID_with,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.SU_partner_SU_with_ChangedAt <> :OLD.SU_partner_SU_with_ChangedAt
                        OR (:NEW.SU_partner_SU_with_ChangedAt IS NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_partner_SU_with_ChangedAt IS NOT NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NULL))
                    THEN :NEW.SU_partner_SU_with_ChangedAt
                    WHEN
                        :NEW.SU_ID_partner = :OLD.SU_ID_partner
                    AND
                        :NEW.SU_ID_with = :OLD.SU_ID_with
                    THEN :NEW.SU_partner_SU_with_ChangedAt
                    ELSE v_now
                END,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.SU_partner_SU_with_Reliability, 1),
                p_metadata => :NEW.Metadata_SU_partner_SU_with
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_SU_partner_SU_with(
                p_SU_partner => :OLD.SU_ID_partner,
                p_SU_with => :OLD.SU_ID_with,
                p_changing => :OLD.SU_partner_SU_with_ChangedAt,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_SU_partner_SU_with
            );
        END IF;
    END IF;
END ut_lSU_partner_SU_with;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_partner_SU_with instead of DELETE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_partner_SU_with
INSTEAD OF DELETE ON lSU_partner_SU_with
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    INSERT INTO SU_partner_SU_with_Annex (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        :OLD.Metadata_SU_partner_SU_with,
        :OLD.SU_partner_SU_with_ID,
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_partner_SU_with_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_partner_SU_with_Annex x
            WHERE
                x.SU_partner_SU_with_ID = :OLD.SU_partner_SU_with_ID
            AND
                x.SU_partner_SU_with_PositedAt = v_now
        );
END dt_lSU_partner_SU_with;
/
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the tables and the columns holding values and references, making
-- them available to catalogs and semantic layers. A comment in Oracle is replaced by running the statement again.
-- Oracle has no comment on a schema, so the description of the model itself is not added.
--
COMMENT ON TABLE GRD_Grade IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON COLUMN GRD_Grade.GRD_Grade IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON COLUMN EV_QTY_Event_Quantity_Posit.EV_QTY_Event_Quantity IS 'Static.';
COMMENT ON COLUMN EV_PLC_Event_Place_Posit.EV_PLC_Event_Place IS 'Historized and not restatable, as an attribute of an anchor may be.';
COMMENT ON COLUMN SU_NAM_Subject_Name_Posit.SU_NAM_Subject_Name IS 'Static.';
COMMENT ON COLUMN SU_COD_Subject_Code_Posit.SU_COD_Subject_Code IS 'Static and idempotent.';
COMMENT ON COLUMN SU_GRD_Subject_Grade_Posit.SU_GRD_GRD_ID IS 'Static and knotted.';
COMMENT ON COLUMN SU_NOT_Subject_Note_Posit.SU_NOT_Subject_Note IS 'Static, with a checksum.';
COMMENT ON COLUMN SU_TTL_Subject_Title_Posit.SU_TTL_Subject_Title IS 'Historized, restatable.';
COMMENT ON COLUMN SU_STA_Subject_State_Posit.SU_STA_Subject_State IS 'Historized, not restatable: a restatement is an error.';
COMMENT ON COLUMN SU_LBL_Subject_Label_Posit.SU_LBL_Subject_Label IS 'Historized, not restatable and idempotent: a restatement is skipped.';
COMMENT ON COLUMN SU_TAG_Subject_Tag_Posit.SU_TAG_Subject_Tag IS 'Historized, restatable and idempotent: a restatement is skipped.';
COMMENT ON COLUMN SU_LVL_Subject_Level_Posit.SU_LVL_GRD_ID IS 'Historized and knotted.';
COMMENT ON COLUMN SU_TXT_Subject_Text_Posit.SU_TXT_Subject_Text IS 'Historized, with a checksum.';
COMMENT ON COLUMN SU_ASR_Subject_Assessment_Posit.SU_ASR_Subject_Assessment IS 'Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).';
COMMENT ON COLUMN SU_ERS_Subject_Erasable_Posit.SU_ERS_Subject_Erasable IS 'Historized and deletable (uni-temporal).';
COMMENT ON COLUMN OB_NAM_Object_Name_Posit.OB_NAM_Object_Name IS 'Static.';
COMMENT ON TABLE SU_Subject IS 'The subject of the tests.';
COMMENT ON TABLE OB_Object IS 'Something the subject has or keeps.';
COMMENT ON TABLE EV_Event IS 'An event, with attributes of its own, a static one and a historized one.';
COMMENT ON COLUMN EV_Event.SU_ID_for IS 'The subject the event is for.';
COMMENT ON TABLE SU_holder_OB_item_GRD_grade_Posit IS 'Historized, with identifiers and a knotted value role, restatable.';
COMMENT ON COLUMN SU_holder_OB_item_GRD_grade_Posit.SU_ID_holder IS 'The subject of the tests.';
COMMENT ON COLUMN SU_holder_OB_item_GRD_grade_Posit.OB_ID_item IS 'Something the subject has or keeps.';
COMMENT ON COLUMN SU_holder_OB_item_GRD_grade_Posit.GRD_ID_grade IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON TABLE SU_keeper_OB_thing_GRD_rank_Posit IS 'Historized, with identifiers and a knotted value role, idempotent and not assertive.';
COMMENT ON COLUMN SU_keeper_OB_thing_GRD_rank_Posit.SU_ID_keeper IS 'The subject of the tests.';
COMMENT ON COLUMN SU_keeper_OB_thing_GRD_rank_Posit.OB_ID_thing IS 'Something the subject has or keeps.';
COMMENT ON COLUMN SU_keeper_OB_thing_GRD_rank_Posit.GRD_ID_rank IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON TABLE OB_part_SU_owner_Posit IS 'Static, with an identifier and a value role: each object has one owner.';
COMMENT ON COLUMN OB_part_SU_owner_Posit.OB_ID_part IS 'Something the subject has or keeps.';
COMMENT ON COLUMN OB_part_SU_owner_Posit.SU_ID_owner IS 'The subject of the tests.';
COMMENT ON TABLE SU_partner_SU_with_Posit IS 'Historized, without identifiers.';
COMMENT ON COLUMN SU_partner_SU_with_Posit.SU_ID_partner IS 'The subject of the tests.';
COMMENT ON COLUMN SU_partner_SU_with_Posit.SU_ID_with IS 'The subject of the tests.';
