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
-- it_EV_QTY_Event_Quantity instead of INSERT trigger on EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_QTY_Event_Quantity', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_QTY_Event_Quantity];
GO
CREATE TRIGGER [dbo].[it_EV_QTY_Event_Quantity] ON [dbo].[EV_QTY_Event_Quantity]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_QTY_Event_Quantity TABLE (
        EV_QTY_EV_ID int not null,
        Metadata_EV_QTY int not null,
        EV_QTY_PositedAt datetime2 not null,
        EV_QTY_Reliability decimal(5,2) not null,
        EV_QTY_Event_Quantity int not null,
        EV_QTY_StatementType char(1) not null,
        primary key (
            EV_QTY_EV_ID asc,
            EV_QTY_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_QTY_EV_ID,
            i.EV_QTY_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_QTY_Event_Quantity_Posit] p
            JOIN
                [dbo].[EV_QTY_Event_Quantity_Annex] a
            ON
                a.EV_QTY_ID = p.EV_QTY_ID
            WHERE
                p.EV_QTY_EV_ID = i.EV_QTY_EV_ID
            AND
                p.EV_QTY_Event_Quantity = i.EV_QTY_Event_Quantity
            AND
                a.EV_QTY_PositedAt = i.EV_QTY_PositedAt
            AND
                a.EV_QTY_Reliability <> i.EV_QTY_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_QTY_Event_Quantity for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_QTY_Event_Quantity
    SELECT
        i.EV_QTY_EV_ID,
        i.Metadata_EV_QTY,
        i.EV_QTY_PositedAt,
        i.EV_QTY_Reliability,
        i.EV_QTY_Event_Quantity,
        CASE
            WHEN p.EV_QTY_ID is null
            THEN 'P' -- new posit
            WHEN a.EV_QTY_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[EV_QTY_Event_Quantity_Posit] p
    ON
        p.EV_QTY_EV_ID = i.EV_QTY_EV_ID
    AND
        p.EV_QTY_Event_Quantity = i.EV_QTY_Event_Quantity
    LEFT JOIN
        [dbo].[EV_QTY_Event_Quantity_Annex] a
    ON
        a.EV_QTY_ID = p.EV_QTY_ID
    AND
        a.EV_QTY_PositedAt = i.EV_QTY_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_QTY_ID is null OR a.EV_QTY_ID is null);
    INSERT INTO @EV_QTY_Event_Quantity (
        EV_QTY_EV_ID,
        Metadata_EV_QTY,
        EV_QTY_PositedAt,
        EV_QTY_Reliability,
        EV_QTY_Event_Quantity,
        EV_QTY_StatementType
    )
    SELECT
        x.EV_QTY_EV_ID,
        x.Metadata_EV_QTY,
        x.EV_QTY_PositedAt,
        x.EV_QTY_Reliability,
        x.EV_QTY_Event_Quantity,
        'X' -- existing data
    FROM (
        SELECT
            i.EV_QTY_EV_ID,
            a.Metadata_EV_QTY,
            a.EV_QTY_PositedAt,
            a.EV_QTY_Reliability,
            p.EV_QTY_Event_Quantity,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.EV_QTY_EV_ID,
                    a.EV_QTY_PositedAt
                ORDER BY
                    a.EV_QTY_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT EV_QTY_EV_ID FROM @EV_QTY_Event_Quantity) i
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        ON
            p.EV_QTY_EV_ID = i.EV_QTY_EV_ID
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Annex] a
        ON
            a.EV_QTY_ID = p.EV_QTY_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        EV_QTY_EV_ID int not null,
        Metadata_EV_QTY int not null,
        EV_QTY_PositedAt datetime2 not null,
        EV_QTY_Reliability decimal(5,2) not null,
        EV_QTY_Event_Quantity int not null,
        EV_QTY_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_QTY_EV_ID,
        Metadata_EV_QTY,
        EV_QTY_PositedAt,
        EV_QTY_Reliability,
        EV_QTY_Event_Quantity,
        EV_QTY_StatementType
    )
    SELECT
        EV_QTY_EV_ID,
        Metadata_EV_QTY,
        EV_QTY_PositedAt,
        EV_QTY_Reliability,
        EV_QTY_Event_Quantity,
        EV_QTY_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.EV_QTY_Reliability as previous_EV_QTY_Reliability,
            fol.EV_QTY_Reliability as following_EV_QTY_Reliability
        FROM
            @EV_QTY_Event_Quantity a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_QTY_Reliability
            FROM
                @EV_QTY_Event_Quantity p
            WHERE
                p.EV_QTY_EV_ID = a.EV_QTY_EV_ID
            AND
                p.EV_QTY_PositedAt < a.EV_QTY_PositedAt
            ORDER BY
                p.EV_QTY_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_QTY_Reliability
            FROM
                @EV_QTY_Event_Quantity p
            WHERE
                p.EV_QTY_EV_ID = a.EV_QTY_EV_ID
            AND
                p.EV_QTY_PositedAt > a.EV_QTY_PositedAt
            ORDER BY
                p.EV_QTY_PositedAt ASC
        ) fol
        WHERE
            (a.EV_QTY_Reliability = 0 AND isnull(pre.EV_QTY_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.EV_QTY_Reliability = 1 AND fol.EV_QTY_Reliability = 0)
    ) i
    WHERE
        i.EV_QTY_StatementType <> 'X'
    AND (
            (i.EV_QTY_Reliability = 0 AND i.previous_EV_QTY_Reliability = 1)
        OR
            (i.EV_QTY_Reliability = 1 AND i.following_EV_QTY_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @EV_QTY_Event_Quantity SELECT * FROM @retracted;
    INSERT INTO [dbo].[EV_QTY_Event_Quantity_Posit] (
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity
    )
    SELECT
        v.EV_QTY_EV_ID,
        v.EV_QTY_Event_Quantity
    FROM
        @EV_QTY_Event_Quantity v
    WHERE
        v.EV_QTY_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @EV_QTY_Event_Quantity w
        WHERE
            w.EV_QTY_StatementType = 'P'
        AND
            w.EV_QTY_EV_ID = v.EV_QTY_EV_ID
        AND
            w.EV_QTY_Event_Quantity = v.EV_QTY_Event_Quantity
        AND
            w.EV_QTY_PositedAt < v.EV_QTY_PositedAt
    );
    INSERT INTO [dbo].[EV_QTY_Event_Quantity_Annex] (
        Metadata_EV_QTY,
        EV_QTY_ID,
        EV_QTY_PositedAt,
        EV_QTY_Reliability
    )
    SELECT
        v.Metadata_EV_QTY,
        p.EV_QTY_ID,
        v.EV_QTY_PositedAt,
        v.EV_QTY_Reliability
    FROM
        @EV_QTY_Event_Quantity v
    JOIN
        [dbo].[EV_QTY_Event_Quantity_Posit] p
    ON
        p.EV_QTY_EV_ID = v.EV_QTY_EV_ID
    AND
        p.EV_QTY_Event_Quantity = v.EV_QTY_Event_Quantity
    WHERE
        EV_QTY_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[EV_QTY_Event_Quantity_Annex] (
        Metadata_EV_QTY,
        EV_QTY_ID,
        EV_QTY_PositedAt,
        EV_QTY_Reliability
    )
    SELECT
        v.Metadata_EV_QTY,
        e.EV_QTY_ID,
        v.EV_QTY_PositedAt,
        0
    FROM
        @EV_QTY_Event_Quantity v
    CROSS APPLY (
        SELECT TOP 1
            p.EV_QTY_ID,
            p.EV_QTY_Event_Quantity
        FROM
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Annex] a
        ON
            a.EV_QTY_ID = p.EV_QTY_ID
        AND
            a.EV_QTY_PositedAt = (
                SELECT
                    max(s.EV_QTY_PositedAt)
                FROM
                    [dbo].[EV_QTY_Event_Quantity_Annex] s
                WHERE
                    s.EV_QTY_ID = p.EV_QTY_ID
                AND
                    s.EV_QTY_PositedAt < v.EV_QTY_PositedAt
            )
        WHERE
            p.EV_QTY_EV_ID = v.EV_QTY_EV_ID
        AND
            a.EV_QTY_Reliability = 1
        ORDER BY
            a.EV_QTY_PositedAt DESC
    ) e
    WHERE
        v.EV_QTY_StatementType in ('P', 'A')
    AND
        v.EV_QTY_Reliability = 1
    AND
        e.EV_QTY_Event_Quantity <> v.EV_QTY_Event_Quantity
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_QTY_Event_Quantity_Annex] x
        WHERE
            x.EV_QTY_ID = e.EV_QTY_ID
        AND
            x.EV_QTY_PositedAt = v.EV_QTY_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_PLC_Event_Place instead of INSERT trigger on EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_PLC_Event_Place', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_PLC_Event_Place];
GO
CREATE TRIGGER [dbo].[it_EV_PLC_Event_Place] ON [dbo].[EV_PLC_Event_Place]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EV_PLC_Event_Place TABLE (
        EV_PLC_EV_ID int not null,
        Metadata_EV_PLC int not null,
        EV_PLC_ChangedAt datetime2 not null,
        EV_PLC_PositedAt datetime2 not null,
        EV_PLC_Reliability decimal(5,2) not null,
        EV_PLC_Event_Place nvarchar(42) not null,
        EV_PLC_StatementType char(1) not null,
        primary key (
            EV_PLC_EV_ID asc,
            EV_PLC_ChangedAt desc,
            EV_PLC_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_PLC_EV_ID,
            i.EV_PLC_ChangedAt,
            i.EV_PLC_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_PLC_Event_Place_Posit] p
            JOIN
                [dbo].[EV_PLC_Event_Place_Annex] a
            ON
                a.EV_PLC_ID = p.EV_PLC_ID
            WHERE
                p.EV_PLC_EV_ID = i.EV_PLC_EV_ID
            AND
                p.EV_PLC_ChangedAt = i.EV_PLC_ChangedAt
            AND
                p.EV_PLC_Event_Place = i.EV_PLC_Event_Place
            AND
                a.EV_PLC_PositedAt = i.EV_PLC_PositedAt
            AND
                a.EV_PLC_Reliability <> i.EV_PLC_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_PLC_Event_Place for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_PLC_Event_Place
    SELECT
        i.EV_PLC_EV_ID,
        i.Metadata_EV_PLC,
        i.EV_PLC_ChangedAt,
        i.EV_PLC_PositedAt,
        i.EV_PLC_Reliability,
        i.EV_PLC_Event_Place,
        CASE
            WHEN p.EV_PLC_ID is null
            THEN 'P' -- new posit
            WHEN a.EV_PLC_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[EV_PLC_Event_Place_Posit] p
    ON
        p.EV_PLC_EV_ID = i.EV_PLC_EV_ID
    AND
        p.EV_PLC_ChangedAt = i.EV_PLC_ChangedAt
    AND
        p.EV_PLC_Event_Place = i.EV_PLC_Event_Place
    LEFT JOIN
        [dbo].[EV_PLC_Event_Place_Annex] a
    ON
        a.EV_PLC_ID = p.EV_PLC_ID
    AND
        a.EV_PLC_PositedAt = i.EV_PLC_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_PLC_ID is null OR a.EV_PLC_ID is null);
    INSERT INTO @EV_PLC_Event_Place (
        EV_PLC_EV_ID,
        Metadata_EV_PLC,
        EV_PLC_ChangedAt,
        EV_PLC_PositedAt,
        EV_PLC_Reliability,
        EV_PLC_Event_Place,
        EV_PLC_StatementType
    )
    SELECT
        x.EV_PLC_EV_ID,
        x.Metadata_EV_PLC,
        x.EV_PLC_ChangedAt,
        x.EV_PLC_PositedAt,
        x.EV_PLC_Reliability,
        x.EV_PLC_Event_Place,
        'X' -- existing data
    FROM (
        SELECT
            i.EV_PLC_EV_ID,
            a.Metadata_EV_PLC,
            p.EV_PLC_ChangedAt,
            a.EV_PLC_PositedAt,
            a.EV_PLC_Reliability,
            p.EV_PLC_Event_Place,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.EV_PLC_EV_ID,
                    p.EV_PLC_ChangedAt,
                    a.EV_PLC_PositedAt
                ORDER BY
                    a.EV_PLC_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT EV_PLC_EV_ID FROM @EV_PLC_Event_Place) i
        JOIN
            [dbo].[EV_PLC_Event_Place_Posit] p
        ON
            p.EV_PLC_EV_ID = i.EV_PLC_EV_ID
        JOIN
            [dbo].[EV_PLC_Event_Place_Annex] a
        ON
            a.EV_PLC_ID = p.EV_PLC_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        EV_PLC_EV_ID int not null,
        Metadata_EV_PLC int not null,
        EV_PLC_ChangedAt datetime2 not null,
        EV_PLC_PositedAt datetime2 not null,
        EV_PLC_Reliability decimal(5,2) not null,
        EV_PLC_Event_Place nvarchar(42) not null,
        EV_PLC_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        EV_PLC_EV_ID,
        Metadata_EV_PLC,
        EV_PLC_ChangedAt,
        EV_PLC_PositedAt,
        EV_PLC_Reliability,
        EV_PLC_Event_Place,
        EV_PLC_StatementType
    )
    SELECT
        EV_PLC_EV_ID,
        Metadata_EV_PLC,
        EV_PLC_ChangedAt,
        EV_PLC_PositedAt,
        EV_PLC_Reliability,
        EV_PLC_Event_Place,
        EV_PLC_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.EV_PLC_Reliability as previous_EV_PLC_Reliability,
            fol.EV_PLC_Reliability as following_EV_PLC_Reliability
        FROM
            @EV_PLC_Event_Place a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_PLC_Reliability
            FROM
                @EV_PLC_Event_Place p
            WHERE
                p.EV_PLC_EV_ID = a.EV_PLC_EV_ID
            AND
                p.EV_PLC_ChangedAt = a.EV_PLC_ChangedAt
            AND
                p.EV_PLC_PositedAt < a.EV_PLC_PositedAt
            ORDER BY
                p.EV_PLC_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_PLC_Reliability
            FROM
                @EV_PLC_Event_Place p
            WHERE
                p.EV_PLC_EV_ID = a.EV_PLC_EV_ID
            AND
                p.EV_PLC_ChangedAt = a.EV_PLC_ChangedAt
            AND
                p.EV_PLC_PositedAt > a.EV_PLC_PositedAt
            ORDER BY
                p.EV_PLC_PositedAt ASC
        ) fol
        WHERE
            (a.EV_PLC_Reliability = 0 AND isnull(pre.EV_PLC_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.EV_PLC_Reliability = 1 AND fol.EV_PLC_Reliability = 0)
    ) i
    WHERE
        i.EV_PLC_StatementType <> 'X'
    AND (
            (i.EV_PLC_Reliability = 0 AND i.previous_EV_PLC_Reliability = 1)
        OR
            (i.EV_PLC_Reliability = 1 AND i.following_EV_PLC_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @EV_PLC_Event_Place SELECT * FROM @retracted;
    INSERT INTO [dbo].[EV_PLC_Event_Place_Posit] (
        EV_PLC_EV_ID,
        EV_PLC_ChangedAt,
        EV_PLC_Event_Place
    )
    SELECT
        v.EV_PLC_EV_ID,
        v.EV_PLC_ChangedAt,
        v.EV_PLC_Event_Place
    FROM
        @EV_PLC_Event_Place v
    WHERE
        v.EV_PLC_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @EV_PLC_Event_Place w
        WHERE
            w.EV_PLC_StatementType = 'P'
        AND
            w.EV_PLC_EV_ID = v.EV_PLC_EV_ID
        AND
            w.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
        AND
            w.EV_PLC_Event_Place = v.EV_PLC_Event_Place
        AND
            w.EV_PLC_PositedAt < v.EV_PLC_PositedAt
    );
    INSERT INTO [dbo].[EV_PLC_Event_Place_Annex] (
        Metadata_EV_PLC,
        EV_PLC_ID,
        EV_PLC_PositedAt,
        EV_PLC_Reliability
    )
    SELECT
        v.Metadata_EV_PLC,
        p.EV_PLC_ID,
        v.EV_PLC_PositedAt,
        v.EV_PLC_Reliability
    FROM
        @EV_PLC_Event_Place v
    JOIN
        [dbo].[EV_PLC_Event_Place_Posit] p
    ON
        p.EV_PLC_EV_ID = v.EV_PLC_EV_ID
    AND
        p.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
    AND
        p.EV_PLC_Event_Place = v.EV_PLC_Event_Place
    WHERE
        EV_PLC_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[EV_PLC_Event_Place_Annex] (
        Metadata_EV_PLC,
        EV_PLC_ID,
        EV_PLC_PositedAt,
        EV_PLC_Reliability
    )
    SELECT
        v.Metadata_EV_PLC,
        e.EV_PLC_ID,
        v.EV_PLC_PositedAt,
        0
    FROM
        @EV_PLC_Event_Place v
    CROSS APPLY (
        SELECT TOP 1
            p.EV_PLC_ID,
            p.EV_PLC_Event_Place
        FROM
            [dbo].[EV_PLC_Event_Place_Posit] p
        JOIN
            [dbo].[EV_PLC_Event_Place_Annex] a
        ON
            a.EV_PLC_ID = p.EV_PLC_ID
        AND
            a.EV_PLC_PositedAt = (
                SELECT
                    max(s.EV_PLC_PositedAt)
                FROM
                    [dbo].[EV_PLC_Event_Place_Annex] s
                WHERE
                    s.EV_PLC_ID = p.EV_PLC_ID
                AND
                    s.EV_PLC_PositedAt < v.EV_PLC_PositedAt
            )
        WHERE
            p.EV_PLC_EV_ID = v.EV_PLC_EV_ID
        AND
            p.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
        AND
            a.EV_PLC_Reliability = 1
        ORDER BY
            a.EV_PLC_PositedAt DESC
    ) e
    WHERE
        v.EV_PLC_StatementType in ('P', 'A')
    AND
        v.EV_PLC_Reliability = 1
    AND
        e.EV_PLC_Event_Place <> v.EV_PLC_Event_Place
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_PLC_Event_Place_Annex] x
        WHERE
            x.EV_PLC_ID = e.EV_PLC_ID
        AND
            x.EV_PLC_PositedAt = v.EV_PLC_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NAM_Subject_Name instead of INSERT trigger on SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_NAM_Subject_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_NAM_Subject_Name];
