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
IF Object_ID('nexuses.dEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[dEV_Event];
IF Object_ID('nexuses.nEV_Event', 'V') IS NOT NULL
DROP VIEW [nexuses].[nEV_Event];
IF Object_ID('nexuses.pEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[pEV_Event];
IF Object_ID('nexuses.lEV_Event', 'V') IS NOT NULL
DROP VIEW [nexuses].[lEV_Event];
GO
IF OBJECT_ID('nexuses.uqEV_Event', 'V') IS NOT NULL
DROP VIEW [nexuses].[uqEV_Event];
GO
CREATE VIEW [nexuses].[uqEV_Event] WITH SCHEMABINDING AS
SELECT
    [EV].ST_ID_wasHeldAt,
    [EV].PR_ID_wasPlayed,
    [EV].ETY_ID_of,
    [DAT].EV_DAT_Event_Date
FROM
    [nexuses].[EV_Event] [EV]
INNER JOIN [attributes].[EV_DAT_Event_Date] [DAT]
    ON [DAT].EV_DAT_EV_ID = [EV].EV_ID
GO
CREATE UNIQUE CLUSTERED INDEX UQ_EV_Event
ON [nexuses].[uqEV_Event](
    ST_ID_wasHeldAt,
    PR_ID_wasPlayed,
    ETY_ID_of,
    EV_DAT_Event_Date
);
GO
-- Latest perspective -----------------------------------------------------------------------------------------------
-- lEV_Event viewed by the latest available information (may include future versions)
----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [nexuses].[lEV_Event] WITH SCHEMABINDING AS
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].ST_ID_wasHeldAt,
    [EV].PR_ID_wasPlayed,
    [ETY_of].ETY_Checksum AS of_ETY_Checksum,
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
    [REV].EV_REV_Event_Revenue,
    [STA].EV_STA_EV_ID,
    [STA].Metadata_EV_STA,
    [STA].EV_STA_ChangedAt,
    [STA].EV_STA_Event_Status,
    [UTL].EV_UTL_EV_ID,
    [UTL].Metadata_EV_UTL,
    [kUTL].UTL_Utilization AS EV_UTL_Event_Utilization,
    [kUTL].UTL_Utilization AS EV_UTL_UTL_Utilization,
    [kUTL].Metadata_UTL AS EV_UTL_Metadata_UTL,
    [UTL].EV_UTL_UTL_ID,
    [LVL].EV_LVL_EV_ID,
    [LVL].Metadata_EV_LVL,
    [LVL].EV_LVL_ChangedAt,
    [kLVL].PLV_Checksum AS EV_LVL_PLV_Checksum,
    [kLVL].PLV_ProfessionalLevel AS EV_LVL_Event_Level,
    [kLVL].PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    [kLVL].Metadata_PLV AS EV_LVL_Metadata_PLV,
    [LVL].EV_LVL_PLV_ID
FROM
    [nexuses].[EV_Event] [EV]
LEFT JOIN
    [knots].[ETY_EventType] [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
LEFT JOIN
    [attributes].[EV_DAT_Event_Date] [DAT]
ON
    [DAT].EV_DAT_EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[EV_AUD_Event_Audience] [AUD]
ON
    [AUD].EV_AUD_EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[EV_REV_Event_Revenue] [REV]
ON
    [REV].EV_REV_EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[EV_STA_Event_Status] [STA]
ON
    [STA].EV_STA_EV_ID = [EV].EV_ID
AND
    [STA].EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            [attributes].[EV_STA_Event_Status] sub
        WHERE
            sub.EV_STA_EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [attributes].[EV_UTL_Event_Utilization] [UTL]
ON
    [UTL].EV_UTL_EV_ID = [EV].EV_ID
LEFT JOIN
    [knots].[UTL_Utilization] [kUTL]
ON
    [kUTL].UTL_ID = [UTL].EV_UTL_UTL_ID
LEFT JOIN
    [attributes].[EV_LVL_Event_Level] [LVL]
ON
    [LVL].EV_LVL_EV_ID = [EV].EV_ID
AND
    [LVL].EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            [attributes].[EV_LVL_Event_Level] sub
        WHERE
            sub.EV_LVL_EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [knots].[PLV_ProfessionalLevel] [kLVL]
ON
    [kLVL].PLV_ID = [LVL].EV_LVL_PLV_ID;
GO
-- Point-in-time perspective -----------------------------------------------------------------------------------------
-- pEV_Event viewed as it was on the given timepoint
----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[pEV_Event] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].ST_ID_wasHeldAt,
    [EV].PR_ID_wasPlayed,
    [ETY_of].ETY_Checksum AS of_ETY_Checksum,
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
    [REV].EV_REV_Event_Revenue,
    [STA].EV_STA_EV_ID,
    [STA].Metadata_EV_STA,
    [STA].EV_STA_ChangedAt,
    [STA].EV_STA_Event_Status,
    [UTL].EV_UTL_EV_ID,
    [UTL].Metadata_EV_UTL,
    [kUTL].UTL_Utilization AS EV_UTL_Event_Utilization,
    [kUTL].UTL_Utilization AS EV_UTL_UTL_Utilization,
    [kUTL].Metadata_UTL AS EV_UTL_Metadata_UTL,
    [UTL].EV_UTL_UTL_ID,
    [LVL].EV_LVL_EV_ID,
    [LVL].Metadata_EV_LVL,
    [LVL].EV_LVL_ChangedAt,
    [kLVL].PLV_Checksum AS EV_LVL_PLV_Checksum,
    [kLVL].PLV_ProfessionalLevel AS EV_LVL_Event_Level,
    [kLVL].PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    [kLVL].Metadata_PLV AS EV_LVL_Metadata_PLV,
    [LVL].EV_LVL_PLV_ID
FROM
    [nexuses].[EV_Event] [EV]
LEFT JOIN
    [knots].[ETY_EventType] [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
LEFT JOIN
    [attributes].[EV_DAT_Event_Date] [DAT]
ON
    [DAT].EV_DAT_EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[EV_AUD_Event_Audience] [AUD]
ON
    [AUD].EV_AUD_EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[EV_REV_Event_Revenue] [REV]
ON
    [REV].EV_REV_EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[rEV_STA_Event_Status](@changingTimepoint) [STA]
ON
    [STA].EV_STA_EV_ID = [EV].EV_ID
AND
    [STA].EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            [attributes].[rEV_STA_Event_Status](@changingTimepoint) sub
        WHERE
            sub.EV_STA_EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [attributes].[EV_UTL_Event_Utilization] [UTL]
ON
    [UTL].EV_UTL_EV_ID = [EV].EV_ID
LEFT JOIN
    [knots].[UTL_Utilization] [kUTL]
ON
    [kUTL].UTL_ID = [UTL].EV_UTL_UTL_ID
LEFT JOIN
    [attributes].[rEV_LVL_Event_Level](@changingTimepoint) [LVL]
ON
    [LVL].EV_LVL_EV_ID = [EV].EV_ID
AND
    [LVL].EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            [attributes].[rEV_LVL_Event_Level](@changingTimepoint) sub
        WHERE
            sub.EV_LVL_EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [knots].[PLV_ProfessionalLevel] [kLVL]
ON
    [kLVL].PLV_ID = [LVL].EV_LVL_PLV_ID;
GO
-- Now perspective --------------------------------------------------------------------------------------------------
-- nEV_Event viewed as it currently is (cannot include future versions)
----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [nexuses].[nEV_Event]
AS
SELECT
    *
FROM
    [nexuses].[pEV_Event](sysdatetime());
GO
-- Difference perspective -------------------------------------------------------------------------------------------
-- dEV_Event showing all differences between the given timepoints and optionally for a subset of attributes
----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[dEV_Event] (
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
        EV_STA_EV_ID AS EV_ID,
        EV_STA_ChangedAt AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        [attributes].[EV_STA_Event_Status]
    WHERE
        (@selection is null OR @selection like '%STA%')
    AND
        EV_STA_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        EV_LVL_EV_ID AS EV_ID,
        EV_LVL_ChangedAt AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        [attributes].[EV_LVL_Event_Level]
    WHERE
        (@selection is null OR @selection like '%LVL%')
    AND
        EV_LVL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [nexuses].[pEV_Event](timepoints.inspectedTimepoint) [pEV]
WHERE
    [pEV].EV_ID = timepoints.EV_ID;
GO
