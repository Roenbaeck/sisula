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
-- BA_Batch table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.BA_Batch', 'U') IS NULL
CREATE TABLE [metadata].[BA_Batch] (
    BA_ID int IDENTITY(1,1) not null,
    BA_Dummy bit null,
    constraint pkBA_Batch primary key (
        BA_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- BA_STA_Batch_Start table (on BA_Batch)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.BA_STA_Batch_Start', 'U') IS NULL
CREATE TABLE [metadata].[BA_STA_Batch_Start] (
    BA_STA_BA_ID int not null,
    BA_STA_Batch_Start datetime not null,
    constraint fkBA_STA_Batch_Start foreign key (
        BA_STA_BA_ID
    ) references [metadata].[BA_Batch](BA_ID),
    constraint pkBA_STA_Batch_Start primary key (
        BA_STA_BA_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- BA_END_Batch_End table (on BA_Batch)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.BA_END_Batch_End', 'U') IS NULL
CREATE TABLE [metadata].[BA_END_Batch_End] (
    BA_END_BA_ID int not null,
    BA_END_Batch_End datetime not null,
    constraint fkBA_END_Batch_End foreign key (
        BA_END_BA_ID
    ) references [metadata].[BA_Batch](BA_ID),
    constraint pkBA_END_Batch_End primary key (
        BA_END_BA_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- FI_File table (with 1 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.FI_File', 'U') IS NULL
CREATE TABLE [metadata].[FI_File] (
    FI_ID int IDENTITY(1,1) not null,
    FI_Dummy bit null,
    constraint pkFI_File primary key (
        FI_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- FI_NAM_File_Name table (on FI_File)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.FI_NAM_File_Name', 'U') IS NULL
CREATE TABLE [metadata].[FI_NAM_File_Name] (
    FI_NAM_FI_ID int not null,
    FI_NAM_File_Name varchar(2000) not null,
    constraint fkFI_NAM_File_Name foreign key (
        FI_NAM_FI_ID
    ) references [metadata].[FI_File](FI_ID),
    constraint pkFI_NAM_File_Name primary key (
        FI_NAM_FI_ID asc
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
-- BA_uses_FI_the table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.BA_uses_FI_the', 'U') IS NULL
CREATE TABLE [metadata].[BA_uses_FI_the] (
    BA_ID_uses int not null, 
    FI_ID_the int not null, 
    constraint BA_uses_FI_the_fkBA_uses foreign key (
        BA_ID_uses
    ) references [metadata].[BA_Batch](BA_ID), 
    constraint BA_uses_FI_the_fkFI_the foreign key (
        FI_ID_the
    ) references [metadata].[FI_File](FI_ID), 
    constraint pkBA_uses_FI_the primary key (
        BA_ID_uses asc,
        FI_ID_the asc
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
-- KEY GENERATORS -----------------------------------------------------------------------------------------------------
--
-- These stored procedures can be used to generate identities of entities.
-- Corresponding anchors must have an incrementing identity column.
--
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kBA_Batch identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kBA_Batch', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kBA_Batch] (
        @requestedNumberOfIdentities bigint
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
            INSERT INTO [metadata].[BA_Batch] (
                BA_Dummy
            )
            OUTPUT
                inserted.BA_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kFI_File identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kFI_File', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kFI_File] (
        @requestedNumberOfIdentities bigint
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
            INSERT INTO [metadata].[FI_File] (
                FI_Dummy
            )
            OUTPUT
                inserted.FI_ID
            SELECT
                null
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
IF Object_ID('metadata.dBA_Batch', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dBA_Batch];
IF Object_ID('metadata.nBA_Batch', 'V') IS NOT NULL
DROP VIEW [metadata].[nBA_Batch];
IF Object_ID('metadata.pBA_Batch', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pBA_Batch];
IF Object_ID('metadata.lBA_Batch', 'V') IS NOT NULL
DROP VIEW [metadata].[lBA_Batch];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lBA_Batch viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lBA_Batch] WITH SCHEMABINDING AS
SELECT
    [BA].BA_ID,
    [STA].BA_STA_BA_ID,
    [STA].BA_STA_Batch_Start,
    [END].BA_END_BA_ID,
    [END].BA_END_Batch_End
FROM
    [metadata].[BA_Batch] [BA]
LEFT JOIN
    [metadata].[BA_STA_Batch_Start] [STA]
ON
    [STA].BA_STA_BA_ID = [BA].BA_ID
LEFT JOIN
    [metadata].[BA_END_Batch_End] [END]
ON
    [END].BA_END_BA_ID = [BA].BA_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pBA_Batch viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pBA_Batch] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [BA].BA_ID,
    [STA].BA_STA_BA_ID,
    [STA].BA_STA_Batch_Start,
    [END].BA_END_BA_ID,
    [END].BA_END_Batch_End
FROM
    [metadata].[BA_Batch] [BA]
LEFT JOIN
    [metadata].[BA_STA_Batch_Start] [STA]
ON
    [STA].BA_STA_BA_ID = [BA].BA_ID
LEFT JOIN
    [metadata].[BA_END_Batch_End] [END]
ON
    [END].BA_END_BA_ID = [BA].BA_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nBA_Batch viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nBA_Batch]
AS
SELECT
    *
FROM
    [metadata].[pBA_Batch](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dFI_File', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dFI_File];
IF Object_ID('metadata.nFI_File', 'V') IS NOT NULL
DROP VIEW [metadata].[nFI_File];
IF Object_ID('metadata.pFI_File', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pFI_File];
IF Object_ID('metadata.lFI_File', 'V') IS NOT NULL
DROP VIEW [metadata].[lFI_File];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lFI_File viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lFI_File] WITH SCHEMABINDING AS
SELECT
    [FI].FI_ID,
    [NAM].FI_NAM_FI_ID,
    [NAM].FI_NAM_File_Name
FROM
    [metadata].[FI_File] [FI]
LEFT JOIN
    [metadata].[FI_NAM_File_Name] [NAM]
ON
    [NAM].FI_NAM_FI_ID = [FI].FI_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pFI_File viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pFI_File] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [FI].FI_ID,
    [NAM].FI_NAM_FI_ID,
    [NAM].FI_NAM_File_Name
FROM
    [metadata].[FI_File] [FI]
LEFT JOIN
    [metadata].[FI_NAM_File_Name] [NAM]
ON
    [NAM].FI_NAM_FI_ID = [FI].FI_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nFI_File viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nFI_File]
AS
SELECT
    *
FROM
    [metadata].[pFI_File](sysdatetime());
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
-- itBA_Batch instead of INSERT trigger on lBA_Batch
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[itBA_Batch] ON [metadata].[lBA_Batch]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7) = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @BA TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        BA_ID int not null
    );
    INSERT INTO [metadata].[BA_Batch] (
        BA_Dummy
    )
    OUTPUT
        inserted.BA_ID
    INTO
        @BA
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.BA_ID is null;
    DECLARE @inserted TABLE (
        BA_ID int not null,
        BA_STA_BA_ID int null,
        BA_STA_Batch_Start datetime null,
        BA_END_BA_ID int null,
        BA_END_Batch_End datetime null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.BA_ID, a.BA_ID),
        ISNULL(ISNULL(i.BA_STA_BA_ID, i.BA_ID), a.BA_ID),
        i.BA_STA_Batch_Start,
        ISNULL(ISNULL(i.BA_END_BA_ID, i.BA_ID), a.BA_ID),
        i.BA_END_Batch_End
    FROM (
        SELECT
            BA_ID,
            BA_STA_BA_ID,
            BA_STA_Batch_Start,
            BA_END_BA_ID,
            BA_END_Batch_End,
            ROW_NUMBER() OVER (PARTITION BY BA_ID ORDER BY BA_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @BA a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[BA_STA_Batch_Start] (
        BA_STA_BA_ID,
        BA_STA_Batch_Start
    )
    SELECT
        i.BA_STA_BA_ID,
        i.BA_STA_Batch_Start
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[BA_STA_Batch_Start] [STA]
    ON
        [STA].BA_STA_BA_ID = i.BA_STA_BA_ID
    WHERE
        [STA].BA_STA_BA_ID is null
    AND
        i.BA_STA_Batch_Start is not null;
    INSERT INTO [metadata].[BA_END_Batch_End] (
        BA_END_BA_ID,
        BA_END_Batch_End
    )
    SELECT
        i.BA_END_BA_ID,
        i.BA_END_Batch_End
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[BA_END_Batch_End] [END]
    ON
        [END].BA_END_BA_ID = i.BA_END_BA_ID
    WHERE
        [END].BA_END_BA_ID is null
    AND
        i.BA_END_Batch_End is not null;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtBA_Batch instead of DELETE trigger on lBA_Batch
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dtBA_Batch] ON [metadata].[lBA_Batch]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [STA]
    FROM
        [metadata].[BA_STA_Batch_Start] [STA]
    JOIN
        deleted d
    ON
        d.BA_STA_BA_ID = [STA].BA_STA_BA_ID
    DELETE [END]
    FROM
        [metadata].[BA_END_Batch_End] [END]
    JOIN
        deleted d
    ON
        d.BA_END_BA_ID = [END].BA_END_BA_ID
        ;
    DELETE [BA]
    FROM
        [metadata].[BA_Batch] [BA]
    LEFT JOIN
        [metadata].[BA_STA_Batch_Start] [STA]
    ON
        [STA].BA_STA_BA_ID = [BA].BA_ID
    LEFT JOIN
        [metadata].[BA_END_Batch_End] [END]
    ON
        [END].BA_END_BA_ID = [BA].BA_ID
    WHERE
        [STA].BA_STA_BA_ID is null
    AND
        [END].BA_END_BA_ID is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itFI_File instead of INSERT trigger on lFI_File
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[itFI_File] ON [metadata].[lFI_File]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7) = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @FI TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        FI_ID int not null
    );
    INSERT INTO [metadata].[FI_File] (
        FI_Dummy
    )
    OUTPUT
        inserted.FI_ID
    INTO
        @FI
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.FI_ID is null;
    DECLARE @inserted TABLE (
        FI_ID int not null,
        FI_NAM_FI_ID int null,
        FI_NAM_File_Name varchar(2000) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.FI_ID, a.FI_ID),
        ISNULL(ISNULL(i.FI_NAM_FI_ID, i.FI_ID), a.FI_ID),
        i.FI_NAM_File_Name
    FROM (
        SELECT
            FI_ID,
            FI_NAM_FI_ID,
            FI_NAM_File_Name,
            ROW_NUMBER() OVER (PARTITION BY FI_ID ORDER BY FI_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @FI a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[FI_NAM_File_Name] (
        FI_NAM_FI_ID,
        FI_NAM_File_Name
    )
    SELECT
        i.FI_NAM_FI_ID,
        i.FI_NAM_File_Name
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[FI_NAM_File_Name] [NAM]
    ON
        [NAM].FI_NAM_FI_ID = i.FI_NAM_FI_ID
    WHERE
        [NAM].FI_NAM_FI_ID is null
    AND
        i.FI_NAM_File_Name is not null;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtFI_File instead of DELETE trigger on lFI_File
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dtFI_File] ON [metadata].[lFI_File]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [metadata].[FI_NAM_File_Name] [NAM]
    JOIN
        deleted d
    ON
        d.FI_NAM_FI_ID = [NAM].FI_NAM_FI_ID
        ;
    DELETE [FI]
    FROM
        [metadata].[FI_File] [FI]
    LEFT JOIN
        [metadata].[FI_NAM_File_Name] [NAM]
    ON
        [NAM].FI_NAM_FI_ID = [FI].FI_ID
    WHERE
        [NAM].FI_NAM_FI_ID is null;
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
IF Object_ID('metadata.dBA_uses_FI_the', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dBA_uses_FI_the];
IF Object_ID('metadata.nBA_uses_FI_the', 'V') IS NOT NULL
DROP VIEW [metadata].[nBA_uses_FI_the];
IF Object_ID('metadata.pBA_uses_FI_the', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pBA_uses_FI_the];
IF Object_ID('metadata.lBA_uses_FI_the', 'V') IS NOT NULL
DROP VIEW [metadata].[lBA_uses_FI_the];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lBA_uses_FI_the viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lBA_uses_FI_the] WITH SCHEMABINDING AS
SELECT
    tie.BA_ID_uses,
    tie.FI_ID_the
FROM
    [metadata].[BA_uses_FI_the] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pBA_uses_FI_the viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pBA_uses_FI_the] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.BA_ID_uses,
    tie.FI_ID_the
FROM
    [metadata].[BA_uses_FI_the] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nBA_uses_FI_the viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nBA_uses_FI_the]
AS
SELECT
    *
FROM
    [metadata].[pBA_uses_FI_the](sysdatetime());
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
-- itBA_uses_FI_the instead of INSERT trigger on lBA_uses_FI_the
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[itBA_uses_FI_the] ON [metadata].[lBA_uses_FI_the]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7) = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        BA_ID_uses int not null,
        FI_ID_the int not null,
        primary key (
            BA_ID_uses,
            FI_ID_the
        )
    );
    INSERT INTO @inserted
    SELECT
        i.BA_ID_uses,
        i.FI_ID_the
    FROM
        inserted i
    WHERE
        i.BA_ID_uses is not null
    AND
        i.FI_ID_the is not null;
    INSERT INTO [metadata].[BA_uses_FI_the] (
        BA_ID_uses,
        FI_ID_the
    )
    SELECT
        i.BA_ID_uses,
        i.FI_ID_the
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[BA_uses_FI_the] tie
    ON
        tie.BA_ID_uses = i.BA_ID_uses
    AND
        tie.FI_ID_the = i.FI_ID_the
    WHERE
        tie.FI_ID_the is null;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtBA_uses_FI_the instead of DELETE trigger on lBA_uses_FI_the
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dtBA_uses_FI_the] ON [metadata].[lBA_uses_FI_the]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[BA_uses_FI_the] tie
    JOIN
        deleted d
    ON
        d.BA_ID_uses = tie.BA_ID_uses
    AND
        d.FI_ID_the = tie.FI_ID_the;
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
IF Object_ID('metadata._Schema', 'U') IS NULL
   CREATE TABLE [metadata].[_Schema] (
      [version] int identity(1, 1) not null primary key,
      [activation] datetime2(7) not null,
      [schema] xml not null
   );
