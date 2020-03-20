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
-- SGR_StatisticGroup table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SGR_StatisticGroup', 'U') IS NULL
CREATE TABLE [dbo].[SGR_StatisticGroup] (
    SGR_ID smallint IDENTITY(1,1) not null,
    SGR_StatisticGroup varchar(555) not null,
    Metadata_SGR int not null,
    constraint pkSGR_StatisticGroup primary key (
        SGR_ID asc
    ),
    constraint uqSGR_StatisticGroup unique (
        SGR_StatisticGroup
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
-- PL_Player table (with 1 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PL_Player', 'U') IS NULL
CREATE TABLE [dbo].[PL_Player] (
    PL_ID int IDENTITY(1,1) not null,
    Metadata_PL int not null, 
    constraint pkPL_Player primary key (
        PL_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PL_NAM_Player_Name table (on PL_Player)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PL_NAM_Player_Name', 'U') IS NULL
CREATE TABLE [dbo].[PL_NAM_Player_Name] (
    PL_NAM_PL_ID int not null,
    PL_NAM_Player_Name varchar(555) not null,
    Metadata_PL_NAM int not null,
    constraint fkPL_NAM_Player_Name foreign key (
        PL_NAM_PL_ID
    ) references [dbo].[PL_Player](PL_ID),
    constraint pkPL_NAM_Player_Name primary key (
        PL_NAM_PL_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ME_Measurement table (with 1 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ME_Measurement', 'U') IS NULL
CREATE TABLE [dbo].[ME_Measurement] (
    ME_ID int IDENTITY(1,1) not null,
    Metadata_ME int not null, 
    constraint pkME_Measurement primary key (
        ME_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ME_VAL_Measurement_Value table (on ME_Measurement)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ME_VAL_Measurement_Value', 'U') IS NULL
CREATE TABLE [dbo].[ME_VAL_Measurement_Value] (
    ME_VAL_ME_ID int not null,
    ME_VAL_Measurement_Value varchar(555) not null,
    ME_VAL_ChangedAt date not null,
    Metadata_ME_VAL int not null,
    constraint fkME_VAL_Measurement_Value foreign key (
        ME_VAL_ME_ID
    ) references [dbo].[ME_Measurement](ME_ID),
    constraint pkME_VAL_Measurement_Value primary key (
        ME_VAL_ME_ID asc,
        ME_VAL_ChangedAt desc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Statistic table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Statistic', 'U') IS NULL
CREATE TABLE [dbo].[ST_Statistic] (
    ST_ID int IDENTITY(1,1) not null,
    Metadata_ST int not null, 
    constraint pkST_Statistic primary key (
        ST_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_DET_Statistic_Detail table (on ST_Statistic)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_DET_Statistic_Detail', 'U') IS NULL
CREATE TABLE [dbo].[ST_DET_Statistic_Detail] (
    ST_DET_ST_ID int not null,
    ST_DET_Statistic_Detail varchar(555) not null,
    Metadata_ST_DET int not null,
    constraint fkST_DET_Statistic_Detail foreign key (
        ST_DET_ST_ID
    ) references [dbo].[ST_Statistic](ST_ID),
    constraint pkST_DET_Statistic_Detail primary key (
        ST_DET_ST_ID asc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_GRP_Statistic_Group table (on ST_Statistic)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_GRP_Statistic_Group', 'U') IS NULL
CREATE TABLE [dbo].[ST_GRP_Statistic_Group] (
    ST_GRP_ST_ID int not null,
    ST_GRP_SGR_ID smallint not null,
    Metadata_ST_GRP int not null,
    constraint fk_A_ST_GRP_Statistic_Group foreign key (
        ST_GRP_ST_ID
    ) references [dbo].[ST_Statistic](ST_ID),
    constraint fk_K_ST_GRP_Statistic_Group foreign key (
        ST_GRP_SGR_ID
    ) references [dbo].[SGR_StatisticGroup](SGR_ID),
    constraint pkST_GRP_Statistic_Group primary key (
        ST_GRP_ST_ID asc
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
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PL_was_ME_measured table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PL_was_ME_measured', 'U') IS NULL
CREATE TABLE [dbo].[PL_was_ME_measured] (
    PL_ID_was int not null, 
    ME_ID_measured int not null, 
    Metadata_PL_was_ME_measured int not null,
    constraint PL_was_ME_measured_fkPL_was foreign key (
        PL_ID_was
    ) references [dbo].[PL_Player](PL_ID), 
    constraint PL_was_ME_measured_fkME_measured foreign key (
        ME_ID_measured
    ) references [dbo].[ME_Measurement](ME_ID), 
    constraint pkPL_was_ME_measured primary key (
        PL_ID_was asc,
        ME_ID_measured asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- ME_for_ST_the table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ME_for_ST_the', 'U') IS NULL
CREATE TABLE [dbo].[ME_for_ST_the] (
    ME_ID_for int not null, 
    ST_ID_the int not null, 
    Metadata_ME_for_ST_the int not null,
    constraint ME_for_ST_the_fkME_for foreign key (
        ME_ID_for
    ) references [dbo].[ME_Measurement](ME_ID), 
    constraint ME_for_ST_the_fkST_the foreign key (
        ST_ID_the
    ) references [dbo].[ST_Statistic](ST_ID), 
    constraint pkME_for_ST_the primary key (
        ME_ID_for asc,
        ST_ID_the asc
    )
);
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
-- rfME_VAL_Measurement_Value restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcME_VAL_Measurement_Value restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfME_VAL_Measurement_Value', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfME_VAL_Measurement_Value] (
        @id int,
        @value varchar(555),
        @changed date
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.ME_VAL_Measurement_Value
                    FROM
                        [dbo].[ME_VAL_Measurement_Value] pre
                    WHERE
                        pre.ME_VAL_ME_ID = @id
                    AND
                        pre.ME_VAL_ChangedAt < @changed
                    ORDER BY
                        pre.ME_VAL_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.ME_VAL_Measurement_Value
                    FROM
                        [dbo].[ME_VAL_Measurement_Value] fol
                    WHERE
                        fol.ME_VAL_ME_ID = @id
                    AND
                        fol.ME_VAL_ChangedAt > @changed
                    ORDER BY
                        fol.ME_VAL_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [dbo].[ME_VAL_Measurement_Value]
    ADD CONSTRAINT [rcME_VAL_Measurement_Value] CHECK (
        [dbo].[rfME_VAL_Measurement_Value] (
            ME_VAL_ME_ID,
            ME_VAL_Measurement_Value,
            ME_VAL_ChangedAt
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
-- kPL_Player identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kPL_Player', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kPL_Player] (
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
            INSERT INTO [dbo].[PL_Player] (
                Metadata_PL
            )
            OUTPUT
                inserted.PL_ID
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
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kME_Measurement identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kME_Measurement', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kME_Measurement] (
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
            INSERT INTO [dbo].[ME_Measurement] (
                Metadata_ME
            )
            OUTPUT
                inserted.ME_ID
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
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kST_Statistic identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kST_Statistic', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kST_Statistic] (
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
            INSERT INTO [dbo].[ST_Statistic] (
                Metadata_ST
            )
            OUTPUT
                inserted.ST_ID
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
-- rME_VAL_Measurement_Value rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rME_VAL_Measurement_Value','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rME_VAL_Measurement_Value] (
        @changingTimepoint date
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ME_VAL,
        ME_VAL_ME_ID,
        ME_VAL_Measurement_Value,
        ME_VAL_ChangedAt
    FROM
        [dbo].[ME_VAL_Measurement_Value]
    WHERE
        ME_VAL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- ANCHOR TEMPORAL BUSINESS PERSPECTIVES ------------------------------------------------------------------------------
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Player', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Player];
IF Object_ID('dbo.Current_Player', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Player];
IF Object_ID('dbo.Point_Player', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Player];
IF Object_ID('dbo.Latest_Player', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Player];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Measurement', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Measurement];
IF Object_ID('dbo.Current_Measurement', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Measurement];
IF Object_ID('dbo.Point_Measurement', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Measurement];
IF Object_ID('dbo.Latest_Measurement', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Measurement];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Statistic', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Statistic];
IF Object_ID('dbo.Current_Statistic', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Statistic];
IF Object_ID('dbo.Point_Statistic', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Statistic];
IF Object_ID('dbo.Latest_Statistic', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Statistic];
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
IF Object_ID('dbo.dPL_Player', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPL_Player];
IF Object_ID('dbo.nPL_Player', 'V') IS NOT NULL
DROP VIEW [dbo].[nPL_Player];
IF Object_ID('dbo.pPL_Player', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPL_Player];
IF Object_ID('dbo.lPL_Player', 'V') IS NOT NULL
DROP VIEW [dbo].[lPL_Player];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPL_Player viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPL_Player] WITH SCHEMABINDING AS
SELECT
    [PL].PL_ID,
    [PL].Metadata_PL,
    [NAM].PL_NAM_PL_ID,
    [NAM].Metadata_PL_NAM,
    [NAM].PL_NAM_Player_Name
FROM
    [dbo].[PL_Player] [PL]
LEFT JOIN
    [dbo].[PL_NAM_Player_Name] [NAM]
ON
    [NAM].PL_NAM_PL_ID = [PL].PL_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPL_Player viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPL_Player] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PL].PL_ID,
    [PL].Metadata_PL,
    [NAM].PL_NAM_PL_ID,
    [NAM].Metadata_PL_NAM,
    [NAM].PL_NAM_Player_Name
FROM
    [dbo].[PL_Player] [PL]
LEFT JOIN
    [dbo].[PL_NAM_Player_Name] [NAM]
ON
    [NAM].PL_NAM_PL_ID = [PL].PL_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPL_Player viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPL_Player]
AS
SELECT
    *
FROM
    [dbo].[pPL_Player](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dME_Measurement', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dME_Measurement];
IF Object_ID('dbo.nME_Measurement', 'V') IS NOT NULL
DROP VIEW [dbo].[nME_Measurement];
IF Object_ID('dbo.pME_Measurement', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pME_Measurement];
IF Object_ID('dbo.lME_Measurement', 'V') IS NOT NULL
DROP VIEW [dbo].[lME_Measurement];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lME_Measurement viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lME_Measurement] WITH SCHEMABINDING AS
SELECT
    [ME].ME_ID,
    [ME].Metadata_ME,
    [VAL].ME_VAL_ME_ID,
    [VAL].Metadata_ME_VAL,
    [VAL].ME_VAL_ChangedAt,
    [VAL].ME_VAL_Measurement_Value
FROM
    [dbo].[ME_Measurement] [ME]
LEFT JOIN
    [dbo].[ME_VAL_Measurement_Value] [VAL]
ON
    [VAL].ME_VAL_ME_ID = [ME].ME_ID
AND
    [VAL].ME_VAL_ChangedAt = (
        SELECT
            max(sub.ME_VAL_ChangedAt)
        FROM
            [dbo].[ME_VAL_Measurement_Value] sub
        WHERE
            sub.ME_VAL_ME_ID = [ME].ME_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pME_Measurement viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pME_Measurement] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ME].ME_ID,
    [ME].Metadata_ME,
    [VAL].ME_VAL_ME_ID,
    [VAL].Metadata_ME_VAL,
    [VAL].ME_VAL_ChangedAt,
    [VAL].ME_VAL_Measurement_Value
FROM
    [dbo].[ME_Measurement] [ME]
LEFT JOIN
    [dbo].[rME_VAL_Measurement_Value](@changingTimepoint) [VAL]
ON
    [VAL].ME_VAL_ME_ID = [ME].ME_ID
AND
    [VAL].ME_VAL_ChangedAt = (
        SELECT
            max(sub.ME_VAL_ChangedAt)
        FROM
            [dbo].[rME_VAL_Measurement_Value](@changingTimepoint) sub
        WHERE
            sub.ME_VAL_ME_ID = [ME].ME_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nME_Measurement viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nME_Measurement]
AS
SELECT
    *
FROM
    [dbo].[pME_Measurement](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dME_Measurement showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dME_Measurement] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pME].*
FROM (
    SELECT DISTINCT
        ME_VAL_ME_ID AS ME_ID,
        ME_VAL_ChangedAt AS inspectedTimepoint,
        'VAL' AS mnemonic
    FROM
        [dbo].[ME_VAL_Measurement_Value]
    WHERE
        (@selection is null OR @selection like '%VAL%')
    AND
        ME_VAL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[pME_Measurement](timepoints.inspectedTimepoint) [pME]
WHERE
    [pME].ME_ID = timepoints.ME_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dST_Statistic', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_Statistic];
IF Object_ID('dbo.nST_Statistic', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_Statistic];
IF Object_ID('dbo.pST_Statistic', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_Statistic];
IF Object_ID('dbo.lST_Statistic', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_Statistic];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_Statistic viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_Statistic] WITH SCHEMABINDING AS
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [DET].ST_DET_ST_ID,
    [DET].Metadata_ST_DET,
    [DET].ST_DET_Statistic_Detail,
    [GRP].ST_GRP_ST_ID,
    [GRP].Metadata_ST_GRP,
    [kGRP].SGR_StatisticGroup AS ST_GRP_SGR_StatisticGroup,
    [kGRP].Metadata_SGR AS ST_GRP_Metadata_SGR,
    [GRP].ST_GRP_SGR_ID
FROM
    [dbo].[ST_Statistic] [ST]
LEFT JOIN
    [dbo].[ST_DET_Statistic_Detail] [DET]
ON
    [DET].ST_DET_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[ST_GRP_Statistic_Group] [GRP]
ON
    [GRP].ST_GRP_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[SGR_StatisticGroup] [kGRP]
ON
    [kGRP].SGR_ID = [GRP].ST_GRP_SGR_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_Statistic viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_Statistic] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [DET].ST_DET_ST_ID,
    [DET].Metadata_ST_DET,
    [DET].ST_DET_Statistic_Detail,
    [GRP].ST_GRP_ST_ID,
    [GRP].Metadata_ST_GRP,
    [kGRP].SGR_StatisticGroup AS ST_GRP_SGR_StatisticGroup,
    [kGRP].Metadata_SGR AS ST_GRP_Metadata_SGR,
    [GRP].ST_GRP_SGR_ID
FROM
    [dbo].[ST_Statistic] [ST]
LEFT JOIN
    [dbo].[ST_DET_Statistic_Detail] [DET]
ON
    [DET].ST_DET_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[ST_GRP_Statistic_Group] [GRP]
ON
    [GRP].ST_GRP_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[SGR_StatisticGroup] [kGRP]
ON
    [kGRP].SGR_ID = [GRP].ST_GRP_SGR_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_Statistic viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_Statistic]
AS
SELECT
    *
FROM
    [dbo].[pST_Statistic](sysdatetime());
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
-- Latest_Player viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Player] AS
SELECT
    [PL].PL_ID as [Player_Id],
    [PL].PL_NAM_Player_Name as [Name]
FROM
    [dbo].[lPL_Player] [PL];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Player viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Player] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE AS RETURN
SELECT
    [PL].PL_ID as [Player_Id],
    [PL].PL_NAM_Player_Name as [Name]
FROM
    [dbo].[pPL_Player](@changingTimepoint) [PL]
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Player viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Player]
AS
SELECT
    *
FROM
    [dbo].[Point_Player](sysdatetime());
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Measurement viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Measurement] AS
SELECT
    [ME].ME_ID as [Measurement_Id],
    [ME].ME_VAL_Measurement_Value as [Value]
FROM
    [dbo].[lME_Measurement] [ME];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Measurement viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Measurement] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE AS RETURN
SELECT
    [ME].ME_ID as [Measurement_Id],
    [ME].ME_VAL_Measurement_Value as [Value]
FROM
    [dbo].[pME_Measurement](@changingTimepoint) [ME]
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Measurement viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Measurement]
AS
SELECT
    *
FROM
    [dbo].[Point_Measurement](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Measurement showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Difference_Measurement] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pME].*
FROM (
    SELECT DISTINCT
        ME_VAL_ME_ID AS ME_ID,
        ME_VAL_ChangedAt AS [Time_of_Change],
        'Value' AS [Subject_of_Change]
    FROM
        [dbo].[ME_VAL_Measurement_Value]
    WHERE
        (@selection is null OR @selection like '%VAL%')
    AND
        ME_VAL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[Point_Measurement](timepoints.[Time_of_Change]) [pME]
WHERE
    [pME].Measurement_Id = timepoints.ME_ID;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Statistic viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Statistic] AS
SELECT
    [ST].ST_ID as [Statistic_Id],
    [ST].ST_DET_Statistic_Detail as [Detail],
    [ST].ST_GRP_SGR_StatisticGroup as [Group_StatisticGroup]
FROM
    [dbo].[lST_Statistic] [ST];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Statistic viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Statistic] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE AS RETURN
SELECT
    [ST].ST_ID as [Statistic_Id],
    [ST].ST_DET_Statistic_Detail as [Detail],
    [ST].ST_GRP_SGR_StatisticGroup as [Group_StatisticGroup]
FROM
    [dbo].[pST_Statistic](@changingTimepoint) [ST]
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Statistic viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Statistic]
AS
SELECT
    *
FROM
    [dbo].[Point_Statistic](sysdatetime());
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
-- it_PL_NAM_Player_Name instead of INSERT trigger on PL_NAM_Player_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_PL_NAM_Player_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PL_NAM_Player_Name];
GO
CREATE TRIGGER [dbo].[it_PL_NAM_Player_Name] ON [dbo].[PL_NAM_Player_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @PL_NAM_Player_Name TABLE (
        PL_NAM_PL_ID int not null,
        Metadata_PL_NAM int not null,
        PL_NAM_Player_Name varchar(555) not null,
        PL_NAM_Version bigint not null,
        PL_NAM_StatementType char(1) not null,
        primary key(
            PL_NAM_Version,
            PL_NAM_PL_ID
        )
    );
    INSERT INTO @PL_NAM_Player_Name
    SELECT
        i.PL_NAM_PL_ID,
        i.Metadata_PL_NAM,
        i.PL_NAM_Player_Name,
        ROW_NUMBER() OVER (
            PARTITION BY
                i.PL_NAM_PL_ID
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
        @PL_NAM_Player_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.PL_NAM_StatementType =
                CASE
                    WHEN [NAM].PL_NAM_PL_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @PL_NAM_Player_Name v
        LEFT JOIN
            [dbo].[PL_NAM_Player_Name] [NAM]
        ON
            [NAM].PL_NAM_PL_ID = v.PL_NAM_PL_ID
        AND
            [NAM].PL_NAM_Player_Name = v.PL_NAM_Player_Name
        WHERE
            v.PL_NAM_Version = @currentVersion;
        INSERT INTO [dbo].[PL_NAM_Player_Name] (
            PL_NAM_PL_ID,
            Metadata_PL_NAM,
            PL_NAM_Player_Name
        )
        SELECT
            PL_NAM_PL_ID,
            Metadata_PL_NAM,
            PL_NAM_Player_Name
        FROM
            @PL_NAM_Player_Name
        WHERE
            PL_NAM_Version = @currentVersion
        AND
            PL_NAM_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ME_VAL_Measurement_Value instead of INSERT trigger on ME_VAL_Measurement_Value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ME_VAL_Measurement_Value', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ME_VAL_Measurement_Value];
GO
CREATE TRIGGER [dbo].[it_ME_VAL_Measurement_Value] ON [dbo].[ME_VAL_Measurement_Value]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ME_VAL_Measurement_Value TABLE (
        ME_VAL_ME_ID int not null,
        Metadata_ME_VAL int not null,
        ME_VAL_ChangedAt date not null,
        ME_VAL_Measurement_Value varchar(555) not null,
        ME_VAL_Version bigint not null,
        ME_VAL_StatementType char(1) not null,
        primary key(
            ME_VAL_Version,
            ME_VAL_ME_ID
        )
    );
    INSERT INTO @ME_VAL_Measurement_Value
    SELECT
        i.ME_VAL_ME_ID,
        i.Metadata_ME_VAL,
        i.ME_VAL_ChangedAt,
        i.ME_VAL_Measurement_Value,
        DENSE_RANK() OVER (
            PARTITION BY
                i.ME_VAL_ME_ID
            ORDER BY
                i.ME_VAL_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(ME_VAL_Version), 
        @currentVersion = 0
    FROM
        @ME_VAL_Measurement_Value;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.ME_VAL_StatementType =
                CASE
                    WHEN [VAL].ME_VAL_ME_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [dbo].[rfME_VAL_Measurement_Value]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.ME_VAL_Measurement_Value = (
                                SELECT TOP 1
                                    pre.ME_VAL_Measurement_Value
                                FROM
                                    [dbo].[ME_VAL_Measurement_Value] pre
                                WHERE
                                    pre.ME_VAL_ME_ID = v.ME_VAL_ME_ID
                                AND
                                    pre.ME_VAL_ChangedAt < v.ME_VAL_ChangedAt
                                ORDER BY
                                    pre.ME_VAL_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.ME_VAL_Measurement_Value = (
                                SELECT TOP 1
                                    fol.ME_VAL_Measurement_Value
                                FROM
                                    [dbo].[ME_VAL_Measurement_Value] fol
                                WHERE
                                    fol.ME_VAL_ME_ID = v.ME_VAL_ME_ID
                                AND
                                    fol.ME_VAL_ChangedAt > v.ME_VAL_ChangedAt
                                ORDER BY
                                    fol.ME_VAL_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @ME_VAL_Measurement_Value v
        LEFT JOIN
            [dbo].[ME_VAL_Measurement_Value] [VAL]
        ON
            [VAL].ME_VAL_ME_ID = v.ME_VAL_ME_ID
        AND
            [VAL].ME_VAL_ChangedAt = v.ME_VAL_ChangedAt
        AND
            [VAL].ME_VAL_Measurement_Value = v.ME_VAL_Measurement_Value
        WHERE
            v.ME_VAL_Version = @currentVersion;
        INSERT INTO [dbo].[ME_VAL_Measurement_Value] (
            ME_VAL_ME_ID,
            Metadata_ME_VAL,
            ME_VAL_ChangedAt,
            ME_VAL_Measurement_Value
        )
        SELECT
            ME_VAL_ME_ID,
            Metadata_ME_VAL,
            ME_VAL_ChangedAt,
            ME_VAL_Measurement_Value
        FROM
            @ME_VAL_Measurement_Value
        WHERE
            ME_VAL_Version = @currentVersion
        AND
            ME_VAL_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_DET_Statistic_Detail instead of INSERT trigger on ST_DET_Statistic_Detail
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_DET_Statistic_Detail', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_DET_Statistic_Detail];
GO
CREATE TRIGGER [dbo].[it_ST_DET_Statistic_Detail] ON [dbo].[ST_DET_Statistic_Detail]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_DET_Statistic_Detail TABLE (
        ST_DET_ST_ID int not null,
        Metadata_ST_DET int not null,
        ST_DET_Statistic_Detail varchar(555) not null,
        ST_DET_Version bigint not null,
        ST_DET_StatementType char(1) not null,
        primary key(
            ST_DET_Version,
            ST_DET_ST_ID
        )
    );
    INSERT INTO @ST_DET_Statistic_Detail
    SELECT
        i.ST_DET_ST_ID,
        i.Metadata_ST_DET,
        i.ST_DET_Statistic_Detail,
        ROW_NUMBER() OVER (
            PARTITION BY
                i.ST_DET_ST_ID
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
        @ST_DET_Statistic_Detail;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.ST_DET_StatementType =
                CASE
                    WHEN [DET].ST_DET_ST_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_DET_Statistic_Detail v
        LEFT JOIN
            [dbo].[ST_DET_Statistic_Detail] [DET]
        ON
            [DET].ST_DET_ST_ID = v.ST_DET_ST_ID
        AND
            [DET].ST_DET_Statistic_Detail = v.ST_DET_Statistic_Detail
        WHERE
            v.ST_DET_Version = @currentVersion;
        INSERT INTO [dbo].[ST_DET_Statistic_Detail] (
            ST_DET_ST_ID,
            Metadata_ST_DET,
            ST_DET_Statistic_Detail
        )
        SELECT
            ST_DET_ST_ID,
            Metadata_ST_DET,
            ST_DET_Statistic_Detail
        FROM
            @ST_DET_Statistic_Detail
        WHERE
            ST_DET_Version = @currentVersion
        AND
            ST_DET_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_GRP_Statistic_Group instead of INSERT trigger on ST_GRP_Statistic_Group
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_GRP_Statistic_Group', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_GRP_Statistic_Group];
GO
CREATE TRIGGER [dbo].[it_ST_GRP_Statistic_Group] ON [dbo].[ST_GRP_Statistic_Group]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_GRP_Statistic_Group TABLE (
        ST_GRP_ST_ID int not null,
        Metadata_ST_GRP int not null,
        ST_GRP_SGR_ID smallint not null, 
        ST_GRP_Version bigint not null,
        ST_GRP_StatementType char(1) not null,
        primary key(
            ST_GRP_Version,
            ST_GRP_ST_ID
        )
    );
    INSERT INTO @ST_GRP_Statistic_Group
    SELECT
        i.ST_GRP_ST_ID,
        i.Metadata_ST_GRP,
        i.ST_GRP_SGR_ID,
        ROW_NUMBER() OVER (
            PARTITION BY
                i.ST_GRP_ST_ID
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
        @ST_GRP_Statistic_Group;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.ST_GRP_StatementType =
                CASE
                    WHEN [GRP].ST_GRP_ST_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_GRP_Statistic_Group v
        LEFT JOIN
            [dbo].[ST_GRP_Statistic_Group] [GRP]
        ON
            [GRP].ST_GRP_ST_ID = v.ST_GRP_ST_ID
        AND
            [GRP].ST_GRP_SGR_ID = v.ST_GRP_SGR_ID
        WHERE
            v.ST_GRP_Version = @currentVersion;
        INSERT INTO [dbo].[ST_GRP_Statistic_Group] (
            ST_GRP_ST_ID,
            Metadata_ST_GRP,
            ST_GRP_SGR_ID
        )
        SELECT
            ST_GRP_ST_ID,
            Metadata_ST_GRP,
            ST_GRP_SGR_ID
        FROM
            @ST_GRP_Statistic_Group
        WHERE
            ST_GRP_Version = @currentVersion
        AND
            ST_GRP_StatementType in ('N');
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
-- it_lPL_Player instead of INSERT trigger on lPL_Player
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPL_Player] ON [dbo].[lPL_Player]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @PL TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        PL_ID int not null
    );
    INSERT INTO [dbo].[PL_Player] (
        Metadata_PL 
    )
    OUTPUT
        inserted.PL_ID
    INTO
        @PL
    SELECT
        Metadata_PL 
    FROM
        inserted
    WHERE
        inserted.PL_ID is null;
    DECLARE @inserted TABLE (
        PL_ID int not null,
        Metadata_PL int not null,
        PL_NAM_PL_ID int null,
        Metadata_PL_NAM int null,
        PL_NAM_Player_Name varchar(555) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.PL_ID, a.PL_ID),
        i.Metadata_PL,
        ISNULL(ISNULL(i.PL_NAM_PL_ID, i.PL_ID), a.PL_ID),
        ISNULL(i.Metadata_PL_NAM, i.Metadata_PL),
        i.PL_NAM_Player_Name
    FROM (
        SELECT
            PL_ID,
            Metadata_PL,
            PL_NAM_PL_ID,
            Metadata_PL_NAM,
            PL_NAM_Player_Name,
            ROW_NUMBER() OVER (PARTITION BY PL_ID ORDER BY PL_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @PL a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[PL_NAM_Player_Name] (
        Metadata_PL_NAM,
        PL_NAM_PL_ID,
        PL_NAM_Player_Name
    )
    SELECT
        i.Metadata_PL_NAM,
        i.PL_NAM_PL_ID,
        i.PL_NAM_Player_Name
    FROM
        @inserted i
    WHERE
        i.PL_NAM_Player_Name is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPL_Player instead of UPDATE trigger on lPL_Player
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lPL_Player] ON [dbo].[lPL_Player]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(PL_ID))
        RAISERROR('The identity column PL_ID is not updatable.', 16, 1);
    IF(UPDATE(PL_NAM_PL_ID))
        RAISERROR('The foreign key column PL_NAM_PL_ID is not updatable.', 16, 1);
    IF (UPDATE(PL_NAM_Player_Name))
        RAISERROR('The static column PL_NAM_Player_Name is not updatable, and only missing values have been added.', 0, 1);
    IF(UPDATE(PL_NAM_Player_Name))
    BEGIN
        INSERT INTO [dbo].[PL_NAM_Player_Name] (
            Metadata_PL_NAM,
            PL_NAM_PL_ID,
            PL_NAM_Player_Name
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_PL) AND NOT UPDATE(Metadata_PL_NAM)
                THEN i.Metadata_PL
                ELSE i.Metadata_PL_NAM
            END, i.Metadata_PL),
            ISNULL(i.PL_NAM_PL_ID, i.PL_ID),
            i.PL_NAM_Player_Name
        FROM
            inserted i
        WHERE
            i.PL_NAM_Player_Name is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPL_Player instead of DELETE trigger on lPL_Player
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPL_Player] ON [dbo].[lPL_Player]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [dbo].[PL_NAM_Player_Name] [NAM]
    JOIN
        deleted d
    ON
        d.PL_NAM_PL_ID = [NAM].PL_NAM_PL_ID;
    DELETE [PL]
    FROM
        [dbo].[PL_Player] [PL]
    LEFT JOIN
        [dbo].[PL_NAM_Player_Name] [NAM]
    ON
        [NAM].PL_NAM_PL_ID = [PL].PL_ID
    WHERE
        [NAM].PL_NAM_PL_ID is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lME_Measurement instead of INSERT trigger on lME_Measurement
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lME_Measurement] ON [dbo].[lME_Measurement]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @ME TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        ME_ID int not null
    );
    INSERT INTO [dbo].[ME_Measurement] (
        Metadata_ME 
    )
    OUTPUT
        inserted.ME_ID
    INTO
        @ME
    SELECT
        Metadata_ME 
    FROM
        inserted
    WHERE
        inserted.ME_ID is null;
    DECLARE @inserted TABLE (
        ME_ID int not null,
        Metadata_ME int not null,
        ME_VAL_ME_ID int null,
        Metadata_ME_VAL int null,
        ME_VAL_ChangedAt date null,
        ME_VAL_Measurement_Value varchar(555) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.ME_ID, a.ME_ID),
        i.Metadata_ME,
        ISNULL(ISNULL(i.ME_VAL_ME_ID, i.ME_ID), a.ME_ID),
        ISNULL(i.Metadata_ME_VAL, i.Metadata_ME),
        ISNULL(i.ME_VAL_ChangedAt, @now),
        i.ME_VAL_Measurement_Value
    FROM (
        SELECT
            ME_ID,
            Metadata_ME,
            ME_VAL_ME_ID,
            Metadata_ME_VAL,
            ME_VAL_ChangedAt,
            ME_VAL_Measurement_Value,
            ROW_NUMBER() OVER (PARTITION BY ME_ID ORDER BY ME_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @ME a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[ME_VAL_Measurement_Value] (
        Metadata_ME_VAL,
        ME_VAL_ME_ID,
        ME_VAL_ChangedAt,
        ME_VAL_Measurement_Value
    )
    SELECT
        i.Metadata_ME_VAL,
        i.ME_VAL_ME_ID,
        i.ME_VAL_ChangedAt,
        i.ME_VAL_Measurement_Value
    FROM
        @inserted i
    WHERE
        i.ME_VAL_Measurement_Value is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lME_Measurement instead of UPDATE trigger on lME_Measurement
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lME_Measurement] ON [dbo].[lME_Measurement]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(ME_ID))
        RAISERROR('The identity column ME_ID is not updatable.', 16, 1);
    IF(UPDATE(ME_VAL_ME_ID))
        RAISERROR('The foreign key column ME_VAL_ME_ID is not updatable.', 16, 1);
    IF(UPDATE(ME_VAL_Measurement_Value))
    BEGIN
        INSERT INTO [dbo].[ME_VAL_Measurement_Value] (
            Metadata_ME_VAL,
            ME_VAL_ME_ID,
            ME_VAL_ChangedAt,
            ME_VAL_Measurement_Value
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_ME) AND NOT UPDATE(Metadata_ME_VAL)
                THEN i.Metadata_ME
                ELSE i.Metadata_ME_VAL
            END, i.Metadata_ME),
            ISNULL(i.ME_VAL_ME_ID, i.ME_ID),
            cast(ISNULL(CASE
                WHEN i.ME_VAL_Measurement_Value is null THEN i.ME_VAL_ChangedAt
                WHEN UPDATE(ME_VAL_ChangedAt) THEN i.ME_VAL_ChangedAt
            END, @now) as date),
            i.ME_VAL_Measurement_Value
        FROM
            inserted i
        WHERE
            i.ME_VAL_Measurement_Value is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lME_Measurement instead of DELETE trigger on lME_Measurement
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lME_Measurement] ON [dbo].[lME_Measurement]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [VAL]
    FROM
        [dbo].[ME_VAL_Measurement_Value] [VAL]
    JOIN
        deleted d
    ON
        d.ME_VAL_ChangedAt = [VAL].ME_VAL_ChangedAt
    AND
        d.ME_VAL_ME_ID = [VAL].ME_VAL_ME_ID;
    DELETE [ME]
    FROM
        [dbo].[ME_Measurement] [ME]
    LEFT JOIN
        [dbo].[ME_VAL_Measurement_Value] [VAL]
    ON
        [VAL].ME_VAL_ME_ID = [ME].ME_ID
    WHERE
        [VAL].ME_VAL_ME_ID is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_Statistic instead of INSERT trigger on lST_Statistic
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lST_Statistic] ON [dbo].[lST_Statistic]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @ST TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        ST_ID int not null
    );
    INSERT INTO [dbo].[ST_Statistic] (
        Metadata_ST 
    )
    OUTPUT
        inserted.ST_ID
    INTO
        @ST
    SELECT
        Metadata_ST 
    FROM
        inserted
    WHERE
        inserted.ST_ID is null;
    DECLARE @inserted TABLE (
        ST_ID int not null,
        Metadata_ST int not null,
        ST_DET_ST_ID int null,
        Metadata_ST_DET int null,
        ST_DET_Statistic_Detail varchar(555) null,
        ST_GRP_ST_ID int null,
        Metadata_ST_GRP int null,
        ST_GRP_SGR_StatisticGroup varchar(555) null,
        ST_GRP_Metadata_SGR int null,
        ST_GRP_SGR_ID smallint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.ST_ID, a.ST_ID),
        i.Metadata_ST,
        ISNULL(ISNULL(i.ST_DET_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_DET, i.Metadata_ST),
        i.ST_DET_Statistic_Detail,
        ISNULL(ISNULL(i.ST_GRP_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_GRP, i.Metadata_ST),
        i.ST_GRP_SGR_StatisticGroup,
        ISNULL(i.ST_GRP_Metadata_SGR, i.Metadata_ST),
        i.ST_GRP_SGR_ID
    FROM (
        SELECT
            ST_ID,
            Metadata_ST,
            ST_DET_ST_ID,
            Metadata_ST_DET,
            ST_DET_Statistic_Detail,
            ST_GRP_ST_ID,
            Metadata_ST_GRP,
            ST_GRP_SGR_StatisticGroup,
            ST_GRP_Metadata_SGR,
            ST_GRP_SGR_ID,
            ROW_NUMBER() OVER (PARTITION BY ST_ID ORDER BY ST_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @ST a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[ST_DET_Statistic_Detail] (
        Metadata_ST_DET,
        ST_DET_ST_ID,
        ST_DET_Statistic_Detail
    )
    SELECT
        i.Metadata_ST_DET,
        i.ST_DET_ST_ID,
        i.ST_DET_Statistic_Detail
    FROM
        @inserted i
    WHERE
        i.ST_DET_Statistic_Detail is not null;
    INSERT INTO [dbo].[ST_GRP_Statistic_Group] (
        Metadata_ST_GRP,
        ST_GRP_ST_ID,
        ST_GRP_SGR_ID
    )
    SELECT
        i.Metadata_ST_GRP,
        i.ST_GRP_ST_ID,
        ISNULL(i.ST_GRP_SGR_ID, [kSGR].SGR_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[SGR_StatisticGroup] [kSGR]
    ON
        [kSGR].SGR_StatisticGroup = i.ST_GRP_SGR_StatisticGroup
    WHERE
        ISNULL(i.ST_GRP_SGR_ID, [kSGR].SGR_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Statistic instead of UPDATE trigger on lST_Statistic
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lST_Statistic] ON [dbo].[lST_Statistic]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(ST_ID))
        RAISERROR('The identity column ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_DET_ST_ID))
        RAISERROR('The foreign key column ST_DET_ST_ID is not updatable.', 16, 1);
    IF (UPDATE(ST_DET_Statistic_Detail))
        RAISERROR('The static column ST_DET_Statistic_Detail is not updatable, and only missing values have been added.', 0, 1);
    IF(UPDATE(ST_DET_Statistic_Detail))
    BEGIN
        INSERT INTO [dbo].[ST_DET_Statistic_Detail] (
            Metadata_ST_DET,
            ST_DET_ST_ID,
            ST_DET_Statistic_Detail
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_ST) AND NOT UPDATE(Metadata_ST_DET)
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_DET
            END, i.Metadata_ST),
            ISNULL(i.ST_DET_ST_ID, i.ST_ID),
            i.ST_DET_Statistic_Detail
        FROM
            inserted i
        WHERE
            i.ST_DET_Statistic_Detail is not null;
    END
    IF(UPDATE(ST_GRP_ST_ID))
        RAISERROR('The foreign key column ST_GRP_ST_ID is not updatable.', 16, 1);
    IF (UPDATE(ST_GRP_SGR_ID))
        RAISERROR('The static column ST_GRP_SGR_ID is not updatable, and only missing values have been added.', 0, 1);
    IF (UPDATE(ST_GRP_SGR_StatisticGroup))
        RAISERROR('The static column ST_GRP_SGR_StatisticGroup is not updatable, and only missing values have been added.', 0, 1);
    IF(UPDATE(ST_GRP_SGR_ID) OR UPDATE(ST_GRP_SGR_StatisticGroup))
    BEGIN
        INSERT INTO [dbo].[ST_GRP_Statistic_Group] (
            Metadata_ST_GRP,
            ST_GRP_ST_ID,
            ST_GRP_SGR_ID
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_ST) AND NOT UPDATE(Metadata_ST_GRP)
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_GRP
            END, i.Metadata_ST),
            ISNULL(i.ST_GRP_ST_ID, i.ST_ID),
            CASE WHEN UPDATE(ST_GRP_SGR_ID) THEN i.ST_GRP_SGR_ID ELSE [kSGR].SGR_ID END
        FROM
            inserted i
        LEFT JOIN
            [dbo].[SGR_StatisticGroup] [kSGR]
        ON
            [kSGR].SGR_StatisticGroup = i.ST_GRP_SGR_StatisticGroup
        WHERE
            CASE WHEN UPDATE(ST_GRP_SGR_ID) THEN i.ST_GRP_SGR_ID ELSE [kSGR].SGR_ID END is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Statistic instead of DELETE trigger on lST_Statistic
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lST_Statistic] ON [dbo].[lST_Statistic]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [DET]
    FROM
        [dbo].[ST_DET_Statistic_Detail] [DET]
    JOIN
        deleted d
    ON
        d.ST_DET_ST_ID = [DET].ST_DET_ST_ID;
    DELETE [GRP]
    FROM
        [dbo].[ST_GRP_Statistic_Group] [GRP]
    JOIN
        deleted d
    ON
        d.ST_GRP_ST_ID = [GRP].ST_GRP_ST_ID;
    DELETE [ST]
    FROM
        [dbo].[ST_Statistic] [ST]
    LEFT JOIN
        [dbo].[ST_DET_Statistic_Detail] [DET]
    ON
        [DET].ST_DET_ST_ID = [ST].ST_ID
    LEFT JOIN
        [dbo].[ST_GRP_Statistic_Group] [GRP]
    ON
        [GRP].ST_GRP_ST_ID = [ST].ST_ID
    WHERE
        [DET].ST_DET_ST_ID is null
    AND
        [GRP].ST_GRP_ST_ID is null;
END
GO
-- TIE TEMPORAL BUSINESS PERSPECTIVES ---------------------------------------------------------------------------------
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Player_was_Measurement_measured', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Player_was_Measurement_measured];
IF Object_ID('dbo.Current_Player_was_Measurement_measured', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Player_was_Measurement_measured];
IF Object_ID('dbo.Point_Player_was_Measurement_measured', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Player_was_Measurement_measured];
IF Object_ID('dbo.Latest_Player_was_Measurement_measured', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Player_was_Measurement_measured];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Measurement_for_Statistic_the', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Measurement_for_Statistic_the];
IF Object_ID('dbo.Current_Measurement_for_Statistic_the', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Measurement_for_Statistic_the];
IF Object_ID('dbo.Point_Measurement_for_Statistic_the', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Measurement_for_Statistic_the];
IF Object_ID('dbo.Latest_Measurement_for_Statistic_the', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Measurement_for_Statistic_the];
GO
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
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPL_was_ME_measured', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPL_was_ME_measured];
IF Object_ID('dbo.nPL_was_ME_measured', 'V') IS NOT NULL
DROP VIEW [dbo].[nPL_was_ME_measured];
IF Object_ID('dbo.pPL_was_ME_measured', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPL_was_ME_measured];
IF Object_ID('dbo.lPL_was_ME_measured', 'V') IS NOT NULL
DROP VIEW [dbo].[lPL_was_ME_measured];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPL_was_ME_measured viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPL_was_ME_measured] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_PL_was_ME_measured,
    tie.PL_ID_was,
    tie.ME_ID_measured
FROM
    [dbo].[PL_was_ME_measured] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPL_was_ME_measured viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPL_was_ME_measured] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_PL_was_ME_measured,
    tie.PL_ID_was,
    tie.ME_ID_measured
FROM
    [dbo].[PL_was_ME_measured] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPL_was_ME_measured viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPL_was_ME_measured]
