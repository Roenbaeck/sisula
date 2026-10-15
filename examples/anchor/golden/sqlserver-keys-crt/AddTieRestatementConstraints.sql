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
-- rfAC_partner_AC_with_ONG_currently restatement finder
-- rcAC_partner_AC_with_ONG_currently restatement constraint (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfAC_partner_AC_with_ONG_currently', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfAC_partner_AC_with_ONG_currently] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @AC_partner int; 
    DECLARE @AC_with int; 
    DECLARE @ONG_currently tinyint;
    SELECT
        @AC_partner = p.AC_ID_partner,
        @AC_with = p.AC_ID_with,
        @ONG_currently = p.ONG_ID_currently,
        @changed = p.AC_partner_AC_with_ONG_currently_ChangedAt
    FROM
        [dbo].[AC_partner_AC_with_ONG_currently_Posit] p
    WHERE
        p.AC_partner_AC_with_ONG_currently_ID = @posit;
    RETURN
        CASE WHEN @assertion = ''?'' THEN 0
        ELSE (
        SELECT
            COUNT(*)
        FROM (
            SELECT * FROM (
            SELECT TOP 1
                pre.AC_ID_partner,
                pre.AC_ID_with,
                pre.ONG_ID_currently
            FROM
                [dbo].[rAC_partner_AC_with_ONG_currently] (
                    @positor,
                    @changed,
                    @posited
                ) pre
            WHERE
            (
                    pre.AC_ID_partner = @AC_partner
                OR
                    pre.AC_ID_with = @AC_with
            )
            AND
                pre.AC_partner_AC_with_ONG_currently_ChangedAt < @changed
            AND
                pre.AC_partner_AC_with_ONG_currently_Assertion = @assertion
            ORDER BY
                pre.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                pre.AC_partner_AC_with_ONG_currently_PositedAt DESC
            ) previous
            UNION
            SELECT * FROM (
            SELECT TOP 1
                fol.AC_ID_partner,
                fol.AC_ID_with,
                fol.ONG_ID_currently
            FROM
                [dbo].[fAC_partner_AC_with_ONG_currently] (
                    @positor,
                    @changed,
                    @posited 
                ) fol
            WHERE
            (
                    fol.AC_ID_partner = @AC_partner
                OR
                    fol.AC_ID_with = @AC_with
            )
            AND
                fol.AC_partner_AC_with_ONG_currently_ChangedAt > @changed
            AND
                fol.AC_partner_AC_with_ONG_currently_Assertion = @assertion
            ORDER BY
                fol.AC_partner_AC_with_ONG_currently_ChangedAt ASC,
                fol.AC_partner_AC_with_ONG_currently_PositedAt DESC
            ) following
        ) s
        WHERE
            s.AC_ID_partner = @AC_partner
        AND
            s.AC_ID_with = @AC_with
        AND
            s.ONG_ID_currently = @ONG_currently
    )
    END;
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfAC_part_PR_in_RAT_got restatement finder
-- rcAC_part_PR_in_RAT_got restatement constraint (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfAC_part_PR_in_RAT_got', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfAC_part_PR_in_RAT_got] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @AC_part int; 
    DECLARE @PR_in int; 
    DECLARE @RAT_got tinyint;
    SELECT
        @AC_part = p.AC_ID_part,
        @PR_in = p.PR_ID_in,
        @RAT_got = p.RAT_ID_got,
        @changed = p.AC_part_PR_in_RAT_got_ChangedAt
    FROM
        [dbo].[AC_part_PR_in_RAT_got_Posit] p
    WHERE
        p.AC_part_PR_in_RAT_got_ID = @posit;
    RETURN
        CASE WHEN @assertion = ''?'' THEN 0
        ELSE (
        SELECT
            COUNT(*)
        FROM (
            SELECT * FROM (
            SELECT TOP 1
                pre.RAT_ID_got
            FROM
                [dbo].[rAC_part_PR_in_RAT_got] (
                    @positor,
                    @changed,
                    @posited
                ) pre
            WHERE
                pre.AC_ID_part = @AC_part
            AND
                pre.PR_ID_in = @PR_in
            AND
                pre.AC_part_PR_in_RAT_got_ChangedAt < @changed
            AND
                pre.AC_part_PR_in_RAT_got_Assertion = @assertion
            ORDER BY
                pre.AC_part_PR_in_RAT_got_ChangedAt DESC,
                pre.AC_part_PR_in_RAT_got_PositedAt DESC
            ) previous
            UNION
            SELECT * FROM (
            SELECT TOP 1
                fol.RAT_ID_got
            FROM
                [dbo].[fAC_part_PR_in_RAT_got] (
                    @positor,
                    @changed,
                    @posited 
                ) fol
            WHERE
                fol.AC_ID_part = @AC_part
            AND
                fol.PR_ID_in = @PR_in
            AND
                fol.AC_part_PR_in_RAT_got_ChangedAt > @changed
            AND
                fol.AC_part_PR_in_RAT_got_Assertion = @assertion
            ORDER BY
                fol.AC_part_PR_in_RAT_got_ChangedAt ASC,
                fol.AC_part_PR_in_RAT_got_PositedAt DESC
            ) following
        ) s
        WHERE
            s.RAT_ID_got = @RAT_got
    )
    END;
    END
    ');
END
GO
