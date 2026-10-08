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
    [EV].of_ETY_EventType AS [of_EventType],
    [EV].EV_DAT_Event_Date as [Date],
    [EV].EV_AUD_Event_Audience as [Audience],
    [EV].EV_REV_Event_Revenue as [Revenue],
    [EV].EV_STA_Event_Status as [Status],
    [EV].EV_UTL_UTL_Utilization as [Utilization_Utilization],
    [EV].EV_LVL_PLV_ProfessionalLevel as [Level_ProfessionalLevel]
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
    [EV].of_ETY_EventType AS [of_EventType],
    [EV].EV_DAT_Event_Date as [Date],
    [EV].EV_AUD_Event_Audience as [Audience],
    [EV].EV_REV_Event_Revenue as [Revenue],
    [EV].EV_STA_Event_Status as [Status],
    [EV].EV_UTL_UTL_Utilization as [Utilization_Utilization],
    [EV].EV_LVL_PLV_ProfessionalLevel as [Level_ProfessionalLevel]
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
        EV_STA_EV_ID AS EV_ID,
        EV_STA_ChangedAt AS [Time_of_Change],
        'Status' AS [Subject_of_Change]
    FROM
        [attributes].[EV_STA_Event_Status]
    WHERE
        (@selection is null OR @selection like '%STA%')
    AND
        EV_STA_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        EV_LVL_EV_ID AS EV_ID,
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