AS
SELECT
    *
FROM
    [dbo].[pPL_was_ME_measured](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dME_for_ST_the', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dME_for_ST_the];
IF Object_ID('dbo.nME_for_ST_the', 'V') IS NOT NULL
DROP VIEW [dbo].[nME_for_ST_the];
IF Object_ID('dbo.pME_for_ST_the', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pME_for_ST_the];
IF Object_ID('dbo.lME_for_ST_the', 'V') IS NOT NULL
DROP VIEW [dbo].[lME_for_ST_the];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lME_for_ST_the viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lME_for_ST_the] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_ME_for_ST_the,
    tie.ME_ID_for,
    tie.ST_ID_the
FROM
    [dbo].[ME_for_ST_the] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pME_for_ST_the viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pME_for_ST_the] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_ME_for_ST_the,
    tie.ME_ID_for,
    tie.ST_ID_the
FROM
    [dbo].[ME_for_ST_the] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nME_for_ST_the viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nME_for_ST_the]
AS
SELECT
    *
FROM
    [dbo].[pME_for_ST_the](sysdatetime());
GO
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
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Player_was_Measurement_measured viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Player_was_Measurement_measured] AS
SELECT
    tie.PL_ID_was as [Player_was_Id],
    tie.ME_ID_measured as [Measurement_measured_Id]
