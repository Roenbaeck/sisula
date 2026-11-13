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
    ST_ID_wasHeldAt,
    PR_ID_wasPlayed,
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
    EV_REV_Event_Revenue
)
AS
SELECT
    "EV".EV_ID,
    "EV".Metadata_EV,
    "EV".ST_ID_wasHeldAt,
    "EV".PR_ID_wasPlayed,
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
    "REV".EV_REV_Event_Revenue
FROM
    EV_Event "EV"
LEFT JOIN
    ETY_EventType "ETY_of"
ON
    "ETY_of".ETY_ID = "EV".ETY_ID_of
LEFT JOIN
    EV_DAT_Event_Date "DAT"
ON
    "DAT".EV_DAT_EV_ID = "EV".EV_ID
LEFT JOIN
    EV_AUD_Event_Audience "AUD"
ON
    "AUD".EV_AUD_EV_ID = "EV".EV_ID
LEFT JOIN
    EV_REV_Event_Revenue "REV"
ON
    "REV".EV_REV_EV_ID = "EV".EV_ID
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
            "EV".ST_ID_wasHeldAt,
            "EV".PR_ID_wasPlayed,
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
            "REV".EV_REV_Event_Revenue
        FROM
            EV_Event "EV"
        LEFT JOIN
            ETY_EventType "ETY_of"
        ON
            "ETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN
            EV_DAT_Event_Date "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN
            EV_AUD_Event_Audience "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN
            EV_REV_Event_Revenue "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
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
