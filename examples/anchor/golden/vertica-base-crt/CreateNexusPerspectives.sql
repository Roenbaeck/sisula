-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- CRT nexus perspectives: latest (l) and now (n), for each positor. Vertica has no function that returns a table, so the
-- perspectives that take a time or a positor (time traveling, point-in-time and difference) are not made; the latest and the now
-- perspectives take none, and are views over the rewinders of the attributes (views that show the latest annex row of every posit
-- for each positor). The assertion that they show is the positive one.
--
CREATE OR REPLACE VIEW public."lEV_Event" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
CROSS JOIN
    public."_Positor" p
LEFT JOIN
    public."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_DAT_Event_Date" r
    ) x
    WHERE
        x."EV_DAT_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_DAT_Positor", x."EV_DAT_EV_ID"
        ORDER BY
            x."EV_DAT_PositedAt" DESC,
            x."EV_DAT_Reliability" DESC
    )
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_AUD_Event_Audience" r
    ) x
    WHERE
        x."EV_AUD_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_AUD_Positor", x."EV_AUD_EV_ID"
        ORDER BY
            x."EV_AUD_PositedAt" DESC,
            x."EV_AUD_Reliability" DESC
    )
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_REV_Event_Revenue" r
    ) x
    WHERE
        x."EV_REV_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_REV_Positor", x."EV_REV_EV_ID"
        ORDER BY
            x."EV_REV_PositedAt" DESC,
            x."EV_REV_Reliability" DESC
    )
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Positor" = p."Positor"
;
CREATE OR REPLACE VIEW public."nEV_Event" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
CROSS JOIN
    public."_Positor" p
LEFT JOIN
    public."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_DAT_Event_Date" r
    ) x
    WHERE
        x."EV_DAT_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_DAT_Positor", x."EV_DAT_EV_ID"
        ORDER BY
            x."EV_DAT_PositedAt" DESC,
            x."EV_DAT_Reliability" DESC
    )
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_AUD_Event_Audience" r
    ) x
    WHERE
        x."EV_AUD_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_AUD_Positor", x."EV_AUD_EV_ID"
        ORDER BY
            x."EV_AUD_PositedAt" DESC,
            x."EV_AUD_Reliability" DESC
    )
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_REV_Event_Revenue" r
    ) x
    WHERE
        x."EV_REV_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_REV_Positor", x."EV_REV_EV_ID"
        ORDER BY
            x."EV_REV_PositedAt" DESC,
            x."EV_REV_Reliability" DESC
    )
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Positor" = p."Positor"
;
