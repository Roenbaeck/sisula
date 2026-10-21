-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION nexuses."tEV_Event" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_wasHeldAt" int,
    "PR_ID_wasPlayed" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_ID" ,
    "EV_DAT_PositedAt" datetime,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Event_Date" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_ID" ,
    "EV_AUD_PositedAt" datetime,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Event_Audience" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_ID" ,
    "EV_REV_PositedAt" datetime,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Event_Revenue" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ID" ,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_PositedAt" datetime,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_ID" ,
    "EV_UTL_PositedAt" datetime,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_UTL_Utilization" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ID" ,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" datetime,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_ProfessionalLevel" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "kETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
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
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Reliability",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Reliability",
    "kUTL"."UTL_Utilization" AS "EV_UTL_UTL_Utilization",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Reliability",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Event" "EV"
LEFT JOIN
    knots."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_DAT_Event_Date"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."EV_DAT_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_DAT_EV_ID"
            ORDER BY
                r."EV_DAT_PositedAt" DESC
        ) = 1
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_AUD_Event_Audience"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."EV_AUD_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_AUD_EV_ID"
            ORDER BY
                r."EV_AUD_PositedAt" DESC
        ) = 1
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_REV_Event_Revenue"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."EV_REV_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_REV_EV_ID"
            ORDER BY
                r."EV_REV_PositedAt" DESC
        ) = 1
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_STA_Event_Status"(
            changingTimepoint::datetime,
            positingTimepoint::datetime
        )) r
    WHERE
        r."EV_STA_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_STA_EV_ID"
            ORDER BY
                r."EV_STA_ChangedAt" DESC,
                r."EV_STA_PositedAt" DESC
        ) = 1
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_UTL_Event_Utilization"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."EV_UTL_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_UTL_EV_ID"
            ORDER BY
                r."EV_UTL_PositedAt" DESC
        ) = 1
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utilization" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_LVL_Event_Level"(
            changingTimepoint::date,
            positingTimepoint::datetime
        )) r
    WHERE
        r."EV_LVL_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_LVL_EV_ID"
            ORDER BY
                r."EV_LVL_ChangedAt" DESC,
                r."EV_LVL_PositedAt" DESC
        ) = 1
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$
;
CREATE OR REPLACE VIEW nexuses."lEV_Event" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    TABLE(nexuses."tEV_Event"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "EV"
;
CREATE OR REPLACE FUNCTION nexuses."pEV_Event" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_wasHeldAt" int,
    "PR_ID_wasPlayed" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_ID" ,
    "EV_DAT_PositedAt" datetime,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Event_Date" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_ID" ,
    "EV_AUD_PositedAt" datetime,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Event_Audience" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_ID" ,
    "EV_REV_PositedAt" datetime,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Event_Revenue" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ID" ,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_PositedAt" datetime,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_ID" ,
    "EV_UTL_PositedAt" datetime,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_UTL_Utilization" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ID" ,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" datetime,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_ProfessionalLevel" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "EV"."of_ETY_Checksum",
    "EV"."of_ETY_EventType",
    "EV"."of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "EV"."EV_DAT_EV_ID",
    "EV"."Metadata_EV_DAT",
    "EV"."EV_DAT_ID",
    "EV"."EV_DAT_PositedAt",
    "EV"."EV_DAT_Reliability",
    "EV"."EV_DAT_Event_Date",
    "EV"."EV_AUD_EV_ID",
    "EV"."Metadata_EV_AUD",
    "EV"."EV_AUD_ID",
    "EV"."EV_AUD_PositedAt",
    "EV"."EV_AUD_Reliability",
    "EV"."EV_AUD_Event_Audience",
    "EV"."EV_REV_EV_ID",
    "EV"."Metadata_EV_REV",
    "EV"."EV_REV_ID",
    "EV"."EV_REV_PositedAt",
    "EV"."EV_REV_Reliability",
    "EV"."EV_REV_Event_Revenue",
    "EV"."EV_STA_EV_ID",
    "EV"."Metadata_EV_STA",
    "EV"."EV_STA_ID",
    "EV"."EV_STA_ChangedAt",
    "EV"."EV_STA_PositedAt",
    "EV"."EV_STA_Reliability",
    "EV"."EV_STA_Event_Status",
    "EV"."EV_UTL_EV_ID",
    "EV"."Metadata_EV_UTL",
    "EV"."EV_UTL_ID",
    "EV"."EV_UTL_PositedAt",
    "EV"."EV_UTL_Reliability",
    "EV"."EV_UTL_UTL_Utilization",
    "EV"."EV_UTL_Metadata_UTL",
    "EV"."EV_UTL_UTL_ID",
    "EV"."EV_LVL_EV_ID",
    "EV"."Metadata_EV_LVL",
    "EV"."EV_LVL_ID",
    "EV"."EV_LVL_ChangedAt",
    "EV"."EV_LVL_PositedAt",
    "EV"."EV_LVL_Reliability",
    "EV"."EV_LVL_PLV_Checksum",
    "EV"."EV_LVL_PLV_ProfessionalLevel",
    "EV"."EV_LVL_Metadata_PLV",
    "EV"."EV_LVL_PLV_ID"
FROM
    TABLE(nexuses."tEV_Event"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "EV"
$$
;
CREATE OR REPLACE VIEW nexuses."nEV_Event" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    TABLE(nexuses."tEV_Event"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "EV"
;
CREATE OR REPLACE FUNCTION nexuses."dEV_Event" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_wasHeldAt" int,
    "PR_ID_wasPlayed" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_ID" ,
    "EV_DAT_PositedAt" datetime,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Event_Date" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_ID" ,
    "EV_AUD_PositedAt" datetime,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Event_Audience" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_ID" ,
    "EV_REV_PositedAt" datetime,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Event_Revenue" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ID" ,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_PositedAt" datetime,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_ID" ,
    "EV_UTL_PositedAt" datetime,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_UTL_Utilization" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ID" ,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" datetime,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_ProfessionalLevel" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. Snowflake cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "kETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
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
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Reliability",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Reliability",
    "kUTL"."UTL_Utilization" AS "EV_UTL_UTL_Utilization",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Reliability",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM (
    SELECT DISTINCT
        "EV_STA_EV_ID" AS "EV_ID",
        "EV_STA_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."EV_STA_Event_Status"
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        "EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "EV_LVL_EV_ID" AS "EV_ID",
        "EV_LVL_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes."EV_LVL_Event_Level"
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        "EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses."EV_Event" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    knots."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_DAT_Event_Date"(
            '9999-12-31'::datetime
        )) r
    WHERE
        r."EV_DAT_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_DAT_EV_ID"
            ORDER BY r."EV_DAT_PositedAt" DESC
        ) = 1
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_AUD_Event_Audience"(
            '9999-12-31'::datetime
        )) r
    WHERE
        r."EV_AUD_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_AUD_EV_ID"
            ORDER BY r."EV_AUD_PositedAt" DESC
        ) = 1
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_REV_Event_Revenue"(
            '9999-12-31'::datetime
        )) r
    WHERE
        r."EV_REV_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_REV_EV_ID"
            ORDER BY r."EV_REV_PositedAt" DESC
        ) = 1
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."EV_STA_ChangedAt") OVER (
            PARTITION BY x."EV_STA_EV_ID"
            ORDER BY x."EV_STA_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            TABLE(attributes."rEV_STA_Event_Status"(
                '9999-12-31'::datetime,
                '9999-12-31'::datetime
            )) r
        WHERE
            r."EV_STA_Reliability" = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r."EV_STA_EV_ID", r."EV_STA_ChangedAt"
                ORDER BY r."EV_STA_PositedAt" DESC
            ) = 1
    ) x
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" <= timepoints.inspectedTimepoint::datetime
AND (
    "STA"."until" IS NULL
OR
    "STA"."until" > timepoints.inspectedTimepoint::datetime
)
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_UTL_Event_Utilization"(
            '9999-12-31'::datetime
        )) r
    WHERE
        r."EV_UTL_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_UTL_EV_ID"
            ORDER BY r."EV_UTL_PositedAt" DESC
        ) = 1
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utilization" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."EV_LVL_ChangedAt") OVER (
            PARTITION BY x."EV_LVL_EV_ID"
            ORDER BY x."EV_LVL_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            TABLE(attributes."rEV_LVL_Event_Level"(
                '9999-12-31'::date,
                '9999-12-31'::datetime
            )) r
        WHERE
            r."EV_LVL_Reliability" = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r."EV_LVL_EV_ID", r."EV_LVL_ChangedAt"
                ORDER BY r."EV_LVL_PositedAt" DESC
            ) = 1
    ) x
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" <= timepoints.inspectedTimepoint::date
AND (
    "LVL"."until" IS NULL
OR
    "LVL"."until" > timepoints.inspectedTimepoint::date
)
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$
;
