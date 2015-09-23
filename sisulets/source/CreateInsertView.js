// Create a raw view compatible with bulk inserts
/*~
IF Object_ID('$S_SCHEMA$.$source.qualified$_CreateInsertView', 'P') IS NOT NULL
DROP PROCEDURE [$S_SCHEMA].[$source.qualified$_CreateInsertView];
GO

--------------------------------------------------------------------------
-- Procedure: $source.qualified$_CreateInsertView
--
-- This view is created as exposing the single column that will be
-- the target of the BULK INSERT operation, since it cannot insert
-- into a table with multiple columns without a format file.
--
-- Generated: ${new Date()}$ by $VARIABLES.USERNAME
-- From: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain
--------------------------------------------------------------------------
CREATE PROCEDURE [$S_SCHEMA].[$source.qualified$_CreateInsertView] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
~*/
beginMetadata(source.qualified + '_CreateInsertView', source.name, 'Source');
if(source.split == 'bulk') {
    var term, part = source.firstPart();
/*~
    IF Object_ID('$S_SCHEMA$.$source.qualified$_Insert', 'V') IS NOT NULL
    DROP VIEW [$S_SCHEMA].[$source.qualified$_Insert];
    EXEC('
    CREATE VIEW [$S_SCHEMA].[$source.qualified$_Insert]
    AS
    SELECT
~*/
    while(term = part.nextTerm()) {
/*~
        [$term.name$]$(part.hasMoreTerms())?,
~*/
    }
/*~
    FROM
        [$S_SCHEMA].[$source.qualified$_RawSplit];
    ');
~*/
}
else {
/*~
    IF Object_ID('$S_SCHEMA$.$source.qualified$_Insert', 'V') IS NOT NULL
    DROP VIEW [$S_SCHEMA].[$source.qualified$_Insert];
    EXEC('
    CREATE VIEW [$S_SCHEMA].[$source.qualified$_Insert]
    AS
    SELECT
        [row]
    FROM
        [$S_SCHEMA].[$source.qualified$_Raw];
    ');
~*/
}
endMetadata();
/*~
END
GO
~*/
