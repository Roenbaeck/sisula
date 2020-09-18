// Create loading logic
var load, map, i, deletable, deletablesExist;
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
    var naturalKeys = [], 
        surrogateKeys = [], 
        metadata = [],
        others = [];

    deletablesExist = false;
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
        if(map.deletable === 'true') deletablesExist = true;
        deletable = map.deletable === 'true' ? '[D]' : '';
/*~
-- Map: $map.source to $map.target $deletable $(map.as)? (as $map.as)
~*/
    }
/*~
-- 
$(deletablesExist)? -- [D] marks deletable attributes
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
    var othersWithoutHistory = [];
    for(i = 0; map = others[i]; i++) {
        if(map.as != 'history') othersWithoutHistory.push(map);
    }
    var maps = othersWithoutHistory;
    if(maps.length > 0) {
/*~
    WHEN MATCHED AND (
~*/
        for(i = 0; map = maps[i]; i++) {
            if(map.deletable === 'true') {
/*~
        ([target].[$map.target] is not null AND [source].[$map.source] is null)
    OR    
~*/

            }
            if(map.as == 'static') {
/*~
        ([target].[$map.target] is null)
    $(i < maps.length - 1)? OR    
~*/
            }
            else {
/*~
        ([target].[$map.target] is null OR [source].[$map.source] <> [target].[$map.target])
    $(i < maps.length - 1)? OR    
~*/
            }
        }    
/*~
    ) 
    THEN UPDATE
    SET
~*/
        var maps = others.concat(metadata);
        for(i = 0; map = maps[i]; i++) {
            if(map.deletable === 'true' && map.as != 'history') {
                var deletableColumn = '[Deletable_' + map.target.substring(0, 6) + ']';                
/*~
        [target].$deletableColumn = 1,
~*/
            }
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
