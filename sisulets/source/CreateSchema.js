/*~
-- create schema if it does not exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = '$S_SCHEMA')
BEGIN
    EXEC( 'CREATE SCHEMA $S_SCHEMA' );
END
GO
~*/
