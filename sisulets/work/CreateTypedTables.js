// Create a typed table suitable for bulk insert
var part, term;
while(part = source.nextPart()) {
/*~
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