FROM
    [dbo].[lPL_was_ME_measured] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Player_was_Measurement_measured viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Player_was_Measurement_measured] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE AS RETURN
SELECT
    tie.PL_ID_was as [Player_was_Id],
    tie.ME_ID_measured as [Measurement_measured_Id]
FROM
    [dbo].[pPL_was_ME_measured](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Player_was_Measurement_measured viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Player_was_Measurement_measured]
AS
SELECT
    *
FROM
    [dbo].[Point_Player_was_Measurement_measured](sysdatetime());
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Measurement_for_Statistic_the viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Measurement_for_Statistic_the] AS
SELECT
    tie.ME_ID_for as [Measurement_for_Id],
    tie.ST_ID_the as [Statistic_the_Id]
FROM
    [dbo].[lME_for_ST_the] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Measurement_for_Statistic_the viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Measurement_for_Statistic_the] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE AS RETURN
SELECT
    tie.ME_ID_for as [Measurement_for_Id],
    tie.ST_ID_the as [Statistic_the_Id]
FROM
    [dbo].[pME_for_ST_the](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Measurement_for_Statistic_the viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Measurement_for_Statistic_the]
AS
SELECT
    *
FROM
    [dbo].[Point_Measurement_for_Statistic_the](sysdatetime());
