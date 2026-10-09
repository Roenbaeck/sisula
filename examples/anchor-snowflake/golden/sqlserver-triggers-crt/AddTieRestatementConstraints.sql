-- TIE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------------
--
-- Ties may be prevented from storing restatements.
-- A restatement is when the same (non-key) values occurs for two adjacent points
-- in changing time.
--
-- returns 1 for one or two equal surrounding values, 0 for different surrounding values
--
-- @posit the id of the posit that should be checked
-- @posited the time when this posit was made
-- @positor the one who made the posit
-- @assertion whether this posit is positively or negatively asserted, or unreliable
--
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_holder_OB_item_GRD_grade restatement finder
-- rcSU_holder_OB_item_GRD_grade restatement constraint (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_holder_OB_item_GRD_grade', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_holder_OB_item_GRD_grade] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @SU_holder int; 
    DECLARE @OB_item int; 
    DECLARE @GRD_grade tinyint;
    SELECT
        @SU_holder = p.SU_ID_holder,
        @OB_item = p.OB_ID_item,
        @GRD_grade = p.GRD_ID_grade,
        @changed = p.SU_holder_OB_item_GRD_grade_ChangedAt
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
    WHERE
        p.SU_holder_OB_item_GRD_grade_ID = @posit;
    RETURN
        CASE WHEN @assertion = ''?'' THEN 0
        ELSE (
        SELECT
            COUNT(*)
        FROM (
            SELECT * FROM (
            SELECT TOP 1
                pre.GRD_ID_grade
            FROM
                [dbo].[rSU_holder_OB_item_GRD_grade] (
                    @positor,
                    @changed,
                    @posited
                ) pre
            WHERE
                pre.SU_ID_holder = @SU_holder
            AND
                pre.OB_ID_item = @OB_item
            AND
                pre.SU_holder_OB_item_GRD_grade_ChangedAt < @changed
            AND
                pre.SU_holder_OB_item_GRD_grade_Assertion = @assertion
            ORDER BY
                pre.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                pre.SU_holder_OB_item_GRD_grade_PositedAt DESC
            ) previous
            UNION
            SELECT * FROM (
            SELECT TOP 1
                fol.GRD_ID_grade
            FROM
                [dbo].[fSU_holder_OB_item_GRD_grade] (
                    @positor,
                    @changed,
                    @posited 
                ) fol
            WHERE
                fol.SU_ID_holder = @SU_holder
            AND
                fol.OB_ID_item = @OB_item
            AND
                fol.SU_holder_OB_item_GRD_grade_ChangedAt > @changed
            AND
                fol.SU_holder_OB_item_GRD_grade_Assertion = @assertion
            ORDER BY
                fol.SU_holder_OB_item_GRD_grade_ChangedAt ASC,
                fol.SU_holder_OB_item_GRD_grade_PositedAt DESC
            ) following
        ) s
        WHERE
            s.GRD_ID_grade = @GRD_grade
    )
    END;
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_keeper_OB_thing_GRD_rank restatement finder
-- rcSU_keeper_OB_thing_GRD_rank restatement constraint (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_keeper_OB_thing_GRD_rank', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_keeper_OB_thing_GRD_rank] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @SU_keeper int; 
    DECLARE @OB_thing int; 
    DECLARE @GRD_rank tinyint;
    SELECT
        @SU_keeper = p.SU_ID_keeper,
        @OB_thing = p.OB_ID_thing,
        @GRD_rank = p.GRD_ID_rank,
        @changed = p.SU_keeper_OB_thing_GRD_rank_ChangedAt
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
    WHERE
        p.SU_keeper_OB_thing_GRD_rank_ID = @posit;
    RETURN
        CASE WHEN @assertion = ''?'' THEN 0
        ELSE (
        SELECT
            COUNT(*)
        FROM (
            SELECT * FROM (
            SELECT TOP 1
                pre.GRD_ID_rank
            FROM
                [dbo].[rSU_keeper_OB_thing_GRD_rank] (
                    @positor,
                    @changed,
                    @posited
                ) pre
            WHERE
                pre.SU_ID_keeper = @SU_keeper
            AND
                pre.OB_ID_thing = @OB_thing
            AND
                pre.SU_keeper_OB_thing_GRD_rank_ChangedAt < @changed
            AND
                pre.SU_keeper_OB_thing_GRD_rank_Assertion = @assertion
            ORDER BY
                pre.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                pre.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
            ) previous
            UNION
            SELECT * FROM (
            SELECT TOP 1
                fol.GRD_ID_rank
            FROM
                [dbo].[fSU_keeper_OB_thing_GRD_rank] (
                    @positor,
                    @changed,
                    @posited 
                ) fol
            WHERE
                fol.SU_ID_keeper = @SU_keeper
            AND
                fol.OB_ID_thing = @OB_thing
            AND
                fol.SU_keeper_OB_thing_GRD_rank_ChangedAt > @changed
            AND
                fol.SU_keeper_OB_thing_GRD_rank_Assertion = @assertion
            ORDER BY
                fol.SU_keeper_OB_thing_GRD_rank_ChangedAt ASC,
                fol.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
            ) following
        ) s
        WHERE
            s.GRD_ID_rank = @GRD_rank
    )
    END;
    END
    ');
    ALTER TABLE [dbo].[SU_keeper_OB_thing_GRD_rank_Annex]
    ADD CONSTRAINT [rcSU_keeper_OB_thing_GRD_rank] CHECK (
        [dbo].[rfSU_keeper_OB_thing_GRD_rank] (
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_Assertion
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_partner_SU_with restatement finder
-- rcSU_partner_SU_with restatement constraint (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_partner_SU_with', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_partner_SU_with] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @SU_partner int; 
    DECLARE @SU_with int; 
    SELECT
        @SU_partner = p.SU_ID_partner,
        @SU_with = p.SU_ID_with,
        @changed = p.SU_partner_SU_with_ChangedAt
    FROM
        [dbo].[SU_partner_SU_with_Posit] p
    WHERE
        p.SU_partner_SU_with_ID = @posit;
    RETURN
        CASE WHEN @assertion = ''?'' THEN 0
        ELSE (
        SELECT
            COUNT(*)
        FROM (
            SELECT * FROM (
            SELECT TOP 1
                pre.SU_ID_partner,
                pre.SU_ID_with
            FROM
                [dbo].[rSU_partner_SU_with] (
                    @positor,
                    @changed,
                    @posited
                ) pre
            WHERE
            (
                    pre.SU_ID_partner = @SU_partner
                OR
                    pre.SU_ID_with = @SU_with
            )
            AND
                pre.SU_partner_SU_with_ChangedAt < @changed
            AND
                pre.SU_partner_SU_with_Assertion = @assertion
            ORDER BY
                pre.SU_partner_SU_with_ChangedAt DESC,
                pre.SU_partner_SU_with_PositedAt DESC
            ) previous
            UNION
            SELECT * FROM (
            SELECT TOP 1
                fol.SU_ID_partner,
                fol.SU_ID_with
            FROM
                [dbo].[fSU_partner_SU_with] (
                    @positor,
                    @changed,
                    @posited 
                ) fol
            WHERE
            (
                    fol.SU_ID_partner = @SU_partner
                OR
                    fol.SU_ID_with = @SU_with
            )
            AND
                fol.SU_partner_SU_with_ChangedAt > @changed
            AND
                fol.SU_partner_SU_with_Assertion = @assertion
            ORDER BY
                fol.SU_partner_SU_with_ChangedAt ASC,
                fol.SU_partner_SU_with_PositedAt DESC
            ) following
        ) s
        WHERE
            s.SU_ID_partner = @SU_partner
        AND
            s.SU_ID_with = @SU_with
    )
    END;
    END
    ');
END
GO
