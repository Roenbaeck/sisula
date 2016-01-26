// Create a columnar split view
var part, term;
/*~
IF Object_ID('$S_SCHEMA$.$source.qualified$_CreateSplitViews', 'P') IS NOT NULL
DROP PROCEDURE [$S_SCHEMA].[$source.qualified$_CreateSplitViews];
GO

--------------------------------------------------------------------------
-- Procedure: $source.qualified$_CreateSplitViews
--
-- The split view uses a CLR called the Splitter to split rows in the
-- 'raw' table into columns. The Splitter uses a regular expression in
-- which groups indicate which parts should be cut out as columns.
--
-- The view also checks data types and provide the results as well as
-- show the 'raw' cut column value, before any given transformations
-- have taken place.
--
-- If keys are defined, these keys are checked for duplicates and the
-- duplicate number can be found through the view.
--
~*/
while(part = source.nextPart()) {
/*~
-- Create: $part.qualified$_Split
~*/
}
/*~
--
-- Generated: ${new Date()}$ by $VARIABLES.USERNAME
-- From: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain
--------------------------------------------------------------------------
CREATE PROCEDURE [$S_SCHEMA].[$source.qualified$_CreateSplitViews] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
~*/
beginMetadata(source.qualified + '_CreateSplitViews', source.name, 'Source');
while(part = source.nextPart()) {
/*~
    IF Object_ID('$S_SCHEMA$.$part.qualified$_Split', 'V') IS NOT NULL
    DROP VIEW [$S_SCHEMA].[$part.qualified$_Split];
    EXEC('
    CREATE VIEW [$S_SCHEMA].[$part.qualified$_Split]
    AS
    SELECT
        t._id,
        t.metadata_CO_ID,
        t.metadata_JB_ID,
        t._timestamp,
~*/
    var key;
    while(term = part.nextTerm()) {
        var isKeyConstituent = false;
        while(key = part.nextKey()) {
            if(key.hasComponent(term)) {
                isKeyConstituent = true;
            }
        }
/*~
        m.[$term.name] as [$term.name$_Match],
        t.[$term.name],
        CASE
            $(isKeyConstituent)? WHEN t.[$term.name] is null THEN ''Null value not allowed''
            WHEN t.[$term.name] is not null AND [$S_SCHEMA].IsType(t.[$term.name], ''$term.format'') = 0 THEN ''Conversion to $term.format failed''
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
                t._id
        ) - 1 as $key.name$_Duplicate$(part.hasMoreKeys())?,
~*/
        }
    }
    if(source.split == 'bulk') {
/*~
    FROM (
        SELECT
            _id,
            metadata_CO_ID,
            metadata_JB_ID,
            _timestamp,
~*/
        while(term = part.nextTerm()) {
            var nulls = '';
            if(term.nulls)
                nulls = term.nulls.escape();
            else if(part.nulls)
                nulls = part.nulls.escape();
/*~
			NULLIF([$term.name], ''$nulls'') AS [$term.name]$(part.hasMoreTerms())?,
~*/
        }
/*~
        FROM ~*/
        if(part._part) {

/*~ (
        ${part._part.trim().escape()}$
        ) src
~*/
        }
        else {
/*~
            [$S_SCHEMA].[$source.qualified$_RawSplit]
~*/
        }
/*~
    ) m
~*/
    }  // end of 'bulk' splitting
    else {
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
            [$S_SCHEMA].[$source.qualified$_Raw] src
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

        var i = 1;
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
        i = 1;
        while(term = part.nextTerm()) {
            var nulls = '';
            if(term.nulls)
                nulls = term.nulls.escape();
            else if(part.nulls)
                nulls = part.nulls.escape();
/*~
			NULLIF([${i}$], ''$nulls'') AS [$term.name]$(part.hasMoreTerms())?,
~*/
            i++;
        }
/*~
		FROM (
            SELECT
                [match],
                ROW_NUMBER() OVER (ORDER BY [index] ASC) AS idx
            FROM
                [$S_SCHEMA].Splitter(ISNULL(forcedMaterializationTrick.[row], ''''), N''$regex'')
        ) s
        PIVOT (
            MAX([match]) FOR idx IN ($pivots)
        ) p
    ) m
~*/
    }
/*~
    CROSS APPLY (
        SELECT
            _id,
            metadata_CO_ID,
            metadata_JB_ID,
            _timestamp,
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
endMetadata();
/*~
END
GO
~*/