GO
CREATE TRIGGER [dbo].[it_SU_NAM_Subject_Name] ON [dbo].[SU_NAM_Subject_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_NAM_Subject_Name TABLE (
        SU_NAM_SU_ID int not null,
        Metadata_SU_NAM int not null,
        SU_NAM_PositedAt datetime2 not null,
        SU_NAM_Reliability decimal(5,2) not null,
        SU_NAM_Subject_Name nvarchar(42) not null,
        SU_NAM_StatementType char(1) not null,
        primary key (
            SU_NAM_SU_ID asc,
            SU_NAM_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_NAM_SU_ID,
            i.SU_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_NAM_Subject_Name_Posit] p
            JOIN
                [dbo].[SU_NAM_Subject_Name_Annex] a
            ON
                a.SU_NAM_ID = p.SU_NAM_ID
            WHERE
                p.SU_NAM_SU_ID = i.SU_NAM_SU_ID
            AND
                p.SU_NAM_Subject_Name = i.SU_NAM_Subject_Name
            AND
                a.SU_NAM_PositedAt = i.SU_NAM_PositedAt
            AND
                a.SU_NAM_Reliability <> i.SU_NAM_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_NAM_Subject_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_NAM_Subject_Name
    SELECT
        i.SU_NAM_SU_ID,
        i.Metadata_SU_NAM,
        i.SU_NAM_PositedAt,
        i.SU_NAM_Reliability,
        i.SU_NAM_Subject_Name,
        CASE
            WHEN p.SU_NAM_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_NAM_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_NAM_Subject_Name_Posit] p
    ON
        p.SU_NAM_SU_ID = i.SU_NAM_SU_ID
    AND
        p.SU_NAM_Subject_Name = i.SU_NAM_Subject_Name
    LEFT JOIN
        [dbo].[SU_NAM_Subject_Name_Annex] a
    ON
        a.SU_NAM_ID = p.SU_NAM_ID
    AND
        a.SU_NAM_PositedAt = i.SU_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_NAM_ID is null OR a.SU_NAM_ID is null);
    INSERT INTO @SU_NAM_Subject_Name (
        SU_NAM_SU_ID,
        Metadata_SU_NAM,
        SU_NAM_PositedAt,
        SU_NAM_Reliability,
        SU_NAM_Subject_Name,
        SU_NAM_StatementType
    )
    SELECT
        x.SU_NAM_SU_ID,
        x.Metadata_SU_NAM,
        x.SU_NAM_PositedAt,
        x.SU_NAM_Reliability,
        x.SU_NAM_Subject_Name,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_NAM_SU_ID,
            a.Metadata_SU_NAM,
            a.SU_NAM_PositedAt,
            a.SU_NAM_Reliability,
            p.SU_NAM_Subject_Name,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_NAM_SU_ID,
                    a.SU_NAM_PositedAt
                ORDER BY
                    a.SU_NAM_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_NAM_SU_ID FROM @SU_NAM_Subject_Name) i
        JOIN
            [dbo].[SU_NAM_Subject_Name_Posit] p
        ON
            p.SU_NAM_SU_ID = i.SU_NAM_SU_ID
        JOIN
            [dbo].[SU_NAM_Subject_Name_Annex] a
        ON
            a.SU_NAM_ID = p.SU_NAM_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_NAM_SU_ID int not null,
        Metadata_SU_NAM int not null,
        SU_NAM_PositedAt datetime2 not null,
        SU_NAM_Reliability decimal(5,2) not null,
        SU_NAM_Subject_Name nvarchar(42) not null,
        SU_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_NAM_SU_ID,
        Metadata_SU_NAM,
        SU_NAM_PositedAt,
        SU_NAM_Reliability,
        SU_NAM_Subject_Name,
        SU_NAM_StatementType
    )
    SELECT
        SU_NAM_SU_ID,
        Metadata_SU_NAM,
        SU_NAM_PositedAt,
        SU_NAM_Reliability,
        SU_NAM_Subject_Name,
        SU_NAM_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_NAM_Reliability as previous_SU_NAM_Reliability,
            fol.SU_NAM_Reliability as following_SU_NAM_Reliability
        FROM
            @SU_NAM_Subject_Name a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_NAM_Reliability
            FROM
                @SU_NAM_Subject_Name p
            WHERE
                p.SU_NAM_SU_ID = a.SU_NAM_SU_ID
            AND
                p.SU_NAM_PositedAt < a.SU_NAM_PositedAt
            ORDER BY
                p.SU_NAM_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_NAM_Reliability
            FROM
                @SU_NAM_Subject_Name p
            WHERE
                p.SU_NAM_SU_ID = a.SU_NAM_SU_ID
            AND
                p.SU_NAM_PositedAt > a.SU_NAM_PositedAt
            ORDER BY
                p.SU_NAM_PositedAt ASC
        ) fol
        WHERE
            (a.SU_NAM_Reliability = 0 AND isnull(pre.SU_NAM_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_NAM_Reliability = 1 AND fol.SU_NAM_Reliability = 0)
    ) i
    WHERE
        i.SU_NAM_StatementType <> 'X'
    AND (
            (i.SU_NAM_Reliability = 0 AND i.previous_SU_NAM_Reliability = 1)
        OR
            (i.SU_NAM_Reliability = 1 AND i.following_SU_NAM_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @SU_NAM_Subject_Name SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_NAM_Subject_Name_Posit] (
        SU_NAM_SU_ID,
        SU_NAM_Subject_Name
    )
    SELECT
        v.SU_NAM_SU_ID,
        v.SU_NAM_Subject_Name
    FROM
        @SU_NAM_Subject_Name v
    WHERE
        v.SU_NAM_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_NAM_Subject_Name w
        WHERE
            w.SU_NAM_StatementType = 'P'
        AND
            w.SU_NAM_SU_ID = v.SU_NAM_SU_ID
        AND
            w.SU_NAM_Subject_Name = v.SU_NAM_Subject_Name
        AND
            w.SU_NAM_PositedAt < v.SU_NAM_PositedAt
    );
    INSERT INTO [dbo].[SU_NAM_Subject_Name_Annex] (
        Metadata_SU_NAM,
        SU_NAM_ID,
        SU_NAM_PositedAt,
        SU_NAM_Reliability
    )
    SELECT
        v.Metadata_SU_NAM,
        p.SU_NAM_ID,
        v.SU_NAM_PositedAt,
        v.SU_NAM_Reliability
    FROM
        @SU_NAM_Subject_Name v
    JOIN
        [dbo].[SU_NAM_Subject_Name_Posit] p
    ON
        p.SU_NAM_SU_ID = v.SU_NAM_SU_ID
    AND
        p.SU_NAM_Subject_Name = v.SU_NAM_Subject_Name
    WHERE
        SU_NAM_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_NAM_Subject_Name_Annex] (
        Metadata_SU_NAM,
        SU_NAM_ID,
        SU_NAM_PositedAt,
        SU_NAM_Reliability
    )
    SELECT
        v.Metadata_SU_NAM,
        e.SU_NAM_ID,
        v.SU_NAM_PositedAt,
        0
    FROM
        @SU_NAM_Subject_Name v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_NAM_ID,
            p.SU_NAM_Subject_Name
        FROM
            [dbo].[SU_NAM_Subject_Name_Posit] p
        JOIN
            [dbo].[SU_NAM_Subject_Name_Annex] a
        ON
            a.SU_NAM_ID = p.SU_NAM_ID
        AND
            a.SU_NAM_PositedAt = (
                SELECT
                    max(s.SU_NAM_PositedAt)
                FROM
                    [dbo].[SU_NAM_Subject_Name_Annex] s
                WHERE
                    s.SU_NAM_ID = p.SU_NAM_ID
                AND
                    s.SU_NAM_PositedAt < v.SU_NAM_PositedAt
            )
        WHERE
            p.SU_NAM_SU_ID = v.SU_NAM_SU_ID
        AND
            a.SU_NAM_Reliability = 1
        ORDER BY
            a.SU_NAM_PositedAt DESC
    ) e
    WHERE
        v.SU_NAM_StatementType in ('P', 'A')
    AND
        v.SU_NAM_Reliability = 1
    AND
        e.SU_NAM_Subject_Name <> v.SU_NAM_Subject_Name
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_NAM_Subject_Name_Annex] x
        WHERE
            x.SU_NAM_ID = e.SU_NAM_ID
        AND
            x.SU_NAM_PositedAt = v.SU_NAM_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_COD_Subject_Code instead of INSERT trigger on SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_COD_Subject_Code', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_COD_Subject_Code];
GO
CREATE TRIGGER [dbo].[it_SU_COD_Subject_Code] ON [dbo].[SU_COD_Subject_Code]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_COD_Subject_Code TABLE (
        SU_COD_SU_ID int not null,
        Metadata_SU_COD int not null,
        SU_COD_PositedAt datetime2 not null,
        SU_COD_Reliability decimal(5,2) not null,
        SU_COD_Subject_Code nvarchar(42) not null,
        SU_COD_StatementType char(1) not null,
        primary key (
            SU_COD_SU_ID asc,
            SU_COD_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_COD_SU_ID,
            i.SU_COD_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_COD_Subject_Code_Posit] p
            JOIN
                [dbo].[SU_COD_Subject_Code_Annex] a
            ON
                a.SU_COD_ID = p.SU_COD_ID
            WHERE
                p.SU_COD_SU_ID = i.SU_COD_SU_ID
            AND
                p.SU_COD_Subject_Code = i.SU_COD_Subject_Code
            AND
                a.SU_COD_PositedAt = i.SU_COD_PositedAt
            AND
                a.SU_COD_Reliability <> i.SU_COD_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_COD_Subject_Code for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_COD_Subject_Code
    SELECT
        i.SU_COD_SU_ID,
        i.Metadata_SU_COD,
        i.SU_COD_PositedAt,
        i.SU_COD_Reliability,
        i.SU_COD_Subject_Code,
        CASE
            WHEN p.SU_COD_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_COD_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_COD_Subject_Code_Posit] p
    ON
        p.SU_COD_SU_ID = i.SU_COD_SU_ID
    AND
        p.SU_COD_Subject_Code = i.SU_COD_Subject_Code
    LEFT JOIN
        [dbo].[SU_COD_Subject_Code_Annex] a
    ON
        a.SU_COD_ID = p.SU_COD_ID
    AND
        a.SU_COD_PositedAt = i.SU_COD_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_COD_ID is null OR a.SU_COD_ID is null);
    INSERT INTO @SU_COD_Subject_Code (
        SU_COD_SU_ID,
        Metadata_SU_COD,
        SU_COD_PositedAt,
        SU_COD_Reliability,
        SU_COD_Subject_Code,
        SU_COD_StatementType
    )
    SELECT
        x.SU_COD_SU_ID,
        x.Metadata_SU_COD,
        x.SU_COD_PositedAt,
        x.SU_COD_Reliability,
        x.SU_COD_Subject_Code,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_COD_SU_ID,
            a.Metadata_SU_COD,
            a.SU_COD_PositedAt,
            a.SU_COD_Reliability,
            p.SU_COD_Subject_Code,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_COD_SU_ID,
                    a.SU_COD_PositedAt
                ORDER BY
                    a.SU_COD_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_COD_SU_ID FROM @SU_COD_Subject_Code) i
        JOIN
            [dbo].[SU_COD_Subject_Code_Posit] p
        ON
            p.SU_COD_SU_ID = i.SU_COD_SU_ID
        JOIN
            [dbo].[SU_COD_Subject_Code_Annex] a
        ON
            a.SU_COD_ID = p.SU_COD_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_COD_SU_ID int not null,
        Metadata_SU_COD int not null,
        SU_COD_PositedAt datetime2 not null,
        SU_COD_Reliability decimal(5,2) not null,
        SU_COD_Subject_Code nvarchar(42) not null,
        SU_COD_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_COD_SU_ID,
        Metadata_SU_COD,
        SU_COD_PositedAt,
        SU_COD_Reliability,
        SU_COD_Subject_Code,
        SU_COD_StatementType
    )
    SELECT
        SU_COD_SU_ID,
        Metadata_SU_COD,
        SU_COD_PositedAt,
        SU_COD_Reliability,
        SU_COD_Subject_Code,
        SU_COD_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_COD_Reliability as previous_SU_COD_Reliability,
            fol.SU_COD_Reliability as following_SU_COD_Reliability
        FROM
            @SU_COD_Subject_Code a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_COD_Reliability
            FROM
                @SU_COD_Subject_Code p
            WHERE
                p.SU_COD_SU_ID = a.SU_COD_SU_ID
            AND
                p.SU_COD_PositedAt < a.SU_COD_PositedAt
            ORDER BY
                p.SU_COD_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_COD_Reliability
            FROM
                @SU_COD_Subject_Code p
            WHERE
                p.SU_COD_SU_ID = a.SU_COD_SU_ID
            AND
                p.SU_COD_PositedAt > a.SU_COD_PositedAt
            ORDER BY
                p.SU_COD_PositedAt ASC
        ) fol
        WHERE
            (a.SU_COD_Reliability = 0 AND isnull(pre.SU_COD_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_COD_Reliability = 1 AND fol.SU_COD_Reliability = 0)
    ) i
    WHERE
        i.SU_COD_StatementType <> 'X'
    AND (
            (i.SU_COD_Reliability = 0 AND i.previous_SU_COD_Reliability = 1)
        OR
            (i.SU_COD_Reliability = 1 AND i.following_SU_COD_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @SU_COD_Subject_Code SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_COD_Subject_Code_Posit] (
        SU_COD_SU_ID,
        SU_COD_Subject_Code
    )
    SELECT
        v.SU_COD_SU_ID,
        v.SU_COD_Subject_Code
    FROM
        @SU_COD_Subject_Code v
    WHERE
        v.SU_COD_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_COD_Subject_Code w
        WHERE
            w.SU_COD_StatementType = 'P'
        AND
            w.SU_COD_SU_ID = v.SU_COD_SU_ID
        AND
            w.SU_COD_Subject_Code = v.SU_COD_Subject_Code
        AND
            w.SU_COD_PositedAt < v.SU_COD_PositedAt
    );
    INSERT INTO [dbo].[SU_COD_Subject_Code_Annex] (
        Metadata_SU_COD,
        SU_COD_ID,
        SU_COD_PositedAt,
        SU_COD_Reliability
    )
    SELECT
        v.Metadata_SU_COD,
        p.SU_COD_ID,
        v.SU_COD_PositedAt,
        v.SU_COD_Reliability
    FROM
        @SU_COD_Subject_Code v
    JOIN
        [dbo].[SU_COD_Subject_Code_Posit] p
    ON
        p.SU_COD_SU_ID = v.SU_COD_SU_ID
    AND
        p.SU_COD_Subject_Code = v.SU_COD_Subject_Code
    WHERE
        SU_COD_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_COD_Subject_Code_Annex] (
        Metadata_SU_COD,
        SU_COD_ID,
        SU_COD_PositedAt,
        SU_COD_Reliability
    )
    SELECT
        v.Metadata_SU_COD,
        e.SU_COD_ID,
        v.SU_COD_PositedAt,
        0
    FROM
        @SU_COD_Subject_Code v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_COD_ID,
            p.SU_COD_Subject_Code
        FROM
            [dbo].[SU_COD_Subject_Code_Posit] p
        JOIN
            [dbo].[SU_COD_Subject_Code_Annex] a
        ON
            a.SU_COD_ID = p.SU_COD_ID
        AND
            a.SU_COD_PositedAt = (
                SELECT
                    max(s.SU_COD_PositedAt)
                FROM
                    [dbo].[SU_COD_Subject_Code_Annex] s
                WHERE
                    s.SU_COD_ID = p.SU_COD_ID
                AND
                    s.SU_COD_PositedAt < v.SU_COD_PositedAt
            )
        WHERE
            p.SU_COD_SU_ID = v.SU_COD_SU_ID
        AND
            a.SU_COD_Reliability = 1
        ORDER BY
            a.SU_COD_PositedAt DESC
    ) e
    WHERE
        v.SU_COD_StatementType in ('P', 'A')
    AND
        v.SU_COD_Reliability = 1
    AND
        e.SU_COD_Subject_Code <> v.SU_COD_Subject_Code
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_COD_Subject_Code_Annex] x
        WHERE
            x.SU_COD_ID = e.SU_COD_ID
        AND
            x.SU_COD_PositedAt = v.SU_COD_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_GRD_Subject_Grade instead of INSERT trigger on SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_GRD_Subject_Grade', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_GRD_Subject_Grade];
