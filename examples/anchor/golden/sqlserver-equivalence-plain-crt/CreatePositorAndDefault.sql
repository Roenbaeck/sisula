-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Positor', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[_Positor] (
        Positor tinyint not null,
        constraint pk_Positor primary key (
            Positor asc
        )
    );
    INSERT INTO [dbo].[_Positor] (
        Positor
    )
    VALUES (
        0 -- the default positor
    );
END
GO
