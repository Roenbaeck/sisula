-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
--
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
-- ST_Street table (with 1 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Street', 'U') IS NULL
CREATE TABLE [dbo].[ST_Street] (
    ST_ID int IDENTITY(1,1) not null,
    Metadata_ST int not null, 
    constraint pkST_Street primary key (
        ST_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_NAM_Street_Name table (on ST_Street)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_NAM_Street_Name', 'U') IS NULL
CREATE TABLE [dbo].[ST_NAM_Street_Name] (
    ST_NAM_ST_ID int not null,
    ST_NAM_Street_Name varchar(555) not null,
    Metadata_ST_NAM int not null,
    constraint fkST_NAM_Street_Name foreign key (
        ST_NAM_ST_ID
    ) references [dbo].[ST_Street](ST_ID),
    constraint pkST_NAM_Street_Name primary key (
        ST_NAM_ST_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- IS_Intersection table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.IS_Intersection', 'U') IS NULL
CREATE TABLE [dbo].[IS_Intersection] (
    IS_ID int IDENTITY(1,1) not null,
    Metadata_IS int not null, 
    constraint pkIS_Intersection primary key (
        IS_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- IS_COL_Intersection_CollisionCount table (on IS_Intersection)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.IS_COL_Intersection_CollisionCount', 'U') IS NULL
CREATE TABLE [dbo].[IS_COL_Intersection_CollisionCount] (
    IS_COL_IS_ID int not null,
    IS_COL_Intersection_CollisionCount int not null,
    IS_COL_ChangedAt date not null,
    Metadata_IS_COL int not null,
    constraint fkIS_COL_Intersection_CollisionCount foreign key (
        IS_COL_IS_ID
    ) references [dbo].[IS_Intersection](IS_ID),
    constraint pkIS_COL_Intersection_CollisionCount primary key (
        IS_COL_IS_ID asc,
        IS_COL_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- IS_INJ_Intersection_InjuredCount table (on IS_Intersection)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.IS_INJ_Intersection_InjuredCount', 'U') IS NULL
CREATE TABLE [dbo].[IS_INJ_Intersection_InjuredCount] (
    IS_INJ_IS_ID int not null,
    IS_INJ_Intersection_InjuredCount int not null,
    IS_INJ_ChangedAt date not null,
    Metadata_IS_INJ int not null,
    constraint fkIS_INJ_Intersection_InjuredCount foreign key (
        IS_INJ_IS_ID
    ) references [dbo].[IS_Intersection](IS_ID),
    constraint pkIS_INJ_Intersection_InjuredCount primary key (
        IS_INJ_IS_ID asc,
        IS_INJ_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- IS_KIL_Intersection_KilledCount table (on IS_Intersection)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.IS_KIL_Intersection_KilledCount', 'U') IS NULL
CREATE TABLE [dbo].[IS_KIL_Intersection_KilledCount] (
    IS_KIL_IS_ID int not null,
    IS_KIL_Intersection_KilledCount int not null,
    IS_KIL_ChangedAt date not null,
    Metadata_IS_KIL int not null,
    constraint fkIS_KIL_Intersection_KilledCount foreign key (
        IS_KIL_IS_ID
    ) references [dbo].[IS_Intersection](IS_ID),
    constraint pkIS_KIL_Intersection_KilledCount primary key (
        IS_KIL_IS_ID asc,
        IS_KIL_ChangedAt desc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- IS_VEH_Intersection_VehicleCount table (on IS_Intersection)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.IS_VEH_Intersection_VehicleCount', 'U') IS NULL
CREATE TABLE [dbo].[IS_VEH_Intersection_VehicleCount] (
    IS_VEH_IS_ID int not null,
    IS_VEH_Intersection_VehicleCount smallint not null,
    IS_VEH_ChangedAt date not null,
    Metadata_IS_VEH int not null,
    constraint fkIS_VEH_Intersection_VehicleCount foreign key (
        IS_VEH_IS_ID
    ) references [dbo].[IS_Intersection](IS_ID),
    constraint pkIS_VEH_Intersection_VehicleCount primary key (
        IS_VEH_IS_ID asc,
        IS_VEH_ChangedAt desc
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
-- ST_intersecting_IS_of_ST_crossing table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_intersecting_IS_of_ST_crossing', 'U') IS NULL
CREATE TABLE [dbo].[ST_intersecting_IS_of_ST_crossing] (
    ST_ID_intersecting int not null, 
    IS_ID_of int not null, 
    ST_ID_crossing int not null, 
    Metadata_ST_intersecting_IS_of_ST_crossing int not null,
    constraint ST_intersecting_IS_of_ST_crossing_fkST_intersecting foreign key (
        ST_ID_intersecting
    ) references [dbo].[ST_Street](ST_ID), 
    constraint ST_intersecting_IS_of_ST_crossing_fkIS_of foreign key (
        IS_ID_of
    ) references [dbo].[IS_Intersection](IS_ID), 
    constraint ST_intersecting_IS_of_ST_crossing_fkST_crossing foreign key (
        ST_ID_crossing
    ) references [dbo].[ST_Street](ST_ID), 
    constraint pkST_intersecting_IS_of_ST_crossing primary key (
        ST_ID_intersecting asc,
        ST_ID_crossing asc
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
-- rfIS_COL_Intersection_CollisionCount restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcIS_COL_Intersection_CollisionCount restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfIS_COL_Intersection_CollisionCount', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfIS_COL_Intersection_CollisionCount] (
        @id int,
        @value int,
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
                        pre.IS_COL_Intersection_CollisionCount
                    FROM
                        [dbo].[IS_COL_Intersection_CollisionCount] pre
                    WHERE
                        pre.IS_COL_IS_ID = @id
                    AND
                        pre.IS_COL_ChangedAt < @changed
                    ORDER BY
                        pre.IS_COL_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.IS_COL_Intersection_CollisionCount
                    FROM
                        [dbo].[IS_COL_Intersection_CollisionCount] fol
                    WHERE
                        fol.IS_COL_IS_ID = @id
                    AND
                        fol.IS_COL_ChangedAt > @changed
                    ORDER BY
                        fol.IS_COL_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [dbo].[IS_COL_Intersection_CollisionCount]
    ADD CONSTRAINT [rcIS_COL_Intersection_CollisionCount] CHECK (
        [dbo].[rfIS_COL_Intersection_CollisionCount] (
            IS_COL_IS_ID,
            IS_COL_Intersection_CollisionCount,
            IS_COL_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfIS_INJ_Intersection_InjuredCount restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcIS_INJ_Intersection_InjuredCount restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfIS_INJ_Intersection_InjuredCount', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfIS_INJ_Intersection_InjuredCount] (
        @id int,
        @value int,
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
                        pre.IS_INJ_Intersection_InjuredCount
                    FROM
                        [dbo].[IS_INJ_Intersection_InjuredCount] pre
                    WHERE
                        pre.IS_INJ_IS_ID = @id
                    AND
                        pre.IS_INJ_ChangedAt < @changed
                    ORDER BY
                        pre.IS_INJ_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.IS_INJ_Intersection_InjuredCount
                    FROM
                        [dbo].[IS_INJ_Intersection_InjuredCount] fol
                    WHERE
                        fol.IS_INJ_IS_ID = @id
                    AND
                        fol.IS_INJ_ChangedAt > @changed
                    ORDER BY
                        fol.IS_INJ_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [dbo].[IS_INJ_Intersection_InjuredCount]
    ADD CONSTRAINT [rcIS_INJ_Intersection_InjuredCount] CHECK (
        [dbo].[rfIS_INJ_Intersection_InjuredCount] (
            IS_INJ_IS_ID,
            IS_INJ_Intersection_InjuredCount,
            IS_INJ_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfIS_KIL_Intersection_KilledCount restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcIS_KIL_Intersection_KilledCount restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfIS_KIL_Intersection_KilledCount', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfIS_KIL_Intersection_KilledCount] (
        @id int,
        @value int,
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
                        pre.IS_KIL_Intersection_KilledCount
                    FROM
                        [dbo].[IS_KIL_Intersection_KilledCount] pre
                    WHERE
                        pre.IS_KIL_IS_ID = @id
                    AND
                        pre.IS_KIL_ChangedAt < @changed
                    ORDER BY
                        pre.IS_KIL_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.IS_KIL_Intersection_KilledCount
                    FROM
                        [dbo].[IS_KIL_Intersection_KilledCount] fol
                    WHERE
                        fol.IS_KIL_IS_ID = @id
                    AND
                        fol.IS_KIL_ChangedAt > @changed
                    ORDER BY
                        fol.IS_KIL_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [dbo].[IS_KIL_Intersection_KilledCount]
    ADD CONSTRAINT [rcIS_KIL_Intersection_KilledCount] CHECK (
        [dbo].[rfIS_KIL_Intersection_KilledCount] (
            IS_KIL_IS_ID,
            IS_KIL_Intersection_KilledCount,
            IS_KIL_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfIS_VEH_Intersection_VehicleCount restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcIS_VEH_Intersection_VehicleCount restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfIS_VEH_Intersection_VehicleCount', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfIS_VEH_Intersection_VehicleCount] (
        @id int,
        @value smallint,
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
                        pre.IS_VEH_Intersection_VehicleCount
                    FROM
                        [dbo].[IS_VEH_Intersection_VehicleCount] pre
                    WHERE
                        pre.IS_VEH_IS_ID = @id
                    AND
                        pre.IS_VEH_ChangedAt < @changed
                    ORDER BY
                        pre.IS_VEH_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.IS_VEH_Intersection_VehicleCount
                    FROM
                        [dbo].[IS_VEH_Intersection_VehicleCount] fol
                    WHERE
                        fol.IS_VEH_IS_ID = @id
                    AND
                        fol.IS_VEH_ChangedAt > @changed
                    ORDER BY
                        fol.IS_VEH_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [dbo].[IS_VEH_Intersection_VehicleCount]
    ADD CONSTRAINT [rcIS_VEH_Intersection_VehicleCount] CHECK (
        [dbo].[rfIS_VEH_Intersection_VehicleCount] (
            IS_VEH_IS_ID,
            IS_VEH_Intersection_VehicleCount,
            IS_VEH_ChangedAt
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
-- kST_Street identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kST_Street', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kST_Street] (
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
            INSERT INTO [dbo].[ST_Street] (
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
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kIS_Intersection identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kIS_Intersection', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kIS_Intersection] (
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
            INSERT INTO [dbo].[IS_Intersection] (
                Metadata_IS
            )
            OUTPUT
                inserted.IS_ID
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
-- rIS_COL_Intersection_CollisionCount rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rIS_COL_Intersection_CollisionCount','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rIS_COL_Intersection_CollisionCount] (
        @changingTimepoint date
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_IS_COL,
        IS_COL_IS_ID,
        IS_COL_Intersection_CollisionCount,
        IS_COL_ChangedAt
    FROM
        [dbo].[IS_COL_Intersection_CollisionCount]
    WHERE
        IS_COL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rIS_INJ_Intersection_InjuredCount rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rIS_INJ_Intersection_InjuredCount','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rIS_INJ_Intersection_InjuredCount] (
        @changingTimepoint date
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_IS_INJ,
        IS_INJ_IS_ID,
        IS_INJ_Intersection_InjuredCount,
        IS_INJ_ChangedAt
    FROM
        [dbo].[IS_INJ_Intersection_InjuredCount]
    WHERE
        IS_INJ_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rIS_KIL_Intersection_KilledCount rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rIS_KIL_Intersection_KilledCount','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rIS_KIL_Intersection_KilledCount] (
        @changingTimepoint date
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_IS_KIL,
        IS_KIL_IS_ID,
        IS_KIL_Intersection_KilledCount,
        IS_KIL_ChangedAt
    FROM
        [dbo].[IS_KIL_Intersection_KilledCount]
    WHERE
        IS_KIL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rIS_VEH_Intersection_VehicleCount rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rIS_VEH_Intersection_VehicleCount','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rIS_VEH_Intersection_VehicleCount] (
        @changingTimepoint date
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_IS_VEH,
        IS_VEH_IS_ID,
        IS_VEH_Intersection_VehicleCount,
        IS_VEH_ChangedAt
    FROM
        [dbo].[IS_VEH_Intersection_VehicleCount]
    WHERE
        IS_VEH_ChangedAt <= @changingTimepoint;
    ');
END
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
IF Object_ID('dbo.dST_Street', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_Street];
IF Object_ID('dbo.nST_Street', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_Street];
IF Object_ID('dbo.pST_Street', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_Street];
IF Object_ID('dbo.lST_Street', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_Street];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_Street viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_Street] WITH SCHEMABINDING AS
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [NAM].ST_NAM_ST_ID,
    [NAM].Metadata_ST_NAM,
    [NAM].ST_NAM_Street_Name
FROM
    [dbo].[ST_Street] [ST]
LEFT JOIN
    [dbo].[ST_NAM_Street_Name] [NAM]
ON
    [NAM].ST_NAM_ST_ID = [ST].ST_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_Street viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_Street] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [NAM].ST_NAM_ST_ID,
    [NAM].Metadata_ST_NAM,
    [NAM].ST_NAM_Street_Name
FROM
    [dbo].[ST_Street] [ST]
LEFT JOIN
    [dbo].[ST_NAM_Street_Name] [NAM]
ON
    [NAM].ST_NAM_ST_ID = [ST].ST_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_Street viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_Street]
AS
SELECT
    *
FROM
    [dbo].[pST_Street](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dIS_Intersection', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dIS_Intersection];
IF Object_ID('dbo.nIS_Intersection', 'V') IS NOT NULL
DROP VIEW [dbo].[nIS_Intersection];
IF Object_ID('dbo.pIS_Intersection', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pIS_Intersection];
IF Object_ID('dbo.lIS_Intersection', 'V') IS NOT NULL
DROP VIEW [dbo].[lIS_Intersection];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lIS_Intersection viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lIS_Intersection] WITH SCHEMABINDING AS
SELECT
    [IS].IS_ID,
    [IS].Metadata_IS,
    [COL].IS_COL_IS_ID,
    [COL].Metadata_IS_COL,
    [COL].IS_COL_ChangedAt,
    [COL].IS_COL_Intersection_CollisionCount,
    [INJ].IS_INJ_IS_ID,
    [INJ].Metadata_IS_INJ,
    [INJ].IS_INJ_ChangedAt,
    [INJ].IS_INJ_Intersection_InjuredCount,
    [KIL].IS_KIL_IS_ID,
    [KIL].Metadata_IS_KIL,
    [KIL].IS_KIL_ChangedAt,
    [KIL].IS_KIL_Intersection_KilledCount,
    [VEH].IS_VEH_IS_ID,
    [VEH].Metadata_IS_VEH,
    [VEH].IS_VEH_ChangedAt,
    [VEH].IS_VEH_Intersection_VehicleCount
FROM
    [dbo].[IS_Intersection] [IS]
LEFT JOIN
    [dbo].[IS_COL_Intersection_CollisionCount] [COL]
ON
    [COL].IS_COL_IS_ID = [IS].IS_ID
AND
    [COL].IS_COL_ChangedAt = (
        SELECT
            max(sub.IS_COL_ChangedAt)
        FROM
            [dbo].[IS_COL_Intersection_CollisionCount] sub
        WHERE
            sub.IS_COL_IS_ID = [IS].IS_ID
   )
LEFT JOIN
    [dbo].[IS_INJ_Intersection_InjuredCount] [INJ]
ON
    [INJ].IS_INJ_IS_ID = [IS].IS_ID
AND
    [INJ].IS_INJ_ChangedAt = (
        SELECT
            max(sub.IS_INJ_ChangedAt)
        FROM
            [dbo].[IS_INJ_Intersection_InjuredCount] sub
        WHERE
            sub.IS_INJ_IS_ID = [IS].IS_ID
   )
LEFT JOIN
    [dbo].[IS_KIL_Intersection_KilledCount] [KIL]
ON
    [KIL].IS_KIL_IS_ID = [IS].IS_ID
AND
    [KIL].IS_KIL_ChangedAt = (
        SELECT
            max(sub.IS_KIL_ChangedAt)
        FROM
            [dbo].[IS_KIL_Intersection_KilledCount] sub
        WHERE
            sub.IS_KIL_IS_ID = [IS].IS_ID
   )
LEFT JOIN
    [dbo].[IS_VEH_Intersection_VehicleCount] [VEH]
ON
    [VEH].IS_VEH_IS_ID = [IS].IS_ID
AND
    [VEH].IS_VEH_ChangedAt = (
        SELECT
            max(sub.IS_VEH_ChangedAt)
        FROM
            [dbo].[IS_VEH_Intersection_VehicleCount] sub
        WHERE
            sub.IS_VEH_IS_ID = [IS].IS_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pIS_Intersection viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pIS_Intersection] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [IS].IS_ID,
    [IS].Metadata_IS,
    [COL].IS_COL_IS_ID,
    [COL].Metadata_IS_COL,
    [COL].IS_COL_ChangedAt,
    [COL].IS_COL_Intersection_CollisionCount,
    [INJ].IS_INJ_IS_ID,
    [INJ].Metadata_IS_INJ,
    [INJ].IS_INJ_ChangedAt,
    [INJ].IS_INJ_Intersection_InjuredCount,
    [KIL].IS_KIL_IS_ID,
    [KIL].Metadata_IS_KIL,
    [KIL].IS_KIL_ChangedAt,
    [KIL].IS_KIL_Intersection_KilledCount,
    [VEH].IS_VEH_IS_ID,
    [VEH].Metadata_IS_VEH,
    [VEH].IS_VEH_ChangedAt,
    [VEH].IS_VEH_Intersection_VehicleCount
FROM
    [dbo].[IS_Intersection] [IS]
LEFT JOIN
    [dbo].[rIS_COL_Intersection_CollisionCount](@changingTimepoint) [COL]
ON
    [COL].IS_COL_IS_ID = [IS].IS_ID
AND
    [COL].IS_COL_ChangedAt = (
        SELECT
            max(sub.IS_COL_ChangedAt)
        FROM
            [dbo].[rIS_COL_Intersection_CollisionCount](@changingTimepoint) sub
        WHERE
            sub.IS_COL_IS_ID = [IS].IS_ID
   )
LEFT JOIN
    [dbo].[rIS_INJ_Intersection_InjuredCount](@changingTimepoint) [INJ]
ON
    [INJ].IS_INJ_IS_ID = [IS].IS_ID
AND
    [INJ].IS_INJ_ChangedAt = (
        SELECT
            max(sub.IS_INJ_ChangedAt)
        FROM
            [dbo].[rIS_INJ_Intersection_InjuredCount](@changingTimepoint) sub
        WHERE
            sub.IS_INJ_IS_ID = [IS].IS_ID
   )
LEFT JOIN
    [dbo].[rIS_KIL_Intersection_KilledCount](@changingTimepoint) [KIL]
ON
    [KIL].IS_KIL_IS_ID = [IS].IS_ID
AND
    [KIL].IS_KIL_ChangedAt = (
        SELECT
            max(sub.IS_KIL_ChangedAt)
        FROM
            [dbo].[rIS_KIL_Intersection_KilledCount](@changingTimepoint) sub
        WHERE
            sub.IS_KIL_IS_ID = [IS].IS_ID
   )
LEFT JOIN
    [dbo].[rIS_VEH_Intersection_VehicleCount](@changingTimepoint) [VEH]
ON
    [VEH].IS_VEH_IS_ID = [IS].IS_ID
AND
    [VEH].IS_VEH_ChangedAt = (
        SELECT
            max(sub.IS_VEH_ChangedAt)
        FROM
            [dbo].[rIS_VEH_Intersection_VehicleCount](@changingTimepoint) sub
        WHERE
            sub.IS_VEH_IS_ID = [IS].IS_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nIS_Intersection viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nIS_Intersection]
AS
SELECT
    *
FROM
    [dbo].[pIS_Intersection](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dIS_Intersection showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dIS_Intersection] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pIS].*
FROM (
    SELECT DISTINCT
        IS_COL_IS_ID AS IS_ID,
        IS_COL_ChangedAt AS inspectedTimepoint,
        'COL' AS mnemonic
    FROM
        [dbo].[IS_COL_Intersection_CollisionCount]
    WHERE
        (@selection is null OR @selection like '%COL%')
    AND
        IS_COL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        IS_INJ_IS_ID AS IS_ID,
        IS_INJ_ChangedAt AS inspectedTimepoint,
        'INJ' AS mnemonic
    FROM
        [dbo].[IS_INJ_Intersection_InjuredCount]
    WHERE
        (@selection is null OR @selection like '%INJ%')
    AND
        IS_INJ_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        IS_KIL_IS_ID AS IS_ID,
        IS_KIL_ChangedAt AS inspectedTimepoint,
        'KIL' AS mnemonic
    FROM
        [dbo].[IS_KIL_Intersection_KilledCount]
    WHERE
        (@selection is null OR @selection like '%KIL%')
    AND
        IS_KIL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        IS_VEH_IS_ID AS IS_ID,
        IS_VEH_ChangedAt AS inspectedTimepoint,
        'VEH' AS mnemonic
    FROM
        [dbo].[IS_VEH_Intersection_VehicleCount]
    WHERE
        (@selection is null OR @selection like '%VEH%')
    AND
        IS_VEH_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[pIS_Intersection](timepoints.inspectedTimepoint) [pIS]
WHERE
    [pIS].IS_ID = timepoints.IS_ID;
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
-- it_ST_NAM_Street_Name instead of INSERT trigger on ST_NAM_Street_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_NAM_Street_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_NAM_Street_Name];
GO
CREATE TRIGGER [dbo].[it_ST_NAM_Street_Name] ON [dbo].[ST_NAM_Street_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_NAM_Street_Name TABLE (
        ST_NAM_ST_ID int not null,
        Metadata_ST_NAM int not null,
        ST_NAM_Street_Name varchar(555) not null,
        ST_NAM_Version bigint not null,
        ST_NAM_StatementType char(1) not null,
        primary key(
            ST_NAM_Version,
            ST_NAM_ST_ID
        )
    );
    INSERT INTO @ST_NAM_Street_Name
    SELECT
        i.ST_NAM_ST_ID,
        i.Metadata_ST_NAM,
        i.ST_NAM_Street_Name,
        ROW_NUMBER() OVER (
            PARTITION BY
                i.ST_NAM_ST_ID
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
        @ST_NAM_Street_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.ST_NAM_StatementType =
                CASE
                    WHEN [NAM].ST_NAM_ST_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_NAM_Street_Name v
        LEFT JOIN
            [dbo].[ST_NAM_Street_Name] [NAM]
        ON
            [NAM].ST_NAM_ST_ID = v.ST_NAM_ST_ID
        AND
            [NAM].ST_NAM_Street_Name = v.ST_NAM_Street_Name
        WHERE
            v.ST_NAM_Version = @currentVersion;
        INSERT INTO [dbo].[ST_NAM_Street_Name] (
            ST_NAM_ST_ID,
            Metadata_ST_NAM,
            ST_NAM_Street_Name
        )
        SELECT
            ST_NAM_ST_ID,
            Metadata_ST_NAM,
            ST_NAM_Street_Name
        FROM
            @ST_NAM_Street_Name
        WHERE
            ST_NAM_Version = @currentVersion
        AND
            ST_NAM_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_IS_COL_Intersection_CollisionCount instead of INSERT trigger on IS_COL_Intersection_CollisionCount
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_IS_COL_Intersection_CollisionCount', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_IS_COL_Intersection_CollisionCount];
GO
CREATE TRIGGER [dbo].[it_IS_COL_Intersection_CollisionCount] ON [dbo].[IS_COL_Intersection_CollisionCount]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @IS_COL_Intersection_CollisionCount TABLE (
        IS_COL_IS_ID int not null,
        Metadata_IS_COL int not null,
        IS_COL_ChangedAt date not null,
        IS_COL_Intersection_CollisionCount int not null,
        IS_COL_Version bigint not null,
        IS_COL_StatementType char(1) not null,
        primary key(
            IS_COL_Version,
            IS_COL_IS_ID
        )
    );
    INSERT INTO @IS_COL_Intersection_CollisionCount
    SELECT
        i.IS_COL_IS_ID,
        i.Metadata_IS_COL,
        i.IS_COL_ChangedAt,
        i.IS_COL_Intersection_CollisionCount,
        DENSE_RANK() OVER (
            PARTITION BY
                i.IS_COL_IS_ID
            ORDER BY
                i.IS_COL_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(IS_COL_Version), 
        @currentVersion = 0
    FROM
        @IS_COL_Intersection_CollisionCount;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.IS_COL_StatementType =
                CASE
                    WHEN [COL].IS_COL_IS_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [dbo].[rfIS_COL_Intersection_CollisionCount]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.IS_COL_Intersection_CollisionCount = (
                                SELECT TOP 1
                                    pre.IS_COL_Intersection_CollisionCount
                                FROM
                                    [dbo].[IS_COL_Intersection_CollisionCount] pre
                                WHERE
                                    pre.IS_COL_IS_ID = v.IS_COL_IS_ID
                                AND
                                    pre.IS_COL_ChangedAt < v.IS_COL_ChangedAt
                                ORDER BY
                                    pre.IS_COL_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.IS_COL_Intersection_CollisionCount = (
                                SELECT TOP 1
                                    fol.IS_COL_Intersection_CollisionCount
                                FROM
                                    [dbo].[IS_COL_Intersection_CollisionCount] fol
                                WHERE
                                    fol.IS_COL_IS_ID = v.IS_COL_IS_ID
                                AND
                                    fol.IS_COL_ChangedAt > v.IS_COL_ChangedAt
                                ORDER BY
                                    fol.IS_COL_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @IS_COL_Intersection_CollisionCount v
        LEFT JOIN
            [dbo].[IS_COL_Intersection_CollisionCount] [COL]
        ON
            [COL].IS_COL_IS_ID = v.IS_COL_IS_ID
        AND
            [COL].IS_COL_ChangedAt = v.IS_COL_ChangedAt
        AND
            [COL].IS_COL_Intersection_CollisionCount = v.IS_COL_Intersection_CollisionCount
        WHERE
            v.IS_COL_Version = @currentVersion;
        INSERT INTO [dbo].[IS_COL_Intersection_CollisionCount] (
            IS_COL_IS_ID,
            Metadata_IS_COL,
            IS_COL_ChangedAt,
            IS_COL_Intersection_CollisionCount
        )
        SELECT
            IS_COL_IS_ID,
            Metadata_IS_COL,
            IS_COL_ChangedAt,
            IS_COL_Intersection_CollisionCount
        FROM
            @IS_COL_Intersection_CollisionCount
        WHERE
            IS_COL_Version = @currentVersion
        AND
            IS_COL_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_IS_INJ_Intersection_InjuredCount instead of INSERT trigger on IS_INJ_Intersection_InjuredCount
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_IS_INJ_Intersection_InjuredCount', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_IS_INJ_Intersection_InjuredCount];
GO
CREATE TRIGGER [dbo].[it_IS_INJ_Intersection_InjuredCount] ON [dbo].[IS_INJ_Intersection_InjuredCount]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @IS_INJ_Intersection_InjuredCount TABLE (
        IS_INJ_IS_ID int not null,
        Metadata_IS_INJ int not null,
        IS_INJ_ChangedAt date not null,
        IS_INJ_Intersection_InjuredCount int not null,
        IS_INJ_Version bigint not null,
        IS_INJ_StatementType char(1) not null,
        primary key(
            IS_INJ_Version,
            IS_INJ_IS_ID
        )
    );
    INSERT INTO @IS_INJ_Intersection_InjuredCount
    SELECT
        i.IS_INJ_IS_ID,
        i.Metadata_IS_INJ,
        i.IS_INJ_ChangedAt,
        i.IS_INJ_Intersection_InjuredCount,
        DENSE_RANK() OVER (
            PARTITION BY
                i.IS_INJ_IS_ID
            ORDER BY
                i.IS_INJ_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(IS_INJ_Version), 
        @currentVersion = 0
    FROM
        @IS_INJ_Intersection_InjuredCount;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.IS_INJ_StatementType =
                CASE
                    WHEN [INJ].IS_INJ_IS_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [dbo].[rfIS_INJ_Intersection_InjuredCount]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.IS_INJ_Intersection_InjuredCount = (
                                SELECT TOP 1
                                    pre.IS_INJ_Intersection_InjuredCount
                                FROM
                                    [dbo].[IS_INJ_Intersection_InjuredCount] pre
                                WHERE
                                    pre.IS_INJ_IS_ID = v.IS_INJ_IS_ID
                                AND
                                    pre.IS_INJ_ChangedAt < v.IS_INJ_ChangedAt
                                ORDER BY
                                    pre.IS_INJ_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.IS_INJ_Intersection_InjuredCount = (
                                SELECT TOP 1
                                    fol.IS_INJ_Intersection_InjuredCount
                                FROM
                                    [dbo].[IS_INJ_Intersection_InjuredCount] fol
                                WHERE
                                    fol.IS_INJ_IS_ID = v.IS_INJ_IS_ID
                                AND
                                    fol.IS_INJ_ChangedAt > v.IS_INJ_ChangedAt
                                ORDER BY
                                    fol.IS_INJ_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @IS_INJ_Intersection_InjuredCount v
        LEFT JOIN
            [dbo].[IS_INJ_Intersection_InjuredCount] [INJ]
        ON
            [INJ].IS_INJ_IS_ID = v.IS_INJ_IS_ID
        AND
            [INJ].IS_INJ_ChangedAt = v.IS_INJ_ChangedAt
        AND
            [INJ].IS_INJ_Intersection_InjuredCount = v.IS_INJ_Intersection_InjuredCount
        WHERE
            v.IS_INJ_Version = @currentVersion;
        INSERT INTO [dbo].[IS_INJ_Intersection_InjuredCount] (
            IS_INJ_IS_ID,
            Metadata_IS_INJ,
            IS_INJ_ChangedAt,
            IS_INJ_Intersection_InjuredCount
        )
        SELECT
            IS_INJ_IS_ID,
            Metadata_IS_INJ,
            IS_INJ_ChangedAt,
            IS_INJ_Intersection_InjuredCount
        FROM
            @IS_INJ_Intersection_InjuredCount
        WHERE
            IS_INJ_Version = @currentVersion
        AND
            IS_INJ_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_IS_KIL_Intersection_KilledCount instead of INSERT trigger on IS_KIL_Intersection_KilledCount
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_IS_KIL_Intersection_KilledCount', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_IS_KIL_Intersection_KilledCount];
GO
CREATE TRIGGER [dbo].[it_IS_KIL_Intersection_KilledCount] ON [dbo].[IS_KIL_Intersection_KilledCount]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @IS_KIL_Intersection_KilledCount TABLE (
        IS_KIL_IS_ID int not null,
        Metadata_IS_KIL int not null,
        IS_KIL_ChangedAt date not null,
        IS_KIL_Intersection_KilledCount int not null,
        IS_KIL_Version bigint not null,
        IS_KIL_StatementType char(1) not null,
        primary key(
            IS_KIL_Version,
            IS_KIL_IS_ID
        )
    );
    INSERT INTO @IS_KIL_Intersection_KilledCount
    SELECT
        i.IS_KIL_IS_ID,
        i.Metadata_IS_KIL,
        i.IS_KIL_ChangedAt,
        i.IS_KIL_Intersection_KilledCount,
        DENSE_RANK() OVER (
            PARTITION BY
                i.IS_KIL_IS_ID
            ORDER BY
                i.IS_KIL_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(IS_KIL_Version), 
        @currentVersion = 0
    FROM
        @IS_KIL_Intersection_KilledCount;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.IS_KIL_StatementType =
                CASE
                    WHEN [KIL].IS_KIL_IS_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [dbo].[rfIS_KIL_Intersection_KilledCount]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.IS_KIL_Intersection_KilledCount = (
                                SELECT TOP 1
                                    pre.IS_KIL_Intersection_KilledCount
                                FROM
                                    [dbo].[IS_KIL_Intersection_KilledCount] pre
                                WHERE
                                    pre.IS_KIL_IS_ID = v.IS_KIL_IS_ID
                                AND
                                    pre.IS_KIL_ChangedAt < v.IS_KIL_ChangedAt
                                ORDER BY
                                    pre.IS_KIL_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.IS_KIL_Intersection_KilledCount = (
                                SELECT TOP 1
                                    fol.IS_KIL_Intersection_KilledCount
                                FROM
                                    [dbo].[IS_KIL_Intersection_KilledCount] fol
                                WHERE
                                    fol.IS_KIL_IS_ID = v.IS_KIL_IS_ID
                                AND
                                    fol.IS_KIL_ChangedAt > v.IS_KIL_ChangedAt
                                ORDER BY
                                    fol.IS_KIL_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @IS_KIL_Intersection_KilledCount v
        LEFT JOIN
            [dbo].[IS_KIL_Intersection_KilledCount] [KIL]
        ON
            [KIL].IS_KIL_IS_ID = v.IS_KIL_IS_ID
        AND
            [KIL].IS_KIL_ChangedAt = v.IS_KIL_ChangedAt
        AND
            [KIL].IS_KIL_Intersection_KilledCount = v.IS_KIL_Intersection_KilledCount
        WHERE
            v.IS_KIL_Version = @currentVersion;
        INSERT INTO [dbo].[IS_KIL_Intersection_KilledCount] (
            IS_KIL_IS_ID,
            Metadata_IS_KIL,
            IS_KIL_ChangedAt,
            IS_KIL_Intersection_KilledCount
        )
        SELECT
            IS_KIL_IS_ID,
            Metadata_IS_KIL,
            IS_KIL_ChangedAt,
            IS_KIL_Intersection_KilledCount
        FROM
            @IS_KIL_Intersection_KilledCount
        WHERE
            IS_KIL_Version = @currentVersion
        AND
            IS_KIL_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_IS_VEH_Intersection_VehicleCount instead of INSERT trigger on IS_VEH_Intersection_VehicleCount
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_IS_VEH_Intersection_VehicleCount', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_IS_VEH_Intersection_VehicleCount];
GO
CREATE TRIGGER [dbo].[it_IS_VEH_Intersection_VehicleCount] ON [dbo].[IS_VEH_Intersection_VehicleCount]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @IS_VEH_Intersection_VehicleCount TABLE (
        IS_VEH_IS_ID int not null,
        Metadata_IS_VEH int not null,
        IS_VEH_ChangedAt date not null,
        IS_VEH_Intersection_VehicleCount smallint not null,
        IS_VEH_Version bigint not null,
        IS_VEH_StatementType char(1) not null,
        primary key(
            IS_VEH_Version,
            IS_VEH_IS_ID
        )
    );
    INSERT INTO @IS_VEH_Intersection_VehicleCount
    SELECT
        i.IS_VEH_IS_ID,
        i.Metadata_IS_VEH,
        i.IS_VEH_ChangedAt,
        i.IS_VEH_Intersection_VehicleCount,
        DENSE_RANK() OVER (
            PARTITION BY
                i.IS_VEH_IS_ID
            ORDER BY
                i.IS_VEH_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(IS_VEH_Version), 
        @currentVersion = 0
    FROM
        @IS_VEH_Intersection_VehicleCount;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.IS_VEH_StatementType =
                CASE
                    WHEN [VEH].IS_VEH_IS_ID is not null
                    THEN 'D' -- duplicate
                    WHEN EXISTS ( -- note that this code is identical to the scalar function [dbo].[rfIS_VEH_Intersection_VehicleCount]
                        SELECT TOP 1
                            42 
                        WHERE
                            v.IS_VEH_Intersection_VehicleCount = (
                                SELECT TOP 1
                                    pre.IS_VEH_Intersection_VehicleCount
                                FROM
                                    [dbo].[IS_VEH_Intersection_VehicleCount] pre
                                WHERE
                                    pre.IS_VEH_IS_ID = v.IS_VEH_IS_ID
                                AND
                                    pre.IS_VEH_ChangedAt < v.IS_VEH_ChangedAt
                                ORDER BY
                                    pre.IS_VEH_ChangedAt DESC
                            )
                    ) OR EXISTS (
                        SELECT TOP 1
                            42 
                        WHERE
                            v.IS_VEH_Intersection_VehicleCount = (
                                SELECT TOP 1
                                    fol.IS_VEH_Intersection_VehicleCount
                                FROM
                                    [dbo].[IS_VEH_Intersection_VehicleCount] fol
                                WHERE
                                    fol.IS_VEH_IS_ID = v.IS_VEH_IS_ID
                                AND
                                    fol.IS_VEH_ChangedAt > v.IS_VEH_ChangedAt
                                ORDER BY
                                    fol.IS_VEH_ChangedAt ASC
                            )
                    ) 
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @IS_VEH_Intersection_VehicleCount v
        LEFT JOIN
            [dbo].[IS_VEH_Intersection_VehicleCount] [VEH]
        ON
            [VEH].IS_VEH_IS_ID = v.IS_VEH_IS_ID
        AND
            [VEH].IS_VEH_ChangedAt = v.IS_VEH_ChangedAt
        AND
            [VEH].IS_VEH_Intersection_VehicleCount = v.IS_VEH_Intersection_VehicleCount
        WHERE
            v.IS_VEH_Version = @currentVersion;
        INSERT INTO [dbo].[IS_VEH_Intersection_VehicleCount] (
            IS_VEH_IS_ID,
            Metadata_IS_VEH,
            IS_VEH_ChangedAt,
            IS_VEH_Intersection_VehicleCount
        )
        SELECT
            IS_VEH_IS_ID,
            Metadata_IS_VEH,
            IS_VEH_ChangedAt,
            IS_VEH_Intersection_VehicleCount
        FROM
            @IS_VEH_Intersection_VehicleCount
        WHERE
            IS_VEH_Version = @currentVersion
        AND
            IS_VEH_StatementType in ('N');
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
-- it_lST_Street instead of INSERT trigger on lST_Street
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lST_Street] ON [dbo].[lST_Street]
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
    INSERT INTO [dbo].[ST_Street] (
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
        ST_NAM_ST_ID int null,
        Metadata_ST_NAM int null,
        ST_NAM_Street_Name varchar(555) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.ST_ID, a.ST_ID),
        i.Metadata_ST,
        ISNULL(ISNULL(i.ST_NAM_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_NAM, i.Metadata_ST),
        i.ST_NAM_Street_Name
    FROM (
        SELECT
            ST_ID,
            Metadata_ST,
            ST_NAM_ST_ID,
            Metadata_ST_NAM,
            ST_NAM_Street_Name,
            ROW_NUMBER() OVER (PARTITION BY ST_ID ORDER BY ST_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @ST a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[ST_NAM_Street_Name] (
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_Street_Name
    )
    SELECT
        i.Metadata_ST_NAM,
        i.ST_NAM_ST_ID,
        i.ST_NAM_Street_Name
    FROM
        @inserted i
    WHERE
        i.ST_NAM_Street_Name is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Street instead of UPDATE trigger on lST_Street
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lST_Street] ON [dbo].[lST_Street]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(ST_ID))
        RAISERROR('The identity column ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_NAM_ST_ID))
        RAISERROR('The foreign key column ST_NAM_ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_NAM_Street_Name))
    BEGIN
        INSERT INTO [dbo].[ST_NAM_Street_Name] (
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_Street_Name
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_ST) AND NOT UPDATE(Metadata_ST_NAM)
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_NAM
            END, i.Metadata_ST),
            ISNULL(i.ST_NAM_ST_ID, i.ST_ID),
            i.ST_NAM_Street_Name
        FROM
            inserted i
        WHERE
            i.ST_NAM_Street_Name is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Street instead of DELETE trigger on lST_Street
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lST_Street] ON [dbo].[lST_Street]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [dbo].[ST_NAM_Street_Name] [NAM]
    JOIN
        deleted d
    ON
        d.ST_NAM_ST_ID = [NAM].ST_NAM_ST_ID;
    DELETE [ST]
    FROM
        [dbo].[ST_Street] [ST]
    LEFT JOIN
        [dbo].[ST_NAM_Street_Name] [NAM]
    ON
        [NAM].ST_NAM_ST_ID = [ST].ST_ID
    WHERE
        [NAM].ST_NAM_ST_ID is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lIS_Intersection instead of INSERT trigger on lIS_Intersection
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lIS_Intersection] ON [dbo].[lIS_Intersection]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @IS TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        IS_ID int not null
    );
    INSERT INTO [dbo].[IS_Intersection] (
        Metadata_IS 
    )
    OUTPUT
        inserted.IS_ID
    INTO
        @IS
    SELECT
        Metadata_IS 
    FROM
        inserted
    WHERE
        inserted.IS_ID is null;
    DECLARE @inserted TABLE (
        IS_ID int not null,
        Metadata_IS int not null,
        IS_COL_IS_ID int null,
        Metadata_IS_COL int null,
        IS_COL_ChangedAt date null,
        IS_COL_Intersection_CollisionCount int null,
        IS_INJ_IS_ID int null,
        Metadata_IS_INJ int null,
        IS_INJ_ChangedAt date null,
        IS_INJ_Intersection_InjuredCount int null,
        IS_KIL_IS_ID int null,
        Metadata_IS_KIL int null,
        IS_KIL_ChangedAt date null,
        IS_KIL_Intersection_KilledCount int null,
        IS_VEH_IS_ID int null,
        Metadata_IS_VEH int null,
        IS_VEH_ChangedAt date null,
        IS_VEH_Intersection_VehicleCount smallint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.IS_ID, a.IS_ID),
        i.Metadata_IS,
        ISNULL(ISNULL(i.IS_COL_IS_ID, i.IS_ID), a.IS_ID),
        ISNULL(i.Metadata_IS_COL, i.Metadata_IS),
        ISNULL(i.IS_COL_ChangedAt, @now),
        i.IS_COL_Intersection_CollisionCount,
        ISNULL(ISNULL(i.IS_INJ_IS_ID, i.IS_ID), a.IS_ID),
        ISNULL(i.Metadata_IS_INJ, i.Metadata_IS),
        ISNULL(i.IS_INJ_ChangedAt, @now),
        i.IS_INJ_Intersection_InjuredCount,
        ISNULL(ISNULL(i.IS_KIL_IS_ID, i.IS_ID), a.IS_ID),
        ISNULL(i.Metadata_IS_KIL, i.Metadata_IS),
        ISNULL(i.IS_KIL_ChangedAt, @now),
        i.IS_KIL_Intersection_KilledCount,
        ISNULL(ISNULL(i.IS_VEH_IS_ID, i.IS_ID), a.IS_ID),
        ISNULL(i.Metadata_IS_VEH, i.Metadata_IS),
        ISNULL(i.IS_VEH_ChangedAt, @now),
        i.IS_VEH_Intersection_VehicleCount
    FROM (
        SELECT
            IS_ID,
            Metadata_IS,
            IS_COL_IS_ID,
            Metadata_IS_COL,
            IS_COL_ChangedAt,
            IS_COL_Intersection_CollisionCount,
            IS_INJ_IS_ID,
            Metadata_IS_INJ,
            IS_INJ_ChangedAt,
            IS_INJ_Intersection_InjuredCount,
            IS_KIL_IS_ID,
            Metadata_IS_KIL,
            IS_KIL_ChangedAt,
            IS_KIL_Intersection_KilledCount,
            IS_VEH_IS_ID,
            Metadata_IS_VEH,
            IS_VEH_ChangedAt,
            IS_VEH_Intersection_VehicleCount,
            ROW_NUMBER() OVER (PARTITION BY IS_ID ORDER BY IS_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @IS a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[IS_COL_Intersection_CollisionCount] (
        Metadata_IS_COL,
        IS_COL_IS_ID,
        IS_COL_ChangedAt,
        IS_COL_Intersection_CollisionCount
    )
    SELECT
        i.Metadata_IS_COL,
        i.IS_COL_IS_ID,
        i.IS_COL_ChangedAt,
        i.IS_COL_Intersection_CollisionCount
    FROM
        @inserted i
    WHERE
        i.IS_COL_Intersection_CollisionCount is not null;
    INSERT INTO [dbo].[IS_INJ_Intersection_InjuredCount] (
        Metadata_IS_INJ,
        IS_INJ_IS_ID,
        IS_INJ_ChangedAt,
        IS_INJ_Intersection_InjuredCount
    )
    SELECT
        i.Metadata_IS_INJ,
        i.IS_INJ_IS_ID,
        i.IS_INJ_ChangedAt,
        i.IS_INJ_Intersection_InjuredCount
    FROM
        @inserted i
    WHERE
        i.IS_INJ_Intersection_InjuredCount is not null;
    INSERT INTO [dbo].[IS_KIL_Intersection_KilledCount] (
        Metadata_IS_KIL,
        IS_KIL_IS_ID,
        IS_KIL_ChangedAt,
        IS_KIL_Intersection_KilledCount
    )
    SELECT
        i.Metadata_IS_KIL,
        i.IS_KIL_IS_ID,
        i.IS_KIL_ChangedAt,
        i.IS_KIL_Intersection_KilledCount
    FROM
        @inserted i
    WHERE
        i.IS_KIL_Intersection_KilledCount is not null;
    INSERT INTO [dbo].[IS_VEH_Intersection_VehicleCount] (
        Metadata_IS_VEH,
        IS_VEH_IS_ID,
        IS_VEH_ChangedAt,
        IS_VEH_Intersection_VehicleCount
    )
    SELECT
        i.Metadata_IS_VEH,
        i.IS_VEH_IS_ID,
        i.IS_VEH_ChangedAt,
        i.IS_VEH_Intersection_VehicleCount
    FROM
        @inserted i
    WHERE
        i.IS_VEH_Intersection_VehicleCount is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lIS_Intersection instead of UPDATE trigger on lIS_Intersection
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lIS_Intersection] ON [dbo].[lIS_Intersection]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(IS_ID))
        RAISERROR('The identity column IS_ID is not updatable.', 16, 1);
    IF(UPDATE(IS_COL_IS_ID))
        RAISERROR('The foreign key column IS_COL_IS_ID is not updatable.', 16, 1);
    IF(UPDATE(IS_COL_Intersection_CollisionCount))
    BEGIN
        INSERT INTO [dbo].[IS_COL_Intersection_CollisionCount] (
            Metadata_IS_COL,
            IS_COL_IS_ID,
            IS_COL_ChangedAt,
            IS_COL_Intersection_CollisionCount
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_IS) AND NOT UPDATE(Metadata_IS_COL)
                THEN i.Metadata_IS
                ELSE i.Metadata_IS_COL
            END, i.Metadata_IS),
            ISNULL(i.IS_COL_IS_ID, i.IS_ID),
            cast(ISNULL(CASE
                WHEN i.IS_COL_Intersection_CollisionCount is null THEN i.IS_COL_ChangedAt
                WHEN UPDATE(IS_COL_ChangedAt) THEN i.IS_COL_ChangedAt
            END, @now) as date),
            i.IS_COL_Intersection_CollisionCount
        FROM
            inserted i
        WHERE
            i.IS_COL_Intersection_CollisionCount is not null;
    END
    IF(UPDATE(IS_INJ_IS_ID))
        RAISERROR('The foreign key column IS_INJ_IS_ID is not updatable.', 16, 1);
    IF(UPDATE(IS_INJ_Intersection_InjuredCount))
    BEGIN
        INSERT INTO [dbo].[IS_INJ_Intersection_InjuredCount] (
            Metadata_IS_INJ,
            IS_INJ_IS_ID,
            IS_INJ_ChangedAt,
            IS_INJ_Intersection_InjuredCount
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_IS) AND NOT UPDATE(Metadata_IS_INJ)
                THEN i.Metadata_IS
                ELSE i.Metadata_IS_INJ
            END, i.Metadata_IS),
            ISNULL(i.IS_INJ_IS_ID, i.IS_ID),
            cast(ISNULL(CASE
                WHEN i.IS_INJ_Intersection_InjuredCount is null THEN i.IS_INJ_ChangedAt
                WHEN UPDATE(IS_INJ_ChangedAt) THEN i.IS_INJ_ChangedAt
            END, @now) as date),
            i.IS_INJ_Intersection_InjuredCount
        FROM
            inserted i
        WHERE
            i.IS_INJ_Intersection_InjuredCount is not null;
    END
    IF(UPDATE(IS_KIL_IS_ID))
        RAISERROR('The foreign key column IS_KIL_IS_ID is not updatable.', 16, 1);
    IF(UPDATE(IS_KIL_Intersection_KilledCount))
    BEGIN
        INSERT INTO [dbo].[IS_KIL_Intersection_KilledCount] (
            Metadata_IS_KIL,
            IS_KIL_IS_ID,
            IS_KIL_ChangedAt,
            IS_KIL_Intersection_KilledCount
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_IS) AND NOT UPDATE(Metadata_IS_KIL)
                THEN i.Metadata_IS
                ELSE i.Metadata_IS_KIL
            END, i.Metadata_IS),
            ISNULL(i.IS_KIL_IS_ID, i.IS_ID),
            cast(ISNULL(CASE
                WHEN i.IS_KIL_Intersection_KilledCount is null THEN i.IS_KIL_ChangedAt
                WHEN UPDATE(IS_KIL_ChangedAt) THEN i.IS_KIL_ChangedAt
            END, @now) as date),
            i.IS_KIL_Intersection_KilledCount
        FROM
            inserted i
        WHERE
            i.IS_KIL_Intersection_KilledCount is not null;
    END
    IF(UPDATE(IS_VEH_IS_ID))
        RAISERROR('The foreign key column IS_VEH_IS_ID is not updatable.', 16, 1);
    IF(UPDATE(IS_VEH_Intersection_VehicleCount))
    BEGIN
        INSERT INTO [dbo].[IS_VEH_Intersection_VehicleCount] (
            Metadata_IS_VEH,
            IS_VEH_IS_ID,
            IS_VEH_ChangedAt,
            IS_VEH_Intersection_VehicleCount
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_IS) AND NOT UPDATE(Metadata_IS_VEH)
                THEN i.Metadata_IS
                ELSE i.Metadata_IS_VEH
            END, i.Metadata_IS),
            ISNULL(i.IS_VEH_IS_ID, i.IS_ID),
            cast(ISNULL(CASE
                WHEN i.IS_VEH_Intersection_VehicleCount is null THEN i.IS_VEH_ChangedAt
                WHEN UPDATE(IS_VEH_ChangedAt) THEN i.IS_VEH_ChangedAt
            END, @now) as date),
            i.IS_VEH_Intersection_VehicleCount
        FROM
            inserted i
        WHERE
            i.IS_VEH_Intersection_VehicleCount is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lIS_Intersection instead of DELETE trigger on lIS_Intersection
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lIS_Intersection] ON [dbo].[lIS_Intersection]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [COL]
    FROM
        [dbo].[IS_COL_Intersection_CollisionCount] [COL]
    JOIN
        deleted d
    ON
        d.IS_COL_ChangedAt = [COL].IS_COL_ChangedAt
    AND
        d.IS_COL_IS_ID = [COL].IS_COL_IS_ID;
    DELETE [INJ]
    FROM
        [dbo].[IS_INJ_Intersection_InjuredCount] [INJ]
    JOIN
        deleted d
    ON
        d.IS_INJ_ChangedAt = [INJ].IS_INJ_ChangedAt
    AND
        d.IS_INJ_IS_ID = [INJ].IS_INJ_IS_ID;
    DELETE [KIL]
    FROM
        [dbo].[IS_KIL_Intersection_KilledCount] [KIL]
    JOIN
        deleted d
    ON
        d.IS_KIL_ChangedAt = [KIL].IS_KIL_ChangedAt
    AND
        d.IS_KIL_IS_ID = [KIL].IS_KIL_IS_ID;
    DELETE [VEH]
    FROM
        [dbo].[IS_VEH_Intersection_VehicleCount] [VEH]
    JOIN
        deleted d
    ON
        d.IS_VEH_ChangedAt = [VEH].IS_VEH_ChangedAt
    AND
        d.IS_VEH_IS_ID = [VEH].IS_VEH_IS_ID;
    DELETE [IS]
    FROM
        [dbo].[IS_Intersection] [IS]
    LEFT JOIN
        [dbo].[IS_COL_Intersection_CollisionCount] [COL]
    ON
        [COL].IS_COL_IS_ID = [IS].IS_ID
    LEFT JOIN
        [dbo].[IS_INJ_Intersection_InjuredCount] [INJ]
    ON
        [INJ].IS_INJ_IS_ID = [IS].IS_ID
    LEFT JOIN
        [dbo].[IS_KIL_Intersection_KilledCount] [KIL]
    ON
        [KIL].IS_KIL_IS_ID = [IS].IS_ID
    LEFT JOIN
        [dbo].[IS_VEH_Intersection_VehicleCount] [VEH]
    ON
        [VEH].IS_VEH_IS_ID = [IS].IS_ID
    WHERE
        [COL].IS_COL_IS_ID is null
    AND
        [INJ].IS_INJ_IS_ID is null
    AND
        [KIL].IS_KIL_IS_ID is null
    AND
        [VEH].IS_VEH_IS_ID is null;
END
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
IF Object_ID('dbo.dST_intersecting_IS_of_ST_crossing', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_intersecting_IS_of_ST_crossing];
IF Object_ID('dbo.nST_intersecting_IS_of_ST_crossing', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_intersecting_IS_of_ST_crossing];
IF Object_ID('dbo.pST_intersecting_IS_of_ST_crossing', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_intersecting_IS_of_ST_crossing];
IF Object_ID('dbo.lST_intersecting_IS_of_ST_crossing', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_intersecting_IS_of_ST_crossing];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_intersecting_IS_of_ST_crossing viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_intersecting_IS_of_ST_crossing] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_ST_intersecting_IS_of_ST_crossing,
    tie.ST_ID_intersecting,
    tie.IS_ID_of,
    tie.ST_ID_crossing
FROM
    [dbo].[ST_intersecting_IS_of_ST_crossing] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_intersecting_IS_of_ST_crossing viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_intersecting_IS_of_ST_crossing] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_ST_intersecting_IS_of_ST_crossing,
    tie.ST_ID_intersecting,
    tie.IS_ID_of,
    tie.ST_ID_crossing
FROM
    [dbo].[ST_intersecting_IS_of_ST_crossing] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_intersecting_IS_of_ST_crossing viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_intersecting_IS_of_ST_crossing]
AS
SELECT
    *
FROM
    [dbo].[pST_intersecting_IS_of_ST_crossing](sysdatetime());
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
-- it_ST_intersecting_IS_of_ST_crossing instead of INSERT trigger on ST_intersecting_IS_of_ST_crossing
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_intersecting_IS_of_ST_crossing', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_intersecting_IS_of_ST_crossing];
GO
CREATE TRIGGER [dbo].[it_ST_intersecting_IS_of_ST_crossing] ON [dbo].[ST_intersecting_IS_of_ST_crossing]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_ST_intersecting_IS_of_ST_crossing int not null,
        ST_ID_intersecting int not null,
        IS_ID_of int not null,
        ST_ID_crossing int not null,
        primary key (
            ST_ID_intersecting,
            ST_ID_crossing
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_ST_intersecting_IS_of_ST_crossing, 0),
        i.ST_ID_intersecting,
        i.IS_ID_of,
        i.ST_ID_crossing
    FROM
        inserted i
    WHERE
        i.ST_ID_intersecting is not null
    AND
        i.ST_ID_crossing is not null;
    INSERT INTO [dbo].[ST_intersecting_IS_of_ST_crossing] (
        Metadata_ST_intersecting_IS_of_ST_crossing,
        ST_ID_intersecting,
        IS_ID_of,
        ST_ID_crossing
    )
    SELECT
        i.Metadata_ST_intersecting_IS_of_ST_crossing,
        i.ST_ID_intersecting,
        i.IS_ID_of,
        i.ST_ID_crossing
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[ST_intersecting_IS_of_ST_crossing] tie
    ON
        tie.ST_ID_intersecting = i.ST_ID_intersecting
    AND
        tie.ST_ID_crossing = i.ST_ID_crossing
    WHERE
        tie.ST_ID_crossing is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_intersecting_IS_of_ST_crossing instead of INSERT trigger on lST_intersecting_IS_of_ST_crossing
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lST_intersecting_IS_of_ST_crossing] ON [dbo].[lST_intersecting_IS_of_ST_crossing]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[ST_intersecting_IS_of_ST_crossing] (
        Metadata_ST_intersecting_IS_of_ST_crossing,
        ST_ID_intersecting,
        IS_ID_of,
        ST_ID_crossing
    )
    SELECT
        i.Metadata_ST_intersecting_IS_of_ST_crossing,
        i.ST_ID_intersecting,
        i.IS_ID_of,
        i.ST_ID_crossing
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_intersecting_IS_of_ST_crossing instead of UPDATE trigger on lST_intersecting_IS_of_ST_crossing
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lST_intersecting_IS_of_ST_crossing] ON [dbo].[lST_intersecting_IS_of_ST_crossing]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(ST_ID_intersecting))
        RAISERROR('The identity column ST_ID_intersecting is not updatable.', 16, 1);
    IF(UPDATE(ST_ID_crossing))
        RAISERROR('The identity column ST_ID_crossing is not updatable.', 16, 1);
    INSERT INTO [dbo].[ST_intersecting_IS_of_ST_crossing] (
        Metadata_ST_intersecting_IS_of_ST_crossing,
        ST_ID_intersecting,
        IS_ID_of,
        ST_ID_crossing
    )
    SELECT
        i.Metadata_ST_intersecting_IS_of_ST_crossing,
        i.ST_ID_intersecting,
        i.IS_ID_of,
        i.ST_ID_crossing
    FROM
        inserted i; 
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_intersecting_IS_of_ST_crossing instead of DELETE trigger on lST_intersecting_IS_of_ST_crossing
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lST_intersecting_IS_of_ST_crossing] ON [dbo].[lST_intersecting_IS_of_ST_crossing]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[ST_intersecting_IS_of_ST_crossing] tie
    JOIN
        deleted d
    ON
        d.ST_ID_intersecting = tie.ST_ID_intersecting
    AND
        d.ST_ID_crossing = tie.ST_ID_crossing;
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
   N'<schema format="0.99.6.2" date="2020-09-18" time="13:38:53"><metadata changingRange="date" encapsulation="dbo" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="true" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="tinyint" reliabilitySuffix="Reliability" deleteReliability="0" assertionSuffix="Assertion" partitioning="false" entityIntegrity="true" restatability="false" idempotency="true" assertiveness="false" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2(7)" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="false" decisiveness="true" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="uni" deletability="false" deletablePrefix="Deletable" deletionSuffix="Deleted" privacy="Ignore" checksum="false"/><anchor mnemonic="ST" descriptor="Street" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(555)"><metadata privacy="Ignore" capsule="dbo" deletable="false"/><layout x="811.12" y="627.80" fixed="false"/></attribute><layout x="833.28" y="572.21" fixed="true"/></anchor><anchor mnemonic="IS" descriptor="Intersection" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="COL" descriptor="CollisionCount" timeRange="date" dataRange="int"><metadata privacy="Ignore" capsule="dbo" restatable="false" idempotent="true" deletable="false"/><layout x="868.55" y="368.42" fixed="false"/></attribute><attribute mnemonic="INJ" descriptor="InjuredCount" timeRange="date" dataRange="int"><metadata privacy="Ignore" capsule="dbo" restatable="false" idempotent="true" deletable="false"/><layout x="909.90" y="323.48" fixed="false"/></attribute><attribute mnemonic="KIL" descriptor="KilledCount" timeRange="date" dataRange="int"><metadata privacy="Ignore" capsule="dbo" restatable="false" idempotent="true" deletable="false"/><layout x="966.00" y="367.00" fixed="false"/></attribute><attribute mnemonic="VEH" descriptor="VehicleCount" timeRange="date" dataRange="smallint"><metadata privacy="Ignore" capsule="dbo" restatable="false" idempotent="true" deletable="false"/><layout x="953.42" y="432.55" fixed="false"/></attribute><layout x="900.77" y="403.78" fixed="false"/></anchor><tie><anchorRole role="intersecting" type="ST" identifier="true"/><anchorRole role="of" type="IS" identifier="false"/><anchorRole role="crossing" type="ST" identifier="true"/><metadata capsule="dbo" deletable="false"/><layout x="857.65" y="494.83" fixed="false"/></tie></schema>';
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
   Nodeset.anchor.value('count(attribute)', 'int') as [numberOfAttributes],
   Nodeset.anchor.value('description[1]/.', 'nvarchar(max)') as [description]
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
   isnull(Nodeset.knot.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent],
   Nodeset.knot.value('description[1]/.', 'nvarchar(max)') as [description]
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
   Nodeset.tie.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   Nodeset.tie.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/tie') as Nodeset(tie);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- The key view shows information about all the keys in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Key', 'V') IS NOT NULL
DROP VIEW [dbo].[_Key]
GO
CREATE VIEW [dbo].[_Key]
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