-- Materialized Natural Key Table -------------------------------------------------
-- 2nd key table for lookups of identities in ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage_2nd', 'U') IS NOT NULL
DROP TABLE [dbo].[ST_Stage_2nd];
GO
CREATE TABLE [dbo].[ST_Stage_2nd](
    ST_ID int NOT NULL,
    ST_NAM_Stage_Name nvarchar(42) NOT NULL,
    ST_NAM_Checksum as cast(dbo.MD5(cast(ST_NAM_Stage_Name as varbinary(max))) as varbinary(16)) persisted,
    ST_ChangedAt datetime2 NOT NULL,
    STschema.metadata.equivalentSuffix tinyint NOT NULL,
    Metadata_ST int NOT NULL,
    CONSTRAINT pkST_Stage_2nd PRIMARY KEY CLUSTERED (
        STschema.metadata.equivalentSuffix,
        ST_ID,
        ST_ChangedAt
    ),
    CONSTRAINT uqST_Stage_2nd UNIQUE (
        STschema.metadata.equivalentSuffix,
        ST_NAM_Checksum,
        ST_ChangedAt
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key view for lookups of identities in ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_ST_Stage_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[key_ST_Stage_2nd];
GO
CREATE VIEW [dbo].[key_ST_Stage_2nd] WITH SCHEMABINDING AS
SELECT
    twine.ST_NAM_Stage_Name,
    twine.[ChangedAt],
    [ST].ST_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN (
    SELECT TOP 1 WITH TIES
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'ST_NAM_Stage_Name'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    ST_ID, 
                    ST_NAM_Stage_Name_ChangedAt
            ) AS nvarchar(42)
        ) AS ST_NAM_Stage_Name,
        ST_ID,
        [ChangedAt]
    FROM (
        SELECT
            MAX(CASE
                WHEN [QualifiedType] = 'ST_NAM_Stage_Name' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY ST_ID 
                ORDER BY [ChangedAt]
            ) AS ST_NAM_Stage_Name_ChangedAt,
            ST_ID,
            [Value],
            [QualifiedType],
            [ChangedAt]
        FROM (
            SELECT
                ST_NAM_ST_ID AS ST_ID, 
                CAST(ST_NAM_Stage_Name AS VARBINARY(max)) AS [Value],
                'ST_NAM_Stage_Name' AS [QualifiedType],
                CAST(ST_NAM_ChangedAt AS datetime2) AS [ChangedAt]
            FROM
                [dbo].[ST_NAM_Stage_Name] 
        ) unified_timelines
    ) resolved_changes
    ORDER BY 
        ROW_NUMBER() OVER (
            PARTITION BY 
                ST_ID, 
                [ChangedAt] 
            ORDER BY
                (select 1)
        )
) twine
ON
    twine.ST_ID = [ST].ST_ID;
GO
-- Materialized Natural Key Table -------------------------------------------------
-- 1st key table for lookups of identities in ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[ST_Stage_1st];
GO
CREATE TABLE [dbo].[ST_Stage_1st](
    ST_ID int NOT NULL,
    ST_LOC_Stage_Location geography NOT NULL,
    ST_LOC_Checksum as cast(dbo.MD5(cast(ST_LOC_Stage_Location as varbinary(max))) as varbinary(16)) persisted,
    STschema.metadata.equivalentSuffix tinyint NOT NULL,
    Metadata_ST int NOT NULL,
    CONSTRAINT pkST_Stage_1st PRIMARY KEY CLUSTERED (
        STschema.metadata.equivalentSuffix,
        ST_ID
    ),
    CONSTRAINT uqST_Stage_1st UNIQUE (
        STschema.metadata.equivalentSuffix,
        ST_LOC_Checksum
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_ST_Stage_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_ST_Stage_1st];
GO
CREATE VIEW [dbo].[key_ST_Stage_1st] WITH SCHEMABINDING AS
SELECT
    twine.ST_LOC_Stage_Location,
    [ST].ST_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN (
    SELECT TOP 1 WITH TIES
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'ST_LOC_Stage_Location'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    ST_ID, 
                    ST_LOC_Stage_Location_ChangedAt
            ) AS geography
        ) AS ST_LOC_Stage_Location,
        ST_ID,
        [ChangedAt]
    FROM (
        SELECT
            MAX(CASE
                WHEN [QualifiedType] = 'ST_LOC_Stage_Location' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY ST_ID 
                ORDER BY [ChangedAt]
            ) AS ST_LOC_Stage_Location_ChangedAt,
            ST_ID,
            [Value],
            [QualifiedType],
            [ChangedAt]
        FROM (
            SELECT
                ST_LOC_ST_ID AS ST_ID, 
                CAST(ST_LOC_Stage_Location AS VARBINARY(max)) AS [Value],
                'ST_LOC_Stage_Location' AS [QualifiedType],
                CAST(NULL AS datetime2) AS [ChangedAt]
            FROM
                [dbo].[ST_LOC_Stage_Location] 
        ) unified_timelines
    ) resolved_changes
    ORDER BY 
        ROW_NUMBER() OVER (
            PARTITION BY 
                ST_ID, 
                [ChangedAt] 
            ORDER BY
                (select 1)
        )
) twine
ON
    twine.ST_ID = [ST].ST_ID;
