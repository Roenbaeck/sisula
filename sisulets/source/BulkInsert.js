/*~
IF Object_ID('$source.qualified$_BulkInsert', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_BulkInsert];
GO

--------------------------------------------------------------------------
-- Procedure: $source.qualified$_BulkInsert
--
-- This procedure performs a BULK INSERT of the given filename into
-- the $source.qualified$_Insert view. The file is loaded row by row
-- into a single column holding the entire row. This ensures that no
-- data is lost when loading.
--
-- This job may called multiple times in a workflow when more than
-- one file matching a given filename pattern is found.
--
-- Generated: ${new Date()}$ by $VARIABLES.USERNAME
-- From: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain
--------------------------------------------------------------------------
CREATE PROCEDURE [$source.qualified$_BulkInsert] (
	@filename varchar(2000),
    @lastModified datetime,
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @file int;
DECLARE @inserts int;
DECLARE @updates int;
~*/
beginMetadata(source.qualified + '_BulkInsert', source.name, 'Source');
setSourceToTargetMetadata(
    "@filename",                            // sourceName
    "'File'",                               // sourceType
    "@lastModified",                        // sourceCreated
    "'" + source.qualified + "_Insert'",    // targetName
    "'View'",                               // targetType
    null                                    // targetCreated
);
if(source.split == 'bulk') {
    // only one part is allowed when 'bulk' is specified
    var part = source.nextPart();
    var sisulaPath = VARIABLES.SisulaPath;
    if(sisulaPath && !sisulaPath.endsWith('\\')) {
        sisulaPath += '\\';
    }
/*~
    IF Object_ID('$source.qualified$_Insert', 'V') IS NOT NULL
    BEGIN
    EXEC('
        BULK INSERT [$source.qualified$_Insert]
        FROM ''' + @filename + '''
        WITH (
            $(source.codepage)?         CODEPAGE        = ''$source.codepage'',
            $(sisulaPath)?              FORMATFILE      = ''${sisulaPath}$format.xml'',
            TABLOCK
        );
    ');
    SET @inserts = @@ROWCOUNT;
~*/
} // not 'bulk' splitting
else {
/*~
    IF Object_ID('$source.qualified$_Insert', 'V') IS NOT NULL
    BEGIN
    EXEC('
        BULK INSERT [$source.qualified$_Insert]
        FROM ''' + @filename + '''
        WITH (
            $(source.codepage)?         CODEPAGE        = ''$source.codepage'',
            $(source.datafiletype)?     DATAFILETYPE    = ''$source.datafiletype'',
            $(source.fieldterminator)?  FIELDTERMINATOR = ''$source.fieldterminator'',
            $(source.rowterminator)?    ROWTERMINATOR   = ''$source.rowterminator'',
            TABLOCK
        );
    ');
    SET @inserts = @@ROWCOUNT;
~*/
}
setInsertsMetadata('@inserts');
if(METADATA) {
/*~
    SET @file = (
        SELECT
            CO_ID
        FROM
            ${METADATABASE}$.metadata.lCO_Container
        WHERE
            CO_NAM_Container_Name = @filename
        AND
            CO_CRE_Container_Created = @lastModified
    );
~*/
}
else {
/*~
    SET @file = 1 + (
        SELECT TOP 1
            _file
        FROM
            [$source.qualified$_Raw]
        ORDER BY
            _file
        DESC
    );
~*/
}
if(source.split == 'bulk') {
/*~
    UPDATE [$source.qualified$_RawSplit]
    SET
        _file = @file
    WHERE
        _file = 0;

    SET @updates = @@ROWCOUNT;
~*/
}
else {
/*~
    UPDATE [$source.qualified$_Raw]
    SET
        _file = @file
    WHERE
        _file = 0;

    SET @updates = @@ROWCOUNT;
~*/
}
setUpdatesMetadata('@updates');
/*~
    END
~*/
endMetadata();
/*~
END
GO
~*/
