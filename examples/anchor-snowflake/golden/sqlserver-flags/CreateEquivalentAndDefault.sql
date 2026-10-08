-- EQUIVALENTS METADATA -----------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available equivalents. Since at least one equivalent
-- must be available the table is set up with a default equivalent with identity 0.
--
-- Equivalent table ---------------------------------------------------------------------------------------------------
IF Object_ID('dw._EQ', 'U') IS NULL
BEGIN
    CREATE TABLE [dw].[_EQ] (
        EQ tinyint not null,
        constraint pk_EQ primary key (
            EQ asc
        )
    );
    INSERT INTO [dw].[_EQ] (
        EQ
    )
    VALUES (
        0 -- the default equivalent
    );
END
GO
