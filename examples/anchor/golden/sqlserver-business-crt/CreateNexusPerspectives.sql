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
IF Object_ID('nexuses.dEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[dEV_Event];
IF Object_ID('nexuses.nEV_Event', 'V') IS NOT NULL
DROP VIEW [nexuses].[nEV_Event];
IF Object_ID('nexuses.pEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[pEV_Event];
IF Object_ID('nexuses.lEV_Event', 'V') IS NOT NULL
DROP VIEW [nexuses].[lEV_Event];
IF Object_ID('nexuses.tEV_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[tEV_Event];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tEV_Event viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[tEV_Event] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
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
    [DAT].EV_DAT_ID,
    [DAT].EV_DAT_PositedAt,
    [DAT].EV_DAT_Positor,
    [DAT].EV_DAT_Reliability,
    [DAT].EV_DAT_Assertion,
    [DAT].EV_DAT_Event_Date,
    [AUD].EV_AUD_EV_ID,
    [AUD].Metadata_EV_AUD,
    [AUD].EV_AUD_ID,
    [AUD].EV_AUD_PositedAt,
    [AUD].EV_AUD_Positor,
    [AUD].EV_AUD_Reliability,
    [AUD].EV_AUD_Assertion,
    [AUD].EV_AUD_Event_Audience,
    [REV].EV_REV_EV_ID,
    [REV].Metadata_EV_REV,
    [REV].EV_REV_ID,
    [REV].EV_REV_PositedAt,
    [REV].EV_REV_Positor,
    [REV].EV_REV_Reliability,
    [REV].EV_REV_Assertion,
    [REV].EV_REV_Event_Revenue,
    [STA].EV_STA_EV_ID,
    [STA].Metadata_EV_STA,
    [STA].EV_STA_ID,
    [STA].EV_STA_ChangedAt,
    [STA].EV_STA_PositedAt,
    [STA].EV_STA_Positor,
    [STA].EV_STA_Reliability,
    [STA].EV_STA_Assertion,
    [STA].EV_STA_Event_Status,
    [UTL].EV_UTL_EV_ID,
    [UTL].Metadata_EV_UTL,
    [UTL].EV_UTL_ID,
    [UTL].EV_UTL_PositedAt,
    [UTL].EV_UTL_Positor,
    [UTL].EV_UTL_Reliability,
    [UTL].EV_UTL_Assertion,
    [kUTL].UTL_Utilization AS EV_UTL_Event_Utilization,
    [kUTL].UTL_Utilization AS EV_UTL_UTL_Utilization,
    [kUTL].Metadata_UTL AS EV_UTL_Metadata_UTL,
    [UTL].EV_UTL_UTL_ID,
    [LVL].EV_LVL_EV_ID,
    [LVL].Metadata_EV_LVL,
    [LVL].EV_LVL_ID,
    [LVL].EV_LVL_ChangedAt,
    [LVL].EV_LVL_PositedAt,
    [LVL].EV_LVL_Positor,
    [LVL].EV_LVL_Reliability,
    [LVL].EV_LVL_Assertion,
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
    [attributes].[rEV_DAT_Event_Date](
        @positor,
        @positingTimepoint
    ) [DAT]
ON
    [DAT].EV_DAT_ID = (
        SELECT TOP 1
            sub.EV_DAT_ID
        FROM
            [attributes].[rEV_DAT_Event_Date](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_DAT_EV_ID = [EV].EV_ID
        AND
            sub.EV_DAT_Assertion = isnull(@assertion, sub.EV_DAT_Assertion)
        ORDER BY
            sub.EV_DAT_PositedAt DESC,
            sub.EV_DAT_Reliability DESC
    )
LEFT JOIN
    [attributes].[rEV_AUD_Event_Audience](
        @positor,
        @positingTimepoint
    ) [AUD]
ON
    [AUD].EV_AUD_ID = (
        SELECT TOP 1
            sub.EV_AUD_ID
        FROM
            [attributes].[rEV_AUD_Event_Audience](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_AUD_EV_ID = [EV].EV_ID
        AND
            sub.EV_AUD_Assertion = isnull(@assertion, sub.EV_AUD_Assertion)
        ORDER BY
            sub.EV_AUD_PositedAt DESC,
            sub.EV_AUD_Reliability DESC
    )
LEFT JOIN
    [attributes].[rEV_REV_Event_Revenue](
        @positor,
        @positingTimepoint
    ) [REV]
ON
    [REV].EV_REV_ID = (
        SELECT TOP 1
            sub.EV_REV_ID
        FROM
            [attributes].[rEV_REV_Event_Revenue](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_REV_EV_ID = [EV].EV_ID
        AND
            sub.EV_REV_Assertion = isnull(@assertion, sub.EV_REV_Assertion)
        ORDER BY
            sub.EV_REV_PositedAt DESC,
            sub.EV_REV_Reliability DESC
    )
LEFT JOIN
    [attributes].[rEV_STA_Event_Status](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [STA]
ON
    [STA].EV_STA_ID = (
        SELECT TOP 1
            sub.EV_STA_ID
        FROM
            [attributes].[rEV_STA_Event_Status](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_STA_EV_ID = [EV].EV_ID
        AND
            sub.EV_STA_Assertion = isnull(@assertion, sub.EV_STA_Assertion)
        ORDER BY
            sub.EV_STA_ChangedAt DESC,
            sub.EV_STA_PositedAt DESC,
            sub.EV_STA_Reliability DESC
    )
LEFT JOIN
    [attributes].[rEV_UTL_Event_Utilization](
        @positor,
        @positingTimepoint
    ) [UTL]
ON
    [UTL].EV_UTL_ID = (
        SELECT TOP 1
            sub.EV_UTL_ID
        FROM
            [attributes].[rEV_UTL_Event_Utilization](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_UTL_EV_ID = [EV].EV_ID
        AND
            sub.EV_UTL_Assertion = isnull(@assertion, sub.EV_UTL_Assertion)
        ORDER BY
            sub.EV_UTL_PositedAt DESC,
            sub.EV_UTL_Reliability DESC
    )
LEFT JOIN
    [knots].[UTL_Utilization] [kUTL]
ON
    [kUTL].UTL_ID = [UTL].EV_UTL_UTL_ID
LEFT JOIN
    [attributes].[rEV_LVL_Event_Level](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [LVL]
ON
    [LVL].EV_LVL_ID = (
        SELECT TOP 1
            sub.EV_LVL_ID
        FROM
            [attributes].[rEV_LVL_Event_Level](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_LVL_EV_ID = [EV].EV_ID
        AND
            sub.EV_LVL_Assertion = isnull(@assertion, sub.EV_LVL_Assertion)
        ORDER BY
            sub.EV_LVL_ChangedAt DESC,
            sub.EV_LVL_PositedAt DESC,
            sub.EV_LVL_Reliability DESC
    )
LEFT JOIN
    [knots].[PLV_ProfessionalLevel] [kLVL]
ON
    [kLVL].PLV_ID = [LVL].EV_LVL_PLV_ID;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lEV_Event viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [nexuses].[lEV_Event]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [nexuses].[tEV_Event] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
    ) [EV];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pEV_Event viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[pEV_Event] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [nexuses].[tEV_Event] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [EV];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_Event viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [nexuses].[nEV_Event]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [nexuses].[tEV_Event] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
    ) [EV];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dEV_Event showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].[dEV_Event] (
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
    [dw].[_Positor] p
JOIN (
    SELECT DISTINCT
        EV_STA_Positor AS positor,
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
        EV_LVL_Positor AS positor,
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
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [nexuses].[tEV_Event] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [EV]
 WHERE
    [EV].EV_ID = timepoints.EV_ID;
GO
