-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- anchor perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pAC_Actor(TIMESTAMP '2020-01-01 00:00:00').
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lST_Scen (
    ST_ID,
    Metadata_ST,
    ST_NAM_ST_ID,
    Metadata_ST_NAM,
    ST_NAM_ChangedAt,
    ST_NAM_Scen_Namn,
    ST_LOC_ST_ID,
    Metadata_ST_LOC,
    ST_LOC_Checksum,
    ST_LOC_Scen_Plats,
    ST_AVG_ST_ID,
    Metadata_ST_AVG,
    ST_AVG_ChangedAt,
    ST_AVG_UTL_Utnyttjande,
    ST_AVG_Metadata_UTL,
    ST_AVG_UTL_ID,
    ST_MIN_ST_ID,
    Metadata_ST_MIN,
    Deletable_ST_MIN,
    ST_MIN_UTL_Utnyttjande,
    ST_MIN_Metadata_UTL,
    ST_MIN_UTL_ID
)
AS
SELECT
    "ST".ST_ID,
    "ST".Metadata_ST,
    "NAM".ST_NAM_ST_ID,
    "NAM".Metadata_ST_NAM,
    "NAM".ST_NAM_ChangedAt,
    "NAM".ST_NAM_Scen_Namn,
    "LOC".ST_LOC_ST_ID,
    "LOC".Metadata_ST_LOC,
    "LOC".ST_LOC_Checksum,
    "LOC".ST_LOC_Scen_Plats,
    "AVG".ST_AVG_ST_ID,
    "AVG".Metadata_ST_AVG,
    "AVG".ST_AVG_ChangedAt,
    "kAVG".UTL_Utnyttjande AS ST_AVG_UTL_Utnyttjande,
    "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
    "AVG".ST_AVG_UTL_ID,
    "MIN".ST_MIN_ST_ID,
    "MIN".Metadata_ST_MIN,
    CAST(NULL AS number(1)),
    "kMIN".UTL_Utnyttjande AS ST_MIN_UTL_Utnyttjande,
    "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
    "MIN".ST_MIN_UTL_ID
FROM
    anchors.ST_Scen "ST"
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.ST_NAM_Scen_Namn a
        WHERE
            a.ST_NAM_ChangedAt = (
                SELECT
                    MAX(sub.ST_NAM_ChangedAt)
                FROM
                    attributes.ST_NAM_Scen_Namn sub
                WHERE
                    sub.ST_NAM_ST_ID = a.ST_NAM_ST_ID
            )
    ) "NAM"
ON
    "NAM".ST_NAM_ST_ID = "ST".ST_ID
LEFT JOIN
    attributes.ST_LOC_Scen_Plats "LOC"
ON
    "LOC".ST_LOC_ST_ID = "ST".ST_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.ST_AVG_Scen_Medel a
        WHERE
            a.ST_AVG_ChangedAt = (
                SELECT
                    MAX(sub.ST_AVG_ChangedAt)
                FROM
                    attributes.ST_AVG_Scen_Medel sub
                WHERE
                    sub.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            )
    ) "AVG"
ON
    "AVG".ST_AVG_ST_ID = "ST".ST_ID
LEFT JOIN
    knots.UTL_Utnyttjande "kAVG"
ON
    "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
LEFT JOIN
    attributes.ST_MIN_Scen_Minimum "MIN"
ON
    "MIN".ST_MIN_ST_ID = "ST".ST_ID
LEFT JOIN
    knots.UTL_Utnyttjande "kMIN"
