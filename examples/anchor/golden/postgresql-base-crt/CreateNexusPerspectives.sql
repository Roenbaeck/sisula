-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tEV_Event" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "EV_ID" integer,
    "Metadata_EV" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" integer,
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" integer,
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Positor" smallint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" char(1),
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" integer,
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Positor" smallint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" char(1),
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" integer,
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Positor" smallint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" char(1),
    "EV_REV_Event_Revenue" decimal(19,4)
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "kETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "kETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Positor",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Assertion",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Positor",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Assertion",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Positor",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Assertion",
    "REV"."EV_REV_Event_Revenue"
FROM
    public."EV_Event" "EV"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public."_Positor" p
LEFT JOIN
    public."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_DAT_Positor", x."EV_DAT_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_DAT_Event_Date"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."EV_DAT_Assertion" = coalesce(assertion, x."EV_DAT_Assertion")
    ORDER BY
    x."EV_DAT_Positor", x."EV_DAT_EV_ID",
    x."EV_DAT_PositedAt" DESC,
    x."EV_DAT_Reliability" DESC
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_AUD_Positor", x."EV_AUD_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_AUD_Event_Audience"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."EV_AUD_Assertion" = coalesce(assertion, x."EV_AUD_Assertion")
    ORDER BY
    x."EV_AUD_Positor", x."EV_AUD_EV_ID",
    x."EV_AUD_PositedAt" DESC,
    x."EV_AUD_Reliability" DESC
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_REV_Positor", x."EV_REV_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_REV_Event_Revenue"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."EV_REV_Assertion" = coalesce(assertion, x."EV_REV_Assertion")
    ORDER BY
    x."EV_REV_Positor", x."EV_REV_EV_ID",
    x."EV_REV_PositedAt" DESC,
    x."EV_REV_Reliability" DESC
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Positor" = p."Positor"
WHERE
    p."Positor" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lEV_Event" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV".*
FROM
    public."_Positor" p,
    public."tEV_Event"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "EV"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pEV_Event" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "EV_ID" integer,
    "Metadata_EV" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" integer,
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" integer,
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Positor" smallint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" char(1),
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" integer,
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Positor" smallint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" char(1),
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" integer,
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Positor" smallint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" char(1),
    "EV_REV_Event_Revenue" decimal(19,4)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "EV"."of_ETY_EventType",
    "EV"."of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "EV"."EV_DAT_EV_ID",
    "EV"."Metadata_EV_DAT",
    "EV"."EV_DAT_ID",
    "EV"."EV_DAT_PositedAt",
    "EV"."EV_DAT_Positor",
    "EV"."EV_DAT_Reliability",
    "EV"."EV_DAT_Assertion",
    "EV"."EV_DAT_Event_Date",
    "EV"."EV_AUD_EV_ID",
    "EV"."Metadata_EV_AUD",
    "EV"."EV_AUD_ID",
    "EV"."EV_AUD_PositedAt",
    "EV"."EV_AUD_Positor",
    "EV"."EV_AUD_Reliability",
    "EV"."EV_AUD_Assertion",
    "EV"."EV_AUD_Event_Audience",
    "EV"."EV_REV_EV_ID",
    "EV"."Metadata_EV_REV",
    "EV"."EV_REV_ID",
    "EV"."EV_REV_PositedAt",
    "EV"."EV_REV_Positor",
    "EV"."EV_REV_Reliability",
    "EV"."EV_REV_Assertion",
    "EV"."EV_REV_Event_Revenue"
FROM
    public."_Positor" p,
    public."tEV_Event"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "EV"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nEV_Event" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV".*
FROM
    public."_Positor" p,
    public."tEV_Event"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "EV"
;
