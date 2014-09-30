// Create typed tables corresponding to parts
var part, term, calculation;
/*~
IF Object_ID('$source.qualified$_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateTypedTables];
GO

--------------------------------------------------------------------------
-- Procedure: $source.qualified$_CreateTypedTables
--
~*/
while(part = source.nextPart()) {
/*~
-- Create: $part.qualified$_Typed
~*/
}
/*~
--
-- Generated: ${new Date()}$ by $VARIABLES.USERNAME
-- From: $VARIABLES.COMPUTERNAME in $VARIABLES.USERDOMAIN
--------------------------------------------------------------------------
CREATE PROCEDURE [$source.qualified$_CreateTypedTables] 
AS
BEGIN
SET NOCOUNT ON;
~*/
beginMetadata(source.qualified + '_CreateTypedTables');
while(part = source.nextPart()) {
/*~
    IF Object_ID('$part.qualified$_Typed', 'U') IS NOT NULL
    DROP TABLE [$part.qualified$_Typed];

    CREATE TABLE [$part.qualified$_Typed] (
        _id int not null,
        _file int not null,
        _timestamp datetime2(2) not null default sysdatetime(),
~*/
    var key;
    while(term = part.nextTerm()) {
        var nullable = 'null';
        while(key = part.nextKey()) {
            if(key.hasComponent(term)) {
                nullable = 'not null';
            }
        }
/*~
        [$term.name] $term.format $nullable$(part.hasMoreTerms() || part.hasMoreCalculations())?, 
~*/
    }
    while(calculation = part.nextCalculation()) {
/*~
        [$calculation.name] as CAST(${calculation._calculation.trim()}$ AS $calculation.format) PERSISTED$(part.hasMoreCalculations())?, 
~*/
    }
/*~
    );
~*/
}  
endMetadata();
/*~
END
GO
~*/

