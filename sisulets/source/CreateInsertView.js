// Create a raw view compatible with bulk inserts
/*~
IF Object_ID('$source.qualified$_CreateInsertView', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateInsertView];
GO

CREATE PROCEDURE [$source.qualified$_CreateInsertView] 
AS
BEGIN
    SET NOCOUNT ON;

    IF Object_ID('$source.qualified$_Insert', 'V') IS NOT NULL
    DROP VIEW [$source.qualified$_Insert];
    EXEC('
    CREATE VIEW [$source.qualified$_Insert]
    AS
    SELECT
        [row]
    FROM
        [$source.qualified$_Raw];
    ');
END
GO
