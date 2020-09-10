-- create schema if it does not exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'metadata')
BEGIN
    EXEC( 'CREATE SCHEMA metadata' );
END
