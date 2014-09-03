/*~
IF Object_ID('$source.qualified$_BulkInsert', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_BulkInsert];
GO

CREATE PROCEDURE [$source.qualified$_BulkInsert] (
	@filename varchar(2000)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF Object_ID('$source.qualified$_Raw', 'U') IS NOT NULL
	EXEC('
		BULK INSERT [$source.qualified$_Raw]
		FROM ''' + @filename + '''
        WITH (
            $(source.codepage)?         CODEPAGE        = ''$source.codepage'',
            $(source.datafiletype)?     DATAFILETYPE    = ''$source.datafiletype'',
            $(source.fieldterminator)?  FIELDTERMINATOR = ''$source.fieldterminator'',
            $(source.rowterminator)?    ROWTERMINATOR   = ''$source.rowterminator'',
            TABLOCK   
        );
	');
END
GO
~*/