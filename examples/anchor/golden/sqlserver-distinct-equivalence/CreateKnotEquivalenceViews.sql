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
IF Object_ID('knots.PAT_ParentalType', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [knots].[PAT_ParentalType] WITH SCHEMABINDING
    AS
    SELECT
        v.Metadata_PAT,
        i.PAT_ID,
        v.PAT_EQ,
        v.PAT_ParentalType
    FROM
        [knots].[PAT_ParentalType_ID] i
    JOIN
        [knots].[PAT_ParentalType_EQ] v
    ON
        v.PAT_ID = i.PAT_ID;
    ');
END
GO
IF Object_ID('knots.ePAT_ParentalType', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [knots].[ePAT_ParentalType] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PAT,
        PAT_ID,
        PAT_EQ,
        PAT_ParentalType
    FROM
        [knots].[PAT_ParentalType]
    WHERE
        PAT_EQ = @equivalent;
    ');
END
GO
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.PLV_ProfessionalLevel', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [knots].[PLV_ProfessionalLevel] WITH SCHEMABINDING
    AS
    SELECT
        v.Metadata_PLV,
        i.PLV_ID,
        v.PLV_EQ,
        v.PLV_Checksum,
        v.PLV_ProfessionalLevel
    FROM
        [knots].[PLV_ProfessionalLevel_ID] i
    JOIN
        [knots].[PLV_ProfessionalLevel_EQ] v
    ON
        v.PLV_ID = i.PLV_ID;
    ');
END
GO
IF Object_ID('knots.ePLV_ProfessionalLevel', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [knots].[ePLV_ProfessionalLevel] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PLV,
        PLV_ID,
        PLV_EQ,
        PLV_Checksum,
        PLV_ProfessionalLevel
    FROM
        [knots].[PLV_ProfessionalLevel]
    WHERE
        PLV_EQ = @equivalent;
    ');
END
GO
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ONG_Ongoing view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.ONG_Ongoing', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [knots].[ONG_Ongoing] WITH SCHEMABINDING
    AS
    SELECT
        v.Metadata_ONG,
        i.ONG_ID,
        v.ONG_EQ,
        v.ONG_Ongoing
    FROM
        [knots].[ONG_Ongoing_ID] i
    JOIN
        [knots].[ONG_Ongoing_EQ] v
    ON
        v.ONG_ID = i.ONG_ID;
    ');
END
GO
IF Object_ID('knots.eONG_Ongoing', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [knots].[eONG_Ongoing] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ONG,
        ONG_ID,
        ONG_EQ,
        ONG_Ongoing
    FROM
        [knots].[ONG_Ongoing]
    WHERE
        ONG_EQ = @equivalent;
    ');
END
GO
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- RAT_Rating view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.RAT_Rating', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [knots].[RAT_Rating] WITH SCHEMABINDING
    AS
    SELECT
        v.Metadata_RAT,
        i.RAT_ID,
        v.RAT_EQ,
        v.RAT_Checksum,
        v.RAT_Rating
    FROM
        [knots].[RAT_Rating_ID] i
    JOIN
        [knots].[RAT_Rating_EQ] v
    ON
        v.RAT_ID = i.RAT_ID;
    ');
END
GO
IF Object_ID('knots.eRAT_Rating', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [knots].[eRAT_Rating] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_RAT,
        RAT_ID,
        RAT_EQ,
        RAT_Checksum,
        RAT_Rating
    FROM
        [knots].[RAT_Rating]
    WHERE
        RAT_EQ = @equivalent;
    ');
END
GO
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ETY_EventType view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('knots.ETY_EventType', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [knots].[ETY_EventType] WITH SCHEMABINDING
    AS
    SELECT
        v.Metadata_ETY,
        i.ETY_ID,
        v.ETY_EQ,
        v.ETY_Checksum,
        v.ETY_EventType
    FROM
        [knots].[ETY_EventType_ID] i
    JOIN
        [knots].[ETY_EventType_EQ] v
    ON
        v.ETY_ID = i.ETY_ID;
    ');
END
GO
IF Object_ID('knots.eETY_EventType', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [knots].[eETY_EventType] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ETY,
        ETY_ID,
        ETY_EQ,
        ETY_Checksum,
        ETY_EventType
    FROM
        [knots].[ETY_EventType]
    WHERE
        ETY_EQ = @equivalent;
    ');
END
GO
