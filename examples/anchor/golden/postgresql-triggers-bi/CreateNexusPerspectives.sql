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
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Reliability" decimal(5,2),
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
    "QTY"."EV_QTY_Reliability",
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    "PLC"."EV_PLC_ID",
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_PositedAt",
    "PLC"."EV_PLC_Reliability",
    "PLC"."EV_PLC_Event_Place"
FROM
    public."EV_Event" "EV"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_QTY_EV_ID")
        r.*
    FROM
        public."rEV_QTY_Event_Quantity"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_QTY_Reliability" = 1
    ORDER BY
    r."EV_QTY_EV_ID",
    r."EV_QTY_PositedAt" DESC
) "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_PLC_EV_ID")
        r.*
    FROM
        public."rEV_PLC_Event_Place"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_PLC_Reliability" = 1
    ORDER BY
    r."EV_PLC_EV_ID",
    r."EV_PLC_ChangedAt" DESC,
    r."EV_PLC_PositedAt" DESC
) "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
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
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Event_Place" varchar(42)
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "EV"."EV_QTY_EV_ID",
    "EV"."Metadata_EV_QTY",
    "EV"."EV_QTY_ID",
    "EV"."EV_QTY_PositedAt",
    "EV"."EV_QTY_Reliability",
    "EV"."EV_QTY_Event_Quantity",
    "EV"."EV_PLC_EV_ID",
    "EV"."Metadata_EV_PLC",
    "EV"."EV_PLC_ID",
    "EV"."EV_PLC_ChangedAt",
    "EV"."EV_PLC_PositedAt",
    "EV"."EV_PLC_Reliability",
    "EV"."EV_PLC_Event_Place"
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
CREATE OR REPLACE FUNCTION public."dEV_Event" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "EV_ID" integer,
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Event_Place" varchar(42)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The time-traveling
-- perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "QTY"."EV_QTY_EV_ID",
    "QTY"."Metadata_EV_QTY",
    "QTY"."EV_QTY_ID",
    "QTY"."EV_QTY_PositedAt",
    "QTY"."EV_QTY_Reliability",
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    "PLC"."EV_PLC_ID",
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_PositedAt",
    "PLC"."EV_PLC_Reliability",
    "PLC"."EV_PLC_Event_Place"
FROM (
    SELECT DISTINCT
        "EV_PLC_EV_ID" AS "EV_ID",
        "EV_PLC_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLC' AS mnemonic
    FROM
        public."EV_PLC_Event_Place"
    WHERE
        (selection IS NULL OR selection LIKE '%PLC%')
    AND
        "EV_PLC_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."EV_Event" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_QTY_EV_ID")
        r.*
    FROM
        public."rEV_QTY_Event_Quantity"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_QTY_Reliability" = 1
    ORDER BY
    r."EV_QTY_EV_ID",
    r."EV_QTY_PositedAt" DESC
) "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."EV_PLC_ChangedAt") OVER (
            PARTITION BY x."EV_PLC_EV_ID"
            ORDER BY x."EV_PLC_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."EV_PLC_EV_ID", r."EV_PLC_ChangedAt")
            r.*
        FROM
            public."rEV_PLC_Event_Place"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."EV_PLC_Reliability" = 1
        ORDER BY
    r."EV_PLC_EV_ID", r."EV_PLC_ChangedAt",
    r."EV_PLC_PositedAt" DESC
    ) x
) "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
AND
    "PLC"."EV_PLC_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "PLC"."until" IS NULL
OR
    "PLC"."until" > timepoints.inspectedTimepoint::timestamp
)
$$ LANGUAGE sql STABLE;
