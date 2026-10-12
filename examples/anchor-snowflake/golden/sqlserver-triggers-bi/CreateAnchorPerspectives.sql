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
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
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
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [SU].SU_ID,
    [SU].Metadata_SU,
    [NAM].SU_NAM_SU_ID,
    [NAM].Metadata_SU_NAM,
    [NAM].SU_NAM_ID,
    [NAM].SU_NAM_PositedAt,
    [NAM].SU_NAM_Reliability,
    [NAM].SU_NAM_Subject_Name,
    [COD].SU_COD_SU_ID,
    [COD].Metadata_SU_COD,
    [COD].SU_COD_ID,
    [COD].SU_COD_PositedAt,
    [COD].SU_COD_Reliability,
    [COD].SU_COD_Subject_Code,
    [GRD].SU_GRD_SU_ID,
    [GRD].Metadata_SU_GRD,
    [GRD].SU_GRD_ID,
    [GRD].SU_GRD_PositedAt,
    [GRD].SU_GRD_Reliability,
    [GRD].GRD_Grade AS SU_GRD_GRD_Grade,
    [GRD].Metadata_GRD AS SU_GRD_Metadata_GRD,
    [GRD].SU_GRD_GRD_ID,
    [NOT].SU_NOT_SU_ID,
    [NOT].Metadata_SU_NOT,
    [NOT].SU_NOT_ID,
    [NOT].SU_NOT_PositedAt,
    [NOT].SU_NOT_Reliability,
    [NOT].SU_NOT_Checksum,
    [NOT].SU_NOT_Subject_Note,
    [TTL].SU_TTL_SU_ID,
    [TTL].Metadata_SU_TTL,
    [TTL].SU_TTL_ID,
    [TTL].SU_TTL_ChangedAt,
    [TTL].SU_TTL_PositedAt,
    [TTL].SU_TTL_Reliability,
    [TTL].SU_TTL_Subject_Title,
    [STA].SU_STA_SU_ID,
    [STA].Metadata_SU_STA,
    [STA].SU_STA_ID,
    [STA].SU_STA_ChangedAt,
    [STA].SU_STA_PositedAt,
    [STA].SU_STA_Reliability,
    [STA].SU_STA_Subject_State,
    [LBL].SU_LBL_SU_ID,
    [LBL].Metadata_SU_LBL,
    [LBL].SU_LBL_ID,
    [LBL].SU_LBL_ChangedAt,
    [LBL].SU_LBL_PositedAt,
    [LBL].SU_LBL_Reliability,
    [LBL].SU_LBL_Subject_Label,
    [TAG].SU_TAG_SU_ID,
    [TAG].Metadata_SU_TAG,
    [TAG].SU_TAG_ID,
    [TAG].SU_TAG_ChangedAt,
    [TAG].SU_TAG_PositedAt,
    [TAG].SU_TAG_Reliability,
    [TAG].SU_TAG_Subject_Tag,
    [LVL].SU_LVL_SU_ID,
    [LVL].Metadata_SU_LVL,
    [LVL].SU_LVL_ID,
    [LVL].SU_LVL_ChangedAt,
    [LVL].SU_LVL_PositedAt,
    [LVL].SU_LVL_Reliability,
    [LVL].GRD_Grade AS SU_LVL_GRD_Grade,
    [LVL].Metadata_GRD AS SU_LVL_Metadata_GRD,
    [LVL].SU_LVL_GRD_ID,
    [TXT].SU_TXT_SU_ID,
    [TXT].Metadata_SU_TXT,
    [TXT].SU_TXT_ID,
    [TXT].SU_TXT_ChangedAt,
    [TXT].SU_TXT_PositedAt,
    [TXT].SU_TXT_Reliability,
    [TXT].SU_TXT_Checksum,
    [TXT].SU_TXT_Subject_Text,
    [ASR].SU_ASR_SU_ID,
    [ASR].Metadata_SU_ASR,
    [ASR].SU_ASR_ID,
    [ASR].SU_ASR_ChangedAt,
    [ASR].SU_ASR_PositedAt,
    [ASR].SU_ASR_Reliability,
    [ASR].SU_ASR_Subject_Assessment,
    [ERS].SU_ERS_SU_ID,
    [ERS].Metadata_SU_ERS,
    [ERS].SU_ERS_ID,
    [ERS].SU_ERS_ChangedAt,
    [ERS].SU_ERS_PositedAt,
    [ERS].SU_ERS_Reliability,
    [ERS].SU_ERS_Subject_Erasable
