-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_Actor(TIMESTAMP '2020-01-01 00:00:00').
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
CREATE OR REPLACE FUNCTION anchors.tST_Stage (
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
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Who,
            "NAM".ST_NAM_Confidence,
            "NAM".ST_NAM_Stance,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Who,
            "LOC".ST_LOC_Confidence,
            "LOC".ST_LOC_Stance,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Who,
            "AVG".ST_AVG_Confidence,
            "AVG".ST_AVG_Stance,
            "AVG".ST_AVG_UTL_Utilization,
            "AVG".ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Who,
            "MIN".ST_MIN_Confidence,
            "MIN".ST_MIN_Stance,
            "MIN".ST_MIN_UTL_Utilization,
            "MIN".ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            anchors.ST_Stage "ST"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_NAM_Who, x.ST_NAM_ST_ID
                        ORDER BY
                            x.ST_NAM_ChangedAt DESC,
                            x.ST_NAM_PositedAt DESC,
                            x.ST_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_NAM_Stance <> '?' THEN r.ST_NAM_ChangedAt END) OVER (
                            PARTITION BY r.ST_NAM_Who, r.ST_NAM_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Who,
                            an.ST_NAM_Confidence,
                            an.ST_NAM_Stance,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Stage_Name,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID, an.ST_NAM_Who
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_NAM_Stage_Name_Fact po
                        JOIN
                            attributes.ST_NAM_Stage_Name_Meta an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                        WHERE
                            po.ST_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_NAM_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_NAM_Stance = COALESCE(assertion, x.ST_NAM_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.ST_NAM_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_LOC_Who, x.ST_LOC_ST_ID
                        ORDER BY
                            x.ST_LOC_PositedAt DESC,
                            x.ST_LOC_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_LOC,
                            po.ST_LOC_ID,
                            an.ST_LOC_PositedAt,
                            an.ST_LOC_Who,
                            an.ST_LOC_Confidence,
                            an.ST_LOC_Stance,
                            po.ST_LOC_ST_ID,
                            po.ST_LOC_Checksum,
                            po.ST_LOC_Stage_Location,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_LOC_ID, an.ST_LOC_Who
                                ORDER BY an.ST_LOC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_LOC_Stage_Location_Fact po
                        JOIN
                            attributes.ST_LOC_Stage_Location_Meta an
                        ON
                            an.ST_LOC_ID = po.ST_LOC_ID
                        WHERE
                            an.ST_LOC_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_LOC_Stance = COALESCE(assertion, x.ST_LOC_Stance)
            ) y
            WHERE
                y.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        AND
            "LOC".ST_LOC_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_AVG_Metadata_UTL,
                k.UTL_Utilization AS ST_AVG_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_AVG_Who, x.ST_AVG_ST_ID
                        ORDER BY
                            x.ST_AVG_ChangedAt DESC,
                            x.ST_AVG_PositedAt DESC,
                            x.ST_AVG_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_AVG_Stance <> '?' THEN r.ST_AVG_ChangedAt END) OVER (
                            PARTITION BY r.ST_AVG_Who, r.ST_AVG_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Who,
                            an.ST_AVG_Confidence,
                            an.ST_AVG_Stance,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID, an.ST_AVG_Who
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_AVG_Stage_Average_Fact po
                        JOIN
                            attributes.ST_AVG_Stage_Average_Meta an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                        WHERE
                            po.ST_AVG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_AVG_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_AVG_Stance = COALESCE(assertion, x.ST_AVG_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.ST_AVG_ChangedAt = x.inEffect
                )
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.ST_AVG_UTL_ID
            WHERE
                y.pickRank = 1
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_MIN_Metadata_UTL,
                k.UTL_Utilization AS ST_MIN_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_MIN_Who, x.ST_MIN_ST_ID
                        ORDER BY
                            x.ST_MIN_PositedAt DESC,
                            x.ST_MIN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_MIN,
                            po.ST_MIN_ID,
                            an.ST_MIN_PositedAt,
                            an.ST_MIN_Who,
                            an.ST_MIN_Confidence,
                            an.ST_MIN_Stance,
                            po.ST_MIN_ST_ID,
                            po.ST_MIN_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_MIN_ID, an.ST_MIN_Who
                                ORDER BY an.ST_MIN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_MIN_Stage_Minimum_Fact po
                        JOIN
                            attributes.ST_MIN_Stage_Minimum_Meta an
                        ON
                            an.ST_MIN_ID = po.ST_MIN_ID
                        WHERE
                            an.ST_MIN_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_MIN_Stance = COALESCE(assertion, x.ST_MIN_Stance)
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.ST_MIN_UTL_ID
            WHERE
                y.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        AND
            "MIN".ST_MIN_Who = positorTable.Who
        WHERE
            positorTable.Who = forPositor
    ]';
