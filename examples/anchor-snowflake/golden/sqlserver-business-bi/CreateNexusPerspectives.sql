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
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
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
    [DAT].EV_DAT_Reliability,
    [DAT].EV_DAT_Event_Date,
    [AUD].EV_AUD_EV_ID,
    [AUD].Metadata_EV_AUD,
    [AUD].EV_AUD_ID,
    [AUD].EV_AUD_PositedAt,
    [AUD].EV_AUD_Reliability,
    [AUD].EV_AUD_Event_Audience,
    [REV].EV_REV_EV_ID,
    [REV].Metadata_EV_REV,
    [REV].EV_REV_ID,
    [REV].EV_REV_PositedAt,
    [REV].EV_REV_Reliability,
    [REV].EV_REV_Event_Revenue,
    [STA].EV_STA_EV_ID,
    [STA].Metadata_EV_STA,
    [STA].EV_STA_ID,
    [STA].EV_STA_ChangedAt,
    [STA].EV_STA_PositedAt,
    [STA].EV_STA_Reliability,
    [STA].EV_STA_Event_Status,
    [UTL].EV_UTL_EV_ID,
    [UTL].Metadata_EV_UTL,
    [UTL].EV_UTL_ID,
    [UTL].EV_UTL_PositedAt,
    [UTL].EV_UTL_Reliability,
    [UTL].UTL_Utilization AS EV_UTL_Event_Utilization,
    [UTL].UTL_Utilization AS EV_UTL_UTL_Utilization,
    [UTL].Metadata_UTL AS EV_UTL_Metadata_UTL,
    [UTL].EV_UTL_UTL_ID,
    [LVL].EV_LVL_EV_ID,
    [LVL].Metadata_EV_LVL,
    [LVL].EV_LVL_ID,
    [LVL].EV_LVL_ChangedAt,
    [LVL].EV_LVL_PositedAt,
    [LVL].EV_LVL_Reliability,
    [LVL].PLV_Checksum AS EV_LVL_PLV_Checksum,
    [LVL].PLV_ProfessionalLevel AS EV_LVL_Event_Level,
    [LVL].PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    [LVL].Metadata_PLV AS EV_LVL_Metadata_PLV,
    [LVL].EV_LVL_PLV_ID
FROM
    [nexuses].[EV_Event] [EV]
LEFT JOIN
    [knots].[ETY_EventType] [ETY_of]
ON
    [ETY_of].ETY_ID = [EV].ETY_ID_of
