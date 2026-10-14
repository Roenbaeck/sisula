-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_partner_AC_with_ONG_currently_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_partner_AC_with_ONG_currently_Posit] (
    AC_partner_AC_with_ONG_currently_ID int IDENTITY(1,1) not null,
    AC_ID_partner int not null, 
    AC_ID_with int not null, 
    ONG_ID_currently tinyint not null,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime2 not null,
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_partner foreign key (
        AC_ID_partner
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_with foreign key (
        AC_ID_with
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_partner_AC_with_ONG_currently_Posit_fkONG_currently foreign key (
        ONG_ID_currently
    ) references [dbo].[ONG_Ongoing](ONG_ID),
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint pkAC_partner_AC_with_ONG_currently_Posit primary key nonclustered (
        AC_partner_AC_with_ONG_currently_ID asc
    ),
    constraint uqAC_partner_AC_with_ONG_currently unique clustered (
        AC_partner_AC_with_ONG_currently_ChangedAt desc,
        AC_ID_partner asc,
        AC_ID_with asc,
        ONG_ID_currently asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_partner_AC_with_ONG_currently_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_partner_AC_with_ONG_currently_Annex] (
    AC_partner_AC_with_ONG_currently_ID int not null,
    AC_partner_AC_with_ONG_currently_PositedAt datetime2 not null,
    AC_partner_AC_with_ONG_currently_Reliability bit not null,
    constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
        AC_partner_AC_with_ONG_currently_ID
    ) references [dbo].[AC_partner_AC_with_ONG_currently_Posit](AC_partner_AC_with_ONG_currently_ID),
    constraint pkAC_partner_AC_with_ONG_currently_Annex primary key clustered (
        AC_partner_AC_with_ONG_currently_ID asc,
        AC_partner_AC_with_ONG_currently_PositedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_subset_PN_of_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_subset_PN_of_Posit] (
    AC_subset_PN_of_ID int IDENTITY(1,1) not null,
    AC_ID_subset int not null, 
    PN_ID_of int not null, 
    constraint AC_subset_PN_of_Posit_fkAC_subset foreign key (
        AC_ID_subset
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_subset_PN_of_Posit_fkPN_of foreign key (
        PN_ID_of
    ) references [dbo].[PN_Person](PN_ID), 
    constraint AC_subset_PN_of_Posit_uqAC_subset unique (
        AC_ID_subset
    ),
    constraint AC_subset_PN_of_Posit_uqPN_of unique (
        PN_ID_of
    ),
    constraint pkAC_subset_PN_of_Posit primary key nonclustered (
        AC_subset_PN_of_ID asc
    ),
    constraint uqAC_subset_PN_of unique clustered (
        AC_ID_subset asc,
        PN_ID_of asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_subset_PN_of_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_subset_PN_of_Annex] (
    AC_subset_PN_of_ID int not null,
    AC_subset_PN_of_PositedAt datetime2 not null,
    AC_subset_PN_of_Reliability bit not null,
    constraint fkAC_subset_PN_of_Annex foreign key (
        AC_subset_PN_of_ID
    ) references [dbo].[AC_subset_PN_of_Posit](AC_subset_PN_of_ID),
    constraint pkAC_subset_PN_of_Annex primary key clustered (
        AC_subset_PN_of_ID asc,
        AC_subset_PN_of_PositedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_in_AC_wasCast_Posit', 'U') IS NULL
CREATE TABLE [dbo].[EV_in_AC_wasCast_Posit] (
    EV_in_AC_wasCast_ID int IDENTITY(1,1) not null,
    EV_ID_in int not null, 
    AC_ID_wasCast int not null, 
    constraint EV_in_AC_wasCast_Posit_fkEV_in foreign key (
        EV_ID_in
    ) references [dbo].[EV_Event](EV_ID), 
    constraint EV_in_AC_wasCast_Posit_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint pkEV_in_AC_wasCast_Posit primary key nonclustered (
        EV_in_AC_wasCast_ID asc
    ),
    constraint uqEV_in_AC_wasCast unique clustered (
        EV_ID_in asc,
        AC_ID_wasCast asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_in_AC_wasCast_Annex', 'U') IS NULL
CREATE TABLE [dbo].[EV_in_AC_wasCast_Annex] (
    EV_in_AC_wasCast_ID int not null,
    EV_in_AC_wasCast_PositedAt datetime2 not null,
    EV_in_AC_wasCast_Reliability bit not null,
    constraint fkEV_in_AC_wasCast_Annex foreign key (
        EV_in_AC_wasCast_ID
    ) references [dbo].[EV_in_AC_wasCast_Posit](EV_in_AC_wasCast_ID),
    constraint pkEV_in_AC_wasCast_Annex primary key clustered (
        EV_in_AC_wasCast_ID asc,
        EV_in_AC_wasCast_PositedAt desc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_part_PR_in_RAT_got_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_part_PR_in_RAT_got_Posit] (
    AC_part_PR_in_RAT_got_ID int IDENTITY(1,1) not null,
    AC_ID_part int not null, 
    PR_ID_in int not null, 
    RAT_ID_got tinyint not null,
    AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
    constraint AC_part_PR_in_RAT_got_Posit_fkAC_part foreign key (
        AC_ID_part
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_part_PR_in_RAT_got_Posit_fkPR_in foreign key (
        PR_ID_in
    ) references [dbo].[PR_Program](PR_ID), 
    constraint AC_part_PR_in_RAT_got_Posit_fkRAT_got foreign key (
        RAT_ID_got
    ) references [dbo].[RAT_Rating](RAT_ID),
    constraint pkAC_part_PR_in_RAT_got_Posit primary key nonclustered (
        AC_part_PR_in_RAT_got_ID asc
    ),
    constraint uqAC_part_PR_in_RAT_got unique clustered (
        AC_ID_part asc,
        PR_ID_in asc,
        AC_part_PR_in_RAT_got_ChangedAt desc,
        RAT_ID_got asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_part_PR_in_RAT_got_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_part_PR_in_RAT_got_Annex] (
    AC_part_PR_in_RAT_got_ID int not null,
    AC_part_PR_in_RAT_got_PositedAt datetime2 not null,
    AC_part_PR_in_RAT_got_Reliability bit not null,
    constraint fkAC_part_PR_in_RAT_got_Annex foreign key (
        AC_part_PR_in_RAT_got_ID
    ) references [dbo].[AC_part_PR_in_RAT_got_Posit](AC_part_PR_in_RAT_got_ID),
    constraint pkAC_part_PR_in_RAT_got_Annex primary key clustered (
        AC_part_PR_in_RAT_got_ID asc,
        AC_part_PR_in_RAT_got_PositedAt desc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_at_PR_isPlaying_Posit', 'U') IS NULL
CREATE TABLE [dbo].[ST_at_PR_isPlaying_Posit] (
    ST_at_PR_isPlaying_ID int IDENTITY(1,1) not null,
    ST_ID_at int not null, 
    PR_ID_isPlaying int not null, 
    ST_at_PR_isPlaying_ChangedAt datetime2 not null,
    constraint ST_at_PR_isPlaying_Posit_fkST_at foreign key (
        ST_ID_at
    ) references [dbo].[ST_Stage](ST_ID), 
    constraint ST_at_PR_isPlaying_Posit_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references [dbo].[PR_Program](PR_ID), 
    constraint pkST_at_PR_isPlaying_Posit primary key nonclustered (
        ST_at_PR_isPlaying_ID asc
    ),
    constraint uqST_at_PR_isPlaying unique clustered (
        ST_ID_at asc,
        PR_ID_isPlaying asc,
        ST_at_PR_isPlaying_ChangedAt desc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_at_PR_isPlaying_Annex', 'U') IS NULL
CREATE TABLE [dbo].[ST_at_PR_isPlaying_Annex] (
    ST_at_PR_isPlaying_ID int not null,
    ST_at_PR_isPlaying_PositedAt datetime2 not null,
    ST_at_PR_isPlaying_Reliability bit not null,
    constraint fkST_at_PR_isPlaying_Annex foreign key (
        ST_at_PR_isPlaying_ID
    ) references [dbo].[ST_at_PR_isPlaying_Posit](ST_at_PR_isPlaying_ID),
    constraint pkST_at_PR_isPlaying_Annex primary key clustered (
        ST_at_PR_isPlaying_ID asc,
        ST_at_PR_isPlaying_PositedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_parent_AC_child_PAT_having_Posit', 'U') IS NULL
CREATE TABLE [dbo].[AC_parent_AC_child_PAT_having_Posit] (
    AC_parent_AC_child_PAT_having_ID int IDENTITY(1,1) not null,
    AC_ID_parent int not null, 
    AC_ID_child int not null, 
    PAT_ID_having tinyint not null,
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_parent foreign key (
        AC_ID_parent
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_child foreign key (
        AC_ID_child
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_parent_AC_child_PAT_having_Posit_fkPAT_having foreign key (
        PAT_ID_having
    ) references [dbo].[PAT_ParentalType](PAT_ID),
    constraint pkAC_parent_AC_child_PAT_having_Posit primary key nonclustered (
        AC_parent_AC_child_PAT_having_ID asc
    ),
    constraint uqAC_parent_AC_child_PAT_having unique clustered (
        AC_ID_parent asc,
        AC_ID_child asc,
        PAT_ID_having asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_parent_AC_child_PAT_having_Annex', 'U') IS NULL
CREATE TABLE [dbo].[AC_parent_AC_child_PAT_having_Annex] (
    AC_parent_AC_child_PAT_having_ID int not null,
    AC_parent_AC_child_PAT_having_PositedAt datetime2 not null,
    AC_parent_AC_child_PAT_having_Reliability bit not null,
    constraint fkAC_parent_AC_child_PAT_having_Annex foreign key (
        AC_parent_AC_child_PAT_having_ID
    ) references [dbo].[AC_parent_AC_child_PAT_having_Posit](AC_parent_AC_child_PAT_having_ID),
    constraint pkAC_parent_AC_child_PAT_having_Annex primary key clustered (
        AC_parent_AC_child_PAT_having_ID asc,
        AC_parent_AC_child_PAT_having_PositedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_content_ST_location_EV_of_Posit', 'U') IS NULL
CREATE TABLE [dbo].[PR_content_ST_location_EV_of_Posit] (
    PR_content_ST_location_EV_of_ID int IDENTITY(1,1) not null,
    PR_ID_content int not null, 
    ST_ID_location int not null, 
    EV_ID_of int not null, 
    constraint PR_content_ST_location_EV_of_Posit_fkPR_content foreign key (
        PR_ID_content
    ) references [dbo].[PR_Program](PR_ID), 
    constraint PR_content_ST_location_EV_of_Posit_fkST_location foreign key (
        ST_ID_location
    ) references [dbo].[ST_Stage](ST_ID), 
    constraint PR_content_ST_location_EV_of_Posit_fkEV_of foreign key (
        EV_ID_of
    ) references [dbo].[EV_Event](EV_ID), 
    constraint pkPR_content_ST_location_EV_of_Posit primary key nonclustered (
        PR_content_ST_location_EV_of_ID asc
    ),
    constraint uqPR_content_ST_location_EV_of unique clustered (
        EV_ID_of asc,
        PR_ID_content asc,
        ST_ID_location asc
    )
);
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of_Annex table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_content_ST_location_EV_of_Annex', 'U') IS NULL
CREATE TABLE [dbo].[PR_content_ST_location_EV_of_Annex] (
    PR_content_ST_location_EV_of_ID int not null,
    PR_content_ST_location_EV_of_PositedAt datetime2 not null,
    PR_content_ST_location_EV_of_Reliability bit not null,
    constraint fkPR_content_ST_location_EV_of_Annex foreign key (
        PR_content_ST_location_EV_of_ID
    ) references [dbo].[PR_content_ST_location_EV_of_Posit](PR_content_ST_location_EV_of_ID),
    constraint pkPR_content_ST_location_EV_of_Annex primary key clustered (
        PR_content_ST_location_EV_of_ID asc,
        PR_content_ST_location_EV_of_PositedAt desc
    )
);
GO
