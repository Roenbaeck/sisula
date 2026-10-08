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
    ) references anchors."AC_Actor"("AC_ID") RELY, 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_with" foreign key (
        "AC_ID_with"
    ) references anchors."AC_Actor"("AC_ID") RELY, 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references knots."ONG_Ongoing"("ONG_ID") RELY,
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
    ) references anchors."AC_Actor"("AC_ID") RELY, 
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
CREATE SEQUENCE IF NOT EXISTS ties."EV_in_AC_wasCast_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_wasCast_Posit" (
    "EV_in_AC_wasCast_ID" int default ties."EV_in_AC_wasCast_Posit_ID_SEQ".nextval not null, 
    "EV_ID_in" numeric(12,0) not null, 
    "AC_ID_wasCast" smallint not null, 
    constraint "EV_in_AC_wasCast_Posit_fkEV_in" foreign key (
        "EV_ID_in"
    ) references nexuses."EV_Event"("EV_ID") RELY, 
    constraint "EV_in_AC_wasCast_Posit_fkAC_wasCast" foreign key (
        "AC_ID_wasCast"
    ) references anchors."AC_Actor"("AC_ID") RELY, 
    constraint "pkEV_in_AC_wasCast_Posit" primary key (
        "EV_in_AC_wasCast_ID"
    ) RELY,
    constraint "uqEV_in_AC_wasCast" unique (
        "EV_ID_in",
        "AC_ID_wasCast"
    ) RELY
) CLUSTER BY (
    "EV_ID_in",
    "AC_ID_wasCast"
);
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_wasCast_Annex" (
    "EV_in_AC_wasCast_ID" int not null,
    "EV_in_AC_wasCast_PositedAt" datetime not null,
    "EV_in_AC_wasCast_Reliability" decimal(5,2) not null,
    "Metadata_EV_in_AC_wasCast" int not null,
    constraint "fkEV_in_AC_wasCast_Annex" foreign key (
        "EV_in_AC_wasCast_ID"
    ) references ties."EV_in_AC_wasCast_Posit"("EV_in_AC_wasCast_ID") RELY,
    constraint "pkEV_in_AC_wasCast_Annex" primary key (
        "EV_in_AC_wasCast_ID",
        "EV_in_AC_wasCast_PositedAt"
    ) RELY
) CLUSTER BY ("EV_in_AC_wasCast_ID", "EV_in_AC_wasCast_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."AC_part_PR_in_RAT_got_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_part_PR_in_RAT_got_Posit" (
    "AC_part_PR_in_RAT_got_ID" int default ties."AC_part_PR_in_RAT_got_Posit_ID_SEQ".nextval not null, 
    "AC_ID_part" smallint not null, 
    "PR_ID_in" number(10,0) not null, 
    "RAT_ID_got" tinyint not null,
    "AC_part_PR_in_RAT_got_ChangedAt" datetime not null,
    constraint "AC_part_PR_in_RAT_got_Posit_fkAC_part" foreign key (
        "AC_ID_part"
    ) references anchors."AC_Actor"("AC_ID") RELY, 
    constraint "AC_part_PR_in_RAT_got_Posit_fkPR_in" foreign key (
        "PR_ID_in"
    ) references anchors."PR_Program"("PR_ID") RELY, 
    constraint "AC_part_PR_in_RAT_got_Posit_fkRAT_got" foreign key (
        "RAT_ID_got"
    ) references knots."RAT_Rating"("RAT_ID") RELY,
    constraint "pkAC_part_PR_in_RAT_got_Posit" primary key (
        "AC_part_PR_in_RAT_got_ID"
    ) RELY,
    constraint "uqAC_part_PR_in_RAT_got" unique (
        "AC_ID_part",
        "PR_ID_in",
        "AC_part_PR_in_RAT_got_ChangedAt",
        "RAT_ID_got"
    ) RELY
) CLUSTER BY (
    "AC_ID_part",
    "PR_ID_in",
    "AC_part_PR_in_RAT_got_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."AC_part_PR_in_RAT_got_Annex" (
    "AC_part_PR_in_RAT_got_ID" int not null,
    "AC_part_PR_in_RAT_got_PositedAt" datetime not null,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2) not null,
    "Metadata_AC_part_PR_in_RAT_got" int not null,
    constraint "fkAC_part_PR_in_RAT_got_Annex" foreign key (
        "AC_part_PR_in_RAT_got_ID"
    ) references ties."AC_part_PR_in_RAT_got_Posit"("AC_part_PR_in_RAT_got_ID") RELY,
    constraint "pkAC_part_PR_in_RAT_got_Annex" primary key (
        "AC_part_PR_in_RAT_got_ID",
        "AC_part_PR_in_RAT_got_PositedAt"
    ) RELY
) CLUSTER BY ("AC_part_PR_in_RAT_got_ID", "AC_part_PR_in_RAT_got_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."ST_at_PR_isPlaying_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_isPlaying_Posit" (
    "ST_at_PR_isPlaying_ID" int default ties."ST_at_PR_isPlaying_Posit_ID_SEQ".nextval not null, 
    "ST_ID_at" int not null, 
    "PR_ID_isPlaying" number(10,0) not null, 
    "ST_at_PR_isPlaying_ChangedAt" datetime not null,
    constraint "ST_at_PR_isPlaying_Posit_fkST_at" foreign key (
        "ST_ID_at"
    ) references anchors."ST_Stage"("ST_ID") RELY, 
    constraint "ST_at_PR_isPlaying_Posit_fkPR_isPlaying" foreign key (
        "PR_ID_isPlaying"
    ) references anchors."PR_Program"("PR_ID") RELY, 
    constraint "pkST_at_PR_isPlaying_Posit" primary key (
        "ST_at_PR_isPlaying_ID"
    ) RELY,
    constraint "uqST_at_PR_isPlaying" unique (
        "ST_ID_at",
        "PR_ID_isPlaying",
        "ST_at_PR_isPlaying_ChangedAt"
    ) RELY
) CLUSTER BY (
    "ST_ID_at",
    "PR_ID_isPlaying",
    "ST_at_PR_isPlaying_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_isPlaying_Annex" (
    "ST_at_PR_isPlaying_ID" int not null,
    "ST_at_PR_isPlaying_PositedAt" datetime not null,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2) not null,
    "Metadata_ST_at_PR_isPlaying" int not null,
    constraint "fkST_at_PR_isPlaying_Annex" foreign key (
        "ST_at_PR_isPlaying_ID"
    ) references ties."ST_at_PR_isPlaying_Posit"("ST_at_PR_isPlaying_ID") RELY,
    constraint "pkST_at_PR_isPlaying_Annex" primary key (
        "ST_at_PR_isPlaying_ID",
        "ST_at_PR_isPlaying_PositedAt"
    ) RELY
) CLUSTER BY ("ST_at_PR_isPlaying_ID", "ST_at_PR_isPlaying_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."AC_parent_AC_child_PAT_having_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_parent_AC_child_PAT_having_Posit" (
    "AC_parent_AC_child_PAT_having_ID" int default ties."AC_parent_AC_child_PAT_having_Posit_ID_SEQ".nextval not null, 
    "AC_ID_parent" smallint not null, 
    "AC_ID_child" smallint not null, 
    "PAT_ID_having" tinyint not null,
    constraint "AC_parent_AC_child_PAT_having_Posit_fkAC_parent" foreign key (
        "AC_ID_parent"
    ) references anchors."AC_Actor"("AC_ID") RELY, 
    constraint "AC_parent_AC_child_PAT_having_Posit_fkAC_child" foreign key (
        "AC_ID_child"
    ) references anchors."AC_Actor"("AC_ID") RELY, 
    constraint "AC_parent_AC_child_PAT_having_Posit_fkPAT_having" foreign key (
        "PAT_ID_having"
    ) references knots."PAT_ParentalType"("PAT_ID") RELY,
    constraint "pkAC_parent_AC_child_PAT_having_Posit" primary key (
        "AC_parent_AC_child_PAT_having_ID"
    ) RELY,
    constraint "uqAC_parent_AC_child_PAT_having" unique (
        "AC_ID_parent",
        "AC_ID_child",
        "PAT_ID_having"
    ) RELY
) CLUSTER BY (
    "AC_ID_parent",
    "AC_ID_child",
    "PAT_ID_having"
);
CREATE TABLE IF NOT EXISTS ties."AC_parent_AC_child_PAT_having_Annex" (
    "AC_parent_AC_child_PAT_having_ID" int not null,
    "AC_parent_AC_child_PAT_having_PositedAt" datetime not null,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2) not null,
    "Metadata_AC_parent_AC_child_PAT_having" int not null,
    constraint "fkAC_parent_AC_child_PAT_having_Annex" foreign key (
        "AC_parent_AC_child_PAT_having_ID"
    ) references ties."AC_parent_AC_child_PAT_having_Posit"("AC_parent_AC_child_PAT_having_ID") RELY,
    constraint "pkAC_parent_AC_child_PAT_having_Annex" primary key (
        "AC_parent_AC_child_PAT_having_ID",
        "AC_parent_AC_child_PAT_having_PositedAt"
    ) RELY
) CLUSTER BY ("AC_parent_AC_child_PAT_having_ID", "AC_parent_AC_child_PAT_having_PositedAt");
CREATE SEQUENCE IF NOT EXISTS ties."PR_content_ST_location_EV_of_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."PR_content_ST_location_EV_of_Posit" (
    "PR_content_ST_location_EV_of_ID" int default ties."PR_content_ST_location_EV_of_Posit_ID_SEQ".nextval not null, 
    "PR_ID_content" number(10,0) not null, 
    "ST_ID_location" int not null, 
    "EV_ID_of" numeric(12,0) not null, 
    "PR_content_ST_location_EV_of_ChangedAt" datetime not null,
    constraint "PR_content_ST_location_EV_of_Posit_fkPR_content" foreign key (
        "PR_ID_content"
    ) references anchors."PR_Program"("PR_ID") RELY, 
    constraint "PR_content_ST_location_EV_of_Posit_fkST_location" foreign key (
        "ST_ID_location"
    ) references anchors."ST_Stage"("ST_ID") RELY, 
    constraint "PR_content_ST_location_EV_of_Posit_fkEV_of" foreign key (
        "EV_ID_of"
    ) references nexuses."EV_Event"("EV_ID") RELY, 
    constraint "PR_content_ST_location_EV_of_Posit_uqPR_content" unique (
        "PR_ID_content",
        "PR_content_ST_location_EV_of_ChangedAt"
    ) RELY,
    constraint "PR_content_ST_location_EV_of_Posit_uqST_location" unique (
        "ST_ID_location",
        "PR_content_ST_location_EV_of_ChangedAt"
    ) RELY,
    constraint "pkPR_content_ST_location_EV_of_Posit" primary key (
        "PR_content_ST_location_EV_of_ID"
    ) RELY,
    constraint "uqPR_content_ST_location_EV_of" unique (
        "PR_content_ST_location_EV_of_ChangedAt",
        "PR_ID_content",
        "ST_ID_location",
        "EV_ID_of"
    ) RELY
) CLUSTER BY (
    "PR_ID_content",
    "ST_ID_location",
    "EV_ID_of",
    "PR_content_ST_location_EV_of_ChangedAt"
);
CREATE TABLE IF NOT EXISTS ties."PR_content_ST_location_EV_of_Annex" (
    "PR_content_ST_location_EV_of_ID" int not null,
    "PR_content_ST_location_EV_of_PositedAt" datetime not null,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2) not null,
    "Metadata_PR_content_ST_location_EV_of" int not null,
    constraint "fkPR_content_ST_location_EV_of_Annex" foreign key (
        "PR_content_ST_location_EV_of_ID"
    ) references ties."PR_content_ST_location_EV_of_Posit"("PR_content_ST_location_EV_of_ID") RELY,
    constraint "pkPR_content_ST_location_EV_of_Annex" primary key (
        "PR_content_ST_location_EV_of_ID",
        "PR_content_ST_location_EV_of_PositedAt"
    ) RELY
) CLUSTER BY ("PR_content_ST_location_EV_of_ID", "PR_content_ST_location_EV_of_PositedAt");
