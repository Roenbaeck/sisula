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
IF Object_ID('attributes.it_EV_DAT_Event_Date', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_DAT_Event_Date];
GO
CREATE TRIGGER [attributes].[it_EV_DAT_Event_Date] ON [attributes].[EV_DAT_Event_Date]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_DAT_Event_Date TABLE (
        EV_DAT_EV_ID numeric(12,0) not null,
        Metadata_EV_DAT int not null,
        EV_DAT_PositedAt datetime2 not null,
        EV_DAT_Reliability decimal(5,2) not null,
        EV_DAT_Event_Date datetime2 not null,
        EV_DAT_StatementType char(1) not null,
        primary key (
            EV_DAT_EV_ID asc, 
            EV_DAT_PositedAt desc
        )
    );
    INSERT INTO @EV_DAT_Event_Date
    SELECT
        i.EV_DAT_EV_ID,
        i.Metadata_EV_DAT,
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
        [attributes].[EV_DAT_Event_Date_Posit] p
    ON
        p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
    AND
        p.EV_DAT_Event_Date = i.EV_DAT_Event_Date
    LEFT JOIN 
        [attributes].[EV_DAT_Event_Date_Annex] a
    ON 
        a.EV_DAT_ID = p.EV_DAT_ID
    AND
        a.EV_DAT_PositedAt = i.EV_DAT_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_DAT_ID is null OR a.EV_DAT_ID is null);
    INSERT INTO @EV_DAT_Event_Date (
        EV_DAT_EV_ID,
        Metadata_EV_DAT,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date,
        EV_DAT_StatementType 
    )
    SELECT
        i.EV_DAT_EV_ID,
        a.Metadata_EV_DAT,
        a.EV_DAT_PositedAt,
        a.EV_DAT_Reliability,
        p.EV_DAT_Event_Date,
        'X' -- existing data
    FROM
        (SELECT DISTINCT EV_DAT_EV_ID FROM @EV_DAT_Event_Date) i
    JOIN
        [attributes].[EV_DAT_Event_Date_Posit] p
    ON
        p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
    JOIN 
        [attributes].[EV_DAT_Event_Date_Annex] a
    ON 
        a.EV_DAT_ID = p.EV_DAT_ID;
    DECLARE @retracted TABLE (
        EV_DAT_EV_ID numeric(12,0) not null,
        Metadata_EV_DAT int not null,
        EV_DAT_PositedAt datetime2 not null,
        EV_DAT_Reliability decimal(5,2) not null,
        EV_DAT_Event_Date datetime2 not null,
        EV_DAT_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_DAT_EV_ID,
        Metadata_EV_DAT,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date,
        EV_DAT_StatementType 
    )
    SELECT
        EV_DAT_EV_ID,
        Metadata_EV_DAT,
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
                p.EV_DAT_EV_ID = a.EV_DAT_EV_ID
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
                p.EV_DAT_EV_ID = a.EV_DAT_EV_ID
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
    -- remove remaining (dangling) retractions
	DELETE @EV_DAT_Event_Date 
	WHERE 
        EV_DAT_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            EV_DAT_StatementType 
        FROM 
            @EV_DAT_Event_Date
        WHERE 
            EV_DAT_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        EV_DAT_EV_ID numeric(12,0) not null,
        Metadata_EV_DAT int not null,
        EV_DAT_PositedAt datetime2 not null,
        EV_DAT_Reliability decimal(5,2) not null,
        EV_DAT_Event_Date datetime2 not null,
        previous_EV_DAT_PositedAt datetime2 not null,
        primary key(
            EV_DAT_EV_ID asc, 
            EV_DAT_PositedAt desc
        )
    );
    INSERT INTO @updated (
        EV_DAT_EV_ID,
        Metadata_EV_DAT,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date, 
        previous_EV_DAT_PositedAt
    )
    SELECT
        EV_DAT_EV_ID,
        Metadata_EV_DAT,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date, 
        previous_EV_DAT_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_DAT_PositedAt AS previous_EV_DAT_PositedAt,
            pre.EV_DAT_StatementType AS previous_EV_DAT_StatementType
        FROM 
            @EV_DAT_Event_Date a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @EV_DAT_Event_Date s
            WHERE
                s.EV_DAT_EV_ID = a.EV_DAT_EV_ID
            AND
                s.EV_DAT_Event_Date = a.EV_DAT_Event_Date
            AND 
                s.EV_DAT_PositedAt < a.EV_DAT_PositedAt
            ORDER BY 
                s.EV_DAT_PositedAt DESC
        ) pre
        WHERE
            a.EV_DAT_Reliability = pre.EV_DAT_Reliability
    ) u
    WHERE
        u.previous_EV_DAT_StatementType = 'A';
    DELETE a
    FROM 
        @EV_DAT_Event_Date a
    JOIN 
        @updated u
    ON 
        u.EV_DAT_EV_ID = a.EV_DAT_EV_ID
    AND
        u.EV_DAT_Event_Date = a.EV_DAT_Event_Date
    AND 
        u.previous_EV_DAT_PositedAt = a.EV_DAT_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @EV_DAT_Event_Date SELECT * FROM @retracted;
    INSERT INTO [attributes].[EV_DAT_Event_Date_Posit] (
        EV_DAT_EV_ID,
        EV_DAT_Event_Date
    )
    SELECT
        EV_DAT_EV_ID,
        EV_DAT_Event_Date
    FROM
        @EV_DAT_Event_Date
    WHERE
        EV_DAT_StatementType = 'P';
    UPDATE a
    SET 
        a.EV_DAT_PositedAt = u.previous_EV_DAT_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[EV_DAT_Event_Date_Posit] p
    ON
        u.EV_DAT_EV_ID = p.EV_DAT_EV_ID
    AND
        u.EV_DAT_Event_Date = p.EV_DAT_Event_Date
    JOIN
        [attributes].[EV_DAT_Event_Date_Annex] a
    ON 
        a.EV_DAT_ID = p.EV_DAT_ID
    AND
        a.EV_DAT_PositedAt = u.EV_DAT_PositedAt;
    INSERT INTO [attributes].[EV_DAT_Event_Date_Annex] (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        v.Metadata_EV_DAT,
        p.EV_DAT_ID,
        v.EV_DAT_PositedAt,
        v.EV_DAT_Reliability
    FROM
        @EV_DAT_Event_Date v
    JOIN
        [attributes].[EV_DAT_Event_Date_Posit] p
    ON
        p.EV_DAT_EV_ID = v.EV_DAT_EV_ID
    AND
        p.EV_DAT_Event_Date = v.EV_DAT_Event_Date
    WHERE
        EV_DAT_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience instead of INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_EV_AUD_Event_Audience', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_AUD_Event_Audience];
GO
CREATE TRIGGER [attributes].[it_EV_AUD_Event_Audience] ON [attributes].[EV_AUD_Event_Audience]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_AUD_Event_Audience TABLE (
        EV_AUD_EV_ID numeric(12,0) not null,
        Metadata_EV_AUD int not null,
        EV_AUD_PositedAt datetime2 not null,
        EV_AUD_Reliability decimal(5,2) not null,
        EV_AUD_Event_Audience int not null,
        EV_AUD_StatementType char(1) not null,
        primary key (
            EV_AUD_EV_ID asc, 
            EV_AUD_PositedAt desc
        )
    );
    INSERT INTO @EV_AUD_Event_Audience
    SELECT
        i.EV_AUD_EV_ID,
        i.Metadata_EV_AUD,
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
        [attributes].[EV_AUD_Event_Audience_Posit] p
    ON
        p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
    AND
        p.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
    LEFT JOIN 
        [attributes].[EV_AUD_Event_Audience_Annex] a
    ON 
        a.EV_AUD_ID = p.EV_AUD_ID
    AND
        a.EV_AUD_PositedAt = i.EV_AUD_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_AUD_ID is null OR a.EV_AUD_ID is null);
    INSERT INTO @EV_AUD_Event_Audience (
        EV_AUD_EV_ID,
        Metadata_EV_AUD,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience,
        EV_AUD_StatementType 
    )
    SELECT
        i.EV_AUD_EV_ID,
        a.Metadata_EV_AUD,
        a.EV_AUD_PositedAt,
        a.EV_AUD_Reliability,
        p.EV_AUD_Event_Audience,
        'X' -- existing data
    FROM
        (SELECT DISTINCT EV_AUD_EV_ID FROM @EV_AUD_Event_Audience) i
    JOIN
        [attributes].[EV_AUD_Event_Audience_Posit] p
    ON
        p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
    JOIN 
        [attributes].[EV_AUD_Event_Audience_Annex] a
    ON 
        a.EV_AUD_ID = p.EV_AUD_ID;
    DECLARE @retracted TABLE (
        EV_AUD_EV_ID numeric(12,0) not null,
        Metadata_EV_AUD int not null,
        EV_AUD_PositedAt datetime2 not null,
        EV_AUD_Reliability decimal(5,2) not null,
        EV_AUD_Event_Audience int not null,
        EV_AUD_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_AUD_EV_ID,
        Metadata_EV_AUD,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience,
        EV_AUD_StatementType 
    )
    SELECT
        EV_AUD_EV_ID,
        Metadata_EV_AUD,
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
                p.EV_AUD_EV_ID = a.EV_AUD_EV_ID
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
                p.EV_AUD_EV_ID = a.EV_AUD_EV_ID
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
    -- remove remaining (dangling) retractions
	DELETE @EV_AUD_Event_Audience 
	WHERE 
        EV_AUD_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            EV_AUD_StatementType 
        FROM 
            @EV_AUD_Event_Audience
        WHERE 
            EV_AUD_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        EV_AUD_EV_ID numeric(12,0) not null,
        Metadata_EV_AUD int not null,
        EV_AUD_PositedAt datetime2 not null,
        EV_AUD_Reliability decimal(5,2) not null,
        EV_AUD_Event_Audience int not null,
        previous_EV_AUD_PositedAt datetime2 not null,
        primary key(
            EV_AUD_EV_ID asc, 
            EV_AUD_PositedAt desc
        )
    );
    INSERT INTO @updated (
        EV_AUD_EV_ID,
        Metadata_EV_AUD,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience, 
        previous_EV_AUD_PositedAt
    )
    SELECT
        EV_AUD_EV_ID,
        Metadata_EV_AUD,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience, 
        previous_EV_AUD_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_AUD_PositedAt AS previous_EV_AUD_PositedAt,
            pre.EV_AUD_StatementType AS previous_EV_AUD_StatementType
        FROM 
            @EV_AUD_Event_Audience a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @EV_AUD_Event_Audience s
            WHERE
                s.EV_AUD_EV_ID = a.EV_AUD_EV_ID
            AND
                s.EV_AUD_Event_Audience = a.EV_AUD_Event_Audience
            AND 
                s.EV_AUD_PositedAt < a.EV_AUD_PositedAt
            ORDER BY 
                s.EV_AUD_PositedAt DESC
        ) pre
        WHERE
            a.EV_AUD_Reliability = pre.EV_AUD_Reliability
    ) u
    WHERE
        u.previous_EV_AUD_StatementType = 'A';
    DELETE a
    FROM 
        @EV_AUD_Event_Audience a
    JOIN 
        @updated u
    ON 
        u.EV_AUD_EV_ID = a.EV_AUD_EV_ID
    AND
        u.EV_AUD_Event_Audience = a.EV_AUD_Event_Audience
    AND 
        u.previous_EV_AUD_PositedAt = a.EV_AUD_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @EV_AUD_Event_Audience SELECT * FROM @retracted;
    INSERT INTO [attributes].[EV_AUD_Event_Audience_Posit] (
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    )
    SELECT
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    FROM
        @EV_AUD_Event_Audience
    WHERE
        EV_AUD_StatementType = 'P';
    UPDATE a
    SET 
        a.EV_AUD_PositedAt = u.previous_EV_AUD_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[EV_AUD_Event_Audience_Posit] p
    ON
        u.EV_AUD_EV_ID = p.EV_AUD_EV_ID
    AND
        u.EV_AUD_Event_Audience = p.EV_AUD_Event_Audience
    JOIN
        [attributes].[EV_AUD_Event_Audience_Annex] a
    ON 
        a.EV_AUD_ID = p.EV_AUD_ID
    AND
        a.EV_AUD_PositedAt = u.EV_AUD_PositedAt;
    INSERT INTO [attributes].[EV_AUD_Event_Audience_Annex] (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        v.Metadata_EV_AUD,
        p.EV_AUD_ID,
        v.EV_AUD_PositedAt,
        v.EV_AUD_Reliability
    FROM
        @EV_AUD_Event_Audience v
    JOIN
        [attributes].[EV_AUD_Event_Audience_Posit] p
    ON
        p.EV_AUD_EV_ID = v.EV_AUD_EV_ID
    AND
        p.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
    WHERE
        EV_AUD_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue instead of INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_EV_REV_Event_Revenue', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_REV_Event_Revenue];
GO
CREATE TRIGGER [attributes].[it_EV_REV_Event_Revenue] ON [attributes].[EV_REV_Event_Revenue]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_REV_Event_Revenue TABLE (
        EV_REV_EV_ID numeric(12,0) not null,
        Metadata_EV_REV int not null,
        EV_REV_PositedAt datetime2 not null,
        EV_REV_Reliability decimal(5,2) not null,
        EV_REV_Event_Revenue decimal(19,4) not null,
        EV_REV_StatementType char(1) not null,
        primary key (
            EV_REV_EV_ID asc, 
            EV_REV_PositedAt desc
        )
    );
    INSERT INTO @EV_REV_Event_Revenue
    SELECT
        i.EV_REV_EV_ID,
        i.Metadata_EV_REV,
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
        [attributes].[EV_REV_Event_Revenue_Posit] p
    ON
        p.EV_REV_EV_ID = i.EV_REV_EV_ID
    AND
        p.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
    LEFT JOIN 
        [attributes].[EV_REV_Event_Revenue_Annex] a
    ON 
        a.EV_REV_ID = p.EV_REV_ID
    AND
        a.EV_REV_PositedAt = i.EV_REV_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_REV_ID is null OR a.EV_REV_ID is null);
    INSERT INTO @EV_REV_Event_Revenue (
        EV_REV_EV_ID,
        Metadata_EV_REV,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue,
        EV_REV_StatementType 
    )
    SELECT
        i.EV_REV_EV_ID,
        a.Metadata_EV_REV,
        a.EV_REV_PositedAt,
        a.EV_REV_Reliability,
        p.EV_REV_Event_Revenue,
        'X' -- existing data
    FROM
        (SELECT DISTINCT EV_REV_EV_ID FROM @EV_REV_Event_Revenue) i
    JOIN
        [attributes].[EV_REV_Event_Revenue_Posit] p
    ON
        p.EV_REV_EV_ID = i.EV_REV_EV_ID
    JOIN 
        [attributes].[EV_REV_Event_Revenue_Annex] a
    ON 
        a.EV_REV_ID = p.EV_REV_ID;
    DECLARE @retracted TABLE (
        EV_REV_EV_ID numeric(12,0) not null,
        Metadata_EV_REV int not null,
        EV_REV_PositedAt datetime2 not null,
        EV_REV_Reliability decimal(5,2) not null,
        EV_REV_Event_Revenue decimal(19,4) not null,
        EV_REV_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_REV_EV_ID,
        Metadata_EV_REV,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue,
        EV_REV_StatementType 
    )
    SELECT
        EV_REV_EV_ID,
        Metadata_EV_REV,
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
                p.EV_REV_EV_ID = a.EV_REV_EV_ID
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
                p.EV_REV_EV_ID = a.EV_REV_EV_ID
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
    -- remove remaining (dangling) retractions
	DELETE @EV_REV_Event_Revenue 
	WHERE 
        EV_REV_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            EV_REV_StatementType 
        FROM 
            @EV_REV_Event_Revenue
        WHERE 
            EV_REV_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        EV_REV_EV_ID numeric(12,0) not null,
        Metadata_EV_REV int not null,
        EV_REV_PositedAt datetime2 not null,
        EV_REV_Reliability decimal(5,2) not null,
        EV_REV_Event_Revenue decimal(19,4) not null,
        previous_EV_REV_PositedAt datetime2 not null,
        primary key(
            EV_REV_EV_ID asc, 
            EV_REV_PositedAt desc
        )
    );
    INSERT INTO @updated (
        EV_REV_EV_ID,
        Metadata_EV_REV,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue, 
        previous_EV_REV_PositedAt
    )
    SELECT
        EV_REV_EV_ID,
        Metadata_EV_REV,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue, 
        previous_EV_REV_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_REV_PositedAt AS previous_EV_REV_PositedAt,
            pre.EV_REV_StatementType AS previous_EV_REV_StatementType
        FROM 
            @EV_REV_Event_Revenue a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @EV_REV_Event_Revenue s
            WHERE
                s.EV_REV_EV_ID = a.EV_REV_EV_ID
            AND
                s.EV_REV_Event_Revenue = a.EV_REV_Event_Revenue
            AND 
                s.EV_REV_PositedAt < a.EV_REV_PositedAt
            ORDER BY 
                s.EV_REV_PositedAt DESC
        ) pre
        WHERE
            a.EV_REV_Reliability = pre.EV_REV_Reliability
    ) u
    WHERE
        u.previous_EV_REV_StatementType = 'A';
    DELETE a
    FROM 
        @EV_REV_Event_Revenue a
    JOIN 
        @updated u
    ON 
        u.EV_REV_EV_ID = a.EV_REV_EV_ID
    AND
        u.EV_REV_Event_Revenue = a.EV_REV_Event_Revenue
    AND 
        u.previous_EV_REV_PositedAt = a.EV_REV_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @EV_REV_Event_Revenue SELECT * FROM @retracted;
    INSERT INTO [attributes].[EV_REV_Event_Revenue_Posit] (
        EV_REV_EV_ID,
        EV_REV_Event_Revenue
    )
    SELECT
        EV_REV_EV_ID,
        EV_REV_Event_Revenue
    FROM
        @EV_REV_Event_Revenue
    WHERE
        EV_REV_StatementType = 'P';
    UPDATE a
    SET 
        a.EV_REV_PositedAt = u.previous_EV_REV_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[EV_REV_Event_Revenue_Posit] p
    ON
        u.EV_REV_EV_ID = p.EV_REV_EV_ID
    AND
        u.EV_REV_Event_Revenue = p.EV_REV_Event_Revenue
    JOIN
        [attributes].[EV_REV_Event_Revenue_Annex] a
    ON 
        a.EV_REV_ID = p.EV_REV_ID
    AND
        a.EV_REV_PositedAt = u.EV_REV_PositedAt;
    INSERT INTO [attributes].[EV_REV_Event_Revenue_Annex] (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        v.Metadata_EV_REV,
        p.EV_REV_ID,
        v.EV_REV_PositedAt,
        v.EV_REV_Reliability
    FROM
        @EV_REV_Event_Revenue v
    JOIN
        [attributes].[EV_REV_Event_Revenue_Posit] p
    ON
        p.EV_REV_EV_ID = v.EV_REV_EV_ID
    AND
        p.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
    WHERE
        EV_REV_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_STA_Event_Status instead of INSERT trigger on EV_STA_Event_Status
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_EV_STA_Event_Status', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_STA_Event_Status];
GO
CREATE TRIGGER [attributes].[it_EV_STA_Event_Status] ON [attributes].[EV_STA_Event_Status]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_STA_Event_Status TABLE (
        EV_STA_EV_ID numeric(12,0) not null,
        Metadata_EV_STA int not null,
        EV_STA_ChangedAt datetime2 not null,
        EV_STA_PositedAt datetime2 not null,
        EV_STA_Reliability decimal(5,2) not null,
        EV_STA_Event_Status nvarchar(20) not null,
        EV_STA_StatementType char(1) not null,
        primary key (
            EV_STA_EV_ID asc, 
            EV_STA_ChangedAt desc,
            EV_STA_PositedAt desc
        )
    );
    INSERT INTO @EV_STA_Event_Status
    SELECT
        i.EV_STA_EV_ID,
        i.Metadata_EV_STA,
        i.EV_STA_ChangedAt,
        i.EV_STA_PositedAt,
        i.EV_STA_Reliability,
        i.EV_STA_Event_Status,
        CASE 
            WHEN p.EV_STA_ID is null 
            THEN 'P' -- new posit
            WHEN a.EV_STA_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [attributes].[EV_STA_Event_Status_Posit] p
    ON
        p.EV_STA_EV_ID = i.EV_STA_EV_ID
    AND
        p.EV_STA_ChangedAt = i.EV_STA_ChangedAt
    AND
        p.EV_STA_Event_Status = i.EV_STA_Event_Status
    LEFT JOIN 
        [attributes].[EV_STA_Event_Status_Annex] a
    ON 
        a.EV_STA_ID = p.EV_STA_ID
    AND
        a.EV_STA_PositedAt = i.EV_STA_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_STA_ID is null OR a.EV_STA_ID is null);
    INSERT INTO @EV_STA_Event_Status (
        EV_STA_EV_ID,
        Metadata_EV_STA,
        EV_STA_ChangedAt,
        EV_STA_PositedAt,
        EV_STA_Reliability,
        EV_STA_Event_Status,
        EV_STA_StatementType 
    )
    SELECT
        i.EV_STA_EV_ID,
        a.Metadata_EV_STA,
        p.EV_STA_ChangedAt,
        a.EV_STA_PositedAt,
        a.EV_STA_Reliability,
        p.EV_STA_Event_Status,
        'X' -- existing data
    FROM
        (SELECT DISTINCT EV_STA_EV_ID FROM @EV_STA_Event_Status) i
    JOIN
        [attributes].[EV_STA_Event_Status_Posit] p
    ON
        p.EV_STA_EV_ID = i.EV_STA_EV_ID
    JOIN 
        [attributes].[EV_STA_Event_Status_Annex] a
    ON 
        a.EV_STA_ID = p.EV_STA_ID;
    DECLARE @retracted TABLE (
        EV_STA_EV_ID numeric(12,0) not null,
        Metadata_EV_STA int not null,
        EV_STA_ChangedAt datetime2 not null,
        EV_STA_PositedAt datetime2 not null,
        EV_STA_Reliability decimal(5,2) not null,
        EV_STA_Event_Status nvarchar(20) not null,
        EV_STA_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_STA_EV_ID,
        Metadata_EV_STA,
        EV_STA_ChangedAt,
        EV_STA_PositedAt,
        EV_STA_Reliability,
        EV_STA_Event_Status,
        EV_STA_StatementType 
    )
    SELECT
        EV_STA_EV_ID,
        Metadata_EV_STA,
        EV_STA_ChangedAt,
        EV_STA_PositedAt,
        EV_STA_Reliability,
        EV_STA_Event_Status,
        EV_STA_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_STA_Reliability as previous_EV_STA_Reliability, 
            fol.EV_STA_Reliability as following_EV_STA_Reliability
        FROM
            @EV_STA_Event_Status a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_STA_Reliability
            FROM
                @EV_STA_Event_Status p
            WHERE
                p.EV_STA_EV_ID = a.EV_STA_EV_ID
            AND
                p.EV_STA_ChangedAt = a.EV_STA_ChangedAt
            AND
                p.EV_STA_PositedAt < a.EV_STA_PositedAt
            ORDER BY 
                p.EV_STA_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_STA_Reliability
            FROM
                @EV_STA_Event_Status p
            WHERE
                p.EV_STA_EV_ID = a.EV_STA_EV_ID
            AND
                p.EV_STA_ChangedAt = a.EV_STA_ChangedAt
            AND
                p.EV_STA_PositedAt > a.EV_STA_PositedAt
            ORDER BY 
                p.EV_STA_PositedAt ASC
        ) fol
        WHERE
            (a.EV_STA_Reliability = 0 AND isnull(pre.EV_STA_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.EV_STA_Reliability = 1 AND fol.EV_STA_Reliability = 0)
    ) i
    WHERE
        i.EV_STA_StatementType <> 'X'
    AND (
            (i.EV_STA_Reliability = 0 AND i.previous_EV_STA_Reliability = 1)
        OR
            (i.EV_STA_Reliability = 1 AND i.following_EV_STA_Reliability = 0)
        );
    -- remove remaining (dangling) retractions
	DELETE @EV_STA_Event_Status 
	WHERE 
        EV_STA_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            EV_STA_StatementType 
        FROM 
            @EV_STA_Event_Status
        WHERE 
            EV_STA_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        EV_STA_EV_ID numeric(12,0) not null,
        Metadata_EV_STA int not null,
        EV_STA_ChangedAt datetime2 not null,
        EV_STA_PositedAt datetime2 not null,
        EV_STA_Reliability decimal(5,2) not null,
        EV_STA_Event_Status nvarchar(20) not null,
        previous_EV_STA_PositedAt datetime2 not null,
        primary key(
            EV_STA_EV_ID asc, 
            EV_STA_ChangedAt desc,
            EV_STA_PositedAt desc
        )
    );
    INSERT INTO @updated (
        EV_STA_EV_ID,
        Metadata_EV_STA,
        EV_STA_ChangedAt,
        EV_STA_PositedAt,
        EV_STA_Reliability,
        EV_STA_Event_Status, 
        previous_EV_STA_PositedAt
    )
    SELECT
        EV_STA_EV_ID,
        Metadata_EV_STA,
        EV_STA_ChangedAt,
        EV_STA_PositedAt,
        EV_STA_Reliability,
        EV_STA_Event_Status, 
        previous_EV_STA_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_STA_PositedAt AS previous_EV_STA_PositedAt,
            pre.EV_STA_StatementType AS previous_EV_STA_StatementType
        FROM 
            @EV_STA_Event_Status a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @EV_STA_Event_Status s
            WHERE
                s.EV_STA_EV_ID = a.EV_STA_EV_ID
            AND
                s.EV_STA_ChangedAt = a.EV_STA_ChangedAt
            AND
                s.EV_STA_Event_Status = a.EV_STA_Event_Status
            AND 
                s.EV_STA_PositedAt < a.EV_STA_PositedAt
            ORDER BY 
                s.EV_STA_PositedAt DESC
        ) pre
        WHERE
            a.EV_STA_Reliability = pre.EV_STA_Reliability
    ) u
    WHERE
        u.previous_EV_STA_StatementType = 'A';
    DELETE a
    FROM 
        @EV_STA_Event_Status a
    JOIN 
        @updated u
    ON 
        u.EV_STA_EV_ID = a.EV_STA_EV_ID
    AND
        u.EV_STA_ChangedAt = a.EV_STA_ChangedAt
    AND
        u.EV_STA_Event_Status = a.EV_STA_Event_Status
    AND 
        u.previous_EV_STA_PositedAt = a.EV_STA_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @EV_STA_Event_Status SELECT * FROM @retracted;
    INSERT INTO [attributes].[EV_STA_Event_Status_Posit] (
        EV_STA_EV_ID,
        EV_STA_ChangedAt,
        EV_STA_Event_Status
    )
    SELECT
        EV_STA_EV_ID,
        EV_STA_ChangedAt,
        EV_STA_Event_Status
    FROM
        @EV_STA_Event_Status
    WHERE
        EV_STA_StatementType = 'P';
    UPDATE a
    SET 
        a.EV_STA_PositedAt = u.previous_EV_STA_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[EV_STA_Event_Status_Posit] p
    ON
        u.EV_STA_EV_ID = p.EV_STA_EV_ID
    AND
        u.EV_STA_ChangedAt = p.EV_STA_ChangedAt
    AND
        u.EV_STA_Event_Status = p.EV_STA_Event_Status
    JOIN
        [attributes].[EV_STA_Event_Status_Annex] a
    ON 
        a.EV_STA_ID = p.EV_STA_ID
    AND
        a.EV_STA_PositedAt = u.EV_STA_PositedAt;
    INSERT INTO [attributes].[EV_STA_Event_Status_Annex] (
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_PositedAt,
        EV_STA_Reliability
    )
    SELECT
        v.Metadata_EV_STA,
        p.EV_STA_ID,
        v.EV_STA_PositedAt,
        v.EV_STA_Reliability
    FROM
        @EV_STA_Event_Status v
    JOIN
        [attributes].[EV_STA_Event_Status_Posit] p
    ON
        p.EV_STA_EV_ID = v.EV_STA_EV_ID
    AND
        p.EV_STA_ChangedAt = v.EV_STA_ChangedAt
    AND
        p.EV_STA_Event_Status = v.EV_STA_Event_Status
    WHERE
        EV_STA_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_UTL_Event_Utilization instead of INSERT trigger on EV_UTL_Event_Utilization
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_EV_UTL_Event_Utilization', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_UTL_Event_Utilization];
GO
CREATE TRIGGER [attributes].[it_EV_UTL_Event_Utilization] ON [attributes].[EV_UTL_Event_Utilization]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_UTL_Event_Utilization TABLE (
        EV_UTL_EV_ID numeric(12,0) not null,
        Metadata_EV_UTL int not null,
        EV_UTL_PositedAt datetime2 not null,
        EV_UTL_Reliability decimal(5,2) not null,
        EV_UTL_UTL_ID tinyint not null, 
        EV_UTL_StatementType char(1) not null,
        primary key (
            EV_UTL_EV_ID asc, 
            EV_UTL_PositedAt desc
        )
    );
    INSERT INTO @EV_UTL_Event_Utilization
    SELECT
        i.EV_UTL_EV_ID,
        i.Metadata_EV_UTL,
        i.EV_UTL_PositedAt,
        i.EV_UTL_Reliability,
        i.EV_UTL_UTL_ID,
        CASE 
            WHEN p.EV_UTL_ID is null 
            THEN 'P' -- new posit
            WHEN a.EV_UTL_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [attributes].[EV_UTL_Event_Utilization_Posit] p
    ON
        p.EV_UTL_EV_ID = i.EV_UTL_EV_ID
    AND
        p.EV_UTL_UTL_ID = i.EV_UTL_UTL_ID
    LEFT JOIN 
        [attributes].[EV_UTL_Event_Utilization_Annex] a
    ON 
        a.EV_UTL_ID = p.EV_UTL_ID
    AND
        a.EV_UTL_PositedAt = i.EV_UTL_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_UTL_ID is null OR a.EV_UTL_ID is null);
    INSERT INTO @EV_UTL_Event_Utilization (
        EV_UTL_EV_ID,
        Metadata_EV_UTL,
        EV_UTL_PositedAt,
        EV_UTL_Reliability,
        EV_UTL_UTL_ID,
        EV_UTL_StatementType 
    )
    SELECT
        i.EV_UTL_EV_ID,
        a.Metadata_EV_UTL,
        a.EV_UTL_PositedAt,
        a.EV_UTL_Reliability,
        p.EV_UTL_UTL_ID,
        'X' -- existing data
    FROM
        (SELECT DISTINCT EV_UTL_EV_ID FROM @EV_UTL_Event_Utilization) i
    JOIN
        [attributes].[EV_UTL_Event_Utilization_Posit] p
    ON
        p.EV_UTL_EV_ID = i.EV_UTL_EV_ID
    JOIN 
        [attributes].[EV_UTL_Event_Utilization_Annex] a
    ON 
        a.EV_UTL_ID = p.EV_UTL_ID;
    DECLARE @retracted TABLE (
        EV_UTL_EV_ID numeric(12,0) not null,
        Metadata_EV_UTL int not null,
        EV_UTL_PositedAt datetime2 not null,
        EV_UTL_Reliability decimal(5,2) not null,
        EV_UTL_UTL_ID tinyint not null, 
        EV_UTL_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_UTL_EV_ID,
        Metadata_EV_UTL,
        EV_UTL_PositedAt,
        EV_UTL_Reliability,
        EV_UTL_UTL_ID,
        EV_UTL_StatementType 
    )
    SELECT
        EV_UTL_EV_ID,
        Metadata_EV_UTL,
        EV_UTL_PositedAt,
        EV_UTL_Reliability,
        EV_UTL_UTL_ID,
        EV_UTL_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_UTL_Reliability as previous_EV_UTL_Reliability, 
            fol.EV_UTL_Reliability as following_EV_UTL_Reliability
        FROM
            @EV_UTL_Event_Utilization a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_UTL_Reliability
            FROM
                @EV_UTL_Event_Utilization p
            WHERE
                p.EV_UTL_EV_ID = a.EV_UTL_EV_ID
            AND
                p.EV_UTL_PositedAt < a.EV_UTL_PositedAt
            ORDER BY 
                p.EV_UTL_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_UTL_Reliability
            FROM
                @EV_UTL_Event_Utilization p
            WHERE
                p.EV_UTL_EV_ID = a.EV_UTL_EV_ID
            AND
                p.EV_UTL_PositedAt > a.EV_UTL_PositedAt
            ORDER BY 
                p.EV_UTL_PositedAt ASC
        ) fol
        WHERE
            (a.EV_UTL_Reliability = 0 AND isnull(pre.EV_UTL_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.EV_UTL_Reliability = 1 AND fol.EV_UTL_Reliability = 0)
    ) i
    WHERE
        i.EV_UTL_StatementType <> 'X'
    AND (
            (i.EV_UTL_Reliability = 0 AND i.previous_EV_UTL_Reliability = 1)
        OR
            (i.EV_UTL_Reliability = 1 AND i.following_EV_UTL_Reliability = 0)
        );
    -- remove remaining (dangling) retractions
	DELETE @EV_UTL_Event_Utilization 
	WHERE 
        EV_UTL_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            EV_UTL_StatementType 
        FROM 
            @EV_UTL_Event_Utilization
        WHERE 
            EV_UTL_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        EV_UTL_EV_ID numeric(12,0) not null,
        Metadata_EV_UTL int not null,
        EV_UTL_PositedAt datetime2 not null,
        EV_UTL_Reliability decimal(5,2) not null,
        EV_UTL_UTL_ID tinyint not null, 
        previous_EV_UTL_PositedAt datetime2 not null,
        primary key(
            EV_UTL_EV_ID asc, 
            EV_UTL_PositedAt desc
        )
    );
    INSERT INTO @updated (
        EV_UTL_EV_ID,
        Metadata_EV_UTL,
        EV_UTL_PositedAt,
        EV_UTL_Reliability,
        EV_UTL_UTL_ID, 
        previous_EV_UTL_PositedAt
    )
    SELECT
        EV_UTL_EV_ID,
        Metadata_EV_UTL,
        EV_UTL_PositedAt,
        EV_UTL_Reliability,
        EV_UTL_UTL_ID, 
        previous_EV_UTL_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_UTL_PositedAt AS previous_EV_UTL_PositedAt,
            pre.EV_UTL_StatementType AS previous_EV_UTL_StatementType
        FROM 
            @EV_UTL_Event_Utilization a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @EV_UTL_Event_Utilization s
            WHERE
                s.EV_UTL_EV_ID = a.EV_UTL_EV_ID
            AND
                s.EV_UTL_UTL_ID = a.EV_UTL_UTL_ID
            AND 
                s.EV_UTL_PositedAt < a.EV_UTL_PositedAt
            ORDER BY 
                s.EV_UTL_PositedAt DESC
        ) pre
        WHERE
            a.EV_UTL_Reliability = pre.EV_UTL_Reliability
    ) u
    WHERE
        u.previous_EV_UTL_StatementType = 'A';
    DELETE a
    FROM 
        @EV_UTL_Event_Utilization a
    JOIN 
        @updated u
    ON 
        u.EV_UTL_EV_ID = a.EV_UTL_EV_ID
    AND
        u.EV_UTL_UTL_ID = a.EV_UTL_UTL_ID
    AND 
        u.previous_EV_UTL_PositedAt = a.EV_UTL_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @EV_UTL_Event_Utilization SELECT * FROM @retracted;
    INSERT INTO [attributes].[EV_UTL_Event_Utilization_Posit] (
        EV_UTL_EV_ID,
        EV_UTL_UTL_ID
    )
    SELECT
        EV_UTL_EV_ID,
        EV_UTL_UTL_ID
    FROM
        @EV_UTL_Event_Utilization
    WHERE
        EV_UTL_StatementType = 'P';
    UPDATE a
    SET 
        a.EV_UTL_PositedAt = u.previous_EV_UTL_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[EV_UTL_Event_Utilization_Posit] p
    ON
        u.EV_UTL_EV_ID = p.EV_UTL_EV_ID
    AND
        u.EV_UTL_UTL_ID = p.EV_UTL_UTL_ID
    JOIN
        [attributes].[EV_UTL_Event_Utilization_Annex] a
    ON 
        a.EV_UTL_ID = p.EV_UTL_ID
    AND
        a.EV_UTL_PositedAt = u.EV_UTL_PositedAt;
    INSERT INTO [attributes].[EV_UTL_Event_Utilization_Annex] (
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_PositedAt,
        EV_UTL_Reliability
    )
    SELECT
        v.Metadata_EV_UTL,
        p.EV_UTL_ID,
        v.EV_UTL_PositedAt,
        v.EV_UTL_Reliability
    FROM
        @EV_UTL_Event_Utilization v
    JOIN
        [attributes].[EV_UTL_Event_Utilization_Posit] p
    ON
        p.EV_UTL_EV_ID = v.EV_UTL_EV_ID
    AND
        p.EV_UTL_UTL_ID = v.EV_UTL_UTL_ID
    WHERE
        EV_UTL_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_LVL_Event_Level instead of INSERT trigger on EV_LVL_Event_Level
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_EV_LVL_Event_Level', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_LVL_Event_Level];
GO
CREATE TRIGGER [attributes].[it_EV_LVL_Event_Level] ON [attributes].[EV_LVL_Event_Level]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_LVL_Event_Level TABLE (
        EV_LVL_EV_ID numeric(12,0) not null,
        Metadata_EV_LVL int not null,
        EV_LVL_ChangedAt date not null,
        EV_LVL_PositedAt datetime2 not null,
        EV_LVL_Reliability decimal(5,2) not null,
        EV_LVL_PLV_ID tinyint not null, 
        EV_LVL_StatementType char(1) not null,
        primary key (
            EV_LVL_EV_ID asc, 
            EV_LVL_ChangedAt desc,
            EV_LVL_PositedAt desc
        )
    );
    INSERT INTO @EV_LVL_Event_Level
    SELECT
        i.EV_LVL_EV_ID,
        i.Metadata_EV_LVL,
        i.EV_LVL_ChangedAt,
        i.EV_LVL_PositedAt,
        i.EV_LVL_Reliability,
        i.EV_LVL_PLV_ID,
        CASE 
            WHEN p.EV_LVL_ID is null 
            THEN 'P' -- new posit
            WHEN a.EV_LVL_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [attributes].[EV_LVL_Event_Level_Posit] p
    ON
        p.EV_LVL_EV_ID = i.EV_LVL_EV_ID
    AND
        p.EV_LVL_ChangedAt = i.EV_LVL_ChangedAt
    AND
        p.EV_LVL_PLV_ID = i.EV_LVL_PLV_ID
    LEFT JOIN 
        [attributes].[EV_LVL_Event_Level_Annex] a
    ON 
        a.EV_LVL_ID = p.EV_LVL_ID
    AND
        a.EV_LVL_PositedAt = i.EV_LVL_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_LVL_ID is null OR a.EV_LVL_ID is null);
    INSERT INTO @EV_LVL_Event_Level (
        EV_LVL_EV_ID,
        Metadata_EV_LVL,
        EV_LVL_ChangedAt,
        EV_LVL_PositedAt,
        EV_LVL_Reliability,
        EV_LVL_PLV_ID,
        EV_LVL_StatementType 
    )
    SELECT
        i.EV_LVL_EV_ID,
        a.Metadata_EV_LVL,
        p.EV_LVL_ChangedAt,
        a.EV_LVL_PositedAt,
        a.EV_LVL_Reliability,
        p.EV_LVL_PLV_ID,
        'X' -- existing data
    FROM
        (SELECT DISTINCT EV_LVL_EV_ID FROM @EV_LVL_Event_Level) i
    JOIN
        [attributes].[EV_LVL_Event_Level_Posit] p
    ON
        p.EV_LVL_EV_ID = i.EV_LVL_EV_ID
    JOIN 
        [attributes].[EV_LVL_Event_Level_Annex] a
    ON 
        a.EV_LVL_ID = p.EV_LVL_ID;
    DECLARE @retracted TABLE (
        EV_LVL_EV_ID numeric(12,0) not null,
        Metadata_EV_LVL int not null,
        EV_LVL_ChangedAt date not null,
        EV_LVL_PositedAt datetime2 not null,
        EV_LVL_Reliability decimal(5,2) not null,
        EV_LVL_PLV_ID tinyint not null, 
        EV_LVL_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_LVL_EV_ID,
        Metadata_EV_LVL,
        EV_LVL_ChangedAt,
        EV_LVL_PositedAt,
        EV_LVL_Reliability,
        EV_LVL_PLV_ID,
        EV_LVL_StatementType 
    )
    SELECT
        EV_LVL_EV_ID,
        Metadata_EV_LVL,
        EV_LVL_ChangedAt,
        EV_LVL_PositedAt,
        EV_LVL_Reliability,
        EV_LVL_PLV_ID,
        EV_LVL_StatementType 
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_LVL_Reliability as previous_EV_LVL_Reliability, 
            fol.EV_LVL_Reliability as following_EV_LVL_Reliability
        FROM
            @EV_LVL_Event_Level a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_LVL_Reliability
            FROM
                @EV_LVL_Event_Level p
            WHERE
                p.EV_LVL_EV_ID = a.EV_LVL_EV_ID
            AND
                p.EV_LVL_ChangedAt = a.EV_LVL_ChangedAt
            AND
                p.EV_LVL_PositedAt < a.EV_LVL_PositedAt
            ORDER BY 
                p.EV_LVL_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_LVL_Reliability
            FROM
                @EV_LVL_Event_Level p
            WHERE
                p.EV_LVL_EV_ID = a.EV_LVL_EV_ID
            AND
                p.EV_LVL_ChangedAt = a.EV_LVL_ChangedAt
            AND
                p.EV_LVL_PositedAt > a.EV_LVL_PositedAt
            ORDER BY 
                p.EV_LVL_PositedAt ASC
        ) fol
        WHERE
            (a.EV_LVL_Reliability = 0 AND isnull(pre.EV_LVL_Reliability, 1) = 1) -- ta bort isnull för assertive
        OR
            (a.EV_LVL_Reliability = 1 AND fol.EV_LVL_Reliability = 0)
    ) i
    WHERE
        i.EV_LVL_StatementType <> 'X'
    AND (
            (i.EV_LVL_Reliability = 0 AND i.previous_EV_LVL_Reliability = 1)
        OR
            (i.EV_LVL_Reliability = 1 AND i.following_EV_LVL_Reliability = 0)
        );
    -- remove remaining (dangling) retractions
	DELETE @EV_LVL_Event_Level 
	WHERE 
        EV_LVL_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            EV_LVL_StatementType 
        FROM 
            @EV_LVL_Event_Level
        WHERE 
            EV_LVL_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        EV_LVL_EV_ID numeric(12,0) not null,
        Metadata_EV_LVL int not null,
        EV_LVL_ChangedAt date not null,
        EV_LVL_PositedAt datetime2 not null,
        EV_LVL_Reliability decimal(5,2) not null,
        EV_LVL_PLV_ID tinyint not null, 
        previous_EV_LVL_PositedAt datetime2 not null,
        primary key(
            EV_LVL_EV_ID asc, 
            EV_LVL_ChangedAt desc,
            EV_LVL_PositedAt desc
        )
    );
    INSERT INTO @updated (
        EV_LVL_EV_ID,
        Metadata_EV_LVL,
        EV_LVL_ChangedAt,
        EV_LVL_PositedAt,
        EV_LVL_Reliability,
        EV_LVL_PLV_ID, 
        previous_EV_LVL_PositedAt
    )
    SELECT
        EV_LVL_EV_ID,
        Metadata_EV_LVL,
        EV_LVL_ChangedAt,
        EV_LVL_PositedAt,
        EV_LVL_Reliability,
        EV_LVL_PLV_ID, 
        previous_EV_LVL_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.EV_LVL_PositedAt AS previous_EV_LVL_PositedAt,
            pre.EV_LVL_StatementType AS previous_EV_LVL_StatementType
        FROM 
            @EV_LVL_Event_Level a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @EV_LVL_Event_Level s
            WHERE
                s.EV_LVL_EV_ID = a.EV_LVL_EV_ID
            AND
                s.EV_LVL_ChangedAt = a.EV_LVL_ChangedAt
            AND
                s.EV_LVL_PLV_ID = a.EV_LVL_PLV_ID
            AND 
                s.EV_LVL_PositedAt < a.EV_LVL_PositedAt
            ORDER BY 
                s.EV_LVL_PositedAt DESC
        ) pre
        WHERE
            a.EV_LVL_Reliability = pre.EV_LVL_Reliability
    ) u
    WHERE
        u.previous_EV_LVL_StatementType = 'A';
    DELETE a
    FROM 
        @EV_LVL_Event_Level a
    JOIN 
        @updated u
    ON 
        u.EV_LVL_EV_ID = a.EV_LVL_EV_ID
    AND
        u.EV_LVL_ChangedAt = a.EV_LVL_ChangedAt
    AND
        u.EV_LVL_PLV_ID = a.EV_LVL_PLV_ID
    AND 
        u.previous_EV_LVL_PositedAt = a.EV_LVL_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @EV_LVL_Event_Level SELECT * FROM @retracted;
    INSERT INTO [attributes].[EV_LVL_Event_Level_Posit] (
        EV_LVL_EV_ID,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    )
    SELECT
        EV_LVL_EV_ID,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    FROM
        @EV_LVL_Event_Level
    WHERE
        EV_LVL_StatementType = 'P';
    UPDATE a
    SET 
        a.EV_LVL_PositedAt = u.previous_EV_LVL_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[EV_LVL_Event_Level_Posit] p
    ON
        u.EV_LVL_EV_ID = p.EV_LVL_EV_ID
    AND
        u.EV_LVL_ChangedAt = p.EV_LVL_ChangedAt
    AND
        u.EV_LVL_PLV_ID = p.EV_LVL_PLV_ID
    JOIN
        [attributes].[EV_LVL_Event_Level_Annex] a
    ON 
        a.EV_LVL_ID = p.EV_LVL_ID
    AND
        a.EV_LVL_PositedAt = u.EV_LVL_PositedAt;
    INSERT INTO [attributes].[EV_LVL_Event_Level_Annex] (
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_PositedAt,
        EV_LVL_Reliability
    )
    SELECT
        v.Metadata_EV_LVL,
        p.EV_LVL_ID,
        v.EV_LVL_PositedAt,
        v.EV_LVL_Reliability
    FROM
        @EV_LVL_Event_Level v
    JOIN
        [attributes].[EV_LVL_Event_Level_Posit] p
    ON
        p.EV_LVL_EV_ID = v.EV_LVL_EV_ID
    AND
        p.EV_LVL_ChangedAt = v.EV_LVL_ChangedAt
    AND
        p.EV_LVL_PLV_ID = v.EV_LVL_PLV_ID
    WHERE
        EV_LVL_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_ST_NAM_Stage_Name', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_ST_NAM_Stage_Name];
