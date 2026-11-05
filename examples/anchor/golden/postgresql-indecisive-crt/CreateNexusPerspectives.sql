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
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Positor" smallint,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Assertion" char(1),
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Positor" smallint,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Assertion" char(1),
    "EV_PLC_Event_Place" varchar(42)
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "QTY"."EV_QTY_EV_ID",
    "QTY"."Metadata_EV_QTY",
    "QTY"."EV_QTY_ID",
    "QTY"."EV_QTY_PositedAt",
    "QTY"."EV_QTY_Positor",
    "QTY"."EV_QTY_Reliability",
    "QTY"."EV_QTY_Assertion",
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    "PLC"."EV_PLC_ID",
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_PositedAt",
    "PLC"."EV_PLC_Positor",
    "PLC"."EV_PLC_Reliability",
    "PLC"."EV_PLC_Assertion",
    "PLC"."EV_PLC_Event_Place"
FROM
    public."EV_Event" "EV"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_QTY_Positor", x."EV_QTY_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_QTY_Event_Quantity"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."EV_QTY_Assertion" = coalesce(assertion, x."EV_QTY_Assertion")
    ORDER BY
    x."EV_QTY_Positor", x."EV_QTY_EV_ID",
    x."EV_QTY_PositedAt" DESC,
    x."EV_QTY_Reliability" DESC
) "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
AND
    "QTY"."EV_QTY_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_PLC_Positor", x."EV_PLC_EV_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_PLC_Assertion" <> '?' THEN r."EV_PLC_ChangedAt" END) OVER (
                PARTITION BY r."EV_PLC_Positor", r."EV_PLC_EV_ID"
            ) AS "inEffect"
        FROM
            public."rEV_PLC_Event_Place"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."EV_PLC_Assertion" = coalesce(assertion, x."EV_PLC_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."EV_PLC_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."EV_PLC_Positor", x."EV_PLC_EV_ID",
    x."EV_PLC_ChangedAt" DESC,
    x."EV_PLC_PositedAt" DESC,
    x."EV_PLC_Reliability" DESC
) "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
AND
    "PLC"."EV_PLC_Positor" = p."Positor"
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
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Positor" smallint,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Assertion" char(1),
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Positor" smallint,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Assertion" char(1),
    "EV_PLC_Event_Place" varchar(42)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "EV"."EV_QTY_EV_ID",
    "EV"."Metadata_EV_QTY",
    "EV"."EV_QTY_ID",
    "EV"."EV_QTY_PositedAt",
    "EV"."EV_QTY_Positor",
    "EV"."EV_QTY_Reliability",
    "EV"."EV_QTY_Assertion",
    "EV"."EV_QTY_Event_Quantity",
    "EV"."EV_PLC_EV_ID",
    "EV"."Metadata_EV_PLC",
    "EV"."EV_PLC_ID",
    "EV"."EV_PLC_ChangedAt",
    "EV"."EV_PLC_PositedAt",
    "EV"."EV_PLC_Positor",
    "EV"."EV_PLC_Reliability",
    "EV"."EV_PLC_Assertion",
    "EV"."EV_PLC_Event_Place"
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
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dEV_Event" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "EV_ID" integer,
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Positor" smallint,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Assertion" char(1),
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Positor" smallint,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Assertion" char(1),
    "EV_PLC_Event_Place" varchar(42)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "QTY"."EV_QTY_EV_ID",
    "QTY"."Metadata_EV_QTY",
    "QTY"."EV_QTY_ID",
    "QTY"."EV_QTY_PositedAt",
    "QTY"."EV_QTY_Positor",
    "QTY"."EV_QTY_Reliability",
    "QTY"."EV_QTY_Assertion",
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    "PLC"."EV_PLC_ID",
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_PositedAt",
    "PLC"."EV_PLC_Positor",
    "PLC"."EV_PLC_Reliability",
    "PLC"."EV_PLC_Assertion",
    "PLC"."EV_PLC_Event_Place"
FROM
    public."_Positor" p
JOIN (
    SELECT DISTINCT
        "EV_PLC_Positor" AS positor,
        "EV_PLC_EV_ID" AS "EV_ID",
        "EV_PLC_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLC' AS mnemonic
    FROM
        public."EV_PLC_Event_Place"
    WHERE
        (selection IS NULL OR selection LIKE '%PLC%')
    AND
        "EV_PLC_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor"
JOIN
    public."EV_Event" "EV"
ON
    "EV"."EV_ID" = tp."EV_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_QTY_Positor", r."EV_QTY_EV_ID")
        r.*
    FROM
        public."rEV_QTY_Event_Quantity"(
            null::smallint,
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_QTY_Assertion" = '+'
    ORDER BY
    r."EV_QTY_Positor", r."EV_QTY_EV_ID",
    r."EV_QTY_PositedAt" DESC,
    r."EV_QTY_Reliability" DESC
) "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
AND
    "QTY"."EV_QTY_Positor" = tp.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y."EV_PLC_ChangedAt") OVER (
            PARTITION BY y."EV_PLC_Positor", y."EV_PLC_EV_ID"
            ORDER BY y."EV_PLC_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."EV_PLC_Positor", r."EV_PLC_EV_ID", r."EV_PLC_ChangedAt")
            r.*
        FROM
            public."rEV_PLC_Event_Place"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."EV_PLC_Assertion" <> '?'
        ORDER BY
    r."EV_PLC_Positor", r."EV_PLC_EV_ID", r."EV_PLC_ChangedAt",
    CASE WHEN r."EV_PLC_Assertion" = '+' THEN 0 ELSE 1 END,
    r."EV_PLC_PositedAt" DESC,
    r."EV_PLC_Reliability" DESC
    ) y
) "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
AND
    "PLC"."EV_PLC_Positor" = tp.positor
AND
    "PLC"."EV_PLC_Assertion" = '+'
AND
    "PLC"."EV_PLC_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    "PLC"."until" IS NULL
OR
    "PLC"."until" > tp.inspectedTimepoint::timestamp
)
$$ LANGUAGE sql STABLE;
