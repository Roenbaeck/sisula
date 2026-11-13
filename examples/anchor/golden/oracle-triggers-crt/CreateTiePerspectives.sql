-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_part_PR_wasPlayed(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinder of a tie is not called in the macros, what it does is written out in them: the posit and annex of the
-- tie joined, the annex with the latest positing time picked for each posit and positor.
--
-- The latest and now perspectives are views over the point-in-time macro. A macro cannot be given a column of another
-- table to work for each positor, so the point-in-time macro works out the views of all positors itself, as does the
-- difference macro. The time traveling macro shows one positor, given by its first argument.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tSU_holder_OB_item_GRD_grade (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_SU_holder_OB_item_GRD_grade,
            t.SU_ID_holder,
            t.OB_ID_item,
            "kGRD_grade".GRD_Grade AS grade_GRD_Grade,
            "kGRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            t.GRD_ID_grade,
            t.SU_holder_OB_item_GRD_grade_ChangedAt,
            t.SU_holder_OB_item_GRD_grade_PositedAt,
            t.SU_holder_OB_item_GRD_grade_Positor,
            t.SU_holder_OB_item_GRD_grade_Reliability,
            t.SU_holder_OB_item_GRD_grade_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.SU_holder_OB_item_GRD_grade_Positor,
                        s.SU_ID_holder,
                        s.OB_ID_item
                    ORDER BY
                        s.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                        s.SU_holder_OB_item_GRD_grade_PositedAt DESC,
                        s.SU_holder_OB_item_GRD_grade_Reliability DESC,
                        s.SU_holder_OB_item_GRD_grade_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.SU_holder_OB_item_GRD_grade_Assertion <> '?' THEN r.SU_holder_OB_item_GRD_grade_ChangedAt END) OVER (
                        PARTITION BY
                            r.SU_holder_OB_item_GRD_grade_Positor,
                            r.SU_ID_holder,
                            r.OB_ID_item
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_SU_holder_OB_item_GRD_grade,
                        po.SU_holder_OB_item_GRD_grade_ID,
                        po.SU_ID_holder,
                        po.OB_ID_item,
                        po.GRD_ID_grade,
                        po.SU_holder_OB_item_GRD_grade_ChangedAt,
                        an.SU_holder_OB_item_GRD_grade_PositedAt,
                        an.SU_holder_OB_item_GRD_grade_Positor,
                        an.SU_holder_OB_item_GRD_grade_Reliability,
                        an.SU_holder_OB_item_GRD_grade_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_holder_OB_item_GRD_grade_ID, an.SU_holder_OB_item_GRD_grade_Positor
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
            ) s
            WHERE
                s.SU_holder_OB_item_GRD_grade_Assertion = COALESCE(assertion, s.SU_holder_OB_item_GRD_grade_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.SU_holder_OB_item_GRD_grade_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_grade"
        ON
            "kGRD_grade".GRD_ID = t.GRD_ID_grade
        WHERE
            t.SU_holder_OB_item_GRD_grade_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tSU_holder_OB_item_GRD_grade;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_holder_OB_item_GRD_grade (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_SU_holder_OB_item_GRD_grade,
            t.SU_ID_holder,
            t.OB_ID_item,
            "kGRD_grade".GRD_Grade AS grade_GRD_Grade,
            "kGRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            t.GRD_ID_grade,
            t.SU_holder_OB_item_GRD_grade_ChangedAt,
            t.SU_holder_OB_item_GRD_grade_PositedAt,
            t.SU_holder_OB_item_GRD_grade_Positor,
            t.SU_holder_OB_item_GRD_grade_Reliability,
            t.SU_holder_OB_item_GRD_grade_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.SU_holder_OB_item_GRD_grade_Positor,
                        s.SU_ID_holder,
                        s.OB_ID_item
                    ORDER BY
                        s.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                        s.SU_holder_OB_item_GRD_grade_PositedAt DESC,
                        s.SU_holder_OB_item_GRD_grade_Reliability DESC,
                        s.SU_holder_OB_item_GRD_grade_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.SU_holder_OB_item_GRD_grade_Assertion <> '?' THEN r.SU_holder_OB_item_GRD_grade_ChangedAt END) OVER (
                        PARTITION BY
                            r.SU_holder_OB_item_GRD_grade_Positor,
                            r.SU_ID_holder,
                            r.OB_ID_item
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_SU_holder_OB_item_GRD_grade,
                        po.SU_holder_OB_item_GRD_grade_ID,
                        po.SU_ID_holder,
                        po.OB_ID_item,
                        po.GRD_ID_grade,
                        po.SU_holder_OB_item_GRD_grade_ChangedAt,
                        an.SU_holder_OB_item_GRD_grade_PositedAt,
                        an.SU_holder_OB_item_GRD_grade_Positor,
                        an.SU_holder_OB_item_GRD_grade_Reliability,
                        an.SU_holder_OB_item_GRD_grade_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_holder_OB_item_GRD_grade_ID, an.SU_holder_OB_item_GRD_grade_Positor
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
            ) s
            WHERE
                s.SU_holder_OB_item_GRD_grade_Assertion = '+'
            AND
                s.SU_holder_OB_item_GRD_grade_ChangedAt = s.inEffect
        ) t
        JOIN
            Positor_ positorTable
        ON
            positorTable.Positor = t.SU_holder_OB_item_GRD_grade_Positor
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_SU_holder_OB_item_GRD_grade,
            t.SU_ID_holder,
            t.OB_ID_item,
            "kGRD_grade".GRD_Grade AS grade_GRD_Grade,
            "kGRD_grade".Metadata_GRD AS grade_Metadata_GRD,
            t.GRD_ID_grade,
            t.SU_holder_OB_item_GRD_grade_ChangedAt,
            t.SU_holder_OB_item_GRD_grade_PositedAt,
            t.SU_holder_OB_item_GRD_grade_Positor,
            t.SU_holder_OB_item_GRD_grade_Reliability,
            t.SU_holder_OB_item_GRD_grade_Assertion
        FROM
            Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.SU_holder_OB_item_GRD_grade_Positor AS inspectedPositor,
                CAST(h.SU_holder_OB_item_GRD_grade_ChangedAt AS timestamp) AS inspectedTimepoint
            FROM
                SU_holder_OB_item_GRD_grade h
            WHERE
                h.SU_holder_OB_item_GRD_grade_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.SU_holder_OB_item_GRD_grade_ChangedAt) OVER (
                    PARTITION BY
                        y.SU_holder_OB_item_GRD_grade_Positor,
                        y.SU_ID_holder,
                        y.OB_ID_item
                    ORDER BY y.SU_holder_OB_item_GRD_grade_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.SU_holder_OB_item_GRD_grade_Positor,
                                r.SU_ID_holder,
                                r.OB_ID_item,
                                r.SU_holder_OB_item_GRD_grade_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_holder_OB_item_GRD_grade_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_holder_OB_item_GRD_grade_PositedAt DESC,
                                r.SU_holder_OB_item_GRD_grade_Reliability DESC,
                                r.SU_holder_OB_item_GRD_grade_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_holder_OB_item_GRD_grade,
                            po.SU_holder_OB_item_GRD_grade_ID,
                            po.SU_ID_holder,
                            po.OB_ID_item,
                            po.GRD_ID_grade,
                            po.SU_holder_OB_item_GRD_grade_ChangedAt,
                            an.SU_holder_OB_item_GRD_grade_PositedAt,
                            an.SU_holder_OB_item_GRD_grade_Positor,
                            an.SU_holder_OB_item_GRD_grade_Reliability,
                            an.SU_holder_OB_item_GRD_grade_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_holder_OB_item_GRD_grade_ID, an.SU_holder_OB_item_GRD_grade_Positor
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
                        r.SU_holder_OB_item_GRD_grade_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.SU_holder_OB_item_GRD_grade_Positor = tp.inspectedPositor
        AND
            t.SU_holder_OB_item_GRD_grade_Assertion = '+'
        AND
            t.SU_holder_OB_item_GRD_grade_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            GRD_Grade "kGRD_grade"
        ON
            "kGRD_grade".GRD_ID = t.GRD_ID_grade
    ]';
