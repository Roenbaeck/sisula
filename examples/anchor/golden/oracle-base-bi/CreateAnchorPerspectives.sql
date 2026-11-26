-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM tAC_Actor(TIMESTAMP '9999-12-31 00:00:00', TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex with the latest positing time up to the positing timepoint picked for each posit.
-- A posit is shown when that annex says that it is asserted (a reliability of 1), and for each anchor the latest asserted
-- posit at the latest changing time is the one that is shown.
--
-- The latest and now perspectives are views over the point-in-time macro, which is the time traveling perspective with the
-- positing time set to End of Time, and as the macros are not nested the point-in-time macro works out the posits itself.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest asserted posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tST_Stage (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            "NAM".ST_NAM_Reliability,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Reliability,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Reliability,
            "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Reliability,
            "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            ST_Stage "ST"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_NAM_ST_ID
                        ORDER BY
                            r.ST_NAM_ChangedAt DESC,
                            r.ST_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_NAM,
                        po.ST_NAM_ID,
                        an.ST_NAM_PositedAt,
                        an.ST_NAM_Reliability,
                        po.ST_NAM_ST_ID,
                        po.ST_NAM_Stage_Name,
                        po.ST_NAM_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_NAM_ID
                            ORDER BY an.ST_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_NAM_Stage_Name_Posit po
                    JOIN
                        ST_NAM_Stage_Name_Annex an
                    ON
                        an.ST_NAM_ID = po.ST_NAM_ID
                    WHERE
                        po.ST_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_LOC_ST_ID
                        ORDER BY
                            r.ST_LOC_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_LOC,
                        po.ST_LOC_ID,
                        an.ST_LOC_PositedAt,
                        an.ST_LOC_Reliability,
                        po.ST_LOC_ST_ID,
                        po.ST_LOC_Checksum,
                        po.ST_LOC_Stage_Location,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_LOC_ID
                            ORDER BY an.ST_LOC_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_LOC_Stage_Location_Posit po
                    JOIN
                        ST_LOC_Stage_Location_Annex an
                    ON
                        an.ST_LOC_ID = po.ST_LOC_ID
                    WHERE
                        an.ST_LOC_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_LOC_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_AVG_ST_ID
                        ORDER BY
                            r.ST_AVG_ChangedAt DESC,
                            r.ST_AVG_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_AVG,
                        po.ST_AVG_ID,
                        an.ST_AVG_PositedAt,
                        an.ST_AVG_Reliability,
                        po.ST_AVG_ST_ID,
                        po.ST_AVG_UTL_ID,
                        po.ST_AVG_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_AVG_ID
                            ORDER BY an.ST_AVG_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_AVG_Stage_Average_Posit po
                    JOIN
                        ST_AVG_Stage_Average_Annex an
                    ON
                        an.ST_AVG_ID = po.ST_AVG_ID
                    WHERE
                        po.ST_AVG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_AVG_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_AVG_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_MIN_ST_ID
                        ORDER BY
                            r.ST_MIN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_MIN,
                        po.ST_MIN_ID,
                        an.ST_MIN_PositedAt,
                        an.ST_MIN_Reliability,
                        po.ST_MIN_ST_ID,
                        po.ST_MIN_UTL_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_MIN_ID
                            ORDER BY an.ST_MIN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_MIN_Stage_Minimum_Posit po
                    JOIN
                        ST_MIN_Stage_Minimum_Annex an
                    ON
                        an.ST_MIN_ID = po.ST_MIN_ID
                    WHERE
                        an.ST_MIN_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_MIN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END tST_Stage;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What is known now (positing time End of Time) about the changing time, with a reliability that is null since a
-- perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pST_Stage (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Reliability,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Reliability,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Reliability,
            "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Reliability,
            "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            ST_Stage "ST"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_NAM_ST_ID
                        ORDER BY
                            r.ST_NAM_ChangedAt DESC,
                            r.ST_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_NAM,
                        po.ST_NAM_ID,
                        an.ST_NAM_PositedAt,
                        an.ST_NAM_Reliability,
                        po.ST_NAM_ST_ID,
                        po.ST_NAM_Stage_Name,
                        po.ST_NAM_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_NAM_ID
                            ORDER BY an.ST_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_NAM_Stage_Name_Posit po
                    JOIN
                        ST_NAM_Stage_Name_Annex an
                    ON
                        an.ST_NAM_ID = po.ST_NAM_ID
                    WHERE
                        po.ST_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_LOC_ST_ID
                        ORDER BY
                            r.ST_LOC_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_LOC,
                        po.ST_LOC_ID,
                        an.ST_LOC_PositedAt,
                        an.ST_LOC_Reliability,
                        po.ST_LOC_ST_ID,
                        po.ST_LOC_Checksum,
                        po.ST_LOC_Stage_Location,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_LOC_ID
                            ORDER BY an.ST_LOC_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_LOC_Stage_Location_Posit po
                    JOIN
                        ST_LOC_Stage_Location_Annex an
                    ON
                        an.ST_LOC_ID = po.ST_LOC_ID
                    WHERE
                        an.ST_LOC_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_LOC_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_AVG_ST_ID
                        ORDER BY
                            r.ST_AVG_ChangedAt DESC,
                            r.ST_AVG_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_AVG,
                        po.ST_AVG_ID,
                        an.ST_AVG_PositedAt,
                        an.ST_AVG_Reliability,
                        po.ST_AVG_ST_ID,
                        po.ST_AVG_UTL_ID,
                        po.ST_AVG_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_AVG_ID
                            ORDER BY an.ST_AVG_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_AVG_Stage_Average_Posit po
                    JOIN
                        ST_AVG_Stage_Average_Annex an
                    ON
                        an.ST_AVG_ID = po.ST_AVG_ID
                    WHERE
                        po.ST_AVG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_AVG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_AVG_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_MIN_ST_ID
                        ORDER BY
                            r.ST_MIN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_MIN,
                        po.ST_MIN_ID,
                        an.ST_MIN_PositedAt,
                        an.ST_MIN_Reliability,
                        po.ST_MIN_ST_ID,
                        po.ST_MIN_UTL_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_MIN_ID
                            ORDER BY an.ST_MIN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ST_MIN_Stage_Minimum_Posit po
                    JOIN
                        ST_MIN_Stage_Minimum_Annex an
                    ON
                        an.ST_MIN_ID = po.ST_MIN_ID
                    WHERE
                        an.ST_MIN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_MIN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END pST_Stage;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-- What is known now, at End of Time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lST_Stage
AS
SELECT
    *
FROM
    pST_Stage(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nST_Stage
AS
SELECT
    *
FROM
    pST_Stage(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The attributes whose
-- mnemonics the selection holds are the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dST_Stage (
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
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Reliability,
            "NAM".ST_NAM_Stage_Name,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Reliability,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Stage_Location,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Reliability,
            "kAVG".UTL_Utilization AS ST_AVG_UTL_Utilization,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Reliability,
            "kMIN".UTL_Utilization AS ST_MIN_UTL_Utilization,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM (
            SELECT DISTINCT
                h.ST_NAM_ST_ID AS ST_ID,
                CAST(h.ST_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                ST_NAM_Stage_Name h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.ST_AVG_ST_ID AS ST_ID,
                CAST(h.ST_AVG_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'AVG' AS mnemonic
            FROM
                ST_AVG_Stage_Average h
            WHERE
                (selection IS NULL OR selection LIKE '%AVG%')
            AND
                h.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            ST_Stage "ST"
        ON
            "ST".ST_ID = timepoints.ST_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.ST_NAM_ChangedAt) OVER (
                    PARTITION BY x.ST_NAM_ST_ID
                    ORDER BY x.ST_NAM_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.ST_NAM_ST_ID, r.ST_NAM_ChangedAt
                            ORDER BY r.ST_NAM_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Reliability,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Stage_Name,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ST_NAM_Stage_Name_Posit po
                        JOIN
                            ST_NAM_Stage_Name_Annex an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                        WHERE
                            po.ST_NAM_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.ST_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_NAM_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
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
                        PARTITION BY r.ST_LOC_ST_ID
                        ORDER BY r.ST_LOC_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_ST_LOC,
                            po.ST_LOC_ID,
                            an.ST_LOC_PositedAt,
                            an.ST_LOC_Reliability,
                            po.ST_LOC_ST_ID,
                            po.ST_LOC_Checksum,
                            po.ST_LOC_Stage_Location,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_LOC_ID
                                ORDER BY an.ST_LOC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ST_LOC_Stage_Location_Posit po
                        JOIN
                            ST_LOC_Stage_Location_Annex an
                        ON
                            an.ST_LOC_ID = po.ST_LOC_ID
                        WHERE
                            an.ST_LOC_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_LOC_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.ST_AVG_ChangedAt) OVER (
                    PARTITION BY x.ST_AVG_ST_ID
                    ORDER BY x.ST_AVG_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.ST_AVG_ST_ID, r.ST_AVG_ChangedAt
                            ORDER BY r.ST_AVG_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Reliability,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ST_AVG_Stage_Average_Posit po
                        JOIN
                            ST_AVG_Stage_Average_Annex an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                        WHERE
                            po.ST_AVG_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.ST_AVG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_AVG_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "AVG".untilTime IS NULL
        OR
            "AVG".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            UTL_Utilization "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_MIN_ST_ID
                        ORDER BY r.ST_MIN_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_ST_MIN,
                            po.ST_MIN_ID,
                            an.ST_MIN_PositedAt,
                            an.ST_MIN_Reliability,
                            po.ST_MIN_ST_ID,
                            po.ST_MIN_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_MIN_ID
                                ORDER BY an.ST_MIN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ST_MIN_Stage_Minimum_Posit po
                        JOIN
                            ST_MIN_Stage_Minimum_Annex an
                        ON
                            an.ST_MIN_ID = po.ST_MIN_ID
                        WHERE
                            an.ST_MIN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_MIN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            UTL_Utilization "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END dST_Stage;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest asserted posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tAC_Actor (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            "NAM".AC_NAM_Reliability,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Reliability,
            "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Reliability,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            AC_Actor "AC"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_NAM_AC_ID
                        ORDER BY
                            r.AC_NAM_ChangedAt DESC,
                            r.AC_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_NAM,
                        po.AC_NAM_ID,
                        an.AC_NAM_PositedAt,
                        an.AC_NAM_Reliability,
                        po.AC_NAM_AC_ID,
                        po.AC_NAM_Actor_Name,
                        po.AC_NAM_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_NAM_ID
                            ORDER BY an.AC_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_NAM_Actor_Name_Posit po
                    JOIN
                        AC_NAM_Actor_Name_Annex an
                    ON
                        an.AC_NAM_ID = po.AC_NAM_ID
                    WHERE
                        po.AC_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_GEN_AC_ID
                        ORDER BY
                            r.AC_GEN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_GEN,
                        po.AC_GEN_ID,
                        an.AC_GEN_PositedAt,
                        an.AC_GEN_Reliability,
                        po.AC_GEN_AC_ID,
                        po.AC_GEN_GEN_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_GEN_ID
                            ORDER BY an.AC_GEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_GEN_Actor_Gender_Posit po
                    JOIN
                        AC_GEN_Actor_Gender_Annex an
                    ON
                        an.AC_GEN_ID = po.AC_GEN_ID
                    WHERE
                        an.AC_GEN_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_GEN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_PLV_AC_ID
                        ORDER BY
                            r.AC_PLV_ChangedAt DESC,
                            r.AC_PLV_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_PLV,
                        po.AC_PLV_ID,
                        an.AC_PLV_PositedAt,
                        an.AC_PLV_Reliability,
                        po.AC_PLV_AC_ID,
                        po.AC_PLV_PLV_ID,
                        po.AC_PLV_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_PLV_ID
                            ORDER BY an.AC_PLV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_PLV_Actor_ProfessionalLevel_Posit po
                    JOIN
                        AC_PLV_Actor_ProfessionalLevel_Annex an
                    ON
                        an.AC_PLV_ID = po.AC_PLV_ID
                    WHERE
                        po.AC_PLV_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_PLV_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_PLV_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        LEFT JOIN
            PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END tAC_Actor;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What is known now (positing time End of Time) about the changing time, with a reliability that is null since a
-- perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_Actor (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Reliability,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Reliability,
            "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Reliability,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            AC_Actor "AC"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_NAM_AC_ID
                        ORDER BY
                            r.AC_NAM_ChangedAt DESC,
                            r.AC_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_NAM,
                        po.AC_NAM_ID,
                        an.AC_NAM_PositedAt,
                        an.AC_NAM_Reliability,
                        po.AC_NAM_AC_ID,
                        po.AC_NAM_Actor_Name,
                        po.AC_NAM_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_NAM_ID
                            ORDER BY an.AC_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_NAM_Actor_Name_Posit po
                    JOIN
                        AC_NAM_Actor_Name_Annex an
                    ON
                        an.AC_NAM_ID = po.AC_NAM_ID
                    WHERE
                        po.AC_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_GEN_AC_ID
                        ORDER BY
                            r.AC_GEN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_GEN,
                        po.AC_GEN_ID,
                        an.AC_GEN_PositedAt,
                        an.AC_GEN_Reliability,
                        po.AC_GEN_AC_ID,
                        po.AC_GEN_GEN_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_GEN_ID
                            ORDER BY an.AC_GEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_GEN_Actor_Gender_Posit po
                    JOIN
                        AC_GEN_Actor_Gender_Annex an
                    ON
                        an.AC_GEN_ID = po.AC_GEN_ID
                    WHERE
                        an.AC_GEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_GEN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_PLV_AC_ID
                        ORDER BY
                            r.AC_PLV_ChangedAt DESC,
                            r.AC_PLV_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_PLV,
                        po.AC_PLV_ID,
                        an.AC_PLV_PositedAt,
                        an.AC_PLV_Reliability,
                        po.AC_PLV_AC_ID,
                        po.AC_PLV_PLV_ID,
                        po.AC_PLV_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_PLV_ID
                            ORDER BY an.AC_PLV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        AC_PLV_Actor_ProfessionalLevel_Posit po
                    JOIN
                        AC_PLV_Actor_ProfessionalLevel_Annex an
                    ON
                        an.AC_PLV_ID = po.AC_PLV_ID
                    WHERE
                        po.AC_PLV_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_PLV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_PLV_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        LEFT JOIN
            PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END pAC_Actor;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-- What is known now, at End of Time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_Actor
AS
SELECT
    *
FROM
    pAC_Actor(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_Actor
AS
SELECT
    *
FROM
    pAC_Actor(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The attributes whose
-- mnemonics the selection holds are the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dAC_Actor (
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
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Reliability,
            "NAM".AC_NAM_Actor_Name,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Reliability,
            "kGEN".GEN_Gender AS AC_GEN_GEN_Gender,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Reliability,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM (
            SELECT DISTINCT
                h.AC_NAM_AC_ID AS AC_ID,
                CAST(h.AC_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                AC_NAM_Actor_Name h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.AC_PLV_AC_ID AS AC_ID,
                CAST(h.AC_PLV_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'PLV' AS mnemonic
            FROM
                AC_PLV_Actor_ProfessionalLevel h
            WHERE
                (selection IS NULL OR selection LIKE '%PLV%')
            AND
                h.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            AC_Actor "AC"
        ON
            "AC".AC_ID = timepoints.AC_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.AC_NAM_ChangedAt) OVER (
                    PARTITION BY x.AC_NAM_AC_ID
                    ORDER BY x.AC_NAM_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.AC_NAM_AC_ID, r.AC_NAM_ChangedAt
                            ORDER BY r.AC_NAM_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Reliability,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Actor_Name,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            AC_NAM_Actor_Name_Posit po
                        JOIN
                            AC_NAM_Actor_Name_Annex an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                        WHERE
                            po.AC_NAM_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.AC_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_NAM_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
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
                        PARTITION BY r.AC_GEN_AC_ID
                        ORDER BY r.AC_GEN_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_AC_GEN,
                            po.AC_GEN_ID,
                            an.AC_GEN_PositedAt,
                            an.AC_GEN_Reliability,
                            po.AC_GEN_AC_ID,
                            po.AC_GEN_GEN_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_GEN_ID
                                ORDER BY an.AC_GEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            AC_GEN_Actor_Gender_Posit po
                        JOIN
                            AC_GEN_Actor_Gender_Annex an
                        ON
                            an.AC_GEN_ID = po.AC_GEN_ID
                        WHERE
                            an.AC_GEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_GEN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            GEN_Gender "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.AC_PLV_ChangedAt) OVER (
                    PARTITION BY x.AC_PLV_AC_ID
                    ORDER BY x.AC_PLV_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.AC_PLV_AC_ID, r.AC_PLV_ChangedAt
                            ORDER BY r.AC_PLV_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Reliability,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            AC_PLV_Actor_ProfessionalLevel_Posit po
                        JOIN
                            AC_PLV_Actor_ProfessionalLevel_Annex an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                        WHERE
                            po.AC_PLV_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.AC_PLV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_PLV_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "PLV".untilTime IS NULL
        OR
            "PLV".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            PLV_ProfessionalLevel "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END dAC_Actor;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest asserted posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tPR_Program (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            "NAM".PR_NAM_Reliability,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Reliability,
            "LEN".PR_LEN_Program_Length
        FROM
            PR_Program "PR"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_NAM_PR_ID
                        ORDER BY
                            r.PR_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_NAM,
                        po.PR_NAM_ID,
                        an.PR_NAM_PositedAt,
                        an.PR_NAM_Reliability,
                        po.PR_NAM_PR_ID,
                        po.PR_NAM_Program_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_NAM_ID
                            ORDER BY an.PR_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        PR_NAM_Program_Name_Posit po
                    JOIN
                        PR_NAM_Program_Name_Annex an
                    ON
                        an.PR_NAM_ID = po.PR_NAM_ID
                    WHERE
                        an.PR_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_LEN_PR_ID
                        ORDER BY
                            r.PR_LEN_ChangedAt DESC,
                            r.PR_LEN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_LEN,
                        po.PR_LEN_ID,
                        an.PR_LEN_PositedAt,
                        an.PR_LEN_Reliability,
                        po.PR_LEN_PR_ID,
                        po.PR_LEN_Program_Length,
                        po.PR_LEN_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_LEN_ID
                            ORDER BY an.PR_LEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        PR_LEN_Program_Length_Posit po
                    JOIN
                        PR_LEN_Program_Length_Annex an
                    ON
                        an.PR_LEN_ID = po.PR_LEN_ID
                    WHERE
                        po.PR_LEN_ChangedAt <= CAST(changingTimepoint AS date)
                    AND
                        an.PR_LEN_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_LEN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
    ]';
END tPR_Program;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What is known now (positing time End of Time) about the changing time, with a reliability that is null since a
-- perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pPR_Program (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Reliability,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Reliability,
            "LEN".PR_LEN_Program_Length
        FROM
            PR_Program "PR"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_NAM_PR_ID
                        ORDER BY
                            r.PR_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_NAM,
                        po.PR_NAM_ID,
                        an.PR_NAM_PositedAt,
                        an.PR_NAM_Reliability,
                        po.PR_NAM_PR_ID,
                        po.PR_NAM_Program_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_NAM_ID
                            ORDER BY an.PR_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        PR_NAM_Program_Name_Posit po
                    JOIN
                        PR_NAM_Program_Name_Annex an
                    ON
                        an.PR_NAM_ID = po.PR_NAM_ID
                    WHERE
                        an.PR_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_LEN_PR_ID
                        ORDER BY
                            r.PR_LEN_ChangedAt DESC,
                            r.PR_LEN_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_LEN,
                        po.PR_LEN_ID,
                        an.PR_LEN_PositedAt,
                        an.PR_LEN_Reliability,
                        po.PR_LEN_PR_ID,
                        po.PR_LEN_Program_Length,
                        po.PR_LEN_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_LEN_ID
                            ORDER BY an.PR_LEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        PR_LEN_Program_Length_Posit po
                    JOIN
                        PR_LEN_Program_Length_Annex an
                    ON
                        an.PR_LEN_ID = po.PR_LEN_ID
                    WHERE
                        po.PR_LEN_ChangedAt <= CAST(changingTimepoint AS date)
                    AND
                        an.PR_LEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_LEN_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
    ]';
END pPR_Program;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-- What is known now, at End of Time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lPR_Program
AS
SELECT
    *
FROM
    pPR_Program(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nPR_Program
AS
SELECT
    *
FROM
    pPR_Program(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The attributes whose
-- mnemonics the selection holds are the ones that are looked at (all of them if it is null).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dPR_Program (
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
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Reliability,
            "NAM".PR_NAM_Program_Name,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Reliability,
            "LEN".PR_LEN_Program_Length
        FROM (
            SELECT DISTINCT
                h.PR_LEN_PR_ID AS PR_ID,
                CAST(h.PR_LEN_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'LEN' AS mnemonic
            FROM
                PR_LEN_Program_Length h
            WHERE
                (selection IS NULL OR selection LIKE '%LEN%')
            AND
                h.PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            PR_Program "PR"
        ON
            "PR".PR_ID = timepoints.PR_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_NAM_PR_ID
                        ORDER BY r.PR_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_PR_NAM,
                            po.PR_NAM_ID,
                            an.PR_NAM_PositedAt,
                            an.PR_NAM_Reliability,
                            po.PR_NAM_PR_ID,
                            po.PR_NAM_Program_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_NAM_ID
                                ORDER BY an.PR_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            PR_NAM_Program_Name_Posit po
                        JOIN
                            PR_NAM_Program_Name_Annex an
                        ON
                            an.PR_NAM_ID = po.PR_NAM_ID
                        WHERE
                            an.PR_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.PR_LEN_ChangedAt) OVER (
                    PARTITION BY x.PR_LEN_PR_ID
                    ORDER BY x.PR_LEN_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.PR_LEN_PR_ID, r.PR_LEN_ChangedAt
                            ORDER BY r.PR_LEN_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Reliability,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Program_Length,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            PR_LEN_Program_Length_Posit po
                        JOIN
                            PR_LEN_Program_Length_Annex an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                        WHERE
                            po.PR_LEN_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS date)
                        AND
                            an.PR_LEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.PR_LEN_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
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
