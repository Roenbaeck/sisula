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
        CREATE TABLE public.AC_partner_AC_with_ONG_currently (
            AC_ID_partner number(10) not null, 
            AC_ID_with number(10) not null, 
            ONG_ID_currently number(3) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            constraint FK1_AC_partner_AC_with_ONG_cur foreign key (
                AC_ID_partner
            ) references public.AC_Actor(AC_ID), 
            constraint FK2_AC_partner_AC_with_ONG_cur foreign key (
                AC_ID_with
            ) references public.AC_Actor(AC_ID), 
            constraint FK3_AC_partner_AC_with_ONG_cur foreign key (
                ONG_ID_currently
            ) references public.ONG_Ongoing(ONG_ID),
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
        CREATE TABLE public.AC_subset_PN_of (
            AC_ID_subset number(10) not null, 
            PN_ID_of number(10) not null, 
            constraint FK1_AC_subset_PN_ofAC_subset foreign key (
                AC_ID_subset
            ) references public.AC_Actor(AC_ID), 
            constraint FK2_AC_subset_PN_ofPN_of foreign key (
                PN_ID_of
            ) references public.PN_Person(PN_ID), 
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
        CREATE TABLE public.EV_in_AC_wasCast (
            EV_ID_in number(10) not null, 
            AC_ID_wasCast number(10) not null, 
            constraint FK1_EV_in_AC_wasCastEV_in foreign key (
                EV_ID_in
            ) references public.EV_Event(EV_ID), 
            constraint FK2_EV_in_AC_wasCastAC_wasCast foreign key (
                AC_ID_wasCast
            ) references public.AC_Actor(AC_ID), 
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
        CREATE TABLE public.AC_part_PR_in_RAT_got (
            AC_ID_part number(10) not null, 
            PR_ID_in number(10) not null, 
            RAT_ID_got number(3) not null,
            AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
            constraint FK1_AC_part_PR_in_RAT_gotAC_pa foreign key (
                AC_ID_part
            ) references public.AC_Actor(AC_ID), 
            constraint FK2_AC_part_PR_in_RAT_gotPR_in foreign key (
                PR_ID_in
            ) references public.PR_Program(PR_ID), 
            constraint FK3_AC_part_PR_in_RAT_gotRAT_g foreign key (
                RAT_ID_got
            ) references public.RAT_Rating(RAT_ID),
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
        CREATE TABLE public.ST_at_PR_isPlaying (
            ST_ID_at number(10) not null, 
            PR_ID_isPlaying number(10) not null, 
            ST_at_PR_isPlaying_ChangedAt timestamp not null,
            constraint FK1_ST_at_PR_isPlayingST_at foreign key (
                ST_ID_at
            ) references public.ST_Stage(ST_ID), 
            constraint FK2_ST_at_PR_isPlayingPR_isPla foreign key (
                PR_ID_isPlaying
            ) references public.PR_Program(PR_ID), 
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
        CREATE TABLE public.AC_parent_AC_child_PAT_having (
            AC_ID_parent number(10) not null, 
            AC_ID_child number(10) not null, 
            PAT_ID_having number(3) not null,
            constraint FK1_AC_parent_AC_child_PAT_hav foreign key (
                AC_ID_parent
            ) references public.AC_Actor(AC_ID), 
            constraint FK2_AC_parent_AC_child_PAT_hav foreign key (
                AC_ID_child
            ) references public.AC_Actor(AC_ID), 
            constraint FK3_AC_parent_AC_child_PAT_hav foreign key (
                PAT_ID_having
            ) references public.PAT_ParentalType(PAT_ID),
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
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.PR_content_ST_location_EV_of (
            PR_ID_content number(10) not null, 
            ST_ID_location number(10) not null, 
            EV_ID_of number(10) not null, 
            constraint FK1_PR_content_ST_location_EV_ foreign key (
                PR_ID_content
            ) references public.PR_Program(PR_ID), 
            constraint FK2_PR_content_ST_location_EV_ foreign key (
                ST_ID_location
            ) references public.ST_Stage(ST_ID), 
            constraint FK3_PR_content_ST_location_EV_ foreign key (
                EV_ID_of
            ) references public.EV_Event(EV_ID), 
            constraint PK_PR_content_ST_location_EV_o primary key (
                EV_ID_of
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
