// Create a typed table suitable for bulk insert
/*~
IF Object_ID('$source.qualified$_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateTypedTables];
GO

CREATE PROCEDURE [$source.qualified$_CreateTypedTables] 
AS
BEGIN
    SET NOCOUNT ON;
~*/
var part, term, calculation;
while(part = source.nextPart()) {
/*~
    IF Object_ID('$part.qualified$_Typed', 'U') IS NOT NULL
    DROP TABLE [$part.qualified$_Typed];

    CREATE TABLE $part.qualified$_Typed (
        _id int not null,
~*/
    var key;
    while(term = part.nextTerm()) {
        var nullable = 'null';
        while(key = part.nextKey()) {
            if(key.hasComponent(term)) {
                nullable = 'not null';
                break;
            }
        }
/*~
        [$term.name] $term.format $nullable$(part.hasMoreTerms() | part.hasMoreCalculations())?, 
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
/*~
END
GO
~*/

