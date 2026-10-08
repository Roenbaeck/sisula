-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Posit" (
    "AC_partner_AC_with_ONG_currently_ID" int default ties."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ".nextval not null, 
    "AC_ID_partner" smallint not null, 
    "AC_ID_with" smallint not null, 
    "ONG_ID_currently" tinyint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime not null,
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_with" foreign key (
        "AC_ID_with"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references knots."ONG_Pågående"("ONG_ID") RELY,
    constraint "AC_partner_AC_with_ONG_currently_Posit_uqAC_partner" unique (
        "AC_ID_partner",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ) RELY,
    constraint "AC_partner_AC_with_ONG_currently_Posit_uqAC_with" unique (
        "AC_ID_with",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ) RELY,
    constraint "pkAC_partner_AC_with_ONG_currently_Posit" primary key (
        "AC_partner_AC_with_ONG_currently_ID"
    ) RELY,
    constraint "uqAC_partner_AC_with_ONG_currently" unique (
        "AC_partner_AC_with_ONG_currently_ChangedAt",
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently"
    ) RELY
) CLUSTER BY (
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Annex" (
    "AC_partner_AC_with_ONG_currently_ID" int not null,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime not null,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2) not null,
    "Metadata_AC_partner_AC_with_ONG_currently" int not null,
    constraint "fkAC_partner_AC_with_ONG_currently_Annex" foreign key (
        "AC_partner_AC_with_ONG_currently_ID"
    ) references ties."AC_partner_AC_with_ONG_currently_Posit"("AC_partner_AC_with_ONG_currently_ID") RELY,
    constraint "pkAC_partner_AC_with_ONG_currently_Annex" primary key (
        "AC_partner_AC_with_ONG_currently_ID",
        "AC_partner_AC_with_ONG_currently_PositedAt"
    ) RELY
) CLUSTER BY ("AC_partner_AC_with_ONG_currently_ID", "AC_partner_AC_with_ONG_currently_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."AC_subset_PN_of_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of_Posit" (
    "AC_subset_PN_of_ID" int default ties."AC_subset_PN_of_Posit_ID_SEQ".nextval not null, 
    "AC_ID_subset" smallint not null, 
    "PN_ID_of" bigint not null, 
    constraint "AC_subset_PN_of_Posit_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_subset_PN_of_Posit_fkPN_of" foreign key (
        "PN_ID_of"
    ) references anchors."PN_Person"("PN_ID") RELY, 
    constraint "AC_subset_PN_of_Posit_uqAC_subset" unique (
        "AC_ID_subset"
    ) RELY,
    constraint "AC_subset_PN_of_Posit_uqPN_of" unique (
        "PN_ID_of"
    ) RELY,
    constraint "pkAC_subset_PN_of_Posit" primary key (
        "AC_subset_PN_of_ID"
    ) RELY,
    constraint "uqAC_subset_PN_of" unique (
        "AC_ID_subset",
        "PN_ID_of"
    ) RELY
) CLUSTER BY (
    "AC_ID_subset",
    "PN_ID_of"
);
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of_Annex" (
    "AC_subset_PN_of_ID" int not null,
    "AC_subset_PN_of_PositedAt" datetime not null,
    "AC_subset_PN_of_Reliability" decimal(5,2) not null,
    "Metadata_AC_subset_PN_of" int not null,
    constraint "fkAC_subset_PN_of_Annex" foreign key (
        "AC_subset_PN_of_ID"
    ) references ties."AC_subset_PN_of_Posit"("AC_subset_PN_of_ID") RELY,
    constraint "pkAC_subset_PN_of_Annex" primary key (
        "AC_subset_PN_of_ID",
        "AC_subset_PN_of_PositedAt"
    ) RELY
) CLUSTER BY ("AC_subset_PN_of_ID", "AC_subset_PN_of_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."EV_in_AC_rollsattes_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_rollsattes_Posit" (
    "EV_in_AC_rollsattes_ID" int default ties."EV_in_AC_rollsattes_Posit_ID_SEQ".nextval not null, 
    "EV_ID_in" numeric(12,0) not null, 
    "AC_ID_rollsattes" smallint not null, 
    constraint "EV_in_AC_rollsattes_Posit_fkEV_in" foreign key (
        "EV_ID_in"
    ) references nexuses."EV_Händelse"("EV_ID") RELY, 
    constraint "EV_in_AC_rollsattes_Posit_fkAC_rollsattes" foreign key (
        "AC_ID_rollsattes"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "pkEV_in_AC_rollsattes_Posit" primary key (
        "EV_in_AC_rollsattes_ID"
    ) RELY,
    constraint "uqEV_in_AC_rollsattes" unique (
        "EV_ID_in",
        "AC_ID_rollsattes"
    ) RELY
) CLUSTER BY (
    "EV_ID_in",
    "AC_ID_rollsattes"
);
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_rollsattes_Annex" (
    "EV_in_AC_rollsattes_ID" int not null,
    "EV_in_AC_rollsattes_PositedAt" datetime not null,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2) not null,
    "Metadata_EV_in_AC_rollsattes" int not null,
    constraint "fkEV_in_AC_rollsattes_Annex" foreign key (
        "EV_in_AC_rollsattes_ID"
    ) references ties."EV_in_AC_rollsattes_Posit"("EV_in_AC_rollsattes_ID") RELY,
    constraint "pkEV_in_AC_rollsattes_Annex" primary key (
        "EV_in_AC_rollsattes_ID",
        "EV_in_AC_rollsattes_PositedAt"
    ) RELY
) CLUSTER BY ("EV_in_AC_rollsattes_ID", "EV_in_AC_rollsattes_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick_Posit" (
    "AC_deltar_PR_in_RAT_fick_ID" int default ties."AC_deltar_PR_in_RAT_fick_Posit_ID_SEQ".nextval not null, 
    "AC_ID_deltar" smallint not null, 
    "PR_ID_in" number(10,0) not null, 
    "RAT_ID_fick" tinyint not null,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime not null,
    constraint "AC_deltar_PR_in_RAT_fick_Posit_fkAC_deltar" foreign key (
        "AC_ID_deltar"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_deltar_PR_in_RAT_fick_Posit_fkPR_in" foreign key (
        "PR_ID_in"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "AC_deltar_PR_in_RAT_fick_Posit_fkRAT_fick" foreign key (
        "RAT_ID_fick"
    ) references knots."RAT_Betyg"("RAT_ID") RELY,
    constraint "pkAC_deltar_PR_in_RAT_fick_Posit" primary key (
        "AC_deltar_PR_in_RAT_fick_ID"
    ) RELY,
    constraint "uqAC_deltar_PR_in_RAT_fick" unique (
        "AC_ID_deltar",
        "PR_ID_in",
        "AC_deltar_PR_in_RAT_fick_ChangedAt",
        "RAT_ID_fick"
    ) RELY
) CLUSTER BY (
    "AC_ID_deltar",
    "PR_ID_in",
    "AC_deltar_PR_in_RAT_fick_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick_Annex" (
    "AC_deltar_PR_in_RAT_fick_ID" int not null,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime not null,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2) not null,
    "Metadata_AC_deltar_PR_in_RAT_fick" int not null,
    constraint "fkAC_deltar_PR_in_RAT_fick_Annex" foreign key (
        "AC_deltar_PR_in_RAT_fick_ID"
    ) references ties."AC_deltar_PR_in_RAT_fick_Posit"("AC_deltar_PR_in_RAT_fick_ID") RELY,
    constraint "pkAC_deltar_PR_in_RAT_fick_Annex" primary key (
        "AC_deltar_PR_in_RAT_fick_ID",
        "AC_deltar_PR_in_RAT_fick_PositedAt"
    ) RELY
) CLUSTER BY ("AC_deltar_PR_in_RAT_fick_ID", "AC_deltar_PR_in_RAT_fick_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."ST_at_PR_spelas_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_spelas_Posit" (
    "ST_at_PR_spelas_ID" int default ties."ST_at_PR_spelas_Posit_ID_SEQ".nextval not null, 
    "ST_ID_at" int not null, 
    "PR_ID_spelas" number(10,0) not null, 
    "ST_at_PR_spelas_ChangedAt" datetime not null,
    constraint "ST_at_PR_spelas_Posit_fkST_at" foreign key (
        "ST_ID_at"
    ) references anchors."ST_Scen"("ST_ID") RELY, 
    constraint "ST_at_PR_spelas_Posit_fkPR_spelas" foreign key (
        "PR_ID_spelas"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "pkST_at_PR_spelas_Posit" primary key (
        "ST_at_PR_spelas_ID"
    ) RELY,
    constraint "uqST_at_PR_spelas" unique (
        "ST_ID_at",
        "PR_ID_spelas",
        "ST_at_PR_spelas_ChangedAt"
    ) RELY
) CLUSTER BY (
    "ST_ID_at",
    "PR_ID_spelas",
    "ST_at_PR_spelas_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_spelas_Annex" (
    "ST_at_PR_spelas_ID" int not null,
    "ST_at_PR_spelas_PositedAt" datetime not null,
    "ST_at_PR_spelas_Reliability" decimal(5,2) not null,
    "Metadata_ST_at_PR_spelas" int not null,
    constraint "fkST_at_PR_spelas_Annex" foreign key (
        "ST_at_PR_spelas_ID"
    ) references ties."ST_at_PR_spelas_Posit"("ST_at_PR_spelas_ID") RELY,
    constraint "pkST_at_PR_spelas_Annex" primary key (
        "ST_at_PR_spelas_ID",
        "ST_at_PR_spelas_PositedAt"
    ) RELY
) CLUSTER BY ("ST_at_PR_spelas_ID", "ST_at_PR_spelas_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har_Posit" (
    "AC_förälder_AC_barn_PAT_har_ID" int default ties."AC_förälder_AC_barn_PAT_har_Posit_ID_SEQ".nextval not null, 
    "AC_ID_förälder" smallint not null, 
    "AC_ID_barn" smallint not null, 
    "PAT_ID_har" tinyint not null,
    constraint "AC_förälder_AC_barn_PAT_har_Posit_fkAC_förälder" foreign key (
        "AC_ID_förälder"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_förälder_AC_barn_PAT_har_Posit_fkAC_barn" foreign key (
        "AC_ID_barn"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_förälder_AC_barn_PAT_har_Posit_fkPAT_har" foreign key (
        "PAT_ID_har"
    ) references knots."PAT_Föräldratyp"("PAT_ID") RELY,
    constraint "pkAC_förälder_AC_barn_PAT_har_Posit" primary key (
        "AC_förälder_AC_barn_PAT_har_ID"
    ) RELY,
    constraint "uqAC_förälder_AC_barn_PAT_har" unique (
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har"
    ) RELY
) CLUSTER BY (
    "AC_ID_förälder",
    "AC_ID_barn",
    "PAT_ID_har"
);
CREATE TABLE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har_Annex" (
    "AC_förälder_AC_barn_PAT_har_ID" int not null,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime not null,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2) not null,
    "Metadata_AC_förälder_AC_barn_PAT_har" int not null,
    constraint "fkAC_förälder_AC_barn_PAT_har_Annex" foreign key (
        "AC_förälder_AC_barn_PAT_har_ID"
    ) references ties."AC_förälder_AC_barn_PAT_har_Posit"("AC_förälder_AC_barn_PAT_har_ID") RELY,
    constraint "pkAC_förälder_AC_barn_PAT_har_Annex" primary key (
        "AC_förälder_AC_barn_PAT_har_ID",
        "AC_förälder_AC_barn_PAT_har_PositedAt"
    ) RELY
) CLUSTER BY ("AC_förälder_AC_barn_PAT_har_ID", "AC_förälder_AC_barn_PAT_har_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of_Posit" (
    "PR_innehåll_ST_plats_EV_of_ID" int default ties."PR_innehåll_ST_plats_EV_of_Posit_ID_SEQ".nextval not null, 
    "PR_ID_innehåll" number(10,0) not null, 
    "ST_ID_plats" int not null, 
    "EV_ID_of" numeric(12,0) not null, 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime not null,
    constraint "PR_innehåll_ST_plats_EV_of_Posit_fkPR_innehåll" foreign key (
        "PR_ID_innehåll"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_Posit_fkST_plats" foreign key (
        "ST_ID_plats"
    ) references anchors."ST_Scen"("ST_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_Posit_fkEV_of" foreign key (
        "EV_ID_of"
    ) references nexuses."EV_Händelse"("EV_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_Posit_uqPR_innehåll" unique (
        "PR_ID_innehåll",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) RELY,
    constraint "PR_innehåll_ST_plats_EV_of_Posit_uqST_plats" unique (
        "ST_ID_plats",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) RELY,
    constraint "pkPR_innehåll_ST_plats_EV_of_Posit" primary key (
        "PR_innehåll_ST_plats_EV_of_ID"
    ) RELY,
    constraint "uqPR_innehåll_ST_plats_EV_of" unique (
        "PR_innehåll_ST_plats_EV_of_ChangedAt",
        "PR_ID_innehåll",
        "ST_ID_plats",
        "EV_ID_of"
    ) RELY
) CLUSTER BY (
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of_Annex" (
    "PR_innehåll_ST_plats_EV_of_ID" int not null,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime not null,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2) not null,
    "Metadata_PR_innehåll_ST_plats_EV_of" int not null,
    constraint "fkPR_innehåll_ST_plats_EV_of_Annex" foreign key (
        "PR_innehåll_ST_plats_EV_of_ID"
    ) references ties."PR_innehåll_ST_plats_EV_of_Posit"("PR_innehåll_ST_plats_EV_of_ID") RELY,
    constraint "pkPR_innehåll_ST_plats_EV_of_Annex" primary key (
        "PR_innehåll_ST_plats_EV_of_ID",
        "PR_innehåll_ST_plats_EV_of_PositedAt"
    ) RELY
) CLUSTER BY ("PR_innehåll_ST_plats_EV_of_ID", "PR_innehåll_ST_plats_EV_of_PositedAt");
