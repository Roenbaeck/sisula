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
IF Object_ID('ties.AC_partner_AC_with_ONG_currently', 'U') IS NULL
CREATE TABLE [ties].[AC_partner_AC_with_ONG_currently] (
    AC_ID_partner smallint not null, 
    AC_ID_with smallint not null, 
    ONG_ID_currently tinyint not null,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime2 not null,
    Metadata_AC_partner_AC_with_ONG_currently int not null,
    constraint AC_partner_AC_with_ONG_currently_fkAC_partner foreign key (
        AC_ID_partner
    ) references [anchors].[AC_Actor](AC_ID), 
    constraint AC_partner_AC_with_ONG_currently_fkAC_with foreign key (
        AC_ID_with
    ) references [anchors].[AC_Actor](AC_ID), 
    constraint AC_partner_AC_with_ONG_currently_fkONG_currently foreign key (
        ONG_ID_currently
    ) references [knots].[ONG_Ongoing_ID](ONG_ID),
    constraint AC_partner_AC_with_ONG_currently_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint AC_partner_AC_with_ONG_currently_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint pkAC_partner_AC_with_ONG_currently primary key (
        AC_ID_partner asc,
        AC_ID_with asc,
        ONG_ID_currently asc,
        AC_partner_AC_with_ONG_currently_ChangedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.AC_subset_PN_of', 'U') IS NULL
CREATE TABLE [ties].[AC_subset_PN_of] (
    AC_ID_subset smallint not null, 
    PN_ID_of bigint not null, 
    Metadata_AC_subset_PN_of int not null,
    constraint AC_subset_PN_of_fkAC_subset foreign key (
        AC_ID_subset
    ) references [anchors].[AC_Actor](AC_ID), 
    constraint AC_subset_PN_of_fkPN_of foreign key (
        PN_ID_of
    ) references [anchors].[PN_Person](PN_ID), 
    constraint AC_subset_PN_of_uqAC_subset unique (
        AC_ID_subset
    ),
    constraint AC_subset_PN_of_uqPN_of unique (
        PN_ID_of
    ),
    constraint pkAC_subset_PN_of primary key (
        AC_ID_subset asc,
        PN_ID_of asc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.EV_in_AC_wasCast', 'U') IS NULL
CREATE TABLE [ties].[EV_in_AC_wasCast] (
    EV_ID_in numeric(12,0) not null, 
    AC_ID_wasCast smallint not null, 
    Metadata_EV_in_AC_wasCast int not null,
    constraint EV_in_AC_wasCast_fkEV_in foreign key (
        EV_ID_in
    ) references [nexuses].[EV_Event](EV_ID), 
    constraint EV_in_AC_wasCast_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references [anchors].[AC_Actor](AC_ID), 
    constraint pkEV_in_AC_wasCast primary key (
        EV_ID_in asc,
        AC_ID_wasCast asc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.AC_part_PR_in_RAT_got', 'U') IS NULL
CREATE TABLE [ties].[AC_part_PR_in_RAT_got] (
    AC_ID_part smallint not null, 
    PR_ID_in bigint not null, 
    RAT_ID_got tinyint not null,
    AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
    Metadata_AC_part_PR_in_RAT_got int not null,
    constraint AC_part_PR_in_RAT_got_fkAC_part foreign key (
        AC_ID_part
    ) references [anchors].[AC_Actor](AC_ID), 
    constraint AC_part_PR_in_RAT_got_fkPR_in foreign key (
        PR_ID_in
    ) references [anchors].[PR_Program](PR_ID), 
    constraint AC_part_PR_in_RAT_got_fkRAT_got foreign key (
        RAT_ID_got
    ) references [knots].[RAT_Rating_ID](RAT_ID),
    constraint pkAC_part_PR_in_RAT_got primary key (
        AC_ID_part asc,
        PR_ID_in asc,
        AC_part_PR_in_RAT_got_ChangedAt desc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.ST_at_PR_isPlaying', 'U') IS NULL
CREATE TABLE [ties].[ST_at_PR_isPlaying] (
    ST_ID_at int not null, 
    PR_ID_isPlaying bigint not null, 
    ST_at_PR_isPlaying_ChangedAt datetime2 not null,
    Metadata_ST_at_PR_isPlaying int not null,
    constraint ST_at_PR_isPlaying_fkST_at foreign key (
        ST_ID_at
    ) references [anchors].[ST_Stage](ST_ID), 
    constraint ST_at_PR_isPlaying_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references [anchors].[PR_Program](PR_ID), 
    constraint pkST_at_PR_isPlaying primary key (
        ST_ID_at asc,
        PR_ID_isPlaying asc,
        ST_at_PR_isPlaying_ChangedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.AC_parent_AC_child_PAT_having', 'U') IS NULL
CREATE TABLE [ties].[AC_parent_AC_child_PAT_having] (
    AC_ID_parent smallint not null, 
    AC_ID_child smallint not null, 
    PAT_ID_having tinyint not null,
    Metadata_AC_parent_AC_child_PAT_having int not null,
    constraint AC_parent_AC_child_PAT_having_fkAC_parent foreign key (
        AC_ID_parent
    ) references [anchors].[AC_Actor](AC_ID), 
    constraint AC_parent_AC_child_PAT_having_fkAC_child foreign key (
        AC_ID_child
    ) references [anchors].[AC_Actor](AC_ID), 
    constraint AC_parent_AC_child_PAT_having_fkPAT_having foreign key (
        PAT_ID_having
    ) references [knots].[PAT_ParentalType_ID](PAT_ID),
    constraint pkAC_parent_AC_child_PAT_having primary key (
        AC_ID_parent asc,
        AC_ID_child asc,
        PAT_ID_having asc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.PR_content_ST_location_EV_of', 'U') IS NULL
CREATE TABLE [ties].[PR_content_ST_location_EV_of] (
    PR_ID_content bigint not null, 
    ST_ID_location int not null, 
    EV_ID_of numeric(12,0) not null, 
    PR_content_ST_location_EV_of_ChangedAt datetime2 not null,
    Metadata_PR_content_ST_location_EV_of int not null,
    constraint PR_content_ST_location_EV_of_fkPR_content foreign key (
        PR_ID_content
    ) references [anchors].[PR_Program](PR_ID), 
    constraint PR_content_ST_location_EV_of_fkST_location foreign key (
        ST_ID_location
    ) references [anchors].[ST_Stage](ST_ID), 
    constraint PR_content_ST_location_EV_of_fkEV_of foreign key (
        EV_ID_of
    ) references [nexuses].[EV_Event](EV_ID), 
    constraint PR_content_ST_location_EV_of_uqPR_content unique (
        PR_ID_content,
        PR_content_ST_location_EV_of_ChangedAt
    ),
    constraint PR_content_ST_location_EV_of_uqST_location unique (
        ST_ID_location,
        PR_content_ST_location_EV_of_ChangedAt
    ),
    constraint pkPR_content_ST_location_EV_of primary key (
        PR_ID_content asc,
        ST_ID_location asc,
        EV_ID_of asc,
        PR_content_ST_location_EV_of_ChangedAt desc
    )
);
GO
