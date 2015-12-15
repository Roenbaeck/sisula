// Create a custom splitter
var part, term;
/*~
IF Object_ID('$S_SCHEMA$.$source.qualified$_SplitRawIntoTyped', 'P') IS NOT NULL
DROP PROCEDURE [$S_SCHEMA].[$source.qualified$_SplitRawIntoTyped];
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
CREATE PROCEDURE [$S_SCHEMA].[$source.qualified$_SplitRawIntoTyped] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @JB_ID int;
DECLARE @insert int;
DECLARE @updates int;
~*/
beginMetadata(source.qualified + '_SplitRawIntoTyped', source.name, 'Source');

while(part = source.nextPart()) {
/*~
    IF Object_ID('$S_SCHEMA$.$part.qualified$_Typed', 'U') IS NOT NULL
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
    INSERT INTO [$S_SCHEMA].[$part.qualified$_Typed] (
        _id,
        metadata_CO_ID,
        metadata_JB_ID,
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
        metadata_CO_ID,
        metadata_JB_ID,
~*/
    while(term = part.nextTerm()) {
/*~
        [$term.name]$(part.hasMoreTerms())?,
~*/
    }
/*~
    FROM
        [$S_SCHEMA].[$part.qualified$_Split]
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
    if(METADATA) {
/*~
    SET @JB_ID = ISNULL((
        SELECT TOP 1
            JB_ID
        FROM
            ${METADATABASE}$.metadata.lJB_Job
        WHERE
            JB_AID_Job_AgentJobId = @agentJobId
    ), 0);

    UPDATE [$S_SCHEMA].[$part.qualified$_Typed]
    SET
      metadata_JB_ID = @JB_ID
    WHERE
      metadata_JB_ID <> @JB_ID;

    SET @updates = @@ROWCOUNT;
~*/
    }
    setUpdatesMetadata('@updates');
/*~
    END
~*/
}
endMetadata();
/*~
END
GO
~*/
