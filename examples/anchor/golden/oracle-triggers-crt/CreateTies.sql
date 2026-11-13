-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
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
            SU_holder_OB_item_GRD_grade_Positor number(5) not null,
            SU_holder_OB_item_GRD_grade_Reliability number(5,2) not null,
            SU_holder_OB_item_GRD_grade_Assertion char(1) generated always as (
                case
                    when SU_holder_OB_item_GRD_grade_Reliability > 0 then '+'
                    when SU_holder_OB_item_GRD_grade_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_holder_OB_item_GRD_grade number(10) not null,
            constraint fkSU_holder_OB_item_GRD_grade_Annex foreign key (
                SU_holder_OB_item_GRD_grade_ID
            ) references SU_holder_OB_item_GRD_grade_Posit(SU_holder_OB_item_GRD_grade_ID),
            constraint pkSU_holder_OB_item_GRD_grade_Annex primary key (
                SU_holder_OB_item_GRD_grade_ID,
                SU_holder_OB_item_GRD_grade_Positor,
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
            SU_keeper_OB_thing_GRD_rank_Positor number(5) not null,
            SU_keeper_OB_thing_GRD_rank_Reliability number(5,2) not null,
            SU_keeper_OB_thing_GRD_rank_Assertion char(1) generated always as (
                case
                    when SU_keeper_OB_thing_GRD_rank_Reliability > 0 then '+'
                    when SU_keeper_OB_thing_GRD_rank_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_keeper_OB_thing_GRD_rank number(10) not null,
            constraint fkSU_keeper_OB_thing_GRD_rank_Annex foreign key (
                SU_keeper_OB_thing_GRD_rank_ID
            ) references SU_keeper_OB_thing_GRD_rank_Posit(SU_keeper_OB_thing_GRD_rank_ID),
            constraint pkSU_keeper_OB_thing_GRD_rank_Annex primary key (
                SU_keeper_OB_thing_GRD_rank_ID,
                SU_keeper_OB_thing_GRD_rank_Positor,
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
            OB_part_SU_owner_Positor number(5) not null,
            OB_part_SU_owner_Reliability number(5,2) not null,
            OB_part_SU_owner_Assertion char(1) generated always as (
                case
                    when OB_part_SU_owner_Reliability > 0 then '+'
                    when OB_part_SU_owner_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_OB_part_SU_owner number(10) not null,
            constraint fkOB_part_SU_owner_Annex foreign key (
                OB_part_SU_owner_ID
            ) references OB_part_SU_owner_Posit(OB_part_SU_owner_ID),
            constraint pkOB_part_SU_owner_Annex primary key (
                OB_part_SU_owner_ID,
                OB_part_SU_owner_Positor,
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
            SU_partner_SU_with_Positor number(5) not null,
            SU_partner_SU_with_Reliability number(5,2) not null,
            SU_partner_SU_with_Assertion char(1) generated always as (
                case
                    when SU_partner_SU_with_Reliability > 0 then '+'
                    when SU_partner_SU_with_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_SU_partner_SU_with number(10) not null,
            constraint fkSU_partner_SU_with_Annex foreign key (
                SU_partner_SU_with_ID
            ) references SU_partner_SU_with_Posit(SU_partner_SU_with_ID),
            constraint pkSU_partner_SU_with_Annex primary key (
                SU_partner_SU_with_ID,
                SU_partner_SU_with_Positor,
                SU_partner_SU_with_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
