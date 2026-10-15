-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssEV_PLC_Event_Place procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssEV_PLC_Event_Place', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssEV_PLC_Event_Place];
GO
CREATE PROCEDURE [dbo].[ssEV_PLC_Event_Place] (
    @EV_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), EV_PLC_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[EV_PLC_Event_Place]
        WHERE
            EV_PLC_EV_ID = ISNULL(@EV_ID, EV_PLC_EV_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        EV_PLC_Positor
    FROM
        [dbo].[EV_PLC_Event_Place]
    WHERE
        EV_PLC_EV_ID = ISNULL(@EV_ID, EV_PLC_EV_ID)
    AND
        EV_PLC_Event_Place is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.EV_PLC_Positor,
                x.EV_PLC_EV_ID,
                x.EV_PLC_PositedAt,
                b.EV_PLC_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    EV_PLC_EV_ID,
                    EV_PLC_PositedAt
                FROM
                    [dbo].[EV_PLC_Event_Place]
                WHERE
                    EV_PLC_EV_ID = ISNULL(@EV_ID, EV_PLC_EV_ID)
            ) x
            LEFT JOIN (
                SELECT
                    EV_PLC_Positor,
                    EV_PLC_EV_ID,
                    EV_PLC_PositedAt,
                    EV_PLC_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[EV_PLC_Event_Place]
                PIVOT (
                    MIN(EV_PLC_Event_Place) FOR EV_PLC_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    EV_PLC_EV_ID = ISNULL(@EV_ID, EV_PLC_EV_ID)
                AND
                    EV_PLC_Positor = ' + @positor + '
            ) b
            ON
                b.EV_PLC_EV_ID = x.EV_PLC_EV_ID
            AND
                b.EV_PLC_PositedAt = x.EV_PLC_PositedAt
            ORDER BY
                EV_PLC_EV_ID,
                EV_PLC_PositedAt,
                EV_PLC_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@EV_ID int', @EV_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_TTL_Subject_Title procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_TTL_Subject_Title', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_TTL_Subject_Title];
