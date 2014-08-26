// Create a typed table suitable for bulk insert
/*~
IF Object_ID('sp_$source.qualified$_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [sp_$source.qualified$_CreateTypedTables];
GO

CREATE PROCEDURE [sp_$source.qualified$_CreateTypedTables] 
AS
BEGIN
~*/
var part, term;
while(part = source.nextPart()) {
/*~
    IF Object_ID('$part.qualified$_Typed', 'U') IS NOT NULL
    DROP TABLE [$part.qualified$_Typed];

    CREATE TABLE $part.qualified$_Typed (
        _id int not null,
~*/
    while(term = part.nextTerm()) {
/*~
        [$term.name] $term.format null$(part.hasMoreTerms())?, 
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

