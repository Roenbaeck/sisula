-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- TYP_Type table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.TYP_Type', 'U') IS NULL
CREATE TABLE [stats].[TYP_Type] (
    TYP_ID char(1) not null,
    TYP_Type varchar(42) not null,
    Metadata_TYP int not null,
    constraint pkTYP_Type primary key (
        TYP_ID asc
    ),
    constraint uqTYP_Type unique (
        TYP_Type
    )
);
GO
-- ANCHORS AND ATTRIBUTES ---------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
-- Attributes are used to store values for properties of entities.
-- Attributes are mutable, their values may change over one or more types of time.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
-- Anchors may have zero or more adjoined attributes.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- GC_GatheredConstruct table (with 16 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_GatheredConstruct', 'U') IS NULL
CREATE TABLE [stats].[GC_GatheredConstruct] (
    GC_ID int IDENTITY(1,1) not null,
    Metadata_GC int not null, 
    constraint pkGC_GatheredConstruct primary key (
        GC_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- GC_NAM_GatheredConstruct_Name table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_NAM_GatheredConstruct_Name', 'U') IS NULL
CREATE TABLE [stats].[GC_NAM_GatheredConstruct_Name] (
    GC_NAM_GC_ID int not null,
    GC_NAM_GatheredConstruct_Name nvarchar(128) not null,
    Metadata_GC_NAM int not null,
    constraint fkGC_NAM_GatheredConstruct_Name foreign key (
        GC_NAM_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_NAM_GatheredConstruct_Name primary key (
        GC_NAM_GC_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- GC_CAP_GatheredConstruct_Capsule table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_CAP_GatheredConstruct_Capsule', 'U') IS NULL
CREATE TABLE [stats].[GC_CAP_GatheredConstruct_Capsule] (
    GC_CAP_GC_ID int not null,
    GC_CAP_GatheredConstruct_Capsule nvarchar(128) not null,
    Metadata_GC_CAP int not null,
    constraint fkGC_CAP_GatheredConstruct_Capsule foreign key (
        GC_CAP_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_CAP_GatheredConstruct_Capsule primary key (
        GC_CAP_GC_ID asc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- GC_TYP_GatheredConstruct_Type table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_TYP_GatheredConstruct_Type', 'U') IS NULL
CREATE TABLE [stats].[GC_TYP_GatheredConstruct_Type] (
    GC_TYP_GC_ID int not null,
    GC_TYP_TYP_ID char(1) not null,
    Metadata_GC_TYP int not null,
    constraint fk_A_GC_TYP_GatheredConstruct_Type foreign key (
        GC_TYP_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint fk_K_GC_TYP_GatheredConstruct_Type foreign key (
        GC_TYP_TYP_ID
    ) references [stats].[TYP_Type](TYP_ID),
    constraint pkGC_TYP_GatheredConstruct_Type primary key (
        GC_TYP_GC_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_ROC_GatheredConstruct_RowCount table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_ROC_GatheredConstruct_RowCount', 'U') IS NULL
CREATE TABLE [stats].[GC_ROC_GatheredConstruct_RowCount] (
    GC_ROC_GC_ID int not null,
    GC_ROC_GatheredConstruct_RowCount bigint not null,
    GC_ROC_ChangedAt datetime not null,
    Metadata_GC_ROC int not null,
    constraint fkGC_ROC_GatheredConstruct_RowCount foreign key (
        GC_ROC_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_ROC_GatheredConstruct_RowCount primary key (
        GC_ROC_GC_ID asc,
        GC_ROC_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_RGR_GatheredConstruct_RowGrowth table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_RGR_GatheredConstruct_RowGrowth', 'U') IS NULL
CREATE TABLE [stats].[GC_RGR_GatheredConstruct_RowGrowth] (
    GC_RGR_GC_ID int not null,
    GC_RGR_GatheredConstruct_RowGrowth int not null,
    GC_RGR_ChangedAt datetime not null,
    Metadata_GC_RGR int not null,
    constraint fkGC_RGR_GatheredConstruct_RowGrowth foreign key (
        GC_RGR_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_RGR_GatheredConstruct_RowGrowth primary key (
        GC_RGR_GC_ID asc,
        GC_RGR_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_RGN_GatheredConstruct_RowGrowthNormal table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_RGN_GatheredConstruct_RowGrowthNormal', 'U') IS NULL
CREATE TABLE [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] (
    GC_RGN_GC_ID int not null,
    GC_RGN_GatheredConstruct_RowGrowthNormal int not null,
    GC_RGN_ChangedAt datetime not null,
    Metadata_GC_RGN int not null,
    constraint fkGC_RGN_GatheredConstruct_RowGrowthNormal foreign key (
        GC_RGN_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_RGN_GatheredConstruct_RowGrowthNormal primary key (
        GC_RGN_GC_ID asc,
        GC_RGN_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_UMB_GatheredConstruct_UsedMegabytes table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_UMB_GatheredConstruct_UsedMegabytes', 'U') IS NULL
CREATE TABLE [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] (
    GC_UMB_GC_ID int not null,
    GC_UMB_GatheredConstruct_UsedMegabytes decimal(19,2) not null,
    GC_UMB_ChangedAt datetime not null,
    Metadata_GC_UMB int not null,
    constraint fkGC_UMB_GatheredConstruct_UsedMegabytes foreign key (
        GC_UMB_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_UMB_GatheredConstruct_UsedMegabytes primary key (
        GC_UMB_GC_ID asc,
        GC_UMB_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_UGR_GatheredConstruct_UsedGrowth table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_UGR_GatheredConstruct_UsedGrowth', 'U') IS NULL
CREATE TABLE [stats].[GC_UGR_GatheredConstruct_UsedGrowth] (
    GC_UGR_GC_ID int not null,
    GC_UGR_GatheredConstruct_UsedGrowth decimal(19,2) not null,
    GC_UGR_ChangedAt datetime not null,
    Metadata_GC_UGR int not null,
    constraint fkGC_UGR_GatheredConstruct_UsedGrowth foreign key (
        GC_UGR_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_UGR_GatheredConstruct_UsedGrowth primary key (
        GC_UGR_GC_ID asc,
        GC_UGR_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_UGN_GatheredConstruct_UsedGrowthNormal table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_UGN_GatheredConstruct_UsedGrowthNormal', 'U') IS NULL
CREATE TABLE [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] (
    GC_UGN_GC_ID int not null,
    GC_UGN_GatheredConstruct_UsedGrowthNormal decimal(19,2) not null,
    GC_UGN_ChangedAt datetime not null,
    Metadata_GC_UGN int not null,
    constraint fkGC_UGN_GatheredConstruct_UsedGrowthNormal foreign key (
        GC_UGN_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_UGN_GatheredConstruct_UsedGrowthNormal primary key (
        GC_UGN_GC_ID asc,
        GC_UGN_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_AMB_GatheredConstruct_AllocatedMegabytes table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_AMB_GatheredConstruct_AllocatedMegabytes', 'U') IS NULL
CREATE TABLE [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] (
    GC_AMB_GC_ID int not null,
    GC_AMB_GatheredConstruct_AllocatedMegabytes decimal(19,2) not null,
    GC_AMB_ChangedAt datetime not null,
    Metadata_GC_AMB int not null,
    constraint fkGC_AMB_GatheredConstruct_AllocatedMegabytes foreign key (
        GC_AMB_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_AMB_GatheredConstruct_AllocatedMegabytes primary key (
        GC_AMB_GC_ID asc,
        GC_AMB_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_AGR_GatheredConstruct_AllocatedGrowth table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_AGR_GatheredConstruct_AllocatedGrowth', 'U') IS NULL
CREATE TABLE [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] (
    GC_AGR_GC_ID int not null,
    GC_AGR_GatheredConstruct_AllocatedGrowth decimal(19,2) not null,
    GC_AGR_ChangedAt datetime not null,
    Metadata_GC_AGR int not null,
    constraint fkGC_AGR_GatheredConstruct_AllocatedGrowth foreign key (
        GC_AGR_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_AGR_GatheredConstruct_AllocatedGrowth primary key (
        GC_AGR_GC_ID asc,
        GC_AGR_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_AGN_GatheredConstruct_AllocatedGrowthNormal table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_AGN_GatheredConstruct_AllocatedGrowthNormal', 'U') IS NULL
CREATE TABLE [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] (
    GC_AGN_GC_ID int not null,
    GC_AGN_GatheredConstruct_AllocatedGrowthNormal decimal(19,2) not null,
    GC_AGN_ChangedAt datetime not null,
    Metadata_GC_AGN int not null,
    constraint fkGC_AGN_GatheredConstruct_AllocatedGrowthNormal foreign key (
        GC_AGN_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_AGN_GatheredConstruct_AllocatedGrowthNormal primary key (
        GC_AGN_GC_ID asc,
        GC_AGN_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_AGI_GatheredConstruct_AllocatedGrowthInterval table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_AGI_GatheredConstruct_AllocatedGrowthInterval', 'U') IS NULL
CREATE TABLE [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] (
    GC_AGI_GC_ID int not null,
    GC_AGI_GatheredConstruct_AllocatedGrowthInterval bigint not null,
    GC_AGI_ChangedAt datetime not null,
    Metadata_GC_AGI int not null,
    constraint fkGC_AGI_GatheredConstruct_AllocatedGrowthInterval foreign key (
        GC_AGI_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_AGI_GatheredConstruct_AllocatedGrowthInterval primary key (
        GC_AGI_GC_ID asc,
        GC_AGI_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_UGI_GatheredConstruct_UsedGrowthInterval table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_UGI_GatheredConstruct_UsedGrowthInterval', 'U') IS NULL
CREATE TABLE [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] (
    GC_UGI_GC_ID int not null,
    GC_UGI_GatheredConstruct_UsedGrowthInterval bigint not null,
    GC_UGI_ChangedAt datetime not null,
    Metadata_GC_UGI int not null,
    constraint fkGC_UGI_GatheredConstruct_UsedGrowthInterval foreign key (
        GC_UGI_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_UGI_GatheredConstruct_UsedGrowthInterval primary key (
        GC_UGI_GC_ID asc,
        GC_UGI_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_RGI_GatheredConstruct_RowGrowthInterval table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_RGI_GatheredConstruct_RowGrowthInterval', 'U') IS NULL
CREATE TABLE [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] (
    GC_RGI_GC_ID int not null,
    GC_RGI_GatheredConstruct_RowGrowthInterval bigint not null,
    GC_RGI_ChangedAt datetime not null,
    Metadata_GC_RGI int not null,
    constraint fkGC_RGI_GatheredConstruct_RowGrowthInterval foreign key (
        GC_RGI_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_RGI_GatheredConstruct_RowGrowthInterval primary key (
        GC_RGI_GC_ID asc,
        GC_RGI_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- GC_LGT_GatheredConstruct_LatestGatheringTime table (on GC_GatheredConstruct)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.GC_LGT_GatheredConstruct_LatestGatheringTime', 'U') IS NULL
CREATE TABLE [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] (
    GC_LGT_GC_ID int not null,
    GC_LGT_GatheredConstruct_LatestGatheringTime datetime not null,
    GC_LGT_ChangedAt datetime not null,
    Metadata_GC_LGT int not null,
    constraint fkGC_LGT_GatheredConstruct_LatestGatheringTime foreign key (
        GC_LGT_GC_ID
    ) references [stats].[GC_GatheredConstruct](GC_ID),
    constraint pkGC_LGT_GatheredConstruct_LatestGatheringTime primary key (
        GC_LGT_GC_ID asc,
        GC_LGT_ChangedAt desc
    )
);
GO
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- ConstructName key view for lookups of identities in GC_GatheredConstruct
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.key_GC_ConstructName', 'V') IS NOT NULL
DROP VIEW [stats].[key_GC_ConstructName];
GO
CREATE VIEW [stats].[key_GC_ConstructName] WITH SCHEMABINDING AS
SELECT
    twine.GC_CAP_GatheredConstruct_Capsule,
    twine.GC_NAM_GatheredConstruct_Name,
    [GC].GC_ID
FROM
    [stats].[GC_GatheredConstruct] [GC]
LEFT JOIN (
    SELECT TOP 1 WITH TIES
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'GC_CAP_GatheredConstruct_Capsule'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    GC_ID, 
                    GC_CAP_GatheredConstruct_Capsule_ChangedAt
            ) AS nvarchar(128)
        ) AS GC_CAP_GatheredConstruct_Capsule,
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'GC_NAM_GatheredConstruct_Name'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    GC_ID, 
                    GC_NAM_GatheredConstruct_Name_ChangedAt
            ) AS nvarchar(128)
        ) AS GC_NAM_GatheredConstruct_Name,
        GC_ID,
        [ChangedAt]
    FROM (
        SELECT
            MAX(CASE
                WHEN [QualifiedType] = 'GC_CAP_GatheredConstruct_Capsule' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY GC_ID 
                ORDER BY [ChangedAt]
            ) AS GC_CAP_GatheredConstruct_Capsule_ChangedAt,
            MAX(CASE
                WHEN [QualifiedType] = 'GC_NAM_GatheredConstruct_Name' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY GC_ID 
                ORDER BY [ChangedAt]
            ) AS GC_NAM_GatheredConstruct_Name_ChangedAt,
            GC_ID,
            [Value],
            [QualifiedType],
            [ChangedAt]
        FROM (
            SELECT
                GC_CAP_GC_ID AS GC_ID, 
                CAST(GC_CAP_GatheredConstruct_Capsule AS VARBINARY(max)) AS [Value],
                'GC_CAP_GatheredConstruct_Capsule' AS [QualifiedType],
                CAST(NULL AS datetime2(7)) AS [ChangedAt]
            FROM
                [stats].[GC_CAP_GatheredConstruct_Capsule] 
            UNION ALL
            SELECT
                GC_NAM_GC_ID AS GC_ID, 
                CAST(GC_NAM_GatheredConstruct_Name AS VARBINARY(max)) AS [Value],
                'GC_NAM_GatheredConstruct_Name' AS [QualifiedType],
                CAST(NULL AS datetime2(7)) AS [ChangedAt]
            FROM
                [stats].[GC_NAM_GatheredConstruct_Name] 
        ) unified_timelines
    ) resolved_changes
    ORDER BY 
        ROW_NUMBER() OVER (
            PARTITION BY 
                GC_ID, 
                [ChangedAt] 
            ORDER BY
                (select 1)
        )
) twine
ON
    twine.GC_ID = [GC].GC_ID;
GO
-- KNOT EQUIVALENCE VIEWS ---------------------------------------------------------------------------------------------
--
-- Equivalence views combine the identity and equivalent parts of a knot into a single view, making
-- it look and behave like a regular knot. They also make it possible to retrieve data for only the
-- given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- ATTRIBUTE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------
--
-- Attributes may be prevented from storing restatements.
-- A restatement is when the same value occurs for two adjacent points
-- in changing time.
--
-- returns 1 for at least one equal surrounding value, 0 for different surrounding values
--
-- @id the identity of the anchored entity
-- @eq the equivalent (when applicable)
-- @value the value of the attribute
-- @changed the point in time from which this value shall represent a change
--
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_ROC_GatheredConstruct_RowCount restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_ROC_GatheredConstruct_RowCount restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_ROC_GatheredConstruct_RowCount', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_ROC_GatheredConstruct_RowCount] (
        @id int,
        @value bigint,
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_ROC_GatheredConstruct_RowCount
                    FROM
                        [stats].[GC_ROC_GatheredConstruct_RowCount] pre
                    WHERE
                        pre.GC_ROC_GC_ID = @id
                    AND
                        pre.GC_ROC_ChangedAt < @changed
                    ORDER BY
                        pre.GC_ROC_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_ROC_GatheredConstruct_RowCount
                    FROM
                        [stats].[GC_ROC_GatheredConstruct_RowCount] fol
                    WHERE
                        fol.GC_ROC_GC_ID = @id
                    AND
                        fol.GC_ROC_ChangedAt > @changed
                    ORDER BY
                        fol.GC_ROC_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_ROC_GatheredConstruct_RowCount]
    ADD CONSTRAINT [rcGC_ROC_GatheredConstruct_RowCount] CHECK (
        [stats].[rfGC_ROC_GatheredConstruct_RowCount] (
            GC_ROC_GC_ID,
            GC_ROC_GatheredConstruct_RowCount,
            GC_ROC_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_RGR_GatheredConstruct_RowGrowth restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_RGR_GatheredConstruct_RowGrowth restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_RGR_GatheredConstruct_RowGrowth', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_RGR_GatheredConstruct_RowGrowth] (
        @id int,
        @value int,
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_RGR_GatheredConstruct_RowGrowth
                    FROM
                        [stats].[GC_RGR_GatheredConstruct_RowGrowth] pre
                    WHERE
                        pre.GC_RGR_GC_ID = @id
                    AND
                        pre.GC_RGR_ChangedAt < @changed
                    ORDER BY
                        pre.GC_RGR_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_RGR_GatheredConstruct_RowGrowth
                    FROM
                        [stats].[GC_RGR_GatheredConstruct_RowGrowth] fol
                    WHERE
                        fol.GC_RGR_GC_ID = @id
                    AND
                        fol.GC_RGR_ChangedAt > @changed
                    ORDER BY
                        fol.GC_RGR_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_RGR_GatheredConstruct_RowGrowth]
    ADD CONSTRAINT [rcGC_RGR_GatheredConstruct_RowGrowth] CHECK (
        [stats].[rfGC_RGR_GatheredConstruct_RowGrowth] (
            GC_RGR_GC_ID,
            GC_RGR_GatheredConstruct_RowGrowth,
            GC_RGR_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_RGN_GatheredConstruct_RowGrowthNormal restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_RGN_GatheredConstruct_RowGrowthNormal restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_RGN_GatheredConstruct_RowGrowthNormal', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_RGN_GatheredConstruct_RowGrowthNormal] (
        @id int,
        @value int,
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_RGN_GatheredConstruct_RowGrowthNormal
                    FROM
                        [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] pre
                    WHERE
                        pre.GC_RGN_GC_ID = @id
                    AND
                        pre.GC_RGN_ChangedAt < @changed
                    ORDER BY
                        pre.GC_RGN_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_RGN_GatheredConstruct_RowGrowthNormal
                    FROM
                        [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] fol
                    WHERE
                        fol.GC_RGN_GC_ID = @id
                    AND
                        fol.GC_RGN_ChangedAt > @changed
                    ORDER BY
                        fol.GC_RGN_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal]
    ADD CONSTRAINT [rcGC_RGN_GatheredConstruct_RowGrowthNormal] CHECK (
        [stats].[rfGC_RGN_GatheredConstruct_RowGrowthNormal] (
            GC_RGN_GC_ID,
            GC_RGN_GatheredConstruct_RowGrowthNormal,
            GC_RGN_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_UMB_GatheredConstruct_UsedMegabytes restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_UMB_GatheredConstruct_UsedMegabytes restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_UMB_GatheredConstruct_UsedMegabytes', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_UMB_GatheredConstruct_UsedMegabytes] (
        @id int,
        @value decimal(19,2),
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_UMB_GatheredConstruct_UsedMegabytes
                    FROM
                        [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] pre
                    WHERE
                        pre.GC_UMB_GC_ID = @id
                    AND
                        pre.GC_UMB_ChangedAt < @changed
                    ORDER BY
                        pre.GC_UMB_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_UMB_GatheredConstruct_UsedMegabytes
                    FROM
                        [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] fol
                    WHERE
                        fol.GC_UMB_GC_ID = @id
                    AND
                        fol.GC_UMB_ChangedAt > @changed
                    ORDER BY
                        fol.GC_UMB_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_UMB_GatheredConstruct_UsedMegabytes]
    ADD CONSTRAINT [rcGC_UMB_GatheredConstruct_UsedMegabytes] CHECK (
        [stats].[rfGC_UMB_GatheredConstruct_UsedMegabytes] (
            GC_UMB_GC_ID,
            GC_UMB_GatheredConstruct_UsedMegabytes,
            GC_UMB_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_UGR_GatheredConstruct_UsedGrowth restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_UGR_GatheredConstruct_UsedGrowth restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_UGR_GatheredConstruct_UsedGrowth', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_UGR_GatheredConstruct_UsedGrowth] (
        @id int,
        @value decimal(19,2),
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_UGR_GatheredConstruct_UsedGrowth
                    FROM
                        [stats].[GC_UGR_GatheredConstruct_UsedGrowth] pre
                    WHERE
                        pre.GC_UGR_GC_ID = @id
                    AND
                        pre.GC_UGR_ChangedAt < @changed
                    ORDER BY
                        pre.GC_UGR_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_UGR_GatheredConstruct_UsedGrowth
                    FROM
                        [stats].[GC_UGR_GatheredConstruct_UsedGrowth] fol
                    WHERE
                        fol.GC_UGR_GC_ID = @id
                    AND
                        fol.GC_UGR_ChangedAt > @changed
                    ORDER BY
                        fol.GC_UGR_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_UGR_GatheredConstruct_UsedGrowth]
    ADD CONSTRAINT [rcGC_UGR_GatheredConstruct_UsedGrowth] CHECK (
        [stats].[rfGC_UGR_GatheredConstruct_UsedGrowth] (
            GC_UGR_GC_ID,
            GC_UGR_GatheredConstruct_UsedGrowth,
            GC_UGR_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_UGN_GatheredConstruct_UsedGrowthNormal restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_UGN_GatheredConstruct_UsedGrowthNormal restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_UGN_GatheredConstruct_UsedGrowthNormal', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_UGN_GatheredConstruct_UsedGrowthNormal] (
        @id int,
        @value decimal(19,2),
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_UGN_GatheredConstruct_UsedGrowthNormal
                    FROM
                        [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] pre
                    WHERE
                        pre.GC_UGN_GC_ID = @id
                    AND
                        pre.GC_UGN_ChangedAt < @changed
                    ORDER BY
                        pre.GC_UGN_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_UGN_GatheredConstruct_UsedGrowthNormal
                    FROM
                        [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] fol
                    WHERE
                        fol.GC_UGN_GC_ID = @id
                    AND
                        fol.GC_UGN_ChangedAt > @changed
                    ORDER BY
                        fol.GC_UGN_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal]
    ADD CONSTRAINT [rcGC_UGN_GatheredConstruct_UsedGrowthNormal] CHECK (
        [stats].[rfGC_UGN_GatheredConstruct_UsedGrowthNormal] (
            GC_UGN_GC_ID,
            GC_UGN_GatheredConstruct_UsedGrowthNormal,
            GC_UGN_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_AMB_GatheredConstruct_AllocatedMegabytes restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_AMB_GatheredConstruct_AllocatedMegabytes restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_AMB_GatheredConstruct_AllocatedMegabytes', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_AMB_GatheredConstruct_AllocatedMegabytes] (
        @id int,
        @value decimal(19,2),
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_AMB_GatheredConstruct_AllocatedMegabytes
                    FROM
                        [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] pre
                    WHERE
                        pre.GC_AMB_GC_ID = @id
                    AND
                        pre.GC_AMB_ChangedAt < @changed
                    ORDER BY
                        pre.GC_AMB_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_AMB_GatheredConstruct_AllocatedMegabytes
                    FROM
                        [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] fol
                    WHERE
                        fol.GC_AMB_GC_ID = @id
                    AND
                        fol.GC_AMB_ChangedAt > @changed
                    ORDER BY
                        fol.GC_AMB_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes]
    ADD CONSTRAINT [rcGC_AMB_GatheredConstruct_AllocatedMegabytes] CHECK (
        [stats].[rfGC_AMB_GatheredConstruct_AllocatedMegabytes] (
            GC_AMB_GC_ID,
            GC_AMB_GatheredConstruct_AllocatedMegabytes,
            GC_AMB_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_AGR_GatheredConstruct_AllocatedGrowth restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_AGR_GatheredConstruct_AllocatedGrowth restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_AGR_GatheredConstruct_AllocatedGrowth', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_AGR_GatheredConstruct_AllocatedGrowth] (
        @id int,
        @value decimal(19,2),
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_AGR_GatheredConstruct_AllocatedGrowth
                    FROM
                        [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] pre
                    WHERE
                        pre.GC_AGR_GC_ID = @id
                    AND
                        pre.GC_AGR_ChangedAt < @changed
                    ORDER BY
                        pre.GC_AGR_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_AGR_GatheredConstruct_AllocatedGrowth
                    FROM
                        [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] fol
                    WHERE
                        fol.GC_AGR_GC_ID = @id
                    AND
                        fol.GC_AGR_ChangedAt > @changed
                    ORDER BY
                        fol.GC_AGR_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth]
    ADD CONSTRAINT [rcGC_AGR_GatheredConstruct_AllocatedGrowth] CHECK (
        [stats].[rfGC_AGR_GatheredConstruct_AllocatedGrowth] (
            GC_AGR_GC_ID,
            GC_AGR_GatheredConstruct_AllocatedGrowth,
            GC_AGR_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_AGN_GatheredConstruct_AllocatedGrowthNormal restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_AGN_GatheredConstruct_AllocatedGrowthNormal restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_AGN_GatheredConstruct_AllocatedGrowthNormal', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_AGN_GatheredConstruct_AllocatedGrowthNormal] (
        @id int,
        @value decimal(19,2),
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_AGN_GatheredConstruct_AllocatedGrowthNormal
                    FROM
                        [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] pre
                    WHERE
                        pre.GC_AGN_GC_ID = @id
                    AND
                        pre.GC_AGN_ChangedAt < @changed
                    ORDER BY
                        pre.GC_AGN_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_AGN_GatheredConstruct_AllocatedGrowthNormal
                    FROM
                        [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] fol
                    WHERE
                        fol.GC_AGN_GC_ID = @id
                    AND
                        fol.GC_AGN_ChangedAt > @changed
                    ORDER BY
                        fol.GC_AGN_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal]
    ADD CONSTRAINT [rcGC_AGN_GatheredConstruct_AllocatedGrowthNormal] CHECK (
        [stats].[rfGC_AGN_GatheredConstruct_AllocatedGrowthNormal] (
            GC_AGN_GC_ID,
            GC_AGN_GatheredConstruct_AllocatedGrowthNormal,
            GC_AGN_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_AGI_GatheredConstruct_AllocatedGrowthInterval restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_AGI_GatheredConstruct_AllocatedGrowthInterval restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_AGI_GatheredConstruct_AllocatedGrowthInterval', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_AGI_GatheredConstruct_AllocatedGrowthInterval] (
        @id int,
        @value bigint,
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_AGI_GatheredConstruct_AllocatedGrowthInterval
                    FROM
                        [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] pre
                    WHERE
                        pre.GC_AGI_GC_ID = @id
                    AND
                        pre.GC_AGI_ChangedAt < @changed
                    ORDER BY
                        pre.GC_AGI_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_AGI_GatheredConstruct_AllocatedGrowthInterval
                    FROM
                        [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] fol
                    WHERE
                        fol.GC_AGI_GC_ID = @id
                    AND
                        fol.GC_AGI_ChangedAt > @changed
                    ORDER BY
                        fol.GC_AGI_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval]
    ADD CONSTRAINT [rcGC_AGI_GatheredConstruct_AllocatedGrowthInterval] CHECK (
        [stats].[rfGC_AGI_GatheredConstruct_AllocatedGrowthInterval] (
            GC_AGI_GC_ID,
            GC_AGI_GatheredConstruct_AllocatedGrowthInterval,
            GC_AGI_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_UGI_GatheredConstruct_UsedGrowthInterval restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_UGI_GatheredConstruct_UsedGrowthInterval restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_UGI_GatheredConstruct_UsedGrowthInterval', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_UGI_GatheredConstruct_UsedGrowthInterval] (
        @id int,
        @value bigint,
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_UGI_GatheredConstruct_UsedGrowthInterval
                    FROM
                        [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] pre
                    WHERE
                        pre.GC_UGI_GC_ID = @id
                    AND
                        pre.GC_UGI_ChangedAt < @changed
                    ORDER BY
                        pre.GC_UGI_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_UGI_GatheredConstruct_UsedGrowthInterval
                    FROM
                        [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] fol
                    WHERE
                        fol.GC_UGI_GC_ID = @id
                    AND
                        fol.GC_UGI_ChangedAt > @changed
                    ORDER BY
                        fol.GC_UGI_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval]
    ADD CONSTRAINT [rcGC_UGI_GatheredConstruct_UsedGrowthInterval] CHECK (
        [stats].[rfGC_UGI_GatheredConstruct_UsedGrowthInterval] (
            GC_UGI_GC_ID,
            GC_UGI_GatheredConstruct_UsedGrowthInterval,
            GC_UGI_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_RGI_GatheredConstruct_RowGrowthInterval restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_RGI_GatheredConstruct_RowGrowthInterval restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_RGI_GatheredConstruct_RowGrowthInterval', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_RGI_GatheredConstruct_RowGrowthInterval] (
        @id int,
        @value bigint,
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_RGI_GatheredConstruct_RowGrowthInterval
                    FROM
                        [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] pre
                    WHERE
                        pre.GC_RGI_GC_ID = @id
                    AND
                        pre.GC_RGI_ChangedAt < @changed
                    ORDER BY
                        pre.GC_RGI_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_RGI_GatheredConstruct_RowGrowthInterval
                    FROM
                        [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] fol
                    WHERE
                        fol.GC_RGI_GC_ID = @id
                    AND
                        fol.GC_RGI_ChangedAt > @changed
                    ORDER BY
                        fol.GC_RGI_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval]
    ADD CONSTRAINT [rcGC_RGI_GatheredConstruct_RowGrowthInterval] CHECK (
        [stats].[rfGC_RGI_GatheredConstruct_RowGrowthInterval] (
            GC_RGI_GC_ID,
            GC_RGI_GatheredConstruct_RowGrowthInterval,
            GC_RGI_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfGC_LGT_GatheredConstruct_LatestGatheringTime restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcGC_LGT_GatheredConstruct_LatestGatheringTime restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rfGC_LGT_GatheredConstruct_LatestGatheringTime', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rfGC_LGT_GatheredConstruct_LatestGatheringTime] (
        @id int,
        @value datetime,
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.GC_LGT_GatheredConstruct_LatestGatheringTime
                    FROM
                        [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] pre
                    WHERE
                        pre.GC_LGT_GC_ID = @id
                    AND
                        pre.GC_LGT_ChangedAt < @changed
                    ORDER BY
                        pre.GC_LGT_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.GC_LGT_GatheredConstruct_LatestGatheringTime
                    FROM
                        [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] fol
                    WHERE
                        fol.GC_LGT_GC_ID = @id
                    AND
                        fol.GC_LGT_ChangedAt > @changed
                    ORDER BY
                        fol.GC_LGT_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime]
    ADD CONSTRAINT [rcGC_LGT_GatheredConstruct_LatestGatheringTime] CHECK (
        [stats].[rfGC_LGT_GatheredConstruct_LatestGatheringTime] (
            GC_LGT_GC_ID,
            GC_LGT_GatheredConstruct_LatestGatheringTime,
            GC_LGT_ChangedAt
        ) = 0
    );
END
GO
-- KEY GENERATORS -----------------------------------------------------------------------------------------------------
--
-- These stored procedures can be used to generate identities of entities.
-- Corresponding anchors must have an incrementing identity column.
--
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kGC_GatheredConstruct identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.kGC_GatheredConstruct', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [stats].[kGC_GatheredConstruct] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [stats].[GC_GatheredConstruct] (
                Metadata_GC
            )
            OUTPUT
                inserted.GC_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_ROC_GatheredConstruct_RowCount rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_ROC_GatheredConstruct_RowCount','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_ROC_GatheredConstruct_RowCount] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_ROC,
        GC_ROC_GC_ID,
        GC_ROC_GatheredConstruct_RowCount,
        GC_ROC_ChangedAt
    FROM
        [stats].[GC_ROC_GatheredConstruct_RowCount]
    WHERE
        GC_ROC_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_RGR_GatheredConstruct_RowGrowth rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_RGR_GatheredConstruct_RowGrowth','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_RGR_GatheredConstruct_RowGrowth] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_RGR,
        GC_RGR_GC_ID,
        GC_RGR_GatheredConstruct_RowGrowth,
        GC_RGR_ChangedAt
    FROM
        [stats].[GC_RGR_GatheredConstruct_RowGrowth]
    WHERE
        GC_RGR_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_RGN_GatheredConstruct_RowGrowthNormal rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_RGN_GatheredConstruct_RowGrowthNormal','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_RGN_GatheredConstruct_RowGrowthNormal] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_RGN,
        GC_RGN_GC_ID,
        GC_RGN_GatheredConstruct_RowGrowthNormal,
        GC_RGN_ChangedAt
    FROM
        [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal]
    WHERE
        GC_RGN_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_UMB_GatheredConstruct_UsedMegabytes rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_UMB_GatheredConstruct_UsedMegabytes','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_UMB_GatheredConstruct_UsedMegabytes] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_UMB,
        GC_UMB_GC_ID,
        GC_UMB_GatheredConstruct_UsedMegabytes,
        GC_UMB_ChangedAt
    FROM
        [stats].[GC_UMB_GatheredConstruct_UsedMegabytes]
    WHERE
        GC_UMB_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_UGR_GatheredConstruct_UsedGrowth rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_UGR_GatheredConstruct_UsedGrowth','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_UGR_GatheredConstruct_UsedGrowth] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_UGR,
        GC_UGR_GC_ID,
        GC_UGR_GatheredConstruct_UsedGrowth,
        GC_UGR_ChangedAt
    FROM
        [stats].[GC_UGR_GatheredConstruct_UsedGrowth]
    WHERE
        GC_UGR_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_UGN_GatheredConstruct_UsedGrowthNormal rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_UGN_GatheredConstruct_UsedGrowthNormal','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_UGN_GatheredConstruct_UsedGrowthNormal] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_UGN,
        GC_UGN_GC_ID,
        GC_UGN_GatheredConstruct_UsedGrowthNormal,
        GC_UGN_ChangedAt
    FROM
        [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal]
    WHERE
        GC_UGN_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_AMB_GatheredConstruct_AllocatedMegabytes rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_AMB_GatheredConstruct_AllocatedMegabytes','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_AMB_GatheredConstruct_AllocatedMegabytes] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_AMB,
        GC_AMB_GC_ID,
        GC_AMB_GatheredConstruct_AllocatedMegabytes,
        GC_AMB_ChangedAt
    FROM
        [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes]
    WHERE
        GC_AMB_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_AGR_GatheredConstruct_AllocatedGrowth rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_AGR_GatheredConstruct_AllocatedGrowth','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_AGR_GatheredConstruct_AllocatedGrowth] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_AGR,
        GC_AGR_GC_ID,
        GC_AGR_GatheredConstruct_AllocatedGrowth,
        GC_AGR_ChangedAt
    FROM
        [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth]
    WHERE
        GC_AGR_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_AGN_GatheredConstruct_AllocatedGrowthNormal rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_AGN_GatheredConstruct_AllocatedGrowthNormal','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_AGN_GatheredConstruct_AllocatedGrowthNormal] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_AGN,
        GC_AGN_GC_ID,
        GC_AGN_GatheredConstruct_AllocatedGrowthNormal,
        GC_AGN_ChangedAt
    FROM
        [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal]
    WHERE
        GC_AGN_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_AGI_GatheredConstruct_AllocatedGrowthInterval rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_AGI_GatheredConstruct_AllocatedGrowthInterval','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_AGI_GatheredConstruct_AllocatedGrowthInterval] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_AGI,
        GC_AGI_GC_ID,
        GC_AGI_GatheredConstruct_AllocatedGrowthInterval,
        GC_AGI_ChangedAt
    FROM
        [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval]
    WHERE
        GC_AGI_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_UGI_GatheredConstruct_UsedGrowthInterval rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_UGI_GatheredConstruct_UsedGrowthInterval','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_UGI_GatheredConstruct_UsedGrowthInterval] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_UGI,
        GC_UGI_GC_ID,
        GC_UGI_GatheredConstruct_UsedGrowthInterval,
        GC_UGI_ChangedAt
    FROM
        [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval]
    WHERE
        GC_UGI_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_RGI_GatheredConstruct_RowGrowthInterval rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_RGI_GatheredConstruct_RowGrowthInterval','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_RGI_GatheredConstruct_RowGrowthInterval] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_RGI,
        GC_RGI_GC_ID,
        GC_RGI_GatheredConstruct_RowGrowthInterval,
        GC_RGI_ChangedAt
    FROM
        [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval]
    WHERE
        GC_RGI_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rGC_LGT_GatheredConstruct_LatestGatheringTime rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.rGC_LGT_GatheredConstruct_LatestGatheringTime','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [stats].[rGC_LGT_GatheredConstruct_LatestGatheringTime] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_GC_LGT,
        GC_LGT_GC_ID,
        GC_LGT_GatheredConstruct_LatestGatheringTime,
        GC_LGT_ChangedAt
    FROM
        [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime]
    WHERE
        GC_LGT_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- ANCHOR TEMPORAL BUSINESS PERSPECTIVES ------------------------------------------------------------------------------
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('stats.Difference_GatheredConstruct', 'IF') IS NOT NULL
DROP FUNCTION [stats].[Difference_GatheredConstruct];
IF Object_ID('stats.Current_GatheredConstruct', 'V') IS NOT NULL
DROP VIEW [stats].[Current_GatheredConstruct];
IF Object_ID('stats.Point_GatheredConstruct', 'IF') IS NOT NULL
DROP FUNCTION [stats].[Point_GatheredConstruct];
IF Object_ID('stats.Latest_GatheredConstruct', 'V') IS NOT NULL
DROP VIEW [stats].[Latest_GatheredConstruct];
GO
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are four types of perspectives: latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The latest perspective shows the latest available information for each anchor.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('stats.dGC_GatheredConstruct', 'IF') IS NOT NULL
DROP FUNCTION [stats].[dGC_GatheredConstruct];
IF Object_ID('stats.nGC_GatheredConstruct', 'V') IS NOT NULL
DROP VIEW [stats].[nGC_GatheredConstruct];
IF Object_ID('stats.pGC_GatheredConstruct', 'IF') IS NOT NULL
DROP FUNCTION [stats].[pGC_GatheredConstruct];
IF Object_ID('stats.lGC_GatheredConstruct', 'V') IS NOT NULL
DROP VIEW [stats].[lGC_GatheredConstruct];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lGC_GatheredConstruct viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [stats].[lGC_GatheredConstruct] WITH SCHEMABINDING AS
SELECT
    [GC].GC_ID,
    [GC].Metadata_GC,
    [NAM].GC_NAM_GC_ID,
    [NAM].Metadata_GC_NAM,
    [NAM].GC_NAM_GatheredConstruct_Name,
    [CAP].GC_CAP_GC_ID,
    [CAP].Metadata_GC_CAP,
    [CAP].GC_CAP_GatheredConstruct_Capsule,
    [TYP].GC_TYP_GC_ID,
    [TYP].Metadata_GC_TYP,
    [kTYP].TYP_Type AS GC_TYP_TYP_Type,
    [kTYP].Metadata_TYP AS GC_TYP_Metadata_TYP,
    [TYP].GC_TYP_TYP_ID,
    [ROC].GC_ROC_GC_ID,
    [ROC].Metadata_GC_ROC,
    [ROC].GC_ROC_ChangedAt,
    [ROC].GC_ROC_GatheredConstruct_RowCount,
    [RGR].GC_RGR_GC_ID,
    [RGR].Metadata_GC_RGR,
    [RGR].GC_RGR_ChangedAt,
    [RGR].GC_RGR_GatheredConstruct_RowGrowth,
    [RGN].GC_RGN_GC_ID,
    [RGN].Metadata_GC_RGN,
    [RGN].GC_RGN_ChangedAt,
    [RGN].GC_RGN_GatheredConstruct_RowGrowthNormal,
    [UMB].GC_UMB_GC_ID,
    [UMB].Metadata_GC_UMB,
    [UMB].GC_UMB_ChangedAt,
    [UMB].GC_UMB_GatheredConstruct_UsedMegabytes,
    [UGR].GC_UGR_GC_ID,
    [UGR].Metadata_GC_UGR,
    [UGR].GC_UGR_ChangedAt,
    [UGR].GC_UGR_GatheredConstruct_UsedGrowth,
    [UGN].GC_UGN_GC_ID,
    [UGN].Metadata_GC_UGN,
    [UGN].GC_UGN_ChangedAt,
    [UGN].GC_UGN_GatheredConstruct_UsedGrowthNormal,
    [AMB].GC_AMB_GC_ID,
    [AMB].Metadata_GC_AMB,
    [AMB].GC_AMB_ChangedAt,
    [AMB].GC_AMB_GatheredConstruct_AllocatedMegabytes,
    [AGR].GC_AGR_GC_ID,
    [AGR].Metadata_GC_AGR,
    [AGR].GC_AGR_ChangedAt,
    [AGR].GC_AGR_GatheredConstruct_AllocatedGrowth,
    [AGN].GC_AGN_GC_ID,
    [AGN].Metadata_GC_AGN,
    [AGN].GC_AGN_ChangedAt,
    [AGN].GC_AGN_GatheredConstruct_AllocatedGrowthNormal,
    [AGI].GC_AGI_GC_ID,
    [AGI].Metadata_GC_AGI,
    [AGI].GC_AGI_ChangedAt,
    [AGI].GC_AGI_GatheredConstruct_AllocatedGrowthInterval,
    [UGI].GC_UGI_GC_ID,
    [UGI].Metadata_GC_UGI,
    [UGI].GC_UGI_ChangedAt,
    [UGI].GC_UGI_GatheredConstruct_UsedGrowthInterval,
    [RGI].GC_RGI_GC_ID,
    [RGI].Metadata_GC_RGI,
    [RGI].GC_RGI_ChangedAt,
    [RGI].GC_RGI_GatheredConstruct_RowGrowthInterval,
    [LGT].GC_LGT_GC_ID,
    [LGT].Metadata_GC_LGT,
    [LGT].GC_LGT_ChangedAt,
    [LGT].GC_LGT_GatheredConstruct_LatestGatheringTime
FROM
    [stats].[GC_GatheredConstruct] [GC]
LEFT JOIN
    [stats].[GC_NAM_GatheredConstruct_Name] [NAM]
ON
    [NAM].GC_NAM_GC_ID = [GC].GC_ID
LEFT JOIN
    [stats].[GC_CAP_GatheredConstruct_Capsule] [CAP]
ON
    [CAP].GC_CAP_GC_ID = [GC].GC_ID
LEFT JOIN
    [stats].[GC_TYP_GatheredConstruct_Type] [TYP]
ON
    [TYP].GC_TYP_GC_ID = [GC].GC_ID
LEFT JOIN
    [stats].[TYP_Type] [kTYP]
ON
    [kTYP].TYP_ID = [TYP].GC_TYP_TYP_ID
LEFT JOIN
    [stats].[GC_ROC_GatheredConstruct_RowCount] [ROC]
ON
    [ROC].GC_ROC_GC_ID = [GC].GC_ID
AND
    [ROC].GC_ROC_ChangedAt = (
        SELECT
            max(sub.GC_ROC_ChangedAt)
        FROM
            [stats].[GC_ROC_GatheredConstruct_RowCount] sub
        WHERE
            sub.GC_ROC_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_RGR_GatheredConstruct_RowGrowth] [RGR]
ON
    [RGR].GC_RGR_GC_ID = [GC].GC_ID
AND
    [RGR].GC_RGR_ChangedAt = (
        SELECT
            max(sub.GC_RGR_ChangedAt)
        FROM
            [stats].[GC_RGR_GatheredConstruct_RowGrowth] sub
        WHERE
            sub.GC_RGR_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] [RGN]
ON
    [RGN].GC_RGN_GC_ID = [GC].GC_ID
AND
    [RGN].GC_RGN_ChangedAt = (
        SELECT
            max(sub.GC_RGN_ChangedAt)
        FROM
            [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] sub
        WHERE
            sub.GC_RGN_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] [UMB]
ON
    [UMB].GC_UMB_GC_ID = [GC].GC_ID
AND
    [UMB].GC_UMB_ChangedAt = (
        SELECT
            max(sub.GC_UMB_ChangedAt)
        FROM
            [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] sub
        WHERE
            sub.GC_UMB_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_UGR_GatheredConstruct_UsedGrowth] [UGR]
ON
    [UGR].GC_UGR_GC_ID = [GC].GC_ID
AND
    [UGR].GC_UGR_ChangedAt = (
        SELECT
            max(sub.GC_UGR_ChangedAt)
        FROM
            [stats].[GC_UGR_GatheredConstruct_UsedGrowth] sub
        WHERE
            sub.GC_UGR_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] [UGN]
ON
    [UGN].GC_UGN_GC_ID = [GC].GC_ID
AND
    [UGN].GC_UGN_ChangedAt = (
        SELECT
            max(sub.GC_UGN_ChangedAt)
        FROM
            [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] sub
        WHERE
            sub.GC_UGN_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] [AMB]
ON
    [AMB].GC_AMB_GC_ID = [GC].GC_ID
AND
    [AMB].GC_AMB_ChangedAt = (
        SELECT
            max(sub.GC_AMB_ChangedAt)
        FROM
            [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] sub
        WHERE
            sub.GC_AMB_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] [AGR]
ON
    [AGR].GC_AGR_GC_ID = [GC].GC_ID
AND
    [AGR].GC_AGR_ChangedAt = (
        SELECT
            max(sub.GC_AGR_ChangedAt)
        FROM
            [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] sub
        WHERE
            sub.GC_AGR_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] [AGN]
ON
    [AGN].GC_AGN_GC_ID = [GC].GC_ID
AND
    [AGN].GC_AGN_ChangedAt = (
        SELECT
            max(sub.GC_AGN_ChangedAt)
        FROM
            [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] sub
        WHERE
            sub.GC_AGN_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] [AGI]
ON
    [AGI].GC_AGI_GC_ID = [GC].GC_ID
AND
    [AGI].GC_AGI_ChangedAt = (
        SELECT
            max(sub.GC_AGI_ChangedAt)
        FROM
            [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] sub
        WHERE
            sub.GC_AGI_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] [UGI]
ON
    [UGI].GC_UGI_GC_ID = [GC].GC_ID
AND
    [UGI].GC_UGI_ChangedAt = (
        SELECT
            max(sub.GC_UGI_ChangedAt)
        FROM
            [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] sub
        WHERE
            sub.GC_UGI_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] [RGI]
ON
    [RGI].GC_RGI_GC_ID = [GC].GC_ID
AND
    [RGI].GC_RGI_ChangedAt = (
        SELECT
            max(sub.GC_RGI_ChangedAt)
        FROM
            [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] sub
        WHERE
            sub.GC_RGI_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] [LGT]
ON
    [LGT].GC_LGT_GC_ID = [GC].GC_ID
AND
    [LGT].GC_LGT_ChangedAt = (
        SELECT
            max(sub.GC_LGT_ChangedAt)
        FROM
            [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] sub
        WHERE
            sub.GC_LGT_GC_ID = [GC].GC_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pGC_GatheredConstruct viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [stats].[pGC_GatheredConstruct] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [GC].GC_ID,
    [GC].Metadata_GC,
    [NAM].GC_NAM_GC_ID,
    [NAM].Metadata_GC_NAM,
    [NAM].GC_NAM_GatheredConstruct_Name,
    [CAP].GC_CAP_GC_ID,
    [CAP].Metadata_GC_CAP,
    [CAP].GC_CAP_GatheredConstruct_Capsule,
    [TYP].GC_TYP_GC_ID,
    [TYP].Metadata_GC_TYP,
    [kTYP].TYP_Type AS GC_TYP_TYP_Type,
    [kTYP].Metadata_TYP AS GC_TYP_Metadata_TYP,
    [TYP].GC_TYP_TYP_ID,
    [ROC].GC_ROC_GC_ID,
    [ROC].Metadata_GC_ROC,
    [ROC].GC_ROC_ChangedAt,
    [ROC].GC_ROC_GatheredConstruct_RowCount,
    [RGR].GC_RGR_GC_ID,
    [RGR].Metadata_GC_RGR,
    [RGR].GC_RGR_ChangedAt,
    [RGR].GC_RGR_GatheredConstruct_RowGrowth,
    [RGN].GC_RGN_GC_ID,
    [RGN].Metadata_GC_RGN,
    [RGN].GC_RGN_ChangedAt,
    [RGN].GC_RGN_GatheredConstruct_RowGrowthNormal,
    [UMB].GC_UMB_GC_ID,
    [UMB].Metadata_GC_UMB,
    [UMB].GC_UMB_ChangedAt,
    [UMB].GC_UMB_GatheredConstruct_UsedMegabytes,
    [UGR].GC_UGR_GC_ID,
    [UGR].Metadata_GC_UGR,
    [UGR].GC_UGR_ChangedAt,
    [UGR].GC_UGR_GatheredConstruct_UsedGrowth,
    [UGN].GC_UGN_GC_ID,
    [UGN].Metadata_GC_UGN,
    [UGN].GC_UGN_ChangedAt,
    [UGN].GC_UGN_GatheredConstruct_UsedGrowthNormal,
    [AMB].GC_AMB_GC_ID,
    [AMB].Metadata_GC_AMB,
    [AMB].GC_AMB_ChangedAt,
    [AMB].GC_AMB_GatheredConstruct_AllocatedMegabytes,
    [AGR].GC_AGR_GC_ID,
    [AGR].Metadata_GC_AGR,
    [AGR].GC_AGR_ChangedAt,
    [AGR].GC_AGR_GatheredConstruct_AllocatedGrowth,
    [AGN].GC_AGN_GC_ID,
    [AGN].Metadata_GC_AGN,
    [AGN].GC_AGN_ChangedAt,
    [AGN].GC_AGN_GatheredConstruct_AllocatedGrowthNormal,
    [AGI].GC_AGI_GC_ID,
    [AGI].Metadata_GC_AGI,
    [AGI].GC_AGI_ChangedAt,
    [AGI].GC_AGI_GatheredConstruct_AllocatedGrowthInterval,
    [UGI].GC_UGI_GC_ID,
    [UGI].Metadata_GC_UGI,
    [UGI].GC_UGI_ChangedAt,
    [UGI].GC_UGI_GatheredConstruct_UsedGrowthInterval,
    [RGI].GC_RGI_GC_ID,
    [RGI].Metadata_GC_RGI,
    [RGI].GC_RGI_ChangedAt,
    [RGI].GC_RGI_GatheredConstruct_RowGrowthInterval,
    [LGT].GC_LGT_GC_ID,
    [LGT].Metadata_GC_LGT,
    [LGT].GC_LGT_ChangedAt,
    [LGT].GC_LGT_GatheredConstruct_LatestGatheringTime
FROM
    [stats].[GC_GatheredConstruct] [GC]
LEFT JOIN
    [stats].[GC_NAM_GatheredConstruct_Name] [NAM]
ON
    [NAM].GC_NAM_GC_ID = [GC].GC_ID
LEFT JOIN
    [stats].[GC_CAP_GatheredConstruct_Capsule] [CAP]
ON
    [CAP].GC_CAP_GC_ID = [GC].GC_ID
LEFT JOIN
    [stats].[GC_TYP_GatheredConstruct_Type] [TYP]
ON
    [TYP].GC_TYP_GC_ID = [GC].GC_ID
LEFT JOIN
    [stats].[TYP_Type] [kTYP]
ON
    [kTYP].TYP_ID = [TYP].GC_TYP_TYP_ID
LEFT JOIN
    [stats].[rGC_ROC_GatheredConstruct_RowCount](@changingTimepoint) [ROC]
ON
    [ROC].GC_ROC_GC_ID = [GC].GC_ID
AND
    [ROC].GC_ROC_ChangedAt = (
        SELECT
            max(sub.GC_ROC_ChangedAt)
        FROM
            [stats].[rGC_ROC_GatheredConstruct_RowCount](@changingTimepoint) sub
        WHERE
            sub.GC_ROC_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_RGR_GatheredConstruct_RowGrowth](@changingTimepoint) [RGR]
ON
    [RGR].GC_RGR_GC_ID = [GC].GC_ID
AND
    [RGR].GC_RGR_ChangedAt = (
        SELECT
            max(sub.GC_RGR_ChangedAt)
        FROM
            [stats].[rGC_RGR_GatheredConstruct_RowGrowth](@changingTimepoint) sub
        WHERE
            sub.GC_RGR_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_RGN_GatheredConstruct_RowGrowthNormal](@changingTimepoint) [RGN]
ON
    [RGN].GC_RGN_GC_ID = [GC].GC_ID
AND
    [RGN].GC_RGN_ChangedAt = (
        SELECT
            max(sub.GC_RGN_ChangedAt)
        FROM
            [stats].[rGC_RGN_GatheredConstruct_RowGrowthNormal](@changingTimepoint) sub
        WHERE
            sub.GC_RGN_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_UMB_GatheredConstruct_UsedMegabytes](@changingTimepoint) [UMB]
ON
    [UMB].GC_UMB_GC_ID = [GC].GC_ID
AND
    [UMB].GC_UMB_ChangedAt = (
        SELECT
            max(sub.GC_UMB_ChangedAt)
        FROM
            [stats].[rGC_UMB_GatheredConstruct_UsedMegabytes](@changingTimepoint) sub
        WHERE
            sub.GC_UMB_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_UGR_GatheredConstruct_UsedGrowth](@changingTimepoint) [UGR]
ON
    [UGR].GC_UGR_GC_ID = [GC].GC_ID
AND
    [UGR].GC_UGR_ChangedAt = (
        SELECT
            max(sub.GC_UGR_ChangedAt)
        FROM
            [stats].[rGC_UGR_GatheredConstruct_UsedGrowth](@changingTimepoint) sub
        WHERE
            sub.GC_UGR_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_UGN_GatheredConstruct_UsedGrowthNormal](@changingTimepoint) [UGN]
ON
    [UGN].GC_UGN_GC_ID = [GC].GC_ID
AND
    [UGN].GC_UGN_ChangedAt = (
        SELECT
            max(sub.GC_UGN_ChangedAt)
        FROM
            [stats].[rGC_UGN_GatheredConstruct_UsedGrowthNormal](@changingTimepoint) sub
        WHERE
            sub.GC_UGN_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_AMB_GatheredConstruct_AllocatedMegabytes](@changingTimepoint) [AMB]
ON
    [AMB].GC_AMB_GC_ID = [GC].GC_ID
AND
    [AMB].GC_AMB_ChangedAt = (
        SELECT
            max(sub.GC_AMB_ChangedAt)
        FROM
            [stats].[rGC_AMB_GatheredConstruct_AllocatedMegabytes](@changingTimepoint) sub
        WHERE
            sub.GC_AMB_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_AGR_GatheredConstruct_AllocatedGrowth](@changingTimepoint) [AGR]
ON
    [AGR].GC_AGR_GC_ID = [GC].GC_ID
AND
    [AGR].GC_AGR_ChangedAt = (
        SELECT
            max(sub.GC_AGR_ChangedAt)
        FROM
            [stats].[rGC_AGR_GatheredConstruct_AllocatedGrowth](@changingTimepoint) sub
        WHERE
            sub.GC_AGR_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_AGN_GatheredConstruct_AllocatedGrowthNormal](@changingTimepoint) [AGN]
ON
    [AGN].GC_AGN_GC_ID = [GC].GC_ID
AND
    [AGN].GC_AGN_ChangedAt = (
        SELECT
            max(sub.GC_AGN_ChangedAt)
        FROM
            [stats].[rGC_AGN_GatheredConstruct_AllocatedGrowthNormal](@changingTimepoint) sub
        WHERE
            sub.GC_AGN_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_AGI_GatheredConstruct_AllocatedGrowthInterval](@changingTimepoint) [AGI]
ON
    [AGI].GC_AGI_GC_ID = [GC].GC_ID
AND
    [AGI].GC_AGI_ChangedAt = (
        SELECT
            max(sub.GC_AGI_ChangedAt)
        FROM
            [stats].[rGC_AGI_GatheredConstruct_AllocatedGrowthInterval](@changingTimepoint) sub
        WHERE
            sub.GC_AGI_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_UGI_GatheredConstruct_UsedGrowthInterval](@changingTimepoint) [UGI]
ON
    [UGI].GC_UGI_GC_ID = [GC].GC_ID
AND
    [UGI].GC_UGI_ChangedAt = (
        SELECT
            max(sub.GC_UGI_ChangedAt)
        FROM
            [stats].[rGC_UGI_GatheredConstruct_UsedGrowthInterval](@changingTimepoint) sub
        WHERE
            sub.GC_UGI_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_RGI_GatheredConstruct_RowGrowthInterval](@changingTimepoint) [RGI]
ON
    [RGI].GC_RGI_GC_ID = [GC].GC_ID
AND
    [RGI].GC_RGI_ChangedAt = (
        SELECT
            max(sub.GC_RGI_ChangedAt)
        FROM
            [stats].[rGC_RGI_GatheredConstruct_RowGrowthInterval](@changingTimepoint) sub
        WHERE
            sub.GC_RGI_GC_ID = [GC].GC_ID
   )
LEFT JOIN
    [stats].[rGC_LGT_GatheredConstruct_LatestGatheringTime](@changingTimepoint) [LGT]
ON
    [LGT].GC_LGT_GC_ID = [GC].GC_ID
AND
    [LGT].GC_LGT_ChangedAt = (
        SELECT
            max(sub.GC_LGT_ChangedAt)
        FROM
            [stats].[rGC_LGT_GatheredConstruct_LatestGatheringTime](@changingTimepoint) sub
        WHERE
            sub.GC_LGT_GC_ID = [GC].GC_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nGC_GatheredConstruct viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [stats].[nGC_GatheredConstruct]
AS
SELECT
    *
FROM
    [stats].[pGC_GatheredConstruct](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dGC_GatheredConstruct showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [stats].[dGC_GatheredConstruct] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pGC].*
FROM (
    SELECT DISTINCT
        GC_ROC_GC_ID AS GC_ID,
        GC_ROC_ChangedAt AS inspectedTimepoint,
        'ROC' AS mnemonic
    FROM
        [stats].[GC_ROC_GatheredConstruct_RowCount]
    WHERE
        (@selection is null OR @selection like '%ROC%')
    AND
        GC_ROC_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_RGR_GC_ID AS GC_ID,
        GC_RGR_ChangedAt AS inspectedTimepoint,
        'RGR' AS mnemonic
    FROM
        [stats].[GC_RGR_GatheredConstruct_RowGrowth]
    WHERE
        (@selection is null OR @selection like '%RGR%')
    AND
        GC_RGR_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_RGN_GC_ID AS GC_ID,
        GC_RGN_ChangedAt AS inspectedTimepoint,
        'RGN' AS mnemonic
    FROM
        [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal]
    WHERE
        (@selection is null OR @selection like '%RGN%')
    AND
        GC_RGN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_UMB_GC_ID AS GC_ID,
        GC_UMB_ChangedAt AS inspectedTimepoint,
        'UMB' AS mnemonic
    FROM
        [stats].[GC_UMB_GatheredConstruct_UsedMegabytes]
    WHERE
        (@selection is null OR @selection like '%UMB%')
    AND
        GC_UMB_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_UGR_GC_ID AS GC_ID,
        GC_UGR_ChangedAt AS inspectedTimepoint,
        'UGR' AS mnemonic
    FROM
        [stats].[GC_UGR_GatheredConstruct_UsedGrowth]
    WHERE
        (@selection is null OR @selection like '%UGR%')
    AND
        GC_UGR_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_UGN_GC_ID AS GC_ID,
        GC_UGN_ChangedAt AS inspectedTimepoint,
        'UGN' AS mnemonic
    FROM
        [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal]
    WHERE
        (@selection is null OR @selection like '%UGN%')
    AND
        GC_UGN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_AMB_GC_ID AS GC_ID,
        GC_AMB_ChangedAt AS inspectedTimepoint,
        'AMB' AS mnemonic
    FROM
        [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes]
    WHERE
        (@selection is null OR @selection like '%AMB%')
    AND
        GC_AMB_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_AGR_GC_ID AS GC_ID,
        GC_AGR_ChangedAt AS inspectedTimepoint,
        'AGR' AS mnemonic
    FROM
        [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth]
    WHERE
        (@selection is null OR @selection like '%AGR%')
    AND
        GC_AGR_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_AGN_GC_ID AS GC_ID,
        GC_AGN_ChangedAt AS inspectedTimepoint,
        'AGN' AS mnemonic
    FROM
        [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal]
    WHERE
        (@selection is null OR @selection like '%AGN%')
    AND
        GC_AGN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_AGI_GC_ID AS GC_ID,
        GC_AGI_ChangedAt AS inspectedTimepoint,
        'AGI' AS mnemonic
    FROM
        [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval]
    WHERE
        (@selection is null OR @selection like '%AGI%')
    AND
        GC_AGI_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_UGI_GC_ID AS GC_ID,
        GC_UGI_ChangedAt AS inspectedTimepoint,
        'UGI' AS mnemonic
    FROM
        [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval]
    WHERE
        (@selection is null OR @selection like '%UGI%')
    AND
        GC_UGI_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_RGI_GC_ID AS GC_ID,
        GC_RGI_ChangedAt AS inspectedTimepoint,
        'RGI' AS mnemonic
    FROM
        [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval]
    WHERE
        (@selection is null OR @selection like '%RGI%')
    AND
        GC_RGI_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_LGT_GC_ID AS GC_ID,
        GC_LGT_ChangedAt AS inspectedTimepoint,
        'LGT' AS mnemonic
    FROM
        [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime]
    WHERE
        (@selection is null OR @selection like '%LGT%')
    AND
        GC_LGT_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [stats].[pGC_GatheredConstruct](timepoints.inspectedTimepoint) [pGC]
WHERE
    [pGC].GC_ID = timepoints.GC_ID;
GO
-- ANCHOR TEMPORAL BUSINESS PERSPECTIVES ------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are four types of perspectives: latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The latest perspective shows the latest available information for each anchor.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-EQ perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_GatheredConstruct viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [stats].[Latest_GatheredConstruct] AS
SELECT
    [GC].GC_ID as [GatheredConstruct_Id],
    [GC].GC_NAM_GatheredConstruct_Name as [Name],
    [GC].GC_CAP_GatheredConstruct_Capsule as [Capsule],
    [GC].GC_TYP_TYP_Type as [Type_Type],
    [GC].GC_ROC_GatheredConstruct_RowCount as [RowCount],
    [GC].GC_RGR_GatheredConstruct_RowGrowth as [RowGrowth],
    [GC].GC_RGN_GatheredConstruct_RowGrowthNormal as [RowGrowthNormal],
    [GC].GC_UMB_GatheredConstruct_UsedMegabytes as [UsedMegabytes],
    [GC].GC_UGR_GatheredConstruct_UsedGrowth as [UsedGrowth],
    [GC].GC_UGN_GatheredConstruct_UsedGrowthNormal as [UsedGrowthNormal],
    [GC].GC_AMB_GatheredConstruct_AllocatedMegabytes as [AllocatedMegabytes],
    [GC].GC_AGR_GatheredConstruct_AllocatedGrowth as [AllocatedGrowth],
    [GC].GC_AGN_GatheredConstruct_AllocatedGrowthNormal as [AllocatedGrowthNormal],
    [GC].GC_AGI_GatheredConstruct_AllocatedGrowthInterval as [AllocatedGrowthInterval],
    [GC].GC_UGI_GatheredConstruct_UsedGrowthInterval as [UsedGrowthInterval],
    [GC].GC_RGI_GatheredConstruct_RowGrowthInterval as [RowGrowthInterval],
    [GC].GC_LGT_GatheredConstruct_LatestGatheringTime as [LatestGatheringTime]
FROM
    [stats].[lGC_GatheredConstruct] [GC];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_GatheredConstruct viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [stats].[Point_GatheredConstruct] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE AS RETURN
SELECT
    [GC].GC_ID as [GatheredConstruct_Id],
    [GC].GC_NAM_GatheredConstruct_Name as [Name],
    [GC].GC_CAP_GatheredConstruct_Capsule as [Capsule],
    [GC].GC_TYP_TYP_Type as [Type_Type],
    [GC].GC_ROC_GatheredConstruct_RowCount as [RowCount],
    [GC].GC_RGR_GatheredConstruct_RowGrowth as [RowGrowth],
    [GC].GC_RGN_GatheredConstruct_RowGrowthNormal as [RowGrowthNormal],
    [GC].GC_UMB_GatheredConstruct_UsedMegabytes as [UsedMegabytes],
    [GC].GC_UGR_GatheredConstruct_UsedGrowth as [UsedGrowth],
    [GC].GC_UGN_GatheredConstruct_UsedGrowthNormal as [UsedGrowthNormal],
    [GC].GC_AMB_GatheredConstruct_AllocatedMegabytes as [AllocatedMegabytes],
    [GC].GC_AGR_GatheredConstruct_AllocatedGrowth as [AllocatedGrowth],
    [GC].GC_AGN_GatheredConstruct_AllocatedGrowthNormal as [AllocatedGrowthNormal],
    [GC].GC_AGI_GatheredConstruct_AllocatedGrowthInterval as [AllocatedGrowthInterval],
    [GC].GC_UGI_GatheredConstruct_UsedGrowthInterval as [UsedGrowthInterval],
    [GC].GC_RGI_GatheredConstruct_RowGrowthInterval as [RowGrowthInterval],
    [GC].GC_LGT_GatheredConstruct_LatestGatheringTime as [LatestGatheringTime]
FROM
    [stats].[pGC_GatheredConstruct](@changingTimepoint) [GC]
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_GatheredConstruct viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [stats].[Current_GatheredConstruct]
AS
SELECT
    *
FROM
    [stats].[Point_GatheredConstruct](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_GatheredConstruct showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [stats].[Difference_GatheredConstruct] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pGC].*
FROM (
    SELECT DISTINCT
        GC_ROC_GC_ID AS GC_ID,
        GC_ROC_ChangedAt AS [Time_of_Change],
        'RowCount' AS [Subject_of_Change]
    FROM
        [stats].[GC_ROC_GatheredConstruct_RowCount]
    WHERE
        (@selection is null OR @selection like '%ROC%')
    AND
        GC_ROC_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_RGR_GC_ID AS GC_ID,
        GC_RGR_ChangedAt AS [Time_of_Change],
        'RowGrowth' AS [Subject_of_Change]
    FROM
        [stats].[GC_RGR_GatheredConstruct_RowGrowth]
    WHERE
        (@selection is null OR @selection like '%RGR%')
    AND
        GC_RGR_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_RGN_GC_ID AS GC_ID,
        GC_RGN_ChangedAt AS [Time_of_Change],
        'RowGrowthNormal' AS [Subject_of_Change]
    FROM
        [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal]
    WHERE
        (@selection is null OR @selection like '%RGN%')
    AND
        GC_RGN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_UMB_GC_ID AS GC_ID,
        GC_UMB_ChangedAt AS [Time_of_Change],
        'UsedMegabytes' AS [Subject_of_Change]
    FROM
        [stats].[GC_UMB_GatheredConstruct_UsedMegabytes]
    WHERE
        (@selection is null OR @selection like '%UMB%')
    AND
        GC_UMB_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_UGR_GC_ID AS GC_ID,
        GC_UGR_ChangedAt AS [Time_of_Change],
        'UsedGrowth' AS [Subject_of_Change]
    FROM
        [stats].[GC_UGR_GatheredConstruct_UsedGrowth]
    WHERE
        (@selection is null OR @selection like '%UGR%')
    AND
        GC_UGR_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_UGN_GC_ID AS GC_ID,
        GC_UGN_ChangedAt AS [Time_of_Change],
        'UsedGrowthNormal' AS [Subject_of_Change]
    FROM
        [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal]
    WHERE
        (@selection is null OR @selection like '%UGN%')
    AND
        GC_UGN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_AMB_GC_ID AS GC_ID,
        GC_AMB_ChangedAt AS [Time_of_Change],
        'AllocatedMegabytes' AS [Subject_of_Change]
    FROM
        [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes]
    WHERE
        (@selection is null OR @selection like '%AMB%')
    AND
        GC_AMB_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_AGR_GC_ID AS GC_ID,
        GC_AGR_ChangedAt AS [Time_of_Change],
        'AllocatedGrowth' AS [Subject_of_Change]
    FROM
        [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth]
    WHERE
        (@selection is null OR @selection like '%AGR%')
    AND
        GC_AGR_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_AGN_GC_ID AS GC_ID,
        GC_AGN_ChangedAt AS [Time_of_Change],
        'AllocatedGrowthNormal' AS [Subject_of_Change]
    FROM
        [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal]
    WHERE
        (@selection is null OR @selection like '%AGN%')
    AND
        GC_AGN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_AGI_GC_ID AS GC_ID,
        GC_AGI_ChangedAt AS [Time_of_Change],
        'AllocatedGrowthInterval' AS [Subject_of_Change]
    FROM
        [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval]
    WHERE
        (@selection is null OR @selection like '%AGI%')
    AND
        GC_AGI_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_UGI_GC_ID AS GC_ID,
        GC_UGI_ChangedAt AS [Time_of_Change],
        'UsedGrowthInterval' AS [Subject_of_Change]
    FROM
        [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval]
    WHERE
        (@selection is null OR @selection like '%UGI%')
    AND
        GC_UGI_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_RGI_GC_ID AS GC_ID,
        GC_RGI_ChangedAt AS [Time_of_Change],
        'RowGrowthInterval' AS [Subject_of_Change]
    FROM
        [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval]
    WHERE
        (@selection is null OR @selection like '%RGI%')
    AND
        GC_RGI_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        GC_LGT_GC_ID AS GC_ID,
        GC_LGT_ChangedAt AS [Time_of_Change],
        'LatestGatheringTime' AS [Subject_of_Change]
    FROM
        [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime]
    WHERE
        (@selection is null OR @selection like '%LGT%')
    AND
        GC_LGT_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [stats].[Point_GatheredConstruct](timepoints.[Time_of_Change]) [pGC]
WHERE
    [pGC].GatheredConstruct_Id = timepoints.GC_ID;
GO
-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the attributes make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_NAM_GatheredConstruct_Name instead of INSERT trigger on GC_NAM_GatheredConstruct_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_NAM_GatheredConstruct_Name', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_NAM_GatheredConstruct_Name];
GO
CREATE TRIGGER [stats].[it_GC_NAM_GatheredConstruct_Name] ON [stats].[GC_NAM_GatheredConstruct_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_NAM_GatheredConstruct_Name TABLE (
        GC_NAM_GC_ID int not null,
        Metadata_GC_NAM int not null,
        GC_NAM_GatheredConstruct_Name nvarchar(128) not null,
        GC_NAM_Version bigint not null,
        GC_NAM_StatementType char(1) not null,
        primary key(
            GC_NAM_Version,
            GC_NAM_GC_ID
        )
    );
    INSERT INTO @GC_NAM_GatheredConstruct_Name
    SELECT
        i.GC_NAM_GC_ID,
        i.Metadata_GC_NAM,
        i.GC_NAM_GatheredConstruct_Name,
        ROW_NUMBER() OVER (
            PARTITION BY
                i.GC_NAM_GC_ID
            ORDER BY
                (SELECT 1) ASC -- some undefined order
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = 1,
        @currentVersion = 0
    FROM
        @GC_NAM_GatheredConstruct_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_NAM_StatementType =
                CASE
                    WHEN [NAM].GC_NAM_GC_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_NAM_GatheredConstruct_Name v
        LEFT JOIN
            [stats].[GC_NAM_GatheredConstruct_Name] [NAM]
        ON
            [NAM].GC_NAM_GC_ID = v.GC_NAM_GC_ID
        AND
            [NAM].GC_NAM_GatheredConstruct_Name = v.GC_NAM_GatheredConstruct_Name
        WHERE
            v.GC_NAM_Version = @currentVersion;
        INSERT INTO [stats].[GC_NAM_GatheredConstruct_Name] (
            GC_NAM_GC_ID,
            Metadata_GC_NAM,
            GC_NAM_GatheredConstruct_Name
        )
        SELECT
            GC_NAM_GC_ID,
            Metadata_GC_NAM,
            GC_NAM_GatheredConstruct_Name
        FROM
            @GC_NAM_GatheredConstruct_Name
        WHERE
            GC_NAM_Version = @currentVersion
        AND
            GC_NAM_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_CAP_GatheredConstruct_Capsule instead of INSERT trigger on GC_CAP_GatheredConstruct_Capsule
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_CAP_GatheredConstruct_Capsule', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_CAP_GatheredConstruct_Capsule];
GO
CREATE TRIGGER [stats].[it_GC_CAP_GatheredConstruct_Capsule] ON [stats].[GC_CAP_GatheredConstruct_Capsule]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_CAP_GatheredConstruct_Capsule TABLE (
        GC_CAP_GC_ID int not null,
        Metadata_GC_CAP int not null,
        GC_CAP_GatheredConstruct_Capsule nvarchar(128) not null,
        GC_CAP_Version bigint not null,
        GC_CAP_StatementType char(1) not null,
        primary key(
            GC_CAP_Version,
            GC_CAP_GC_ID
        )
    );
    INSERT INTO @GC_CAP_GatheredConstruct_Capsule
    SELECT
        i.GC_CAP_GC_ID,
        i.Metadata_GC_CAP,
        i.GC_CAP_GatheredConstruct_Capsule,
        ROW_NUMBER() OVER (
            PARTITION BY
                i.GC_CAP_GC_ID
            ORDER BY
                (SELECT 1) ASC -- some undefined order
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = 1,
        @currentVersion = 0
    FROM
        @GC_CAP_GatheredConstruct_Capsule;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_CAP_StatementType =
                CASE
                    WHEN [CAP].GC_CAP_GC_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_CAP_GatheredConstruct_Capsule v
        LEFT JOIN
            [stats].[GC_CAP_GatheredConstruct_Capsule] [CAP]
        ON
            [CAP].GC_CAP_GC_ID = v.GC_CAP_GC_ID
        AND
            [CAP].GC_CAP_GatheredConstruct_Capsule = v.GC_CAP_GatheredConstruct_Capsule
        WHERE
            v.GC_CAP_Version = @currentVersion;
        INSERT INTO [stats].[GC_CAP_GatheredConstruct_Capsule] (
            GC_CAP_GC_ID,
            Metadata_GC_CAP,
            GC_CAP_GatheredConstruct_Capsule
        )
        SELECT
            GC_CAP_GC_ID,
            Metadata_GC_CAP,
            GC_CAP_GatheredConstruct_Capsule
        FROM
            @GC_CAP_GatheredConstruct_Capsule
        WHERE
            GC_CAP_Version = @currentVersion
        AND
            GC_CAP_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_TYP_GatheredConstruct_Type instead of INSERT trigger on GC_TYP_GatheredConstruct_Type
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_TYP_GatheredConstruct_Type', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_TYP_GatheredConstruct_Type];
GO
CREATE TRIGGER [stats].[it_GC_TYP_GatheredConstruct_Type] ON [stats].[GC_TYP_GatheredConstruct_Type]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_TYP_GatheredConstruct_Type TABLE (
        GC_TYP_GC_ID int not null,
        Metadata_GC_TYP int not null,
        GC_TYP_TYP_ID char(1) not null, 
        GC_TYP_Version bigint not null,
        GC_TYP_StatementType char(1) not null,
        primary key(
            GC_TYP_Version,
            GC_TYP_GC_ID
        )
    );
    INSERT INTO @GC_TYP_GatheredConstruct_Type
    SELECT
        i.GC_TYP_GC_ID,
        i.Metadata_GC_TYP,
        i.GC_TYP_TYP_ID,
        ROW_NUMBER() OVER (
            PARTITION BY
                i.GC_TYP_GC_ID
            ORDER BY
                (SELECT 1) ASC -- some undefined order
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = 1,
        @currentVersion = 0
    FROM
        @GC_TYP_GatheredConstruct_Type;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_TYP_StatementType =
                CASE
                    WHEN [TYP].GC_TYP_GC_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_TYP_GatheredConstruct_Type v
        LEFT JOIN
            [stats].[GC_TYP_GatheredConstruct_Type] [TYP]
        ON
            [TYP].GC_TYP_GC_ID = v.GC_TYP_GC_ID
        AND
            [TYP].GC_TYP_TYP_ID = v.GC_TYP_TYP_ID
        WHERE
            v.GC_TYP_Version = @currentVersion;
        INSERT INTO [stats].[GC_TYP_GatheredConstruct_Type] (
            GC_TYP_GC_ID,
            Metadata_GC_TYP,
            GC_TYP_TYP_ID
        )
        SELECT
            GC_TYP_GC_ID,
            Metadata_GC_TYP,
            GC_TYP_TYP_ID
        FROM
            @GC_TYP_GatheredConstruct_Type
        WHERE
            GC_TYP_Version = @currentVersion
        AND
            GC_TYP_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_ROC_GatheredConstruct_RowCount instead of INSERT trigger on GC_ROC_GatheredConstruct_RowCount
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_ROC_GatheredConstruct_RowCount', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_ROC_GatheredConstruct_RowCount];
GO
CREATE TRIGGER [stats].[it_GC_ROC_GatheredConstruct_RowCount] ON [stats].[GC_ROC_GatheredConstruct_RowCount]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_ROC_GatheredConstruct_RowCount TABLE (
        GC_ROC_GC_ID int not null,
        Metadata_GC_ROC int not null,
        GC_ROC_ChangedAt datetime not null,
        GC_ROC_GatheredConstruct_RowCount bigint not null,
        GC_ROC_Version bigint not null,
        GC_ROC_StatementType char(1) not null,
        primary key(
            GC_ROC_Version,
            GC_ROC_GC_ID
        )
    );
    INSERT INTO @GC_ROC_GatheredConstruct_RowCount
    SELECT
        i.GC_ROC_GC_ID,
        i.Metadata_GC_ROC,
        i.GC_ROC_ChangedAt,
        i.GC_ROC_GatheredConstruct_RowCount,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_ROC_GC_ID
            ORDER BY
                i.GC_ROC_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_ROC_Version), 
        @currentVersion = 0
    FROM
        @GC_ROC_GatheredConstruct_RowCount;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_ROC_StatementType =
                CASE
                    WHEN [ROC].GC_ROC_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_ROC_GatheredConstruct_RowCount]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_ROC_GatheredConstruct_RowCount = (
                                SELECT TOP 1
                                    pre.GC_ROC_GatheredConstruct_RowCount
                                FROM
                                    [stats].[GC_ROC_GatheredConstruct_RowCount] pre
                                WHERE
                                    pre.GC_ROC_GC_ID = v.GC_ROC_GC_ID
                                AND
                                    pre.GC_ROC_ChangedAt < v.GC_ROC_ChangedAt
                                ORDER BY
                                    pre.GC_ROC_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_ROC_GatheredConstruct_RowCount = (
                                SELECT TOP 1
                                    fol.GC_ROC_GatheredConstruct_RowCount
                                FROM
                                    [stats].[GC_ROC_GatheredConstruct_RowCount] fol
                                WHERE
                                    fol.GC_ROC_GC_ID = v.GC_ROC_GC_ID
                                AND
                                    fol.GC_ROC_ChangedAt > v.GC_ROC_ChangedAt
                                ORDER BY
                                    fol.GC_ROC_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_ROC_GatheredConstruct_RowCount v
        LEFT JOIN
            [stats].[GC_ROC_GatheredConstruct_RowCount] [ROC]
        ON
            [ROC].GC_ROC_GC_ID = v.GC_ROC_GC_ID
        AND
            [ROC].GC_ROC_ChangedAt = v.GC_ROC_ChangedAt
        AND
            [ROC].GC_ROC_GatheredConstruct_RowCount = v.GC_ROC_GatheredConstruct_RowCount
        WHERE
            v.GC_ROC_Version = @currentVersion;
        INSERT INTO [stats].[GC_ROC_GatheredConstruct_RowCount] (
            GC_ROC_GC_ID,
            Metadata_GC_ROC,
            GC_ROC_ChangedAt,
            GC_ROC_GatheredConstruct_RowCount
        )
        SELECT
            GC_ROC_GC_ID,
            Metadata_GC_ROC,
            GC_ROC_ChangedAt,
            GC_ROC_GatheredConstruct_RowCount
        FROM
            @GC_ROC_GatheredConstruct_RowCount
        WHERE
            GC_ROC_Version = @currentVersion
        AND
            GC_ROC_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_RGR_GatheredConstruct_RowGrowth instead of INSERT trigger on GC_RGR_GatheredConstruct_RowGrowth
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_RGR_GatheredConstruct_RowGrowth', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_RGR_GatheredConstruct_RowGrowth];
GO
CREATE TRIGGER [stats].[it_GC_RGR_GatheredConstruct_RowGrowth] ON [stats].[GC_RGR_GatheredConstruct_RowGrowth]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_RGR_GatheredConstruct_RowGrowth TABLE (
        GC_RGR_GC_ID int not null,
        Metadata_GC_RGR int not null,
        GC_RGR_ChangedAt datetime not null,
        GC_RGR_GatheredConstruct_RowGrowth int not null,
        GC_RGR_Version bigint not null,
        GC_RGR_StatementType char(1) not null,
        primary key(
            GC_RGR_Version,
            GC_RGR_GC_ID
        )
    );
    INSERT INTO @GC_RGR_GatheredConstruct_RowGrowth
    SELECT
        i.GC_RGR_GC_ID,
        i.Metadata_GC_RGR,
        i.GC_RGR_ChangedAt,
        i.GC_RGR_GatheredConstruct_RowGrowth,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_RGR_GC_ID
            ORDER BY
                i.GC_RGR_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_RGR_Version), 
        @currentVersion = 0
    FROM
        @GC_RGR_GatheredConstruct_RowGrowth;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_RGR_StatementType =
                CASE
                    WHEN [RGR].GC_RGR_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_RGR_GatheredConstruct_RowGrowth]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_RGR_GatheredConstruct_RowGrowth = (
                                SELECT TOP 1
                                    pre.GC_RGR_GatheredConstruct_RowGrowth
                                FROM
                                    [stats].[GC_RGR_GatheredConstruct_RowGrowth] pre
                                WHERE
                                    pre.GC_RGR_GC_ID = v.GC_RGR_GC_ID
                                AND
                                    pre.GC_RGR_ChangedAt < v.GC_RGR_ChangedAt
                                ORDER BY
                                    pre.GC_RGR_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_RGR_GatheredConstruct_RowGrowth = (
                                SELECT TOP 1
                                    fol.GC_RGR_GatheredConstruct_RowGrowth
                                FROM
                                    [stats].[GC_RGR_GatheredConstruct_RowGrowth] fol
                                WHERE
                                    fol.GC_RGR_GC_ID = v.GC_RGR_GC_ID
                                AND
                                    fol.GC_RGR_ChangedAt > v.GC_RGR_ChangedAt
                                ORDER BY
                                    fol.GC_RGR_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_RGR_GatheredConstruct_RowGrowth v
        LEFT JOIN
            [stats].[GC_RGR_GatheredConstruct_RowGrowth] [RGR]
        ON
            [RGR].GC_RGR_GC_ID = v.GC_RGR_GC_ID
        AND
            [RGR].GC_RGR_ChangedAt = v.GC_RGR_ChangedAt
        AND
            [RGR].GC_RGR_GatheredConstruct_RowGrowth = v.GC_RGR_GatheredConstruct_RowGrowth
        WHERE
            v.GC_RGR_Version = @currentVersion;
        INSERT INTO [stats].[GC_RGR_GatheredConstruct_RowGrowth] (
            GC_RGR_GC_ID,
            Metadata_GC_RGR,
            GC_RGR_ChangedAt,
            GC_RGR_GatheredConstruct_RowGrowth
        )
        SELECT
            GC_RGR_GC_ID,
            Metadata_GC_RGR,
            GC_RGR_ChangedAt,
            GC_RGR_GatheredConstruct_RowGrowth
        FROM
            @GC_RGR_GatheredConstruct_RowGrowth
        WHERE
            GC_RGR_Version = @currentVersion
        AND
            GC_RGR_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_RGN_GatheredConstruct_RowGrowthNormal instead of INSERT trigger on GC_RGN_GatheredConstruct_RowGrowthNormal
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_RGN_GatheredConstruct_RowGrowthNormal', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_RGN_GatheredConstruct_RowGrowthNormal];
GO
CREATE TRIGGER [stats].[it_GC_RGN_GatheredConstruct_RowGrowthNormal] ON [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_RGN_GatheredConstruct_RowGrowthNormal TABLE (
        GC_RGN_GC_ID int not null,
        Metadata_GC_RGN int not null,
        GC_RGN_ChangedAt datetime not null,
        GC_RGN_GatheredConstruct_RowGrowthNormal int not null,
        GC_RGN_Version bigint not null,
        GC_RGN_StatementType char(1) not null,
        primary key(
            GC_RGN_Version,
            GC_RGN_GC_ID
        )
    );
    INSERT INTO @GC_RGN_GatheredConstruct_RowGrowthNormal
    SELECT
        i.GC_RGN_GC_ID,
        i.Metadata_GC_RGN,
        i.GC_RGN_ChangedAt,
        i.GC_RGN_GatheredConstruct_RowGrowthNormal,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_RGN_GC_ID
            ORDER BY
                i.GC_RGN_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_RGN_Version), 
        @currentVersion = 0
    FROM
        @GC_RGN_GatheredConstruct_RowGrowthNormal;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_RGN_StatementType =
                CASE
                    WHEN [RGN].GC_RGN_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_RGN_GatheredConstruct_RowGrowthNormal]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_RGN_GatheredConstruct_RowGrowthNormal = (
                                SELECT TOP 1
                                    pre.GC_RGN_GatheredConstruct_RowGrowthNormal
                                FROM
                                    [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] pre
                                WHERE
                                    pre.GC_RGN_GC_ID = v.GC_RGN_GC_ID
                                AND
                                    pre.GC_RGN_ChangedAt < v.GC_RGN_ChangedAt
                                ORDER BY
                                    pre.GC_RGN_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_RGN_GatheredConstruct_RowGrowthNormal = (
                                SELECT TOP 1
                                    fol.GC_RGN_GatheredConstruct_RowGrowthNormal
                                FROM
                                    [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] fol
                                WHERE
                                    fol.GC_RGN_GC_ID = v.GC_RGN_GC_ID
                                AND
                                    fol.GC_RGN_ChangedAt > v.GC_RGN_ChangedAt
                                ORDER BY
                                    fol.GC_RGN_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_RGN_GatheredConstruct_RowGrowthNormal v
        LEFT JOIN
            [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] [RGN]
        ON
            [RGN].GC_RGN_GC_ID = v.GC_RGN_GC_ID
        AND
            [RGN].GC_RGN_ChangedAt = v.GC_RGN_ChangedAt
        AND
            [RGN].GC_RGN_GatheredConstruct_RowGrowthNormal = v.GC_RGN_GatheredConstruct_RowGrowthNormal
        WHERE
            v.GC_RGN_Version = @currentVersion;
        INSERT INTO [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] (
            GC_RGN_GC_ID,
            Metadata_GC_RGN,
            GC_RGN_ChangedAt,
            GC_RGN_GatheredConstruct_RowGrowthNormal
        )
        SELECT
            GC_RGN_GC_ID,
            Metadata_GC_RGN,
            GC_RGN_ChangedAt,
            GC_RGN_GatheredConstruct_RowGrowthNormal
        FROM
            @GC_RGN_GatheredConstruct_RowGrowthNormal
        WHERE
            GC_RGN_Version = @currentVersion
        AND
            GC_RGN_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_UMB_GatheredConstruct_UsedMegabytes instead of INSERT trigger on GC_UMB_GatheredConstruct_UsedMegabytes
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_UMB_GatheredConstruct_UsedMegabytes', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_UMB_GatheredConstruct_UsedMegabytes];
GO
CREATE TRIGGER [stats].[it_GC_UMB_GatheredConstruct_UsedMegabytes] ON [stats].[GC_UMB_GatheredConstruct_UsedMegabytes]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_UMB_GatheredConstruct_UsedMegabytes TABLE (
        GC_UMB_GC_ID int not null,
        Metadata_GC_UMB int not null,
        GC_UMB_ChangedAt datetime not null,
        GC_UMB_GatheredConstruct_UsedMegabytes decimal(19,2) not null,
        GC_UMB_Version bigint not null,
        GC_UMB_StatementType char(1) not null,
        primary key(
            GC_UMB_Version,
            GC_UMB_GC_ID
        )
    );
    INSERT INTO @GC_UMB_GatheredConstruct_UsedMegabytes
    SELECT
        i.GC_UMB_GC_ID,
        i.Metadata_GC_UMB,
        i.GC_UMB_ChangedAt,
        i.GC_UMB_GatheredConstruct_UsedMegabytes,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_UMB_GC_ID
            ORDER BY
                i.GC_UMB_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_UMB_Version), 
        @currentVersion = 0
    FROM
        @GC_UMB_GatheredConstruct_UsedMegabytes;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_UMB_StatementType =
                CASE
                    WHEN [UMB].GC_UMB_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_UMB_GatheredConstruct_UsedMegabytes]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_UMB_GatheredConstruct_UsedMegabytes = (
                                SELECT TOP 1
                                    pre.GC_UMB_GatheredConstruct_UsedMegabytes
                                FROM
                                    [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] pre
                                WHERE
                                    pre.GC_UMB_GC_ID = v.GC_UMB_GC_ID
                                AND
                                    pre.GC_UMB_ChangedAt < v.GC_UMB_ChangedAt
                                ORDER BY
                                    pre.GC_UMB_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_UMB_GatheredConstruct_UsedMegabytes = (
                                SELECT TOP 1
                                    fol.GC_UMB_GatheredConstruct_UsedMegabytes
                                FROM
                                    [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] fol
                                WHERE
                                    fol.GC_UMB_GC_ID = v.GC_UMB_GC_ID
                                AND
                                    fol.GC_UMB_ChangedAt > v.GC_UMB_ChangedAt
                                ORDER BY
                                    fol.GC_UMB_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_UMB_GatheredConstruct_UsedMegabytes v
        LEFT JOIN
            [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] [UMB]
        ON
            [UMB].GC_UMB_GC_ID = v.GC_UMB_GC_ID
        AND
            [UMB].GC_UMB_ChangedAt = v.GC_UMB_ChangedAt
        AND
            [UMB].GC_UMB_GatheredConstruct_UsedMegabytes = v.GC_UMB_GatheredConstruct_UsedMegabytes
        WHERE
            v.GC_UMB_Version = @currentVersion;
        INSERT INTO [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] (
            GC_UMB_GC_ID,
            Metadata_GC_UMB,
            GC_UMB_ChangedAt,
            GC_UMB_GatheredConstruct_UsedMegabytes
        )
        SELECT
            GC_UMB_GC_ID,
            Metadata_GC_UMB,
            GC_UMB_ChangedAt,
            GC_UMB_GatheredConstruct_UsedMegabytes
        FROM
            @GC_UMB_GatheredConstruct_UsedMegabytes
        WHERE
            GC_UMB_Version = @currentVersion
        AND
            GC_UMB_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_UGR_GatheredConstruct_UsedGrowth instead of INSERT trigger on GC_UGR_GatheredConstruct_UsedGrowth
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_UGR_GatheredConstruct_UsedGrowth', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_UGR_GatheredConstruct_UsedGrowth];
GO
CREATE TRIGGER [stats].[it_GC_UGR_GatheredConstruct_UsedGrowth] ON [stats].[GC_UGR_GatheredConstruct_UsedGrowth]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_UGR_GatheredConstruct_UsedGrowth TABLE (
        GC_UGR_GC_ID int not null,
        Metadata_GC_UGR int not null,
        GC_UGR_ChangedAt datetime not null,
        GC_UGR_GatheredConstruct_UsedGrowth decimal(19,2) not null,
        GC_UGR_Version bigint not null,
        GC_UGR_StatementType char(1) not null,
        primary key(
            GC_UGR_Version,
            GC_UGR_GC_ID
        )
    );
    INSERT INTO @GC_UGR_GatheredConstruct_UsedGrowth
    SELECT
        i.GC_UGR_GC_ID,
        i.Metadata_GC_UGR,
        i.GC_UGR_ChangedAt,
        i.GC_UGR_GatheredConstruct_UsedGrowth,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_UGR_GC_ID
            ORDER BY
                i.GC_UGR_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_UGR_Version), 
        @currentVersion = 0
    FROM
        @GC_UGR_GatheredConstruct_UsedGrowth;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_UGR_StatementType =
                CASE
                    WHEN [UGR].GC_UGR_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_UGR_GatheredConstruct_UsedGrowth]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_UGR_GatheredConstruct_UsedGrowth = (
                                SELECT TOP 1
                                    pre.GC_UGR_GatheredConstruct_UsedGrowth
                                FROM
                                    [stats].[GC_UGR_GatheredConstruct_UsedGrowth] pre
                                WHERE
                                    pre.GC_UGR_GC_ID = v.GC_UGR_GC_ID
                                AND
                                    pre.GC_UGR_ChangedAt < v.GC_UGR_ChangedAt
                                ORDER BY
                                    pre.GC_UGR_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_UGR_GatheredConstruct_UsedGrowth = (
                                SELECT TOP 1
                                    fol.GC_UGR_GatheredConstruct_UsedGrowth
                                FROM
                                    [stats].[GC_UGR_GatheredConstruct_UsedGrowth] fol
                                WHERE
                                    fol.GC_UGR_GC_ID = v.GC_UGR_GC_ID
                                AND
                                    fol.GC_UGR_ChangedAt > v.GC_UGR_ChangedAt
                                ORDER BY
                                    fol.GC_UGR_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_UGR_GatheredConstruct_UsedGrowth v
        LEFT JOIN
            [stats].[GC_UGR_GatheredConstruct_UsedGrowth] [UGR]
        ON
            [UGR].GC_UGR_GC_ID = v.GC_UGR_GC_ID
        AND
            [UGR].GC_UGR_ChangedAt = v.GC_UGR_ChangedAt
        AND
            [UGR].GC_UGR_GatheredConstruct_UsedGrowth = v.GC_UGR_GatheredConstruct_UsedGrowth
        WHERE
            v.GC_UGR_Version = @currentVersion;
        INSERT INTO [stats].[GC_UGR_GatheredConstruct_UsedGrowth] (
            GC_UGR_GC_ID,
            Metadata_GC_UGR,
            GC_UGR_ChangedAt,
            GC_UGR_GatheredConstruct_UsedGrowth
        )
        SELECT
            GC_UGR_GC_ID,
            Metadata_GC_UGR,
            GC_UGR_ChangedAt,
            GC_UGR_GatheredConstruct_UsedGrowth
        FROM
            @GC_UGR_GatheredConstruct_UsedGrowth
        WHERE
            GC_UGR_Version = @currentVersion
        AND
            GC_UGR_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_UGN_GatheredConstruct_UsedGrowthNormal instead of INSERT trigger on GC_UGN_GatheredConstruct_UsedGrowthNormal
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_UGN_GatheredConstruct_UsedGrowthNormal', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_UGN_GatheredConstruct_UsedGrowthNormal];
GO
CREATE TRIGGER [stats].[it_GC_UGN_GatheredConstruct_UsedGrowthNormal] ON [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_UGN_GatheredConstruct_UsedGrowthNormal TABLE (
        GC_UGN_GC_ID int not null,
        Metadata_GC_UGN int not null,
        GC_UGN_ChangedAt datetime not null,
        GC_UGN_GatheredConstruct_UsedGrowthNormal decimal(19,2) not null,
        GC_UGN_Version bigint not null,
        GC_UGN_StatementType char(1) not null,
        primary key(
            GC_UGN_Version,
            GC_UGN_GC_ID
        )
    );
    INSERT INTO @GC_UGN_GatheredConstruct_UsedGrowthNormal
    SELECT
        i.GC_UGN_GC_ID,
        i.Metadata_GC_UGN,
        i.GC_UGN_ChangedAt,
        i.GC_UGN_GatheredConstruct_UsedGrowthNormal,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_UGN_GC_ID
            ORDER BY
                i.GC_UGN_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_UGN_Version), 
        @currentVersion = 0
    FROM
        @GC_UGN_GatheredConstruct_UsedGrowthNormal;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_UGN_StatementType =
                CASE
                    WHEN [UGN].GC_UGN_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_UGN_GatheredConstruct_UsedGrowthNormal]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_UGN_GatheredConstruct_UsedGrowthNormal = (
                                SELECT TOP 1
                                    pre.GC_UGN_GatheredConstruct_UsedGrowthNormal
                                FROM
                                    [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] pre
                                WHERE
                                    pre.GC_UGN_GC_ID = v.GC_UGN_GC_ID
                                AND
                                    pre.GC_UGN_ChangedAt < v.GC_UGN_ChangedAt
                                ORDER BY
                                    pre.GC_UGN_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_UGN_GatheredConstruct_UsedGrowthNormal = (
                                SELECT TOP 1
                                    fol.GC_UGN_GatheredConstruct_UsedGrowthNormal
                                FROM
                                    [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] fol
                                WHERE
                                    fol.GC_UGN_GC_ID = v.GC_UGN_GC_ID
                                AND
                                    fol.GC_UGN_ChangedAt > v.GC_UGN_ChangedAt
                                ORDER BY
                                    fol.GC_UGN_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_UGN_GatheredConstruct_UsedGrowthNormal v
        LEFT JOIN
            [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] [UGN]
        ON
            [UGN].GC_UGN_GC_ID = v.GC_UGN_GC_ID
        AND
            [UGN].GC_UGN_ChangedAt = v.GC_UGN_ChangedAt
        AND
            [UGN].GC_UGN_GatheredConstruct_UsedGrowthNormal = v.GC_UGN_GatheredConstruct_UsedGrowthNormal
        WHERE
            v.GC_UGN_Version = @currentVersion;
        INSERT INTO [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] (
            GC_UGN_GC_ID,
            Metadata_GC_UGN,
            GC_UGN_ChangedAt,
            GC_UGN_GatheredConstruct_UsedGrowthNormal
        )
        SELECT
            GC_UGN_GC_ID,
            Metadata_GC_UGN,
            GC_UGN_ChangedAt,
            GC_UGN_GatheredConstruct_UsedGrowthNormal
        FROM
            @GC_UGN_GatheredConstruct_UsedGrowthNormal
        WHERE
            GC_UGN_Version = @currentVersion
        AND
            GC_UGN_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_AMB_GatheredConstruct_AllocatedMegabytes instead of INSERT trigger on GC_AMB_GatheredConstruct_AllocatedMegabytes
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_AMB_GatheredConstruct_AllocatedMegabytes', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_AMB_GatheredConstruct_AllocatedMegabytes];
GO
CREATE TRIGGER [stats].[it_GC_AMB_GatheredConstruct_AllocatedMegabytes] ON [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_AMB_GatheredConstruct_AllocatedMegabytes TABLE (
        GC_AMB_GC_ID int not null,
        Metadata_GC_AMB int not null,
        GC_AMB_ChangedAt datetime not null,
        GC_AMB_GatheredConstruct_AllocatedMegabytes decimal(19,2) not null,
        GC_AMB_Version bigint not null,
        GC_AMB_StatementType char(1) not null,
        primary key(
            GC_AMB_Version,
            GC_AMB_GC_ID
        )
    );
    INSERT INTO @GC_AMB_GatheredConstruct_AllocatedMegabytes
    SELECT
        i.GC_AMB_GC_ID,
        i.Metadata_GC_AMB,
        i.GC_AMB_ChangedAt,
        i.GC_AMB_GatheredConstruct_AllocatedMegabytes,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_AMB_GC_ID
            ORDER BY
                i.GC_AMB_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_AMB_Version), 
        @currentVersion = 0
    FROM
        @GC_AMB_GatheredConstruct_AllocatedMegabytes;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_AMB_StatementType =
                CASE
                    WHEN [AMB].GC_AMB_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_AMB_GatheredConstruct_AllocatedMegabytes]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_AMB_GatheredConstruct_AllocatedMegabytes = (
                                SELECT TOP 1
                                    pre.GC_AMB_GatheredConstruct_AllocatedMegabytes
                                FROM
                                    [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] pre
                                WHERE
                                    pre.GC_AMB_GC_ID = v.GC_AMB_GC_ID
                                AND
                                    pre.GC_AMB_ChangedAt < v.GC_AMB_ChangedAt
                                ORDER BY
                                    pre.GC_AMB_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_AMB_GatheredConstruct_AllocatedMegabytes = (
                                SELECT TOP 1
                                    fol.GC_AMB_GatheredConstruct_AllocatedMegabytes
                                FROM
                                    [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] fol
                                WHERE
                                    fol.GC_AMB_GC_ID = v.GC_AMB_GC_ID
                                AND
                                    fol.GC_AMB_ChangedAt > v.GC_AMB_ChangedAt
                                ORDER BY
                                    fol.GC_AMB_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_AMB_GatheredConstruct_AllocatedMegabytes v
        LEFT JOIN
            [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] [AMB]
        ON
            [AMB].GC_AMB_GC_ID = v.GC_AMB_GC_ID
        AND
            [AMB].GC_AMB_ChangedAt = v.GC_AMB_ChangedAt
        AND
            [AMB].GC_AMB_GatheredConstruct_AllocatedMegabytes = v.GC_AMB_GatheredConstruct_AllocatedMegabytes
        WHERE
            v.GC_AMB_Version = @currentVersion;
        INSERT INTO [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] (
            GC_AMB_GC_ID,
            Metadata_GC_AMB,
            GC_AMB_ChangedAt,
            GC_AMB_GatheredConstruct_AllocatedMegabytes
        )
        SELECT
            GC_AMB_GC_ID,
            Metadata_GC_AMB,
            GC_AMB_ChangedAt,
            GC_AMB_GatheredConstruct_AllocatedMegabytes
        FROM
            @GC_AMB_GatheredConstruct_AllocatedMegabytes
        WHERE
            GC_AMB_Version = @currentVersion
        AND
            GC_AMB_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_AGR_GatheredConstruct_AllocatedGrowth instead of INSERT trigger on GC_AGR_GatheredConstruct_AllocatedGrowth
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_AGR_GatheredConstruct_AllocatedGrowth', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_AGR_GatheredConstruct_AllocatedGrowth];
GO
CREATE TRIGGER [stats].[it_GC_AGR_GatheredConstruct_AllocatedGrowth] ON [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_AGR_GatheredConstruct_AllocatedGrowth TABLE (
        GC_AGR_GC_ID int not null,
        Metadata_GC_AGR int not null,
        GC_AGR_ChangedAt datetime not null,
        GC_AGR_GatheredConstruct_AllocatedGrowth decimal(19,2) not null,
        GC_AGR_Version bigint not null,
        GC_AGR_StatementType char(1) not null,
        primary key(
            GC_AGR_Version,
            GC_AGR_GC_ID
        )
    );
    INSERT INTO @GC_AGR_GatheredConstruct_AllocatedGrowth
    SELECT
        i.GC_AGR_GC_ID,
        i.Metadata_GC_AGR,
        i.GC_AGR_ChangedAt,
        i.GC_AGR_GatheredConstruct_AllocatedGrowth,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_AGR_GC_ID
            ORDER BY
                i.GC_AGR_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_AGR_Version), 
        @currentVersion = 0
    FROM
        @GC_AGR_GatheredConstruct_AllocatedGrowth;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_AGR_StatementType =
                CASE
                    WHEN [AGR].GC_AGR_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_AGR_GatheredConstruct_AllocatedGrowth]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_AGR_GatheredConstruct_AllocatedGrowth = (
                                SELECT TOP 1
                                    pre.GC_AGR_GatheredConstruct_AllocatedGrowth
                                FROM
                                    [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] pre
                                WHERE
                                    pre.GC_AGR_GC_ID = v.GC_AGR_GC_ID
                                AND
                                    pre.GC_AGR_ChangedAt < v.GC_AGR_ChangedAt
                                ORDER BY
                                    pre.GC_AGR_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_AGR_GatheredConstruct_AllocatedGrowth = (
                                SELECT TOP 1
                                    fol.GC_AGR_GatheredConstruct_AllocatedGrowth
                                FROM
                                    [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] fol
                                WHERE
                                    fol.GC_AGR_GC_ID = v.GC_AGR_GC_ID
                                AND
                                    fol.GC_AGR_ChangedAt > v.GC_AGR_ChangedAt
                                ORDER BY
                                    fol.GC_AGR_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_AGR_GatheredConstruct_AllocatedGrowth v
        LEFT JOIN
            [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] [AGR]
        ON
            [AGR].GC_AGR_GC_ID = v.GC_AGR_GC_ID
        AND
            [AGR].GC_AGR_ChangedAt = v.GC_AGR_ChangedAt
        AND
            [AGR].GC_AGR_GatheredConstruct_AllocatedGrowth = v.GC_AGR_GatheredConstruct_AllocatedGrowth
        WHERE
            v.GC_AGR_Version = @currentVersion;
        INSERT INTO [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] (
            GC_AGR_GC_ID,
            Metadata_GC_AGR,
            GC_AGR_ChangedAt,
            GC_AGR_GatheredConstruct_AllocatedGrowth
        )
        SELECT
            GC_AGR_GC_ID,
            Metadata_GC_AGR,
            GC_AGR_ChangedAt,
            GC_AGR_GatheredConstruct_AllocatedGrowth
        FROM
            @GC_AGR_GatheredConstruct_AllocatedGrowth
        WHERE
            GC_AGR_Version = @currentVersion
        AND
            GC_AGR_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_AGN_GatheredConstruct_AllocatedGrowthNormal instead of INSERT trigger on GC_AGN_GatheredConstruct_AllocatedGrowthNormal
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_AGN_GatheredConstruct_AllocatedGrowthNormal', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_AGN_GatheredConstruct_AllocatedGrowthNormal];
GO
CREATE TRIGGER [stats].[it_GC_AGN_GatheredConstruct_AllocatedGrowthNormal] ON [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_AGN_GatheredConstruct_AllocatedGrowthNormal TABLE (
        GC_AGN_GC_ID int not null,
        Metadata_GC_AGN int not null,
        GC_AGN_ChangedAt datetime not null,
        GC_AGN_GatheredConstruct_AllocatedGrowthNormal decimal(19,2) not null,
        GC_AGN_Version bigint not null,
        GC_AGN_StatementType char(1) not null,
        primary key(
            GC_AGN_Version,
            GC_AGN_GC_ID
        )
    );
    INSERT INTO @GC_AGN_GatheredConstruct_AllocatedGrowthNormal
    SELECT
        i.GC_AGN_GC_ID,
        i.Metadata_GC_AGN,
        i.GC_AGN_ChangedAt,
        i.GC_AGN_GatheredConstruct_AllocatedGrowthNormal,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_AGN_GC_ID
            ORDER BY
                i.GC_AGN_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_AGN_Version), 
        @currentVersion = 0
    FROM
        @GC_AGN_GatheredConstruct_AllocatedGrowthNormal;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_AGN_StatementType =
                CASE
                    WHEN [AGN].GC_AGN_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_AGN_GatheredConstruct_AllocatedGrowthNormal]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_AGN_GatheredConstruct_AllocatedGrowthNormal = (
                                SELECT TOP 1
                                    pre.GC_AGN_GatheredConstruct_AllocatedGrowthNormal
                                FROM
                                    [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] pre
                                WHERE
                                    pre.GC_AGN_GC_ID = v.GC_AGN_GC_ID
                                AND
                                    pre.GC_AGN_ChangedAt < v.GC_AGN_ChangedAt
                                ORDER BY
                                    pre.GC_AGN_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_AGN_GatheredConstruct_AllocatedGrowthNormal = (
                                SELECT TOP 1
                                    fol.GC_AGN_GatheredConstruct_AllocatedGrowthNormal
                                FROM
                                    [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] fol
                                WHERE
                                    fol.GC_AGN_GC_ID = v.GC_AGN_GC_ID
                                AND
                                    fol.GC_AGN_ChangedAt > v.GC_AGN_ChangedAt
                                ORDER BY
                                    fol.GC_AGN_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_AGN_GatheredConstruct_AllocatedGrowthNormal v
        LEFT JOIN
            [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] [AGN]
        ON
            [AGN].GC_AGN_GC_ID = v.GC_AGN_GC_ID
        AND
            [AGN].GC_AGN_ChangedAt = v.GC_AGN_ChangedAt
        AND
            [AGN].GC_AGN_GatheredConstruct_AllocatedGrowthNormal = v.GC_AGN_GatheredConstruct_AllocatedGrowthNormal
        WHERE
            v.GC_AGN_Version = @currentVersion;
        INSERT INTO [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] (
            GC_AGN_GC_ID,
            Metadata_GC_AGN,
            GC_AGN_ChangedAt,
            GC_AGN_GatheredConstruct_AllocatedGrowthNormal
        )
        SELECT
            GC_AGN_GC_ID,
            Metadata_GC_AGN,
            GC_AGN_ChangedAt,
            GC_AGN_GatheredConstruct_AllocatedGrowthNormal
        FROM
            @GC_AGN_GatheredConstruct_AllocatedGrowthNormal
        WHERE
            GC_AGN_Version = @currentVersion
        AND
            GC_AGN_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_AGI_GatheredConstruct_AllocatedGrowthInterval instead of INSERT trigger on GC_AGI_GatheredConstruct_AllocatedGrowthInterval
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_AGI_GatheredConstruct_AllocatedGrowthInterval', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_AGI_GatheredConstruct_AllocatedGrowthInterval];
GO
CREATE TRIGGER [stats].[it_GC_AGI_GatheredConstruct_AllocatedGrowthInterval] ON [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_AGI_GatheredConstruct_AllocatedGrowthInterval TABLE (
        GC_AGI_GC_ID int not null,
        Metadata_GC_AGI int not null,
        GC_AGI_ChangedAt datetime not null,
        GC_AGI_GatheredConstruct_AllocatedGrowthInterval bigint not null,
        GC_AGI_Version bigint not null,
        GC_AGI_StatementType char(1) not null,
        primary key(
            GC_AGI_Version,
            GC_AGI_GC_ID
        )
    );
    INSERT INTO @GC_AGI_GatheredConstruct_AllocatedGrowthInterval
    SELECT
        i.GC_AGI_GC_ID,
        i.Metadata_GC_AGI,
        i.GC_AGI_ChangedAt,
        i.GC_AGI_GatheredConstruct_AllocatedGrowthInterval,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_AGI_GC_ID
            ORDER BY
                i.GC_AGI_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_AGI_Version), 
        @currentVersion = 0
    FROM
        @GC_AGI_GatheredConstruct_AllocatedGrowthInterval;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_AGI_StatementType =
                CASE
                    WHEN [AGI].GC_AGI_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_AGI_GatheredConstruct_AllocatedGrowthInterval]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_AGI_GatheredConstruct_AllocatedGrowthInterval = (
                                SELECT TOP 1
                                    pre.GC_AGI_GatheredConstruct_AllocatedGrowthInterval
                                FROM
                                    [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] pre
                                WHERE
                                    pre.GC_AGI_GC_ID = v.GC_AGI_GC_ID
                                AND
                                    pre.GC_AGI_ChangedAt < v.GC_AGI_ChangedAt
                                ORDER BY
                                    pre.GC_AGI_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_AGI_GatheredConstruct_AllocatedGrowthInterval = (
                                SELECT TOP 1
                                    fol.GC_AGI_GatheredConstruct_AllocatedGrowthInterval
                                FROM
                                    [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] fol
                                WHERE
                                    fol.GC_AGI_GC_ID = v.GC_AGI_GC_ID
                                AND
                                    fol.GC_AGI_ChangedAt > v.GC_AGI_ChangedAt
                                ORDER BY
                                    fol.GC_AGI_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_AGI_GatheredConstruct_AllocatedGrowthInterval v
        LEFT JOIN
            [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] [AGI]
        ON
            [AGI].GC_AGI_GC_ID = v.GC_AGI_GC_ID
        AND
            [AGI].GC_AGI_ChangedAt = v.GC_AGI_ChangedAt
        AND
            [AGI].GC_AGI_GatheredConstruct_AllocatedGrowthInterval = v.GC_AGI_GatheredConstruct_AllocatedGrowthInterval
        WHERE
            v.GC_AGI_Version = @currentVersion;
        INSERT INTO [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] (
            GC_AGI_GC_ID,
            Metadata_GC_AGI,
            GC_AGI_ChangedAt,
            GC_AGI_GatheredConstruct_AllocatedGrowthInterval
        )
        SELECT
            GC_AGI_GC_ID,
            Metadata_GC_AGI,
            GC_AGI_ChangedAt,
            GC_AGI_GatheredConstruct_AllocatedGrowthInterval
        FROM
            @GC_AGI_GatheredConstruct_AllocatedGrowthInterval
        WHERE
            GC_AGI_Version = @currentVersion
        AND
            GC_AGI_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_UGI_GatheredConstruct_UsedGrowthInterval instead of INSERT trigger on GC_UGI_GatheredConstruct_UsedGrowthInterval
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_UGI_GatheredConstruct_UsedGrowthInterval', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_UGI_GatheredConstruct_UsedGrowthInterval];
GO
CREATE TRIGGER [stats].[it_GC_UGI_GatheredConstruct_UsedGrowthInterval] ON [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_UGI_GatheredConstruct_UsedGrowthInterval TABLE (
        GC_UGI_GC_ID int not null,
        Metadata_GC_UGI int not null,
        GC_UGI_ChangedAt datetime not null,
        GC_UGI_GatheredConstruct_UsedGrowthInterval bigint not null,
        GC_UGI_Version bigint not null,
        GC_UGI_StatementType char(1) not null,
        primary key(
            GC_UGI_Version,
            GC_UGI_GC_ID
        )
    );
    INSERT INTO @GC_UGI_GatheredConstruct_UsedGrowthInterval
    SELECT
        i.GC_UGI_GC_ID,
        i.Metadata_GC_UGI,
        i.GC_UGI_ChangedAt,
        i.GC_UGI_GatheredConstruct_UsedGrowthInterval,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_UGI_GC_ID
            ORDER BY
                i.GC_UGI_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_UGI_Version), 
        @currentVersion = 0
    FROM
        @GC_UGI_GatheredConstruct_UsedGrowthInterval;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_UGI_StatementType =
                CASE
                    WHEN [UGI].GC_UGI_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_UGI_GatheredConstruct_UsedGrowthInterval]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_UGI_GatheredConstruct_UsedGrowthInterval = (
                                SELECT TOP 1
                                    pre.GC_UGI_GatheredConstruct_UsedGrowthInterval
                                FROM
                                    [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] pre
                                WHERE
                                    pre.GC_UGI_GC_ID = v.GC_UGI_GC_ID
                                AND
                                    pre.GC_UGI_ChangedAt < v.GC_UGI_ChangedAt
                                ORDER BY
                                    pre.GC_UGI_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_UGI_GatheredConstruct_UsedGrowthInterval = (
                                SELECT TOP 1
                                    fol.GC_UGI_GatheredConstruct_UsedGrowthInterval
                                FROM
                                    [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] fol
                                WHERE
                                    fol.GC_UGI_GC_ID = v.GC_UGI_GC_ID
                                AND
                                    fol.GC_UGI_ChangedAt > v.GC_UGI_ChangedAt
                                ORDER BY
                                    fol.GC_UGI_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_UGI_GatheredConstruct_UsedGrowthInterval v
        LEFT JOIN
            [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] [UGI]
        ON
            [UGI].GC_UGI_GC_ID = v.GC_UGI_GC_ID
        AND
            [UGI].GC_UGI_ChangedAt = v.GC_UGI_ChangedAt
        AND
            [UGI].GC_UGI_GatheredConstruct_UsedGrowthInterval = v.GC_UGI_GatheredConstruct_UsedGrowthInterval
        WHERE
            v.GC_UGI_Version = @currentVersion;
        INSERT INTO [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] (
            GC_UGI_GC_ID,
            Metadata_GC_UGI,
            GC_UGI_ChangedAt,
            GC_UGI_GatheredConstruct_UsedGrowthInterval
        )
        SELECT
            GC_UGI_GC_ID,
            Metadata_GC_UGI,
            GC_UGI_ChangedAt,
            GC_UGI_GatheredConstruct_UsedGrowthInterval
        FROM
            @GC_UGI_GatheredConstruct_UsedGrowthInterval
        WHERE
            GC_UGI_Version = @currentVersion
        AND
            GC_UGI_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_RGI_GatheredConstruct_RowGrowthInterval instead of INSERT trigger on GC_RGI_GatheredConstruct_RowGrowthInterval
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_RGI_GatheredConstruct_RowGrowthInterval', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_RGI_GatheredConstruct_RowGrowthInterval];
GO
CREATE TRIGGER [stats].[it_GC_RGI_GatheredConstruct_RowGrowthInterval] ON [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_RGI_GatheredConstruct_RowGrowthInterval TABLE (
        GC_RGI_GC_ID int not null,
        Metadata_GC_RGI int not null,
        GC_RGI_ChangedAt datetime not null,
        GC_RGI_GatheredConstruct_RowGrowthInterval bigint not null,
        GC_RGI_Version bigint not null,
        GC_RGI_StatementType char(1) not null,
        primary key(
            GC_RGI_Version,
            GC_RGI_GC_ID
        )
    );
    INSERT INTO @GC_RGI_GatheredConstruct_RowGrowthInterval
    SELECT
        i.GC_RGI_GC_ID,
        i.Metadata_GC_RGI,
        i.GC_RGI_ChangedAt,
        i.GC_RGI_GatheredConstruct_RowGrowthInterval,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_RGI_GC_ID
            ORDER BY
                i.GC_RGI_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_RGI_Version), 
        @currentVersion = 0
    FROM
        @GC_RGI_GatheredConstruct_RowGrowthInterval;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_RGI_StatementType =
                CASE
                    WHEN [RGI].GC_RGI_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_RGI_GatheredConstruct_RowGrowthInterval]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_RGI_GatheredConstruct_RowGrowthInterval = (
                                SELECT TOP 1
                                    pre.GC_RGI_GatheredConstruct_RowGrowthInterval
                                FROM
                                    [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] pre
                                WHERE
                                    pre.GC_RGI_GC_ID = v.GC_RGI_GC_ID
                                AND
                                    pre.GC_RGI_ChangedAt < v.GC_RGI_ChangedAt
                                ORDER BY
                                    pre.GC_RGI_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_RGI_GatheredConstruct_RowGrowthInterval = (
                                SELECT TOP 1
                                    fol.GC_RGI_GatheredConstruct_RowGrowthInterval
                                FROM
                                    [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] fol
                                WHERE
                                    fol.GC_RGI_GC_ID = v.GC_RGI_GC_ID
                                AND
                                    fol.GC_RGI_ChangedAt > v.GC_RGI_ChangedAt
                                ORDER BY
                                    fol.GC_RGI_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_RGI_GatheredConstruct_RowGrowthInterval v
        LEFT JOIN
            [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] [RGI]
        ON
            [RGI].GC_RGI_GC_ID = v.GC_RGI_GC_ID
        AND
            [RGI].GC_RGI_ChangedAt = v.GC_RGI_ChangedAt
        AND
            [RGI].GC_RGI_GatheredConstruct_RowGrowthInterval = v.GC_RGI_GatheredConstruct_RowGrowthInterval
        WHERE
            v.GC_RGI_Version = @currentVersion;
        INSERT INTO [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] (
            GC_RGI_GC_ID,
            Metadata_GC_RGI,
            GC_RGI_ChangedAt,
            GC_RGI_GatheredConstruct_RowGrowthInterval
        )
        SELECT
            GC_RGI_GC_ID,
            Metadata_GC_RGI,
            GC_RGI_ChangedAt,
            GC_RGI_GatheredConstruct_RowGrowthInterval
        FROM
            @GC_RGI_GatheredConstruct_RowGrowthInterval
        WHERE
            GC_RGI_Version = @currentVersion
        AND
            GC_RGI_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_GC_LGT_GatheredConstruct_LatestGatheringTime instead of INSERT trigger on GC_LGT_GatheredConstruct_LatestGatheringTime
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats.it_GC_LGT_GatheredConstruct_LatestGatheringTime', 'TR') IS NOT NULL
DROP TRIGGER [stats].[it_GC_LGT_GatheredConstruct_LatestGatheringTime];
GO
CREATE TRIGGER [stats].[it_GC_LGT_GatheredConstruct_LatestGatheringTime] ON [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @GC_LGT_GatheredConstruct_LatestGatheringTime TABLE (
        GC_LGT_GC_ID int not null,
        Metadata_GC_LGT int not null,
        GC_LGT_ChangedAt datetime not null,
        GC_LGT_GatheredConstruct_LatestGatheringTime datetime not null,
        GC_LGT_Version bigint not null,
        GC_LGT_StatementType char(1) not null,
        primary key(
            GC_LGT_Version,
            GC_LGT_GC_ID
        )
    );
    INSERT INTO @GC_LGT_GatheredConstruct_LatestGatheringTime
    SELECT
        i.GC_LGT_GC_ID,
        i.Metadata_GC_LGT,
        i.GC_LGT_ChangedAt,
        i.GC_LGT_GatheredConstruct_LatestGatheringTime,
        DENSE_RANK() OVER (
            PARTITION BY
                i.GC_LGT_GC_ID
            ORDER BY
                i.GC_LGT_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(GC_LGT_Version), 
        @currentVersion = 0
    FROM
        @GC_LGT_GatheredConstruct_LatestGatheringTime;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.GC_LGT_StatementType =
                CASE
                    WHEN [LGT].GC_LGT_GC_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [stats].[rfGC_LGT_GatheredConstruct_LatestGatheringTime]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_LGT_GatheredConstruct_LatestGatheringTime = (
                                SELECT TOP 1
                                    pre.GC_LGT_GatheredConstruct_LatestGatheringTime
                                FROM
                                    [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] pre
                                WHERE
                                    pre.GC_LGT_GC_ID = v.GC_LGT_GC_ID
                                AND
                                    pre.GC_LGT_ChangedAt < v.GC_LGT_ChangedAt
                                ORDER BY
                                    pre.GC_LGT_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.GC_LGT_GatheredConstruct_LatestGatheringTime = (
                                SELECT TOP 1
                                    fol.GC_LGT_GatheredConstruct_LatestGatheringTime
                                FROM
                                    [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] fol
                                WHERE
                                    fol.GC_LGT_GC_ID = v.GC_LGT_GC_ID
                                AND
                                    fol.GC_LGT_ChangedAt > v.GC_LGT_ChangedAt
                                ORDER BY
                                    fol.GC_LGT_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @GC_LGT_GatheredConstruct_LatestGatheringTime v
        LEFT JOIN
            [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] [LGT]
        ON
            [LGT].GC_LGT_GC_ID = v.GC_LGT_GC_ID
        AND
            [LGT].GC_LGT_ChangedAt = v.GC_LGT_ChangedAt
        AND
            [LGT].GC_LGT_GatheredConstruct_LatestGatheringTime = v.GC_LGT_GatheredConstruct_LatestGatheringTime
        WHERE
            v.GC_LGT_Version = @currentVersion;
        INSERT INTO [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] (
            GC_LGT_GC_ID,
            Metadata_GC_LGT,
            GC_LGT_ChangedAt,
            GC_LGT_GatheredConstruct_LatestGatheringTime
        )
        SELECT
            GC_LGT_GC_ID,
            Metadata_GC_LGT,
            GC_LGT_ChangedAt,
            GC_LGT_GatheredConstruct_LatestGatheringTime
        FROM
            @GC_LGT_GatheredConstruct_LatestGatheringTime
        WHERE
            GC_LGT_Version = @currentVersion
        AND
            GC_LGT_StatementType in ('N');
    END
END
GO
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lGC_GatheredConstruct instead of INSERT trigger on lGC_GatheredConstruct
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [stats].[it_lGC_GatheredConstruct] ON [stats].[lGC_GatheredConstruct]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @GC TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        GC_ID int not null
    );
    INSERT INTO [stats].[GC_GatheredConstruct] (
        Metadata_GC 
    )
    OUTPUT
        inserted.GC_ID
    INTO
        @GC
    SELECT
        Metadata_GC 
    FROM
        inserted
    WHERE
        inserted.GC_ID is null;
    DECLARE @inserted TABLE (
        GC_ID int not null,
        Metadata_GC int not null,
        GC_NAM_GC_ID int null,
        Metadata_GC_NAM int null,
        GC_NAM_GatheredConstruct_Name nvarchar(128) null,
        GC_CAP_GC_ID int null,
        Metadata_GC_CAP int null,
        GC_CAP_GatheredConstruct_Capsule nvarchar(128) null,
        GC_TYP_GC_ID int null,
        Metadata_GC_TYP int null,
        GC_TYP_TYP_Type varchar(42) null,
        GC_TYP_Metadata_TYP int null,
        GC_TYP_TYP_ID char(1) null,
        GC_ROC_GC_ID int null,
        Metadata_GC_ROC int null,
        GC_ROC_ChangedAt datetime null,
        GC_ROC_GatheredConstruct_RowCount bigint null,
        GC_RGR_GC_ID int null,
        Metadata_GC_RGR int null,
        GC_RGR_ChangedAt datetime null,
        GC_RGR_GatheredConstruct_RowGrowth int null,
        GC_RGN_GC_ID int null,
        Metadata_GC_RGN int null,
        GC_RGN_ChangedAt datetime null,
        GC_RGN_GatheredConstruct_RowGrowthNormal int null,
        GC_UMB_GC_ID int null,
        Metadata_GC_UMB int null,
        GC_UMB_ChangedAt datetime null,
        GC_UMB_GatheredConstruct_UsedMegabytes decimal(19,2) null,
        GC_UGR_GC_ID int null,
        Metadata_GC_UGR int null,
        GC_UGR_ChangedAt datetime null,
        GC_UGR_GatheredConstruct_UsedGrowth decimal(19,2) null,
        GC_UGN_GC_ID int null,
        Metadata_GC_UGN int null,
        GC_UGN_ChangedAt datetime null,
        GC_UGN_GatheredConstruct_UsedGrowthNormal decimal(19,2) null,
        GC_AMB_GC_ID int null,
        Metadata_GC_AMB int null,
        GC_AMB_ChangedAt datetime null,
        GC_AMB_GatheredConstruct_AllocatedMegabytes decimal(19,2) null,
        GC_AGR_GC_ID int null,
        Metadata_GC_AGR int null,
        GC_AGR_ChangedAt datetime null,
        GC_AGR_GatheredConstruct_AllocatedGrowth decimal(19,2) null,
        GC_AGN_GC_ID int null,
        Metadata_GC_AGN int null,
        GC_AGN_ChangedAt datetime null,
        GC_AGN_GatheredConstruct_AllocatedGrowthNormal decimal(19,2) null,
        GC_AGI_GC_ID int null,
        Metadata_GC_AGI int null,
        GC_AGI_ChangedAt datetime null,
        GC_AGI_GatheredConstruct_AllocatedGrowthInterval bigint null,
        GC_UGI_GC_ID int null,
        Metadata_GC_UGI int null,
        GC_UGI_ChangedAt datetime null,
        GC_UGI_GatheredConstruct_UsedGrowthInterval bigint null,
        GC_RGI_GC_ID int null,
        Metadata_GC_RGI int null,
        GC_RGI_ChangedAt datetime null,
        GC_RGI_GatheredConstruct_RowGrowthInterval bigint null,
        GC_LGT_GC_ID int null,
        Metadata_GC_LGT int null,
        GC_LGT_ChangedAt datetime null,
        GC_LGT_GatheredConstruct_LatestGatheringTime datetime null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.GC_ID, a.GC_ID),
        i.Metadata_GC,
        ISNULL(ISNULL(i.GC_NAM_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_NAM, i.Metadata_GC),
        i.GC_NAM_GatheredConstruct_Name,
        ISNULL(ISNULL(i.GC_CAP_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_CAP, i.Metadata_GC),
        i.GC_CAP_GatheredConstruct_Capsule,
        ISNULL(ISNULL(i.GC_TYP_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_TYP, i.Metadata_GC),
        i.GC_TYP_TYP_Type,
        ISNULL(i.GC_TYP_Metadata_TYP, i.Metadata_GC),
        i.GC_TYP_TYP_ID,
        ISNULL(ISNULL(i.GC_ROC_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_ROC, i.Metadata_GC),
        ISNULL(i.GC_ROC_ChangedAt, @now),
        i.GC_ROC_GatheredConstruct_RowCount,
        ISNULL(ISNULL(i.GC_RGR_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_RGR, i.Metadata_GC),
        ISNULL(i.GC_RGR_ChangedAt, @now),
        i.GC_RGR_GatheredConstruct_RowGrowth,
        ISNULL(ISNULL(i.GC_RGN_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_RGN, i.Metadata_GC),
        ISNULL(i.GC_RGN_ChangedAt, @now),
        i.GC_RGN_GatheredConstruct_RowGrowthNormal,
        ISNULL(ISNULL(i.GC_UMB_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_UMB, i.Metadata_GC),
        ISNULL(i.GC_UMB_ChangedAt, @now),
        i.GC_UMB_GatheredConstruct_UsedMegabytes,
        ISNULL(ISNULL(i.GC_UGR_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_UGR, i.Metadata_GC),
        ISNULL(i.GC_UGR_ChangedAt, @now),
        i.GC_UGR_GatheredConstruct_UsedGrowth,
        ISNULL(ISNULL(i.GC_UGN_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_UGN, i.Metadata_GC),
        ISNULL(i.GC_UGN_ChangedAt, @now),
        i.GC_UGN_GatheredConstruct_UsedGrowthNormal,
        ISNULL(ISNULL(i.GC_AMB_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_AMB, i.Metadata_GC),
        ISNULL(i.GC_AMB_ChangedAt, @now),
        i.GC_AMB_GatheredConstruct_AllocatedMegabytes,
        ISNULL(ISNULL(i.GC_AGR_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_AGR, i.Metadata_GC),
        ISNULL(i.GC_AGR_ChangedAt, @now),
        i.GC_AGR_GatheredConstruct_AllocatedGrowth,
        ISNULL(ISNULL(i.GC_AGN_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_AGN, i.Metadata_GC),
        ISNULL(i.GC_AGN_ChangedAt, @now),
        i.GC_AGN_GatheredConstruct_AllocatedGrowthNormal,
        ISNULL(ISNULL(i.GC_AGI_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_AGI, i.Metadata_GC),
        ISNULL(i.GC_AGI_ChangedAt, @now),
        i.GC_AGI_GatheredConstruct_AllocatedGrowthInterval,
        ISNULL(ISNULL(i.GC_UGI_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_UGI, i.Metadata_GC),
        ISNULL(i.GC_UGI_ChangedAt, @now),
        i.GC_UGI_GatheredConstruct_UsedGrowthInterval,
        ISNULL(ISNULL(i.GC_RGI_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_RGI, i.Metadata_GC),
        ISNULL(i.GC_RGI_ChangedAt, @now),
        i.GC_RGI_GatheredConstruct_RowGrowthInterval,
        ISNULL(ISNULL(i.GC_LGT_GC_ID, i.GC_ID), a.GC_ID),
        ISNULL(i.Metadata_GC_LGT, i.Metadata_GC),
        ISNULL(i.GC_LGT_ChangedAt, @now),
        i.GC_LGT_GatheredConstruct_LatestGatheringTime
    FROM (
        SELECT
            GC_ID,
            Metadata_GC,
            GC_NAM_GC_ID,
            Metadata_GC_NAM,
            GC_NAM_GatheredConstruct_Name,
            GC_CAP_GC_ID,
            Metadata_GC_CAP,
            GC_CAP_GatheredConstruct_Capsule,
            GC_TYP_GC_ID,
            Metadata_GC_TYP,
            GC_TYP_TYP_Type,
            GC_TYP_Metadata_TYP,
            GC_TYP_TYP_ID,
            GC_ROC_GC_ID,
            Metadata_GC_ROC,
            GC_ROC_ChangedAt,
            GC_ROC_GatheredConstruct_RowCount,
            GC_RGR_GC_ID,
            Metadata_GC_RGR,
            GC_RGR_ChangedAt,
            GC_RGR_GatheredConstruct_RowGrowth,
            GC_RGN_GC_ID,
            Metadata_GC_RGN,
            GC_RGN_ChangedAt,
            GC_RGN_GatheredConstruct_RowGrowthNormal,
            GC_UMB_GC_ID,
            Metadata_GC_UMB,
            GC_UMB_ChangedAt,
            GC_UMB_GatheredConstruct_UsedMegabytes,
            GC_UGR_GC_ID,
            Metadata_GC_UGR,
            GC_UGR_ChangedAt,
            GC_UGR_GatheredConstruct_UsedGrowth,
            GC_UGN_GC_ID,
            Metadata_GC_UGN,
            GC_UGN_ChangedAt,
            GC_UGN_GatheredConstruct_UsedGrowthNormal,
            GC_AMB_GC_ID,
            Metadata_GC_AMB,
            GC_AMB_ChangedAt,
            GC_AMB_GatheredConstruct_AllocatedMegabytes,
            GC_AGR_GC_ID,
            Metadata_GC_AGR,
            GC_AGR_ChangedAt,
            GC_AGR_GatheredConstruct_AllocatedGrowth,
            GC_AGN_GC_ID,
            Metadata_GC_AGN,
            GC_AGN_ChangedAt,
            GC_AGN_GatheredConstruct_AllocatedGrowthNormal,
            GC_AGI_GC_ID,
            Metadata_GC_AGI,
            GC_AGI_ChangedAt,
            GC_AGI_GatheredConstruct_AllocatedGrowthInterval,
            GC_UGI_GC_ID,
            Metadata_GC_UGI,
            GC_UGI_ChangedAt,
            GC_UGI_GatheredConstruct_UsedGrowthInterval,
            GC_RGI_GC_ID,
            Metadata_GC_RGI,
            GC_RGI_ChangedAt,
            GC_RGI_GatheredConstruct_RowGrowthInterval,
            GC_LGT_GC_ID,
            Metadata_GC_LGT,
            GC_LGT_ChangedAt,
            GC_LGT_GatheredConstruct_LatestGatheringTime,
            ROW_NUMBER() OVER (PARTITION BY GC_ID ORDER BY GC_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @GC a
    ON
        a.Row = i.Row;
    INSERT INTO [stats].[GC_NAM_GatheredConstruct_Name] (
        Metadata_GC_NAM,
        GC_NAM_GC_ID,
        GC_NAM_GatheredConstruct_Name
    )
    SELECT
        i.Metadata_GC_NAM,
        i.GC_NAM_GC_ID,
        i.GC_NAM_GatheredConstruct_Name
    FROM
        @inserted i
    WHERE
        i.GC_NAM_GatheredConstruct_Name is not null;
    INSERT INTO [stats].[GC_CAP_GatheredConstruct_Capsule] (
        Metadata_GC_CAP,
        GC_CAP_GC_ID,
        GC_CAP_GatheredConstruct_Capsule
    )
    SELECT
        i.Metadata_GC_CAP,
        i.GC_CAP_GC_ID,
        i.GC_CAP_GatheredConstruct_Capsule
    FROM
        @inserted i
    WHERE
        i.GC_CAP_GatheredConstruct_Capsule is not null;
    INSERT INTO [stats].[GC_TYP_GatheredConstruct_Type] (
        Metadata_GC_TYP,
        GC_TYP_GC_ID,
        GC_TYP_TYP_ID
    )
    SELECT
        i.Metadata_GC_TYP,
        i.GC_TYP_GC_ID,
        ISNULL(i.GC_TYP_TYP_ID, [kTYP].TYP_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [stats].[TYP_Type] [kTYP]
    ON
        [kTYP].TYP_Type = i.GC_TYP_TYP_Type
    WHERE
        ISNULL(i.GC_TYP_TYP_ID, [kTYP].TYP_ID) is not null;
    INSERT INTO [stats].[GC_ROC_GatheredConstruct_RowCount] (
        Metadata_GC_ROC,
        GC_ROC_GC_ID,
        GC_ROC_ChangedAt,
        GC_ROC_GatheredConstruct_RowCount
    )
    SELECT
        i.Metadata_GC_ROC,
        i.GC_ROC_GC_ID,
        i.GC_ROC_ChangedAt,
        i.GC_ROC_GatheredConstruct_RowCount
    FROM
        @inserted i
    WHERE
        i.GC_ROC_GatheredConstruct_RowCount is not null;
    INSERT INTO [stats].[GC_RGR_GatheredConstruct_RowGrowth] (
        Metadata_GC_RGR,
        GC_RGR_GC_ID,
        GC_RGR_ChangedAt,
        GC_RGR_GatheredConstruct_RowGrowth
    )
    SELECT
        i.Metadata_GC_RGR,
        i.GC_RGR_GC_ID,
        i.GC_RGR_ChangedAt,
        i.GC_RGR_GatheredConstruct_RowGrowth
    FROM
        @inserted i
    WHERE
        i.GC_RGR_GatheredConstruct_RowGrowth is not null;
    INSERT INTO [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] (
        Metadata_GC_RGN,
        GC_RGN_GC_ID,
        GC_RGN_ChangedAt,
        GC_RGN_GatheredConstruct_RowGrowthNormal
    )
    SELECT
        i.Metadata_GC_RGN,
        i.GC_RGN_GC_ID,
        i.GC_RGN_ChangedAt,
        i.GC_RGN_GatheredConstruct_RowGrowthNormal
    FROM
        @inserted i
    WHERE
        i.GC_RGN_GatheredConstruct_RowGrowthNormal is not null;
    INSERT INTO [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] (
        Metadata_GC_UMB,
        GC_UMB_GC_ID,
        GC_UMB_ChangedAt,
        GC_UMB_GatheredConstruct_UsedMegabytes
    )
    SELECT
        i.Metadata_GC_UMB,
        i.GC_UMB_GC_ID,
        i.GC_UMB_ChangedAt,
        i.GC_UMB_GatheredConstruct_UsedMegabytes
    FROM
        @inserted i
    WHERE
        i.GC_UMB_GatheredConstruct_UsedMegabytes is not null;
    INSERT INTO [stats].[GC_UGR_GatheredConstruct_UsedGrowth] (
        Metadata_GC_UGR,
        GC_UGR_GC_ID,
        GC_UGR_ChangedAt,
        GC_UGR_GatheredConstruct_UsedGrowth
    )
    SELECT
        i.Metadata_GC_UGR,
        i.GC_UGR_GC_ID,
        i.GC_UGR_ChangedAt,
        i.GC_UGR_GatheredConstruct_UsedGrowth
    FROM
        @inserted i
    WHERE
        i.GC_UGR_GatheredConstruct_UsedGrowth is not null;
    INSERT INTO [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] (
        Metadata_GC_UGN,
        GC_UGN_GC_ID,
        GC_UGN_ChangedAt,
        GC_UGN_GatheredConstruct_UsedGrowthNormal
    )
    SELECT
        i.Metadata_GC_UGN,
        i.GC_UGN_GC_ID,
        i.GC_UGN_ChangedAt,
        i.GC_UGN_GatheredConstruct_UsedGrowthNormal
    FROM
        @inserted i
    WHERE
        i.GC_UGN_GatheredConstruct_UsedGrowthNormal is not null;
    INSERT INTO [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] (
        Metadata_GC_AMB,
        GC_AMB_GC_ID,
        GC_AMB_ChangedAt,
        GC_AMB_GatheredConstruct_AllocatedMegabytes
    )
    SELECT
        i.Metadata_GC_AMB,
        i.GC_AMB_GC_ID,
        i.GC_AMB_ChangedAt,
        i.GC_AMB_GatheredConstruct_AllocatedMegabytes
    FROM
        @inserted i
    WHERE
        i.GC_AMB_GatheredConstruct_AllocatedMegabytes is not null;
    INSERT INTO [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] (
        Metadata_GC_AGR,
        GC_AGR_GC_ID,
        GC_AGR_ChangedAt,
        GC_AGR_GatheredConstruct_AllocatedGrowth
    )
    SELECT
        i.Metadata_GC_AGR,
        i.GC_AGR_GC_ID,
        i.GC_AGR_ChangedAt,
        i.GC_AGR_GatheredConstruct_AllocatedGrowth
    FROM
        @inserted i
    WHERE
        i.GC_AGR_GatheredConstruct_AllocatedGrowth is not null;
    INSERT INTO [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] (
        Metadata_GC_AGN,
        GC_AGN_GC_ID,
        GC_AGN_ChangedAt,
        GC_AGN_GatheredConstruct_AllocatedGrowthNormal
    )
    SELECT
        i.Metadata_GC_AGN,
        i.GC_AGN_GC_ID,
        i.GC_AGN_ChangedAt,
        i.GC_AGN_GatheredConstruct_AllocatedGrowthNormal
    FROM
        @inserted i
    WHERE
        i.GC_AGN_GatheredConstruct_AllocatedGrowthNormal is not null;
    INSERT INTO [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] (
        Metadata_GC_AGI,
        GC_AGI_GC_ID,
        GC_AGI_ChangedAt,
        GC_AGI_GatheredConstruct_AllocatedGrowthInterval
    )
    SELECT
        i.Metadata_GC_AGI,
        i.GC_AGI_GC_ID,
        i.GC_AGI_ChangedAt,
        i.GC_AGI_GatheredConstruct_AllocatedGrowthInterval
    FROM
        @inserted i
    WHERE
        i.GC_AGI_GatheredConstruct_AllocatedGrowthInterval is not null;
    INSERT INTO [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] (
        Metadata_GC_UGI,
        GC_UGI_GC_ID,
        GC_UGI_ChangedAt,
        GC_UGI_GatheredConstruct_UsedGrowthInterval
    )
    SELECT
        i.Metadata_GC_UGI,
        i.GC_UGI_GC_ID,
        i.GC_UGI_ChangedAt,
        i.GC_UGI_GatheredConstruct_UsedGrowthInterval
    FROM
        @inserted i
    WHERE
        i.GC_UGI_GatheredConstruct_UsedGrowthInterval is not null;
    INSERT INTO [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] (
        Metadata_GC_RGI,
        GC_RGI_GC_ID,
        GC_RGI_ChangedAt,
        GC_RGI_GatheredConstruct_RowGrowthInterval
    )
    SELECT
        i.Metadata_GC_RGI,
        i.GC_RGI_GC_ID,
        i.GC_RGI_ChangedAt,
        i.GC_RGI_GatheredConstruct_RowGrowthInterval
    FROM
        @inserted i
    WHERE
        i.GC_RGI_GatheredConstruct_RowGrowthInterval is not null;
    INSERT INTO [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] (
        Metadata_GC_LGT,
        GC_LGT_GC_ID,
        GC_LGT_ChangedAt,
        GC_LGT_GatheredConstruct_LatestGatheringTime
    )
    SELECT
        i.Metadata_GC_LGT,
        i.GC_LGT_GC_ID,
        i.GC_LGT_ChangedAt,
        i.GC_LGT_GatheredConstruct_LatestGatheringTime
    FROM
        @inserted i
    WHERE
        i.GC_LGT_GatheredConstruct_LatestGatheringTime is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lGC_GatheredConstruct instead of UPDATE trigger on lGC_GatheredConstruct
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [stats].[ut_lGC_GatheredConstruct] ON [stats].[lGC_GatheredConstruct]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(GC_ID))
        RAISERROR('The identity column GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_NAM_GC_ID))
        RAISERROR('The foreign key column GC_NAM_GC_ID is not updatable.', 16, 1);
    IF (UPDATE(GC_NAM_GatheredConstruct_Name))
        RAISERROR('The static column GC_NAM_GatheredConstruct_Name is not updatable, and only missing values have been added.', 0, 1);
    IF(UPDATE(GC_NAM_GatheredConstruct_Name))
    BEGIN
        INSERT INTO [stats].[GC_NAM_GatheredConstruct_Name] (
            Metadata_GC_NAM,
            GC_NAM_GC_ID,
            GC_NAM_GatheredConstruct_Name
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_NAM)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_NAM
            END, i.Metadata_GC),
            ISNULL(i.GC_NAM_GC_ID, i.GC_ID),
            i.GC_NAM_GatheredConstruct_Name
        FROM
            inserted i
        WHERE
            i.GC_NAM_GatheredConstruct_Name is not null;
    END
    IF(UPDATE(GC_CAP_GC_ID))
        RAISERROR('The foreign key column GC_CAP_GC_ID is not updatable.', 16, 1);
    IF (UPDATE(GC_CAP_GatheredConstruct_Capsule))
        RAISERROR('The static column GC_CAP_GatheredConstruct_Capsule is not updatable, and only missing values have been added.', 0, 1);
    IF(UPDATE(GC_CAP_GatheredConstruct_Capsule))
    BEGIN
        INSERT INTO [stats].[GC_CAP_GatheredConstruct_Capsule] (
            Metadata_GC_CAP,
            GC_CAP_GC_ID,
            GC_CAP_GatheredConstruct_Capsule
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_CAP)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_CAP
            END, i.Metadata_GC),
            ISNULL(i.GC_CAP_GC_ID, i.GC_ID),
            i.GC_CAP_GatheredConstruct_Capsule
        FROM
            inserted i
        WHERE
            i.GC_CAP_GatheredConstruct_Capsule is not null;
    END
    IF(UPDATE(GC_TYP_GC_ID))
        RAISERROR('The foreign key column GC_TYP_GC_ID is not updatable.', 16, 1);
    IF (UPDATE(GC_TYP_TYP_ID))
        RAISERROR('The static column GC_TYP_TYP_ID is not updatable, and only missing values have been added.', 0, 1);
    IF (UPDATE(GC_TYP_TYP_Type))
        RAISERROR('The static column GC_TYP_TYP_Type is not updatable, and only missing values have been added.', 0, 1);
    IF(UPDATE(GC_TYP_TYP_ID) OR UPDATE(GC_TYP_TYP_Type))
    BEGIN
        INSERT INTO [stats].[GC_TYP_GatheredConstruct_Type] (
            Metadata_GC_TYP,
            GC_TYP_GC_ID,
            GC_TYP_TYP_ID
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_TYP)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_TYP
            END, i.Metadata_GC),
            ISNULL(i.GC_TYP_GC_ID, i.GC_ID),
            CASE WHEN UPDATE(GC_TYP_TYP_ID) THEN i.GC_TYP_TYP_ID ELSE [kTYP].TYP_ID END
        FROM
            inserted i
        LEFT JOIN
            [stats].[TYP_Type] [kTYP]
        ON
            [kTYP].TYP_Type = i.GC_TYP_TYP_Type
        WHERE
            CASE WHEN UPDATE(GC_TYP_TYP_ID) THEN i.GC_TYP_TYP_ID ELSE [kTYP].TYP_ID END is not null;
    END
    IF(UPDATE(GC_ROC_GC_ID))
        RAISERROR('The foreign key column GC_ROC_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_ROC_GatheredConstruct_RowCount))
    BEGIN
        INSERT INTO [stats].[GC_ROC_GatheredConstruct_RowCount] (
            Metadata_GC_ROC,
            GC_ROC_GC_ID,
            GC_ROC_ChangedAt,
            GC_ROC_GatheredConstruct_RowCount
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_ROC)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_ROC
            END, i.Metadata_GC),
            ISNULL(i.GC_ROC_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_ROC_GatheredConstruct_RowCount is null THEN i.GC_ROC_ChangedAt
                WHEN UPDATE(GC_ROC_ChangedAt) THEN i.GC_ROC_ChangedAt
            END, @now) as datetime),
            i.GC_ROC_GatheredConstruct_RowCount
        FROM
            inserted i
        WHERE
            i.GC_ROC_GatheredConstruct_RowCount is not null;
    END
    IF(UPDATE(GC_RGR_GC_ID))
        RAISERROR('The foreign key column GC_RGR_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_RGR_GatheredConstruct_RowGrowth))
    BEGIN
        INSERT INTO [stats].[GC_RGR_GatheredConstruct_RowGrowth] (
            Metadata_GC_RGR,
            GC_RGR_GC_ID,
            GC_RGR_ChangedAt,
            GC_RGR_GatheredConstruct_RowGrowth
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_RGR)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_RGR
            END, i.Metadata_GC),
            ISNULL(i.GC_RGR_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_RGR_GatheredConstruct_RowGrowth is null THEN i.GC_RGR_ChangedAt
                WHEN UPDATE(GC_RGR_ChangedAt) THEN i.GC_RGR_ChangedAt
            END, @now) as datetime),
            i.GC_RGR_GatheredConstruct_RowGrowth
        FROM
            inserted i
        WHERE
            i.GC_RGR_GatheredConstruct_RowGrowth is not null;
    END
    IF(UPDATE(GC_RGN_GC_ID))
        RAISERROR('The foreign key column GC_RGN_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_RGN_GatheredConstruct_RowGrowthNormal))
    BEGIN
        INSERT INTO [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] (
            Metadata_GC_RGN,
            GC_RGN_GC_ID,
            GC_RGN_ChangedAt,
            GC_RGN_GatheredConstruct_RowGrowthNormal
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_RGN)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_RGN
            END, i.Metadata_GC),
            ISNULL(i.GC_RGN_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_RGN_GatheredConstruct_RowGrowthNormal is null THEN i.GC_RGN_ChangedAt
                WHEN UPDATE(GC_RGN_ChangedAt) THEN i.GC_RGN_ChangedAt
            END, @now) as datetime),
            i.GC_RGN_GatheredConstruct_RowGrowthNormal
        FROM
            inserted i
        WHERE
            i.GC_RGN_GatheredConstruct_RowGrowthNormal is not null;
    END
    IF(UPDATE(GC_UMB_GC_ID))
        RAISERROR('The foreign key column GC_UMB_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_UMB_GatheredConstruct_UsedMegabytes))
    BEGIN
        INSERT INTO [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] (
            Metadata_GC_UMB,
            GC_UMB_GC_ID,
            GC_UMB_ChangedAt,
            GC_UMB_GatheredConstruct_UsedMegabytes
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_UMB)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_UMB
            END, i.Metadata_GC),
            ISNULL(i.GC_UMB_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_UMB_GatheredConstruct_UsedMegabytes is null THEN i.GC_UMB_ChangedAt
                WHEN UPDATE(GC_UMB_ChangedAt) THEN i.GC_UMB_ChangedAt
            END, @now) as datetime),
            i.GC_UMB_GatheredConstruct_UsedMegabytes
        FROM
            inserted i
        WHERE
            i.GC_UMB_GatheredConstruct_UsedMegabytes is not null;
    END
    IF(UPDATE(GC_UGR_GC_ID))
        RAISERROR('The foreign key column GC_UGR_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_UGR_GatheredConstruct_UsedGrowth))
    BEGIN
        INSERT INTO [stats].[GC_UGR_GatheredConstruct_UsedGrowth] (
            Metadata_GC_UGR,
            GC_UGR_GC_ID,
            GC_UGR_ChangedAt,
            GC_UGR_GatheredConstruct_UsedGrowth
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_UGR)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_UGR
            END, i.Metadata_GC),
            ISNULL(i.GC_UGR_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_UGR_GatheredConstruct_UsedGrowth is null THEN i.GC_UGR_ChangedAt
                WHEN UPDATE(GC_UGR_ChangedAt) THEN i.GC_UGR_ChangedAt
            END, @now) as datetime),
            i.GC_UGR_GatheredConstruct_UsedGrowth
        FROM
            inserted i
        WHERE
            i.GC_UGR_GatheredConstruct_UsedGrowth is not null;
    END
    IF(UPDATE(GC_UGN_GC_ID))
        RAISERROR('The foreign key column GC_UGN_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_UGN_GatheredConstruct_UsedGrowthNormal))
    BEGIN
        INSERT INTO [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] (
            Metadata_GC_UGN,
            GC_UGN_GC_ID,
            GC_UGN_ChangedAt,
            GC_UGN_GatheredConstruct_UsedGrowthNormal
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_UGN)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_UGN
            END, i.Metadata_GC),
            ISNULL(i.GC_UGN_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_UGN_GatheredConstruct_UsedGrowthNormal is null THEN i.GC_UGN_ChangedAt
                WHEN UPDATE(GC_UGN_ChangedAt) THEN i.GC_UGN_ChangedAt
            END, @now) as datetime),
            i.GC_UGN_GatheredConstruct_UsedGrowthNormal
        FROM
            inserted i
        WHERE
            i.GC_UGN_GatheredConstruct_UsedGrowthNormal is not null;
    END
    IF(UPDATE(GC_AMB_GC_ID))
        RAISERROR('The foreign key column GC_AMB_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_AMB_GatheredConstruct_AllocatedMegabytes))
    BEGIN
        INSERT INTO [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] (
            Metadata_GC_AMB,
            GC_AMB_GC_ID,
            GC_AMB_ChangedAt,
            GC_AMB_GatheredConstruct_AllocatedMegabytes
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_AMB)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_AMB
            END, i.Metadata_GC),
            ISNULL(i.GC_AMB_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_AMB_GatheredConstruct_AllocatedMegabytes is null THEN i.GC_AMB_ChangedAt
                WHEN UPDATE(GC_AMB_ChangedAt) THEN i.GC_AMB_ChangedAt
            END, @now) as datetime),
            i.GC_AMB_GatheredConstruct_AllocatedMegabytes
        FROM
            inserted i
        WHERE
            i.GC_AMB_GatheredConstruct_AllocatedMegabytes is not null;
    END
    IF(UPDATE(GC_AGR_GC_ID))
        RAISERROR('The foreign key column GC_AGR_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_AGR_GatheredConstruct_AllocatedGrowth))
    BEGIN
        INSERT INTO [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] (
            Metadata_GC_AGR,
            GC_AGR_GC_ID,
            GC_AGR_ChangedAt,
            GC_AGR_GatheredConstruct_AllocatedGrowth
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_AGR)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_AGR
            END, i.Metadata_GC),
            ISNULL(i.GC_AGR_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_AGR_GatheredConstruct_AllocatedGrowth is null THEN i.GC_AGR_ChangedAt
                WHEN UPDATE(GC_AGR_ChangedAt) THEN i.GC_AGR_ChangedAt
            END, @now) as datetime),
            i.GC_AGR_GatheredConstruct_AllocatedGrowth
        FROM
            inserted i
        WHERE
            i.GC_AGR_GatheredConstruct_AllocatedGrowth is not null;
    END
    IF(UPDATE(GC_AGN_GC_ID))
        RAISERROR('The foreign key column GC_AGN_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_AGN_GatheredConstruct_AllocatedGrowthNormal))
    BEGIN
        INSERT INTO [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] (
            Metadata_GC_AGN,
            GC_AGN_GC_ID,
            GC_AGN_ChangedAt,
            GC_AGN_GatheredConstruct_AllocatedGrowthNormal
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_AGN)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_AGN
            END, i.Metadata_GC),
            ISNULL(i.GC_AGN_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_AGN_GatheredConstruct_AllocatedGrowthNormal is null THEN i.GC_AGN_ChangedAt
                WHEN UPDATE(GC_AGN_ChangedAt) THEN i.GC_AGN_ChangedAt
            END, @now) as datetime),
            i.GC_AGN_GatheredConstruct_AllocatedGrowthNormal
        FROM
            inserted i
        WHERE
            i.GC_AGN_GatheredConstruct_AllocatedGrowthNormal is not null;
    END
    IF(UPDATE(GC_AGI_GC_ID))
        RAISERROR('The foreign key column GC_AGI_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_AGI_GatheredConstruct_AllocatedGrowthInterval))
    BEGIN
        INSERT INTO [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] (
            Metadata_GC_AGI,
            GC_AGI_GC_ID,
            GC_AGI_ChangedAt,
            GC_AGI_GatheredConstruct_AllocatedGrowthInterval
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_AGI)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_AGI
            END, i.Metadata_GC),
            ISNULL(i.GC_AGI_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_AGI_GatheredConstruct_AllocatedGrowthInterval is null THEN i.GC_AGI_ChangedAt
                WHEN UPDATE(GC_AGI_ChangedAt) THEN i.GC_AGI_ChangedAt
            END, @now) as datetime),
            i.GC_AGI_GatheredConstruct_AllocatedGrowthInterval
        FROM
            inserted i
        WHERE
            i.GC_AGI_GatheredConstruct_AllocatedGrowthInterval is not null;
    END
    IF(UPDATE(GC_UGI_GC_ID))
        RAISERROR('The foreign key column GC_UGI_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_UGI_GatheredConstruct_UsedGrowthInterval))
    BEGIN
        INSERT INTO [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] (
            Metadata_GC_UGI,
            GC_UGI_GC_ID,
            GC_UGI_ChangedAt,
            GC_UGI_GatheredConstruct_UsedGrowthInterval
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_UGI)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_UGI
            END, i.Metadata_GC),
            ISNULL(i.GC_UGI_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_UGI_GatheredConstruct_UsedGrowthInterval is null THEN i.GC_UGI_ChangedAt
                WHEN UPDATE(GC_UGI_ChangedAt) THEN i.GC_UGI_ChangedAt
            END, @now) as datetime),
            i.GC_UGI_GatheredConstruct_UsedGrowthInterval
        FROM
            inserted i
        WHERE
            i.GC_UGI_GatheredConstruct_UsedGrowthInterval is not null;
    END
    IF(UPDATE(GC_RGI_GC_ID))
        RAISERROR('The foreign key column GC_RGI_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_RGI_GatheredConstruct_RowGrowthInterval))
    BEGIN
        INSERT INTO [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] (
            Metadata_GC_RGI,
            GC_RGI_GC_ID,
            GC_RGI_ChangedAt,
            GC_RGI_GatheredConstruct_RowGrowthInterval
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_RGI)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_RGI
            END, i.Metadata_GC),
            ISNULL(i.GC_RGI_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_RGI_GatheredConstruct_RowGrowthInterval is null THEN i.GC_RGI_ChangedAt
                WHEN UPDATE(GC_RGI_ChangedAt) THEN i.GC_RGI_ChangedAt
            END, @now) as datetime),
            i.GC_RGI_GatheredConstruct_RowGrowthInterval
        FROM
            inserted i
        WHERE
            i.GC_RGI_GatheredConstruct_RowGrowthInterval is not null;
    END
    IF(UPDATE(GC_LGT_GC_ID))
        RAISERROR('The foreign key column GC_LGT_GC_ID is not updatable.', 16, 1);
    IF(UPDATE(GC_LGT_GatheredConstruct_LatestGatheringTime))
    BEGIN
        INSERT INTO [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] (
            Metadata_GC_LGT,
            GC_LGT_GC_ID,
            GC_LGT_ChangedAt,
            GC_LGT_GatheredConstruct_LatestGatheringTime
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_GC) AND NOT UPDATE(Metadata_GC_LGT)
                THEN i.Metadata_GC
                ELSE i.Metadata_GC_LGT
            END, i.Metadata_GC),
            ISNULL(i.GC_LGT_GC_ID, i.GC_ID),
            cast(ISNULL(CASE
                WHEN i.GC_LGT_GatheredConstruct_LatestGatheringTime is null THEN i.GC_LGT_ChangedAt
                WHEN UPDATE(GC_LGT_ChangedAt) THEN i.GC_LGT_ChangedAt
            END, @now) as datetime),
            i.GC_LGT_GatheredConstruct_LatestGatheringTime
        FROM
            inserted i
        WHERE
            i.GC_LGT_GatheredConstruct_LatestGatheringTime is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lGC_GatheredConstruct instead of DELETE trigger on lGC_GatheredConstruct
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [stats].[dt_lGC_GatheredConstruct] ON [stats].[lGC_GatheredConstruct]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [stats].[GC_NAM_GatheredConstruct_Name] [NAM]
    JOIN
        deleted d
    ON
        d.GC_NAM_GC_ID = [NAM].GC_NAM_GC_ID;
    DELETE [CAP]
    FROM
        [stats].[GC_CAP_GatheredConstruct_Capsule] [CAP]
    JOIN
        deleted d
    ON
        d.GC_CAP_GC_ID = [CAP].GC_CAP_GC_ID;
    DELETE [TYP]
    FROM
        [stats].[GC_TYP_GatheredConstruct_Type] [TYP]
    JOIN
        deleted d
    ON
        d.GC_TYP_GC_ID = [TYP].GC_TYP_GC_ID;
    DELETE [ROC]
    FROM
        [stats].[GC_ROC_GatheredConstruct_RowCount] [ROC]
    JOIN
        deleted d
    ON
        d.GC_ROC_ChangedAt = [ROC].GC_ROC_ChangedAt
    AND
        d.GC_ROC_GC_ID = [ROC].GC_ROC_GC_ID;
    DELETE [RGR]
    FROM
        [stats].[GC_RGR_GatheredConstruct_RowGrowth] [RGR]
    JOIN
        deleted d
    ON
        d.GC_RGR_ChangedAt = [RGR].GC_RGR_ChangedAt
    AND
        d.GC_RGR_GC_ID = [RGR].GC_RGR_GC_ID;
    DELETE [RGN]
    FROM
        [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] [RGN]
    JOIN
        deleted d
    ON
        d.GC_RGN_ChangedAt = [RGN].GC_RGN_ChangedAt
    AND
        d.GC_RGN_GC_ID = [RGN].GC_RGN_GC_ID;
    DELETE [UMB]
    FROM
        [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] [UMB]
    JOIN
        deleted d
    ON
        d.GC_UMB_ChangedAt = [UMB].GC_UMB_ChangedAt
    AND
        d.GC_UMB_GC_ID = [UMB].GC_UMB_GC_ID;
    DELETE [UGR]
    FROM
        [stats].[GC_UGR_GatheredConstruct_UsedGrowth] [UGR]
    JOIN
        deleted d
    ON
        d.GC_UGR_ChangedAt = [UGR].GC_UGR_ChangedAt
    AND
        d.GC_UGR_GC_ID = [UGR].GC_UGR_GC_ID;
    DELETE [UGN]
    FROM
        [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] [UGN]
    JOIN
        deleted d
    ON
        d.GC_UGN_ChangedAt = [UGN].GC_UGN_ChangedAt
    AND
        d.GC_UGN_GC_ID = [UGN].GC_UGN_GC_ID;
    DELETE [AMB]
    FROM
        [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] [AMB]
    JOIN
        deleted d
    ON
        d.GC_AMB_ChangedAt = [AMB].GC_AMB_ChangedAt
    AND
        d.GC_AMB_GC_ID = [AMB].GC_AMB_GC_ID;
    DELETE [AGR]
    FROM
        [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] [AGR]
    JOIN
        deleted d
    ON
        d.GC_AGR_ChangedAt = [AGR].GC_AGR_ChangedAt
    AND
        d.GC_AGR_GC_ID = [AGR].GC_AGR_GC_ID;
    DELETE [AGN]
    FROM
        [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] [AGN]
    JOIN
        deleted d
    ON
        d.GC_AGN_ChangedAt = [AGN].GC_AGN_ChangedAt
    AND
        d.GC_AGN_GC_ID = [AGN].GC_AGN_GC_ID;
    DELETE [AGI]
    FROM
        [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] [AGI]
    JOIN
        deleted d
    ON
        d.GC_AGI_ChangedAt = [AGI].GC_AGI_ChangedAt
    AND
        d.GC_AGI_GC_ID = [AGI].GC_AGI_GC_ID;
    DELETE [UGI]
    FROM
        [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] [UGI]
    JOIN
        deleted d
    ON
        d.GC_UGI_ChangedAt = [UGI].GC_UGI_ChangedAt
    AND
        d.GC_UGI_GC_ID = [UGI].GC_UGI_GC_ID;
    DELETE [RGI]
    FROM
        [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] [RGI]
    JOIN
        deleted d
    ON
        d.GC_RGI_ChangedAt = [RGI].GC_RGI_ChangedAt
    AND
        d.GC_RGI_GC_ID = [RGI].GC_RGI_GC_ID;
    DELETE [LGT]
    FROM
        [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] [LGT]
    JOIN
        deleted d
    ON
        d.GC_LGT_ChangedAt = [LGT].GC_LGT_ChangedAt
    AND
        d.GC_LGT_GC_ID = [LGT].GC_LGT_GC_ID;
    DELETE [GC]
    FROM
        [stats].[GC_GatheredConstruct] [GC]
    LEFT JOIN
        [stats].[GC_NAM_GatheredConstruct_Name] [NAM]
    ON
        [NAM].GC_NAM_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_CAP_GatheredConstruct_Capsule] [CAP]
    ON
        [CAP].GC_CAP_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_TYP_GatheredConstruct_Type] [TYP]
    ON
        [TYP].GC_TYP_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_ROC_GatheredConstruct_RowCount] [ROC]
    ON
        [ROC].GC_ROC_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_RGR_GatheredConstruct_RowGrowth] [RGR]
    ON
        [RGR].GC_RGR_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_RGN_GatheredConstruct_RowGrowthNormal] [RGN]
    ON
        [RGN].GC_RGN_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_UMB_GatheredConstruct_UsedMegabytes] [UMB]
    ON
        [UMB].GC_UMB_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_UGR_GatheredConstruct_UsedGrowth] [UGR]
    ON
        [UGR].GC_UGR_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_UGN_GatheredConstruct_UsedGrowthNormal] [UGN]
    ON
        [UGN].GC_UGN_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_AMB_GatheredConstruct_AllocatedMegabytes] [AMB]
    ON
        [AMB].GC_AMB_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_AGR_GatheredConstruct_AllocatedGrowth] [AGR]
    ON
        [AGR].GC_AGR_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_AGN_GatheredConstruct_AllocatedGrowthNormal] [AGN]
    ON
        [AGN].GC_AGN_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_AGI_GatheredConstruct_AllocatedGrowthInterval] [AGI]
    ON
        [AGI].GC_AGI_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_UGI_GatheredConstruct_UsedGrowthInterval] [UGI]
    ON
        [UGI].GC_UGI_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_RGI_GatheredConstruct_RowGrowthInterval] [RGI]
    ON
        [RGI].GC_RGI_GC_ID = [GC].GC_ID
    LEFT JOIN
        [stats].[GC_LGT_GatheredConstruct_LatestGatheringTime] [LGT]
    ON
        [LGT].GC_LGT_GC_ID = [GC].GC_ID
    WHERE
        [NAM].GC_NAM_GC_ID is null
    AND
        [CAP].GC_CAP_GC_ID is null
    AND
        [TYP].GC_TYP_GC_ID is null
    AND
        [ROC].GC_ROC_GC_ID is null
    AND
        [RGR].GC_RGR_GC_ID is null
    AND
        [RGN].GC_RGN_GC_ID is null
    AND
        [UMB].GC_UMB_GC_ID is null
    AND
        [UGR].GC_UGR_GC_ID is null
    AND
        [UGN].GC_UGN_GC_ID is null
    AND
        [AMB].GC_AMB_GC_ID is null
    AND
        [AGR].GC_AGR_GC_ID is null
    AND
        [AGN].GC_AGN_GC_ID is null
    AND
        [AGI].GC_AGI_GC_ID is null
    AND
        [UGI].GC_UGI_GC_ID is null
    AND
        [RGI].GC_RGI_GC_ID is null
    AND
        [LGT].GC_LGT_GC_ID is null;
END
GO
-- TIE TEMPORAL BUSINESS PERSPECTIVES ---------------------------------------------------------------------------------
--
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
--
-- The latest perspective shows the latest available information for each tie.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- TIE TEMPORAL BUSINESS PERSPECTIVES ---------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
--
-- The latest perspective shows the latest available information for each tie.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- SCHEMA EVOLUTION ---------------------------------------------------------------------------------------------------
--
-- The following tables, views, and functions are used to track schema changes
-- over time, as well as providing every XML that has been 'executed' against
-- the database.
--
-- Schema table -------------------------------------------------------------------------------------------------------
-- The schema table holds every xml that has been executed against the database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._Schema', 'U') IS NULL
   CREATE TABLE [stats].[_Schema] (
      [version] int identity(1, 1) not null,
      [activation] datetime2(7) not null,
      [schema] xml not null,
      constraint pk_Schema primary key (
         [version]
      )
   );
GO
-- Insert the XML schema (as of now)
INSERT INTO [stats].[_Schema] (
   [activation],
   [schema]
)
SELECT
   current_timestamp,
   N'<schema format="0.99.6.1" date="2020-04-23" time="17:21:29"><metadata changingRange="datetime" encapsulation="stats" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="true" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="decimal(5,2)" reliabilitySuffix="Reliability" deleteReliability="0" assertionSuffix="Assertion" partitioning="false" entityIntegrity="true" restatability="false" idempotency="true" assertiveness="true" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2(7)" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="true" decisiveness="true" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="uni" deletability="false" deletablePrefix="Deletable" deletionSuffix="Deleted" privacy="Ignore" checksum="false"/><anchor mnemonic="GC" descriptor="GatheredConstruct" identity="int"><metadata capsule="stats" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="nvarchar(128)"><metadata privacy="Ignore" capsule="stats" deletable="false"/><key stop="2" route="ConstructName" of="GC" branch="2"/><layout x="1547.81" y="526.77" fixed="false"/></attribute><attribute mnemonic="CAP" descriptor="Capsule" dataRange="nvarchar(128)"><metadata privacy="Ignore" capsule="stats" deletable="false"/><key stop="1" route="ConstructName" of="GC" branch="1"/><layout x="1626.51" y="590.41" fixed="false"/></attribute><attribute mnemonic="TYP" descriptor="Type" knotRange="TYP"><metadata privacy="Ignore" capsule="stats" deletable="false"/><layout x="1647.77" y="814.66" fixed="false"/></attribute><attribute mnemonic="ROC" descriptor="RowCount" timeRange="datetime" dataRange="bigint"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1685.79" y="637.40" fixed="false"/></attribute><attribute mnemonic="RGR" descriptor="RowGrowth" timeRange="datetime" dataRange="int"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1470.41" y="661.36" fixed="false"/></attribute><attribute mnemonic="RGN" descriptor="RowGrowthNormal" timeRange="datetime" dataRange="int"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1529.36" y="783.04" fixed="false"/></attribute><attribute mnemonic="UMB" descriptor="UsedMegabytes" timeRange="datetime" dataRange="decimal(19,2)"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1701.57" y="717.89" fixed="false"/></attribute><attribute mnemonic="UGR" descriptor="UsedGrowth" timeRange="datetime" dataRange="decimal(19,2)"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1649.92" y="615.62" fixed="false"/></attribute><attribute mnemonic="UGN" descriptor="UsedGrowthNormal" timeRange="datetime" dataRange="decimal(19,2)"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1497.53" y="749.23" fixed="false"/></attribute><attribute mnemonic="AMB" descriptor="AllocatedMegabytes" timeRange="datetime" dataRange="decimal(19,2)"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1572.29" y="802.41" fixed="false"/></attribute><attribute mnemonic="AGR" descriptor="AllocatedGrowth" timeRange="datetime" dataRange="decimal(19,2)"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1480.72" y="713.90" fixed="false"/></attribute><attribute mnemonic="AGN" descriptor="AllocatedGrowthNormal" timeRange="datetime" dataRange="decimal(19,2)"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1516.61" y="579.95" fixed="false"/></attribute><attribute mnemonic="AGI" descriptor="AllocatedGrowthInterval" timeRange="datetime" dataRange="bigint"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1488.98" y="638.37" fixed="false"/></attribute><attribute mnemonic="UGI" descriptor="UsedGrowthInterval" timeRange="datetime" dataRange="bigint"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1640.47" y="750.13" fixed="false"/></attribute><attribute mnemonic="RGI" descriptor="RowGrowthInterval" timeRange="datetime" dataRange="bigint"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1608.37" y="566.13" fixed="false"/></attribute><attribute mnemonic="LGT" descriptor="LatestGatheringTime" timeRange="datetime" dataRange="datetime"><metadata privacy="Ignore" capsule="stats" restatable="false" idempotent="true" deletable="false"/><layout x="1709.37" y="671.35" fixed="false"/></attribute><layout x="1585.94" y="684.24" fixed="false"/></anchor><knot mnemonic="TYP" descriptor="Type" identity="char(1)" dataRange="varchar(42)"><metadata capsule="stats" generator="false"/><layout x="1682.46" y="898.58" fixed="false"/></knot></schema>';
GO
-- Schema expanded view -----------------------------------------------------------------------------------------------
-- A view of the schema table that expands the XML attributes into columns
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._Schema_Expanded', 'V') IS NOT NULL
DROP VIEW [stats].[_Schema_Expanded]
GO
CREATE VIEW [stats].[_Schema_Expanded]
AS
SELECT
	[version],
	[activation],
	[schema],
	[schema].value('schema[1]/@format', 'nvarchar(max)') as [format],
	[schema].value('schema[1]/@date', 'datetime') + [schema].value('schema[1]/@time', 'datetime') as [date],
	[schema].value('schema[1]/metadata[1]/@temporalization', 'nvarchar(max)') as [temporalization],
	[schema].value('schema[1]/metadata[1]/@databaseTarget', 'nvarchar(max)') as [databaseTarget],
	[schema].value('schema[1]/metadata[1]/@changingRange', 'nvarchar(max)') as [changingRange],
	[schema].value('schema[1]/metadata[1]/@encapsulation', 'nvarchar(max)') as [encapsulation],
	[schema].value('schema[1]/metadata[1]/@identity', 'nvarchar(max)') as [identity],
	[schema].value('schema[1]/metadata[1]/@metadataPrefix', 'nvarchar(max)') as [metadataPrefix],
	[schema].value('schema[1]/metadata[1]/@metadataType', 'nvarchar(max)') as [metadataType],
	[schema].value('schema[1]/metadata[1]/@metadataUsage', 'nvarchar(max)') as [metadataUsage],
	[schema].value('schema[1]/metadata[1]/@changingSuffix', 'nvarchar(max)') as [changingSuffix],
	[schema].value('schema[1]/metadata[1]/@identitySuffix', 'nvarchar(max)') as [identitySuffix],
	[schema].value('schema[1]/metadata[1]/@positIdentity', 'nvarchar(max)') as [positIdentity],
	[schema].value('schema[1]/metadata[1]/@positGenerator', 'nvarchar(max)') as [positGenerator],
	[schema].value('schema[1]/metadata[1]/@positingRange', 'nvarchar(max)') as [positingRange],
	[schema].value('schema[1]/metadata[1]/@positingSuffix', 'nvarchar(max)') as [positingSuffix],
	[schema].value('schema[1]/metadata[1]/@positorRange', 'nvarchar(max)') as [positorRange],
	[schema].value('schema[1]/metadata[1]/@positorSuffix', 'nvarchar(max)') as [positorSuffix],
	[schema].value('schema[1]/metadata[1]/@reliabilityRange', 'nvarchar(max)') as [reliabilityRange],
	[schema].value('schema[1]/metadata[1]/@reliabilitySuffix', 'nvarchar(max)') as [reliabilitySuffix],
	[schema].value('schema[1]/metadata[1]/@deleteReliability', 'nvarchar(max)') as [deleteReliability],
	[schema].value('schema[1]/metadata[1]/@assertionSuffix', 'nvarchar(max)') as [assertionSuffix],
	[schema].value('schema[1]/metadata[1]/@partitioning', 'nvarchar(max)') as [partitioning],
	[schema].value('schema[1]/metadata[1]/@entityIntegrity', 'nvarchar(max)') as [entityIntegrity],
	[schema].value('schema[1]/metadata[1]/@restatability', 'nvarchar(max)') as [restatability],
	[schema].value('schema[1]/metadata[1]/@idempotency', 'nvarchar(max)') as [idempotency],
	[schema].value('schema[1]/metadata[1]/@assertiveness', 'nvarchar(max)') as [assertiveness],
	[schema].value('schema[1]/metadata[1]/@naming', 'nvarchar(max)') as [naming],
	[schema].value('schema[1]/metadata[1]/@positSuffix', 'nvarchar(max)') as [positSuffix],
	[schema].value('schema[1]/metadata[1]/@annexSuffix', 'nvarchar(max)') as [annexSuffix],
	[schema].value('schema[1]/metadata[1]/@chronon', 'nvarchar(max)') as [chronon],
	[schema].value('schema[1]/metadata[1]/@now', 'nvarchar(max)') as [now],
	[schema].value('schema[1]/metadata[1]/@dummySuffix', 'nvarchar(max)') as [dummySuffix],
	[schema].value('schema[1]/metadata[1]/@statementTypeSuffix', 'nvarchar(max)') as [statementTypeSuffix],
	[schema].value('schema[1]/metadata[1]/@checksumSuffix', 'nvarchar(max)') as [checksumSuffix],
	[schema].value('schema[1]/metadata[1]/@businessViews', 'nvarchar(max)') as [businessViews],
	[schema].value('schema[1]/metadata[1]/@equivalence', 'nvarchar(max)') as [equivalence],
	[schema].value('schema[1]/metadata[1]/@equivalentSuffix', 'nvarchar(max)') as [equivalentSuffix],
	[schema].value('schema[1]/metadata[1]/@equivalentRange', 'nvarchar(max)') as [equivalentRange]
FROM
	_Schema;
GO
-- Anchor view --------------------------------------------------------------------------------------------------------
-- The anchor view shows information about all the anchors in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._Anchor', 'V') IS NOT NULL
DROP VIEW [stats].[_Anchor]
GO
CREATE VIEW [stats].[_Anchor]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.anchor.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.anchor.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.anchor.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.anchor.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.anchor.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.anchor.value('count(attribute)', 'int') as [numberOfAttributes],
   Nodeset.anchor.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [stats].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as Nodeset(anchor);
GO
-- Knot view ----------------------------------------------------------------------------------------------------------
-- The knot view shows information about all the knots in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._Knot', 'V') IS NOT NULL
DROP VIEW [stats].[_Knot]
GO
CREATE VIEW [stats].[_Knot]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.knot.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.knot.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.knot.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.knot.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.knot.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.knot.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.knot.value('@dataRange', 'nvarchar(max)') as [dataRange],
   isnull(Nodeset.knot.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   isnull(Nodeset.knot.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent],
   Nodeset.knot.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [stats].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/knot') as Nodeset(knot);
GO
-- Attribute view -----------------------------------------------------------------------------------------------------
-- The attribute view shows information about all the attributes in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._Attribute', 'V') IS NOT NULL
DROP VIEW [stats].[_Attribute]
GO
CREATE VIEW [stats].[_Attribute]
AS
SELECT
   S.version,
   S.activation,
   ParentNodeset.anchor.value('concat(@mnemonic, "_")', 'nvarchar(max)') +
   Nodeset.attribute.value('concat(@mnemonic, "_")', 'nvarchar(max)') +
   ParentNodeset.anchor.value('concat(@descriptor, "_")', 'nvarchar(max)') +
   Nodeset.attribute.value('@descriptor', 'nvarchar(max)') as [name],
   Nodeset.attribute.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.attribute.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.attribute.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.attribute.value('@identity', 'nvarchar(max)') as [identity],
   isnull(Nodeset.attribute.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent],
   Nodeset.attribute.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.attribute.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   Nodeset.attribute.value('metadata[1]/@privacy', 'nvarchar(max)') as [privacy],
   isnull(Nodeset.attribute.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   Nodeset.attribute.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.attribute.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   ParentNodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [anchorMnemonic],
   ParentNodeset.anchor.value('@descriptor', 'nvarchar(max)') as [anchorDescriptor],
   ParentNodeset.anchor.value('@identity', 'nvarchar(max)') as [anchorIdentity],
   Nodeset.attribute.value('@dataRange', 'nvarchar(max)') as [dataRange],
   Nodeset.attribute.value('@knotRange', 'nvarchar(max)') as [knotRange],
   Nodeset.attribute.value('@timeRange', 'nvarchar(max)') as [timeRange],
   Nodeset.attribute.value('metadata[1]/@deletable', 'nvarchar(max)') as [deletable],
   Nodeset.attribute.value('metadata[1]/@encryptionGroup', 'nvarchar(max)') as [encryptionGroup],
   Nodeset.attribute.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [stats].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as ParentNodeset(anchor)
OUTER APPLY
   ParentNodeset.anchor.nodes('attribute') as Nodeset(attribute);
GO
-- Tie view -----------------------------------------------------------------------------------------------------------
-- The tie view shows information about all the ties in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._Tie', 'V') IS NOT NULL
DROP VIEW [stats].[_Tie]
GO
CREATE VIEW [stats].[_Tie]
AS
SELECT
   S.version,
   S.activation,
   REPLACE(Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"]
      return concat($role/@type, "_", $role/@role)
   ').value('.', 'nvarchar(max)'), ' ', '_') as [name],
   Nodeset.tie.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.tie.value('count(anchorRole) + count(knotRole)', 'int') as [numberOfRoles],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"]
      return string($role/@role)
   ').value('.', 'nvarchar(max)') as [roles],
   Nodeset.tie.value('count(anchorRole)', 'int') as [numberOfAnchors],
   Nodeset.tie.query('
      for $role in anchorRole
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [anchors],
   Nodeset.tie.value('count(knotRole)', 'int') as [numberOfKnots],
   Nodeset.tie.query('
      for $role in knotRole
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [knots],
   Nodeset.tie.value('count(*[local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"])', 'int') as [numberOfIdentifiers],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"]
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [identifiers],
   Nodeset.tie.value('@timeRange', 'nvarchar(max)') as [timeRange],
   Nodeset.tie.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.tie.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   Nodeset.tie.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.tie.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   Nodeset.tie.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [stats].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/tie') as Nodeset(tie);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- The key view shows information about all the keys in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._Key', 'V') IS NOT NULL
DROP VIEW [stats].[_Key]
GO
CREATE VIEW [stats].[_Key]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.keys.value('@of', 'nvarchar(max)') as [of],
   Nodeset.keys.value('@route', 'nvarchar(max)') as [route],
   Nodeset.keys.value('@stop', 'nvarchar(max)') as [stop],
   case [parent]
      when 'tie'
      then Nodeset.keys.value('../@role', 'nvarchar(max)')
   end as [role],
   case [parent]
      when 'knot'
      then Nodeset.keys.value('concat(../@mnemonic, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('../@descriptor', 'nvarchar(max)') 
      when 'attribute'
      then Nodeset.keys.value('concat(../../@mnemonic, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('concat(../@mnemonic, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('concat(../../@descriptor, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('../@descriptor', 'nvarchar(max)') 
      when 'tie'
      then REPLACE(Nodeset.keys.query('
            for $role in ../../*[local-name() = "anchorRole" or local-name() = "knotRole"]
            return concat($role/@type, "_", $role/@role)
          ').value('.', 'nvarchar(max)'), ' ', '_')
   end as [in],
   [parent]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema//key') as Nodeset(keys)
CROSS APPLY (
   VALUES (
      case
         when Nodeset.keys.value('local-name(..)', 'nvarchar(max)') in ('anchorRole', 'knotRole')
         then 'tie'
         else Nodeset.keys.value('local-name(..)', 'nvarchar(max)')
      end 
   )
) p ([parent]);
GO
-- Evolution function -------------------------------------------------------------------------------------------------
-- The evolution function shows what the schema looked like at the given
-- point in time with additional information about missing or added
-- modeling components since that time.
--
-- @timepoint The point in time to which you would like to travel.
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._Evolution', 'IF') IS NOT NULL
DROP FUNCTION [stats].[_Evolution];
GO
CREATE FUNCTION [stats].[_Evolution] (
    @timepoint AS datetime2(7)
)
RETURNS TABLE AS
RETURN
WITH constructs AS (
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM 
      [stats].[_Anchor] a
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [stats].[_Knot] k
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [stats].[_Attribute] b
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '_Annex'), ('crt', '_Posit')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [stats].[_Tie] t
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '_Annex'), ('crt', '_Posit')
   ) s (temporalization, suffix)
), 
selectedSchema AS (
   SELECT TOP 1
      *
   FROM
      [stats].[_Schema_Expanded]
   WHERE
      [activation] <= @timepoint
   ORDER BY
      [activation] DESC
),
presentConstructs AS (
   SELECT
      C.*
   FROM
      selectedSchema S
   JOIN
      constructs C
   ON
      S.[version] = C.[version]
   AND
      S.temporalization = C.temporalization 
), 
allConstructs AS (
   SELECT
      C.*
   FROM
      selectedSchema S
   JOIN
      constructs C
   ON
      S.temporalization = C.temporalization
)
SELECT
   COALESCE(P.[version], X.[version]) as [version],
   COALESCE(P.[qualifiedName], T.[qualifiedName]) AS [name],
   COALESCE(P.[activation], X.[activation], T.[create_date]) AS [activation],
   CASE
      WHEN P.[activation] = S.[activation] THEN 'Present'
      WHEN X.[activation] > S.[activation] THEN 'Future'
      WHEN X.[activation] < S.[activation] THEN 'Past'
      ELSE 'Missing'
   END AS Existence
FROM 
   presentConstructs P
FULL OUTER JOIN (
   SELECT 
      s.[name] + '.' + t.[name] AS [qualifiedName],
      t.[create_date]
   FROM 
      sys.tables t
   JOIN
      sys.schemas s
   ON
      s.schema_id = t.schema_id
   WHERE
      t.[type] = 'U'
   AND
      LEFT(t.[name], 1) <> '_'
) T
ON
   T.[qualifiedName] = P.[qualifiedName]
LEFT JOIN
   allConstructs X
ON
   X.[qualifiedName] = T.[qualifiedName]
AND
   X.[activation] = (
      SELECT
         MIN(sub.[activation])
      FROM
         constructs sub
      WHERE
         sub.[qualifiedName] = T.[qualifiedName]
      AND 
         sub.[activation] >= T.[create_date]
   )
CROSS APPLY (
   SELECT
      *
   FROM
      selectedSchema
) S;
GO
-- Drop Script Generator ----------------------------------------------------------------------------------------------
-- generates a drop script, that must be run separately, dropping everything in an Anchor Modeled database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._GenerateDropScript', 'P') IS NOT NULL
DROP PROCEDURE [stats].[_GenerateDropScript];
GO
CREATE PROCEDURE [stats]._GenerateDropScript (
   @exclusionPattern varchar(42) = '%.[[][_]%', -- exclude Metadata by default
   @inclusionPattern varchar(42) = '%', -- include everything by default
   @directions varchar(42) = 'Upwards, Downwards', -- do both up and down by default
   @qualifiedName varchar(555) = null -- can specify a single object
)
AS
BEGIN
   set nocount on;
   select
      ordinal,
      unqualifiedName,
      qualifiedName
   into 
      #constructs
   from (
      select distinct
         10 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [stats]._Attribute
      union all
      select distinct
         11 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Annex]' as qualifiedName
      from
         [stats]._Attribute
      union all
      select distinct
         12 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Posit]' as qualifiedName
      from
         [stats]._Attribute
      union all
      select distinct
         20 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [stats]._Tie
      union all
      select distinct
         21 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Annex]' as qualifiedName
      from
         [stats]._Tie
      union all
      select distinct
         22 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Posit]' as qualifiedName
      from
         [stats]._Tie
      union all
      select distinct
         30 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [stats]._Knot
      union all
      select distinct
         40 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [stats]._Anchor
   ) t;
   select
      c.ordinal,
      cast(c.unqualifiedName as nvarchar(517)) as unqualifiedName,
      cast(c.qualifiedName as nvarchar(517)) as qualifiedName,
      o.[object_id],
      o.[type]
   into
      #includedConstructs
   from
      #constructs c
   join
      sys.objects o
   on
      o.[object_id] = OBJECT_ID(c.qualifiedName)
   and 
      o.[type] = 'U'
   where
      OBJECT_ID(c.qualifiedName) = OBJECT_ID(isnull(@qualifiedName, c.qualifiedName));
   create unique clustered index ix_includedConstructs on #includedConstructs([object_id]);
   with relatedUpwards as (
      select
         c.[object_id],
         c.[type],
         c.unqualifiedName,
         c.qualifiedName,
         1 as depth
      from
         #includedConstructs c
      union all
      select
         o.[object_id],
         o.[type],
         n.unqualifiedName,
         n.qualifiedName,
         c.depth + 1 as depth
      from
         relatedUpwards c
      cross apply (
         select
            refs.referencing_id
         from 
            sys.dm_sql_referencing_entities(c.qualifiedName, 'OBJECT') refs
         where
            refs.referencing_id <> OBJECT_ID(c.qualifiedName)
      ) r
      join
         sys.objects o
      on
         o.[object_id] = r.referencing_id
      and
         o.type not in ('S')
      join 
         sys.schemas s 
      on 
         s.schema_id = o.schema_id
      cross apply (
         select
            cast('[' + s.name + '].[' + o.name + ']' as nvarchar(517)),
            cast(o.name as nvarchar(517))
      ) n (qualifiedName, unqualifiedName)
   )
   select distinct
      [object_id],
      [type],
      unqualifiedName,
      qualifiedName,
      depth
   into
      #relatedUpwards
   from
      relatedUpwards u
   where
      depth = (
         select
            MAX(depth)
         from
            relatedUpwards s
         where
            s.[object_id] = u.[object_id]
      );
   create unique clustered index ix_relatedUpwards on #relatedUpwards([object_id]);
   with relatedDownwards as (
      select
         cast('Upwards' as varchar(42)) as [relationType],
         c.[object_id],
         c.[type],
         c.unqualifiedName, 
         c.qualifiedName,
         c.depth
      from
         #relatedUpwards c 
      union all
      select
         cast('Downwards' as varchar(42)) as [relationType],
         o.[object_id],
         o.[type],
         n.unqualifiedName, 
         n.qualifiedName,
         c.depth - 1 as depth
      from
         relatedDownwards c
      cross apply (
         select 
            refs.referenced_id 
         from
            sys.dm_sql_referenced_entities(c.qualifiedName, 'OBJECT') refs
         where
            refs.referenced_minor_id = 0
         and
            refs.referenced_id <> OBJECT_ID(c.qualifiedName)
         and 
            refs.referenced_id not in (select [object_id] from #relatedUpwards)
      ) r
      join -- select top 100 * from 
         sys.objects o
      on
         o.[object_id] = r.referenced_id
      and
         o.type not in ('S')
      join
         sys.schemas s
      on 
         s.schema_id = o.schema_id
      cross apply (
         select
            cast('[' + s.name + '].[' + o.name + ']' as nvarchar(517)),
            cast(o.name as nvarchar(517))
      ) n (qualifiedName, unqualifiedName)
   )
   select distinct
      relationType,
      [object_id],
      [type],
      unqualifiedName,
      qualifiedName,
      depth
   into
      #relatedDownwards
   from
      relatedDownwards d
   where
      depth = (
         select
            MIN(depth)
         from
            relatedDownwards s
         where
            s.[object_id] = d.[object_id]
      );
   create unique clustered index ix_relatedDownwards on #relatedDownwards([object_id]);
   select distinct
      [object_id],
      [type],
      [unqualifiedName],
      [qualifiedName],
      [depth]
   into
      #affectedObjects
   from
      #relatedDownwards d
   where
      [qualifiedName] not like @exclusionPattern
   and
      [qualifiedName] like @inclusionPattern
   and
      @directions like '%' + [relationType] + '%';
   create unique clustered index ix_affectedObjects on #affectedObjects([object_id]);
   select distinct
      objectType,
      unqualifiedName,
      qualifiedName,
      dropOrder
   into
      #dropList
   from (
      select
         t.objectType,
         o.unqualifiedName,
         o.qualifiedName,
         dense_rank() over (
            order by
               o.depth desc,
               case o.[type]
                  when 'C' then 0 -- CHECK CONSTRAINT
                  when 'TR' then 1 -- SQL_TRIGGER
                  when 'P' then 2 -- SQL_STORED_PROCEDURE
                  when 'V' then 3 -- VIEW
                  when 'IF' then 4 -- SQL_INLINE_TABLE_VALUED_FUNCTION
                  when 'FN' then 5 -- SQL_SCALAR_FUNCTION
                  when 'PK' then 6 -- PRIMARY_KEY_CONSTRAINT
                  when 'UQ' then 7 -- UNIQUE_CONSTRAINT
                  when 'F' then 8 -- FOREIGN_KEY_CONSTRAINT
                  when 'U' then 9 -- USER_TABLE
               end asc,
               isnull(c.ordinal, 0) asc
         ) as dropOrder
      from
         #affectedObjects o
      left join
         #includedConstructs c
      on
         c.[object_id] = o.[object_id]
      cross apply (
         select
            case o.[type]
               when 'C' then 'CHECK'
               when 'TR' then 'TRIGGER'
               when 'V' then 'VIEW'
               when 'IF' then 'FUNCTION'
               when 'FN' then 'FUNCTION'
               when 'P' then 'PROCEDURE'
               when 'PK' then 'CONSTRAINT'
               when 'UQ' then 'CONSTRAINT'
               when 'F' then 'CONSTRAINT'
               when 'U' then 'TABLE'
            end
         ) t (objectType)
      where
         t.objectType in (
            'CHECK',
            'VIEW',
            'FUNCTION',
            'PROCEDURE',
            'TABLE'
         )
   ) r;
   select
      case 
         when d.objectType = 'CHECK'
         then 'ALTER TABLE ' + p.parentName + ' DROP CONSTRAINT ' + d.unqualifiedName
         else 'DROP ' + d.objectType + ' ' + d.qualifiedName
      end + ';' + CHAR(13) as [text()]
   from
      #dropList d
   join
      sys.objects o
   on
      o.[object_id] = OBJECT_ID(d.qualifiedName)
   join
      sys.schemas s
   on
      s.[schema_id] = o.[schema_id]
   cross apply (
      select
         '[' + s.name + '].[' + OBJECT_NAME(o.parent_object_id) + ']'
   ) p (parentName)
   order by
      d.dropOrder asc
   for xml path('');
END
GO
-- Database Copy Script Generator -------------------------------------------------------------------------------------
-- generates a copy script, that must be run separately, copying all data between two identically modeled databases
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._GenerateCopyScript', 'P') IS NOT NULL
DROP PROCEDURE [stats].[_GenerateCopyScript];
GO
CREATE PROCEDURE [stats]._GenerateCopyScript (
	@source varchar(123),
	@target varchar(123)
)
as
begin
	declare @R char(1);
    set @R = CHAR(13);
	-- stores the built SQL code
	declare @sql varchar(max);
    set @sql = 'USE ' + @target + ';' + @R;
	declare @xml xml;
	-- find which version of the schema that is in effect
	declare @version int;
	select
		@version = max([version])
	from
		_Schema;
	-- declare and set other variables we need
	declare @equivalentSuffix varchar(42);
	declare @identitySuffix varchar(42);
	declare @annexSuffix varchar(42);
	declare @positSuffix varchar(42);
	declare @temporalization varchar(42);
	select
		@equivalentSuffix = equivalentSuffix,
		@identitySuffix = identitySuffix,
		@annexSuffix = annexSuffix,
		@positSuffix = positSuffix,
		@temporalization = temporalization
	from
		_Schema_Expanded
	where
		[version] = @version;
	-- build non-equivalent knot copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R
			end
		from
			_Knot x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		and
			isnull(equivalent, 'false') = 'false'
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build equivalent knot copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @identitySuffix + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @identitySuffix + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @identitySuffix + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @identitySuffix + ' OFF;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @equivalentSuffix + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @equivalentSuffix + ';' + @R
		from
			_Knot x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		and
			isnull(equivalent, 'false') = 'true'
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build anchor copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R
			end
		from
			_Anchor x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build attribute copy
	if (@temporalization = 'crt')
	begin
		set @xml = (
			select
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' ON;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @positSuffix + '(' + [positColumns] + ')' + @R +
				'SELECT ' + [positColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @positSuffix + ';' + @R,
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' OFF;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @annexSuffix + '(' + [annexColumns] + ')' + @R +
				'SELECT ' + [annexColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @annexSuffix + ';' + @R
			from
				_Attribute x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @positSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) pc ([positColumns])
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @annexSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) ac ([annexColumns])
			where
				[version] = @version
			for xml path('')
		);
	end
	else -- uni
	begin
		set @xml = (
			select
				'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
				'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R
			from
				_Attribute x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) c ([columns])
			where
				[version] = @version
			for xml path('')
		);
	end
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build tie copy
	if (@temporalization = 'crt')
	begin
		set @xml = (
			select
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' ON;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @positSuffix + '(' + [positColumns] + ')' + @R +
				'SELECT ' + [positColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @positSuffix + ';' + @R,
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' OFF;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @annexSuffix + '(' + [annexColumns] + ')' + @R +
				'SELECT ' + [annexColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @annexSuffix + ';' + @R
			from
				_Tie x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @positSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) pc ([positColumns])
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @annexSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) ac ([annexColumns])
			where
				[version] = @version
			for xml path('')
		);
	end
	else -- uni
	begin
		set @xml = (
			select
				'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
				'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R
			from
				_Tie x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) c ([columns])
			where
				[version] = @version
			for xml path('')
		);
	end
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	select @sql for xml path('');
end
go
-- Delete Everything with a Certain Metadata Id -----------------------------------------------------------------------
-- deletes all rows from all tables that have the specified metadata id
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('stats._DeleteWhereMetadataEquals', 'P') IS NOT NULL
DROP PROCEDURE [stats].[_DeleteWhereMetadataEquals];
GO
CREATE PROCEDURE [stats]._DeleteWhereMetadataEquals (
	@metadataID int,
	@schemaVersion int = null,
	@includeKnots bit = 0
)
as
begin
	declare @sql varchar(max);
	set @sql = 'print ''Null is not a valid value for @metadataId''';
	if(@metadataId is not null)
	begin
		if(@schemaVersion is null)
		begin
			select
				@schemaVersion = max(Version)
			from
				_Schema;
		end;
		with constructs as (
			select
				'l' + name as name,
				2 as prio,
				'Metadata_' + name as metadataColumn
			from
				_Tie
			where
				[version] = @schemaVersion
			union all
			select
				'l' + name as name,
				3 as prio,
				'Metadata_' + mnemonic as metadataColumn
			from
				_Anchor
			where
				[version] = @schemaVersion
			union all
			select
				name,
				4 as prio,
				'Metadata_' + mnemonic as metadataColumn
			from
				_Knot
			where
				[version] = @schemaVersion
			and
				@includeKnots = 1
		)
		select
			@sql = (
				select
					'DELETE FROM ' + name + ' WHERE ' + metadataColumn + ' = ' + cast(@metadataId as varchar(10)) + '; '
				from
					constructs
        order by
					prio, name
				for xml
					path('')
			);
	end
	exec(@sql);
end
go
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------