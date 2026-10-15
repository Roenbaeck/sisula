-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssST_NAM_Stage_Name procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssST_NAM_Stage_Name', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssST_NAM_Stage_Name];
GO
CREATE PROCEDURE [dbo].[ssST_NAM_Stage_Name] (
    @ST_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), ST_NAM_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[ST_NAM_Stage_Name]
        WHERE
            ST_NAM_ST_ID = ISNULL(@ST_ID, ST_NAM_ST_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        ST_NAM_Positor
    FROM
        [dbo].[ST_NAM_Stage_Name]
    WHERE
        ST_NAM_ST_ID = ISNULL(@ST_ID, ST_NAM_ST_ID)
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
                x.ST_NAM_ST_ID,
                x.ST_NAM_PositedAt,
                b.ST_NAM_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    ST_NAM_ST_ID,
                    ST_NAM_PositedAt
                FROM
                    [dbo].[ST_NAM_Stage_Name]
                WHERE
                    ST_NAM_ST_ID = ISNULL(@ST_ID, ST_NAM_ST_ID)
            ) x
            LEFT JOIN (
                SELECT
                    ST_NAM_Positor,
                    ST_NAM_ST_ID,
                    ST_NAM_PositedAt,
                    ST_NAM_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[ST_NAM_Stage_Name]
                PIVOT (
                    MIN(ST_NAM_Stage_Name) FOR ST_NAM_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    ST_NAM_ST_ID = ISNULL(@ST_ID, ST_NAM_ST_ID)
                AND
                    ST_NAM_Positor = ' + @positor + '
            ) b
            ON
                b.ST_NAM_ST_ID = x.ST_NAM_ST_ID
            AND
                b.ST_NAM_PositedAt = x.ST_NAM_PositedAt
            ORDER BY
                ST_NAM_ST_ID,
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
IF Object_ID('dbo.ssST_AVG_Stage_Average', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssST_AVG_Stage_Average];
GO
CREATE PROCEDURE [dbo].[ssST_AVG_Stage_Average] (
    @ST_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), ST_AVG_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[ST_AVG_Stage_Average]
        WHERE
            ST_AVG_ST_ID = ISNULL(@ST_ID, ST_AVG_ST_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        ST_AVG_Positor
    FROM
        [dbo].[ST_AVG_Stage_Average]
    WHERE
        ST_AVG_ST_ID = ISNULL(@ST_ID, ST_AVG_ST_ID)
    AND
        ST_AVG_UTL_ID is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.ST_AVG_Positor,
                x.ST_AVG_ST_ID,
                x.ST_AVG_PositedAt,
                b.ST_AVG_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    ST_AVG_ST_ID,
                    ST_AVG_PositedAt
                FROM
                    [dbo].[ST_AVG_Stage_Average]
                WHERE
                    ST_AVG_ST_ID = ISNULL(@ST_ID, ST_AVG_ST_ID)
            ) x
            LEFT JOIN (
                SELECT
                    ST_AVG_Positor,
                    ST_AVG_ST_ID,
                    ST_AVG_PositedAt,
                    ST_AVG_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[ST_AVG_Stage_Average]
                PIVOT (
                    MIN(ST_AVG_UTL_ID) FOR ST_AVG_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    ST_AVG_ST_ID = ISNULL(@ST_ID, ST_AVG_ST_ID)
                AND
                    ST_AVG_Positor = ' + @positor + '
            ) b
            ON
                b.ST_AVG_ST_ID = x.ST_AVG_ST_ID
            AND
                b.ST_AVG_PositedAt = x.ST_AVG_PositedAt
            ORDER BY
                ST_AVG_ST_ID,
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
IF Object_ID('dbo.ssAC_NAM_Actor_Name', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssAC_NAM_Actor_Name];
GO
CREATE PROCEDURE [dbo].[ssAC_NAM_Actor_Name] (
    @AC_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), AC_NAM_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[AC_NAM_Actor_Name]
        WHERE
            AC_NAM_AC_ID = ISNULL(@AC_ID, AC_NAM_AC_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        AC_NAM_Positor
    FROM
        [dbo].[AC_NAM_Actor_Name]
    WHERE
        AC_NAM_AC_ID = ISNULL(@AC_ID, AC_NAM_AC_ID)
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
                x.AC_NAM_AC_ID,
                x.AC_NAM_PositedAt,
                b.AC_NAM_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    AC_NAM_AC_ID,
                    AC_NAM_PositedAt
                FROM
                    [dbo].[AC_NAM_Actor_Name]
                WHERE
                    AC_NAM_AC_ID = ISNULL(@AC_ID, AC_NAM_AC_ID)
            ) x
            LEFT JOIN (
                SELECT
                    AC_NAM_Positor,
                    AC_NAM_AC_ID,
                    AC_NAM_PositedAt,
                    AC_NAM_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[AC_NAM_Actor_Name]
                PIVOT (
                    MIN(AC_NAM_Actor_Name) FOR AC_NAM_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    AC_NAM_AC_ID = ISNULL(@AC_ID, AC_NAM_AC_ID)
                AND
                    AC_NAM_Positor = ' + @positor + '
            ) b
            ON
                b.AC_NAM_AC_ID = x.AC_NAM_AC_ID
            AND
                b.AC_NAM_PositedAt = x.AC_NAM_PositedAt
            ORDER BY
                AC_NAM_AC_ID,
                AC_NAM_PositedAt,
                AC_NAM_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@AC_ID int', @AC_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssAC_PLV_Actor_ProfessionalLevel procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssAC_PLV_Actor_ProfessionalLevel', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssAC_PLV_Actor_ProfessionalLevel];
GO
CREATE PROCEDURE [dbo].[ssAC_PLV_Actor_ProfessionalLevel] (
    @AC_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), AC_PLV_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel]
        WHERE
            AC_PLV_AC_ID = ISNULL(@AC_ID, AC_PLV_AC_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        AC_PLV_Positor
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        AC_PLV_AC_ID = ISNULL(@AC_ID, AC_PLV_AC_ID)
    AND
        AC_PLV_PLV_ID is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.AC_PLV_Positor,
                x.AC_PLV_AC_ID,
                x.AC_PLV_PositedAt,
                b.AC_PLV_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    AC_PLV_AC_ID,
                    AC_PLV_PositedAt
                FROM
                    [dbo].[AC_PLV_Actor_ProfessionalLevel]
                WHERE
                    AC_PLV_AC_ID = ISNULL(@AC_ID, AC_PLV_AC_ID)
            ) x
            LEFT JOIN (
                SELECT
                    AC_PLV_Positor,
                    AC_PLV_AC_ID,
                    AC_PLV_PositedAt,
                    AC_PLV_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[AC_PLV_Actor_ProfessionalLevel]
                PIVOT (
                    MIN(AC_PLV_PLV_ID) FOR AC_PLV_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    AC_PLV_AC_ID = ISNULL(@AC_ID, AC_PLV_AC_ID)
                AND
                    AC_PLV_Positor = ' + @positor + '
            ) b
            ON
                b.AC_PLV_AC_ID = x.AC_PLV_AC_ID
            AND
                b.AC_PLV_PositedAt = x.AC_PLV_PositedAt
            ORDER BY
                AC_PLV_AC_ID,
                AC_PLV_PositedAt,
                AC_PLV_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@AC_ID int', @AC_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssPR_LEN_Program_Length procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssPR_LEN_Program_Length', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssPR_LEN_Program_Length];
GO
CREATE PROCEDURE [dbo].[ssPR_LEN_Program_Length] (
    @PR_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), PR_LEN_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[PR_LEN_Program_Length]
        WHERE
            PR_LEN_PR_ID = ISNULL(@PR_ID, PR_LEN_PR_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        PR_LEN_Positor
    FROM
        [dbo].[PR_LEN_Program_Length]
    WHERE
        PR_LEN_PR_ID = ISNULL(@PR_ID, PR_LEN_PR_ID)
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
                x.PR_LEN_PR_ID,
                x.PR_LEN_PositedAt,
                b.PR_LEN_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    PR_LEN_PR_ID,
                    PR_LEN_PositedAt
                FROM
                    [dbo].[PR_LEN_Program_Length]
                WHERE
                    PR_LEN_PR_ID = ISNULL(@PR_ID, PR_LEN_PR_ID)
            ) x
            LEFT JOIN (
                SELECT
                    PR_LEN_Positor,
                    PR_LEN_PR_ID,
                    PR_LEN_PositedAt,
                    PR_LEN_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[PR_LEN_Program_Length]
                PIVOT (
                    MIN(PR_LEN_Program_Length) FOR PR_LEN_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    PR_LEN_PR_ID = ISNULL(@PR_ID, PR_LEN_PR_ID)
                AND
                    PR_LEN_Positor = ' + @positor + '
            ) b
            ON
                b.PR_LEN_PR_ID = x.PR_LEN_PR_ID
            AND
                b.PR_LEN_PositedAt = x.PR_LEN_PositedAt
            ORDER BY
                PR_LEN_PR_ID,
                PR_LEN_PositedAt,
                PR_LEN_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@PR_ID int', @PR_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
