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
END
GO
~*/