OUTER APPLY (
    SELECT TOP 1
        [rDAT].EV_DAT_EV_ID,
        [rDAT].Metadata_EV_DAT,
        [rDAT].EV_DAT_ID,
        [rDAT].EV_DAT_PositedAt,
        [rDAT].EV_DAT_Reliability,
        [rDAT].EV_DAT_Event_Date
    FROM
        [attributes].[rEV_DAT_Event_Date](
            @positingTimepoint
        ) [rDAT]
    WHERE
		[rDAT].EV_DAT_EV_ID = [EV].EV_ID
	AND 
		[rDAT].EV_DAT_Reliability = 1
	ORDER BY
        [rDAT].EV_DAT_PositedAt DESC
) [DAT]
OUTER APPLY (
    SELECT TOP 1
        [rAUD].EV_AUD_EV_ID,
        [rAUD].Metadata_EV_AUD,
        [rAUD].EV_AUD_ID,
        [rAUD].EV_AUD_PositedAt,
        [rAUD].EV_AUD_Reliability,
        [rAUD].EV_AUD_Event_Audience
    FROM
        [attributes].[rEV_AUD_Event_Audience](
            @positingTimepoint
        ) [rAUD]
    WHERE
		[rAUD].EV_AUD_EV_ID = [EV].EV_ID
	AND 
		[rAUD].EV_AUD_Reliability = 1
	ORDER BY
        [rAUD].EV_AUD_PositedAt DESC
) [AUD]
OUTER APPLY (
    SELECT TOP 1
        [rREV].EV_REV_EV_ID,
        [rREV].Metadata_EV_REV,
        [rREV].EV_REV_ID,
        [rREV].EV_REV_PositedAt,
        [rREV].EV_REV_Reliability,
        [rREV].EV_REV_Event_Revenue
    FROM
        [attributes].[rEV_REV_Event_Revenue](
            @positingTimepoint
        ) [rREV]
    WHERE
		[rREV].EV_REV_EV_ID = [EV].EV_ID
	AND 
		[rREV].EV_REV_Reliability = 1
	ORDER BY
        [rREV].EV_REV_PositedAt DESC
) [REV]
OUTER APPLY (
    SELECT TOP 1
        [rSTA].EV_STA_EV_ID,
        [rSTA].Metadata_EV_STA,
        [rSTA].EV_STA_ID,
        [rSTA].EV_STA_ChangedAt,
        [rSTA].EV_STA_PositedAt,
        [rSTA].EV_STA_Reliability,
        [rSTA].EV_STA_Event_Status
    FROM
        [attributes].[rEV_STA_Event_Status](
            @changingTimepoint,
            @positingTimepoint
        ) [rSTA]
    WHERE
		[rSTA].EV_STA_EV_ID = [EV].EV_ID
	AND 
		[rSTA].EV_STA_Reliability = 1
	ORDER BY
        [rSTA].EV_STA_ChangedAt DESC,
        [rSTA].EV_STA_PositedAt DESC
) [STA]
OUTER APPLY (
    SELECT TOP 1
        [rUTL].EV_UTL_EV_ID,
        [rUTL].Metadata_EV_UTL,
        [rUTL].EV_UTL_ID,
        [rUTL].EV_UTL_PositedAt,
        [rUTL].EV_UTL_Reliability,
        [kUTL].UTL_Utilization,
        [kUTL].UTL_Utilization,
        [kUTL].Metadata_UTL,
        [rUTL].EV_UTL_UTL_ID
    FROM
        [attributes].[rEV_UTL_Event_Utilization](
            @positingTimepoint
        ) [rUTL]
    JOIN
        [knots].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_ID = [rUTL].EV_UTL_UTL_ID
    WHERE
		[rUTL].EV_UTL_EV_ID = [EV].EV_ID
	AND 
		[rUTL].EV_UTL_Reliability = 1
	ORDER BY
        [rUTL].EV_UTL_PositedAt DESC
) [UTL]
OUTER APPLY (
    SELECT TOP 1
        [rLVL].EV_LVL_EV_ID,
        [rLVL].Metadata_EV_LVL,
        [rLVL].EV_LVL_ID,
        [rLVL].EV_LVL_ChangedAt,
        [rLVL].EV_LVL_PositedAt,
        [rLVL].EV_LVL_Reliability,
        [kLVL].PLV_Checksum,
        [kLVL].PLV_ProfessionalLevel,
        [kLVL].PLV_ProfessionalLevel,
        [kLVL].Metadata_PLV,
        [rLVL].EV_LVL_PLV_ID
    FROM
        [attributes].[rEV_LVL_Event_Level](
            @changingTimepoint,
            @positingTimepoint
        ) [rLVL]
    JOIN
        [knots].[PLV_ProfessionalLevel] [kLVL]
    ON
        [kLVL].PLV_ID = [rLVL].EV_LVL_PLV_ID
    WHERE
		[rLVL].EV_LVL_EV_ID = [EV].EV_ID
	AND 
		[rLVL].EV_LVL_Reliability = 1
	ORDER BY
        [rLVL].EV_LVL_ChangedAt DESC,
        [rLVL].EV_LVL_PositedAt DESC
) [LVL];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lEV_Event viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [nexuses].[lEV_Event]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [nexuses].tEV_Event (
        DEFAULT,
        DEFAULT
    ) [EV];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pEV_Event viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].pEV_Event (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [nexuses].tEV_Event (
        @changingTimepoint,
        DEFAULT
    ) [EV];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_Event viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [nexuses].nEV_Event
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [EV].*
FROM
    [nexuses].tEV_Event (
        sysdatetime(),
        DEFAULT
    ) [EV];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dEV_Event showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [nexuses].dEV_Event (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    [EV].*
FROM
    (
        SELECT DISTINCT
            timepoint AS inspectedTimepoint
        FROM
            [dw].[_AnchorTimepoints](
                @intervalStart,
                @intervalEnd
            )
    ) timepoints
CROSS APPLY
    [nexuses].pEV_Event(timepoints.inspectedTimepoint) [EV]
WHERE
    @selection is null
OR
    EXISTS (
        SELECT
            1
        FROM
            [dw].[pPositor]
        CROSS APPLY
            [dw].[_SplitMnemonic](@selection)
        JOIN
            [dw].[_AnchorAttributes]
        ON
            mnemonic = [attribute]
        AND
            [anchor] = 'EV_Event'
        JOIN
            [dw].[pPositor] positors
        ON
            positors.Positor = 0
        CROSS APPLY
            [dw].[_AttributeTimepoints](
                [capsule],
                [attribute],
                positors.Positor,
                @intervalStart,
                @intervalEnd
            )
        WHERE
            timepoint = timepoints.inspectedTimepoint
    );
GO
