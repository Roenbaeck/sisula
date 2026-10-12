-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are five types of perspectives: time traveling, latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
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
-- The latest perspective shows the latest available (changing & positing) information for each anchor.
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
IF Object_ID('dbo.dSU_Subject', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dSU_Subject];
IF Object_ID('dbo.nSU_Subject', 'V') IS NOT NULL
DROP VIEW [dbo].[nSU_Subject];
IF Object_ID('dbo.pSU_Subject', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pSU_Subject];
IF Object_ID('dbo.lSU_Subject', 'V') IS NOT NULL
DROP VIEW [dbo].[lSU_Subject];
IF Object_ID('dbo.tSU_Subject', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tSU_Subject];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tSU_Subject viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tSU_Subject] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [SU].SU_ID,
    [SU].Metadata_SU,
    [NAM].SU_NAM_SU_ID,
    [NAM].Metadata_SU_NAM,
    [NAM].SU_NAM_ID,
    [NAM].SU_NAM_PositedAt,
    [NAM].SU_NAM_Positor,
    [NAM].SU_NAM_Reliability,
    [NAM].SU_NAM_Assertion,
    [NAM].SU_NAM_Subject_Name,
    [COD].SU_COD_SU_ID,
    [COD].Metadata_SU_COD,
    [COD].SU_COD_ID,
    [COD].SU_COD_PositedAt,
    [COD].SU_COD_Positor,
    [COD].SU_COD_Reliability,
    [COD].SU_COD_Assertion,
    [COD].SU_COD_Subject_Code,
    [GRD].SU_GRD_SU_ID,
    [GRD].Metadata_SU_GRD,
    [GRD].SU_GRD_ID,
    [GRD].SU_GRD_PositedAt,
    [GRD].SU_GRD_Positor,
    [GRD].SU_GRD_Reliability,
    [GRD].SU_GRD_Assertion,
    [kGRD].GRD_Grade AS SU_GRD_GRD_Grade,
    [kGRD].Metadata_GRD AS SU_GRD_Metadata_GRD,
    [GRD].SU_GRD_GRD_ID,
    [NOT].SU_NOT_SU_ID,
    [NOT].Metadata_SU_NOT,
    [NOT].SU_NOT_ID,
    [NOT].SU_NOT_PositedAt,
    [NOT].SU_NOT_Positor,
    [NOT].SU_NOT_Reliability,
    [NOT].SU_NOT_Assertion,
    [NOT].SU_NOT_Checksum,
    [NOT].SU_NOT_Subject_Note,
    [TTL].SU_TTL_SU_ID,
    [TTL].Metadata_SU_TTL,
    [TTL].SU_TTL_ID,
    [TTL].SU_TTL_ChangedAt,
    [TTL].SU_TTL_PositedAt,
    [TTL].SU_TTL_Positor,
    [TTL].SU_TTL_Reliability,
    [TTL].SU_TTL_Assertion,
    [TTL].SU_TTL_Subject_Title,
    [STA].SU_STA_SU_ID,
    [STA].Metadata_SU_STA,
    [STA].SU_STA_ID,
    [STA].SU_STA_ChangedAt,
    [STA].SU_STA_PositedAt,
    [STA].SU_STA_Positor,
    [STA].SU_STA_Reliability,
    [STA].SU_STA_Assertion,
    [STA].SU_STA_Subject_State,
    [LBL].SU_LBL_SU_ID,
    [LBL].Metadata_SU_LBL,
    [LBL].SU_LBL_ID,
    [LBL].SU_LBL_ChangedAt,
    [LBL].SU_LBL_PositedAt,
    [LBL].SU_LBL_Positor,
    [LBL].SU_LBL_Reliability,
    [LBL].SU_LBL_Assertion,
    [LBL].SU_LBL_Subject_Label,
    [TAG].SU_TAG_SU_ID,
    [TAG].Metadata_SU_TAG,
    [TAG].SU_TAG_ID,
    [TAG].SU_TAG_ChangedAt,
    [TAG].SU_TAG_PositedAt,
    [TAG].SU_TAG_Positor,
    [TAG].SU_TAG_Reliability,
    [TAG].SU_TAG_Assertion,
    [TAG].SU_TAG_Subject_Tag,
    [LVL].SU_LVL_SU_ID,
    [LVL].Metadata_SU_LVL,
    [LVL].SU_LVL_ID,
    [LVL].SU_LVL_ChangedAt,
    [LVL].SU_LVL_PositedAt,
    [LVL].SU_LVL_Positor,
    [LVL].SU_LVL_Reliability,
    [LVL].SU_LVL_Assertion,
    [kLVL].GRD_Grade AS SU_LVL_GRD_Grade,
    [kLVL].Metadata_GRD AS SU_LVL_Metadata_GRD,
    [LVL].SU_LVL_GRD_ID,
    [TXT].SU_TXT_SU_ID,
    [TXT].Metadata_SU_TXT,
    [TXT].SU_TXT_ID,
    [TXT].SU_TXT_ChangedAt,
    [TXT].SU_TXT_PositedAt,
    [TXT].SU_TXT_Positor,
    [TXT].SU_TXT_Reliability,
    [TXT].SU_TXT_Assertion,
    [TXT].SU_TXT_Checksum,
    [TXT].SU_TXT_Subject_Text,
    [ASR].SU_ASR_SU_ID,
    [ASR].Metadata_SU_ASR,
    [ASR].SU_ASR_ID,
    [ASR].SU_ASR_ChangedAt,
    [ASR].SU_ASR_PositedAt,
    [ASR].SU_ASR_Positor,
    [ASR].SU_ASR_Reliability,
    [ASR].SU_ASR_Assertion,
    [ASR].SU_ASR_Subject_Assessment,
    [ERS].SU_ERS_SU_ID,
    [ERS].Metadata_SU_ERS,
    [ERS].SU_ERS_ID,
    [ERS].SU_ERS_ChangedAt,
    [ERS].SU_ERS_PositedAt,
    [ERS].SU_ERS_Positor,
    [ERS].SU_ERS_Reliability,
    [ERS].SU_ERS_Assertion,
    [ERS].SU_ERS_Subject_Erasable
