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
-- GRD_Grade table
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
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- SU_Subject table (with 12 attributes)
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
-- OB_Object table (with 1 attributes)
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
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 2 attributes and 1 roles)
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
-- SU_holder_OB_item_GRD_grade table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_holder_OB_item_GRD_grade (
            SU_ID_holder number(10) not null, 
            OB_ID_item number(10) not null, 
            GRD_ID_grade number(5) not null,
            SU_holder_OB_item_GRD_grade_ChangedAt timestamp not null,
            Metadata_SU_holder_OB_item_GRD_grade number(10) not null,
            constraint SU_holder_OB_item_GRD_grade_fkSU_holder foreign key (
                SU_ID_holder
            ) references SU_Subject(SU_ID),
            constraint SU_holder_OB_item_GRD_grade_fkOB_item foreign key (
                OB_ID_item
            ) references OB_Object(OB_ID),
            constraint SU_holder_OB_item_GRD_grade_fkGRD_grade foreign key (
                GRD_ID_grade
            ) references GRD_Grade(GRD_ID),
            constraint pkSU_holder_OB_item_GRD_grade primary key (
                SU_ID_holder,
                OB_ID_item,
                SU_holder_OB_item_GRD_grade_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Deletion table -----------------------------------------------------------------------------------------------------
-- SU_holder_OB_item_GRD_grade_Deleted table (what was deleted from SU_holder_OB_item_GRD_grade, and when)
-- It has the columns of the tie table, without keys, and the time of the deletion.
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_holder_OB_item_GRD_grade_Deleted (
            SU_ID_holder number(10) not null, 
            OB_ID_item number(10) not null, 
            GRD_ID_grade number(5) not null,
            SU_holder_OB_item_GRD_grade_ChangedAt timestamp not null,
            Metadata_SU_holder_OB_item_GRD_grade number(10) not null,
            SU_holder_OB_item_GRD_grade_Deleted timestamp not null
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_keeper_OB_thing_GRD_rank (
            SU_ID_keeper number(10) not null, 
            OB_ID_thing number(10) not null, 
            GRD_ID_rank number(5) not null,
            SU_keeper_OB_thing_GRD_rank_ChangedAt timestamp not null,
            Metadata_SU_keeper_OB_thing_GRD_rank number(10) not null,
            constraint SU_keeper_OB_thing_GRD_rank_fkSU_keeper foreign key (
                SU_ID_keeper
            ) references SU_Subject(SU_ID),
            constraint SU_keeper_OB_thing_GRD_rank_fkOB_thing foreign key (
                OB_ID_thing
            ) references OB_Object(OB_ID),
            constraint SU_keeper_OB_thing_GRD_rank_fkGRD_rank foreign key (
                GRD_ID_rank
            ) references GRD_Grade(GRD_ID),
            constraint pkSU_keeper_OB_thing_GRD_rank primary key (
                SU_ID_keeper,
                OB_ID_thing,
                SU_keeper_OB_thing_GRD_rank_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- OB_part_SU_owner table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE OB_part_SU_owner (
            OB_ID_part number(10) not null, 
            SU_ID_owner number(10) not null, 
            Metadata_OB_part_SU_owner number(10) not null,
            constraint OB_part_SU_owner_fkOB_part foreign key (
                OB_ID_part
            ) references OB_Object(OB_ID),
            constraint OB_part_SU_owner_fkSU_owner foreign key (
                SU_ID_owner
            ) references SU_Subject(SU_ID),
            constraint pkOB_part_SU_owner primary key (
                OB_ID_part
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Deletion table -----------------------------------------------------------------------------------------------------
-- OB_part_SU_owner_Deleted table (what was deleted from OB_part_SU_owner, and when)
-- It has the columns of the tie table, without keys, and the time of the deletion.
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE OB_part_SU_owner_Deleted (
            OB_ID_part number(10) not null, 
            SU_ID_owner number(10) not null, 
            Metadata_OB_part_SU_owner number(10) not null,
            OB_part_SU_owner_Deleted timestamp not null
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized tie table -----------------------------------------------------------------------------------------------
-- SU_partner_SU_with table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE SU_partner_SU_with (
            SU_ID_partner number(10) not null, 
            SU_ID_with number(10) not null, 
            SU_partner_SU_with_ChangedAt timestamp not null,
            Metadata_SU_partner_SU_with number(10) not null,
            constraint SU_partner_SU_with_fkSU_partner foreign key (
                SU_ID_partner
            ) references SU_Subject(SU_ID),
            constraint SU_partner_SU_with_fkSU_with foreign key (
                SU_ID_with
            ) references SU_Subject(SU_ID),
            constraint SU_partner_SU_with_uqSU_partner unique (
                SU_ID_partner,
                SU_partner_SU_with_ChangedAt
            ),
            constraint SU_partner_SU_with_uqSU_with unique (
                SU_ID_with,
                SU_partner_SU_with_ChangedAt
            ),
            constraint pkSU_partner_SU_with primary key (
                SU_ID_partner,
                SU_ID_with,
                SU_partner_SU_with_ChangedAt
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
-- rEV_PLC_Event_Place rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_PLC_Event_Place (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_PLC,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt
        FROM
            EV_PLC_Event_Place
        WHERE
            EV_PLC_ChangedAt <= changingTimepoint
    ]';
END rEV_PLC_Event_Place;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TTL_Subject_Title (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TTL,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt
        FROM
            SU_TTL_Subject_Title
        WHERE
            SU_TTL_ChangedAt <= changingTimepoint
    ]';
END rSU_TTL_Subject_Title;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_STA_Subject_State rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_STA_Subject_State (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_STA,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt
        FROM
            SU_STA_Subject_State
        WHERE
            SU_STA_ChangedAt <= changingTimepoint
    ]';
END rSU_STA_Subject_State;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LBL_Subject_Label (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LBL,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt
        FROM
            SU_LBL_Subject_Label
        WHERE
            SU_LBL_ChangedAt <= changingTimepoint
    ]';
END rSU_LBL_Subject_Label;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TAG_Subject_Tag (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TAG,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt
        FROM
            SU_TAG_Subject_Tag
        WHERE
            SU_TAG_ChangedAt <= changingTimepoint
    ]';
END rSU_TAG_Subject_Tag;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LVL_Subject_Level (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LVL,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt
        FROM
            SU_LVL_Subject_Level
        WHERE
            SU_LVL_ChangedAt <= changingTimepoint
    ]';
END rSU_LVL_Subject_Level;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TXT_Subject_Text (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TXT,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt
        FROM
            SU_TXT_Subject_Text
        WHERE
            SU_TXT_ChangedAt <= changingTimepoint
    ]';
END rSU_TXT_Subject_Text;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ASR_Subject_Assessment (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ASR,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt
        FROM
            SU_ASR_Subject_Assessment
        WHERE
            SU_ASR_ChangedAt <= changingTimepoint
    ]';
END rSU_ASR_Subject_Assessment;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ERS_Subject_Erasable (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ERS,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt
        FROM
            SU_ERS_Subject_Erasable
        WHERE
            SU_ERS_ChangedAt <= changingTimepoint
    ]';
END rSU_ERS_Subject_Erasable;
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
CREATE OR REPLACE VIEW lSU_Subject (
    SU_ID,
    Metadata_SU,
    SU_NAM_SU_ID,
    Metadata_SU_NAM,
    Deletable_SU_NAM,
    SU_NAM_Subject_Name,
    SU_COD_SU_ID,
    Metadata_SU_COD,
    SU_COD_Subject_Code,
    SU_GRD_SU_ID,
    Metadata_SU_GRD,
    SU_GRD_GRD_Grade,
    SU_GRD_Metadata_GRD,
    SU_GRD_GRD_ID,
    SU_NOT_SU_ID,
    Metadata_SU_NOT,
    SU_NOT_Subject_Note,
    SU_TTL_SU_ID,
    Metadata_SU_TTL,
    SU_TTL_ChangedAt,
    SU_TTL_Subject_Title,
    SU_STA_SU_ID,
    Metadata_SU_STA,
    SU_STA_ChangedAt,
    SU_STA_Subject_State,
    SU_LBL_SU_ID,
    Metadata_SU_LBL,
    SU_LBL_ChangedAt,
    SU_LBL_Subject_Label,
    SU_TAG_SU_ID,
    Metadata_SU_TAG,
    SU_TAG_ChangedAt,
    SU_TAG_Subject_Tag,
    SU_LVL_SU_ID,
    Metadata_SU_LVL,
    Deletable_SU_LVL,
    SU_LVL_ChangedAt,
    SU_LVL_GRD_Grade,
    SU_LVL_Metadata_GRD,
    SU_LVL_GRD_ID,
    SU_TXT_SU_ID,
    Metadata_SU_TXT,
    SU_TXT_ChangedAt,
    SU_TXT_Subject_Text,
    SU_ASR_SU_ID,
    Metadata_SU_ASR,
    SU_ASR_ChangedAt,
    SU_ASR_Subject_Assessment,
    SU_ERS_SU_ID,
    Metadata_SU_ERS,
    Deletable_SU_ERS,
    SU_ERS_ChangedAt,
    SU_ERS_Subject_Erasable
)
AS
SELECT
    "SU".SU_ID,
    "SU".Metadata_SU,
    "NAM".SU_NAM_SU_ID,
    "NAM".Metadata_SU_NAM,
    CAST(NULL AS number(1)),
    "NAM".SU_NAM_Subject_Name,
    "COD".SU_COD_SU_ID,
    "COD".Metadata_SU_COD,
    "COD".SU_COD_Subject_Code,
    "GRD".SU_GRD_SU_ID,
    "GRD".Metadata_SU_GRD,
    "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
    "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
    "GRD".SU_GRD_GRD_ID,
    "NOT".SU_NOT_SU_ID,
    "NOT".Metadata_SU_NOT,
    "NOT".SU_NOT_Subject_Note,
    "TTL".SU_TTL_SU_ID,
    "TTL".Metadata_SU_TTL,
    "TTL".SU_TTL_ChangedAt,
    "TTL".SU_TTL_Subject_Title,
    "STA".SU_STA_SU_ID,
    "STA".Metadata_SU_STA,
    "STA".SU_STA_ChangedAt,
    "STA".SU_STA_Subject_State,
    "LBL".SU_LBL_SU_ID,
    "LBL".Metadata_SU_LBL,
    "LBL".SU_LBL_ChangedAt,
    "LBL".SU_LBL_Subject_Label,
    "TAG".SU_TAG_SU_ID,
    "TAG".Metadata_SU_TAG,
    "TAG".SU_TAG_ChangedAt,
    "TAG".SU_TAG_Subject_Tag,
    "LVL".SU_LVL_SU_ID,
    "LVL".Metadata_SU_LVL,
    CAST(NULL AS number(1)),
    "LVL".SU_LVL_ChangedAt,
    "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
    "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
    "LVL".SU_LVL_GRD_ID,
    "TXT".SU_TXT_SU_ID,
    "TXT".Metadata_SU_TXT,
    "TXT".SU_TXT_ChangedAt,
    "TXT".SU_TXT_Subject_Text,
    "ASR".SU_ASR_SU_ID,
    "ASR".Metadata_SU_ASR,
    "ASR".SU_ASR_ChangedAt,
    "ASR".SU_ASR_Subject_Assessment,
    "ERS".SU_ERS_SU_ID,
    "ERS".Metadata_SU_ERS,
    CAST(NULL AS number(1)),
    "ERS".SU_ERS_ChangedAt,
    "ERS".SU_ERS_Subject_Erasable
FROM
    SU_Subject "SU"
LEFT JOIN
    SU_NAM_Subject_Name "NAM"
ON
    "NAM".SU_NAM_SU_ID = "SU".SU_ID
LEFT JOIN
    SU_COD_Subject_Code "COD"
ON
    "COD".SU_COD_SU_ID = "SU".SU_ID
LEFT JOIN
    SU_GRD_Subject_Grade "GRD"
ON
    "GRD".SU_GRD_SU_ID = "SU".SU_ID
LEFT JOIN
    GRD_Grade "kGRD"
ON
    "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
LEFT JOIN
    SU_NOT_Subject_Note "NOT"
ON
    "NOT".SU_NOT_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_TTL_Subject_Title a
        WHERE
            a.SU_TTL_ChangedAt = (
                SELECT
                    MAX(sub.SU_TTL_ChangedAt)
                FROM
                    SU_TTL_Subject_Title sub
                WHERE
                    sub.SU_TTL_SU_ID = a.SU_TTL_SU_ID
            )
    ) "TTL"
ON
    "TTL".SU_TTL_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_STA_Subject_State a
        WHERE
            a.SU_STA_ChangedAt = (
                SELECT
                    MAX(sub.SU_STA_ChangedAt)
                FROM
                    SU_STA_Subject_State sub
                WHERE
                    sub.SU_STA_SU_ID = a.SU_STA_SU_ID
            )
    ) "STA"
ON
    "STA".SU_STA_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_LBL_Subject_Label a
        WHERE
            a.SU_LBL_ChangedAt = (
                SELECT
                    MAX(sub.SU_LBL_ChangedAt)
                FROM
                    SU_LBL_Subject_Label sub
                WHERE
                    sub.SU_LBL_SU_ID = a.SU_LBL_SU_ID
            )
    ) "LBL"
ON
    "LBL".SU_LBL_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_TAG_Subject_Tag a
        WHERE
            a.SU_TAG_ChangedAt = (
                SELECT
                    MAX(sub.SU_TAG_ChangedAt)
                FROM
                    SU_TAG_Subject_Tag sub
                WHERE
                    sub.SU_TAG_SU_ID = a.SU_TAG_SU_ID
            )
    ) "TAG"
ON
    "TAG".SU_TAG_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_LVL_Subject_Level a
        WHERE
            a.SU_LVL_ChangedAt = (
                SELECT
                    MAX(sub.SU_LVL_ChangedAt)
                FROM
                    SU_LVL_Subject_Level sub
                WHERE
                    sub.SU_LVL_SU_ID = a.SU_LVL_SU_ID
            )
    ) "LVL"
ON
    "LVL".SU_LVL_SU_ID = "SU".SU_ID
LEFT JOIN
    GRD_Grade "kLVL"
ON
    "kLVL".GRD_ID = "LVL".SU_LVL_GRD_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_TXT_Subject_Text a
        WHERE
            a.SU_TXT_ChangedAt = (
                SELECT
                    MAX(sub.SU_TXT_ChangedAt)
                FROM
                    SU_TXT_Subject_Text sub
                WHERE
                    sub.SU_TXT_SU_ID = a.SU_TXT_SU_ID
            )
    ) "TXT"
ON
    "TXT".SU_TXT_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_ASR_Subject_Assessment a
        WHERE
            a.SU_ASR_ChangedAt = (
                SELECT
                    MAX(sub.SU_ASR_ChangedAt)
                FROM
                    SU_ASR_Subject_Assessment sub
                WHERE
                    sub.SU_ASR_SU_ID = a.SU_ASR_SU_ID
            )
    ) "ASR"
ON
    "ASR".SU_ASR_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_ERS_Subject_Erasable a
        WHERE
            a.SU_ERS_ChangedAt = (
                SELECT
                    MAX(sub.SU_ERS_ChangedAt)
                FROM
                    SU_ERS_Subject_Erasable sub
                WHERE
                    sub.SU_ERS_SU_ID = a.SU_ERS_SU_ID
            )
    ) "ERS"
ON
    "ERS".SU_ERS_SU_ID = "SU".SU_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_Subject (
    changingTimepoint IN timestamp
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
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ChangedAt,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_Subject_Erasable
        FROM
            SU_Subject "SU"
        LEFT JOIN
            SU_NAM_Subject_Name "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        LEFT JOIN
            SU_COD_Subject_Code "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        LEFT JOIN
            SU_GRD_Subject_Grade "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kGRD"
        ON
            "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
        LEFT JOIN
            SU_NOT_Subject_Note "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_TTL_Subject_Title a
                WHERE
                    a.SU_TTL_ChangedAt = (
                        SELECT
                            MAX(sub.SU_TTL_ChangedAt)
                        FROM
                            SU_TTL_Subject_Title sub
                        WHERE
                            sub.SU_TTL_SU_ID = a.SU_TTL_SU_ID
                        AND
                            sub.SU_TTL_ChangedAt <= changingTimepoint
                    )
            ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_STA_Subject_State a
                WHERE
                    a.SU_STA_ChangedAt = (
                        SELECT
                            MAX(sub.SU_STA_ChangedAt)
                        FROM
                            SU_STA_Subject_State sub
                        WHERE
                            sub.SU_STA_SU_ID = a.SU_STA_SU_ID
                        AND
                            sub.SU_STA_ChangedAt <= changingTimepoint
                    )
            ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_LBL_Subject_Label a
                WHERE
                    a.SU_LBL_ChangedAt = (
                        SELECT
                            MAX(sub.SU_LBL_ChangedAt)
                        FROM
                            SU_LBL_Subject_Label sub
                        WHERE
                            sub.SU_LBL_SU_ID = a.SU_LBL_SU_ID
                        AND
                            sub.SU_LBL_ChangedAt <= changingTimepoint
                    )
            ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_TAG_Subject_Tag a
                WHERE
                    a.SU_TAG_ChangedAt = (
                        SELECT
                            MAX(sub.SU_TAG_ChangedAt)
                        FROM
                            SU_TAG_Subject_Tag sub
                        WHERE
                            sub.SU_TAG_SU_ID = a.SU_TAG_SU_ID
                        AND
                            sub.SU_TAG_ChangedAt <= changingTimepoint
                    )
            ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_LVL_Subject_Level a
                WHERE
                    a.SU_LVL_ChangedAt = (
                        SELECT
                            MAX(sub.SU_LVL_ChangedAt)
                        FROM
                            SU_LVL_Subject_Level sub
                        WHERE
                            sub.SU_LVL_SU_ID = a.SU_LVL_SU_ID
                        AND
                            sub.SU_LVL_ChangedAt <= changingTimepoint
                    )
            ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kLVL"
        ON
            "kLVL".GRD_ID = "LVL".SU_LVL_GRD_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_TXT_Subject_Text a
                WHERE
                    a.SU_TXT_ChangedAt = (
                        SELECT
                            MAX(sub.SU_TXT_ChangedAt)
                        FROM
                            SU_TXT_Subject_Text sub
                        WHERE
                            sub.SU_TXT_SU_ID = a.SU_TXT_SU_ID
                        AND
                            sub.SU_TXT_ChangedAt <= changingTimepoint
                    )
            ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_ASR_Subject_Assessment a
                WHERE
                    a.SU_ASR_ChangedAt = (
                        SELECT
                            MAX(sub.SU_ASR_ChangedAt)
                        FROM
                            SU_ASR_Subject_Assessment sub
                        WHERE
                            sub.SU_ASR_SU_ID = a.SU_ASR_SU_ID
                        AND
                            sub.SU_ASR_ChangedAt <= changingTimepoint
                    )
            ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_ERS_Subject_Erasable a
                WHERE
                    a.SU_ERS_ChangedAt = (
                        SELECT
                            MAX(sub.SU_ERS_ChangedAt)
                        FROM
                            SU_ERS_Subject_Erasable sub
                        WHERE
                            sub.SU_ERS_SU_ID = a.SU_ERS_SU_ID
                        AND
                            sub.SU_ERS_ChangedAt <= changingTimepoint
                    )
            ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
    ]';
END pSU_Subject;
/
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
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
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
            timepoints.mnemonic,
            "SU".SU_ID,
            "SU".Metadata_SU,
            "NAM".SU_NAM_SU_ID,
            "NAM".Metadata_SU_NAM,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ChangedAt,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ChangedAt,
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
        LEFT JOIN
            SU_NAM_Subject_Name "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        LEFT JOIN
            SU_COD_Subject_Code "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        LEFT JOIN
            SU_GRD_Subject_Grade "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kGRD"
        ON
            "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
        LEFT JOIN
            SU_NOT_Subject_Note "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.SU_TTL_ChangedAt) OVER (
                    PARTITION BY h.SU_TTL_SU_ID
                    ORDER BY h.SU_TTL_ChangedAt
                ) AS untilTime
            FROM
                SU_TTL_Subject_Title h
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
                h.*,
                LEAD(h.SU_STA_ChangedAt) OVER (
                    PARTITION BY h.SU_STA_SU_ID
                    ORDER BY h.SU_STA_ChangedAt
                ) AS untilTime
            FROM
                SU_STA_Subject_State h
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
                h.*,
                LEAD(h.SU_LBL_ChangedAt) OVER (
                    PARTITION BY h.SU_LBL_SU_ID
                    ORDER BY h.SU_LBL_ChangedAt
                ) AS untilTime
            FROM
                SU_LBL_Subject_Label h
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
                h.*,
                LEAD(h.SU_TAG_ChangedAt) OVER (
                    PARTITION BY h.SU_TAG_SU_ID
                    ORDER BY h.SU_TAG_ChangedAt
                ) AS untilTime
            FROM
                SU_TAG_Subject_Tag h
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
                h.*,
                LEAD(h.SU_LVL_ChangedAt) OVER (
                    PARTITION BY h.SU_LVL_SU_ID
                    ORDER BY h.SU_LVL_ChangedAt
                ) AS untilTime
            FROM
                SU_LVL_Subject_Level h
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
                h.*,
                LEAD(h.SU_TXT_ChangedAt) OVER (
                    PARTITION BY h.SU_TXT_SU_ID
                    ORDER BY h.SU_TXT_ChangedAt
                ) AS untilTime
            FROM
                SU_TXT_Subject_Text h
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
                h.*,
                LEAD(h.SU_ASR_ChangedAt) OVER (
                    PARTITION BY h.SU_ASR_SU_ID
                    ORDER BY h.SU_ASR_ChangedAt
                ) AS untilTime
            FROM
                SU_ASR_Subject_Assessment h
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
                h.*,
                LEAD(h.SU_ERS_ChangedAt) OVER (
                    PARTITION BY h.SU_ERS_SU_ID
                    ORDER BY h.SU_ERS_ChangedAt
                ) AS untilTime
            FROM
                SU_ERS_Subject_Erasable h
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
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lOB_Object (
    OB_ID,
    Metadata_OB,
    OB_NAM_OB_ID,
    Metadata_OB_NAM,
    OB_NAM_Object_Name
)
AS
SELECT
    "OB".OB_ID,
    "OB".Metadata_OB,
    "NAM".OB_NAM_OB_ID,
    "NAM".Metadata_OB_NAM,
    "NAM".OB_NAM_Object_Name
FROM
    OB_Object "OB"
LEFT JOIN
    OB_NAM_Object_Name "NAM"
ON
    "NAM".OB_NAM_OB_ID = "OB".OB_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pOB_Object (
    changingTimepoint IN timestamp
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
            "NAM".OB_NAM_Object_Name
        FROM
            OB_Object "OB"
        LEFT JOIN
            OB_NAM_Object_Name "NAM"
        ON
            "NAM".OB_NAM_OB_ID = "OB".OB_ID
    ]';
END pOB_Object;
/
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
    Metadata_EV,
    SU_ID_for,
    EV_QTY_EV_ID,
    Metadata_EV_QTY,
    Deletable_EV_QTY,
    EV_QTY_Event_Quantity,
    EV_PLC_EV_ID,
    Metadata_EV_PLC,
    Deletable_EV_PLC,
    EV_PLC_ChangedAt,
    EV_PLC_Event_Place
)
AS
SELECT
    "EV".EV_ID,
    "EV".Metadata_EV,
    "EV".SU_ID_for,
    "QTY".EV_QTY_EV_ID,
    "QTY".Metadata_EV_QTY,
    CAST(NULL AS number(1)),
    "QTY".EV_QTY_Event_Quantity,
    "PLC".EV_PLC_EV_ID,
    "PLC".Metadata_EV_PLC,
    CAST(NULL AS number(1)),
    "PLC".EV_PLC_ChangedAt,
    "PLC".EV_PLC_Event_Place
