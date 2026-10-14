-- TIE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------------
--
-- Ties may be prevented from storing restatements.
-- A restatement is when the same (non-key) values occurs for two adjacent points
-- in changing time. Note that restatement checking is not done for
-- unreliable information as this could prevent demotion.
--
-- If actual deletes are made, the remaining information will not
-- be checked for restatements.
--
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_PR_content_ST_location_EV_of (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rt_PR_content_ST_location_EV_of', 'TR') IS NOT NULL
DROP TRIGGER [ties].[rt_PR_content_ST_location_EV_of];
GO
CREATE TRIGGER [ties].[rt_PR_content_ST_location_EV_of] ON [ties].[PR_content_ST_location_EV_of]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @inserted TABLE (
        Metadata_PR_content_ST_location_EV_of int not null,
        PR_content_ST_location_EV_of_ChangedAt datetime2 not null,
        PR_ID_content bigint not null,
        ST_ID_location int not null,
        EV_ID_of numeric(12,0) not null,
        primary key (
            PR_ID_content asc,
            ST_ID_location asc,
            EV_ID_of asc,
            PR_content_ST_location_EV_of_ChangedAt desc
        )
    );
    INSERT INTO @inserted (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    SELECT
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    FROM
        inserted;
    INSERT INTO @inserted (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    SELECT
        p.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ChangedAt,
        p.PR_ID_content,
        p.ST_ID_location,
        p.EV_ID_of
    FROM (
        SELECT DISTINCT
            PR_ID_content,
            ST_ID_location,
            EV_ID_of
        FROM 
            @inserted 
    ) i
    JOIN
        [ties].[PR_content_ST_location_EV_of] p
    ON
        p.PR_ID_content = i.PR_ID_content
    AND
        p.ST_ID_location = i.ST_ID_location
    AND
        p.EV_ID_of = i.EV_ID_of
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            @inserted x
        WHERE 
            x.PR_content_ST_location_EV_of_ChangedAt = p.PR_content_ST_location_EV_of_ChangedAt
        AND
            x.PR_ID_content = i.PR_ID_content
        AND
            x.ST_ID_location = i.ST_ID_location
        AND
            x.EV_ID_of = i.EV_ID_of
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @inserted i
        CROSS APPLY (
            SELECT TOP 1
                PR_ID_content,
                ST_ID_location,
                EV_ID_of,
                PR_content_ST_location_EV_of_ChangedAt
            FROM
                @inserted h
            WHERE
                h.PR_ID_content = i.PR_ID_content
            AND
                h.ST_ID_location = i.ST_ID_location
            AND
                h.EV_ID_of = i.EV_ID_of
            AND
                h.PR_content_ST_location_EV_of_ChangedAt < i.PR_content_ST_location_EV_of_ChangedAt
            ORDER BY 
                h.PR_content_ST_location_EV_of_ChangedAt DESC
        ) pre 
        WHERE
            i.PR_ID_content = pre.PR_ID_content
        AND
            i.ST_ID_location = pre.ST_ID_location
        AND
            i.EV_ID_of = pre.EV_ID_of
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in PR_content_ST_location_EV_of for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
