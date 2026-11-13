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
CREATE OR REPLACE FUNCTION nexuses.tEV_Event (
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
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "kETY_of".ETY_Checksum AS of_ETY_Checksum,
            "kETY_of".ETY_EventType AS of_ETY_EventType,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Who,
            "DAT".EV_DAT_Confidence,
            "DAT".EV_DAT_Stance,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Who,
            "AUD".EV_AUD_Confidence,
            "AUD".EV_AUD_Stance,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Who,
            "REV".EV_REV_Confidence,
            "REV".EV_REV_Stance,
            "REV".EV_REV_Event_Revenue,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ID,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_PositedAt,
            "STA".EV_STA_Who,
            "STA".EV_STA_Confidence,
            "STA".EV_STA_Stance,
            "STA".EV_STA_Event_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "UTL".EV_UTL_ID,
            "UTL".EV_UTL_PositedAt,
            "UTL".EV_UTL_Who,
            "UTL".EV_UTL_Confidence,
            "UTL".EV_UTL_Stance,
            "UTL".EV_UTL_UTL_Utilization,
            "UTL".EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ID,
            "LVL".EV_LVL_ChangedAt,
            "LVL".EV_LVL_PositedAt,
            "LVL".EV_LVL_Who,
            "LVL".EV_LVL_Confidence,
            "LVL".EV_LVL_Stance,
            "LVL".EV_LVL_PLV_Checksum,
            "LVL".EV_LVL_PLV_ProfessionalLevel,
            "LVL".EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            nexuses.EV_Event "EV"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN
            knots.ETY_EventType "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_DAT_Who, x.EV_DAT_EV_ID
                        ORDER BY
                            x.EV_DAT_PositedAt DESC,
                            x.EV_DAT_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_DAT,
                            po.EV_DAT_ID,
                            an.EV_DAT_PositedAt,
                            an.EV_DAT_Who,
                            an.EV_DAT_Confidence,
                            an.EV_DAT_Stance,
                            po.EV_DAT_EV_ID,
                            po.EV_DAT_Event_Date,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_DAT_ID, an.EV_DAT_Who
                                ORDER BY an.EV_DAT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_DAT_Event_Date_Fact po
                        JOIN
                            attributes.EV_DAT_Event_Date_Meta an
                        ON
                            an.EV_DAT_ID = po.EV_DAT_ID
                        WHERE
                            an.EV_DAT_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_DAT_Stance = COALESCE(assertion, x.EV_DAT_Stance)
            ) y
            WHERE
                y.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        AND
            "DAT".EV_DAT_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_AUD_Who, x.EV_AUD_EV_ID
                        ORDER BY
                            x.EV_AUD_PositedAt DESC,
                            x.EV_AUD_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_AUD,
                            po.EV_AUD_ID,
                            an.EV_AUD_PositedAt,
                            an.EV_AUD_Who,
                            an.EV_AUD_Confidence,
                            an.EV_AUD_Stance,
                            po.EV_AUD_EV_ID,
                            po.EV_AUD_Event_Audience,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_AUD_ID, an.EV_AUD_Who
                                ORDER BY an.EV_AUD_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_AUD_Event_Audience_Fact po
                        JOIN
                            attributes.EV_AUD_Event_Audience_Meta an
                        ON
                            an.EV_AUD_ID = po.EV_AUD_ID
                        WHERE
                            an.EV_AUD_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_AUD_Stance = COALESCE(assertion, x.EV_AUD_Stance)
            ) y
            WHERE
                y.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        AND
            "AUD".EV_AUD_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_REV_Who, x.EV_REV_EV_ID
                        ORDER BY
                            x.EV_REV_PositedAt DESC,
                            x.EV_REV_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_REV,
                            po.EV_REV_ID,
                            an.EV_REV_PositedAt,
                            an.EV_REV_Who,
                            an.EV_REV_Confidence,
                            an.EV_REV_Stance,
                            po.EV_REV_EV_ID,
                            po.EV_REV_Event_Revenue,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_REV_ID, an.EV_REV_Who
                                ORDER BY an.EV_REV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_REV_Event_Revenue_Fact po
                        JOIN
                            attributes.EV_REV_Event_Revenue_Meta an
                        ON
                            an.EV_REV_ID = po.EV_REV_ID
                        WHERE
                            an.EV_REV_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_REV_Stance = COALESCE(assertion, x.EV_REV_Stance)
            ) y
            WHERE
                y.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        AND
            "REV".EV_REV_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_STA_Who, x.EV_STA_EV_ID
                        ORDER BY
                            x.EV_STA_ChangedAt DESC,
                            x.EV_STA_PositedAt DESC,
                            x.EV_STA_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_STA_Stance <> '?' THEN r.EV_STA_ChangedAt END) OVER (
                            PARTITION BY r.EV_STA_Who, r.EV_STA_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_STA,
                            po.EV_STA_ID,
                            an.EV_STA_PositedAt,
                            an.EV_STA_Who,
                            an.EV_STA_Confidence,
                            an.EV_STA_Stance,
                            po.EV_STA_EV_ID,
                            po.EV_STA_Event_Status,
                            po.EV_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_STA_ID, an.EV_STA_Who
                                ORDER BY an.EV_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_STA_Event_Status_Fact po
                        JOIN
                            attributes.EV_STA_Event_Status_Meta an
                        ON
                            an.EV_STA_ID = po.EV_STA_ID
                        WHERE
                            po.EV_STA_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.EV_STA_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_STA_Stance = COALESCE(assertion, x.EV_STA_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.EV_STA_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS EV_UTL_Metadata_UTL,
                k.UTL_Utilization AS EV_UTL_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_UTL_Who, x.EV_UTL_EV_ID
                        ORDER BY
                            x.EV_UTL_PositedAt DESC,
                            x.EV_UTL_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_UTL,
                            po.EV_UTL_ID,
                            an.EV_UTL_PositedAt,
                            an.EV_UTL_Who,
                            an.EV_UTL_Confidence,
                            an.EV_UTL_Stance,
                            po.EV_UTL_EV_ID,
                            po.EV_UTL_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_UTL_ID, an.EV_UTL_Who
                                ORDER BY an.EV_UTL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_UTL_Event_Utilization_Fact po
                        JOIN
                            attributes.EV_UTL_Event_Utilization_Meta an
                        ON
                            an.EV_UTL_ID = po.EV_UTL_ID
                        WHERE
                            an.EV_UTL_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_UTL_Stance = COALESCE(assertion, x.EV_UTL_Stance)
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.EV_UTL_UTL_ID
            WHERE
                y.pickRank = 1
        ) "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        AND
            "UTL".EV_UTL_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS EV_LVL_PLV_Checksum,
                k.Metadata_PLV AS EV_LVL_Metadata_PLV,
                k.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_LVL_Who, x.EV_LVL_EV_ID
                        ORDER BY
                            x.EV_LVL_ChangedAt DESC,
                            x.EV_LVL_PositedAt DESC,
                            x.EV_LVL_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_LVL_Stance <> '?' THEN r.EV_LVL_ChangedAt END) OVER (
                            PARTITION BY r.EV_LVL_Who, r.EV_LVL_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_LVL,
                            po.EV_LVL_ID,
                            an.EV_LVL_PositedAt,
                            an.EV_LVL_Who,
                            an.EV_LVL_Confidence,
                            an.EV_LVL_Stance,
                            po.EV_LVL_EV_ID,
                            po.EV_LVL_PLV_ID,
                            po.EV_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_LVL_ID, an.EV_LVL_Who
                                ORDER BY an.EV_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_LVL_Event_Level_Fact po
                        JOIN
                            attributes.EV_LVL_Event_Level_Meta an
                        ON
                            an.EV_LVL_ID = po.EV_LVL_ID
                        WHERE
                            po.EV_LVL_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.EV_LVL_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_LVL_Stance = COALESCE(assertion, x.EV_LVL_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.EV_LVL_ChangedAt = x.inEffect
                )
            ) y
            LEFT JOIN
                knots.PLV_ProfessionalLevel k
            ON
                k.PLV_ID = y.EV_LVL_PLV_ID
            WHERE
                y.pickRank = 1
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_Who = positorTable.Who
        WHERE
            positorTable.Who = forPositor
    ]';
