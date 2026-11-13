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
        CREATE TABLE ties.AC_partner_AC_with_ONG_currently (
            AC_ID_partner number(5) not null, 
            AC_ID_with number(5) not null, 
            ONG_ID_currently number(3) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            Metadata_AC_partner_AC_with_ONG_currently number(10) not null,
            constraint AC_partner_AC_with_ONG_currently_fkAC_partner foreign key (
                AC_ID_partner
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_fkAC_with foreign key (
                AC_ID_with
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_fkONG_currently foreign key (
                ONG_ID_currently
            ) references knots.ONG_Pågående(ONG_ID),
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
        CREATE TABLE ties.AC_subset_PN_of (
            AC_ID_subset number(5) not null, 
            PN_ID_of number(19) not null, 
            Metadata_AC_subset_PN_of number(10) not null,
            constraint AC_subset_PN_of_fkAC_subset foreign key (
                AC_ID_subset
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_subset_PN_of_fkPN_of foreign key (
                PN_ID_of
            ) references anchors.PN_Person(PN_ID),
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
-- EV_in_AC_rollsattes table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.EV_in_AC_rollsattes (
            EV_ID_in number(12,0) not null, 
            AC_ID_rollsattes number(5) not null, 
            Metadata_EV_in_AC_rollsattes number(10) not null,
            constraint EV_in_AC_rollsattes_fkEV_in foreign key (
                EV_ID_in
            ) references nexuses.EV_Händelse(EV_ID),
            constraint EV_in_AC_rollsattes_fkAC_rollsattes foreign key (
                AC_ID_rollsattes
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint pkEV_in_AC_rollsattes primary key (
                EV_ID_in,
                AC_ID_rollsattes
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_deltar_PR_in_RAT_fick (
            AC_ID_deltar number(5) not null, 
            PR_ID_in number(19) not null, 
            RAT_ID_fick number(3) not null,
            AC_deltar_PR_in_RAT_fick_ChangedAt timestamp not null,
            Metadata_AC_deltar_PR_in_RAT_fick number(10) not null,
            constraint AC_deltar_PR_in_RAT_fick_fkAC_deltar foreign key (
                AC_ID_deltar
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_deltar_PR_in_RAT_fick_fkPR_in foreign key (
                PR_ID_in
            ) references anchors.PR_Föreställning(PR_ID),
            constraint AC_deltar_PR_in_RAT_fick_fkRAT_fick foreign key (
                RAT_ID_fick
            ) references knots.RAT_Betyg(RAT_ID),
            constraint pkAC_deltar_PR_in_RAT_fick primary key (
                AC_ID_deltar,
                PR_ID_in,
                AC_deltar_PR_in_RAT_fick_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_spelas table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.ST_at_PR_spelas (
            ST_ID_at number(10) not null, 
            PR_ID_spelas number(19) not null, 
            ST_at_PR_spelas_ChangedAt timestamp not null,
            Metadata_ST_at_PR_spelas number(10) not null,
            constraint ST_at_PR_spelas_fkST_at foreign key (
                ST_ID_at
            ) references anchors.ST_Scen(ST_ID),
            constraint ST_at_PR_spelas_fkPR_spelas foreign key (
                PR_ID_spelas
            ) references anchors.PR_Föreställning(PR_ID),
            constraint pkST_at_PR_spelas primary key (
                ST_ID_at,
                PR_ID_spelas,
                ST_at_PR_spelas_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_förälder_AC_barn_PAT_har (
            AC_ID_förälder number(5) not null, 
            AC_ID_barn number(5) not null, 
            PAT_ID_har number(3) not null,
            Metadata_AC_förälder_AC_barn_PAT_har number(10) not null,
            constraint AC_förälder_AC_barn_PAT_har_fkAC_förälder foreign key (
                AC_ID_förälder
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_förälder_AC_barn_PAT_har_fkAC_barn foreign key (
                AC_ID_barn
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_förälder_AC_barn_PAT_har_fkPAT_har foreign key (
                PAT_ID_har
            ) references knots.PAT_Föräldratyp(PAT_ID),
            constraint pkAC_förälder_AC_barn_PAT_har primary key (
                AC_ID_förälder,
                AC_ID_barn,
                PAT_ID_har
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized tie table -----------------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.PR_innehåll_ST_plats_EV_of (
            PR_ID_innehåll number(19) not null, 
            ST_ID_plats number(10) not null, 
            EV_ID_of number(12,0) not null, 
            PR_innehåll_ST_plats_EV_of_ChangedAt timestamp not null,
            Metadata_PR_innehåll_ST_plats_EV_of number(10) not null,
            constraint PR_innehåll_ST_plats_EV_of_fkPR_innehåll foreign key (
                PR_ID_innehåll
            ) references anchors.PR_Föreställning(PR_ID),
            constraint PR_innehåll_ST_plats_EV_of_fkST_plats foreign key (
                ST_ID_plats
            ) references anchors.ST_Scen(ST_ID),
            constraint PR_innehåll_ST_plats_EV_of_fkEV_of foreign key (
                EV_ID_of
            ) references nexuses.EV_Händelse(EV_ID),
            constraint PR_innehåll_ST_plats_EV_of_uqPR_innehåll unique (
                PR_ID_innehåll,
                PR_innehåll_ST_plats_EV_of_ChangedAt
            ),
            constraint PR_innehåll_ST_plats_EV_of_uqST_plats unique (
                ST_ID_plats,
                PR_innehåll_ST_plats_EV_of_ChangedAt
            ),
            constraint pkPR_innehåll_ST_plats_EV_of primary key (
                PR_ID_innehåll,
                ST_ID_plats,
                EV_ID_of,
                PR_innehåll_ST_plats_EV_of_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
