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
    [EV].Metadata_EV,
    [EV].SU_ID_for,
    [QTY].EV_QTY_EV_ID,
    [QTY].Metadata_EV_QTY,
    [QTY].EV_QTY_ID,
    [QTY].EV_QTY_PositedAt,
    [QTY].EV_QTY_Reliability,
    [QTY].EV_QTY_Event_Quantity,
    [PLC].EV_PLC_EV_ID,
    [PLC].Metadata_EV_PLC,
    [PLC].EV_PLC_ID,
    [PLC].EV_PLC_ChangedAt,
    [PLC].EV_PLC_PositedAt,
    [PLC].EV_PLC_Reliability,
    [PLC].EV_PLC_Event_Place
FROM
    [dbo].[EV_Event] [EV]
OUTER APPLY (
    SELECT TOP 1
        [rQTY].EV_QTY_EV_ID,
        [rQTY].Metadata_EV_QTY,
        [rQTY].EV_QTY_ID,
        [rQTY].EV_QTY_PositedAt,
        [rQTY].EV_QTY_Reliability,
        [rQTY].EV_QTY_Event_Quantity
    FROM
        [dbo].[rEV_QTY_Event_Quantity](
            @positingTimepoint
        ) [rQTY]
    WHERE
        [rQTY].EV_QTY_EV_ID = [EV].EV_ID
    AND
        [rQTY].EV_QTY_Reliability = 1
    ORDER BY
        [rQTY].EV_QTY_PositedAt DESC
) [QTY]
OUTER APPLY (
    SELECT TOP 1
        [rPLC].EV_PLC_EV_ID,
        [rPLC].Metadata_EV_PLC,
        [rPLC].EV_PLC_ID,
        [rPLC].EV_PLC_ChangedAt,
        [rPLC].EV_PLC_PositedAt,
        [rPLC].EV_PLC_Reliability,
        [rPLC].EV_PLC_Event_Place
    FROM
        [dbo].[rEV_PLC_Event_Place](
            @changingTimepoint,
            @positingTimepoint
        ) [rPLC]
    WHERE
        [rPLC].EV_PLC_EV_ID = [EV].EV_ID
    AND
        [rPLC].EV_PLC_Reliability = 1
    ORDER BY
        [rPLC].EV_PLC_ChangedAt DESC,
        [rPLC].EV_PLC_PositedAt DESC
) [PLC];
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
    [dbo].[tEV_Event] (
        DEFAULT,
        DEFAULT
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
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[tEV_Event] (
        @changingTimepoint,
        DEFAULT
    ) [EV];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_Event viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nEV_Event]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dbo].[tEV_Event] (
        sysdatetime(),
        DEFAULT
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
    timepoints.inspectedTimepoint,
    [EV].*
FROM (
    SELECT DISTINCT
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
CROSS APPLY
    [dbo].[tEV_Event] (
        timepoints.inspectedTimepoint,
        DEFAULT
    ) [EV]
 WHERE
    [EV].EV_ID = timepoints.EV_ID;
GO
