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
CREATE OR REPLACE VIEW nexuses.lEV_Händelse (
    EV_ID,
    Metadata_EV,
    ST_ID_hölls,
    PR_ID_spelades,
    of_ETY_Checksum,
    of_ETY_Händelsetyp,
    of_Metadata_ETY,
    ETY_ID_of,
    EV_DAT_EV_ID,
    Metadata_EV_DAT,
    EV_DAT_Händelse_Datum,
    EV_AUD_EV_ID,
    Metadata_EV_AUD,
    EV_AUD_Händelse_Publik,
    EV_REV_EV_ID,
    Metadata_EV_REV,
    EV_REV_Händelse_Intäkt,
    EV_STA_EV_ID,
    Metadata_EV_STA,
    EV_STA_ChangedAt,
    EV_STA_Händelse_Status,
    EV_UTL_EV_ID,
    Metadata_EV_UTL,
    EV_UTL_UTL_Utnyttjande,
    EV_UTL_Metadata_UTL,
    EV_UTL_UTL_ID,
    EV_LVL_EV_ID,
    Metadata_EV_LVL,
    EV_LVL_ChangedAt,
    EV_LVL_PLV_Checksum,
    EV_LVL_PLV_Yrkesnivå,
    EV_LVL_Metadata_PLV,
    EV_LVL_PLV_ID
)
AS
SELECT
    "EV".EV_ID,
    "EV".Metadata_EV,
    "EV".ST_ID_hölls,
    "EV".PR_ID_spelades,
    "ETY_of".ETY_Checksum AS of_ETY_Checksum,
    "ETY_of".ETY_Händelsetyp AS of_ETY_Händelsetyp,
    "ETY_of".Metadata_ETY AS of_Metadata_ETY,
    "EV".ETY_ID_of,
    "DAT".EV_DAT_EV_ID,
    "DAT".Metadata_EV_DAT,
    "DAT".EV_DAT_Händelse_Datum,
    "AUD".EV_AUD_EV_ID,
    "AUD".Metadata_EV_AUD,
    "AUD".EV_AUD_Händelse_Publik,
    "REV".EV_REV_EV_ID,
    "REV".Metadata_EV_REV,
    "REV".EV_REV_Händelse_Intäkt,
    "STA".EV_STA_EV_ID,
    "STA".Metadata_EV_STA,
    "STA".EV_STA_ChangedAt,
    "STA".EV_STA_Händelse_Status,
    "UTL".EV_UTL_EV_ID,
    "UTL".Metadata_EV_UTL,
    "kUTL".UTL_Utnyttjande AS EV_UTL_UTL_Utnyttjande,
    "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
    "UTL".EV_UTL_UTL_ID,
    "LVL".EV_LVL_EV_ID,
    "LVL".Metadata_EV_LVL,
    "LVL".EV_LVL_ChangedAt,
    "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
    "kLVL".PLV_Yrkesnivå AS EV_LVL_PLV_Yrkesnivå,
    "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
    "LVL".EV_LVL_PLV_ID
FROM
    nexuses.EV_Händelse "EV"
LEFT JOIN
    knots.ETY_Händelsetyp "ETY_of"
ON
    "ETY_of".ETY_ID = "EV".ETY_ID_of
LEFT JOIN
    attributes.EV_DAT_Händelse_Datum "DAT"
ON
    "DAT".EV_DAT_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_AUD_Händelse_Publik "AUD"
ON
    "AUD".EV_AUD_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_REV_Händelse_Intäkt "REV"
ON
    "REV".EV_REV_EV_ID = "EV".EV_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.EV_STA_Händelse_Status a
        WHERE
            a.EV_STA_ChangedAt = (
                SELECT
                    MAX(sub.EV_STA_ChangedAt)
                FROM
                    attributes.EV_STA_Händelse_Status sub
                WHERE
                    sub.EV_STA_EV_ID = a.EV_STA_EV_ID
            )
    ) "STA"
ON
    "STA".EV_STA_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_UTL_Händelse_Utnyttjande "UTL"
ON
    "UTL".EV_UTL_EV_ID = "EV".EV_ID
LEFT JOIN
    knots.UTL_Utnyttjande "kUTL"
ON
    "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.EV_LVL_Händelse_Level a
        WHERE
            a.EV_LVL_ChangedAt = (
                SELECT
                    MAX(sub.EV_LVL_ChangedAt)
                FROM
                    attributes.EV_LVL_Händelse_Level sub
                WHERE
                    sub.EV_LVL_EV_ID = a.EV_LVL_EV_ID
            )
    ) "LVL"
ON
    "LVL".EV_LVL_EV_ID = "EV".EV_ID
LEFT JOIN
    knots.PLV_Yrkesnivå "kLVL"
