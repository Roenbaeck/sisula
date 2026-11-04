-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION public."tEV_Event" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" integer,
    "ETY_EventType" varchar(42),
    "ETY_ID_of" smallint,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Event_Audience" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Event_Revenue" decimal(19,4)
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
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_ID")
        r.*
    FROM
        public."rEV_DAT_Event_Date"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_DAT_Reliability" = 1
    ORDER BY
    r."EV_ID",
    r."EV_DAT_PositedAt" DESC
) "DAT"
ON
    "DAT"."EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_ID")
        r.*
    FROM
        public."rEV_AUD_Event_Audience"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_AUD_Reliability" = 1
    ORDER BY
    r."EV_ID",
    r."EV_AUD_PositedAt" DESC
) "AUD"
ON
    "AUD"."EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_ID")
        r.*
    FROM
        public."rEV_REV_Event_Revenue"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_REV_Reliability" = 1
    ORDER BY
    r."EV_ID",
    r."EV_REV_PositedAt" DESC
) "REV"
ON
    "REV"."EV_ID" = "EV"."EV_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lEV_Event" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    public."tEV_Event"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
;
CREATE OR REPLACE FUNCTION public."pEV_Event" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "EV_ID" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" integer,
    "ETY_EventType" varchar(42),
    "ETY_ID_of" smallint,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Event_Audience" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Event_Revenue" decimal(19,4)
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
    public."tEV_Event"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nEV_Event" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    public."tEV_Event"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
;
