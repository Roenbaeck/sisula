-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_STA_Event_Status rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_STA_Event_Status','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_STA_Event_Status] (
        @equivalent tinyint,
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_STA,
        EV_STA_EV_ID,
        EV_STA_EQ,
        EV_STA_Event_Status,
        EV_STA_ChangedAt
    FROM
        [attributes].[eEV_STA_Event_Status](@equivalent) 
    WHERE
        EV_STA_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Event_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_LVL_Event_Level','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_LVL_Event_Level] (
        @changingTimepoint date
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_LVL,
        EV_LVL_EV_ID,
        EV_LVL_PLV_ID,
        EV_LVL_ChangedAt
    FROM
        [attributes].[EV_LVL_Event_Level]
    WHERE
        EV_LVL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rST_NAM_Stage_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_NAM_Stage_Name] (
        @equivalent tinyint,
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_EQ,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        [attributes].[eST_NAM_Stage_Name](@equivalent) 
    WHERE
        ST_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rST_AVG_Stage_Average','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_AVG_Stage_Average] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt
    FROM
        [attributes].[ST_AVG_Stage_Average]
    WHERE
        ST_AVG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rAC_NAM_Actor_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rAC_NAM_Actor_Name] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        [attributes].[AC_NAM_Actor_Name]
    WHERE
        AC_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rAC_PLV_Actor_ProfessionalLevel','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rAC_PLV_Actor_ProfessionalLevel] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        AC_PLV_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rPR_LEN_Program_Length','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rPR_LEN_Program_Length] (
        @equivalent tinyint,
        @changingTimepoint date
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PR_LEN,
        PR_LEN_PR_ID,
        PR_LEN_EQ,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt
    FROM
        [attributes].[ePR_LEN_Program_Length](@equivalent) 
    WHERE
        PR_LEN_ChangedAt <= @changingTimepoint;
    ');
END
GO
