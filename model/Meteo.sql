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
-- MM_Measurement table (with 5 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.MM_Measurement', 'U') IS NULL
CREATE TABLE [dbo].[MM_Measurement] (
    MM_ID int IDENTITY(1,1) not null,
    Metadata_MM int not null, 
    constraint pkMM_Measurement primary key (
        MM_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- MM_DAT_Measurement_Date table (on MM_Measurement)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.MM_DAT_Measurement_Date', 'U') IS NULL
CREATE TABLE [dbo].[MM_DAT_Measurement_Date] (
    MM_DAT_MM_ID int not null,
    MM_DAT_Measurement_Date date not null,
    Metadata_MM_DAT int not null,
    constraint fkMM_DAT_Measurement_Date foreign key (
        MM_DAT_MM_ID
    ) references [dbo].[MM_Measurement](MM_ID),
    constraint pkMM_DAT_Measurement_Date primary key (
        MM_DAT_MM_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- MM_HOU_Measurement_Hour table (on MM_Measurement)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.MM_HOU_Measurement_Hour', 'U') IS NULL
CREATE TABLE [dbo].[MM_HOU_Measurement_Hour] (
    MM_HOU_MM_ID int not null,
    MM_HOU_Measurement_Hour char(2) not null,
    Metadata_MM_HOU int not null,
    constraint fkMM_HOU_Measurement_Hour foreign key (
        MM_HOU_MM_ID
    ) references [dbo].[MM_Measurement](MM_ID),
    constraint pkMM_HOU_Measurement_Hour primary key (
        MM_HOU_MM_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- MM_TMP_Measurement_Temperature table (on MM_Measurement)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.MM_TMP_Measurement_Temperature', 'U') IS NULL
CREATE TABLE [dbo].[MM_TMP_Measurement_Temperature] (
    MM_TMP_MM_ID int not null,
    MM_TMP_Measurement_Temperature decimal(19,10) not null,
    Metadata_MM_TMP int not null,
    constraint fkMM_TMP_Measurement_Temperature foreign key (
        MM_TMP_MM_ID
    ) references [dbo].[MM_Measurement](MM_ID),
    constraint pkMM_TMP_Measurement_Temperature primary key (
        MM_TMP_MM_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- MM_PRS_Measurement_Pressure table (on MM_Measurement)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.MM_PRS_Measurement_Pressure', 'U') IS NULL
CREATE TABLE [dbo].[MM_PRS_Measurement_Pressure] (
    MM_PRS_MM_ID int not null,
    MM_PRS_Measurement_Pressure decimal(19,10) not null,
    Metadata_MM_PRS int not null,
    constraint fkMM_PRS_Measurement_Pressure foreign key (
        MM_PRS_MM_ID
    ) references [dbo].[MM_Measurement](MM_ID),
    constraint pkMM_PRS_Measurement_Pressure primary key (
        MM_PRS_MM_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- MM_WND_Measurement_WindSpeed table (on MM_Measurement)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.MM_WND_Measurement_WindSpeed', 'U') IS NULL
CREATE TABLE [dbo].[MM_WND_Measurement_WindSpeed] (
    MM_WND_MM_ID int not null,
    MM_WND_Measurement_WindSpeed decimal(19,10) not null,
    MM_WND_ChangedAt datetime not null,
    Metadata_MM_WND int not null,
    constraint fkMM_WND_Measurement_WindSpeed foreign key (
        MM_WND_MM_ID
    ) references [dbo].[MM_Measurement](MM_ID),
    constraint pkMM_WND_Measurement_WindSpeed primary key (
        MM_WND_MM_ID asc,
        MM_WND_ChangedAt desc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- OC_Occasion table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OC_Occasion', 'U') IS NULL
CREATE TABLE [dbo].[OC_Occasion] (
    OC_ID int IDENTITY(1,1) not null,
    Metadata_OC int not null, 
    constraint pkOC_Occasion primary key (
        OC_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- OC_TYP_Occasion_Type table (on OC_Occasion)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OC_TYP_Occasion_Type', 'U') IS NULL
CREATE TABLE [dbo].[OC_TYP_Occasion_Type] (
    OC_TYP_OC_ID int not null,
    OC_TYP_Occasion_Type varchar(42) not null,
    Metadata_OC_TYP int not null,
    constraint fkOC_TYP_Occasion_Type foreign key (
        OC_TYP_OC_ID
    ) references [dbo].[OC_Occasion](OC_ID),
    constraint pkOC_TYP_Occasion_Type primary key (
        OC_TYP_OC_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- OC_WDY_Occasion_Weekday table (on OC_Occasion)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OC_WDY_Occasion_Weekday', 'U') IS NULL
CREATE TABLE [dbo].[OC_WDY_Occasion_Weekday] (
    OC_WDY_OC_ID int not null,
    OC_WDY_Occasion_Weekday varchar(42) not null,
    Metadata_OC_WDY int not null,
    constraint fkOC_WDY_Occasion_Weekday foreign key (
        OC_WDY_OC_ID
    ) references [dbo].[OC_Occasion](OC_ID),
    constraint pkOC_WDY_Occasion_Weekday primary key (
        OC_WDY_OC_ID asc
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
-- MM_taken_OC_on table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.MM_taken_OC_on', 'U') IS NULL
CREATE TABLE [dbo].[MM_taken_OC_on] (
    MM_ID_taken int not null, 
    OC_ID_on int not null, 
    Metadata_MM_taken_OC_on int not null,
    constraint MM_taken_OC_on_fkMM_taken foreign key (
        MM_ID_taken
    ) references [dbo].[MM_Measurement](MM_ID), 
    constraint MM_taken_OC_on_fkOC_on foreign key (
        OC_ID_on
    ) references [dbo].[OC_Occasion](OC_ID), 
    constraint pkMM_taken_OC_on primary key (
        MM_ID_taken asc,
        OC_ID_on asc
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
-- rfMM_WND_Measurement_WindSpeed restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcMM_WND_Measurement_WindSpeed restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfMM_WND_Measurement_WindSpeed', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfMM_WND_Measurement_WindSpeed] (
        @id int,
        @value decimal(19,10),
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
                        pre.MM_WND_Measurement_WindSpeed
                    FROM
                        [dbo].[MM_WND_Measurement_WindSpeed] pre
                    WHERE
                        pre.MM_WND_MM_ID = @id
                    AND
                        pre.MM_WND_ChangedAt < @changed
                    ORDER BY
                        pre.MM_WND_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.MM_WND_Measurement_WindSpeed
                    FROM
                        [dbo].[MM_WND_Measurement_WindSpeed] fol
                    WHERE
                        fol.MM_WND_MM_ID = @id
                    AND
                        fol.MM_WND_ChangedAt > @changed
                    ORDER BY
                        fol.MM_WND_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- KEY GENERATORS -----------------------------------------------------------------------------------------------------
--
-- These stored procedures can be used to generate identities of entities.
-- Corresponding anchors must have an incrementing identity column.
--
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kMM_Measurement identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kMM_Measurement', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kMM_Measurement] (
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
            INSERT INTO [dbo].[MM_Measurement] (
                Metadata_MM
            )
            OUTPUT
                inserted.MM_ID
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
-- kOC_Occasion identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kOC_Occasion', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kOC_Occasion] (
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
            INSERT INTO [dbo].[OC_Occasion] (
                Metadata_OC
            )
            OUTPUT
                inserted.OC_ID
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
-- rMM_WND_Measurement_WindSpeed rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rMM_WND_Measurement_WindSpeed','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rMM_WND_Measurement_WindSpeed] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_MM_WND,
        MM_WND_MM_ID,
        MM_WND_Measurement_WindSpeed,
        MM_WND_ChangedAt
    FROM
        [dbo].[MM_WND_Measurement_WindSpeed]
    WHERE
        MM_WND_ChangedAt <= @changingTimepoint;
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
IF Object_ID('dbo.dMM_Measurement', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dMM_Measurement];
IF Object_ID('dbo.nMM_Measurement', 'V') IS NOT NULL
DROP VIEW [dbo].[nMM_Measurement];
IF Object_ID('dbo.pMM_Measurement', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pMM_Measurement];
IF Object_ID('dbo.lMM_Measurement', 'V') IS NOT NULL
DROP VIEW [dbo].[lMM_Measurement];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lMM_Measurement viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lMM_Measurement] WITH SCHEMABINDING AS
SELECT
    [MM].MM_ID,
    [MM].Metadata_MM,
    [DAT].MM_DAT_MM_ID,
    [DAT].Metadata_MM_DAT,
    [DAT].MM_DAT_Measurement_Date,
    [HOU].MM_HOU_MM_ID,
    [HOU].Metadata_MM_HOU,
    [HOU].MM_HOU_Measurement_Hour,
    [TMP].MM_TMP_MM_ID,
    [TMP].Metadata_MM_TMP,
    [TMP].MM_TMP_Measurement_Temperature,
    [PRS].MM_PRS_MM_ID,
    [PRS].Metadata_MM_PRS,
    [PRS].MM_PRS_Measurement_Pressure,
    [WND].MM_WND_MM_ID,
    [WND].Metadata_MM_WND,
    [WND].MM_WND_ChangedAt,
    [WND].MM_WND_Measurement_WindSpeed
FROM
    [dbo].[MM_Measurement] [MM]
LEFT JOIN
    [dbo].[MM_DAT_Measurement_Date] [DAT]
ON
    [DAT].MM_DAT_MM_ID = [MM].MM_ID
LEFT JOIN
    [dbo].[MM_HOU_Measurement_Hour] [HOU]
ON
    [HOU].MM_HOU_MM_ID = [MM].MM_ID
LEFT JOIN
    [dbo].[MM_TMP_Measurement_Temperature] [TMP]
ON
    [TMP].MM_TMP_MM_ID = [MM].MM_ID
LEFT JOIN
    [dbo].[MM_PRS_Measurement_Pressure] [PRS]
ON
    [PRS].MM_PRS_MM_ID = [MM].MM_ID
LEFT JOIN
    [dbo].[MM_WND_Measurement_WindSpeed] [WND]
ON
    [WND].MM_WND_MM_ID = [MM].MM_ID
AND
    [WND].MM_WND_ChangedAt = (
        SELECT
            max(sub.MM_WND_ChangedAt)
        FROM
            [dbo].[MM_WND_Measurement_WindSpeed] sub
        WHERE
            sub.MM_WND_MM_ID = [MM].MM_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pMM_Measurement viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pMM_Measurement] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [MM].MM_ID,
    [MM].Metadata_MM,
    [DAT].MM_DAT_MM_ID,
    [DAT].Metadata_MM_DAT,
    [DAT].MM_DAT_Measurement_Date,
    [HOU].MM_HOU_MM_ID,
    [HOU].Metadata_MM_HOU,
    [HOU].MM_HOU_Measurement_Hour,
    [TMP].MM_TMP_MM_ID,
    [TMP].Metadata_MM_TMP,
    [TMP].MM_TMP_Measurement_Temperature,
    [PRS].MM_PRS_MM_ID,
    [PRS].Metadata_MM_PRS,
    [PRS].MM_PRS_Measurement_Pressure,
    [WND].MM_WND_MM_ID,
    [WND].Metadata_MM_WND,
    [WND].MM_WND_ChangedAt,
    [WND].MM_WND_Measurement_WindSpeed
FROM
    [dbo].[MM_Measurement] [MM]
LEFT JOIN
    [dbo].[MM_DAT_Measurement_Date] [DAT]
ON
    [DAT].MM_DAT_MM_ID = [MM].MM_ID
LEFT JOIN
    [dbo].[MM_HOU_Measurement_Hour] [HOU]
ON
    [HOU].MM_HOU_MM_ID = [MM].MM_ID
LEFT JOIN
    [dbo].[MM_TMP_Measurement_Temperature] [TMP]
ON
    [TMP].MM_TMP_MM_ID = [MM].MM_ID
LEFT JOIN
    [dbo].[MM_PRS_Measurement_Pressure] [PRS]
ON
    [PRS].MM_PRS_MM_ID = [MM].MM_ID
LEFT JOIN
    [dbo].[rMM_WND_Measurement_WindSpeed](@changingTimepoint) [WND]
ON
    [WND].MM_WND_MM_ID = [MM].MM_ID
AND
    [WND].MM_WND_ChangedAt = (
        SELECT
            max(sub.MM_WND_ChangedAt)
        FROM
            [dbo].[rMM_WND_Measurement_WindSpeed](@changingTimepoint) sub
        WHERE
            sub.MM_WND_MM_ID = [MM].MM_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nMM_Measurement viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nMM_Measurement]
AS
SELECT
    *
FROM
    [dbo].[pMM_Measurement](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dMM_Measurement showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dMM_Measurement] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pMM].*
FROM (
    SELECT DISTINCT
        MM_WND_MM_ID AS MM_ID,
        MM_WND_ChangedAt AS inspectedTimepoint,
        'WND' AS mnemonic
    FROM
        [dbo].[MM_WND_Measurement_WindSpeed]
    WHERE
        (@selection is null OR @selection like '%WND%')
    AND
        MM_WND_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[pMM_Measurement](timepoints.inspectedTimepoint) [pMM]
WHERE
    [pMM].MM_ID = timepoints.MM_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dOC_Occasion', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dOC_Occasion];
IF Object_ID('dbo.nOC_Occasion', 'V') IS NOT NULL
DROP VIEW [dbo].[nOC_Occasion];
IF Object_ID('dbo.pOC_Occasion', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pOC_Occasion];
IF Object_ID('dbo.lOC_Occasion', 'V') IS NOT NULL
DROP VIEW [dbo].[lOC_Occasion];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOC_Occasion viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lOC_Occasion] WITH SCHEMABINDING AS
SELECT
    [OC].OC_ID,
    [OC].Metadata_OC,
    [TYP].OC_TYP_OC_ID,
    [TYP].Metadata_OC_TYP,
    [TYP].OC_TYP_Occasion_Type,
    [WDY].OC_WDY_OC_ID,
    [WDY].Metadata_OC_WDY,
    [WDY].OC_WDY_Occasion_Weekday
FROM
    [dbo].[OC_Occasion] [OC]
LEFT JOIN
    [dbo].[OC_TYP_Occasion_Type] [TYP]
ON
    [TYP].OC_TYP_OC_ID = [OC].OC_ID
LEFT JOIN
    [dbo].[OC_WDY_Occasion_Weekday] [WDY]
ON
    [WDY].OC_WDY_OC_ID = [OC].OC_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pOC_Occasion viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pOC_Occasion] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [OC].OC_ID,
    [OC].Metadata_OC,
    [TYP].OC_TYP_OC_ID,
    [TYP].Metadata_OC_TYP,
    [TYP].OC_TYP_Occasion_Type,
    [WDY].OC_WDY_OC_ID,
    [WDY].Metadata_OC_WDY,
    [WDY].OC_WDY_Occasion_Weekday
FROM
    [dbo].[OC_Occasion] [OC]
LEFT JOIN
    [dbo].[OC_TYP_Occasion_Type] [TYP]
ON
    [TYP].OC_TYP_OC_ID = [OC].OC_ID
LEFT JOIN
    [dbo].[OC_WDY_Occasion_Weekday] [WDY]
ON
    [WDY].OC_WDY_OC_ID = [OC].OC_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOC_Occasion viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nOC_Occasion]
AS
SELECT
    *
FROM
    [dbo].[pOC_Occasion](sysdatetime());
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
-- itMM_Measurement instead of INSERT trigger on lMM_Measurement
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[itMM_Measurement] ON [dbo].[lMM_Measurement]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @MM TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        MM_ID int not null
    );
    INSERT INTO [dbo].[MM_Measurement] (
        Metadata_MM 
    )
    OUTPUT
        inserted.MM_ID
    INTO
        @MM
    SELECT
        Metadata_MM 
    FROM
        inserted
    WHERE
        inserted.MM_ID is null;
    DECLARE @inserted TABLE (
        MM_ID int not null,
        Metadata_MM int not null,
        MM_DAT_MM_ID int null,
        Metadata_MM_DAT int null,
        MM_DAT_Measurement_Date date null,
        MM_HOU_MM_ID int null,
        Metadata_MM_HOU int null,
        MM_HOU_Measurement_Hour char(2) null,
        MM_TMP_MM_ID int null,
        Metadata_MM_TMP int null,
        MM_TMP_Measurement_Temperature decimal(19,10) null,
        MM_PRS_MM_ID int null,
        Metadata_MM_PRS int null,
        MM_PRS_Measurement_Pressure decimal(19,10) null,
        MM_WND_MM_ID int null,
        Metadata_MM_WND int null,
        MM_WND_ChangedAt datetime null,
        MM_WND_Measurement_WindSpeed decimal(19,10) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.MM_ID, a.MM_ID),
        i.Metadata_MM,
        ISNULL(ISNULL(i.MM_DAT_MM_ID, i.MM_ID), a.MM_ID),
        ISNULL(i.Metadata_MM_DAT, i.Metadata_MM),
        i.MM_DAT_Measurement_Date,
        ISNULL(ISNULL(i.MM_HOU_MM_ID, i.MM_ID), a.MM_ID),
        ISNULL(i.Metadata_MM_HOU, i.Metadata_MM),
        i.MM_HOU_Measurement_Hour,
        ISNULL(ISNULL(i.MM_TMP_MM_ID, i.MM_ID), a.MM_ID),
        ISNULL(i.Metadata_MM_TMP, i.Metadata_MM),
        i.MM_TMP_Measurement_Temperature,
        ISNULL(ISNULL(i.MM_PRS_MM_ID, i.MM_ID), a.MM_ID),
        ISNULL(i.Metadata_MM_PRS, i.Metadata_MM),
        i.MM_PRS_Measurement_Pressure,
        ISNULL(ISNULL(i.MM_WND_MM_ID, i.MM_ID), a.MM_ID),
        ISNULL(i.Metadata_MM_WND, i.Metadata_MM),
        ISNULL(i.MM_WND_ChangedAt, @now),
        i.MM_WND_Measurement_WindSpeed
    FROM (
        SELECT
            MM_ID,
            Metadata_MM,
            MM_DAT_MM_ID,
            Metadata_MM_DAT,
            MM_DAT_Measurement_Date,
            MM_HOU_MM_ID,
            Metadata_MM_HOU,
            MM_HOU_Measurement_Hour,
            MM_TMP_MM_ID,
            Metadata_MM_TMP,
            MM_TMP_Measurement_Temperature,
            MM_PRS_MM_ID,
            Metadata_MM_PRS,
            MM_PRS_Measurement_Pressure,
            MM_WND_MM_ID,
            Metadata_MM_WND,
            MM_WND_ChangedAt,
            MM_WND_Measurement_WindSpeed,
            ROW_NUMBER() OVER (PARTITION BY MM_ID ORDER BY MM_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @MM a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[MM_DAT_Measurement_Date] (
        MM_DAT_MM_ID,
        Metadata_MM_DAT,
        MM_DAT_Measurement_Date
    )
    SELECT
        i.MM_DAT_MM_ID,
        i.Metadata_MM_DAT,
        i.MM_DAT_Measurement_Date
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[MM_DAT_Measurement_Date] [DAT]
    ON
        [DAT].MM_DAT_MM_ID = i.MM_DAT_MM_ID
    WHERE
        [DAT].MM_DAT_MM_ID is null
    AND
        i.MM_DAT_Measurement_Date is not null;
    INSERT INTO [dbo].[MM_HOU_Measurement_Hour] (
        MM_HOU_MM_ID,
        Metadata_MM_HOU,
        MM_HOU_Measurement_Hour
    )
    SELECT
        i.MM_HOU_MM_ID,
        i.Metadata_MM_HOU,
        i.MM_HOU_Measurement_Hour
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[MM_HOU_Measurement_Hour] [HOU]
    ON
        [HOU].MM_HOU_MM_ID = i.MM_HOU_MM_ID
    WHERE
        [HOU].MM_HOU_MM_ID is null
    AND
        i.MM_HOU_Measurement_Hour is not null;
    INSERT INTO [dbo].[MM_TMP_Measurement_Temperature] (
        MM_TMP_MM_ID,
        Metadata_MM_TMP,
        MM_TMP_Measurement_Temperature
    )
    SELECT
        i.MM_TMP_MM_ID,
        i.Metadata_MM_TMP,
        i.MM_TMP_Measurement_Temperature
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[MM_TMP_Measurement_Temperature] [TMP]
    ON
        [TMP].MM_TMP_MM_ID = i.MM_TMP_MM_ID
    WHERE
        [TMP].MM_TMP_MM_ID is null
    AND
        i.MM_TMP_Measurement_Temperature is not null;
    INSERT INTO [dbo].[MM_PRS_Measurement_Pressure] (
        MM_PRS_MM_ID,
        Metadata_MM_PRS,
        MM_PRS_Measurement_Pressure
    )
    SELECT
        i.MM_PRS_MM_ID,
        i.Metadata_MM_PRS,
        i.MM_PRS_Measurement_Pressure
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[MM_PRS_Measurement_Pressure] [PRS]
    ON
        [PRS].MM_PRS_MM_ID = i.MM_PRS_MM_ID
    WHERE
        [PRS].MM_PRS_MM_ID is null
    AND
        i.MM_PRS_Measurement_Pressure is not null;
    DECLARE @MM_WND_Measurement_WindSpeed TABLE (
        MM_WND_MM_ID int not null,
        Metadata_MM_WND int not null,
        MM_WND_ChangedAt datetime not null,
        MM_WND_Measurement_WindSpeed decimal(19,10) not null,
        MM_WND_Version bigint not null,
        MM_WND_StatementType char(1) not null,
        primary key(
            MM_WND_Version,
            MM_WND_MM_ID
        )
    );
    INSERT INTO @MM_WND_Measurement_WindSpeed
    SELECT
        i.MM_WND_MM_ID,
        i.Metadata_MM_WND,
        i.MM_WND_ChangedAt,
        i.MM_WND_Measurement_WindSpeed,
        DENSE_RANK() OVER (
            PARTITION BY
                i.MM_WND_MM_ID
            ORDER BY
                i.MM_WND_ChangedAt ASC
        ),
        'X'
    FROM
        @inserted i
    WHERE
        i.MM_WND_Measurement_WindSpeed is not null;
    SELECT
        @maxVersion = max(MM_WND_Version),
        @currentVersion = 0
    FROM
        @MM_WND_Measurement_WindSpeed;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.MM_WND_StatementType =
                CASE
                    WHEN [WND].MM_WND_MM_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [dbo].[rfMM_WND_Measurement_WindSpeed](
                        v.MM_WND_MM_ID,
                        v.MM_WND_Measurement_WindSpeed,
                        v.MM_WND_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @MM_WND_Measurement_WindSpeed v
        LEFT JOIN
            [dbo].[MM_WND_Measurement_WindSpeed] [WND]
        ON
            [WND].MM_WND_MM_ID = v.MM_WND_MM_ID
        AND
            [WND].MM_WND_ChangedAt = v.MM_WND_ChangedAt
        AND
            [WND].MM_WND_Measurement_WindSpeed = v.MM_WND_Measurement_WindSpeed
        WHERE
            v.MM_WND_Version = @currentVersion;
        INSERT INTO [dbo].[MM_WND_Measurement_WindSpeed] (
            MM_WND_MM_ID,
            Metadata_MM_WND,
            MM_WND_ChangedAt,
            MM_WND_Measurement_WindSpeed
        )
        SELECT
            MM_WND_MM_ID,
            Metadata_MM_WND,
            MM_WND_ChangedAt,
            MM_WND_Measurement_WindSpeed
        FROM
            @MM_WND_Measurement_WindSpeed
        WHERE
            MM_WND_Version = @currentVersion
        AND
            MM_WND_StatementType in ('N','R');
    END
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utMM_Measurement instead of UPDATE trigger on lMM_Measurement
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[utMM_Measurement] ON [dbo].[lMM_Measurement]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(MM_ID))
        RAISERROR('The identity column MM_ID is not updatable.', 16, 1);
    IF(UPDATE(MM_WND_Measurement_WindSpeed))
    INSERT INTO [dbo].[MM_WND_Measurement_WindSpeed] (
        MM_WND_MM_ID,
        Metadata_MM_WND,
        MM_WND_ChangedAt,
        MM_WND_Measurement_WindSpeed
    )
    SELECT
        u.MM_WND_MM_ID,
        CASE WHEN UPDATE(Metadata_MM_WND) THEN i.Metadata_MM_WND ELSE 0 END,
        u.MM_WND_ChangedAt,
        i.MM_WND_Measurement_WindSpeed
    FROM
        inserted i
    CROSS APPLY (
        SELECT
            ISNULL(i.MM_WND_MM_ID, i.MM_ID),
            cast(CASE WHEN UPDATE(MM_WND_ChangedAt) THEN i.MM_WND_ChangedAt ELSE @now END as datetime)
    ) u (
        MM_WND_MM_ID,
        MM_WND_ChangedAt
    );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtMM_Measurement instead of DELETE trigger on lMM_Measurement
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dtMM_Measurement] ON [dbo].[lMM_Measurement]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [DAT]
    FROM
        [dbo].[MM_DAT_Measurement_Date] [DAT]
    JOIN
        deleted d
    ON
        d.MM_DAT_MM_ID = [DAT].MM_DAT_MM_ID
    DELETE [HOU]
    FROM
        [dbo].[MM_HOU_Measurement_Hour] [HOU]
    JOIN
        deleted d
    ON
        d.MM_HOU_MM_ID = [HOU].MM_HOU_MM_ID
    DELETE [TMP]
    FROM
        [dbo].[MM_TMP_Measurement_Temperature] [TMP]
    JOIN
        deleted d
    ON
        d.MM_TMP_MM_ID = [TMP].MM_TMP_MM_ID
    DELETE [PRS]
    FROM
        [dbo].[MM_PRS_Measurement_Pressure] [PRS]
    JOIN
        deleted d
    ON
        d.MM_PRS_MM_ID = [PRS].MM_PRS_MM_ID
    DELETE [WND]
    FROM
        [dbo].[MM_WND_Measurement_WindSpeed] [WND]
    JOIN
        deleted d
    ON
        d.MM_WND_MM_ID = [WND].MM_WND_MM_ID
    AND
        d.MM_WND_ChangedAt = [WND].MM_WND_ChangedAt;
    DELETE [MM]
    FROM
        [dbo].[MM_Measurement] [MM]
    LEFT JOIN
        [dbo].[MM_DAT_Measurement_Date] [DAT]
    ON
        [DAT].MM_DAT_MM_ID = [MM].MM_ID
    LEFT JOIN
        [dbo].[MM_HOU_Measurement_Hour] [HOU]
    ON
        [HOU].MM_HOU_MM_ID = [MM].MM_ID
    LEFT JOIN
        [dbo].[MM_TMP_Measurement_Temperature] [TMP]
    ON
        [TMP].MM_TMP_MM_ID = [MM].MM_ID
    LEFT JOIN
        [dbo].[MM_PRS_Measurement_Pressure] [PRS]
    ON
        [PRS].MM_PRS_MM_ID = [MM].MM_ID
    LEFT JOIN
        [dbo].[MM_WND_Measurement_WindSpeed] [WND]
    ON
        [WND].MM_WND_MM_ID = [MM].MM_ID
    WHERE
        [DAT].MM_DAT_MM_ID is null
    AND
        [HOU].MM_HOU_MM_ID is null
    AND
        [TMP].MM_TMP_MM_ID is null
    AND
        [PRS].MM_PRS_MM_ID is null
    AND
        [WND].MM_WND_MM_ID is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itOC_Occasion instead of INSERT trigger on lOC_Occasion
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[itOC_Occasion] ON [dbo].[lOC_Occasion]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @OC TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        OC_ID int not null
    );
    INSERT INTO [dbo].[OC_Occasion] (
        Metadata_OC 
    )
    OUTPUT
        inserted.OC_ID
    INTO
        @OC
    SELECT
        Metadata_OC 
    FROM
        inserted
    WHERE
        inserted.OC_ID is null;
    DECLARE @inserted TABLE (
        OC_ID int not null,
        Metadata_OC int not null,
        OC_TYP_OC_ID int null,
        Metadata_OC_TYP int null,
        OC_TYP_Occasion_Type varchar(42) null,
        OC_WDY_OC_ID int null,
        Metadata_OC_WDY int null,
        OC_WDY_Occasion_Weekday varchar(42) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.OC_ID, a.OC_ID),
        i.Metadata_OC,
        ISNULL(ISNULL(i.OC_TYP_OC_ID, i.OC_ID), a.OC_ID),
        ISNULL(i.Metadata_OC_TYP, i.Metadata_OC),
        i.OC_TYP_Occasion_Type,
        ISNULL(ISNULL(i.OC_WDY_OC_ID, i.OC_ID), a.OC_ID),
        ISNULL(i.Metadata_OC_WDY, i.Metadata_OC),
        i.OC_WDY_Occasion_Weekday
    FROM (
        SELECT
            OC_ID,
            Metadata_OC,
            OC_TYP_OC_ID,
            Metadata_OC_TYP,
            OC_TYP_Occasion_Type,
            OC_WDY_OC_ID,
            Metadata_OC_WDY,
            OC_WDY_Occasion_Weekday,
            ROW_NUMBER() OVER (PARTITION BY OC_ID ORDER BY OC_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @OC a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[OC_TYP_Occasion_Type] (
        OC_TYP_OC_ID,
        Metadata_OC_TYP,
        OC_TYP_Occasion_Type
    )
    SELECT
        i.OC_TYP_OC_ID,
        i.Metadata_OC_TYP,
        i.OC_TYP_Occasion_Type
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[OC_TYP_Occasion_Type] [TYP]
    ON
        [TYP].OC_TYP_OC_ID = i.OC_TYP_OC_ID
    WHERE
        [TYP].OC_TYP_OC_ID is null
    AND
        i.OC_TYP_Occasion_Type is not null;
    INSERT INTO [dbo].[OC_WDY_Occasion_Weekday] (
        OC_WDY_OC_ID,
        Metadata_OC_WDY,
        OC_WDY_Occasion_Weekday
    )
    SELECT
        i.OC_WDY_OC_ID,
        i.Metadata_OC_WDY,
        i.OC_WDY_Occasion_Weekday
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[OC_WDY_Occasion_Weekday] [WDY]
    ON
        [WDY].OC_WDY_OC_ID = i.OC_WDY_OC_ID
    WHERE
        [WDY].OC_WDY_OC_ID is null
    AND
        i.OC_WDY_Occasion_Weekday is not null;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtOC_Occasion instead of DELETE trigger on lOC_Occasion
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dtOC_Occasion] ON [dbo].[lOC_Occasion]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [TYP]
    FROM
        [dbo].[OC_TYP_Occasion_Type] [TYP]
    JOIN
        deleted d
    ON
        d.OC_TYP_OC_ID = [TYP].OC_TYP_OC_ID
    DELETE [WDY]
    FROM
        [dbo].[OC_WDY_Occasion_Weekday] [WDY]
    JOIN
        deleted d
    ON
        d.OC_WDY_OC_ID = [WDY].OC_WDY_OC_ID
        ;
    DELETE [OC]
    FROM
        [dbo].[OC_Occasion] [OC]
    LEFT JOIN
        [dbo].[OC_TYP_Occasion_Type] [TYP]
    ON
        [TYP].OC_TYP_OC_ID = [OC].OC_ID
    LEFT JOIN
        [dbo].[OC_WDY_Occasion_Weekday] [WDY]
    ON
        [WDY].OC_WDY_OC_ID = [OC].OC_ID
    WHERE
        [TYP].OC_TYP_OC_ID is null
    AND
        [WDY].OC_WDY_OC_ID is null;
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
IF Object_ID('dbo.dMM_taken_OC_on', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dMM_taken_OC_on];
IF Object_ID('dbo.nMM_taken_OC_on', 'V') IS NOT NULL
DROP VIEW [dbo].[nMM_taken_OC_on];
IF Object_ID('dbo.pMM_taken_OC_on', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pMM_taken_OC_on];
IF Object_ID('dbo.lMM_taken_OC_on', 'V') IS NOT NULL
DROP VIEW [dbo].[lMM_taken_OC_on];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lMM_taken_OC_on viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lMM_taken_OC_on] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_MM_taken_OC_on,
    tie.MM_ID_taken,
    tie.OC_ID_on
FROM
    [dbo].[MM_taken_OC_on] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pMM_taken_OC_on viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pMM_taken_OC_on] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_MM_taken_OC_on,
    tie.MM_ID_taken,
    tie.OC_ID_on
FROM
    [dbo].[MM_taken_OC_on] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nMM_taken_OC_on viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nMM_taken_OC_on]
AS
SELECT
    *
FROM
    [dbo].[pMM_taken_OC_on](sysdatetime());
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
-- itMM_taken_OC_on instead of INSERT trigger on lMM_taken_OC_on
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[itMM_taken_OC_on] ON [dbo].[lMM_taken_OC_on]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_MM_taken_OC_on int not null,
        MM_ID_taken int not null,
        OC_ID_on int not null,
        primary key (
            MM_ID_taken,
            OC_ID_on
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_MM_taken_OC_on, 0),
        i.MM_ID_taken,
        i.OC_ID_on
    FROM
        inserted i
    WHERE
        i.MM_ID_taken is not null
    AND
        i.OC_ID_on is not null;
    INSERT INTO [dbo].[MM_taken_OC_on] (
        Metadata_MM_taken_OC_on,
        MM_ID_taken,
        OC_ID_on
    )
    SELECT
        i.Metadata_MM_taken_OC_on,
        i.MM_ID_taken,
        i.OC_ID_on
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[MM_taken_OC_on] tie
    ON
        tie.MM_ID_taken = i.MM_ID_taken
    AND
        tie.OC_ID_on = i.OC_ID_on
    WHERE
        tie.OC_ID_on is null;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtMM_taken_OC_on instead of DELETE trigger on lMM_taken_OC_on
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dtMM_taken_OC_on] ON [dbo].[lMM_taken_OC_on]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[MM_taken_OC_on] tie
    JOIN
        deleted d
    ON
        d.MM_ID_taken = tie.MM_ID_taken
    AND
        d.OC_ID_on = tie.OC_ID_on;
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
      [version] int identity(1, 1) not null primary key,
      [activation] datetime2(7) not null,
      [schema] xml not null
   );
GO
-- Insert the XML schema (as of now)
INSERT INTO [dbo].[_Schema] (
   [activation],
   [schema]
)
SELECT
   current_timestamp,
   N'<schema format="0.98" date="2014-09-24" time="15:06:59"><metadata changingRange="datetime" encapsulation="dbo" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="true" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="tinyint" reliabilitySuffix="Reliability" reliableCutoff="1" deleteReliability="0" reliableSuffix="Reliable" partitioning="false" entityIntegrity="true" restatability="true" idempotency="false" assertiveness="false" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2(7)" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="false" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="uni"/><anchor mnemonic="MM" descriptor="Measurement" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="DAT" descriptor="Date" dataRange="date"><metadata capsule="dbo"/><layout x="917.44" y="495.28" fixed="false"/></attribute><attribute mnemonic="HOU" descriptor="Hour" dataRange="char(2)"><metadata capsule="dbo"/><layout x="984.49" y="422.10" fixed="false"/></attribute><attribute mnemonic="TMP" descriptor="Temperature" dataRange="decimal(19,10)"><metadata capsule="dbo"/><layout x="853.46" y="479.47" fixed="false"/></attribute><attribute mnemonic="PRS" descriptor="Pressure" dataRange="decimal(19,10)"><metadata capsule="dbo"/><layout x="814.50" y="420.82" fixed="false"/></attribute><attribute mnemonic="WND" descriptor="WindSpeed" timeRange="datetime" dataRange="decimal(19,10)"><metadata capsule="dbo" restatable="true" idempotent="false"/><layout x="986.48" y="458.75" fixed="false"/></attribute><layout x="900.39" y="422.86" fixed="false"/></anchor><tie><anchorRole role="taken" type="MM" identifier="true"/><anchorRole role="on" type="OC" identifier="true"/><metadata capsule="dbo"/><layout x="989.18" y="367.84" fixed="false"/></tie><anchor mnemonic="OC" descriptor="Occasion" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="TYP" descriptor="Type" dataRange="varchar(42)"><metadata capsule="dbo"/><layout x="951.81" y="249.95" fixed="false"/></attribute><attribute mnemonic="WDY" descriptor="Weekday" dataRange="varchar(42)"><metadata capsule="dbo"/><layout x="968.78" y="225.59" fixed="false"/></attribute><layout x="1008.00" y="271.00" fixed="true"/></anchor></schema>';
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
	[schema].value('schema[1]/@date', 'date') as [date],
	[schema].value('schema[1]/@time', 'time(0)') as [time],
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
	[schema].value('schema[1]/metadata[1]/@reliableCutoff', 'nvarchar(max)') as [reliableCutoff],
	[schema].value('schema[1]/metadata[1]/@deleteReliability', 'nvarchar(max)') as [deleteReliability],
	[schema].value('schema[1]/metadata[1]/@reliableSuffix', 'nvarchar(max)') as [reliableSuffix],
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
    @timepoint AS DATETIME2(7)
)
RETURNS TABLE
RETURN
SELECT
   V.[version],
   ISNULL(S.[name], T.[name]) AS [name],
   ISNULL(V.[activation], T.[create_date]) AS [activation],
   CASE
      WHEN S.[name] is null THEN
         CASE
            WHEN T.[create_date] > (
               SELECT
                  ISNULL(MAX([activation]), @timepoint)
               FROM
                  [dbo].[_Schema]
               WHERE
                  [activation] <= @timepoint
            ) THEN 'Future'
            ELSE 'Past'
         END
      WHEN T.[name] is null THEN 'Missing'
      ELSE 'Present'
   END AS Existence
FROM (
   SELECT
      MAX([version]) as [version],
      MAX([activation]) as [activation]
   FROM
      [dbo].[_Schema]
   WHERE
      [activation] <= @timepoint
) V
JOIN (
   SELECT
      [name],
      [version]
   FROM
      [dbo].[_Anchor] a
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [dbo].[_Knot] k
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [dbo].[_Attribute] b
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [dbo].[_Tie] t
) S
ON
   S.[version] = V.[version]
FULL OUTER JOIN (
   SELECT
      [name],
      [create_date]
   FROM
      sys.tables
   WHERE
      [type] like '%U%'
   AND
      LEFT([name], 1) <> '_'
) T
ON
   S.[name] = T.[name];
GO
-- Drop Script Generator ----------------------------------------------------------------------------------------------
-- generates a drop script, that must be run separately, dropping everything in an Anchor Modeled database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._GenerateDropScript', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[_GenerateDropScript];
GO
CREATE PROCEDURE [dbo]._GenerateDropScript (
   @exclusionPattern varchar(42) = '[_]%', -- exclude Metadata by default
   @inclusionPattern varchar(42) = '%' -- include everything by default
)
AS
BEGIN
   DECLARE @xml XML;
   WITH objects AS (
      SELECT
         'DROP ' + ft.[type] + ' ' + fn.[name] + '; -- ' + fn.[description] as [statement],
         row_number() OVER (
            ORDER BY
               -- restatement finders last
               CASE dc.[description]
                  WHEN 'restatement finder' THEN 1
                  ELSE 0
               END ASC,
               -- order based on type
               CASE ft.[type]
                  WHEN 'PROCEDURE' THEN 1
                  WHEN 'FUNCTION' THEN 2
                  WHEN 'VIEW' THEN 3
                  WHEN 'TABLE' THEN 4
                  ELSE 5
               END ASC,
               -- order within type
               CASE dc.[description]
                  WHEN 'key generator' THEN 1
                  WHEN 'latest perspective' THEN 2
                  WHEN 'current perspective' THEN 3
                  WHEN 'difference perspective' THEN 4
                  WHEN 'point-in-time perspective' THEN 5
                  WHEN 'time traveler' THEN 6
                  WHEN 'rewinder' THEN 7
                  WHEN 'assembled view' THEN 8
                  WHEN 'annex table' THEN 9
                  WHEN 'posit table' THEN 10
                  WHEN 'table' THEN 11
                  WHEN 'restatement finder' THEN 12
                  ELSE 13
               END,
               -- order within description
               CASE ft.[type]
                  WHEN 'TABLE' THEN
                     CASE cl.[class]
                        WHEN 'Attribute' THEN 1
                        WHEN 'Attribute Annex' THEN 2
                        WHEN 'Attribute Posit' THEN 3
                        WHEN 'Tie' THEN 4
                        WHEN 'Anchor' THEN 5
                        WHEN 'Knot' THEN 6
                        ELSE 7
                     END
                  ELSE
                     CASE cl.[class]
                        WHEN 'Anchor' THEN 1
                        WHEN 'Attribute' THEN 2
                        WHEN 'Attribute Annex' THEN 3
                        WHEN 'Attribute Posit' THEN 4
                        WHEN 'Tie' THEN 5
                        WHEN 'Knot' THEN 6
                        ELSE 7
                     END
               END,
               -- finally alphabetically
               o.[name] ASC
         ) AS [ordinal]
      FROM
         sys.objects o
      JOIN
         sys.schemas s
      ON
         s.[schema_id] = o.[schema_id]
      CROSS APPLY (
         SELECT
            CASE
               WHEN o.[name] LIKE '[_]%'
               COLLATE Latin1_General_BIN THEN 'Metadata'
               WHEN o.[name] LIKE '%[A-Z][A-Z][_][a-z]%[A-Z][A-Z][_][a-z]%'
               COLLATE Latin1_General_BIN THEN 'Tie'
               WHEN o.[name] LIKE '%[A-Z][A-Z][_][A-Z][A-Z][A-Z][_][A-Z]%[_]%'
               COLLATE Latin1_General_BIN THEN 'Attribute'
               WHEN o.[name] LIKE '%[A-Z][A-Z][A-Z][_][A-Z]%'
               COLLATE Latin1_General_BIN THEN 'Knot'
               WHEN o.[name] LIKE '%[A-Z][A-Z][_][A-Z]%'
               COLLATE Latin1_General_BIN THEN 'Anchor'
               ELSE 'Other'
            END
      ) cl ([class])
      CROSS APPLY (
         SELECT
            CASE o.[type]
               WHEN 'P' THEN 'PROCEDURE'
               WHEN 'IF' THEN 'FUNCTION'
               WHEN 'FN' THEN 'FUNCTION'
               WHEN 'V' THEN 'VIEW'
               WHEN 'U' THEN 'TABLE'
            END
      ) ft ([type])
      CROSS APPLY (
         SELECT
            CASE
               WHEN ft.[type] = 'PROCEDURE' AND cl.[class] = 'Anchor' AND o.[name] LIKE 'k%'
               COLLATE Latin1_General_BIN THEN 'key generator'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 't%'
               COLLATE Latin1_General_BIN THEN 'time traveler'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'rf%'
               COLLATE Latin1_General_BIN THEN 'restatement finder'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'r%'
               COLLATE Latin1_General_BIN THEN 'rewinder'
               WHEN ft.[type] = 'VIEW' AND o.[name] LIKE 'l%'
               COLLATE Latin1_General_BIN THEN 'latest perspective'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'p%'
               COLLATE Latin1_General_BIN THEN 'point-in-time perspective'
               WHEN ft.[type] = 'VIEW' AND o.[name] LIKE 'n%'
               COLLATE Latin1_General_BIN THEN 'current perspective'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'd%'
               COLLATE Latin1_General_BIN THEN 'difference perspective'
               WHEN ft.[type] = 'VIEW' AND cl.[class] = 'Attribute'
               COLLATE Latin1_General_BIN THEN 'assembled view'
               WHEN ft.[type] = 'TABLE' AND o.[name] LIKE '%Annex'
               COLLATE Latin1_General_BIN THEN 'annex table'
               WHEN ft.[type] = 'TABLE' AND o.[name] LIKE '%Posit'
               COLLATE Latin1_General_BIN THEN 'posit table'
               WHEN ft.[type] = 'TABLE'
               COLLATE Latin1_General_BIN THEN 'table'
               ELSE 'other'
            END
      ) dc ([description])
      CROSS APPLY (
         SELECT
            s.[name] + '.' + o.[name],
            cl.[class] + ' ' + dc.[description]
      ) fn ([name], [description])
      WHERE
         o.[type] IN ('P', 'IF', 'FN', 'V', 'U')
      AND
         o.[name] NOT LIKE ISNULL(@exclusionPattern, '')
      AND
         o.[name] LIKE ISNULL(@inclusionPattern, '%')
   )
   SELECT @xml = (
       SELECT
          [statement] + CHAR(13) as [text()]
       FROM
          objects
       ORDER BY
          [ordinal]
       FOR XML PATH('')
   );
   SELECT isnull(@xml.value('.', 'varchar(max)'), ''); 
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
	declare @R char(1) = CHAR(13);
	-- stores the built SQL code
	declare @sql varchar(max) = 'USE ' + @target + ';' + @R;
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
	select @sql;
end
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------