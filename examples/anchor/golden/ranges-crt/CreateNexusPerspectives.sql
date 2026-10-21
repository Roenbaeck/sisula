-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."tEV_Event" (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" bigint,
    "ST_ID_wasHeldAt" int,
    "PR_ID_wasPlayed" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" bigint,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" bigint,
    "EV_DAT_ID" bigint,
    "EV_DAT_PositedAt" timestamp_ntz(3),
    "EV_DAT_Who" smallint,
    "EV_DAT_Confidence" decimal(7,3),
    "EV_DAT_Stance" string,
    "EV_DAT_Event_Date" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" bigint,
    "EV_AUD_ID" bigint,
    "EV_AUD_PositedAt" timestamp_ntz(3),
    "EV_AUD_Who" smallint,
    "EV_AUD_Confidence" decimal(7,3),
    "EV_AUD_Stance" string,
    "EV_AUD_Event_Audience" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" bigint,
    "EV_REV_ID" bigint,
    "EV_REV_PositedAt" timestamp_ntz(3),
    "EV_REV_Who" smallint,
    "EV_REV_Confidence" decimal(7,3),
    "EV_REV_Stance" string,
    "EV_REV_Event_Revenue" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_PositedAt" timestamp_ntz(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" string,
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" bigint,
    "EV_UTL_ID" bigint,
    "EV_UTL_PositedAt" timestamp_ntz(3),
    "EV_UTL_Who" smallint,
    "EV_UTL_Confidence" decimal(7,3),
    "EV_UTL_Stance" string,
    "EV_UTL_UTL_Utilization" tinyint,
    "EV_UTL_Metadata_UTL" bigint,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp_ntz(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" string,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_ProfessionalLevel" string,
    "EV_LVL_Metadata_PLV" bigint,
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
    "DAT"."EV_DAT_Who",
    "DAT"."EV_DAT_Confidence",
    "DAT"."EV_DAT_Stance",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Who",
    "AUD"."EV_AUD_Confidence",
    "AUD"."EV_AUD_Stance",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Who",
    "REV"."EV_REV_Confidence",
    "REV"."EV_REV_Stance",
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Who",
    "STA"."EV_STA_Confidence",
    "STA"."EV_STA_Stance",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Who",
    "UTL"."EV_UTL_Confidence",
    "UTL"."EV_UTL_Stance",
    "UTL"."EV_UTL_UTL_Utilization",
    "UTL"."EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Who",
    "LVL"."EV_LVL_Confidence",
    "LVL"."EV_LVL_Stance",
    "LVL"."EV_LVL_PLV_Checksum",
    "LVL"."EV_LVL_PLV_ProfessionalLevel",
    "LVL"."EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Event" "EV"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and Snowflake cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    dw."_Who" p
LEFT JOIN
    knots."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: Snowflake cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            TABLE(attributes."rEV_DAT_Event_Date"(
                null::smallint,
                positingTimepoint::timestamp_ntz(3)
            )) r
    ) x
    WHERE
        x."EV_DAT_Stance" = coalesce(assertion, x."EV_DAT_Stance")
    QUALIFY
        row_number() OVER (
            PARTITION BY x."EV_DAT_Who", x."EV_DAT_EV_ID"
            ORDER BY
                x."EV_DAT_PositedAt" DESC,
                x."EV_DAT_Confidence" DESC
        ) = 1
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: Snowflake cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            TABLE(attributes."rEV_AUD_Event_Audience"(
                null::smallint,
                positingTimepoint::timestamp_ntz(3)
            )) r
    ) x
    WHERE
        x."EV_AUD_Stance" = coalesce(assertion, x."EV_AUD_Stance")
    QUALIFY
        row_number() OVER (
            PARTITION BY x."EV_AUD_Who", x."EV_AUD_EV_ID"
            ORDER BY
                x."EV_AUD_PositedAt" DESC,
                x."EV_AUD_Confidence" DESC
        ) = 1
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: Snowflake cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            TABLE(attributes."rEV_REV_Event_Revenue"(
                null::smallint,
                positingTimepoint::timestamp_ntz(3)
            )) r
    ) x
    WHERE
        x."EV_REV_Stance" = coalesce(assertion, x."EV_REV_Stance")
    QUALIFY
        row_number() OVER (
            PARTITION BY x."EV_REV_Who", x."EV_REV_EV_ID"
            ORDER BY
                x."EV_REV_PositedAt" DESC,
                x."EV_REV_Confidence" DESC
        ) = 1
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: Snowflake cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(iff(r."EV_STA_Stance" <> '?', r."EV_STA_ChangedAt", null)) OVER (
                PARTITION BY r."EV_STA_Who", r."EV_STA_EV_ID"
            ) AS "inEffect"
        FROM
            TABLE(attributes."rEV_STA_Event_Status"(
                null::smallint,
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) r
    ) x
    WHERE
        x."EV_STA_Stance" = coalesce(assertion, x."EV_STA_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."EV_STA_ChangedAt" = x."inEffect"
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x."EV_STA_Who", x."EV_STA_EV_ID"
            ORDER BY
                x."EV_STA_ChangedAt" DESC,
                x."EV_STA_PositedAt" DESC,
                x."EV_STA_Confidence" DESC
        ) = 1
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_Who" = p."Who"
LEFT JOIN (
    -- the knot joined in here, since Snowflake cannot call this function for each positor with it joined outside
    SELECT
        y.*,
        k."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
        k."UTL_Utilization" AS "EV_UTL_UTL_Utilization"
    FROM (
    -- the posit in effect for each nexus and positor, picked by a window: Snowflake cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            TABLE(attributes."rEV_UTL_Event_Utilization"(
                null::smallint,
                positingTimepoint::timestamp_ntz(3)
            )) r
    ) x
    WHERE
        x."EV_UTL_Stance" = coalesce(assertion, x."EV_UTL_Stance")
    QUALIFY
        row_number() OVER (
            PARTITION BY x."EV_UTL_Who", x."EV_UTL_EV_ID"
            ORDER BY
                x."EV_UTL_PositedAt" DESC,
                x."EV_UTL_Confidence" DESC
        ) = 1
    ) y
    LEFT JOIN
        knots."UTL_Utilization" k
    ON
        k."UTL_ID" = y."EV_UTL_UTL_ID"
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
AND
    "UTL"."EV_UTL_Who" = p."Who"