ON
    "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pST_Scen (
    changingTimepoint IN timestamp
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
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_Scen_Namn,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Scen_Plats,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ChangedAt,
            "kAVG".UTL_Utnyttjande AS ST_AVG_UTL_Utnyttjande,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "kMIN".UTL_Utnyttjande AS ST_MIN_UTL_Utnyttjande,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            anchors.ST_Scen "ST"
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.ST_NAM_Scen_Namn a
                WHERE
                    a.ST_NAM_ChangedAt = (
                        SELECT
                            MAX(sub.ST_NAM_ChangedAt)
                        FROM
                            attributes.ST_NAM_Scen_Namn sub
                        WHERE
                            sub.ST_NAM_ST_ID = a.ST_NAM_ST_ID
                        AND
                            sub.ST_NAM_ChangedAt <= changingTimepoint
                    )
            ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        LEFT JOIN
            attributes.ST_LOC_Scen_Plats "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.ST_AVG_Scen_Medel a
                WHERE
                    a.ST_AVG_ChangedAt = (
                        SELECT
                            MAX(sub.ST_AVG_ChangedAt)
                        FROM
                            attributes.ST_AVG_Scen_Medel sub
                        WHERE
                            sub.ST_AVG_ST_ID = a.ST_AVG_ST_ID
                        AND
                            sub.ST_AVG_ChangedAt <= changingTimepoint
                    )
            ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        LEFT JOIN
            knots.UTL_Utnyttjande "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN
            attributes.ST_MIN_Scen_Minimum "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            knots.UTL_Utnyttjande "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END pST_Scen;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nST_Scen
AS
SELECT
    *
FROM
    anchors.pST_Scen(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dST_Scen (
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
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_Scen_Namn,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Scen_Plats,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ChangedAt,
            "kAVG".UTL_Utnyttjande AS ST_AVG_UTL_Utnyttjande,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "kMIN".UTL_Utnyttjande AS ST_MIN_UTL_Utnyttjande,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM (
            SELECT DISTINCT
                h.ST_NAM_ST_ID AS ST_ID,
                CAST(h.ST_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                attributes.ST_NAM_Scen_Namn h
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
                attributes.ST_AVG_Scen_Medel h
            WHERE
                (selection IS NULL OR selection LIKE '%AVG%')
            AND
                h.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            anchors.ST_Scen "ST"
        ON
            "ST".ST_ID = timepoints.ST_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.ST_NAM_ChangedAt) OVER (
                    PARTITION BY h.ST_NAM_ST_ID
                    ORDER BY h.ST_NAM_ChangedAt
                ) AS untilTime
            FROM
                attributes.ST_NAM_Scen_Namn h
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
        LEFT JOIN
            attributes.ST_LOC_Scen_Plats "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.ST_AVG_ChangedAt) OVER (
                    PARTITION BY h.ST_AVG_ST_ID
                    ORDER BY h.ST_AVG_ChangedAt
                ) AS untilTime
            FROM
                attributes.ST_AVG_Scen_Medel h
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
            knots.UTL_Utnyttjande "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN
            attributes.ST_MIN_Scen_Minimum "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            knots.UTL_Utnyttjande "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END dST_Scen;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lAC_Skådespelare (
    AC_ID,
    Metadata_AC,
    AC_NAM_AC_ID,
    Metadata_AC_NAM,
    AC_NAM_ChangedAt,
    AC_NAM_Skådespelare_Namn,
    AC_GEN_AC_ID,
    Metadata_AC_GEN,
    AC_GEN_GEN_Checksum,
    AC_GEN_GEN_Kön,
    AC_GEN_Metadata_GEN,
    AC_GEN_GEN_ID,
    AC_PLV_AC_ID,
    Metadata_AC_PLV,
    AC_PLV_ChangedAt,
    AC_PLV_PLV_Checksum,
    AC_PLV_PLV_Yrkesnivå,
    AC_PLV_Metadata_PLV,
    AC_PLV_PLV_ID
)
AS
SELECT
    "AC".AC_ID,
    "AC".Metadata_AC,
    "NAM".AC_NAM_AC_ID,
    "NAM".Metadata_AC_NAM,
    "NAM".AC_NAM_ChangedAt,
    "NAM".AC_NAM_Skådespelare_Namn,
    "GEN".AC_GEN_AC_ID,
    "GEN".Metadata_AC_GEN,
    "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
    "kGEN".GEN_Kön AS AC_GEN_GEN_Kön,
    "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
    "GEN".AC_GEN_GEN_ID,
    "PLV".AC_PLV_AC_ID,
    "PLV".Metadata_AC_PLV,
    "PLV".AC_PLV_ChangedAt,
    "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
    "kPLV".PLV_Yrkesnivå AS AC_PLV_PLV_Yrkesnivå,
    "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
    "PLV".AC_PLV_PLV_ID
FROM
    anchors.AC_Skådespelare "AC"
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.AC_NAM_Skådespelare_Namn a
        WHERE
            a.AC_NAM_ChangedAt = (
                SELECT
                    MAX(sub.AC_NAM_ChangedAt)
                FROM
                    attributes.AC_NAM_Skådespelare_Namn sub
                WHERE
                    sub.AC_NAM_AC_ID = a.AC_NAM_AC_ID
            )
    ) "NAM"
ON
    "NAM".AC_NAM_AC_ID = "AC".AC_ID
LEFT JOIN
    attributes.AC_GEN_Skådespelare_Kön "GEN"
ON
    "GEN".AC_GEN_AC_ID = "AC".AC_ID
LEFT JOIN
    knots.GEN_Kön "kGEN"
ON
    "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå a
        WHERE
            a.AC_PLV_ChangedAt = (
                SELECT
                    MAX(sub.AC_PLV_ChangedAt)
                FROM
                    attributes.AC_PLV_Skådespelare_Yrkesnivå sub
                WHERE
                    sub.AC_PLV_AC_ID = a.AC_PLV_AC_ID
            )
    ) "PLV"