END dSU_holder_OB_item_GRD_grade;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tSU_keeper_OB_thing_GRD_rank (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_SU_keeper_OB_thing_GRD_rank,
            t.SU_ID_keeper,
            t.OB_ID_thing,
            "kGRD_rank".GRD_Grade AS rank_GRD_Grade,
            "kGRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            t.GRD_ID_rank,
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            t.SU_keeper_OB_thing_GRD_rank_PositedAt,
            t.SU_keeper_OB_thing_GRD_rank_Positor,
            t.SU_keeper_OB_thing_GRD_rank_Reliability,
            t.SU_keeper_OB_thing_GRD_rank_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.SU_keeper_OB_thing_GRD_rank_Positor,
                        s.SU_ID_keeper,
                        s.OB_ID_thing
                    ORDER BY
                        s.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                        s.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
                        s.SU_keeper_OB_thing_GRD_rank_Reliability DESC,
                        s.SU_keeper_OB_thing_GRD_rank_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.SU_keeper_OB_thing_GRD_rank_Assertion <> '?' THEN r.SU_keeper_OB_thing_GRD_rank_ChangedAt END) OVER (
                        PARTITION BY
                            r.SU_keeper_OB_thing_GRD_rank_Positor,
                            r.SU_ID_keeper,
                            r.OB_ID_thing
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_SU_keeper_OB_thing_GRD_rank,
                        po.SU_keeper_OB_thing_GRD_rank_ID,
                        po.SU_ID_keeper,
                        po.OB_ID_thing,
                        po.GRD_ID_rank,
                        po.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                        an.SU_keeper_OB_thing_GRD_rank_PositedAt,
                        an.SU_keeper_OB_thing_GRD_rank_Positor,
                        an.SU_keeper_OB_thing_GRD_rank_Reliability,
                        an.SU_keeper_OB_thing_GRD_rank_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_keeper_OB_thing_GRD_rank_ID, an.SU_keeper_OB_thing_GRD_rank_Positor
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
            ) s
            WHERE
                s.SU_keeper_OB_thing_GRD_rank_Assertion = COALESCE(assertion, s.SU_keeper_OB_thing_GRD_rank_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.SU_keeper_OB_thing_GRD_rank_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            GRD_Grade "kGRD_rank"
        ON
            "kGRD_rank".GRD_ID = t.GRD_ID_rank
        WHERE
            t.SU_keeper_OB_thing_GRD_rank_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tSU_keeper_OB_thing_GRD_rank;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_keeper_OB_thing_GRD_rank (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_SU_keeper_OB_thing_GRD_rank,
            t.SU_ID_keeper,
            t.OB_ID_thing,
            "kGRD_rank".GRD_Grade AS rank_GRD_Grade,
            "kGRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            t.GRD_ID_rank,
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            t.SU_keeper_OB_thing_GRD_rank_PositedAt,
            t.SU_keeper_OB_thing_GRD_rank_Positor,
            t.SU_keeper_OB_thing_GRD_rank_Reliability,
            t.SU_keeper_OB_thing_GRD_rank_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.SU_keeper_OB_thing_GRD_rank_Positor,
                        s.SU_ID_keeper,
                        s.OB_ID_thing
                    ORDER BY
                        s.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                        s.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
                        s.SU_keeper_OB_thing_GRD_rank_Reliability DESC,
                        s.SU_keeper_OB_thing_GRD_rank_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.SU_keeper_OB_thing_GRD_rank_Assertion <> '?' THEN r.SU_keeper_OB_thing_GRD_rank_ChangedAt END) OVER (
                        PARTITION BY
                            r.SU_keeper_OB_thing_GRD_rank_Positor,
                            r.SU_ID_keeper,
                            r.OB_ID_thing
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_SU_keeper_OB_thing_GRD_rank,
                        po.SU_keeper_OB_thing_GRD_rank_ID,
                        po.SU_ID_keeper,
                        po.OB_ID_thing,
                        po.GRD_ID_rank,
                        po.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                        an.SU_keeper_OB_thing_GRD_rank_PositedAt,
                        an.SU_keeper_OB_thing_GRD_rank_Positor,
                        an.SU_keeper_OB_thing_GRD_rank_Reliability,
                        an.SU_keeper_OB_thing_GRD_rank_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_keeper_OB_thing_GRD_rank_ID, an.SU_keeper_OB_thing_GRD_rank_Positor
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
            ) s
            WHERE
                s.SU_keeper_OB_thing_GRD_rank_Assertion = '+'
            AND
                s.SU_keeper_OB_thing_GRD_rank_ChangedAt = s.inEffect
        ) t
        JOIN
            Positor_ positorTable
        ON
            positorTable.Positor = t.SU_keeper_OB_thing_GRD_rank_Positor
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_SU_keeper_OB_thing_GRD_rank,
            t.SU_ID_keeper,
            t.OB_ID_thing,
            "kGRD_rank".GRD_Grade AS rank_GRD_Grade,
            "kGRD_rank".Metadata_GRD AS rank_Metadata_GRD,
            t.GRD_ID_rank,
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            t.SU_keeper_OB_thing_GRD_rank_PositedAt,
            t.SU_keeper_OB_thing_GRD_rank_Positor,
            t.SU_keeper_OB_thing_GRD_rank_Reliability,
            t.SU_keeper_OB_thing_GRD_rank_Assertion
        FROM
            Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.SU_keeper_OB_thing_GRD_rank_Positor AS inspectedPositor,
                CAST(h.SU_keeper_OB_thing_GRD_rank_ChangedAt AS timestamp) AS inspectedTimepoint
            FROM
                SU_keeper_OB_thing_GRD_rank h
            WHERE
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.SU_keeper_OB_thing_GRD_rank_ChangedAt) OVER (
                    PARTITION BY
                        y.SU_keeper_OB_thing_GRD_rank_Positor,
                        y.SU_ID_keeper,
                        y.OB_ID_thing
                    ORDER BY y.SU_keeper_OB_thing_GRD_rank_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.SU_keeper_OB_thing_GRD_rank_Positor,
                                r.SU_ID_keeper,
                                r.OB_ID_thing,
                                r.SU_keeper_OB_thing_GRD_rank_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_keeper_OB_thing_GRD_rank_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
                                r.SU_keeper_OB_thing_GRD_rank_Reliability DESC,
                                r.SU_keeper_OB_thing_GRD_rank_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_keeper_OB_thing_GRD_rank,
                            po.SU_keeper_OB_thing_GRD_rank_ID,
                            po.SU_ID_keeper,
                            po.OB_ID_thing,
                            po.GRD_ID_rank,
                            po.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                            an.SU_keeper_OB_thing_GRD_rank_PositedAt,
                            an.SU_keeper_OB_thing_GRD_rank_Positor,
                            an.SU_keeper_OB_thing_GRD_rank_Reliability,
                            an.SU_keeper_OB_thing_GRD_rank_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_keeper_OB_thing_GRD_rank_ID, an.SU_keeper_OB_thing_GRD_rank_Positor
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
                        r.SU_keeper_OB_thing_GRD_rank_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.SU_keeper_OB_thing_GRD_rank_Positor = tp.inspectedPositor
        AND
            t.SU_keeper_OB_thing_GRD_rank_Assertion = '+'
        AND
            t.SU_keeper_OB_thing_GRD_rank_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            GRD_Grade "kGRD_rank"
        ON
            "kGRD_rank".GRD_ID = t.GRD_ID_rank
    ]';
