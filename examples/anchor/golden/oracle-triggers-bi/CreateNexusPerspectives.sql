-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pEV_Event(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex row with the latest positing time picked for each posit, the posits that are not
-- reliable left out, and the latest of the posits that are left picked for each nexus.
--
-- The latest and now perspectives are views over the point-in-time macro.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tEV_Event (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            "QTY".EV_QTY_Reliability,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ID,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_PositedAt,
            "PLC".EV_PLC_Reliability,
            "PLC".EV_PLC_Event_Place
        FROM
            EV_Event "EV"
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_QTY_EV_ID
                        ORDER BY
                            r.EV_QTY_PositedAt DESC,
                            r.EV_QTY_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_QTY,
                        po.EV_QTY_ID,
                        an.EV_QTY_PositedAt,
                        an.EV_QTY_Reliability,
                        po.EV_QTY_EV_ID,
                        po.EV_QTY_Event_Quantity,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_QTY_ID
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
                AND
                    r.EV_QTY_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_PLC_EV_ID
                        ORDER BY
                            r.EV_PLC_ChangedAt DESC,
                            r.EV_PLC_PositedAt DESC,
                            r.EV_PLC_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_PLC,
                        po.EV_PLC_ID,
                        an.EV_PLC_PositedAt,
                        an.EV_PLC_Reliability,
                        po.EV_PLC_EV_ID,
                        po.EV_PLC_Event_Place,
                        po.EV_PLC_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_PLC_ID
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
                AND
                    r.EV_PLC_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
    ]';
END tEV_Event;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time,
-- with a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pEV_Event (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_ID,
            "QTY".EV_QTY_PositedAt,
            "QTY".EV_QTY_Reliability,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ID,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_PositedAt,
            "PLC".EV_PLC_Reliability,
            "PLC".EV_PLC_Event_Place
        FROM
            EV_Event "EV"
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_QTY_EV_ID
                        ORDER BY
                            r.EV_QTY_PositedAt DESC,
                            r.EV_QTY_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_QTY,
                        po.EV_QTY_ID,
                        an.EV_QTY_PositedAt,
                        an.EV_QTY_Reliability,
                        po.EV_QTY_EV_ID,
                        po.EV_QTY_Event_Quantity,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_QTY_ID
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
                AND
                    r.EV_QTY_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_PLC_EV_ID
                        ORDER BY
                            r.EV_PLC_ChangedAt DESC,
                            r.EV_PLC_PositedAt DESC,
                            r.EV_PLC_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_PLC,
                        po.EV_PLC_ID,
                        an.EV_PLC_PositedAt,
                        an.EV_PLC_Reliability,
                        po.EV_PLC_EV_ID,
                        po.EV_PLC_Event_Place,
                        po.EV_PLC_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_PLC_ID
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
                AND
                    r.EV_PLC_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- reliable posit is joined with the changing time until which it holds, when the next one does. The attributes whose
-- mnemonics the selection holds are the ones that are looked at (all of them if it is null).
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
            timepoints.inspectedTimepoint,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_ID,
            "QTY".EV_QTY_PositedAt,
            "QTY".EV_QTY_Reliability,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ID,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_PositedAt,
            "PLC".EV_PLC_Reliability,
            "PLC".EV_PLC_Event_Place
        FROM (
            SELECT DISTINCT
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
                        PARTITION BY r.EV_QTY_EV_ID
                        ORDER BY
                            r.EV_QTY_PositedAt DESC,
                            r.EV_QTY_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_QTY,
                        po.EV_QTY_ID,
                        an.EV_QTY_PositedAt,
                        an.EV_QTY_Reliability,
                        po.EV_QTY_EV_ID,
                        po.EV_QTY_Event_Quantity,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_QTY_ID
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
                    r.EV_QTY_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.EV_PLC_ChangedAt) OVER (
                    PARTITION BY y.EV_PLC_EV_ID
                    ORDER BY y.EV_PLC_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.EV_PLC_EV_ID, r.EV_PLC_ChangedAt
                            ORDER BY
                                r.EV_PLC_PositedAt DESC,
                                r.EV_PLC_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_EV_PLC,
                            po.EV_PLC_ID,
                            an.EV_PLC_PositedAt,
                            an.EV_PLC_Reliability,
                            po.EV_PLC_EV_ID,
                            po.EV_PLC_Event_Place,
                            po.EV_PLC_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_PLC_ID
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
                        r.EV_PLC_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
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
