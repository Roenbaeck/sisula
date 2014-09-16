// Create a columnar split view
/*~
IF Object_ID('$source.qualified$_CreateSplitViews', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateSplitViews];
GO

CREATE PROCEDURE [$source.qualified$_CreateSplitViews] 
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
        _file,
~*/
    var key;
    var i = 1;
    while(term = part.nextTerm()) {
        var isKeyConstituent = false;
        while(key = part.nextKey()) {
            if(key.hasComponent(term)) {
                isKeyConstituent = true;
                break;
            }
        }        
/*~
        c${i}$.[$term.name] as [$term.name$_Raw],
        t.[$term.name], 
        CASE
            $(isKeyConstituent)? WHEN t.[$term.name] is null THEN ''Null value not allowed''
            WHEN t.[$term.name] is not null AND TRY_CAST(t.[$term.name] AS $term.format) is null THEN ''Conversion to $term.format failed''
        END AS [$term.name$_Error]$(part.hasMoreTerms() || part.hasMoreKeys())?,
~*/
        i++;
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
    var skip = part.charskip ? part.charskip : '0';
/*~
    CROSS APPLY (SELECT $skip) d0 (p)
~*/
    i = 1;
    while(term = part.nextTerm()) {
        if(term.size) {
            var s = parseInt(term.size);
            var nulls = term.nulls | part.nulls;
            nulls = nulls ? nulls.escape() : '';
/*~
    CROSS APPLY (SELECT d${(i - 1)}$.p + $s) d${i}$ (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d${(i - 1)}$.p + 1, $s)), ''$nulls'')) c${i}$ ([$term.name$])
~*/
        }
        else if(term.delimiter) {
            var delim = term.delimiter.escape();
/*~
    CROSS APPLY (SELECT NULLIF(CHARINDEX(''$delim'', [row], d${(i - 1)}$.p + 1), 0)) d${i}$ (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d${(i - 1)}$.p + 1, d${i}$.p - d${(i - 1)}$.p - 1)), ''$nulls'')) c${i}$ ([$term.name$])
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
