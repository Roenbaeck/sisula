-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION nexuses."tEV_Händelse" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_ID" integer,
    "EV_UTL_PositedAt" timestamp,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "kETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "kETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "kETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Reliability",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Reliability",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Reliability",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
LEFT JOIN
    knots."ETY_Händelsetyp" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_DAT_EV_ID")
        r.*
    FROM
        attributes."rEV_DAT_Händelse_Datum"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_DAT_Reliability" = 1
    ORDER BY
    r."EV_DAT_EV_ID",
    r."EV_DAT_PositedAt" DESC
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_AUD_EV_ID")
        r.*
    FROM
        attributes."rEV_AUD_Händelse_Publik"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_AUD_Reliability" = 1
    ORDER BY
    r."EV_AUD_EV_ID",
    r."EV_AUD_PositedAt" DESC
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_REV_EV_ID")
        r.*
    FROM
        attributes."rEV_REV_Händelse_Intäkt"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_REV_Reliability" = 1
    ORDER BY
    r."EV_REV_EV_ID",
    r."EV_REV_PositedAt" DESC
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_STA_EV_ID")
        r.*
    FROM
        attributes."rEV_STA_Händelse_Status"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_STA_Reliability" = 1
    ORDER BY
    r."EV_STA_EV_ID",
    r."EV_STA_ChangedAt" DESC,
    r."EV_STA_PositedAt" DESC
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_UTL_EV_ID")
        r.*
    FROM
        attributes."rEV_UTL_Händelse_Utnyttjande"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_UTL_Reliability" = 1
    ORDER BY
    r."EV_UTL_EV_ID",
    r."EV_UTL_PositedAt" DESC
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_LVL_EV_ID")
        r.*
    FROM
        attributes."rEV_LVL_Händelse_Level"(
            changingTimepoint::date,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_LVL_Reliability" = 1
    ORDER BY
    r."EV_LVL_EV_ID",
    r."EV_LVL_ChangedAt" DESC,
    r."EV_LVL_PositedAt" DESC
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."PLV_Yrkesnivå" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW nexuses."lEV_Händelse" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    nexuses."tEV_Händelse"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
;
CREATE OR REPLACE FUNCTION nexuses."pEV_Händelse" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_ID" integer,
    "EV_UTL_PositedAt" timestamp,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "EV"."of_ETY_Checksum",
    "EV"."of_ETY_Händelsetyp",
    "EV"."of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "EV"."EV_DAT_EV_ID",
    "EV"."Metadata_EV_DAT",
    "EV"."EV_DAT_ID",
    "EV"."EV_DAT_PositedAt",
    "EV"."EV_DAT_Reliability",
    "EV"."EV_DAT_Händelse_Datum",
    "EV"."EV_AUD_EV_ID",
    "EV"."Metadata_EV_AUD",
    "EV"."EV_AUD_ID",
    "EV"."EV_AUD_PositedAt",
    "EV"."EV_AUD_Reliability",
    "EV"."EV_AUD_Händelse_Publik",
    "EV"."EV_REV_EV_ID",
    "EV"."Metadata_EV_REV",
    "EV"."EV_REV_ID",
    "EV"."EV_REV_PositedAt",
    "EV"."EV_REV_Reliability",
    "EV"."EV_REV_Händelse_Intäkt",
    "EV"."EV_STA_EV_ID",
    "EV"."Metadata_EV_STA",
    "EV"."EV_STA_ID",
    "EV"."EV_STA_ChangedAt",
    "EV"."EV_STA_PositedAt",
    "EV"."EV_STA_Reliability",
    "EV"."EV_STA_Händelse_Status",
    "EV"."EV_UTL_EV_ID",
    "EV"."Metadata_EV_UTL",
    "EV"."EV_UTL_ID",
    "EV"."EV_UTL_PositedAt",
    "EV"."EV_UTL_Reliability",
    "EV"."EV_UTL_UTL_Utnyttjande",
    "EV"."EV_UTL_Metadata_UTL",
    "EV"."EV_UTL_UTL_ID",
    "EV"."EV_LVL_EV_ID",
    "EV"."Metadata_EV_LVL",
    "EV"."EV_LVL_ID",
    "EV"."EV_LVL_ChangedAt",
    "EV"."EV_LVL_PositedAt",
    "EV"."EV_LVL_Reliability",
    "EV"."EV_LVL_PLV_Checksum",
    "EV"."EV_LVL_PLV_Yrkesnivå",
    "EV"."EV_LVL_Metadata_PLV",
    "EV"."EV_LVL_PLV_ID"
FROM
    nexuses."tEV_Händelse"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW nexuses."nEV_Händelse" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    nexuses."tEV_Händelse"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
;
CREATE OR REPLACE FUNCTION nexuses."dEV_Händelse" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_ID" integer,
    "EV_UTL_PositedAt" timestamp,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
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
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "kETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "kETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "kETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Reliability",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Reliability",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Reliability",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM (
    SELECT DISTINCT
        "EV_STA_EV_ID" AS "EV_ID",
        "EV_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."EV_STA_Händelse_Status"
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        "EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "EV_LVL_EV_ID" AS "EV_ID",
        "EV_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes."EV_LVL_Händelse_Level"
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        "EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses."EV_Händelse" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    knots."ETY_Händelsetyp" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_DAT_EV_ID")
        r.*
    FROM
        attributes."rEV_DAT_Händelse_Datum"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_DAT_Reliability" = 1
    ORDER BY
    r."EV_DAT_EV_ID",
    r."EV_DAT_PositedAt" DESC
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_AUD_EV_ID")
        r.*
    FROM
        attributes."rEV_AUD_Händelse_Publik"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_AUD_Reliability" = 1
    ORDER BY
    r."EV_AUD_EV_ID",
    r."EV_AUD_PositedAt" DESC
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_REV_EV_ID")
        r.*
    FROM
        attributes."rEV_REV_Händelse_Intäkt"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_REV_Reliability" = 1
    ORDER BY
    r."EV_REV_EV_ID",
    r."EV_REV_PositedAt" DESC
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
        SELECT DISTINCT ON (r."EV_STA_EV_ID", r."EV_STA_ChangedAt")
            r.*
        FROM
            attributes."rEV_STA_Händelse_Status"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."EV_STA_Reliability" = 1
        ORDER BY
    r."EV_STA_EV_ID", r."EV_STA_ChangedAt",
    r."EV_STA_PositedAt" DESC
    ) x
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "STA"."until" IS NULL
OR
    "STA"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_UTL_EV_ID")
        r.*
    FROM
        attributes."rEV_UTL_Händelse_Utnyttjande"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_UTL_Reliability" = 1
    ORDER BY
    r."EV_UTL_EV_ID",
    r."EV_UTL_PositedAt" DESC
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
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
        SELECT DISTINCT ON (r."EV_LVL_EV_ID", r."EV_LVL_ChangedAt")
            r.*
        FROM
            attributes."rEV_LVL_Händelse_Level"(
                '9999-12-31'::date,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."EV_LVL_Reliability" = 1
        ORDER BY
    r."EV_LVL_EV_ID", r."EV_LVL_ChangedAt",
    r."EV_LVL_PositedAt" DESC
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
    knots."PLV_Yrkesnivå" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
