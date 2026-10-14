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
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_NAM_Stage_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_NAM_Stage_Name] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        [dbo].[ST_NAM_Stage_Name]
    WHERE
        ST_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_AVG_Stage_Average','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_AVG_Stage_Average] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_ID,
        UTL_ID,
        ST_AVG_ChangedAt
    FROM
        [dbo].[ST_AVG_Stage_Average]
    WHERE
        ST_AVG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_NAM_Actor_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_NAM_Actor_Name] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        [dbo].[AC_NAM_Actor_Name]
    WHERE
        AC_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_PLV_Actor_ProfessionalLevel','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_PLV_Actor_ProfessionalLevel] (
        @changingTimepoint datetime2
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_ID,
        PLV_ID,
        AC_PLV_ChangedAt
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        AC_PLV_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_LEN_Program_Length','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_LEN_Program_Length] (
        @changingTimepoint date
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt
    FROM
        [dbo].[PR_LEN_Program_Length]
    WHERE
        PR_LEN_ChangedAt <= @changingTimepoint;
    ');
END
GO