GO
CREATE TRIGGER [dbo].[it_SU_GRD_Subject_Grade] ON [dbo].[SU_GRD_Subject_Grade]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_GRD_Subject_Grade TABLE (
        SU_GRD_SU_ID int not null,
        Metadata_SU_GRD int not null,
        SU_GRD_PositedAt datetime2 not null,
        SU_GRD_Reliability decimal(5,2) not null,
        SU_GRD_GRD_ID tinyint not null,
        SU_GRD_StatementType char(1) not null,
        primary key (
            SU_GRD_SU_ID asc,
            SU_GRD_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_GRD_SU_ID,
            i.SU_GRD_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_GRD_Subject_Grade_Posit] p
            JOIN
                [dbo].[SU_GRD_Subject_Grade_Annex] a
            ON
                a.SU_GRD_ID = p.SU_GRD_ID
            WHERE
                p.SU_GRD_SU_ID = i.SU_GRD_SU_ID
            AND
                p.SU_GRD_GRD_ID = i.SU_GRD_GRD_ID
            AND
                a.SU_GRD_PositedAt = i.SU_GRD_PositedAt
            AND
                a.SU_GRD_Reliability <> i.SU_GRD_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_GRD_Subject_Grade for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_GRD_Subject_Grade
    SELECT
        i.SU_GRD_SU_ID,
        i.Metadata_SU_GRD,
        i.SU_GRD_PositedAt,
        i.SU_GRD_Reliability,
        i.SU_GRD_GRD_ID,
        CASE
            WHEN p.SU_GRD_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_GRD_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_GRD_Subject_Grade_Posit] p
    ON
        p.SU_GRD_SU_ID = i.SU_GRD_SU_ID
    AND
        p.SU_GRD_GRD_ID = i.SU_GRD_GRD_ID
    LEFT JOIN
        [dbo].[SU_GRD_Subject_Grade_Annex] a
    ON
        a.SU_GRD_ID = p.SU_GRD_ID
    AND
        a.SU_GRD_PositedAt = i.SU_GRD_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_GRD_ID is null OR a.SU_GRD_ID is null);
    INSERT INTO @SU_GRD_Subject_Grade (
        SU_GRD_SU_ID,
        Metadata_SU_GRD,
        SU_GRD_PositedAt,
        SU_GRD_Reliability,
        SU_GRD_GRD_ID,
        SU_GRD_StatementType
    )
    SELECT
        x.SU_GRD_SU_ID,
        x.Metadata_SU_GRD,
        x.SU_GRD_PositedAt,
        x.SU_GRD_Reliability,
        x.SU_GRD_GRD_ID,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_GRD_SU_ID,
            a.Metadata_SU_GRD,
            a.SU_GRD_PositedAt,
            a.SU_GRD_Reliability,
            p.SU_GRD_GRD_ID,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_GRD_SU_ID,
                    a.SU_GRD_PositedAt
                ORDER BY
                    a.SU_GRD_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_GRD_SU_ID FROM @SU_GRD_Subject_Grade) i
        JOIN
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        ON
            p.SU_GRD_SU_ID = i.SU_GRD_SU_ID
        JOIN
            [dbo].[SU_GRD_Subject_Grade_Annex] a
        ON
            a.SU_GRD_ID = p.SU_GRD_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_GRD_SU_ID int not null,
        Metadata_SU_GRD int not null,
        SU_GRD_PositedAt datetime2 not null,
        SU_GRD_Reliability decimal(5,2) not null,
        SU_GRD_GRD_ID tinyint not null,
        SU_GRD_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_GRD_SU_ID,
        Metadata_SU_GRD,
        SU_GRD_PositedAt,
        SU_GRD_Reliability,
        SU_GRD_GRD_ID,
        SU_GRD_StatementType
    )
    SELECT
        SU_GRD_SU_ID,
        Metadata_SU_GRD,
        SU_GRD_PositedAt,
        SU_GRD_Reliability,
        SU_GRD_GRD_ID,
        SU_GRD_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_GRD_Reliability as previous_SU_GRD_Reliability,
            fol.SU_GRD_Reliability as following_SU_GRD_Reliability
        FROM
            @SU_GRD_Subject_Grade a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_GRD_Reliability
            FROM
                @SU_GRD_Subject_Grade p
            WHERE
                p.SU_GRD_SU_ID = a.SU_GRD_SU_ID
            AND
                p.SU_GRD_PositedAt < a.SU_GRD_PositedAt
            ORDER BY
                p.SU_GRD_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_GRD_Reliability
            FROM
                @SU_GRD_Subject_Grade p
            WHERE
                p.SU_GRD_SU_ID = a.SU_GRD_SU_ID
            AND
                p.SU_GRD_PositedAt > a.SU_GRD_PositedAt
            ORDER BY
                p.SU_GRD_PositedAt ASC
        ) fol
        WHERE
            (a.SU_GRD_Reliability = 0 AND isnull(pre.SU_GRD_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_GRD_Reliability = 1 AND fol.SU_GRD_Reliability = 0)
    ) i
    WHERE
        i.SU_GRD_StatementType <> 'X'
    AND (
            (i.SU_GRD_Reliability = 0 AND i.previous_SU_GRD_Reliability = 1)
        OR
            (i.SU_GRD_Reliability = 1 AND i.following_SU_GRD_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @SU_GRD_Subject_Grade SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_GRD_Subject_Grade_Posit] (
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID
    )
    SELECT
        v.SU_GRD_SU_ID,
        v.SU_GRD_GRD_ID
    FROM
        @SU_GRD_Subject_Grade v
    WHERE
        v.SU_GRD_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_GRD_Subject_Grade w
        WHERE
            w.SU_GRD_StatementType = 'P'
        AND
            w.SU_GRD_SU_ID = v.SU_GRD_SU_ID
        AND
            w.SU_GRD_GRD_ID = v.SU_GRD_GRD_ID
        AND
            w.SU_GRD_PositedAt < v.SU_GRD_PositedAt
    );
    INSERT INTO [dbo].[SU_GRD_Subject_Grade_Annex] (
        Metadata_SU_GRD,
        SU_GRD_ID,
        SU_GRD_PositedAt,
        SU_GRD_Reliability
    )
    SELECT
        v.Metadata_SU_GRD,
        p.SU_GRD_ID,
        v.SU_GRD_PositedAt,
        v.SU_GRD_Reliability
    FROM
        @SU_GRD_Subject_Grade v
    JOIN
        [dbo].[SU_GRD_Subject_Grade_Posit] p
    ON
        p.SU_GRD_SU_ID = v.SU_GRD_SU_ID
    AND
        p.SU_GRD_GRD_ID = v.SU_GRD_GRD_ID
    WHERE
        SU_GRD_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_GRD_Subject_Grade_Annex] (
        Metadata_SU_GRD,
        SU_GRD_ID,
        SU_GRD_PositedAt,
        SU_GRD_Reliability
    )
    SELECT
        v.Metadata_SU_GRD,
        e.SU_GRD_ID,
        v.SU_GRD_PositedAt,
        0
    FROM
        @SU_GRD_Subject_Grade v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_GRD_ID,
            p.SU_GRD_GRD_ID
        FROM
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        JOIN
            [dbo].[SU_GRD_Subject_Grade_Annex] a
        ON
            a.SU_GRD_ID = p.SU_GRD_ID
        AND
            a.SU_GRD_PositedAt = (
                SELECT
                    max(s.SU_GRD_PositedAt)
                FROM
                    [dbo].[SU_GRD_Subject_Grade_Annex] s
                WHERE
                    s.SU_GRD_ID = p.SU_GRD_ID
                AND
                    s.SU_GRD_PositedAt < v.SU_GRD_PositedAt
            )
        WHERE
            p.SU_GRD_SU_ID = v.SU_GRD_SU_ID
        AND
            a.SU_GRD_Reliability = 1
        ORDER BY
            a.SU_GRD_PositedAt DESC
    ) e
    WHERE
        v.SU_GRD_StatementType in ('P', 'A')
    AND
        v.SU_GRD_Reliability = 1
    AND
        e.SU_GRD_GRD_ID <> v.SU_GRD_GRD_ID
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_GRD_Subject_Grade_Annex] x
        WHERE
            x.SU_GRD_ID = e.SU_GRD_ID
        AND
            x.SU_GRD_PositedAt = v.SU_GRD_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NOT_Subject_Note instead of INSERT trigger on SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_NOT_Subject_Note', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_NOT_Subject_Note];
GO
CREATE TRIGGER [dbo].[it_SU_NOT_Subject_Note] ON [dbo].[SU_NOT_Subject_Note]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_NOT_Subject_Note TABLE (
        SU_NOT_SU_ID int not null,
        Metadata_SU_NOT int not null,
        SU_NOT_PositedAt datetime2 not null,
        SU_NOT_Reliability decimal(5,2) not null,
        SU_NOT_Subject_Note nvarchar(max) not null,
        SU_NOT_Checksum varbinary(16) not null,
        SU_NOT_StatementType char(1) not null,
        primary key (
            SU_NOT_SU_ID asc,
            SU_NOT_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_NOT_SU_ID,
            i.SU_NOT_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_NOT_Subject_Note_Posit] p
            JOIN
                [dbo].[SU_NOT_Subject_Note_Annex] a
            ON
                a.SU_NOT_ID = p.SU_NOT_ID
            WHERE
                p.SU_NOT_SU_ID = i.SU_NOT_SU_ID
            AND
                p.SU_NOT_Checksum = dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
            AND
                a.SU_NOT_PositedAt = i.SU_NOT_PositedAt
            AND
                a.SU_NOT_Reliability <> i.SU_NOT_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_NOT_Subject_Note for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_NOT_Subject_Note
    SELECT
        i.SU_NOT_SU_ID,
        i.Metadata_SU_NOT,
        i.SU_NOT_PositedAt,
        i.SU_NOT_Reliability,
        i.SU_NOT_Subject_Note,
        dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max))),
        CASE
            WHEN p.SU_NOT_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_NOT_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_NOT_Subject_Note_Posit] p
    ON
        p.SU_NOT_SU_ID = i.SU_NOT_SU_ID
    AND
        p.SU_NOT_Checksum = dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
    LEFT JOIN
        [dbo].[SU_NOT_Subject_Note_Annex] a
    ON
        a.SU_NOT_ID = p.SU_NOT_ID
    AND
        a.SU_NOT_PositedAt = i.SU_NOT_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_NOT_ID is null OR a.SU_NOT_ID is null);
    INSERT INTO @SU_NOT_Subject_Note (
        SU_NOT_SU_ID,
        Metadata_SU_NOT,
        SU_NOT_PositedAt,
        SU_NOT_Reliability,
        SU_NOT_Subject_Note,
        SU_NOT_Checksum,
        SU_NOT_StatementType
    )
    SELECT
        x.SU_NOT_SU_ID,
        x.Metadata_SU_NOT,
        x.SU_NOT_PositedAt,
        x.SU_NOT_Reliability,
        x.SU_NOT_Subject_Note,
        x.SU_NOT_Checksum,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_NOT_SU_ID,
            a.Metadata_SU_NOT,
            a.SU_NOT_PositedAt,
            a.SU_NOT_Reliability,
            p.SU_NOT_Subject_Note,
            p.SU_NOT_Checksum,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_NOT_SU_ID,
                    a.SU_NOT_PositedAt
                ORDER BY
                    a.SU_NOT_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_NOT_SU_ID FROM @SU_NOT_Subject_Note) i
        JOIN
            [dbo].[SU_NOT_Subject_Note_Posit] p
        ON
            p.SU_NOT_SU_ID = i.SU_NOT_SU_ID
        JOIN
            [dbo].[SU_NOT_Subject_Note_Annex] a
        ON
            a.SU_NOT_ID = p.SU_NOT_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_NOT_SU_ID int not null,
        Metadata_SU_NOT int not null,
        SU_NOT_PositedAt datetime2 not null,
        SU_NOT_Reliability decimal(5,2) not null,
        SU_NOT_Subject_Note nvarchar(max) not null,
        SU_NOT_Checksum varbinary(16) not null,
        SU_NOT_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_NOT_SU_ID,
        Metadata_SU_NOT,
        SU_NOT_PositedAt,
        SU_NOT_Reliability,
        SU_NOT_Subject_Note,
        SU_NOT_Checksum,
        SU_NOT_StatementType
    )
    SELECT
        SU_NOT_SU_ID,
        Metadata_SU_NOT,
        SU_NOT_PositedAt,
        SU_NOT_Reliability,
        SU_NOT_Subject_Note,
        SU_NOT_Checksum,
        SU_NOT_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_NOT_Reliability as previous_SU_NOT_Reliability,
            fol.SU_NOT_Reliability as following_SU_NOT_Reliability
        FROM
            @SU_NOT_Subject_Note a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_NOT_Reliability
            FROM
                @SU_NOT_Subject_Note p
            WHERE
                p.SU_NOT_SU_ID = a.SU_NOT_SU_ID
            AND
                p.SU_NOT_PositedAt < a.SU_NOT_PositedAt
            ORDER BY
                p.SU_NOT_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_NOT_Reliability
            FROM
                @SU_NOT_Subject_Note p
            WHERE
                p.SU_NOT_SU_ID = a.SU_NOT_SU_ID
            AND
                p.SU_NOT_PositedAt > a.SU_NOT_PositedAt
            ORDER BY
                p.SU_NOT_PositedAt ASC
        ) fol
        WHERE
            (a.SU_NOT_Reliability = 0 AND isnull(pre.SU_NOT_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_NOT_Reliability = 1 AND fol.SU_NOT_Reliability = 0)
    ) i
    WHERE
        i.SU_NOT_StatementType <> 'X'
    AND (
            (i.SU_NOT_Reliability = 0 AND i.previous_SU_NOT_Reliability = 1)
        OR
            (i.SU_NOT_Reliability = 1 AND i.following_SU_NOT_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @SU_NOT_Subject_Note SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_NOT_Subject_Note_Posit] (
        SU_NOT_SU_ID,
        SU_NOT_Subject_Note
    )
    SELECT
        v.SU_NOT_SU_ID,
        v.SU_NOT_Subject_Note
    FROM
        @SU_NOT_Subject_Note v
    WHERE
        v.SU_NOT_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_NOT_Subject_Note w
        WHERE
            w.SU_NOT_StatementType = 'P'
        AND
            w.SU_NOT_SU_ID = v.SU_NOT_SU_ID
        AND
            w.SU_NOT_Checksum = v.SU_NOT_Checksum
        AND
            w.SU_NOT_PositedAt < v.SU_NOT_PositedAt
    );
    INSERT INTO [dbo].[SU_NOT_Subject_Note_Annex] (
        Metadata_SU_NOT,
        SU_NOT_ID,
        SU_NOT_PositedAt,
        SU_NOT_Reliability
    )
    SELECT
        v.Metadata_SU_NOT,
        p.SU_NOT_ID,
        v.SU_NOT_PositedAt,
        v.SU_NOT_Reliability
    FROM
        @SU_NOT_Subject_Note v
    JOIN
        [dbo].[SU_NOT_Subject_Note_Posit] p
    ON
        p.SU_NOT_SU_ID = v.SU_NOT_SU_ID
    AND
        p.SU_NOT_Checksum = v.SU_NOT_Checksum
    WHERE
        SU_NOT_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_NOT_Subject_Note_Annex] (
        Metadata_SU_NOT,
        SU_NOT_ID,
        SU_NOT_PositedAt,
        SU_NOT_Reliability
    )
    SELECT
        v.Metadata_SU_NOT,
        e.SU_NOT_ID,
        v.SU_NOT_PositedAt,
        0
    FROM
        @SU_NOT_Subject_Note v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_NOT_ID,
            p.SU_NOT_Checksum
        FROM
            [dbo].[SU_NOT_Subject_Note_Posit] p
        JOIN
            [dbo].[SU_NOT_Subject_Note_Annex] a
        ON
            a.SU_NOT_ID = p.SU_NOT_ID
        AND
            a.SU_NOT_PositedAt = (
                SELECT
                    max(s.SU_NOT_PositedAt)
                FROM
                    [dbo].[SU_NOT_Subject_Note_Annex] s
                WHERE
                    s.SU_NOT_ID = p.SU_NOT_ID
                AND
                    s.SU_NOT_PositedAt < v.SU_NOT_PositedAt
            )
        WHERE
            p.SU_NOT_SU_ID = v.SU_NOT_SU_ID
        AND
            a.SU_NOT_Reliability = 1
        ORDER BY
            a.SU_NOT_PositedAt DESC
    ) e
    WHERE
        v.SU_NOT_StatementType in ('P', 'A')
    AND
        v.SU_NOT_Reliability = 1
    AND
        e.SU_NOT_Checksum <> v.SU_NOT_Checksum
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_NOT_Subject_Note_Annex] x
        WHERE
            x.SU_NOT_ID = e.SU_NOT_ID
        AND
            x.SU_NOT_PositedAt = v.SU_NOT_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TTL_Subject_Title instead of INSERT trigger on SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TTL_Subject_Title', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TTL_Subject_Title];