END tEV_Event;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.pEV_Event (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "kETY_of".ETY_Checksum AS of_ETY_Checksum,
            "kETY_of".ETY_EventType AS of_ETY_EventType,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Who,
            "DAT".EV_DAT_Confidence,
            "DAT".EV_DAT_Stance,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Who,
            "AUD".EV_AUD_Confidence,
            "AUD".EV_AUD_Stance,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Who,
            "REV".EV_REV_Confidence,
            "REV".EV_REV_Stance,
            "REV".EV_REV_Event_Revenue,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ID,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_PositedAt,
            "STA".EV_STA_Who,
            "STA".EV_STA_Confidence,
            "STA".EV_STA_Stance,
            "STA".EV_STA_Event_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "UTL".EV_UTL_ID,
            "UTL".EV_UTL_PositedAt,
            "UTL".EV_UTL_Who,
            "UTL".EV_UTL_Confidence,
            "UTL".EV_UTL_Stance,
            "UTL".EV_UTL_UTL_Utilization,
            "UTL".EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ID,
            "LVL".EV_LVL_ChangedAt,
            "LVL".EV_LVL_PositedAt,
            "LVL".EV_LVL_Who,
            "LVL".EV_LVL_Confidence,
            "LVL".EV_LVL_Stance,
            "LVL".EV_LVL_PLV_Checksum,
            "LVL".EV_LVL_PLV_ProfessionalLevel,
            "LVL".EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            nexuses.EV_Event "EV"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN
            knots.ETY_EventType "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_DAT_Who, x.EV_DAT_EV_ID
                        ORDER BY
                            x.EV_DAT_PositedAt DESC,
                            x.EV_DAT_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_DAT,
                            po.EV_DAT_ID,
                            an.EV_DAT_PositedAt,
                            an.EV_DAT_Who,
                            an.EV_DAT_Confidence,
                            an.EV_DAT_Stance,
                            po.EV_DAT_EV_ID,
                            po.EV_DAT_Event_Date,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_DAT_ID, an.EV_DAT_Who
                                ORDER BY an.EV_DAT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_DAT_Event_Date_Fact po
                        JOIN
                            attributes.EV_DAT_Event_Date_Meta an
                        ON
                            an.EV_DAT_ID = po.EV_DAT_ID
                        WHERE
                            an.EV_DAT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_DAT_Stance = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        AND
            "DAT".EV_DAT_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_AUD_Who, x.EV_AUD_EV_ID
                        ORDER BY
                            x.EV_AUD_PositedAt DESC,
                            x.EV_AUD_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_AUD,
                            po.EV_AUD_ID,
                            an.EV_AUD_PositedAt,
                            an.EV_AUD_Who,
                            an.EV_AUD_Confidence,
                            an.EV_AUD_Stance,
                            po.EV_AUD_EV_ID,
                            po.EV_AUD_Event_Audience,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_AUD_ID, an.EV_AUD_Who
                                ORDER BY an.EV_AUD_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_AUD_Event_Audience_Fact po
                        JOIN
                            attributes.EV_AUD_Event_Audience_Meta an
                        ON
                            an.EV_AUD_ID = po.EV_AUD_ID
                        WHERE
                            an.EV_AUD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_AUD_Stance = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        AND
            "AUD".EV_AUD_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_REV_Who, x.EV_REV_EV_ID
                        ORDER BY
                            x.EV_REV_PositedAt DESC,
                            x.EV_REV_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_REV,
                            po.EV_REV_ID,
                            an.EV_REV_PositedAt,
                            an.EV_REV_Who,
                            an.EV_REV_Confidence,
                            an.EV_REV_Stance,
                            po.EV_REV_EV_ID,
                            po.EV_REV_Event_Revenue,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_REV_ID, an.EV_REV_Who
                                ORDER BY an.EV_REV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_REV_Event_Revenue_Fact po
                        JOIN
                            attributes.EV_REV_Event_Revenue_Meta an
                        ON
                            an.EV_REV_ID = po.EV_REV_ID
                        WHERE
                            an.EV_REV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_REV_Stance = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        AND
            "REV".EV_REV_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_STA_Who, x.EV_STA_EV_ID
                        ORDER BY
                            x.EV_STA_ChangedAt DESC,
                            x.EV_STA_PositedAt DESC,
                            x.EV_STA_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_STA_Stance <> '?' THEN r.EV_STA_ChangedAt END) OVER (
                            PARTITION BY r.EV_STA_Who, r.EV_STA_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_STA,
                            po.EV_STA_ID,
                            an.EV_STA_PositedAt,
                            an.EV_STA_Who,
                            an.EV_STA_Confidence,
                            an.EV_STA_Stance,
                            po.EV_STA_EV_ID,
                            po.EV_STA_Event_Status,
                            po.EV_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_STA_ID, an.EV_STA_Who
                                ORDER BY an.EV_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_STA_Event_Status_Fact po
                        JOIN
                            attributes.EV_STA_Event_Status_Meta an
                        ON
                            an.EV_STA_ID = po.EV_STA_ID
                        WHERE
                            po.EV_STA_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.EV_STA_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_STA_Stance = '+'
                AND
                    x.EV_STA_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS EV_UTL_Metadata_UTL,
                k.UTL_Utilization AS EV_UTL_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_UTL_Who, x.EV_UTL_EV_ID
                        ORDER BY
                            x.EV_UTL_PositedAt DESC,
                            x.EV_UTL_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_UTL,
                            po.EV_UTL_ID,
                            an.EV_UTL_PositedAt,
                            an.EV_UTL_Who,
                            an.EV_UTL_Confidence,
                            an.EV_UTL_Stance,
                            po.EV_UTL_EV_ID,
                            po.EV_UTL_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_UTL_ID, an.EV_UTL_Who
                                ORDER BY an.EV_UTL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_UTL_Event_Utilization_Fact po
                        JOIN
                            attributes.EV_UTL_Event_Utilization_Meta an
                        ON
                            an.EV_UTL_ID = po.EV_UTL_ID
                        WHERE
                            an.EV_UTL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_UTL_Stance = '+'
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.EV_UTL_UTL_ID
            WHERE
                y.pickRank = 1
        ) "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        AND
            "UTL".EV_UTL_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS EV_LVL_PLV_Checksum,
                k.Metadata_PLV AS EV_LVL_Metadata_PLV,
                k.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_LVL_Who, x.EV_LVL_EV_ID
                        ORDER BY
                            x.EV_LVL_ChangedAt DESC,
                            x.EV_LVL_PositedAt DESC,
                            x.EV_LVL_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_LVL_Stance <> '?' THEN r.EV_LVL_ChangedAt END) OVER (
                            PARTITION BY r.EV_LVL_Who, r.EV_LVL_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_LVL,
                            po.EV_LVL_ID,
                            an.EV_LVL_PositedAt,
                            an.EV_LVL_Who,
                            an.EV_LVL_Confidence,
                            an.EV_LVL_Stance,
                            po.EV_LVL_EV_ID,
                            po.EV_LVL_PLV_ID,
                            po.EV_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_LVL_ID, an.EV_LVL_Who
                                ORDER BY an.EV_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_LVL_Event_Level_Fact po
                        JOIN
                            attributes.EV_LVL_Event_Level_Meta an
                        ON
                            an.EV_LVL_ID = po.EV_LVL_ID
                        WHERE
                            po.EV_LVL_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.EV_LVL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_LVL_Stance = '+'
                AND
                    x.EV_LVL_ChangedAt = x.inEffect
            ) y
            LEFT JOIN
                knots.PLV_ProfessionalLevel k
            ON
                k.PLV_ID = y.EV_LVL_PLV_ID
            WHERE
                y.pickRank = 1
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_Who = positorTable.Who
    ]';
