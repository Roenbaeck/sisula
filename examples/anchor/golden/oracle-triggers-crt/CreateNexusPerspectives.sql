-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pEV_Event(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex with the latest positing time picked for each posit and positor.
--
-- The latest and now perspectives are views over the point-in-time macro. A macro cannot be given a column of another
-- table to work for each positor, so the point-in-time macro works out the views of all positors itself, as does the
-- difference macro. The time traveling macro shows one positor, given by its first argument.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tEV_Event (
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
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_ID,
            "QTY".EV_QTY_PositedAt,
            "QTY".EV_QTY_Positor,
            "QTY".EV_QTY_Reliability,
            "QTY".EV_QTY_Assertion,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ID,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_PositedAt,
            "PLC".EV_PLC_Positor,
            "PLC".EV_PLC_Reliability,
            "PLC".EV_PLC_Assertion,
            "PLC".EV_PLC_Event_Place
        FROM
            EV_Event "EV"
        CROSS JOIN
            Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_QTY_Positor, x.EV_QTY_EV_ID
                        ORDER BY
                            x.EV_QTY_PositedAt DESC,
                            x.EV_QTY_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_QTY,
                            po.EV_QTY_ID,
                            an.EV_QTY_PositedAt,
                            an.EV_QTY_Positor,
                            an.EV_QTY_Reliability,
                            an.EV_QTY_Assertion,
                            po.EV_QTY_EV_ID,
                            po.EV_QTY_Event_Quantity,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_QTY_ID, an.EV_QTY_Positor
                                ORDER BY an.EV_QTY_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            EV_QTY_Event_Quantity_Posit po
                        JOIN
                            EV_QTY_Event_Quantity_Annex an
                        ON
                            an.EV_QTY_ID = po.EV_QTY_ID
                        WHERE
                            an.EV_QTY_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_QTY_Assertion = COALESCE(assertion, x.EV_QTY_Assertion)
            ) y
            WHERE
                y.pickRank = 1
        ) "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        AND
            "QTY".EV_QTY_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_PLC_Positor, x.EV_PLC_EV_ID
                        ORDER BY
                            x.EV_PLC_ChangedAt DESC,
                            x.EV_PLC_PositedAt DESC,
                            x.EV_PLC_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_PLC_Assertion <> '?' THEN r.EV_PLC_ChangedAt END) OVER (
                            PARTITION BY r.EV_PLC_Positor, r.EV_PLC_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_PLC,
                            po.EV_PLC_ID,
                            an.EV_PLC_PositedAt,
                            an.EV_PLC_Positor,
                            an.EV_PLC_Reliability,
                            an.EV_PLC_Assertion,
                            po.EV_PLC_EV_ID,
                            po.EV_PLC_Event_Place,
                            po.EV_PLC_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_PLC_ID, an.EV_PLC_Positor
                                ORDER BY an.EV_PLC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            EV_PLC_Event_Place_Posit po
                        JOIN
                            EV_PLC_Event_Place_Annex an
                        ON
                            an.EV_PLC_ID = po.EV_PLC_ID
                        WHERE
                            po.EV_PLC_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.EV_PLC_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_PLC_Assertion = COALESCE(assertion, x.EV_PLC_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.EV_PLC_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
        AND
            "PLC".EV_PLC_Positor = positorTable.Positor
        WHERE
            positorTable.Positor = forPositor
    ]';
END tEV_Event;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pEV_Event (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_ID,
            "QTY".EV_QTY_PositedAt,
            "QTY".EV_QTY_Positor,
            "QTY".EV_QTY_Reliability,
            "QTY".EV_QTY_Assertion,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ID,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_PositedAt,
            "PLC".EV_PLC_Positor,
            "PLC".EV_PLC_Reliability,
            "PLC".EV_PLC_Assertion,
            "PLC".EV_PLC_Event_Place
        FROM
            EV_Event "EV"
        CROSS JOIN
            Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_QTY_Positor, x.EV_QTY_EV_ID
                        ORDER BY
                            x.EV_QTY_PositedAt DESC,
                            x.EV_QTY_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_QTY,
                            po.EV_QTY_ID,
                            an.EV_QTY_PositedAt,
                            an.EV_QTY_Positor,
                            an.EV_QTY_Reliability,
                            an.EV_QTY_Assertion,
                            po.EV_QTY_EV_ID,
                            po.EV_QTY_Event_Quantity,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_QTY_ID, an.EV_QTY_Positor
                                ORDER BY an.EV_QTY_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            EV_QTY_Event_Quantity_Posit po
                        JOIN
                            EV_QTY_Event_Quantity_Annex an
                        ON
                            an.EV_QTY_ID = po.EV_QTY_ID
                        WHERE
                            an.EV_QTY_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_QTY_Assertion = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        AND
            "QTY".EV_QTY_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_PLC_Positor, x.EV_PLC_EV_ID
                        ORDER BY
                            x.EV_PLC_ChangedAt DESC,
                            x.EV_PLC_PositedAt DESC,
                            x.EV_PLC_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_PLC_Assertion <> '?' THEN r.EV_PLC_ChangedAt END) OVER (
                            PARTITION BY r.EV_PLC_Positor, r.EV_PLC_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_PLC,
                            po.EV_PLC_ID,
                            an.EV_PLC_PositedAt,
                            an.EV_PLC_Positor,
                            an.EV_PLC_Reliability,
                            an.EV_PLC_Assertion,
                            po.EV_PLC_EV_ID,
                            po.EV_PLC_Event_Place,
                            po.EV_PLC_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_PLC_ID, an.EV_PLC_Positor
                                ORDER BY an.EV_PLC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            EV_PLC_Event_Place_Posit po
                        JOIN
                            EV_PLC_Event_Place_Annex an
                        ON
                            an.EV_PLC_ID = po.EV_PLC_ID
                        WHERE
                            po.EV_PLC_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.EV_PLC_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_PLC_Assertion = '+'
                AND
                    x.EV_PLC_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
        AND
            "PLC".EV_PLC_Positor = positorTable.Positor
    ]';
END pEV_Event;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lEV_Event
AS
SELECT
    *
FROM
    pEV_Event(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nEV_Event
AS
SELECT
    *
FROM
    pEV_Event(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dEV_Event (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            timepoints.inspectedTimepoint,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_ID,
            "QTY".EV_QTY_PositedAt,
            "QTY".EV_QTY_Positor,
            "QTY".EV_QTY_Reliability,
            "QTY".EV_QTY_Assertion,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ID,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_PositedAt,
            "PLC".EV_PLC_Positor,
            "PLC".EV_PLC_Reliability,
            "PLC".EV_PLC_Assertion,
            "PLC".EV_PLC_Event_Place
        FROM
            Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.EV_PLC_Positor AS inspectedPositor,
                h.EV_PLC_EV_ID AS EV_ID,
                CAST(h.EV_PLC_ChangedAt AS timestamp) AS inspectedTimepoint,
                'PLC' AS mnemonic
            FROM
                EV_PLC_Event_Place h
            WHERE
                (selection IS NULL OR selection LIKE '%PLC%')
            AND
                h.EV_PLC_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        ON
            timepoints.inspectedPositor = positorTable.Positor
        JOIN
            EV_Event "EV"
        ON
            "EV".EV_ID = timepoints.EV_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_QTY_Positor, r.EV_QTY_EV_ID
                        ORDER BY
                            r.EV_QTY_PositedAt DESC,
                            r.EV_QTY_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_QTY,
                        po.EV_QTY_ID,
                        an.EV_QTY_PositedAt,
                        an.EV_QTY_Positor,
                        an.EV_QTY_Reliability,
                        an.EV_QTY_Assertion,
                        po.EV_QTY_EV_ID,
                        po.EV_QTY_Event_Quantity,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_QTY_ID, an.EV_QTY_Positor
                            ORDER BY an.EV_QTY_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_QTY_Event_Quantity_Posit po
                    JOIN
                        EV_QTY_Event_Quantity_Annex an
                    ON
                        an.EV_QTY_ID = po.EV_QTY_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_QTY_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        AND
            "QTY".EV_QTY_Positor = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.EV_PLC_ChangedAt) OVER (
                    PARTITION BY y.EV_PLC_Positor, y.EV_PLC_EV_ID
                    ORDER BY y.EV_PLC_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.EV_PLC_Positor, r.EV_PLC_EV_ID, r.EV_PLC_ChangedAt
                            ORDER BY
                                CASE WHEN r.EV_PLC_Assertion = '+' THEN 0 ELSE 1 END,
                                r.EV_PLC_PositedAt DESC,
                                r.EV_PLC_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_EV_PLC,
                            po.EV_PLC_ID,
                            an.EV_PLC_PositedAt,
                            an.EV_PLC_Positor,
                            an.EV_PLC_Reliability,
                            an.EV_PLC_Assertion,
                            po.EV_PLC_EV_ID,
                            po.EV_PLC_Event_Place,
                            po.EV_PLC_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_PLC_ID, an.EV_PLC_Positor
                                ORDER BY an.EV_PLC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            EV_PLC_Event_Place_Posit po
                        JOIN
                            EV_PLC_Event_Place_Annex an
                        ON
                            an.EV_PLC_ID = po.EV_PLC_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.EV_PLC_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
        AND
            "PLC".EV_PLC_Positor = timepoints.inspectedPositor
        AND
            "PLC".EV_PLC_Assertion = '+'
        AND
            "PLC".EV_PLC_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "PLC".untilTime IS NULL
        OR
            "PLC".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
    ]';
END dEV_Event;
/
