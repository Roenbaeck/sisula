-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_partner_AC_with_ONG_currently_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_partner_AC_with_ONG_currently_Posit (
            AC_partner_AC_with_ONG_currently_ID number(10) default AC_partner_AC_with_ONG_currently_Posit_ID_SEQ.nextval not null, 
            AC_ID_partner number(10) not null, 
            AC_ID_with number(10) not null, 
            ONG_ID_currently number(3) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_partner foreign key (
                AC_ID_partner
            ) references AC_Actor(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_with foreign key (
                AC_ID_with
            ) references AC_Actor(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_Posit_fkONG_currently foreign key (
                ONG_ID_currently
            ) references ONG_Ongoing(ONG_ID),
            constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_partner unique (
                AC_ID_partner,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_with unique (
                AC_ID_with,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint pkAC_partner_AC_with_ONG_currently_Posit primary key (
                AC_partner_AC_with_ONG_currently_ID
            ),
            constraint uqAC_partner_AC_with_ONG_currently unique (
                AC_partner_AC_with_ONG_currently_ChangedAt,
                AC_ID_partner,
                AC_ID_with,
                ONG_ID_currently
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_partner_AC_with_ONG_currently_Annex (
            AC_partner_AC_with_ONG_currently_ID number(10) not null,
            AC_partner_AC_with_ONG_currently_PositedAt timestamp not null,
            AC_partner_AC_with_ONG_currently_Positor number(3) not null,
            AC_partner_AC_with_ONG_currently_Reliability number(5,2) not null,
            AC_partner_AC_with_ONG_currently_Assertion char(1) generated always as (
                case
                    when AC_partner_AC_with_ONG_currently_Reliability > 0 then '+'
                    when AC_partner_AC_with_ONG_currently_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_partner_AC_with_ONG_currently number(10) not null,
            constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
                AC_partner_AC_with_ONG_currently_ID
            ) references AC_partner_AC_with_ONG_currently_Posit(AC_partner_AC_with_ONG_currently_ID),
            constraint pkAC_partner_AC_with_ONG_currently_Annex primary key (
                AC_partner_AC_with_ONG_currently_ID,
                AC_partner_AC_with_ONG_currently_Positor,
                AC_partner_AC_with_ONG_currently_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_subset_PN_of_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_subset_PN_of_Posit (
            AC_subset_PN_of_ID number(10) default AC_subset_PN_of_Posit_ID_SEQ.nextval not null, 
            AC_ID_subset number(10) not null, 
            PN_ID_of number(10) not null, 
            constraint AC_subset_PN_of_Posit_fkAC_subset foreign key (
                AC_ID_subset
            ) references AC_Actor(AC_ID),
            constraint AC_subset_PN_of_Posit_fkPN_of foreign key (
                PN_ID_of
            ) references PN_Person(PN_ID),
            constraint AC_subset_PN_of_Posit_uqAC_subset unique (
                AC_ID_subset
            ),
            constraint AC_subset_PN_of_Posit_uqPN_of unique (
                PN_ID_of
            ),
            constraint pkAC_subset_PN_of_Posit primary key (
                AC_subset_PN_of_ID
            ),
            constraint uqAC_subset_PN_of unique (
                AC_ID_subset,
                PN_ID_of
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_subset_PN_of_Annex (
            AC_subset_PN_of_ID number(10) not null,
            AC_subset_PN_of_PositedAt timestamp not null,
            AC_subset_PN_of_Positor number(3) not null,
            AC_subset_PN_of_Reliability number(5,2) not null,
            AC_subset_PN_of_Assertion char(1) generated always as (
                case
                    when AC_subset_PN_of_Reliability > 0 then '+'
                    when AC_subset_PN_of_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_subset_PN_of number(10) not null,
            constraint fkAC_subset_PN_of_Annex foreign key (
                AC_subset_PN_of_ID
            ) references AC_subset_PN_of_Posit(AC_subset_PN_of_ID),
            constraint pkAC_subset_PN_of_Annex primary key (
                AC_subset_PN_of_ID,
                AC_subset_PN_of_Positor,
                AC_subset_PN_of_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE EV_in_AC_wasCast_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_in_AC_wasCast_Posit (
            EV_in_AC_wasCast_ID number(10) default EV_in_AC_wasCast_Posit_ID_SEQ.nextval not null, 
            EV_ID_in number(10) not null, 
            AC_ID_wasCast number(10) not null, 
            constraint EV_in_AC_wasCast_Posit_fkEV_in foreign key (
                EV_ID_in
            ) references EV_Event(EV_ID),
            constraint EV_in_AC_wasCast_Posit_fkAC_wasCast foreign key (
                AC_ID_wasCast
            ) references AC_Actor(AC_ID),
            constraint pkEV_in_AC_wasCast_Posit primary key (
                EV_in_AC_wasCast_ID
            ),
            constraint uqEV_in_AC_wasCast unique (
                EV_ID_in,
                AC_ID_wasCast
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_in_AC_wasCast_Annex (
            EV_in_AC_wasCast_ID number(10) not null,
            EV_in_AC_wasCast_PositedAt timestamp not null,
            EV_in_AC_wasCast_Positor number(3) not null,
            EV_in_AC_wasCast_Reliability number(5,2) not null,
            EV_in_AC_wasCast_Assertion char(1) generated always as (
                case
                    when EV_in_AC_wasCast_Reliability > 0 then '+'
                    when EV_in_AC_wasCast_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_in_AC_wasCast number(10) not null,
            constraint fkEV_in_AC_wasCast_Annex foreign key (
                EV_in_AC_wasCast_ID
            ) references EV_in_AC_wasCast_Posit(EV_in_AC_wasCast_ID),
            constraint pkEV_in_AC_wasCast_Annex primary key (
                EV_in_AC_wasCast_ID,
                EV_in_AC_wasCast_Positor,
                EV_in_AC_wasCast_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_part_PR_in_RAT_got_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_part_PR_in_RAT_got_Posit (
            AC_part_PR_in_RAT_got_ID number(10) default AC_part_PR_in_RAT_got_Posit_ID_SEQ.nextval not null, 
            AC_ID_part number(10) not null, 
            PR_ID_in number(10) not null, 
            RAT_ID_got number(3) not null,
            AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
            constraint AC_part_PR_in_RAT_got_Posit_fkAC_part foreign key (
                AC_ID_part
            ) references AC_Actor(AC_ID),
            constraint AC_part_PR_in_RAT_got_Posit_fkPR_in foreign key (
                PR_ID_in
            ) references PR_Program(PR_ID),
            constraint AC_part_PR_in_RAT_got_Posit_fkRAT_got foreign key (
                RAT_ID_got
            ) references RAT_Rating(RAT_ID),
            constraint pkAC_part_PR_in_RAT_got_Posit primary key (
                AC_part_PR_in_RAT_got_ID
            ),
            constraint uqAC_part_PR_in_RAT_got unique (
                AC_ID_part,
                PR_ID_in,
                AC_part_PR_in_RAT_got_ChangedAt,
                RAT_ID_got
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_part_PR_in_RAT_got_Annex (
            AC_part_PR_in_RAT_got_ID number(10) not null,
            AC_part_PR_in_RAT_got_PositedAt timestamp not null,
            AC_part_PR_in_RAT_got_Positor number(3) not null,
            AC_part_PR_in_RAT_got_Reliability number(5,2) not null,
            AC_part_PR_in_RAT_got_Assertion char(1) generated always as (
                case
                    when AC_part_PR_in_RAT_got_Reliability > 0 then '+'
                    when AC_part_PR_in_RAT_got_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_part_PR_in_RAT_got number(10) not null,
            constraint fkAC_part_PR_in_RAT_got_Annex foreign key (
                AC_part_PR_in_RAT_got_ID
            ) references AC_part_PR_in_RAT_got_Posit(AC_part_PR_in_RAT_got_ID),
            constraint pkAC_part_PR_in_RAT_got_Annex primary key (
                AC_part_PR_in_RAT_got_ID,
                AC_part_PR_in_RAT_got_Positor,
                AC_part_PR_in_RAT_got_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ST_at_PR_isPlaying_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_at_PR_isPlaying_Posit (
            ST_at_PR_isPlaying_ID number(10) default ST_at_PR_isPlaying_Posit_ID_SEQ.nextval not null, 
            ST_ID_at number(10) not null, 
            PR_ID_isPlaying number(10) not null, 
            ST_at_PR_isPlaying_ChangedAt timestamp not null,
            constraint ST_at_PR_isPlaying_Posit_fkST_at foreign key (
                ST_ID_at
            ) references ST_Stage(ST_ID),
            constraint ST_at_PR_isPlaying_Posit_fkPR_isPlaying foreign key (
                PR_ID_isPlaying
            ) references PR_Program(PR_ID),
            constraint pkST_at_PR_isPlaying_Posit primary key (
                ST_at_PR_isPlaying_ID
            ),
            constraint uqST_at_PR_isPlaying unique (
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ST_at_PR_isPlaying_Annex (
            ST_at_PR_isPlaying_ID number(10) not null,
            ST_at_PR_isPlaying_PositedAt timestamp not null,
            ST_at_PR_isPlaying_Positor number(3) not null,
            ST_at_PR_isPlaying_Reliability number(5,2) not null,
            ST_at_PR_isPlaying_Assertion char(1) generated always as (
                case
                    when ST_at_PR_isPlaying_Reliability > 0 then '+'
                    when ST_at_PR_isPlaying_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_at_PR_isPlaying number(10) not null,
            constraint fkST_at_PR_isPlaying_Annex foreign key (
                ST_at_PR_isPlaying_ID
            ) references ST_at_PR_isPlaying_Posit(ST_at_PR_isPlaying_ID),
            constraint pkST_at_PR_isPlaying_Annex primary key (
                ST_at_PR_isPlaying_ID,
                ST_at_PR_isPlaying_Positor,
                ST_at_PR_isPlaying_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE AC_parent_AC_child_PAT_having_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_parent_AC_child_PAT_having_Posit (
            AC_parent_AC_child_PAT_having_ID number(10) default AC_parent_AC_child_PAT_having_Posit_ID_SEQ.nextval not null, 
            AC_ID_parent number(10) not null, 
            AC_ID_child number(10) not null, 
            PAT_ID_having number(3) not null,
            constraint AC_parent_AC_child_PAT_having_Posit_fkAC_parent foreign key (
                AC_ID_parent
            ) references AC_Actor(AC_ID),
            constraint AC_parent_AC_child_PAT_having_Posit_fkAC_child foreign key (
                AC_ID_child
            ) references AC_Actor(AC_ID),
            constraint AC_parent_AC_child_PAT_having_Posit_fkPAT_having foreign key (
                PAT_ID_having
            ) references PAT_ParentalType(PAT_ID),
            constraint pkAC_parent_AC_child_PAT_having_Posit primary key (
                AC_parent_AC_child_PAT_having_ID
            ),
            constraint uqAC_parent_AC_child_PAT_having unique (
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE AC_parent_AC_child_PAT_having_Annex (
            AC_parent_AC_child_PAT_having_ID number(10) not null,
            AC_parent_AC_child_PAT_having_PositedAt timestamp not null,
            AC_parent_AC_child_PAT_having_Positor number(3) not null,
            AC_parent_AC_child_PAT_having_Reliability number(5,2) not null,
            AC_parent_AC_child_PAT_having_Assertion char(1) generated always as (
                case
                    when AC_parent_AC_child_PAT_having_Reliability > 0 then '+'
                    when AC_parent_AC_child_PAT_having_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_parent_AC_child_PAT_having number(10) not null,
            constraint fkAC_parent_AC_child_PAT_having_Annex foreign key (
                AC_parent_AC_child_PAT_having_ID
            ) references AC_parent_AC_child_PAT_having_Posit(AC_parent_AC_child_PAT_having_ID),
            constraint pkAC_parent_AC_child_PAT_having_Annex primary key (
                AC_parent_AC_child_PAT_having_ID,
                AC_parent_AC_child_PAT_having_Positor,
                AC_parent_AC_child_PAT_having_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE PR_content_ST_location_EV_of_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_content_ST_location_EV_of_Posit (
            PR_content_ST_location_EV_of_ID number(10) default PR_content_ST_location_EV_of_Posit_ID_SEQ.nextval not null, 
            PR_ID_content number(10) not null, 
            ST_ID_location number(10) not null, 
            EV_ID_of number(10) not null, 
            constraint PR_content_ST_location_EV_of_Posit_fkPR_content foreign key (
                PR_ID_content
            ) references PR_Program(PR_ID),
            constraint PR_content_ST_location_EV_of_Posit_fkST_location foreign key (
                ST_ID_location
            ) references ST_Stage(ST_ID),
            constraint PR_content_ST_location_EV_of_Posit_fkEV_of foreign key (
                EV_ID_of
            ) references EV_Event(EV_ID),
            constraint pkPR_content_ST_location_EV_of_Posit primary key (
                PR_content_ST_location_EV_of_ID
            ),
            constraint uqPR_content_ST_location_EV_of unique (
                EV_ID_of,
                PR_ID_content,
                ST_ID_location
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PR_content_ST_location_EV_of_Annex (
            PR_content_ST_location_EV_of_ID number(10) not null,
            PR_content_ST_location_EV_of_PositedAt timestamp not null,
            PR_content_ST_location_EV_of_Positor number(3) not null,
            PR_content_ST_location_EV_of_Reliability number(5,2) not null,
            PR_content_ST_location_EV_of_Assertion char(1) generated always as (
                case
                    when PR_content_ST_location_EV_of_Reliability > 0 then '+'
                    when PR_content_ST_location_EV_of_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_PR_content_ST_location_EV_of number(10) not null,
            constraint fkPR_content_ST_location_EV_of_Annex foreign key (
                PR_content_ST_location_EV_of_ID
            ) references PR_content_ST_location_EV_of_Posit(PR_content_ST_location_EV_of_ID),
            constraint pkPR_content_ST_location_EV_of_Annex primary key (
                PR_content_ST_location_EV_of_ID,
                PR_content_ST_location_EV_of_Positor,
                PR_content_ST_location_EV_of_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
