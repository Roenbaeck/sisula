-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native nexus perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lEV_Event" (
    "EV_ID",
    "ST_ID_wasHeldAt" COMMENT 'The stage at which the event was held.',
    "PR_ID_wasPlayed" COMMENT 'The program that was played at the event.',
    "ETY_EventType" COMMENT 'The type of the event.',
    "ETY_ID_of" COMMENT 'The type of the event.',
    "EV_DAT_Event_Date" COMMENT 'Date and time when the event took place.',
    "EV_AUD_Event_Audience" COMMENT 'Number of people in the audience at the event.',
    "EV_REV_Event_Revenue" COMMENT 'Revenue from ticket sales for the event.'
) COPY GRANTS COMMENT = 'An event, a single performance of a program held at a stage at a specific date and time.'
AS
SELECT
    "EV"."EV_ID",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "ETY_of"."ETY_EventType" AS "ETY_EventType",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_Event_Revenue"
FROM
    public."EV_Event" "EV"
LEFT JOIN
    public."ETY_EventType" "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    public."EV_DAT_Event_Date" "DAT"
ON
    "DAT"."EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."EV_AUD_Event_Audience" "AUD"
ON
    "AUD"."EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."EV_REV_Event_Revenue" "REV"
ON
    "REV"."EV_ID" = "EV"."EV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pEV_Event" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "EV_ID" int,
    "ST_ID_wasHeldAt" int,
    "PR_ID_wasPlayed" int,
    "ETY_EventType" varchar(42),
    "ETY_ID_of" tinyint,
    "EV_DAT_Event_Date" datetime,
    "EV_AUD_Event_Audience" int,
    "EV_REV_Event_Revenue" number(19,4)
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "ETY_of"."ETY_EventType" AS "ETY_EventType",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_Event_Revenue"
FROM
    public."EV_Event" "EV"
LEFT JOIN
    public."ETY_EventType" "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    public."EV_DAT_Event_Date" "DAT"
ON
    "DAT"."EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."EV_AUD_Event_Audience" "AUD"
ON
    "AUD"."EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."EV_REV_Event_Revenue" "REV"
ON
    "REV"."EV_ID" = "EV"."EV_ID"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nEV_Event" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public."pEV_Event"(sysdate()::timestamp_ntz(9)))
;
