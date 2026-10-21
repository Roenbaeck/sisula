-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION public."tEV_Event" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "EV_ID" int,
    "ST_ID_wasHeldAt" int,
    "PR_ID_wasPlayed" int,
    "ETY_EventType" varchar(42),
    "ETY_ID_of" tinyint,
    "EV_DAT_ID" int,
    "EV_DAT_PositedAt" datetime,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Event_Date" datetime,
    "EV_AUD_ID" int,
    "EV_AUD_PositedAt" datetime,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Event_Audience" int,
    "EV_REV_ID" int,
    "EV_REV_PositedAt" datetime,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Event_Revenue" number(19,4)
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "kETY_of"."ETY_EventType" AS "ETY_EventType",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Event_Revenue"
FROM
    public."EV_Event" "EV"
LEFT JOIN
    public."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(public."rEV_DAT_Event_Date"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."EV_DAT_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_ID"
            ORDER BY
                r."EV_DAT_PositedAt" DESC
        ) = 1
) "DAT"
ON
    "DAT"."EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(public."rEV_AUD_Event_Audience"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."EV_AUD_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_ID"
            ORDER BY
                r."EV_AUD_PositedAt" DESC
        ) = 1
) "AUD"
ON
    "AUD"."EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(public."rEV_REV_Event_Revenue"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."EV_REV_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_ID"
            ORDER BY
                r."EV_REV_PositedAt" DESC
        ) = 1
) "REV"
ON
    "REV"."EV_ID" = "EV"."EV_ID"
$$
;
CREATE OR REPLACE VIEW public."lEV_Event" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    TABLE(public."tEV_Event"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "EV"
;
CREATE OR REPLACE FUNCTION public."pEV_Event" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "EV_ID" int,
    "ST_ID_wasHeldAt" int,
    "PR_ID_wasPlayed" int,
    "ETY_EventType" varchar(42),
    "ETY_ID_of" tinyint,
    "EV_DAT_ID" int,
    "EV_DAT_PositedAt" datetime,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Event_Date" datetime,
    "EV_AUD_ID" int,
    "EV_AUD_PositedAt" datetime,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Event_Audience" int,
    "EV_REV_ID" int,
    "EV_REV_PositedAt" datetime,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Event_Revenue" number(19,4)
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV"."EV_ID",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "EV"."ETY_EventType",
    "EV"."ETY_ID_of",
    "EV"."EV_DAT_ID",
    "EV"."EV_DAT_PositedAt",
    "EV"."EV_DAT_Reliability",
    "EV"."EV_DAT_Event_Date",
    "EV"."EV_AUD_ID",
    "EV"."EV_AUD_PositedAt",
    "EV"."EV_AUD_Reliability",
    "EV"."EV_AUD_Event_Audience",
    "EV"."EV_REV_ID",
    "EV"."EV_REV_PositedAt",
    "EV"."EV_REV_Reliability",
    "EV"."EV_REV_Event_Revenue"
FROM
    TABLE(public."tEV_Event"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "EV"
$$
;
CREATE OR REPLACE VIEW public."nEV_Event" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    TABLE(public."tEV_Event"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "EV"
;
