// Create a custom splitter 
var part, term;
/*~
IF Object_ID('$source.qualified$_SplitRawIntoTyped', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_SplitRawIntoTyped];
GO

--------------------------------------------------------------------------
-- Procedure: $source.qualified$_SplitRawIntoTyped
--
-- This procedure loads data from the 'Split' views into the 'Typed'
-- tables, with the condition that data must conform to the given
-- data types and have no duplicates for defined keys.
--
~*/
while(part = source.nextPart()) {
/*~
-- Load: $part.qualified$_Split into $part.qualified$_Typed
~*/
}
/*~
--
-- Generated: ${new Date()}$ by $VARIABLES.USERNAME
-- From: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain
--------------------------------------------------------------------------
CREATE PROCEDURE [$source.qualified$_SplitRawIntoTyped] 
AS
BEGIN
SET NOCOUNT ON;
~*/
beginMetadata(source.qualified + '_SplitRawIntoTyped');
while(part = source.nextPart()) {
/*~
    IF Object_ID('$part.qualified$_Typed', 'U') IS NOT NULL
    INSERT INTO [$part.qualified$_Typed] (
        _id,
        _file,
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
        _file,
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
    var key;
    if(part.hasMoreKeys()) {
        while(key = part.nextKey()) {
/*~
        $key.name$_Duplicate = 0
    AND
~*/
        }
    }
    while(term = part.nextTerm()) {
/*~
        [$term.name$_Error] is null$(!part.hasMoreTerms())?;
    $(part.hasMoreTerms())? AND
~*/
    }
}
endMetadata();
/*~
END
GO
~*/
