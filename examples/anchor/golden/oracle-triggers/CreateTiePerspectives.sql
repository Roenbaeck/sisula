-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- tie perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pAC_part_EV_in(TIMESTAMP '2020-01-01 00:00:00').
--
-- A historized tie shows, for each identifier (for each anchor, in a tie without identifiers), the rows that have the latest
-- changing time: that is worked out with an analytic MAX in an inline view, whose column holds the latest time.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_holder_OB_item_GRD_grade (
    Metadata_SU_holder_OB_item_GRD_grade,
    Deletable_SU_holder_OB_item_GRD_grade,
    SU_holder_OB_item_GRD_grade_ChangedAt,
    SU_ID_holder,
    OB_ID_item,
    grade_GRD_Grade,
    grade_Metadata_GRD,
    GRD_ID_grade
)
AS
SELECT
    tie.Metadata_SU_holder_OB_item_GRD_grade,
    CAST(NULL AS number(1)),
    tie.SU_holder_OB_item_GRD_grade_ChangedAt,
    tie.SU_ID_holder,
    tie.OB_ID_item,
    "GRD_grade".GRD_Grade AS grade_GRD_Grade,
    "GRD_grade".Metadata_GRD AS grade_Metadata_GRD,
    tie.GRD_ID_grade
FROM
    (
        SELECT
            t.*,
            MAX(t.SU_holder_OB_item_GRD_grade_ChangedAt) OVER (
                PARTITION BY
                    t.SU_ID_holder,
                    t.OB_ID_item
            ) AS latestTime
        FROM
            SU_holder_OB_item_GRD_grade t
    ) tie
LEFT JOIN
    GRD_Grade "GRD_grade"
ON
    "GRD_grade".GRD_ID = tie.GRD_ID_grade
WHERE
    tie.SU_holder_OB_item_GRD_grade_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_holder_OB_item_GRD_grade (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_SU_holder_OB_item_GRD_grade,
            tie.SU_holder_OB_item_GRD_grade_ChangedAt,
            tie.SU_ID_holder,
            tie.OB_ID_item,
            "GRD_grade".GRD_Grade AS grade_GRD_Grade,
            "GRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            tie.GRD_ID_grade
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.SU_holder_OB_item_GRD_grade_ChangedAt) OVER (
                        PARTITION BY
                            t.SU_ID_holder,
                            t.OB_ID_item
                    ) AS latestTime
                FROM
                    SU_holder_OB_item_GRD_grade t
                WHERE
                    t.SU_holder_OB_item_GRD_grade_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            GRD_Grade "GRD_grade"
        ON
            "GRD_grade".GRD_ID = tie.GRD_ID_grade
        WHERE
            tie.SU_holder_OB_item_GRD_grade_ChangedAt = tie.latestTime
    ]';
END pSU_holder_OB_item_GRD_grade;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nSU_holder_OB_item_GRD_grade
AS
SELECT
    *
