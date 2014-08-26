// Create a raw table suitable for bulk insert
/*~
IF Object_ID('sp_$source.qualified$_CreateRawTable', 'P') IS NOT NULL
DROP PROCEDURE [sp_$source.qualified$_CreateRawTable];
GO

CREATE PROCEDURE [sp_$source.qualified$_CreateRawTable] 
AS
BEGIN
    IF Object_ID('$source.qualified$_Raw', 'U') IS NOT NULL
    DROP TABLE [$source.qualified$_Raw];

    CREATE TABLE [$source.qualified$_Raw] (
        _id int identity(1,1) not null primary key,
        _row $(source.characterType == 'char')? varchar(max) : nvarchar(max)
    );
END
GO
~*/
