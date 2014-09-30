// Create a raw view compatible with bulk inserts
/*~
IF Object_ID('$source.qualified$_CreateInsertView', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateInsertView];
GO

--------------------------------------------------------------------------
-- Procedure: $source.qualified$_CreateInsertView
--
-- This view is created as exposing the single column that will be 
-- the target of the BULK INSERT operation, since it cannot insert
-- into a table with multiple columns without a format file.
--
-- Generated: ${new Date()}$ by $VARIABLES.USERNAME
-- From: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain
--------------------------------------------------------------------------
CREATE PROCEDURE [$source.qualified$_CreateInsertView] 
AS
BEGIN
SET NOCOUNT ON;
~*/
beginMetadata(source.qualified + '_CreateInsertView');
/*~
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
~*/
endMetadata();
/*~
END
GO
~*/