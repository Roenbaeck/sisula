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
CREATE OR REPLACE VIEW nexuses.lEV_Event (
    EV_ID,
    Metadata_EV,
    ST_ID_wasHeldAt,
    PR_ID_wasPlayed,
    of_ETY_Checksum,
    of_ETY_EventType,
    of_Metadata_ETY,
    ETY_ID_of,
    EV_DAT_EV_ID,
    Metadata_EV_DAT,
    EV_DAT_Event_Date,
    EV_AUD_EV_ID,
    Metadata_EV_AUD,
    EV_AUD_Event_Audience,
    EV_REV_EV_ID,
    Metadata_EV_REV,
    EV_REV_Event_Revenue,
    EV_STA_EV_ID,
    Metadata_EV_STA,
    EV_STA_ChangedAt,
    EV_STA_Event_Status,
    EV_UTL_EV_ID,
    Metadata_EV_UTL,
    EV_UTL_UTL_Utilization,
    EV_UTL_Metadata_UTL,
    EV_UTL_UTL_ID,
    EV_LVL_EV_ID,
    Metadata_EV_LVL,
    EV_LVL_ChangedAt,
    EV_LVL_PLV_Checksum,
    EV_LVL_PLV_ProfessionalLevel,
    EV_LVL_Metadata_PLV,
    EV_LVL_PLV_ID
)
AS
SELECT
    "EV".EV_ID,
    "EV".Metadata_EV,
    "EV".ST_ID_wasHeldAt,
    "EV".PR_ID_wasPlayed,
    "ETY_of".ETY_Checksum AS of_ETY_Checksum,
    "ETY_of".ETY_EventType AS of_ETY_EventType,
    "ETY_of".Metadata_ETY AS of_Metadata_ETY,
    "EV".ETY_ID_of,
    "DAT".EV_DAT_EV_ID,
    "DAT".Metadata_EV_DAT,
    "DAT".EV_DAT_Event_Date,
    "AUD".EV_AUD_EV_ID,
    "AUD".Metadata_EV_AUD,
    "AUD".EV_AUD_Event_Audience,
    "REV".EV_REV_EV_ID,
    "REV".Metadata_EV_REV,
    "REV".EV_REV_Event_Revenue,
    "STA".EV_STA_EV_ID,
    "STA".Metadata_EV_STA,
    "STA".EV_STA_ChangedAt,
    "STA".EV_STA_Event_Status,
    "UTL".EV_UTL_EV_ID,
    "UTL".Metadata_EV_UTL,
    "kUTL".UTL_Utilization AS EV_UTL_UTL_Utilization,
    "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
    "UTL".EV_UTL_UTL_ID,
    "LVL".EV_LVL_EV_ID,
    "LVL".Metadata_EV_LVL,
    "LVL".EV_LVL_ChangedAt,
    "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
    "kLVL".PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
    "LVL".EV_LVL_PLV_ID
FROM
    nexuses.EV_Event "EV"
LEFT JOIN
    knots.ETY_EventType "ETY_of"
ON
    "ETY_of".ETY_ID = "EV".ETY_ID_of
LEFT JOIN
    attributes.EV_DAT_Event_Date "DAT"
ON
    "DAT".EV_DAT_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_AUD_Event_Audience "AUD"
ON
    "AUD".EV_AUD_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_REV_Event_Revenue "REV"
ON
    "REV".EV_REV_EV_ID = "EV".EV_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.EV_STA_Event_Status a
        WHERE
            a.EV_STA_ChangedAt = (
                SELECT
                    MAX(sub.EV_STA_ChangedAt)
                FROM
                    attributes.EV_STA_Event_Status sub
                WHERE
                    sub.EV_STA_EV_ID = a.EV_STA_EV_ID
            )
    ) "STA"
ON
    "STA".EV_STA_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_UTL_Event_Utilization "UTL"
ON
    "UTL".EV_UTL_EV_ID = "EV".EV_ID
LEFT JOIN
    knots.UTL_Utilization "kUTL"
ON
    "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.EV_LVL_Event_Level a
        WHERE
            a.EV_LVL_ChangedAt = (
                SELECT
                    MAX(sub.EV_LVL_ChangedAt)
                FROM
                    attributes.EV_LVL_Event_Level sub
                WHERE
                    sub.EV_LVL_EV_ID = a.EV_LVL_EV_ID
            )
    ) "LVL"
ON
    "LVL".EV_LVL_EV_ID = "EV".EV_ID
LEFT JOIN
    knots.PLV_ProfessionalLevel "kLVL"
ON
    "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.pEV_Event (
    changingTimepoint IN timestamp
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
            "ETY_of".ETY_Checksum AS of_ETY_Checksum,
            "ETY_of".ETY_EventType AS of_ETY_EventType,
            "ETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_Event_Revenue,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_Event_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "kUTL".UTL_Utilization AS EV_UTL_UTL_Utilization,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ChangedAt,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            nexuses.EV_Event "EV"
        LEFT JOIN
            knots.ETY_EventType "ETY_of"
        ON
            "ETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN
            attributes.EV_DAT_Event_Date "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_AUD_Event_Audience "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_REV_Event_Revenue "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.EV_STA_Event_Status a
                WHERE
                    a.EV_STA_ChangedAt = (
                        SELECT
                            MAX(sub.EV_STA_ChangedAt)
                        FROM
                            attributes.EV_STA_Event_Status sub
                        WHERE
                            sub.EV_STA_EV_ID = a.EV_STA_EV_ID
                        AND
                            sub.EV_STA_ChangedAt <= changingTimepoint
                    )
            ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_UTL_Event_Utilization "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.UTL_Utilization "kUTL"
        ON
            "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.EV_LVL_Event_Level a
                WHERE
                    a.EV_LVL_ChangedAt = (
                        SELECT
                            MAX(sub.EV_LVL_ChangedAt)
                        FROM
                            attributes.EV_LVL_Event_Level sub
                        WHERE
                            sub.EV_LVL_EV_ID = a.EV_LVL_EV_ID
                        AND
                            sub.EV_LVL_ChangedAt <= changingTimepoint
                    )
            ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.PLV_ProfessionalLevel "kLVL"
        ON
            "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
    ]';
END pEV_Event;
/
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
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
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
            timepoints.inspectedTimepoint,
            timepoints.mnemonic,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
            "ETY_of".ETY_Checksum AS of_ETY_Checksum,
            "ETY_of".ETY_EventType AS of_ETY_EventType,
            "ETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_Event_Date,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_Event_Audience,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_Event_Revenue,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_Event_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "kUTL".UTL_Utilization AS EV_UTL_UTL_Utilization,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ChangedAt,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM (
            SELECT DISTINCT
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
        JOIN
            nexuses.EV_Event "EV"
        ON
            "EV".EV_ID = timepoints.EV_ID
        LEFT JOIN
            knots.ETY_EventType "ETY_of"
        ON
            "ETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN
            attributes.EV_DAT_Event_Date "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_AUD_Event_Audience "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_REV_Event_Revenue "REV"
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
                attributes.EV_STA_Event_Status h
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
            attributes.EV_UTL_Event_Utilization "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.UTL_Utilization "kUTL"
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
                attributes.EV_LVL_Event_Level h
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
            knots.PLV_ProfessionalLevel "kLVL"
        ON
            "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
    ]';
END dEV_Event;
/