GO
CREATE TRIGGER [dbo].[it_SU_TTL_Subject_Title] ON [dbo].[SU_TTL_Subject_Title]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_TTL_Subject_Title TABLE (
        SU_TTL_SU_ID int not null,
        Metadata_SU_TTL int not null,
        SU_TTL_ChangedAt datetime2 not null,
        SU_TTL_PositedAt datetime2 not null,
        SU_TTL_Reliability decimal(5,2) not null,
        SU_TTL_Subject_Title nvarchar(42) not null,
        SU_TTL_StatementType char(1) not null,
        primary key (
            SU_TTL_SU_ID asc,
            SU_TTL_ChangedAt desc,
            SU_TTL_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TTL_SU_ID,
            i.SU_TTL_ChangedAt,
            i.SU_TTL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TTL_Subject_Title_Posit] p
            JOIN
                [dbo].[SU_TTL_Subject_Title_Annex] a
            ON
                a.SU_TTL_ID = p.SU_TTL_ID
            WHERE
                p.SU_TTL_SU_ID = i.SU_TTL_SU_ID
            AND
                p.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
            AND
                p.SU_TTL_Subject_Title = i.SU_TTL_Subject_Title
            AND
                a.SU_TTL_PositedAt = i.SU_TTL_PositedAt
            AND
                a.SU_TTL_Reliability <> i.SU_TTL_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TTL_Subject_Title for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_TTL_Subject_Title
    SELECT
        i.SU_TTL_SU_ID,
        i.Metadata_SU_TTL,
        i.SU_TTL_ChangedAt,
        i.SU_TTL_PositedAt,
        i.SU_TTL_Reliability,
        i.SU_TTL_Subject_Title,
        CASE
            WHEN p.SU_TTL_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_TTL_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_TTL_Subject_Title_Posit] p
    ON
        p.SU_TTL_SU_ID = i.SU_TTL_SU_ID
    AND
        p.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
    AND
        p.SU_TTL_Subject_Title = i.SU_TTL_Subject_Title
    LEFT JOIN
        [dbo].[SU_TTL_Subject_Title_Annex] a
    ON
        a.SU_TTL_ID = p.SU_TTL_ID
    AND
        a.SU_TTL_PositedAt = i.SU_TTL_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_TTL_ID is null OR a.SU_TTL_ID is null);
    INSERT INTO @SU_TTL_Subject_Title (
        SU_TTL_SU_ID,
        Metadata_SU_TTL,
        SU_TTL_ChangedAt,
        SU_TTL_PositedAt,
        SU_TTL_Reliability,
        SU_TTL_Subject_Title,
        SU_TTL_StatementType
    )
    SELECT
        x.SU_TTL_SU_ID,
        x.Metadata_SU_TTL,
        x.SU_TTL_ChangedAt,
        x.SU_TTL_PositedAt,
        x.SU_TTL_Reliability,
        x.SU_TTL_Subject_Title,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_TTL_SU_ID,
            a.Metadata_SU_TTL,
            p.SU_TTL_ChangedAt,
            a.SU_TTL_PositedAt,
            a.SU_TTL_Reliability,
            p.SU_TTL_Subject_Title,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_TTL_SU_ID,
                    p.SU_TTL_ChangedAt,
                    a.SU_TTL_PositedAt
                ORDER BY
                    a.SU_TTL_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_TTL_SU_ID FROM @SU_TTL_Subject_Title) i
        JOIN
            [dbo].[SU_TTL_Subject_Title_Posit] p
        ON
            p.SU_TTL_SU_ID = i.SU_TTL_SU_ID
        JOIN
            [dbo].[SU_TTL_Subject_Title_Annex] a
        ON
            a.SU_TTL_ID = p.SU_TTL_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_TTL_SU_ID int not null,
        Metadata_SU_TTL int not null,
        SU_TTL_ChangedAt datetime2 not null,
        SU_TTL_PositedAt datetime2 not null,
        SU_TTL_Reliability decimal(5,2) not null,
        SU_TTL_Subject_Title nvarchar(42) not null,
        SU_TTL_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_TTL_SU_ID,
        Metadata_SU_TTL,
        SU_TTL_ChangedAt,
        SU_TTL_PositedAt,
        SU_TTL_Reliability,
        SU_TTL_Subject_Title,
        SU_TTL_StatementType
    )
    SELECT
        SU_TTL_SU_ID,
        Metadata_SU_TTL,
        SU_TTL_ChangedAt,
        SU_TTL_PositedAt,
        SU_TTL_Reliability,
        SU_TTL_Subject_Title,
        SU_TTL_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_TTL_Reliability as previous_SU_TTL_Reliability,
            fol.SU_TTL_Reliability as following_SU_TTL_Reliability
        FROM
            @SU_TTL_Subject_Title a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_TTL_Reliability
            FROM
                @SU_TTL_Subject_Title p
            WHERE
                p.SU_TTL_SU_ID = a.SU_TTL_SU_ID
            AND
                p.SU_TTL_ChangedAt = a.SU_TTL_ChangedAt
            AND
                p.SU_TTL_PositedAt < a.SU_TTL_PositedAt
            ORDER BY
                p.SU_TTL_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_TTL_Reliability
            FROM
                @SU_TTL_Subject_Title p
            WHERE
                p.SU_TTL_SU_ID = a.SU_TTL_SU_ID
            AND
                p.SU_TTL_ChangedAt = a.SU_TTL_ChangedAt
            AND
                p.SU_TTL_PositedAt > a.SU_TTL_PositedAt
            ORDER BY
                p.SU_TTL_PositedAt ASC
        ) fol
        WHERE
            (a.SU_TTL_Reliability = 0 AND isnull(pre.SU_TTL_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_TTL_Reliability = 1 AND fol.SU_TTL_Reliability = 0)
    ) i
    WHERE
        i.SU_TTL_StatementType <> 'X'
    AND (
            (i.SU_TTL_Reliability = 0 AND i.previous_SU_TTL_Reliability = 1)
        OR
            (i.SU_TTL_Reliability = 1 AND i.following_SU_TTL_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @SU_TTL_Subject_Title SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_TTL_Subject_Title_Posit] (
        SU_TTL_SU_ID,
        SU_TTL_ChangedAt,
        SU_TTL_Subject_Title
    )
    SELECT
        v.SU_TTL_SU_ID,
        v.SU_TTL_ChangedAt,
        v.SU_TTL_Subject_Title
    FROM
        @SU_TTL_Subject_Title v
    WHERE
        v.SU_TTL_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_TTL_Subject_Title w
        WHERE
            w.SU_TTL_StatementType = 'P'
        AND
            w.SU_TTL_SU_ID = v.SU_TTL_SU_ID
        AND
            w.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
        AND
            w.SU_TTL_Subject_Title = v.SU_TTL_Subject_Title
        AND
            w.SU_TTL_PositedAt < v.SU_TTL_PositedAt
    );
    INSERT INTO [dbo].[SU_TTL_Subject_Title_Annex] (
        Metadata_SU_TTL,
        SU_TTL_ID,
        SU_TTL_PositedAt,
        SU_TTL_Reliability
    )
    SELECT
        v.Metadata_SU_TTL,
        p.SU_TTL_ID,
        v.SU_TTL_PositedAt,
        v.SU_TTL_Reliability
    FROM
        @SU_TTL_Subject_Title v
    JOIN
        [dbo].[SU_TTL_Subject_Title_Posit] p
    ON
        p.SU_TTL_SU_ID = v.SU_TTL_SU_ID
    AND
        p.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
    AND
        p.SU_TTL_Subject_Title = v.SU_TTL_Subject_Title
    WHERE
        SU_TTL_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_TTL_Subject_Title_Annex] (
        Metadata_SU_TTL,
        SU_TTL_ID,
        SU_TTL_PositedAt,
        SU_TTL_Reliability
    )
    SELECT
        v.Metadata_SU_TTL,
        e.SU_TTL_ID,
        v.SU_TTL_PositedAt,
        0
    FROM
        @SU_TTL_Subject_Title v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_TTL_ID,
            p.SU_TTL_Subject_Title
        FROM
            [dbo].[SU_TTL_Subject_Title_Posit] p
        JOIN
            [dbo].[SU_TTL_Subject_Title_Annex] a
        ON
            a.SU_TTL_ID = p.SU_TTL_ID
        AND
            a.SU_TTL_PositedAt = (
                SELECT
                    max(s.SU_TTL_PositedAt)
                FROM
                    [dbo].[SU_TTL_Subject_Title_Annex] s
                WHERE
                    s.SU_TTL_ID = p.SU_TTL_ID
                AND
                    s.SU_TTL_PositedAt < v.SU_TTL_PositedAt
            )
        WHERE
            p.SU_TTL_SU_ID = v.SU_TTL_SU_ID
        AND
            p.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
        AND
            a.SU_TTL_Reliability = 1
        ORDER BY
            a.SU_TTL_PositedAt DESC
    ) e
    WHERE
        v.SU_TTL_StatementType in ('P', 'A')
    AND
        v.SU_TTL_Reliability = 1
    AND
        e.SU_TTL_Subject_Title <> v.SU_TTL_Subject_Title
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_TTL_Subject_Title_Annex] x
        WHERE
            x.SU_TTL_ID = e.SU_TTL_ID
        AND
            x.SU_TTL_PositedAt = v.SU_TTL_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_STA_Subject_State instead of INSERT trigger on SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_STA_Subject_State', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_STA_Subject_State];
GO
CREATE TRIGGER [dbo].[it_SU_STA_Subject_State] ON [dbo].[SU_STA_Subject_State]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_STA_Subject_State TABLE (
        SU_STA_SU_ID int not null,
        Metadata_SU_STA int not null,
        SU_STA_ChangedAt datetime2 not null,
        SU_STA_PositedAt datetime2 not null,
        SU_STA_Reliability decimal(5,2) not null,
        SU_STA_Subject_State nvarchar(42) not null,
        SU_STA_StatementType char(1) not null,
        primary key (
            SU_STA_SU_ID asc,
            SU_STA_ChangedAt desc,
            SU_STA_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_STA_SU_ID,
            i.SU_STA_ChangedAt,
            i.SU_STA_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_STA_Subject_State_Posit] p
            JOIN
                [dbo].[SU_STA_Subject_State_Annex] a
            ON
                a.SU_STA_ID = p.SU_STA_ID
            WHERE
                p.SU_STA_SU_ID = i.SU_STA_SU_ID
            AND
                p.SU_STA_ChangedAt = i.SU_STA_ChangedAt
            AND
                p.SU_STA_Subject_State = i.SU_STA_Subject_State
            AND
                a.SU_STA_PositedAt = i.SU_STA_PositedAt
            AND
                a.SU_STA_Reliability <> i.SU_STA_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_STA_Subject_State for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_STA_Subject_State
    SELECT
        i.SU_STA_SU_ID,
        i.Metadata_SU_STA,
        i.SU_STA_ChangedAt,
        i.SU_STA_PositedAt,
        i.SU_STA_Reliability,
        i.SU_STA_Subject_State,
        CASE
            WHEN p.SU_STA_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_STA_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_STA_Subject_State_Posit] p
    ON
        p.SU_STA_SU_ID = i.SU_STA_SU_ID
    AND
        p.SU_STA_ChangedAt = i.SU_STA_ChangedAt
    AND
        p.SU_STA_Subject_State = i.SU_STA_Subject_State
    LEFT JOIN
        [dbo].[SU_STA_Subject_State_Annex] a
    ON
        a.SU_STA_ID = p.SU_STA_ID
    AND
        a.SU_STA_PositedAt = i.SU_STA_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_STA_ID is null OR a.SU_STA_ID is null);
    INSERT INTO @SU_STA_Subject_State (
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_PositedAt,
        SU_STA_Reliability,
        SU_STA_Subject_State,
        SU_STA_StatementType
    )
    SELECT
        x.SU_STA_SU_ID,
        x.Metadata_SU_STA,
        x.SU_STA_ChangedAt,
        x.SU_STA_PositedAt,
        x.SU_STA_Reliability,
        x.SU_STA_Subject_State,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_STA_SU_ID,
            a.Metadata_SU_STA,
            p.SU_STA_ChangedAt,
            a.SU_STA_PositedAt,
            a.SU_STA_Reliability,
            p.SU_STA_Subject_State,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_STA_SU_ID,
                    p.SU_STA_ChangedAt,
                    a.SU_STA_PositedAt
                ORDER BY
                    a.SU_STA_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_STA_SU_ID FROM @SU_STA_Subject_State) i
        JOIN
            [dbo].[SU_STA_Subject_State_Posit] p
        ON
            p.SU_STA_SU_ID = i.SU_STA_SU_ID
        JOIN
            [dbo].[SU_STA_Subject_State_Annex] a
        ON
            a.SU_STA_ID = p.SU_STA_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_STA_SU_ID int not null,
        Metadata_SU_STA int not null,
        SU_STA_ChangedAt datetime2 not null,
        SU_STA_PositedAt datetime2 not null,
        SU_STA_Reliability decimal(5,2) not null,
        SU_STA_Subject_State nvarchar(42) not null,
        SU_STA_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_PositedAt,
        SU_STA_Reliability,
        SU_STA_Subject_State,
        SU_STA_StatementType
    )
    SELECT
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_PositedAt,
        SU_STA_Reliability,
        SU_STA_Subject_State,
        SU_STA_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_STA_Reliability as previous_SU_STA_Reliability,
            fol.SU_STA_Reliability as following_SU_STA_Reliability
        FROM
            @SU_STA_Subject_State a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_STA_Reliability
            FROM
                @SU_STA_Subject_State p
            WHERE
                p.SU_STA_SU_ID = a.SU_STA_SU_ID
            AND
                p.SU_STA_ChangedAt = a.SU_STA_ChangedAt
            AND
                p.SU_STA_PositedAt < a.SU_STA_PositedAt
            ORDER BY
                p.SU_STA_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_STA_Reliability
            FROM
                @SU_STA_Subject_State p
            WHERE
                p.SU_STA_SU_ID = a.SU_STA_SU_ID
            AND
                p.SU_STA_ChangedAt = a.SU_STA_ChangedAt
            AND
                p.SU_STA_PositedAt > a.SU_STA_PositedAt
            ORDER BY
                p.SU_STA_PositedAt ASC
        ) fol
        WHERE
            (a.SU_STA_Reliability = 0 AND isnull(pre.SU_STA_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_STA_Reliability = 1 AND fol.SU_STA_Reliability = 0)
    ) i
    WHERE
        i.SU_STA_StatementType <> 'X'
    AND (
            (i.SU_STA_Reliability = 0 AND i.previous_SU_STA_Reliability = 1)
        OR
            (i.SU_STA_Reliability = 1 AND i.following_SU_STA_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @SU_STA_Subject_State SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_STA_Subject_State_Posit] (
        SU_STA_SU_ID,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    SELECT
        v.SU_STA_SU_ID,
        v.SU_STA_ChangedAt,
        v.SU_STA_Subject_State
    FROM
        @SU_STA_Subject_State v
    WHERE
        v.SU_STA_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_STA_Subject_State w
        WHERE
            w.SU_STA_StatementType = 'P'
        AND
            w.SU_STA_SU_ID = v.SU_STA_SU_ID
        AND
            w.SU_STA_ChangedAt = v.SU_STA_ChangedAt
        AND
            w.SU_STA_Subject_State = v.SU_STA_Subject_State
        AND
            w.SU_STA_PositedAt < v.SU_STA_PositedAt
    );
    INSERT INTO [dbo].[SU_STA_Subject_State_Annex] (
        Metadata_SU_STA,
        SU_STA_ID,
        SU_STA_PositedAt,
        SU_STA_Reliability
    )
    SELECT
        v.Metadata_SU_STA,
        p.SU_STA_ID,
        v.SU_STA_PositedAt,
        v.SU_STA_Reliability
    FROM
        @SU_STA_Subject_State v
    JOIN
        [dbo].[SU_STA_Subject_State_Posit] p
    ON
        p.SU_STA_SU_ID = v.SU_STA_SU_ID
    AND
        p.SU_STA_ChangedAt = v.SU_STA_ChangedAt
    AND
        p.SU_STA_Subject_State = v.SU_STA_Subject_State
    WHERE
        SU_STA_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_STA_Subject_State_Annex] (
        Metadata_SU_STA,
        SU_STA_ID,
        SU_STA_PositedAt,
        SU_STA_Reliability
    )
    SELECT
        v.Metadata_SU_STA,
        e.SU_STA_ID,
        v.SU_STA_PositedAt,
        0
    FROM
        @SU_STA_Subject_State v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_STA_ID,
            p.SU_STA_Subject_State
        FROM
            [dbo].[SU_STA_Subject_State_Posit] p
        JOIN
            [dbo].[SU_STA_Subject_State_Annex] a
        ON
            a.SU_STA_ID = p.SU_STA_ID
        AND
            a.SU_STA_PositedAt = (
                SELECT
                    max(s.SU_STA_PositedAt)
                FROM
                    [dbo].[SU_STA_Subject_State_Annex] s
                WHERE
                    s.SU_STA_ID = p.SU_STA_ID
                AND
                    s.SU_STA_PositedAt < v.SU_STA_PositedAt
            )
        WHERE
            p.SU_STA_SU_ID = v.SU_STA_SU_ID
        AND
            p.SU_STA_ChangedAt = v.SU_STA_ChangedAt
        AND
            a.SU_STA_Reliability = 1
        ORDER BY
            a.SU_STA_PositedAt DESC
    ) e
    WHERE
        v.SU_STA_StatementType in ('P', 'A')
    AND
        v.SU_STA_Reliability = 1
    AND
        e.SU_STA_Subject_State <> v.SU_STA_Subject_State
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_STA_Subject_State_Annex] x
        WHERE
            x.SU_STA_ID = e.SU_STA_ID
        AND
            x.SU_STA_PositedAt = v.SU_STA_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LBL_Subject_Label instead of INSERT trigger on SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_LBL_Subject_Label', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_LBL_Subject_Label];
