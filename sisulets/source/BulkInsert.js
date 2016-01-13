/*~
IF Object_ID('$S_SCHEMA$.$source.qualified$_BulkInsert', 'P') IS NOT NULL
DROP PROCEDURE [$S_SCHEMA].[$source.qualified$_BulkInsert];
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
CREATE PROCEDURE [$S_SCHEMA].[$source.qualified$_BulkInsert] (
	@filename varchar(2000),
    @lastModified datetime,
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @CO_ID int;
DECLARE @JB_ID int;
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
    var formatFile = VARIABLES.FormatFile;
/*~
    IF Object_ID('$S_SCHEMA$.$source.qualified$_Insert', 'V') IS NOT NULL
    BEGIN
    EXEC('
        BULK INSERT [$S_SCHEMA].[$source.qualified$_Insert]
        FROM ''' + @filename + '''
        WITH (
            $(source.codepage)?         CODEPAGE        = ''$source.codepage'',
            $(formatFile)?              FORMATFILE      = ''${formatFile}$'',
            $(source.firstrow)?         FIRSTROW        = $source.firstrow,
            TABLOCK
        );
    ');
    SET @inserts = @@ROWCOUNT;
~*/
} // not 'bulk' splitting
else {
/*~
    IF Object_ID('$S_SCHEMA$.$source.qualified$_Insert', 'V') IS NOT NULL
    BEGIN
    EXEC('
        BULK INSERT [$S_SCHEMA].[$source.qualified$_Insert]
        FROM ''' + @filename + '''
        WITH (
            $(source.codepage)?         CODEPAGE        = ''$source.codepage'',
            $(source.datafiletype)?     DATAFILETYPE    = ''$source.datafiletype'',
            $(source.fieldterminator)?  FIELDTERMINATOR = ''$source.fieldterminator'',
            $(source.rowterminator)?    ROWTERMINATOR   = ''$source.rowterminator'',
            $(source.firstrow)?         FIRSTROW        = $source.firstrow,
            TABLOCK
        );
    ');
    SET @inserts = @@ROWCOUNT;
~*/
}
setInsertsMetadata('@inserts');
if(METADATA) {
/*~
    SET @CO_ID = ISNULL((
        SELECT TOP 1
            CO_ID
        FROM
            ${METADATABASE}$.metadata.lCO_Container
        WHERE
            CO_NAM_Container_Name = @filename
        AND
            CO_CRE_Container_Created = @lastModified
    ), 0);
    SET @JB_ID = ISNULL((
        SELECT
            jb.JB_ID
        FROM
            ${METADATABASE}$.metadata.lWO_part_JB_of wojb
        JOIN
            ${METADATABASE}$.metadata.lJB_Job jb
        ON
            jb.JB_ID = wojb.JB_ID_of
        AND
            jb.JB_AID_Job_AgentJobId = @agentJobId
        WHERE
            wojb.WO_ID_part = @workId
    ), 0);
~*/
}
else {
/*~
    SET @CO_ID = 1 + (
        SELECT TOP 1
            metadata_CO_ID
        FROM
            [$S_SCHEMA].[$source.qualified$_Raw]
        ORDER BY
            metadata_CO_ID
        DESC
    );
    SET @JB_ID = CHECKSUM(@agentJobId);
~*/
}
if(source.split == 'bulk') {
/*~
    UPDATE [$S_SCHEMA].[$source.qualified$_RawSplit]
    SET
        metadata_CO_ID =
          case when metadata_CO_ID = 0 then @CO_ID else metadata_CO_ID end,
        metadata_JB_ID =
          case when metadata_JB_ID = 0 then @JB_ID else metadata_JB_ID end;

    SET @updates = @@ROWCOUNT;
~*/
}
else {
/*~
    UPDATE [$S_SCHEMA].[$source.qualified$_Raw]
    SET
    metadata_CO_ID =
      case when metadata_CO_ID = 0 then @CO_ID else metadata_CO_ID end,
    metadata_JB_ID =
      case when metadata_JB_ID = 0 then @JB_ID else metadata_JB_ID end;

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