GO
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
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PL_was_ME_measured instead of INSERT trigger on PL_was_ME_measured
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_PL_was_ME_measured', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PL_was_ME_measured];
GO
CREATE TRIGGER [dbo].[it_PL_was_ME_measured] ON [dbo].[PL_was_ME_measured]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_PL_was_ME_measured int not null,
        PL_ID_was int not null,
        ME_ID_measured int not null,
        primary key (
            PL_ID_was,
            ME_ID_measured
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_PL_was_ME_measured, 0),
        i.PL_ID_was,
        i.ME_ID_measured
    FROM
        inserted i
    WHERE
        i.PL_ID_was is not null
    AND
        i.ME_ID_measured is not null;
    INSERT INTO [dbo].[PL_was_ME_measured] (
        Metadata_PL_was_ME_measured,
        PL_ID_was,
        ME_ID_measured
    )
    SELECT
        i.Metadata_PL_was_ME_measured,
        i.PL_ID_was,
        i.ME_ID_measured
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[PL_was_ME_measured] tie
    ON
        tie.PL_ID_was = i.PL_ID_was
    AND
        tie.ME_ID_measured = i.ME_ID_measured
    WHERE
        tie.ME_ID_measured is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPL_was_ME_measured instead of INSERT trigger on lPL_was_ME_measured
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPL_was_ME_measured] ON [dbo].[lPL_was_ME_measured]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PL_was_ME_measured] (
        Metadata_PL_was_ME_measured,
        PL_ID_was,
        ME_ID_measured
    )
    SELECT
        i.Metadata_PL_was_ME_measured,
        i.PL_ID_was,
        i.ME_ID_measured
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPL_was_ME_measured instead of DELETE trigger on lPL_was_ME_measured
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPL_was_ME_measured] ON [dbo].[lPL_was_ME_measured]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[PL_was_ME_measured] tie
    JOIN
        deleted d
    ON
        d.PL_ID_was = tie.PL_ID_was
    AND
        d.ME_ID_measured = tie.ME_ID_measured;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ME_for_ST_the instead of INSERT trigger on ME_for_ST_the
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ME_for_ST_the', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ME_for_ST_the];
GO
CREATE TRIGGER [dbo].[it_ME_for_ST_the] ON [dbo].[ME_for_ST_the]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_ME_for_ST_the int not null,
        ME_ID_for int not null,
        ST_ID_the int not null,
        primary key (
            ME_ID_for,
            ST_ID_the
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_ME_for_ST_the, 0),
        i.ME_ID_for,
        i.ST_ID_the
    FROM
        inserted i
    WHERE
        i.ME_ID_for is not null
    AND
        i.ST_ID_the is not null;
    INSERT INTO [dbo].[ME_for_ST_the] (
        Metadata_ME_for_ST_the,
        ME_ID_for,
        ST_ID_the
    )
    SELECT
        i.Metadata_ME_for_ST_the,
        i.ME_ID_for,
        i.ST_ID_the
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[ME_for_ST_the] tie
    ON
        tie.ME_ID_for = i.ME_ID_for
    AND
        tie.ST_ID_the = i.ST_ID_the
    WHERE
        tie.ST_ID_the is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lME_for_ST_the instead of INSERT trigger on lME_for_ST_the
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lME_for_ST_the] ON [dbo].[lME_for_ST_the]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[ME_for_ST_the] (
        Metadata_ME_for_ST_the,
        ME_ID_for,
        ST_ID_the
    )
    SELECT
        i.Metadata_ME_for_ST_the,
        i.ME_ID_for,
        i.ST_ID_the
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lME_for_ST_the instead of DELETE trigger on lME_for_ST_the
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lME_for_ST_the] ON [dbo].[lME_for_ST_the]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[ME_for_ST_the] tie
    JOIN
        deleted d
    ON
        d.ME_ID_for = tie.ME_ID_for
    AND
        d.ST_ID_the = tie.ST_ID_the;
