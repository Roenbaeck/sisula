// Create typed tables corresponding to parts
var part, term, calculation;
/*~
IF Object_ID('$source.qualified$_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateTypedTables];
GO

--------------------------------------------------------------------------
-- Procedure: $source.qualified$_CreateTypedTables
--
-- The typed tables hold the data that make it through the process
-- without errors. Columns here have the data types defined in the
-- source XML definition.
--
-- Metadata columns, such as _id, can be used to backtrack from
-- a value to the actual row from where it came.
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
-- From: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain
--------------------------------------------------------------------------
CREATE PROCEDURE [$source.qualified$_CreateTypedTables] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
~*/
beginMetadata(source.qualified + '_CreateTypedTables', source.name, 'Source');
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
        var persisted = calculation.persisted == 'false' ? '' : 'PERSISTED';
        var nullable = 'null';
        while(key = part.nextKey()) {
            if(key.hasComponent(calculation)) {
                nullable = 'not null';
            }
        }
		if(calculation._calculation) {
/*~
        [$calculation.name] as CAST(${calculation._calculation.trim()}$ AS $calculation.format) $persisted$(part.hasMoreCalculations())?,
~*/
		}
		else {
/*~
        [$calculation.name] $calculation.format $nullable$(part.hasMoreCalculations())?,
~*/
		}
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

