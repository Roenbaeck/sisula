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
    var i = 2;
    while(term = part.nextTerm()) {
        var isKeyConstituent = false;
        while(key = part.nextKey()) {
            if(key.hasComponent(term)) {
                isKeyConstituent = true;
                break;
            }
        }        
/*~
        m.[$term.name] as [$term.name$_Match],
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
    FROM (
        SELECT TOP($MAXLEN) 
            * 
        FROM ~*/
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
/*~
        ORDER BY 
            _id ASC 
    ) forcedMaterializationTrick
~*/
    var regex = '', pivots = '';
    if(part.charskip)
        regex += '.{' + part.charskip + '}';
    else if (part.pattern)
        regex += part.pattern;

    i = 2;
    while(term = part.nextTerm()) {
        pivots += '[' + i + ']';
        if(part.hasMoreTerms())
            pivots += ', ';
        if(term.pattern) 
            regex += term.pattern.escape();
        else if(term.size) 
            regex += '(.{' + term.size + '})';
        else if(term.delimiter) 
            regex += '(.*?)' + term.delimiter.escape();
        else // capture to the end of the line if nothing is specified
            regex += '(.*)'
        i++;
    }
/*~
    CROSS APPLY (
		SELECT
~*/
    i = 2;
    while(term = part.nextTerm()) {
        var nulls = '';
        if(part.nulls)
            nulls = part.nulls.escape();
        else if(term.nulls) 
            nulls = term.nulls.escape();
/*~    
			NULLIF(LTRIM([${i}$]), ''$nulls'') AS [$term.name]$(part.hasMoreTerms())?,
~*/
        i++;
    }
/*~            
		FROM (

            SELECT 
                [match],
                ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS idx
            FROM
                dbo.Splitter(forcedMaterializationTrick.[row], N''$regex'')
        ) s
        PIVOT (
            MAX([match]) FOR idx IN ($pivots)
        ) p
    ) m
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
