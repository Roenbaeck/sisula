-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.eEV_AUD_Event_Audience', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[eEV_AUD_Event_Audience] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_ID,
        EV_AUD_EQ,
        Metadata_EV_AUD,
        EV_AUD_Event_Audience
    FROM
        [attributes].[EV_AUD_Event_Audience]
    WHERE
        EV_AUD_EQ = @equivalent;
    ');
END
GO
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.eEV_REV_Event_Revenue', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[eEV_REV_Event_Revenue] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_ID,
        EV_REV_EQ,
        Metadata_EV_REV,
        EV_REV_Event_Revenue
    FROM
        [attributes].[EV_REV_Event_Revenue]
    WHERE
        EV_REV_EQ = @equivalent;
    ');
END
GO
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_STA_Event_Status parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.eEV_STA_Event_Status', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[eEV_STA_Event_Status] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_ID,
        EV_STA_EQ,
        EV_STA_ChangedAt,
        Metadata_EV_STA,
        EV_STA_Event_Status
    FROM
        [attributes].[EV_STA_Event_Status]
    WHERE
        EV_STA_EQ = @equivalent;
    ');
END
GO
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.eST_NAM_Stage_Name', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[eST_NAM_Stage_Name] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_ID,
        ST_NAM_EQ,
        ST_NAM_ChangedAt,
        Metadata_ST_NAM,
        ST_NAM_Stage_Name
    FROM
        [attributes].[ST_NAM_Stage_Name]
    WHERE
        ST_NAM_EQ = @equivalent;
    ');
END
GO
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.eST_LOC_Stage_Location', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[eST_LOC_Stage_Location] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_ID,
        ST_LOC_EQ,
        ST_LOC_Checksum,
        Metadata_ST_LOC,
        ST_LOC_Stage_Location
    FROM
        [attributes].[ST_LOC_Stage_Location]
    WHERE
        ST_LOC_EQ = @equivalent;
    ');
END
GO
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ePR_LEN_Program_Length', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[ePR_LEN_Program_Length] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_ID,
        PR_LEN_EQ,
        PR_LEN_ChangedAt,
        Metadata_PR_LEN,
        PR_LEN_Program_Length
    FROM
        [attributes].[PR_LEN_Program_Length]
    WHERE
        PR_LEN_EQ = @equivalent;
    ');
END
GO
