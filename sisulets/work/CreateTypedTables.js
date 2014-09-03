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
var part, term;
while(part = source.nextPart()) {
/*~
    IF Object_ID('$part.qualified$_Typed', 'U') IS NOT NULL
    DROP TABLE [$part.qualified$_Typed];

    CREATE TABLE $part.qualified$_Typed (
        _id int not null,
~*/
    var k, key, c, component;
    while(term = part.nextTerm()) {
        var nullable = 'null';
        for(k = 0; key = part.key[part.keys[k]]; k++) {
            if(key.components.indexOf(term.name) >= 0) {
                nullable = 'not null';
                break;
            }
        }
/*~
        [$term.name] $term.format $nullable$(part.hasMoreTerms())?, 
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