FROM
    [dbo].[SU_Subject] [SU]
LEFT JOIN
    [dbo].[rSU_NAM_Subject_Name](
        @positor,
        @positingTimepoint
    ) [NAM]
ON
    [NAM].SU_NAM_ID = (
        SELECT TOP 1
            sub.SU_NAM_ID
        FROM
            [dbo].[rSU_NAM_Subject_Name](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_NAM_SU_ID = [SU].SU_ID
        AND
            sub.SU_NAM_Assertion = isnull(@assertion, sub.SU_NAM_Assertion)
        ORDER BY
            sub.SU_NAM_PositedAt DESC,
            sub.SU_NAM_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_COD_Subject_Code](
        @positor,
        @positingTimepoint
    ) [COD]
ON
    [COD].SU_COD_ID = (
        SELECT TOP 1
            sub.SU_COD_ID
        FROM
            [dbo].[rSU_COD_Subject_Code](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_COD_SU_ID = [SU].SU_ID
        AND
            sub.SU_COD_Assertion = isnull(@assertion, sub.SU_COD_Assertion)
        ORDER BY
            sub.SU_COD_PositedAt DESC,
            sub.SU_COD_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_GRD_Subject_Grade](
        @positor,
        @positingTimepoint
    ) [GRD]
ON
    [GRD].SU_GRD_ID = (
        SELECT TOP 1
            sub.SU_GRD_ID
        FROM
            [dbo].[rSU_GRD_Subject_Grade](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_GRD_SU_ID = [SU].SU_ID
        AND
            sub.SU_GRD_Assertion = isnull(@assertion, sub.SU_GRD_Assertion)
        ORDER BY
            sub.SU_GRD_PositedAt DESC,
            sub.SU_GRD_Reliability DESC
    )
LEFT JOIN
    [dbo].[GRD_Grade] [kGRD]
ON
    [kGRD].GRD_ID = [GRD].SU_GRD_GRD_ID
LEFT JOIN
    [dbo].[rSU_NOT_Subject_Note](
        @positor,
        @positingTimepoint
    ) [NOT]
ON
    [NOT].SU_NOT_ID = (
        SELECT TOP 1
            sub.SU_NOT_ID
        FROM
            [dbo].[rSU_NOT_Subject_Note](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_NOT_SU_ID = [SU].SU_ID
        AND
            sub.SU_NOT_Assertion = isnull(@assertion, sub.SU_NOT_Assertion)
        ORDER BY
            sub.SU_NOT_PositedAt DESC,
            sub.SU_NOT_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_TTL_Subject_Title](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [TTL]
ON
    [TTL].SU_TTL_ID = (
        SELECT TOP 1
            sub.SU_TTL_ID
        FROM
            [dbo].[rSU_TTL_Subject_Title](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_TTL_SU_ID = [SU].SU_ID
        AND
            sub.SU_TTL_Assertion = isnull(@assertion, sub.SU_TTL_Assertion)
        ORDER BY
            sub.SU_TTL_ChangedAt DESC,
            sub.SU_TTL_PositedAt DESC,
            sub.SU_TTL_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_STA_Subject_State](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [STA]
ON
    [STA].SU_STA_ID = (
        SELECT TOP 1
            sub.SU_STA_ID
        FROM
            [dbo].[rSU_STA_Subject_State](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_STA_SU_ID = [SU].SU_ID
        AND
            sub.SU_STA_Assertion = isnull(@assertion, sub.SU_STA_Assertion)
        ORDER BY
            sub.SU_STA_ChangedAt DESC,
            sub.SU_STA_PositedAt DESC,
            sub.SU_STA_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_LBL_Subject_Label](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [LBL]
ON
    [LBL].SU_LBL_ID = (
        SELECT TOP 1
            sub.SU_LBL_ID
        FROM
            [dbo].[rSU_LBL_Subject_Label](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_LBL_SU_ID = [SU].SU_ID
        AND
            sub.SU_LBL_Assertion = isnull(@assertion, sub.SU_LBL_Assertion)
        ORDER BY
            sub.SU_LBL_ChangedAt DESC,
            sub.SU_LBL_PositedAt DESC,
            sub.SU_LBL_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_TAG_Subject_Tag](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [TAG]
ON
    [TAG].SU_TAG_ID = (
        SELECT TOP 1
            sub.SU_TAG_ID
        FROM
            [dbo].[rSU_TAG_Subject_Tag](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_TAG_SU_ID = [SU].SU_ID
        AND
            sub.SU_TAG_Assertion = isnull(@assertion, sub.SU_TAG_Assertion)
        ORDER BY
            sub.SU_TAG_ChangedAt DESC,
            sub.SU_TAG_PositedAt DESC,
            sub.SU_TAG_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_LVL_Subject_Level](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [LVL]
ON
    [LVL].SU_LVL_ID = (
        SELECT TOP 1
            sub.SU_LVL_ID
        FROM
            [dbo].[rSU_LVL_Subject_Level](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_LVL_SU_ID = [SU].SU_ID
        AND
            sub.SU_LVL_Assertion = isnull(@assertion, sub.SU_LVL_Assertion)
        ORDER BY
            sub.SU_LVL_ChangedAt DESC,
            sub.SU_LVL_PositedAt DESC,
            sub.SU_LVL_Reliability DESC
    )
LEFT JOIN
    [dbo].[GRD_Grade] [kLVL]
ON
    [kLVL].GRD_ID = [LVL].SU_LVL_GRD_ID
LEFT JOIN
    [dbo].[rSU_TXT_Subject_Text](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [TXT]
ON
    [TXT].SU_TXT_ID = (
        SELECT TOP 1
            sub.SU_TXT_ID
        FROM
            [dbo].[rSU_TXT_Subject_Text](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_TXT_SU_ID = [SU].SU_ID
        AND
            sub.SU_TXT_Assertion = isnull(@assertion, sub.SU_TXT_Assertion)
        ORDER BY
            sub.SU_TXT_ChangedAt DESC,
            sub.SU_TXT_PositedAt DESC,
            sub.SU_TXT_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_ASR_Subject_Assessment](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [ASR]
ON
    [ASR].SU_ASR_ID = (
        SELECT TOP 1
            sub.SU_ASR_ID
        FROM
            [dbo].[rSU_ASR_Subject_Assessment](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_ASR_SU_ID = [SU].SU_ID
        AND
            sub.SU_ASR_Assertion = isnull(@assertion, sub.SU_ASR_Assertion)
        ORDER BY
            sub.SU_ASR_ChangedAt DESC,
            sub.SU_ASR_PositedAt DESC,
            sub.SU_ASR_Reliability DESC
    )
LEFT JOIN
    [dbo].[rSU_ERS_Subject_Erasable](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [ERS]
ON
    [ERS].SU_ERS_ID = (
        SELECT TOP 1
            sub.SU_ERS_ID
        FROM
            [dbo].[rSU_ERS_Subject_Erasable](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_ERS_SU_ID = [SU].SU_ID
        AND
            sub.SU_ERS_Assertion = isnull(@assertion, sub.SU_ERS_Assertion)
        ORDER BY
            sub.SU_ERS_ChangedAt DESC,
            sub.SU_ERS_PositedAt DESC,
            sub.SU_ERS_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_Subject viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_Subject]
AS
SELECT
    p.*, 
    cast(null as decimal(5,2)) as Reliability,
    [SU].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_Subject] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
    ) [SU];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_Subject viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_Subject] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [SU].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_Subject] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [SU];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_Subject viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_Subject]
AS
SELECT
    p.*, 
    cast(null as decimal(5,2)) as Reliability,
    [SU].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_Subject] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
    ) [SU];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dSU_Subject showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dSU_Subject] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    [SU].*
FROM
    [dbo].[_Positor] p
JOIN (
    SELECT DISTINCT
        SU_TTL_Positor AS positor,
        SU_TTL_SU_ID AS SU_ID,
        SU_TTL_ChangedAt AS inspectedTimepoint,
        'TTL' AS mnemonic
    FROM
        [dbo].[SU_TTL_Subject_Title]
    WHERE
        (@selection is null OR @selection like '%TTL%')
    AND
        SU_TTL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_STA_Positor AS positor,
        SU_STA_SU_ID AS SU_ID,
        SU_STA_ChangedAt AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        [dbo].[SU_STA_Subject_State]
    WHERE
        (@selection is null OR @selection like '%STA%')
    AND
        SU_STA_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_LBL_Positor AS positor,
        SU_LBL_SU_ID AS SU_ID,
        SU_LBL_ChangedAt AS inspectedTimepoint,
        'LBL' AS mnemonic
    FROM
        [dbo].[SU_LBL_Subject_Label]
    WHERE
        (@selection is null OR @selection like '%LBL%')
    AND
        SU_LBL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_TAG_Positor AS positor,
        SU_TAG_SU_ID AS SU_ID,
        SU_TAG_ChangedAt AS inspectedTimepoint,
        'TAG' AS mnemonic
    FROM
        [dbo].[SU_TAG_Subject_Tag]
    WHERE
        (@selection is null OR @selection like '%TAG%')
    AND
        SU_TAG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_LVL_Positor AS positor,
        SU_LVL_SU_ID AS SU_ID,
        SU_LVL_ChangedAt AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        [dbo].[SU_LVL_Subject_Level]
    WHERE
        (@selection is null OR @selection like '%LVL%')
    AND
        SU_LVL_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_TXT_Positor AS positor,
        SU_TXT_SU_ID AS SU_ID,
        SU_TXT_ChangedAt AS inspectedTimepoint,
        'TXT' AS mnemonic
    FROM
        [dbo].[SU_TXT_Subject_Text]
    WHERE
        (@selection is null OR @selection like '%TXT%')
    AND
        SU_TXT_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_ASR_Positor AS positor,
        SU_ASR_SU_ID AS SU_ID,
        SU_ASR_ChangedAt AS inspectedTimepoint,
        'ASR' AS mnemonic
    FROM
        [dbo].[SU_ASR_Subject_Assessment]
    WHERE
        (@selection is null OR @selection like '%ASR%')
    AND
        SU_ASR_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        SU_ERS_Positor AS positor,
        SU_ERS_SU_ID AS SU_ID,
        SU_ERS_ChangedAt AS inspectedTimepoint,
        'ERS' AS mnemonic
    FROM
        [dbo].[SU_ERS_Subject_Erasable]
    WHERE
        (@selection is null OR @selection like '%ERS%')
    AND
        SU_ERS_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [dbo].[tSU_Subject] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [SU]
 WHERE
    [SU].SU_ID = timepoints.SU_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dOB_Object', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dOB_Object];
IF Object_ID('dbo.nOB_Object', 'V') IS NOT NULL
DROP VIEW [dbo].[nOB_Object];
IF Object_ID('dbo.pOB_Object', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pOB_Object];
IF Object_ID('dbo.lOB_Object', 'V') IS NOT NULL
DROP VIEW [dbo].[lOB_Object];
IF Object_ID('dbo.tOB_Object', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tOB_Object];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tOB_Object viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tOB_Object] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [OB].OB_ID,
    [OB].Metadata_OB,
    [NAM].OB_NAM_OB_ID,
    [NAM].Metadata_OB_NAM,
    [NAM].OB_NAM_ID,
    [NAM].OB_NAM_PositedAt,
    [NAM].OB_NAM_Positor,
    [NAM].OB_NAM_Reliability,
    [NAM].OB_NAM_Assertion,
    [NAM].OB_NAM_Object_Name
FROM
    [dbo].[OB_Object] [OB]
LEFT JOIN
    [dbo].[rOB_NAM_Object_Name](
        @positor,
        @positingTimepoint
    ) [NAM]
ON
    [NAM].OB_NAM_ID = (
        SELECT TOP 1
            sub.OB_NAM_ID
        FROM
            [dbo].[rOB_NAM_Object_Name](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.OB_NAM_OB_ID = [OB].OB_ID
        AND
            sub.OB_NAM_Assertion = isnull(@assertion, sub.OB_NAM_Assertion)
        ORDER BY
            sub.OB_NAM_PositedAt DESC,
            sub.OB_NAM_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOB_Object viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lOB_Object]
AS
SELECT
    p.*, 
    cast(null as decimal(5,2)) as Reliability,
    [OB].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_Object] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
    ) [OB];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pOB_Object viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pOB_Object] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [OB].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_Object] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [OB];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOB_Object viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nOB_Object]
AS
SELECT
    p.*, 
    cast(null as decimal(5,2)) as Reliability,
    [OB].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_Object] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
    ) [OB];
GO