GO
CREATE TRIGGER [dbo].[it_SU_LBL_Subject_Label] ON [dbo].[SU_LBL_Subject_Label]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_LBL_Subject_Label TABLE (
        SU_LBL_SU_ID int not null,
        Metadata_SU_LBL int not null,
        SU_LBL_ChangedAt datetime2 not null,
        SU_LBL_PositedAt datetime2 not null,
        SU_LBL_Reliability decimal(5,2) not null,
        SU_LBL_Subject_Label nvarchar(42) not null,
        SU_LBL_StatementType char(1) not null,
        primary key (
            SU_LBL_SU_ID asc,
            SU_LBL_ChangedAt desc,
            SU_LBL_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_LBL_SU_ID,
            i.SU_LBL_ChangedAt,
            i.SU_LBL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_LBL_Subject_Label_Posit] p
            JOIN
                [dbo].[SU_LBL_Subject_Label_Annex] a
            ON
                a.SU_LBL_ID = p.SU_LBL_ID
            WHERE
                p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
            AND
                p.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
            AND
                p.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
            AND
                a.SU_LBL_PositedAt = i.SU_LBL_PositedAt
            AND
                a.SU_LBL_Reliability <> i.SU_LBL_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_LBL_Subject_Label for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_LBL_Subject_Label
    SELECT
        i.SU_LBL_SU_ID,
        i.Metadata_SU_LBL,
        i.SU_LBL_ChangedAt,
        i.SU_LBL_PositedAt,
        i.SU_LBL_Reliability,
        i.SU_LBL_Subject_Label,
        CASE
            WHEN p.SU_LBL_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_LBL_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_LBL_Subject_Label_Posit] p
    ON
        p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
    AND
        p.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
    AND
        p.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
    LEFT JOIN
        [dbo].[SU_LBL_Subject_Label_Annex] a
    ON
        a.SU_LBL_ID = p.SU_LBL_ID
    AND
        a.SU_LBL_PositedAt = i.SU_LBL_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_LBL_ID is null OR a.SU_LBL_ID is null);
    INSERT INTO @SU_LBL_Subject_Label (
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_PositedAt,
        SU_LBL_Reliability,
        SU_LBL_Subject_Label,
        SU_LBL_StatementType
    )
    SELECT
        x.SU_LBL_SU_ID,
        x.Metadata_SU_LBL,
        x.SU_LBL_ChangedAt,
        x.SU_LBL_PositedAt,
        x.SU_LBL_Reliability,
        x.SU_LBL_Subject_Label,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_LBL_SU_ID,
            a.Metadata_SU_LBL,
            p.SU_LBL_ChangedAt,
            a.SU_LBL_PositedAt,
            a.SU_LBL_Reliability,
            p.SU_LBL_Subject_Label,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_LBL_SU_ID,
                    p.SU_LBL_ChangedAt,
                    a.SU_LBL_PositedAt
                ORDER BY
                    a.SU_LBL_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_LBL_SU_ID FROM @SU_LBL_Subject_Label) i
        JOIN
            [dbo].[SU_LBL_Subject_Label_Posit] p
        ON
            p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
        JOIN
            [dbo].[SU_LBL_Subject_Label_Annex] a
        ON
            a.SU_LBL_ID = p.SU_LBL_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_LBL_SU_ID int not null,
        Metadata_SU_LBL int not null,
        SU_LBL_ChangedAt datetime2 not null,
        SU_LBL_PositedAt datetime2 not null,
        SU_LBL_Reliability decimal(5,2) not null,
        SU_LBL_Subject_Label nvarchar(42) not null,
        SU_LBL_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_PositedAt,
        SU_LBL_Reliability,
        SU_LBL_Subject_Label,
        SU_LBL_StatementType
    )
    SELECT
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_PositedAt,
        SU_LBL_Reliability,
        SU_LBL_Subject_Label,
        SU_LBL_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_LBL_Reliability as previous_SU_LBL_Reliability,
            fol.SU_LBL_Reliability as following_SU_LBL_Reliability
        FROM
            @SU_LBL_Subject_Label a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_LBL_Reliability
            FROM
                @SU_LBL_Subject_Label p
            WHERE
                p.SU_LBL_SU_ID = a.SU_LBL_SU_ID
            AND
                p.SU_LBL_ChangedAt = a.SU_LBL_ChangedAt
            AND
                p.SU_LBL_PositedAt < a.SU_LBL_PositedAt
            ORDER BY
                p.SU_LBL_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_LBL_Reliability
            FROM
                @SU_LBL_Subject_Label p
            WHERE
                p.SU_LBL_SU_ID = a.SU_LBL_SU_ID
            AND
                p.SU_LBL_ChangedAt = a.SU_LBL_ChangedAt
            AND
                p.SU_LBL_PositedAt > a.SU_LBL_PositedAt
            ORDER BY
                p.SU_LBL_PositedAt ASC
        ) fol
        WHERE
            (a.SU_LBL_Reliability = 0 AND isnull(pre.SU_LBL_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_LBL_Reliability = 1 AND fol.SU_LBL_Reliability = 0)
    ) i
    WHERE
        i.SU_LBL_StatementType <> 'X'
    AND (
            (i.SU_LBL_Reliability = 0 AND i.previous_SU_LBL_Reliability = 1)
        OR
            (i.SU_LBL_Reliability = 1 AND i.following_SU_LBL_Reliability = 0)
        );
    IF EXISTS (
        SELECT TOP 1
            SU_LBL_StatementType
        FROM
            @SU_LBL_Subject_Label
        WHERE
            SU_LBL_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @restated TABLE (
        SU_LBL_SU_ID int not null,
        Metadata_SU_LBL int not null,
        SU_LBL_ChangedAt datetime2 not null,
        SU_LBL_PositedAt datetime2 not null,
        SU_LBL_Reliability decimal(5,2) not null,
        SU_LBL_Subject_Label nvarchar(42) not null,
        SU_LBL_StatementType char(1) not null
    );
    INSERT INTO @restated (
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_PositedAt,
        SU_LBL_Reliability,
        SU_LBL_Subject_Label,
        SU_LBL_StatementType
    )
    SELECT
        x.SU_LBL_SU_ID,
        x.Metadata_SU_LBL,
        x.SU_LBL_ChangedAt,
        CASE
            WHEN x.previous_SU_LBL_PositedAt < x.SU_LBL_PositedAt THEN x.SU_LBL_PositedAt
            ELSE x.previous_SU_LBL_PositedAt
        END,
        0, -- quench the existing restatements
        x.SU_LBL_Subject_Label,
        CASE
            WHEN x.previous_SU_LBL_PositedAt < x.SU_LBL_PositedAt THEN 'D' -- physical delete
            ELSE 'A' -- logical delete
        END
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_LBL_PositedAt as previous_SU_LBL_PositedAt
        FROM
            @SU_LBL_Subject_Label a
        OUTER APPLY (
            SELECT TOP 1
                *
            FROM
                @SU_LBL_Subject_Label h
            WHERE
                h.SU_LBL_SU_ID = a.SU_LBL_SU_ID
            AND
                h.SU_LBL_ChangedAt < a.SU_LBL_ChangedAt
            ORDER BY
                h.SU_LBL_ChangedAt DESC,
                h.SU_LBL_PositedAt DESC
        ) pre
        WHERE
            a.SU_LBL_Subject_Label = pre.SU_LBL_Subject_Label
    ) x
    WHERE
        x.SU_LBL_StatementType = 'X'; -- quench
    -- add the quenches
    INSERT INTO @SU_LBL_Subject_Label
    SELECT
        *
    FROM (
        DELETE @restated
        OUTPUT deleted.*
        WHERE SU_LBL_StatementType = 'A'
    ) d;
    -- perform any remaining physical deletes
    DELETE a
    FROM
        @restated i
    JOIN
        [dbo].[SU_LBL_Subject_Label_Posit] p
    ON
        p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
    AND
        p.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
    AND
        p.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
    JOIN
        [dbo].[SU_LBL_Subject_Label_Annex] a
    ON
        a.SU_LBL_ID = p.SU_LBL_ID
    AND
        a.SU_LBL_PositedAt = i.SU_LBL_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @SU_LBL_Subject_Label SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_LBL_Subject_Label_Posit] (
        SU_LBL_SU_ID,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    SELECT
        v.SU_LBL_SU_ID,
        v.SU_LBL_ChangedAt,
        v.SU_LBL_Subject_Label
    FROM
        @SU_LBL_Subject_Label v
    WHERE
        v.SU_LBL_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_LBL_Subject_Label w
        WHERE
            w.SU_LBL_StatementType = 'P'
        AND
            w.SU_LBL_SU_ID = v.SU_LBL_SU_ID
        AND
            w.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
        AND
            w.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label
        AND
            w.SU_LBL_PositedAt < v.SU_LBL_PositedAt
    );
    INSERT INTO [dbo].[SU_LBL_Subject_Label_Annex] (
        Metadata_SU_LBL,
        SU_LBL_ID,
        SU_LBL_PositedAt,
        SU_LBL_Reliability
    )
    SELECT
        v.Metadata_SU_LBL,
        p.SU_LBL_ID,
        v.SU_LBL_PositedAt,
        v.SU_LBL_Reliability
    FROM
        @SU_LBL_Subject_Label v
    JOIN
        [dbo].[SU_LBL_Subject_Label_Posit] p
    ON
        p.SU_LBL_SU_ID = v.SU_LBL_SU_ID
    AND
        p.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
    AND
        p.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label
    WHERE
        SU_LBL_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_LBL_Subject_Label_Annex] (
        Metadata_SU_LBL,
        SU_LBL_ID,
        SU_LBL_PositedAt,
        SU_LBL_Reliability
    )
    SELECT
        v.Metadata_SU_LBL,
        e.SU_LBL_ID,
        v.SU_LBL_PositedAt,
        0
    FROM
        @SU_LBL_Subject_Label v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_LBL_ID,
            p.SU_LBL_Subject_Label
        FROM
            [dbo].[SU_LBL_Subject_Label_Posit] p
        JOIN
            [dbo].[SU_LBL_Subject_Label_Annex] a
        ON
            a.SU_LBL_ID = p.SU_LBL_ID
        AND
            a.SU_LBL_PositedAt = (
                SELECT
                    max(s.SU_LBL_PositedAt)
                FROM
                    [dbo].[SU_LBL_Subject_Label_Annex] s
                WHERE
                    s.SU_LBL_ID = p.SU_LBL_ID
                AND
                    s.SU_LBL_PositedAt < v.SU_LBL_PositedAt
            )
        WHERE
            p.SU_LBL_SU_ID = v.SU_LBL_SU_ID
        AND
            p.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
        AND
            a.SU_LBL_Reliability = 1
        ORDER BY
            a.SU_LBL_PositedAt DESC
    ) e
    WHERE
        v.SU_LBL_StatementType in ('P', 'A')
    AND
        v.SU_LBL_Reliability = 1
    AND
        e.SU_LBL_Subject_Label <> v.SU_LBL_Subject_Label
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_LBL_Subject_Label_Annex] x
        WHERE
            x.SU_LBL_ID = e.SU_LBL_ID
        AND
            x.SU_LBL_PositedAt = v.SU_LBL_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TAG_Subject_Tag instead of INSERT trigger on SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TAG_Subject_Tag', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TAG_Subject_Tag];
GO
CREATE TRIGGER [dbo].[it_SU_TAG_Subject_Tag] ON [dbo].[SU_TAG_Subject_Tag]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_TAG_Subject_Tag TABLE (
        SU_TAG_SU_ID int not null,
        Metadata_SU_TAG int not null,
        SU_TAG_ChangedAt datetime2 not null,
        SU_TAG_PositedAt datetime2 not null,
        SU_TAG_Reliability decimal(5,2) not null,
        SU_TAG_Subject_Tag nvarchar(42) not null,
        SU_TAG_StatementType char(1) not null,
        primary key (
            SU_TAG_SU_ID asc,
            SU_TAG_ChangedAt desc,
            SU_TAG_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TAG_SU_ID,
            i.SU_TAG_ChangedAt,
            i.SU_TAG_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TAG_Subject_Tag_Posit] p
            JOIN
                [dbo].[SU_TAG_Subject_Tag_Annex] a
            ON
                a.SU_TAG_ID = p.SU_TAG_ID
            WHERE
                p.SU_TAG_SU_ID = i.SU_TAG_SU_ID
            AND
                p.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
            AND
                p.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
            AND
                a.SU_TAG_PositedAt = i.SU_TAG_PositedAt
            AND
                a.SU_TAG_Reliability <> i.SU_TAG_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TAG_Subject_Tag for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_TAG_Subject_Tag
    SELECT
        i.SU_TAG_SU_ID,
        i.Metadata_SU_TAG,
        i.SU_TAG_ChangedAt,
        i.SU_TAG_PositedAt,
        i.SU_TAG_Reliability,
        i.SU_TAG_Subject_Tag,
        CASE
            WHEN p.SU_TAG_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_TAG_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_TAG_Subject_Tag_Posit] p
    ON
        p.SU_TAG_SU_ID = i.SU_TAG_SU_ID
    AND
        p.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
    AND
        p.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
    LEFT JOIN
        [dbo].[SU_TAG_Subject_Tag_Annex] a
    ON
        a.SU_TAG_ID = p.SU_TAG_ID
    AND
        a.SU_TAG_PositedAt = i.SU_TAG_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_TAG_ID is null OR a.SU_TAG_ID is null);
    INSERT INTO @SU_TAG_Subject_Tag (
        SU_TAG_SU_ID,
        Metadata_SU_TAG,
        SU_TAG_ChangedAt,
        SU_TAG_PositedAt,
        SU_TAG_Reliability,
        SU_TAG_Subject_Tag,
        SU_TAG_StatementType
    )
    SELECT
        x.SU_TAG_SU_ID,
        x.Metadata_SU_TAG,
        x.SU_TAG_ChangedAt,
        x.SU_TAG_PositedAt,
        x.SU_TAG_Reliability,
        x.SU_TAG_Subject_Tag,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_TAG_SU_ID,
            a.Metadata_SU_TAG,
            p.SU_TAG_ChangedAt,
            a.SU_TAG_PositedAt,
            a.SU_TAG_Reliability,
            p.SU_TAG_Subject_Tag,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_TAG_SU_ID,
                    p.SU_TAG_ChangedAt,
                    a.SU_TAG_PositedAt
                ORDER BY
                    a.SU_TAG_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_TAG_SU_ID FROM @SU_TAG_Subject_Tag) i
        JOIN
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        ON
            p.SU_TAG_SU_ID = i.SU_TAG_SU_ID
        JOIN
            [dbo].[SU_TAG_Subject_Tag_Annex] a
        ON
            a.SU_TAG_ID = p.SU_TAG_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_TAG_SU_ID int not null,
        Metadata_SU_TAG int not null,
        SU_TAG_ChangedAt datetime2 not null,
        SU_TAG_PositedAt datetime2 not null,
        SU_TAG_Reliability decimal(5,2) not null,
        SU_TAG_Subject_Tag nvarchar(42) not null,
        SU_TAG_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_TAG_SU_ID,
        Metadata_SU_TAG,
        SU_TAG_ChangedAt,
        SU_TAG_PositedAt,
        SU_TAG_Reliability,
        SU_TAG_Subject_Tag,
        SU_TAG_StatementType
    )
    SELECT
        SU_TAG_SU_ID,
        Metadata_SU_TAG,
        SU_TAG_ChangedAt,
        SU_TAG_PositedAt,
        SU_TAG_Reliability,
        SU_TAG_Subject_Tag,
        SU_TAG_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_TAG_Reliability as previous_SU_TAG_Reliability,
            fol.SU_TAG_Reliability as following_SU_TAG_Reliability
        FROM
            @SU_TAG_Subject_Tag a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_TAG_Reliability
            FROM
                @SU_TAG_Subject_Tag p
            WHERE
                p.SU_TAG_SU_ID = a.SU_TAG_SU_ID
            AND
                p.SU_TAG_ChangedAt = a.SU_TAG_ChangedAt
            AND
                p.SU_TAG_PositedAt < a.SU_TAG_PositedAt
            ORDER BY
                p.SU_TAG_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_TAG_Reliability
            FROM
                @SU_TAG_Subject_Tag p
            WHERE
                p.SU_TAG_SU_ID = a.SU_TAG_SU_ID
            AND
                p.SU_TAG_ChangedAt = a.SU_TAG_ChangedAt
            AND
                p.SU_TAG_PositedAt > a.SU_TAG_PositedAt
            ORDER BY
                p.SU_TAG_PositedAt ASC
        ) fol
        WHERE
            (a.SU_TAG_Reliability = 0 AND isnull(pre.SU_TAG_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_TAG_Reliability = 1 AND fol.SU_TAG_Reliability = 0)
    ) i
    WHERE
        i.SU_TAG_StatementType <> 'X'
    AND (
            (i.SU_TAG_Reliability = 0 AND i.previous_SU_TAG_Reliability = 1)
        OR
            (i.SU_TAG_Reliability = 1 AND i.following_SU_TAG_Reliability = 0)
        );
    IF EXISTS (
        SELECT TOP 1
            SU_TAG_StatementType
        FROM
            @SU_TAG_Subject_Tag
        WHERE
            SU_TAG_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @restated TABLE (
        SU_TAG_SU_ID int not null,
        Metadata_SU_TAG int not null,
        SU_TAG_ChangedAt datetime2 not null,
        SU_TAG_PositedAt datetime2 not null,
        SU_TAG_Reliability decimal(5,2) not null,
        SU_TAG_Subject_Tag nvarchar(42) not null,
        SU_TAG_StatementType char(1) not null
    );
    INSERT INTO @restated (
        SU_TAG_SU_ID,
        Metadata_SU_TAG,
        SU_TAG_ChangedAt,
        SU_TAG_PositedAt,
        SU_TAG_Reliability,
        SU_TAG_Subject_Tag,
        SU_TAG_StatementType
    )
    SELECT
        x.SU_TAG_SU_ID,
        x.Metadata_SU_TAG,
        x.SU_TAG_ChangedAt,
        CASE
            WHEN x.previous_SU_TAG_PositedAt < x.SU_TAG_PositedAt THEN x.SU_TAG_PositedAt
            ELSE x.previous_SU_TAG_PositedAt
        END,
        0, -- quench the existing restatements
        x.SU_TAG_Subject_Tag,
        CASE
            WHEN x.previous_SU_TAG_PositedAt < x.SU_TAG_PositedAt THEN 'D' -- physical delete
            ELSE 'A' -- logical delete
        END
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_TAG_PositedAt as previous_SU_TAG_PositedAt
        FROM
            @SU_TAG_Subject_Tag a
        OUTER APPLY (
            SELECT TOP 1
                *
            FROM
                @SU_TAG_Subject_Tag h
            WHERE
                h.SU_TAG_SU_ID = a.SU_TAG_SU_ID
            AND
                h.SU_TAG_ChangedAt < a.SU_TAG_ChangedAt
            ORDER BY
                h.SU_TAG_ChangedAt DESC,
                h.SU_TAG_PositedAt DESC
        ) pre
        WHERE
            a.SU_TAG_Subject_Tag = pre.SU_TAG_Subject_Tag
    ) x
    WHERE
        x.SU_TAG_StatementType = 'X'; -- quench
    -- add the quenches
    INSERT INTO @SU_TAG_Subject_Tag
    SELECT
        *
    FROM (
        DELETE @restated
        OUTPUT deleted.*
        WHERE SU_TAG_StatementType = 'A'
    ) d;
    -- perform any remaining physical deletes
    DELETE a
    FROM
        @restated i
    JOIN
        [dbo].[SU_TAG_Subject_Tag_Posit] p
    ON
        p.SU_TAG_SU_ID = i.SU_TAG_SU_ID
    AND
        p.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
    AND
        p.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
    JOIN
        [dbo].[SU_TAG_Subject_Tag_Annex] a
    ON
        a.SU_TAG_ID = p.SU_TAG_ID
    AND
        a.SU_TAG_PositedAt = i.SU_TAG_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @SU_TAG_Subject_Tag SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_TAG_Subject_Tag_Posit] (
        SU_TAG_SU_ID,
        SU_TAG_ChangedAt,
        SU_TAG_Subject_Tag
    )
    SELECT
        v.SU_TAG_SU_ID,
        v.SU_TAG_ChangedAt,
        v.SU_TAG_Subject_Tag
    FROM
        @SU_TAG_Subject_Tag v
    WHERE
        v.SU_TAG_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_TAG_Subject_Tag w
        WHERE
            w.SU_TAG_StatementType = 'P'
        AND
            w.SU_TAG_SU_ID = v.SU_TAG_SU_ID
        AND
            w.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
        AND
            w.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag
        AND
            w.SU_TAG_PositedAt < v.SU_TAG_PositedAt
    );
    INSERT INTO [dbo].[SU_TAG_Subject_Tag_Annex] (
        Metadata_SU_TAG,
        SU_TAG_ID,
        SU_TAG_PositedAt,
        SU_TAG_Reliability
    )
    SELECT
        v.Metadata_SU_TAG,
        p.SU_TAG_ID,
        v.SU_TAG_PositedAt,
        v.SU_TAG_Reliability
    FROM
        @SU_TAG_Subject_Tag v
    JOIN
        [dbo].[SU_TAG_Subject_Tag_Posit] p
    ON
        p.SU_TAG_SU_ID = v.SU_TAG_SU_ID
    AND
        p.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
    AND
        p.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag
    WHERE
        SU_TAG_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_TAG_Subject_Tag_Annex] (
        Metadata_SU_TAG,
        SU_TAG_ID,
        SU_TAG_PositedAt,
        SU_TAG_Reliability
    )
    SELECT
        v.Metadata_SU_TAG,
        e.SU_TAG_ID,
        v.SU_TAG_PositedAt,
        0
    FROM
        @SU_TAG_Subject_Tag v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_TAG_ID,
            p.SU_TAG_Subject_Tag
        FROM
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        JOIN
            [dbo].[SU_TAG_Subject_Tag_Annex] a
        ON
            a.SU_TAG_ID = p.SU_TAG_ID
        AND
            a.SU_TAG_PositedAt = (
                SELECT
                    max(s.SU_TAG_PositedAt)
                FROM
                    [dbo].[SU_TAG_Subject_Tag_Annex] s
                WHERE
                    s.SU_TAG_ID = p.SU_TAG_ID
                AND
                    s.SU_TAG_PositedAt < v.SU_TAG_PositedAt
            )
        WHERE
            p.SU_TAG_SU_ID = v.SU_TAG_SU_ID
        AND
            p.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
        AND
            a.SU_TAG_Reliability = 1
        ORDER BY
            a.SU_TAG_PositedAt DESC
    ) e
    WHERE
        v.SU_TAG_StatementType in ('P', 'A')
    AND
        v.SU_TAG_Reliability = 1
    AND
        e.SU_TAG_Subject_Tag <> v.SU_TAG_Subject_Tag
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_TAG_Subject_Tag_Annex] x
        WHERE
            x.SU_TAG_ID = e.SU_TAG_ID
        AND
            x.SU_TAG_PositedAt = v.SU_TAG_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LVL_Subject_Level instead of INSERT trigger on SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_LVL_Subject_Level', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_LVL_Subject_Level];
