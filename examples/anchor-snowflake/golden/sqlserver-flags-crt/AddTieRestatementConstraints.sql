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
IF Object_ID('ties.rfAC_partner_AC_with_ONG_currently', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rfAC_partner_AC_with_ONG_currently] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @AC_partner smallint; 
    DECLARE @AC_with smallint; 
    DECLARE @ONG_currently tinyint;
    SELECT
        @AC_partner = p.AC_ID_partner,
        @AC_with = p.AC_ID_with,
        @ONG_currently = p.ONG_ID_currently,
        @changed = p.AC_partner_AC_with_ONG_currently_ChangedAt
    FROM
        [ties].[AC_partner_AC_with_ONG_currently_Posit] p
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
                [ties].[rAC_partner_AC_with_ONG_currently] (
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
                [ties].[fAC_partner_AC_with_ONG_currently] (
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
IF Object_ID('ties.rfAC_part_PR_in_RAT_got', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rfAC_part_PR_in_RAT_got] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @AC_part smallint; 
    DECLARE @PR_in bigint; 
    DECLARE @RAT_got tinyint;
    SELECT
        @AC_part = p.AC_ID_part,
        @PR_in = p.PR_ID_in,
        @RAT_got = p.RAT_ID_got,
        @changed = p.AC_part_PR_in_RAT_got_ChangedAt
    FROM
        [ties].[AC_part_PR_in_RAT_got_Posit] p
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
                [ties].[rAC_part_PR_in_RAT_got] (
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
                [ties].[fAC_part_PR_in_RAT_got] (
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
    ALTER TABLE [ties].[AC_part_PR_in_RAT_got_Annex]
    ADD CONSTRAINT [rcAC_part_PR_in_RAT_got] CHECK (
        [ties].[rfAC_part_PR_in_RAT_got] (
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Positor,
            AC_part_PR_in_RAT_got_Assertion
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfPR_content_ST_location_EV_of restatement finder
-- rcPR_content_ST_location_EV_of restatement constraint (available only in ties that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rfPR_content_ST_location_EV_of', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rfPR_content_ST_location_EV_of] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @changed datetime2;
    DECLARE @PR_content bigint; 
    DECLARE @ST_location int; 
    DECLARE @EV_of numeric(12,0); 
    SELECT
        @PR_content = p.PR_ID_content,
        @ST_location = p.ST_ID_location,
        @EV_of = p.EV_ID_of,
        @changed = p.PR_content_ST_location_EV_of_ChangedAt
    FROM
        [ties].[PR_content_ST_location_EV_of_Posit] p
    WHERE
        p.PR_content_ST_location_EV_of_ID = @posit;
    RETURN
        CASE WHEN @assertion = ''?'' THEN 0
        ELSE (
        SELECT
            COUNT(*)
        FROM (
            SELECT * FROM (
            SELECT TOP 1
                pre.PR_ID_content,
                pre.ST_ID_location,
                pre.EV_ID_of
            FROM
                [ties].[rPR_content_ST_location_EV_of] (
                    @positor,
                    @changed,
                    @posited
                ) pre
            WHERE
            (
                    pre.PR_ID_content = @PR_content
                OR
                    pre.ST_ID_location = @ST_location
            )
            AND
                pre.PR_content_ST_location_EV_of_ChangedAt < @changed
            AND
                pre.PR_content_ST_location_EV_of_Assertion = @assertion
            ORDER BY
                pre.PR_content_ST_location_EV_of_ChangedAt DESC,
                pre.PR_content_ST_location_EV_of_PositedAt DESC
            ) previous
            UNION
            SELECT * FROM (
            SELECT TOP 1
                fol.PR_ID_content,
                fol.ST_ID_location,
                fol.EV_ID_of
            FROM
                [ties].[fPR_content_ST_location_EV_of] (
                    @positor,
                    @changed,
                    @posited 
                ) fol
            WHERE
            (
                    fol.PR_ID_content = @PR_content
                OR
                    fol.ST_ID_location = @ST_location
            )
            AND
                fol.PR_content_ST_location_EV_of_ChangedAt > @changed
            AND
                fol.PR_content_ST_location_EV_of_Assertion = @assertion
            ORDER BY
                fol.PR_content_ST_location_EV_of_ChangedAt ASC,
                fol.PR_content_ST_location_EV_of_PositedAt DESC
            ) following
        ) s
        WHERE
            s.PR_ID_content = @PR_content
        AND
            s.ST_ID_location = @ST_location
        AND
            s.EV_ID_of = @EV_of
    )
    END;
    END
    ');
    ALTER TABLE [ties].[PR_content_ST_location_EV_of_Annex]
    ADD CONSTRAINT [rcPR_content_ST_location_EV_of] CHECK (
        [ties].[rfPR_content_ST_location_EV_of] (
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Positor,
            PR_content_ST_location_EV_of_Assertion
        ) = 0
    );
END
GO
