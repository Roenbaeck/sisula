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
IF OBJECT_ID('dbo.uqEV_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[uqEV_Event];
GO
CREATE VIEW [dbo].[uqEV_Event] WITH SCHEMABINDING AS
SELECT
    [EV].ST_ID_wasHeldAt,
    [EV].PR_ID_wasPlayed,
    [EV].ETY_ID_of,
    [DAT].EV_DAT_Event_Date
FROM
    [dbo].[EV_Event] [EV]
INNER JOIN [dbo].[EV_DAT_Event_Date] [DAT]
    ON [DAT].EV_DAT_EV_ID = [EV].EV_ID
GO
CREATE UNIQUE CLUSTERED INDEX UQ_EV_Event
ON [dbo].[uqEV_Event](
    ST_ID_wasHeldAt,
    PR_ID_wasPlayed,
    ETY_ID_of,
    EV_DAT_Event_Date
);
GO
-- Latest perspective -----------------------------------------------------------------------------------------------
-- lEV_Event viewed by the latest available information (may include future versions)
----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lEV_Event] WITH SCHEMABINDING AS
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].ST_ID_wasHeldAt,
    [EV].PR_ID_wasPlayed,
    [ETY_of].ETY_EventType AS of_ETY_EventType,
    [ETY_of].Metadata_ETY AS of_Metadata_ETY,
    [EV].ETY_ID_of,
    [DAT].EV_DAT_EV_ID,
    [DAT].Metadata_EV_DAT,
    [DAT].EV_DAT_Event_Date,
    [AUD].EV_AUD_EV_ID,
    [AUD].Metadata_EV_AUD,
    [AUD].EV_AUD_Event_Audience,
    [REV].EV_REV_EV_ID,
    [REV].Metadata_EV_REV,
    [REV].EV_REV_Event_Revenue
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[ETY_EventType] [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
LEFT JOIN
    [dbo].[EV_DAT_Event_Date] [DAT]
ON
    [DAT].EV_DAT_EV_ID = [EV].EV_ID
LEFT JOIN
    [dbo].[EV_AUD_Event_Audience] [AUD]
ON
    [AUD].EV_AUD_EV_ID = [EV].EV_ID
LEFT JOIN
    [dbo].[EV_REV_Event_Revenue] [REV]
ON
    [REV].EV_REV_EV_ID = [EV].EV_ID;
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
    [EV].ST_ID_wasHeldAt,
    [EV].PR_ID_wasPlayed,
    [ETY_of].ETY_EventType AS of_ETY_EventType,
    [ETY_of].Metadata_ETY AS of_Metadata_ETY,
    [EV].ETY_ID_of,
    [DAT].EV_DAT_EV_ID,
    [DAT].Metadata_EV_DAT,
    [DAT].EV_DAT_Event_Date,
    [AUD].EV_AUD_EV_ID,
    [AUD].Metadata_EV_AUD,
    [AUD].EV_AUD_Event_Audience,
    [REV].EV_REV_EV_ID,
    [REV].Metadata_EV_REV,
    [REV].EV_REV_Event_Revenue
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN
    [dbo].[ETY_EventType] [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
LEFT JOIN
    [dbo].[EV_DAT_Event_Date] [DAT]
ON
    [DAT].EV_DAT_EV_ID = [EV].EV_ID
LEFT JOIN
    [dbo].[EV_AUD_Event_Audience] [AUD]
ON
    [AUD].EV_AUD_EV_ID = [EV].EV_ID
LEFT JOIN
    [dbo].[EV_REV_Event_Revenue] [REV]
ON
    [REV].EV_REV_EV_ID = [EV].EV_ID;
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
