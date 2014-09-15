// Create a columnar split view
/*~
IF Object_ID('$source.qualified$_CreateSplitView', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateSplitView];
GO

CREATE PROCEDURE [$source.qualified$_CreateSplitView] 
AS
BEGIN
    SET NOCOUNT ON;
~*/
var part, term;
while(part = source.nextPart()) {
/*~
    IF Object_ID('$part.qualified$_Split', 'V') IS NOT NULL
    DROP VIEW [$part.qualified$_Split];
    EXEC('
    CREATE VIEW [$part.qualified$_Split] 
    AS
    SELECT
        _id,
~*/
    var key;
    while(term = part.nextTerm()) {
        var isKeyConstituent = false;
        while(key = part.nextKey()) {
            if(key.hasComponent(term)) {
                isKeyConstituent = true;
                break;
            }
        }        
/*~
        t.[$term.name], 
        CASE
            $(isKeyConstituent)? WHEN t.[$term.name] is null THEN ''Null value not allowed''
            WHEN t.[$term.name] is not null AND TRY_CAST(t.[$term.name] AS $term.format) is null THEN ''Conversion to $term.format failed''
        END AS [$term.name$_Error]$(part.hasMoreTerms() || part.hasMoreKeys())?,
~*/
    }
    var component;
    if(part.hasMoreKeys()) {
        while(key = part.nextKey()) {
/*~
        ROW_NUMBER() OVER (
            PARTITION BY
~*/
            while(component = key.nextComponent()) {
/*~
                t.[$component.of]$(key.hasMoreComponents())?,
~*/
            }
/*~
            ORDER BY
                _id
        ) - 1 as $key.name$_Duplicate$(part.hasMoreKeys())?,
~*/
        }
    }
/*~        
    FROM~*/
    if(part._part) {

/*~ (
        ${part._part.trim().escape()}$
    ) src
~*/
    }
    else {
/*~
        $source.qualified$_Raw src
~*/
    }
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
    var i = 0;
    while(term = part.nextTerm()) {
        if(term.size) {
            var s = parseInt(term.size);
            var nulls = term.nulls | part.nulls;
            nulls = nulls ? nulls.escape() : '';
/*~
    CROSS APPLY (SELECT NULLIF(LEFT(c${i}$.[row], $s), ''$nulls''), SUBSTRING(c${i}$.[row], ${(s + 1)}$, $MAXLEN)) c${(i + 1)}$ ([$term.name], [row])
~*/
        }
        else if(term.delimiter) {
            var delim = term.delimiter.escape();
/*~
    CROSS APPLY (SELECT NULLIF(CHARINDEX(''$delim'', c${i}$.[row]), 0)) d${i}$ (p)
    CROSS APPLY (SELECT NULLIF(LEFT(c${i}$.[row], d${i}$.p - 1), ''''), SUBSTRING(c${i}$.[row], d${i}$.p + 1, $MAXLEN)) c${(i + 1)}$ ([$term.name], [row])
~*/
        }
        i++;
    }
/*~
    CROSS APPLY (
        SELECT 
~*/
    var termOrTransform;
    while(term = part.nextTerm()) {
        termOrTransform = '[' + term.name + ']';
        if(term._term) {
            termOrTransform = term._term.trim().escape();
        }
/*~
            $termOrTransform AS [$term.name]$(part.hasMoreTerms())?, 
~*/
    }
/*~
    ) t;
    ');
~*/
}
/*~
END
GO
~*/
