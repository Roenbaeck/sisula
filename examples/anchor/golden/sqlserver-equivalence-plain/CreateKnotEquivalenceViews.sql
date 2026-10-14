-- KNOT EQUIVALENCE VIEWS ---------------------------------------------------------------------------------------------
--
-- Equivalence views combine the identity and equivalent parts of a knot into a single view, making
-- it look and behave like a regular knot. They also make it possible to retrieve data for only the
-- given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- PAT_ParentalType view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PAT_ParentalType', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[PAT_ParentalType] WITH SCHEMABINDING
    AS
    SELECT
        i.PAT_ID,
        v.PAT_EQ,
        v.PAT_ParentalType
    FROM
        [dbo].[PAT_ParentalType_ID] i
    JOIN
        [dbo].[PAT_ParentalType_EQ] v
    ON
        v.PAT_ID = i.PAT_ID;
    ');
END
GO
IF Object_ID('dbo.ePAT_ParentalType', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[ePAT_ParentalType] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PAT_ID,
        PAT_EQ,
        PAT_ParentalType
    FROM
        [dbo].[PAT_ParentalType]
    WHERE
        PAT_EQ = @equivalent;
    ');
END
GO
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- GEN_Gender view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.GEN_Gender', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[GEN_Gender] WITH SCHEMABINDING
    AS
    SELECT
        i.GEN_ID,
        v.GEN_EQ,
        v.GEN_Gender
    FROM
        [dbo].[GEN_Gender_ID] i
    JOIN
        [dbo].[GEN_Gender_EQ] v
    ON
        v.GEN_ID = i.GEN_ID;
    ');
END
GO
IF Object_ID('dbo.eGEN_Gender', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[eGEN_Gender] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        GEN_ID,
        GEN_EQ,
        GEN_Gender
    FROM
        [dbo].[GEN_Gender]
    WHERE
        GEN_EQ = @equivalent;
    ');
END
GO
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ONG_Ongoing view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ONG_Ongoing', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[ONG_Ongoing] WITH SCHEMABINDING
    AS
    SELECT
        i.ONG_ID,
        v.ONG_EQ,
        v.ONG_Ongoing
    FROM
        [dbo].[ONG_Ongoing_ID] i
    JOIN
        [dbo].[ONG_Ongoing_EQ] v
    ON
        v.ONG_ID = i.ONG_ID;
    ');
END
GO
IF Object_ID('dbo.eONG_Ongoing', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[eONG_Ongoing] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ONG_ID,
        ONG_EQ,
        ONG_Ongoing
    FROM
        [dbo].[ONG_Ongoing]
    WHERE
        ONG_EQ = @equivalent;
    ');
END
GO
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- RAT_Rating view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.RAT_Rating', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[RAT_Rating] WITH SCHEMABINDING
    AS
    SELECT
        i.RAT_ID,
        v.RAT_EQ,
        v.RAT_Rating
    FROM
        [dbo].[RAT_Rating_ID] i
    JOIN
        [dbo].[RAT_Rating_EQ] v
    ON
        v.RAT_ID = i.RAT_ID;
    ');
END
GO
IF Object_ID('dbo.eRAT_Rating', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[eRAT_Rating] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        RAT_ID,
        RAT_EQ,
        RAT_Rating
    FROM
        [dbo].[RAT_Rating]
    WHERE
        RAT_EQ = @equivalent;
    ');
END
GO
