-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_DAT_Event_Date parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.eEV_DAT_Event_Date', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[eEV_DAT_Event_Date] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_DAT_EV_ID,
        EV_DAT_EQ,
        EV_DAT_Event_Date
    FROM
        [dbo].[EV_DAT_Event_Date]
    WHERE
        EV_DAT_EQ = @equivalent;
    ');
END
GO
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.eEV_REV_Event_Revenue', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[eEV_REV_Event_Revenue] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_REV_EV_ID,
        EV_REV_EQ,
        EV_REV_Event_Revenue
    FROM
        [dbo].[EV_REV_Event_Revenue]
    WHERE
        EV_REV_EQ = @equivalent;
    ');
END
GO
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.eST_NAM_Stage_Name', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[eST_NAM_Stage_Name] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_NAM_ST_ID,
        ST_NAM_EQ,
        ST_NAM_Checksum,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    FROM
        [dbo].[ST_NAM_Stage_Name]
    WHERE
        ST_NAM_EQ = @equivalent;
    ');
END
GO
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.eST_LOC_Stage_Location', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[eST_LOC_Stage_Location] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_LOC_ST_ID,
        ST_LOC_EQ,
        ST_LOC_Checksum,
        ST_LOC_Stage_Location
    FROM
        [dbo].[ST_LOC_Stage_Location]
    WHERE
        ST_LOC_EQ = @equivalent;
    ');
END
GO
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.eAC_NAM_Actor_Name', 'IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[eAC_NAM_Actor_Name] (
        @equivalent tinyint
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_NAM_AC_ID,
        AC_NAM_EQ,
        AC_NAM_Checksum,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    FROM
        [dbo].[AC_NAM_Actor_Name]
    WHERE
        AC_NAM_EQ = @equivalent;
    ');
END
GO