GO
-- Insert the XML schema (as of now)
INSERT INTO [metadata].[_Schema] (
   [activation],
   [schema]
)
SELECT
   current_timestamp,
   N'<schema format="0.98" date="2014-08-27" time="16:14:05"><metadata changingRange="datetime" encapsulation="metadata" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="false" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="tinyint" reliabilitySuffix="Reliability" reliableCutoff="1" deleteReliability="0" reliableSuffix="Reliable" partitioning="false" entityIntegrity="true" restatability="false" idempotency="true" assertiveness="false" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2(7)" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="false" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="uni"/><anchor mnemonic="BA" descriptor="Batch" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="STA" descriptor="Start" dataRange="datetime"><metadata capsule="metadata"/><layout x="737.80" y="542.14" fixed="false"/></attribute><attribute mnemonic="END" descriptor="End" dataRange="datetime"><metadata capsule="metadata"/><layout x="709.57" y="551.64" fixed="false"/></attribute><layout x="705.11" y="492.40" fixed="false"/></anchor><anchor mnemonic="FI" descriptor="File" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(2000)"><metadata capsule="metadata"/><layout x="822.00" y="241.00" fixed="true"/></attribute><layout x="788.00" y="317.00" fixed="true"/></anchor><tie><anchorRole role="uses" type="BA" identifier="true"/><anchorRole role="the" type="FI" identifier="true"/><metadata capsule="metadata"/><layout x="744.73" y="406.96" fixed="false"/></tie></schema>';