LEFT JOIN (
    -- the knot joined in here, since Snowflake cannot call this function for each positor with it joined outside
    SELECT
        y.*,
        k."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
        k."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
        k."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each nexus and positor, picked by a window: Snowflake cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(iff(r."EV_LVL_Stance" <> '?', r."EV_LVL_ChangedAt", null)) OVER (
                PARTITION BY r."EV_LVL_Who", r."EV_LVL_EV_ID"
            ) AS "inEffect"
        FROM
            TABLE(attributes."rEV_LVL_Event_Level"(
                null::smallint,
                changingTimepoint::date,
                positingTimepoint::timestamp_ntz(3)
            )) r
    ) x
    WHERE
        x."EV_LVL_Stance" = coalesce(assertion, x."EV_LVL_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."EV_LVL_ChangedAt" = x."inEffect"
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x."EV_LVL_Who", x."EV_LVL_EV_ID"
            ORDER BY
                x."EV_LVL_ChangedAt" DESC,
                x."EV_LVL_PositedAt" DESC,
                x."EV_LVL_Confidence" DESC
        ) = 1
    ) y
    LEFT JOIN
        knots."PLV_ProfessionalLevel" k
    ON
        k."PLV_ID" = y."EV_LVL_PLV_ID"
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_Who" = p."Who"
WHERE
    p."Who" = positor
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."lEV_Event" COPY GRANTS AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    "EV".*
FROM
    dw."_Who" p,
    TABLE(nexuses."tEV_Event"(
        p."Who",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) "EV"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."pEV_Event" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "EV_ID" numeric(12,0),
    "Metadata_EV" bigint,
    "ST_ID_wasHeldAt" int,
    "PR_ID_wasPlayed" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" bigint,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" bigint,
    "EV_DAT_ID" bigint,
    "EV_DAT_PositedAt" timestamp_ntz(3),
    "EV_DAT_Who" smallint,
    "EV_DAT_Confidence" decimal(7,3),
    "EV_DAT_Stance" string,
    "EV_DAT_Event_Date" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" bigint,
    "EV_AUD_ID" bigint,
    "EV_AUD_PositedAt" timestamp_ntz(3),
    "EV_AUD_Who" smallint,
    "EV_AUD_Confidence" decimal(7,3),
    "EV_AUD_Stance" string,
    "EV_AUD_Event_Audience" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" bigint,
    "EV_REV_ID" bigint,
    "EV_REV_PositedAt" timestamp_ntz(3),
    "EV_REV_Who" smallint,
    "EV_REV_Confidence" decimal(7,3),
    "EV_REV_Stance" string,
    "EV_REV_Event_Revenue" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_PositedAt" timestamp_ntz(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" string,
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" bigint,
    "EV_UTL_ID" bigint,
    "EV_UTL_PositedAt" timestamp_ntz(3),
    "EV_UTL_Who" smallint,
    "EV_UTL_Confidence" decimal(7,3),
    "EV_UTL_Stance" string,
    "EV_UTL_UTL_Utilization" tinyint,
    "EV_UTL_Metadata_UTL" bigint,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp_ntz(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" string,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_ProfessionalLevel" string,
    "EV_LVL_Metadata_PLV" bigint,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
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
    "EV"."EV_DAT_Who",
    "EV"."EV_DAT_Confidence",
    "EV"."EV_DAT_Stance",
    "EV"."EV_DAT_Event_Date",
    "EV"."EV_AUD_EV_ID",
    "EV"."Metadata_EV_AUD",
    "EV"."EV_AUD_ID",
    "EV"."EV_AUD_PositedAt",
    "EV"."EV_AUD_Who",
    "EV"."EV_AUD_Confidence",
    "EV"."EV_AUD_Stance",
    "EV"."EV_AUD_Event_Audience",
    "EV"."EV_REV_EV_ID",
    "EV"."Metadata_EV_REV",
    "EV"."EV_REV_ID",
    "EV"."EV_REV_PositedAt",
    "EV"."EV_REV_Who",
    "EV"."EV_REV_Confidence",
    "EV"."EV_REV_Stance",
    "EV"."EV_REV_Event_Revenue",
    "EV"."EV_STA_EV_ID",
    "EV"."Metadata_EV_STA",
    "EV"."EV_STA_ID",
    "EV"."EV_STA_ChangedAt",
    "EV"."EV_STA_PositedAt",
    "EV"."EV_STA_Who",
    "EV"."EV_STA_Confidence",
    "EV"."EV_STA_Stance",
    "EV"."EV_STA_Event_Status",
    "EV"."EV_UTL_EV_ID",
    "EV"."Metadata_EV_UTL",
    "EV"."EV_UTL_ID",
    "EV"."EV_UTL_PositedAt",
    "EV"."EV_UTL_Who",
    "EV"."EV_UTL_Confidence",
    "EV"."EV_UTL_Stance",
    "EV"."EV_UTL_UTL_Utilization",
    "EV"."EV_UTL_Metadata_UTL",
    "EV"."EV_UTL_UTL_ID",
    "EV"."EV_LVL_EV_ID",
    "EV"."Metadata_EV_LVL",
    "EV"."EV_LVL_ID",
    "EV"."EV_LVL_ChangedAt",
    "EV"."EV_LVL_PositedAt",
    "EV"."EV_LVL_Who",
    "EV"."EV_LVL_Confidence",
    "EV"."EV_LVL_Stance",
    "EV"."EV_LVL_PLV_Checksum",
    "EV"."EV_LVL_PLV_ProfessionalLevel",
    "EV"."EV_LVL_Metadata_PLV",
    "EV"."EV_LVL_PLV_ID"
FROM
    dw."_Who" p,
    TABLE(nexuses."tEV_Event"(
        p."Who",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) "EV"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."nEV_Event" COPY GRANTS AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    "EV".*
FROM
    dw."_Who" p,
    TABLE(nexuses."tEV_Event"(
        p."Who",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) "EV"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."dEV_Event" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    "Who" smallint,
    inspectedTimepoint timestamp_ntz(9),
    "EV_ID" numeric(12,0),
    "Metadata_EV" bigint,
    "ST_ID_wasHeldAt" int,
    "PR_ID_wasPlayed" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" bigint,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" bigint,
    "EV_DAT_ID" bigint,
    "EV_DAT_PositedAt" timestamp_ntz(3),
    "EV_DAT_Who" smallint,
    "EV_DAT_Confidence" decimal(7,3),
    "EV_DAT_Stance" string,
    "EV_DAT_Event_Date" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" bigint,
    "EV_AUD_ID" bigint,
    "EV_AUD_PositedAt" timestamp_ntz(3),
    "EV_AUD_Who" smallint,
    "EV_AUD_Confidence" decimal(7,3),
    "EV_AUD_Stance" string,
    "EV_AUD_Event_Audience" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" bigint,
    "EV_REV_ID" bigint,
    "EV_REV_PositedAt" timestamp_ntz(3),
    "EV_REV_Who" smallint,
    "EV_REV_Confidence" decimal(7,3),
    "EV_REV_Stance" string,
    "EV_REV_Event_Revenue" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_PositedAt" timestamp_ntz(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" string,
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" bigint,
    "EV_UTL_ID" bigint,
    "EV_UTL_PositedAt" timestamp_ntz(3),
    "EV_UTL_Who" smallint,
    "EV_UTL_Confidence" decimal(7,3),
    "EV_UTL_Stance" string,
    "EV_UTL_UTL_Utilization" tinyint,
    "EV_UTL_Metadata_UTL" bigint,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp_ntz(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" string,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_ProfessionalLevel" string,
    "EV_LVL_Metadata_PLV" bigint,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. Snowflake cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with an outer join on its argument for each row of another
-- table.
SELECT
    p."Who",
    tp.inspectedTimepoint,
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
    "DAT"."EV_DAT_Who",
    "DAT"."EV_DAT_Confidence",
    "DAT"."EV_DAT_Stance",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Who",
    "AUD"."EV_AUD_Confidence",
    "AUD"."EV_AUD_Stance",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Who",
    "REV"."EV_REV_Confidence",
    "REV"."EV_REV_Stance",
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Who",
    "STA"."EV_STA_Confidence",
    "STA"."EV_STA_Stance",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Who",
    "UTL"."EV_UTL_Confidence",
    "UTL"."EV_UTL_Stance",
    "kUTL"."UTL_Utilization" AS "EV_UTL_UTL_Utilization",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Who",
    "LVL"."EV_LVL_Confidence",
    "LVL"."EV_LVL_Stance",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    dw."_Who" p
JOIN (
    SELECT DISTINCT
        "EV_STA_Who" AS positor,
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
        "EV_LVL_Who" AS positor,
        "EV_LVL_EV_ID" AS "EV_ID",
        "EV_LVL_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes."EV_LVL_Event_Level"
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        "EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Who"
JOIN
    nexuses."EV_Event" "EV"
ON
    "EV"."EV_ID" = tp."EV_ID"
LEFT JOIN
    knots."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_DAT_Event_Date"(
            null::smallint,
            '9999-12-31'::timestamp_ntz(3)
        )) r
    WHERE
        r."EV_DAT_Stance" = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_DAT_Who", r."EV_DAT_EV_ID"
            ORDER BY
                r."EV_DAT_PositedAt" DESC,
                r."EV_DAT_Confidence" DESC
        ) = 1
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Who" = tp.positor
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_AUD_Event_Audience"(
            null::smallint,
            '9999-12-31'::timestamp_ntz(3)
        )) r
    WHERE
        r."EV_AUD_Stance" = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_AUD_Who", r."EV_AUD_EV_ID"
            ORDER BY
                r."EV_AUD_PositedAt" DESC,
                r."EV_AUD_Confidence" DESC
        ) = 1
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Who" = tp.positor
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_REV_Event_Revenue"(
            null::smallint,
            '9999-12-31'::timestamp_ntz(3)
        )) r
    WHERE
        r."EV_REV_Stance" = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_REV_Who", r."EV_REV_EV_ID"
            ORDER BY
                r."EV_REV_PositedAt" DESC,
                r."EV_REV_Confidence" DESC
        ) = 1
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Who" = tp.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y."EV_STA_ChangedAt") OVER (
            PARTITION BY y."EV_STA_Who", y."EV_STA_EV_ID"
            ORDER BY y."EV_STA_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            TABLE(attributes."rEV_STA_Event_Status"(
                null::smallint,
                '9999-12-31'::datetime,
                '9999-12-31'::timestamp_ntz(3)
            )) r
        WHERE
            r."EV_STA_Stance" <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r."EV_STA_Who", r."EV_STA_EV_ID", r."EV_STA_ChangedAt"
                ORDER BY
                    iff(r."EV_STA_Stance" = '+', 0, 1),
                    r."EV_STA_PositedAt" DESC,
                    r."EV_STA_Confidence" DESC
            ) = 1
    ) y
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_Who" = tp.positor
AND
    "STA"."EV_STA_Stance" = '+'
