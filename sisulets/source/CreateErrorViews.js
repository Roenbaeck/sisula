// Create a columnar split view
/*~
IF Object_ID('$source.qualified$_CreateErrorViews', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateErrorViews];
GO

CREATE PROCEDURE [$source.qualified$_CreateErrorViews] 
AS
BEGIN
    SET NOCOUNT ON;
~*/
var part, term;
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
/*~
END
GO
~*/
