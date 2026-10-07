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
IF Object_ID('nexuses.edEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[edEV_Event];
IF Object_ID('nexuses.enEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[enEV_Event];
IF Object_ID('nexuses.epEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[epEV_Event];
IF Object_ID('nexuses.elEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[elEV_Event];
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
    ON [DAT].EV_ID = [EV].EV_ID
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
    [ETY_of].ETY_Checksum AS ETY_Checksum,
    [ETY_of].ETY_EventType AS ETY_EventType,
    [ETY_of].ETY_EQ AS ETY_EQ,
    [ETY_of].Metadata_ETY AS Metadata_ETY,
    [EV].ETY_ID_of,
    [DAT].Metadata_EV_DAT,
    [DAT].EV_DAT_Event_Date,
    [AUD].Metadata_EV_AUD,
    [AUD].EV_AUD_EQ,
    [AUD].EV_AUD_Event_Audience,
    [REV].Metadata_EV_REV,
    [REV].EV_REV_EQ,
    [REV].EV_REV_Event_Revenue,
    [STA].Metadata_EV_STA,
    [STA].EV_STA_ChangedAt,
    [STA].EV_STA_EQ,
    [STA].EV_STA_Event_Status,
    [UTL].Metadata_EV_UTL,
    [kUTL].UTL_Utilization AS UTL_Utilization,
    [kUTL].Metadata_UTL AS Metadata_UTL,
    [UTL].UTL_ID,
    [LVL].Metadata_EV_LVL,
    [LVL].EV_LVL_ChangedAt,
    [kLVL].PLV_Checksum AS PLV_Checksum,
    [kLVL].PLV_EQ AS PLV_EQ,
    [kLVL].PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    [kLVL].Metadata_PLV AS Metadata_PLV,
    [LVL].PLV_ID
FROM
    [nexuses].[EV_Event] [EV]
LEFT JOIN
    [knots].[eETY_EventType](0) [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
LEFT JOIN
    [attributes].[EV_DAT_Event_Date] [DAT]
ON
    [DAT].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[eEV_AUD_Event_Audience](0) [AUD]
ON
    [AUD].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[eEV_REV_Event_Revenue](0) [REV]
ON
    [REV].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[eEV_STA_Event_Status](0) [STA]
ON
    [STA].EV_ID = [EV].EV_ID
AND
    [STA].EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            [attributes].[eEV_STA_Event_Status](0) sub 
        WHERE
            sub.EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [attributes].[EV_UTL_Event_Utilization] [UTL]
ON
    [UTL].EV_ID = [EV].EV_ID
LEFT JOIN
    [knots].[UTL_Utilization] [kUTL]
ON
    [kUTL].UTL_ID = [UTL].UTL_ID
LEFT JOIN
    [attributes].[EV_LVL_Event_Level] [LVL]
ON
    [LVL].EV_ID = [EV].EV_ID
AND
    [LVL].EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            [attributes].[EV_LVL_Event_Level] sub
        WHERE
            sub.EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [knots].[ePLV_ProfessionalLevel](0) [kLVL]
ON
    [kLVL].PLV_ID = [LVL].PLV_ID;
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
    [ETY_of].ETY_Checksum AS ETY_Checksum,
    [ETY_of].ETY_EventType AS ETY_EventType,
    [ETY_of].ETY_EQ AS ETY_EQ,
    [ETY_of].Metadata_ETY AS Metadata_ETY,
    [EV].ETY_ID_of,
    [DAT].Metadata_EV_DAT,
    [DAT].EV_DAT_Event_Date,
    [AUD].Metadata_EV_AUD,
    [AUD].EV_AUD_EQ,
    [AUD].EV_AUD_Event_Audience,
    [REV].Metadata_EV_REV,
    [REV].EV_REV_EQ,
    [REV].EV_REV_Event_Revenue,
    [STA].Metadata_EV_STA,
    [STA].EV_STA_ChangedAt,
    [STA].EV_STA_EQ,
    [STA].EV_STA_Event_Status,
    [UTL].Metadata_EV_UTL,
    [kUTL].UTL_Utilization AS UTL_Utilization,
    [kUTL].Metadata_UTL AS Metadata_UTL,
    [UTL].UTL_ID,
    [LVL].Metadata_EV_LVL,
    [LVL].EV_LVL_ChangedAt,
    [kLVL].PLV_Checksum AS PLV_Checksum,
    [kLVL].PLV_EQ AS PLV_EQ,
    [kLVL].PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    [kLVL].Metadata_PLV AS Metadata_PLV,
    [LVL].PLV_ID
FROM
    [nexuses].[EV_Event] [EV]
LEFT JOIN
    [knots].[eETY_EventType](0) [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
LEFT JOIN
    [attributes].[EV_DAT_Event_Date] [DAT]
ON
    [DAT].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[eEV_AUD_Event_Audience](0) [AUD]
ON
    [AUD].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[eEV_REV_Event_Revenue](0) [REV]
ON
    [REV].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[rEV_STA_Event_Status](0, @changingTimepoint) [STA]
ON
    [STA].EV_ID = [EV].EV_ID
AND
    [STA].EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            [attributes].[rEV_STA_Event_Status](0, @changingTimepoint) sub 
        WHERE
            sub.EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [attributes].[EV_UTL_Event_Utilization] [UTL]
ON
    [UTL].EV_ID = [EV].EV_ID
LEFT JOIN
    [knots].[UTL_Utilization] [kUTL]
ON
    [kUTL].UTL_ID = [UTL].UTL_ID
LEFT JOIN
    [attributes].[rEV_LVL_Event_Level](@changingTimepoint) [LVL]
ON
    [LVL].EV_ID = [EV].EV_ID
AND
    [LVL].EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            [attributes].[rEV_LVL_Event_Level](@changingTimepoint) sub
        WHERE
            sub.EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [knots].[ePLV_ProfessionalLevel](0) [kLVL]
ON
    [kLVL].PLV_ID = [LVL].PLV_ID;
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
        EV_ID AS EV_ID,
        EV_STA_ChangedAt AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        [attributes].[eEV_STA_Event_Status](0) 
    WHERE
        (@selection is null OR @selection like '%STA%')
    AND
        EV_STA_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        EV_ID AS EV_ID,
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
-- Latest equivalence perspective -----------------------------------------------------------------------------------
-- elEV_Event viewed by the latest available information (may include future versions)
----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[elEV_Event] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].ST_ID_wasHeldAt,
    [EV].PR_ID_wasPlayed,
    [ETY_of].ETY_Checksum AS ETY_Checksum,
    [ETY_of].ETY_EventType AS ETY_EventType,
    [ETY_of].ETY_EQ AS ETY_EQ,
    [ETY_of].Metadata_ETY AS Metadata_ETY,
    [EV].ETY_ID_of
    [DAT].Metadata_EV_DAT,
    [DAT].EV_DAT_Event_Date,
    [AUD].Metadata_EV_AUD,
    [AUD].EV_AUD_EQ,
    [AUD].EV_AUD_Event_Audience,
    [REV].Metadata_EV_REV,
    [REV].EV_REV_EQ,
    [REV].EV_REV_Event_Revenue,
    [STA].Metadata_EV_STA,
    [STA].EV_STA_ChangedAt,
    [STA].EV_STA_EQ,
    [STA].EV_STA_Event_Status,
    [UTL].Metadata_EV_UTL,
    [kUTL].UTL_Utilization AS UTL_Utilization,
    [kUTL].Metadata_UTL AS Metadata_UTL,
    [UTL].UTL_ID,
    [LVL].Metadata_EV_LVL,
    [LVL].EV_LVL_ChangedAt,
    [kLVL].PLV_Checksum AS PLV_Checksum,
    [kLVL].PLV_EQ AS PLV_EQ,
    [kLVL].PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    [kLVL].Metadata_PLV AS Metadata_PLV,
    [LVL].PLV_ID
FROM
    [nexuses].[EV_Event] [EV]
LEFT JOIN
    [knots].[eETY_EventType](@equivalent) [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
LEFT JOIN
    [attributes].[EV_DAT_Event_Date] [DAT]
ON
    [DAT].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[eEV_AUD_Event_Audience](@equivalent) [AUD]
ON
    [AUD].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[eEV_REV_Event_Revenue](@equivalent) [REV]
ON
    [REV].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[eEV_STA_Event_Status](@equivalent) [STA]
ON
    [STA].EV_ID = [EV].EV_ID
AND
    [STA].EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            [attributes].[eEV_STA_Event_Status](@equivalent) sub 
        WHERE
            sub.EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [attributes].[EV_UTL_Event_Utilization] [UTL]
ON
    [UTL].EV_ID = [EV].EV_ID
LEFT JOIN
    [knots].[UTL_Utilization] [kUTL]
ON
    [kUTL].UTL_ID = [UTL].UTL_ID
LEFT JOIN
    [attributes].[EV_LVL_Event_Level] [LVL]
ON
    [LVL].EV_ID = [EV].EV_ID
AND
    [LVL].EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            [attributes].[EV_LVL_Event_Level] sub
        WHERE
            sub.EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [knots].[ePLV_ProfessionalLevel](@equivalent) [kLVL]
ON
    [kLVL].PLV_ID = [LVL].PLV_ID;
GO
-- Point-in-time equivalence perspective -----------------------------------------------------------------------------
-- epEV_Event viewed as it was on the given timepoint
----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[epEV_Event] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [EV].EV_ID,
    [EV].Metadata_EV,
    [EV].ST_ID_wasHeldAt,
    [EV].PR_ID_wasPlayed,
    [ETY_of].ETY_Checksum AS ETY_Checksum,
    [ETY_of].ETY_EventType AS ETY_EventType,
    [ETY_of].ETY_EQ AS ETY_EQ,
    [ETY_of].Metadata_ETY AS Metadata_ETY,
    [EV].ETY_ID_of
    [DAT].Metadata_EV_DAT,
    [DAT].EV_DAT_Event_Date,
    [AUD].Metadata_EV_AUD,
    [AUD].EV_AUD_EQ,
    [AUD].EV_AUD_Event_Audience,
    [REV].Metadata_EV_REV,
    [REV].EV_REV_EQ,
    [REV].EV_REV_Event_Revenue,
    [STA].Metadata_EV_STA,
    [STA].EV_STA_ChangedAt,
    [STA].EV_STA_EQ,
    [STA].EV_STA_Event_Status,
    [UTL].Metadata_EV_UTL,
    [kUTL].UTL_Utilization AS UTL_Utilization,
    [kUTL].Metadata_UTL AS Metadata_UTL,
    [UTL].UTL_ID,
    [LVL].Metadata_EV_LVL,
    [LVL].EV_LVL_ChangedAt,
    [kLVL].PLV_Checksum AS PLV_Checksum,
    [kLVL].PLV_EQ AS PLV_EQ,
    [kLVL].PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    [kLVL].Metadata_PLV AS Metadata_PLV,
    [LVL].PLV_ID
FROM
    [nexuses].[EV_Event] [EV]
LEFT JOIN
    [knots].[eETY_EventType](@equivalent) [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
LEFT JOIN
    [attributes].[EV_DAT_Event_Date] [DAT]
ON
    [DAT].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[eEV_AUD_Event_Audience](@equivalent) [AUD]
ON
    [AUD].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[eEV_REV_Event_Revenue](@equivalent) [REV]
ON
    [REV].EV_ID = [EV].EV_ID
LEFT JOIN
    [attributes].[rEV_STA_Event_Status](@equivalent, @changingTimepoint) [STA]
ON
    [STA].EV_ID = [EV].EV_ID
AND
    [STA].EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            [attributes].[rEV_STA_Event_Status](@equivalent, @changingTimepoint) sub 
        WHERE
            sub.EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [attributes].[EV_UTL_Event_Utilization] [UTL]
ON
    [UTL].EV_ID = [EV].EV_ID
LEFT JOIN
    [knots].[UTL_Utilization] [kUTL]
ON
    [kUTL].UTL_ID = [UTL].UTL_ID
LEFT JOIN
    [attributes].[rEV_LVL_Event_Level](@changingTimepoint) [LVL]
ON
    [LVL].EV_ID = [EV].EV_ID
AND
    [LVL].EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            [attributes].[rEV_LVL_Event_Level](@changingTimepoint) sub
        WHERE
            sub.EV_ID = [EV].EV_ID
   )
LEFT JOIN
    [knots].[ePLV_ProfessionalLevel](@equivalent) [kLVL]
ON
    [kLVL].PLV_ID = [LVL].PLV_ID;
GO
-- Now equivalence perspective --------------------------------------------------------------------------------------
-- enEV_Event viewed as it currently is (cannot include future versions)
----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[enEV_Event] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [nexuses].[epEV_Event](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective -------------------------------------------------------------------------------
-- edEV_Event showing all differences between the given timepoints and optionally for a subset of attributes
----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[edEV_Event] (
    @equivalent tinyint,
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
        EV_ID AS EV_ID,
        EV_STA_ChangedAt AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        [attributes].[eEV_STA_Event_Status](@equivalent) 
    WHERE
        (@selection is null OR @selection like '%STA%')
    AND
        EV_STA_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        EV_ID AS EV_ID,
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
    [nexuses].[epEV_Event](@equivalent, timepoints.inspectedTimepoint) [pEV]
WHERE
    [pEV].EV_ID = timepoints.EV_ID;
GO
