-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BI nexus perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the perspectives that
-- take a time (time traveling, point-in-time and difference) are not made; the latest and the now perspectives take none,
-- and are views over the rewinders of the attributes (views that show the latest annex row of every posit).
--
CREATE OR REPLACE VIEW public."lEV_Event" AS
SELECT
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
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
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
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        public."rEV_DAT_Event_Date" r
    WHERE
        r."EV_DAT_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."EV_DAT_EV_ID"
        ORDER BY
            r."EV_DAT_PositedAt" DESC
    )
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        public."rEV_AUD_Event_Audience" r
    WHERE
        r."EV_AUD_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."EV_AUD_EV_ID"
        ORDER BY
            r."EV_AUD_PositedAt" DESC
    )
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        public."rEV_REV_Event_Revenue" r
    WHERE
        r."EV_REV_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."EV_REV_EV_ID"
        ORDER BY
            r."EV_REV_PositedAt" DESC
    )
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
;
CREATE OR REPLACE VIEW public."nEV_Event" AS
SELECT
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
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
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
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        public."rEV_DAT_Event_Date" r
    WHERE
        r."EV_DAT_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."EV_DAT_EV_ID"
        ORDER BY
            r."EV_DAT_PositedAt" DESC
    )
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        public."rEV_AUD_Event_Audience" r
    WHERE
        r."EV_AUD_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."EV_AUD_EV_ID"
        ORDER BY
            r."EV_AUD_PositedAt" DESC
    )
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        public."rEV_REV_Event_Revenue" r
    WHERE
        r."EV_REV_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."EV_REV_EV_ID"
        ORDER BY
            r."EV_REV_PositedAt" DESC
    )
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
;
