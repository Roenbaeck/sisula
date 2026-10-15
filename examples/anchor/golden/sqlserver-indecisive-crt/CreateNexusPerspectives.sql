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
    [EV].Metadata_EV,
    [EV].SU_ID_for,
    [QTY].EV_QTY_EV_ID,
    [QTY].Metadata_EV_QTY,
    [QTY].EV_QTY_ID,
    [QTY].EV_QTY_PositedAt,
    [QTY].EV_QTY_Positor,
    [QTY].EV_QTY_Reliability,
    [QTY].EV_QTY_Assertion,
    [QTY].EV_QTY_Event_Quantity,
    [PLC].EV_PLC_EV_ID,
    [PLC].Metadata_EV_PLC,
    [PLC].EV_PLC_ID,
    [PLC].EV_PLC_ChangedAt,
    [PLC].EV_PLC_PositedAt,
    [PLC].EV_PLC_Positor,
    [PLC].EV_PLC_Reliability,
    [PLC].EV_PLC_Assertion,
    [PLC].EV_PLC_Event_Place
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[rEV_QTY_Event_Quantity](
        @positor,
        @positingTimepoint
    ) [QTY]
ON
    [QTY].EV_QTY_ID = (
        SELECT TOP 1
            sub.EV_QTY_ID
        FROM
            [dbo].[rEV_QTY_Event_Quantity](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_QTY_EV_ID = [EV].EV_ID
        AND
            sub.EV_QTY_Assertion = isnull(@assertion, sub.EV_QTY_Assertion)
        ORDER BY
            sub.EV_QTY_PositedAt DESC,
            sub.EV_QTY_Reliability DESC
    )
LEFT JOIN
    [dbo].[rEV_PLC_Event_Place](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [PLC]
ON
    [PLC].EV_PLC_ID = (
        SELECT TOP 1
            sub.EV_PLC_ID
        FROM
            [dbo].[rEV_PLC_Event_Place](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_PLC_EV_ID = [EV].EV_ID
        AND
            sub.EV_PLC_Assertion = isnull(@assertion, sub.EV_PLC_Assertion)
        ORDER BY
            sub.EV_PLC_ChangedAt DESC,
            sub.EV_PLC_PositedAt DESC,
            sub.EV_PLC_Reliability DESC
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
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dEV_Event showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dEV_Event] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    p.Positor,
    timepoints.inspectedTimepoint,
    [EV].*
FROM
    [dbo].[_Positor] p
JOIN (
    SELECT DISTINCT
        EV_PLC_Positor AS positor,
        EV_PLC_EV_ID AS EV_ID,
        EV_PLC_ChangedAt AS inspectedTimepoint,
        'PLC' AS mnemonic
    FROM
        [dbo].[EV_PLC_Event_Place]
    WHERE
        (@selection is null OR @selection like '%PLC%')
    AND
        EV_PLC_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [dbo].[tEV_Event] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [EV]
 WHERE
    [EV].EV_ID = timepoints.EV_ID;
GO
