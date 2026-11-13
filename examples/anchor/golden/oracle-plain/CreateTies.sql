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
-- AC_partner_AC_with_ONG_currently table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_partner_AC_with_ONG_currently (
            AC_ID_partner number(10) not null, 
            AC_ID_with number(10) not null, 
            ONG_ID_currently number(3) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            constraint AC_partner_AC_with_ONG_currently_fkAC_partner foreign key (
                AC_ID_partner
            ) references AC_Actor(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_fkAC_with foreign key (
                AC_ID_with
            ) references AC_Actor(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_fkONG_currently foreign key (
                ONG_ID_currently
            ) references ONG_Ongoing(ONG_ID),
            constraint AC_partner_AC_with_ONG_currently_uqAC_partner unique (
                AC_ID_partner,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint AC_partner_AC_with_ONG_currently_uqAC_with unique (
                AC_ID_with,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint pkAC_partner_AC_with_ONG_currently primary key (
                AC_ID_partner,
                AC_ID_with,
                ONG_ID_currently,
                AC_partner_AC_with_ONG_currently_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_subset_PN_of (
            AC_ID_subset number(10) not null, 
            PN_ID_of number(10) not null, 
            constraint AC_subset_PN_of_fkAC_subset foreign key (
                AC_ID_subset
            ) references AC_Actor(AC_ID),
            constraint AC_subset_PN_of_fkPN_of foreign key (
                PN_ID_of
            ) references PN_Person(PN_ID),
            constraint AC_subset_PN_of_uqAC_subset unique (
                AC_ID_subset
            ),
            constraint AC_subset_PN_of_uqPN_of unique (
                PN_ID_of
            ),
            constraint pkAC_subset_PN_of primary key (
                AC_ID_subset,
                PN_ID_of
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_in_AC_wasCast (
            EV_ID_in number(10) not null, 
            AC_ID_wasCast number(10) not null, 
            constraint EV_in_AC_wasCast_fkEV_in foreign key (
                EV_ID_in
            ) references EV_Event(EV_ID),
            constraint EV_in_AC_wasCast_fkAC_wasCast foreign key (
                AC_ID_wasCast
            ) references AC_Actor(AC_ID),
            constraint pkEV_in_AC_wasCast primary key (
                EV_ID_in,
                AC_ID_wasCast
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_part_PR_in_RAT_got (
            AC_ID_part number(10) not null, 
            PR_ID_in number(10) not null, 
            RAT_ID_got number(3) not null,
            AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
            constraint AC_part_PR_in_RAT_got_fkAC_part foreign key (
                AC_ID_part
            ) references AC_Actor(AC_ID),
            constraint AC_part_PR_in_RAT_got_fkPR_in foreign key (
                PR_ID_in
            ) references PR_Program(PR_ID),
            constraint AC_part_PR_in_RAT_got_fkRAT_got foreign key (
                RAT_ID_got
            ) references RAT_Rating(RAT_ID),
            constraint pkAC_part_PR_in_RAT_got primary key (
                AC_ID_part,
                PR_ID_in,
                AC_part_PR_in_RAT_got_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_at_PR_isPlaying (
            ST_ID_at number(10) not null, 
            PR_ID_isPlaying number(10) not null, 
            ST_at_PR_isPlaying_ChangedAt timestamp not null,
            constraint ST_at_PR_isPlaying_fkST_at foreign key (
                ST_ID_at
            ) references ST_Stage(ST_ID),
            constraint ST_at_PR_isPlaying_fkPR_isPlaying foreign key (
                PR_ID_isPlaying
            ) references PR_Program(PR_ID),
            constraint pkST_at_PR_isPlaying primary key (
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
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_parent_AC_child_PAT_having (
            AC_ID_parent number(10) not null, 
            AC_ID_child number(10) not null, 
            PAT_ID_having number(3) not null,
            constraint AC_parent_AC_child_PAT_having_fkAC_parent foreign key (
                AC_ID_parent
            ) references AC_Actor(AC_ID),
            constraint AC_parent_AC_child_PAT_having_fkAC_child foreign key (
                AC_ID_child
            ) references AC_Actor(AC_ID),
            constraint AC_parent_AC_child_PAT_having_fkPAT_having foreign key (
                PAT_ID_having
            ) references PAT_ParentalType(PAT_ID),
            constraint pkAC_parent_AC_child_PAT_having primary key (
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
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_content_ST_location_EV_of (
            PR_ID_content number(10) not null, 
            ST_ID_location number(10) not null, 
            EV_ID_of number(10) not null, 
            constraint PR_content_ST_location_EV_of_fkPR_content foreign key (
                PR_ID_content
            ) references PR_Program(PR_ID),
            constraint PR_content_ST_location_EV_of_fkST_location foreign key (
                ST_ID_location
            ) references ST_Stage(ST_ID),
            constraint PR_content_ST_location_EV_of_fkEV_of foreign key (
                EV_ID_of
            ) references EV_Event(EV_ID),
            constraint pkPR_content_ST_location_EV_of primary key (
                EV_ID_of
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