FROM
    pSU_holder_OB_item_GRD_grade(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dSU_holder_OB_item_GRD_grade (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_SU_holder_OB_item_GRD_grade,
            tie.SU_holder_OB_item_GRD_grade_ChangedAt,
            tie.SU_ID_holder,
            tie.OB_ID_item,
            "GRD_grade".GRD_Grade AS grade_GRD_Grade,
            "GRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            tie.GRD_ID_grade
        FROM
            SU_holder_OB_item_GRD_grade tie
        LEFT JOIN
            GRD_Grade "GRD_grade"
        ON
            "GRD_grade".GRD_ID = tie.GRD_ID_grade
        WHERE
            tie.SU_holder_OB_item_GRD_grade_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_holder_OB_item_GRD_grade;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_keeper_OB_thing_GRD_rank (
    Metadata_SU_keeper_OB_thing_GRD_rank,
    SU_keeper_OB_thing_GRD_rank_ChangedAt,
    SU_ID_keeper,
    OB_ID_thing,
    rank_GRD_Grade,
    rank_Metadata_GRD,
    GRD_ID_rank
)
AS
SELECT
    tie.Metadata_SU_keeper_OB_thing_GRD_rank,
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    tie.SU_ID_keeper,
    tie.OB_ID_thing,
    "GRD_rank".GRD_Grade AS rank_GRD_Grade,
    "GRD_rank".Metadata_GRD AS rank_Metadata_GRD,
    tie.GRD_ID_rank
FROM
    (
        SELECT
            t.*,
            MAX(t.SU_keeper_OB_thing_GRD_rank_ChangedAt) OVER (
                PARTITION BY
                    t.SU_ID_keeper,
                    t.OB_ID_thing
            ) AS latestTime
        FROM
            SU_keeper_OB_thing_GRD_rank t
    ) tie
LEFT JOIN
    GRD_Grade "GRD_rank"
ON
    "GRD_rank".GRD_ID = tie.GRD_ID_rank
WHERE
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_keeper_OB_thing_GRD_rank (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_SU_keeper_OB_thing_GRD_rank,
            tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            tie.SU_ID_keeper,
            tie.OB_ID_thing,
            "GRD_rank".GRD_Grade AS rank_GRD_Grade,
            "GRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            tie.GRD_ID_rank
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.SU_keeper_OB_thing_GRD_rank_ChangedAt) OVER (
                        PARTITION BY
                            t.SU_ID_keeper,
                            t.OB_ID_thing
                    ) AS latestTime
                FROM
                    SU_keeper_OB_thing_GRD_rank t
                WHERE
                    t.SU_keeper_OB_thing_GRD_rank_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            GRD_Grade "GRD_rank"
        ON
            "GRD_rank".GRD_ID = tie.GRD_ID_rank
        WHERE
            tie.SU_keeper_OB_thing_GRD_rank_ChangedAt = tie.latestTime
    ]';
END pSU_keeper_OB_thing_GRD_rank;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nSU_keeper_OB_thing_GRD_rank
AS
SELECT
    *
FROM
    pSU_keeper_OB_thing_GRD_rank(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dSU_keeper_OB_thing_GRD_rank (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_SU_keeper_OB_thing_GRD_rank,
            tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            tie.SU_ID_keeper,
            tie.OB_ID_thing,
            "GRD_rank".GRD_Grade AS rank_GRD_Grade,
            "GRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            tie.GRD_ID_rank
        FROM
            SU_keeper_OB_thing_GRD_rank tie
        LEFT JOIN
            GRD_Grade "GRD_rank"
        ON
            "GRD_rank".GRD_ID = tie.GRD_ID_rank
        WHERE
            tie.SU_keeper_OB_thing_GRD_rank_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_keeper_OB_thing_GRD_rank;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lOB_part_SU_owner (
    Metadata_OB_part_SU_owner,
    Deletable_OB_part_SU_owner,
    OB_ID_part,
    SU_ID_owner
)
AS
SELECT
    tie.Metadata_OB_part_SU_owner,
    CAST(NULL AS number(1)),
    tie.OB_ID_part,
    tie.SU_ID_owner
FROM
    OB_part_SU_owner tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pOB_part_SU_owner (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_OB_part_SU_owner,
            tie.OB_ID_part,
            tie.SU_ID_owner
        FROM
            OB_part_SU_owner tie
    ]';
END pOB_part_SU_owner;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nOB_part_SU_owner
AS
SELECT
    *
FROM
    pOB_part_SU_owner(CAST(current_timestamp AS timestamp))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_partner_SU_with (
    Metadata_SU_partner_SU_with,
    SU_partner_SU_with_ChangedAt,
    SU_ID_partner,
    SU_ID_with
)
AS
SELECT
    tie.Metadata_SU_partner_SU_with,
    tie.SU_partner_SU_with_ChangedAt,
    tie.SU_ID_partner,
    tie.SU_ID_with
FROM
    (
        SELECT
            t.*,
            MAX(t.SU_partner_SU_with_ChangedAt) OVER (PARTITION BY t.SU_ID_partner) AS latestSU_ID_partner,
            MAX(t.SU_partner_SU_with_ChangedAt) OVER (PARTITION BY t.SU_ID_with) AS latestSU_ID_with
        FROM
            SU_partner_SU_with t
    ) tie
WHERE
    tie.SU_partner_SU_with_ChangedAt = tie.latestSU_ID_partner
AND
    tie.SU_partner_SU_with_ChangedAt = tie.latestSU_ID_with
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_partner_SU_with (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_SU_partner_SU_with,
            tie.SU_partner_SU_with_ChangedAt,
            tie.SU_ID_partner,
            tie.SU_ID_with
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.SU_partner_SU_with_ChangedAt) OVER (PARTITION BY t.SU_ID_partner) AS latestSU_ID_partner,
                    MAX(t.SU_partner_SU_with_ChangedAt) OVER (PARTITION BY t.SU_ID_with) AS latestSU_ID_with
                FROM
                    SU_partner_SU_with t
                WHERE
                    t.SU_partner_SU_with_ChangedAt <= changingTimepoint
            ) tie
        WHERE
            tie.SU_partner_SU_with_ChangedAt = tie.latestSU_ID_partner
        AND
            tie.SU_partner_SU_with_ChangedAt = tie.latestSU_ID_with
    ]';
END pSU_partner_SU_with;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nSU_partner_SU_with
AS
SELECT
    *
FROM
    pSU_partner_SU_with(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dSU_partner_SU_with (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_SU_partner_SU_with,
            tie.SU_partner_SU_with_ChangedAt,
            tie.SU_ID_partner,
            tie.SU_ID_with
        FROM
            SU_partner_SU_with tie
        WHERE
            tie.SU_partner_SU_with_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_partner_SU_with;
/
