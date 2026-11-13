-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- An attribute that may be deleted (deletability) also has a deletion table, which holds what was deleted and when.
-- Oracle cannot make a table in a trigger without ending the transaction, so these are made here, not when needed.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_QTY_Event_Quantity table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_QTY_Event_Quantity (
            EV_QTY_EV_ID number(10) not null,
            EV_QTY_Event_Quantity number(10) not null,
            Metadata_EV_QTY number(10) not null,
            constraint fkEV_QTY_Event_Quantity foreign key (
                EV_QTY_EV_ID
            ) references EV_Event(EV_ID),
            constraint pkEV_QTY_Event_Quantity primary key (
                EV_QTY_EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Deletion table -----------------------------------------------------------------------------------------------------
-- EV_QTY_Event_Quantity_Deleted table (what was deleted from EV_QTY_Event_Quantity, and when)
-- It has the columns of the attribute table, without keys and without the checksum, and the time of the deletion.
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_QTY_Event_Quantity_Deleted (
            EV_QTY_EV_ID number(10) not null,
            EV_QTY_Event_Quantity number(10) not null,
            Metadata_EV_QTY number(10) not null,
            EV_QTY_Deleted timestamp not null
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_PLC_Event_Place table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_PLC_Event_Place (
            EV_PLC_EV_ID number(10) not null,
            EV_PLC_Event_Place nvarchar2(42) not null,
            EV_PLC_ChangedAt timestamp not null,
            Metadata_EV_PLC number(10) not null,
            constraint fkEV_PLC_Event_Place foreign key (
                EV_PLC_EV_ID
            ) references EV_Event(EV_ID),
            constraint pkEV_PLC_Event_Place primary key (
                EV_PLC_EV_ID,
                EV_PLC_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Deletion table -----------------------------------------------------------------------------------------------------
-- EV_PLC_Event_Place_Deleted table (what was deleted from EV_PLC_Event_Place, and when)
-- It has the columns of the attribute table, without keys and without the checksum, and the time of the deletion.
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_PLC_Event_Place_Deleted (
            EV_PLC_EV_ID number(10) not null,
            EV_PLC_Event_Place nvarchar2(42) not null,
            EV_PLC_ChangedAt timestamp not null,
            Metadata_EV_PLC number(10) not null,
            EV_PLC_Deleted timestamp not null
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_NAM_Subject_Name (
            SU_NAM_SU_ID number(10) not null,
            SU_NAM_Subject_Name nvarchar2(42) not null,
            Metadata_SU_NAM number(10) not null,
            constraint fkSU_NAM_Subject_Name foreign key (
                SU_NAM_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_NAM_Subject_Name primary key (
                SU_NAM_SU_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Deletion table -----------------------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name_Deleted table (what was deleted from SU_NAM_Subject_Name, and when)
-- It has the columns of the attribute table, without keys and without the checksum, and the time of the deletion.
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_NAM_Subject_Name_Deleted (
            SU_NAM_SU_ID number(10) not null,
            SU_NAM_Subject_Name nvarchar2(42) not null,
            Metadata_SU_NAM number(10) not null,
            SU_NAM_Deleted timestamp not null
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- SU_COD_Subject_Code table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_COD_Subject_Code (
            SU_COD_SU_ID number(10) not null,
            SU_COD_Subject_Code nvarchar2(42) not null,
            Metadata_SU_COD number(10) not null,
            constraint fkSU_COD_Subject_Code foreign key (
                SU_COD_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_COD_Subject_Code primary key (
                SU_COD_SU_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_GRD_Subject_Grade (
            SU_GRD_SU_ID number(10) not null,
            SU_GRD_GRD_ID number(5) not null,
            Metadata_SU_GRD number(10) not null,
            constraint fk_A_SU_GRD_Subject_Grade foreign key (
                SU_GRD_SU_ID
            ) references SU_Subject(SU_ID),
            constraint fk_K_SU_GRD_Subject_Grade foreign key (
                SU_GRD_GRD_ID
            ) references GRD_Grade(GRD_ID),
            constraint pkSU_GRD_Subject_Grade primary key (
                SU_GRD_SU_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- SU_NOT_Subject_Note table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_NOT_Subject_Note (
            SU_NOT_SU_ID number(10) not null,
            SU_NOT_Subject_Note nclob not null,
            Metadata_SU_NOT number(10) not null,
            constraint fkSU_NOT_Subject_Note foreign key (
                SU_NOT_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_NOT_Subject_Note primary key (
                SU_NOT_SU_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_TTL_Subject_Title table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TTL_Subject_Title (
            SU_TTL_SU_ID number(10) not null,
            SU_TTL_Subject_Title nvarchar2(42) not null,
            SU_TTL_ChangedAt timestamp not null,
            Metadata_SU_TTL number(10) not null,
            constraint fkSU_TTL_Subject_Title foreign key (
                SU_TTL_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_TTL_Subject_Title primary key (
                SU_TTL_SU_ID,
                SU_TTL_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_STA_Subject_State table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_STA_Subject_State (
            SU_STA_SU_ID number(10) not null,
            SU_STA_Subject_State nvarchar2(42) not null,
            SU_STA_ChangedAt timestamp not null,
            Metadata_SU_STA number(10) not null,
            constraint fkSU_STA_Subject_State foreign key (
                SU_STA_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_STA_Subject_State primary key (
                SU_STA_SU_ID,
                SU_STA_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_LBL_Subject_Label table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_LBL_Subject_Label (
            SU_LBL_SU_ID number(10) not null,
            SU_LBL_Subject_Label nvarchar2(42) not null,
            SU_LBL_ChangedAt timestamp not null,
            Metadata_SU_LBL number(10) not null,
            constraint fkSU_LBL_Subject_Label foreign key (
                SU_LBL_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_LBL_Subject_Label primary key (
                SU_LBL_SU_ID,
                SU_LBL_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TAG_Subject_Tag (
            SU_TAG_SU_ID number(10) not null,
            SU_TAG_Subject_Tag nvarchar2(42) not null,
            SU_TAG_ChangedAt timestamp not null,
            Metadata_SU_TAG number(10) not null,
            constraint fkSU_TAG_Subject_Tag foreign key (
                SU_TAG_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_TAG_Subject_Tag primary key (
                SU_TAG_SU_ID,
                SU_TAG_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- SU_LVL_Subject_Level table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_LVL_Subject_Level (
            SU_LVL_SU_ID number(10) not null,
            SU_LVL_GRD_ID number(5) not null,
            SU_LVL_ChangedAt timestamp not null,
            Metadata_SU_LVL number(10) not null,
            constraint fk_A_SU_LVL_Subject_Level foreign key (
                SU_LVL_SU_ID
            ) references SU_Subject(SU_ID),
            constraint fk_K_SU_LVL_Subject_Level foreign key (
                SU_LVL_GRD_ID
            ) references GRD_Grade(GRD_ID),
            constraint pkSU_LVL_Subject_Level primary key (
                SU_LVL_SU_ID,
                SU_LVL_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Deletion table -----------------------------------------------------------------------------------------------------
-- SU_LVL_Subject_Level_Deleted table (what was deleted from SU_LVL_Subject_Level, and when)
-- It has the columns of the attribute table, without keys and without the checksum, and the time of the deletion.
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_LVL_Subject_Level_Deleted (
            SU_LVL_SU_ID number(10) not null,
            SU_LVL_GRD_ID number(5) not null,
            SU_LVL_ChangedAt timestamp not null,
            Metadata_SU_LVL number(10) not null,
            SU_LVL_Deleted timestamp not null
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_TXT_Subject_Text table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_TXT_Subject_Text (
            SU_TXT_SU_ID number(10) not null,
            SU_TXT_Subject_Text nclob not null,
            SU_TXT_ChangedAt timestamp not null,
            Metadata_SU_TXT number(10) not null,
            constraint fkSU_TXT_Subject_Text foreign key (
                SU_TXT_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_TXT_Subject_Text primary key (
                SU_TXT_SU_ID,
                SU_TXT_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_ASR_Subject_Assessment (
            SU_ASR_SU_ID number(10) not null,
            SU_ASR_Subject_Assessment nvarchar2(42) not null,
            SU_ASR_ChangedAt timestamp not null,
            Metadata_SU_ASR number(10) not null,
            constraint fkSU_ASR_Subject_Assessment foreign key (
                SU_ASR_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_ASR_Subject_Assessment primary key (
                SU_ASR_SU_ID,
                SU_ASR_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_ERS_Subject_Erasable (
            SU_ERS_SU_ID number(10) not null,
            SU_ERS_Subject_Erasable nvarchar2(42) not null,
            SU_ERS_ChangedAt timestamp not null,
            Metadata_SU_ERS number(10) not null,
            constraint fkSU_ERS_Subject_Erasable foreign key (
                SU_ERS_SU_ID
            ) references SU_Subject(SU_ID),
            constraint pkSU_ERS_Subject_Erasable primary key (
                SU_ERS_SU_ID,
                SU_ERS_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Deletion table -----------------------------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable_Deleted table (what was deleted from SU_ERS_Subject_Erasable, and when)
-- It has the columns of the attribute table, without keys and without the checksum, and the time of the deletion.
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_ERS_Subject_Erasable_Deleted (
            SU_ERS_SU_ID number(10) not null,
            SU_ERS_Subject_Erasable nvarchar2(42) not null,
            SU_ERS_ChangedAt timestamp not null,
            Metadata_SU_ERS number(10) not null,
            SU_ERS_Deleted timestamp not null
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- OB_NAM_Object_Name table (on OB_Object)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE OB_NAM_Object_Name (
            OB_NAM_OB_ID number(10) not null,
            OB_NAM_Object_Name nvarchar2(42) not null,
            Metadata_OB_NAM number(10) not null,
            constraint fkOB_NAM_Object_Name foreign key (
                OB_NAM_OB_ID
            ) references OB_Object(OB_ID),
            constraint pkOB_NAM_Object_Name primary key (
                OB_NAM_OB_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