FROM
    EV_Event "EV"
LEFT JOIN
    EV_QTY_Event_Quantity "QTY"
ON
    "QTY".EV_QTY_EV_ID = "EV".EV_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            EV_PLC_Event_Place a
        WHERE
            a.EV_PLC_ChangedAt = (
                SELECT
                    MAX(sub.EV_PLC_ChangedAt)
                FROM
                    EV_PLC_Event_Place sub
                WHERE
                    sub.EV_PLC_EV_ID = a.EV_PLC_EV_ID
            )
    ) "PLC"
ON
    "PLC".EV_PLC_EV_ID = "EV".EV_ID
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
            "EV".Metadata_EV,
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_Event_Place
        FROM
            EV_Event "EV"
        LEFT JOIN
            EV_QTY_Event_Quantity "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    EV_PLC_Event_Place a
                WHERE
                    a.EV_PLC_ChangedAt = (
                        SELECT
                            MAX(sub.EV_PLC_ChangedAt)
                        FROM
                            EV_PLC_Event_Place sub
                        WHERE
                            sub.EV_PLC_EV_ID = a.EV_PLC_EV_ID
                        AND
                            sub.EV_PLC_ChangedAt <= changingTimepoint
                    )
            ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
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
    pEV_Event(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
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
            timepoints.mnemonic,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ChangedAt,
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
        LEFT JOIN
            EV_QTY_Event_Quantity "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.EV_PLC_ChangedAt) OVER (
                    PARTITION BY h.EV_PLC_EV_ID
                    ORDER BY h.EV_PLC_ChangedAt
                ) AS untilTime
            FROM
                EV_PLC_Event_Place h
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
CREATE OR REPLACE VIEW lSU_holder_OB_item_GRD_grade (
    Metadata_SU_holder_OB_item_GRD_grade,
    Deletable_SU_holder_OB_item_GRD_grade,
    SU_holder_OB_item_GRD_grade_ChangedAt,
    SU_ID_holder,
    OB_ID_item,
    grade_GRD_Grade,
    grade_Metadata_GRD,
    GRD_ID_grade
)
AS
SELECT
    tie.Metadata_SU_holder_OB_item_GRD_grade,
    CAST(NULL AS number(1)),
    tie.SU_holder_OB_item_GRD_grade_ChangedAt,
    tie.SU_ID_holder,
    tie.OB_ID_item,
    "GRD_grade".GRD_Grade AS grade_GRD_Grade,
    "GRD_grade".Metadata_GRD AS grade_Metadata_GRD,
    tie.GRD_ID_grade
FROM
    (
        SELECT
            t.*,
            MAX(t.SU_holder_OB_item_GRD_grade_ChangedAt) OVER (
                PARTITION BY
                    t.SU_ID_holder,
                    t.OB_ID_item
            ) AS latestTime
        FROM
            SU_holder_OB_item_GRD_grade t
    ) tie
LEFT JOIN
    GRD_Grade "GRD_grade"
ON
    "GRD_grade".GRD_ID = tie.GRD_ID_grade
WHERE
    tie.SU_holder_OB_item_GRD_grade_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_holder_OB_item_GRD_grade (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_SU_holder_OB_item_GRD_grade,
            tie.SU_holder_OB_item_GRD_grade_ChangedAt,
            tie.SU_ID_holder,
            tie.OB_ID_item,
            "GRD_grade".GRD_Grade AS grade_GRD_Grade,
            "GRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            tie.GRD_ID_grade
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.SU_holder_OB_item_GRD_grade_ChangedAt) OVER (
                        PARTITION BY
                            t.SU_ID_holder,
                            t.OB_ID_item
                    ) AS latestTime
                FROM
                    SU_holder_OB_item_GRD_grade t
                WHERE
                    t.SU_holder_OB_item_GRD_grade_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            GRD_Grade "GRD_grade"
        ON
            "GRD_grade".GRD_ID = tie.GRD_ID_grade
        WHERE
            tie.SU_holder_OB_item_GRD_grade_ChangedAt = tie.latestTime
    ]';
END pSU_holder_OB_item_GRD_grade;
/
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
            tie.Metadata_SU_holder_OB_item_GRD_grade,
            tie.SU_holder_OB_item_GRD_grade_ChangedAt,
            tie.SU_ID_holder,
            tie.OB_ID_item,
            "GRD_grade".GRD_Grade AS grade_GRD_Grade,
            "GRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            tie.GRD_ID_grade
        FROM
            SU_holder_OB_item_GRD_grade tie
        LEFT JOIN
            GRD_Grade "GRD_grade"
        ON
            "GRD_grade".GRD_ID = tie.GRD_ID_grade
        WHERE
            tie.SU_holder_OB_item_GRD_grade_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_holder_OB_item_GRD_grade;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_keeper_OB_thing_GRD_rank (
    Metadata_SU_keeper_OB_thing_GRD_rank,
    SU_keeper_OB_thing_GRD_rank_ChangedAt,
    SU_ID_keeper,
    OB_ID_thing,
    rank_GRD_Grade,
    rank_Metadata_GRD,
    GRD_ID_rank
)
AS
SELECT
    tie.Metadata_SU_keeper_OB_thing_GRD_rank,
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    tie.SU_ID_keeper,
    tie.OB_ID_thing,
    "GRD_rank".GRD_Grade AS rank_GRD_Grade,
    "GRD_rank".Metadata_GRD AS rank_Metadata_GRD,
    tie.GRD_ID_rank
