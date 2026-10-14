-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled views make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_DAT_Event_Date instead of INSERT trigger on EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_DAT_Event_Date', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_DAT_Event_Date];
GO
CREATE TRIGGER [dbo].[it_EV_DAT_Event_Date] ON [dbo].[EV_DAT_Event_Date]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_DAT_Event_Date TABLE (
        EV_ID int not null,
        EV_DAT_PositedAt datetime2 not null,
        EV_DAT_Reliability decimal(5,2) not null,
        EV_DAT_Event_Date datetime2 not null,
        EV_DAT_StatementType char(1) not null,
        primary key (
            EV_ID asc, 
            EV_DAT_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_ID,
            i.EV_DAT_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_DAT_Event_Date_Posit] p
            JOIN
                [dbo].[EV_DAT_Event_Date_Annex] a
            ON
                a.EV_DAT_ID = p.EV_DAT_ID
            WHERE
                p.EV_ID = i.EV_ID
            AND
                p.EV_DAT_Event_Date = i.EV_DAT_Event_Date
            AND
                a.EV_DAT_PositedAt = i.EV_DAT_PositedAt
            AND
                a.EV_DAT_Reliability <> i.EV_DAT_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_DAT_Event_Date for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_DAT_Event_Date
    SELECT
        i.EV_ID,
        i.EV_DAT_PositedAt,
        i.EV_DAT_Reliability,
        i.EV_DAT_Event_Date,
        CASE 
            WHEN p.EV_DAT_ID is null 
            THEN 'P' -- new posit
            WHEN a.EV_DAT_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[EV_DAT_Event_Date_Posit] p
    ON
        p.EV_ID = i.EV_ID
    AND
        p.EV_DAT_Event_Date = i.EV_DAT_Event_Date
    LEFT JOIN 
        [dbo].[EV_DAT_Event_Date_Annex] a
    ON 
        a.EV_DAT_ID = p.EV_DAT_ID
    AND
        a.EV_DAT_PositedAt = i.EV_DAT_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_DAT_ID is null OR a.EV_DAT_ID is null);
    INSERT INTO @EV_DAT_Event_Date (
        EV_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date,
        EV_DAT_StatementType 
    )
    SELECT
        i.EV_ID,
        a.EV_DAT_PositedAt,
        a.EV_DAT_Reliability,
        p.EV_DAT_Event_Date,
        'X' -- existing data
    FROM
        (SELECT DISTINCT EV_ID FROM @EV_DAT_Event_Date) i
    JOIN
        [dbo].[EV_DAT_Event_Date_Posit] p
    ON
        p.EV_ID = i.EV_ID
    JOIN 
        [dbo].[EV_DAT_Event_Date_Annex] a
    ON 
        a.EV_DAT_ID = p.EV_DAT_ID;
    DECLARE @retracted TABLE (
        EV_ID int not null,
        EV_DAT_PositedAt datetime2 not null,
        EV_DAT_Reliability decimal(5,2) not null,
        EV_DAT_Event_Date datetime2 not null,
        EV_DAT_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date,
        EV_DAT_StatementType 
    )
    SELECT
        EV_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date,
        EV_DAT_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_DAT_Reliability as previous_EV_DAT_Reliability, 
            fol.EV_DAT_Reliability as following_EV_DAT_Reliability
        FROM
            @EV_DAT_Event_Date a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_DAT_Reliability
            FROM
                @EV_DAT_Event_Date p
            WHERE
                p.EV_ID = a.EV_ID
            AND
                p.EV_DAT_PositedAt < a.EV_DAT_PositedAt
            ORDER BY 
                p.EV_DAT_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_DAT_Reliability
            FROM
                @EV_DAT_Event_Date p
            WHERE
                p.EV_ID = a.EV_ID
            AND
                p.EV_DAT_PositedAt > a.EV_DAT_PositedAt
            ORDER BY 
                p.EV_DAT_PositedAt ASC
        ) fol
        WHERE
            (a.EV_DAT_Reliability = 0 AND isnull(pre.EV_DAT_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.EV_DAT_Reliability = 1 AND fol.EV_DAT_Reliability = 0)
    ) i
    WHERE
        i.EV_DAT_StatementType <> 'X'
    AND (
            (i.EV_DAT_Reliability = 0 AND i.previous_EV_DAT_Reliability = 1)
        OR
            (i.EV_DAT_Reliability = 1 AND i.following_EV_DAT_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @EV_DAT_Event_Date SELECT * FROM @retracted;
    INSERT INTO [dbo].[EV_DAT_Event_Date_Posit] (
        EV_ID,
        EV_DAT_Event_Date
    )
    SELECT
        EV_ID,
        EV_DAT_Event_Date
    FROM
        @EV_DAT_Event_Date
    WHERE
        EV_DAT_StatementType = 'P';
    INSERT INTO [dbo].[EV_DAT_Event_Date_Annex] (
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        p.EV_DAT_ID,
        v.EV_DAT_PositedAt,
        v.EV_DAT_Reliability
    FROM
        @EV_DAT_Event_Date v
    JOIN
        [dbo].[EV_DAT_Event_Date_Posit] p
    ON
        p.EV_ID = v.EV_ID
    AND
        p.EV_DAT_Event_Date = v.EV_DAT_Event_Date
    WHERE
        EV_DAT_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience instead of INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_AUD_Event_Audience', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_AUD_Event_Audience];
GO
CREATE TRIGGER [dbo].[it_EV_AUD_Event_Audience] ON [dbo].[EV_AUD_Event_Audience]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_AUD_Event_Audience TABLE (
        EV_ID int not null,
        EV_AUD_PositedAt datetime2 not null,
        EV_AUD_Reliability decimal(5,2) not null,
        EV_AUD_Event_Audience int not null,
        EV_AUD_StatementType char(1) not null,
        primary key (
            EV_ID asc, 
            EV_AUD_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_ID,
            i.EV_AUD_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_AUD_Event_Audience_Posit] p
            JOIN
                [dbo].[EV_AUD_Event_Audience_Annex] a
            ON
                a.EV_AUD_ID = p.EV_AUD_ID
            WHERE
                p.EV_ID = i.EV_ID
            AND
                p.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
            AND
                a.EV_AUD_PositedAt = i.EV_AUD_PositedAt
            AND
                a.EV_AUD_Reliability <> i.EV_AUD_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_AUD_Event_Audience for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_AUD_Event_Audience
    SELECT
        i.EV_ID,
        i.EV_AUD_PositedAt,
        i.EV_AUD_Reliability,
        i.EV_AUD_Event_Audience,
        CASE 
            WHEN p.EV_AUD_ID is null 
            THEN 'P' -- new posit
            WHEN a.EV_AUD_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[EV_AUD_Event_Audience_Posit] p
    ON
        p.EV_ID = i.EV_ID
    AND
        p.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
    LEFT JOIN 
        [dbo].[EV_AUD_Event_Audience_Annex] a
    ON 
        a.EV_AUD_ID = p.EV_AUD_ID
    AND
        a.EV_AUD_PositedAt = i.EV_AUD_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_AUD_ID is null OR a.EV_AUD_ID is null);
    INSERT INTO @EV_AUD_Event_Audience (
        EV_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience,
        EV_AUD_StatementType 
    )
    SELECT
        i.EV_ID,
        a.EV_AUD_PositedAt,
        a.EV_AUD_Reliability,
        p.EV_AUD_Event_Audience,
        'X' -- existing data
    FROM
        (SELECT DISTINCT EV_ID FROM @EV_AUD_Event_Audience) i
    JOIN
        [dbo].[EV_AUD_Event_Audience_Posit] p
    ON
        p.EV_ID = i.EV_ID
    JOIN 
        [dbo].[EV_AUD_Event_Audience_Annex] a
    ON 
        a.EV_AUD_ID = p.EV_AUD_ID;
    DECLARE @retracted TABLE (
        EV_ID int not null,
        EV_AUD_PositedAt datetime2 not null,
        EV_AUD_Reliability decimal(5,2) not null,
        EV_AUD_Event_Audience int not null,
        EV_AUD_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience,
        EV_AUD_StatementType 
    )
    SELECT
        EV_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience,
        EV_AUD_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_AUD_Reliability as previous_EV_AUD_Reliability, 
            fol.EV_AUD_Reliability as following_EV_AUD_Reliability
        FROM
            @EV_AUD_Event_Audience a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_AUD_Reliability
            FROM
                @EV_AUD_Event_Audience p
            WHERE
                p.EV_ID = a.EV_ID
            AND
                p.EV_AUD_PositedAt < a.EV_AUD_PositedAt
            ORDER BY 
                p.EV_AUD_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_AUD_Reliability
            FROM
                @EV_AUD_Event_Audience p
            WHERE
                p.EV_ID = a.EV_ID
            AND
                p.EV_AUD_PositedAt > a.EV_AUD_PositedAt
            ORDER BY 
                p.EV_AUD_PositedAt ASC
        ) fol
        WHERE
            (a.EV_AUD_Reliability = 0 AND isnull(pre.EV_AUD_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.EV_AUD_Reliability = 1 AND fol.EV_AUD_Reliability = 0)
    ) i
    WHERE
        i.EV_AUD_StatementType <> 'X'
    AND (
            (i.EV_AUD_Reliability = 0 AND i.previous_EV_AUD_Reliability = 1)
        OR
            (i.EV_AUD_Reliability = 1 AND i.following_EV_AUD_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @EV_AUD_Event_Audience SELECT * FROM @retracted;
    INSERT INTO [dbo].[EV_AUD_Event_Audience_Posit] (
        EV_ID,
        EV_AUD_Event_Audience
    )
    SELECT
        EV_ID,
        EV_AUD_Event_Audience
    FROM
        @EV_AUD_Event_Audience
    WHERE
        EV_AUD_StatementType = 'P';
    INSERT INTO [dbo].[EV_AUD_Event_Audience_Annex] (
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        p.EV_AUD_ID,
        v.EV_AUD_PositedAt,
        v.EV_AUD_Reliability
    FROM
        @EV_AUD_Event_Audience v
    JOIN
        [dbo].[EV_AUD_Event_Audience_Posit] p
    ON
        p.EV_ID = v.EV_ID
    AND
        p.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
    WHERE
        EV_AUD_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue instead of INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_REV_Event_Revenue', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_REV_Event_Revenue];
GO
CREATE TRIGGER [dbo].[it_EV_REV_Event_Revenue] ON [dbo].[EV_REV_Event_Revenue]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_REV_Event_Revenue TABLE (
        EV_ID int not null,
        EV_REV_PositedAt datetime2 not null,
        EV_REV_Reliability decimal(5,2) not null,
        EV_REV_Event_Revenue decimal(19,4) not null,
        EV_REV_StatementType char(1) not null,
        primary key (
            EV_ID asc, 
            EV_REV_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_ID,
            i.EV_REV_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_REV_Event_Revenue_Posit] p
            JOIN
                [dbo].[EV_REV_Event_Revenue_Annex] a
            ON
                a.EV_REV_ID = p.EV_REV_ID
            WHERE
                p.EV_ID = i.EV_ID
            AND
                p.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
            AND
                a.EV_REV_PositedAt = i.EV_REV_PositedAt
            AND
                a.EV_REV_Reliability <> i.EV_REV_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_REV_Event_Revenue for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_REV_Event_Revenue
    SELECT
        i.EV_ID,
        i.EV_REV_PositedAt,
        i.EV_REV_Reliability,
        i.EV_REV_Event_Revenue,
        CASE 
            WHEN p.EV_REV_ID is null 
            THEN 'P' -- new posit
            WHEN a.EV_REV_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[EV_REV_Event_Revenue_Posit] p
    ON
        p.EV_ID = i.EV_ID
    AND
        p.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
    LEFT JOIN 
        [dbo].[EV_REV_Event_Revenue_Annex] a
    ON 
        a.EV_REV_ID = p.EV_REV_ID
    AND
        a.EV_REV_PositedAt = i.EV_REV_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_REV_ID is null OR a.EV_REV_ID is null);
    INSERT INTO @EV_REV_Event_Revenue (
        EV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue,
        EV_REV_StatementType 
    )
    SELECT
        i.EV_ID,
        a.EV_REV_PositedAt,
        a.EV_REV_Reliability,
        p.EV_REV_Event_Revenue,
        'X' -- existing data
    FROM
        (SELECT DISTINCT EV_ID FROM @EV_REV_Event_Revenue) i
    JOIN
        [dbo].[EV_REV_Event_Revenue_Posit] p
    ON
        p.EV_ID = i.EV_ID
    JOIN 
        [dbo].[EV_REV_Event_Revenue_Annex] a
    ON 
        a.EV_REV_ID = p.EV_REV_ID;
    DECLARE @retracted TABLE (
        EV_ID int not null,
        EV_REV_PositedAt datetime2 not null,
        EV_REV_Reliability decimal(5,2) not null,
        EV_REV_Event_Revenue decimal(19,4) not null,
        EV_REV_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue,
        EV_REV_StatementType 
    )
    SELECT
        EV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue,
        EV_REV_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_REV_Reliability as previous_EV_REV_Reliability, 
            fol.EV_REV_Reliability as following_EV_REV_Reliability
        FROM
            @EV_REV_Event_Revenue a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_REV_Reliability
            FROM
                @EV_REV_Event_Revenue p
            WHERE
                p.EV_ID = a.EV_ID
            AND
                p.EV_REV_PositedAt < a.EV_REV_PositedAt
            ORDER BY 
                p.EV_REV_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_REV_Reliability
            FROM
                @EV_REV_Event_Revenue p
            WHERE
                p.EV_ID = a.EV_ID
            AND
                p.EV_REV_PositedAt > a.EV_REV_PositedAt
            ORDER BY 
                p.EV_REV_PositedAt ASC
        ) fol
        WHERE
            (a.EV_REV_Reliability = 0 AND isnull(pre.EV_REV_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.EV_REV_Reliability = 1 AND fol.EV_REV_Reliability = 0)
    ) i
    WHERE
        i.EV_REV_StatementType <> 'X'
    AND (
            (i.EV_REV_Reliability = 0 AND i.previous_EV_REV_Reliability = 1)
        OR
            (i.EV_REV_Reliability = 1 AND i.following_EV_REV_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @EV_REV_Event_Revenue SELECT * FROM @retracted;
    INSERT INTO [dbo].[EV_REV_Event_Revenue_Posit] (
        EV_ID,
        EV_REV_Event_Revenue
    )
    SELECT
        EV_ID,
        EV_REV_Event_Revenue
    FROM
        @EV_REV_Event_Revenue
    WHERE
        EV_REV_StatementType = 'P';
    INSERT INTO [dbo].[EV_REV_Event_Revenue_Annex] (
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        p.EV_REV_ID,
        v.EV_REV_PositedAt,
        v.EV_REV_Reliability
    FROM
        @EV_REV_Event_Revenue v
    JOIN
        [dbo].[EV_REV_Event_Revenue_Posit] p
    ON
        p.EV_ID = v.EV_ID
    AND
        p.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
    WHERE
        EV_REV_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_NAM_Stage_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_NAM_Stage_Name];
GO
CREATE TRIGGER [dbo].[it_ST_NAM_Stage_Name] ON [dbo].[ST_NAM_Stage_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_NAM_Stage_Name TABLE (
        ST_ID int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_PositedAt datetime2 not null,
        ST_NAM_Reliability decimal(5,2) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_StatementType char(1) not null,
        primary key (
            ST_ID asc, 
            ST_NAM_ChangedAt desc,
            ST_NAM_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_ID,
            i.ST_NAM_ChangedAt,
            i.ST_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[ST_NAM_Stage_Name_Posit] p
            JOIN
                [dbo].[ST_NAM_Stage_Name_Annex] a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            WHERE
                p.ST_ID = i.ST_ID
            AND
                p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
            AND
                p.ST_NAM_Stage_Name = i.ST_NAM_Stage_Name
            AND
                a.ST_NAM_PositedAt = i.ST_NAM_PositedAt
            AND
                a.ST_NAM_Reliability <> i.ST_NAM_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_NAM_Stage_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @ST_NAM_Stage_Name
    SELECT
        i.ST_ID,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_PositedAt,
        i.ST_NAM_Reliability,
        i.ST_NAM_Stage_Name,
        CASE 
            WHEN p.ST_NAM_ID is null 
            THEN 'P' -- new posit
            WHEN a.ST_NAM_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ST_NAM_Stage_Name_Posit] p
    ON
        p.ST_ID = i.ST_ID
    AND
        p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
    AND
        p.ST_NAM_Stage_Name = i.ST_NAM_Stage_Name
    LEFT JOIN 
        [dbo].[ST_NAM_Stage_Name_Annex] a
    ON 
        a.ST_NAM_ID = p.ST_NAM_ID
    AND
        a.ST_NAM_PositedAt = i.ST_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_NAM_ID is null OR a.ST_NAM_ID is null);
    INSERT INTO @ST_NAM_Stage_Name (
        ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name,
        ST_NAM_StatementType 
    )
    SELECT
        i.ST_ID,
        p.ST_NAM_ChangedAt,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Reliability,
        p.ST_NAM_Stage_Name,
        'X' -- existing data
    FROM
        (SELECT DISTINCT ST_ID FROM @ST_NAM_Stage_Name) i
    JOIN
        [dbo].[ST_NAM_Stage_Name_Posit] p
    ON
        p.ST_ID = i.ST_ID
    JOIN 
        [dbo].[ST_NAM_Stage_Name_Annex] a
    ON 
        a.ST_NAM_ID = p.ST_NAM_ID;
    DECLARE @retracted TABLE (
        ST_ID int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_PositedAt datetime2 not null,
        ST_NAM_Reliability decimal(5,2) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name,
        ST_NAM_StatementType 
    )
    SELECT
        ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name,
        ST_NAM_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.ST_NAM_Reliability as previous_ST_NAM_Reliability, 
            fol.ST_NAM_Reliability as following_ST_NAM_Reliability
        FROM
            @ST_NAM_Stage_Name a
        OUTER APPLY (
            SELECT TOP 1
                p.ST_NAM_Reliability
            FROM
                @ST_NAM_Stage_Name p
            WHERE
                p.ST_ID = a.ST_ID
            AND
                p.ST_NAM_ChangedAt = a.ST_NAM_ChangedAt
            AND
                p.ST_NAM_PositedAt < a.ST_NAM_PositedAt
            ORDER BY 
                p.ST_NAM_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.ST_NAM_Reliability
            FROM
                @ST_NAM_Stage_Name p
            WHERE
                p.ST_ID = a.ST_ID
            AND
                p.ST_NAM_ChangedAt = a.ST_NAM_ChangedAt
            AND
                p.ST_NAM_PositedAt > a.ST_NAM_PositedAt
            ORDER BY 
                p.ST_NAM_PositedAt ASC
        ) fol
        WHERE
            (a.ST_NAM_Reliability = 0 AND isnull(pre.ST_NAM_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.ST_NAM_Reliability = 1 AND fol.ST_NAM_Reliability = 0)
    ) i
    WHERE
        i.ST_NAM_StatementType <> 'X'
    AND (
            (i.ST_NAM_Reliability = 0 AND i.previous_ST_NAM_Reliability = 1)
        OR
            (i.ST_NAM_Reliability = 1 AND i.following_ST_NAM_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @ST_NAM_Stage_Name SELECT * FROM @retracted;
    INSERT INTO [dbo].[ST_NAM_Stage_Name_Posit] (
        ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    SELECT
        ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    FROM
        @ST_NAM_Stage_Name
    WHERE
        ST_NAM_StatementType = 'P';
    INSERT INTO [dbo].[ST_NAM_Stage_Name_Annex] (
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        p.ST_NAM_ID,
        v.ST_NAM_PositedAt,
        v.ST_NAM_Reliability
    FROM
        @ST_NAM_Stage_Name v
    JOIN
        [dbo].[ST_NAM_Stage_Name_Posit] p
    ON
        p.ST_ID = v.ST_ID
    AND
        p.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
    AND
        p.ST_NAM_Stage_Name = v.ST_NAM_Stage_Name
    WHERE
        ST_NAM_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Stage_Location instead of INSERT trigger on ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_LOC_Stage_Location', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_LOC_Stage_Location];
GO
CREATE TRIGGER [dbo].[it_ST_LOC_Stage_Location] ON [dbo].[ST_LOC_Stage_Location]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_LOC_Stage_Location TABLE (
        ST_ID int not null,
        ST_LOC_PositedAt datetime2 not null,
        ST_LOC_Reliability decimal(5,2) not null,
        ST_LOC_Stage_Location geography not null,
        ST_LOC_Checksum varbinary(16) not null,
        ST_LOC_StatementType char(1) not null,
        primary key (
            ST_ID asc, 
            ST_LOC_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_ID,
            i.ST_LOC_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[ST_LOC_Stage_Location_Posit] p
            JOIN
                [dbo].[ST_LOC_Stage_Location_Annex] a
            ON
                a.ST_LOC_ID = p.ST_LOC_ID
            WHERE
                p.ST_ID = i.ST_ID
            AND
                p.ST_LOC_Checksum = dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))) 
            AND
                a.ST_LOC_PositedAt = i.ST_LOC_PositedAt
            AND
                a.ST_LOC_Reliability <> i.ST_LOC_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_LOC_Stage_Location for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @ST_LOC_Stage_Location
    SELECT
        i.ST_ID,
        i.ST_LOC_PositedAt,
        i.ST_LOC_Reliability,
        i.ST_LOC_Stage_Location,
        dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))),
        CASE 
            WHEN p.ST_LOC_ID is null 
            THEN 'P' -- new posit
            WHEN a.ST_LOC_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ST_LOC_Stage_Location_Posit] p
    ON
        p.ST_ID = i.ST_ID
    AND
        p.ST_LOC_Checksum = dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))) 
    LEFT JOIN 
        [dbo].[ST_LOC_Stage_Location_Annex] a
    ON 
        a.ST_LOC_ID = p.ST_LOC_ID
    AND
        a.ST_LOC_PositedAt = i.ST_LOC_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_LOC_ID is null OR a.ST_LOC_ID is null);
    INSERT INTO @ST_LOC_Stage_Location (
        ST_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum,
        ST_LOC_StatementType 
    )
    SELECT
        i.ST_ID,
        a.ST_LOC_PositedAt,
        a.ST_LOC_Reliability,
        p.ST_LOC_Stage_Location,
        p.ST_LOC_Checksum,
        'X' -- existing data
    FROM
        (SELECT DISTINCT ST_ID FROM @ST_LOC_Stage_Location) i
    JOIN
        [dbo].[ST_LOC_Stage_Location_Posit] p
    ON
        p.ST_ID = i.ST_ID
    JOIN 
        [dbo].[ST_LOC_Stage_Location_Annex] a
    ON 
        a.ST_LOC_ID = p.ST_LOC_ID;
    DECLARE @retracted TABLE (
        ST_ID int not null,
        ST_LOC_PositedAt datetime2 not null,
        ST_LOC_Reliability decimal(5,2) not null,
        ST_LOC_Stage_Location geography not null,
        ST_LOC_Checksum varbinary(16) not null,
        ST_LOC_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum,
        ST_LOC_StatementType 
    )
    SELECT
        ST_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum,
        ST_LOC_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.ST_LOC_Reliability as previous_ST_LOC_Reliability, 
            fol.ST_LOC_Reliability as following_ST_LOC_Reliability
        FROM
            @ST_LOC_Stage_Location a
        OUTER APPLY (
            SELECT TOP 1
                p.ST_LOC_Reliability
            FROM
                @ST_LOC_Stage_Location p
            WHERE
                p.ST_ID = a.ST_ID
            AND
                p.ST_LOC_PositedAt < a.ST_LOC_PositedAt
            ORDER BY 
                p.ST_LOC_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.ST_LOC_Reliability
            FROM
                @ST_LOC_Stage_Location p
            WHERE
                p.ST_ID = a.ST_ID
            AND
                p.ST_LOC_PositedAt > a.ST_LOC_PositedAt
            ORDER BY 
                p.ST_LOC_PositedAt ASC
        ) fol
        WHERE
            (a.ST_LOC_Reliability = 0 AND isnull(pre.ST_LOC_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.ST_LOC_Reliability = 1 AND fol.ST_LOC_Reliability = 0)
    ) i
    WHERE
        i.ST_LOC_StatementType <> 'X'
    AND (
            (i.ST_LOC_Reliability = 0 AND i.previous_ST_LOC_Reliability = 1)
        OR
            (i.ST_LOC_Reliability = 1 AND i.following_ST_LOC_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @ST_LOC_Stage_Location SELECT * FROM @retracted;
    INSERT INTO [dbo].[ST_LOC_Stage_Location_Posit] (
        ST_ID,
        ST_LOC_Stage_Location
    )
    SELECT
        ST_ID,
        ST_LOC_Stage_Location
    FROM
        @ST_LOC_Stage_Location
    WHERE
        ST_LOC_StatementType = 'P';
    INSERT INTO [dbo].[ST_LOC_Stage_Location_Annex] (
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        p.ST_LOC_ID,
        v.ST_LOC_PositedAt,
        v.ST_LOC_Reliability
    FROM
        @ST_LOC_Stage_Location v
    JOIN
        [dbo].[ST_LOC_Stage_Location_Posit] p
    ON
        p.ST_ID = v.ST_ID
    AND
        p.ST_LOC_Checksum = v.ST_LOC_Checksum 
    WHERE
        ST_LOC_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average instead of INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_AVG_Stage_Average', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_AVG_Stage_Average];
GO
CREATE TRIGGER [dbo].[it_ST_AVG_Stage_Average] ON [dbo].[ST_AVG_Stage_Average]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_ID int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        UTL_ID tinyint not null, 
        ST_AVG_StatementType char(1) not null,
        primary key (
            ST_ID asc, 
            ST_AVG_ChangedAt desc,
            ST_AVG_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_ID,
            i.ST_AVG_ChangedAt,
            i.ST_AVG_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[ST_AVG_Stage_Average_Posit] p
            JOIN
                [dbo].[ST_AVG_Stage_Average_Annex] a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            WHERE
                p.ST_ID = i.ST_ID
            AND
                p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
            AND
                p.UTL_ID = i.UTL_ID
            AND
                a.ST_AVG_PositedAt = i.ST_AVG_PositedAt
            AND
                a.ST_AVG_Reliability <> i.ST_AVG_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_AVG_Stage_Average for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        i.ST_ID,
        i.ST_AVG_ChangedAt,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Reliability,
        i.UTL_ID,
        CASE 
            WHEN p.ST_AVG_ID is null 
            THEN 'P' -- new posit
            WHEN a.ST_AVG_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_ID = i.ST_ID
    AND
        p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
    AND
        p.UTL_ID = i.UTL_ID
    LEFT JOIN 
        [dbo].[ST_AVG_Stage_Average_Annex] a
    ON 
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = i.ST_AVG_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_AVG_ID is null OR a.ST_AVG_ID is null);
    INSERT INTO @ST_AVG_Stage_Average (
        ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        UTL_ID,
        ST_AVG_StatementType 
    )
    SELECT
        i.ST_ID,
        p.ST_AVG_ChangedAt,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Reliability,
        p.UTL_ID,
        'X' -- existing data
    FROM
        (SELECT DISTINCT ST_ID FROM @ST_AVG_Stage_Average) i
    JOIN
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_ID = i.ST_ID
    JOIN 
        [dbo].[ST_AVG_Stage_Average_Annex] a
    ON 
        a.ST_AVG_ID = p.ST_AVG_ID;
    DECLARE @retracted TABLE (
        ST_ID int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        UTL_ID tinyint not null, 
        ST_AVG_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        UTL_ID,
        ST_AVG_StatementType 
    )
    SELECT
        ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        UTL_ID,
        ST_AVG_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.ST_AVG_Reliability as previous_ST_AVG_Reliability, 
            fol.ST_AVG_Reliability as following_ST_AVG_Reliability
        FROM
            @ST_AVG_Stage_Average a
        OUTER APPLY (
            SELECT TOP 1
                p.ST_AVG_Reliability
            FROM
                @ST_AVG_Stage_Average p
            WHERE
                p.ST_ID = a.ST_ID
            AND
                p.ST_AVG_ChangedAt = a.ST_AVG_ChangedAt
            AND
                p.ST_AVG_PositedAt < a.ST_AVG_PositedAt
            ORDER BY 
                p.ST_AVG_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.ST_AVG_Reliability
            FROM
                @ST_AVG_Stage_Average p
            WHERE
                p.ST_ID = a.ST_ID
            AND
                p.ST_AVG_ChangedAt = a.ST_AVG_ChangedAt
            AND
                p.ST_AVG_PositedAt > a.ST_AVG_PositedAt
            ORDER BY 
                p.ST_AVG_PositedAt ASC
        ) fol
        WHERE
            (a.ST_AVG_Reliability = 0 AND isnull(pre.ST_AVG_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.ST_AVG_Reliability = 1 AND fol.ST_AVG_Reliability = 0)
    ) i
    WHERE
        i.ST_AVG_StatementType <> 'X'
    AND (
            (i.ST_AVG_Reliability = 0 AND i.previous_ST_AVG_Reliability = 1)
        OR
            (i.ST_AVG_Reliability = 1 AND i.following_ST_AVG_Reliability = 0)
        );
    IF EXISTS (
        SELECT TOP 1 
            ST_AVG_StatementType 
        FROM 
            @ST_AVG_Stage_Average
        WHERE 
            ST_AVG_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @restated TABLE (
        ST_ID int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        UTL_ID tinyint not null, 
        ST_AVG_StatementType char(1) not null
    );
    INSERT INTO @restated (
        ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        UTL_ID,
        ST_AVG_StatementType 
    )
    SELECT 
        x.ST_ID,
        x.ST_AVG_ChangedAt,
        CASE 
            WHEN x.previous_ST_AVG_PositedAt < x.ST_AVG_PositedAt THEN x.ST_AVG_PositedAt 
            ELSE x.previous_ST_AVG_PositedAt 
        END,
        0, -- quench the existing restatements
        x.UTL_ID,
        CASE 
            WHEN x.previous_ST_AVG_PositedAt < x.ST_AVG_PositedAt THEN 'D' -- physical delete 
            ELSE 'A' -- logical delete 
        END
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.ST_AVG_PositedAt as previous_ST_AVG_PositedAt
        FROM 
            @ST_AVG_Stage_Average a
        OUTER APPLY (
            SELECT TOP 1
                *
            FROM 
                @ST_AVG_Stage_Average h
            WHERE
                h.ST_ID = a.ST_ID
            AND
                h.ST_AVG_ChangedAt < a.ST_AVG_ChangedAt
            ORDER BY 
                h.ST_AVG_ChangedAt DESC,
                h.ST_AVG_PositedAt DESC
        ) pre
        WHERE
            a.UTL_ID = pre.UTL_ID
    ) x
    WHERE
        x.ST_AVG_StatementType = 'X'; -- quench
    -- add the quenches
    INSERT INTO @ST_AVG_Stage_Average 
    SELECT 
        * 
    FROM (
        DELETE @restated
        OUTPUT deleted.*
        WHERE ST_AVG_StatementType = 'A'
    ) d;
    -- perform any remaining physical deletes 
    DELETE a
    FROM 
        @restated i
    JOIN
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_ID = i.ST_ID
    AND
        p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
    AND
        p.UTL_ID = i.UTL_ID
    JOIN 
        [dbo].[ST_AVG_Stage_Average_Annex] a
    ON 
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = i.ST_AVG_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @ST_AVG_Stage_Average SELECT * FROM @retracted;
    INSERT INTO [dbo].[ST_AVG_Stage_Average_Posit] (
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    )
    SELECT
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    FROM
        @ST_AVG_Stage_Average
    WHERE
        ST_AVG_StatementType = 'P';
    INSERT INTO [dbo].[ST_AVG_Stage_Average_Annex] (
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        p.ST_AVG_ID,
        v.ST_AVG_PositedAt,
        v.ST_AVG_Reliability
    FROM
        @ST_AVG_Stage_Average v
    JOIN
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_ID = v.ST_ID
    AND
        p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
    AND
        p.UTL_ID = v.UTL_ID
    WHERE
        ST_AVG_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum instead of INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_MIN_Stage_Minimum', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_MIN_Stage_Minimum];
GO
CREATE TRIGGER [dbo].[it_ST_MIN_Stage_Minimum] ON [dbo].[ST_MIN_Stage_Minimum]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_MIN_Stage_Minimum TABLE (
        ST_ID int not null,
        ST_MIN_PositedAt datetime2 not null,
        ST_MIN_Reliability decimal(5,2) not null,
        UTL_ID tinyint not null, 
        ST_MIN_StatementType char(1) not null,
        primary key (
            ST_ID asc, 
            ST_MIN_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_ID,
            i.ST_MIN_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[ST_MIN_Stage_Minimum_Posit] p
            JOIN
                [dbo].[ST_MIN_Stage_Minimum_Annex] a
            ON
                a.ST_MIN_ID = p.ST_MIN_ID
            WHERE
                p.ST_ID = i.ST_ID
            AND
                p.UTL_ID = i.UTL_ID
            AND
                a.ST_MIN_PositedAt = i.ST_MIN_PositedAt
            AND
                a.ST_MIN_Reliability <> i.ST_MIN_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_MIN_Stage_Minimum for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @ST_MIN_Stage_Minimum
    SELECT
        i.ST_ID,
        i.ST_MIN_PositedAt,
        i.ST_MIN_Reliability,
        i.UTL_ID,
        CASE 
            WHEN p.ST_MIN_ID is null 
            THEN 'P' -- new posit
            WHEN a.ST_MIN_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    ON
        p.ST_ID = i.ST_ID
    AND
        p.UTL_ID = i.UTL_ID
    LEFT JOIN 
        [dbo].[ST_MIN_Stage_Minimum_Annex] a
    ON 
        a.ST_MIN_ID = p.ST_MIN_ID
    AND
        a.ST_MIN_PositedAt = i.ST_MIN_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_MIN_ID is null OR a.ST_MIN_ID is null);
    INSERT INTO @ST_MIN_Stage_Minimum (
        ST_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        UTL_ID,
        ST_MIN_StatementType 
    )
    SELECT
        i.ST_ID,
        a.ST_MIN_PositedAt,
        a.ST_MIN_Reliability,
        p.UTL_ID,
        'X' -- existing data
    FROM
        (SELECT DISTINCT ST_ID FROM @ST_MIN_Stage_Minimum) i
    JOIN
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    ON
        p.ST_ID = i.ST_ID
    JOIN 
        [dbo].[ST_MIN_Stage_Minimum_Annex] a
    ON 
        a.ST_MIN_ID = p.ST_MIN_ID;
    DECLARE @retracted TABLE (
        ST_ID int not null,
        ST_MIN_PositedAt datetime2 not null,
        ST_MIN_Reliability decimal(5,2) not null,
        UTL_ID tinyint not null, 
        ST_MIN_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        UTL_ID,
        ST_MIN_StatementType 
    )
    SELECT
        ST_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        UTL_ID,
        ST_MIN_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.ST_MIN_Reliability as previous_ST_MIN_Reliability, 
            fol.ST_MIN_Reliability as following_ST_MIN_Reliability
        FROM
            @ST_MIN_Stage_Minimum a
        OUTER APPLY (
            SELECT TOP 1
                p.ST_MIN_Reliability
            FROM
                @ST_MIN_Stage_Minimum p
            WHERE
                p.ST_ID = a.ST_ID
            AND
                p.ST_MIN_PositedAt < a.ST_MIN_PositedAt
            ORDER BY 
                p.ST_MIN_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.ST_MIN_Reliability
            FROM
                @ST_MIN_Stage_Minimum p
            WHERE
                p.ST_ID = a.ST_ID
            AND
                p.ST_MIN_PositedAt > a.ST_MIN_PositedAt
            ORDER BY 
                p.ST_MIN_PositedAt ASC
        ) fol
        WHERE
            (a.ST_MIN_Reliability = 0 AND isnull(pre.ST_MIN_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.ST_MIN_Reliability = 1 AND fol.ST_MIN_Reliability = 0)
    ) i
    WHERE
        i.ST_MIN_StatementType <> 'X'
    AND (
            (i.ST_MIN_Reliability = 0 AND i.previous_ST_MIN_Reliability = 1)
        OR
            (i.ST_MIN_Reliability = 1 AND i.following_ST_MIN_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @ST_MIN_Stage_Minimum SELECT * FROM @retracted;
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Posit] (
        ST_ID,
        UTL_ID
    )
    SELECT
        ST_ID,
        UTL_ID
    FROM
        @ST_MIN_Stage_Minimum
    WHERE
        ST_MIN_StatementType = 'P';
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Annex] (
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        p.ST_MIN_ID,
        v.ST_MIN_PositedAt,
        v.ST_MIN_Reliability
    FROM
        @ST_MIN_Stage_Minimum v
    JOIN
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    ON
        p.ST_ID = v.ST_ID
    AND
        p.UTL_ID = v.UTL_ID
    WHERE
        ST_MIN_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name instead of INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [dbo].[it_AC_NAM_Actor_Name] ON [dbo].[AC_NAM_Actor_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_ID int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_StatementType char(1) not null,
        primary key (
            AC_ID asc, 
            AC_NAM_ChangedAt desc,
            AC_NAM_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID,
            i.AC_NAM_ChangedAt,
            i.AC_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[AC_NAM_Actor_Name_Posit] p
            JOIN
                [dbo].[AC_NAM_Actor_Name_Annex] a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            WHERE
                p.AC_ID = i.AC_ID
            AND
                p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
            AND
                p.AC_NAM_Actor_Name = i.AC_NAM_Actor_Name
            AND
                a.AC_NAM_PositedAt = i.AC_NAM_PositedAt
            AND
                a.AC_NAM_Reliability <> i.AC_NAM_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_NAM_Actor_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @AC_NAM_Actor_Name
    SELECT
        i.AC_ID,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Reliability,
        i.AC_NAM_Actor_Name,
        CASE 
            WHEN p.AC_NAM_ID is null 
            THEN 'P' -- new posit
            WHEN a.AC_NAM_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_ID = i.AC_ID
    AND
        p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
    AND
        p.AC_NAM_Actor_Name = i.AC_NAM_Actor_Name
    LEFT JOIN 
        [dbo].[AC_NAM_Actor_Name_Annex] a
    ON 
        a.AC_NAM_ID = p.AC_NAM_ID
    AND
        a.AC_NAM_PositedAt = i.AC_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_NAM_ID is null OR a.AC_NAM_ID is null);
    INSERT INTO @AC_NAM_Actor_Name (
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name,
        AC_NAM_StatementType 
    )
    SELECT
        i.AC_ID,
        p.AC_NAM_ChangedAt,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Reliability,
        p.AC_NAM_Actor_Name,
        'X' -- existing data
    FROM
        (SELECT DISTINCT AC_ID FROM @AC_NAM_Actor_Name) i
    JOIN
        [dbo].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_ID = i.AC_ID
    JOIN 
        [dbo].[AC_NAM_Actor_Name_Annex] a
    ON 
        a.AC_NAM_ID = p.AC_NAM_ID;
    DECLARE @retracted TABLE (
        AC_ID int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name,
        AC_NAM_StatementType 
    )
    SELECT
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name,
        AC_NAM_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.AC_NAM_Reliability as previous_AC_NAM_Reliability, 
            fol.AC_NAM_Reliability as following_AC_NAM_Reliability
        FROM
            @AC_NAM_Actor_Name a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_NAM_Reliability
            FROM
                @AC_NAM_Actor_Name p
            WHERE
                p.AC_ID = a.AC_ID
            AND
                p.AC_NAM_ChangedAt = a.AC_NAM_ChangedAt
            AND
                p.AC_NAM_PositedAt < a.AC_NAM_PositedAt
            ORDER BY 
                p.AC_NAM_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_NAM_Reliability
            FROM
                @AC_NAM_Actor_Name p
            WHERE
                p.AC_ID = a.AC_ID
            AND
                p.AC_NAM_ChangedAt = a.AC_NAM_ChangedAt
            AND
                p.AC_NAM_PositedAt > a.AC_NAM_PositedAt
            ORDER BY 
                p.AC_NAM_PositedAt ASC
        ) fol
        WHERE
            (a.AC_NAM_Reliability = 0 AND isnull(pre.AC_NAM_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.AC_NAM_Reliability = 1 AND fol.AC_NAM_Reliability = 0)
    ) i
    WHERE
        i.AC_NAM_StatementType <> 'X'
    AND (
            (i.AC_NAM_Reliability = 0 AND i.previous_AC_NAM_Reliability = 1)
        OR
            (i.AC_NAM_Reliability = 1 AND i.following_AC_NAM_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @AC_NAM_Actor_Name SELECT * FROM @retracted;
    INSERT INTO [dbo].[AC_NAM_Actor_Name_Posit] (
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    FROM
        @AC_NAM_Actor_Name
    WHERE
        AC_NAM_StatementType = 'P';
    INSERT INTO [dbo].[AC_NAM_Actor_Name_Annex] (
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        p.AC_NAM_ID,
        v.AC_NAM_PositedAt,
        v.AC_NAM_Reliability
    FROM
        @AC_NAM_Actor_Name v
    JOIN
        [dbo].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_ID = v.AC_ID
    AND
        p.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
    AND
        p.AC_NAM_Actor_Name = v.AC_NAM_Actor_Name
    WHERE
        AC_NAM_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Actor_Gender instead of INSERT trigger on AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_GEN_Actor_Gender', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_GEN_Actor_Gender];
GO
CREATE TRIGGER [dbo].[it_AC_GEN_Actor_Gender] ON [dbo].[AC_GEN_Actor_Gender]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AC_GEN_Actor_Gender TABLE (
        AC_ID int not null,
        AC_GEN_PositedAt datetime2 not null,
        AC_GEN_Reliability decimal(5,2) not null,
        GEN_ID tinyint not null, 
        AC_GEN_StatementType char(1) not null,
        primary key (
            AC_ID asc, 
            AC_GEN_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID,
            i.AC_GEN_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[AC_GEN_Actor_Gender_Posit] p
            JOIN
                [dbo].[AC_GEN_Actor_Gender_Annex] a
            ON
                a.AC_GEN_ID = p.AC_GEN_ID
            WHERE
                p.AC_ID = i.AC_ID
            AND
                p.GEN_ID = i.GEN_ID
            AND
                a.AC_GEN_PositedAt = i.AC_GEN_PositedAt
            AND
                a.AC_GEN_Reliability <> i.AC_GEN_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_GEN_Actor_Gender for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @AC_GEN_Actor_Gender
    SELECT
        i.AC_ID,
        i.AC_GEN_PositedAt,
        i.AC_GEN_Reliability,
        i.GEN_ID,
        CASE 
            WHEN p.AC_GEN_ID is null 
            THEN 'P' -- new posit
            WHEN a.AC_GEN_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    ON
        p.AC_ID = i.AC_ID
    AND
        p.GEN_ID = i.GEN_ID
    LEFT JOIN 
        [dbo].[AC_GEN_Actor_Gender_Annex] a
    ON 
        a.AC_GEN_ID = p.AC_GEN_ID
    AND
        a.AC_GEN_PositedAt = i.AC_GEN_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_GEN_ID is null OR a.AC_GEN_ID is null);
    INSERT INTO @AC_GEN_Actor_Gender (
        AC_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        GEN_ID,
        AC_GEN_StatementType 
    )
    SELECT
        i.AC_ID,
        a.AC_GEN_PositedAt,
        a.AC_GEN_Reliability,
        p.GEN_ID,
        'X' -- existing data
    FROM
        (SELECT DISTINCT AC_ID FROM @AC_GEN_Actor_Gender) i
    JOIN
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    ON
        p.AC_ID = i.AC_ID
    JOIN 
        [dbo].[AC_GEN_Actor_Gender_Annex] a
    ON 
        a.AC_GEN_ID = p.AC_GEN_ID;
    DECLARE @retracted TABLE (
        AC_ID int not null,
        AC_GEN_PositedAt datetime2 not null,
        AC_GEN_Reliability decimal(5,2) not null,
        GEN_ID tinyint not null, 
        AC_GEN_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        AC_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        GEN_ID,
        AC_GEN_StatementType 
    )
    SELECT
        AC_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        GEN_ID,
        AC_GEN_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.AC_GEN_Reliability as previous_AC_GEN_Reliability, 
            fol.AC_GEN_Reliability as following_AC_GEN_Reliability
        FROM
            @AC_GEN_Actor_Gender a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_GEN_Reliability
            FROM
                @AC_GEN_Actor_Gender p
            WHERE
                p.AC_ID = a.AC_ID
            AND
                p.AC_GEN_PositedAt < a.AC_GEN_PositedAt
            ORDER BY 
                p.AC_GEN_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_GEN_Reliability
            FROM
                @AC_GEN_Actor_Gender p
            WHERE
                p.AC_ID = a.AC_ID
            AND
                p.AC_GEN_PositedAt > a.AC_GEN_PositedAt
            ORDER BY 
                p.AC_GEN_PositedAt ASC
        ) fol
        WHERE
            (a.AC_GEN_Reliability = 0 AND isnull(pre.AC_GEN_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.AC_GEN_Reliability = 1 AND fol.AC_GEN_Reliability = 0)
    ) i
    WHERE
        i.AC_GEN_StatementType <> 'X'
    AND (
            (i.AC_GEN_Reliability = 0 AND i.previous_AC_GEN_Reliability = 1)
        OR
            (i.AC_GEN_Reliability = 1 AND i.following_AC_GEN_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @AC_GEN_Actor_Gender SELECT * FROM @retracted;
    INSERT INTO [dbo].[AC_GEN_Actor_Gender_Posit] (
        AC_ID,
        GEN_ID
    )
    SELECT
        AC_ID,
        GEN_ID
    FROM
        @AC_GEN_Actor_Gender
    WHERE
        AC_GEN_StatementType = 'P';
    INSERT INTO [dbo].[AC_GEN_Actor_Gender_Annex] (
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        p.AC_GEN_ID,
        v.AC_GEN_PositedAt,
        v.AC_GEN_Reliability
    FROM
        @AC_GEN_Actor_Gender v
    JOIN
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    ON
        p.AC_ID = v.AC_ID
    AND
        p.GEN_ID = v.GEN_ID
    WHERE
        AC_GEN_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel instead of INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_PLV_Actor_ProfessionalLevel', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_PLV_Actor_ProfessionalLevel];
GO
CREATE TRIGGER [dbo].[it_AC_PLV_Actor_ProfessionalLevel] ON [dbo].[AC_PLV_Actor_ProfessionalLevel]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AC_PLV_Actor_ProfessionalLevel TABLE (
        AC_ID int not null,
        AC_PLV_ChangedAt datetime2 not null,
        AC_PLV_PositedAt datetime2 not null,
        AC_PLV_Reliability decimal(5,2) not null,
        PLV_ID tinyint not null, 
        AC_PLV_StatementType char(1) not null,
        primary key (
            AC_ID asc, 
            AC_PLV_ChangedAt desc,
            AC_PLV_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID,
            i.AC_PLV_ChangedAt,
            i.AC_PLV_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
            JOIN
                [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            WHERE
                p.AC_ID = i.AC_ID
            AND
                p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
            AND
                p.PLV_ID = i.PLV_ID
            AND
                a.AC_PLV_PositedAt = i.AC_PLV_PositedAt
            AND
                a.AC_PLV_Reliability <> i.AC_PLV_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel
    SELECT
        i.AC_ID,
        i.AC_PLV_ChangedAt,
        i.AC_PLV_PositedAt,
        i.AC_PLV_Reliability,
        i.PLV_ID,
        CASE 
            WHEN p.AC_PLV_ID is null 
            THEN 'P' -- new posit
            WHEN a.AC_PLV_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        p.AC_ID = i.AC_ID
    AND
        p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
    AND
        p.PLV_ID = i.PLV_ID
    LEFT JOIN 
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
    ON 
        a.AC_PLV_ID = p.AC_PLV_ID
    AND
        a.AC_PLV_PositedAt = i.AC_PLV_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_PLV_ID is null OR a.AC_PLV_ID is null);
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel (
        AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        PLV_ID,
        AC_PLV_StatementType 
    )
    SELECT
        i.AC_ID,
        p.AC_PLV_ChangedAt,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Reliability,
        p.PLV_ID,
        'X' -- existing data
    FROM
        (SELECT DISTINCT AC_ID FROM @AC_PLV_Actor_ProfessionalLevel) i
    JOIN
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        p.AC_ID = i.AC_ID
    JOIN 
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
    ON 
        a.AC_PLV_ID = p.AC_PLV_ID;
    DECLARE @retracted TABLE (
        AC_ID int not null,
        AC_PLV_ChangedAt datetime2 not null,
        AC_PLV_PositedAt datetime2 not null,
        AC_PLV_Reliability decimal(5,2) not null,
        PLV_ID tinyint not null, 
        AC_PLV_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        PLV_ID,
        AC_PLV_StatementType 
    )
    SELECT
        AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        PLV_ID,
        AC_PLV_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.AC_PLV_Reliability as previous_AC_PLV_Reliability, 
            fol.AC_PLV_Reliability as following_AC_PLV_Reliability
        FROM
            @AC_PLV_Actor_ProfessionalLevel a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_PLV_Reliability
            FROM
                @AC_PLV_Actor_ProfessionalLevel p
            WHERE
                p.AC_ID = a.AC_ID
            AND
                p.AC_PLV_ChangedAt = a.AC_PLV_ChangedAt
            AND
                p.AC_PLV_PositedAt < a.AC_PLV_PositedAt
            ORDER BY 
                p.AC_PLV_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_PLV_Reliability
            FROM
                @AC_PLV_Actor_ProfessionalLevel p
            WHERE
                p.AC_ID = a.AC_ID
            AND
                p.AC_PLV_ChangedAt = a.AC_PLV_ChangedAt
            AND
                p.AC_PLV_PositedAt > a.AC_PLV_PositedAt
            ORDER BY 
                p.AC_PLV_PositedAt ASC
        ) fol
        WHERE
            (a.AC_PLV_Reliability = 0 AND isnull(pre.AC_PLV_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.AC_PLV_Reliability = 1 AND fol.AC_PLV_Reliability = 0)
    ) i
    WHERE
        i.AC_PLV_StatementType <> 'X'
    AND (
            (i.AC_PLV_Reliability = 0 AND i.previous_AC_PLV_Reliability = 1)
        OR
            (i.AC_PLV_Reliability = 1 AND i.following_AC_PLV_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel SELECT * FROM @retracted;
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] (
        AC_ID,
        AC_PLV_ChangedAt,
        PLV_ID
    )
    SELECT
        AC_ID,
        AC_PLV_ChangedAt,
        PLV_ID
    FROM
        @AC_PLV_Actor_ProfessionalLevel
    WHERE
        AC_PLV_StatementType = 'P';
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] (
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        p.AC_PLV_ID,
        v.AC_PLV_PositedAt,
        v.AC_PLV_Reliability
    FROM
        @AC_PLV_Actor_ProfessionalLevel v
    JOIN
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        p.AC_ID = v.AC_ID
    AND
        p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
    AND
        p.PLV_ID = v.PLV_ID
    WHERE
        AC_PLV_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Program_Name instead of INSERT trigger on PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_PR_NAM_Program_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PR_NAM_Program_Name];
GO
CREATE TRIGGER [dbo].[it_PR_NAM_Program_Name] ON [dbo].[PR_NAM_Program_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PR_NAM_Program_Name TABLE (
        PR_ID int not null,
        PR_NAM_PositedAt datetime2 not null,
        PR_NAM_Reliability decimal(5,2) not null,
        PR_NAM_Program_Name nvarchar(42) not null,
        PR_NAM_StatementType char(1) not null,
        primary key (
            PR_ID asc, 
            PR_NAM_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_ID,
            i.PR_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[PR_NAM_Program_Name_Posit] p
            JOIN
                [dbo].[PR_NAM_Program_Name_Annex] a
            ON
                a.PR_NAM_ID = p.PR_NAM_ID
            WHERE
                p.PR_ID = i.PR_ID
            AND
                p.PR_NAM_Program_Name = i.PR_NAM_Program_Name
            AND
                a.PR_NAM_PositedAt = i.PR_NAM_PositedAt
            AND
                a.PR_NAM_Reliability <> i.PR_NAM_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in PR_NAM_Program_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @PR_NAM_Program_Name
    SELECT
        i.PR_ID,
        i.PR_NAM_PositedAt,
        i.PR_NAM_Reliability,
        i.PR_NAM_Program_Name,
        CASE 
            WHEN p.PR_NAM_ID is null 
            THEN 'P' -- new posit
            WHEN a.PR_NAM_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[PR_NAM_Program_Name_Posit] p
    ON
        p.PR_ID = i.PR_ID
    AND
        p.PR_NAM_Program_Name = i.PR_NAM_Program_Name
    LEFT JOIN 
        [dbo].[PR_NAM_Program_Name_Annex] a
    ON 
        a.PR_NAM_ID = p.PR_NAM_ID
    AND
        a.PR_NAM_PositedAt = i.PR_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.PR_NAM_ID is null OR a.PR_NAM_ID is null);
    INSERT INTO @PR_NAM_Program_Name (
        PR_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name,
        PR_NAM_StatementType 
    )
    SELECT
        i.PR_ID,
        a.PR_NAM_PositedAt,
        a.PR_NAM_Reliability,
        p.PR_NAM_Program_Name,
        'X' -- existing data
    FROM
        (SELECT DISTINCT PR_ID FROM @PR_NAM_Program_Name) i
    JOIN
        [dbo].[PR_NAM_Program_Name_Posit] p
    ON
        p.PR_ID = i.PR_ID
    JOIN 
        [dbo].[PR_NAM_Program_Name_Annex] a
    ON 
        a.PR_NAM_ID = p.PR_NAM_ID;
    DECLARE @retracted TABLE (
        PR_ID int not null,
        PR_NAM_PositedAt datetime2 not null,
        PR_NAM_Reliability decimal(5,2) not null,
        PR_NAM_Program_Name nvarchar(42) not null,
        PR_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        PR_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name,
        PR_NAM_StatementType 
    )
    SELECT
        PR_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name,
        PR_NAM_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.PR_NAM_Reliability as previous_PR_NAM_Reliability, 
            fol.PR_NAM_Reliability as following_PR_NAM_Reliability
        FROM
            @PR_NAM_Program_Name a
        OUTER APPLY (
            SELECT TOP 1
                p.PR_NAM_Reliability
            FROM
                @PR_NAM_Program_Name p
            WHERE
                p.PR_ID = a.PR_ID
            AND
                p.PR_NAM_PositedAt < a.PR_NAM_PositedAt
            ORDER BY 
                p.PR_NAM_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.PR_NAM_Reliability
            FROM
                @PR_NAM_Program_Name p
            WHERE
                p.PR_ID = a.PR_ID
            AND
                p.PR_NAM_PositedAt > a.PR_NAM_PositedAt
            ORDER BY 
                p.PR_NAM_PositedAt ASC
        ) fol
        WHERE
            (a.PR_NAM_Reliability = 0 AND isnull(pre.PR_NAM_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.PR_NAM_Reliability = 1 AND fol.PR_NAM_Reliability = 0)
    ) i
    WHERE
        i.PR_NAM_StatementType <> 'X'
    AND (
            (i.PR_NAM_Reliability = 0 AND i.previous_PR_NAM_Reliability = 1)
        OR
            (i.PR_NAM_Reliability = 1 AND i.following_PR_NAM_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @PR_NAM_Program_Name SELECT * FROM @retracted;
    INSERT INTO [dbo].[PR_NAM_Program_Name_Posit] (
        PR_ID,
        PR_NAM_Program_Name
    )
    SELECT
        PR_ID,
        PR_NAM_Program_Name
    FROM
        @PR_NAM_Program_Name
    WHERE
        PR_NAM_StatementType = 'P';
    INSERT INTO [dbo].[PR_NAM_Program_Name_Annex] (
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        p.PR_NAM_ID,
        v.PR_NAM_PositedAt,
        v.PR_NAM_Reliability
    FROM
        @PR_NAM_Program_Name v
    JOIN
        [dbo].[PR_NAM_Program_Name_Posit] p
    ON
        p.PR_ID = v.PR_ID
    AND
        p.PR_NAM_Program_Name = v.PR_NAM_Program_Name
    WHERE
        PR_NAM_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Program_Length instead of INSERT trigger on PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_PR_LEN_Program_Length', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PR_LEN_Program_Length];
GO
CREATE TRIGGER [dbo].[it_PR_LEN_Program_Length] ON [dbo].[PR_LEN_Program_Length]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PR_LEN_Program_Length TABLE (
        PR_ID int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null,
        primary key (
            PR_ID asc, 
            PR_LEN_ChangedAt desc,
            PR_LEN_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_ID,
            i.PR_LEN_ChangedAt,
            i.PR_LEN_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[PR_LEN_Program_Length_Posit] p
            JOIN
                [dbo].[PR_LEN_Program_Length_Annex] a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            WHERE
                p.PR_ID = i.PR_ID
            AND
                p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
            AND
                p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
            AND
                a.PR_LEN_PositedAt = i.PR_LEN_PositedAt
            AND
                a.PR_LEN_Reliability <> i.PR_LEN_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in PR_LEN_Program_Length for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @PR_LEN_Program_Length
    SELECT
        i.PR_ID,
        i.PR_LEN_ChangedAt,
        i.PR_LEN_PositedAt,
        i.PR_LEN_Reliability,
        i.PR_LEN_Program_Length,
        CASE 
            WHEN p.PR_LEN_ID is null 
            THEN 'P' -- new posit
            WHEN a.PR_LEN_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_ID = i.PR_ID
    AND
        p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
    AND
        p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
    LEFT JOIN 
        [dbo].[PR_LEN_Program_Length_Annex] a
    ON 
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = i.PR_LEN_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.PR_LEN_ID is null OR a.PR_LEN_ID is null);
    INSERT INTO @PR_LEN_Program_Length (
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType 
    )
    SELECT
        i.PR_ID,
        p.PR_LEN_ChangedAt,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Reliability,
        p.PR_LEN_Program_Length,
        'X' -- existing data
    FROM
        (SELECT DISTINCT PR_ID FROM @PR_LEN_Program_Length) i
    JOIN
        [dbo].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_ID = i.PR_ID
    JOIN 
        [dbo].[PR_LEN_Program_Length_Annex] a
    ON 
        a.PR_LEN_ID = p.PR_LEN_ID;
    DECLARE @retracted TABLE (
        PR_ID int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType 
    )
    SELECT
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.PR_LEN_Reliability as previous_PR_LEN_Reliability, 
            fol.PR_LEN_Reliability as following_PR_LEN_Reliability
        FROM
            @PR_LEN_Program_Length a
        OUTER APPLY (
            SELECT TOP 1
                p.PR_LEN_Reliability
            FROM
                @PR_LEN_Program_Length p
            WHERE
                p.PR_ID = a.PR_ID
            AND
                p.PR_LEN_ChangedAt = a.PR_LEN_ChangedAt
            AND
                p.PR_LEN_PositedAt < a.PR_LEN_PositedAt
            ORDER BY 
                p.PR_LEN_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.PR_LEN_Reliability
            FROM
                @PR_LEN_Program_Length p
            WHERE
                p.PR_ID = a.PR_ID
            AND
                p.PR_LEN_ChangedAt = a.PR_LEN_ChangedAt
            AND
                p.PR_LEN_PositedAt > a.PR_LEN_PositedAt
            ORDER BY 
                p.PR_LEN_PositedAt ASC
        ) fol
        WHERE
            (a.PR_LEN_Reliability = 0 AND isnull(pre.PR_LEN_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.PR_LEN_Reliability = 1 AND fol.PR_LEN_Reliability = 0)
    ) i
    WHERE
        i.PR_LEN_StatementType <> 'X'
    AND (
            (i.PR_LEN_Reliability = 0 AND i.previous_PR_LEN_Reliability = 1)
        OR
            (i.PR_LEN_Reliability = 1 AND i.following_PR_LEN_Reliability = 0)
        );
    IF EXISTS (
        SELECT TOP 1 
            PR_LEN_StatementType 
        FROM 
            @PR_LEN_Program_Length
        WHERE 
            PR_LEN_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @restated TABLE (
        PR_ID int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null
    );
    INSERT INTO @restated (
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType 
    )
    SELECT 
        x.PR_ID,
        x.PR_LEN_ChangedAt,
        CASE 
            WHEN x.previous_PR_LEN_PositedAt < x.PR_LEN_PositedAt THEN x.PR_LEN_PositedAt 
            ELSE x.previous_PR_LEN_PositedAt 
        END,
        0, -- quench the existing restatements
        x.PR_LEN_Program_Length,
        CASE 
            WHEN x.previous_PR_LEN_PositedAt < x.PR_LEN_PositedAt THEN 'D' -- physical delete 
            ELSE 'A' -- logical delete 
        END
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.PR_LEN_PositedAt as previous_PR_LEN_PositedAt
        FROM 
            @PR_LEN_Program_Length a
        OUTER APPLY (
            SELECT TOP 1
                *
            FROM 
                @PR_LEN_Program_Length h
            WHERE
                h.PR_ID = a.PR_ID
            AND
                h.PR_LEN_ChangedAt < a.PR_LEN_ChangedAt
            ORDER BY 
                h.PR_LEN_ChangedAt DESC,
                h.PR_LEN_PositedAt DESC
        ) pre
        WHERE
            a.PR_LEN_Program_Length = pre.PR_LEN_Program_Length
    ) x
    WHERE
        x.PR_LEN_StatementType = 'X'; -- quench
    -- add the quenches
    INSERT INTO @PR_LEN_Program_Length 
    SELECT 
        * 
    FROM (
        DELETE @restated
        OUTPUT deleted.*
        WHERE PR_LEN_StatementType = 'A'
    ) d;
    -- perform any remaining physical deletes 
    DELETE a
    FROM 
        @restated i
    JOIN
        [dbo].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_ID = i.PR_ID
    AND
        p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
    AND
        p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
    JOIN 
        [dbo].[PR_LEN_Program_Length_Annex] a
    ON 
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = i.PR_LEN_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @PR_LEN_Program_Length SELECT * FROM @retracted;
    INSERT INTO [dbo].[PR_LEN_Program_Length_Posit] (
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    SELECT
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    FROM
        @PR_LEN_Program_Length
    WHERE
        PR_LEN_StatementType = 'P';
    INSERT INTO [dbo].[PR_LEN_Program_Length_Annex] (
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        p.PR_LEN_ID,
        v.PR_LEN_PositedAt,
        v.PR_LEN_Reliability
    FROM
        @PR_LEN_Program_Length v
    JOIN
        [dbo].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_ID = v.PR_ID
    AND
        p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
    AND
        p.PR_LEN_Program_Length = v.PR_LEN_Program_Length
    WHERE
        PR_LEN_StatementType in ('P', 'A');
END
GO
