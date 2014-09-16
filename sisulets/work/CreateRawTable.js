// Create a raw table suitable for bulk insert
/*~
IF Object_ID('$source.qualified$_CreateRawTable', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_CreateRawTable];
GO

CREATE PROCEDURE [$source.qualified$_CreateRawTable] 
AS
BEGIN
    SET NOCOUNT ON;
    
    IF Object_ID('$source.qualified$_Raw', 'U') IS NOT NULL
    DROP TABLE [$source.qualified$_Raw];

    CREATE TABLE [$source.qualified$_Raw] (
        _id int identity(1,1) not null,
        _file int not null default 0,
        _timestamp datetime2(2) not null default sysdatetime(),
        [row] $(source.characterType == 'char')? varchar(max), : nvarchar(max),
        constraint [pk$source.qualified$_Raw] primary key(
            _id asc
        )
    );
END
GO
~*/