FROM
    (
        SELECT
            t.*,
            MAX(t.SU_keeper_OB_thing_GRD_rank_ChangedAt) OVER (
                PARTITION BY
                    t.SU_ID_keeper,
                    t.OB_ID_thing
            ) AS latestTime
        FROM
            SU_keeper_OB_thing_GRD_rank t
    ) tie
LEFT JOIN
    GRD_Grade "GRD_rank"
ON
    "GRD_rank".GRD_ID = tie.GRD_ID_rank
WHERE
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_keeper_OB_thing_GRD_rank (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_SU_keeper_OB_thing_GRD_rank,
            tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            tie.SU_ID_keeper,
            tie.OB_ID_thing,
            "GRD_rank".GRD_Grade AS rank_GRD_Grade,
            "GRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            tie.GRD_ID_rank
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.SU_keeper_OB_thing_GRD_rank_ChangedAt) OVER (
                        PARTITION BY
                            t.SU_ID_keeper,
                            t.OB_ID_thing
                    ) AS latestTime
                FROM
                    SU_keeper_OB_thing_GRD_rank t
                WHERE
                    t.SU_keeper_OB_thing_GRD_rank_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            GRD_Grade "GRD_rank"
        ON
            "GRD_rank".GRD_ID = tie.GRD_ID_rank
        WHERE
            tie.SU_keeper_OB_thing_GRD_rank_ChangedAt = tie.latestTime
    ]';
END pSU_keeper_OB_thing_GRD_rank;
/
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
            tie.Metadata_SU_keeper_OB_thing_GRD_rank,
            tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            tie.SU_ID_keeper,
            tie.OB_ID_thing,
            "GRD_rank".GRD_Grade AS rank_GRD_Grade,
            "GRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            tie.GRD_ID_rank
        FROM
            SU_keeper_OB_thing_GRD_rank tie
        LEFT JOIN
            GRD_Grade "GRD_rank"
        ON
            "GRD_rank".GRD_ID = tie.GRD_ID_rank
        WHERE
            tie.SU_keeper_OB_thing_GRD_rank_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_keeper_OB_thing_GRD_rank;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lOB_part_SU_owner (
    Metadata_OB_part_SU_owner,
    Deletable_OB_part_SU_owner,
    OB_ID_part,
    SU_ID_owner
)
AS
SELECT
    tie.Metadata_OB_part_SU_owner,
    CAST(NULL AS number(1)),
    tie.OB_ID_part,
    tie.SU_ID_owner
FROM
    OB_part_SU_owner tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pOB_part_SU_owner (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_OB_part_SU_owner,
            tie.OB_ID_part,
            tie.SU_ID_owner
        FROM
            OB_part_SU_owner tie
    ]';
END pOB_part_SU_owner;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nOB_part_SU_owner
AS
SELECT
    *
FROM
    pOB_part_SU_owner(CAST(current_timestamp AS timestamp))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_partner_SU_with (
    Metadata_SU_partner_SU_with,
    SU_partner_SU_with_ChangedAt,
    SU_ID_partner,
    SU_ID_with
)
AS
SELECT
    tie.Metadata_SU_partner_SU_with,
    tie.SU_partner_SU_with_ChangedAt,
    tie.SU_ID_partner,
    tie.SU_ID_with
FROM
    (
        SELECT
            t.*,
            MAX(t.SU_partner_SU_with_ChangedAt) OVER (PARTITION BY t.SU_ID_partner) AS latestSU_ID_partner,
            MAX(t.SU_partner_SU_with_ChangedAt) OVER (PARTITION BY t.SU_ID_with) AS latestSU_ID_with
        FROM
            SU_partner_SU_with t
    ) tie
WHERE
    tie.SU_partner_SU_with_ChangedAt = tie.latestSU_ID_partner
AND
    tie.SU_partner_SU_with_ChangedAt = tie.latestSU_ID_with
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_partner_SU_with (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_SU_partner_SU_with,
            tie.SU_partner_SU_with_ChangedAt,
            tie.SU_ID_partner,
            tie.SU_ID_with
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.SU_partner_SU_with_ChangedAt) OVER (PARTITION BY t.SU_ID_partner) AS latestSU_ID_partner,
                    MAX(t.SU_partner_SU_with_ChangedAt) OVER (PARTITION BY t.SU_ID_with) AS latestSU_ID_with
                FROM
                    SU_partner_SU_with t
                WHERE
                    t.SU_partner_SU_with_ChangedAt <= changingTimepoint
            ) tie
        WHERE
            tie.SU_partner_SU_with_ChangedAt = tie.latestSU_ID_partner
        AND
            tie.SU_partner_SU_with_ChangedAt = tie.latestSU_ID_with
    ]';