GO
-- Materialized Natural Key Table -------------------------------------------------
-- 1st key table for lookups of identities in AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_Actor_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[AC_Actor_1st];
GO
CREATE TABLE [dbo].[AC_Actor_1st](
    AC_ID int NOT NULL,
    AC_NAM_Actor_Name nvarchar(42) NOT NULL,
    AC_NAM_Checksum as cast(dbo.MD5(cast(AC_NAM_Actor_Name as varbinary(max))) as varbinary(16)) persisted,
    AC_ChangedAt datetime2 NOT NULL,
    ACschema.metadata.equivalentSuffix tinyint NOT NULL,
    Metadata_AC int NOT NULL,
    CONSTRAINT pkAC_Actor_1st PRIMARY KEY CLUSTERED (
        ACschema.metadata.equivalentSuffix,
        AC_ID,
        AC_ChangedAt
    ),
    CONSTRAINT uqAC_Actor_1st UNIQUE (
        ACschema.metadata.equivalentSuffix,
        AC_NAM_Checksum,
        AC_ChangedAt
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_AC_Actor_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_AC_Actor_1st];
GO
CREATE VIEW [dbo].[key_AC_Actor_1st] WITH SCHEMABINDING AS
SELECT
    twine.AC_NAM_Actor_Name,
    twine.[ChangedAt],
    [AC].AC_ID
FROM
    [dbo].[AC_Actor] [AC]
LEFT JOIN (
    SELECT TOP 1 WITH TIES
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'AC_NAM_Actor_Name'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    AC_ID, 
                    AC_NAM_Actor_Name_ChangedAt
            ) AS nvarchar(42)
        ) AS AC_NAM_Actor_Name,
        AC_ID,
        [ChangedAt]
    FROM (
        SELECT
            MAX(CASE
                WHEN [QualifiedType] = 'AC_NAM_Actor_Name' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY AC_ID 
                ORDER BY [ChangedAt]
            ) AS AC_NAM_Actor_Name_ChangedAt,
            AC_ID,
            [Value],
            [QualifiedType],
            [ChangedAt]
        FROM (
            SELECT
                AC_NAM_AC_ID AS AC_ID, 
                CAST(AC_NAM_Actor_Name AS VARBINARY(max)) AS [Value],
                'AC_NAM_Actor_Name' AS [QualifiedType],
                CAST(AC_NAM_ChangedAt AS datetime2) AS [ChangedAt]
            FROM
                [dbo].[AC_NAM_Actor_Name] 
        ) unified_timelines
    ) resolved_changes
    ORDER BY 
        ROW_NUMBER() OVER (
            PARTITION BY 
                AC_ID, 
                [ChangedAt] 
            ORDER BY
                (select 1)
        )
) twine
ON
    twine.AC_ID = [AC].AC_ID;
GO
-- Materialized Natural Key Table -------------------------------------------------
-- 1st key table for lookups of identities in PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_Program_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[PR_Program_1st];
GO
CREATE TABLE [dbo].[PR_Program_1st](
    PR_ID int NOT NULL,
    PR_NAM_Program_Name nvarchar(42) NOT NULL,
    PRschema.metadata.equivalentSuffix tinyint NOT NULL,
    Metadata_PR int NOT NULL,
    CONSTRAINT pkPR_Program_1st PRIMARY KEY CLUSTERED (
        PRschema.metadata.equivalentSuffix,
        PR_ID
    ),
    CONSTRAINT uqPR_Program_1st UNIQUE (
        PRschema.metadata.equivalentSuffix,
        PR_NAM_Program_Name
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_PR_Program_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_PR_Program_1st];
GO
CREATE VIEW [dbo].[key_PR_Program_1st] WITH SCHEMABINDING AS
SELECT
    twine.PR_NAM_Program_Name,
    [PR].PR_ID
FROM
    [dbo].[PR_Program] [PR]
LEFT JOIN (
    SELECT TOP 1 WITH TIES
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'PR_NAM_Program_Name'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    PR_ID, 
                    PR_NAM_Program_Name_ChangedAt
            ) AS nvarchar(42)
        ) AS PR_NAM_Program_Name,
        PR_ID,
        [ChangedAt]
    FROM (
        SELECT
            MAX(CASE
                WHEN [QualifiedType] = 'PR_NAM_Program_Name' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY PR_ID 
                ORDER BY [ChangedAt]
            ) AS PR_NAM_Program_Name_ChangedAt,
            PR_ID,
            [Value],
            [QualifiedType],
            [ChangedAt]
        FROM (
            SELECT
                PR_NAM_PR_ID AS PR_ID, 
                CAST(PR_NAM_Program_Name AS VARBINARY(max)) AS [Value],
                'PR_NAM_Program_Name' AS [QualifiedType],
                CAST(NULL AS datetime2) AS [ChangedAt]
            FROM
                [dbo].[PR_NAM_Program_Name] 
        ) unified_timelines
    ) resolved_changes
    ORDER BY 
        ROW_NUMBER() OVER (
            PARTITION BY 
                PR_ID, 
                [ChangedAt] 
            ORDER BY
                (select 1)
        )
) twine
ON
    twine.PR_ID = [PR].PR_ID;