GO
CREATE TRIGGER [attributes].[it_ST_NAM_Stage_Name] ON [attributes].[ST_NAM_Stage_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_NAM_Stage_Name TABLE (
        ST_NAM_ST_ID int not null,
        Metadata_ST_NAM int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_PositedAt datetime2 not null,
        ST_NAM_Reliability decimal(5,2) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_StatementType char(1) not null,
        primary key (
            ST_NAM_ST_ID asc, 
            ST_NAM_ChangedAt desc,
            ST_NAM_PositedAt desc
        )
    );
    INSERT INTO @ST_NAM_Stage_Name
    SELECT
        i.ST_NAM_ST_ID,
        i.Metadata_ST_NAM,
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
        [attributes].[ST_NAM_Stage_Name_Posit] p
    ON
        p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
    AND
        p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
    AND
        p.ST_NAM_Stage_Name = i.ST_NAM_Stage_Name
    LEFT JOIN 
        [attributes].[ST_NAM_Stage_Name_Annex] a
    ON 
        a.ST_NAM_ID = p.ST_NAM_ID
    AND
        a.ST_NAM_PositedAt = i.ST_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_NAM_ID is null OR a.ST_NAM_ID is null);
    INSERT INTO @ST_NAM_Stage_Name (
        ST_NAM_ST_ID,
        Metadata_ST_NAM,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name,
        ST_NAM_StatementType 
    )
    SELECT
        i.ST_NAM_ST_ID,
        a.Metadata_ST_NAM,
        p.ST_NAM_ChangedAt,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Reliability,
        p.ST_NAM_Stage_Name,
        'X' -- existing data
    FROM
        (SELECT DISTINCT ST_NAM_ST_ID FROM @ST_NAM_Stage_Name) i
    JOIN
        [attributes].[ST_NAM_Stage_Name_Posit] p
    ON
        p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
    JOIN 
        [attributes].[ST_NAM_Stage_Name_Annex] a
    ON 
        a.ST_NAM_ID = p.ST_NAM_ID;
    DECLARE @retracted TABLE (
        ST_NAM_ST_ID int not null,
        Metadata_ST_NAM int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_PositedAt datetime2 not null,
        ST_NAM_Reliability decimal(5,2) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_NAM_ST_ID,
        Metadata_ST_NAM,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name,
        ST_NAM_StatementType 
    )
    SELECT
        ST_NAM_ST_ID,
        Metadata_ST_NAM,
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
                p.ST_NAM_ST_ID = a.ST_NAM_ST_ID
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
                p.ST_NAM_ST_ID = a.ST_NAM_ST_ID
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
    -- remove remaining (dangling) retractions
	DELETE @ST_NAM_Stage_Name 
	WHERE 
        ST_NAM_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            ST_NAM_StatementType 
        FROM 
            @ST_NAM_Stage_Name
        WHERE 
            ST_NAM_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        ST_NAM_ST_ID int not null,
        Metadata_ST_NAM int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_PositedAt datetime2 not null,
        ST_NAM_Reliability decimal(5,2) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        previous_ST_NAM_PositedAt datetime2 not null,
        primary key(
            ST_NAM_ST_ID asc, 
            ST_NAM_ChangedAt desc,
            ST_NAM_PositedAt desc
        )
    );
    INSERT INTO @updated (
        ST_NAM_ST_ID,
        Metadata_ST_NAM,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name, 
        previous_ST_NAM_PositedAt
    )
    SELECT
        ST_NAM_ST_ID,
        Metadata_ST_NAM,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name, 
        previous_ST_NAM_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.ST_NAM_PositedAt AS previous_ST_NAM_PositedAt,
            pre.ST_NAM_StatementType AS previous_ST_NAM_StatementType
        FROM 
            @ST_NAM_Stage_Name a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @ST_NAM_Stage_Name s
            WHERE
                s.ST_NAM_ST_ID = a.ST_NAM_ST_ID
            AND
                s.ST_NAM_ChangedAt = a.ST_NAM_ChangedAt
            AND
                s.ST_NAM_Stage_Name = a.ST_NAM_Stage_Name
            AND 
                s.ST_NAM_PositedAt < a.ST_NAM_PositedAt
            ORDER BY 
                s.ST_NAM_PositedAt DESC
        ) pre
        WHERE
            a.ST_NAM_Reliability = pre.ST_NAM_Reliability
    ) u
    WHERE
        u.previous_ST_NAM_StatementType = 'A';
    DELETE a
    FROM 
        @ST_NAM_Stage_Name a
    JOIN 
        @updated u
    ON 
        u.ST_NAM_ST_ID = a.ST_NAM_ST_ID
    AND
        u.ST_NAM_ChangedAt = a.ST_NAM_ChangedAt
    AND
        u.ST_NAM_Stage_Name = a.ST_NAM_Stage_Name
    AND 
        u.previous_ST_NAM_PositedAt = a.ST_NAM_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @ST_NAM_Stage_Name SELECT * FROM @retracted;
    INSERT INTO [attributes].[ST_NAM_Stage_Name_Posit] (
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    SELECT
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    FROM
        @ST_NAM_Stage_Name
    WHERE
        ST_NAM_StatementType = 'P';
    UPDATE a
    SET 
        a.ST_NAM_PositedAt = u.previous_ST_NAM_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[ST_NAM_Stage_Name_Posit] p
    ON
        u.ST_NAM_ST_ID = p.ST_NAM_ST_ID
    AND
        u.ST_NAM_ChangedAt = p.ST_NAM_ChangedAt
    AND
        u.ST_NAM_Stage_Name = p.ST_NAM_Stage_Name
    JOIN
        [attributes].[ST_NAM_Stage_Name_Annex] a
    ON 
        a.ST_NAM_ID = p.ST_NAM_ID
    AND
        a.ST_NAM_PositedAt = u.ST_NAM_PositedAt;
    INSERT INTO [attributes].[ST_NAM_Stage_Name_Annex] (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        v.Metadata_ST_NAM,
        p.ST_NAM_ID,
        v.ST_NAM_PositedAt,
        v.ST_NAM_Reliability
    FROM
        @ST_NAM_Stage_Name v
    JOIN
        [attributes].[ST_NAM_Stage_Name_Posit] p
    ON
        p.ST_NAM_ST_ID = v.ST_NAM_ST_ID
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
IF Object_ID('attributes.it_ST_LOC_Stage_Location', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_ST_LOC_Stage_Location];
GO
CREATE TRIGGER [attributes].[it_ST_LOC_Stage_Location] ON [attributes].[ST_LOC_Stage_Location]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_LOC_Stage_Location TABLE (
        ST_LOC_ST_ID int not null,
        Metadata_ST_LOC int not null,
        ST_LOC_PositedAt datetime2 not null,
        ST_LOC_Reliability decimal(5,2) not null,
        ST_LOC_Stage_Location geography not null,
        ST_LOC_Checksum varbinary(16) not null,
        ST_LOC_StatementType char(1) not null,
        primary key (
            ST_LOC_ST_ID asc, 
            ST_LOC_PositedAt desc
        )
    );
    INSERT INTO @ST_LOC_Stage_Location
    SELECT
        i.ST_LOC_ST_ID,
        i.Metadata_ST_LOC,
        i.ST_LOC_PositedAt,
        i.ST_LOC_Reliability,
        i.ST_LOC_Stage_Location,
        dw.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))),
        CASE 
            WHEN p.ST_LOC_ID is null 
            THEN 'P' -- new posit
            WHEN a.ST_LOC_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [attributes].[ST_LOC_Stage_Location_Posit] p
    ON
        p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
    AND
        p.ST_LOC_Checksum = dw.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))) 
    LEFT JOIN 
        [attributes].[ST_LOC_Stage_Location_Annex] a
    ON 
        a.ST_LOC_ID = p.ST_LOC_ID
    AND
        a.ST_LOC_PositedAt = i.ST_LOC_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_LOC_ID is null OR a.ST_LOC_ID is null);
    INSERT INTO @ST_LOC_Stage_Location (
        ST_LOC_ST_ID,
        Metadata_ST_LOC,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum,
        ST_LOC_StatementType 
    )
    SELECT
        i.ST_LOC_ST_ID,
        a.Metadata_ST_LOC,
        a.ST_LOC_PositedAt,
        a.ST_LOC_Reliability,
        p.ST_LOC_Stage_Location,
        p.ST_LOC_Checksum,
        'X' -- existing data
    FROM
        (SELECT DISTINCT ST_LOC_ST_ID FROM @ST_LOC_Stage_Location) i
    JOIN
        [attributes].[ST_LOC_Stage_Location_Posit] p
    ON
        p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
    JOIN 
        [attributes].[ST_LOC_Stage_Location_Annex] a
    ON 
        a.ST_LOC_ID = p.ST_LOC_ID;
    DECLARE @retracted TABLE (
        ST_LOC_ST_ID int not null,
        Metadata_ST_LOC int not null,
        ST_LOC_PositedAt datetime2 not null,
        ST_LOC_Reliability decimal(5,2) not null,
        ST_LOC_Stage_Location geography not null,
        ST_LOC_Checksum varbinary(16) not null,
        ST_LOC_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_LOC_ST_ID,
        Metadata_ST_LOC,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum,
        ST_LOC_StatementType 
    )
    SELECT
        ST_LOC_ST_ID,
        Metadata_ST_LOC,
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
                p.ST_LOC_ST_ID = a.ST_LOC_ST_ID
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
                p.ST_LOC_ST_ID = a.ST_LOC_ST_ID
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
    -- remove remaining (dangling) retractions
	DELETE @ST_LOC_Stage_Location 
	WHERE 
        ST_LOC_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            ST_LOC_StatementType 
        FROM 
            @ST_LOC_Stage_Location
        WHERE 
            ST_LOC_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        ST_LOC_ST_ID int not null,
        Metadata_ST_LOC int not null,
        ST_LOC_PositedAt datetime2 not null,
        ST_LOC_Reliability decimal(5,2) not null,
        ST_LOC_Stage_Location geography not null,
        ST_LOC_Checksum varbinary(16) not null,
        previous_ST_LOC_PositedAt datetime2 not null,
        primary key(
            ST_LOC_ST_ID asc, 
            ST_LOC_PositedAt desc
        )
    );
    INSERT INTO @updated (
        ST_LOC_ST_ID,
        Metadata_ST_LOC,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location, 
        ST_LOC_Checksum,
        previous_ST_LOC_PositedAt
    )
    SELECT
        ST_LOC_ST_ID,
        Metadata_ST_LOC,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location, 
        ST_LOC_Checksum,
        previous_ST_LOC_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.ST_LOC_PositedAt AS previous_ST_LOC_PositedAt,
            pre.ST_LOC_StatementType AS previous_ST_LOC_StatementType
        FROM 
            @ST_LOC_Stage_Location a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @ST_LOC_Stage_Location s
            WHERE
                s.ST_LOC_ST_ID = a.ST_LOC_ST_ID
            AND
                s.ST_LOC_Checksum = a.ST_LOC_Checksum 
            AND 
                s.ST_LOC_PositedAt < a.ST_LOC_PositedAt
            ORDER BY 
                s.ST_LOC_PositedAt DESC
        ) pre
        WHERE
            a.ST_LOC_Reliability = pre.ST_LOC_Reliability
    ) u
    WHERE
        u.previous_ST_LOC_StatementType = 'A';
    DELETE a
    FROM 
        @ST_LOC_Stage_Location a
    JOIN 
        @updated u
    ON 
        u.ST_LOC_ST_ID = a.ST_LOC_ST_ID
    AND
        u.ST_LOC_Checksum = a.ST_LOC_Checksum 
    AND 
        u.previous_ST_LOC_PositedAt = a.ST_LOC_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @ST_LOC_Stage_Location SELECT * FROM @retracted;
    INSERT INTO [attributes].[ST_LOC_Stage_Location_Posit] (
        ST_LOC_ST_ID,
        ST_LOC_Stage_Location
    )
    SELECT
        ST_LOC_ST_ID,
        ST_LOC_Stage_Location
    FROM
        @ST_LOC_Stage_Location
    WHERE
        ST_LOC_StatementType = 'P';
    UPDATE a
    SET 
        a.ST_LOC_PositedAt = u.previous_ST_LOC_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[ST_LOC_Stage_Location_Posit] p
    ON
        u.ST_LOC_ST_ID = p.ST_LOC_ST_ID
    AND
        u.ST_LOC_Checksum = p.ST_LOC_Checksum 
    JOIN
        [attributes].[ST_LOC_Stage_Location_Annex] a
    ON 
        a.ST_LOC_ID = p.ST_LOC_ID
    AND
        a.ST_LOC_PositedAt = u.ST_LOC_PositedAt;
    INSERT INTO [attributes].[ST_LOC_Stage_Location_Annex] (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        v.Metadata_ST_LOC,
        p.ST_LOC_ID,
        v.ST_LOC_PositedAt,
        v.ST_LOC_Reliability
    FROM
        @ST_LOC_Stage_Location v
    JOIN
        [attributes].[ST_LOC_Stage_Location_Posit] p
    ON
        p.ST_LOC_ST_ID = v.ST_LOC_ST_ID
    AND
        p.ST_LOC_Checksum = v.ST_LOC_Checksum 
    WHERE
        ST_LOC_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average instead of INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_ST_AVG_Stage_Average', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_ST_AVG_Stage_Average];
GO
CREATE TRIGGER [attributes].[it_ST_AVG_Stage_Average] ON [attributes].[ST_AVG_Stage_Average]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null, 
        ST_AVG_StatementType char(1) not null,
        primary key (
            ST_AVG_ST_ID asc, 
            ST_AVG_ChangedAt desc,
            ST_AVG_PositedAt desc
        )
    );
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        i.ST_AVG_ST_ID,
        i.Metadata_ST_AVG,
        i.ST_AVG_ChangedAt,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Reliability,
        i.ST_AVG_UTL_ID,
        CASE 
            WHEN p.ST_AVG_ID is null 
            THEN 'P' -- new posit
            WHEN a.ST_AVG_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [attributes].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
    AND
        p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
    AND
        p.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
    LEFT JOIN 
        [attributes].[ST_AVG_Stage_Average_Annex] a
    ON 
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = i.ST_AVG_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_AVG_ID is null OR a.ST_AVG_ID is null);
    INSERT INTO @ST_AVG_Stage_Average (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID,
        ST_AVG_StatementType 
    )
    SELECT
        i.ST_AVG_ST_ID,
        a.Metadata_ST_AVG,
        p.ST_AVG_ChangedAt,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Reliability,
        p.ST_AVG_UTL_ID,
        'X' -- existing data
    FROM
        (SELECT DISTINCT ST_AVG_ST_ID FROM @ST_AVG_Stage_Average) i
    JOIN
        [attributes].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
    JOIN 
        [attributes].[ST_AVG_Stage_Average_Annex] a
    ON 
        a.ST_AVG_ID = p.ST_AVG_ID;
    DECLARE @retracted TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null, 
        ST_AVG_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID,
        ST_AVG_StatementType 
    )
    SELECT
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID,
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
                p.ST_AVG_ST_ID = a.ST_AVG_ST_ID
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
                p.ST_AVG_ST_ID = a.ST_AVG_ST_ID
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
    -- remove remaining (dangling) retractions
	DELETE @ST_AVG_Stage_Average 
	WHERE 
        ST_AVG_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            ST_AVG_StatementType 
        FROM 
            @ST_AVG_Stage_Average
        WHERE 
            ST_AVG_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null, 
        previous_ST_AVG_PositedAt datetime2 not null,
        primary key(
            ST_AVG_ST_ID asc, 
            ST_AVG_ChangedAt desc,
            ST_AVG_PositedAt desc
        )
    );
    INSERT INTO @updated (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID, 
        previous_ST_AVG_PositedAt
    )
    SELECT
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID, 
        previous_ST_AVG_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.ST_AVG_PositedAt AS previous_ST_AVG_PositedAt,
            pre.ST_AVG_StatementType AS previous_ST_AVG_StatementType
        FROM 
            @ST_AVG_Stage_Average a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @ST_AVG_Stage_Average s
            WHERE
                s.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            AND
                s.ST_AVG_ChangedAt = a.ST_AVG_ChangedAt
            AND
                s.ST_AVG_UTL_ID = a.ST_AVG_UTL_ID
            AND 
                s.ST_AVG_PositedAt < a.ST_AVG_PositedAt
            ORDER BY 
                s.ST_AVG_PositedAt DESC
        ) pre
        WHERE
            a.ST_AVG_Reliability = pre.ST_AVG_Reliability
    ) u
    WHERE
        u.previous_ST_AVG_StatementType = 'A';
    DELETE a
    FROM 
        @ST_AVG_Stage_Average a
    JOIN 
        @updated u
    ON 
        u.ST_AVG_ST_ID = a.ST_AVG_ST_ID
    AND
        u.ST_AVG_ChangedAt = a.ST_AVG_ChangedAt
    AND
        u.ST_AVG_UTL_ID = a.ST_AVG_UTL_ID
    AND 
        u.previous_ST_AVG_PositedAt = a.ST_AVG_PositedAt;
    END --- (only run if necessary) ---
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
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null, 
        ST_AVG_StatementType char(1) not null
    );
    INSERT INTO @restated (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability,
        ST_AVG_UTL_ID,
        ST_AVG_StatementType 
    )
    SELECT 
        x.ST_AVG_ST_ID,
        x.Metadata_ST_AVG,
        x.ST_AVG_ChangedAt,
        CASE 
            WHEN x.previous_ST_AVG_PositedAt < x.ST_AVG_PositedAt THEN x.ST_AVG_PositedAt 
            ELSE x.previous_ST_AVG_PositedAt 
        END,
        0, -- quench the existing restatements
        x.ST_AVG_UTL_ID,
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
                h.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            AND
                h.ST_AVG_ChangedAt < a.ST_AVG_ChangedAt
            ORDER BY 
                h.ST_AVG_ChangedAt DESC,
                h.ST_AVG_PositedAt DESC
        ) pre
        WHERE
            a.ST_AVG_UTL_ID = pre.ST_AVG_UTL_ID
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
        [attributes].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
    AND
        p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
    AND
        p.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
    JOIN 
        [attributes].[ST_AVG_Stage_Average_Annex] a
    ON 
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = i.ST_AVG_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @ST_AVG_Stage_Average SELECT * FROM @retracted;
    INSERT INTO [attributes].[ST_AVG_Stage_Average_Posit] (
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    SELECT
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    FROM
        @ST_AVG_Stage_Average
    WHERE
        ST_AVG_StatementType = 'P';
    UPDATE a
    SET 
        a.ST_AVG_PositedAt = u.previous_ST_AVG_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[ST_AVG_Stage_Average_Posit] p
    ON
        u.ST_AVG_ST_ID = p.ST_AVG_ST_ID
    AND
        u.ST_AVG_ChangedAt = p.ST_AVG_ChangedAt
    AND
        u.ST_AVG_UTL_ID = p.ST_AVG_UTL_ID
    JOIN
        [attributes].[ST_AVG_Stage_Average_Annex] a
    ON 
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = u.ST_AVG_PositedAt;
    INSERT INTO [attributes].[ST_AVG_Stage_Average_Annex] (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        v.Metadata_ST_AVG,
        p.ST_AVG_ID,
        v.ST_AVG_PositedAt,
        v.ST_AVG_Reliability
    FROM
        @ST_AVG_Stage_Average v
    JOIN
        [attributes].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ST_ID = v.ST_AVG_ST_ID
    AND
        p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
    AND
        p.ST_AVG_UTL_ID = v.ST_AVG_UTL_ID
    WHERE
        ST_AVG_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum instead of INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_ST_MIN_Stage_Minimum', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_ST_MIN_Stage_Minimum];
GO
CREATE TRIGGER [attributes].[it_ST_MIN_Stage_Minimum] ON [attributes].[ST_MIN_Stage_Minimum]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ST_MIN_Stage_Minimum TABLE (
        ST_MIN_ST_ID int not null,
        Metadata_ST_MIN int not null,
        ST_MIN_PositedAt datetime2 not null,
        ST_MIN_Reliability decimal(5,2) not null,
        ST_MIN_UTL_ID tinyint not null, 
        ST_MIN_StatementType char(1) not null,
        primary key (
            ST_MIN_ST_ID asc, 
            ST_MIN_PositedAt desc
        )
    );
    INSERT INTO @ST_MIN_Stage_Minimum
    SELECT
        i.ST_MIN_ST_ID,
        i.Metadata_ST_MIN,
        i.ST_MIN_PositedAt,
        i.ST_MIN_Reliability,
        i.ST_MIN_UTL_ID,
        CASE 
            WHEN p.ST_MIN_ID is null 
            THEN 'P' -- new posit
            WHEN a.ST_MIN_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [attributes].[ST_MIN_Stage_Minimum_Posit] p
    ON
        p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
    AND
        p.ST_MIN_UTL_ID = i.ST_MIN_UTL_ID
    LEFT JOIN 
        [attributes].[ST_MIN_Stage_Minimum_Annex] a
    ON 
        a.ST_MIN_ID = p.ST_MIN_ID
    AND
        a.ST_MIN_PositedAt = i.ST_MIN_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_MIN_ID is null OR a.ST_MIN_ID is null);
    INSERT INTO @ST_MIN_Stage_Minimum (
        ST_MIN_ST_ID,
        Metadata_ST_MIN,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        ST_MIN_UTL_ID,
        ST_MIN_StatementType 
    )
    SELECT
        i.ST_MIN_ST_ID,
        a.Metadata_ST_MIN,
        a.ST_MIN_PositedAt,
        a.ST_MIN_Reliability,
        p.ST_MIN_UTL_ID,
        'X' -- existing data
    FROM
        (SELECT DISTINCT ST_MIN_ST_ID FROM @ST_MIN_Stage_Minimum) i
    JOIN
        [attributes].[ST_MIN_Stage_Minimum_Posit] p
    ON
        p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
    JOIN 
        [attributes].[ST_MIN_Stage_Minimum_Annex] a
    ON 
        a.ST_MIN_ID = p.ST_MIN_ID;
    DECLARE @retracted TABLE (
        ST_MIN_ST_ID int not null,
        Metadata_ST_MIN int not null,
        ST_MIN_PositedAt datetime2 not null,
        ST_MIN_Reliability decimal(5,2) not null,
        ST_MIN_UTL_ID tinyint not null, 
        ST_MIN_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_MIN_ST_ID,
        Metadata_ST_MIN,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        ST_MIN_UTL_ID,
        ST_MIN_StatementType 
    )
    SELECT
        ST_MIN_ST_ID,
        Metadata_ST_MIN,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        ST_MIN_UTL_ID,
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
                p.ST_MIN_ST_ID = a.ST_MIN_ST_ID
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
                p.ST_MIN_ST_ID = a.ST_MIN_ST_ID
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
    -- remove remaining (dangling) retractions
	DELETE @ST_MIN_Stage_Minimum 
	WHERE 
        ST_MIN_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            ST_MIN_StatementType 
        FROM 
            @ST_MIN_Stage_Minimum
        WHERE 
            ST_MIN_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        ST_MIN_ST_ID int not null,
        Metadata_ST_MIN int not null,
        ST_MIN_PositedAt datetime2 not null,
        ST_MIN_Reliability decimal(5,2) not null,
        ST_MIN_UTL_ID tinyint not null, 
        previous_ST_MIN_PositedAt datetime2 not null,
        primary key(
            ST_MIN_ST_ID asc, 
            ST_MIN_PositedAt desc
        )
    );
    INSERT INTO @updated (
        ST_MIN_ST_ID,
        Metadata_ST_MIN,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        ST_MIN_UTL_ID, 
        previous_ST_MIN_PositedAt
    )
    SELECT
        ST_MIN_ST_ID,
        Metadata_ST_MIN,
        ST_MIN_PositedAt,
        ST_MIN_Reliability,
        ST_MIN_UTL_ID, 
        previous_ST_MIN_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.ST_MIN_PositedAt AS previous_ST_MIN_PositedAt,
            pre.ST_MIN_StatementType AS previous_ST_MIN_StatementType
        FROM 
            @ST_MIN_Stage_Minimum a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @ST_MIN_Stage_Minimum s
            WHERE
                s.ST_MIN_ST_ID = a.ST_MIN_ST_ID
            AND
                s.ST_MIN_UTL_ID = a.ST_MIN_UTL_ID
            AND 
                s.ST_MIN_PositedAt < a.ST_MIN_PositedAt
            ORDER BY 
                s.ST_MIN_PositedAt DESC
        ) pre
        WHERE
            a.ST_MIN_Reliability = pre.ST_MIN_Reliability
    ) u
    WHERE
        u.previous_ST_MIN_StatementType = 'A';
    DELETE a
    FROM 
        @ST_MIN_Stage_Minimum a
    JOIN 
        @updated u
    ON 
        u.ST_MIN_ST_ID = a.ST_MIN_ST_ID
    AND
        u.ST_MIN_UTL_ID = a.ST_MIN_UTL_ID
    AND 
        u.previous_ST_MIN_PositedAt = a.ST_MIN_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @ST_MIN_Stage_Minimum SELECT * FROM @retracted;
    INSERT INTO [attributes].[ST_MIN_Stage_Minimum_Posit] (
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
    SELECT
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    FROM
        @ST_MIN_Stage_Minimum
    WHERE
        ST_MIN_StatementType = 'P';
    UPDATE a
    SET 
        a.ST_MIN_PositedAt = u.previous_ST_MIN_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[ST_MIN_Stage_Minimum_Posit] p
    ON
        u.ST_MIN_ST_ID = p.ST_MIN_ST_ID
    AND
        u.ST_MIN_UTL_ID = p.ST_MIN_UTL_ID
    JOIN
        [attributes].[ST_MIN_Stage_Minimum_Annex] a
    ON 
        a.ST_MIN_ID = p.ST_MIN_ID
    AND
        a.ST_MIN_PositedAt = u.ST_MIN_PositedAt;
    INSERT INTO [attributes].[ST_MIN_Stage_Minimum_Annex] (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        v.Metadata_ST_MIN,
        p.ST_MIN_ID,
        v.ST_MIN_PositedAt,
        v.ST_MIN_Reliability
    FROM
        @ST_MIN_Stage_Minimum v
    JOIN
        [attributes].[ST_MIN_Stage_Minimum_Posit] p
    ON
        p.ST_MIN_ST_ID = v.ST_MIN_ST_ID
    AND
        p.ST_MIN_UTL_ID = v.ST_MIN_UTL_ID
    WHERE
        ST_MIN_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name instead of INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [attributes].[it_AC_NAM_Actor_Name] ON [attributes].[AC_NAM_Actor_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_NAM_AC_ID smallint not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name varbinary(max) not null,
        AC_NAM_StatementType char(1) not null,
        primary key (
            AC_NAM_AC_ID asc, 
            AC_NAM_ChangedAt desc,
            AC_NAM_PositedAt desc
        )
    );
    INSERT INTO @AC_NAM_Actor_Name
    SELECT
        i.AC_NAM_AC_ID,
        i.Metadata_AC_NAM,
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
        [attributes].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
    AND
        p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
    AND
        p.AC_NAM_Actor_Name = i.AC_NAM_Actor_Name
    LEFT JOIN 
        [attributes].[AC_NAM_Actor_Name_Annex] a
    ON 
        a.AC_NAM_ID = p.AC_NAM_ID
    AND
        a.AC_NAM_PositedAt = i.AC_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_NAM_ID is null OR a.AC_NAM_ID is null);
    INSERT INTO @AC_NAM_Actor_Name (
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name,
        AC_NAM_StatementType 
    )
    SELECT
        i.AC_NAM_AC_ID,
        a.Metadata_AC_NAM,
        p.AC_NAM_ChangedAt,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Reliability,
        p.AC_NAM_Actor_Name,
        'X' -- existing data
    FROM
        (SELECT DISTINCT AC_NAM_AC_ID FROM @AC_NAM_Actor_Name) i
    JOIN
        [attributes].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
    JOIN 
        [attributes].[AC_NAM_Actor_Name_Annex] a
    ON 
        a.AC_NAM_ID = p.AC_NAM_ID;
    DECLARE @retracted TABLE (
        AC_NAM_AC_ID smallint not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name varbinary(max) not null,
        AC_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name,
        AC_NAM_StatementType 
    )
    SELECT
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
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
                p.AC_NAM_AC_ID = a.AC_NAM_AC_ID
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
                p.AC_NAM_AC_ID = a.AC_NAM_AC_ID
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
    -- remove remaining (dangling) retractions
	DELETE @AC_NAM_Actor_Name 
	WHERE 
        AC_NAM_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            AC_NAM_StatementType 
        FROM 
            @AC_NAM_Actor_Name
        WHERE 
            AC_NAM_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        AC_NAM_AC_ID smallint not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name varbinary(max) not null,
        previous_AC_NAM_PositedAt datetime2 not null,
        primary key(
            AC_NAM_AC_ID asc, 
            AC_NAM_ChangedAt desc,
            AC_NAM_PositedAt desc
        )
    );
    INSERT INTO @updated (
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name, 
        previous_AC_NAM_PositedAt
    )
    SELECT
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name, 
        previous_AC_NAM_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.AC_NAM_PositedAt AS previous_AC_NAM_PositedAt,
            pre.AC_NAM_StatementType AS previous_AC_NAM_StatementType
        FROM 
            @AC_NAM_Actor_Name a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @AC_NAM_Actor_Name s
            WHERE
                s.AC_NAM_AC_ID = a.AC_NAM_AC_ID
            AND
                s.AC_NAM_ChangedAt = a.AC_NAM_ChangedAt
            AND
                s.AC_NAM_Actor_Name = a.AC_NAM_Actor_Name
            AND 
                s.AC_NAM_PositedAt < a.AC_NAM_PositedAt
            ORDER BY 
                s.AC_NAM_PositedAt DESC
        ) pre
        WHERE
            a.AC_NAM_Reliability = pre.AC_NAM_Reliability
    ) u
    WHERE
        u.previous_AC_NAM_StatementType = 'A';
    DELETE a
    FROM 
        @AC_NAM_Actor_Name a
    JOIN 
        @updated u
    ON 
        u.AC_NAM_AC_ID = a.AC_NAM_AC_ID
    AND
        u.AC_NAM_ChangedAt = a.AC_NAM_ChangedAt
    AND
        u.AC_NAM_Actor_Name = a.AC_NAM_Actor_Name
    AND 
        u.previous_AC_NAM_PositedAt = a.AC_NAM_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @AC_NAM_Actor_Name SELECT * FROM @retracted;
    INSERT INTO [attributes].[AC_NAM_Actor_Name_Posit] (
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    FROM
        @AC_NAM_Actor_Name
    WHERE
        AC_NAM_StatementType = 'P';
    UPDATE a
    SET 
        a.AC_NAM_PositedAt = u.previous_AC_NAM_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[AC_NAM_Actor_Name_Posit] p
    ON
        u.AC_NAM_AC_ID = p.AC_NAM_AC_ID
    AND
        u.AC_NAM_ChangedAt = p.AC_NAM_ChangedAt
    AND
        u.AC_NAM_Actor_Name = p.AC_NAM_Actor_Name
    JOIN
        [attributes].[AC_NAM_Actor_Name_Annex] a
    ON 
        a.AC_NAM_ID = p.AC_NAM_ID
    AND
        a.AC_NAM_PositedAt = u.AC_NAM_PositedAt;
    INSERT INTO [attributes].[AC_NAM_Actor_Name_Annex] (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        v.Metadata_AC_NAM,
        p.AC_NAM_ID,
        v.AC_NAM_PositedAt,
        v.AC_NAM_Reliability
    FROM
        @AC_NAM_Actor_Name v
    JOIN
        [attributes].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_NAM_AC_ID = v.AC_NAM_AC_ID
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
IF Object_ID('attributes.it_AC_GEN_Actor_Gender', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_AC_GEN_Actor_Gender];
GO
CREATE TRIGGER [attributes].[it_AC_GEN_Actor_Gender] ON [attributes].[AC_GEN_Actor_Gender]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AC_GEN_Actor_Gender TABLE (
        AC_GEN_AC_ID smallint not null,
        Metadata_AC_GEN int not null,
        AC_GEN_PositedAt datetime2 not null,
        AC_GEN_Reliability decimal(5,2) not null,
        AC_GEN_GEN_ID tinyint not null, 
        AC_GEN_StatementType char(1) not null,
        primary key (
            AC_GEN_AC_ID asc, 
            AC_GEN_PositedAt desc
        )
    );
    INSERT INTO @AC_GEN_Actor_Gender
    SELECT
        i.AC_GEN_AC_ID,
        i.Metadata_AC_GEN,
        i.AC_GEN_PositedAt,
        i.AC_GEN_Reliability,
        i.AC_GEN_GEN_ID,
        CASE 
            WHEN p.AC_GEN_ID is null 
            THEN 'P' -- new posit
            WHEN a.AC_GEN_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [attributes].[AC_GEN_Actor_Gender_Posit] p
    ON
        p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
    AND
        p.AC_GEN_GEN_ID = i.AC_GEN_GEN_ID
    LEFT JOIN 
        [attributes].[AC_GEN_Actor_Gender_Annex] a
    ON 
        a.AC_GEN_ID = p.AC_GEN_ID
    AND
        a.AC_GEN_PositedAt = i.AC_GEN_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_GEN_ID is null OR a.AC_GEN_ID is null);
    INSERT INTO @AC_GEN_Actor_Gender (
        AC_GEN_AC_ID,
        Metadata_AC_GEN,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        AC_GEN_GEN_ID,
        AC_GEN_StatementType 
    )
    SELECT
        i.AC_GEN_AC_ID,
        a.Metadata_AC_GEN,
        a.AC_GEN_PositedAt,
        a.AC_GEN_Reliability,
        p.AC_GEN_GEN_ID,
        'X' -- existing data
    FROM
        (SELECT DISTINCT AC_GEN_AC_ID FROM @AC_GEN_Actor_Gender) i
    JOIN
        [attributes].[AC_GEN_Actor_Gender_Posit] p
    ON
        p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
    JOIN 
        [attributes].[AC_GEN_Actor_Gender_Annex] a
    ON 
        a.AC_GEN_ID = p.AC_GEN_ID;
    DECLARE @retracted TABLE (
        AC_GEN_AC_ID smallint not null,
        Metadata_AC_GEN int not null,
        AC_GEN_PositedAt datetime2 not null,
        AC_GEN_Reliability decimal(5,2) not null,
        AC_GEN_GEN_ID tinyint not null, 
        AC_GEN_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        AC_GEN_AC_ID,
        Metadata_AC_GEN,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        AC_GEN_GEN_ID,
        AC_GEN_StatementType 
    )
    SELECT
        AC_GEN_AC_ID,
        Metadata_AC_GEN,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        AC_GEN_GEN_ID,
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
                p.AC_GEN_AC_ID = a.AC_GEN_AC_ID
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
                p.AC_GEN_AC_ID = a.AC_GEN_AC_ID
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
    -- remove remaining (dangling) retractions
	DELETE @AC_GEN_Actor_Gender 
	WHERE 
        AC_GEN_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            AC_GEN_StatementType 
        FROM 
            @AC_GEN_Actor_Gender
        WHERE 
            AC_GEN_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        AC_GEN_AC_ID smallint not null,
        Metadata_AC_GEN int not null,
        AC_GEN_PositedAt datetime2 not null,
        AC_GEN_Reliability decimal(5,2) not null,
        AC_GEN_GEN_ID tinyint not null, 
        previous_AC_GEN_PositedAt datetime2 not null,
        primary key(
            AC_GEN_AC_ID asc, 
            AC_GEN_PositedAt desc
        )
    );
    INSERT INTO @updated (
        AC_GEN_AC_ID,
        Metadata_AC_GEN,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        AC_GEN_GEN_ID, 
        previous_AC_GEN_PositedAt
    )
    SELECT
        AC_GEN_AC_ID,
        Metadata_AC_GEN,
        AC_GEN_PositedAt,
        AC_GEN_Reliability,
        AC_GEN_GEN_ID, 
        previous_AC_GEN_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.AC_GEN_PositedAt AS previous_AC_GEN_PositedAt,
            pre.AC_GEN_StatementType AS previous_AC_GEN_StatementType
        FROM 
            @AC_GEN_Actor_Gender a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @AC_GEN_Actor_Gender s
            WHERE
                s.AC_GEN_AC_ID = a.AC_GEN_AC_ID
            AND
                s.AC_GEN_GEN_ID = a.AC_GEN_GEN_ID
            AND 
                s.AC_GEN_PositedAt < a.AC_GEN_PositedAt
            ORDER BY 
                s.AC_GEN_PositedAt DESC
        ) pre
        WHERE
            a.AC_GEN_Reliability = pre.AC_GEN_Reliability
    ) u
    WHERE
        u.previous_AC_GEN_StatementType = 'A';
    DELETE a
    FROM 
        @AC_GEN_Actor_Gender a
    JOIN 
        @updated u
    ON 
        u.AC_GEN_AC_ID = a.AC_GEN_AC_ID
    AND
        u.AC_GEN_GEN_ID = a.AC_GEN_GEN_ID
    AND 
        u.previous_AC_GEN_PositedAt = a.AC_GEN_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @AC_GEN_Actor_Gender SELECT * FROM @retracted;
    INSERT INTO [attributes].[AC_GEN_Actor_Gender_Posit] (
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
    SELECT
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    FROM
        @AC_GEN_Actor_Gender
    WHERE
        AC_GEN_StatementType = 'P';
    UPDATE a
    SET 
        a.AC_GEN_PositedAt = u.previous_AC_GEN_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[AC_GEN_Actor_Gender_Posit] p
    ON
        u.AC_GEN_AC_ID = p.AC_GEN_AC_ID
    AND
        u.AC_GEN_GEN_ID = p.AC_GEN_GEN_ID
    JOIN
        [attributes].[AC_GEN_Actor_Gender_Annex] a
    ON 
        a.AC_GEN_ID = p.AC_GEN_ID
    AND
        a.AC_GEN_PositedAt = u.AC_GEN_PositedAt;
    INSERT INTO [attributes].[AC_GEN_Actor_Gender_Annex] (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        v.Metadata_AC_GEN,
        p.AC_GEN_ID,
        v.AC_GEN_PositedAt,
        v.AC_GEN_Reliability
    FROM
        @AC_GEN_Actor_Gender v
    JOIN
        [attributes].[AC_GEN_Actor_Gender_Posit] p
    ON
        p.AC_GEN_AC_ID = v.AC_GEN_AC_ID
    AND
        p.AC_GEN_GEN_ID = v.AC_GEN_GEN_ID
    WHERE
        AC_GEN_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel instead of INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_AC_PLV_Actor_ProfessionalLevel', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_AC_PLV_Actor_ProfessionalLevel];
GO
CREATE TRIGGER [attributes].[it_AC_PLV_Actor_ProfessionalLevel] ON [attributes].[AC_PLV_Actor_ProfessionalLevel]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AC_PLV_Actor_ProfessionalLevel TABLE (
        AC_PLV_AC_ID smallint not null,
        Metadata_AC_PLV int not null,
        AC_PLV_ChangedAt datetime2 not null,
        AC_PLV_PositedAt datetime2 not null,
        AC_PLV_Reliability decimal(5,2) not null,
        AC_PLV_PLV_ID tinyint not null, 
        AC_PLV_StatementType char(1) not null,
        primary key (
            AC_PLV_AC_ID asc, 
            AC_PLV_ChangedAt desc,
            AC_PLV_PositedAt desc
        )
    );
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel
    SELECT
        i.AC_PLV_AC_ID,
        i.Metadata_AC_PLV,
        i.AC_PLV_ChangedAt,
        i.AC_PLV_PositedAt,
        i.AC_PLV_Reliability,
        i.AC_PLV_PLV_ID,
        CASE 
            WHEN p.AC_PLV_ID is null 
            THEN 'P' -- new posit
            WHEN a.AC_PLV_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
    AND
        p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
    AND
        p.AC_PLV_PLV_ID = i.AC_PLV_PLV_ID
    LEFT JOIN 
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Annex] a
    ON 
        a.AC_PLV_ID = p.AC_PLV_ID
    AND
        a.AC_PLV_PositedAt = i.AC_PLV_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_PLV_ID is null OR a.AC_PLV_ID is null);
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel (
        AC_PLV_AC_ID,
        Metadata_AC_PLV,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        AC_PLV_PLV_ID,
        AC_PLV_StatementType 
    )
    SELECT
        i.AC_PLV_AC_ID,
        a.Metadata_AC_PLV,
        p.AC_PLV_ChangedAt,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Reliability,
        p.AC_PLV_PLV_ID,
        'X' -- existing data
    FROM
        (SELECT DISTINCT AC_PLV_AC_ID FROM @AC_PLV_Actor_ProfessionalLevel) i
    JOIN
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
    JOIN 
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Annex] a
    ON 
        a.AC_PLV_ID = p.AC_PLV_ID;
    DECLARE @retracted TABLE (
        AC_PLV_AC_ID smallint not null,
        Metadata_AC_PLV int not null,
        AC_PLV_ChangedAt datetime2 not null,
        AC_PLV_PositedAt datetime2 not null,
        AC_PLV_Reliability decimal(5,2) not null,
        AC_PLV_PLV_ID tinyint not null, 
        AC_PLV_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        AC_PLV_AC_ID,
        Metadata_AC_PLV,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        AC_PLV_PLV_ID,
        AC_PLV_StatementType 
    )
    SELECT
        AC_PLV_AC_ID,
        Metadata_AC_PLV,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        AC_PLV_PLV_ID,
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
                p.AC_PLV_AC_ID = a.AC_PLV_AC_ID
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
                p.AC_PLV_AC_ID = a.AC_PLV_AC_ID
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
    -- remove remaining (dangling) retractions
	DELETE @AC_PLV_Actor_ProfessionalLevel 
	WHERE 
        AC_PLV_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            AC_PLV_StatementType 
        FROM 
            @AC_PLV_Actor_ProfessionalLevel
        WHERE 
            AC_PLV_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        AC_PLV_AC_ID smallint not null,
        Metadata_AC_PLV int not null,
        AC_PLV_ChangedAt datetime2 not null,
        AC_PLV_PositedAt datetime2 not null,
        AC_PLV_Reliability decimal(5,2) not null,
        AC_PLV_PLV_ID tinyint not null, 
        previous_AC_PLV_PositedAt datetime2 not null,
        primary key(
            AC_PLV_AC_ID asc, 
            AC_PLV_ChangedAt desc,
            AC_PLV_PositedAt desc
        )
    );
    INSERT INTO @updated (
        AC_PLV_AC_ID,
        Metadata_AC_PLV,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        AC_PLV_PLV_ID, 
        previous_AC_PLV_PositedAt
    )
    SELECT
        AC_PLV_AC_ID,
        Metadata_AC_PLV,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability,
        AC_PLV_PLV_ID, 
        previous_AC_PLV_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.AC_PLV_PositedAt AS previous_AC_PLV_PositedAt,
            pre.AC_PLV_StatementType AS previous_AC_PLV_StatementType
        FROM 
            @AC_PLV_Actor_ProfessionalLevel a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @AC_PLV_Actor_ProfessionalLevel s
            WHERE
                s.AC_PLV_AC_ID = a.AC_PLV_AC_ID
            AND
                s.AC_PLV_ChangedAt = a.AC_PLV_ChangedAt
            AND
                s.AC_PLV_PLV_ID = a.AC_PLV_PLV_ID
            AND 
                s.AC_PLV_PositedAt < a.AC_PLV_PositedAt
            ORDER BY 
                s.AC_PLV_PositedAt DESC
        ) pre
        WHERE
            a.AC_PLV_Reliability = pre.AC_PLV_Reliability
    ) u
    WHERE
        u.previous_AC_PLV_StatementType = 'A';
    DELETE a
    FROM 
        @AC_PLV_Actor_ProfessionalLevel a
    JOIN 
        @updated u
    ON 
        u.AC_PLV_AC_ID = a.AC_PLV_AC_ID
    AND
        u.AC_PLV_ChangedAt = a.AC_PLV_ChangedAt
    AND
        u.AC_PLV_PLV_ID = a.AC_PLV_PLV_ID
    AND 
        u.previous_AC_PLV_PositedAt = a.AC_PLV_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel SELECT * FROM @retracted;
    INSERT INTO [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit] (
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
    SELECT
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    FROM
        @AC_PLV_Actor_ProfessionalLevel
    WHERE
        AC_PLV_StatementType = 'P';
    UPDATE a
    SET 
        a.AC_PLV_PositedAt = u.previous_AC_PLV_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        u.AC_PLV_AC_ID = p.AC_PLV_AC_ID
    AND
        u.AC_PLV_ChangedAt = p.AC_PLV_ChangedAt
    AND
        u.AC_PLV_PLV_ID = p.AC_PLV_PLV_ID
    JOIN
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Annex] a
    ON 
        a.AC_PLV_ID = p.AC_PLV_ID
    AND
        a.AC_PLV_PositedAt = u.AC_PLV_PositedAt;
    INSERT INTO [attributes].[AC_PLV_Actor_ProfessionalLevel_Annex] (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        v.Metadata_AC_PLV,
        p.AC_PLV_ID,
        v.AC_PLV_PositedAt,
        v.AC_PLV_Reliability
    FROM
        @AC_PLV_Actor_ProfessionalLevel v
    JOIN
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        p.AC_PLV_AC_ID = v.AC_PLV_AC_ID
    AND
        p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
    AND
        p.AC_PLV_PLV_ID = v.AC_PLV_PLV_ID
    WHERE
        AC_PLV_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Program_Name instead of INSERT trigger on PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_PR_NAM_Program_Name', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_PR_NAM_Program_Name];
GO
CREATE TRIGGER [attributes].[it_PR_NAM_Program_Name] ON [attributes].[PR_NAM_Program_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PR_NAM_Program_Name TABLE (
        PR_NAM_PR_ID bigint not null,
        Metadata_PR_NAM int not null,
        PR_NAM_PositedAt datetime2 not null,
        PR_NAM_Reliability decimal(5,2) not null,
        PR_NAM_Program_Name nvarchar(42) not null,
        PR_NAM_StatementType char(1) not null,
        primary key (
            PR_NAM_PR_ID asc, 
            PR_NAM_PositedAt desc
        )
    );
    INSERT INTO @PR_NAM_Program_Name
    SELECT
        i.PR_NAM_PR_ID,
        i.Metadata_PR_NAM,
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
        [attributes].[PR_NAM_Program_Name_Posit] p
    ON
        p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
    AND
        p.PR_NAM_Program_Name = i.PR_NAM_Program_Name
    LEFT JOIN 
        [attributes].[PR_NAM_Program_Name_Annex] a
    ON 
        a.PR_NAM_ID = p.PR_NAM_ID
    AND
        a.PR_NAM_PositedAt = i.PR_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.PR_NAM_ID is null OR a.PR_NAM_ID is null);
    INSERT INTO @PR_NAM_Program_Name (
        PR_NAM_PR_ID,
        Metadata_PR_NAM,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name,
        PR_NAM_StatementType 
    )
    SELECT
        i.PR_NAM_PR_ID,
        a.Metadata_PR_NAM,
        a.PR_NAM_PositedAt,
        a.PR_NAM_Reliability,
        p.PR_NAM_Program_Name,
        'X' -- existing data
    FROM
        (SELECT DISTINCT PR_NAM_PR_ID FROM @PR_NAM_Program_Name) i
    JOIN
        [attributes].[PR_NAM_Program_Name_Posit] p
    ON
        p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
    JOIN 
        [attributes].[PR_NAM_Program_Name_Annex] a
    ON 
        a.PR_NAM_ID = p.PR_NAM_ID;
    DECLARE @retracted TABLE (
        PR_NAM_PR_ID bigint not null,
        Metadata_PR_NAM int not null,
        PR_NAM_PositedAt datetime2 not null,
        PR_NAM_Reliability decimal(5,2) not null,
        PR_NAM_Program_Name nvarchar(42) not null,
        PR_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        PR_NAM_PR_ID,
        Metadata_PR_NAM,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name,
        PR_NAM_StatementType 
    )
    SELECT
        PR_NAM_PR_ID,
        Metadata_PR_NAM,
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
                p.PR_NAM_PR_ID = a.PR_NAM_PR_ID
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
                p.PR_NAM_PR_ID = a.PR_NAM_PR_ID
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
    -- remove remaining (dangling) retractions
	DELETE @PR_NAM_Program_Name 
	WHERE 
        PR_NAM_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            PR_NAM_StatementType 
        FROM 
            @PR_NAM_Program_Name
        WHERE 
            PR_NAM_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        PR_NAM_PR_ID bigint not null,
        Metadata_PR_NAM int not null,
        PR_NAM_PositedAt datetime2 not null,
        PR_NAM_Reliability decimal(5,2) not null,
        PR_NAM_Program_Name nvarchar(42) not null,
        previous_PR_NAM_PositedAt datetime2 not null,
        primary key(
            PR_NAM_PR_ID asc, 
            PR_NAM_PositedAt desc
        )
    );
    INSERT INTO @updated (
        PR_NAM_PR_ID,
        Metadata_PR_NAM,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name, 
        previous_PR_NAM_PositedAt
    )
    SELECT
        PR_NAM_PR_ID,
        Metadata_PR_NAM,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name, 
        previous_PR_NAM_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.PR_NAM_PositedAt AS previous_PR_NAM_PositedAt,
            pre.PR_NAM_StatementType AS previous_PR_NAM_StatementType
        FROM 
            @PR_NAM_Program_Name a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @PR_NAM_Program_Name s
            WHERE
                s.PR_NAM_PR_ID = a.PR_NAM_PR_ID
            AND
                s.PR_NAM_Program_Name = a.PR_NAM_Program_Name
            AND 
                s.PR_NAM_PositedAt < a.PR_NAM_PositedAt
            ORDER BY 
                s.PR_NAM_PositedAt DESC
        ) pre
        WHERE
            a.PR_NAM_Reliability = pre.PR_NAM_Reliability
    ) u
    WHERE
        u.previous_PR_NAM_StatementType = 'A';
    DELETE a
    FROM 
        @PR_NAM_Program_Name a
    JOIN 
        @updated u
    ON 
        u.PR_NAM_PR_ID = a.PR_NAM_PR_ID
    AND
        u.PR_NAM_Program_Name = a.PR_NAM_Program_Name
    AND 
        u.previous_PR_NAM_PositedAt = a.PR_NAM_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @PR_NAM_Program_Name SELECT * FROM @retracted;
    INSERT INTO [attributes].[PR_NAM_Program_Name_Posit] (
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    )
    SELECT
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    FROM
        @PR_NAM_Program_Name
    WHERE
        PR_NAM_StatementType = 'P';
    UPDATE a
    SET 
        a.PR_NAM_PositedAt = u.previous_PR_NAM_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[PR_NAM_Program_Name_Posit] p
    ON
        u.PR_NAM_PR_ID = p.PR_NAM_PR_ID
    AND
        u.PR_NAM_Program_Name = p.PR_NAM_Program_Name
    JOIN
        [attributes].[PR_NAM_Program_Name_Annex] a
    ON 
        a.PR_NAM_ID = p.PR_NAM_ID
    AND
        a.PR_NAM_PositedAt = u.PR_NAM_PositedAt;
    INSERT INTO [attributes].[PR_NAM_Program_Name_Annex] (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        v.Metadata_PR_NAM,
        p.PR_NAM_ID,
        v.PR_NAM_PositedAt,
        v.PR_NAM_Reliability
    FROM
        @PR_NAM_Program_Name v
    JOIN
        [attributes].[PR_NAM_Program_Name_Posit] p
    ON
        p.PR_NAM_PR_ID = v.PR_NAM_PR_ID
    AND
        p.PR_NAM_Program_Name = v.PR_NAM_Program_Name
    WHERE
        PR_NAM_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Program_Length instead of INSERT trigger on PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_PR_LEN_Program_Length', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_PR_LEN_Program_Length];
GO
CREATE TRIGGER [attributes].[it_PR_LEN_Program_Length] ON [attributes].[PR_LEN_Program_Length]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PR_LEN_Program_Length TABLE (
        PR_LEN_PR_ID bigint not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null,
        primary key (
            PR_LEN_PR_ID asc, 
            PR_LEN_ChangedAt desc,
            PR_LEN_PositedAt desc
        )
    );
    INSERT INTO @PR_LEN_Program_Length
    SELECT
        i.PR_LEN_PR_ID,
        i.Metadata_PR_LEN,
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
        [attributes].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
    AND
        p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
    AND
        p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
    LEFT JOIN 
        [attributes].[PR_LEN_Program_Length_Annex] a
    ON 
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = i.PR_LEN_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.PR_LEN_ID is null OR a.PR_LEN_ID is null);
    INSERT INTO @PR_LEN_Program_Length (
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType 
    )
    SELECT
        i.PR_LEN_PR_ID,
        a.Metadata_PR_LEN,
        p.PR_LEN_ChangedAt,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Reliability,
        p.PR_LEN_Program_Length,
        'X' -- existing data
    FROM
        (SELECT DISTINCT PR_LEN_PR_ID FROM @PR_LEN_Program_Length) i
    JOIN
        [attributes].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
    JOIN 
        [attributes].[PR_LEN_Program_Length_Annex] a
    ON 
        a.PR_LEN_ID = p.PR_LEN_ID;
    DECLARE @retracted TABLE (
        PR_LEN_PR_ID bigint not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType 
    )
    SELECT
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
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
                p.PR_LEN_PR_ID = a.PR_LEN_PR_ID
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
                p.PR_LEN_PR_ID = a.PR_LEN_PR_ID
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
    -- remove remaining (dangling) retractions
	DELETE @PR_LEN_Program_Length 
	WHERE 
        PR_LEN_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1 
            PR_LEN_StatementType 
        FROM 
            @PR_LEN_Program_Length
        WHERE 
            PR_LEN_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        PR_LEN_PR_ID bigint not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        previous_PR_LEN_PositedAt datetime2 not null,
        primary key(
            PR_LEN_PR_ID asc, 
            PR_LEN_ChangedAt desc,
            PR_LEN_PositedAt desc
        )
    );
    INSERT INTO @updated (
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length, 
        previous_PR_LEN_PositedAt
    )
    SELECT
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length, 
        previous_PR_LEN_PositedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*,
            pre.PR_LEN_PositedAt AS previous_PR_LEN_PositedAt,
            pre.PR_LEN_StatementType AS previous_PR_LEN_StatementType
        FROM 
            @PR_LEN_Program_Length a
        CROSS APPLY (
            SELECT TOP 1
                * 
            FROM 
                @PR_LEN_Program_Length s
            WHERE
                s.PR_LEN_PR_ID = a.PR_LEN_PR_ID
            AND
                s.PR_LEN_ChangedAt = a.PR_LEN_ChangedAt
            AND
                s.PR_LEN_Program_Length = a.PR_LEN_Program_Length
            AND 
                s.PR_LEN_PositedAt < a.PR_LEN_PositedAt
            ORDER BY 
                s.PR_LEN_PositedAt DESC
        ) pre
        WHERE
            a.PR_LEN_Reliability = pre.PR_LEN_Reliability
    ) u
    WHERE
        u.previous_PR_LEN_StatementType = 'A';
    DELETE a
    FROM 
        @PR_LEN_Program_Length a
    JOIN 
        @updated u
    ON 
        u.PR_LEN_PR_ID = a.PR_LEN_PR_ID
    AND
        u.PR_LEN_ChangedAt = a.PR_LEN_ChangedAt
    AND
        u.PR_LEN_Program_Length = a.PR_LEN_Program_Length
    AND 
        u.previous_PR_LEN_PositedAt = a.PR_LEN_PositedAt;
    END --- (only run if necessary) ---
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
        PR_LEN_PR_ID bigint not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null
    );
    INSERT INTO @restated (
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability,
        PR_LEN_Program_Length,
        PR_LEN_StatementType 
    )
    SELECT 
        x.PR_LEN_PR_ID,
        x.Metadata_PR_LEN,
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
                h.PR_LEN_PR_ID = a.PR_LEN_PR_ID
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
        [attributes].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
    AND
        p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
    AND
        p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
    JOIN 
        [attributes].[PR_LEN_Program_Length_Annex] a
    ON 
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = i.PR_LEN_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @PR_LEN_Program_Length SELECT * FROM @retracted;
    INSERT INTO [attributes].[PR_LEN_Program_Length_Posit] (
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    SELECT
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    FROM
        @PR_LEN_Program_Length
    WHERE
        PR_LEN_StatementType = 'P';
    UPDATE a
    SET 
        a.PR_LEN_PositedAt = u.previous_PR_LEN_PositedAt
    FROM 
        @updated u
    JOIN
        [attributes].[PR_LEN_Program_Length_Posit] p
    ON
        u.PR_LEN_PR_ID = p.PR_LEN_PR_ID
    AND
        u.PR_LEN_ChangedAt = p.PR_LEN_ChangedAt
    AND
        u.PR_LEN_Program_Length = p.PR_LEN_Program_Length
    JOIN
        [attributes].[PR_LEN_Program_Length_Annex] a
    ON 
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = u.PR_LEN_PositedAt;
    INSERT INTO [attributes].[PR_LEN_Program_Length_Annex] (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        v.Metadata_PR_LEN,
        p.PR_LEN_ID,
        v.PR_LEN_PositedAt,
        v.PR_LEN_Reliability
    FROM
        @PR_LEN_Program_Length v
    JOIN
        [attributes].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_LEN_PR_ID = v.PR_LEN_PR_ID
    AND
        p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
    AND
        p.PR_LEN_Program_Length = v.PR_LEN_Program_Length
    WHERE
        PR_LEN_StatementType in ('P', 'A');
END
GO
