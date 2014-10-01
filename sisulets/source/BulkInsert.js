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
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
~*/
beginMetadata(source.qualified + '_BulkInsert');
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
    
    DECLARE @file int = 1 + (
        SELECT TOP 1
            _file
        FROM
            [$source.qualified$_Raw]
        ORDER BY
            _file
        DESC
    );
    
    UPDATE [$source.qualified$_Raw]
    SET
        _file = @file
    WHERE
        _file = 0;
    
    END    
~*/
endMetadata();
/*~
END
GO
~*/