FROM
    [dbo].[SU_Subject] [SU]
OUTER APPLY (
    SELECT TOP 1
        [rNAM].SU_NAM_SU_ID,
        [rNAM].Metadata_SU_NAM,
        [rNAM].SU_NAM_ID,
        [rNAM].SU_NAM_PositedAt,
        [rNAM].SU_NAM_Reliability,
        [rNAM].SU_NAM_Subject_Name
    FROM
        [dbo].[rSU_NAM_Subject_Name](
            @positingTimepoint
        ) [rNAM]
    WHERE
		[rNAM].SU_NAM_SU_ID = [SU].SU_ID
	AND 
		[rNAM].SU_NAM_Reliability = 1
	ORDER BY
        [rNAM].SU_NAM_PositedAt DESC
) [NAM]
OUTER APPLY (
    SELECT TOP 1
        [rCOD].SU_COD_SU_ID,
        [rCOD].Metadata_SU_COD,
        [rCOD].SU_COD_ID,
        [rCOD].SU_COD_PositedAt,
        [rCOD].SU_COD_Reliability,
        [rCOD].SU_COD_Subject_Code
    FROM
        [dbo].[rSU_COD_Subject_Code](
            @positingTimepoint
        ) [rCOD]
    WHERE
		[rCOD].SU_COD_SU_ID = [SU].SU_ID
	AND 
		[rCOD].SU_COD_Reliability = 1
	ORDER BY
        [rCOD].SU_COD_PositedAt DESC
) [COD]
OUTER APPLY (
    SELECT TOP 1
        [rGRD].SU_GRD_SU_ID,
        [rGRD].Metadata_SU_GRD,
        [rGRD].SU_GRD_ID,
        [rGRD].SU_GRD_PositedAt,
        [rGRD].SU_GRD_Reliability,
        [kGRD].GRD_Grade,
        [kGRD].Metadata_GRD,
        [rGRD].SU_GRD_GRD_ID
    FROM
        [dbo].[rSU_GRD_Subject_Grade](
            @positingTimepoint
        ) [rGRD]
    JOIN
        [dbo].[GRD_Grade] [kGRD]
    ON
        [kGRD].GRD_ID = [rGRD].SU_GRD_GRD_ID
    WHERE
		[rGRD].SU_GRD_SU_ID = [SU].SU_ID
	AND 
		[rGRD].SU_GRD_Reliability = 1
	ORDER BY
        [rGRD].SU_GRD_PositedAt DESC
) [GRD]
OUTER APPLY (
    SELECT TOP 1
        [rNOT].SU_NOT_SU_ID,
        [rNOT].Metadata_SU_NOT,
        [rNOT].SU_NOT_ID,
        [rNOT].SU_NOT_PositedAt,
        [rNOT].SU_NOT_Reliability,
        [rNOT].SU_NOT_Checksum,
        [rNOT].SU_NOT_Subject_Note
    FROM
        [dbo].[rSU_NOT_Subject_Note](
            @positingTimepoint
        ) [rNOT]
    WHERE
		[rNOT].SU_NOT_SU_ID = [SU].SU_ID
	AND 
		[rNOT].SU_NOT_Reliability = 1
	ORDER BY
        [rNOT].SU_NOT_PositedAt DESC
) [NOT]
OUTER APPLY (
    SELECT TOP 1
        [rTTL].SU_TTL_SU_ID,
        [rTTL].Metadata_SU_TTL,
        [rTTL].SU_TTL_ID,
        [rTTL].SU_TTL_ChangedAt,
        [rTTL].SU_TTL_PositedAt,
        [rTTL].SU_TTL_Reliability,
        [rTTL].SU_TTL_Subject_Title
    FROM
        [dbo].[rSU_TTL_Subject_Title](
            @changingTimepoint,
            @positingTimepoint
        ) [rTTL]
    WHERE
		[rTTL].SU_TTL_SU_ID = [SU].SU_ID
	AND 
		[rTTL].SU_TTL_Reliability = 1
	ORDER BY
        [rTTL].SU_TTL_ChangedAt DESC,
        [rTTL].SU_TTL_PositedAt DESC
) [TTL]
OUTER APPLY (
    SELECT TOP 1
        [rSTA].SU_STA_SU_ID,
        [rSTA].Metadata_SU_STA,
        [rSTA].SU_STA_ID,
        [rSTA].SU_STA_ChangedAt,
        [rSTA].SU_STA_PositedAt,
        [rSTA].SU_STA_Reliability,
        [rSTA].SU_STA_Subject_State
    FROM
        [dbo].[rSU_STA_Subject_State](
            @changingTimepoint,
            @positingTimepoint
        ) [rSTA]
    WHERE
		[rSTA].SU_STA_SU_ID = [SU].SU_ID
	AND 
		[rSTA].SU_STA_Reliability = 1
	ORDER BY
        [rSTA].SU_STA_ChangedAt DESC,
        [rSTA].SU_STA_PositedAt DESC
) [STA]
OUTER APPLY (
    SELECT TOP 1
        [rLBL].SU_LBL_SU_ID,
        [rLBL].Metadata_SU_LBL,
        [rLBL].SU_LBL_ID,
        [rLBL].SU_LBL_ChangedAt,
        [rLBL].SU_LBL_PositedAt,
        [rLBL].SU_LBL_Reliability,
        [rLBL].SU_LBL_Subject_Label
    FROM
        [dbo].[rSU_LBL_Subject_Label](
            @changingTimepoint,
            @positingTimepoint
        ) [rLBL]
    WHERE
		[rLBL].SU_LBL_SU_ID = [SU].SU_ID
	AND 
		[rLBL].SU_LBL_Reliability = 1
	ORDER BY
        [rLBL].SU_LBL_ChangedAt DESC,
        [rLBL].SU_LBL_PositedAt DESC
) [LBL]
OUTER APPLY (
    SELECT TOP 1
        [rTAG].SU_TAG_SU_ID,
        [rTAG].Metadata_SU_TAG,
        [rTAG].SU_TAG_ID,
        [rTAG].SU_TAG_ChangedAt,
        [rTAG].SU_TAG_PositedAt,
        [rTAG].SU_TAG_Reliability,
        [rTAG].SU_TAG_Subject_Tag
    FROM
        [dbo].[rSU_TAG_Subject_Tag](
            @changingTimepoint,
            @positingTimepoint
        ) [rTAG]
    WHERE
		[rTAG].SU_TAG_SU_ID = [SU].SU_ID
	AND 
		[rTAG].SU_TAG_Reliability = 1
	ORDER BY
        [rTAG].SU_TAG_ChangedAt DESC,
        [rTAG].SU_TAG_PositedAt DESC
) [TAG]
OUTER APPLY (
    SELECT TOP 1
        [rLVL].SU_LVL_SU_ID,
        [rLVL].Metadata_SU_LVL,
        [rLVL].SU_LVL_ID,
        [rLVL].SU_LVL_ChangedAt,
        [rLVL].SU_LVL_PositedAt,
        [rLVL].SU_LVL_Reliability,
        [kLVL].GRD_Grade,
        [kLVL].Metadata_GRD,
        [rLVL].SU_LVL_GRD_ID
    FROM
        [dbo].[rSU_LVL_Subject_Level](
            @changingTimepoint,
            @positingTimepoint
        ) [rLVL]
    JOIN
        [dbo].[GRD_Grade] [kLVL]
    ON
        [kLVL].GRD_ID = [rLVL].SU_LVL_GRD_ID
    WHERE
		[rLVL].SU_LVL_SU_ID = [SU].SU_ID
	AND 
		[rLVL].SU_LVL_Reliability = 1
	ORDER BY
        [rLVL].SU_LVL_ChangedAt DESC,
        [rLVL].SU_LVL_PositedAt DESC
) [LVL]
OUTER APPLY (
    SELECT TOP 1
        [rTXT].SU_TXT_SU_ID,
        [rTXT].Metadata_SU_TXT,
        [rTXT].SU_TXT_ID,
        [rTXT].SU_TXT_ChangedAt,
        [rTXT].SU_TXT_PositedAt,
        [rTXT].SU_TXT_Reliability,
        [rTXT].SU_TXT_Checksum,
        [rTXT].SU_TXT_Subject_Text
    FROM
        [dbo].[rSU_TXT_Subject_Text](
            @changingTimepoint,
            @positingTimepoint
        ) [rTXT]
    WHERE
		[rTXT].SU_TXT_SU_ID = [SU].SU_ID
	AND 
		[rTXT].SU_TXT_Reliability = 1
	ORDER BY
        [rTXT].SU_TXT_ChangedAt DESC,
        [rTXT].SU_TXT_PositedAt DESC
) [TXT]
OUTER APPLY (
    SELECT TOP 1
        [rASR].SU_ASR_SU_ID,
        [rASR].Metadata_SU_ASR,
        [rASR].SU_ASR_ID,
        [rASR].SU_ASR_ChangedAt,
        [rASR].SU_ASR_PositedAt,
        [rASR].SU_ASR_Reliability,
        [rASR].SU_ASR_Subject_Assessment
    FROM
        [dbo].[rSU_ASR_Subject_Assessment](
            @changingTimepoint,
            @positingTimepoint
        ) [rASR]
    WHERE
		[rASR].SU_ASR_SU_ID = [SU].SU_ID
	AND 
		[rASR].SU_ASR_Reliability = 1
	ORDER BY
        [rASR].SU_ASR_ChangedAt DESC,
        [rASR].SU_ASR_PositedAt DESC
) [ASR]
OUTER APPLY (
    SELECT TOP 1
        [rERS].SU_ERS_SU_ID,
        [rERS].Metadata_SU_ERS,
        [rERS].SU_ERS_ID,
        [rERS].SU_ERS_ChangedAt,
        [rERS].SU_ERS_PositedAt,
        [rERS].SU_ERS_Reliability,
        [rERS].SU_ERS_Subject_Erasable
    FROM
        [dbo].[rSU_ERS_Subject_Erasable](
            @changingTimepoint,
            @positingTimepoint
        ) [rERS]
    WHERE
		[rERS].SU_ERS_SU_ID = [SU].SU_ID
	AND 
		[rERS].SU_ERS_Reliability = 1
	ORDER BY
        [rERS].SU_ERS_ChangedAt DESC,
        [rERS].SU_ERS_PositedAt DESC
) [ERS];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_Subject viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_Subject]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [SU].*
FROM
    [dbo].[tSU_Subject] (
        DEFAULT,
        DEFAULT
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
    cast(null as decimal(5,2)) as Reliability,
    [SU].*
FROM
    [dbo].[tSU_Subject] (
        @changingTimepoint,
        DEFAULT
    ) [SU];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_Subject viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_Subject]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [SU].*