GO
-- Materialized Natural Key Table -------------------------------------------------
-- 1st key table for lookups of identities in EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_Event_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[EV_Event_1st];
GO
CREATE TABLE [dbo].[EV_Event_1st](
    EV_ID int NOT NULL,
    ST_LOC_Stage_Location geography NULL,
    ST_LOC_Checksum as cast(dbo.MD5(cast(ST_LOC_Stage_Location as varbinary(max))) as varbinary(16)) persisted,
    PR_NAM_Program_Name nvarchar(42) NULL,
    EVschema.metadata.equivalentSuffix tinyint NOT NULL,
    Metadata_EV int NOT NULL,
    CONSTRAINT pkEV_Event_1st PRIMARY KEY CLUSTERED (
        EV_ID
    ),
    CONSTRAINT uqEV_Event_1st UNIQUE (
        EVschema.metadata.equivalentSuffix,
        ST_LOC_Checksum,
        PR_NAM_Program_Name
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_EV_Event_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_EV_Event_1st];
GO
CREATE VIEW [dbo].[key_EV_Event_1st] WITH SCHEMABINDING AS
SELECT
    twine.ST_LOC_Stage_Location,
    twine.PR_NAM_Program_Name,
    [EV].EV_ID
FROM
    [dbo].[EV_Event] [EV]
LEFT JOIN (
    SELECT TOP 1 WITH TIES
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'ST_LOC_Stage_Location'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    EV_ID, 
                    ST_LOC_Stage_Location_ChangedAt
            ) AS geography
        ) AS ST_LOC_Stage_Location,
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'PR_NAM_Program_Name'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    EV_ID, 
                    PR_NAM_Program_Name_ChangedAt
            ) AS nvarchar(42)
        ) AS PR_NAM_Program_Name,
        EV_ID,
        [ChangedAt]
    FROM (
        SELECT
            MAX(CASE
                WHEN [QualifiedType] = 'ST_LOC_Stage_Location' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY EV_ID 
                ORDER BY [ChangedAt]
            ) AS ST_LOC_Stage_Location_ChangedAt,
            MAX(CASE
                WHEN [QualifiedType] = 'PR_NAM_Program_Name' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY EV_ID 
                ORDER BY [ChangedAt]
            ) AS PR_NAM_Program_Name_ChangedAt,
            EV_ID,
            [Value],
            [QualifiedType],
            [ChangedAt]
        FROM (
            SELECT
                ST_LOC_ST_ID AS EV_ID, 
                CAST(ST_LOC_Stage_Location AS VARBINARY(max)) AS [Value],
                'ST_LOC_Stage_Location' AS [QualifiedType],
                CAST(NULL AS datetime2) AS [ChangedAt]
            FROM
                [dbo].[ST_LOC_Stage_Location] 
            UNION ALL
            SELECT
                PR_NAM_PR_ID AS EV_ID, 
                CAST(PR_NAM_Program_Name AS VARBINARY(max)) AS [Value],
                'PR_NAM_Program_Name' AS [QualifiedType],
                CAST(NULL AS datetime2) AS [ChangedAt]
            FROM
                [dbo].[PR_NAM_Program_Name] 
        ) unified_timelines
    ) resolved_changes
    ORDER BY 
        ROW_NUMBER() OVER (
            PARTITION BY 
                EV_ID, 
                [ChangedAt] 
            ORDER BY
                (select 1)
        )
) twine
ON
    twine.EV_ID = [EV].EV_ID;
GO
