-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssEV_STA_Event_Status procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ssEV_STA_Event_Status', 'P') IS NOT NULL
DROP PROCEDURE [attributes].[ssEV_STA_Event_Status];
GO
CREATE PROCEDURE [attributes].[ssEV_STA_Event_Status] (
    @EV_ID numeric(12,0) = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), EV_STA_ChangedAt, 126) + ']' AS [text()]
        FROM
            [attributes].[EV_STA_Event_Status]
        WHERE
            EV_ID = ISNULL(@EV_ID, EV_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        EV_STA_Positor
    FROM
        [attributes].[EV_STA_Event_Status]
    WHERE
        EV_ID = ISNULL(@EV_ID, EV_ID)
    AND
        EV_STA_Event_Status is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.EV_STA_Positor,
                x.EV_ID,
                x.EV_STA_PositedAt,
                b.EV_STA_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    EV_ID,
                    EV_STA_PositedAt
                FROM
                    [attributes].[EV_STA_Event_Status]
                WHERE
                    EV_ID = ISNULL(@EV_ID, EV_ID)
            ) x
            LEFT JOIN (
                SELECT
                    EV_STA_Positor,
                    EV_ID,
                    EV_STA_PositedAt,
                    EV_STA_Assertion,
                    ' + @pivot + '
                FROM
                    [attributes].[EV_STA_Event_Status]
                PIVOT (
                    MIN(EV_STA_Event_Status) FOR EV_STA_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    EV_ID = ISNULL(@EV_ID, EV_ID)
                AND
                    EV_STA_Positor = ' + @positor + '
            ) b
            ON
                b.EV_ID = x.EV_ID
            AND
                b.EV_STA_PositedAt = x.EV_STA_PositedAt
            ORDER BY
                EV_ID,
                EV_STA_PositedAt,
                EV_STA_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@EV_ID numeric(12,0)', @EV_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssEV_LVL_Event_Level procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ssEV_LVL_Event_Level', 'P') IS NOT NULL
DROP PROCEDURE [attributes].[ssEV_LVL_Event_Level];
GO
CREATE PROCEDURE [attributes].[ssEV_LVL_Event_Level] (
    @EV_ID numeric(12,0) = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), EV_LVL_ChangedAt, 126) + ']' AS [text()]
        FROM
            [attributes].[EV_LVL_Event_Level]
        WHERE
            EV_ID = ISNULL(@EV_ID, EV_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        EV_LVL_Positor
    FROM
        [attributes].[EV_LVL_Event_Level]
    WHERE
        EV_ID = ISNULL(@EV_ID, EV_ID)
    AND
        PLV_ID is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.EV_LVL_Positor,
                x.EV_ID,
                x.EV_LVL_PositedAt,
                b.EV_LVL_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    EV_ID,
                    EV_LVL_PositedAt
                FROM
                    [attributes].[EV_LVL_Event_Level]
                WHERE
                    EV_ID = ISNULL(@EV_ID, EV_ID)
            ) x
            LEFT JOIN (
                SELECT
                    EV_LVL_Positor,
                    EV_ID,
                    EV_LVL_PositedAt,
                    EV_LVL_Assertion,
                    ' + @pivot + '
                FROM
                    [attributes].[EV_LVL_Event_Level]
                PIVOT (
                    MIN(PLV_ID) FOR EV_LVL_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    EV_ID = ISNULL(@EV_ID, EV_ID)
                AND
                    EV_LVL_Positor = ' + @positor + '
            ) b
            ON
                b.EV_ID = x.EV_ID
            AND
                b.EV_LVL_PositedAt = x.EV_LVL_PositedAt
            ORDER BY
                EV_ID,
                EV_LVL_PositedAt,
                EV_LVL_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@EV_ID numeric(12,0)', @EV_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssST_NAM_Stage_Name procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ssST_NAM_Stage_Name', 'P') IS NOT NULL