GO
CREATE PROCEDURE [dbo].[ssSU_TTL_Subject_Title] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_TTL_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_TTL_Subject_Title]
        WHERE
            SU_TTL_SU_ID = ISNULL(@SU_ID, SU_TTL_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_TTL_Positor
    FROM
        [dbo].[SU_TTL_Subject_Title]
    WHERE
        SU_TTL_SU_ID = ISNULL(@SU_ID, SU_TTL_SU_ID)
    AND
        SU_TTL_Subject_Title is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_TTL_Positor,
                x.SU_TTL_SU_ID,
                x.SU_TTL_PositedAt,
                b.SU_TTL_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_TTL_SU_ID,
                    SU_TTL_PositedAt
                FROM
                    [dbo].[SU_TTL_Subject_Title]
                WHERE
                    SU_TTL_SU_ID = ISNULL(@SU_ID, SU_TTL_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_TTL_Positor,
                    SU_TTL_SU_ID,
                    SU_TTL_PositedAt,
                    SU_TTL_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_TTL_Subject_Title]
                PIVOT (
                    MIN(SU_TTL_Subject_Title) FOR SU_TTL_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_TTL_SU_ID = ISNULL(@SU_ID, SU_TTL_SU_ID)
                AND
                    SU_TTL_Positor = ' + @positor + '
            ) b
            ON
                b.SU_TTL_SU_ID = x.SU_TTL_SU_ID
            AND
                b.SU_TTL_PositedAt = x.SU_TTL_PositedAt
            ORDER BY
                SU_TTL_SU_ID,
                SU_TTL_PositedAt,
                SU_TTL_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_STA_Subject_State procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_STA_Subject_State', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_STA_Subject_State];
GO
CREATE PROCEDURE [dbo].[ssSU_STA_Subject_State] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_STA_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_STA_Subject_State]
        WHERE
            SU_STA_SU_ID = ISNULL(@SU_ID, SU_STA_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_STA_Positor
    FROM
        [dbo].[SU_STA_Subject_State]
    WHERE
        SU_STA_SU_ID = ISNULL(@SU_ID, SU_STA_SU_ID)
    AND
        SU_STA_Subject_State is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_STA_Positor,
                x.SU_STA_SU_ID,
                x.SU_STA_PositedAt,
                b.SU_STA_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_STA_SU_ID,
                    SU_STA_PositedAt
                FROM
                    [dbo].[SU_STA_Subject_State]
                WHERE
                    SU_STA_SU_ID = ISNULL(@SU_ID, SU_STA_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_STA_Positor,
                    SU_STA_SU_ID,
                    SU_STA_PositedAt,
                    SU_STA_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_STA_Subject_State]
                PIVOT (
                    MIN(SU_STA_Subject_State) FOR SU_STA_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_STA_SU_ID = ISNULL(@SU_ID, SU_STA_SU_ID)
                AND
                    SU_STA_Positor = ' + @positor + '
            ) b
            ON
                b.SU_STA_SU_ID = x.SU_STA_SU_ID
            AND
                b.SU_STA_PositedAt = x.SU_STA_PositedAt
            ORDER BY
                SU_STA_SU_ID,
                SU_STA_PositedAt,
                SU_STA_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_LBL_Subject_Label procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_LBL_Subject_Label', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_LBL_Subject_Label];
GO
CREATE PROCEDURE [dbo].[ssSU_LBL_Subject_Label] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_LBL_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_LBL_Subject_Label]
        WHERE
            SU_LBL_SU_ID = ISNULL(@SU_ID, SU_LBL_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_LBL_Positor
    FROM
        [dbo].[SU_LBL_Subject_Label]
    WHERE
        SU_LBL_SU_ID = ISNULL(@SU_ID, SU_LBL_SU_ID)
    AND
        SU_LBL_Subject_Label is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_LBL_Positor,
                x.SU_LBL_SU_ID,
                x.SU_LBL_PositedAt,
                b.SU_LBL_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_LBL_SU_ID,
                    SU_LBL_PositedAt
                FROM
                    [dbo].[SU_LBL_Subject_Label]
                WHERE
                    SU_LBL_SU_ID = ISNULL(@SU_ID, SU_LBL_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_LBL_Positor,
                    SU_LBL_SU_ID,
                    SU_LBL_PositedAt,
                    SU_LBL_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_LBL_Subject_Label]
                PIVOT (
                    MIN(SU_LBL_Subject_Label) FOR SU_LBL_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_LBL_SU_ID = ISNULL(@SU_ID, SU_LBL_SU_ID)
                AND
                    SU_LBL_Positor = ' + @positor + '
            ) b
            ON
                b.SU_LBL_SU_ID = x.SU_LBL_SU_ID
            AND
                b.SU_LBL_PositedAt = x.SU_LBL_PositedAt
            ORDER BY
                SU_LBL_SU_ID,
                SU_LBL_PositedAt,
                SU_LBL_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_TAG_Subject_Tag procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_TAG_Subject_Tag', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_TAG_Subject_Tag];
GO
CREATE PROCEDURE [dbo].[ssSU_TAG_Subject_Tag] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_TAG_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_TAG_Subject_Tag]
        WHERE
            SU_TAG_SU_ID = ISNULL(@SU_ID, SU_TAG_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_TAG_Positor
    FROM
        [dbo].[SU_TAG_Subject_Tag]
    WHERE
        SU_TAG_SU_ID = ISNULL(@SU_ID, SU_TAG_SU_ID)
    AND
        SU_TAG_Subject_Tag is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_TAG_Positor,
                x.SU_TAG_SU_ID,
                x.SU_TAG_PositedAt,
                b.SU_TAG_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_TAG_SU_ID,
                    SU_TAG_PositedAt
                FROM
                    [dbo].[SU_TAG_Subject_Tag]
                WHERE
                    SU_TAG_SU_ID = ISNULL(@SU_ID, SU_TAG_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_TAG_Positor,
                    SU_TAG_SU_ID,
                    SU_TAG_PositedAt,
                    SU_TAG_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_TAG_Subject_Tag]
                PIVOT (
                    MIN(SU_TAG_Subject_Tag) FOR SU_TAG_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_TAG_SU_ID = ISNULL(@SU_ID, SU_TAG_SU_ID)
                AND
                    SU_TAG_Positor = ' + @positor + '
            ) b
            ON
                b.SU_TAG_SU_ID = x.SU_TAG_SU_ID
            AND
                b.SU_TAG_PositedAt = x.SU_TAG_PositedAt
            ORDER BY
                SU_TAG_SU_ID,
                SU_TAG_PositedAt,
                SU_TAG_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_LVL_Subject_Level procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_LVL_Subject_Level', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_LVL_Subject_Level];
GO
CREATE PROCEDURE [dbo].[ssSU_LVL_Subject_Level] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_LVL_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_LVL_Subject_Level]
        WHERE
            SU_LVL_SU_ID = ISNULL(@SU_ID, SU_LVL_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_LVL_Positor
    FROM
        [dbo].[SU_LVL_Subject_Level]
    WHERE
        SU_LVL_SU_ID = ISNULL(@SU_ID, SU_LVL_SU_ID)
    AND
        SU_LVL_GRD_ID is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_LVL_Positor,
                x.SU_LVL_SU_ID,
                x.SU_LVL_PositedAt,
                b.SU_LVL_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_LVL_SU_ID,
                    SU_LVL_PositedAt
                FROM
                    [dbo].[SU_LVL_Subject_Level]
                WHERE
                    SU_LVL_SU_ID = ISNULL(@SU_ID, SU_LVL_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_LVL_Positor,
                    SU_LVL_SU_ID,
                    SU_LVL_PositedAt,
                    SU_LVL_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_LVL_Subject_Level]
                PIVOT (
                    MIN(SU_LVL_GRD_ID) FOR SU_LVL_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_LVL_SU_ID = ISNULL(@SU_ID, SU_LVL_SU_ID)
                AND
                    SU_LVL_Positor = ' + @positor + '
            ) b
            ON
                b.SU_LVL_SU_ID = x.SU_LVL_SU_ID
            AND
                b.SU_LVL_PositedAt = x.SU_LVL_PositedAt
            ORDER BY
                SU_LVL_SU_ID,
                SU_LVL_PositedAt,
                SU_LVL_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_TXT_Subject_Text procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_TXT_Subject_Text', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_TXT_Subject_Text];
GO
CREATE PROCEDURE [dbo].[ssSU_TXT_Subject_Text] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_TXT_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_TXT_Subject_Text]
        WHERE
            SU_TXT_SU_ID = ISNULL(@SU_ID, SU_TXT_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_TXT_Positor
    FROM
        [dbo].[SU_TXT_Subject_Text]
    WHERE
        SU_TXT_SU_ID = ISNULL(@SU_ID, SU_TXT_SU_ID)
    AND
        SU_TXT_Subject_Text is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_TXT_Positor,
                x.SU_TXT_SU_ID,
                x.SU_TXT_PositedAt,
                b.SU_TXT_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_TXT_SU_ID,
                    SU_TXT_PositedAt
                FROM
                    [dbo].[SU_TXT_Subject_Text]
                WHERE
                    SU_TXT_SU_ID = ISNULL(@SU_ID, SU_TXT_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_TXT_Positor,
                    SU_TXT_SU_ID,
                    SU_TXT_PositedAt,
                    SU_TXT_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_TXT_Subject_Text]
                PIVOT (
                    MIN(SU_TXT_Subject_Text) FOR SU_TXT_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_TXT_SU_ID = ISNULL(@SU_ID, SU_TXT_SU_ID)
                AND
                    SU_TXT_Positor = ' + @positor + '
            ) b
            ON
                b.SU_TXT_SU_ID = x.SU_TXT_SU_ID
            AND
                b.SU_TXT_PositedAt = x.SU_TXT_PositedAt
            ORDER BY
                SU_TXT_SU_ID,
                SU_TXT_PositedAt,
                SU_TXT_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_ASR_Subject_Assessment procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_ASR_Subject_Assessment', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_ASR_Subject_Assessment];
GO
CREATE PROCEDURE [dbo].[ssSU_ASR_Subject_Assessment] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_ASR_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_ASR_Subject_Assessment]
        WHERE
            SU_ASR_SU_ID = ISNULL(@SU_ID, SU_ASR_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_ASR_Positor
    FROM
        [dbo].[SU_ASR_Subject_Assessment]
    WHERE
        SU_ASR_SU_ID = ISNULL(@SU_ID, SU_ASR_SU_ID)
    AND
        SU_ASR_Subject_Assessment is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_ASR_Positor,
                x.SU_ASR_SU_ID,
                x.SU_ASR_PositedAt,
                b.SU_ASR_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_ASR_SU_ID,
                    SU_ASR_PositedAt
                FROM
                    [dbo].[SU_ASR_Subject_Assessment]
                WHERE
                    SU_ASR_SU_ID = ISNULL(@SU_ID, SU_ASR_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_ASR_Positor,
                    SU_ASR_SU_ID,
                    SU_ASR_PositedAt,
                    SU_ASR_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_ASR_Subject_Assessment]
                PIVOT (
                    MIN(SU_ASR_Subject_Assessment) FOR SU_ASR_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_ASR_SU_ID = ISNULL(@SU_ID, SU_ASR_SU_ID)
                AND
                    SU_ASR_Positor = ' + @positor + '
            ) b
            ON
                b.SU_ASR_SU_ID = x.SU_ASR_SU_ID
            AND
                b.SU_ASR_PositedAt = x.SU_ASR_PositedAt
            ORDER BY
                SU_ASR_SU_ID,
                SU_ASR_PositedAt,
                SU_ASR_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
-- Attribute sheet stack ----------------------------------------------------------------------------------------------
-- ssSU_ERS_Subject_Erasable procedure returning one temporal sheet per positor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ssSU_ERS_Subject_Erasable', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[ssSU_ERS_Subject_Erasable];
GO
CREATE PROCEDURE [dbo].[ssSU_ERS_Subject_Erasable] (
    @SU_ID int = null
)
AS
BEGIN
    DECLARE @pivot varchar(max);
    SET @pivot = REPLACE((
        SELECT DISTINCT
            '[' + convert(varchar(23), SU_ERS_ChangedAt, 126) + ']' AS [text()]
        FROM
            [dbo].[SU_ERS_Subject_Erasable]
        WHERE
            SU_ERS_SU_ID = ISNULL(@SU_ID, SU_ERS_SU_ID)
        FOR XML PATH('')
    ), '][', '], [');
    DECLARE positor CURSOR FOR
    SELECT DISTINCT
        SU_ERS_Positor
    FROM
        [dbo].[SU_ERS_Subject_Erasable]
    WHERE
        SU_ERS_SU_ID = ISNULL(@SU_ID, SU_ERS_SU_ID)
    AND
        SU_ERS_Subject_Erasable is not null;
    DECLARE @positor varchar(20);
    OPEN positor;
    FETCH NEXT FROM positor INTO @positor;
    DECLARE @sql nvarchar(max);
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
            SELECT
                b.SU_ERS_Positor,
                x.SU_ERS_SU_ID,
                x.SU_ERS_PositedAt,
                b.SU_ERS_Assertion,
                ' + @pivot + '
            FROM (
                SELECT DISTINCT
                    SU_ERS_SU_ID,
                    SU_ERS_PositedAt
                FROM
                    [dbo].[SU_ERS_Subject_Erasable]
                WHERE
                    SU_ERS_SU_ID = ISNULL(@SU_ID, SU_ERS_SU_ID)
            ) x
            LEFT JOIN (
                SELECT
                    SU_ERS_Positor,
                    SU_ERS_SU_ID,
                    SU_ERS_PositedAt,
                    SU_ERS_Assertion,
                    ' + @pivot + '
                FROM
                    [dbo].[SU_ERS_Subject_Erasable]
                PIVOT (
                    MIN(SU_ERS_Subject_Erasable) FOR SU_ERS_ChangedAt IN (' + @pivot + ')
                ) p
                WHERE
                    SU_ERS_SU_ID = ISNULL(@SU_ID, SU_ERS_SU_ID)
                AND
                    SU_ERS_Positor = ' + @positor + '
            ) b
            ON
                b.SU_ERS_SU_ID = x.SU_ERS_SU_ID
            AND
                b.SU_ERS_PositedAt = x.SU_ERS_PositedAt
            ORDER BY
                SU_ERS_SU_ID,
                SU_ERS_PositedAt,
                SU_ERS_Assertion
        ';
        -- the statement runs in a scope of its own, so the parameter is passed to it
        EXEC sp_executesql @sql, N'@SU_ID int', @SU_ID;
        FETCH NEXT FROM positor INTO @positor;
    END
    CLOSE positor;
    DEALLOCATE positor;
END
GO