GO
CREATE TRIGGER [dbo].[it_SU_LVL_Subject_Level] ON [dbo].[SU_LVL_Subject_Level]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_LVL_Subject_Level TABLE (
        SU_LVL_SU_ID int not null,
        Metadata_SU_LVL int not null,
        SU_LVL_ChangedAt datetime2 not null,
        SU_LVL_PositedAt datetime2 not null,
        SU_LVL_Reliability decimal(5,2) not null,
        SU_LVL_GRD_ID tinyint not null,
        SU_LVL_StatementType char(1) not null,
        primary key (
            SU_LVL_SU_ID asc,
            SU_LVL_ChangedAt desc,
            SU_LVL_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_LVL_SU_ID,
            i.SU_LVL_ChangedAt,
            i.SU_LVL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_LVL_Subject_Level_Posit] p
            JOIN
                [dbo].[SU_LVL_Subject_Level_Annex] a
            ON
                a.SU_LVL_ID = p.SU_LVL_ID
            WHERE
                p.SU_LVL_SU_ID = i.SU_LVL_SU_ID
            AND
                p.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
            AND
                p.SU_LVL_GRD_ID = i.SU_LVL_GRD_ID
            AND
                a.SU_LVL_PositedAt = i.SU_LVL_PositedAt
            AND
                a.SU_LVL_Reliability <> i.SU_LVL_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_LVL_Subject_Level for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_LVL_Subject_Level
    SELECT
        i.SU_LVL_SU_ID,
        i.Metadata_SU_LVL,
        i.SU_LVL_ChangedAt,
        i.SU_LVL_PositedAt,
        i.SU_LVL_Reliability,
        i.SU_LVL_GRD_ID,
        CASE
            WHEN p.SU_LVL_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_LVL_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_LVL_Subject_Level_Posit] p
    ON
        p.SU_LVL_SU_ID = i.SU_LVL_SU_ID
    AND
        p.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
    AND
        p.SU_LVL_GRD_ID = i.SU_LVL_GRD_ID
    LEFT JOIN
        [dbo].[SU_LVL_Subject_Level_Annex] a
    ON
        a.SU_LVL_ID = p.SU_LVL_ID
    AND
        a.SU_LVL_PositedAt = i.SU_LVL_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_LVL_ID is null OR a.SU_LVL_ID is null);
    INSERT INTO @SU_LVL_Subject_Level (
        SU_LVL_SU_ID,
        Metadata_SU_LVL,
        SU_LVL_ChangedAt,
        SU_LVL_PositedAt,
        SU_LVL_Reliability,
        SU_LVL_GRD_ID,
        SU_LVL_StatementType
    )
    SELECT
        x.SU_LVL_SU_ID,
        x.Metadata_SU_LVL,
        x.SU_LVL_ChangedAt,
        x.SU_LVL_PositedAt,
        x.SU_LVL_Reliability,
        x.SU_LVL_GRD_ID,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_LVL_SU_ID,
            a.Metadata_SU_LVL,
            p.SU_LVL_ChangedAt,
            a.SU_LVL_PositedAt,
            a.SU_LVL_Reliability,
            p.SU_LVL_GRD_ID,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_LVL_SU_ID,
                    p.SU_LVL_ChangedAt,
                    a.SU_LVL_PositedAt
                ORDER BY
                    a.SU_LVL_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_LVL_SU_ID FROM @SU_LVL_Subject_Level) i
        JOIN
            [dbo].[SU_LVL_Subject_Level_Posit] p
        ON
            p.SU_LVL_SU_ID = i.SU_LVL_SU_ID
        JOIN
            [dbo].[SU_LVL_Subject_Level_Annex] a
        ON
            a.SU_LVL_ID = p.SU_LVL_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_LVL_SU_ID int not null,
        Metadata_SU_LVL int not null,
        SU_LVL_ChangedAt datetime2 not null,
        SU_LVL_PositedAt datetime2 not null,
        SU_LVL_Reliability decimal(5,2) not null,
        SU_LVL_GRD_ID tinyint not null,
        SU_LVL_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_LVL_SU_ID,
        Metadata_SU_LVL,
        SU_LVL_ChangedAt,
        SU_LVL_PositedAt,
        SU_LVL_Reliability,
        SU_LVL_GRD_ID,
        SU_LVL_StatementType
    )
    SELECT
        SU_LVL_SU_ID,
        Metadata_SU_LVL,
        SU_LVL_ChangedAt,
        SU_LVL_PositedAt,
        SU_LVL_Reliability,
        SU_LVL_GRD_ID,
        SU_LVL_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_LVL_Reliability as previous_SU_LVL_Reliability,
            fol.SU_LVL_Reliability as following_SU_LVL_Reliability
        FROM
            @SU_LVL_Subject_Level a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_LVL_Reliability
            FROM
                @SU_LVL_Subject_Level p
            WHERE
                p.SU_LVL_SU_ID = a.SU_LVL_SU_ID
            AND
                p.SU_LVL_ChangedAt = a.SU_LVL_ChangedAt
            AND
                p.SU_LVL_PositedAt < a.SU_LVL_PositedAt
            ORDER BY
                p.SU_LVL_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_LVL_Reliability
            FROM
                @SU_LVL_Subject_Level p
            WHERE
                p.SU_LVL_SU_ID = a.SU_LVL_SU_ID
            AND
                p.SU_LVL_ChangedAt = a.SU_LVL_ChangedAt
            AND
                p.SU_LVL_PositedAt > a.SU_LVL_PositedAt
            ORDER BY
                p.SU_LVL_PositedAt ASC
        ) fol
        WHERE
            (a.SU_LVL_Reliability = 0 AND isnull(pre.SU_LVL_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_LVL_Reliability = 1 AND fol.SU_LVL_Reliability = 0)
    ) i
    WHERE
        i.SU_LVL_StatementType <> 'X'
    AND (
            (i.SU_LVL_Reliability = 0 AND i.previous_SU_LVL_Reliability = 1)
        OR
            (i.SU_LVL_Reliability = 1 AND i.following_SU_LVL_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @SU_LVL_Subject_Level SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_LVL_Subject_Level_Posit] (
        SU_LVL_SU_ID,
        SU_LVL_ChangedAt,
        SU_LVL_GRD_ID
    )
    SELECT
        v.SU_LVL_SU_ID,
        v.SU_LVL_ChangedAt,
        v.SU_LVL_GRD_ID
    FROM
        @SU_LVL_Subject_Level v
    WHERE
        v.SU_LVL_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_LVL_Subject_Level w
        WHERE
            w.SU_LVL_StatementType = 'P'
        AND
            w.SU_LVL_SU_ID = v.SU_LVL_SU_ID
        AND
            w.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
        AND
            w.SU_LVL_GRD_ID = v.SU_LVL_GRD_ID
        AND
            w.SU_LVL_PositedAt < v.SU_LVL_PositedAt
    );
    INSERT INTO [dbo].[SU_LVL_Subject_Level_Annex] (
        Metadata_SU_LVL,
        SU_LVL_ID,
        SU_LVL_PositedAt,
        SU_LVL_Reliability
    )
    SELECT
        v.Metadata_SU_LVL,
        p.SU_LVL_ID,
        v.SU_LVL_PositedAt,
        v.SU_LVL_Reliability
    FROM
        @SU_LVL_Subject_Level v
    JOIN
        [dbo].[SU_LVL_Subject_Level_Posit] p
    ON
        p.SU_LVL_SU_ID = v.SU_LVL_SU_ID
    AND
        p.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
    AND
        p.SU_LVL_GRD_ID = v.SU_LVL_GRD_ID
    WHERE
        SU_LVL_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_LVL_Subject_Level_Annex] (
        Metadata_SU_LVL,
        SU_LVL_ID,
        SU_LVL_PositedAt,
        SU_LVL_Reliability
    )
    SELECT
        v.Metadata_SU_LVL,
        e.SU_LVL_ID,
        v.SU_LVL_PositedAt,
        0
    FROM
        @SU_LVL_Subject_Level v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_LVL_ID,
            p.SU_LVL_GRD_ID
        FROM
            [dbo].[SU_LVL_Subject_Level_Posit] p
        JOIN
            [dbo].[SU_LVL_Subject_Level_Annex] a
        ON
            a.SU_LVL_ID = p.SU_LVL_ID
        AND
            a.SU_LVL_PositedAt = (
                SELECT
                    max(s.SU_LVL_PositedAt)
                FROM
                    [dbo].[SU_LVL_Subject_Level_Annex] s
                WHERE
                    s.SU_LVL_ID = p.SU_LVL_ID
                AND
                    s.SU_LVL_PositedAt < v.SU_LVL_PositedAt
            )
        WHERE
            p.SU_LVL_SU_ID = v.SU_LVL_SU_ID
        AND
            p.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
        AND
            a.SU_LVL_Reliability = 1
        ORDER BY
            a.SU_LVL_PositedAt DESC
    ) e
    WHERE
        v.SU_LVL_StatementType in ('P', 'A')
    AND
        v.SU_LVL_Reliability = 1
    AND
        e.SU_LVL_GRD_ID <> v.SU_LVL_GRD_ID
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_LVL_Subject_Level_Annex] x
        WHERE
            x.SU_LVL_ID = e.SU_LVL_ID
        AND
            x.SU_LVL_PositedAt = v.SU_LVL_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TXT_Subject_Text instead of INSERT trigger on SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TXT_Subject_Text', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TXT_Subject_Text];
GO
CREATE TRIGGER [dbo].[it_SU_TXT_Subject_Text] ON [dbo].[SU_TXT_Subject_Text]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_TXT_Subject_Text TABLE (
        SU_TXT_SU_ID int not null,
        Metadata_SU_TXT int not null,
        SU_TXT_ChangedAt datetime2 not null,
        SU_TXT_PositedAt datetime2 not null,
        SU_TXT_Reliability decimal(5,2) not null,
        SU_TXT_Subject_Text nvarchar(max) not null,
        SU_TXT_Checksum varbinary(16) not null,
        SU_TXT_StatementType char(1) not null,
        primary key (
            SU_TXT_SU_ID asc,
            SU_TXT_ChangedAt desc,
            SU_TXT_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TXT_SU_ID,
            i.SU_TXT_ChangedAt,
            i.SU_TXT_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TXT_Subject_Text_Posit] p
            JOIN
                [dbo].[SU_TXT_Subject_Text_Annex] a
            ON
                a.SU_TXT_ID = p.SU_TXT_ID
            WHERE
                p.SU_TXT_SU_ID = i.SU_TXT_SU_ID
            AND
                p.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
            AND
                p.SU_TXT_Checksum = dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
            AND
                a.SU_TXT_PositedAt = i.SU_TXT_PositedAt
            AND
                a.SU_TXT_Reliability <> i.SU_TXT_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TXT_Subject_Text for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_TXT_Subject_Text
    SELECT
        i.SU_TXT_SU_ID,
        i.Metadata_SU_TXT,
        i.SU_TXT_ChangedAt,
        i.SU_TXT_PositedAt,
        i.SU_TXT_Reliability,
        i.SU_TXT_Subject_Text,
        dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max))),
        CASE
            WHEN p.SU_TXT_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_TXT_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_TXT_Subject_Text_Posit] p
    ON
        p.SU_TXT_SU_ID = i.SU_TXT_SU_ID
    AND
        p.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
    AND
        p.SU_TXT_Checksum = dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
    LEFT JOIN
        [dbo].[SU_TXT_Subject_Text_Annex] a
    ON
        a.SU_TXT_ID = p.SU_TXT_ID
    AND
        a.SU_TXT_PositedAt = i.SU_TXT_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_TXT_ID is null OR a.SU_TXT_ID is null);
    INSERT INTO @SU_TXT_Subject_Text (
        SU_TXT_SU_ID,
        Metadata_SU_TXT,
        SU_TXT_ChangedAt,
        SU_TXT_PositedAt,
        SU_TXT_Reliability,
        SU_TXT_Subject_Text,
        SU_TXT_Checksum,
        SU_TXT_StatementType
    )
    SELECT
        x.SU_TXT_SU_ID,
        x.Metadata_SU_TXT,
        x.SU_TXT_ChangedAt,
        x.SU_TXT_PositedAt,
        x.SU_TXT_Reliability,
        x.SU_TXT_Subject_Text,
        x.SU_TXT_Checksum,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_TXT_SU_ID,
            a.Metadata_SU_TXT,
            p.SU_TXT_ChangedAt,
            a.SU_TXT_PositedAt,
            a.SU_TXT_Reliability,
            p.SU_TXT_Subject_Text,
            p.SU_TXT_Checksum,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_TXT_SU_ID,
                    p.SU_TXT_ChangedAt,
                    a.SU_TXT_PositedAt
                ORDER BY
                    a.SU_TXT_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_TXT_SU_ID FROM @SU_TXT_Subject_Text) i
        JOIN
            [dbo].[SU_TXT_Subject_Text_Posit] p
        ON
            p.SU_TXT_SU_ID = i.SU_TXT_SU_ID
        JOIN
            [dbo].[SU_TXT_Subject_Text_Annex] a
        ON
            a.SU_TXT_ID = p.SU_TXT_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_TXT_SU_ID int not null,
        Metadata_SU_TXT int not null,
        SU_TXT_ChangedAt datetime2 not null,
        SU_TXT_PositedAt datetime2 not null,
        SU_TXT_Reliability decimal(5,2) not null,
        SU_TXT_Subject_Text nvarchar(max) not null,
        SU_TXT_Checksum varbinary(16) not null,
        SU_TXT_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_TXT_SU_ID,
        Metadata_SU_TXT,
        SU_TXT_ChangedAt,
        SU_TXT_PositedAt,
        SU_TXT_Reliability,
        SU_TXT_Subject_Text,
        SU_TXT_Checksum,
        SU_TXT_StatementType
    )
    SELECT
        SU_TXT_SU_ID,
        Metadata_SU_TXT,
        SU_TXT_ChangedAt,
        SU_TXT_PositedAt,
        SU_TXT_Reliability,
        SU_TXT_Subject_Text,
        SU_TXT_Checksum,
        SU_TXT_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_TXT_Reliability as previous_SU_TXT_Reliability,
            fol.SU_TXT_Reliability as following_SU_TXT_Reliability
        FROM
            @SU_TXT_Subject_Text a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_TXT_Reliability
            FROM
                @SU_TXT_Subject_Text p
            WHERE
                p.SU_TXT_SU_ID = a.SU_TXT_SU_ID
            AND
                p.SU_TXT_ChangedAt = a.SU_TXT_ChangedAt
            AND
                p.SU_TXT_PositedAt < a.SU_TXT_PositedAt
            ORDER BY
                p.SU_TXT_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_TXT_Reliability
            FROM
                @SU_TXT_Subject_Text p
            WHERE
                p.SU_TXT_SU_ID = a.SU_TXT_SU_ID
            AND
                p.SU_TXT_ChangedAt = a.SU_TXT_ChangedAt
            AND
                p.SU_TXT_PositedAt > a.SU_TXT_PositedAt
            ORDER BY
                p.SU_TXT_PositedAt ASC
        ) fol
        WHERE
            (a.SU_TXT_Reliability = 0 AND isnull(pre.SU_TXT_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_TXT_Reliability = 1 AND fol.SU_TXT_Reliability = 0)
    ) i
    WHERE
        i.SU_TXT_StatementType <> 'X'
    AND (
            (i.SU_TXT_Reliability = 0 AND i.previous_SU_TXT_Reliability = 1)
        OR
            (i.SU_TXT_Reliability = 1 AND i.following_SU_TXT_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @SU_TXT_Subject_Text SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_TXT_Subject_Text_Posit] (
        SU_TXT_SU_ID,
        SU_TXT_ChangedAt,
        SU_TXT_Subject_Text
    )
    SELECT
        v.SU_TXT_SU_ID,
        v.SU_TXT_ChangedAt,
        v.SU_TXT_Subject_Text
    FROM
        @SU_TXT_Subject_Text v
    WHERE
        v.SU_TXT_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_TXT_Subject_Text w
        WHERE
            w.SU_TXT_StatementType = 'P'
        AND
            w.SU_TXT_SU_ID = v.SU_TXT_SU_ID
        AND
            w.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
        AND
            w.SU_TXT_Checksum = v.SU_TXT_Checksum
        AND
            w.SU_TXT_PositedAt < v.SU_TXT_PositedAt
    );
    INSERT INTO [dbo].[SU_TXT_Subject_Text_Annex] (
        Metadata_SU_TXT,
        SU_TXT_ID,
        SU_TXT_PositedAt,
        SU_TXT_Reliability
    )
    SELECT
        v.Metadata_SU_TXT,
        p.SU_TXT_ID,
        v.SU_TXT_PositedAt,
        v.SU_TXT_Reliability
    FROM
        @SU_TXT_Subject_Text v
    JOIN
        [dbo].[SU_TXT_Subject_Text_Posit] p
    ON
        p.SU_TXT_SU_ID = v.SU_TXT_SU_ID
    AND
        p.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
    AND
        p.SU_TXT_Checksum = v.SU_TXT_Checksum
    WHERE
        SU_TXT_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_TXT_Subject_Text_Annex] (
        Metadata_SU_TXT,
        SU_TXT_ID,
        SU_TXT_PositedAt,
        SU_TXT_Reliability
    )
    SELECT
        v.Metadata_SU_TXT,
        e.SU_TXT_ID,
        v.SU_TXT_PositedAt,
        0
    FROM
        @SU_TXT_Subject_Text v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_TXT_ID,
            p.SU_TXT_Checksum
        FROM
            [dbo].[SU_TXT_Subject_Text_Posit] p
        JOIN
            [dbo].[SU_TXT_Subject_Text_Annex] a
        ON
            a.SU_TXT_ID = p.SU_TXT_ID
        AND
            a.SU_TXT_PositedAt = (
                SELECT
                    max(s.SU_TXT_PositedAt)
                FROM
                    [dbo].[SU_TXT_Subject_Text_Annex] s
                WHERE
                    s.SU_TXT_ID = p.SU_TXT_ID
                AND
                    s.SU_TXT_PositedAt < v.SU_TXT_PositedAt
            )
        WHERE
            p.SU_TXT_SU_ID = v.SU_TXT_SU_ID
        AND
            p.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
        AND
            a.SU_TXT_Reliability = 1
        ORDER BY
            a.SU_TXT_PositedAt DESC
    ) e
    WHERE
        v.SU_TXT_StatementType in ('P', 'A')
    AND
        v.SU_TXT_Reliability = 1
    AND
        e.SU_TXT_Checksum <> v.SU_TXT_Checksum
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_TXT_Subject_Text_Annex] x
        WHERE
            x.SU_TXT_ID = e.SU_TXT_ID
        AND
            x.SU_TXT_PositedAt = v.SU_TXT_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ASR_Subject_Assessment instead of INSERT trigger on SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_ASR_Subject_Assessment', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_ASR_Subject_Assessment];
