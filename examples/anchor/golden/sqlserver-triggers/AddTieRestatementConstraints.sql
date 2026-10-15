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
CREATE TRIGGER [dbo].[rt_SU_keeper_OB_thing_GRD_rank] ON [dbo].[SU_keeper_OB_thing_GRD_rank]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @inserted TABLE (
        Metadata_SU_keeper_OB_thing_GRD_rank int not null,
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null,
        primary key (
            SU_ID_keeper asc,
            OB_ID_thing asc,
            SU_keeper_OB_thing_GRD_rank_ChangedAt desc
        )
    );
    INSERT INTO @inserted (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    FROM
        inserted;
    INSERT INTO @inserted (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        p.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
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
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            @inserted x
        WHERE
            x.SU_keeper_OB_thing_GRD_rank_ChangedAt = p.SU_keeper_OB_thing_GRD_rank_ChangedAt
        AND
            x.SU_ID_keeper = i.SU_ID_keeper
        AND
            x.OB_ID_thing = i.OB_ID_thing
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @inserted i
        CROSS APPLY (
            SELECT TOP 1
                SU_ID_keeper,
                OB_ID_thing,
                GRD_ID_rank,
                SU_keeper_OB_thing_GRD_rank_ChangedAt
            FROM
                @inserted h
            WHERE
                h.SU_ID_keeper = i.SU_ID_keeper
            AND
                h.OB_ID_thing = i.OB_ID_thing
            AND
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt < i.SU_keeper_OB_thing_GRD_rank_ChangedAt
            ORDER BY
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC
        ) pre
        WHERE
            i.SU_ID_keeper = pre.SU_ID_keeper
        AND
            i.OB_ID_thing = pre.OB_ID_thing
        AND
            i.GRD_ID_rank = pre.GRD_ID_rank
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
