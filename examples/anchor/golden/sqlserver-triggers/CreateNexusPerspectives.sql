-- NEXUS TEMPORAL PERSPECTIVES --------------------------------------------------------------------------------------
--
-- These views and table valued functions provide temporal perspectives over each nexus,
-- denormalizing the nexus, its adjoined attributes, and any referenced knots (both from
-- roles and from knotted attributes) from sixth to third normal form.
--
-- Four types of perspectives are provided (mirroring anchors):
-- latest (l), point-in-time (p), difference (d), and now (n).
-- Under equivalence, corresponding e-prefixed variants (el, ep, ed, en) are generated.
--
-- The nexus base row is immutable; only its historized attributes change over time. Roles
-- (anchor/nexus/knot foreign keys stored in the base nexus table) are therefore treated as
-- static within temporal selection logic. Historization logic only applies to historized
-- attributes.
--
-- @changingTimepoint the point in changing time to travel to (for point-in-time functions)
-- @intervalStart the start of the interval for finding changes (difference)
-- @intervalEnd the end of the interval for finding changes (difference)
-- @selection list of mnemonics for tracked attributes, e.g. 'ABC DEF', or null for all (difference)
-- @equivalent the equivalent for which to retrieve data (equivalence variants)
--
-- Perspective generation is skipped for nexuses without attributes (to avoid redundant
-- projections identical to the base nexus table).
--
-- Drop perspectives ------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dEV_Event];
IF Object_ID('dbo.nEV_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[nEV_Event];
IF Object_ID('dbo.pEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pEV_Event];
IF Object_ID('dbo.lEV_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[lEV_Event];
GO
-- Latest perspective -----------------------------------------------------------------------------------------------
-- lEV_Event viewed by the latest available information (may include future versions)
----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lEV_Event] WITH SCHEMABINDING AS
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].SU_ID_for,
    [QTY].EV_QTY_EV_ID,
    [QTY].Metadata_EV_QTY,
    [QTY].EV_QTY_Event_Quantity,
    [PLC].EV_PLC_EV_ID,
    [PLC].Metadata_EV_PLC,
    [PLC].EV_PLC_ChangedAt,
    [PLC].EV_PLC_Event_Place
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[EV_QTY_Event_Quantity] [QTY]
ON
    [QTY].EV_QTY_EV_ID = [EV].EV_ID
LEFT JOIN
    [dbo].[EV_PLC_Event_Place] [PLC]
ON
    [PLC].EV_PLC_EV_ID = [EV].EV_ID
AND
    [PLC].EV_PLC_ChangedAt = (
        SELECT
            max(sub.EV_PLC_ChangedAt)
        FROM
            [dbo].[EV_PLC_Event_Place] sub
        WHERE
            sub.EV_PLC_EV_ID = [EV].EV_ID
   );
GO
-- Point-in-time perspective -----------------------------------------------------------------------------------------
-- pEV_Event viewed as it was on the given timepoint
----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pEV_Event] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].SU_ID_for,
    [QTY].EV_QTY_EV_ID,
    [QTY].Metadata_EV_QTY,
    [QTY].EV_QTY_Event_Quantity,
    [PLC].EV_PLC_EV_ID,
    [PLC].Metadata_EV_PLC,
    [PLC].EV_PLC_ChangedAt,
    [PLC].EV_PLC_Event_Place
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[EV_QTY_Event_Quantity] [QTY]
ON
    [QTY].EV_QTY_EV_ID = [EV].EV_ID
LEFT JOIN
    [dbo].[rEV_PLC_Event_Place](@changingTimepoint) [PLC]
ON
    [PLC].EV_PLC_EV_ID = [EV].EV_ID
AND
    [PLC].EV_PLC_ChangedAt = (
        SELECT
            max(sub.EV_PLC_ChangedAt)
        FROM
            [dbo].[rEV_PLC_Event_Place](@changingTimepoint) sub
        WHERE
            sub.EV_PLC_EV_ID = [EV].EV_ID
   );
GO
-- Now perspective --------------------------------------------------------------------------------------------------
-- nEV_Event viewed as it currently is (cannot include future versions)
----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nEV_Event]
AS
SELECT
    *
FROM
    [dbo].[pEV_Event](sysdatetime());
GO
-- Difference perspective -------------------------------------------------------------------------------------------
-- dEV_Event showing all differences between the given timepoints and optionally for a subset of attributes
----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dEV_Event] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pEV].*
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
    [dbo].[pEV_Event](timepoints.inspectedTimepoint) [pEV]
WHERE
    [pEV].EV_ID = timepoints.EV_ID;
GO
