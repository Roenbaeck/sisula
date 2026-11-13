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
