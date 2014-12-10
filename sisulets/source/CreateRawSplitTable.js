// Create a columnar split table
if(source.split == 'bulk') {
var term, part = source.firstPart();
/*~
IF Object_ID('$source.qualified$_CreateRawSplitTable', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateRawSplitTable];
GO

--------------------------------------------------------------------------
-- Procedure: $source.qualified$_CreateRawSplitTable
--
-- The split table is populated by a bulk insert with a format file that
-- split rows from the source file into columns.
--
-- Create: $part.qualified$_RawSplit
--
-- Generated: ${new Date()}$ by $VARIABLES.USERNAME
-- From: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain
--------------------------------------------------------------------------
CREATE PROCEDURE [$source.qualified$_CreateRawSplitTable] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
~*/
beginMetadata(source.qualified + '_CreateRawSplitTable', source.name, 'Source');
var rowlength = source.rowlength ? source.rowlength : 'max';
/*~
    IF Object_ID('$source.qualified$_RawSplit', 'U') IS NOT NULL
    DROP TABLE [$source.qualified$_RawSplit];
    EXEC('
    CREATE TABLE [$source.qualified$_RawSplit] (
        _id int identity(1,1) not null,
        _file int not null default 0,
        _timestamp datetime2(2) not null default sysdatetime(),
~*/
while(term = part.nextTerm()) {
/*~
        [$term.name$] $(source.datafiletype == 'char')? varchar($rowlength), : nvarchar($rowlength),
~*/
}
/*~
        constraint [pk$source.qualified$_RawSplit] primary key(
            _id asc
        )
    )
    ');
~*/
endMetadata();
/*~
END
GO
~*/
}
