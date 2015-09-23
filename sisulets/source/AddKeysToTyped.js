var part, term, calculation, key, component;
/*~
IF Object_ID('$S_SCHEMA$.$source.qualified$_AddKeysToTyped', 'P') IS NOT NULL
DROP PROCEDURE [$S_SCHEMA].[$source.qualified$_AddKeysToTyped];
GO

--------------------------------------------------------------------------
-- Procedure: $source.qualified$_AddKeysToTyped
--
-- This procedure adds keys defined in the source xml definition to the 
-- typed staging tables. Keys boost performance when loading is made 
-- using MERGE statements on the target with a search condition that 
-- matches the key composition. Primary keys also guarantee uniquness
-- among its values.
--
~*/
while(part = source.nextPart()) {
    if(part.hasMoreKeys()) {
/*~
-- Table: $part.qualified$_Typed
~*/
        while(key = part.nextKey()) {
            while(component = key.nextComponent()) {
/*~
-- Key: $component.of (as $key.type)
~*/
            }
        }
    }
}
/*~
--
-- Generated: ${new Date()}$ by $VARIABLES.USERNAME
-- From: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain
--------------------------------------------------------------------------
CREATE PROCEDURE [$S_SCHEMA].[$source.qualified$_AddKeysToTyped] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
    SET NOCOUNT ON;
~*/
beginMetadata(source.qualified + '_AddKeysToTyped', source.name, 'Source');
while(part = source.nextPart()) {
    if(part.hasMoreKeys()) {
/*~
    IF Object_ID('$S_SCHEMA$.$part.qualified$_Typed', 'U') IS NOT NULL
    ALTER TABLE [$S_SCHEMA].[$part.qualified$_Typed]
    ADD
~*/
        while(key = part.nextKey()) {
/*~
        CONSTRAINT [${S_SCHEMA}$_$key.name$_$part.qualified$_Typed] $key.type (
~*/
            while(component = key.nextComponent()) {
/*~
            [$component.of]$(key.hasMoreComponents())?,
~*/
            }
/*~        
        )$(part.hasMoreKeys())? , : ;
~*/
        }
    }
}    
endMetadata();
/*~
END
GO
~*/

