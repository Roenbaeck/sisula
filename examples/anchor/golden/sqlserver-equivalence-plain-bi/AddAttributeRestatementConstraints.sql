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
CREATE TRIGGER [dbo].[rt_ST_AVG_Stage_Average] ON [dbo].[ST_AVG_Stage_Average_Annex]
AFTER INSERT 
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_AVG_ID int not null,
        ST_AVG_ST_ID int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null, 
        primary key (
            ST_AVG_ST_ID asc, 
            ST_AVG_ChangedAt desc,
            ST_AVG_PositedAt desc
        ),
        unique (
            ST_AVG_ID,
            ST_AVG_PositedAt
        )
    );
    INSERT INTO @ST_AVG_Stage_Average (
        ST_AVG_ID,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID
    )
    SELECT
        i.ST_AVG_ID,
        p.ST_AVG_ST_ID,
        p.ST_AVG_ChangedAt,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Reliability,
        p.ST_AVG_UTL_ID
    FROM 
        inserted i
    JOIN 
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON 
        p.ST_AVG_ID = i.ST_AVG_ID; -- the posit has already been created
    INSERT INTO @ST_AVG_Stage_Average (
        ST_AVG_ID,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID
    )
    SELECT
        p.ST_AVG_ID,
        p.ST_AVG_ST_ID,
        p.ST_AVG_ChangedAt,
        p.ST_AVG_PositedAt,
        p.ST_AVG_Reliability,
        p.ST_AVG_UTL_ID
    FROM 
        (SELECT DISTINCT ST_AVG_ST_ID FROM @ST_AVG_Stage_Average) i
    JOIN
        [dbo].[ST_AVG_Stage_Average] p
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
                h.ST_AVG_PositedAt DESC
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
IF Object_ID('dbo.rt_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [dbo].[rt_AC_NAM_Actor_Name] ON [dbo].[AC_NAM_Actor_Name_Annex]
AFTER INSERT 
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_NAM_ID int not null,
        AC_NAM_AC_ID int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_Checksum varbinary(16) not null,
        primary key (
            AC_NAM_AC_ID asc, 
            AC_NAM_ChangedAt desc,
            AC_NAM_PositedAt desc
        ),
        unique (
            AC_NAM_ID,
            AC_NAM_PositedAt
        )
    );
    INSERT INTO @AC_NAM_Actor_Name (
        AC_NAM_ID,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Checksum,
        AC_NAM_Actor_Name
    )
    SELECT
        i.AC_NAM_ID,
        p.AC_NAM_AC_ID,
        p.AC_NAM_ChangedAt,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Reliability,
        p.AC_NAM_Checksum,
        p.AC_NAM_Actor_Name
    FROM 
        inserted i
    JOIN 
        [dbo].[AC_NAM_Actor_Name_Posit] p
    ON 
        p.AC_NAM_ID = i.AC_NAM_ID; -- the posit has already been created
    INSERT INTO @AC_NAM_Actor_Name (
        AC_NAM_ID,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Checksum,
        AC_NAM_Actor_Name
    )
    SELECT
        p.AC_NAM_ID,
        p.AC_NAM_AC_ID,
        p.AC_NAM_ChangedAt,
        p.AC_NAM_PositedAt,
        p.AC_NAM_Reliability,
        p.AC_NAM_Checksum,
        p.AC_NAM_Actor_Name
    FROM 
        (SELECT DISTINCT AC_NAM_AC_ID FROM @AC_NAM_Actor_Name) i
    JOIN
        [dbo].[AC_NAM_Actor_Name] p
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
                h.AC_NAM_Checksum 
            FROM 
                @AC_NAM_Actor_Name h
            WHERE
                h.AC_NAM_AC_ID = a.AC_NAM_AC_ID
            AND
                h.AC_NAM_ChangedAt < a.AC_NAM_ChangedAt
            ORDER BY 
                h.AC_NAM_ChangedAt DESC,
                h.AC_NAM_PositedAt DESC
        ) pre
        WHERE
            a.AC_NAM_Checksum = pre.AC_NAM_Checksum 
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