END tST_Stage;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pST_Stage (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Who,
            "NAM".ST_NAM_Confidence,
            "NAM".ST_NAM_Stance,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Who,
            "LOC".ST_LOC_Confidence,
            "LOC".ST_LOC_Stance,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Who,
            "AVG".ST_AVG_Confidence,
            "AVG".ST_AVG_Stance,
            "AVG".ST_AVG_UTL_Utilization,
            "AVG".ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Who,
            "MIN".ST_MIN_Confidence,
            "MIN".ST_MIN_Stance,
            "MIN".ST_MIN_UTL_Utilization,
            "MIN".ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            anchors.ST_Stage "ST"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_NAM_Who, x.ST_NAM_ST_ID
                        ORDER BY
                            x.ST_NAM_ChangedAt DESC,
                            x.ST_NAM_PositedAt DESC,
                            x.ST_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_NAM_Stance <> '?' THEN r.ST_NAM_ChangedAt END) OVER (
                            PARTITION BY r.ST_NAM_Who, r.ST_NAM_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Who,
                            an.ST_NAM_Confidence,
                            an.ST_NAM_Stance,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Stage_Name,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID, an.ST_NAM_Who
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_NAM_Stage_Name_Fact po
                        JOIN
                            attributes.ST_NAM_Stage_Name_Meta an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                        WHERE
                            po.ST_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_NAM_Stance = '+'
                AND
                    x.ST_NAM_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_LOC_Who, x.ST_LOC_ST_ID
                        ORDER BY
                            x.ST_LOC_PositedAt DESC,
                            x.ST_LOC_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_LOC,
                            po.ST_LOC_ID,
                            an.ST_LOC_PositedAt,
                            an.ST_LOC_Who,
                            an.ST_LOC_Confidence,
                            an.ST_LOC_Stance,
                            po.ST_LOC_ST_ID,
                            po.ST_LOC_Checksum,
                            po.ST_LOC_Stage_Location,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_LOC_ID, an.ST_LOC_Who
                                ORDER BY an.ST_LOC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_LOC_Stage_Location_Fact po
                        JOIN
                            attributes.ST_LOC_Stage_Location_Meta an
                        ON
                            an.ST_LOC_ID = po.ST_LOC_ID
                        WHERE
                            an.ST_LOC_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_LOC_Stance = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        AND
            "LOC".ST_LOC_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_AVG_Metadata_UTL,
                k.UTL_Utilization AS ST_AVG_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_AVG_Who, x.ST_AVG_ST_ID
                        ORDER BY
                            x.ST_AVG_ChangedAt DESC,
                            x.ST_AVG_PositedAt DESC,
                            x.ST_AVG_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_AVG_Stance <> '?' THEN r.ST_AVG_ChangedAt END) OVER (
                            PARTITION BY r.ST_AVG_Who, r.ST_AVG_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Who,
                            an.ST_AVG_Confidence,
                            an.ST_AVG_Stance,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID, an.ST_AVG_Who
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_AVG_Stage_Average_Fact po
                        JOIN
                            attributes.ST_AVG_Stage_Average_Meta an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                        WHERE
                            po.ST_AVG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_AVG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_AVG_Stance = '+'
                AND
                    x.ST_AVG_ChangedAt = x.inEffect
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.ST_AVG_UTL_ID
            WHERE
                y.pickRank = 1
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_MIN_Metadata_UTL,
                k.UTL_Utilization AS ST_MIN_UTL_Utilization
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_MIN_Who, x.ST_MIN_ST_ID
                        ORDER BY
                            x.ST_MIN_PositedAt DESC,
                            x.ST_MIN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_MIN,
                            po.ST_MIN_ID,
                            an.ST_MIN_PositedAt,
                            an.ST_MIN_Who,
                            an.ST_MIN_Confidence,
                            an.ST_MIN_Stance,
                            po.ST_MIN_ST_ID,
                            po.ST_MIN_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_MIN_ID, an.ST_MIN_Who
                                ORDER BY an.ST_MIN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_MIN_Stage_Minimum_Fact po
                        JOIN
                            attributes.ST_MIN_Stage_Minimum_Meta an
                        ON
                            an.ST_MIN_ID = po.ST_MIN_ID
                        WHERE
                            an.ST_MIN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_MIN_Stance = '+'
            ) y
            LEFT JOIN
                knots.UTL_Utilization k
            ON
                k.UTL_ID = y.ST_MIN_UTL_ID
            WHERE
                y.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        AND
            "MIN".ST_MIN_Who = positorTable.Who
    ]';
