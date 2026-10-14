-- NEXUS TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each nexus. There are five types of perspectives: time traveling, latest,
-- point-in-time, difference, and now. They also denormalize the nexus, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The time traveling perspective shows information as it was or will be based on a number
-- of input parameters.
--
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
--
-- The latest perspective shows the latest available (changing & positing) information for each nexus.
-- The now perspective shows the information as it is right now, with latest positing time.
-- The point-in-time perspective lets you travel through the information to the given timepoint,
-- with latest positing time and the given point in changing time.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes, with latest positing time.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dEV_Event];
IF Object_ID('dbo.nEV_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[nEV_Event];
IF Object_ID('dbo.pEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pEV_Event];
IF Object_ID('dbo.lEV_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[lEV_Event];
IF Object_ID('dbo.tEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tEV_Event];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tEV_Event viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tEV_Event] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [EV].EV_ID,
    [EV].ST_ID_wasHeldAt,
    [EV].PR_ID_wasPlayed,
    [ETY_of].ETY_EventType AS ETY_EventType,
    [EV].ETY_ID_of,
    [DAT].EV_DAT_ID,
    [DAT].EV_DAT_PositedAt,
    [DAT].EV_DAT_Reliability,
    [DAT].EV_DAT_Event_Date,
    [AUD].EV_AUD_ID,
    [AUD].EV_AUD_PositedAt,
    [AUD].EV_AUD_Reliability,
    [AUD].EV_AUD_Event_Audience,
    [REV].EV_REV_ID,
    [REV].EV_REV_PositedAt,
    [REV].EV_REV_Reliability,
    [REV].EV_REV_Event_Revenue
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[ETY_EventType] [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
OUTER APPLY (
    SELECT TOP 1
        [rDAT].EV_DAT_ID,
        [rDAT].EV_DAT_PositedAt,
        [rDAT].EV_DAT_Reliability,
        [rDAT].EV_DAT_Event_Date
    FROM
        [dbo].[rEV_DAT_Event_Date](
            @positingTimepoint
        ) [rDAT]
    WHERE
		[rDAT].EV_ID = [EV].EV_ID
	AND 
		[rDAT].EV_DAT_Reliability = 1
	ORDER BY
        [rDAT].EV_DAT_PositedAt DESC
) [DAT]
OUTER APPLY (
    SELECT TOP 1
        [rAUD].EV_AUD_ID,
        [rAUD].EV_AUD_PositedAt,
        [rAUD].EV_AUD_Reliability,
        [rAUD].EV_AUD_Event_Audience
    FROM
        [dbo].[rEV_AUD_Event_Audience](
            @positingTimepoint
        ) [rAUD]
    WHERE
		[rAUD].EV_ID = [EV].EV_ID
	AND 
		[rAUD].EV_AUD_Reliability = 1
	ORDER BY
        [rAUD].EV_AUD_PositedAt DESC
) [AUD]
OUTER APPLY (
    SELECT TOP 1
        [rREV].EV_REV_ID,
        [rREV].EV_REV_PositedAt,
        [rREV].EV_REV_Reliability,
        [rREV].EV_REV_Event_Revenue
    FROM
        [dbo].[rEV_REV_Event_Revenue](
            @positingTimepoint
        ) [rREV]
    WHERE
		[rREV].EV_ID = [EV].EV_ID
	AND 
		[rREV].EV_REV_Reliability = 1
	ORDER BY
        [rREV].EV_REV_PositedAt DESC
) [REV];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lEV_Event viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lEV_Event]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].tEV_Event (
        DEFAULT,
        DEFAULT
    ) [EV];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pEV_Event viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].pEV_Event (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].tEV_Event (
        @changingTimepoint,
        DEFAULT
    ) [EV];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_Event viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].nEV_Event
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].tEV_Event (
        sysdatetime(),
        DEFAULT
    ) [EV];
GO
