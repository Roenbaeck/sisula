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
-- EV_QTY_Event_Quantity_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_QTY_Event_Quantity_Annex table (of EV_QTY_Event_Quantity_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_QTY_Event_Quantity_Annex (
            EV_QTY_ID number(10) not null,
            EV_QTY_PositedAt timestamp not null,
            EV_QTY_Positor number(5) not null,
            EV_QTY_Reliability number(5,2) not null,
            EV_QTY_Assertion char(1) generated always as (
                case
                    when EV_QTY_Reliability > 0 then '+'
                    when EV_QTY_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_QTY number(10) not null,
            constraint fkEV_QTY_Event_Quantity_Annex foreign key (
                EV_QTY_ID
            ) references EV_QTY_Event_Quantity_Posit(EV_QTY_ID),
            constraint pkEV_QTY_Event_Quantity_Annex primary key (
                EV_QTY_ID,
                EV_QTY_Positor,
                EV_QTY_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_PLC_Event_Place_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_PLC_Event_Place_Annex table (of EV_PLC_Event_Place_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_PLC_Event_Place_Annex (
            EV_PLC_ID number(10) not null,
            EV_PLC_PositedAt timestamp not null,
            EV_PLC_Positor number(5) not null,
            EV_PLC_Reliability number(5,2) not null,
            EV_PLC_Assertion char(1) generated always as (
                case
                    when EV_PLC_Reliability > 0 then '+'
                    when EV_PLC_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_PLC number(10) not null,
            constraint fkEV_PLC_Event_Place_Annex foreign key (
                EV_PLC_ID
            ) references EV_PLC_Event_Place_Posit(EV_PLC_ID),
            constraint pkEV_PLC_Event_Place_Annex primary key (
                EV_PLC_ID,
                EV_PLC_Positor,
                EV_PLC_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name_Annex table (of SU_NAM_Subject_Name_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_NAM_Subject_Name_Annex (
            SU_NAM_ID number(10) not null,
            SU_NAM_PositedAt timestamp not null,
            SU_NAM_Positor number(5) not null,
            SU_NAM_Reliability number(5,2) not null,
            SU_NAM_Assertion char(1) generated always as (
                case
                    when SU_NAM_Reliability > 0 then '+'
                    when SU_NAM_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_NAM number(10) not null,
            constraint fkSU_NAM_Subject_Name_Annex foreign key (
                SU_NAM_ID
            ) references SU_NAM_Subject_Name_Posit(SU_NAM_ID),
            constraint pkSU_NAM_Subject_Name_Annex primary key (
                SU_NAM_ID,
                SU_NAM_Positor,
                SU_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- SU_COD_Subject_Code_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_COD_Subject_Code_Annex table (of SU_COD_Subject_Code_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_COD_Subject_Code_Annex (
            SU_COD_ID number(10) not null,
            SU_COD_PositedAt timestamp not null,
            SU_COD_Positor number(5) not null,
            SU_COD_Reliability number(5,2) not null,
            SU_COD_Assertion char(1) generated always as (
                case
                    when SU_COD_Reliability > 0 then '+'
                    when SU_COD_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_COD number(10) not null,
            constraint fkSU_COD_Subject_Code_Annex foreign key (
                SU_COD_ID
            ) references SU_COD_Subject_Code_Posit(SU_COD_ID),
            constraint pkSU_COD_Subject_Code_Annex primary key (
                SU_COD_ID,
                SU_COD_Positor,
                SU_COD_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade_Annex table (of SU_GRD_Subject_Grade_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_GRD_Subject_Grade_Annex (
            SU_GRD_ID number(10) not null,
            SU_GRD_PositedAt timestamp not null,
            SU_GRD_Positor number(5) not null,
            SU_GRD_Reliability number(5,2) not null,
            SU_GRD_Assertion char(1) generated always as (
                case
                    when SU_GRD_Reliability > 0 then '+'
                    when SU_GRD_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_GRD number(10) not null,
            constraint fkSU_GRD_Subject_Grade_Annex foreign key (
                SU_GRD_ID
            ) references SU_GRD_Subject_Grade_Posit(SU_GRD_ID),
            constraint pkSU_GRD_Subject_Grade_Annex primary key (
                SU_GRD_ID,
                SU_GRD_Positor,
                SU_GRD_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- SU_NOT_Subject_Note_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_NOT_Subject_Note_Annex table (of SU_NOT_Subject_Note_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_NOT_Subject_Note_Annex (
            SU_NOT_ID number(10) not null,
            SU_NOT_PositedAt timestamp not null,
            SU_NOT_Positor number(5) not null,
            SU_NOT_Reliability number(5,2) not null,
            SU_NOT_Assertion char(1) generated always as (
                case
                    when SU_NOT_Reliability > 0 then '+'
                    when SU_NOT_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_NOT number(10) not null,
            constraint fkSU_NOT_Subject_Note_Annex foreign key (
                SU_NOT_ID
            ) references SU_NOT_Subject_Note_Posit(SU_NOT_ID),
            constraint pkSU_NOT_Subject_Note_Annex primary key (
                SU_NOT_ID,
                SU_NOT_Positor,
                SU_NOT_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_TTL_Subject_Title_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_TTL_Subject_Title_Annex table (of SU_TTL_Subject_Title_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TTL_Subject_Title_Annex (
            SU_TTL_ID number(10) not null,
            SU_TTL_PositedAt timestamp not null,
            SU_TTL_Positor number(5) not null,
            SU_TTL_Reliability number(5,2) not null,
            SU_TTL_Assertion char(1) generated always as (
                case
                    when SU_TTL_Reliability > 0 then '+'
                    when SU_TTL_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_TTL number(10) not null,
            constraint fkSU_TTL_Subject_Title_Annex foreign key (
                SU_TTL_ID
            ) references SU_TTL_Subject_Title_Posit(SU_TTL_ID),
            constraint pkSU_TTL_Subject_Title_Annex primary key (
                SU_TTL_ID,
                SU_TTL_Positor,
                SU_TTL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_STA_Subject_State_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_STA_Subject_State_Annex table (of SU_STA_Subject_State_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_STA_Subject_State_Annex (
            SU_STA_ID number(10) not null,
            SU_STA_PositedAt timestamp not null,
            SU_STA_Positor number(5) not null,
            SU_STA_Reliability number(5,2) not null,
            SU_STA_Assertion char(1) generated always as (
                case
                    when SU_STA_Reliability > 0 then '+'
                    when SU_STA_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_STA number(10) not null,
            constraint fkSU_STA_Subject_State_Annex foreign key (
                SU_STA_ID
            ) references SU_STA_Subject_State_Posit(SU_STA_ID),
            constraint pkSU_STA_Subject_State_Annex primary key (
                SU_STA_ID,
                SU_STA_Positor,
                SU_STA_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_LBL_Subject_Label_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_LBL_Subject_Label_Annex table (of SU_LBL_Subject_Label_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_LBL_Subject_Label_Annex (
            SU_LBL_ID number(10) not null,
            SU_LBL_PositedAt timestamp not null,
            SU_LBL_Positor number(5) not null,
            SU_LBL_Reliability number(5,2) not null,
            SU_LBL_Assertion char(1) generated always as (
                case
                    when SU_LBL_Reliability > 0 then '+'
                    when SU_LBL_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_LBL number(10) not null,
            constraint fkSU_LBL_Subject_Label_Annex foreign key (
                SU_LBL_ID
            ) references SU_LBL_Subject_Label_Posit(SU_LBL_ID),
            constraint pkSU_LBL_Subject_Label_Annex primary key (
                SU_LBL_ID,
                SU_LBL_Positor,
                SU_LBL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag_Annex table (of SU_TAG_Subject_Tag_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TAG_Subject_Tag_Annex (
            SU_TAG_ID number(10) not null,
            SU_TAG_PositedAt timestamp not null,
            SU_TAG_Positor number(5) not null,
            SU_TAG_Reliability number(5,2) not null,
            SU_TAG_Assertion char(1) generated always as (
                case
                    when SU_TAG_Reliability > 0 then '+'
                    when SU_TAG_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_TAG number(10) not null,
            constraint fkSU_TAG_Subject_Tag_Annex foreign key (
                SU_TAG_ID
            ) references SU_TAG_Subject_Tag_Posit(SU_TAG_ID),
            constraint pkSU_TAG_Subject_Tag_Annex primary key (
                SU_TAG_ID,
                SU_TAG_Positor,
                SU_TAG_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- SU_LVL_Subject_Level_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_LVL_Subject_Level_Annex table (of SU_LVL_Subject_Level_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_LVL_Subject_Level_Annex (
            SU_LVL_ID number(10) not null,
            SU_LVL_PositedAt timestamp not null,
            SU_LVL_Positor number(5) not null,
            SU_LVL_Reliability number(5,2) not null,
            SU_LVL_Assertion char(1) generated always as (
                case
                    when SU_LVL_Reliability > 0 then '+'
                    when SU_LVL_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_LVL number(10) not null,
            constraint fkSU_LVL_Subject_Level_Annex foreign key (
                SU_LVL_ID
            ) references SU_LVL_Subject_Level_Posit(SU_LVL_ID),
            constraint pkSU_LVL_Subject_Level_Annex primary key (
                SU_LVL_ID,
                SU_LVL_Positor,
                SU_LVL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_TXT_Subject_Text_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_TXT_Subject_Text_Annex table (of SU_TXT_Subject_Text_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TXT_Subject_Text_Annex (
            SU_TXT_ID number(10) not null,
            SU_TXT_PositedAt timestamp not null,
            SU_TXT_Positor number(5) not null,
            SU_TXT_Reliability number(5,2) not null,
            SU_TXT_Assertion char(1) generated always as (
                case
                    when SU_TXT_Reliability > 0 then '+'
                    when SU_TXT_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_TXT number(10) not null,
            constraint fkSU_TXT_Subject_Text_Annex foreign key (
                SU_TXT_ID
            ) references SU_TXT_Subject_Text_Posit(SU_TXT_ID),
            constraint pkSU_TXT_Subject_Text_Annex primary key (
                SU_TXT_ID,
                SU_TXT_Positor,
                SU_TXT_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment_Annex table (of SU_ASR_Subject_Assessment_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_ASR_Subject_Assessment_Annex (
            SU_ASR_ID number(10) not null,
            SU_ASR_PositedAt timestamp not null,
            SU_ASR_Positor number(5) not null,
            SU_ASR_Reliability number(5,2) not null,
            SU_ASR_Assertion char(1) generated always as (
                case
                    when SU_ASR_Reliability > 0 then '+'
                    when SU_ASR_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_ASR number(10) not null,
            constraint fkSU_ASR_Subject_Assessment_Annex foreign key (
                SU_ASR_ID
            ) references SU_ASR_Subject_Assessment_Posit(SU_ASR_ID),
            constraint pkSU_ASR_Subject_Assessment_Annex primary key (
                SU_ASR_ID,
                SU_ASR_Positor,
                SU_ASR_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable_Annex table (of SU_ERS_Subject_Erasable_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_ERS_Subject_Erasable_Annex (
            SU_ERS_ID number(10) not null,
            SU_ERS_PositedAt timestamp not null,
            SU_ERS_Positor number(5) not null,
            SU_ERS_Reliability number(5,2) not null,
            SU_ERS_Assertion char(1) generated always as (
                case
                    when SU_ERS_Reliability > 0 then '+'
                    when SU_ERS_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_ERS number(10) not null,
            constraint fkSU_ERS_Subject_Erasable_Annex foreign key (
                SU_ERS_ID
            ) references SU_ERS_Subject_Erasable_Posit(SU_ERS_ID),
            constraint pkSU_ERS_Subject_Erasable_Annex primary key (
                SU_ERS_ID,
                SU_ERS_Positor,
                SU_ERS_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- OB_NAM_Object_Name_Posit table (on OB_Object)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- OB_NAM_Object_Name_Annex table (of OB_NAM_Object_Name_Posit on OB_Object)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE OB_NAM_Object_Name_Annex (
            OB_NAM_ID number(10) not null,
            OB_NAM_PositedAt timestamp not null,
            OB_NAM_Positor number(5) not null,
            OB_NAM_Reliability number(5,2) not null,
            OB_NAM_Assertion char(1) generated always as (
                case
                    when OB_NAM_Reliability > 0 then '+'
                    when OB_NAM_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_OB_NAM number(10) not null,
            constraint fkOB_NAM_Object_Name_Annex foreign key (
                OB_NAM_ID
            ) references OB_NAM_Object_Name_Posit(OB_NAM_ID),
            constraint pkOB_NAM_Object_Name_Annex primary key (
                OB_NAM_ID,
                OB_NAM_Positor,
                OB_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
