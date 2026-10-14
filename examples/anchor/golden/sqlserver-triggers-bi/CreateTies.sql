-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_holder_OB_item_GRD_grade_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_holder_OB_item_GRD_grade_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_holder_OB_item_GRD_grade_Posit] (
    SU_holder_OB_item_GRD_grade_ID int IDENTITY(1,1) not null,
    SU_ID_holder int not null, 
    OB_ID_item int not null, 
    GRD_ID_grade tinyint not null,
    SU_holder_OB_item_GRD_grade_ChangedAt datetime2 not null,
    constraint SU_holder_OB_item_GRD_grade_Posit_fkSU_holder foreign key (
        SU_ID_holder
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_holder_OB_item_GRD_grade_Posit_fkOB_item foreign key (
        OB_ID_item
    ) references [dbo].[OB_Object](OB_ID), 
    constraint SU_holder_OB_item_GRD_grade_Posit_fkGRD_grade foreign key (
        GRD_ID_grade
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_holder_OB_item_GRD_grade_Posit primary key nonclustered (
        SU_holder_OB_item_GRD_grade_ID asc
    ),
    constraint uqSU_holder_OB_item_GRD_grade unique clustered (
        SU_ID_holder asc,
        OB_ID_item asc,
        SU_holder_OB_item_GRD_grade_ChangedAt desc,
        GRD_ID_grade asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- SU_holder_OB_item_GRD_grade_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_holder_OB_item_GRD_grade_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
    SU_holder_OB_item_GRD_grade_ID int not null,
    SU_holder_OB_item_GRD_grade_PositedAt datetime2 not null,
    SU_holder_OB_item_GRD_grade_Reliability bit not null,
    Metadata_SU_holder_OB_item_GRD_grade int not null,
    constraint fkSU_holder_OB_item_GRD_grade_Annex foreign key (
        SU_holder_OB_item_GRD_grade_ID
    ) references [dbo].[SU_holder_OB_item_GRD_grade_Posit](SU_holder_OB_item_GRD_grade_ID),
    constraint pkSU_holder_OB_item_GRD_grade_Annex primary key clustered (
        SU_holder_OB_item_GRD_grade_ID asc,
        SU_holder_OB_item_GRD_grade_PositedAt desc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_keeper_OB_thing_GRD_rank_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] (
    SU_keeper_OB_thing_GRD_rank_ID int IDENTITY(1,1) not null,
    SU_ID_keeper int not null, 
    OB_ID_thing int not null, 
    GRD_ID_rank tinyint not null,
    SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
    constraint SU_keeper_OB_thing_GRD_rank_Posit_fkSU_keeper foreign key (
        SU_ID_keeper
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_keeper_OB_thing_GRD_rank_Posit_fkOB_thing foreign key (
        OB_ID_thing
    ) references [dbo].[OB_Object](OB_ID), 
    constraint SU_keeper_OB_thing_GRD_rank_Posit_fkGRD_rank foreign key (
        GRD_ID_rank
    ) references [dbo].[GRD_Grade](GRD_ID),
    constraint pkSU_keeper_OB_thing_GRD_rank_Posit primary key nonclustered (
        SU_keeper_OB_thing_GRD_rank_ID asc
    ),
    constraint uqSU_keeper_OB_thing_GRD_rank unique clustered (
        SU_ID_keeper asc,
        OB_ID_thing asc,
        SU_keeper_OB_thing_GRD_rank_ChangedAt desc,
        GRD_ID_rank asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_keeper_OB_thing_GRD_rank_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
    SU_keeper_OB_thing_GRD_rank_ID int not null,
    SU_keeper_OB_thing_GRD_rank_PositedAt datetime2 not null,
    SU_keeper_OB_thing_GRD_rank_Reliability bit not null,
    Metadata_SU_keeper_OB_thing_GRD_rank int not null,
    constraint fkSU_keeper_OB_thing_GRD_rank_Annex foreign key (
        SU_keeper_OB_thing_GRD_rank_ID
    ) references [dbo].[SU_keeper_OB_thing_GRD_rank_Posit](SU_keeper_OB_thing_GRD_rank_ID),
    constraint pkSU_keeper_OB_thing_GRD_rank_Annex primary key clustered (
        SU_keeper_OB_thing_GRD_rank_ID asc,
        SU_keeper_OB_thing_GRD_rank_PositedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- OB_part_SU_owner_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_part_SU_owner_Posit', 'U') IS NULL
CREATE TABLE [dbo].[OB_part_SU_owner_Posit] (
    OB_part_SU_owner_ID int IDENTITY(1,1) not null,
    OB_ID_part int not null, 
    SU_ID_owner int not null, 
    constraint OB_part_SU_owner_Posit_fkOB_part foreign key (
        OB_ID_part
    ) references [dbo].[OB_Object](OB_ID), 
    constraint OB_part_SU_owner_Posit_fkSU_owner foreign key (
        SU_ID_owner
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint pkOB_part_SU_owner_Posit primary key nonclustered (
        OB_part_SU_owner_ID asc
    ),
    constraint uqOB_part_SU_owner unique clustered (
        OB_ID_part asc,
        SU_ID_owner asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- OB_part_SU_owner_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_part_SU_owner_Annex', 'U') IS NULL
CREATE TABLE [dbo].[OB_part_SU_owner_Annex] (
    OB_part_SU_owner_ID int not null,
    OB_part_SU_owner_PositedAt datetime2 not null,
    OB_part_SU_owner_Reliability bit not null,
    Metadata_OB_part_SU_owner int not null,
    constraint fkOB_part_SU_owner_Annex foreign key (
        OB_part_SU_owner_ID
    ) references [dbo].[OB_part_SU_owner_Posit](OB_part_SU_owner_ID),
    constraint pkOB_part_SU_owner_Annex primary key clustered (
        OB_part_SU_owner_ID asc,
        OB_part_SU_owner_PositedAt desc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_partner_SU_with_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_partner_SU_with_Posit', 'U') IS NULL
CREATE TABLE [dbo].[SU_partner_SU_with_Posit] (
    SU_partner_SU_with_ID int IDENTITY(1,1) not null,
    SU_ID_partner int not null, 
    SU_ID_with int not null, 
    SU_partner_SU_with_ChangedAt datetime2 not null,
    constraint SU_partner_SU_with_Posit_fkSU_partner foreign key (
        SU_ID_partner
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_partner_SU_with_Posit_fkSU_with foreign key (
        SU_ID_with
    ) references [dbo].[SU_Subject](SU_ID), 
    constraint SU_partner_SU_with_Posit_uqSU_partner unique (
        SU_ID_partner,
        SU_partner_SU_with_ChangedAt
    ),
    constraint SU_partner_SU_with_Posit_uqSU_with unique (
        SU_ID_with,
        SU_partner_SU_with_ChangedAt
    ),
    constraint pkSU_partner_SU_with_Posit primary key nonclustered (
        SU_partner_SU_with_ID asc
    ),
    constraint uqSU_partner_SU_with unique clustered (
        SU_partner_SU_with_ChangedAt desc,
        SU_ID_partner asc,
        SU_ID_with asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- SU_partner_SU_with_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_partner_SU_with_Annex', 'U') IS NULL
CREATE TABLE [dbo].[SU_partner_SU_with_Annex] (
    SU_partner_SU_with_ID int not null,
    SU_partner_SU_with_PositedAt datetime2 not null,
    SU_partner_SU_with_Reliability bit not null,
    Metadata_SU_partner_SU_with int not null,
    constraint fkSU_partner_SU_with_Annex foreign key (
        SU_partner_SU_with_ID
    ) references [dbo].[SU_partner_SU_with_Posit](SU_partner_SU_with_ID),
    constraint pkSU_partner_SU_with_Annex primary key clustered (
        SU_partner_SU_with_ID asc,
        SU_partner_SU_with_PositedAt desc
    )
);
GO
