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
        EV_DAT_EV_ID int not null,
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_DAT_EV_ID,
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
                p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
            AND
                p.EV_DAT_Event_Date = i.EV_DAT_Event_Date
            AND
                a.EV_DAT_PositedAt = i.EV_DAT_PositedAt
            AND
                a.EV_DAT_Reliability <> i.EV_DAT_Reliability
        )
        OR (
            i.EV_DAT_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[EV_DAT_Event_Date_Posit] p
                JOIN
                    [dbo].[EV_DAT_Event_Date_Annex] a
                ON
                    a.EV_DAT_ID = p.EV_DAT_ID
                WHERE
                    p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
                AND
                    p.EV_DAT_Event_Date <> i.EV_DAT_Event_Date
                AND
                    a.EV_DAT_PositedAt = i.EV_DAT_PositedAt
                AND
                    a.EV_DAT_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.EV_DAT_EV_ID = i.EV_DAT_EV_ID
                AND
                    j.EV_DAT_Event_Date <> i.EV_DAT_Event_Date
                AND
                    j.EV_DAT_PositedAt = i.EV_DAT_PositedAt
                AND
                    j.EV_DAT_Reliability = 1
            )
        )
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
        [dbo].[EV_DAT_Event_Date_Posit] p
    ON
        p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
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
        EV_DAT_EV_ID,
        Metadata_EV_DAT,
        EV_DAT_PositedAt,
        EV_DAT_Reliability,
        EV_DAT_Event_Date,
        EV_DAT_StatementType
    )
    SELECT
        x.EV_DAT_EV_ID,
        x.Metadata_EV_DAT,
        x.EV_DAT_PositedAt,
        x.EV_DAT_Reliability,
        x.EV_DAT_Event_Date,
        'X' -- existing data
    FROM (
        SELECT
            i.EV_DAT_EV_ID,
            a.Metadata_EV_DAT,
            a.EV_DAT_PositedAt,
            a.EV_DAT_Reliability,
            p.EV_DAT_Event_Date,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.EV_DAT_EV_ID,
                    a.EV_DAT_PositedAt
                ORDER BY
                    a.EV_DAT_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT EV_DAT_EV_ID FROM @EV_DAT_Event_Date) i
        JOIN
            [dbo].[EV_DAT_Event_Date_Posit] p
        ON
            p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
        JOIN
            [dbo].[EV_DAT_Event_Date_Annex] a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @EV_DAT_Event_Date n
        WHERE
            n.EV_DAT_EV_ID = x.EV_DAT_EV_ID
        AND
            n.EV_DAT_PositedAt = x.EV_DAT_PositedAt
    );
    DECLARE @retracted TABLE (
        EV_DAT_EV_ID int not null,
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
            (a.EV_DAT_Reliability = 0 AND isnull(pre.EV_DAT_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
        EV_DAT_EV_ID,
        EV_DAT_Event_Date
    )
    SELECT
        v.EV_DAT_EV_ID,
        v.EV_DAT_Event_Date
    FROM
        @EV_DAT_Event_Date v
    WHERE
        v.EV_DAT_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @EV_DAT_Event_Date w
        WHERE
            w.EV_DAT_StatementType = 'P'
        AND
            w.EV_DAT_EV_ID = v.EV_DAT_EV_ID
        AND
            w.EV_DAT_Event_Date = v.EV_DAT_Event_Date
        AND
            w.EV_DAT_PositedAt < v.EV_DAT_PositedAt
    );
    INSERT INTO [dbo].[EV_DAT_Event_Date_Annex] (
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
        [dbo].[EV_DAT_Event_Date_Posit] p
    ON
        p.EV_DAT_EV_ID = v.EV_DAT_EV_ID
    AND
        p.EV_DAT_Event_Date = v.EV_DAT_Event_Date
    WHERE
        EV_DAT_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[EV_DAT_Event_Date_Annex] (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        v.Metadata_EV_DAT,
        e.EV_DAT_ID,
        v.EV_DAT_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_EV_DAT,
            n.EV_DAT_EV_ID,
            n.EV_DAT_PositedAt,
            n.EV_DAT_Event_Date
        FROM
            @EV_DAT_Event_Date n
        WHERE
            n.EV_DAT_StatementType in ('P', 'A')
        AND
            n.EV_DAT_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.EV_DAT_ID,
            p.EV_DAT_Event_Date
        FROM
            [dbo].[EV_DAT_Event_Date_Posit] p
        JOIN
            [dbo].[EV_DAT_Event_Date_Annex] a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
        AND
            a.EV_DAT_PositedAt = (
                SELECT
                    max(s.EV_DAT_PositedAt)
                FROM
                    [dbo].[EV_DAT_Event_Date_Annex] s
                WHERE
                    s.EV_DAT_ID = p.EV_DAT_ID
                AND
                    s.EV_DAT_PositedAt < v.EV_DAT_PositedAt
            )
        WHERE
            p.EV_DAT_EV_ID = v.EV_DAT_EV_ID
        AND
            a.EV_DAT_Reliability = 1
        ORDER BY
            a.EV_DAT_PositedAt DESC
    ) e
    WHERE
        e.EV_DAT_Event_Date <> v.EV_DAT_Event_Date
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_DAT_Event_Date_Annex] x
        WHERE
            x.EV_DAT_ID = e.EV_DAT_ID
        AND
            x.EV_DAT_PositedAt = v.EV_DAT_PositedAt
    );
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
        EV_AUD_EV_ID int not null,
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_AUD_EV_ID,
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
                p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
            AND
                p.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
            AND
                a.EV_AUD_PositedAt = i.EV_AUD_PositedAt
            AND
                a.EV_AUD_Reliability <> i.EV_AUD_Reliability
        )
        OR (
            i.EV_AUD_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[EV_AUD_Event_Audience_Posit] p
                JOIN
                    [dbo].[EV_AUD_Event_Audience_Annex] a
                ON
                    a.EV_AUD_ID = p.EV_AUD_ID
                WHERE
                    p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
                AND
                    p.EV_AUD_Event_Audience <> i.EV_AUD_Event_Audience
                AND
                    a.EV_AUD_PositedAt = i.EV_AUD_PositedAt
                AND
                    a.EV_AUD_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.EV_AUD_EV_ID = i.EV_AUD_EV_ID
                AND
                    j.EV_AUD_Event_Audience <> i.EV_AUD_Event_Audience
                AND
                    j.EV_AUD_PositedAt = i.EV_AUD_PositedAt
                AND
                    j.EV_AUD_Reliability = 1
            )
        )
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
        [dbo].[EV_AUD_Event_Audience_Posit] p
    ON
        p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
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
        EV_AUD_EV_ID,
        Metadata_EV_AUD,
        EV_AUD_PositedAt,
        EV_AUD_Reliability,
        EV_AUD_Event_Audience,
        EV_AUD_StatementType
    )
    SELECT
        x.EV_AUD_EV_ID,
        x.Metadata_EV_AUD,
        x.EV_AUD_PositedAt,
        x.EV_AUD_Reliability,
        x.EV_AUD_Event_Audience,
        'X' -- existing data
    FROM (
        SELECT
            i.EV_AUD_EV_ID,
            a.Metadata_EV_AUD,
            a.EV_AUD_PositedAt,
            a.EV_AUD_Reliability,
            p.EV_AUD_Event_Audience,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.EV_AUD_EV_ID,
                    a.EV_AUD_PositedAt
                ORDER BY
                    a.EV_AUD_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT EV_AUD_EV_ID FROM @EV_AUD_Event_Audience) i
        JOIN
            [dbo].[EV_AUD_Event_Audience_Posit] p
        ON
            p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
        JOIN
            [dbo].[EV_AUD_Event_Audience_Annex] a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @EV_AUD_Event_Audience n
        WHERE
            n.EV_AUD_EV_ID = x.EV_AUD_EV_ID
        AND
            n.EV_AUD_PositedAt = x.EV_AUD_PositedAt
    );
    DECLARE @retracted TABLE (
        EV_AUD_EV_ID int not null,
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
            (a.EV_AUD_Reliability = 0 AND isnull(pre.EV_AUD_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    )
    SELECT
        v.EV_AUD_EV_ID,
        v.EV_AUD_Event_Audience
    FROM
        @EV_AUD_Event_Audience v
    WHERE
        v.EV_AUD_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @EV_AUD_Event_Audience w
        WHERE
            w.EV_AUD_StatementType = 'P'
        AND
            w.EV_AUD_EV_ID = v.EV_AUD_EV_ID
        AND
            w.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
        AND
            w.EV_AUD_PositedAt < v.EV_AUD_PositedAt
    );
    INSERT INTO [dbo].[EV_AUD_Event_Audience_Annex] (
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
        [dbo].[EV_AUD_Event_Audience_Posit] p
    ON
        p.EV_AUD_EV_ID = v.EV_AUD_EV_ID
    AND
        p.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
    WHERE
        EV_AUD_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[EV_AUD_Event_Audience_Annex] (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        v.Metadata_EV_AUD,
        e.EV_AUD_ID,
        v.EV_AUD_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_EV_AUD,
            n.EV_AUD_EV_ID,
            n.EV_AUD_PositedAt,
            n.EV_AUD_Event_Audience
        FROM
            @EV_AUD_Event_Audience n
        WHERE
            n.EV_AUD_StatementType in ('P', 'A')
        AND
            n.EV_AUD_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.EV_AUD_ID,
            p.EV_AUD_Event_Audience
        FROM
            [dbo].[EV_AUD_Event_Audience_Posit] p
        JOIN
            [dbo].[EV_AUD_Event_Audience_Annex] a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
        AND
            a.EV_AUD_PositedAt = (
                SELECT
                    max(s.EV_AUD_PositedAt)
                FROM
                    [dbo].[EV_AUD_Event_Audience_Annex] s
                WHERE
                    s.EV_AUD_ID = p.EV_AUD_ID
                AND
                    s.EV_AUD_PositedAt < v.EV_AUD_PositedAt
            )
        WHERE
            p.EV_AUD_EV_ID = v.EV_AUD_EV_ID
        AND
            a.EV_AUD_Reliability = 1
        ORDER BY
            a.EV_AUD_PositedAt DESC
    ) e
    WHERE
        e.EV_AUD_Event_Audience <> v.EV_AUD_Event_Audience
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_AUD_Event_Audience_Annex] x
        WHERE
            x.EV_AUD_ID = e.EV_AUD_ID
        AND
            x.EV_AUD_PositedAt = v.EV_AUD_PositedAt
    );
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
        EV_REV_EV_ID int not null,
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_REV_EV_ID,
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
                p.EV_REV_EV_ID = i.EV_REV_EV_ID
            AND
                p.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
            AND
                a.EV_REV_PositedAt = i.EV_REV_PositedAt
            AND
                a.EV_REV_Reliability <> i.EV_REV_Reliability
        )
        OR (
            i.EV_REV_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[EV_REV_Event_Revenue_Posit] p
                JOIN
                    [dbo].[EV_REV_Event_Revenue_Annex] a
                ON
                    a.EV_REV_ID = p.EV_REV_ID
                WHERE
                    p.EV_REV_EV_ID = i.EV_REV_EV_ID
                AND
                    p.EV_REV_Event_Revenue <> i.EV_REV_Event_Revenue
                AND
                    a.EV_REV_PositedAt = i.EV_REV_PositedAt
                AND
                    a.EV_REV_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.EV_REV_EV_ID = i.EV_REV_EV_ID
                AND
                    j.EV_REV_Event_Revenue <> i.EV_REV_Event_Revenue
                AND
                    j.EV_REV_PositedAt = i.EV_REV_PositedAt
                AND
                    j.EV_REV_Reliability = 1
            )
        )
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
        [dbo].[EV_REV_Event_Revenue_Posit] p
    ON
        p.EV_REV_EV_ID = i.EV_REV_EV_ID
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
        EV_REV_EV_ID,
        Metadata_EV_REV,
        EV_REV_PositedAt,
        EV_REV_Reliability,
        EV_REV_Event_Revenue,
        EV_REV_StatementType
    )
    SELECT
        x.EV_REV_EV_ID,
        x.Metadata_EV_REV,
        x.EV_REV_PositedAt,
        x.EV_REV_Reliability,
        x.EV_REV_Event_Revenue,
        'X' -- existing data
    FROM (
        SELECT
            i.EV_REV_EV_ID,
            a.Metadata_EV_REV,
            a.EV_REV_PositedAt,
            a.EV_REV_Reliability,
            p.EV_REV_Event_Revenue,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.EV_REV_EV_ID,
                    a.EV_REV_PositedAt
                ORDER BY
                    a.EV_REV_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT EV_REV_EV_ID FROM @EV_REV_Event_Revenue) i
        JOIN
            [dbo].[EV_REV_Event_Revenue_Posit] p
        ON
            p.EV_REV_EV_ID = i.EV_REV_EV_ID
        JOIN
            [dbo].[EV_REV_Event_Revenue_Annex] a
        ON
            a.EV_REV_ID = p.EV_REV_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @EV_REV_Event_Revenue n
        WHERE
            n.EV_REV_EV_ID = x.EV_REV_EV_ID
        AND
            n.EV_REV_PositedAt = x.EV_REV_PositedAt
    );
    DECLARE @retracted TABLE (
        EV_REV_EV_ID int not null,
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
            (a.EV_REV_Reliability = 0 AND isnull(pre.EV_REV_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
        EV_REV_EV_ID,
        EV_REV_Event_Revenue
    )
    SELECT
        v.EV_REV_EV_ID,
        v.EV_REV_Event_Revenue
    FROM
        @EV_REV_Event_Revenue v
    WHERE
        v.EV_REV_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @EV_REV_Event_Revenue w
        WHERE
            w.EV_REV_StatementType = 'P'
        AND
            w.EV_REV_EV_ID = v.EV_REV_EV_ID
        AND
            w.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
        AND
            w.EV_REV_PositedAt < v.EV_REV_PositedAt
    );
    INSERT INTO [dbo].[EV_REV_Event_Revenue_Annex] (
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
        [dbo].[EV_REV_Event_Revenue_Posit] p
    ON
        p.EV_REV_EV_ID = v.EV_REV_EV_ID
    AND
        p.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
    WHERE
        EV_REV_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[EV_REV_Event_Revenue_Annex] (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        v.Metadata_EV_REV,
        e.EV_REV_ID,
        v.EV_REV_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_EV_REV,
            n.EV_REV_EV_ID,
            n.EV_REV_PositedAt,
            n.EV_REV_Event_Revenue
        FROM
            @EV_REV_Event_Revenue n
        WHERE
            n.EV_REV_StatementType in ('P', 'A')
        AND
            n.EV_REV_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.EV_REV_ID,
            p.EV_REV_Event_Revenue
        FROM
            [dbo].[EV_REV_Event_Revenue_Posit] p
        JOIN
            [dbo].[EV_REV_Event_Revenue_Annex] a
        ON
            a.EV_REV_ID = p.EV_REV_ID
        AND
            a.EV_REV_PositedAt = (
                SELECT
                    max(s.EV_REV_PositedAt)
                FROM
                    [dbo].[EV_REV_Event_Revenue_Annex] s
                WHERE
                    s.EV_REV_ID = p.EV_REV_ID
                AND
                    s.EV_REV_PositedAt < v.EV_REV_PositedAt
            )
        WHERE
            p.EV_REV_EV_ID = v.EV_REV_EV_ID
        AND
            a.EV_REV_Reliability = 1
        ORDER BY
            a.EV_REV_PositedAt DESC
    ) e
    WHERE
        e.EV_REV_Event_Revenue <> v.EV_REV_Event_Revenue
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_REV_Event_Revenue_Annex] x
        WHERE
            x.EV_REV_ID = e.EV_REV_ID
        AND
            x.EV_REV_PositedAt = v.EV_REV_PositedAt
    );
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
        ST_NAM_ST_ID int not null,
        Metadata_ST_NAM int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_PositedAt datetime2 not null,
        ST_NAM_Reliability decimal(5,2) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_Checksum varbinary(16) not null,
        ST_NAM_StatementType char(1) not null,
        primary key (
            ST_NAM_ST_ID asc,
            ST_NAM_ChangedAt desc,
            ST_NAM_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_NAM_ST_ID,
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
                p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
            AND
                p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
            AND
                p.ST_NAM_Checksum = dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max)))
            AND
                a.ST_NAM_PositedAt = i.ST_NAM_PositedAt
            AND
                a.ST_NAM_Reliability <> i.ST_NAM_Reliability
        )
        OR (
            i.ST_NAM_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[ST_NAM_Stage_Name_Posit] p
                JOIN
                    [dbo].[ST_NAM_Stage_Name_Annex] a
                ON
                    a.ST_NAM_ID = p.ST_NAM_ID
                WHERE
                    p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
                AND
                    p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
                AND
                    p.ST_NAM_Checksum <> dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max)))
                AND
                    a.ST_NAM_PositedAt = i.ST_NAM_PositedAt
                AND
                    a.ST_NAM_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.ST_NAM_ST_ID = i.ST_NAM_ST_ID
                AND
                    j.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
                AND
                    dbo.MD5(cast(j.ST_NAM_Stage_Name as varbinary(max))) <> dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max)))
                AND
                    j.ST_NAM_PositedAt = i.ST_NAM_PositedAt
                AND
                    j.ST_NAM_Reliability = 1
            )
        )
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
        i.ST_NAM_ST_ID,
        i.Metadata_ST_NAM,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_PositedAt,
        i.ST_NAM_Reliability,
        i.ST_NAM_Stage_Name,
        dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max))),
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
        p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
    AND
        p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
    AND
        p.ST_NAM_Checksum = dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max)))
    LEFT JOIN
        [dbo].[ST_NAM_Stage_Name_Annex] a
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
        ST_NAM_Checksum,
        ST_NAM_StatementType
    )
    SELECT
        x.ST_NAM_ST_ID,
        x.Metadata_ST_NAM,
        x.ST_NAM_ChangedAt,
        x.ST_NAM_PositedAt,
        x.ST_NAM_Reliability,
        x.ST_NAM_Stage_Name,
        x.ST_NAM_Checksum,
        'X' -- existing data
    FROM (
        SELECT
            i.ST_NAM_ST_ID,
            a.Metadata_ST_NAM,
            p.ST_NAM_ChangedAt,
            a.ST_NAM_PositedAt,
            a.ST_NAM_Reliability,
            p.ST_NAM_Stage_Name,
            p.ST_NAM_Checksum,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.ST_NAM_ST_ID,
                    p.ST_NAM_ChangedAt,
                    a.ST_NAM_PositedAt
                ORDER BY
                    a.ST_NAM_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT ST_NAM_ST_ID FROM @ST_NAM_Stage_Name) i
        JOIN
            [dbo].[ST_NAM_Stage_Name_Posit] p
        ON
            p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
        JOIN
            [dbo].[ST_NAM_Stage_Name_Annex] a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @ST_NAM_Stage_Name n
        WHERE
            n.ST_NAM_ST_ID = x.ST_NAM_ST_ID
        AND
            n.ST_NAM_ChangedAt = x.ST_NAM_ChangedAt
        AND
            n.ST_NAM_PositedAt = x.ST_NAM_PositedAt
    );
    DECLARE @retracted TABLE (
        ST_NAM_ST_ID int not null,
        Metadata_ST_NAM int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_PositedAt datetime2 not null,
        ST_NAM_Reliability decimal(5,2) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_Checksum varbinary(16) not null,
        ST_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        ST_NAM_ST_ID,
        Metadata_ST_NAM,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name,
        ST_NAM_Checksum,
        ST_NAM_StatementType
    )
    SELECT
        ST_NAM_ST_ID,
        Metadata_ST_NAM,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability,
        ST_NAM_Stage_Name,
        ST_NAM_Checksum,
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
            (a.ST_NAM_Reliability = 0 AND isnull(pre.ST_NAM_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    SELECT
        v.ST_NAM_ST_ID,
        v.ST_NAM_ChangedAt,
        v.ST_NAM_Stage_Name
    FROM
        @ST_NAM_Stage_Name v
    WHERE
        v.ST_NAM_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @ST_NAM_Stage_Name w
        WHERE
            w.ST_NAM_StatementType = 'P'
        AND
            w.ST_NAM_ST_ID = v.ST_NAM_ST_ID
        AND
            w.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
        AND
            w.ST_NAM_Checksum = v.ST_NAM_Checksum
        AND
            w.ST_NAM_PositedAt < v.ST_NAM_PositedAt
    );
    INSERT INTO [dbo].[ST_NAM_Stage_Name_Annex] (
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
        [dbo].[ST_NAM_Stage_Name_Posit] p
    ON
        p.ST_NAM_ST_ID = v.ST_NAM_ST_ID
    AND
        p.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
    AND
        p.ST_NAM_Checksum = v.ST_NAM_Checksum
    WHERE
        ST_NAM_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[ST_NAM_Stage_Name_Annex] (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        v.Metadata_ST_NAM,
        e.ST_NAM_ID,
        v.ST_NAM_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_ST_NAM,
            n.ST_NAM_ST_ID,
            n.ST_NAM_ChangedAt,
            n.ST_NAM_PositedAt,
            n.ST_NAM_Checksum
        FROM
            @ST_NAM_Stage_Name n
        WHERE
            n.ST_NAM_StatementType in ('P', 'A')
        AND
            n.ST_NAM_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.ST_NAM_ID,
            p.ST_NAM_Checksum
        FROM
            [dbo].[ST_NAM_Stage_Name_Posit] p
        JOIN
            [dbo].[ST_NAM_Stage_Name_Annex] a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
        AND
            a.ST_NAM_PositedAt = (
                SELECT
                    max(s.ST_NAM_PositedAt)
                FROM
                    [dbo].[ST_NAM_Stage_Name_Annex] s
                WHERE
                    s.ST_NAM_ID = p.ST_NAM_ID
                AND
                    s.ST_NAM_PositedAt < v.ST_NAM_PositedAt
            )
        WHERE
            p.ST_NAM_ST_ID = v.ST_NAM_ST_ID
        AND
            p.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
        AND
            a.ST_NAM_Reliability = 1
        ORDER BY
            a.ST_NAM_PositedAt DESC
    ) e
    WHERE
        e.ST_NAM_Checksum <> v.ST_NAM_Checksum
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_NAM_Stage_Name_Annex] x
        WHERE
            x.ST_NAM_ID = e.ST_NAM_ID
        AND
            x.ST_NAM_PositedAt = v.ST_NAM_PositedAt
    );
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_LOC_ST_ID,
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
                p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
            AND
                p.ST_LOC_Checksum = dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max)))
            AND
                a.ST_LOC_PositedAt = i.ST_LOC_PositedAt
            AND
                a.ST_LOC_Reliability <> i.ST_LOC_Reliability
        )
        OR (
            i.ST_LOC_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[ST_LOC_Stage_Location_Posit] p
                JOIN
                    [dbo].[ST_LOC_Stage_Location_Annex] a
                ON
                    a.ST_LOC_ID = p.ST_LOC_ID
                WHERE
                    p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
                AND
                    p.ST_LOC_Checksum <> dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max)))
                AND
                    a.ST_LOC_PositedAt = i.ST_LOC_PositedAt
                AND
                    a.ST_LOC_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.ST_LOC_ST_ID = i.ST_LOC_ST_ID
                AND
                    dbo.MD5(cast(j.ST_LOC_Stage_Location as varbinary(max))) <> dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max)))
                AND
                    j.ST_LOC_PositedAt = i.ST_LOC_PositedAt
                AND
                    j.ST_LOC_Reliability = 1
            )
        )
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
        i.ST_LOC_ST_ID,
        i.Metadata_ST_LOC,
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
        p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
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
        ST_LOC_ST_ID,
        Metadata_ST_LOC,
        ST_LOC_PositedAt,
        ST_LOC_Reliability,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum,
        ST_LOC_StatementType
    )
    SELECT
        x.ST_LOC_ST_ID,
        x.Metadata_ST_LOC,
        x.ST_LOC_PositedAt,
        x.ST_LOC_Reliability,
        x.ST_LOC_Stage_Location,
        x.ST_LOC_Checksum,
        'X' -- existing data
    FROM (
        SELECT
            i.ST_LOC_ST_ID,
            a.Metadata_ST_LOC,
            a.ST_LOC_PositedAt,
            a.ST_LOC_Reliability,
            p.ST_LOC_Stage_Location,
            p.ST_LOC_Checksum,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.ST_LOC_ST_ID,
                    a.ST_LOC_PositedAt
                ORDER BY
                    a.ST_LOC_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT ST_LOC_ST_ID FROM @ST_LOC_Stage_Location) i
        JOIN
            [dbo].[ST_LOC_Stage_Location_Posit] p
        ON
            p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
        JOIN
            [dbo].[ST_LOC_Stage_Location_Annex] a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @ST_LOC_Stage_Location n
        WHERE
            n.ST_LOC_ST_ID = x.ST_LOC_ST_ID
        AND
            n.ST_LOC_PositedAt = x.ST_LOC_PositedAt
    );
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
            (a.ST_LOC_Reliability = 0 AND isnull(pre.ST_LOC_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
        ST_LOC_ST_ID,
        ST_LOC_Stage_Location
    )
    SELECT
        v.ST_LOC_ST_ID,
        v.ST_LOC_Stage_Location
    FROM
        @ST_LOC_Stage_Location v
    WHERE
        v.ST_LOC_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @ST_LOC_Stage_Location w
        WHERE
            w.ST_LOC_StatementType = 'P'
        AND
            w.ST_LOC_ST_ID = v.ST_LOC_ST_ID
        AND
            w.ST_LOC_Checksum = v.ST_LOC_Checksum
        AND
            w.ST_LOC_PositedAt < v.ST_LOC_PositedAt
    );
    INSERT INTO [dbo].[ST_LOC_Stage_Location_Annex] (
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
        [dbo].[ST_LOC_Stage_Location_Posit] p
    ON
        p.ST_LOC_ST_ID = v.ST_LOC_ST_ID
    AND
        p.ST_LOC_Checksum = v.ST_LOC_Checksum
    WHERE
        ST_LOC_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[ST_LOC_Stage_Location_Annex] (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        v.Metadata_ST_LOC,
        e.ST_LOC_ID,
        v.ST_LOC_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_ST_LOC,
            n.ST_LOC_ST_ID,
            n.ST_LOC_PositedAt,
            n.ST_LOC_Checksum
        FROM
            @ST_LOC_Stage_Location n
        WHERE
            n.ST_LOC_StatementType in ('P', 'A')
        AND
            n.ST_LOC_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.ST_LOC_ID,
            p.ST_LOC_Checksum
        FROM
            [dbo].[ST_LOC_Stage_Location_Posit] p
        JOIN
            [dbo].[ST_LOC_Stage_Location_Annex] a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
        AND
            a.ST_LOC_PositedAt = (
                SELECT
                    max(s.ST_LOC_PositedAt)
                FROM
                    [dbo].[ST_LOC_Stage_Location_Annex] s
                WHERE
                    s.ST_LOC_ID = p.ST_LOC_ID
                AND
                    s.ST_LOC_PositedAt < v.ST_LOC_PositedAt
            )
        WHERE
            p.ST_LOC_ST_ID = v.ST_LOC_ST_ID
        AND
            a.ST_LOC_Reliability = 1
        ORDER BY
            a.ST_LOC_PositedAt DESC
    ) e
    WHERE
        e.ST_LOC_Checksum <> v.ST_LOC_Checksum
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_LOC_Stage_Location_Annex] x
        WHERE
            x.ST_LOC_ID = e.ST_LOC_ID
        AND
            x.ST_LOC_PositedAt = v.ST_LOC_PositedAt
    );
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_AVG_ST_ID,
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
                p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
            AND
                p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
            AND
                p.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
            AND
                a.ST_AVG_PositedAt = i.ST_AVG_PositedAt
            AND
                a.ST_AVG_Reliability <> i.ST_AVG_Reliability
        )
        OR (
            i.ST_AVG_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[ST_AVG_Stage_Average_Posit] p
                JOIN
                    [dbo].[ST_AVG_Stage_Average_Annex] a
                ON
                    a.ST_AVG_ID = p.ST_AVG_ID
                WHERE
                    p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
                AND
                    p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
                AND
                    p.ST_AVG_UTL_ID <> i.ST_AVG_UTL_ID
                AND
                    a.ST_AVG_PositedAt = i.ST_AVG_PositedAt
                AND
                    a.ST_AVG_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.ST_AVG_ST_ID = i.ST_AVG_ST_ID
                AND
                    j.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
                AND
                    j.ST_AVG_UTL_ID <> i.ST_AVG_UTL_ID
                AND
                    j.ST_AVG_PositedAt = i.ST_AVG_PositedAt
                AND
                    j.ST_AVG_Reliability = 1
            )
        )
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
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
    AND
        p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
    AND
        p.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
    LEFT JOIN
        [dbo].[ST_AVG_Stage_Average_Annex] a
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
        x.ST_AVG_ST_ID,
        x.Metadata_ST_AVG,
        x.ST_AVG_ChangedAt,
        x.ST_AVG_PositedAt,
        x.ST_AVG_Reliability,
        x.ST_AVG_UTL_ID,
        'X' -- existing data
    FROM (
        SELECT
            i.ST_AVG_ST_ID,
            a.Metadata_ST_AVG,
            p.ST_AVG_ChangedAt,
            a.ST_AVG_PositedAt,
            a.ST_AVG_Reliability,
            p.ST_AVG_UTL_ID,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.ST_AVG_ST_ID,
                    p.ST_AVG_ChangedAt,
                    a.ST_AVG_PositedAt
                ORDER BY
                    a.ST_AVG_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT ST_AVG_ST_ID FROM @ST_AVG_Stage_Average) i
        JOIN
            [dbo].[ST_AVG_Stage_Average_Posit] p
        ON
            p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
        JOIN
            [dbo].[ST_AVG_Stage_Average_Annex] a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @ST_AVG_Stage_Average n
        WHERE
            n.ST_AVG_ST_ID = x.ST_AVG_ST_ID
        AND
            n.ST_AVG_ChangedAt = x.ST_AVG_ChangedAt
        AND
            n.ST_AVG_PositedAt = x.ST_AVG_PositedAt
    );
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
            (a.ST_AVG_Reliability = 0 AND isnull(pre.ST_AVG_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
    -- the new values that only restate the previous version, which are skipped, though what they correct is retracted
    DECLARE @skipped TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_UTL_ID tinyint not null
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
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_UTL_ID tinyint not null,
        ST_AVG_StatementType char(1) not null
    );
    INSERT INTO @skipped (
        ST_AVG_ST_ID,
        Metadata_ST_AVG,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_UTL_ID
    )
    SELECT
        a.ST_AVG_ST_ID,
        a.Metadata_ST_AVG,
        a.ST_AVG_ChangedAt,
        a.ST_AVG_PositedAt,
        a.ST_AVG_UTL_ID
    FROM
        @ST_AVG_Stage_Average a
    CROSS APPLY (
        SELECT TOP 1
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
        a.ST_AVG_StatementType in ('P', 'A')
    AND
        a.ST_AVG_Reliability = 1
    AND
        a.ST_AVG_UTL_ID = pre.ST_AVG_UTL_ID;
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
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
    AND
        p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
    AND
        p.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
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
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    SELECT
        v.ST_AVG_ST_ID,
        v.ST_AVG_ChangedAt,
        v.ST_AVG_UTL_ID
    FROM
        @ST_AVG_Stage_Average v
    WHERE
        v.ST_AVG_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @ST_AVG_Stage_Average w
        WHERE
            w.ST_AVG_StatementType = 'P'
        AND
            w.ST_AVG_ST_ID = v.ST_AVG_ST_ID
        AND
            w.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
        AND
            w.ST_AVG_UTL_ID = v.ST_AVG_UTL_ID
        AND
            w.ST_AVG_PositedAt < v.ST_AVG_PositedAt
    );
    INSERT INTO [dbo].[ST_AVG_Stage_Average_Annex] (
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
        [dbo].[ST_AVG_Stage_Average_Posit] p
    ON
        p.ST_AVG_ST_ID = v.ST_AVG_ST_ID
    AND
        p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
    AND
        p.ST_AVG_UTL_ID = v.ST_AVG_UTL_ID
    WHERE
        ST_AVG_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[ST_AVG_Stage_Average_Annex] (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        v.Metadata_ST_AVG,
        e.ST_AVG_ID,
        v.ST_AVG_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_ST_AVG,
            n.ST_AVG_ST_ID,
            n.ST_AVG_ChangedAt,
            n.ST_AVG_PositedAt,
            n.ST_AVG_UTL_ID
        FROM
            @ST_AVG_Stage_Average n
        WHERE
            n.ST_AVG_StatementType in ('P', 'A')
        AND
            n.ST_AVG_Reliability = 1
        UNION ALL
        SELECT
            k.Metadata_ST_AVG,
            k.ST_AVG_ST_ID,
            k.ST_AVG_ChangedAt,
            k.ST_AVG_PositedAt,
            k.ST_AVG_UTL_ID
        FROM
            @skipped k
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.ST_AVG_ID,
            p.ST_AVG_UTL_ID
        FROM
            [dbo].[ST_AVG_Stage_Average_Posit] p
        JOIN
            [dbo].[ST_AVG_Stage_Average_Annex] a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
        AND
            a.ST_AVG_PositedAt = (
                SELECT
                    max(s.ST_AVG_PositedAt)
                FROM
                    [dbo].[ST_AVG_Stage_Average_Annex] s
                WHERE
                    s.ST_AVG_ID = p.ST_AVG_ID
                AND
                    s.ST_AVG_PositedAt < v.ST_AVG_PositedAt
            )
        WHERE
            p.ST_AVG_ST_ID = v.ST_AVG_ST_ID
        AND
            p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
        AND
            a.ST_AVG_Reliability = 1
        ORDER BY
            a.ST_AVG_PositedAt DESC
    ) e
    WHERE
        e.ST_AVG_UTL_ID <> v.ST_AVG_UTL_ID
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_AVG_Stage_Average_Annex] x
        WHERE
            x.ST_AVG_ID = e.ST_AVG_ID
        AND
            x.ST_AVG_PositedAt = v.ST_AVG_PositedAt
    );
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_MIN_ST_ID,
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
                p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
            AND
                p.ST_MIN_UTL_ID = i.ST_MIN_UTL_ID
            AND
                a.ST_MIN_PositedAt = i.ST_MIN_PositedAt
            AND
                a.ST_MIN_Reliability <> i.ST_MIN_Reliability
        )
        OR (
            i.ST_MIN_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[ST_MIN_Stage_Minimum_Posit] p
                JOIN
                    [dbo].[ST_MIN_Stage_Minimum_Annex] a
                ON
                    a.ST_MIN_ID = p.ST_MIN_ID
                WHERE
                    p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
                AND
                    p.ST_MIN_UTL_ID <> i.ST_MIN_UTL_ID
                AND
                    a.ST_MIN_PositedAt = i.ST_MIN_PositedAt
                AND
                    a.ST_MIN_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.ST_MIN_ST_ID = i.ST_MIN_ST_ID
                AND
                    j.ST_MIN_UTL_ID <> i.ST_MIN_UTL_ID
                AND
                    j.ST_MIN_PositedAt = i.ST_MIN_PositedAt
                AND
                    j.ST_MIN_Reliability = 1
            )
        )
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
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    ON
        p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
    AND
        p.ST_MIN_UTL_ID = i.ST_MIN_UTL_ID
    LEFT JOIN
        [dbo].[ST_MIN_Stage_Minimum_Annex] a
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
        x.ST_MIN_ST_ID,
        x.Metadata_ST_MIN,
        x.ST_MIN_PositedAt,
        x.ST_MIN_Reliability,
        x.ST_MIN_UTL_ID,
        'X' -- existing data
    FROM (
        SELECT
            i.ST_MIN_ST_ID,
            a.Metadata_ST_MIN,
            a.ST_MIN_PositedAt,
            a.ST_MIN_Reliability,
            p.ST_MIN_UTL_ID,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.ST_MIN_ST_ID,
                    a.ST_MIN_PositedAt
                ORDER BY
                    a.ST_MIN_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT ST_MIN_ST_ID FROM @ST_MIN_Stage_Minimum) i
        JOIN
            [dbo].[ST_MIN_Stage_Minimum_Posit] p
        ON
            p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
        JOIN
            [dbo].[ST_MIN_Stage_Minimum_Annex] a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @ST_MIN_Stage_Minimum n
        WHERE
            n.ST_MIN_ST_ID = x.ST_MIN_ST_ID
        AND
            n.ST_MIN_PositedAt = x.ST_MIN_PositedAt
    );
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
            (a.ST_MIN_Reliability = 0 AND isnull(pre.ST_MIN_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
    SELECT
        v.ST_MIN_ST_ID,
        v.ST_MIN_UTL_ID
    FROM
        @ST_MIN_Stage_Minimum v
    WHERE
        v.ST_MIN_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @ST_MIN_Stage_Minimum w
        WHERE
            w.ST_MIN_StatementType = 'P'
        AND
            w.ST_MIN_ST_ID = v.ST_MIN_ST_ID
        AND
            w.ST_MIN_UTL_ID = v.ST_MIN_UTL_ID
        AND
            w.ST_MIN_PositedAt < v.ST_MIN_PositedAt
    );
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Annex] (
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
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    ON
        p.ST_MIN_ST_ID = v.ST_MIN_ST_ID
    AND
        p.ST_MIN_UTL_ID = v.ST_MIN_UTL_ID
    WHERE
        ST_MIN_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Annex] (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        v.Metadata_ST_MIN,
        e.ST_MIN_ID,
        v.ST_MIN_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_ST_MIN,
            n.ST_MIN_ST_ID,
            n.ST_MIN_PositedAt,
            n.ST_MIN_UTL_ID
        FROM
            @ST_MIN_Stage_Minimum n
        WHERE
            n.ST_MIN_StatementType in ('P', 'A')
        AND
            n.ST_MIN_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.ST_MIN_ID,
            p.ST_MIN_UTL_ID
        FROM
            [dbo].[ST_MIN_Stage_Minimum_Posit] p
        JOIN
            [dbo].[ST_MIN_Stage_Minimum_Annex] a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
        AND
            a.ST_MIN_PositedAt = (
                SELECT
                    max(s.ST_MIN_PositedAt)
                FROM
                    [dbo].[ST_MIN_Stage_Minimum_Annex] s
                WHERE
                    s.ST_MIN_ID = p.ST_MIN_ID
                AND
                    s.ST_MIN_PositedAt < v.ST_MIN_PositedAt
            )
        WHERE
            p.ST_MIN_ST_ID = v.ST_MIN_ST_ID
        AND
            a.ST_MIN_Reliability = 1
        ORDER BY
            a.ST_MIN_PositedAt DESC
    ) e
    WHERE
        e.ST_MIN_UTL_ID <> v.ST_MIN_UTL_ID
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_MIN_Stage_Minimum_Annex] x
        WHERE
            x.ST_MIN_ID = e.ST_MIN_ID
        AND
            x.ST_MIN_PositedAt = v.ST_MIN_PositedAt
    );
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
        AC_NAM_AC_ID int not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_Checksum varbinary(16) not null,
        AC_NAM_StatementType char(1) not null,
        primary key (
            AC_NAM_AC_ID asc,
            AC_NAM_ChangedAt desc,
            AC_NAM_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_NAM_AC_ID,
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
                p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
            AND
                p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
            AND
                p.AC_NAM_Checksum = dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max)))
            AND
                a.AC_NAM_PositedAt = i.AC_NAM_PositedAt
            AND
                a.AC_NAM_Reliability <> i.AC_NAM_Reliability
        )
        OR (
            i.AC_NAM_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[AC_NAM_Actor_Name_Posit] p
                JOIN
                    [dbo].[AC_NAM_Actor_Name_Annex] a
                ON
                    a.AC_NAM_ID = p.AC_NAM_ID
                WHERE
                    p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
                AND
                    p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
                AND
                    p.AC_NAM_Checksum <> dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max)))
                AND
                    a.AC_NAM_PositedAt = i.AC_NAM_PositedAt
                AND
                    a.AC_NAM_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.AC_NAM_AC_ID = i.AC_NAM_AC_ID
                AND
                    j.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
                AND
                    dbo.MD5(cast(j.AC_NAM_Actor_Name as varbinary(max))) <> dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max)))
                AND
                    j.AC_NAM_PositedAt = i.AC_NAM_PositedAt
                AND
                    j.AC_NAM_Reliability = 1
            )
        )
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
        i.AC_NAM_AC_ID,
        i.Metadata_AC_NAM,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Reliability,
        i.AC_NAM_Actor_Name,
        dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max))),
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
        p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
    AND
        p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
    AND
        p.AC_NAM_Checksum = dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max)))
    LEFT JOIN
        [dbo].[AC_NAM_Actor_Name_Annex] a
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
        AC_NAM_Checksum,
        AC_NAM_StatementType
    )
    SELECT
        x.AC_NAM_AC_ID,
        x.Metadata_AC_NAM,
        x.AC_NAM_ChangedAt,
        x.AC_NAM_PositedAt,
        x.AC_NAM_Reliability,
        x.AC_NAM_Actor_Name,
        x.AC_NAM_Checksum,
        'X' -- existing data
    FROM (
        SELECT
            i.AC_NAM_AC_ID,
            a.Metadata_AC_NAM,
            p.AC_NAM_ChangedAt,
            a.AC_NAM_PositedAt,
            a.AC_NAM_Reliability,
            p.AC_NAM_Actor_Name,
            p.AC_NAM_Checksum,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.AC_NAM_AC_ID,
                    p.AC_NAM_ChangedAt,
                    a.AC_NAM_PositedAt
                ORDER BY
                    a.AC_NAM_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT AC_NAM_AC_ID FROM @AC_NAM_Actor_Name) i
        JOIN
            [dbo].[AC_NAM_Actor_Name_Posit] p
        ON
            p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
        JOIN
            [dbo].[AC_NAM_Actor_Name_Annex] a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @AC_NAM_Actor_Name n
        WHERE
            n.AC_NAM_AC_ID = x.AC_NAM_AC_ID
        AND
            n.AC_NAM_ChangedAt = x.AC_NAM_ChangedAt
        AND
            n.AC_NAM_PositedAt = x.AC_NAM_PositedAt
    );
    DECLARE @retracted TABLE (
        AC_NAM_AC_ID int not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_Checksum varbinary(16) not null,
        AC_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name,
        AC_NAM_Checksum,
        AC_NAM_StatementType
    )
    SELECT
        AC_NAM_AC_ID,
        Metadata_AC_NAM,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability,
        AC_NAM_Actor_Name,
        AC_NAM_Checksum,
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
            (a.AC_NAM_Reliability = 0 AND isnull(pre.AC_NAM_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT
        v.AC_NAM_AC_ID,
        v.AC_NAM_ChangedAt,
        v.AC_NAM_Actor_Name
    FROM
        @AC_NAM_Actor_Name v
    WHERE
        v.AC_NAM_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @AC_NAM_Actor_Name w
        WHERE
            w.AC_NAM_StatementType = 'P'
        AND
            w.AC_NAM_AC_ID = v.AC_NAM_AC_ID
        AND
            w.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
        AND
            w.AC_NAM_Checksum = v.AC_NAM_Checksum
        AND
            w.AC_NAM_PositedAt < v.AC_NAM_PositedAt
    );
    INSERT INTO [dbo].[AC_NAM_Actor_Name_Annex] (
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
        [dbo].[AC_NAM_Actor_Name_Posit] p
    ON
        p.AC_NAM_AC_ID = v.AC_NAM_AC_ID
    AND
        p.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
    AND
        p.AC_NAM_Checksum = v.AC_NAM_Checksum
    WHERE
        AC_NAM_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[AC_NAM_Actor_Name_Annex] (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        v.Metadata_AC_NAM,
        e.AC_NAM_ID,
        v.AC_NAM_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_AC_NAM,
            n.AC_NAM_AC_ID,
            n.AC_NAM_ChangedAt,
            n.AC_NAM_PositedAt,
            n.AC_NAM_Checksum
        FROM
            @AC_NAM_Actor_Name n
        WHERE
            n.AC_NAM_StatementType in ('P', 'A')
        AND
            n.AC_NAM_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.AC_NAM_ID,
            p.AC_NAM_Checksum
        FROM
            [dbo].[AC_NAM_Actor_Name_Posit] p
        JOIN
            [dbo].[AC_NAM_Actor_Name_Annex] a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
        AND
            a.AC_NAM_PositedAt = (
                SELECT
                    max(s.AC_NAM_PositedAt)
                FROM
                    [dbo].[AC_NAM_Actor_Name_Annex] s
                WHERE
                    s.AC_NAM_ID = p.AC_NAM_ID
                AND
                    s.AC_NAM_PositedAt < v.AC_NAM_PositedAt
            )
        WHERE
            p.AC_NAM_AC_ID = v.AC_NAM_AC_ID
        AND
            p.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
        AND
            a.AC_NAM_Reliability = 1
        ORDER BY
            a.AC_NAM_PositedAt DESC
    ) e
    WHERE
        e.AC_NAM_Checksum <> v.AC_NAM_Checksum
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_NAM_Actor_Name_Annex] x
        WHERE
            x.AC_NAM_ID = e.AC_NAM_ID
        AND
            x.AC_NAM_PositedAt = v.AC_NAM_PositedAt
    );
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
        AC_GEN_AC_ID int not null,
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_GEN_AC_ID,
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
                p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
            AND
                p.AC_GEN_GEN_ID = i.AC_GEN_GEN_ID
            AND
                a.AC_GEN_PositedAt = i.AC_GEN_PositedAt
            AND
                a.AC_GEN_Reliability <> i.AC_GEN_Reliability
        )
        OR (
            i.AC_GEN_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[AC_GEN_Actor_Gender_Posit] p
                JOIN
                    [dbo].[AC_GEN_Actor_Gender_Annex] a
                ON
                    a.AC_GEN_ID = p.AC_GEN_ID
                WHERE
                    p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
                AND
                    p.AC_GEN_GEN_ID <> i.AC_GEN_GEN_ID
                AND
                    a.AC_GEN_PositedAt = i.AC_GEN_PositedAt
                AND
                    a.AC_GEN_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.AC_GEN_AC_ID = i.AC_GEN_AC_ID
                AND
                    j.AC_GEN_GEN_ID <> i.AC_GEN_GEN_ID
                AND
                    j.AC_GEN_PositedAt = i.AC_GEN_PositedAt
                AND
                    j.AC_GEN_Reliability = 1
            )
        )
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
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    ON
        p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
    AND
        p.AC_GEN_GEN_ID = i.AC_GEN_GEN_ID
    LEFT JOIN
        [dbo].[AC_GEN_Actor_Gender_Annex] a
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
        x.AC_GEN_AC_ID,
        x.Metadata_AC_GEN,
        x.AC_GEN_PositedAt,
        x.AC_GEN_Reliability,
        x.AC_GEN_GEN_ID,
        'X' -- existing data
    FROM (
        SELECT
            i.AC_GEN_AC_ID,
            a.Metadata_AC_GEN,
            a.AC_GEN_PositedAt,
            a.AC_GEN_Reliability,
            p.AC_GEN_GEN_ID,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.AC_GEN_AC_ID,
                    a.AC_GEN_PositedAt
                ORDER BY
                    a.AC_GEN_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT AC_GEN_AC_ID FROM @AC_GEN_Actor_Gender) i
        JOIN
            [dbo].[AC_GEN_Actor_Gender_Posit] p
        ON
            p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
        JOIN
            [dbo].[AC_GEN_Actor_Gender_Annex] a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @AC_GEN_Actor_Gender n
        WHERE
            n.AC_GEN_AC_ID = x.AC_GEN_AC_ID
        AND
            n.AC_GEN_PositedAt = x.AC_GEN_PositedAt
    );
    DECLARE @retracted TABLE (
        AC_GEN_AC_ID int not null,
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
            (a.AC_GEN_Reliability = 0 AND isnull(pre.AC_GEN_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
    SELECT
        v.AC_GEN_AC_ID,
        v.AC_GEN_GEN_ID
    FROM
        @AC_GEN_Actor_Gender v
    WHERE
        v.AC_GEN_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @AC_GEN_Actor_Gender w
        WHERE
            w.AC_GEN_StatementType = 'P'
        AND
            w.AC_GEN_AC_ID = v.AC_GEN_AC_ID
        AND
            w.AC_GEN_GEN_ID = v.AC_GEN_GEN_ID
        AND
            w.AC_GEN_PositedAt < v.AC_GEN_PositedAt
    );
    INSERT INTO [dbo].[AC_GEN_Actor_Gender_Annex] (
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
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    ON
        p.AC_GEN_AC_ID = v.AC_GEN_AC_ID
    AND
        p.AC_GEN_GEN_ID = v.AC_GEN_GEN_ID
    WHERE
        AC_GEN_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[AC_GEN_Actor_Gender_Annex] (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        v.Metadata_AC_GEN,
        e.AC_GEN_ID,
        v.AC_GEN_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_AC_GEN,
            n.AC_GEN_AC_ID,
            n.AC_GEN_PositedAt,
            n.AC_GEN_GEN_ID
        FROM
            @AC_GEN_Actor_Gender n
        WHERE
            n.AC_GEN_StatementType in ('P', 'A')
        AND
            n.AC_GEN_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.AC_GEN_ID,
            p.AC_GEN_GEN_ID
        FROM
            [dbo].[AC_GEN_Actor_Gender_Posit] p
        JOIN
            [dbo].[AC_GEN_Actor_Gender_Annex] a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
        AND
            a.AC_GEN_PositedAt = (
                SELECT
                    max(s.AC_GEN_PositedAt)
                FROM
                    [dbo].[AC_GEN_Actor_Gender_Annex] s
                WHERE
                    s.AC_GEN_ID = p.AC_GEN_ID
                AND
                    s.AC_GEN_PositedAt < v.AC_GEN_PositedAt
            )
        WHERE
            p.AC_GEN_AC_ID = v.AC_GEN_AC_ID
        AND
            a.AC_GEN_Reliability = 1
        ORDER BY
            a.AC_GEN_PositedAt DESC
    ) e
    WHERE
        e.AC_GEN_GEN_ID <> v.AC_GEN_GEN_ID
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_GEN_Actor_Gender_Annex] x
        WHERE
            x.AC_GEN_ID = e.AC_GEN_ID
        AND
            x.AC_GEN_PositedAt = v.AC_GEN_PositedAt
    );
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
        AC_PLV_AC_ID int not null,
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_PLV_AC_ID,
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
                p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
            AND
                p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
            AND
                p.AC_PLV_PLV_ID = i.AC_PLV_PLV_ID
            AND
                a.AC_PLV_PositedAt = i.AC_PLV_PositedAt
            AND
                a.AC_PLV_Reliability <> i.AC_PLV_Reliability
        )
        OR (
            i.AC_PLV_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
                JOIN
                    [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
                ON
                    a.AC_PLV_ID = p.AC_PLV_ID
                WHERE
                    p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
                AND
                    p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
                AND
                    p.AC_PLV_PLV_ID <> i.AC_PLV_PLV_ID
                AND
                    a.AC_PLV_PositedAt = i.AC_PLV_PositedAt
                AND
                    a.AC_PLV_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.AC_PLV_AC_ID = i.AC_PLV_AC_ID
                AND
                    j.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
                AND
                    j.AC_PLV_PLV_ID <> i.AC_PLV_PLV_ID
                AND
                    j.AC_PLV_PositedAt = i.AC_PLV_PositedAt
                AND
                    j.AC_PLV_Reliability = 1
            )
        )
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
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
    AND
        p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
    AND
        p.AC_PLV_PLV_ID = i.AC_PLV_PLV_ID
    LEFT JOIN
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
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
        x.AC_PLV_AC_ID,
        x.Metadata_AC_PLV,
        x.AC_PLV_ChangedAt,
        x.AC_PLV_PositedAt,
        x.AC_PLV_Reliability,
        x.AC_PLV_PLV_ID,
        'X' -- existing data
    FROM (
        SELECT
            i.AC_PLV_AC_ID,
            a.Metadata_AC_PLV,
            p.AC_PLV_ChangedAt,
            a.AC_PLV_PositedAt,
            a.AC_PLV_Reliability,
            p.AC_PLV_PLV_ID,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.AC_PLV_AC_ID,
                    p.AC_PLV_ChangedAt,
                    a.AC_PLV_PositedAt
                ORDER BY
                    a.AC_PLV_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT AC_PLV_AC_ID FROM @AC_PLV_Actor_ProfessionalLevel) i
        JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
        ON
            p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
        JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @AC_PLV_Actor_ProfessionalLevel n
        WHERE
            n.AC_PLV_AC_ID = x.AC_PLV_AC_ID
        AND
            n.AC_PLV_ChangedAt = x.AC_PLV_ChangedAt
        AND
            n.AC_PLV_PositedAt = x.AC_PLV_PositedAt
    );
    DECLARE @retracted TABLE (
        AC_PLV_AC_ID int not null,
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
            (a.AC_PLV_Reliability = 0 AND isnull(pre.AC_PLV_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
    SELECT
        v.AC_PLV_AC_ID,
        v.AC_PLV_ChangedAt,
        v.AC_PLV_PLV_ID
    FROM
        @AC_PLV_Actor_ProfessionalLevel v
    WHERE
        v.AC_PLV_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @AC_PLV_Actor_ProfessionalLevel w
        WHERE
            w.AC_PLV_StatementType = 'P'
        AND
            w.AC_PLV_AC_ID = v.AC_PLV_AC_ID
        AND
            w.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
        AND
            w.AC_PLV_PLV_ID = v.AC_PLV_PLV_ID
        AND
            w.AC_PLV_PositedAt < v.AC_PLV_PositedAt
    );
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] (
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
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    ON
        p.AC_PLV_AC_ID = v.AC_PLV_AC_ID
    AND
        p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
    AND
        p.AC_PLV_PLV_ID = v.AC_PLV_PLV_ID
    WHERE
        AC_PLV_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        v.Metadata_AC_PLV,
        e.AC_PLV_ID,
        v.AC_PLV_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_AC_PLV,
            n.AC_PLV_AC_ID,
            n.AC_PLV_ChangedAt,
            n.AC_PLV_PositedAt,
            n.AC_PLV_PLV_ID
        FROM
            @AC_PLV_Actor_ProfessionalLevel n
        WHERE
            n.AC_PLV_StatementType in ('P', 'A')
        AND
            n.AC_PLV_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.AC_PLV_ID,
            p.AC_PLV_PLV_ID
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
        JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
        AND
            a.AC_PLV_PositedAt = (
                SELECT
                    max(s.AC_PLV_PositedAt)
                FROM
                    [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] s
                WHERE
                    s.AC_PLV_ID = p.AC_PLV_ID
                AND
                    s.AC_PLV_PositedAt < v.AC_PLV_PositedAt
            )
        WHERE
            p.AC_PLV_AC_ID = v.AC_PLV_AC_ID
        AND
            p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
        AND
            a.AC_PLV_Reliability = 1
        ORDER BY
            a.AC_PLV_PositedAt DESC
    ) e
    WHERE
        e.AC_PLV_PLV_ID <> v.AC_PLV_PLV_ID
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] x
        WHERE
            x.AC_PLV_ID = e.AC_PLV_ID
        AND
            x.AC_PLV_PositedAt = v.AC_PLV_PositedAt
    );
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
        PR_NAM_PR_ID int not null,
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_NAM_PR_ID,
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
                p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
            AND
                p.PR_NAM_Program_Name = i.PR_NAM_Program_Name
            AND
                a.PR_NAM_PositedAt = i.PR_NAM_PositedAt
            AND
                a.PR_NAM_Reliability <> i.PR_NAM_Reliability
        )
        OR (
            i.PR_NAM_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[PR_NAM_Program_Name_Posit] p
                JOIN
                    [dbo].[PR_NAM_Program_Name_Annex] a
                ON
                    a.PR_NAM_ID = p.PR_NAM_ID
                WHERE
                    p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
                AND
                    p.PR_NAM_Program_Name <> i.PR_NAM_Program_Name
                AND
                    a.PR_NAM_PositedAt = i.PR_NAM_PositedAt
                AND
                    a.PR_NAM_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.PR_NAM_PR_ID = i.PR_NAM_PR_ID
                AND
                    j.PR_NAM_Program_Name <> i.PR_NAM_Program_Name
                AND
                    j.PR_NAM_PositedAt = i.PR_NAM_PositedAt
                AND
                    j.PR_NAM_Reliability = 1
            )
        )
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
        [dbo].[PR_NAM_Program_Name_Posit] p
    ON
        p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
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
        PR_NAM_PR_ID,
        Metadata_PR_NAM,
        PR_NAM_PositedAt,
        PR_NAM_Reliability,
        PR_NAM_Program_Name,
        PR_NAM_StatementType
    )
    SELECT
        x.PR_NAM_PR_ID,
        x.Metadata_PR_NAM,
        x.PR_NAM_PositedAt,
        x.PR_NAM_Reliability,
        x.PR_NAM_Program_Name,
        'X' -- existing data
    FROM (
        SELECT
            i.PR_NAM_PR_ID,
            a.Metadata_PR_NAM,
            a.PR_NAM_PositedAt,
            a.PR_NAM_Reliability,
            p.PR_NAM_Program_Name,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.PR_NAM_PR_ID,
                    a.PR_NAM_PositedAt
                ORDER BY
                    a.PR_NAM_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT PR_NAM_PR_ID FROM @PR_NAM_Program_Name) i
        JOIN
            [dbo].[PR_NAM_Program_Name_Posit] p
        ON
            p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
        JOIN
            [dbo].[PR_NAM_Program_Name_Annex] a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @PR_NAM_Program_Name n
        WHERE
            n.PR_NAM_PR_ID = x.PR_NAM_PR_ID
        AND
            n.PR_NAM_PositedAt = x.PR_NAM_PositedAt
    );
    DECLARE @retracted TABLE (
        PR_NAM_PR_ID int not null,
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
            (a.PR_NAM_Reliability = 0 AND isnull(pre.PR_NAM_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    )
    SELECT
        v.PR_NAM_PR_ID,
        v.PR_NAM_Program_Name
    FROM
        @PR_NAM_Program_Name v
    WHERE
        v.PR_NAM_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @PR_NAM_Program_Name w
        WHERE
            w.PR_NAM_StatementType = 'P'
        AND
            w.PR_NAM_PR_ID = v.PR_NAM_PR_ID
        AND
            w.PR_NAM_Program_Name = v.PR_NAM_Program_Name
        AND
            w.PR_NAM_PositedAt < v.PR_NAM_PositedAt
    );
    INSERT INTO [dbo].[PR_NAM_Program_Name_Annex] (
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
        [dbo].[PR_NAM_Program_Name_Posit] p
    ON
        p.PR_NAM_PR_ID = v.PR_NAM_PR_ID
    AND
        p.PR_NAM_Program_Name = v.PR_NAM_Program_Name
    WHERE
        PR_NAM_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[PR_NAM_Program_Name_Annex] (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        v.Metadata_PR_NAM,
        e.PR_NAM_ID,
        v.PR_NAM_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_PR_NAM,
            n.PR_NAM_PR_ID,
            n.PR_NAM_PositedAt,
            n.PR_NAM_Program_Name
        FROM
            @PR_NAM_Program_Name n
        WHERE
            n.PR_NAM_StatementType in ('P', 'A')
        AND
            n.PR_NAM_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.PR_NAM_ID,
            p.PR_NAM_Program_Name
        FROM
            [dbo].[PR_NAM_Program_Name_Posit] p
        JOIN
            [dbo].[PR_NAM_Program_Name_Annex] a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
        AND
            a.PR_NAM_PositedAt = (
                SELECT
                    max(s.PR_NAM_PositedAt)
                FROM
                    [dbo].[PR_NAM_Program_Name_Annex] s
                WHERE
                    s.PR_NAM_ID = p.PR_NAM_ID
                AND
                    s.PR_NAM_PositedAt < v.PR_NAM_PositedAt
            )
        WHERE
            p.PR_NAM_PR_ID = v.PR_NAM_PR_ID
        AND
            a.PR_NAM_Reliability = 1
        ORDER BY
            a.PR_NAM_PositedAt DESC
    ) e
    WHERE
        e.PR_NAM_Program_Name <> v.PR_NAM_Program_Name
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[PR_NAM_Program_Name_Annex] x
        WHERE
            x.PR_NAM_ID = e.PR_NAM_ID
        AND
            x.PR_NAM_PositedAt = v.PR_NAM_PositedAt
    );
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
        PR_LEN_PR_ID int not null,
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_LEN_PR_ID,
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
                p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
            AND
                p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
            AND
                p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
            AND
                a.PR_LEN_PositedAt = i.PR_LEN_PositedAt
            AND
                a.PR_LEN_Reliability <> i.PR_LEN_Reliability
        )
        OR (
            i.PR_LEN_Reliability = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [dbo].[PR_LEN_Program_Length_Posit] p
                JOIN
                    [dbo].[PR_LEN_Program_Length_Annex] a
                ON
                    a.PR_LEN_ID = p.PR_LEN_ID
                WHERE
                    p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
                AND
                    p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
                AND
                    p.PR_LEN_Program_Length <> i.PR_LEN_Program_Length
                AND
                    a.PR_LEN_PositedAt = i.PR_LEN_PositedAt
                AND
                    a.PR_LEN_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.PR_LEN_PR_ID = i.PR_LEN_PR_ID
                AND
                    j.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
                AND
                    j.PR_LEN_Program_Length <> i.PR_LEN_Program_Length
                AND
                    j.PR_LEN_PositedAt = i.PR_LEN_PositedAt
                AND
                    j.PR_LEN_Reliability = 1
            )
        )
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
        [dbo].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
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
        x.PR_LEN_PositedAt,
        x.PR_LEN_Reliability,
        x.PR_LEN_Program_Length,
        'X' -- existing data
    FROM (
        SELECT
            i.PR_LEN_PR_ID,
            a.Metadata_PR_LEN,
            p.PR_LEN_ChangedAt,
            a.PR_LEN_PositedAt,
            a.PR_LEN_Reliability,
            p.PR_LEN_Program_Length,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.PR_LEN_PR_ID,
                    p.PR_LEN_ChangedAt,
                    a.PR_LEN_PositedAt
                ORDER BY
                    a.PR_LEN_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT PR_LEN_PR_ID FROM @PR_LEN_Program_Length) i
        JOIN
            [dbo].[PR_LEN_Program_Length_Posit] p
        ON
            p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
        JOIN
            [dbo].[PR_LEN_Program_Length_Annex] a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @PR_LEN_Program_Length n
        WHERE
            n.PR_LEN_PR_ID = x.PR_LEN_PR_ID
        AND
            n.PR_LEN_ChangedAt = x.PR_LEN_ChangedAt
        AND
            n.PR_LEN_PositedAt = x.PR_LEN_PositedAt
    );
    DECLARE @retracted TABLE (
        PR_LEN_PR_ID int not null,
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
            (a.PR_LEN_Reliability = 0 AND isnull(pre.PR_LEN_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
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
    -- the new values that only restate the previous version, which are skipped, though what they correct is retracted
    DECLARE @skipped TABLE (
        PR_LEN_PR_ID int not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Program_Length time not null
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
        PR_LEN_PR_ID int not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null
    );
    INSERT INTO @skipped (
        PR_LEN_PR_ID,
        Metadata_PR_LEN,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Program_Length
    )
    SELECT
        a.PR_LEN_PR_ID,
        a.Metadata_PR_LEN,
        a.PR_LEN_ChangedAt,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Program_Length
    FROM
        @PR_LEN_Program_Length a
    CROSS APPLY (
        SELECT TOP 1
            h.PR_LEN_Program_Length
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
        a.PR_LEN_StatementType in ('P', 'A')
    AND
        a.PR_LEN_Reliability = 1
    AND
        a.PR_LEN_Program_Length = pre.PR_LEN_Program_Length;
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
        [dbo].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
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
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    SELECT
        v.PR_LEN_PR_ID,
        v.PR_LEN_ChangedAt,
        v.PR_LEN_Program_Length
    FROM
        @PR_LEN_Program_Length v
    WHERE
        v.PR_LEN_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @PR_LEN_Program_Length w
        WHERE
            w.PR_LEN_StatementType = 'P'
        AND
            w.PR_LEN_PR_ID = v.PR_LEN_PR_ID
        AND
            w.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
        AND
            w.PR_LEN_Program_Length = v.PR_LEN_Program_Length
        AND
            w.PR_LEN_PositedAt < v.PR_LEN_PositedAt
    );
    INSERT INTO [dbo].[PR_LEN_Program_Length_Annex] (
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
        [dbo].[PR_LEN_Program_Length_Posit] p
    ON
        p.PR_LEN_PR_ID = v.PR_LEN_PR_ID
    AND
        p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
    AND
        p.PR_LEN_Program_Length = v.PR_LEN_Program_Length
    WHERE
        PR_LEN_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted; also when the assertion is a restatement that an
    -- idempotent attribute skips
    INSERT INTO [dbo].[PR_LEN_Program_Length_Annex] (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        v.Metadata_PR_LEN,
        e.PR_LEN_ID,
        v.PR_LEN_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_PR_LEN,
            n.PR_LEN_PR_ID,
            n.PR_LEN_ChangedAt,
            n.PR_LEN_PositedAt,
            n.PR_LEN_Program_Length
        FROM
            @PR_LEN_Program_Length n
        WHERE
            n.PR_LEN_StatementType in ('P', 'A')
        AND
            n.PR_LEN_Reliability = 1
        UNION ALL
        SELECT
            k.Metadata_PR_LEN,
            k.PR_LEN_PR_ID,
            k.PR_LEN_ChangedAt,
            k.PR_LEN_PositedAt,
            k.PR_LEN_Program_Length
        FROM
            @skipped k
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.PR_LEN_ID,
            p.PR_LEN_Program_Length
        FROM
            [dbo].[PR_LEN_Program_Length_Posit] p
        JOIN
            [dbo].[PR_LEN_Program_Length_Annex] a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
        AND
            a.PR_LEN_PositedAt = (
                SELECT
                    max(s.PR_LEN_PositedAt)
                FROM
                    [dbo].[PR_LEN_Program_Length_Annex] s
                WHERE
                    s.PR_LEN_ID = p.PR_LEN_ID
                AND
                    s.PR_LEN_PositedAt < v.PR_LEN_PositedAt
            )
        WHERE
            p.PR_LEN_PR_ID = v.PR_LEN_PR_ID
        AND
            p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
        AND
            a.PR_LEN_Reliability = 1
        ORDER BY
            a.PR_LEN_PositedAt DESC
    ) e
    WHERE
        e.PR_LEN_Program_Length <> v.PR_LEN_Program_Length
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[PR_LEN_Program_Length_Annex] x
        WHERE
            x.PR_LEN_ID = e.PR_LEN_ID
        AND
            x.PR_LEN_PositedAt = v.PR_LEN_PositedAt
    );
END
GO
