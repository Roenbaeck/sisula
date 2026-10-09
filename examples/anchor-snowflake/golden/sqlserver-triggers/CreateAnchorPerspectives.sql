-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are four types of perspectives: latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The latest perspective shows the latest available information for each anchor.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
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
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_Subject viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_Subject] WITH SCHEMABINDING AS
SELECT
    [SU].SU_ID,
    [SU].Metadata_SU,
    [NAM].SU_NAM_SU_ID,
    [NAM].Metadata_SU_NAM,
    [NAM].SU_NAM_Subject_Name,
    [COD].SU_COD_SU_ID,
    [COD].Metadata_SU_COD,
    [COD].SU_COD_Subject_Code,
    [GRD].SU_GRD_SU_ID,
    [GRD].Metadata_SU_GRD,
    [kGRD].GRD_Grade AS SU_GRD_GRD_Grade,
    [kGRD].Metadata_GRD AS SU_GRD_Metadata_GRD,
    [GRD].SU_GRD_GRD_ID,
    [NOT].SU_NOT_SU_ID,
    [NOT].Metadata_SU_NOT,
    [NOT].SU_NOT_Checksum,
    [NOT].SU_NOT_Subject_Note,
    [TTL].SU_TTL_SU_ID,
    [TTL].Metadata_SU_TTL,
    [TTL].SU_TTL_ChangedAt,
    [TTL].SU_TTL_Subject_Title,
    [STA].SU_STA_SU_ID,
    [STA].Metadata_SU_STA,
    [STA].SU_STA_ChangedAt,
    [STA].SU_STA_Subject_State,
    [LBL].SU_LBL_SU_ID,
    [LBL].Metadata_SU_LBL,
    [LBL].SU_LBL_ChangedAt,
    [LBL].SU_LBL_Subject_Label,
    [TAG].SU_TAG_SU_ID,
    [TAG].Metadata_SU_TAG,
    [TAG].SU_TAG_ChangedAt,
    [TAG].SU_TAG_Subject_Tag,
    [LVL].SU_LVL_SU_ID,
    [LVL].Metadata_SU_LVL,
    [LVL].SU_LVL_ChangedAt,
    [kLVL].GRD_Grade AS SU_LVL_GRD_Grade,
    [kLVL].Metadata_GRD AS SU_LVL_Metadata_GRD,
    [LVL].SU_LVL_GRD_ID,
    [TXT].SU_TXT_SU_ID,
    [TXT].Metadata_SU_TXT,
    [TXT].SU_TXT_ChangedAt,
    [TXT].SU_TXT_Checksum,
    [TXT].SU_TXT_Subject_Text,
    [ASR].SU_ASR_SU_ID,
    [ASR].Metadata_SU_ASR,
    [ASR].SU_ASR_ChangedAt,
    [ASR].SU_ASR_Subject_Assessment,
    [ERS].SU_ERS_SU_ID,
    [ERS].Metadata_SU_ERS,
    cast(null as bit) as Deletable_SU_ERS,
    [ERS].SU_ERS_ChangedAt,
    [ERS].SU_ERS_Subject_Erasable
FROM
    [dbo].[SU_Subject] [SU]
LEFT JOIN
    [dbo].[SU_NAM_Subject_Name] [NAM]
ON
    [NAM].SU_NAM_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[SU_COD_Subject_Code] [COD]
ON
    [COD].SU_COD_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[SU_GRD_Subject_Grade] [GRD]
ON
    [GRD].SU_GRD_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[GRD_Grade] [kGRD]
ON
    [kGRD].GRD_ID = [GRD].SU_GRD_GRD_ID
LEFT JOIN
    [dbo].[SU_NOT_Subject_Note] [NOT]
ON
    [NOT].SU_NOT_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[SU_TTL_Subject_Title] [TTL]
ON
    [TTL].SU_TTL_SU_ID = [SU].SU_ID
