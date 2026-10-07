-- ANCHOR TEMPORAL BUSINESS PERSPECTIVES ------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are four types of perspectives: latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The latest perspective shows the latest available information for each anchor.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-EQ perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Stage viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[Latest_Stage] AS
SELECT
    [ST].ST_ID as [Stage_Id],
    [ST].ST_NAM_Stage_Name as [Name],
    [ST].ST_LOC_Stage_Location as [Location],
    [ST].UTL_Utilization as [],
    [ST].UTL_Utilization as []
FROM
    [anchors].[lST_Stage] [ST];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[Point_Stage] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [ST].ST_ID as [Stage_Id],
    [ST].ST_NAM_Stage_Name as [Name],
    [ST].ST_LOC_Stage_Location as [Location],
    [ST].UTL_Utilization as [],
    [ST].UTL_Utilization as []
FROM
    [anchors].[pST_Stage](@changingTimepoint) [ST]
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[Current_Stage]
AS
SELECT
    *
FROM
    [anchors].[Point_Stage](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Stage showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[Difference_Stage] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pST].*
FROM (
    SELECT DISTINCT
        ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS [Time_of_Change],
        'Name' AS [Subject_of_Change]
    FROM
        [attributes].[eST_NAM_Stage_Name](0) 
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        ST_ID AS ST_ID,
        ST_AVG_ChangedAt AS [Time_of_Change],
        'Average' AS [Subject_of_Change]
    FROM
        [attributes].[ST_AVG_Stage_Average]
    WHERE
        (@selection is null OR @selection like '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[Point_Stage](timepoints.[Time_of_Change]) [pST]
WHERE
    [pST].Stage_Id = timepoints.ST_ID;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- EQ_Latest_Stage viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Latest_Stage] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    [ST].ST_ID as [Stage_Id],
    [ST].ST_NAM_Stage_Name as [Name],
    [ST].ST_LOC_Stage_Location as [Location],
    [ST].UTL_Utilization as [],
    [ST].UTL_Utilization as []
FROM
    [anchors].[elST_Stage](@equivalent) [ST];
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-- EQ_Point_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Point_Stage] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [ST].ST_ID as [Stage_Id],
    [ST].ST_NAM_Stage_Name as [Name],
    [ST].ST_LOC_Stage_Location as [Location],
    [ST].UTL_Utilization as [],
    [ST].UTL_Utilization as []