END
GO
-- SCHEMA EVOLUTION ---------------------------------------------------------------------------------------------------
--
-- The following tables, views, and functions are used to track schema changes
-- over time, as well as providing every XML that has been 'executed' against
-- the database.
--
-- Schema table -------------------------------------------------------------------------------------------------------
-- The schema table holds every xml that has been executed against the database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Schema', 'U') IS NULL
   CREATE TABLE [dbo].[_Schema] (
      [version] int identity(1, 1) not null,
      [activation] datetime2(7) not null,
      [schema] xml not null,
      constraint pk_Schema primary key (
         [version]
      )
   );
GO
-- Insert the XML schema (as of now)
INSERT INTO [dbo].[_Schema] (
   [activation],
   [schema]
)
SELECT
   current_timestamp,
   N'<schema format="0.99.1" date="2020-03-20" time="08:12:27"><metadata changingRange="datetime" encapsulation="dbo" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="true" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="decimal(5,2)" reliabilitySuffix="Reliability" deleteReliability="0" assertionSuffix="Assertion" partitioning="false" entityIntegrity="true" restatability="true" idempotency="false" assertiveness="true" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2(7)" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="true" decisiveness="true" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="uni" deletability="false" deletablePrefix="Deletable" deletionSuffix="Deleted" privacy="Ignore"/><knot mnemonic="SGR" descriptor="StatisticGroup" identity="smallint" dataRange="varchar(555)"><metadata capsule="dbo" generator="true"/><layout x="1067.87" y="619.48" fixed="false"/></knot><anchor mnemonic="PL" descriptor="Player" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(555)"><metadata privacy="Ignore" capsule="dbo" deletable="false"/><layout x="1194.94" y="151.87" fixed="false"/></attribute><layout x="1157.46" y="206.72" fixed="false"/></anchor><anchor mnemonic="ME" descriptor="Measurement" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="VAL" descriptor="Value" timeRange="date" dataRange="varchar(555)"><metadata privacy="Ignore" capsule="dbo" restatable="false" idempotent="true" deletable="false"/><layout x="942.28" y="318.62" fixed="false"/></attribute><layout x="1043.46" y="351.93" fixed="false"/></anchor><anchor mnemonic="ST" descriptor="Statistic" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="DET" descriptor="Detail" dataRange="varchar(555)"><metadata privacy="Ignore" capsule="dbo" deletable="false"/><layout x="1182.94" y="502.38" fixed="false"/></attribute><attribute mnemonic="GRP" descriptor="Group" knotRange="SGR"><metadata privacy="Ignore" capsule="dbo" deletable="false"/><layout x="1088.52" y="547.32" fixed="false"/></attribute><layout x="1104.69" y="486.71" fixed="false"/></anchor><tie><anchorRole role="was" type="PL" identifier="true"/><anchorRole role="measured" type="ME" identifier="true"/><metadata capsule="dbo" deletable="false"/><layout x="1104.12" y="273.31" fixed="false"/></tie><tie><anchorRole role="for" type="ME" identifier="true"/><anchorRole role="the" type="ST" identifier="true"/><metadata capsule="dbo" deletable="false"/><layout x="1056.40" y="436.89" fixed="false"/></tie></schema>';
