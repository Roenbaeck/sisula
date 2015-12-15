// Create typed tables corresponding to parts
var part, term, calculation;
/*~
IF Object_ID('$S_SCHEMA$.$source.qualified$_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [$S_SCHEMA].[$source.qualified$_CreateTypedTables];
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
CREATE PROCEDURE [$S_SCHEMA].[$source.qualified$_CreateTypedTables] (
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
    IF Object_ID('$S_SCHEMA$.$part.qualified$_Typed', 'U') IS NOT NULL
    DROP TABLE [$S_SCHEMA].[$part.qualified$_Typed];

    CREATE TABLE [$S_SCHEMA].[$part.qualified$_Typed] (
        _id int not null,
        _file AS metadata_CO_ID, -- keep an alias for backwards compatibility
        metadata_CO_ID int not null,
        metadata_JB_ID int not null,
        _timestamp datetime not null default getdate(),
~*/
    var key, component, keyConcat; // _key is kept for legacy reasons
    while(key = part.nextKey()) {
        keyConcat = '';
        while(component = key.nextComponent()) {
            keyConcat += 'CONVERT(varchar(max), [' + component.of + '], 126)' + (key.hasMoreComponents() ? ' + CHAR(183) + ' : '');
        }
/*~
        ${'_' + key.name}$ as cast(HashBytes('MD5', $keyConcat) as varbinary(16)),
~*/
    }
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