GO
CREATE TRIGGER [dbo].[it_SU_ASR_Subject_Assessment] ON [dbo].[SU_ASR_Subject_Assessment]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_ASR_Subject_Assessment TABLE (
        SU_ASR_SU_ID int not null,
        Metadata_SU_ASR int not null,
        SU_ASR_ChangedAt datetime2 not null,
        SU_ASR_PositedAt datetime2 not null,
        SU_ASR_Reliability decimal(5,2) not null,
        SU_ASR_Subject_Assessment nvarchar(42) not null,
        SU_ASR_StatementType char(1) not null,
        primary key (
            SU_ASR_SU_ID asc,
            SU_ASR_ChangedAt desc,
            SU_ASR_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ASR_SU_ID,
            i.SU_ASR_ChangedAt,
            i.SU_ASR_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_ASR_Subject_Assessment_Posit] p
            JOIN
                [dbo].[SU_ASR_Subject_Assessment_Annex] a
            ON
                a.SU_ASR_ID = p.SU_ASR_ID
            WHERE
                p.SU_ASR_SU_ID = i.SU_ASR_SU_ID
            AND
                p.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
            AND
                p.SU_ASR_Subject_Assessment = i.SU_ASR_Subject_Assessment
            AND
                a.SU_ASR_PositedAt = i.SU_ASR_PositedAt
            AND
                a.SU_ASR_Reliability <> i.SU_ASR_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_ASR_Subject_Assessment for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_ASR_Subject_Assessment
    SELECT
        i.SU_ASR_SU_ID,
        i.Metadata_SU_ASR,
        i.SU_ASR_ChangedAt,
        i.SU_ASR_PositedAt,
        i.SU_ASR_Reliability,
        i.SU_ASR_Subject_Assessment,
        CASE
            WHEN p.SU_ASR_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_ASR_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_ASR_Subject_Assessment_Posit] p
    ON
        p.SU_ASR_SU_ID = i.SU_ASR_SU_ID
    AND
        p.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
    AND
        p.SU_ASR_Subject_Assessment = i.SU_ASR_Subject_Assessment
    LEFT JOIN
        [dbo].[SU_ASR_Subject_Assessment_Annex] a
    ON
        a.SU_ASR_ID = p.SU_ASR_ID
    AND
        a.SU_ASR_PositedAt = i.SU_ASR_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_ASR_ID is null OR a.SU_ASR_ID is null);
    INSERT INTO @SU_ASR_Subject_Assessment (
        SU_ASR_SU_ID,
        Metadata_SU_ASR,
        SU_ASR_ChangedAt,
        SU_ASR_PositedAt,
        SU_ASR_Reliability,
        SU_ASR_Subject_Assessment,
        SU_ASR_StatementType
    )
    SELECT
        x.SU_ASR_SU_ID,
        x.Metadata_SU_ASR,
        x.SU_ASR_ChangedAt,
        x.SU_ASR_PositedAt,
        x.SU_ASR_Reliability,
        x.SU_ASR_Subject_Assessment,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_ASR_SU_ID,
            a.Metadata_SU_ASR,
            p.SU_ASR_ChangedAt,
            a.SU_ASR_PositedAt,
            a.SU_ASR_Reliability,
            p.SU_ASR_Subject_Assessment,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_ASR_SU_ID,
                    p.SU_ASR_ChangedAt,
                    a.SU_ASR_PositedAt
                ORDER BY
                    a.SU_ASR_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_ASR_SU_ID FROM @SU_ASR_Subject_Assessment) i
        JOIN
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        ON
            p.SU_ASR_SU_ID = i.SU_ASR_SU_ID
        JOIN
            [dbo].[SU_ASR_Subject_Assessment_Annex] a
        ON
            a.SU_ASR_ID = p.SU_ASR_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_ASR_SU_ID int not null,
        Metadata_SU_ASR int not null,
        SU_ASR_ChangedAt datetime2 not null,
        SU_ASR_PositedAt datetime2 not null,
        SU_ASR_Reliability decimal(5,2) not null,
        SU_ASR_Subject_Assessment nvarchar(42) not null,
        SU_ASR_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_ASR_SU_ID,
        Metadata_SU_ASR,
        SU_ASR_ChangedAt,
        SU_ASR_PositedAt,
        SU_ASR_Reliability,
        SU_ASR_Subject_Assessment,
        SU_ASR_StatementType
    )
    SELECT
        SU_ASR_SU_ID,
        Metadata_SU_ASR,
        SU_ASR_ChangedAt,
        SU_ASR_PositedAt,
        SU_ASR_Reliability,
        SU_ASR_Subject_Assessment,
        SU_ASR_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_ASR_Reliability as previous_SU_ASR_Reliability,
            fol.SU_ASR_Reliability as following_SU_ASR_Reliability
        FROM
            @SU_ASR_Subject_Assessment a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_ASR_Reliability
            FROM
                @SU_ASR_Subject_Assessment p
            WHERE
                p.SU_ASR_SU_ID = a.SU_ASR_SU_ID
            AND
                p.SU_ASR_ChangedAt = a.SU_ASR_ChangedAt
            AND
                p.SU_ASR_PositedAt < a.SU_ASR_PositedAt
            ORDER BY
                p.SU_ASR_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_ASR_Reliability
            FROM
                @SU_ASR_Subject_Assessment p
            WHERE
                p.SU_ASR_SU_ID = a.SU_ASR_SU_ID
            AND
                p.SU_ASR_ChangedAt = a.SU_ASR_ChangedAt
            AND
                p.SU_ASR_PositedAt > a.SU_ASR_PositedAt
            ORDER BY
                p.SU_ASR_PositedAt ASC
        ) fol
        WHERE
            (a.SU_ASR_Reliability = 0 AND isnull(pre.SU_ASR_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_ASR_Reliability = 1 AND fol.SU_ASR_Reliability = 0)
    ) i
    WHERE
        i.SU_ASR_StatementType <> 'X'
    AND (
            (i.SU_ASR_Reliability = 0 AND i.previous_SU_ASR_Reliability = 1)
        OR
            (i.SU_ASR_Reliability = 1 AND i.following_SU_ASR_Reliability = 0)
        );
    -- remove remaining (dangling) retractions
    DELETE @SU_ASR_Subject_Assessment
    WHERE
        SU_ASR_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1
            SU_ASR_StatementType
        FROM
            @SU_ASR_Subject_Assessment
        WHERE
            SU_ASR_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        SU_ASR_SU_ID int not null,
        Metadata_SU_ASR int not null,
        SU_ASR_ChangedAt datetime2 not null,
        SU_ASR_PositedAt datetime2 not null,
        SU_ASR_Reliability decimal(5,2) not null,
        SU_ASR_Subject_Assessment nvarchar(42) not null,
        previous_SU_ASR_PositedAt datetime2 not null,
        primary key(
            SU_ASR_SU_ID asc,
            SU_ASR_ChangedAt desc,
            SU_ASR_PositedAt desc
        )
    );
    INSERT INTO @updated (
        SU_ASR_SU_ID,
        Metadata_SU_ASR,
        SU_ASR_ChangedAt,
        SU_ASR_PositedAt,
        SU_ASR_Reliability,
        SU_ASR_Subject_Assessment,
        previous_SU_ASR_PositedAt
    )
    SELECT
        SU_ASR_SU_ID,
        Metadata_SU_ASR,
        SU_ASR_ChangedAt,
        SU_ASR_PositedAt,
        SU_ASR_Reliability,
        SU_ASR_Subject_Assessment,
        previous_SU_ASR_PositedAt
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_ASR_PositedAt AS previous_SU_ASR_PositedAt,
            pre.SU_ASR_StatementType AS previous_SU_ASR_StatementType
        FROM
            @SU_ASR_Subject_Assessment a
        CROSS APPLY (
            SELECT TOP 1
                *
            FROM
                @SU_ASR_Subject_Assessment s
            WHERE
                s.SU_ASR_SU_ID = a.SU_ASR_SU_ID
            AND
                s.SU_ASR_ChangedAt = a.SU_ASR_ChangedAt
            AND
                s.SU_ASR_PositedAt < a.SU_ASR_PositedAt
            ORDER BY
                s.SU_ASR_PositedAt DESC
        ) pre -- what is shown just before
        WHERE
            a.SU_ASR_Subject_Assessment = pre.SU_ASR_Subject_Assessment
        AND
            a.SU_ASR_Reliability = pre.SU_ASR_Reliability
    ) u
    WHERE
        u.previous_SU_ASR_StatementType = 'A';
    DELETE a
    FROM
        @SU_ASR_Subject_Assessment a
    JOIN
        @updated u
    ON
        u.SU_ASR_SU_ID = a.SU_ASR_SU_ID
    AND
        u.SU_ASR_ChangedAt = a.SU_ASR_ChangedAt
    AND
        u.SU_ASR_Subject_Assessment = a.SU_ASR_Subject_Assessment
    AND
        u.previous_SU_ASR_PositedAt = a.SU_ASR_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @SU_ASR_Subject_Assessment SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment_Posit] (
        SU_ASR_SU_ID,
        SU_ASR_ChangedAt,
        SU_ASR_Subject_Assessment
    )
    SELECT
        v.SU_ASR_SU_ID,
        v.SU_ASR_ChangedAt,
        v.SU_ASR_Subject_Assessment
    FROM
        @SU_ASR_Subject_Assessment v
    WHERE
        v.SU_ASR_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_ASR_Subject_Assessment w
        WHERE
            w.SU_ASR_StatementType = 'P'
        AND
            w.SU_ASR_SU_ID = v.SU_ASR_SU_ID
        AND
            w.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
        AND
            w.SU_ASR_Subject_Assessment = v.SU_ASR_Subject_Assessment
        AND
            w.SU_ASR_PositedAt < v.SU_ASR_PositedAt
    );
    UPDATE a
    SET
        a.SU_ASR_PositedAt = u.previous_SU_ASR_PositedAt
    FROM
        @updated u
    JOIN
        [dbo].[SU_ASR_Subject_Assessment_Posit] p
    ON
        u.SU_ASR_SU_ID = p.SU_ASR_SU_ID
    AND
        u.SU_ASR_ChangedAt = p.SU_ASR_ChangedAt
    AND
        u.SU_ASR_Subject_Assessment = p.SU_ASR_Subject_Assessment
    JOIN
        [dbo].[SU_ASR_Subject_Assessment_Annex] a
    ON
        a.SU_ASR_ID = p.SU_ASR_ID
    AND
        a.SU_ASR_PositedAt = u.SU_ASR_PositedAt;
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment_Annex] (
        Metadata_SU_ASR,
        SU_ASR_ID,
        SU_ASR_PositedAt,
        SU_ASR_Reliability
    )
    SELECT
        v.Metadata_SU_ASR,
        p.SU_ASR_ID,
        v.SU_ASR_PositedAt,
        v.SU_ASR_Reliability
    FROM
        @SU_ASR_Subject_Assessment v
    JOIN
        [dbo].[SU_ASR_Subject_Assessment_Posit] p
    ON
        p.SU_ASR_SU_ID = v.SU_ASR_SU_ID
    AND
        p.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
    AND
        p.SU_ASR_Subject_Assessment = v.SU_ASR_Subject_Assessment
    WHERE
        SU_ASR_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment_Annex] (
        Metadata_SU_ASR,
        SU_ASR_ID,
        SU_ASR_PositedAt,
        SU_ASR_Reliability
    )
    SELECT
        v.Metadata_SU_ASR,
        e.SU_ASR_ID,
        v.SU_ASR_PositedAt,
        0
    FROM
        @SU_ASR_Subject_Assessment v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_ASR_ID,
            p.SU_ASR_Subject_Assessment
        FROM
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        JOIN
            [dbo].[SU_ASR_Subject_Assessment_Annex] a
        ON
            a.SU_ASR_ID = p.SU_ASR_ID
        AND
            a.SU_ASR_PositedAt = (
                SELECT
                    max(s.SU_ASR_PositedAt)
                FROM
                    [dbo].[SU_ASR_Subject_Assessment_Annex] s
                WHERE
                    s.SU_ASR_ID = p.SU_ASR_ID
                AND
                    s.SU_ASR_PositedAt < v.SU_ASR_PositedAt
            )
        WHERE
            p.SU_ASR_SU_ID = v.SU_ASR_SU_ID
        AND
            p.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
        AND
            a.SU_ASR_Reliability = 1
        ORDER BY
            a.SU_ASR_PositedAt DESC
    ) e
    WHERE
        v.SU_ASR_StatementType in ('P', 'A')
    AND
        v.SU_ASR_Reliability = 1
    AND
        e.SU_ASR_Subject_Assessment <> v.SU_ASR_Subject_Assessment
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_ASR_Subject_Assessment_Annex] x
        WHERE
            x.SU_ASR_ID = e.SU_ASR_ID
        AND
            x.SU_ASR_PositedAt = v.SU_ASR_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ERS_Subject_Erasable instead of INSERT trigger on SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_ERS_Subject_Erasable', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_ERS_Subject_Erasable];
