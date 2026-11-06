-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- nexus perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lEV_Event" (
    "EV_ID",
    "Metadata_EV",
    "SU_ID_for",
    "EV_QTY_EV_ID",
    "Metadata_EV_QTY",
    "Deletable_EV_QTY",
    "EV_QTY_Event_Quantity",
    "EV_PLC_EV_ID",
    "Metadata_EV_PLC",
    "Deletable_EV_PLC",
    "EV_PLC_ChangedAt",
    "EV_PLC_Event_Place"
)
AS
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "QTY"."EV_QTY_EV_ID",
    "QTY"."Metadata_EV_QTY",
    NULL::boolean,
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    NULL::boolean,
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_Event_Place"
FROM
    public."EV_Event" "EV"
LEFT JOIN
    public."EV_QTY_Event_Quantity" "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."EV_PLC_Event_Place" "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
AND
    "PLC"."EV_PLC_ChangedAt" = (
        SELECT
            max(sub."EV_PLC_ChangedAt")
        FROM
            public."EV_PLC_Event_Place" sub
        WHERE
            sub."EV_PLC_EV_ID" = "EV"."EV_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pEV_Event" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" integer,
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ChangedAt" timestamp,
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
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_Event_Place"
FROM
    public."EV_Event" "EV"
LEFT JOIN
    public."EV_QTY_Event_Quantity" "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."rEV_PLC_Event_Place"(changingTimepoint::timestamp) "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
AND
    "PLC"."EV_PLC_ChangedAt" = (
        SELECT
            max(sub."EV_PLC_ChangedAt")
        FROM
            public."rEV_PLC_Event_Place"(changingTimepoint::timestamp) sub
        WHERE
            sub."EV_PLC_EV_ID" = "EV"."EV_ID"
   )
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nEV_Event" AS
SELECT
    *
FROM
    public."pEV_Event"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dEV_Event" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "EV_ID" integer,
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_Event_Place" varchar(42)
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. The point-in-time perspective is not called for each change; the values are worked out
-- for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "QTY"."EV_QTY_EV_ID",
    "QTY"."Metadata_EV_QTY",
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_Event_Place"
FROM (
    SELECT DISTINCT
        h."EV_PLC_EV_ID" AS "EV_ID",
        h."EV_PLC_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLC' AS mnemonic
    FROM
        public."EV_PLC_Event_Place" h
    WHERE
        (selection IS NULL OR selection LIKE '%PLC%')
    AND
        h."EV_PLC_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."EV_Event" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    public."EV_QTY_Event_Quantity" "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."EV_PLC_ChangedAt") OVER (
            PARTITION BY h."EV_PLC_EV_ID"
            ORDER BY h."EV_PLC_ChangedAt"
        ) AS "until"
    FROM
        public."EV_PLC_Event_Place" h
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
