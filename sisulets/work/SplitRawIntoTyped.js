// Create a custom splitter 
/*~
IF Object_ID('$source.qualified$_SplitRawIntoTyped', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_SplitRawIntoTyped];
GO

CREATE PROCEDURE [$source.qualified$_SplitRawIntoTyped] 
AS
BEGIN
    SET NOCOUNT ON;
~*/
var part, term;
while(part = source.nextPart()) {
/*~
    IF Object_ID('$part.qualified$_Typed', 'U') IS NOT NULL
    INSERT INTO [$part.qualified$_Typed] (
~*/
    while(term = part.nextTerm()) {
/*~
        [$term.name]$(part.hasMoreTerms())?, 
~*/
    }
/*~
    )
    SELECT
~*/
    var i = 1;
    while(term = part.nextTerm()) {
/*~
        c$i$.[$term.name]$(part.hasMoreTerms())?, 
~*/
        i++;
    }
/*~
    FROM $(part._part)? ($part._part) src : $source.qualified$_Raw src
~*/
    if(part.charskip) {
        var skip = parseInt(part.charskip);
/*~
    CROSS APPLY (SELECT SUBSTRING(src.[row], ${(skip + 1)}$, $MAXLEN)) c0 ([row])
~*/
    }
    else {
/*~
    CROSS APPLY (SELECT [row]) c0 ([row])
~*/
    }
    i = 0;
    while(term = part.nextTerm()) {
        if(term.size) {
            var s = parseInt(term.size);
/*~
    CROSS APPLY (SELECT NULLIF(LEFT(c${i}$.[row], $s), ''), SUBSTRING(c${i}$.[row], ${(s + 1)}$, $MAXLEN)) c${(i + 1)}$ ([$term.name], [row])$(!part.hasMoreTerms())?; 
~*/
        }
        else if(term.delimiter) {
/*~
    CROSS APPLY (SELECT NULLIF(CHARINDEX(' ', c${i}$.[row]), 0)) d${i}$ (p)
    CROSS APPLY (SELECT NULLIF(LEFT(c${i}$.[row], d${i}$.p - 1), ''), SUBSTRING(c${i}$.[row], d${i}$.p + 1, $MAXLEN)) c${(i + 1)}$ ([$term.name], [row])$(!part.hasMoreTerms())?;
~*/
        }
        i++;
    }
}
/*~
END
GO
~*/
