-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE ties.AC_partner_AC_with_ONG_currently (
            AC_ID_partner number(5) not null, 
            AC_ID_with number(5) not null, 
            ONG_ID_currently number(3) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            Metadata_AC_partner_AC_with_ONG_currently number(19) not null,
            constraint FK1_AC_partner_AC_with_ONG_cur foreign key (
                AC_ID_partner
            ) references anchors.AC_Actor(AC_ID), 
            constraint FK2_AC_partner_AC_with_ONG_cur foreign key (
                AC_ID_with
            ) references anchors.AC_Actor(AC_ID), 
            constraint FK3_AC_partner_AC_with_ONG_cur foreign key (
                ONG_ID_currently
            ) references knots.ONG_Ongoing(ONG_ID),
            constraint UQ1_AC_partner_AC_with_ONG_cur unique (
                AC_ID_partner,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint UQ2_AC_partner_AC_with_ONG_cur unique (
                AC_ID_with,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint UQ3_AC_partner_AC_with_ONG_cur unique (
                ONG_ID_currently,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint PK_AC_partner_AC_with_ONG_curr primary key (
                AC_ID_partner,
                AC_ID_with,
                ONG_ID_currently,
                AC_partner_AC_with_ONG_currently_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE ties.AC_subset_PN_of (
            AC_ID_subset number(5) not null, 
            PN_ID_of number(19) not null, 
            Metadata_AC_subset_PN_of number(19) not null,
            constraint FK1_AC_subset_PN_ofAC_subset foreign key (
                AC_ID_subset
            ) references anchors.AC_Actor(AC_ID), 
            constraint FK2_AC_subset_PN_ofPN_of foreign key (
                PN_ID_of
            ) references anchors.PN_Person(PN_ID), 
            constraint UQ1_AC_subset_PN_ofAC_subset unique (
                AC_ID_subset
            ),
            constraint UQ2_AC_subset_PN_ofPN_of unique (
                PN_ID_of
            ),
            constraint PK_AC_subset_PN_of primary key (
                AC_ID_subset,
                PN_ID_of
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE ties.EV_in_AC_wasCast (
            EV_ID_in number(12,0) not null, 
            AC_ID_wasCast number(5) not null, 
            Metadata_EV_in_AC_wasCast number(19) not null,
            constraint FK1_EV_in_AC_wasCastEV_in foreign key (
                EV_ID_in
            ) references nexuses.EV_Event(EV_ID), 
            constraint FK2_EV_in_AC_wasCastAC_wasCast foreign key (
                AC_ID_wasCast
            ) references anchors.AC_Actor(AC_ID), 
            constraint PK_EV_in_AC_wasCast primary key (
                EV_ID_in,
                AC_ID_wasCast
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE ties.AC_part_PR_in_RAT_got (
            AC_ID_part number(5) not null, 
            PR_ID_in number(19) not null, 
            RAT_ID_got number(3) not null,
            AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
            Metadata_AC_part_PR_in_RAT_got number(19) not null,
            constraint FK1_AC_part_PR_in_RAT_gotAC_pa foreign key (
                AC_ID_part
            ) references anchors.AC_Actor(AC_ID), 
            constraint FK2_AC_part_PR_in_RAT_gotPR_in foreign key (
                PR_ID_in
            ) references anchors.PR_Program(PR_ID), 
            constraint FK3_AC_part_PR_in_RAT_gotRAT_g foreign key (
                RAT_ID_got
            ) references knots.RAT_Rating(RAT_ID),
            constraint PK_AC_part_PR_in_RAT_got primary key (
                AC_ID_part,
                PR_ID_in,
                AC_part_PR_in_RAT_got_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE ties.ST_at_PR_isPlaying (
            ST_ID_at number(10) not null, 
            PR_ID_isPlaying number(19) not null, 
            ST_at_PR_isPlaying_ChangedAt timestamp not null,
            Metadata_ST_at_PR_isPlaying number(19) not null,
            constraint FK1_ST_at_PR_isPlayingST_at foreign key (
                ST_ID_at
            ) references anchors.ST_Stage(ST_ID), 
            constraint FK2_ST_at_PR_isPlayingPR_isPla foreign key (
                PR_ID_isPlaying
            ) references anchors.PR_Program(PR_ID), 
            constraint PK_ST_at_PR_isPlaying primary key (
                ST_ID_at,
                PR_ID_isPlaying,
                ST_at_PR_isPlaying_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE ties.AC_parent_AC_child_PAT_having (
            AC_ID_parent number(5) not null, 
            AC_ID_child number(5) not null, 
            PAT_ID_having number(3) not null,
            Metadata_AC_parent_AC_child_PAT_having number(19) not null,
            constraint FK1_AC_parent_AC_child_PAT_hav foreign key (
                AC_ID_parent
            ) references anchors.AC_Actor(AC_ID), 
            constraint FK2_AC_parent_AC_child_PAT_hav foreign key (
                AC_ID_child
            ) references anchors.AC_Actor(AC_ID), 
            constraint FK3_AC_parent_AC_child_PAT_hav foreign key (
                PAT_ID_having
            ) references knots.PAT_ParentalType(PAT_ID),
            constraint PK_AC_parent_AC_child_PAT_havi primary key (
                AC_ID_parent,
                AC_ID_child,
                PAT_ID_having
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Historized tie table -----------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE ties.PR_content_ST_location_EV_of (
            PR_ID_content number(19) not null, 
            ST_ID_location number(10) not null, 
            EV_ID_of number(12,0) not null, 
            PR_content_ST_location_EV_of_ChangedAt timestamp not null,
            Metadata_PR_content_ST_location_EV_of number(19) not null,
            constraint FK1_PR_content_ST_location_EV_ foreign key (
                PR_ID_content
            ) references anchors.PR_Program(PR_ID), 
            constraint FK2_PR_content_ST_location_EV_ foreign key (
                ST_ID_location
            ) references anchors.ST_Stage(ST_ID), 
            constraint FK3_PR_content_ST_location_EV_ foreign key (
                EV_ID_of
            ) references nexuses.EV_Event(EV_ID), 
            constraint UQ1_PR_content_ST_location_EV_ unique (
                PR_ID_content,
                PR_content_ST_location_EV_of_ChangedAt
            ),
            constraint UQ2_PR_content_ST_location_EV_ unique (
                ST_ID_location,
                PR_content_ST_location_EV_of_ChangedAt
            ),
            constraint UQ3_PR_content_ST_location_EV_ unique (
                EV_ID_of,
                PR_content_ST_location_EV_of_ChangedAt
            ),
            constraint PK_PR_content_ST_location_EV_o primary key (
                PR_ID_content,
                ST_ID_location,
                EV_ID_of,
                PR_content_ST_location_EV_of_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
