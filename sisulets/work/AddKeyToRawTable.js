/*~
IF Object_ID('$source.qualified$_AddKeyToRawTable', 'P') IS NOT NULL
DROP PROCEDURE [$source.qualified$_AddKeyToRawTable];
GO

CREATE PROCEDURE [$source.qualified$_AddKeyToRawTable] 
AS
BEGIN
    SET NOCOUNT ON;

    IF Object_ID('$source.qualified$_Raw', 'U') IS NOT NULL
    ALTER TABLE [$source.qualified$_Raw]
    ADD _id int identity(1,1) not null primary key;
END
GO
~*/