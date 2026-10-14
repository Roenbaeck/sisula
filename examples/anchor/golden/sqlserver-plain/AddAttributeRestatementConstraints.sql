-- ATTRIBUTE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------
--
-- Attributes may be prevented from storing restatements.
-- A restatement is when the same value occurs for two adjacent points
-- in changing time. Note that restatement checking is not done for
-- unreliable information as this could prevent demotion.
--
-- If actual deletes are made, the remaining information will not
-- be checked for restatements.
--
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_ST_AVG_Stage_Average (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_ST_AVG_Stage_Average', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_ST_AVG_Stage_Average];
GO
CREATE TRIGGER [dbo].[rt_ST_AVG_Stage_Average] ON [dbo].[ST_AVG_Stage_Average]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_ID int not null,
        ST_AVG_ChangedAt datetime2 not null,
        UTL_ID tinyint not null, 
        primary key(
            ST_ID asc, 
            ST_AVG_ChangedAt desc
        )
    );
    INSERT INTO @ST_AVG_Stage_Average (
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    )
    SELECT
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    FROM 
        inserted;
    INSERT INTO @ST_AVG_Stage_Average (
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    )
    SELECT
        p.ST_ID,
        p.ST_AVG_ChangedAt,
        p.UTL_ID
    FROM (
        SELECT DISTINCT 
            ST_ID 
        FROM 
            @ST_AVG_Stage_Average
    ) i 
    JOIN
        [dbo].[ST_AVG_Stage_Average] p
    ON 
        p.ST_ID = i.ST_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.ST_ID
        FROM
            @ST_AVG_Stage_Average x
        WHERE
            x.ST_ID = p.ST_ID
        AND
            x.ST_AVG_ChangedAt = p.ST_AVG_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @ST_AVG_Stage_Average i
        CROSS APPLY (
            SELECT TOP 1
                h.ST_ID,
                h.ST_AVG_ChangedAt,
                h.UTL_ID
            FROM 
                @ST_AVG_Stage_Average h
            WHERE
                h.ST_ID = i.ST_ID
            AND
                h.ST_AVG_ChangedAt < i.ST_AVG_ChangedAt
            ORDER BY 
                h.ST_AVG_ChangedAt DESC
        ) pre
        WHERE
            i.UTL_ID = pre.UTL_ID
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in ST_AVG_Stage_Average for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_AC_NAM_Actor_Name (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [dbo].[rt_AC_NAM_Actor_Name] ON [dbo].[AC_NAM_Actor_Name]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_ID int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        primary key(
            AC_ID asc, 
            AC_NAM_ChangedAt desc
        )
    );
    INSERT INTO @AC_NAM_Actor_Name (
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    FROM 
        inserted;
    INSERT INTO @AC_NAM_Actor_Name (
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT
        p.AC_ID,
        p.AC_NAM_ChangedAt,
        p.AC_NAM_Actor_Name
    FROM (
        SELECT DISTINCT 
            AC_ID 
        FROM 
            @AC_NAM_Actor_Name
    ) i 
    JOIN
        [dbo].[AC_NAM_Actor_Name] p
    ON 
        p.AC_ID = i.AC_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.AC_ID
        FROM
            @AC_NAM_Actor_Name x
        WHERE
            x.AC_ID = p.AC_ID
        AND
            x.AC_NAM_ChangedAt = p.AC_NAM_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @AC_NAM_Actor_Name i
        CROSS APPLY (
            SELECT TOP 1
                h.AC_ID,
                h.AC_NAM_ChangedAt,
                h.AC_NAM_Actor_Name
            FROM 
                @AC_NAM_Actor_Name h
            WHERE
                h.AC_ID = i.AC_ID
            AND
                h.AC_NAM_ChangedAt < i.AC_NAM_ChangedAt
            ORDER BY 
                h.AC_NAM_ChangedAt DESC
        ) pre
        WHERE
            i.AC_NAM_Actor_Name = pre.AC_NAM_Actor_Name
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in AC_NAM_Actor_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
