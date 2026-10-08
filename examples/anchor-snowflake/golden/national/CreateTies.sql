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
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently" (
    "AC_ID_partner" smallint not null, 
    "AC_ID_with" smallint not null, 
    "ONG_ID_currently" tinyint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime not null,
    "Metadata_AC_partner_AC_with_ONG_currently" int not null,
    constraint "AC_partner_AC_with_ONG_currently_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_partner_AC_with_ONG_currently_fkAC_with" foreign key (
        "AC_ID_with"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_partner_AC_with_ONG_currently_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references knots."ONG_Pågående_ID"("ONG_ID") RELY,
    constraint "AC_partner_AC_with_ONG_currently_uqAC_partner" unique (
        "AC_ID_partner",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ) RELY,
    constraint "AC_partner_AC_with_ONG_currently_uqAC_with" unique (
        "AC_ID_with",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ) RELY,
    constraint "pkAC_partner_AC_with_ONG_currently" primary key (
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ) RELY
) CLUSTER BY (
    "AC_ID_partner",
    "AC_ID_with"
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of" (
    "AC_ID_subset" smallint not null, 
    "PN_ID_of" bigint not null, 
    "Metadata_AC_subset_PN_of" int not null,
    constraint "AC_subset_PN_of_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_subset_PN_of_fkPN_of" foreign key (
        "PN_ID_of"
    ) references anchors."PN_Person"("PN_ID") RELY, 
    constraint "AC_subset_PN_of_uqAC_subset" unique (
        "AC_ID_subset"
    ) RELY,
    constraint "AC_subset_PN_of_uqPN_of" unique (
        "PN_ID_of"
    ) RELY,
    constraint "pkAC_subset_PN_of" primary key (
        "AC_ID_subset",
        "PN_ID_of"
    ) RELY
) CLUSTER BY (
    "AC_ID_subset",
    "PN_ID_of"
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- EV_in_AC_rollsattes table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_rollsattes" (
    "EV_ID_in" numeric(12,0) not null, 
    "AC_ID_rollsattes" smallint not null, 
    "Metadata_EV_in_AC_rollsattes" int not null,
    constraint "EV_in_AC_rollsattes_fkEV_in" foreign key (
        "EV_ID_in"
    ) references nexuses."EV_Händelse"("EV_ID") RELY, 
    constraint "EV_in_AC_rollsattes_fkAC_rollsattes" foreign key (
        "AC_ID_rollsattes"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "pkEV_in_AC_rollsattes" primary key (
        "EV_ID_in",
        "AC_ID_rollsattes"
    ) RELY
) CLUSTER BY (
    "AC_ID_rollsattes"
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick" (
    "AC_ID_deltar" smallint not null, 
    "PR_ID_in" number(10,0) not null, 
    "RAT_ID_fick" tinyint not null,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime not null,
    "Metadata_AC_deltar_PR_in_RAT_fick" int not null,
    constraint "AC_deltar_PR_in_RAT_fick_fkAC_deltar" foreign key (
        "AC_ID_deltar"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_deltar_PR_in_RAT_fick_fkPR_in" foreign key (
        "PR_ID_in"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "AC_deltar_PR_in_RAT_fick_fkRAT_fick" foreign key (
        "RAT_ID_fick"
    ) references knots."RAT_Betyg_ID"("RAT_ID") RELY,
    constraint "pkAC_deltar_PR_in_RAT_fick" primary key (
        "AC_ID_deltar",
        "PR_ID_in",
        "AC_deltar_PR_in_RAT_fick_ChangedAt"
    ) RELY
) CLUSTER BY (
    "AC_ID_deltar",
    "PR_ID_in"
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- ST_at_PR_spelas table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_spelas" (
    "ST_ID_at" int not null, 
    "PR_ID_spelas" number(10,0) not null, 
    "ST_at_PR_spelas_ChangedAt" datetime not null,
    "Metadata_ST_at_PR_spelas" int not null,
    constraint "ST_at_PR_spelas_fkST_at" foreign key (
        "ST_ID_at"
    ) references anchors."ST_Scen"("ST_ID") RELY, 
    constraint "ST_at_PR_spelas_fkPR_spelas" foreign key (
        "PR_ID_spelas"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "pkST_at_PR_spelas" primary key (
        "ST_ID_at",
        "PR_ID_spelas",
        "ST_at_PR_spelas_ChangedAt"
    ) RELY
) CLUSTER BY (
    "ST_ID_at",
    "PR_ID_spelas"
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har" (
    "AC_ID_förälder" smallint not null, 
    "AC_ID_barn" smallint not null, 
    "PAT_ID_har" tinyint not null,
    "Metadata_AC_förälder_AC_barn_PAT_har" int not null,
    constraint "AC_förälder_AC_barn_PAT_har_fkAC_förälder" foreign key (
        "AC_ID_förälder"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_förälder_AC_barn_PAT_har_fkAC_barn" foreign key (
        "AC_ID_barn"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_förälder_AC_barn_PAT_har_fkPAT_har" foreign key (
        "PAT_ID_har"
    ) references knots."PAT_Föräldratyp_ID"("PAT_ID") RELY,
    constraint "pkAC_förälder_AC_barn_PAT_har" primary key (
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har"
    ) RELY
) CLUSTER BY (
    "AC_ID_förälder",
    "AC_ID_barn"
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of" (
    "PR_ID_innehåll" number(10,0) not null, 
    "ST_ID_plats" int not null, 
    "EV_ID_of" numeric(12,0) not null, 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime not null,
    "Metadata_PR_innehåll_ST_plats_EV_of" int not null,
    constraint "PR_innehåll_ST_plats_EV_of_fkPR_innehåll" foreign key (
        "PR_ID_innehåll"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_fkST_plats" foreign key (
        "ST_ID_plats"
    ) references anchors."ST_Scen"("ST_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_fkEV_of" foreign key (
        "EV_ID_of"
    ) references nexuses."EV_Händelse"("EV_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_uqPR_innehåll" unique (
        "PR_ID_innehåll",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) RELY,
    constraint "PR_innehåll_ST_plats_EV_of_uqST_plats" unique (
        "ST_ID_plats",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) RELY,
    constraint "pkPR_innehåll_ST_plats_EV_of" primary key (
        "PR_ID_innehåll",
        "ST_ID_plats",
        "EV_ID_of",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) RELY
) CLUSTER BY (
    "PR_ID_innehåll",
    "ST_ID_plats"
);