AND
    [TTL].SU_TTL_ChangedAt = (
        SELECT
            max(sub.SU_TTL_ChangedAt)
        FROM
            [dbo].[SU_TTL_Subject_Title] sub
        WHERE
            sub.SU_TTL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_STA_Subject_State] [STA]
ON
    [STA].SU_STA_SU_ID = [SU].SU_ID
AND
    [STA].SU_STA_ChangedAt = (
        SELECT
            max(sub.SU_STA_ChangedAt)
        FROM
            [dbo].[SU_STA_Subject_State] sub
        WHERE
            sub.SU_STA_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_LBL_Subject_Label] [LBL]
ON
    [LBL].SU_LBL_SU_ID = [SU].SU_ID
AND
    [LBL].SU_LBL_ChangedAt = (
        SELECT
            max(sub.SU_LBL_ChangedAt)
        FROM
            [dbo].[SU_LBL_Subject_Label] sub
        WHERE
            sub.SU_LBL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_TAG_Subject_Tag] [TAG]
ON
    [TAG].SU_TAG_SU_ID = [SU].SU_ID
AND
    [TAG].SU_TAG_ChangedAt = (
        SELECT
            max(sub.SU_TAG_ChangedAt)
        FROM
            [dbo].[SU_TAG_Subject_Tag] sub
        WHERE
            sub.SU_TAG_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_LVL_Subject_Level] [LVL]
ON
    [LVL].SU_LVL_SU_ID = [SU].SU_ID