ON
    "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.pEV_Händelse (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_hölls,
            "EV".PR_ID_spelades,
            "ETY_of".ETY_Checksum AS of_ETY_Checksum,
            "ETY_of".ETY_Händelsetyp AS of_ETY_Händelsetyp,
            "ETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_Händelse_Datum,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_Händelse_Publik,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_Händelse_Intäkt,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_Händelse_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "kUTL".UTL_Utnyttjande AS EV_UTL_UTL_Utnyttjande,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ChangedAt,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_Yrkesnivå AS EV_LVL_PLV_Yrkesnivå,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            nexuses.EV_Händelse "EV"
        LEFT JOIN
            knots.ETY_Händelsetyp "ETY_of"
        ON
            "ETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN
            attributes.EV_DAT_Händelse_Datum "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_AUD_Händelse_Publik "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_REV_Händelse_Intäkt "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.EV_STA_Händelse_Status a
                WHERE
                    a.EV_STA_ChangedAt = (
                        SELECT
                            MAX(sub.EV_STA_ChangedAt)
                        FROM
                            attributes.EV_STA_Händelse_Status sub
                        WHERE
                            sub.EV_STA_EV_ID = a.EV_STA_EV_ID
                        AND
                            sub.EV_STA_ChangedAt <= changingTimepoint
                    )
            ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_UTL_Händelse_Utnyttjande "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.UTL_Utnyttjande "kUTL"
        ON
            "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.EV_LVL_Händelse_Level a
                WHERE
                    a.EV_LVL_ChangedAt = (
                        SELECT
                            MAX(sub.EV_LVL_ChangedAt)
                        FROM
                            attributes.EV_LVL_Händelse_Level sub
                        WHERE
                            sub.EV_LVL_EV_ID = a.EV_LVL_EV_ID
                        AND
                            sub.EV_LVL_ChangedAt <= changingTimepoint
                    )
            ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.PLV_Yrkesnivå "kLVL"
        ON
            "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
    ]';
END pEV_Händelse;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.nEV_Händelse
AS
SELECT
    *
FROM
    nexuses.pEV_Händelse(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.dEV_Händelse (
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
            "EV".ST_ID_hölls,
            "EV".PR_ID_spelades,
            "ETY_of".ETY_Checksum AS of_ETY_Checksum,
            "ETY_of".ETY_Händelsetyp AS of_ETY_Händelsetyp,
            "ETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_Händelse_Datum,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_Händelse_Publik,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_Händelse_Intäkt,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_Händelse_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "kUTL".UTL_Utnyttjande AS EV_UTL_UTL_Utnyttjande,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ChangedAt,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_Yrkesnivå AS EV_LVL_PLV_Yrkesnivå,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM (
            SELECT DISTINCT
                h.EV_STA_EV_ID AS EV_ID,
                CAST(h.EV_STA_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'STA' AS mnemonic
            FROM
                attributes.EV_STA_Händelse_Status h
            WHERE
                (selection IS NULL OR selection LIKE '%STA%')
            AND
                h.EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.EV_LVL_EV_ID AS EV_ID,
                CAST(h.EV_LVL_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'LVL' AS mnemonic
            FROM
                attributes.EV_LVL_Händelse_Level h
            WHERE
                (selection IS NULL OR selection LIKE '%LVL%')
            AND
                h.EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            nexuses.EV_Händelse "EV"
        ON
            "EV".EV_ID = timepoints.EV_ID
        LEFT JOIN
            knots.ETY_Händelsetyp "ETY_of"
        ON
            "ETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN
            attributes.EV_DAT_Händelse_Datum "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_AUD_Händelse_Publik "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_REV_Händelse_Intäkt "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.EV_STA_ChangedAt) OVER (
                    PARTITION BY h.EV_STA_EV_ID
                    ORDER BY h.EV_STA_ChangedAt
                ) AS untilTime
            FROM
                attributes.EV_STA_Händelse_Status h
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "STA".untilTime IS NULL
        OR
            "STA".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            attributes.EV_UTL_Händelse_Utnyttjande "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.UTL_Utnyttjande "kUTL"
        ON
            "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.EV_LVL_ChangedAt) OVER (
                    PARTITION BY h.EV_LVL_EV_ID
                    ORDER BY h.EV_LVL_ChangedAt
                ) AS untilTime
            FROM
                attributes.EV_LVL_Händelse_Level h
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS date)
        AND (
            "LVL".untilTime IS NULL
        OR
            "LVL".untilTime > CAST(timepoints.inspectedTimepoint AS date)
        )
        LEFT JOIN
            knots.PLV_Yrkesnivå "kLVL"
        ON
            "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
    ]';
END dEV_Händelse;
/