DROP PROCEDURE [attributes].[ssST_NAM_Stage_Name];
GO
CREATE PROCEDURE [attributes].[ssST_NAM_Stage_Name] (
    @ST_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), ST_NAM_ChangedAt, 126) + ']' AS [text()]
        FROM
            [attributes].[ST_NAM_Stage_Name]
        WHERE
            ST_ID = ISNULL(@ST_ID, ST_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        ST_NAM_Positor
    FROM
        [attributes].[ST_NAM_Stage_Name]
    WHERE
        ST_ID = ISNULL(@ST_ID, ST_ID)
    AND
        ST_NAM_Stage_Name is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.ST_NAM_Positor,
                x.ST_ID,
                x.ST_NAM_PositedAt,
                b.ST_NAM_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    ST_ID,
                    ST_NAM_PositedAt
                FROM
                    [attributes].[ST_NAM_Stage_Name]
                WHERE
                    ST_ID = ISNULL(@ST_ID, ST_ID)
            ) x
            LEFT JOIN (
                SELECT
                    ST_NAM_Positor,
                    ST_ID,
                    ST_NAM_PositedAt,
                    ST_NAM_Assertion,
                    ' + @pivot + '
                FROM
                    [attributes].[ST_NAM_Stage_Name]
                PIVOT (
                    MIN(ST_NAM_Stage_Name) FOR ST_NAM_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    ST_ID = ISNULL(@ST_ID, ST_ID)
                AND
                    ST_NAM_Positor = ' + @positor + '
            ) b
            ON
                b.ST_ID = x.ST_ID
            AND
                b.ST_NAM_PositedAt = x.ST_NAM_PositedAt
            ORDER BY
                ST_ID,
                ST_NAM_PositedAt,
                ST_NAM_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@ST_ID int', @ST_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssST_AVG_Stage_Average procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ssST_AVG_Stage_Average', 'P') IS NOT NULL
DROP PROCEDURE [attributes].[ssST_AVG_Stage_Average];
GO
CREATE PROCEDURE [attributes].[ssST_AVG_Stage_Average] (
    @ST_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), ST_AVG_ChangedAt, 126) + ']' AS [text()]
        FROM
            [attributes].[ST_AVG_Stage_Average]
        WHERE
            ST_ID = ISNULL(@ST_ID, ST_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        ST_AVG_Positor
    FROM
        [attributes].[ST_AVG_Stage_Average]
    WHERE
        ST_ID = ISNULL(@ST_ID, ST_ID)
    AND
        UTL_ID is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.ST_AVG_Positor,
                x.ST_ID,
                x.ST_AVG_PositedAt,
                b.ST_AVG_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    ST_ID,
                    ST_AVG_PositedAt
                FROM
                    [attributes].[ST_AVG_Stage_Average]
                WHERE
                    ST_ID = ISNULL(@ST_ID, ST_ID)
            ) x
            LEFT JOIN (
                SELECT
                    ST_AVG_Positor,
                    ST_ID,
                    ST_AVG_PositedAt,
                    ST_AVG_Assertion,
                    ' + @pivot + '
                FROM
                    [attributes].[ST_AVG_Stage_Average]
                PIVOT (
                    MIN(UTL_ID) FOR ST_AVG_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    ST_ID = ISNULL(@ST_ID, ST_ID)
                AND
                    ST_AVG_Positor = ' + @positor + '
            ) b
            ON
                b.ST_ID = x.ST_ID
            AND
                b.ST_AVG_PositedAt = x.ST_AVG_PositedAt
            ORDER BY
                ST_ID,
                ST_AVG_PositedAt,
                ST_AVG_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@ST_ID int', @ST_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssAC_NAM_Actor_Name procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ssAC_NAM_Actor_Name', 'P') IS NOT NULL
DROP PROCEDURE [attributes].[ssAC_NAM_Actor_Name];
GO
CREATE PROCEDURE [attributes].[ssAC_NAM_Actor_Name] (
    @AC_ID smallint = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), AC_NAM_ChangedAt, 126) + ']' AS [text()]
        FROM
            [attributes].[AC_NAM_Actor_Name]
        WHERE
            AC_ID = ISNULL(@AC_ID, AC_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        AC_NAM_Positor
    FROM
        [attributes].[AC_NAM_Actor_Name]
    WHERE
        AC_ID = ISNULL(@AC_ID, AC_ID)
    AND
        AC_NAM_Actor_Name is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.AC_NAM_Positor,
                x.AC_ID,
                x.AC_NAM_PositedAt,
                b.AC_NAM_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    AC_ID,
                    AC_NAM_PositedAt
                FROM
                    [attributes].[AC_NAM_Actor_Name]
                WHERE
                    AC_ID = ISNULL(@AC_ID, AC_ID)
            ) x
            LEFT JOIN (
                SELECT
                    AC_NAM_Positor,
                    AC_ID,
                    AC_NAM_PositedAt,
                    AC_NAM_Assertion,
                    ' + @pivot + '
                FROM
                    [attributes].[AC_NAM_Actor_Name]
                PIVOT (
                    MIN(AC_NAM_Actor_Name) FOR AC_NAM_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    AC_ID = ISNULL(@AC_ID, AC_ID)
                AND
                    AC_NAM_Positor = ' + @positor + '
            ) b
            ON
                b.AC_ID = x.AC_ID
            AND
                b.AC_NAM_PositedAt = x.AC_NAM_PositedAt
            ORDER BY
                AC_ID,
                AC_NAM_PositedAt,
                AC_NAM_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@AC_ID smallint', @AC_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssAC_PLV_Actor_ProfessionalLevel procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ssAC_PLV_Actor_ProfessionalLevel', 'P') IS NOT NULL