END pSU_partner_SU_with;
/
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
            tie.Metadata_SU_partner_SU_with,
            tie.SU_partner_SU_with_ChangedAt,
            tie.SU_ID_partner,
            tie.SU_ID_with
        FROM
            SU_partner_SU_with tie
        WHERE
            tie.SU_partner_SU_with_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_partner_SU_with;
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
-- ip_EV_QTY_Event_Quantity states a value of EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_QTY_Event_Quantity (
    p_owner IN EV_QTY_Event_Quantity.EV_QTY_EV_ID%TYPE,
    p_value IN EV_QTY_Event_Quantity.EV_QTY_Event_Quantity%TYPE,
    p_metadata IN EV_QTY_Event_Quantity.Metadata_EV_QTY%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN EV_QTY_Event_Quantity.EV_QTY_Event_Quantity%TYPE,
        b IN EV_QTY_Event_Quantity.EV_QTY_Event_Quantity%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_QTY_Event_Quantity
        FROM
            EV_QTY_Event_Quantity x
        WHERE
            x.EV_QTY_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_QTY_Event_Quantity, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_QTY_Event_Quantity for: ' || p_owner);
    END LOOP;
    INSERT INTO EV_QTY_Event_Quantity (
        Metadata_EV_QTY,
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_QTY_Event_Quantity;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_PLC_Event_Place states a value of EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_PLC_Event_Place (
    p_owner IN EV_PLC_Event_Place.EV_PLC_EV_ID%TYPE,
    p_changing IN EV_PLC_Event_Place.EV_PLC_ChangedAt%TYPE,
    p_value IN EV_PLC_Event_Place.EV_PLC_Event_Place%TYPE,
    p_metadata IN EV_PLC_Event_Place.Metadata_EV_PLC%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN EV_PLC_Event_Place.EV_PLC_Event_Place%TYPE,
        b IN EV_PLC_Event_Place.EV_PLC_Event_Place%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.EV_PLC_Event_Place
        FROM
            EV_PLC_Event_Place x
        WHERE
            x.EV_PLC_EV_ID = p_owner
        AND
            x.EV_PLC_ChangedAt = p_changing
    ) LOOP
        IF same(r.EV_PLC_Event_Place, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_PLC_Event_Place for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    FOR r IN (
        SELECT
            p.EV_PLC_Event_Place
        FROM
            EV_PLC_Event_Place p
        WHERE
            p.EV_PLC_EV_ID = p_owner
        AND
            p.EV_PLC_ChangedAt < p_changing
        ORDER BY
            p.EV_PLC_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.EV_PLC_Event_Place, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in EV_PLC_Event_Place for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.EV_PLC_Event_Place
        FROM
            EV_PLC_Event_Place f
        WHERE
            f.EV_PLC_EV_ID = p_owner
        AND
            f.EV_PLC_ChangedAt > p_changing
        ORDER BY
            f.EV_PLC_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.EV_PLC_Event_Place, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in EV_PLC_Event_Place for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    INSERT INTO EV_PLC_Event_Place (
        Metadata_EV_PLC,
        EV_PLC_EV_ID,
        EV_PLC_ChangedAt,
        EV_PLC_Event_Place
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_EV_PLC_Event_Place;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_NAM_Subject_Name states a value of SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_NAM_Subject_Name (
    p_owner IN SU_NAM_Subject_Name.SU_NAM_SU_ID%TYPE,
    p_value IN SU_NAM_Subject_Name.SU_NAM_Subject_Name%TYPE,
    p_metadata IN SU_NAM_Subject_Name.Metadata_SU_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_NAM_Subject_Name.SU_NAM_Subject_Name%TYPE,
        b IN SU_NAM_Subject_Name.SU_NAM_Subject_Name%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.SU_NAM_Subject_Name
        FROM
            SU_NAM_Subject_Name x
        WHERE
            x.SU_NAM_SU_ID = p_owner
    ) LOOP
        IF same(r.SU_NAM_Subject_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NAM_Subject_Name for: ' || p_owner);
    END LOOP;
    INSERT INTO SU_NAM_Subject_Name (
        Metadata_SU_NAM,
        SU_NAM_SU_ID,
        SU_NAM_Subject_Name
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_SU_NAM_Subject_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_COD_Subject_Code states a value of SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_COD_Subject_Code (
    p_owner IN SU_COD_Subject_Code.SU_COD_SU_ID%TYPE,
    p_value IN SU_COD_Subject_Code.SU_COD_Subject_Code%TYPE,
    p_metadata IN SU_COD_Subject_Code.Metadata_SU_COD%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_COD_Subject_Code.SU_COD_Subject_Code%TYPE,
        b IN SU_COD_Subject_Code.SU_COD_Subject_Code%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.SU_COD_Subject_Code
        FROM
            SU_COD_Subject_Code x
        WHERE
            x.SU_COD_SU_ID = p_owner
    ) LOOP
        IF same(r.SU_COD_Subject_Code, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_COD_Subject_Code for: ' || p_owner);
    END LOOP;
    INSERT INTO SU_COD_Subject_Code (
        Metadata_SU_COD,
        SU_COD_SU_ID,
        SU_COD_Subject_Code
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_SU_COD_Subject_Code;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_GRD_Subject_Grade states a value of SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_GRD_Subject_Grade (
    p_owner IN SU_GRD_Subject_Grade.SU_GRD_SU_ID%TYPE,
    p_value IN SU_GRD_Subject_Grade.SU_GRD_GRD_ID%TYPE,
    p_metadata IN SU_GRD_Subject_Grade.Metadata_SU_GRD%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_GRD_Subject_Grade.SU_GRD_GRD_ID%TYPE,
        b IN SU_GRD_Subject_Grade.SU_GRD_GRD_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.SU_GRD_GRD_ID
        FROM
            SU_GRD_Subject_Grade x
        WHERE
            x.SU_GRD_SU_ID = p_owner
    ) LOOP
        IF same(r.SU_GRD_GRD_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_GRD_Subject_Grade for: ' || p_owner);
    END LOOP;
    INSERT INTO SU_GRD_Subject_Grade (
        Metadata_SU_GRD,
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_SU_GRD_Subject_Grade;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_NOT_Subject_Note states a value of SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_NOT_Subject_Note (
    p_owner IN SU_NOT_Subject_Note.SU_NOT_SU_ID%TYPE,
    p_value IN SU_NOT_Subject_Note.SU_NOT_Subject_Note%TYPE,
    p_metadata IN SU_NOT_Subject_Note.Metadata_SU_NOT%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_NOT_Subject_Note.SU_NOT_Subject_Note%TYPE,
        b IN SU_NOT_Subject_Note.SU_NOT_Subject_Note%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN DBMS_LOB.COMPARE(a, b) = 0;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.SU_NOT_Subject_Note
        FROM
            SU_NOT_Subject_Note x
        WHERE
            x.SU_NOT_SU_ID = p_owner
    ) LOOP
        IF same(r.SU_NOT_Subject_Note, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NOT_Subject_Note for: ' || p_owner);
    END LOOP;
    INSERT INTO SU_NOT_Subject_Note (
        Metadata_SU_NOT,
        SU_NOT_SU_ID,
        SU_NOT_Subject_Note
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_SU_NOT_Subject_Note;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TTL_Subject_Title states a value of SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TTL_Subject_Title (
    p_owner IN SU_TTL_Subject_Title.SU_TTL_SU_ID%TYPE,
    p_changing IN SU_TTL_Subject_Title.SU_TTL_ChangedAt%TYPE,
    p_value IN SU_TTL_Subject_Title.SU_TTL_Subject_Title%TYPE,
    p_metadata IN SU_TTL_Subject_Title.Metadata_SU_TTL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_TTL_Subject_Title.SU_TTL_Subject_Title%TYPE,
        b IN SU_TTL_Subject_Title.SU_TTL_Subject_Title%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_TTL_Subject_Title
        FROM
            SU_TTL_Subject_Title x
        WHERE
            x.SU_TTL_SU_ID = p_owner
        AND
            x.SU_TTL_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_TTL_Subject_Title, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TTL_Subject_Title for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO SU_TTL_Subject_Title (
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_ChangedAt,
        SU_TTL_Subject_Title
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_TTL_Subject_Title;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_STA_Subject_State states a value of SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_STA_Subject_State (
    p_owner IN SU_STA_Subject_State.SU_STA_SU_ID%TYPE,
    p_changing IN SU_STA_Subject_State.SU_STA_ChangedAt%TYPE,
    p_value IN SU_STA_Subject_State.SU_STA_Subject_State%TYPE,
    p_metadata IN SU_STA_Subject_State.Metadata_SU_STA%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_STA_Subject_State.SU_STA_Subject_State%TYPE,
        b IN SU_STA_Subject_State.SU_STA_Subject_State%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_STA_Subject_State
        FROM
            SU_STA_Subject_State x
        WHERE
            x.SU_STA_SU_ID = p_owner
        AND
            x.SU_STA_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_STA_Subject_State, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_STA_Subject_State for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    FOR r IN (
        SELECT
            p.SU_STA_Subject_State
        FROM
            SU_STA_Subject_State p
        WHERE
            p.SU_STA_SU_ID = p_owner
        AND
            p.SU_STA_ChangedAt < p_changing
        ORDER BY
            p.SU_STA_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_STA_Subject_State, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in SU_STA_Subject_State for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.SU_STA_Subject_State
        FROM
            SU_STA_Subject_State f
        WHERE
            f.SU_STA_SU_ID = p_owner
        AND
            f.SU_STA_ChangedAt > p_changing
        ORDER BY
            f.SU_STA_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_STA_Subject_State, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in SU_STA_Subject_State for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    INSERT INTO SU_STA_Subject_State (
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_STA_Subject_State;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_LBL_Subject_Label states a value of SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_LBL_Subject_Label (
    p_owner IN SU_LBL_Subject_Label.SU_LBL_SU_ID%TYPE,
    p_changing IN SU_LBL_Subject_Label.SU_LBL_ChangedAt%TYPE,
    p_value IN SU_LBL_Subject_Label.SU_LBL_Subject_Label%TYPE,
    p_metadata IN SU_LBL_Subject_Label.Metadata_SU_LBL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_LBL_Subject_Label.SU_LBL_Subject_Label%TYPE,
        b IN SU_LBL_Subject_Label.SU_LBL_Subject_Label%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_LBL_Subject_Label
        FROM
            SU_LBL_Subject_Label x
        WHERE
            x.SU_LBL_SU_ID = p_owner
        AND
            x.SU_LBL_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_LBL_Subject_Label, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LBL_Subject_Label for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.SU_LBL_Subject_Label
        FROM
            SU_LBL_Subject_Label p
        WHERE
            p.SU_LBL_SU_ID = p_owner
        AND
            p.SU_LBL_ChangedAt < p_changing
        ORDER BY
            p.SU_LBL_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_LBL_Subject_Label, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.SU_LBL_ChangedAt,
            f.SU_LBL_Subject_Label
        FROM
            SU_LBL_Subject_Label f
        WHERE
            f.SU_LBL_SU_ID = p_owner
        AND
            f.SU_LBL_ChangedAt > p_changing
        ORDER BY
            f.SU_LBL_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_LBL_Subject_Label, p_value) THEN
            DELETE FROM
                SU_LBL_Subject_Label
            WHERE
                SU_LBL_SU_ID = p_owner
            AND
                SU_LBL_ChangedAt = r.SU_LBL_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO SU_LBL_Subject_Label (
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_LBL_Subject_Label;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TAG_Subject_Tag states a value of SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TAG_Subject_Tag (
    p_owner IN SU_TAG_Subject_Tag.SU_TAG_SU_ID%TYPE,
    p_changing IN SU_TAG_Subject_Tag.SU_TAG_ChangedAt%TYPE,
    p_value IN SU_TAG_Subject_Tag.SU_TAG_Subject_Tag%TYPE,
    p_metadata IN SU_TAG_Subject_Tag.Metadata_SU_TAG%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_TAG_Subject_Tag.SU_TAG_Subject_Tag%TYPE,
        b IN SU_TAG_Subject_Tag.SU_TAG_Subject_Tag%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_TAG_Subject_Tag
        FROM
            SU_TAG_Subject_Tag x
        WHERE
            x.SU_TAG_SU_ID = p_owner
        AND
            x.SU_TAG_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_TAG_Subject_Tag, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TAG_Subject_Tag for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.SU_TAG_Subject_Tag
        FROM
            SU_TAG_Subject_Tag p
        WHERE
            p.SU_TAG_SU_ID = p_owner
        AND
            p.SU_TAG_ChangedAt < p_changing
        ORDER BY
            p.SU_TAG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_TAG_Subject_Tag, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.SU_TAG_ChangedAt,
            f.SU_TAG_Subject_Tag
        FROM
            SU_TAG_Subject_Tag f
        WHERE
            f.SU_TAG_SU_ID = p_owner
        AND
            f.SU_TAG_ChangedAt > p_changing
        ORDER BY
            f.SU_TAG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_TAG_Subject_Tag, p_value) THEN
            DELETE FROM
                SU_TAG_Subject_Tag
            WHERE
                SU_TAG_SU_ID = p_owner
            AND
                SU_TAG_ChangedAt = r.SU_TAG_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO SU_TAG_Subject_Tag (
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_ChangedAt,
        SU_TAG_Subject_Tag
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_TAG_Subject_Tag;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_LVL_Subject_Level states a value of SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_LVL_Subject_Level (
    p_owner IN SU_LVL_Subject_Level.SU_LVL_SU_ID%TYPE,
    p_changing IN SU_LVL_Subject_Level.SU_LVL_ChangedAt%TYPE,
    p_value IN SU_LVL_Subject_Level.SU_LVL_GRD_ID%TYPE,
    p_metadata IN SU_LVL_Subject_Level.Metadata_SU_LVL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_LVL_Subject_Level.SU_LVL_GRD_ID%TYPE,
        b IN SU_LVL_Subject_Level.SU_LVL_GRD_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_LVL_GRD_ID
        FROM
            SU_LVL_Subject_Level x
        WHERE
            x.SU_LVL_SU_ID = p_owner
        AND
            x.SU_LVL_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_LVL_GRD_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LVL_Subject_Level for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO SU_LVL_Subject_Level (
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_ChangedAt,
        SU_LVL_GRD_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_LVL_Subject_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TXT_Subject_Text states a value of SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TXT_Subject_Text (
    p_owner IN SU_TXT_Subject_Text.SU_TXT_SU_ID%TYPE,
    p_changing IN SU_TXT_Subject_Text.SU_TXT_ChangedAt%TYPE,
    p_value IN SU_TXT_Subject_Text.SU_TXT_Subject_Text%TYPE,
    p_metadata IN SU_TXT_Subject_Text.Metadata_SU_TXT%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_TXT_Subject_Text.SU_TXT_Subject_Text%TYPE,
        b IN SU_TXT_Subject_Text.SU_TXT_Subject_Text%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN DBMS_LOB.COMPARE(a, b) = 0;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_TXT_Subject_Text
        FROM
            SU_TXT_Subject_Text x
        WHERE
            x.SU_TXT_SU_ID = p_owner
        AND
            x.SU_TXT_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_TXT_Subject_Text, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TXT_Subject_Text for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO SU_TXT_Subject_Text (
        Metadata_SU_TXT,
        SU_TXT_SU_ID,
        SU_TXT_ChangedAt,
        SU_TXT_Subject_Text
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_TXT_Subject_Text;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_ASR_Subject_Assessment states a value of SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_ASR_Subject_Assessment (
    p_owner IN SU_ASR_Subject_Assessment.SU_ASR_SU_ID%TYPE,
    p_changing IN SU_ASR_Subject_Assessment.SU_ASR_ChangedAt%TYPE,
    p_value IN SU_ASR_Subject_Assessment.SU_ASR_Subject_Assessment%TYPE,
    p_metadata IN SU_ASR_Subject_Assessment.Metadata_SU_ASR%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_ASR_Subject_Assessment.SU_ASR_Subject_Assessment%TYPE,
        b IN SU_ASR_Subject_Assessment.SU_ASR_Subject_Assessment%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_ASR_Subject_Assessment
        FROM
            SU_ASR_Subject_Assessment x
        WHERE
            x.SU_ASR_SU_ID = p_owner
        AND
            x.SU_ASR_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_ASR_Subject_Assessment, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ASR_Subject_Assessment for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO SU_ASR_Subject_Assessment (
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_ChangedAt,
        SU_ASR_Subject_Assessment
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_ASR_Subject_Assessment;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_ERS_Subject_Erasable states a value of SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_ERS_Subject_Erasable (
    p_owner IN SU_ERS_Subject_Erasable.SU_ERS_SU_ID%TYPE,
    p_changing IN SU_ERS_Subject_Erasable.SU_ERS_ChangedAt%TYPE,
    p_value IN SU_ERS_Subject_Erasable.SU_ERS_Subject_Erasable%TYPE,
    p_metadata IN SU_ERS_Subject_Erasable.Metadata_SU_ERS%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_ERS_Subject_Erasable.SU_ERS_Subject_Erasable%TYPE,
        b IN SU_ERS_Subject_Erasable.SU_ERS_Subject_Erasable%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_ERS_Subject_Erasable
        FROM
            SU_ERS_Subject_Erasable x
        WHERE
            x.SU_ERS_SU_ID = p_owner
        AND
            x.SU_ERS_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_ERS_Subject_Erasable, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ERS_Subject_Erasable for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO SU_ERS_Subject_Erasable (
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_ChangedAt,
        SU_ERS_Subject_Erasable
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_ERS_Subject_Erasable;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_OB_NAM_Object_Name states a value of OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_OB_NAM_Object_Name (
    p_owner IN OB_NAM_Object_Name.OB_NAM_OB_ID%TYPE,
    p_value IN OB_NAM_Object_Name.OB_NAM_Object_Name%TYPE,
    p_metadata IN OB_NAM_Object_Name.Metadata_OB_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN OB_NAM_Object_Name.OB_NAM_Object_Name%TYPE,
        b IN OB_NAM_Object_Name.OB_NAM_Object_Name%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.OB_NAM_Object_Name
        FROM
            OB_NAM_Object_Name x
        WHERE
            x.OB_NAM_OB_ID = p_owner
    ) LOOP
        IF same(r.OB_NAM_Object_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_NAM_Object_Name for: ' || p_owner);
    END LOOP;
    INSERT INTO OB_NAM_Object_Name (
        Metadata_OB_NAM,
        OB_NAM_OB_ID,
        OB_NAM_Object_Name
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_OB_NAM_Object_Name;
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
            p_metadata => COALESCE(:NEW.Metadata_SU_NAM, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_COD_Subject_Code IS NOT NULL THEN
        ip_SU_COD_Subject_Code(
            p_owner => COALESCE(:NEW.SU_COD_SU_ID, v_id),
            p_value => :NEW.SU_COD_Subject_Code,
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
            p_metadata => COALESCE(:NEW.Metadata_SU_GRD, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_NOT_Subject_Note IS NOT NULL THEN
        ip_SU_NOT_Subject_Note(
            p_owner => COALESCE(:NEW.SU_NOT_SU_ID, v_id),
            p_value => :NEW.SU_NOT_Subject_Note,
            p_metadata => COALESCE(:NEW.Metadata_SU_NOT, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TTL_Subject_Title IS NOT NULL THEN
        ip_SU_TTL_Subject_Title(
            p_owner => COALESCE(:NEW.SU_TTL_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_TTL_ChangedAt, v_now),
            p_value => :NEW.SU_TTL_Subject_Title,
            p_metadata => COALESCE(:NEW.Metadata_SU_TTL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_STA_Subject_State IS NOT NULL THEN
        ip_SU_STA_Subject_State(
            p_owner => COALESCE(:NEW.SU_STA_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_STA_ChangedAt, v_now),
            p_value => :NEW.SU_STA_Subject_State,
            p_metadata => COALESCE(:NEW.Metadata_SU_STA, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_LBL_Subject_Label IS NOT NULL THEN
        ip_SU_LBL_Subject_Label(
            p_owner => COALESCE(:NEW.SU_LBL_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_LBL_ChangedAt, v_now),
            p_value => :NEW.SU_LBL_Subject_Label,
            p_metadata => COALESCE(:NEW.Metadata_SU_LBL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TAG_Subject_Tag IS NOT NULL THEN
        ip_SU_TAG_Subject_Tag(
            p_owner => COALESCE(:NEW.SU_TAG_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_TAG_ChangedAt, v_now),
            p_value => :NEW.SU_TAG_Subject_Tag,
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
            p_changing => COALESCE(:NEW.SU_LVL_ChangedAt, v_now),
            p_value => v_LVL,
            p_metadata => COALESCE(:NEW.Metadata_SU_LVL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TXT_Subject_Text IS NOT NULL THEN
        ip_SU_TXT_Subject_Text(
            p_owner => COALESCE(:NEW.SU_TXT_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_TXT_ChangedAt, v_now),
            p_value => :NEW.SU_TXT_Subject_Text,
            p_metadata => COALESCE(:NEW.Metadata_SU_TXT, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_ASR_Subject_Assessment IS NOT NULL THEN
        ip_SU_ASR_Subject_Assessment(
            p_owner => COALESCE(:NEW.SU_ASR_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_ASR_ChangedAt, v_now),
            p_value => :NEW.SU_ASR_Subject_Assessment,
            p_metadata => COALESCE(:NEW.Metadata_SU_ASR, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_ERS_Subject_Erasable IS NOT NULL THEN
        ip_SU_ERS_Subject_Erasable(
            p_owner => COALESCE(:NEW.SU_ERS_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_ERS_ChangedAt, v_now),
            p_value => :NEW.SU_ERS_Subject_Erasable,
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
    v_GRD number(5);
    v_LVL number(5);
BEGIN
    IF (:NEW.SU_ID <> :OLD.SU_ID
        OR (:NEW.SU_ID IS NULL AND :OLD.SU_ID IS NOT NULL)
        OR (:NEW.SU_ID IS NOT NULL AND :OLD.SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_NAM_SU_ID <> :OLD.SU_NAM_SU_ID
        OR (:NEW.SU_NAM_SU_ID IS NULL AND :OLD.SU_NAM_SU_ID IS NOT NULL)
        OR (:NEW.SU_NAM_SU_ID IS NOT NULL AND :OLD.SU_NAM_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_NAM_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_NAM_Subject_Name <> :OLD.SU_NAM_Subject_Name
        OR (:NEW.SU_NAM_Subject_Name IS NULL AND :OLD.SU_NAM_Subject_Name IS NOT NULL)
        OR (:NEW.SU_NAM_Subject_Name IS NOT NULL AND :OLD.SU_NAM_Subject_Name IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_NAM_Subject_Name IS NOT NULL THEN
            ip_SU_NAM_Subject_Name(
                p_owner => COALESCE(:NEW.SU_NAM_SU_ID, :NEW.SU_ID),
                p_value => :NEW.SU_NAM_Subject_Name,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_NAM = :OLD.Metadata_SU_NAM
                            OR (:NEW.Metadata_SU_NAM IS NULL AND :OLD.Metadata_SU_NAM IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_NAM
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_SU_NAM = 1
    AND :OLD.SU_NAM_Subject_Name IS NOT NULL
    AND :NEW.SU_NAM_Subject_Name IS NULL
    THEN
        INSERT INTO SU_NAM_Subject_Name_Deleted (
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name,
            Metadata_SU_NAM,
            SU_NAM_Deleted
        )
        SELECT
            x.SU_NAM_SU_ID,
            x.SU_NAM_Subject_Name,
            x.Metadata_SU_NAM,
            v_now
        FROM
            SU_NAM_Subject_Name x
        WHERE
            x.SU_NAM_SU_ID = :OLD.SU_ID;
        DELETE FROM
            SU_NAM_Subject_Name
        WHERE
            SU_NAM_SU_ID = :OLD.SU_ID;
    END IF;
    IF (:NEW.SU_COD_SU_ID <> :OLD.SU_COD_SU_ID
        OR (:NEW.SU_COD_SU_ID IS NULL AND :OLD.SU_COD_SU_ID IS NOT NULL)
        OR (:NEW.SU_COD_SU_ID IS NOT NULL AND :OLD.SU_COD_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_COD_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_COD_Subject_Code <> :OLD.SU_COD_Subject_Code
        OR (:NEW.SU_COD_Subject_Code IS NULL AND :OLD.SU_COD_Subject_Code IS NOT NULL)
        OR (:NEW.SU_COD_Subject_Code IS NOT NULL AND :OLD.SU_COD_Subject_Code IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_COD_Subject_Code IS NOT NULL THEN
            ip_SU_COD_Subject_Code(
                p_owner => COALESCE(:NEW.SU_COD_SU_ID, :NEW.SU_ID),
                p_value => :NEW.SU_COD_Subject_Code,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_COD = :OLD.Metadata_SU_COD
                            OR (:NEW.Metadata_SU_COD IS NULL AND :OLD.Metadata_SU_COD IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_COD
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_GRD_SU_ID <> :OLD.SU_GRD_SU_ID
        OR (:NEW.SU_GRD_SU_ID IS NULL AND :OLD.SU_GRD_SU_ID IS NOT NULL)
        OR (:NEW.SU_GRD_SU_ID IS NOT NULL AND :OLD.SU_GRD_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_GRD_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_GRD_GRD_ID <> :OLD.SU_GRD_GRD_ID
        OR (:NEW.SU_GRD_GRD_ID IS NULL AND :OLD.SU_GRD_GRD_ID IS NOT NULL)
        OR (:NEW.SU_GRD_GRD_ID IS NOT NULL AND :OLD.SU_GRD_GRD_ID IS NULL))
    OR (:NEW.SU_GRD_GRD_Grade <> :OLD.SU_GRD_GRD_Grade
        OR (:NEW.SU_GRD_GRD_Grade IS NULL AND :OLD.SU_GRD_GRD_Grade IS NOT NULL)
        OR (:NEW.SU_GRD_GRD_Grade IS NOT NULL AND :OLD.SU_GRD_GRD_Grade IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_GRD := :NEW.SU_GRD_GRD_ID;
        IF (v_GRD = :OLD.SU_GRD_GRD_ID OR (v_GRD IS NULL AND :OLD.SU_GRD_GRD_ID IS NULL))
        AND :NEW.SU_GRD_GRD_Grade IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF v_GRD IS NOT NULL AND (
            :OLD.SU_GRD_GRD_ID IS NULL OR
            :OLD.SU_GRD_GRD_ID <> v_GRD
        ) THEN
            ip_SU_GRD_Subject_Grade(
                p_owner => COALESCE(:NEW.SU_GRD_SU_ID, :NEW.SU_ID),
                p_value => v_GRD,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_GRD = :OLD.Metadata_SU_GRD
                            OR (:NEW.Metadata_SU_GRD IS NULL AND :OLD.Metadata_SU_GRD IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_GRD
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_NOT_SU_ID <> :OLD.SU_NOT_SU_ID
        OR (:NEW.SU_NOT_SU_ID IS NULL AND :OLD.SU_NOT_SU_ID IS NOT NULL)
        OR (:NEW.SU_NOT_SU_ID IS NOT NULL AND :OLD.SU_NOT_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_NOT_SU_ID is not updatable.');
    END IF;
    IF (DBMS_LOB.COMPARE(:NEW.SU_NOT_Subject_Note, :OLD.SU_NOT_Subject_Note) <> 0
        OR (:NEW.SU_NOT_Subject_Note IS NULL AND :OLD.SU_NOT_Subject_Note IS NOT NULL)
        OR (:NEW.SU_NOT_Subject_Note IS NOT NULL AND :OLD.SU_NOT_Subject_Note IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_NOT_Subject_Note IS NOT NULL THEN
            ip_SU_NOT_Subject_Note(
                p_owner => COALESCE(:NEW.SU_NOT_SU_ID, :NEW.SU_ID),
                p_value => :NEW.SU_NOT_Subject_Note,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_NOT = :OLD.Metadata_SU_NOT
                            OR (:NEW.Metadata_SU_NOT IS NULL AND :OLD.Metadata_SU_NOT IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_NOT
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_TTL_SU_ID <> :OLD.SU_TTL_SU_ID
        OR (:NEW.SU_TTL_SU_ID IS NULL AND :OLD.SU_TTL_SU_ID IS NOT NULL)
        OR (:NEW.SU_TTL_SU_ID IS NOT NULL AND :OLD.SU_TTL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TTL_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_TTL_Subject_Title <> :OLD.SU_TTL_Subject_Title
        OR (:NEW.SU_TTL_Subject_Title IS NULL AND :OLD.SU_TTL_Subject_Title IS NOT NULL)
        OR (:NEW.SU_TTL_Subject_Title IS NOT NULL AND :OLD.SU_TTL_Subject_Title IS NULL))
    OR (:NEW.SU_TTL_ChangedAt <> :OLD.SU_TTL_ChangedAt
        OR (:NEW.SU_TTL_ChangedAt IS NULL AND :OLD.SU_TTL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TTL_ChangedAt IS NOT NULL AND :OLD.SU_TTL_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_TTL_Subject_Title IS NOT NULL THEN
            ip_SU_TTL_Subject_Title(
                p_owner => COALESCE(:NEW.SU_TTL_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_TTL_ChangedAt <> :OLD.SU_TTL_ChangedAt
                        OR (:NEW.SU_TTL_ChangedAt IS NULL AND :OLD.SU_TTL_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_TTL_ChangedAt IS NOT NULL AND :OLD.SU_TTL_ChangedAt IS NULL))
                    THEN :NEW.SU_TTL_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_TTL_Subject_Title,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_TTL = :OLD.Metadata_SU_TTL
                            OR (:NEW.Metadata_SU_TTL IS NULL AND :OLD.Metadata_SU_TTL IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_TTL
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_STA_SU_ID <> :OLD.SU_STA_SU_ID
        OR (:NEW.SU_STA_SU_ID IS NULL AND :OLD.SU_STA_SU_ID IS NOT NULL)
        OR (:NEW.SU_STA_SU_ID IS NOT NULL AND :OLD.SU_STA_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_STA_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_STA_Subject_State <> :OLD.SU_STA_Subject_State
        OR (:NEW.SU_STA_Subject_State IS NULL AND :OLD.SU_STA_Subject_State IS NOT NULL)
        OR (:NEW.SU_STA_Subject_State IS NOT NULL AND :OLD.SU_STA_Subject_State IS NULL))
    OR (:NEW.SU_STA_ChangedAt <> :OLD.SU_STA_ChangedAt
        OR (:NEW.SU_STA_ChangedAt IS NULL AND :OLD.SU_STA_ChangedAt IS NOT NULL)
        OR (:NEW.SU_STA_ChangedAt IS NOT NULL AND :OLD.SU_STA_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_STA_Subject_State IS NOT NULL THEN
            ip_SU_STA_Subject_State(
                p_owner => COALESCE(:NEW.SU_STA_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_STA_ChangedAt <> :OLD.SU_STA_ChangedAt
                        OR (:NEW.SU_STA_ChangedAt IS NULL AND :OLD.SU_STA_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_STA_ChangedAt IS NOT NULL AND :OLD.SU_STA_ChangedAt IS NULL))
                    THEN :NEW.SU_STA_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_STA_Subject_State,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_STA = :OLD.Metadata_SU_STA
                            OR (:NEW.Metadata_SU_STA IS NULL AND :OLD.Metadata_SU_STA IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_STA
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_LBL_SU_ID <> :OLD.SU_LBL_SU_ID
        OR (:NEW.SU_LBL_SU_ID IS NULL AND :OLD.SU_LBL_SU_ID IS NOT NULL)
        OR (:NEW.SU_LBL_SU_ID IS NOT NULL AND :OLD.SU_LBL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_LBL_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_LBL_Subject_Label <> :OLD.SU_LBL_Subject_Label
        OR (:NEW.SU_LBL_Subject_Label IS NULL AND :OLD.SU_LBL_Subject_Label IS NOT NULL)
        OR (:NEW.SU_LBL_Subject_Label IS NOT NULL AND :OLD.SU_LBL_Subject_Label IS NULL))
    OR (:NEW.SU_LBL_ChangedAt <> :OLD.SU_LBL_ChangedAt
        OR (:NEW.SU_LBL_ChangedAt IS NULL AND :OLD.SU_LBL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_LBL_ChangedAt IS NOT NULL AND :OLD.SU_LBL_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_LBL_Subject_Label IS NOT NULL THEN
            ip_SU_LBL_Subject_Label(
                p_owner => COALESCE(:NEW.SU_LBL_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_LBL_ChangedAt <> :OLD.SU_LBL_ChangedAt
                        OR (:NEW.SU_LBL_ChangedAt IS NULL AND :OLD.SU_LBL_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_LBL_ChangedAt IS NOT NULL AND :OLD.SU_LBL_ChangedAt IS NULL))
                    THEN :NEW.SU_LBL_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_LBL_Subject_Label,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_LBL = :OLD.Metadata_SU_LBL
                            OR (:NEW.Metadata_SU_LBL IS NULL AND :OLD.Metadata_SU_LBL IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_LBL
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_TAG_SU_ID <> :OLD.SU_TAG_SU_ID
        OR (:NEW.SU_TAG_SU_ID IS NULL AND :OLD.SU_TAG_SU_ID IS NOT NULL)
        OR (:NEW.SU_TAG_SU_ID IS NOT NULL AND :OLD.SU_TAG_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TAG_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_TAG_Subject_Tag <> :OLD.SU_TAG_Subject_Tag
        OR (:NEW.SU_TAG_Subject_Tag IS NULL AND :OLD.SU_TAG_Subject_Tag IS NOT NULL)
        OR (:NEW.SU_TAG_Subject_Tag IS NOT NULL AND :OLD.SU_TAG_Subject_Tag IS NULL))
    OR (:NEW.SU_TAG_ChangedAt <> :OLD.SU_TAG_ChangedAt
        OR (:NEW.SU_TAG_ChangedAt IS NULL AND :OLD.SU_TAG_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TAG_ChangedAt IS NOT NULL AND :OLD.SU_TAG_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_TAG_Subject_Tag IS NOT NULL THEN
            ip_SU_TAG_Subject_Tag(
                p_owner => COALESCE(:NEW.SU_TAG_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_TAG_ChangedAt <> :OLD.SU_TAG_ChangedAt
                        OR (:NEW.SU_TAG_ChangedAt IS NULL AND :OLD.SU_TAG_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_TAG_ChangedAt IS NOT NULL AND :OLD.SU_TAG_ChangedAt IS NULL))
                    THEN :NEW.SU_TAG_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_TAG_Subject_Tag,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_TAG = :OLD.Metadata_SU_TAG
                            OR (:NEW.Metadata_SU_TAG IS NULL AND :OLD.Metadata_SU_TAG IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_TAG
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_LVL_SU_ID <> :OLD.SU_LVL_SU_ID
        OR (:NEW.SU_LVL_SU_ID IS NULL AND :OLD.SU_LVL_SU_ID IS NOT NULL)
        OR (:NEW.SU_LVL_SU_ID IS NOT NULL AND :OLD.SU_LVL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_LVL_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_LVL_GRD_ID <> :OLD.SU_LVL_GRD_ID
        OR (:NEW.SU_LVL_GRD_ID IS NULL AND :OLD.SU_LVL_GRD_ID IS NOT NULL)
        OR (:NEW.SU_LVL_GRD_ID IS NOT NULL AND :OLD.SU_LVL_GRD_ID IS NULL))
    OR (:NEW.SU_LVL_GRD_Grade <> :OLD.SU_LVL_GRD_Grade
        OR (:NEW.SU_LVL_GRD_Grade IS NULL AND :OLD.SU_LVL_GRD_Grade IS NOT NULL)
        OR (:NEW.SU_LVL_GRD_Grade IS NOT NULL AND :OLD.SU_LVL_GRD_Grade IS NULL))
    OR (:NEW.SU_LVL_ChangedAt <> :OLD.SU_LVL_ChangedAt
        OR (:NEW.SU_LVL_ChangedAt IS NULL AND :OLD.SU_LVL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_LVL_ChangedAt IS NOT NULL AND :OLD.SU_LVL_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_LVL := :NEW.SU_LVL_GRD_ID;
        IF (v_LVL = :OLD.SU_LVL_GRD_ID OR (v_LVL IS NULL AND :OLD.SU_LVL_GRD_ID IS NULL))
        AND :NEW.SU_LVL_GRD_Grade IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF v_LVL IS NOT NULL AND (
            (:NEW.SU_LVL_ChangedAt <> :OLD.SU_LVL_ChangedAt
                OR (:NEW.SU_LVL_ChangedAt IS NULL AND :OLD.SU_LVL_ChangedAt IS NOT NULL)
                OR (:NEW.SU_LVL_ChangedAt IS NOT NULL AND :OLD.SU_LVL_ChangedAt IS NULL)) OR
            :OLD.SU_LVL_GRD_ID IS NULL OR
            :OLD.SU_LVL_GRD_ID <> v_LVL
        ) THEN
            ip_SU_LVL_Subject_Level(
                p_owner => COALESCE(:NEW.SU_LVL_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_LVL_ChangedAt <> :OLD.SU_LVL_ChangedAt
                        OR (:NEW.SU_LVL_ChangedAt IS NULL AND :OLD.SU_LVL_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_LVL_ChangedAt IS NOT NULL AND :OLD.SU_LVL_ChangedAt IS NULL))
                    THEN :NEW.SU_LVL_ChangedAt
                    ELSE v_now
                END,
                p_value => v_LVL,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_LVL = :OLD.Metadata_SU_LVL
                            OR (:NEW.Metadata_SU_LVL IS NULL AND :OLD.Metadata_SU_LVL IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_LVL
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_SU_LVL = 1
    AND :OLD.SU_LVL_GRD_ID IS NOT NULL
    AND (:NEW.SU_LVL_GRD_ID IS NULL OR :NEW.SU_LVL_GRD_Grade IS NULL)
    THEN
        INSERT INTO SU_LVL_Subject_Level_Deleted (
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt,
            Metadata_SU_LVL,
            SU_LVL_Deleted
        )
        SELECT
            x.SU_LVL_SU_ID,
            x.SU_LVL_GRD_ID,
            x.SU_LVL_ChangedAt,
            x.Metadata_SU_LVL,
            CAST(CASE WHEN :NEW.SU_LVL_ChangedAt <> :OLD.SU_LVL_ChangedAt
                    OR (:NEW.SU_LVL_ChangedAt IS NULL AND :OLD.SU_LVL_ChangedAt IS NOT NULL)
                    OR (:NEW.SU_LVL_ChangedAt IS NOT NULL AND :OLD.SU_LVL_ChangedAt IS NULL)
                THEN :NEW.SU_LVL_ChangedAt ELSE v_now END AS timestamp)
        FROM
            SU_LVL_Subject_Level x
        WHERE
            x.SU_LVL_SU_ID = :OLD.SU_ID;
        DELETE FROM
            SU_LVL_Subject_Level
        WHERE
            SU_LVL_SU_ID = :OLD.SU_ID;
    END IF;
    IF (:NEW.SU_TXT_SU_ID <> :OLD.SU_TXT_SU_ID
        OR (:NEW.SU_TXT_SU_ID IS NULL AND :OLD.SU_TXT_SU_ID IS NOT NULL)
        OR (:NEW.SU_TXT_SU_ID IS NOT NULL AND :OLD.SU_TXT_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TXT_SU_ID is not updatable.');
    END IF;
    IF (DBMS_LOB.COMPARE(:NEW.SU_TXT_Subject_Text, :OLD.SU_TXT_Subject_Text) <> 0
        OR (:NEW.SU_TXT_Subject_Text IS NULL AND :OLD.SU_TXT_Subject_Text IS NOT NULL)
        OR (:NEW.SU_TXT_Subject_Text IS NOT NULL AND :OLD.SU_TXT_Subject_Text IS NULL))
    OR (:NEW.SU_TXT_ChangedAt <> :OLD.SU_TXT_ChangedAt
        OR (:NEW.SU_TXT_ChangedAt IS NULL AND :OLD.SU_TXT_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TXT_ChangedAt IS NOT NULL AND :OLD.SU_TXT_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_TXT_Subject_Text IS NOT NULL THEN
            ip_SU_TXT_Subject_Text(
                p_owner => COALESCE(:NEW.SU_TXT_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_TXT_ChangedAt <> :OLD.SU_TXT_ChangedAt
                        OR (:NEW.SU_TXT_ChangedAt IS NULL AND :OLD.SU_TXT_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_TXT_ChangedAt IS NOT NULL AND :OLD.SU_TXT_ChangedAt IS NULL))
                    THEN :NEW.SU_TXT_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_TXT_Subject_Text,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_TXT = :OLD.Metadata_SU_TXT
                            OR (:NEW.Metadata_SU_TXT IS NULL AND :OLD.Metadata_SU_TXT IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_TXT
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_ASR_SU_ID <> :OLD.SU_ASR_SU_ID
        OR (:NEW.SU_ASR_SU_ID IS NULL AND :OLD.SU_ASR_SU_ID IS NOT NULL)
        OR (:NEW.SU_ASR_SU_ID IS NOT NULL AND :OLD.SU_ASR_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_ASR_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ASR_Subject_Assessment <> :OLD.SU_ASR_Subject_Assessment
        OR (:NEW.SU_ASR_Subject_Assessment IS NULL AND :OLD.SU_ASR_Subject_Assessment IS NOT NULL)
        OR (:NEW.SU_ASR_Subject_Assessment IS NOT NULL AND :OLD.SU_ASR_Subject_Assessment IS NULL))
    OR (:NEW.SU_ASR_ChangedAt <> :OLD.SU_ASR_ChangedAt
        OR (:NEW.SU_ASR_ChangedAt IS NULL AND :OLD.SU_ASR_ChangedAt IS NOT NULL)
        OR (:NEW.SU_ASR_ChangedAt IS NOT NULL AND :OLD.SU_ASR_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_ASR_Subject_Assessment IS NOT NULL THEN
            ip_SU_ASR_Subject_Assessment(
                p_owner => COALESCE(:NEW.SU_ASR_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_ASR_ChangedAt <> :OLD.SU_ASR_ChangedAt
                        OR (:NEW.SU_ASR_ChangedAt IS NULL AND :OLD.SU_ASR_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_ASR_ChangedAt IS NOT NULL AND :OLD.SU_ASR_ChangedAt IS NULL))
                    THEN :NEW.SU_ASR_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_ASR_Subject_Assessment,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_ASR = :OLD.Metadata_SU_ASR
                            OR (:NEW.Metadata_SU_ASR IS NULL AND :OLD.Metadata_SU_ASR IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_ASR
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_ERS_SU_ID <> :OLD.SU_ERS_SU_ID
        OR (:NEW.SU_ERS_SU_ID IS NULL AND :OLD.SU_ERS_SU_ID IS NOT NULL)
        OR (:NEW.SU_ERS_SU_ID IS NOT NULL AND :OLD.SU_ERS_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_ERS_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ERS_Subject_Erasable <> :OLD.SU_ERS_Subject_Erasable
        OR (:NEW.SU_ERS_Subject_Erasable IS NULL AND :OLD.SU_ERS_Subject_Erasable IS NOT NULL)
        OR (:NEW.SU_ERS_Subject_Erasable IS NOT NULL AND :OLD.SU_ERS_Subject_Erasable IS NULL))
    OR (:NEW.SU_ERS_ChangedAt <> :OLD.SU_ERS_ChangedAt
        OR (:NEW.SU_ERS_ChangedAt IS NULL AND :OLD.SU_ERS_ChangedAt IS NOT NULL)
        OR (:NEW.SU_ERS_ChangedAt IS NOT NULL AND :OLD.SU_ERS_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_ERS_Subject_Erasable IS NOT NULL THEN
            ip_SU_ERS_Subject_Erasable(
                p_owner => COALESCE(:NEW.SU_ERS_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_ERS_ChangedAt <> :OLD.SU_ERS_ChangedAt
                        OR (:NEW.SU_ERS_ChangedAt IS NULL AND :OLD.SU_ERS_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_ERS_ChangedAt IS NOT NULL AND :OLD.SU_ERS_ChangedAt IS NULL))
                    THEN :NEW.SU_ERS_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_ERS_Subject_Erasable,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_ERS = :OLD.Metadata_SU_ERS
                            OR (:NEW.Metadata_SU_ERS IS NULL AND :OLD.Metadata_SU_ERS IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_ERS
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_SU_ERS = 1
    AND :OLD.SU_ERS_Subject_Erasable IS NOT NULL
    AND :NEW.SU_ERS_Subject_Erasable IS NULL
    THEN
        INSERT INTO SU_ERS_Subject_Erasable_Deleted (
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt,
            Metadata_SU_ERS,
            SU_ERS_Deleted
        )
        SELECT
            x.SU_ERS_SU_ID,
            x.SU_ERS_Subject_Erasable,
            x.SU_ERS_ChangedAt,
            x.Metadata_SU_ERS,
            CAST(CASE WHEN :NEW.SU_ERS_ChangedAt <> :OLD.SU_ERS_ChangedAt
                    OR (:NEW.SU_ERS_ChangedAt IS NULL AND :OLD.SU_ERS_ChangedAt IS NOT NULL)
                    OR (:NEW.SU_ERS_ChangedAt IS NOT NULL AND :OLD.SU_ERS_ChangedAt IS NULL)
                THEN :NEW.SU_ERS_ChangedAt ELSE v_now END AS timestamp)
        FROM
            SU_ERS_Subject_Erasable x
        WHERE
            x.SU_ERS_SU_ID = :OLD.SU_ID;
        DELETE FROM
            SU_ERS_Subject_Erasable
        WHERE
            SU_ERS_SU_ID = :OLD.SU_ID;
    END IF;
END ut_lSU_Subject;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_Subject instead of DELETE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_Subject
INSTEAD OF DELETE ON lSU_Subject
FOR EACH ROW
BEGIN
    DELETE FROM
        SU_NAM_Subject_Name x
    WHERE
        x.SU_NAM_SU_ID = :OLD.SU_ID
    ;
    DELETE FROM
        SU_COD_Subject_Code x
    WHERE
        x.SU_COD_SU_ID = :OLD.SU_ID
    ;
    DELETE FROM
        SU_GRD_Subject_Grade x
    WHERE
        x.SU_GRD_SU_ID = :OLD.SU_ID
    ;
    DELETE FROM
        SU_NOT_Subject_Note x
    WHERE
        x.SU_NOT_SU_ID = :OLD.SU_ID
    ;
    DELETE FROM
        SU_TTL_Subject_Title x
    WHERE
        x.SU_TTL_SU_ID = :OLD.SU_ID
    AND
        x.SU_TTL_ChangedAt = :OLD.SU_TTL_ChangedAt
    ;
    DELETE FROM
        SU_STA_Subject_State x
    WHERE
        x.SU_STA_SU_ID = :OLD.SU_ID
    AND
        x.SU_STA_ChangedAt = :OLD.SU_STA_ChangedAt
    ;
    DELETE FROM
        SU_LBL_Subject_Label x
    WHERE
        x.SU_LBL_SU_ID = :OLD.SU_ID
    AND
        x.SU_LBL_ChangedAt = :OLD.SU_LBL_ChangedAt
    ;
    DELETE FROM
        SU_TAG_Subject_Tag x
    WHERE
        x.SU_TAG_SU_ID = :OLD.SU_ID
    AND
        x.SU_TAG_ChangedAt = :OLD.SU_TAG_ChangedAt
    ;
    DELETE FROM
        SU_LVL_Subject_Level x
    WHERE
        x.SU_LVL_SU_ID = :OLD.SU_ID
    AND
        x.SU_LVL_ChangedAt = :OLD.SU_LVL_ChangedAt
    ;
    DELETE FROM
        SU_TXT_Subject_Text x
    WHERE
        x.SU_TXT_SU_ID = :OLD.SU_ID
    AND
        x.SU_TXT_ChangedAt = :OLD.SU_TXT_ChangedAt
    ;
    DELETE FROM
        SU_ASR_Subject_Assessment x
    WHERE
        x.SU_ASR_SU_ID = :OLD.SU_ID
    AND
        x.SU_ASR_ChangedAt = :OLD.SU_ASR_ChangedAt
    ;
    DELETE FROM
        SU_ERS_Subject_Erasable x
    WHERE
        x.SU_ERS_SU_ID = :OLD.SU_ID
    AND
        x.SU_ERS_ChangedAt = :OLD.SU_ERS_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        SU_Subject a
    WHERE
        a.SU_ID = :OLD.SU_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_NAM_Subject_Name x
        WHERE
            x.SU_NAM_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_COD_Subject_Code x
        WHERE
            x.SU_COD_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_GRD_Subject_Grade x
        WHERE
            x.SU_GRD_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_NOT_Subject_Note x
        WHERE
            x.SU_NOT_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_TTL_Subject_Title x
        WHERE
            x.SU_TTL_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_STA_Subject_State x
        WHERE
            x.SU_STA_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_LBL_Subject_Label x
        WHERE
            x.SU_LBL_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_TAG_Subject_Tag x
        WHERE
            x.SU_TAG_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_LVL_Subject_Level x
        WHERE
            x.SU_LVL_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_TXT_Subject_Text x
        WHERE
            x.SU_TXT_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_ASR_Subject_Assessment x
        WHERE
            x.SU_ASR_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_ERS_Subject_Erasable x
        WHERE
            x.SU_ERS_SU_ID = a.SU_ID
    )
    ;
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
BEGIN
    IF (:NEW.OB_ID <> :OLD.OB_ID
        OR (:NEW.OB_ID IS NULL AND :OLD.OB_ID IS NOT NULL)
        OR (:NEW.OB_ID IS NOT NULL AND :OLD.OB_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID is not updatable.');
    END IF;
    IF (:NEW.OB_NAM_OB_ID <> :OLD.OB_NAM_OB_ID
        OR (:NEW.OB_NAM_OB_ID IS NULL AND :OLD.OB_NAM_OB_ID IS NOT NULL)
        OR (:NEW.OB_NAM_OB_ID IS NOT NULL AND :OLD.OB_NAM_OB_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column OB_NAM_OB_ID is not updatable.');
    END IF;
    IF (:NEW.OB_NAM_Object_Name <> :OLD.OB_NAM_Object_Name
        OR (:NEW.OB_NAM_Object_Name IS NULL AND :OLD.OB_NAM_Object_Name IS NOT NULL)
        OR (:NEW.OB_NAM_Object_Name IS NOT NULL AND :OLD.OB_NAM_Object_Name IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.OB_NAM_Object_Name IS NOT NULL THEN
            ip_OB_NAM_Object_Name(
                p_owner => COALESCE(:NEW.OB_NAM_OB_ID, :NEW.OB_ID),
                p_value => :NEW.OB_NAM_Object_Name,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_OB <> :OLD.Metadata_OB
                            OR (:NEW.Metadata_OB IS NULL AND :OLD.Metadata_OB IS NOT NULL)
                            OR (:NEW.Metadata_OB IS NOT NULL AND :OLD.Metadata_OB IS NULL))
                        AND (:NEW.Metadata_OB_NAM = :OLD.Metadata_OB_NAM
                            OR (:NEW.Metadata_OB_NAM IS NULL AND :OLD.Metadata_OB_NAM IS NULL))
                        THEN :NEW.Metadata_OB
                        ELSE :NEW.Metadata_OB_NAM
                    END, :NEW.Metadata_OB)
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
BEGIN
    DELETE FROM
        OB_NAM_Object_Name x
    WHERE
        x.OB_NAM_OB_ID = :OLD.OB_ID
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        OB_Object a
    WHERE
        a.OB_ID = :OLD.OB_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            OB_NAM_Object_Name x
        WHERE
            x.OB_NAM_OB_ID = a.OB_ID
    )
    ;
END dt_lOB_Object;
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
            p_metadata => COALESCE(:NEW.Metadata_EV_QTY, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_PLC_Event_Place IS NOT NULL THEN
        ip_EV_PLC_Event_Place(
            p_owner => COALESCE(:NEW.EV_PLC_EV_ID, v_id),
            p_changing => COALESCE(:NEW.EV_PLC_ChangedAt, v_now),
            p_value => :NEW.EV_PLC_Event_Place,
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
    IF (:NEW.EV_QTY_EV_ID <> :OLD.EV_QTY_EV_ID
        OR (:NEW.EV_QTY_EV_ID IS NULL AND :OLD.EV_QTY_EV_ID IS NOT NULL)
        OR (:NEW.EV_QTY_EV_ID IS NOT NULL AND :OLD.EV_QTY_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_QTY_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_QTY_Event_Quantity <> :OLD.EV_QTY_Event_Quantity
        OR (:NEW.EV_QTY_Event_Quantity IS NULL AND :OLD.EV_QTY_Event_Quantity IS NOT NULL)
        OR (:NEW.EV_QTY_Event_Quantity IS NOT NULL AND :OLD.EV_QTY_Event_Quantity IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_QTY_Event_Quantity IS NOT NULL THEN
            ip_EV_QTY_Event_Quantity(
                p_owner => COALESCE(:NEW.EV_QTY_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_QTY_Event_Quantity,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_QTY = :OLD.Metadata_EV_QTY
                            OR (:NEW.Metadata_EV_QTY IS NULL AND :OLD.Metadata_EV_QTY IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_QTY
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_EV_QTY = 1
    AND :OLD.EV_QTY_Event_Quantity IS NOT NULL
    AND :NEW.EV_QTY_Event_Quantity IS NULL
    THEN
        INSERT INTO EV_QTY_Event_Quantity_Deleted (
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity,
            Metadata_EV_QTY,
            EV_QTY_Deleted
        )
        SELECT
            x.EV_QTY_EV_ID,
            x.EV_QTY_Event_Quantity,
            x.Metadata_EV_QTY,
            v_now
        FROM
            EV_QTY_Event_Quantity x
        WHERE
            x.EV_QTY_EV_ID = :OLD.EV_ID;
        DELETE FROM
            EV_QTY_Event_Quantity
        WHERE
            EV_QTY_EV_ID = :OLD.EV_ID;
    END IF;
    IF (:NEW.EV_PLC_EV_ID <> :OLD.EV_PLC_EV_ID
        OR (:NEW.EV_PLC_EV_ID IS NULL AND :OLD.EV_PLC_EV_ID IS NOT NULL)
        OR (:NEW.EV_PLC_EV_ID IS NOT NULL AND :OLD.EV_PLC_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_PLC_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_PLC_Event_Place <> :OLD.EV_PLC_Event_Place
        OR (:NEW.EV_PLC_Event_Place IS NULL AND :OLD.EV_PLC_Event_Place IS NOT NULL)
        OR (:NEW.EV_PLC_Event_Place IS NOT NULL AND :OLD.EV_PLC_Event_Place IS NULL))
    OR (:NEW.EV_PLC_ChangedAt <> :OLD.EV_PLC_ChangedAt
        OR (:NEW.EV_PLC_ChangedAt IS NULL AND :OLD.EV_PLC_ChangedAt IS NOT NULL)
        OR (:NEW.EV_PLC_ChangedAt IS NOT NULL AND :OLD.EV_PLC_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_PLC_Event_Place IS NOT NULL THEN
            ip_EV_PLC_Event_Place(
                p_owner => COALESCE(:NEW.EV_PLC_EV_ID, :NEW.EV_ID),
                p_changing => CASE
                    WHEN (:NEW.EV_PLC_ChangedAt <> :OLD.EV_PLC_ChangedAt
                        OR (:NEW.EV_PLC_ChangedAt IS NULL AND :OLD.EV_PLC_ChangedAt IS NOT NULL)
                        OR (:NEW.EV_PLC_ChangedAt IS NOT NULL AND :OLD.EV_PLC_ChangedAt IS NULL))
                    THEN :NEW.EV_PLC_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.EV_PLC_Event_Place,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_PLC = :OLD.Metadata_EV_PLC
                            OR (:NEW.Metadata_EV_PLC IS NULL AND :OLD.Metadata_EV_PLC IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_PLC
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_EV_PLC = 1
    AND :OLD.EV_PLC_Event_Place IS NOT NULL
    AND :NEW.EV_PLC_Event_Place IS NULL
    THEN
        INSERT INTO EV_PLC_Event_Place_Deleted (
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt,
            Metadata_EV_PLC,
            EV_PLC_Deleted
        )
        SELECT
            x.EV_PLC_EV_ID,
            x.EV_PLC_Event_Place,
            x.EV_PLC_ChangedAt,
            x.Metadata_EV_PLC,
            CAST(CASE WHEN :NEW.EV_PLC_ChangedAt <> :OLD.EV_PLC_ChangedAt
                    OR (:NEW.EV_PLC_ChangedAt IS NULL AND :OLD.EV_PLC_ChangedAt IS NOT NULL)
                    OR (:NEW.EV_PLC_ChangedAt IS NOT NULL AND :OLD.EV_PLC_ChangedAt IS NULL)
                THEN :NEW.EV_PLC_ChangedAt ELSE v_now END AS timestamp)
        FROM
            EV_PLC_Event_Place x
        WHERE
            x.EV_PLC_EV_ID = :OLD.EV_ID;
        DELETE FROM
            EV_PLC_Event_Place
        WHERE
            EV_PLC_EV_ID = :OLD.EV_ID;
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
        EV_QTY_Event_Quantity x
    WHERE
        x.EV_QTY_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        EV_PLC_Event_Place x
    WHERE
        x.EV_PLC_EV_ID = :OLD.EV_ID
    AND
        x.EV_PLC_ChangedAt = :OLD.EV_PLC_ChangedAt
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
            EV_QTY_Event_Quantity x
        WHERE
            x.EV_QTY_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            EV_PLC_Event_Place x
        WHERE
            x.EV_PLC_EV_ID = a.EV_ID
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
-- ip_SU_holder_OB_item_GRD_grade states a row of SU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_holder_OB_item_GRD_grade (
    p_SU_holder IN SU_holder_OB_item_GRD_grade.SU_ID_holder%TYPE,
    p_OB_item IN SU_holder_OB_item_GRD_grade.OB_ID_item%TYPE,
    p_GRD_grade IN SU_holder_OB_item_GRD_grade.GRD_ID_grade%TYPE,
    p_changing IN SU_holder_OB_item_GRD_grade.SU_holder_OB_item_GRD_grade_ChangedAt%TYPE,
    p_metadata IN SU_holder_OB_item_GRD_grade.Metadata_SU_holder_OB_item_GRD_grade%TYPE
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_changing SU_holder_OB_item_GRD_grade.SU_holder_OB_item_GRD_grade_ChangedAt%TYPE;
    v_metadata SU_holder_OB_item_GRD_grade.Metadata_SU_holder_OB_item_GRD_grade%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            SU_holder_OB_item_GRD_grade x
        WHERE
            x.SU_ID_holder = p_SU_holder
        AND
            x.OB_ID_item = p_OB_item
        AND
            x.GRD_ID_grade = p_GRD_grade
        AND
            x.SU_holder_OB_item_GRD_grade_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            SU_holder_OB_item_GRD_grade x
        WHERE
            x.SU_ID_holder = p_SU_holder
        AND
            x.OB_ID_item = p_OB_item
        AND
            x.SU_holder_OB_item_GRD_grade_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_holder_OB_item_GRD_grade for: '
            || p_SU_holder
            || ', '
            || p_OB_item
            || ', '
            || v_changing
        );
    END LOOP;
    INSERT INTO SU_holder_OB_item_GRD_grade (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    )
    VALUES (
        v_metadata,
        v_changing,
        p_SU_holder,
        p_OB_item,
        p_GRD_grade
    );
END ip_SU_holder_OB_item_GRD_grade;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_holder_OB_item_GRD_grade instead of INSERT trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_holder_OB_item_GRD_grade
INSTEAD OF INSERT ON lSU_holder_OB_item_GRD_grade
FOR EACH ROW
DECLARE
    v_GRD_grade number(5);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
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
        p_changing => :NEW.SU_holder_OB_item_GRD_grade_ChangedAt,
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
    v_changed NUMBER(1);
    v_changing SU_holder_OB_item_GRD_grade.SU_holder_OB_item_GRD_grade_ChangedAt%TYPE;
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
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt <> :OLD.SU_holder_OB_item_GRD_grade_ChangedAt
        OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL)
        OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.SU_holder_OB_item_GRD_grade_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_GRD_grade := :NEW.GRD_ID_grade;
    IF (:NEW.grade_GRD_Grade <> :OLD.grade_GRD_Grade
        OR (:NEW.grade_GRD_Grade IS NULL AND :OLD.grade_GRD_Grade IS NOT NULL)
        OR (:NEW.grade_GRD_Grade IS NOT NULL AND :OLD.grade_GRD_Grade IS NULL)) THEN
        v_GRD_grade := NULL;
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
    -- values that are left as they are state nothing
    IF
        v_GRD_grade IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.SU_ID_holder <> :OLD.SU_ID_holder
                OR (:NEW.SU_ID_holder IS NULL AND :OLD.SU_ID_holder IS NOT NULL)
                OR (:NEW.SU_ID_holder IS NOT NULL AND :OLD.SU_ID_holder IS NULL))
        OR
            (:NEW.OB_ID_item <> :OLD.OB_ID_item
                OR (:NEW.OB_ID_item IS NULL AND :OLD.OB_ID_item IS NOT NULL)
                OR (:NEW.OB_ID_item IS NOT NULL AND :OLD.OB_ID_item IS NULL))
        OR
            (v_GRD_grade <> :OLD.GRD_ID_grade
                OR (v_GRD_grade IS NULL AND :OLD.GRD_ID_grade IS NOT NULL)
                OR (v_GRD_grade IS NOT NULL AND :OLD.GRD_ID_grade IS NULL))
        )
    THEN
        ip_SU_holder_OB_item_GRD_grade(
            p_SU_holder => :NEW.SU_ID_holder,
            p_OB_item => :NEW.OB_ID_item,
            p_GRD_grade => v_GRD_grade,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_SU_holder_OB_item_GRD_grade
        );
    END IF;
    -- a null in every value of a deletable tie moves what the identifiers have to the deletion table
    IF :NEW.Deletable_SU_holder_OB_item_GRD_grade = 1
    AND (:NEW.GRD_ID_grade IS NULL OR :NEW.grade_GRD_Grade IS NULL)
    THEN
        INSERT INTO SU_holder_OB_item_GRD_grade_Deleted (
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt,
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_Deleted
        )
        SELECT
            x.SU_ID_holder,
            x.OB_ID_item,
            x.GRD_ID_grade,
            x.SU_holder_OB_item_GRD_grade_ChangedAt,
            x.Metadata_SU_holder_OB_item_GRD_grade,
            CAST(v_changing AS timestamp)
        FROM
            SU_holder_OB_item_GRD_grade x
        WHERE
            x.SU_ID_holder = :OLD.SU_ID_holder
        AND
            x.OB_ID_item = :OLD.OB_ID_item
        ;
        DELETE FROM
            SU_holder_OB_item_GRD_grade
        WHERE
            SU_ID_holder = :OLD.SU_ID_holder
        AND
            OB_ID_item = :OLD.OB_ID_item
        ;
    END IF;
END ut_lSU_holder_OB_item_GRD_grade;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_holder_OB_item_GRD_grade instead of DELETE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_holder_OB_item_GRD_grade
INSTEAD OF DELETE ON lSU_holder_OB_item_GRD_grade
FOR EACH ROW
BEGIN
    DELETE FROM
        SU_holder_OB_item_GRD_grade x
    WHERE
        x.SU_holder_OB_item_GRD_grade_ChangedAt = :OLD.SU_holder_OB_item_GRD_grade_ChangedAt
    AND
        x.SU_ID_holder = :OLD.SU_ID_holder
    AND
        x.OB_ID_item = :OLD.OB_ID_item
    ;
END dt_lSU_holder_OB_item_GRD_grade;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_keeper_OB_thing_GRD_rank states a row of SU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_keeper_OB_thing_GRD_rank (
    p_SU_keeper IN SU_keeper_OB_thing_GRD_rank.SU_ID_keeper%TYPE,
    p_OB_thing IN SU_keeper_OB_thing_GRD_rank.OB_ID_thing%TYPE,
    p_GRD_rank IN SU_keeper_OB_thing_GRD_rank.GRD_ID_rank%TYPE,
    p_changing IN SU_keeper_OB_thing_GRD_rank.SU_keeper_OB_thing_GRD_rank_ChangedAt%TYPE,
    p_metadata IN SU_keeper_OB_thing_GRD_rank.Metadata_SU_keeper_OB_thing_GRD_rank%TYPE
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_changing SU_keeper_OB_thing_GRD_rank.SU_keeper_OB_thing_GRD_rank_ChangedAt%TYPE;
    v_metadata SU_keeper_OB_thing_GRD_rank.Metadata_SU_keeper_OB_thing_GRD_rank%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            SU_keeper_OB_thing_GRD_rank x
        WHERE
            x.SU_ID_keeper = p_SU_keeper
        AND
            x.OB_ID_thing = p_OB_thing
        AND
            x.GRD_ID_rank = p_GRD_rank
        AND
            x.SU_keeper_OB_thing_GRD_rank_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            SU_keeper_OB_thing_GRD_rank x
        WHERE
            x.SU_ID_keeper = p_SU_keeper
        AND
            x.OB_ID_thing = p_OB_thing
        AND
            x.SU_keeper_OB_thing_GRD_rank_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_keeper_OB_thing_GRD_rank for: '
            || p_SU_keeper
            || ', '
            || p_OB_thing
            || ', '
            || v_changing
        );
    END LOOP;
    -- what has the same values as the row before it, or as the row after it, is a restatement
    -- (an idempotent tie does not store it, and removes the row after it that the new row makes a restatement of)
    FOR r IN (
        SELECT
            p.SU_ID_keeper,
            p.OB_ID_thing,
            p.GRD_ID_rank
        FROM
            SU_keeper_OB_thing_GRD_rank p
        WHERE
            p.SU_ID_keeper = p_SU_keeper
        AND
            p.OB_ID_thing = p_OB_thing
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt < v_changing
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
    DELETE FROM
        SU_keeper_OB_thing_GRD_rank x
    WHERE
        x.SU_ID_keeper = p_SU_keeper
    AND
        x.OB_ID_thing = p_OB_thing
    AND
        x.SU_keeper_OB_thing_GRD_rank_ChangedAt = (
            SELECT
                MIN(f.SU_keeper_OB_thing_GRD_rank_ChangedAt)
            FROM
                SU_keeper_OB_thing_GRD_rank f
            WHERE
                f.SU_ID_keeper = p_SU_keeper
            AND
                f.OB_ID_thing = p_OB_thing
            AND
                f.SU_keeper_OB_thing_GRD_rank_ChangedAt > v_changing
        )
    AND
        x.SU_ID_keeper = p_SU_keeper
    AND
        x.OB_ID_thing = p_OB_thing
    AND
        x.GRD_ID_rank = p_GRD_rank
    ;
    INSERT INTO SU_keeper_OB_thing_GRD_rank (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    VALUES (
        v_metadata,
        v_changing,
        p_SU_keeper,
        p_OB_thing,
        p_GRD_rank
    );
END ip_SU_keeper_OB_thing_GRD_rank;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_keeper_OB_thing_GRD_rank
INSTEAD OF INSERT ON lSU_keeper_OB_thing_GRD_rank
FOR EACH ROW
DECLARE
    v_GRD_rank number(5);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
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
        p_changing => :NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt,
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
    v_changed NUMBER(1);
    v_changing SU_keeper_OB_thing_GRD_rank.SU_keeper_OB_thing_GRD_rank_ChangedAt%TYPE;
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
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt <> :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt
        OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL)
        OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_GRD_rank := :NEW.GRD_ID_rank;
    IF (:NEW.rank_GRD_Grade <> :OLD.rank_GRD_Grade
        OR (:NEW.rank_GRD_Grade IS NULL AND :OLD.rank_GRD_Grade IS NOT NULL)
        OR (:NEW.rank_GRD_Grade IS NOT NULL AND :OLD.rank_GRD_Grade IS NULL)) THEN
        v_GRD_rank := NULL;
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
    -- values that are left as they are state nothing
    IF
        v_GRD_rank IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.SU_ID_keeper <> :OLD.SU_ID_keeper
                OR (:NEW.SU_ID_keeper IS NULL AND :OLD.SU_ID_keeper IS NOT NULL)
                OR (:NEW.SU_ID_keeper IS NOT NULL AND :OLD.SU_ID_keeper IS NULL))
        OR
            (:NEW.OB_ID_thing <> :OLD.OB_ID_thing
                OR (:NEW.OB_ID_thing IS NULL AND :OLD.OB_ID_thing IS NOT NULL)
                OR (:NEW.OB_ID_thing IS NOT NULL AND :OLD.OB_ID_thing IS NULL))
        OR
            (v_GRD_rank <> :OLD.GRD_ID_rank
                OR (v_GRD_rank IS NULL AND :OLD.GRD_ID_rank IS NOT NULL)
                OR (v_GRD_rank IS NOT NULL AND :OLD.GRD_ID_rank IS NULL))
        )
    THEN
        ip_SU_keeper_OB_thing_GRD_rank(
            p_SU_keeper => :NEW.SU_ID_keeper,
            p_OB_thing => :NEW.OB_ID_thing,
            p_GRD_rank => v_GRD_rank,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_SU_keeper_OB_thing_GRD_rank
        );
    END IF;
END ut_lSU_keeper_OB_thing_GRD_rank;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_keeper_OB_thing_GRD_rank instead of DELETE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_keeper_OB_thing_GRD_rank
INSTEAD OF DELETE ON lSU_keeper_OB_thing_GRD_rank
FOR EACH ROW
BEGIN
    DELETE FROM
        SU_keeper_OB_thing_GRD_rank x
    WHERE
        x.SU_keeper_OB_thing_GRD_rank_ChangedAt = :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt
    AND
        x.SU_ID_keeper = :OLD.SU_ID_keeper
    AND
        x.OB_ID_thing = :OLD.OB_ID_thing
    ;
END dt_lSU_keeper_OB_thing_GRD_rank;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_OB_part_SU_owner states a row of OB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_OB_part_SU_owner (
    p_OB_part IN OB_part_SU_owner.OB_ID_part%TYPE,
    p_SU_owner IN OB_part_SU_owner.SU_ID_owner%TYPE,
    p_metadata IN OB_part_SU_owner.Metadata_OB_part_SU_owner%TYPE
)
IS
    v_metadata OB_part_SU_owner.Metadata_OB_part_SU_owner%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            OB_part_SU_owner x
        WHERE
            x.OB_ID_part = p_OB_part
        AND
            x.SU_ID_owner = p_SU_owner
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
            OB_part_SU_owner x
        WHERE
            x.OB_ID_part = p_OB_part
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_part_SU_owner for: '
            || p_OB_part
        );
    END LOOP;
    INSERT INTO OB_part_SU_owner (
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner
    )
    VALUES (
        v_metadata,
        p_OB_part,
        p_SU_owner
    );
END ip_OB_part_SU_owner;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_part_SU_owner instead of INSERT trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lOB_part_SU_owner
INSTEAD OF INSERT ON lOB_part_SU_owner
FOR EACH ROW
BEGIN
    ip_OB_part_SU_owner(
        p_OB_part => :NEW.OB_ID_part,
        p_SU_owner => :NEW.SU_ID_owner,
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
BEGIN
    IF (:NEW.OB_ID_part <> :OLD.OB_ID_part
        OR (:NEW.OB_ID_part IS NULL AND :OLD.OB_ID_part IS NOT NULL)
        OR (:NEW.OB_ID_part IS NOT NULL AND :OLD.OB_ID_part IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID_part is not updatable.');
    END IF;
    -- values that are left as they are state nothing
    IF
        :NEW.SU_ID_owner IS NOT NULL
    AND
        (
            (:NEW.OB_ID_part <> :OLD.OB_ID_part
                OR (:NEW.OB_ID_part IS NULL AND :OLD.OB_ID_part IS NOT NULL)
                OR (:NEW.OB_ID_part IS NOT NULL AND :OLD.OB_ID_part IS NULL))
        OR
            (:NEW.SU_ID_owner <> :OLD.SU_ID_owner
                OR (:NEW.SU_ID_owner IS NULL AND :OLD.SU_ID_owner IS NOT NULL)
                OR (:NEW.SU_ID_owner IS NOT NULL AND :OLD.SU_ID_owner IS NULL))
        )
    THEN
        ip_OB_part_SU_owner(
            p_OB_part => :NEW.OB_ID_part,
            p_SU_owner => :NEW.SU_ID_owner,
            p_metadata => :NEW.Metadata_OB_part_SU_owner
        );
    END IF;
    -- a null in every value of a deletable tie moves what the identifiers have to the deletion table
    IF :NEW.Deletable_OB_part_SU_owner = 1
    AND :NEW.SU_ID_owner IS NULL
    THEN
        INSERT INTO OB_part_SU_owner_Deleted (
            OB_ID_part,
            SU_ID_owner,
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_Deleted
        )
        SELECT
            x.OB_ID_part,
            x.SU_ID_owner,
            x.Metadata_OB_part_SU_owner,
            v_now
        FROM
            OB_part_SU_owner x
        WHERE
            x.OB_ID_part = :OLD.OB_ID_part
        ;
        DELETE FROM
            OB_part_SU_owner
        WHERE
            OB_ID_part = :OLD.OB_ID_part
        ;
    END IF;
END ut_lOB_part_SU_owner;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_part_SU_owner instead of DELETE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lOB_part_SU_owner
INSTEAD OF DELETE ON lOB_part_SU_owner
FOR EACH ROW
BEGIN
    DELETE FROM
        OB_part_SU_owner x
    WHERE
        x.OB_ID_part = :OLD.OB_ID_part
    ;
END dt_lOB_part_SU_owner;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_partner_SU_with states a row of SU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_partner_SU_with (
    p_SU_partner IN SU_partner_SU_with.SU_ID_partner%TYPE,
    p_SU_with IN SU_partner_SU_with.SU_ID_with%TYPE,
    p_changing IN SU_partner_SU_with.SU_partner_SU_with_ChangedAt%TYPE,
    p_metadata IN SU_partner_SU_with.Metadata_SU_partner_SU_with%TYPE
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_changing SU_partner_SU_with.SU_partner_SU_with_ChangedAt%TYPE;
    v_metadata SU_partner_SU_with.Metadata_SU_partner_SU_with%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            SU_partner_SU_with x
        WHERE
            x.SU_ID_partner = p_SU_partner
        AND
            x.SU_ID_with = p_SU_with
        AND
            x.SU_partner_SU_with_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO SU_partner_SU_with (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with
    )
    VALUES (
        v_metadata,
        v_changing,
        p_SU_partner,
        p_SU_with
    );
END ip_SU_partner_SU_with;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_partner_SU_with instead of INSERT trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_partner_SU_with
INSTEAD OF INSERT ON lSU_partner_SU_with
FOR EACH ROW
BEGIN
    ip_SU_partner_SU_with(
        p_SU_partner => :NEW.SU_ID_partner,
        p_SU_with => :NEW.SU_ID_with,
        p_changing => :NEW.SU_partner_SU_with_ChangedAt,
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
    v_changed NUMBER(1);
    v_changing SU_partner_SU_with.SU_partner_SU_with_ChangedAt%TYPE;
BEGIN
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.SU_partner_SU_with_ChangedAt <> :OLD.SU_partner_SU_with_ChangedAt
        OR (:NEW.SU_partner_SU_with_ChangedAt IS NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NOT NULL)
        OR (:NEW.SU_partner_SU_with_ChangedAt IS NOT NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.SU_partner_SU_with_ChangedAt ELSE v_now END;
    -- values that are left as they are state nothing
    IF
        :NEW.SU_ID_partner IS NOT NULL
    AND
        :NEW.SU_ID_with IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.SU_ID_partner <> :OLD.SU_ID_partner
                OR (:NEW.SU_ID_partner IS NULL AND :OLD.SU_ID_partner IS NOT NULL)
                OR (:NEW.SU_ID_partner IS NOT NULL AND :OLD.SU_ID_partner IS NULL))
        OR
            (:NEW.SU_ID_with <> :OLD.SU_ID_with
                OR (:NEW.SU_ID_with IS NULL AND :OLD.SU_ID_with IS NOT NULL)
                OR (:NEW.SU_ID_with IS NOT NULL AND :OLD.SU_ID_with IS NULL))
        )
    THEN
        ip_SU_partner_SU_with(
            p_SU_partner => :NEW.SU_ID_partner,
            p_SU_with => :NEW.SU_ID_with,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_SU_partner_SU_with
        );
    END IF;
END ut_lSU_partner_SU_with;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_partner_SU_with instead of DELETE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_partner_SU_with
INSTEAD OF DELETE ON lSU_partner_SU_with
FOR EACH ROW
BEGIN
    DELETE FROM
        SU_partner_SU_with x
    WHERE
        x.SU_partner_SU_with_ChangedAt = :OLD.SU_partner_SU_with_ChangedAt
    AND
        x.SU_ID_partner = :OLD.SU_ID_partner
    AND
        x.SU_ID_with = :OLD.SU_ID_with
    ;
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
COMMENT ON COLUMN EV_QTY_Event_Quantity.EV_QTY_Event_Quantity IS 'Static.';
COMMENT ON COLUMN EV_PLC_Event_Place.EV_PLC_Event_Place IS 'Historized and not restatable, as an attribute of an anchor may be.';
COMMENT ON COLUMN SU_NAM_Subject_Name.SU_NAM_Subject_Name IS 'Static.';
COMMENT ON COLUMN SU_COD_Subject_Code.SU_COD_Subject_Code IS 'Static and idempotent.';
COMMENT ON COLUMN SU_GRD_Subject_Grade.SU_GRD_GRD_ID IS 'Static and knotted.';
COMMENT ON COLUMN SU_NOT_Subject_Note.SU_NOT_Subject_Note IS 'Static, with a checksum.';
COMMENT ON COLUMN SU_TTL_Subject_Title.SU_TTL_Subject_Title IS 'Historized, restatable.';
COMMENT ON COLUMN SU_STA_Subject_State.SU_STA_Subject_State IS 'Historized, not restatable: a restatement is an error.';
COMMENT ON COLUMN SU_LBL_Subject_Label.SU_LBL_Subject_Label IS 'Historized, not restatable and idempotent: a restatement is skipped.';
COMMENT ON COLUMN SU_TAG_Subject_Tag.SU_TAG_Subject_Tag IS 'Historized, restatable and idempotent: a restatement is skipped.';
COMMENT ON COLUMN SU_LVL_Subject_Level.SU_LVL_GRD_ID IS 'Historized and knotted.';
COMMENT ON COLUMN SU_TXT_Subject_Text.SU_TXT_Subject_Text IS 'Historized, with a checksum.';
COMMENT ON COLUMN SU_ASR_Subject_Assessment.SU_ASR_Subject_Assessment IS 'Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).';
COMMENT ON COLUMN SU_ERS_Subject_Erasable.SU_ERS_Subject_Erasable IS 'Historized and deletable (uni-temporal).';
COMMENT ON COLUMN OB_NAM_Object_Name.OB_NAM_Object_Name IS 'Static.';
COMMENT ON TABLE SU_Subject IS 'The subject of the tests.';
COMMENT ON TABLE OB_Object IS 'Something the subject has or keeps.';
COMMENT ON TABLE EV_Event IS 'An event, with attributes of its own, a static one and a historized one.';
COMMENT ON COLUMN EV_Event.SU_ID_for IS 'The subject the event is for.';
COMMENT ON TABLE SU_holder_OB_item_GRD_grade IS 'Historized, with identifiers and a knotted value role, restatable.';
COMMENT ON COLUMN SU_holder_OB_item_GRD_grade.SU_ID_holder IS 'The subject of the tests.';
COMMENT ON COLUMN SU_holder_OB_item_GRD_grade.OB_ID_item IS 'Something the subject has or keeps.';
COMMENT ON COLUMN SU_holder_OB_item_GRD_grade.GRD_ID_grade IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON TABLE SU_keeper_OB_thing_GRD_rank IS 'Historized, with identifiers and a knotted value role, idempotent and not assertive.';
COMMENT ON COLUMN SU_keeper_OB_thing_GRD_rank.SU_ID_keeper IS 'The subject of the tests.';
COMMENT ON COLUMN SU_keeper_OB_thing_GRD_rank.OB_ID_thing IS 'Something the subject has or keeps.';
COMMENT ON COLUMN SU_keeper_OB_thing_GRD_rank.GRD_ID_rank IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON TABLE OB_part_SU_owner IS 'Static, with an identifier and a value role: each object has one owner.';
COMMENT ON COLUMN OB_part_SU_owner.OB_ID_part IS 'Something the subject has or keeps.';
COMMENT ON COLUMN OB_part_SU_owner.SU_ID_owner IS 'The subject of the tests.';
COMMENT ON TABLE SU_partner_SU_with IS 'Historized, without identifiers.';
COMMENT ON COLUMN SU_partner_SU_with.SU_ID_partner IS 'The subject of the tests.';
COMMENT ON COLUMN SU_partner_SU_with.SU_ID_with IS 'The subject of the tests.';
