-- Materialized Natural Key Table -------------------------------------------------
-- 2nd key table for lookups of identities in ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.ST_Stage_2nd', 'U') IS NOT NULL
DROP TABLE [anchors].[ST_Stage_2nd];
GO
CREATE TABLE [anchors].[ST_Stage_2nd](
    ST_ID int NOT NULL,
    ST_NAM_Stage_Name varbinary(max) NOT NULL,
    ST_ChangedAt datetime2 NOT NULL,
    Metadata_ST int NOT NULL,
    CONSTRAINT pkST_Stage_2nd PRIMARY KEY CLUSTERED (
        ST_ID,
        ST_ChangedAt
    ),
    CONSTRAINT uqST_Stage_2nd UNIQUE (
        ST_NAM_Stage_Name,
        ST_ChangedAt
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key view for lookups of identities in ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.key_ST_Stage_2nd', 'V') IS NOT NULL
DROP VIEW [anchors].[key_ST_Stage_2nd];
GO
CREATE VIEW [anchors].[key_ST_Stage_2nd] WITH SCHEMABINDING AS
SELECT
    twine.ST_NAM_Stage_Name,
    twine.[ChangedAt],
    [ST].ST_ID
FROM
    [anchors].[ST_Stage] [ST]
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
            ) AS varbinary(max)
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
                [attributes].[ST_NAM_Stage_Name] 
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
IF Object_ID('anchors.ST_Stage_1st', 'U') IS NOT NULL
DROP TABLE [anchors].[ST_Stage_1st];
GO
CREATE TABLE [anchors].[ST_Stage_1st](
    ST_ID int NOT NULL,
    ST_LOC_Stage_Location geography NOT NULL,
    Metadata_ST int NOT NULL,
    CONSTRAINT pkST_Stage_1st PRIMARY KEY CLUSTERED (
        ST_ID
    ),
    CONSTRAINT uqST_Stage_1st UNIQUE (
        ST_LOC_Stage_Location
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.key_ST_Stage_1st', 'V') IS NOT NULL
DROP VIEW [anchors].[key_ST_Stage_1st];
GO
CREATE VIEW [anchors].[key_ST_Stage_1st] WITH SCHEMABINDING AS
SELECT
    twine.ST_LOC_Stage_Location,
    [ST].ST_ID
FROM
    [anchors].[ST_Stage] [ST]
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
                [attributes].[ST_LOC_Stage_Location] 
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
IF Object_ID('anchors.AC_Actor_1st', 'U') IS NOT NULL
DROP TABLE [anchors].[AC_Actor_1st];
GO
CREATE TABLE [anchors].[AC_Actor_1st](
    AC_ID smallint NOT NULL,
    AC_NAM_Actor_Name varbinary(max) NOT NULL,
    AC_ChangedAt datetime2 NOT NULL,
    Metadata_AC int NOT NULL,
    CONSTRAINT pkAC_Actor_1st PRIMARY KEY CLUSTERED (
        AC_ID,
        AC_ChangedAt
    ),
    CONSTRAINT uqAC_Actor_1st UNIQUE (
        AC_NAM_Actor_Name,
        AC_ChangedAt
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.key_AC_Actor_1st', 'V') IS NOT NULL
DROP VIEW [anchors].[key_AC_Actor_1st];
GO
CREATE VIEW [anchors].[key_AC_Actor_1st] WITH SCHEMABINDING AS
SELECT
    twine.AC_NAM_Actor_Name,
    twine.[ChangedAt],
    [AC].AC_ID
FROM
    [anchors].[AC_Actor] [AC]
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
            ) AS varbinary(max)
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
                [attributes].[AC_NAM_Actor_Name] 
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
IF Object_ID('anchors.PR_Program_1st', 'U') IS NOT NULL
DROP TABLE [anchors].[PR_Program_1st];
GO
CREATE TABLE [anchors].[PR_Program_1st](
    PR_ID bigint NOT NULL,
    PR_NAM_Program_Name nvarchar(42) NOT NULL,
    Metadata_PR int NOT NULL,
    CONSTRAINT pkPR_Program_1st PRIMARY KEY CLUSTERED (
        PR_ID
    ),
    CONSTRAINT uqPR_Program_1st UNIQUE (
        PR_NAM_Program_Name
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.key_PR_Program_1st', 'V') IS NOT NULL
DROP VIEW [anchors].[key_PR_Program_1st];
GO
CREATE VIEW [anchors].[key_PR_Program_1st] WITH SCHEMABINDING AS
SELECT
    twine.PR_NAM_Program_Name,
    [PR].PR_ID
FROM
    [anchors].[PR_Program] [PR]
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
                [attributes].[PR_NAM_Program_Name] 
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
IF Object_ID('nexuses.EV_Event_1st', 'U') IS NOT NULL
DROP TABLE [nexuses].[EV_Event_1st];
GO
CREATE TABLE [nexuses].[EV_Event_1st](
    EV_ID NOT NULL,
    ST_LOC_Stage_Location geography NULL,
    PR_NAM_Program_Name nvarchar(42) NULL,
    Metadata_EV int NOT NULL,
    CONSTRAINT pkEV_Event_1st PRIMARY KEY CLUSTERED (
        EV_ID
    ),
    CONSTRAINT uqEV_Event_1st UNIQUE (
        PR_NAM_Program_Name,
        ST_LOC_Stage_Location
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('nexuses.key_EV_Event_1st', 'V') IS NOT NULL
DROP VIEW [nexuses].[key_EV_Event_1st];
GO
CREATE VIEW [nexuses].[key_EV_Event_1st] WITH SCHEMABINDING AS
SELECT
    twine.ST_LOC_Stage_Location,
    twine.PR_NAM_Program_Name,
    [EV].EV_ID
FROM
    [nexuses].[EV_Event] [EV]
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
                [attributes].[ST_LOC_Stage_Location] 
            UNION ALL
            SELECT
                PR_NAM_PR_ID AS EV_ID, 
                CAST(PR_NAM_Program_Name AS VARBINARY(max)) AS [Value],
                'PR_NAM_Program_Name' AS [QualifiedType],
                CAST(NULL AS datetime2) AS [ChangedAt]
            FROM
                [attributes].[PR_NAM_Program_Name] 
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
