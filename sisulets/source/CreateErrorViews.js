// Create a columnar split view
var part, term;
/*~
IF Object_ID('$source.qualified$_CreateErrorViews', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateErrorViews];
GO

--------------------------------------------------------------------------
-- Procedure: $source.qualified$_CreateErrorViews
--
-- The created error views can be used to find rows that have errors of
-- the following kinds: 
-- 
-- Type casting errors
-- These errors occur when a value cannot be cast to its designated 
-- datatype, for example when trying to cast 'A' to an int.
--
-- Key duplicate errors
-- These errors occur when a primary key is defined and duplicates of
-- that key is found in the tables.
--
~*/
while(part = source.nextPart()) {
/*~
-- Create: $part.qualified$_Error
~*/
}
/*~
--
-- Generated: ${new Date()}$ by $VARIABLES.USERNAME
-- From: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain
--------------------------------------------------------------------------
CREATE PROCEDURE [$source.qualified$_CreateErrorViews] 
AS
BEGIN
SET NOCOUNT ON;
~*/
beginMetadata(source.qualified + '_CreateInsertView');
while(part = source.nextPart()) {
/*~
    IF Object_ID('$part.qualified$_Error', 'V') IS NOT NULL
    DROP VIEW [$part.qualified$_Error];
    EXEC('
    CREATE VIEW [$part.qualified$_Error] 
    AS
    SELECT
        *
    FROM
        [$part.qualified$_Split]
    WHERE
~*/
    var key;
    if(part.hasMoreKeys()) {
        while(key = part.nextKey()) {
/*~
        $key.name$_Duplicate > 0
    OR
~*/
        }
    }
    while(term = part.nextTerm()) {
/*~
        [$term.name$_Error] is not null$(!part.hasMoreTerms())?;
    $(part.hasMoreTerms())? OR
~*/
    }
/*~
    ');
~*/
}
endMetadata();
/*~
END
GO
~*/
