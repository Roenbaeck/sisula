// Create a raw table suitable for bulk insert
/*~
IF Object_ID('$source.qualified$_CreateRawTable', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateRawTable];
GO

CREATE PROCEDURE [$source.qualified$_CreateRawTable] 
AS
BEGIN
    SET NOCOUNT ON;
    
    IF Object_ID('$source.qualified$_Raw', 'U') IS NOT NULL
    DROP TABLE [$source.qualified$_Raw];

    CREATE TABLE [$source.qualified$_Raw] (
        [row] $(source.characterType == 'char')? varchar(max) : nvarchar(max)
    );
END
GO
~*/
