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
-- rt_AC_part_PR_in_RAT_got (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rt_AC_part_PR_in_RAT_got', 'TR') IS NOT NULL
DROP TRIGGER [ties].[rt_AC_part_PR_in_RAT_got];
GO
CREATE TRIGGER [ties].[rt_AC_part_PR_in_RAT_got] ON [ties].[AC_part_PR_in_RAT_got_Annex]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @inserted TABLE (
        AC_part_PR_in_RAT_got_ID int not null,
        Metadata_AC_part_PR_in_RAT_got int not null,
        AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
        AC_part_PR_in_RAT_got_PositedAt datetime2 not null,
        AC_part_PR_in_RAT_got_Reliability decimal(5,2) not null,
        AC_ID_part smallint not null,
        PR_ID_in bigint not null,
        RAT_ID_got tinyint not null,
        primary key (
            AC_ID_part asc,
            PR_ID_in asc,
            AC_part_PR_in_RAT_got_ChangedAt desc,
            AC_part_PR_in_RAT_got_PositedAt desc
        ), 
        unique ( 
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_PositedAt
        )
    );
    INSERT INTO @inserted (
        AC_part_PR_in_RAT_got_ID,
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    ) 
    SELECT
        i.AC_part_PR_in_RAT_got_ID,
        i.Metadata_AC_part_PR_in_RAT_got,
        p.AC_part_PR_in_RAT_got_ChangedAt,
        i.AC_part_PR_in_RAT_got_PositedAt,
        i.AC_part_PR_in_RAT_got_Reliability,
        p.AC_ID_part,
        p.PR_ID_in,
        p.RAT_ID_got
    FROM
        inserted i
    JOIN 
        [ties].[AC_part_PR_in_RAT_got_Posit] p
    ON 
        p.AC_part_PR_in_RAT_got_ID = i.AC_part_PR_in_RAT_got_ID; -- the posit has already been created
    INSERT INTO @inserted (
        AC_part_PR_in_RAT_got_ID,
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    ) 
    SELECT
        p.AC_part_PR_in_RAT_got_ID,
        p.Metadata_AC_part_PR_in_RAT_got,
        p.AC_part_PR_in_RAT_got_ChangedAt,
        p.AC_part_PR_in_RAT_got_PositedAt,
        p.AC_part_PR_in_RAT_got_Reliability,
        p.AC_ID_part,
        p.PR_ID_in,
        p.RAT_ID_got
    FROM (
        SELECT DISTINCT
            AC_ID_part,
            PR_ID_in
        FROM 
            @inserted 
    ) i
    JOIN
        [ties].[AC_part_PR_in_RAT_got] p
    ON
        p.AC_ID_part = i.AC_ID_part
    AND
        p.PR_ID_in = i.PR_ID_in
    LEFT JOIN 
        @inserted x
    ON
        x.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    AND
        x.AC_part_PR_in_RAT_got_PositedAt = p.AC_part_PR_in_RAT_got_PositedAt
    WHERE
        x.AC_part_PR_in_RAT_got_ID is null;
    -- no need to check retracted information
    DELETE a 
    FROM 
        @inserted a
    OUTER APPLY (
        SELECT TOP 1
            x.AC_part_PR_in_RAT_got_Reliability
        FROM 
            @inserted x
        WHERE
            x.AC_part_PR_in_RAT_got_ID = a.AC_part_PR_in_RAT_got_ID
        AND
            x.AC_part_PR_in_RAT_got_PositedAt < a.AC_part_PR_in_RAT_got_PositedAt
        ORDER BY
            x.AC_part_PR_in_RAT_got_PositedAt DESC
    ) pre 
    OUTER APPLY (
        SELECT TOP 1
            x.AC_part_PR_in_RAT_got_Reliability
        FROM 
            @inserted x
        WHERE
            x.AC_part_PR_in_RAT_got_ID = a.AC_part_PR_in_RAT_got_ID
        AND
            x.AC_part_PR_in_RAT_got_PositedAt > a.AC_part_PR_in_RAT_got_PositedAt
        ORDER BY
            x.AC_part_PR_in_RAT_got_PositedAt ASC
    ) fol 
    WHERE
        (a.AC_part_PR_in_RAT_got_Reliability = 1 AND fol.AC_part_PR_in_RAT_got_Reliability = 0)
    OR
        (a.AC_part_PR_in_RAT_got_Reliability = 0 AND pre.AC_part_PR_in_RAT_got_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @inserted a
        CROSS APPLY (
            SELECT TOP 1
                AC_ID_part,
                PR_ID_in,
                RAT_ID_got,
                AC_part_PR_in_RAT_got_ChangedAt
            FROM
                AC_part_PR_in_RAT_got h
            WHERE
                h.AC_ID_part = a.AC_ID_part
            AND
                h.PR_ID_in = a.PR_ID_in
            AND
                h.AC_part_PR_in_RAT_got_ChangedAt < a.AC_part_PR_in_RAT_got_ChangedAt
            ORDER BY 
                h.AC_part_PR_in_RAT_got_ChangedAt DESC,
                h.AC_part_PR_in_RAT_got_PositedAt DESC
        ) pre 
        WHERE
            a.AC_ID_part = pre.AC_ID_part
        AND
            a.PR_ID_in = pre.PR_ID_in
        AND
            a.RAT_ID_got = pre.RAT_ID_got
        AND
            a.AC_part_PR_in_RAT_got_Reliability = 1
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in AC_part_PR_in_RAT_got for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_PR_content_ST_location_EV_of (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rt_PR_content_ST_location_EV_of', 'TR') IS NOT NULL
DROP TRIGGER [ties].[rt_PR_content_ST_location_EV_of];
GO
CREATE TRIGGER [ties].[rt_PR_content_ST_location_EV_of] ON [ties].[PR_content_ST_location_EV_of_Annex]
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @inserted TABLE (
        PR_content_ST_location_EV_of_ID int not null,
        Metadata_PR_content_ST_location_EV_of int not null,
        PR_content_ST_location_EV_of_ChangedAt datetime2 not null,
        PR_content_ST_location_EV_of_PositedAt datetime2 not null,
        PR_content_ST_location_EV_of_Reliability decimal(5,2) not null,
        PR_ID_content bigint not null,
        ST_ID_location int not null,
        EV_ID_of numeric(12,0) not null,
        primary key (
            PR_ID_content asc,
            ST_ID_location asc,
            EV_ID_of asc,
            PR_content_ST_location_EV_of_ChangedAt desc,
            PR_content_ST_location_EV_of_PositedAt desc
        ), 
        unique ( 
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_PositedAt
        )
    );
    INSERT INTO @inserted (
        PR_content_ST_location_EV_of_ID,
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    ) 
    SELECT
        i.PR_content_ST_location_EV_of_ID,
        i.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ChangedAt,
        i.PR_content_ST_location_EV_of_PositedAt,
        i.PR_content_ST_location_EV_of_Reliability,
        p.PR_ID_content,
        p.ST_ID_location,
        p.EV_ID_of
    FROM
        inserted i
    JOIN 
        [ties].[PR_content_ST_location_EV_of_Posit] p
    ON 
        p.PR_content_ST_location_EV_of_ID = i.PR_content_ST_location_EV_of_ID; -- the posit has already been created
    INSERT INTO @inserted (
        PR_content_ST_location_EV_of_ID,
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    ) 
    SELECT
        p.PR_content_ST_location_EV_of_ID,
        p.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ChangedAt,
        p.PR_content_ST_location_EV_of_PositedAt,
        p.PR_content_ST_location_EV_of_Reliability,
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
    LEFT JOIN 
        @inserted x
    ON
        x.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    AND
        x.PR_content_ST_location_EV_of_PositedAt = p.PR_content_ST_location_EV_of_PositedAt
    WHERE
        x.PR_content_ST_location_EV_of_ID is null;
    -- no need to check retracted information
    DELETE a 
    FROM 
        @inserted a
    OUTER APPLY (
        SELECT TOP 1
            x.PR_content_ST_location_EV_of_Reliability
        FROM 
            @inserted x
        WHERE
            x.PR_content_ST_location_EV_of_ID = a.PR_content_ST_location_EV_of_ID
        AND
            x.PR_content_ST_location_EV_of_PositedAt < a.PR_content_ST_location_EV_of_PositedAt
        ORDER BY
            x.PR_content_ST_location_EV_of_PositedAt DESC
    ) pre 
    OUTER APPLY (
        SELECT TOP 1
            x.PR_content_ST_location_EV_of_Reliability
        FROM 
            @inserted x
        WHERE
            x.PR_content_ST_location_EV_of_ID = a.PR_content_ST_location_EV_of_ID
        AND
            x.PR_content_ST_location_EV_of_PositedAt > a.PR_content_ST_location_EV_of_PositedAt
        ORDER BY
            x.PR_content_ST_location_EV_of_PositedAt ASC
    ) fol 
    WHERE
        (a.PR_content_ST_location_EV_of_Reliability = 1 AND fol.PR_content_ST_location_EV_of_Reliability = 0)
    OR
        (a.PR_content_ST_location_EV_of_Reliability = 0 AND pre.PR_content_ST_location_EV_of_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @inserted a
        CROSS APPLY (
            SELECT TOP 1
                PR_ID_content,
                ST_ID_location,
                EV_ID_of,
                PR_content_ST_location_EV_of_ChangedAt
            FROM
                PR_content_ST_location_EV_of h
            WHERE
                h.PR_ID_content = a.PR_ID_content
            AND
                h.ST_ID_location = a.ST_ID_location
            AND
                h.EV_ID_of = a.EV_ID_of
            AND
                h.PR_content_ST_location_EV_of_ChangedAt < a.PR_content_ST_location_EV_of_ChangedAt
            ORDER BY 
                h.PR_content_ST_location_EV_of_ChangedAt DESC,
                h.PR_content_ST_location_EV_of_PositedAt DESC
        ) pre 
        WHERE
            a.PR_ID_content = pre.PR_ID_content
        AND
            a.ST_ID_location = pre.ST_ID_location
        AND
            a.EV_ID_of = pre.EV_ID_of
        AND
            a.PR_content_ST_location_EV_of_Reliability = 1
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