ON
    "PLV".AC_PLV_AC_ID = "AC".AC_ID
LEFT JOIN
    knots.PLV_Yrkesnivå "kPLV"
ON
    "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pAC_Skådespelare (
    changingTimepoint IN timestamp
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
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_Skådespelare_Namn,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
            "kGEN".GEN_Kön AS AC_GEN_GEN_Kön,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ChangedAt,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_Yrkesnivå AS AC_PLV_PLV_Yrkesnivå,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            anchors.AC_Skådespelare "AC"
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.AC_NAM_Skådespelare_Namn a
                WHERE
                    a.AC_NAM_ChangedAt = (
                        SELECT
                            MAX(sub.AC_NAM_ChangedAt)
                        FROM
                            attributes.AC_NAM_Skådespelare_Namn sub
                        WHERE
                            sub.AC_NAM_AC_ID = a.AC_NAM_AC_ID
                        AND
                            sub.AC_NAM_ChangedAt <= changingTimepoint
                    )
            ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        LEFT JOIN
            attributes.AC_GEN_Skådespelare_Kön "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            knots.GEN_Kön "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.AC_PLV_Skådespelare_Yrkesnivå a
                WHERE
                    a.AC_PLV_ChangedAt = (
                        SELECT
                            MAX(sub.AC_PLV_ChangedAt)
                        FROM
                            attributes.AC_PLV_Skådespelare_Yrkesnivå sub
                        WHERE
                            sub.AC_PLV_AC_ID = a.AC_PLV_AC_ID
                        AND
                            sub.AC_PLV_ChangedAt <= changingTimepoint
                    )
            ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        LEFT JOIN
            knots.PLV_Yrkesnivå "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END pAC_Skådespelare;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nAC_Skådespelare
AS
SELECT
    *
