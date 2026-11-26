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
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "kETY_of".ETY_EventType AS of_ETY_EventType,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Reliability,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Reliability,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Reliability,
            "REV".EV_REV_Event_Revenue
        FROM
            EV_Event "EV"
        LEFT JOIN
            ETY_EventType "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_DAT_EV_ID
                        ORDER BY
                            r.EV_DAT_PositedAt DESC,
                            r.EV_DAT_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_DAT,
                        po.EV_DAT_ID,
                        an.EV_DAT_PositedAt,
                        an.EV_DAT_Reliability,
                        po.EV_DAT_EV_ID,
                        po.EV_DAT_Event_Date,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_DAT_ID
                            ORDER BY an.EV_DAT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_DAT_Event_Date_Posit po
                    JOIN
                        EV_DAT_Event_Date_Annex an
                    ON
                        an.EV_DAT_ID = po.EV_DAT_ID
                    WHERE
                        an.EV_DAT_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_DAT_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_AUD_EV_ID
                        ORDER BY
                            r.EV_AUD_PositedAt DESC,
                            r.EV_AUD_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_AUD,
                        po.EV_AUD_ID,
                        an.EV_AUD_PositedAt,
                        an.EV_AUD_Reliability,
                        po.EV_AUD_EV_ID,
                        po.EV_AUD_Event_Audience,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_AUD_ID
                            ORDER BY an.EV_AUD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_AUD_Event_Audience_Posit po
                    JOIN
                        EV_AUD_Event_Audience_Annex an
                    ON
                        an.EV_AUD_ID = po.EV_AUD_ID
                    WHERE
                        an.EV_AUD_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_AUD_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_REV_EV_ID
                        ORDER BY
                            r.EV_REV_PositedAt DESC,
                            r.EV_REV_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_REV,
                        po.EV_REV_ID,
                        an.EV_REV_PositedAt,
                        an.EV_REV_Reliability,
                        po.EV_REV_EV_ID,
                        po.EV_REV_Event_Revenue,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_REV_ID
                            ORDER BY an.EV_REV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_REV_Event_Revenue_Posit po
                    JOIN
                        EV_REV_Event_Revenue_Annex an
                    ON
                        an.EV_REV_ID = po.EV_REV_ID
                    WHERE
                        an.EV_REV_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_REV_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
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
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "kETY_of".ETY_EventType AS of_ETY_EventType,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Reliability,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Reliability,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Reliability,
            "REV".EV_REV_Event_Revenue
        FROM
            EV_Event "EV"
        LEFT JOIN
            ETY_EventType "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_DAT_EV_ID
                        ORDER BY
                            r.EV_DAT_PositedAt DESC,
                            r.EV_DAT_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_DAT,
                        po.EV_DAT_ID,
                        an.EV_DAT_PositedAt,
                        an.EV_DAT_Reliability,
                        po.EV_DAT_EV_ID,
                        po.EV_DAT_Event_Date,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_DAT_ID
                            ORDER BY an.EV_DAT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_DAT_Event_Date_Posit po
                    JOIN
                        EV_DAT_Event_Date_Annex an
                    ON
                        an.EV_DAT_ID = po.EV_DAT_ID
                    WHERE
                        an.EV_DAT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_DAT_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_AUD_EV_ID
                        ORDER BY
                            r.EV_AUD_PositedAt DESC,
                            r.EV_AUD_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_AUD,
                        po.EV_AUD_ID,
                        an.EV_AUD_PositedAt,
                        an.EV_AUD_Reliability,
                        po.EV_AUD_EV_ID,
                        po.EV_AUD_Event_Audience,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_AUD_ID
                            ORDER BY an.EV_AUD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_AUD_Event_Audience_Posit po
                    JOIN
                        EV_AUD_Event_Audience_Annex an
                    ON
                        an.EV_AUD_ID = po.EV_AUD_ID
                    WHERE
                        an.EV_AUD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_AUD_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_REV_EV_ID
                        ORDER BY
                            r.EV_REV_PositedAt DESC,
                            r.EV_REV_ID DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_REV,
                        po.EV_REV_ID,
                        an.EV_REV_PositedAt,
                        an.EV_REV_Reliability,
                        po.EV_REV_EV_ID,
                        po.EV_REV_Event_Revenue,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_REV_ID
                            ORDER BY an.EV_REV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        EV_REV_Event_Revenue_Posit po
                    JOIN
                        EV_REV_Event_Revenue_Annex an
                    ON
                        an.EV_REV_ID = po.EV_REV_ID
                    WHERE
                        an.EV_REV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_REV_Reliability = 1
            ) y
            WHERE
                y.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
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