AND
    [LVL].SU_LVL_ChangedAt = (
        SELECT
            max(sub.SU_LVL_ChangedAt)
        FROM
            [dbo].[SU_LVL_Subject_Level] sub
        WHERE
            sub.SU_LVL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[GRD_Grade] [kLVL]
ON
    [kLVL].GRD_ID = [LVL].SU_LVL_GRD_ID
LEFT JOIN
    [dbo].[SU_TXT_Subject_Text] [TXT]
ON
    [TXT].SU_TXT_SU_ID = [SU].SU_ID
AND
    [TXT].SU_TXT_ChangedAt = (
        SELECT
            max(sub.SU_TXT_ChangedAt)
        FROM
            [dbo].[SU_TXT_Subject_Text] sub
        WHERE
            sub.SU_TXT_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_ASR_Subject_Assessment] [ASR]
ON
    [ASR].SU_ASR_SU_ID = [SU].SU_ID
AND
    [ASR].SU_ASR_ChangedAt = (
        SELECT
            max(sub.SU_ASR_ChangedAt)
        FROM
            [dbo].[SU_ASR_Subject_Assessment] sub
        WHERE
            sub.SU_ASR_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[SU_ERS_Subject_Erasable] [ERS]
ON
    [ERS].SU_ERS_SU_ID = [SU].SU_ID
AND
    [ERS].SU_ERS_ChangedAt = (
        SELECT
            max(sub.SU_ERS_ChangedAt)
        FROM
            [dbo].[SU_ERS_Subject_Erasable] sub
        WHERE
            sub.SU_ERS_SU_ID = [SU].SU_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_Subject viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_Subject] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [SU].SU_ID,
    [SU].Metadata_SU,
    [NAM].SU_NAM_SU_ID,
    [NAM].Metadata_SU_NAM,
    [NAM].SU_NAM_Subject_Name,
    [COD].SU_COD_SU_ID,
    [COD].Metadata_SU_COD,
    [COD].SU_COD_Subject_Code,
    [GRD].SU_GRD_SU_ID,
    [GRD].Metadata_SU_GRD,
    [kGRD].GRD_Grade AS SU_GRD_GRD_Grade,
    [kGRD].Metadata_GRD AS SU_GRD_Metadata_GRD,
    [GRD].SU_GRD_GRD_ID,
    [NOT].SU_NOT_SU_ID,
    [NOT].Metadata_SU_NOT,
    [NOT].SU_NOT_Checksum,
    [NOT].SU_NOT_Subject_Note,
    [TTL].SU_TTL_SU_ID,
    [TTL].Metadata_SU_TTL,
    [TTL].SU_TTL_ChangedAt,
    [TTL].SU_TTL_Subject_Title,
    [STA].SU_STA_SU_ID,
    [STA].Metadata_SU_STA,
    [STA].SU_STA_ChangedAt,
    [STA].SU_STA_Subject_State,
    [LBL].SU_LBL_SU_ID,
    [LBL].Metadata_SU_LBL,
    [LBL].SU_LBL_ChangedAt,
    [LBL].SU_LBL_Subject_Label,
    [TAG].SU_TAG_SU_ID,
    [TAG].Metadata_SU_TAG,
    [TAG].SU_TAG_ChangedAt,
    [TAG].SU_TAG_Subject_Tag,
    [LVL].SU_LVL_SU_ID,
    [LVL].Metadata_SU_LVL,
    [LVL].SU_LVL_ChangedAt,
    [kLVL].GRD_Grade AS SU_LVL_GRD_Grade,
    [kLVL].Metadata_GRD AS SU_LVL_Metadata_GRD,
    [LVL].SU_LVL_GRD_ID,
    [TXT].SU_TXT_SU_ID,
    [TXT].Metadata_SU_TXT,
    [TXT].SU_TXT_ChangedAt,
    [TXT].SU_TXT_Checksum,
    [TXT].SU_TXT_Subject_Text,
    [ASR].SU_ASR_SU_ID,
    [ASR].Metadata_SU_ASR,
    [ASR].SU_ASR_ChangedAt,
    [ASR].SU_ASR_Subject_Assessment,
    [ERS].SU_ERS_SU_ID,
    [ERS].Metadata_SU_ERS,
    [ERS].SU_ERS_ChangedAt,
    [ERS].SU_ERS_Subject_Erasable
FROM
    [dbo].[SU_Subject] [SU]
LEFT JOIN
    [dbo].[SU_NAM_Subject_Name] [NAM]
ON
    [NAM].SU_NAM_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[SU_COD_Subject_Code] [COD]
ON
    [COD].SU_COD_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[SU_GRD_Subject_Grade] [GRD]
ON
    [GRD].SU_GRD_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[GRD_Grade] [kGRD]
ON
    [kGRD].GRD_ID = [GRD].SU_GRD_GRD_ID
LEFT JOIN
    [dbo].[SU_NOT_Subject_Note] [NOT]
ON
    [NOT].SU_NOT_SU_ID = [SU].SU_ID
LEFT JOIN
    [dbo].[rSU_TTL_Subject_Title](@changingTimepoint) [TTL]
ON
    [TTL].SU_TTL_SU_ID = [SU].SU_ID
AND
    [TTL].SU_TTL_ChangedAt = (
        SELECT
            max(sub.SU_TTL_ChangedAt)
        FROM
            [dbo].[rSU_TTL_Subject_Title](@changingTimepoint) sub
        WHERE
            sub.SU_TTL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_STA_Subject_State](@changingTimepoint) [STA]
ON
    [STA].SU_STA_SU_ID = [SU].SU_ID
AND
    [STA].SU_STA_ChangedAt = (
        SELECT
            max(sub.SU_STA_ChangedAt)
        FROM
            [dbo].[rSU_STA_Subject_State](@changingTimepoint) sub
        WHERE
            sub.SU_STA_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_LBL_Subject_Label](@changingTimepoint) [LBL]
ON
    [LBL].SU_LBL_SU_ID = [SU].SU_ID
AND
    [LBL].SU_LBL_ChangedAt = (
        SELECT
            max(sub.SU_LBL_ChangedAt)
        FROM
            [dbo].[rSU_LBL_Subject_Label](@changingTimepoint) sub
        WHERE
            sub.SU_LBL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_TAG_Subject_Tag](@changingTimepoint) [TAG]
ON
    [TAG].SU_TAG_SU_ID = [SU].SU_ID
AND
    [TAG].SU_TAG_ChangedAt = (
        SELECT
            max(sub.SU_TAG_ChangedAt)
        FROM
            [dbo].[rSU_TAG_Subject_Tag](@changingTimepoint) sub
        WHERE
            sub.SU_TAG_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_LVL_Subject_Level](@changingTimepoint) [LVL]
ON
    [LVL].SU_LVL_SU_ID = [SU].SU_ID
AND
    [LVL].SU_LVL_ChangedAt = (
        SELECT
            max(sub.SU_LVL_ChangedAt)
        FROM
            [dbo].[rSU_LVL_Subject_Level](@changingTimepoint) sub
        WHERE
            sub.SU_LVL_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[GRD_Grade] [kLVL]
ON
    [kLVL].GRD_ID = [LVL].SU_LVL_GRD_ID
LEFT JOIN
    [dbo].[rSU_TXT_Subject_Text](@changingTimepoint) [TXT]
ON
    [TXT].SU_TXT_SU_ID = [SU].SU_ID
AND
    [TXT].SU_TXT_ChangedAt = (
        SELECT
            max(sub.SU_TXT_ChangedAt)
        FROM
            [dbo].[rSU_TXT_Subject_Text](@changingTimepoint) sub
        WHERE
            sub.SU_TXT_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_ASR_Subject_Assessment](@changingTimepoint) [ASR]
ON
    [ASR].SU_ASR_SU_ID = [SU].SU_ID
AND
    [ASR].SU_ASR_ChangedAt = (
        SELECT
            max(sub.SU_ASR_ChangedAt)
        FROM
            [dbo].[rSU_ASR_Subject_Assessment](@changingTimepoint) sub
        WHERE
            sub.SU_ASR_SU_ID = [SU].SU_ID
   )
LEFT JOIN
    [dbo].[rSU_ERS_Subject_Erasable](@changingTimepoint) [ERS]
ON
    [ERS].SU_ERS_SU_ID = [SU].SU_ID
AND
    [ERS].SU_ERS_ChangedAt = (
        SELECT
            max(sub.SU_ERS_ChangedAt)
        FROM
            [dbo].[rSU_ERS_Subject_Erasable](@changingTimepoint) sub
        WHERE
            sub.SU_ERS_SU_ID = [SU].SU_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_Subject viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_Subject]
AS
SELECT
    *
FROM
    [dbo].[pSU_Subject](sysdatetime());
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
    timepoints.mnemonic,
    [pSU].*
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
    [dbo].[pSU_Subject](timepoints.inspectedTimepoint) [pSU]
WHERE
    [pSU].SU_ID = timepoints.SU_ID;
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
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOB_Object viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lOB_Object] WITH SCHEMABINDING AS
SELECT
    [OB].OB_ID,
    [OB].Metadata_OB,
    [NAM].OB_NAM_OB_ID,
    [NAM].Metadata_OB_NAM,
    [NAM].OB_NAM_Object_Name
FROM
    [dbo].[OB_Object] [OB]
LEFT JOIN
    [dbo].[OB_NAM_Object_Name] [NAM]
ON
    [NAM].OB_NAM_OB_ID = [OB].OB_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pOB_Object viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pOB_Object] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [OB].OB_ID,
    [OB].Metadata_OB,
    [NAM].OB_NAM_OB_ID,
    [NAM].Metadata_OB_NAM,
    [NAM].OB_NAM_Object_Name
FROM
    [dbo].[OB_Object] [OB]
LEFT JOIN
    [dbo].[OB_NAM_Object_Name] [NAM]
ON
    [NAM].OB_NAM_OB_ID = [OB].OB_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOB_Object viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nOB_Object]
AS
SELECT
    *
FROM
    [dbo].[pOB_Object](sysdatetime());
GO
