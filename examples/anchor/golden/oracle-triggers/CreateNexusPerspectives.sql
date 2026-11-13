-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- nexus perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pEV_Event(TIMESTAMP '2020-01-01 00:00:00').
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lEV_Event (
    EV_ID,
    Metadata_EV,
    SU_ID_for,
    EV_QTY_EV_ID,
    Metadata_EV_QTY,
    Deletable_EV_QTY,
    EV_QTY_Event_Quantity,
    EV_PLC_EV_ID,
    Metadata_EV_PLC,
    Deletable_EV_PLC,
    EV_PLC_ChangedAt,
    EV_PLC_Event_Place
)
AS
SELECT
    "EV".EV_ID,
    "EV".Metadata_EV,
    "EV".SU_ID_for,
    "QTY".EV_QTY_EV_ID,
    "QTY".Metadata_EV_QTY,
    CAST(NULL AS number(1)),
    "QTY".EV_QTY_Event_Quantity,
    "PLC".EV_PLC_EV_ID,
    "PLC".Metadata_EV_PLC,
    CAST(NULL AS number(1)),
    "PLC".EV_PLC_ChangedAt,
    "PLC".EV_PLC_Event_Place
FROM
    EV_Event "EV"
LEFT JOIN
    EV_QTY_Event_Quantity "QTY"
ON
    "QTY".EV_QTY_EV_ID = "EV".EV_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            EV_PLC_Event_Place a
        WHERE
            a.EV_PLC_ChangedAt = (
                SELECT
                    MAX(sub.EV_PLC_ChangedAt)
                FROM
                    EV_PLC_Event_Place sub
                WHERE
                    sub.EV_PLC_EV_ID = a.EV_PLC_EV_ID
            )
    ) "PLC"
ON
    "PLC".EV_PLC_EV_ID = "EV".EV_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pEV_Event (
    changingTimepoint IN timestamp
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
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ChangedAt,
            "PLC".EV_PLC_Event_Place
        FROM
            EV_Event "EV"
        LEFT JOIN
            EV_QTY_Event_Quantity "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    EV_PLC_Event_Place a
                WHERE
                    a.EV_PLC_ChangedAt = (
                        SELECT
                            MAX(sub.EV_PLC_ChangedAt)
                        FROM
                            EV_PLC_Event_Place sub
                        WHERE
                            sub.EV_PLC_EV_ID = a.EV_PLC_EV_ID
                        AND
                            sub.EV_PLC_ChangedAt <= changingTimepoint
                    )
            ) "PLC"
        ON
            "PLC".EV_PLC_EV_ID = "EV".EV_ID
    ]';
END pEV_Event;
/
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
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
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
            timepoints.mnemonic,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".SU_ID_for,
            "QTY".EV_QTY_EV_ID,
            "QTY".Metadata_EV_QTY,
            "QTY".EV_QTY_Event_Quantity,
            "PLC".EV_PLC_EV_ID,
            "PLC".Metadata_EV_PLC,
            "PLC".EV_PLC_ChangedAt,
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
        LEFT JOIN
            EV_QTY_Event_Quantity "QTY"
        ON
            "QTY".EV_QTY_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.EV_PLC_ChangedAt) OVER (
                    PARTITION BY h.EV_PLC_EV_ID
                    ORDER BY h.EV_PLC_ChangedAt
                ) AS untilTime
            FROM
                EV_PLC_Event_Place h
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
