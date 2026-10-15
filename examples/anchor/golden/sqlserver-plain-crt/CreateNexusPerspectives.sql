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
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
-- @assertion whether to show positve, negative, uncertain, or all posits (defaults to all)
--
-- The latest perspective shows the latest available (changing & positing) information for each nexus.
-- The now perspective shows the information as it is right now, with latest positing time.
-- The point-in-time perspective lets you travel through the information to the given timepoint,
-- with latest positing time and the given point in changing time.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes, with latest positing time, for each positor, which each row names.
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
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
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
    [DAT].EV_DAT_Positor,
    [DAT].EV_DAT_Reliability,
    [DAT].EV_DAT_Assertion,
    [DAT].EV_DAT_Event_Date,
    [AUD].EV_AUD_ID,
    [AUD].EV_AUD_PositedAt,
    [AUD].EV_AUD_Positor,
    [AUD].EV_AUD_Reliability,
    [AUD].EV_AUD_Assertion,
    [AUD].EV_AUD_Event_Audience,
    [REV].EV_REV_ID,
    [REV].EV_REV_PositedAt,
    [REV].EV_REV_Positor,
    [REV].EV_REV_Reliability,
    [REV].EV_REV_Assertion,
    [REV].EV_REV_Event_Revenue
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[ETY_EventType] [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
LEFT JOIN
    [dbo].[rEV_DAT_Event_Date](
        @positor,
        @positingTimepoint
    ) [DAT]
ON
    [DAT].EV_DAT_ID = (
        SELECT TOP 1
            sub.EV_DAT_ID
        FROM
            [dbo].[rEV_DAT_Event_Date](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_ID = [EV].EV_ID
        AND
            sub.EV_DAT_Assertion = isnull(@assertion, sub.EV_DAT_Assertion)
        ORDER BY
            sub.EV_DAT_PositedAt DESC,
            sub.EV_DAT_Reliability DESC
    )
LEFT JOIN
    [dbo].[rEV_AUD_Event_Audience](
        @positor,
        @positingTimepoint
    ) [AUD]
ON
    [AUD].EV_AUD_ID = (
        SELECT TOP 1
            sub.EV_AUD_ID
        FROM
            [dbo].[rEV_AUD_Event_Audience](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_ID = [EV].EV_ID
        AND
            sub.EV_AUD_Assertion = isnull(@assertion, sub.EV_AUD_Assertion)
        ORDER BY
            sub.EV_AUD_PositedAt DESC,
            sub.EV_AUD_Reliability DESC
    )
LEFT JOIN
    [dbo].[rEV_REV_Event_Revenue](
        @positor,
        @positingTimepoint
    ) [REV]
ON
    [REV].EV_REV_ID = (
        SELECT TOP 1
            sub.EV_REV_ID
        FROM
            [dbo].[rEV_REV_Event_Revenue](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_ID = [EV].EV_ID
        AND
            sub.EV_REV_Assertion = isnull(@assertion, sub.EV_REV_Assertion)
        ORDER BY
            sub.EV_REV_PositedAt DESC,
            sub.EV_REV_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lEV_Event viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lEV_Event]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tEV_Event] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
    ) [EV];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pEV_Event viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pEV_Event] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tEV_Event] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [EV];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_Event viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nEV_Event]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tEV_Event] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
    ) [EV];
GO
