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
CREATE PROCEDURE [$source.qualified$_SplitRawIntoTyped] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @insert int = 0;
~*/
beginMetadata(source.qualified + '_SplitRawIntoTyped', source.name, 'Source');

while(part = source.nextPart()) {
/*~
    IF Object_ID('$part.qualified$_Typed', 'U') IS NOT NULL
    BEGIN
~*/
setSourceToTargetMetadata(
    "'" + part.qualified + "_Split'",   // sourceName
    "'View'",                           // sourceType
    null,                               // sourceCreated
    "'" + part.qualified + "_Typed'",   // targetName
    "'Table'",                          // targetType
    null                                // targetCreated
);
/*~
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
~*/
    // default to true
    part.keyCheck = part.keyCheck ? part.keyCheck : 'true';
    part.typeCheck = part.typeCheck ? part.typeCheck : 'true';
    if((part.keyCheck == 'true' && part.hasMoreKeys()) || part.typeCheck == 'true') {
/*~
    WHERE
~*/
    }
    var key;
    if(part.keyCheck == 'true' && part.hasMoreKeys()) {
        while(key = part.nextKey()) {
/*~
        $key.name$_Duplicate = 0
    $(part.typeCheck == 'true')? AND
~*/
        }
    }
    if(part.typeCheck == 'true') {
        while(term = part.nextTerm()) {
/*~
        [$term.name$_Error] is null$(!part.hasMoreTerms())?;
    $(part.hasMoreTerms())? AND
~*/
        }
    }
/*~
    SET @insert = @insert + @@ROWCOUNT;
~*/
    setInsertsMetadata('@insert');
/*~
    END
~*/
}
endMetadata();
/*~
END
GO
~*/
