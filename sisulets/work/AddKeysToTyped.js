/*~
IF Object_ID('$source.qualified$_AddKeysToTyped', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_AddKeysToTyped];
GO

CREATE PROCEDURE [$source.qualified$_AddKeysToTyped] 
AS
BEGIN
    SET NOCOUNT ON;
~*/
var part, term, calculation;
while(part = source.nextPart()) {
    if(part.hasMoreKeys()) {
/*~
    IF Object_ID('$part.qualified$_Typed', 'U') IS NOT NULL
    ALTER TABLE [$part.qualified$_Typed]
    ADD
~*/
        var key, component;
        while(key = part.nextKey()) {
/*~
        CONSTRAINT [$key.name$_$part.qualified$_Typed] $key.type (
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
/*~
END
GO
~*/

