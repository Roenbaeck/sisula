-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_holder_OB_item_GRD_grade table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_holder_OB_item_GRD_grade" (
    "SU_ID_holder" integer not null, 
    "OB_ID_item" integer not null, 
    "GRD_ID_grade" smallint not null,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp not null,
    "Metadata_SU_holder_OB_item_GRD_grade" integer not null,
    constraint "SU_holder_OB_item_GRD_grade_fkSU_holder" foreign key (
        "SU_ID_holder"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_holder_OB_item_GRD_grade_fkOB_item" foreign key (
        "OB_ID_item"
    ) references public."OB_Object"("OB_ID"), 
    constraint "SU_holder_OB_item_GRD_grade_fkGRD_grade" foreign key (
        "GRD_ID_grade"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_holder_OB_item_GRD_grade" primary key (
        "SU_ID_holder",
        "OB_ID_item",
        "SU_holder_OB_item_GRD_grade_ChangedAt"
    )
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_keeper_OB_thing_GRD_rank" (
    "SU_ID_keeper" integer not null, 
    "OB_ID_thing" integer not null, 
    "GRD_ID_rank" smallint not null,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp not null,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer not null,
    constraint "SU_keeper_OB_thing_GRD_rank_fkSU_keeper" foreign key (
        "SU_ID_keeper"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_keeper_OB_thing_GRD_rank_fkOB_thing" foreign key (
        "OB_ID_thing"
    ) references public."OB_Object"("OB_ID"), 
    constraint "SU_keeper_OB_thing_GRD_rank_fkGRD_rank" foreign key (
        "GRD_ID_rank"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_keeper_OB_thing_GRD_rank" primary key (
        "SU_ID_keeper",
        "OB_ID_thing",
        "SU_keeper_OB_thing_GRD_rank_ChangedAt"
    )
);
-- Static tie table ---------------------------------------------------------------------------------------------------
-- OB_part_SU_owner table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."OB_part_SU_owner" (
    "OB_ID_part" integer not null, 
    "SU_ID_owner" integer not null, 
    "Metadata_OB_part_SU_owner" integer not null,
    constraint "OB_part_SU_owner_fkOB_part" foreign key (
        "OB_ID_part"
    ) references public."OB_Object"("OB_ID"), 
    constraint "OB_part_SU_owner_fkSU_owner" foreign key (
        "SU_ID_owner"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "pkOB_part_SU_owner" primary key (
        "OB_ID_part"
    )
);
-- Historized tie table -----------------------------------------------------------------------------------------------
-- SU_partner_SU_with table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_partner_SU_with" (
    "SU_ID_partner" integer not null, 
    "SU_ID_with" integer not null, 
    "SU_partner_SU_with_ChangedAt" timestamp not null,
    "Metadata_SU_partner_SU_with" integer not null,
    constraint "SU_partner_SU_with_fkSU_partner" foreign key (
        "SU_ID_partner"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_partner_SU_with_fkSU_with" foreign key (
        "SU_ID_with"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_partner_SU_with_uqSU_partner" unique (
        "SU_ID_partner",
        "SU_partner_SU_with_ChangedAt"
    ),
    constraint "SU_partner_SU_with_uqSU_with" unique (
        "SU_ID_with",
        "SU_partner_SU_with_ChangedAt"
    ),
    constraint "pkSU_partner_SU_with" primary key (
        "SU_ID_partner",
        "SU_ID_with",
        "SU_partner_SU_with_ChangedAt"
    )
);
