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
-- rt_EV_STA_Event_Status (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rt_EV_STA_Event_Status', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[rt_EV_STA_Event_Status];
GO
CREATE TRIGGER [attributes].[rt_EV_STA_Event_Status] ON [attributes].[EV_STA_Event_Status]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @EV_STA_Event_Status TABLE (
        EV_STA_EV_ID numeric(12,0) not null,
        EV_STA_EQ tinyint not null,
        Metadata_EV_STA int not null,
        EV_STA_ChangedAt datetime2 not null,
        EV_STA_Event_Status nvarchar(20) not null,
        primary key(
            EV_STA_EV_ID asc, 
            EV_STA_ChangedAt desc
        )
    );
    INSERT INTO @EV_STA_Event_Status (
        EV_STA_EV_ID,
        EV_STA_EQ,
        Metadata_EV_STA,
        EV_STA_ChangedAt,
        EV_STA_Event_Status
    )
    SELECT
        EV_STA_EV_ID,
        EV_STA_EQ,
        Metadata_EV_STA,
        EV_STA_ChangedAt,
        EV_STA_Event_Status
    FROM 
        inserted;
    INSERT INTO @EV_STA_Event_Status (
        EV_STA_EV_ID,
        EV_STA_EQ,
        Metadata_EV_STA,
        EV_STA_ChangedAt,
        EV_STA_Event_Status
    )
    SELECT
        p.EV_STA_EV_ID,
        p.EV_STA_EQ,
        p.Metadata_EV_STA,
        p.EV_STA_ChangedAt,
        p.EV_STA_Event_Status
    FROM (
        SELECT DISTINCT 
            EV_STA_EQ,
            EV_STA_EV_ID 
        FROM 
            @EV_STA_Event_Status
    ) i 
    JOIN
        [attributes].[EV_STA_Event_Status] p
    ON 
        p.EV_STA_EQ = i.EV_STA_EQ
    AND 
        p.EV_STA_EV_ID = i.EV_STA_EV_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.EV_STA_EV_ID
        FROM
            @EV_STA_Event_Status x
        WHERE
            p.EV_STA_EQ = i.EV_STA_EQ
        AND 
            x.EV_STA_EV_ID = p.EV_STA_EV_ID
        AND
            x.EV_STA_ChangedAt = p.EV_STA_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @EV_STA_Event_Status i
        CROSS APPLY (
            SELECT TOP 1
                h.EV_STA_EQ,
                h.EV_STA_EV_ID,
                h.EV_STA_ChangedAt,
                h.EV_STA_Event_Status
            FROM 
                @EV_STA_Event_Status h
            WHERE
                h.EV_STA_EQ = i.EV_STA_EQ
            AND 
                h.EV_STA_EV_ID = i.EV_STA_EV_ID
            AND
                h.EV_STA_ChangedAt < i.EV_STA_ChangedAt
            ORDER BY 
                h.EV_STA_ChangedAt DESC
        ) pre
        WHERE
            i.EV_STA_Event_Status = pre.EV_STA_Event_Status
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in EV_STA_Event_Status for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_EV_LVL_Event_Level (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rt_EV_LVL_Event_Level', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[rt_EV_LVL_Event_Level];
GO
CREATE TRIGGER [attributes].[rt_EV_LVL_Event_Level] ON [attributes].[EV_LVL_Event_Level]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @EV_LVL_Event_Level TABLE (
        EV_LVL_EV_ID numeric(12,0) not null,
        Metadata_EV_LVL int not null,
        EV_LVL_ChangedAt date not null,
        EV_LVL_PLV_ID tinyint not null, 
        primary key(
            EV_LVL_EV_ID asc, 
            EV_LVL_ChangedAt desc
        )
    );
    INSERT INTO @EV_LVL_Event_Level (
        EV_LVL_EV_ID,
        Metadata_EV_LVL,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    )
    SELECT
        EV_LVL_EV_ID,
        Metadata_EV_LVL,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    FROM 
        inserted;
    INSERT INTO @EV_LVL_Event_Level (
        EV_LVL_EV_ID,
        Metadata_EV_LVL,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    )
    SELECT
        p.EV_LVL_EV_ID,
        p.Metadata_EV_LVL,
        p.EV_LVL_ChangedAt,
        p.EV_LVL_PLV_ID
    FROM (
        SELECT DISTINCT 
            EV_LVL_EV_ID 
        FROM 
            @EV_LVL_Event_Level
    ) i 
    JOIN
        [attributes].[EV_LVL_Event_Level] p
    ON 
        p.EV_LVL_EV_ID = i.EV_LVL_EV_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.EV_LVL_EV_ID
        FROM
            @EV_LVL_Event_Level x
        WHERE
            x.EV_LVL_EV_ID = p.EV_LVL_EV_ID
        AND
            x.EV_LVL_ChangedAt = p.EV_LVL_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @EV_LVL_Event_Level i
        CROSS APPLY (
            SELECT TOP 1
                h.EV_LVL_EV_ID,
                h.EV_LVL_ChangedAt,
                h.EV_LVL_PLV_ID
            FROM 
                @EV_LVL_Event_Level h
            WHERE
                h.EV_LVL_EV_ID = i.EV_LVL_EV_ID
            AND
                h.EV_LVL_ChangedAt < i.EV_LVL_ChangedAt
            ORDER BY 
                h.EV_LVL_ChangedAt DESC
        ) pre
        WHERE
            i.EV_LVL_PLV_ID = pre.EV_LVL_PLV_ID
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in EV_LVL_Event_Level for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_ST_AVG_Stage_Average (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rt_ST_AVG_Stage_Average', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[rt_ST_AVG_Stage_Average];
GO
CREATE TRIGGER [attributes].[rt_ST_AVG_Stage_Average] ON [attributes].[ST_AVG_Stage_Average]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_UTL_ID tinyint not null, 
        primary key(
            ST_AVG_ST_ID asc, 
            ST_AVG_ChangedAt desc
        )
    );
    INSERT INTO @ST_AVG_Stage_Average (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    SELECT
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    FROM 
        inserted;
    INSERT INTO @ST_AVG_Stage_Average (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    SELECT
        p.ST_AVG_ST_ID,
        p.Metadata_ST_AVG,
        p.ST_AVG_ChangedAt,
        p.ST_AVG_UTL_ID
    FROM (
        SELECT DISTINCT 
            ST_AVG_ST_ID 
        FROM 
            @ST_AVG_Stage_Average
    ) i 
    JOIN
        [attributes].[ST_AVG_Stage_Average] p
    ON 
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.ST_AVG_ST_ID
        FROM
            @ST_AVG_Stage_Average x
        WHERE
            x.ST_AVG_ST_ID = p.ST_AVG_ST_ID
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
                h.ST_AVG_ST_ID,
                h.ST_AVG_ChangedAt,
                h.ST_AVG_UTL_ID
            FROM 
                @ST_AVG_Stage_Average h
            WHERE
                h.ST_AVG_ST_ID = i.ST_AVG_ST_ID
            AND
                h.ST_AVG_ChangedAt < i.ST_AVG_ChangedAt
            ORDER BY 
                h.ST_AVG_ChangedAt DESC
        ) pre
        WHERE
            i.ST_AVG_UTL_ID = pre.ST_AVG_UTL_ID
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
IF Object_ID('attributes.rt_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[rt_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [attributes].[rt_AC_NAM_Actor_Name] ON [attributes].[AC_NAM_Actor_Name]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_NAM_AC_ID smallint not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_Actor_Name varbinary(max) not null,
        primary key(
            AC_NAM_AC_ID asc, 
            AC_NAM_ChangedAt desc
        )
    );
    INSERT INTO @AC_NAM_Actor_Name (
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    FROM 
        inserted;
    INSERT INTO @AC_NAM_Actor_Name (
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT
        p.AC_NAM_AC_ID,
        p.Metadata_AC_NAM,
        p.AC_NAM_ChangedAt,
        p.AC_NAM_Actor_Name
    FROM (
        SELECT DISTINCT 
            AC_NAM_AC_ID 
        FROM 
            @AC_NAM_Actor_Name
    ) i 
    JOIN
        [attributes].[AC_NAM_Actor_Name] p
    ON 
        p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.AC_NAM_AC_ID
        FROM
            @AC_NAM_Actor_Name x
        WHERE
            x.AC_NAM_AC_ID = p.AC_NAM_AC_ID
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
                h.AC_NAM_AC_ID,
                h.AC_NAM_ChangedAt,
                h.AC_NAM_Actor_Name
            FROM 
                @AC_NAM_Actor_Name h
            WHERE
                h.AC_NAM_AC_ID = i.AC_NAM_AC_ID
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