END dSU_keeper_OB_thing_GRD_rank;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tOB_part_SU_owner (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_OB_part_SU_owner,
            t.OB_ID_part,
            t.SU_ID_owner,
            t.OB_part_SU_owner_PositedAt,
            t.OB_part_SU_owner_Positor,
            t.OB_part_SU_owner_Reliability,
            t.OB_part_SU_owner_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.OB_part_SU_owner_Positor,
                        s.OB_ID_part
                    ORDER BY
                        s.OB_part_SU_owner_PositedAt DESC,
                        s.OB_part_SU_owner_Reliability DESC,
                        s.OB_part_SU_owner_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_OB_part_SU_owner,
                        po.OB_part_SU_owner_ID,
                        po.OB_ID_part,
                        po.SU_ID_owner,
                        an.OB_part_SU_owner_PositedAt,
                        an.OB_part_SU_owner_Positor,
                        an.OB_part_SU_owner_Reliability,
                        an.OB_part_SU_owner_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.OB_part_SU_owner_ID, an.OB_part_SU_owner_Positor
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
            ) s
            WHERE
                s.OB_part_SU_owner_Assertion = COALESCE(assertion, s.OB_part_SU_owner_Assertion)
        ) t
        WHERE
            t.OB_part_SU_owner_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tOB_part_SU_owner;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pOB_part_SU_owner (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_OB_part_SU_owner,
            t.OB_ID_part,
            t.SU_ID_owner,
            t.OB_part_SU_owner_PositedAt,
            t.OB_part_SU_owner_Positor,
            t.OB_part_SU_owner_Reliability,
            t.OB_part_SU_owner_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.OB_part_SU_owner_Positor,
                        s.OB_ID_part
                    ORDER BY
                        s.OB_part_SU_owner_PositedAt DESC,
                        s.OB_part_SU_owner_Reliability DESC,
                        s.OB_part_SU_owner_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_OB_part_SU_owner,
                        po.OB_part_SU_owner_ID,
                        po.OB_ID_part,
                        po.SU_ID_owner,
                        an.OB_part_SU_owner_PositedAt,
                        an.OB_part_SU_owner_Positor,
                        an.OB_part_SU_owner_Reliability,
                        an.OB_part_SU_owner_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.OB_part_SU_owner_ID, an.OB_part_SU_owner_Positor
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
            ) s
            WHERE
                s.OB_part_SU_owner_Assertion = '+'
        ) t
        JOIN
            Positor_ positorTable
        ON
            positorTable.Positor = t.OB_part_SU_owner_Positor
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
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tSU_partner_SU_with (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_SU_partner_SU_with,
            t.SU_ID_partner,
            t.SU_ID_with,
            t.SU_partner_SU_with_ChangedAt,
            t.SU_partner_SU_with_PositedAt,
            t.SU_partner_SU_with_Positor,
            t.SU_partner_SU_with_Reliability,
            t.SU_partner_SU_with_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.SU_partner_SU_with_Positor, s.SU_ID_partner
                    ORDER BY
                        s.SU_partner_SU_with_ChangedAt DESC,
                        s.SU_partner_SU_with_PositedAt DESC,
                        s.SU_partner_SU_with_Reliability DESC,
                        s.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY s.SU_partner_SU_with_Positor, s.SU_ID_with
                    ORDER BY
                        s.SU_partner_SU_with_ChangedAt DESC,
                        s.SU_partner_SU_with_PositedAt DESC,
                        s.SU_partner_SU_with_Reliability DESC,
                        s.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_with
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.SU_partner_SU_with_Assertion <> '?' THEN r.SU_partner_SU_with_ChangedAt END) OVER (
                        PARTITION BY
                            r.SU_partner_SU_with_Positor,
                            r.SU_ID_partner,
                            r.SU_ID_with
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_SU_partner_SU_with,
                        po.SU_partner_SU_with_ID,
                        po.SU_ID_partner,
                        po.SU_ID_with,
                        po.SU_partner_SU_with_ChangedAt,
                        an.SU_partner_SU_with_PositedAt,
                        an.SU_partner_SU_with_Positor,
                        an.SU_partner_SU_with_Reliability,
                        an.SU_partner_SU_with_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_partner_SU_with_ID, an.SU_partner_SU_with_Positor
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
            ) s
            WHERE
                s.SU_partner_SU_with_Assertion = COALESCE(assertion, s.SU_partner_SU_with_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.SU_partner_SU_with_ChangedAt = s.inEffect
            )
        ) t
        WHERE
            t.SU_partner_SU_with_Positor = forPositor
        AND
            t.latestPositSU_ID_partner = 1
        AND
            t.latestPositSU_ID_with = 1
    ]';
