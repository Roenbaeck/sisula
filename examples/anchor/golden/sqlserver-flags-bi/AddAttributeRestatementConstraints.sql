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
CREATE TRIGGER [attributes].[rt_EV_STA_Event_Status] ON [attributes].[EV_STA_Event_Status_Annex]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @EV_STA_Event_Status TABLE (
        EV_STA_ID int not null,
        EV_STA_EV_ID numeric(12,0) not null,
        Metadata_EV_STA int not null,
        EV_STA_ChangedAt datetime2 not null,
        EV_STA_PositedAt datetime2 not null,
        EV_STA_Reliability decimal(5,2) not null,
        EV_STA_Event_Status nvarchar(20) not null,
        primary key (
            EV_STA_EV_ID asc,
            EV_STA_ChangedAt desc,
            EV_STA_PositedAt desc,
            EV_STA_Reliability desc
        ),
        unique (
            EV_STA_ID,
            EV_STA_PositedAt
        )
    );
    INSERT INTO @EV_STA_Event_Status (
        EV_STA_ID,
        EV_STA_EV_ID,
        Metadata_EV_STA,
        EV_STA_ChangedAt,
        EV_STA_PositedAt,
        EV_STA_Reliability,
        EV_STA_Event_Status
    )
    SELECT
        i.EV_STA_ID,
        p.EV_STA_EV_ID,
        i.Metadata_EV_STA,
        p.EV_STA_ChangedAt,
        i.EV_STA_PositedAt,
        i.EV_STA_Reliability,
        p.EV_STA_Event_Status
    FROM
        inserted i
    JOIN
        [attributes].[EV_STA_Event_Status_Posit] p
    ON
        p.EV_STA_ID = i.EV_STA_ID; -- the posit has already been created
    INSERT INTO @EV_STA_Event_Status (
        EV_STA_ID,
        EV_STA_EV_ID,
        Metadata_EV_STA,
        EV_STA_ChangedAt,
        EV_STA_PositedAt,
        EV_STA_Reliability,
        EV_STA_Event_Status
    )
    SELECT
        p.EV_STA_ID,
        p.EV_STA_EV_ID,
        p.Metadata_EV_STA,
        p.EV_STA_ChangedAt,
        p.EV_STA_PositedAt,
        p.EV_STA_Reliability,
        p.EV_STA_Event_Status
    FROM
        (SELECT DISTINCT EV_STA_EV_ID FROM @EV_STA_Event_Status) i
    JOIN
        [attributes].[EV_STA_Event_Status] p
    ON
        p.EV_STA_EV_ID = i.EV_STA_EV_ID
    LEFT JOIN
        @EV_STA_Event_Status x
    ON
        x.EV_STA_ID = p.EV_STA_ID
    AND
        x.EV_STA_PositedAt = p.EV_STA_PositedAt
    WHERE
        x.EV_STA_ID is null;
    -- no need to check retracted information
    DELETE a
    FROM
        @EV_STA_Event_Status a
    OUTER APPLY (
        SELECT TOP 1
            x.EV_STA_Reliability
        FROM
            @EV_STA_Event_Status x
        WHERE
            x.EV_STA_ID = a.EV_STA_ID
        AND
            x.EV_STA_PositedAt < a.EV_STA_PositedAt
        ORDER BY
            x.EV_STA_PositedAt DESC
    ) pre
    OUTER APPLY (
        SELECT TOP 1
            x.EV_STA_Reliability
        FROM
            @EV_STA_Event_Status x
        WHERE
            x.EV_STA_ID = a.EV_STA_ID
        AND
            x.EV_STA_PositedAt > a.EV_STA_PositedAt
        ORDER BY
            x.EV_STA_PositedAt ASC
    ) fol
    WHERE
        (a.EV_STA_Reliability = 1 AND fol.EV_STA_Reliability = 0)
    OR
        (a.EV_STA_Reliability = 0 AND pre.EV_STA_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @EV_STA_Event_Status a
        CROSS APPLY (
            SELECT TOP 1
                h.EV_STA_EV_ID,
                h.EV_STA_ChangedAt,
                h.EV_STA_Event_Status
            FROM
                @EV_STA_Event_Status h
            WHERE
                h.EV_STA_EV_ID = a.EV_STA_EV_ID
            AND
                h.EV_STA_ChangedAt < a.EV_STA_ChangedAt
            ORDER BY
                h.EV_STA_ChangedAt DESC,
                h.EV_STA_PositedAt DESC,
                h.EV_STA_Reliability DESC
        ) pre
        WHERE
            a.EV_STA_Event_Status = pre.EV_STA_Event_Status
        AND
            a.EV_STA_Reliability = 1
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
CREATE TRIGGER [attributes].[rt_EV_LVL_Event_Level] ON [attributes].[EV_LVL_Event_Level_Annex]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @EV_LVL_Event_Level TABLE (
        EV_LVL_ID int not null,
        EV_LVL_EV_ID numeric(12,0) not null,
        Metadata_EV_LVL int not null,
        EV_LVL_ChangedAt date not null,
        EV_LVL_PositedAt datetime2 not null,
        EV_LVL_Reliability decimal(5,2) not null,
        EV_LVL_PLV_ID tinyint not null,
        primary key (
            EV_LVL_EV_ID asc,
            EV_LVL_ChangedAt desc,
            EV_LVL_PositedAt desc,
            EV_LVL_Reliability desc
        ),
        unique (
            EV_LVL_ID,
            EV_LVL_PositedAt
        )
    );
    INSERT INTO @EV_LVL_Event_Level (
        EV_LVL_ID,
        EV_LVL_EV_ID,
        Metadata_EV_LVL,
        EV_LVL_ChangedAt,
        EV_LVL_PositedAt,
        EV_LVL_Reliability,
        EV_LVL_PLV_ID
    )
    SELECT
        i.EV_LVL_ID,
        p.EV_LVL_EV_ID,
        i.Metadata_EV_LVL,
        p.EV_LVL_ChangedAt,
        i.EV_LVL_PositedAt,
        i.EV_LVL_Reliability,
        p.EV_LVL_PLV_ID
    FROM
        inserted i
    JOIN
        [attributes].[EV_LVL_Event_Level_Posit] p
    ON
        p.EV_LVL_ID = i.EV_LVL_ID; -- the posit has already been created
    INSERT INTO @EV_LVL_Event_Level (
        EV_LVL_ID,
        EV_LVL_EV_ID,
        Metadata_EV_LVL,
        EV_LVL_ChangedAt,
        EV_LVL_PositedAt,
        EV_LVL_Reliability,
        EV_LVL_PLV_ID
    )
    SELECT
        p.EV_LVL_ID,
        p.EV_LVL_EV_ID,
        p.Metadata_EV_LVL,
        p.EV_LVL_ChangedAt,
        p.EV_LVL_PositedAt,
        p.EV_LVL_Reliability,
        p.EV_LVL_PLV_ID
    FROM
        (SELECT DISTINCT EV_LVL_EV_ID FROM @EV_LVL_Event_Level) i
    JOIN
        [attributes].[EV_LVL_Event_Level] p
    ON
        p.EV_LVL_EV_ID = i.EV_LVL_EV_ID
    LEFT JOIN
        @EV_LVL_Event_Level x
    ON
        x.EV_LVL_ID = p.EV_LVL_ID
    AND
        x.EV_LVL_PositedAt = p.EV_LVL_PositedAt
    WHERE
        x.EV_LVL_ID is null;
    -- no need to check retracted information
    DELETE a
    FROM
        @EV_LVL_Event_Level a
    OUTER APPLY (
        SELECT TOP 1
            x.EV_LVL_Reliability
        FROM
            @EV_LVL_Event_Level x
        WHERE
            x.EV_LVL_ID = a.EV_LVL_ID
        AND
            x.EV_LVL_PositedAt < a.EV_LVL_PositedAt
        ORDER BY
            x.EV_LVL_PositedAt DESC
    ) pre
    OUTER APPLY (
        SELECT TOP 1
            x.EV_LVL_Reliability
        FROM
            @EV_LVL_Event_Level x
        WHERE
            x.EV_LVL_ID = a.EV_LVL_ID
        AND
            x.EV_LVL_PositedAt > a.EV_LVL_PositedAt
        ORDER BY
            x.EV_LVL_PositedAt ASC
    ) fol
    WHERE
        (a.EV_LVL_Reliability = 1 AND fol.EV_LVL_Reliability = 0)
    OR
        (a.EV_LVL_Reliability = 0 AND pre.EV_LVL_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @EV_LVL_Event_Level a
        CROSS APPLY (
            SELECT TOP 1
                h.EV_LVL_EV_ID,
                h.EV_LVL_ChangedAt,
                h.EV_LVL_PLV_ID
            FROM
                @EV_LVL_Event_Level h
            WHERE
                h.EV_LVL_EV_ID = a.EV_LVL_EV_ID
            AND
                h.EV_LVL_ChangedAt < a.EV_LVL_ChangedAt
            ORDER BY
                h.EV_LVL_ChangedAt DESC,
                h.EV_LVL_PositedAt DESC,
                h.EV_LVL_Reliability DESC
        ) pre
        WHERE
            a.EV_LVL_PLV_ID = pre.EV_LVL_PLV_ID
        AND
            a.EV_LVL_Reliability = 1
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
CREATE TRIGGER [attributes].[rt_ST_AVG_Stage_Average] ON [attributes].[ST_AVG_Stage_Average_Annex]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_AVG_ID int not null,
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null,
        primary key (
            ST_AVG_ST_ID asc,
            ST_AVG_ChangedAt desc,
            ST_AVG_PositedAt desc,
            ST_AVG_Reliability desc
        ),
        unique (
            ST_AVG_ID,
            ST_AVG_PositedAt
        )
    );
    INSERT INTO @ST_AVG_Stage_Average (
        ST_AVG_ID,
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID
    )
    SELECT
        i.ST_AVG_ID,
        p.ST_AVG_ST_ID,
        i.Metadata_ST_AVG,
        p.ST_AVG_ChangedAt,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Reliability,
        p.ST_AVG_UTL_ID
    FROM
        inserted i
    JOIN
        [attributes].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ID = i.ST_AVG_ID; -- the posit has already been created
    INSERT INTO @ST_AVG_Stage_Average (
        ST_AVG_ID,
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID
    )
    SELECT
        p.ST_AVG_ID,
        p.ST_AVG_ST_ID,
        p.Metadata_ST_AVG,
        p.ST_AVG_ChangedAt,
        p.ST_AVG_PositedAt,
        p.ST_AVG_Reliability,
        p.ST_AVG_UTL_ID
    FROM
        (SELECT DISTINCT ST_AVG_ST_ID FROM @ST_AVG_Stage_Average) i
    JOIN
        [attributes].[ST_AVG_Stage_Average] p
    ON
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
    LEFT JOIN
        @ST_AVG_Stage_Average x
    ON
        x.ST_AVG_ID = p.ST_AVG_ID
    AND
        x.ST_AVG_PositedAt = p.ST_AVG_PositedAt
    WHERE
        x.ST_AVG_ID is null;
    -- no need to check retracted information
    DELETE a
    FROM
        @ST_AVG_Stage_Average a
    OUTER APPLY (
        SELECT TOP 1
            x.ST_AVG_Reliability
        FROM
            @ST_AVG_Stage_Average x
        WHERE
            x.ST_AVG_ID = a.ST_AVG_ID
        AND
            x.ST_AVG_PositedAt < a.ST_AVG_PositedAt
        ORDER BY
            x.ST_AVG_PositedAt DESC
    ) pre
    OUTER APPLY (
        SELECT TOP 1
            x.ST_AVG_Reliability
        FROM
            @ST_AVG_Stage_Average x
        WHERE
            x.ST_AVG_ID = a.ST_AVG_ID
        AND
            x.ST_AVG_PositedAt > a.ST_AVG_PositedAt
        ORDER BY
            x.ST_AVG_PositedAt ASC
    ) fol
    WHERE
        (a.ST_AVG_Reliability = 1 AND fol.ST_AVG_Reliability = 0)
    OR
        (a.ST_AVG_Reliability = 0 AND pre.ST_AVG_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @ST_AVG_Stage_Average a
        CROSS APPLY (
            SELECT TOP 1
                h.ST_AVG_ST_ID,
                h.ST_AVG_ChangedAt,
                h.ST_AVG_UTL_ID
            FROM
                @ST_AVG_Stage_Average h
            WHERE
                h.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            AND
                h.ST_AVG_ChangedAt < a.ST_AVG_ChangedAt
            ORDER BY
                h.ST_AVG_ChangedAt DESC,
                h.ST_AVG_PositedAt DESC,
                h.ST_AVG_Reliability DESC
        ) pre
        WHERE
            a.ST_AVG_UTL_ID = pre.ST_AVG_UTL_ID
        AND
            a.ST_AVG_Reliability = 1
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
CREATE TRIGGER [attributes].[rt_AC_NAM_Actor_Name] ON [attributes].[AC_NAM_Actor_Name_Annex]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_NAM_ID int not null,
        AC_NAM_AC_ID smallint not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        primary key (
            AC_NAM_AC_ID asc,
            AC_NAM_ChangedAt desc,
            AC_NAM_PositedAt desc,
            AC_NAM_Reliability desc
        ),
        unique (
            AC_NAM_ID,
            AC_NAM_PositedAt
        )
    );
    INSERT INTO @AC_NAM_Actor_Name (
        AC_NAM_ID,
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name
    )
    SELECT
        i.AC_NAM_ID,
        p.AC_NAM_AC_ID,
        i.Metadata_AC_NAM,
        p.AC_NAM_ChangedAt,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Reliability,
        p.AC_NAM_Actor_Name
    FROM
        inserted i
    JOIN
        [attributes].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_NAM_ID = i.AC_NAM_ID; -- the posit has already been created
    INSERT INTO @AC_NAM_Actor_Name (
        AC_NAM_ID,
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name
    )
    SELECT
        p.AC_NAM_ID,
        p.AC_NAM_AC_ID,
        p.Metadata_AC_NAM,
        p.AC_NAM_ChangedAt,
        p.AC_NAM_PositedAt,
        p.AC_NAM_Reliability,
        p.AC_NAM_Actor_Name
    FROM
        (SELECT DISTINCT AC_NAM_AC_ID FROM @AC_NAM_Actor_Name) i
    JOIN
        [attributes].[AC_NAM_Actor_Name] p
    ON
        p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
    LEFT JOIN
        @AC_NAM_Actor_Name x
    ON
        x.AC_NAM_ID = p.AC_NAM_ID
    AND
        x.AC_NAM_PositedAt = p.AC_NAM_PositedAt
    WHERE
        x.AC_NAM_ID is null;
    -- no need to check retracted information
    DELETE a
    FROM
        @AC_NAM_Actor_Name a
    OUTER APPLY (
        SELECT TOP 1
            x.AC_NAM_Reliability
        FROM
            @AC_NAM_Actor_Name x
        WHERE
            x.AC_NAM_ID = a.AC_NAM_ID
        AND
            x.AC_NAM_PositedAt < a.AC_NAM_PositedAt
        ORDER BY
            x.AC_NAM_PositedAt DESC
    ) pre
    OUTER APPLY (
        SELECT TOP 1
            x.AC_NAM_Reliability
        FROM
            @AC_NAM_Actor_Name x
        WHERE
            x.AC_NAM_ID = a.AC_NAM_ID
        AND
            x.AC_NAM_PositedAt > a.AC_NAM_PositedAt
        ORDER BY
            x.AC_NAM_PositedAt ASC
    ) fol
    WHERE
        (a.AC_NAM_Reliability = 1 AND fol.AC_NAM_Reliability = 0)
    OR
        (a.AC_NAM_Reliability = 0 AND pre.AC_NAM_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @AC_NAM_Actor_Name a
        CROSS APPLY (
            SELECT TOP 1
                h.AC_NAM_AC_ID,
                h.AC_NAM_ChangedAt,
                h.AC_NAM_Actor_Name
            FROM
                @AC_NAM_Actor_Name h
            WHERE
                h.AC_NAM_AC_ID = a.AC_NAM_AC_ID
            AND
                h.AC_NAM_ChangedAt < a.AC_NAM_ChangedAt
            ORDER BY
                h.AC_NAM_ChangedAt DESC,
                h.AC_NAM_PositedAt DESC,
                h.AC_NAM_Reliability DESC
        ) pre
        WHERE
            a.AC_NAM_Actor_Name = pre.AC_NAM_Actor_Name
        AND
            a.AC_NAM_Reliability = 1
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