FROM
    [anchors].[epST_Stage](@equivalent, @changingTimepoint) [ST]
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- EQ_Current_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Current_Stage] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [anchors].[EQ_Point_Stage](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- EQ_Difference_Stage showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Difference_Stage] (
    @equivalent tinyint,
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pST].*
FROM (
    SELECT DISTINCT
        ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS [Time_of_Change],
        'Name' AS [Subject_of_Change]
    FROM
        [attributes].[eST_NAM_Stage_Name](@equivalent) 
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        ST_ID AS ST_ID,
        ST_AVG_ChangedAt AS [Time_of_Change],
        'Average' AS [Subject_of_Change]
    FROM
        [attributes].[ST_AVG_Stage_Average]
    WHERE
        (@selection is null OR @selection like '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[EQ_Point_Stage](@equivalent, timepoints.[Time_of_Change]) [pST]
WHERE
    [pST].Stage_Id = timepoints.ST_ID;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Actor viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[Latest_Actor] AS
SELECT
    [AC].AC_ID as [Actor_Id],
    [AC].AC_NAM_Actor_Name as [Name],
    [AC].GEN_Gender as [],
    [AC].PLV_ProfessionalLevel as []
FROM
    [anchors].[lAC_Actor] [AC];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[Point_Actor] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [AC].AC_ID as [Actor_Id],
    [AC].AC_NAM_Actor_Name as [Name],
    [AC].GEN_Gender as [],
    [AC].PLV_ProfessionalLevel as []
FROM
    [anchors].[pAC_Actor](@changingTimepoint) [AC]
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[Current_Actor]
AS
SELECT
    *
FROM
    [anchors].[Point_Actor](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Actor showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[Difference_Actor] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pAC].*
FROM (
    SELECT DISTINCT
        AC_ID AS AC_ID,
        AC_NAM_ChangedAt AS [Time_of_Change],
        'Name' AS [Subject_of_Change]
    FROM
        [attributes].[AC_NAM_Actor_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        AC_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        AC_ID AS AC_ID,
        AC_PLV_ChangedAt AS [Time_of_Change],
        'ProfessionalLevel' AS [Subject_of_Change]
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        (@selection is null OR @selection like '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[Point_Actor](timepoints.[Time_of_Change]) [pAC]
WHERE
    [pAC].Actor_Id = timepoints.AC_ID;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- EQ_Latest_Actor viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Latest_Actor] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    [AC].AC_ID as [Actor_Id],
    [AC].AC_NAM_Actor_Name as [Name],
    [AC].GEN_Gender as [],
    [AC].PLV_ProfessionalLevel as []
FROM
    [anchors].[elAC_Actor](@equivalent) [AC];
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-- EQ_Point_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Point_Actor] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [AC].AC_ID as [Actor_Id],
    [AC].AC_NAM_Actor_Name as [Name],
    [AC].GEN_Gender as [],
    [AC].PLV_ProfessionalLevel as []
FROM
    [anchors].[epAC_Actor](@equivalent, @changingTimepoint) [AC]
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- EQ_Current_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Current_Actor] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [anchors].[EQ_Point_Actor](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- EQ_Difference_Actor showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Difference_Actor] (
    @equivalent tinyint,
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pAC].*
FROM (
    SELECT DISTINCT
        AC_ID AS AC_ID,
        AC_NAM_ChangedAt AS [Time_of_Change],
        'Name' AS [Subject_of_Change]
    FROM
        [attributes].[AC_NAM_Actor_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        AC_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        AC_ID AS AC_ID,
        AC_PLV_ChangedAt AS [Time_of_Change],
        'ProfessionalLevel' AS [Subject_of_Change]
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        (@selection is null OR @selection like '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[EQ_Point_Actor](@equivalent, timepoints.[Time_of_Change]) [pAC]
WHERE
    [pAC].Actor_Id = timepoints.AC_ID;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Program viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[Latest_Program] AS
SELECT
    [PR].PR_ID as [Program_Id],
    [PR].PR_NAM_Program_Name as [Name],
    [PR].PR_LEN_Program_Length as [Length]
FROM
    [anchors].[lPR_Program] [PR];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[Point_Program] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [PR].PR_ID as [Program_Id],
    [PR].PR_NAM_Program_Name as [Name],
    [PR].PR_LEN_Program_Length as [Length]
FROM
    [anchors].[pPR_Program](@changingTimepoint) [PR]
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[Current_Program]
AS
SELECT
    *
FROM
    [anchors].[Point_Program](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Program showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[Difference_Program] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pPR].*
FROM (
    SELECT DISTINCT
        PR_ID AS PR_ID,
        PR_LEN_ChangedAt AS [Time_of_Change],
        'Length' AS [Subject_of_Change]
    FROM
        [attributes].[ePR_LEN_Program_Length](0) 
    WHERE
        (@selection is null OR @selection like '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[Point_Program](timepoints.[Time_of_Change]) [pPR]
WHERE
    [pPR].Program_Id = timepoints.PR_ID;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- EQ_Latest_Program viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Latest_Program] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    [PR].PR_ID as [Program_Id],
    [PR].PR_NAM_Program_Name as [Name],
    [PR].PR_LEN_Program_Length as [Length]
FROM
    [anchors].[elPR_Program](@equivalent) [PR];
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-- EQ_Point_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Point_Program] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [PR].PR_ID as [Program_Id],
    [PR].PR_NAM_Program_Name as [Name],
    [PR].PR_LEN_Program_Length as [Length]
FROM
    [anchors].[epPR_Program](@equivalent, @changingTimepoint) [PR]
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- EQ_Current_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Current_Program] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [anchors].[EQ_Point_Program](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- EQ_Difference_Program showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[EQ_Difference_Program] (
    @equivalent tinyint,
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pPR].*
FROM (
    SELECT DISTINCT
        PR_ID AS PR_ID,
        PR_LEN_ChangedAt AS [Time_of_Change],
        'Length' AS [Subject_of_Change]
    FROM
        [attributes].[ePR_LEN_Program_Length](@equivalent) 
    WHERE
        (@selection is null OR @selection like '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[EQ_Point_Program](@equivalent, timepoints.[Time_of_Change]) [pPR]
WHERE
    [pPR].Program_Id = timepoints.PR_ID;
GO
