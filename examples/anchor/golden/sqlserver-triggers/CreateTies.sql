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
IF Object_ID('dbo.SU_holder_OB_item_GRD_grade', 'U') IS NULL
CREATE TABLE [dbo].[SU_holder_OB_item_GRD_grade] (
    SU_ID_holder int not null, 
    OB_ID_item int not null, 
    GRD_ID_grade tinyint not null,
    SU_holder_OB_item_GRD_grade_ChangedAt datetime2 not null,
    Metadata_SU_holder_OB_item_GRD_grade int not null,
    constraint SU_holder_OB_item_GRD_grade_fkSU_holder foreign key (
        SU_ID_holder
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_holder_OB_item_GRD_grade_fkOB_item foreign key (
        OB_ID_item
    ) references [dbo].[OB_Object](OB_ID), 
    constraint SU_holder_OB_item_GRD_grade_fkGRD_grade foreign key (
        GRD_ID_grade
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_holder_OB_item_GRD_grade primary key (
        SU_ID_holder asc,
        OB_ID_item asc,
        SU_holder_OB_item_GRD_grade_ChangedAt desc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_keeper_OB_thing_GRD_rank', 'U') IS NULL
CREATE TABLE [dbo].[SU_keeper_OB_thing_GRD_rank] (
    SU_ID_keeper int not null, 
    OB_ID_thing int not null, 
    GRD_ID_rank tinyint not null,
    SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
    Metadata_SU_keeper_OB_thing_GRD_rank int not null,
    constraint SU_keeper_OB_thing_GRD_rank_fkSU_keeper foreign key (
        SU_ID_keeper
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_keeper_OB_thing_GRD_rank_fkOB_thing foreign key (
        OB_ID_thing
    ) references [dbo].[OB_Object](OB_ID), 
    constraint SU_keeper_OB_thing_GRD_rank_fkGRD_rank foreign key (
        GRD_ID_rank
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_keeper_OB_thing_GRD_rank primary key (
        SU_ID_keeper asc,
        OB_ID_thing asc,
        SU_keeper_OB_thing_GRD_rank_ChangedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- OB_part_SU_owner table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_part_SU_owner', 'U') IS NULL
CREATE TABLE [dbo].[OB_part_SU_owner] (
    OB_ID_part int not null, 
    SU_ID_owner int not null, 
    Metadata_OB_part_SU_owner int not null,
    constraint OB_part_SU_owner_fkOB_part foreign key (
        OB_ID_part
    ) references [dbo].[OB_Object](OB_ID), 
    constraint OB_part_SU_owner_fkSU_owner foreign key (
        SU_ID_owner
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint pkOB_part_SU_owner primary key (
        OB_ID_part asc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_partner_SU_with table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_partner_SU_with', 'U') IS NULL
CREATE TABLE [dbo].[SU_partner_SU_with] (
    SU_ID_partner int not null, 
    SU_ID_with int not null, 
    SU_partner_SU_with_ChangedAt datetime2 not null,
    Metadata_SU_partner_SU_with int not null,
    constraint SU_partner_SU_with_fkSU_partner foreign key (
        SU_ID_partner
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_partner_SU_with_fkSU_with foreign key (
        SU_ID_with
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_partner_SU_with_uqSU_partner unique (
        SU_ID_partner,
        SU_partner_SU_with_ChangedAt
    ),
    constraint SU_partner_SU_with_uqSU_with unique (
        SU_ID_with,
        SU_partner_SU_with_ChangedAt
    ),
    constraint pkSU_partner_SU_with primary key (
        SU_ID_partner asc,
        SU_ID_with asc,
        SU_partner_SU_with_ChangedAt desc
    )
);
GO