END tSU_partner_SU_with;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_partner_SU_with (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_SU_partner_SU_with,
            t.SU_ID_partner,
            t.SU_ID_with,
            t.SU_partner_SU_with_ChangedAt,
            t.SU_partner_SU_with_PositedAt,
            t.SU_partner_SU_with_Positor,
            t.SU_partner_SU_with_Reliability,
            t.SU_partner_SU_with_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.SU_partner_SU_with_Positor, s.SU_ID_partner
                    ORDER BY
                        s.SU_partner_SU_with_ChangedAt DESC,
                        s.SU_partner_SU_with_PositedAt DESC,
                        s.SU_partner_SU_with_Reliability DESC,
                        s.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY s.SU_partner_SU_with_Positor, s.SU_ID_with
                    ORDER BY
                        s.SU_partner_SU_with_ChangedAt DESC,
                        s.SU_partner_SU_with_PositedAt DESC,
                        s.SU_partner_SU_with_Reliability DESC,
                        s.SU_partner_SU_with_ID DESC
                ) AS latestPositSU_ID_with
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.SU_partner_SU_with_Assertion <> '?' THEN r.SU_partner_SU_with_ChangedAt END) OVER (
                        PARTITION BY
                            r.SU_partner_SU_with_Positor,
                            r.SU_ID_partner,
                            r.SU_ID_with
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_SU_partner_SU_with,
                        po.SU_partner_SU_with_ID,
                        po.SU_ID_partner,
                        po.SU_ID_with,
                        po.SU_partner_SU_with_ChangedAt,
                        an.SU_partner_SU_with_PositedAt,
                        an.SU_partner_SU_with_Positor,
                        an.SU_partner_SU_with_Reliability,
                        an.SU_partner_SU_with_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_partner_SU_with_ID, an.SU_partner_SU_with_Positor
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
            ) s
            WHERE
                s.SU_partner_SU_with_Assertion = '+'
            AND
                s.SU_partner_SU_with_ChangedAt = s.inEffect
        ) t
        JOIN
            Positor_ positorTable
        ON
            positorTable.Positor = t.SU_partner_SU_with_Positor
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            q.Positor,
            q.inspectedTimepoint,
            q.Metadata_SU_partner_SU_with,
            q.SU_ID_partner,
            q.SU_ID_with,
            q.SU_partner_SU_with_ChangedAt,
            q.SU_partner_SU_with_PositedAt,
            q.SU_partner_SU_with_Positor,
            q.SU_partner_SU_with_Reliability,
            q.SU_partner_SU_with_Assertion
        FROM (
        SELECT
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_SU_partner_SU_with,
            t.SU_ID_partner,
            t.SU_ID_with,
            t.SU_partner_SU_with_ChangedAt,
            t.SU_partner_SU_with_PositedAt,
            t.SU_partner_SU_with_Positor,
            t.SU_partner_SU_with_Reliability,
            t.SU_partner_SU_with_Assertion,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.SU_ID_partner
                ORDER BY
                    t.SU_partner_SU_with_ChangedAt DESC,
                    t.SU_partner_SU_with_PositedAt DESC,
                    t.SU_partner_SU_with_Reliability DESC,
                    t.SU_partner_SU_with_ID DESC
            ) AS latestPositSU_ID_partner,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.SU_ID_with
                ORDER BY
                    t.SU_partner_SU_with_ChangedAt DESC,
                    t.SU_partner_SU_with_PositedAt DESC,
                    t.SU_partner_SU_with_Reliability DESC,
                    t.SU_partner_SU_with_ID DESC
            ) AS latestPositSU_ID_with
        FROM
            Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.SU_partner_SU_with_Positor AS inspectedPositor,
                CAST(h.SU_partner_SU_with_ChangedAt AS timestamp) AS inspectedTimepoint
            FROM
                SU_partner_SU_with h
            WHERE
                h.SU_partner_SU_with_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.SU_partner_SU_with_ChangedAt) OVER (
                    PARTITION BY
                        y.SU_partner_SU_with_Positor,
                        y.SU_ID_partner,
                        y.SU_ID_with
                    ORDER BY y.SU_partner_SU_with_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.SU_partner_SU_with_Positor,
                                r.SU_ID_partner,
                                r.SU_ID_with,
                                r.SU_partner_SU_with_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_partner_SU_with_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_partner_SU_with_PositedAt DESC,
                                r.SU_partner_SU_with_Reliability DESC,
                                r.SU_partner_SU_with_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_partner_SU_with,
                            po.SU_partner_SU_with_ID,
                            po.SU_ID_partner,
                            po.SU_ID_with,
                            po.SU_partner_SU_with_ChangedAt,
                            an.SU_partner_SU_with_PositedAt,
                            an.SU_partner_SU_with_Positor,
                            an.SU_partner_SU_with_Reliability,
                            an.SU_partner_SU_with_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_partner_SU_with_ID, an.SU_partner_SU_with_Positor
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
                        r.SU_partner_SU_with_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.SU_partner_SU_with_Positor = tp.inspectedPositor
        AND
            t.SU_partner_SU_with_Assertion = '+'
        AND
            t.SU_partner_SU_with_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        ) q
        WHERE
            q.latestPositSU_ID_partner = 1
        AND
            q.latestPositSU_ID_with = 1
    ]';
END dSU_partner_SU_with;
/