FROM
    anchors.pAC_Skådespelare(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dAC_Skådespelare (
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
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_Skådespelare_Namn,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
            "kGEN".GEN_Kön AS AC_GEN_GEN_Kön,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ChangedAt,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_Yrkesnivå AS AC_PLV_PLV_Yrkesnivå,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM (
            SELECT DISTINCT
                h.AC_NAM_AC_ID AS AC_ID,
                CAST(h.AC_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                attributes.AC_NAM_Skådespelare_Namn h
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
                attributes.AC_PLV_Skådespelare_Yrkesnivå h
            WHERE
                (selection IS NULL OR selection LIKE '%PLV%')
            AND
                h.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            anchors.AC_Skådespelare "AC"
        ON
            "AC".AC_ID = timepoints.AC_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.AC_NAM_ChangedAt) OVER (
                    PARTITION BY h.AC_NAM_AC_ID
                    ORDER BY h.AC_NAM_ChangedAt
                ) AS untilTime
            FROM
                attributes.AC_NAM_Skådespelare_Namn h
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
        LEFT JOIN
            attributes.AC_GEN_Skådespelare_Kön "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            knots.GEN_Kön "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.AC_PLV_ChangedAt) OVER (
                    PARTITION BY h.AC_PLV_AC_ID
                    ORDER BY h.AC_PLV_ChangedAt
                ) AS untilTime
            FROM
                attributes.AC_PLV_Skådespelare_Yrkesnivå h
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
            knots.PLV_Yrkesnivå "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END dAC_Skådespelare;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lPR_Föreställning (
    PR_ID,
    Metadata_PR,
    PR_NAM_PR_ID,
    Metadata_PR_NAM,
    PR_NAM_Föreställning_Namn,
    PR_LEN_PR_ID,
    Metadata_PR_LEN,
    PR_LEN_ChangedAt,
    PR_LEN_Föreställning_Längd
)
AS
SELECT
    "PR".PR_ID,
    "PR".Metadata_PR,
    "NAM".PR_NAM_PR_ID,
    "NAM".Metadata_PR_NAM,
    "NAM".PR_NAM_Föreställning_Namn,
    "LEN".PR_LEN_PR_ID,
    "LEN".Metadata_PR_LEN,
    "LEN".PR_LEN_ChangedAt,
    "LEN".PR_LEN_Föreställning_Längd
FROM
    anchors.PR_Föreställning "PR"
LEFT JOIN
    attributes.PR_NAM_Föreställning_Namn "NAM"
ON
    "NAM".PR_NAM_PR_ID = "PR".PR_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.PR_LEN_Föreställning_Längd a
        WHERE
            a.PR_LEN_ChangedAt = (
                SELECT
                    MAX(sub.PR_LEN_ChangedAt)
                FROM
                    attributes.PR_LEN_Föreställning_Längd sub
                WHERE
                    sub.PR_LEN_PR_ID = a.PR_LEN_PR_ID
            )
    ) "LEN"
ON
    "LEN".PR_LEN_PR_ID = "PR".PR_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pPR_Föreställning (
    changingTimepoint IN timestamp
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
            "NAM".PR_NAM_Föreställning_Namn,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_Föreställning_Längd
        FROM
            anchors.PR_Föreställning "PR"
        LEFT JOIN
            attributes.PR_NAM_Föreställning_Namn "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.PR_LEN_Föreställning_Längd a
                WHERE
                    a.PR_LEN_ChangedAt = (
                        SELECT
                            MAX(sub.PR_LEN_ChangedAt)
                        FROM
                            attributes.PR_LEN_Föreställning_Längd sub
                        WHERE
                            sub.PR_LEN_PR_ID = a.PR_LEN_PR_ID
                        AND
                            sub.PR_LEN_ChangedAt <= changingTimepoint
                    )
            ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
    ]';
END pPR_Föreställning;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nPR_Föreställning
AS
SELECT
    *
FROM
    anchors.pPR_Föreställning(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dPR_Föreställning (
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
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_Föreställning_Namn,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_Föreställning_Längd
        FROM (
            SELECT DISTINCT
                h.PR_LEN_PR_ID AS PR_ID,
                CAST(h.PR_LEN_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'LEN' AS mnemonic
            FROM
                attributes.PR_LEN_Föreställning_Längd h
            WHERE
                (selection IS NULL OR selection LIKE '%LEN%')
            AND
                h.PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            anchors.PR_Föreställning "PR"
        ON
            "PR".PR_ID = timepoints.PR_ID
        LEFT JOIN
            attributes.PR_NAM_Föreställning_Namn "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.PR_LEN_ChangedAt) OVER (
                    PARTITION BY h.PR_LEN_PR_ID
                    ORDER BY h.PR_LEN_ChangedAt
                ) AS untilTime
            FROM
                attributes.PR_LEN_Föreställning_Längd h
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
END dPR_Föreställning;
/
