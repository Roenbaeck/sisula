-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_part_PR_in_RAT_got(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinder of a tie is not called in the macros, what it does is written out in them: the posit and annex of the tie
-- joined, the annex row with the latest positing time picked for each posit, the posits that are not reliable left out.
--
-- The latest and now perspectives are views over the point-in-time macro.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tSU_holder_OB_item_GRD_grade (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_holder_OB_item_GRD_grade_ID,
            t.Metadata_SU_holder_OB_item_GRD_grade,
            t.SU_holder_OB_item_GRD_grade_ChangedAt,
            t.SU_holder_OB_item_GRD_grade_PositedAt,
            t.SU_holder_OB_item_GRD_grade_Reliability,
            t.SU_ID_holder,
            t.OB_ID_item,
            "kGRD_grade".GRD_Grade AS grade_GRD_Grade,
            "kGRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            t.GRD_ID_grade
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_holder,
                        r.OB_ID_item
                    ORDER BY
                        r.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_PositedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_holder_OB_item_GRD_grade,
                    po.SU_holder_OB_item_GRD_grade_ID,
                    po.SU_ID_holder,
                    po.OB_ID_item,
                    po.GRD_ID_grade,
                    po.SU_holder_OB_item_GRD_grade_ChangedAt,
                    an.SU_holder_OB_item_GRD_grade_PositedAt,
                    an.SU_holder_OB_item_GRD_grade_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_holder_OB_item_GRD_grade_ID
                        ORDER BY an.SU_holder_OB_item_GRD_grade_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_holder_OB_item_GRD_grade_Posit po
                JOIN
                    SU_holder_OB_item_GRD_grade_Annex an
                ON
                    an.SU_holder_OB_item_GRD_grade_ID = po.SU_holder_OB_item_GRD_grade_ID
                WHERE
                    po.SU_holder_OB_item_GRD_grade_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_holder_OB_item_GRD_grade_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_holder_OB_item_GRD_grade_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_grade"
        ON
            "kGRD_grade".GRD_ID = t.GRD_ID_grade
        WHERE
            t.latestPosit = 1
    ]';
END tSU_holder_OB_item_GRD_grade;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_holder_OB_item_GRD_grade (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_holder_OB_item_GRD_grade_ID,
            t.Metadata_SU_holder_OB_item_GRD_grade,
            t.SU_holder_OB_item_GRD_grade_ChangedAt,
            t.SU_holder_OB_item_GRD_grade_PositedAt,
            t.SU_holder_OB_item_GRD_grade_Reliability,
            t.SU_ID_holder,
            t.OB_ID_item,
            "kGRD_grade".GRD_Grade AS grade_GRD_Grade,
            "kGRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            t.GRD_ID_grade
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_holder,
                        r.OB_ID_item
                    ORDER BY
                        r.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_PositedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_holder_OB_item_GRD_grade,
                    po.SU_holder_OB_item_GRD_grade_ID,
                    po.SU_ID_holder,
                    po.OB_ID_item,
                    po.GRD_ID_grade,
                    po.SU_holder_OB_item_GRD_grade_ChangedAt,
                    an.SU_holder_OB_item_GRD_grade_PositedAt,
                    an.SU_holder_OB_item_GRD_grade_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_holder_OB_item_GRD_grade_ID
                        ORDER BY an.SU_holder_OB_item_GRD_grade_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_holder_OB_item_GRD_grade_Posit po
                JOIN
                    SU_holder_OB_item_GRD_grade_Annex an
                ON
                    an.SU_holder_OB_item_GRD_grade_ID = po.SU_holder_OB_item_GRD_grade_ID
                WHERE
                    po.SU_holder_OB_item_GRD_grade_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_holder_OB_item_GRD_grade_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_holder_OB_item_GRD_grade_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_grade"
        ON
            "kGRD_grade".GRD_ID = t.GRD_ID_grade
        WHERE
            t.latestPosit = 1
    ]';
END pSU_holder_OB_item_GRD_grade;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_holder_OB_item_GRD_grade
AS
SELECT
    *
FROM
    pSU_holder_OB_item_GRD_grade(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
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
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
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
            t.SU_holder_OB_item_GRD_grade_ID,
            t.Metadata_SU_holder_OB_item_GRD_grade,
            t.SU_holder_OB_item_GRD_grade_ChangedAt,
            t.SU_holder_OB_item_GRD_grade_PositedAt,
            t.SU_holder_OB_item_GRD_grade_Reliability,
            t.SU_ID_holder,
            t.OB_ID_item,
            "kGRD_grade".GRD_Grade AS grade_GRD_Grade,
            "kGRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            t.GRD_ID_grade
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_holder,
                        r.OB_ID_item
                    ORDER BY
                        r.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_PositedAt DESC,
                        r.SU_holder_OB_item_GRD_grade_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_holder_OB_item_GRD_grade,
                    po.SU_holder_OB_item_GRD_grade_ID,
                    po.SU_ID_holder,
                    po.OB_ID_item,
                    po.GRD_ID_grade,
                    po.SU_holder_OB_item_GRD_grade_ChangedAt,
                    an.SU_holder_OB_item_GRD_grade_PositedAt,
                    an.SU_holder_OB_item_GRD_grade_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_holder_OB_item_GRD_grade_ID
                        ORDER BY an.SU_holder_OB_item_GRD_grade_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_holder_OB_item_GRD_grade_Posit po
                JOIN
                    SU_holder_OB_item_GRD_grade_Annex an
                ON
                    an.SU_holder_OB_item_GRD_grade_ID = po.SU_holder_OB_item_GRD_grade_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_holder_OB_item_GRD_grade_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_grade"
        ON
            "kGRD_grade".GRD_ID = t.GRD_ID_grade
        WHERE
            t.latestPosit = 1
        AND
            t.SU_holder_OB_item_GRD_grade_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_holder_OB_item_GRD_grade;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tSU_keeper_OB_thing_GRD_rank (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_keeper_OB_thing_GRD_rank_ID,
            t.Metadata_SU_keeper_OB_thing_GRD_rank,
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            t.SU_keeper_OB_thing_GRD_rank_PositedAt,
            t.SU_keeper_OB_thing_GRD_rank_Reliability,
            t.SU_ID_keeper,
            t.OB_ID_thing,
            "kGRD_rank".GRD_Grade AS rank_GRD_Grade,
            "kGRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            t.GRD_ID_rank
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_keeper,
                        r.OB_ID_thing
                    ORDER BY
                        r.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_keeper_OB_thing_GRD_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ID,
                    po.SU_ID_keeper,
                    po.OB_ID_thing,
                    po.GRD_ID_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                    an.SU_keeper_OB_thing_GRD_rank_PositedAt,
                    an.SU_keeper_OB_thing_GRD_rank_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_keeper_OB_thing_GRD_rank_ID
                        ORDER BY an.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_keeper_OB_thing_GRD_rank_Posit po
                JOIN
                    SU_keeper_OB_thing_GRD_rank_Annex an
                ON
                    an.SU_keeper_OB_thing_GRD_rank_ID = po.SU_keeper_OB_thing_GRD_rank_ID
                WHERE
                    po.SU_keeper_OB_thing_GRD_rank_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_keeper_OB_thing_GRD_rank_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_keeper_OB_thing_GRD_rank_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_rank"
        ON
            "kGRD_rank".GRD_ID = t.GRD_ID_rank
        WHERE
            t.latestPosit = 1
    ]';
END tSU_keeper_OB_thing_GRD_rank;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_keeper_OB_thing_GRD_rank (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_keeper_OB_thing_GRD_rank_ID,
            t.Metadata_SU_keeper_OB_thing_GRD_rank,
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            t.SU_keeper_OB_thing_GRD_rank_PositedAt,
            t.SU_keeper_OB_thing_GRD_rank_Reliability,
            t.SU_ID_keeper,
            t.OB_ID_thing,
            "kGRD_rank".GRD_Grade AS rank_GRD_Grade,
            "kGRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            t.GRD_ID_rank
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_keeper,
                        r.OB_ID_thing
                    ORDER BY
                        r.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_keeper_OB_thing_GRD_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ID,
                    po.SU_ID_keeper,
                    po.OB_ID_thing,
                    po.GRD_ID_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                    an.SU_keeper_OB_thing_GRD_rank_PositedAt,
                    an.SU_keeper_OB_thing_GRD_rank_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_keeper_OB_thing_GRD_rank_ID
                        ORDER BY an.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_keeper_OB_thing_GRD_rank_Posit po
                JOIN
                    SU_keeper_OB_thing_GRD_rank_Annex an
                ON
                    an.SU_keeper_OB_thing_GRD_rank_ID = po.SU_keeper_OB_thing_GRD_rank_ID
                WHERE
                    po.SU_keeper_OB_thing_GRD_rank_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_keeper_OB_thing_GRD_rank_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_keeper_OB_thing_GRD_rank_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_rank"
        ON
            "kGRD_rank".GRD_ID = t.GRD_ID_rank
        WHERE
            t.latestPosit = 1
    ]';
END pSU_keeper_OB_thing_GRD_rank;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_keeper_OB_thing_GRD_rank
AS
SELECT
    *
FROM
    pSU_keeper_OB_thing_GRD_rank(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
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
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
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
            t.SU_keeper_OB_thing_GRD_rank_ID,
            t.Metadata_SU_keeper_OB_thing_GRD_rank,
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            t.SU_keeper_OB_thing_GRD_rank_PositedAt,
            t.SU_keeper_OB_thing_GRD_rank_Reliability,
            t.SU_ID_keeper,
            t.OB_ID_thing,
            "kGRD_rank".GRD_Grade AS rank_GRD_Grade,
            "kGRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            t.GRD_ID_rank
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.SU_ID_keeper,
                        r.OB_ID_thing
                    ORDER BY
                        r.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
                        r.SU_keeper_OB_thing_GRD_rank_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_SU_keeper_OB_thing_GRD_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ID,
                    po.SU_ID_keeper,
                    po.OB_ID_thing,
                    po.GRD_ID_rank,
                    po.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                    an.SU_keeper_OB_thing_GRD_rank_PositedAt,
                    an.SU_keeper_OB_thing_GRD_rank_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_keeper_OB_thing_GRD_rank_ID
                        ORDER BY an.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_keeper_OB_thing_GRD_rank_Posit po
                JOIN
                    SU_keeper_OB_thing_GRD_rank_Annex an
                ON
                    an.SU_keeper_OB_thing_GRD_rank_ID = po.SU_keeper_OB_thing_GRD_rank_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_keeper_OB_thing_GRD_rank_Reliability = 1
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_rank"
        ON
            "kGRD_rank".GRD_ID = t.GRD_ID_rank
        WHERE
            t.latestPosit = 1
        AND
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_keeper_OB_thing_GRD_rank;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tOB_part_SU_owner (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.OB_part_SU_owner_ID,
            t.Metadata_OB_part_SU_owner,
            t.OB_part_SU_owner_PositedAt,
            t.OB_part_SU_owner_Reliability,
            t.OB_ID_part,
            t.SU_ID_owner
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.OB_ID_part
                    ORDER BY
                        r.OB_part_SU_owner_PositedAt DESC,
                        r.OB_part_SU_owner_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_OB_part_SU_owner,
                    po.OB_part_SU_owner_ID,
                    po.OB_ID_part,
                    po.SU_ID_owner,
                    an.OB_part_SU_owner_PositedAt,
                    an.OB_part_SU_owner_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.OB_part_SU_owner_ID
                        ORDER BY an.OB_part_SU_owner_PositedAt DESC
                    ) AS rewindRank
                FROM
                    OB_part_SU_owner_Posit po
                JOIN
                    OB_part_SU_owner_Annex an
                ON
                    an.OB_part_SU_owner_ID = po.OB_part_SU_owner_ID
                WHERE
                    an.OB_part_SU_owner_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.OB_part_SU_owner_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END tOB_part_SU_owner;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pOB_part_SU_owner (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.OB_part_SU_owner_ID,
            t.Metadata_OB_part_SU_owner,
            t.OB_part_SU_owner_PositedAt,
            t.OB_part_SU_owner_Reliability,
            t.OB_ID_part,
            t.SU_ID_owner
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.OB_ID_part
                    ORDER BY
                        r.OB_part_SU_owner_PositedAt DESC,
                        r.OB_part_SU_owner_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_OB_part_SU_owner,
                    po.OB_part_SU_owner_ID,
                    po.OB_ID_part,
                    po.SU_ID_owner,
                    an.OB_part_SU_owner_PositedAt,
                    an.OB_part_SU_owner_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.OB_part_SU_owner_ID
                        ORDER BY an.OB_part_SU_owner_PositedAt DESC
                    ) AS rewindRank
                FROM
                    OB_part_SU_owner_Posit po
                JOIN
                    OB_part_SU_owner_Annex an
                ON
                    an.OB_part_SU_owner_ID = po.OB_part_SU_owner_ID
                WHERE
                    an.OB_part_SU_owner_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.OB_part_SU_owner_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END pOB_part_SU_owner;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lOB_part_SU_owner
AS
SELECT
    *
FROM
    pOB_part_SU_owner(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nOB_part_SU_owner
AS
SELECT
    *
FROM
    pOB_part_SU_owner(CAST(current_timestamp AS timestamp))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tSU_partner_SU_with (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_partner_SU_with_ID,
            t.Metadata_SU_partner_SU_with,
            t.SU_partner_SU_with_ChangedAt,
            t.SU_partner_SU_with_PositedAt,
            t.SU_partner_SU_with_Reliability,
            t.SU_ID_partner,
            t.SU_ID_with
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_partner
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_with
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_with
            FROM (
                SELECT
                    an.Metadata_SU_partner_SU_with,
                    po.SU_partner_SU_with_ID,
                    po.SU_ID_partner,
                    po.SU_ID_with,
                    po.SU_partner_SU_with_ChangedAt,
                    an.SU_partner_SU_with_PositedAt,
                    an.SU_partner_SU_with_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_partner_SU_with_ID
                        ORDER BY an.SU_partner_SU_with_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_partner_SU_with_Posit po
                JOIN
                    SU_partner_SU_with_Annex an
                ON
                    an.SU_partner_SU_with_ID = po.SU_partner_SU_with_ID
                WHERE
                    po.SU_partner_SU_with_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_partner_SU_with_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_partner_SU_with_Reliability = 1
        ) t
        WHERE
            t.latestPositSU_ID_partner = 1
        AND
            t.latestPositSU_ID_with = 1
    ]';
END tSU_partner_SU_with;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_partner_SU_with (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.SU_partner_SU_with_ID,
            t.Metadata_SU_partner_SU_with,
            t.SU_partner_SU_with_ChangedAt,
            t.SU_partner_SU_with_PositedAt,
            t.SU_partner_SU_with_Reliability,
            t.SU_ID_partner,
            t.SU_ID_with
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_partner
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_with
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_with
            FROM (
                SELECT
                    an.Metadata_SU_partner_SU_with,
                    po.SU_partner_SU_with_ID,
                    po.SU_ID_partner,
                    po.SU_ID_with,
                    po.SU_partner_SU_with_ChangedAt,
                    an.SU_partner_SU_with_PositedAt,
                    an.SU_partner_SU_with_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_partner_SU_with_ID
                        ORDER BY an.SU_partner_SU_with_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_partner_SU_with_Posit po
                JOIN
                    SU_partner_SU_with_Annex an
                ON
                    an.SU_partner_SU_with_ID = po.SU_partner_SU_with_ID
                WHERE
                    po.SU_partner_SU_with_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.SU_partner_SU_with_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_partner_SU_with_Reliability = 1
        ) t
        WHERE
            t.latestPositSU_ID_partner = 1
        AND
            t.latestPositSU_ID_with = 1
    ]';
END pSU_partner_SU_with;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_partner_SU_with
AS
SELECT
    *
FROM
    pSU_partner_SU_with(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
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
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
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
            t.SU_partner_SU_with_ID,
            t.Metadata_SU_partner_SU_with,
            t.SU_partner_SU_with_ChangedAt,
            t.SU_partner_SU_with_PositedAt,
            t.SU_partner_SU_with_Reliability,
            t.SU_ID_partner,
            t.SU_ID_with
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_partner
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.SU_ID_with
                    ORDER BY
                        r.SU_partner_SU_with_ChangedAt DESC,
                        r.SU_partner_SU_with_PositedAt DESC,
                        r.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_with
            FROM (
                SELECT
                    an.Metadata_SU_partner_SU_with,
                    po.SU_partner_SU_with_ID,
                    po.SU_ID_partner,
                    po.SU_ID_with,
                    po.SU_partner_SU_with_ChangedAt,
                    an.SU_partner_SU_with_PositedAt,
                    an.SU_partner_SU_with_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.SU_partner_SU_with_ID
                        ORDER BY an.SU_partner_SU_with_PositedAt DESC
                    ) AS rewindRank
                FROM
                    SU_partner_SU_with_Posit po
                JOIN
                    SU_partner_SU_with_Annex an
                ON
                    an.SU_partner_SU_with_ID = po.SU_partner_SU_with_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.SU_partner_SU_with_Reliability = 1
        ) t
        WHERE
            t.latestPositSU_ID_partner = 1
        AND
            t.latestPositSU_ID_with = 1
        AND
            t.SU_partner_SU_with_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dSU_partner_SU_with;
/