GO
-- Schema expanded view -----------------------------------------------------------------------------------------------
-- A view of the schema table that expands the XML attributes into columns
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Schema_Expanded', 'V') IS NOT NULL
DROP VIEW [dbo].[_Schema_Expanded]
GO
CREATE VIEW [dbo].[_Schema_Expanded]
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
IF Object_ID('dbo._Anchor', 'V') IS NOT NULL
DROP VIEW [dbo].[_Anchor]
GO
CREATE VIEW [dbo].[_Anchor]
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
   Nodeset.anchor.value('count(attribute)', 'int') as [numberOfAttributes]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as Nodeset(anchor);
GO
-- Knot view ----------------------------------------------------------------------------------------------------------
-- The knot view shows information about all the knots in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Knot', 'V') IS NOT NULL
DROP VIEW [dbo].[_Knot]
GO
CREATE VIEW [dbo].[_Knot]
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
   isnull(Nodeset.knot.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/knot') as Nodeset(knot);
GO
-- Attribute view -----------------------------------------------------------------------------------------------------
-- The attribute view shows information about all the attributes in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Attribute', 'V') IS NOT NULL
DROP VIEW [dbo].[_Attribute]
GO
CREATE VIEW [dbo].[_Attribute]
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
   isnull(Nodeset.attribute.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   Nodeset.attribute.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.attribute.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   ParentNodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [anchorMnemonic],
   ParentNodeset.anchor.value('@descriptor', 'nvarchar(max)') as [anchorDescriptor],
   ParentNodeset.anchor.value('@identity', 'nvarchar(max)') as [anchorIdentity],
   Nodeset.attribute.value('@dataRange', 'nvarchar(max)') as [dataRange],
   Nodeset.attribute.value('@knotRange', 'nvarchar(max)') as [knotRange],
   Nodeset.attribute.value('@timeRange', 'nvarchar(max)') as [timeRange]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as ParentNodeset(anchor)
OUTER APPLY
   ParentNodeset.anchor.nodes('attribute') as Nodeset(attribute);
GO
-- Tie view -----------------------------------------------------------------------------------------------------------
-- The tie view shows information about all the ties in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Tie', 'V') IS NOT NULL
DROP VIEW [dbo].[_Tie]
GO
CREATE VIEW [dbo].[_Tie]
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
   Nodeset.tie.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/tie') as Nodeset(tie);
GO
-- Evolution function -------------------------------------------------------------------------------------------------
-- The evolution function shows what the schema looked like at the given
-- point in time with additional information about missing or added
-- modeling components since that time.
--
-- @timepoint The point in time to which you would like to travel.
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Evolution', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[_Evolution];
GO
CREATE FUNCTION [dbo].[_Evolution] (
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
      [dbo].[_Anchor] a
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
      [dbo].[_Knot] k
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
      [dbo].[_Attribute] b
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
      [dbo].[_Tie] t
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '_Annex'), ('crt', '_Posit')
   ) s (temporalization, suffix)
), 
selectedSchema AS (
   SELECT TOP 1
      *
   FROM
      [dbo].[_Schema_Expanded]
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
IF Object_ID('dbo._GenerateDropScript', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[_GenerateDropScript];
GO
CREATE PROCEDURE [dbo]._GenerateDropScript (
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
         [dbo]._Attribute
      union all
      select distinct
         11 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Annex]' as qualifiedName
      from
         [dbo]._Attribute
      union all
      select distinct
         12 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Posit]' as qualifiedName
      from
         [dbo]._Attribute
      union all
      select distinct
         20 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [dbo]._Tie
      union all
      select distinct
         21 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Annex]' as qualifiedName
      from
         [dbo]._Tie
      union all
      select distinct
         22 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + '_Posit]' as qualifiedName
      from
         [dbo]._Tie
      union all
      select distinct
         30 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [dbo]._Knot
      union all
      select distinct
         40 as ordinal,
         name as unqualifiedName,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [dbo]._Anchor
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
IF Object_ID('dbo._GenerateCopyScript', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[_GenerateCopyScript];
GO
CREATE PROCEDURE [dbo]._GenerateCopyScript (
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
IF Object_ID('dbo._DeleteWhereMetadataEquals', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[_DeleteWhereMetadataEquals];
GO
CREATE PROCEDURE [dbo]._DeleteWhereMetadataEquals (
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