GO
CREATE TRIGGER [dbo].[it_SU_ERS_Subject_Erasable] ON [dbo].[SU_ERS_Subject_Erasable]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SU_ERS_Subject_Erasable TABLE (
        SU_ERS_SU_ID int not null,
        Metadata_SU_ERS int not null,
        SU_ERS_ChangedAt datetime2 not null,
        SU_ERS_PositedAt datetime2 not null,
        SU_ERS_Reliability decimal(5,2) not null,
        SU_ERS_Subject_Erasable nvarchar(42) not null,
        SU_ERS_StatementType char(1) not null,
        primary key (
            SU_ERS_SU_ID asc,
            SU_ERS_ChangedAt desc,
            SU_ERS_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ERS_SU_ID,
            i.SU_ERS_ChangedAt,
            i.SU_ERS_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_ERS_Subject_Erasable_Posit] p
            JOIN
                [dbo].[SU_ERS_Subject_Erasable_Annex] a
            ON
                a.SU_ERS_ID = p.SU_ERS_ID
            WHERE
                p.SU_ERS_SU_ID = i.SU_ERS_SU_ID
            AND
                p.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
            AND
                p.SU_ERS_Subject_Erasable = i.SU_ERS_Subject_Erasable
            AND
                a.SU_ERS_PositedAt = i.SU_ERS_PositedAt
            AND
                a.SU_ERS_Reliability <> i.SU_ERS_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_ERS_Subject_Erasable for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_ERS_Subject_Erasable
    SELECT
        i.SU_ERS_SU_ID,
        i.Metadata_SU_ERS,
        i.SU_ERS_ChangedAt,
        i.SU_ERS_PositedAt,
        i.SU_ERS_Reliability,
        i.SU_ERS_Subject_Erasable,
        CASE
            WHEN p.SU_ERS_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_ERS_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_ERS_Subject_Erasable_Posit] p
    ON
        p.SU_ERS_SU_ID = i.SU_ERS_SU_ID
    AND
        p.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
    AND
        p.SU_ERS_Subject_Erasable = i.SU_ERS_Subject_Erasable
    LEFT JOIN
        [dbo].[SU_ERS_Subject_Erasable_Annex] a
    ON
        a.SU_ERS_ID = p.SU_ERS_ID
    AND
        a.SU_ERS_PositedAt = i.SU_ERS_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_ERS_ID is null OR a.SU_ERS_ID is null);
    INSERT INTO @SU_ERS_Subject_Erasable (
        SU_ERS_SU_ID,
        Metadata_SU_ERS,
        SU_ERS_ChangedAt,
        SU_ERS_PositedAt,
        SU_ERS_Reliability,
        SU_ERS_Subject_Erasable,
        SU_ERS_StatementType
    )
    SELECT
        x.SU_ERS_SU_ID,
        x.Metadata_SU_ERS,
        x.SU_ERS_ChangedAt,
        x.SU_ERS_PositedAt,
        x.SU_ERS_Reliability,
        x.SU_ERS_Subject_Erasable,
        'X' -- existing data
    FROM (
        SELECT
            i.SU_ERS_SU_ID,
            a.Metadata_SU_ERS,
            p.SU_ERS_ChangedAt,
            a.SU_ERS_PositedAt,
            a.SU_ERS_Reliability,
            p.SU_ERS_Subject_Erasable,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.SU_ERS_SU_ID,
                    p.SU_ERS_ChangedAt,
                    a.SU_ERS_PositedAt
                ORDER BY
                    a.SU_ERS_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT SU_ERS_SU_ID FROM @SU_ERS_Subject_Erasable) i
        JOIN
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        ON
            p.SU_ERS_SU_ID = i.SU_ERS_SU_ID
        JOIN
            [dbo].[SU_ERS_Subject_Erasable_Annex] a
        ON
            a.SU_ERS_ID = p.SU_ERS_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        SU_ERS_SU_ID int not null,
        Metadata_SU_ERS int not null,
        SU_ERS_ChangedAt datetime2 not null,
        SU_ERS_PositedAt datetime2 not null,
        SU_ERS_Reliability decimal(5,2) not null,
        SU_ERS_Subject_Erasable nvarchar(42) not null,
        SU_ERS_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        SU_ERS_SU_ID,
        Metadata_SU_ERS,
        SU_ERS_ChangedAt,
        SU_ERS_PositedAt,
        SU_ERS_Reliability,
        SU_ERS_Subject_Erasable,
        SU_ERS_StatementType
    )
    SELECT
        SU_ERS_SU_ID,
        Metadata_SU_ERS,
        SU_ERS_ChangedAt,
        SU_ERS_PositedAt,
        SU_ERS_Reliability,
        SU_ERS_Subject_Erasable,
        SU_ERS_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_ERS_Reliability as previous_SU_ERS_Reliability,
            fol.SU_ERS_Reliability as following_SU_ERS_Reliability
        FROM
            @SU_ERS_Subject_Erasable a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_ERS_Reliability
            FROM
                @SU_ERS_Subject_Erasable p
            WHERE
                p.SU_ERS_SU_ID = a.SU_ERS_SU_ID
            AND
                p.SU_ERS_ChangedAt = a.SU_ERS_ChangedAt
            AND
                p.SU_ERS_PositedAt < a.SU_ERS_PositedAt
            ORDER BY
                p.SU_ERS_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_ERS_Reliability
            FROM
                @SU_ERS_Subject_Erasable p
            WHERE
                p.SU_ERS_SU_ID = a.SU_ERS_SU_ID
            AND
                p.SU_ERS_ChangedAt = a.SU_ERS_ChangedAt
            AND
                p.SU_ERS_PositedAt > a.SU_ERS_PositedAt
            ORDER BY
                p.SU_ERS_PositedAt ASC
        ) fol
        WHERE
            (a.SU_ERS_Reliability = 0 AND isnull(pre.SU_ERS_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_ERS_Reliability = 1 AND fol.SU_ERS_Reliability = 0)
    ) i
    WHERE
        i.SU_ERS_StatementType <> 'X'
    AND (
            (i.SU_ERS_Reliability = 0 AND i.previous_SU_ERS_Reliability = 1)
        OR
            (i.SU_ERS_Reliability = 1 AND i.following_SU_ERS_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @SU_ERS_Subject_Erasable SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable_Posit] (
        SU_ERS_SU_ID,
        SU_ERS_ChangedAt,
        SU_ERS_Subject_Erasable
    )
    SELECT
        v.SU_ERS_SU_ID,
        v.SU_ERS_ChangedAt,
        v.SU_ERS_Subject_Erasable
    FROM
        @SU_ERS_Subject_Erasable v
    WHERE
        v.SU_ERS_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @SU_ERS_Subject_Erasable w
        WHERE
            w.SU_ERS_StatementType = 'P'
        AND
            w.SU_ERS_SU_ID = v.SU_ERS_SU_ID
        AND
            w.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
        AND
            w.SU_ERS_Subject_Erasable = v.SU_ERS_Subject_Erasable
        AND
            w.SU_ERS_PositedAt < v.SU_ERS_PositedAt
    );
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable_Annex] (
        Metadata_SU_ERS,
        SU_ERS_ID,
        SU_ERS_PositedAt,
        SU_ERS_Reliability
    )
    SELECT
        v.Metadata_SU_ERS,
        p.SU_ERS_ID,
        v.SU_ERS_PositedAt,
        v.SU_ERS_Reliability
    FROM
        @SU_ERS_Subject_Erasable v
    JOIN
        [dbo].[SU_ERS_Subject_Erasable_Posit] p
    ON
        p.SU_ERS_SU_ID = v.SU_ERS_SU_ID
    AND
        p.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
    AND
        p.SU_ERS_Subject_Erasable = v.SU_ERS_Subject_Erasable
    WHERE
        SU_ERS_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect at the same changing time when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable_Annex] (
        Metadata_SU_ERS,
        SU_ERS_ID,
        SU_ERS_PositedAt,
        SU_ERS_Reliability
    )
    SELECT
        v.Metadata_SU_ERS,
        e.SU_ERS_ID,
        v.SU_ERS_PositedAt,
        0
    FROM
        @SU_ERS_Subject_Erasable v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_ERS_ID,
            p.SU_ERS_Subject_Erasable
        FROM
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        JOIN
            [dbo].[SU_ERS_Subject_Erasable_Annex] a
        ON
            a.SU_ERS_ID = p.SU_ERS_ID
        AND
            a.SU_ERS_PositedAt = (
                SELECT
                    max(s.SU_ERS_PositedAt)
                FROM
                    [dbo].[SU_ERS_Subject_Erasable_Annex] s
                WHERE
                    s.SU_ERS_ID = p.SU_ERS_ID
                AND
                    s.SU_ERS_PositedAt < v.SU_ERS_PositedAt
            )
        WHERE
            p.SU_ERS_SU_ID = v.SU_ERS_SU_ID
        AND
            p.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
        AND
            a.SU_ERS_Reliability = 1
        ORDER BY
            a.SU_ERS_PositedAt DESC
    ) e
    WHERE
        v.SU_ERS_StatementType in ('P', 'A')
    AND
        v.SU_ERS_Reliability = 1
    AND
        e.SU_ERS_Subject_Erasable <> v.SU_ERS_Subject_Erasable
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_ERS_Subject_Erasable_Annex] x
        WHERE
            x.SU_ERS_ID = e.SU_ERS_ID
        AND
            x.SU_ERS_PositedAt = v.SU_ERS_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_NAM_Object_Name instead of INSERT trigger on OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_OB_NAM_Object_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_OB_NAM_Object_Name];
GO
CREATE TRIGGER [dbo].[it_OB_NAM_Object_Name] ON [dbo].[OB_NAM_Object_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OB_NAM_Object_Name TABLE (
        OB_NAM_OB_ID int not null,
        Metadata_OB_NAM int not null,
        OB_NAM_PositedAt datetime2 not null,
        OB_NAM_Reliability decimal(5,2) not null,
        OB_NAM_Object_Name nvarchar(42) not null,
        OB_NAM_StatementType char(1) not null,
        primary key (
            OB_NAM_OB_ID asc,
            OB_NAM_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.OB_NAM_OB_ID,
            i.OB_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[OB_NAM_Object_Name_Posit] p
            JOIN
                [dbo].[OB_NAM_Object_Name_Annex] a
            ON
                a.OB_NAM_ID = p.OB_NAM_ID
            WHERE
                p.OB_NAM_OB_ID = i.OB_NAM_OB_ID
            AND
                p.OB_NAM_Object_Name = i.OB_NAM_Object_Name
            AND
                a.OB_NAM_PositedAt = i.OB_NAM_PositedAt
            AND
                a.OB_NAM_Reliability <> i.OB_NAM_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in OB_NAM_Object_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @OB_NAM_Object_Name
    SELECT
        i.OB_NAM_OB_ID,
        i.Metadata_OB_NAM,
        i.OB_NAM_PositedAt,
        i.OB_NAM_Reliability,
        i.OB_NAM_Object_Name,
        CASE
            WHEN p.OB_NAM_ID is null
            THEN 'P' -- new posit
            WHEN a.OB_NAM_ID is null
            THEN 'A' -- new assertion
        END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[OB_NAM_Object_Name_Posit] p
    ON
        p.OB_NAM_OB_ID = i.OB_NAM_OB_ID
    AND
        p.OB_NAM_Object_Name = i.OB_NAM_Object_Name
    LEFT JOIN
        [dbo].[OB_NAM_Object_Name_Annex] a
    ON
        a.OB_NAM_ID = p.OB_NAM_ID
    AND
        a.OB_NAM_PositedAt = i.OB_NAM_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.OB_NAM_ID is null OR a.OB_NAM_ID is null);
    INSERT INTO @OB_NAM_Object_Name (
        OB_NAM_OB_ID,
        Metadata_OB_NAM,
        OB_NAM_PositedAt,
        OB_NAM_Reliability,
        OB_NAM_Object_Name,
        OB_NAM_StatementType
    )
    SELECT
        x.OB_NAM_OB_ID,
        x.Metadata_OB_NAM,
        x.OB_NAM_PositedAt,
        x.OB_NAM_Reliability,
        x.OB_NAM_Object_Name,
        'X' -- existing data
    FROM (
        SELECT
            i.OB_NAM_OB_ID,
            a.Metadata_OB_NAM,
            a.OB_NAM_PositedAt,
            a.OB_NAM_Reliability,
            p.OB_NAM_Object_Name,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    i.OB_NAM_OB_ID,
                    a.OB_NAM_PositedAt
                ORDER BY
                    a.OB_NAM_Reliability DESC
            ) as shown
        FROM
            (SELECT DISTINCT OB_NAM_OB_ID FROM @OB_NAM_Object_Name) i
        JOIN
            [dbo].[OB_NAM_Object_Name_Posit] p
        ON
            p.OB_NAM_OB_ID = i.OB_NAM_OB_ID
        JOIN
            [dbo].[OB_NAM_Object_Name_Annex] a
        ON
            a.OB_NAM_ID = p.OB_NAM_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        OB_NAM_OB_ID int not null,
        Metadata_OB_NAM int not null,
        OB_NAM_PositedAt datetime2 not null,
        OB_NAM_Reliability decimal(5,2) not null,
        OB_NAM_Object_Name nvarchar(42) not null,
        OB_NAM_StatementType char(1) not null
    );
    INSERT INTO @retracted (
        OB_NAM_OB_ID,
        Metadata_OB_NAM,
        OB_NAM_PositedAt,
        OB_NAM_Reliability,
        OB_NAM_Object_Name,
        OB_NAM_StatementType
    )
    SELECT
        OB_NAM_OB_ID,
        Metadata_OB_NAM,
        OB_NAM_PositedAt,
        OB_NAM_Reliability,
        OB_NAM_Object_Name,
        OB_NAM_StatementType
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.OB_NAM_Reliability as previous_OB_NAM_Reliability,
            fol.OB_NAM_Reliability as following_OB_NAM_Reliability
        FROM
            @OB_NAM_Object_Name a
        OUTER APPLY (
            SELECT TOP 1
                p.OB_NAM_Reliability
            FROM
                @OB_NAM_Object_Name p
            WHERE
                p.OB_NAM_OB_ID = a.OB_NAM_OB_ID
            AND
                p.OB_NAM_PositedAt < a.OB_NAM_PositedAt
            ORDER BY
                p.OB_NAM_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.OB_NAM_Reliability
            FROM
                @OB_NAM_Object_Name p
            WHERE
                p.OB_NAM_OB_ID = a.OB_NAM_OB_ID
            AND
                p.OB_NAM_PositedAt > a.OB_NAM_PositedAt
            ORDER BY
                p.OB_NAM_PositedAt ASC
        ) fol
        WHERE
            (a.OB_NAM_Reliability = 0 AND isnull(pre.OB_NAM_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.OB_NAM_Reliability = 1 AND fol.OB_NAM_Reliability = 0)
    ) i
    WHERE
        i.OB_NAM_StatementType <> 'X'
    AND (
            (i.OB_NAM_Reliability = 0 AND i.previous_OB_NAM_Reliability = 1)
        OR
            (i.OB_NAM_Reliability = 1 AND i.following_OB_NAM_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @OB_NAM_Object_Name SELECT * FROM @retracted;
    INSERT INTO [dbo].[OB_NAM_Object_Name_Posit] (
        OB_NAM_OB_ID,
        OB_NAM_Object_Name
    )
    SELECT
        v.OB_NAM_OB_ID,
        v.OB_NAM_Object_Name
    FROM
        @OB_NAM_Object_Name v
    WHERE
        v.OB_NAM_StatementType = 'P'
    AND NOT EXISTS ( -- a posit stated at several positing times is made once
        SELECT TOP 1
            42
        FROM
            @OB_NAM_Object_Name w
        WHERE
            w.OB_NAM_StatementType = 'P'
        AND
            w.OB_NAM_OB_ID = v.OB_NAM_OB_ID
        AND
            w.OB_NAM_Object_Name = v.OB_NAM_Object_Name
        AND
            w.OB_NAM_PositedAt < v.OB_NAM_PositedAt
    );
    INSERT INTO [dbo].[OB_NAM_Object_Name_Annex] (
        Metadata_OB_NAM,
        OB_NAM_ID,
        OB_NAM_PositedAt,
        OB_NAM_Reliability
    )
    SELECT
        v.Metadata_OB_NAM,
        p.OB_NAM_ID,
        v.OB_NAM_PositedAt,
        v.OB_NAM_Reliability
    FROM
        @OB_NAM_Object_Name v
    JOIN
        [dbo].[OB_NAM_Object_Name_Posit] p
    ON
        p.OB_NAM_OB_ID = v.OB_NAM_OB_ID
    AND
        p.OB_NAM_Object_Name = v.OB_NAM_Object_Name
    WHERE
        OB_NAM_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect when that has another
    -- value (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[OB_NAM_Object_Name_Annex] (
        Metadata_OB_NAM,
        OB_NAM_ID,
        OB_NAM_PositedAt,
        OB_NAM_Reliability
    )
    SELECT
        v.Metadata_OB_NAM,
        e.OB_NAM_ID,
        v.OB_NAM_PositedAt,
        0
    FROM
        @OB_NAM_Object_Name v
    CROSS APPLY (
        SELECT TOP 1
            p.OB_NAM_ID,
            p.OB_NAM_Object_Name
        FROM
            [dbo].[OB_NAM_Object_Name_Posit] p
        JOIN
            [dbo].[OB_NAM_Object_Name_Annex] a
        ON
            a.OB_NAM_ID = p.OB_NAM_ID
        AND
            a.OB_NAM_PositedAt = (
                SELECT
                    max(s.OB_NAM_PositedAt)
                FROM
                    [dbo].[OB_NAM_Object_Name_Annex] s
                WHERE
                    s.OB_NAM_ID = p.OB_NAM_ID
                AND
                    s.OB_NAM_PositedAt < v.OB_NAM_PositedAt
            )
        WHERE
            p.OB_NAM_OB_ID = v.OB_NAM_OB_ID
        AND
            a.OB_NAM_Reliability = 1
        ORDER BY
            a.OB_NAM_PositedAt DESC
    ) e
    WHERE
        v.OB_NAM_StatementType in ('P', 'A')
    AND
        v.OB_NAM_Reliability = 1
    AND
        e.OB_NAM_Object_Name <> v.OB_NAM_Object_Name
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[OB_NAM_Object_Name_Annex] x
        WHERE
            x.OB_NAM_ID = e.OB_NAM_ID
        AND
            x.OB_NAM_PositedAt = v.OB_NAM_PositedAt
    );
END
GO
