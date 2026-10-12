-- NEXUS TEMPORAL BUSINESS PERSPECTIVES -----------------------------------------------------------------------------
--
-- These views and functions provide business friendly temporal perspectives over each nexus
-- paralleling the anchor and tie business perspectives. A nexus base row is immutable; only
-- its historized attributes vary over time. Roles (anchor/nexus/knot foreign keys) project
-- as business columns without historization logic.
--
-- Four base perspectives: Latest_, Point_, Difference_, Current_ (l / p / d / n)
-- Under equivalence: EQ_Latest_, EQ_Point_, EQ_Difference_, EQ_Current_ (el / ep / ed / en)
--
-- @changingTimepoint point in changing time for point-in-time functions
-- @intervalStart interval start (difference)
-- @intervalEnd interval end (difference)
-- @selection list of attribute mnemonics to filter differences (null = all)
-- @equivalent equivalence key (equivalence variants)
--
-- Generation is skipped for nexuses without attributes to avoid trivial duplication of the base table.
-- Knot value columns respect schema.KNOT_ALIASES for presentable naming; both alias and knot value
-- are exposed analogous to anchor business perspectives when aliases are disabled.
--
-- Latest perspective ------------------------------------------------------------------------------------------------
-- Latest_Event viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [nexuses].[Latest_Event] AS
SELECT
    [EV].EV_ID as [Event_Id],
    [EV].ST_ID_wasHeldAt as [Stage_wasHeldAt_Id],
    [EV].PR_ID_wasPlayed as [Program_wasPlayed_Id],
    [EV].ETY_EventType AS [of_EventType],
    [EV].EV_DAT_Event_Date as [Date],
    [EV].EV_AUD_Event_Audience as [Audience],
    [EV].EV_REV_Event_Revenue as [Revenue],
    [EV].EV_STA_Event_Status as [Status],
    [EV].UTL_Utilization as [],
    [EV].PLV_ProfessionalLevel as []
FROM
    [nexuses].[lEV_Event] [EV];
GO
-- Point-in-time perspective -----------------------------------------------------------------------------------------
-- Point_Event viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[Point_Event] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [EV].EV_ID as [Event_Id],
    [EV].ST_ID_wasHeldAt as [Stage_wasHeldAt_Id],
    [EV].PR_ID_wasPlayed as [Program_wasPlayed_Id],
    [EV].ETY_EventType AS [of_EventType],
    [EV].EV_DAT_Event_Date as [Date],
    [EV].EV_AUD_Event_Audience as [Audience],
    [EV].EV_REV_Event_Revenue as [Revenue],
    [EV].EV_STA_Event_Status as [Status],
    [EV].UTL_Utilization as [],
    [EV].PLV_ProfessionalLevel as []
FROM
    [nexuses].[pEV_Event](@changingTimepoint) [EV]
GO
-- Now perspective ---------------------------------------------------------------------------------------------------
-- Current_Event viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [nexuses].[Current_Event]
AS
SELECT
    *
FROM
    [nexuses].[Point_Event](sysdatetime());
GO
-- Difference perspective --------------------------------------------------------------------------------------------
-- Difference_Event showing differences between timepoints (optionally subset of attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[Difference_Event] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pEV].*
FROM (
    SELECT DISTINCT
        EV_ID AS EV_ID,
        EV_STA_ChangedAt AS [Time_of_Change],
        'Status' AS [Subject_of_Change]
    FROM
        [attributes].[eEV_STA_Event_Status](0) 
    WHERE
        (@selection is null OR @selection like '%STA%')
    AND
        EV_STA_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        EV_ID AS EV_ID,
        EV_LVL_ChangedAt AS [Time_of_Change],
        'Level' AS [Subject_of_Change]
    FROM
        [attributes].[EV_LVL_Event_Level]
    WHERE
        (@selection is null OR @selection like '%LVL%')
    AND
        EV_LVL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [nexuses].[Point_Event](timepoints.[Time_of_Change]) [pEV]
WHERE
    [pEV].Event_Id = timepoints.EV_ID;
GO
-- Latest equivalence perspective ------------------------------------------------------------------------------------
-- EQ_Latest_Event viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[EQ_Latest_Event] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    [EV].EV_ID as [Event_Id],
    [EV].ST_ID_wasHeldAt as [Stage_wasHeldAt_Id],
    [EV].PR_ID_wasPlayed as [Program_wasPlayed_Id],
    [EV].ETY_EventType AS [of_EventType],
    [EV].EV_DAT_Event_Date as [Date],
    [EV].EV_AUD_Event_Audience as [Audience],
    [EV].EV_REV_Event_Revenue as [Revenue],
    [EV].EV_STA_Event_Status as [Status],
    [EV].UTL_Utilization as [],
    [EV].PLV_ProfessionalLevel as []
FROM
    [nexuses].[elEV_Event](@equivalent) [EV];
GO
-- Point-in-time equivalence perspective -----------------------------------------------------------------------------
-- EQ_Point_Event viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[EQ_Point_Event] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [EV].EV_ID as [Event_Id],
    [EV].ST_ID_wasHeldAt as [Stage_wasHeldAt_Id],
    [EV].PR_ID_wasPlayed as [Program_wasPlayed_Id],
    [EV].ETY_EventType AS [of_EventType],
    [EV].EV_DAT_Event_Date as [Date],
    [EV].EV_AUD_Event_Audience as [Audience],
    [EV].EV_REV_Event_Revenue as [Revenue],
    [EV].EV_STA_Event_Status as [Status],
    [EV].UTL_Utilization as [],
    [EV].PLV_ProfessionalLevel as []
FROM
    [nexuses].[epEV_Event](@equivalent, @changingTimepoint) [EV]
GO
-- Now equivalence perspective ---------------------------------------------------------------------------------------
-- EQ_Current_Event viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[EQ_Current_Event] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [nexuses].[EQ_Point_Event](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective -------------------------------------------------------------------------------
-- EQ_Difference_Event showing differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[EQ_Difference_Event] (
    @equivalent tinyint,
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.[Time_of_Change],
    timepoints.[Subject_of_Change],
    [pEV].*
FROM (
    SELECT DISTINCT
        EV_ID AS EV_ID,
        EV_STA_ChangedAt AS [Time_of_Change],
        'Status' AS [Subject_of_Change]
    FROM
        [attributes].[eEV_STA_Event_Status](@equivalent) 
    WHERE
        (@selection is null OR @selection like '%STA%')
    AND
        EV_STA_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        EV_ID AS EV_ID,
        EV_LVL_ChangedAt AS [Time_of_Change],
        'Level' AS [Subject_of_Change]
    FROM
        [attributes].[EV_LVL_Event_Level]
    WHERE
        (@selection is null OR @selection like '%LVL%')
    AND
        EV_LVL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [nexuses].[EQ_Point_Event](@equivalent, timepoints.[Time_of_Change]) [pEV]
WHERE
    [pEV].Event_Id = timepoints.EV_ID;
GO