FROM
    [dbo].[tSU_Subject] (
        sysdatetime(),
        DEFAULT
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
FROM (
    SELECT DISTINCT
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
CROSS APPLY
    [dbo].[tSU_Subject] (
        timepoints.inspectedTimepoint,
        DEFAULT
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
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [OB].OB_ID,
    [OB].Metadata_OB,
    [NAM].OB_NAM_OB_ID,
    [NAM].Metadata_OB_NAM,
    [NAM].OB_NAM_ID,
    [NAM].OB_NAM_PositedAt,
    [NAM].OB_NAM_Reliability,
    [NAM].OB_NAM_Object_Name
FROM
    [dbo].[OB_Object] [OB]
OUTER APPLY (
    SELECT TOP 1
        [rNAM].OB_NAM_OB_ID,
        [rNAM].Metadata_OB_NAM,
        [rNAM].OB_NAM_ID,
        [rNAM].OB_NAM_PositedAt,
        [rNAM].OB_NAM_Reliability,
        [rNAM].OB_NAM_Object_Name
    FROM
        [dbo].[rOB_NAM_Object_Name](
            @positingTimepoint
        ) [rNAM]
    WHERE
		[rNAM].OB_NAM_OB_ID = [OB].OB_ID
	AND 
		[rNAM].OB_NAM_Reliability = 1
	ORDER BY
        [rNAM].OB_NAM_PositedAt DESC
) [NAM];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOB_Object viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lOB_Object]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [OB].*
FROM
    [dbo].[tOB_Object] (
        DEFAULT,
        DEFAULT
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
    cast(null as decimal(5,2)) as Reliability,
    [OB].*
FROM
    [dbo].[tOB_Object] (
        @changingTimepoint,
        DEFAULT
    ) [OB];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOB_Object viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nOB_Object]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [OB].*
FROM
    [dbo].[tOB_Object] (
        sysdatetime(),
        DEFAULT
    ) [OB];
GO