AND
    "STA"."EV_STA_ChangedAt" <= tp.inspectedTimepoint::datetime
AND (
    "STA"."until" IS NULL
OR
    "STA"."until" > tp.inspectedTimepoint::datetime
)
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rEV_UTL_Event_Utilization"(
            null::smallint,
            '9999-12-31'::timestamp_ntz(3)
        )) r
    WHERE
        r."EV_UTL_Stance" = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r."EV_UTL_Who", r."EV_UTL_EV_ID"
            ORDER BY
                r."EV_UTL_PositedAt" DESC,
                r."EV_UTL_Confidence" DESC
        ) = 1
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
AND
    "UTL"."EV_UTL_Who" = tp.positor
LEFT JOIN
    knots."UTL_Utilization" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."EV_LVL_ChangedAt") OVER (
            PARTITION BY y."EV_LVL_Who", y."EV_LVL_EV_ID"
            ORDER BY y."EV_LVL_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            TABLE(attributes."rEV_LVL_Event_Level"(
                null::smallint,
                '9999-12-31'::date,
                '9999-12-31'::timestamp_ntz(3)
            )) r
        WHERE
            r."EV_LVL_Stance" <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r."EV_LVL_Who", r."EV_LVL_EV_ID", r."EV_LVL_ChangedAt"
                ORDER BY
                    iff(r."EV_LVL_Stance" = '+', 0, 1),
                    r."EV_LVL_PositedAt" DESC,
                    r."EV_LVL_Confidence" DESC
            ) = 1
    ) y
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_Who" = tp.positor
AND
    "LVL"."EV_LVL_Stance" = '+'
AND
    "LVL"."EV_LVL_ChangedAt" <= tp.inspectedTimepoint::date
AND (
    "LVL"."until" IS NULL
OR
    "LVL"."until" > tp.inspectedTimepoint::date
)
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$
;
