// Create a custom splitter 
/*~
IF Object_ID('$source.qualified$_SplitRawIntoTyped', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_SplitRawIntoTyped];
GO

CREATE PROCEDURE [$source.qualified$_SplitRawIntoTyped] 
AS
BEGIN
    SET NOCOUNT ON;
~*/
var part, term;
while(part = source.nextPart()) {
/*~
    IF Object_ID('$part.qualified$_Typed', 'U') IS NOT NULL
    INSERT INTO [$part.qualified$_Typed] (
        _id,
~*/
    while(term = part.nextTerm()) {
/*~
        [$term.name]$(part.hasMoreTerms())?, 
~*/
    }
/*~
    )
    SELECT
        _id,
~*/
    while(term = part.nextTerm()) {
/*~
        [$term.name]$(part.hasMoreTerms())?, 
~*/
    }
/*~
    FROM 
        [$part.qualified$_Split]
    WHERE
~*/
    while(term = part.nextTerm()) {
/*~
        [$term.name$_Error] is null$(!part.hasMoreTerms())?;
    $(part.hasMoreTerms())? AND
~*/
    }
}
/*~
END
GO
~*/