DROP PROCEDURE [attributes].[ssAC_PLV_Actor_ProfessionalLevel];
GO
CREATE PROCEDURE [attributes].[ssAC_PLV_Actor_ProfessionalLevel] (
    @AC_ID smallint = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), AC_PLV_ChangedAt, 126) + ']' AS [text()]
        FROM
            [attributes].[AC_PLV_Actor_ProfessionalLevel]
        WHERE
            AC_ID = ISNULL(@AC_ID, AC_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        AC_PLV_Positor
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        AC_ID = ISNULL(@AC_ID, AC_ID)
    AND
        PLV_ID is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.AC_PLV_Positor,
                x.AC_ID,
                x.AC_PLV_PositedAt,
                b.AC_PLV_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    AC_ID,
                    AC_PLV_PositedAt
                FROM
                    [attributes].[AC_PLV_Actor_ProfessionalLevel]
                WHERE
                    AC_ID = ISNULL(@AC_ID, AC_ID)
            ) x
            LEFT JOIN (
                SELECT
                    AC_PLV_Positor,
                    AC_ID,
                    AC_PLV_PositedAt,
                    AC_PLV_Assertion,
                    ' + @pivot + '
                FROM
                    [attributes].[AC_PLV_Actor_ProfessionalLevel]
                PIVOT (
                    MIN(PLV_ID) FOR AC_PLV_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    AC_ID = ISNULL(@AC_ID, AC_ID)
                AND
                    AC_PLV_Positor = ' + @positor + '
            ) b
            ON
                b.AC_ID = x.AC_ID
            AND
                b.AC_PLV_PositedAt = x.AC_PLV_PositedAt
            ORDER BY
                AC_ID,
                AC_PLV_PositedAt,
                AC_PLV_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@AC_ID smallint', @AC_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssPR_LEN_Program_Length procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ssPR_LEN_Program_Length', 'P') IS NOT NULL
DROP PROCEDURE [attributes].[ssPR_LEN_Program_Length];
GO
CREATE PROCEDURE [attributes].[ssPR_LEN_Program_Length] (
    @PR_ID bigint = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), PR_LEN_ChangedAt, 126) + ']' AS [text()]
        FROM
            [attributes].[PR_LEN_Program_Length]
        WHERE
            PR_ID = ISNULL(@PR_ID, PR_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        PR_LEN_Positor
    FROM
        [attributes].[PR_LEN_Program_Length]
    WHERE
        PR_ID = ISNULL(@PR_ID, PR_ID)
    AND
        PR_LEN_Program_Length is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.PR_LEN_Positor,
                x.PR_ID,
                x.PR_LEN_PositedAt,
                b.PR_LEN_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    PR_ID,
                    PR_LEN_PositedAt
                FROM
                    [attributes].[PR_LEN_Program_Length]
                WHERE
                    PR_ID = ISNULL(@PR_ID, PR_ID)
            ) x
            LEFT JOIN (
                SELECT
                    PR_LEN_Positor,
                    PR_ID,
                    PR_LEN_PositedAt,
                    PR_LEN_Assertion,
                    ' + @pivot + '
                FROM
                    [attributes].[PR_LEN_Program_Length]
                PIVOT (
                    MIN(PR_LEN_Program_Length) FOR PR_LEN_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    PR_ID = ISNULL(@PR_ID, PR_ID)
                AND
                    PR_LEN_Positor = ' + @positor + '
            ) b
            ON
                b.PR_ID = x.PR_ID
            AND
                b.PR_LEN_PositedAt = x.PR_LEN_PositedAt
            ORDER BY
                PR_ID,
                PR_LEN_PositedAt,
                PR_LEN_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@PR_ID bigint', @PR_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
