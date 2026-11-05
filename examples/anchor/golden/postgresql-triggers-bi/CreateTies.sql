-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS public."SU_holder_OB_item_GRD_grade_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_holder_OB_item_GRD_grade_Posit" (
    "SU_holder_OB_item_GRD_grade_ID" integer default nextval('public."SU_holder_OB_item_GRD_grade_Posit_ID_SEQ"') not null, 
    "SU_ID_holder" integer not null, 
    "OB_ID_item" integer not null, 
    "GRD_ID_grade" smallint not null,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp not null,
    constraint "SU_holder_OB_item_GRD_grade_Posit_fkSU_holder" foreign key (
        "SU_ID_holder"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_holder_OB_item_GRD_grade_Posit_fkOB_item" foreign key (
        "OB_ID_item"
    ) references public."OB_Object"("OB_ID"), 
    constraint "SU_holder_OB_item_GRD_grade_Posit_fkGRD_grade" foreign key (
        "GRD_ID_grade"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_holder_OB_item_GRD_grade_Posit" primary key (
        "SU_holder_OB_item_GRD_grade_ID"
    ),
    constraint "uqSU_holder_OB_item_GRD_grade" unique (
        "SU_ID_holder",
        "OB_ID_item",
        "SU_holder_OB_item_GRD_grade_ChangedAt",
        "GRD_ID_grade"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_holder_OB_item_GRD_grade_Annex" (
    "SU_holder_OB_item_GRD_grade_ID" integer not null,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp not null,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2) not null,
    "Metadata_SU_holder_OB_item_GRD_grade" integer not null,
    constraint "fkSU_holder_OB_item_GRD_grade_Annex" foreign key (
        "SU_holder_OB_item_GRD_grade_ID"
    ) references public."SU_holder_OB_item_GRD_grade_Posit"("SU_holder_OB_item_GRD_grade_ID"),
    constraint "pkSU_holder_OB_item_GRD_grade_Annex" primary key (
        "SU_holder_OB_item_GRD_grade_ID",
        "SU_holder_OB_item_GRD_grade_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_keeper_OB_thing_GRD_rank_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_keeper_OB_thing_GRD_rank_Posit" (
    "SU_keeper_OB_thing_GRD_rank_ID" integer default nextval('public."SU_keeper_OB_thing_GRD_rank_Posit_ID_SEQ"') not null, 
    "SU_ID_keeper" integer not null, 
    "OB_ID_thing" integer not null, 
    "GRD_ID_rank" smallint not null,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp not null,
    constraint "SU_keeper_OB_thing_GRD_rank_Posit_fkSU_keeper" foreign key (
        "SU_ID_keeper"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_keeper_OB_thing_GRD_rank_Posit_fkOB_thing" foreign key (
        "OB_ID_thing"
    ) references public."OB_Object"("OB_ID"), 
    constraint "SU_keeper_OB_thing_GRD_rank_Posit_fkGRD_rank" foreign key (
        "GRD_ID_rank"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_keeper_OB_thing_GRD_rank_Posit" primary key (
        "SU_keeper_OB_thing_GRD_rank_ID"
    ),
    constraint "uqSU_keeper_OB_thing_GRD_rank" unique (
        "SU_ID_keeper",
        "OB_ID_thing",
        "SU_keeper_OB_thing_GRD_rank_ChangedAt",
        "GRD_ID_rank"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_keeper_OB_thing_GRD_rank_Annex" (
    "SU_keeper_OB_thing_GRD_rank_ID" integer not null,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp not null,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2) not null,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer not null,
    constraint "fkSU_keeper_OB_thing_GRD_rank_Annex" foreign key (
        "SU_keeper_OB_thing_GRD_rank_ID"
    ) references public."SU_keeper_OB_thing_GRD_rank_Posit"("SU_keeper_OB_thing_GRD_rank_ID"),
    constraint "pkSU_keeper_OB_thing_GRD_rank_Annex" primary key (
        "SU_keeper_OB_thing_GRD_rank_ID",
        "SU_keeper_OB_thing_GRD_rank_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."OB_part_SU_owner_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."OB_part_SU_owner_Posit" (
    "OB_part_SU_owner_ID" integer default nextval('public."OB_part_SU_owner_Posit_ID_SEQ"') not null, 
    "OB_ID_part" integer not null, 
    "SU_ID_owner" integer not null, 
    constraint "OB_part_SU_owner_Posit_fkOB_part" foreign key (
        "OB_ID_part"
    ) references public."OB_Object"("OB_ID"), 
    constraint "OB_part_SU_owner_Posit_fkSU_owner" foreign key (
        "SU_ID_owner"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "pkOB_part_SU_owner_Posit" primary key (
        "OB_part_SU_owner_ID"
    ),
    constraint "uqOB_part_SU_owner" unique (
        "OB_ID_part",
        "SU_ID_owner"
    )
);
CREATE TABLE IF NOT EXISTS public."OB_part_SU_owner_Annex" (
    "OB_part_SU_owner_ID" integer not null,
    "OB_part_SU_owner_PositedAt" timestamp not null,
    "OB_part_SU_owner_Reliability" decimal(5,2) not null,
    "Metadata_OB_part_SU_owner" integer not null,
    constraint "fkOB_part_SU_owner_Annex" foreign key (
        "OB_part_SU_owner_ID"
    ) references public."OB_part_SU_owner_Posit"("OB_part_SU_owner_ID"),
    constraint "pkOB_part_SU_owner_Annex" primary key (
        "OB_part_SU_owner_ID",
        "OB_part_SU_owner_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_partner_SU_with_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_partner_SU_with_Posit" (
    "SU_partner_SU_with_ID" integer default nextval('public."SU_partner_SU_with_Posit_ID_SEQ"') not null, 
    "SU_ID_partner" integer not null, 
    "SU_ID_with" integer not null, 
    "SU_partner_SU_with_ChangedAt" timestamp not null,
    constraint "SU_partner_SU_with_Posit_fkSU_partner" foreign key (
        "SU_ID_partner"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_partner_SU_with_Posit_fkSU_with" foreign key (
        "SU_ID_with"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_partner_SU_with_Posit_uqSU_partner" unique (
        "SU_ID_partner",
        "SU_partner_SU_with_ChangedAt"
    ),
    constraint "SU_partner_SU_with_Posit_uqSU_with" unique (
        "SU_ID_with",
        "SU_partner_SU_with_ChangedAt"
    ),
    constraint "pkSU_partner_SU_with_Posit" primary key (
        "SU_partner_SU_with_ID"
    ),
    constraint "uqSU_partner_SU_with" unique (
        "SU_partner_SU_with_ChangedAt",
        "SU_ID_partner",
        "SU_ID_with"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_partner_SU_with_Annex" (
    "SU_partner_SU_with_ID" integer not null,
    "SU_partner_SU_with_PositedAt" timestamp not null,
    "SU_partner_SU_with_Reliability" decimal(5,2) not null,
    "Metadata_SU_partner_SU_with" integer not null,
    constraint "fkSU_partner_SU_with_Annex" foreign key (
        "SU_partner_SU_with_ID"
    ) references public."SU_partner_SU_with_Posit"("SU_partner_SU_with_ID"),
    constraint "pkSU_partner_SU_with_Annex" primary key (
        "SU_partner_SU_with_ID",
        "SU_partner_SU_with_PositedAt"
    )
);
