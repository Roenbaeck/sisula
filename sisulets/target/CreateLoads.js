// Create loading logic
var load, map, i;
while(load = target.nextLoad()) {
/*~
IF Object_ID('$S_SCHEMA$.$load.qualified', 'P') IS NOT NULL
DROP PROCEDURE [$S_SCHEMA].[$load.qualified];
GO
--------------------------------------------------------------------------
-- Procedure: $load.qualified
-- Source:    $load.source
-- Target:    $load.target
--
~*/
    while(map = load.nextMap()) {
/*~
-- Map: $map.source to $map.target $(map.as)? (as $map.as)
~*/
    }
/*~
--
-- Generated: ${new Date()}$ by $VARIABLES.USERNAME
-- From: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain
--------------------------------------------------------------------------
CREATE PROCEDURE [$S_SCHEMA].[$load.qualified] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN

SET NOCOUNT ON;
DECLARE @inserts int;
DECLARE @updates int;
DECLARE @deletes int;
DECLARE @actions TABLE (
    [action] char(1) not null
);
~*/
    beginMetadata(load.qualified, target.name, 'Target');
    setSourceToTargetMetadata(
        "'" + load.source + "'",        // sourceName
        "'Table'",                      // sourceType
        null,                           // sourceCreated
        "'" + load.target + "'",        // targetName
        "'Table'",                      // targetType
        null                            // targetCreated
    ); 

    if(sql = load.sql ? load.sql.before : null) {
/*~
    -- Preparations before the merge -----------------
    $sql._sql
~*/
    }
    
/*~    
    -- Perform the actual merge ----------------------
    MERGE INTO [$target.database].[$T_SCHEMA].[$load.target] AS [target]
    USING~*/
    if(load._load) {
/*~ (
        $load._load
    ) AS [source]
~*/
    }
    else {
/*~
        $load.source AS [source]
~*/
    }
/*~
    ON (
~*/
    var naturalKeys = [], 
        surrogateKeys = [], 
        metadata = [],
        others = [];
    
    while(map = load.nextMap()) {
        switch (map.as) {
            case 'natural key':
                naturalKeys.push(map);
                break;
            case 'surrogate key':
                surrogateKeys.push(map);
                break;
            case 'metadata':
                metadata.push(map);
                break;
            default:
                others.push(map);
        }
    }
    var maps = naturalKeys.concat(surrogateKeys);
    for(i = 0; map = maps[i]; i++) {
/*~
        [source].[$map.source] = [target].[$map.target]
    $(i < maps.length - 1)? AND
~*/
    } 
    if(load.condition) {
/*~
    AND (
        $load.condition
        )
~*/        
    } 
/*~    
    )
~*/
    var maps = naturalKeys.concat(others, metadata);
    if(maps.length > 0) {
/*~        
    WHEN NOT MATCHED THEN INSERT (
~*/
        for(i = 0; map = maps[i]; i++) {
/*~
        [$map.target]$(i < maps.length - 1)?,
~*/
        }    
/*~    
    )
    VALUES (
~*/
        for(i = 0; map = maps[i]; i++) {
/*~
        [source].[$map.source]$(i < maps.length - 1)?,
~*/
        }    
/*~
    )
~*/
    }
    var maps = others;
    if(maps.length > 0) {
/*~
    WHEN MATCHED AND (
~*/
        for(i = 0; map = maps[i]; i++) {
/*~
        ([target].[$map.target] is null OR [source].[$map.source] <> [target].[$map.target])
    $(i < maps.length - 1)? OR    
~*/
        }    
/*~
    ) 
    THEN UPDATE
    SET
~*/
        var maps = others.concat(metadata);
        for(i = 0; map = maps[i]; i++) {
/*~
        [target].[$map.target] = [source].[$map.source]$(i < maps.length - 1)?,
~*/
        }    
    } // end of if nonkeys
/*~
    OUTPUT
        LEFT($$action, 1) INTO @actions;

    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
~*/
    setInsertsMetadata('@inserts');
    setUpdatesMetadata('@updates');
    setDeletesMetadata('@deletes');

    if(sql = load.sql ? load.sql.after : null) {
/*~
    -- Post processing after the merge ---------------
    $sql._sql
~*/
    }
    endMetadata();
/*~
END
GO
~*/
}
