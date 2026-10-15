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
-- rt_SU_keeper_OB_thing_GRD_rank (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_SU_keeper_OB_thing_GRD_rank', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_SU_keeper_OB_thing_GRD_rank];
GO
CREATE TRIGGER [dbo].[rt_SU_keeper_OB_thing_GRD_rank] ON [dbo].[SU_keeper_OB_thing_GRD_rank_Annex]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @inserted TABLE (
        SU_keeper_OB_thing_GRD_rank_ID int not null,
        Metadata_SU_keeper_OB_thing_GRD_rank int not null,
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_PositedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_Reliability decimal(5,2) not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null,
        primary key (
            SU_ID_keeper asc,
            OB_ID_thing asc,
            SU_keeper_OB_thing_GRD_rank_ChangedAt desc,
            SU_keeper_OB_thing_GRD_rank_PositedAt desc,
            SU_keeper_OB_thing_GRD_rank_Reliability desc
        ),
        unique (
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_PositedAt
        )
    );
    INSERT INTO @inserted (
        SU_keeper_OB_thing_GRD_rank_ID,
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        i.SU_keeper_OB_thing_GRD_rank_ID,
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        i.SU_keeper_OB_thing_GRD_rank_PositedAt,
        i.SU_keeper_OB_thing_GRD_rank_Reliability,
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank
    FROM
        inserted i
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
    ON
        p.SU_keeper_OB_thing_GRD_rank_ID = i.SU_keeper_OB_thing_GRD_rank_ID; -- the posit has already been created
    INSERT INTO @inserted (
        SU_keeper_OB_thing_GRD_rank_ID,
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        p.SU_keeper_OB_thing_GRD_rank_ID,
        p.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        p.SU_keeper_OB_thing_GRD_rank_PositedAt,
        p.SU_keeper_OB_thing_GRD_rank_Reliability,
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank
    FROM (
        SELECT DISTINCT
            SU_ID_keeper,
            OB_ID_thing
        FROM
            @inserted
    ) i
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank] p
    ON
        p.SU_ID_keeper = i.SU_ID_keeper
    AND
        p.OB_ID_thing = i.OB_ID_thing
    LEFT JOIN
        @inserted x
    ON
        x.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
    AND
        x.SU_keeper_OB_thing_GRD_rank_PositedAt = p.SU_keeper_OB_thing_GRD_rank_PositedAt
    WHERE
        x.SU_keeper_OB_thing_GRD_rank_ID is null;
    -- no need to check retracted information
    DELETE a
    FROM
        @inserted a
    OUTER APPLY (
        SELECT TOP 1
            x.SU_keeper_OB_thing_GRD_rank_Reliability
        FROM
            @inserted x
        WHERE
            x.SU_keeper_OB_thing_GRD_rank_ID = a.SU_keeper_OB_thing_GRD_rank_ID
        AND
            x.SU_keeper_OB_thing_GRD_rank_PositedAt < a.SU_keeper_OB_thing_GRD_rank_PositedAt
        ORDER BY
            x.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
    ) pre
    OUTER APPLY (
        SELECT TOP 1
            x.SU_keeper_OB_thing_GRD_rank_Reliability
        FROM
            @inserted x
        WHERE
            x.SU_keeper_OB_thing_GRD_rank_ID = a.SU_keeper_OB_thing_GRD_rank_ID
        AND
            x.SU_keeper_OB_thing_GRD_rank_PositedAt > a.SU_keeper_OB_thing_GRD_rank_PositedAt
        ORDER BY
            x.SU_keeper_OB_thing_GRD_rank_PositedAt ASC
    ) fol
    WHERE
        (a.SU_keeper_OB_thing_GRD_rank_Reliability = 1 AND fol.SU_keeper_OB_thing_GRD_rank_Reliability = 0)
    OR
        (a.SU_keeper_OB_thing_GRD_rank_Reliability = 0 AND pre.SU_keeper_OB_thing_GRD_rank_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @inserted a
        CROSS APPLY (
            SELECT TOP 1
                SU_ID_keeper,
                OB_ID_thing,
                GRD_ID_rank,
                SU_keeper_OB_thing_GRD_rank_ChangedAt
            FROM
                SU_keeper_OB_thing_GRD_rank h
            WHERE
                h.SU_ID_keeper = a.SU_ID_keeper
            AND
                h.OB_ID_thing = a.OB_ID_thing
            AND
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt < a.SU_keeper_OB_thing_GRD_rank_ChangedAt
            ORDER BY
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                h.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
                h.SU_keeper_OB_thing_GRD_rank_Reliability DESC
        ) pre
        WHERE
            a.SU_ID_keeper = pre.SU_ID_keeper
        AND
            a.OB_ID_thing = pre.OB_ID_thing
        AND
            a.GRD_ID_rank = pre.GRD_ID_rank
        AND
            a.SU_keeper_OB_thing_GRD_rank_Reliability = 1
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in SU_keeper_OB_thing_GRD_rank for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