GO
-- Schema expanded view -----------------------------------------------------------------------------------------------
-- A view of the schema table that expands the XML attributes into columns
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Schema_Expanded', 'V') IS NOT NULL
DROP VIEW [metadata].[_Schema_Expanded]
GO
CREATE VIEW [metadata].[_Schema_Expanded]
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
IF Object_ID('metadata._Anchor', 'V') IS NOT NULL
DROP VIEW [metadata].[_Anchor]
GO
CREATE VIEW [metadata].[_Anchor]
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
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as Nodeset(anchor);
GO
-- Knot view ----------------------------------------------------------------------------------------------------------
-- The knot view shows information about all the knots in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Knot', 'V') IS NOT NULL
DROP VIEW [metadata].[_Knot]
GO
CREATE VIEW [metadata].[_Knot]
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
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/knot') as Nodeset(knot);
GO
-- Attribute view -----------------------------------------------------------------------------------------------------
-- The attribute view shows information about all the attributes in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Attribute', 'V') IS NOT NULL
DROP VIEW [metadata].[_Attribute]
GO
CREATE VIEW [metadata].[_Attribute]
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
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as ParentNodeset(anchor)
OUTER APPLY
   ParentNodeset.anchor.nodes('attribute') as Nodeset(attribute);
GO
-- Tie view -----------------------------------------------------------------------------------------------------------
-- The tie view shows information about all the ties in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Tie', 'V') IS NOT NULL
DROP VIEW [metadata].[_Tie]
GO
CREATE VIEW [metadata].[_Tie]
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
   [metadata].[_Schema] S
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
IF Object_ID('metadata._Evolution', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[_Evolution];
GO
CREATE FUNCTION [metadata].[_Evolution] (
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
                  [metadata].[_Schema]
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
      [metadata].[_Schema]
   WHERE
      [activation] <= @timepoint
) V
JOIN (
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Anchor] a
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Knot] k
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Attribute] b
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Tie] t
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
IF Object_ID('metadata._GenerateDropScript', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_GenerateDropScript];
GO
CREATE PROCEDURE [metadata]._GenerateDropScript (
   @exclusionPattern varchar(42) = '[_]%' -- exclude Metadata by default
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
IF Object_ID('metadata._GenerateCopyScript', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_GenerateCopyScript];
GO
CREATE PROCEDURE [metadata]._GenerateCopyScript (
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