END pEV_Event;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.lEV_Event
AS
SELECT
    *
FROM
    nexuses.pEV_Event(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.nEV_Event
AS
SELECT
    *
FROM
    nexuses.pEV_Event(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.dEV_Event (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            timepoints.inspectedTimepoint,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "kETY_of".ETY_Checksum AS of_ETY_Checksum,
            "kETY_of".ETY_EventType AS of_ETY_EventType,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Who,
            "DAT".EV_DAT_Confidence,
            "DAT".EV_DAT_Stance,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Who,
            "AUD".EV_AUD_Confidence,
            "AUD".EV_AUD_Stance,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Who,
            "REV".EV_REV_Confidence,
            "REV".EV_REV_Stance,
            "REV".EV_REV_Event_Revenue,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ID,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_PositedAt,
            "STA".EV_STA_Who,
            "STA".EV_STA_Confidence,
            "STA".EV_STA_Stance,
            "STA".EV_STA_Event_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "UTL".EV_UTL_ID,
            "UTL".EV_UTL_PositedAt,
            "UTL".EV_UTL_Who,
            "UTL".EV_UTL_Confidence,
            "UTL".EV_UTL_Stance,
            "kUTL".UTL_Utilization AS EV_UTL_UTL_Utilization,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ID,
            "LVL".EV_LVL_ChangedAt,
            "LVL".EV_LVL_PositedAt,
            "LVL".EV_LVL_Who,
            "LVL".EV_LVL_Confidence,
            "LVL".EV_LVL_Stance,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.EV_STA_Who AS inspectedPositor,
                h.EV_STA_EV_ID AS EV_ID,
                CAST(h.EV_STA_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'STA' AS mnemonic
            FROM
                attributes.EV_STA_Event_Status h
            WHERE
                (selection IS NULL OR selection LIKE '%STA%')
            AND
                h.EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.EV_LVL_Who AS inspectedPositor,
                h.EV_LVL_EV_ID AS EV_ID,
                CAST(h.EV_LVL_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'LVL' AS mnemonic
            FROM
                attributes.EV_LVL_Event_Level h
            WHERE
                (selection IS NULL OR selection LIKE '%LVL%')
            AND
                h.EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        ON
            timepoints.inspectedPositor = positorTable.Who
        JOIN
            nexuses.EV_Event "EV"
        ON
            "EV".EV_ID = timepoints.EV_ID
        LEFT JOIN
            knots.ETY_EventType "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_DAT_Who, r.EV_DAT_EV_ID
                        ORDER BY
                            r.EV_DAT_PositedAt DESC,
                            r.EV_DAT_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_DAT,
                        po.EV_DAT_ID,
                        an.EV_DAT_PositedAt,
                        an.EV_DAT_Who,
                        an.EV_DAT_Confidence,
                        an.EV_DAT_Stance,
                        po.EV_DAT_EV_ID,
                        po.EV_DAT_Event_Date,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_DAT_ID, an.EV_DAT_Who
                            ORDER BY an.EV_DAT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_DAT_Event_Date_Fact po
                    JOIN
                        attributes.EV_DAT_Event_Date_Meta an
                    ON
                        an.EV_DAT_ID = po.EV_DAT_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_DAT_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        AND
            "DAT".EV_DAT_Who = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_AUD_Who, r.EV_AUD_EV_ID
                        ORDER BY
                            r.EV_AUD_PositedAt DESC,
                            r.EV_AUD_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_AUD,
                        po.EV_AUD_ID,
                        an.EV_AUD_PositedAt,
                        an.EV_AUD_Who,
                        an.EV_AUD_Confidence,
                        an.EV_AUD_Stance,
                        po.EV_AUD_EV_ID,
                        po.EV_AUD_Event_Audience,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_AUD_ID, an.EV_AUD_Who
                            ORDER BY an.EV_AUD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_AUD_Event_Audience_Fact po
                    JOIN
                        attributes.EV_AUD_Event_Audience_Meta an
                    ON
                        an.EV_AUD_ID = po.EV_AUD_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_AUD_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        AND
            "AUD".EV_AUD_Who = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_REV_Who, r.EV_REV_EV_ID
                        ORDER BY
                            r.EV_REV_PositedAt DESC,
                            r.EV_REV_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_REV,
                        po.EV_REV_ID,
                        an.EV_REV_PositedAt,
                        an.EV_REV_Who,
                        an.EV_REV_Confidence,
                        an.EV_REV_Stance,
                        po.EV_REV_EV_ID,
                        po.EV_REV_Event_Revenue,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_REV_ID, an.EV_REV_Who
                            ORDER BY an.EV_REV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_REV_Event_Revenue_Fact po
                    JOIN
                        attributes.EV_REV_Event_Revenue_Meta an
                    ON
                        an.EV_REV_ID = po.EV_REV_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_REV_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        AND
            "REV".EV_REV_Who = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.EV_STA_ChangedAt) OVER (
                    PARTITION BY y.EV_STA_Who, y.EV_STA_EV_ID
                    ORDER BY y.EV_STA_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.EV_STA_Who, r.EV_STA_EV_ID, r.EV_STA_ChangedAt
                            ORDER BY
                                CASE WHEN r.EV_STA_Stance = '+' THEN 0 ELSE 1 END,
                                r.EV_STA_PositedAt DESC,
                                r.EV_STA_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_EV_STA,
                            po.EV_STA_ID,
                            an.EV_STA_PositedAt,
                            an.EV_STA_Who,
                            an.EV_STA_Confidence,
                            an.EV_STA_Stance,
                            po.EV_STA_EV_ID,
                            po.EV_STA_Event_Status,
                            po.EV_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_STA_ID, an.EV_STA_Who
                                ORDER BY an.EV_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_STA_Event_Status_Fact po
                        JOIN
                            attributes.EV_STA_Event_Status_Meta an
                        ON
                            an.EV_STA_ID = po.EV_STA_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.EV_STA_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_Who = timepoints.inspectedPositor
        AND
            "STA".EV_STA_Stance = '+'
        AND
            "STA".EV_STA_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "STA".untilTime IS NULL
        OR
            "STA".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_UTL_Who, r.EV_UTL_EV_ID
                        ORDER BY
                            r.EV_UTL_PositedAt DESC,
                            r.EV_UTL_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_UTL,
                        po.EV_UTL_ID,
                        an.EV_UTL_PositedAt,
                        an.EV_UTL_Who,
                        an.EV_UTL_Confidence,
                        an.EV_UTL_Stance,
                        po.EV_UTL_EV_ID,
                        po.EV_UTL_UTL_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_UTL_ID, an.EV_UTL_Who
                            ORDER BY an.EV_UTL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_UTL_Event_Utilization_Fact po
                    JOIN
                        attributes.EV_UTL_Event_Utilization_Meta an
                    ON
                        an.EV_UTL_ID = po.EV_UTL_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_UTL_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        AND
            "UTL".EV_UTL_Who = timepoints.inspectedPositor
        LEFT JOIN
            knots.UTL_Utilization "kUTL"
        ON
            "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.EV_LVL_ChangedAt) OVER (
                    PARTITION BY y.EV_LVL_Who, y.EV_LVL_EV_ID
                    ORDER BY y.EV_LVL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.EV_LVL_Who, r.EV_LVL_EV_ID, r.EV_LVL_ChangedAt
                            ORDER BY
                                CASE WHEN r.EV_LVL_Stance = '+' THEN 0 ELSE 1 END,
                                r.EV_LVL_PositedAt DESC,
                                r.EV_LVL_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_EV_LVL,
                            po.EV_LVL_ID,
                            an.EV_LVL_PositedAt,
                            an.EV_LVL_Who,
                            an.EV_LVL_Confidence,
                            an.EV_LVL_Stance,
                            po.EV_LVL_EV_ID,
                            po.EV_LVL_PLV_ID,
                            po.EV_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_LVL_ID, an.EV_LVL_Who
                                ORDER BY an.EV_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_LVL_Event_Level_Fact po
                        JOIN
                            attributes.EV_LVL_Event_Level_Meta an
                        ON
                            an.EV_LVL_ID = po.EV_LVL_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.EV_LVL_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_Who = timepoints.inspectedPositor
        AND
            "LVL".EV_LVL_Stance = '+'
        AND
            "LVL".EV_LVL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS date)
        AND (
            "LVL".untilTime IS NULL
        OR
            "LVL".untilTime > CAST(timepoints.inspectedTimepoint AS date)
        )
        LEFT JOIN
            knots.PLV_ProfessionalLevel "kLVL"
        ON
            "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
    ]';
END dEV_Event;
/