END pST_Stage;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lST_Stage
AS
SELECT
    *
FROM
    anchors.pST_Stage(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nST_Stage
AS
SELECT
    *
FROM
    anchors.pST_Stage(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dST_Stage (
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
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Who,
            "NAM".ST_NAM_Confidence,
            "NAM".ST_NAM_Stance,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Who,
            "LOC".ST_LOC_Confidence,
            "LOC".ST_LOC_Stance,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Who,
            "AVG".ST_AVG_Confidence,
            "AVG".ST_AVG_Stance,
            "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Who,
            "MIN".ST_MIN_Confidence,
            "MIN".ST_MIN_Stance,
            "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.ST_NAM_Who AS inspectedPositor,
                h.ST_NAM_ST_ID AS ST_ID,
                CAST(h.ST_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                attributes.ST_NAM_Stage_Name h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.ST_AVG_Who AS inspectedPositor,
                h.ST_AVG_ST_ID AS ST_ID,
                CAST(h.ST_AVG_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'AVG' AS mnemonic
            FROM
                attributes.ST_AVG_Stage_Average h
            WHERE
                (selection IS NULL OR selection LIKE '%AVG%')
            AND
                h.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        ON
            timepoints.inspectedPositor = positorTable.Who
        JOIN
            anchors.ST_Stage "ST"
        ON
            "ST".ST_ID = timepoints.ST_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.ST_NAM_ChangedAt) OVER (
                    PARTITION BY y.ST_NAM_Who, y.ST_NAM_ST_ID
                    ORDER BY y.ST_NAM_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.ST_NAM_Who, r.ST_NAM_ST_ID, r.ST_NAM_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_NAM_Stance = '+' THEN 0 ELSE 1 END,
                                r.ST_NAM_PositedAt DESC,
                                r.ST_NAM_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Who,
                            an.ST_NAM_Confidence,
                            an.ST_NAM_Stance,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Stage_Name,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID, an.ST_NAM_Who
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_NAM_Stage_Name_Fact po
                        JOIN
                            attributes.ST_NAM_Stage_Name_Meta an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_NAM_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_Who = timepoints.inspectedPositor
        AND
            "NAM".ST_NAM_Stance = '+'
        AND
            "NAM".ST_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_LOC_Who, r.ST_LOC_ST_ID
                        ORDER BY
                            r.ST_LOC_PositedAt DESC,
                            r.ST_LOC_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_LOC,
                        po.ST_LOC_ID,
                        an.ST_LOC_PositedAt,
                        an.ST_LOC_Who,
                        an.ST_LOC_Confidence,
                        an.ST_LOC_Stance,
                        po.ST_LOC_ST_ID,
                        po.ST_LOC_Checksum,
                        po.ST_LOC_Stage_Location,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_LOC_ID, an.ST_LOC_Who
                            ORDER BY an.ST_LOC_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.ST_LOC_Stage_Location_Fact po
                    JOIN
                        attributes.ST_LOC_Stage_Location_Meta an
                    ON
                        an.ST_LOC_ID = po.ST_LOC_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_LOC_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        AND
            "LOC".ST_LOC_Who = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.ST_AVG_ChangedAt) OVER (
                    PARTITION BY y.ST_AVG_Who, y.ST_AVG_ST_ID
                    ORDER BY y.ST_AVG_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.ST_AVG_Who, r.ST_AVG_ST_ID, r.ST_AVG_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_AVG_Stance = '+' THEN 0 ELSE 1 END,
                                r.ST_AVG_PositedAt DESC,
                                r.ST_AVG_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Who,
                            an.ST_AVG_Confidence,
                            an.ST_AVG_Stance,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID, an.ST_AVG_Who
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_AVG_Stage_Average_Fact po
                        JOIN
                            attributes.ST_AVG_Stage_Average_Meta an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_AVG_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_Who = timepoints.inspectedPositor
        AND
            "AVG".ST_AVG_Stance = '+'
        AND
            "AVG".ST_AVG_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "AVG".untilTime IS NULL
        OR
            "AVG".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_MIN_Who, r.ST_MIN_ST_ID
                        ORDER BY
                            r.ST_MIN_PositedAt DESC,
                            r.ST_MIN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_MIN,
                        po.ST_MIN_ID,
                        an.ST_MIN_PositedAt,
                        an.ST_MIN_Who,
                        an.ST_MIN_Confidence,
                        an.ST_MIN_Stance,
                        po.ST_MIN_ST_ID,
                        po.ST_MIN_UTL_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_MIN_ID, an.ST_MIN_Who
                            ORDER BY an.ST_MIN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.ST_MIN_Stage_Minimum_Fact po
                    JOIN
                        attributes.ST_MIN_Stage_Minimum_Meta an
                    ON
                        an.ST_MIN_ID = po.ST_MIN_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_MIN_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        AND
            "MIN".ST_MIN_Who = timepoints.inspectedPositor
        LEFT JOIN
            knots.UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END dST_Stage;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tAC_Actor (
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
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Who,
            "NAM".AC_NAM_Confidence,
            "NAM".AC_NAM_Stance,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Who,
            "GEN".AC_GEN_Confidence,
            "GEN".AC_GEN_Stance,
            "GEN".AC_GEN_GEN_Checksum,
            "GEN".AC_GEN_GEN_Gender,
            "GEN".AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Who,
            "PLV".AC_PLV_Confidence,
            "PLV".AC_PLV_Stance,
            "PLV".AC_PLV_PLV_Checksum,
            "PLV".AC_PLV_PLV_ProfessionalLevel,
            "PLV".AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            anchors.AC_Actor "AC"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_NAM_Who, x.AC_NAM_AC_ID
                        ORDER BY
                            x.AC_NAM_ChangedAt DESC,
                            x.AC_NAM_PositedAt DESC,
                            x.AC_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_NAM_Stance <> '?' THEN r.AC_NAM_ChangedAt END) OVER (
                            PARTITION BY r.AC_NAM_Who, r.AC_NAM_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Who,
                            an.AC_NAM_Confidence,
                            an.AC_NAM_Stance,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Actor_Name,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID, an.AC_NAM_Who
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_NAM_Actor_Name_Fact po
                        JOIN
                            attributes.AC_NAM_Actor_Name_Meta an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                        WHERE
                            po.AC_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_NAM_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_NAM_Stance = COALESCE(assertion, x.AC_NAM_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.AC_NAM_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.GEN_Checksum AS AC_GEN_GEN_Checksum,
                k.Metadata_GEN AS AC_GEN_Metadata_GEN,
                k.GEN_Gender AS AC_GEN_GEN_Gender
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_GEN_Who, x.AC_GEN_AC_ID
                        ORDER BY
                            x.AC_GEN_PositedAt DESC,
                            x.AC_GEN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_AC_GEN,
                            po.AC_GEN_ID,
                            an.AC_GEN_PositedAt,
                            an.AC_GEN_Who,
                            an.AC_GEN_Confidence,
                            an.AC_GEN_Stance,
                            po.AC_GEN_AC_ID,
                            po.AC_GEN_GEN_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_GEN_ID, an.AC_GEN_Who
                                ORDER BY an.AC_GEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_GEN_Actor_Gender_Fact po
                        JOIN
                            attributes.AC_GEN_Actor_Gender_Meta an
                        ON
                            an.AC_GEN_ID = po.AC_GEN_ID
                        WHERE
                            an.AC_GEN_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_GEN_Stance = COALESCE(assertion, x.AC_GEN_Stance)
            ) y
            LEFT JOIN
                knots.GEN_Gender k
            ON
                k.GEN_ID = y.AC_GEN_GEN_ID
            WHERE
                y.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        AND
            "GEN".AC_GEN_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS AC_PLV_PLV_Checksum,
                k.Metadata_PLV AS AC_PLV_Metadata_PLV,
                k.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_PLV_Who, x.AC_PLV_AC_ID
                        ORDER BY
                            x.AC_PLV_ChangedAt DESC,
                            x.AC_PLV_PositedAt DESC,
                            x.AC_PLV_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_PLV_Stance <> '?' THEN r.AC_PLV_ChangedAt END) OVER (
                            PARTITION BY r.AC_PLV_Who, r.AC_PLV_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Who,
                            an.AC_PLV_Confidence,
                            an.AC_PLV_Stance,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID, an.AC_PLV_Who
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_PLV_Actor_ProfessionalLevel_Fact po
                        JOIN
                            attributes.AC_PLV_Actor_ProfessionalLevel_Meta an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                        WHERE
                            po.AC_PLV_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_PLV_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_PLV_Stance = COALESCE(assertion, x.AC_PLV_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.AC_PLV_ChangedAt = x.inEffect
                )
            ) y
            LEFT JOIN
                knots.PLV_ProfessionalLevel k
            ON
                k.PLV_ID = y.AC_PLV_PLV_ID
            WHERE
                y.pickRank = 1
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_Who = positorTable.Who
        WHERE
            positorTable.Who = forPositor
    ]';
END tAC_Actor;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pAC_Actor (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Who,
            "NAM".AC_NAM_Confidence,
            "NAM".AC_NAM_Stance,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Who,
            "GEN".AC_GEN_Confidence,
            "GEN".AC_GEN_Stance,
            "GEN".AC_GEN_GEN_Checksum,
            "GEN".AC_GEN_GEN_Gender,
            "GEN".AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Who,
            "PLV".AC_PLV_Confidence,
            "PLV".AC_PLV_Stance,
            "PLV".AC_PLV_PLV_Checksum,
            "PLV".AC_PLV_PLV_ProfessionalLevel,
            "PLV".AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            anchors.AC_Actor "AC"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_NAM_Who, x.AC_NAM_AC_ID
                        ORDER BY
                            x.AC_NAM_ChangedAt DESC,
                            x.AC_NAM_PositedAt DESC,
                            x.AC_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_NAM_Stance <> '?' THEN r.AC_NAM_ChangedAt END) OVER (
                            PARTITION BY r.AC_NAM_Who, r.AC_NAM_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Who,
                            an.AC_NAM_Confidence,
                            an.AC_NAM_Stance,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Actor_Name,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID, an.AC_NAM_Who
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_NAM_Actor_Name_Fact po
                        JOIN
                            attributes.AC_NAM_Actor_Name_Meta an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                        WHERE
                            po.AC_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_NAM_Stance = '+'
                AND
                    x.AC_NAM_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.GEN_Checksum AS AC_GEN_GEN_Checksum,
                k.Metadata_GEN AS AC_GEN_Metadata_GEN,
                k.GEN_Gender AS AC_GEN_GEN_Gender
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_GEN_Who, x.AC_GEN_AC_ID
                        ORDER BY
                            x.AC_GEN_PositedAt DESC,
                            x.AC_GEN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_AC_GEN,
                            po.AC_GEN_ID,
                            an.AC_GEN_PositedAt,
                            an.AC_GEN_Who,
                            an.AC_GEN_Confidence,
                            an.AC_GEN_Stance,
                            po.AC_GEN_AC_ID,
                            po.AC_GEN_GEN_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_GEN_ID, an.AC_GEN_Who
                                ORDER BY an.AC_GEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_GEN_Actor_Gender_Fact po
                        JOIN
                            attributes.AC_GEN_Actor_Gender_Meta an
                        ON
                            an.AC_GEN_ID = po.AC_GEN_ID
                        WHERE
                            an.AC_GEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_GEN_Stance = '+'
            ) y
            LEFT JOIN
                knots.GEN_Gender k
            ON
                k.GEN_ID = y.AC_GEN_GEN_ID
            WHERE
                y.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        AND
            "GEN".AC_GEN_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS AC_PLV_PLV_Checksum,
                k.Metadata_PLV AS AC_PLV_Metadata_PLV,
                k.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_PLV_Who, x.AC_PLV_AC_ID
                        ORDER BY
                            x.AC_PLV_ChangedAt DESC,
                            x.AC_PLV_PositedAt DESC,
                            x.AC_PLV_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_PLV_Stance <> '?' THEN r.AC_PLV_ChangedAt END) OVER (
                            PARTITION BY r.AC_PLV_Who, r.AC_PLV_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Who,
                            an.AC_PLV_Confidence,
                            an.AC_PLV_Stance,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID, an.AC_PLV_Who
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_PLV_Actor_ProfessionalLevel_Fact po
                        JOIN
                            attributes.AC_PLV_Actor_ProfessionalLevel_Meta an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                        WHERE
                            po.AC_PLV_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_PLV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_PLV_Stance = '+'
                AND
                    x.AC_PLV_ChangedAt = x.inEffect
            ) y
            LEFT JOIN
                knots.PLV_ProfessionalLevel k
            ON
                k.PLV_ID = y.AC_PLV_PLV_ID
            WHERE
                y.pickRank = 1
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_Who = positorTable.Who
    ]';
END pAC_Actor;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lAC_Actor
AS
SELECT
    *
FROM
    anchors.pAC_Actor(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nAC_Actor
AS
SELECT
    *
FROM
    anchors.pAC_Actor(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dAC_Actor (
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
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Who,
            "NAM".AC_NAM_Confidence,
            "NAM".AC_NAM_Stance,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Who,
            "GEN".AC_GEN_Confidence,
            "GEN".AC_GEN_Stance,
            "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
            "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Who,
            "PLV".AC_PLV_Confidence,
            "PLV".AC_PLV_Stance,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_NAM_Who AS inspectedPositor,
                h.AC_NAM_AC_ID AS AC_ID,
                CAST(h.AC_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                attributes.AC_NAM_Actor_Name h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.AC_PLV_Who AS inspectedPositor,
                h.AC_PLV_AC_ID AS AC_ID,
                CAST(h.AC_PLV_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'PLV' AS mnemonic
            FROM
                attributes.AC_PLV_Actor_ProfessionalLevel h
            WHERE
                (selection IS NULL OR selection LIKE '%PLV%')
            AND
                h.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        ON
            timepoints.inspectedPositor = positorTable.Who
        JOIN
            anchors.AC_Actor "AC"
        ON
            "AC".AC_ID = timepoints.AC_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.AC_NAM_ChangedAt) OVER (
                    PARTITION BY y.AC_NAM_Who, y.AC_NAM_AC_ID
                    ORDER BY y.AC_NAM_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.AC_NAM_Who, r.AC_NAM_AC_ID, r.AC_NAM_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_NAM_Stance = '+' THEN 0 ELSE 1 END,
                                r.AC_NAM_PositedAt DESC,
                                r.AC_NAM_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Who,
                            an.AC_NAM_Confidence,
                            an.AC_NAM_Stance,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Actor_Name,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID, an.AC_NAM_Who
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_NAM_Actor_Name_Fact po
                        JOIN
                            attributes.AC_NAM_Actor_Name_Meta an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_NAM_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_Who = timepoints.inspectedPositor
        AND
            "NAM".AC_NAM_Stance = '+'
        AND
            "NAM".AC_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_GEN_Who, r.AC_GEN_AC_ID
                        ORDER BY
                            r.AC_GEN_PositedAt DESC,
                            r.AC_GEN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_GEN,
                        po.AC_GEN_ID,
                        an.AC_GEN_PositedAt,
                        an.AC_GEN_Who,
                        an.AC_GEN_Confidence,
                        an.AC_GEN_Stance,
                        po.AC_GEN_AC_ID,
                        po.AC_GEN_GEN_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_GEN_ID, an.AC_GEN_Who
                            ORDER BY an.AC_GEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.AC_GEN_Actor_Gender_Fact po
                    JOIN
                        attributes.AC_GEN_Actor_Gender_Meta an
                    ON
                        an.AC_GEN_ID = po.AC_GEN_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_GEN_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        AND
            "GEN".AC_GEN_Who = timepoints.inspectedPositor
        LEFT JOIN
            knots.GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.AC_PLV_ChangedAt) OVER (
                    PARTITION BY y.AC_PLV_Who, y.AC_PLV_AC_ID
                    ORDER BY y.AC_PLV_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.AC_PLV_Who, r.AC_PLV_AC_ID, r.AC_PLV_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_PLV_Stance = '+' THEN 0 ELSE 1 END,
                                r.AC_PLV_PositedAt DESC,
                                r.AC_PLV_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Who,
                            an.AC_PLV_Confidence,
                            an.AC_PLV_Stance,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID, an.AC_PLV_Who
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_PLV_Actor_ProfessionalLevel_Fact po
                        JOIN
                            attributes.AC_PLV_Actor_ProfessionalLevel_Meta an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_PLV_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_Who = timepoints.inspectedPositor
        AND
            "PLV".AC_PLV_Stance = '+'
        AND
            "PLV".AC_PLV_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "PLV".untilTime IS NULL
        OR
            "PLV".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END dAC_Actor;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tPR_Program (
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
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Who,
            "NAM".PR_NAM_Confidence,
            "NAM".PR_NAM_Stance,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Who,
            "LEN".PR_LEN_Confidence,
            "LEN".PR_LEN_Stance,
            "LEN".PR_LEN_Program_Length
        FROM
            anchors.PR_Program "PR"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_NAM_Who, x.PR_NAM_PR_ID
                        ORDER BY
                            x.PR_NAM_PositedAt DESC,
                            x.PR_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_PR_NAM,
                            po.PR_NAM_ID,
                            an.PR_NAM_PositedAt,
                            an.PR_NAM_Who,
                            an.PR_NAM_Confidence,
                            an.PR_NAM_Stance,
                            po.PR_NAM_PR_ID,
                            po.PR_NAM_Program_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_NAM_ID, an.PR_NAM_Who
                                ORDER BY an.PR_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_NAM_Program_Name_Fact po
                        JOIN
                            attributes.PR_NAM_Program_Name_Meta an
                        ON
                            an.PR_NAM_ID = po.PR_NAM_ID
                        WHERE
                            an.PR_NAM_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_NAM_Stance = COALESCE(assertion, x.PR_NAM_Stance)
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        AND
            "NAM".PR_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_LEN_Who, x.PR_LEN_PR_ID
                        ORDER BY
                            x.PR_LEN_ChangedAt DESC,
                            x.PR_LEN_PositedAt DESC,
                            x.PR_LEN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.PR_LEN_Stance <> '?' THEN r.PR_LEN_ChangedAt END) OVER (
                            PARTITION BY r.PR_LEN_Who, r.PR_LEN_PR_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Who,
                            an.PR_LEN_Confidence,
                            an.PR_LEN_Stance,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Program_Length,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID, an.PR_LEN_Who
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_LEN_Program_Length_Fact po
                        JOIN
                            attributes.PR_LEN_Program_Length_Meta an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                        WHERE
                            po.PR_LEN_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.PR_LEN_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_LEN_Stance = COALESCE(assertion, x.PR_LEN_Stance)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.PR_LEN_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
        AND
            "LEN".PR_LEN_Who = positorTable.Who
        WHERE
            positorTable.Who = forPositor
    ]';
END tPR_Program;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pPR_Program (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Who,
            "NAM".PR_NAM_Confidence,
            "NAM".PR_NAM_Stance,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Who,
            "LEN".PR_LEN_Confidence,
            "LEN".PR_LEN_Stance,
            "LEN".PR_LEN_Program_Length
        FROM
            anchors.PR_Program "PR"
        CROSS JOIN
            dw.Who_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_NAM_Who, x.PR_NAM_PR_ID
                        ORDER BY
                            x.PR_NAM_PositedAt DESC,
                            x.PR_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_PR_NAM,
                            po.PR_NAM_ID,
                            an.PR_NAM_PositedAt,
                            an.PR_NAM_Who,
                            an.PR_NAM_Confidence,
                            an.PR_NAM_Stance,
                            po.PR_NAM_PR_ID,
                            po.PR_NAM_Program_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_NAM_ID, an.PR_NAM_Who
                                ORDER BY an.PR_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_NAM_Program_Name_Fact po
                        JOIN
                            attributes.PR_NAM_Program_Name_Meta an
                        ON
                            an.PR_NAM_ID = po.PR_NAM_ID
                        WHERE
                            an.PR_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_NAM_Stance = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        AND
            "NAM".PR_NAM_Who = positorTable.Who
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_LEN_Who, x.PR_LEN_PR_ID
                        ORDER BY
                            x.PR_LEN_ChangedAt DESC,
                            x.PR_LEN_PositedAt DESC,
                            x.PR_LEN_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.PR_LEN_Stance <> '?' THEN r.PR_LEN_ChangedAt END) OVER (
                            PARTITION BY r.PR_LEN_Who, r.PR_LEN_PR_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Who,
                            an.PR_LEN_Confidence,
                            an.PR_LEN_Stance,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Program_Length,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID, an.PR_LEN_Who
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_LEN_Program_Length_Fact po
                        JOIN
                            attributes.PR_LEN_Program_Length_Meta an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                        WHERE
                            po.PR_LEN_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.PR_LEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_LEN_Stance = '+'
                AND
                    x.PR_LEN_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
        AND
            "LEN".PR_LEN_Who = positorTable.Who
    ]';
END pPR_Program;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lPR_Program
AS
SELECT
    *
FROM
    anchors.pPR_Program(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nPR_Program
AS
SELECT
    *
FROM
    anchors.pPR_Program(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dPR_Program (
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
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Who,
            "NAM".PR_NAM_Confidence,
            "NAM".PR_NAM_Stance,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Who,
            "LEN".PR_LEN_Confidence,
            "LEN".PR_LEN_Stance,
            "LEN".PR_LEN_Program_Length
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.PR_LEN_Who AS inspectedPositor,
                h.PR_LEN_PR_ID AS PR_ID,
                CAST(h.PR_LEN_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'LEN' AS mnemonic
            FROM
                attributes.PR_LEN_Program_Length h
            WHERE
                (selection IS NULL OR selection LIKE '%LEN%')
            AND
                h.PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        ON
            timepoints.inspectedPositor = positorTable.Who
        JOIN
            anchors.PR_Program "PR"
        ON
            "PR".PR_ID = timepoints.PR_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_NAM_Who, r.PR_NAM_PR_ID
                        ORDER BY
                            r.PR_NAM_PositedAt DESC,
                            r.PR_NAM_Confidence DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_NAM,
                        po.PR_NAM_ID,
                        an.PR_NAM_PositedAt,
                        an.PR_NAM_Who,
                        an.PR_NAM_Confidence,
                        an.PR_NAM_Stance,
                        po.PR_NAM_PR_ID,
                        po.PR_NAM_Program_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_NAM_ID, an.PR_NAM_Who
                            ORDER BY an.PR_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.PR_NAM_Program_Name_Fact po
                    JOIN
                        attributes.PR_NAM_Program_Name_Meta an
                    ON
                        an.PR_NAM_ID = po.PR_NAM_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_NAM_Stance = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        AND
            "NAM".PR_NAM_Who = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.PR_LEN_ChangedAt) OVER (
                    PARTITION BY y.PR_LEN_Who, y.PR_LEN_PR_ID
                    ORDER BY y.PR_LEN_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.PR_LEN_Who, r.PR_LEN_PR_ID, r.PR_LEN_ChangedAt
                            ORDER BY
                                CASE WHEN r.PR_LEN_Stance = '+' THEN 0 ELSE 1 END,
                                r.PR_LEN_PositedAt DESC,
                                r.PR_LEN_Confidence DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Who,
                            an.PR_LEN_Confidence,
                            an.PR_LEN_Stance,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Program_Length,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID, an.PR_LEN_Who
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_LEN_Program_Length_Fact po
                        JOIN
                            attributes.PR_LEN_Program_Length_Meta an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.PR_LEN_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
        AND
            "LEN".PR_LEN_Who = timepoints.inspectedPositor
        AND
            "LEN".PR_LEN_Stance = '+'
        AND
            "LEN".PR_LEN_ChangedAt <= CAST(timepoints.inspectedTimepoint AS date)
        AND (
            "LEN".untilTime IS NULL
        OR
            "LEN".untilTime > CAST(timepoints.inspectedTimepoint AS date)
        )
    ]';
END dPR_Program;
/
